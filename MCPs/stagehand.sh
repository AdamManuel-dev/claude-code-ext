#!/bin/bash

# Stagehand MCP Server Runner
# This script runs the stagehand MCP server with the required environment variables

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the stagehand compiled JavaScript file
STAGEHAND_PATH="$SCRIPT_DIR/mcp-server-browserbase/stagehand/dist/index.js"

# Check if the stagehand file exists and is readable
if [ ! -f "$STAGEHAND_PATH" ]; then
    echo "Error: Stagehand file not found at $STAGEHAND_PATH"
    echo "Please ensure the stagehand project is built and the dist/index.js file exists."
    exit 1
fi

if [ ! -r "$STAGEHAND_PATH" ]; then
    echo "Error: Stagehand file is not readable at $STAGEHAND_PATH"
    echo "Please check file permissions."
    exit 1
fi

# Load environment variables from .env file if it exists
ENV_FILE="/Users/adammanuel/.claude/.env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE"
    set -a  # Mark variables which are modified or created for export
    source "$ENV_FILE"
    set +a  # Disable the above
else
    echo "Warning: .env file not found at $ENV_FILE"
fi

# Set environment variables (will use values from .env if loaded)
export BROWSERBASE_API_KEY="${BROWSERBASE_API_KEY}"
export BROWSERBASE_PROJECT_ID="${BROWSERBASE_PROJECT_ID}"
export OPENAI_API_KEY="${OPENAI_API_KEY}"

# Generate a random context ID if not provided
if [ -z "$CONTEXT_ID" ]; then
    # Try multiple methods for generating unique ID
    if command -v uuidgen >/dev/null 2>&1; then
        CONTEXT_ID=$(uuidgen)
    elif command -v openssl >/dev/null 2>&1; then
        CONTEXT_ID="context_$(date +%s)_$(openssl rand -hex 8)"
    else
        # Fallback using built-in shell features
        CONTEXT_ID="context_$(date +%s)_${RANDOM}"
    fi
fi
export CONTEXT_ID

# Run the stagehand MCP server
echo "Starting Stagehand MCP Server..."
echo "Using stagehand path: $STAGEHAND_PATH"
echo "Environment variables:"
echo "  BROWSERBASE_API_KEY: ${BROWSERBASE_API_KEY:0:10}..."
echo "  BROWSERBASE_PROJECT_ID: $BROWSERBASE_PROJECT_ID"
echo "  OPENAI_API_KEY: ${OPENAI_API_KEY:0:10}..."
echo "  CONTEXT_ID: $CONTEXT_ID"

node "$STAGEHAND_PATH"
