# AI Agent Guidelines

This file contains instructions and guidelines for AI agents working on this repository.

## 🔒 Security Best Practices

**Never commit sensitive information to this repository:**
- API keys, tokens, or credentials
- Personal access tokens (PATs)
- Database connection strings with passwords
- Environment-specific configuration values

**For MCP configuration files (`mcp.json`):**
- Use placeholder values like `"YOUR_API_KEY_HERE"` or `"${API_KEY}"`
- Reference environment variables for sensitive data
- Include documentation about required environment variables

## 📋 Repository Guidelines

### Purpose
This repository is one of several for Microsoft Ignite 2025 sessions and should:
- Provide a consistent structure for all Ignite content repositories
- Include proper documentation for the customer
- Support MkDocs documentation generation
- Enable Learn MCP (Model Context Protocol) server integration

### Consistent Experience
- Maintain the existing folder structure (`docs/`, `src/`, `lab/`, etc.)
- Don't remove placeholder folders unless explicitly instructed
- Keep the banner image and branding consistent
- Ensure all links use proper campaign codes when referencing Learn content
- SUPPORT.md should be updated with support information.
- All readme files in the repo should have updates
- All subfolder names under /docs should be reviewed for mkdocs compatibility
- Unused subfolders (e.g. that only have a README file in them) should be cleaned up before the repo is released.
- No large binary files like powerpoints or videos should be added to the repo.

### What NOT to modify without permission:
- License files (`LICENSE`, `CODE_OF_CONDUCT.md`)
- Security files (`SECURITY.md`)
- GitHub workflow files in `.github/` directory

