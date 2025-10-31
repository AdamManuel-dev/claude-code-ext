/**
 * @fileoverview Tool deduplication utility for MCP servers
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Duplicate detection, smart deduplication, validation
 * Main APIs: deduplicate(), validate()
 * Constraints: Preserves complete tool definitions, maintains schema integrity
 * Patterns: Deduplicates by name, prefers more complete schemas
 */

export interface Tool {
  name: string;
  description?: string;
  inputSchema?: Record<string, unknown>;
  [key: string]: unknown;
}

export interface ValidationResult {
  valid: boolean;
  error?: string;
  duplicates?: string[];
}

export class ToolDeduplicator {
  /**
   * Deduplicates tools based on name, preserving the most complete definition
   * @param tools Array of tools potentially containing duplicates
   * @returns Deduplicated tool array
   */
  static deduplicate(tools: Tool[]): Tool[] {
    const toolMap = new Map<string, Tool>();

    tools.forEach((tool) => {
      const existing = toolMap.get(tool.name);

      if (!existing || this.isMoreComplete(tool, existing)) {
        toolMap.set(tool.name, tool);
      }
    });

    return Array.from(toolMap.values());
  }

  /**
   * Compares two tools to determine which has a more complete schema
   * @param toolA First tool to compare
   * @param toolB Second tool to compare
   * @returns True if toolA is more complete than toolB
   */
  private static isMoreComplete(toolA: Tool, toolB: Tool): boolean {
    // Prefer tools with descriptions
    if (toolA.description && !toolB.description) {
      return true;
    }

    // Prefer tools with input schemas
    if (toolA.inputSchema && !toolB.inputSchema) {
      return true;
    }

    // Compare by schema size
    const schemaA = JSON.stringify(toolA.inputSchema || {}).length;
    const schemaB = JSON.stringify(toolB.inputSchema || {}).length;
    return schemaA > schemaB;
  }

  /**
   * Validates a tool array for duplicates before sending to API
   * @param tools Array of tools to validate
   * @returns Validation result with error details if invalid
   */
  static validate(tools: Tool[]): ValidationResult {
    const names = tools.map((t) => t.name);
    const uniqueNames = new Set(names);

    if (names.length !== uniqueNames.size) {
      const duplicates = names.filter(
        (name, index) => names.indexOf(name) !== index
      );
      return {
        valid: false,
        error: `Duplicate tool names detected: ${Array.from(new Set(duplicates)).join(', ')}`,
        duplicates: Array.from(new Set(duplicates)),
      };
    }

    // Validate tool names meet API constraints
    for (const tool of tools) {
      if (tool.name.length > 64) {
        return {
          valid: false,
          error: `Tool name "${tool.name}" exceeds 64 character limit`,
          duplicates: [],
        };
      }

      if (!/^[a-zA-Z0-9_-]+$/.test(tool.name)) {
        return {
          valid: false,
          error: `Tool name "${tool.name}" contains invalid characters. Only alphanumeric, underscore, and hyphen allowed.`,
          duplicates: [],
        };
      }
    }

    return { valid: true };
  }

  /**
   * Attempts to fix invalid tool names by namespacing them
   * @param tools Tools with potentially invalid names
   * @param namespace Prefix namespace (e.g., server name)
   * @returns Tools with namespaced names
   */
  static namespaceTool(tool: Tool, namespace: string): Tool {
    const maxNameLength = 64;
    const separator = ':';

    // Try to namespace the tool name
    const namespacedName = `${namespace}${separator}${tool.name}`;

    if (namespacedName.length > maxNameLength) {
      // If still too long, abbreviate
      const maxTruncated = maxNameLength - namespace.length - separator.length;
      const truncatedName = tool.name.substring(0, maxTruncated);
      return {
        ...tool,
        name: `${namespace}${separator}${truncatedName}`,
      };
    }

    return {
      ...tool,
      name: namespacedName,
    };
  }
}
