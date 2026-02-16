# Phase 12: Angular Signals & Modern Reactivity

> "Signals are not just a new API — they are a fundamental shift in how Angular thinks about reactivity. Where Zone.js made Angular powerful by tracking everything, Signals make Angular fast by tracking only what matters."

---

## 12.1 Why Signals? The Problem with Zone.js

### How Zone.js Works

Zone.js is a library that ships with every Angular application (prior to the signals era). It works by **monkey-patching** every async API in the browser — meaning it replaces built-in functions with its own wrapped versions that notify Angular when something might have changed.

```
Zone.js monkey-patches these APIs at startup:

  setTimeout     → Zone.setTimeout     // ← wraps to notify Angular after callback
  setInterval    → Zone.setInterval    // ← wraps to notify Angular after callback
  Promise.then   → Zone.Promise.then   // ← wraps to notify Angular after resolution
  XMLHttpRequest → Zone.XHR            // ← wraps to notify Angular after response
  addEventListener → Zone.addEventListener // ← wraps to notify Angular after event
  fetch          → Zone.fetch          // ← wraps to notify Angular after response
```

When any of these wrapped operations complete, Zone.js tells Angular: **"Something may have changed — please check everything."**

Angular then runs **Change Detection (CD)** — it walks the entire component tree, compares current values to previous values, and updates the DOM wherever differences are found.

```typescript
// Zone.js intercepts EVERY async operation automatically
// You write normal code and Angular "just knows" to update the view

@Component({
  selector: 'app-counter',
  template: `<p>Count: {{ count }}</p>`
})
export class CounterComponent {
  count = 0;  // ← just a plain number

  increment() {
    this.count++;  // ← Zone.js detects this change via the click event wrapper
    // Angular automatically runs change detection after this method returns
    // You never call detectChanges() manually — Zone.js handles it
  }
}
```

### The Core Problem: Whole-Tree Change Detection

The fundamental issue is that Zone.js cannot know WHICH component changed. It only knows THAT something changed. So Angular's default strategy (`CheckAlways`) walks every single component in the tree on every event.

```
THE ZONE.JS CHANGE DETECTION PROBLEM:

User clicks a button in <ProductCard> (deep in the tree)
                              │
                              ▼
         Zone.js fires: "Something may have changed!"
                              │
                              ▼
         Angular starts change detection at ROOT
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
      <AppComponent>    <HeaderComponent>   <FooterComponent>
    (nothing changed)   (nothing changed)   (nothing changed)
         │
    ┌────┴────┐
    ▼         ▼
 <NavBar>  <MainContent>
(nothing)  (nothing)
               │
         ┌─────┴─────┐
         ▼           ▼
    <Sidebar>   <ProductList>
    (nothing)       │
                ┌───┴───┐
                ▼       ▼
          <ProductCard> <ProductCard>  ← ONLY THIS CHANGED
          (CHANGED!)    (nothing)

  Result: Angular checked 9 components to find 1 change.
  In a real app with 200 components: checked 200, changed 1.
  Multiply by thousands of events per session = WASTED CPU.
```

### Real-World Analogy: Fire Alarm vs Smart Motion Detectors

```
ZONE.JS APPROACH — Fire Alarm System:

  ┌─────────────────────────────────────────────┐
  │           OFFICE BUILDING                    │
  │                                             │
  │  Someone burns toast in the kitchen         │
  │              │                              │
  │              ▼                              │
  │    FIRE ALARM TRIGGERED!!!                  │
  │              │                              │
  │    ┌─────────┼─────────┐                   │
  │    ▼         ▼         ▼                   │
  │  Floor 1   Floor 2   Floor 3               │
  │  evacuate  evacuate  evacuate              │
  │  (all 300  (all 300  (all 300              │
  │   people)   people)   people)              │
  │                                             │
  │  300 people disrupted because of 1 piece   │
  │  of burnt toast in ONE kitchen.             │
  └─────────────────────────────────────────────┘

SIGNALS APPROACH — Smart Motion Detectors:

  ┌─────────────────────────────────────────────┐
  │           OFFICE BUILDING                    │
  │                                             │
  │  Someone burns toast in the kitchen         │
  │              │                              │
  │              ▼                              │
  │    Kitchen smoke detector triggers          │
  │              │                              │
  │              ▼                              │
  │    ONLY kitchen sprinkler activates         │
  │                                             │
  │  Floor 1: unaffected — keeps working        │
  │  Floor 2: unaffected — keeps working        │
  │  Floor 3: unaffected — keeps working        │
  │  Kitchen: handled precisely                 │
  │                                             │
  │  1 change = 1 precise response.             │
  └─────────────────────────────────────────────┘
```

### The Signal-Based Future

Signals give Angular **fine-grained reactivity**: instead of checking all components when anything changes, Angular knows exactly which signals changed and which components read those signals — so it updates ONLY those components.

```
SIGNALS CHANGE DETECTION:

User clicks button in <ProductCard>
ProductCard reads signal: count()
                              │
                              ▼
  Signal notifies Angular: "count changed — ProductCard reads count"
                              │
                              ▼
  Angular updates ONLY <ProductCard>
  ─────────────────────────────────
  <AppComponent>     → NOT CHECKED  // ← skipped entirely
  <HeaderComponent>  → NOT CHECKED  // ← skipped entirely
  <FooterComponent>  → NOT CHECKED  // ← skipped entirely
  <NavBar>           → NOT CHECKED  // ← skipped entirely
  <MainContent>      → NOT CHECKED  // ← skipped entirely
  <Sidebar>          → NOT CHECKED  // ← skipped entirely
  <ProductList>      → NOT CHECKED  // ← skipped entirely
  <ProductCard>      → UPDATED ✓   // ← only this, because it reads the signal

  Result: 1 check instead of 9. O(affected) instead of O(total).
```

### Zone.js vs Signals — Side-by-Side Comparison

| Aspect | Zone.js | Signals |
|--------|---------|---------|
| **Change detection trigger** | Any async event (click, timer, HTTP) | Only when a signal's value changes |
| **Scope of CD** | Entire component tree (by default) | Only components that read the changed signal |
| **Developer overhead** | Automatic but unpredictable | Explicit, but precise |
| **Bundle size** | Requires zone.js (~100KB) | Zero extra dependencies |
| **Performance** | O(components) per event | O(affected components) per change |
| **Debugging** | Hard — why did this component re-render? | Easy — which signals does it read? |
| **SSR compatibility** | Complex (Zone.js needs to work server-side) | Clean, no Zone.js needed |
| **Angular version** | Angular 2–present | Angular 16+ (stable in 17+) |

---

## 12.2 What Are Signals?

### The Core Definition

A **Signal** is a wrapper around a value that:
1. Stores a value
2. Notifies all consumers when the value changes
3. Tracks which other signals/computed values/effects depend on it

Think of a signal like a **cell in a spreadsheet**. When you change the value of cell A1, every formula that references A1 automatically recalculates. Signals work the same way in Angular.

```
SPREADSHEET ANALOGY:

  Cell A1: 5          ← signal: price = signal(5)
  Cell A2: 3          ← signal: quantity = signal(3)
  Cell B1: =A1*A2     ← computed: total = computed(() => price() * quantity())
  Cell B2: =B1*0.1    ← computed: tax = computed(() => total() * 0.1)
  Cell B3: =B1+B2     ← computed: grandTotal = computed(() => total() + tax())

  Change A1 to 10:
  → B1 recalculates: 30
  → B2 recalculates: 3
  → B3 recalculates: 33
  → Only affected cells update. Everything else stays the same.
```

### Creating a Signal with `signal()`

```typescript
import { signal } from '@angular/core';

// signal<T>(initialValue) creates a WritableSignal<T>
const count = signal(0);         // ← WritableSignal<number>, initial value = 0
const name = signal('Alice');    // ← WritableSignal<string>
const isOpen = signal(false);    // ← WritableSignal<boolean>
const user = signal<User | null>(null); // ← WritableSignal<User | null>, explicit type

// TypeScript infers the type from the initial value
// signal(0) → WritableSignal<number>
// signal('') → WritableSignal<string>
// But for complex types, provide the type explicitly
const items = signal<Product[]>([]); // ← explicit type annotation recommended
```

### Reading a Signal

**Critical rule: read a signal by calling it as a function.** A signal is NOT a property — it is a function that returns the current value.

```typescript
// CORRECT — call signal as a function
const count = signal(5);
console.log(count());   // ← 5 — call with () to get value

// WRONG — do NOT access .value
console.log(count.value); // ← undefined! Signals don't have .value
console.log(count);       // ← [Function] — this is the signal itself, not the value

// In a template — also call it as a function
// <p>{{ count() }}</p>   ← correct
// <p>{{ count }}</p>     ← WRONG — shows "[object Object]"
```

### `set()` — Replace the Value

```typescript
import { signal } from '@angular/core';

const count = signal(0); // ← initial value: 0

count.set(5);    // ← replaces value with 5 — now count() returns 5
count.set(10);   // ← replaces value with 10 — now count() returns 10
count.set(0);    // ← replaces value with 0 — now count() returns 0

// set() with objects — replaces entire object reference
const user = signal({ name: 'Alice', age: 30 });
user.set({ name: 'Bob', age: 25 }); // ← replaces entire object
// Angular detects the reference change and updates consumers
```

### `update()` — Compute New Value from Old

```typescript
import { signal } from '@angular/core';

const count = signal(0); // ← initial value: 0

// update(fn) passes current value to fn, sets result as new value
count.update(current => current + 1); // ← 0 → 1
count.update(current => current + 1); // ← 1 → 2
count.update(current => current * 2); // ← 2 → 4

// Useful for arrays — add/remove items
const items = signal<string[]>(['a', 'b', 'c']);

items.update(list => [...list, 'd']);            // ← adds 'd': ['a','b','c','d']
items.update(list => list.filter(i => i !== 'b')); // ← removes 'b': ['a','c','d']

// Useful for objects — merge partial update
const user = signal({ name: 'Alice', age: 30, role: 'admin' });
user.update(u => ({ ...u, age: 31 })); // ← only update age, keep rest
// now user() = { name: 'Alice', age: 31, role: 'admin' }
```

### Full Component Example with All Signal Methods

```typescript
import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-signal-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="demo">
      <h2>Signal Demo</h2>

      <!-- Read signal with () — Angular tracks this dependency -->
      <p>Count: {{ count() }}</p>          <!-- ← reactive: updates when count changes -->
      <p>Name: {{ name() }}</p>            <!-- ← reactive: updates when name changes -->
      <p>Items: {{ items().join(', ') }}</p> <!-- ← reactive: updates when items changes -->

      <div class="controls">
        <!-- set() — replace with fixed value -->
        <button (click)="resetCount()">Reset to 0</button>

        <!-- update() — compute from current value -->
        <button (click)="increment()">Increment</button>
        <button (click)="decrement()">Decrement</button>
        <button (click)="double()">Double</button>

        <!-- update() on array -->
        <button (click)="addItem()">Add Item</button>
        <button (click)="removeFirst()">Remove First</button>
      </div>
    </div>
  `
})
export class SignalDemoComponent {
  // Declare signals as class fields
  count = signal(0);                   // ← WritableSignal<number>
  name = signal('Angular');            // ← WritableSignal<string>
  items = signal<string[]>(['A', 'B']); // ← WritableSignal<string[]>

  // Using set() — replace with known value
  resetCount(): void {
    this.count.set(0); // ← replaces current value with 0
  }

  // Using update() — compute from current value
  increment(): void {
    this.count.update(n => n + 1); // ← n is current value, return new value
  }

  decrement(): void {
    this.count.update(n => n - 1); // ← subtract 1 from current count
  }

  double(): void {
    this.count.update(n => n * 2); // ← multiply current count by 2
  }

  // update() for arrays — always return new array (immutable)
  addItem(): void {
    const letter = String.fromCharCode(65 + this.items().length); // ← next letter
    this.items.update(list => [...list, letter]); // ← spread + add: immutable update
  }

  removeFirst(): void {
    this.items.update(list => list.slice(1)); // ← new array without first element
  }
}
```

### Signal Equality — Avoiding Unnecessary Re-renders

By default, signals use `===` (reference equality) to determine if a value changed. You can provide a custom equality function:

```typescript
import { signal } from '@angular/core';

// Default equality: === (reference equality)
const count = signal(0);
count.set(0); // ← 0 === 0: true → NO notification sent (no re-render)
count.set(1); // ← 1 === 0: false → notification sent (re-render)

