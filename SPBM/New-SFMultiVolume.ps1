function New-SFMultiVolume{
<#
    .Synopsis
    
     Create multiple SolidFire Volumes with same account, name prefix, and size.
     
    .Description 
     
     Create multiple SolidFire Volumes with same account, name prefix, and size.
     This function supplements and uses the SolidFire Tools for PowerShell
     Primary value of this function is to create multiple, similar volumes.
    
    .Parameter VolumeCount

     The number of volumes to be created. Required. Must be greater than 1.
    
    .Parameter NamePrefix

     The string to prepend to the Volume name. Defaults to "MultiVolume"

    .Parameter AccountID
    
     The ID of the Account these Volumes should be created under. Required.
     
    .Parameter SizeInGB

     The size of the Volumes to be created in GB. Required.

    .Example
    
     Get-SFAccount | New-SFMultiVolume -VolumeCount 100 -NamePrefix "OneHundred" -SizeInGB 10
     Creates 100 10GB Volumes with names prefixed by "OneHundred" (eg: OneHundred-45813576) for each Account on the cluster
     
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
         Position=0,
         Mandatory=$True,
         HelpMessage="Enter the number of Volumes to create. Int between 2 and 1000.")]
         [ValidateRange(2,1000)]
        [int]
        $VolumeCount,
        
        [Parameter(
         Position=1,
         Mandatory=$False,
         HelpMessage="Enter the prefix for Volume names.")]
        [string]
        $NamePrefix = "MultiVolume",
        
        [Parameter(
         ValueFromPipeline = $True, 
         Position=2,
         Mandatory=$True,
         HelpMessage="Enter the AccountID under which to create these Volumes.")]
        [long]
        $AccountID,

        [Parameter( 
         Position=3,
         Mandatory=$True,
         HelpMessage="Enter the Volume size in GB.")]
        [int]
        $SizeInGB
    
)
    #Create an ArrayList to hold the newly created Volumes.
    $CreatedVolumes = New-Object System.Collections.ArrayList($null)

    #Counter used to compare to the $VolumeCount argument
    $VolumeTally = 0
    Do {
        #Generates a random hash to append to the NamePrefix for unique Volume names
        $Random = Get-Random
        #Creates a new Volume
        $NewVolume = New-SFVolume -Name "$NamePrefix-$Random" -AccountID $AccountID -Enable512e:$true -TotalSize $SizeInGB -GB
        $NewVolumeName = $NewVolume.Name
        Write-Verbose "Solidfire volume $NewVolume.Name has been created"
        #Add the new Volume to the CreatedVolumes list.
        $CreatedVolumes.Add($NewVolume)
        #Increments $VolumeTally by 1
        $VolumeTally = $VolumeTally + 1
        #Compares $VolumeTally and $VolumeCount to stop volume creation loop
    } Until ($VolumeTally -eq $VolumeCount)
    #Writes created Volumes to Output 
    Write-Output $CreatedVolumes
}