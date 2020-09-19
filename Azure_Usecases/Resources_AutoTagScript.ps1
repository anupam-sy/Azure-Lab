# Function Definition
Function ResourceAutoTag {

    $RequiredTagArray = @("Project", "CostCenter")

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

            # Get Resource Group Tags
            $RgData = Get-AzResourceGroup -ResourceGroupName $RG.ResourceGroupName

            $flag = $true

            # Check availability of all required tags in RG
            foreach ($Key in $RequiredTagArray) {
                if ($($Key -in $RgData.Tags.Keys) -and $($($RgData.Tags[$Key]) -ne "")){ 
		            # Write-Output "Tag $Key found."
	            }
	            else {
		            Write-Output "RG doesn't have all the required tags."
                    $flag = $false
                    break
	            }
            }

            if ($flag -eq $true) {

        	    $Resources = Get-AzResource -ResourceGroupName $RG.ResourceGroupName
			    if ($Resources) {

                    # Parsing all available Resources
				    forEach ($Resource in $Resources) {

                        Write-Output "Tagging Validation is in Progress for $($Resource.ResourceName)"
                        foreach ($Key in $RequiredTagArray) {
                            if ($($Key -in $Resource.Tags.Keys) -and $($($Resource.Tags[$Key]) -ne "")){ 
		                        # Write-Output "Tag $Key found."
	                        }
	                        else{
		                        Write-Output "Tag $Key missed or Its value is null. Updating Tag..."
                                Update-AzTag -ResourceId $Resource.ResourceId -Tag @{$Key=$($RgData.Tags[$Key])} -Operation Merge 
	                        }
                        }


                    }

    		    }
            }
        }
    }
}

# Function Calling
ResourceAutoTag