<#
.Set QoS on Datastore

.NOTES  Author: Josh Atwell @josh_atwell

.Label
Sets QoS on the SolidFire Volume related to the selected datastore.

.Description
Sets QoS on the SolidFire Volume related to the selected datastore. 

====================================================================
Disclaimer: This script is written as best effort and provides no 
warranty expressed or implied. Please contact the author(s) if you 
have questions about this script before running or modifying
====================================================================
#>

param(
[Parameter(Mandatory=$true)]
[VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl]
$datastore,
[Parameter(Mandatory=$true)]
$minIops,
[Parameter(Mandatory=$true)]
$maxIops,
[Parameter(Mandatory=$true)]
$burstIops
);
Import-Module SolidFire | Out-Null
Connect-SFCluster -Target "xnode-api-dev1.pm.solidfire.net" -UserName admin -ClearPassword solidfire | Out-Null

$scsiID = ((Get-ScsiLun -Datastore $datastore).CanonicalName).Split(".")[1]
$volume = Get-SFVolume | Where{$_.Scsi_NAA_DeviceID -eq $scsiID}
Set-SFVolume -VolumeID $volume.VolumeID -MinIOPS $minIops -MaxIOPS $maxIops -BurstIOPS $burstIops -Confirm:$false
