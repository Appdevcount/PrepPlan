# Phase 20: Advanced Patterns & Architecture

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand." -- Martin Fowler. At enterprise scale, the difference between a successful product and a maintenance nightmare is not the cleverness of individual functions -- it is the discipline of architecture. This phase teaches you the structural patterns that make large Angular applications maintainable, testable, and evolvable over years.

---

## 20.1 Why Architecture Matters at Scale

### The Problem: Small App vs Enterprise App Complexity

When you build a small Angular todo app, architecture feels like overkill. Everything fits in your head. One component does the HTTP call, displays the result, and handles errors -- fine. Ship it.

Then the product grows. Six months later you have 40 developers, 200 components, 80 services, and a codebase nobody fully understands. A change to fix a bug in the user profile breaks the dashboard. Adding a new API endpoint requires touching 12 different files. Every feature takes three times longer than it should.

This is **accidental complexity** -- complexity you created yourself, not complexity inherent to the problem.

```
Small App (Day 1):
┌─────────────────────────────────────────────────────┐
│  AppComponent                                        │
│  ├── calls UserService                               │
│  ├── calls ProductService                            │
│  └── renders everything                              │
└─────────────────────────────────────────────────────┘
  10 files, one developer, changes are easy

Enterprise App (Year 2 without architecture):
┌──────────────────────────────────────────────────────────┐
│  Component A ←→ Component B ←→ Component C               │
│       ↑              ↓              ↑                     │
│  Service X ←→ Service Y ←→ Service Z                     │
│       ↕              ↕              ↕                     │
│  Component D ←→ Component E ←→ Component F               │
└──────────────────────────────────────────────────────────┘
  200 files, spaghetti dependencies, changes are terrifying

Enterprise App (Year 2 WITH architecture):
┌─────────────────────────────────────────────────────────┐
│  Feature Module (self-contained)                        │
│  ├── Containers (smart components, own data)            │
│  ├── Presentational (dumb, receive @Input)              │
│  ├── Facade (single service interface for the feature)  │
│  └── Repository (data access, caching, error handling)  │
└─────────────────────────────────────────────────────────┘
  Each module is understandable in isolation, changes are local
```

### Technical Debt and Its Cost

Technical debt is borrowed time. You take shortcuts now (copying code instead of abstracting, direct service calls instead of facades) and you pay interest later (every future change costs more because of the mess you left behind).

```
Cost of change over time:

  Without Architecture:
  Cost │                                        *
       │                                   *  *  *
       │                               *  *
       │                          *  *
       │                    *  *
       │           *   *  *
       │  *  *  *
       └────────────────────────────────────────→ Time
          Month 1      Month 6       Month 18

  With Architecture:
  Cost │
       │      *  *  *  *  *  *  *  *  *  *  *  *
       │  *  *
       └────────────────────────────────────────→ Time
          Month 1      Month 6       Month 18
       (Higher initial cost, dramatically lower long-term cost)
```

### The City Planning Analogy

Building software without architecture is like building a city without urban planning:

| Urban Planning | Software Architecture |
|---|---|
| Roads before buildings | Establish data flow patterns before features |
| Zoning laws (residential, commercial) | Module boundaries (feature, shared, core) |
| Utility infrastructure (water, electricity) | Core services (auth, logging, error handling) |
| Building codes | Coding standards, linting, architecture rules |
| City districts | Feature modules |
| Public squares (shared spaces) | Shared module (reusable components) |

You would not build houses and then try to squeeze roads between them after the fact. Similarly, you should not build features and then try to untangle the dependencies later -- it costs orders of magnitude more.

**The core principle: make decisions when they are cheap (early), not when they are expensive (after 200 components are built).**

---

## 20.2 Smart (Container) vs Dumb (Presentational) Components

### The Problem

Without this pattern, components become monoliths: they fetch data, transform it, display it, handle user events, call APIs, and manage state -- all at once. Such components are impossible to test in isolation and impossible to reuse.

### The Pattern Explained

The core insight is simple: **separate the WHAT (data and behavior) from the HOW (display)**

- **Smart Component (Container):** Knows about the application state. Talks to services. Manages data. Does NOT care about how things look.
- **Dumb Component (Presentational):** Knows about display. Receives data via `@Input()`. Emits events via `@Output()`. Has ZERO knowledge of services, HTTP, or application state.

### The Restaurant Analogy

```
SMART Component = Restaurant Manager
  - Knows the menu (data)
  - Communicates with kitchen (services)
  - Knows what orders are pending (state)
  - Does NOT serve food to tables

DUMB Component = Waiter
  - Takes instructions from manager (receives @Input)
  - Tells manager what customers want (emits @Output events)
  - Serves exactly what they are told to serve (renders @Input data)
  - Has NO idea how the kitchen works (no service injection)
```

### ASCII Data Flow Diagram

```
                    Smart Component (Container)
                    ┌─────────────────────────────────┐
                    │  @Component({ ... })             │
                    │                                  │
                    │  constructor(                    │
                    │    private svc: ProductService   │ ← Injects services
                    │  ) {}                            │
                    │                                  │
                    │  products$: Observable<Product[]>│ ← Manages data
                    │  loading: boolean                │ ← Manages state
                    │                                  │
                    │  onAddToCart(p: Product) {       │ ← Handles business logic
                    │    this.svc.addToCart(p);        │
                    │  }                               │
                    └───────────┬──────────────────────┘
                                │ @Input() products
                                │ @Input() loading
                                ↓
                    Dumb Component (Presentational)
                    ┌─────────────────────────────────┐
                    │  @Component({ ... })             │
                    │                                  │
                    │  @Input() products: Product[]    │ ← Receives data
                    │  @Input() loading: boolean       │ ← Receives state
                    │  @Output() addToCart =           │
                    │    new EventEmitter<Product>()   │ ← Emits events upward
                    │                                  │
                    │  // NO services injected         │
                    │  // NO HTTP calls                │
                    │  // Pure display logic only      │
                    └─────────────────────────────────┘
```

### Full Example: ProductListContainer + ProductCard

**Domain model (shared):**

```typescript
// src/app/features/products/models/product.model.ts

export interface Product {
  id: number;
  name: string;
  price: number;
  imageUrl: string;
  inStock: boolean;
}
```

**Product service (data layer):**

```typescript
// src/app/features/products/services/product.service.ts

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Product } from '../models/product.model';

@Injectable({ providedIn: 'root' })
export class ProductService {
  private readonly apiUrl = '/api/products'; // ← Centralized URL, easy to change

  constructor(private http: HttpClient) {}

  getProducts(): Observable<Product[]> {
    return this.http.get<Product[]>(this.apiUrl); // ← Returns Observable, does not subscribe
  }

  addToCart(product: Product): void {
    console.log('Adding to cart:', product.name); // ← Real impl would call cart service
  }
}
```

**Smart Container Component:**

```typescript
// src/app/features/products/containers/product-list.container.ts

import { Component, OnInit } from '@angular/core';
import { Observable, BehaviorSubject } from 'rxjs';
import { catchError, finalize } from 'rxjs/operators';
import { ProductService } from '../services/product.service';
import { Product } from '../models/product.model';

@Component({
  selector: 'app-product-list-container',
  template: `
    <!--
      The container's template is THIN -- it just wires
      data down and events up. All display logic lives in the
      presentational component.
    -->
    <app-product-card-list
      [products]="products$ | async"
      [loading]="loading"
      [error]="error"
      (addToCart)="onAddToCart($event)"
      (retry)="onRetry()"
    ></app-product-card-list>
  `
})
export class ProductListContainerComponent implements OnInit {

  // ← The container OWNS the data streams
  products$!: Observable<Product[]>;
  loading = false;   // ← The container OWNS loading state
  error: string | null = null; // ← The container OWNS error state

  constructor(
    private productService: ProductService // ← Container INJECTS services
  ) {}

  ngOnInit(): void {
    this.loadProducts(); // ← Triggers data loading on init
  }

  onAddToCart(product: Product): void {
    // ← Container handles the BUSINESS LOGIC triggered by child events
    this.productService.addToCart(product);
  }

  onRetry(): void {
    this.loadProducts(); // ← Re-trigger loading on retry event from child
  }

  private loadProducts(): void {
    this.loading = true;  // ← Set loading BEFORE the call
    this.error = null;    // ← Clear previous errors

    this.products$ = this.productService.getProducts().pipe(
      catchError(err => {
        this.error = 'Failed to load products. Please try again.'; // ← Handle errors here
        throw err; // ← Re-throw so finalize still runs
      }),
      finalize(() => {
        this.loading = false; // ← Always turn off loading, success or fail
      })
    );
  }
}
```

**Dumb Presentational Component (ProductCardList):**

```typescript
// src/app/features/products/components/product-card-list.component.ts

import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Product } from '../models/product.model';

@Component({
  selector: 'app-product-card-list',
  changeDetection: ChangeDetectionStrategy.OnPush, // ← OnPush is safe here because only @Inputs change
  template: `
    <!-- Loading state -->
    <div *ngIf="loading" class="loading-spinner">
      Loading products...
    </div>

    <!-- Error state -->
    <div *ngIf="error" class="error-banner">
      {{ error }}
      <button (click)="retry.emit()">Retry</button>
    </div>

    <!-- Data state -->
    <div *ngIf="!loading && !error" class="product-grid">
      <app-product-card
        *ngFor="let product of products; trackBy: trackById"
        [product]="product"
        (addToCart)="addToCart.emit($event)"
      ></app-product-card>
    </div>

    <!-- Empty state -->
    <div *ngIf="!loading && !error && products?.length === 0">
      No products found.
    </div>
  `
})
export class ProductCardListComponent {

  // ← Pure @Input decorators -- no service injection
  @Input() products: Product[] | null = [];
  @Input() loading = false;
  @Input() error: string | null = null;

  // ← Pure @Output decorators -- emits events upward to container
  @Output() addToCart = new EventEmitter<Product>();
  @Output() retry = new EventEmitter<void>();

  // ← trackBy for performance -- not business logic
  trackById(_index: number, product: Product): number {
    return product.id;
  }

  // ← NO constructor with services
  // ← NO HTTP calls
  // ← NO state management
}
```

