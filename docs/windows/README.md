# To install NetApp SolidFire Powershell on Windows:

![solidfire-powershell-logo](../../docs/product.png)   ![windows-logo](windows10-logo-small.png)

This page has instructions for installing the SolidFire PowerShell tools module on a Windows client. 

## Powershell 6.1

##### Prerequisites

| Component            | Version          |
|----------------------|------------------|
| PowerShell           | 6.1 or later     |
| SolidFire Element OS | 11.8 through 12.3|

### Installation Instructions

1. Once inside the PowerShell shell, install SolidFire PowerShell Tools by downloading it from the [PowerShell Gallery](powershellgallery.com) with the following command:

        PS> Install-Module -Name SolidFire.Core

1. Then, import the SolidFire module with the following command:

        PS> Import-Module SolidFire.Core

1. To see a list of available commands, use:

        PS> Get-Command -Module SolidFire.Core

##### Supported Microsoft Operating Systems

The following versions of Microsoft operating systems are supported, and have had the module tested on them.

| Version                |
|------------------------|
| Windows Server 2016    |
| Mac 10.13              |
| CentOS 7.3             |
| Ubuntu 16.04           |

PowerShell 7.1 supports many more platforms, but extensive module testing has not been done. More than likely they work fine, but no guarantees are given.

You can find that list here at [PowerShell Core 7.1](https://devblogs.microsoft.com/powershell/announcing-powershell-7-1/).