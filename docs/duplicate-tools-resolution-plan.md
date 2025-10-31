# Strategic Plan: Duplicate Tool Names Error Resolution

## Executive Summary
This comprehensive strategic plan addresses the "duplicate tool names" API error that's causing agents to fail silently. The error indicates that multiple tools with identical names are being registered in API requests, potentially through MCP servers, agent frameworks, or client-side code.

## Current Situation Analysis

### System Architecture
```
Claude Code Client
    ↓
MCP Framework (Tool Registration)
    ↓
Multiple MCP Servers:
- ChatGPT Agent (invoke-chatgpt)
- Stagehand (browser automation tools)
- Postman (API testing tools)
- iOS Simulator (device control tools)
    ↓
Agent Execution Framework
```

### Key Findings
1. **MCP ChatGPT Server**: Properly registers single tool "invoke-chatgpt"
2. **No Obvious Duplicates**: Server implementation shows clean tool registration
3. **Multiple MCP Servers**: Config loads multiple servers that might have overlapping tools
4. **Missing Logging**: No comprehensive logging of tool registration flow
5. **Silent Failures**: Errors aren't surfaced to users properly

## Phase 1: Root Cause Analysis Strategy

### 1.1 Tool Registration Flow Mapping
**Objective**: Trace the complete tool registration lifecycle

#### Investigation Areas
```typescript
// Points to investigate:
1. MCP Server Initialization
   - Each server's ListToolsRequest handler
   - Tool array construction
   - Response aggregation

2. Client-Side Tool Collection
   - How Claude Code collects tools from all MCP servers
   - Tool merging logic
   - API request construction

3. Agent Framework Integration
   - How agents request available tools
   - Tool filtering/selection logic
   - Retry mechanisms that might duplicate
```

#### Diagnostic Implementation
```typescript
// Add to each MCP server's tool registration
class DiagnosticToolRegistry {
  private static registrations: Map<string, {
    tool: string;
    source: string;
    timestamp: Date;
    stackTrace: string;
  }[]> = new Map();

  static registerTool(toolName: string, source: string) {
    const entry = {
      tool: toolName,
      source,
      timestamp: new Date(),
      stackTrace: new Error().stack || ''
    };

    if (!this.registrations.has(toolName)) {
      this.registrations.set(toolName, []);
    }
    this.registrations.get(toolName)!.push(entry);

    // Log duplicate detection
    if (this.registrations.get(toolName)!.length > 1) {
      console.error(`[DUPLICATE TOOL] ${toolName} registered ${this.registrations.get(toolName)!.length} times`);
      console.error('Sources:', this.registrations.get(toolName)!.map(e => e.source));
    }
  }

  static getReport(): string {
    const duplicates = Array.from(this.registrations.entries())
      .filter(([_, entries]) => entries.length > 1);

    return JSON.stringify({
      totalTools: this.registrations.size,
      duplicates: duplicates.map(([name, entries]) => ({
        tool: name,
        count: entries.length,
        sources: entries.map(e => e.source)
      }))
    }, null, 2);
  }
}
```

### 1.2 Potential Duplicate Sources

#### Hypothesis 1: Multiple MCP Server Instances
**Theory**: Same MCP server might be spawned multiple times
**Test**: Add process ID logging to server startup
```bash
# In mcp-chatgpt.sh
echo "Starting MCP Process PID: $$" >> "$LOGFILE"
```

#### Hypothesis 2: Tool Name Collisions
**Theory**: Different MCP servers register tools with same names
**Test**: Audit all MCP servers for tool names
```typescript
// Tool name audit script
const servers = ['chatgpt', 'stagehand', 'postman', 'ios-simulator'];
const toolNames = new Set<string>();
const collisions: string[] = [];

servers.forEach(server => {
  const tools = getServerTools(server);
  tools.forEach(tool => {
    if (toolNames.has(tool.name)) {
      collisions.push(`${tool.name} (collision)`);
    }
    toolNames.add(tool.name);
  });
});
```

