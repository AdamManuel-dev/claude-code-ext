#!/bin/bash

##
# @fileoverview Helper script for opening files/directories in Cursor IDE
# @lastmodified 2025-07-28T06:08:48Z
# 
# Features: Smart Cursor detection, multiple fallback strategies, debug logging
# Main APIs: Main path opening handler with cursor command and open -a fallbacks
# Constraints: Requires either cursor CLI or Cursor.app, logs to /tmp/cursor-handler.log
# Patterns: Absolute path resolution, priority CLI > App > default, comprehensive logging
##

# URL handler for opening paths in Cursor IDE
# Usage: cursor-handler.sh "path"

TARGET="$1"

# Log for debugging
echo "$(date): Cursor handler called with: $TARGET" >> /tmp/cursor-handler.log

if [[ -x "/usr/local/bin/cursor" ]]; then
    echo "$(date): Using cursor command at /usr/local/bin/cursor" >> /tmp/cursor-handler.log
    /usr/local/bin/cursor "$TARGET" 2>>/tmp/cursor-handler.log
elif [[ -d "/Applications/Cursor.app" ]]; then
    echo "$(date): Using open -a Cursor" >> /tmp/cursor-handler.log
    open -a "Cursor" "$TARGET" 2>>/tmp/cursor-handler.log
else
    echo "$(date): Cursor not found, using default open" >> /tmp/cursor-handler.log
    # Fallback to default app if Cursor not found
    open "$TARGET" 2>>/tmp/cursor-handler.log
fi

echo "$(date): Cursor handler completed" >> /tmp/cursor-handler.log