function New-SPBMPolicyFromDatastore{
# Dynamically create SPBM Policy from ground up.
[CmdletBinding(ConfirmImpact="Low")]
param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the Datastore.")]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $datastore,
        [Parameter(
        Position=2,
        Mandatory=$False,
        HelpMessage="Enter the SolidFire Volume attribute."
        )]
        $attribute = "Workload"

)
Begin{}
Process{
# Get Volume
Write-Verbose "Getting the SolidFire Volume" 
$volume = Get-SFVolumeFromDatastore -datastore $datastore

# Get Workload
$workload = ($volume).Attributes.$($attribute)
Write-Verbose "Collected workload $workload"

# Create Tag
Write-Verbose "Creating a new Tag from Workload" 
$volume | New-TagFromSFWorkload
Write-Verbose "Completed Tag creation for workload $workload" 


# Assign Tag to Datastore
Write-Verbose "Assigning a new Tag to Datastore" 
$datastore | Set-SFWorkloadTagToDatastore
Write-Verbose "Completed assigning new Tag to Datastore" 



# Check if Policy exists. Create if it does not.
$policyname = (Get-SFSpbmPolicyName -Volume $volume).PolicyName
Write-Verbose "Creating Storage Policy" 
$checkpolicy = Get-SPBMStoragePolicy -Name $policyname -ErrorAction SilentlyContinue
if($checkpolicy -eq $null){
    New-SPBMPolicyFromSFWorkload -Volume $volume
}
Write-Verbose "Policy created successfully" 
}
}