#!/bin/zsh

###
# Interactive Notification Script with Action Button
# Usage: ./interactive-notification.sh "BRANCH_NAME" "MESSAGE" ["ACTION_COMMAND"]
# Example: ./interactive-notification.sh "main" "Build complete!" "open /path/to/logs"
###

# Parse arguments
BRANCH_NAME="${1:-Alert}"
MESSAGE="${2:-Notification}"
ACTION_COMMAND="${3:-}"

# Generate unique identifier for this notification
NOTIFICATION_ID="notify_$(date +%s)_$$"
TEMP_FILE="/tmp/${NOTIFICATION_ID}"

# Create action handler script if action command provided
if [[ -n "$ACTION_COMMAND" ]]; then
    cat > "$TEMP_FILE" <<EOF
#!/bin/zsh
# Auto-generated action handler for notification: $MESSAGE
$ACTION_COMMAND
# Clean up after execution
rm -f "$TEMP_FILE"
EOF
    chmod +x "$TEMP_FILE"
fi

# Display notification with custom action
if [[ -n "$ACTION_COMMAND" ]]; then
    # Notification with actionable button
    osascript <<EOF
display notification "📢 $BRANCH_NAME" with title "$MESSAGE" sound name "Submarine"
set theButton to button returned of (display dialog "$MESSAGE" & return & return & "Action available: Click 'Execute' to run the associated command." buttons {"Dismiss", "Execute"} default button "Execute" with icon note)

if theButton is "Execute" then
    do shell script "$TEMP_FILE"
end if
EOF
else
    # Simple notification without action
    osascript -e "display notification \"📢 $BRANCH_NAME\" with title \"$MESSAGE\" sound name \"Submarine\""
fi

# Help function
show_help() {
    echo "Interactive Notification Script"
    echo ""
    echo "Usage:"
    echo "  $0 \"BRANCH_NAME\" \"MESSAGE\" [\"ACTION_COMMAND\"]"
    echo ""
    echo "Examples:"
    echo "  $0 \"main\" \"Build complete!\""
    echo "  $0 \"feature\" \"Tests passed!\" \"open /path/to/test-report.html\""
    echo "  $0 \"deploy\" \"Server ready\" \"open https://myapp.com\""
    echo "  $0 \"error\" \"Fix needed\" \"code /path/to/error-file.js:42\""
    echo ""
    echo "Features:"
    echo "  - Displays macOS notification with Submarine sound"
    echo "  - Optional action button for interactive functionality"
    echo "  - Automatic cleanup of temporary action handlers"
    echo "  - Supports opening files, URLs, running commands, etc."
}

# Show help if requested
if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi