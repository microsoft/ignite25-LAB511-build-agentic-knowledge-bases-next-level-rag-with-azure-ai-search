// ===============================================
// Bicep template for LAB565 - Microsoft 365 Copilot Agents
// Creates: Storage Account, AI Search, Search Index, OpenAI Service, Text Embedding Model
// ===============================================

@description('The name prefix for all resources')
param resourcePrefix string = 'lab511'

@description('The location where all resources will be deployed')
param location string = 'eastus'

@description('Storage account SKU')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS'])
param storageAccountSku string = 'Standard_RAGRS'

@description('AI Search service SKU')
@allowed(['basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param searchServiceSku string = 'standard'

@description('OpenAI service SKU')
@allowed(['S0'])
param openAiSku string = 'S0'

@description('Text embedding model name')
@allowed(['text-embedding-3-large'])
param embeddingModelName string = 'text-embedding-3-large'

@description('Text embedding model version')
param embeddingModelVersion string = '1'

@description('Embedding model deployment capacity')
@minValue(1)
@maxValue(200)
param embeddingModelCapacity int = 150

@description('GPT-5 model name')
param gpt5ModelName string = 'gpt-5'

@description('GPT-5 model version')
param gpt5ModelVersion string = '2025-08-07'

@description('GPT-5 deployment capacity')
@minValue(1)
@maxValue(200)
param gpt5Capacity int = 50

@description('GPT-5 mini model name')
param gpt5MiniModelName string = 'gpt-5-mini'

@description('GPT-5 mini model version')
param gpt5MiniModelVersion string = '2025-08-07'

@description('GPT-5 mini deployment capacity')
@minValue(1)
@maxValue(200)
param gpt5MiniCapacity int = 50



// Variables for resource naming and configuration
var uniqueSuffix = uniqueString(resourceGroup().id)
var resourceNames = {
  storageAccount: '${resourcePrefix}st${uniqueSuffix}'
  searchService: '${resourcePrefix}-search-${uniqueSuffix}'
  searchIndex: '${resourcePrefix}-index'
  openAiService: '${resourcePrefix}-openai-${uniqueSuffix}'
  embeddingDeployment: 'text-embedding'
  gpt5Deployment: 'gpt-5'
  gpt5MiniDeployment: 'gpt-5-mini'
}

// Ensure storage account name meets requirements (3-24 chars, lowercase alphanumeric)
var storageAccountName = length(resourceNames.storageAccount) > 24 ? substring(resourceNames.storageAccount, 0, 24) : resourceNames.storageAccount

// ===============================================
// AZURE STORAGE ACCOUNT
// ===============================================

@description('Azure Storage Account for document storage and processing')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    defaultToOAuthAuthentication: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
  }
}

// Create blob service for the storage account
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    isVersioningEnabled: true
  }
}

// Create container for documents
resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'documents'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'Document storage for AI processing'
    }
  }
}

// ===============================================
// AZURE AI SEARCH SERVICE
// ===============================================

@description('Azure AI Search service for vector search and document indexing')
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: resourceNames.searchService
  location: location
  sku: {
    name: searchServiceSku
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    disableLocalAuth: false
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    semanticSearch: 'free'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// ---------------------------------------------------
// Conditional role assignments for the search service (inlined)
// ---------------------------------------------------
// OpenAI host role assignment (scoped to the OpenAI resource group's scope)
resource openAiRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, searchService.name, '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  properties: {
    principalId: searchService.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  }
}

// Storage Blob Data Reader role (scoped to the storage resource group)
resource storageReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, searchService.name, '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  properties: {
    principalId: searchService.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  }
}

// Storage Blob Data Contributor role (scoped to the storage resource group)
resource storageContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().id, searchService.name, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  properties: {
    principalId: searchService.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  }
}

// ===============================================
// AZURE OPENAI SERVICE
// ===============================================

@description('Azure OpenAI service for AI models and embeddings')
resource openAiService 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: resourceNames.openAiService
  location: location
  sku: {
    name: openAiSku
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {
      statisticsEnabled: false
    }
    customSubDomainName: resourceNames.openAiService
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// ===============================================
// TEXT EMBEDDING MODEL DEPLOYMENT
// ===============================================

@description('Text embedding model deployment for vector generation')
resource embeddingModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAiService
  name: resourceNames.embeddingDeployment
  properties: {
    model: {
      format: 'OpenAI'
      name: embeddingModelName
      version: embeddingModelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: embeddingModelCapacity
  }
}

// ===============================================
// GPT-5 MODEL DEPLOYMENT
// ===============================================

@description('GPT-5 model deployment for chat and reasoning')
resource gpt5ModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAiService
  name: resourceNames.gpt5Deployment
  properties: {
    model: {
      format: 'OpenAI'
      name: gpt5ModelName
      version: gpt5ModelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'GlobalStandard'
    capacity: gpt5Capacity
  }
}

// ===============================================
// GPT-5 MINI MODEL DEPLOYMENT
// ===============================================

@description('GPT-5 mini model deployment for lightweight chat tasks')
resource gpt5MiniModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAiService
  name: resourceNames.gpt5MiniDeployment
  properties: {
    model: {
      format: 'OpenAI'
      name: gpt5MiniModelName
      version: gpt5MiniModelVersion
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'GlobalStandard'
    capacity: gpt5MiniCapacity
  }
}

// ===============================================
// OUTPUTS
// ===============================================

@description('Storage account name')
output storageAccountName string = storageAccount.name

@description('Storage account primary endpoint')
output storageAccountPrimaryEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('Documents container name')
output documentsContainerName string = documentsContainer.name

@description('AI Search service name')
output searchServiceName string = searchService.name

@description('AI Search service endpoint')
output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'

@description('OpenAI service name')
output openAiServiceName string = openAiService.name

@description('OpenAI service endpoint')
output openAiServiceEndpoint string = openAiService.properties.endpoint

@description('Text embedding model deployment name')
output embeddingDeploymentName string = embeddingModelDeployment.name

@description('Resource group location')
output resourceGroupLocation string = location

@description('Unique suffix used for resource naming')
output uniqueSuffix string = uniqueSuffix

@description('GPT-5 model deployment name')
output gpt5DeploymentName string = gpt5ModelDeployment.name

@description('GPT-5 mini model deployment name')
output gpt5MiniDeploymentName string = gpt5MiniModelDeployment.name

// ===============================================
// USAGE NOTES
// ===============================================
/*

DEPLOYMENT COMMAND:
# Deploy to an existing resource group
az deployment group create --resource-group <your-existing-rg-name> --template-file LAB565.bicep --parameters resourcePrefix=<your-prefix>

# Example with specific values:
az deployment group create --resource-group rg-copilot-lab --template-file LAB565.bicep --parameters resourcePrefix=mylab565

# To deploy with custom parameters:
az deployment group create --resource-group <your-existing-rg-name> --template-file LAB565.bicep --parameters resourcePrefix=<your-prefix> storageAccountSku=Standard_GRS searchServiceSku=standard embeddingModelName=text-embedding-3-small

*/
