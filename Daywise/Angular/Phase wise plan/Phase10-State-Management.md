# Phase 10: State Management

> "The hardest part of building a frontend application is not rendering the UI -- it is managing the data that drives it." As your Angular application grows beyond a handful of components, the question of WHERE your data lives, WHO can change it, and HOW changes propagate becomes the single biggest source of bugs. This phase takes you from scattered, unpredictable state to clean, centralized, debuggable state management -- covering everything from simple BehaviorSubject patterns to full NgRx with Effects and Entity.

---

## 10.1 Why State Management Matters

### What Is "State" in a Frontend App?

**State** is any data that can change over time and affects what the user sees or can do. If it changes, it is state.

Frontend applications deal with several distinct TYPES of state:

| State Type | What It Is | Examples | Where It Lives |
|---|---|---|---|
| **UI State** | Visual/interaction state | Is the sidebar open? Which tab is active? Is a modal visible? | Component properties |
| **Server State** | Data fetched from an API | List of products, user profile, order history | Services / Store |
| **URL State** | Data encoded in the URL | Current page, search query, selected item ID | Router |
| **Form State** | User input in forms | Username field value, is email valid?, has form been touched? | Reactive Forms / Template |
| **Client State** | App-level data not from the server | Shopping cart contents, user preferences, theme selection | Services / Store / localStorage |

```
State in a typical Angular e-commerce app:

┌─────────────────────────────────────────────────────────────┐
│                       APPLICATION STATE                      │
├──────────────┬──────────────┬───────────────┬───────────────┤
│  UI State    │ Server State │  URL State    │  Form State   │
├──────────────┼──────────────┼───────────────┼───────────────┤
│ sidebar open │ products[]   │ /products?    │ search input  │
│ modal visible│ user profile │   page=2&     │ login form    │
│ loading flag │ cart items   │   sort=price  │ checkout form │
│ active tab   │ orders[]     │ /product/42   │ filter values │
│ theme: dark  │ categories[] │ /cart         │ address form  │
└──────────────┴──────────────┴───────────────┴───────────────┘
```

### The Problem: State Chaos as Apps Grow

In a small app with 5-10 components, you can pass data around with `@Input()` and `@Output()`. But as an app grows to 50, 100, or 500+ components, state management without a system becomes a nightmare.

```
SMALL APP (5 components) -- manageable:

    App
   ╱   ╲
  Nav   Content
        ╱    ╲
     List    Detail

Data flows simply through parent → child.
Easy to trace. Easy to debug.


LARGE APP (50+ components) -- chaos:

                          App
                   ╱    ╱    ╲    ╲
               Nav  Sidebar  Main  Footer
              ╱  ╲     │    ╱ ╲ ╲    │
          Logo  Menu  Filter   ...  Links
                 │     │  ╲
              SubMenu  A    B
                       │
                       C ← needs data from Nav!
                           How does it get there?
                           @Input() chain? Service? Event bus?
                           WHO KNOWS?!
```

Here are the specific problems that arise:

| Problem | Description | Real Consequence |
|---|---|---|
| **Prop Drilling** | Passing data through 5+ levels of components that do not even USE the data | Fragile code, every intermediate component must forward props |
| **Inconsistent State** | Two components show different values for the same data | User sees "3 items in cart" in header, but "2 items" in sidebar |
| **Unpredictable Mutations** | Any component can change shared data at any time | Bugs that are impossible to reproduce or trace |
| **No Single Source of Truth** | Same data duplicated in multiple places | One copy gets updated, the other does not -- now they disagree |
| **Hard to Debug** | No record of WHAT changed, WHEN, or WHY | "The cart total is wrong but I have no idea which component did this" |
| **Testing Difficulty** | Components tightly coupled to data sources | Cannot test a component without setting up its entire data chain |

### Real-World Analogy: The Restaurant With No Central Order System

Imagine a busy restaurant with 10 tables, 3 waiters, and a kitchen:

```
WITHOUT central order system (state chaos):

  Table 1: "I ordered steak!" ──→ Waiter A remembers in his head
  Table 3: "Cancel my soup!" ──→ Waiter B never hears about it
  Kitchen: "What did Table 5 order?" ──→ Nobody knows for sure
  Table 7: "I've been waiting 40 minutes!" ──→ Order was forgotten

  Problems:
  - Orders in multiple waiters' heads (scattered state)
  - No way to check what was ordered (no single source of truth)
  - Cancellations get lost (mutations not tracked)
  - Kitchen gets conflicting info (inconsistent state)

WITH central order system (managed state):

  ┌──────────────────────────────────┐
  │     CENTRAL ORDER SYSTEM         │
  │  (Single Source of Truth)        │
  │                                  │
  │  Table 1: Steak (pending)        │
  │  Table 3: Soup (CANCELLED)       │
  │  Table 5: Pasta (cooking)        │
  │  Table 7: Salad (served)         │
  └──────────┬───────────────────────┘
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
  Waiter A  Waiter B  Kitchen
  (reads)   (reads)   (reads)

  Everyone reads from ONE place.
  Changes go THROUGH the system.
  Full history of every order change.
```

### State Management = Organized State Flow

```
WITHOUT state management:

  Component A ──────────→ Component B
       │    ←────────────     │
       │                      │
       ▼                      ▼
  Component C ──→ Service ──→ Component D
       │              │           │
       └──── ??? ─────┘     ??? ──┘

  Data flows EVERYWHERE. No rules. No traceability.


WITH state management:

  ┌─────────────────────────────────────┐
  │              STORE                   │
  │         (Single Source of Truth)     │
  │                                     │
  │  { products: [...], cart: [...] }   │
  └──────────────┬──────────────────────┘
                 │
        ┌────────┼────────┬──────────┐
        ▼        ▼        ▼          ▼
   Component  Component  Component  Component
      A          B          C          D

  All components READ from the store.
  All changes go THROUGH defined channels.
  Every change is traceable and predictable.
```

---

## 10.2 Service-Based State Management (The Angular Way)

### The BehaviorSubject Store Pattern

Before reaching for a full state management library, Angular provides everything you need for simple-to-medium state management using **services + BehaviorSubject**. This is the most "Angular-native" approach and is recommended by the Angular team for most applications.

```
BehaviorSubject Store Pattern:

  ┌────────────────────────────────────────┐
  │           Store Service                 │
  │                                        │
  │  private state$ = BehaviorSubject      │
  │        ▲            │                  │
  │        │            ▼                  │
  │   setState()   asObservable()          │
  │   (methods)    (public read-only)      │
  └────────┬────────────┬─────────────────┘
           │            │
    Components call     Components subscribe
    methods to update   to read state
```

**Why BehaviorSubject specifically?**

| Observable Type | Has Initial Value? | Emits Last Value to New Subscribers? | Use for State? |
|---|---|---|---|
| `Subject` | No | No -- new subscribers miss past values | Bad for state |
| `BehaviorSubject` | **Yes** | **Yes** -- always emits current value immediately | **Perfect for state** |
| `ReplaySubject` | No | Yes -- replays N past values | Overkill for state |
| `AsyncSubject` | No | Only emits last value on complete | Not suitable |

### Complete Example: Shopping Cart Store Service

Let us build a complete shopping cart with the BehaviorSubject pattern:

```typescript
// ─── cart.models.ts ─── Define the shape of our state FIRST

export interface CartItem {
  productId: number;
  productName: string;
  price: number;
  quantity: number;
}

export interface CartState {                // ← State interface: the "shape" of our state
  items: CartItem[];                        // ← All items currently in cart
  loading: boolean;                         // ← Are we doing an async operation?
  error: string | null;                     // ← Last error message, if any
}

// ← Define initial state as a constant -- this is what the store starts with
export const initialCartState: CartState = {
  items: [],                                // ← Cart starts empty
  loading: false,                           // ← Not loading anything initially
  error: null                               // ← No errors initially
};
```

```typescript
// ─── cart-store.service.ts ─── The actual store

import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { map, distinctUntilChanged } from 'rxjs/operators';
import { CartState, CartItem, initialCartState } from './cart.models';

@Injectable({
  providedIn: 'root'                        // ← Singleton: ONE instance for the entire app
})
export class CartStore {

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE state -- only THIS service can directly modify state
  // ═══════════════════════════════════════════════════════════════
  private state$ = new BehaviorSubject<CartState>(initialCartState);  // ← Private! Components cannot directly push values

  // ═══════════════════════════════════════════════════════════════
  // PUBLIC observables -- components SUBSCRIBE to these (read-only)
  // ═══════════════════════════════════════════════════════════════
  readonly cart$: Observable<CartState> = this.state$.asObservable();  // ← asObservable() strips away the .next() method

  // ← Derived state: select SPECIFIC slices of state using map()
  readonly items$: Observable<CartItem[]> = this.select(state => state.items);     // ← Only the items array
  readonly loading$: Observable<boolean> = this.select(state => state.loading);    // ← Only the loading flag
  readonly error$: Observable<string | null> = this.select(state => state.error);  // ← Only the error

  // ← Computed state: values DERIVED from the raw state
  readonly itemCount$: Observable<number> = this.select(                           // ← Total number of items
    state => state.items.reduce((total, item) => total + item.quantity, 0)
  );

  readonly totalPrice$: Observable<number> = this.select(                          // ← Total price of all items
    state => state.items.reduce((total, item) => total + (item.price * item.quantity), 0)
  );

  readonly isEmpty$: Observable<boolean> = this.select(                            // ← Is the cart empty?
    state => state.items.length === 0
  );

  // ═══════════════════════════════════════════════════════════════
  // SELECT helper -- creates a derived observable from state
  // ═══════════════════════════════════════════════════════════════
  private select<T>(selector: (state: CartState) => T): Observable<T> {
    return this.state$.pipe(
      map(selector),                        // ← Extract the slice of state we care about
      distinctUntilChanged()                 // ← Only emit when the selected value ACTUALLY changes
    );                                       // ← This prevents unnecessary re-renders!
  }

  // ═══════════════════════════════════════════════════════════════
  // SNAPSHOT -- get the current state value synchronously
  // ═══════════════════════════════════════════════════════════════
  private get currentState(): CartState {
    return this.state$.getValue();           // ← BehaviorSubject lets us read the current value
  }                                          // ← Use sparingly! Prefer reactive (observable) access

  // ═══════════════════════════════════════════════════════════════
  // STATE UPDATE METHODS -- the ONLY way to change state
  // ═══════════════════════════════════════════════════════════════

  addItem(product: { id: number; name: string; price: number }): void {
    const currentItems = this.currentState.items;
    const existingItem = currentItems.find(item => item.productId === product.id);

    let updatedItems: CartItem[];

    if (existingItem) {
      // ← Item already in cart: increment quantity (immutable update!)
      updatedItems = currentItems.map(item =>
        item.productId === product.id
          ? { ...item, quantity: item.quantity + 1 }   // ← Spread operator creates a NEW object
          : item                                        // ← Other items stay the same
      );
    } else {
      // ← New item: add to array (immutable: spread existing + add new)
      updatedItems = [
        ...currentItems,                               // ← Keep all existing items
        {                                               // ← Add the new item
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: 1
        }
      ];
    }

    // ← IMMUTABLE STATE UPDATE: create a completely NEW state object
    this.state$.next({
      ...this.currentState,                             // ← Spread the old state
      items: updatedItems,                              // ← Override items with new array
      error: null                                       // ← Clear any previous error
    });
  }

  removeItem(productId: number): void {
    this.state$.next({
      ...this.currentState,
      items: this.currentState.items.filter(             // ← filter() returns a NEW array (immutable)
        item => item.productId !== productId
      ),
      error: null
    });
  }

  updateQuantity(productId: number, quantity: number): void {
    if (quantity <= 0) {
      this.removeItem(productId);                        // ← Quantity 0 or less = remove the item
      return;
    }

    this.state$.next({
      ...this.currentState,
      items: this.currentState.items.map(item =>
        item.productId === productId
          ? { ...item, quantity }                         // ← Update quantity immutably
          : item
      ),
      error: null
    });
  }

  clearCart(): void {
    this.state$.next({
      ...this.currentState,
      items: [],                                          // ← Empty array = empty cart
      error: null
    });
  }

  setLoading(loading: boolean): void {
    this.state$.next({
      ...this.currentState,
      loading                                             // ← Shorthand property: loading: loading
    });
  }

  setError(error: string): void {
    this.state$.next({
      ...this.currentState,
      loading: false,                                     // ← If there is an error, we are not loading anymore
      error
    });
  }
}
```

