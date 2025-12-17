# Common Refactoring Patterns

Step-by-step guides for frequently used refactorings.

## Extract Method

**When:** Function is too long, code is duplicated, or you need to add a comment.

**Steps:**
1. Create new function with descriptive name
2. Copy extracted code to new function
3. Identify local variables needed as parameters
4. Identify local variables modified (become return values)
5. Replace original code with function call
6. Run tests

**Example:**
```typescript
// Before
function processOrder(order: Order) {
  // Validate items
  for (const item of order.items) {
    if (item.quantity <= 0) throw new Error("Invalid quantity");
    if (!item.productId) throw new Error("Missing product");
  }
  // ... rest of processing
}

// After
function processOrder(order: Order) {
  validateItems(order.items);
  // ... rest of processing
}

function validateItems(items: OrderItem[]) {
  for (const item of items) {
    if (item.quantity <= 0) throw new Error("Invalid quantity");
    if (!item.productId) throw new Error("Missing product");
  }
}
```

## Extract Variable

**When:** Expression is complex and hard to understand.

**Steps:**
1. Declare new variable with meaningful name
2. Replace part of expression with variable
3. Run tests

**Example:**
```typescript
// Before
if (user.subscription && user.subscription.endDate > new Date() && user.subscription.plan !== 'free') {
  showPremiumContent();
}

// After
const hasActiveSubscription = user.subscription && user.subscription.endDate > new Date();
const isPaidPlan = user.subscription?.plan !== 'free';

if (hasActiveSubscription && isPaidPlan) {
  showPremiumContent();
}
```

## Introduce Parameter Object

**When:** Group of parameters travel together, function has too many parameters.

**Steps:**
1. Create new class/interface for the parameters
2. Add new parameter of that type
3. Gradually move parameters into the object
4. Remove old parameters one by one
5. Run tests after each change

**Example:**
```typescript
// Before
function createBooking(
  startDate: Date,
  endDate: Date,
  roomType: string,
  guestCount: number,
  guestName: string,
  guestEmail: string,
  specialRequests: string[]
) {}

// After
interface BookingRequest {
  dateRange: { start: Date; end: Date };
  room: { type: string; guestCount: number };
  guest: { name: string; email: string };
  specialRequests?: string[];
}

function createBooking(request: BookingRequest) {}
```

## Replace Conditional with Polymorphism

**When:** Same conditional logic appears in multiple places, adding new types requires code changes.

**Steps:**
1. Create interface or abstract base class
2. Create subclass for each type
3. Move type-specific behavior to subclasses
4. Replace conditional with polymorphic call
5. Run tests

**Example:**
```typescript
// Before
function calculateShipping(order: Order): number {
  switch (order.shippingMethod) {
    case 'standard':
      return order.weight * 0.5;
    case 'express':
      return order.weight * 2.0 + 10;
    case 'overnight':
      return order.weight * 5.0 + 25;
  }
}

// After
interface ShippingMethod {
  calculate(order: Order): number;
}

class StandardShipping implements ShippingMethod {
  calculate(order: Order) { return order.weight * 0.5; }
}

class ExpressShipping implements ShippingMethod {
  calculate(order: Order) { return order.weight * 2.0 + 10; }
}

class OvernightShipping implements ShippingMethod {
  calculate(order: Order) { return order.weight * 5.0 + 25; }
}

function calculateShipping(order: Order, method: ShippingMethod): number {
  return method.calculate(order);
}
```

## Move Method

**When:** Method uses more features of another class than its own (Feature Envy).

**Steps:**
1. Examine all features used by the method
2. Check if method should move to the most-used class
3. Declare method in target class
4. Copy code, adjusting for new context
5. Convert original to delegation
6. Consider removing original if only delegating
7. Run tests

**Example:**
```typescript
// Before
class Order {
  customer: Customer;

  getDiscountedTotal(): number {
    let discount = 0;
    if (this.customer.loyaltyPoints > 1000) discount = 0.1;
    if (this.customer.memberSince < yearsAgo(5)) discount += 0.05;
    if (this.customer.orders.length > 100) discount += 0.03;
    return this.total * (1 - discount);
  }
}

// After
class Customer {
  getDiscount(): number {
    let discount = 0;
    if (this.loyaltyPoints > 1000) discount = 0.1;
    if (this.memberSince < yearsAgo(5)) discount += 0.05;
    if (this.orders.length > 100) discount += 0.03;
    return discount;
  }
}

class Order {
  customer: Customer;

  getDiscountedTotal(): number {
    return this.total * (1 - this.customer.getDiscount());
  }
}
```

## Replace Magic Number with Symbolic Constant

**When:** Literal number appears in code without explanation.

**Steps:**
1. Declare constant with descriptive name
2. Replace all occurrences of literal
3. Run tests

**Example:**
```typescript
// Before
function calculateShipping(distance: number): number {
  if (distance > 100) {
    return distance * 0.25 + 10;
  }
  return 5.99;
}

// After
const LONG_DISTANCE_THRESHOLD_KM = 100;
const RATE_PER_KM = 0.25;
const LONG_DISTANCE_BASE_FEE = 10;
const LOCAL_SHIPPING_FEE = 5.99;

function calculateShipping(distance: number): number {
  if (distance > LONG_DISTANCE_THRESHOLD_KM) {
    return distance * RATE_PER_KM + LONG_DISTANCE_BASE_FEE;
  }
  return LOCAL_SHIPPING_FEE;
}
```

## Decompose Conditional

**When:** Complex conditional logic with multiple conditions.

**Steps:**
1. Extract condition into well-named function
2. Extract then-branch if complex
3. Extract else-branch if complex
4. Run tests

**Example:**
```typescript
// Before
if (date.isBefore(SUMMER_START) || date.isAfter(SUMMER_END)) {
  charge = quantity * winterRate + winterServiceCharge;
} else {
  charge = quantity * summerRate;
}

// After
if (isWinter(date)) {
  charge = winterCharge(quantity);
} else {
  charge = summerCharge(quantity);
}

function isWinter(date: Date): boolean {
  return date.isBefore(SUMMER_START) || date.isAfter(SUMMER_END);
}

function winterCharge(quantity: number): number {
  return quantity * winterRate + winterServiceCharge;
}

function summerCharge(quantity: number): number {
  return quantity * summerRate;
}
```

## Consolidate Duplicate Conditional Fragments

**When:** Same code appears in all branches of a conditional.

**Steps:**
1. Identify common code in all branches
2. Move it outside the conditional (before or after)
3. Run tests

**Example:**
```typescript
// Before
if (isSpecialDeal()) {
  total = price * 0.95;
  send();
} else {
  total = price * 0.98;
  send();
}

// After
total = isSpecialDeal() ? price * 0.95 : price * 0.98;
send();
```

## Replace Nested Conditional with Guard Clauses

**When:** Deeply nested conditionals make the happy path unclear.

**Steps:**
1. Identify special cases
2. Convert each to a guard clause with early return
3. Run tests after each change

**Example:**
```typescript
// Before
function getPayAmount(employee: Employee): number {
  let result: number;
  if (employee.isSeparated) {
    result = separatedAmount();
  } else {
    if (employee.isRetired) {
      result = retiredAmount();
    } else {
      result = normalPayAmount();
    }
  }
  return result;
}

// After
function getPayAmount(employee: Employee): number {
  if (employee.isSeparated) return separatedAmount();
  if (employee.isRetired) return retiredAmount();
  return normalPayAmount();
}
```
