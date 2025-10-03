## Before You Begin

To complete this lab, you will need the credentials for the virtual machine (Windows) and Azure.

### Sign into Windows

If you need to sign in the virtual machine, use the following credentials:

- **User name**: +++@lab.VirtualMachine(Win11-Pro-Base).Username+++  
- **Password**: +++@lab.VirtualMachine(Win11-Pro-Base).Password+++

### Azure Sign-In Credentials

If you need to sign in to Azure at any point during the lab, use the following credentials:  

- **Username**: +++@lab.CloudPortalCredential(User1).Username+++  
- **Temporary Access Pass**: +++@lab.CloudPortalCredential(User1).AccessToken+++

## Overview

In this hands-on lab, you will design and implement a **Knowledge Agent** that can *retrieve, reason, and respond* over enterprise data using **agentic retrieval** in Azure AI Search.

Unlike traditional search or basic RAG (Retrieval-Augmented Generation) approaches, a Knowledge Agent does far more than retrieve documents. It actively plans *how* and *where* to search, intelligently selects the most relevant data sources, and synthesizes grounded, citation-rich responses tailored to user intent. This new agentic approach turns static retrieval into a dynamic, adaptive process that is capable of delivering deeper insights, more relevant answers, and greater reliability at scale.

By the end of this lab, you will have built a production-ready Knowledge Agent capable of delivering context-rich, accurate, and explainable responses over enterprise data, forming the foundation for building custom copilots, enterprise assistants, and next-generation knowledge applications.

### Learning Objectives

By completing this lab, you will be able to:

- Design and build a **Knowledge Agent** that uses agentic retrieval to retrieve, reason, and respond over enterprise data.  
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

Once signed in to the Skillable environment, you’ll find the lab repository already cloned on your desktop under the folder: **Desktop > LAB511**.

> This folder contains all the code, notebooks, and resources you’ll need for the lab.

### Open the Project Folder in Your Development Environment

Double-click on **LAB511** folder on your desktop. Then right-click to the **ignite25-LAB511-build-knowledge-agents-next-level-agentic-rag-with-azure-ai-search-main** folder and select **Open in Terminal**.

Then run the following command to open the project in Visual Studio Code:

```powershell
code .
```

> [!TIP]
> * When prompted whether to trust the authors of the files, select **Yes, I trust the authors**.
> * You may see pop-up message in VS Code **Dev Container prompt**. This appears when you first open the app folder. Select **Don’t Show Again** or close it, as you won’t be using a container in this lab.

### Verify the Environment Setup

All required Azure services including **Azure AI Search**, **OpenAI deployments**, and **storage accounts** have already been provisioned for you.

To confirm the environment is configured correctly:

1. Open the **.env** file under the main project folder.  
2. Verify that it includes all the key environment variables, such as *SEARCH_ENDPOINT*, *OPENAI_ENDPOINT*, and *INDEX_NAME*.

If these variables are present, your environment is ready to use.

### Open the Jupyter Notebook

1. Navigate to the **notebook** folder.  
2. Open **lab511-knowledge-agents.ipynb**.

The notebook is organized into thematic sections, each introducing a new capability of agentic retrieval and progressively building toward a fully functional Knowledge Agent. You’ll explore how query planning, multi-source retrieval, answer synthesis, and adaptive search all work together to deliver intelligent, enterprise-grade retrieval.

### Start Building Your Knowledge Agent

All guided content and hands-on steps for this lab are contained inside the **lab511-knowledge-agents.ipynb** notebook. **Begin your work directly in the Jupyter Notebook.** Follow the guided sections in order, executing the provided code cells and reviewing the explanations along the way.

Once you’ve completed the full notebook experience and built your Knowledge Agent, return to this page and select **Next >** to view the summary page, where you’ll review key takeaways, architectural patterns, and recommended next steps for applying what you’ve learned.
