#get credentials for the Invoke-Command section
$creds = get-credential

<#
Add storage to Failover Cluster, assumes all nodes joined to cluster with no shared storage.
Script has to be run on an existing cluster node, otherwise CredSSP
will need to be configured which can be considered a security risk
#>
$cluster = Get-Cluster

<#Server used should currently own storage being configured
This server should have the FCM role and management tools installed
as well as having access to the iSCSI volumes to be imported into FCM
Assumes iSCSI volumes are connected
#>
$server = "Hyperv-09"

#Add CSVs to cluster
#Invoke-Command -ComputerName $server -Credential $creds -ScriptBlock {

#Format storage and add to Failover Cluster Manager as CSVs
#Get the target name and legacy disk name for the volumes
#This requires that iSCSI targets are already presented and connected
$iscsidevices = (get-wmiobject -namespace ROOT\WMI -class MSiSCSIInitiator_SessionClass).devices | select TargetName,LegacyName -Unique | where {$_.targetname -match "pvs-desktop"}

#Sort the devices by legacy name
$iscsidevices = $iscsidevices | Sort-Object -Property @{Expression={[int][RegEx]::Match($_.LegacyName, "(?:[a-zA-Z-\.]+)(?<number>\d+)").Groups["number"].Value}}

#Break out volume names and legacy disk numbers for use in Initialize-Disk
$iscsivolumenames = $iscsidevices.Targetname | ForEach-Object {$_.split('.')[4]}
$LegacyDiskNumber = $iscsidevices.LegacyName | ForEach-Object {$_.split('e')[1]}

#Format driveswith GPT partition type
#Uses SolidFire volume name for file system label
for ($i = 0; $i -lt $iscsidevices.count; $i++)  {
write-host "Formating Disk number" $LegacyDiskNumber[$i] "as" $iscsivolumenames[$i] -ForegroundColor DarkGreen
#Initialize-Disk -Number $LegacyDiskNumber[$i] -PartitionStyle GPT -PassThru  | New-Partition -UseMaximumSize  | Format-Volume -FileSystem NTFS -NewFileSystemLabel $iscsivolumenames[$i]  -Confirm:$false -ErrorAction SilentlyContinue
Initialize-Disk -Number $LegacyDiskNumber[$i] -PartitionStyle GPT
#Assign temp free drive letter to ease formating logic
New-Partition -DiskNumber $LegacyDiskNumber[$i] -UseMaximumSize -AssignDriveLetter 
$tempdriveletter = Get-Partition -DiskNumber $LegacyDiskNumber[$i] | select DriveLetter
Format-Volume -FileSystem NTFS -NewFileSystemLabel $iscsivolumenames[$i] -Confirm:$false -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2
} #End for loop

#Add storage to Cluster Failover Manager as available storage
<#If not all available storage is to be added to FCM this
then the "Get-ClusterAvailableDisk | Add-ClusterDisk" command
could be run inside the preceeding for loop to add disks
as they are available after formating. This would limit the 
storage added to the cluster to just those volumes that get
matched in the $iscsidevices variable
#>
Get-ClusterAvailableDisk | Add-ClusterDisk

#Get list of cluster disk resources to add to CSV
$ClusterDisks = Get-ClusterResource | where {$_.OwnerGroup -match "Available Storage"}
Add-ClusterSharedVolume -Name $clusterdisks.Name

#Rename Cluster Disks in FCM to match volume name
$ClusterDisks =  Get-CimInstance -ClassName MSCluster_Resource -Namespace root/mscluster -Filter "type = 'Physical Disk'"

foreach ($Disk in $ClusterDisks) {
    $DiskResource = Get-CimAssociatedInstance -InputObject $Disk -ResultClass MSCluster_DiskPartition
        if (-not ($DiskResource.VolumeLabel -eq $Disk.Name)) {
        Write-host "Renaming CSV" $disk.Name "to" $DiskResource.VolumeLabel -ForegroundColor DarkGreen
        Invoke-CimMethod -InputObject $Disk -MethodName Rename -Arguments @{newName = $DiskResource.VolumeLabel}
        } #End If
    } #End Foreach

#Aaannnd for extra credit, rename shortcuts for CSVs to match volume names
#To Do - Figure out how to programatically rename Junctions to their target

Write-Host "Finished Adding CSV" -ForegroundColor DarkGreen
#} #End Invoke-Command for adding CSVs

########################################################################
#Now validate that all the servers have the expected storage allocated #
########################################################################

#pull in csv with server IP information
$csvfile = "\\172.27.100.7\share\scripts\powershell\hyper-v\hyperv-ips.csv"
$csv = Import-Csv -path $csvfile 

#Populate the servers variable
$servers = ($csv).hostname

foreach ($server in $servers) {

    Invoke-Command -ComputerName $server -Credential $creds -ScriptBlock {
    $ClusterDisks =  Get-CimInstance -ClassName MSCluster_Resource -Namespace root/mscluster -Filter "type = 'Physical Disk'" | sort
    $outstring = $ClusterDisks.Name -join "`n"
    $serverhost = $env:COMPUTERNAME
    Write-host "Checking cluster storage on" $serverhost
    write-host "There are" $ClusterDisks.Count "cluster disks on this server" 
    Write-host "The cluster disks are:`n"
    write-host $outstring -ForegroundColor DarkGreen
    }
}

#Finally, set the CSV cache size to 512MB
#In Windows 2012 R2 CSV cache is enabled by default but set to 0MB
#More information here: http://blogs.msdn.com/b/clustering/archive/2013/07/19/10286676.aspx

Write-Host "Setting CSV Block Cache Size to 512MB"
(Get-Cluster).BlockCacheSize = 512

#We are done
Write-Host "Script Complete"