/**
 * @fileoverview Unit tests for CentralToolRegistry
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Tests: Singleton behavior, registration, conflict detection
 * Coverage: All main APIs and edge cases
 */

import { describe, test, expect, beforeEach, afterEach } from '@jest/globals';
import { CentralToolRegistry } from '../utils/central-tool-registry.js';

describe('CentralToolRegistry', () => {
  beforeEach(() => {
    CentralToolRegistry.reset();
  });

  afterEach(() => {
    CentralToolRegistry.reset();
  });

  describe('singleton', () => {
    test('should return same instance on multiple calls', () => {
      const instance1 = CentralToolRegistry.getInstance();
      const instance2 = CentralToolRegistry.getInstance();

      expect(instance1).toBe(instance2);
    });
  });

  describe('registerTool', () => {
    test('should register a tool successfully', () => {
      const registry = CentralToolRegistry.getInstance();
      const tool = { name: 'test-tool', description: 'A test tool' };

      const result = registry.registerTool(tool, 'source1');

      expect(result).toBe(true);
      expect(registry.hasTool('test-tool')).toBe(true);
    });

    test('should prevent duplicate registration of same tool', () => {
      const registry = CentralToolRegistry.getInstance();
      const tool = { name: 'test-tool' };

      const result1 = registry.registerTool(tool, 'source1');
      const result2 = registry.registerTool(tool, 'source2');

      expect(result1).toBe(true);
      expect(result2).toBe(false);
      expect(registry.getToolSource('test-tool')).toBe('source1');
    });

    test('should allow multiple tools from same source', () => {
      const registry = CentralToolRegistry.getInstance();

      const result1 = registry.registerTool({ name: 'tool1' }, 'source1');
      const result2 = registry.registerTool({ name: 'tool2' }, 'source1');

      expect(result1).toBe(true);
      expect(result2).toBe(true);
      expect(registry.getToolsBySource('source1')).toHaveLength(2);
    });
  });

  describe('getTools', () => {
    test('should return all registered tools', () => {
      const registry = CentralToolRegistry.getInstance();

      registry.registerTool({ name: 'tool1' }, 'source1');
      registry.registerTool({ name: 'tool2' }, 'source1');
      registry.registerTool({ name: 'tool3' }, 'source2');

      const tools = registry.getTools();

      expect(tools).toHaveLength(3);
      expect(tools.map((t) => t.name)).toContain('tool1');
      expect(tools.map((t) => t.name)).toContain('tool2');
      expect(tools.map((t) => t.name)).toContain('tool3');
    });

    test('should return empty array initially', () => {
      const registry = CentralToolRegistry.getInstance();
      expect(registry.getTools()).toEqual([]);
    });
  });

  describe('getToolsBySource', () => {
    test('should return tools for specific source', () => {
      const registry = CentralToolRegistry.getInstance();

      registry.registerTool({ name: 'tool1' }, 'source1');
      registry.registerTool({ name: 'tool2' }, 'source1');
      registry.registerTool({ name: 'tool3' }, 'source2');

      const source1Tools = registry.getToolsBySource('source1');
      const source2Tools = registry.getToolsBySource('source2');

      expect(source1Tools).toHaveLength(2);
      expect(source2Tools).toHaveLength(1);
    });
  });

  describe('removeTool', () => {
    test('should remove a registered tool', () => {
      const registry = CentralToolRegistry.getInstance();

      registry.registerTool({ name: 'test-tool' }, 'source1');
      const result = registry.removeTool('test-tool');

      expect(result).toBe(true);
      expect(registry.hasTool('test-tool')).toBe(false);
    });

    test('should return false for non-existent tool', () => {
      const registry = CentralToolRegistry.getInstance();
      const result = registry.removeTool('non-existent');

      expect(result).toBe(false);
    });
  });

  describe('clear', () => {
    test('should clear all registered tools', () => {
      const registry = CentralToolRegistry.getInstance();

      registry.registerTool({ name: 'tool1' }, 'source1');
      registry.registerTool({ name: 'tool2' }, 'source1');

      registry.clear();

      expect(registry.getTools()).toEqual([]);
    });
  });

  describe('getStats', () => {
    test('should provide accurate statistics', () => {
      const registry = CentralToolRegistry.getInstance();

      registry.registerTool({ name: 'tool1' }, 'source1');
      registry.registerTool({ name: 'tool2' }, 'source1');
      registry.registerTool({ name: 'tool3' }, 'source2');

      const stats = registry.getStats();

      expect(stats.totalTools).toBe(3);
      expect(stats.toolsBySource['source1']).toBe(2);
      expect(stats.toolsBySource['source2']).toBe(1);
    });
  });
});
