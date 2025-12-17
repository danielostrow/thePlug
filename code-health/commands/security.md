---
name: security
description: Run security-focused analysis for vulnerabilities, secrets, and CVEs
argument-hint: "[--secrets] [--owasp] [--cves] [--severity critical|high|medium|low]"
allowed-tools: ["Read", "Grep", "Glob", "Bash"]
---

# Security Scan Command

Perform focused security analysis of your codebase to find vulnerabilities, hardcoded secrets, and dependency CVEs.

## Arguments

- `--secrets`: Focus on hardcoded secrets detection only
- `--owasp`: Focus on OWASP vulnerability patterns only
- `--cves`: Focus on dependency CVEs only
- `--all`: Run all security checks (default)
- `--severity <level>`: Minimum severity to report (critical, high, medium, low)
- `--path <directory>`: Target directory (default: current)

## Workflow

### Step 1: Secret Detection

Scan for high-confidence patterns:

```bash
# AWS Keys
grep -rn "AKIA[0-9A-Z]{16}" --include="*.ts" --include="*.py" --include="*.env*" \
  --exclude-dir={node_modules,.git} .

# GitHub Tokens
grep -rn "ghp_[A-Za-z0-9_]{36}" --include="*" --exclude-dir={node_modules,.git} .

# Generic Secrets
grep -rn -E "(password|secret|api_key|token)\s*[=:]\s*['\"][^'\"]{8,}['\"]" \
  --include="*.ts" --include="*.py" --include="*.json" .

# Private Keys
grep -rn "BEGIN.*PRIVATE KEY" --include="*.pem" --include="*.key" --include="*" .

# Connection Strings
grep -rn -E "(mongodb|postgres|mysql|redis)://[^:]+:[^@]+@" --include="*" .
```

### Step 2: OWASP Pattern Detection

```bash
# SQL Injection
grep -rn -E "(query|execute)\s*\([^)]*\+" --include="*.ts" --include="*.py" .
grep -rn -E "cursor\.execute\s*\(\s*f['\"]" --include="*.py" .

# Command Injection
grep -rn -E "(exec|system|popen|spawn)\s*\([^)]*(\$|%|\+)" --include="*.ts" --include="*.py" .

# XSS
grep -rn "innerHTML\s*=" --include="*.ts" --include="*.tsx" .
grep -rn "dangerouslySetInnerHTML" --include="*.tsx" --include="*.jsx" .

# Path Traversal
grep -rn -E "\.\.\/" --include="*.ts" --include="*.py" .
```

### Step 3: CVE Analysis

Run appropriate audit based on detected package manager:

```bash
# Node.js
npm audit --json 2>/dev/null

# Python
pip-audit --format json 2>/dev/null || safety check --json 2>/dev/null

# Go
govulncheck ./... 2>/dev/null

# Rust
cargo audit --json 2>/dev/null
```

### Step 4: Sensitive File Check

```bash
# Find sensitive files that shouldn't be committed
find . -name "*.env" -o -name "*.pem" -o -name "*.key" \
  -o -name "credentials*" -o -name "secrets*" \
  | grep -v node_modules | grep -v .git

# Check if .env is in .gitignore
grep -q "\.env" .gitignore 2>/dev/null || echo "WARNING: .env not in .gitignore"
```

## Output Format

```
SECURITY SCAN RESULTS
=====================

Security Score: [X]/100
Risk Level: [CRITICAL/HIGH/MEDIUM/LOW]

SECRETS DETECTED: [count]
┌────────────────────────┬────────────┬─────────────────────┐
│ Location               │ Type       │ Pattern             │
├────────────────────────┼────────────┼─────────────────────┤
│ src/config.ts:23       │ API Key    │ sk_live_****        │
│ .env.production:5      │ DB Pass    │ postgres://****     │
└────────────────────────┴────────────┴─────────────────────┘

VULNERABILITY PATTERNS: [count]
1. [HIGH] SQL Injection - src/db/users.ts:45
   Pattern: String concatenation in query
   Fix: Use parameterized queries

2. [MEDIUM] XSS Risk - src/components/Profile.tsx:89
   Pattern: innerHTML assignment
   Fix: Use textContent or sanitize input

DEPENDENCY CVES: [count]
| Package | CVE | Severity | CVSS | Fix Version |
|---------|-----|----------|------|-------------|
| minimist | CVE-2021-44906 | Critical | 9.8 | 1.2.6 |

SENSITIVE FILES:
- .env (not in .gitignore!)
- config/secrets.json

RECOMMENDATIONS:
1. [CRITICAL] Move all hardcoded secrets to environment variables
2. [HIGH] Update minimist to fix CVE-2021-44906
3. [HIGH] Use parameterized queries in src/db/users.ts

Fix security issues: /code-health:fix --security
```

## Example Usage

```
/code-health:security
/code-health:security --secrets
/code-health:security --severity high
/code-health:security --owasp --cves
```
