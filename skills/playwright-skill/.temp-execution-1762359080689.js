const { chromium } = require('playwright');

const TARGET_URL = 'http://localhost:8082/recording-playback.html';

(async () => {
  console.log('🎬 Phase 3.3 Recording Playback - Visual Test\n');
  console.log('═══════════════════════════════════════════════\n');

  const browser = await chromium.launch({
    headless: false,
    slowMo: 75,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({
    viewport: null
  });

  const page = await context.newPage();

  try {
    console.log('📡 Loading Recording Playback...');
    await page.goto(TARGET_URL, { waitUntil: 'networkidle' });
    console.log('✅ Recording Playback loaded successfully!\n');

    await page.waitForTimeout(1000);

    console.log('📸 Capturing component screenshots...\n');

    // 1. Full page screenshot
    await page.screenshot({
      path: '/tmp/recording-playback-full.png',
      fullPage: true
    });
    console.log('  ✓ Full page screenshot saved');

    // 2. VideoPlayer
    console.log('\n🎬 Testing VideoPlayer...');
    const videoContainer = page.locator('.video-container').first();
    await videoContainer.hover();
    await page.waitForTimeout(500);
    await page.screenshot({
      path: '/tmp/component-video-player.png',
      clip: { x: 0, y: 180, width: 1400, height: 650 }
    });
    console.log('  ✓ VideoPlayer with controls visible');

    // Test play button
    const playButton = page.locator('.play-button');
    await playButton.click();
    await page.waitForTimeout(300);
    console.log('  ✓ Play button clicked');

    await page.screenshot({
      path: '/tmp/component-video-playing.png',
      clip: { x: 0, y: 180, width: 1400, height: 650 }
    });
    console.log('  ✓ Video playing state captured');

    // Test speed selector
    await page.click('button[onclick="toggleSpeedSelector()"]');
    await page.waitForTimeout(300);
    await page.screenshot({
      path: '/tmp/component-speed-selector.png',
      clip: { x: 0, y: 180, width: 1400, height: 650 }
    });
    console.log('  ✓ Speed selector menu captured');

    // 3. ScreenshotCarousel
    console.log('\n📸 Testing ScreenshotCarousel...');
    const carousel = page.locator('.carousel-track');
    await carousel.scrollIntoViewIfNeeded();
    await page.waitForTimeout(500);
    await page.screenshot({
      path: '/tmp/component-screenshot-carousel.png',
      clip: { x: 0, y: 900, width: 1400, height: 500 }
    });
    console.log('  ✓ Screenshot carousel captured');

    // Test frame selection
    const thumbnails = page.locator('.screenshot-thumbnail');
    await thumbnails.nth(5).click();
    await page.waitForTimeout(500);
    await page.screenshot({
      path: '/tmp/component-frame-selected.png',
      clip: { x: 0, y: 900, width: 1400, height: 500 }
    });
    console.log('  ✓ Frame selection captured');

    // 4. ActionOverlay
    console.log('\n🎯 Testing ActionOverlay...');
    await page.screenshot({
      path: '/tmp/component-action-overlay.png',
      clip: { x: 0, y: 850, width: 1400, height: 450 }
    });
    console.log('  ✓ Action overlay with highlight captured');

    // 5. Keyboard shortcuts
    console.log('\n⌨️  Testing keyboard shortcuts...');
    await page.keyboard.press('Space');
    await page.waitForTimeout(300);
    console.log('  ✓ Space (play/pause) tested');

    await page.keyboard.press('ArrowRight');
    await page.waitForTimeout(300);
    console.log('  ✓ Arrow Right (next frame) tested');

    await page.keyboard.press('ArrowLeft');
    await page.waitForTimeout(300);
    console.log('  ✓ Arrow Left (previous frame) tested');

    // 6. Responsive views
    console.log('\n📱 Testing responsive views...');

    // Desktop
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.waitForTimeout(500);
    await page.screenshot({
      path: '/tmp/recording-desktop.png',
      fullPage: true
    });
    console.log('  ✓ Desktop view (1920x1080)');

    // Tablet
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.waitForTimeout(500);
    await page.screenshot({
      path: '/tmp/recording-tablet.png',
      fullPage: true
    });
    console.log('  ✓ Tablet view (768x1024)');

    // Mobile
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(500);
    await page.screenshot({
      path: '/tmp/recording-mobile.png',
      fullPage: true
    });
    console.log('  ✓ Mobile view (375x667)');

    // Reset to desktop
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto(TARGET_URL);
    await page.waitForTimeout(1000);

    console.log('\n✨ Visual Testing Complete!\n');
    console.log('📂 Screenshots saved to /tmp/:');
    console.log('   • recording-playback-full.png');
    console.log('   • component-video-player.png');
    console.log('   • component-video-playing.png');
    console.log('   • component-speed-selector.png');
    console.log('   • component-screenshot-carousel.png');
    console.log('   • component-frame-selected.png');
    console.log('   • component-action-overlay.png');
    console.log('   • recording-desktop.png');
    console.log('   • recording-tablet.png');
    console.log('   • recording-mobile.png\n');

    console.log('🔍 Browser will remain open for 30 seconds for manual inspection...\n');

    await page.waitForTimeout(30000);

  } catch (error) {
    console.error('❌ Error:', error.message);
    await page.screenshot({ path: '/tmp/error-recording.png' });
  } finally {
    await browser.close();
    console.log('\n👋 Test complete!');
  }
})();
