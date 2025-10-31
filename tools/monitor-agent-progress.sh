#!/bin/bash

# Agent Progress Monitor
# Real-time monitoring tool for agent.log progress tracking
#
# Usage: monitor-agent-progress.sh [agent_name] [poll_interval_seconds]
# Example: monitor-agent-progress.sh intelligent-docs 30

AGENT_LOG="/Users/adammanuel/.claude/agent.log"
AGENT_NAME="${1:-all}" # Default to monitoring all agents
POLL_INTERVAL="${2:-30}" # Default to 30 seconds

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ensure agent.log exists
touch "$AGENT_LOG"

echo -e "${BLUE}=== Agent Progress Monitor ===${NC}"
echo -e "Monitoring: ${YELLOW}$AGENT_NAME${NC}"
echo -e "Poll Interval: ${YELLOW}${POLL_INTERVAL}s${NC}"
echo -e "Log File: ${YELLOW}$AGENT_LOG${NC}"
echo ""

# Track last read position to avoid re-reading
LAST_LINE=0

monitor_progress() {
  # Get total lines in log
  TOTAL_LINES=$(wc -l < "$AGENT_LOG" 2>/dev/null || echo "0")

  if [ "$TOTAL_LINES" -gt "$LAST_LINE" ]; then
    # Read new lines since last check
    NEW_LINES=$(tail -n +$((LAST_LINE + 1)) "$AGENT_LOG")

    # Filter by agent name if specified
    if [ "$AGENT_NAME" != "all" ]; then
      NEW_LINES=$(echo "$NEW_LINES" | grep "\[$AGENT_NAME\]")
    fi

    # Display progress lines
    if [ -n "$NEW_LINES" ]; then
      echo "$NEW_LINES" | while IFS= read -r line; do
        # Color code by status
        if echo "$line" | grep -q "\[START\]"; then
          echo -e "${BLUE}$line${NC}"
        elif echo "$line" | grep -q "\[PROGRESS\]"; then
          echo -e "${YELLOW}$line${NC}"
        elif echo "$line" | grep -q "\[COMPLETE\]"; then
          echo -e "${GREEN}$line${NC}"
        elif echo "$line" | grep -q "\[ERROR\]"; then
          echo -e "${RED}$line${NC}"
        else
          echo "$line"
        fi
      done
    fi

    LAST_LINE=$TOTAL_LINES
  fi

  # Check for completion
  if grep -q "\[ORCHESTRATOR\] \[AGGREGATE\]" "$AGENT_LOG"; then
    echo ""
    echo -e "${GREEN}=== All Agents Completed ===${NC}"

    # Display aggregate summary
    AGGREGATE_LINE=$(grep "\[ORCHESTRATOR\] \[AGGREGATE\]" "$AGENT_LOG" | tail -1)
    echo -e "${GREEN}$AGGREGATE_LINE${NC}"

    return 0 # Signal completion
  fi

  return 1 # Continue monitoring
}

# Initial display of recent history
echo -e "${BLUE}Recent Activity:${NC}"
tail -20 "$AGENT_LOG" | while IFS= read -r line; do
  if echo "$line" | grep -q "\[START\]\|\[PROGRESS\]\|\[COMPLETE\]"; then
    echo "$line"
  fi
done
echo ""

# Main monitoring loop
echo -e "${BLUE}Live Monitoring (Ctrl+C to stop):${NC}"
echo ""

while true; do
  if monitor_progress; then
    # Completed
    break
  fi

  sleep "$POLL_INTERVAL"
done

echo ""
echo -e "${GREEN}Monitoring complete.${NC}"
