# Visual Analysis for Web Scraping

Techniques for using screenshots and visual inspection to build intelligent scrapers.

## Screenshot-Driven Development

### The Visual-First Approach

Instead of guessing at page structure, capture what you actually see:

```typescript
import puppeteer from 'puppeteer';
import * as fs from 'fs';

async function analyzePageVisually(url: string): Promise<void> {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();

  // Set a realistic viewport
  await page.setViewport({ width: 1920, height: 1080 });

  // Configure anti-detection
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
  );

  // Navigate and wait for full render
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });

  // Capture initial state
  await page.screenshot({
    path: '/tmp/scrape-analysis-1-initial.png',
    fullPage: true,
  });
  console.log('Captured: Initial page state');

  // Wait for any lazy content
  await new Promise((r) => setTimeout(r, 2000));

  // Capture after settling
  await page.screenshot({
    path: '/tmp/scrape-analysis-2-settled.png',
    fullPage: true,
  });
  console.log('Captured: After settling');

  await browser.close();
}
```

### Multi-State Screenshot Capture

Capture the page in different states to understand dynamic behavior:

```typescript
interface AnalysisCapture {
  name: string;
  path: string;
  action?: () => Promise<void>;
}

async function capturePageStates(page: Page, captures: AnalysisCapture[]): Promise<void> {
  for (const capture of captures) {
    if (capture.action) {
      await capture.action();
      await new Promise((r) => setTimeout(r, 1000)); // Wait for state change
    }
    await page.screenshot({ path: capture.path, fullPage: true });
    console.log(`Captured: ${capture.name}`);
  }
}

// Usage
await capturePageStates(page, [
  { name: 'Initial load', path: '/tmp/state-1-initial.png' },
  {
    name: 'After scroll',
    path: '/tmp/state-2-scrolled.png',
    action: async () => {
      await page.evaluate(() => window.scrollBy(0, 1000));
    },
  },
  {
    name: 'After clicking load more',
    path: '/tmp/state-3-loaded.png',
    action: async () => {
      const btn = await page.$('.load-more, [data-action="load-more"]');
      if (btn) await btn.click();
      await page.waitForNetworkIdle();
    },
  },
  {
    name: 'Mobile viewport',
    path: '/tmp/state-4-mobile.png',
    action: async () => {
      await page.setViewport({ width: 375, height: 812 });
    },
  },
]);
```

## Visual Element Discovery

### Region-Based Element Finding

Find elements within specific visual regions:

```typescript
interface VisualRegion {
  top: number;
  bottom: number;
  left?: number;
  right?: number;
}

async function findElementsInRegion(
  page: Page,
  region: VisualRegion
): Promise<Array<{ selector: string; text: string; bounds: DOMRect }>> {
  return await page.evaluate((r) => {
    const results: Array<{ selector: string; text: string; bounds: DOMRect }> = [];

    // Get all elements
    const elements = document.querySelectorAll('*');

    elements.forEach((el) => {
      const rect = el.getBoundingClientRect();

      // Check if element is in the visual region
      if (
        rect.top >= r.top &&
        rect.bottom <= r.bottom &&
        rect.width > 0 &&
        rect.height > 0
      ) {
        // Build a selector for this element
        let selector = el.tagName.toLowerCase();
        if (el.id) selector += `#${el.id}`;
        if (el.className && typeof el.className === 'string') {
          selector += '.' + el.className.split(' ').filter(Boolean).join('.');
        }

        results.push({
          selector,
          text: el.textContent?.trim().substring(0, 100) || '',
          bounds: rect.toJSON() as DOMRect,
        });
      }
    });

    return results;
  }, region);
}

// Usage: Find elements in the main content area (typically 200-800px from top)
const contentElements = await findElementsInRegion(page, {
  top: 200,
  bottom: 800,
});
```

### Visual Pattern Recognition

Identify repeating visual patterns that indicate data items:

```typescript
interface VisualPattern {
  width: number;
  height: number;
  top: number;
  count: number;
  selector: string;
}

