Function New-TagFromSFWorkload{
<#
    .Synopsis
	
 	 Creates a tag based on SolidFire volume attribute.
	 
	.Description 
	 
 	 Creates a tag based on SolidFire volume attribute.
     Default attribute key is Workload
     Default Tag Category is SolidFire

	.Parameter Datastore
	
	 Represents a VMware datastore object. Datastore objects can be collected with Get-Datastore

	.Parameter Attribute
	
	 SolidFire attribute value
	 
	.Example
	
	 New-TagFromSFWorkload $volume

     Returns an object that has the QoS values split out.
	 
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
        Mandatory=$True)]
        [SolidFire.Core.Objects.SFVolume[]]
        $Volume,
        [Parameter(
        Position=1,
        Mandatory=$False,
        HelpMessage="Enter category name."
        )]
        $category = "*Solidfire*",
        [Parameter(
        Position=2,
        Mandatory=$False,
        HelpMessage="Enter the SolidFire Volume."
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

# Collect value for the attribute provided
$workload = ($volume).Attributes.$($attribute)

<#
If((Get-Tag -Name $workload)){
    Write-Output "The Tag for $workload already exists"
    Break
}
#>


$cat = Get-TagCategory $category | Select -First 1

}

# Runs one time for every object piped in
PROCESS {


If($workload -ne $null){
    
    # If a category does not exist based on the value provided a new category will be created.
    If($cat -eq $null){
        New-TagCategory -Name "SolidFire" -Description "Tags related to SolidFire Storage capabilities" -Cardinality Multiple -EntityType Datastore,DatastoreCluster
        $cat = Get-TagCategory "SolidFire"
    }

# Creates a new tag as part of the provided tag category.
New-Tag -Name $workload -Category $cat -Description "SolidFire volume with $($attribute) value of $($workload)"

}Else{
Write-Output "No value available for attribute $($workload) on volume $($volume)"
}

}
}