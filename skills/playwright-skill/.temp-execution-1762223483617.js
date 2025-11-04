const { chromium } = require('playwright');

const TARGET_URL = 'http://localhost:5173/';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  const all404s = [];

  page.on('response', async response => {
    if (response.status() === 404) {
      const url = response.url();
      console.log(`🔍 404 NOT FOUND: ${url}`);
      all404s.push(url);
    }
  });

  try {
    await page.goto(TARGET_URL, {
      waitUntil: 'networkidle',
      timeout: 30000
    });

    await page.waitForTimeout(2000);

    console.log(`\n📋 Total 404 errors: ${all404s.length}`);
    if (all404s.length > 0) {
      console.log('\nAll 404 URLs:');
      all404s.forEach((url, i) => {
        console.log(`${i + 1}. ${url}`);
      });
    }

    await page.waitForTimeout(3000);
  } catch (error) {
    console.error(`Error: ${error.message}`);
  } finally {
    await browser.close();
  }
})();
