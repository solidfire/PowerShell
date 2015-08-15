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
        [SolidFire.Core.Objects.SFVolumeInfo[]]
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
        $AttributeValue

)
Begin{
$attribute = @{"$($AttributeName)" = "$($AttributeValue)"}

}
# Set Attributes

Process{
$volume | %{Set-SFVolume -VolumeID $_.VolumeID -Attributes $attribute -Confirm:$False}
}

}