import os
import asyncio
import glob
import json
from dotenv import load_dotenv
from azure.core.credentials import AzureKeyCredential
from azure.search.documents.aio import SearchClient
from azure.search.documents.indexes.aio import SearchIndexClient
from azure.search.documents.indexes.models import (
    AzureBlobKnowledgeSource,
    AzureBlobKnowledgeSourceParameters,
    AzureOpenAIVectorizer,
    AzureOpenAIVectorizerParameters,
    KnowledgeAgentAzureOpenAIModel,
    SearchIndex
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

def log(message):
    """Print to stderr so it shows in Skillable lifecycle output"""
    print(message, file=sys.stderr, flush=True)

async def restore_index(endpoint: str, index_name: str, index_file: str, records_file: str, azure_openai_endpoint: str, credential: AzureKeyCredential):
    default_path = r"C:\Users\LabUser\Desktop\LAB511\ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main\data\index-data"
    async with SearchIndexClient(endpoint=endpoint, credential=credential) as client:
        with open(os.path.join(default_path, index_file), "r", encoding="utf-8") as in_file:
            index_data = json.load(in_file)
            index = SearchIndex.deserialize(index_data)
            index.name = index_name
            
            # FIX: Make vectorizer name unique per index
            if index.vector_search and index.vector_search.vectorizers:
                for vectorizer in index.vector_search.vectorizers:
                    vectorizer.vectorizer_name = f"{index_name}-vectorizer"
                    vectorizer.parameters.resource_url = azure_openai_endpoint
            
            # Update vector profiles to reference the unique vectorizer name
            if index.vector_search and index.vector_search.profiles:
                for profile in index.vector_search.profiles:
                    profile.vectorizer_name = f"{index_name}-vectorizer"
            
            await client.create_or_update_index(index)

    async with SearchClient(endpoint=endpoint, index_name=index_name, credential=credential) as client:
        records = []
        with open(os.path.join(default_path, records_file), "r", encoding="utf-8") as in_file:
            for line in in_file:
                record = json.loads(line)
                if len(records) < 100:
                    records.append(record)
                else:
                    await client.upload_documents(documents=records)
                    records = []
        
        if records:
            await client.upload_documents(documents=records)
    print (f"✓ Index {index_name} restored using {index_file} and {records_file}")


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
        log("Creating hrdocs index...")
        await restore_index(endpoint, "hrdocs", "index.json", "hrdocs-exported.jsonl", azure_openai_endpoint, credential)
        
        log("Waiting 10 seconds before creating healthdocs index...")
        await asyncio.sleep(10)
        
        log("Creating healthdocs index...")
        await restore_index(endpoint, "healthdocs", "index.json", "healthdocs-exported.jsonl", azure_openai_endpoint, credential)
        
        log("\nSUCCESS: Setup completed!")
    except Exception as e:
        log(f"\nERROR: {e}")
        import traceback
        traceback.print_exc(file=sys.stderr)
        raise


if __name__ == "__main__":
    asyncio.run(main())
