#!/usr/bin/env node

/**
 * Export carousel HTML slides to individual 1080x1350 PNG images.
 * Usage: node export-carousel.js <path-to-carousel.html> [output-dir]
 *
 * Requires: npx playwright install chromium (one-time setup)
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function exportCarousel(htmlPath, outputDir) {
  const resolvedPath = path.resolve(htmlPath);
  if (!fs.existsSync(resolvedPath)) {
    console.error(`File not found: ${resolvedPath}`);
    process.exit(1);
  }

  outputDir = outputDir || path.join(path.dirname(resolvedPath), 'carousel-export');
  fs.mkdirSync(outputDir, { recursive: true });

  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.setViewportSize({ width: 1080, height: 1350 });
  await page.goto(`file://${resolvedPath}`, { waitUntil: 'networkidle' });

  // Wait for fonts to load
  await page.waitForTimeout(2000);

  const slideCount = await page.evaluate(() => {
    return document.querySelectorAll('.slide').length;
  });

  console.log(`Found ${slideCount} slides. Exporting...`);

  for (let i = 0; i < slideCount; i++) {
    const slideSelector = `[data-slide="${i + 1}"]`;
    const slide = await page.$(slideSelector);

    if (!slide) {
      console.warn(`Slide ${i + 1} not found with selector ${slideSelector}`);
      continue;
    }

    const filename = `slide-${String(i + 1).padStart(2, '0')}.png`;
    const filepath = path.join(outputDir, filename);

    await slide.screenshot({
      path: filepath,
      type: 'png',
    });

    console.log(`  Exported: ${filename}`);
  }

  await browser.close();
  console.log(`\nDone! ${slideCount} slides exported to: ${outputDir}`);
}

const args = process.argv.slice(2);
if (args.length < 1) {
  console.log('Usage: node export-carousel.js <carousel.html> [output-dir]');
  console.log('Example: node export-carousel.js ./carousel-template.html ./my-carousel');
  process.exit(0);
}

exportCarousel(args[0], args[1]);
