<#
.Get_Queue_Depth

.NOTES  Author: Josh Atwell @josh_atwell

.Label
Get iSCSI adapter Queue Depth

.Description
Reports the Queue Depth settings for iSCSI adapters
#>

param
(
   [Parameter(Mandatory=$true)]
   [VMware.VimAutomation.ViCore.Types.V1.Inventory.VMHost[]]
   $vParam
);

foreach($vmhost in $vParam){
  $esxcli = Get-EsxCli -VMhost $vmhost
  $result = $esxcli.system.module.parameters.list("iscsi_vmk") | Where{$_.Name -eq "iscsivmk_LunQDepth"}
  Write-Host "$($result.Description) for $vmhost is set to $($result.Value)"
}