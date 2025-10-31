/**
 * @fileoverview Duplicate tool monitor with health checks and auto-remediation
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Features: Health checks, auto-remediation, alerts, metrics
 * Main APIs: start(), stop(), performHealthCheck()
 * Constraints: Runs periodically, requires cleanup on exit
 * Patterns: Continuous monitoring with configurable intervals
 */

import { ToolDeduplicator, ValidationResult } from '../utils/tool-deduplicator.js';

export interface HealthCheckResult {
  timestamp: Date;
  status: 'healthy' | 'warning' | 'critical';
  toolCount: number;
  duplicateCount: number;
  errors: string[];
  remediationAttempted: boolean;
  remediationSuccessful: boolean;
}

export class DuplicateMonitor {
  private checkInterval: NodeJS.Timer | null = null;
  private healthCheckInterval: number;
  private healthHistory: HealthCheckResult[] = [];
  private maxHistorySize: number = 1000;

  constructor(checkIntervalMs: number = 5000) {
    this.healthCheckInterval = checkIntervalMs;
  }

  /**
   * Start continuous health monitoring
   */
  start(): void {
    if (this.checkInterval) {
      console.warn('[Duplicate Monitor] Monitor already running');
      return;
    }

    console.log(`[Duplicate Monitor] Starting health checks every ${this.healthCheckInterval}ms`);

    this.checkInterval = setInterval(async () => {
      await this.performHealthCheck();
    }, this.healthCheckInterval);

    // Also run immediately
    this.performHealthCheck().catch((error) => {
      console.error('[Duplicate Monitor] Initial health check failed:', error);
    });
  }

  /**
   * Stop monitoring
   */
  stop(): void {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
      console.log('[Duplicate Monitor] Health monitoring stopped');
    }
  }

  /**
   * Perform a health check
   */
  async performHealthCheck(): Promise<HealthCheckResult> {
    const result: HealthCheckResult = {
      timestamp: new Date(),
      status: 'healthy',
      toolCount: 0,
      duplicateCount: 0,
      errors: [],
      remediationAttempted: false,
      remediationSuccessful: false,
    };

    try {
      // Get current tools (this would be integrated with actual tool registry)
      const tools = await this.getCurrentTools();
      result.toolCount = tools.length;

      // Validate tools
      const validation = ToolDeduplicator.validate(tools);

      if (!validation.valid) {
        result.status = 'critical';
        result.errors.push(validation.error || 'Validation failed');
        result.duplicateCount = validation.duplicates?.length || 0;

        // Attempt auto-remediation
        result.remediationAttempted = true;
        const remediated = ToolDeduplicator.deduplicate(tools);
        const retryValidation = ToolDeduplicator.validate(remediated);

        if (retryValidation.valid) {
          result.remediationSuccessful = true;
          result.status = 'warning';
          console.warn(`[Duplicate Monitor] Auto-remediated ${result.duplicateCount} duplicates`);
        } else {
          console.error('[Duplicate Monitor] Auto-remediation failed:', retryValidation.error);
        }
      }
    } catch (error) {
      result.status = 'critical';
      result.errors.push(error instanceof Error ? error.message : String(error));
      console.error('[Duplicate Monitor] Health check error:', error);
    }

    // Store in history (with trimming)
    this.healthHistory.push(result);
    if (this.healthHistory.length > this.maxHistorySize) {
      this.healthHistory = this.healthHistory.slice(-this.maxHistorySize);
    }

    // Log critical issues
    if (result.status === 'critical') {
      console.error('[Duplicate Monitor] CRITICAL: ' + result.errors.join('; '));
    }

    return result;
  }

  /**
   * Get current tools (to be overridden or integrated with registry)
   */
  private async getCurrentTools(): Promise<Array<{ name: string }>> {
    // This would integrate with the actual tool registry
    // For now, return empty array
    return [];
  }

  /**
   * Get health history
   */
  getHealthHistory(): HealthCheckResult[] {
    return [...this.healthHistory];
  }

  /**
   * Get latest health status
   */
  getLatestStatus(): HealthCheckResult | undefined {
    return this.healthHistory[this.healthHistory.length - 1];
  }

  /**
   * Get health statistics
   */
  getStats(): {
    totalChecks: number;
    healthyChecks: number;
    warningChecks: number;
    criticalChecks: number;
    averageDuplicates: number;
    remediationSuccessRate: number;
  } {
    const stats = {
      totalChecks: this.healthHistory.length,
      healthyChecks: 0,
      warningChecks: 0,
      criticalChecks: 0,
      averageDuplicates: 0,
      remediationSuccessRate: 0,
    };

    if (stats.totalChecks === 0) {
      return stats;
    }

    let totalDuplicates = 0;
    let successfulRemediations = 0;
    let remediationAttempts = 0;

    this.healthHistory.forEach((check) => {
      switch (check.status) {
        case 'healthy':
          stats.healthyChecks++;
          break;
        case 'warning':
          stats.warningChecks++;
          break;
        case 'critical':
          stats.criticalChecks++;
          break;
      }

      totalDuplicates += check.duplicateCount;

      if (check.remediationAttempted) {
        remediationAttempts++;
        if (check.remediationSuccessful) {
          successfulRemediations++;
        }
      }
    });

    stats.averageDuplicates = totalDuplicates / stats.totalChecks;
    stats.remediationSuccessRate =
      remediationAttempts > 0 ? (successfulRemediations / remediationAttempts) * 100 : 0;

    return stats;
  }

  /**
   * Clear health history
   */
  clearHistory(): void {
    this.healthHistory = [];
  }

  /**
   * Get monitoring status
   */
  isRunning(): boolean {
    return this.checkInterval !== null;
  }
}
