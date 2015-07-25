# Display Volume Names in Volume Access Group

Get-SFVolumeAccessGroup -VolumeAccessGroupName 'name' | Get-SFVolume


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


# Add volume(s) to Volume Access Group
Get-SFVolume "vol1","vol2" | Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID 1

