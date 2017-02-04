<# This script creates vSphere snapshots of all VMs on vSphere datastore and then snapshots/replicates SolidFire volume hosting the datastore
Author: Sergey Omelaenko osergey@netapp.com
Edit parameter section below for your environment
Requires vSphere PowerCLI and SolidFire PowerShell Tools 
====================================================================
Disclaimer: This script is written as best effort and provides no 
warranty expressed or implied. Please contact the author(s) if you 
have questions about this script.
====================================================================
#>
Param(
  $VcServer = “vCentre1.vsphere.local”,
  $Username = "administrator@vsphere.local",
  $Password = “password”,
  $DatastoreName = "DS1",
  $Mvip = "10.1.1.10",
  $SfUsername = "script-user",
  $SfPassword = “password123”
)

import-module SolidFire
import-module "Vmware.VimAutomation.Core"

#Connect SolidFire cluster
Write-Output "Connecting to SolidFire Cluster $Mvip"
Connect-SFCluster -Target $Mvip -Username $SfUsername -Password $SfPassword

#Connect vCentre Server
Write-Output "Connecting to $VcServer"
$viserver = connect-viserver -server $VcServer -user $Username -password $Password


#Snap VMs on the Datastore
$vm_list = Get-Datastore -Name $DatastoreName | Get-VM
$vm_list = $vm_list | Sort-Object

$datestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$tasks = @()
foreach ($vm in $vm_list)
{
    Write-Output "Taking a snapshot of $vm"
    $snap_name = "PowerCLI snapshot backup $datestamp"
    $tasks += $vm | New-Snapshot -Name $snap_name -Memory:$true -Quiesce:$true -RunAsync
}
Write-Output "Waiting for VM snapshots to complete"
foreach ($task in $tasks)
{
    $vm_id = $task.ObjectId
    $vm = Get-VM -Id $vm_id
    Write-Output "Waiting for snap on $vm"
    #Wait-Task -Task $task
    $tv = $task | Get-View
    $tv.WaitForTask($tv.MoRef) | Out-Null
}
Write-Output "All VM snapshots have finished"

# Get SolidFire volume associated with a vSphere Datastore
# http://www.github.com/solidfire/powershell
Function Get-SFVolumeFromDatastore{[CmdletBinding()]
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


# Snap and replicate SolidFire volume
# Replicated volumes must be paired manually for replication to function 
Write-Output "Beginning SolidFire snap operation"
Get-Datastore $DatastoreName | Get-SFVolumeFromDatastore | New-SFSnapshot -Name Snap-$DatastoreName -Retention "72:0:00" -EnableRemoteReplication

#Delete all VM snaps
Get-VM $vm_list | Get-Snapshot | Remove-Snapshot -Confirm:$false
Write-Output "All VMs have finished deleting snapshots"


disconnect-viserver -server * -force -confirm:$false | out-null


