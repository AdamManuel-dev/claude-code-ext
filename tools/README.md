# Claude Tools

A comprehensive toolkit for enhancing Claude Code workflows with intelligent notifications, file analysis, and IDE integration.

## 🚀 Quick Start

```bash
# Test the notification system
./clickable-notification.sh "test" "Click to open project!"

# Analyze file headers
./get-file-headers.sh ./src

# Get help for any tool
./send-notification.sh help
```

## 📋 Available Tools

### Notification Scripts
- **`send-notification.sh`** - Smart notifications with 7-stage reminders and acknowledgment tracking
- **`clickable-notification.sh`** - Click to open files/directories in Cursor IDE (perfect for Claude workflows)
- **`ack-notifications.sh`** - Bulk cancel all active notifications
- **`interactive-notification.sh`** - Notifications with custom action buttons
- **`url-notification.sh`** - Direct URL opening notifications

### Analysis & Integration
- **`get-file-headers.sh`** - Extract documentation headers from source files
- **`cursor-handler.sh`** - Helper for IDE integration with fallback strategies

## 📚 Documentation

Comprehensive documentation is available in the `../docs/` directory:

- **[Getting Started](../docs/guides/GETTING_STARTED.md)** - Installation and basic usage
- **[API Reference](../docs/API.md)** - Complete function documentation
- **[Architecture](../docs/ARCHITECTURE.md)** - System design and patterns
- **[Troubleshooting](../docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Documentation Index](../docs/INDEX.md)** - Complete navigation

## 🎯 Common Use Cases

### Claude Code Workflows
```bash
# Task completion - click to return to project
./clickable-notification.sh "$(git branch --show-current)" "Task completed"

# Error with specific file
./clickable-notification.sh "error" "Fix needed" "./src/problematic.js"
```

### Development Automation
```bash
# Build notifications
./send-notification.sh "build" "Build completed" true

# Git hook integration
./send-notification.sh "$(git branch --show-current)" "Committed" true
```

## ⚡ Installation

1. **Make executable**: `chmod +x *.sh`
2. **Test**: `./clickable-notification.sh "setup" "Installation complete!"`
3. **Optional**: Install `terminal-notifier` with `brew install terminal-notifier`

## 📖 Help

Every script includes comprehensive help:
```bash
./script-name.sh help
```

For detailed documentation, troubleshooting, and integration examples, see the [full documentation](../docs/INDEX.md).

