#!/bin/bash
# Update Claude Code configuration to use safe MCP wrappers

echo "======================================="
echo "MCP Configuration Update Script"
echo "======================================="
echo "Started: $(date)"
echo

CONFIG_FILE="/Users/adammanuel/.config/claude-code/config.json"
BACKUP_FILE="/Users/adammanuel/.config/claude-code/config.json.backup-$(date +%Y%m%d-%H%M%S)"

# Function to kill all MCP processes
cleanup_processes() {
    echo "1. CLEANING UP EXISTING MCP PROCESSES:"
    echo "--------------------------------------"

    # Kill all MCP-related processes
    local processes=(
        "mcp-postman/build/index.js"
        "stagehand/dist/index.js"
        "context7-mcp"
        "@upstash/context7-mcp"
        "mcp-chatgpt-agent"
        "ios-simulator.*index.js"
        "claude-memory"
    )

    for pattern in "${processes[@]}"; do
        if pgrep -f "$pattern" > /dev/null 2>&1; then
            echo "  Killing processes matching: $pattern"
            pkill -f "$pattern" 2>/dev/null
        fi
    done

    # Clean up Docker containers
    if docker ps -a --format '{{.Names}}' | grep -q "^mcp-memory$"; then
        echo "  Stopping and removing mcp-memory Docker container"
        docker stop mcp-memory 2>/dev/null
        docker rm mcp-memory 2>/dev/null
    fi

    echo "  Process cleanup complete"
    echo
}

# Function to clean up PID files
cleanup_pid_files() {
    echo "2. CLEANING UP PID FILES:"
    echo "------------------------"

    rm -f /tmp/mcp-*.pid 2>/dev/null
    echo "  Removed all MCP PID files"
    echo
}

# Function to update configuration
update_config() {
    echo "3. UPDATING CONFIGURATION:"
    echo "-------------------------"

    # Backup current config
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_FILE"
        echo "  Created backup: $BACKUP_FILE"
    fi

    # Create new configuration with safe wrappers
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "stagehand": {
      "command": "/Users/adammanuel/.claude/MCPs/stagehand-safe.sh",
      "args": []
    },
    "stagehand-fresh": {
      "command": "/Users/adammanuel/.claude/MCPs/stagehand-fresh-safe.sh",
      "args": []
    },
    "stagehand-local": {
      "command": "/Users/adammanuel/.claude/MCPs/stagehand-local-safe.sh",
      "args": []
    },
    "chatgpt": {
      "command": "/Users/adammanuel/.claude/MCPs/mcp-chatgpt-safe.sh",
      "args": []
    },
    "postman": {
      "command": "/Users/adammanuel/.claude/MCPs/postman-safe.sh",
      "args": []
    },
    "context7": {
      "command": "/Users/adammanuel/.claude/MCPs/context7-safe.sh",
      "args": []
    },
    "claude-memory": {
      "command": "/Users/adammanuel/.claude/MCPs/claude-memory-safe.sh",
      "args": []
    },
    "ios-simulator": {
      "command": "/Users/adammanuel/.claude/MCPs/ios-simulator-safe.sh",
      "args": []
    }
  }
}
EOF

    echo "  Updated configuration to use safe wrappers"
    echo
}

# Function to verify configuration
verify_config() {
    echo "4. VERIFYING CONFIGURATION:"
    echo "---------------------------"

    if [ -f "$CONFIG_FILE" ]; then
        echo "  Configuration file exists"

        # Count MCP servers configured
        local server_count=$(grep -c '"command"' "$CONFIG_FILE")
        echo "  Number of MCP servers configured: $server_count"

        # Check if all use safe wrappers
        local safe_count=$(grep -c "safe.sh" "$CONFIG_FILE")
        echo "  Number using safe wrappers: $safe_count"

        if [ "$server_count" -eq "$safe_count" ]; then
            echo "  ✅ All MCP servers use safe wrappers"
        else
            echo "  ⚠️  Warning: Not all servers use safe wrappers"
        fi
    else
        echo "  ❌ Configuration file not found!"
    fi
    echo
}

# Function to list safe wrapper scripts
list_wrappers() {
    echo "5. AVAILABLE SAFE WRAPPERS:"
    echo "---------------------------"

    ls -la /Users/adammanuel/.claude/MCPs/*-safe.sh 2>/dev/null | awk '{print "  " $NF}' | sed 's|.*/||'
    echo
}

# Main execution
main() {
    cleanup_processes
    cleanup_pid_files
    update_config
    verify_config
    list_wrappers

    echo "======================================="
    echo "SUMMARY:"
    echo "======================================="
    echo "✅ All MCP processes have been terminated"
    echo "✅ PID files have been cleaned up"
    echo "✅ Configuration updated to use safe wrappers"
    echo "✅ Safe wrappers prevent duplicate processes"
    echo
    echo "NEXT STEPS:"
    echo "1. Restart Claude Code to apply the new configuration"
    echo "2. Test MCP functionality with agents"
    echo "3. Monitor with: /Users/adammanuel/.claude/tools/diagnose-duplicate-tools.sh"
    echo
    echo "======================================="
    echo "Update complete at $(date)"
    echo "======================================="
}

# Run main function
main