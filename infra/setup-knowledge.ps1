param(
  [Parameter(Mandatory=$true)][string]$SearchEndpoint,
  [Parameter(Mandatory=$true)][string]$SearchAdminKey,
  [Parameter(Mandatory=$true)][string]$OpenAIEndpoint,
  [Parameter(Mandatory=$true)][string]$OpenAIKey,
  [Parameter(Mandatory=$true)][string]$BlobConnectionString,
  [string]$BlobContainerName = "documents",
  [string]$EmbeddingDeployment = "text-embedding-3-large",
  [string]$ChatDeployment = "gpt-5-mini",
  [string]$KnowledgeAgentName = "knowledge-base",
  [ValidateSet("true","false")][string]$UseVerbalization = "false"
)

$ErrorActionPreference = "Stop"

$repoRoot = "C:\Users\LabUser\Desktop\LAB511\ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main"
$knowledgeFolder = Join-Path $repoRoot "notebook"
$infraFolder = Join-Path $repoRoot "infra"

# Create .env content
$envContent = @"
AZURE_SEARCH_SERVICE_ENDPOINT=$SearchEndpoint
AZURE_SEARCH_ADMIN_KEY=$SearchAdminKey
BLOB_CONNECTION_STRING=$BlobConnectionString
BLOB_CONTAINER_NAME=$BlobContainerName
SEARCH_BLOB_DATASOURCE_CONNECTION_STRING=$BlobConnectionString
AZURE_OPENAI_ENDPOINT=$OpenAIEndpoint
AZURE_OPENAI_KEY=$OpenAIKey
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=$EmbeddingDeployment
AZURE_OPENAI_EMBEDDING_MODEL_NAME=text-embedding-3-large
AZURE_OPENAI_CHATGPT_DEPLOYMENT=$ChatDeployment
AZURE_OPENAI_CHATGPT_MODEL_NAME=gpt-5-mini
AZURE_SEARCH_KNOWLEDGE_AGENT=$KnowledgeAgentName
USE_VERBALIZATION=$UseVerbalization
"@

# Write .env to repo root WITHOUT BOM
$envPathRoot = Join-Path $repoRoot ".env"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($envPathRoot, $envContent, $utf8NoBom)
Write-Host "Created .env in repo root"

# # Write .env to notebook folder WITHOUT BOM
# $envPathNotebook = Join-Path $knowledgeFolder ".env"
# [System.IO.File]::WriteAllText($envPathNotebook, $envContent, $utf8NoBom)
# Write-Host "Created .env in notebook folder"

$docsPath = Join-Path $repoRoot "data\ai-search-data"
if (-not (Test-Path $docsPath)) {
    throw "Documents folder not found at $docsPath"
}
Write-Host "Using existing documents at: $docsPath"

[System.Environment]::SetEnvironmentVariable("LOCAL_DOCS_PATH", $docsPath, "Process")

$reqLocal = Join-Path $knowledgeFolder "requirements.txt"
if (-not (Test-Path $reqLocal)) { 
    throw "requirements.txt not found at $reqLocal" 
}

$pyLocal = Join-Path $infraFolder "create-knowledge.py"
if (-not (Test-Path $pyLocal)) { 
    throw "create-knowledge.py not found at $pyLocal" 
}

# Change to repo root (where .env and .venv will be)
Push-Location $repoRoot

$pythonCmd = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonCmd) { $pythonCmd = (Get-Command py -ErrorAction SilentlyContinue) }
if (-not $pythonCmd) { throw "Python 3.10+ is required." }

# Create venv in repo root
if (-not (Test-Path ".venv")) {
    Write-Host "Creating Python virtual environment in repo root..."
    python -m venv .venv
}

$venvPy = Join-Path $repoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $venvPy)) { throw "Venv python not found at $venvPy" }

Write-Host "Installing Python dependencies..."
& $venvPy -m pip install --upgrade pip --no-python-version-warning
& $venvPy -m pip install -r $reqLocal --no-cache-dir --disable-pip-version-check

Write-Host "Uploading documents to blob storage..."
& $venvPy $pyLocal

Pop-Location

Write-Host ""
Write-Host "Setup completed successfully!"
Write-Host "Environment files created. Documents uploaded to blob storage."
Write-Host "Next: Open the notebook to create Knowledge Source and Knowledge Base."
