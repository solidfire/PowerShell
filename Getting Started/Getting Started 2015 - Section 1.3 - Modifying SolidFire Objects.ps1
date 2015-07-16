<#
This script is part of a series of scripts that were provided for instructional purposes.
Examples in this document should not be considered complete in part or in whole and used for instructional purposes.

====================================================================
|                              Disclaimer:                         |
| This script is written as best effort and provides no warranty   |
| expressed or implied. Please contact SolidFire support if you    |
| have questions about this script before running or modifying.    |
====================================================================

#>

# Using the break in case you accidentally run the entire file
break


<#
##############################
Part 2.3.1.1 - Change CHAP Secrets for Account
##############################
#>


$accountID = (Get-SFAccount SELab01).AccountID
# Change the CHAP Secrets
# NOTE: You will be asked to confirm this action
Set-SFAccount -AccountID $accountID -InitiatorSecret selab01initiator -TargetSecret selab01target

# Note: You can disable confirmation by adding  -Confirm:$false


<#
##############################
Part 2.3.2.1 - Change QoS on Multiple Volumes
##############################
#>

$account = Get-SFAccount SELab01
$volumes = Get-SFVolume SELab01-0*
$volumes | %{Set-SFVolume -VolumeID $_.VolumeID -MinIOPS 1500 -MaxIOPS 3000 -BurstIOPS 5000}


$volumes = Get-SFVolume SELab01-0* 
# Why do we collect the information again?

# Query results
$volumes | Select VolumeName, @{N='MinIOPS';E={$_.QoS.MinIOPS}}, @{N='MaxIOPS';E={$_.QoS.MaxIOPS}}, @{N='BurstIOPS';E={$_.QoS.BurstIOPS}}

# Look at ONLY the QoS values
$volumes | Select -ExpandProperty QoS

# Look at ONLY the QoS curve
$volumes | select -ExpandProperty QoS | Select -ExpandProperty Curve


<#
##############################
Part 2.3.2.2 - Change Volume Capacity
##############################
#>

# Skip this subsection. This one is currently broken with a reported bug.

#$volumes | Set-SFVolume -TotalSize 12 -GB

#Get-SFVolume | Select VolumeName, VolumeID, TotalSize


<#
##############################
Part 2.3.3.1 - Add Initiators to Volume Access Group
##############################
#>

# We'll tackle this with live data in the next section
$iqns = "iqn.1998-01.com.vmware.iscsi:name1","iqn.1998-01.com.vmware.iscsi:name2","iqn.1998-01.com.vmware.iscsi:name3"
$vid = (Get-SFVolumeAccessGroup SELab01).VolumeAccessGroupID

$iqns | Add-SFInitiatorToVolumeAccessGroup -VolumeAccessGroupID $vid


<#
##############################
Part 2.3.3.2 - Add Volumes to Volume Access Group
##############################
#>

$volumes | Add-SFVolumeToVolumeAccessGroup -VolumeAccessGroupID $vid

<#
##############################
Part 2.3.3.3 - Remove Initiators from Volume Access Group
##############################
#>

# We'll remove the fictitious list of host IQNs as clean up.
$iqns = "iqn.1998-01.com.vmware.iscsi:name1","iqn.1998-01.com.vmware.iscsi:name2","iqn.1998-01.com.vmware.iscsi:name3"
$vid = (Get-SFVolumeAccessGroup SELab01).VolumeAccessGroupID

$iqns | Remove-SFInitiatorFromVolumeAccessGroup -VolumeAccessGroupID $vid


<#
##############################
Part 2.3.3.4 - Remove Volume from Volume Access Group
##############################
#>

# Let's remove the volumes to demonstrate the capability.
$volumes | Remove-SFVolumeFromVolumeAccessGroup -VolumeAccessGroupID $vid

Get-SFVolumeAccessGroup

<#
##############################
Part 2.3.3.5 - Put the volumes back

See if you can remember how to put the volumes back in the 
volume access group...without peeking at previous example.


##############################
#>


