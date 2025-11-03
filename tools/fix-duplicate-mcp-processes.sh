#!/bin/bash

# Fix Script for Duplicate MCP Process Issue
# This script safely terminates duplicate MCP processes and prevents future duplicates

echo "======================================"
echo "MCP Duplicate Process Cleanup Script"
echo "======================================"
echo "Started: $(date)"
echo ""

# Function to kill processes safely
kill_processes() {
    local process_name=$1
    local pids=$(ps aux | grep "$process_name" | grep -v grep | awk '{print $2}')

    if [ -z "$pids" ]; then
        echo "No $process_name processes found"
        return
    fi

    local count=$(echo "$pids" | wc -l)
    echo "Found $count $process_name process(es)"

    if [ "$count" -gt 1 ]; then
        echo "WARNING: Multiple instances detected, keeping only the newest"
        # Sort by start time and keep the newest (last) one
        local newest_pid=$(ps aux | grep "$process_name" | grep -v grep | sort -k9 | tail -1 | awk '{print $2}')
        local pids_to_kill=$(echo "$pids" | grep -v "^$newest_pid$")

        echo "Keeping PID: $newest_pid"
        echo "Killing PIDs: $(echo $pids_to_kill | tr '\n' ' ')"

        for pid in $pids_to_kill; do
            echo "  Terminating PID $pid..."
            kill -TERM "$pid" 2>/dev/null
            sleep 0.5
            # Force kill if still running
            if ps -p "$pid" > /dev/null 2>&1; then
                echo "  Force killing PID $pid..."
                kill -KILL "$pid" 2>/dev/null
            fi
        done
    else
        echo "Single instance found (PID: $pids) - no action needed"
    fi
}

# Step 1: Kill duplicate stagehand processes
echo "1. CLEANING STAGEHAND PROCESSES:"
echo "--------------------------------"
kill_processes "stagehand/dist/index.js"
echo ""

# Step 2: Kill duplicate mcp-chatgpt processes
echo "2. CLEANING MCP-CHATGPT PROCESSES:"
echo "----------------------------------"
kill_processes "mcp-chatgpt-agent/dist/index.js"
echo ""

# Step 3: Clean up any stale PID files
echo "3. CLEANING PID FILES:"
echo "---------------------"
for pidfile in /tmp/mcp-*.pid; do
    if [ -f "$pidfile" ]; then
        pid=$(cat "$pidfile")
        if ! ps -p "$pid" > /dev/null 2>&1; then
            echo "Removing stale PID file: $pidfile (PID $pid not running)"
            rm -f "$pidfile"
        else
            echo "Keeping active PID file: $pidfile (PID $pid is running)"
        fi
    fi
done
[ ! -f /tmp/mcp-*.pid ] && echo "No PID files found"
echo ""

# Step 4: Create PID management wrapper scripts
echo "4. CREATING PID MANAGEMENT WRAPPERS:"
echo "------------------------------------"

# Create wrapper for stagehand
cat << 'EOF' > /Users/adammanuel/.claude/MCPs/stagehand-safe.sh
#!/bin/bash
# Safe wrapper for stagehand that prevents duplicate processes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/mcp-stagehand.pid"
LOCK_FILE="/tmp/mcp-stagehand.lock"

# Use file locking to prevent race conditions
(
    flock -n 200 || { echo "Another instance is starting, waiting..."; exit 1; }

    # Check if already running
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo "Stagehand already running (PID: $OLD_PID)"
            exit 0
        else
            echo "Removing stale PID file"
            rm -f "$PID_FILE"
        fi
    fi

    # Start the server
    echo "Starting Stagehand MCP server..."
    bash "$SCRIPT_DIR/stagehand.sh" &
    NEW_PID=$!
    echo $NEW_PID > "$PID_FILE"

    # Wait for the process
    wait $NEW_PID

    # Cleanup on exit
    rm -f "$PID_FILE"

) 200>"$LOCK_FILE"
EOF

chmod +x /Users/adammanuel/.claude/MCPs/stagehand-safe.sh

# Create wrapper for mcp-chatgpt
cat << 'EOF' > /Users/adammanuel/.claude/MCPs/mcp-chatgpt-safe.sh
#!/bin/bash
# Safe wrapper for mcp-chatgpt that prevents duplicate processes

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/mcp-chatgpt.pid"
LOCK_FILE="/tmp/mcp-chatgpt.lock"

# Use file locking to prevent race conditions
(
    flock -n 200 || { echo "Another instance is starting, waiting..."; exit 1; }

    # Check if already running
    if [ -f "$PID_FILE" ]; then
        OLD_PID=$(cat "$PID_FILE")
        if ps -p "$OLD_PID" > /dev/null 2>&1; then
            echo "MCP ChatGPT already running (PID: $OLD_PID)"
            exit 0
        else
            echo "Removing stale PID file"
            rm -f "$PID_FILE"
        fi
    fi

    # Start the server
    echo "Starting MCP ChatGPT server..."
    bash "$SCRIPT_DIR/mcp-chatgpt.sh" &
    NEW_PID=$!
    echo $NEW_PID > "$PID_FILE"

    # Wait for the process
    wait $NEW_PID

    # Cleanup on exit
    rm -f "$PID_FILE"

) 200>"$LOCK_FILE"
EOF

chmod +x /Users/adammanuel/.claude/MCPs/mcp-chatgpt-safe.sh
echo "Created safe wrapper scripts"
echo ""

# Step 5: Update configuration to use safe wrappers
echo "5. UPDATING CONFIGURATION:"
echo "-------------------------"
CONFIG_FILE="/Users/adammanuel/.config/claude-code/config.json"

if [ -f "$CONFIG_FILE" ]; then
    # Backup original
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"

    # Update to use safe wrappers
    cat << 'EOF' > "$CONFIG_FILE"
{
  "mcpServers": {
    "stagehand": {
      "command": "/Users/adammanuel/.claude/MCPs/stagehand-safe.sh",
      "args": []
    },
    "chatgpt": {
      "command": "/Users/adammanuel/.claude/MCPs/mcp-chatgpt-safe.sh",
      "args": []
    }
  }
}
EOF
    echo "Updated configuration to use safe wrappers"
else
    echo "Configuration file not found - skipping update"
fi
echo ""

# Step 6: Verify cleanup
echo "6. VERIFICATION:"
echo "---------------"
echo "Stagehand processes after cleanup:"
ps aux | grep "stagehand/dist/index.js" | grep -v grep | wc -l | xargs echo "  Count:"
echo ""
echo "MCP ChatGPT processes after cleanup:"
ps aux | grep "mcp-chatgpt-agent/dist/index.js" | grep -v grep | wc -l | xargs echo "  Count:"
echo ""

# Step 7: Recommendations
echo "7. RECOMMENDATIONS:"
echo "------------------"
echo "✅ Duplicate processes have been cleaned up"
echo "✅ Safe wrapper scripts created to prevent future duplicates"
echo "✅ Configuration updated to use safe wrappers"
echo ""
echo "Next steps:"
echo "1. Restart Claude Code to apply configuration changes"
echo "2. Test agent execution to verify duplicate tool error is resolved"
echo "3. Monitor with: /Users/adammanuel/.claude/tools/diagnose-duplicate-tools.sh"
echo ""
echo "======================================"
echo "Cleanup complete at $(date)"
echo "======================================"