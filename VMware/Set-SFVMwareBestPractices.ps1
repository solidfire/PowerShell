Function Set-SFVMwareBestPractices{
<#
    .Synopsis
	
 	 Applies ESXi host configuration information with respect to SolidFire recommended configurations. Organized by ESXi host object
	 
	.Description 
	 Applies ESXi host configuration information with respect to SolidFire recommended configurations.

     Options included in script.
     1 | Increase  MaxHWTransferSize size from 4MB to 16MB !!! only for Nitrogen
     2 | Set DSNRO (Disk Scheduler Number Req Outstanding for a volume
     3 | Set Queue Depth for Software iSCSI initiator to 256
     4 | Turn Off DelayedAck for Random Workloads !!! Only for throughput heavy workloads or latency senstive applications
     5 | Create Custom SATP Rule for SolidFire

     Requirements:
     1. Active PowerCLI connection to a vCenter server or ESXi host
     2. User must have privileges to make changes to advanced settings
     3. Evaluation of each segment's configuration changes as it relatesto your environment.  
     
     Not all recommendations apply to everyone
   
     PLEASE READ ALL SCRIPT BLOCKS!
	 
	.Parameter VMHost
	
	 Represents a VMware vSphere ESXi host where settings will be applied.
	
	.Parameter Configuration
	 
	 Allows user to specify the configurations they would like to Query
	 
	.Example
	
	 Get-VMHost | Set-SFVMwareBestPractices

     Sets all configurations for all ESXi hosts.

	.Example
	 
	 Get-VMHost esxi6-prod-01 | Set-SFVMwareBestPractices -Configuration 1 -MaxHWTransferSize 16384

     Sets the first configuration information for a single ESXi host. Optional value provided.

	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
     Authors: Josh Atwell | josh.atwell@soldifire.com
     Aaron Patten | aaron.patten@solidfire.com

====================================================================
|                              Disclaimer:                         |
| This script is written as best effort and provides no warranty   |
| expressed or implied. Please contact SolidFire support if you    |
| have questions about this script before running or modifying.    |
====================================================================


#>
[CmdletBinding(ConfirmImpact="Medium")]
param(
[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the ESXi Host.")]
        [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
        $VMhost,
[Parameter(Mandatory=$false)]
$Configuration="all",
[Parameter(Mandatory=$false)]
$Confirm = $true,
[Parameter(Mandatory=$false)]
[Int]$MaxHWTransferSize=16384,
[Parameter(Mandatory=$false)]
[Int]$dsnro=64,
[Parameter(Mandatory=$false)]
[Int]$qdepth=256
)

Begin{
If ((Get-Module "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue) -eq $null) {
    Write-Output "This script must be run in PowerShell session with PowerCLI 6.x loaded"
    Return
}
}

Process{
$esxcli = Get-EsxCli -VMHost $VMhost

#########    Begin Block 1 | MaxHWTransferSize    ####################
if($configuration -contains 1 -or $configuration -eq "all"){
    Write-Verbose "Increasing MaxHWTransferSize size from 4MB to 16MB"
<#
1 | Increase MaxHWTransferSize size from 4MB to 16MB (only for Nitrogen) 

Default value is 4MB
SolidFire recommended value is 16MB

Per ESXi Host Setting

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!      Only applied for Nitrogen release and later                        !!!
!!! This setting will result in poor xcopy and write-same offload in Carbon !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Alternate method of implementation:
esxcfg-advcfg -s 16384 /DataMover/MaxHWTransferSize
  or 
esxcli system settings advanced set -i 16384 -o /DataMover/MaxHWTransferSize
#>
    $VMhost | Get-AdvancedSetting -Name "DataMover.MaxHWTransferSize" | Set-AdvancedSetting -Value $MaxHWTransferSize -Confirm:$($Confirm)    
    
    # Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Verbose ("MaxHWTransferSize size set to 16MB for " + $VMhost.name)
    }
}
##################### End Block 1 ####################################

#########    Begin Block 2 | DSNRO    ################################
if($configuration -contains 2 -or $configuration -eq "all"){
    Write-Verbose "Setting DSNRO to 64"
<#
2 | Set DSNRO (Disk Scheduler Number Req Outstanding for a volume

Only applied to SolidFire devices

Default value is 32
Max value is 256
SolidFire recommended value is 64
Set $dsnro to your preferred value if you want something other than 64

Alternate method of implementation:
esxcli storage core device set -d naa.xxxx -O 64
#>


    $esxcli=get-esxcli -VMHost $VMhost
    $devices = $VMhost | Get-ScsiLun | Where{$_.Vendor -match "SolidFir"}
    foreach ($device in $devices)
    {
        If($VMhost.Version.Split(".")[0] -ge "6"){
            #vSphere 6.x hosts or greater
            $esxcli.storage.core.device.set($null, $null, $device.CanonicalName, $null, $null, $null, $null, $null, $null, $null, $null, $dsnro, $null, $null)
        }else{
            #vSphere 5.x hosts
            $esxcli.storage.core.device.set($null, $device.CanonicalName, $null, $null, $null, $null, $null, $dsnro, $null)
        }
        
        Write-Verbose ("DSNRO for " + $device.CanonicalName + " on host " + $VMhost.name + " set to " + $dsnro)
    }
}

##################### End Block 2 ####################################

#########    Begin Block 3 | Queue Depth    ##########################
if($configuration -contains 3 -or $configuration -eq "all"){
Write-Verbose "Setting Queue Depth for Software iSCSI initiators to 256"
<#
3 | Set Queue Depth for Software iSCSI initiator to 256

Default value is 128
SolidFire recommended value is 256

Alternate method of implementation:
esxcli system module parameters set -m iscsi_vmk -p iscsivmk_LunQDepth=256
#>

    $esxcli = get-esxcli -VMHost $VMhost

    If($VMhost.Version.Split(".")[0] -ge "6"){
        #vSphere 6.x hosts or greater
        #$esxcli.system.module.parameters.set($null, $null,"iscsi_vmk","iscsivmk_LunQDepth=256")
        $esxcli.system.module.parameters.set($null, $null,"iscsi_vmk","iscsivmk_LunQDepth=$qdepth")
        
    }else{
        #vSphere 5.x command
        #$esxcli.system.module.parameters.set($null,"iscsi_vmk","iscsivmk_LunQDepth=256")
        $esxcli.system.module.parameters.set($null,"iscsi_vmk","iscsivmk_LunQDepth=$qdepth")

    }

    #$esxcli.system.module.parameters.list("iscsi_vmk") | Where{$_.Name -eq "iscsivmk_LunQDepth"}

    Write-Verbose ("Queue depth for " + $VMhost.Name + " set to $qdepth")
}
##################### End Block 3 ####################################


#########    Begin Block 4 | DelayedAck    ###########################
if($configuration -contains 4 -or $configuration -eq "all"){
    Write-Verbose "Turning off DelayedAck"
<# 
4 | Turn Off DelayedAck for Random Workloads

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! Only for throughput heavy workload or latency senstive applications.    !!!
!!! This is a global ESXi host setting that applies to all software iSCSI   !!!
!!! initiator targets on the host.                                          !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Default application value is 1 (On)
Modified application value is 0 (Off)

Alternate method of implementation:
vmkiscsi-tool vmhba38 -W -a delayed_ack=0

NOTES from https://communities.vmware.com/message/1830738  
#>

    $adapterID = $VMhost.ExtensionData.config.StorageDevice.HostBusAdapter | Where{$_.Model -match "iSCSI"}

    $esxcli.iscsi.adapter.param.set($adapterID.device, $null, "DelayedAck", "false")


    Write-Verbose ("DelayedAck turned off for " + $VMhost.name)
}
##################### End Block 4 ####################################


#########    Begin Block 5 | SATP Rule    ############################
if($configuration -contains 5 -or $configuration -eq "all"){
Write-Verbose "Creating Custom SATP Rule"
<# 
5 | Create Custom SATP Rule for SolidFire

Alternate method of implementation:
esxcli storage nmp satp rule add -s VMW_SATP_DEFAULT_AA -P VMW_PSP_RR -O iops=“1” -V “SolidFir" -M “SSD SAN” -e “SolidFire custom SATP rule" 

add(boolean boot, string claimoption, string description, string device, string driver, boolean force, string model, string option, string psp, string pspoption, string satp, string
transport, string type, string vendor)

    -s = The SATP for which a new rule will be added
    -P = Set the default PSP for the SATP claim rule
    -O = Set the PSP options for the SATP claim rule (option=string
    -V = Set the vendor string when adding SATP claim rules. Vendor/Model rules are mutually exclusive with driver rules (vendor=string)
    -M = Set the model string when adding SATP claim rule.
    -e = Claim rule description

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!      When to reboot the host upon applying setting                      !!!
!!! Reboot host if you have already presented SolidFire storage to the host !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

To remove the claim rule:
$esxcli.storage.nmp.satp.rule.remove($false, $null, "SolidFire custom SATP rule", $null, $null, "SSD SAN", $null, "VMW_PSP_RR", "iops=10", "VMW_SATP_DEFAULT_AA", $null, $null, "SolidFir")
#>

    $esxcli = Get-Esxcli -VMHost $VMhost
    $esxcli.storage.nmp.satp.rule.add($false, $null, "SolidFire custom SATP rule", $null, $null, $true, "SSD SAN", $null, "VMW_PSP_RR", "iops=10", "VMW_SATP_DEFAULT_AA", $null, $null, "SolidFir")
    
    Write-Output ("Custom SATP rule created for " + $VMhost.name)

<# Result Looks like:
ClaimOptions :
DefaultPSP   : VMW_PSP_RR
Description  : SolidFire custom SATP rule
Device       :
Driver       :
Model        : SSD SAN
Name         : VMW_SATP_DEFAULT_AA
Options      :
PSPOptions   : iops='1'
RuleGroup    : user
Transport    :
Vendor       : SolidFir
#>

}
##################### End Block 5 ####################################

}

}