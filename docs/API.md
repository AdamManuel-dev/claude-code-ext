# Claude Tools API Reference

Complete API documentation for all tools in the Claude CLI toolkit.

## Table of Contents
- [Notification System](#notification-system)
- [File Analysis](#file-analysis)
- [Utility Scripts](#utility-scripts)

---

## Notification System

### send-notification.sh

Smart notification system with persistent reminders and acknowledgment tracking.

**Synopsis:**
```bash
send-notification.sh "BRANCH_NAME" "MESSAGE" [skip_reminders]
```

**Parameters:**
- `BRANCH_NAME` (string): Branch or context identifier displayed with 📢 emoji
- `MESSAGE` (string): Main notification message shown as title
- `skip_reminders` (optional): Set to `"true"` to disable reminder system

**Returns:** Exit code 0 on success

**Creates:**
- Tracking file: `/tmp/notify_[TIMESTAMP]` (unless `skip_reminders=true`)
- Shell alias: `ack` command (if not already present)
- Background processes: 7 reminder processes at 5, 10, 15, 20, 30, 45, 60 minutes

**Examples:**
```bash
# Smart notification with full reminder system
./send-notification.sh "feature-auth" "Please review login implementation"

# Single notification without reminders
./send-notification.sh "main" "Build completed" true

# Git integration
./send-notification.sh "$(git branch --show-current)" "Commit successful" true
```

**Error Conditions:**
- macOS notification permissions disabled
- Unable to create tracking file in `/tmp`
- Shell profile write permission issues

---

### clickable-notification.sh

Native clickable notifications with Cursor IDE integration for development workflows.

**Synopsis:**
```bash
clickable-notification.sh "BRANCH_NAME" "MESSAGE" ["PATH_OR_URL"]
```

**Parameters:**
- `BRANCH_NAME` (string): Context identifier displayed with 📢 emoji
- `MESSAGE` (string): Notification message
- `PATH_OR_URL` (optional): File path, directory path, or URL to open when clicked
  - Default: Current working directory (`pwd`)

**Returns:** Exit code 0 on success

**Behavior:**
- **No path specified**: Opens current directory in Cursor IDE
- **File/directory path**: Opens in Cursor IDE using cursor-handler.sh
- **URL (starts with http)**: Opens in default web browser
- **Fallback**: Uses AppleScript dialog if terminal-notifier unavailable

**Examples:**
```bash
# Open current directory in Cursor (default behavior)
./clickable-notification.sh "main" "Build complete!"

# Open specific file in Cursor
./clickable-notification.sh "error" "Fix needed" "/path/to/file.js"

# Open website
./clickable-notification.sh "deploy" "Site live!" "https://myapp.com"
```

**Dependencies:**
- `terminal-notifier` (recommended, falls back to AppleScript)
- `cursor` CLI or Cursor.app (for IDE integration)

**Error Conditions:**
- Cursor IDE not installed (falls back to system default)
- terminal-notifier not available (falls back to AppleScript)
- Invalid file path (opens in default application)

---

### ack-notifications.sh

Bulk acknowledgment tool for canceling all active notifications.

**Synopsis:**
```bash
ack-notifications.sh [help]
```

**Parameters:**
- `help` (optional): Display comprehensive help information

**Returns:** 
- Exit code 0: Success or no notifications found
- Prints summary of acknowledged notifications

**Behavior:**
- Scans `/tmp/notify_*` for tracking files
- Removes all found tracking files
- Displays readable timestamps and counts
- Safe to run multiple times

**Examples:**
```bash
# Cancel all active notifications
./ack-notifications.sh

# View help and usage information
./ack-notifications.sh help
```

**Output Format:**
```
📊 SUMMARY
==========
• Notifications found: 3
• Successfully acknowledged: 3
• Status: ✅ All pending reminders cancelled
```

---

### cursor-handler.sh

Helper script for opening files and directories in Cursor IDE with fallback strategies.

**Synopsis:**
```bash
cursor-handler.sh "PATH"
```

**Parameters:**
- `PATH` (string): File or directory path to open

**Returns:** Exit code 0 on successful opening

**Behavior:**
1. **First priority**: Use `/usr/local/bin/cursor` CLI command
2. **Second priority**: Use `open -a "Cursor"` with Cursor.app
3. **Fallback**: Use system default `open` command

**Logging:**
- Creates `/tmp/cursor-handler.log` with detailed execution traces
- Includes timestamps and error output

**Examples:**
```bash
# Open file in Cursor
./cursor-handler.sh "/path/to/file.js"

# Open directory in Cursor
./cursor-handler.sh "/path/to/project"
```

---

### interactive-notification.sh

Interactive notifications with custom action button execution.

**Synopsis:**
```bash
interactive-notification.sh "BRANCH_NAME" "MESSAGE" ["ACTION_COMMAND"]
```

**Parameters:**
- `BRANCH_NAME` (string): Context identifier
- `MESSAGE` (string): Notification message
- `ACTION_COMMAND` (optional): Shell command to execute when "Execute" button clicked

**Returns:** Exit code 0 on success

**Behavior:**
- Shows notification with AppleScript dialog
- If `ACTION_COMMAND` provided, displays "Execute" button
- Creates temporary script in `/tmp` for command execution
- Auto-cleanup of temporary files

**Examples:**
```bash
# Simple notification
./interactive-notification.sh "main" "Build complete!"

# Notification with file opening action
./interactive-notification.sh "test" "Tests passed!" "open /path/to/report.html"

# Notification with URL opening action
./interactive-notification.sh "deploy" "Site ready" "open https://mysite.com"
```

**Security Notes:**
- Executes user-provided commands with current user permissions
- Temporary scripts are created with unique IDs
- Scripts self-delete after execution

---

### url-notification.sh

URL-based notification system with direct clicking support (experimental).

**Synopsis:**
```bash
url-notification.sh "BRANCH_NAME" "MESSAGE" ["URL_OR_PATH"]
```

**Parameters:**
- `BRANCH_NAME` (string): Context identifier
- `MESSAGE` (string): Notification message
- `URL_OR_PATH` (optional): URL or file path to open

**Returns:** Exit code 0 on success

**Behavior:**
- Converts file paths to `file://` URLs
- Direct URL opening for web links
- Limited by osascript notification capabilities

**Examples:**
```bash
# Open file
./url-notification.sh "main" "Build complete!" "/path/to/build.log"

# Open URL
./url-notification.sh "deploy" "Site deployed" "https://myapp.com"
```

**Limitations:**
- `action url` parameter not supported in standard osascript
- Fallback behavior may vary by macOS version

---

## File Analysis

### get-file-headers.sh

Extract file header documentation from source code files across a project.

**Synopsis:**
```bash
get-file-headers.sh [PATH_TO_SEARCH]
```

**Parameters:**
- `PATH_TO_SEARCH` (optional): Directory to search (defaults to current directory)

**Returns:** 
- Exit code 0 on success
- Outputs header content to stdout

**Supported File Types:**
- `.txt` - Plain text files
- `.md` - Markdown documentation
- `.js` - JavaScript source files
- `.ts` - TypeScript source files
- `.jsx` - React JavaScript components
- `.tsx` - React TypeScript components

**Exclusions:**
- `build/` and `build/*` directories
- `dist/` and `dist/*` directories
- `node_modules/` and `node_modules/*` directories

**Header Formats Detected:**

#### JSDoc Style
```javascript
/**
 * @fileoverview Description
 * @lastmodified 2024-01-15T10:30:00Z
 * 
 * Features: Feature list
 * Main APIs: API list
 * Constraints: Constraint list
 * Patterns: Pattern list
 */
```

#### HTML Style
```html
<!-- 
@fileoverview Description
@lastmodified 2024-01-15T10:30:00Z

Features: Feature list
Main APIs: API list
Constraints: Constraint list
Patterns: Pattern list
-->
```

**Examples:**
```bash
# Extract headers from current directory
./get-file-headers.sh

# Extract headers from src directory
./get-file-headers.sh ./src

# Save headers to file
./get-file-headers.sh > headers-audit.txt
```

**Output Format:**
```
File: ./src/auth.js
/**
 * @fileoverview User authentication system
 * @lastmodified 2024-01-15T10:30:00Z
 * 
 * Features: JWT validation, session management
 * Main APIs: login(), logout(), validateToken()
 * Constraints: Requires Redis connection
 * Patterns: All functions throw AuthError on failure
 */

File: ./docs/README.md
<!-- Documentation content -->
```

---

## Utility Scripts

### Shell Integration

All scripts support help documentation:
```bash
script-name.sh help
script-name.sh --help
script-name.sh -h
```

### Common Exit Codes
- `0`: Success
- `1`: General error (permission, file not found, etc.)
- Non-zero: Script-specific error conditions

### Environment Variables
None of the scripts require environment variables, but they respect:
- `$HOME`: For shell profile modifications
- `$PWD`: For current directory operations
- Standard shell variables for path resolution

### Logging and Debugging
- `send-notification.sh`: Creates tracking files in `/tmp/notify_*`
- `cursor-handler.sh`: Logs to `/tmp/cursor-handler.log`
- `interactive-notification.sh`: Creates temporary scripts in `/tmp/notify_*_*`

### Performance Characteristics
- **Notification scripts**: ~100ms execution time
- **File analysis**: Linear time O(n) where n = number of files
- **Memory usage**: <1MB per script execution
- **Background processes**: Minimal CPU usage during sleep periods

---

## Error Handling Patterns

### Common Error Types

1. **Permission Errors**
   - File system access denied
   - Notification permission disabled
   - Shell profile write access

2. **Dependency Errors**
   - terminal-notifier not installed
   - Cursor IDE not available
   - Required system tools missing

3. **Runtime Errors**
   - Invalid file paths
   - Malformed commands
   - Network connectivity (for URLs)

### Error Recovery Strategies

All scripts implement graceful degradation:
- **Fallback mechanisms**: Alternative tools when primary unavailable
- **Safe defaults**: Reasonable behavior when parameters missing
- **Error reporting**: Clear messages about what went wrong
- **Partial success**: Continue operation when possible

### Debugging Guidelines

1. **Check dependencies**: Verify required tools are installed
2. **Test permissions**: Ensure file system and notification access
3. **Enable logging**: Use debug modes where available
4. **Isolate issues**: Test individual components separately
5. **Check system state**: Verify no conflicting processes

---

## Integration Examples

### Claude Code Workflow
```bash
# Task completion with project opening
./clickable-notification.sh "$(git branch --show-current)" "Task completed" "$(pwd)"

# Error with specific file
./clickable-notification.sh "error" "Type check failed" "./src/types.ts"
```

### Build System Integration
```bash
# Successful build
./send-notification.sh "build" "Build completed successfully" true

# Failed build with log access
./clickable-notification.sh "build-error" "Build failed" "./build.log"
```

### Git Hook Integration
```bash
# In .git/hooks/post-commit
#!/bin/bash
BRANCH=$(git branch --show-current)
./send-notification.sh "$BRANCH" "Commit successful" true
```

### CI/CD Pipeline Integration
```bash
# Pipeline success
if [ "$CI_SUCCESS" = "true" ]; then
    ./clickable-notification.sh "ci" "Pipeline succeeded" "$CI_DASHBOARD_URL"
else
    ./send-notification.sh "ci-error" "Pipeline failed - review needed"
fi
```