# Complexity Metrics Reference

Detailed guide for calculating code complexity metrics across languages.

## Lines of Code (LOC)

### Counting Methods

| Method | Description | Use Case |
|--------|-------------|----------|
| Physical LOC | All lines including blanks | File size |
| Logical LOC | Executable statements | Complexity |
| Source LOC | Non-blank, non-comment | Comparison |

### Measurement Commands

```bash
# Physical LOC per file
wc -l $(find . -name "*.ts" -o -name "*.py" -o -name "*.go") | sort -rn

# Source LOC (excluding blanks and comments) - using cloc
cloc --by-file --include-lang=TypeScript,Python,Go .

# Simple SLOC approximation
find . -name "*.ts" -exec grep -cve '^\s*$' {} + | sort -t: -k2 -rn
```

### Thresholds by File Type

| File Type | Warning | Critical | Notes |
|-----------|---------|----------|-------|
| Component | 300 | 500 | UI components should be focused |
| Service | 400 | 700 | Business logic files |
| Utility | 200 | 400 | Helper functions |
| Test | 500 | 1000 | Tests can be longer |
| Config | 100 | 200 | Config should be minimal |

## Function/Method Length

### Counting Rules

- Count from signature to closing brace
- Include blank lines within function
- Exclude leading comments/docstrings

### Detection by Language

**JavaScript/TypeScript:**
```regex
# Function declarations
(function\s+\w+|const\s+\w+\s*=\s*(async\s+)?\([^)]*\)\s*=>|\w+\s*\([^)]*\)\s*\{)
```

**Python:**
```regex
# Function definitions
^\s*def\s+\w+\s*\([^)]*\)\s*:
```

**Go:**
```regex
# Function declarations
^func\s+(\([^)]+\)\s+)?\w+\s*\([^)]*\)
```

### Ideal Function Sizes

| Guideline | Lines | Rationale |
|-----------|-------|-----------|
| Ideal | 10-20 | Fits on screen, easy to understand |
| Acceptable | 20-50 | May need splitting |
| Warning | 50-100 | Should be refactored |
| Critical | >100 | Must be refactored |

## Nesting Depth

### What Counts as Nesting

- `if/else` blocks
- `for/while/do` loops
- `try/catch/finally` blocks
- `switch/case` statements
- Lambda/arrow functions
- Callbacks

### Detection Pattern

```bash
# Approximate nesting by indentation
awk '{
  gsub(/\t/, "    ");
  match($0, /^ */);
  depth = RLENGTH / 4;
  if (depth > max) max = depth
} END { print "Max depth:", max }' file.ts
```

### Reducing Nesting

1. **Early Returns (Guard Clauses)**
```typescript
// Before
function process(data) {
  if (data) {
    if (data.valid) {
      if (data.items.length > 0) {
        // logic
      }
    }
  }
}

// After
function process(data) {
  if (!data) return;
  if (!data.valid) return;
  if (data.items.length === 0) return;
  // logic
}
```

2. **Extract Methods**
3. **Replace Conditional with Polymorphism**

## Cyclomatic Complexity

### Formula

```
CC = E - N + 2P

Where:
E = Number of edges in control flow graph
N = Number of nodes
P = Number of connected components (usually 1)
```

### Simplified Counting

```
CC = 1 + (number of decision points)

Decision points:
- if, elif, else if
- for, while, do-while
- case (each case label)
- catch, except
- &&, ||, and, or
- ?: (ternary)
- ?? (nullish coalescing)
```

### Example

```typescript
function example(a, b, c) {  // Base: 1
  if (a > 0) {               // +1 = 2
    for (let i = 0; i < b; i++) {  // +1 = 3
      if (c || a > 10) {     // +2 (if + ||) = 5
        // ...
      }
    }
  } else if (b < 0) {        // +1 = 6
    // ...
  }
  return a && b;             // +1 (&&) = 7
}
// Total CC = 7
```

### Thresholds

| CC | Risk | Action |
|----|------|--------|
| 1-10 | Low | Well-structured |
| 11-20 | Moderate | Consider refactoring |
| 21-50 | High | Refactoring needed |
| >50 | Very High | Untestable, must refactor |

## Cognitive Complexity

More intuitive than cyclomatic complexity, penalizes nesting.

### Counting Rules

1. **Increment for:**
   - `if`, `else if`, `else`
   - `switch`
   - `for`, `while`, `do-while`
   - `catch`
   - `goto`, `break`/`continue` to label
   - Sequences of binary operators
   - Each recursion

2. **Nesting Penalty:**
   - Add +1 for each level of nesting when incrementing

### Example

```typescript
function example(a, b) {
  if (a) {                    // +1 (if)
    for (let i = 0; i < b; i++) {  // +2 (for + nesting)
      if (a > i) {            // +3 (if + 2 nesting levels)
        // ...
      }
    }
  }
}
// Total Cognitive Complexity = 6
```

## Parameter Count

### Why It Matters

- More parameters = harder to understand
- More parameters = more combinations to test
- Often indicates function doing too much

### Solutions

1. **Parameter Object**
```typescript
// Before
function createUser(name, email, age, role, department, manager) {}

// After
function createUser(options: CreateUserOptions) {}
```

2. **Builder Pattern**
3. **Split into multiple functions**

## Aggregate Metrics

### File Health Score

```
File Score = 100 - (
  (LOC > 500 ? 10 : 0) +
  (max_function_length > 50 ? 5 : 0) +
  (max_nesting > 4 ? 5 : 0) +
  (avg_cc > 10 ? 10 : 0) +
  (param_count_violations * 2)
)
```

### Project Health Score

```
Project Score = average(all file scores)
```
