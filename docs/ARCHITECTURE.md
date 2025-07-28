# Claude Tools Architecture

## System Overview

The Claude Tools suite is a collection of shell scripts designed to enhance development workflows through intelligent notifications, file analysis, and IDE integration. The architecture follows a modular, loosely-coupled design with clear separation of concerns.

## Design Philosophy

### Core Principles
- **Simplicity**: Each script has a single, well-defined purpose
- **Reliability**: Graceful degradation when dependencies unavailable
- **Integration-First**: Designed to work seamlessly with existing workflows
- **User-Centric**: Prioritizes developer experience and workflow efficiency

### Architectural Patterns
- **Command-Line Interface**: All tools expose consistent CLI patterns
- **Process Isolation**: Background operations don't block user workflows
- **State Management**: Minimal persistent state through filesystem tracking
- **Error Recovery**: Comprehensive fallback strategies

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Claude Tools Suite                       │
├─────────────────────────────────────────────────────────────────┤
│  User Workflows & Integration Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │ Git Hooks   │  │ Build Tools │  │ CI/CD       │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Core Script Layer                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐    ┌──────────────────────────────┐   │
│  │   Notification       │    │      File Analysis           │   │
│  │     System           │    │        System                │   │
│  │                      │    │                              │   │
│  │ • send-notification  │    │ • get-file-headers.sh        │   │
│  │ • clickable-notify   │    │                              │   │
│  │ • ack-notifications  │    │                              │   │
│  │ • interactive-notify │    │                              │   │
│  │ • url-notification   │    │                              │   │
│  └──────────────────────┘    └──────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Integration Helpers                         │   │
│  │                                                          │   │
│  │ • cursor-handler.sh  (IDE integration)                   │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    System Dependencies                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   macOS     │  │  Optional   │  │  Standard   │              │
│  │  Built-in   │  │ Dependencies│  │ UNIX Tools  │              │
│  │             │  │             │  │             │              │
│  │• osascript  │  │• terminal-  │  │• find       │              │
│  │• open       │  │  notifier   │  │• awk        │              │
│  │• date       │  │• cursor CLI │  │• sh/bash    │              │
│  │             │  │• Cursor.app │  │• grep       │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Component Architecture

### Notification System Module

```
┌─────────────────────────────────────────────┐
│          Notification System                │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────┐                        │
│  │ Entry Points    │                        │
│  │                 │                        │
│  │ • Smart Notify  │───┐                    │
│  │ • Clickable     │   │                    │
│  │ • Interactive   │   │                    │
│  │ • URL-based     │   │                    │
│  └─────────────────┘   │                    │
│                        │                    │
│                        ▼                    │
│  ┌─────────────────────────────────────┐    │
│  │       Notification Engine           │    │
│  │                                     │    │
│  │  ┌─────────────┐  ┌─────────────┐   │    │
│  │  │ osascript   │  │ terminal-   │   │    │
│  │  │ backend     │  │ notifier    │   │    │
│  │  │ (fallback)  │  │ (preferred) │   │    │
│  │  └─────────────┘  └─────────────┘   │    │
│  └─────────────────────────────────────┘    │
│                        │                    │
│                        ▼                    │
│  ┌─────────────────────────────────────┐    │
│  │     Background Services             │    │
│  │                                     │    │
│  │ • Reminder Scheduler                │    │
│  │ • Tracking File Manager             │    │
│  │ • Process Cleanup                   │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

### File Analysis Module

```
┌─────────────────────────────────────────────┐
│            File Analysis System             │
├─────────────────────────────────────────────┤
│                                             │
│              ┌─────────────────┐            │
│              │ Entry Point     │            │
│              │                 │            │
│              │ get-file-       │            │
│              │ headers.sh      │            │
│              └─────────────────┘            │
│                        │                    │
│                        ▼                    │
│  ┌─────────────────────────────────────┐    │
│  │      File Discovery Engine          │    │
│  │                                     │    │
│  │ • Recursive traversal               │    │
│  │ • Type filtering                    │    │
│  │ • Directory exclusions              │    │
│  │ • Path resolution                   │    │
│  └─────────────────────────────────────┘    │
│                        │                    │
│                        ▼                    │
│  ┌─────────────────────────────────────┐    │
│  │      Comment Extraction             │    │
│  │                                     │    │
│  │ • AWK state machine                 │    │
│  │ • JSDoc format support              │    │
│  │ • HTML comment support              │    │
│  │ • Multi-line parsing                │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

