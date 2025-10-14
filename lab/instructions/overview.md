## Before You Begin

In any point of time during the lab, if you need to sign in to the virtual machine (Windows) or any Azure or Microsoft 365 apps (M365 Copilot, SharePoint, Teams etc.), use the credentials provided below.

### Sign into Virtual Machine (Windows)

If you need to sign in the virtual machine, use the following credentials:

- **User name**: +++@lab.VirtualMachine(Win11-Pro-Base).Username+++  
- **Password**: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++

### Sign into Azure & Microsoft 365

If you need to sign in to any Azure or Microsoft 365 apps, use the following credentials:

- **Username**: +++@lab.CloudPortalCredential(User1).Username+++  
- **Temporary Access Pass**: +++@lab.CloudPortalCredential(User1).AccessToken+++

## Overview

In this hands-on lab, you will design and implement a **Knowledge Base** that can retrieve, reason, and respond over enterprise data using **agentic retrieval** in Azure AI Search.

Unlike traditional search or basic RAG (Retrieval-Augmented Generation), an Agentic Knowledge Base doesn’t just return documents, it plans how and where to search, chooses the most relevant knowledge sources, and uses an LLM to synthesize grounded, citation-backed responses tailored to the user’s intent. This agentic approach transforms retrieval into a dynamic, adaptive process capable of delivering deeper insights, more relevant answers, and higher-quality results.

By the end of this lab, you’ll have built an Agentic Knowledge Base that provides context-aware, accurate, and explainable responses over enterprise data, forming a foundation you can extend into custom copilots, enterprise assistants, and intelligent knowledge applications.

### Learning Objectives

By completing this lab, you will be able to:

- Design and build a **Knowledge Base** that uses agentic retrieval to retrieve, reason, and respond over enterprise data.  
- Implement **smart source selection** to intelligently connect and query multiple indexes and data sources.  
- Enhance **query planning** with natural language instructions and retrieval guidance.  
- Generate **grounded, citation-backed responses** using answer synthesis or extractive techniques.  
- Optimize **retrieval strategies** with configurable effort levels and iterative refinement.

## Getting Started

Follow the steps below to set up your environment and begin the lab.

### Sign into Windows

In the virtual machine, sign into Windows using the following credentials:

- **User name**: +++@lab.VirtualMachine(Win11-Pro-Base).Username+++  
- **Password**: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++

### Access the Lab Repository

Once signed in to the Skillable environment, you’ll find the lab repository already cloned on your desktop under the folder: **Desktop > ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main**.

> This folder contains all the code, notebooks, and resources you’ll need for the lab.

### Open the Project Folder in Visual Studio Code

Right-click to the **ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main** folder in your Desktop and select **Open in Terminal**.

Then run the following command to open the project in Visual Studio Code:

```powershell
code .
```

> [!TIP]
> * When prompted whether to trust the authors of the files, select **Yes, I trust the authors**.
> * You may see pop-up message in VS Code **Dev Container prompt**. This appears when you first open the app folder. Select **Don’t Show Again** or close it, as you won’t be using a container in this lab.

### Verify the Environment Setup

All required Azure services including **Azure AI Search with pre-indexed data** and **Azure OpenAI deployments** have already been provisioned for you.

**What's Pre-Configured:**
- **Azure AI Search** - Standard tier with two pre-created indexes:
  - `hrdocs` (50 documents): HR policies, employee handbook, role library, company overview
  - `healthdocs` (334 documents): Health insurance plans, benefits options, coverage details
- **Azure OpenAI** - Deployed models:
  - `gpt-5-mini` for chat completion and answer synthesis
  - `text-embedding-3-large` for vector embeddings
- **Pre-computed vectors** - All 384 documents are already vectorized and indexed

#### Verify Environment Variables

1. Open the **.env** file under the main project folder.  
2. Verify that it includes the key environment variables:
   - `AZURE_SEARCH_SERVICE_ENDPOINT`
   - `AZURE_SEARCH_ADMIN_KEY`
   - `AZURE_OPENAI_ENDPOINT`
   - `AZURE_OPENAI_KEY`

If these variables are present, proceed to verify the indexes in Azure Portal.

#### Verify Indexes in Azure Portal

Let's confirm that the search indexes have been created successfully:

1. Open a web browser and navigate to the +++https://portal.azure.com+++.
2. Sign in using your lab credentials:
    - **Username**: +++@lab.CloudPortalCredential(User1).Username+++  
    - **Temporary Access Pass**: +++@lab.CloudPortalCredential(User1).AccessToken+++
3. In the Azure Portal search bar at the top, search for +++AI Search+++ and select your AI Search service (it will start with *lab511-search-*).
4. In the left navigation menu, select **Search management** > **Indexes**.
5. You should see two indexes:
   - **hrdocs** - Should show approximately 50 documents
   - **healthdocs** - Should show approximately 334 documents

> **✅ Checkpoint:** If you see both indexes with document counts, your environment is ready! If the indexes are missing or empty, please notify your instructor.

If your indexes are present and populated, your environment is ready to use. You can now proceed to open the Jupyter Notebook.

### Open the Jupyter Notebook

1. Navigate to the **notebook** folder.  
2. Open **lab511-agentic-knowledge-bases.ipynb**.

The notebook is organized into progressive sections, each building toward a fully functional Knowledge Agent. You'll explore:

- **Knowledge Sources** - Connecting to pre-indexed search collections
- **Knowledge Base Creation** - Configuring the orchestration layer with Azure OpenAI
- **Agentic Retrieval** - Query decomposition, multi-source search, and semantic reranking
- **Answer Synthesis** - Generating grounded responses with citations
- **Activity Inspection** - Understanding the agent's reasoning process

### Start Building Your Agentic Knowledge Base

All guided content and hands-on steps for this lab are contained inside the **lab511-agentic-knowledge-bases.ipynb** notebook. **Begin your work directly in the Jupyter Notebook.** Follow the guided sections in order, executing the provided code cells and reviewing the explanations along the way.

Once you’ve completed the full notebook experience and built your Agentic Knowledge Base, return to this page and select **Next >** to view the summary page, where you’ll review key takeaways, architectural patterns, and recommended next steps for applying what you’ve learned.
