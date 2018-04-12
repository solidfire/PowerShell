# To install NetApp SolidFire Powershell on Windows:

![solidfire-powershell-logo](../../Install/product.png)   ![windows-logo](windows10-logo-small.png)

This page has instructions for installing the SolidFire PowerShell tools module on a Windows client. 

There are two different versions. One for PowerShell 5.1, and one for PowerShell 6. With it being able to run on many types of systems with very few dependencies, we recommend you choose the PowerShell 6 version if possible. 

## Powershell 6.0

##### Prerequisites

| Component            | Version          |
|----------------------|------------------|
| PowerShell           | 6.0 or later     |
| SolidFire Element OS | 7 through 10.0   |

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

PowerShell 6 supports many more platforms, but extensive module testing has not been done. More than likely they work fine, but no guarantees are given.

You can find that list here at [PowerShell Core 6.0](https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/).



## PowerShell 5.1 and below

##### Prerequisites

| Component            | Version          |
|----------------------|------------------|
| PowerShell           | 4.0 or later     |
| SolidFire Element OS | 7 through 10.0   |
| .NET Framework       | 4.5.1 or later   |

### Installation Instructions - Two methods are available

#### PowerShell Gallery (Preferred Method)

1. Once inside the PowerShell shell, install SolidFire PowerShell Tools by downloading it from the [PowerShell Gallery](powershellgallery.com) with the following command:

        PS> Install-Module -Name SolidFire

1. Then, import the SolidFire module with the following command:

        PS> Import-Module SolidFire

1. To see a list of available commands, use:

        PS> Get-Command -Module SolidFire


#### MSI Installer

Download and launch the installer .msi file then follow the instructions in the install wizard. 

[SolidFire PowerShell Installer](https://github.com/solidfire/PowerShell/raw/master/Install/SolidFire_PowerShell_1_5_0_119-install.msi) 

** Additional installation details can be found in the SolidFire PowerShell [User Guide Doc](https://github.com/solidfire/PowerShell/blob/master/Install/NetApp_SolidFire_PowerShell_Tools_v1.5_User_Guide.pdf)

##### Supported Microsoft Operating Systems

The following versions of Microsoft operating systems are supported and can run the SolidFire PowerShell tools.

| Version                |
|------------------------|
| Windows Server 2016    |
| Windows Server 2012 R2 |
| Windows 10             |

