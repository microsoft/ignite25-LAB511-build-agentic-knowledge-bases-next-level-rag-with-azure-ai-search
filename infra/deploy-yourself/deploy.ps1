param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourcePrefix = "lab511",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2")]
    [string]$SearchServiceSku = "standard",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Standard_LRS", "Standard_GRS", "Standard_RAGRS", "Standard_ZRS")]
    [string]$StorageAccountSku = "Standard_RAGRS",
    
    [Parameter(Mandatory=$false)]
    [int]$EmbeddingModelCapacity = 30,
    
    [Parameter(Mandatory=$false)]
    [int]$Gpt41Capacity = 50,
    
    [Parameter(Mandatory=$false, HelpMessage="Optional tags in 'key=value' format, separated by spaces. E.g. 'env=dev project=lab511'")]
    [string]$Tags = ""
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LAB511 Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✓ Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "✗ Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Install from: https://learn.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Check if logged in to Azure
Write-Host ""
Write-Host "Checking Azure login status..." -ForegroundColor Yellow
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✓ Logged in as: $($account.user.name)" -ForegroundColor Green
    Write-Host "✓ Subscription: $($account.name) ($($account.id))" -ForegroundColor Green
} catch {
    Write-Host "✗ Not logged in to Azure" -ForegroundColor Red
    Write-Host "  Run: az login" -ForegroundColor Yellow
    exit 1
}

# Get user object ID
Write-Host ""
Write-Host "Getting user object ID..." -ForegroundColor Yellow
try {
    $userObjectId = az ad signed-in-user show --query id -o tsv
    Write-Host "✓ User Object ID: $userObjectId" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to get user object ID" -ForegroundColor Red
    exit 1
}

# Create resource group
Write-Host ""
Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Yellow
try {
    $rgExists = az group exists --name $ResourceGroupName
    if ($rgExists -eq "true") {
        Write-Host "✓ Resource group already exists" -ForegroundColor Green
    } else {
        if ($Tags) {
            az group create --name $ResourceGroupName --location $Location --tags $Tags --output none
        } else {
            az group create --name $ResourceGroupName --location $Location --output none
        }
        Write-Host "✓ Resource group created" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Deploy Bicep template
Write-Host ""
Write-Host "Deploying infrastructure (this may take 5-10 minutes)..." -ForegroundColor Yellow
Write-Host "  Resource Prefix: $ResourcePrefix" -ForegroundColor Gray
Write-Host "  Location: $Location" -ForegroundColor Gray
Write-Host "  Search SKU: $SearchServiceSku" -ForegroundColor Gray
Write-Host "  Storage SKU: $StorageAccountSku" -ForegroundColor Gray
Write-Host ""

$bicepFile = Join-Path $PSScriptRoot "..\LAB511.bicep"

try {
    $deployment = az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file $bicepFile `
        --parameters labUserObjectId=$userObjectId `
        --parameters resourcePrefix=$ResourcePrefix `
        --parameters location=$Location `
        --parameters searchServiceSku=$SearchServiceSku `
        --parameters storageAccountSku=$StorageAccountSku `
        --parameters embeddingModelCapacity=$EmbeddingModelCapacity `
        --parameters gpt41Capacity=$Gpt41Capacity `
        --output json | ConvertFrom-Json
    
    Write-Host "✓ Infrastructure deployed successfully!" -ForegroundColor Green
} catch {
    Write-Host "✗ Deployment failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Display outputs
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Run the setup script to configure your environment:" -ForegroundColor White
Write-Host "     .\setup-environment.ps1 -ResourceGroupName '$ResourceGroupName'" -ForegroundColor Gray
Write-Host "    or if you want to use managed identities:" -ForegroundColor White
Write-Host "     .\setup-environment.ps1 -ResourceGroupName '$ResourceGroupName' -Keyless $true" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Open the notebooks folder in VS Code:" -ForegroundColor White
Write-Host "     cd ..\..\notebooks" -ForegroundColor Gray
Write-Host "     code ." -ForegroundColor Gray
Write-Host ""
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "Location: $Location" -ForegroundColor Cyan
Write-Host ""
