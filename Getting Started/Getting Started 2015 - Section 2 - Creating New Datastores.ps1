<#
This script is part of a series of scripts that were provided for instructional purposes.
Examples in this document should not be considered complete in part or in whole and used for instructional purposes.

====================================================================
|                              Disclaimer:                         |
| This script is written as best effort and provides no warranty   |
| expressed or implied. Please contact SolidFire support if you    |
| have questions about this script before running or modifying.    |
====================================================================

#>

# Using the break in case you accidentally run the entire file
break

# Use PowerCLI for these steps.
# Get User Credentials for vCenter Server
$vcenter = "view-vcenter.vdi.sf.local"

Break
Connect-VIServer -Server $vcenter -User <username> -Password <password>

<#
##############################
Prepare Volume Access Group for dynamic Discovery
##############################
#>

# Get Volumes
$volumes = Get-SFVolume

# Get list of ESXi host software initiator IQNs
# Note: you should make sure you only collect the ESXi hosts you want to add to the Volume Access Group
$IQNs = Get-VMHost | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}


# Add IQNs to Volume Access Group
$vid = (Get-SFVolumeAccessGroup SELab01).VolumeAccessGroupID
$IQNs | %{Add-SFInitiatorToVolumeAccessGroup -VolumeAccessGroupID $vid -Initiators $_.IQN}

# Note: % is PowerShell for forEach

<#
##############################
Adding iSCSI targets
##############################
#>

# Check Target to hosts - Before
Write-Host "Showing iSCSI targets" -ForegroundColor Yellow
Get-VMHost | Get-VMhostHba -Type IScsi | Get-IScsiHbaTarget


# Collects cluster's SVIP dynamically
$SVIP = (Get-SFClusterInfo).Svip

# Add the target
Get-VMhost | Get-VMHostHba -Type IScsi | New-IScsiHbaTarget -Address $SVIP -Port 3260


<#
##############################
Part 2.4.3 - Create Datastores in VMware
##############################
#>
# Check Target to hosts
Write-Host "Showing ISCSI targets post Add" -ForegroundColor Yellow
Get-VMHost | Get-VMhostHba -Type IScsi | Get-IScsiHbaTarget

# Rescan HBAs
Get-VMhost | Get-VMhostStorage -RescanAllHba -RescanVMFs


<#
##############################
Part 2.4.4 - Create Datastores in VMware
##############################
#>

# Create Datastore with a loop that matches the datastore name to the volume name.
$vmhost = Get-VMhost | Select -First 1
foreach($volume in $volumes){
    $canonicalname = "naa." + $volume.Scsi_NAA_DeviceID
    New-Datastore -VMhost $vmhost -Name $volume.VolumeName -Path $canonicalname -Vmfs -FileSystemVersion 5
}

# Rescan HBAs
Get-VMhost | Get-VMhostStorage -RescanAllHba -RescanVMFs

<# Review the available datastores.
Click on the ESXi Host
Identify the new datastores under Resources frame
or
Click on Configuration tab
Select Storage
#>