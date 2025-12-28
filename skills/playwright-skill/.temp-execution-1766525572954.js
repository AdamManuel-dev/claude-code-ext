const { chromium } = require('playwright');
const fs = require('fs');

const TARGET_URL = 'https://app.tahoma.io';
const EMAIL = 'adam@manuel.dev';
const PASSWORD = 'testPassword#1';

(async () => {
  console.log('🔬 COMPREHENSIVE NETWORK CAPTURE\n');

  const browser = await chromium.launch({ headless: false, slowMo: 400 });
  const context = await browser.newContext();
  const page = await context.newPage();

  const allRequests = [];
  const allResponses = [];

  // Capture EVERYTHING
  page.on('request', req => {
    const data = {
      timestamp: new Date().toISOString(),
      method: req.method(),
      url: req.url(),
      postData: req.postData()
    };
    allRequests.push(data);

    if (req.url().includes('credential') || req.url().includes('orchestration')) {
      console.log(`📤 ${req.method()} ${req.url()}`);
      if (req.postData()) {
        console.log(`   Body: ${req.postData().substring(0, 200)}`);
      }
    }
  });

  page.on('response', async res => {
    if (res.url().includes('credential') || res.url().includes('orchestration')) {
      const body = await res.text().catch(() => '');
      console.log(`📥 ${res.status()} ${res.url()}`);
      if (body && body.length < 500) {
        console.log(`   Response: ${body}`);
      }

      allResponses.push({
        timestamp: new Date().toISOString(),
        status: res.status(),
        url: res.url(),
        body: body
      });
    }
  });

  page.on('console', msg => {
    if (msg.type() === 'error') {
      console.log(`🔴 Console: ${msg.text()}`);
    }
  });

  try {
    // Login
    console.log('🔐 Logging in...\n');
    await page.goto(TARGET_URL, { waitUntil: 'networkidle' });
    await page.waitForSelector('input[name="identifier"]');
    await page.fill('input[name="identifier"]', EMAIL);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(2000);
    await page.waitForSelector('input[name="password"]');
    await page.fill('input[name="password"]', PASSWORD);
    await page.keyboard.press('Enter');
    await page.waitForTimeout(5000);
    console.log('✅ Logged in\n');

    // Navigate
    console.log('📋 Navigate to Credentials...\n');
    await page.click('a:has-text("Settings")');
    await page.waitForTimeout(1000);
    await page.click('button:has-text("Credentials")');
    await page.waitForTimeout(3000);
    console.log('✅ On Credentials page\n');

    // Open modal
    console.log('➕ Opening Add modal...\n');
    await page.click('button:has-text("Add")');
    await page.waitForTimeout(2000);

    // Fill form
    console.log('📝 Filling form...\n');
    const uniqueId = 'network-capture-' + Date.now();

    await page.locator('input[placeholder*="UnitedHealthcare"]').first().fill('Network Test');
    await page.locator('input[type="url"]').first().fill('https://networktest.com');
    await page.locator('input[placeholder*="email@example"]').first().fill(uniqueId);
    await page.locator('input[type="password"]:visible').nth(0).fill('NetTest123!');
    await page.locator('input[type="password"]:visible').nth(1).fill('NetTest123!');

    // Scroll
    await page.evaluate(() => {
      const modal = document.querySelector('[role="dialog"]');
      if (modal) modal.scrollTop = modal.scrollHeight;
    });
    await page.waitForTimeout(1000);

    // Add modifier
    const modBtn = page.locator('button:has-text("Add Modifier")').first();
    if (await modBtn.isVisible()) {
      await modBtn.click();
      await page.waitForTimeout(500);
      const inputs = await page.locator('input[type="text"]:visible').all();
      await inputs[inputs.length - 2].fill('NET');
      await inputs[inputs.length - 1].fill('NetworkScenario');
      console.log('  ✅ Modifier added: NET - NetworkScenario\n');
    }

    // Add payer
    const payBtn = page.locator('button:has-text("Add Payer")').first();
    if (await payBtn.isVisible()) {
      await payBtn.click();
      await page.waitForTimeout(500);
      const inputs = await page.locator('input[type="text"]:visible').all();
      await inputs[inputs.length - 2].fill('NetworkPayer');
      await inputs[inputs.length - 1].fill('PayerScenario');
      console.log('  ✅ Payer added: NetworkPayer - PayerScenario\n');
    }

    console.log('💾 Clicking Save button...\n');
    console.log('=' .repeat(70));
    console.log('WATCH FOR API CALLS BELOW:');
    console.log('='.repeat(70) + '\n');

    // Clear arrays before save
    allRequests.length = 0;
    allResponses.length = 0;

    // Click save
    const saveBtn = page.locator('button:has-text("Add Credential")').first();
    await saveBtn.click({ force: true });

    // Wait and watch for network activity
    console.log('\n⏳ Waiting 10 seconds for API calls...\n');
    await page.waitForTimeout(10000);

    // Save network data to file for analysis
    const networkData = {
      requests: allRequests,
      responses: allResponses
    };
    fs.writeFileSync('/tmp/network-capture.json', JSON.stringify(networkData, null, 2));

    console.log('\n' + '='.repeat(70));
    console.log('📊 NETWORK CAPTURE RESULTS');
    console.log('='.repeat(70));
    console.log(`Total requests captured: ${allRequests.length}`);
    console.log(`Total responses captured: ${allResponses.length}`);

    if (allRequests.length > 0) {
      console.log('\n📤 REQUESTS:');
      allRequests.forEach((req, i) => {
        console.log(`  ${i + 1}. ${req.method} ${req.url}`);
        if (req.postData) {
          try {
            const json = JSON.parse(req.postData);
            console.log(`     Has modifiers: ${json.modifiers ? '✅' : '❌'}`);
            console.log(`     Has payers: ${json.payers ? '✅' : '❌'}`);
            if (json.modifiers) console.log(`     Modifiers: ${JSON.stringify(json.modifiers)}`);
            if (json.payers) console.log(`     Payers: ${JSON.stringify(json.payers)}`);
          } catch (e) {
            console.log(`     Body: ${req.postData.substring(0, 100)}`);
          }
        }
      });
    }

    if (allResponses.length > 0) {
      console.log('\n📥 RESPONSES:');
      allResponses.forEach((res, i) => {
        console.log(`  ${i + 1}. ${res.status} ${res.url}`);
        if (res.body) {
          try {
            const json = JSON.parse(res.body);
            if (json.modifiers !== undefined || json.payers !== undefined) {
              console.log(`     Has modifiers: ${json.modifiers ? '✅' : '❌'}`);
              console.log(`     Has payers: ${json.payers ? '✅' : '❌'}`);
            }
          } catch (e) {
            // Not JSON
          }
        }
      });
    }

    console.log('\n💾 Full network data saved to: /tmp/network-capture.json');
    console.log('='.repeat(70));

    await page.screenshot({ path: '/tmp/network-final.png', fullPage: true });

    console.log('\n🔍 Browser open for 60s for inspection...\n');
    await page.waitForTimeout(60000);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    await page.screenshot({ path: '/tmp/network-error.png', fullPage: true });
    await page.waitForTimeout(30000);
  } finally {
    await browser.close();
    console.log('🏁 Complete\n');
  }
})();
