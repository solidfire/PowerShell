$capabilities = Get-SpbmCapability | Where{$_.Category -eq "SolidfireVolumeQOSHints"} | Sort Name
$NewPolicyName = "VDIEncrypt"
$values = @(1000,100,50,5000,500,150,$false)
 
$range = 0..6
$rules = @()

foreach ($x in $range) {
If($x -lt $range.count -1){
    $rule = New-SpbmRule -Capability $capabilities[$x] -Value ($values[$x] -as [Int64])
    $rules += $rule
}
if($x -eq ($range.count - 1)){
    $rule = New-SpbmRule -Capability $capabilities[$x] -Value ($values[$x])
    $rules += $rule
    }
}
$rules


$ruleset = New-SpbmRuleSet -Name Capabilities -AllOfRules $rules

New-SpbmStoragePolicy -Name VDIEncrypt -Description "Policy for Encrypted VDI Disks." -AnyOfRuleSets $ruleset
#Get-SpbmStoragePolicy -Name VDIEncrypt | Set-SpbmStoragePolicy -AnyOfRuleSets $ruleset