```typescript
// ─── cart.component.ts ─── Component that USES the store

import { Component } from '@angular/core';
import { CartStore } from './cart-store.service';

@Component({
  selector: 'app-cart',
  template: `
    <!-- ← Subscribe to loading state -->
    <div *ngIf="store.loading$ | async" class="spinner">Loading...</div>

    <!-- ← Subscribe to error state -->
    <div *ngIf="store.error$ | async as error" class="error">{{ error }}</div>

    <!-- ← Subscribe to isEmpty to show empty message -->
    <div *ngIf="store.isEmpty$ | async; else cartContent">
      Your cart is empty.
    </div>

    <ng-template #cartContent>
      <!-- ← Subscribe to items array -->
      <div *ngFor="let item of store.items$ | async">
        <span>{{ item.productName }}</span>
        <span>{{ item.price | currency }}</span>

        <!-- ← Call store methods to update state -->
        <button (click)="store.updateQuantity(item.productId, item.quantity - 1)">-</button>
        <span>{{ item.quantity }}</span>
        <button (click)="store.updateQuantity(item.productId, item.quantity + 1)">+</button>

        <button (click)="store.removeItem(item.productId)">Remove</button>
      </div>

      <!-- ← Subscribe to computed total -->
      <div class="total">
        Total ({{ store.itemCount$ | async }} items): {{ store.totalPrice$ | async | currency }}
      </div>

      <button (click)="store.clearCart()">Clear Cart</button>
    </ng-template>
  `
})
export class CartComponent {
  // ← Inject the store -- that is it! No manual subscriptions needed
  constructor(public store: CartStore) {}    // ← Public so the template can access it directly
                                              // ← async pipe handles subscribe AND unsubscribe automatically
}
```

### Pros and Cons of BehaviorSubject Store

| Dimension | Rating | Details |
|---|---|---|
| **Simplicity** | Excellent | No libraries to install, pure Angular + RxJS |
| **Learning curve** | Low | If you know Services and BehaviorSubject, you know this |
| **Boilerplate** | Minimal | Just a service class with a BehaviorSubject |
| **Debugging** | Fair | No built-in devtools, must add logging manually |
| **Scalability** | Fair | Works well up to medium complexity apps |
| **Testing** | Good | Easy to test -- just a service with methods |
| **Type safety** | Good | Full TypeScript support out of the box |
| **Time travel debugging** | None | No action history, cannot replay or undo |
| **Team conventions** | Weak | No enforced patterns -- each developer may do it differently |

**When to use this pattern:**
- Small to medium apps (under 20-30 features)
- Teams new to state management
- Features with localized state (a single page or feature module)
- Rapid prototyping

**When to upgrade to NgRx or similar:**
- Large teams that need enforced conventions
- Complex state with many interrelated pieces
- Need for time-travel debugging
- App has heavy side effects (many API calls, WebSocket streams)

---

## 10.3 NgRx -- The Redux Pattern for Angular

### What Is NgRx?

NgRx is the most popular state management library for Angular. It implements the **Redux pattern** (originally from the React world) with full RxJS integration. It brings strict rules and structure to how state is managed.

### The Three Principles of Redux

| Principle | What It Means | Why It Matters |
|---|---|---|
| **Single source of truth** | The entire app state lives in ONE store object | No conflicting copies of state |
| **State is read-only** | You CANNOT directly modify state -- ever | Prevents accidental mutations |
| **Changes via pure functions** | State changes happen ONLY through reducers (pure functions) | Changes are predictable and testable |

### NgRx Building Blocks

```
NgRx has 5 core building blocks:

┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   STORE          The single state container for the whole app    │
│   ACTIONS        Messages that describe "what happened"          │
│   REDUCERS       Pure functions that calculate new state         │
│   SELECTORS      Functions that extract/derive data from state   │
│   EFFECTS        Handle side effects (API calls, navigation)     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### The NgRx Data Flow Cycle (CRITICAL to understand)

```
The NgRx Unidirectional Data Flow:

   ┌──────────────┐
   │  COMPONENT    │
   │              │
   │ Dispatches   │ ←──────────── Reads state via
   │ an Action    │               Selectors
   └──────┬───────┘               ▲
          │                       │
          ▼                       │
   ┌──────────────┐        ┌─────┴────────┐
   │   ACTION      │        │   STORE       │
   │              │        │              │
   │ "Add Product" │        │ { products:  │
   └──────┬───────┘        │   [...] }    │
          │                 └──────▲───────┘
          │                        │
          ├────────────┐           │
          ▼            ▼           │
   ┌──────────────┐  ┌────────────┴──┐
   │  REDUCER      │  │   EFFECT       │
   │              │  │               │
   │ Pure function │  │ Side effects:  │
   │ returns new   │  │ API calls,     │
   │ state         │  │ navigation     │
   └──────┬───────┘  └───────┬───────┘
          │                   │
          │                   │ Dispatches
          └───────────────────┘ new Actions
                  ▼                (success/failure)
              NEW STATE
              pushed to Store

Step by step:
1. Component DISPATCHES an action:     "Hey, the user clicked Add Product"
2. REDUCER receives the action:        "Ok, I will add this product to state"
3. EFFECT receives the action:         "I need to save this to the API too"
4. Effect dispatches a NEW action:     "API call succeeded" or "API call failed"
5. REDUCER handles the new action:     "Ok, I will update loading/error state"
6. STORE is updated:                   New state flows to all subscribers
7. SELECTORS emit new values:          Components automatically re-render
```

### Real-World Analogy: The Fast Food Restaurant

```
NgRx is like a well-run fast food restaurant:

CUSTOMER (Component)        → Places an ORDER (dispatches an Action)
ORDER TICKET (Action)       → A piece of paper describing what they want
KITCHEN (Reducer)           → Reads the ticket, makes the food (new state)
DELIVERY DRIVER (Effect)    → Handles things OUTSIDE the kitchen (API calls)
ORDER DISPLAY (Selector)    → Shows the customer their order status
COUNTER (Store)             → The central place where orders are tracked

The customer NEVER walks into the kitchen to make their own food.
The kitchen NEVER calls a delivery driver -- they have their own process.
Everything flows through the ORDER TICKET (Action).
```

---

### 10.3.1 Actions -- Describing What Happened

Actions are simple objects that describe an event that occurred in your application. They are the ONLY way to trigger state changes.

**Key principle:** Actions describe WHAT HAPPENED, not what should happen. They are past-tense events or commands.

```typescript
// ─── product.actions.ts ─── Defining actions with createAction

import { createAction, props } from '@ngrx/store';
import { Product } from '../models/product.model';

// ═══════════════════════════════════════════════════════════════
// ACTION NAMING CONVENTION: [Source] Event Description
//   [Source] = where the action originated (component, API, etc.)
//   Event    = what happened (past tense or imperative)
// ═══════════════════════════════════════════════════════════════

// ── Load Products ──
export const loadProducts = createAction(
  '[Product List Page] Load Products'        // ← Source: Product List Page, Event: Load Products
);                                            // ← No payload needed -- just "please load products"

export const loadProductsSuccess = createAction(
  '[Product API] Load Products Success',     // ← Source: the API effect, Event: Load succeeded
  props<{ products: Product[] }>()           // ← props<>() defines the payload TYPE
);                                            // ← This action CARRIES the loaded products

export const loadProductsFailure = createAction(
  '[Product API] Load Products Failure',     // ← Source: the API effect, Event: Load failed
  props<{ error: string }>()                 // ← Carries the error message
);

// ── Add Product ──
export const addProduct = createAction(
  '[Product Form] Add Product',              // ← Triggered from a form component
  props<{ product: Omit<Product, 'id'> }>()  // ← Product without ID (server generates it)
);

export const addProductSuccess = createAction(
  '[Product API] Add Product Success',
  props<{ product: Product }>()              // ← The full product WITH server-generated ID
);

export const addProductFailure = createAction(
  '[Product API] Add Product Failure',
  props<{ error: string }>()
);

// ── Update Product ──
export const updateProduct = createAction(
  '[Product Detail Page] Update Product',
  props<{ product: Product }>()              // ← Full product with updated fields
);

export const updateProductSuccess = createAction(
  '[Product API] Update Product Success',
  props<{ product: Product }>()
);

export const updateProductFailure = createAction(
  '[Product API] Update Product Failure',
  props<{ error: string }>()
);

// ── Delete Product ──
export const deleteProduct = createAction(
  '[Product List Page] Delete Product',
  props<{ id: number }>()                    // ← Only need the ID to delete
);

export const deleteProductSuccess = createAction(
  '[Product API] Delete Product Success',
  props<{ id: number }>()                    // ← Which product was deleted
);

export const deleteProductFailure = createAction(
  '[Product API] Delete Product Failure',
  props<{ error: string }>()
);

// ── Select Product ──
export const selectProduct = createAction(
  '[Product List Page] Select Product',
  props<{ id: number }>()                    // ← Which product was selected by the user
);

export const clearSelectedProduct = createAction(
  '[Product Detail Page] Clear Selected Product'  // ← No payload needed
);
```

### Action Grouping with createActionGroup (NgRx 15+)

NgRx 15 introduced `createActionGroup` which reduces boilerplate significantly:

```typescript
// ─── product.actions.ts ─── Using createActionGroup (NgRx 15+)

import { createActionGroup, props, emptyProps } from '@ngrx/store';
import { Product } from '../models/product.model';

// ← Group all actions from the Product List Page together
export const ProductListPageActions = createActionGroup({
  source: 'Product List Page',               // ← The [Source] part of the action type
  events: {
    'Load Products': emptyProps(),            // ← emptyProps() = no payload
    'Delete Product': props<{ id: number }>(),
    'Select Product': props<{ id: number }>(),
  }
});

// ← Group all actions from the Product API (Effects) together
export const ProductApiActions = createActionGroup({
  source: 'Product API',
  events: {
    'Load Products Success': props<{ products: Product[] }>(),
    'Load Products Failure': props<{ error: string }>(),
    'Add Product Success': props<{ product: Product }>(),
    'Add Product Failure': props<{ error: string }>(),
    'Delete Product Success': props<{ id: number }>(),
    'Delete Product Failure': props<{ error: string }>(),
  }
});

// ← USAGE: Actions are now accessed as properties of the group
// ProductListPageActions.loadProducts()
// ProductApiActions.loadProductsSuccess({ products: [...] })
// ProductApiActions.loadProductsFailure({ error: 'Network error' })
```

**Before vs After createActionGroup:**

```typescript
// BEFORE (verbose):
this.store.dispatch(loadProducts());
this.store.dispatch(deleteProduct({ id: 42 }));

// AFTER (grouped):
this.store.dispatch(ProductListPageActions.loadProducts());
this.store.dispatch(ProductListPageActions.deleteProduct({ id: 42 }));

