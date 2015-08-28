function New-SFVolumeFromSPBMPolicy{
<#
    .Synopsis
	
 	 Creates a new SolidFire volume based on 
	 
	.Description 
	 Creates a string name based on values related to a SolidFire volume.
     Pulls the QoS profile for the volume.  Substitutes 000 with a K.
     Prefixes the policy name with a workload attribute if it exists.
     Ability to choose different attribute name lookup

     Returns the Volume name and resulting policy name.
	 
	.Parameter Volume
	
	 Represents a SolidFire volume object as returned by Get-SFVolume
	
	.Parameter Attribute
	 
	 Allows user to specify the attribute name they would like to use if different than default.
     Default attribute name is "Workload"
     The attribute value is pulled from the volume attribute and used as a prefix for the policy name.
     If volume attribute is: Workload = Oracle
     Policy name will be: Oracle-Min-Max-Burst
	 
	.Example
	
	 Get-SFVolume Volume1 | Get-SFSpbmPolicyName

     Returns the derived policy name for SolidFire volume Volume1

	.Example
	 
	 Get-SFVolume | Get-SFSpbmPolicyName

     Returns the derivied policy name for all SolidFire volumes returned.
    .Example

     Get-SFVolume Volume1 | Get-SFSpbmPolicyName -Attribute Application

     Returns the derived policy name for the SolidFire volume Volume1 with the value for Application as prefix
     <Application>-Min-Max-Burst
     Oracle-1K-3K-5K

	 
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
        HelpMessage="Enter the VMware Storage Policy.")]
        [VimAutomation.Storage.Impl.V1.Spbm.SpbmStoragePolicyImpl[]]
        $Policy,
        [Parameter(
        ValueFromPipeline=$false,
        Position=1,
        Mandatory=$True)]
        [String]
        $VolumeName,
        [Parameter(
        ValueFromPipeline=$True,
        Position=1,
        Mandatory=$True)]
        [String]
        $AccountName
)


$specs = $policy | Get-SFVolumeQosFromSpbmPolicy
$capacity = [Math]::Round((($policy | Get-SpbmCompatibleStorage | Select -First 1).CapacityGB)*1.07374)
$attribute = @{"Workload" = $specs.Workload}

New-SFVolume -Name Oracle2 -Account (Get-SFAccount $AccountName) -Enable512e:$true -TotalSize $capacity -GB -MinIOPS $specs.Min -MaxIOPS $specs.Max -BurstIOPS $specs.Burst -Attributes $attribute
}
