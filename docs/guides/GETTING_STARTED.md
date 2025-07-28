# Getting Started with Claude Tools

## Prerequisites

### System Requirements
- **macOS** (required for notification system)
- **Bash or Zsh shell** (standard on macOS)
- **Basic command line tools** (find, awk, osascript - built into macOS)

### Optional Dependencies
For the best experience, install these optional tools:

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install terminal-notifier for enhanced notifications
brew install terminal-notifier

# Install Cursor IDE for development integration
# Download from: https://cursor.so
```

---

## Quick Installation

### 1. Verify Tools Location
```bash
# Check if tools directory exists
ls -la ~/.claude/tools/

# If not found, you may need to set up the tools directory
mkdir -p ~/.claude/tools
```

### 2. Make Scripts Executable
```bash
# Make all scripts executable
chmod +x ~/.claude/tools/*.sh

# Verify permissions
ls -la ~/.claude/tools/
```

### 3. Test Installation
```bash
# Test basic notification
./tools/clickable-notification.sh "setup" "Installation test - click me!"

# Test file analysis
./tools/get-file-headers.sh . | head -20

# Test acknowledgment system
./tools/ack-notifications.sh help
```

---

## First Steps

### Understanding the Notification System

**Basic Notification (with reminders)**
```bash
# Sends notification with 7-stage reminder system
./tools/send-notification.sh "test" "This is a test notification"

# To stop reminders:
./tools/ack-notifications.sh
# or use the auto-created 'ack' alias
```

**Clickable Notification (opens in Cursor)**
```bash
# Opens current directory in Cursor when clicked
./tools/clickable-notification.sh "development" "Click to open project"

# Opens specific file
./tools/clickable-notification.sh "error" "Fix needed" "./src/problematic-file.js"

# Opens website
./tools/clickable-notification.sh "deploy" "Site is live!" "https://mysite.com"
```

### File Analysis

**Extract documentation headers**
```bash
# Analyze current directory
./tools/get-file-headers.sh

# Analyze specific directory
./tools/get-file-headers.sh ./src

# Save analysis to file
./tools/get-file-headers.sh > documentation-audit.txt
```

---

## Setting Up Workflows

### Development Workflow Integration

**1. Git Hook Integration**
```bash
# Add to .git/hooks/post-commit
#!/bin/bash
BRANCH=$(git branch --show-current)
~/.claude/tools/send-notification.sh "$BRANCH" "Commit successful" true
```

**2. Build System Integration**
```bash
# Add to package.json scripts
{
  "scripts": {
    "build:notify": "npm run build && ~/.claude/tools/clickable-notification.sh 'build' 'Build complete - click to review'",
    "test:notify": "npm test && ~/.claude/tools/send-notification.sh 'test' 'Tests passed' true"
  }
}
```

**3. Development Server**
```bash
# Notify when server starts
npm start &
sleep 3
./tools/clickable-notification.sh "dev-server" "Server running" "http://localhost:3000"
```

### Claude Code Integration

The tools are specifically designed for Claude Code workflows:

**Task Completion Notifications**
```bash
# When Claude completes a task - click to return to your project
./tools/clickable-notification.sh "$(git branch --show-current)" "Claude task completed"
```

**Error Notifications with File Opening**
```bash
# When Claude finds an error - click to open the problematic file
./tools/clickable-notification.sh "error" "Type error found" "./src/types/user.ts"
```

**Review Requests**
```bash
# When Claude needs your input
./tools/send-notification.sh "review" "Claude needs your input on database schema"
```

---

## Customization

### Shell Aliases

Add useful aliases to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
# Quick notification aliases
alias notify='~/.claude/tools/clickable-notification.sh'
alias remind='~/.claude/tools/send-notification.sh'
alias ack-all='~/.claude/tools/ack-notifications.sh'

# Development workflow aliases
alias build-notify='npm run build && notify "build" "Build complete!"'
alias test-notify='npm test && notify "test" "Tests passed!"'

# File analysis
alias headers='~/.claude/tools/get-file-headers.sh'
```

### Custom Notification Types

**Create project-specific notifications:**
```bash
#!/bin/bash
# save as: project-notify.sh

PROJECT_NAME="my-awesome-project"
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

~/.claude/tools/clickable-notification.sh "$PROJECT_NAME:$BRANCH" "$1" "${2:-$(pwd)}"
```

**Usage:**
```bash
./project-notify.sh "Feature complete!"
./project-notify.sh "Bug found" "./src/bug-location.js"
```

---

## Verification Checklist

### ✅ Basic Functionality
- [ ] Notifications appear when running scripts
- [ ] Clicking notifications performs expected actions
- [ ] File analysis finds and extracts headers
- [ ] Acknowledgment system cancels active notifications

### ✅ Optional Features
- [ ] terminal-notifier provides native clickable notifications
- [ ] Cursor IDE opens when clicking development notifications
- [ ] Background reminders work for persistent notifications

### ✅ Integration
- [ ] Scripts work from any directory
- [ ] Git integration functions correctly
- [ ] Build system notifications work
- [ ] Shell aliases function properly

---

## Common First-Time Issues

### Notifications Don't Appear
1. **Check notification permissions**
   - System Preferences > Notifications & Focus
   - Find "Terminal" and enable notifications

2. **Test basic notifications**
   ```bash
   osascript -e 'display notification "test" with title "test"'
   ```

### Cursor Integration Not Working
1. **Install Cursor IDE**
   - Download from cursor.so
   - Ensure it's in `/Applications/Cursor.app`

2. **Check cursor CLI**
   ```bash
   which cursor
   cursor --version
   ```

### Permission Errors
1. **Fix script permissions**
   ```bash
   chmod +x ~/.claude/tools/*.sh
   ```

2. **Check /tmp directory access**
   ```bash
   touch /tmp/test && rm /tmp/test && echo "OK" || echo "FAILED"
   ```

---

## Next Steps

### Learn More
1. **Read the [API Reference](../API.md)** for complete function documentation
2. **Explore [Integration Patterns](./INTEGRATION.md)** for advanced workflow automation
3. **Check [Troubleshooting Guide](../TROUBLESHOOTING.md)** if you encounter issues

### Advanced Usage
1. **Study the [Architecture](../ARCHITECTURE.md)** to understand system design
2. **Create custom notification workflows** for your specific needs
3. **Integrate with CI/CD systems** for automated notifications

### Get Help
1. **Use built-in help**: Run any script with `help` parameter
2. **Check logs**: Look in `/tmp/cursor-handler.log` for debugging
3. **Test components**: Use individual scripts to isolate issues

---

## Quick Reference Card

### Essential Commands
```bash
# Smart notification with reminders
./tools/send-notification.sh "branch" "message"

# Clickable notification (opens in Cursor)
./tools/clickable-notification.sh "branch" "message"

# Cancel all notifications
./tools/ack-notifications.sh

# Analyze file headers
./tools/get-file-headers.sh [path]

# Get help for any script
./tools/script-name.sh help
```

### Integration Examples
```bash
# Git hook
./tools/send-notification.sh "$(git branch --show-current)" "Committed" true

# Build complete
./tools/clickable-notification.sh "build" "Complete!" "./dist"

# Error with file
./tools/clickable-notification.sh "error" "Fix needed" "./src/error.js"

# Website ready
./tools/clickable-notification.sh "deploy" "Live!" "https://site.com"
```

---

*Welcome to Claude Tools! Start with simple notifications and gradually explore the advanced features as you become comfortable with the system.*