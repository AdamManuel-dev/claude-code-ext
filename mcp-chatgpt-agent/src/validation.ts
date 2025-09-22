/**
 * @fileoverview Validation utilities for MCP ChatGPT agent
 * @lastmodified 2025-01-22T10:30:00Z
 *
 * Features: Input validation, sanitization, security checks
 * Main APIs: validatePrompt(), sanitizeInput(), checkCodexAvailability()
 * Constraints: Enforces prompt length limits and security constraints
 * Patterns: Throws ValidationError for invalid inputs with detailed messages
 */

export class ValidationError extends Error {
  constructor(message: string, public readonly code: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

export interface ValidationOptions {
  maxPromptLength?: number;
  allowedCharacters?: RegExp;
  forbiddenPatterns?: RegExp[];
}

const DEFAULT_OPTIONS: Required<ValidationOptions> = {
  maxPromptLength: 10000,
  allowedCharacters: /^[\s\S]*$/, // Allow all characters by default
  forbiddenPatterns: [
    /rm\s+-rf/i, // Dangerous file operations
    /sudo\s+/i,  // Sudo commands
    />\s*\/dev\/null/i, // Output redirection that might hide errors
  ],
};

export function validatePrompt(prompt: string, options: ValidationOptions = {}): void {
  const opts = { ...DEFAULT_OPTIONS, ...options };

  if (typeof prompt !== 'string') {
    throw new ValidationError('Prompt must be a string', 'INVALID_TYPE');
  }

  if (prompt.trim().length === 0) {
    throw new ValidationError('Prompt cannot be empty', 'EMPTY_PROMPT');
  }

  if (prompt.length > opts.maxPromptLength) {
    throw new ValidationError(
      `Prompt exceeds maximum length of ${opts.maxPromptLength} characters`,
      'PROMPT_TOO_LONG'
    );
  }

  if (!opts.allowedCharacters.test(prompt)) {
    throw new ValidationError('Prompt contains invalid characters', 'INVALID_CHARACTERS');
  }

  for (const pattern of opts.forbiddenPatterns) {
    if (pattern.test(prompt)) {
      throw new ValidationError(
        `Prompt contains forbidden pattern: ${pattern.source}`,
        'FORBIDDEN_PATTERN'
      );
    }
  }
}

export function sanitizeInput(input: string): string {
  return input
    .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '') // Remove control characters
    .trim();
}

export async function checkCodexAvailability(): Promise<boolean> {
  const { spawn } = await import('child_process');

  return new Promise((resolve) => {
    const child = spawn('which', ['codex'], { stdio: 'pipe' });

    child.on('close', (code) => {
      resolve(code === 0);
    });

    child.on('error', () => {
      resolve(false);
    });

    setTimeout(() => {
      child.kill();
      resolve(false);
    }, 5000);
  });
}