---
name: scan
description: Run a comprehensive codebase health scan with security, debt, and dependency analysis
argument-hint: "[--mode quick|deep] [--focus security|debt|deps|all]"
allowed-tools: ["Read", "Grep", "Glob", "Bash"]
---

# Health Scan Command

Run a comprehensive health analysis of your codebase covering security vulnerabilities, technical debt, and dependency health.

## Arguments

- `--mode <quick|deep>`: Scan depth (default: quick)
  - **quick**: Top 5 issues per category, letter grade, summary view
  - **deep**: All issues with full details and fix recommendations
- `--focus <area>`: Focus on specific area
  - **security**: Only security analysis
  - **debt**: Only technical debt analysis
  - **deps**: Only dependency analysis
  - **all**: All categories (default)
- `--path <directory>`: Target directory (default: current working directory)

## Workflow

### Step 1: Detect Project Type

Identify the project ecosystem by checking for:
- `package.json` - Node.js/npm
- `requirements.txt` or `pyproject.toml` - Python
- `go.mod` - Go
- `Cargo.toml` - Rust
- `composer.json` - PHP

Also detect primary languages by file extensions.

### Step 2: Run Security Analysis

1. **Secret Detection**
   ```bash
   grep -rn -E "(AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{36}|sk_live_|password\s*[=:])" \
     --include="*.ts" --include="*.js" --include="*.py" --include="*.env*" \
     --exclude-dir={node_modules,.git,vendor} .
   ```

2. **OWASP Patterns**
   ```bash
   grep -rn -E "(query\s*\([^)]*\+|innerHTML\s*=|exec\s*\([^)]*\$)" \
     --include="*.ts" --include="*.py" .
   ```

3. **CVE Check**
   ```bash
   npm audit --json 2>/dev/null || pip-audit --format json 2>/dev/null
   ```

### Step 3: Run Debt Analysis

1. **File Complexity**
   ```bash
   find . -name "*.ts" -o -name "*.py" | xargs wc -l | sort -rn | head -10
   ```

2. **TODO/FIXME Count**
   ```bash
   grep -rn "TODO\|FIXME\|HACK" --include="*.ts" --include="*.py" . | wc -l
   ```

3. **Code Smells**
   - Files over 500 lines
   - Circular dependencies (if madge available)

### Step 4: Run Dependency Analysis

1. **Outdated Packages**
   ```bash
   npm outdated --json 2>/dev/null || pip list --outdated --format json 2>/dev/null
   ```

2. **Unused Dependencies**
   ```bash
   npx depcheck 2>/dev/null
   ```

### Step 5: Calculate Health Score

```
Security Score = 100 - (critical * 15 + high * 10 + medium * 3 + low * 1)
Debt Score = 100 - (god_files * 5 + ancient_todos * 1 + circular_deps * 8)
Deps Score = 100 - (major_outdated * 3 + cves * 10 + unused * 2)

Overall = (Security * 0.4) + (Debt * 0.3) + (Deps * 0.3)

Grade: A (90+), B (80-89), C (70-79), D (60-69), F (<60)
```

## Quick Mode Output

```
CODE HEALTH SCAN
================

Project: [name]
Scanned: [X] files, [Y] lines

┌────────────────────────────────────────────────────┐
│                    HEALTH GRADE                     │
│                                                     │
│                        [A-F]                        │
│                     [XX]/100                        │
│                                                     │
│   Security: [X]   Debt: [X]   Dependencies: [X]   │
└────────────────────────────────────────────────────┘

TOP 5 ISSUES:
1. [SEVERITY] Issue description - file:line
2. ...

Run `/code-health:scan --mode deep` for full report.
```

## Deep Mode Output

Full markdown report with:
- Executive summary
- Detailed findings by category
- All issues with severity and fix recommendations
- Prioritized action items

## Example Usage

```
/code-health:scan
/code-health:scan --mode deep
/code-health:scan --focus security
/code-health:scan --path ./backend --mode deep
```
