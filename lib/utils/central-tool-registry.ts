/**
 * @fileoverview Centralized tool registry singleton
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Singleton registry, conflict detection, tool source tracking
 * Main APIs: getInstance(), registerTool(), getTools(), clear()
 * Constraints: Thread-safe singleton, prevents duplicate registrations
 * Patterns: Centralized ownership prevents inconsistency across servers
 */

export interface ToolEntry {
  tool: Record<string, unknown>;
  source: string;
  timestamp: Date;
  namespace?: string;
}

export class CentralToolRegistry {
  private static instance: CentralToolRegistry | null = null;
  private tools = new Map<string, ToolEntry>();
  private registrationLog: Array<{ tool: string; action: 'register' | 'skip' | 'replace'; source: string; timestamp: Date }> = [];

  /**
   * Get singleton instance
   */
  static getInstance(): CentralToolRegistry {
    if (!this.instance) {
      this.instance = new CentralToolRegistry();
    }
    return this.instance;
  }

  /**
   * Register a tool in the central registry
   * @returns true if registered, false if already exists and was skipped
   */
  registerTool(tool: Record<string, unknown>, source: string, namespace?: string): boolean {
    const toolName = tool.name as string;

    if (this.tools.has(toolName)) {
      const existing = this.tools.get(toolName)!;
      console.warn(
        `[Central Registry] Tool "${toolName}" already registered by ${existing.source}, skipping registration from ${source}`
      );

      this.registrationLog.push({
        tool: toolName,
        action: 'skip',
        source,
        timestamp: new Date(),
      });

      return false;
    }

    this.tools.set(toolName, {
      tool,
      source,
      timestamp: new Date(),
      namespace,
    });

    this.registrationLog.push({
      tool: toolName,
      action: 'register',
      source,
      timestamp: new Date(),
    });

    console.log(`[Central Registry] Tool "${toolName}" registered from ${source}`);
    return true;
  }

  /**
   * Get all registered tools
   */
  getTools(): Record<string, unknown>[] {
    return Array.from(this.tools.values()).map((entry) => entry.tool);
  }

  /**
   * Get tool with metadata
   */
  getToolEntry(name: string): ToolEntry | undefined {
    return this.tools.get(name);
  }

  /**
   * Check if tool is registered
   */
  hasTool(name: string): boolean {
    return this.tools.has(name);
  }

  /**
   * Get registration source for a tool
   */
  getToolSource(name: string): string | undefined {
    return this.tools.get(name)?.source;
  }

  /**
   * Get all tools from a specific source
   */
  getToolsBySource(source: string): Record<string, unknown>[] {
    return Array.from(this.tools.values())
      .filter((entry) => entry.source === source)
      .map((entry) => entry.tool);
  }

  /**
   * Clear the registry (use with caution)
   */
  clear(): void {
    const count = this.tools.size;
    this.tools.clear();
    console.log(`[Central Registry] Cleared ${count} tools`);
  }

  /**
   * Remove a tool from registry
   */
  removeTool(name: string): boolean {
    if (this.tools.has(name)) {
      this.tools.delete(name);
      console.log(`[Central Registry] Removed tool "${name}"`);
      return true;
    }
    return false;
  }

  /**
   * Get registration statistics
   */
  getStats(): {
    totalTools: number;
    toolsBySource: Record<string, number>;
    registrationHistory: Array<{ tool: string; action: string; source: string; timestamp: string }>;
  } {
    const toolsBySource: Record<string, number> = {};

    Array.from(this.tools.values()).forEach((entry) => {
      toolsBySource[entry.source] = (toolsBySource[entry.source] || 0) + 1;
    });

    return {
      totalTools: this.tools.size,
      toolsBySource,
      registrationHistory: this.registrationLog.map((entry) => ({
        tool: entry.tool,
        action: entry.action,
        source: entry.source,
        timestamp: entry.timestamp.toISOString(),
      })),
    };
  }

  /**
   * Reset singleton (for testing)
   */
  static reset(): void {
    this.instance = null;
  }
}
