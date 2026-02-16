# Phase 11: Modules & Standalone Components Architecture

> "Architecture is not about making code work today — it's about making code *changeable* tomorrow. The way you structure your Angular application determines whether adding feature #50 is as easy as feature #1, or whether it becomes a nightmare of circular dependencies and spaghetti imports." This phase teaches you how to design Angular apps that scale from 5 screens to 500.

---

## 11.1 Why Architecture Matters

### The Problem: What Happens Without a Plan

Imagine you are hired to add a feature to a 2-year-old Angular app. You open the codebase and see this:

```
src/
  app/
    app.component.ts         ← 1,400 lines
    app.module.ts            ← 200+ imports, everything in one file
    home.component.ts
    products.component.ts
    product-detail.component.ts
    product-card.component.ts
    users.component.ts
    user-profile.component.ts
    user-card.component.ts
    orders.component.ts
    order-detail.component.ts
    auth.component.ts
    login.component.ts
    register.component.ts
    dashboard.component.ts
    admin.component.ts
    reports.component.ts
    header.component.ts
    footer.component.ts
    sidebar.component.ts
    breadcrumb.component.ts
    ... (60 more files, all in one flat folder)
```

**What goes wrong:**

| Problem | Real-World Impact |
|---------|-----------------|
| No grouping by feature | To find "product" code you search through 80+ files |
| Everything in AppModule | One change breaks unrelated features |
| No lazy loading | Users download ALL code even for pages they never visit |
| Shared utils duplicated | `format-date.pipe.ts` exists in 5 different places |
| No clear boundaries | A "user" service is imported in the "reports" component directly |
| One team changes everything | Team A and Team B constantly merge conflicts in `app.module.ts` |

### Real-World Analogy: Building a House Without Blueprints

```
WITHOUT ARCHITECTURE (no blueprint):
+------------------------------------------+
|  ONE BIG ROOM                            |
|                                          |
|  Kitchen equipment HERE                  |
|  Bedroom furniture HERE                  |
|  Bathroom fixtures HERE                  |
|  Living room couch HERE                  |
|  Office desk HERE                        |
|  Everything tangled together             |
|                                          |
|  → To find the sink, search entire house |
|  → Moving the couch breaks the plumbing  |
|  → Can't add a new room without          |
|    demolishing existing walls            |
+------------------------------------------+

WITH ARCHITECTURE (proper blueprint):
+----------+  +----------+  +----------+
| Kitchen  |  | Bedroom  |  | Bathroom |
| - Sink   |  | - Bed    |  | - Sink   |
| - Stove  |  | - Desk   |  | - Toilet |
| - Fridge |  | - Lamp   |  | - Shower |
+----------+  +----------+  +----------+
     |               |            |
     +-------+-------+------------+
             |
         +--------+
         | Hallway|  ← shared space (like SharedModule)
         | (common|
         |  area) |
         +--------+

→ Each room has ONE purpose
→ Rooms are INDEPENDENT (moving bedroom furniture
  doesn't affect kitchen plumbing)
→ Adding a new room = add it alongside existing ones
```

### Small App vs Enterprise App — Why Structure Matters

```
SMALL APP (1-3 developers, < 20 screens):
----------------------------------------
AppModule
  ├── HomeComponent
  ├── AboutComponent
  └── ContactComponent

→ Fine to keep everything in AppModule
→ Everyone knows where everything is
→ Lazy loading: optional
→ Shared module: overkill

MEDIUM APP (3-8 developers, 20-60 screens):
--------------------------------------------
AppModule
  ├── AppRoutingModule
  ├── SharedModule         ← common reusables
  ├── CoreModule           ← singletons
  ├── HomeModule
  ├── ProductsModule (lazy loaded)
  └── UsersModule (lazy loaded)

→ Feature modules necessary
→ Lazy loading: important for performance
→ Team A works in ProductsModule, Team B in UsersModule
→ Minimal merge conflicts

ENTERPRISE APP (8+ developers, 60+ screens):
---------------------------------------------
AppModule
  ├── CoreModule
  ├── SharedModule
  ├── AuthModule (lazy loaded)
  ├── DashboardModule (lazy loaded)
  ├── ProductsModule (lazy loaded)
  │     ├── ProductListModule
  │     ├── ProductDetailModule
  │     └── ProductAdminModule
  ├── UsersModule (lazy loaded)
  ├── OrdersModule (lazy loaded)
  ├── ReportsModule (lazy loaded)
  └── AdminModule (lazy loaded)
        ├── AdminUsersModule
        └── AdminSettingsModule

→ Multiple nested feature modules
→ All routes lazy loaded
→ Clear team ownership per module
→ Shared contracts via SharedModule
→ Zero coupling between features
```

---

## 11.2 NgModules Deep Dive

### What is an NgModule?

An `@NgModule` is a class decorated with `@NgModule()` that tells Angular: "These are the pieces that belong together. Here is what they need, and here is what they make available to others."

Think of it as a **package declaration** — like how a Java package groups related classes, or how a Python module groups related functions.

### The @NgModule Anatomy

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HeaderComponent } from './core/header/header.component';
import { FooterComponent } from './core/footer/footer.component';
import { UserCardComponent } from './shared/user-card/user-card.component';
import { LoggingService } from './core/services/logging.service';
import { AuthService } from './core/services/auth.service';

@NgModule({

  // ─────────────────────────────────────────────────────────────
  // DECLARATIONS — Components, Directives, and Pipes that BELONG
  // to THIS module. Think: "Who lives in this apartment?"
  //
  // Rules:
  // → A component/directive/pipe can only be DECLARED in ONE module
  // → Declared items are only usable within this module UNLESS exported
  // → You MUST declare something before using it in a template
  // ─────────────────────────────────────────────────────────────
  declarations: [
    AppComponent,           // ← The root component (bootstrap entry point)
    HeaderComponent,        // ← Declared here = lives in AppModule
    FooterComponent,        // ← Declared here = lives in AppModule
    UserCardComponent,      // ← Declared here = can only use in AppModule templates
  ],

  // ─────────────────────────────────────────────────────────────
  // IMPORTS — Other NgModules whose EXPORTED declarations you
  // want to use in THIS module's templates.
  //
  // Think: "What external tools does this apartment subscribe to?"
  //
  // Rules:
  // → Only NgModules go here (not components/services directly)
  // → Importing a module makes its EXPORTS available in templates
  // → BrowserModule must be imported ONLY in the root AppModule
  // ─────────────────────────────────────────────────────────────
  imports: [
    BrowserModule,          // ← Provides *ngIf, *ngFor, AsyncPipe, etc.
                            //   Also sets up the browser platform
                            //   ONLY use in AppModule (not feature modules)
    FormsModule,            // ← Provides [(ngModel)], ngForm, ngModelGroup
    HttpClientModule,       // ← Provides HttpClient for API calls
    AppRoutingModule,       // ← Our routing configuration
  ],

  // ─────────────────────────────────────────────────────────────
  // EXPORTS — Declarations (or imported modules) you want to make
  // available to OTHER modules that import THIS module.
  //
  // Think: "What does this apartment share with the building?"
  //
  // Rules:
  // → Only EXPORTED items are usable by importing modules
  // → You can re-export entire modules (e.g., export CommonModule)
  // → Exported items MUST also be in declarations or imports
  // ─────────────────────────────────────────────────────────────
  exports: [
    UserCardComponent,      // ← Now OTHER modules can use <app-user-card>
    // AppComponent is NOT exported — it's the root, no one else needs it
    // HeaderComponent is NOT exported — only AppModule's template uses it
  ],

  // ─────────────────────────────────────────────────────────────
  // PROVIDERS — Services to register in the INJECTOR for this module.
  //
  // Think: "What services does this building's management office offer?"
  //
  // Rules:
  // → Services provided here are available to the ENTIRE app
  //   (in eagerly loaded modules) because Angular merges all
  //   root-level injectors
  // → Modern Angular: prefer providedIn: 'root' in the service itself
  // → In lazy-loaded feature modules: creates a CHILD injector
  //   (separate instance — see 11.6 for details)
  // ─────────────────────────────────────────────────────────────
  providers: [
    LoggingService,         // ← Available app-wide
    AuthService,            // ← Available app-wide
    // Modern approach: use providedIn: 'root' in the @Injectable decorator
    // and DON'T list services here at all
  ],

  // ─────────────────────────────────────────────────────────────
  // BOOTSTRAP — Which component(s) to render when the app starts.
  // Angular inserts the bootstrap component into index.html.
  //
  // Rules:
  // → ONLY the root AppModule has bootstrap
  // → Usually just [AppComponent]
  // → Angular looks for <app-root> in index.html
  // ─────────────────────────────────────────────────────────────
  bootstrap: [AppComponent]  // ← "Start the app by rendering AppComponent"
})
export class AppModule { }
```

### The Module Boundary Concept — Visualized

```
+══════════════════════════════════════════════════════╗
║  ProductsModule                                      ║
║                                                      ║
║  DECLARATIONS (private to this module):              ║
║  ┌────────────────┐  ┌───────────────────────┐       ║
║  │ProductListComp │  │ProductDetailComponent │       ║
║  └────────────────┘  └───────────────────────┘       ║
║  ┌────────────────┐  ┌───────────────────────┐       ║
║  │ProductCardComp │  │DiscountPipe           │       ║
║  └────────────────┘  └───────────────────────┘       ║
║                                                      ║
║  EXPORTS (visible to other modules that import me):  ║
║  ┌────────────────┐                                  ║
║  │ProductCardComp │  ← ONLY this one is shared       ║
║  └────────────────┘                                  ║
║                                                      ║
║  IMPORTS (tools I use in MY templates):              ║
║  ┌─────────────┐  ┌──────────┐  ┌───────────┐       ║
║  │CommonModule │  │FormsModule│  │SharedModule│      ║
║  └─────────────┘  └──────────┘  └───────────┘       ║
║                                                      ║
╚══════════════════════════════════════════════════════╝

If OrdersModule imports ProductsModule:
  ✅ Can use <app-product-card> in templates
  ❌ CANNOT use <app-product-list> (not exported)
  ❌ CANNOT use <app-product-detail> (not exported)
  ❌ CANNOT use DiscountPipe (not exported)
```

### Root Module (AppModule) vs Feature Modules

| Aspect | AppModule (Root) | Feature Module |
|--------|-----------------|----------------|
| Created by CLI? | Yes, auto-generated | You create it |
| Has `bootstrap`? | Yes (`[AppComponent]`) | No |
| Imports `BrowserModule`? | Yes (ONCE only) | No — use `CommonModule` |
| Eager vs Lazy? | Always eager (loads first) | Can be eager or lazy |
| Number per app? | Exactly ONE | As many as you need |
| Purpose | App initialization | Grouping related features |

---

## 11.3 Feature Modules

### What is a Feature Module and Why?

A **feature module** groups all the components, directives, pipes, and services related to a single feature of your application. It creates a clear boundary: everything related to "Products" lives in `ProductsModule`, everything related to "Users" lives in `UsersModule`.

**Analogy: Departments in a Company**

```
Acme Corporation
├── Engineering Department     → ProductsModule
│   ├── Engineers              → ProductComponents
│   ├── Designers              → ProductDirectives
│   └── Department tools       → ProductServices
│
├── HR Department              → UsersModule
│   ├── HR Managers            → UserComponents
│   └── HR tools               → UserServices
│
├── Reception (shared)         → SharedModule
│   └── Shared tools everyone  → Common components/pipes
│       uses: phone, printer
│
└── CEO office (core)          → CoreModule
    └── Company-wide policies  → App-wide singleton services
