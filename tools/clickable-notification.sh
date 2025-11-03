#!/bin/zsh

##
# @fileoverview Clickable notification system with Cursor IDE integration
# @lastmodified 2025-07-28T06:08:48Z
# 
# Features: Terminal-notifier integration, Cursor IDE auto-opening, URL handling, AppleScript fallback
# Main APIs: Main notification handler, cursor-handler.sh integration, terminal-notifier execution
# Constraints: Requires terminal-notifier for best experience, macOS only, cursor command or Cursor.app
# Patterns: Smart target detection (URLs vs files), graceful fallbacks, auto-current-directory
##

# Clickable Notification Script with Path/URL Opening
# Uses terminal-notifier if available, falls back to AppleScript dialog
# Usage: ./clickable-notification.sh "BRANCH_NAME" "MESSAGE" ["PATH_OR_URL"]

BRANCH_NAME="${1:-Alert}"
MESSAGE="${2:-Notification}"
TARGET="${3:-}"

# If no target specified, default to opening current directory in Cursor IDE
if [[ -z "$TARGET" ]]; then
    TARGET="$(pwd)"
    OPEN_WITH_CURSOR=true
else
    OPEN_WITH_CURSOR=false
fi

# Check if terminal-notifier is available (better for clickable notifications)
if command -v terminal-notifier >/dev/null 2>&1 && [[ -n "$TARGET" ]]; then
    # Handle different target types
    if [[ "$TARGET" == http* ]]; then
        # Web URLs - open directly using -open parameter
        terminal-notifier \
            -title "📢 $BRANCH_NAME" \
            -message "$MESSAGE" \
            -sound Submarine \
            -open "$TARGET"
    else
        # Files/directories - use Cursor via execute command
        HANDLER_SCRIPT="$(dirname "$0")/cursor-handler.sh"
        if [[ -f "$HANDLER_SCRIPT" ]]; then
            EXECUTE_CMD="$HANDLER_SCRIPT \"$TARGET\""
        else
            # Fallback command - try direct cursor command first
            if command -v cursor >/dev/null 2>&1; then
                EXECUTE_CMD="cursor \"$TARGET\""
            else
                EXECUTE_CMD="open -a Cursor \"$TARGET\""
            fi
        fi
        
        
        terminal-notifier \
            -title "📢 $BRANCH_NAME" \
            -message "$MESSAGE" \
            -sound Submarine \
            -execute "$EXECUTE_CMD"
    fi
else
    # Fallback: Display notification + immediate dialog option
    osascript <<EOF
display notification "📢 $BRANCH_NAME" with title "$MESSAGE" sound name "Submarine"

if "$TARGET" is not "" then
    delay 1
    set userChoice to button returned of (display dialog "$MESSAGE" & return & return & "Open: $TARGET" buttons {"Cancel", "Open"} default button "Open" with icon note)
    
    if userChoice is "Open" then
        if "$TARGET" starts with "http" then
            open location "$TARGET"
        else
            -- Try to open with Cursor IDE
            try
                tell application "Cursor" to open POSIX file "$TARGET"
            on error
                -- Fallback to Finder if Cursor not available
                tell application "Finder" to open POSIX file "$TARGET"
            end try
        end if
    end if
end if
EOF
fi

# Installation helper for terminal-notifier
install_terminal_notifier() {
    echo "Installing terminal-notifier for better notification support..."
    if command -v brew >/dev/null 2>&1; then
        brew install terminal-notifier
        echo "✅ terminal-notifier installed! Rerun the script for better clickable notifications."
    else
        echo "❌ Homebrew not found. Install it first or use the fallback dialog method."
        echo "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    fi
}

# Help function
show_help() {
    echo "Clickable Notification Script with Cursor IDE Integration"
    echo ""
    echo "Usage:"
    echo "  $0 \"BRANCH_NAME\" \"MESSAGE\" [\"PATH_OR_URL\"]"
    echo ""
    echo "Examples:"
    echo "  # Open current directory in Cursor IDE (default behavior)"
    echo "  $0 \"main\" \"Build complete!\""
    echo ""
    echo "  # Open specific file in Cursor IDE"
    echo "  $0 \"error\" \"Fix needed\" \"/path/to/file.js\""
    echo ""
    echo "  # Open specific directory in Cursor IDE"
    echo "  $0 \"deploy\" \"Files ready\" \"/Users/adam/project/dist\""
    echo ""
    echo "  # Open website (bypasses Cursor)"
    echo "  $0 \"live\" \"Site up\" \"https://myapp.com\""
    echo ""
    echo "Features:"
    echo "  - 🎯 Automatically opens current directory in Cursor IDE when no path specified"
    echo "  - 💻 Smart Cursor IDE integration for files and directories"
    echo "  - 🌐 Direct URL opening for web links"
    echo "  - 📱 Uses terminal-notifier for native clickable notifications"
    echo "  - 🔄 Graceful fallback if Cursor or terminal-notifier unavailable"
    echo ""
    echo "Perfect for Claude Code notifications - click to jump back to your project!"
    echo ""
    echo "Install terminal-notifier for best experience:"
    echo "  $0 install"
}

# Handle special commands
case "$1" in
    "help"|"--help"|"-h")
        show_help
        exit 0
        ;;
    "install")
        install_terminal_notifier
        exit 0
        ;;
esac