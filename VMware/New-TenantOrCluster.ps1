function New-TenantOrCluster{
<#
    .Synopsis
	
 	 Creates all components necessary to populate SolidFire storage on a new cluster.
	 
	.Description 
 	 Creates all components necessary to populate SolidFire storage on a new cluster.  Not all conditions are managed in this script.
     Modifications may need to be made in your environment based on your vSphere configurations.

     Creates Account
     Creates Volumes
     Creates VolumeAccess Groups
     Collects ESXi host IQNs.
     Adds IQNs and Volumes to VolumeAccessGroup
     Creates iSCSI Targets on ESXi host iSCSI HBA
     Rescans HBA
     Creates Datastores based on Volume name in the vSphere Cluster
	 
	.Parameter Cluster
	
     Represents a vSphere cluster.
	
	.Parameter qtyVolumes

     The number of volumes that need to be added to the cluster.
	 
    .Parameter sizeGB

     Size of each new volume in GB

	.Parameter min

     Minimum IOPs value

    .Parameter max

     Minimum IOPs value

    .Parameter burst
     
     Minimum IOPs value
	
    .Example
	
	 New-TenantOrCluster -Cluster Cluster02 -qtyVolumes 4 -sizeGB 1024 -min 1000 -max 1200 -burst 2000
	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
	
	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
#>

param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$true)]
        $Cluster,
        [Parameter(
        Position=1,
        Mandatory=$true,
        HelpMessage="Enter quantity of Volumes."
        )]
        $qtyVolumes,
        [Parameter(
        Position=2,
        Mandatory=$True,
        HelpMessage="Enter the size of volumes in GB."
        )]
        $sizeGB,
        [Parameter(Mandatory=$true)]
        $min,
        [Parameter(Mandatory=$true)]
        $max,
        [Parameter(Mandatory=$true)]
        $burst

)


# Optional - 12-16 Characters
$initiatorSecret = ""
$targetSecret = ""

$accountname = $Cluster


# Create the account for the cluster/tenant
Write-Verbose "Creating the account $($accountname)"


if($initiatorSecret -or $targetSecret -eq ""){
    New-SFAccount -UserName $accountname
}Else{
    New-SFAccount -UserName $accountname -InitiatorSecret $initiatorSecret -TargetSecret $targetSecret
}
Write-Verbose "Creating the account $($accountname) complete"


# Create Volumes
Write-Verbose "Creating the volumes"

1..$($qtyVolumes) | %{New-SFVolume -Name ("$accountname-$_") -AccountID (Get-SFAccount $accountname).AccountID -TotalSize $sizeGB -GB -Enable512e:$true -MinIOPS $min -MaxIOPS $max -BurstIOPS $burst}
Write-Verbose "Creating the volumes complete"

$volumes = Get-SFVolume "$accountname-*"



# Gather Volumes
# Create Volume Access Group and Add volumes
Write-Verbose "Creating the volume access group $($accountname)"

New-SFVolumeAccessGroup -Name $accountname -VolumeIDs $volumes.VolumeID

Write-Verbose "Creating the volume access group $($accountname) complete"


# Collects cluster's SVIP dynamically
$SVIP = (Get-SFClusterInfo).Svip

# Collect all of the ESXi hosts in the cluster that will connect to the volumes in the access group
$vmhosts = Get-Cluster $cluster | Get-VMHost

# Add iSCSI Target on each VMhost
Write-Verbose "Adding the SolidFire SVIP $($SVIP) as a target"

$vmhosts | Get-VMHostHba -Type IScsi | New-IScsiHbaTarget -Address $SVIP -Port 3260

Write-Verbose "Adding the SolidFire SVIP $($SVIP) as a target complete"


# Collect IQNs for each host iSCSI adapater
$IQNs = $vmhosts | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}

# Add IQNs to Volume Access Group
Write-Verbose "Adding the ESXi host IQNs to the Volume Access Group"

$vid = (Get-SFVolumeAccessGroup $accountname).VolumeAccessGroupID
$IQNs | %{Add-SFInitiatorToVolumeAccessGroup -VolumeAccessGroupID $vid -Initiators $_.IQN}
# Note: % is PowerShell for forEach

Write-Verbose "Adding the ESXi host IQNs to the Volume Access Group Complete"


# Rescan all of the HBAs so that the storage devices can be seen.
Write-Verbose "Rescanning the HBAs to identify storage devices"

$vmhosts | Get-VMhostStorage -RescanAllHba

# Collect Host information from Cluster (One Host required to add storage in cluster)
$vmhost = $vmhosts | select -First 1

Write-Verbose "Creating the new datastores on ESXi host $($vmhost.Name)"

foreach($volume in $volumes){
    $canonicalname = "naa." + $volume.Scsi_NAA_DeviceID
    New-Datastore -VMhost $vmhost -Name $volume.VolumeName -Path $canonicalname -Vmfs -FileSystemVersion 5
}
Write-Verbose "Creating the new datastores on ESXi host $($vmhost.Name) Complete"

# Rescan HBAs
Write-Verbose "Rescanning the HBAs to connect all datastores"

$vmhosts | Get-VMhostStorage -RescanAllHba -RescanVMFs
Write-Verbose "Rescan Complete"


}