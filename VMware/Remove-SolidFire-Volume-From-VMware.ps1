# Load Datastore Functions
. "C:\Users\jatwell\Google Drive\Scripts\DatastoreFunctions.ps1"

# Load SPBM Module since we'll use the Get-SVolumeFromDatastore function.
Import-Module "C:\Users\jatwell\Documents\GitHub\PowerShell\SPBM\SolidFire-SPBM.psm1"


# Collect datastore object that you wish to remove
$datastore = Get-Datastore Engineering-02

# Collect volume object for the selected datastore
$volume = $datastore | Get-SFVolumeFromDatastore


$datastore | Get-DatastoreMountInfo

# Unmount the datastore
$datastore | Unmount-Datastore

# Check mount info for the datastore (optional)
$datastore | Get-DatastoreMountInfo


# Detach the datastore from ESXi host
$datastore | Detach-Datastore

# Remove the volume from the SolidFire System
# This places the volume in the DeletedVolumes space
$volume | Remove-SFVolume -Confirm:$false

# Optional | Permanently remove volume from SolidFire system
# This is a PERMANENT OPERATION!
#Get-SFDeletedVolume | Remove-SFDeletedVolume -Confirm:$false