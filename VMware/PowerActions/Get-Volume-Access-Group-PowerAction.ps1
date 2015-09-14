<#
.Get_Volume_Access_Group

.NOTES  Author: Josh Atwell @josh_atwell

.Label
Identifies the SolidFire Volume Access Group the ESXi host is connected.

.Description
Identifies the SolidFire Volume Access Group the ESXi host is connected. 

#>

param(
[Parameter(Mandatory=$true)]
[VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost]
$vhost,
[Parameter(Mandatory=$true)]
$sfcluster
);

If(!(Get-Module SolidFire)){
Import-Module SolidFire
}

$sfcluster = 'xnode-api-dev1.pm.solidfire.net'
Connect-SFCluster -Target $sfcluster -UserName admin -ClearPassword solidfire
$vhost = Get-VMHost | select -First 1

$IQNs = Get-VMHost | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}

$result = @()
foreach($vmhost in $IQNs){
	foreach($iqn in $vmhost.IQN){ 
        $vag = Get-SFVolumeAccessGroup | Where{$_.Initiators -match $iqn}
	 
	     $a = New-Object System.Object
	     $a | Add-Member -Type NoteProperty -Name VMhost -Value $vmhost.Name
	     $a | Add-Member -Type NoteProperty -Name VolumeAccessGroup -Value $vag.VolumeAccessGroupName
	     $a | Add-Member -Type NoteProperty -Name IQN -Value $vmhost.IQN

$result += $a
}
}
Write-Host $result
