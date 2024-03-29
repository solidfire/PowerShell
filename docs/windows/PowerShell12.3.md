# To install NetApp SolidFire Powershell on Windows:

![solidfire-powershell-logo](../../docs/product.png)   ![windows-logo](windows10-logo-small.png)

This page has instructions for installing the SolidFire PowerShell Core tools module on a Windows client. 

**Note**: Only Powershell Core is supported in Powershell Tools v12.3. 

## Powershell Core

##### Prerequisites

| Component            | Version          |
|----------------------|------------------|
| PowerShell Core      | 6.1 or later     |
| SolidFire Element OS | 11.0 through 12.3|

### Installation Instructions
1. Download and install the PowerShell Core msi installer: 

   Latest version : [Powershell Core 7.1](https://github.com/PowerShell/PowerShell/)
   
2. Download the PowerShell Core zip file from the NetApp Support Site and extract the contents to the directory you wish to keep them in.   

3. Open Windows PowerShell, or a command prompt, and run powershell core using the following command:

       pwsh
   
4. Then, import the SolidFire module with the following command:

        PS> Import-Module <directory cotaining zip file contents>\SolidFire.dll

5. To see a list of available commands, use:

        PS> Get-Command -Module SolidFire

##### Supported Microsoft Operating Systems

The following versions of Microsoft operating systems are supported, and have had the module tested on them.

| Version                |
|------------------------|
| Windows Server 2016    |
| Windows Server 2018    |
| Windows 10             |

PowerShell Core 7.1 supports many more platforms, but extensive module testing has not been done. More than likely they work fine, but no guarantees are given.

You can find that list here at [PowerShell Core 7.1](https://devblogs.microsoft.com/powershell/announcing-powershell-7-1/).
