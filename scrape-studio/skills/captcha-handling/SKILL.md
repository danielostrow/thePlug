---
name: Captcha Handling
description: This skill should be used when the user mentions "captcha", "blocked", "bot detection", "access denied", "challenge page", "reCAPTCHA", "hCaptcha", "Cloudflare", or asks how to handle captchas, bypass bot detection, or implement manual fallback for blocked requests.
version: 0.1.0
---

# Captcha Handling

Strategies for detecting, handling, and working around captchas when web scraping. This skill focuses on built-in heuristics for detection and graceful fallback mechanisms rather than automated solving services.

## Detection Strategies

### Common Captcha Indicators

Detect captchas by checking page content and structure:

```typescript
interface CaptchaDetection {
  detected: boolean;
  type: 'recaptcha' | 'hcaptcha' | 'cloudflare' | 'custom' | 'none';
  confidence: number;
  element?: string;
}

async function detectCaptcha(page: Page): Promise<CaptchaDetection> {
  return await page.evaluate(() => {
    const detection: CaptchaDetection = {
      detected: false,
      type: 'none',
      confidence: 0
    };

    // Check for reCAPTCHA
    if (
      document.querySelector('iframe[src*="recaptcha"]') ||
      document.querySelector('.g-recaptcha') ||
      document.querySelector('[data-sitekey]')
    ) {
      return { detected: true, type: 'recaptcha', confidence: 0.95, element: 'iframe[src*="recaptcha"]' };
    }

    // Check for hCaptcha
    if (
      document.querySelector('iframe[src*="hcaptcha"]') ||
      document.querySelector('.h-captcha')
    ) {
      return { detected: true, type: 'hcaptcha', confidence: 0.95, element: 'iframe[src*="hcaptcha"]' };
    }

    // Check for Cloudflare challenge
    if (
      document.querySelector('#challenge-form') ||
      document.querySelector('.cf-browser-verification') ||
      document.title.includes('Just a moment')
    ) {
      return { detected: true, type: 'cloudflare', confidence: 0.9, element: '#challenge-form' };
    }

    // Check for generic challenge indicators
    const bodyText = document.body.innerText.toLowerCase();
    const challengeKeywords = ['captcha', 'verify you are human', 'are you a robot', 'security check'];

    for (const keyword of challengeKeywords) {
      if (bodyText.includes(keyword)) {
        return { detected: true, type: 'custom', confidence: 0.7 };
      }
    }

    return detection;
  });
}
```

### Block Detection

Identify when access is blocked without captcha:

```typescript
interface BlockDetection {
  blocked: boolean;
  reason: string;
  statusCode?: number;
  retryAfter?: number;
}

async function detectBlock(page: Page, response: HTTPResponse | null): Promise<BlockDetection> {
  // Check HTTP status
  if (response) {
    const status = response.status();

    if (status === 403) {
      return { blocked: true, reason: 'Forbidden (403)', statusCode: status };
    }

    if (status === 429) {
      const retryAfter = parseInt(response.headers()['retry-after'] || '60');
      return { blocked: true, reason: 'Rate limited (429)', statusCode: status, retryAfter };
    }

    if (status === 503) {
      return { blocked: true, reason: 'Service unavailable (503)', statusCode: status };
    }
  }

  // Check page content
  const pageBlock = await page.evaluate(() => {
    const bodyText = document.body.innerText.toLowerCase();

    const blockPhrases = [
      'access denied',
      'ip has been blocked',
      'too many requests',
      'temporarily banned',
      'please try again later',
      'suspicious activity'
    ];

    for (const phrase of blockPhrases) {
      if (bodyText.includes(phrase)) {
        return { blocked: true, reason: phrase };
      }
    }

    return { blocked: false, reason: '' };
  });

  return pageBlock;
}
```

## Handling Strategies

### Cloudflare Bypass

Wait for Cloudflare's JavaScript challenge to complete:

```typescript
async function waitForCloudflare(page: Page, maxWaitMs = 15000): Promise<boolean> {
  const startTime = Date.now();

  while (Date.now() - startTime < maxWaitMs) {
    const title = await page.title();

    // Cloudflare challenge shows "Just a moment..."
    if (!title.includes('Just a moment')) {
      // Wait a bit more for page to fully load
      await new Promise(r => setTimeout(r, 2000));
      return true;
    }

    await new Promise(r => setTimeout(r, 500));
  }

  return false;
}
```

### Manual Intervention Flow

Implement pause-and-wait for manual captcha solving:

```typescript
interface ManualInterventionResult {
  resolved: boolean;
  timeoutMs: number;
}

async function requestManualIntervention(
  page: Page,
  captchaType: string,
  timeoutMs = 120000
): Promise<ManualInterventionResult> {
  console.log('\n========================================');
  console.log(`CAPTCHA DETECTED: ${captchaType}`);
  console.log('Manual intervention required.');
  console.log('Please solve the captcha in the browser window.');
  console.log(`Timeout: ${timeoutMs / 1000} seconds`);
  console.log('========================================\n');

  // Switch to headed mode if not already
  // This requires browser restart with headless: false

  const startTime = Date.now();

  // Poll for captcha resolution
  while (Date.now() - startTime < timeoutMs) {
    const stillPresent = await detectCaptcha(page);

    if (!stillPresent.detected) {
      console.log('Captcha resolved! Continuing...');
      return { resolved: true, timeoutMs: Date.now() - startTime };
    }

    await new Promise(r => setTimeout(r, 1000));
  }

  console.log('Timeout waiting for manual intervention.');
  return { resolved: false, timeoutMs };
}
```

