<#
.Set Attribute on SolidFire Volume

.NOTES  Author: Josh Atwell @josh_atwell

.Label
Sets volume attributes on the SolidFire volume that supports the selected datastore(s).

.Description
Sets volume attributes on the SolidFire volume that supports the selected datastore(s).
This can be leveraged to assist in dynamic SPBM policy creation and management.

====================================================================
Disclaimer: This script is written as best effort and provides no 
warranty expressed or implied. Please contact the author(s) if you 
have questions about this script before running or modifying
====================================================================
#>

param
(
   [Parameter(Mandatory=$true)]
   [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
   $vParam,
   [Parameter(Mandatory=$true)]
   $Cluster,
   [Parameter(Mandatory=$true)]
   $AttributeName,
   [Parameter(Mandatory=$true)]
   $AttributeValue
);
Import-Module SolidFire | Out-Null
Import-Module "C:\Program Files\WindowsPowerShell\Modules\SolidFire\SolidFire-SPBM.psm1" | Out-Null

$sfcred = Get-Credential

Connect-SFCluster -Target $cluster -Credential $sfcred | Out-Null

foreach($datastore in $vParam){

$scsiID = ((Get-ScsiLun -Datastore $datastore).CanonicalName).Split(".")[1]
$volume = Get-SFVolume | Where{$_.ScsiNAADeviceID -eq $scsiID}
$volume | Set-SFVolumeAttribute -AttributeName $AttributeName -AttributeValue $AttributeValue | Out-Null

Write-Host "$($datastore.name) updated with $AttributeName value set to $AttributeValue"

}