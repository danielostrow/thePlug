/**
 * Basic Web Scraper Template
 *
 * A minimal, working Puppeteer scraper that demonstrates core patterns:
 * - Browser configuration with anti-detection
 * - Page navigation and waiting
 * - Data extraction with selectors
 * - Error handling and cleanup
 *
 * Usage:
 *   npx ts-node basic-scraper.ts https://example.com
 */

import puppeteer, { Browser, Page } from 'puppeteer';

// Define the structure of scraped data
interface ScrapedItem {
  title: string;
  description: string;
  url: string;
  timestamp: string;
}

// Configuration
const CONFIG = {
  timeout: 30000,
  userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  viewport: { width: 1920, height: 1080 },
};

/**
 * Configure page with anti-detection measures
 */
async function configurePage(page: Page): Promise<void> {
  await page.setViewport(CONFIG.viewport);
  await page.setUserAgent(CONFIG.userAgent);

  // Remove webdriver flag
  await page.evaluateOnNewDocument(() => {
    Object.defineProperty(navigator, 'webdriver', {
      get: () => undefined,
    });
  });

  // Set realistic headers
  await page.setExtraHTTPHeaders({
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
  });
}

/**
 * Extract data from the page
 * Customize this function for your target site
 */
async function extractData(page: Page): Promise<ScrapedItem[]> {
  return await page.evaluate(() => {
    // Customize selectors for your target site
    const items = document.querySelectorAll('article, .item, [data-item]');

    return Array.from(items).map(item => ({
      title: item.querySelector('h1, h2, h3, .title')?.textContent?.trim() || '',
      description: item.querySelector('p, .description, .summary')?.textContent?.trim() || '',
      url: (item.querySelector('a') as HTMLAnchorElement)?.href || window.location.href,
      timestamp: new Date().toISOString(),
    }));
  });
}

/**
 * Main scraping function
 */
async function scrape(url: string): Promise<ScrapedItem[]> {
  let browser: Browser | null = null;

  try {
    console.log(`Starting scrape of: ${url}`);

    // Launch browser
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox'],
    });

    const page = await browser.newPage();
    await configurePage(page);

    // Navigate to target
    console.log('Navigating to page...');
    await page.goto(url, {
      waitUntil: 'networkidle2',
      timeout: CONFIG.timeout,
    });

    // Wait for content to load
    // Customize selector for your target site
    await page.waitForSelector('body', { timeout: CONFIG.timeout });

    // Extract data
    console.log('Extracting data...');
    const data = await extractData(page);

    console.log(`Extracted ${data.length} items`);
    return data;

  } catch (error) {
    console.error('Scraping failed:', error);
    throw error;

  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

/**
 * Entry point
 */
async function main(): Promise<void> {
  const url = process.argv[2];

  if (!url) {
    console.log('Usage: npx ts-node basic-scraper.ts <url>');
    process.exit(1);
  }

  try {
    const data = await scrape(url);
    console.log('\nScraped Data:');
    console.log(JSON.stringify(data, null, 2));

  } catch (error) {
    console.error('Failed:', error);
    process.exit(1);
  }
}

main();
