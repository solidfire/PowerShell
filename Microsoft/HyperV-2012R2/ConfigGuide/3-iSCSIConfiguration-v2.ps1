#Configures the iSCSI initiator on SCVMM managed hosts

#pull in csv with server IP information
$csvfile = "\\172.27.100.7\share\scripts\powershell\hyper-v\hyperv-ips.csv"
$csv = Import-Csv -path $csvfile 

#Get credentials for Invoke-Command 
$creds = Get-Credential

#Populate the servers and sort the array by the FQDN of the VMM hosts
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
        }
        
        #Set name variables for Invoke-Command
        $temphost = hostname
        $thishost = $using:csv | where{$_.hostname -eq $temphost}

        #Message what server we are working on
        Write-Host "########################################" -ForegroundColor Green
        Write-Host "Beginning configuration of $using:server`r`n" -ForegroundColor Green

        #Get status of iSCSI service
        $iSCSIService = get-service msiscsi

        #Test to see if the msiscsi service is already running, if not, start it
        Write-Host "Checking status of iSCSI service"
        if ($iSCSIService.Status -eq "Stopped") {
            Write-Host "MSISCSI service not running. Starting service and setting startup type to 'automatic'"  -ForegroundColor DarkGray
            $iSCSIService.Start()
            Start-Sleep -seconds 5
            Set-Service –Name MSiSCSI –StartupType Automatic
        } 
        else {
            Write-Host "iSCSI service already running on host" $temphost -ForegroundColor DarkGray
        } 

        #Enable iSCSI through the firewall
        $iscsiFw = Get-NetFirewallRule -DisplayGroup "iscsi Service"
        $iscsiFwIn = $iscsifw | Where-Object {$_.Name -eq "MsiScsi-In-TCP"}
        $iscsiFwOut = $iscsifw | Where-Object {$_.Name -eq "MsiScsi-Out-TCP"}

        #Check and enable inbound iSCSI traffic 
        if ($iscsiFwIn.Enabled -eq "True") {
            Write-Host "MSiSCSI inbound connections already enabled" -ForegroundColor DarkGray
            }
        else {
            write-host "Updating firewall rules to allow inbound iSCSI traffic on host" $temphost -ForegroundColor DarkGray
            Set-NetFirewallRule -Name MsiScsi-In-TCP -Enabled True
        }

        #Check and enable inbound iSCSI traffic 
        if ($iscsiFwOut.Enabled -eq "True") {
            Write-Host "MSiSCSI outbound connections already enabled" -ForegroundColor DarkGray
            }
        else {
            write-host "Updating firewall rules to allow outbound iSCSI traffic on host" $temphost -ForegroundColor DarkGray
            Set-NetFirewallRule -Name MsiScsi-Out-TCP -Enabled True
        }

        #Check to see if iSCSI Target Portal has already been configured
        #If so, skip, if not, configure it
        $isIscsiConfigured = (Get-IscsiTargetPortal).TargetPortalAddress
        if ($isIscsiConfigured) {
            Write-Host "iSCSI Target Portal" (Get-IscsiTargetPortal).TargetPortalAddress "has already been configured" -ForegroundColor DarkGray
        }
        else {
            Write-Host "Configuring the iSCSI Target Portal on host" $temphost -ForegroundColor DarkGray
            New-IscsiTargetPortal –TargetPortalAddress $thishost.svip
           
            <#
            Connect to each target with both vEth iSCSI interfaces
            Sleep command necessary for avoiding aborted connections that can happen
            when many concurrent connections are attempted
            #>
            Write-Host "Connecting to targets" -ForegroundColor DarkGray
            #$targets = Get-IscsiTarget
            $targets = Get-IscsiTarget | Where-Object {$_.IsConnected -ne "True"}
            foreach ($target in $targets) {
            Connect-IscsiTarget -NodeAddress $target.NodeAddress -InitiatorPortalAddress $thishost.ipiscsi1 -IsMultipathEnabled $true -IsPersistent $true -TargetPortalAddress $thishost.svip
            Connect-IscsiTarget -NodeAddress $target.NodeAddress -InitiatorPortalAddress $thishost.ipiscsi2 -IsMultipathEnabled $true -IsPersistent $true -TargetPortalAddress $thishost.svip
            Start-Sleep -s 1
            }

            #Set up MPIO to automatically claim devices
            # Enable the MPIO Feature, if not already done
            Write-Host "Enabling MPIO on server " $using:server -ForegroundColor DarkGray
            Enable-WindowsOptionalFeature -Online -FeatureName MultipathIO

            # Enable automatic claiming of iSCSI devices for MPIO 
            Write-Host "Enabling automatic claiming of MPIO devices for iSCSI" -ForegroundColor DarkGray
            Enable-MSDSMAutomaticClaim -BusType iSCSI | Out-Null

            # Set the default load balance policy of all newly claimed devices to Round Robin 
            # Might have to reboot to get it to work if you just enabled MPIO feature and didn't reboot
            #The "Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy RR" command will actually fail if the server
            #has not been rebooted after enabling MPIO
            Write-Host "Setting default load balancing policy to Round Robin" -ForegroundColor DarkGray
            Set-MSDSMGlobalDefaultLoadBalancePolicy -Policy RR
        } #End $isIscsiConfigured if/else 

    Write-Host "Finsihed configuration of $using:server" -ForegroundColor Green
    Write-Host "#######################################`r`n" -ForegroundColor Green
    } #End Invoke-Command 
} #End foreach ($server in $servers) loop


#Optional - Push server IQNs into Volume Access Group
#This assumes the SolidFire PSM is installed on the host running this script


