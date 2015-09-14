<#
Options included in script.
1 | Increase  MaxHWTransferSize size from 4MB to 16MB !!! only for Nitrogen
2 | Set DSNRO (Disk Scheduler Number Req Outstanding for a volume
3 | Set Queue Depth for Software iSCSI initiator to 256
4 | Turn Off DelayedAck for Random Workloads !!! Only for throughput heavy workloads or latency senstive applications
5 | Create Custom SATP Rule for SolidFire
#>

$vmhosts = Get-VMhost esxi6-ja-03.pm.solidfire.net

foreach($vmhost in $vmhosts){

$esxcli = Get-EsxCli -VMHost $vmhost

# 1 - Max HW Transfer Size

$vmhost | Get-AdvancedSetting -Name "DataMover.MaxHWTransferSize" | Select Value

# 2 - DSNRO


$devices = $esx | Get-ScsiLun | Where{$_.Vendor -match "SolidFir"}
foreach($device in $devices){
($esxcli.storage.core.device.list($device.CanonicalName)).NoofoutstandingIOswithcompetingworlds
}

# No of outstanding IOs with competing worlds: 32


# 3 - Queue Depth
$result = $esxcli.system.module.parameters.list("iscsi_vmk") | Where{$_.Name -eq "iscsivmk_LunQDepth"}


# 4 - Delayed Ack

$adapterID = $vmhost.ExtensionData.config.StorageDevice.HostBusAdapter | Where{$_.Model -match "iSCSI"}

    $esxcli.iscsi.adapter.param.get($adapterID.device) | Where{$_.Name -eq "DelayedACK"} | Select Current

# 5 - SATP
$esxcli.storage.nmp.satp.rule.list() | Where{$_.Vendor -eq "SolidFir"}
}