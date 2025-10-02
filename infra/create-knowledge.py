import os
import asyncio
import glob
from dotenv import load_dotenv
from azure.core.credentials import AzureKeyCredential
from azure.storage.blob.aio import BlobServiceClient
from azure.search.documents.indexes.aio import SearchIndexClient
from azure.search.documents.indexes.models import (
    AzureBlobKnowledgeSource,
    AzureBlobKnowledgeSourceParameters,
    AzureOpenAIVectorizer,
    AzureOpenAIVectorizerParameters,
    KnowledgeAgentAzureOpenAIModel
)

load_dotenv(override=True)

endpoint = os.environ["AZURE_SEARCH_SERVICE_ENDPOINT"]
admin_key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
credential = AzureKeyCredential(admin_key)

knowledge_source_name = os.getenv("AZURE_SEARCH_KNOWLEDGE_SOURCE", "blob-knowledge-source")

blob_connection_string = os.environ["BLOB_CONNECTION_STRING"]
search_blob_connection_string = os.getenv("SEARCH_BLOB_DATASOURCE_CONNECTION_STRING", blob_connection_string)
blob_container_name = os.getenv("BLOB_CONTAINER_NAME", "documents")
azure_openai_endpoint = os.environ["AZURE_OPENAI_ENDPOINT"]
azure_openai_key = os.getenv("AZURE_OPENAI_KEY")
azure_openai_embedding_deployment = os.getenv("AZURE_OPENAI_EMBEDDING_DEPLOYMENT", "text-embedding-3-large")
azure_openai_embedding_model_name = os.getenv("AZURE_OPENAI_EMBEDDING_MODEL_NAME", "text-embedding-3-large")
azure_openai_chatgpt_deployment = os.getenv("AZURE_OPENAI_CHATGPT_DEPLOYMENT", "gpt-5-mini")
azure_openai_chatgpt_model_name = os.getenv("AZURE_OPENAI_CHATGPT_MODEL_NAME", "gpt-5-mini")
use_verbalization = os.getenv("USE_VERBALIZATION", "false").lower() == "true"


async def ensure_container_exists():
    async with BlobServiceClient.from_connection_string(blob_connection_string, logging_enable=False) as bsc:
        container_client = bsc.get_container_client(blob_container_name)
        if not await container_client.exists():
            await container_client.create_container()
            print(f"Created container: {blob_container_name}")
        else:
            print(f"Container exists: {blob_container_name}")


async def upload_local_docs():
    default_path = r"C:\Users\LabUser\Desktop\LAB511\ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main\data\ai-search-data"
    local_docs_path = os.getenv("LOCAL_DOCS_PATH", default_path)
    
    if not os.path.exists(local_docs_path):
        print(f"Documents not found at: {local_docs_path}")
        return
    
    print(f"Uploading documents from: {local_docs_path}")
    async with BlobServiceClient.from_connection_string(blob_connection_string) as blob_service_client:
        container_client = blob_service_client.get_container_client(blob_container_name)
        
        files = glob.glob(os.path.join(local_docs_path, "*"))
        uploaded = 0
        skipped = 0
        
        for file_path in files:
            if not os.path.isfile(file_path):
                continue
            
            blob_name = os.path.basename(file_path)
            blob_client = container_client.get_blob_client(blob_name)
            
            try:
                if not await blob_client.exists():
                    with open(file_path, "rb") as f:
                        await blob_client.upload_blob(f)
                    print(f"Uploaded: {blob_name}")
                    uploaded += 1
                else:
                    skipped += 1
            except Exception as e:
                print(f"Failed to upload {blob_name}: {e}")
        
        print(f"Upload complete: {uploaded} uploaded, {skipped} skipped")


async def create_knowledge_source():
    print("\nCreating Knowledge Source and triggering indexing...")
    
    chat_model = KnowledgeAgentAzureOpenAIModel(
        azure_open_ai_parameters=AzureOpenAIVectorizerParameters(
            resource_url=azure_openai_endpoint,
            deployment_name=azure_openai_chatgpt_deployment,
            api_key=azure_openai_key,
            model_name=azure_openai_chatgpt_model_name
        )
    )
    
    knowledge_source = AzureBlobKnowledgeSource(
        name=knowledge_source_name,
        azure_blob_parameters=AzureBlobKnowledgeSourceParameters(
            connection_string=search_blob_connection_string,
            container_name=blob_container_name,
            embedding_model=AzureOpenAIVectorizer(
                vectorizer_name="blob-vectorizer",
                parameters=AzureOpenAIVectorizerParameters(
                    resource_url=azure_openai_endpoint,
                    deployment_name=azure_openai_embedding_deployment,
                    api_key=azure_openai_key,
                    model_name=azure_openai_embedding_model_name
                )
            ),
            chat_completion_model=chat_model if use_verbalization else None,
            disable_image_verbalization=(not use_verbalization),
        ),
    )
    
    async with SearchIndexClient(endpoint=endpoint, credential=credential) as client:
        print(f"Creating/updating Knowledge Source: {knowledge_source.name}")
        result = await client.create_or_update_knowledge_source(knowledge_source)
        print(f"✓ Knowledge Source created: {result.name}")
        print("\nIndexing started. This may take a few minutes.")
        print("Check Azure Portal > AI Search > Indexers for status.")
        print("\nNext: Open the notebook to create the Knowledge Agent.")


async def main():
    try:
        await ensure_container_exists()
        await upload_local_docs()
        await create_knowledge_source()
        print("\n✓ Setup completed!")
    except Exception as e:
        print(f"\n✗ Error: {e}")
        import traceback
        traceback.print_exc()
        raise


if __name__ == "__main__":
    asyncio.run(main())