### Retry with Backoff

Implement exponential backoff for rate limits:

```typescript
interface RetryConfig {
  maxRetries: number;
  baseDelayMs: number;
  maxDelayMs: number;
  jitterMs: number;
}

const DEFAULT_RETRY_CONFIG: RetryConfig = {
  maxRetries: 5,
  baseDelayMs: 2000,
  maxDelayMs: 60000,
  jitterMs: 1000
};

async function withRetryBackoff<T>(
  fn: () => Promise<T>,
  config: RetryConfig = DEFAULT_RETRY_CONFIG
): Promise<T> {
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < config.maxRetries; attempt++) {
    try {
      return await fn();

    } catch (error: any) {
      lastError = error;

      // Check if retryable
      if (error.message?.includes('Navigation timeout') ||
          error.message?.includes('429') ||
          error.message?.includes('rate limit')) {

        const delay = Math.min(
          config.baseDelayMs * Math.pow(2, attempt),
          config.maxDelayMs
        );
        const jitter = Math.random() * config.jitterMs;

        console.log(`Attempt ${attempt + 1} failed. Retrying in ${Math.round(delay + jitter)}ms...`);
        await new Promise(r => setTimeout(r, delay + jitter));

      } else {
        // Non-retryable error
        throw error;
      }
    }
  }

  throw lastError || new Error('Max retries exceeded');
}
```

## Prevention Strategies

### Pre-emptive Measures

Reduce captcha triggers before they happen:

```typescript
async function configureForCaptchaPrevention(page: Page): Promise<void> {
  // Set realistic browser fingerprint
  await page.evaluateOnNewDocument(() => {
    // Realistic screen properties
    Object.defineProperty(screen, 'width', { get: () => 1920 });
    Object.defineProperty(screen, 'height', { get: () => 1080 });
    Object.defineProperty(screen, 'availWidth', { get: () => 1920 });
    Object.defineProperty(screen, 'availHeight', { get: () => 1040 });
    Object.defineProperty(screen, 'colorDepth', { get: () => 24 });
    Object.defineProperty(screen, 'pixelDepth', { get: () => 24 });

    // Realistic hardware concurrency
    Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });

    // Realistic memory
    Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });

    // Platform consistency
    Object.defineProperty(navigator, 'platform', { get: () => 'MacIntel' });
  });

  // Cookie acceptance for returning visitor appearance
  await page.setCookie({
    name: '_session',
    value: 'returning_visitor',
    domain: new URL(page.url()).hostname,
  });
}
```

### Session Rotation

Rotate sessions to avoid detection patterns:

```typescript
class SessionRotator {
  private sessionCount = 0;
  private maxRequestsPerSession = 20 + Math.floor(Math.random() * 10);

  async shouldRotate(): Promise<boolean> {
    this.sessionCount++;

    if (this.sessionCount >= this.maxRequestsPerSession) {
      this.sessionCount = 0;
      this.maxRequestsPerSession = 20 + Math.floor(Math.random() * 10);
      return true;
    }

    return false;
  }

  async rotateBrowser(browser: Browser): Promise<Browser> {
    await browser.close();

    // Random delay between sessions
    await new Promise(r => setTimeout(r, 5000 + Math.random() * 10000));

    return await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
  }
}
```

## Workflow

When encountering captcha challenges:

1. **Detect** - Identify the type of challenge (captcha, block, rate limit)
2. **Assess** - Determine if the challenge is bypassable or requires intervention
3. **Handle** - Apply appropriate strategy (wait, retry, manual, skip)
4. **Log** - Record the incident for pattern analysis
5. **Adapt** - Adjust scraping behavior to prevent future triggers

## Integration Example

```typescript
async function scrapeWithCaptchaHandling(url: string): Promise<ScrapedData[]> {
  const browser = await puppeteer.launch({ headless: 'new' });

  try {
    const page = await browser.newPage();
    await configureForCaptchaPrevention(page);

    const response = await page.goto(url, { waitUntil: 'networkidle2' });

    // Check for blocks
    const blockCheck = await detectBlock(page, response);
    if (blockCheck.blocked) {
      if (blockCheck.retryAfter) {
        console.log(`Rate limited. Waiting ${blockCheck.retryAfter}s...`);
        await new Promise(r => setTimeout(r, blockCheck.retryAfter * 1000));
        return scrapeWithCaptchaHandling(url); // Retry
      }
      throw new Error(`Blocked: ${blockCheck.reason}`);
    }

    // Check for captcha
    const captchaCheck = await detectCaptcha(page);
    if (captchaCheck.detected) {
      if (captchaCheck.type === 'cloudflare') {
        const passed = await waitForCloudflare(page);
        if (!passed) throw new Error('Cloudflare challenge timeout');
      } else {
        // Log and skip or request manual intervention
        console.log(`Captcha detected: ${captchaCheck.type}`);
        throw new Error(`Captcha required: ${captchaCheck.type}`);
      }
    }

    // Proceed with scraping
    return await extractData(page);

  } finally {
    await browser.close();
  }
}
```

## Additional Resources

### Reference Files

For detailed patterns and advanced techniques:
- **`references/detection-patterns.md`** - Extended detection signatures for various captcha systems
