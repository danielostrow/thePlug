# Auto-Fix Templates

Ready-to-apply fix patterns for common issues.

## Security Fixes

### Secret Externalization

**Pattern: Hardcoded API Key**
```diff
// Before
- const API_KEY = "sk_live_abc123xyz";
+ const API_KEY = process.env.API_KEY;

// .env.example (create if doesn't exist)
+ API_KEY=your_api_key_here

// .gitignore (add if not present)
+ .env
+ .env.local
+ .env.*.local
```

**Pattern: Database Credentials**
```diff
// Before
- const DB_URL = "postgres://user:password@localhost:5432/db";
+ const DB_URL = process.env.DATABASE_URL;

// .env.example
+ DATABASE_URL=postgres://user:password@localhost:5432/db
```

**Pattern: AWS Credentials**
```diff
// Before
- const awsConfig = {
-   accessKeyId: "AKIAIOSFODNN7EXAMPLE",
-   secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
- };
+ const awsConfig = {
+   accessKeyId: process.env.AWS_ACCESS_KEY_ID,
+   secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
+ };

// .env.example
+ AWS_ACCESS_KEY_ID=your_access_key
+ AWS_SECRET_ACCESS_KEY=your_secret_key
```

### SQL Injection Fixes

**JavaScript (mysql/mysql2)**
```diff
// Before
- connection.query("SELECT * FROM users WHERE id=" + userId);
+ connection.query("SELECT * FROM users WHERE id = ?", [userId]);

// Before (template literal)
- connection.query(`SELECT * FROM users WHERE name='${name}'`);
+ connection.query("SELECT * FROM users WHERE name = ?", [name]);
```

**JavaScript (pg/postgres)**
```diff
// Before
- client.query("SELECT * FROM users WHERE id=" + userId);
+ client.query("SELECT * FROM users WHERE id = $1", [userId]);
```

**Python (psycopg2)**
```diff
# Before
- cursor.execute(f"SELECT * FROM users WHERE id={user_id}")
+ cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))

# Before (format)
- cursor.execute("SELECT * FROM users WHERE id={}".format(user_id))
+ cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

**Python (sqlite3)**
```diff
# Before
- cursor.execute(f"SELECT * FROM users WHERE name='{name}'")
+ cursor.execute("SELECT * FROM users WHERE name = ?", (name,))
```

**Go (database/sql)**
```diff
// Before
- db.Query("SELECT * FROM users WHERE id=" + id)
+ db.Query("SELECT * FROM users WHERE id = $1", id)
```

### XSS Fixes

**React**
```diff
// Before - dangerous
- <div dangerouslySetInnerHTML={{__html: userContent}} />
+ <div>{userContent}</div>

// If HTML is required, sanitize first
+ import DOMPurify from 'dompurify';
+ <div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(userContent)}} />
```

**Vue**
```diff
// Before
- <div v-html="userContent"></div>
+ <div>{{ userContent }}</div>

// If HTML required
+ import DOMPurify from 'dompurify';
+ <div v-html="sanitize(userContent)"></div>
+ methods: { sanitize: (html) => DOMPurify.sanitize(html) }
```

**Vanilla JS**
```diff
// Before
- element.innerHTML = userInput;
+ element.textContent = userInput;
```

## Dead Code Removal

### Unused Imports
```diff
// Before
- import { used, unused, alsoUnused } from 'module';
+ import { used } from 'module';

// Before (namespace import with partial use)
- import * as utils from './utils';
- utils.usedFunc();
+ import { usedFunc } from './utils';
+ usedFunc();
```

### Unused Variables
```diff
// Before
- const unused = computeValue();
- let x = 1;
- x = 2;  // Never read
  const used = otherValue;
  console.log(used);
```

### Unreachable Code
```diff
  function example() {
    return result;
-   console.log("never executes");
-   cleanup();
  }
```

### Commented Code
```diff
- // function oldImplementation() {
- //   return deprecated();
- // }
-
- /*
- class RemovedFeature {
-   doThing() {}
- }
- */
```

## Code Quality Fixes

### Early Return (Guard Clauses)
```diff
// Before
- function process(data) {
-   if (data) {
-     if (data.valid) {
-       if (data.items.length > 0) {
-         return doWork(data);
-       }
-     }
-   }
-   return null;
- }

+ function process(data) {
+   if (!data) return null;
+   if (!data.valid) return null;
+   if (data.items.length === 0) return null;
+   return doWork(data);
+ }
```

### Replace Magic Numbers
```diff
// Before
- if (age >= 21) {
-   discount = price * 0.15;
- }

+ const LEGAL_AGE = 21;
+ const SENIOR_DISCOUNT_RATE = 0.15;
+
+ if (age >= LEGAL_AGE) {
+   discount = price * SENIOR_DISCOUNT_RATE;
+ }
```

### Simplify Boolean Returns
```diff
// Before
- if (condition) {
-   return true;
- } else {
-   return false;
- }

+ return condition;

// Before (negated)
- if (condition) {
-   return false;
- }
- return true;

+ return !condition;
```

### Use Optional Chaining
```diff
// Before
- if (user && user.address && user.address.city) {
-   city = user.address.city;
- }

+ city = user?.address?.city;

// Before (with default)
- const city = user && user.address ? user.address.city : 'Unknown';
+ const city = user?.address?.city ?? 'Unknown';
```

### Use Nullish Coalescing
```diff
// Before
- const value = input !== null && input !== undefined ? input : defaultValue;
+ const value = input ?? defaultValue;

// Before (common mistake - falsy vs nullish)
- const count = input || 0;  // Wrong if 0 is valid
+ const count = input ?? 0;  // Correct - only null/undefined trigger default
```

## Dependency Fixes

### Update Vulnerable Package
```bash
# npm
npm update package-name

# yarn
yarn upgrade package-name

# pnpm
pnpm update package-name
```

### Remove Unused Dependency
```bash
# npm
npm uninstall unused-package

# yarn
yarn remove unused-package

# pnpm
pnpm remove unused-package

# Python
pip uninstall unused-package
# Then remove from requirements.txt
```

### Pin Floating Version
```diff
// package.json - Before
- "lodash": "^4.17.0"
+ "lodash": "4.17.21"

// requirements.txt - Before
- requests>=2.0
+ requests==2.31.0
```

## Configuration Fixes

### Add .gitignore Entries
```diff
+ # Environment files
+ .env
+ .env.local
+ .env.*.local
+
+ # Secrets
+ *.pem
+ *.key
+ credentials.json
+ secrets.yaml
+
+ # IDE
+ .idea/
+ .vscode/
+ *.swp
```

### Add Security Headers (Express)
```diff
+ const helmet = require('helmet');
+ app.use(helmet());
```

### Disable Debug Mode
```diff
// Before
- DEBUG=true
- app.debug = True
- NODE_ENV=development

+ DEBUG=false
+ app.debug = False
+ NODE_ENV=production
```
