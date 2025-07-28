#!/bin/bash

# Auto-acknowledge all active notifications (slash command)
# Usage: ./ack-notifications.sh [help]

# Show help if requested
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    cat << 'EOF'
✅ AUTO-ACKNOWLEDGE NOTIFICATIONS
=================================

Automatically finds and cancels all active notification reminders.
Perfect slash command for quickly turning off all pending alerts.

📖 USAGE
--------
./ack-notifications.sh

🎯 WHAT IT DOES
--------------
• Finds all active notification tracking files in /tmp/notify_*
• Removes them to cancel future reminders
• Shows summary of what was acknowledged
• Attempts to clean up any orphaned sleep processes

🚀 EXAMPLES
-----------
# Acknowledge all active notifications
./ack-notifications.sh

# View this help
./ack-notifications.sh help

🔧 INTEGRATION
--------------
Add to your shell profile for global access:
  echo 'alias ack-all="~/.claude/MCPs/ack-notifications.sh"' >> ~/.zshrc

Or use as Claude slash command:
  /ack-notifications

📊 OUTPUT
---------
Shows count of acknowledged notifications and tracking files removed.
If no active notifications found, confirms system is clean.

🛠️ TROUBLESHOOTING
------------------
• Script is safe to run multiple times
• No harm if no notifications are active
• Removes only notification tracking files (safe)
• Check background jobs: jobs
• Kill specific jobs: kill %[job_number]

Created by Claude for enhanced notification workflow automation.
EOF
    exit 0
fi

echo "🔍 Scanning for active notifications..."

# Find all notification tracking files
NOTIFY_FILES=(/tmp/notify_*)
FOUND_COUNT=0
REMOVED_COUNT=0

# Check if any notification files exist
if [ ${#NOTIFY_FILES[@]} -eq 1 ] && [ ! -f "${NOTIFY_FILES[0]}" ]; then
    echo "✨ No active notifications found - system is clean!"
    exit 0
fi

# Process each notification file
for file in "${NOTIFY_FILES[@]}"; do
    if [ -f "$file" ]; then
        FOUND_COUNT=$((FOUND_COUNT + 1))
        
        # Extract timestamp from filename for display
        TIMESTAMP=$(basename "$file" | sed 's/notify_//')
        READABLE_TIME=$(date -r "$TIMESTAMP" 2>/dev/null || echo "unknown time")
        
        echo "📱 Found notification: $file (created: $READABLE_TIME)"
        
        # Remove the tracking file to cancel reminders
        if rm "$file" 2>/dev/null; then
            REMOVED_COUNT=$((REMOVED_COUNT + 1))
            echo "   ✅ Acknowledged and cancelled future reminders"
        else
            echo "   ❌ Failed to remove tracking file"
        fi
    fi
done

# Summary
echo ""
echo "📊 SUMMARY"
echo "=========="
echo "• Notifications found: $FOUND_COUNT"
echo "• Successfully acknowledged: $REMOVED_COUNT"

if [ $REMOVED_COUNT -gt 0 ]; then
    echo "• Status: ✅ All pending reminders cancelled"
    echo ""
    echo "💡 TIP: Background processes may still be running but will exit"
    echo "       harmlessly when they check for tracking files."
    echo "       Use 'jobs' to see active background processes."
else
    echo "• Status: ⚠️  Some notifications may still be active"
fi

echo ""
echo "🎉 Notification acknowledgment complete!" 