// Custom equality for objects — compare by content, not reference
const user = signal(
  { name: 'Alice', age: 30 },
  {
    equal: (a, b) => a.name === b.name && a.age === b.age
    // ← only notify consumers if name OR age actually changed
  }
);

user.set({ name: 'Alice', age: 30 }); // ← equal by custom fn → no notification
user.set({ name: 'Bob', age: 30 });   // ← different name → notification sent

// Custom equality for arrays — compare contents
const tags = signal<string[]>(
  ['angular', 'typescript'],
  {
    equal: (a, b) =>
      a.length === b.length && a.every((v, i) => v === b[i])
    // ← only notify if array contents actually changed
  }
);
```

---

## 12.3 Computed Signals

### What Is a Computed Signal?

A **computed signal** is a **read-only, automatically-derived signal** whose value is recalculated whenever any of its signal dependencies change. It is like a spreadsheet formula: it re-evaluates when its inputs change, but you cannot set its value directly.

```
COMPUTED SIGNAL FLOW:

  signal: firstName = signal('John')
  signal: lastName  = signal('Doe')
                          │
                          ▼
  computed: fullName = computed(() => firstName() + ' ' + lastName())
                          │
                          ▼
  When firstName.set('Jane'):
    → fullName automatically becomes 'Jane Doe'
    → Any component reading fullName() re-renders
    → You never manually update fullName — it's automatic
```

### Creating Computed Signals

```typescript
import { Component, signal, computed } from '@angular/core';

@Component({
  selector: 'app-computed-demo',
  standalone: true,
  template: `
    <p>First: {{ firstName() }}</p>
    <p>Last: {{ lastName() }}</p>
    <p>Full: {{ fullName() }}</p>          <!-- ← reads computed signal -->
    <p>Upper: {{ upperFullName() }}</p>    <!-- ← chained computed signal -->
    <p>Has Name: {{ hasName() }}</p>       <!-- ← boolean computed -->
    <button (click)="updateFirst('Jane')">Set Jane</button>
  `
})
export class ComputedDemoComponent {
  // Source signals (writable)
  firstName = signal('John');   // ← WritableSignal<string>
  lastName  = signal('Doe');    // ← WritableSignal<string>

  // Computed signal — derived from firstName and lastName
  fullName = computed(() =>
    `${this.firstName()} ${this.lastName()}`
    // ← Angular tracks that fullName depends on firstName and lastName
    // ← When either changes, fullName is marked stale and recalculates on next read
  );

  // Chained computed — depends on another computed signal
  upperFullName = computed(() =>
    this.fullName().toUpperCase()
    // ← depends on fullName, which depends on firstName + lastName
    // ← change firstName → fullName recalculates → upperFullName recalculates
  );

  // Boolean computed
  hasName = computed(() =>
    this.firstName().length > 0 && this.lastName().length > 0
    // ← returns true if both names are non-empty
  );

  updateFirst(name: string): void {
    this.firstName.set(name); // ← triggers: fullName, upperFullName, hasName recalculate
  }
}
```

### Lazy Evaluation and Memoization

Computed signals are **lazy** and **memoized**:
- **Lazy**: the computation runs only when the computed signal is READ (not when dependencies change)
- **Memoized**: the result is cached — if dependencies haven't changed, reading the computed returns the cached value without re-running the function

```typescript
import { signal, computed } from '@angular/core';

const price = signal(100);
const quantity = signal(3);

// This function does NOT run immediately when computed() is called
// It runs when total() is first read
let computeCount = 0;

const total = computed(() => {
  computeCount++;
  console.log(`Computing total... (run #${computeCount})`);
  return price() * quantity(); // ← reads both signals (registers dependencies)
});

// At this point: computeCount = 0 (not computed yet — it's lazy)

console.log(total()); // ← NOW it runs: computeCount = 1, logs "Computing total..."
// Output: 300

console.log(total()); // ← Dependencies unchanged: uses CACHE, computeCount still 1
// Output: 300 (no "Computing total..." log — memoized!)

price.set(200);       // ← price changed: total is marked STALE (not recomputed yet)
// computeCount still 1 (lazy — not recalculated until read)

console.log(total()); // ← total is stale, so it recomputes: computeCount = 2
// Output: 600

console.log(total()); // ← price/quantity unchanged: uses CACHE again
// Output: 600 (no recomputation)
```

### Computed Signals Are Read-Only

You cannot call `.set()` or `.update()` on a computed signal:

```typescript
import { signal, computed } from '@angular/core';

const count = signal(0);
const doubled = computed(() => count() * 2); // ← Signal<number> (not WritableSignal)

doubled();         // ← OK: read the value
// doubled.set(10); // ← COMPILE ERROR: Property 'set' does not exist on type 'Signal<number>'
// doubled.update(...); // ← COMPILE ERROR: same reason

// To change doubled, you change its dependency (count):
count.set(5); // ← doubled() now returns 10 automatically
```

### Practical Computed Signal Examples

```typescript
import { Component, signal, computed } from '@angular/core';

interface Product {
  id: number;
  name: string;
  price: number;
  inCart: boolean;
  category: string;
}

@Component({
  selector: 'app-shop',
  standalone: true,
  template: `
    <p>Products: {{ allProducts().length }}</p>
    <p>Cart Items: {{ cartItems().length }}</p>
    <p>Cart Total: ${{ cartTotal() | number:'1.2-2' }}</p>
    <p>Tax (10%): ${{ cartTax() | number:'1.2-2' }}</p>
    <p>Grand Total: ${{ grandTotal() | number:'1.2-2' }}</p>
    <p>Is Cart Empty? {{ isCartEmpty() }}</p>
    <p>Category Filter: {{ activeCategory() }}</p>
    <p>Filtered Count: {{ filteredProducts().length }}</p>
  `
})
export class ShopComponent {
  // Source signals
  allProducts = signal<Product[]>([]);         // ← raw product list
  activeCategory = signal<string>('all');      // ← selected category filter
  taxRate = signal(0.10);                      // ← 10% tax

  // Computed: products currently in cart
  cartItems = computed(() =>
    this.allProducts().filter(p => p.inCart)   // ← re-runs when allProducts changes
  );

  // Computed: sum of cart item prices
  cartTotal = computed(() =>
    this.cartItems().reduce((sum, p) => sum + p.price, 0)
    // ← re-runs when cartItems changes (which re-runs when allProducts changes)
  );

  // Computed: derived from another computed
  cartTax = computed(() =>
    this.cartTotal() * this.taxRate()
    // ← depends on cartTotal (computed) and taxRate (signal)
  );

  // Computed: derived from two computed signals
  grandTotal = computed(() =>
    this.cartTotal() + this.cartTax()           // ← sum of two computed signals
  );

  // Computed: boolean derived state
  isCartEmpty = computed(() =>
    this.cartItems().length === 0               // ← true when cart has no items
  );

  // Computed: filter products by category
  filteredProducts = computed(() => {
    const category = this.activeCategory();     // ← read category signal
    const products = this.allProducts();        // ← read products signal
    if (category === 'all') return products;    // ← no filter: return all
    return products.filter(p => p.category === category); // ← filter by category
  });
}
```

### Common Mistake: Side Effects Inside `computed()`

```typescript
import { signal, computed, effect } from '@angular/core';

const count = signal(0);

// ❌ WRONG: side effects inside computed()
const wrongComputed = computed(() => {
  console.log('Count changed!'); // ← SIDE EFFECT in computed — BAD!
  localStorage.setItem('count', count().toString()); // ← SIDE EFFECT — BAD!
  return count() * 2;            // ← computed should ONLY return a derived value
});
// Problems:
// 1. computed() should be pure — same inputs, same output, no side effects
// 2. localStorage write might happen 0 times (lazy) or multiple times (surprising)
// 3. Angular may warn/error in dev mode

// ✓ CORRECT: use effect() for side effects
const doubled = computed(() => count() * 2); // ← pure computation only

// Separate effect for side effects
// (effects are covered in section 12.4)
```

---

## 12.4 Effects

### What Is an Effect?

An **effect** is a function that runs **whenever any signal it reads changes**. Unlike `computed()`, an effect is used for **side effects**: things that interact with the outside world — logging, localStorage, analytics, DOM manipulation, HTTP calls.

```
EFFECT MENTAL MODEL:

  effect(() => {
    // This function body is the "reactive" block
    // Every signal you READ inside here becomes a dependency
    // When any dependency changes, this whole function re-runs
  })

  Example:
  effect(() => {
    const n = count();  // ← reads count → count is now a dependency
    console.log('Count is now:', n); // ← side effect runs when count changes
  })

  When count changes from 5 to 6:
    → effect re-runs
    → logs "Count is now: 6"
    → count is still a dependency for next run
```

### Creating Effects

```typescript
import { Component, signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-effect-demo',
  standalone: true,
  template: `
    <p>Count: {{ count() }}</p>
    <button (click)="increment()">Increment</button>
  `
})
export class EffectDemoComponent {
  count = signal(0);   // ← source signal

  constructor() {
    // Effects must be created in an injection context
    // The constructor is the most common place

    // Basic effect — logs every time count changes
    effect(() => {
      console.log('Count changed to:', this.count()); // ← reads count → dependency
      // This runs immediately once (to capture initial value)
      // Then re-runs every time count() changes
    });

    // Effect reading multiple signals
    const name = signal('Alice');
    const role = signal('admin');

    effect(() => {
      // This effect depends on BOTH name and role
      console.log(`User: ${name()}, Role: ${role()}`);
      // ← re-runs if EITHER name OR role changes
    });
  }

  increment(): void {
    this.count.update(n => n + 1); // ← triggers effect to re-run
  }
}
```

### Effect Cleanup Function

Effects can return a cleanup function that runs before the next execution and when the effect is destroyed:

```typescript
import { Component, signal, effect } from '@angular/core';

@Component({
  selector: 'app-cleanup-demo',
  standalone: true,
  template: `<p>Timer ID: {{ timerId() }}</p>`
})
export class CleanupDemoComponent {
  interval = signal(1000); // ← interval duration in ms
  timerId = signal<number | null>(null);

  constructor() {
    effect(() => {
      const ms = this.interval(); // ← dependency: runs when interval changes

      // Start a timer with the new interval
      const id = window.setInterval(() => {
        console.log('Tick!');
      }, ms);

      this.timerId.set(id);

      // Return a CLEANUP function
      // Angular calls this cleanup BEFORE the next effect execution
      // AND when the component is destroyed
      return () => {
        console.log(`Clearing timer ${id}`); // ← cleanup: stop old timer
        window.clearInterval(id);             // ← prevent memory leak
      };
    });
    // Timeline:
    // 1. Effect runs: starts timer with 1000ms
    // 2. interval.set(500):
    //    a. Cleanup runs: clearInterval(old timer)
    //    b. Effect re-runs: starts new timer with 500ms
    // 3. Component destroyed:
    //    a. Cleanup runs: clearInterval(current timer)
  }
}
```

### `allowSignalWrites` Option

By default, Angular disallows writing to signals inside an effect (to prevent infinite loops). Use `allowSignalWrites: true` when you genuinely need to:

```typescript
import { Component, signal, effect } from '@angular/core';

@Component({
  selector: 'app-signal-write-effect',
  standalone: true,
  template: `<p>Status: {{ status() }}</p>`
})
export class SignalWriteEffectComponent {
  count = signal(0);
  status = signal('idle'); // ← will be written from effect

  constructor() {
    // Without allowSignalWrites, this throws:
    // "Writing to signals is not allowed in a `computed` or an `effect` by default"

    effect(() => {
      const n = this.count(); // ← dependency

      // Writing to a DIFFERENT signal based on what we read
      if (n > 10) {
        this.status.set('high'); // ← writing to status signal inside effect
      } else if (n > 5) {
        this.status.set('medium');
      } else {
        this.status.set('low');
      }
    }, { allowSignalWrites: true }); // ← opts into writing signals from effect

    // NOTE: If status were used to compute count, this would be an infinite loop.
    // Use allowSignalWrites carefully — prefer computed() when possible.
  }
}
```

### Practical Effect Use Cases

```typescript
import { Component, signal, effect, inject } from '@angular/core';

@Component({
  selector: 'app-practical-effects',
  standalone: true,
  template: `<div>See console for effect outputs</div>`
})
export class PracticalEffectsComponent {
  theme = signal<'light' | 'dark'>('light');
  userId = signal<number | null>(null);
  searchQuery = signal('');
  cartItemCount = signal(0);

