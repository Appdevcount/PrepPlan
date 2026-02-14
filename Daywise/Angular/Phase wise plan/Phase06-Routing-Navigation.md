# Phase 6: Routing & Navigation

> Routing is what makes Angular a Single Page Application (SPA). Instead of loading entirely new HTML pages from a server, Angular swaps components in and out based on the URL — making navigation feel instant. This phase teaches you everything about Angular's powerful router.

---

## 6.1 What is Routing and Why Do We Need It?

### The Problem Without Routing

Imagine an app with these pages: Home, About, Products, Contact.

**Traditional websites (without SPA):**
```
User clicks "About" link
  → Browser sends request to server
    → Server returns about.html (FULL page)
      → Browser renders entire page from scratch
        → All JavaScript/CSS reloads
          → SLOW! (300ms-2s per navigation)
```

**Angular SPA with Routing:**
```
User clicks "About" link
  → Angular intercepts the click (no server request!)
    → URL changes to /about
      → Angular swaps the component in <router-outlet>
        → Only the changed part of the page re-renders
          → FAST! (< 50ms, feels instant)
```

**Key insight:** The browser NEVER actually leaves `index.html`. Angular just changes what's displayed inside it.

---

## 6.2 Setting Up Routing

### Step 1: Create a Project with Routing

```bash
# When creating a new project, say YES to routing
ng new my-app
# ? Would you like to add Angular routing? YES

# Or add routing to an existing project
ng generate module app-routing --flat --module=app
```

### Step 2: Understand the Routing Module

```typescript
// app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

// Import the components you want to route to
import { HomeComponent } from './home/home.component';
import { AboutComponent } from './about/about.component';
import { ProductsComponent } from './products/products.component';
import { ContactComponent } from './contact/contact.component';
import { NotFoundComponent } from './not-found/not-found.component';

// Define your routes — this is the "URL → Component" mapping
const routes: Routes = [
  { path: '', component: HomeComponent },              // localhost:4200/
  { path: 'about', component: AboutComponent },         // localhost:4200/about
  { path: 'products', component: ProductsComponent },   // localhost:4200/products
  { path: 'contact', component: ContactComponent },     // localhost:4200/contact
  { path: '**', component: NotFoundComponent }          // Any other URL → 404 page
];

@NgModule({
  // forRoot() = register routes at the ROOT level of the app
  // This should only be called ONCE in the entire app
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]  // Makes router directives available throughout the app
})
export class AppRoutingModule { }
```

**Explanation of each route property:**

| Property | What it does | Example |
|---|---|---|
| `path` | The URL segment (WITHOUT leading `/`) | `'about'` → `/about` |
| `component` | Which component to display for this path | `AboutComponent` |
| `''` | Empty path = the default/home route | Matches `/` |
| `'**'` | Wildcard = matches ANY unmatched URL | 404 page |

**Important rules:**
- Route order MATTERS — Angular uses the FIRST match. Put specific routes before wildcards.
- The `**` wildcard route should ALWAYS be the LAST route.
- Paths do NOT start with `/`.

### Step 3: Add `<router-outlet>` to Your Template

```html
<!-- app.component.html -->
<nav>
  <a routerLink="/">Home</a>
  <a routerLink="/about">About</a>
  <a routerLink="/products">Products</a>
  <a routerLink="/contact">Contact</a>
</nav>

<!-- This is WHERE routed components will appear -->
<router-outlet></router-outlet>

<footer>
  <p>My App Footer</p>
</footer>
```

**How this works:**
```
When URL is /about:

<nav>...</nav>           ← Always visible
<router-outlet>
  <app-about></app-about>  ← Angular puts AboutComponent HERE
</router-outlet>
<footer>...</footer>     ← Always visible
```

The nav and footer stay. Only the content inside `<router-outlet>` changes.

---

## 6.3 Navigation — Links and Programmatic

### 6.3.1 `routerLink` — Template Navigation

```html
<!-- Basic navigation -->
<a routerLink="/about">About Us</a>

<!-- With routerLinkActive — adds CSS class to active link -->
<nav>
  <a routerLink="/"
     routerLinkActive="active"
     [routerLinkActiveOptions]="{ exact: true }">Home</a>

  <a routerLink="/about"
     routerLinkActive="active">About</a>

  <a routerLink="/products"
     routerLinkActive="active">Products</a>

  <a routerLink="/contact"
     routerLinkActive="active">Contact</a>
</nav>
```

