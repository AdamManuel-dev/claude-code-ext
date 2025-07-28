import type * as playwright from 'playwright';
import type { Context } from '../context.js';

export async function waitForCompletion<R>(context: Context, page: playwright.Page, callback: () => Promise<R>): Promise<R> {
  const requests = new Set<playwright.Request>();
  let frameNavigated = false;
  let waitCallback: () => void = () => {};
  const waitBarrier = new Promise<void>(f => { waitCallback = f; });

  const requestListener = (request: playwright.Request) => requests.add(request);
  const requestFinishedListener = (request: playwright.Request) => {
    requests.delete(request);
    if (!requests.size)
      waitCallback();
  };

  const frameNavigateListener = (frame: playwright.Frame) => {
    if (frame.parentFrame())
      return;
    frameNavigated = true;
    dispose();
    clearTimeout(timeout);
    void frame.waitForLoadState('load').then(() => {
      waitCallback();
    });
  };

  const onTimeout = () => {
    dispose();
    waitCallback();
  };

  page.on('request', requestListener);
  page.on('requestfinished', requestFinishedListener);
  page.on('framenavigated', frameNavigateListener);
  const timeout = setTimeout(onTimeout, 10000);

  const dispose = () => {
    page.off('request', requestListener);
    page.off('requestfinished', requestFinishedListener);
    page.off('framenavigated', frameNavigateListener);
    clearTimeout(timeout);
  };

  try {
    const result = await callback();
    if (!requests.size && !frameNavigated)
      waitCallback();
    await waitBarrier;
    await context.waitForTimeout(1000);
    return result;
  } finally {
    dispose();
  }
}

export function sanitizeForFilePath(s: string) {
  if (!s || typeof s !== 'string') {
    throw new Error('Invalid input: must be a non-empty string');
  }
  
  // Remove path traversal sequences
  let sanitized = s.replace(/\.\./g, '');
  
  // Replace dangerous characters with underscores
  sanitized = sanitized.replace(/[^a-zA-Z0-9_.-]/g, '_');
  
  // Ensure it doesn't start with a dot or hyphen (hidden files/flags)
  sanitized = sanitized.replace(/^[.-]/, '_');
  
  // Limit length to prevent buffer overflow
  sanitized = sanitized.substring(0, 255);
  
  // Ensure it's not empty after sanitization
  if (!sanitized) {
    sanitized = 'sanitized_file';
  }
  
  return sanitized;
} 