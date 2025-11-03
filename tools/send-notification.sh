#!/bin/bash

##
# @fileoverview Smart notification system with persistent reminders and acknowledgment
# @lastmodified 2025-07-28T06:08:48Z
# 
# Features: Multi-stage reminders, tracking files, auto-aliases, comprehensive help system
# Main APIs: Main notification sender, background reminder processes, acknowledgment system
# Constraints: macOS only, requires notification permissions, creates /tmp tracking files
# Patterns: Background process spawning, tracking file lifecycle, shell alias injection
##

# Smart notification system with acknowledgment
# Usage: ./send-notification.sh "BRANCH_NAME" "MESSAGE" [skip_reminders]

# Show help if requested
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    cat << 'EOF'
🔔 SMART NOTIFICATION SYSTEM
============================

A macOS notification system with acknowledgment and reminder capabilities.
Perfect for getting user attention when Claude needs input or feedback.

📖 USAGE
--------
./send-notification.sh "BRANCH_NAME" "MESSAGE" [skip_reminders]

📋 PARAMETERS
-------------
BRANCH_NAME     : Branch or context identifier (shown with 📢)
MESSAGE         : Main notification message/title
skip_reminders  : Optional. Set to "true" to send only immediate notification

🎯 EXAMPLES
-----------
# Smart notification with 5min & 15min reminders
./send-notification.sh "feature-auth" "Please review the login implementation"

# Single notification only (no follow-ups)
./send-notification.sh "main" "Tests are failing" true

# Get user attention for urgent input
./send-notification.sh "hotfix" "Claude needs your input on database migration"

# Quick status update
./send-notification.sh "$(git branch --show-current)" "Build completed successfully" true

🎛️ ACKNOWLEDGMENT SYSTEM
------------------------
When reminders are enabled, the script creates a tracking file:
  📁 /tmp/notify_[TIMESTAMP]

To acknowledge and cancel future reminders:
  🗑️  rm /tmp/notify_[TIMESTAMP]
  
The script automatically creates a convenient 'ack' alias:
  ⚡ ack  (removes tracking file and confirms acknowledgment)
  
Note: Alias is added to ~/.zshrc if not already present

📅 REMINDER SCHEDULE
-------------------
• Immediate   : Notification sent right away
• 5 minutes   : First reminder (if not acknowledged)
• 10 minutes  : Second reminder (if not acknowledged)
• 15 minutes  : Third reminder (if not acknowledged)
• 20 minutes  : Fourth reminder (if not acknowledged)
• 30 minutes  : Fifth reminder (if not acknowledged)
• 45 minutes  : Sixth reminder (if not acknowledged)
• 60 minutes  : Final reminder (if not acknowledged)

🔧 INTEGRATION WITH CLAUDE.MD
-----------------------------
This script is referenced in CLAUDE.md as:
> **⚠️ IMPORTANT**: Use `/Users/adammanuel/.claude/MCPs/send-notification.sh "BRANCH_NAME" "MESSAGE"` for smart notifications with acknowledgment

💡 WORKFLOW TIPS
---------------
• Use with git hooks for automated notifications
• Integrate with CI/CD pipelines for build status
• Pair with Claude's task completion alerts
• Set reminders for time-sensitive code reviews

🛠️ TROUBLESHOOTING
------------------
• Ensure macOS notifications are enabled
• Check System Preferences > Notifications > Terminal
• Background processes appear as [1] [2] [3] [4] [5] [6] [7] in terminal
• Kill all background jobs: kill %1 %2 %3 %4 %5 %6 %7
• List active jobs: jobs
• Kill all jobs at once: killall sleep (if needed)

📚 RELATED COMMANDS
------------------
• Get file headers: ./get-file-headers.sh [path]
• Raw notification: osascript -e 'display notification "text" with title "title"'
• Check background jobs: jobs
• Kill specific job: kill %[job_number]

Created by Claude for enhanced developer workflow automation.
EOF
    exit 0
fi

BRANCH_NAME="${1:-BRANCH_NAME}"
MESSAGE="${2:-ENTER_MESSAGE_FOR_USER_HERE}"
SKIP_REMINDERS="${3:-false}"

# Create unique tracking file
NOTIFY_ID="notify_$(date +%s)"
NOTIFY_FILE="/tmp/${NOTIFY_ID}"

# Send immediate notification
osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE}\" sound name \"Submarine\""

# Create tracking file unless reminders are skipped
if [ "$SKIP_REMINDERS" != "true" ]; then
    echo "$(date): Notification sent, waiting for acknowledgment..." > "$NOTIFY_FILE"
    
    # Background processes for multiple reminders
    # 5 minutes (300 seconds)
    (sleep 300 && if [ -f "$NOTIFY_FILE" ]; then 
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 5min reminder (rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    # 10 minutes (600 seconds)
    (sleep 600 && if [ -f "$NOTIFY_FILE" ]; then 
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 10min reminder (rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    # 15 minutes (900 seconds)
    (sleep 900 && if [ -f "$NOTIFY_FILE" ]; then
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 15min reminder (rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    # 20 minutes (1200 seconds)
    (sleep 1200 && if [ -f "$NOTIFY_FILE" ]; then
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 20min reminder (rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    # 30 minutes (1800 seconds)
    (sleep 1800 && if [ -f "$NOTIFY_FILE" ]; then
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 30min reminder (rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    # 45 minutes (2700 seconds)
    (sleep 2700 && if [ -f "$NOTIFY_FILE" ]; then
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 45min reminder (rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    # 60 minutes (3600 seconds)
    (sleep 3600 && if [ -f "$NOTIFY_FILE" ]; then
        osascript -e "display notification \"📢 ${BRANCH_NAME}\" with title \"${MESSAGE} - 60min reminder (FINAL - rm ${NOTIFY_FILE} to stop)\" sound name \"Submarine\""
    fi) &
    
    echo "✅ Smart notifications scheduled! (7 reminders: 5, 10, 15, 20, 30, 45, 60 min)"
    echo "📱 To acknowledge and cancel future alerts:"
    echo "   rm $NOTIFY_FILE"
    
    # Auto-create convenient alias if it doesn't exist
    SHELL_RC="${HOME}/.zshrc"
    if [ -f "$SHELL_RC" ] && ! grep -q "alias ack=" "$SHELL_RC" 2>/dev/null; then
        echo "alias ack='rm $NOTIFY_FILE && echo \"✅ Acknowledged!\"'" >> "$SHELL_RC"
        echo "   ✅ Created 'ack' alias in $SHELL_RC"
    elif ! alias ack >/dev/null 2>&1; then
        # Create temporary alias for current session if no permanent one exists
        alias ack="rm $NOTIFY_FILE && echo '✅ Acknowledged!'"
        echo "   ✅ Created temporary 'ack' alias for this session"
    else
        echo "   💡 Use existing 'ack' alias or: rm $NOTIFY_FILE"
    fi
    
    echo "🔗 Tracking file: $NOTIFY_FILE"
else
    echo "✅ Single notification sent (no reminders)"
fi 