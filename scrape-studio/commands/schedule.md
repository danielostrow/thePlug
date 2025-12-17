---
name: schedule
description: Configure scheduling for a scraper using cron or GitHub Actions
argument-hint: "[scraper] [--cron <expression>] [--github]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
---

# Schedule Scraper Command

Set up automated scheduling for scrapers using cron jobs or GitHub Actions workflows.

## Arguments

- `scraper` (optional): Path to scraper or scraper name. Auto-detects if in scraper directory
- `--cron <expression>`: Cron expression for scheduling (e.g., "0 */6 * * *")
- `--github`: Generate GitHub Actions workflow instead of system cron
- `--daily`: Shorthand for daily at midnight
- `--hourly`: Shorthand for every hour

## Workflow

### For Cron (default)

1. **Parse schedule expression**:
   - Validate cron syntax
   - Show human-readable interpretation

2. **Generate cron entry**:
   ```
   # Scrape Studio: product-scraper
   0 */6 * * * cd /path/to/scraper && npx ts-node src/index.ts >> logs/scrape.log 2>&1
   ```

3. **Create log rotation** (optional):
   - Add logrotate configuration
   - Set up log directory

4. **Provide installation instructions**:
   ```bash
   crontab -e  # Then paste the generated entry
   ```

### For GitHub Actions (--github)

1. **Create workflow file** at `.github/workflows/scrape.yml`:
   ```yaml
   name: Scheduled Scrape
   on:
     schedule:
       - cron: '0 */6 * * *'
     workflow_dispatch:

   jobs:
     scrape:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-node@v4
           with:
             node-version: '20'
         - run: npm ci
         - run: npx ts-node src/index.ts
         - uses: actions/upload-artifact@v4
           with:
             name: scrape-data
             path: output/
   ```

2. **Add secrets reminder**:
   - List required environment variables
   - Show how to add GitHub secrets

## Schedule Examples

| Expression | Description |
|------------|-------------|
| `0 * * * *` | Every hour |
| `0 */6 * * *` | Every 6 hours |
| `0 0 * * *` | Daily at midnight |
| `0 0 * * 1` | Weekly on Monday |
| `0 0 1 * *` | Monthly on the 1st |

## Output

```
Scheduling: product-scraper
Schedule: Every 6 hours (0 */6 * * *)

Generated cron entry:
───────────────────────
0 */6 * * * cd /Users/dan/scrapers/product-scraper && npx ts-node src/index.ts >> logs/scrape.log 2>&1
───────────────────────

To install:
1. Run: crontab -e
2. Paste the entry above
3. Save and exit

Logs will be written to: logs/scrape.log
```

## Example Usage

```
/scrape-studio:schedule --cron "0 */6 * * *"
/scrape-studio:schedule product-scraper --daily
/scrape-studio:schedule --github --hourly
```
