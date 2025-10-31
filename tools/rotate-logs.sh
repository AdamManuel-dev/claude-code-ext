#!/bin/bash
# Log rotation script for Claude Code logs
# Rotates logs when they exceed 10MB, keeps last 5 rotations

LOG_DIR="/Users/adammanuel/.claude/.old_claude"
MAX_SIZE=10485760  # 10MB in bytes

# Function to get file size cross-platform
get_file_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$1" 2>/dev/null || echo "0"
    else
        stat -c%s "$1" 2>/dev/null || echo "0"
    fi
}

# Function to rotate a log file
rotate_log() {
    local log_file="$1"
    local log_path="$LOG_DIR/$log_file"

    if [ ! -f "$log_path" ]; then
        return 0
    fi

    local size=$(get_file_size "$log_path")

    if [ "$size" -gt "$MAX_SIZE" ]; then
        echo "[$(date)] Rotating $log_file (size: $size bytes)"

        # Create rotated filename with timestamp
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local rotated_file="$log_path.$timestamp"

        # Move current log to rotated file
        mv "$log_path" "$rotated_file"

        # Create new empty log file
        touch "$log_path"

        # Keep only last 5 rotated logs
        ls -t "$log_path".* 2>/dev/null | tail -n +6 | while read old_log; do
            echo "[$(date)] Removing old rotation: $old_log"
            rm -f "$old_log"
        done

        echo "[$(date)] Rotation complete for $log_file"
    fi
}

# Main rotation logic
echo "[$(date)] Starting log rotation check..."

# Rotate each log file
for log_file in agent.log debug.log metrics.log; do
    rotate_log "$log_file"
done

# Also check for any .log files that might exist
for log_path in "$LOG_DIR"/*.log; do
    if [ -f "$log_path" ]; then
        log_file=$(basename "$log_path")
        # Skip if already processed
        if [[ "$log_file" != "agent.log" && "$log_file" != "debug.log" && "$log_file" != "metrics.log" ]]; then
            rotate_log "$log_file"
        fi
    fi
done

echo "[$(date)] Log rotation check complete"