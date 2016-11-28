$vms = Get-VM VMAPP-DB04

foreach($vm in $vms){

$configurations = Get-SpbmEntityConfiguration -VM $vm -HardDisk ($vm | Get-HardDisk)

foreach($configuration in $configurations){
    
$config = $configuration.Entity

switch ($config)
    { 
        "Hard Disk 1" {$policy = "AppSrvOS"} 
        "Hard Disk 2" {$policy = "AppSrvLog"} 
        "Hard Disk 3" {$policy = "AppSrvDBHigh"}
        $vm {$policy = "AppSrvOS"}
    }
Set-SpbmEntityConfiguration -Configuration $configuration -StoragePolicy (Get-SpbmStoragePolicy $policy)
Write-Host $policy was set for $config
}
}