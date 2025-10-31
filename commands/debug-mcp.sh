#!/bin/bash

echo "=== MCP Connection Debug Script ==="
echo

# Check environment variables
echo "1. Checking environment variables..."
echo -n "BROWSERBASE_API_KEY: "
if [ -n "$BROWSERBASE_API_KEY" ]; then echo "SET (hidden)"; else echo "NOT SET"; fi
echo -n "BROWSERBASE_PROJECT_ID: "
if [ -n "$BROWSERBASE_PROJECT_ID" ]; then echo "SET (hidden)"; else echo "NOT SET"; fi
echo -n "OPENAI_API_KEY: "
if [ -n "$OPENAI_API_KEY" ]; then echo "SET (hidden)"; else echo "NOT SET"; fi
echo

# Check file permissions
echo "2. Checking file permissions..."
ls -la /Users/adammanuel/.claude/MCPs/stagehand.sh
ls -la /Users/adammanuel/.claude/MCPs/mcp-server-browserbase/stagehand/dist/index.js
echo

# Check Node.js version
echo "3. Checking Node.js version..."
node --version
echo

# Check if stagehand is built
echo "4. Checking if stagehand is built..."
if [ -f "/Users/adammanuel/.claude/MCPs/mcp-server-browserbase/stagehand/dist/index.js" ]; then
    echo "✓ dist/index.js exists"
else
    echo "✗ dist/index.js missing - need to run 'npm run build'"
fi
echo

# Check dependencies
echo "5. Checking dependencies..."
cd /Users/adammanuel/.claude/MCPs/mcp-server-browserbase/stagehand
if [ -d "node_modules" ]; then
    echo "✓ node_modules exists"
    echo "  Checking key dependencies:"
    [ -d "node_modules/@modelcontextprotocol/sdk" ] && echo "  ✓ @modelcontextprotocol/sdk installed" || echo "  ✗ @modelcontextprotocol/sdk missing"
    [ -d "node_modules/@browserbasehq/stagehand" ] && echo "  ✓ @browserbasehq/stagehand installed" || echo "  ✗ @browserbasehq/stagehand missing"
else
    echo "✗ node_modules missing - need to run 'npm install'"
fi
echo

# Check Claude configurations
echo "6. Checking Claude configurations..."
echo "Claude Desktop config:"
if [ -f "/Users/adammanuel/Library/Application Support/Claude/claude_desktop_config.json" ]; then
    cat "/Users/adammanuel/Library/Application Support/Claude/claude_desktop_config.json" | jq -r '.mcpServers.stagehand' 2>/dev/null || echo "  (unable to parse)"
else
    echo "  ✗ Config file not found"
fi
echo
echo "Claude Code config:"
if [ -f "/Users/adammanuel/.config/claude-code/config.json" ]; then
    cat "/Users/adammanuel/.config/claude-code/config.json" | jq -r '.mcpServers.stagehand' 2>/dev/null || echo "  (unable to parse)"
else
    echo "  ✗ Config file not found"
fi
echo

# Test running the script
echo "7. Testing stagehand script..."
echo "Running: /Users/adammanuel/.claude/MCPs/stagehand.sh"
echo "(Will timeout after 3 seconds)"
echo "---"
timeout 3 /Users/adammanuel/.claude/MCPs/stagehand.sh 2>&1 || true
echo "---"
echo

# Check recent logs
echo "8. Recent log entries..."
LOG_DIR="/Users/adammanuel/.claude/MCPs/mcp-server-browserbase/stagehand/logs"
if [ -d "$LOG_DIR" ]; then
    LATEST_LOG=$(ls -1t "$LOG_DIR"/*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ]; then
        echo "Latest log: $LATEST_LOG"
        echo "Last 10 lines:"
        tail -10 "$LATEST_LOG"
    else
        echo "No log files found"
    fi
else
    echo "Log directory not found"
fi
echo

echo "=== Debug complete ==="
echo
echo "Common fixes:"
echo "1. Set environment variables in your shell profile (~/.zshrc or ~/.bashrc):"
echo "   export BROWSERBASE_API_KEY='your-key'"
echo "   export BROWSERBASE_PROJECT_ID='your-project-id'"
echo "   export OPENAI_API_KEY='your-key'"
echo
echo "2. Rebuild stagehand if needed:"
echo "   cd ~/.claude/MCPs/mcp-server-browserbase/stagehand"
echo "   npm install && npm run build"
echo
echo "3. Restart Claude Desktop/Code after making changes"