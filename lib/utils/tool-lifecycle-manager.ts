/**
 * @fileoverview Tool lifecycle manager with event system
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Full lifecycle tracking, events, conflict resolution, graceful deprecation
 * Main APIs: registerTool(), unregisterTool(), resolveConflict(), on()
 * Constraints: EventEmitter-based, requires cleanup on shutdown
 * Patterns: State machine for tool lifecycle with event notifications
 */

import { EventEmitter } from 'node:events';
import { Tool } from './tool-deduplicator.js';

export interface ToolMetadata {
  version?: string;
  namespace?: string;
  priority?: number;
  tags?: string[];
  deprecated?: boolean;
  deprecationDate?: Date;
}

export interface ToolLifecycleEntry {
  tool: Tool;
  metadata: ToolMetadata;
  state: 'active' | 'deprecated' | 'removed';
  registered: Date;
  lastUsed: Date | null;
  usageCount: number;
}

export interface ToolConflictEvent {
  toolName: string;
  existing: ToolLifecycleEntry;
  new: { tool: Tool; metadata: ToolMetadata };
}

export class ToolLifecycleManager extends EventEmitter {
  private tools: Map<string, ToolLifecycleEntry>;
  private conflictHandlers: Map<string, (conflict: ToolConflictEvent) => Promise<boolean>>;
  private deprecationGracePeriod: number;

  constructor() {
    super();
    this.setMaxListeners(100); // Prevent warnings
    this.tools = new Map<string, ToolLifecycleEntry>();
    this.conflictHandlers = new Map<string, (conflict: ToolConflictEvent) => Promise<boolean>>();
    this.deprecationGracePeriod = 5000; // 5 seconds by default
  }

  /**
   * Register a tool with lifecycle tracking
   */
  async registerTool(tool: Tool, metadata: ToolMetadata = {}): Promise<void> {
    const toolName = tool.name;

    if (this.tools.has(toolName)) {
      const existing = this.tools.get(toolName)!;

      // Emit conflict event
      const conflictEvent: ToolConflictEvent = {
        toolName,
        existing,
        new: { tool, metadata },
      };

      (this as any).emit('tool:conflict', conflictEvent);

      // Try to resolve conflict
      const resolved = await this.resolveConflict(toolName, tool, metadata);
      if (!resolved) {
        return;
      }
    }

    // Register with lifecycle tracking
    this.tools.set(toolName, {
      tool,
      metadata,
      state: 'active',
      registered: new Date(),
      lastUsed: null,
      usageCount: 0,
    });

    (this as any).emit('tool:registered', tool);
    console.log(`[Tool Lifecycle] Registered tool: ${toolName}`);
  }

  /**
   * Mark a tool as deprecated (soft removal)
   */
  async deprecateTool(toolName: string, replacementTool?: string): Promise<void> {
    if (!this.tools.has(toolName)) {
      console.warn(`[Tool Lifecycle] Cannot deprecate non-existent tool: ${toolName}`);
      return;
    }

    const entry = this.tools.get(toolName)!;
    entry.state = 'deprecated';
    entry.metadata.deprecated = true;
    entry.metadata.deprecationDate = new Date();

    (this as any).emit('tool:deprecated', {
      toolName,
      replacement: replacementTool,
      entry,
    });

    console.log(`[Tool Lifecycle] Deprecated tool: ${toolName}`);

    // Schedule removal after grace period
    setTimeout(() => {
      this.removeTool(toolName);
    }, this.deprecationGracePeriod);
  }

  /**
   * Unregister a tool (hard removal)
   */
  async unregisterTool(toolName: string): Promise<void> {
    if (!this.tools.has(toolName)) {
      return;
    }

    const entry = this.tools.get(toolName)!;
    entry.state = 'deprecated';

    (this as any).emit('tool:unregistered', entry.tool);

    // Delayed removal for grace period
    setTimeout(() => {
      this.removeTool(toolName);
    }, this.deprecationGracePeriod);
  }

  /**
   * Actually remove the tool
   */
  private removeTool(toolName: string): void {
    if (this.tools.has(toolName)) {
      this.tools.delete(toolName);
      (this as any).emit('tool:removed', toolName);
      console.log(`[Tool Lifecycle] Removed tool: ${toolName}`);
    }
  }

  /**
   * Handle tool conflicts
   */
  private async resolveConflict(
    toolName: string,
    newTool: Tool,
    newMetadata: ToolMetadata
  ): Promise<boolean> {
    const existing = this.tools.get(toolName)!;
    const existingPriority = existing.metadata.priority || 0;

    // Check if custom handler is registered
    if (this.conflictHandlers.has(toolName)) {
      const handler = this.conflictHandlers.get(toolName)!;
      const conflictEvent: ToolConflictEvent = {
        toolName,
        existing,
        new: { tool: newTool, metadata: newMetadata },
      };

      try {
        const resolved = await handler(conflictEvent);
        return resolved;
      } catch (error) {
        console.error(`[Tool Lifecycle] Conflict handler error for ${toolName}:`, error);
        return false;
      }
    }

    // Default: higher priority wins
    const newPriority = newMetadata.priority || 0;

    if (newPriority > existingPriority) {
      // Replace with new tool
      this.tools.set(toolName, {
        tool: newTool,
        metadata: newMetadata,
        state: 'active',
        registered: new Date(),
        lastUsed: null,
        usageCount: 0,
      });
      (this as any).emit('tool:replaced', { old: existing, new: newTool });
      return true;
    }

    return false;
  }

  /**
   * Register a custom conflict handler
   */
  setConflictHandler(
    toolName: string,
    handler: (conflict: ToolConflictEvent) => Promise<boolean>
  ): void {
    this.conflictHandlers.set(toolName, handler);
  }

  /**
   * Record tool usage
   */
  recordUsage(toolName: string): void {
    if (this.tools.has(toolName)) {
      const entry = this.tools.get(toolName)!;
      entry.lastUsed = new Date();
      entry.usageCount++;
    }
  }

  /**
   * Get tool info
   */
  getToolEntry(toolName: string): ToolLifecycleEntry | undefined {
    return this.tools.get(toolName);
  }

  /**
   * Get all tools
   */
  getAllTools(): Tool[] {
    return Array.from(this.tools.values())
      .filter((entry) => entry.state === 'active')
      .map((entry) => entry.tool);
  }

  /**
   * Get lifecycle statistics
   */
  getStats(): {
    totalActive: number;
    totalDeprecated: number;
    mostUsed: Array<{ name: string; count: number }>;
    neverUsed: string[];
    averageUsage: number;
  } {
    const active = Array.from(this.tools.values()).filter((e) => e.state === 'active');
    const deprecated = Array.from(this.tools.values()).filter((e) => e.state === 'deprecated');

    const usageStats = active
      .map((e) => ({ name: e.tool.name, count: e.usageCount }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    const neverUsed = active.filter((e) => e.usageCount === 0).map((e) => e.tool.name);

    const averageUsage = active.length > 0
      ? active.reduce((sum, e) => sum + e.usageCount, 0) / active.length
      : 0;

    return {
      totalActive: active.length,
      totalDeprecated: deprecated.length,
      mostUsed: usageStats,
      neverUsed,
      averageUsage,
    };
  }

  /**
   * Set deprecation grace period
   */
  setDeprecationGracePeriod(ms: number): void {
    this.deprecationGracePeriod = ms;
  }

  /**
   * Clear all tools (use with caution)
   */
  clear(): void {
    this.tools.clear();
    this.conflictHandlers.clear();
    console.log('[Tool Lifecycle] Cleared all tools');
  }
}