```css
/* Style for the active link */
.active {
  color: #dd0031;
  font-weight: bold;
  border-bottom: 2px solid #dd0031;
}
```

**Why `routerLink` instead of `href`?**
```html
<!-- DON'T DO THIS — it causes a full page reload! -->
<a href="/about">About</a>

<!-- DO THIS — Angular intercepts and handles navigation without reload -->
<a routerLink="/about">About</a>
```

**`routerLinkActiveOptions: { exact: true }`:**
- Without `exact: true`, the Home link (`/`) would be active for ALL routes (because `/about` contains `/`)
- With `exact: true`, the link is only active when the URL matches EXACTLY

### 6.3.2 Programmatic Navigation

Sometimes you need to navigate from TypeScript code (after form submission, after login, etc.):

```typescript
import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  template: `
    <button (click)="onLogin()">Login</button>
  `
})
export class LoginComponent {

  // Inject the Router service
  constructor(private router: Router) { }

  onLogin(): void {
    // ... perform login logic ...

    // Navigate to dashboard after successful login
    this.router.navigate(['/dashboard']);

    // Navigate with route parameters
    this.router.navigate(['/products', 42]);  // → /products/42

    // Navigate with query parameters
    this.router.navigate(['/products'], {
      queryParams: { category: 'electronics', page: 1 }
    });
    // → /products?category=electronics&page=1

    // Navigate relative to current route
    this.router.navigate(['details'], { relativeTo: this.route });
  }
}
```

---

## 6.4 Route Parameters

### 6.4.1 Path Parameters (`:id`)

Used for identifying a specific resource (product, user, article).

```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: 'products', component: ProductListComponent },
  { path: 'products/:id', component: ProductDetailComponent },  // :id is a parameter
  { path: 'users/:userId/posts/:postId', component: PostDetailComponent }  // Multiple params
];
```

**Reading route parameters in a component:**

```typescript
// product-detail.component.ts
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'app-product-detail',
  template: `
    <h2>Product Detail</h2>
    <p>Product ID: {{ productId }}</p>
  `
})
export class ProductDetailComponent implements OnInit {
  productId: string = '';

  // ActivatedRoute gives access to route information
  constructor(private route: ActivatedRoute) { }

  ngOnInit(): void {
    // --- Method 1: Snapshot (reads once) ---
    // Use when: the component is destroyed and recreated for each route change
    this.productId = this.route.snapshot.paramMap.get('id') || '';

    // --- Method 2: Observable (reacts to changes) ---
    // Use when: the component stays alive but the parameter changes
    // Example: navigating from /products/1 to /products/2 while on the same page
    this.route.paramMap.subscribe(params => {
      this.productId = params.get('id') || '';
      // Fetch new product data based on the new ID
      this.loadProduct(this.productId);
    });
  }

  loadProduct(id: string): void {
    // Call service to fetch product by ID
    console.log('Loading product:', id);
  }
}
```

**Navigating with parameters:**
```html
<!-- In template -->
<a [routerLink]="['/products', product.id]">{{ product.name }}</a>
<!-- Result: /products/42 -->
```

```typescript
// In code
this.router.navigate(['/products', 42]);
```

**When to use Snapshot vs Observable:**

| Scenario | Use | Why |
|---|---|---|
| Navigate to `/products/1` from another page | Snapshot | Component is freshly created |
| Navigate from `/products/1` to `/products/2` (same route, different param) | Observable | Component is NOT destroyed — Angular reuses it |
| Safe default | Observable | Works in ALL cases |

---

### 6.4.2 Query Parameters (`?key=value`)

Used for optional, non-identifying data (filters, sorting, pagination).

```typescript
// Navigating WITH query parameters
// Template approach:
```

```html
<a [routerLink]="['/products']"
   [queryParams]="{ category: 'laptops', sort: 'price', page: 1 }">
  Laptops (sorted by price)
</a>
<!-- Result: /products?category=laptops&sort=price&page=1 -->

<!-- Preserve query params when navigating to another route -->
<a [routerLink]="['/products', 1]"
   queryParamsHandling="preserve">
  Product 1 (keeps existing query params)
</a>

<!-- Merge new query params with existing ones -->
<a [routerLink]="['/products']"
   [queryParams]="{ page: 2 }"
   queryParamsHandling="merge">
  Page 2 (adds page=2 to existing params)
</a>
```

