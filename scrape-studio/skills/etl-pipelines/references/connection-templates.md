# Connection Templates

Ready-to-use connection configurations for all supported output destinations.

## File Outputs

### JSON Configuration

```typescript
interface JsonOutputConfig {
  destination: 'file';
  format: 'json';
  options: {
    path: string;
    pretty: boolean;
    appendMode: boolean;
  };
}

// Example configuration
const jsonConfig: JsonOutputConfig = {
  destination: 'file',
  format: 'json',
  options: {
    path: './output/data-{timestamp}.json',
    pretty: true,
    appendMode: false,
  },
};

// Implementation
function writeJson(data: any[], config: JsonOutputConfig): void {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filePath = config.options.path.replace('{timestamp}', timestamp);

  const content = config.options.pretty
    ? JSON.stringify(data, null, 2)
    : JSON.stringify(data);

  fs.writeFileSync(filePath, content, 'utf-8');
}
```

### CSV Configuration

```typescript
interface CsvOutputConfig {
  destination: 'file';
  format: 'csv';
  options: {
    path: string;
    delimiter: string;
    headers: boolean;
    quoteStrings: boolean;
  };
}

// Example configuration
const csvConfig: CsvOutputConfig = {
  destination: 'file',
  format: 'csv',
  options: {
    path: './output/data-{timestamp}.csv',
    delimiter: ',',
    headers: true,
    quoteStrings: true,
  },
};

// Implementation using csv-writer
import { createObjectCsvWriter } from 'csv-writer';

async function writeCsv(data: any[], config: CsvOutputConfig): Promise<void> {
  if (data.length === 0) return;

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filePath = config.options.path.replace('{timestamp}', timestamp);

  const headers = Object.keys(data[0]).map((key) => ({
    id: key,
    title: key,
  }));

  const csvWriter = createObjectCsvWriter({
    path: filePath,
    header: headers,
    fieldDelimiter: config.options.delimiter,
  });

  await csvWriter.writeRecords(data);
}
```

### Parquet Configuration

```typescript
interface ParquetOutputConfig {
  destination: 'file';
  format: 'parquet';
  options: {
    path: string;
    compression: 'GZIP' | 'SNAPPY' | 'UNCOMPRESSED';
    rowGroupSize: number;
  };
  schema: Record<string, 'UTF8' | 'INT64' | 'DOUBLE' | 'BOOLEAN' | 'TIMESTAMP_MILLIS'>;
}

// Example configuration
const parquetConfig: ParquetOutputConfig = {
  destination: 'file',
  format: 'parquet',
  options: {
    path: './output/data-{timestamp}.parquet',
    compression: 'SNAPPY',
    rowGroupSize: 10000,
  },
  schema: {
    id: 'UTF8',
    title: 'UTF8',
    price: 'DOUBLE',
    quantity: 'INT64',
    in_stock: 'BOOLEAN',
    scraped_at: 'TIMESTAMP_MILLIS',
  },
};

// Implementation using parquetjs
import { ParquetWriter, ParquetSchema } from 'parquetjs';

async function writeParquet(
  data: any[],
  config: ParquetOutputConfig
): Promise<void> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const filePath = config.options.path.replace('{timestamp}', timestamp);

  const schemaFields: Record<string, any> = {};
  for (const [field, type] of Object.entries(config.schema)) {
    schemaFields[field] = { type, compression: config.options.compression };
  }

  const schema = new ParquetSchema(schemaFields);
  const writer = await ParquetWriter.openFile(schema, filePath);

  for (const row of data) {
    await writer.appendRow(row);
  }

  await writer.close();
}
```

## Database Outputs

### PostgreSQL

```typescript
interface PostgresConfig {
  destination: 'postgres';
  connection: {
    host: string;
    port: number;
    database: string;
    user: string;
    password: string;
    ssl?: boolean | { rejectUnauthorized: boolean };
  };
  table: string;
  options: {
    createTable: boolean;
    upsertKey?: string;
    batchSize: number;
  };
}

// Example configuration
const postgresConfig: PostgresConfig = {
  destination: 'postgres',
  connection: {
    host: process.env.POSTGRES_HOST || 'localhost',
    port: parseInt(process.env.POSTGRES_PORT || '5432'),
    database: process.env.POSTGRES_DB || 'scrapes',
    user: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || '',
    ssl: process.env.NODE_ENV === 'production',
  },
  table: 'scraped_products',
  options: {
    createTable: true,
    upsertKey: 'url', // For upsert behavior
    batchSize: 1000,
  },
};

// Implementation using pg
import { Pool } from 'pg';

async function writePostgres(data: any[], config: PostgresConfig): Promise<void> {
  const pool = new Pool(config.connection);

  try {
    // Create table if needed
    if (config.options.createTable && data.length > 0) {
      const columns = Object.keys(data[0]);
      const createSql = `
        CREATE TABLE IF NOT EXISTS ${config.table} (
          _id SERIAL PRIMARY KEY,
          ${columns.map((col) => `${col} TEXT`).join(',\n          ')},
          _created_at TIMESTAMP DEFAULT NOW()
        )
      `;
      await pool.query(createSql);
    }

    // Insert in batches
    const columns = Object.keys(data[0]);
    for (let i = 0; i < data.length; i += config.options.batchSize) {
      const batch = data.slice(i, i + config.options.batchSize);

      const values = batch
        .map((row, rowIdx) => {
          const vals = columns.map(
            (_, colIdx) => `$${rowIdx * columns.length + colIdx + 1}`
          );
          return `(${vals.join(', ')})`;
        })
        .join(', ');

      const params = batch.flatMap((row) => columns.map((col) => row[col]));

      const insertSql = config.options.upsertKey
        ? `
            INSERT INTO ${config.table} (${columns.join(', ')})
            VALUES ${values}
            ON CONFLICT (${config.options.upsertKey})
            DO UPDATE SET ${columns.filter((c) => c !== config.options.upsertKey).map((c) => `${c} = EXCLUDED.${c}`).join(', ')}
          `
        : `INSERT INTO ${config.table} (${columns.join(', ')}) VALUES ${values}`;

      await pool.query(insertSql, params);
    }
  } finally {
    await pool.end();
  }
}
```

