# Code Smell Catalog

Extended catalog of code smells with detection patterns and refactoring strategies.

## Bloaters

Code that has grown too large to handle effectively.

### God Class / God File

**Symptoms:**
- >500 lines of code
- >20 methods/functions
- Multiple unrelated responsibilities
- High coupling to many other classes

**Detection:**
```bash
# Find large files
find . -name "*.ts" -exec wc -l {} + | sort -rn | head -20

# Count functions per file
grep -c "function\|const.*=.*=>" file.ts
```

**Refactoring:**
1. Identify distinct responsibilities
2. Group related methods/data
3. Extract each group to its own class
4. Use composition in original

### Long Method

**Symptoms:**
- >50 lines
- Multiple levels of abstraction
- Many local variables
- Comments explaining sections

**Detection:**
```regex
# Find function boundaries and count lines between
(function|const\s+\w+\s*=|^\s*\w+\s*\([^)]*\)\s*\{)
```

**Refactoring:**
1. Extract Method for each logical section
2. Replace Temp with Query
3. Introduce Parameter Object
4. Decompose Conditional

### Long Parameter List

**Symptoms:**
- >5 parameters
- Multiple boolean flags
- Parameters that often travel together

**Detection:**
```regex
# Functions with many parameters
function\s+\w+\s*\([^)]{100,}\)
\w+\s*\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,
```

**Refactoring:**
1. Introduce Parameter Object
2. Preserve Whole Object
3. Replace Parameter with Method Call

## Object-Orientation Abusers

### Switch Statements (Type Checking)

**Symptoms:**
- Switch on type field
- Same switch in multiple places
- Adding types requires code changes

**Detection:**
```regex
switch\s*\(\s*\w+\.(type|kind|variant)\s*\)
if\s*\(\s*\w+\s*(===?|instanceof)\s*['"]?\w+['"]?\s*\)
```

**Refactoring:**
1. Replace Conditional with Polymorphism
2. Replace Type Code with Subclasses
3. Replace Type Code with State/Strategy

### Temporary Field

**Symptoms:**
- Fields only used in some methods
- Fields set to null when not in use
- Null checks scattered throughout

**Detection:**
```regex
# Fields with frequent null checks
if\s*\(\s*this\.\w+\s*(===?|!==?)\s*(null|undefined)\s*\)
this\.\w+\s*\?\.\w+
```

**Refactoring:**
1. Extract Class for the temporary fields
2. Introduce Null Object
3. Replace temp with local variables

## Change Preventers

### Divergent Change

**Symptoms:**
- One class changed for many different reasons
- Multiple unrelated change requests touch same file
- File modified in most PRs

**Detection:**
```bash
# Most frequently changed files
git log --pretty=format: --name-only | sort | uniq -c | sort -rn | head -20
```

**Refactoring:**
1. Extract Class for each change reason
2. Single Responsibility Principle

### Shotgun Surgery

**Symptoms:**
- Small change requires edits to many files
- Same change pattern repeated across files
- Missing abstraction

**Detection:**
```bash
# Commits that touch many files
git log --stat --oneline | grep -E "^\s+[0-9]+ files? changed"
```

**Refactoring:**
1. Move Method/Field to consolidate
2. Inline Class if over-distributed
3. Extract shared behavior

## Dispensables

### Dead Code

**Symptoms:**
- Unreachable code after return/throw
- Unused variables, functions, classes
- Commented-out code blocks

**Detection:**
```bash
# TypeScript/JavaScript
npx ts-prune  # Find unused exports

# Commented code blocks
grep -n "^[[:space:]]*//" file.ts | head -50
```

**Refactoring:**
1. Delete with confidence (git has history)
2. Remove unused imports first
3. Run tests after each deletion

### Speculative Generality

**Symptoms:**
- Unused abstract classes
- Unused parameters "for future use"
- Methods that only delegate
- Classes with only one subclass

**Detection:**
```bash
# Abstract classes with single implementer
grep -l "abstract class" *.ts | xargs -I{} sh -c 'echo {} && grep -c "extends" {}'
```

**Refactoring:**
1. Collapse Hierarchy
2. Inline Class
3. Remove unused parameters
4. Rename Method to remove abstraction

### Duplicate Code

**Symptoms:**
- Copy-pasted code blocks
- Similar methods in different classes
- Repeated conditional logic

**Detection:**
```bash
# Use jscpd for JS/TS
npx jscpd --min-lines 5 --reporters console src/

# Manual pattern search
grep -rn "specific code pattern" .
```

**Refactoring:**
1. Extract Method for duplicates in same class
2. Extract Class for duplicates across classes
3. Pull Up Method/Field if in subclasses
4. Form Template Method for similar algorithms

## Couplers

### Feature Envy

**Symptoms:**
- Method uses more features of another class
- Many calls to another object's getters
- Data and behavior separated

**Detection:**
```regex
# Many calls to same external object
other\.\w+.*other\.\w+.*other\.\w+
```

**Refactoring:**
1. Move Method to the envied class
2. Extract Method then Move

### Inappropriate Intimacy

**Symptoms:**
- Classes know too much about each other
- Accessing private/protected members
- Bidirectional associations

**Detection:**
```bash
# Circular imports
npx madge --circular src/
```

**Refactoring:**
1. Move Method/Field
2. Change Bidirectional to Unidirectional
3. Extract Class for shared behavior
4. Hide Delegate

### Message Chains

**Symptoms:**
- a.getB().getC().getD().doSomething()
- Train wrecks
- Violations of Law of Demeter

**Detection:**
```regex
\w+\.\w+\(\)\.\w+\(\)\.\w+\(\)
\w+\.\w+\.\w+\.\w+
```

**Refactoring:**
1. Hide Delegate
2. Extract Method
3. Move Method

## Architecture Smells

### Circular Dependencies

**Symptoms:**
- A imports B, B imports C, C imports A
- Build order issues
- Difficult to test in isolation

**Detection:**
```bash
# JavaScript/TypeScript
npx madge --circular --extensions ts src/

# Python
pydeps --show-cycles src/
```

**Refactoring:**
1. Extract Interface - depend on abstraction
2. Extract Common Module - shared code to third module
3. Dependency Injection - pass dependency instead of import
4. Event-Based - decouple with events

### Missing Abstraction

**Symptoms:**
- Primitive types used for domain concepts
- Same validation logic repeated
- String constants with special meaning

**Detection:**
```regex
# String type checking
if\s*\(\s*\w+\s*===?\s*['"][^'"]+['"]\s*\)
```

**Refactoring:**
1. Replace Primitive with Object
2. Introduce Value Object
3. Replace Type Code with Class
