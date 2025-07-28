import { z } from 'zod'; 
import { defineTool, type ToolFactory } from './tool.js'; 

const pressKey: ToolFactory = captureSnapshot => defineTool({
  capability: 'core',

  schema: {
    name: 'browserbase_press_key',
    description: 'Press a key on the keyboard',
    inputSchema: z.object({
      key: z.string().describe('Name of the key to press or a character to generate, such as `ArrowLeft` or `a`'),
    }),
  },

  handle: async (context, params) => {
    const page = await context.getActivePage();
    if (!page) {
      throw new Error('No active page found for pressKey');
    }

    // Sanitize key input to prevent code injection
    const sanitizedKey = params.key.replace(/['\\/]/g, '\\$&');
    
    const code = [
      `// Press ${sanitizedKey}`,
      `await page.keyboard.press('${sanitizedKey}');`
    ];

    const action = async () => {
      try {
        await page.keyboard.press(params.key);
      } catch (error) {
        throw new Error(`Failed to press key '${params.key}': ${error.message}`);
      }
    };

    return {
      code,
      action,
      captureSnapshot, 
      waitForNetwork: true 
    };
  },
});

// Configure snapshot capture
const CAPTURE_SNAPSHOT = true;

export default [
  pressKey(CAPTURE_SNAPSHOT),
]; 