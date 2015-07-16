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
Part 2.1.1 - Loading and Checking the Module
##############################
#>

# Checking if module is loaded.
Get-Module
Get-Module SolidFire


# Remove Module and validate removal
Remove-Module SolidFire
Get-Module


<# Import Module
The SolidFire module will be placed in one of the default module directories during install.

Directories can be located with $env:PSModulePath

If you want to import the module on a different system you can use the following
Import-Module "path\to\module\SolidFire.dll"
#>
Import-Module SolidFire
Get-Module SolidFire

# Identify Module installation path
(Get-Module SolidFire).path


<#
##############################
Part 2.1.2 - Using Get-Help
##############################
#>

# Get-Help provides documentation for how each cmdlet works and can be used.

# Check available cmdlets
Get-Command -Module SolidFire
(Get-Command -Module SolidFire).count

# Get-SFCommand works only when loading the SolidFire Tools for PowerShell session via install.

# There are more than 60 cmdlets in the initial beta release!  More will be in 1.0

# Finding the cmdlet you need
Get-Command *volume* -Module SolidFire
Get-Command -Module SolidFire -Verb Get -Noun *volume*

# Accessing Help
Get-Help Get-SFVolume
Get-Help Get-SFVolume -Examples
Get-Help Get-SFVolume -Full


<#
##############################
Part 2.1.2 - Connecting to SolidFire
##############################
#>

# Connect to SolidFire Node/Cluster


# Lab Group 1
Connect-SFCluster -Target 192.168.0.100 -UserName <username> -ClearPassword <password>

# Connect-SFCluster also supports stored credentials.

$sfcred = Get-Credential
Connect-SFCluster -Target 192.168.0.100 -Credential $sfcred

# Connect to a node
Connect-SFCluster -Target 192.168.1.101 -Credential $sfcred -Node

# Check the connection
$SFConnection

<#
???????????????????????????
What other ways can you initiate a connection to SolidFire cluster
Hint: Use Get-Help
???????????????????????????
#>