```typescript
// Programmatic approach:
this.router.navigate(['/products'], {
  queryParams: { category: 'laptops', sort: 'price', page: 1 }
});

// Reading query parameters:
export class ProductListComponent implements OnInit {
  category = '';
  sortBy = '';
  page = 1;

  constructor(private route: ActivatedRoute) { }

  ngOnInit(): void {
    // Snapshot
    this.category = this.route.snapshot.queryParamMap.get('category') || '';

    // Observable (reacts to changes)
    this.route.queryParamMap.subscribe(params => {
      this.category = params.get('category') || '';
      this.sortBy = params.get('sort') || 'name';
      this.page = Number(params.get('page')) || 1;
      this.loadProducts();
    });
  }
}
```

**Path Params vs Query Params — when to use which:**

| Use Case | Type | Example |
|---|---|---|
| Identify a specific resource | Path param | `/products/42` |
| Required for the route to work | Path param | `/users/5/posts/10` |
| Optional filters | Query param | `/products?category=laptops` |
| Pagination | Query param | `/products?page=2&limit=20` |
| Sorting | Query param | `/products?sort=price&order=asc` |
| Search | Query param | `/search?q=angular` |

---

### 6.4.3 Route Data (Static Data)

Pass static data to a route:

```typescript
const routes: Routes = [
  {
    path: 'about',
    component: AboutComponent,
    data: { title: 'About Us', showBanner: true }
  },
  {
    path: 'dashboard',
    component: DashboardComponent,
    data: { title: 'Dashboard', roles: ['admin', 'manager'] }
  }
];
```

```typescript
// Reading route data
export class AboutComponent implements OnInit {
  pageTitle = '';

  constructor(private route: ActivatedRoute) { }

  ngOnInit(): void {
    this.pageTitle = this.route.snapshot.data['title'];
    // or
    this.route.data.subscribe(data => {
      this.pageTitle = data['title'];
    });
  }
}
```

---

## 6.5 Child Routes (Nested Routing)

Child routes create nested views — a component inside a component, each with its own routes.

**Real-world example:** A Settings page with sub-pages (Profile, Security, Notifications).

```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'settings',
    component: SettingsComponent,
    children: [
      { path: '', redirectTo: 'profile', pathMatch: 'full' },
      { path: 'profile', component: ProfileSettingsComponent },
      { path: 'security', component: SecuritySettingsComponent },
      { path: 'notifications', component: NotificationSettingsComponent }
    ]
  }
];
```

```html
<!-- settings.component.html -->
<div class="settings-layout">
  <nav class="settings-sidebar">
    <h2>Settings</h2>
    <a routerLink="profile" routerLinkActive="active">Profile</a>
    <a routerLink="security" routerLinkActive="active">Security</a>
    <a routerLink="notifications" routerLinkActive="active">Notifications</a>
  </nav>

  <div class="settings-content">
    <!-- Child routes render HERE (not in app.component's router-outlet!) -->
    <router-outlet></router-outlet>
  </div>
</div>
```

**How the URL maps:**

| URL | Components Rendered |
|---|---|
| `/settings` | Redirects to `/settings/profile` |
| `/settings/profile` | SettingsComponent → ProfileSettingsComponent |
| `/settings/security` | SettingsComponent → SecuritySettingsComponent |
| `/settings/notifications` | SettingsComponent → NotificationSettingsComponent |

**Key point:** The parent component (`SettingsComponent`) has its OWN `<router-outlet>` where child components render. The app's main `<router-outlet>` shows `SettingsComponent`.

```
<app-root>
  <router-outlet>              ← Main (renders SettingsComponent)
    <app-settings>
      <nav>sidebar links</nav>
      <router-outlet>          ← Child (renders ProfileSettingsComponent)
        <app-profile-settings></app-profile-settings>
      </router-outlet>
    </app-settings>
  </router-outlet>
</app-root>
```

---

## 6.6 Redirects

```typescript
const routes: Routes = [
  // Redirect empty path to /home
  { path: '', redirectTo: '/home', pathMatch: 'full' },

  { path: 'home', component: HomeComponent },

  // Redirect old URLs to new ones
  { path: 'about-us', redirectTo: '/about', pathMatch: 'full' },

  { path: 'about', component: AboutComponent },

  // Wildcard — catch everything else
  { path: '**', component: NotFoundComponent }
  // OR redirect wildcard to home:
  // { path: '**', redirectTo: '/home' }
];
```

**`pathMatch: 'full'` vs `pathMatch: 'prefix'`:**

