#!/usr/bin/env node

import { Stagehand } from "@browserbasehq/stagehand";
import dotenv from 'dotenv';

// Load .env file
dotenv.config({ path: '/Users/adammanuel/.claude/.env' });

console.log('Environment check:');
console.log('BROWSERBASE_API_KEY:', process.env.BROWSERBASE_API_KEY ? '✓ Set' : '✗ Not set');
console.log('BROWSERBASE_PROJECT_ID:', process.env.BROWSERBASE_PROJECT_ID ? '✓ Set' : '✗ Not set');
console.log('OPENAI_API_KEY:', process.env.OPENAI_API_KEY ? '✓ Set' : '✗ Not set');

const config = {
  env: "BROWSERBASE",
  apiKey: process.env.BROWSERBASE_API_KEY,
  projectId: process.env.BROWSERBASE_PROJECT_ID,
  domSettleTimeoutMs: 30000,
  browserbaseSessionCreateParams: {
    projectId: process.env.BROWSERBASE_PROJECT_ID,
    browserSettings: {
      context: {
        id: process.env.CONTEXT_ID || `test-context-${Date.now()}`,
        persist: true
      }
    }
  },
  enableCaching: true,
  modelName: "gpt-4o",
  modelClientOptions: {
    apiKey: process.env.OPENAI_API_KEY
  },
  useAPI: false,
  logger: (message) => {
    console.log('[Stagehand Log]:', message);
  }
};

console.log('\nStagehand config:', JSON.stringify(config, null, 2));

async function testStagehand() {
  try {
    console.log('\nInitializing Stagehand...');
    const stagehand = new Stagehand(config);
    
    console.log('Calling stagehand.init()...');
    await stagehand.init();
    
    console.log('✓ Stagehand initialized successfully!');
    
    console.log('\nTesting page access...');
    const title = await stagehand.page.evaluate(() => document.title);
    console.log('✓ Page title:', title);
    
    console.log('\nNavigating to Google...');
    await stagehand.page.goto('https://google.com');
    
    const googleTitle = await stagehand.page.evaluate(() => document.title);
    console.log('✓ Google page title:', googleTitle);
    
    console.log('\n✓ All tests passed!');
    
    await stagehand.close();
  } catch (error) {
    console.error('\n✗ Error:', error.message);
    console.error('Stack trace:', error.stack);
  }
}

testStagehand();