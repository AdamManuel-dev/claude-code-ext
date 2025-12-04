const { chromium } = require('playwright');

const TARGET_URL = 'http://localhost:5173';
const EMAIL = 'adam@manuel.dev';
const PASSWORD = 'testPassword#1';

(async () => {
  const browser = await chromium.launch({
    headless: false,
    slowMo: 50
  });

  const context = await browser.newContext();
  const page = await context.newPage();

  const apiRequests = [];
  const apiResponses = [];

  // Capture requests
  page.on('request', request => {
    const url = request.url();
    if (url.includes('azurewebsites.net') || url.includes('/api/')) {
      apiRequests.push({
        timestamp: new Date().toISOString(),
        method: request.method(),
        url: url,
        headers: request.headers()
      });
    }
  });

  // Capture responses
  page.on('response', async response => {
    const url = response.url();
    if (url.includes('azurewebsites.net') || url.includes('/api/')) {
      let body = null;
      try {
        body = await response.text();
      } catch (e) {
        body = 'Could not read body';
      }

      apiResponses.push({
        timestamp: new Date().toISOString(),
        status: response.status(),
        statusText: response.statusText(),
        url: url,
        headers: response.headers(),
        body: body
      });
    }
  });

  // Console logging
  page.on('console', msg => {
    const text = msg.text();
    if (text.includes('[BaseAPIClient]') || text.includes('[Atlas]')) {
      console.log(`📋 ${text}`);
    }
  });

  try {
    console.log('\n🔍 Capturing Network Requests to Production API\n');
    console.log('=' .repeat(70));

    await page.goto(TARGET_URL);
    await page.waitForTimeout(2000);

    // Login
    const emailInput = page.locator('input[type="email"], input[name="email"]');
    const passwordInput = page.locator('input[type="password"]');

    if (await emailInput.count() > 0) {
      console.log('🔐 Logging in...\n');
      await emailInput.first().fill(EMAIL);
      await passwordInput.first().fill(PASSWORD);
      await passwordInput.first().press('Enter');
      await page.waitForTimeout(4000);
    }

    // Go to ATLAS
    console.log('📍 Navigating to ATLAS...\n');
    await page.goto(`${TARGET_URL}/#/atlas`);
    await page.waitForTimeout(8000); // Wait for API calls

    console.log('\n' + '=' .repeat(70));
    console.log('📊 API REQUESTS & RESPONSES CAPTURED');
    console.log('=' .repeat(70));

    if (apiRequests.length === 0) {
      console.log('\n⚠️  No API requests to production backend captured!');
      console.log('This means the frontend is not even attempting to call the API.\n');
      console.log('Possible causes:');
      console.log('  1. Error occurred before API calls (check console for JS errors)');
      console.log('  2. Authentication failed early');
      console.log('  3. Component mounted but useAtlasAgent hook not triggered\n');
    } else {
      apiRequests.forEach((req, i) => {
        console.log(`\n📤 Request #${i + 1}:`);
        console.log(`   URL: ${req.url}`);
        console.log(`   Method: ${req.method}`);
        console.log(`   Authorization: ${req.headers.authorization ? '✅ Present' : '❌ Missing'}`);
        if (req.headers.authorization) {
          const token = req.headers.authorization;
          console.log(`   Token: Bearer ${token.substring(7, 30)}...`);
        }

        const matchingResp = apiResponses.find(r => r.url === req.url &&
          Math.abs(new Date(r.timestamp) - new Date(req.timestamp)) < 1000);

        if (matchingResp) {
          console.log(`\n📥 Response #${i + 1}:`);
          console.log(`   Status: ${matchingResp.status} ${matchingResp.statusText}`);
          console.log(`   Body: ${matchingResp.body.substring(0, 200)}${matchingResp.body.length > 200 ? '...' : ''}`);

          if (matchingResp.status === 401) {
            console.log('\n   ❌ 401 UNAUTHORIZED - Authentication failed!');
            console.log('   Possible causes:');
            console.log('     • Invalid or expired JWT token');
            console.log('     • Token missing required claims (org_id, user_id)');
            console.log('     • Backend expecting different token format');
            console.log('     • CORS preflight blocking auth header');
          }
        }
      });
    }

    console.log('\n' + '=' .repeat(70));
    console.log('✅ Network capture complete');
    console.log('🖼️  Taking screenshot...');

    await page.screenshot({
      path: '/tmp/atlas-network-debug.png',
      fullPage: true
    });

    console.log('📸 Screenshot: /tmp/atlas-network-debug.png\n');

    await page.waitForTimeout(3000);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
  } finally {
    await browser.close();
  }
})();