```

### Creating Feature Modules with CLI

```bash
# Generate a feature module with routing
ng generate module features/products --routing

# What this creates:
# src/app/features/products/
#   products.module.ts          ← The module class
#   products-routing.module.ts  ← Routing for this feature

# Generate components INSIDE the feature module
ng generate component features/products/product-list
ng generate component features/products/product-detail
ng generate component features/products/product-card

# The CLI automatically declares them in products.module.ts
```

### Complete Example: ProductsModule

```typescript
// src/app/features/products/products.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';     // ← NOT BrowserModule!
import { ReactiveFormsModule } from '@angular/forms';

import { ProductsRoutingModule } from './products-routing.module';
import { SharedModule } from '../../shared/shared.module';  // ← Use shared components

import { ProductListComponent } from './product-list/product-list.component';
import { ProductDetailComponent } from './product-detail/product-detail.component';
import { ProductCardComponent } from './product-card/product-card.component';
import { ProductFormComponent } from './product-form/product-form.component';
import { DiscountPipe } from './pipes/discount.pipe';
import { StockStatusDirective } from './directives/stock-status.directive';

@NgModule({
  declarations: [
    ProductListComponent,     // ← "Products owns this component"
    ProductDetailComponent,   // ← "Products owns this component"
    ProductCardComponent,     // ← "Products owns this component"
    ProductFormComponent,     // ← "Products owns this component"
    DiscountPipe,             // ← "Products owns this pipe"
    StockStatusDirective,     // ← "Products owns this directive"
  ],
  imports: [
    CommonModule,             // ← Provides *ngIf, *ngFor, AsyncPipe
                              //   (BrowserModule's re-exports for feature modules)
    ReactiveFormsModule,      // ← Provides FormBuilder, FormGroup, FormControl
    ProductsRoutingModule,    // ← This feature's routes
    SharedModule,             // ← Import shared components/pipes we need
  ],
  exports: [
    ProductCardComponent,     // ← Export so other modules can embed product cards
                              //   e.g., OrdersModule shows products in an order
    // ProductListComponent NOT exported — only accessible via router
    // ProductDetailComponent NOT exported — only accessible via router
    // DiscountPipe NOT exported — keep it private to Products feature
  ]
  // No providers here — ProductService uses providedIn: 'root'
  // No bootstrap here — only AppModule has bootstrap
})
export class ProductsModule { }
```

```typescript
// src/app/features/products/products-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { ProductListComponent } from './product-list/product-list.component';
import { ProductDetailComponent } from './product-detail/product-detail.component';

// Routes are RELATIVE to the parent route that loads this module
// If loaded at /products, then '' = /products, ':id' = /products/123
const routes: Routes = [
  {
    path: '',                         // ← Matches /products
    component: ProductListComponent
  },
  {
    path: ':id',                      // ← Matches /products/123
    component: ProductDetailComponent
  }
];

@NgModule({
  // forChild() — NOT forRoot()! Feature modules use forChild()
  // forRoot() registers the Router service (only once, in AppRoutingModule)
  // forChild() just registers these routes WITH the existing router
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]  // ← Export so ProductsModule can use router directives
})
export class ProductsRoutingModule { }
```

### Complete Example: UsersModule

```typescript
// src/app/features/users/users.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { UsersRoutingModule } from './users-routing.module';
import { SharedModule } from '../../shared/shared.module';

import { UserListComponent } from './user-list/user-list.component';
import { UserProfileComponent } from './user-profile/user-profile.component';
import { UserCardComponent } from './user-card/user-card.component';
import { UserAvatarComponent } from './user-avatar/user-avatar.component';
import { RoleBadgeDirective } from './directives/role-badge.directive';

@NgModule({
  declarations: [
    UserListComponent,      // ← Only accessible via router
    UserProfileComponent,   // ← Only accessible via router
    UserCardComponent,      // ← Exported — other modules can show user cards
    UserAvatarComponent,    // ← Exported — used in headers, comments, etc.
    RoleBadgeDirective,     // ← NOT exported — internal to Users feature
  ],
  imports: [
    CommonModule,
    FormsModule,
    UsersRoutingModule,
    SharedModule,
  ],
  exports: [
    UserCardComponent,      // ← Allow other features to embed user cards
    UserAvatarComponent,    // ← Allow header/comments to show avatars
  ]
})
export class UsersModule { }
```

### Declaring vs Importing vs Exporting — The Decision Table

```
For each item, ask these questions:

