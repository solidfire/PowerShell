# SolidFire PowerShell Tools

## Version 1.3 
#### Released 24-Jan-2017

![logo](docs/product.png)

##Description

The SolidFire PowerShell Tools is a collection of Microsoft® Windows® PowerShell functions that use SolidFire API to control a SolidFire storage system. These functions allow administrators to query for information, make changes to objects in a storage system, and develop complex scripts on a single platform. Users can implement this module with other modules and snap-ins, such as VMware® PowerCLI and Cisco® UCS PowerTool, to extend capabilities throughout the infrastructure.

Any user with a SolidFire storage system and Windows PowerShell can take advantage of the SolidFire PowerShell Tools. Users of the SolidFire PowerShell Tools should have an understanding of Windows PowerShell functions.

##Installation

The SolidFire Powershell Module can be installed on the following systems:

| System                    | Installation                              |
|---------------------------|-------------------------------------------|
| Windows                   | [Instructions](docs/windows/README.md)    |
| Mac                       | [Instructions](docs/mac/README.md)        |
| Linux (Ubuntu/Centos)     | [Instructions](docs/linux/README.md)      |
| Docker                    | [Instructions](docs/docker/README.md)     |

[V1.3 Release Notes](https://github.com/solidfire/PowerShell/blob/master/Install/SolidFire%20PowerShell%20Tools%20Release%20Notes%20v1.3.pdf)

Collection of scripts, functions, and examples using the SolidFire Tools for PowerShell. This repository serves as a space for development on various scripts and functions to assist in managing SolidFire systems using PowerShell.

You can access the SolidFire PowerShell Tools in the Install section below or through NetApp's SolidFire Support FTP site.

All scripts and functions will leverage the SolidFire PowerShell Tools.  Some scripts or functions may also leverage other PowerShell tools such as VMware's PowerCLI or Cisco's UCSPowerTool.  Scripts or functions using other modules or snapins will be noted. 


## Install
Download Installer: [SolidFire PowerShell 1.3 Installer](https://github.com/solidfire/PowerShell/raw/master/Install/SolidFire_PowerShell_1_3_0_124-install.msi) 

Instructions: Double-click the downloaded .msi file and follow the instructions in the install wizard. Additional details can be found in the [SolidFire PowerShell User Guide](https://github.com/solidfire/PowerShell/blob/master/Install/SolidFire%20PowerShell%20Tools%20User%20Guide_v1.3.pdf).

## Getting Started
Files located in the [Getting Started](https://github.com/solidfire/PowerShell/blob/master/Getting%20Started) directory provide a self-paced lab guide providing basic functionality to get started.

## Reporting
Provides scripts for reporting useful information from a SolidFire system.  Reports may also include scripts that report against other application or infrastructure components.

## SPBM
The SPBM functions extend capabilities by allowing administrators to implement vSphere Storage Policy Based Management dynamically. This leverages both the SolidFire PowerShell Tools and VMware PowerCLI.

## VMware
The scripts and functions in the VMware directory are directly related to managing SolidFire in a VMware environment.  This will include scripts to report on VM to volume mappings, creating policies, managing ESXi host to volume access group mappings, etc.  We will also include scripts for help with implementation of SolidFire best practices.

## Microsoft
Example scripts referenced in the Configuring Windows Server 2012 R2 Hyper-V for SolidFire configuration guide available on solidfire.com 

## Support
The complimenting scripts and resources are written as best effort and provide no warranty expressed or implied.  SolidFire support is not responsible for the content of this resource outside of the core module. Please contact the original author if you have questions about a script/resource. Please help support and answer questions for content you contribute and make this community great. You can engage with other users of this content at [ThePub](http://netapp.io).

If you have any questions or comments about this product, contact <ng-sf-host-integrations-sdk@netapp.com> or reach out to the online developer community at [ThePub](http://netapp.io). Your feedback helps us focus our efforts on new features and capabilities.

##Release History

| Version      | Release Date   |
|--------------|----------------|
| 1.3.0.124    | 24-JAN-2017 	  | 
| 1.2.1.1      | 26-MAY-2016    |
| 1.2.0.37     | 22-MAR-2016    |
| 1.1.0.37     | 17-DEC-2015    |   

## Archive
Previous versions of SolidFire PowerShell Tools can be found in the [archive](https://github.com/solidfire/PowerShell/tree/master/Install/Archive).