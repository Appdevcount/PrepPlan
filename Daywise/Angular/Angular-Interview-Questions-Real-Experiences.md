# Angular Real Interview Questions from Top Companies

Based on real experiences shared by developers who interviewed at FAANG, MAANG, and top service/product companies.

---

## Table of Contents

1. [Signals & Reactive Programming](#signals--reactive-programming)
2. [Standalone Components & Modern APIs](#standalone-components--modern-apis)
3. [RxJS & Observables](#rxjs--observables)
4. [Performance Optimization](#performance-optimization)
5. [Dependency Injection](#dependency-injection)
6. [Change Detection](#change-detection)
7. [Routing & Guards](#routing--guards)
8. [Forms & Validation](#forms--validation)
9. [State Management](#state-management)
10. [Testing](#testing)
11. [Architecture & Best Practices](#architecture--best-practices)

---

## Signals & Reactive Programming

### Q1: Implement a shopping cart with Signals (Asked at: Google, Microsoft)

**Question:** Create a shopping cart that calculates total price, applies discounts, and manages quantity using Angular Signals. The cart should automatically update when items change.

**Implementation:**

```typescript
// cart-item.interface.ts
export interface CartItem {
  id: number;
  name: string;
  price: number;
  quantity: number;
  image: string;
}

// discount.interface.ts
export interface Discount {
  code: string;
  percentage: number;
  minAmount: number;
}

// cart.service.ts
import { Injectable, signal, computed } from '@angular/core';
import { CartItem, Discount } from './interfaces';

@Injectable({
  providedIn: 'root'
})
export class CartService {
  // Signal to store cart items - writable signal
  private cartItemsSignal = signal<CartItem[]>([]);
  
  // Signal for applied discount code
  private discountCodeSignal = signal<string>('');
  
  // Available discounts (in real app, fetch from API)
  private availableDiscounts: Discount[] = [
    { code: 'SAVE10', percentage: 10, minAmount: 100 },
    { code: 'SAVE20', percentage: 20, minAmount: 200 },
    { code: 'SAVE30', percentage: 30, minAmount: 300 }
  ];
  
  // Public readonly signal for components to subscribe
  readonly cartItems = this.cartItemsSignal.asReadonly();
  readonly discountCode = this.discountCodeSignal.asReadonly();
  
  // Computed signal for subtotal (before discount)
  readonly subtotal = computed(() => {
    // Calculate sum of (price * quantity) for all items
    return this.cartItemsSignal().reduce((total, item) => {
      return total + (item.price * item.quantity);
    }, 0);
  });
  
  // Computed signal for total items count
  readonly itemCount = computed(() => {
    // Sum all quantities
    return this.cartItemsSignal().reduce((count, item) => {
      return count + item.quantity;
    }, 0);
  });
  
  // Computed signal for applied discount
  readonly appliedDiscount = computed(() => {
    const code = this.discountCodeSignal();
    if (!code) return null;
    
    // Find matching discount
    const discount = this.availableDiscounts.find(d => d.code === code);
    if (!discount) return null;
    
    // Check if subtotal meets minimum amount
    const subtotal = this.subtotal();
    if (subtotal < discount.minAmount) return null;
    
    return discount;
  });
  
  // Computed signal for discount amount
  readonly discountAmount = computed(() => {
    const discount = this.appliedDiscount();
    if (!discount) return 0;
    
    // Calculate discount amount
    return (this.subtotal() * discount.percentage) / 100;
  });
  
  // Computed signal for final total (after discount)
  readonly total = computed(() => {
    return this.subtotal() - this.discountAmount();
  });
  
  // Computed signal for cart status
  readonly isEmpty = computed(() => {
    return this.cartItemsSignal().length === 0;
  });

  /**
   * Add item to cart or increase quantity if exists
   */
  addItem(item: Omit<CartItem, 'quantity'>): void {
    // Get current cart state
    const currentItems = this.cartItemsSignal();
    
    // Check if item already exists
    const existingItemIndex = currentItems.findIndex(i => i.id === item.id);
    
    if (existingItemIndex !== -1) {
      // Item exists - increase quantity
      const updatedItems = currentItems.map((i, index) => 
        index === existingItemIndex 
          ? { ...i, quantity: i.quantity + 1 }
          : i
      );
      this.cartItemsSignal.set(updatedItems);
    } else {
      // New item - add with quantity 1
      this.cartItemsSignal.set([...currentItems, { ...item, quantity: 1 }]);
    }
  }

  /**
   * Remove item from cart completely
   */
  removeItem(itemId: number): void {
    // Filter out the item with matching id
    const updatedItems = this.cartItemsSignal().filter(item => item.id !== itemId);
    this.cartItemsSignal.set(updatedItems);
  }

  /**
   * Update item quantity
   */
  updateQuantity(itemId: number, quantity: number): void {
    // Ensure quantity is at least 1
    if (quantity < 1) {
      this.removeItem(itemId);
      return;
    }
    
    // Update the specific item's quantity
    const updatedItems = this.cartItemsSignal().map(item =>
      item.id === itemId 
        ? { ...item, quantity }
        : item
    );
    this.cartItemsSignal.set(updatedItems);
  }

  /**
   * Increment item quantity by 1
   */
  incrementQuantity(itemId: number): void {
    const item = this.cartItemsSignal().find(i => i.id === itemId);
    if (item) {
      this.updateQuantity(itemId, item.quantity + 1);
    }
  }

  /**
   * Decrement item quantity by 1
   */
  decrementQuantity(itemId: number): void {
    const item = this.cartItemsSignal().find(i => i.id === itemId);
    if (item) {
      this.updateQuantity(itemId, item.quantity - 1);
    }
  }

  /**
   * Apply discount code
   */
  applyDiscount(code: string): boolean {
    // Find discount
    const discount = this.availableDiscounts.find(d => d.code === code.toUpperCase());
    
    if (!discount) {
      console.error('Invalid discount code');
      return false;
    }
    
    // Check minimum amount
    if (this.subtotal() < discount.minAmount) {
      console.error(`Minimum amount of $${discount.minAmount} required`);
      return false;
    }
    
    // Apply discount
    this.discountCodeSignal.set(code.toUpperCase());
    return true;
  }

  /**
   * Remove applied discount
   */
  removeDiscount(): void {
    this.discountCodeSignal.set('');
  }

  /**
   * Clear entire cart
   */
  clearCart(): void {
    this.cartItemsSignal.set([]);
    this.discountCodeSignal.set('');
  }
}

// cart.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CartService } from './cart.service';

@Component({
  selector: 'app-cart',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="cart-container">
      <h2>Shopping Cart ({{ cartService.itemCount() }} items)</h2>
      
      @if (cartService.isEmpty()) {
        <!-- Empty cart state -->
        <div class="empty-cart">
          <p>Your cart is empty</p>
          <button (click)="addSampleItems()">Add Sample Items</button>
        </div>
      } @else {
        <!-- Cart items list -->
        <div class="cart-items">
          @for (item of cartService.cartItems(); track item.id) {
            <div class="cart-item">
              <img [src]="item.image" [alt]="item.name" />
              
              <div class="item-details">
                <h3>{{ item.name }}</h3>
                <p class="price">\${{ item.price.toFixed(2) }}</p>
              </div>
              
              <div class="quantity-controls">
                <button (click)="cartService.decrementQuantity(item.id)">-</button>
                <input 
                  type="number" 
                  [value]="item.quantity"
                  (change)="onQuantityChange(item.id, $event)"
                  min="1"
                />
                <button (click)="cartService.incrementQuantity(item.id)">+</button>
              </div>
              
              <div class="item-total">
                <p>\${{ (item.price * item.quantity).toFixed(2) }}</p>
              </div>
              
              <button 
                class="remove-btn"
                (click)="cartService.removeItem(item.id)">
                Remove
              </button>
            </div>
          }
        </div>
        
        <!-- Discount code section -->
        <div class="discount-section">
          <input 
            type="text" 
            [(ngModel)]="discountInput"
            placeholder="Enter discount code"
            [disabled]="!!cartService.discountCode()"
          />
          
          @if (cartService.discountCode()) {
            <!-- Discount applied -->
            <button (click)="cartService.removeDiscount()">
              Remove {{ cartService.discountCode() }}
            </button>
          } @else {
            <!-- Apply discount button -->
            <button (click)="applyDiscount()">Apply</button>
          }
        </div>
        
        <!-- Cart summary -->
        <div class="cart-summary">
          <div class="summary-row">
            <span>Subtotal:</span>
            <span>\${{ cartService.subtotal().toFixed(2) }}</span>
          </div>
          
          @if (cartService.appliedDiscount(); as discount) {
            <div class="summary-row discount">
              <span>Discount ({{ discount.code }} - {{ discount.percentage }}%):</span>
              <span>-\${{ cartService.discountAmount().toFixed(2) }}</span>
            </div>
          }
          
          <div class="summary-row total">
            <span>Total:</span>
            <span>\${{ cartService.total().toFixed(2) }}</span>
          </div>
          
          <button class="checkout-btn" (click)="checkout()">
            Proceed to Checkout
          </button>
          
          <button class="clear-btn" (click)="cartService.clearCart()">
            Clear Cart
          </button>
        </div>
      }
    </div>
  `,
  styles: [`
    .cart-container {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .empty-cart {
      text-align: center;
      padding: 40px;
    }
    .cart-item {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px;
      border: 1px solid #ddd;
      margin-bottom: 12px;
      border-radius: 8px;
    }
    .cart-item img {
      width: 80px;
      height: 80px;
      object-fit: cover;
      border-radius: 4px;
    }
    .item-details {
      flex: 1;
    }
    .quantity-controls {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .quantity-controls input {
      width: 60px;
      text-align: center;
    }
    .discount-section {
      display: flex;
      gap: 8px;
      margin: 20px 0;
    }
    .discount-section input {
      flex: 1;
      padding: 8px;
    }
    .cart-summary {
      border-top: 2px solid #ddd;
      padding-top: 16px;
      margin-top: 16px;
    }
    .summary-row {
      display: flex;
      justify-content: space-between;
      margin: 8px 0;
    }
    .summary-row.discount {
      color: green;
    }
    .summary-row.total {
      font-size: 1.5em;
      font-weight: bold;
      margin-top: 16px;
    }
    .checkout-btn {
      width: 100%;
      padding: 12px;
      background: #4caf50;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 1.1em;
      cursor: pointer;
      margin-top: 16px;
    }
    .clear-btn {
      width: 100%;
      padding: 12px;
      background: #f44336;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      margin-top: 8px;
    }
  `]
})
export class CartComponent {
  // Inject cart service
  cartService = inject(CartService);
  
  // Input for discount code
  discountInput = '';

  /**
   * Handle quantity input change
   */
  onQuantityChange(itemId: number, event: Event): void {
    const input = event.target as HTMLInputElement;
    const quantity = parseInt(input.value, 10);
    
    if (!isNaN(quantity)) {
      this.cartService.updateQuantity(itemId, quantity);
    }
  }

  /**
   * Apply discount code
   */
  applyDiscount(): void {
    if (this.discountInput.trim()) {
      const success = this.cartService.applyDiscount(this.discountInput);
      
      if (success) {
        this.discountInput = '';
        alert('Discount applied successfully!');
      } else {
        alert('Invalid discount code or minimum amount not met');
      }
    }
  }

  /**
   * Proceed to checkout
   */
  checkout(): void {
    const total = this.cartService.total();
    alert(`Proceeding to checkout. Total: $${total.toFixed(2)}`);
    // Navigate to checkout page
  }

  /**
   * Add sample items for demo
   */
  addSampleItems(): void {
    this.cartService.addItem({
      id: 1,
      name: 'Laptop',
      price: 999.99,
      image: 'https://via.placeholder.com/80'
    });
    
    this.cartService.addItem({
      id: 2,
      name: 'Mouse',
      price: 29.99,
      image: 'https://via.placeholder.com/80'
    });
    
    this.cartService.addItem({
      id: 3,
      name: 'Keyboard',
      price: 79.99,
      image: 'https://via.placeholder.com/80'
    });
  }
}
```

**Key Points Tested:**
- Understanding of Signals (writable, readonly, computed)
- Reactive state management without RxJS
- Automatic dependency tracking
- Performance optimization with computed signals
- Real-world e-commerce scenario

---

### Q2: Implement a debounced search with Signals (Asked at: Amazon, Meta)

**Question:** Create a search component that debounces user input using Signals and RxJS interop. Show loading state and handle errors.

**Implementation:**

```typescript
// search.service.ts
import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, catchError, of, delay } from 'rxjs';

export interface SearchResult {
  id: number;
  title: string;
  description: string;
}

@Injectable({
  providedIn: 'root'
})
export class SearchService {
  private http = inject(HttpClient);

  /**
   * Simulate API search with delay
   */
  search(query: string): Observable<SearchResult[]> {
    // Simulate network delay
    return of([
      { id: 1, title: `Result for "${query}" #1`, description: 'Description 1' },
      { id: 2, title: `Result for "${query}" #2`, description: 'Description 2' },
      { id: 3, title: `Result for "${query}" #3`, description: 'Description 3' }
    ]).pipe(
      delay(500), // Simulate API latency
      catchError(error => {
        console.error('Search error:', error);
        return of([]);
      })
    );
  }
}

// search.component.ts
import { Component, inject, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subject, debounceTime, distinctUntilChanged, switchMap, tap } from 'rxjs';
import { toObservable, toSignal } from '@angular/core/rxjs-interop';
import { SearchService, SearchResult } from './search.service';

@Component({
  selector: 'app-search',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="search-container">
      <h2>Search Products</h2>
      
      <!-- Search input -->
      <div class="search-box">
        <input
          type="text"
          [(ngModel)]="searchQuery"
          (ngModelChange)="onSearchChange($event)"
          placeholder="Search..."
          class="search-input"
        />
        
        @if (isLoading()) {
          <span class="loading-spinner">⟳</span>
        }
      </div>
      
      <!-- Search stats -->
      <div class="search-stats">
        @if (searchQuery) {
          <p>
            Searching for: "{{ searchQuery }}"
            @if (!isLoading() && results()) {
              - Found {{ results()!.length }} results
            }
          </p>
        }
      </div>
      
      <!-- Results -->
      @if (isLoading()) {
        <div class="loading">Loading...</div>
      } @else if (error()) {
        <div class="error">
          Error: {{ error() }}
          <button (click)="retry()">Retry</button>
        </div>
      } @else if (results(); as resultList) {
        @if (resultList.length === 0 && searchQuery) {
          <div class="no-results">
            No results found for "{{ searchQuery }}"
          </div>
        } @else if (resultList.length > 0) {
          <div class="results-list">
            @for (result of resultList; track result.id) {
              <div class="result-item">
                <h3>{{ result.title }}</h3>
                <p>{{ result.description }}</p>
              </div>
            }
          </div>
        }
      }
    </div>
  `,
  styles: [`
    .search-container {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .search-box {
      position: relative;
      margin-bottom: 20px;
    }
    .search-input {
      width: 100%;
      padding: 12px;
      font-size: 16px;
      border: 2px solid #ddd;
      border-radius: 4px;
    }
    .loading-spinner {
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      from { transform: translateY(-50%) rotate(0deg); }
      to { transform: translateY(-50%) rotate(360deg); }
    }
    .search-stats {
      color: #666;
      margin-bottom: 16px;
    }
    .results-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .result-item {
      padding: 16px;
      border: 1px solid #ddd;
      border-radius: 4px;
      background: #f9f9f9;
    }
    .result-item h3 {
      margin: 0 0 8px 0;
      color: #2196f3;
    }
    .loading, .error, .no-results {
      text-align: center;
      padding: 20px;
      color: #666;
    }
    .error {
      color: #f44336;
    }
  `]
})
export class SearchComponent {
  private searchService = inject(SearchService);
  
  // Signal for search query input
  searchQuery = '';
  
  // Subject to emit search queries
  private searchSubject = new Subject<string>();
  
  // Signal for loading state
  isLoading = signal(false);
  
  // Signal for error state
  error = signal<string | null>(null);
  
  // Convert search subject to observable with debounce and API call
  private search$ = this.searchSubject.pipe(
    // Wait 300ms after user stops typing
    debounceTime(300),
    
    // Only emit if value changed
    distinctUntilChanged(),
    
    // Set loading state
    tap(() => {
      this.isLoading.set(true);
      this.error.set(null);
    }),
    
    // Cancel previous request and start new one
    switchMap(query => {
      // Don't search for empty queries
      if (!query.trim()) {
        this.isLoading.set(false);
        return of([]);
      }
      
      // Call search API
      return this.searchService.search(query).pipe(
        tap(() => this.isLoading.set(false)),
        catchError(err => {
          this.isLoading.set(false);
          this.error.set('Failed to fetch results');
          return of([]);
        })
      );
    })
  );
  
  // Convert observable to signal for template
  results = toSignal(this.search$, { initialValue: [] });
  
  // Effect to log search activity
  constructor() {
    effect(() => {
      const query = this.searchQuery;
      const resultCount = this.results()?.length || 0;
      
      if (query) {
        console.log(`Search for "${query}" returned ${resultCount} results`);
      }
    });
  }

  /**
   * Handle search input change
   */
  onSearchChange(query: string): void {
    // Emit query to subject (will be debounced)
    this.searchSubject.next(query);
  }

  /**
   * Retry failed search
   */
  retry(): void {
    if (this.searchQuery) {
      this.searchSubject.next(this.searchQuery);
    }
  }
}
```

**Key Points Tested:**
- Signals + RxJS interop (toSignal, toObservable)
- Debouncing user input
- Loading and error states
- switchMap to cancel previous requests
- Effect for side effects

---

## Standalone Components & Modern APIs

### Q3: Convert NgModule-based app to Standalone (Asked at: Microsoft, Thoughtworks)

**Question:** You have an NgModule-based application. Migrate it to use standalone components with the new routing APIs.

**Implementation:**

```typescript
// BEFORE: Module-based approach

// app.module.ts (OLD)
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { SharedModule } from './shared/shared.module';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    AppRoutingModule,
    SharedModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }

// app-routing.module.ts (OLD)
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { 
    path: 'users', 
    loadChildren: () => import('./users/users.module').then(m => m.UsersModule)
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }

// ============================================
// AFTER: Standalone approach

// main.ts (NEW)
import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { AppComponent } from './app/app.component';
import { routes } from './app/app.routes';
import { authInterceptor } from './app/interceptors/auth.interceptor';

// Bootstrap standalone application
bootstrapApplication(AppComponent, {
  providers: [
    // Provide router with routes
    provideRouter(routes),
    
    // Provide HTTP client with interceptors
    provideHttpClient(
      withInterceptors([authInterceptor])
    ),
    
    // Other providers
    // provideAnimations(),
    // provideStore(reducers),
  ]
}).catch(err => console.error(err));

// app.component.ts (NEW - Standalone)
import { Component } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true, // Mark as standalone
  imports: [
    CommonModule,
    RouterOutlet,
    RouterLink
  ],
  template: `
    <header>
      <nav>
        <a routerLink="/">Home</a>
        <a routerLink="/users">Users</a>
        <a routerLink="/products">Products</a>
      </nav>
    </header>
    
    <main>
      <!-- Router outlet for lazy-loaded routes -->
      <router-outlet></router-outlet>
    </main>
  `,
  styles: [`
    header {
      background: #2196f3;
      padding: 16px;
    }
    nav {
      display: flex;
      gap: 16px;
    }
    nav a {
      color: white;
      text-decoration: none;
    }
  `]
})
export class AppComponent {
  title = 'Standalone App';
}

// app.routes.ts (NEW - Route configuration)
import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./home/home.component').then(m => m.HomeComponent)
  },
  {
    path: 'users',
    loadChildren: () => import('./users/user.routes').then(m => m.USER_ROUTES),
    canActivate: [authGuard]
  },
  {
    path: 'products',
    loadChildren: () => import('./products/product.routes').then(m => m.PRODUCT_ROUTES)
  },
  {
    path: '**',
    loadComponent: () => import('./not-found/not-found.component').then(m => m.NotFoundComponent)
  }
];

// home.component.ts (NEW - Standalone)
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="home">
      <h1>Welcome Home</h1>
      <p>This is a standalone component</p>
    </div>
  `
})
export class HomeComponent {}

// users/user.routes.ts (NEW - Child routes)
import { Routes } from '@angular/router';

export const USER_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./user-list/user-list.component').then(m => m.UserListComponent)
  },
  {
    path: ':id',
    loadComponent: () => import('./user-detail/user-detail.component').then(m => m.UserDetailComponent)
  }
];

// users/user-list/user-list.component.ts (NEW - Standalone)
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { UserService } from '../user.service';

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <div class="user-list">
      <h2>Users</h2>
      
      @for (user of users(); track user.id) {
        <div class="user-card">
          <h3>{{ user.name }}</h3>
          <a [routerLink]="['/users', user.id]">View Details</a>
        </div>
      }
    </div>
  `,
  styles: [`
    .user-list {
      padding: 20px;
    }
    .user-card {
      border: 1px solid #ddd;
      padding: 16px;
      margin: 8px 0;
      border-radius: 4px;
    }
  `]
})
export class UserListComponent {
  private userService = inject(UserService);
  
  // Using signals
  users = this.userService.users;
}

// guards/auth.guard.ts (NEW - Functional guard)
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  // Check if user is authenticated
  if (authService.isAuthenticated()) {
    return true;
  }
  
  // Redirect to login
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url }
  });
};

// interceptors/auth.interceptor.ts (NEW - Functional interceptor)
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();
  
  // Clone request and add authorization header
  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }
  
  return next(req);
};
```

**Migration Checklist:**
1. ✅ Remove `@NgModule` decorators
2. ✅ Add `standalone: true` to components
3. ✅ Import dependencies directly in components
4. ✅ Convert guards to functional guards
5. ✅ Convert interceptors to functional interceptors
6. ✅ Use `provideRouter` instead of `RouterModule.forRoot`
7. ✅ Use `loadComponent` instead of `loadChildren` with modules
8. ✅ Use `inject()` function instead of constructor injection

---

## RxJS & Observables

### Q4: Implement an auto-save feature with RxJS (Asked at: Google, Netflix)

**Question:** Create a form that auto-saves data to an API after user stops typing, with debounce, retry logic, and conflict resolution.

**Implementation:**

```typescript
// auto-save-form.component.ts
import { Component, inject, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { 
  Subject, 
  merge,
  of,
  throwError,
  fromEvent
} from 'rxjs';
import {
  debounceTime,
  distinctUntilChanged,
  switchMap,
  catchError,
  retry,
  tap,
  takeUntil,
  filter,
  map
} from 'rxjs/operators';

interface DocumentData {
  id: string;
  title: string;
  content: string;
  lastModified: Date;
  version: number;
}

interface SaveResponse {
  success: boolean;
  version: number;
  timestamp: Date;
}

@Component({
  selector: 'app-auto-save-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="editor-container">
      <div class="editor-header">
        <h2>Document Editor</h2>
        
        <!-- Save status indicator -->
        <div class="save-status">
          @if (saveStatus === 'saving') {
            <span class="status saving">💾 Saving...</span>
          } @else if (saveStatus === 'saved') {
            <span class="status saved">✓ Saved</span>
          } @else if (saveStatus === 'error') {
            <span class="status error">⚠ Save failed</span>
          } @else if (saveStatus === 'conflict') {
            <span class="status conflict">⚠ Conflict detected</span>
          }
          
          @if (lastSaved) {
            <small>Last saved: {{ lastSaved | date:'short' }}</small>
          }
        </div>
      </div>
      
      <form [formGroup]="documentForm" class="editor-form">
        <!-- Title input -->
        <div class="form-group">
          <label>Title</label>
          <input 
            formControlName="title"
            type="text"
            placeholder="Document title"
            class="title-input"
          />
        </div>
        
        <!-- Content textarea -->
        <div class="form-group">
          <label>Content</label>
          <textarea
            formControlName="content"
            rows="15"
            placeholder="Start typing..."
            class="content-input"
          ></textarea>
        </div>
        
        <!-- Manual save button -->
        <button 
          type="button"
          (click)="manualSave()"
          [disabled]="!documentForm.dirty || saveStatus === 'saving'"
          class="save-button">
          Save Now
        </button>
      </form>
      
      <!-- Conflict resolution modal -->
      @if (conflictData) {
        <div class="conflict-modal">
          <div class="modal-content">
            <h3>Conflict Detected</h3>
            <p>The document was modified by another user. Choose a version:</p>
            
            <div class="conflict-options">
              <div class="version-card">
                <h4>Your Version</h4>
                <p><strong>Title:</strong> {{ documentForm.value.title }}</p>
                <p><strong>Content:</strong> {{ documentForm.value.content }}</p>
                <button (click)="resolveConflict('local')">Use My Version</button>
              </div>
              
              <div class="version-card">
                <h4>Server Version</h4>
                <p><strong>Title:</strong> {{ conflictData.title }}</p>
                <p><strong>Content:</strong> {{ conflictData.content }}</p>
                <button (click)="resolveConflict('server')">Use Server Version</button>
              </div>
            </div>
          </div>
        </div>
      }
    </div>
  `,
  styles: [`
    .editor-container {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .editor-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }
    .save-status {
      text-align: right;
    }
    .status {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 14px;
    }
    .status.saving { background: #ffc107; }
    .status.saved { background: #4caf50; color: white; }
    .status.error { background: #f44336; color: white; }
    .status.conflict { background: #ff9800; color: white; }
    .editor-form {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .form-group {
      display: flex;
      flex-direction: column;
    }
    .title-input, .content-input {
      padding: 12px;
      font-size: 16px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .title-input {
      font-size: 24px;
      font-weight: bold;
    }
    .save-button {
      padding: 12px 24px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
    }
    .save-button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    .conflict-modal {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
    }
    .modal-content {
      background: white;
      padding: 24px;
      border-radius: 8px;
      max-width: 600px;
      width: 90%;
    }
    .conflict-options {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
      margin-top: 16px;
    }
    .version-card {
      border: 1px solid #ddd;
      padding: 16px;
      border-radius: 4px;
    }
  `]
})
export class AutoSaveFormComponent implements OnInit, OnDestroy {
  private fb = inject(FormBuilder);
  private http = inject(HttpClient);
  
  // Form group
  documentForm: FormGroup;
  
  // Document metadata
  private documentId = 'doc-123';
  private currentVersion = 1;
  
  // Save status
  saveStatus: 'idle' | 'saving' | 'saved' | 'error' | 'conflict' = 'idle';
  lastSaved: Date | null = null;
  
  // Conflict resolution
  conflictData: DocumentData | null = null;
  
  // Subject to trigger manual saves
  private manualSave$ = new Subject<void>();
  
  // Subject for component cleanup
  private destroy$ = new Subject<void>();
  
  constructor() {
    // Initialize form
    this.documentForm = this.fb.group({
      title: ['', Validators.required],
      content: ['', Validators.required]
    });
  }

  ngOnInit(): void {
    // Load initial data
    this.loadDocument();
    
    // Setup auto-save
    this.setupAutoSave();
    
    // Setup beforeunload handler
    this.setupBeforeUnload();
  }

  ngOnDestroy(): void {
    // Clean up subscriptions
    this.destroy$.next();
    this.destroy$.complete();
  }

  /**
   * Load document from server
   */
  private loadDocument(): void {
    this.http.get<DocumentData>(`/api/documents/${this.documentId}`)
      .pipe(
        catchError(error => {
          console.error('Failed to load document:', error);
          return of(null);
        })
      )
      .subscribe(data => {
        if (data) {
          this.documentForm.patchValue({
            title: data.title,
            content: data.content
          });
          this.currentVersion = data.version;
          this.documentForm.markAsPristine();
        }
      });
  }

  /**
   * Setup auto-save with debounce
   */
  private setupAutoSave(): void {
    // Create observable from form value changes
    const formChange$ = this.documentForm.valueChanges.pipe(
      // Only proceed if form is valid
      filter(() => this.documentForm.valid),
      
      // Wait 2 seconds after user stops typing
      debounceTime(2000),
      
      // Only emit if value actually changed
      distinctUntilChanged((prev, curr) => 
        JSON.stringify(prev) === JSON.stringify(curr)
      ),
      
      // Map to save action
      map(() => this.documentForm.value)
    );
    
    // Merge auto-save and manual save streams
    merge(
      formChange$,
      this.manualSave$.pipe(map(() => this.documentForm.value))
    ).pipe(
      // Set saving status
      tap(() => {
        this.saveStatus = 'saving';
      }),
      
      // Switch to save API call (cancels previous request)
      switchMap(formValue => 
        this.saveDocument(formValue).pipe(
          // Retry failed requests up to 3 times
          retry({
            count: 3,
            delay: 1000 // Wait 1 second between retries
          }),
          
          // Handle errors
          catchError(error => {
            console.error('Auto-save failed:', error);
            
            // Check for conflict (409 status)
            if (error.status === 409) {
              this.handleConflict(error.error);
              return of({ success: false, conflict: true });
            }
            
            this.saveStatus = 'error';
            return of({ success: false });
          })
        )
      ),
      
      // Take until component destroyed
      takeUntil(this.destroy$)
    ).subscribe(response => {
      if (response.success) {
        // Update success status
        this.saveStatus = 'saved';
        this.lastSaved = new Date();
        this.currentVersion = response.version;
        this.documentForm.markAsPristine();
        
        // Reset status after 3 seconds
        setTimeout(() => {
          if (this.saveStatus === 'saved') {
            this.saveStatus = 'idle';
          }
        }, 3000);
      }
    });
  }

  /**
   * Save document to server
   */
  private saveDocument(data: any) {
    return this.http.put<SaveResponse>(
      `/api/documents/${this.documentId}`,
      {
        ...data,
        version: this.currentVersion
      }
    );
  }

  /**
   * Handle version conflict
   */
  private handleConflict(serverData: DocumentData): void {
    this.saveStatus = 'conflict';
    this.conflictData = serverData;
  }

  /**
   * Resolve conflict by choosing a version
   */
  resolveConflict(choice: 'local' | 'server'): void {
    if (choice === 'server' && this.conflictData) {
      // Use server version
      this.documentForm.patchValue({
        title: this.conflictData.title,
        content: this.conflictData.content
      });
      this.currentVersion = this.conflictData.version;
    } else {
      // Use local version - force save
      this.currentVersion = this.conflictData!.version;
      this.manualSave();
    }
    
    this.conflictData = null;
    this.saveStatus = 'idle';
  }

  /**
   * Trigger manual save
   */
  manualSave(): void {
    if (this.documentForm.valid && this.documentForm.dirty) {
      this.manualSave$.next();
    }
  }

  /**
   * Setup beforeunload handler to warn about unsaved changes
   */
  private setupBeforeUnload(): void {
    fromEvent(window, 'beforeunload').pipe(
      // Only show warning if form is dirty
      filter(() => this.documentForm.dirty),
      takeUntil(this.destroy$)
    ).subscribe((event: any) => {
      event.preventDefault();
      event.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
    });
  }
}
```

**Key RxJS Concepts Tested:**
- debounceTime for user input
- distinctUntilChanged to avoid duplicate saves
- switchMap to cancel previous requests
- retry with exponential backoff
- merge multiple observables
- takeUntil for cleanup
- Error handling and recovery
- Conflict resolution

---

## Performance Optimization

### Q5: Implement Virtual Scrolling for large lists (Asked at: Amazon, Uber)

**Question:** You need to display 10,000 items in a list. Implement virtual scrolling to render only visible items for optimal performance.

**Implementation:**

```typescript
// virtual-scroll.component.ts
import { Component, signal, computed, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ScrollingModule, CdkVirtualScrollViewport } from '@angular/cdk/scrolling';

interface User {
  id: number;
  name: string;
  email: string;
  avatar: string;
  status: 'online' | 'offline' | 'away';
}

@Component({
  selector: 'app-virtual-scroll',
  standalone: true,
  imports: [CommonModule, ScrollingModule],
  template: `
    <div class="container">
      <div class="header">
        <h2>Users List ({{ totalUsers() }} users)</h2>
        
        <!-- Search and filter -->
        <div class="controls">
          <input
            type="text"
            placeholder="Search users..."
            (input)="onSearch($event)"
            class="search-input"
          />
          
          <select (change)="onFilterChange($event)" class="filter-select">
            <option value="all">All Status</option>
            <option value="online">Online</option>
            <option value="offline">Offline</option>
            <option value="away">Away</option>
          </select>
        </div>
        
        <!-- Stats -->
        <div class="stats">
          <span>Showing: {{ filteredUsers().length }} users</span>
          <span>Rendered: ~{{ renderedCount() }} DOM elements</span>
        </div>
      </div>
      
      <!-- Virtual scroll viewport -->
      <cdk-virtual-scroll-viewport
        [itemSize]="80"
        class="viewport"
        (scrolledIndexChange)="onScrollIndexChange($event)">
        
        <!-- Virtual scroll content -->
        <div
          *cdkVirtualFor="let user of filteredUsers(); trackBy: trackByUserId"
          class="user-item"
          [class.online]="user.status === 'online'"
          [class.offline]="user.status === 'offline'"
          [class.away]="user.status === 'away'">
          
          <img [src]="user.avatar" [alt]="user.name" class="avatar" />
          
          <div class="user-info">
            <h3>{{ user.name }}</h3>
            <p>{{ user.email }}</p>
          </div>
          
          <span class="status-badge">{{ user.status }}</span>
        </div>
      </cdk-virtual-scroll-viewport>
      
      <!-- Scroll to top button -->
      @if (showScrollTop()) {
        <button class="scroll-top-btn" (click)="scrollToTop()">
          ↑ Back to Top
        </button>
      }
    </div>
  `,
  styles: [`
    .container {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    .header {
      margin-bottom: 16px;
    }
    .controls {
      display: flex;
      gap: 12px;
      margin: 12px 0;
    }
    .search-input, .filter-select {
      padding: 8px 12px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
    }
    .search-input {
      flex: 1;
    }
    .stats {
      display: flex;
      gap: 20px;
      color: #666;
      font-size: 14px;
      margin-top: 8px;
    }
    .viewport {
      flex: 1;
      border: 1px solid #ddd;
      border-radius: 8px;
      overflow-y: auto;
    }
    .user-item {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px;
      border-bottom: 1px solid #eee;
      height: 80px;
      box-sizing: border-box;
    }
    .user-item:hover {
      background: #f5f5f5;
    }
    .avatar {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      object-fit: cover;
    }
    .user-info {
      flex: 1;
    }
    .user-info h3 {
      margin: 0 0 4px 0;
      font-size: 16px;
    }
    .user-info p {
      margin: 0;
      color: #666;
      font-size: 14px;
    }
    .status-badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 500;
    }
    .user-item.online .status-badge {
      background: #4caf50;
      color: white;
    }
    .user-item.offline .status-badge {
      background: #9e9e9e;
      color: white;
    }
    .user-item.away .status-badge {
      background: #ff9800;
      color: white;
    }
    .scroll-top-btn {
      position: fixed;
      bottom: 20px;
      right: 20px;
      padding: 12px 20px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 24px;
      cursor: pointer;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
      font-size: 14px;
      font-weight: 500;
    }
  `]
})
export class VirtualScrollComponent {
  // All users data (simulating 10,000 users)
  private allUsers = signal<User[]>(this.generateUsers(10000));
  
  // Search query
  private searchQuery = signal<string>('');
  
  // Filter status
  private filterStatus = signal<string>('all');
  
  // Current scroll index
  private scrollIndex = signal<number>(0);
  
  // Computed: Total users count
  readonly totalUsers = computed(() => this.allUsers().length);
  
  // Computed: Filtered users based on search and status
  readonly filteredUsers = computed(() => {
    const users = this.allUsers();
    const query = this.searchQuery().toLowerCase();
    const status = this.filterStatus();
    
    return users.filter(user => {
      // Filter by search query
      const matchesSearch = !query || 
        user.name.toLowerCase().includes(query) ||
        user.email.toLowerCase().includes(query);
      
      // Filter by status
      const matchesStatus = status === 'all' || user.status === status;
      
      return matchesSearch && matchesStatus;
    });
  });
  
  // Computed: Approximate rendered items (visible + buffer)
  readonly renderedCount = computed(() => {
    // Virtual scroll renders ~10 items visible + 10 buffer
    return Math.min(20, this.filteredUsers().length);
  });
  
  // Computed: Show scroll to top button
  readonly showScrollTop = computed(() => this.scrollIndex() > 10);
  
  // Reference to viewport (set via ViewChild in real implementation)
  private viewport?: CdkVirtualScrollViewport;

  constructor() {
    // Effect to log performance metrics
    effect(() => {
      const filtered = this.filteredUsers().length;
      const rendered = this.renderedCount();
      
      console.log(`Performance: ${filtered} items filtered, only ${rendered} DOM elements rendered`);
      console.log(`Memory saved: ~${((filtered - rendered) / filtered * 100).toFixed(1)}% fewer DOM nodes`);
    });
  }

  /**
   * Generate mock users
   */
  private generateUsers(count: number): User[] {
    const statuses: Array<'online' | 'offline' | 'away'> = ['online', 'offline', 'away'];
    
    return Array.from({ length: count }, (_, i) => ({
      id: i + 1,
      name: `User ${i + 1}`,
      email: `user${i + 1}@example.com`,
      avatar: `https://i.pravatar.cc/150?img=${(i % 70) + 1}`,
      status: statuses[i % 3]
    }));
  }

  /**
   * Track by function for virtual scroll
   * CRITICAL: Prevents re-rendering of items when scrolling
   */
  trackByUserId(index: number, user: User): number {
    return user.id; // Track by unique ID, not index
  }

  /**
   * Handle search input
   */
  onSearch(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.searchQuery.set(input.value);
  }

  /**
   * Handle filter change
   */
  onFilterChange(event: Event): void {
    const select = event.target as HTMLSelectElement;
    this.filterStatus.set(select.value);
  }

  /**
   * Handle scroll index change
   */
  onScrollIndexChange(index: number): void {
    this.scrollIndex.set(index);
  }

  /**
   * Scroll to top
   */
  scrollToTop(): void {
    this.viewport?.scrollToIndex(0, 'smooth');
  }
}
```

**Key Performance Optimizations:**
1. **Virtual Scrolling**: Only renders ~20 DOM elements instead of 10,000
2. **trackBy**: Prevents unnecessary re-renders when scrolling
3. **Computed Signals**: Automatic memoization of filtered results
4. **Item Size**: Fixed height (80px) allows CDK to calculate positions efficiently
5. **OnPush Compatible**: Works with ChangeDetectionStrategy.OnPush

---

### Q6: Implement OnPush change detection optimization (Asked at: Meta, Netflix)

**Question:** Optimize a product list component using OnPush change detection strategy. Handle async data updates properly.

**Implementation:**

```typescript
// product.interface.ts
export interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
  inStock: boolean;
  rating: number;
}

// product.service.ts
import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, interval } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private http = inject(HttpClient);
  
  // Signal for products
  private productsSignal = signal<Product[]>([]);
  
  // Readonly signal for consumers
  readonly products = this.productsSignal.asReadonly();

  /**
   * Load products from API
   */
  loadProducts(): Observable<Product[]> {
    return this.http.get<Product[]>('/api/products');
  }

  /**
   * Update product in signal (immutably)
   */
  updateProduct(id: number, updates: Partial<Product>): void {
    this.productsSignal.update(products => 
      products.map(p => 
        p.id === id ? { ...p, ...updates } : p
      )
    );
  }

  /**
   * Set products (replaces entire array)
   */
  setProducts(products: Product[]): void {
    this.productsSignal.set(products);
  }

  /**
   * Simulate real-time stock updates
   */
  getStockUpdates(): Observable<{ productId: number; inStock: boolean }> {
    return interval(3000).pipe(
      map(() => ({
        productId: Math.floor(Math.random() * 10) + 1,
        inStock: Math.random() > 0.5
      }))
    );
  }
}

// product-card.component.ts
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Product } from './product.interface';

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CommonModule],
  // CRITICAL: OnPush strategy - only checks when:
  // 1. @Input reference changes
  // 2. Event emitted
  // 3. Async pipe emits new value
  // 4. Manual detectChanges() called
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="product-card" [class.out-of-stock]="!product.inStock">
      <div class="product-header">
        <h3>{{ product.name }}</h3>
        <span class="price">\${{ product.price.toFixed(2) }}</span>
      </div>
      
      <div class="product-details">
        <span class="category">{{ product.category }}</span>
        <span class="rating">⭐ {{ product.rating.toFixed(1) }}</span>
      </div>
      
      <div class="product-footer">
        <span class="stock-status" [class.in-stock]="product.inStock">
          {{ product.inStock ? 'In Stock' : 'Out of Stock' }}
        </span>
        
        <button
          (click)="onAddToCart()"
          [disabled]="!product.inStock"
          class="add-to-cart-btn">
          Add to Cart
        </button>
      </div>
      
      <!-- Debug: Show CD checks -->
      <div class="debug-info">
        CD Checks: {{ cdChecks }}
      </div>
    </div>
  `,
  styles: [`
    .product-card {
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 16px;
      background: white;
      transition: transform 0.2s;
    }
    .product-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .product-card.out-of-stock {
      opacity: 0.6;
    }
    .product-header {
      display: flex;
      justify-content: space-between;
      align-items: start;
      margin-bottom: 12px;
    }
    .product-header h3 {
      margin: 0;
      font-size: 18px;
    }
    .price {
      font-size: 20px;
      font-weight: bold;
      color: #2196f3;
    }
    .product-details {
      display: flex;
      justify-content: space-between;
      margin-bottom: 12px;
      font-size: 14px;
      color: #666;
    }
    .product-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .stock-status {
      font-size: 14px;
      color: #f44336;
    }
    .stock-status.in-stock {
      color: #4caf50;
    }
    .add-to-cart-btn {
      padding: 8px 16px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .add-to-cart-btn:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    .debug-info {
      margin-top: 8px;
      font-size: 12px;
      color: #999;
      border-top: 1px solid #eee;
      padding-top: 8px;
    }
  `]
})
export class ProductCardComponent {
  // Input with immutable object reference
  @Input({ required: true }) product!: Product;
  
  // Output event
  @Output() addToCart = new EventEmitter<Product>();
  
  // Track CD checks for debugging
  cdChecks = 0;

  ngDoCheck(): void {
    // Increment counter on each CD check
    this.cdChecks++;
    console.log(`ProductCard ${this.product.id} CD check #${this.cdChecks}`);
  }

  onAddToCart(): void {
    // Emit event (triggers CD check)
    this.addToCart.emit(this.product);
  }
}

