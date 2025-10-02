param(
  [Parameter(Mandatory=$true)][string]$SearchEndpoint,
  [Parameter(Mandatory=$true)][string]$SearchAdminKey,
  [Parameter(Mandatory=$true)][string]$OpenAIEndpoint,
  [Parameter(Mandatory=$true)][string]$OpenAIKey,
  [Parameter(Mandatory=$true)][string]$BlobConnectionString,

  [string]$BlobContainerName = "documents",
  [string]$EmbeddingDeployment = "text-embedding-3-large",
  [string]$ChatDeployment = "gpt-5-mini",                 # ✅ updated default
  [string]$KnowledgeSourceName = "blob-knowledge-source",
  [string]$KnowledgeAgentName  = "blob-knowledge-agent",
  [ValidateSet("true","false")][string]$UseVerbalization = "false"
)

$ErrorActionPreference = "Stop"

$workRoot        = "$env:USERPROFILE\Desktop\LAB511"
$knowledgeFolder = Join-Path $workRoot "notebook"
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
AZURE_OPENAI_CHATGPT_MODEL_NAME=gpt-5-mini                 # ✅ match deployment

AZURE_SEARCH_KNOWLEDGE_SOURCE=$KnowledgeSourceName
AZURE_SEARCH_KNOWLEDGE_AGENT=$KnowledgeAgentName
USE_VERBALIZATION=$UseVerbalization
"@ | Set-Content -Path $envPath -Encoding UTF8

# Path to the existing documents folder
$docsPath = "C:\LAB511\data\ai-search-data"
if (-not (Test-Path $docsPath)) {
    throw "❌ Documents folder not found at $docsPath. Please check the path."
}
Write-Host "✅ Using existing documents at: $docsPath"

# Pass to Python as env var
[System.Environment]::SetEnvironmentVariable("LOCAL_DOCS_PATH", $docsPath, "Process")

# Prepare Python venv and run helper
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$reqLocal  = Join-Path $scriptDir "requirements.txt"
$pyLocal   = Join-Path $scriptDir "create_knowledge.py"

if (-not (Test-Path $reqLocal)) { throw "requirements.txt not found at $reqLocal" }
if (-not (Test-Path $pyLocal))  { throw "create_knowledge.py not found at $pyLocal" }

Push-Location $knowledgeFolder

$pythonCmd = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pythonCmd) { $pythonCmd = (Get-Command py -ErrorAction SilentlyContinue) }
if (-not $pythonCmd) { throw "Python 3.10+ is required." }

python -m venv .venv
$venvPy = Join-Path $knowledgeFolder ".venv\Scripts\python.exe"
if (-not (Test-Path $venvPy)) { throw "Venv python not found at $venvPy" }

& $venvPy -m pip install --upgrade pip --no-python-version-warning
& $venvPy -m pip install -r $reqLocal --no-cache-dir --disable-pip-version-check

# Run the Python helper (creates/updates Knowledge Source + Agent)
& $venvPy $pyLocal

Pop-Location

Write-Host "`n✅ Knowledge Source '$KnowledgeSourceName' and Agent '$KnowledgeAgentName' created/updated successfully."
Write-Host "📁 Notebook is ready. Env file: $knowledgeFolder\.env"