COMPONENT / DIRECTIVE / PIPE:
┌─────────────────────────────────────────────────────────────┐
│ Does it BELONG to this module (you're creating it here)?    │
│ → YES: Put it in declarations[]                             │
│                                                             │
│   Should other modules be able to USE it?                   │
│   → YES: Also put it in exports[]                           │
│   → NO: Only in declarations (private to this module)       │
└─────────────────────────────────────────────────────────────┘

NGMODULE (another module):
┌─────────────────────────────────────────────────────────────┐
│ Do you need to USE the exports of that module in THIS       │
│ module's templates?                                         │
│ → YES: Put it in imports[]                                  │
│                                                             │
│   Should importing modules ALSO get those exports?          │
│   → YES: Also put the imported module in exports[]          │
│          (this is called "re-exporting")                    │
│   → NO: Only in imports                                     │
└─────────────────────────────────────────────────────────────┘

SERVICE:
┌─────────────────────────────────────────────────────────────┐
│ Modern Angular: Use providedIn: 'root' in @Injectable       │
│ → Don't list in providers[] at all (tree-shakeable)         │
│                                                             │
│ Need module-scoped service (rare)?                          │
│ → Put in providers[] of the module                          │
│   (creates new instance, NOT the root instance)             │
└─────────────────────────────────────────────────────────────┘
```

---

## 11.4 Shared Module Pattern

### What is SharedModule For?

`SharedModule` is where you put things that are used across MULTIPLE features but don't belong to any single feature. It's the "commons" of your application.

**What goes in SharedModule:**

```
SharedModule contains:
  ✅ Common UI components (buttons, cards, modals, spinners, badges)
  ✅ Common directives (highlight, tooltip, click-outside)
  ✅ Common pipes (format-date, currency, truncate, safe-html)
  ✅ Re-exported frequently-used Angular modules (CommonModule, FormsModule)

SharedModule does NOT contain:
  ❌ Singleton services (those go in CoreModule or use providedIn: 'root')
  ❌ App-wide components with router-outlet (those go in AppModule/CoreModule)
  ❌ Feature-specific code (ProductCard belongs in ProductsModule)
  ❌ HTTP call logic (belongs in services)
```

### Real-World Analogy: The Office Kitchen

```
Imagine an office building with 10 departments (feature modules).

SharedModule = The shared kitchen/break room:
  ✅ Coffee machine (everyone uses it)
  ✅ Microwave (common utility)
  ✅ Paper towels (common utility)
  ✅ Shared plates (common UI elements)

NOT in the shared kitchen:
  ❌ Engineering team's specialized equipment → stays in Engineering dept
  ❌ The building's main generator → goes in CoreModule (company-wide, once)
  ❌ HR's personnel files → stays in HR dept (feature-specific)
```

### Full SharedModule Example

```typescript
// src/app/shared/shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';       // ← *ngIf, *ngFor, pipes
import { RouterModule } from '@angular/router';       // ← routerLink, routerLinkActive
import { FormsModule } from '@angular/forms';         // ← [(ngModel)], ngForm
import { ReactiveFormsModule } from '@angular/forms'; // ← FormBuilder, FormGroup

// ── Shared UI Components ──────────────────────────────────────────────────────
import { LoadingSpinnerComponent } from './components/loading-spinner/loading-spinner.component';
import { ErrorMessageComponent } from './components/error-message/error-message.component';
import { ConfirmDialogComponent } from './components/confirm-dialog/confirm-dialog.component';
import { PaginationComponent } from './components/pagination/pagination.component';
import { SearchBarComponent } from './components/search-bar/search-bar.component';
import { EmptyStateComponent } from './components/empty-state/empty-state.component';
import { BadgeComponent } from './components/badge/badge.component';
import { CardComponent } from './components/card/card.component';
import { ModalComponent } from './components/modal/modal.component';

// ── Shared Directives ─────────────────────────────────────────────────────────
import { HighlightDirective } from './directives/highlight.directive';
import { AutoFocusDirective } from './directives/auto-focus.directive';
import { ClickOutsideDirective } from './directives/click-outside.directive';
import { LazyImageDirective } from './directives/lazy-image.directive';
import { TooltipDirective } from './directives/tooltip.directive';

// ── Shared Pipes ──────────────────────────────────────────────────────────────
import { FormatDatePipe } from './pipes/format-date.pipe';
import { TruncatePipe } from './pipes/truncate.pipe';
import { SafeHtmlPipe } from './pipes/safe-html.pipe';
import { CurrencyFormatPipe } from './pipes/currency-format.pipe';
import { TimeAgoPipe } from './pipes/time-ago.pipe';
import { InitialsPipe } from './pipes/initials.pipe';

// Collect ALL shared items into arrays so we can reuse them
// in both declarations[] and exports[] cleanly
const SHARED_COMPONENTS = [
  LoadingSpinnerComponent,  // ← <app-loading-spinner [isLoading]="loading">
  ErrorMessageComponent,    // ← <app-error-message [error]="error">
  ConfirmDialogComponent,   // ← <app-confirm-dialog (confirmed)="onDelete()">
  PaginationComponent,      // ← <app-pagination [total]="total" (pageChange)="...">
  SearchBarComponent,       // ← <app-search-bar (search)="onSearch($event)">
  EmptyStateComponent,      // ← <app-empty-state message="No items found">
  BadgeComponent,           // ← <app-badge [type]="'success'">Active</app-badge>
  CardComponent,            // ← <app-card [title]="'My Card'">content</app-card>
  ModalComponent,           // ← <app-modal [isOpen]="showModal">...</app-modal>
];

const SHARED_DIRECTIVES = [
  HighlightDirective,       // ← <div appHighlight [color]="'yellow'">
  AutoFocusDirective,       // ← <input appAutoFocus>  (auto-focuses on render)
  ClickOutsideDirective,    // ← <div (appClickOutside)="closeMenu()">
  LazyImageDirective,       // ← <img appLazyImage [src]="imageUrl">
  TooltipDirective,         // ← <button appTooltip="Click to submit">Submit</button>
];

const SHARED_PIPES = [
  FormatDatePipe,           // ← {{ date | formatDate:'short' }}
  TruncatePipe,             // ← {{ longText | truncate:100 }}
  SafeHtmlPipe,             // ← <div [innerHTML]="html | safeHtml">
  CurrencyFormatPipe,       // ← {{ price | currencyFormat:'USD' }}
  TimeAgoPipe,              // ← {{ createdAt | timeAgo }}  → "3 hours ago"
  InitialsPipe,             // ← {{ 'John Doe' | initials }}  → "JD"
];

@NgModule({
  // Declare ALL shared items — they "live" in SharedModule
  declarations: [
    ...SHARED_COMPONENTS,   // ← Spread operator: adds all components to array
    ...SHARED_DIRECTIVES,
    ...SHARED_PIPES,
  ],

  // Import what WE need to build our shared components
  imports: [
    CommonModule,           // ← Our shared components use *ngIf, *ngFor, etc.
    RouterModule,           // ← Our shared components use routerLink
    FormsModule,            // ← SearchBarComponent uses [(ngModel)]
    ReactiveFormsModule,    // ← ConfirmDialogComponent uses reactive forms
  ],

  // Export EVERYTHING — that is the whole point of SharedModule!
  // Any module that imports SharedModule gets all of these.
  exports: [
    // Re-export Angular modules so importing modules get them too
    // ↓ This means: import SharedModule = also get CommonModule for free
    CommonModule,           // ← Feature modules no longer need to import CommonModule separately
    RouterModule,           // ← Feature modules no longer need to import RouterModule separately
    FormsModule,            // ← Feature modules can use [(ngModel)] without explicit import
    ReactiveFormsModule,    // ← Feature modules can use FormBuilder without explicit import

    // Export our own shared items
    ...SHARED_COMPONENTS,
    ...SHARED_DIRECTIVES,
    ...SHARED_PIPES,
  ]
  // NO providers[] in SharedModule!
  // Services should use providedIn: 'root' or go in CoreModule
  // If you put services in SharedModule providers[], they get
  // DUPLICATED when SharedModule is imported multiple times
})
export class SharedModule { }
```

### Exporting vs Not Exporting — Decision Diagram

```
You have a component/directive/pipe in SharedModule.

Should it be exported?
         |
         v
  Is it used ONLY internally by other
  shared components (like a helper)?
         |
    YES  |  NO
    ↓    |   ↓
  Don't  |  Export it ← It's the whole point of SharedModule
 export  |             to share with feature modules
```

### Caution: Services in SharedModule

```typescript
// ⚠️ DANGEROUS — DO NOT put services in SharedModule providers[]
@NgModule({
  providers: [
    NotificationService,  // ← BAD! SharedModule is imported by many modules.
                          //   Each lazy-loaded module gets its OWN instance.
                          //   Module A and Module B have DIFFERENT NotificationServices.
                          //   State is not shared — subtle bugs!
  ]
})
export class SharedModule { }

// ✅ CORRECT — Use providedIn: 'root' in the service instead
@Injectable({ providedIn: 'root' })  // ← Single instance, entire app
export class NotificationService { }

// OR put singleton services in CoreModule (see 11.5)
```

---

## 11.5 Core Module Pattern

### What is CoreModule For?

`CoreModule` is for things that should exist **once** for the **entire application**:

```
CoreModule contains:
  ✅ App-wide singleton services (AuthService, LoggingService, NotificationService)
  ✅ App-shell components used ONCE (HeaderComponent, FooterComponent, SidebarComponent)
  ✅ Global HTTP interceptors
  ✅ App-level guards (AuthGuard)
  ✅ App initialization services
  ✅ Global error handler

CoreModule does NOT contain:
  ❌ Reusable components/directives/pipes (those go in SharedModule)
  ❌ Feature-specific code (goes in feature modules)
  ❌ Anything you need in lazy-loaded modules (CoreModule is eagerly loaded once)
```

### CoreModule vs SharedModule — Quick Comparison

| Aspect | SharedModule | CoreModule |
|--------|-------------|------------|
| Imported by? | Every feature module | AppModule ONLY |
| Contains? | Reusable UI pieces | App-wide singletons |
| Exports? | Everything | App-shell components |
| Services? | NO | YES (app-wide) |
| Imported multiple times? | Yes, by design | NO (guarded against) |
| Analogy | Office kitchen (everyone uses) | CEO's office (one per company) |

### Full CoreModule with Re-Import Guard

```typescript
// src/app/core/core.module.ts
import { NgModule, Optional, SkipSelf } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';

// ── App-Shell Components (rendered once in AppComponent template) ──────────────
import { HeaderComponent } from './components/header/header.component';
import { FooterComponent } from './components/footer/footer.component';
import { SidebarComponent } from './components/sidebar/sidebar.component';
import { BreadcrumbComponent } from './components/breadcrumb/breadcrumb.component';
import { NavigationComponent } from './components/navigation/navigation.component';

// ── Singleton Services ────────────────────────────────────────────────────────
import { AuthService } from './services/auth.service';
import { LoggingService } from './services/logging.service';
import { NotificationService } from './services/notification.service';
import { StorageService } from './services/storage.service';
import { AnalyticsService } from './services/analytics.service';

// ── HTTP Interceptors ─────────────────────────────────────────────────────────
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { ErrorInterceptor } from './interceptors/error.interceptor';
import { LoadingInterceptor } from './interceptors/loading.interceptor';
import { CachingInterceptor } from './interceptors/caching.interceptor';

// ── Guards ────────────────────────────────────────────────────────────────────
import { AuthGuard } from './guards/auth.guard';
import { AdminGuard } from './guards/admin.guard';

@NgModule({
  // Declare app-shell components — these are used ONCE in AppComponent template
  declarations: [
    HeaderComponent,         // ← Used as <app-header> in app.component.html
    FooterComponent,         // ← Used as <app-footer> in app.component.html
    SidebarComponent,        // ← Used as <app-sidebar> in app.component.html
    BreadcrumbComponent,     // ← Used as <app-breadcrumb> in app.component.html
    NavigationComponent,     // ← Used as <app-navigation> in app.component.html
  ],

  imports: [
    CommonModule,            // ← Shell components use *ngIf, *ngFor, etc.
    RouterModule,            // ← Shell components use routerLink
    HttpClientModule,        // ← Required for HTTP interceptors
  ],

  // Export shell components so AppModule's templates can use them
  exports: [
    HeaderComponent,         // ← AppModule imports CoreModule, gets HeaderComponent
    FooterComponent,         // ← AppModule imports CoreModule, gets FooterComponent
    SidebarComponent,        // ← AppModule imports CoreModule, gets SidebarComponent
    BreadcrumbComponent,
    NavigationComponent,
  ],

  providers: [
    // Singleton services — CoreModule is only imported by AppModule
    // so these are true singletons (one instance for the whole app)
    // Modern Angular: most can be moved to providedIn: 'root'
    // but listing here makes the "app-wide" intent explicit
    AuthService,             // ← One AuthService for the entire app
    LoggingService,          // ← One LoggingService for the entire app
    NotificationService,     // ← One NotificationService for the entire app
    StorageService,
    AnalyticsService,

    // Guards are services — register them here
    AuthGuard,
    AdminGuard,

    // HTTP Interceptors — special registration syntax
    {
      provide: HTTP_INTERCEPTORS,   // ← Angular's interceptor injection token
      useClass: AuthInterceptor,    // ← Which interceptor class to use
      multi: true                   // ← multi:true means "add to array of interceptors"
                                    //   Without this, each one REPLACES the previous
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,   // ← Handles HTTP errors globally
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: LoadingInterceptor, // ← Shows/hides global loading spinner
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: CachingInterceptor, // ← Caches GET requests
      multi: true
    },
  ]
})
export class CoreModule {

  // ─────────────────────────────────────────────────────────────────────────
  // RE-IMPORT GUARD — Prevents CoreModule from being imported more than once
  //
  // Problem: If a developer accidentally imports CoreModule into a feature
  // module, singletons get DUPLICATED. Two AuthServices = two login states!
  //
  // Solution: In the constructor, check if CoreModule was already loaded.
  // If it was, the existing CoreModule instance gets injected via @Optional.
  // If parentModule is truthy, someone imported CoreModule twice — THROW!
  //
  // @SkipSelf() — "Don't look for CoreModule in MY own injector,
  //               look in the PARENT injector" (avoids injecting itself)
  //
  // @Optional() — "If CoreModule isn't found in the parent, that's OK,
  //               return null instead of throwing" (first time = no parent)
  // ─────────────────────────────────────────────────────────────────────────
  constructor(
    @Optional() @SkipSelf() parentModule: CoreModule  // ← null if first import, non-null if duplicate
  ) {
    if (parentModule) {
      // parentModule is NOT null → CoreModule was already loaded → ERROR!
      throw new Error(
        'CoreModule is already loaded. Import it only in AppModule. ' +
        'Feature modules should NOT import CoreModule.'
      );
    }
    // parentModule IS null → first time loading → all good, proceed
  }
}
```

```typescript
// src/app/app.module.ts — CoreModule usage
@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    AppRoutingModule,
    CoreModule,    // ← Import CoreModule ONCE here in the root module
    SharedModule,  // ← SharedModule is imported here AND in every feature module
    // Feature modules are NOT imported here — they are lazy loaded via router
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

---

## 11.6 Lazy Loading Modules (Revisited in Depth)

### The Core Problem Lazy Loading Solves

```
WITHOUT LAZY LOADING:
─────────────────────
User opens the app → Browser downloads 2.8 MB of JavaScript
→ Parses and compiles ALL routes, ALL components
→ User only visits: Home, Products, Contact
→ BUT they downloaded: Admin, Reports, UserManagement, OrderHistory code too!
→ Wasted bandwidth + slow initial load

WITH LAZY LOADING:
──────────────────
User opens the app → Browser downloads 350 KB (only AppModule)
User visits /products → Browser downloads 220 KB (ProductsModule)
User visits /orders  → Browser downloads 180 KB (OrdersModule)
User NEVER visits /admin → AdminModule is NEVER downloaded!
→ Faster startup, less wasted bandwidth
```

### loadChildren Syntax

```typescript
// src/app/app-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { PreloadAllModules, NoPreloading } from '@angular/router';

// Import ONLY eagerly-loaded components
import { HomeComponent } from './features/home/home.component';
import { NotFoundComponent } from './not-found/not-found.component';

// Import Guards (used in routes)
import { AuthGuard } from './core/guards/auth.guard';
import { AdminGuard } from './core/guards/admin.guard';

// Import a custom preloading strategy (see below)
import { SelectivePreloadingStrategy } from './core/strategies/selective-preloading.strategy';

const routes: Routes = [
  // ── Eagerly Loaded Routes ─────────────────────────────────────────────────
  {
    path: '',               // ← localhost:4200/
    component: HomeComponent // ← HomeComponent is in AppModule — always downloaded
  },

  // ── Lazily Loaded Routes ──────────────────────────────────────────────────
  {
    path: 'products',       // ← When user navigates to /products...
    loadChildren: () =>
      import('./features/products/products.module')  // ← Dynamic import!
        .then(m => m.ProductsModule),                // ← Angular loads this module
    // TypeScript uses dynamic import() — the module file is only
    // downloaded when this route is first activated
  },

  {
    path: 'users',
    loadChildren: () =>
      import('./features/users/users.module')
        .then(m => m.UsersModule),
    canActivate: [AuthGuard],   // ← Guard runs BEFORE downloading the module
  },

  {
    path: 'orders',
    loadChildren: () =>
      import('./features/orders/orders.module')
        .then(m => m.OrdersModule),
    canActivate: [AuthGuard],
    data: { preload: true }     // ← Hint for SelectivePreloadingStrategy
  },

  {
    path: 'reports',
    loadChildren: () =>
      import('./features/reports/reports.module')
        .then(m => m.ReportsModule),
    canActivate: [AuthGuard],
    data: { preload: false }    // ← Don't preload this (large, rarely used)
  },

  {
    path: 'admin',
    loadChildren: () =>
      import('./features/admin/admin.module')
        .then(m => m.AdminModule),
    canActivate: [AuthGuard, AdminGuard],  // ← Multiple guards
    data: { preload: false }
  },

  // Wildcard — MUST be last
  {
    path: '**',
    component: NotFoundComponent
  }
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, {
      // ── PRELOADING STRATEGY ─────────────────────────────────────────────
      // Controls which lazy modules are pre-downloaded in the background
      // AFTER the initial page loads.

      // Option 1: NoPreloading (default)
      // → Only load modules when the user actually navigates to them
      // → Best for: apps where most routes are rarely used
      preloadingStrategy: NoPreloading,

      // Option 2: PreloadAllModules
      // → After initial load, download ALL lazy modules in the background
      // → Best for: small-medium apps where all routes are commonly used
      // preloadingStrategy: PreloadAllModules,

      // Option 3: Custom SelectivePreloadingStrategy
      // → You decide which modules to preload via route data
      // → Best for: large apps — preload likely-visited, skip large/rare ones
      // preloadingStrategy: SelectivePreloadingStrategy,

      scrollPositionRestoration: 'enabled',  // ← Restore scroll on back navigation
    })
  ],
  providers: [
    SelectivePreloadingStrategy,  // ← Register custom strategy as a service
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

### Preloading Strategies — Deep Dive

```typescript
// src/app/core/strategies/selective-preloading.strategy.ts
import { Injectable } from '@angular/core';
import { PreloadingStrategy, Route } from '@angular/router';
import { Observable, of } from 'rxjs';

// This strategy preloads a module ONLY if the route's data has { preload: true }
@Injectable({ providedIn: 'root' })
export class SelectivePreloadingStrategy implements PreloadingStrategy {

  preloadedModules: string[] = [];  // ← Track which modules were preloaded

  // Angular calls this for EVERY lazy route after the app loads
  // route: the route configuration object
  // load: a function that, when called, triggers the download
  preload(route: Route, load: () => Observable<any>): Observable<any> {

    if (route.data?.['preload'] === true) {
      // ← route.data.preload is true → PRELOAD IT
      this.preloadedModules.push(route.path || '');
      console.log(`Preloading: ${route.path}`);
      return load();        // ← Calling load() starts the download
    } else {
      // ← preload is false or not set → DON'T preload
      return of(null);      // ← Return observable of null (no download)
    }
  }
}
```

```typescript
// Custom network-aware preloading strategy
// Only preload on fast connections
@Injectable({ providedIn: 'root' })
export class NetworkAwarePreloadingStrategy implements PreloadingStrategy {
  preload(route: Route, load: () => Observable<any>): Observable<any> {

    // Check network connection speed using the Network Information API
    const connection = (navigator as any).connection;

    if (connection) {
      // 'slow-2g' and '2g' are slow connections — don't preload
      if (connection.effectiveType === 'slow-2g' || connection.effectiveType === '2g') {
        return of(null);  // ← Slow connection: skip preloading to save data
      }
    }

    // Fast connection or no connection API support — preload all
    return load();
  }
}
```

### How Lazy Loading Affects Service Scope

```
CRITICAL CONCEPT: Injector Hierarchy with Lazy Modules

Root Injector (AppModule level):
  └── Provides: AuthService, LoggingService, NotificationService
      (available to the ENTIRE app)

          │
          ├── ProductsModule (lazy)
          │    ├── Child Injector created when module loads
          │    └── If ProductsModule has providers: [SomeService]
          │         → Creates a NEW instance SEPARATE from root
          │         → ProductsModule.SomeService ≠ AppModule.SomeService!
          │
          └── OrdersModule (lazy)
               ├── Child Injector created when module loads
               └── If OrdersModule has providers: [SomeService]
                    → Creates ANOTHER new instance!
                    → OrdersModule.SomeService ≠ ProductsModule.SomeService!

THE GOLDEN RULE:
  → Services that should be SINGLETONS: use providedIn: 'root'
    (goes into root injector, shared everywhere)
  → Services that should be FEATURE-SCOPED: put in lazy module providers[]
    (new instance per lazy module — intentional isolation)
```

---

## 11.7 forRoot() / forChild() Pattern

### The Problem This Pattern Solves

Imagine you're creating a `NotificationsModule` that provides both UI components AND a singleton `NotificationsService`. The service holds the queue of notifications to show.

```
WITHOUT forRoot()/forChild():

Feature Module A (lazy) imports NotificationsModule
  → NotificationsModule.providers: [NotificationsService]
  → Creates NotificationsService INSTANCE #1

Feature Module B (lazy) imports NotificationsModule
  → NotificationsModule.providers: [NotificationsService]
  → Creates NotificationsService INSTANCE #2

Result: Feature A's notifications go to Instance #1
        Feature B's notifications go to Instance #2
        App's notification bell shows Instance #1 (or #2?)
        → Notifications from Feature B NEVER appear in the bell!
        → This is a REAL bug that's hard to debug!
```

### The forRoot() / forChild() Solution

```typescript
// src/app/notifications/notifications.module.ts
import { NgModule, ModuleWithProviders } from '@angular/core';
import { CommonModule } from '@angular/common';

import { NotificationBellComponent } from './components/notification-bell.component';
import { NotificationToastComponent } from './components/notification-toast.component';
import { NotificationListComponent } from './components/notification-list.component';
import { NotificationsService } from './services/notifications.service';
import { NotificationsConfig } from './notifications.config';
import { NOTIFICATIONS_CONFIG } from './notifications.tokens';

@NgModule({
  // UI components are in declarations — shared across forRoot/forChild
  declarations: [
    NotificationBellComponent,   // ← <app-notification-bell>
    NotificationToastComponent,  // ← <app-notification-toast>
    NotificationListComponent,   // ← <app-notification-list>
  ],
  imports: [
    CommonModule,
  ],
  exports: [
    NotificationBellComponent,   // ← Exported so other modules can use them
    NotificationToastComponent,
    NotificationListComponent,
  ]
  // NO providers here in the base @NgModule!
  // Services are provided in forRoot() ONLY
})
export class NotificationsModule {

  // ──────────────────────────────────────────────────────────────────────────
  // forRoot() — Call this ONCE in AppModule
  //
  // Purpose: Provides the singleton service AND accepts configuration.
  //
  // ModuleWithProviders<T> is the return type — it's an NgModule WITH providers.
  // TypeScript knows this returns NotificationsModule's type information.
  // ──────────────────────────────────────────────────────────────────────────
  static forRoot(config?: NotificationsConfig): ModuleWithProviders<NotificationsModule> {
    return {
      ngModule: NotificationsModule,  // ← Which module class this is for
      providers: [
        // ← The SINGLETON service — provided ONLY via forRoot
        //   Since AppModule calls forRoot, this goes into the ROOT injector
        //   One instance for the entire app
        NotificationsService,

        // ← Inject configuration — pass the config object as a value
        {
          provide: NOTIFICATIONS_CONFIG,         // ← Injection token
          useValue: config || {                  // ← The actual config value
            maxNotifications: 10,
            timeout: 5000,
            position: 'top-right'
          }
        }
      ]
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // forChild() — Call this in FEATURE modules that need the UI components
  //
  // Purpose: Just gives the UI components (bell, toast, list) to the feature
  // WITHOUT creating a new service instance.
  //
  // No providers[] → no new service instance!
  // The feature module uses the ROOT injector's NotificationsService.
  // ──────────────────────────────────────────────────────────────────────────
  static forChild(): ModuleWithProviders<NotificationsModule> {
    return {
      ngModule: NotificationsModule,  // ← Same module
      providers: []                   // ← Empty providers = NO new service instance
    };
  }
}
```

```typescript
// src/app/notifications/notifications.tokens.ts
import { InjectionToken } from '@angular/core';
import { NotificationsConfig } from './notifications.config';

// InjectionToken is used when you want to inject a plain value (not a class)
// Must be unique — use a descriptive string
export const NOTIFICATIONS_CONFIG = new InjectionToken<NotificationsConfig>(
  'notifications.config'  // ← Debug label shown in error messages
);
```

```typescript
// src/app/notifications/notifications.config.ts
export interface NotificationsConfig {
  maxNotifications: number;   // ← Maximum concurrent notifications
  timeout: number;            // ← Auto-dismiss after N milliseconds
  position: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left';
}
```

```typescript
// src/app/notifications/services/notifications.service.ts
import { Injectable, Inject } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { NOTIFICATIONS_CONFIG } from '../notifications.tokens';
import { NotificationsConfig } from '../notifications.config';

export interface Notification {
  id: string;
  message: string;
  type: 'success' | 'error' | 'warning' | 'info';
  timestamp: Date;
}

@Injectable()  // ← No providedIn here — the module's forRoot() provides it
export class NotificationsService {
  private notifications$ = new BehaviorSubject<Notification[]>([]);
  notifications = this.notifications$.asObservable();

  constructor(
    @Inject(NOTIFICATIONS_CONFIG) private config: NotificationsConfig
    // ← @Inject() with our InjectionToken reads the config we provided
  ) {
    console.log('NotificationsService created with config:', config);
    // ← With forRoot/forChild pattern, this logs ONCE
    // ← Without the pattern (wrong approach), it would log multiple times
  }

  show(message: string, type: Notification['type'] = 'info'): void {
    const notification: Notification = {
      id: Math.random().toString(36),   // ← Simple unique ID
      message,
      type,
      timestamp: new Date()
    };

    const current = this.notifications$.value;

    // Enforce maxNotifications limit from config
    if (current.length >= this.config.maxNotifications) {
      current.shift();  // ← Remove oldest notification
    }

    this.notifications$.next([...current, notification]);

    // Auto-dismiss after timeout
    if (this.config.timeout > 0) {
      setTimeout(() => this.dismiss(notification.id), this.config.timeout);
    }
  }

  dismiss(id: string): void {
    const filtered = this.notifications$.value.filter(n => n.id !== id);
    this.notifications$.next(filtered);
  }
}
```

```typescript
// ── Usage ─────────────────────────────────────────────────────────────────────

// src/app/app.module.ts
@NgModule({
  imports: [
    BrowserModule,
    CoreModule,
    AppRoutingModule,
    // ← forRoot() called HERE — registers the singleton service with config
    NotificationsModule.forRoot({
      maxNotifications: 5,
      timeout: 4000,
      position: 'top-right'
    }),
  ]
})
export class AppModule { }

// src/app/features/products/products.module.ts
@NgModule({
  imports: [
    CommonModule,
    ProductsRoutingModule,
    SharedModule,
    // ← forChild() called HERE — gets the UI components, NOT a new service
    NotificationsModule.forChild(),
    // ProductsComponent can now use <app-notification-toast>
    // AND inject NotificationsService (gets the ROOT singleton)
  ]
})
export class ProductsModule { }
```

### RouterModule.forRoot() vs forChild() — Under the Hood

```
RouterModule.forRoot(routes):
  → Provides: Router service (the main router)
  → Provides: ActivatedRoute
  → Provides: RouterLink, RouterOutlet directives
  → REGISTERS the routes with the root Router
  → Called ONCE in AppRoutingModule

RouterModule.forChild(routes):
  → Provides: RouterLink, RouterOutlet directives only
  → NO Router service (uses the existing one from forRoot)
  → ADDS these routes to the existing Router
  → Called in EVERY feature routing module

If you called forRoot() in a feature module:
  → Creates a SECOND Router service
  → Two routers fighting for control of navigation
  → Application breaks in subtle ways
  → This is why the CLI always generates forChild() in feature routing modules
```

---

## 11.8 Standalone Components (Angular 14+)

### What is "Standalone" and Why Did Angular Introduce It?

Before Angular 14 (2022), EVERY component had to be declared in exactly one NgModule. Even tiny components required:
1. Create the component
2. Find the right NgModule
3. Add it to `declarations: []`
4. If others need it: add it to `exports: []`

This was boilerplate-heavy and a common source of errors ("Did you declare X in NgModule Y?").

**Angular 14 introduced Standalone Components** — components that manage their own dependencies directly, without needing to be declared in any NgModule.

```
BEFORE (NgModule-based):
┌─────────────────────────────────────────────┐
│ UserCardModule                              │
│   declarations: [UserCardComponent]         │
│   imports: [CommonModule, RouterModule]     │
│   exports: [UserCardComponent]              │
└─────────────────────────────────────────────┘
         ↑
   Must create this JUST to use UserCardComponent!

AFTER (Standalone):
┌─────────────────────────────────────────────┐
│ UserCardComponent (standalone)              │
│   imports: [CommonModule, RouterModule]     │
│   → No module wrapper needed!               │
└─────────────────────────────────────────────┘
   Use it directly: import [UserCardComponent]
```

### standalone: true in @Component

```typescript
// src/app/shared/components/user-card/user-card.component.ts
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';    // ← *ngIf, *ngFor, etc.
import { RouterModule } from '@angular/router';    // ← routerLink
import { User } from '../../../models/user.model';

@Component({
  selector: 'app-user-card',

  // ────────────────────────────────────────────────────────────────────────
  // standalone: true — This is the key flag!
  //
  // Means:
  // → This component does NOT need to be declared in any NgModule
  // → This component manages its own imports
  // → Other standalone components and modules can import it directly
  // ────────────────────────────────────────────────────────────────────────
  standalone: true,

  // ────────────────────────────────────────────────────────────────────────
  // imports — What THIS component's template needs
  //
  // For standalone components, the imports array goes HERE on the component,
  // not in a module. You can import:
  //   → Angular modules (CommonModule, RouterModule, FormsModule)
  //   → Other standalone components
  //   → Other standalone directives
  //   → Other standalone pipes
  //
  // Note: You CANNOT import non-standalone components/directives/pipes here.
  // They must be wrapped in a module and the module imported.
  // ────────────────────────────────────────────────────────────────────────
  imports: [
    CommonModule,    // ← Gives us *ngIf, *ngFor, AsyncPipe, DatePipe, etc.
    RouterModule,    // ← Gives us routerLink, routerLinkActive
  ],

  template: `
    <div class="user-card" [class.active]="user.isActive">
      <!-- *ngIf works because we imported CommonModule -->
      <img *ngIf="user.avatar" [src]="user.avatar" [alt]="user.name">
      <div class="user-info">
        <h3>{{ user.name }}</h3>
        <p>{{ user.email }}</p>
        <!-- routerLink works because we imported RouterModule -->
        <a [routerLink]="['/users', user.id]">View Profile</a>
      </div>
    </div>
  `,
  styleUrls: ['./user-card.component.scss']
})
export class UserCardComponent {
  @Input() user!: User;  // ← Required input (Angular 16+ uses required: true)
}
```

### Standalone Directives

```typescript
// src/app/shared/directives/highlight.directive.ts
import { Directive, ElementRef, Input, HostListener } from '@angular/core';

@Directive({
  selector: '[appHighlight]',
  standalone: true,  // ← This directive is standalone!
                     // Other standalone components can import it directly
})
export class HighlightDirective {
  @Input() appHighlight = 'yellow';  // ← The highlight color (default: yellow)
  @Input() defaultColor = '';        // ← Original background color

  constructor(private el: ElementRef) { }

  @HostListener('mouseenter')
  onMouseEnter() {
    this.el.nativeElement.style.backgroundColor = this.appHighlight;
  }

  @HostListener('mouseleave')
  onMouseLeave() {
    this.el.nativeElement.style.backgroundColor = this.defaultColor;
  }
}
```

### Standalone Pipes

```typescript
// src/app/shared/pipes/truncate.pipe.ts
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'truncate',
  standalone: true,  // ← This pipe is standalone!
                     // Import it directly into components that need it
})
export class TruncatePipe implements PipeTransform {
  transform(value: string, maxLength: number = 100, suffix: string = '...'): string {
    if (!value) return '';                    // ← Guard against null/undefined
    if (value.length <= maxLength) return value;  // ← No truncation needed
    return value.substring(0, maxLength) + suffix;  // ← Truncate and add suffix
  }
}
```

### Using Standalone Components Together

```typescript
// A standalone component importing other standalone components/directives/pipes
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { UserCardComponent } from '../user-card/user-card.component';  // ← standalone
import { HighlightDirective } from '../../directives/highlight.directive';  // ← standalone
import { TruncatePipe } from '../../pipes/truncate.pipe';  // ← standalone

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [
    CommonModule,         // ← Angular module (still imported as module)
    UserCardComponent,    // ← Standalone component (imported directly!)
    HighlightDirective,   // ← Standalone directive (imported directly!)
    TruncatePipe,         // ← Standalone pipe (imported directly!)
  ],
  template: `
    <div *ngFor="let user of users">
      <!-- UserCardComponent is available because we imported it above -->
      <app-user-card
        [user]="user"
        appHighlight="lightblue"
      ></app-user-card>

      <!-- TruncatePipe is available because we imported it above -->
      <p>{{ user.bio | truncate:150 }}</p>
    </div>
  `
})
export class UserListComponent {
  users = [
    { id: 1, name: 'Alice', email: 'alice@example.com', bio: 'A very long bio...' },
    { id: 2, name: 'Bob', email: 'bob@example.com', bio: 'Another long bio...' }
  ];
}
```

### Bootstrapping with bootstrapApplication()

```typescript
// src/main.ts — The new way to bootstrap a standalone app
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

