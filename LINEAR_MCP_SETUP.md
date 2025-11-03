# Linear MCP Server Setup Guide

This guide helps you configure the Linear Model Context Protocol (MCP) server for Claude Code integration.

## Overview

The Linear MCP server enables Claude Code to:
- Fetch Linear issue details
- Create and update Linear issues
- Track time on issues
- Change issue status
- Add comments and labels
- Manage issue assignments

## Prerequisites

- Active Linear account with appropriate access
- Claude Code installed and configured
- Node.js installed (for npx-based setup)

## Configuration Methods

### Method 1: HTTP Transport (Recommended for Claude Code)

Create or edit `~/.config/claude-code/mcp_settings.json`:

```json
{
  "mcpServers": {
    "linear": {
      "url": "https://mcp.linear.app/mcp",
      "transport": "http"
    }
  }
}
```

### Method 2: SSE Transport (Alternative)

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/sse"]
    }
  }
}
```

## Setup Steps

1. **Create Configuration File** (if it doesn't exist):
   ```bash
   mkdir -p ~/.config/claude-code
   touch ~/.config/claude-code/mcp_settings.json
   ```

2. **Add Linear Configuration**:
   Copy the JSON configuration from Method 1 above into the file

3. **Restart Claude Code**:
   ```bash
   # Exit Claude Code completely and restart
   # The MCP server will initialize on startup
   ```

4. **Authenticate** (on first use):
   - Linear will prompt for OAuth authentication
   - Follow the browser flow to authorize
   - Credentials are cached in `~/.mcp-auth/`

5. **Verify Installation**:
   - In Claude Code, check for available MCP tools
   - Look for tools prefixed with `mcp__linear__*`
   - Test by fetching an issue: "Fetch Linear issue ENG-123"

## Authentication

### OAuth Flow (Default)
- Uses OAuth 2.1 with dynamic client registration
- Interactive browser-based authentication
- Tokens cached locally for reuse
- Supports both personal and app-user workflows

### API Token (Alternative)
If you prefer using a personal API token:

1. Generate token in Linear: Settings → API → Personal API Keys
2. Set environment variable:
   ```bash
   export LINEAR_API_KEY="lin_api_xxxxx"
   ```
3. Restart Claude Code

### Troubleshooting Authentication

**Clear cached credentials:**
```bash
rm -rf ~/.mcp-auth/linear
```

**Re-authenticate:**
- Restart Claude Code after clearing cache
- Authentication prompt will appear on next Linear MCP usage

## Available Tools

Once configured, the Linear MCP server provides these capabilities:

- **Find Issues**: Search and retrieve issue details
- **Create Issues**: Create new Linear issues
- **Update Issues**: Modify issue properties
- **Change Status**: Update workflow state
- **Add Comments**: Post comments on issues
- **Log Time**: Track time spent on issues
- **Manage Labels**: Add/remove issue labels
- **Handle Assignments**: Assign/unassign team members

## Usage Examples

### Fetch Issue Details
```
/linear-task ENG-123
```

### Create Issue from Description
```
Create Linear issue: "Add user authentication"
Priority: High
Team: Engineering
```

### Update Issue Status
```
Update ENG-123 to "In Progress"
```

### Log Time
```
Log 2.5 hours to issue ENG-123
```

## Integration with Custom Commands

### /linear-task Command

The `/linear-task` command provides a complete workflow:

```bash
# Execute a Linear issue end-to-end
/linear-task ENG-123
```

**This command will:**
1. Fetch issue details from Linear
2. Create feature branch: `feature/ENG-123-issue-title`
3. Implement with @agent-ts-coder
4. Review with @agent-senior-code-reviewer
5. Apply fixes with @agent-ts-coder
6. Track time automatically
7. Update Linear issue with completion details
8. Mark issue as Done

## Troubleshooting

### MCP Tools Not Available

**Symptoms:**
- No `mcp__linear__*` tools visible
- Claude Code doesn't recognize Linear commands

**Solutions:**
1. Verify configuration file location and format
2. Check JSON syntax (use `jq` or online validator)
3. Restart Claude Code completely
4. Check logs: `~/.claude-code/logs/`

### Authentication Failures

**Symptoms:**
- "Unauthorized" errors
- Authentication prompts don't appear

**Solutions:**
1. Clear auth cache: `rm -rf ~/.mcp-auth/linear`
2. Verify Linear account access
3. Check network connectivity to `mcp.linear.app`
4. Try API token method instead

### Issue Not Found

**Symptoms:**
- "Issue not found" errors
- Permission denied messages

**Solutions:**
1. Verify issue ID format: `TEAM-123` (not just `123`)
2. Check issue exists in your Linear workspace
3. Confirm you have access to the team/project
4. Verify issue isn't archived or deleted

### Slow Performance

**Symptoms:**
- Long delays fetching issue data
- Timeout errors

**Solutions:**
1. Check network latency to Linear servers
2. Try SSE transport instead of HTTP
3. Reduce concurrent requests
4. Check Linear API status: https://status.linear.app

## Advanced Configuration

### Custom Timeout
```json
{
  "mcpServers": {
    "linear": {
      "url": "https://mcp.linear.app/mcp",
      "transport": "http",
      "timeout": 30000
    }
  }
}
```

### Team-Specific Configuration
```json
{
  "mcpServers": {
    "linear-eng": {
      "url": "https://mcp.linear.app/mcp",
      "transport": "http",
      "env": {
        "LINEAR_TEAM": "ENG"
      }
    },
    "linear-product": {
      "url": "https://mcp.linear.app/mcp",
      "transport": "http",
      "env": {
        "LINEAR_TEAM": "PRODUCT"
      }
    }
  }
}
```

### Proxy Configuration
```json
{
  "mcpServers": {
    "linear": {
      "url": "https://mcp.linear.app/mcp",
      "transport": "http",
      "env": {
        "HTTP_PROXY": "http://proxy.company.com:8080",
        "HTTPS_PROXY": "http://proxy.company.com:8080"
      }
    }
  }
}
```

## Security Best Practices

1. **Never commit credentials** to git repositories
2. **Use environment variables** for sensitive config
3. **Rotate tokens regularly** if using API key method
4. **Limit token scope** to minimum required permissions
5. **Monitor token usage** in Linear settings
6. **Revoke unused tokens** immediately

## Resources

- **Linear MCP Docs**: https://linear.app/docs/mcp
- **Linear API Docs**: https://developers.linear.app/docs
- **MCP Protocol Spec**: https://spec.modelcontextprotocol.io
- **Claude Code Docs**: https://docs.claude.com/claude-code

## Support

**Linear Issues:**
- Linear Support: https://linear.app/support
- Linear Community: https://linear.app/community

**Claude Code Issues:**
- GitHub Issues: https://github.com/anthropics/claude-code/issues
- Documentation: https://docs.claude.com/claude-code

## Verification Checklist

After setup, verify these items:

- [ ] Configuration file exists at `~/.config/claude-code/mcp_settings.json`
- [ ] JSON syntax is valid
- [ ] Claude Code restarted after configuration
- [ ] Authentication completed successfully
- [ ] Linear MCP tools visible in Claude Code
- [ ] Can fetch a test issue successfully
- [ ] `/linear-task` command recognized
- [ ] Time tracking works correctly
- [ ] Issue status updates succeed

Once all items are checked, you're ready to use the `/linear-task` command!
