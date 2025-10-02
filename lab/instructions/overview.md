## Overview

In this hands-on lab, you will design and implement a **Knowledge Agent** — an intelligent retrieval system that can *retrieve, reason, and respond* over enterprise data using **agentic retrieval** in Azure AI Search. 

Unlike traditional search or basic RAG (Retrieval-Augmented Generation) approaches, a Knowledge Agent does far more than retrieve documents. It actively plans *how* and *where* to search, intelligently selects the most relevant data sources, and synthesizes grounded, citation-rich responses tailored to user intent. This new agentic approach turns static retrieval into a dynamic, adaptive process — capable of delivering deeper insights, more relevant answers, and greater reliability at scale.

This lab is built around the latest advancements in Azure AI Search and introduces you to several key capabilities:

- **Multi-source retrieval**: Seamlessly retrieve and merge results from multiple sources, including search indexes, blob storage, SharePoint, and even the web.
- **LLM-powered query planning**: Use language models to plan and orchestrate multi-step retrieval strategies for complex queries.
- **Dynamic source selection**: Automatically identify and query the most relevant data sources based on user intent.
- **Answer synthesis**: Generate clear, natural-language responses grounded in retrieved content, with inline citations for transparency.
- **Retrieval effort control**: Optimize for cost, quality, or latency depending on your scenario.
- **Iterative search**: Automatically refine search strategies when initial results are incomplete or insufficient.

By the end of this lab, you will have built a production-ready Knowledge Agent capable of delivering context-rich, accurate, and explainable responses over enterprise data — forming the foundation for building custom copilots, enterprise assistants, and next-generation knowledge applications.

## Learning Objectives

By completing this lab, you will be able to:

- Design and build a **Knowledge Agent** that uses agentic retrieval to retrieve, reason, and respond over enterprise data.  
- Implement **smart source selection** to intelligently connect and query multiple indexes and data sources.  
- Enhance **query planning** with natural language instructions and retrieval guidance.  
- Generate **grounded, citation-backed responses** using answer synthesis or extractive techniques.  
- Optimize **retrieval strategies** with configurable effort levels and iterative refinement.

## Sign into Windows

In the virtual machine, sign into Windows using the following credentials:

- **User name**: +++@lab.VirtualMachine(Win11-Pro-Base).Username+++  
- **Password**: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++

## Access the Lab Repository

Once signed in to the Skillable environment, you’ll find the lab repository already cloned on your desktop under the folder: **Desktop > LAB511**.

> This folder contains all the code, notebooks, and resources you’ll need for the lab.

## Open the Project Folder in Your Development Environment

Right-click the **LAB511** folder on your desktop and select **Open in Terminal**.

Then run the following command to open the project in Visual Studio Code:

```bash
code .
```
> When prompted whether to trust the authors of the files, select **Yes, I trust the authors**.

## Verify the Environment Setup

All required Azure services including **Azure AI Search**, **OpenAI deployments**, and **storage accounts** have already been provisioned for you.

To confirm the environment is configured correctly:

1. Open the **.env** file under the `notebook` folder.  
2. Verify that it includes all the key environment variables, such as *SEARCH_ENDPOINT*, *OPENAI_ENDPOINT*, and *INDEX_NAME*.

If these variables are present, your environment is ready to use.

## Open the Jupyter Notebook

1. Navigate to the `notebook` folder.  
2. Open **`lab511-knowledge-agents.ipynb`**.

The notebook is organized into thematic sections, each introducing a new capability of agentic retrieval and progressively building toward a fully functional Knowledge Agent. You’ll explore how query planning, multi-source retrieval, answer synthesis, and adaptive search all work together to deliver intelligent, enterprise-grade retrieval.

## Start the Lab

All guided content and hands-on steps for this lab are contained inside the **lab511-knowledge-agents.ipynb** notebook.

> [!IMPORTANT]  
> **Begin your work directly in the Jupyter Notebook.** Follow the guided sections in order, executing the provided code cells and reviewing the explanations along the way.

> [!TIP]  
> If you need to sign in to Azure at any point during the lab, use the following credentials:  
> - **Username**: +++@lab.CloudPortalCredential(User1).Username+++  
> - **Temporary Access Pass**: +++@lab.CloudPortalCredential(User1).AccessToken+++

Once you’ve completed the full notebook experience and built your Knowledge Agent, return to this page and select **Next >** to view the summary page, where you’ll review key takeaways, architectural patterns, and recommended next steps for applying what you’ve learned.
