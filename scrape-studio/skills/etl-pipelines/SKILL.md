---
name: ETL Pipeline Integration
description: This skill should be used when the user asks about "output format", "export data", "save to database", "upload to S3", "BigQuery", "Postgres", "MongoDB", "CSV", "JSON", "Parquet", "data pipeline", "ETL", "data transformation", or needs help configuring where scraped data should be stored and how it should be formatted.
version: 0.1.0
---

# ETL Pipeline Integration

Comprehensive guidance for transforming and loading scraped data into various destinations including files (JSON, CSV, Parquet), databases (PostgreSQL, MongoDB), and cloud storage (S3, BigQuery).

## Data Transformation

### Schema Normalization

Ensure consistent data structure before export:

```typescript
interface RawScrapedItem {
  [key: string]: any;
}

interface NormalizedItem {
  id: string;
  source_url: string;
  scraped_at: string;
  data: Record<string, any>;
}

function normalizeData(items: RawScrapedItem[], sourceUrl: string): NormalizedItem[] {
  return items.map((item, index) => ({
    id: `${Date.now()}-${index}`,
    source_url: sourceUrl,
    scraped_at: new Date().toISOString(),
    data: cleanItem(item)
  }));
}

function cleanItem(item: RawScrapedItem): Record<string, any> {
  const cleaned: Record<string, any> = {};

  for (const [key, value] of Object.entries(item)) {
    // Normalize keys to snake_case
    const normalizedKey = key.replace(/([A-Z])/g, '_$1').toLowerCase().replace(/^_/, '');

    // Clean values
    if (typeof value === 'string') {
      cleaned[normalizedKey] = value.trim();
    } else if (value !== null && value !== undefined) {
      cleaned[normalizedKey] = value;
    }
  }

  return cleaned;
}
```

### Type Coercion

Convert scraped strings to appropriate types:

```typescript
interface TypeSchema {
  [field: string]: 'string' | 'number' | 'boolean' | 'date' | 'array';
}

function coerceTypes(item: Record<string, any>, schema: TypeSchema): Record<string, any> {
  const result: Record<string, any> = {};

  for (const [field, type] of Object.entries(schema)) {
    const value = item[field];

    if (value === null || value === undefined) {
      result[field] = null;
      continue;
    }

    switch (type) {
      case 'number':
        result[field] = parseFloat(String(value).replace(/[^0-9.-]/g, '')) || null;
        break;
      case 'boolean':
        result[field] = ['true', '1', 'yes'].includes(String(value).toLowerCase());
        break;
      case 'date':
        result[field] = new Date(value).toISOString();
        break;
      case 'array':
        result[field] = Array.isArray(value) ? value : [value];
        break;
      default:
        result[field] = String(value);
    }
  }

  return result;
}
```

## File Outputs

### JSON Export

```typescript
import { writeFileSync } from 'fs';

function exportToJson(data: any[], filePath: string, options?: { pretty?: boolean }): void {
  const content = options?.pretty
    ? JSON.stringify(data, null, 2)
    : JSON.stringify(data);

  writeFileSync(filePath, content, 'utf-8');
  console.log(`Exported ${data.length} items to ${filePath}`);
}

// JSONL (newline-delimited) for streaming
function exportToJsonl(data: any[], filePath: string): void {
  const content = data.map(item => JSON.stringify(item)).join('\n');
  writeFileSync(filePath, content, 'utf-8');
}
```

### CSV Export

```typescript
import { createObjectCsvWriter } from 'csv-writer';

async function exportToCsv(data: any[], filePath: string): Promise<void> {
  if (data.length === 0) return;

  // Auto-detect headers from first item
  const headers = Object.keys(flattenObject(data[0])).map(key => ({
    id: key,
    title: key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
  }));

  const csvWriter = createObjectCsvWriter({
    path: filePath,
    header: headers
  });

  const flatData = data.map(flattenObject);
  await csvWriter.writeRecords(flatData);
  console.log(`Exported ${data.length} items to ${filePath}`);
}

function flattenObject(obj: any, prefix = ''): Record<string, any> {
  const result: Record<string, any> = {};

  for (const [key, value] of Object.entries(obj)) {
    const newKey = prefix ? `${prefix}_${key}` : key;

    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      Object.assign(result, flattenObject(value, newKey));
    } else if (Array.isArray(value)) {
      result[newKey] = value.join('; ');
    } else {
      result[newKey] = value;
    }
  }

  return result;
}
```

### Parquet Export

```typescript
import { ParquetWriter, ParquetSchema } from 'parquetjs';

async function exportToParquet(data: any[], filePath: string, schema: any): Promise<void> {
  const parquetSchema = new ParquetSchema(schema);
  const writer = await ParquetWriter.openFile(parquetSchema, filePath);

  for (const row of data) {
    await writer.appendRow(row);
  }

  await writer.close();
  console.log(`Exported ${data.length} items to ${filePath}`);
}

// Example schema
const productSchema = {
  id: { type: 'UTF8' },
  title: { type: 'UTF8' },
  price: { type: 'DOUBLE' },
  scraped_at: { type: 'TIMESTAMP_MILLIS' }
};
```

## Database Outputs

### PostgreSQL