**Dumb Presentational Component (ProductCard -- leaf level):**

```typescript
// src/app/features/products/components/product-card.component.ts

import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { Product } from '../models/product.model';

@Component({
  selector: 'app-product-card',
  changeDetection: ChangeDetectionStrategy.OnPush, // ← Safe because pure @Input
  template: `
    <div class="card" [class.out-of-stock]="!product.inStock">
      <img [src]="product.imageUrl" [alt]="product.name">
      <h3>{{ product.name }}</h3>
      <p class="price">{{ product.price | currency }}</p>
      <span *ngIf="!product.inStock" class="badge">Out of Stock</span>
      <button
        [disabled]="!product.inStock"
        (click)="addToCart.emit(product)"
      >
        Add to Cart
      </button>
    </div>
  `
})
export class ProductCardComponent {
  @Input() product!: Product;              // ← Only receives data
  @Output() addToCart = new EventEmitter<Product>(); // ← Only emits events
}
```

### Decision Guide: When to Use This Pattern

```
Should this component be Smart or Dumb?

  Does the component need to talk to a service?
  ├── YES → It is or should become a SMART component (Container)
  └── NO  → It should be a DUMB component (Presentational)

  Is this component reused in multiple places with different data?
  ├── YES → It MUST be DUMB -- reusability requires @Input
  └── NO  → It could be Smart, but consider splitting anyway

  Do you need to unit test this component easily?
  ├── YES → Make it DUMB -- no service mocking needed
  └── NO  → Either, but DUMB is still simpler

  Is this the "entry point" for a route?
  ├── YES → Smart Container (route-level components own data loading)
  └── NO  → Probably Dumb (leaf components just display)
```

### Benefits Summary

| Concern | Without Pattern | With Smart/Dumb Pattern |
|---|---|---|
| **Testability** | Must mock every service | Dumb components need zero mocking |
| **Reusability** | Tightly coupled to one context | Dumb components work anywhere |
| **Change detection** | Must use Default strategy | Dumb can use OnPush (faster) |
| **Separation of concerns** | Mixed display + business logic | Clean boundary |
| **Readability** | Large mixed-concern components | Small, focused components |

---

## 20.3 Facade Pattern

### The Problem

A complex feature page often needs data from multiple services: user information, analytics data, notification counts, subscription status. Without a facade, your component's constructor becomes a tangled list of injected services, and your component logic is spread across calls to five different places.

```typescript
// WITHOUT a facade -- the component knows too much
constructor(
  private userService: UserService,
  private analyticsService: AnalyticsService,
  private notificationService: NotificationService,
  private subscriptionService: SubscriptionService,
  private preferencesService: PreferencesService
) {}
// The component is tightly coupled to every service's internals
// Change any service API = change this component
```

### The Analogy: Hotel Concierge

```
WITHOUT facade:
  Guest (Component) talks to:
  - Housekeeping department directly
  - Restaurant directly
  - Parking garage directly
  - Spa booking desk directly
  - Airport shuttle office directly
  = Guest must know the internal structure of the hotel

WITH facade:
  Guest (Component) talks to:
  - Concierge (Facade)
    └── Concierge knows how to coordinate housekeeping,
        restaurant, parking, spa, and shuttle
  = Guest only knows one phone number
```

### Full Example: DashboardFacade

```typescript
// src/app/features/dashboard/services/user.service.ts
// (simplified -- assume these exist)

@Injectable({ providedIn: 'root' })
export class UserService {
  getCurrentUser(): Observable<User> {
    return this.http.get<User>('/api/me');
  }
}

// src/app/features/dashboard/services/analytics.service.ts

@Injectable({ providedIn: 'root' })
export class AnalyticsService {
  getPageViews(): Observable<number> {
    return this.http.get<number>('/api/analytics/pageviews');
  }
  getConversionRate(): Observable<number> {
    return this.http.get<number>('/api/analytics/conversion');
  }
}

// src/app/features/dashboard/services/notification.service.ts

@Injectable({ providedIn: 'root' })
export class NotificationService {
  getUnreadCount(): Observable<number> {
    return this.http.get<number>('/api/notifications/unread');
  }
}
```

```typescript
// src/app/features/dashboard/facades/dashboard.facade.ts

import { Injectable } from '@angular/core';
import { combineLatest, Observable } from 'rxjs';
import { map, shareReplay } from 'rxjs/operators';
import { UserService } from '../services/user.service';
import { AnalyticsService } from '../services/analytics.service';
import { NotificationService } from '../services/notification.service';

// ← This interface defines what the dashboard NEEDS -- not what each service provides
export interface DashboardViewModel {
  userName: string;
  userEmail: string;
  pageViews: number;
  conversionRate: number;
  unreadNotifications: number;
  isHighPerformer: boolean; // ← Derived/computed field, calculated in facade
}

@Injectable({ providedIn: 'root' })
export class DashboardFacade {

  // ← The facade composes multiple service calls into ONE stream
  readonly dashboardData$: Observable<DashboardViewModel>;

  constructor(
    private userService: UserService,           // ← Facade knows about services
    private analyticsService: AnalyticsService, // ← Not the component
    private notificationService: NotificationService
  ) {
    // ← combineLatest waits for ALL observables to emit at least once
    // ← then re-emits whenever ANY of them emits
    this.dashboardData$ = combineLatest([
      this.userService.getCurrentUser(),
      this.analyticsService.getPageViews(),
      this.analyticsService.getConversionRate(),
      this.notificationService.getUnreadCount()
    ]).pipe(
      map(([user, pageViews, conversionRate, unreadCount]) => ({
        // ← Transform multiple service responses into one clean ViewModel
        userName: `${user.firstName} ${user.lastName}`,
        userEmail: user.email,
        pageViews,
        conversionRate,
        unreadNotifications: unreadCount,
        isHighPerformer: conversionRate > 5.0  // ← Business logic lives in facade, not component
      })),
      shareReplay(1) // ← Cache the latest value so multiple subscribers don't re-trigger
    );
  }

  // ← Facade exposes ACTIONS, not service methods directly
  refreshData(): void {
    // Real implementation would trigger a refresh mechanism
    // e.g., a Subject that the data$ combines with
  }
}
```

```typescript
// src/app/features/dashboard/containers/dashboard.container.ts

import { Component, OnInit } from '@angular/core';
import { DashboardFacade, DashboardViewModel } from '../facades/dashboard.facade';
import { Observable } from 'rxjs';

@Component({
  selector: 'app-dashboard-container',
  template: `
    <!-- Component is THIN -- just wires facade data to presentational components -->
    <ng-container *ngIf="vm$ | async as vm">
      <app-dashboard-header
        [userName]="vm.userName"
        [unreadCount]="vm.unreadNotifications"
      ></app-dashboard-header>

      <app-analytics-panel
        [pageViews]="vm.pageViews"
        [conversionRate]="vm.conversionRate"
        [isHighPerformer]="vm.isHighPerformer"
      ></app-analytics-panel>
    </ng-container>
  `
})
export class DashboardContainerComponent implements OnInit {

  vm$!: Observable<DashboardViewModel>; // ← Receives from facade, not from 5 services

  constructor(
    private facade: DashboardFacade // ← ONE injection instead of many
  ) {}

  ngOnInit(): void {
    this.vm$ = this.facade.dashboardData$; // ← Clean and simple
  }
}
```

### Facade vs Multiple Direct Injections -- Comparison

| Concern | Direct Multi-Service Injection | Facade Pattern |
|---|---|---|
| **Component constructor** | 5+ injected services | 1 facade |
| **Component knowledge** | Must know API of each service | Only knows facade API |
| **Testability** | Must mock 5 services | Mock one facade |
| **Service refactoring** | Any service change breaks component | Only facade needs updating |
| **Data combination logic** | Scattered in component | Centralized in facade |
| **Reuse across components** | Duplicate combination logic | Facade reused everywhere |

---

## 20.4 Repository Pattern for Data Access

### The Problem

When components or services directly call `HttpClient`, data access logic is scattered everywhere: error handling differs per place, caching is ad-hoc or missing, and if you need to change your API URL structure or switch to a different backend, you touch dozens of files.

### The Analogy: A Library Catalog

```
WITHOUT Repository:
  You (component) go searching through the library yourself:
  - Find the right shelf
  - Check if the book is checked out
  - Log your search manually
  - Handle "book missing" yourself
  = You duplicate this effort every time you need a book

WITH Repository:
  You (component) ask the Librarian (Repository):
  - "I need the book called Product #42"
  - Librarian checks the catalog (cache)
  - If not there, librarian finds it on the shelf (HTTP)
  - Librarian logs the lookup (centralized logging)
  - Librarian tells you if it's missing (error handling)
  = You get a clean, consistent interface every time
```

### Repository Architecture Diagram

```
Component / Container
        │
        │ calls
        ↓
  ProductRepository           ← Repository interface (single point of entry)
  ├── get(id)
  ├── getAll()
  ├── create(product)
  └── update(product)
        │
        ├── Cache Layer       ← In-memory or sessionStorage cache
        │   (Map<id, Product>)
        │
        └── HttpClient        ← Only talks to HTTP here
              │
              ↓
         Backend API
```

### Full Example: ProductRepository with Caching

