#KEVIN PAPRECK - UNOFFICIAL SCRIPT FOR CALCULATING SOLIDFIRE EFFICIENCIES

#       ====================================================================
#       Disclaimer: This script is written as best effort and provides no
#       warranty expressed or implied. Please contact the author(s) if you
#       have questions about this script before running or modifying
#       ====================================================================

#EFFICIENCY CALCULATIONS
#thinProvisioningFactor = (nonZeroBlocks + zeroBlocks) / nonZeroBlocks
#deDuplicationFactor = (nonZeroBlocks+snapshotNonZeroBlocks) / uniqueBlocks
#compressionFactor = (uniqueBlocks * 4096) / (uniqueBlocksUsedSpace*.93)

#REQUIRED INPUTS
$nonZeroBlocks = get-sfclustercapacity | select nonZeroBlocks -ExpandProperty nonZeroBlocks
$zeroBlocks = get-sfclustercapacity | select zeroBlocks -ExpandProperty zeroBlocks
$uniqueBlocks = get-sfclustercapacity | select uniqueBlocks -ExpandProperty uniqueBlocks
$uniqueBlocksUsedSpace = get-sfclustercapacity | select uniqueBlocksUsedSpace -ExpandProperty uniqueBlocksUsedSpace
$snapshotNonZeroBlocks = get-sfclustercapacity | select snapshotNonZeroBlocks -ExpandProperty snapshotNonZeroBlocks

#EFFICIENCY CALCULATIONS
[single]$thinProvisioningFactor = (($nonZeroBlocks+$zeroBlocks)/$nonZeroBlocks)
[single]$deDuplicationFactor = (($nonZeroBlocks+$snapshotNonZeroBlocks)/$uniqueBlocks)
[single]$compressionFactor = (($uniqueBlocks*4096)/($uniqueBlocksUsedSpace*.93))

#FOR DEBUGGING
#echo $thinProvisioningFactor
#echo $deDuplicationFactor
#echo $compressionFactor

#CALCULATE EFFICIENCY FACTOR FOR COMPRESSION + DEDUPLICATION ONLY
$efficiencyFactor = ($deDuplicationFactor*$compressionFactor)

#CALCULATE FULL EFFICIENCY FACTOR FOR COMPRESSION + DEDUPLICATION + THIN PROVISIONING
$efficiencyFullFactor = ($deDuplicationFactor*$compressionFactor*$thinProvisioningFactor)

#GET THE CLUSTER ERROR THRESHOLD BYTES
$errorThreshold = get-sfclusterfullthreshold | select stage4BlockThresholdBytes -ExpandProperty Stage4BlockThresholdBytes
$errorThresholdTB = ($errorThreshold/1000/1000/1000/1000)

#GET THE TOTAL USED RAW CAPACITY
$sumUsedCapacity = get-sfclusterfullthreshold | select sumUsedClusterBytes -ExpandProperty sumUsedClusterBytes
$sumUsed = ($sumUsedCapacity/1000/1000/1000/1000)

#DETERMINE THE RAW SPACE AVAILABLE ON THE CLUSTER UNTIL ERROR THRESHOLD
$rawSpaceAvailableTB = (($errorThreshold-$sumUsedCapacity)/(1000*1000*1000*1000))

#DETERMINE THE RAW SPACE AVAILABLE ON THE CLUSTER UNTIL 100% FULL
$stage5BlockThresholdBytes = get-sfclusterfullthreshold | select stage5BlockThresholdBytes -ExpandProperty stage5BlockThresholdBytes
$rawSpaceAvailable100TB = (($stage5BlockThresholdBytes-$sumUsedCapacity)/(1000*1000*1000*1000))

#GET TOTAL CLUSTER CAPCITY
$sumTotalClusterBytes = get-sfclusterfullthreshold | select sumTotalClusterBytes -ExpandProperty sumTotalClusterBytes
$sumTotalClusterBytes = ($sumTotalClusterBytes/1000/1000/1000/1000)

#GET CLUSTER FULL EFFECTIVE
$sumClusterFulldc = ($sumTotalClusterBytes*$efficiencyFactor)/2
$sumClusterFulldct = ($sumTotalClusterBytes*$efficiencyFullFactor)/2

