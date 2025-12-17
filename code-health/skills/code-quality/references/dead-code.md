# Dead Code Detection

Techniques for finding and safely removing dead code.

## Types of Dead Code

### 1. Unreachable Code

Code that can never be executed.

**Patterns:**
```typescript
// After return
function example() {
  return value;
  console.log("never runs");  // Dead
}

// After throw
function validate(x) {
  if (!x) {
    throw new Error("Invalid");
    cleanup();  // Dead
  }
}

// Impossible conditions
if (false) {
  // Dead
}

if (typeof x === "string" && typeof x === "number") {
  // Dead - impossible condition
}
```

**Detection:**
```bash
# ESLint rule
npx eslint --rule 'no-unreachable: error' src/

# TypeScript compiler
tsc --noEmit --allowUnreachableCode false
```

### 2. Unused Variables

Variables declared but never read.

**Patterns:**
```typescript
const unused = compute();  // Never used
let x = 1;
x = 2;  // Only written, never read

function example(unusedParam) {  // Parameter not used
  return 42;
}
```

**Detection:**
```bash
# ESLint
npx eslint --rule 'no-unused-vars: error' src/

# TypeScript
tsc --noUnusedLocals --noUnusedParameters
```

### 3. Unused Functions/Methods

Defined but never called.

**Detection:**
```bash
# TypeScript - find unused exports
npx ts-prune

# Manual search
grep -rn "function unusedFunc" .  # Find definition
grep -rn "unusedFunc(" .           # Find calls
```

### 4. Unused Exports

Exported but never imported elsewhere.

**Detection:**
```bash
# ts-prune (TypeScript)
npx ts-prune

# Manual verification
# 1. Find all exports
grep -rh "^export " src/ | grep -oP "(?<=export (const|function|class|interface|type) )\w+"

# 2. For each export, check imports
grep -rn "import.*{.*exportName.*}" src/
```

### 5. Unused Dependencies

Installed but never imported.

**Detection:**
```bash
# JavaScript/TypeScript
npx depcheck

# Python
pip-extra-reqs .  # Or manually check imports vs requirements.txt
```

### 6. Commented-Out Code

Code preserved in comments but no longer used.

**Patterns:**
```typescript
// function oldImplementation() {
//   return deprecated();
// }

/*
class RemovedFeature {
  ...
}
*/
```

**Detection:**
```bash
# Find large comment blocks
grep -n "^[[:space:]]*//" *.ts | wc -l

# Find multi-line comments with code patterns
grep -Pzo "(?s)/\*.*?(function|class|const|let|var|if|for|while).*?\*/" *.ts
```

### 7. Orphan Files

Files not imported by any other file.

**Detection:**
```bash
# JavaScript/TypeScript - using madge
npx madge --orphans src/

# Manual approach
# 1. List all source files
find src -name "*.ts" > all_files.txt

# 2. For each file, check if imported
for f in $(cat all_files.txt); do
  basename=$(basename "$f" .ts)
  if ! grep -rq "from.*$basename" src/; then
    echo "Orphan: $f"
  fi
done
```

## Safe Removal Process

### Step 1: Verify It's Actually Dead

```bash
# Search for all references
grep -rn "symbolName" --include="*.ts" --include="*.tsx" .

# Check dynamic references
grep -rn "symbolName" --include="*.ts" | grep -E "(require|import|eval|\[)"

# Check configuration files
grep -rn "symbolName" --include="*.json" --include="*.yaml" .
```

### Step 2: Consider Edge Cases

**False Positives to Watch For:**

1. **Dynamic Imports**
   ```typescript
   const module = await import(`./handlers/${type}`);
   ```

2. **Reflection-Based Access**
   ```typescript
   obj[methodName]();
   ```

3. **Entry Points**
   - Main files
   - CLI commands
   - API endpoints
   - Event handlers

4. **Test Utilities**
   - Test helpers only used in tests
   - Mocks and fixtures

5. **Type-Only Exports**
   ```typescript
   export type { MyType };  // Used for type checking only
   ```

6. **Public API**
   - Library exports for consumers
   - SDK methods

### Step 3: Remove Incrementally

```bash
# 1. Create a branch
git checkout -b remove-dead-code

# 2. Remove one item at a time
# 3. Run tests after each removal
npm test

# 4. Commit each successful removal
git commit -m "Remove unused function: oldHelper"

# 5. Continue until all dead code removed
```

### Step 4: Verify No Regressions

```bash
# Run full test suite
npm test

# Run type checking
tsc --noEmit

# Run linting
npm run lint

# Build the project
npm run build
```

## Automation Tools

### JavaScript/TypeScript

| Tool | Purpose | Command |
|------|---------|---------|
| ts-prune | Unused exports | `npx ts-prune` |
| depcheck | Unused deps | `npx depcheck` |
| madge | Orphan files | `npx madge --orphans src/` |
| ESLint | Unused vars | `npx eslint --rule 'no-unused-vars: error'` |

### Python

| Tool | Purpose | Command |
|------|---------|---------|
| vulture | Dead code | `vulture src/` |
| autoflake | Unused imports | `autoflake --remove-all-unused-imports` |
| pip-extra-reqs | Unused deps | `pip-extra-reqs .` |

### Go

| Tool | Purpose | Command |
|------|---------|---------|
| staticcheck | Dead code | `staticcheck ./...` |
| deadcode | Unused code | `deadcode ./...` |

## Metrics

### Dead Code Ratio

```
Dead Code % = (dead lines / total lines) * 100

Healthy: < 5%
Warning: 5-15%
Critical: > 15%
```

### Cleanup Impact

Track before/after:
- Lines of code
- Bundle size
- Build time
- Test coverage %
