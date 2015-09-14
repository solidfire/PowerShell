function New-SPBMPolicyFromSFWorkload{
<#
    .Synopsis
	
 	 Creates a policy based on a SolidFire volume QOS profile and attributes..
	 
	.Description 
	 
 	 Creates a policy based on a SolidFire volume QOS profile and attributes..


	.Parameter Volume
	
	 Represents a SolidFire volume object.

	.Parameter AttributeName
	
	 SolidFire attribute name.  This key allows lookup of appropriate values used in policy creation.
	 
	.Example
	
	 Get-SFVolume Cluster01-1 | New-SPBMPolicyFromSFWorkload -AttributeName Workload
	 
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
        Mandatory=$True,
        HelpMessage="Enter the SolidFire volume")]
		[SolidFire.Core.Objects.SFVolume[]]
        $Volume,
        [Parameter(
        ValueFromPipeline=$false,
        Position=1,
        Mandatory=$false,
        HelpMessage="Enter the attribute name if different from Workload")]
        [String]
        $AttributeName = "Workload"
)



$name = (Get-SFSpbmPolicyName -Volume $volume).PolicyName
$workload = $volume.Attributes.$AttributeName

#if(!(Get-SPBMStoragePolicy $name)){
    $rules = New-SpbmRuleSet -Name "$($name)" -AllOfRules (New-SpbmRule -AnyOfTags (Get-Tag $workload))

    New-SpbmStoragePolicy -Name $name -AnyOfRuleSets $rules -Description "Storage policy for $workload workloads"
#}


}