```typescript
import { Pool } from 'pg';

interface PgConfig {
  host: string;
  port: number;
  database: string;
  user: string;
  password: string;
}

async function exportToPostgres(
  data: any[],
  config: PgConfig,
  tableName: string
): Promise<void> {
  const pool = new Pool(config);

  try {
    // Create table if not exists
    const columns = Object.keys(data[0]);
    const createTableSql = `
      CREATE TABLE IF NOT EXISTS ${tableName} (
        id SERIAL PRIMARY KEY,
        ${columns.map(col => `${col} TEXT`).join(',\n        ')},
        created_at TIMESTAMP DEFAULT NOW()
      )
    `;
    await pool.query(createTableSql);

    // Insert data
    for (const item of data) {
      const values = columns.map(col => item[col]);
      const placeholders = columns.map((_, i) => `$${i + 1}`).join(', ');
      const insertSql = `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES (${placeholders})`;
      await pool.query(insertSql, values);
    }

    console.log(`Inserted ${data.length} rows into ${tableName}`);

  } finally {
    await pool.end();
  }
}
```

### MongoDB

```typescript
import { MongoClient } from 'mongodb';

interface MongoConfig {
  uri: string;
  database: string;
  collection: string;
}

async function exportToMongo(data: any[], config: MongoConfig): Promise<void> {
  const client = new MongoClient(config.uri);

  try {
    await client.connect();
    const db = client.db(config.database);
    const collection = db.collection(config.collection);

    // Add metadata to each document
    const documents = data.map(item => ({
      ...item,
      _scraped_at: new Date(),
      _source: 'scrape-studio'
    }));

    const result = await collection.insertMany(documents);
    console.log(`Inserted ${result.insertedCount} documents into ${config.collection}`);

  } finally {
    await client.close();
  }
}
```

## Cloud Outputs

### AWS S3

```typescript
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

interface S3Config {
  region: string;
  bucket: string;
  prefix?: string;
}

async function exportToS3(
  data: any[],
  config: S3Config,
  format: 'json' | 'csv' | 'parquet' = 'json'
): Promise<string> {
  const s3 = new S3Client({ region: config.region });

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const key = `${config.prefix || 'scrapes'}/${timestamp}.${format}`;

  let body: string | Buffer;
  let contentType: string;

  switch (format) {
    case 'json':
      body = JSON.stringify(data, null, 2);
      contentType = 'application/json';
      break;
    case 'csv':
      body = await convertToCsvString(data);
      contentType = 'text/csv';
      break;
    default:
      throw new Error(`Unsupported format: ${format}`);
  }

  await s3.send(new PutObjectCommand({
    Bucket: config.bucket,
    Key: key,
    Body: body,
    ContentType: contentType
  }));

  const location = `s3://${config.bucket}/${key}`;
  console.log(`Uploaded to ${location}`);
  return location;
}
```

### Google BigQuery

```typescript
import { BigQuery } from '@google-cloud/bigquery';

interface BigQueryConfig {
  projectId: string;
  datasetId: string;
  tableId: string;
}

async function exportToBigQuery(data: any[], config: BigQueryConfig): Promise<void> {
  const bigquery = new BigQuery({ projectId: config.projectId });

  const dataset = bigquery.dataset(config.datasetId);
  const table = dataset.table(config.tableId);

  // Auto-detect schema from data
  const [exists] = await table.exists();
  if (!exists) {
    const schema = inferBigQuerySchema(data[0]);
    await dataset.createTable(config.tableId, { schema });
  }

  // Stream insert
  await table.insert(data);
  console.log(`Inserted ${data.length} rows into ${config.datasetId}.${config.tableId}`);
}

function inferBigQuerySchema(sample: any): any[] {
  return Object.entries(sample).map(([name, value]) => ({
    name,
    type: typeof value === 'number' ? 'FLOAT64' :
          typeof value === 'boolean' ? 'BOOL' :
          value instanceof Date ? 'TIMESTAMP' : 'STRING'
  }));
}
```

## Pipeline Configuration

### Unified Output Manager

```typescript
type OutputFormat = 'json' | 'csv' | 'parquet';
type OutputDestination = 'file' | 'postgres' | 'mongodb' | 's3' | 'bigquery';

interface OutputConfig {
  destination: OutputDestination;
  format?: OutputFormat;
  path?: string;
  connection?: Record<string, any>;
}

class OutputManager {
  async export(data: any[], config: OutputConfig): Promise<void> {
    switch (config.destination) {
      case 'file':
        await this.exportToFile(data, config.path!, config.format || 'json');
        break;
      case 'postgres':
        await exportToPostgres(data, config.connection as PgConfig, config.path!);
        break;
      case 'mongodb':
        await exportToMongo(data, config.connection as MongoConfig);
        break;
      case 's3':
        await exportToS3(data, config.connection as S3Config, config.format);
        break;
      case 'bigquery':
        await exportToBigQuery(data, config.connection as BigQueryConfig);
        break;
    }
  }

  private async exportToFile(data: any[], path: string, format: OutputFormat): Promise<void> {
    switch (format) {
      case 'json':
        exportToJson(data, path, { pretty: true });
        break;
      case 'csv':
        await exportToCsv(data, path);
        break;
      case 'parquet':
        await exportToParquet(data, path, inferParquetSchema(data[0]));
        break;
    }
  }
}
```

## Workflow

To configure ETL for scraped data:

1. **Define schema** - Specify expected fields and types
2. **Transform data** - Normalize, clean, and coerce types
3. **Choose destination** - File, database, or cloud storage
4. **Configure connection** - Set up credentials and endpoints
5. **Test pipeline** - Verify with sample data
6. **Add error handling** - Retry logic and dead letter queues

## Additional Resources

### Reference Files

For detailed configuration patterns:
- **`references/connection-templates.md`** - Connection string templates for all destinations

### Example Files

Working examples in `examples/`:
- **`output-config.json`** - Sample output configuration file