  constructor() {
    // USE CASE 1: Sync to localStorage
    effect(() => {
      const currentTheme = this.theme(); // ← dependency: theme
      localStorage.setItem('app-theme', currentTheme);
      // ← runs every time theme changes, persists to storage
      document.body.setAttribute('data-theme', currentTheme);
      // ← also updates DOM attribute for CSS theming
    });

    // USE CASE 2: Analytics / logging
    effect(() => {
      const query = this.searchQuery(); // ← dependency: searchQuery
      if (query.length > 2) {
        // Track search analytics when query is meaningful
        console.log('[Analytics] User searched for:', query);
        // analyticsService.track('search', { query }); // ← real analytics call
      }
    });

    // USE CASE 3: Cart badge update (DOM side effect)
    effect(() => {
      const count = this.cartItemCount(); // ← dependency: cartItemCount
      document.title = count > 0
        ? `(${count}) My Shop`  // ← update browser tab title with cart count
        : 'My Shop';
    });

    // USE CASE 4: Logging for debugging
    effect(() => {
      // Read all relevant signals to get a full picture on any change
      console.group('[State Snapshot]');
      console.log('theme:', this.theme());           // ← dependency
      console.log('userId:', this.userId());          // ← dependency
      console.log('cart:', this.cartItemCount());     // ← dependency
      console.groupEnd();
      // Runs whenever ANY of these signals change — great for debugging
    });
  }
}
```

### Effect with Injector — Outside Constructor

If you need to create an effect outside the constructor (e.g., in a method), you must provide an `Injector`:

```typescript
import { Component, signal, effect, inject, Injector } from '@angular/core';

@Component({
  selector: 'app-injector-effect',
  standalone: true,
  template: `<button (click)="startTracking()">Start Tracking</button>`
})
export class InjectorEffectComponent {
  count = signal(0);
  private injector = inject(Injector); // ← inject the Injector token

  startTracking(): void {
    // Creating effect outside constructor requires explicit injector
    effect(() => {
      console.log('Tracking count:', this.count()); // ← reactive tracking
    }, { injector: this.injector }); // ← provide injector explicitly
    // Without injector: "effect() can only be used within an injection context"
  }
}
```

### Common Mistake: Using `effect()` for Derived Values

```typescript
import { signal, computed, effect } from '@angular/core';

const price = signal(100);
const quantity = signal(3);

// ❌ WRONG: using effect to update a derived value
let total = 0; // ← plain variable, NOT a signal
effect(() => {
  total = price() * quantity(); // ← updating a regular variable from an effect
  // Problems:
  // - total is not a signal, so templates won't react when it changes
  // - effect runs asynchronously — total may be stale
  // - This is exactly what computed() was designed for
});

// ✓ CORRECT: use computed() for derived values
const correctTotal = computed(() =>
  price() * quantity() // ← synchronous, memoized, reactive, read-only
);
// correctTotal() is always up-to-date when read
// Templates automatically re-render when it changes
```

### Effect vs Computed — When to Use Which

| Scenario | Use | Reason |
|----------|-----|--------|
| Derive a value from other signals | `computed()` | Synchronous, cached, pure |
| Sync to localStorage | `effect()` | Side effect |
| Log when data changes | `effect()` | Side effect |
| Update document.title | `effect()` | DOM side effect |
| Send analytics event | `effect()` | External system interaction |
| Calculate a total price | `computed()` | Pure derivation |
| Filter a list | `computed()` | Pure derivation |
| Format a display string | `computed()` | Pure derivation |
| Start/stop a timer | `effect()` with cleanup | Side effect with resource |

---

## 12.5 Signal Inputs — `input()` (Angular 17.1+)

### The Problem with `@Input()`

Traditional `@Input()` uses decorators and property assignments. Angular 17.1 introduced `input()` as a signal-based replacement:

```typescript
// OLD WAY — @Input() decorator
@Component({ ... })
export class OldComponent {
  @Input() userId!: number;        // ← plain property, possibly undefined at init
  @Input() required = '';          // ← no way to enforce "must be provided"
  @Input('externalName') prop = ''; // ← alias with decorator option

  ngOnChanges(changes: SimpleChanges): void {
    // Must use lifecycle hook to react to input changes
    if (changes['userId']) {
      this.loadUser(changes['userId'].currentValue);
    }
  }
}
```

### `input()` — Signal-Based Inputs

```typescript
import { Component, input, computed } from '@angular/core';

@Component({
  selector: 'app-user-card',
  standalone: true,
  template: `
    <div class="card">
      <!-- Read input as a signal — call with () -->
      <h3>{{ userId() }}</h3>
      <p>{{ displayName() }}</p>     <!-- ← reads computed which reads input -->
      <p>Role: {{ role() }}</p>
    </div>
  `
})
export class UserCardComponent {
  // input<Type>(defaultValue) — optional input with default
  userId = input<number>(0);           // ← Signal<number>, defaults to 0

  // input.required<Type>() — REQUIRED input, no default
  displayName = input.required<string>(); // ← Signal<string>, MUST be provided by parent
  // If parent doesn't provide displayName, Angular throws a compile error

  // input with alias — external name differs from internal name
  role = input<string>('user', {
    alias: 'userRole'  // ← parent uses [userRole]="...", internally use role()
  });

  // input with transform — convert/coerce the incoming value
  maxItems = input(10, {
    transform: (value: string | number) => Number(value)
    // ← parent might pass a string "20", transform converts to number 20
  });

  // input() returns a Signal — use in computed(), effect(), templates
  isAdmin = computed(() =>
    this.role() === 'admin'  // ← derived from role input signal
    // ← automatically re-evaluates when role input changes
  );
}
```

### Parent Component Using Signal Inputs

```typescript
import { Component, signal } from '@angular/core';
import { UserCardComponent } from './user-card.component';

@Component({
  selector: 'app-parent',
  standalone: true,
  imports: [UserCardComponent],
  template: `
    <!-- Providing signal inputs — same template syntax as @Input() -->
    <app-user-card
      [userId]="selectedId()"
      [displayName]="selectedName()"
      [userRole]="selectedRole()"
      [maxItems]="'25'"
    />
    <!-- [userRole] matches the alias defined in input() -->
    <!-- [maxItems]="'25'" — string '25' gets transformed to number 25 -->

    <button (click)="selectUser(2)">Select User 2</button>
  `
})
export class ParentComponent {
  selectedId   = signal(1);         // ← writable signal for parent state
  selectedName = signal('Alice');   // ← writable signal
  selectedRole = signal('admin');   // ← writable signal

  selectUser(id: number): void {
    this.selectedId.set(id);   // ← signal update propagates to child input automatically
    this.selectedName.set('Bob');
    this.selectedRole.set('user');
  }
}
```

### `@Input()` vs `input()` Comparison

| Feature | `@Input()` decorator | `input()` function |
|---------|---------------------|-------------------|
| **Type** | Plain property | `Signal<T>` / `InputSignal<T>` |
| **Reading in class** | `this.userId` | `this.userId()` |
| **Reading in template** | `{{ userId }}` | `{{ userId() }}` |
| **Required input** | `@Input({ required: true })` (Angular 16+) | `input.required<T>()` |
| **Default value** | `@Input() prop = default` | `input(default)` |
| **Alias** | `@Input('alias')` | `input(default, { alias: 'name' })` |
| **Transform** | `@Input({ transform: fn })` (Angular 16+) | `input(default, { transform: fn })` |
| **React to changes** | `ngOnChanges()` lifecycle hook | Use in `computed()` or `effect()` |
| **Interop with computed** | No | Yes — use directly in `computed()` |
| **Available Angular** | All versions | 17.1+ |
| **Writable by child** | Can accidentally mutate | Read-only by design |

---

## 12.6 Signal Outputs — `output()` (Angular 17.1+)

### The Problem with `@Output()` + EventEmitter

```typescript
// OLD WAY — verbose and requires RxJS import
import { Component, Output, EventEmitter } from '@angular/core';

@Component({ ... })
export class OldButtonComponent {
  @Output() clicked = new EventEmitter<void>();    // ← requires EventEmitter
  @Output() valueChanged = new EventEmitter<number>(); // ← RxJS Subject underneath

  handleClick(): void {
    this.clicked.emit();        // ← emit with no value
    this.valueChanged.emit(42); // ← emit with value
  }
}
```

### `output()` — Signal-Based Outputs

```typescript
import { Component, output } from '@angular/core';

@Component({
  selector: 'app-fancy-button',
  standalone: true,
  template: `
    <button (click)="handleClick()">Click Me</button>
    <input (input)="handleInput($event)" placeholder="Type something" />
  `
})
export class FancyButtonComponent {
  // output<Type>() — creates an OutputEmitterRef<Type>
  clicked      = output<void>();   // ← no value emitted
  valueChanged = output<number>(); // ← emits a number
  textChanged  = output<string>(); // ← emits a string

  handleClick(): void {
    this.clicked.emit();      // ← emit() — same API as EventEmitter
  }

  handleInput(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.textChanged.emit(input.value); // ← emit string value
    this.valueChanged.emit(input.value.length); // ← emit number (string length)
  }
}
```

### Parent Consuming Signal Outputs

```typescript
import { Component } from '@angular/core';
import { FancyButtonComponent } from './fancy-button.component';

@Component({
  selector: 'app-parent',
  standalone: true,
  imports: [FancyButtonComponent],
  template: `
    <!-- Template syntax is IDENTICAL to @Output() -->
    <app-fancy-button
      (clicked)="onClicked()"
      (valueChanged)="onValueChanged($event)"
      (textChanged)="onTextChanged($event)"
    />
    <p>Last text: {{ lastText }}</p>
    <p>Last length: {{ lastLength }}</p>
    <p>Click count: {{ clickCount }}</p>
  `
})
export class ParentComponent {
  lastText = '';
  lastLength = 0;
  clickCount = 0;

  onClicked(): void {
    this.clickCount++; // ← handles void output
  }

  onValueChanged(length: number): void {
    this.lastLength = length; // ← receives number emitted by child
  }

