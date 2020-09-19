Param (
	[string] $SubscriptionID,
	[string] $ResourceGroupName,
	[string] $AppServiceName,
	[string] $StorageName
)

# Connect to Azure Account and Set Context
Function LoginToAzure {
	# Connect-AzAccount
	Set-AzContext -SubscriptionId $SubID
}
# Set Azure Context
Function ParamaterValidation {
	Param (
	[parameter(Mandatory=$True)] [hashtable] $ExecutionParamters
	)
	
	foreach ($key in $ExecutionParamters.keys) {
		if ($ExecutionParamters[$key] -eq "") {
			write-host ("Missing Parameter " + $key)
			exit
		}
	}
}

# Get All Outbound IPs of App Service
Function GetOutboundIPs {
	Param (
	[parameter(Mandatory=$True)] [string] $RGName,
	[parameter(Mandatory=$True)] [string] $AppName
	)
	
	$OutboundIPs = (Get-AzWebApp -ResourceGroup $RGName -name $AppName).PossibleOutboundIpAddresses
	UpdateStorageFirewall -RGName $ResourceGroupName -StorageName $StorageName -OutboundIPs $OutboundIPs
}

# White-list IPs in Storage Account's Firewall
Function UpdateStorageFirewall {
	Param (
	[parameter(Mandatory=$True)] [string] $RGName,
	[parameter(Mandatory=$True)] [string] $StorageName,
	[parameter(Mandatory=$True)] [string] $OutboundIPs
	)
	
	try {
		Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $RGName -AccountName $StorageName -DefaultAction 0
		
		foreach ($IP in $OutboundIPs.split(",")) {
			Write-Host ("White-listing IP - " + $IP)
			$result = Add-AzStorageAccountNetworkRule -ResourceGroupName $RGName -Name $StorageName -IPAddressOrRange $IP
			Write-Host $result.Action
			}
			
		Write-Host "[Success]: All IPs white-listed successfully."
	}
	catch {
		Write-Host "[Error]: An error occured, check the possible causes."
	}
}

# Function Calling
$ExecutionParamters = @{}
$ExecutionParamters.Add("SubscriptionID", $SubscriptionID)
$ExecutionParamters.Add("ResourceGroupName", $ResourceGroupName)
$ExecutionParamters.Add("AppServiceName", $AppServiceName)
$ExecutionParamters.Add("StorageName", $StorageName)

ParamaterValidation -ExecutionParamters $ExecutionParamters
#LoginToAzure
GetOutboundIPs -RGName $ResourceGroupName -AppName $AppServiceName


