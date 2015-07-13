<#

         SolidFire VMware Best Practices Implementation Script

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
   
   PLEASE READ ALL SCRIPT BLOCKS!
#>

######  User Input Section ########

<# User Checklist. Choose:
1. Verbose and Confirm selection
2. VMhosts to apply
3. Options to apply
#>

######  1. Verbose Output ######
# Verbose writes output letting user know what is happening throughout the script.
$verbose = $true

######  1b. Confirm ######
# Instructs the script whether to confirm your command or not.
# False means user will receive no confiromation.

$Confirm = $false

######  2. VMware Host Selection ######
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

######  3. Options to Apply ######
<# Beneath this section choose the components that you want to include.  

Options included in script.
1 | Increase  MaxHWTransferSize size from 4MB to 16MB !!! only for Nitrogen
2 | Set DSNRO (Disk Scheduler Number Req Outstanding for a volume
3 | Set Queue Depth for Software iSCSI initiator to 256
4 | Turn Off DelayedAck for Random Workloads !!! Only for throughput heavy workloads or latency senstive applications
5 | Create Custom SATP Rule for SolidFire


Use if you need to include only specific settings. 
Must be comma-separated or all

Examples
$apply = 2,3,5
$apply = "all"
#>

$apply = 4




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

foreach ($esx in $vmhosts){
    
    $esx | Get-AdvancedSetting -Name "DataMover.MaxHWTransferSize" | Set-AdvancedSetting -Value 16384 -Confirm:$($Confirm)    
    
    # Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Output ("MaxHWTransferSize size set to 16MB for " + $esx.name)
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

$dsnro = 64
foreach ($esx in $vmhosts)
{
    $esxcli=get-esxcli -VMHost $esx
    $devices = $esx | Get-ScsiLun | Where{$_.Vendor -match "SolidFir"}
    foreach ($device in $devices)
    {
        If($esx.Version.Split(".")[0] -ge "6"){
            #vSphere 6.x hosts or greater
            $esxcli.storage.core.device.set($null, $null, $device.CanonicalName, $null, $null, $null, $null, $null, $null, $null, $null, $dsnro, $null, $null)
        }else{
            #vSphere 5.x hosts
            $esxcli.storage.core.device.set($null, $device.CanonicalName, $null, $null, $null, $null, $null, $dsnro, $null)
        }
        
        # Output completion to screen if $verbose = $true
        if($verbose = $true){
            Write-Output ("DSNRO for " + $device.CanonicalName + " on host " + $esx.name + " set to " + $dsnro)
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

foreach ($esx in $vmhosts){
    $esxcli = get-esxcli -VMHost $esx


    If($esx.Version.Split(".")[0] -ge "6"){
        #vSphere 6.x hosts or greater
        $esxcli.system.module.parameters.set($null, $null,"iscsi_vmk","iscsivmk_LunQDepth=256")
    }else{
        #vSphere 5.x command
        $esxcli.system.module.parameters.set($null,"iscsi_vmk","iscsivmk_LunQDepth=256")
    }

    $esxcli.system.module.parameters.list("iscsi_vmk") | Where{$_.Name -eq "iscsivmk_LunQDepth"}

    # Output completion to screen if $verbose = $true
    if($verbose = $true){
            Write-Output ("Queue depth for " + $esx.Name + " set to 256")
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

foreach($esx in $vmhosts){
    $adapterID = $esx.ExtensionData.config.StorageDevice.HostBusAdapter | Where{$_.Model -match "iSCSI"}

    $esxcli.iscsi.adapter.param.set($adapterID.device, $null, "DelayedAck", "false")

    # Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Output ("DelayedAck turned off for " + $esx.name)
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

#>
foreach($esx in $vmhosts){

    $esxcli = Get-Esxcli -VMHost $esx
    $esxcli.storage.nmp.satp.rule.add($false, $null, "SolidFire custom SATP rule", $null, $null, $true, "SSD SAN", $null, "VMW_PSP_RR", "iops=10", "VMW_SATP_DEFAULT_AA", $null, $null, "SolidFir")
    
    # Output completion to screen if $verbose = $true
    if($verbose = $true){
        Write-Output ("Custom SATP rule created for " + $esx.name)
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