## Data Flow

### Notification Workflow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐
│   User      │───▶│   Script     │───▶│   Notification  │
│   Action    │    │   Execution  │    │   Display       │
└─────────────┘    └──────────────┘    └─────────────────┘
                             │                    │
                             ▼                    │
                   ┌──────────────┐               │
                   │   Tracking   │               │
                   │   File       │               │
                   │   Creation   │               │
                   └──────────────┘               │
                             │                    │
                             ▼                    │
                   ┌──────────────┐               │
                   │  Background  │               │
                   │  Reminder    │               │
                   │  Processes   │               │
                   └──────────────┘               │
                             │                    │
                             ▼                    ▼
                   ┌─────────────────────────────────┐
                   │      User Interaction           │
                   │   (Click/Acknowledge)           │
                   └─────────────────────────────────┘
```

### File Analysis Workflow

```
┌─────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Path      │───▶│   Directory  │───▶│   File Type     │
│   Input     │    │   Traversal  │    │   Filtering     │
└─────────────┘    └──────────────┘    └─────────────────┘
                                                │
                                                ▼
                   ┌─────────────────────────────────────┐
                   │         File Processing             │
                   │                                     │
                   │  ┌─────────────┐  ┌─────────────┐   │
                   │  │   Header    │  │   Comment   │   │
                   │  │   Detection │  │   Parsing   │   │
                   │  └─────────────┘  └─────────────┘   │
                   └─────────────────────────────────────┘
                                                │
                                                ▼
                   ┌─────────────────────────────────────┐
                   │          Output Generation          │
                   │      (Structured Text Output)       │
                   └─────────────────────────────────────┘
```

## State Management

### Tracking Files
```
/tmp/notify_[TIMESTAMP]
├── Creation: Immediate upon notification send
├── Content: Metadata about notification
├── Lifecycle: Exists until acknowledged or timeout
└── Cleanup: Manual (ack script) or process completion
```

### Process State
```
Background Processes (send-notification.sh)
├── Parent Process: Exits immediately after spawn
├── Child Processes: 7 independent sleep+notify pairs
├── Coordination: Via tracking file existence checks
└── Cleanup: Self-terminating based on file presence
```

### IDE Integration State
```
cursor-handler.sh Logging
├── Log File: /tmp/cursor-handler.log
├── Content: Execution traces and error output
├── Rotation: No automatic cleanup (manual maintenance)
└── Purpose: Debugging and troubleshooting
```

## Security Model

### Execution Context
- **User Permissions**: Scripts run with invoking user's privileges
- **File System Access**: Limited to read operations and /tmp writes
- **Network Access**: None (except opening URLs via system)
- **Process Creation**: Limited to notification and IDE processes

### Input Validation
- **Path Sanitization**: Shell-level path handling
- **Command Injection**: Minimal risk due to controlled execution
- **File Access**: Respects filesystem permissions
- **User Input**: Escaped properly in osascript calls

### Privilege Model
```
┌─────────────────────────────────────────────┐
│              User Context                   │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────┐                        │
│  │ Script Process  │                        │
│  │                 │                        │
│  │ • Read files    │                        │
│  │ • Write /tmp    │                        │
│  │ • Spawn notify  │                        │
│  │ • Open apps     │                        │
│  └─────────────────┘                        │
│           │                                 │
│           ▼                                 │
│  ┌─────────────────┐                        │
│  │ System Services │                        │
│  │                 │                        │
│  │ • Notification  │                        │
│  │   Center        │                        │
│  │ • Application   │                        │
│  │   Launcher      │                        │
│  └─────────────────┘                        │
└─────────────────────────────────────────────┘
```

## Performance Characteristics

### Execution Performance
- **Script Startup**: ~50ms (shell initialization)
- **Notification Display**: ~100ms (osascript/terminal-notifier)
- **File Processing**: ~1ms per file (header extraction)
- **IDE Integration**: ~200ms (application launch overhead)

### Resource Usage
- **Memory**: <1MB per script execution
- **CPU**: Minimal (mostly I/O bound)
- **Storage**: <1KB per tracking file
- **Network**: None (local operations only)

### Scalability
- **File Analysis**: Linear scaling O(n) with file count
- **Notification Load**: Independent processes (parallel)
- **Background Processes**: Max 7 per send-notification call
- **Tracking Files**: No practical limit (filesystem dependent)

## Integration Points

### External System Integration

```
┌─────────────────────────────────────────────┐
│            Integration Layer                │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────┐  ┌─────────────────┐   │
│  │   Git Hooks     │  │   Build Tools   │   │
│  │                 │  │                 │   │
│  │ • pre-commit    │  │ • npm scripts   │   │
│  │ • post-commit   │  │ • Makefile      │   │
│  │ • pre-push      │  │ • webpack       │   │
│  └─────────────────┘  └─────────────────┘   │
│                                             │
│  ┌─────────────────┐  ┌─────────────────┐   │
│  │   CI/CD         │  │   IDE Tools     │   │
│  │                 │  │                 │   │
│  │ • GitHub Actions│  │ • VS Code       │   │
│  │ • Jenkins       │  │ • Cursor        │   │
│  │ • GitLab CI     │  │ • Command Line  │   │
│  └─────────────────┘  └─────────────────┘   │
└─────────────────────────────────────────────┘
```

### Claude.md Integration

The tools are specifically designed to integrate with Claude.md configuration:

```yaml
# Configuration in CLAUDE.md
tools:
  notification: /Users/adammanuel/.claude/tools/send-notification.sh
  clickable: /Users/adammanuel/.claude/tools/clickable-notification.sh
  file_headers: /Users/adammanuel/.claude/tools/get-file-headers.sh
  acknowledgment: /Users/adammanuel/.claude/tools/ack-notifications.sh
