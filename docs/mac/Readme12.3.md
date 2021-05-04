# Install NetApp SolidFire PowerShell Tools on Mac OS

![solidfire-powershell-logo](../../docs/product.png) ![apple-logo](apple-logo-small.png)

## Installation Instructions

The commands should be run in a terminal session on the machine you want to install on. You don't have to be in a specific directory to execute any of these commands. You will need sudo access. 

### First, Install PowerShell bits

Follow the detailed instructions on the [PowerShell for Mac installation page](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#macos-1012). 
    
### Next, Install SolidFire bits

1. Once inside the PowerShell shell, install SolidFire PowerShell Tools by downloading it from the [PowerShell Gallery](powershellgallery.com) with the following command:

        PS> Install-Module -Name SolidFire.Core

1. Then, import the SolidFire module with the following command:

        PS> Import-Module SolidFire.Core

1. To see a list of available commands, use:

        PS> Get-Command -Module SolidFire.Core

## Paths

* `$PSHOME` is `/opt/microsoft/powershell/[version]/`
* User profiles will be read from `~/.config/powershell/profile.ps1`
* Default profiles will be read from `$PSHOME/profile.ps1`
* User modules will be read from `~/.local/share/powershell/Modules`
* Shared modules will be read from `/usr/local/share/powershell/Modules`
* Default modules will be read from `$PSHOME/Modules`
* PSReadLine history will be recorded to `~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt`

The profiles respect PowerShell's per-host configuration,
so the default host-specific profiles exists at `Microsoft.PowerShell_profile.ps1` in the same locations.

`$PSHOME` is `/usr/local/microsoft/powershell/[version]/`,
and the symlink is placed at `/usr/local/bin/powershell`.

On Linux and macOS, the [XDG Base Directory Specification][xdg-bds] is respected.

[xdg-bds]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