// product-list.component.ts
import { Component, inject, OnInit, ChangeDetectionStrategy, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductCardComponent } from './product-card.component';
import { ProductService } from './product.service';
import { Product } from './product.interface';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule, ProductCardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="container">
      <div class="header">
        <h2>Products</h2>
        
        <!-- Manual refresh button -->
        <button (click)="refresh()" class="refresh-btn">
          🔄 Refresh
        </button>
      </div>
      
      <!-- Products grid -->
      <div class="products-grid">
        @for (product of products(); track product.id) {
          <app-product-card
            [product]="product"
            (addToCart)="onAddToCart($event)" />
        }
      </div>
      
      <!-- Cart summary -->
      <div class="cart-summary">
        <h3>Cart ({{ cartItems().length }} items)</h3>
        <p>Total: \${{ cartTotal().toFixed(2) }}</p>
      </div>
    </div>
  `,
  styles: [`
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }
    .refresh-btn {
      padding: 8px 16px;
      background: #4caf50;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .products-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 20px;
      margin-bottom: 20px;
    }
    .cart-summary {
      position: fixed;
      bottom: 20px;
      right: 20px;
      background: white;
      padding: 16px;
      border-radius: 8px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.2);
    }
  `]
})
export class ProductListComponent implements OnInit {
  private productService = inject(ProductService);
  private cdr = inject(ChangeDetectorRef);
  
  // Signals for reactive state
  products = this.productService.products;
  private cartItemsSignal = signal<Product[]>([]);
  readonly cartItems = this.cartItemsSignal.asReadonly();
  
  // Computed cart total
  readonly cartTotal = computed(() => {
    return this.cartItemsSignal().reduce((sum, item) => sum + item.price, 0);
  });

  ngOnInit(): void {
    // Load initial products
    this.loadProducts();
    
    // Subscribe to real-time stock updates
    this.subscribeToStockUpdates();
  }

  /**
   * Load products from API
   */
  private loadProducts(): void {
    this.productService.loadProducts().subscribe(products => {
      // Set products using signal (automatically triggers CD with OnPush)
      this.productService.setProducts(products);
      
      // Not needed with signals:
      // this.cdr.markForCheck();
    });
  }

  /**
   * Subscribe to real-time stock updates
   */
  private subscribeToStockUpdates(): void {
    this.productService.getStockUpdates().subscribe(update => {
      // Update product immutably (creates new reference)
      this.productService.updateProduct(update.productId, {
        inStock: update.inStock
      });
      
      // Signals automatically trigger CD with OnPush
      // No manual cdr.markForCheck() needed!
    });
  }

  /**
   * Handle add to cart
   */
  onAddToCart(product: Product): void {
    // Update cart immutably (creates new array reference)
    this.cartItemsSignal.update(items => [...items, product]);
    
    console.log(`Added ${product.name} to cart`);
  }

  /**
   * Manual refresh
   */
  refresh(): void {
    this.loadProducts();
  }
}
```

