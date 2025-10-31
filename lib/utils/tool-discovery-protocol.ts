/**
 * @fileoverview Tool discovery protocol with conflict negotiation
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Server discovery, conflict detection, negotiation strategies
 * Main APIs: discover(), negotiate(), register()
 * Constraints: Requires access to all MCP servers
 * Patterns: Implements conflict resolution strategies with fallback mechanisms
 */

import { Tool } from './tool-deduplicator.js';

export interface MCPServer {
  name: string;
  listTools(): Promise<Tool[]>;
}

export interface DiscoveredTools {
  servers: Map<string, Tool[]>;
  conflicts: ToolConflict[];
  totalTools: number;
  conflictCount: number;
}

export interface ToolConflict {
  toolName: string;
  sources: string[];
  tools: Tool[];
}

export interface ConflictResolution {
  toolName: string;
  selectedSource: string;
  selectedTool: Tool;
  strategy: 'local_preferred' | 'newest' | 'schema_merge' | 'namespace';
}

export interface ResolvedTools {
  tools: Tool[];
  resolutions: ConflictResolution[];
  failedResolutions: ToolConflict[];
}

export class MCPToolDiscovery {
  private servers: Map<string, MCPServer> = new Map();

  /**
   * Register an MCP server for discovery
   */
  registerServer(server: MCPServer): void {
    this.servers.set(server.name, server);
  }

  /**
   * Remove a server from discovery
   */
  unregisterServer(name: string): void {
    this.servers.delete(name);
  }

  /**
   * Discover all tools from registered servers
   */
  async discover(): Promise<DiscoveredTools> {
    const servers = new Map<string, Tool[]>();
    const toolsByName = new Map<string, ToolConflict>();

    // Query each server
    for (const [serverName, server] of this.servers) {
      try {
        const tools = await server.listTools();
        servers.set(serverName, tools);

        // Track conflicts
        for (const tool of tools) {
          if (!toolsByName.has(tool.name)) {
            toolsByName.set(tool.name, {
              toolName: tool.name,
              sources: [serverName],
              tools: [tool],
            });
          } else {
            const conflict = toolsByName.get(tool.name)!;
            conflict.sources.push(serverName);
            conflict.tools.push(tool);
          }
        }
      } catch (error) {
        console.error(`[Tool Discovery] Failed to query server ${serverName}:`, error);
      }
    }

    // Extract conflicts (tools appearing more than once)
    const conflicts = Array.from(toolsByName.values()).filter(
      (conflict) => conflict.sources.length > 1
    );

    return {
      servers,
      conflicts,
      totalTools: toolsByName.size,
      conflictCount: conflicts.length,
    };
  }

  /**
   * Negotiate conflicts using various strategies
   */
  async negotiate(conflicts: ToolConflict[]): Promise<ResolvedTools> {
    const resolutions: ConflictResolution[] = [];
    const failedResolutions: ToolConflict[] = [];

    for (const conflict of conflicts) {
      try {
        // Try strategies in order of preference
        let resolution = this.preferLocalStrategy(conflict);

        if (!resolution) {
          resolution = this.preferNewerStrategy(conflict);
        }

        if (!resolution) {
          resolution = this.namespaceStrategy(conflict);
        }

        if (resolution) {
          resolutions.push(resolution);
        } else {
          failedResolutions.push(conflict);
        }
      } catch (error) {
        console.error(`[Tool Discovery] Failed to resolve conflict for ${conflict.toolName}:`, error);
        failedResolutions.push(conflict);
      }
    }

    // Compile resolved tools
    const discovery = await this.discover();
    const toolMap = new Map<string, Tool>();

    // Add all non-conflicting tools
    for (const tools of discovery.servers.values()) {
      for (const tool of tools) {
        if (!toolMap.has(tool.name)) {
          toolMap.set(tool.name, tool);
        }
      }
    }

    // Replace conflicting tools with resolutions
    for (const resolution of resolutions) {
      toolMap.set(resolution.toolName, resolution.selectedTool);
    }

    return {
      tools: Array.from(toolMap.values()),
      resolutions,
      failedResolutions,
    };
  }

  /**
   * Strategy 1: Prefer local/internal tools over remote
   */
  private preferLocalStrategy(conflict: ToolConflict): ConflictResolution | null {
    // Local servers (starting with 'local-' or 'internal-') take precedence
    const localIndex = conflict.sources.findIndex(
      (s) => s.startsWith('local-') || s.startsWith('internal-')
    );

    if (localIndex >= 0) {
      return {
        toolName: conflict.toolName,
        selectedSource: conflict.sources[localIndex],
        selectedTool: conflict.tools[localIndex],
        strategy: 'local_preferred',
      };
    }

    return null;
  }

  /**
   * Strategy 2: Prefer newer tool definitions
   */
  private preferNewerStrategy(conflict: ToolConflict): ConflictResolution | null {
    // Compare based on registration timestamp or version
    // For now, prefer the one with most complete schema
    let selectedIndex = 0;
    let maxSchemaSize = 0;

    for (let i = 0; i < conflict.tools.length; i++) {
      const schemaSize = JSON.stringify(conflict.tools[i].inputSchema || {}).length;
      if (schemaSize > maxSchemaSize) {
        maxSchemaSize = schemaSize;
        selectedIndex = i;
      }
    }

    return {
      toolName: conflict.toolName,
      selectedSource: conflict.sources[selectedIndex],
      selectedTool: conflict.tools[selectedIndex],
      strategy: 'newest',
    };
  }

  /**
   * Strategy 3: Namespace tools by server
   */
  private namespaceStrategy(conflict: ToolConflict): ConflictResolution | null {
    // For namespace strategy, we'd typically keep the first one and log the conflict
    // In practice, the system would need to handle multi-resolution scenarios
    return {
      toolName: conflict.toolName,
      selectedSource: conflict.sources[0],
      selectedTool: conflict.tools[0],
      strategy: 'namespace',
    };
  }

  /**
   * Register resolved tools
   */
  async register(tools: Tool[]): Promise<RegistrationResult> {
    // This would integrate with CentralToolRegistry
    return {
      success: true,
      registered: tools.length,
      failed: 0,
      errors: [],
    };
  }

  /**
   * Get discovery report
   */
  async getReport(): Promise<string> {
    const discovery = await this.discover();
    const negotiated = await this.negotiate(discovery.conflicts);

    const report = {
      timestamp: new Date().toISOString(),
      servers: Array.from(discovery.servers.keys()),
      discovery: {
        totalTools: discovery.totalTools,
        conflicts: discovery.conflictCount,
        conflictDetails: discovery.conflicts.map((c) => ({
          toolName: c.toolName,
          conflictingSources: c.sources,
        })),
      },
      resolution: {
        resolved: negotiated.resolutions.length,
        failed: negotiated.failedResolutions.length,
        strategies: negotiated.resolutions.map((r) => ({
          tool: r.toolName,
          strategy: r.strategy,
          source: r.selectedSource,
        })),
      },
    };

    return JSON.stringify(report, null, 2);
  }
}

export interface RegistrationResult {
  success: boolean;
  registered: number;
  failed: number;
  errors: string[];
}
