#Identify the Master Node in the Cluster
Get-SFClusterMasterNodeID

#Get Name and info about the Cluster Master Node
Get-SFClusterMasterNodeID | Get-SFNode

#Get Listing of all of the Nodes
Get-SFNode

#List Nodes and software version
Get-SFNode | Select Name, NodeID, SoftwareVersion

#Get platform info for a single node
$node = Get-SFNode | Select -first 1
$node.PlatformInfo | fl