**OnPush Optimization Benefits:**
1. **Reduced CD Checks**: Component only checks when inputs change
2. **Immutability**: Always create new object/array references
3. **Signals Integration**: Signals work perfectly with OnPush
4. **Async Pipe**: Automatically marks for check when observable emits
5. **Performance**: 10x faster with large component trees

**Common Pitfalls:**
- ❌ Mutating input objects directly
- ❌ Forgetting to use trackBy in loops
- ❌ Not calling markForCheck() when needed
- ✅ Always create new references for objects/arrays
- ✅ Use signals for automatic reactivity

---

## Dependency Injection

### Q7: Implement hierarchical injectors with InjectionToken (Asked at: Google, Shopify)

**Question:** Create a feature module with its own configuration that doesn't affect other modules. Use InjectionToken and hierarchical DI.

**Implementation:**

```typescript
// config.interface.ts
export interface FeatureConfig {
  apiUrl: string;
  timeout: number;
  retryAttempts: number;
  enableLogging: boolean;
}

// config.token.ts
import { InjectionToken } from '@angular/core';
import { FeatureConfig } from './config.interface';

/**
 * InjectionToken for feature configuration
 * Allows providing configuration at different levels of the injector tree
 */
export const FEATURE_CONFIG = new InjectionToken<FeatureConfig>(
  'feature.config',
  {
    // Default factory at root level
    providedIn: 'root',
    factory: () => ({
      apiUrl: 'https://api.example.com',
      timeout: 5000,
      retryAttempts: 3,
      enableLogging: false
    })
  }
);

/**
 * Optional injection token for feature name
 */
export const FEATURE_NAME = new InjectionToken<string>('feature.name');

// base-api.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, throwError, timer } from 'rxjs';
import { catchError, retry, timeout } from 'rxjs/operators';
import { FEATURE_CONFIG, FEATURE_NAME } from './config.token';

@Injectable()
export class BaseApiService {
  private http = inject(HttpClient);
  private config = inject(FEATURE_CONFIG); // Injects config from current injector level
  private featureName = inject(FEATURE_NAME, { optional: true }); // Optional injection

  constructor() {
    // Log which configuration is being used
    if (this.config.enableLogging) {
      console.log(`[${this.featureName || 'Unknown'}] API Service initialized with config:`, this.config);
    }
  }

  /**
   * Generic GET request with configuration applied
   */
  get<T>(endpoint: string): Observable<T> {
    const url = `${this.config.apiUrl}${endpoint}`;
    
    if (this.config.enableLogging) {
      console.log(`[${this.featureName}] GET ${url}`);
    }
    
    return this.http.get<T>(url).pipe(
      // Apply timeout from config
      timeout(this.config.timeout),
      
      // Retry based on config
      retry({
        count: this.config.retryAttempts,
        delay: (error, retryCount) => {
          if (this.config.enableLogging) {
            console.log(`[${this.featureName}] Retry attempt ${retryCount}`);
          }
          return timer(1000 * retryCount); // Exponential backoff
        }
      }),
      
      // Error handling
      catchError(error => {
        if (this.config.enableLogging) {
          console.error(`[${this.featureName}] Request failed:`, error);
        }
        return throwError(() => error);
      })
    );
  }

  /**
   * Generic POST request
   */
  post<T>(endpoint: string, data: any): Observable<T> {
    const url = `${this.config.apiUrl}${endpoint}`;
    
    if (this.config.enableLogging) {
      console.log(`[${this.featureName}] POST ${url}`, data);
    }
    
    return this.http.post<T>(url, data).pipe(
      timeout(this.config.timeout),
      retry(this.config.retryAttempts),
      catchError(error => {
        if (this.config.enableLogging) {
          console.error(`[${this.featureName}] Request failed:`, error);
        }
        return throwError(() => error);
      })
    );
  }
}

// users/users.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseApiService } from '../base-api.service';
import { FEATURE_CONFIG, FEATURE_NAME } from '../config.token';
import { FeatureConfig } from '../config.interface';

/**
 * Users component with its own configuration
 * This configuration is scoped to this component and its children
 */
@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule],
  providers: [
    // Provide feature-specific configuration
    {
      provide: FEATURE_CONFIG,
      useValue: {
        apiUrl: 'https://users-api.example.com',
        timeout: 3000,
        retryAttempts: 2,
        enableLogging: true
      } as FeatureConfig
    },
    // Provide feature name
    {
      provide: FEATURE_NAME,
      useValue: 'Users Feature'
    },
    // Provide API service (will use configuration from this level)
    BaseApiService
  ],
  template: `
    <div class="users-container">
      <h2>Users Feature</h2>
      <p>Using custom configuration: users-api.example.com</p>
      <p>Timeout: 3000ms | Retries: 2 | Logging: Enabled</p>
      
      <button (click)="loadUsers()">Load Users</button>
      
      @if (users.length > 0) {
        <ul>
          @for (user of users; track user.id) {
            <li>{{ user.name }} - {{ user.email }}</li>
          }
        </ul>
      }
    </div>
  `,
  styles: [`
    .users-container {
      padding: 20px;
      border: 2px solid #2196f3;
      border-radius: 8px;
      margin: 20px;
    }
  `]
})
export class UsersComponent {
  // Inject API service (gets config from this component's injector)
  private apiService = inject(BaseApiService);
  
  users: any[] = [];

  loadUsers(): void {
    this.apiService.get<any[]>('/users').subscribe(
      users => this.users = users
    );
  }
}

// products/products.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BaseApiService } from '../base-api.service';
import { FEATURE_CONFIG, FEATURE_NAME } from '../config.token';
import { FeatureConfig } from '../config.interface';

/**
 * Products component with different configuration
 * This configuration doesn't affect UsersComponent
 */
@Component({
  selector: 'app-products',
  standalone: true,
  imports: [CommonModule],
  providers: [
    // Different configuration for products feature
    {
      provide: FEATURE_CONFIG,
      useValue: {
        apiUrl: 'https://products-api.example.com',
        timeout: 10000,
        retryAttempts: 5,
        enableLogging: false
      } as FeatureConfig
    },
    {
      provide: FEATURE_NAME,
      useValue: 'Products Feature'
    },
    BaseApiService
  ],
  template: `
    <div class="products-container">
      <h2>Products Feature</h2>
      <p>Using custom configuration: products-api.example.com</p>
      <p>Timeout: 10000ms | Retries: 5 | Logging: Disabled</p>
      
      <button (click)="loadProducts()">Load Products</button>
      
      @if (products.length > 0) {
        <ul>
          @for (product of products; track product.id) {
            <li>{{ product.name }} - ${{ product.price }}</li>
          }
        </ul>
      }
    </div>
  `,
  styles: [`
    .products-container {
      padding: 20px;
      border: 2px solid #4caf50;
      border-radius: 8px;
      margin: 20px;
    }
  `]
})
export class ProductsComponent {
  // Inject API service (gets different config from this component's injector)
  private apiService = inject(BaseApiService);
  
  products: any[] = [];

  loadProducts(): void {
    this.apiService.get<any[]>('/products').subscribe(
      products => this.products = products
    );
  }
}

// app.component.ts
import { Component } from '@angular/core';
import { UsersComponent } from './users/users.component';
import { ProductsComponent } from './products/products.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [UsersComponent, ProductsComponent],
  template: `
    <div class="app">
      <h1>Hierarchical Injector Demo</h1>
      
      <!-- Each component has its own injector with different config -->
      <app-users></app-users>
      <app-products></app-products>
    </div>
  `,
  styles: [`
    .app {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
  `]
})
export class AppComponent {}
```

**Key DI Concepts:**
1. **InjectionToken**: Type-safe dependency injection
2. **Hierarchical Injectors**: Each component can have its own providers
3. **Provider Scoping**: Configuration scoped to component tree
4. **Optional Injection**: Use `inject(token, { optional: true })`
5. **Factory Functions**: Default values in token definition

**Injector Tree:**
```
Root Injector (Default Config)
    ├── UsersComponent Injector (Users Config)
    │   └── BaseApiService (uses Users Config)
    └── ProductsComponent Injector (Products Config)
        └── BaseApiService (uses Products Config)
```

---

### Q8: Implement multi-provider pattern for plugins (Asked at: Microsoft, Stripe)

**Question:** Create a plugin system where multiple implementations can be registered and executed in sequence (e.g., validators, middleware).

**Implementation:**

```typescript
// plugin.interface.ts
export interface ValidationPlugin {
  name: string;
  validate(value: any): { valid: boolean; errors?: string[] };
}

// plugin.token.ts
import { InjectionToken } from '@angular/core';
import { ValidationPlugin } from './plugin.interface';

/**
 * Multi-provider token for validation plugins
 * Multiple providers can be registered for this token
 */
export const VALIDATION_PLUGINS = new InjectionToken<ValidationPlugin[]>(
  'validation.plugins'
);

// plugins/required.plugin.ts
import { ValidationPlugin } from '../plugin.interface';

/**
 * Required field validation plugin
 */
export class RequiredValidationPlugin implements ValidationPlugin {
  name = 'RequiredValidator';

  validate(value: any): { valid: boolean; errors?: string[] } {
    if (value === null || value === undefined || value === '') {
      return {
        valid: false,
        errors: ['This field is required']
      };
    }
    
    return { valid: true };
  }
}

// plugins/email.plugin.ts
import { ValidationPlugin } from '../plugin.interface';

/**
 * Email format validation plugin
 */
export class EmailValidationPlugin implements ValidationPlugin {
  name = 'EmailValidator';

  validate(value: any): { valid: boolean; errors?: string[] } {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    
    if (value && !emailRegex.test(value)) {
      return {
        valid: false,
        errors: ['Invalid email format']
      };
    }
    
    return { valid: true };
  }
}

// plugins/length.plugin.ts
import { ValidationPlugin } from '../plugin.interface';

/**
 * Length validation plugin (configurable)
 */
export class LengthValidationPlugin implements ValidationPlugin {
  name = 'LengthValidator';

  constructor(
    private minLength: number,
    private maxLength: number
  ) {}

  validate(value: any): { valid: boolean; errors?: string[] } {
    const errors: string[] = [];
    
    if (value && value.length < this.minLength) {
      errors.push(`Minimum length is ${this.minLength} characters`);
    }
    
    if (value && value.length > this.maxLength) {
      errors.push(`Maximum length is ${this.maxLength} characters`);
    }
    
    if (errors.length > 0) {
      return { valid: false, errors };
    }
    
    return { valid: true };
  }
}

// plugins/custom.plugin.ts
import { ValidationPlugin } from '../plugin.interface';

/**
 * Custom validation plugin with regex pattern
 */
export class PatternValidationPlugin implements ValidationPlugin {
  name = 'PatternValidator';

  constructor(
    private pattern: RegExp,
    private errorMessage: string
  ) {}

  validate(value: any): { valid: boolean; errors?: string[] } {
    if (value && !this.pattern.test(value)) {
      return {
        valid: false,
        errors: [this.errorMessage]
      };
    }
    
    return { valid: true };
  }
}

// validation.service.ts
import { Injectable, inject } from '@angular/core';
import { VALIDATION_PLUGINS } from './plugin.token';
import { ValidationPlugin } from './plugin.interface';

@Injectable({
  providedIn: 'root'
})
export class ValidationService {
  // Inject ALL providers registered for VALIDATION_PLUGINS token
  // This returns an array of all plugin instances
  private plugins = inject(VALIDATION_PLUGINS, { optional: true }) || [];

  constructor() {
    console.log(`ValidationService initialized with ${this.plugins.length} plugins:`);
    this.plugins.forEach(plugin => {
      console.log(`  - ${plugin.name}`);
    });
  }

  /**
   * Validate value using all registered plugins
   * Runs all validators and aggregates errors
   */
  validate(value: any): { valid: boolean; errors: string[] } {
    const allErrors: string[] = [];
    
    // Run all validation plugins
    for (const plugin of this.plugins) {
      const result = plugin.validate(value);
      
      if (!result.valid && result.errors) {
        allErrors.push(...result.errors);
      }
    }
    
    return {
      valid: allErrors.length === 0,
      errors: allErrors
    };
  }

  /**
   * Get list of registered plugin names
   */
  getRegisteredPlugins(): string[] {
    return this.plugins.map(p => p.name);
  }
}

// form-field.component.ts
import { Component, Input, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ValidationService } from './validation.service';

@Component({
  selector: 'app-form-field',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="form-field">
      <label>{{ label }}</label>
      
      <input
        type="text"
        [(ngModel)]="value"
        (blur)="onBlur()"
        [class.invalid]="touched() && !isValid()"
        placeholder="{{ placeholder }}"
      />
      
      <!-- Validation errors -->
      @if (touched() && !isValid()) {
        <div class="errors">
          @for (error of errors(); track error) {
            <div class="error-message">{{ error }}</div>
          }
        </div>
      }
      
      <!-- Success indicator -->
      @if (touched() && isValid() && value) {
        <div class="success">✓ Valid</div>
      }
    </div>
  `,
  styles: [`
    .form-field {
      margin-bottom: 16px;
    }
    label {
      display: block;
      margin-bottom: 4px;
      font-weight: 500;
    }
    input {
      width: 100%;
      padding: 8px 12px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
    }
    input.invalid {
      border-color: #f44336;
    }
    .errors {
      margin-top: 4px;
    }
    .error-message {
      color: #f44336;
      font-size: 12px;
      margin: 2px 0;
    }
    .success {
      color: #4caf50;
      font-size: 12px;
      margin-top: 4px;
    }
  `]
})
export class FormFieldComponent {
  @Input() label = '';
  @Input() placeholder = '';
  
