---
name: create
description: Create a new web scraper project with TypeScript and Puppeteer
argument-hint: "[scraper-name] [--url <target-url>]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
---

# Create Scraper Command

Create a new TypeScript Puppeteer scraper project with best practices built in.

## Arguments

- `scraper-name` (optional): Name for the scraper. Defaults to "scraper"
- `--url <target-url>` (optional): Target URL to scrape. If provided, analyze the page structure

## Workflow

1. **Parse arguments** - Extract scraper name and optional target URL
2. **Create project structure**:
   ```
   scraper-name/
   ├── package.json
   ├── tsconfig.json
   ├── src/
   │   ├── index.ts          # Main entry point
   │   ├── scraper.ts        # Core scraping logic
   │   ├── config.ts         # Configuration
   │   └── types.ts          # TypeScript interfaces
   ├── output/               # Scraped data output
   └── .env.example          # Environment template
   ```
3. **Generate package.json** with dependencies:
   - puppeteer
   - typescript
   - ts-node
   - dotenv
4. **Generate TypeScript configuration**
5. **Create scraper template** with:
   - Anti-detection configuration
   - Error handling
   - Retry logic
   - Output formatting
6. **If URL provided**, use the scraper-generator agent to analyze and customize

## Output

Report what was created and provide next steps:
```
Created scraper: my-scraper/

Next steps:
1. cd my-scraper
2. npm install
3. Edit src/scraper.ts to customize selectors
4. npm start
```

## Example Usage

```
/scrape-studio:create product-scraper
/scrape-studio:create price-tracker --url https://example.com/products
```

## Templates

Use the puppeteer-scraping skill for template code patterns. Include:
- Browser configuration with stealth settings
- Configurable selectors
- Data validation
- Multiple output format support
