# Anti-Detection Techniques

Comprehensive strategies for avoiding bot detection when scraping.

## Browser Fingerprint Masking

### WebDriver Detection

Most sites check for the `navigator.webdriver` property:

```typescript
await page.evaluateOnNewDocument(() => {
  // Remove webdriver property
  Object.defineProperty(navigator, 'webdriver', {
    get: () => undefined,
  });

  // Mock chrome runtime
  (window as any).chrome = {
    runtime: {},
  };

  // Mock permissions
  const originalQuery = window.navigator.permissions.query;
  window.navigator.permissions.query = (parameters: any) =>
    parameters.name === 'notifications'
      ? Promise.resolve({ state: Notification.permission } as PermissionStatus)
      : originalQuery(parameters);

  // Mock plugins
  Object.defineProperty(navigator, 'plugins', {
    get: () => [1, 2, 3, 4, 5],
  });

  // Mock languages
  Object.defineProperty(navigator, 'languages', {
    get: () => ['en-US', 'en'],
  });
});
```

### Canvas Fingerprint Noise

Add subtle noise to canvas fingerprinting:

```typescript
await page.evaluateOnNewDocument(() => {
  const originalGetContext = HTMLCanvasElement.prototype.getContext;
  HTMLCanvasElement.prototype.getContext = function(type: string, attributes?: any) {
    const context = originalGetContext.call(this, type, attributes);
    if (type === '2d' && context) {
      const originalFillText = (context as CanvasRenderingContext2D).fillText;
      (context as CanvasRenderingContext2D).fillText = function(...args) {
        // Add imperceptible noise
        args[1] += Math.random() * 0.01;
        args[2] += Math.random() * 0.01;
        return originalFillText.apply(this, args as any);
      };
    }
    return context;
  };
});
```

## User Agent Management

### Rotation Strategy

```typescript
const USER_AGENTS = {
  chrome_mac: [
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
  ],
  chrome_windows: [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
  ],
  firefox: [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0',
  ]
};

function getRandomUserAgent(): string {
  const allAgents = Object.values(USER_AGENTS).flat();
  return allAgents[Math.floor(Math.random() * allAgents.length)];
}
```

### Matching Headers to User Agent

```typescript
function getHeadersForUserAgent(ua: string): Record<string, string> {
  const isChrome = ua.includes('Chrome');
  const isFirefox = ua.includes('Firefox');

  const headers: Record<string, string> = {
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
  };

  if (isChrome) {
    headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8';
    headers['sec-ch-ua'] = '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"';
    headers['sec-ch-ua-mobile'] = '?0';
    headers['sec-ch-ua-platform'] = ua.includes('Mac') ? '"macOS"' : '"Windows"';
    headers['sec-fetch-dest'] = 'document';
    headers['sec-fetch-mode'] = 'navigate';
    headers['sec-fetch-site'] = 'none';
    headers['sec-fetch-user'] = '?1';
  } else if (isFirefox) {
    headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
  }

  return headers;
}
```

## Request Timing

### Human-like Delays

```typescript
function humanDelay(minMs: number = 500, maxMs: number = 3000): Promise<void> {
  // Normal distribution around the middle
  const mean = (minMs + maxMs) / 2;
  const stdDev = (maxMs - minMs) / 6;

  // Box-Muller transform for normal distribution
  const u1 = Math.random();
  const u2 = Math.random();
  const z = Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);

  const delay = Math.max(minMs, Math.min(maxMs, mean + z * stdDev));
  return new Promise(r => setTimeout(r, delay));
}

// Usage between actions
await humanDelay(1000, 3000);
```

### Session Timing Patterns

```typescript
class SessionManager {
  private requestCount = 0;
  private sessionStart = Date.now();

  async beforeRequest(): Promise<void> {
    this.requestCount++;

    // Take longer breaks periodically
    if (this.requestCount % 10 === 0) {
      await humanDelay(5000, 15000); // Longer break every 10 requests
    } else if (this.requestCount % 50 === 0) {
      await humanDelay(30000, 60000); // Very long break every 50 requests
    } else {
      await humanDelay(1000, 3000);
    }

    // Reset session after 30 minutes
    if (Date.now() - this.sessionStart > 30 * 60 * 1000) {
      this.sessionStart = Date.now();
      this.requestCount = 0;
      await humanDelay(60000, 120000); // Session break
    }
  }
}
```

## Mouse and Keyboard Simulation

### Realistic Mouse Movement