  onTextChanged(text: string): void {
    this.lastText = text; // ← receives string emitted by child
  }
}
```

### `outputFromObservable()` and `outputToObservable()`

```typescript
import { Component, output } from '@angular/core';
import { outputFromObservable, outputToObservable } from '@angular/core/rxjs-interop';
import { interval, Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({
  selector: 'app-observable-output',
  standalone: true,
  template: `<p>Tick: {{ tick }}</p>`
})
export class ObservableOutputComponent {
  tick = 0;

  // outputFromObservable — wrap an Observable as an output
  // Useful when you have an existing Observable to expose as an output
  timerTick = outputFromObservable(
    interval(1000) // ← Observable<number> that emits every second
    // ← parent can listen: (timerTick)="onTick($event)"
  );

  // Regular output
  clicked = output<string>();

  // outputToObservable — convert an output back to Observable
  // Useful for piping through RxJS operators
  clicked$ = outputToObservable(this.clicked);
  // ← now you can: this.clicked$.pipe(debounceTime(300)).subscribe(...)
}
```

### `@Output()` vs `output()` Comparison

| Feature | `@Output()` + EventEmitter | `output()` |
|---------|---------------------------|-----------|
| **Import** | `Output`, `EventEmitter` | `output` |
| **Type** | `EventEmitter<T>` | `OutputEmitterRef<T>` |
| **Emit** | `.emit(value)` | `.emit(value)` (same) |
| **Template syntax** | `(event)="handler($event)"` | `(event)="handler($event)"` (same) |
| **Observable interop** | Is-an Observable | `outputToObservable()` |
| **From Observable** | Manual subscription | `outputFromObservable()` |
| **Boilerplate** | More (two imports) | Less (one import) |
| **Performance** | Good | Slightly better (no RxJS Subject overhead) |

---

## 12.7 `model()` — Two-Way Binding with Signals (Angular 17.2+)

### The Problem `model()` Solves

Two-way binding in Angular traditionally requires coordinating an `@Input()` and a matching `@Output()` with the `Change` suffix:

```typescript
// OLD WAY — verbose two-way binding setup
@Component({ ... })
export class OldCounterComponent {
  @Input() value = 0;               // ← receive value from parent
  @Output() valueChange = new EventEmitter<number>(); // ← must be named "valueChange"
  // The naming convention "valueChange" is what makes [(value)]="..." work in parent

  increment(): void {
    this.value++;
    this.valueChange.emit(this.value); // ← must manually emit on every change
  }
}
// Parent: <app-counter [(value)]="parentValue" />
```

### `model()` — Unified Two-Way Binding Signal

```typescript
import { Component, model } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <div class="counter">
      <button (click)="decrement()">-</button>
      <span>{{ value() }}</span>   <!-- ← read model as signal -->
      <button (click)="increment()">+</button>
    </div>
  `
})
export class CounterComponent {
  // model<Type>() — creates a ModelSignal<Type>
  // Combines @Input() + @Output() with naming convention built-in
  value = model(0); // ← ModelSignal<number>, default = 0
  // This AUTOMATICALLY creates:
  //   - an @Input() named "value"
  //   - an @Output() named "valueChange" (model name + "Change")

  // model.required<Type>() — required model (no default)
  // selectedItem = model.required<Product>();

  increment(): void {
    this.value.update(v => v + 1); // ← update model signal like any writable signal
    // Angular automatically emits "valueChange" event to parent
    // Parent's two-way bound property updates automatically
  }

  decrement(): void {
    this.value.update(v => v - 1); // ← update propagates back to parent
  }
}
```

### Parent Using `[(model)]` Syntax

```typescript
import { Component, signal } from '@angular/core';
import { CounterComponent } from './counter.component';

@Component({
  selector: 'app-parent',
  standalone: true,
  imports: [CounterComponent],
  template: `
    <h2>Parent Value: {{ quantity() }}</h2>

    <!-- [(value)] two-way binds the model -->
    <!-- Equivalent to: [value]="quantity()" (valueChange)="quantity.set($event)" -->
    <app-counter [(value)]="quantity" />
    <!-- ← quantity is a signal — model() handles signal binding directly -->

    <!-- One-way bindings also work: -->
    <app-counter [value]="quantity()" />         <!-- ← read-only: no two-way -->
    <app-counter (valueChange)="onChange($event)" /> <!-- ← output only -->

    <button (click)="resetQuantity()">Reset</button>
  `
})
export class ParentComponent {
  quantity = signal(5); // ← writable signal bound two-ways to child model

  resetQuantity(): void {
    this.quantity.set(0); // ← parent changes → child model() updates automatically
  }

  onChange(newValue: number): void {
    console.log('Value changed to:', newValue);
  }
}
```

### Custom Toggle Component with `model()`

```typescript
import { Component, model, computed } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-toggle',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button
      class="toggle"
      [class.active]="checked()"
      (click)="toggle()"
      [attr.aria-checked]="checked()"
    >
      <!-- ← checked() reads model signal, class changes when model changes -->
      {{ checked() ? label() : offLabel() }}
    </button>
  `
})
export class ToggleComponent {
  checked  = model(false);          // ← ModelSignal<boolean>, two-way bindable
  label    = model('ON');           // ← ModelSignal<string>, customizable label
  offLabel = model('OFF');          // ← ModelSignal<string>, off-state label

  displayText = computed(() =>      // ← computed from model signals
    this.checked() ? this.label() : this.offLabel()
  );

  toggle(): void {
    this.checked.update(v => !v);   // ← flip boolean, auto-emits "checkedChange"
  }
}

// Parent usage:
// <app-toggle [(checked)]="isDarkMode" label="Dark" offLabel="Light" />
// isDarkMode signal is two-way bound — child toggling updates parent signal
```

---

## 12.8 Signal Queries (Angular 17.2+)

### The Problem with Decorator Queries

Traditional `@ViewChild` / `@ContentChild` require the component class to know the exact timing (after view init) and use decorators:

```typescript
// OLD WAY
@Component({ ... })
export class OldComponent implements AfterViewInit {
  @ViewChild('myInput') inputRef!: ElementRef; // ← possibly undefined before AfterViewInit
  @ViewChildren(ChildComponent) children!: QueryList<ChildComponent>; // ← QueryList

  ngAfterViewInit(): void {
    // MUST use AfterViewInit — not available in constructor
    this.inputRef.nativeElement.focus(); // ← access after view is initialized
    this.children.changes.subscribe(list => { // ← RxJS Observable for changes
      console.log('Children changed:', list);
    });
  }
}
```

### `viewChild()` — Signal-Based ViewChild

```typescript
import { Component, viewChild, ElementRef, AfterViewInit } from '@angular/core';

@Component({
  selector: 'app-view-child-demo',
  standalone: true,
  template: `
    <input #myInput placeholder="Focus me" />
    <app-child #childComp />
  `
})
export class ViewChildDemoComponent {
  // viewChild(selector) — returns Signal<T | undefined>
  // selector can be: template ref variable string, component type, directive type, token
  myInput  = viewChild<ElementRef>('myInput');   // ← Signal<ElementRef | undefined>
  childComp = viewChild(ChildComponent);          // ← Signal<ChildComponent | undefined>

  // viewChild.required(selector) — returns Signal<T>, throws if not found
  requiredInput = viewChild.required<ElementRef>('myInput'); // ← Signal<ElementRef>
  // If 'myInput' is not in the template, Angular throws at compile/runtime

  constructor() {
    // In constructor: signal exists but value is undefined (view not yet initialized)
    // console.log(this.myInput()); // ← undefined here

    // After view init: use effect() to react when the element is available
    // (Or just use it in template with | and optional chaining)
  }

  focusInput(): void {
    // Call the signal as a function to get the value
    const el = this.requiredInput(); // ← ElementRef (guaranteed non-null by .required)
    el.nativeElement.focus();         // ← access the DOM element
  }
}
```

### `viewChildren()` — Signal-Based ViewChildren

```typescript
import { Component, viewChildren, signal, computed } from '@angular/core';
import { ItemComponent } from './item.component';

@Component({
  selector: 'app-list',
  standalone: true,
  imports: [ItemComponent],
  template: `
    <app-item *ngFor="let item of items()" [data]="item" />
    <p>Total children: {{ childCount() }}</p>
  `
})
export class ListComponent {
  items = signal([1, 2, 3]);

  // viewChildren returns Signal<readonly ItemComponent[]>
  // Unlike QueryList, this is a plain readonly array wrapped in a signal
  itemComponents = viewChildren(ItemComponent); // ← Signal<readonly ItemComponent[]>

  // Use in computed — reactive derived state from query
  childCount = computed(() =>
    this.itemComponents().length // ← re-evaluates when children change
  );

  selectAll(): void {
    this.itemComponents().forEach(child => child.select()); // ← call method on each child
  }
}
```

### `contentChild()` and `contentChildren()` — Signal-Based ContentChild

```typescript
import { Component, contentChild, contentChildren } from '@angular/core';
import { TabComponent } from './tab.component';

@Component({
  selector: 'app-tab-group',
  standalone: true,
  template: `
    <div class="tab-headers">
      <button *ngFor="let tab of tabs()" (click)="tab.activate()">
        {{ tab.label() }}
      </button>
    </div>
    <ng-content />
  `
})
export class TabGroupComponent {
  // contentChild — query projected content (ng-content)
  firstTab = contentChild(TabComponent); // ← Signal<TabComponent | undefined>

  // contentChildren — query all projected content of a type
  tabs = contentChildren(TabComponent); // ← Signal<readonly TabComponent[]>

  getActiveTab() {
    return this.tabs().find(tab => tab.isActive()); // ← iterate signal array
  }
}
```

### Decorator Queries vs Signal Queries Comparison

| Feature | `@ViewChild` decorator | `viewChild()` signal |
|---------|----------------------|---------------------|
| **Return type** | `T \| undefined` (property) | `Signal<T \| undefined>` |
| **Required** | `@ViewChild({ required: true })` | `viewChild.required()` |
| **Lifecycle needed** | `ngAfterViewInit` | No — use in `computed()`/`effect()` |
| **Multiple results** | `@ViewChildren` → `QueryList<T>` | `viewChildren()` → `Signal<readonly T[]>` |
| **Change detection** | `QueryList.changes` Observable | Automatic signal tracking |
| **Read option** | `@ViewChild('ref', { read: ElementRef })` | `viewChild<ElementRef>('ref')` |
| **Interop** | Requires lifecycle hook | Works with `computed()`, `effect()` |

---

## 12.9 RxJS Interop — `toSignal()` and `toObservable()`

### Why Interop?

Angular's ecosystem has years of RxJS-based code. Signals and Observables are different paradigms:

```
OBSERVABLE vs SIGNAL mental model:

Observable:                      Signal:
─────────────────────────        ─────────────────────────
Stream of events over time       Current value that can change
Lazy (doesn't run until subscribe) Eager (has a value immediately)
Can complete or error            Never completes, no errors
Push model (data comes to you)   Pull model (you read when needed)
Requires subscribe/unsubscribe   No subscription management
Operators: map, filter, etc.     computed() for derivation

Both are valid — interop bridges the gap
```

### `toSignal()` — Observable to Signal

```typescript
import { Component, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { HttpClient } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder } from '@angular/forms';

interface User { id: number; name: string; }

@Component({
  selector: 'app-rxjs-interop',
  standalone: true,
  template: `
    <!-- toSignal signals are read like any other signal -->
    @if (user(); as u) {
      <h2>{{ u.name }}</h2>   <!-- ← reactive: updates when HTTP response arrives -->
    }
    <p>Route param: {{ userId() }}</p>
    <p>Form value: {{ formValue() | json }}</p>
  `
})
export class RxJsInteropComponent {
  private http  = inject(HttpClient);
  private route = inject(ActivatedRoute);
  private fb    = inject(FormBuilder);

  // USE CASE 1: HTTP response as signal
  // toSignal subscribes to the Observable and returns its latest value as a signal
  user = toSignal(
    this.http.get<User>('/api/user/1'),
    // ← Observable<User> → Signal<User | undefined>
    // ← initial value is undefined until HTTP responds
    { initialValue: null as User | null }
    // ← initialValue: what the signal returns before first emission
  );

  // USE CASE 2: Route params as signal (Observable of params)
  userId = toSignal(
    this.route.params,
    // ← Observable<Params> → Signal<Params | undefined>
    { initialValue: {} } // ← start with empty object
  );

  // USE CASE 3: Form value changes as signal
  form = this.fb.group({ name: [''], email: [''] });
  formValue = toSignal(
    this.form.valueChanges, // ← Observable<any> that emits on every keystroke
    { initialValue: this.form.value } // ← start with initial form value
  );
}
```

### `toSignal()` Options

```typescript
import { toSignal } from '@angular/core/rxjs-interop';
import { Subject, of, throwError } from 'rxjs';
import { inject, Injector } from '@angular/core';

// OPTION 1: initialValue — value before first emission
const stream$ = new Subject<number>();
const sig1 = toSignal(stream$, { initialValue: 0 });
// sig1() → 0 (before any emission)
// stream$.next(5) → sig1() → 5

// OPTION 2: requireSync — for Observables that emit synchronously
// Throws if Observable doesn't emit synchronously (e.g., BehaviorSubject)
import { BehaviorSubject } from 'rxjs';
const bs$ = new BehaviorSubject(42);
const sig2 = toSignal(bs$, { requireSync: true });
// sig2() → 42 immediately (no undefined, because BehaviorSubject emits sync)

// OPTION 3: rejectErrors — throw signal errors to the error boundary
const failing$ = throwError(() => new Error('API failed'));
const sig3 = toSignal(failing$, {
  rejectErrors: true // ← error thrown by observable propagates to Angular error boundary
  // Default: errors are silently ignored
});

// OPTION 4: manualCleanup — prevent auto-unsubscription
// By default, toSignal unsubscribes when the injection context (component) is destroyed
// manualCleanup: true means you handle unsubscription yourself
const sig4 = toSignal(stream$, { manualCleanup: true });
// ← useful for signals in services that outlive any single component

// OPTION 5: injector — use outside injection context
const injector = inject(Injector);
const sig5 = toSignal(stream$, { injector });
// ← allows toSignal() call outside constructor/field initializer
```

### `toObservable()` — Signal to Observable

```typescript
import { Component, signal, computed } from '@angular/core';
import { toObservable } from '@angular/core/rxjs-interop';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs/operators';
import { HttpClient } from '@angular/common/http';
import { inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-search',
  standalone: true,
  template: `
    <input [value]="searchQuery()" (input)="updateSearch($event)" placeholder="Search..." />
    <ul>
      @for (result of searchResults(); track result.id) {
        <li>{{ result.name }}</li>
      }
    </ul>
  `
})
export class SearchComponent {
  private http = inject(HttpClient);

