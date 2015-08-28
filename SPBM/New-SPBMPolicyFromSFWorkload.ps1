function New-SPBMPolicyFromSFWorkload{
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