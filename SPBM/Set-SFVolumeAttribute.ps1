function Set-SFVolumeAttribute{
<#
    .Synopsis
	
 	 Sets attribute on SolidFire Volume.
	 
	.Description 
 	 
     Sets attribute on SolidFire Volume.
     WARNING: It overrights all attributes in current version.

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