  searchQuery = signal(''); // ← writable signal for search input

  // toObservable converts a signal to an Observable
  // Emits whenever the signal value changes
  searchQuery$ = toObservable(this.searchQuery);
  // ← Observable<string> that emits every time searchQuery changes

  // Now use RxJS operators to create a debounced search
  // Then convert back to signal for template use
  searchResults = toSignal(
    this.searchQuery$.pipe(
      debounceTime(300),          // ← wait 300ms after last keystroke
      distinctUntilChanged(),     // ← skip if same value as before
      switchMap(query =>          // ← cancel previous request, start new one
        query.length > 1
          ? this.http.get<any[]>(`/api/search?q=${query}`)
          : []                    // ← don't search for very short queries
      )
    ),
    { initialValue: [] }          // ← start with empty results
  );

  updateSearch(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchQuery.set(input.value); // ← update signal → toObservable emits → pipe runs
  }
}
```

### Signals vs Observables — Decision Table

| Scenario | Recommended | Reason |
|----------|-------------|--------|
| Component local state (counter, toggle) | Signal | Simpler, no subscription |
| HTTP request | Observable + toSignal | HTTP is inherently async stream |
| Form valueChanges | toSignal(form.valueChanges) | Bridge to signal world |
| Router params | toSignal(route.params) | Bridge to signal world |
| WebSocket stream | Observable (keep as Observable) | Ongoing stream, complex operators |
| Simple derived state | computed() | Pure, synchronous derivation |
| Complex async pipe | Observable with operators | debounce, switchMap etc |
| Shared app state | Signal in service | Simple, reactive, no BehaviorSubject |
| Animations/transitions | Observable | Time-based sequences |
| Component inputs | input() signal | Angular 17.1+ standard |
| Two-way binding | model() signal | Angular 17.2+ standard |

---

## 12.10 Signals in Services — Signal-Based State

### The Old Way: BehaviorSubject Store

```typescript
// OLD WAY — BehaviorSubject-based service
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { map } from 'rxjs/operators';

interface CartState {
  items: CartItem[];
  loading: boolean;
}

@Injectable({ providedIn: 'root' })
export class OldCartService {
  // Private mutable state
  private state$ = new BehaviorSubject<CartState>({ items: [], loading: false });

  // Public observables — derived via operators
  items$: Observable<CartItem[]> = this.state$.pipe(map(s => s.items));
  loading$: Observable<boolean>  = this.state$.pipe(map(s => s.loading));
  total$: Observable<number>     = this.items$.pipe(
    map(items => items.reduce((sum, i) => sum + i.price * i.qty, 0))
  );

  // Mutation — must go through next()
  addItem(item: CartItem): void {
    const current = this.state$.getValue(); // ← synchronous read (anti-pattern)
    this.state$.next({ ...current, items: [...current.items, item] });
  }
}

// In component: must use async pipe or subscribe
// items$ | async  ← template pipe
// this.cartService.items$.subscribe(...)  ← class subscription
```

### The New Way: Signal-Based Service

```typescript
import { Injectable, signal, computed } from '@angular/core';

interface CartItem {
  id: number;
  name: string;
  price: number;
  qty: number;
}

@Injectable({ providedIn: 'root' })
export class CartService {
  // Private writable signals — only this service can modify them
  private _items   = signal<CartItem[]>([]);      // ← internal state
  private _loading = signal(false);                // ← internal loading flag

  // Public read-only signals — consumers read but cannot write
  readonly items   = this._items.asReadonly();     // ← Signal<CartItem[]>
  readonly loading = this._loading.asReadonly();   // ← Signal<boolean>

  // Computed signals — derived state
  readonly total = computed(() =>
    this._items().reduce((sum, item) => sum + item.price * item.qty, 0)
    // ← recalculates only when items signal changes
  );

  readonly itemCount = computed(() =>
    this._items().reduce((sum, item) => sum + item.qty, 0)
    // ← total quantity across all cart items
  );

  readonly isEmpty = computed(() =>
    this._items().length === 0 // ← true when cart has no items
  );

  readonly hasExpensiveItems = computed(() =>
    this._items().some(item => item.price > 100)
    // ← true if any item costs more than $100
  );

  // Mutations — public methods that update private signals
  addItem(item: CartItem): void {
    this._items.update(items => {
      const existing = items.find(i => i.id === item.id);
      if (existing) {
        // Increment quantity if item already in cart
        return items.map(i =>
          i.id === item.id ? { ...i, qty: i.qty + 1 } : i
        );
      }
      return [...items, { ...item, qty: 1 }]; // ← add new item
    });
  }

  removeItem(id: number): void {
    this._items.update(items =>
      items.filter(i => i.id !== id) // ← remove item by id
    );
  }

  updateQuantity(id: number, qty: number): void {
    if (qty <= 0) {
      this.removeItem(id); // ← remove if quantity reaches 0
      return;
    }
    this._items.update(items =>
      items.map(i => i.id === id ? { ...i, qty } : i) // ← update specific item
    );
  }

  clearCart(): void {
    this._items.set([]); // ← reset to empty array
  }

  setLoading(loading: boolean): void {
    this._loading.set(loading); // ← toggle loading state
  }
}
```

### Using Signal Service in Components

```typescript
import { Component, inject, computed } from '@angular/core';
import { CartService } from './cart.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="cart">
      <h2>Cart ({{ cartService.itemCount() }} items)</h2>
      <!-- ← call computed signal as function — reactive in template -->

      @if (cartService.loading()) {
        <p>Loading...</p>                        <!-- ← reading signal inline -->
      }

      @if (cartService.isEmpty()) {
        <p>Your cart is empty</p>               <!-- ← computed boolean signal -->
      } @else {
        @for (item of cartService.items(); track item.id) {
          <div class="cart-item">
            <span>{{ item.name }}</span>
            <span>{{ item.price | currency }}</span>
            <button (click)="cartService.removeItem(item.id)">Remove</button>
          </div>
        }
        <div class="total">
          Total: {{ cartService.total() | currency }}  <!-- ← computed total signal -->
        </div>
      }
    </div>
  `
})
export class CartComponent {
  cartService = inject(CartService); // ← inject service directly (no constructor param)
  // ← all signal reads in template are reactive automatically
}
```

### `AuthService` with Signals

```typescript
import { Injectable, signal, computed, effect } from '@angular/core';

interface User {
  id: number;
  name: string;
  email: string;
  roles: string[];
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  // Private signals
  private _currentUser = signal<User | null>(null);
  private _token       = signal<string | null>(null);
  private _loading     = signal(false);

  // Public read-only
  readonly currentUser = this._currentUser.asReadonly(); // ← Signal<User | null>
  readonly token       = this._token.asReadonly();       // ← Signal<string | null>
  readonly loading     = this._loading.asReadonly();     // ← Signal<boolean>

  // Computed auth state
  readonly isLoggedIn = computed(() =>
    this._currentUser() !== null && this._token() !== null
    // ← true only when both user and token exist
  );

  readonly isAdmin = computed(() =>
    this._currentUser()?.roles?.includes('admin') ?? false
    // ← safe optional chaining for null user
  );

  readonly displayName = computed(() =>
    this._currentUser()?.name ?? 'Guest'
    // ← "Guest" when not logged in
  );

  constructor() {
    // Restore session from localStorage on app start
    const savedToken = localStorage.getItem('auth_token');
    const savedUser  = localStorage.getItem('auth_user');

    if (savedToken && savedUser) {
      this._token.set(savedToken);
      this._currentUser.set(JSON.parse(savedUser));
    }

    // Persist auth state to localStorage automatically
    effect(() => {
      const token = this._token();    // ← dependency
      const user  = this._currentUser(); // ← dependency

      if (token && user) {
        localStorage.setItem('auth_token', token);
        localStorage.setItem('auth_user', JSON.stringify(user));
      } else {
        localStorage.removeItem('auth_token');
        localStorage.removeItem('auth_user');
      }
    });
  }

  async login(email: string, password: string): Promise<void> {
    this._loading.set(true);
    try {
      // Simulated API call
      const response = await fetch('/api/login', {
        method: 'POST',
        body: JSON.stringify({ email, password })
      });
      const data = await response.json();
      this._token.set(data.token);
      this._currentUser.set(data.user);
    } finally {
      this._loading.set(false); // ← always clear loading, even on error
    }
  }

  logout(): void {
    this._currentUser.set(null); // ← clear user
    this._token.set(null);       // ← clear token → effect clears localStorage
  }
}
```

### BehaviorSubject vs Signal Service Comparison

| Aspect | BehaviorSubject Service | Signal Service |
|--------|------------------------|----------------|
| **State type** | `BehaviorSubject<State>` | `signal<State>()` |
| **Read value** | `.getValue()` or `async pipe` | Call as function `state()` |
| **Template read** | `state$ \| async` | `state()` |
| **Derived state** | `.pipe(map(...))` | `computed(() => ...)` |
| **Update state** | `.next(newValue)` | `.set()` or `.update()` |
| **Subscribe** | Required | Not required |
| **Unsubscribe** | Required (memory leak risk) | Automatic |
| **Synchronous read** | `.getValue()` (avoid) | Always synchronous |
| **Type safety** | Good | Excellent |
| **Boilerplate** | More | Less |

---

## 12.11 `linkedSignal()` (Angular 19)

### The Problem `linkedSignal()` Solves

Sometimes you have a "selected item" that should reset when its source list changes. With regular signals, this requires manual coordination:

```typescript
// WITHOUT linkedSignal — manual coordination problem
const products = signal<Product[]>([]);
const selectedProduct = signal<Product | null>(null);

// Problem: when products changes (e.g., user switches category),
// selectedProduct might still hold a product from the OLD list!
// You need an effect to manually reset it:

effect(() => {
  const list = products(); // ← dependency
  // Reset selection whenever list changes
  selectedProduct.set(null); // ← allowSignalWrites needed, easy to forget
}, { allowSignalWrites: true });

// This is fragile — easy to forget, creates implicit coupling
```

### `linkedSignal()` — Derived but Writable

```typescript
import { signal, linkedSignal } from '@angular/core';

interface Product { id: number; name: string; }

const products = signal<Product[]>([
  { id: 1, name: 'Apple' },
  { id: 2, name: 'Banana' },
]);

// linkedSignal — writable signal whose default value is derived from a source
// When the source changes, the linked signal resets to the new computed default
const selectedProduct = linkedSignal<Product[]>({
  source: products,                     // ← the signal to watch
  computation: (list) => list[0] ?? null // ← default value when source changes
  // ← When products changes: selectedProduct resets to first item (or null)
});

console.log(selectedProduct()); // ← { id: 1, name: 'Apple' } (computed default)

// User selects a different product — you CAN write to a linkedSignal
selectedProduct.set(products()[1]); // ← { id: 2, name: 'Banana' }
console.log(selectedProduct());     // ← { id: 2, name: 'Banana' }

// Now products list changes (e.g., category switch)
products.set([
  { id: 3, name: 'Cherry' },
  { id: 4, name: 'Date' },
]);

// selectedProduct AUTOMATICALLY RESETS to the new computed default
console.log(selectedProduct()); // ← { id: 3, name: 'Cherry' } — reset to first item!
// The previous { id: 2, name: 'Banana' } is gone — it was from the OLD list
```

### Full `linkedSignal()` Component Example

```typescript
import { Component, signal, linkedSignal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';

interface Category { id: number; name: string; }
interface Product   { id: number; name: string; categoryId: number; price: number; }

@Component({
  selector: 'app-linked-signal-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="layout">
      <div class="categories">
        <h3>Categories</h3>
        @for (cat of categories(); track cat.id) {
          <button
            [class.active]="selectedCategory()?.id === cat.id"
            (click)="selectCategory(cat)"
          >{{ cat.name }}</button>
        }
      </div>

      <div class="products">
        <h3>Products in {{ selectedCategory()?.name }}</h3>
        @for (product of productsInCategory(); track product.id) {
          <div
            class="product-card"
            [class.selected]="selectedProduct()?.id === product.id"
            (click)="selectProduct(product)"
          >
            {{ product.name }} — ${{ product.price }}
          </div>
        }
      </div>

      <div class="detail">
        <h3>Selected Product</h3>
        @if (selectedProduct(); as p) {
          <p>{{ p.name }}</p>
          <p>Price: ${{ p.price }}</p>
        } @else {
          <p>No product selected</p>
        }
      </div>
    </div>
  `
})
export class LinkedSignalDemoComponent {
  categories = signal<Category[]>([
    { id: 1, name: 'Fruits' },
    { id: 2, name: 'Vegetables' },
  ]);

