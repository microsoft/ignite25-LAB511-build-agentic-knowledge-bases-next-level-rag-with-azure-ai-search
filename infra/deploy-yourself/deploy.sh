set -e

# Default values
RESOURCE_GROUP=""
LOCATION=""
RESOURCE_PREFIX="lab511"
SEARCH_SKU="standard"
STORAGE_SKU="Standard_RAGRS"
EMBEDDING_CAPACITY=30
GPT41_CAPACITY=50
TAGS=""

# Parse command line arguments
while getopts "g:l:p:s:t:T:h" opt; do
  case $opt in
    g) RESOURCE_GROUP="$OPTARG" ;;
    l) LOCATION="$OPTARG" ;;
    p) RESOURCE_PREFIX="$OPTARG" ;;
    s) SEARCH_SKU="$OPTARG" ;;
    t) STORAGE_SKU="$OPTARG" ;;
    T) TAGS="$OPTARG" ;;
    h)
      echo "Usage: $0 -g <resource-group> -l <location> [-p <prefix>] [-s <search-sku>] [-t <storage-sku>] [-T <tags>]"
      echo ""
      echo "Required:"
      echo "  -g  Resource group name"
      echo "  -l  Azure location (e.g., westcentralus)"
      echo ""
      echo "Optional:"
      echo "  -p  Resource prefix (default: lab511)"
      echo "  -s  Search service SKU (default: standard)"
      echo "  -t  Storage account SKU (default: Standard_RAGRS)"
      echo "  -T  Space formatted tags for resource group (e.g., 'env=dev project=lab511')"
      echo "  -h  Show this help message"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$RESOURCE_GROUP" ] || [ -z "$LOCATION" ]; then
  echo "Error: Resource group (-g) and location (-l) are required"
  echo "Use -h for help"
  exit 1
fi

echo "========================================"
echo "LAB511 Infrastructure Deployment"
echo "========================================"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "✗ Azure CLI is not installed"
    echo "  Install from: https://learn.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
echo "✓ Azure CLI version: $AZ_VERSION"

# Check if logged in to Azure
echo ""
echo "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo "✗ Not logged in to Azure"
    echo "  Run: az login"
    exit 1
fi

ACCOUNT_NAME=$(az account show --query name -o tsv)
ACCOUNT_ID=$(az account show --query id -o tsv)
USER_NAME=$(az account show --query user.name -o tsv)

echo "✓ Logged in as: $USER_NAME"
echo "✓ Subscription: $ACCOUNT_NAME ($ACCOUNT_ID)"

# Get user object ID
echo ""
echo "Getting user object ID..."
USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
echo "✓ User Object ID: $USER_OBJECT_ID"

# Create resource group
echo ""
echo "Creating resource group: $RESOURCE_GROUP"
if az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
    echo "✓ Resource group already exists"
else
    if [ -n "$TAGS" ]; then
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --tags "$TAGS" --output none
    else
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
    fi
    echo "✓ Resource group created"
fi

# Deploy Bicep template
echo ""
echo "Deploying infrastructure (this may take 5-10 minutes)..."
echo "  Resource Prefix: $RESOURCE_PREFIX"
echo "  Location: $LOCATION"
echo "  Search SKU: $SEARCH_SKU"
echo "  Storage SKU: $STORAGE_SKU"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BICEP_FILE="$SCRIPT_DIR/../LAB511.bicep"

az deployment group create \
    --resource-group "$RESOURCE_GROUP" \
    --template-file "$BICEP_FILE" \
    --parameters labUserObjectId="$USER_OBJECT_ID" \
    --parameters resourcePrefix="$RESOURCE_PREFIX" \
    --parameters location="$LOCATION" \
    --parameters searchServiceSku="$SEARCH_SKU" \
    --parameters storageAccountSku="$STORAGE_SKU" \
    --parameters embeddingModelCapacity=$EMBEDDING_CAPACITY \
    --parameters gpt41Capacity=$GPT41_CAPACITY \
    --output json > /dev/null

echo "✓ Infrastructure deployed successfully!"

# Display next steps
echo ""
echo "========================================"
echo "Deployment Complete!"
echo "========================================"
echo ""
echo "Next Steps:"
echo "  1. Run the setup script to configure your environment:"
echo "     ./setup-environment.sh -g '$RESOURCE_GROUP'"
echo "    or if you want to use managed identities:"
echo "     ./setup-environment.sh -g '$RESOURCE_GROUP' -k"
echo ""
echo "  2. Open the notebooks folder in VS Code:"
echo "     cd ../../notebooks"
echo "     code ."
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo ""
