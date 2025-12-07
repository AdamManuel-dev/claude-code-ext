
(async () => {
  try {
    /**
 * CF-001 Step 8 Debugging with Manual 2FA Support
 */
const { chromium } = require('playwright');
const fs = require('fs');

const USERNAME = 'info+1@gina4med.com';
const PASSWORD = 'Rakovski@345';

async function debugWithManual2FA() {
  const browser = await chromium.launch({
    headless: false,
    slowMo: 800
  });

  const page = await browser.newPage();

  try {
    console.log('\n📍 Navigating to SimplePractice...');
    await page.goto('https://secure.simplepractice.com/calendar/appointments', {
      waitUntil: 'domcontentloaded',  // Don't wait for networkidle
      timeout: 60000
    });

    console.log('Current URL:', page.url());

    // Handle login
    if (page.url().includes('saml') || page.url().includes('login') || page.url().includes('account.simplepractice')) {
      console.log('\n🔐 LOGIN REQUIRED');

      // Wait for email field
      await page.waitForSelector('#user_email', { timeout: 10000 });
      await page.fill('#user_email', USERNAME);
      await page.fill('#user_password', PASSWORD);
      await page.click('#submitBtn');

      console.log('✅ Credentials submitted');
      console.log('\n⏸️  PAUSING 30 SECONDS FOR MANUAL 2FA');
      console.log('   👉 Please complete 2FA in the browser window');
      await page.waitForTimeout(30000);

      console.log('\n✅ Resuming after 2FA');
      console.log('Current URL:', page.url());
    }

    // Navigate to billings if needed
    if (!page.url().includes('/billings/insurance')) {
      console.log('\n📍 STEP 2: Navigate to billings');
      await page.click('nav a[href*="/billing"], nav span:has-text("Billings")');
      await page.waitForTimeout(3000);
    }

    console.log('\n📍 STEP 3: Click filter button');
    await page.waitForSelector('button.button.utility-button-style.filtered', { timeout: 10000 });
    await page.click('button.button.utility-button-style.filtered');
    await page.waitForTimeout(2000);

    console.log('\n📍 STEP 4: Click table cell (open date picker)');
    await page.click('table tbody tr:nth-child(6) td:nth-child(4)');
    await page.waitForTimeout(3000);

    // Steps 5-7
    console.log('\n📍 STEPS 5-7: Click date picker input 3 times');
    for (let i = 0; i < 3; i++) {
      await page.click('input[name="daterangepicker_start"]');
      await page.waitForTimeout(500);
    }

    console.log('\n═══════════════════════════════════════');
    console.log('🎯 STEP 8: TESTING FILL APPROACHES');
    console.log('═══════════════════════════════════════');

    // Save HTML
    const html = await page.content();
    fs.writeFileSync('/tmp/step8-html.html', html);
    console.log('📄 Full HTML saved');

    // Find the input
    const input = page.locator('input[name="daterangepicker_start"]').first();

    console.log('\n🔍 Input Element Info:');
    console.log('  Visible:', await input.isVisible());
    console.log('  Enabled:', await input.isEnabled());
    console.log('  Readonly:', await input.getAttribute('readonly'));
    console.log('  Current value:', await input.inputValue());

    // Try different fill methods
    console.log('\n🧪 METHOD 1: Direct fill()');
    try {
      await input.fill('12/03/2025', { timeout: 10000 });
      console.log('✅ fill() worked! Value:', await input.inputValue());
    } catch (e) {
      console.log('❌ fill() failed:', e.message);

      console.log('\n🧪 METHOD 2: Click + clear + type()');
      try {
        await input.click();
        await page.keyboard.press('Control+A');
        await input.type('12/03/2025', { delay: 100 });
        console.log('✅ type() worked! Value:', await input.inputValue());
      } catch (e2) {
        console.log('❌ type() failed:', e2.message);

        console.log('\n🧪 METHOD 3: JavaScript setValue()');
        await page.evaluate(() => {
          const el = document.querySelector('input[name="daterangepicker_start"]');
          if (el) {
            el.value = '12/03/2025';
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
          }
        });
        const jsValue = await input.inputValue();
        console.log('JavaScript set value to:', jsValue);
      }
    }

    // Screenshot
    await page.screenshot({ path: '/tmp/step8-final.png', fullPage: true });
    console.log('\n📸 Screenshot saved: /tmp/step8-final.png');

    console.log('\n⏸️  Browser will stay open for 20 seconds for inspection...');
    await page.waitForTimeout(20000);

  } catch (error) {
    console.error('\n❌ ERROR:', error.message);
    await page.screenshot({ path: '/tmp/error.png', fullPage: true });
  } finally {
    await browser.close();
  }
}

debugWithManual2FA().catch(console.error);

  } catch (error) {
    console.error('❌ Automation error:', error.message);
    if (error.stack) {
      console.error(error.stack);
    }
    process.exit(1);
  }
})();
