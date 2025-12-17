# Captcha Detection Patterns

Extended signatures and heuristics for detecting various captcha and anti-bot systems.

## reCAPTCHA Detection

### v2 (Checkbox)

```typescript
interface ReCaptchaV2Detection {
  type: 'recaptcha-v2';
  indicators: string[];
  siteKey?: string;
}

async function detectReCaptchaV2(page: Page): Promise<ReCaptchaV2Detection | null> {
  return await page.evaluate(() => {
    const indicators: string[] = [];

    // Check for reCAPTCHA iframe
    const iframe = document.querySelector('iframe[src*="recaptcha"]');
    if (iframe) indicators.push('recaptcha-iframe');

    // Check for g-recaptcha div
    const gRecaptcha = document.querySelector('.g-recaptcha');
    if (gRecaptcha) indicators.push('g-recaptcha-class');

    // Check for data-sitekey attribute
    const siteKeyEl = document.querySelector('[data-sitekey]');
    const siteKey = siteKeyEl?.getAttribute('data-sitekey') || undefined;
    if (siteKey) indicators.push('data-sitekey');

    // Check for grecaptcha object
    if ((window as any).grecaptcha) indicators.push('grecaptcha-object');

    // Check for recaptcha script
    const scripts = document.querySelectorAll('script[src*="recaptcha"]');
    if (scripts.length > 0) indicators.push('recaptcha-script');

    if (indicators.length === 0) return null;

    return {
      type: 'recaptcha-v2',
      indicators,
      siteKey,
    };
  });
}
```

### v3 (Invisible)

```typescript
async function detectReCaptchaV3(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    // v3 loads invisibly - check for the script and grecaptcha.execute
    const hasScript = !!document.querySelector(
      'script[src*="recaptcha/api.js?render="]'
    );
    const hasExecute =
      typeof (window as any).grecaptcha?.execute === 'function';

    // Check for v3-specific badge
    const badge = document.querySelector('.grecaptcha-badge');

    return hasScript || hasExecute || !!badge;
  });
}
```

### Enterprise

```typescript
async function detectReCaptchaEnterprise(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    // Enterprise uses different script URL
    const enterpriseScript = document.querySelector(
      'script[src*="recaptcha/enterprise.js"]'
    );
    const hasEnterprise =
      typeof (window as any).grecaptcha?.enterprise === 'object';

    return !!enterpriseScript || hasEnterprise;
  });
}
```

## hCaptcha Detection

```typescript
interface HCaptchaDetection {
  type: 'hcaptcha';
  indicators: string[];
  siteKey?: string;
}

async function detectHCaptcha(page: Page): Promise<HCaptchaDetection | null> {
  return await page.evaluate(() => {
    const indicators: string[] = [];

    // Check for hCaptcha iframe
    const iframe = document.querySelector('iframe[src*="hcaptcha.com"]');
    if (iframe) indicators.push('hcaptcha-iframe');

    // Check for h-captcha div
    const hCaptcha = document.querySelector('.h-captcha');
    if (hCaptcha) indicators.push('h-captcha-class');

    // Check for data-sitekey
    const siteKeyEl = document.querySelector('.h-captcha[data-sitekey]');
    const siteKey = siteKeyEl?.getAttribute('data-sitekey') || undefined;
    if (siteKey) indicators.push('data-sitekey');

    // Check for hcaptcha object
    if ((window as any).hcaptcha) indicators.push('hcaptcha-object');

    // Check for hcaptcha script
    const scripts = document.querySelectorAll('script[src*="hcaptcha.com"]');
    if (scripts.length > 0) indicators.push('hcaptcha-script');

    if (indicators.length === 0) return null;

    return {
      type: 'hcaptcha',
      indicators,
      siteKey,
    };
  });
}
```

## Cloudflare Detection

### Browser Verification

