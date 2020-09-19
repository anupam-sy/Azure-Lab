$Subscriptions = Get-AzSubscription
foreach ($sub in $Subscriptions) {
    Write-Output "Switching to Azure subscription: $($sub.Name)"
    Get-AzSubscription -SubscriptionName $sub.Name | Set-AzContext
    Write-Output "List of available Resource Groups:"
    $ResourceGroups = Get-AzResourceGroup
    foreach ($RG in $ResourceGroups) {
        Write-Output $RG.ResourceGroupName
        Write-Output ("Showing resources in Resource Group:" + $RG.ResourceGroupName)
        $Resources = Get-AzResource -ResourceGroupName $RG.ResourceGroupName | Select ResourceName, ResourceType
        forEach ($Resource in $Resources) {
        Write-Output ($Resource.ResourceName + " of type " +  $Resource.ResourceType)
        }
    }
}