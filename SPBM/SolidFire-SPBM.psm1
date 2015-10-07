Function Get-SFSpbmPolicyName{
<#
    .Synopsis
	
 	 Creates a string based on values related to a SolidFire volume that can be used to generate 
     VMware Storage Policy Based Management policies. 
	 
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


# Runs Once
BEGIN {
$result = @()
}

# Runs one time for every object piped in
PROCESS {
$qos = $Volume | Select -ExpandProperty QoS
$attribute = $Volume | Select -ExpandProperty Attributes

$min = Replace-TrailingZeroesWithK -name $qos.MinIOPS
$max = Replace-TrailingZeroesWithK -name $qos.MaxIOPS
$burst = Replace-TrailingZeroesWithK -name $qos.BurstIOPS


#$min = ($qos.MinIOPS.ToString()).Replace("000","K")
#$max = ($qos.MaxIOPS.ToString()).Replace("000","K")
#$burst = ($qos.BurstIOPS.ToString()).Replace("000","K")

if($attribute.$($attributename)){
$policy = "$($attribute.Workload)-$min-$max-$burst"
}else{
$policy = "$min-$max-$burst"
}
$row = "" | Select Name,PolicyName
$row.Name = $Volume.Name
$row.PolicyName = $policy

$result += $row
}

# Runs once
END {
$result
}

}
function Replace-TrailingZeroesWithK{

param(
		[Parameter(
        Mandatory=$True)]
        $name
)

If($name.ToString().EndsWith("000")){
$front = $name.ToString().SubString(0,$name.ToString().Length-3)
$end = ($name.ToString()).Substring($name.ToString().Length-3)

$replace = $front + ($end).Replace("000","K")
}Else{
$replace = $name.ToString()
}
Return $replace
}
Function Get-SFVolumeFromDatastore{
<#
    .Synopsis
	
 	 Gets the SolidFire volume associated with a vSphere Datastore
	 
	.Description 
	 
     Gets the SolidFire volume associated with a vSphere Datastore.
     Requires active connections to vCenter with PowerCLI and connection to SolidFire cluster.
	 
	.Parameter Datastore
	
	 Represents a VMware datastore object. Datastore objects can be collected with Get-Datastore
	 
	.Example
	
	 Get-Datastore "Oracle01" | Get-SFVolumeFromDatastore

     Returns the SolidFire volume associated with vSphere datastore "Oracle01"ds.
	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
	
	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
#>
[CmdletBinding()]
param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the Datastore.")]
        [VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.Datastore[]]
        $datastore

)

Process{
    $scsiID = ((Get-ScsiLun -Datastore $datastore).CanonicalName).Split(".")[1]
    $result = Get-SFVolume | Where{$_.ScsiNAAdeviceID -eq $scsiID}
    Return $result
}

}
Function Get-SFVolumeQoSfromSPBMPolicy{
<#
    .Synopsis
	
 	 Creates a QoS profile based on values related to a SPBM policy name.
	 
	.Description 
	 Creates a QoS profile based on values related to a SPBM policy name.
     Splits name at '-' and pulls values when the policy name is formatted
     <Attribute>-Min-Max-Burst | Oracle-500-3K-5K

     Returns an object containing the QoS values and Attributes
	 
	.Parameter Policy
	
	 Represents a VMware SPBM policy object.
	 
	.Example
	
	 Get-SpbmStoragePolicy "Oracle-5K-10K-15K" | Get-SFVolumeQoSfromSPBMPolicy

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
        Mandatory=$True,
        HelpMessage="Enter the VMware Storage Policy name.")]
        #[VimAutomation.Storage.Impl.V1.Spbm.SpbmStoragePolicyImpl[]]
        $Policy
)

# Runs Once
BEGIN {
$result = @()
}

# Runs one time for every object piped in
PROCESS {

$row = "" | Select Workload,Min,Max,Burst
$row.Workload = ($policy.Name.Split("-")[0])
$row.Min = ($policy.Name.Split("-")[1]).Replace("K","000")
$row.Max = ($policy.Name.Split("-")[2]).Replace("K","000")
$row.Burst = ($policy.Name.Split("-")[3]).Replace("K","000")

$result += $row
}

# Runs once
END {
$result
}

}
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
        $category = "*SolidFire*",
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

}

# Runs one time for every object piped in
PROCESS {

# Collect value for the attribute provided
$workload = ($volume).Attributes.$($attribute)
$tagexists = Get-Tag -Name $workload -ErrorAction SilentlyContinue

If($tagexists -ne $null){
    Write-Output "The Tag for $workload already exists"
    Break
}



$cat = Get-TagCategory $category -ErrorAction SilentlyContinue | Select -First 1

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
function Set-SFVolumeAttribute{
<#
    .Synopsis
	
 	 Easily sets attributes on SolidFire Volume.
	 
	.Description 
 	 
     Sets attribute on SolidFire Volume.
     This function supplements and uses the SolidFire Tools for PowerShell
     Primary value of this function is to quickly modify and add attributes.
     This is helpful since the default behavior of the api call overwrites

	.Parameter Volume
	

	.Parameter AttributeName

     Name for the Attribute.

    .Parameter AttributeValue
	
     Value for the attribute.
	 
	.Example
	
	 Get-SFVolume | Set-SFVolumeAttribute -AttributeName Workload -AttributeValue SQLDB
	 
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
        HelpMessage="Enter the SolidFire Volume.")]
        [SolidFire.Core.Objects.SFVolume[]]
        $Volume,
        [Parameter(
        Position=1,
        Mandatory=$False,
        HelpMessage="Enter the SolidFire Volume attribute name."
        )]
        $AttributeName = "Workload",
        [Parameter(
        Position=2,
        Mandatory=$True,
        HelpMessage="Enter the SolidFire Volume attribute value."
        )]
        [String]
        $AttributeValue

)

# Set Attributes

Process{
$attributes = $volume | Select -ExpandProperty Attributes

If($attributes.ContainsKey($AttributeName)){
$attributes.Set_Item($AttributeName,$AttributeValue)

}ElseIf(!($attributes.ContainsKey($AttributeName))){

$attributes.Add($AttributeName,$AttributeValue)
}

$Volume | Set-SFVolume -Attributes $attributes -Confirm:$False

}

}
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
