---
name: Code Quality Patterns
description: This skill activates when the user asks about "code quality", "complexity", "maintainability", "code smells", "refactoring", "clean code", "technical debt metrics", "cyclomatic complexity", "dead code", "duplicate code", "TODO comments", or needs to measure and improve code quality.
version: 1.0.0
---

# Code Quality Patterns

Comprehensive guidance for measuring code quality using language-agnostic metrics and patterns.

## Complexity Metrics

| Metric | Description | Warning | Critical |
|--------|-------------|---------|----------|
| Lines of Code (LOC) | File size | >500 | >1000 |
| Function Length | Lines per function | >50 | >100 |
| Nesting Depth | Max indent levels | >4 | >6 |
| Cyclomatic Complexity | Decision points + 1 | >10 | >20 |
| Parameter Count | Function arguments | >5 | >8 |

### Calculating Cyclomatic Complexity

Count these constructs and add 1:
- `if`, `elif`, `else if`
- `for`, `while`, `do`
- `case` (each case)
- `catch`, `except`
- `&&`, `||`, `and`, `or`
- Ternary operators `?:`

## Code Smell Catalog

| Smell | Detection | Impact | Fix |
|-------|-----------|--------|-----|
| God File | >500 lines, many responsibilities | High | Split by responsibility |
| Long Method | >50 lines | High | Extract methods |
| Long Parameter List | >5 parameters | Medium | Parameter object |
| Feature Envy | Many external calls | Medium | Move method |
| Data Clumps | Repeated field groups | Medium | Extract class |
| Primitive Obsession | Overuse of primitives | Low | Value objects |
| Deep Nesting | >4 indent levels | Medium | Guard clauses, extract |
| Circular Dependencies | A imports B, B imports A | High | Extract common module |

### Detection Patterns

**God File:**
```bash
# Find large files
wc -l $(find . -name "*.ts" -o -name "*.py") | sort -rn | head -20
```

**Circular Dependencies:**
```bash
# JS/TS - use madge
npx madge --circular src/

# Python - use pydeps
pydeps --show-cycles src/
```

## Dead Code Detection

### Types of Dead Code

1. **Unreachable Code**: After return/throw/break
2. **Unused Variables**: Declared but never read
3. **Unused Functions**: Defined but never called
4. **Unused Exports**: Exported but never imported
5. **Commented Code**: Large commented blocks
6. **Orphan Files**: Files not imported anywhere

### Detection Strategies

**Unused Exports (JS/TS):**
```bash
# Find exports
grep -rh "^export" src/ | grep -oP "(?<=export (const|function|class|interface|type) )\w+"

# Check for imports of each export
# If no imports found, likely unused
```

**Commented Code:**
```regex
# Multi-line comments with code patterns
/\*[\s\S]*?(function|class|const|let|var|if|for|while)[\s\S]*?\*/

# Large comment blocks (>5 lines)
(^[ \t]*//.*\n){5,}
```

## TODO/FIXME Tracking

### Pattern Detection
```regex
(TODO|FIXME|HACK|XXX|BUG|OPTIMIZE)[\s:]+(.*)
```

### Age Analysis with Git
```bash
# Get TODO with blame info
grep -rn "TODO\|FIXME\|HACK" --include="*.ts" . | while read line; do
  file=$(echo "$line" | cut -d: -f1)
  linenum=$(echo "$line" | cut -d: -f2)
  git blame -L "$linenum,$linenum" "$file" 2>/dev/null | cut -d'(' -f2 | cut -d' ' -f1-3
done
```

### Staleness Categories

| Age | Category | Priority |
|-----|----------|----------|
| <30 days | Fresh | Low |
| 30-90 days | Stale | Medium |
| >90 days | Ancient | High |

## Duplicate Code Detection

### Simple Hash-Based Detection
1. Normalize code (remove whitespace, comments)
2. Create sliding window of N lines
3. Hash each window
4. Group by hash
5. Windows with same hash are duplicates

### Clone Types

| Type | Description | Detection |
|------|-------------|-----------|
| Type 1 | Identical except whitespace | Hash matching |
| Type 2 | Same structure, different names | Normalized hash |
| Type 3 | Similar with modifications | Fuzzy matching |

## Quality Score Formula

```
Base Score = 100

Deductions:
- Per god file (>500 lines): -5
- Per critical complexity file: -3
- Per circular dependency: -8
- Per ancient TODO: -1
- Per 1% duplication: -2
- Per unused export: -0.25
- Per deep nesting instance: -1

Grade = max(0, Base Score - Deductions)

A: 90-100, B: 80-89, C: 70-79, D: 60-69, F: <60
```

## Reference Files

- `references/complexity-metrics.md` - Detailed metric calculations
- `references/code-smells.md` - Extended smell catalog
- `references/dead-code.md` - Dead code detection techniques
