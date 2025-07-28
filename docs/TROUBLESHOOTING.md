# Troubleshooting Guide

## Common Issues

### Notification System Problems

#### Notifications Not Appearing

**Problem:** Scripts execute without errors but no notifications show up

**Solutions:**
1. **Check macOS notification permissions**
   ```bash
   # Open System Preferences
   open "x-apple.systempreferences:com.apple.preference.notifications"
   ```
   - Navigate to Notifications & Focus
   - Find "Terminal" in the app list
   - Ensure "Allow Notifications" is enabled
   - Set alert style to "Alerts" or "Banners"

2. **Test basic notification functionality**
   ```bash
   # Test osascript directly
   osascript -e 'display notification "test" with title "test" sound name "Submarine"'
   ```

3. **Check Do Not Disturb status**
   - Disable Do Not Disturb mode
   - Check Focus settings in System Preferences

**Prevention:**
- Always test notification permissions after fresh macOS installs
- Document notification requirements for team members

---

#### Terminal-notifier Issues

**Problem:** `terminal-notifier not found` or notifications appear but aren't clickable

**Solutions:**
1. **Install terminal-notifier**
   ```bash
   # Using Homebrew
   brew install terminal-notifier
   
   # Manual installation
   brew install terminal-notifier
   
   # Verify installation
   which terminal-notifier
   terminal-notifier -help
   ```

2. **Check PATH configuration**
   ```bash
   # Add to your shell profile (~/.zshrc or ~/.bash_profile)
   export PATH="/opt/homebrew/bin:$PATH"
   
   # Reload shell configuration
   source ~/.zshrc
   ```

3. **Verify permissions**
   ```bash
   # Check if terminal-notifier has notification permissions
   terminal-notifier -message "test" -title "test"
   ```

**Fallback Behavior:**
Scripts automatically fall back to osascript if terminal-notifier is unavailable.

---

#### Background Process Accumulation

**Problem:** Multiple notification processes running, consuming system resources

**Diagnosis:**
```bash
# Check active jobs
jobs

# Check background processes
ps aux | grep "sleep"
ps aux | grep "notification"
```

**Solutions:**
1. **Clean shutdown of background jobs**
   ```bash
   # Kill specific jobs
   kill %1 %2 %3
   
   # Kill all sleep processes (use with caution)
   killall sleep
   ```

2. **Acknowledge notifications to stop reminders**
   ```bash
   # Use the acknowledgment script
   ./ack-notifications.sh
   
   # Manual acknowledgment
   rm /tmp/notify_*
   ```

3. **Prevent accumulation**
   ```bash
   # Use single notifications when appropriate
   ./send-notification.sh "branch" "message" true
   ```

**Prevention:**
- Regularly acknowledge notifications
- Use single-shot notifications for automated systems
- Monitor system with `jobs` command

---

### Cursor IDE Integration Problems

#### Cursor Not Opening

**Problem:** Notifications appear but clicking doesn't open Cursor IDE

**Diagnosis:**
```bash
# Check if Cursor is installed
ls -la /Applications/Cursor.app

# Check if cursor CLI is available
which cursor
cursor --version

# Test cursor-handler directly
./cursor-handler.sh "/path/to/test"

# Check handler logs
cat /tmp/cursor-handler.log
```