// bootstrapApplication() replaces the old NgModule-based bootstrap.
// It takes:
//   1. The ROOT standalone component (replaces AppModule's bootstrap: [AppComponent])
//   2. An ApplicationConfig object with providers (replaces AppModule's providers)
bootstrapApplication(AppComponent, appConfig)
  .catch(err => console.error(err));  // ← Log any startup errors
```

```typescript
// src/app/app.config.ts — Application-wide configuration
import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter, withPreloading, PreloadAllModules } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';

import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

// ApplicationConfig is a plain object with a providers array
// This is the standalone equivalent of AppModule's providers + imports
export const appConfig: ApplicationConfig = {
  providers: [
    // ← provideRouter() replaces RouterModule.forRoot()
    //   Takes the routes array + optional features
    provideRouter(
      routes,
      withPreloading(PreloadAllModules),  // ← Preloading strategy as a "feature"
    ),

    // ← provideHttpClient() replaces HttpClientModule
    //   Takes optional features like interceptors
    provideHttpClient(
      withInterceptors([
        authInterceptor,   // ← Functional interceptors (new style)
        errorInterceptor,
      ])
    ),

    // ← Animations support (replaces BrowserAnimationsModule)
    provideAnimations(),

    // ← importProvidersFrom() bridges the gap between NgModules and standalone
    //   Use this for third-party libraries that haven't adopted standalone yet
    importProvidersFrom(
      // ThirdPartyLibraryModule,  // ← Example: Angular Material, NgRx, etc.
    ),
  ]
};
```

```typescript
// src/app/app.component.ts — The root standalone component
import { Component } from '@angular/core';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { HeaderComponent } from './core/components/header/header.component';
import { FooterComponent } from './core/components/footer/footer.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    RouterOutlet,        // ← <router-outlet> in template
    RouterLink,          // ← [routerLink] directive
    RouterLinkActive,    // ← [routerLinkActive] directive
    HeaderComponent,     // ← <app-header> in template
    FooterComponent,     // ← <app-footer> in template
  ],
  template: `
    <app-header></app-header>
    <main>
      <router-outlet></router-outlet>
    </main>
    <app-footer></app-footer>
  `
})
export class AppComponent { }
```

---

## 11.9 Standalone Architecture in Depth

### The New Provider Functions

Angular 15+ introduced a set of `provide*()` functions that replace the old NgModule imports. They are more explicit, type-safe, and tree-shakeable.

```
OLD WAY (NgModule):                NEW WAY (Standalone providers):
─────────────────────────────────  ─────────────────────────────────────────
imports: [RouterModule.forRoot()]  → provideRouter(routes, ...features)
imports: [HttpClientModule]        → provideHttpClient(...features)
imports: [BrowserAnimationsModule] → provideAnimations()
imports: [BrowserModule]           → (handled by bootstrapApplication)
imports: [NoopAnimationsModule]    → provideNoopAnimations()
imports: [MatDialogModule]         → importProvidersFrom(MatDialogModule)
```

### provideRouter() — Deep Dive

```typescript
// src/app/app.routes.ts
import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    // ← Standalone component lazy loading (Angular 14+)
    // Instead of loadChildren with a module, load a standalone component directly!
    loadComponent: () =>
      import('./features/home/home.component')
        .then(c => c.HomeComponent),
  },
  {
    path: 'products',
    loadComponent: () =>
      import('./features/products/product-list/product-list.component')
        .then(c => c.ProductListComponent),
  },
  {
    path: 'products/:id',
    loadComponent: () =>
      import('./features/products/product-detail/product-detail.component')
        .then(c => c.ProductDetailComponent),
  },
  {
    // Group of routes under /users with a shared guard
    path: 'users',
    canActivate: [AuthGuard],
    // loadChildren can point to a ROUTES array (not a module)
    // This is the standalone equivalent of feature routing modules
    loadChildren: () =>
      import('./features/users/users.routes')
        .then(r => r.userRoutes),
  },
  {
    path: 'admin',
    canActivate: [AuthGuard],
    loadChildren: () =>
      import('./features/admin/admin.routes')
        .then(r => r.adminRoutes),

    // ── Route-level providers ────────────────────────────────────────────
    // Providers listed here are SCOPED to this route and its children.
    // They create a new injector for the /admin subtree.
    // Useful for: admin-specific services that shouldn't bleed into other routes
    providers: [
      AdminLoggingService,   // ← Only available in /admin routes
      AdminSettingsService,  // ← Only available in /admin routes
    ]
  }
];
```

```typescript
// src/app/features/users/users.routes.ts
// ← Note: This is a ROUTES array, not an NgModule!
import { Routes } from '@angular/router';