```typescript
async function humanMove(page: Page, x: number, y: number): Promise<void> {
  const steps = 10 + Math.floor(Math.random() * 10);

  const currentPosition = await page.evaluate(() => ({
    x: (window as any).__mouseX || 0,
    y: (window as any).__mouseY || 0
  }));

  for (let i = 0; i <= steps; i++) {
    const progress = i / steps;
    // Ease-out curve for natural movement
    const eased = 1 - Math.pow(1 - progress, 3);

    const currentX = currentPosition.x + (x - currentPosition.x) * eased;
    const currentY = currentPosition.y + (y - currentPosition.y) * eased;

    // Add slight randomness
    const noiseX = (Math.random() - 0.5) * 3;
    const noiseY = (Math.random() - 0.5) * 3;

    await page.mouse.move(currentX + noiseX, currentY + noiseY);
    await new Promise(r => setTimeout(r, 10 + Math.random() * 20));
  }
}

async function humanClick(page: Page, selector: string): Promise<void> {
  const element = await page.$(selector);
  if (!element) throw new Error(`Element not found: ${selector}`);

  const box = await element.boundingBox();
  if (!box) throw new Error(`Element not visible: ${selector}`);

  // Click at random position within element
  const x = box.x + box.width * (0.3 + Math.random() * 0.4);
  const y = box.y + box.height * (0.3 + Math.random() * 0.4);

  await humanMove(page, x, y);
  await humanDelay(50, 150);
  await page.mouse.click(x, y);
}
```

### Realistic Typing

```typescript
async function humanType(page: Page, selector: string, text: string): Promise<void> {
  await humanClick(page, selector);
  await humanDelay(100, 300);

  for (const char of text) {
    await page.keyboard.type(char, { delay: 50 + Math.random() * 100 });

    // Occasional longer pause (thinking)
    if (Math.random() < 0.1) {
      await humanDelay(200, 500);
    }
  }
}
```

## Proxy Rotation

### Residential Proxy Integration

```typescript
interface ProxyConfig {
  host: string;
  port: number;
  username?: string;
  password?: string;
}

async function launchWithProxy(proxy: ProxyConfig): Promise<Browser> {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: [
      `--proxy-server=${proxy.host}:${proxy.port}`,
      '--no-sandbox',
      '--disable-setuid-sandbox'
    ]
  });

  if (proxy.username && proxy.password) {
    const page = await browser.newPage();
    await page.authenticate({
      username: proxy.username,
      password: proxy.password
    });
  }

  return browser;
}
```

### Proxy Pool Manager

```typescript
class ProxyPool {
  private proxies: ProxyConfig[];
  private currentIndex = 0;
  private failedProxies = new Set<string>();

  constructor(proxies: ProxyConfig[]) {
    this.proxies = proxies;
  }

  getNext(): ProxyConfig {
    let attempts = 0;
    while (attempts < this.proxies.length) {
      const proxy = this.proxies[this.currentIndex];
      this.currentIndex = (this.currentIndex + 1) % this.proxies.length;

      const proxyKey = `${proxy.host}:${proxy.port}`;
      if (!this.failedProxies.has(proxyKey)) {
        return proxy;
      }
      attempts++;
    }
    throw new Error('All proxies failed');
  }

  markFailed(proxy: ProxyConfig): void {
    this.failedProxies.add(`${proxy.host}:${proxy.port}`);
  }

  reset(): void {
    this.failedProxies.clear();
  }
}
```

## Detection Response

### Handling Blocks

```typescript
async function handleBlock(page: Page): Promise<boolean> {
  const blocked = await page.evaluate(() => {
    const bodyText = document.body.innerText.toLowerCase();
    return (
      bodyText.includes('access denied') ||
      bodyText.includes('blocked') ||
      bodyText.includes('captcha') ||
      bodyText.includes('robot') ||
      document.querySelector('iframe[src*="captcha"]') !== null
    );
  });

  if (blocked) {
    console.log('Block detected, implementing countermeasures...');
    return true;
  }
  return false;
}
```

### Graceful Degradation

```typescript
async function scrapeWithFallback(url: string): Promise<ScrapedData | null> {
  // Try headless first (faster)
  try {
    return await scrapeHeadless(url);
  } catch (e) {
    console.log('Headless blocked, trying headed mode...');
  }

  // Fall back to headed with proxy
  try {
    return await scrapeHeadedWithProxy(url);
  } catch (e) {
    console.log('Proxy blocked, trying different region...');
  }

  // Last resort: manual intervention flag
  return null;
}
```