### MongoDB

```typescript
interface MongoConfig {
  destination: 'mongodb';
  connection: {
    uri: string;
    database: string;
    collection: string;
  };
  options: {
    upsertKey?: string;
    batchSize: number;
    indexes?: Array<{ fields: Record<string, 1 | -1>; unique?: boolean }>;
  };
}

// Example configuration
const mongoConfig: MongoConfig = {
  destination: 'mongodb',
  connection: {
    uri: process.env.MONGODB_URI || 'mongodb://localhost:27017',
    database: 'scrapes',
    collection: 'products',
  },
  options: {
    upsertKey: 'url',
    batchSize: 1000,
    indexes: [
      { fields: { url: 1 }, unique: true },
      { fields: { scraped_at: -1 } },
    ],
  },
};

// Implementation using mongodb
import { MongoClient } from 'mongodb';

async function writeMongo(data: any[], config: MongoConfig): Promise<void> {
  const client = new MongoClient(config.connection.uri);

  try {
    await client.connect();
    const db = client.db(config.connection.database);
    const collection = db.collection(config.connection.collection);

    // Create indexes if specified
    if (config.options.indexes) {
      for (const idx of config.options.indexes) {
        await collection.createIndex(idx.fields, { unique: idx.unique });
      }
    }

    // Add metadata
    const documents = data.map((item) => ({
      ...item,
      _scraped_at: new Date(),
      _source: 'scrape-studio',
    }));

    // Insert or upsert
    if (config.options.upsertKey) {
      const operations = documents.map((doc) => ({
        updateOne: {
          filter: { [config.options.upsertKey!]: doc[config.options.upsertKey!] },
          update: { $set: doc },
          upsert: true,
        },
      }));
      await collection.bulkWrite(operations);
    } else {
      await collection.insertMany(documents);
    }
  } finally {
    await client.close();
  }
}
```

## Cloud Outputs

### AWS S3

```typescript
interface S3Config {
  destination: 's3';
  connection: {
    region: string;
    bucket: string;
    prefix: string;
    accessKeyId?: string;
    secretAccessKey?: string;
  };
  format: 'json' | 'csv' | 'parquet';
  options: {
    partitionBy?: string; // e.g., 'date' for daily partitions
    compression?: 'gzip' | 'none';
  };
}

// Example configuration
const s3Config: S3Config = {
  destination: 's3',
  connection: {
    region: process.env.AWS_REGION || 'us-east-1',
    bucket: process.env.S3_BUCKET || 'my-scrape-data',
    prefix: 'scraped-data',
    // Uses AWS SDK credential chain if not specified
  },
  format: 'json',
  options: {
    partitionBy: 'date',
    compression: 'gzip',
  },
};

// Implementation using @aws-sdk/client-s3
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { gzipSync } from 'zlib';

async function writeS3(data: any[], config: S3Config): Promise<string> {
  const s3 = new S3Client({
    region: config.connection.region,
    credentials: config.connection.accessKeyId
      ? {
          accessKeyId: config.connection.accessKeyId,
          secretAccessKey: config.connection.secretAccessKey!,
        }
      : undefined,
  });

  const timestamp = new Date().toISOString();
  const date = timestamp.split('T')[0];

  // Build key with optional partitioning
  let key = config.connection.prefix;
  if (config.options.partitionBy === 'date') {
    key += `/date=${date}`;
  }
  key += `/data-${timestamp.replace(/[:.]/g, '-')}.${config.format}`;
  if (config.options.compression === 'gzip') {
    key += '.gz';
  }

  // Serialize data
  let body: Buffer | string;
  let contentType: string;

  switch (config.format) {
    case 'json':
      body = JSON.stringify(data, null, 2);
      contentType = 'application/json';
      break;
    case 'csv':
      body = convertToCsv(data);
      contentType = 'text/csv';
      break;
    default:
      throw new Error(`Unsupported format: ${config.format}`);
  }

  // Compress if needed
  if (config.options.compression === 'gzip') {
    body = gzipSync(body);
    contentType = 'application/gzip';
  }

  await s3.send(
    new PutObjectCommand({
      Bucket: config.connection.bucket,
      Key: key,
      Body: body,
      ContentType: contentType,
    })
  );

  return `s3://${config.connection.bucket}/${key}`;
}
```

### Google BigQuery

```typescript
interface BigQueryConfig {
  destination: 'bigquery';
  connection: {
    projectId: string;
    datasetId: string;
    tableId: string;
    location?: string;
    keyFilename?: string; // Path to service account JSON
  };
  options: {
    createDataset: boolean;
    createTable: boolean;
    writeDisposition: 'WRITE_APPEND' | 'WRITE_TRUNCATE' | 'WRITE_EMPTY';
    partitionField?: string;
  };
  schema?: Array<{
    name: string;
    type: 'STRING' | 'INTEGER' | 'FLOAT' | 'BOOLEAN' | 'TIMESTAMP' | 'RECORD';
    mode?: 'NULLABLE' | 'REQUIRED' | 'REPEATED';
  }>;
}

