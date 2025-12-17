---
name: Security Vulnerability Patterns
description: This skill activates when the user asks about "security vulnerabilities", "OWASP", "SQL injection", "XSS", "command injection", "hardcoded secrets", "API keys", "CVE", "security audit", "find passwords", "exposed credentials", or needs to detect and fix security issues in code.
version: 1.0.0
---

# Security Vulnerability Patterns

Comprehensive guidance for detecting security vulnerabilities using language-agnostic pattern matching.

## Secret Detection Patterns

### High-Confidence Patterns

| Type | Regex Pattern | Example |
|------|---------------|---------|
| AWS Access Key | `AKIA[0-9A-Z]{16}` | AKIAIOSFODNN7EXAMPLE |
| AWS Secret Key | `['\"][0-9a-zA-Z/+]{40}['\"]` | 40-char base64 string |
| GitHub Token | `(ghp\|gho\|ghu\|ghs\|ghr)_[A-Za-z0-9_]{36}` | ghp_xxxx... |
| Generic API Key | `['\"]([Aa]pi[_-]?[Kk]ey)['\"]\\s*[=:]\\s*['\"][a-zA-Z0-9_-]{20,}['\"]` | api_key = "xxx" |
| Private Key | `-----BEGIN (RSA\|DSA\|EC\|OPENSSH) PRIVATE KEY-----` | PEM header |
| JWT Token | `eyJ[a-zA-Z0-9_-]*\\.eyJ[a-zA-Z0-9_-]*\\.[a-zA-Z0-9_-]*` | eyJhbGc... |

### Connection Strings

```regex
# Database URLs with credentials
(mongodb|postgres|mysql|redis|amqp):\/\/[^:]+:[^@]+@

# Generic password assignments
(password|passwd|pwd|secret)\s*[=:]\s*['"][^'"]{8,}['"]
```

## OWASP Top 10 Patterns

### A03:2021 - Injection

**SQL Injection:**
```regex
# String concatenation in queries
(query|execute|sql)\s*\(\s*['"].*['"]\s*\+
(query|execute|sql)\s*\(\s*f['"]
\.query\s*\(`[^`]*\$\{
```

**Command Injection:**
```regex
# Shell execution with variables
(exec|system|popen|spawn)\s*\([^)]*(\$|%)
subprocess\.(call|run|Popen).*shell\s*=\s*True
child_process\.(exec|spawn)\s*\([^)]*\+
```

**XSS Patterns:**
```regex
innerHTML\s*=
dangerouslySetInnerHTML
v-html\s*=
\{\{\s*.*\s*\}\}  # Context-dependent
```

### A02:2021 - Cryptographic Failures

```regex
# Weak algorithms
(md5|sha1)\s*\(
DES|RC4|Blowfish
# Hardcoded IVs
iv\s*=\s*['"][a-fA-F0-9]{16,}['"]
```

### A08:2021 - Insecure Deserialization

```regex
pickle\.loads?\s*\(
yaml\.load\s*\([^)]*\)  # Without Loader
unserialize\s*\(
eval\s*\(
```

## Severity Classification

| Level | Criteria | Response Time |
|-------|----------|---------------|
| Critical | RCE, exposed prod secrets, auth bypass | Immediate |
| High | SQLi, XSS, CVEs with CVSS > 7.0 | 24 hours |
| Medium | SSRF, path traversal, info disclosure | 1 week |
| Low | Best practice violations | Next release |

## Scanning Workflow

1. **Secret Scan**: Apply regex patterns to all text files (exclude node_modules, .git, vendor)
2. **OWASP Scan**: Check injection patterns in source files
3. **CVE Audit**: Run native package manager audit tools
4. **Config Check**: Analyze security settings in config files
5. **File Permissions**: Check for sensitive files (.env, *.pem, *.key)

## Fix Recommendations

### Secret Externalization
```diff
- const API_KEY = "sk_live_abc123";
+ const API_KEY = process.env.API_KEY;
```

### Parameterized Queries
```diff
# JavaScript
- db.query("SELECT * FROM users WHERE id=" + id);
+ db.query("SELECT * FROM users WHERE id = ?", [id]);

# Python
- cursor.execute(f"SELECT * FROM users WHERE id={id}")
+ cursor.execute("SELECT * FROM users WHERE id = %s", (id,))
```

## Reference Files

- `references/owasp-patterns.md` - Extended OWASP detection by language
- `references/secret-patterns.md` - Comprehensive secret detection
- `references/cve-databases.md` - CVE checking integration