  private validationService = inject(ValidationService);
  
  // Form state
  value = '';
  private touched = signal(false);
  
  // Computed validation state
  private validationResult = computed(() => {
    if (!this.value) {
      return { valid: true, errors: [] };
    }
    return this.validationService.validate(this.value);
  });
  
  readonly isValid = computed(() => this.validationResult().valid);
  readonly errors = computed(() => this.validationResult().errors);

  onBlur(): void {
    this.touched.set(true);
  }
}

// app.component.ts
import { Component } from '@angular/core';
import { FormFieldComponent } from './form-field.component';
import { VALIDATION_PLUGINS } from './plugin.token';
import { 
  RequiredValidationPlugin,
  EmailValidationPlugin,
  LengthValidationPlugin,
  PatternValidationPlugin
} from './plugins';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [FormFieldComponent],
  // Register multiple providers for VALIDATION_PLUGINS token
  providers: [
    // Each provider adds to the multi-provider array
    {
      provide: VALIDATION_PLUGINS,
      useClass: RequiredValidationPlugin,
      multi: true // CRITICAL: Enables multi-provider pattern
    },
    {
      provide: VALIDATION_PLUGINS,
      useClass: EmailValidationPlugin,
      multi: true
    },
    {
      provide: VALIDATION_PLUGINS,
      useValue: new LengthValidationPlugin(5, 50),
      multi: true
    },
    {
      provide: VALIDATION_PLUGINS,
      useValue: new PatternValidationPlugin(
        /^[a-zA-Z0-9]+$/,
        'Only alphanumeric characters allowed'
      ),
      multi: true
    }
  ],
  template: `
    <div class="app">
      <h1>Multi-Provider Plugin System</h1>
      
      <div class="form">
        <h2>User Registration</h2>
        
        <app-form-field
          label="Username"
          placeholder="Enter username"
        ></app-form-field>
        
        <app-form-field
          label="Email"
          placeholder="Enter email"
        ></app-form-field>
        
        <p class="info">
          All fields are validated using 4 plugins:
          Required, Email, Length (5-50), and Alphanumeric
        </p>
      </div>
    </div>
  `,
  styles: [`
    .app {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .form {
      background: white;
      padding: 24px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .info {
      color: #666;
      font-size: 14px;
      margin-top: 16px;
    }
  `]
})
export class AppComponent {}
```

**Multi-Provider Pattern Benefits:**
1. **Extensibility**: Easy to add new plugins without modifying existing code
2. **Separation of Concerns**: Each plugin is independent
3. **Testability**: Plugins can be tested in isolation
4. **Flexible Configuration**: Can register different plugins in different modules
5. **Open/Closed Principle**: Open for extension, closed for modification

**Real-World Use Cases:**
- HTTP Interceptors (Angular uses multi-providers internally)
- Validation systems
- Logging handlers
- Event subscribers
- Middleware pipelines
- Route guards (multiple guards per route)

---

## Change Detection

### Q9: Implement manual change detection with zones (Asked at: Netflix, LinkedIn)

**Question:** Create a component that runs heavy computation outside Angular's zone and manually triggers change detection when needed.

**Implementation:**

```typescript
// heavy-computation.component.ts
import { 
  Component, 
  NgZone, 
  ChangeDetectorRef, 
  ChangeDetectionStrategy,
  signal,
  inject,
  OnDestroy
} from '@angular/core';
import { CommonModule } from '@angular/common';

interface ComputationResult {
  value: number;
  iterations: number;
  duration: number;
}