export const userRoutes: Routes = [
  {
    path: '',                // ← /users
    loadComponent: () =>
      import('./user-list/user-list.component').then(c => c.UserListComponent),
  },
  {
    path: ':id',             // ← /users/123
    loadComponent: () =>
      import('./user-profile/user-profile.component').then(c => c.UserProfileComponent),
  },
  {
    path: ':id/edit',        // ← /users/123/edit
    loadComponent: () =>
      import('./user-edit/user-edit.component').then(c => c.UserEditComponent),
  }
];
```

### provideHttpClient() Features

```typescript
// src/app/app.config.ts
import {
  provideHttpClient,
  withInterceptors,          // ← Functional interceptors
  withInterceptorsFromDi,   // ← Class-based interceptors (backward compat)
  withJsonpSupport,          // ← Enables JSONP requests
  withXsrfConfiguration,    // ← Configure XSRF protection
  withFetch,                 // ← Use the Fetch API instead of XMLHttpRequest
} from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      // Functional interceptors (Angular 15+ style)
      withInterceptors([
        authInterceptor,      // ← Adds Authorization header
        errorInterceptor,     // ← Handles 401, 403, 500 globally
        loadingInterceptor,   // ← Shows/hides loading indicator
      ]),

      // Use Fetch API (better performance, supports streaming)
      // Optional — defaults to XMLHttpRequest for backward compatibility
      withFetch(),

      // XSRF protection configuration
      withXsrfConfiguration({
        cookieName: 'XSRF-TOKEN',    // ← Name of the XSRF cookie
        headerName: 'X-XSRF-TOKEN', // ← Name of the header to send
      })
    ),
  ]
};
```

```typescript
// src/app/core/interceptors/auth.interceptor.ts
// Functional interceptor (Angular 15+ style)
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

