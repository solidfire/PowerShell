$vms = Get-VM VMAPP-DB05

foreach ($vm in $vms){
    $policy = "AppSrvOS"

    $target = Get-SpbmStoragePolicy $policy | Get-SpbmCompatibleStorage
    Move-VM $vm -Datastore $target

    $configurations = Get-SpbmEntityConfiguration -VM $vm -HardDisk ($vm | Get-HardDisk)

    Set-SpbmEntityConfiguration -Configuration $configurations -StoragePolicy (Get-SpbmStoragePolicy $policy)
}