**Solutions:**
1. **Install Cursor IDE**
   - Download from [cursor.so](https://cursor.so)
   - Install in `/Applications/Cursor.app`

2. **Install Cursor CLI**
   ```bash
   # Usually installed automatically with Cursor IDE
   # If missing, reinstall Cursor or add manually
   ln -s "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" /usr/local/bin/cursor
   ```

3. **Verify handler script**
   ```bash
   # Test the handler directly
   ./cursor-handler.sh "$(pwd)"
   
   # Check for errors in log
   tail -f /tmp/cursor-handler.log
   ```

4. **Fallback behavior**
   - Script falls back to `open -a Cursor`
   - Then falls back to system default (`open`)

**Alternative IDEs:**
Modify `cursor-handler.sh` to support other editors:
```bash
# Example: VS Code support
if command -v code >/dev/null 2>&1; then
    code "$TARGET"
elif [[ -d "/Applications/Visual Studio Code.app" ]]; then
    open -a "Visual Studio Code" "$TARGET"
fi
```

---

#### Handler Script Permissions

**Problem:** Permission denied when executing cursor-handler.sh

**Solutions:**
1. **Fix permissions**
   ```bash
   chmod +x ~/.claude/tools/cursor-handler.sh
   chmod +x ~/.claude/tools/*.sh
   ```

2. **Check file ownership**
   ```bash
   ls -la ~/.claude/tools/
   chown $USER ~/.claude/tools/*.sh
   ```

3. **Verify PATH resolution**
   ```bash
   # Test full path execution
   /Users/$USER/.claude/tools/cursor-handler.sh "$(pwd)"
   ```

---

### File Analysis Issues

#### No Files Found

**Problem:** `get-file-headers.sh` returns no results

**Diagnosis:**
```bash
# Test find command directly
find . -name "*.js" -o -name "*.ts" | head -5

# Check current directory
ls -la

# Test with specific path
./get-file-headers.sh ./src
```

**Solutions:**
1. **Verify file types**
   - Script supports: `.txt`, `.md`, `.js`, `.ts`, `.jsx`, `.tsx`
   - Add more types if needed

2. **Check directory exclusions**
   - Excludes: `build/`, `dist/`, `node_modules/`
   - May need to adjust exclusion patterns

3. **Test with verbose output**
   ```bash
   # Add debug to the script temporarily
   set -x
   ./get-file-headers.sh
   set +x
   ```

---

#### Malformed Header Detection

**Problem:** Headers exist but aren't extracted properly

**Common Issues:**
1. **Incorrect comment format**
   ```javascript
   // Wrong - single line comment
   /* Wrong - doesn't start with /** */
   
   /**
    * Correct - JSDoc format
    */
   ```

2. **Header not at file beginning**
   ```javascript
   import something from 'somewhere';  // Wrong - imports first
   
   /**
    * @fileoverview This header won't be detected
    */
   ```

3. **Mixed comment styles**
   ```javascript
   /**
    * @fileoverview Started correctly
   // But mixing with single-line comments breaks it
    */
   ```

**Solutions:**
1. **Standardize header format**
   ```javascript
   /**
    * @fileoverview Brief description
    * @lastmodified 2024-01-15T10:30:00Z
    * 
    * Features: List features
    * Main APIs: List main functions
    * Constraints: List constraints  
    * Patterns: List patterns
    */
   ```

2. **Place headers at file beginning**
   - Headers must be the first content (after shebang if applicable)
   - No imports or code before header

3. **Test AWK pattern manually**
   ```bash
   # Test the AWK pattern on a specific file
   awk '
       /^\/\*\*/ { inComment=1; print; next }
       /^ \*\// && inComment { print; exit }
       inComment { print }
   ' your-file.js
   ```

---

### Permission and Access Issues

#### /tmp Directory Access

**Problem:** Cannot create tracking files or logs

**Diagnosis:**
```bash
# Check /tmp permissions
ls -ld /tmp

# Test write access
touch /tmp/test-file && rm /tmp/test-file && echo "OK" || echo "FAILED"

# Check disk space
df -h /tmp
```

**Solutions:**
1. **Fix /tmp permissions**
   ```bash
   # Usually requires admin privileges
   sudo chmod 1777 /tmp
   ```

2. **Alternative temporary directory**
   ```bash
   # Use home directory for temporary files
   export TMPDIR="$HOME/.tmp"
   mkdir -p "$TMPDIR"
   ```

3. **Check system integrity**
   ```bash
   # On macOS, repair permissions
   sudo diskutil repairPermissions /
   ```

---

#### Shell Profile Modifications

**Problem:** Auto-alias creation fails

**Common Causes:**
- Shell profile not writable
- Profile file doesn't exist
- Wrong shell detected

**Solutions:**
1. **Check profile file**
   ```bash
   # Determine your shell
   echo $SHELL
   
   # Check if profile exists
   ls -la ~/.zshrc ~/.bash_profile ~/.profile
   
   # Create if needed
   touch ~/.zshrc  # for zsh
   touch ~/.bash_profile  # for bash
   ```

2. **Fix permissions**
   ```bash
   chmod u+w ~/.zshrc
   ```

3. **Manual alias creation**
   ```bash
   # Add to your shell profile manually
   echo 'alias ack="rm /tmp/notify_* && echo \"✅ Acknowledged!\""' >> ~/.zshrc
   source ~/.zshrc
   ```

---

## System Dependencies

### Required Tools Checklist

**Built-in macOS Tools:**
```bash
# Test each required tool
which osascript && echo "✅ osascript" || echo "❌ osascript"
which open && echo "✅ open" || echo "❌ open"  
which find && echo "✅ find" || echo "❌ find"
which awk && echo "✅ awk" || echo "❌ awk"
which date && echo "✅ date" || echo "❌ date"
```

**Optional Dependencies:**
```bash
# Test optional tools
which terminal-notifier && echo "✅ terminal-notifier" || echo "⚠️ terminal-notifier (optional)"
which cursor && echo "✅ cursor CLI" || echo "⚠️ cursor CLI (optional)"
ls /Applications/Cursor.app && echo "✅ Cursor.app" || echo "⚠️ Cursor.app (optional)"
```

### Installation Check Script

Create a diagnostic script:
```bash
#!/bin/bash
# save as: check-claude-tools.sh

echo "🔍 Claude Tools Dependency Check"
echo "=================================="

# Required tools
REQUIRED_TOOLS=("osascript" "open" "find" "awk" "date" "sh")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool"
    else
        echo "❌ $tool (REQUIRED)"
    fi
done

# Optional tools
echo ""
echo "Optional Dependencies:"
if command -v terminal-notifier >/dev/null 2>&1; then
    echo "✅ terminal-notifier (enhanced notifications)"
else
    echo "⚠️ terminal-notifier (install with: brew install terminal-notifier)"
fi

if command -v cursor >/dev/null 2>&1; then
    echo "✅ cursor CLI"
elif [[ -d "/Applications/Cursor.app" ]]; then
    echo "⚠️ cursor CLI missing (Cursor.app found - reinstall may fix)"
else
    echo "⚠️ Cursor IDE not installed (download from cursor.so)"
fi

# Test notifications
echo ""
echo "Testing notification system..."
if osascript -e 'display notification "test" with title "test"' 2>/dev/null; then
    echo "✅ Basic notifications work"
else
    echo "❌ Notification test failed - check permissions"
fi

# Test file system
echo ""
echo "Testing file system access..."
if touch /tmp/test-claude-tools 2>/dev/null && rm /tmp/test-claude-tools 2>/dev/null; then
    echo "✅ /tmp directory writable"
else
    echo "❌ Cannot write to /tmp directory"
fi

echo ""
echo "Check complete! ✅ = Working, ⚠️ = Optional, ❌ = Needs attention"
```

---

## Performance Issues

### Slow File Analysis

**Problem:** `get-file-headers.sh` takes too long on large codebases

**Solutions:**
1. **Limit search scope**
   ```bash
   # Search specific directories instead of entire project
   ./get-file-headers.sh ./src
   ./get-file-headers.sh ./lib
   ```

2. **Add more exclusions**
   ```bash
   # Edit the script to exclude more directories
   -not -path "*/coverage/*" \
   -not -path "*/docs/*" \
   -not -path "*/.git/*" \
   ```

3. **Use parallel processing**
   ```bash
   # Process directories in parallel
   find ./src -type d -maxdepth 1 | xargs -P 4 -I {} ./get-file-headers.sh {}
   ```

---

### High Memory Usage

**Problem:** Multiple background processes consuming memory

**Monitoring:**
```bash
# Monitor memory usage
ps aux | grep notification | awk '{sum+=$6} END {print "Memory usage: " sum/1024 " MB"}'

# Count active processes
ps aux | grep -c sleep
```

**Solutions:**
1. **Limit concurrent notifications**
   ```bash
   # Use single-shot notifications in automated systems
   ./send-notification.sh "build" "completed" true
   ```

2. **Regular cleanup**
   ```bash
   # Set up periodic cleanup
   # Add to crontab: 0 */6 * * * ~/.claude/tools/ack-notifications.sh
   ```

---

## Debugging Techniques

### Enable Debug Mode

Add debug output to any script:
```bash
#!/bin/bash
set -x  # Enable debug tracing
set -e  # Exit on error

# Your script content here

set +x  # Disable debug tracing
```

### Logging Strategies

1. **Add logging to scripts**
   ```bash
   # At the beginning of any script
   LOG_FILE="/tmp/$(basename "$0" .sh).log"
   echo "$(date): Starting $(basename "$0") with args: $*" >> "$LOG_FILE"
   ```

2. **Trace execution**
   ```bash
   # Run with trace
   bash -x ./your-script.sh
   ```

3. **Check system logs**
   ```bash
   # Check system notification logs
   log show --predicate 'subsystem == "com.apple.usernotifications"' --last 1h
   ```

### Test Individual Components

1. **Test notification system**
   ```bash
   # Test osascript directly
   osascript -e 'display notification "test" with title "test"'
   
   # Test terminal-notifier
   terminal-notifier -message "test" -title "test"
   ```

2. **Test file analysis**
   ```bash
   # Test find command
   find . -name "*.js" | head -5
   
   # Test AWK pattern
   awk '/^\/\*\*/{print}' your-file.js
   ```

3. **Test IDE integration**
   ```bash
   # Test cursor directly
   cursor --version
   cursor .
   
   # Test handler script
   ./cursor-handler.sh "$(pwd)"
   ```

---

## Getting Help

### Built-in Help Systems

All scripts provide comprehensive help:
```bash
./send-notification.sh help
./clickable-notification.sh help
./ack-notifications.sh help
./interactive-notification.sh help
./url-notification.sh help
```

### Log Analysis

Check relevant log files:
```bash
# Cursor integration logs
tail -f /tmp/cursor-handler.log

# Notification tracking
ls -la /tmp/notify_*

# System notification logs (macOS)
log show --predicate 'subsystem == "com.apple.usernotifications"' --last 10m
```

### Community Resources

1. **macOS Notification Issues**
   - Apple Developer Documentation
   - macOS-specific forums and communities

2. **Shell Scripting Help**
   - Bash/Zsh documentation
   - Unix/Linux command references

3. **IDE Integration**
   - Cursor IDE documentation
   - VS Code extension patterns (for reference)

### Creating Support Requests

When seeking help, include:

1. **System Information**
   ```bash
   uname -a
   echo $SHELL
   which terminal-notifier
   ls -la ~/.claude/tools/
   ```

2. **Error Output**
   ```bash
   # Run with debug mode
   bash -x ./problematic-script.sh 2>&1 | tee debug-output.txt
   ```

3. **Log Files**
   ```bash
   # Include relevant logs
   cat /tmp/cursor-handler.log
   ls -la /tmp/notify_*
   ```

4. **Reproduction Steps**
   - Exact commands that cause the issue
   - Expected vs actual behavior
   - Environment details (macOS version, shell, etc.)

---

*This troubleshooting guide covers the most common issues. For additional help, use the built-in help systems or check the debug logs for specific error messages.*