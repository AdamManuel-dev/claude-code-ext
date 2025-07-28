# Claude Tools Documentation Index

Complete documentation for the Claude CLI toolkit - shell scripts for enhanced development workflows with notifications, file analysis, and IDE integration.

## 🚀 Quick Start

### Essential Scripts
- **[clickable-notification.sh](./API.md#clickable-notificationsh)** - Click to open in Cursor IDE
- **[send-notification.sh](./API.md#send-notificationsh)** - Smart reminders with acknowledgment
- **[ack-notifications.sh](./API.md#ack-notificationssh)** - Cancel all active notifications

### Quick Setup
```bash
# Install recommended dependency
brew install terminal-notifier

# Test notification system
./tools/clickable-notification.sh "test" "Click to open project!"

# View comprehensive help
./tools/send-notification.sh help
```

---

## 📚 Documentation Structure

### Core Reference
- **[Complete API Reference](./API.md)** - Full function signatures and examples
- **[Architecture Overview](./ARCHITECTURE.md)** - System design and integration patterns
- **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Common issues and solutions

### Module Documentation
- **[Notification System](./modules/notifications.md)** - Multi-modal notification delivery
- **[File Analysis](./modules/file-analysis.md)** - Source code header extraction

### Development Guides
- **[Getting Started](./guides/GETTING_STARTED.md)** - Installation and basic usage
- **[Integration Patterns](./guides/INTEGRATION.md)** - Workflow automation examples
- **[Advanced Usage](./guides/ADVANCED.md)** - Custom configurations and extensions

---

## 🛠️ Tools Overview

### Notification Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `clickable-notification.sh` | Development workflow notifications | Cursor IDE integration, URL handling, fallback dialogs |
| `send-notification.sh` | Smart reminder system | 7-stage reminders, acknowledgment tracking, auto-aliases |
| `ack-notifications.sh` | Bulk notification management | Auto-discovery, batch cancellation, status reporting |
| `interactive-notification.sh` | Action button notifications | Custom command execution, temporary scripts |
| `url-notification.sh` | Direct URL notifications | file:// conversion, click-to-open |

### Utility Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `get-file-headers.sh` | Code documentation analysis | Multi-language support, recursive scanning, build exclusions |
| `cursor-handler.sh` | IDE integration helper | Smart Cursor detection, fallback strategies, debug logging |

### Supporting Files

| File | Purpose | Contents |
|------|---------|----------|
| `README.md` | Tool overview | Brief descriptions and basic usage |
| All scripts | Built-in help | Run with `help` parameter for detailed documentation |

---

## 🎯 Common Use Cases

### Claude Code Workflows
```bash
# Task completion - click to return to project
./clickable-notification.sh "$(git branch --show-current)" "Task completed"

# Error notification with specific file
./clickable-notification.sh "error" "Fix needed" "./src/problematic-file.js"

# Build completion with reminder system
./send-notification.sh "build" "Review build output when ready"
```

### Development Automation
```bash
# Git hook notifications
./send-notification.sh "commit" "Changes committed successfully" true

# CI/CD integration
./clickable-notification.sh "deploy" "Site deployed" "https://yoursite.com"

# Test completion
./interactive-notification.sh "tests" "Tests completed" "open ./test-results.html"
```

### Project Management
```bash
# Code review reminders
./send-notification.sh "review" "PR ready for review"

# Documentation audits
./get-file-headers.sh ./src > documentation-report.txt

# Cleanup notifications
./ack-notifications.sh
```

---

## 🔧 Installation & Setup

### Prerequisites
- macOS (for notification system)
- Bash/Zsh shell
- Basic command line tools (`find`, `awk`, `osascript`)

### Optional Dependencies
```bash
# Enhanced notification experience
brew install terminal-notifier

# IDE integration
# Install Cursor from cursor.so
# Ensure cursor CLI is available: which cursor
```

### Configuration
1. **Clone or download** the tools to `~/.claude/tools/`
2. **Make executable**: `chmod +x ~/.claude/tools/*.sh`
3. **Test installation**: `./tools/clickable-notification.sh "setup" "Installation complete!"`
4. **Add to PATH** (optional): Add `~/.claude/tools` to your shell PATH

---

## 📖 Learning Path

### Beginner
1. Start with **[Getting Started Guide](./guides/GETTING_STARTED.md)**
2. Try basic notifications with `clickable-notification.sh`
3. Read **[API Reference](./API.md)** for your most-used scripts

### Intermediate
1. Explore **[Integration Patterns](./guides/INTEGRATION.md)**
2. Set up notification workflows for your projects
3. Review **[Module Documentation](./modules/notifications.md)**

### Advanced
1. Study **[Architecture Overview](./ARCHITECTURE.md)**
2. Read **[Advanced Usage Guide](./guides/ADVANCED.md)**
3. Customize scripts for your specific workflows

---

## 🆘 Support & Troubleshooting

### Quick Fixes
- **Notifications not appearing**: Check System Preferences > Notifications > Terminal
- **Cursor not opening**: Verify Cursor.app installation or cursor CLI availability
- **Permission errors**: Check file permissions and /tmp directory access

### Detailed Help
- **[Troubleshooting Guide](./TROUBLESHOOTING.md)** - Step-by-step solutions
- **Script help**: Run any script with `help` parameter
- **Debug logging**: Check `/tmp/cursor-handler.log` for IDE integration issues

### Getting More Help
1. Check the built-in help: `script-name.sh help`
2. Review error messages in script output
3. Test components individually to isolate issues
4. Check system dependencies and permissions

---

## 🔗 Cross-References

### Related Claude.md Instructions
The tools integrate with Claude.md configuration:
- Smart notifications: `tools/send-notification.sh`
- Cursor integration: `tools/clickable-notification.sh`
- File analysis: `tools/get-file-headers.sh`
- Acknowledgment: `tools/ack-notifications.sh`

### Integration Points
- **Git hooks**: Automatic notifications on commits/pushes
- **Build systems**: npm scripts, Makefile targets
- **CI/CD**: Pipeline success/failure notifications
- **Development servers**: Status and URL notifications

### Workflow Automation
- **Task management**: Reminder systems for pending work
- **Code review**: Notifications for PR readiness
- **Documentation**: Automated header extraction and auditing
- **Error handling**: Smart notifications for build failures

---

*This documentation was generated automatically and is kept up-to-date with the source code. Last updated: 2025-07-28T06:08:48Z*