```

## Error Handling Architecture

### Error Classification
1. **Dependency Errors**: Missing tools (terminal-notifier, cursor)
2. **Permission Errors**: File system, notification permissions
3. **Runtime Errors**: Invalid paths, malformed inputs
4. **System Errors**: Resource exhaustion, process limits

### Recovery Strategies
```
┌─────────────────────────────────────────────┐
│           Error Handling Chain              │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────┐                       │
│  │  Primary Path   │                       │
│  │  (Optimal)      │                       │
│  └─────────────────┘                       │
│           │                                 │
│           ▼ (on error)                      │
│  ┌─────────────────┐                       │
│  │  Fallback Path  │                       │
│  │  (Degraded)     │                       │
│  └─────────────────┘                       │
│           │                                 │
│           ▼ (on error)                      │
│  ┌─────────────────┐                       │
│  │  Safe Default   │                       │
│  │  (Minimal)      │                       │
│  └─────────────────┘                       │
└─────────────────────────────────────────────┘
```

### Failure Modes and Recovery

| Component | Failure Mode | Recovery Strategy |
|-----------|--------------|-------------------|
| terminal-notifier | Not installed | Fall back to osascript |
| Cursor IDE | Not available | Fall back to system default |
| File permissions | Access denied | Report error, continue with accessible files |
| Notification permissions | Disabled | Report requirement, continue execution |
| Background processes | Resource limits | Graceful degradation, fewer reminders |

## Extension Points

### Adding New Notification Types
1. **Follow naming convention**: `*-notification.sh`
2. **Implement help system**: Support `help` parameter
3. **Use consistent API**: `BRANCH_NAME MESSAGE [OPTIONS]`
4. **Add fallback strategy**: Handle missing dependencies

### Custom File Analysis
1. **Extend file types**: Modify find command patterns
2. **Add comment formats**: Extend AWK state machine
3. **Custom exclusions**: Add directory patterns
4. **Output formatting**: Modify output generation

### Integration Enhancements
1. **New IDE support**: Create handler scripts
2. **Additional platforms**: Add OS detection and platform-specific code
3. **Remote notifications**: Add network notification backends
4. **Enhanced tracking**: Add database or structured storage

## Future Architecture Considerations

### Scalability Enhancements
- **Configuration management**: Centralized settings
- **Plugin architecture**: Modular notification backends
- **Caching layer**: File analysis result caching
- **Distributed tracking**: Multi-machine notification coordination

### Security Improvements
- **Input validation**: Enhanced sanitization
- **Privilege separation**: Minimal permission requirements  
- **Audit logging**: Security event tracking
- **Sandboxing**: Isolated execution environments

### Performance Optimizations
- **Parallel processing**: Concurrent file analysis
- **Lazy evaluation**: On-demand resource loading
- **Result caching**: Avoid redundant operations
- **Resource pooling**: Shared process management

---

*This architecture documentation reflects the current implementation and provides guidance for future enhancements. The modular design ensures components remain loosely coupled and independently maintainable.*