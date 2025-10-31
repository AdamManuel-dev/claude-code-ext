/**
 * @fileoverview Tool registration logging system
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Comprehensive logging, duplicate detection, analysis, reporting
 * Main APIs: log(), analyze(), getReport()
 * Constraints: JSONL format for streaming analysis, includes stack traces
 * Patterns: Real-time duplicate detection with detailed context
 */

import * as fs from 'fs';
import * as path from 'path';

export interface ToolInfo {
  name: string;
  hash?: string;
  source?: string;
}

export interface ToolRegistrationLog {
  timestamp: Date;
  phase: 'server_init' | 'tool_list' | 'client_aggregate' | 'api_request';
  source: string;
  tools: ToolInfo[];
  duplicates?: string[];
  stackTrace?: string;
}

export interface DuplicateAnalysis {
  totalRegistrations: number;
  duplicatesByPhase: Map<string, number>;
  commonPatterns: string[];
  recommendations: string[];
}

export class ToolRegistrationLogger {
  private static logs: ToolRegistrationLog[] = [];
  private static logFile: string;

  static initialize(logDir: string = path.join(process.env.HOME || '/tmp', '.claude/logs')): void {
    if (!fs.existsSync(logDir)) {
      fs.mkdirSync(logDir, { recursive: true });
    }
    this.logFile = path.join(logDir, 'tool-registration.jsonl');
  }

  /**
   * Log a tool registration event
   * @param entry Log entry containing tools and registration context
   */
  static log(entry: ToolRegistrationLog): void {
    this.logs.push(entry);

    // Detect duplicates in real-time
    const toolCounts = new Map<string, number>();
    entry.tools.forEach((tool) => {
      toolCounts.set(tool.name, (toolCounts.get(tool.name) || 0) + 1);
    });

    const duplicates = Array.from(toolCounts.entries())
      .filter(([_, count]) => count > 1)
      .map(([name, _]) => name);

    if (duplicates.length > 0) {
      entry.duplicates = duplicates;
      console.error(
        `[DUPLICATE TOOLS DETECTED] Phase: ${entry.phase}, Tools: ${duplicates.join(', ')}`
      );
    }

    // Write to log file
    if (this.logFile && fs.existsSync(path.dirname(this.logFile))) {
      fs.appendFileSync(this.logFile, JSON.stringify(entry) + '\n');
    }
  }

  /**
   * Analyze logged data for patterns and recommendations
   */
  static analyze(): DuplicateAnalysis {
    const duplicatesByPhase = new Map<string, number>();
    const allDuplicates = new Set<string>();

    this.logs.forEach((log) => {
      if (log.duplicates && log.duplicates.length > 0) {
        const count = duplicatesByPhase.get(log.phase) || 0;
        duplicatesByPhase.set(log.phase, count + log.duplicates.length);
        log.duplicates.forEach((dup) => allDuplicates.add(dup));
      }
    });

    const commonPatterns = this.findCommonPatterns();
    const recommendations = this.generateRecommendations(allDuplicates);

    return {
      totalRegistrations: this.logs.length,
      duplicatesByPhase,
      commonPatterns,
      recommendations,
    };
  }

  /**
   * Find common patterns in duplicate registration
   */
  private static findCommonPatterns(): string[] {
    const patterns: string[] = [];

    // Find tools that duplicate across multiple phases
    const toolsByPhase = new Map<string, Set<string>>();
    this.logs.forEach((log) => {
      if (!toolsByPhase.has(log.phase)) {
        toolsByPhase.set(log.phase, new Set());
      }
      log.tools.forEach((tool) => {
        toolsByPhase.get(log.phase)!.add(tool.name);
      });
    });

    // Check for tools appearing in multiple phases
    const allTools = new Map<string, number>();
    toolsByPhase.forEach((tools) => {
      tools.forEach((tool) => {
        allTools.set(tool, (allTools.get(tool) || 0) + 1);
      });
    });

    allTools.forEach((count, tool) => {
      if (count > 1) {
        patterns.push(`Tool "${tool}" appears across ${count} different phases`);
      }
    });

    // Find sources registering duplicate tools
    const sourcesByTool = new Map<string, Set<string>>();
    this.logs.forEach((log) => {
      log.tools.forEach((tool) => {
        if (!sourcesByTool.has(tool.name)) {
          sourcesByTool.set(tool.name, new Set());
        }
        sourcesByTool.get(tool.name)!.add(log.source);
      });
    });

    sourcesByTool.forEach((sources, tool) => {
      if (sources.size > 1) {
        patterns.push(`Tool "${tool}" registered by multiple sources: ${Array.from(sources).join(', ')}`);
      }
    });

    return patterns;
  }

  /**
   * Generate recommendations based on analysis
   */
  private static generateRecommendations(duplicates: Set<string>): string[] {
    const recommendations: string[] = [];

    if (duplicates.size > 0) {
      recommendations.push('Enable tool deduplication layer in MCP servers');
      recommendations.push('Implement centralized tool registry to prevent re-registration');
      recommendations.push('Add tool namespacing for cross-server conflicts');

      if (duplicates.size > 5) {
        recommendations.push('Consider tool discovery protocol to negotiate conflicts');
      }
    }

    return recommendations;
  }

  /**
   * Generate a comprehensive report from logs
   */
  static getReport(): string {
    const analysis = this.analyze();

    const report = {
      timestamp: new Date().toISOString(),
      summary: {
        totalRegistrations: analysis.totalRegistrations,
        uniqueDuplicates: analysis.duplicatesByPhase.size,
      },
      duplicatesByPhase: Object.fromEntries(analysis.duplicatesByPhase),
      patterns: analysis.commonPatterns,
      recommendations: analysis.recommendations,
    };

    return JSON.stringify(report, null, 2);
  }

  /**
   * Clear logs (for testing or reset)
   */
  static clear(): void {
    this.logs = [];
  }

  /**
   * Get all logged entries
   */
  static getLogs(): ToolRegistrationLog[] {
    return [...this.logs];
  }
}

// Initialize on module load
ToolRegistrationLogger.initialize();
