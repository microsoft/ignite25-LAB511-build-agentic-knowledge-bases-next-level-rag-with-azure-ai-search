# ===========================================
# Download GitHub Repo to Skillable Desktop
# ===========================================

# Set variables
$repoUrl = "https://github.com/microsoft/ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search"
$zipUrl = "$repoUrl/archive/refs/heads/main.zip"
$downloadPath = "$env:USERPROFILE\Desktop\LAB511.zip"
$extractPath = "$env:USERPROFILE\Desktop\LAB511"

# Download the ZIP file from GitHub
Invoke-WebRequest -Uri $zipUrl -OutFile $downloadPath -UseBasicParsing

# Create the target folder if it doesn't exist
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath | Out-Null
}

# Extract the zip file to Desktop
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

Write-Host "Repository downloaded and extracted to: $extractPath"

$clientId = "@lab.CloudSubscription.AppId"
$clientSecret = "@lab.CloudSubscription.AppSecret"
$tenantId = "@lab.CloudSubscription.TenantId"
$subscriptionId = "@lab.CloudSubscription.Id"

az login --service-principal -u $clientId -p $clientSecret --tenant $tenantId --only-show-errors
az account set -s $subscriptionId --only-show-errors

$resourceGroupName = "@lab.CloudResourceGroup(LAB511-ResourceGroup).Name"
$deploymentName = "deployment"

$bicepFilePath = "C:\Users\LabUser\Desktop\LAB511\ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main\infra\LAB511.bicep"

if (-not (Test-Path $bicepFilePath)) {
    throw "Bicep file not found at: $bicepFilePath"
}

az config set core.only_show_errors=yes --only-show-errors
az config set bicep.use_binary_from_path=false --only-show-errors

$labUserUpn = "@lab.CloudPortalCredential(User1).Username"
$labUserObjectId = az ad user show --id $labUserUpn --query id -o tsv

$outs = az deployment group create `
  --name $deploymentName `
  --resource-group $resourceGroupName `
  --template-file $bicepFilePath `
  --parameters labUserObjectId="$labUserObjectId" `
  --only-show-errors `
  --query properties.outputs -o json | ConvertFrom-Json

# Pull values directly from outputs
$storageName            = $outs.storageAccountName.value
$blobEndpoint           = $outs.storageAccountPrimaryEndpoint.value
$containerName          = $outs.documentsContainerName.value
$searchName             = $outs.searchServiceName.value
$searchEndpoint         = $outs.searchServiceEndpoint.value
$openaiName             = $outs.openAiServiceName.value
$openaiEndpoint         = $outs.openAiServiceEndpoint.value
$embeddingDeployment    = $outs.embeddingDeploymentName.value
$chatDeployment         = $outs.gpt5MiniDeploymentName.value

# ===============================
# Fetch secrets (kept out of deployment history)
# ===============================
$searchAdminKey = az rest --method POST `
  --url "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Search/searchServices/$searchName/listAdminKeys?api-version=2023-11-01" `
  --query primaryKey -o tsv

$blobConnectionString = az storage account show-connection-string -n $storageName -g $resourceGroupName -o tsv
$openaiKey            = az cognitiveservices account keys list -g $resourceGroupName -n $openaiName --query key1 -o tsv

# ===============================
# Run setup with output values
# ===============================

$localInfraPath = "C:\Users\LabUser\Desktop\LAB511\ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main\infra"
$setupLocal = Join-Path $localInfraPath "setup-knowledge.ps1"

if (-not (Test-Path $setupLocal)) {
    throw "Setup file not found at: $setupLocal"
}

$docsPath = "C:\Users\LabUser\Desktop\LAB511\ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main\data\ai-search-data"

[Environment]::SetEnvironmentVariable("LOCAL_DOCS_PATH", $docsPath, "Process")

powershell -ExecutionPolicy Bypass -File $setupLocal `
  -SearchEndpoint $searchEndpoint `
  -SearchAdminKey $searchAdminKey `
  -OpenAIEndpoint $openaiEndpoint `
  -OpenAIKey $openaiKey `
  -BlobConnectionString $blobConnectionString `
  -BlobContainerName $containerName `
  -EmbeddingDeployment $embeddingDeployment `
  -ChatDeployment $chatDeployment `
  -KnowledgeSourceName "blob-knowledge-source" `
  -KnowledgeAgentName "blob-knowledge-agent" `
  -UseVerbalization "false"