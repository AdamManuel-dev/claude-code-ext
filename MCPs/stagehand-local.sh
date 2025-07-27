#!/bin/bash

# Stagehand MCP Server Runner (Local Chrome)
# This script runs the stagehand MCP server with local Chrome debugging

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

# Chrome debug configuration
CHROME_DEBUG_URL="http://localhost:9222"
CHROME_PID=""
CHROME_STARTED_BY_SCRIPT=false

# Function to start Chrome in debug mode
start_chrome_debug() {
    # First check if Chrome is already running with debug port
    if ps aux | grep -i "chrome.*remote-debugging-port=9222" | grep -v grep > /dev/null; then
        echo "Chrome is already running with --remote-debugging-port=9222"
        echo "Attempting to connect..."
        return 0
    fi
    
    echo "Closing all Chrome instances..."
    echo "This will close all Chrome instances. Do you want to continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Aborted by user."
        exit 0
    fi
    pkill -f "Google Chrome"
    
    # wait for chrome to close
    for i in {1..30}; do
        if ! pgrep -f "Google Chrome"; then
            break
        fi
        sleep 1
    done
    
    echo "Starting Chrome in debug mode..."
    # Use the full Chrome executable path for better control
    CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    if [ ! -f "$CHROME_PATH" ]; then
        echo "Error: Chrome not found at $CHROME_PATH"
        return 1
    fi
    
    echo "Running: \"$CHROME_PATH\" --remote-debugging-port=9222 --no-first-run --no-default-browser-check"
    "$CHROME_PATH" --remote-debugging-port=9222 --no-first-run --no-default-browser-check &
    CHROME_PID=$!
    CHROME_STARTED_BY_SCRIPT=true
    
    # Wait for Chrome to start and be ready
    echo "Waiting for Chrome to start..."
    for i in {1..30}; do
        # Test the debug endpoint
        if response=$(curl -s "$CHROME_DEBUG_URL/json/version" 2>&1); then
            echo ""
            echo "Chrome is ready for debugging!"
            echo "Debug URL: $CHROME_DEBUG_URL"
            return 0
        fi
        
        # Every 5 seconds, check if the process is still running
        if [ $((i % 5)) -eq 0 ]; then
            if [ ! -z "$CHROME_PID" ] && ! kill -0 "$CHROME_PID" 2>/dev/null; then
                echo ""
                echo "Error: Chrome process terminated unexpectedly"
                return 1
            fi
        fi
        
        echo -n "."
        sleep 1
    done
    echo ""
    
    echo "Error: Chrome failed to start in debug mode within 30 seconds"
    echo "Checking Chrome processes:"
    ps aux | grep -i "chrome.*remote-debugging" | grep -v grep || echo "No Chrome process found with --remote-debugging-port flag"
    return 1
}

# Function to cleanup Chrome process on exit
cleanup() {
    if [ "$CHROME_STARTED_BY_SCRIPT" = true ] && [ ! -z "$CHROME_PID" ]; then
        echo "Cleaning up Chrome process..."
        kill "$CHROME_PID" 2>/dev/null
    fi
}

# Set up cleanup on script exit
trap cleanup EXIT

# Check if Chrome is already running in debug mode, if not start it
if ! curl -s "$CHROME_DEBUG_URL/json" > /dev/null 2>&1; then
    if ! start_chrome_debug; then
        exit 1
    fi
else
    echo "Chrome is already running in debug mode."
fi

# Set environment variables
export OPENAI_API_KEY="${OPENAI_API_KEY}"
export LOCAL_CDP_URL="$CHROME_DEBUG_URL"

# Generate a random context ID if not provided
if [ -z "$CONTEXT_ID" ]; then
    CONTEXT_ID=$(uuidgen 2>/dev/null || echo "context_$(date +%s)_$(openssl rand -hex 8)")
fi
export CONTEXT_ID

# Run the stagehand MCP server
echo "Starting Stagehand MCP Server (Local Chrome)..."
echo "Using stagehand path: $STAGEHAND_PATH"
echo "Chrome debug URL: $LOCAL_CDP_URL"
echo "Context ID: $CONTEXT_ID"

node "$STAGEHAND_PATH" 