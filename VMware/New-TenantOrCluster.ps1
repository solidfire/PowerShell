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
	
     Represents a vSphere cluster where the volumes should be added.
	
	.Parameter qtyVolumes

     The number of volumes that need to be added to the cluster.

    .Parameter StartingNumber

     The first number that should be represented in the range for the new volumes.
	 
    .Parameter sizeGB

     Size of each new volume in GB.

    .Parameter Tenant

     Name of tenant to be used as account name.

	.Parameter min

     Minimum IOPs value.

    .Parameter max

     Minimum IOPs value.

    .Parameter burst
     
     Minimum IOPs value.

    .Parameter InitiatorSecret

     Custom initiator secret for the account. Must be between 12 and 16 characters in length.

    .Parameter TargetSecret

     Custom target secret for the account. Must be between 12 and 16 characters in length.
	
    .Example
	
	 New-TenantOrCluster -Cluster Cluster02 -qtyVolumes 4 -sizeGB 1024 -min 1000 -max 1200 -burst 2000

     Basic usage of the New-TenantOrCluster function to deploy 4 volumes.

    .Example

     New-TenantOrCluster -Cluster Cluster02 -Tenant DeveloperA -qtyVolumes 4 -sizeGB 1024 -min 1000 -max 1200 -burst 2000

     Creates volumes for an account based on Tenant name to specified cluster.

    .Example

     New-TenantOrCluster -Cluster Cluster01 -Tenant Engineering -InitiatorSecret sdl29sl19sdk -TargetSecret e9dlxwps8c!s -qtyVolumes 10 -StartingNumber 11 -sizeGB 2048 -min 3000 -max 4000 -burst 6000

     Creates volumes for an account based on Tenant name to specified cluster. Custom Target and Initiator secrets are provided and a starting volume number provided.
     Specifically useful when adding additional volumes to existing cluster or tenant.
	 
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
        [Int]$qtyVolumes,
        [Parameter(
        Position=2,
        Mandatory=$True,
        HelpMessage="Enter the size of volumes in GB."
        )]
        [Int]$sizeGB,
        [Parameter(Mandatory=$false)]
        [String]$Tenant,
        [Parameter(Mandatory=$false)]
        [Int]$StartingNumber=0,
        [Parameter(Mandatory=$true)]
        [Int]$min,
        [Parameter(Mandatory=$true)]
        [Int]$max,
        [Parameter(Mandatory=$true)]
        [Int]$burst,
        [Parameter(Mandatory=$false,
        ParameterSetName='CustomSecrets')]
        [ValidateLength(12,16)]
        [String]$InitiatorSecret="",
        [Parameter(Mandatory=$false,
        ParameterSetName='CustomSecrets')]
        [ValidateLength(12,16)]
        [String]$TargetSecret=""

)

# Choose tenant name for account name if specified. Otherwise use Cluster name for account.
If($tenant -ne ""){
    $accountname = $Tenant
}Else{
    $accountname = $Cluster
}

###################
# Account creation
###################

# Check if account exists. If not then the account is created.
If(!(Get-SFAccount $accountname -ErrorAction SilentlyContinue)){
# Create the account for the cluster/tenant
Write-Verbose "Creating the account $($accountname)"

    if($initiatorSecret -or $targetSecret -eq ""){
        New-SFAccount -UserName $accountname
    }Else{
        New-SFAccount -UserName $accountname -InitiatorSecret $initiatorSecret -TargetSecret $targetSecret
    }
Write-Verbose "Creating the account $($accountname) complete"
}

#################
# Create Volumes
#################

Write-Verbose "Creating the volumes"

# Create numeric range based on provided values for volume numbering.
If($StartingNumber -ne 0){
    $lastnumber = $StartingNumber + ($qtyVolumes - 1)
    $volnumbers = $StartingNumber..$lastnumber
}Else{
    $volnumbers = 1..$($qtyVolumes)
}

# Ensure that all of the volumes are numerically consistent. Places a '0' before volumes 1-9. i.e. 01-09
$volnumbers = $volnumbers | %{$_.ToString("00")}

