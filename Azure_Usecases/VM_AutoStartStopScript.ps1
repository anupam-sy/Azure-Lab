# Function Definition
Function VMAutoStartStop {

	$ResultsArray = @()
	$OutputFile = "VMStatusData" + "_" + (Get-Date -Format "yyyy_MM_dd_HHmm") + ".csv"

	# Get all Available Subscriptions in Selected Tenant
	$Subscriptions = Get-AzSubscription
	
	foreach ($sub in $Subscriptions) {
	
		# Select one subscription at a time
		Write-Output "`n" "Switching to Azure subscription: $($sub.Name)"
		$SubResult = Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
		
		# Get all available resource groups.
		Write-Output "Parsing all available Resource Groups..."
		$ResourceGroups = Get-AzResourceGroup
		
		foreach ($RG in $ResourceGroups) {
			Write-Output ("`n" + "Parsing Resource Group:" + $RG.ResourceGroupName)
			
			# Get all Virtual Machines having defined Tag.
			$Resources = Get-AzResource -ResourceGroupName $RG.ResourceGroupName -ResourceType Microsoft.Compute/virtualMachines -Tag @{CostCenter="FREE"}
			if ($Resources) {
				forEach ($Resource in $Resources) {
					# Write-Output ("Resource Name: " + $Resource.ResourceName + " ID: " +  $Resource.ResourceId + "`n")
					$StatusResult = Get-AzVM -ResourceGroupName $Resource.ResourceGroupName -Name $Resource.ResourceName -Status
					if ($StatusResult.Statuses[1].DisplayStatus -eq "VM deallocated") {
						$VMDetails = [PSCustomObject] @{    
						VirtualMachineName = $Resource.ResourceName
						VMResourceGroup = $Resource.ResourceGroupName
						VMSubscription = $sub
						VMState = "Deallocated"
						Remarks = "[INFO]: VM $($Resource.ResourceName) is already in deallocated state."
						}
						$ResultsArray += $VMDetails					
						Write-Output "VM $($Resource.ResourceName) is already in deallocated state."
					}
					else {
						try {
							$ExecutionResult = Stop-AzVM -ResourceGroupName $Resource.ResourceGroupName -Name $Resource.ResourceName -Force
							if ($ExecutionResult.Status -eq "Succeeded") {
								$VMDetails = [PSCustomObject] @{    
								VirtualMachineName = $Resource.ResourceName
								VMResourceGroup = $Resource.ResourceGroupName
								VMSubscription = $sub
								VMState = "Deallocated"
								Remarks = "[SUCCESS]: VM $($Resource.ResourceName) stopped successfully."
								}
								$ResultsArray += $VMDetails
								Write-Output "[SUCCESS]: VM $($Resource.ResourceName) stopped successfully."
							}
							else {
								$VMDetails = [PSCustomObject] @{    
								VirtualMachineName = $Resource.ResourceName
								VMResourceGroup = $Resource.ResourceGroupName
								VMSubscription = $sub
								VMState = ""
								Remarks = "[ERROR]: VM Status needs to be checked manually."
								}
								$ResultsArray += $VMDetails
								Write-Output "[ERROR]: VM Status needs to be checked manually."
							}
						}
						catch {
							$VMDetails = [PSCustomObject] @{    
							VirtualMachineName = $Resource.ResourceName
							VMResourceGroup = $Resource.ResourceGroupName
							VMSubscription = $sub
							VMState = ""
							Remarks = "[ERROR]: Something went wrong during deallocation of VM $($Resource.ResourceName)."
							}
							$ResultsArray += $VMDetails
							Write-Output "[ERROR]: Something went wrong during deallocation of VM $($Resource.ResourceName)."
						}
					}
				}
			}
			else {
				$VMDetails = [PSCustomObject] @{    
				VirtualMachineName = "NA"
				VMResourceGroup = $RG.ResourceGroupName
				VMSubscription = $sub
				VMState = "NA"
				Remarks = "[INFO]: No Virtual Machine found with Tag {'CostCenter': 'FREE'}."
				}
				$ResultsArray += $VMDetails
				Write-Output "[INFO]: No Virtual Machine found with Tag {'CostCenter': 'FREE'}."
			}
		}
	}
	$ResultsArray | Export-CSV $OutputFile -NoTypeInformation
}

# Function Calling
VMAutoStartStop