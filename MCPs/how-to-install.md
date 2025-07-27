# MCP Installation Tutorial

## Overview

Model Context Protocols (MCPs) extend Claude's capabilities by providing access to external tools and services. This tutorial will guide you through installing and configuring three powerful MCPs: Stagehand (browser automation), Memory (knowledge graphs), and Postman (API testing).

## Prerequisites

Before installing MCPs, ensure you have:

- **Claude Desktop** installed and configured
- **Terminal access** with appropriate permissions
- **API Keys** for the services you want to use:
  - Browserbase API key and Project ID (for Stagehand)
  - OpenAI API key (for Stagehand AI features)
- **Node.js** installed (for Stagehand MCP)

## MCP Installation Commands

### 1. Stagehand MCP (Browser Automation)

Stagehand enables Claude to control web browsers for automation, testing, and data extraction.

**What it provides:**
- Navigate to websites
- Click buttons and fill forms
- Extract data from web pages
- Take screenshots
- Perform web-based actions

**Installation:**
```bash
claude mcp add stagehand \
  -e BROWSERBASE_API_KEY="bb_live_ePNJ3UhmkwGhBwMvJG3CZ46UVIY" \
  -e BROWSERBASE_PROJECT_ID="PROJECT_ID" \
  -e OPENAI_API_KEY="KEY" \
  -- node /Users/adammanuel/Projects/MCPs/mcp-server-browserbase/stagehand/dist/index.js
```

**Required Environment Variables:**
- `BROWSERBASE_API_KEY`: Your Browserbase API key
- `BROWSERBASE_PROJECT_ID`: Your Browserbase project identifier
- `OPENAI_API_KEY`: OpenAI API key for AI-powered browser actions

**Setup Steps:**
1. Sign up for [Browserbase](https://browserbase.com) account
2. Create a new project and copy the Project ID
3. Generate an API key from your Browserbase dashboard
4. Replace `PROJECT_ID` and `KEY` with your actual values
5. Run the installation command

### 2. Memory MCP (Knowledge Graphs)

Memory MCP provides persistent knowledge storage using graph databases for complex information relationships.

**What it provides:**
- Create and manage knowledge graphs
- Store entities and relationships
- Search through stored knowledge
- Maintain conversation context across sessions

**Installation:**
```bash
# Install for current project only
claude mcp add memory /Users/adammanuel/.claude/MCPs/claude-memory.sh

# Install for your user account (available across all projects)
claude mcp add memory --user /Users/adammanuel/.claude/MCPs/claude-memory.sh
```

**Installation Scope Options:**
- **Project Scope** (default): MCP only available in the current project directory
- **User Scope** (`--user` flag): MCP available globally across all your projects

**Features:**
- **Entity Management**: Create, read, update, delete entities
- **Relationship Mapping**: Define connections between entities
- **Knowledge Search**: Query stored information semantically
- **Session Persistence**: Maintain context between conversations

### 3. Postman MCP (API Testing)

Postman MCP integrates API testing capabilities directly into Claude conversations.

**What it provides:**
- Run Postman collections
- Execute API requests
- Validate responses
- Generate test reports

**Installation:**
```bash
claude mcp add postman /Users/adammanuel/.claude/MCPs/postman.sh
```

**Requirements:**
- Newman (Postman CLI) installed: `npm install -g newman`
- Postman collections in JSON format
- Optional: Environment and globals files

## Verification

After installation, verify your MCPs are working:

1. **Check MCP Status:**
   ```bash
   claude mcp list
   ```

2. **Test Each MCP:**
   - **Stagehand**: Ask Claude to "navigate to google.com and take a screenshot"
   - **Memory**: Ask Claude to "create a knowledge graph about my project"
   - **Postman**: Ask Claude to "run my API collection tests"

## Configuration Files

Your MCPs are configured in Claude's settings. The installation commands above automatically:

- Register the MCP with Claude
- Set up required environment variables
- Configure execution paths
- Enable the MCP for use

## Troubleshooting

### Common Issues

**Stagehand MCP:**
- **Error**: "Browserbase API key invalid"
  - **Solution**: Verify your API key and project ID are correct
  - **Check**: Ensure your Browserbase account is active

- **Error**: "Node.js path not found"
  - **Solution**: Verify Node.js is installed and the path is correct
  - **Check**: `which node` to find the correct path

**Memory MCP:**
- **Error**: "Permission denied"
  - **Solution**: Make the shell script executable: `chmod +x /Users/adammanuel/.claude/MCPs/claude-memory.sh`

**Postman MCP:**
- **Error**: "Newman not found"
  - **Solution**: Install Newman globally: `npm install -g newman`

### General Troubleshooting

1. **Check MCP Status:**
   ```bash
   claude mcp status <mcp-name>
   ```

2. **View MCP Logs:**
   ```bash
   claude mcp logs <mcp-name>
   ```

3. **Restart Claude Desktop** after installation

4. **Verify File Paths** are accessible and correct

## Usage Examples

### Stagehand Example
```
"Navigate to github.com, search for 'typescript', and take a screenshot of the results"
```

### Memory Example  
```
"Create entities for our team members and their roles, then show me the knowledge graph"
```

### Postman Example
```
"Run the user authentication test collection and show me the results"
```

## Next Steps

With your MCPs installed, you can:

1. **Explore Capabilities**: Ask Claude what each MCP can do
2. **Create Workflows**: Combine MCPs for complex automation
3. **Build Projects**: Use MCPs to enhance your development workflow
4. **Share Collections**: Export configurations for team use

## Support

If you encounter issues:

- Check the [Claude MCP Documentation](https://docs.anthropic.com/claude/docs)
- Review individual MCP repositories for specific issues
- Verify API keys and permissions are correct
- Ensure all prerequisites are installed

---

**Note**: Replace placeholder values (API keys, project IDs, file paths) with your actual configuration before running the commands.