```typescript
// src/app/core/repositories/product.repository.ts

import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, of, throwError } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';
import { Product } from '../models/product.model';
import { environment } from '../../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ProductRepository {

  private readonly baseUrl = `${environment.apiUrl}/products`; // ← One URL definition

  // ← Simple in-memory cache: Map from product ID to Product
  private cache = new Map<number, Product>();
  private allProductsCache: Product[] | null = null; // ← Cache for the full list
  private cacheExpiry = 0; // ← Timestamp when cache becomes stale
  private readonly CACHE_TTL_MS = 5 * 60 * 1000; // ← 5-minute TTL

  constructor(private http: HttpClient) {}

  /**
   * Get all products. Returns cached data if fresh, otherwise fetches from API.
   */
  getAll(): Observable<Product[]> {
    const now = Date.now();

    // ← Cache hit: return cached data without any HTTP call
    if (this.allProductsCache && now < this.cacheExpiry) {
      return of(this.allProductsCache); // ← of() wraps a value in an Observable
    }

    // ← Cache miss: fetch from API
    return this.http.get<Product[]>(this.baseUrl).pipe(
      tap(products => {
        // ← Store in cache after successful fetch
        this.allProductsCache = products;
        this.cacheExpiry = Date.now() + this.CACHE_TTL_MS;

        // ← Also populate individual cache entries
        products.forEach(p => this.cache.set(p.id, p));
      }),
      catchError(this.handleError) // ← Centralized error handling
    );
  }

  /**
   * Get a single product by ID. Checks individual cache first.
   */
  getById(id: number): Observable<Product> {
    // ← Check individual cache first (might have been populated by getAll())
    if (this.cache.has(id)) {
      return of(this.cache.get(id)!); // ← Immediate return from cache
    }

    // ← Cache miss: fetch individual product
    return this.http.get<Product>(`${this.baseUrl}/${id}`).pipe(
      tap(product => this.cache.set(product.id, product)), // ← Cache the result
      catchError(this.handleError)
    );
  }

  /**
   * Create a new product. Invalidates the all-products cache.
   */
  create(product: Omit<Product, 'id'>): Observable<Product> {
    return this.http.post<Product>(this.baseUrl, product).pipe(
      tap(created => {
        this.cache.set(created.id, created); // ← Cache the newly created product
        this.allProductsCache = null;         // ← Invalidate list cache (stale now)
      }),
      catchError(this.handleError)
    );
  }

  /**
   * Update a product. Updates cache and invalidates list cache.
   */
  update(id: number, changes: Partial<Product>): Observable<Product> {
    return this.http.patch<Product>(`${this.baseUrl}/${id}`, changes).pipe(
      tap(updated => {
        this.cache.set(updated.id, updated); // ← Update individual cache
        this.allProductsCache = null;         // ← Invalidate list cache
      }),
      catchError(this.handleError)
    );
  }

  /**
   * Delete a product. Removes from all caches.
   */
  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(
      tap(() => {
        this.cache.delete(id);       // ← Remove from individual cache
        this.allProductsCache = null; // ← Invalidate list cache
      }),
      catchError(this.handleError)
    );
  }

  /**
   * Force-clear all caches. Call after bulk operations or when freshness is required.
   */
  invalidateCache(): void {
    this.cache.clear();
    this.allProductsCache = null;
    this.cacheExpiry = 0;
  }

  /**
   * Centralized error handler -- ONE place to handle all HTTP errors for products.
   */
  private handleError(error: HttpErrorResponse): Observable<never> {
    let userFriendlyMessage: string;

    if (error.status === 404) {
      userFriendlyMessage = 'Product not found.'; // ← Translate HTTP status to meaningful message
    } else if (error.status === 403) {
      userFriendlyMessage = 'You do not have permission to access this product.';
    } else if (error.status === 0) {
      userFriendlyMessage = 'Network error. Please check your connection.';
    } else {
      userFriendlyMessage = `Server error: ${error.status}. Please try again.`;
    }

    // ← In production you would also log to a monitoring service here
    console.error('ProductRepository error:', error);

    return throwError(() => new Error(userFriendlyMessage)); // ← Return meaningful error
  }
}
```

### Benefits of the Repository Pattern

| Concern | Without Repository | With Repository |
|---|---|---|
| **Caching** | Each component implements its own | Centralized, consistent |
| **Error handling** | Different per component | One place for all product errors |
| **API URL changes** | Touch every component that calls the API | Change one constant |
| **Backend swap** | Scatter changes everywhere | Swap implementation behind interface |
| **Testing** | Must mock HttpClient everywhere | Mock only the repository |
| **Cache invalidation** | Forgotten or duplicated | One `invalidateCache()` method |

---

## 20.5 Adapter Pattern for API Integration

### The Problem: Mismatch Between API and Frontend Models

Real-world APIs are designed by backend teams with backend conventions. They often return:
- `snake_case` fields (`first_name`, `created_at`)
- Nested structures that don't match your UI layout
- Fields with cryptic names (`usr_acct_typ`)
- Dates as Unix timestamps instead of ISO strings

If you use the API shapes directly in your frontend, your entire codebase is coupled to the backend's naming conventions. When the backend changes, everything breaks.

### The Analogy: A Power Adapter

```
UK Plug (API Response Shape)
    [ ][ ]   ← 3 square pins (snake_case, nested, different types)

Power Adapter (Adapter Service)
    Converts UK to EU without changing either the plug or the socket

EU Socket (Frontend Domain Model)
    (O) (O)  ← 2 round pins (camelCase, flat, typed)

The Adapter Pattern is exactly this: it converts between two
incompatible shapes WITHOUT changing either end.
```

### Full Example: API Response to Domain Model

**The API shape (what the backend sends):**

```typescript
// src/app/core/api-models/user-api.model.ts
// These interfaces describe EXACTLY what the API returns -- do NOT add camelCase here

export interface UserApiResponse {
  user_id: number;            // ← snake_case from backend
  first_name: string;         // ← snake_case
  last_name: string;          // ← snake_case
  email_address: string;      // ← verbose field name
  created_at: number;         // ← Unix timestamp (seconds since epoch)
  is_active: number;          // ← 0 or 1 instead of boolean
  subscription_tier: string;  // ← Raw string, not typed enum
  addr: {                     // ← Abbreviated field name
    st: string;               // ← More abbreviations
    cty: string;
    cntry: string;
    zip: string;
  };
}
```

**The frontend domain model (what your Angular app uses):**

```typescript
// src/app/core/models/user.model.ts
// Clean, typed, camelCase -- this is what your components work with

export type SubscriptionTier = 'free' | 'pro' | 'enterprise'; // ← Typed union

export interface UserAddress {
  street: string;     // ← Clear field names
  city: string;
  country: string;
  zipCode: string;
}

export interface User {
  id: number;                          // ← Clean camelCase
  firstName: string;
  lastName: string;
  fullName: string;                    // ← Computed, not from API
  email: string;
  createdAt: Date;                     // ← Proper Date object, not Unix timestamp
  isActive: boolean;                   // ← Proper boolean
  subscriptionTier: SubscriptionTier;  // ← Typed enum
  address: UserAddress;                // ← Clearly named sub-object
}
```

**The Adapter Service:**

```typescript
// src/app/core/adapters/user.adapter.ts

import { Injectable } from '@angular/core';
import { UserApiResponse } from '../api-models/user-api.model';
import { User, UserAddress, SubscriptionTier } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserAdapter {

  /**
   * Adapt a single API response to a domain model.
   * This is the ONLY place in the codebase that knows about snake_case field names.
   */
  adapt(apiUser: UserApiResponse): User {
    return {
      id: apiUser.user_id,                          // ← snake_case → camelCase
      firstName: apiUser.first_name,                // ← snake_case → camelCase
      lastName: apiUser.last_name,                  // ← snake_case → camelCase
      fullName: `${apiUser.first_name} ${apiUser.last_name}`, // ← Computed field
      email: apiUser.email_address,                 // ← Rename verbose field
      createdAt: new Date(apiUser.created_at * 1000), // ← Unix seconds → JS Date
      isActive: apiUser.is_active === 1,            // ← Number → boolean
      subscriptionTier: this.adaptTier(apiUser.subscription_tier),
      address: this.adaptAddress(apiUser.addr)      // ← Adapt nested object
    };
  }

  /**
   * Adapt an array of API responses. Useful for list endpoints.
   */
  adaptArray(apiUsers: UserApiResponse[]): User[] {
    return apiUsers.map(u => this.adapt(u)); // ← Apply adapt to each element
  }

  /**
   * Adapt frontend model back to API shape for POST/PUT requests.
   * The REVERSE adaptation for sending data to the server.
   */
  adaptToApi(user: Partial<User>): Partial<UserApiResponse> {
    const result: Partial<UserApiResponse> = {};

    if (user.firstName !== undefined) result.first_name = user.firstName; // ← Reverse
    if (user.lastName !== undefined) result.last_name = user.lastName;
    if (user.email !== undefined) result.email_address = user.email;
    if (user.isActive !== undefined) result.is_active = user.isActive ? 1 : 0; // ← boolean → 0/1

    return result;
  }

  private adaptTier(apiTier: string): SubscriptionTier {
    // ← Safely map API string to typed union -- default to 'free' if unknown
    const tierMap: Record<string, SubscriptionTier> = {
      'FREE': 'free',
      'PRO': 'pro',
      'ENT': 'enterprise',   // ← API uses abbreviated value
      'ENTERPRISE': 'enterprise'
    };
    return tierMap[apiTier] ?? 'free'; // ← Nullish coalescing -- default to 'free'
  }

  private adaptAddress(apiAddr: UserApiResponse['addr']): UserAddress {
    return {
      street: apiAddr.st,    // ← Expand abbreviations
      city: apiAddr.cty,
      country: apiAddr.cntry,
      zipCode: apiAddr.zip
    };
  }
}
```

**Using the adapter in the repository:**

```typescript
// src/app/core/repositories/user.repository.ts

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { UserApiResponse } from '../api-models/user-api.model';
import { User } from '../models/user.model';
import { UserAdapter } from '../adapters/user.adapter';

@Injectable({ providedIn: 'root' })
export class UserRepository {

  constructor(
    private http: HttpClient,
    private adapter: UserAdapter // ← Inject the adapter
  ) {}

  getCurrentUser(): Observable<User> {
    return this.http.get<UserApiResponse>('/api/me').pipe(
      map(apiResponse => this.adapter.adapt(apiResponse)) // ← Transform at the boundary
      // ← Everything ABOVE this line works with snake_case API shapes
      // ← Everything BELOW this line works with clean domain models
    );
  }

  getAll(): Observable<User[]> {
    return this.http.get<UserApiResponse[]>('/api/users').pipe(
      map(apiUsers => this.adapter.adaptArray(apiUsers)) // ← Adapt the array
    );
  }
}
// ← Components NEVER see UserApiResponse -- they only see clean User objects
// ← If the API renames user_id to usr_identifier, only the adapter changes
```

