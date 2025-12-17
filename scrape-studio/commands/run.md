---
name: run
description: Execute an existing scraper and display results
argument-hint: "[scraper-file.ts] [--output <format>] [--dest <path>]"
allowed-tools: ["Read", "Bash", "Write", "Glob"]
---

# Run Scraper Command

Execute a TypeScript Puppeteer scraper and handle the output.

## Arguments

- `scraper-file.ts` (optional): Path to scraper file. Auto-detects if in scraper directory
- `--output <format>`: Output format (json, csv, parquet). Default: json
- `--dest <path>`: Output destination path. Default: ./output/

## Workflow

1. **Locate scraper file**:
   - If path provided, use it
   - If in scraper directory, look for src/index.ts or src/scraper.ts
   - Search for *.scraper.ts files in current directory

2. **Verify dependencies**:
   - Check if node_modules exists
   - If not, run `npm install`

3. **Execute scraper**:
   ```bash
   npx ts-node <scraper-file>
   ```

4. **Handle output**:
   - Parse stdout for JSON data
   - Apply requested format transformation
   - Save to destination

5. **Report results**:
   - Number of items scraped
   - Output file location
   - Any errors or warnings

## Error Handling

- **Captcha detected**: Pause and notify user, reference captcha-handling skill
- **Rate limited**: Wait and retry with backoff
- **Timeout**: Report which step failed
- **Parse error**: Show raw output for debugging

## Output

```
Running scraper: src/scraper.ts

✓ Browser launched
✓ Page loaded: https://example.com
✓ Extracted 47 items
✓ Saved to output/data-2024-01-15.json

Summary:
- Items scraped: 47
- Duration: 23.4s
- Output: output/data-2024-01-15.json (12.3 KB)
```

## Example Usage

```
/scrape-studio:run
/scrape-studio:run src/product-scraper.ts
/scrape-studio:run --output csv --dest ./exports/
```