async function findRepeatingPatterns(page: Page): Promise<VisualPattern[]> {
  return await page.evaluate(() => {
    const patterns: Map<string, VisualPattern> = new Map();

    // Find all container-like elements
    const containers = document.querySelectorAll(
      'div, article, section, li, tr'
    );

    containers.forEach((container) => {
      const children = Array.from(container.children);
      if (children.length < 3) return; // Need at least 3 similar items

      // Check if children have similar dimensions
      const rects = children.map((c) => c.getBoundingClientRect());
      const firstRect = rects[0];

      if (firstRect.width < 50 || firstRect.height < 50) return; // Skip tiny elements

      // Check for consistent sizing
      const similarCount = rects.filter(
        (r) =>
          Math.abs(r.width - firstRect.width) < 20 &&
          Math.abs(r.height - firstRect.height) < 20
      ).length;

      if (similarCount >= 3) {
        // Build selector for the pattern
        let selector = container.tagName.toLowerCase();
        if (container.className && typeof container.className === 'string') {
          selector += '.' + container.className.split(' ')[0];
        }
        selector += ' > *';

        const key = `${Math.round(firstRect.width)}x${Math.round(firstRect.height)}`;
        if (!patterns.has(key)) {
          patterns.set(key, {
            width: firstRect.width,
            height: firstRect.height,
            top: firstRect.top,
            count: similarCount,
            selector,
          });
        }
      }
    });

    return Array.from(patterns.values()).sort((a, b) => b.count - a.count);
  });
}
```

## Screenshot-Based Verification

### Capture Extraction Results

Highlight and capture what your scraper found:

```typescript
async function visualizeExtraction(
  page: Page,
  selector: string,
  outputPath: string
): Promise<void> {
  // Add visual highlighting
  await page.evaluate((sel) => {
    document.querySelectorAll(sel).forEach((el, i) => {
      (el as HTMLElement).style.outline = '3px solid red';
      (el as HTMLElement).style.outlineOffset = '2px';

      // Add index label
      const label = document.createElement('div');
      label.textContent = String(i + 1);
      label.style.cssText = `
        position: absolute;
        background: red;
        color: white;
        padding: 2px 6px;
        font-size: 12px;
        font-weight: bold;
        z-index: 10000;
      `;
      const rect = el.getBoundingClientRect();
      label.style.top = rect.top + window.scrollY + 'px';
      label.style.left = rect.left + 'px';
      document.body.appendChild(label);
    });
  }, selector);

  // Capture with highlighting
  await page.screenshot({ path: outputPath, fullPage: true });
  console.log(`Visualized ${selector} -> ${outputPath}`);
}
```

### Before/After Comparison

Compare page states to understand changes:

```typescript
async function captureComparison(
  page: Page,
  action: () => Promise<void>,
  baseName: string
): Promise<{ before: string; after: string }> {
  const beforePath = `/tmp/${baseName}-before.png`;
  const afterPath = `/tmp/${baseName}-after.png`;

  // Capture before state
  await page.screenshot({ path: beforePath, fullPage: true });

  // Perform action
  await action();
  await page.waitForNetworkIdle();

  // Capture after state
  await page.screenshot({ path: afterPath, fullPage: true });

  return { before: beforePath, after: afterPath };
}

// Usage
const { before, after } = await captureComparison(
  page,
  async () => {
    await page.click('.load-more');
  },
  'load-more-click'
);
console.log(`Compare ${before} and ${after} to see what loaded`);
```

## Interactive Analysis Script

A complete analysis script to understand any page:

```typescript
#!/usr/bin/env npx ts-node

import puppeteer, { Page } from 'puppeteer';

const URL = process.argv[2];
if (!URL) {
  console.log('Usage: npx ts-node analyze-page.ts <url>');
  process.exit(1);
}

