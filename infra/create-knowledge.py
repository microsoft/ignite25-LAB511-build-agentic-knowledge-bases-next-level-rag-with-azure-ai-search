import os, asyncio
from dotenv import load_dotenv

from azure.core.credentials import AzureKeyCredential
from azure.identity.aio import DefaultAzureCredential
from azure.storage.blob.aio import BlobServiceClient
from azure.search.documents.indexes.aio import SearchIndexClient
from azure.search.documents.indexes.models import (
    AzureBlobKnowledgeSource, AzureBlobKnowledgeSourceParameters,
    AzureOpenAIVectorizer, AzureOpenAIVectorizerParameters,
    KnowledgeAgentAzureOpenAIModel, KnowledgeAgent, KnowledgeSourceReference,
    KnowledgeAgentOutputConfiguration, KnowledgeAgentOutputConfigurationModality
)

load_dotenv(override=True)

endpoint = os.environ["AZURE_SEARCH_SERVICE_ENDPOINT"]
admin_key = os.getenv("AZURE_SEARCH_ADMIN_KEY")
credential = AzureKeyCredential(admin_key) if admin_key else DefaultAzureCredential()

knowledge_source_name = os.getenv("AZURE_SEARCH_KNOWLEDGE_SOURCE", "blob-knowledge-source")
knowledge_agent_name  = os.getenv("AZURE_SEARCH_KNOWLEDGE_AGENT", "blob-knowledge-agent")

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
    async with DefaultAzureCredential() as user_cred, \
        BlobServiceClient.from_connection_string(logging_enable=False, conn_str=blob_connection_string, credential=user_cred) as bsc:
        async with bsc.get_container_client(blob_container_name) as cc:
            if not await cc.exists():
                await cc.create_container()

async def create_knowledge():
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

    output_config = KnowledgeAgentOutputConfiguration(
        modality=KnowledgeAgentOutputConfigurationModality.ANSWER_SYNTHESIS,
        include_activity=True
    )

    agent = KnowledgeAgent(
        name=knowledge_agent_name,
        models=[chat_model],
        knowledge_sources=[KnowledgeSourceReference(
            name=knowledge_source.name,
            include_reference_source_data=True,
            always_query_source=True
        )],
        output_configuration=output_config
    )

    async with SearchIndexClient(endpoint=endpoint, credential=credential) as client:
        await client.create_or_update_knowledge_source(knowledge_source)
        print(f"Created/updated knowledge source: {knowledge_source.name}")
        await client.create_or_update_agent(agent)
        print(f"Created/updated knowledge agent: {agent.name}")

async def main():
    await ensure_container_exists()
    await create_knowledge()

if __name__ == "__main__":
    asyncio.run(main())
