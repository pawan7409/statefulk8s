# Authenticate to Azure
$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection"
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
    "Logging in to Azure..."
    
      -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
} catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else {
        $ErrorMessage = "Could not authenticate to Azure using $connectionName. Error: $_"
        throw $ErrorMessage
    }
}

# Define the tags to be applied
$tags = @{
    "Environment" = "Production"
    "Owner" = "Admin"
}

# Get all resources in a specific resource group (example)
$resourceGroupName = "YourResourceGroupName"
$resources = Get-AzResource -ResourceGroupName $resourceGroupName

# Loop through each resource and apply tags
foreach ($resource in $resources) {
    # Merge existing tags with new tags
    $existingTags = $resource.Tags
    if ($existingTags) {
        $newTags = @{}
        $newTags += $existingTags
        $newTags += $tags
    } else {
        $newTags = $tags
    }
    
    # Apply tags to the resource
    Set-AzResource -ResourceId $resource.ResourceId -Tag $newTags -Force
    Write-Output "Applied tags to resource: $($resource.Name)"
}

Write-Output "Tagging completed."