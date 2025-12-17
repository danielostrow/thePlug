---
name: Refactoring Strategies
description: This skill activates when the user asks about "refactoring", "clean up code", "improve code", "reduce complexity", "extract method", "split file", "fix code smells", "modernize code", "auto-fix", or needs guidance on safely transforming code.
version: 1.0.0
---

# Refactoring Strategies

Guidance for safely improving code structure while preserving functionality.

## Core Principles

1. **Small Steps**: One change at a time
2. **Test After Each Step**: Verify behavior preserved
3. **Version Control**: Commit after each successful refactoring
4. **Reversibility**: Be able to undo any change

## Common Refactorings

| Refactoring | When to Use | Risk |
|-------------|-------------|------|
| Extract Method | Long function, duplicate code | Low |
| Inline Method | Trivial delegation | Low |
| Extract Variable | Complex expression | Low |
| Rename | Unclear naming | Low |
| Move Method | Feature envy | Medium |
| Extract Class | God class | Medium |
| Replace Conditional with Polymorphism | Complex switches | High |
| Introduce Parameter Object | Long parameter list | Medium |

## Extract Method

**Before:**
```typescript
function printOwing(invoice: Invoice) {
  let outstanding = 0;

  // Print banner
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");

  // Calculate outstanding
  for (const order of invoice.orders) {
    outstanding += order.amount;
  }

  // Print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

**After:**
```typescript
function printOwing(invoice: Invoice) {
  printBanner();
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}

function printBanner() {
  console.log("***********************");
  console.log("**** Customer Owes ****");
  console.log("***********************");
}

function calculateOutstanding(invoice: Invoice): number {
  return invoice.orders.reduce((sum, order) => sum + order.amount, 0);
}

function printDetails(invoice: Invoice, outstanding: number) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

## Split God Class

**Process:**
1. List all methods and group by data they access
2. Identify cohesive groups
3. Extract each group to its own class
4. Use composition in original

**Before:**
```typescript
class OrderProcessor {
  // Customer-related
  validateCustomer() {}
  getCustomerDiscount() {}
  updateCustomerStatus() {}

  // Order-related
  calculateTotal() {}
  applyDiscounts() {}
  validateOrder() {}

  // Shipping-related
  calculateShipping() {}
  selectCarrier() {}
  generateLabel() {}
}
```

**After:**
```typescript
class OrderProcessor {
  constructor(
    private customerService: CustomerService,
    private orderCalculator: OrderCalculator,
    private shippingService: ShippingService
  ) {}

  process(order: Order) {
    this.customerService.validate(order.customer);
    const total = this.orderCalculator.calculate(order);
    this.shippingService.ship(order);
  }
}

class CustomerService {
  validate() {}
  getDiscount() {}
  updateStatus() {}
}

class OrderCalculator {
  calculateTotal() {}
  applyDiscounts() {}
  validate() {}
}

class ShippingService {
  calculateCost() {}
  selectCarrier() {}
  generateLabel() {}
}
```

## Fix Circular Dependencies

**Strategies:**
1. Extract Interface
2. Extract Common Module
3. Dependency Injection
4. Event-Based Decoupling

**Before (Circular):**
```typescript
// a.ts
import { B } from './b';
export class A {
  constructor(private b: B) {}
}

// b.ts
import { A } from './a';
export class B {
  constructor(private a: A) {}
}
```

**After (Extract Interface):**
```typescript
// interfaces.ts
export interface IA { }
export interface IB { }

// a.ts
import { IB } from './interfaces';
export class A implements IA {
  constructor(private b: IB) {}
}

// b.ts
import { IA } from './interfaces';
export class B implements IB {
  constructor(private a: IA) {}
}
```

## Safe Auto-Fixes

### 1. Remove Unused Imports
```diff
- import { used, unused } from 'module';
+ import { used } from 'module';
```

### 2. Externalize Secrets
```diff
- const API_KEY = "sk_live_abc123";
+ const API_KEY = process.env.API_KEY;
```
Add to `.env.example`:
```
API_KEY=your_api_key_here
```

### 3. Parameterize Queries
```diff
# JavaScript
- db.query("SELECT * FROM users WHERE id=" + id);
+ db.query("SELECT * FROM users WHERE id = ?", [id]);

# Python
- cursor.execute(f"SELECT * FROM users WHERE id={id}")
+ cursor.execute("SELECT * FROM users WHERE id = %s", (id,))
```

### 4. Remove Commented Code
```diff
- // function oldCode() {
- //   return deprecated();
- // }
```

### 5. Remove Dead Code
```diff
  function example() {
    return value;
-   console.log("unreachable");
  }
```

## Refactoring Workflow

1. **Ensure tests exist** - Write tests if missing
2. **Make one change** - Single refactoring step
3. **Run tests** - Verify behavior preserved
4. **Commit** - Create rollback point
5. **Repeat** - Continue with next change

## Reference Files

- `references/common-refactors.md` - Step-by-step refactoring guides
- `references/fix-templates.md` - Auto-fix code templates
