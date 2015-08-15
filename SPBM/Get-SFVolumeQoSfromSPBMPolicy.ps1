Function Get-SFVolumeQoSfromSPBMPolicy{
<#
    .Synopsis
	
 	 Creates a QoS profile based on values related to a SPBM policy name.
	 
	.Description 
	 Creates a QoS profile based on values related to a SPBM policy name.
     Splits name at '-' and pulls values when the policy name is formatted
     <Attribute>-Min-Max-Burst | Oracle-500-3K-5K

     Returns an object containing the QoS values and Attributes
	 
	.Parameter Policy
	
	 Represents a VMware SPBM policy object.
	 
	.Example
	
	 Get-SpbmStoragePolicy "Oracle-5K-10K-15K" | Get-SFVolumeQoSfromSPBMPolicy

     Returns an object that has the QoS values split out.
	 
	.Link
	 http://www.github.com/solidfire/powershell
	 
	.Notes
	
	====================================================================
	Disclaimer: This script is written as best effort and provides no 
	warranty expressed or implied. Please contact the author(s) if you 
	have questions about this script before running or modifying
	====================================================================
#>
[CmdletBinding(ConfirmImpact="Low")]
param(
		[Parameter(
        ValueFromPipeline=$true,
        Position=0,
        Mandatory=$True,
        HelpMessage="Enter the VMware Storage Policy name.")]
        #[VimAutomation.Storage.Impl.V1.Spbm.SpbmStoragePolicyImpl[]]
        $Policy
)

# Runs Once
BEGIN {
$result = @()
}

# Runs one time for every object piped in
PROCESS {

$row = "" | Select Workload,Min,Max,Burst
$row.Workload = ($policy.Name.Split("-")[0])
$row.Min = ($policy.Name.Split("-")[1]).Replace("K","000")
$row.Max = ($policy.Name.Split("-")[2]).Replace("K","000")
$row.Burst = ($policy.Name.Split("-")[3]).Replace("K","000")

$result += $row
}

# Runs once
END {
$result
}

}