```typescript
// pathMatch: 'full' — the ENTIRE URL must match the path
{ path: '', redirectTo: '/home', pathMatch: 'full' }
// '' matches ONLY '/' (exact empty path)

// pathMatch: 'prefix' (default) — the URL just needs to START with the path
{ path: '', redirectTo: '/home', pathMatch: 'prefix' }
// '' matches EVERYTHING (because every URL starts with empty string!)
// This would redirect ALL routes to /home — NOT what you want!

// RULE: Always use pathMatch: 'full' with empty path redirects
```

---

## 6.7 Route Guards — Protecting Routes

Guards are like security checkpoints. They decide whether a user can navigate to or away from a route.

### Types of Guards

| Guard | When it Runs | Purpose |
|---|---|---|
| `CanActivate` | Before entering a route | Block unauthorized users |
| `CanActivateChild` | Before entering child routes | Protect all children of a route |
| `CanDeactivate` | Before leaving a route | Warn about unsaved changes |
| `Resolve` | Before the route loads | Pre-fetch data |
| `CanLoad` | Before lazy-loading a module | Don't even download the module if unauthorized |

### 6.7.1 CanActivate — Protecting Routes

```bash
ng generate guard auth
# Select: CanActivate
```

```typescript
// auth.guard.ts
import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  constructor(
    private authService: AuthService,
    private router: Router
  ) { }

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {

    // Check if user is logged in
    if (this.authService.isLoggedIn()) {
      return true;  // Allow navigation
    }

    // Not logged in — redirect to login page
    // Save the attempted URL so we can redirect back after login
    this.router.navigate(['/login'], {
      queryParams: { returnUrl: state.url }
    });
    return false;  // Block navigation
  }
}
```

**Apply the guard to routes:**
```typescript
const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'home', component: HomeComponent },

  // Protected routes — require authentication
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuard]  // ← Guard applied here
  },
  {
    path: 'profile',
    component: ProfileComponent,
    canActivate: [AuthGuard]
  },

  // Protect ALL child routes at once
  {
    path: 'admin',
    component: AdminComponent,
    canActivate: [AuthGuard],
    canActivateChild: [AuthGuard],  // ← Protects all children too
    children: [
      { path: 'users', component: AdminUsersComponent },
      { path: 'settings', component: AdminSettingsComponent }
    ]
  }
];
```

**Simple AuthService for reference:**
```typescript
// auth.service.ts
import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private loggedIn = false;

  isLoggedIn(): boolean {
    return this.loggedIn;
  }

  login(username: string, password: string): boolean {
    // In real app: call API, validate credentials
    if (username === 'admin' && password === 'password') {
      this.loggedIn = true;
      return true;
    }
    return false;
  }

  logout(): void {
    this.loggedIn = false;
  }
}
```

### 6.7.2 CanDeactivate — Unsaved Changes Warning

```typescript
// can-deactivate.guard.ts
import { Injectable } from '@angular/core';
import { CanDeactivate } from '@angular/router';

// Interface that components must implement
export interface CanComponentDeactivate {
  canDeactivate: () => boolean;
}

@Injectable({ providedIn: 'root' })
export class UnsavedChangesGuard implements CanDeactivate<CanComponentDeactivate> {

  canDeactivate(component: CanComponentDeactivate): boolean {
    if (component.canDeactivate && !component.canDeactivate()) {
      // Ask the user if they really want to leave
      return confirm('You have unsaved changes. Do you really want to leave?');
    }
    return true;
  }
}
```

```typescript
// edit-form.component.ts
export class EditFormComponent implements CanComponentDeactivate {
  formDirty = false;

  onInputChange(): void {
    this.formDirty = true;
  }

  onSave(): void {
    // Save data...
    this.formDirty = false;
  }

  // This method is called by the guard
  canDeactivate(): boolean {
    return !this.formDirty;  // If form is dirty, return false (triggers confirmation)
  }
}
```

```typescript
// Apply in routes
{
  path: 'edit/:id',
  component: EditFormComponent,
  canDeactivate: [UnsavedChangesGuard]
}
```

### 6.7.3 Resolve — Pre-fetching Data

```typescript
// product-resolver.service.ts
import { Injectable } from '@angular/core';
import { Resolve, ActivatedRouteSnapshot } from '@angular/router';
import { Observable } from 'rxjs';
import { ProductService } from './product.service';
import { Product } from './product.model';

@Injectable({ providedIn: 'root' })
export class ProductResolver implements Resolve<Product> {

  constructor(private productService: ProductService) { }

  resolve(route: ActivatedRouteSnapshot): Observable<Product> {
    const id = route.paramMap.get('id')!;
    return this.productService.getProduct(id);
    // Angular waits for this Observable to complete BEFORE rendering the component
  }
}
```

