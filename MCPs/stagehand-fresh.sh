#!/bin/bash

# Stagehand MCP Server Runner
# This script runs the stagehand MCP server with the required environment variables

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the stagehand compiled JavaScript file
STAGEHAND_PATH="$SCRIPT_DIR/mcp-server-browserbase/stagehand/dist/index.js"

# Check if the stagehand file exists and is readable
if [ ! -f "$STAGEHAND_PATH" ]; then
    echo "Error: Stagehand file not found at $STAGEHAND_PATH" >&2
    echo "Please ensure the stagehand project is built and the dist/index.js file exists." >&2
    exit 1
fi

if [ ! -r "$STAGEHAND_PATH" ]; then
    echo "Error: Stagehand file is not readable at $STAGEHAND_PATH" >&2
    echo "Please check file permissions." >&2
    exit 1
fi

# Load environment variables from .env file if it exists
ENV_FILE="/Users/adammanuel/.claude/.env"
if [ -f "$ENV_FILE" ]; then
    # Redirect debug output to stderr to avoid polluting stdout
    echo "Loading environment variables from $ENV_FILE" >&2
    set -a  # Mark variables which are modified or created for export
    source "$ENV_FILE"
    set +a  # Disable the above
else
    echo "Warning: .env file not found at $ENV_FILE" >&2
fi

# Set environment variables (will use values from .env if loaded)
export BROWSERBASE_API_KEY="${BROWSERBASE_API_KEY}"
export BROWSERBASE_PROJECT_ID="${BROWSERBASE_PROJECT_ID}"
export OPENAI_API_KEY="${OPENAI_API_KEY}"

# Don't use persistent context - let BrowserBase create a fresh one each time
# This avoids issues with stale or inaccessible browser contexts
unset CONTEXT_ID

# Run the stagehand MCP server
# All debug output goes to stderr to avoid interfering with MCP protocol
echo "Starting Stagehand MCP Server..." >&2
echo "Using stagehand path: $STAGEHAND_PATH" >&2
echo "Environment variables:" >&2
echo "  BROWSERBASE_API_KEY: ${BROWSERBASE_API_KEY:0:10}..." >&2
echo "  BROWSERBASE_PROJECT_ID: $BROWSERBASE_PROJECT_ID" >&2
echo "  OPENAI_API_KEY: ${OPENAI_API_KEY:0:10}..." >&2
echo "  CONTEXT_ID: (fresh session - not persisted)" >&2

# Use a modern Node.js version that supports optional chaining
NODE_PATH="/Users/adammanuel/.nvm/versions/node/v20.15.1/bin/node"
if [ -x "$NODE_PATH" ]; then
    "$NODE_PATH" "$STAGEHAND_PATH"
else
    # Fallback to system node
    node "$STAGEHAND_PATH"
fi
