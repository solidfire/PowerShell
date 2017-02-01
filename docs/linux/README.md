# Install SolidFire PowerShell on Linux

![solidfire-powershell-logo](../../docs/product.png) ![linux-logo](linux-logo-small.png)

The commands should be run in a terminal session on the machine you want to install on. You don't have to be in a specific directory to execute any of these commands. You will need sudo access. 

## First, Install PowerShell bits

#### Ubuntu 14.04

Using [Ubuntu 14.04][], download the Debian package
`powershell_6.0.0-alpha.14-1ubuntu1.14.04.1_amd64.deb`
from the [releases][] page onto the Ubuntu machine.

Then execute the following in the terminal:

```sh
sudo dpkg -i powershell_6.0.0-alpha.14-1ubuntu1.14.04.1_amd64.deb
sudo apt-get install -f
```

> Please note that `dpkg -i` will fail with unmet dependencies;
> the next command, `apt-get install -f` resolves these
> and then finishes configuring the PowerShell package.

**Uninstallation**

```sh
sudo apt-get remove powershell
```

[Ubuntu 14.04]: http://releases.ubuntu.com/14.04/

#### Ubuntu 16.04

Using [Ubuntu 16.04][], download the Debian package
`powershell_6.0.0-alpha.14-1ubuntu1.16.04.1_amd64.deb`
from the [releases][] page onto the Ubuntu machine.

Then execute the following in the terminal:

```sh
sudo dpkg -i powershell_6.0.0-alpha.14-1ubuntu1.16.04.1_amd64.deb
sudo apt-get install -f
```

> Please note that `dpkg -i` will fail with unmet dependencies;
> the next command, `apt-get install -f` resolves these
> and then finishes configuring the PowerShell package.

**Uninstallation**

```sh
sudo apt-get remove powershell
```

[Ubuntu 16.04]: http://releases.ubuntu.com/16.04/

This works for Debian Stretch (now testing) as well.

#### CentOS 7

Using [CentOS 7][], download the RPM package
`powershell-6.0.0_alpha.13-1.el7.centos.x86_64.rpm`
from the [releases][] page onto the CentOS machine.

Then execute the following in the terminal:

```sh
sudo yum install ./powershell-6.0.0_alpha.14-1.el7.centos.x86_64.rpm
```

You can also install the RPM without the intermediate step of downloading it:

```sh
sudo yum install https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.14/powershell-6.0.0_alpha.14-1.el7.centos.x86_64.rpm
```

This package works on Oracle Linux 7. It should work on Red Hat Enterprise Linux 7 too.

**Uninstallation**

```sh
sudo yum remove powershell
```

[CentOS 7]: https://www.centos.org/download/
    
## Next, Install SolidFire Bits

1. Create a directory for the SolidFire module:

        mkdir -p /usr/local/share/powershell/Modules/SolidFire

1. Download the SolidFire Powershell Module dlls from Github:

        cd /usr/local/share/powershell/Modules/SolidFire && curl --remote-name-all  https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.SDK.dll https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/Newtonsoft.Json.dll https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.dll https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.psd1 https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/Initialize-SFEnvironment.ps1 https://raw.githubusercontent.com/solidfire/PowerShell/master/packages/SolidFire.dll-help.xml >/dev/null && cd -
   
1. [OPTIONAL but recommended] Setup the SolidFire PowerShell initializer script:

	    echo ". /usr/local/share/powershell/Modules/SolidFire/Initialize-SFEnvironment.ps1" > /opt/microsoft/powershell/6.0.0-alpha.14/profile.ps1
	
	This will ensure the SolidFire PowerShell module is imported and initialized when you start up the PowerShell shell 

1. Launch PowerShell shell:

        powershell

## Paths

* `$PSHOME` is `/opt/microsoft/powershell/6.0.0-alpha.14/`
* User profiles will be read from `~/.config/powershell/profile.ps1`
* Default profiles will be read from `$PSHOME/profile.ps1`
* User modules will be read from `~/.local/share/powershell/Modules`
* Shared modules will be read from `/usr/local/share/powershell/Modules`
* Default modules will be read from `$PSHOME/Modules`
* PSReadLine history will be recorded to `~/.local/share/powershell/PSReadLine/ConsoleHost_history.txt`

The profiles respect PowerShell's per-host configuration,
so the default host-specific profiles exists at `Microsoft.PowerShell_profile.ps1` in the same locations.

On Linux and macOS, the [XDG Base Directory Specification][xdg-bds] is respected.

[releases]: https://github.com/PowerShell/PowerShell/releases/latest
[xdg-bds]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
