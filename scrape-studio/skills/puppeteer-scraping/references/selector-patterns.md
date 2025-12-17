# Selector Patterns for Common Sites

Advanced selector strategies for different website architectures and common scraping targets.

## E-commerce Sites

### Product Listing Pages

```typescript
// Amazon-style product cards
const amazonSelectors = {
  container: '[data-component-type="s-search-result"]',
  title: 'h2 a span',
  price: '.a-price .a-offscreen',
  rating: '.a-icon-star-small span',
  reviews: '[data-csa-c-type="widget"] span:last-child',
  image: '.s-image',
  link: 'h2 a'
};

// Shopify-style stores
const shopifySelectors = {
  container: '.product-card, .grid__item',
  title: '.product-card__title, .product-title',
  price: '.price, .product-price',
  comparePrice: '.price--compare, .compare-price',
  image: '.product-card__image img',
  link: '.product-card__link'
};

// Generic e-commerce fallbacks
const genericEcommerceSelectors = {
  container: '[data-product], .product, .product-item, article[class*="product"]',
  title: '[data-product-title], .product-title, .product-name, h2, h3',
  price: '[data-product-price], .price, .product-price, [class*="price"]',
  image: '[data-product-image], .product-image img, .product-img',
  link: 'a[href*="/product"], a[href*="/p/"]'
};
```

### Product Detail Pages

```typescript
const productDetailSelectors = {
  // Primary info
  title: 'h1, [data-testid="product-title"], .product-title',
  price: '[data-testid="price"], .price-current, #priceblock_ourprice',
  description: '[data-testid="description"], .product-description, #productDescription',

  // Images
  mainImage: '[data-testid="main-image"], .product-image-main img',
  thumbnails: '.product-thumbnails img, .image-gallery img',

  // Variants
  variants: '[data-variant], .variant-option, .swatch',
  selectedVariant: '[data-variant].selected, .variant-option.active',

  // Availability
  stock: '[data-availability], .stock-status, #availability span',
  addToCart: '[data-testid="add-to-cart"], #add-to-cart-button, .add-to-cart',

  // Reviews
  reviewCount: '[data-testid="review-count"], .review-count',
  averageRating: '[data-testid="rating"], .average-rating, [itemprop="ratingValue"]'
};
```

## News & Content Sites

### Article Listings

```typescript
const newsListingSelectors = {
  container: 'article, [data-testid="article"], .story, .post',
  headline: 'h2, h3, .headline, .story-title',
  summary: '.summary, .excerpt, .dek, p:first-of-type',
  author: '[rel="author"], .byline, .author',
  timestamp: 'time, [datetime], .timestamp, .date',
  category: '.category, .section, .tag:first-child',
  image: 'figure img, .thumbnail img, .story-image'
};
```

### Article Content

```typescript
const articleContentSelectors = {
  // Main content
  headline: 'h1, .article-title, [data-testid="headline"]',
  body: 'article, .article-body, .story-body, [data-testid="article-body"]',
  paragraphs: 'article p, .article-body p',

  // Metadata
  author: '[rel="author"], .author-name, .byline a',
  publishDate: 'time[datetime], [data-testid="publish-date"], .publish-date',
  updateDate: '.update-date, [data-testid="update-date"]',

  // Media
  featuredImage: '.featured-image img, article > figure img',
  captions: 'figcaption, .image-caption',

  // Related
  tags: '.tags a, .article-tags a',
  relatedArticles: '.related-articles a, .more-stories a'
};
```

## Job Boards

### Job Listings

```typescript
const jobListingSelectors = {
  // Indeed-style
  indeed: {
    container: '.job_seen_beacon, .jobsearch-ResultsList > li',
    title: '.jobTitle, h2.jobTitle',
    company: '.companyName, [data-testid="company-name"]',
    location: '.companyLocation, [data-testid="text-location"]',
    salary: '.salary-snippet, .estimated-salary',
    description: '.job-snippet, .job-desc',
    posted: '.date, [data-testid="myJobsStateDate"]'
  },

  // LinkedIn-style
  linkedin: {
    container: '.job-card-container, .jobs-search-results__list-item',
    title: '.job-card-list__title, .job-card-container__link',
    company: '.job-card-container__company-name',
    location: '.job-card-container__metadata-item',
    posted: '.job-card-container__listed-time'
  },

  // Generic
  generic: {
    container: '[data-job], .job-listing, .job-item',
    title: '.job-title, h2, h3',
    company: '.company, .employer',
    location: '.location, [class*="location"]',
    salary: '.salary, [class*="salary"], [class*="compensation"]',
    type: '.job-type, .employment-type'
  }
};
```

## Real Estate

```typescript
const realEstateSelectors = {
  // Property cards
  container: '[data-testid="property-card"], .property-card, .listing-card',
  price: '[data-testid="price"], .list-card-price, .property-price',
  address: '[data-testid="address"], .list-card-addr, .property-address',
  beds: '[data-testid="beds"], .list-card-details li:nth-child(1)',
  baths: '[data-testid="baths"], .list-card-details li:nth-child(2)',
  sqft: '[data-testid="sqft"], .list-card-details li:nth-child(3)',
  image: '.property-image img, .carousel img:first-child',
  link: 'a[href*="/homedetails"], a[href*="/property"]',

  // Property details
  description: '.property-description, [data-testid="description"]',
  features: '.property-features li, .amenities li',
  agent: '.agent-info, .realtor-info',
  listingDate: '.listing-date, [data-testid="list-date"]'
};
```

## Social Media (Public Data)

