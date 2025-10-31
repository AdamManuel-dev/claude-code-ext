/**
 * @fileoverview MCP tool validator with runtime validation hooks
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Server-side validation, client-side aggregation hooks, API request validation
 * Main APIs: installHooks(), validate()
 * Constraints: Monkey-patches existing handlers, requires careful cleanup
 * Patterns: Validation at multiple critical points in tool registration lifecycle
 */

import { ToolDeduplicator, Tool, ValidationResult } from './tool-deduplicator.js';

export class MCPToolValidator {
  private static hooksInstalled = false;
  private static originalFetch: typeof global.fetch;

  /**
   * Install validation hooks at critical points in tool lifecycle
   */
  static installHooks(): void {
    if (this.hooksInstalled) {
      return;
    }

    try {
      this.hookAPIRequest();
      this.hooksInstalled = true;
      console.log('[MCP Tool Validator] Hooks installed successfully');
    } catch (error) {
      console.error('[MCP Tool Validator] Failed to install hooks:', error);
    }
  }

  /**
   * Uninstall validation hooks (cleanup)
   */
  static uninstallHooks(): void {
    if (!this.hooksInstalled) {
      return;
    }

    try {
      if (this.originalFetch) {
        global.fetch = this.originalFetch;
      }
      this.hooksInstalled = false;
      console.log('[MCP Tool Validator] Hooks removed successfully');
    } catch (error) {
      console.error('[MCP Tool Validator] Failed to remove hooks:', error);
    }
  }

  /**
   * Intercept API requests to validate tools before sending
   */
  private static hookAPIRequest(): void {
    this.originalFetch = global.fetch;

    global.fetch = async (url: RequestInfo | URL, options?: RequestInit) => {
      // Only intercept API calls that contain tools
      if (options?.body && typeof options.body === 'string') {
        try {
          const body = JSON.parse(options.body);

          if (body.tools && Array.isArray(body.tools)) {
            const validation = ToolDeduplicator.validate(body.tools);

            if (!validation.valid) {
              console.error('[API Request Validator] Duplicate tools detected, deduplicating...');
              console.error(`  Error: ${validation.error}`);

              // Deduplicate and validate again
              body.tools = ToolDeduplicator.deduplicate(body.tools);
              const retryValidation = ToolDeduplicator.validate(body.tools);

              if (!retryValidation.valid) {
                console.error('[API Request Validator] Deduplication failed validation:', retryValidation.error);
                // Continue anyway but log the issue
              }

              options.body = JSON.stringify(body);
            }
          }
        } catch (e) {
          // Not JSON or parsing failed, continue normally
        }
      }

      return this.originalFetch(url, options);
    };
  }

  /**
   * Validate tools at server response time
   */
  static validateServerResponse(tools: Tool[]): Tool[] {
    const validation = ToolDeduplicator.validate(tools);

    if (!validation.valid) {
      console.error('[Server Response Validator] Tool validation failed:', validation.error);

      // Auto-remediate by deduplicating
      const deduped = ToolDeduplicator.deduplicate(tools);
      const retryValidation = ToolDeduplicator.validate(deduped);

      if (retryValidation.valid) {
        console.log('[Server Response Validator] Auto-remediation successful');
        return deduped;
      }

      // If still failing, return original and let it fail downstream
      console.error('[Server Response Validator] Auto-remediation failed');
      return tools;
    }

    return tools;
  }

  /**
   * Validate and deduplicate client-side aggregated tools
   */
  static validateClientAggregation(tools: Tool[]): Tool[] {
    const validation = ToolDeduplicator.validate(tools);

    if (!validation.valid) {
      console.error('[Client Aggregation Validator] Duplicates detected:', validation.error);
      return ToolDeduplicator.deduplicate(tools);
    }

    return tools;
  }

  /**
   * Detailed validation with context
   */
  static validateWithContext(tools: Tool[], context: string): ValidationResult {
    const validation = ToolDeduplicator.validate(tools);

    if (!validation.valid) {
      console.error(`[${context}] Validation failed:`, {
        toolCount: tools.length,
        uniqueCount: new Set(tools.map((t) => t.name)).size,
        error: validation.error,
        duplicates: validation.duplicates,
      });
    }

    return validation;
  }

  /**
   * Check if hooks are installed
   */
  static areHooksInstalled(): boolean {
    return this.hooksInstalled;
  }
}