async function analyzePage(): Promise<void> {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();

  await page.setViewport({ width: 1920, height: 1080 });
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
  );

  console.log(`\n=== Analyzing: ${URL} ===\n`);

  // Navigate
  await page.goto(URL, { waitUntil: 'networkidle2' });

  // 1. Initial screenshot
  await page.screenshot({ path: '/tmp/analyze-1-initial.png', fullPage: true });
  console.log('1. Captured initial state -> /tmp/analyze-1-initial.png');

  // 2. Page info
  const pageInfo = await page.evaluate(() => ({
    title: document.title,
    url: window.location.href,
    bodyClasses: document.body.className,
    hasReact: !!(window as any).__REACT_DEVTOOLS_GLOBAL_HOOK__,
    hasVue: !!(window as any).__VUE__,
    hasAngular: !!(window as any).ng,
    isShopify: !!(window as any).Shopify,
  }));
  console.log('\n2. Page Info:', pageInfo);

  // 3. Find main content containers
  const containers = await page.evaluate(() => {
    const candidates = ['main', 'article', '[role="main"]', '#content', '.content'];
    const found: string[] = [];
    candidates.forEach((sel) => {
      if (document.querySelector(sel)) found.push(sel);
    });
    return found;
  });
  console.log('\n3. Content containers found:', containers);

  // 4. Find repeating patterns (likely data items)
  const patterns = await page.evaluate(() => {
    const results: Array<{ selector: string; count: number; sample: string }> = [];

    // Common data container selectors
    const selectors = [
      '[data-testid]',
      '[data-product]',
      '[data-item]',
      'article',
      '.card',
      '.product',
      '.item',
      '.result',
      '.listing',
      'li',
      'tr',
    ];

    selectors.forEach((sel) => {
      const els = document.querySelectorAll(sel);
      if (els.length >= 3) {
        results.push({
          selector: sel,
          count: els.length,
          sample: els[0].textContent?.trim().substring(0, 50) || '',
        });
      }
    });

    return results.sort((a, b) => b.count - a.count);
  });
  console.log('\n4. Repeating patterns (likely data items):');
  patterns.slice(0, 5).forEach((p) => {
    console.log(`   ${p.selector}: ${p.count} items - "${p.sample}..."`);
  });

  // 5. Scroll and capture
  await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
  await new Promise((r) => setTimeout(r, 2000));
  await page.screenshot({ path: '/tmp/analyze-2-scrolled.png', fullPage: true });
  console.log('\n5. Scrolled to bottom -> /tmp/analyze-2-scrolled.png');

  // 6. Check for infinite scroll / load more
  const loadMore = await page.evaluate(() => {
    const buttons = document.querySelectorAll(
      'button, a, [role="button"]'
    );
    const loadMoreBtns: string[] = [];
    buttons.forEach((btn) => {
      const text = btn.textContent?.toLowerCase() || '';
      if (
        text.includes('load more') ||
        text.includes('show more') ||
        text.includes('view more')
      ) {
        loadMoreBtns.push(text.trim());
      }
    });
    return loadMoreBtns;
  });
  console.log('\n6. Load more buttons found:', loadMore.length > 0 ? loadMore : 'None');

  // 7. Check for pagination
  const pagination = await page.evaluate(() => {
    const paginationSelectors = [
      '.pagination',
      '[aria-label*="pagination"]',
      'nav[role="navigation"]',
      '.pager',
    ];
    for (const sel of paginationSelectors) {
      const el = document.querySelector(sel);
      if (el) return { found: true, selector: sel };
    }
    return { found: false };
  });
  console.log('7. Pagination:', pagination);

  console.log('\n=== Analysis Complete ===');
  console.log('Screenshots saved to /tmp/analyze-*.png');
  console.log('Read these images to understand the page structure visually.\n');

  await browser.close();
}

analyzePage().catch(console.error);
```

## Visual Debugging

### Screenshot on Error

Capture the page state when something goes wrong:

```typescript
async function withScreenshotOnError<T>(
  page: Page,
  operation: () => Promise<T>,
  name: string
): Promise<T> {
  try {
    return await operation();
  } catch (error) {
    const errorPath = `/tmp/error-${name}-${Date.now()}.png`;
    await page.screenshot({ path: errorPath, fullPage: true });
    console.error(`Error during ${name}. Screenshot: ${errorPath}`);
    throw error;
  }
}

// Usage
const data = await withScreenshotOnError(
  page,
  async () => {
    await page.waitForSelector('.products', { timeout: 5000 });
    return await extractProducts(page);
  },
  'product-extraction'
);
```

### Progressive Screenshot Series

Capture a series of screenshots during complex operations:

```typescript
class ScreenshotSeries {
  private page: Page;
  private baseName: string;
  private count = 0;

  constructor(page: Page, baseName: string) {
    this.page = page;
    this.baseName = baseName;
  }

  async capture(label: string): Promise<string> {
    this.count++;
    const path = `/tmp/${this.baseName}-${this.count}-${label}.png`;
    await this.page.screenshot({ path, fullPage: true });
    console.log(`Screenshot ${this.count}: ${label} -> ${path}`);
    return path;
  }
}

// Usage
const screenshots = new ScreenshotSeries(page, 'product-scrape');
await screenshots.capture('initial');
await page.click('.category-filter');
await screenshots.capture('filter-opened');
await page.click('[data-category="electronics"]');
await page.waitForNetworkIdle();
await screenshots.capture('filtered');
```

## Integration with Claude

When Claude reads screenshot files, it can:

1. **Identify visual layout** - Header, navigation, content areas, footer
2. **Spot data patterns** - Product grids, lists, tables, cards
3. **Recognize UI elements** - Buttons, forms, pagination, filters
4. **Detect obstacles** - Popups, cookie banners, captchas
5. **Suggest selectors** - Based on visual hierarchy and structure

The screenshot-first approach ensures Claude understands exactly what it's working with before writing any extraction code.
