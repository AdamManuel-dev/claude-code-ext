#!/bin/zsh

##
# @fileoverview URL-based notification system with direct clicking support
# @lastmodified 2025-07-28T06:08:48Z
# 
# Features: URL scheme handling, file path conversion, direct notification clicking
# Main APIs: Main notification handler with URL/path detection and conversion
# Constraints: macOS only, limited by osascript notification capabilities
# Patterns: file:// URL conversion, path type detection, URL scheme support
##

# URL-Based Notification Script
# Usage: ./url-notification.sh "BRANCH_NAME" "MESSAGE" ["URL_OR_PATH"]
# The URL/path will be opened when user clicks the notification

BRANCH_NAME="${1:-Alert}"
MESSAGE="${2:-Notification}"
URL_OR_PATH="${3:-}"

if [[ -n "$URL_OR_PATH" ]]; then
    # Convert file paths to file:// URLs if needed
    if [[ -f "$URL_OR_PATH" || -d "$URL_OR_PATH" ]]; then
        # Convert to absolute path and file URL
        FULL_PATH=$(realpath "$URL_OR_PATH")
        URL_SCHEME="file://$FULL_PATH"
    else
        URL_SCHEME="$URL_OR_PATH"
    fi
    
    # Notification with clickable action
    osascript -e "display notification \"📢 $BRANCH_NAME\" with title \"$MESSAGE\" sound name \"Submarine\" action button \"Open\" action url \"$URL_SCHEME\""
else
    # Simple notification
    osascript -e "display notification \"📢 $BRANCH_NAME\" with title \"$MESSAGE\" sound name \"Submarine\""
fi

# Help function
show_help() {
    echo "URL-Based Notification Script"
    echo ""
    echo "Usage:"
    echo "  $0 \"BRANCH_NAME\" \"MESSAGE\" [\"URL_OR_PATH\"]"
    echo ""
    echo "Examples:"
    echo "  # Open file"
    echo "  $0 \"main\" \"Build complete!\" \"/path/to/build.log\""
    echo ""
    echo "  # Open directory"
    echo "  $0 \"deploy\" \"Files ready\" \"/Users/adam/project/dist\""
    echo ""
    echo "  # Open URL"
    echo "  $0 \"live\" \"Site deployed\" \"https://myapp.com\""
    echo ""
    echo "  # Open in specific app"
    echo "  $0 \"code\" \"Review needed\" \"vscode://file/path/to/file.js:42:1\""
    echo ""
    echo "  # Open terminal location"
    echo "  $0 \"debug\" \"Check logs\" \"terminal://new?dir=/var/log\""
    echo ""
    echo "Supported URL schemes:"
    echo "  - file://           - Open files/directories in Finder"
    echo "  - https://          - Open web URLs"
    echo "  - vscode://         - Open in VS Code"
    echo "  - terminal://       - Open Terminal"
    echo "  - finder://         - Open Finder locations"
}

if [[ "$1" == "help" || "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi