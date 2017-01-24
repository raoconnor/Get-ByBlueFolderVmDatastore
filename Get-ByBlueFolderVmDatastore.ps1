
<# 
Get-ByBlueFolderVmDatastore.ps1

.Description
    Get the names of the edge devices using a vxlan
	usefull when removing dhcp assignments
	russ 25/01/2016
	
.Acknowledgments 

    
.Example
    ./Get-ByBlueFolderVmDatastore.ps1
#>


Get-folder

# Choose folder
Get-folder

Write-host "`n" 
	Write-host "To run on all vms in a blue folder, enter folder name"  "`n"  -ForegroundColor White 	
	$choice = Read-Host " "
	Try
	{
	$f = Get-Folder "$choice"  
	}
	
	Catch
	{
	Write-Warning "You must enter the folder name or run with the -VM <vm name> switch..!"
	Break
	}

# Identify the containing folder and add to variable
$folder = (Get-Folder $f | Get-View)
	
# Collect vms the in blue folder
$vms = Get-View -SearchRoot $folder.MoRef -ViewType "VirtualMachine" | Select Name

# Create empty results array to hold values
$resultsarray =@()

foreach ( $vm in $vms ){ 
	$ds = Get-Datastore -RelatedObject $vm.Name
	$vmhost = Get-vm $vm.Name | Select Host
	$dsId = $ds.ExtensionData.Info.Vmfs.Extent.DiskName
	
		write-output "$($vm.Name), $($vmhost.Host.Name), $($ds.Name), $($ds.ExtensionData.Info.Vmfs.Extent.DiskName)"
		
		# Create an array object to hold results, and add data as attributes using the add-member commandlet
		$resultObject = new-object PSObject
		$resultObject | add-member -membertype NoteProperty -name "vm" -Value $vm.Name
		$resultObject | add-member -membertype NoteProperty -name "host" -Value $vmhost.Host.Name
		$resultObject | add-member -membertype NoteProperty -name "datastore" -Value $ds.Name
		$resultObject | add-member -membertype NoteProperty -name "canonical name" -Value $ds.ExtensionData.Info.Vmfs.Extent.DiskName
	
	    # Write array output to results 
		$resultsarray += $resultObject
		}
		
# output to gridview
$resultsarray | Out-GridView
		