// A functional interceptor is just a function (not a class)
// inject() works here because Angular calls it in an injection context
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);  // ← inject() instead of constructor injection
  const token = authService.getToken();

  if (token) {
    // Clone the request and add the Authorization header
    // HTTP requests are IMMUTABLE — you must clone to modify
    const authReq = req.clone({
      headers: req.headers.set('Authorization', `Bearer ${token}`)
    });
    return next(authReq);  // ← Pass the modified request down the chain
  }

  return next(req);  // ← No token — pass original request unchanged
};
```

### importProvidersFrom() — The Bridge

```typescript
// importProvidersFrom() lets you use ANY NgModule's providers in a standalone app.
// This is critical for migrating gradually or using third-party NgModule-based libraries.

import { importProvidersFrom } from '@angular/core';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { StoreModule } from '@ngrx/store';
import { EffectsModule } from '@ngrx/effects';
import { reducers } from './store/reducers';
import { AppEffects } from './store/effects/app.effects';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),

    // ← importProvidersFrom() extracts providers from NgModules
    //   Use this for libraries that haven't been updated for standalone yet
    importProvidersFrom(
      MatDialogModule,           // ← Angular Material dialog service
      MatSnackBarModule,         // ← Angular Material snack bar service
      StoreModule.forRoot(reducers),    // ← NgRx store setup
      EffectsModule.forRoot([AppEffects])  // ← NgRx effects setup
    ),
  ]
};
```

### Environment Providers Pattern

```typescript
// src/app/core/providers/app.providers.ts
// Organize providers by domain for clarity

import { Provider, EnvironmentProviders } from '@angular/core';

// Group auth-related providers
export function provideAuth(): EnvironmentProviders {
  return makeEnvironmentProviders([
    AuthService,
    AuthGuard,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ]);
}

// Group notification-related providers
export function provideNotifications(config?: NotificationsConfig): EnvironmentProviders {
  return makeEnvironmentProviders([
    NotificationsService,
    {
      provide: NOTIFICATIONS_CONFIG,
      useValue: config || defaultNotificationsConfig
    }
  ]);
}
```

```typescript
// Usage in app.config.ts — clean and organized
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAnimations(),
    provideAuth(),                          // ← Auth setup
    provideNotifications({ timeout: 3000 }) // ← Notifications with config
  ]
};
```

---

## 11.10 Migrating from NgModules to Standalone

### Migration Strategies

```
STRATEGY 1: Big Bang (Full Rewrite)
────────────────────────────────────
Convert everything at once.

Pros:  Clean codebase immediately
Cons:  High risk, long freeze on new features, hard to review

Best for: Small apps (< 20 components), greenfield projects

STRATEGY 2: Incremental (Recommended)
───────────────────────────────────────
Migrate bottom-up: leaves first, then parent modules, then root.

Step 1: Convert leaf components to standalone (no dependents)
Step 2: Convert shared utilities (pipes, directives)
Step 3: Convert feature components
Step 4: Convert feature modules → route configuration files
Step 5: Convert SharedModule → just export standalone items
Step 6: Migrate AppModule → bootstrapApplication()

Pros:  Low risk, reviewable in small PRs, ship features in parallel
Cons:  Mixed codebase during transition, takes longer

Best for: Large production apps
```

### Manual Migration Step by Step

**Step 1: Convert a Leaf Component**

```typescript
// BEFORE: NgModule-based component
// ──────────────────────────────────

// badge.component.ts
@Component({
  selector: 'app-badge',
  template: `<span class="badge" [class]="type">{{ text }}</span>`
})
export class BadgeComponent {
  @Input() text = '';
  @Input() type: 'success' | 'danger' | 'warning' = 'success';
}

// shared.module.ts — had to declare it here
@NgModule({
  declarations: [BadgeComponent],
  exports: [BadgeComponent]
})
export class SharedModule { }


// AFTER: Standalone component
// ──────────────────────────────────

// badge.component.ts
@Component({
  selector: 'app-badge',
  standalone: true,             // ← Add this
  imports: [],                  // ← Add this (empty — no dependencies)
  template: `<span class="badge" [class]="type">{{ text }}</span>`
})
export class BadgeComponent {
  @Input() text = '';
  @Input() type: 'success' | 'danger' | 'warning' = 'success';
}

// shared.module.ts — remove from declarations, add to imports+exports
@NgModule({
  imports: [BadgeComponent],    // ← Standalone components go in imports[]
  exports: [BadgeComponent]     // ← Still exported for module-based consumers
  // declarations: [] ← REMOVE from here!
})
export class SharedModule { }
```

**Step 2: Convert a Component with Template Dependencies**

```typescript
// BEFORE
@Component({
  selector: 'app-user-card',
  template: `
    <div *ngIf="user">{{ user.name | date }}</div>
    <a [routerLink]="['/users', user?.id]">Profile</a>
  `
})
export class UserCardComponent {
  @Input() user?: User;
}

// shared.module.ts
@NgModule({
  declarations: [UserCardComponent],
  imports: [CommonModule, RouterModule],  // ← Module provided *ngIf, date pipe, routerLink
  exports: [UserCardComponent]
})
class SharedModule { }


// AFTER — The component now owns its own imports
@Component({
  selector: 'app-user-card',
  standalone: true,
  imports: [
    CommonModule,   // ← Bring *ngIf and DatePipe directly to THIS component
    RouterModule,   // ← Bring routerLink directly to THIS component
  ],
  template: `
    <div *ngIf="user">{{ user.name | date }}</div>
    <a [routerLink]="['/users', user?.id]">Profile</a>
  `
})
export class UserCardComponent {
  @Input() user?: User;
}
```

### Angular CLI Automatic Migration

```bash
# Generate new components as standalone by default
ng generate component features/products/product-card --standalone

# Equivalent shorthand
ng g c features/products/product-card --standalone

# Generate a standalone service
ng generate service core/services/auth --standalone
# (services don't really have standalone, but this sets up the file correctly)

# ──────────────────────────────────────────────────────────────────────────────
# SCHEMATIC: Automated migration of an existing app
# Angular provides an official migration schematic
# ──────────────────────────────────────────────────────────────────────────────

# Step 1: Migrate all components, directives, and pipes to standalone
ng generate @angular/core:standalone --mode=convert-to-standalone

# Step 2: Remove unnecessary NgModules (ones that only declared standalone items)
ng generate @angular/core:standalone --mode=prune-ng-modules

# Step 3: Migrate bootstrap from NgModule to bootstrapApplication()
ng generate @angular/core:standalone --mode=standalone-bootstrap

# Note: Run these steps IN ORDER, one at a time.
# Review and test after each step before proceeding.
```

### Before/After: AppModule to bootstrapApplication()

```typescript
// ────────────────────────────────────────────────────────────────────────────
// BEFORE: NgModule-based bootstrap
// ────────────────────────────────────────────────────────────────────────────

// app.module.ts
@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    BrowserAnimationsModule,
    CoreModule,
    SharedModule,
  ],
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }

// main.ts
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic()
  .bootstrapModule(AppModule)
  .catch(err => console.error(err));


// ────────────────────────────────────────────────────────────────────────────
// AFTER: Standalone bootstrap
// ────────────────────────────────────────────────────────────────────────────

// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withPreloading, PreloadAllModules } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes, withPreloading(PreloadAllModules)),
    provideHttpClient(withInterceptors([authInterceptor, errorInterceptor])),
    provideAnimations(),
    // Services that were in CoreModule providers:
    AuthService,
    LoggingService,
    NotificationService,
  ]
};

// app.component.ts — now standalone
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, HeaderComponent, FooterComponent],
  template: `
    <app-header></app-header>
    <router-outlet></router-outlet>
    <app-footer></app-footer>
  `
})
export class AppComponent { }

// main.ts — simpler now
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig)
  .catch(err => console.error(err));
```

---

## 11.11 Comparison: NgModules vs Standalone

### Large Comparison Table

| Feature | NgModules | Standalone Components |
|---------|-----------|----------------------|
| Angular version | Angular 2+ | Angular 14+ |
| Component declaration | In `NgModule.declarations[]` | `standalone: true` on the decorator |
| Template dependencies | Module provides via `imports[]` | Component's own `imports[]` |
| Bootstrapping | `platformBrowserDynamic().bootstrapModule(AppModule)` | `bootstrapApplication(AppComponent, appConfig)` |
| Routing | `RouterModule.forRoot(routes)` | `provideRouter(routes)` |
| HTTP | `HttpClientModule` | `provideHttpClient()` |
| Animations | `BrowserAnimationsModule` | `provideAnimations()` |
| Interceptors | Class-based with `HTTP_INTERCEPTORS` token | Functional with `withInterceptors([fn])` |
| Lazy loading | `loadChildren: () => import(...).then(m => m.SomeModule)` | `loadComponent: () => import(...).then(c => c.SomeComponent)` |
| Feature grouping | Feature modules | Route files with `loadChildren` → routes array |
| Code splitting | At module boundary | At component boundary (more granular!) |
| Boilerplate | Higher (module file for everything) | Lower (no extra module file) |
| Mental model | "What module does this belong to?" | "What does THIS component need?" |
| Tree-shaking | At module level | At component level (more efficient) |
| Third-party compat | Works with all libraries | Use `importProvidersFrom()` for legacy libs |
| Testing | Must import NgModule in TestBed | Just import the standalone component |
| Learning curve | Higher (must understand module system) | Lower (simpler mental model) |
| Angular team direction | Maintained, not deprecated | Recommended for new code |

### Decision Guide: When to Use Which

```
CHOOSE NgModules when:
┌────────────────────────────────────────────────────────────────┐
│ ✅ You are maintaining an existing NgModule-based app          │
│    and a full migration is not yet planned                     │
│                                                                │
│ ✅ Your team is familiar with NgModules and the migration      │
│    cost outweighs the benefit right now                        │
│                                                                │
│ ✅ You need to use a third-party library that requires         │
│    being in a specific NgModule's context                      │
│    (rare, but some older libraries have this constraint)       │
│                                                                │
│ ✅ You are on Angular < 14 (no choice)                        │
└────────────────────────────────────────────────────────────────┘