```typescript
const socialMediaSelectors = {
  // Twitter/X public pages
  twitter: {
    tweet: 'article[data-testid="tweet"]',
    author: '[data-testid="User-Name"]',
    content: '[data-testid="tweetText"]',
    timestamp: 'time',
    likes: '[data-testid="like"] span',
    retweets: '[data-testid="retweet"] span',
    replies: '[data-testid="reply"] span'
  },

  // Instagram public posts
  instagram: {
    post: 'article',
    image: 'article img',
    likes: 'section span',
    caption: 'div > span',
    timestamp: 'time'
  }
};
```

## Framework-Specific Patterns

### React Applications

```typescript
// React apps often use data-testid for testing
const reactPatterns = {
  // Common test ID patterns
  byTestId: (name: string) => `[data-testid="${name}"]`,
  byTestIdContains: (partial: string) => `[data-testid*="${partial}"]`,

  // Look for hydration markers
  reactRoot: '[data-reactroot], #__next, #root',

  // State stored in window
  extractState: () => {
    return (window as any).__NEXT_DATA__?.props?.pageProps ||
           (window as any).__INITIAL_STATE__ ||
           {};
  }
};

// Extract data from React state instead of DOM
async function extractReactState(page: Page): Promise<any> {
  return await page.evaluate(() => {
    // Next.js
    if ((window as any).__NEXT_DATA__) {
      return (window as any).__NEXT_DATA__.props.pageProps;
    }
    // Redux
    if ((window as any).__REDUX_STATE__) {
      return (window as any).__REDUX_STATE__;
    }
    // Generic React state
    const rootEl = document.querySelector('[data-reactroot]');
    if (rootEl) {
      const fiber = (rootEl as any)._reactRootContainer?._internalRoot?.current;
      return fiber?.memoizedState || null;
    }
    return null;
  });
}
```

### Vue Applications

```typescript
const vuePatterns = {
  // Nuxt.js data
  nuxtData: 'script#__NUXT_DATA__',

  // Vue refs
  byRef: (name: string) => `[ref="${name}"]`,

  // Extract Nuxt state
  extractNuxtState: () => {
    const script = document.querySelector('script#__NUXT_DATA__');
    if (script) {
      return JSON.parse(script.textContent || '[]');
    }
    return (window as any).__NUXT__?.state || {};
  }
};
```

## Defensive Selector Strategies

### Multi-fallback Pattern

```typescript
async function selectWithFallbacks(
  page: Page,
  selectors: string[],
  description: string
): Promise<string | null> {
  for (const selector of selectors) {
    const element = await page.$(selector);
    if (element) {
      const text = await element.evaluate(el => el.textContent?.trim());
      if (text) {
        console.log(`Found ${description} with selector: ${selector}`);
        return text;
      }
    }
  }
  console.warn(`Could not find ${description} with any selector`);
  return null;
}

// Usage
const title = await selectWithFallbacks(page, [
  '[data-testid="product-title"]',
  'h1.product-title',
  '.product-info h1',
  'h1'
], 'product title');
```

### Self-Healing Selectors

```typescript
interface SelectorConfig {
  primary: string;
  fallbacks: string[];
  validator: (text: string) => boolean;
}

class SelfHealingSelector {
  private configs: Record<string, SelectorConfig> = {};
  private workingSelectors: Record<string, string> = {};

  register(name: string, config: SelectorConfig): void {
    this.configs[name] = config;
  }

  async select(page: Page, name: string): Promise<string | null> {
    const config = this.configs[name];
    if (!config) throw new Error(`Unknown selector: ${name}`);

    // Try cached working selector first
    if (this.workingSelectors[name]) {
      const result = await this.trySelector(page, this.workingSelectors[name], config.validator);
      if (result) return result;
    }

    // Try primary
    const primaryResult = await this.trySelector(page, config.primary, config.validator);
    if (primaryResult) {
      this.workingSelectors[name] = config.primary;
      return primaryResult;
    }

    // Try fallbacks
    for (const fallback of config.fallbacks) {
      const result = await this.trySelector(page, fallback, config.validator);
      if (result) {
        this.workingSelectors[name] = fallback;
        console.log(`Selector healed: ${name} now uses ${fallback}`);
        return result;
      }
    }

    return null;
  }

  private async trySelector(
    page: Page,
    selector: string,
    validator: (text: string) => boolean
  ): Promise<string | null> {
    try {
      const element = await page.$(selector);
      if (!element) return null;

      const text = await element.evaluate(el => el.textContent?.trim() || '');
      return validator(text) ? text : null;
    } catch {
      return null;
    }
  }
}

// Usage
const selectors = new SelfHealingSelector();
selectors.register('price', {
  primary: '[data-testid="price"]',
  fallbacks: ['.price', '.product-price', 'span[class*="price"]'],
  validator: (text) => /\$[\d,.]+/.test(text)
});
```

## XPath Patterns

For complex selections when CSS isn't enough:

```typescript
const xpathPatterns = {
  // Text content matching
  buttonByText: (text: string) => `//button[contains(text(), "${text}")]`,
  linkByText: (text: string) => `//a[contains(text(), "${text}")]`,

  // Sibling selection
  labelValue: (label: string) => `//dt[contains(text(), "${label}")]/following-sibling::dd[1]`,
  tableRowValue: (header: string) => `//th[contains(text(), "${header}")]/following-sibling::td[1]`,

  // Parent traversal
  parentOfChild: (childSelector: string) => `${childSelector}/..`,
  ancestorWithClass: (className: string) => `ancestor::*[contains(@class, "${className}")]`,

  // Positional
  nthMatch: (selector: string, n: number) => `(${selector})[${n}]`
};

// Usage with Puppeteer
async function xpathSelect(page: Page, xpath: string): Promise<string | null> {
  const elements = await page.$x(xpath);
  if (elements.length === 0) return null;
  return await elements[0].evaluate(el => el.textContent?.trim() || null);
}
```
