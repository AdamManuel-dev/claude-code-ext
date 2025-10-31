#!/bin/bash
# Quality Watch Orchestrator - Continuous quality assurance in background
# Monitors TypeScript, Tests, and ESLint in parallel with real-time feedback

LOG_FILE="/Users/adammanuel/.claude/.old_claude/agent.log"
SUMMARY_FILE="/Users/adammanuel/.claude/.old_claude/quality-summary.txt"

# Ensure log file exists
touch "$LOG_FILE"

# Colors for output (if terminal supports it)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Function to log with timestamp
log_message() {
    local level="$1"
    local component="$2"
    local message="$3"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] [$component] $message" >> "$LOG_FILE"

    # Also echo to console with color
    case "$level" in
        ERROR) echo -e "${RED}[$component] $message${NC}" ;;
        SUCCESS) echo -e "${GREEN}[$component] $message${NC}" ;;
        WARNING) echo -e "${YELLOW}[$component] $message${NC}" ;;
        INFO) echo -e "${BLUE}[$component] $message${NC}" ;;
        *) echo "[$component] $message" ;;
    esac
}

# PID tracking for cleanup
declare -a PIDS=()

# Cleanup function
cleanup() {
    log_message "INFO" "ORCHESTRATOR" "Stopping all quality watchers..."

    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
            log_message "INFO" "ORCHESTRATOR" "Stopped process $pid"
        fi
    done

    # Generate final summary
    generate_summary

    log_message "SUCCESS" "ORCHESTRATOR" "All watchers stopped. Session complete."
    exit 0
}

# Generate quality summary
generate_summary() {
    cat > "$SUMMARY_FILE" << EOF
Quality Watch Session Summary
=============================
End Time: $(date)

TypeScript Issues: $(grep -c "TSC.*ERROR" "$LOG_FILE" || echo "0")
Test Failures: $(grep -c "TEST.*FAIL" "$LOG_FILE" || echo "0")
ESLint Warnings: $(grep -c "LINT.*WARNING" "$LOG_FILE" || echo "0")
ESLint Errors: $(grep -c "LINT.*ERROR" "$LOG_FILE" || echo "0")

Session Duration: $SECONDS seconds
EOF

    log_message "INFO" "ORCHESTRATOR" "Summary saved to $SUMMARY_FILE"
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM EXIT

# Check if we're in a valid project directory
if [ ! -f "package.json" ]; then
    log_message "ERROR" "ORCHESTRATOR" "No package.json found. Please run from project root."
    exit 1
fi

log_message "INFO" "ORCHESTRATOR" "Starting quality watch mode..."

# Start TypeScript watcher
if command -v tsc &> /dev/null || [ -f "node_modules/.bin/tsc" ]; then
    log_message "INFO" "TSC" "Starting TypeScript compiler in watch mode..."

    npx tsc --watch --noEmit --preserveWatchOutput 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"error"* ]]; then
            log_message "ERROR" "TSC" "$line"
        elif [[ "$line" == *"Found 0 errors"* ]]; then
            log_message "SUCCESS" "TSC" "No TypeScript errors found"
        else
            log_message "INFO" "TSC" "$line"
        fi
    done &

    TSC_PID=$!
    PIDS+=("$TSC_PID")
    log_message "SUCCESS" "TSC" "TypeScript watcher started (PID: $TSC_PID)"
else
    log_message "WARNING" "TSC" "TypeScript not found, skipping type checking"
fi

# Start test watcher (check for different test runners)
if [ -f "node_modules/.bin/jest" ]; then
    log_message "INFO" "TEST" "Starting Jest in watch mode..."

    npx jest --watch --coverage=false 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"FAIL"* ]]; then
            log_message "ERROR" "TEST" "$line"
        elif [[ "$line" == *"PASS"* ]]; then
            log_message "SUCCESS" "TEST" "$line"
        else
            log_message "INFO" "TEST" "$line"
        fi
    done &

    TEST_PID=$!
    PIDS+=("$TEST_PID")
    log_message "SUCCESS" "TEST" "Jest watcher started (PID: $TEST_PID)"

elif [ -f "node_modules/.bin/vitest" ]; then
    log_message "INFO" "TEST" "Starting Vitest in watch mode..."

    npx vitest --watch 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"FAIL"* ]]; then
            log_message "ERROR" "TEST" "$line"
        elif [[ "$line" == *"PASS"* ]]; then
            log_message "SUCCESS" "TEST" "$line"
        else
            log_message "INFO" "TEST" "$line"
        fi
    done &

    TEST_PID=$!
    PIDS+=("$TEST_PID")
    log_message "SUCCESS" "TEST" "Vitest watcher started (PID: $TEST_PID)"
else
    log_message "WARNING" "TEST" "No test runner found, skipping test watching"
fi

# Start ESLint watcher (using nodemon as ESLint doesn't have built-in watch)
if command -v eslint &> /dev/null || [ -f "node_modules/.bin/eslint" ]; then
    log_message "INFO" "LINT" "Starting ESLint in watch mode..."

    # Check if nodemon is available
    if [ -f "node_modules/.bin/nodemon" ]; then
        npx nodemon --watch . --ext js,jsx,ts,tsx --exec "npx eslint . --ext .js,.jsx,.ts,.tsx" 2>&1 | while IFS= read -r line; do
            if [[ "$line" == *"error"* ]]; then
                log_message "ERROR" "LINT" "$line"
            elif [[ "$line" == *"warning"* ]]; then
                log_message "WARNING" "LINT" "$line"
            elif [[ "$line" == *"All files pass"* ]] || [[ "$line" == *"0 problems"* ]]; then
                log_message "SUCCESS" "LINT" "No ESLint issues found"
            else
                log_message "INFO" "LINT" "$line"
            fi
        done &

        LINT_PID=$!
        PIDS+=("$LINT_PID")
        log_message "SUCCESS" "LINT" "ESLint watcher started (PID: $LINT_PID)"
    else
        log_message "WARNING" "LINT" "nodemon not found, running single ESLint check..."
        npx eslint . --ext .js,.jsx,.ts,.tsx
    fi
else
    log_message "WARNING" "LINT" "ESLint not found, skipping linting"
fi

# Monitor aggregated results
log_message "INFO" "ORCHESTRATOR" "All watchers started. Monitoring for quality issues..."
log_message "INFO" "ORCHESTRATOR" "Press Ctrl+C to stop all watchers"

# Tail the log file for real-time updates
tail -f "$LOG_FILE" | grep -E "\[(TSC|TEST|LINT|ORCHESTRATOR)\]" &
TAIL_PID=$!
PIDS+=("$TAIL_PID")

# Keep script running
wait