#### Hypothesis 3: Client-Side Duplication
**Theory**: Claude Code client duplicates tools during aggregation
**Test**: Intercept tool aggregation logic

#### Hypothesis 4: Retry Logic Duplication
**Theory**: Failed requests retry and re-add tools to array
**Test**: Check for retry mechanisms without array clearing

## Phase 2: Detection & Prevention Strategy

### 2.1 Enhanced Logging System

```typescript
// Comprehensive logging middleware
interface ToolRegistrationLog {
  timestamp: Date;
  phase: 'server_init' | 'tool_list' | 'client_aggregate' | 'api_request';
  source: string;
  tools: Array<{name: string; hash: string}>;
  duplicates?: string[];
  stackTrace?: string;
}

class ToolRegistrationLogger {
  private static logs: ToolRegistrationLog[] = [];
  private static logFile = '/Users/adammanuel/.claude/logs/tool-registration.jsonl';

  static log(entry: ToolRegistrationLog) {
    this.logs.push(entry);

    // Detect duplicates in real-time
    const toolCounts = new Map<string, number>();
    entry.tools.forEach(tool => {
      toolCounts.set(tool.name, (toolCounts.get(tool.name) || 0) + 1);
    });

    const duplicates = Array.from(toolCounts.entries())
      .filter(([_, count]) => count > 1)
      .map(([name, _]) => name);

    if (duplicates.length > 0) {
      entry.duplicates = duplicates;
      console.error(`[DUPLICATE TOOLS DETECTED] Phase: ${entry.phase}, Tools: ${duplicates.join(', ')}`);
    }

    // Append to log file
    fs.appendFileSync(this.logFile, JSON.stringify(entry) + '\n');
  }

  static analyze(): DuplicateAnalysis {
    // Analysis logic for patterns
    return {
      totalRegistrations: this.logs.length,
      duplicatesByPhase: this.groupDuplicatesByPhase(),
      commonPatterns: this.findCommonPatterns(),
      recommendations: this.generateRecommendations()
    };
  }
}
```

### 2.2 Tool Deduplication Layer

```typescript
// Universal tool deduplication utility
class ToolDeduplicator {
  /**
   * Deduplicates tools based on name, preserving the most complete definition
   */
  static deduplicate(tools: Tool[]): Tool[] {
    const toolMap = new Map<string, Tool>();

    tools.forEach(tool => {
      const existing = toolMap.get(tool.name);

      if (!existing || this.isMoreComplete(tool, existing)) {
        toolMap.set(tool.name, tool);
      } else {
        console.warn(`[DEDUP] Skipping duplicate tool: ${tool.name}`);
      }
    });

    return Array.from(toolMap.values());
  }

  private static isMoreComplete(toolA: Tool, toolB: Tool): boolean {
    // Prefer tools with more complete schemas
    const schemaA = JSON.stringify(toolA.inputSchema || {}).length;
    const schemaB = JSON.stringify(toolB.inputSchema || {}).length;
    return schemaA > schemaB;
  }

  /**
   * Validates tool array for duplicates before sending
   */
  static validate(tools: Tool[]): ValidationResult {
    const names = tools.map(t => t.name);
    const uniqueNames = new Set(names);

    if (names.length !== uniqueNames.size) {
      const duplicates = names.filter((name, index) => names.indexOf(name) !== index);
      return {
        valid: false,
        error: `Duplicate tool names detected: ${Array.from(new Set(duplicates)).join(', ')}`,
        duplicates: Array.from(new Set(duplicates))
      };
    }

    return { valid: true };
  }
}
```

### 2.3 Runtime Validation Hooks

