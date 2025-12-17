---
name: discover
description: Find websites matching search criteria for scraping
argument-hint: "<search terms> [--category <type>]"
allowed-tools: ["Read", "Write", "WebSearch", "WebFetch"]
---

# Discover Sites Command

Find websites that match specified criteria for potential scraping targets. Uses curated data source directories plus web search.

## Arguments

- `search terms` (required): Keywords describing the data or sites to find
- `--category <type>`: Filter by category (ecommerce, news, directory, api, government)
- `--limit <n>`: Maximum number of results (default: 10)

## Workflow

1. **Parse search terms** and category filter

2. **Search curated directories** first:
   - Public data sources (data.gov, kaggle, etc.)
   - API directories (RapidAPI, public-apis)
   - Industry-specific databases

3. **Perform web search** for additional sources:
   - Search for: "{terms} site data" or "{terms} public data"
   - Filter for likely scrapable sources

4. **Analyze each result**:
   - Check if site is accessible
   - Identify data structure (HTML tables, JSON API, etc.)
   - Note any obvious restrictions (login required, rate limits)

5. **Rank results** by:
   - Data relevance
   - Ease of scraping
   - Data freshness indicators
   - Terms of service considerations

6. **Present findings** with actionable next steps

## Curated Source Categories

| Category | Sources |
|----------|---------|
| Government | data.gov, census.gov, bls.gov |
| Finance | SEC EDGAR, Yahoo Finance, Alpha Vantage |
| Ecommerce | Product review sites, price aggregators |
| Real Estate | Zillow, Redfin public data |
| Jobs | Indeed, LinkedIn public listings |
| Weather | NOAA, Weather.gov |

## Output

```
Discovering sites for: "laptop prices comparison"

Found 8 potential sources:

1. PriceGrabber.com
   Type: Price aggregator
   Structure: HTML with structured data
   Difficulty: Medium (pagination required)
   ✓ Recommended for scraping

2. Google Shopping
   Type: Search engine
   Structure: Dynamic JavaScript
   Difficulty: Hard (anti-bot protection)
   ⚠ Consider alternatives

3. Best Buy API (RapidAPI)
   Type: REST API
   Structure: JSON
   Difficulty: Easy (API key required)
   ✓ Recommended for scraping

...

Recommendations:
- Best for quick start: Best Buy API via RapidAPI
- Best for comprehensive data: PriceGrabber.com
- Avoid: Google Shopping (heavy anti-bot)

Next steps:
1. /scrape-studio:create laptop-prices --url https://pricegrabber.com/laptops
2. Review site structure with site-analyzer agent
```

## Example Usage

```
/scrape-studio:discover laptop prices
/scrape-studio:discover real estate listings --category ecommerce
/scrape-studio:discover weather data --category government --limit 5
```

## Notes

- Always respect robots.txt and terms of service
- Prefer official APIs over HTML scraping when available
- Consider rate limits and be a good citizen
- Government and public data sources are generally safest