CHOOSE Standalone when:
┌────────────────────────────────────────────────────────────────┐
│ ✅ Starting a NEW Angular 14+ application                      │
│    (The Angular CLI now generates standalone by default        │
│     as of Angular 17)                                          │
│                                                                │
│ ✅ Building a reusable component library — standalone          │
│    components are easier to consume without NgModule overhead  │
│                                                                │
│ ✅ You want simpler testing — TestBed setup is cleaner         │
│    with standalone components                                  │
│                                                                │
│ ✅ You want better tree-shaking — Angular knows exactly        │
│    which components need which dependencies                    │
│                                                                │
│ ✅ You are incrementally migrating an existing app             │
└────────────────────────────────────────────────────────────────┘
```

### Industry Direction

```
Angular CLI default behavior (history):
─────────────────────────────────────────────────────────────────
Angular 2-13:   ng generate component → Creates NgModule-based
Angular 14:     Standalone introduced as opt-in (--standalone flag)
Angular 15:     Standalone APIs stabilized (provideRouter, etc.)
Angular 16:     Required inputs, Signals preview
Angular 17:     ng generate component → Creates STANDALONE by default!
                All new CLI projects use standalone architecture
Angular 18+:    NgModule remains supported but standalone is standard

Official Angular documentation (2024/2025):
→ All tutorials use standalone components
→ "NgModules are still supported but standalone is the recommended approach"
→ No plans to remove NgModules (backward compatibility is maintained)

Bottom line:
→ If you are starting a new project: USE STANDALONE
→ If you have an existing NgModule app: MIGRATE INCREMENTALLY
→ NgModules are NOT going away, but they are not the future direction
```

---

## 11.12 Practical Example — Enterprise App Architecture

### Complete Folder Structure

```
src/
├── main.ts                          ← bootstrapApplication()
├── index.html                       ← Single HTML file
│
└── app/
    ├── app.component.ts             ← Root standalone component
    ├── app.config.ts                ← ApplicationConfig (providers)
    ├── app.routes.ts                ← Root routes
    │
    ├── core/                        ← CoreModule equivalent (standalone)
    │   ├── components/
    │   │   ├── header/
    │   │   │   └── header.component.ts        ← standalone
    │   │   ├── footer/
    │   │   │   └── footer.component.ts        ← standalone
    │   │   ├── sidebar/
    │   │   │   └── sidebar.component.ts       ← standalone
    │   │   └── breadcrumb/
    │   │       └── breadcrumb.component.ts    ← standalone
    │   ├── guards/
    │   │   ├── auth.guard.ts
    │   │   └── admin.guard.ts
    │   ├── interceptors/
    │   │   ├── auth.interceptor.ts           ← functional interceptor
    │   │   ├── error.interceptor.ts          ← functional interceptor
    │   │   └── loading.interceptor.ts        ← functional interceptor
    │   ├── services/
    │   │   ├── auth.service.ts
    │   │   ├── logging.service.ts
    │   │   └── notification.service.ts
    │   └── providers/
    │       └── app.providers.ts              ← provideAuth(), provideNotifications()
    │
    ├── shared/                      ← SharedModule equivalent (standalone)
    │   ├── components/
    │   │   ├── loading-spinner/
    │   │   │   └── loading-spinner.component.ts  ← standalone
    │   │   ├── error-message/
    │   │   │   └── error-message.component.ts    ← standalone
    │   │   ├── pagination/
    │   │   │   └── pagination.component.ts       ← standalone
    │   │   ├── search-bar/
    │   │   │   └── search-bar.component.ts       ← standalone
    │   │   └── modal/
    │   │       └── modal.component.ts            ← standalone
    │   ├── directives/
    │   │   ├── highlight.directive.ts            ← standalone
    │   │   ├── click-outside.directive.ts        ← standalone
    │   │   └── lazy-image.directive.ts           ← standalone
    │   └── pipes/
    │       ├── format-date.pipe.ts               ← standalone
    │       ├── truncate.pipe.ts                  ← standalone
    │       └── time-ago.pipe.ts                  ← standalone
    │
    ├── models/                      ← TypeScript interfaces/types
    │   ├── user.model.ts
    │   ├── product.model.ts
    │   └── order.model.ts
    │
    └── features/                    ← Feature modules (or standalone route sets)
        ├── home/
        │   └── home.component.ts              ← standalone, lazy loaded
        │
        ├── products/
        │   ├── products.routes.ts             ← Routes array (no NgModule!)
        │   ├── product-list/
        │   │   └── product-list.component.ts  ← standalone
        │   ├── product-detail/
        │   │   └── product-detail.component.ts ← standalone
        │   ├── product-card/
        │   │   └── product-card.component.ts  ← standalone, shared across features
        │   ├── product-form/
        │   │   └── product-form.component.ts  ← standalone
        │   └── services/
        │       └── product.service.ts         ← providedIn: 'root'
        │
        ├── users/
        │   ├── users.routes.ts
        │   ├── user-list/
        │   │   └── user-list.component.ts     ← standalone
        │   ├── user-profile/
        │   │   └── user-profile.component.ts  ← standalone
        │   └── services/
        │       └── user.service.ts
        │
        ├── orders/
        │   ├── orders.routes.ts
        │   ├── order-list/
        │   │   └── order-list.component.ts    ← standalone
        │   └── services/
        │       └── order.service.ts
        │
        └── admin/
            ├── admin.routes.ts
            ├── dashboard/
            │   └── dashboard.component.ts     ← standalone
            └── services/
                └── admin.service.ts
```

### The Complete NgModule Version (Enterprise App)

```typescript
// ──────────────────────────────────────────────────────────────────────────────
// NGMODULE APPROACH — Enterprise app wired together with modules
// ──────────────────────────────────────────────────────────────────────────────

// src/app/app-routing.module.ts
const routes: Routes = [
  { path: '', component: HomeComponent },
  {
    path: 'products',
    loadChildren: () =>
      import('./features/products/products.module').then(m => m.ProductsModule),
  },
  {
    path: 'users',
    loadChildren: () =>
      import('./features/users/users.module').then(m => m.UsersModule),
    canActivate: [AuthGuard],
  },
  {
    path: 'orders',
    loadChildren: () =>
      import('./features/orders/orders.module').then(m => m.OrdersModule),
    canActivate: [AuthGuard],
  },
  {
    path: 'admin',
    loadChildren: () =>
      import('./features/admin/admin.module').then(m => m.AdminModule),
    canActivate: [AuthGuard, AdminGuard],
  },
  { path: '**', component: NotFoundComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })],
  exports: [RouterModule]
})
export class AppRoutingModule { }


// src/app/app.module.ts
@NgModule({
  declarations: [AppComponent, NotFoundComponent],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    CoreModule,
    SharedModule,
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }


// src/app/features/products/products.module.ts
@NgModule({
  declarations: [
    ProductListComponent,
    ProductDetailComponent,
    ProductCardComponent,
    ProductFormComponent,
    DiscountPipe,
  ],
  imports: [
    CommonModule,
    ReactiveFormsModule,
    ProductsRoutingModule,
    SharedModule,
  ],
  exports: [
    ProductCardComponent,  // ← Shared with orders feature
  ]
})
export class ProductsModule { }


// src/app/features/orders/orders.module.ts
@NgModule({
  declarations: [OrderListComponent, OrderDetailComponent],
  imports: [
    CommonModule,
    FormsModule,
    OrdersRoutingModule,
    SharedModule,
    ProductsModule,    // ← Import Products to use ProductCardComponent
  ],
})
export class OrdersModule { }
```

### The Complete Standalone Version (Same App)

```typescript
// ──────────────────────────────────────────────────────────────────────────────
// STANDALONE APPROACH — Same enterprise app, no NgModules
// ──────────────────────────────────────────────────────────────────────────────

// src/main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig).catch(console.error);


// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withPreloading, PreloadAllModules, withComponentInputBinding } from '@angular/router';
import { provideHttpClient, withInterceptors, withFetch } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(
      routes,
      withPreloading(PreloadAllModules),     // ← Preload all lazy modules
      withComponentInputBinding(),           // ← Bind route params to @Input() directly
    ),
    provideHttpClient(
      withFetch(),                           // ← Modern Fetch API
      withInterceptors([authInterceptor, errorInterceptor])
    ),
    provideAnimations(),
  ]
};


// src/app/app.routes.ts
import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { adminGuard } from './core/guards/admin.guard';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./features/home/home.component').then(c => c.HomeComponent),
  },
  {
    path: 'products',
    loadChildren: () =>
      import('./features/products/products.routes').then(r => r.productRoutes),
  },
  {
    path: 'users',
    canActivate: [authGuard],
    loadChildren: () =>
      import('./features/users/users.routes').then(r => r.userRoutes),
  },
  {
    path: 'orders',
    canActivate: [authGuard],
    loadChildren: () =>
      import('./features/orders/orders.routes').then(r => r.orderRoutes),
  },
  {
    path: 'admin',
    canActivate: [authGuard, adminGuard],
    loadChildren: () =>
      import('./features/admin/admin.routes').then(r => r.adminRoutes),
  },
  {
    path: '**',
    loadComponent: () =>
      import('./not-found/not-found.component').then(c => c.NotFoundComponent),
  }
];


// src/app/features/products/products.routes.ts
import { Routes } from '@angular/router';

export const productRoutes: Routes = [
  {
    path: '',                  // ← /products
    loadComponent: () =>
      import('./product-list/product-list.component')
        .then(c => c.ProductListComponent),
  },
  {
    path: ':id',               // ← /products/123
    loadComponent: () =>
      import('./product-detail/product-detail.component')
        .then(c => c.ProductDetailComponent),
  },
  {
    path: ':id/edit',          // ← /products/123/edit
    loadComponent: () =>
      import('./product-form/product-form.component')
        .then(c => c.ProductFormComponent),
    canActivate: [authGuard],  // ← Only logged-in users can edit
  }
];


// src/app/features/products/product-list/product-list.component.ts
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

// ← Import other standalone components directly (no module wrapper!)
import { ProductCardComponent } from '../product-card/product-card.component';
import { SearchBarComponent } from '../../../shared/components/search-bar/search-bar.component';
import { PaginationComponent } from '../../../shared/components/pagination/pagination.component';
import { LoadingSpinnerComponent } from '../../../shared/components/loading-spinner/loading-spinner.component';

import { ProductService } from '../services/product.service';
import { Product } from '../../../models/product.model';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [
    CommonModule,            // ← *ngIf, *ngFor, AsyncPipe
    RouterModule,            // ← routerLink
    ProductCardComponent,    // ← <app-product-card> — standalone import!
    SearchBarComponent,      // ← <app-search-bar> — standalone import!
    PaginationComponent,     // ← <app-pagination> — standalone import!
    LoadingSpinnerComponent, // ← <app-loading-spinner> — standalone import!
  ],
  template: `
    <div class="products-page">
      <h1>Products</h1>

      <!-- SearchBarComponent is available because it's in our imports[] -->
      <app-search-bar (search)="onSearch($event)"></app-search-bar>

      <!-- LoadingSpinnerComponent shows during data fetch -->
      <app-loading-spinner *ngIf="loading"></app-loading-spinner>

      <div class="product-grid" *ngIf="!loading">
        <!-- ProductCardComponent available via imports[] — NO MODULE NEEDED! -->
        <app-product-card
          *ngFor="let product of products"
          [product]="product"
          (addToCart)="onAddToCart($event)"
        ></app-product-card>
      </div>

      <!-- PaginationComponent for page navigation -->
      <app-pagination
        [total]="totalProducts"
        [pageSize]="pageSize"
        [currentPage]="currentPage"
        (pageChange)="onPageChange($event)"
      ></app-pagination>
    </div>
  `
})
export class ProductListComponent implements OnInit {
  // inject() function — standalone alternative to constructor injection
  // Works in Angular 14+ as an alternative to constructor(private svc: Service)
  private productService = inject(ProductService);

