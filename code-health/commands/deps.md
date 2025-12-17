---
name: deps
description: Audit dependencies for updates, security vulnerabilities, and license issues
argument-hint: "[--outdated] [--cves] [--licenses] [--unused] [--update]"
allowed-tools: ["Read", "Grep", "Glob", "Bash"]
---

# Dependency Audit Command

Analyze project dependencies for outdated packages, security vulnerabilities, license compliance, and unused packages.

## Arguments

- `--outdated`: Focus on outdated package detection
- `--cves`: Focus on security vulnerabilities
- `--licenses`: Focus on license compliance checking
- `--unused`: Focus on unused dependency detection
- `--all`: Run all checks (default)
- `--update`: Show update commands for each issue
- `--path <directory>`: Target directory (default: current)

## Workflow

### Step 1: Detect Package Manager

Check for package manager files:

| File | Package Manager | Ecosystem |
|------|-----------------|-----------|
| package.json | npm/yarn/pnpm | Node.js |
| package-lock.json | npm | Node.js |
| yarn.lock | yarn | Node.js |
| pnpm-lock.yaml | pnpm | Node.js |
| requirements.txt | pip | Python |
| pyproject.toml | poetry/pip | Python |
| Pipfile | pipenv | Python |
| go.mod | go modules | Go |
| Cargo.toml | cargo | Rust |
| Gemfile | bundler | Ruby |
| composer.json | composer | PHP |

### Step 2: Check Outdated Packages

**Node.js:**
```bash
npm outdated --json 2>/dev/null
```

**Python:**
```bash
pip list --outdated --format json 2>/dev/null
```

**Go:**
```bash
go list -u -m -json all 2>/dev/null | jq -s '.'
```

**Rust:**
```bash
cargo outdated --format json 2>/dev/null
```

### Step 3: Security Audit

**Node.js:**
```bash
npm audit --json 2>/dev/null
```

**Python:**
```bash
pip-audit --format json 2>/dev/null
# or
safety check --json 2>/dev/null
```

**Go:**
```bash
govulncheck ./... 2>/dev/null
```

**Rust:**
```bash
cargo audit --json 2>/dev/null
```

### Step 4: License Check

**Node.js:**
```bash
npx license-checker --json 2>/dev/null
```

**License Risk Levels:**
| License | Risk | Notes |
|---------|------|-------|
| MIT, Apache-2.0, BSD | Low | Permissive |
| ISC, Unlicense | Low | Permissive |
| GPL-2.0, GPL-3.0 | Medium | Copyleft - review |
| LGPL | Medium | Library use OK |
| AGPL | High | Network copyleft |
| Unknown | High | Investigate |

### Step 5: Unused Dependencies

**Node.js:**
```bash
npx depcheck 2>/dev/null
```

**Manual verification:**
```bash
# List dependencies
jq '.dependencies + .devDependencies | keys[]' package.json

# Check for imports
grep -rh "from ['\"]" src/ | grep -oP "(?<=from ['\"])[^'\"./]+"
```

## Output Format

```
DEPENDENCY AUDIT
================

Package Manager: npm
Total Dependencies: [X] ([Y] prod, [Z] dev)
Health Score: [Grade] ([X]/100)

OUTDATED PACKAGES: [count]
┌─────────────────────┬─────────────┬─────────────┬──────────┬──────────┐
│ Package             │ Current     │ Latest      │ Gap      │ Severity │
├─────────────────────┼─────────────┼─────────────┼──────────┼──────────┤
│ react               │ 17.0.2      │ 18.2.0      │ Major    │ Medium   │
│ lodash              │ 4.17.20     │ 4.17.21     │ Patch    │ Low      │
│ express             │ 4.17.1      │ 4.18.2      │ Minor    │ Low      │
└─────────────────────┴─────────────┴─────────────┴──────────┴──────────┘

SECURITY VULNERABILITIES: [count]
| Package | CVE | Severity | CVSS | Fixed In |
|---------|-----|----------|------|----------|
| minimist | CVE-2021-44906 | Critical | 9.8 | 1.2.6 |
| node-fetch | CVE-2022-0235 | High | 8.1 | 2.6.7 |

LICENSE ANALYSIS:
✓ MIT: 35 packages
✓ Apache-2.0: 7 packages
✓ ISC: 5 packages
⚠ GPL-3.0: 2 packages (review required)
  - package-a
  - package-b
✗ Unknown: 1 package (investigate)
  - mysterious-pkg

UNUSED DEPENDENCIES: [count]
- moment (not imported anywhere)
- underscore (superseded by lodash)
- request (deprecated, not used)

RECOMMENDATIONS:
1. [CRITICAL] npm update minimist - fix CVE-2021-44906
2. [HIGH] npm update node-fetch - fix CVE-2022-0235
3. [MEDIUM] Review GPL-3.0 packages for license compliance
4. [LOW] npm uninstall moment underscore request

UPDATE COMMANDS:
# Security fixes
npm update minimist node-fetch

# Remove unused
npm uninstall moment underscore request

# Update all (review changelogs first)
npm update
```

## Example Usage

```
/code-health:deps
/code-health:deps --outdated
/code-health:deps --cves --update
/code-health:deps --licenses
/code-health:deps --unused
```
