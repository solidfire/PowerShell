# To install NetApp SolidFire Powershell on Windows:

![solidfire-powershell-logo](../../Install/product.png)   ![windows-logo](windows10-logo-small.png)

This page has instructions for installing the SolidFire PowerShell Core tools module on a Windows client. 

**Note**: Only Powershell Core is supported in Powershell Tools v1.6. 

## Powershell Core

##### Prerequisites

| Component            | Version          |
|----------------------|------------------|
| .NET Core SDK        | 3.1 or later     |
| PowerShell Core      | 6.2 or later     |
| SolidFire Element OS | 11               |

### Installation Instructions
1. Download and install the .NET Core SDK, Version 3.1. You can get that here: 

   [.NET Core 3.1](https://dotnet.microsoft.com/download/dotnet-core/3.1/).

   You must use the SDK, not just the runtime.

2. Download and install the PowerShell Core msi installer: 

   Latest version : [Powershell Core 7.0](https://github.com/PowerShell/PowerShell/)
   
3. Download the PowerShell Core zip file from the NetApp Support Site and extract the contents to the directory you widsh to keep them in.   

4. Open Windows PowerShell, or a command prompt, and run powershell core using the following command:

   pwsh
   
4. Then, import the SolidFire module with the following command:

        PS> Import-Module <directory cotaining zip filecontents>\SolidFire.dll

5. To see a list of available commands, use:

        PS> Get-Command -Module SolidFire.Core

##### Supported Microsoft Operating Systems

The following versions of Microsoft operating systems are supported, and have had the module tested on them.

| Version                |
|------------------------|
| Windows Server 2016    |
| Windows Server 2018    |
| Windows 10             |

PowerShell Core 6.2 supports many more platforms, but extensive module testing has not been done. More than likely they work fine, but no guarantees are given.

You can find that list here at [PowerShell Core 6.2](https://devblogs.microsoft.com/powershell/general-availability-of-powershell-core-6-2/).