---

## 20.6 Dynamic Component Loading

### The Problem

Some features require rendering components that are not known at compile time. Examples: a configurable dashboard where users drag and drop widgets, a plugin system where third-party components are registered, or a form builder that creates fields based on a JSON schema.

### Core APIs for Dynamic Loading

```typescript
// Two key APIs for dynamic component loading:

// ViewContainerRef: a "slot" in the DOM where you can insert components dynamically
// Think of it as an empty div that Angular can programmatically fill

// createComponent(): creates a component instance and inserts it into a ViewContainerRef
// Available on ViewContainerRef since Angular 14+

// ComponentRef: a handle to the created component -- lets you set @Inputs and listen to @Outputs
```

### Full Example: Dynamic Dashboard with Configurable Widgets

**Widget interfaces:**

```typescript
// src/app/features/dashboard/models/widget.model.ts

export interface WidgetConfig {
  type: 'chart' | 'stats' | 'map' | 'table'; // ← Which widget to load
  title: string;
  config: Record<string, unknown>;            // ← Widget-specific configuration
}
```

**Individual widget components:**

```typescript
// src/app/features/dashboard/widgets/chart-widget.component.ts

import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-chart-widget',
  template: `
    <div class="widget chart-widget">
      <h3>{{ title }}</h3>
      <div class="chart-placeholder">Chart here with data: {{ config | json }}</div>
    </div>
  `
})
export class ChartWidgetComponent {
  @Input() title = '';
  @Input() config: Record<string, unknown> = {};
}

// src/app/features/dashboard/widgets/stats-widget.component.ts

@Component({
  selector: 'app-stats-widget',
  template: `
    <div class="widget stats-widget">
      <h3>{{ title }}</h3>
      <p class="stat-number">{{ config['value'] }}</p>
    </div>
  `
})
export class StatsWidgetComponent {
  @Input() title = '';
  @Input() config: Record<string, unknown> = {};
}
```

**The dynamic widget loader:**

```typescript
// src/app/features/dashboard/components/dynamic-widget-loader.component.ts

import {
  Component,
  Input,
  OnChanges,
  OnDestroy,
  ViewChild,
  ViewContainerRef,
  ComponentRef,
  Type
} from '@angular/core';
import { WidgetConfig } from '../models/widget.model';
import { ChartWidgetComponent } from '../widgets/chart-widget.component';
import { StatsWidgetComponent } from '../widgets/stats-widget.component';

// ← Registry: maps widget type strings to component classes
// ← This is the only place that knows about all widget types
const WIDGET_REGISTRY: Record<string, Type<unknown>> = {
  'chart': ChartWidgetComponent,
  'stats': StatsWidgetComponent
};

@Component({
  selector: 'app-dynamic-widget-loader',
  template: `
    <!-- ng-container with #widgetHost is the "slot" where components will be inserted -->
    <ng-container #widgetHost></ng-container>
  `
})
export class DynamicWidgetLoaderComponent implements OnChanges, OnDestroy {

  @Input() widgetConfig!: WidgetConfig; // ← Receives config describing WHICH widget to load

  // ← @ViewChild grabs a reference to the DOM slot where we'll insert the component
  @ViewChild('widgetHost', { read: ViewContainerRef, static: true })
  widgetHost!: ViewContainerRef;

  private componentRef: ComponentRef<unknown> | null = null; // ← Handle to the created component

  ngOnChanges(): void {
    this.loadWidget(); // ← Re-load when config changes
  }

  private loadWidget(): void {
    // ← Step 1: clear any previously loaded component
    this.widgetHost.clear();
    if (this.componentRef) {
      this.componentRef.destroy(); // ← Clean up previous component
      this.componentRef = null;
    }

    // ← Step 2: look up the component class from the registry
    const componentClass = WIDGET_REGISTRY[this.widgetConfig.type];
    if (!componentClass) {
      console.error(`Unknown widget type: ${this.widgetConfig.type}`);
      return;
    }

    // ← Step 3: dynamically create the component and insert it into the slot
    this.componentRef = this.widgetHost.createComponent(
      componentClass as Type<{ title: string; config: Record<string, unknown> }>
    );

    // ← Step 4: set @Input values on the dynamically created component
    // ← instance gives access to the component's public properties
    const instance = this.componentRef.instance as {
      title: string;
      config: Record<string, unknown>;
    };
    instance.title = this.widgetConfig.title;       // ← Set @Input programmatically
    instance.config = this.widgetConfig.config;     // ← Set @Input programmatically

    // ← Step 5: trigger change detection so the new @Inputs are reflected
    this.componentRef.changeDetectorRef.detectChanges();
  }

  ngOnDestroy(): void {
    // ← Always clean up dynamic components to prevent memory leaks
    if (this.componentRef) {
      this.componentRef.destroy();
    }
  }
}
```

**The dashboard container using dynamic widgets:**

```typescript
// src/app/features/dashboard/containers/dynamic-dashboard.container.ts

import { Component, OnInit } from '@angular/core';
import { WidgetConfig } from '../models/widget.model';

@Component({
  selector: 'app-dynamic-dashboard',
  template: `
    <div class="dashboard-grid">
      <!-- For each widget config, a loader dynamically creates the right component -->
      <app-dynamic-widget-loader
        *ngFor="let widget of widgets; trackBy: trackByTitle"
        [widgetConfig]="widget"
      ></app-dynamic-widget-loader>
    </div>
  `
})
export class DynamicDashboardContainerComponent implements OnInit {

  widgets: WidgetConfig[] = []; // ← Populated from user preferences or API

  ngOnInit(): void {
    // ← In real app, fetch this from user preferences API
    this.widgets = [
      { type: 'stats', title: 'Total Revenue', config: { value: '$48,295' } },
      { type: 'chart', title: 'Monthly Sales', config: { data: [], type: 'line' } },
      { type: 'stats', title: 'Active Users', config: { value: '1,284' } }
    ];
  }

  trackByTitle(_: number, w: WidgetConfig): string {
    return w.title; // ← Stable identity for ngFor
  }
}
```

### NgComponentOutlet -- The Simpler Alternative

```typescript
// NgComponentOutlet is a directive-based alternative to ViewContainerRef
// Use it when you don't need to set @Inputs dynamically (or when using injector)

@Component({
  selector: 'app-simple-dynamic',
  template: `
    <!-- NgComponentOutlet handles the createComponent lifecycle for you -->
    <ng-container [ngComponentOutlet]="currentComponent"></ng-container>
  `
})
export class SimpleDynamicComponent {
  // ← Just set this property to any component class and Angular loads it
  currentComponent: Type<unknown> = ChartWidgetComponent;

  switchToStats(): void {
    this.currentComponent = StatsWidgetComponent; // ← Angular automatically swaps
  }
}
```

### When to Use Each Approach

| Scenario | Recommended Approach |
|---|---|
| Need to set @Inputs dynamically | `ViewContainerRef.createComponent()` |
| Just need to swap components | `NgComponentOutlet` directive |
| Plugin system with registration | `ViewContainerRef` + registry Map |
| Configurable form fields | `ViewContainerRef.createComponent()` |
| Simple conditional component rendering | `*ngIf` with multiple components |

---

## 20.7 Advanced Template Techniques

### ng-template Deep Dive

`ng-template` is a blueprint -- it defines HTML that is NOT rendered immediately. It is rendered only when explicitly instantiated, either by a structural directive or by `ngTemplateOutlet`.

**TemplateRef with context -- passing data into templates:**

```typescript
// src/app/shared/components/data-table/data-table.component.ts

import { Component, Input, ContentChild, TemplateRef } from '@angular/core';

// ← Define the context shape -- what data the template has access to
export interface RowContext<T> {
  $implicit: T;    // ← $implicit is the default variable (used with 'let item')
  index: number;   // ← Extra context variables must be named
  isLast: boolean;
}

@Component({
  selector: 'app-data-table',
  template: `
    <table>
      <tbody>
        <tr *ngFor="let item of data; let i = index; let isLast = last">
          <!-- ngTemplateOutlet renders the template with a context object -->
          <ng-container
            *ngTemplateOutlet="rowTemplate; context: buildContext(item, i, isLast)"
          ></ng-container>
        </tr>
      </tbody>
    </table>
  `
})
export class DataTableComponent<T> {
  @Input() data: T[] = [];

  // ← @ContentChild grabs the template projected from the parent
  @ContentChild('rowTemplate')
  rowTemplate!: TemplateRef<RowContext<T>>;

  buildContext(item: T, index: number, isLast: boolean): RowContext<T> {
    return {
      $implicit: item,  // ← This becomes the 'let item' variable
      index,
      isLast
    };
  }
}
```

**Using the data-table with custom row templates:**

```html
<!-- Parent component template -->
<app-data-table [data]="products">

  <!-- 'let product' binds to $implicit -->
  <!-- 'let i = index' binds to the named context variable -->
  <!-- 'let last = isLast' binds to the named context variable -->
  <ng-template #rowTemplate let-product let-i="index" let-last="isLast">
    <td [class.last-row]="last">{{ i + 1 }}</td>
    <td>{{ product.name }}</td>
    <td>{{ product.price | currency }}</td>
  </ng-template>

</app-data-table>
```

### ng-container Advanced Usage

`ng-container` is a grouping element that renders NO actual DOM element. It is essential for applying multiple structural directives and for avoiding wrapper elements that would break CSS layouts.

```html
<!-- PROBLEM: Can't put two structural directives on the same element -->
<!-- This causes a compile error: -->
<tr *ngFor="let item of items" *ngIf="item.visible">...</tr>

<!-- SOLUTION: ng-container as the wrapper for the outer directive -->
<ng-container *ngFor="let item of items">
  <!-- The *ngIf goes on the element (or another ng-container) inside -->
  <tr *ngIf="item.visible">
    <td>{{ item.name }}</td>
  </tr>
</ng-container>
```

