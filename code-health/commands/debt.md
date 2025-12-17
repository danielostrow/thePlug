---
name: debt
description: Analyze technical debt, code complexity, and quality issues
argument-hint: "[--complexity] [--todos] [--smells] [--duplicates] [--dead-code]"
allowed-tools: ["Read", "Grep", "Glob", "Bash"]
---

# Technical Debt Command

Analyze technical debt and code quality issues in your codebase.

## Arguments

- `--complexity`: Focus on complexity metrics (file size, nesting, function length)
- `--todos`: Focus on TODO/FIXME/HACK comment tracking with age analysis
- `--smells`: Focus on code smell detection (god files, circular deps)
- `--duplicates`: Focus on duplicate code detection
- `--dead-code`: Focus on unused code detection
- `--all`: Run all analyses (default)
- `--path <directory>`: Target directory (default: current)

## Workflow

### Step 1: Complexity Analysis

**File Size:**
```bash
# Find all source files and count lines
find . -name "*.ts" -o -name "*.py" -o -name "*.go" \
  | grep -v node_modules | grep -v .git \
  | xargs wc -l 2>/dev/null | sort -rn | head -20
```

**Identify Hotspots:**
- Files > 500 lines: Warning
- Files > 1000 lines: Critical

### Step 2: TODO/FIXME Archaeology

**Find all TODO comments:**
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|BUG" \
  --include="*.ts" --include="*.py" --include="*.go" \
  --exclude-dir={node_modules,.git,vendor} .
```

**Age analysis with git:**
```bash
# For each TODO, get the commit date
git blame -L <line>,<line> <file> 2>/dev/null | \
  awk -F'[()]' '{print $2}' | cut -d' ' -f1-3
```

**Categories:**
- Fresh: < 30 days old
- Stale: 30-90 days old
- Ancient: > 90 days old

### Step 3: Code Smell Detection

**God Files (>500 lines):**
```bash
wc -l $(find . -name "*.ts" -o -name "*.py" 2>/dev/null) | \
  awk '$1 > 500 {print}' | sort -rn
```

**Circular Dependencies:**
```bash
# For JS/TS projects
npx madge --circular src/ 2>/dev/null
```

**Long Functions:**
- Functions > 50 lines: Warning
- Functions > 100 lines: Critical

### Step 4: Duplicate Code Detection

```bash
# Use jscpd for JS/TS projects
npx jscpd --min-lines 5 --reporters console src/ 2>/dev/null
```

### Step 5: Dead Code Detection

**Unused Exports:**
```bash
npx ts-prune 2>/dev/null
```

**Orphan Files:**
```bash
npx madge --orphans src/ 2>/dev/null
```

**Commented Code:**
```bash
# Count lines of commented code
grep -rn "^[[:space:]]*//" --include="*.ts" . | wc -l
```

## Debt Score Calculation

```
Base Score = 100

Deductions:
- God file (>500 lines): -5 each
- God file (>1000 lines): -10 each
- Circular dependency: -8 each
- Ancient TODO (>90 days): -1 each
- Stale TODO (30-90 days): -0.5 each
- Duplicate block: -1.5 each
- Unused export: -0.25 each

Grade = max(0, Base Score - Deductions)
```

## Output Format

```
TECHNICAL DEBT REPORT
=====================

Debt Score: [Grade] ([X]/100)
Files Analyzed: [count]
Total Lines: [count]

COMPLEXITY HOTSPOTS:
┌─────────────────────────┬───────┬────────────┬─────────────┐
│ File                    │ Lines │ Max Depth  │ Status      │
├─────────────────────────┼───────┼────────────┼─────────────┤
│ src/api/handler.ts      │ 847   │ 6          │ Critical    │
│ src/utils/helpers.py    │ 623   │ 5          │ Warning     │
└─────────────────────────┴───────┴────────────┴─────────────┘

TODO ARCHAEOLOGY:
Found: [X] comments
- Ancient (>90 days): [Y]
- Stale (30-90 days): [Z]
- Fresh (<30 days): [W]

Oldest TODOs:
1. src/auth.ts:45 - "TODO: implement refresh tokens" (2 years, @jsmith)
2. src/db.py:123 - "FIXME: race condition" (8 months, @mjones)

CODE SMELLS: [count]
1. God File: src/api/handler.ts (847 lines)
   Recommendation: Split by responsibility

2. Circular Dependency: src/a.ts <-> src/b.ts
   Recommendation: Extract common module

DUPLICATE CODE: [X]% duplication
- [Y] significant duplicate blocks found

DEAD CODE:
- [X] unused exports
- [Y] orphan files
- [Z] lines of commented code

PRIORITIZED IMPROVEMENTS:
1. Refactor src/api/handler.ts (High impact)
2. Resolve circular dependency (High impact)
3. Address ancient TODOs (Medium impact)
4. Remove dead code (Low impact)
```

## Example Usage

```
/code-health:debt
/code-health:debt --todos
/code-health:debt --complexity --smells
/code-health:debt --dead-code
```