```typescript
// Inject validation at critical points
class MCPToolValidator {
  static installHooks() {
    // Hook 1: Server-side validation
    this.hookServerResponse();

    // Hook 2: Client-side aggregation
    this.hookClientAggregation();

    // Hook 3: Pre-API request
    this.hookAPIRequest();
  }

  private static hookServerResponse() {
    // Monkey-patch or wrapper around ListToolsRequest handler
    const originalHandler = server.handlers.get(ListToolsRequestSchema);

    server.setRequestHandler(ListToolsRequestSchema, async (...args) => {
      const response = await originalHandler(...args);

      // Validate and deduplicate
      const validation = ToolDeduplicator.validate(response.tools);
      if (!validation.valid) {
        console.error('[MCP Server] Tool validation failed:', validation.error);
        response.tools = ToolDeduplicator.deduplicate(response.tools);
      }

      return response;
    });
  }

  private static hookAPIRequest() {
    // Intercept API requests to validate tools
    const originalFetch = global.fetch;

    global.fetch = async (url, options) => {
      if (options?.body && typeof options.body === 'string') {
        try {
          const body = JSON.parse(options.body);

          if (body.tools && Array.isArray(body.tools)) {
            const validation = ToolDeduplicator.validate(body.tools);

            if (!validation.valid) {
              console.error('[API Request] Duplicate tools detected, deduplicating...');
              body.tools = ToolDeduplicator.deduplicate(body.tools);
              options.body = JSON.stringify(body);
            }
          }
        } catch (e) {
          // Not JSON or parsing failed, continue normally
        }
      }

      return originalFetch(url, options);
    };
  }
}
```

## Phase 3: Resolution Strategy

### 3.1 Immediate Fixes (Stopgap Solutions)

#### Fix 1: Add Deduplication to MCP Servers
```typescript
// In each MCP server's index.ts
import { ToolDeduplicator } from './validation';

// In ListToolsRequest handler
server.setRequestHandler(ListToolsRequestSchema, async () => {
  const tools = [{
    name: 'invoke-chatgpt',
    // ... rest of tool definition
  }];

  // Ensure no duplicates
  const dedupedTools = ToolDeduplicator.deduplicate(tools);

  return { tools: dedupedTools };
});
```

#### Fix 2: Client-Side Safety Check
```bash
#!/bin/bash
# Add to MCP launch scripts

# Check if server is already running
PID_FILE="/tmp/mcp-chatgpt.pid"

if [ -f "$PID_FILE" ]; then
  OLD_PID=$(cat "$PID_FILE")
  if ps -p "$OLD_PID" > /dev/null 2>&1; then
    echo "MCP ChatGPT server already running (PID: $OLD_PID)"
    exit 0
  fi
fi

# Store new PID
echo $$ > "$PID_FILE"

# Cleanup on exit
trap "rm -f $PID_FILE" EXIT
```

### 3.2 Medium-Term Improvements

#### Improvement 1: Centralized Tool Registry
```typescript
// Singleton tool registry for all MCP servers
class CentralToolRegistry {
  private static instance: CentralToolRegistry;
  private tools = new Map<string, { tool: Tool; source: string }>();

  static getInstance(): CentralToolRegistry {
    if (!this.instance) {
      this.instance = new CentralToolRegistry();
    }
    return this.instance;
  }

  registerTool(tool: Tool, source: string): boolean {
    if (this.tools.has(tool.name)) {
      console.warn(`Tool ${tool.name} already registered by ${this.tools.get(tool.name)!.source}`);
      return false;
    }

    this.tools.set(tool.name, { tool, source });
    return true;
  }

  getTools(): Tool[] {
    return Array.from(this.tools.values()).map(entry => entry.tool);
  }

  clear() {
    this.tools.clear();
  }
}
```

#### Improvement 2: Tool Namespacing
```typescript
// Namespace tools by server to prevent collisions
interface NamespacedTool extends Tool {
  name: string;  // Format: "server:toolname"
  namespace: string;
  originalName: string;
}

class ToolNamespacer {
  static namespace(tool: Tool, serverName: string): NamespacedTool {
    return {
      ...tool,
      name: `${serverName}:${tool.name}`,
      namespace: serverName,
      originalName: tool.name
    };
  }

  static denormalize(namespacedTool: NamespacedTool): Tool {
    return {
      ...namespacedTool,
      name: namespacedTool.originalName
    };
  }
}
```

### 3.3 Long-Term Architecture

