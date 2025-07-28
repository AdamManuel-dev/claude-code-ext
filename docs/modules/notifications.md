# Notification System Module

## Purpose
Comprehensive notification system for Claude CLI workflows with multiple delivery methods, acknowledgment tracking, and IDE integration.

## Dependencies
- **Internal**: None (standalone module)
- **External**: 
  - macOS osascript (built-in)
  - terminal-notifier (optional, recommended)
  - Cursor IDE (optional)

## Key Components

### Smart Notification System (`send-notification.sh`)
Multi-stage notification system with persistent reminders and acknowledgment tracking.

#### Public API
- `send-notification.sh "BRANCH_NAME" "MESSAGE" [skip_reminders]` - Send smart notification with optional reminders
- Built-in help system with `help` parameter
- Auto-creates acknowledgment aliases

#### Features
- **7-stage reminder system**: 5, 10, 15, 20, 30, 45, 60 minutes
- **Tracking files**: Creates `/tmp/notify_[timestamp]` for acknowledgment
- **Auto-alias creation**: Adds `ack` command to shell profile
- **Background processes**: Non-blocking reminder scheduling

### Clickable Notifications (`clickable-notification.sh`)
Native clickable notifications with Cursor IDE integration for development workflows.

#### Public API
- `clickable-notification.sh "BRANCH_NAME" "MESSAGE" [path_or_url]` - Send clickable notification
- Auto-opens current directory in Cursor if no path specified
- Support for files, directories, and URLs

#### Features
- **Cursor IDE integration**: Smart detection of cursor CLI and Cursor.app
- **Fallback handling**: Graceful degradation to AppleScript dialogs
- **URL handling**: Direct web link opening vs IDE file opening

### Acknowledgment System (`ack-notifications.sh`)
Bulk acknowledgment tool for canceling all active notifications.

#### Public API
- `ack-notifications.sh` - Cancel all active notifications
- `ack-notifications.sh help` - Show comprehensive help

#### Features
- **Auto-discovery**: Finds all `/tmp/notify_*` tracking files
- **Bulk operations**: Cancels multiple notifications at once
- **Summary reporting**: Shows count of acknowledged notifications

## Usage Examples

### Basic Smart Notification
```bash
# Send notification with 7-stage reminders
./send-notification.sh "feature-auth" "Please review the login implementation"

# Acknowledge notification
rm /tmp/notify_1234567890
# or use auto-created alias
ack
```

### Development Workflow Integration
```bash
# Build complete - click to open project in Cursor
./clickable-notification.sh "main" "Build completed successfully!"

# Error found - click to open specific file
./clickable-notification.sh "error" "Fix needed" "/path/to/problematic-file.js"

# Deployment ready - click to open website
./clickable-notification.sh "deploy" "Site is live!" "https://myapp.com"
```

### Batch Acknowledgment
```bash
# Cancel all active notifications
./ack-notifications.sh

# Check status
./ack-notifications.sh help
```

## Configuration

### Environment Variables
- None required (all tools are self-contained)

### Optional Dependencies
Install for enhanced experience:
```bash
# Install terminal-notifier for native clickable notifications
brew install terminal-notifier

# Install Cursor IDE for development integration
# Download from cursor.so
```

## Error Handling

### Common Errors and Solutions

**Notifications not appearing**
- Check System Preferences > Notifications > Terminal
- Ensure "Allow Notifications" is enabled
- Try running a simple osascript test

**Cursor IDE not opening**
- Verify Cursor is installed in `/Applications/Cursor.app`
- Check if `cursor` CLI command is available: `which cursor`
- Script falls back to default system opener

**Permission issues with /tmp files**
- Ensure write access to `/tmp` directory
- Check if antivirus is blocking temporary file creation

**Background processes accumulating**
- Use `jobs` to see active background processes
- Kill specific jobs: `kill %1 %2 %3`
- Clean shutdown: `killall sleep` (if needed)

## Integration Patterns

### With Claude Code Workflows
```bash
# Task completion notification that opens project
./clickable-notification.sh "$(git branch --show-current)" "Task completed - click to review"

# Error notification with specific file
./clickable-notification.sh "error" "Type checking failed" "./src/types/user.ts"
```

### With Git Hooks
```bash
# In .git/hooks/post-commit
./send-notification.sh "$(git branch --show-current)" "Commit successful" true
```

### With Build Systems
```bash
# In package.json scripts
"build:notify": "npm run build && ./tools/send-notification.sh 'build' 'Build completed' true"
```

## Security Considerations

### File System Access
- Scripts only create files in `/tmp` directory
- Tracking files use timestamp-based naming (not predictable)
- Auto-cleanup prevents file accumulation

### Command Execution
- clickable-notification.sh executes user-provided commands
- cursor-handler.sh has controlled execution paths
- No arbitrary code execution from external inputs

### Process Management
- Background processes are properly isolated
- Scripts handle process cleanup gracefully
- No persistent daemon processes created

## Advanced Usage

### Custom Notification Chains
```bash
# Chain multiple notification types
./send-notification.sh "build" "Starting build process" true
sleep 30
./clickable-notification.sh "build" "Build complete - click to review" "./dist"
```

### Integration with CI/CD
```bash
# Pipeline notification with acknowledgment tracking
if [ "$CI_SUCCESS" = "true" ]; then
    ./send-notification.sh "ci" "Pipeline succeeded - review needed"
else
    ./clickable-notification.sh "ci-error" "Pipeline failed" "$CI_LOG_URL"
fi
```

### Development Server Integration
```bash
# Server start notification with URL
./clickable-notification.sh "dev-server" "Server running on port 3000" "http://localhost:3000"
```

## Performance Notes

- Notification delivery: ~100ms (osascript overhead)
- Background process startup: ~50ms per reminder
- File I/O operations: Minimal overhead
- Memory usage: <1MB per active notification chain

## Troubleshooting Scripts

Check notification system health:
```bash
# Show all active notifications
ls -la /tmp/notify_*

# Show background jobs
jobs

# Test basic notification
osascript -e 'display notification "test" with title "test" sound name "Submarine"'

# Test Cursor integration
./cursor-handler.sh "/Users/$(whoami)"
```