  allProducts = signal<Product[]>([
    { id: 1, name: 'Apple',  categoryId: 1, price: 1.5 },
    { id: 2, name: 'Banana', categoryId: 1, price: 0.8 },
    { id: 3, name: 'Carrot', categoryId: 2, price: 2.0 },
    { id: 4, name: 'Daikon', categoryId: 2, price: 3.5 },
  ]);

  // Simple writable signal for category
  selectedCategory = signal<Category | null>(this.categories()[0]);

  // Computed: products filtered by selected category
  productsInCategory = computed(() => {
    const catId = this.selectedCategory()?.id;
    return catId
      ? this.allProducts().filter(p => p.categoryId === catId)
      : this.allProducts();
  });

  // linkedSignal: selectedProduct auto-resets when productsInCategory changes
  selectedProduct = linkedSignal<Product[]>({
    source: this.productsInCategory,  // ← watch the filtered product list
    computation: (list) => list[0] ?? null // ← default: first product in new list
    // ← When user switches category:
    //   1. productsInCategory recomputes with new category's products
    //   2. selectedProduct resets to first product in new list
    //   3. User sees the first product in the new category automatically selected
  });

  selectCategory(cat: Category): void {
    this.selectedCategory.set(cat);
    // ← selectedCategory changes → productsInCategory recomputes
    // → selectedProduct resets to first product in new category (via linkedSignal)
  }

  selectProduct(product: Product): void {
    this.selectedProduct.set(product); // ← user manually selects — writable!
    // This manual selection persists UNTIL the source (productsInCategory) changes
  }
}
```

---

## 12.12 `resource()` and `rxResource()` (Angular 19)

### The Problem: Declarative Async Data Fetching

Before `resource()`, loading async data in Angular required verbose service code:

```typescript
// OLD WAY — manual async state management
@Component({ ... })
export class OldUserComponent implements OnInit {
  user: User | null = null;   // ← data
  loading = false;            // ← loading flag
  error: string | null = null; // ← error state

  ngOnInit(): void {
    this.loading = true;
    this.userService.getUser(this.userId).subscribe({
      next: (u) => { this.user = u; this.loading = false; },
      error: (e) => { this.error = e.message; this.loading = false; }
    });
  }
  // 15 lines to do something very common
}
```

### `resource()` — Declarative Async State

```typescript
import { Component, signal, resource, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

interface User { id: number; name: string; email: string; }

@Component({
  selector: 'app-resource-demo',
  standalone: true,
  template: `
    @if (userResource.isLoading()) {
      <p>Loading user...</p>           <!-- ← reactive loading state -->
    }

    @if (userResource.error()) {
      <p>Error: {{ userResource.error() }}</p>  <!-- ← reactive error state -->
    }

    @if (userResource.value(); as user) {
      <h2>{{ user.name }}</h2>         <!-- ← reactive data value -->
      <p>{{ user.email }}</p>
    }

    <p>Status: {{ userResource.status() }}</p>  <!-- ← ResourceStatus enum -->

    <button (click)="changeUser(2)">Load User 2</button>
    <button (click)="userResource.reload()">Reload</button>  <!-- ← manual reload -->
  `
})
export class ResourceDemoComponent {
  private http = inject(HttpClient);

  userId = signal(1); // ← request parameter signal

  // resource() — declarative async resource
  userResource = resource<User, { id: number }>({
    // request: function that returns the "request parameters"
    // resource re-fetches whenever this changes
    request: () => ({ id: this.userId() }),
    // ← reads userId signal → dependency
    // ← when userId changes, loader re-runs automatically

    // loader: async function that fetches the data
    // receives the current request parameters
    loader: async ({ request }) => {
      const user = await firstValueFrom(
        this.http.get<User>(`/api/users/${request.id}`)
      );
      return user; // ← return the fetched data
    }
  });

  changeUser(id: number): void {
    this.userId.set(id);
    // ← userId signal changes → resource.request() returns new value
    // → resource automatically re-runs loader with new id
    // → isLoading() becomes true → value() becomes new user when done
  }
}
```

### ResourceStatus Enum

```typescript
import { ResourceStatus } from '@angular/core';

// ResourceStatus describes the current lifecycle state of the resource

// ResourceStatus.Idle      (0) — resource not yet requested (no request params)
// ResourceStatus.Error     (1) — loader threw an error
// ResourceStatus.Loading   (2) — first load in progress (no previous value)
// ResourceStatus.Refreshing (3) — re-loading (has previous value, loading new)
// ResourceStatus.Resolved  (4) — successfully loaded, value available
// ResourceStatus.Local     (5) — value was set locally (not from loader)

@Component({ ... })
export class StatusDemoComponent {
  myResource = resource({ ... });

  getStatusText = computed(() => {
    switch (this.myResource.status()) {
      case ResourceStatus.Idle:       return 'Not started';
      case ResourceStatus.Loading:    return 'Loading first time...';
      case ResourceStatus.Refreshing: return 'Refreshing...';   // ← has old value
      case ResourceStatus.Resolved:   return 'Data loaded';
      case ResourceStatus.Error:      return 'Error occurred';
      case ResourceStatus.Local:      return 'Locally set';
      default:                        return 'Unknown';
    }
  });
}
```

### `rxResource()` — RxJS-Based Loader

```typescript
import { Component, signal, inject } from '@angular/core';
import { rxResource } from '@angular/core/rxjs-interop';
import { HttpClient } from '@angular/common/http';

interface Product { id: number; name: string; }

@Component({
  selector: 'app-rx-resource',
  standalone: true,
  template: `
    @for (product of productsResource.value() ?? []; track product.id) {
      <p>{{ product.name }}</p>
    }
    @if (productsResource.isLoading()) {
      <p>Loading...</p>
    }
  `
})
export class RxResourceComponent {
  private http = inject(HttpClient);
  categoryId = signal(1);

  // rxResource — like resource() but loader returns an Observable
  productsResource = rxResource<Product[], { catId: number }>({
    request: () => ({ catId: this.categoryId() }), // ← reactive request params
    loader: ({ request }) =>
      // loader returns Observable (not Promise) — HttpClient natively
      this.http.get<Product[]>(`/api/products?category=${request.catId}`)
      // ← No need for firstValueFrom() — rxResource handles Observable natively
  });
}
```

### Setting Resource Value Locally

```typescript
import { resource, signal } from '@angular/core';

const userId = signal(1);
const userResource = resource({
  request: () => ({ id: userId() }),
  loader: async ({ request }) => fetchUser(request.id)
});

// You can update the resource value locally (optimistic updates)
userResource.value.set({ id: 1, name: 'Updated Name', email: 'x@y.com' });
// ← status becomes ResourceStatus.Local
// ← value() now returns the locally set value (not from server)

// reload() fetches from server again, replacing local value
userResource.reload();
// ← status becomes ResourceStatus.Refreshing
// ← when done: status becomes ResourceStatus.Resolved
```

---

## 12.13 `afterNextRender()` and `afterRender()`

### The Problem They Solve

Running DOM-dependent code in Angular was previously done with `ngAfterViewInit`, but this had an SSR problem:

```typescript
// OLD WAY — breaks during Server-Side Rendering
@Component({ ... })
export class OldChartComponent implements AfterViewInit {
  @ViewChild('canvas') canvas!: ElementRef;

  ngAfterViewInit(): void {
    // This CRASHES during SSR because:
    // 1. There is no DOM on the server
    // 2. canvas is undefined on server
    // 3. document/window don't exist on server
    new Chart(this.canvas.nativeElement, { ... }); // ← CRASH on server!
  }
}

// FIX attempt — verbose SSR guard
constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

ngAfterViewInit(): void {
  if (isPlatformBrowser(this.platformId)) { // ← must check every time
    new Chart(this.canvas.nativeElement, { ... });
  }
}
```

### `afterNextRender()` — Runs Once After First Render

```typescript
import { Component, afterNextRender, viewChild, ElementRef } from '@angular/core';

@Component({
  selector: 'app-chart',
  standalone: true,
  template: `<canvas #myCanvas width="400" height="300"></canvas>`
})
export class ChartComponent {
  canvas = viewChild.required<ElementRef>('myCanvas'); // ← signal query

  constructor() {
    // afterNextRender: runs ONCE after the NEXT render cycle
    // Automatically skipped on the server (SSR safe — no isPlatformBrowser needed!)
    afterNextRender(() => {
      // Safe to access DOM here — we're definitely in the browser
      const ctx = (this.canvas().nativeElement as HTMLCanvasElement).getContext('2d');
      // Initialize Chart.js or any other DOM-dependent library
      // new Chart(ctx, { type: 'bar', data: { ... } });
      console.log('Chart initialized on canvas:', ctx);
    });
    // ← runs once after the component's first render
    // ← NOT called again on subsequent re-renders
    // ← perfect for one-time setup: library initialization, focus, measurements
  }
}
```

### `afterRender()` — Runs After Every Render

```typescript
import { Component, afterRender, viewChild, ElementRef, signal } from '@angular/core';

@Component({
  selector: 'app-measure',
  standalone: true,
  template: `
    <div #container [style.padding]="padding()">
      <p>Content here</p>
    </div>
    <p>Container height: {{ containerHeight() }}px</p>
  `
})
export class MeasureComponent {
  container     = viewChild.required<ElementRef>('container');
  padding       = signal('16px');
  containerHeight = signal(0);

  constructor() {
    // afterRender: runs after EVERY render cycle
    // Use for measurements that depend on the current rendered state
    afterRender(() => {
      // Measure the container height after every render
      // (height changes when padding changes, when content changes, etc.)
      const height = (this.container().nativeElement as HTMLElement).offsetHeight;
      this.containerHeight.set(height);
      // ← NOTE: setting a signal inside afterRender is allowed
      // ← but be careful about causing infinite render loops
    });

    // afterRender phase options (for advanced use):
    // afterRender(() => { ... }, { phase: AfterRenderPhase.EarlyRead }) // ← before write
    // afterRender(() => { ... }, { phase: AfterRenderPhase.Write })     // ← DOM writes
    // afterRender(() => { ... }, { phase: AfterRenderPhase.MixedReadWrite }) // ← default
    // afterRender(() => { ... }, { phase: AfterRenderPhase.Read })      // ← after write
  }
}
```

### `afterNextRender` vs `afterRender` vs `ngAfterViewInit`

| Feature | `ngAfterViewInit` | `afterNextRender` | `afterRender` |
|---------|------------------|------------------|---------------|
| **When** | After view initialized | After next render | After every render |
| **Runs count** | Once | Once | Every render |
| **SSR safe** | No (need isPlatformBrowser) | Yes (auto-skipped on server) | Yes |
| **Signal queries** | Needs AfterViewInit timing | Works naturally | Works naturally |
| **Typical use** | One-time DOM init | Library init, focus, measure once | Ongoing measurements |
| **Angular version** | All | 17+ | 17+ |

---

## 12.14 `DestroyRef` and `takeUntilDestroyed()`

### The Memory Leak Problem

Every Observable subscription that isn't cleaned up when a component is destroyed is a **memory leak**:

```typescript
// OLD WAY — memory leak risk
@Component({ ... })
export class OldComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>(); // ← manual cleanup token

  ngOnInit(): void {
    this.dataService.items$.pipe(
      takeUntil(this.destroy$) // ← must add to every subscription
    ).subscribe(items => {
      this.items = items;
    });
    // If you forget takeUntil, subscription lives forever → memory leak
  }

  ngOnDestroy(): void {
    this.destroy$.next(); // ← must manually trigger
    this.destroy$.complete();
    // Must remember to implement OnDestroy AND call next/complete
  }
}
```

### `takeUntilDestroyed()` — Automatic Cleanup

```typescript
import { Component, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { DataService } from './data.service';

@Component({
  selector: 'app-auto-cleanup',
  standalone: true,
  template: `<ul><li *ngFor="let item of items">{{ item }}</li></ul>`
})
export class AutoCleanupComponent implements OnInit {
  private dataService = inject(DataService);
  items: string[] = [];

  // takeUntilDestroyed() in field initializer — simplest form
  // Uses the component's injection context to know when to destroy
  private readonly destroy$ = takeUntilDestroyed(); // ← creates a DestroyRef-backed operator

  ngOnInit(): void {
    this.dataService.items$
      .pipe(
        takeUntilDestroyed() // ← when used in injection context (constructor/field init)
        // ← automatically unsubscribes when the component is destroyed
        // ← NO ngOnDestroy needed!
      )
      .subscribe(items => {
        this.items = items;
      });
  }
}
```

### `inject(DestroyRef)` — Programmatic Destroy Notification

```typescript
import { Component, inject, OnInit } from '@angular/core';
import { DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { interval } from 'rxjs';

@Component({
  selector: 'app-destroy-ref',
  standalone: true,
  template: `<p>Tick: {{ tick }}</p>`
})
export class DestroyRefComponent implements OnInit {
  tick = 0;
  private destroyRef = inject(DestroyRef); // ← inject the DestroyRef token

  ngOnInit(): void {
    // Use destroyRef with takeUntilDestroyed outside constructor
    interval(1000)
      .pipe(takeUntilDestroyed(this.destroyRef)) // ← pass destroyRef explicitly
      .subscribe(() => this.tick++);
    // ← when component destroys, destroyRef notifies takeUntilDestroyed
    // ← subscription automatically cleaned up — no memory leak

    // DestroyRef also has onDestroy() for non-RxJS cleanup
    this.destroyRef.onDestroy(() => {
      console.log('Component destroyed — cleaning up!');
      // ← run any cleanup code here
      // ← equivalent to ngOnDestroy but injectable/composable
    });
  }
}
```

### `takeUntilDestroyed()` Outside Constructor

```typescript
import { inject, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { Observable } from 'rxjs';

// Utility function that can be called OUTSIDE a component's injection context
function createAutoCleanupSubscription<T>(
  obs$: Observable<T>,
  destroyRef: DestroyRef, // ← must pass destroyRef when calling outside injection context
  handler: (value: T) => void
): void {
  obs$.pipe(
    takeUntilDestroyed(destroyRef) // ← explicit destroyRef when no injection context
  ).subscribe(handler);
}

// Usage in component:
@Component({ ... })
export class MyComponent implements OnInit {
  private destroyRef = inject(DestroyRef);
  private data$: Observable<string[]> = inject(DataService).items$;

  ngOnInit(): void {
    // ngOnInit is NOT an injection context, so pass destroyRef explicitly
    createAutoCleanupSubscription(
      this.data$,
      this.destroyRef, // ← pass destroyRef to function
      (items) => console.log('Items:', items)
    );
  }
}
```

---

## 12.15 Practical Example — Complete Signal-Based App

### Product Management App

This example ties together all signal concepts from this phase into a cohesive, real-world application.

```typescript
// product.model.ts — data types
export interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
  inStock: boolean;
  imageUrl: string;
}

export interface CartItem extends Product {
  quantity: number;
}
```

```typescript
// product.service.ts — signal-based service with resource()
import { Injectable, signal, computed, effect, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { rxResource } from '@angular/core/rxjs-interop';
import { Product, CartItem } from './product.model';

@Injectable({ providedIn: 'root' })
export class ProductService {
  private http = inject(HttpClient);

  // ── Filters ──────────────────────────────────────────────────────────────
  searchQuery  = signal('');                   // ← user's search text
  activeCategory = signal<string>('all');      // ← selected category filter
  sortBy       = signal<'name' | 'price'>('name'); // ← sort field

  // ── Async resource: load products from API ───────────────────────────────
  productsResource = rxResource<Product[], { category: string }>({
    request: () => ({ category: this.activeCategory() }), // ← reactive: re-fetches on category change
    loader: ({ request }) =>
      request.category === 'all'
        ? this.http.get<Product[]>('/api/products')
        : this.http.get<Product[]>(`/api/products?category=${request.category}`)
  });

  // ── Computed: filtered + sorted product list ─────────────────────────────
  filteredProducts = computed(() => {
    const products = this.productsResource.value() ?? []; // ← use resource value (or empty)
    const query    = this.searchQuery().toLowerCase();    // ← read search query
    const sortField = this.sortBy();                      // ← read sort field

    return products
      .filter(p =>
        query === '' || p.name.toLowerCase().includes(query) // ← filter by search
      )
      .sort((a, b) =>
        sortField === 'name'
          ? a.name.localeCompare(b.name)    // ← sort alphabetically
          : a.price - b.price               // ← sort by price ascending
      );
  });

  // ── Cart state ────────────────────────────────────────────────────────────
  private _cartItems = signal<CartItem[]>([]);     // ← private cart state
  readonly cartItems = this._cartItems.asReadonly(); // ← public read-only

  cartTotal = computed(() =>
    this._cartItems().reduce((sum, item) => sum + item.price * item.quantity, 0)
  );

  cartCount = computed(() =>
    this._cartItems().reduce((sum, item) => sum + item.quantity, 0)
  );

  constructor() {
    // Persist cart to localStorage automatically
    effect(() => {
      const cart = this._cartItems(); // ← dependency: re-runs when cart changes
      localStorage.setItem('cart', JSON.stringify(cart));
      // ← every cart change is automatically persisted
    });

    // Restore cart from localStorage on app start
    const saved = localStorage.getItem('cart');
    if (saved) {
      this._cartItems.set(JSON.parse(saved)); // ← hydrate from storage
    }
  }

  addToCart(product: Product): void {
    this._cartItems.update(items => {
      const existing = items.find(i => i.id === product.id);
      if (existing) {
        return items.map(i =>
          i.id === product.id ? { ...i, quantity: i.quantity + 1 } : i
        );
      }
      return [...items, { ...product, quantity: 1 }]; // ← new item with qty 1
    });
  }

  removeFromCart(id: number): void {
    this._cartItems.update(items => items.filter(i => i.id !== id));
  }
}
```

```typescript
// product-card.component.ts — signal inputs/outputs
import { Component, input, output, computed } from '@angular/core';
import { Product } from './product.model';
import { CurrencyPipe } from '@angular/common';

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CurrencyPipe],
  template: `
    <div class="product-card" [class.out-of-stock]="!product().inStock">

      <img [src]="product().imageUrl" [alt]="product().name" />

      <div class="info">
        <h3>{{ product().name }}</h3>              <!-- ← reads input signal -->
        <p class="price">{{ product().price | currency }}</p>
        <p class="category">{{ product().category }}</p>

        <span class="badge" [class.in-stock]="product().inStock">
          {{ stockLabel() }}                       <!-- ← reads computed signal -->
        </span>
      </div>

      <div class="actions">
        <button
          (click)="onAddToCart()"
          [disabled]="!product().inStock"          <!-- ← reads input signal -->
        >
          Add to Cart
        </button>

        <button (click)="onViewDetails()">
          View Details
        </button>
      </div>
    </div>
  `
})
export class ProductCardComponent {
  // Signal inputs — replace @Input() decorators
  product     = input.required<Product>();        // ← required: must be provided
  isInCart    = input(false);                     // ← optional with default
  cartQuantity = input(0, {
    transform: (v: number | string) => Number(v) // ← coerce string to number
  });

