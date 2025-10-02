param(
  [Parameter(Mandatory=$true)][string]$SearchEndpoint,
  [Parameter(Mandatory=$true)][string]$SearchAdminKey,
  [Parameter(Mandatory=$true)][string]$OpenAIEndpoint,
  [Parameter(Mandatory=$true)][string]$OpenAIKey,
  [Parameter(Mandatory=$true)][string]$BlobConnectionString,

  [string]$BlobContainerName = "documents",
  [string]$EmbeddingDeployment = "text-embedding-3-large",
  [string]$ChatDeployment = "gpt-5",
  [string]$KnowledgeSourceName = "blob-knowledge-source",
  [string]$KnowledgeAgentName  = "blob-knowledge-agent",
  [ValidateSet("true","false")][string]$UseVerbalization = "false",

  # optional: used to place a few PDFs
  [string]$RepoZipUrl = ""
)

$ErrorActionPreference = "Stop"

$workRoot        = "$env:USERPROFILE\Desktop\Lab511"
$knowledgeFolder = Join-Path $workRoot "knowledge"
New-Item -ItemType Directory -Force -Path $workRoot,$knowledgeFolder | Out-Null

# Write .env for notebook + helper
$envPath = Join-Path $knowledgeFolder ".env"
@"
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
AZURE_OPENAI_CHATGPT_MODEL_NAME=gpt-5

AZURE_SEARCH_KNOWLEDGE_SOURCE=$KnowledgeSourceName
AZURE_SEARCH_KNOWLEDGE_AGENT=$KnowledgeAgentName
USE_VERBALIZATION=$UseVerbalization
"@ | Set-Content -Path $envPath -Encoding UTF8

# Optional: pull sample docs and upload via Storage SDK is handled by Python helper (container creation).
if ($RepoZipUrl) {
  try {
    $repoZip = Join-Path $workRoot "repo.zip"
    Invoke-WebRequest -Uri $RepoZipUrl -OutFile $repoZip -UseBasicParsing
    Expand-Archive -Path $repoZip -DestinationPath $workRoot -Force
    Remove-Item $repoZip -Force
  } catch { Write-Warning "Repo download skipped: $($_.Exception.Message)" }
}

# Prepare Python venv and run helper
$reqLocal = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "requirements.txt"
$pyLocal  = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "create_knowledge.py"

Push-Location $knowledgeFolder

$pythonCmd = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonCmd) { $pythonCmd = (Get-Command py -ErrorAction SilentlyContinue) }
if (-not $pythonCmd) { throw "Python 3.10+ is required." }

python -m venv .venv
$venvPy = Join-Path $knowledgeFolder ".venv\Scripts\python.exe"
& $venvPy -m pip install --upgrade pip
& $venvPy -m pip install -r $reqLocal

# Run: creates/updates Knowledge Source + Agent
& $venvPy $pyLocal

Pop-Location

Write-Host "`n✅ Created/updated Knowledge Source '$KnowledgeSourceName' and Agent '$KnowledgeAgentName'."
Write-Host "Notebook is ready to use the .env in $knowledgeFolder."
