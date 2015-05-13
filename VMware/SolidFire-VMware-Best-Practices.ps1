<#

            SolidFire Best Practices Implementation Script

          This script simplifies implementation of recommended 
                configurations for VMware environments
             
             Authors: Josh Atwell | josh.atwell@soldifire.com
                     Aaron Patten | aaron.patten@solidfire.com

====================================================================
|                              Disclaimer:                         |
| This script is written as best effort and provides no warranty   |
| expressed or implied. Please contact SolidFire support if you    |
| have questions about this script before running or modifying.    |
====================================================================

Requirements:
1. Active PowerCLI connection to a vCenter server or ESXi host
2. User must have privileges to make changes to advanced settings
3. Evaluation of each segment's configuration changes as it relates
   to your environment.  Not all recommendations apply to everyone
#>

######  VMware Host Selection ######
<# Choose the vSphere host filter.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Requires active connection to your vCenter server !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#>
If ((Get-PSSnapin "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue) -eq $null) {
    Write-Output "This script must be run in PowerShell session with PowerCLI loaded"
    Return
}else{
    $vmhosts = Get-VMhost
}

######  Interactive Mode ########
<# Beneath this section choose the components that you want to include.  

Options included in script.
1 | Increase  MaxHWTransferSize size from 4MB to 16MB !!! only for Nitrogen
2 | Set DSNRO (Disk Scheduler Number Req Outstanding for a volume
3 | Set Queue Depth for Software iSCSI initiator to 256
4 | Turn Off DelayedAck for Random Workloads !!! Only for throughput heavy workloads or latency senstive applications
5 | Create Custom SATP Rule for SolidFire

#>

$apply = ""

# Use if you need to include only specific settings. Must be comma-separated
# Example $apply = 2,3,5

$apply = 4

#$apply = "all"

$verbose = $true

#######      The Script blocks   #######
if($verbose = $true){
Write-Output "
      ______________            ___
     /__/__\__\__\__\       ___/__/
    /_ /__/_\__\__\__\  ___/__/__/ 
   /__/__/__/\__\__\__\/__/__/__/  
  /__/__/__/  \__\__\__\_/__/__/   
 /__/__/       \__\__\__\__/__/    
/__/            \__\__\__\/__/     
       Fueled By SolidFire        

   SolidFire VMware Configuration 
       Implementation Script
"
}

#########    Begin Block 1 | MaxHWTransferSize    ####################
if($apply -contains 1 -or $apply -eq "all"){

if($verbose = $true){
    Write-Output "Increasing MaxHWTransferSize size from 4MB to 16MB"
}
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

foreach ($esxi in $vmhosts){
    #$esxi | Get-AdvancedSetting -Name "DataMover.MaxHWTransferSize" | Set-AdvancedSetting -Value 16384
	#[AP] - Added the "-Confirm:$false" for obvious reasons
	 $esxi | Get-AdvancedSetting -Name DataMover.MaxHWTransferSize | Set-AdvancedSetting -Value 4096 -Confirm:$false
    
    # Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Output ("MaxHWTransferSize size set to 16MB for " + $esxi.name)
    }
}
}
##################### End Block 1 ####################################

#########    Begin Block 2 | DSNRO    ################################
if($apply -contains 2 -or $apply -eq "all"){
if($verbose = $true){
    Write-Output "Setting DSNRO to 64"
}
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

$dsnro = 256
foreach ($esxi in $vmhosts)
{
    $esxcli=get-esxcli -VMHost $esxi
    $devices = $esxi | Get-ScsiLun | Where{$_.Vendor -match "SolidFir"}
    foreach ($device in $devices)
    {
        $esxcli.storage.core.device.set($null, $device.CanonicalName, $null, $null, $null, $null, $null, $dsnro, $null) 
		#[AP] - Added this line in case we recommend setting QFullSampleSize and QFullThreshold in addition to DSNRO
		#$esxcli.storage.core.device.set($null, $device.Device, $null, $null, $null, 32, 16, $dsnro, $null)

        # Output completion to screen if $verbose = $true
        if($verbose = $true){
            Write-Output ("DSNRO for " + $device.CanonicalName + " on host " + $esxi.name + " set to " + $dsnro)
        }
    }
}
}
##################### End Block 2 ####################################

#########    Begin Block 3 | Queue Depth    ##########################
if($apply -contains 3 -or $apply -eq "all"){
if($verbose = $true){
    Write-Output "Setting Queue Depth for Software iSCSI initiators to 256"
}
<#
3 | Set Queue Depth for Software iSCSI initiator to 256

Default value is 128
SolidFire recommended value is 256

Alternate method of implementation:
esxcli system module parameters set -m iscsi_vmk -p iscsivmk_LunQDepth=256
#>

foreach ($esxi in $vmhosts){
    $esxcli = get-esxcli -VMHost $esxi
    $esxcli.system.module.parameters.set($null,"iscsi_vmk","iscsivmk_LunQDepth=256")
    $esxcli.system.module.parameters.list("iscsi_vmk") | Where{$_.Name -eq "iscsivmk_LunQDepth"}

    # Output completion to screen if $verbose = $true
    if($verbose = $true){
            Write-Output ("Queue depth for " + $vmhost.Name + " set to 256")
    }
}
}
##################### End Block 3 ####################################


#########    Begin Block 4 | DelayedAck    ###########################
if($apply -contains 4 -or $apply -eq "all"){
if($verbose = $true){
    Write-Output "Turning off DelayedAck"
}
<# 
4 | Turn Off DelayedAck for Random Workloads

!!! Only for throughput heavy workload or latency senstive applications. !!!
This is a global ESXi host setting that applies to all software iSCSI initiator targets on the host.

Default application value is 1 (On)
Modified application value is 0 (Off)

Alternate method of implementation
vmkiscsi-tool vmhba38 -W -a delayed_ack=0

NOTES from https://communities.vmware.com/message/1830738  
#>

foreach($esxi in $vmhosts){

	#[AP] - Added the following lines: <addition>
	$HostView = Get-VMHost $esxi | Get-View  
	$storagesystemID = $HostView.configmanager.StorageSystem  
	$adapterID = ($HostView.config.storagedevice.HostBusAdapter | where {$_.Model -match "iSCSI Software"}).device  
	
    #$adapterID = $esxi.ExtensionData.config.StorageDevice.HostBusAdapter | Where{$_.Model -match "iSCSI"}
    #$storagesystemID = $esxi.ExtensionData.configmanager.StorageSystem 

    $options = New-Object VMWare.Vim.HostInternetScsiHbaParamValue[] (1)  
    $options[0] = New-Object VMware.Vim.HostInternetScsiHbaParamValue  
    $options[0].key = "DelayedAck"  
    $options[0].value = $false
    $esxiStorageSystem = Get-View -ID $storagesystemID
    $esxiStorageSystem.UpdateInternetScsiAdvancedOptions($adapterID, $null, $options)

    # Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Output ("DelayedAck turned off for " + $esxi.name)
    }
}
}
##################### End Block 4 ####################################


#########    Begin Block 5 | SATP Rule    ############################
if($apply -contains 5 -or $apply -eq "all"){
if($verbose = $true){
    Write-Output "Creating Custom SATP Rule"
}
<# 
5 | Create Custom SATP Rule for SolidFire

Alternate method of implementation
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

#>

foreach($esxi in $vmhosts){

    $esxcli = Get-Esxcli -VMHost $esxi
    #$esxcli.storage.nmp.satp.rule.add($false,$null,“SolidFire custom SATP rule",$null,$null,$true,“SSD SAN”,$null,"VMW_PSP_RR","iops='1'","VMW_SATP_DEFAULT_AA",$null,$null,“SolidFir")
	#[AP] - The below string fixed it.
	$esxcli.storage.nmp.satp.rule.add($null, $null, "SolidFire Custom SATP", $null, $null, $null, "SSD SAN", $null, "VMW_PSP_RR", "iops=1", "VMW_SATP_DEFAULT_AA", $null, $null, "SolidFir")
    #[AP] - This will error if the rule already exists. Should list the SATP rules first and see if we find the string "SolidFir" in the vendor string
    
	# Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Output ("Custom SATP rule created for " + $esxi.name)
    }
}

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