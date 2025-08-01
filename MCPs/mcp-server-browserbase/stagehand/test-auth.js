#!/usr/bin/env node

import { Stagehand } from "@browserbasehq/stagehand";
import dotenv from 'dotenv';
import crypto from 'crypto';

// Load .env file
dotenv.config({ path: '/Users/adammanuel/.claude/.env' });

console.log('=== Browserbase Authentication Test ===\n');

// Check environment
console.log('Environment variables:');
console.log('BROWSERBASE_API_KEY:', process.env.BROWSERBASE_API_KEY ? `${process.env.BROWSERBASE_API_KEY.substring(0, 10)}...` : 'NOT SET');
console.log('BROWSERBASE_PROJECT_ID:', process.env.BROWSERBASE_PROJECT_ID || 'NOT SET');
console.log('OPENAI_API_KEY:', process.env.OPENAI_API_KEY ? `${process.env.OPENAI_API_KEY.substring(0, 10)}...` : 'NOT SET');

// Generate a unique context ID
const contextId = crypto.randomUUID();
console.log('\nGenerated Context ID:', contextId);

// Test different configurations
async function testConfig(configName, config) {
  console.log(`\n=== Testing ${configName} ===`);
  console.log('Config:', JSON.stringify({
    ...config,
    apiKey: config.apiKey ? `${config.apiKey.substring(0, 10)}...` : undefined,
    modelClientOptions: {
      ...config.modelClientOptions,
      apiKey: config.modelClientOptions?.apiKey ? `${config.modelClientOptions.apiKey.substring(0, 10)}...` : undefined
    }
  }, null, 2));
  
  try {
    const stagehand = new Stagehand(config);
    await stagehand.init();
    console.log('✓ Success! Stagehand initialized.');
    
    // Test basic functionality
    const title = await stagehand.page.evaluate(() => document.title);
    console.log('✓ Page title:', title);
    
    await stagehand.close();
    return true;
  } catch (error) {
    console.error('✗ Failed:', error.message);
    if (error.stack) {
      console.error('Stack:', error.stack.split('\n').slice(0, 3).join('\n'));
    }
    return false;
  }
}

async function runTests() {
  // Test 1: Basic configuration
  await testConfig('Basic Browserbase Config', {
    env: "BROWSERBASE",
    apiKey: process.env.BROWSERBASE_API_KEY,
    projectId: process.env.BROWSERBASE_PROJECT_ID,
    modelName: "gpt-4o",
    modelClientOptions: {
      apiKey: process.env.OPENAI_API_KEY
    }
  });
  
  // Test 2: With context persistence
  await testConfig('With Context Persistence', {
    env: "BROWSERBASE",
    apiKey: process.env.BROWSERBASE_API_KEY,
    projectId: process.env.BROWSERBASE_PROJECT_ID,
    browserbaseSessionCreateParams: {
      projectId: process.env.BROWSERBASE_PROJECT_ID,
      browserSettings: {
        context: {
          id: contextId,
          persist: true
        }
      }
    },
    modelName: "gpt-4o",
    modelClientOptions: {
      apiKey: process.env.OPENAI_API_KEY
    }
  });
  
  // Test 3: Minimal config
  await testConfig('Minimal Config', {
    env: "BROWSERBASE",
    apiKey: process.env.BROWSERBASE_API_KEY,
    projectId: process.env.BROWSERBASE_PROJECT_ID
  });
}

runTests().then(() => {
  console.log('\n=== Test Complete ===');
}).catch(error => {
  console.error('\nUnexpected error:', error);
});