@Component({
  selector: 'app-heavy-computation',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="container">
      <h2>Heavy Computation with Zone Control</h2>
      
      <!-- Control Panel -->
      <div class="controls">
        <button 
          (click)="startWithZone()"
          [disabled]="isRunning()">
          🐌 Run WITH Zone (Slow)
        </button>
        
        <button 
          (click)="startOutsideZone()"
          [disabled]="isRunning()">
          🚀 Run OUTSIDE Zone (Fast)
        </button>
        
        <button 
          (click)="stopComputation()"
          [disabled]="!isRunning()">
          ⏹ Stop
        </button>
      </div>
      
      <!-- Progress Bar -->
      @if (isRunning()) {
        <div class="progress-container">
          <div class="progress-bar" [style.width.%]="progress()"></div>
          <span class="progress-text">{{ progress().toFixed(1) }}%</span>
        </div>
      }
      
      <!-- Results -->
      <div class="results">
        <div class="result-card">
          <h3>Current Value</h3>
          <p class="big-number">{{ currentValue() }}</p>
        </div>
        
        <div class="result-card">
          <h3>Iterations</h3>
          <p class="big-number">{{ iterations() }}</p>
        </div>
        
        <div class="result-card">
          <h3>FPS Counter</h3>
          <p class="big-number">{{ fps() }}</p>
          <small>{{ fpsStatus() }}</small>
        </div>
      </div>
      
      <!-- Change Detection Stats -->
      <div class="stats">
        <h3>Change Detection Stats</h3>
        <p>CD Checks: {{ cdChecks() }}</p>
        <p>Manual Triggers: {{ manualTriggers() }}</p>
        <p>Status: {{ isRunning() ? 'Running' : 'Idle' }}</p>
      </div>
      
      <!-- Explanation -->
      <div class="explanation">
        <h3>💡 Key Concepts</h3>
        <ul>
          <li><strong>WITH Zone:</strong> Every computation triggers CD (~60 times/sec) = Slow UI</li>
          <li><strong>OUTSIDE Zone:</strong> Computation runs without CD, manual trigger every 100ms = Smooth UI</li>
          <li><strong>FPS Counter:</strong> requestAnimationFrame outside zone for 60fps animation</li>
        </ul>
      </div>
    </div>
  `,
  styles: [`
    .container {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .controls {
      display: flex;
      gap: 12px;
      margin: 20px 0;
    }
    button {
      flex: 1;
      padding: 12px 24px;
      font-size: 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      background: #2196f3;
      color: white;
    }
    button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    .progress-container {
      position: relative;
      height: 40px;
      background: #eee;
      border-radius: 4px;
      overflow: hidden;
      margin: 20px 0;
    }
    .progress-bar {
      height: 100%;
      background: linear-gradient(90deg, #4caf50, #8bc34a);
      transition: width 0.1s ease-out;
    }
    .progress-text {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      font-weight: bold;
      color: #333;
    }
    .results {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin: 20px 0;
    }
    .result-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      text-align: center;
    }
    .result-card h3 {
      margin: 0 0 12px 0;
      color: #666;
      font-size: 14px;
    }
    .big-number {
      font-size: 32px;
      font-weight: bold;
      color: #2196f3;
      margin: 0;
    }
    .stats {
      background: #f5f5f5;
      padding: 16px;
      border-radius: 4px;
      margin: 20px 0;
    }
    .stats h3 {
      margin: 0 0 12px 0;
    }
    .stats p {
      margin: 4px 0;
    }
    .explanation {
      background: #e3f2fd;
      padding: 16px;
      border-radius: 4px;
      border-left: 4px solid #2196f3;
    }
    .explanation h3 {
      margin: 0 0 12px 0;
    }
    .explanation ul {
      margin: 0;
      padding-left: 20px;
    }
    .explanation li {
      margin: 8px 0;
    }
  `]
})
export class HeavyComputationComponent implements OnDestroy {
  private ngZone = inject(NgZone);
  private cdr = inject(ChangeDetectorRef);
  
  // Computation state
  isRunning = signal(false);
  currentValue = signal(0);
  iterations = signal(0);
  progress = signal(0);
  
  // Change detection tracking
  cdChecks = signal(0);
  manualTriggers = signal(0);
  
  // FPS tracking
  fps = signal(60);
  fpsStatus = signal('Excellent');
  
  // Animation frame ID for cleanup
  private animationFrameId: number | null = null;
  private computationIntervalId: any = null;
  private shouldStop = false;

  constructor() {
    // Start FPS counter (runs outside zone)
    this.startFpsCounter();
  }

  ngDoCheck(): void {
    // Count every CD check
    this.cdChecks.update(count => count + 1);
  }

  ngOnDestroy(): void {
    // Cleanup
    this.stopComputation();
    if (this.animationFrameId) {
      cancelAnimationFrame(this.animationFrameId);
    }
  }

  /**
   * Run computation INSIDE Angular zone
   * This triggers change detection on every iteration = SLOW
   */
  startWithZone(): void {
    this.resetState();
    this.isRunning.set(true);
    this.shouldStop = false;
    
    console.log('🐌 Starting computation INSIDE zone (triggering CD)');
    
    // Run inside zone - every operation triggers CD
    this.computationIntervalId = setInterval(() => {
      if (this.shouldStop) {
        this.stopComputation();
        return;
      }
      
      // Heavy computation
      const result = this.performHeavyComputation();
      
      // Update state (triggers CD automatically because inside zone)
      this.currentValue.set(result.value);
      this.iterations.update(i => i + 1);
      this.progress.set((this.iterations() / 1000) * 100);
      
      // Log CD trigger
      console.log(`CD triggered by zone - Iteration ${this.iterations()}`);
      
      if (this.iterations() >= 1000) {
        this.stopComputation();
      }
    }, 16); // ~60 times per second
  }

  /**
   * Run computation OUTSIDE Angular zone
   * Manually trigger CD only when necessary = FAST
   */
  startOutsideZone(): void {
    this.resetState();
    this.isRunning.set(true);
    this.shouldStop = false;
    
    console.log('🚀 Starting computation OUTSIDE zone (manual CD)');
    
    // Run outside zone - no automatic CD
    this.ngZone.runOutsideAngular(() => {
      let localIterations = 0;
      let localValue = 0;
      
      this.computationIntervalId = setInterval(() => {
        if (this.shouldStop) {
          // Re-enter zone to stop
          this.ngZone.run(() => {
            this.stopComputation();
          });
          return;
        }
        
        // Heavy computation (doesn't trigger CD)
        const result = this.performHeavyComputation();
        localValue = result.value;
        localIterations++;
        
        // Update state every 10 iterations (10 times per second instead of 60)
        if (localIterations % 10 === 0) {
          // Re-enter Angular zone to update UI
          this.ngZone.run(() => {
            this.currentValue.set(localValue);
            this.iterations.set(localIterations);
            this.progress.set((localIterations / 1000) * 100);
            this.manualTriggers.update(t => t + 1);
            
            // Manually trigger change detection
            this.cdr.detectChanges();
            
            console.log(`Manual CD triggered - Iteration ${localIterations}`);
          });
        }
        
        if (localIterations >= 1000) {
          this.ngZone.run(() => {
            this.stopComputation();
          });
        }
      }, 16); // Same interval, but CD only 10 times/sec
    });
  }

  /**
   * Stop computation
   */
  stopComputation(): void {
    this.shouldStop = true;
    
    if (this.computationIntervalId) {
      clearInterval(this.computationIntervalId);
      this.computationIntervalId = null;
    }
    
    this.isRunning.set(false);
    console.log('⏹ Computation stopped');
  }

  /**
   * Reset state
   */
  private resetState(): void {
    this.currentValue.set(0);
    this.iterations.set(0);
    this.progress.set(0);
    this.cdChecks.set(0);
    this.manualTriggers.set(0);
  }

  /**
   * Simulate heavy computation
   */
  private performHeavyComputation(): ComputationResult {
    const start = performance.now();
    
    // Simulate CPU-intensive work
    let result = 0;
    for (let i = 0; i < 100000; i++) {
      result += Math.sqrt(i) * Math.random();
    }
    
    const duration = performance.now() - start;
    
    return {
      value: Math.floor(result),
      iterations: 1,
      duration
    };
  }

  /**
   * FPS counter using requestAnimationFrame outside zone
   */
  private startFpsCounter(): void {
    // Run FPS counter outside zone to avoid triggering CD
    this.ngZone.runOutsideAngular(() => {
      let lastTime = performance.now();
      let frames = 0;
      
      const updateFps = () => {
        const currentTime = performance.now();
        frames++;
        
        // Calculate FPS every second
        if (currentTime >= lastTime + 1000) {
          const currentFps = Math.round((frames * 1000) / (currentTime - lastTime));
          
          // Update FPS in Angular zone
          this.ngZone.run(() => {
            this.fps.set(currentFps);
            
            // Set status based on FPS
            if (currentFps >= 55) {
              this.fpsStatus.set('Excellent');
            } else if (currentFps >= 30) {
              this.fpsStatus.set('Good');
            } else if (currentFps >= 20) {
              this.fpsStatus.set('Fair');
            } else {
              this.fpsStatus.set('Poor');
            }
            
            // Manually trigger CD for FPS update
            this.cdr.markForCheck();
          });
          
          frames = 0;
          lastTime = currentTime;
        }
        
        // Continue animation loop
        this.animationFrameId = requestAnimationFrame(updateFps);
      };
      
      updateFps();
    });
  }
}
```

**Key Concepts:**
1. **NgZone.runOutsideAngular()**: Run code without triggering CD
2. **NgZone.run()**: Re-enter zone to trigger CD
3. **ChangeDetectorRef.detectChanges()**: Manually trigger CD for this component
4. **ChangeDetectorRef.markForCheck()**: Mark component and ancestors for check
5. **Performance**: Outside zone = 6x fewer CD checks = smoother UI

---

## Routing & Guards

### Q10: Implement complex route guard with async validation (Asked at: Google, Airbnb)

**Question:** Create a route guard that checks user permissions from an API, handles loading states, and provides detailed error messages.

**Implementation:**

```typescript
// permission.interface.ts
export interface UserPermission {
  userId: string;
  roles: string[];
  permissions: string[];
  expiresAt: Date;
}

// auth.service.ts
import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of, delay, throwError } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private http = inject(HttpClient);
  
  // Cache permissions
  private permissionsCache = signal<UserPermission | null>(null);
  readonly currentPermissions = this.permissionsCache.asReadonly();
  
  // Auth state
  private isAuthenticatedSignal = signal(false);
  readonly isAuthenticated = this.isAuthenticatedSignal.asReadonly();

  /**
   * Check if user is authenticated
   */
  checkAuthentication(): Observable<boolean> {
    // Simulate API call
    return of(true).pipe(
      delay(500),
      tap(isAuth => this.isAuthenticatedSignal.set(isAuth))
    );
  }

  /**
   * Load user permissions from API
   */
  loadPermissions(): Observable<UserPermission> {
    // Check cache first
    const cached = this.permissionsCache();
    if (cached && new Date(cached.expiresAt) > new Date()) {
      console.log('✓ Using cached permissions');
      return of(cached);
    }
    
    console.log('🌐 Fetching permissions from API...');
    
    // Simulate API call
    return of<UserPermission>({
      userId: 'user-123',
      roles: ['admin', 'editor'],
      permissions: ['read:posts', 'write:posts', 'delete:posts', 'manage:users'],
      expiresAt: new Date(Date.now() + 3600000) // 1 hour
    }).pipe(
      delay(1000), // Simulate network delay
      tap(permissions => {
        console.log('✓ Permissions loaded:', permissions);
        this.permissionsCache.set(permissions);
      }),
      catchError(error => {
        console.error('✗ Failed to load permissions:', error);
        return throwError(() => new Error('Failed to load permissions'));
      })
    );
  }

  /**
   * Check if user has specific permission
   */
  hasPermission(permission: string): Observable<boolean> {
    return this.loadPermissions().pipe(
      map(perms => perms.permissions.includes(permission))
    );
  }

  /**
   * Check if user has any of the specified roles
   */
  hasRole(roles: string[]): Observable<boolean> {
    return this.loadPermissions().pipe(
      map(perms => roles.some(role => perms.roles.includes(role)))
    );
  }

  /**
   * Clear permissions cache
   */
  clearPermissions(): void {
    this.permissionsCache.set(null);
  }
}

// guards/permission.guard.ts
import { inject } from '@angular/core';
import { Router, CanActivateFn, ActivatedRouteSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';
import { map, catchError } from 'rxjs/operators';
import { of } from 'rxjs';

/**
 * Functional guard that checks user permissions
 * Usage in routes: canActivate: [permissionGuard]
 * Route data: { requiredPermission: 'write:posts' }
 */
export const permissionGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  // Get required permission from route data
  const requiredPermission = route.data['requiredPermission'] as string;
  const requiredRoles = route.data['requiredRoles'] as string[];
  
  console.log(`🛡️ Permission guard checking for: ${requiredPermission || requiredRoles?.join(', ')}`);
  
  // First check authentication
  return authService.checkAuthentication().pipe(
    map(isAuthenticated => {
      if (!isAuthenticated) {
        console.log('✗ User not authenticated');
        // Redirect to login with return URL
        router.navigate(['/login'], {
          queryParams: { returnUrl: state.url }
        });
        return false;
      }
      return true;
    }),
    // If authenticated, check permissions
    map(isAuthenticated => {
      if (!isAuthenticated) return false;
      
      // Check permission if specified
      if (requiredPermission) {
        authService.hasPermission(requiredPermission).subscribe(hasPermission => {
          if (!hasPermission) {
            console.log(`✗ Missing permission: ${requiredPermission}`);
            router.navigate(['/forbidden'], {
              queryParams: { 
                reason: 'missing-permission',
                required: requiredPermission 
              }
            });
          }
        });
      }
      
      // Check roles if specified
      if (requiredRoles) {
        authService.hasRole(requiredRoles).subscribe(hasRole => {
          if (!hasRole) {
            console.log(`✗ Missing role: ${requiredRoles.join(' or ')}`);
            router.navigate(['/forbidden'], {
              queryParams: { 
                reason: 'missing-role',
                required: requiredRoles.join(',')
              }
            });
          }
        });
      }
      
      console.log('✓ Permission check passed');
      return true;
    }),
    catchError(error => {
      console.error('✗ Guard error:', error);
      router.navigate(['/error']);
      return of(false);
    })
  );
};

// guards/can-deactivate.guard.ts
import { Observable } from 'rxjs';

/**
 * Interface for components that can be deactivated
 */
export interface CanComponentDeactivate {
  canDeactivate: () => Observable<boolean> | Promise<boolean> | boolean;
}

/**
 * Guard to prevent navigation if component has unsaved changes
 */
export const canDeactivateGuard: CanActivateFn = (component: any) => {
  // Check if component implements CanComponentDeactivate
  if (component && typeof component.canDeactivate === 'function') {
    return component.canDeactivate();
  }
  
  return true;
};

// admin-panel.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

/**
 * Protected route component requiring 'manage:users' permission
 */
@Component({
  selector: 'app-admin-panel',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="admin-panel">
      <h2>Admin Panel</h2>
      
      <div class="info-card">
        <h3>Current Permissions</h3>
        @if (permissions(); as perms) {
          <div class="permissions-list">
            <div class="permission-group">
              <strong>Roles:</strong>
              <ul>
                @for (role of perms.roles; track role) {
                  <li class="role-badge">{{ role }}</li>
                }
              </ul>
            </div>
            
            <div class="permission-group">
              <strong>Permissions:</strong>
              <ul>
                @for (perm of perms.permissions; track perm) {
                  <li class="permission-badge">{{ perm }}</li>
                }
              </ul>
            </div>
            
            <div class="permission-group">
              <strong>Expires:</strong>
              <p>{{ perms.expiresAt | date:'medium' }}</p>
            </div>
          </div>
        }
      </div>
      
      <div class="actions">
        <button (click)="manageUsers()">Manage Users</button>
        <button (click)="viewLogs()">View Logs</button>
        <button (click)="clearCache()">Clear Permission Cache</button>
      </div>
    </div>
  `,
  styles: [`
    .admin-panel {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .info-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      margin: 20px 0;
    }
    .permissions-list {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .permission-group ul {
      list-style: none;
      padding: 0;
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }
    .role-badge {
      background: #2196f3;
      color: white;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 14px;
    }
    .permission-badge {
      background: #4caf50;
      color: white;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 14px;
    }
    .actions {
      display: flex;
      gap: 12px;
    }
    .actions button {
      flex: 1;
      padding: 12px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
  `]
})
export class AdminPanelComponent {
  private authService = inject(AuthService);
  private router = inject(Router);
  
  permissions = this.authService.currentPermissions;

  manageUsers(): void {
    this.router.navigate(['/admin/users']);
  }

  viewLogs(): void {
    this.router.navigate(['/admin/logs']);
  }

  clearCache(): void {
    this.authService.clearPermissions();
    alert('Permission cache cleared. Refresh to reload.');
  }
}

// app.routes.ts
import { Routes } from '@angular/router';
import { permissionGuard, canDeactivateGuard } from './guards';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./home/home.component').then(m => m.HomeComponent)
  },
  {
    path: 'admin',
    loadComponent: () => import('./admin-panel/admin-panel.component').then(m => m.AdminPanelComponent),
    canActivate: [permissionGuard],
    data: { 
      requiredRoles: ['admin'],
      requiredPermission: 'manage:users'
    }
  },
  {
    path: 'posts/new',
    loadComponent: () => import('./post-editor/post-editor.component').then(m => m.PostEditorComponent),
    canActivate: [permissionGuard],
    canDeactivate: [canDeactivateGuard],
    data: { 
      requiredPermission: 'write:posts'
    }
  },
  {
    path: 'forbidden',
    loadComponent: () => import('./forbidden/forbidden.component').then(m => m.ForbiddenComponent)
  }
];
```

**Guard Features:**
1. **Async Permission Checking**: Loads from API with caching
2. **Multiple Guard Types**: Authentication + Authorization
3. **Detailed Error Messages**: Passes context to error pages
4. **Return URL Handling**: Redirects back after login
5. **Can Deactivate**: Prevents navigation with unsaved changes

---

## Forms & Validation

### Q11: Implement dynamic form with custom async validator (Asked at: Meta, Salesforce)

**Question:** Create a dynamic form generator that validates usernames against an API, with debouncing and loading indicators.

**Implementation:**

```typescript
// form-field.interface.ts
export interface FormFieldConfig {
  type: 'text' | 'email' | 'password' | 'number' | 'select' | 'checkbox';
  name: string;
  label: string;
  placeholder?: string;
  required?: boolean;
  minLength?: number;
  maxLength?: number;
  pattern?: string;
  options?: { label: string; value: any }[];
  asyncValidator?: 'username' | 'email';
}

// validators/async-validators.ts
import { AbstractControl, AsyncValidatorFn, ValidationErrors } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Observable, of, timer } from 'rxjs';
import { map, catchError, switchMap, debounceTime, distinctUntilChanged, first } from 'rxjs/operators';
import { inject } from '@angular/core';

/**
 * Async validator to check username availability
 * Debounces input and queries API
 */
export function usernameAsyncValidator(): AsyncValidatorFn {
  const http = inject(HttpClient);
  
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    // Don't validate empty values (let required validator handle it)
    if (!control.value) {
      return of(null);
    }
    
    console.log(`🔍 Checking username availability: ${control.value}`);
    
    // Return observable that debounces and checks API
    return timer(500).pipe( // Debounce 500ms
      switchMap(() => {
        // Simulate API call to check username
        return of({ available: control.value !== 'admin' }).pipe(
          map(response => {
            if (response.available) {
              console.log(`✓ Username available: ${control.value}`);
              return null; // Valid
            } else {
              console.log(`✗ Username taken: ${control.value}`);
              return { usernameTaken: true }; // Invalid
            }
          }),
          catchError(error => {
            console.error('✗ Validation error:', error);
            return of({ validationError: true });
          })
        );
      }),
      first() // Complete after first emission
    );
  };
}