// Example configuration
const bigqueryConfig: BigQueryConfig = {
  destination: 'bigquery',
  connection: {
    projectId: process.env.GCP_PROJECT_ID || 'my-project',
    datasetId: 'scrape_data',
    tableId: 'products',
    location: 'US',
  },
  options: {
    createDataset: true,
    createTable: true,
    writeDisposition: 'WRITE_APPEND',
    partitionField: 'scraped_at',
  },
  schema: [
    { name: 'id', type: 'STRING', mode: 'REQUIRED' },
    { name: 'title', type: 'STRING' },
    { name: 'price', type: 'FLOAT' },
    { name: 'url', type: 'STRING' },
    { name: 'scraped_at', type: 'TIMESTAMP' },
  ],
};

// Implementation using @google-cloud/bigquery
import { BigQuery } from '@google-cloud/bigquery';

async function writeBigQuery(
  data: any[],
  config: BigQueryConfig
): Promise<void> {
  const bigquery = new BigQuery({
    projectId: config.connection.projectId,
    keyFilename: config.connection.keyFilename,
  });

  // Create dataset if needed
  if (config.options.createDataset) {
    const dataset = bigquery.dataset(config.connection.datasetId);
    const [exists] = await dataset.exists();
    if (!exists) {
      await bigquery.createDataset(config.connection.datasetId, {
        location: config.connection.location,
      });
    }
  }

  const dataset = bigquery.dataset(config.connection.datasetId);
  const table = dataset.table(config.connection.tableId);

  // Create table if needed
  if (config.options.createTable) {
    const [exists] = await table.exists();
    if (!exists) {
      const schema = config.schema || inferSchema(data[0]);
      const tableOptions: any = { schema };

      if (config.options.partitionField) {
        tableOptions.timePartitioning = {
          type: 'DAY',
          field: config.options.partitionField,
        };
      }

      await dataset.createTable(config.connection.tableId, tableOptions);
    }
  }

  // Insert data
  await table.insert(data, {
    raw: false,
    skipInvalidRows: false,
    ignoreUnknownValues: false,
  });
}

function inferSchema(sample: any): any[] {
  return Object.entries(sample).map(([name, value]) => ({
    name,
    type:
      typeof value === 'number'
        ? Number.isInteger(value)
          ? 'INTEGER'
          : 'FLOAT'
        : typeof value === 'boolean'
          ? 'BOOLEAN'
          : value instanceof Date
            ? 'TIMESTAMP'
            : 'STRING',
  }));
}
```

## Environment Variable Templates

For secure credential management:

```bash
# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=scrapes
POSTGRES_USER=scraper
POSTGRES_PASSWORD=your-secure-password

# MongoDB
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net

# AWS S3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
S3_BUCKET=my-scrape-data

# Google Cloud
GCP_PROJECT_ID=my-project
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# BigQuery
BIGQUERY_DATASET=scrape_data
BIGQUERY_TABLE=products
```

## Connection Testing

```typescript
async function testConnection(config: any): Promise<{ success: boolean; error?: string }> {
  try {
    switch (config.destination) {
      case 'postgres': {
        const pool = new Pool(config.connection);
        await pool.query('SELECT 1');
        await pool.end();
        return { success: true };
      }

      case 'mongodb': {
        const client = new MongoClient(config.connection.uri);
        await client.connect();
        await client.db(config.connection.database).command({ ping: 1 });
        await client.close();
        return { success: true };
      }

      case 's3': {
        const s3 = new S3Client({ region: config.connection.region });
        await s3.send(
          new HeadBucketCommand({ Bucket: config.connection.bucket })
        );
        return { success: true };
      }

      case 'bigquery': {
        const bigquery = new BigQuery({ projectId: config.connection.projectId });
        const [datasets] = await bigquery.getDatasets({ maxResults: 1 });
        return { success: true };
      }

      default:
        return { success: false, error: `Unknown destination: ${config.destination}` };
    }
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}
```