  // Signal outputs — replace @Output() + EventEmitter
  addToCart   = output<Product>();                // ← emits Product when added
  viewDetails = output<number>();                 // ← emits product id

  // Computed from input signal
  stockLabel = computed(() =>
    this.product().inStock ? 'In Stock' : 'Out of Stock'
    // ← re-evaluates when product input changes
  );

  onAddToCart(): void {
    this.addToCart.emit(this.product()); // ← emit input signal value
  }

  onViewDetails(): void {
    this.viewDetails.emit(this.product().id); // ← emit product id
  }
}
```

```typescript
// product-list.component.ts — ties everything together
import { Component, inject, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProductService } from './product.service';
import { ProductCardComponent } from './product-card.component';
import { Product } from './product.model';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule, FormsModule, ProductCardComponent],
  template: `
    <!-- Search and filter controls -->
    <div class="controls">
      <input
        [value]="productService.searchQuery()"
        (input)="onSearch($event)"
        placeholder="Search products..."
      />

      <select
        [value]="productService.activeCategory()"
        (change)="onCategoryChange($event)"
      >
        <option value="all">All Categories</option>
        @for (cat of categories(); track cat) {
          <option [value]="cat">{{ cat }}</option>
        }
      </select>

      <select
        [value]="productService.sortBy()"
        (change)="onSortChange($event)"
      >
        <option value="name">Sort by Name</option>
        <option value="price">Sort by Price</option>
      </select>
    </div>

    <!-- Loading state -->
    @if (productService.productsResource.isLoading()) {
      <div class="loading-spinner">Loading products...</div>
    }

    <!-- Error state -->
    @if (productService.productsResource.error()) {
      <div class="error">
        Failed to load products.
        <button (click)="productService.productsResource.reload()">Retry</button>
      </div>
    }

    <!-- Product grid -->
    <div class="product-grid">
      @for (product of productService.filteredProducts(); track product.id) {
        <app-product-card
          [product]="product"
          [isInCart]="isInCart(product.id)"
          [cartQuantity]="getCartQuantity(product.id)"
          (addToCart)="productService.addToCart($event)"
          (viewDetails)="onViewDetails($event)"
        />
      } @empty {
        <p class="no-results">No products found for "{{ productService.searchQuery() }}"</p>
      }
    </div>

    <!-- Cart summary -->
    <div class="cart-summary">
      <span>{{ productService.cartCount() }} items</span>
      <span>Total: {{ productService.cartTotal() | currency }}</span>
    </div>
  `
})
export class ProductListComponent {
  productService = inject(ProductService); // ← inject service with all signals

  // Local component signal for modal state
  selectedProductId = signal<number | null>(null);

  // Computed: unique categories from loaded products
  categories = computed(() => {
    const products = this.productService.productsResource.value() ?? [];
    return [...new Set(products.map(p => p.category))].sort(); // ← unique sorted categories
  });

  // Helper: check if a product is in cart
  isInCart(productId: number): boolean {
    return this.productService.cartItems().some(i => i.id === productId);
  }

  // Helper: get cart quantity for a product
  getCartQuantity(productId: number): number {
    return this.productService.cartItems().find(i => i.id === productId)?.quantity ?? 0;
  }

  onSearch(event: Event): void {
    this.productService.searchQuery.set(
      (event.target as HTMLInputElement).value
      // ← update service signal → filteredProducts recomputes automatically
    );
  }

  onCategoryChange(event: Event): void {
    this.productService.activeCategory.set(
      (event.target as HTMLSelectElement).value
      // ← update category → resource re-fetches → filteredProducts recomputes
    );
  }

  onSortChange(event: Event): void {
    this.productService.sortBy.set(
      (event.target as HTMLSelectElement).value as 'name' | 'price'
    );
  }

  onViewDetails(productId: number): void {
    this.selectedProductId.set(productId); // ← local signal update
    // open modal, navigate to detail page, etc.
  }
}
```

---

## 12.16 Migration from Traditional to Signals

### Migration Priority and Strategy

Not everything needs to migrate at once. Signals and traditional patterns coexist in the same application:

```
MIGRATION PRIORITY GUIDE:

High Value (migrate first):
─────────────────────────────────────────────────────
1. Local component state           @Input → input()
   (no side effects, most common)  @Output → output()
                                   local vars → signal()
                                   ngOnChanges → computed()

2. Service state stores            BehaviorSubject → signal()
   (immediate reactivity benefit)  Observable chains → computed()

3. Template-driven async           async pipe → toSignal()
   (simplify templates)

Lower Priority (migrate later):
─────────────────────────────────────────────────────
4. Complex RxJS pipelines          Keep as Observable (switchMap, etc.)
   (operators are RxJS strength)   Use toSignal() at the end

5. ViewChild/ContentChild          Migrate when touching the component anyway
```

### Before → After: `@Input()` to `input()`

```typescript
// ─────────── BEFORE ─────────────────────────────────────────────────────────
import { Component, Input, OnChanges, SimpleChanges } from '@angular/core';

@Component({ selector: 'app-user', template: `<p>{{ fullName }}</p>` })
export class UserComponentBefore implements OnChanges {
  @Input() firstName = '';   // ← plain property
  @Input() lastName  = '';   // ← plain property
  @Input({ required: true }) userId!: number; // ← required in Angular 16+

  fullName = ''; // ← must be manually kept in sync

