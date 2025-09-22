#!/usr/bin/env node

/**
 * @fileoverview MCP server that invokes ChatGPT as a sub-agent using codex command
 * @lastmodified 2025-01-22T10:30:00Z
 *
 * Features: ChatGPT invocation via codex command, streaming responses, error handling
 * Main APIs: invoke-chatgpt tool
 * Constraints: Requires codex CLI tool to be installed and accessible
 * Patterns: Uses child_process.spawn for command execution with proper error handling
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { spawn } from 'child_process';

class ChatGPTAgentServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: 'mcp-chatgpt-agent',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
    this.setupErrorHandling();
  }

  private setupErrorHandling(): void {
    this.server.onerror = (error) => {
      console.error('[MCP Error]', error);
    };

    process.on('SIGINT', async () => {
      await this.server.close();
      process.exit(0);
    });
  }

  private setupToolHandlers(): void {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'invoke-chatgpt',
            description: 'Invoke ChatGPT as a sub-agent using the codex command with dangerous bypasses',
            inputSchema: {
              type: 'object',
              properties: {
                prompt: {
                  type: 'string',
                  description: 'The prompt to send to ChatGPT',
                },
                timeout: {
                  type: 'number',
                  description: 'Timeout in milliseconds (default: 30000)',
                  default: 30000,
                },
              },
              required: ['prompt'],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      if (request.params.name !== 'invoke-chatgpt') {
        throw new Error(`Unknown tool: ${request.params.name}`);
      }

      const { prompt, timeout = 30000 } = request.params.arguments as {
        prompt: string;
        timeout?: number;
      };

      if (!prompt || typeof prompt !== 'string') {
        throw new Error('Prompt is required and must be a string');
      }

      try {
        const result = await this.invokeChatGPT(prompt, timeout);
        return {
          content: [
            {
              type: 'text',
              text: result,
            },
          ],
        };
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
        return {
          content: [
            {
              type: 'text',
              text: `Error invoking ChatGPT: ${errorMessage}`,
            },
          ],
          isError: true,
        };
      }
    });
  }

  private async invokeChatGPT(prompt: string, timeoutMs: number): Promise<string> {
    return new Promise((resolve, reject) => {
      const args = [
        '--dangerously-bypass-approvals-and-sandbox',
        '--search',
        'exec',
        prompt
      ];

      const child = spawn('codex', args, {
        stdio: ['pipe', 'pipe', 'pipe'],
        shell: false,
      });

      let stdout = '';
      let stderr = '';
      let isResolved = false;

      const cleanup = () => {
        if (!child.killed) {
          child.kill('SIGTERM');
        }
      };

      const timeout = setTimeout(() => {
        if (!isResolved) {
          isResolved = true;
          cleanup();
          reject(new Error(`ChatGPT invocation timed out after ${timeoutMs}ms`));
        }
      }, timeoutMs);

      child.stdout?.on('data', (data) => {
        stdout += data.toString();
      });

      child.stderr?.on('data', (data) => {
        stderr += data.toString();
      });

      child.on('close', (code) => {
        if (!isResolved) {
          isResolved = true;
          clearTimeout(timeout);

          if (code === 0) {
            resolve(stdout.trim() || 'ChatGPT completed successfully but returned no output');
          } else {
            const errorMsg = stderr.trim() || `Process exited with code ${code}`;
            reject(new Error(`ChatGPT invocation failed: ${errorMsg}`));
          }
        }
      });

      child.on('error', (error) => {
        if (!isResolved) {
          isResolved = true;
          clearTimeout(timeout);
          cleanup();
          reject(new Error(`Failed to spawn codex command: ${error.message}`));
        }
      });

      // Send the prompt to stdin if needed (though codex might not use it)
      if (child.stdin) {
        child.stdin.end();
      }
    });
  }

  async run(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('MCP ChatGPT Agent Server running on stdio');
  }
}

const server = new ChatGPTAgentServer();
server.run().catch(console.error);