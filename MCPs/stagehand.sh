#!/bin/bash

# Stagehand MCP Server Runner
# This script runs the stagehand MCP server with the required environment variables

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the stagehand compiled JavaScript file
STAGEHAND_PATH="$SCRIPT_DIR/mcp-server-browserbase/stagehand/dist/index.js"

# Check if the stagehand file exists
if [ ! -f "$STAGEHAND_PATH" ]; then
    echo "Error: Stagehand file not found at $STAGEHAND_PATH"
    echo "Please ensure the stagehand project is built and the dist/index.js file exists."
    exit 1
fi

# Set environment variables (replace with your actual values)
export BROWSERBASE_API_KEY="${BROWSERBASE_API_KEY}"
export BROWSERBASE_PROJECT_ID="${BROWSERBASE_PROJECT_ID}"
export OPENAI_API_KEY="${OPENAI_API_KEY}"

# Generate a random context ID if not provided
if [ -z "$CONTEXT_ID" ]; then
    CONTEXT_ID=$(uuidgen 2>/dev/null || echo "context_$(date +%s)_$(openssl rand -hex 8)")
fi
export CONTEXT_ID

# Run the stagehand MCP server
echo "Starting Stagehand MCP Server..."
echo "Using stagehand path: $STAGEHAND_PATH"

node "$STAGEHAND_PATH"
