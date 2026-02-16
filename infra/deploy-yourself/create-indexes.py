"""
Create Azure AI Search indexes and upload sample data
This script is designed for the deploy-yourself scenario
"""
import os
import sys
import asyncio
import json
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.core.credentials import AzureKeyCredential
from azure.search.documents.aio import SearchClient
from azure.search.documents.indexes.aio import SearchIndexClient
from azure.search.documents.indexes.models import SearchIndex

# Load environment variables
load_dotenv(override=True)

# Get script directory and repo root
script_dir = Path(__file__).parent
repo_root = script_dir.parent.parent

# Azure AI Search configuration
endpoint = os.environ.get("AZURE_SEARCH_SERVICE_ENDPOINT")
azure_openai_endpoint = os.environ.get("AZURE_OPENAI_ENDPOINT")

if not all([endpoint, azure_openai_endpoint]):
    print("❌ Error: Missing required environment variables")
    print("   Make sure .env file exists with AZURE_SEARCH_SERVICE_ENDPOINT and AZURE_OPENAI_ENDPOINT")
    sys.exit(1)


if os.getenv('KEYLESS','false').lower() == 'true':
    credential = DefaultAzureCredential()
else:
    credential = AzureKeyCredential(os.environ["AZURE_SEARCH_ADMIN_KEY"])

# Paths
data_dir = repo_root / "data" / "index-data"
log_file = repo_root / "infra" / "index-creation.log"

def log_message(message):
    """Write message to log file and console with timestamp"""
    log_file.parent.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_line = f"[{timestamp}] {message}"
    
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"{log_line}\n")
    
    print(message)

async def create_index(index_name: str, index_file: str, records_file: str):
    """Create search index and upload documents"""
    try:
        log_message(f"📋 [{index_name}] Starting index creation...")
        
        # Create or update index
        async with SearchIndexClient(endpoint=endpoint, credential=credential) as client:
            index_file_path = data_dir / index_file
            
            if not index_file_path.exists():
                raise FileNotFoundError(f"Index definition not found: {index_file_path}")
            
            log_message(f"   Reading index definition from: {index_file_path.name}")
            
            with open(index_file_path, "r", encoding="utf-8") as f:
                index_data = json.load(f)
                index = SearchIndex.deserialize(index_data)
                index.name = index_name
                index.vector_search.vectorizers[0].parameters.resource_url = azure_openai_endpoint
                
                log_message(f"   Creating index in Azure AI Search...")
                await client.create_or_update_index(index)
                log_message(f"   ✅ Index '{index_name}' created successfully")

        # Upload documents
        async with SearchClient(endpoint=endpoint, index_name=index_name, credential=credential) as client:
            records_file_path = data_dir / records_file
            
            if not records_file_path.exists():
                raise FileNotFoundError(f"Records file not found: {records_file_path}")
            
            log_message(f"   Reading documents from: {records_file_path.name}")
            
            records = []
            total_uploaded = 0
            batch_size = 100
            
            with open(records_file_path, "r", encoding="utf-8") as f:
                for line_num, line in enumerate(f, 1):
                    try:
                        record = json.loads(line)
                        records.append(record)
                        
                        if len(records) >= batch_size:
                            await client.upload_documents(documents=records)
                            total_uploaded += len(records)
                            log_message(f"   Uploaded {total_uploaded} documents...")
                            records = []
                    except json.JSONDecodeError as e:
                        log_message(f"   ⚠️  Skipping invalid JSON on line {line_num}: {e}")
                        continue

            # Upload remaining documents
            if records:
                await client.upload_documents(documents=records)
                total_uploaded += len(records)
        
        log_message(f"   ✅ [{index_name}] Index created with {total_uploaded} documents")
        return True
        
    except Exception as e:
        log_message(f"   ❌ [{index_name}] Error: {type(e).__name__}: {str(e)}")
        return False

async def main():
    """Main execution"""
    log_message("="*80)
    log_message("🚀 Azure AI Search Index Creation")
    log_message("="*80)
    log_message(f"Search Endpoint: {endpoint}")
    log_message(f"OpenAI Endpoint: {azure_openai_endpoint}")
    log_message(f"Data Directory: {data_dir}")
    log_message("")
    
    # Check if data files exist
    if not data_dir.exists():
        log_message(f"❌ Error: Data directory not found: {data_dir}")
        log_message("   Make sure you're running this from the repository root")
        sys.exit(1)
    
    results = {}
    
    # Create hrdocs index
    log_message("📚 Creating hrdocs index...")
    results['hrdocs'] = await create_index(
        index_name="hrdocs",
        index_file="index.json",
        records_file="hrdocs-exported.jsonl"
    )
    
    # Wait between operations
    log_message("")
    log_message("⏳ Waiting 5 seconds to avoid rate limiting...")
    await asyncio.sleep(5)
    log_message("")
    
    # Create healthdocs index
    log_message("📚 Creating healthdocs index...")
    results['healthdocs'] = await create_index(
        index_name="healthdocs",
        index_file="index.json",
        records_file="healthdocs-exported.jsonl"
    )
    
    # Summary
    log_message("")
    log_message("="*80)
    log_message("📊 SUMMARY")
    log_message("="*80)
    
    success_count = sum(1 for success in results.values() if success)
    
    for index_name, success in results.items():
        status = "✅ SUCCESS" if success else "❌ FAILED"
        log_message(f"{status}: {index_name}")
    
    log_message("")
    if success_count == len(results):
        log_message("🎉 All indexes created successfully!")
        log_message(f"📄 Log file: {log_file}")
        return 0
    else:
        log_message(f"⚠️  {len(results) - success_count} index(es) failed")
        log_message(f"📄 Check log file for details: {log_file}")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
