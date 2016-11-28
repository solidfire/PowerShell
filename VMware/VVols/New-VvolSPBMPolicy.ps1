$capabilities = Get-SpbmCapability | Where{$_.Category -eq "SolidfireVolumeQOSHints"} | Where {$_.ValueType.ToString() -eq "System.Int64"}

$values = @(1000,100,50,5000,500,150,"VDI")
 
$range = 0..6
$rules = @()



foreach ($x in $range) {
If($x -lt $range.count -1){
    $rule = New-SpbmRule -Capability $capabilities[$x] -Value ($values[$x] -as [Int64])
    $rules += $rule
}
if($x -eq ($range.count - 1)){
    $tagrule = New-SpbmRule -AnyOfTags (Get-Tag $values[$x])
    }
}
$rules


$ruleset = New-SpbmRuleSet -Name Capabilities -AllOfRules $rules
$tagruleset = New-SpbmRuleSet -Name Capabilities -AllOfRules $tagrule

New-SpbmStoragePolicy -Name VDIDefault -Description "Policy for default VDI Disks." -AnyOfRuleSets $ruleset, $tagruleset