# Display Volume Name and Volume size in GB
Get-SFVolume | Select VolumeName, @{N='TotalSizeGB';E={[math]::Round($_.TotalSize/1GB*(1/0.9313),1) }}

# Display Volume Name and QoS information
Get-SFVolume | Select VolumeName, @{N='MinIOPS';E={$_.QoS.MinIOPS}}, @{N='MaxIOPS';E={$_.QoS.MaxIOPS}}, @{N='BurstIOPS';E={$_.QoS.BurstIOPS}}

# Display the VolumeName, VolumeIQN, SCSI NAA
Get-SFVolume | Select VolumeName, VolumeIQN, Scsi_NAA_DeviceID

# Display Volumes from a Range
$range | %{Get-SFVolume -StartVolumeID $_ -Limit 1}

# Display Volumes for an Account or list of accounts or accountIDs
$accounts = "Josh","Aaron"
$accounts | Get-SFAccountByName | Get-SFVolumesForAccount
# or
$accountids = 5,6,7
$accountids | Get-SFVolumesForAccounts


# Display the VolumeAccessGroups each volume is assigned
$result = @()
$volumes = Get-SFVolume
foreach($vol in $volumes){
    $volaccessgroups = $vol.VolumeAccessGroupIDs
    foreach($vagID in $volaccessgroups){
        $vag = Get-SFVolumeAccessGroup $vagID
        # Store Volume Access Group data in object
        $object = New-Object -TypeName PSObject -Property @{
              VolumeName = $vol.VolumeName
              VolumeAccessGroupName = $vag.VolumeAccessGroupName
        }
        $result += $object
    }
 }
 $result | Sort VolumeName

 
 