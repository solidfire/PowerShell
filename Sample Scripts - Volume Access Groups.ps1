# Display VolumeIDs in Volume Access Groups

Get-SFVolumeAccessGroup | Select VolumeAccessGroupName, VolumeID


# Display Volume Names in Volume Access Groups

$result = @()
$vags = Get-SFVolumeAccessGroup
 foreach($vag in $vags){
    $volumeIDs = $vag.VolumeID
    foreach($volID in $volumeIDs){
        $object = New-Object -TypeName PSObject -Property @{
              Name = $vag.VolumeAccessGroupName
              VolumeName = (Get-SFVolume $volID).VolumeName
        }
        $result += $object
    }
 }
 $result | Sort VolumeAccessGroupName


# Display InitiatorIQNs for each VolumeAccessGroup
 $result = @()
 $vags = Get-SFVolumeAccessGroup
 foreach($vag in $vags){
    $initiators = $vag.Initiators
    foreach($init in $initiators){
        $object = New-Object -TypeName PSObject -Property @{
              Name = $vag.VolumeAccessGroupName
              Initiator = $init
        }
        $result += $object
    }
 }
 $result | Sort VolumeAccessGroupName