/**
 * Async validator to check email format and domain
 */
export function emailAsyncValidator(): AsyncValidatorFn {
  const http = inject(HttpClient);
  
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    if (!control.value) {
      return of(null);
    }
    
    console.log(`🔍 Validating email: ${control.value}`);
    
    return timer(500).pipe(
      switchMap(() => {
        // Check if email domain is valid
        const domain = control.value.split('@')[1];
        const blockedDomains = ['tempmail.com', 'throwaway.email'];
        
        if (blockedDomains.includes(domain)) {
          console.log(`✗ Blocked email domain: ${domain}`);
          return of({ blockedDomain: true });
        }
        
        console.log(`✓ Email validated: ${control.value}`);
        return of(null);
      }),
      first()
    );
  };
}

// dynamic-form.component.ts
import { Component, Input, Output, EventEmitter, OnInit, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  FormBuilder, 
  FormGroup, 
  ReactiveFormsModule, 
  Validators,
  AbstractControl
} from '@angular/forms';
import { FormFieldConfig } from './form-field.interface';
import { usernameAsyncValidator, emailAsyncValidator } from './validators/async-validators';

@Component({
  selector: 'app-dynamic-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()" class="dynamic-form">
      <h2>{{ title }}</h2>
      
      @for (field of fields; track field.name) {
        <div class="form-field">
          <label [for]="field.name">
            {{ field.label }}
            @if (field.required) {
              <span class="required">*</span>
            }
          </label>
          
          <!-- Text/Email/Password/Number inputs -->
          @if (field.type !== 'select' && field.type !== 'checkbox') {
            <div class="input-container">
              <input
                [id]="field.name"
                [type]="field.type"
                [formControlName]="field.name"
                [placeholder]="field.placeholder || ''"
                [class.invalid]="isFieldInvalid(field.name)"
                [class.valid]="isFieldValid(field.name)"
              />
              
              <!-- Async validation loading indicator -->
              @if (isFieldValidating(field.name)) {
                <span class="validating-spinner">⟳</span>
              }
            </div>
          }
          
          <!-- Select dropdown -->
          @if (field.type === 'select') {
            <select
              [id]="field.name"
              [formControlName]="field.name"
              [class.invalid]="isFieldInvalid(field.name)">
              <option value="">Select...</option>
              @for (option of field.options; track option.value) {
                <option [value]="option.value">{{ option.label }}</option>
              }
            </select>
          }
          
          <!-- Checkbox -->
          @if (field.type === 'checkbox') {
            <label class="checkbox-label">
              <input
                [id]="field.name"
                type="checkbox"
                [formControlName]="field.name"
              />
              <span>{{ field.placeholder }}</span>
            </label>
          }
          
          <!-- Validation errors -->
          @if (isFieldInvalid(field.name)) {
            <div class="errors">
              @if (getFieldControl(field.name)?.errors?.['required']) {
                <span class="error">This field is required</span>
              }
              @if (getFieldControl(field.name)?.errors?.['minlength']; as error) {
                <span class="error">
                  Minimum length is {{ error.requiredLength }} characters
                </span>
              }
              @if (getFieldControl(field.name)?.errors?.['maxlength']; as error) {
                <span class="error">
                  Maximum length is {{ error.requiredLength }} characters
                </span>
              }
              @if (getFieldControl(field.name)?.errors?.['email']) {
                <span class="error">Invalid email format</span>
              }
              @if (getFieldControl(field.name)?.errors?.['pattern']) {
                <span class="error">Invalid format</span>
              }
              @if (getFieldControl(field.name)?.errors?.['usernameTaken']) {
                <span class="error">Username is already taken</span>
              }
              @if (getFieldControl(field.name)?.errors?.['blockedDomain']) {
                <span class="error">Email domain is not allowed</span>
              }
              @if (getFieldControl(field.name)?.errors?.['validationError']) {
                <span class="error">Validation failed</span>
              }
            </div>
          }
          
          <!-- Success indicator -->
          @if (isFieldValid(field.name)) {
            <div class="success">✓ Valid</div>
          }
        </div>
      }
      
      <!-- Form-level errors -->
      @if (form.errors?.['passwordMismatch']) {
        <div class="form-error">
          Passwords do not match
        </div>
      }
      
      <!-- Submit button -->
      <button 
        type="submit" 
        [disabled]="form.invalid || form.pending"
        class="submit-btn">
        @if (form.pending) {
          <span>Validating...</span>
        } @else {
          <span>{{ submitButtonText }}</span>
        }
      </button>
      
      <!-- Form status -->
      <div class="form-status">
        <p>Form Status: {{ formStatus() }}</p>
        <p>Valid: {{ form.valid }}</p>
        <p>Pending: {{ form.pending }}</p>
      </div>
    </form>
  `,
  styles: [`
    .dynamic-form {
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .form-field {
      margin-bottom: 20px;
    }
    label {
      display: block;
      margin-bottom: 4px;
      font-weight: 500;
    }
    .required {
      color: #f44336;
    }
    .input-container {
      position: relative;
    }
    input, select {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #ddd;
      border-radius: 4px;
      font-size: 14px;
      box-sizing: border-box;
    }
    input.invalid, select.invalid {
      border-color: #f44336;
    }
    input.valid {
      border-color: #4caf50;
    }
    .validating-spinner {
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      from { transform: translateY(-50%) rotate(0deg); }
      to { transform: translateY(-50%) rotate(360deg); }
    }
    .checkbox-label {
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
    }
    .errors {
      margin-top: 4px;
    }
    .error {
      display: block;
      color: #f44336;
      font-size: 12px;
      margin: 2px 0;
    }
    .success {
      color: #4caf50;
      font-size: 12px;
      margin-top: 4px;
    }
    .form-error {
      background: #ffebee;
      color: #f44336;
      padding: 12px;
      border-radius: 4px;
      margin-bottom: 16px;
      border-left: 4px solid #f44336;
    }
    .submit-btn {
      width: 100%;
      padding: 12px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
    }
    .submit-btn:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    .form-status {
      margin-top: 16px;
      padding: 12px;
      background: #f5f5f5;
      border-radius: 4px;
      font-size: 14px;
    }
    .form-status p {
      margin: 4px 0;
    }
  `]
})
export class DynamicFormComponent implements OnInit {
  @Input() fields: FormFieldConfig[] = [];
  @Input() title = 'Form';
  @Input() submitButtonText = 'Submit';
  @Output() formSubmit = new EventEmitter<any>();
  
  private fb = inject(FormBuilder);
  
  form!: FormGroup;
  
  formStatus = computed(() => {
    if (this.form.pending) return 'Validating...';
    if (this.form.invalid) return 'Invalid';
    return 'Valid';
  });

  ngOnInit(): void {
    this.buildForm();
  }

  /**
   * Build form dynamically from field configuration
   */
  private buildForm(): void {
    const group: any = {};
    
    this.fields.forEach(field => {
      const validators = [];
      const asyncValidators = [];
      
      // Add sync validators
      if (field.required) {
        validators.push(Validators.required);
      }
      if (field.minLength) {
        validators.push(Validators.minLength(field.minLength));
      }
      if (field.maxLength) {
        validators.push(Validators.maxLength(field.maxLength));
      }
      if (field.pattern) {
        validators.push(Validators.pattern(field.pattern));
      }
      if (field.type === 'email') {
        validators.push(Validators.email);
      }
      
      // Add async validators
      if (field.asyncValidator === 'username') {
        asyncValidators.push(usernameAsyncValidator());
      }
      if (field.asyncValidator === 'email') {
        asyncValidators.push(emailAsyncValidator());
      }
      
      // Create form control
      group[field.name] = [
        '', // Initial value
        validators,
        asyncValidators
      ];
    });
    
    this.form = this.fb.group(group);
  }

  /**
   * Check if field is invalid and touched
   */
  isFieldInvalid(fieldName: string): boolean {
    const control = this.form.get(fieldName);
    return !!(control && control.invalid && (control.dirty || control.touched));
  }

  /**
   * Check if field is valid and not pending
   */
  isFieldValid(fieldName: string): boolean {
    const control = this.form.get(fieldName);
    return !!(control && control.valid && !control.pending && control.value);
  }

  /**
   * Check if field is currently being validated
   */
  isFieldValidating(fieldName: string): boolean {
    const control = this.form.get(fieldName);
    return !!(control && control.pending);
  }

  /**
   * Get form control by name
   */
  getFieldControl(fieldName: string): AbstractControl | null {
    return this.form.get(fieldName);
  }

  /**
   * Handle form submission
   */
  onSubmit(): void {
    if (this.form.valid) {
      console.log('✓ Form submitted:', this.form.value);
      this.formSubmit.emit(this.form.value);
    } else {
      console.log('✗ Form invalid');
      // Mark all fields as touched to show errors
      Object.keys(this.form.controls).forEach(key => {
        this.form.get(key)?.markAsTouched();
      });
    }
  }
}

// app.component.ts - Usage example
import { Component } from '@angular/core';
import { DynamicFormComponent } from './dynamic-form/dynamic-form.component';
import { FormFieldConfig } from './dynamic-form/form-field.interface';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [DynamicFormComponent],
  template: `
    <div class="app">
      <h1>Dynamic Form with Async Validation</h1>
      
      <app-dynamic-form
        [fields]="formFields"
        [title]="'User Registration'"
        [submitButtonText]="'Register'"
        (formSubmit)="onFormSubmit($event)"
      ></app-dynamic-form>
    </div>
  `,
  styles: [`
    .app {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
  `]
})
export class AppComponent {
  formFields: FormFieldConfig[] = [
    {
      type: 'text',
      name: 'username',
      label: 'Username',
      placeholder: 'Choose a username',
      required: true,
      minLength: 3,
      maxLength: 20,
      asyncValidator: 'username'
    },
    {
      type: 'email',
      name: 'email',
      label: 'Email',
      placeholder: 'your@email.com',
      required: true,
      asyncValidator: 'email'
    },
    {
      type: 'password',
      name: 'password',
      label: 'Password',
      placeholder: 'Enter password',
      required: true,
      minLength: 8
    },
    {
      type: 'select',
      name: 'country',
      label: 'Country',
      required: true,
      options: [
        { label: 'United States', value: 'US' },
        { label: 'Canada', value: 'CA' },
        { label: 'United Kingdom', value: 'UK' }
      ]
    },
    {
      type: 'checkbox',
      name: 'terms',
      label: 'Terms',
      placeholder: 'I agree to the terms and conditions',
      required: true
    }
  ];

  onFormSubmit(data: any): void {
    console.log('Form submitted with data:', data);
    alert('Registration successful!');
  }
}
```

**Form Features:**
1. **Dynamic Generation**: Build forms from configuration
2. **Async Validators**: Check username/email with API
3. **Debouncing**: Wait for user to stop typing
4. **Loading States**: Show spinner during validation
5. **Rich Error Messages**: Display specific validation errors
6. **Type Safety**: Full TypeScript support

---

## State Management

### Q12: Implement a state management service with Signals (Asked at: Uber, Spotify)

**Question:** Create a centralized state management solution using Signals that handles products, cart, and user preferences with undo/redo capability.

**Implementation:**

```typescript
// state.interface.ts
export interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

export interface UserPreferences {
  theme: 'light' | 'dark';
  currency: 'USD' | 'EUR' | 'GBP';
  notifications: boolean;
}

export interface AppState {
  products: Product[];
  cart: CartItem[];
  preferences: UserPreferences;
  loading: boolean;
  error: string | null;
}

// state-history.interface.ts
export interface StateHistory<T> {
  past: T[];
  present: T;
  future: T[];
}

// state.service.ts
import { Injectable, signal, computed, effect } from '@angular/core';
import { AppState, Product, CartItem, UserPreferences } from './state.interface';
import { StateHistory } from './state-history.interface';

/**
 * Centralized state management service using Signals
 * Implements undo/redo pattern with history tracking
 */
@Injectable({
  providedIn: 'root'
})
export class StateService {
  // Initial state
  private readonly initialState: AppState = {
    products: [],
    cart: [],
    preferences: {
      theme: 'light',
      currency: 'USD',
      notifications: true
    },
    loading: false,
    error: null
  };

  // State history for undo/redo
  private stateHistory = signal<StateHistory<AppState>>({
    past: [],
    present: this.initialState,
    future: []
  });

  // Current state (extracted from history)
  private state = computed(() => this.stateHistory().present);

  // Public selectors (read-only computed signals)
  readonly products = computed(() => this.state().products);
  readonly cart = computed(() => this.state().cart);
  readonly preferences = computed(() => this.state().preferences);
  readonly loading = computed(() => this.state().loading);
  readonly error = computed(() => this.state().error);

  // Derived state
  readonly cartTotal = computed(() => {
    return this.cart().reduce((total, item) => {
      return total + (item.product.price * item.quantity);
    }, 0);
  });

  readonly cartItemCount = computed(() => {
    return this.cart().reduce((count, item) => count + item.quantity, 0);
  });

  readonly productsGroupedByCategory = computed(() => {
    const products = this.products();
    const grouped = new Map<string, Product[]>();
    
    products.forEach(product => {
      const category = product.category;
      if (!grouped.has(category)) {
        grouped.set(category, []);
      }
      grouped.get(category)!.push(product);
    });
    
    return grouped;
  });

  // History state
  readonly canUndo = computed(() => this.stateHistory().past.length > 0);
  readonly canRedo = computed(() => this.stateHistory().future.length > 0);

  constructor() {
    // Load initial products
    this.loadProducts();
    
    // Persist state to localStorage
    this.setupPersistence();
    
    // Log state changes in development
    this.setupDevLogging();
  }

  /**
   * Update state immutably and save to history
   */
  private updateState(updater: (state: AppState) => AppState, saveHistory = true): void {
    const history = this.stateHistory();
    const newState = updater(history.present);
    
    if (saveHistory) {
      // Save current state to history
      this.stateHistory.set({
        past: [...history.past, history.present],
        present: newState,
        future: [] // Clear future when new action is performed
      });
    } else {
      // Update without saving to history (for undo/redo)
      this.stateHistory.update(h => ({
        ...h,
        present: newState
      }));
    }
  }

  /**
   * Load products (simulate API call)
   */
  loadProducts(): void {
    // Set loading state
    this.updateState(state => ({ ...state, loading: true, error: null }), false);
    
    // Simulate API delay
    setTimeout(() => {
      const products: Product[] = [
        { id: 1, name: 'Laptop', price: 999, category: 'Electronics' },
        { id: 2, name: 'Mouse', price: 29, category: 'Electronics' },
        { id: 3, name: 'Desk', price: 299, category: 'Furniture' },
        { id: 4, name: 'Chair', price: 199, category: 'Furniture' },
        { id: 5, name: 'Monitor', price: 399, category: 'Electronics' }
      ];
      
      this.updateState(state => ({
        ...state,
        products,
        loading: false
      }), false);
    }, 1000);
  }

  /**
   * Add product to cart
   */
  addToCart(product: Product): void {
    this.updateState(state => {
      const existingItem = state.cart.find(item => item.product.id === product.id);
      
      if (existingItem) {
        // Increment quantity
        return {
          ...state,
          cart: state.cart.map(item =>
            item.product.id === product.id
              ? { ...item, quantity: item.quantity + 1 }
              : item
          )
        };
      } else {
        // Add new item
        return {
          ...state,
          cart: [...state.cart, { product, quantity: 1 }]
        };
      }
    });
    
    console.log(`✓ Added ${product.name} to cart`);
  }

  /**
   * Remove product from cart
   */
  removeFromCart(productId: number): void {
    this.updateState(state => ({
      ...state,
      cart: state.cart.filter(item => item.product.id !== productId)
    }));
    
    console.log(`✓ Removed product ${productId} from cart`);
  }

  /**
   * Update cart item quantity
   */
  updateCartQuantity(productId: number, quantity: number): void {
    if (quantity <= 0) {
      this.removeFromCart(productId);
      return;
    }
    
    this.updateState(state => ({
      ...state,
      cart: state.cart.map(item =>
        item.product.id === productId
          ? { ...item, quantity }
          : item
      )
    }));
    
    console.log(`✓ Updated product ${productId} quantity to ${quantity}`);
  }

  /**
   * Clear cart
   */
  clearCart(): void {
    this.updateState(state => ({
      ...state,
      cart: []
    }));
    
    console.log('✓ Cart cleared');
  }

  /**
   * Update user preferences
   */
  updatePreferences(preferences: Partial<UserPreferences>): void {
    this.updateState(state => ({
      ...state,
      preferences: { ...state.preferences, ...preferences }
    }));
    
    console.log('✓ Preferences updated:', preferences);
  }

  /**
   * Undo last action
   */
  undo(): void {
    const history = this.stateHistory();
    
    if (history.past.length === 0) {
      console.log('✗ Nothing to undo');
      return;
    }
    
    const previous = history.past[history.past.length - 1];
    const newPast = history.past.slice(0, -1);
    
    this.stateHistory.set({
      past: newPast,
      present: previous,
      future: [history.present, ...history.future]
    });
    
    console.log('↶ Undo performed');
  }

  /**
   * Redo last undone action
   */
  redo(): void {
    const history = this.stateHistory();
    
    if (history.future.length === 0) {
      console.log('✗ Nothing to redo');
      return;
    }
    
    const next = history.future[0];
    const newFuture = history.future.slice(1);
    
    this.stateHistory.set({
      past: [...history.past, history.present],
      present: next,
      future: newFuture
    });
    
    console.log('↷ Redo performed');
  }

  /**
   * Reset to initial state
   */
  reset(): void {
    this.stateHistory.set({
      past: [],
      present: this.initialState,
      future: []
    });
    
    console.log('↺ State reset');
  }

  /**
   * Get current state snapshot (for debugging)
   */
  getStateSnapshot(): AppState {
    return this.state();
  }

  /**
   * Setup localStorage persistence
   */
  private setupPersistence(): void {
    // Load from localStorage on init
    const saved = localStorage.getItem('app-state');
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        this.stateHistory.set({
          past: [],
          present: parsed,
          future: []
        });
        console.log('✓ State loaded from localStorage');
      } catch (error) {
        console.error('✗ Failed to load state from localStorage:', error);
      }
    }
    
    // Save to localStorage on state changes
    effect(() => {
      const state = this.state();
      localStorage.setItem('app-state', JSON.stringify(state));
      console.log('💾 State saved to localStorage');
    });
  }

  /**
   * Setup development logging
   */
  private setupDevLogging(): void {
    effect(() => {
      const state = this.state();
      console.log('📊 State changed:', {
        products: state.products.length,
        cartItems: state.cart.length,
        cartTotal: this.cartTotal(),
        preferences: state.preferences
      });
    });
  }
}

// state-display.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StateService } from './state.service';

@Component({
  selector: 'app-state-display',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="state-container">
      <div class="header">
        <h2>State Management Demo</h2>
        
        <!-- Undo/Redo controls -->
        <div class="history-controls">
          <button 
            (click)="stateService.undo()"
            [disabled]="!stateService.canUndo()">
            ↶ Undo
          </button>
          <button 
            (click)="stateService.redo()"
            [disabled]="!stateService.canRedo()">
            ↷ Redo
          </button>
          <button (click)="stateService.reset()">
            ↺ Reset
          </button>
        </div>
      </div>
      
      <!-- Products Grid -->
      <div class="section">
        <h3>Products</h3>
        
        @if (stateService.loading()) {
          <div class="loading">Loading products...</div>
        } @else {
          <div class="products-grid">
            @for (product of stateService.products(); track product.id) {
              <div class="product-card">
                <h4>{{ product.name }}</h4>
                <p class="price">\${{ product.price }}</p>
                <p class="category">{{ product.category }}</p>
                <button (click)="stateService.addToCart(product)">
                  Add to Cart
                </button>
              </div>
            }
          </div>
        }
      </div>
      
      <!-- Cart -->
      <div class="section">
        <h3>Shopping Cart ({{ stateService.cartItemCount() }} items)</h3>
        
        @if (stateService.cart().length === 0) {
          <p class="empty">Cart is empty</p>
        } @else {
          <div class="cart-items">
            @for (item of stateService.cart(); track item.product.id) {
              <div class="cart-item">
                <div class="item-info">
                  <strong>{{ item.product.name }}</strong>
                  <span>\${{ item.product.price }} × {{ item.quantity }}</span>
                </div>
                
                <div class="item-controls">
                  <button (click)="stateService.updateCartQuantity(item.product.id, item.quantity - 1)">
                    -
                  </button>
                  <span>{{ item.quantity }}</span>
                  <button (click)="stateService.updateCartQuantity(item.product.id, item.quantity + 1)">
                    +
                  </button>
                  <button (click)="stateService.removeFromCart(item.product.id)">
                    🗑️
                  </button>
                </div>
              </div>
            }
          </div>
          
          <div class="cart-summary">
            <h4>Total: \${{ stateService.cartTotal().toFixed(2) }}</h4>
            <button (click)="stateService.clearCart()" class="clear-btn">
              Clear Cart
            </button>
          </div>
        }
      </div>
      
      <!-- Preferences -->
      <div class="section">
        <h3>Preferences</h3>
        
        <div class="preferences-grid">
          <div class="pref-item">
            <label>Theme:</label>
            <select 
              [value]="stateService.preferences().theme"
              (change)="updateTheme($event)">
              <option value="light">Light</option>
              <option value="dark">Dark</option>
            </select>
          </div>
          
          <div class="pref-item">
            <label>Currency:</label>
            <select 
              [value]="stateService.preferences().currency"
              (change)="updateCurrency($event)">
              <option value="USD">USD</option>
              <option value="EUR">EUR</option>
              <option value="GBP">GBP</option>
            </select>
          </div>
          
          <div class="pref-item">
            <label>
              <input 
                type="checkbox"
                [checked]="stateService.preferences().notifications"
                (change)="updateNotifications($event)"
              />
              Enable Notifications
            </label>
          </div>
        </div>
      </div>
      
      <!-- State Inspector -->
      <div class="section debug">
        <h3>State Inspector</h3>
        <pre>{{ stateService.getStateSnapshot() | json }}</pre>
      </div>
    </div>
  `,
  styles: [`
    .state-container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 30px;
    }
    .history-controls {
      display: flex;
      gap: 8px;
    }
    .history-controls button {
      padding: 8px 16px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .history-controls button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    .section {
      background: white;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .products-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 16px;
    }
    .product-card {
      border: 1px solid #ddd;
      padding: 16px;
      border-radius: 4px;
      text-align: center;
    }
    .product-card h4 {
      margin: 0 0 8px 0;
    }
    .price {
      font-size: 20px;
      font-weight: bold;
      color: #2196f3;
      margin: 8px 0;
    }
    .category {
      color: #666;
      font-size: 14px;
      margin: 8px 0;
    }
    .cart-items {
      display: flex;
      flex-direction: column;
      gap: 12px;
      margin-bottom: 16px;
    }
    .cart-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px;
      background: #f5f5f5;
      border-radius: 4px;
    }
    .item-controls {
      display: flex;
      gap: 8px;
      align-items: center;
    }
    .cart-summary {
      border-top: 2px solid #ddd;
      padding-top: 16px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .clear-btn {
      background: #f44336;
      color: white;
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .preferences-grid {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .pref-item {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .debug {
      background: #f5f5f5;
    }
    .debug pre {
      overflow-x: auto;
      font-size: 12px;
    }
    button {
      padding: 8px 16px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
  `]
})
export class StateDisplayComponent {
  stateService = inject(StateService);

  updateTheme(event: Event): void {
    const select = event.target as HTMLSelectElement;
    this.stateService.updatePreferences({ theme: select.value as any });
  }

  updateCurrency(event: Event): void {
    const select = event.target as HTMLSelectElement;
    this.stateService.updatePreferences({ currency: select.value as any });
  }

  updateNotifications(event: Event): void {
    const checkbox = event.target as HTMLInputElement;
    this.stateService.updatePreferences({ notifications: checkbox.checked });
  }
}
```

**State Management Features:**
1. **Centralized State**: Single source of truth
2. **Immutability**: All updates create new state
3. **Computed Selectors**: Derived state with memoization
4. **Undo/Redo**: Full history tracking
5. **Persistence**: LocalStorage integration
6. **Type Safety**: Full TypeScript support

---

## Testing

### Q13: Write comprehensive unit tests with async operations (Asked at: Google, Amazon)

**Question:** Write tests for a service that handles HTTP requests, caching, and error handling. Include async tests, mocking, and edge cases.

**Implementation:**

```typescript
// user.service.ts
import { Injectable, signal } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError, timer, of } from 'rxjs';
import { catchError, retry, tap, switchMap, shareReplay } from 'rxjs/operators';

export interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);
  
  // Cache for users
  private usersCache = signal<User[] | null>(null);
  private cacheExpiry = signal<number>(0);
  
  // Cache duration: 5 minutes
  private readonly CACHE_DURATION = 5 * 60 * 1000;

  /**
   * Get all users with caching
   */
  getUsers(forceRefresh = false): Observable<User[]> {
    // Check if cache is valid
    if (!forceRefresh && this.isCacheValid()) {
      console.log('✓ Returning cached users');
      return of(this.usersCache()!);
    }
    
    console.log('🌐 Fetching users from API');
    
    return this.http.get<User[]>('/api/users').pipe(
      // Retry failed requests
      retry({
        count: 3,
        delay: (error, retryCount) => {
          console.log(`Retry attempt ${retryCount}`);
          return timer(1000 * retryCount);
        }
      }),
      
      // Cache successful response
      tap(users => {
        this.usersCache.set(users);
        this.cacheExpiry.set(Date.now() + this.CACHE_DURATION);
        console.log('✓ Users cached');
      }),
      
      // Handle errors
      catchError(this.handleError),
      
      // Share replay to prevent multiple requests
      shareReplay(1)
    );
  }

  /**
   * Get user by ID
   */
  getUserById(id: number): Observable<User> {
    // Check cache first
    const cached = this.usersCache();
    if (cached && this.isCacheValid()) {
      const user = cached.find(u => u.id === id);
      if (user) {
        console.log(`✓ Returning cached user ${id}`);
        return of(user);
      }
    }
    
    console.log(`🌐 Fetching user ${id} from API`);
    
    return this.http.get<User>(`/api/users/${id}`).pipe(
      retry({ count: 2, delay: 1000 }),
      catchError(this.handleError)
    );
  }

  /**
   * Create new user
   */
  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>('/api/users', user).pipe(
      tap(newUser => {
        // Invalidate cache
        this.clearCache();
        console.log('✓ User created, cache invalidated');
      }),
      catchError(this.handleError)
    );
  }

  /**
   * Update user
   */
  updateUser(id: number, updates: Partial<User>): Observable<User> {
    return this.http.put<User>(`/api/users/${id}`, updates).pipe(
      tap(updatedUser => {
        // Update cache
        const cached = this.usersCache();
        if (cached && this.isCacheValid()) {
          this.usersCache.set(
            cached.map(u => u.id === id ? updatedUser : u)
          );
        }
        console.log('✓ User updated, cache refreshed');
      }),
      catchError(this.handleError)
    );
  }

  /**
   * Delete user
   */
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`/api/users/${id}`).pipe(
      tap(() => {
        // Remove from cache
        const cached = this.usersCache();
        if (cached && this.isCacheValid()) {
          this.usersCache.set(cached.filter(u => u.id !== id));
        }
        console.log('✓ User deleted, cache updated');
      }),
      catchError(this.handleError)
    );
  }

  /**
   * Check if cache is valid
   */
  private isCacheValid(): boolean {
    return this.usersCache() !== null && Date.now() < this.cacheExpiry();
  }

  /**
   * Clear cache
   */
  clearCache(): void {
    this.usersCache.set(null);
    this.cacheExpiry.set(0);
    console.log('🗑️ Cache cleared');
  }

  /**
   * Handle HTTP errors
   */
  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An error occurred';
    
    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Client Error: ${error.error.message}`;
    } else {
      // Server-side error
      errorMessage = `Server Error: ${error.status} - ${error.message}`;
    }
    
    console.error(errorMessage);
    return throwError(() => new Error(errorMessage));
  }
}

// user.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { UserService, User } from './user.service';

describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;
  
  // Mock data
  const mockUsers: User[] = [
    { id: 1, name: 'Alice', email: 'alice@example.com', role: 'admin' },
    { id: 2, name: 'Bob', email: 'bob@example.com', role: 'user' },
    { id: 3, name: 'Charlie', email: 'charlie@example.com', role: 'user' }
  ];

  beforeEach(() => {
    // Configure testing module
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService]
    });
    
    // Inject service and HTTP mock
    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    // Verify no outstanding HTTP requests
    httpMock.verify();
    
    // Clear cache between tests
    service.clearCache();
  });

  describe('getUsers', () => {
    it('should fetch users from API', (done) => {
      // Call service method
      service.getUsers().subscribe(users => {
        // Assert response
        expect(users).toEqual(mockUsers);
        expect(users.length).toBe(3);
        expect(users[0].name).toBe('Alice');
        done();
      });
      
      // Expect HTTP request
      const req = httpMock.expectOne('/api/users');
      expect(req.request.method).toBe('GET');
      
      // Respond with mock data
      req.flush(mockUsers);
    });

    it('should return cached users on second call', (done) => {
      // First call - fetches from API
      service.getUsers().subscribe(users => {
        expect(users).toEqual(mockUsers);
        
        // Second call - should use cache
        service.getUsers().subscribe(cachedUsers => {
          expect(cachedUsers).toEqual(mockUsers);
          expect(cachedUsers).toBe(users); // Same reference
          done();
        });
        
        // No second HTTP request expected
        httpMock.expectNone('/api/users');
      });
      
      const req = httpMock.expectOne('/api/users');
      req.flush(mockUsers);
    });

    it('should force refresh when forceRefresh is true', (done) => {
      // First call
      service.getUsers().subscribe(() => {
        // Force refresh
        service.getUsers(true).subscribe(users => {
          expect(users).toEqual(mockUsers);
          done();
        });
        
        // Expect second HTTP request
        const req2 = httpMock.expectOne('/api/users');
        req2.flush(mockUsers);
      });
      
      const req1 = httpMock.expectOne('/api/users');
      req1.flush(mockUsers);
    });

    it('should handle HTTP errors', (done) => {
      service.getUsers().subscribe({
        next: () => fail('should have failed'),
        error: (error) => {
          expect(error.message).toContain('Server Error: 500');
          done();
        }
      });
      
      const req = httpMock.expectOne('/api/users');
      req.flush('Server error', { status: 500, statusText: 'Internal Server Error' });
    });

    it('should retry failed requests', (done) => {
      let attempts = 0;
      
      service.getUsers().subscribe({
        next: (users) => {
          // Should succeed after retries
          expect(users).toEqual(mockUsers);
          expect(attempts).toBe(2); // Failed once, succeeded on retry
          done();
        },
        error: () => fail('should not fail with retry')
      });
      
      // Fail first attempt
      const req1 = httpMock.expectOne('/api/users');
      attempts++;
      req1.flush('Error', { status: 500, statusText: 'Error' });
      
      // Succeed on retry
      setTimeout(() => {
        const req2 = httpMock.expectOne('/api/users');
        attempts++;
        req2.flush(mockUsers);
      }, 1100);
    });
  });

  describe('getUserById', () => {
    it('should fetch single user by ID', (done) => {
      const userId = 1;
      const expectedUser = mockUsers[0];
      
      service.getUserById(userId).subscribe(user => {
        expect(user).toEqual(expectedUser);
        expect(user.id).toBe(userId);
        done();
      });
      
      const req = httpMock.expectOne(`/api/users/${userId}`);
      expect(req.request.method).toBe('GET');
      req.flush(expectedUser);
    });

    it('should return cached user if available', (done) => {
      // First populate cache
      service.getUsers().subscribe(() => {
        // Then get user by ID from cache
        service.getUserById(1).subscribe(user => {
          expect(user).toEqual(mockUsers[0]);
          done();
        });
        
        // No HTTP request for getUserById
        httpMock.expectNone('/api/users/1');
      });
      
      const req = httpMock.expectOne('/api/users');
      req.flush(mockUsers);
    });

    it('should handle user not found', (done) => {
      service.getUserById(999).subscribe({
        next: () => fail('should have failed'),
        error: (error) => {
          expect(error.message).toContain('404');
          done();
        }
      });
      
      const req = httpMock.expectOne('/api/users/999');
      req.flush('Not found', { status: 404, statusText: 'Not Found' });
    });
  });

  describe('createUser', () => {
    it('should create new user', (done) => {
      const newUser = { name: 'Dave', email: 'dave@example.com', role: 'user' as const };
      const createdUser = { id: 4, ...newUser };
      
      service.createUser(newUser).subscribe(user => {
        expect(user).toEqual(createdUser);
        expect(user.id).toBe(4);
        done();
      });
      
      const req = httpMock.expectOne('/api/users');
      expect(req.request.method).toBe('POST');
      expect(req.request.body).toEqual(newUser);
      req.flush(createdUser);
    });

    it('should invalidate cache after creating user', (done) => {
      // First populate cache
      service.getUsers().subscribe(() => {
        const newUser = { name: 'Dave', email: 'dave@example.com', role: 'user' as const };
        
        // Create user
        service.createUser(newUser).subscribe(() => {
          // Cache should be invalidated
          // Next getUsers call should fetch from API
          service.getUsers().subscribe(() => {
            done();
          });
          
          const req2 = httpMock.expectOne('/api/users');
          req2.flush([...mockUsers, { id: 4, ...newUser }]);
        });
        
        const createReq = httpMock.expectOne('/api/users');
        createReq.flush({ id: 4, ...newUser });
      });
      
      const req1 = httpMock.expectOne('/api/users');
      req1.flush(mockUsers);
    });

    it('should handle validation errors', (done) => {
      const invalidUser = { name: '', email: 'invalid', role: 'user' as const };
      
      service.createUser(invalidUser).subscribe({
        next: () => fail('should have failed'),
        error: (error) => {
          expect(error.message).toContain('400');
          done();
        }
      });
      
      const req = httpMock.expectOne('/api/users');
      req.flush({ error: 'Validation failed' }, { status: 400, statusText: 'Bad Request' });
    });
  });

  describe('updateUser', () => {
    it('should update existing user', (done) => {
      const userId = 1;
      const updates = { name: 'Alice Updated' };
      const updatedUser = { ...mockUsers[0], ...updates };
      
      service.updateUser(userId, updates).subscribe(user => {
        expect(user.name).toBe('Alice Updated');
        expect(user.id).toBe(userId);
        done();
      });
      
      const req = httpMock.expectOne(`/api/users/${userId}`);
      expect(req.request.method).toBe('PUT');
      expect(req.request.body).toEqual(updates);
      req.flush(updatedUser);
    });

    it('should update cache after update', (done) => {
      // Populate cache first
      service.getUsers().subscribe(() => {
        const userId = 1;
        const updates = { name: 'Alice Updated' };
        const updatedUser = { ...mockUsers[0], ...updates };
        
        // Update user
        service.updateUser(userId, updates).subscribe(() => {
          // Get users again - should use updated cache
          service.getUsers().subscribe(users => {
            expect(users[0].name).toBe('Alice Updated');
            done();
          });
        });
        
        const updateReq = httpMock.expectOne(`/api/users/${userId}`);
        updateReq.flush(updatedUser);
      });
      
      const req = httpMock.expectOne('/api/users');
      req.flush(mockUsers);
    });
  });

  describe('deleteUser', () => {
    it('should delete user', (done) => {
      const userId = 1;
      
      service.deleteUser(userId).subscribe(() => {
        // Success - no response body expected
        done();
      });
      
      const req = httpMock.expectOne(`/api/users/${userId}`);
      expect(req.request.method).toBe('DELETE');
      req.flush(null);
    });

    it('should update cache after deletion', (done) => {
      // Populate cache
      service.getUsers().subscribe(() => {
        const userId = 1;
        
        // Delete user
        service.deleteUser(userId).subscribe(() => {
          // Cache should be updated
          service.getUsers().subscribe(users => {
            expect(users.length).toBe(2);
            expect(users.find(u => u.id === userId)).toBeUndefined();
            done();
          });
        });
        
        const deleteReq = httpMock.expectOne(`/api/users/${userId}`);
        deleteReq.flush(null);
      });
      
      const req = httpMock.expectOne('/api/users');
      req.flush(mockUsers);
    });
  });

  describe('Cache Management', () => {
    it('should clear cache manually', (done) => {
      // Populate cache
      service.getUsers().subscribe(() => {
        // Clear cache
        service.clearCache();
        
        // Next call should fetch from API
        service.getUsers().subscribe(() => {
          done();
        });
        
        const req2 = httpMock.expectOne('/api/users');
        req2.flush(mockUsers);
      });
      
      const req1 = httpMock.expectOne('/api/users');
      req1.flush(mockUsers);
    });
  });
});
```

