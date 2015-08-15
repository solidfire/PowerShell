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
    $result = Get-SFVolume | Where{$_.Scsi_NAA_DeviceID -eq $scsiID}
    Return $result
}

}