// ← Both work identically. The grouped version is more organized and discoverable.
```

---

### 10.3.2 Reducers -- How State Changes

A **reducer** is a pure function that takes the current state and an action, and returns a NEW state. Reducers are the ONLY place where state actually changes.

```
Reducer:  (currentState, action) → newState

                ┌───────────┐
  currentState  │           │
  ────────────→ │  REDUCER  │ ────────────→ newState
  action        │           │
  ────────────→ │ (pure fn) │
                └───────────┘

  Rules:
  1. MUST be a pure function (no side effects!)
  2. MUST NOT mutate the input state
  3. MUST return a NEW state object
  4. Given the same inputs, MUST always produce the same output
```

**What "pure function" means for reducers:**

| Allowed (Pure) | NOT Allowed (Impure) |
|---|---|
| Return new object with spread | Modify state directly |
| Use `...spread` operator | Use `state.items.push()` |
| Use `map()`, `filter()` | Make API calls |
| Simple calculations | Access `localStorage` |
| Conditional logic | Use `Date.now()` or `Math.random()` |

```typescript
// ─── product.reducer.ts ─── Complete reducer example

import { createReducer, on } from '@ngrx/store';
import { Product } from '../models/product.model';
import * as ProductActions from './product.actions';

// ═══════════════════════════════════════════════════════════════
// STEP 1: Define the state interface
// ═══════════════════════════════════════════════════════════════
export interface ProductState {
  products: Product[];                       // ← The list of all products
  selectedProductId: number | null;          // ← Currently selected product (for detail view)
  loading: boolean;                          // ← Is an API call in progress?
  error: string | null;                      // ← Last error message
}

// ═══════════════════════════════════════════════════════════════
// STEP 2: Define the initial state
// ═══════════════════════════════════════════════════════════════
export const initialState: ProductState = {
  products: [],                              // ← No products initially
  selectedProductId: null,                   // ← Nothing selected
  loading: false,                            // ← Not loading
  error: null                                // ← No error
};

// ═══════════════════════════════════════════════════════════════
// STEP 3: Create the reducer with on() handlers for each action
// ═══════════════════════════════════════════════════════════════
export const productReducer = createReducer(
  initialState,                              // ← Starting state

  // ── Handle: Load Products (user clicked "Load") ──
  on(ProductActions.loadProducts, (state) => ({
    ...state,                                // ← Spread: copy ALL existing state properties
    loading: true,                           // ← Override loading to true
    error: null                              // ← Clear any previous error
  })),
  // ← WHY spread? Because we must return a NEW object. If we just did
  //   state.loading = true, we would MUTATE the existing state object,
  //   and Angular/NgRx would not detect the change!

  // ── Handle: Load Products Success (API returned data) ──
  on(ProductActions.loadProductsSuccess, (state, { products }) => ({
    ...state,
    products,                                // ← Replace products array with the API response
    loading: false,                          // ← Done loading
    error: null                              // ← No error
  })),
  // ← Note: { products } destructures the action payload

  // ── Handle: Load Products Failure (API call failed) ──
  on(ProductActions.loadProductsFailure, (state, { error }) => ({
    ...state,
    loading: false,                          // ← Done loading (even though it failed)
    error                                    // ← Store the error message
  })),
  // ← Products array stays unchanged -- we keep the old data on error

  // ── Handle: Add Product Success ──
  on(ProductActions.addProductSuccess, (state, { product }) => ({
    ...state,
    products: [...state.products, product],  // ← Immutable array add: spread old + new item
    loading: false
  })),

  // ── Handle: Update Product Success ──
  on(ProductActions.updateProductSuccess, (state, { product }) => ({
    ...state,
    products: state.products.map(            // ← map() returns NEW array (immutable)
      p => p.id === product.id ? product : p // ← Replace matching product, keep others
    ),
    loading: false
  })),

  // ── Handle: Delete Product Success ──
  on(ProductActions.deleteProductSuccess, (state, { id }) => ({
    ...state,
    products: state.products.filter(         // ← filter() returns NEW array (immutable)
      p => p.id !== id                       // ← Keep all products EXCEPT the deleted one
    ),
    selectedProductId:
      state.selectedProductId === id         // ← If we deleted the selected product...
        ? null                               // ← ...clear the selection
        : state.selectedProductId,           // ← ...otherwise keep it
    loading: false
  })),

  // ── Handle: Select Product ──
  on(ProductActions.selectProduct, (state, { id }) => ({
    ...state,
    selectedProductId: id                    // ← Just update which product is selected
  })),

  // ── Handle: Clear Selected Product ──
  on(ProductActions.clearSelectedProduct, (state) => ({
    ...state,
    selectedProductId: null                  // ← Deselect
  })),

  // ── Handle: All failure actions the same way ──
  on(
    ProductActions.addProductFailure,
    ProductActions.updateProductFailure,
    ProductActions.deleteProductFailure,
    (state, { error }) => ({                 // ← Multiple actions can share the same handler!
      ...state,
      loading: false,
      error
    })
  )
);
```

**Common Mistake: Mutating State**

```typescript
// ❌ WRONG -- Mutating state directly
on(ProductActions.addProductSuccess, (state, { product }) => {
  state.products.push(product);     // ← MUTATES the existing array! NgRx will NOT detect this change!
  return state;                     // ← Returns the SAME object reference -- change detection fails!
});

// ✅ CORRECT -- Immutable update
on(ProductActions.addProductSuccess, (state, { product }) => ({
  ...state,                         // ← Creates a NEW state object
  products: [...state.products, product]  // ← Creates a NEW array with the new product added
}));

// ❌ WRONG -- Mutating a nested object
on(ProductActions.updateProductSuccess, (state, { product }) => {
  const found = state.products.find(p => p.id === product.id);
  found.name = product.name;        // ← Directly mutating an object inside the array!
  return { ...state };               // ← New outer object, but inner objects are mutated!
});

// ✅ CORRECT -- Immutable nested update
on(ProductActions.updateProductSuccess, (state, { product }) => ({
  ...state,
  products: state.products.map(p =>
    p.id === product.id ? { ...p, ...product } : p  // ← New object for the updated item
  )
}));
```

---

### 10.3.3 Selectors -- Querying State

**Selectors** are pure functions that extract or derive data from the store. They are how components READ state. The key feature of selectors is **memoization** -- they cache their results and only recompute when their inputs change.

```
Selectors: Extract and derive data from the store

  ┌─────────────────────────────────────┐
  │          STORE (Full State)          │
  │  {                                  │
  │    products: {                      │
  │      products: [...],               │
  │      selectedProductId: 42,         │
  │      loading: false,                │
  │      error: null                    │
  │    },                               │
  │    cart: { ... },                   │
  │    user: { ... }                    │
  │  }                                  │
  └──────────┬──────────────────────────┘
             │
    ┌────────┼────────────┬─────────────┐
    ▼        ▼            ▼             ▼
 selectAll  selectById  selectLoading  selectFiltered
 Products   (42)         (false)       Products
             │                          │
             ▼                          ▼
         One Product            Computed/derived
         object                 from raw state

  Memoization:
  If the input state has NOT changed, the selector
  returns the CACHED result without recomputing.
  This is a HUGE performance optimization!
```

```typescript
// ─── product.selectors.ts ─── Complete selector examples

import { createFeatureSelector, createSelector } from '@ngrx/store';
import { ProductState } from './product.reducer';

// ═══════════════════════════════════════════════════════════════
// STEP 1: Feature selector -- selects the "products" slice of state
// ═══════════════════════════════════════════════════════════════
export const selectProductState = createFeatureSelector<ProductState>(
  'products'                                 // ← This string MUST match the key used in StoreModule.forFeature()
);
// ← createFeatureSelector is a shortcut for:
//    createSelector((state: AppState) => state.products)

// ═══════════════════════════════════════════════════════════════
// STEP 2: Basic selectors -- extract individual properties
// ═══════════════════════════════════════════════════════════════
export const selectAllProducts = createSelector(
  selectProductState,                        // ← Input selector: the feature state
  (state: ProductState) => state.products    // ← Projector function: extract the products array
);

export const selectProductsLoading = createSelector(
  selectProductState,
  (state: ProductState) => state.loading     // ← Extract the loading boolean
);

export const selectProductsError = createSelector(
  selectProductState,
  (state: ProductState) => state.error       // ← Extract the error string
);

export const selectSelectedProductId = createSelector(
  selectProductState,
  (state: ProductState) => state.selectedProductId  // ← Extract selected ID
);

// ═══════════════════════════════════════════════════════════════
// STEP 3: Composed selectors -- combine multiple selectors
// ═══════════════════════════════════════════════════════════════
export const selectSelectedProduct = createSelector(
  selectAllProducts,                         // ← Input 1: all products
  selectSelectedProductId,                   // ← Input 2: selected ID
  (products, selectedId) =>                  // ← Projector: combine them
    selectedId
      ? products.find(p => p.id === selectedId) || null  // ← Find the selected product
      : null
);
// ← This selector depends on TWO other selectors.
// ← It only recomputes when EITHER of them changes.
// ← If neither changed, it returns the cached result!

// ═══════════════════════════════════════════════════════════════
// STEP 4: Computed selectors -- derive NEW values from state
// ═══════════════════════════════════════════════════════════════
export const selectProductCount = createSelector(
  selectAllProducts,
  (products) => products.length              // ← Derived value: count of products
);

export const selectExpensiveProducts = createSelector(
  selectAllProducts,
  (products) => products.filter(p => p.price > 100)  // ← Derived: filtered list
);
// ← Even though this runs filter(), memoization means it only
//   re-filters when the products array ACTUALLY changes

export const selectProductsSortedByPrice = createSelector(
  selectAllProducts,
  (products) => [...products].sort((a, b) => a.price - b.price)  // ← Derived: sorted list
);
// ← Note: [...products] creates a copy before sorting because sort() mutates!

// ═══════════════════════════════════════════════════════════════
// STEP 5: Parameterized selector -- select by dynamic value
// ═══════════════════════════════════════════════════════════════
export const selectProductById = (productId: number) =>
  createSelector(
    selectAllProducts,
    (products) => products.find(p => p.id === productId) || null
  );
// ← Usage: this.store.select(selectProductById(42))
// ← Each call with a different ID creates a NEW selector with its own cache

// ═══════════════════════════════════════════════════════════════
// STEP 6: Cross-feature selectors (combining state from different features)
// ═══════════════════════════════════════════════════════════════
// import { selectCartItems } from '../cart/cart.selectors';
//
// export const selectCartProductDetails = createSelector(
//   selectAllProducts,
//   selectCartItems,                        // ← From a DIFFERENT feature!
//   (products, cartItems) =>
//     cartItems.map(cartItem => ({
//       ...cartItem,
//       product: products.find(p => p.id === cartItem.productId)
//     }))
// );
```

### Why Memoization Matters (Performance)

```
Without memoization:

  Component renders → selector runs → filter/sort/compute → return
  Component renders → selector runs → filter/sort/compute → return  ← Same work!
  Component renders → selector runs → filter/sort/compute → return  ← Again!

  Every single render recomputes, even if NOTHING changed.


With memoization (NgRx selectors):

  Component renders → selector runs → filter/sort/compute → return + CACHE
  Component renders → selector checks: "input changed?" → NO → return CACHE  ← Instant!
  Component renders → selector checks: "input changed?" → NO → return CACHE  ← Instant!
  (state changes)
  Component renders → selector checks: "input changed?" → YES → recompute → new CACHE

  Work is only done when the input state ACTUALLY changes.
  This is critical for lists with hundreds of items!
