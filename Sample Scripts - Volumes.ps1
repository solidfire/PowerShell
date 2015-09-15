# Display Volume Name and Volume size in GB
Get-SFVolume | Select Name, @{N='TotalSizeGB';E={[math]::Round($_.TotalSize/1GB*(1/0.9313),1) }}

# Display Volume Name and QoS information
Get-SFVolume | Select Name, @{N='MinIOPS';E={$_.QoS.MinIOPS}}, @{N='MaxIOPS';E={$_.QoS.MaxIOPS}}, @{N='BurstIOPS';E={$_.QoS.BurstIOPS}}

# Display the Name, IQN, SCSI NAA
Get-SFVolume | Select Name, IQN, ScsiNAADeviceID

# Display Volumes for an Account or list of accounts or accountIDs
$accounts = "Josh","Aaron"
$accounts | Get-SFAccount | Get-SFVolume
# or
$accountids = 5,6,7
Get-SFVolume -AccountID $accountids


# Display the VolumeAccessGroups each volume is assigned
$result = @()
$volumes = Get-SFVolume
foreach($vol in $volumes){
    $volaccessgroups = $vol.VolumeAccessGroups
    foreach($vagID in $volaccessgroups){
        $vag = Get-SFVolumeAccessGroup $vagID
        # Store Volume Access Group data in object
        $object = New-Object -TypeName PSObject -Property @{
              Name = $vol.Name
              VolumeAccessGroupName = $vag.VolumeAccessGroupName
        }
        $result += $object
    }
 }
 $result | Sort Name

# Set Attribute
# !!!! Note !!! Doing it this way will OVERWRITE your attributes for the volume.
# We recommend using the Set-SFVolumeAttribute function in the SPBM module for modifying volume attributes.

$attribute = @{"Workload" = "Standard"}
Get-SFVolume Dev* | Set-SFVolume -Attributes $attribute


 
 