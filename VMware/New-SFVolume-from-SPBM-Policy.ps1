<#
This script sample allows an administrator to create a new volume using the same QoS and Attribute
settings as identified in a VMware SPBM Storage Policy.

#>
$policy = Get-SpbmStoragePolicy "Standard-1K-2K-5K-STD"

$specs = $policy | Get-SFVolumeQosFromSpbmPolicy
$capacity = [Math]::Round((($policy | Get-SpbmCompatibleStorage | Select -First 1).CapacityGB)*1.07374)
$attribute = @{"Workload" = $specs.Workload}

New-SFVolume -Name Oracle2 -AccountID 1 -Enable512e:$true -TotalSize $capacity -GB -MinIOPS $specs.Min -MaxIOPS $specs.Max -BurstIOPS $specs.Burst -Attributes $attribute