```typescript
// Apply in routes
{
  path: 'products/:id',
  component: ProductDetailComponent,
  resolve: { product: ProductResolver }  // 'product' is the key to access the data
}
```

```typescript
// Access resolved data in the component
export class ProductDetailComponent implements OnInit {
  product!: Product;

  constructor(private route: ActivatedRoute) { }

  ngOnInit(): void {
    // Data is already loaded — no loading spinner needed!
    this.product = this.route.snapshot.data['product'];
  }
}
```

**Why use Resolve?**
- Without Resolve: Component renders immediately → shows loading spinner → data arrives → content appears
- With Resolve: Angular waits for data → then renders the component with data already available
- Better user experience for small data loads

### 6.7.4 Functional Guards (Angular 14+)

Newer Angular versions support simpler functional guards:

```typescript
// Functional guard (no class needed!)
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true;
  }

  router.navigate(['/login']);
  return false;
};

// Usage in routes — same as before
{
  path: 'dashboard',
  component: DashboardComponent,
  canActivate: [authGuard]
}
```

**Why functional guards?**
- Less boilerplate (no class, no implements)
- Easier to write and read
- Recommended approach in modern Angular

---

## 6.8 Lazy Loading — Load Modules On Demand

### The Problem Without Lazy Loading

```
User visits homepage
  → Browser downloads ALL JavaScript for the ENTIRE app
    → Home, About, Products (100 products), Admin panel, Settings, etc.
      → 2MB+ of JavaScript to parse and execute
        → SLOW initial load (3-5 seconds on slow networks)
```

### The Solution: Lazy Loading

```
User visits homepage
  → Browser downloads JavaScript for HOME only (~200KB)
    → App loads fast (< 1 second)
      → User clicks "Products"
        → Browser downloads Products module (~300KB)
          → Products page appears
```

**Each feature loads ONLY when the user navigates to it.**

### Setting Up Lazy Loading

```bash
# Generate a feature module with routing and lazy loading setup
ng generate module products --route products --module app
```

This creates:
```
src/app/products/
├── products.module.ts
├── products-routing.module.ts
└── products.component.ts/html/css/spec
```

And automatically updates `app-routing.module.ts`:

```typescript
// app-routing.module.ts
const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'products',
    // loadChildren: Lazy load the module ONLY when user navigates to /products
    loadChildren: () => import('./products/products.module')
      .then(m => m.ProductsModule)
  },
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.module')
      .then(m => m.AdminModule)
  }
];
```

**How it works step by step:**

1. App starts → `ProductsModule` is NOT loaded
2. User clicks "Products" link
3. Angular sees `loadChildren` → triggers dynamic `import()`
4. Browser downloads the Products bundle (separate JS file)
5. Angular registers `ProductsModule` and its routes
6. ProductsComponent renders

**The feature module's routes use `forChild()` (not `forRoot()`):**

```typescript
// products-routing.module.ts
const routes: Routes = [
  { path: '', component: ProductListComponent },        // /products
  { path: ':id', component: ProductDetailComponent }     // /products/42
];

@NgModule({
  imports: [RouterModule.forChild(routes)],  // forChild, NOT forRoot!
  exports: [RouterModule]
})
export class ProductsRoutingModule { }
```

**`forRoot()` vs `forChild()`:**

| Method | When to Use | How Many Times |
|---|---|---|
| `forRoot(routes)` | In the main `AppRoutingModule` | ONCE only |
| `forChild(routes)` | In feature modules | As many times as needed |

`forRoot()` sets up the Router service. `forChild()` only registers additional routes without creating a new Router instance.

### Standalone Component Lazy Loading (Angular 15+)

```typescript
// Even simpler — lazy load a single component (no module needed!)
const routes: Routes = [
  {
    path: 'products',
    loadComponent: () => import('./products/products.component')
      .then(c => c.ProductsComponent)
  }
];
```

---

## 6.9 Route Events — Tracking Navigation

Angular's router emits events during navigation. Useful for showing loading indicators.