#### Architecture 1: Tool Discovery Protocol
```typescript
// Implement tool discovery with conflict resolution
interface ToolDiscoveryProtocol {
  discover(): Promise<DiscoveredTools>;
  negotiate(conflicts: ToolConflict[]): Promise<ResolvedTools>;
  register(tools: Tool[]): Promise<RegistrationResult>;
}

class MCPToolDiscovery implements ToolDiscoveryProtocol {
  async discover(): Promise<DiscoveredTools> {
    const servers = await this.getMCPServers();
    const toolsByServer = new Map<string, Tool[]>();

    for (const server of servers) {
      const tools = await server.listTools();
      toolsByServer.set(server.name, tools);
    }

    return this.analyzeDiscovery(toolsByServer);
  }

  async negotiate(conflicts: ToolConflict[]): Promise<ResolvedTools> {
    // Implement conflict resolution strategies:
    // 1. Prefer local over remote
    // 2. Prefer newer versions
    // 3. Merge compatible schemas
    // 4. Namespace as last resort
  }
}
```

#### Architecture 2: Tool Lifecycle Management
```typescript
// Comprehensive tool lifecycle with events
class ToolLifecycleManager extends EventEmitter {
  private tools = new Map<string, ToolLifecycleEntry>();

  async registerTool(tool: Tool, metadata: ToolMetadata): Promise<void> {
    // Check for existing
    if (this.tools.has(tool.name)) {
      this.emit('tool:conflict', {
        existing: this.tools.get(tool.name),
        new: { tool, metadata }
      });

      // Apply conflict resolution
      const resolved = await this.resolveConflict(tool.name, tool, metadata);
      if (!resolved) return;
    }

    // Register with lifecycle tracking
    this.tools.set(tool.name, {
      tool,
      metadata,
      state: 'active',
      registered: new Date(),
      lastUsed: null,
      usageCount: 0
    });

    this.emit('tool:registered', tool);
  }

  async unregisterTool(toolName: string): Promise<void> {
    if (this.tools.has(toolName)) {
      const entry = this.tools.get(toolName)!;
      entry.state = 'deprecated';
      this.emit('tool:unregistered', entry.tool);

      // Delayed removal for grace period
      setTimeout(() => {
        this.tools.delete(toolName);
        this.emit('tool:removed', toolName);
      }, 5000);
    }
  }
}
```

## Phase 4: Testing Strategy

### 4.1 Reproduction Test Suite

```typescript
// Test suite to reliably reproduce the issue
describe('Duplicate Tool Registration Tests', () => {
  let mcpServers: MCPServer[];
  let toolRegistry: ToolRegistry;

  beforeEach(() => {
    // Clean slate
    toolRegistry = new ToolRegistry();
    mcpServers = [];
  });

  test('should detect duplicate tools from same server', async () => {
    const server = new MCPServer('test-server');

    // Simulate duplicate registration
    server.registerTool({ name: 'test-tool', ... });
    server.registerTool({ name: 'test-tool', ... });

    const tools = await server.listTools();
    expect(tools.filter(t => t.name === 'test-tool')).toHaveLength(1);
  });

  test('should handle concurrent server startups', async () => {
    // Start multiple servers simultaneously
    const promises = Array(3).fill(null).map(() =>
      startMCPServer('chatgpt')
    );

    const results = await Promise.allSettled(promises);
    const successful = results.filter(r => r.status === 'fulfilled');

    expect(successful).toHaveLength(1); // Only one should succeed
  });

  test('should detect cross-server tool conflicts', async () => {
    const server1 = new MCPServer('server1');
    const server2 = new MCPServer('server2');

    server1.registerTool({ name: 'shared-tool', ... });
    server2.registerTool({ name: 'shared-tool', ... });

    const aggregated = aggregateTools([server1, server2]);
    expect(aggregated.filter(t => t.name === 'shared-tool')).toHaveLength(1);
  });
});
```

### 4.2 Integration Testing

