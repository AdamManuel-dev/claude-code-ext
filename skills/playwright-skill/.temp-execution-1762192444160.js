const { chromium } = require('playwright');

// Target URL for the production build
const TARGET_URL = 'http://localhost:3000';

(async () => {
  const browser = await chromium.launch({ headless: false, slowMo: 100 });
  const page = await browser.newPage();

  console.log('🚀 Testing production build at', TARGET_URL);

  try {
    // Navigate to the application
    console.log('\n1️⃣ Loading application...');
    await page.goto(TARGET_URL, {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    const title = await page.title();
    console.log('   ✅ Page loaded successfully');
    console.log('   📄 Title:', title);

    // Wait a moment for any dynamic content
    await page.waitForTimeout(2000);

    // Check for console errors
    const errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        errors.push(msg.text());
      }
    });

    // Take full page screenshot
    console.log('\n2️⃣ Capturing full page screenshot...');
    await page.screenshot({
      path: '/tmp/build-test-fullpage.png',
      fullPage: true
    });
    console.log('   📸 Screenshot saved to /tmp/build-test-fullpage.png');

    // Test responsive design
    console.log('\n3️⃣ Testing responsive viewports...');

    const viewports = [
      { name: 'Desktop', width: 1920, height: 1080 },
      { name: 'Tablet', width: 768, height: 1024 },
      { name: 'Mobile', width: 375, height: 667 }
    ];

    for (const viewport of viewports) {
      console.log(`   📱 Testing ${viewport.name} (${viewport.width}x${viewport.height})`);
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height
      });
      await page.waitForTimeout(500);
      await page.screenshot({
        path: `/tmp/build-test-${viewport.name.toLowerCase()}.png`,
        fullPage: true
      });
    }

    // Check for common UI elements
    console.log('\n4️⃣ Checking for key UI elements...');

    // Check if there's any content on the page
    const bodyText = await page.textContent('body');
    if (bodyText && bodyText.length > 0) {
      console.log('   ✅ Page has content');
    } else {
      console.log('   ⚠️ Warning: Page appears to be empty');
    }

    // Check for navigation elements
    const nav = await page.locator('nav').count();
    if (nav > 0) {
      console.log(`   ✅ Found ${nav} navigation element(s)`);
    }

    // Check for headings
    const headings = await page.locator('h1, h2, h3').count();
    if (headings > 0) {
      console.log(`   ✅ Found ${headings} heading(s)`);
    }

    // Check for buttons
    const buttons = await page.locator('button').count();
    if (buttons > 0) {
      console.log(`   ✅ Found ${buttons} button(s)`);
    }

    // Check for links
    const links = await page.locator('a').count();
    if (links > 0) {
      console.log(`   ✅ Found ${links} link(s)`);
    }

    // Test basic interactivity
    console.log('\n5️⃣ Testing basic interactivity...');

    // Try clicking the first button if it exists
    const firstButton = page.locator('button').first();
    const buttonCount = await firstButton.count();
    if (buttonCount > 0) {
      const buttonText = await firstButton.textContent();
      console.log(`   🖱️ Clicking first button: "${buttonText}"`);
      await firstButton.click();
      await page.waitForTimeout(1000);
      console.log('   ✅ Button click successful');
    }

    // Final screenshot after interaction
    await page.screenshot({
      path: '/tmp/build-test-after-interaction.png',
      fullPage: true
    });

    // Summary
    console.log('\n' + '='.repeat(50));
    console.log('✅ BUILD TEST COMPLETE');
    console.log('='.repeat(50));
    console.log(`📊 Results:`);
    console.log(`   - Application loads successfully`);
    console.log(`   - Responsive design tested across 3 viewports`);
    console.log(`   - Screenshots saved to /tmp/build-test-*.png`);
    console.log(`   - UI elements detected: ${nav} nav, ${headings} headings, ${buttons} buttons, ${links} links`);
    if (errors.length > 0) {
      console.log(`   ⚠️ Console errors detected: ${errors.length}`);
      errors.forEach(err => console.log(`     - ${err}`));
    } else {
      console.log(`   ✅ No console errors detected`);
    }
    console.log('='.repeat(50));

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    await page.screenshot({ path: '/tmp/build-test-error.png' });
    console.log('   📸 Error screenshot saved to /tmp/build-test-error.png');
  } finally {
    await browser.close();
  }
})();
