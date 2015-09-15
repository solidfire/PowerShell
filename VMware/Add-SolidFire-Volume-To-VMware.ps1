<#
A more complete script is available in the New-TenantOrCluster function.

This script file  contains elements that can be used for connecting SolidFire volumes to a VMware vSphere environment.

This is NOT an end to end script with logic, error-handling, and full capabilities.

The contents in this script serves to provide examples of cmdlets required to connect SolidFire volumes to vSphere.

- Script will connect to both VMware and SF environments.
- Creates an account
- Creates some volumes
- Gets ESXi iSCSI initiator IQNs
- Creates volume access group with initiators and volumes
- Checks for the new targets
- Creates VMware datastores based on the SF volume name
- Rescans the HBAs.
#>

#Connect to SF Cluster

Connect-SFCluster -Target clusterMVIP -UserName admin -ClearPassword pass

#Connect to vCenter

Connect-VIServer -Server vcenter -User root -Password pass

#Create an Account

New-SFAccount -UserName PoshTest

$account = Get-SFAccount PoshTest

# Create a Volume

New-SFVolume -Name TestDefaultQoS -AccountID $account.AccountID -TotalSize 200 -GB -Enable512e:$true

New-SFVolume -Name TestSetQoS -AccountID $account.AccountID -TotalSize 200 -GB -Enable512e:$true -MinIOPS 1000 -MaxIOPS 2000 -BurstIOPS 3000


# Get Volumes

$volumes = Get-SFVolume Test*

# Get list of ESXi host software initiator IQNs.  
# You can use Get-Cluster prior to Get-VMhost to reduce scope.

$IQNs = Get-VMHost | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}


# Create a Volume Access Group

New-SFVolumeAccessGroup -Name TestGroup -Initiators $IQNs.IQN -VolumeIDs $volumes.VolumeID


<#
Use this if an existing volume access group
Write-Host "Adding Volumes to Volume Access Group" -ForegroundColor Yellow
$vag = Get-SFVolumeAccessGroup -VolumeAccessGroupName ESX-16
$vag | Add-SFVolumeToVolumeAccessGroup -VolumeID $volumes.VolumeID
#>

# Check Target to hosts

Write-Host "Showing ISCSI targets" -ForegroundColor Yellow
Get-VMHost | Get-VMhostHba -Type IScsi | Get-IScsiHbaTarget

# Add Target

Write-Host "Adding iSCSI Targets" -ForegroundColor Yellow
$SVIP = (Get-SFClusterInfo).Svip
Get-VMhost | Get-VMHostHba -Type IScsi | New-IScsiHbaTarget -Address $SVIP -Port 3260

# Check Target to hosts

Write-Host "Showing ISCSI targets post Add" -ForegroundColor Yellow
Get-VMHost | Get-VMhostHba -Type IScsi | Get-IScsiHbaTarget

# Rescan HBAs

Get-VMhost | Get-VMhostStorage -RescanAllHba -RescanVMFs


# Create Datastore

$vmhost = Get-VMhost | Select -First 1
foreach($volume in $volumes){
$canonicalname = "naa." + $volume.ScsiNAADeviceID
New-Datastore -VMhost $vmhost -Name $volume.VolumeName -Path $canonicalname -Vmfs -FileSystemVersion 5
}


# Rescan HBAs

Get-VMhost | Get-VMhostStorage -RescanAllHba -RescanVMFs
