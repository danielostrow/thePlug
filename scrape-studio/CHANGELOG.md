# Changelog

All notable changes to Scrape Studio will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-17

### Added

- **Visual-First Scraping**: Screenshot-driven page analysis for intelligent scraper generation
- **Commands**:
  - `/scrape-studio:create` - Create new scraper projects with TypeScript/Puppeteer
  - `/scrape-studio:run` - Execute scrapers with output formatting
  - `/scrape-studio:schedule` - Configure cron jobs or GitHub Actions workflows
  - `/scrape-studio:output` - Set up ETL pipelines (JSON, CSV, Parquet, Postgres, MongoDB, S3, BigQuery)
  - `/scrape-studio:discover` - Find scrapable sites matching search criteria
- **Agents**:
  - `scraper-generator` - Visual analysis and dynamic scraper code generation
  - `site-analyzer` - Assess scraping feasibility and recommend strategies
  - `content-validator` - Validate scraped data quality and completeness
- **Skills**:
  - `puppeteer-scraping` - Best practices for selectors, navigation, and anti-detection
  - `captcha-handling` - Detection heuristics and manual fallback strategies
  - `etl-pipelines` - Output formatting and database/cloud integration patterns
- **Reference Documentation**:
  - Visual analysis techniques for screenshot-driven development
  - Selector patterns for common site types (e-commerce, news, jobs)
  - Anti-detection and bot evasion strategies
  - Captcha detection patterns for major protection systems
  - Connection templates for all supported output destinations

### Technical Details

- TypeScript-first with full type definitions
- Puppeteer-based browser automation
- Support for dynamic/JavaScript-rendered pages
- Pagination and infinite scroll handling
- Human-like delays and rate limiting
- Multiple output format support