```html
<!-- ADVANCED: ng-container + ngTemplateOutlet for component composition -->
<!-- This lets you conditionally render different templates cleanly -->

<ng-container
  *ngTemplateOutlet="isLoggedIn ? authenticatedTemplate : guestTemplate"
></ng-container>

<ng-template #authenticatedTemplate>
  <app-user-dashboard></app-user-dashboard>
</ng-template>

<ng-template #guestTemplate>
  <app-login-prompt></app-login-prompt>
</ng-template>
```

### Content Projection Advanced Patterns

**Multi-slot projection with named slots:**

```typescript
// src/app/shared/components/card/card.component.ts

import { Component, ContentChild, TemplateRef } from '@angular/core';

@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <!-- Named slot for header -->
      <div class="card-header">
        <ng-content select="[card-header]"></ng-content>
        <!-- ← select="[card-header]" means: only project elements with attribute card-header -->
      </div>

      <!-- Named slot for body -->
      <div class="card-body">
        <ng-content select="[card-body]"></ng-content>
      </div>

      <!-- Named slot for footer -->
      <div class="card-footer">
        <!-- Default content when nothing is projected into the footer slot -->
        <ng-content select="[card-footer]"></ng-content>
        <ng-container *ngIf="!hasFooterContent">
          <span class="default-footer">No footer provided</span>
        </ng-container>
      </div>

      <!-- Catch-all: projects anything NOT matched by a named select -->
      <ng-content></ng-content>
    </div>
  `
})
export class CardComponent {
  // ← @ContentChild detects if footer content was projected
  @ContentChild('[card-footer]') footerContent?: unknown;

  get hasFooterContent(): boolean {
    return !!this.footerContent;
  }
}
```

**Using the multi-slot card:**

```html
<!-- Consumer template -->
<app-card>
  <!-- This goes into the [card-header] slot -->
  <h2 card-header>Product Details</h2>

  <!-- This goes into the [card-body] slot -->
  <div card-body>
    <p>{{ product.description }}</p>
    <p>Price: {{ product.price | currency }}</p>
  </div>

  <!-- This goes into the [card-footer] slot -->
  <div card-footer>
    <button (click)="addToCart()">Add to Cart</button>
  </div>
</app-card>
```

---

## 20.8 Custom Structural Directives

### How Structural Directives Work Under the Hood

The `*` syntax is syntactic sugar. Angular desugars it at compile time:

```html
<!-- What you write: -->
<div *ngIf="condition">Content</div>

<!-- What Angular actually compiles it to: -->
<ng-template [ngIf]="condition">
  <div>Content</div>
</ng-template>
```

So `*directive="expression"` becomes `<ng-template [directive]="expression">`. Understanding this desugaring is key to writing custom structural directives.

### Core Injections for Structural Directives

```typescript
// Every structural directive needs two injections:

// TemplateRef<C>: the template inside the ng-template (the "blueprint")
// ViewContainerRef: where the rendered content will be inserted (the "canvas")

constructor(
  private templateRef: TemplateRef<unknown>,  // ← The blueprint
  private viewContainer: ViewContainerRef     // ← The canvas
) {}

// To SHOW content: this.viewContainer.createEmbeddedView(this.templateRef)
// To HIDE content: this.viewContainer.clear()
```

### Full Example: *appRepeat Directive

```typescript
// src/app/shared/directives/repeat.directive.ts

import {
  Directive,
  Input,
  OnChanges,
  TemplateRef,
  ViewContainerRef
} from '@angular/core';

// ← Context object: what variables are available inside the template
export interface RepeatContext {
  $implicit: number;  // ← The current iteration index (0-based)
  index: number;      // ← Explicit index (same value)
  count: number;      // ← Total count being repeated
}

@Directive({
  selector: '[appRepeat]' // ← The selector must match the attribute name after *
})
export class RepeatDirective implements OnChanges {

  // ← When used as *appRepeat="3", the value 3 is bound to appRepeat (same name as selector)
  @Input() appRepeat = 0; // ← Number of times to repeat

  constructor(
    private templateRef: TemplateRef<RepeatContext>, // ← The template blueprint
    private viewContainer: ViewContainerRef          // ← Where to render
  ) {}

  ngOnChanges(): void {
    this.viewContainer.clear(); // ← Remove all previously created views

    // ← Create the template N times
    for (let i = 0; i < this.appRepeat; i++) {
      this.viewContainer.createEmbeddedView(
        this.templateRef,
        {
          $implicit: i,       // ← Accessible as 'let index' in template
          index: i,           // ← Accessible as 'let i = index'
          count: this.appRepeat // ← Accessible as 'let total = count'
        }
      );
    }
  }

  // ← Type guard: tells Angular what context variables are available
  // ← This enables template type checking for 'let' variables
  static ngTemplateContextGuard(
    _dir: RepeatDirective,
    ctx: unknown
  ): ctx is RepeatContext {
    return true;
  }
}
```

**Using *appRepeat:**

```html
<!-- Repeat a star rating 5 times -->
<span *appRepeat="5; let i = index; let total = count">
  ★ {{ i + 1 }} of {{ total }}
</span>

<!-- Renders: ★ 1 of 5  ★ 2 of 5  ★ 3 of 5  ★ 4 of 5  ★ 5 of 5 -->

<!-- Microsyntax breakdown:
  *appRepeat="5; let i = index; let total = count"
  │           │   │             │
  │           │   │             └── binds template var 'total' to context.count
  │           │   └── binds template var 'i' to context.index
  │           └── value passed to @Input() appRepeat
  └── desugars to [appRepeat]="5" on <ng-template>
-->
```

### Full Example: *appPermission Directive

```typescript
// src/app/shared/directives/permission.directive.ts

import {
  Directive,
  Input,
  OnInit,
  TemplateRef,
  ViewContainerRef
} from '@angular/core';
import { AuthService } from '../../core/services/auth.service';

@Directive({
  selector: '[appPermission]'
})
export class PermissionDirective implements OnInit {

  @Input() appPermission!: string; // ← The required permission, e.g. 'admin', 'editor'

  // ← Optional: what to show when permission is DENIED (an else template)
  @Input() appPermissionElse?: TemplateRef<void>;

  constructor(
    private templateRef: TemplateRef<void>,  // ← The main template (shown if permitted)
    private viewContainer: ViewContainerRef, // ← Where to render
    private authService: AuthService         // ← Inject auth to check permissions
  ) {}

  ngOnInit(): void {
    const hasPermission = this.authService.hasPermission(this.appPermission);

    this.viewContainer.clear(); // ← Always clear first

    if (hasPermission) {
      // ← User has permission: render the main template
      this.viewContainer.createEmbeddedView(this.templateRef);
    } else if (this.appPermissionElse) {
      // ← User lacks permission AND an else template was provided: render the else
      this.viewContainer.createEmbeddedView(this.appPermissionElse);
    }
    // ← If no permission and no else template: renders nothing (equivalent to *ngIf false)
  }
}
```

**Using *appPermission:**

```html
<!-- Show admin panel only to admins -->
<div *appPermission="'admin'">
  <app-admin-panel></app-admin-panel>
</div>

<!-- With an else template for unauthorized users -->
<div *appPermission="'admin'; else noAccess">
  <app-admin-panel></app-admin-panel>
</div>

<ng-template #noAccess>
  <p>You do not have permission to view this section.</p>
</ng-template>
```

### Microsyntax Explained

Angular's structural directive microsyntax (`*dir="expression; let x = y; let z"`) follows rules:

```
*appRepeat="5; let i = index; let total = count"

Desugars to:
<ng-template [appRepeat]="5" let-i="index" let-total="count">
  ...
</ng-template>

Rules:
- The first expression binds to the directive's @Input with the SAME name as the selector
- "let varName = contextKey" maps template var to context object key
- "let varName" alone binds to $implicit in the context
- Multiple bindings are separated by semicolons
```

---

## 20.9 Advanced Dependency Injection

### 20.9.1 InjectionToken

#### The Problem

Angular's DI system works by using a CLASS as a token. But what if you want to inject a configuration object (a plain `{}`)? Classes are used as tokens, and plain objects are not classes.

```typescript
// PROBLEM: You can't inject a plain object this way
// This doesn't work -- Angular has no class token for a config object
constructor(@Inject(???) private config: AppConfig) {}
```

`InjectionToken` solves this by creating a unique token for non-class values.

```typescript
// src/app/core/tokens/app-config.token.ts

import { InjectionToken } from '@angular/core';

// ← Define the shape of the config object
export interface AppConfig {
  apiUrl: string;
  maxRetries: number;
  debugMode: boolean;
  featureFlags: {
    newCheckout: boolean;
    darkMode: boolean;
  };
}

// ← Create a unique token for this config type
// ← The string 'AppConfig' is just for debugging -- it shows in error messages
export const APP_CONFIG = new InjectionToken<AppConfig>('AppConfig');
```

```typescript
// src/app/app.module.ts

import { NgModule } from '@angular/core';
import { APP_CONFIG, AppConfig } from './core/tokens/app-config.token';

const appConfig: AppConfig = {
  apiUrl: 'https://api.myapp.com',
  maxRetries: 3,
  debugMode: false,
  featureFlags: {
    newCheckout: true,
    darkMode: false
  }
};

@NgModule({
  providers: [
    {
      provide: APP_CONFIG,    // ← The token (not a class, but an InjectionToken)
      useValue: appConfig     // ← The value to inject
    }
  ]
})
export class AppModule {}
```

```typescript
// Usage in a service or component:

import { Inject, Injectable } from '@angular/core';
import { APP_CONFIG, AppConfig } from '../tokens/app-config.token';

@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(
    @Inject(APP_CONFIG) private config: AppConfig // ← @Inject tells Angular which token to use
  ) {
    // ← config.apiUrl, config.maxRetries etc. are now fully typed
    console.log('API URL:', this.config.apiUrl);
  }
}
```

### 20.9.2 @Optional, @Self, @SkipSelf, @Host

Angular's DI resolves tokens by walking UP the injector hierarchy. These decorators control that walk.

**Injector Hierarchy:**

```
Platform Injector (highest level -- singleton services)
    │
    ↓