  ngOnChanges(changes: SimpleChanges): void {
    // ← must implement lifecycle hook just to react to input changes
    if (changes['firstName'] || changes['lastName']) {
      this.fullName = `${this.firstName} ${this.lastName}`; // ← manual derivation
    }
  }
}

// ─────────── AFTER ──────────────────────────────────────────────────────────
import { Component, input, computed } from '@angular/core';

@Component({ selector: 'app-user', template: `<p>{{ fullName() }}</p>` })
export class UserComponentAfter {
  firstName = input('');               // ← signal input with default
  lastName  = input('');               // ← signal input with default
  userId    = input.required<number>(); // ← required signal input

  fullName = computed(() =>
    `${this.firstName()} ${this.lastName()}` // ← automatic derivation, no lifecycle hook
  );
  // ← no ngOnChanges needed
  // ← fullName stays in sync automatically
}
```

### Before → After: `@Output()` to `output()`

```typescript
// ─────────── BEFORE ─────────────────────────────────────────────────────────
import { Component, Output, EventEmitter } from '@angular/core';

@Component({ selector: 'app-btn', template: `<button (click)="click()">Go</button>` })
export class ButtonBefore {
  @Output() action = new EventEmitter<string>(); // ← two imports, EventEmitter

  click(): void {
    this.action.emit('clicked'); // ← same emit API
  }
}

// ─────────── AFTER ──────────────────────────────────────────────────────────
import { Component, output } from '@angular/core';

@Component({ selector: 'app-btn', template: `<button (click)="click()">Go</button>` })
export class ButtonAfter {
  action = output<string>(); // ← single import, cleaner

  click(): void {
    this.action.emit('clicked'); // ← identical emit API
  }
}
```

### Before → After: BehaviorSubject Service to Signal Service

```typescript
// ─────────── BEFORE ─────────────────────────────────────────────────────────
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class CounterServiceBefore {
  private count$ = new BehaviorSubject(0);    // ← BehaviorSubject

  readonly value$ = this.count$.asObservable(); // ← expose as Observable
  readonly doubled$ = this.count$.pipe(map(n => n * 2)); // ← derived via pipe

  increment(): void { this.count$.next(this.count$.getValue() + 1); }
  reset(): void { this.count$.next(0); }
}
// Component must use: countService.value$ | async

// ─────────── AFTER ──────────────────────────────────────────────────────────
import { Injectable, signal, computed } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class CounterServiceAfter {
  private _count = signal(0);                        // ← writable signal

  readonly value   = this._count.asReadonly();       // ← read-only signal
  readonly doubled = computed(() => this._count() * 2); // ← computed derivation

  increment(): void { this._count.update(n => n + 1); }
  reset(): void { this._count.set(0); }
}
// Component uses: countService.value() — no async pipe needed
```

### Before → After: `ngOnChanges` to `computed()`

```typescript
// ─────────── BEFORE ─────────────────────────────────────────────────────────
@Component({ ... })
export class FilterComponentBefore implements OnChanges {
  @Input() items: string[] = [];
  @Input() searchTerm = '';
  filtered: string[] = []; // ← derived state as plain property

  ngOnChanges(changes: SimpleChanges): void {
    // ← runs on EVERY input change, even unrelated ones
    if (changes['items'] || changes['searchTerm']) {
      this.filtered = this.items.filter(item =>
        item.toLowerCase().includes(this.searchTerm.toLowerCase())
      );
    }
  }
}

// ─────────── AFTER ──────────────────────────────────────────────────────────
@Component({ ... })
export class FilterComponentAfter {
  items      = input<string[]>([]);   // ← signal input
  searchTerm = input('');             // ← signal input

  filtered = computed(() =>
    this.items().filter(item =>
      item.toLowerCase().includes(this.searchTerm().toLowerCase())
      // ← automatically re-evaluates when items or searchTerm changes
      // ← no lifecycle hook, no manual tracking
    )
  );
}
```

### Step-by-Step Migration Checklist

```
SIGNAL MIGRATION CHECKLIST
═══════════════════════════════════════════════════════════════════════

PHASE A: Component Inputs/Outputs (Angular 17.1+, low risk)
───────────────────────────────────────────────────────────
□ Replace @Input() with input()
□ Replace @Input({ required: true }) with input.required()
□ Replace @Input({ transform }) with input(default, { transform })
□ Replace @Input('alias') with input(default, { alias })
□ Update template: userId → userId() (add parentheses)
□ Remove ngOnChanges — replace logic with computed()
□ Replace @Output() + EventEmitter with output()
□ Remove EventEmitter import

PHASE B: Local Component State (always safe)
─────────────────────────────────────────────
□ Replace boolean/number/string properties with signal()
□ Replace computed properties with computed()
□ Replace ngOnChanges derived logic with computed()
□ Replace BehaviorSubject local state with signal()
□ Update template: prop → prop() (add parentheses)

PHASE C: ViewChild/ContentChild (Angular 17.2+)
────────────────────────────────────────────────
□ Replace @ViewChild with viewChild()
□ Replace @ViewChild({ required: true }) with viewChild.required()
□ Replace @ViewChildren with viewChildren()
□ Replace @ContentChild with contentChild()
□ Replace @ContentChildren with contentChildren()
□ Move ngAfterViewInit code to afterNextRender() or effect()
□ Update access: this.el → this.el() (add parentheses)

PHASE D: Service State (high impact)
──────────────────────────────────────
□ Replace BehaviorSubject<T> with signal<T>()
□ Replace .asObservable() with .asReadonly()
□ Replace Observable chains with computed()
□ Replace .next() with .set() or .update()
□ Remove async pipe from templates — use signal() directly
□ Add toSignal() to bridge remaining Observables

PHASE E: Async Data (Angular 19, resource())
─────────────────────────────────────────────
□ Identify Observable data loads in ngOnInit
□ Replace with resource() or rxResource()
□ Remove manual loading/error state management
□ Use resource.isLoading(), resource.error(), resource.value()

PHASE F: Cleanup (after each phase)
──────────────────────────────────────
□ Remove unused imports (BehaviorSubject, EventEmitter, etc.)
□ Remove unnecessary lifecycle hooks (ngOnChanges, ngOnDestroy)
□ Add takeUntilDestroyed() to remaining Observable subscriptions
□ Replace ngAfterViewInit DOM init with afterNextRender()
□ Run tests after each phase to catch regressions
```

---

## 12.17 Summary

### Key Concepts Recap

```
ANGULAR SIGNALS — COMPLETE MENTAL MAP
══════════════════════════════════════════════════════════════════════

PRIMITIVES:
┌─────────────────┬──────────────────────────────────────────────────┐
│ signal(v)        │ Writable signal. .set(), .update(), .asReadonly() │
│ computed(fn)     │ Read-only derived signal. Lazy. Memoized.         │
│ effect(fn)       │ Side effect runner. Auto-tracks dependencies.     │
│ linkedSignal(opts)│ Writable signal that resets from a source.      │
└─────────────────┴──────────────────────────────────────────────────┘

COMPONENT INTEGRATION:
┌─────────────────┬──────────────────────────────────────────────────┐
│ input()          │ Signal-based @Input() replacement (17.1+)         │
│ input.required() │ Mandatory input signal                            │
│ output()         │ Signal-based @Output() replacement (17.1+)        │
│ model()          │ Two-way binding signal (17.2+)                    │
│ viewChild()      │ Signal-based @ViewChild replacement (17.2+)       │
│ viewChildren()   │ Signal-based @ViewChildren replacement (17.2+)    │
│ contentChild()   │ Signal-based @ContentChild replacement (17.2+)    │
│ contentChildren()│ Signal-based @ContentChildren replacement (17.2+) │
└─────────────────┴──────────────────────────────────────────────────┘

RXJS INTEROP:
┌─────────────────┬──────────────────────────────────────────────────┐
│ toSignal(obs$)   │ Subscribe to Observable, expose as Signal         │
│ toObservable(sig)│ Create Observable from Signal                     │
│ outputFromObservable(obs$) │ Wrap Observable as output()             │
│ outputToObservable(out)    │ Convert output() to Observable          │
└─────────────────┴──────────────────────────────────────────────────┘

ASYNC & LIFECYCLE:
┌─────────────────┬──────────────────────────────────────────────────┐
│ resource()       │ Declarative async data loading (19+)             │
│ rxResource()     │ resource() with Observable loader (19+)          │
│ afterNextRender()│ Run once after first render (browser only) (17+) │
│ afterRender()    │ Run after every render (browser only) (17+)      │
│ DestroyRef       │ Programmatic destroy notification (16+)          │
│ takeUntilDestroyed() │ Auto-unsubscribe operator (16+)              │
└─────────────────┴──────────────────────────────────────────────────┘
```

### Signal Gotchas List

```
SIGNAL GOTCHAS — READ BEFORE SHIPPING TO PRODUCTION
═════════════════════════════════════════════════════════════════════

GOTCHA 1: Forgetting () to read a signal
─────────────────────────────────────────
  ❌ Wrong:  <p>{{ count }}</p>        → shows "[object Object]"
  ✓ Correct: <p>{{ count() }}</p>      → shows the value

GOTCHA 2: Mutating objects/arrays directly
──────────────────────────────────────────
  ❌ Wrong:  this.items().push(newItem)  → mutates in place, NO notification sent
  ✓ Correct: this.items.update(list => [...list, newItem]) → new reference = notification

GOTCHA 3: Side effects in computed()
──────────────────────────────────────
  ❌ Wrong:  computed(() => { console.log('!'); return count() * 2; })
  ✓ Correct: use effect() for side effects, computed() for pure derivation

GOTCHA 4: Writing signals inside effect() without allowSignalWrites
────────────────────────────────────────────────────────────────────
  ❌ Throws: effect(() => { otherSignal.set(count()); })
  ✓ Option A: effect(() => { ... }, { allowSignalWrites: true })
  ✓ Option B: prefer computed() instead — it handles derived state better

GOTCHA 5: Creating effects outside injection context
──────────────────────────────────────────────────────
  ❌ Throws: "effect() can only be used within an injection context"
  ✓ Fix:    move to constructor, or pass { injector: this.injector }

GOTCHA 6: Using toSignal() outside injection context
──────────────────────────────────────────────────────
  ❌ Throws in ngOnInit, ngAfterViewInit, click handlers
  ✓ Fix:    call in constructor/field initializer, or pass { injector }

GOTCHA 7: model() naming convention
──────────────────────────────────────
  model('checked') automatically creates output 'checkedChange'
  If parent uses [(checked)] Angular looks for (checkedChange) event
  ← this is why model() works with [()] banana-in-box syntax

GOTCHA 8: linkedSignal resets on source change
───────────────────────────────────────────────
  If user manually sets a linkedSignal and then its source changes,
  the manual value is DISCARDED and computation fn runs again.
  This is intended behavior — keep it in mind for UX decisions.

GOTCHA 9: resource() starts loading immediately
────────────────────────────────────────────────
  resource() starts loading as soon as request() returns a non-undefined value.
  To delay loading, return undefined from request() initially:
  request: () => this.isReady() ? { id: this.userId() } : undefined
  ← resource stays Idle until isReady() becomes true

GOTCHA 10: Signal equality by default uses ===
───────────────────────────────────────────────
  signal({name:'Alice'}).set({name:'Alice'}) → TWO DIFFERENT OBJECTS
  → notification IS sent (different references)
  → Use custom equal fn for value-based equality on objects/arrays
```

### Version Reference Table

| Feature | Angular Version | Status |
|---------|----------------|--------|
| `signal()`, `computed()`, `effect()` | 16 (developer preview) | Stable in 17 |
| `toSignal()`, `toObservable()` | 16 | Stable |
| `takeUntilDestroyed()`, `DestroyRef` | 16 | Stable |
| `afterNextRender()`, `afterRender()` | 17 | Stable |
| `input()`, `output()` | 17.1 | Stable |
| `model()` | 17.2 | Stable |
| `viewChild()`, `viewChildren()` | 17.2 | Stable |
| `contentChild()`, `contentChildren()` | 17.2 | Stable |
| `linkedSignal()` | 19 | Stable |
| `resource()`, `rxResource()` | 19 | Developer Preview |

---

> **Next Phase:** [Phase 13 — Change Detection & Performance](./Phase13-Change-Detection-Performance.md)
>
> Phase 13 dives deep into `ChangeDetectionStrategy.OnPush`, zone-less applications, the Angular profiler, `NgOptimizedImage`, and advanced performance patterns that build directly on the signal knowledge from this phase.