```typescript
interface CloudflareDetection {
  type: 'cloudflare';
  variant: 'challenge' | 'turnstile' | 'managed' | 'js-challenge';
  indicators: string[];
}

async function detectCloudflare(page: Page): Promise<CloudflareDetection | null> {
  // Check response headers first
  const response = await page.evaluate(() => {
    return {
      title: document.title,
      hasCfRay: document.querySelector('meta[name="cf-ray"]') !== null,
    };
  });

  // Check for "Just a moment..." page
  if (response.title.includes('Just a moment')) {
    return {
      type: 'cloudflare',
      variant: 'js-challenge',
      indicators: ['just-a-moment-title'],
    };
  }

  return await page.evaluate(() => {
    const indicators: string[] = [];

    // Check for challenge form
    const challengeForm = document.querySelector('#challenge-form');
    if (challengeForm) indicators.push('challenge-form');

    // Check for Turnstile widget
    const turnstile = document.querySelector('.cf-turnstile');
    if (turnstile) indicators.push('turnstile-widget');

    // Check for CF challenge scripts
    const cfScripts = document.querySelectorAll(
      'script[src*="challenges.cloudflare.com"]'
    );
    if (cfScripts.length > 0) indicators.push('cf-challenge-script');

    // Check for ray ID in page
    const rayId = document.body.innerHTML.match(/Ray ID: ([a-f0-9]+)/i);
    if (rayId) indicators.push('ray-id-present');

    // Check for cf-browser-verification
    const browserVerify = document.querySelector('.cf-browser-verification');
    if (browserVerify) indicators.push('browser-verification');

    if (indicators.length === 0) return null;

    // Determine variant
    let variant: CloudflareDetection['variant'] = 'managed';
    if (indicators.includes('turnstile-widget')) variant = 'turnstile';
    else if (indicators.includes('challenge-form')) variant = 'challenge';

    return {
      type: 'cloudflare',
      variant,
      indicators,
    };
  });
}
```

## Advanced Bot Detection Systems

### DataDome

```typescript
async function detectDataDome(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    // Check for DataDome cookie
    const hasDataDomeCookie = document.cookie.includes('datadome');

    // Check for DataDome script
    const ddScript = document.querySelector('script[src*="datadome"]');

    // Check for DataDome headers (via meta tag or stored value)
    const ddMeta = document.querySelector('meta[name*="datadome"]');

    // Check for DataDome challenge page
    const ddChallenge =
      document.body.innerHTML.includes('datadome') ||
      document.body.innerHTML.includes('DataDome');

    return hasDataDomeCookie || !!ddScript || !!ddMeta || ddChallenge;
  });
}
```

### PerimeterX / HUMAN

```typescript
async function detectPerimeterX(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    // Check for _px cookies
    const hasPxCookie =
      document.cookie.includes('_px') || document.cookie.includes('_pxhd');

    // Check for PerimeterX script
    const pxScript = document.querySelector(
      'script[src*="px-cdn"], script[src*="perimeterx"]'
    );

    // Check for _pxAppId
    const hasPxAppId = !!(window as any)._pxAppId;

    // Check for block page indicators
    const blockPage =
      document.body.innerHTML.includes('perimeterx') ||
      document.body.innerHTML.includes('Press & Hold');

    return hasPxCookie || !!pxScript || hasPxAppId || blockPage;
  });
}
```

### Akamai Bot Manager

```typescript
async function detectAkamai(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    // Check for _abck cookie
    const hasAbckCookie = document.cookie.includes('_abck');

    // Check for bm_sz cookie
    const hasBmSzCookie = document.cookie.includes('bm_sz');

    // Check for Akamai script patterns
    const akamaiScript = document.querySelector(
      'script[src*="akamaihd"], script[src*="akstat"]'
    );

    // Check for sensor_data
    const hasSensorData = !!(window as any).bmak;

    return hasAbckCookie || hasBmSzCookie || !!akamaiScript || hasSensorData;
  });
}
```

### Imperva / Incapsula

```typescript
async function detectImperva(page: Page): Promise<boolean> {
  return await page.evaluate(() => {
    // Check for incap_ses cookie
    const hasIncapCookie =
      document.cookie.includes('incap_ses') ||
      document.cookie.includes('visid_incap');

    // Check for Incapsula script
    const incapScript = document.querySelector('script[src*="incapsula"]');

    // Check for reese84 cookie (newer Imperva)
    const hasReeseCookie = document.cookie.includes('reese84');

    // Check for block page
    const blockPage =
      document.body.innerHTML.includes('Incapsula') ||
      document.body.innerHTML.includes('Request unsuccessful');

    return hasIncapCookie || !!incapScript || hasReeseCookie || blockPage;
  });
}
```

## Generic Block Detection

### HTTP Status Patterns

```typescript
async function checkResponseForBlock(
  response: HTTPResponse
): Promise<{ blocked: boolean; reason: string }> {
  const status = response.status();

  // Common block status codes
  if (status === 403) {
    return { blocked: true, reason: 'HTTP 403 Forbidden' };
  }

  if (status === 429) {
    return { blocked: true, reason: 'HTTP 429 Too Many Requests' };
  }

  if (status === 503) {
    const body = await response.text().catch(() => '');
    if (body.includes('captcha') || body.includes('challenge')) {
      return { blocked: true, reason: 'HTTP 503 with challenge' };
    }
  }

  // Check headers for WAF indicators
  const headers = response.headers();
  if (headers['x-amz-cf-pop'] && status >= 400) {
    return { blocked: true, reason: 'CloudFront block' };
  }

  return { blocked: false, reason: '' };
}
```

