<#
Basic initial network configuration. Expects to be run from a host locally

The CSV file is structured as follows

hostname,ipmgmt,ipiscsi1,ipiscsi2,ipfailover,svip
hyperv-01,172.27.40.9,172.27.41.9,172.27.41.19,172.27.50.9,172.27.41.220
#>

#pull in csv with network config
$csvfile = "\\172.27.100.7\share\scripts\powershell\hyper-v\hyperv-ips.csv"
$csv = Import-Csv -path $csvfile 
$temphost = hostname
$thishost = $csv | where{$_.hostname -eq $temphost}

New-NetLbfoTeam -Name 1G-Mgmt -TeamMembers NIC3,NIC4 -confirm:$false
New-NetLbfoTeam -Name 10G-Net -TeamMembers NIC1,NIC2 -confirm:$false

#Create new VMSwitch for Management Traffic
New-VMSwitch -Name "Management" -NetAdapterName "1G-Mgmt"
start-sleep -s 2

#Set up management network
New-NetIPAddress -InterfaceAlias "vEthernet (Management)" -IPAddress $thishost.ipmgmt -PrefixLength 24 -DefaultGateway 172.27.40.254
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Management)" -ServerAddresses 172.27.100.13,172.27.100.14

#Create VMSwitch for iSCSI and VM traffic 
New-VMSwitch -Name "XD-Logical-Switch" -NetAdapterName "10G-Net" -AllowManagementOS $false

#Add iSCSI VMNetworkAdapters and set VLAN
Add-VMNetworkAdapter -ManagementOS -Name "iSCSI1" -SwitchName "XD-Logical-Switch"
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "iSCSI1" -Access -VlanId 2001
Add-VMNetworkAdapter -ManagementOS -Name "iSCSI2" -SwitchName "XD-Logical-Switch"
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "iSCSI2" -Access -VlanId 2001

New-NetIPAddress -InterfaceAlias "vEthernet (iSCSI1)" -IPAddress $thishost.ipiscsi1 -PrefixLength 24
New-NetIPAddress -InterfaceAlias "vEthernet (iSCSI2)" -IPAddress $thishost.ipiscsi2 -PrefixLength 24

#Add Hyper-V Failover Network
Add-VMNetworkAdapter -ManagementOS -Name "Failover" -SwitchName "XD-Logical-Switch"
Set-VMNetworkAdapterVlan -ManagementOS -VMNetworkAdapterName "Failover" -Access -VlanId 2002
New-NetIPAddress -InterfaceAlias "vEthernet (Failover)" -IPAddress $thishost.ipfailover -PrefixLength 24

#Enable Jumbo Frames on 10g adapters
#Have separate matches for vEth vs Eth due to slightly different property names
$10gvNICs = Get-Netadapter | where Name -Match iSCSI
$10gNICs = Get-NetAdapter | where InterfaceDescription -Match 10G
Set-NetAdapterAdvancedProperty $10gNICs.Name -DisplayName "Jumbo Packet" -DisplayValue "9014 Bytes"
Set-NetAdapterAdvancedProperty $10gNICs.Name -DisplayName "Large Send Offload V2 (IPV4)" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty $10gNICs.Name -DisplayName "Large Send Offload V2 (IPV6)" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty $10gvNICs.Name -DisplayName "Jumbo Packet" -DisplayValue "9014 Bytes"
Set-NetAdapterAdvancedProperty $10gvNICs.Name -DisplayName "Large Send Offload Version 2 (IPV4)" -DisplayValue "Disabled"
Set-NetAdapterAdvancedProperty $10gvNICs.Name -DisplayName "Large Send Offload Version 2 (IPV6)" -DisplayValue "Disabled"
