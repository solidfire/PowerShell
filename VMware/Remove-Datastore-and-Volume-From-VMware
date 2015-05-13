# Remove Datastores

$vmhost = Get-vmhost | select -first 1
$datastores = Get-Datastore Test*
$datastores | Remove-Datastore -vmhost $vmhost -Confirm:$false


# Remove SolidFire Volumes

Get-SFVolume Test* | Remove-SFVolume -Confirm:$false

# Rescan HBAs
Get-VMhost | Get-VMhostStorage -RescanAllHba -RescanVMFs

# Check Target to hosts

Write-Host "Showing ISCSI targets" -ForegroundColor Yellow
Get-VMHost | Get-VMhostHba -Type IScsi | Get-IScsiHbaTarget

# Note the deleted volumes on array

Get-SFDeletedVolume