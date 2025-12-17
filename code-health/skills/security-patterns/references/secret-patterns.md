# Secret Detection Patterns

Comprehensive regex patterns for detecting hardcoded secrets with false positive handling.

## Cloud Provider Credentials

### AWS
```regex
# Access Key ID (high confidence)
AKIA[0-9A-Z]{16}

# Secret Access Key (medium confidence - check context)
(?<![A-Za-z0-9/+=])[A-Za-z0-9/+=]{40}(?![A-Za-z0-9/+=])

# Session Token
FwoGZXIvYXdzE[A-Za-z0-9/+=]+
```

### Google Cloud
```regex
# Service Account Key (JSON)
"type"\s*:\s*"service_account"

# API Key
AIza[0-9A-Za-z_-]{35}

# OAuth Client Secret
[0-9]+-[a-z0-9_]{32}\.apps\.googleusercontent\.com
```

### Azure
```regex
# Storage Account Key
[a-zA-Z0-9/+]{86}==

# Connection String
DefaultEndpointsProtocol=https;AccountName=[^;]+;AccountKey=[^;]+

# Client Secret
~[A-Za-z0-9_~.-]{34}
```

## API Services

### Stripe
```regex
sk_live_[0-9a-zA-Z]{24,}
pk_live_[0-9a-zA-Z]{24,}
rk_live_[0-9a-zA-Z]{24,}
```

### Twilio
```regex
SK[0-9a-fA-F]{32}
AC[0-9a-fA-F]{32}
```

### SendGrid
```regex
SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}
```

### Slack
```regex
xox[baprs]-[0-9]{10,13}-[0-9]{10,13}[a-zA-Z0-9-]*
```

### GitHub
```regex
ghp_[A-Za-z0-9_]{36}
gho_[A-Za-z0-9_]{36}
ghu_[A-Za-z0-9_]{36}
ghs_[A-Za-z0-9_]{36}
ghr_[A-Za-z0-9_]{36}
github_pat_[A-Za-z0-9_]{22,}
```

## Generic Patterns

### Passwords
```regex
# Assignment patterns
(password|passwd|pwd|pass)\s*[=:]\s*['"][^'"]{8,}['"]

# Config file patterns
(password|passwd|pwd):\s*[^\s#]+

# Environment variable patterns
(PASSWORD|PASSWD|PWD)=[^\s]+
```

### API Keys
```regex
# Generic key patterns
(api[_-]?key|apikey)\s*[=:]\s*['"][a-zA-Z0-9_-]{20,}['"]

# Bearer tokens
[Bb]earer\s+[a-zA-Z0-9_-]{20,}

# Authorization headers
[Aa]uthorization['"]\s*[=:]\s*['"][^'"]{20,}['"]
```

### Private Keys
```regex
-----BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY-----
-----BEGIN ENCRYPTED PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
```

### Connection Strings
```regex
# MongoDB
mongodb(\+srv)?:\/\/[^:]+:[^@]+@[^\/]+

# PostgreSQL
postgres(ql)?:\/\/[^:]+:[^@]+@[^\/]+

# MySQL
mysql:\/\/[^:]+:[^@]+@[^\/]+

# Redis
redis:\/\/:[^@]+@[^\/]+

# AMQP/RabbitMQ
amqps?:\/\/[^:]+:[^@]+@[^\/]+
```

### JWT Tokens
```regex
eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*
```

## False Positive Handling

### Common False Positives
- Placeholder values: `your_api_key_here`, `xxx`, `changeme`
- Example values in documentation
- Test fixtures with mock data
- Environment variable references: `process.env.`, `os.environ`

### Exclusion Patterns
```regex
# Skip placeholder values
(example|sample|test|mock|fake|dummy|placeholder|your[_-])[a-z_]*

# Skip env var references
(process\.env\.|os\.environ|getenv|ENV\[)

# Skip common test patterns
(test|spec|mock|fixture|stub)
```

### Validation Heuristics

1. **Entropy Check**: Real secrets typically have high entropy (>4.0)
2. **Length Check**: Most API keys are 20+ characters
3. **Character Distribution**: Real keys have mixed case, numbers, special chars
4. **Context Check**: Look for assignment to credential-named variables

## Scanning Command

```bash
# High-confidence secret scan
grep -rn --include="*.js" --include="*.ts" --include="*.py" --include="*.go" \
  --include="*.env*" --include="*.json" --include="*.yaml" --include="*.yml" \
  -E "(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{36}|sk_live_[0-9a-zA-Z]{24,})" \
  --exclude-dir={node_modules,.git,vendor,dist,build} .
```
