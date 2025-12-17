---
name: Puppeteer Web Scraping
description: This skill should be used when the user asks to "scrape a website", "extract data from a page", "build a web scraper", "create a puppeteer script", "automate browser", "get data from URL", mentions "selectors", "dynamic content", "JavaScript-rendered pages", or needs help with anti-detection, page navigation, or data extraction patterns.
version: 0.1.0
---

# Puppeteer Web Scraping

Comprehensive guidance for building robust, AI-powered web scrapers using TypeScript and Puppeteer. This skill enables creation of scrapers that handle dynamic content, evade detection, and reliably extract structured data.

## Core Concepts

### TypeScript Scraper Structure

Every scraper follows this standard structure:

```typescript
import puppeteer, { Browser, Page } from 'puppeteer';

interface ScrapedData {
  // Define expected output structure
}

async function scrape(url: string): Promise<ScrapedData[]> {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  try {
    const page = await browser.newPage();
    await configurePage(page);
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });

    const data = await extractData(page);
    return data;
  } finally {
    await browser.close();
  }
}
```

### Selector Strategies

Use resilient selectors that survive page changes:

| Strategy | Priority | Example | Use When |
|----------|----------|---------|----------|
| data-* attributes | 1st | `[data-testid="price"]` | Available (most stable) |
| Semantic HTML | 2nd | `article h2`, `main nav` | Clear structure exists |
| ARIA labels | 3rd | `[aria-label="Add to cart"]` | Interactive elements |
| Class combinations | 4th | `.product-card .title` | No better option |
| XPath text match | Last | `//button[contains(text(), "Buy")]` | Dynamic class names |

**Dynamic selector generation:**
```typescript
async function findBestSelector(page: Page, targetText: string): Promise<string> {
  // Try data attributes first
  const dataSelector = await page.$(`[data-testid*="${targetText.toLowerCase()}"]`);
  if (dataSelector) return `[data-testid*="${targetText.toLowerCase()}"]`;

  // Fall back to text content matching
  const elements = await page.$$('*');
  for (const el of elements) {
    const text = await el.evaluate(e => e.textContent?.trim());
    if (text?.includes(targetText)) {
      const tagName = await el.evaluate(e => e.tagName.toLowerCase());
      return `${tagName}:has-text("${targetText}")`;
    }
  }
  throw new Error(`No selector found for: ${targetText}`);
}
```

### Anti-Detection Techniques

Configure browser to appear human-like:

```typescript
async function configurePage(page: Page): Promise<void> {
  // Realistic viewport
  await page.setViewport({ width: 1920, height: 1080 });

  // User agent rotation
  const userAgents = [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36...',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...'
  ];
  await page.setUserAgent(userAgents[Math.floor(Math.random() * userAgents.length)]);

  // Disable webdriver flag
  await page.evaluateOnNewDocument(() => {
    Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
  });

  // Add realistic headers
  await page.setExtraHTTPHeaders({
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br'
  });
}
```

### Waiting Strategies

Handle dynamic content loading:

```typescript
// Wait for specific element
await page.waitForSelector('.products-loaded', { timeout: 10000 });

// Wait for network idle
await page.waitForNetworkIdle({ idleTime: 500, timeout: 30000 });

// Wait for function to return true
await page.waitForFunction(() => {
  const items = document.querySelectorAll('.product');
  return items.length > 0;
}, { timeout: 15000 });

// Custom polling wait
async function waitForCondition(page: Page, check: () => Promise<boolean>): Promise<void> {
  const maxAttempts = 20;
  for (let i = 0; i < maxAttempts; i++) {
    if (await check()) return;
    await new Promise(r => setTimeout(r, 500));
  }
  throw new Error('Condition not met');
}
```

### Pagination Handling

Navigate through paginated content:

```typescript
async function scrapeAllPages(page: Page): Promise<ScrapedData[]> {
  const allData: ScrapedData[] = [];

  while (true) {
    // Extract current page
    const pageData = await extractData(page);
    allData.push(...pageData);

    // Check for next button
    const nextButton = await page.$('a[rel="next"], .pagination .next:not(.disabled)');
    if (!nextButton) break;

    // Click and wait for navigation
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle2' }),
      nextButton.click()
    ]);

    // Rate limiting
    await new Promise(r => setTimeout(r, 1000 + Math.random() * 2000));
  }

  return allData;
}
```

### Infinite Scroll Handling

Load all content from infinite scroll pages:

```typescript
async function scrollToBottom(page: Page): Promise<void> {
  let previousHeight = 0;
  let attempts = 0;
  const maxAttempts = 50;

  while (attempts < maxAttempts) {
    const currentHeight = await page.evaluate(() => document.body.scrollHeight);

    if (currentHeight === previousHeight) {
      attempts++;
      if (attempts >= 3) break; // No new content after 3 attempts
    } else {
      attempts = 0;
    }

    previousHeight = currentHeight;
    await page.evaluate(() => window.scrollTo(0, document.body.scrollHeight));
    await new Promise(r => setTimeout(r, 1500));
  }
}
```

## Workflow

To build a scraper for a target site:

1. **Analyze the page structure** - Identify data containers, selectors, and loading patterns
2. **Determine content type** - Static HTML, JavaScript-rendered, paginated, or infinite scroll
3. **Choose selector strategy** - Prefer stable attributes over class names
4. **Implement extraction** - Use page.evaluate() for data extraction
5. **Add error handling** - Retry logic, timeout handling, validation
6. **Configure anti-detection** - User agents, delays, realistic behavior
7. **Test incrementally** - Verify each step before proceeding

## Data Extraction Patterns

Extract structured data using page.evaluate():

```typescript
async function extractData(page: Page): Promise<ScrapedData[]> {
  return await page.evaluate(() => {
    const items = document.querySelectorAll('.product-card');
    return Array.from(items).map(item => ({
      title: item.querySelector('h2')?.textContent?.trim() || '',
      price: parseFloat(item.querySelector('.price')?.textContent?.replace(/[^0-9.]/g, '') || '0'),
      url: (item.querySelector('a') as HTMLAnchorElement)?.href || '',
      image: (item.querySelector('img') as HTMLImageElement)?.src || ''
    }));
  });
}
```

## Error Handling

Implement robust retry logic:

```typescript
async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  delayMs = 2000
): Promise<T> {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries) throw error;
      console.log(`Attempt ${attempt} failed, retrying in ${delayMs}ms...`);
      await new Promise(r => setTimeout(r, delayMs * attempt));
    }
  }
  throw new Error('Max retries exceeded');
}
```

## Additional Resources

### Reference Files

For detailed patterns and advanced techniques:
- **`references/visual-analysis.md`** - Screenshot-driven page analysis and selector discovery
- **`references/anti-detection.md`** - Comprehensive anti-bot evasion techniques
- **`references/selector-patterns.md`** - Advanced selector strategies for common sites

### Example Files

Working examples in `examples/`:
- **`basic-scraper.ts`** - Minimal working scraper template with visual analysis hooks
