Function Get-SFVMwareBestPractices {
<#
    .Synopsis
	
 	 Collects ESXi host configuration information with respect to SolidFire recommended configurations. Organized by ESXi host object
	 
	.Description 
	 Collects ESXi host configuration information with respect to SolidFire recommended configurations.

     Options included in script.
     1 | Increase  MaxHWTransferSize size from 4MB to 16MB !!! only for Nitrogen
     2 | Set DSNRO (Disk Scheduler Number Req Outstanding for a volume
     3 | Set Queue Depth for Software iSCSI initiator to 256
     4 | Turn Off DelayedAck for Random Workloads !!! Only for throughput heavy workloads or latency senstive applications
     5 | Create Custom SATP Rule for SolidFire
	 
	.Parameter VMHost
	
	 Represents a VMware vSphere ESXi host
	
	.Parameter Configuration
	 
	 Allows user to specify the configurations they would like to Query
	 
	.Example
	
	 Get-VMHost | Get-SFVMwareBestPractices

     Returns all configurations for all ESXi hosts.

	.Example
	 
	 Get-VMHost esxi6-prod-01 | Get-SFVMwareBestPractices -Configuration 1

     Returns the first configuration information for a single ESXi host.

	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
	
	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
#>
[CmdletBinding(ConfirmImpact="Low")]
param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the ESXi Host.")]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $vmhost,
        [Parameter(
        Position=2,
        Mandatory=$False,
        HelpMessage="Enter the SolidFire configurations to check. Use Get-Help to see available options."
        )]
        $configuration = "all"

)

Begin{
    # Validate that there is an active connection to a vCenter server
    If(!($defaultviserver)){
        Write-Output "No vCenter Server is available with this session"
        Break
    }
}

Process{

$esxcli = Get-EsxCli -VMHost $vmhost




###################
# 1 - Max HW Transfer Size
###################

if($configuration -contains 1 -or $configuration -eq "all"){
  Write-Verbose "Collecting Max HW Transfer Size"

    #$maxHWTransferSize = $vmhost | Get-AdvancedSetting -Name "DataMover.MaxHWTransferSize" | Select Value

    $vmhost | Select Name,@{N="MaxHWTransferSize";E={($_ | Get-AdvancedSetting -Name "DataMover.MaxHWTransferSize").Value }} | Format-Table -AutoSize

  #Write-Host $vmhost.Name " | " $maxHWTransferSize.Value
}

###################
# 2 - DSNRO
# No of outstanding IOs with competing worlds: 32
###################

if($configuration -contains 2 -or $configuration -eq "all"){
  Write-Verbose "Collecting Number of outstanding IOs with competing worlds"
    $devices = $vmhost | Get-ScsiLun | Where{$_.Vendor -match "SolidFir"}
    $devices | Select VMHost, CanonicalName, @{N="NoOf";E={($esxcli.storage.core.device.list($_.CanonicalName)).NoofoutstandingIOswithcompetingworlds}} | Format-Table -AutoSize
}

###################
# 3 - Queue Depth
###################

if($configuration -contains 3 -or $configuration -eq "all"){
  Write-Verbose "Collecting Queue Depth"
    $esxcli.system.module.parameters.list("iscsi_vmk") | Where{$_.Name -eq "iscsivmk_LunQDepth"} | Select Name,Value | Format-Table -AutoSize
    #Write-Host $vmhost.Name $qdepth.Name $qdepth.Value
}


###################
# 4 - Delayed Ack
###################

if($configuration -contains 4 -or $configuration -eq "all"){
  Write-Verbose "Collecting Delayed Ack"
    Write-Host $vmhost.Name
    $adapterID = $vmhost.ExtensionData.config.StorageDevice.HostBusAdapter | Where{$_.Model -match "iSCSI"}
    foreach($adapter in $adapterID){
        $esxcli.iscsi.adapter.param.get($adapter.device) | Where{$_.Name -eq "DelayedACK"} | Select ID, Current
    }
}

###################
# 5 - SATP
###################
if($configuration -contains 5 -or $configuration -eq "all"){
    Write-Verbose "Collecting SATP Info"
    $esxcli.storage.nmp.satp.rule.list() | Where{$_.Vendor -eq "SolidFir"}
}

}
}