## Overview

In this hands-on lab, you will design and implement a Knowledge Agent that can retrieve, reason, and respond over enterprise data using agentic retrieval in Azure AI Search. Unlike traditional search or basic RAG (Retrieval-Augmented Generation) approaches, a Knowledge Agent actively plans how and where to search, intelligently selects the most relevant data sources, and generates grounded, citation-rich responses tailored to user queries.

This lab reflects the latest evolution of retrieval capabilities in Azure AI Search, introducing advanced features such as:

* Multi-source retrieval across search indexes, blob storage, SharePoint, and the web.
* LLM-powered query planning and dynamic source selection for intelligent data discovery.
* Answer synthesis, enabling concise, natural-language answers grounded in retrieved content.
* Retrieval effort control, allowing you to balance cost, quality, and latency for different use cases.
* Iterative search, where the agent refines its approach when initial results are insufficient

By the end of this lab, you will have built a production-ready Knowledge Agent capable of delivering context-rich, accurate, and explainable responses over enterprise data — the foundation for building copilots, business assistants, and enterprise-scale knowledge applications.

## Learning Objectives

By completing this lab, you will be able to:

* Design and build a Knowledge Agent that uses agentic RAG to retrieve, reason, and respond over enterprise data.
* Implement smart source selection to connect and query multiple indexes and data sources intelligently.
* Enhance query planning using natural language instructions and retrieval guidance.
* Generate grounded responses using answer synthesis with citations or extractive answers.
* Optimize retrieval strategies using configurable retrieval effort levels and iterative search.

## Sign into Windows

In the virtual machine, sign into Windows using the following credentials:

- **User name**: +++@lab.VirtualMachine(Win11-Pro-Base).Username+++
- **Password**: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++

## Access and set up the lab repository

Once signed in to the Skillable environment, you'll find the lab repo pre-cloned on the desktop under the folder **Desktop > LAB511**. This folder contains all the code and resources you'll need.

## Open the project folder in your dev environment

Right-click to the **LAB511** folder on your Desktop and select **Open in Terminal**.

Run the following command to open the project in Visual Studio Code:

+++code .+++

> [!TIP]
> * When prompted whether to trust the authors of the files, select **Yes, I trust the authors**.
> * You may see pop-up message in VS Code **Dev Container prompt**. This appears when you first open the app folder. Select **Don't Show Again** or close it, as you won't be using a container in this lab.

## Verify the Environment Setup

All required Azure services including Azure AI Search, OpenAI deployments, and storage accounts that have already been deployed for you.

To confirm, check **.env** file under the *notebook* folder that should include all the key environment variables (such as SEARCH_ENDPOINT, OPENAI_ENDPOINT, and INDEX_NAME).

If all variables are present, your environment is ready to use.

### Open the Jupyter Notebook

1. Navigate to the *notebook* folder.
2. Open **lab511-knowledge-agents.ipynb**.

The notebook is organized into thematic sections, each introducing a new capability of agentic retrieval and progressively building toward a fully functional Knowledge Agent. While you will complete everything in a single guided flow, these sections align with key capabilities you will implement and understand.

## Start the Lab

All guided content and hands-on steps for this lab are contained inside the **lab511-knowledge-agents.ipynb** notebook.

[!IMPORTANT]
Begin your work directly in the Jupyter Notebook. Follow the guided sections in order, executing the provided code cells and reviewing the explanations along the way.

> [!TIP]
> If you need to login to Azure in any point of this exercise, please use the following credentials:
> - **Username**: +++@lab.CloudPortalCredential(User1).Username+++
> - **Temporary Access Pass**: +++@lab.CloudPortalCredential(User1).AccessToken+++

Once you have completed the full notebook experience and built your Knowledge Agent, return to this page and select **Next >** to view the summary page where you’ll review key concepts, architectural patterns, and recommended next steps for applying what you’ve learned.