Root Injector (AppModule providers, providedIn: 'root')
    │
    ↓
Feature Module Injector (lazy-loaded module providers)
    │
    ↓
Component Injector (component providers: [...] array)
    │
    ↓
Child Component Injector
```

**@Optional -- don't throw if not found:**

```typescript
import { Optional, Injectable } from '@angular/core';
import { LoggingService } from './logging.service';

@Injectable()
export class FeatureService {
  constructor(
    // ← WITHOUT @Optional: throws error if LoggingService is not provided
    // ← WITH @Optional: injects null if LoggingService is not provided
    @Optional() private logger: LoggingService | null
  ) {}

  doSomething(): void {
    this.logger?.log('Doing something'); // ← Safe call: no error if logger is null
  }
}
```

**@Self -- only look in THIS component's injector:**

```typescript
@Component({
  providers: [{ provide: SomeService, useClass: LocalSomeService }] // ← Component-level provider
})
export class MyComponent {
  constructor(
    // ← @Self: ONLY looks in MyComponent's own providers array
    // ← Throws error if SomeService is not in THIS component's providers
    // ← Will NOT look in parent components or root
    @Self() private svc: SomeService
  ) {}
}
```

**@SkipSelf -- skip my injector, look in parent:**

```typescript
@Component({
  providers: [LoggingService] // ← Provides its own LoggingService
})
export class ParentComponent {}

@Component({
  providers: [LoggingService] // ← Also has its own LoggingService
})
export class ChildComponent {
  constructor(
    // ← WITHOUT @SkipSelf: gets ChildComponent's own LoggingService
    // ← WITH @SkipSelf: skips ChildComponent's provider, gets ParentComponent's
    @SkipSelf() private parentLogger: LoggingService
  ) {}
}
```

**@Host -- look up to the host component's injector:**

```typescript
// Useful in directives: look for a service in the HOST ELEMENT's injector
// (not in the directive's own injector, and not beyond the host)

@Directive({ selector: '[appHighlight]' })
export class HighlightDirective {
  constructor(
    // ← @Host: looks in the injector of the ELEMENT this directive is applied to
    // ← If that component provides FormGroup, this gets it; otherwise error
    // ← Combine with @Optional to avoid error: @Optional() @Host()
    @Optional() @Host() private formGroup: FormGroup | null
  ) {}
}
```

### 20.9.3 Multi-Providers

`multi: true` allows MULTIPLE values to be registered for the SAME token, and they are collected into an ARRAY.

```typescript
// Angular uses this for HTTP_INTERCEPTORS -- you register multiple interceptors
// and Angular collects them all into one array

// src/app/core/tokens/logger.token.ts

import { InjectionToken } from '@angular/core';

export interface Logger {
  log(message: string): void;
}

// ← Token for an array of loggers (multi-provider)
export const LOGGERS = new InjectionToken<Logger[]>('LOGGERS');
```

```typescript
// Register multiple loggers -- each uses multi: true

@NgModule({
  providers: [
    {
      provide: LOGGERS,
      useClass: ConsoleLogger, // ← First logger: logs to console
      multi: true              // ← multi: true means "add to the array, don't replace"
    },
    {
      provide: LOGGERS,
      useClass: RemoteLogger,  // ← Second logger: sends to analytics server
      multi: true              // ← Same token, multi: true -- APPENDED to array
    },
    {
      provide: LOGGERS,
      useClass: LocalStorageLogger, // ← Third logger: persists locally
      multi: true
    }
  ]
})
export class AppModule {}
```

```typescript
// Consuming the multi-provider:

@Injectable({ providedIn: 'root' })
export class LoggingService {
  constructor(
    @Inject(LOGGERS) private loggers: Logger[] // ← Receives ALL three loggers as an array
  ) {}

  log(message: string): void {
    // ← Calls every registered logger -- console, remote, and localStorage
    this.loggers.forEach(logger => logger.log(message));
  }
}
```

### 20.9.4 useClass, useValue, useFactory, useExisting

```typescript
// COMPARISON TABLE:
// Provider type    When to use                           Example

// useClass:        Substitute one class for another      Testing (mock class), conditional impl
// useValue:        Inject a constant/object              Config objects, strings, feature flags
// useFactory:      Dynamic creation based on conditions  Token-based auth, environment-specific
// useExisting:     Alias one token to another            Multiple tokens, same instance

// ────────────────────────────────────────────────────

// useClass: Substitute one implementation for another
// Useful for providing a mock in tests or swapping implementations

abstract class PaymentGateway {
  abstract processPayment(amount: number): Observable<Receipt>;
}

@NgModule({
  providers: [
    {
      provide: PaymentGateway,        // ← Provide the ABSTRACT CLASS as the token
      useClass: StripePaymentGateway  // ← Inject THIS concrete implementation
      // ← To switch to PayPal: just change this one line
    }
  ]
})
export class AppModule {}

// useValue: Inject a pre-built value (no class needed)

const STRIPE_CONFIG = { publicKey: 'pk_live_...', currency: 'USD' };

@NgModule({
  providers: [
    {
      provide: STRIPE_CONFIG_TOKEN, // ← InjectionToken
      useValue: STRIPE_CONFIG       // ← Plain object, injected as-is
    }
  ]
})
export class AppModule {}

// useFactory: Build the dependency dynamically

@NgModule({
  providers: [
    {
      provide: HttpClient,
      useFactory: (handler: HttpHandler, config: AppConfig) => {
        // ← Factory receives its own dependencies via 'deps'
        if (config.debugMode) {
          return new HttpClient(new DebugHttpHandler(handler)); // ← Debug version
        }
        return new HttpClient(handler); // ← Normal version
      },
      deps: [HttpHandler, APP_CONFIG] // ← Factory dependencies, resolved by DI
    }
  ]
})
export class AppModule {}

// useExisting: Create an alias from one token to another (same instance)

@NgModule({
  providers: [
    AuthService, // ← AuthService is registered normally

    {
      provide: UserStateService, // ← A different token
      useExisting: AuthService   // ← BUT resolves to the SAME AuthService instance (not a new one)
      // ← Useful when a legacy token needs to resolve to a new service
    }
  ]
})
export class AppModule {}
```

---

## 20.10 Mono-Repo with Nx

### What is Nx and Why Mono-Repos?

A mono-repo is a single Git repository containing multiple related applications and libraries. Instead of having `frontend-repo`, `admin-repo`, and `shared-components-repo` as separate repositories, they all live together.

**Nx** is a build system and CLI that makes mono-repos practical with features like:
- Smart caching (only rebuild what changed)
- Affected detection (only test what's impacted by a change)
- Dependency graph visualization
- Code generators for consistency

### Nx Architecture Diagram

```
monorepo/
├── apps/
│   ├── customer-app/          ← Customer-facing Angular app
│   ├── admin-app/             ← Admin Angular app
│   └── mobile-app/            ← React Native app (yes, mixed frameworks)
├── libs/
│   ├── shared/
│   │   ├── ui/                ← Shared UI components (used by all apps)
│   │   ├── util/              ← Shared utilities
│   │   └── data-access/       ← Shared services and state
│   ├── customer/
│   │   ├── feature-checkout/  ← Feature-specific library
│   │   └── feature-orders/    ← Feature-specific library
│   └── admin/
│       └── feature-users/     ← Admin-specific feature library
└── nx.json                    ← Nx configuration
```

### Key Nx Commands

```bash
# Generate a new Angular app
npx nx generate @nrwl/angular:app customer-app

# Generate a shared library
npx nx generate @nrwl/angular:lib shared-ui

# Generate a feature library inside the customer directory
npx nx generate @nrwl/angular:lib feature-checkout --directory=customer

# Run tests only for projects AFFECTED by recent changes
# (Nx figures out the dependency graph and only tests what matters)
npx nx affected:test --base=main

# Build only affected apps
npx nx affected:build --base=main

# Visualize the dependency graph in your browser
npx nx graph
```

### Using Shared Libraries

```typescript
// In libs/shared/ui/src/lib/button/button.component.ts
// This component is in the shared library

@Component({
  selector: 'lib-button',
  template: `<button [class]="variant" (click)="click.emit()"><ng-content></ng-content></button>`
})
export class ButtonComponent {
  @Input() variant: 'primary' | 'secondary' = 'primary';
  @Output() click = new EventEmitter<void>();
}

// In apps/customer-app: import from the library path alias
// (defined in tsconfig.base.json)
import { ButtonComponent } from '@mycompany/shared-ui';
// ← NOT a relative path -- uses the workspace path alias
// ← Nx configures TypeScript path aliases automatically

// In apps/admin-app: same import, same component, zero duplication
import { ButtonComponent } from '@mycompany/shared-ui';
```

### Enforcing Module Boundaries

```json
// nx.json -- enforce that admin features can't import customer features

{
  "tasksRunnerOptions": { ... },
  "targetDefaults": { ... },
  "generators": { ... },
  "plugins": [
    {
      "plugin": "@nx/eslint/plugin",
      "options": {
        "targetName": "lint"
      }
    }
  ]
}

// .eslintrc.json -- boundary enforcement rules
{
  "rules": {
    "@nx/enforce-module-boundaries": [
      "error",
      {
        "depConstraints": [
          {
            "sourceTag": "scope:admin",
            "onlyDependOnLibsWithTags": ["scope:admin", "scope:shared"]
          },
          {
            "sourceTag": "scope:customer",
            "onlyDependOnLibsWithTags": ["scope:customer", "scope:shared"]
          }
        ]
      }
    ]
  }
}
// ← This lint rule ENFORCES architectural boundaries at CI time
// ← admin code cannot accidentally import customer-specific code
```

---

## 20.11 Micro-Frontends with Module Federation

### What Are Micro-Frontends?

Micro-frontends apply microservice principles to the frontend. Instead of one large Angular app, you have multiple independently deployed Angular apps (each owned by a different team) that compose into one user experience at runtime.

### Architecture Diagram

```
User's Browser
┌──────────────────────────────────────────────────────────────────┐
│  Shell Application (Host)                                        │
│  ├── Navigation                                                  │
│  ├── Authentication                                              │
│  └── Layout shell                                                │
│                                                                  │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │  Products MFE   │  │   Orders MFE     │  │  Profile MFE   │  │
│  │  (Team Alpha)   │  │   (Team Beta)    │  │  (Team Gamma)  │  │
│  │  Port 4201      │  │   Port 4202      │  │  Port 4203     │  │
│  └─────────────────┘  └──────────────────┘  └────────────────┘  │
│                                                                  │
│  Shared: Angular core, RxJS, common UI libs (loaded ONCE)        │
└──────────────────────────────────────────────────────────────────┘

