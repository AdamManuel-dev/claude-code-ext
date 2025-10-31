#!/bin/bash

# Agent Log Utilities
# Helper functions for managing agent.log
#
# Usage: agent-log-utils.sh [command]
# Commands:
#   init      - Initialize agent.log for a new session
#   archive   - Archive current agent.log with timestamp
#   clean     - Remove old archived logs (keep last 10)
#   summary   - Display summary of recent agent activity
#   clear     - Clear current agent.log (with backup)

AGENT_LOG="/Users/adammanuel/.claude/agent.log"
ARCHIVE_DIR="/Users/adammanuel/.claude/logs/archive"

# Ensure archive directory exists
mkdir -p "$ARCHIVE_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

init_log() {
  echo -e "${BLUE}Initializing agent.log for new session...${NC}"

  # Archive existing log if it has content
  if [ -s "$AGENT_LOG" ]; then
    archive_log
  fi

  # Create fresh log
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[$TIMESTAMP] [SYSTEM] [INIT] Agent log initialized" > "$AGENT_LOG"

  echo -e "${GREEN}✅ Agent log initialized${NC}"
}

archive_log() {
  if [ ! -f "$AGENT_LOG" ]; then
    echo -e "${YELLOW}No agent.log to archive${NC}"
    return
  fi

  TIMESTAMP=$(date -u +"%Y%m%d-%H%M%S")
  ARCHIVE_FILE="$ARCHIVE_DIR/agent-log-$TIMESTAMP.txt"

  cp "$AGENT_LOG" "$ARCHIVE_FILE"
  echo -e "${GREEN}✅ Archived to: $ARCHIVE_FILE${NC}"

  # Compress to save space
  gzip "$ARCHIVE_FILE"
  echo -e "${GREEN}✅ Compressed: $ARCHIVE_FILE.gz${NC}"
}

clean_archives() {
  echo -e "${BLUE}Cleaning old archived logs...${NC}"

  # Keep last 10 archives
  cd "$ARCHIVE_DIR" || return

  # Count archives
  ARCHIVE_COUNT=$(ls -1 agent-log-*.txt.gz 2>/dev/null | wc -l)

  if [ "$ARCHIVE_COUNT" -le 10 ]; then
    echo -e "${GREEN}✅ No cleanup needed (${ARCHIVE_COUNT} archives, keeping last 10)${NC}"
    return
  fi

  # Remove oldest archives beyond last 10
  ls -1t agent-log-*.txt.gz | tail -n +11 | xargs rm -f

  REMOVED=$((ARCHIVE_COUNT - 10))
  echo -e "${GREEN}✅ Removed ${REMOVED} old archives${NC}"
}

display_summary() {
  if [ ! -f "$AGENT_LOG" ]; then
    echo -e "${YELLOW}No agent.log found${NC}"
    return
  fi

  echo -e "${BLUE}=== Agent Activity Summary ===${NC}"
  echo ""

  # Count events by type
  START_COUNT=$(grep -c "\[START\]" "$AGENT_LOG" 2>/dev/null || echo "0")
  PROGRESS_COUNT=$(grep -c "\[PROGRESS\]" "$AGENT_LOG" 2>/dev/null || echo "0")
  COMPLETE_COUNT=$(grep -c "\[COMPLETE\]" "$AGENT_LOG" 2>/dev/null || echo "0")
  ERROR_COUNT=$(grep -c "\[ERROR\]" "$AGENT_LOG" 2>/dev/null || echo "0")

  echo -e "Started:   ${BLUE}$START_COUNT${NC}"
  echo -e "Progress:  ${YELLOW}$PROGRESS_COUNT${NC}"
  echo -e "Completed: ${GREEN}$COMPLETE_COUNT${NC}"
  echo -e "Errors:    ${RED}$ERROR_COUNT${NC}"
  echo ""

  # Display recent completions
  echo -e "${BLUE}Recent Completions:${NC}"
  grep "\[COMPLETE\]" "$AGENT_LOG" | tail -5 | while IFS= read -r line; do
    echo -e "${GREEN}$line${NC}"
  done
  echo ""

  # Display recent errors if any
  if [ "$ERROR_COUNT" -gt 0 ]; then
    echo -e "${RED}Recent Errors:${NC}"
    grep "\[ERROR\]" "$AGENT_LOG" | tail -3 | while IFS= read -r line; do
      echo -e "${RED}$line${NC}"
    done
    echo ""
  fi

  # Display aggregate summary if exists
  if grep -q "\[ORCHESTRATOR\] \[AGGREGATE\]" "$AGENT_LOG"; then
    echo -e "${BLUE}Aggregate Summary:${NC}"
    grep "\[ORCHESTRATOR\] \[AGGREGATE\]" "$AGENT_LOG" | tail -1 | while IFS= read -r line; do
      echo -e "${GREEN}$line${NC}"
    done
  fi
}

clear_log() {
  echo -e "${YELLOW}Clearing agent.log...${NC}"

  # Archive first
  if [ -s "$AGENT_LOG" ]; then
    archive_log
  fi

  # Clear the log
  > "$AGENT_LOG"

  echo -e "${GREEN}✅ Agent log cleared (backup archived)${NC}"
}

# Command dispatcher
case "${1:-summary}" in
  init)
    init_log
    ;;
  archive)
    archive_log
    ;;
  clean)
    clean_archives
    ;;
  summary)
    display_summary
    ;;
  clear)
    clear_log
    ;;
  *)
    echo "Usage: agent-log-utils.sh [command]"
    echo ""
    echo "Commands:"
    echo "  init      - Initialize agent.log for a new session"
    echo "  archive   - Archive current agent.log with timestamp"
    echo "  clean     - Remove old archived logs (keep last 10)"
    echo "  summary   - Display summary of recent agent activity"
    echo "  clear     - Clear current agent.log (with backup)"
    exit 1
    ;;
esac