$volnumbers | %{New-SFVolume -Name ("$accountname-$_") -AccountID (Get-SFAccount $accountname).AccountID -TotalSize $sizeGB -GB -Enable512e:$true -MinIOPS $min -MaxIOPS $max -BurstIOPS $burst}

Write-Verbose "Creating the volumes complete"

$volumes = $volnumbers | %{Get-SFVolume -Name ("$accountname-$_")}


#############################################
# Create Volume Access Group and Add volumes
#############################################

Write-Verbose "Creating the volume access group $($Cluster)"

If(!(Get-SFVolumeAccessGroup -VolumeAccessGroupName $Cluster -ErrorAction SilentlyContinue)){

    New-SFVolumeAccessGroup -Name $Cluster -VolumeIDs $volumes.VolumeID

Write-Verbose "Creating the volume access group $($Cluster) complete"

}Else{
Write-Verbose "Adding volumes to existing volume access group $($Cluster)"
    $volumes | Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID (Get-SFVolumeAccessGroup $Cluster).VolumeAccessGroupID
Write-Verbose "Adding volumes to existing volume access group $($Cluster) complete"
}

# Collects cluster's SVIP dynamically
$SVIP = (Get-SFClusterInfo).Svip

# Collect all of the ESXi hosts in the cluster that will connect to the volumes in the access group
$vmhosts = Get-Cluster $cluster | Get-VMHost

# Validate whether the ESXi host already has the SVIP as a send target on the iSCSI HBA Adapter.
foreach($vmhost in $vmhosts){
    If(!($vmhost | Get-VMHostHba -Type IScsi | Get-IScsiHbaTarget | Where{$_.Address -eq $SVIP -and $_.Type -eq "Send"})){
        Write-Verbose "Adding the SolidFire SVIP $($SVIP) as a target"
        $vmhost | Get-VMHostHba -Type IScsi | New-IScsiHbaTarget -Address $SVIP -Port 3260
        # Add iSCSI Target on each VMhost
        Write-Verbose "Adding the SolidFire SVIP $($SVIP) as a target complete"
    }Else{
    Write-Verbose "SolidFire SVIP $($SVIP) is already present"
    }
}

###################################
# Add IQNs to Volume Access Group
###################################
$vid = (Get-SFVolumeAccessGroup $Cluster).VolumeAccessGroupID
# Collect IQNs for each host iSCSI adapater
$IQNs = $vmhosts | Select name,@{n="IQN";e={$_.ExtensionData.Config.StorageDevice.HostBusAdapter.IscsiName}}


ForEach($IQN in $IQNs){
    If((Get-SFVolumeAccessGroup -VolumeAccessGroupID $vid | Select -ExpandProperty Initiators) -notcontains $IQN.IQN){
        Write-Verbose "Adding the ESXi host IQN $($IQN.IQN) to the Volume Access Group"

        $IQN | Add-SFInitiatorToVolumeAccessGroup -VolumeAccessGroupID $vid -Initiators $_.IQN
        # Note: % is PowerShell for forEach
        
        Write-Verbose "Adding the ESXi host IQNs to the Volume Access Group Complete"

    }Else{
        Write-Verbose "The IQN $($IQN.IQN) is already Present in the Volume Access Group"
    }

}


# Rescan all of the HBAs so that the storage devices can be seen.
Write-Verbose "Rescanning the HBAs to identify storage devices"

# Collect Host information from Cluster (One Host required to add storage in cluster)
$vmhost = $vmhosts | select -First 1

$vmhosts | Get-VMhostStorage -RescanAllHba


###################################
# Creating Datastores on ESXi Host
###################################


Write-Verbose "Creating the new datastores on ESXi host $($vmhost.Name)"

foreach($volume in $volumes){
    $canonicalname = "naa." + $volume.ScsiNAADeviceID
    New-Datastore -VMhost $vmhost -Name $volume.Name -Path $canonicalname -Vmfs -FileSystemVersion 5
}
Write-Verbose "Creating the new datastores on ESXi host $($vmhost.Name) Complete"


# Rescan HBAs
Write-Verbose "Rescanning the HBAs to connect all datastores"

$vmhosts | Get-VMhostStorage -RescanAllHba -RescanVMFs
Write-Verbose "Rescan Complete"
}