# Scrape Studio

Visual AI-powered web scraper creation plugin for Claude Code. Design, generate, and manage dynamic web scrapers using screenshot-driven analysis, intelligent captcha handling, and ETL pipeline integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://github.com/anthropics/claude-code)

## How It Works

Scrape Studio uses a **visual-first approach** - Claude analyzes screenshots of web pages to understand their structure, then dynamically generates scraper code based on what it actually sees:

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Screenshot │ -> │   Analyze   │ -> │   Generate  │ -> │   Verify    │
│   Capture   │    │   Layout    │    │   Scraper   │    │   Results   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

No more guessing at selectors - Claude sees the page like a human would.

## Features

- **Visual Scraper Generation**: Screenshot-driven page analysis for intelligent code generation
- **Site Analysis**: Automatic page structure analysis and scraping strategy recommendations
- **Captcha Handling**: Built-in heuristics for detecting and handling captchas with manual fallback
- **Scheduling**: Generate cron jobs or GitHub Actions workflows for automated scraping
- **ETL Pipelines**: Output to JSON, CSV, Parquet, databases (Postgres, MongoDB), or cloud (S3, BigQuery)
- **Content Validation**: AI-powered validation of scraped data quality

## Installation

### From thePlug Marketplace (Recommended)

```bash
# Add thePlug marketplace
/plugin marketplace add danielostrow/thePlug

# Install scrape-studio
/plugin install scrape-studio@thePlug
```

### Manual Installation

```bash
# Clone and use directly
git clone https://github.com/danielostrow/scrape-studio.git
claude --plugin-dir /path/to/scrape-studio

# Or copy to your project
cp -r scrape-studio /your-project/.claude-plugin/
```

## Commands

| Command | Description |
|---------|-------------|
| `/scrape-studio:create [name]` | Create a new scraper project |
| `/scrape-studio:run [file]` | Execute an existing scraper |
| `/scrape-studio:schedule [scraper]` | Configure scheduling (cron or GitHub Actions) |
| `/scrape-studio:output` | Configure output format and destination |
| `/scrape-studio:discover [terms]` | Find sites matching search criteria |

## Quick Start

Just describe what you want to scrape:

```
"Scrape all product prices from https://shop.example.com"
```

Claude will:
1. Take a screenshot of the page
2. Analyze the visual layout
3. Identify data patterns (product cards, prices, etc.)
4. Generate a TypeScript Puppeteer scraper
5. Run and verify the results

## Agents

| Agent | When It Triggers |
|-------|------------------|
| `scraper-generator` | When describing data to extract from a website |
| `site-analyzer` | When analyzing a URL for scraping feasibility |
| `content-validator` | After running a scraper to validate output quality |

## Skills

The plugin provides specialized knowledge that activates automatically:

- **Puppeteer Scraping**: Best practices for selectors, anti-detection, navigation
- **Captcha Handling**: Detection heuristics and fallback strategies
- **ETL Pipelines**: Output formatting and database/cloud integration patterns

## Requirements

- Node.js 18+
- TypeScript (`npm install -g typescript ts-node`)
- Puppeteer (`npm install puppeteer`)

## Output Destinations

### Files
- JSON, CSV, Parquet formats

### Databases
- PostgreSQL (via `pg` package)
- MongoDB (via `mongodb` package)

### Cloud
- AWS S3 (via `@aws-sdk/client-s3`)
- Google BigQuery (via `@google-cloud/bigquery`)

## Examples

### Scrape E-commerce Products

```
"Scrape product listings from books.toscrape.com including title, price, and rating"
```

### Scrape News Headlines

```
"Get the top stories from Hacker News with title, points, and comments"
```

### Analyze Site Feasibility

```
"Can you check if https://example.com is scrapable?"
```

## Author

**Daniel Ostrow**
- Website: [neuralintellect.com](https://neuralintellect.com)
- GitHub: [@danielostrow](https://github.com/danielostrow)

## License

MIT License - see [LICENSE](LICENSE) for details.
