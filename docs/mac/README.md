# Install SolidFire PowerShell on Mac OS 10.11

![solidfire-powershell-logo](../../Install/product.png) ![apple-logo](apple-logo-small.png)

## Installation Instructions

The commands should be run in a terminal session on the machine you want to install on. You don't have to be in a specific directory to execute any of these commands. You will need sudo access. 

### First, Install PowerShell bits

*WARNING* If you run into complications with these steps, there are more detailed instructions on the [PowerShell for Mac installation page](https://github.com/PowerShell/PowerShell/blob/master/docs/installation/linux.md#macos-1012). 

1. Install the dependencies with [Homebrew](http://brew.sh/):

        brew install openssl
        brew install curl --with-openssl

1. Download the PowerShell for Mac bits:

        wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.2/powershell-6.0.0-beta.2-osx.10.12-x64.pkg

1. Install the package you just downloaded:

        sudo installer -pkg powershell-6.0.0-beta.2-osx.10.12-x64.pkg -target / 
    
### Next, Install SolidFire Bits

1. Create a directory for the SolidFire module:

        mkdir -p /usr/local/share/powershell/Modules/SolidFire

1. Download the SolidFire Powershell Module dlls from GitHub:

        cd /usr/local/share/powershell/Modules/SolidFire && curl --remote-name-all https://raw.githubusercontent.com/solidfire/sdk-dotnet/master/package/SolidFire.SDK.dll https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/Newtonsoft.Json.dll https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.dll https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.psd1 https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/Initialize-SFEnvironment.ps1 https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.dll-help.xml >/dev/null && cd -
   
1. [OPTIONAL] Setup the SolidFire PowerShell initializer script:

	    echo ". /usr/local/share/powershell/Modules/SolidFire/Initialize-SFEnvironment.ps1" > /usr/local/microsoft/powershell/6.0.0-beta.2/profile.ps1
	
	This will ensure the SolidFire PowerShell module is imported and initialized when you start up the PowerShell shell 

1. Launch PowerShell shell:

        powershell

## Paths

* `$PSHOME` is `/opt/microsoft/powershell/6.0.0-beta.2/`
* User profiles will be read from `~/.config/powershell/profile.ps1`
* Default profiles will be read from `$PSHOME/profile.ps1`
* User modules will be read from `~/.local/share/powershell/Modules`
* Shared modules will be read from `/usr/local/share/powershell/Modules`
* Default modules will be read from `$PSHOME/Modules`
* PSReadLine history will be recorded to `~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt`

The profiles respect PowerShell's per-host configuration,
so the default host-specific profiles exists at `Microsoft.PowerShell_profile.ps1` in the same locations.

`$PSHOME` is `/usr/local/microsoft/powershell/6.0.0-beta.2/`,
and the symlink is placed at `/usr/local/bin/powershell`.
