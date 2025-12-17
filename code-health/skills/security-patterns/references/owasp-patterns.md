# OWASP Vulnerability Detection Patterns

Extended patterns for detecting OWASP Top 10 vulnerabilities across languages.

## A01:2021 - Broken Access Control

### Missing Authorization Checks
```regex
# Routes without auth middleware
app\.(get|post|put|delete)\s*\([^)]+\)\s*$
@(Get|Post|Put|Delete)\s*\([^)]*\)\s*\n\s*(async\s+)?def\s+\w+\s*\([^)]*\)\s*:
```

### Insecure Direct Object References
```regex
# User ID from request without validation
req\.(params|query|body)\.id
request\.args\.get\(['"]id['"]\)
```

## A02:2021 - Cryptographic Failures

### Weak Hashing
```regex
# MD5/SHA1 for passwords
(md5|sha1)\s*\(\s*(password|passwd|pwd)
hashlib\.(md5|sha1)\s*\(
crypto\.createHash\s*\(\s*['"]md5['"]\s*\)
```

### Hardcoded Encryption Keys
```regex
(aes|encryption)_?key\s*[=:]\s*['"][a-fA-F0-9]{32,}['"]
cipher\.init\s*\([^)]*['"][a-fA-F0-9]{16,}['"]
```

## A03:2021 - Injection

### SQL Injection by Language

**JavaScript/TypeScript:**
```regex
\.query\s*\(\s*`[^`]*\$\{
\.query\s*\([^)]*\+\s*
sequelize\.query\s*\([^)]*\$\{
```

**Python:**
```regex
cursor\.execute\s*\(\s*f['"]
cursor\.execute\s*\([^)]*%\s*
cursor\.execute\s*\([^)]*\.format\s*\(
```

**Go:**
```regex
db\.(Query|Exec)\s*\([^)]*\+
fmt\.Sprintf\s*\([^)]*SELECT
```

### Command Injection by Language

**JavaScript:**
```regex
child_process\.(exec|execSync)\s*\([^)]*\+
child_process\.(exec|execSync)\s*\(\s*`[^`]*\$\{
shelljs\.(exec|cat|ls)\s*\([^)]*\+
```

**Python:**
```regex
os\.system\s*\([^)]*\+
os\.popen\s*\([^)]*\+
subprocess\.(call|run|Popen)\s*\(\s*[^)]*,\s*shell\s*=\s*True
```

## A05:2021 - Security Misconfiguration

### Debug Mode in Production
```regex
DEBUG\s*=\s*True
app\.debug\s*=\s*True
NODE_ENV\s*[=:]\s*['"]development['"]
```

### CORS Misconfiguration
```regex
Access-Control-Allow-Origin['"]\s*[=:]\s*['"]\*['"]
cors\(\s*\{\s*origin\s*:\s*['"]\*['"]
```

### Missing Security Headers
```regex
# Check for absence of:
X-Frame-Options
X-Content-Type-Options
Strict-Transport-Security
Content-Security-Policy
```

## A06:2021 - Vulnerable Components

### Known Vulnerable Patterns
```regex
# Old jQuery with XSS
\$\s*\(\s*[^)]*\.html\s*\(
# Eval-based templating
new\s+Function\s*\(
```

## A07:2021 - Auth Failures

### Weak Password Requirements
```regex
password.*minlength\s*[=:]\s*[1-5]
min_length\s*=\s*[1-5]
```

### Session Issues
```regex
session\.cookie_secure\s*=\s*False
cookie\s*:\s*\{[^}]*secure\s*:\s*false
```

## A08:2021 - Integrity Failures

### Insecure Deserialization
```regex
# Python
pickle\.(loads?|Unpickler)\s*\(
yaml\.load\s*\([^)]*\)\s*$  # Missing Loader
marshal\.loads?\s*\(

# PHP
unserialize\s*\(\s*\$_(GET|POST|REQUEST)

# Java
ObjectInputStream.*readObject
XMLDecoder
```

## A10:2021 - SSRF

### User-Controlled URLs
```regex
(fetch|axios|request|http\.get)\s*\(\s*(req\.|request\.|params\.)
urllib\.request\.urlopen\s*\([^)]*request\.
http\.Get\s*\([^)]*r\.URL
```

## Detection Commands

```bash
# Run comprehensive OWASP scan
grep -rn --include="*.js" --include="*.ts" --include="*.py" \
  -E "(\.query\s*\([^)]*\+|exec\s*\([^)]*\+|innerHTML\s*=)" .
```
