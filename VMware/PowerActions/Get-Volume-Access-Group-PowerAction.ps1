<#
.Get_Volume_Access_Group

.NOTES  Author: Josh Atwell @josh_atwell

.Label
Identifies the SolidFire Volume Access Group the ESXi host is connected.

.Description
Identifies the SolidFire Volume Access Group the ESXi host is connected. 

#>

param
(
   [Parameter(Mandatory=$true)]
   [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
   $vhosts,
   [Parameter(Mandatory=$true)]
   $sfcluster
);

If(!(Get-Module SolidFire)){
Import-Module SolidFire | Out-Null
}
$cred = Get-Credential
Connect-SFCluster -Target $sfcluster -Credential $cred | Out-Null
foreach($vhost in $vhosts){
$IQNs = $vhost | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}

$output = @()
foreach($vmhost in $IQNs){
	foreach($iqn in $vmhost.IQN){ 
        $vag = Get-SFVolumeAccessGroup | Where{$_.Initiators -match $iqn}
	 
	     $a = New-Object System.Object
	     $a | Add-Member -Type NoteProperty -Name VMhost -Value $vmhost.Name
       If($vag -eq $null){
	     $a | Add-Member -Type NoteProperty -Name VolumeAccessGroup -Value "Unassociated"
	     }Else{
       $a | Add-Member -Type NoteProperty -Name VolumeAccessGroup -Value $vag.VolumeAccessGroupName
       }
       $a | Add-Member -Type NoteProperty -Name IQN -Value $vmhost.IQN

$output += $a
Write-Host "ESXi Host      | Volume Access Group |   Host IQN"
Write-Host "$($a.VMHost)  |  $($a.VolumeAccessGroup)  |  $($a.IQN)"
}
}
}