#GET THE EFFECTIVE CAPACITY REMAINING OF COMPRESSION + DEDUPLICATION UNTIL ERROR THRESHOLD
$effectiveCapacityRemaining = ($rawSpaceAvailableTB*$efficiencyFactor)/2

#GET THE EFFECTIVE CAPACITY OF COMPRESSION + DEDUPLICATION + THIN PROVISIONING UNTIL ERROR THRESHOLD
$effectiveFullCapacityRemaining = ($rawSpaceAvailableTB*$efficiencyFullFactor)/2

#GET THE EFFECTIVE CAPACITY REMAINING OF COMPRESSION + DEDUPLICATION UNTIL 100% FULL
$effectiveCapacityRemaining100 = ((($stage5BlockThresholdBytes-$sumUsedCapacity)*$efficiencyFactor)/(1000*1000*1000*1000))/2

#GET CLUSTER NAME
$clusterName = get-sfClusterInfo | select name -ExpandProperty name

#FORMAT TO 2 DECIMALS
$efficiencyFactor = "{0:N2}" -f $efficiencyFactor
$efficiencyFullFactor = "{0:N2}" -f $efficiencyFullFactor
$rawSpaceAvailableTB = "{0:N2}" -f $rawSpaceAvailableTB
$effectiveCapacity = "{0:N2}" -f $effectiveCapacity
$sumTotalClusterBytes = "{0:N2}" -f $sumTotalClusterBytes
$effectiveCapacityRemaining = "{0:N2}" -f $effectiveCapacityRemaining
$sumClusterFulldc = "{0:N2}" -f $sumClusterFulldc
$sumClusterFulldct = "{0:N2}" -f $sumClusterFulldct
$effectiveCapacityRemaining100 = "{0:N2}" -f $effectiveCapacityRemaining100
$sumUsed = "{0:N2}" -f $sumUsed
$errorThresholdTB = "{0:N2}" -f $errorThresholdTB
$compressionFactor = "{0:N2}" -f $compressionFactor
$deDuplicationFactor = "{0:N2}" -f $deDuplicationFactor
$thinProvisioningFactor = "{0:N2}" -f $thinProvisioningFactor
$rawSpaceAvailable100TB = "{0:N2}" -f $rawSpaceAvailable100TB

Write-Host "--------------------------------------------------------------------------------------------------------------"
Write-Host "SolidFire Cluster: $clusterName"
Write-Host ""
Write-Host "Cluster RAW Capacity: $sumTotalClusterBytes TB"
Write-Host "Cluster RAW Capacity Error Stage: $errorThresholdTB TB"
Write-Host "Cluster RAW Capacity Used: $sumUsed"
Write-Host "Cluster Error Stage RAW TB Remaining Available: $rawSpaceAvailableTB TB"
Write-Host "Cluster 100% Full RAW TB Remaining Available: $rawSpaceAvailable100TB TB"

Write-Host ""
Write-Host "Cluster Efficiencies"
Write-Host "Thin Provisioning Ratio: $thinProvisioningFactor"
Write-Host "Deduplication Ratio: $deDuplicationFactor"
Write-Host "Compression Ratio: $compressionFactor"
Write-Host "Cluster Deduplication/Compression Efficiency: $efficiencyFactor"
Write-host "Cluster Deduplication/Compression/Thin Provisioning Efficiency: $efficiencyFullFactor"
Write-Host ""
Write-Host "Cluster Capacity"
Write-Host "Cluster Effective Capacity @ 100% Full with Dedup/Comp: $sumClusterFulldc TB"
Write-Host "Cluster Effective Capacity @ 100% Full with Dedup/Comp/Thin: $sumClusterFulldct TB"
Write-Host "Effective Capacity Remaining until 100% Full with Dedup/Comp: $effectiveCapacityRemaining100 TB"
Write-Host "Effective Capacity Remaining until Error Threshold with Dedup/Comp: $effectiveCapacityRemaining TB"

Write-Host "--------------------------------------------------------------------------------------------------------------"
