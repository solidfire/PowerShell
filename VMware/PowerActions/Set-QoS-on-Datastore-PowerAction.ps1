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

param
(
   [Parameter(Mandatory=$true)]
   [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore]
   $vParam,
   [Parameter(Mandatory=$true)]
   $cluster,
   [Parameter(Mandatory=$true)]
   $minIOPs,
   [Parameter(Mandatory=$true)]
   $maxIOPs,
   [Parameter(Mandatory=$true)]
   $burstIOPs

);
Import-Module SolidFire | Out-Null
$cred = Get-Credential
Connect-SFCluster -Target $cluster -Credential $cred | Out-Null
If($sfconnection -eq $null){
Write-Host "Connection to cluster failed"
break
}

$scsiID = ((Get-ScsiLun -Datastore $vParam).CanonicalName).Split(".")[1]
$volume = Get-SFVolume | Where{$_.ScsiNAADeviceID -eq $scsiID}
Set-SFVolume -VolumeID $volume.VolumeID -MinIOPS $minIOPs -MaxIOPS $maxIOPs -BurstIOPS $burstIOPs -Confirm:$false | Out-Null
Write-Host "QoS on Volume $($volume.name) was updated | $minIOPs / $maxIOPs / $burstIOPs"