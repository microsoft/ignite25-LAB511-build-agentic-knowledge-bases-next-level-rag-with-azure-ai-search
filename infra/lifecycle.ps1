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

# ===========================================
# Run Bicep Deployment and Provision Resources
# ===========================================

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

az deployment group create `
  --name $deploymentName `
  --resource-group $resourceGroupName `
  --template-file $bicepFilePath `
  --parameters labUserObjectId="$labUserObjectId" `
  --only-show-errors

# ===========================================
# Setup and Create Knowledge Store
# ===========================================

$storage = az resource list -g $resourceGroupName --resource-type "Microsoft.Storage/storageAccounts" -o json | ConvertFrom-Json | Select-Object -First 1
if (-not $storage) { throw "No Storage account found in $resourceGroupName." }
$storageName = $storage.name

$search = az resource list -g $resourceGroupName --resource-type "Microsoft.Search/searchServices" -o json | ConvertFrom-Json | Select-Object -First 1
if (-not $search) { throw "No Azure AI Search service found in $resourceGroupName." }
$searchName = $search.name

$openai = az resource list -g $resourceGroupName --resource-type "Microsoft.CognitiveServices/accounts" -o json `
  | ConvertFrom-Json | Where-Object { $_.kind -match "OpenAI" } | Select-Object -First 1
if (-not $openai) { throw "No Azure OpenAI account found in $resourceGroupName." }
$openaiName = $openai.name

$searchRes = az resource show -g $resourceGroupName -n $searchName --resource-type "Microsoft.Search/searchServices" -o json | ConvertFrom-Json
$searchHost = $searchRes.properties.hostname
if (-not $searchHost) { $searchHost = "$searchName.search.windows.net" }
$searchEndpoint = "https://$searchHost"

$searchAdminKey = az rest --method POST `
  --url "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Search/searchServices/$searchName/listAdminKeys?api-version=2023-11-01" `
  --query primaryKey -o tsv

$blobConnectionString = az storage account show-connection-string -n $storageName -g $resourceGroupName -o tsv

$openaiJson = az cognitiveservices account show -g $resourceGroupName -n $openaiName -o json | ConvertFrom-Json
$openaiEndpoint = $openaiJson.properties.endpoint
$openaiKey = az cognitiveservices account keys list -g $resourceGroupName -n $openaiName --query key1 -o tsv

$deployments = az cognitiveservices account deployment list -g $resourceGroupName -n $openaiName -o json | ConvertFrom-Json
$embeddingDeployment = ($deployments | Where-Object { $_.model.name -eq "text-embedding-3-large" } | Select-Object -First 1).name
if (-not $embeddingDeployment) { $embeddingDeployment = "text-embedding-3-large" }

$chatDeployment = ($deployments | Where-Object { $_.model.name -eq "gpt-5-mini" } | Select-Object -First 1).name
if (-not $chatDeployment) { $chatDeployment = "gpt-5-mini" }

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
  -BlobContainerName "documents" `
  -EmbeddingDeployment $embeddingDeployment `
  -ChatDeployment $chatDeployment `
  -KnowledgeSourceName "blob-knowledge-source" `
  -KnowledgeAgentName "blob-knowledge-agent" `
  -UseVerbalization "false"

Write-Host "Done."