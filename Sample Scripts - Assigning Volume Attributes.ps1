# This script sample demonstrates how to use the Set-SFVolumeAttribute function to assign attributes to a volume.

Get-SFVolume Cluster01-2 | Set-SFVolumeAttribute -AttributeName Workload -AttributeValue Standard
Get-SFVolume Cluster01-2 | Set-SFVolumeAttribute -AttributeName Workload -AttributeValue Standard
Get-SFVolume Cluster01-3 | Set-SFVolumeAttribute -AttributeName Workload -AttributeValue MySQLDB
Get-SFVolume Cluster01-4 | Set-SFVolumeAttribute -AttributeName Workload -AttributeValue SQLDB
