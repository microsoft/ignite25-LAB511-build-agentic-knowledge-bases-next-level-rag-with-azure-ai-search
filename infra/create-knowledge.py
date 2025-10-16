import os
import asyncio
import json
import traceback
from datetime import datetime
from dotenv import load_dotenv
from azure.core.credentials import AzureKeyCredential
from azure.search.documents.aio import SearchClient
from azure.search.documents.indexes.aio import SearchIndexClient
from azure.search.documents.indexes.models import SearchIndex

load_dotenv(override=True)

endpoint = os.environ["AZURE_SEARCH_SERVICE_ENDPOINT"]
admin_key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
credential = AzureKeyCredential(admin_key)

azure_openai_endpoint = os.environ["AZURE_OPENAI_ENDPOINT"]

LOG_FILE = r"C:\Users\LabUser\Desktop\ignite25-LAB511-build-agentic-knowledge-bases-next-level-rag-with-azure-ai-search-main\infra\index-creation.log"

def log_message(message, log_file=LOG_FILE):
    """Write message to log file with timestamp"""
    # Ensure the directory exists
    os.makedirs(os.path.dirname(log_file), exist_ok=True)
    
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(log_file, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] {message}\n")

async def restore_index(endpoint: str, index_name: str, index_file: str, records_file: str, azure_openai_endpoint: str, credential: AzureKeyCredential):
    default_path = r"C:\Users\LabUser\Desktop\ignite25-LAB511-build-agentic-knowledge-bases-next-level-rag-with-azure-ai-search-main\data\index-data"
    
    try:
        log_message(f"[{index_name}] Starting index restoration...")
        
        # Create or update index
        async with SearchIndexClient(endpoint=endpoint, credential=credential) as client:
            index_file_path = os.path.join(default_path, index_file)
            log_message(f"[{index_name}] Reading index definition from: {index_file_path}")
            
            with open(index_file_path, "r", encoding="utf-8") as in_file:
                index_data = json.load(in_file)
                index = SearchIndex.deserialize(index_data)
                index.name = index_name
                index.vector_search.vectorizers[0].parameters.resource_url = azure_openai_endpoint
                
                log_message(f"[{index_name}] Creating/updating index in Azure AI Search...")
                await client.create_or_update_index(index)
                log_message(f"[{index_name}] Index created/updated successfully")

        # Upload documents
        async with SearchClient(endpoint=endpoint, index_name=index_name, credential=credential) as client:
            records_file_path = os.path.join(default_path, records_file)
            log_message(f"[{index_name}] Reading documents from: {records_file_path}")
            
            records = []
            total_uploaded = 0
            batch_count = 0
            
            with open(records_file_path, "r", encoding="utf-8") as in_file:
                for line_num, line in enumerate(in_file, 1):
                    try:
                        record = json.loads(line)
                        records.append(record)
                        
                        if len(records) >= 100:
                            batch_count += 1
                            log_message(f"[{index_name}] Uploading batch #{batch_count} ({len(records)} documents)...")
                            await client.upload_documents(documents=records)
                            total_uploaded += len(records)
                            records = []
                    except json.JSONDecodeError as e:
                        log_message(f"[{index_name}] WARNING: Skipping invalid JSON on line {line_num}: {e}")
                        continue

            # Upload remaining documents
            if records:
                batch_count += 1
                log_message(f"[{index_name}] Uploading final batch #{batch_count} ({len(records)} documents)...")
                await client.upload_documents(documents=records)
                total_uploaded += len(records)
        
        log_message(f"[{index_name}] SUCCESS - Index restored! Total documents uploaded: {total_uploaded}")
        print(f"Index {index_name} restored using {index_file} and {records_file}")
        return True
        
    except FileNotFoundError as e:
        error_msg = f"[{index_name}] ERROR - File not found: {e}"
        log_message(error_msg)
        log_message(f"[{index_name}] Traceback:\n{traceback.format_exc()}")
        print(f"Index {index_name} failed - see log file for details")
        return False
    except PermissionError as e:
        error_msg = f"[{index_name}] ERROR - Permission denied: {e}"
        log_message(error_msg)
        log_message(f"[{index_name}] This indicates insufficient permissions for the service principal")
        log_message(f"[{index_name}] Traceback:\n{traceback.format_exc()}")
        print(f"Index {index_name} failed - see log file for details")
        return False
    except Exception as e:
        error_msg = f"[{index_name}] ERROR - {type(e).__name__}: {str(e)}"
        log_message(error_msg)
        log_message(f"[{index_name}] Traceback:\n{traceback.format_exc()}")
        print(f"Index {index_name} failed - see log file for details")
        return False


async def main():
    # Initialize log file
    log_message("="*80)
    log_message("Azure AI Search Index Restoration Script - Starting")
    log_message("="*80)
    log_message(f"Azure Search Endpoint: {endpoint}")
    log_message(f"Azure OpenAI Endpoint: {azure_openai_endpoint}")
    
    results = {}
    
    # Restore hrdocs index
    log_message("\n--- Processing hrdocs index ---")
    results['hrdocs'] = await restore_index(
        endpoint, 
        "hrdocs", 
        "index.json", 
        "hrdocs-exported.jsonl", 
        azure_openai_endpoint, 
        credential
    )
    
    # Add delay between operations to avoid rate limiting
    log_message("Waiting 3 seconds before processing next index...")
    await asyncio.sleep(3)
    
    # Restore healthdocs index
    log_message("\n--- Processing healthdocs index ---")
    results['healthdocs'] = await restore_index(
        endpoint, 
        "healthdocs", 
        "index.json", 
        "healthdocs-exported.jsonl", 
        azure_openai_endpoint, 
        credential
    )
    
    # Summary
    log_message("\n" + "="*80)
    log_message("EXECUTION SUMMARY")
    log_message("="*80)
    
    success_count = sum(1 for v in results.values() if v)
    
    for index_name, success in results.items():
        status = "SUCCESS" if success else " FAILED"
        log_message(f"{status}: {index_name}")
    
    if success_count == len(results):
        log_message("\n All indexes created successfully!")
        print("\n Setup completed!")
    else:
        log_message(f"\n WARNING: {len(results) - success_count} index(es) failed to create.")
        log_message("\nPossible causes when using service principal:")
        log_message("  1. Insufficient Azure RBAC permissions on the AI Search service")
        log_message("  2. Missing 'Search Service Contributor' or 'Search Index Data Contributor' role")
        log_message("  3. Rate limiting from Azure OpenAI or AI Search")
        log_message("  4. Network/firewall restrictions")
        log_message("  5. Quota limits on Azure OpenAI or AI Search service")
        log_message("\nRecommended actions:")
        log_message("  - Verify service principal has 'Search Service Contributor' role")
        log_message("  - Verify service principal has 'Search Index Data Contributor' role")
        log_message("  - Check Azure OpenAI access permissions")
        log_message("  - Review detailed error messages above in this log file")
        
        print(f"\n Setup completed with errors. Check log file: {LOG_FILE}")
    
    log_message("="*80)
    log_message("Script execution completed")
    log_message("="*80)


if __name__ == "__main__":
    asyncio.run(main())