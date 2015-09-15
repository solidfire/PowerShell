# Remove Datastores

$vmhost = Get-vmhost | select -first 1
$datastores = Get-Datastore Test*
$datastores | Remove-Datastore -vmhost $vmhost -Confirm:$false

# Included break so there are less chances for accidents :-)
break

# Remove SolidFire Volumes

Get-SFVolume Test* | Remove-SFVolume -Confirm:$false

# Rescan HBAs
Get-VMhost | Get-VMhostStorage -RescanAllHba -RescanVMFs

# Check Target to hosts

Write-Host "Showing ISCSI targets" -ForegroundColor Yellow
Get-VMHost | Get-VMhostHba -Type IScsi | Get-IScsiHbaTarget

# Note the deleted volumes on array

Get-SFDeletedVolume

# This is a break in case you removed the other break, made a mistake, and want to restore the deleted volumes still.
break

# Remove the deleted volumes
Get-SFDeletedVolume | Remove-SFDeletedVolume -Confirm:$false