Each MFE:
- Has its own repository
- Deploys independently
- Owned by a different team
- Can be updated without redeploying the shell
```

### Setup with @angular-architects/module-federation

```bash
# In the SHELL app:
ng add @angular-architects/module-federation --project shell --port 4200 --type host

# In each REMOTE app:
ng add @angular-architects/module-federation --project products-mfe --port 4201 --type remote
```

**Remote app webpack config:**

```javascript
// apps/products-mfe/webpack.config.js

const { shareAll, withModuleFederationPlugin } = require('@angular-architects/module-federation/webpack');

module.exports = withModuleFederationPlugin({
  name: 'productsMfe', // ← Unique name for this remote

  exposes: {
    // ← Maps a public name to the module being exposed
    './Module': './src/app/products/products.module.ts'
    // ← Shell app will load this module at runtime
  },

  shared: {
    ...shareAll({                // ← Share ALL dependencies
      singleton: true,           // ← Only one instance across all MFEs
      strictVersion: true,       // ← Must use the exact version
      requiredVersion: 'auto'    // ← Auto-detect from package.json
    })
  }
});
```

**Shell app webpack config:**

```javascript
// apps/shell/webpack.config.js

const { shareAll, withModuleFederationPlugin } = require('@angular-architects/module-federation/webpack');

module.exports = withModuleFederationPlugin({
  remotes: {
    // ← Map a name to the URL where the remote is deployed
    'productsMfe': 'http://localhost:4201/remoteEntry.js',
    'ordersMfe': 'http://localhost:4202/remoteEntry.js'
    // ← In production: use absolute URLs of each deployed MFE
  },

  shared: {
    ...shareAll({ singleton: true, strictVersion: true, requiredVersion: 'auto' })
  }
});
```

**Shell app routing -- lazy loading remote modules:**

```typescript
// apps/shell/src/app/app-routing.module.ts

import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { loadRemoteModule } from '@angular-architects/module-federation';

const routes: Routes = [
  {
    path: 'products',
    loadChildren: () =>
      // ← loadRemoteModule fetches the remote's bundle at runtime
      loadRemoteModule({
        type: 'module',
        remoteEntry: 'http://localhost:4201/remoteEntry.js', // ← Remote app URL
        exposedModule: './Module' // ← Matches the key in the remote's exposes
      }).then(m => m.ProductsModule) // ← Get the actual Angular module
  },
  {
    path: 'orders',
    loadChildren: () =>
      loadRemoteModule({
        type: 'module',
        remoteEntry: 'http://localhost:4202/remoteEntry.js',
        exposedModule: './Module'
      }).then(m => m.OrdersModule)
  }
];
```

---

## 20.12 Error Handling Architecture

### The Problem: Ad-Hoc Error Handling

Without a plan, error handling is scattered: some components show `alert()`, some silently swallow errors, some show different error messages for the same HTTP 500. Users see inconsistent experiences, and errors are never logged for debugging.

### Complete Error Handling Pipeline

```
Error Occurs (HTTP 500, null reference, etc.)
        │
        ↓
  HTTP Interceptor ─────→ (for HTTP errors)
        │                  Standardizes HTTP errors
        │                  Retries transient failures
        │
        ↓
  Global ErrorHandler ──→ (for ALL uncaught errors)
        │                  Catches anything that escapes component code
        │
        ↓
  Error Logging Service → Sends error details to backend monitoring
        │                  (Sentry, DataDog, custom endpoint)
        │
        ↓
  Error Display Service → Shows user-friendly message
                          (toast notification, error banner, redirect)
```

**Global Error Handler:**

```typescript
// src/app/core/handlers/global-error.handler.ts

import { ErrorHandler, Injectable, NgZone } from '@angular/core';
import { ErrorLoggingService } from '../services/error-logging.service';
import { ErrorDisplayService } from '../services/error-display.service';

@Injectable()
export class GlobalErrorHandler implements ErrorHandler {

  constructor(
    private errorLogger: ErrorLoggingService,
    private errorDisplay: ErrorDisplayService,
    private zone: NgZone // ← Need NgZone because error handler runs outside Angular zone
  ) {}

  handleError(error: unknown): void {
    const err = error instanceof Error ? error : new Error(String(error));

    // ← Log the error to monitoring service (Sentry, etc.)
    this.errorLogger.logError(err);

    // ← Run inside NgZone so Angular change detection picks up the display update
    this.zone.run(() => {
      this.errorDisplay.showError('An unexpected error occurred. Our team has been notified.');
    });

    // ← Always log to console in development
    console.error('Global Error Handler caught:', err);
  }
}
```

**Error Logging Service:**

```typescript
// src/app/core/services/error-logging.service.ts

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { catchError, EMPTY } from 'rxjs';

export interface ErrorReport {
  message: string;
  stack?: string;
  url: string;
  timestamp: string;
  userAgent: string;
  userId?: string;
}

@Injectable({ providedIn: 'root' })
export class ErrorLoggingService {

  private readonly logEndpoint = '/api/errors/log'; // ← Your error logging endpoint

  constructor(private http: HttpClient) {}

  logError(error: Error, context?: Record<string, unknown>): void {
    const report: ErrorReport = {
      message: error.message,
      stack: error.stack,
      url: window.location.href,              // ← Where the error happened
      timestamp: new Date().toISOString(),    // ← When it happened
      userAgent: navigator.userAgent,         // ← Browser info for debugging
      userId: this.getCurrentUserId()         // ← Who was affected
    };

    // ← Fire and forget -- we don't await this, but also swallow errors
    // ← (to avoid infinite error logging loops)
    this.http.post(this.logEndpoint, { ...report, context }).pipe(
      catchError(loggingError => {
        // ← If logging itself fails, just console.error -- don't throw again
        console.error('Failed to log error to server:', loggingError);
        return EMPTY; // ← Return empty observable to complete without error
      })
    ).subscribe(); // ← Fire and forget subscription
  }

  private getCurrentUserId(): string | undefined {
    // ← In real app: get from auth service or localStorage
    return localStorage.getItem('userId') || undefined;
  }
}
```

**HTTP Error Interceptor (complete version):**

```typescript
// src/app/core/interceptors/error.interceptor.ts

import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, throwError, timer } from 'rxjs';
import { catchError, retry, switchMap } from 'rxjs/operators';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { ErrorDisplayService } from '../services/error-display.service';

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {

  constructor(
    private router: Router,
    private authService: AuthService,
    private errorDisplay: ErrorDisplayService
  ) {}

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    return next.handle(request).pipe(
      // ← Retry transient network errors up to 2 times with exponential backoff
      retry({
        count: 2,
        delay: (error: HttpErrorResponse, retryCount: number) => {
          // ← Only retry on network errors or 5xx server errors, not 4xx client errors
          if (error.status === 0 || (error.status >= 500 && error.status < 600)) {
            const delayMs = Math.pow(2, retryCount) * 1000; // ← 1s, 2s, 4s
            return timer(delayMs); // ← Wait before retrying
          }
          return throwError(() => error); // ← Don't retry 4xx errors
        }
      }),

      catchError((error: HttpErrorResponse) => {
        this.handleHttpError(error);
        return throwError(() => this.createUserFriendlyError(error)); // ← Always re-throw
      })
    );
  }

  private handleHttpError(error: HttpErrorResponse): void {
    switch (error.status) {
      case 401:
        // ← Unauthorized: token expired or invalid -- force login
        this.authService.logout();
        this.router.navigate(['/login'], {
          queryParams: { reason: 'session-expired' }
        });
        break;

      case 403:
        // ← Forbidden: logged in but no permission
        this.router.navigate(['/access-denied']);
        break;

      case 404:
        // ← Not Found: don't navigate, let the caller handle the error display
        break;

      case 503:
        // ← Service Unavailable: show maintenance message
        this.errorDisplay.showError('Service temporarily unavailable. Please try again in a few minutes.');
        break;

      default:
        if (error.status >= 500) {
          this.errorDisplay.showError('A server error occurred. Our team has been notified.');
        }
    }
  }

  private createUserFriendlyError(error: HttpErrorResponse): Error {
    // ← Transform HTTP error to a human-readable Error object
    const messages: Record<number, string> = {
      400: 'Invalid request. Please check your input.',
      401: 'Your session has expired. Please log in again.',
      403: 'You do not have permission to perform this action.',
      404: 'The requested resource was not found.',
      409: 'A conflict occurred. Please refresh and try again.',
      422: 'The data provided is invalid.',
      429: 'Too many requests. Please wait a moment and try again.',
      503: 'Service temporarily unavailable.',
    };

    const message = messages[error.status]
      || (error.status === 0 ? 'Network error. Check your internet connection.' : 'An unexpected error occurred.');

    return new Error(message);
  }
}
```

**Register the global handler and interceptor:**

```typescript
// src/app/app.module.ts

import { ErrorHandler, NgModule } from '@angular/core';
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { GlobalErrorHandler } from './core/handlers/global-error.handler';
import { ErrorInterceptor } from './core/interceptors/error.interceptor';

