---
name: output
description: Configure output format and destination for scraped data
argument-hint: "[--format <type>] [--dest <target>]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob"]
---

# Configure Output Command

Set up output format, destination, and data pipeline for scraped data.

## Arguments

- `--format <type>`: Output format (json, csv, parquet)
- `--dest <target>`: Destination type (file, postgres, mongodb, s3, bigquery)
- `--config <path>`: Path to existing output config file

## Workflow

1. **Gather configuration**:
   - If no arguments, prompt for format and destination
   - Load existing config if --config provided

2. **Configure destination**:
   - **File**: Set output directory and filename pattern
   - **PostgreSQL**: Configure connection string, table name
   - **MongoDB**: Configure URI, database, collection
   - **S3**: Configure bucket, region, prefix
   - **BigQuery**: Configure project, dataset, table

3. **Generate configuration file**:
   Create `scrape-output.config.json`:
   ```json
   {
     "format": "json",
     "destination": "file",
     "file": {
       "directory": "./output",
       "pattern": "data-{timestamp}.json"
     }
   }
   ```

4. **Update scraper code**:
   - Add output module import
   - Configure output at end of scrape function

5. **Test connection** (for databases/cloud):
   - Verify credentials work
   - Check write permissions

## Destination Configurations

### File Output
```json
{
  "destination": "file",
  "format": "csv",
  "file": {
    "directory": "./output",
    "pattern": "scrape-{date}.csv"
  }
}
```

### PostgreSQL
```json
{
  "destination": "postgres",
  "postgres": {
    "host": "localhost",
    "port": 5432,
    "database": "scrapes",
    "table": "products",
    "user": "${POSTGRES_USER}",
    "password": "${POSTGRES_PASSWORD}"
  }
}
```

### S3
```json
{
  "destination": "s3",
  "format": "parquet",
  "s3": {
    "bucket": "my-scrape-data",
    "region": "us-east-1",
    "prefix": "daily/"
  }
}
```

## Output

```
Configuring output for: product-scraper

Output Format: CSV
Destination: PostgreSQL

Configuration:
─────────────
Host: localhost:5432
Database: scrapes
Table: products
─────────────

✓ Connection test successful
✓ Config saved to scrape-output.config.json
✓ Updated src/index.ts with output configuration

Environment variables required:
- POSTGRES_USER
- POSTGRES_PASSWORD

Add to .env file or export before running.
```

## Example Usage

```
/scrape-studio:output --format json --dest file
/scrape-studio:output --format csv --dest postgres
/scrape-studio:output --format parquet --dest s3
/scrape-studio:output --config ./my-config.json
```

## Reference

Use the etl-pipelines skill for detailed output patterns and connection templates.
