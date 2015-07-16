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
Part 2.2.1 - Create an Account
##############################
#>


New-SFAccount -UserName SELab01

<#
##############################
Part 2.2.2 - Create Volumes
##############################
#>

$account = Get-SFAccount SELab01

# Create volume with default QoS
New-SFVolume -Name SELab01-01 -AccountID $account.AccountID -Enable512e:$true -TotalSize 10 -GB

# Create volume with custom QoS
New-SFVolume -Name SELab01-02 -AccountID $account.AccountID -Enable512e:$true -TotalSize 10 -GB -MinIOPS 500 -MaxIOPS 1000 -BurstIOPS 2000

$volumes = Get-SFVolume SELab01*


<#
##############################
Part 2.2.3 - Create a Volume Access Group
##############################
#>

# We will add volumes and initiators in the next section.
New-SFVolumeAccessGroup -Name SELab01
