---
name: fix
description: Auto-fix common issues found during health scans
argument-hint: "[--security] [--debt] [--deps] [--all] [--dry-run]"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

# Auto-Fix Command

Apply automated fixes for issues found during health scans. Supports dry-run mode for preview.

## Arguments

- `--security`: Fix security issues (externalize secrets, parameterize queries)
- `--debt`: Fix technical debt (remove dead code, unused imports)
- `--deps`: Fix dependency issues (update vulnerable packages, remove unused)
- `--all`: Apply all safe fixes
- `--dry-run`: Preview changes without applying them
- `--interactive`: Confirm each fix before applying
- `--path <directory>`: Target directory (default: current)

## Fix Categories

### Security Fixes (--security)

**Safe to Auto-Fix:**
- Move hardcoded secrets to environment variables
- Add `.env` to `.gitignore`
- Update packages with critical CVEs

**Requires Review:**
- Parameterize SQL queries
- Add input sanitization

### Debt Fixes (--debt)

**Safe to Auto-Fix:**
- Remove unused imports
- Delete commented-out code blocks
- Remove empty files

**Requires Review:**
- Remove unused exports
- Delete orphan files

### Dependency Fixes (--deps)

**Safe to Auto-Fix:**
- Update packages with security fixes (patch/minor)
- Remove unused dependencies

**Requires Review:**
- Major version updates

## Workflow

### Step 1: Pre-Flight Checks

```bash
# Check git status
git status --porcelain

# Warn if uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo "WARNING: Uncommitted changes detected"
fi
```

### Step 2: Apply Fixes by Priority

**Priority Order:**
1. Security fixes (highest priority)
2. Dependency security updates
3. Dead code removal
4. Unused dependency removal

### Step 3: Apply Each Fix

**Secret Externalization:**
```diff
// Before
- const API_KEY = "sk_live_abc123";
+ const API_KEY = process.env.API_KEY;
```

Create `.env.example` if needed:
```
API_KEY=your_api_key_here
```

Update `.gitignore`:
```
.env
.env.local
.env.*.local
```

**Remove Unused Imports:**
```diff
- import { used, unused } from 'module';
+ import { used } from 'module';
```

**Remove Commented Code:**
```diff
- // function oldCode() {
- //   return deprecated();
- // }
```

**Update Vulnerable Dependencies:**
```bash
npm update minimist  # CVE fix
```

**Remove Unused Dependencies:**
```bash
npm uninstall unused-package
```

### Step 4: Verify Changes

After each fix:
1. Check file syntax is valid
2. Run linter if available
3. Run tests if specified

### Step 5: Report Results

## Output Format (Dry Run)

```
AUTO-FIX PREVIEW (--dry-run)
============================

SECURITY FIXES:
✓ Would move 2 secrets to environment variables
  - src/config.ts:23 (API_KEY)
  - src/db.ts:5 (DB_PASSWORD)
✓ Would add .env to .gitignore
✓ Would update 1 package with CVE fix
  - minimist: 1.2.5 -> 1.2.6

DEBT FIXES:
✓ Would remove 23 unused imports across 8 files
✓ Would delete 156 lines of commented code in 5 files
✓ Would remove 3 unused exports

DEPENDENCY FIXES:
✓ Would remove 4 unused packages
  - moment, underscore, request, debug

Summary:
- Files to modify: 12
- Lines to remove: 180
- Lines to add: 15
- Packages to update: 1
- Packages to remove: 4

Run without --dry-run to apply changes.
```

## Output Format (Applied)

```
AUTO-FIX RESULTS
================

Applied Fixes:
✓ Moved 2 secrets to environment variables
✓ Added .env to .gitignore
✓ Updated minimist (CVE-2021-44906 fix)
✓ Removed 23 unused imports
✓ Deleted 156 lines of commented code
✓ Removed 4 unused packages

Changes by File:
┌─────────────────────────┬──────────┬──────────┬─────────────────────┐
│ File                    │ Adds     │ Removes  │ Description         │
├─────────────────────────┼──────────┼──────────┼─────────────────────┤
│ src/config.ts           │ +2       │ -2       │ Externalized secrets│
│ src/db.ts               │ +1       │ -1       │ Externalized secrets│
│ src/utils/helpers.ts    │ 0        │ -45      │ Removed dead code   │
│ .gitignore              │ +3       │ 0        │ Added .env patterns │
│ .env.example            │ +2       │ 0        │ Created template    │
└─────────────────────────┴──────────┴──────────┴─────────────────────┘

Health Score Impact:
Before: C (72/100)
After:  B (85/100)
Improvement: +13 points

Remaining Manual Items:
1. Review SQL queries in src/db/users.ts for injection risks
2. Consider splitting src/api/handler.ts (847 lines)

Next steps:
- Review changes: git diff
- Run tests: npm test
- Commit: git add . && git commit -m "chore: apply code health fixes"
```

## Example Usage

```
/code-health:fix --dry-run
/code-health:fix --security
/code-health:fix --debt
/code-health:fix --all
/code-health:fix --interactive
```