**Testing Best Practices:**
1. **Arrange-Act-Assert**: Clear test structure
2. **Mock HTTP**: Use HttpClientTestingModule
3. **Async Testing**: Use done() callback or async/await
4. **Edge Cases**: Test errors, retries, edge conditions
5. **Cleanup**: Clear state between tests
6. **Coverage**: Test all public methods and branches

---

## Architecture & Best Practices

### Q14: Design a scalable feature module architecture (Asked at: Amazon, Thoughtworks)

**Question:** Design a scalable, maintainable architecture for a large Angular application with multiple feature modules, shared services, and lazy loading.

**Implementation:**

```typescript
/**
 * RECOMMENDED ARCHITECTURE for large Angular applications
 * 
 * Directory Structure:
 * 
 * src/
 * ├── app/
 * │   ├── core/                    # Singleton services, guards, interceptors
 * │   │   ├── auth/
 * │   │   │   ├── auth.service.ts
 * │   │   │   ├── auth.guard.ts
 * │   │   │   └── auth.interceptor.ts
 * │   │   ├── services/
 * │   │   │   ├── api.service.ts
 * │   │   │   ├── logger.service.ts
 * │   │   │   └── error-handler.service.ts
 * │   │   └── core.config.ts
 * │   │
 * │   ├── shared/                  # Reusable components, directives, pipes
 * │   │   ├── components/
 * │   │   │   ├── button/
 * │   │   │   ├── modal/
 * │   │   │   └── table/
 * │   │   ├── directives/
 * │   │   │   ├── highlight.directive.ts
 * │   │   │   └── tooltip.directive.ts
 * │   │   ├── pipes/
 * │   │   │   ├── format-date.pipe.ts
 * │   │   │   └── truncate.pipe.ts
 * │   │   └── utils/
 * │   │       ├── validators.ts
 * │   │       └── helpers.ts
 * │   │
 * │   ├── features/                # Feature modules (lazy-loaded)
 * │   │   ├── dashboard/
 * │   │   │   ├── components/
 * │   │   │   ├── services/
 * │   │   │   ├── dashboard.routes.ts
 * │   │   │   └── dashboard.component.ts
 * │   │   ├── users/
 * │   │   │   ├── components/
 * │   │   │   │   ├── user-list/
 * │   │   │   │   ├── user-detail/
 * │   │   │   │   └── user-form/
 * │   │   │   ├── services/
 * │   │   │   │   └── user.service.ts
 * │   │   │   ├── models/
 * │   │   │   │   └── user.model.ts
 * │   │   │   ├── state/
 * │   │   │   │   └── user.state.ts
 * │   │   │   ├── users.routes.ts
 * │   │   │   └── users.component.ts
 * │   │   └── products/
 * │   │       ├── components/
 * │   │       ├── services/
 * │   │       ├── products.routes.ts
 * │   │       └── products.component.ts
 * │   │
 * │   ├── layout/                  # Layout components
 * │   │   ├── header/
 * │   │   ├── footer/
 * │   │   ├── sidebar/
 * │   │   └── main-layout/
 * │   │
 * │   ├── app.component.ts
 * │   ├── app.routes.ts
 * │   └── app.config.ts
 * │
 * ├── assets/
 * ├── environments/
 * └── main.ts
 */

// ====================================
// CORE MODULE EXAMPLE
// ====================================

// core/services/api.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

/**
 * Base API service for all HTTP requests
 * Provides consistent API interaction patterns
 */
@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private http = inject(HttpClient);
  private baseUrl = environment.apiUrl;

  /**
   * GET request
   */
  get<T>(endpoint: string, params?: any): Observable<T> {
    return this.http.get<T>(`${this.baseUrl}${endpoint}`, {
      params: this.buildHttpParams(params)
    });
  }

  /**
   * POST request
   */
  post<T>(endpoint: string, body: any): Observable<T> {
    return this.http.post<T>(`${this.baseUrl}${endpoint}`, body);
  }

  /**
   * PUT request
   */
  put<T>(endpoint: string, body: any): Observable<T> {
    return this.http.put<T>(`${this.baseUrl}${endpoint}`, body);
  }

  /**
   * DELETE request
   */
  delete<T>(endpoint: string): Observable<T> {
    return this.http.delete<T>(`${this.baseUrl}${endpoint}`);
  }

  /**
   * Build HTTP params from object
   */
  private buildHttpParams(params?: any): HttpParams {
    let httpParams = new HttpParams();
    
    if (params) {
      Object.keys(params).forEach(key => {
        if (params[key] !== null && params[key] !== undefined) {
          httpParams = httpParams.set(key, params[key].toString());
        }
      });
    }
    
    return httpParams;
  }
}

// core/auth/auth.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';
import { catchError, throwError } from 'rxjs';

/**
 * Authentication interceptor
 * Adds auth token to all requests
 */
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();
  
  // Clone request and add authorization header
  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }
  
  return next(req).pipe(
    catchError(error => {
      if (error.status === 401) {
        authService.logout();
      }
      return throwError(() => error);
    })
  );
};

// ====================================
// SHARED MODULE EXAMPLE
// ====================================

// shared/components/button/button.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-button',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button
      [type]="type"
      [disabled]="disabled || loading"
      [class]="'btn btn-' + variant + ' ' + size"
      (click)="handleClick($event)">
      @if (loading) {
        <span class="spinner"></span>
      }
      <ng-content></ng-content>
    </button>
  `,
  styles: [`
    .btn {
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.2s;
    }
    .btn-primary { background: #2196f3; color: white; }
    .btn-secondary { background: #757575; color: white; }
    .btn-danger { background: #f44336; color: white; }
    .btn:disabled { opacity: 0.6; cursor: not-allowed; }
    .spinner {
      display: inline-block;
      width: 12px;
      height: 12px;
      border: 2px solid white;
      border-top-color: transparent;
      border-radius: 50%;
      animation: spin 0.6s linear infinite;
      margin-right: 8px;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
  `]
})
export class ButtonComponent {
  @Input() type: 'button' | 'submit' | 'reset' = 'button';
  @Input() variant: 'primary' | 'secondary' | 'danger' = 'primary';
  @Input() size: 'small' | 'medium' | 'large' = 'medium';
  @Input() disabled = false;
  @Input() loading = false;
  @Output() clicked = new EventEmitter<MouseEvent>();

