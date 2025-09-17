# Welcome Ignite 2025 Creators!

Thanks for creating content for Ignite!  Please follow this guidance so all ignite repos have the same look and feel.

## Put your docs in the docs folder

This repo is configured for a user to view the docs through mkdocs.

1. update the `mkdocs.yml` file to reference your session. Look particularly for the `site_name`, `site_author`, and `repo_name` tags.
1. Subfolders in the docs folder will show up as tabs in the navigation bar.

## Guidance

1. Do not turn on github pages for this repo, traffic to github pages isn't captured in our metrics.
1. Do not store slides or recordings in this repo

## Update the badges!

1. if the foundry discord and github links aren't appropriate for your session you can remove or change them.
2. See shields.io for how to build your own dynamic or static badge for your community destinations, or other sample repos for how they've done
3. Please limit your repo to one row of badges under the session title.

## MCP Server
1. This repo has an mcp.json file and is configured to let agents connect to the Learn MCP Server.

> **Important** Make sure to avoid hardcoding sensitive information like API keys and other credentials by using input variables or environment files.


## Update this readme below

1. Fill out the content in this file, below the banner graphic, including the session code.
2. Please embed links to Learn with your campaign codes!
3. Add resources for your session to the Resources and Next Steps table
4. Change the Content Owner section to your info
5. Change the placeholder session code BRKXXX to your session code.

## Improve SEO

1. Update the Repo Info for this repo 
    1. Click the gear icon⚙️ in the upper right.
    1. Set a good description of this repo.
    1. Add the technologies that you're using in this session.

## Questions?

Send them to [Mike Kinsman](mailto:mikki@microsoft.com) and [Laurent Bugnion](lbugnion@microsoft.com), or surface your question through your content leads.  We are also monitoring issues logged in the repos.

## Finished?

- Remove the folders that you don't need or didn't use, *please don't leave them empty with placeholder readmes*
- Delete this line and everything above it!

<p align="center">
<img src="img/Banner-ignite-25.png" alt="decorative banner" width="1200"/>
</p>

# [Microsoft Ignite 2025](https://ignite.microsoft.com)

## 🔥BRKXXX: SESSIONNAME

[![Microsoft Azure AI Foundry Discord](https://dcbadge.limes.pink/api/server/ByRwuEEgH4)](https://discord.com/invite/ByRwuEEgH4)
[![Azure AI Foundry Developer Forum](https://img.shields.io/badge/GitHub-Azure_AI_Foundry_Developer_Forum-blue?style=for-the-badge&logo=github&color=adff2f&logoColor=fff)](https://aka.ms/foundry/forum)

### Session Description

*Add Session Description*

### 🧠 Learning Outcomes

By the end of this session, learners will be able to:

-  
-
-

### 💻 Technologies Used

1.
1.
1.

### 🌟 Microsoft Learn MCP Server

[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Microsoft_Docs_MCP-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://vscode.dev/redirect/mcp/install?name=microsoft.docs.mcp&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)

The Microsoft Learn MCP Server is a remote MCP Server that enables clients like GitHub Copilot and other AI agents to bring trusted and up-to-date information directly from Microsoft's official documentation. Get started by using the one-click button above for VSCode or access the [mcp.json](.vscode/mcp.json) file included in this repo.

For more information, setup instructions for other dev clients, and to post comments and questions, visit our Learn MCP Server GitHub repo at [https://github.com/MicrosoftDocs/MCP](https://github.com/MicrosoftDocs/MCP). Find other MCP Servers to connect your agent to at [https://mcp.azure.com](https://mcp.azure.com).

*Note: When you use the Learn MCP Server, you agree with [Microsoft Learn](https://learn.microsoft.com/en-us/legal/termsofuse) and [Microsoft API Terms](https://learn.microsoft.com/en-us/legal/microsoft-apis/terms-of-use) of Use.*

### 📚 Resources and Next Steps

| Resources          | Links                             | Description        |
|:-------------------|:----------------------------------|:-------------------|
| Ignite 2025 Next Steps | [https://aka.ms/Ignite25-Next-Steps](https://aka.ms/Ignite25-Next-Steps?ocid=ignite25_nextsteps_cnl) | Links to all repos for AI Tour 26 Sessions |
| Azure AI Foundry Community Discord | [![Microsoft Azure AI Foundry Discord](https://dcbadge.limes.pink/api/server/ByRwuEEgH4)](https://discord.com/invite/ByRwuEEgH4)| Connect with the Azure AI Foundry Community! |
| Learn at Ignite | [https://aka.ms/LearnAtIgnite](https://aka.ms/LearnAtIgnite?ocid=ignite25_nextsteps_github_cnl) | Continue learning on Microsoft Learn |

## Content Owners

<!-- TODO: Add yourself as a content owner
1. Change the src in the image tag to {your github url}.png
2. Change INSERT NAME HERE to your name
3. Change the github url in the final href to your url. -->

<table>
<tr>
    <td align="center"><a href="http://github.com/mikekinsman">
        <img src="https://github.com/mikekinsman.png" width="100px;" alt="INSERT NAME HERE"
"/><br />
        <sub><b> INSERT NAME HERE
</b></sub></a><br />
            <a href="https://github.com/mikekinsman" title="talk">📢</a> 
    </td>
    <td align="center"><a href="http://github.com/mikekinsman">
        <img src="https://github.com/mikekinsman.png" width="100px;" alt="INSERT NAME HERE
"/><br />
        <sub><b>INSERT NAME HERE
</b></sub></a><br />
            <a href="https://github.com/mikekinsman" title="talk">📢</a> 
    </td>
</tr></table>


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
