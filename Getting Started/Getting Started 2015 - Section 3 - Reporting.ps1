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


<#
##############################
Part 3.1.1 - List Accounts
##############################
#>

# Return a single SolidFire account.
Get-SFAccount | Select -First 1

# Return all SolidFire accounts and only display three properties.
Get-SFAccount | Select UserName, TargetSecret, InitiatorSecret

<#
##############################
Part 3.1.2 - List Volumes
##############################
#>

Get-SFVolume | Select -First 1
Get-SFVolume | Select VolumeID, Name, IQN, ScsiNAADeviceID, ScsiEUIDeviceID


<#
##############################
Part 3.1.3 - List Volume Access Groups
##############################
#>

# Returns all Volume Access Groups
Get-SFVolumeAccessGroup

# Returns name of all volumes that are part of a Volume Access Group
Get-SFVolumeAccessGroup | select -ExpandProperty VolumeID | Get-SFVolume | Select VolumeName

<#
##############################
Part 3.2 - Identify IQNs
##############################
#>

# Volume IQNs
Get-SFVolume | Select VolumeID, VolumeName, VolumeIQN, Scsi_NAA_DeviceID, Scsi_EUI_DeviceID

# ESXi Hosts
Get-VMHost | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}



<#
##############################
Part 3.3 - More Content - ESXi Host to VAG mapping
##############################
#>

# Take your browser to:
# https://github.com/solidfire/PowerShell/tree/master/VMware



<#
##############################
Part 4 - More Content - Interesting commands not directly related to VMware
##############################
#>
# Cluster configuration, capacity 
Get-SFConfig
Get-SFClusterCapacity
# Volume efficiency, latency
Get-SFVolumeEfficiency
Get-SFVolumeStats | select VolumeID, AccountID, LatencyUSec | Sort-Object -descending -property LatencyUSec | Select-Object -first 5

