#Create SolidFire volumes

#Collect credentials for connecting to SolidFire
$creds = Get-Credential

#Connect to SolidFire Cluster
Connect-SFCluster 172.27.1.193 -credential $creds

#Get the account for the volumes to create
$acct = Get-SFAccount -AccountID 1

#Create 20 1TiB Volumes with QoS of 2500/25000/25000 (Min/Max/Burst) IOPS
$vols = 1..20
$vols = $vols | ForEach-Object {$_.ToString("00")}

$vols | %{New-SFVolume -AccountID 1 -Name “pvs-desktop$_” -TotalSize 1000 -GiB -Enable512e:$false -miniops 2500 -maxiops 25000 -burstiops 25000; start-sleep -s 5}

#Add volumes to volume access group
$acct | Get-SFVolume | Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID 1