```

---

### 10.3.4 Effects -- Side Effects (API Calls, Navigation, etc.)

**Effects** handle anything that is NOT a pure state calculation: API calls, navigation, localStorage, logging, analytics, WebSocket connections, etc.

**Why do effects exist?** Because reducers MUST be pure functions. You cannot make an HTTP call inside a reducer. Effects listen for specific actions, perform the side effect, and dispatch new actions with the results.

```
Effect Flow:

  Component dispatches     Effect listens      Effect performs     Effect dispatches
  an action                for that action      side effect         result action
  ─────────────────→ ─────────────────→ ──────────────────→ ─────────────────→

  [Load Products]    →  effect catches   →  HTTP GET /api/  →  [Load Products Success]
                        the action          products             { products: [...] }
                                                            OR
                                                            →  [Load Products Failure]
                                                                 { error: "..." }
```

```typescript
// ─── product.effects.ts ─── Complete effects example

import { Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { switchMap, map, catchError, tap } from 'rxjs/operators';
import { ProductService } from '../services/product.service';
import { Router } from '@angular/router';
import * as ProductActions from './product.actions';

@Injectable()
export class ProductEffects {

  // ═══════════════════════════════════════════════════════════════
  // EFFECT: Load Products (API GET)
  // ═══════════════════════════════════════════════════════════════
  loadProducts$ = createEffect(() =>
    this.actions$.pipe(                      // ← actions$ is a stream of ALL dispatched actions
      ofType(ProductActions.loadProducts),   // ← Filter: only react to "Load Products" action
      switchMap(() =>                        // ← switchMap: cancel previous request if new one comes
        this.productService.getAll().pipe(   // ← The actual HTTP call (the side effect!)
          map(products =>                    // ← On success: transform response into success action
            ProductActions.loadProductsSuccess({ products })
          ),
          catchError(error =>                // ← On failure: emit failure action
            of(ProductActions.loadProductsFailure({ error: error.message }))
          )                                  // ← of() wraps the action in an observable
        )
      )
    )
  );
  // ← This effect:
  //   1. Waits for [Load Products] action
  //   2. Calls the API
  //   3. On success: dispatches [Load Products Success]
  //   4. On failure: dispatches [Load Products Failure]
  //   5. The REDUCER handles both success/failure actions

  // ═══════════════════════════════════════════════════════════════
  // EFFECT: Add Product (API POST)
  // ═══════════════════════════════════════════════════════════════
  addProduct$ = createEffect(() =>
    this.actions$.pipe(
      ofType(ProductActions.addProduct),
      switchMap(({ product }) =>             // ← Destructure the action to get the product payload
        this.productService.create(product).pipe(
          map(createdProduct =>              // ← API returns the product with a server-generated ID
            ProductActions.addProductSuccess({ product: createdProduct })
          ),
          catchError(error =>
            of(ProductActions.addProductFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // EFFECT: Update Product (API PUT)
  // ═══════════════════════════════════════════════════════════════
  updateProduct$ = createEffect(() =>
    this.actions$.pipe(
      ofType(ProductActions.updateProduct),
      switchMap(({ product }) =>
        this.productService.update(product).pipe(
          map(updatedProduct =>
            ProductActions.updateProductSuccess({ product: updatedProduct })
          ),
          catchError(error =>
            of(ProductActions.updateProductFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // EFFECT: Delete Product (API DELETE)
  // ═══════════════════════════════════════════════════════════════
  deleteProduct$ = createEffect(() =>
    this.actions$.pipe(
      ofType(ProductActions.deleteProduct),
      switchMap(({ id }) =>
        this.productService.delete(id).pipe(
          map(() =>                          // ← DELETE usually returns no body
            ProductActions.deleteProductSuccess({ id })  // ← Pass the ID so reducer knows what to remove
          ),
          catchError(error =>
            of(ProductActions.deleteProductFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // EFFECT: Navigate after successful add (no new action dispatched)
  // ═══════════════════════════════════════════════════════════════
  addProductSuccessRedirect$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(ProductActions.addProductSuccess),
        tap(({ product }) => {               // ← tap() for side effects that do NOT produce actions
          this.router.navigate(['/products', product.id]);  // ← Navigate to the new product
        })
      ),
    { dispatch: false }                      // ← CRITICAL: tells NgRx this effect does NOT dispatch an action
  );                                         // ← Without this, NgRx expects an action and will error!

  constructor(
    private actions$: Actions,               // ← Injected by NgRx: stream of all dispatched actions
    private productService: ProductService,  // ← Your HTTP service
    private router: Router                   // ← For navigation side effects
  ) {}
}
```

### switchMap vs mergeMap vs concatMap vs exhaustMap in Effects

This is one of the most important decisions you make when writing effects. Choosing the wrong flattening operator leads to subtle bugs.

```
Scenario: User clicks "Load" button multiple times rapidly.
Each click dispatches a loadProducts action.

switchMap:   CANCEL previous, only keep LATEST
  Click 1 → Request 1 starts → Click 2 → Request 1 CANCELLED → Request 2 starts → Response 2

mergeMap:    Run ALL requests in PARALLEL
  Click 1 → Request 1 starts → Click 2 → Request 2 starts → Response 1, Response 2 (any order)

concatMap:   Run requests in SEQUENCE (queue them)
  Click 1 → Request 1 starts → Click 2 → (queued) → Response 1 → Request 2 starts → Response 2

exhaustMap:  IGNORE new requests while one is running
  Click 1 → Request 1 starts → Click 2 → (IGNORED) → Response 1
```

| Operator | Behavior | Use When | Example |
|---|---|---|---|
| `switchMap` | Cancels previous, runs latest | Loading/searching -- only latest matters | Searching products, loading a page |
| `mergeMap` | Runs all in parallel | Each request is independent | Deleting multiple items, logging events |
| `concatMap` | Queues, runs in order | Order matters, nothing should be lost | Creating items where order matters |
| `exhaustMap` | Ignores new until current completes | Prevent duplicate submissions | Login button, form submit, payment |

**Decision Guide:**

```
Is order important AND must every request complete?
  YES → concatMap

Should we cancel the previous request?
  YES → switchMap (most common for reads/loads)

Should all requests run simultaneously?
  YES → mergeMap

Should we ignore requests while one is in progress?
  YES → exhaustMap (best for form submissions)
```

### Error Handling in Effects (Critical!)

```typescript
// ═══════════════════════════════════════════════════════════════
// ERROR HANDLING -- Getting it right is critical
// ═══════════════════════════════════════════════════════════════

// ❌ WRONG -- catchError outside switchMap kills the effect permanently!
loadProducts$ = createEffect(() =>
  this.actions$.pipe(
    ofType(ProductActions.loadProducts),
    switchMap(() =>
      this.productService.getAll()           // ← If this throws...
    ),
    map(products => ProductActions.loadProductsSuccess({ products })),
    catchError(error =>                      // ← ...this catches it BUT...
      of(ProductActions.loadProductsFailure({ error: error.message }))
    )
    // ← The effect observable COMPLETES after the error!
    // ← The effect will NEVER respond to loadProducts actions again!
    // ← This is a silent, devastating bug!
  )
);

// ✅ CORRECT -- catchError INSIDE switchMap keeps the effect alive
loadProducts$ = createEffect(() =>
  this.actions$.pipe(
    ofType(ProductActions.loadProducts),
    switchMap(() =>
      this.productService.getAll().pipe(     // ← The .pipe() is on the INNER observable
        map(products => ProductActions.loadProductsSuccess({ products })),
        catchError(error =>                  // ← catchError is INSIDE switchMap
          of(ProductActions.loadProductsFailure({ error: error.message }))
        )
        // ← Only the INNER observable completes on error
        // ← The OUTER effect observable keeps running!
        // ← The effect will respond to future loadProducts actions!
      )
    )
  )
);
```

```
Why catchError placement matters:

  WRONG (outside switchMap):
  actions$ ─── ofType ─── switchMap ─── map ─── catchError
                                                      │
                                                 Effect DIES here
                                                 (outer stream completes)

  CORRECT (inside switchMap):
  actions$ ─── ofType ─── switchMap(── api ─── map ─── catchError ──)
                              │                              │
                              │         Inner stream dies, but
                              │         outer stream LIVES ON
                              └── Still listening for next action!
```

---

### 10.3.5 Setting Up NgRx in a Module

```typescript
// ─── app.module.ts ─── Module-based setup (traditional)

import { NgModule } from '@angular/core';
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { StoreDevtoolsModule } from '@ngrx/store-devtools';
import { environment } from '../environments/environment';

@NgModule({
  imports: [
    // ═══════════════════════════════════════════════════════════
    // ROOT store setup (only in AppModule)
    // ═══════════════════════════════════════════════════════════
    StoreModule.forRoot({
      // ← Global reducers go here (if any)
      // ← Usually empty -- features register their own reducers
    }),

    EffectsModule.forRoot([
      // ← Global effects go here (if any)
      // ← Usually empty -- features register their own effects
    ]),

    // ← Redux DevTools integration (only in development!)
    StoreDevtoolsModule.instrument({
      maxAge: 25,                            // ← Keep last 25 state changes in devtools
      logOnly: environment.production,       // ← In production, only log (no time-travel)
      autoPause: true                        // ← Pause when DevTools window is not open
    }),
  ]
})
export class AppModule {}
```

```typescript
// ─── products.module.ts ─── Feature module setup

import { NgModule } from '@angular/core';
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { productReducer } from './state/product.reducer';
import { ProductEffects } from './state/product.effects';

@NgModule({
  imports: [
    // ═══════════════════════════════════════════════════════════
    // FEATURE store setup (in each feature module)
    // ═══════════════════════════════════════════════════════════
    StoreModule.forFeature(
      'products',                            // ← Feature key: state.products
      productReducer                         // ← The reducer for this feature
    ),
    // ← This adds a "products" slice to the global store:
    //   { products: { products: [], loading: false, error: null } }

    EffectsModule.forFeature([
      ProductEffects                         // ← Register effects for this feature
    ]),
  ]
})
export class ProductsModule {}
```

```typescript
// ─── main.ts or app.config.ts ─── Standalone API setup (Angular 15+)

import { provideStore } from '@ngrx/store';
import { provideEffects } from '@ngrx/effects';
import { provideStoreDevtools } from '@ngrx/store-devtools';
import { productReducer } from './state/product.reducer';
import { ProductEffects } from './state/product.effects';

// ← In bootstrapApplication or app.config.ts:
export const appConfig = {
  providers: [
    provideStore({                           // ← Replaces StoreModule.forRoot()
      products: productReducer               // ← Register reducers directly
    }),
    provideEffects([                          // ← Replaces EffectsModule.forRoot()
      ProductEffects
    ]),
    provideStoreDevtools({                   // ← Replaces StoreDevtoolsModule.instrument()
      maxAge: 25,
      logOnly: false                         // ← Set based on environment
    }),
  ]
};
```

**Module-Based vs Standalone Setup Comparison:**

| Aspect | Module-Based | Standalone |
|---|---|---|
| Syntax | `StoreModule.forRoot()` | `provideStore()` |
| Feature registration | `StoreModule.forFeature()` | `provideState()` |
| Effects | `EffectsModule.forRoot()` | `provideEffects()` |
| Where configured | `@NgModule` imports | `providers` array |
| Angular version | All versions | Angular 15+ |

---

### 10.3.6 Component Integration

Here is how a component uses the NgRx store:

```typescript
// ─── product-list.component.ts ─── Complete component with NgRx

import { Component, OnInit } from '@angular/core';
import { Store } from '@ngrx/store';
import { Observable } from 'rxjs';
import { Product } from '../models/product.model';
import * as ProductActions from '../state/product.actions';
import * as ProductSelectors from '../state/product.selectors';

@Component({
  selector: 'app-product-list',
  template: `
    <!-- ════════════════════════════════════════════════════ -->
    <!-- LOADING STATE: Show spinner while fetching          -->
    <!-- ════════════════════════════════════════════════════ -->
    <div *ngIf="loading$ | async" class="loading-overlay">
      <div class="spinner"></div>
      <p>Loading products...</p>
    </div>

    <!-- ════════════════════════════════════════════════════ -->
    <!-- ERROR STATE: Show error message if API call failed  -->
    <!-- ════════════════════════════════════════════════════ -->
    <div *ngIf="error$ | async as error" class="error-banner">
      <p>Error: {{ error }}</p>
      <button (click)="retry()">Retry</button>
    </div>

    <!-- ════════════════════════════════════════════════════ -->
    <!-- PRODUCT LIST: Render when data is available         -->
    <!-- ════════════════════════════════════════════════════ -->
    <div class="product-count">
      Total: {{ productCount$ | async }} products   <!-- ← Computed selector -->
    </div>

    <div *ngFor="let product of products$ | async; trackBy: trackByFn"
         class="product-card"
         [class.selected]="(selectedProductId$ | async) === product.id">

      <h3>{{ product.name }}</h3>
      <p>{{ product.price | currency }}</p>

      <!-- ← Dispatch an action when user clicks -->
      <button (click)="onSelect(product.id)">View Details</button>
      <button (click)="onDelete(product.id)">Delete</button>
    </div>
  `
})
export class ProductListComponent implements OnInit {

  // ═══════════════════════════════════════════════════════════════
  // SELECT state from the store using selectors
  // ═══════════════════════════════════════════════════════════════
  products$: Observable<Product[]>;          // ← Will hold the products observable
  loading$: Observable<boolean>;
  error$: Observable<string | null>;
  productCount$: Observable<number>;
  selectedProductId$: Observable<number | null>;

  constructor(private store: Store) {        // ← Inject the NgRx Store
    // ← Use store.select() with our selectors to get observables
    this.products$ = this.store.select(ProductSelectors.selectAllProducts);
    this.loading$ = this.store.select(ProductSelectors.selectProductsLoading);
    this.error$ = this.store.select(ProductSelectors.selectProductsError);
    this.productCount$ = this.store.select(ProductSelectors.selectProductCount);
    this.selectedProductId$ = this.store.select(ProductSelectors.selectSelectedProductId);
  }

  ngOnInit(): void {
    // ═══════════════════════════════════════════════════════════
    // DISPATCH an action to trigger data loading
    // ═══════════════════════════════════════════════════════════
    this.store.dispatch(ProductActions.loadProducts());
    // ← This dispatches the action: "[Product List Page] Load Products"
    // ← The reducer sets loading: true
    // ← The effect makes the API call
    // ← On success, the reducer stores the products and sets loading: false
    // ← The selectors emit the new values
    // ← The template updates via the async pipe
    // ← ALL of this from ONE dispatch call!
  }

  onSelect(id: number): void {
    this.store.dispatch(ProductActions.selectProduct({ id }));  // ← Dispatch with payload
  }

  onDelete(id: number): void {
    if (confirm('Are you sure?')) {
      this.store.dispatch(ProductActions.deleteProduct({ id }));
    }
  }

  retry(): void {
    this.store.dispatch(ProductActions.loadProducts());          // ← Same action as initial load
  }

  trackByFn(index: number, product: Product): number {
    return product.id;                       // ← trackBy for ngFor performance
  }
}
```

**Key patterns in this component:**

```
1. NO manual subscribe() calls!
   The async pipe in the template handles subscribe + unsubscribe automatically.
   This eliminates memory leaks from forgotten unsubscriptions.

2. Component does NOT know HOW state is stored or fetched.
   It just dispatches actions and reads selectors.
   You could swap the backend from REST to GraphQL
   and this component would not change at all.

3. Component is THIN -- no business logic.
   All state logic lives in reducers, effects, and selectors.
   The component is just a bridge between user events and the store.
```

---

## 10.4 NgRx Entity -- Managing Collections

### The Problem with Manual Collection Management

Managing arrays of objects (collections) in NgRx involves a LOT of repetitive code: adding items, updating items, removing items, finding items by ID. NgRx Entity automates all of this.

```
Without NgRx Entity (manual):          With NgRx Entity (automated):

  // Add item                             adapter.addOne(item, state)
  [...state.items, newItem]

  // Update item                          adapter.updateOne({ id, changes }, state)
  state.items.map(i =>
    i.id === id ? {...i, ...changes} : i
  )

  // Remove item                          adapter.removeOne(id, state)
  state.items.filter(i => i.id !== id)

  // Get all items                        adapter.getSelectors().selectAll
  state.items

  Repetitive, error-prone!               Clean, tested, consistent!
```

```typescript
// ─── product.reducer.ts ─── With NgRx Entity

import { createReducer, on } from '@ngrx/store';
import { EntityState, EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { Product } from '../models/product.model';
import * as ProductActions from './product.actions';

// ═══════════════════════════════════════════════════════════════
// STEP 1: Define entity state (extends EntityState)
// ═══════════════════════════════════════════════════════════════
export interface ProductEntityState extends EntityState<Product> {
  // ← EntityState automatically provides:
  //   ids: number[] | string[]   -- ordered array of all entity IDs
  //   entities: { [id: number]: Product }  -- dictionary lookup by ID
  //
  // We add our OWN custom properties:
  selectedProductId: number | null;
  loading: boolean;
  error: string | null;
}

// ═══════════════════════════════════════════════════════════════
// STEP 2: Create the entity adapter
// ═══════════════════════════════════════════════════════════════
export const productAdapter: EntityAdapter<Product> = createEntityAdapter<Product>({
  selectId: (product: Product) => product.id,  // ← Which property is the unique ID (default: 'id')
  sortComparer: (a, b) => a.name.localeCompare(b.name)  // ← Optional: sort entities by name
});
// ← The adapter provides methods to manipulate the entity collection immutably

// ═══════════════════════════════════════════════════════════════
// STEP 3: Define initial state using the adapter
// ═══════════════════════════════════════════════════════════════
export const initialState: ProductEntityState = productAdapter.getInitialState({
  // ← getInitialState() creates: { ids: [], entities: {} }
  // ← We add our custom properties:
  selectedProductId: null,
  loading: false,
  error: null
});

// ═══════════════════════════════════════════════════════════════
// STEP 4: Create the reducer using adapter methods
// ═══════════════════════════════════════════════════════════════
export const productEntityReducer = createReducer(
  initialState,

  // ── Load Products ──
  on(ProductActions.loadProducts, (state) => ({
    ...state,
    loading: true,
    error: null
  })),

  on(ProductActions.loadProductsSuccess, (state, { products }) =>
    productAdapter.setAll(products, {        // ← setAll: Replace ALL entities with the new array
      ...state,
      loading: false,
      error: null
    })
  ),

  on(ProductActions.loadProductsFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),

  // ── Add Product ──
  on(ProductActions.addProductSuccess, (state, { product }) =>
    productAdapter.addOne(product, {         // ← addOne: Add a single entity to the collection
      ...state,
      loading: false
    })
  ),

  // ── Update Product ──
  on(ProductActions.updateProductSuccess, (state, { product }) =>
    productAdapter.updateOne(                // ← updateOne: Update a single entity
      {
        id: product.id,                      // ← Which entity to update
        changes: product                     // ← The changes to apply (partial or full)
      },
      { ...state, loading: false }
    )
  ),

  // ── Delete Product ──
  on(ProductActions.deleteProductSuccess, (state, { id }) =>
    productAdapter.removeOne(id, {           // ← removeOne: Remove entity by ID
      ...state,
      loading: false,
      selectedProductId:
        state.selectedProductId === id ? null : state.selectedProductId
    })
  ),

  // ── Select Product ──
  on(ProductActions.selectProduct, (state, { id }) => ({
    ...state,
    selectedProductId: id
  }))
);
```

```typescript
// ─── product.selectors.ts ─── Selectors with NgRx Entity

import { createFeatureSelector, createSelector } from '@ngrx/store';
import { ProductEntityState, productAdapter } from './product.reducer';

// ← Feature selector
export const selectProductState = createFeatureSelector<ProductEntityState>('products');

// ═══════════════════════════════════════════════════════════════
// Entity adapter provides BUILT-IN selectors!
// ═══════════════════════════════════════════════════════════════
const {
  selectAll,                                 // ← Returns all entities as an array
  selectEntities,                            // ← Returns entities as a dictionary { [id]: entity }
  selectIds,                                 // ← Returns just the IDs array
  selectTotal                                // ← Returns the count of entities
} = productAdapter.getSelectors(selectProductState);
// ← getSelectors() takes the feature selector and returns pre-built selectors

// ← Export them for use in components
export const selectAllProducts = selectAll;            // ← Product[]
export const selectProductEntities = selectEntities;   // ← { [id: number]: Product }
export const selectProductIds = selectIds;             // ← number[]
export const selectProductTotal = selectTotal;         // ← number

// ← Custom selectors (same as before)
export const selectProductsLoading = createSelector(
  selectProductState,
  state => state.loading
);

export const selectProductsError = createSelector(
  selectProductState,
  state => state.error
);

export const selectSelectedProductId = createSelector(
  selectProductState,
  state => state.selectedProductId
);

// ← Using entity dictionary for O(1) lookup by ID
export const selectSelectedProduct = createSelector(
  selectProductEntities,                     // ← Dictionary of products
  selectSelectedProductId,                   // ← Selected ID
  (entities, selectedId) =>
    selectedId ? entities[selectedId] || null : null  // ← O(1) lookup instead of .find()!
);
// ← With regular arrays, finding by ID is O(n) -- you scan the whole array
// ← With entity dictionary, lookup is O(1) -- instant, no matter how many entities
```

### Entity Adapter Method Reference

| Method | What It Does | Example |
|---|---|---|
| `addOne(entity, state)` | Add one entity | Adding a newly created product |
| `addMany(entities, state)` | Add multiple entities | Adding a batch of products |
| `setOne(entity, state)` | Add or replace one entity | Upsert a product |
| `setMany(entities, state)` | Add or replace multiple entities | Upsert a batch |
| `setAll(entities, state)` | Replace ALL entities | Loading fresh data from API |
| `removeOne(id, state)` | Remove one entity by ID | Deleting a product |
| `removeMany(ids, state)` | Remove multiple by IDs | Bulk delete |
| `removeAll(state)` | Remove ALL entities | Clearing the list |
| `updateOne({id, changes}, state)` | Partially update one | Changing product name |
| `updateMany(updates, state)` | Partially update multiple | Bulk price update |
| `upsertOne(entity, state)` | Update if exists, add if not | Sync from API |
| `upsertMany(entities, state)` | Upsert multiple | Batch sync from API |
| `map(mapFn, state)` | Apply a function to all entities | Apply discount to all |

---

## 10.5 NgRx Component Store (Lightweight Local State)

### When Global Store Is Too Much

NgRx Store is great for global, shared state. But sometimes you have **local state** that belongs to a single component or feature and does not need to be global. That is where **ComponentStore** shines.

```
Global Store (NgRx Store)              vs    Local Store (ComponentStore)
─────────────────────                        ─────────────────────────────
Shared across the entire app                 Scoped to one component/feature
Survives navigation                          Destroyed when component is destroyed
Actions + Reducers + Effects                 setState + patchState + select + effect
More boilerplate                             Less boilerplate
Best for: user data, cart, global config     Best for: pagination, filters, local UI state
```

```typescript
// ─── paginated-list.store.ts ─── ComponentStore example

import { Injectable } from '@angular/core';
import { ComponentStore } from '@ngrx/component-store';
import { Observable, switchMap, tap, catchError, EMPTY } from 'rxjs';
import { Product } from '../models/product.model';
import { ProductService } from '../services/product.service';

// ═══════════════════════════════════════════════════════════════
// STEP 1: Define the local state interface
// ═══════════════════════════════════════════════════════════════
export interface PaginatedListState {
  products: Product[];
  currentPage: number;
  pageSize: number;
  totalItems: number;
  loading: boolean;
  error: string | null;
  searchTerm: string;
}

const initialState: PaginatedListState = {
  products: [],
  currentPage: 1,
  pageSize: 10,
  totalItems: 0,
  loading: false,
  error: null,
  searchTerm: ''
};

@Injectable()                                // ← No providedIn: 'root'! This is LOCAL to a component
export class PaginatedListStore extends ComponentStore<PaginatedListState> {

  constructor(private productService: ProductService) {
    super(initialState);                     // ← Pass initial state to ComponentStore base class
  }

  // ═══════════════════════════════════════════════════════════════
  // SELECTORS -- using this.select() from ComponentStore
  // ═══════════════════════════════════════════════════════════════

  readonly products$ = this.select(state => state.products);          // ← Select a slice of state
  readonly loading$ = this.select(state => state.loading);
  readonly error$ = this.select(state => state.error);
  readonly currentPage$ = this.select(state => state.currentPage);
  readonly searchTerm$ = this.select(state => state.searchTerm);

  // ← Composed selector: derive total pages from totalItems and pageSize
  readonly totalPages$ = this.select(
    state => Math.ceil(state.totalItems / state.pageSize)
  );

  // ← Combine multiple selectors into a view model
  readonly vm$ = this.select(
    this.products$,
    this.loading$,
    this.error$,
    this.currentPage$,
    this.totalPages$,
    (products, loading, error, currentPage, totalPages) => ({
      products,
      loading,
      error,
      currentPage,
      totalPages
    })
  );
  // ← vm$ (view model) gives the template ONE observable with everything it needs!

  // ═══════════════════════════════════════════════════════════════
  // UPDATERS -- using this.patchState() and this.setState()
  // ═══════════════════════════════════════════════════════════════

  // ← patchState: merge partial updates into the current state
  readonly setSearchTerm = this.updater((state, searchTerm: string) => ({
    ...state,
    searchTerm,
    currentPage: 1                           // ← Reset to page 1 when search changes
  }));

  readonly setPage = this.updater((state, page: number) => ({
    ...state,
    currentPage: page
  }));

  // ═══════════════════════════════════════════════════════════════
  // EFFECTS -- using this.effect() from ComponentStore
  // ═══════════════════════════════════════════════════════════════

  readonly loadProducts = this.effect((params$: Observable<{ page: number; search: string }>) =>
    params$.pipe(
      tap(() => this.patchState({ loading: true, error: null })),  // ← Set loading before API call
      switchMap(({ page, search }) =>
        this.productService.search(search, page).pipe(
          tap({
            next: (response) => {
              this.patchState({              // ← patchState merges these into current state
                products: response.items,
                totalItems: response.totalCount,
                loading: false
              });
            },
            error: (error) => {
              this.patchState({
                loading: false,
                error: error.message
              });
            }
          }),
          catchError(() => EMPTY)            // ← EMPTY completes without emitting
        )
      )
    )
  );
}
```

```typescript
// ─── paginated-list.component.ts ─── Using the ComponentStore

import { Component, OnInit } from '@angular/core';
import { PaginatedListStore } from './paginated-list.store';

@Component({
  selector: 'app-paginated-list',
  template: `
    <!-- ← Use the view model observable for a single subscription -->
    <ng-container *ngIf="store.vm$ | async as vm">
      <input
        [value]="store.searchTerm$ | async"
        (input)="onSearch($event)"
        placeholder="Search products..."
      />

      <div *ngIf="vm.loading" class="spinner">Loading...</div>
      <div *ngIf="vm.error" class="error">{{ vm.error }}</div>

      <div *ngFor="let product of vm.products" class="product-card">
        <h3>{{ product.name }}</h3>
        <p>{{ product.price | currency }}</p>
      </div>

      <!-- Pagination controls -->
      <div class="pagination">
        <button
          [disabled]="vm.currentPage === 1"
          (click)="onPageChange(vm.currentPage - 1)">
          Previous
        </button>
        <span>Page {{ vm.currentPage }} of {{ vm.totalPages }}</span>
        <button
          [disabled]="vm.currentPage === vm.totalPages"
          (click)="onPageChange(vm.currentPage + 1)">
          Next
        </button>
      </div>
    </ng-container>
  `,
  providers: [PaginatedListStore]            // ← Provide at COMPONENT level!
})                                            // ← Store is created when component is created
export class PaginatedListComponent implements OnInit {  // ← Store is destroyed when component is destroyed

  constructor(public store: PaginatedListStore) {}

  ngOnInit(): void {
    // ← Trigger initial load
    this.store.loadProducts({ page: 1, search: '' });
  }

  onSearch(event: Event): void {
    const term = (event.target as HTMLInputElement).value;
    this.store.setSearchTerm(term);
    this.store.loadProducts({ page: 1, search: term });
  }

  onPageChange(page: number): void {
    this.store.setPage(page);
    this.store.loadProducts({ page, search: '' });
  }
}
```

### Component Store vs Global Store Decision Guide

| Question | If YES → | If NO → |
|---|---|---|
| Does this state need to be shared across multiple routes/features? | Global Store | Component Store |
| Does this state need to survive component destruction? | Global Store | Component Store |
| Is this state used by sibling or distant components? | Global Store | Component Store |
| Is this only pagination, sort, filter, or local UI state? | Component Store | Depends |
| Does the team need strict Redux DevTools debugging for this? | Global Store | Component Store |

---

## 10.6 NGXS -- Alternative State Management

### Overview

**NGXS** (pronounced "nexus") is an alternative to NgRx that uses TypeScript decorators and classes instead of separate actions/reducers files. It has less boilerplate and feels more "Angular-like" to some developers.

```typescript
// ─── product.state.ts ─── NGXS State (all-in-one)

import { State, Action, StateContext, Selector } from '@ngxs/store';
import { Injectable } from '@angular/core';
import { tap, catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { ProductService } from '../services/product.service';
import { Product } from '../models/product.model';

// ═══════════════════════════════════════════════════════════════
// ACTIONS -- Simple classes (no createAction needed)
// ═══════════════════════════════════════════════════════════════
export class LoadProducts {
  static readonly type = '[Products] Load';   // ← Action type as a static property
}

export class LoadProductsSuccess {
  static readonly type = '[Products] Load Success';
  constructor(public products: Product[]) {} // ← Payload is just a constructor parameter
}

export class AddProduct {
  static readonly type = '[Products] Add';
  constructor(public product: Omit<Product, 'id'>) {}
}

export class DeleteProduct {
  static readonly type = '[Products] Delete';
  constructor(public id: number) {}
}

// ═══════════════════════════════════════════════════════════════
// STATE MODEL
// ═══════════════════════════════════════════════════════════════
export interface ProductStateModel {
  products: Product[];
  loading: boolean;
  error: string | null;
}

// ═══════════════════════════════════════════════════════════════
// STATE -- Combines reducer + effects + selectors in ONE class
// ═══════════════════════════════════════════════════════════════
@State<ProductStateModel>({
  name: 'products',                          // ← State slice name
  defaults: {                                // ← Initial state (like initialState in NgRx)
    products: [],
    loading: false,
    error: null
  }
})
@Injectable()
export class ProductState {

  constructor(private productService: ProductService) {}

  // ── SELECTORS (decorators instead of createSelector) ──
  @Selector()                                // ← Decorator-based selector
  static getProducts(state: ProductStateModel): Product[] {
    return state.products;
  }

  @Selector()
  static isLoading(state: ProductStateModel): boolean {
    return state.loading;
  }

  @Selector()
  static getError(state: ProductStateModel): string | null {
    return state.error;
  }

  // ── ACTIONS (decorators instead of createReducer + on()) ──
  @Action(LoadProducts)                      // ← This method handles the LoadProducts action
  loadProducts(ctx: StateContext<ProductStateModel>) {
    ctx.patchState({ loading: true, error: null });  // ← patchState = partial update (like spread)

    return this.productService.getAll().pipe(
      tap(products => {
        ctx.patchState({                     // ← Update state with the response
          products,
          loading: false
        });
      }),
      catchError(error => {
        ctx.patchState({
          loading: false,
          error: error.message
        });
        return of(error);
      })
    );
    // ← Notice: the action handler can BOTH update state AND make API calls!
    // ← In NgRx, this would require a reducer AND an effect.
  }

  @Action(DeleteProduct)
  deleteProduct(ctx: StateContext<ProductStateModel>, action: DeleteProduct) {
    return this.productService.delete(action.id).pipe(
      tap(() => {
        const state = ctx.getState();
        ctx.setState({                       // ← setState = replace entire state
          ...state,
          products: state.products.filter(p => p.id !== action.id)
        });
      })
    );
  }
}
```

```typescript
// ─── product-list.component.ts ─── Using NGXS in a component

import { Component, OnInit } from '@angular/core';
import { Store, Select } from '@ngxs/store';
import { Observable } from 'rxjs';
import { ProductState } from '../state/product.state';
import { LoadProducts, DeleteProduct } from '../state/product.state';
import { Product } from '../models/product.model';

@Component({
  selector: 'app-product-list',
  template: `
    <div *ngIf="loading$ | async">Loading...</div>
    <div *ngFor="let product of products$ | async">
      {{ product.name }}
      <button (click)="delete(product.id)">Delete</button>
    </div>
  `
})
export class ProductListComponent implements OnInit {

  @Select(ProductState.getProducts)          // ← Decorator-based selection (NGXS-specific)
  products$!: Observable<Product[]>;

  @Select(ProductState.isLoading)
  loading$!: Observable<boolean>;

  constructor(private store: Store) {}

  ngOnInit(): void {
    this.store.dispatch(new LoadProducts()); // ← Dispatch using "new" keyword (class-based actions)
  }

  delete(id: number): void {
    this.store.dispatch(new DeleteProduct(id));
  }
}
```

### NgRx vs NGXS Quick Comparison

| Feature | NgRx | NGXS |
|---|---|---|
| **Philosophy** | Separate files: actions, reducers, effects, selectors | All-in-one state class |
| **Action definition** | `createAction()` functions | Plain classes |
| **State changes** | Reducer + `on()` handlers | `@Action()` decorated methods |
| **Side effects** | Separate `Effects` class | Inside `@Action()` methods |
| **Selectors** | `createSelector()` functions | `@Selector()` decorated static methods |
| **Boilerplate** | More files, more code | Less files, less code |
| **Community** | Larger | Smaller |
| **DevTools** | Redux DevTools | Redux DevTools |
| **Learning curve** | Steeper | Gentler (if you know OOP) |

---

## 10.7 Comparison: Which State Management to Use?

### The Big Comparison Table

| Dimension | No Library | BehaviorSubject Store | NgRx | NGXS | Akita |
|---|---|---|---|---|---|
| **Complexity** | None | Low | High | Medium | Medium |
| **Boilerplate** | None | Minimal | Heavy | Moderate | Moderate |
| **Learning curve** | None | Low (RxJS) | Steep | Moderate | Moderate |
| **DevTools** | None | None (manual logging) | Redux DevTools | Redux DevTools | Redux DevTools |
| **Time travel** | No | No | Yes | Yes | Yes |
| **Scalability** | Poor | Fair | Excellent | Good | Good |
| **Testing** | Varies | Easy | Excellent | Good | Good |
| **Team conventions** | None | Weak | Strong (enforced) | Moderate | Moderate |
| **Bundle size** | 0 KB | 0 KB | ~15 KB | ~10 KB | ~8 KB |
| **Community** | N/A | N/A | Very Large | Medium | Small |
| **Maintenance** | N/A | Custom code | NgRx team | NGXS team | Less active |
| **Best for** | Tiny apps | Small-Medium apps | Large enterprise apps | Medium apps | Medium apps |

### Decision Flowchart

```
START: How complex is your app's state?
  │
  ├── Tiny (< 10 components, minimal shared state)
  │   └── → No library needed. Use @Input/@Output and simple services.
  │
  ├── Small-Medium (10-30 components, some shared state)
  │   │
  │   ├── Team is comfortable with RxJS?
  │   │   ├── YES → BehaviorSubject Store pattern
  │   │   └── NO  → Consider NGXS (less RxJS knowledge needed)
  │   │
  │   └── Need local component state management?
  │       └── YES → NgRx ComponentStore
  │
  ├── Medium-Large (30-100+ components, complex shared state)
  │   │
  │   ├── Team prefers strict conventions and patterns?
  │   │   └── YES → NgRx (Redux pattern, enforced structure)
  │   │
  │   ├── Team prefers less boilerplate, OOP style?
  │   │   └── YES → NGXS (decorator-based, less files)
  │   │
  │   └── Need time-travel debugging?
  │       └── YES → NgRx or NGXS (both support Redux DevTools)
  │
  └── Enterprise (100+ components, multiple teams, complex workflows)
      └── → NgRx. The boilerplate is worth it.
            Strict patterns prevent chaos in large teams.
            Best tooling, largest community, most resources.
```

### What Companies Actually Use (Industry Reality)

| State Management | Used By | Typical App Size |
|---|---|---|
| **No library / simple services** | Most small Angular apps | Prototypes, internal tools, small SaaS |
| **BehaviorSubject stores** | Many mid-size companies | Medium SaaS products, dashboards |
| **NgRx** | Google, many Fortune 500 | Enterprise apps, banking, healthcare, e-commerce |
| **NGXS** | Medium-size companies | Apps where NgRx boilerplate was rejected |
| **Akita** | Datorama (Salesforce) | Analytics, dashboards |

**The honest truth:** Many successful Angular applications use NO state management library. Services with BehaviorSubjects handle 80% of use cases. Only reach for NgRx when you genuinely need its benefits (DevTools, time-travel, strict conventions for large teams).

---

## 10.8 Practical Example -- Complete Todo App with NgRx

Let us put everything together with a complete CRUD Todo application using NgRx Store, Effects, and Entity.

### Model

```typescript
// ─── todo.model.ts ───

export interface Todo {
  id: number;
  title: string;
  completed: boolean;
  createdAt: string;                         // ← ISO date string
}
```

### Actions

```typescript
// ─── todo.actions.ts ───

import { createActionGroup, props, emptyProps } from '@ngrx/store';
import { Todo } from '../models/todo.model';

// ← All actions from the Todo Page
export const TodoPageActions = createActionGroup({
  source: 'Todo Page',
  events: {
    'Load Todos': emptyProps(),              // ← User navigates to the page
    'Add Todo': props<{ title: string }>(),  // ← User submits the "add" form
    'Toggle Todo': props<{ id: number }>(),  // ← User clicks the checkbox
    'Delete Todo': props<{ id: number }>(),  // ← User clicks "delete"
    'Update Todo': props<{ id: number; title: string }>(),  // ← User edits a todo title
    'Set Filter': props<{ filter: 'all' | 'active' | 'completed' }>(),  // ← User clicks filter button
  }
});

// ← All actions from the API layer (dispatched by Effects)
export const TodoApiActions = createActionGroup({
  source: 'Todo API',
  events: {
    'Load Todos Success': props<{ todos: Todo[] }>(),
    'Load Todos Failure': props<{ error: string }>(),
    'Add Todo Success': props<{ todo: Todo }>(),
    'Add Todo Failure': props<{ error: string }>(),
    'Toggle Todo Success': props<{ todo: Todo }>(),
    'Toggle Todo Failure': props<{ error: string }>(),
    'Delete Todo Success': props<{ id: number }>(),
    'Delete Todo Failure': props<{ error: string }>(),
    'Update Todo Success': props<{ todo: Todo }>(),
    'Update Todo Failure': props<{ error: string }>(),
  }
});
```

### Reducer (with Entity)

```typescript
// ─── todo.reducer.ts ───

import { createReducer, on } from '@ngrx/store';
import { EntityState, EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { Todo } from '../models/todo.model';
import { TodoPageActions, TodoApiActions } from './todo.actions';

// ═══════════════════════════════════════════════════════════════
// State interface
// ═══════════════════════════════════════════════════════════════
export interface TodoState extends EntityState<Todo> {   // ← Extends EntityState for auto ids/entities
  loading: boolean;
  error: string | null;
  filter: 'all' | 'active' | 'completed';   // ← Current filter selection
}

// ═══════════════════════════════════════════════════════════════
// Entity adapter
// ═══════════════════════════════════════════════════════════════
export const todoAdapter: EntityAdapter<Todo> = createEntityAdapter<Todo>({
  selectId: (todo) => todo.id,
  sortComparer: (a, b) =>                    // ← Sort: incomplete first, then by creation date
    a.completed === b.completed
      ? new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      : a.completed ? 1 : -1
});

// ═══════════════════════════════════════════════════════════════
// Initial state
// ═══════════════════════════════════════════════════════════════
export const initialTodoState: TodoState = todoAdapter.getInitialState({
  loading: false,
  error: null,
  filter: 'all'
});

// ═══════════════════════════════════════════════════════════════
// Reducer
// ═══════════════════════════════════════════════════════════════
export const todoReducer = createReducer(
  initialTodoState,

  // ── Load Todos ──
  on(TodoPageActions.loadTodos, (state) => ({
    ...state,
    loading: true,
    error: null
  })),

  on(TodoApiActions.loadTodosSuccess, (state, { todos }) =>
    todoAdapter.setAll(todos, {              // ← Replace all entities with fresh data from API
      ...state,
      loading: false,
      error: null
    })
  ),

  on(TodoApiActions.loadTodosFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),

  // ── Add Todo ──
  on(TodoApiActions.addTodoSuccess, (state, { todo }) =>
    todoAdapter.addOne(todo, state)          // ← Add the new todo to the entity collection
  ),

  // ── Toggle Todo ──
  on(TodoApiActions.toggleTodoSuccess, (state, { todo }) =>
    todoAdapter.updateOne(                   // ← Update the toggled todo
      { id: todo.id, changes: { completed: todo.completed } },
      state
    )
  ),

  // ── Update Todo ──
  on(TodoApiActions.updateTodoSuccess, (state, { todo }) =>
    todoAdapter.updateOne(
      { id: todo.id, changes: { title: todo.title } },
      state
    )
  ),

  // ── Delete Todo ──
  on(TodoApiActions.deleteTodoSuccess, (state, { id }) =>
    todoAdapter.removeOne(id, state)         // ← Remove by ID
  ),

  // ── Set Filter (pure UI state, no API call needed) ──
  on(TodoPageActions.setFilter, (state, { filter }) => ({
    ...state,
    filter                                   // ← Just update the filter property
  })),

  // ── Handle all failures the same way ──
  on(
    TodoApiActions.addTodoFailure,
    TodoApiActions.toggleTodoFailure,
    TodoApiActions.deleteTodoFailure,
    TodoApiActions.updateTodoFailure,
    (state, { error }) => ({
      ...state,
      error
    })
  )
);
```

### Selectors

```typescript
// ─── todo.selectors.ts ───

import { createFeatureSelector, createSelector } from '@ngrx/store';
import { TodoState, todoAdapter } from './todo.reducer';

// ← Feature selector
export const selectTodoState = createFeatureSelector<TodoState>('todos');

// ← Entity adapter selectors
const { selectAll, selectTotal } = todoAdapter.getSelectors(selectTodoState);

// ← Base selectors
export const selectAllTodos = selectAll;                    // ← All todos as an array
export const selectTodoTotal = selectTotal;                  // ← Total count
export const selectTodoLoading = createSelector(selectTodoState, s => s.loading);
export const selectTodoError = createSelector(selectTodoState, s => s.error);
export const selectCurrentFilter = createSelector(selectTodoState, s => s.filter);

// ═══════════════════════════════════════════════════════════════
// Derived selectors
// ═══════════════════════════════════════════════════════════════
export const selectActiveTodos = createSelector(
  selectAllTodos,
  (todos) => todos.filter(t => !t.completed) // ← Only incomplete todos
);

export const selectCompletedTodos = createSelector(
  selectAllTodos,
  (todos) => todos.filter(t => t.completed)  // ← Only completed todos
);

export const selectActiveCount = createSelector(
  selectActiveTodos,
  (todos) => todos.length                    // ← Count of incomplete todos
);

export const selectCompletedCount = createSelector(
  selectCompletedTodos,
  (todos) => todos.length
);

// ← THE KEY SELECTOR: applies the current filter to return the visible todos
export const selectFilteredTodos = createSelector(
  selectAllTodos,
  selectCurrentFilter,
  (todos, filter) => {
    switch (filter) {
      case 'active':
        return todos.filter(t => !t.completed);
      case 'completed':
        return todos.filter(t => t.completed);
      case 'all':
      default:
        return todos;                        // ← Return all todos when filter is 'all'
    }
  }
);
// ← This selector is MEMOIZED: it only refilters when
//   either the todos array OR the filter value changes

// ← View model selector: everything the component needs in one object
export const selectTodoViewModel = createSelector(
  selectFilteredTodos,
  selectTodoLoading,
  selectTodoError,
  selectCurrentFilter,
  selectActiveCount,
  selectCompletedCount,
  selectTodoTotal,
  (todos, loading, error, filter, activeCount, completedCount, total) => ({
    todos,
    loading,
    error,
    filter,
    activeCount,
    completedCount,
    total
  })
);
```

### Effects

```typescript
// ─── todo.effects.ts ───

import { Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { switchMap, map, catchError, mergeMap } from 'rxjs/operators';
import { TodoService } from '../services/todo.service';
import { TodoPageActions, TodoApiActions } from './todo.actions';

@Injectable()
export class TodoEffects {

  // ═══════════════════════════════════════════════════════════════
  // LOAD TODOS
  // ═══════════════════════════════════════════════════════════════
  loadTodos$ = createEffect(() =>
    this.actions$.pipe(
      ofType(TodoPageActions.loadTodos),
      switchMap(() =>                        // ← switchMap: cancel if user triggers another load
        this.todoService.getAll().pipe(
          map(todos => TodoApiActions.loadTodosSuccess({ todos })),
          catchError(error =>                // ← catchError INSIDE switchMap to keep effect alive
            of(TodoApiActions.loadTodosFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // ADD TODO
  // ═══════════════════════════════════════════════════════════════
  addTodo$ = createEffect(() =>
    this.actions$.pipe(
      ofType(TodoPageActions.addTodo),
      mergeMap(({ title }) =>                // ← mergeMap: allow multiple adds in parallel
        this.todoService.create({ title, completed: false }).pipe(
          map(todo => TodoApiActions.addTodoSuccess({ todo })),
          catchError(error =>
            of(TodoApiActions.addTodoFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // TOGGLE TODO
  // ═══════════════════════════════════════════════════════════════
  toggleTodo$ = createEffect(() =>
    this.actions$.pipe(
      ofType(TodoPageActions.toggleTodo),
      mergeMap(({ id }) =>                   // ← mergeMap: user might toggle several rapidly
        this.todoService.toggle(id).pipe(
          map(todo => TodoApiActions.toggleTodoSuccess({ todo })),
          catchError(error =>
            of(TodoApiActions.toggleTodoFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // UPDATE TODO
  // ═══════════════════════════════════════════════════════════════
  updateTodo$ = createEffect(() =>
    this.actions$.pipe(
      ofType(TodoPageActions.updateTodo),
      switchMap(({ id, title }) =>           // ← switchMap: only care about the latest edit
        this.todoService.update(id, { title }).pipe(
          map(todo => TodoApiActions.updateTodoSuccess({ todo })),
          catchError(error =>
            of(TodoApiActions.updateTodoFailure({ error: error.message }))
          )
        )
      )
    )
  );

  // ═══════════════════════════════════════════════════════════════
  // DELETE TODO
  // ═══════════════════════════════════════════════════════════════
  deleteTodo$ = createEffect(() =>
    this.actions$.pipe(
      ofType(TodoPageActions.deleteTodo),
      mergeMap(({ id }) =>                   // ← mergeMap: allow deleting multiple in parallel
        this.todoService.delete(id).pipe(
          map(() => TodoApiActions.deleteTodoSuccess({ id })),
          catchError(error =>
            of(TodoApiActions.deleteTodoFailure({ error: error.message }))
          )
        )
      )
    )
  );

  constructor(
    private actions$: Actions,               // ← Stream of all dispatched actions
    private todoService: TodoService         // ← HTTP service for API calls
  ) {}
}
```

### Component and Template

```typescript
// ─── todo-page.component.ts ───

import { Component, OnInit } from '@angular/core';
import { Store } from '@ngrx/store';
import { Observable } from 'rxjs';
import { TodoPageActions } from '../state/todo.actions';
import { selectTodoViewModel } from '../state/todo.selectors';

@Component({
  selector: 'app-todo-page',
  template: `
    <!-- ═══════════════════════════════════════════════════════ -->
    <!-- Single subscription using the view model selector      -->
    <!-- ═══════════════════════════════════════════════════════ -->
    <ng-container *ngIf="vm$ | async as vm">
      <div class="todo-app">
        <h1>Todo App (NgRx)</h1>

        <!-- ═══════════ ERROR DISPLAY ═══════════ -->
        <div *ngIf="vm.error" class="error-banner">
          {{ vm.error }}
        </div>

        <!-- ═══════════ ADD TODO FORM ═══════════ -->
        <form (submit)="addTodo(newTodoInput)" class="add-form">
          <input
            #newTodoInput                     <!-- ← Template reference for the input -->
            type="text"
            placeholder="What needs to be done?"
            class="todo-input"
          />
          <button type="submit">Add</button>
        </form>

        <!-- ═══════════ LOADING STATE ═══════════ -->
        <div *ngIf="vm.loading" class="loading">Loading todos...</div>

        <!-- ═══════════ TODO LIST ═══════════ -->
        <ul class="todo-list">
          <li *ngFor="let todo of vm.todos; trackBy: trackById"
              [class.completed]="todo.completed">

            <!-- ← Dispatch toggle action on checkbox click -->
            <input
              type="checkbox"
              [checked]="todo.completed"
              (change)="onToggle(todo.id)"
            />

            <span class="todo-title">{{ todo.title }}</span>

            <!-- ← Dispatch delete action -->
            <button (click)="onDelete(todo.id)" class="delete-btn">x</button>
          </li>
        </ul>

        <!-- ═══════════ FILTER BUTTONS ═══════════ -->
        <div class="filters">
          <span>{{ vm.activeCount }} items left</span>

          <div class="filter-buttons">
            <button
              [class.active]="vm.filter === 'all'"
              (click)="onFilterChange('all')">
              All ({{ vm.total }})
            </button>
            <button
              [class.active]="vm.filter === 'active'"
              (click)="onFilterChange('active')">
              Active ({{ vm.activeCount }})
            </button>
            <button
              [class.active]="vm.filter === 'completed'"
              (click)="onFilterChange('completed')">
              Completed ({{ vm.completedCount }})
            </button>
          </div>
        </div>
      </div>
    </ng-container>
  `,
  styles: [`
    .todo-app { max-width: 500px; margin: 0 auto; }
    .add-form { display: flex; gap: 8px; margin-bottom: 16px; }
    .todo-input { flex: 1; padding: 8px; font-size: 16px; }
    .todo-list { list-style: none; padding: 0; }
    .todo-list li { display: flex; align-items: center; gap: 8px; padding: 8px 0; border-bottom: 1px solid #eee; }
    .completed .todo-title { text-decoration: line-through; opacity: 0.5; }
    .delete-btn { margin-left: auto; background: none; border: none; color: red; cursor: pointer; font-size: 18px; }
    .filters { display: flex; justify-content: space-between; margin-top: 16px; }
    .filter-buttons button { margin: 0 4px; }
    .filter-buttons button.active { font-weight: bold; text-decoration: underline; }
    .error-banner { background: #fee; color: #c00; padding: 8px; border-radius: 4px; margin-bottom: 8px; }
    .loading { text-align: center; padding: 16px; color: #666; }
  `]
})
export class TodoPageComponent implements OnInit {

  // ← Select the entire view model -- one subscription in the template
  vm$: Observable<{
    todos: any[];
    loading: boolean;
    error: string | null;
    filter: string;
    activeCount: number;
    completedCount: number;
    total: number;
  }>;

  constructor(private store: Store) {
    this.vm$ = this.store.select(selectTodoViewModel);  // ← Single selector for everything
  }

  ngOnInit(): void {
    this.store.dispatch(TodoPageActions.loadTodos());    // ← Load todos on component init
  }

  addTodo(input: HTMLInputElement): void {
    const title = input.value.trim();
    if (title) {
      this.store.dispatch(TodoPageActions.addTodo({ title }));  // ← Dispatch add action
      input.value = '';                      // ← Clear the input after dispatching
    }
  }

  onToggle(id: number): void {
    this.store.dispatch(TodoPageActions.toggleTodo({ id }));
  }

  onDelete(id: number): void {
    this.store.dispatch(TodoPageActions.deleteTodo({ id }));
  }

  onFilterChange(filter: 'all' | 'active' | 'completed'): void {
    this.store.dispatch(TodoPageActions.setFilter({ filter }));
    // ← Note: setFilter does NOT trigger an API call!
    // ← The reducer updates the filter, and the selectFilteredTodos
    // ← selector automatically recomputes the visible todos.
  }

  trackById(index: number, todo: any): number {
    return todo.id;                          // ← trackBy for ngFor performance optimization
  }
}
```

### Module Setup

```typescript
// ─── todo.module.ts ─── Wiring it all together

import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { todoReducer } from './state/todo.reducer';
import { TodoEffects } from './state/todo.effects';
import { TodoPageComponent } from './components/todo-page.component';

@NgModule({
  declarations: [TodoPageComponent],
  imports: [
    CommonModule,
    StoreModule.forFeature('todos', todoReducer),    // ← Register the "todos" feature state
    EffectsModule.forFeature([TodoEffects]),          // ← Register the todo effects
  ],
  exports: [TodoPageComponent]
})
export class TodoModule {}
```

### The Complete Data Flow (Traced Step by Step)

```
User types "Buy milk" and clicks "Add":

1. COMPONENT dispatches:
   TodoPageActions.addTodo({ title: 'Buy milk' })

2. EFFECT catches the action:
   addTodo$ → ofType(TodoPageActions.addTodo)
   → mergeMap → todoService.create({ title: 'Buy milk', completed: false })
   → HTTP POST /api/todos → Server responds with { id: 99, title: 'Buy milk', ... }

3. EFFECT dispatches success:
   TodoApiActions.addTodoSuccess({ todo: { id: 99, title: 'Buy milk', ... } })

4. REDUCER handles addTodoSuccess:
   todoAdapter.addOne(todo, state)
   → New state: { ids: [..., 99], entities: { ..., 99: { ... } }, ... }

5. STORE updates with new state

6. SELECTORS recompute:
   selectAllTodos → [..., { id: 99, title: 'Buy milk' }]
   selectFilteredTodos → (depends on current filter)
   selectActiveCount → increments by 1
   selectTodoViewModel → new view model object

7. COMPONENT template updates:
   vm$ emits new value → async pipe triggers change detection
   → New todo appears in the list!
```

---

## 10.9 Summary

### What We Covered

| Topic | Key Takeaway |
|---|---|
| **Why State Management** | As apps grow, scattered state leads to bugs, inconsistency, and untrackable changes |
| **Types of State** | UI state, server state, URL state, form state, client state -- each has different needs |
| **BehaviorSubject Store** | The simplest Angular-native pattern: service + BehaviorSubject + immutable updates |
| **NgRx Store** | Full Redux pattern: Actions describe events, Reducers compute state, Selectors read state |
| **NgRx Actions** | Named messages like `[Source] Event` -- use `createAction()` or `createActionGroup()` |
| **NgRx Reducers** | Pure functions that return NEW state -- never mutate, always spread |
| **NgRx Selectors** | Memoized queries against the store -- compose them for derived data |
| **NgRx Effects** | Side effects (API calls, navigation) -- use `switchMap` for loads, `exhaustMap` for submits |
| **NgRx Entity** | EntityAdapter automates collection CRUD: `addOne`, `removeOne`, `updateOne`, `setAll` |
| **Component Store** | Lightweight local state for components -- `patchState`, `select`, `effect` |
| **NGXS** | Decorator-based alternative to NgRx: less boilerplate, `@State`, `@Action`, `@Selector` |
| **Choosing a solution** | No library for small apps, BehaviorSubject for medium, NgRx for large/enterprise |

### The Golden Rules of State Management

```
1. SINGLE SOURCE OF TRUTH
   Every piece of state should live in exactly ONE place.
   If two components need the same data, they both read from the same source.

2. STATE IS READ-ONLY
   Never modify state directly. Always create a new state object.
   This enables change detection, time-travel debugging, and undo/redo.

3. CHANGES ARE PREDICTABLE
   Whether you use a BehaviorSubject method or an NgRx reducer,
   state changes should follow defined paths that can be traced and tested.

4. DERIVE, DON'T DUPLICATE
   If a value can be COMPUTED from existing state, compute it (via selector).
   Do not store "totalPrice" if you can compute it from items + quantities.

5. CHOOSE THE RIGHT LEVEL
   Not everything needs to be in a global store.
   Local UI state can stay in the component.
   Feature state can use ComponentStore.
   Only truly global, shared state needs NgRx Store.
```

### Common Mistakes Summary

| Mistake | Why It Is Bad | Fix |
|---|---|---|
| Mutating state directly | Change detection fails, time travel breaks | Always use spread operator or adapter methods |
| `catchError` outside `switchMap` in effects | Effect dies permanently after first error | Put `catchError` INSIDE `switchMap` |
| Putting everything in global store | Over-engineering, unnecessary complexity | Use ComponentStore for local state |
| Not using `distinctUntilChanged` with selectors | Components re-render even when nothing changed | NgRx selectors do this automatically; add it to BehaviorSubject stores |
| Subscribing in components instead of using async pipe | Memory leaks from forgotten unsubscribes | Always prefer `async` pipe |
| Storing derived data in state | State gets out of sync with itself | Use selectors to compute derived values |
| Not using `trackBy` with `*ngFor` | Entire list re-renders on every change | Always provide `trackBy` function |
| Using `mergeMap` for loads | Multiple duplicate API calls in parallel | Use `switchMap` for loads, `exhaustMap` for submits |

---

> **Next Phase:** [Phase 11: Modules & Standalone Components Architecture](Phase11-Modules-Standalone-Architecture.md)