  handleClick(event: MouseEvent): void {
    if (!this.disabled && !this.loading) {
      this.clicked.emit(event);
    }
  }
}

// ====================================
// FEATURE MODULE EXAMPLE
// ====================================

// features/users/services/user-facade.service.ts
import { Injectable, inject, signal, computed } from '@angular/core';
import { ApiService } from '../../../core/services/api.service';
import { User } from '../models/user.model';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

/**
 * Facade service for user feature
 * Encapsulates state management and business logic
 * Provides clean API for components
 */
@Injectable({
  providedIn: 'root'
})
export class UserFacadeService {
  private apiService = inject(ApiService);
  
  // State
  private usersSignal = signal<User[]>([]);
  private loadingSignal = signal(false);
  private errorSignal = signal<string | null>(null);
  
  // Selectors
  readonly users = this.usersSignal.asReadonly();
  readonly loading = this.loadingSignal.asReadonly();
  readonly error = this.errorSignal.asReadonly();
  
  // Derived state
  readonly userCount = computed(() => this.usersSignal().length);
  readonly activeUsers = computed(() => 
    this.usersSignal().filter(u => u.status === 'active')
  );

  /**
   * Load all users
   */
  loadUsers(): void {
    this.loadingSignal.set(true);
    this.errorSignal.set(null);
    
    this.apiService.get<User[]>('/users').pipe(
      tap(users => {
        this.usersSignal.set(users);
        this.loadingSignal.set(false);
      })
    ).subscribe({
      error: (error) => {
        this.errorSignal.set(error.message);
        this.loadingSignal.set(false);
      }
    });
  }

  /**
   * Get user by ID
   */
  getUserById(id: number): Observable<User> {
    return this.apiService.get<User>(`/users/${id}`);
  }

  /**
   * Create user
   */
  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.apiService.post<User>('/users', user).pipe(
      tap(newUser => {
        this.usersSignal.update(users => [...users, newUser]);
      })
    );
  }

  /**
   * Update user
   */
  updateUser(id: number, updates: Partial<User>): Observable<User> {
    return this.apiService.put<User>(`/users/${id}`, updates).pipe(
      tap(updatedUser => {
        this.usersSignal.update(users =>
          users.map(u => u.id === id ? updatedUser : u)
        );
      })
    );
  }

  /**
   * Delete user
   */
  deleteUser(id: number): Observable<void> {
    return this.apiService.delete<void>(`/users/${id}`).pipe(
      tap(() => {
        this.usersSignal.update(users =>
          users.filter(u => u.id !== id)
        );
      })
    );
  }
}

// features/users/users.routes.ts
import { Routes } from '@angular/router';
import { authGuard } from '../../core/auth/auth.guard';

export const USERS_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => import('./components/user-list/user-list.component')
      .then(m => m.UserListComponent),
    canActivate: [authGuard]
  },
  {
    path: ':id',
    loadComponent: () => import('./components/user-detail/user-detail.component')
      .then(m => m.UserDetailComponent),
    canActivate: [authGuard]
  },
  {
    path: ':id/edit',
    loadComponent: () => import('./components/user-form/user-form.component')
      .then(m => m.UserFormComponent),
    canActivate: [authGuard],
    data: { mode: 'edit' }
  }
];

// ====================================
// APP CONFIGURATION
// ====================================

// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { routes } from './app.routes';
import { authInterceptor } from './core/auth/auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(
      routes,
      withComponentInputBinding() // Bind route params to @Input()
    ),
    provideHttpClient(
      withInterceptors([authInterceptor])
    )
  ]
};

// app.routes.ts
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },
  {
    path: 'dashboard',
    loadComponent: () => import('./features/dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  },
  {
    path: 'users',
    loadChildren: () => import('./features/users/users.routes')
      .then(m => m.USERS_ROUTES)
  },
  {
    path: 'products',
    loadChildren: () => import('./features/products/products.routes')
      .then(m => m.PRODUCTS_ROUTES)
  },
  {
    path: '**',
    loadComponent: () => import('./shared/components/not-found/not-found.component')
      .then(m => m.NotFoundComponent)
  }
];
```

**Architecture Principles:**
1. **Separation of Concerns**: Core, Shared, Features
2. **Lazy Loading**: Feature modules loaded on demand
3. **Facade Pattern**: Clean API for components
4. **Smart/Dumb Components**: Container vs Presentational
5. **Single Responsibility**: Each module has one purpose
6. **DRY**: Shared code in shared module
7. **Testability**: Services injected, easy to mock
8. **Scalability**: Easy to add new features

---

## Summary

This document covered **14 real interview questions** from top companies including:

- **Google**: Signals cart, async route guards, comprehensive testing
- **Microsoft**: Standalone migration, multi-provider pattern
- **Amazon**: Virtual scrolling, dynamic forms, architecture
- **Meta**: OnPush optimization, debounced search
- **Netflix**: Manual change detection, OnPush strategies
- **Uber**: State management with Signals
- **Airbnb**: Complex route guards
- **Shopify**: Hierarchical injectors
- **Stripe**: Plugin system
- **Salesforce**: Dynamic forms with async validators
- **Spotify**: Signals-based state
- **Thoughtworks**: Module architecture

**Key Topics Covered:**
- ✅ Signals & Reactive Programming
- ✅ Standalone Components & Modern APIs
- ✅ RxJS & Observables (debounce, switchMap, retry)
- ✅ Performance Optimization (Virtual Scrolling, OnPush)
- ✅ Dependency Injection (InjectionToken, Multi-Providers)
- ✅ Change Detection (NgZone, Manual CD)
- ✅ Routing & Guards (Async validation, permissions)
- ✅ Forms & Validation (Dynamic forms, async validators)
- ✅ State Management (Signals, undo/redo, persistence)
- ✅ Testing (Unit tests, mocking, async testing)
- ✅ Architecture (Feature modules, facades, scalability)

**Interview Preparation Tips:**
1. Practice implementing features from scratch
2. Understand the "why" behind each pattern
3. Be ready to discuss trade-offs and alternatives
4. Know when to use RxJS vs Signals
5. Understand performance implications
6. Practice explaining code decisions
7. Be familiar with testing strategies
8. Know Angular best practices and patterns

---

**Additional Resources:**
- [Angular Official Docs](https://angular.dev)
- [RxJS Documentation](https://rxjs.dev)
- [Angular GitHub Discussions](https://github.com/angular/angular/discussions)
- [Angular Blog](https://blog.angular.io)
