Param (
	[string] $SubscriptionID,
	[string] $ResourceGroupName,
	[string] $AppServiceName,
	[string] $KeyVaultName
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
	UpdateKVFirewall -RGName $ResourceGroupName -KVName $KeyVaultName -OutboundIPs $OutboundIPs
}

# White-list IPs in Key Vault's Firewall
Function UpdateKVFirewall {
	Param (
	[parameter(Mandatory=$True)] [string] $RGName,
	[parameter(Mandatory=$True)] [string] $KVName,
	[parameter(Mandatory=$True)] [string] $OutboundIPs
	)
	
	try {
	Update-AzKeyVaultNetworkRuleSet -DefaultAction Deny -VaultName $KVName
	
	foreach ($IP in $OutboundIPs.split(",")) {
		Write-Host Adding $IP
		Add-AzKeyVaultNetworkRule -VaultName $KVName -ResourceGroupName $RGName -IpAddressRange $IP -DefaultAction Allow
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
$ExecutionParamters.Add("KeyVaultName", $KeyVaultName)

ParamaterValidation -ExecutionParamters $ExecutionParamters
#LoginToAzure
GetOutboundIPs -RGName $ResourceGroupName -AppName $AppServiceName