@NgModule({
  providers: [
    {
      provide: ErrorHandler,          // ← Override Angular's default error handler
      useClass: GlobalErrorHandler    // ← With our custom one
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,
      multi: true                     // ← multi: true because other interceptors exist too
    }
  ]
})
export class AppModule {}
```

---

## 20.13 Practical Example -- Enterprise Application Architecture

### Folder Structure for a Large-Scale Angular App

```
src/
├── app/
│   │
│   ├── core/                          ← Singleton services (loaded once in AppModule)
│   │   ├── guards/
│   │   │   ├── auth.guard.ts
│   │   │   └── permission.guard.ts
│   │   ├── handlers/
│   │   │   └── global-error.handler.ts
│   │   ├── interceptors/
│   │   │   ├── auth.interceptor.ts    ← Adds Authorization header
│   │   │   └── error.interceptor.ts  ← Handles HTTP errors
│   │   ├── models/                    ← App-wide domain models
│   │   │   ├── user.model.ts
│   │   │   └── api-response.model.ts
│   │   ├── api-models/               ← Raw API response shapes (snake_case)
│   │   │   └── user-api.model.ts
│   │   ├── adapters/                 ← API to Domain model adapters
│   │   │   └── user.adapter.ts
│   │   ├── repositories/             ← Data access layer
│   │   │   ├── user.repository.ts
│   │   │   └── product.repository.ts
│   │   ├── services/                 ← Core singleton services
│   │   │   ├── auth.service.ts
│   │   │   ├── error-logging.service.ts
│   │   │   └── error-display.service.ts
│   │   ├── tokens/                   ← InjectionTokens
│   │   │   └── app-config.token.ts
│   │   └── core.module.ts            ← Imports into AppModule ONLY (not feature modules)
│   │
│   ├── shared/                        ← Shared, reusable components/directives/pipes
│   │   ├── components/
│   │   │   ├── card/
│   │   │   │   └── card.component.ts  ← Reusable card with slots
│   │   │   ├── spinner/
│   │   │   │   └── spinner.component.ts
│   │   │   └── data-table/
│   │   │       └── data-table.component.ts
│   │   ├── directives/
│   │   │   ├── repeat.directive.ts
│   │   │   └── permission.directive.ts
│   │   ├── pipes/
│   │   │   └── safe-html.pipe.ts
│   │   └── shared.module.ts          ← Imported by every feature module that needs shared components
│   │
│   └── features/                      ← Feature modules (one per domain area)
│       │
│       ├── products/                  ← Products feature module
│       │   ├── containers/            ← Smart components (own data)
│       │   │   └── product-list.container.ts
│       │   ├── components/            ← Dumb components (pure display)
│       │   │   ├── product-card.component.ts
│       │   │   └── product-card-list.component.ts
│       │   ├── facades/               ← Facade services for the feature
│       │   │   └── product.facade.ts
│       │   ├── models/                ← Feature-specific models
│       │   │   └── product.model.ts
│       │   ├── services/              ← Feature-specific services
│       │   │   └── product.service.ts
│       │   └── products.module.ts
│       │
│       └── dashboard/                 ← Dashboard feature module
│           ├── containers/
│           │   └── dynamic-dashboard.container.ts
│           ├── facades/
│           │   └── dashboard.facade.ts
│           ├── widgets/
│           │   ├── chart-widget.component.ts
│           │   └── stats-widget.component.ts
│           └── dashboard.module.ts
│
├── environments/
│   ├── environment.ts                 ← Development config
│   └── environment.prod.ts            ← Production config
└── main.ts
```

### The CoreModule -- Import Once Pattern

```typescript
// src/app/core/core.module.ts

import { NgModule, Optional, SkipSelf } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { ErrorHandler } from '@angular/core';
import { GlobalErrorHandler } from './handlers/global-error.handler';
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { ErrorInterceptor } from './interceptors/error.interceptor';

@NgModule({
  imports: [CommonModule, HttpClientModule],
  providers: [
    { provide: ErrorHandler, useClass: GlobalErrorHandler },
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true }
  ]
})
export class CoreModule {

  // ← This constructor pattern prevents CoreModule from being imported into feature modules
  // ← If someone accidentally imports CoreModule into a feature module,
  // ← Angular will throw an error at startup -- a guard rail for architecture
  constructor(
    @Optional() @SkipSelf() existingModule: CoreModule // ← @SkipSelf: look in PARENT injector
  ) {
    if (existingModule) {
      // ← If CoreModule already exists in the parent (AppModule), throw
      throw new Error('CoreModule is already loaded. Import it only in AppModule.');
    }
    // ← If null (not already loaded), allow this import (it's the first time)
  }
}
```

### Putting It All Together -- Products Feature Module

```typescript
// src/app/features/products/products.module.ts

import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';
import { SharedModule } from '../../shared/shared.module';

// ← Import all components in this feature
import { ProductListContainerComponent } from './containers/product-list.container';
import { ProductCardListComponent } from './components/product-card-list.component';
import { ProductCardComponent } from './components/product-card.component';
import { ProductFacade } from './facades/product.facade';
import { ProductRepository } from '../../core/repositories/product.repository';

const routes: Routes = [
  { path: '', component: ProductListContainerComponent } // ← Feature entry point
];

@NgModule({
  declarations: [
    ProductListContainerComponent, // ← Smart container
    ProductCardListComponent,      // ← Dumb list
    ProductCardComponent           // ← Dumb card (leaf)
  ],
  imports: [
    CommonModule,                  // ← ngFor, ngIf, async pipe
    SharedModule,                  // ← Shared UI components
    RouterModule.forChild(routes)  // ← Feature routing
  ],
  providers: [
    ProductFacade, // ← Feature-scoped (not root) -- each instance of this module gets its own
    // ProductRepository is provided in CoreModule (singleton)
  ]
})
export class ProductsModule {}
```

### The Complete Data Flow in the Enterprise Architecture

```
User clicks "View Products"
        │
        ↓
  Router activates ProductListContainerComponent (Smart)
        │
        │ calls
        ↓
  ProductFacade.loadProducts()     ← Facade orchestrates
        │
        │ calls
        ↓
  ProductRepository.getAll()       ← Repository handles caching + HTTP
        │
        │ checks cache
        ├── Cache HIT → of(cachedProducts)
        └── Cache MISS → HttpClient.get('/api/products')
                │
                │ raw response passes through
                ↓
          ProductAdapter.adaptArray(rawProducts) ← Adapter transforms shape
                │
                ↓
          Observable<Product[]>    ← Clean domain models returned up
        │
        │ products$ arrives back at
        ↓
  ProductListContainerComponent
        │
        │ passes via @Input
        ↓
  ProductCardListComponent (Dumb) ← Receives [products]
        │
        │ passes via @Input
        ↓
  ProductCardComponent (Dumb)     ← Renders each card
        │
        │ user clicks "Add to Cart"
        │ @Output addToCart.emit(product)
        ↓
  ProductCardListComponent        ← Bubbles up the event
        │
        │ @Output addToCart.emit(product)
        ↓
  ProductListContainerComponent   ← Handles event
        │
        │ calls
        ↓
  ProductFacade.addToCart(product) ← Facade knows what to do
```

---

## 20.14 Summary

This phase covered the architectural foundations that separate maintainable enterprise Angular applications from fragile ones. Here is a condensed reference:

### Pattern Reference Table

| Pattern | Problem It Solves | Key Angular API |
|---|---|---|
| **Smart/Dumb Components** | Mixed display + data concerns | `@Input`, `@Output`, `ChangeDetectionStrategy.OnPush` |
| **Facade** | Component coupled to many services | Custom `@Injectable` service |
| **Repository** | Scattered data access, no caching | Custom `@Injectable` wrapping `HttpClient` |
| **Adapter** | API shape mismatch with frontend model | Transform service using `map()` operator |
| **Dynamic Loading** | Unknown components at compile time | `ViewContainerRef.createComponent()` |
| **InjectionToken** | Injecting non-class values | `InjectionToken<T>` |
| **Multi-Provider** | Multiple implementations of one interface | `multi: true` in provider config |
| **Custom Structural Directive** | Reusable template control flow | `TemplateRef`, `ViewContainerRef` |
| **Global Error Handler** | Inconsistent, scattered error handling | `ErrorHandler` class override |
| **CoreModule guard** | CoreModule imported multiple times | `@Optional @SkipSelf()` in constructor |

### Decision Guide: Which Pattern to Use?

```
"My component's constructor has too many injected services"
└── Use FACADE PATTERN -- consolidate behind one service

"I need to reuse a component with different data in different places"
└── Use SMART/DUMB SPLIT -- make the display component dumb

"My HTTP calls are scattered and caching is inconsistent"
└── Use REPOSITORY PATTERN -- centralize data access

"The API returns snake_case and it's polluting my entire codebase"
└── Use ADAPTER PATTERN -- transform at the data access boundary

"I need to render components that aren't known at compile time"
└── Use DYNAMIC COMPONENT LOADING with ViewContainerRef

"I need to inject a configuration object (not a class)"
└── Use INJECTION TOKEN (InjectionToken<T>)

"I need multiple HTTP interceptors or validators registered"
└── Use MULTI-PROVIDERS with multi: true

"I need to show/hide template content based on custom logic"
└── Use CUSTOM STRUCTURAL DIRECTIVE with TemplateRef + ViewContainerRef

"My app has grown to 5+ teams and needs independent deployments"
└── Consider MICRO-FRONTENDS with Module Federation

"My app has 3+ separate Angular applications sharing code"
└── Consider MONO-REPO with Nx
```

### Architecture Principles to Carry Forward

1. **Separate concerns early.** Splitting smart/dumb is 10x cheaper on day 1 than on day 200.
2. **Single responsibility.** Each class does one job: repositories fetch, adapters transform, facades orchestrate, presentational components display.
3. **Depend on abstractions.** Components depend on facades (not services). Facades depend on repositories (not HttpClient directly). The further from HTTP you are, the more stable your code.
4. **Centralize cross-cutting concerns.** Error handling, logging, authentication headers -- these belong in interceptors and global handlers, not scattered across components.
5. **Test at the right level.** Dumb components need no mocking. Facades test service orchestration. Repositories test HTTP and caching. Integration tests cover the assembled flow.
6. **Architecture is a team agreement.** Patterns are only valuable if everyone follows them. Enforce with linting rules (Nx boundaries), code reviews, and documented conventions.

---

> **Next Phase:** [Phase 21: Build, Deploy & DevOps](Phase21-Build-Deploy-DevOps.md)
