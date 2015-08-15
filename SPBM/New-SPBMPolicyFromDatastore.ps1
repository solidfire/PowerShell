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
Write-Host "Getting the SolidFire Volume" -ForegroundColor Yellow
$volume = Get-SFVolumeFromDatastore -datastore $datastore

# Get Workload
$workload = ($volume).Attributes.$($attribute)
Write-Host "Collected workload $workload"

# Create Tag
Write-Host "Creating a new Tag from Workload" -ForegroundColor Yellow
$volume | New-TagFromSFWorkload
Write-Host "Completed Tag creation for workload $workload" -ForegroundColor Green


# Assign Tag to Datastore
Write-Host "Assigning a new Tag to Datastore" -ForegroundColor Yellow
$datastore | Set-SFWorkloadTagToDatastore
Write-Host "Completed assigning new Tag to Datastore" -ForegroundColor Green



# Check if Policy exists. Create if it does not.
$policyname = (Get-SFSpbmPolicyName -Volume $volume)
Write-Host "Creating Storage Policy" -ForegroundColor Yellow

if(!(Get-SPBMStoragePolicy -Name $policyname -ErrorAction SilentlyContinue)){
    New-SPBMPolicyFromSFWorkload -Volume $volume
}
Write-Host "Policy created successfully" -ForegroundColor Green
}
}