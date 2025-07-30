# Stagehand MCP Server Setup Instructions

## Overview
This document provides step-by-step instructions to set up the local Stagehand MCP server for both Claude Desktop and Claude Code applications.

## Prerequisites
- Node.js (v24+ recommended)
- npm
- Chrome browser (for local testing)
- Git

## Step 1: Clone and Build the Local Stagehand Implementation

```bash
# Navigate to your Claude MCPs directory
cd ~/.claude/MCPs/mcp-server-browserbase/stagehand

# Clean install dependencies
rm -rf node_modules package-lock.json
npm install

# Build the project
npm run build
```

## Step 2: Set Up Environment Variables

Create environment variables for the required API keys:

```bash
# Add to your ~/.bashrc, ~/.zshrc, or ~/.profile
export BROWSERBASE_API_KEY="your_browserbase_api_key"
export BROWSERBASE_PROJECT_ID="your_browserbase_project_id"
export OPENAI_API_KEY="your_openai_api_key"
```

## Step 3: Configure Claude Desktop

Edit the Claude Desktop configuration file:

**File Location**: `~/Library/Application Support/Claude/claude_desktop_config.json`

**Content**:
```json
{
  "mcpServers": {
    "stagehand": {
      "command": "/Users/[YOUR_USERNAME]/.claude/MCPs/stagehand.sh",
      "args": []
    }
  }
}
```

**Replace `[YOUR_USERNAME]` with your actual username.**

## Step 4: Configure Claude Code

### Option A: Project-specific configuration
Create a configuration file in your project root:

**File**: `.claude_config.json`
```json
{
  "mcpServers": {
    "stagehand": {
      "command": "/Users/[YOUR_USERNAME]/.claude/MCPs/stagehand.sh",
      "args": []
    }
  }
}
```

### Option B: Global configuration
```bash
mkdir -p ~/.config/claude-code
echo '{
  "mcpServers": {
    "stagehand": {
      "command": "/Users/[YOUR_USERNAME]/.claude/MCPs/stagehand.sh",
      "args": []
    }
  }
}' > ~/.config/claude-code/config.json
```

## Step 5: Verify Installation

Test the Stagehand script directly:

```bash
cd ~/.claude/MCPs
./stagehand.sh
```

You should see output similar to:
```
Starting Stagehand MCP Server...
Using stagehand path: /Users/[USERNAME]/.claude/MCPs/mcp-server-browserbase/stagehand/dist/index.js
{"method":"notifications/message","params":{"level":"info","data":"Stagehand MCP server is ready to accept requests"},"jsonrpc":"2.0"}
```

Press Ctrl+C to stop the server.

## Step 6: Restart Applications

1. **Restart Claude Desktop** - Close and reopen the application
2. **Restart Claude Code** - If using VS Code extension, reload the window

## Troubleshooting

### Common Issues

1. **Module not found errors**
   ```bash
   cd ~/.claude/MCPs/mcp-server-browserbase/stagehand
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **Permission denied errors**
   ```bash
   chmod +x ~/.claude/MCPs/stagehand.sh
   chmod +x ~/.claude/MCPs/stagehand-local.sh
   ```

3. **Chrome issues (for local mode)**
   - Ensure Chrome is installed in `/Applications/Google Chrome.app/`
   - Close all Chrome instances before using local mode
   - Use `stagehand-local.sh` instead of `stagehand.sh` for local Chrome debugging

### Script Variations

- **`stagehand.sh`**: Uses Browserbase cloud service
- **`stagehand-local.sh`**: Uses local Chrome with debugging enabled

### Environment-specific Notes

- **macOS**: Paths use `/Users/[username]`
- **Linux**: Paths would use `/home/[username]`
- **Windows**: Would require different path format and shell scripts

## File Structure

After setup, your directory structure should look like:

```
~/.claude/MCPs/
├── stagehand.sh                    # Main runner script
├── stagehand-local.sh             # Local Chrome runner
└── mcp-server-browserbase/
    └── stagehand/
        ├── dist/                  # Compiled JavaScript
        ├── src/                   # TypeScript source
        ├── package.json
        ├── tsconfig.json
        └── SETUP_INSTRUCTIONS.md  # This file
```

## Testing the Setup

1. Open Claude Desktop or Claude Code
2. Look for Stagehand in the available tools/MCPs
3. Try using a simple Stagehand command
4. Check the logs directory for any error messages:
   ```bash
   ls ~/.claude/MCPs/mcp-server-browserbase/stagehand/logs/
   ```

## Replicating on Other Machines

To replicate this setup on other machines:

1. Copy the entire `~/.claude/MCPs/` directory
2. Update username paths in all configuration files
3. Install Node.js and npm
4. Run `npm install` in the stagehand directory
5. Set up environment variables
6. Update Claude Desktop and Claude Code configurations
7. Restart applications

## Support

If you encounter issues:
1. Check the logs in `~/.claude/MCPs/mcp-server-browserbase/stagehand/logs/`
2. Verify all file permissions are correct
3. Ensure all environment variables are set
4. Try running the script manually to isolate issues