#Installs feature(s) on multiple hosts
#pull in csv with server IP information
$csvfile = "\\172.27.100.7\share\scripts\powershell\hyper-v\hyperv-ips.csv"
$csv = Import-Csv -path $csvfile 

#Get credentials for Invoke-Command 
$creds = Get-Credential

#Populate the servers and sort the array by the FQDN of the VMM hosts
$servers = ($csv).hostname

#List of features to install. If more than one, use comma separated list
#Example for single feature $featurename = "GPMC"
#Example for multiple features $featurename = "GPMC","Multipath-IO"
$featurename = "GPMC","Failover-Clustering"

#Iterate through all the servers in the $servers variable
foreach ($server in $servers) {

#For each feature, check if the feature is installed or not
    foreach ($feature in $featurename) {
    write-host "Checking for $feature on server $server"
    $check = Get-WindowsFeature -Name $feature -ComputerName $server
    
        if ($check.Installed -ne "True") {
        #Install the feature if not installed as well as management tools
        Write-Host "Windows feature $feature not installed on server $server. Installing $feature ..." -ForegroundColor Green
        Add-WindowsFeature $feature -ComputerName $server -IncludeManagementTools | Out-Null
        }
        else {
        Write-Host "Feature $feature is already installed on host $server" -ForegroundColor Gray
        }
    }
}

Write-Host "Script Complete. Please reboot all hosts before continuing configuration"