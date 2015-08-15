Function Set-SFWorkloadTagToDatastore{
<#
    .Synopsis
	
 	 Assigns a datastore to a tag based on an attribute value.
	 
	.Description 
	 Assigns a datastore to a tag based on an attribute value.
     If a tag doesn't exist for the workload then a new tag is created and assigned.

	 
	.Parameter Datastore
	
	 Represents a VMware datastore object. Datastore objects can be collected with Get-Datastore

	.Parameter Attribute
	
	 SolidFire attribute value
	 
	.Example
	
	 Get-Datastore | Set-SFWorkloadTagToDatastore

     Assigns tag to datastores based on defined attribute.
	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
	
	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
#>
[CmdletBinding(ConfirmImpact="Low")]
param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the Datastore.")]
        #[VMware.VimAutomation.ViCore.Impl.V1.DatastoreManagement.VmfsDatastoreImpl[]]
        $datastore,
        [Parameter(
        Position=2,
        Mandatory=$False,
        HelpMessage="Enter the SolidFire Volume attribute."
        )]
        $attribute = "Workload"

)

# Runs Once
BEGIN {
# Validate that there is an active connection to a vCenter server
If(!($defaultviserver)){
    Write-Output "No vCenter Server is available with this session"
    Break
    }
}

# Runs one time for every object piped in
PROCESS {

# Identify the workload name.
$volume = Get-SFVolumeFromDatastore $datastore
$workload = $volume.Attributes.$($attribute)

# Get the tag associated with that name.  Creates a new tag for the workload if the tag doesn't exist.
If(!($tag = Get-Tag -Name $workload -ErrorAction SilentlyContinue)){
    New-TagfromSFWorkload -Volume $volume
    $tag = Get-Tag -Name $workload
    }

# Assign the tag to that datastore.
New-TagAssignment -Tag $tag -Entity $datastore

}
}