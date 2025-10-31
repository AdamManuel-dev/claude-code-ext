const { chromium } = require('playwright');
const http = require('http');

const TARGET_URL = 'http://localhost:6006';

const VIEWPORTS = [
  { name: 'Mobile (375px)', width: 375, height: 667 },
  { name: 'Tablet (768px)', width: 768, height: 1024 },
  { name: 'Desktop (1920px)', width: 1920, height: 1080 }
];

async function fetchJSON(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function testStory(browser, storyId, displayName) {
  let isResponsive = true;
  const issues = [];

  for (const viewport of VIEWPORTS) {
    try {
      const page = await browser.newPage();
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height
      });

      const storyUrl = `${TARGET_URL}/iframe.html?id=${storyId}&viewMode=story`;

      await page.goto(storyUrl, {
        waitUntil: 'networkidle',
        timeout: 25000
      });

      await page.waitForTimeout(1000);

      const pageIssues = await page.evaluate((vWidth) => {
        const probs = [];

        const docScrollWidth = Math.max(
          document.documentElement.scrollWidth,
          document.body.scrollWidth
        );

        if (docScrollWidth > vWidth + 5) {
          probs.push('overflow');
        }

        if (document.body.scrollWidth > vWidth + 5) {
          probs.push('body-overflow');
        }

        return probs;
      }, viewport.width);

      if (pageIssues.length > 0) {
        isResponsive = false;
        issues.push(`${viewport.name}: ${pageIssues.join(', ')}`);
      }

      await page.close();
    } catch (error) {
      isResponsive = false;
      issues.push(`${viewport.name}: Load error`);
    }
  }

  return { isResponsive, issues };
}

(async () => {
  const browser = await chromium.launch({ headless: false });

  try {
    console.log('🔍 Fetching Storybook index...\n');

    const storyIndex = await fetchJSON(`${TARGET_URL}/index.json`);
    const allStories = Object.values(storyIndex.entries)
      .filter(entry => entry.type === 'story')
      .map(entry => ({
        id: entry.id,
        title: entry.title,
        name: entry.name
      }));

    // Filter for ActivityFeed and AgentActivityCenter stories only
    const testStories = allStories.filter(
      s => s.title.includes('ActivityFeed') || s.title.includes('AgentActivityCenter')
    );

    console.log(`Testing ${testStories.length} fixed component stories...\n`);
    console.log('='.repeat(90) + '\n');

    let responsive = 0;
    let notResponsive = 0;
    const issues = [];

    for (const story of testStories) {
      const displayName = `${story.title} > ${story.name}`;
      const shortName = displayName.length > 70 ? displayName.substring(0, 67) + '...' : displayName;

      process.stdout.write(`${shortName.padEnd(70)} `);

      const { isResponsive: isResp, issues: storyIssues } = await testStory(browser, story.id, displayName);

      if (isResp) {
        console.log('✅');
        responsive++;
      } else {
        console.log('❌');
        notResponsive++;
        issues.push({ name: displayName, issues: storyIssues });
      }
    }

    console.log('\n' + '='.repeat(90));
    console.log(`\n📊 RESULTS:\n`);
    console.log(`✅ Responsive: ${responsive}/${testStories.length}`);
    console.log(`❌ Not Responsive: ${notResponsive}/${testStories.length}`);

    if (issues.length > 0) {
      console.log('\nIssues found:');
      issues.forEach(item => {
        console.log(`  • ${item.name}`);
        item.issues.forEach(issue => console.log(`    - ${issue}`));
      });
    } else {
      console.log('\n✨ All fixed components are now responsive!');
    }

    console.log('\n' + '='.repeat(90));

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await browser.close();
  }
})();