```typescript
// End-to-end agent testing with tool validation
class AgentIntegrationTest {
  async testAgentWithMCPTools() {
    // Start MCP servers
    const chatgptServer = await this.startMCPServer('chatgpt');
    const stagehandServer = await this.startMCPServer('stagehand');

    // Initialize agent
    const agent = new Agent({
      validateTools: true,
      deduplicateTools: true
    });

    // Execute agent task
    const result = await agent.execute({
      task: 'Use ChatGPT to analyze code',
      tools: ['invoke-chatgpt']
    });

    // Validate no duplicate tool errors
    expect(result.errors).not.toContain('duplicate tool names');

    // Check tool usage logs
    const toolLogs = await this.getToolUsageLogs();
    expect(toolLogs.duplicateErrors).toHaveLength(0);
  }

  async stressTestToolRegistration() {
    // Rapid registration/deregistration cycles
    for (let i = 0; i < 100; i++) {
      const server = await this.startMCPServer('chatgpt');
      await this.stopMCPServer(server);
    }

    // Check for lingering duplicates
    const finalTools = await this.getAllRegisteredTools();
    const toolNames = finalTools.map(t => t.name);
    const uniqueNames = new Set(toolNames);

    expect(toolNames.length).toBe(uniqueNames.size);
  }
}
```

### 4.3 Monitoring & Validation

```typescript
// Continuous monitoring for duplicate issues
class DuplicateMonitor {
  private checkInterval: NodeJS.Timer;

  start() {
    this.checkInterval = setInterval(() => {
      this.performHealthCheck();
    }, 5000);
  }

  async performHealthCheck() {
    const tools = await this.getCurrentTools();
    const validation = ToolDeduplicator.validate(tools);

    if (!validation.valid) {
      // Alert and auto-remediate
      console.error(`[HEALTH CHECK FAILED] ${validation.error}`);
      await this.autoRemediate(validation.duplicates!);
    }
  }

  async autoRemediate(duplicates: string[]) {
    // Attempt automatic fix
    for (const toolName of duplicates) {
      await this.restartServerForTool(toolName);
    }
  }
}
```

## Phase 5: Implementation Roadmap

### Stage 1: Immediate (Day 1)
**Priority: Stop the bleeding**

1. **Add Basic Logging** (2 hours)
   - Instrument MCP ChatGPT server with registration logging
   - Add timestamp and source tracking
   - Output to dedicated log file

2. **Implement Client-Side Deduplication** (1 hour)
   - Add deduplication before API calls
   - Log when duplicates are removed
   - Test with agent execution

3. **Create Diagnostic Script** (1 hour)
   - Script to analyze current tool registrations
   - Identify patterns and sources
   - Generate diagnostic report

### Stage 2: Short-term (Days 2-3)
**Priority: Understand and prevent**

1. **Enhanced Logging System** (4 hours)
   - Implement ToolRegistrationLogger
   - Add to all MCP servers
   - Create analysis tools

2. **Tool Validation Layer** (3 hours)
   - Implement ToolDeduplicator class
   - Add validation hooks
   - Test with all MCP servers

3. **Process Management** (2 hours)
   - Add PID file management
   - Prevent duplicate server starts
   - Implement graceful shutdown

### Stage 3: Medium-term (Week 1)
**Priority: Robust solution**

1. **Central Tool Registry** (6 hours)
   - Implement singleton registry
   - Integrate with all servers
   - Add conflict resolution

2. **Comprehensive Testing** (4 hours)
   - Create test suite
   - Add integration tests
   - Set up continuous testing

3. **Monitoring System** (3 hours)
   - Implement health checks
   - Add auto-remediation
   - Create alerting

### Stage 4: Long-term (Week 2+)
**Priority: Architectural improvements**

1. **Tool Discovery Protocol** (8 hours)
   - Design and implement protocol
   - Add negotiation logic
   - Migrate all servers

2. **Lifecycle Management** (6 hours)
   - Implement full lifecycle
   - Add event system
   - Create management UI

3. **Documentation** (4 hours)
   - Document architecture
   - Create troubleshooting guide
   - Update developer docs

## Risk Mitigation

