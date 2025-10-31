/**
 * @fileoverview Unit tests for ToolDeduplicator
 * @lastmodified 2025-10-30T14:00:00Z
 *
 * Tests: Deduplication, validation, namespacing
 * Coverage: All main APIs and edge cases
 */

import { describe, test, expect } from '@jest/globals';
import { ToolDeduplicator, Tool } from '../utils/tool-deduplicator.js';

describe('ToolDeduplicator', () => {
  describe('deduplicate', () => {
    test('should remove duplicate tools by name', () => {
      const tools: Tool[] = [
        { name: 'tool1', description: 'First tool' },
        { name: 'tool1', description: 'Duplicate' },
        { name: 'tool2', description: 'Second tool' },
      ];

      const result = ToolDeduplicator.deduplicate(tools);

      expect(result).toHaveLength(2);
      expect(result.map((t) => t.name)).toEqual(['tool1', 'tool2']);
    });

    test('should prefer tools with more complete schemas', () => {
      const tools: Tool[] = [
        { name: 'test', description: 'Basic' },
        {
          name: 'test',
          description: 'Complete',
          inputSchema: { type: 'object', properties: { prop: { type: 'string' } } },
        },
      ];

      const result = ToolDeduplicator.deduplicate(tools);

      expect(result).toHaveLength(1);
      expect(result[0].inputSchema).toBeDefined();
    });

    test('should handle empty array', () => {
      const result = ToolDeduplicator.deduplicate([]);
      expect(result).toEqual([]);
    });

    test('should preserve unique tools', () => {
      const tools: Tool[] = [
        { name: 'tool1' },
        { name: 'tool2' },
        { name: 'tool3' },
      ];

      const result = ToolDeduplicator.deduplicate(tools);
      expect(result).toHaveLength(3);
    });
  });

  describe('validate', () => {
    test('should detect duplicate tool names', () => {
      const tools: Tool[] = [
        { name: 'duplicate' },
        { name: 'duplicate' },
      ];

      const result = ToolDeduplicator.validate(tools);

      expect(result.valid).toBe(false);
      expect(result.error).toContain('Duplicate tool names');
      expect(result.duplicates).toContain('duplicate');
    });

    test('should accept unique tool names', () => {
      const tools: Tool[] = [
        { name: 'tool1' },
        { name: 'tool2' },
      ];

      const result = ToolDeduplicator.validate(tools);

      expect(result.valid).toBe(true);
      expect(result.error).toBeUndefined();
    });

    test('should reject names exceeding 64 character limit', () => {
      const tools: Tool[] = [
        { name: 'a'.repeat(65) },
      ];

      const result = ToolDeduplicator.validate(tools);

      expect(result.valid).toBe(false);
      expect(result.error).toContain('64 character limit');
    });

    test('should reject names with invalid characters', () => {
      const tools: Tool[] = [
        { name: 'tool/with/slash' },
      ];

      const result = ToolDeduplicator.validate(tools);

      expect(result.valid).toBe(false);
      expect(result.error).toContain('invalid characters');
    });

    test('should accept valid tool names with allowed characters', () => {
      const tools: Tool[] = [
        { name: 'tool_name-123' },
        { name: 'TOOL' },
        { name: 'tool-with_dash' },
      ];

      const result = ToolDeduplicator.validate(tools);

      expect(result.valid).toBe(true);
    });
  });

  describe('namespaceTool', () => {
    test('should add namespace prefix to tool name', () => {
      const tool: Tool = { name: 'test' };
      const result = ToolDeduplicator.namespaceTool(tool, 'server1');

      expect(result.name).toBe('server1:test');
    });

    test('should handle long namespaced names by truncation', () => {
      const tool: Tool = { name: 'a'.repeat(60) };
      const result = ToolDeduplicator.namespaceTool(tool, 'server');

      expect(result.name.length).toBeLessThanOrEqual(64);
      expect(result.name).toContain('server:');
    });

    test('should preserve tool properties', () => {
      const tool: Tool = {
        name: 'test',
        description: 'Test tool',
        inputSchema: { type: 'object' },
      };

      const result = ToolDeduplicator.namespaceTool(tool, 'ns');

      expect(result.description).toBe('Test tool');
      expect(result.inputSchema).toEqual({ type: 'object' });
    });
  });
});
