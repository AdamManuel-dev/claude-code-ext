# Advanced Usage Guide

Advanced patterns, customizations, and extensions for Claude Tools power users.

## Table of Contents
- [Advanced Notification Patterns](#advanced-notification-patterns)
- [Custom Script Development](#custom-script-development)
- [Performance Optimization](#performance-optimization)
- [Security Considerations](#security-considerations)
- [Multi-Environment Setup](#multi-environment-setup)
- [Automation Frameworks](#automation-frameworks)

---

## Advanced Notification Patterns

### Dynamic Context Detection
Create context-aware notifications that adapt to your current environment.

```bash
#!/bin/bash
# smart-context-notify.sh - Context-aware notification wrapper

detect_context() {
    local context=""
    
    # Git context
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current)
        local status=$(git status --porcelain | wc -l | tr -d ' ')
        context="$branch"
        [[ $status -gt 0 ]] && context="$context($status)"
    fi
    
    # Docker context
    if docker ps > /dev/null 2>&1; then
        local containers=$(docker ps --format "table {{.Names}}" | tail -n +2 | wc -l | tr -d ' ')
        [[ $containers -gt 0 ]] && context="$context[docker:$containers]"
    fi
    
    # Node.js context
    if [[ -f "package.json" ]]; then
        local pkg_name=$(jq -r '.name' package.json 2>/dev/null || echo "unknown")
        context="$context{$pkg_name}"
    fi
    
    echo "$context"
}

CONTEXT=$(detect_context)
MESSAGE="$1"
TARGET="${2:-$(pwd)}"

./tools/clickable-notification.sh "$CONTEXT" "$MESSAGE" "$TARGET"
```

### Conditional Notification Strategies
Build smart notification logic based on system state.

```bash
#!/bin/bash
# conditional-notify.sh - Smart notification with conditions

should_notify() {
    local hour=$(date +%H)
    local day=$(date +%u)  # 1-7, Monday-Sunday
    
    # Don't notify during night hours (22-06)
    if [[ $hour -ge 22 || $hour -le 6 ]]; then
        return 1
    fi
    
    # Don't notify on weekends (6-7 = Sat-Sun)
    if [[ $day -ge 6 ]]; then
        return 1
    fi
    
    # Check if we're in focus mode
    if [[ -f "/tmp/focus-mode" ]]; then
        return 1
    fi
    
    return 0
}

notify_with_conditions() {
    local type="$1"
    local message="$2"
    local target="$3"
    
    if should_notify; then
        case "$type" in
            "urgent")
                # Always notify urgent messages
                ./tools/send-notification.sh "URGENT" "$message"
                ;;
            "build")
                # Build notifications only during work hours
                ./tools/clickable-notification.sh "build" "$message" "$target"
                ;;
            "info")
                # Info notifications without reminders
                ./tools/send-notification.sh "info" "$message" true
                ;;
        esac
    else
        # Log notifications that were suppressed
        echo "$(date): Suppressed $type notification: $message" >> /tmp/suppressed-notifications.log
    fi
}

# Usage examples
notify_with_conditions "build" "Build completed" "./dist"
notify_with_conditions "urgent" "Critical error requires immediate attention"
notify_with_conditions "info" "Background task finished"
```

### Notification Queuing System
Handle high-frequency notifications intelligently.

```bash
#!/bin/bash
# notification-queue.sh - Queue and batch notifications

QUEUE_DIR="/tmp/notification-queue"
QUEUE_LOCK="/tmp/notification-queue.lock"

init_queue() {
    mkdir -p "$QUEUE_DIR"
    
    # Start queue processor if not running
    if [[ ! -f "$QUEUE_LOCK" ]]; then
        (process_queue &)
    fi
}

enqueue_notification() {
    local type="$1"
    local message="$2"
    local target="$3"
    local timestamp=$(date +%s)
    
    cat > "$QUEUE_DIR/notification_$timestamp.json" <<EOF
{
    "type": "$type",
    "message": "$message",
    "target": "$target",
    "timestamp": $timestamp
}
EOF
}

process_queue() {
    touch "$QUEUE_LOCK"
    
    while true; do
        # Process notifications every 30 seconds
        sleep 30
        
        local notifications=($QUEUE_DIR/notification_*.json)
        
        if [[ ${#notifications[@]} -eq 0 || ! -f "${notifications[0]}" ]]; then
            continue
        fi
        
        # Batch similar notifications
        local build_count=0
        local test_count=0
        local latest_build=""
        local latest_test=""
        
        for notif in "${notifications[@]}"; do
            local type=$(jq -r '.type' "$notif")
            local message=$(jq -r '.message' "$notif")
            local target=$(jq -r '.target' "$notif")
            
            case "$type" in
                "build")
                    build_count=$((build_count + 1))
                    latest_build="$message"
                    latest_build_target="$target"
                    ;;
                "test")
                    test_count=$((test_count + 1))
                    latest_test="$message"
                    ;;
                *)
                    # Send individual notifications immediately
                    ./tools/clickable-notification.sh "$type" "$message" "$target"
                    ;;
            esac
            
            rm "$notif"
        done
        
        # Send batched notifications
        if [[ $build_count -gt 0 ]]; then
            if [[ $build_count -eq 1 ]]; then
                ./tools/clickable-notification.sh "build" "$latest_build" "$latest_build_target"
            else
                ./tools/clickable-notification.sh "build" "$build_count builds completed" "$latest_build_target"
            fi
        fi
        
        if [[ $test_count -gt 0 ]]; then
            if [[ $test_count -eq 1 ]]; then
                ./tools/send-notification.sh "test" "$latest_test" true
            else
                ./tools/send-notification.sh "test" "$test_count test suites completed" true
            fi
        fi
    done
}

# Cleanup on exit
trap 'rm -f "$QUEUE_LOCK"; exit' EXIT INT TERM

# Usage
init_queue
enqueue_notification "build" "Webpack build complete" "./dist"
enqueue_notification "test" "Unit tests passed" ""
```

---

## Custom Script Development

### Script Template Framework
Standardized template for creating new notification scripts.

```bash
#!/bin/bash
# template-notification.sh - Template for custom notification scripts

##
# @fileoverview Template for custom notification scripts
# @lastmodified $(date -u +%Y-%m-%dT%H:%M:%SZ)
# 
# Features: Template structure, help system, error handling, logging
# Main APIs: main_function(), show_help(), log_action()
# Constraints: Requires bash/zsh, follows Claude Tools patterns
# Patterns: Standard parameter handling, graceful fallbacks, comprehensive help
##

# Configuration
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/tmp/${SCRIPT_NAME%.sh}.log"
TEMP_DIR="/tmp/${SCRIPT_NAME%.sh}"

# Default values
DEFAULT_BRANCH="notification"
DEFAULT_MESSAGE="Custom notification"

# Parse arguments
BRANCH_NAME="${1:-$DEFAULT_BRANCH}"
MESSAGE="${2:-$DEFAULT_MESSAGE}"
CUSTOM_PARAM="${3:-}"

# Logging function
log_action() {
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ): $*" >> "$LOG_FILE"
}

# Error handling
handle_error() {
    local error_msg="$1"
    log_action "ERROR: $error_msg"
    ./tools/send-notification.sh "error" "$error_msg" true
    exit 1
}

# Main functionality
main_function() {
    log_action "Starting custom notification: $MESSAGE"
    
    # Your custom logic here
    if [[ -n "$CUSTOM_PARAM" ]]; then
        # Handle custom parameter
        log_action "Processing custom parameter: $CUSTOM_PARAM"
    fi
    
    # Send notification
    ./tools/clickable-notification.sh "$BRANCH_NAME" "$MESSAGE" "${CUSTOM_PARAM:-$(pwd)}"
    
    log_action "Custom notification completed successfully"
}

# Help system
show_help() {
    cat << 'EOF'
🔧 CUSTOM NOTIFICATION SCRIPT
=============================

Template-based custom notification script with advanced features.

📖 USAGE
--------
./template-notification.sh "BRANCH_NAME" "MESSAGE" [CUSTOM_PARAM]

📋 PARAMETERS
-------------
BRANCH_NAME   : Branch or context identifier
MESSAGE       : Notification message
CUSTOM_PARAM  : Optional custom parameter

🎯 EXAMPLES
-----------
# Basic usage
./template-notification.sh "feature" "Custom notification"

# With custom parameter
./template-notification.sh "deploy" "Deployment ready" "https://myapp.com"

🔧 CUSTOMIZATION
----------------
Modify the main_function() to implement your specific logic.

📊 LOGGING
----------
Actions are logged to: /tmp/template-notification.log

Created based on Claude Tools template framework.
EOF
}

# Handle help requests
if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Validate environment
if [[ ! -d "./tools" ]]; then
    handle_error "Tools directory not found. Run from project root."
fi

# Create temp directory if needed
mkdir -p "$TEMP_DIR"

# Main execution
main_function

# Cleanup
rm -rf "$TEMP_DIR"
log_action "Script execution completed, cleanup done"
```

### Advanced File Analysis
Extended file analysis with custom patterns and reporting.

```bash
#!/bin/bash
# advanced-file-analysis.sh - Extended file analysis capabilities

analyze_code_quality() {
    local directory="${1:-.}"
    local output_file="${2:-code-analysis-$(date +%Y%m%d-%H%M%S).md}"
    
    echo "# Advanced Code Analysis Report" > "$output_file"
    echo "Generated: $(date)" >> "$output_file"
    echo "" >> "$output_file"
    
    # Documentation coverage
    echo "## Documentation Coverage" >> "$output_file"
    local total_files=$(find "$directory" -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | wc -l)
    local documented_files=$(./tools/get-file-headers.sh "$directory" | grep -c "File:")
    local coverage_percent=$((documented_files * 100 / total_files))
    
    echo "- Total files: $total_files" >> "$output_file"
    echo "- Documented files: $documented_files" >> "$output_file"
    echo "- Coverage: $coverage_percent%" >> "$output_file"
    echo "" >> "$output_file"
    
    # File type distribution
    echo "## File Type Distribution" >> "$output_file"
    find "$directory" -type f | sed 's/.*\\.//' | sort | uniq -c | sort -nr | head -10 >> "$output_file"
    echo "" >> "$output_file"
    
    # Large files (potential refactoring candidates)
    echo "## Large Files (>500 lines)" >> "$output_file"
    find "$directory" -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | xargs wc -l | sort -nr | head -10 >> "$output_file"
    echo "" >> "$output_file"
    
    # TODO/FIXME analysis
    echo "## Technical Debt Indicators" >> "$output_file"
    echo "### TODO items:" >> "$output_file"
    grep -r "TODO" "$directory" --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" | head -20 >> "$output_file"
    echo "" >> "$output_file"
    echo "### FIXME items:" >> "$output_file"
    grep -r "FIXME" "$directory" --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" | head -20 >> "$output_file"
    
    ./tools/clickable-notification.sh "analysis" "Code analysis complete" "$output_file"
}

analyze_dependencies() {
    local directory="${1:-.}"
    
    if [[ -f "$directory/package.json" ]]; then
        echo "## Dependency Analysis"
        
        # Outdated packages
        npm outdated --json 2>/dev/null | jq -r 'keys[]' | while read package; do
            echo "- Outdated: $package"
        done
        
        # Security vulnerabilities
        npm audit --json 2>/dev/null | jq -r '.vulnerabilities | keys[]' | while read vuln; do
            echo "- Security issue: $vuln"
        done
    fi
}

# Usage
analyze_code_quality "${1:-.}" "${2:-}"
```

### Performance Monitoring Integration
Monitor script performance and system impact.

```bash
#!/bin/bash
# performance-monitor.sh - Monitor notification system performance

METRICS_FILE="/tmp/notification-metrics.json"
ALERT_THRESHOLD=10  # seconds

init_metrics() {
    if [[ ! -f "$METRICS_FILE" ]]; then
        echo '{"executions": [], "averageTime": 0, "errorCount": 0}' > "$METRICS_FILE"
    fi
}

record_execution() {
    local script_name="$1"
    local execution_time="$2"
    local success="$3"
    
    local timestamp=$(date +%s)
    
    # Record execution data
    local temp_file=$(mktemp)
    jq --arg script "$script_name" \
       --arg time "$execution_time" \
       --arg timestamp "$timestamp" \
       --arg success "$success" \
       '.executions += [{
         "script": $script,
         "time": ($time | tonumber),
         "timestamp": ($timestamp | tonumber),
         "success": ($success == "true")
       }]' "$METRICS_FILE" > "$temp_file"
    
    mv "$temp_file" "$METRICS_FILE"
    
    # Alert on slow executions
    if (( $(echo "$execution_time > $ALERT_THRESHOLD" | bc -l) )); then
        ./tools/send-notification.sh "performance" "Slow execution detected: $script_name took ${execution_time}s"
    fi
}

generate_performance_report() {
    local report_file="performance-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" <<EOF
# Notification System Performance Report

Generated: $(date)

## Execution Statistics

EOF
    
    # Extract metrics using jq
    local total_executions=$(jq '.executions | length' "$METRICS_FILE")
    local avg_time=$(jq '.executions | map(.time) | add / length' "$METRICS_FILE")
    local error_count=$(jq '.executions | map(select(.success == false)) | length' "$METRICS_FILE")
    
    cat >> "$report_file" <<EOF
- Total executions: $total_executions
- Average execution time: ${avg_time}s
- Error count: $error_count
- Success rate: $(( (total_executions - error_count) * 100 / total_executions ))%

## Slowest Executions

EOF
    
    jq -r '.executions | sort_by(.time) | reverse | .[0:5] | .[] | "- \(.script): \(.time)s at \(.timestamp | strftime("%Y-%m-%d %H:%M:%S"))"' "$METRICS_FILE" >> "$report_file"
    
    ./tools/clickable-notification.sh "performance" "Performance report generated" "$report_file"
}

# Wrapper function to monitor any script
monitor_script() {
    local script_path="$1"
    shift
    local args="$@"
    
    local start_time=$(date +%s.%N)
    
    if "$script_path" $args; then
        local end_time=$(date +%s.%N)
        local execution_time=$(echo "$end_time - $start_time" | bc)
        record_execution "$(basename "$script_path")" "$execution_time" "true"
    else
        local end_time=$(date +%s.%N)
        local execution_time=$(echo "$end_time - $start_time" | bc)
        record_execution "$(basename "$script_path")" "$execution_time" "false"
    fi
}

init_metrics

# Usage examples:
# monitor_script ./tools/send-notification.sh "test" "Performance test"
# generate_performance_report
```

---

## Performance Optimization

### Batch Processing Strategies
Optimize for high-volume notification scenarios.

```bash
#!/bin/bash
# batch-processor.sh - Efficient batch notification processing

BATCH_SIZE=10
BATCH_DELAY=5  # seconds between batches

process_notifications_batch() {
    local input_file="$1"
    local batch_count=0
    local current_batch=()
    
    while IFS= read -r line; do
        current_batch+=("$line")
        
        if (( ${#current_batch[@]} >= BATCH_SIZE )); then
            process_batch "${current_batch[@]}"
            current_batch=()
            batch_count=$((batch_count + 1))
            
            # Delay between batches to avoid overwhelming the system
            sleep "$BATCH_DELAY"
        fi
    done < "$input_file"
    
    # Process remaining items
    if (( ${#current_batch[@]} > 0 )); then
        process_batch "${current_batch[@]}"
    fi
    
    ./tools/send-notification.sh "batch" "Processed $batch_count batches" true
}

process_batch() {
    local notifications=("$@")
    
    # Group similar notifications
    local build_notifications=()
    local test_notifications=()
    local other_notifications=()
    
    for notif in "${notifications[@]}"; do
        if [[ "$notif" =~ build ]]; then
            build_notifications+=("$notif")
        elif [[ "$notif" =~ test ]]; then
            test_notifications+=("$notif")
        else
            other_notifications+=("$notif")
        fi
    done
    
    # Send consolidated notifications
    if (( ${#build_notifications[@]} > 0 )); then
        ./tools/clickable-notification.sh "build" "${#build_notifications[@]} builds completed" "./dist"
    fi
    
    if (( ${#test_notifications[@]} > 0 )); then
        ./tools/send-notification.sh "test" "${#test_notifications[@]} test suites completed" true
    fi
    
    for notif in "${other_notifications[@]}"; do
        # Process individual notifications
        eval "$notif"
    done
}
```

### Resource Management
Efficient resource usage for background processes.

```bash
#!/bin/bash
# resource-manager.sh - Manage notification system resources

MAX_BACKGROUND_PROCESSES=20
PROCESS_CLEANUP_INTERVAL=300  # 5 minutes

monitor_resources() {
    while true; do
        local bg_count=$(jobs | wc -l)
        local memory_usage=$(ps -o pid,vsz,comm | grep notification | awk '{sum+=$2} END {print sum}')
        
        # Cleanup if too many background processes
        if (( bg_count > MAX_BACKGROUND_PROCESSES )); then
            cleanup_old_processes
        fi
        
        # Alert on high memory usage (>100MB)
        if (( memory_usage > 100000 )); then
            ./tools/send-notification.sh "resource" "High memory usage: ${memory_usage}KB" true
        fi
        
        sleep "$PROCESS_CLEANUP_INTERVAL"
    done
}

cleanup_old_processes() {
    # Find and clean up orphaned notification processes
    local old_processes=$(ps aux | grep "send-notification" | grep "sleep" | awk '{print $2}')
    
    for pid in $old_processes; do
        local age=$(ps -o etime= -p "$pid" | tr -d ' ')
        
        # Kill processes older than 1 hour
        if [[ "$age" > "01:00:00" ]]; then
            kill "$pid" 2>/dev/null
        fi
    done
}

# Auto-start resource monitoring
monitor_resources &
```

---

## Security Considerations

### Input Sanitization
Secure handling of user inputs and file paths.

```bash
#!/bin/bash
# secure-notification.sh - Security-hardened notification wrapper

sanitize_input() {
    local input="$1"
    
    # Remove dangerous characters
    input="${input//\$/\\$}"      # Escape dollar signs
    input="${input//\`/\\`}"      # Escape backticks
    input="${input//;/}"          # Remove semicolons
    input="${input//|/}"          # Remove pipes
    input="${input//&/}"          # Remove ampersands
    
    # Limit length
    if (( ${#input} > 200 )); then
        input="${input:0:200}..."
    fi
    
    echo "$input"
}

validate_path() {
    local path="$1"
    
    # Convert to absolute path
    path=$(realpath "$path" 2>/dev/null)
    
    # Check if path exists and is readable
    if [[ ! -r "$path" ]]; then
        return 1
    fi
    
    # Prevent access to sensitive directories
    case "$path" in
        /etc/*|/usr/bin/*|/System/*|/private/*)
            return 1
            ;;
    esac
    
    echo "$path"
}

secure_notify() {
    local branch_name=$(sanitize_input "$1")
    local message=$(sanitize_input "$2")
    local target_path=""
    
    if [[ -n "$3" ]]; then
        target_path=$(validate_path "$3")
        if [[ $? -ne 0 ]]; then
            ./tools/send-notification.sh "security" "Invalid or inaccessible path provided" true
            return 1
        fi
    fi
    
    ./tools/clickable-notification.sh "$branch_name" "$message" "$target_path"
}

# Usage
secure_notify "$1" "$2" "$3"
```

### Audit Logging
Comprehensive logging for security and compliance.

```bash
#!/bin/bash
# audit-logger.sh - Security audit logging for notifications

AUDIT_LOG="/var/log/claude-tools-audit.log"
SYSLOG_TAG="claude-tools"

log_security_event() {
    local event_type="$1"
    local details="$2"
    local user=$(whoami)
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local session_id="$$"
    
    # Create structured log entry
    local log_entry="{\"timestamp\":\"$timestamp\",\"user\":\"$user\",\"session_id\":\"$session_id\",\"event_type\":\"$event_type\",\"details\":\"$details\"}"
    
    # Log to local file if writable
    if [[ -w "$(dirname "$AUDIT_LOG")" ]]; then
        echo "$log_entry" >> "$AUDIT_LOG"
    fi
    
    # Log to system log
    logger -t "$SYSLOG_TAG" "$log_entry"
}

audit_notification() {
    local script_name="$1"
    local branch_name="$2"
    local message="$3"
    local target="$4"
    
    log_security_event "notification_sent" "script=$script_name,branch=$branch_name,message=$message,target=$target"
}

audit_file_access() {
    local file_path="$1"
    local access_type="$2"  # read, write, execute
    
    log_security_event "file_access" "path=$file_path,type=$access_type"
}

# Wrapper for audited notifications
audited_notify() {
    audit_notification "$(basename "$0")" "$1" "$2" "$3"
    ./tools/clickable-notification.sh "$1" "$2" "$3"
}
```

---

## Multi-Environment Setup

### Environment-Specific Configuration
Handle different environments (dev, staging, prod) intelligently.

```bash
#!/bin/bash
# env-config.sh - Environment-specific notification configuration

detect_environment() {
    local env="unknown"
    
    # Check environment variables
    if [[ -n "$NODE_ENV" ]]; then
        env="$NODE_ENV"
    elif [[ -n "$RAILS_ENV" ]]; then
        env="$RAILS_ENV"
    elif [[ -f ".env" ]]; then
        env=$(grep "^ENV=" .env | cut -d'=' -f2)
    fi
    
    # Check git branch patterns
    local branch=$(git branch --show-current 2>/dev/null)
    case "$branch" in
        main|master)
            env="production"
            ;;
        develop|dev)
            env="development"
            ;;
        staging|stage)
            env="staging"
            ;;
    esac
    
    echo "$env"
}

get_env_config() {
    local env="$1"
    local key="$2"
    
    case "$env" in
        "production")
            case "$key" in
                "notification_sound") echo "Glass" ;;
                "reminder_enabled") echo "false" ;;
                "batch_notifications") echo "true" ;;
            esac
            ;;
        "staging")
            case "$key" in
                "notification_sound") echo "Submarine" ;;
                "reminder_enabled") echo "true" ;;
                "batch_notifications") echo "false" ;;
            esac
            ;;
        "development")
            case "$key" in
                "notification_sound") echo "Submarine" ;;
                "reminder_enabled") echo "true" ;;
                "batch_notifications") echo "false" ;;
            esac
            ;;
    esac
}

env_aware_notify() {
    local env=$(detect_environment)
    local sound=$(get_env_config "$env" "notification_sound")
    local reminders=$(get_env_config "$env" "reminder_enabled")
    
    # Modify notification behavior based on environment
    case "$env" in
        "production")
            # Production: minimal, urgent notifications only
            if [[ "$1" =~ error|fail|critical ]]; then
                osascript -e "display notification \"[$env] $2\" with title \"🚨 $1\" sound name \"$sound\""
            fi
            ;;
        "staging")
            # Staging: moderate notification frequency
            ./tools/send-notification.sh "[$env] $1" "$2" "$([[ $reminders == "true" ]] && echo "" || echo "true")"
            ;;
        "development")
            # Development: full notification suite
            ./tools/clickable-notification.sh "[$env] $1" "$2" "$3"
            ;;
    esac
}

# Usage
env_aware_notify "$1" "$2" "$3"
```

### Cross-Platform Compatibility
Extend support beyond macOS.

```bash
#!/bin/bash
# cross-platform-notify.sh - Multi-platform notification support

detect_platform() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if command -v notify-send >/dev/null 2>&1; then
                echo "linux-desktop"
            else
                echo "linux-server"
            fi
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "windows"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

platform_notify() {
    local platform=$(detect_platform)
    local title="$1"
    local message="$2"
    local target="$3"
    
    case "$platform" in
        "macos")
            ./tools/clickable-notification.sh "$title" "$message" "$target"
            ;;
        "linux-desktop")
            notify-send "$title" "$message"
            if [[ -n "$target" && "$target" =~ ^http ]]; then
                xdg-open "$target"
            fi
            ;;
        "linux-server")
            # Server environments: log to syslog
            logger -t "claude-tools" "$title: $message"
            ;;
        "windows")
            # Windows: use PowerShell for notifications
            powershell -Command "
                Add-Type -AssemblyName System.Windows.Forms
                \$notify = New-Object System.Windows.Forms.NotifyIcon
                \$notify.Icon = [System.Drawing.SystemIcons]::Information
                \$notify.BalloonTipTitle = '$title'
                \$notify.BalloonTipText = '$message'
                \$notify.Visible = \$true
                \$notify.ShowBalloonTip(5000)
            "
            ;;
        *)
            echo "[$title] $message"
            ;;
    esac
}

# Usage
platform_notify "$1" "$2" "$3"
```

---

*This advanced usage guide provides sophisticated patterns for power users who want to extend and customize Claude Tools for complex workflows and enterprise environments.*