  products: Product[] = [];  // ← Product list
  loading = false;           // ← Loading state
  totalProducts = 0;         // ← Total count for pagination
  pageSize = 12;             // ← Products per page
  currentPage = 1;           // ← Current page number
  searchQuery = '';          // ← Current search query

  ngOnInit(): void {
    this.loadProducts();
  }

  loadProducts(): void {
    this.loading = true;  // ← Show spinner
    this.productService
      .getProducts({
        page: this.currentPage,
        pageSize: this.pageSize,
        search: this.searchQuery
      })
      .subscribe({
        next: (result) => {
          this.products = result.items;        // ← Set the product data
          this.totalProducts = result.total;   // ← Set total for pagination
          this.loading = false;                // ← Hide spinner
        },
        error: (err) => {
          console.error('Failed to load products', err);
          this.loading = false;                // ← Hide spinner even on error
        }
      });
  }

  onSearch(query: string): void {
    this.searchQuery = query;   // ← Update search query
    this.currentPage = 1;       // ← Reset to first page on new search
    this.loadProducts();        // ← Reload with new query
  }

  onPageChange(page: number): void {
    this.currentPage = page;    // ← Update current page
    this.loadProducts();        // ← Load new page
  }

  onAddToCart(product: Product): void {
    // Cart service is a singleton via providedIn: 'root'
    // inject() it here if needed
    console.log('Add to cart:', product.name);
  }
}


// src/app/features/products/product-card/product-card.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

// Standalone pipes can be imported directly
import { TruncatePipe } from '../../../shared/pipes/truncate.pipe';
import { CurrencyFormatPipe } from '../../../shared/pipes/currency-format.pipe';

import { Product } from '../../../models/product.model';

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [
    CommonModule,        // ← *ngIf for conditional rendering
    RouterModule,        // ← routerLink for navigation
    TruncatePipe,        // ← {{ description | truncate:80 }}
    CurrencyFormatPipe,  // ← {{ price | currencyFormat }}
  ],
  template: `
    <div class="product-card" [class.out-of-stock]="product.stock === 0">
      <img
        [src]="product.imageUrl"
        [alt]="product.name"
        class="product-image"
      >
      <div class="product-body">
        <h3 class="product-name">
          <a [routerLink]="['/products', product.id]">{{ product.name }}</a>
        </h3>
        <!-- TruncatePipe limits description to 80 characters -->
        <p class="product-description">{{ product.description | truncate:80 }}</p>

        <div class="product-footer">
          <!-- CurrencyFormatPipe formats the price -->
          <span class="price">{{ product.price | currencyFormat:'USD' }}</span>

          <!-- *ngIf shows out-of-stock badge if stock is 0 -->
          <span *ngIf="product.stock === 0" class="badge badge-danger">
            Out of Stock
          </span>

          <button
            class="btn btn-primary"
            [disabled]="product.stock === 0"
            (click)="addToCart.emit(product)"
          >
            Add to Cart
          </button>
        </div>
      </div>
    </div>
  `,
  styleUrls: ['./product-card.component.scss']
})
export class ProductCardComponent {
  @Input({ required: true }) product!: Product;  // ← Required input (Angular 16+)
  @Output() addToCart = new EventEmitter<Product>();  // ← Emit when button clicked
}
```

### Functional Guards (Standalone-Style)

```typescript
// src/app/core/guards/auth.guard.ts
// Modern functional guard — no class, no @Injectable
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

// A functional guard is just a function that returns boolean | UrlTree | Observable | Promise
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);  // ← inject() works in guard context
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true;    // ← Logged in → allow navigation
  }

  // Not logged in → redirect to login, passing the attempted URL as query param
  return router.createUrlTree(['/auth/login'], {
    queryParams: { returnUrl: state.url }  // ← After login, redirect back here
  });
};


// src/app/core/guards/admin.guard.ts
export const adminGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.hasRole('admin')) {
    return true;    // ← Has admin role → allow
  }

  // Not an admin → redirect to dashboard with an error message
  return router.createUrlTree(['/dashboard'], {
    queryParams: { error: 'insufficient_permissions' }
  });
};
```

---

## 11.13 Summary

### What We Covered

```
Phase 11 Learning Map:
──────────────────────────────────────────────────────────────────────────────

 11.1 Architecture Matters
   → Structure determines long-term maintainability
   → Small apps vs enterprise apps need different approaches
   → House blueprint analogy

 11.2 NgModules Deep Dive
   → @NgModule anatomy: declarations, imports, exports, providers, bootstrap
   → Module boundary concept (what's private, what's shared)
   → Root module vs feature module differences

 11.3 Feature Modules
   → Group related code into self-contained modules
   → CLI commands to generate feature modules
   → ProductsModule, UsersModule complete examples
   → Declarations vs imports vs exports decision logic

 11.4 SharedModule Pattern
   → Common reusables: components, directives, pipes
   → Re-exporting Angular modules (CommonModule, RouterModule)
   → Do NOT put singleton services in SharedModule

 11.5 CoreModule Pattern
   → Singletons: app-shell components, global services, interceptors
   → Re-import guard using @Optional() @SkipSelf()
   → Import CoreModule ONLY in AppModule

 11.6 Lazy Loading In Depth
   → loadChildren syntax and how it works
   → NoPreloading, PreloadAllModules, custom SelectivePreloadingStrategy
   → Child injectors: how lazy modules affect service scope

 11.7 forRoot() / forChild() Pattern
   → Solves the "duplicate singleton in lazy modules" problem
   → ModuleWithProviders<T> return type
   → Complete configurable module example with InjectionToken

 11.8 Standalone Components
   → standalone: true, component-level imports[]
   → Standalone directives and pipes
   → bootstrapApplication() replacing NgModule bootstrap

 11.9 Standalone Architecture
   → provideRouter(), provideHttpClient(), provideAnimations()
   → Functional interceptors with withInterceptors()
   → importProvidersFrom() for backward compatibility
   → loadComponent for standalone lazy loading
   → Route-level providers

 11.10 Migration Strategy
   → Incremental (bottom-up) vs big-bang approaches
   → ng generate --standalone flag
   → ng generate @angular/core:standalone schematic
   → Before/after code for AppModule → bootstrapApplication()

 11.11 NgModules vs Standalone Comparison
   → Full feature comparison table
   → Decision guide for each approach
   → Angular's official direction: standalone is the future

 11.12 Complete Enterprise Example
   → Full folder structure for a real enterprise app
   → NgModule version and standalone version side by side
   → Functional guards, lazy routes, inject() function

──────────────────────────────────────────────────────────────────────────────
```

### Key Rules to Remember

| Rule | Why It Matters |
|------|---------------|
| Declare in ONE module only | Angular throws an error if a component is declared in two modules |
| Use `CommonModule` in feature modules, NOT `BrowserModule` | `BrowserModule` sets up the browser — should only run once |
| `CoreModule` imported only in `AppModule` | The re-import guard enforces this to prevent duplicate singletons |
| `SharedModule` imported by ALL feature modules | Its purpose is to be shared — that's why everything gets exported |
| Services: use `providedIn: 'root'` | True singleton, tree-shakeable, no need to list in providers |
| `forRoot()` in root module, `forChild()` in feature modules | Prevents duplicate service instances in lazy-loaded features |
| `loadChildren` for module groups, `loadComponent` for single standalone | Code splitting at the right granularity |
| Standalone apps: never call `bootstrapModule()` | Use `bootstrapApplication()` with `appConfig` instead |
| `inject()` works in functional guards and standalone components | Modern alternative to constructor injection |

### Common Mistakes / Gotchas

```
❌ MISTAKE 1: Importing BrowserModule in a feature module
   Fix: Use CommonModule instead. BrowserModule is for AppModule only.
   Error you'll see: "BrowserModule has already been loaded."

❌ MISTAKE 2: Declaring a component in two NgModules
   Fix: Declare in one module, export it, import that module elsewhere.
   Error you'll see: "Type X is part of declarations of 2 modules."

❌ MISTAKE 3: Putting singleton services in SharedModule providers[]
   Fix: Use providedIn: 'root' or CoreModule providers[].
   Bug you'll see: Two copies of the service, state not shared between features.

❌ MISTAKE 4: Calling RouterModule.forRoot() in a feature module
   Fix: Feature modules use RouterModule.forChild().
   Bug you'll see: Router state corruption, navigation breaks unpredictably.

❌ MISTAKE 5: Forgetting to import CommonModule in a standalone component
   Fix: Add CommonModule to the component's imports[].
   Error you'll see: "Can't bind to 'ngIf' since it isn't a known property."

❌ MISTAKE 6: Mixing bootstrapModule and bootstrapApplication
   Fix: Choose one approach. Full standalone apps use bootstrapApplication.
   Error you'll see: Providers not found, routing doesn't initialize.

❌ MISTAKE 7: Using class-based interceptors with withInterceptors()
   Fix: Use functional interceptors with withInterceptors(), OR
        use withInterceptorsFromDi() for class-based ones.
   Error you'll see: Interceptors not being called.

❌ MISTAKE 8: Lazy loading a non-standalone component with loadComponent
   Fix: The loaded component MUST have standalone: true.
   Error you'll see: "Component used in loadComponent must be standalone."
```

### Architecture Decision Flowchart

```
Starting a new Angular project?
         │
    YES  │  NO (existing project)
     ↓   │       ↓
Use      │  Are you on Angular 14+?
Standalone│    │
(default  │  NO│  YES
in v17+)  │   ↓   ↓
          │  Keep  Consider incremental
          │  NgModules  migration to standalone
          │  as-is  (see 11.10)
          │

For your standalone app's architecture:
─────────────────────────────────────────
Single feature? → loadComponent (lazy single component)
Group of related routes? → loadChildren → routes array
App-wide services? → providedIn: 'root' or appConfig providers
HTTP? → provideHttpClient(withInterceptors([...]))
Routing? → provideRouter(routes, withPreloading(...))
Legacy library? → importProvidersFrom(LegacyModule)
Route-specific services? → providers[] on the route config

For your NgModule app's architecture:
──────────────────────────────────────
Single common component/pipe/directive used everywhere?
  → SharedModule (declarations + exports)
App-wide singleton service?
  → CoreModule providers[] or providedIn: 'root'
Feature-specific code (routes, components, services)?
  → Feature Module
Configurable library/feature with singleton service?
  → forRoot() / forChild() pattern
Group of routes loaded on demand?
  → Lazy loaded feature module (loadChildren)
```

---

> **Next Phase:** [Phase 12: Signals & Modern Reactivity](Phase12-Signals-Modern-Reactivity.md)
