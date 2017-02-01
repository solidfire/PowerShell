# SolidFire PowerShell Tools

### Version 1.3.1.4 (github)

![logo](docs/product.png)

## Description

The SolidFire PowerShell Tools is a collection of Microsoft® Windows® PowerShell functions that use SolidFire API to control a SolidFire storage system. These functions allow administrators to query for information, make changes to objects in a storage system, and develop complex scripts on a single platform. Users can implement this module with other modules and snap-ins, such as VMware® PowerCLI and Cisco® UCS PowerTool, to extend capabilities throughout the infrastructure.

Any user with a SolidFire storage system and Windows PowerShell can take advantage of the SolidFire PowerShell Tools. Users of the SolidFire PowerShell Tools should have an understanding of Windows PowerShell functions.

## Installation

The SolidFire Powershell Module can be installed on the following systems:

| System                    | Installation                              |
|---------------------------|-------------------------------------------|
| Windows                   | [Instructions](docs/windows/README.md)    |
| Mac                       | [Instructions](docs/mac/README.md)        |
| Linux (Ubuntu/Centos)     | [Instructions](docs/linux/README.md)      |
| Docker                    | [Instructions](docs/docker/README.md)     |

[V1.3.1.4 Release Notes](https://github.com/solidfire/PowerShell/blob/master/Install/NetApp_SolidFire_PowerShell_Tools_v1_3_1_4_Release_Notes.pdf)

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

## Getting Help

The complimenting scripts and resources are written as best effort and provide no warranty expressed or implied.  SolidFire support is not responsible for the content of this resource outside of the core module. Please contact the original author if you have questions about a script/resource. Please help support and answer questions for content you contribute and make this community great.

If you have any questions or comments about this product, open an issue on our [GitHub repo](https://github.com/solidfire/powershell) or reach out to the online developer community at [ThePub](http://netapp.io). Your feedback helps us focus our efforts on new features and capabilities.

## Release History

| Version      | Release Date   |
|--------------|----------------|
| 1.3.1.4      | 01-FEB-2017    |
| 1.3.0.124    | 25-JAN-2017    |
| 1.2.1.1      | 26-MAY-2016    |
| 1.2.0.37     | 22-MAR-2016    |
| 1.1.0.37     | 17-DEC-2015    |

## Archive
Previous versions of SolidFire PowerShell Tools can be found in the [archive](https://github.com/solidfire/PowerShell/tree/master/Install/Archive).