```typescript
// app.component.ts
import { Component } from '@angular/core';
import { Router, NavigationStart, NavigationEnd, NavigationCancel, NavigationError } from '@angular/router';

@Component({
  selector: 'app-root',
  template: `
    <div class="loading-bar" *ngIf="isLoading"></div>
    <nav><!-- links --></nav>
    <router-outlet></router-outlet>
  `
})
export class AppComponent {
  isLoading = false;

  constructor(private router: Router) {
    this.router.events.subscribe(event => {
      if (event instanceof NavigationStart) {
        this.isLoading = true;    // Show loading bar
      }
      if (event instanceof NavigationEnd ||
          event instanceof NavigationCancel ||
          event instanceof NavigationError) {
        this.isLoading = false;   // Hide loading bar
      }
    });
  }
}
```

---

## 6.10 Complete Practical Example

Let's build a mini app with all routing concepts:

```typescript
// app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './login/login.component';
import { NotFoundComponent } from './not-found/not-found.component';
import { authGuard } from './guards/auth.guard';

const routes: Routes = [
  // Public routes
  { path: '', component: HomeComponent, data: { title: 'Home' } },
  { path: 'login', component: LoginComponent },

  // Lazy-loaded feature modules (protected)
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard.module').then(m => m.DashboardModule),
    canActivate: [authGuard]
  },
  {
    path: 'products',
    loadChildren: () => import('./products/products.module').then(m => m.ProductsModule)
  },

  // Redirects
  { path: 'home', redirectTo: '', pathMatch: 'full' },

  // 404 - must be last!
  { path: '**', component: NotFoundComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes, {
    scrollPositionRestoration: 'enabled',  // Scroll to top on navigation
    // enableTracing: true  // Uncomment to debug routing in console
  })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

```html
<!-- app.component.html -->
<header>
  <nav>
    <a routerLink="/" routerLinkActive="active"
       [routerLinkActiveOptions]="{ exact: true }">Home</a>
    <a routerLink="/products" routerLinkActive="active">Products</a>
    <a routerLink="/dashboard" routerLinkActive="active">Dashboard</a>

    <div class="auth-buttons">
      <a *ngIf="!isLoggedIn" routerLink="/login">Login</a>
      <button *ngIf="isLoggedIn" (click)="logout()">Logout</button>
    </div>
  </nav>
</header>

<main>
  <router-outlet></router-outlet>
</main>

<footer>
  <p>&copy; 2026 My Angular App</p>
</footer>
```

```typescript
// products-routing.module.ts (feature module)
const routes: Routes = [
  { path: '', component: ProductListComponent },
  { path: ':id', component: ProductDetailComponent }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class ProductsRoutingModule { }
```

```typescript
// product-list.component.ts
export class ProductListComponent {
  products = [
    { id: 1, name: 'Laptop', price: 999 },
    { id: 2, name: 'Phone', price: 699 },
    { id: 3, name: 'Tablet', price: 499 }
  ];
}
```

```html
<!-- product-list.component.html -->
<h2>Our Products</h2>
<div class="product-grid">
  <div *ngFor="let product of products" class="product-card">
    <h3>{{ product.name }}</h3>
    <p>${{ product.price }}</p>
    <!-- Navigate to product detail with route parameter -->
    <a [routerLink]="[product.id]">View Details</a>
  </div>
</div>
```

```typescript
// product-detail.component.ts
export class ProductDetailComponent implements OnInit {
  productId = '';

  constructor(private route: ActivatedRoute) { }

  ngOnInit(): void {
    this.route.paramMap.subscribe(params => {
      this.productId = params.get('id') || '';
    });
  }
}
```

```html
<!-- product-detail.component.html -->
<div>
  <h2>Product Details</h2>
  <p>Product ID: {{ productId }}</p>
  <a routerLink="/products">← Back to Products</a>
</div>
```

---

## 6.11 Summary

| Concept | What You Learned |
|---|---|
| SPA Routing | Navigate without page reloads |
| `RouterModule.forRoot()` | Set up routes in the root module |
| `<router-outlet>` | Placeholder where routed components render |
| `routerLink` | Navigate via template links |
| `routerLinkActive` | Highlight the active navigation link |
| `Router.navigate()` | Navigate programmatically from code |
| Path Parameters (`:id`) | Identify specific resources |
| Query Parameters | Pass optional filter/sort/page data |
| Child Routes | Nested views with nested `<router-outlet>` |
| Route Guards | Protect routes (auth, unsaved changes, etc.) |
| Lazy Loading | Load feature modules on demand for performance |
| `loadChildren` | Dynamic import for lazy-loaded modules |
| `loadComponent` | Lazy load standalone components |
| Route Events | Track navigation lifecycle for loading indicators |

---

**Next:** [Phase 7 — Forms (Template-Driven & Reactive)](./Phase07-Forms.md)