### Content-Based Detection

```typescript
interface ContentBlockDetection {
  blocked: boolean;
  reason: string;
  confidence: number;
}

async function detectBlockByContent(page: Page): Promise<ContentBlockDetection> {
  return await page.evaluate(() => {
    const bodyText = document.body.innerText.toLowerCase();
    const bodyHtml = document.body.innerHTML.toLowerCase();

    // High confidence block phrases
    const highConfidencePatterns = [
      'access denied',
      'access to this page has been denied',
      'your ip has been blocked',
      'you have been blocked',
      'please verify you are human',
      'complete the security check',
      'unusual traffic from your computer',
    ];

    for (const pattern of highConfidencePatterns) {
      if (bodyText.includes(pattern)) {
        return { blocked: true, reason: pattern, confidence: 0.95 };
      }
    }

    // Medium confidence patterns
    const mediumConfidencePatterns = [
      'captcha',
      'robot',
      'bot detected',
      'automated access',
      'please try again later',
      'too many requests',
      'rate limit',
    ];

    for (const pattern of mediumConfidencePatterns) {
      if (bodyText.includes(pattern)) {
        return { blocked: true, reason: pattern, confidence: 0.7 };
      }
    }

    // Check for suspiciously small page
    if (bodyText.length < 500 && !document.querySelector('script')) {
      return {
        blocked: true,
        reason: 'Suspiciously small response',
        confidence: 0.5,
      };
    }

    return { blocked: false, reason: '', confidence: 0 };
  });
}
```

## Unified Detection Function

```typescript
interface ProtectionDetectionResult {
  protected: boolean;
  systems: Array<{
    name: string;
    type: string;
    confidence: number;
    details?: Record<string, any>;
  }>;
  recommendation: string;
}

async function detectAllProtections(
  page: Page,
  response: HTTPResponse | null
): Promise<ProtectionDetectionResult> {
  const systems: ProtectionDetectionResult['systems'] = [];

  // Check Cloudflare
  const cloudflare = await detectCloudflare(page);
  if (cloudflare) {
    systems.push({
      name: 'Cloudflare',
      type: cloudflare.variant,
      confidence: 0.95,
      details: cloudflare,
    });
  }

  // Check reCAPTCHA
  const recaptchaV2 = await detectReCaptchaV2(page);
  if (recaptchaV2) {
    systems.push({
      name: 'reCAPTCHA v2',
      type: 'captcha',
      confidence: 0.95,
      details: recaptchaV2,
    });
  }

  const recaptchaV3 = await detectReCaptchaV3(page);
  if (recaptchaV3) {
    systems.push({
      name: 'reCAPTCHA v3',
      type: 'captcha',
      confidence: 0.85,
    });
  }

  // Check hCaptcha
  const hcaptcha = await detectHCaptcha(page);
  if (hcaptcha) {
    systems.push({
      name: 'hCaptcha',
      type: 'captcha',
      confidence: 0.95,
      details: hcaptcha,
    });
  }

  // Check advanced systems
  if (await detectDataDome(page)) {
    systems.push({ name: 'DataDome', type: 'bot-detection', confidence: 0.9 });
  }
  if (await detectPerimeterX(page)) {
    systems.push({ name: 'PerimeterX', type: 'bot-detection', confidence: 0.9 });
  }
  if (await detectAkamai(page)) {
    systems.push({ name: 'Akamai', type: 'bot-detection', confidence: 0.85 });
  }
  if (await detectImperva(page)) {
    systems.push({ name: 'Imperva', type: 'bot-detection', confidence: 0.9 });
  }

  // Check content-based blocking
  const contentBlock = await detectBlockByContent(page);
  if (contentBlock.blocked) {
    systems.push({
      name: 'Content Block',
      type: 'generic',
      confidence: contentBlock.confidence,
      details: { reason: contentBlock.reason },
    });
  }

  // Generate recommendation
  let recommendation = 'No protection detected - proceed with scraping';
  if (systems.length > 0) {
    const hasAdvanced = systems.some((s) => s.type === 'bot-detection');
    const hasCaptcha = systems.some((s) => s.type === 'captcha');

    if (hasAdvanced) {
      recommendation =
        'Advanced bot protection detected - consider using residential proxies or manual intervention';
    } else if (hasCaptcha) {
      recommendation =
        'Captcha detected - implement manual fallback or captcha solving service';
    } else {
      recommendation =
        'Basic protection detected - add delays and stealth configuration';
    }
  }

  return {
    protected: systems.length > 0,
    systems,
    recommendation,
  };
}
```