### Risk Matrix

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing agents | Medium | High | Comprehensive testing, gradual rollout |
| Performance degradation | Low | Medium | Benchmark before/after, optimize hot paths |
| Incomplete fix | Medium | High | Multiple validation layers, monitoring |
| New edge cases | High | Low | Logging, quick iteration capability |

### Rollback Plan

1. **Feature Flags**
   ```typescript
   const FEATURES = {
     TOOL_DEDUPLICATION: process.env.ENABLE_DEDUP === 'true',
     CENTRAL_REGISTRY: process.env.ENABLE_REGISTRY === 'true',
     ENHANCED_LOGGING: process.env.ENABLE_LOGGING === 'true'
   };
   ```

2. **Version Pinning**
   - Tag current working version
   - Document rollback procedure
   - Test rollback process

3. **Gradual Rollout**
   - Start with ChatGPT server only
   - Monitor for 24 hours
   - Expand to other servers

## Success Metrics

### Key Performance Indicators

1. **Error Rate**
   - Target: 0% duplicate tool errors
   - Measurement: API error logs

2. **Agent Success Rate**
   - Target: 100% agent completion
   - Measurement: Agent execution logs

3. **Performance Impact**
   - Target: <10ms added latency
   - Measurement: Tool registration timing

4. **Tool Discovery Time**
   - Target: <100ms total
   - Measurement: End-to-end timing

### Monitoring Dashboard

```typescript
interface DuplicateMetrics {
  totalRegistrations: number;
  duplicatesDetected: number;
  duplicatesResolved: number;
  failedResolutions: number;
  averageResolutionTime: number;
  toolsPerServer: Map<string, number>;
  conflictsByType: Map<string, number>;
}

class MetricsDashboard {
  async getMetrics(): Promise<DuplicateMetrics> {
    // Aggregate from all sources
    return {
      totalRegistrations: await this.countRegistrations(),
      duplicatesDetected: await this.countDuplicates(),
      duplicatesResolved: await this.countResolutions(),
      failedResolutions: await this.countFailures(),
      averageResolutionTime: await this.calcAvgResolutionTime(),
      toolsPerServer: await this.getToolDistribution(),
      conflictsByType: await this.getConflictTypes()
    };
  }

  async generateReport(): Promise<string> {
    const metrics = await this.getMetrics();
    return this.formatReport(metrics);
  }
}
```

## Communication Plan

### Stakeholder Updates

1. **For Users**
   - Clear error messages when duplicates detected
   - Progress indicators during resolution
   - Success confirmation when fixed

2. **For Developers**
   - Detailed logs with actionable information
   - Stack traces for debugging
   - Performance metrics

3. **For Operations**
   - Health check endpoints
   - Monitoring alerts
   - Runbook for common issues

## Appendix: Code Snippets

### A. Complete Deduplication Implementation
[Full implementation details with 200+ lines of code]

### B. Testing Harness
[Complete test suite with all test cases]

### C. Monitoring Scripts
[Bash and TypeScript monitoring scripts]

### D. Emergency Procedures
[Step-by-step emergency response procedures]

## Summary

This strategic plan provides a comprehensive approach to resolving the duplicate tool names error through:

1. **Root cause analysis** to understand where duplicates originate
2. **Detection mechanisms** to catch duplicates early
3. **Prevention strategies** to stop duplicates from occurring
4. **Resolution tactics** for immediate, medium, and long-term fixes
5. **Testing framework** to validate solutions
6. **Implementation roadmap** with clear priorities and timelines

The plan emphasizes gradual rollout with extensive monitoring to ensure stability while fixing the core issue. The multi-layered approach ensures that even if one mechanism fails, others will catch and resolve duplicates before they cause agent failures.

## Next Steps

1. Review and approve the strategic plan
2. Begin Stage 1 implementation immediately
3. Set up monitoring and logging infrastructure
4. Coordinate with senior-code-reviewer for bug identification
5. Coordinate with ts-coder for implementation
6. Schedule daily progress reviews

---

*Last Updated: 2025-01-30*
*Plan Version: 1.0*
*Status: Ready for Implementation*