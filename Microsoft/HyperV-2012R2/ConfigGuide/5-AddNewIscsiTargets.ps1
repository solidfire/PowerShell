#Configures the iSCSI initiator on SCVMM managed hosts

#pull in csv with server IP information
$csvfile = "\\172.27.100.7\share\scripts\powershell\hyper-v\hyperv-ips.csv"
$csv = Import-Csv -path $csvfile 

#Get credentials for Invoke-Command 
$creds = Get-Credential

#Populate the servers 
$servers = ($csv).hostname

#Iterate through all the servers in the $servers variable
foreach ($server in $servers) {

    Invoke-Command -ComputerName $server -Credential $creds -ScriptBlock {

        #Import IscsiTarget module if not loaded
        if (Get-Module -ListAvailable -Name IscsiTarget) {
            Write-Host "IscsiTarget module loaded... Continuting"
        } else {
            Write-Host "IscsiTarget module not loaded. Loading..."
            Import-Module IscsiTarget
        } #End if 
        
        #Set name variables for Invoke-Command
        $temphost = hostname
        $thishost = $using:csv | where{$_.hostname -eq $temphost}

        #Message what server we are working on
        Write-Host "########################################" -ForegroundColor Green
        Write-Host "Beginning configuration of $using:server`r`n" -ForegroundColor Green

        Write-Host "Updating iSCSI Targets..."
        Update-IscsiTargetPortal -TargetPortalAddress $thishost.svip

        Write-Host "Connecting any new inactive iSCSI targets on" $temphost -ForegroundColor DarkGray
        $targets = Get-IscsiTarget | Where-Object {$_.IsConnected -ne "True"}
        foreach ($target in $targets) {
        Connect-IscsiTarget -NodeAddress $target.NodeAddress -InitiatorPortalAddress $thishost.ipiscsi1 -IsMultipathEnabled $true -IsPersistent $true -TargetPortalAddress $thishost.svip
        Connect-IscsiTarget -NodeAddress $target.NodeAddress -InitiatorPortalAddress $thishost.ipiscsi2 -IsMultipathEnabled $true -IsPersistent $true -TargetPortalAddress $thishost.svip
        Start-Sleep -s 1
        } #End foreach ($target in $targets) loop
    } #End Invoke-Command
}#End foreach ($server in $servers) loop