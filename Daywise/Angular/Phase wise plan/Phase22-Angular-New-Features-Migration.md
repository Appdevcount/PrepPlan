# Phase 22: Angular New Features & Migration (v14–v19)

> "Angular does not just add features — it reimagines how you build. Every major version is a deliberate step toward a faster, simpler, and more powerful framework. Mastering the evolution is not optional; it is what separates engineers who maintain legacy code from engineers who drive the future." — Angular Core Team

---

## 22.1 Angular's Evolution — Why Staying Current Matters

### The Problem: Falling Behind the Framework

Many Angular teams make a dangerous mistake: they lock in at a specific version and never upgrade. Two years later they are running Angular 12 while the ecosystem has moved to Angular 19. The result? Security vulnerabilities go unpatched, performance improvements are missed, new hires are confused, and eventually a painful big-bang migration is forced upon the team.

**Real-world analogy:** Imagine buying a car in 2018 and refusing any software updates. The navigation maps grow stale, the engine control firmware misses fuel efficiency improvements, safety features that could prevent accidents are never activated, and your warranty is voided. Angular versions work the same way — each release is a software update for your framework.

```
Angular Version Timeline (v14 → v19)

2022 ─── v14 ─── Standalone Components (Preview), Typed Forms
         │
2022 ─── v15 ─── Standalone APIs Stable, Functional Guards, NgOptimizedImage
         │
2023 ─── v16 ─── Signals (Preview), Required Inputs, Non-Destructive Hydration
         │
2023 ─── v17 ─── New Control Flow (@if/@for), Deferrable Views, Vite+esbuild
         │
2024 ─── v18 ─── Signals Stable, Zoneless (Experimental), Material 3
         │
2024 ─── v19 ─── Incremental Hydration, Linked Signals, Resource API
         │
2025+ ── v20+ ── Full Zoneless, Signal Router, Signal Forms (Stable)
```

### 22.1.1 Angular's 6-Month Release Cycle

Angular follows a predictable **6-month major release cadence**:

| Period | What Happens |
|--------|-------------|
| Months 1-4 | Feature development and developer preview |
| Month 5 | Release Candidate (RC) — stabilization |
| Month 6 | Major version release |
| Next 6 months | Patch releases (bug fixes, security) |

This means:
- May/June — one major version
- November/December — next major version

**Why this is good for you:**
- Predictable planning: you know when to expect changes
- Features spend time in "Developer Preview" so you can test early
- No more "Angular 2" style big-bang rewrites — changes are incremental

### 22.1.2 Semantic Versioning in Angular

Angular uses **SemVer** (Semantic Versioning): `MAJOR.MINOR.PATCH`

```
Angular 17.3.2
         │  │  └── PATCH: Bug fixes only. Safe to upgrade immediately.
         │  └───── MINOR: New features, fully backward compatible. Safe to upgrade.
         └──────── MAJOR: May contain breaking changes. Needs migration steps.

Examples:
  17.0.0 → 17.0.1   (patch: safe, auto-upgradable)
  17.0.0 → 17.3.0   (minor: safe, new features added)
  17.3.0 → 18.0.0   (major: check migration guide!)
```

**Common mistake:** Teams upgrading directly from v14 to v18, skipping intermediate versions. Angular explicitly warns against this — always upgrade one major version at a time.

### 22.1.3 LTS (Long Term Support) Policy

Angular maintains two versions in LTS at any given time:

```
Active Support (Latest version)
  ├── Bug fixes
  ├── Security patches
  ├── Performance improvements
  └── New features

LTS Support (Previous 2 major versions)
  ├── Bug fixes ✓
  ├── Critical security patches ✓
  ├── Performance improvements ✗
  └── New features ✗

End of Life (Older versions)
  └── No support at all — UPGRADE IMMEDIATELY
```

| Version | Release Date | LTS Until |
|---------|-------------|-----------|
| v14 | June 2022 | Nov 2023 |
| v15 | Nov 2022 | May 2024 |
| v16 | May 2023 | Nov 2024 |
| v17 | Nov 2023 | May 2025 |
| v18 | May 2024 | Nov 2025 |
| v19 | Nov 2024 | May 2026 |

**Decision rule:** If your Angular version is past its LTS end date, upgrading is a security requirement, not just a nice-to-have.

### 22.1.4 Why Staying Current Pays Off

```
Cost of staying current (upgrading each version):
  └── Small, manageable changes each time
  └── Automated migration schematics do most of the work
  └── ~2-8 hours per major version for an average app

Cost of skipping 3+ versions:
  └── Large, painful migration
  └── Breaking changes stack up
  └── Manual code changes everywhere
  └── ~2-4 weeks for an average app
  └── High risk of regressions
```

---

## 22.2 Angular 14 — Standalone Components & Typed Forms

### The Big Picture

Angular 14, released June 2022, introduced two game-changing features: **Standalone Components** (which eventually eliminate NgModules) and **Strictly Typed Reactive Forms** (which eliminates the `any` type plague in form code).

### 22.2.1 Standalone Components (Preview)

**The problem Standalone Components solve:**

In Angular's original design, every component, directive, and pipe had to be declared inside an NgModule. This meant:
- Every new component required touching two files (the component AND the module)
- Understanding a component required reading the module to see its dependencies
- Sharing components between modules required complex re-export patterns
- Testing required mocking entire modules

**Analogy:** Traditional NgModules are like a corporate department — to hire one person (add one component), you have to go through HR paperwork (the module), get approval from the manager (add to declarations), and notify every department that works with them (imports/exports). Standalone components are like a freelancer — self-contained, brings their own tools, works directly with whoever needs them.

```
BEFORE: NgModule-based component architecture

app.module.ts
  ├── declarations: [AppComponent, HeaderComponent, FooterComponent]
  ├── imports: [BrowserModule, RouterModule, HttpClientModule]
  └── exports: [HeaderComponent]

To use HeaderComponent elsewhere:
  shared.module.ts
    ├── imports: [HeaderComponent's module]
    └── exports: [HeaderComponent]

  feature.module.ts
    └── imports: [SharedModule]  ← needed just for HeaderComponent!

AFTER: Standalone component architecture

header.component.ts (self-contained)
  └── standalone: true
  └── imports: [CommonModule, RouterLink]  ← declares its OWN dependencies

feature.component.ts
  └── imports: [HeaderComponent]  ← directly imports what it needs
```

**Code comparison — Before vs After:**

```typescript
// ============================================================
// BEFORE (v13 and earlier): NgModule-based component
// ============================================================

// header.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
  // ← No standalone flag, no imports array here
  // ← Must be declared in a module somewhere
})
export class HeaderComponent {
  title = 'My App';
}

// shared.module.ts — REQUIRED in old approach
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HeaderComponent } from './header.component';

@NgModule({
  declarations: [
    HeaderComponent  // ← Every component must be declared in exactly ONE module
  ],
  imports: [
    CommonModule,    // ← HeaderComponent needs these, declared at module level
    RouterModule
  ],
  exports: [
    HeaderComponent  // ← Must be exported to be used elsewhere
  ]
})
export class SharedModule {}

// feature.module.ts — REQUIRED just to use HeaderComponent
import { NgModule } from '@angular/core';
import { SharedModule } from '../shared/shared.module';

@NgModule({
  imports: [
    SharedModule  // ← Import entire shared module just for one component
  ]
})
export class FeatureModule {}
```

```typescript
// ============================================================
// AFTER (v14+): Standalone component
// ============================================================

// header.component.ts
import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';  // ← import directly, no module needed
import { NgClass } from '@angular/common';      // ← import what you need specifically

@Component({
  selector: 'app-header',
  standalone: true,          // ← THE key flag: this component manages itself
  imports: [
    RouterLink,              // ← Declares its own Angular dependencies
    NgClass                  // ← Only imports what it actually uses
  ],
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent {
  title = 'My App';
}

// feature.component.ts — Uses HeaderComponent directly, no module needed
import { Component } from '@angular/core';
import { HeaderComponent } from '../shared/header.component'; // ← direct import

@Component({
  selector: 'app-feature',
  standalone: true,
  imports: [
    HeaderComponent  // ← Just import the component directly, like a TypeScript import
  ],
  template: `
    <app-header />
    <main>Feature content here</main>
  `
})
export class FeatureComponent {}
```

**Key benefits of standalone components:**
- Tree-shakable: unused components are excluded from the bundle automatically
- Self-documenting: the `imports` array shows exactly what a component needs
- Easier testing: no need to create TestBed module configurations
- Better IDE tooling: direct TypeScript import traceability

### 22.2.2 Strictly Typed Reactive Forms

**The problem typed forms solve:**

Before v14, every reactive form value had type `any`. This meant TypeScript could not catch bugs like accessing `.email` on a form that has no email field, or assigning a number to a field that should be a string. The compiler was blind to your form structure.

**Analogy:** Untyped forms are like a filing cabinet with unlabeled folders — you can put anything anywhere, and when you reach in to get something, you have no guarantee about what you will pull out. Typed forms are like a filing cabinet with labeled, indexed folders where the filing system physically prevents you from putting the wrong document in the wrong folder.

```
BEFORE (Untyped Forms):
  formGroup.value ──→ type: any
  formGroup.get('email')?.value ──→ type: any
  TypeScript: "I have no idea what type this is. Good luck!"

AFTER (Typed Forms):
  formGroup.value ──→ type: { email: string | null, age: number | null }
  formGroup.get('email')?.value ──→ type: string | null
  TypeScript: "email must be string | null, you cannot assign a number here!"
```

**Code comparison:**

```typescript
// ============================================================
// BEFORE (v13 and earlier): Untyped forms — runtime bugs only
// ============================================================
import { FormBuilder, FormGroup } from '@angular/forms';

@Component({ /* ... */ })
export class LoginComponent {
  // ← FormGroup has no type parameter — everything is 'any'
  loginForm: FormGroup;

  constructor(private fb: FormBuilder) {
    this.loginForm = this.fb.group({
      email: [''],     // ← TypeScript thinks this is 'any'
      password: [''],  // ← TypeScript thinks this is 'any'
      rememberMe: [false]
    });
  }

  onSubmit() {
    const email = this.loginForm.value.email;     // ← type: any (no help from TypeScript!)
    const password = this.loginForm.value.pasword; // ← TYPO! TypeScript won't catch this
    const age = this.loginForm.value.age;          // ← 'age' doesn't exist! No error!

    // This compiles fine but crashes at runtime:
    email.toUpperCase(); // ← If email is null, this crashes. TypeScript doesn't warn you.
  }
}
```

```typescript
// ============================================================
// AFTER (v14+): Typed forms — compile-time safety
// ============================================================
import { Component } from '@angular/core';
import { FormControl, FormGroup, NonNullableFormBuilder, Validators } from '@angular/forms';

// ← Define your form's interface explicitly for maximum clarity
interface LoginForm {
  email: FormControl<string>;     // ← string (not null) because NonNullable
  password: FormControl<string>;  // ← string (not null)
  rememberMe: FormControl<boolean>;
}

@Component({
  selector: 'app-login',
  standalone: true,
  template: `...`
})
export class LoginComponent {
  // ← FormGroup is now typed: FormGroup<LoginForm>
  loginForm: FormGroup<LoginForm>;

  constructor(private fb: NonNullableFormBuilder) {
    // ← NonNullableFormBuilder ensures controls return their base type, not T | null
    this.loginForm = this.fb.group<LoginForm>({
      email: this.fb.control('', Validators.required),      // ← type inferred as string
      password: this.fb.control('', Validators.required),   // ← type inferred as string
      rememberMe: this.fb.control(false)                    // ← type inferred as boolean
    });
  }

  onSubmit() {
    const email = this.loginForm.value.email;       // ← type: string | undefined (partial value)
    const password = this.loginForm.value.pasword;  // ← COMPILE ERROR: 'pasword' doesn't exist!
    const age = this.loginForm.value.age;           // ← COMPILE ERROR: 'age' doesn't exist!

    // getRawValue() gets ALL values (including disabled controls) as the full type
    const rawValue = this.loginForm.getRawValue();
    // ← rawValue type: { email: string, password: string, rememberMe: boolean }
    // ← No undefined! All fields present.
    rawValue.email.toUpperCase(); // ← Safe! TypeScript knows email is string.
  }
}
```

**`.value` vs `.getRawValue()` — The important distinction:**

```typescript
// .value — type includes 'undefined' for disabled controls
// If a control is disabled, it is excluded from .value
const partialValue = form.value;
// type: { email?: string, password?: string, rememberMe?: boolean }
// ← Notice the ? — disabled controls won't appear

// .getRawValue() — type is the full, non-partial type
// Gets ALL control values including disabled ones
const fullValue = form.getRawValue();
// type: { email: string, password: string, rememberMe: boolean }
// ← No ? — all controls present regardless of disabled state
```

| Method | Type | Disabled Controls | Use When |
|--------|------|-------------------|----------|
| `.value` | `Partial<T>` | Excluded | You want to exclude disabled field values |
| `.getRawValue()` | `T` | Included | You need all values for form submission |

### 22.2.3 The inject() Function

**The problem inject() solves:**

Constructor injection has been Angular's primary DI mechanism since v1. But with the rise of functional guards, resolvers, and interceptors (introduced in v15), there was no `this` and no constructor to inject into. The `inject()` function solves this by allowing dependency injection anywhere during the injection context.

**Analogy:** Constructor injection is like having a receptionist who greets you when you enter the building and hands you everything you need upfront. `inject()` is like having a vending machine anywhere in the building — you can get what you need on-demand, wherever you are, not just at the entrance.

```
Constructor Injection (Traditional):
  enter class → constructor runs → dependencies handed in → you use them

inject() Function (New):
  call inject(SomeService) from anywhere → DI container provides it
  Works in: constructors, field initializers, functional guards,
            functional resolvers, functional interceptors, any
            code running inside an injection context
```

**Code comparison — Constructor vs inject():**

```typescript
// ============================================================
// BEFORE: Constructor injection (still valid, not deprecated)
// ============================================================
import { Component, OnInit } from '@angular/core';
import { UserService } from './user.service';
import { LogService } from './log.service';
import { AnalyticsService } from './analytics.service';

@Component({ selector: 'app-user', standalone: true, template: '' })
export class UserComponent implements OnInit {
  // ← Constructor injection: all services listed as constructor parameters
  // ← Long constructor parameter lists are a code smell ("constructor bloat")
  constructor(
    private userService: UserService,
    private logService: LogService,
    private analyticsService: AnalyticsService
    // ← Imagine 5-6 more services here — common in large components!
  ) {}

  ngOnInit() {
    this.userService.getUser();
    this.logService.log('UserComponent initialized');
  }
}
```

```typescript
// ============================================================
// AFTER: inject() function (v14+)
// ============================================================
import { Component, OnInit, inject } from '@angular/core';
import { UserService } from './user.service';
import { LogService } from './log.service';
import { AnalyticsService } from './analytics.service';

@Component({ selector: 'app-user', standalone: true, template: '' })
export class UserComponent implements OnInit {
  // ← inject() as field initializers — cleaner, no constructor needed
  private userService = inject(UserService);         // ← inject at field level
  private logService = inject(LogService);           // ← TypeScript infers the type
  private analyticsService = inject(AnalyticsService);

  // ← No constructor needed! Component is cleaner.
  // ← If you DO have a constructor, inject() still works inside it.

  ngOnInit() {
    this.userService.getUser();
    this.logService.log('UserComponent initialized');
  }
}
```

**inject() in functional guards (the real power — covered in section 22.3):**

```typescript
// inject() is ESSENTIAL for functional guards because there's no class constructor
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

// ← This is a plain function, not a class — no constructor!
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService); // ← inject() works here because Angular
  const router = inject(Router);           //   runs this in an injection context

  if (authService.isAuthenticated()) {
    return true;
  }

  router.navigate(['/login']);
  return false;
};
```

**Common mistake — calling inject() outside injection context:**

```typescript
// WRONG: inject() called outside Angular's injection context
export class MyService {
  private http = inject(HttpClient); // ← Works! Field initializer runs in injection context

  fetchData() {
    // WRONG: inject() called inside a regular method — NOT in injection context!
    const otherService = inject(OtherService); // ← Runtime ERROR!
    // ← Angular says: "inject() must be called from an injection context"
    // ← Injection context = constructor, field initializer, or during module/component setup
  }
}

// CORRECT: inject() only at class field level or in constructor
export class MyService {
  private http = inject(HttpClient);     // ← Correct: field initializer
  private other = inject(OtherService); // ← Correct: field initializer

  fetchData() {
    // ← Use this.http and this.other here — they're already injected
    return this.http.get('/api/data');
  }
}
```

---

## 22.3 Angular 15 — Standalone APIs Stable & Simplified

### The Big Picture

Angular 15 (November 2022) promoted Standalone Components from "Developer Preview" to stable production status, and introduced a complete set of standalone-friendly APIs that replace the old NgModule-based imports. Angular 15 also introduced functional guards/resolvers and the NgOptimizedImage directive.

### 22.3.1 Standalone APIs Made Stable

**The problem:** Even with standalone components, you still needed `AppModule` to bootstrap the app and configure providers like the Router and HttpClient. Angular 15 provides standalone equivalents for all of this.

```
OLD WAY (NgModule bootstrap):
  main.ts
    └── platformBrowserDynamic().bootstrapModule(AppModule)

  app.module.ts
    └── imports: [
          BrowserModule,
          RouterModule.forRoot(routes),    ← old
          HttpClientModule,               ← old
          BrowserAnimationsModule         ← old
        ]

NEW WAY (Standalone bootstrap):
  main.ts
    └── bootstrapApplication(AppComponent, {
          providers: [
            provideRouter(routes),          ← new, functional, tree-shakable
            provideHttpClient(),            ← new, functional, tree-shakable
            provideAnimations()             ← new, functional, tree-shakable
          ]
        })
```

**Complete standalone app setup example:**

```typescript
// ============================================================
// main.ts — Standalone application bootstrap (v15+)
// ============================================================
import { bootstrapApplication } from '@angular/platform-browser'; // ← new bootstrap function
import { provideRouter, withPreloading, PreloadAllModules } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { AppComponent } from './app/app.component';
import { routes } from './app/app.routes';
import { authInterceptor } from './app/interceptors/auth.interceptor';

bootstrapApplication(
  AppComponent, // ← Root component (must be standalone: true)
  {
    providers: [
      // ← provideRouter replaces RouterModule.forRoot()
      // ← withPreloading() is a "feature" — tree-shakable router configuration
      provideRouter(
        routes,
        withPreloading(PreloadAllModules),  // ← optional: preload strategy
        // withDebugTracing(),              // ← optional: log route events
        // withHashLocation(),             // ← optional: use hash-based URLs
      ),

      // ← provideHttpClient replaces HttpClientModule
      // ← withInterceptors() takes functional interceptors
      provideHttpClient(
        withInterceptors([authInterceptor])  // ← functional interceptors (see below)
      ),

      // ← provideAnimations replaces BrowserAnimationsModule
      // ← Use provideNoopAnimations() for testing (disables animations)
      provideAnimations(),
    ]
  }
).catch(err => console.error(err));
```

```typescript
// ============================================================
// app.component.ts — Root component must be standalone
// ============================================================
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';  // ← import directly, no RouterModule
import { HeaderComponent } from './layout/header.component';
import { FooterComponent } from './layout/footer.component';

@Component({
  selector: 'app-root',
  standalone: true,                         // ← Must be standalone
  imports: [
    RouterOutlet,    // ← Just import RouterOutlet, not entire RouterModule
    HeaderComponent,
    FooterComponent
  ],
  template: `
    <app-header />
    <router-outlet />
    <app-footer />
  `
})
export class AppComponent {
  title = 'my-standalone-app';
}
```

```typescript
// ============================================================
// app.routes.ts — Route configuration (standalone-friendly)
// ============================================================
import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';   // ← functional guard

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'home',
    pathMatch: 'full'
  },
  {
    path: 'home',
    // ← loadComponent for standalone components (replaces loadChildren for single components)
    loadComponent: () => import('./features/home/home.component')
      .then(m => m.HomeComponent)
  },
  {
    path: 'dashboard',
    canActivate: [authGuard],  // ← functional guard used directly
    // ← loadChildren with a routes array (no NgModule needed)
    loadChildren: () => import('./features/dashboard/dashboard.routes')
      .then(m => m.DASHBOARD_ROUTES)
  },
  {
    path: '**',
    loadComponent: () => import('./features/not-found/not-found.component')
      .then(m => m.NotFoundComponent)
  }
];
```

**Comparison table — Old NgModule imports vs new Standalone providers:**

| Old (NgModule) | New (Standalone) | Key Difference |
|----------------|-----------------|----------------|
| `RouterModule.forRoot(routes)` | `provideRouter(routes)` | Tree-shakable, features are separate |
| `RouterModule.forChild(routes)` | `provideRouter(routes)` in child | Or just export `Routes` array |
| `HttpClientModule` | `provideHttpClient()` | Supports functional interceptors |
| `BrowserAnimationsModule` | `provideAnimations()` | Identical behavior |
| `NoopAnimationsModule` | `provideNoopAnimations()` | For testing |
| `BrowserModule` | Not needed (included in bootstrapApplication) | Automatically provided |

### 22.3.2 Functional Guards & Resolvers

**The problem class-based guards have:**

Class-based guards are verbose. You need a class with a specific interface, a method with a specific signature, and the class must be provided somewhere. For a simple auth check, this is significant ceremony.

**Analogy:** Class-based guards are like hiring a full-time security officer with a badge, office, and employment contract just to check IDs at the door. Functional guards are like installing an automated turnstile — same security check, far less overhead.

**Before vs After — CanActivate guard:**

```typescript
// ============================================================
// BEFORE: Class-based guard (v14 and earlier)
// ============================================================

// auth.guard.ts
import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'  // ← Must be provided (either here or in a module)
})
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,  // ← Constructor injection
    private router: Router
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean> | Promise<boolean> | boolean {
    if (this.authService.isAuthenticated()) {
      return true;
    }
    this.router.navigate(['/login']);
    return false;
  }
}

// app-routing.module.ts — registering the guard
{
  path: 'dashboard',
  canActivate: [AuthGuard],  // ← reference the class
  component: DashboardComponent
}
```

```typescript
// ============================================================
// AFTER: Functional guard (v15+) — much simpler
// ============================================================

// auth.guard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

// ← Just a function! No class, no interface, no @Injectable, no constructor
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService); // ← inject() works inside functional guards
  const router = inject(Router);           // ← because Angular runs them in injection context

  if (authService.isAuthenticated()) {
    return true; // ← Route is accessible
  }

  // ← Redirect to login and block the route
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url }  // ← Pass return URL as query param
  });
};

// app.routes.ts — using the functional guard
{
  path: 'dashboard',
  canActivate: [authGuard],  // ← reference the function (lowercase — it's not a class)
  loadComponent: () => import('./dashboard.component').then(m => m.DashboardComponent)
}
```

**Functional Resolver example:**

```typescript
// ============================================================
// BEFORE: Class-based resolver
// ============================================================
@Injectable({ providedIn: 'root' })
export class UserResolver implements Resolve<User> {
  constructor(private userService: UserService) {}

  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    return this.userService.getUser(route.paramMap.get('id')!);
  }
}

// ============================================================
// AFTER: Functional resolver (v15+)
// ============================================================
import { inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { UserService } from './user.service';
import { User } from './user.model';

// ← ResolveFn<User> — TypeScript knows this resolves to a User
export const userResolver: ResolveFn<User> = (route, state) => {
  const userService = inject(UserService); // ← inject() for DI in functional context
  return userService.getUser(route.paramMap.get('id')!);
  // ← Return an Observable, Promise, or synchronous value
};
```

**Available functional guard types:**

| Type | Old Interface | New Function Type | Use Case |
|------|--------------|------------------|----------|
| Activate | `CanActivate` | `CanActivateFn` | Can user enter this route? |
| Activate child | `CanActivateChild` | `CanActivateChildFn` | Can user enter child routes? |
| Deactivate | `CanDeactivate<T>` | `CanDeactivateFn<T>` | Can user leave? (unsaved changes) |
| Match | `CanMatch` | `CanMatchFn` | Should this route even be considered? |
| Resolve | `Resolve<T>` | `ResolveFn<T>` | Pre-fetch data before activation |

### 22.3.3 NgOptimizedImage Directive

**The problem:** Images are the #1 cause of poor Core Web Vitals scores (LCP - Largest Contentful Paint). Developers forget to lazy-load images, don't set width/height (causing layout shift), and don't provide proper srcset for responsive images.

**Analogy:** NgOptimizedImage is like having a professional image optimizer automatically handle your photos — it adds lazy loading, generates multiple sizes for different screens, prioritizes above-the-fold images, and detects common mistakes — all automatically.

```typescript
// ============================================================
// setup: import NgOptimizedImage in your component
// ============================================================
import { NgOptimizedImage } from '@angular/common';

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [NgOptimizedImage],  // ← import the directive
  template: `
    <!-- BEFORE (plain <img>): no lazy loading, no srcset, layout shift risk -->
    <img src="/images/product.jpg" alt="Product">

    <!-- AFTER (NgOptimizedImage): use ngSrc instead of src -->

    <!-- Regular image: lazy loaded by default -->
    <img ngSrc="/images/product.jpg"   <!-- ← ngSrc instead of src -->
         alt="Product"
         width="400"                   <!-- ← width/height REQUIRED (prevents layout shift) -->
         height="300">

    <!-- Priority image (above the fold / LCP element): NOT lazy loaded -->
    <img ngSrc="/images/hero.jpg"
         alt="Hero banner"
         width="1200"
         height="600"
         priority>                     <!-- ← marks as priority, adds fetchpriority="high" -->

    <!-- With a configured image loader (e.g., Cloudinary, Imgix) -->
    <!-- The loader automatically generates srcset for responsive images -->
    <img ngSrc="product-image-id"     <!-- ← just the image ID, loader builds the URL -->
         alt="Product"
         width="400"
         height="300"
         sizes="(max-width: 768px) 100vw, 400px">  <!-- ← responsive sizes hint -->
  `
})
export class ProductCardComponent {}
```

```typescript
// Configuring an image loader (Cloudinary example)
// main.ts
import { provideImgixLoader } from '@angular/common';

bootstrapApplication(AppComponent, {
  providers: [
    // ← Tells NgOptimizedImage how to build optimized URLs
    provideImgixLoader('https://mysite.imgix.net'),
    // ← Now <img ngSrc="product.jpg"> becomes:
    // ← https://mysite.imgix.net/product.jpg?w=400&auto=format
    // ← And srcset is automatically generated for multiple widths!
  ]
});
```

**What NgOptimizedImage automatically does:**

```
Without NgOptimizedImage:
  <img src="hero.jpg">
  └── No lazy loading
  └── No srcset
  └── No fetchpriority
  └── No width/height (layout shift!)
  └── LCP score: POOR

With NgOptimizedImage:
  <img ngSrc="hero.jpg" width="1200" height="600" priority>
  └── Adds fetchpriority="high" (priority images)
  └── Adds loading="lazy" (non-priority images)
  └── Generates srcset="hero.jpg?w=400 400w, hero.jpg?w=800 800w, ..."
  └── Enforces width/height (no layout shift)
  └── Console warning if priority image is not above-the-fold
  └── LCP score: GOOD
```

### 22.3.4 Simplified Router Lazy Loading

```typescript
// ============================================================
// loadComponent — for loading a single standalone component lazily
// ============================================================
const routes: Routes = [
  {
    path: 'profile',
    // ← Dynamic import returns the component class directly
    loadComponent: () =>
      import('./features/profile/profile.component')
        .then(m => m.ProfileComponent)
        // ← Angular knows it's a standalone component (standalone: true)
  }
];

// ============================================================
// loadChildren with routes array — for feature sections
// ============================================================

// dashboard.routes.ts — a routes configuration (no NgModule!)
export const DASHBOARD_ROUTES: Routes = [
  {
    path: '',      // ← empty path = this is the default route for the dashboard section
    component: DashboardHomeComponent
  },
  {
    path: 'analytics',
    component: DashboardAnalyticsComponent
  },
  {
    path: 'settings',
    loadComponent: () =>
      import('./settings/settings.component')
        .then(m => m.SettingsComponent)
  }
];

// app.routes.ts — reference the dashboard routes lazily
const routes: Routes = [
  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadChildren: () =>
      import('./features/dashboard/dashboard.routes')
        .then(m => m.DASHBOARD_ROUTES)  // ← load the Routes array, not an NgModule
  }
];
```

---

## 22.4 Angular 16 — Signals & Hydration

### The Big Picture

Angular 16 (May 2023) was a pivotal release. It introduced Signals as a new reactive primitive that could eventually replace Zone.js entirely. It also significantly improved Server-Side Rendering (SSR) with non-destructive hydration, and introduced quality-of-life improvements like required inputs and the `takeUntilDestroyed` operator.

### 22.4.1 Signals (Developer Preview)

Signals were introduced in v16 as a developer preview. For full signal coverage, see Phase 12. This section focuses on what's specifically new and why signals were introduced in the context of Angular's evolution.

**The core problem with Zone.js:**

Zone.js is a library that monkey-patches every async API in the browser (setTimeout, Promise, fetch, addEventListener, etc.) to notify Angular when something might have changed. Angular then runs change detection on the entire component tree.

```
Zone.js Change Detection (BEFORE Signals):
  User clicks button
    └── Zone.js intercepts the click event
    └── Notifies Angular: "something might have changed!"
    └── Angular walks EVERY component in the tree
    └── Angular checks EVERY binding in EVERY component
    └── Even components that clearly didn't change!
    └── Performance degrades with large component trees

Signals Change Detection (AFTER Signals):
  User clicks button
    └── Handler updates a signal: count.set(count() + 1)
    └── Angular knows EXACTLY which components use `count`
    └── Angular re-renders ONLY those specific components
    └── No full tree walk!
    └── Performance is excellent even with huge component trees
```

**Basic signal API (v16 preview — stable in v18):**

```typescript
import { Component, signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <p>Count: {{ count() }}</p>          <!-- ← call signal like a function to read -->
    <p>Double: {{ double() }}</p>        <!-- ← computed signal updates automatically -->
    <button (click)="increment()">+</button>
    <button (click)="decrement()">-</button>
    <button (click)="reset()">Reset</button>
  `
})
export class CounterComponent {
  // ← signal() creates a reactive value
  // ← Type is inferred: signal<number>(0)
  count = signal(0);

  // ← computed() creates a derived signal that updates when dependencies change
  // ← Angular automatically tracks which signals are read inside computed()
  double = computed(() => this.count() * 2);

  // ← effect() runs side effects when signals change
  // ← Similar to ngOnChanges but reactive
  constructor() {
    effect(() => {
      // ← This runs whenever count() changes
      console.log(`Count changed to: ${this.count()}`);
      // ← Angular tracks that this effect reads count()
      // ← When count changes, Angular re-runs this effect
    });
  }

  increment() {
    this.count.update(c => c + 1);  // ← update() takes a function (old value → new value)
  }

  decrement() {
    this.count.update(c => c - 1);
  }

  reset() {
    this.count.set(0);  // ← set() takes the new value directly
  }
}
```

### 22.4.2 Required Inputs

**The problem:** Before v16, all `@Input()` properties were optional. If you forgot to pass a required input, you would get a runtime error (or worse, `undefined` silently used). There was no compile-time enforcement.

```typescript
// ============================================================
// BEFORE (v15 and earlier): No way to enforce required inputs
// ============================================================

@Component({ selector: 'app-user-card', standalone: true, template: '' })
export class UserCardComponent {
  @Input() userId!: string;   // ← The ! says "trust me, this will be set"
  // ← But nothing prevents the parent from NOT passing userId!
  // ← Using userId without passing it gives undefined at runtime — no compile error
}

// In parent template — TypeScript does NOT catch this mistake:
// <app-user-card></app-user-card>  ← Missing userId! Runtime error, not compile error.
```

```typescript
// ============================================================
// AFTER (v16+): required: true enforces inputs at compile time
// ============================================================

@Component({ selector: 'app-user-card', standalone: true, template: '' })
export class UserCardComponent {
  // ← { required: true } — Angular CLI and TypeScript both enforce this
  @Input({ required: true }) userId!: string;

  // ← Optional inputs still work the same way
  @Input() displayName: string = 'Anonymous';

  // ← Required with a transform function (v16.1+)
  @Input({ required: true, transform: (v: string) => v.trim() }) email!: string;
}

// In parent template — TypeScript CATCHES this mistake at compile time:
// <app-user-card></app-user-card>
// ← ERROR: Required input 'userId' from component UserCardComponent must be specified.

// Correct usage:
// <app-user-card userId="123" />  ← Compile-time check passes
```

### 22.4.3 Non-Destructive Hydration

**The problem with SSR hydration before v16:**

Angular SSR (Server-Side Rendering) renders your app on the server, sends the HTML to the browser, and then Angular "boots up" in the browser. The old approach was **destructive hydration**: Angular would throw away the server-rendered DOM and rebuild it from scratch. This caused:
- A flash of content (FCP to FMP flicker)
- Re-fetching data that was already fetched on the server
- Poor Core Web Vitals scores

```
BEFORE (Destructive Hydration):
  Server renders HTML ──→ Browser receives HTML (LCP looks good!)
                               └── Angular boots up
                               └── Angular DESTROYS server HTML
                               └── Angular rebuilds DOM from scratch
                               └── Visual flicker!
                               └── Data re-fetched!
                               └── LCP: POOR (content disappeared briefly)

AFTER (Non-Destructive Hydration, v16+):
  Server renders HTML ──→ Browser receives HTML (LCP looks good!)
                               └── Angular boots up
                               └── Angular REUSES server HTML
                               └── Angular attaches event listeners to existing DOM
                               └── No flicker!
                               └── Data already present!
                               └── LCP: EXCELLENT
```

**Setup:**

```typescript
// main.ts — enable non-destructive hydration
import { bootstrapApplication } from '@angular/platform-browser';
import { provideClientHydration } from '@angular/platform-browser'; // ← v16+

bootstrapApplication(AppComponent, {
  providers: [
    provideClientHydration(), // ← This single provider enables non-destructive hydration
    provideRouter(routes),
    provideHttpClient()
  ]
});
```

```typescript
// app.server.ts — for SSR
import { bootstrapApplication } from '@angular/platform-browser';
import { provideServerRendering } from '@angular/platform-server';

export const appConfig = {
  providers: [
    provideServerRendering(), // ← enables SSR
    provideRouter(routes),
    provideHttpClient()
    // ← Note: provideClientHydration is NOT added here — it's client-only
  ]
};
```

### 22.4.4 DestroyRef and takeUntilDestroyed

**The problem with the old takeUntil pattern:**

The classic way to prevent memory leaks from subscriptions was the `takeUntil` + `Subject` pattern. It required boilerplate in every component and was easy to forget.

```typescript
// ============================================================
// BEFORE: The classic takeUntil pattern (repetitive boilerplate)
// ============================================================
import { Component, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({ selector: 'app-dashboard', standalone: true, template: '' })
export class DashboardComponent implements OnDestroy {
  // ← A destroy Subject — must create this in EVERY component
  private destroy$ = new Subject<void>();

  constructor(private dataService: DataService) {
    // ← Must add takeUntil to EVERY subscription
    this.dataService.getUpdates()
      .pipe(takeUntil(this.destroy$))  // ← boilerplate
      .subscribe(data => console.log(data));

    this.dataService.getAlerts()
      .pipe(takeUntil(this.destroy$))  // ← same boilerplate again
      .subscribe(alert => console.log(alert));
  }

  ngOnDestroy() {
    // ← Must remember to call this in EVERY component
    // ← If you forget, subscriptions leak!
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

```typescript
// ============================================================
// AFTER (v16+): takeUntilDestroyed operator
// ============================================================
import { Component, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop'; // ← new import
import { DestroyRef } from '@angular/core';                       // ← new in v16

@Component({ selector: 'app-dashboard', standalone: true, template: '' })
export class DashboardComponent {
  // ← No manual destroy$ Subject needed!
  // ← No implements OnDestroy needed!

  constructor(private dataService: DataService) {
    // ← takeUntilDestroyed() automatically uses the component's DestroyRef
    // ← It unsubscribes when the component is destroyed
    this.dataService.getUpdates()
      .pipe(takeUntilDestroyed())  // ← single operator, no Subject needed
      .subscribe(data => console.log(data));

    this.dataService.getAlerts()
      .pipe(takeUntilDestroyed())  // ← same — each subscription cleaned up automatically
      .subscribe(alert => console.log(alert));
    // ← No ngOnDestroy needed! takeUntilDestroyed handles cleanup.
  }
}

// ============================================================
// Using takeUntilDestroyed() OUTSIDE constructor (inject DestroyRef explicitly)
// ============================================================
@Component({ selector: 'app-feature', standalone: true, template: '' })
export class FeatureComponent implements OnInit {
  // ← When using outside constructor, get DestroyRef via inject()
  private destroyRef = inject(DestroyRef);

  ngOnInit() {
    // ← takeUntilDestroyed() can accept a DestroyRef explicitly
    this.someService.getData()
      .pipe(takeUntilDestroyed(this.destroyRef)) // ← pass destroyRef when outside constructor
      .subscribe(data => console.log(data));
  }
}
```

### 22.4.5 Self-Closing Tags

A small but delightful quality-of-life improvement in v16: Angular now supports self-closing tags for components with no content projection.

```html
<!-- BEFORE (v15 and earlier): Always need opening AND closing tags -->
<app-header></app-header>
<app-sidebar></app-sidebar>
<app-user-card [user]="user"></app-user-card>
<app-loading-spinner></app-loading-spinner>

<!-- AFTER (v16+): Self-closing tags for components without content -->
<app-header />
<app-sidebar />
<app-user-card [user]="user" />
<app-loading-spinner />

<!-- Note: Only use self-closing when the component has no ng-content slot being used -->
<!-- Components WITH content projection still need the traditional syntax: -->
<app-modal>
  <h1>Title</h1>
  <p>Body content here</p>
</app-modal>
```

---

## 22.5 Angular 17 — The Renaissance Release

### The Big Picture

Angular 17 (November 2023) was called the "Renaissance Release" by the Angular team. It introduced an entirely new template syntax for control flow, deferrable views for lazy template loading, switched to Vite + esbuild by default, and made standalone the default for new projects. The Angular logo and website were also redesigned. This was perhaps the most visually and ergonomically significant Angular release since Angular 2.

```
Angular 17 Changes at a Glance:
  ┌─────────────────────────────────────────────────────┐
  │  Template Syntax    │ *ngIf → @if                   │
  │                     │ *ngFor → @for (with track)    │
  │                     │ *ngSwitch → @switch            │
  ├─────────────────────┼───────────────────────────────┤
  │  Lazy Templates     │ @defer (deferrable views)     │
  ├─────────────────────┼───────────────────────────────┤
  │  Build System       │ Vite + esbuild (not Webpack)  │
  ├─────────────────────┼───────────────────────────────┤
  │  New Project        │ Standalone by default          │
  │  Defaults           │ No AppModule generated         │
  │                     │ SSR prompt during ng new       │
  └─────────────────────┴───────────────────────────────┘
```

### 22.5.1 New Control Flow Syntax — @if / @else

**Why the new syntax?**

The old structural directives (`*ngIf`, `*ngFor`, `*ngSwitch`) had several problems:
- They required importing `CommonModule` (or `NgIf`, `NgFor` individually)
- They used a `*` microsyntax that was non-standard and confusing to new developers
- `*ngIf`'s `as` pattern for type narrowing was awkward
- `*ngFor`'s `trackBy` was easy to forget (leading to performance bugs)
- They created extra DOM wrapper elements in some cases

**The new `@if` syntax:**

```html
<!-- ============================================================ -->
<!-- BEFORE (*ngIf): requires CommonModule or NgIf import         -->
<!-- ============================================================ -->

<!-- Basic conditional -->
<div *ngIf="isLoggedIn">Welcome back!</div>

<!-- With else (separate ng-template required) -->
<div *ngIf="isLoggedIn; else loginBlock">Welcome back!</div>
<ng-template #loginBlock>
  <div>Please log in.</div>
</ng-template>

<!-- With then and else (separate ng-templates required) -->
<div *ngIf="user; then userBlock; else loadingBlock"></div>
<ng-template #userBlock>
  <p>Hello, {{ user.name }}!</p>
</ng-template>
<ng-template #loadingBlock>
  <p>Loading...</p>
</ng-template>

<!-- Type narrowing (awkward as pattern) -->
<div *ngIf="currentUser as user">
  {{ user.name }}  <!-- ← user is narrowed here -->
</div>
```

```html
<!-- ============================================================ -->
<!-- AFTER (@if): built-in, no imports needed, clean syntax       -->
<!-- ============================================================ -->

<!-- Basic conditional — looks like regular code! -->
@if (isLoggedIn) {
  <div>Welcome back!</div>
}

<!-- With else — no ng-template needed! -->
@if (isLoggedIn) {
  <div>Welcome back!</div>
} @else {
  <div>Please log in.</div>
}

<!-- With else if — NEW! *ngIf had no else if! -->
@if (user.role === 'admin') {
  <app-admin-panel />
} @else if (user.role === 'moderator') {
  <app-moderator-panel />
} @else {
  <app-user-panel />
}

<!-- Type narrowing (clean and natural!) -->
@if (currentUser) {
  <!-- ← currentUser is narrowed to non-null/undefined here -->
  <!-- ← TypeScript knows it's not null inside this block -->
  <p>Hello, {{ currentUser.name }}!</p>
}
```

### 22.5.2 New Control Flow Syntax — @for

**The most important improvement:** `@for` makes the `track` expression **mandatory**. In the old `*ngFor`, `trackBy` was optional, leading to many developers skipping it (causing poor DOM reconciliation performance). With `@for`, you cannot forget it.

```html
<!-- ============================================================ -->
<!-- BEFORE (*ngFor): trackBy is optional and often forgotten      -->
<!-- ============================================================ -->

<!-- Basic loop — no trackBy (COMMON MISTAKE in old code!) -->
<div *ngFor="let user of users">
  {{ user.name }}
</div>

<!-- With trackBy — the correct way, but often forgotten -->
<div *ngFor="let user of users; trackBy: trackByUserId; let i = index; let isFirst = first">
  {{ i }}: {{ user.name }}
</div>

<!-- In component class — must define trackBy function separately -->
trackByUserId(index: number, user: User): number {
  return user.id;
}
```

```html
<!-- ============================================================ -->
<!-- AFTER (@for): track is REQUIRED — cannot forget it!          -->
<!-- ============================================================ -->

<!-- Basic loop — track is required (compiler error if missing) -->
@for (user of users; track user.id) {
  <!-- ← track uses the expression directly — no separate function needed! -->
  <div>{{ user.name }}</div>
}

<!-- With index, first, last, even, odd context variables -->
@for (user of users; track user.id; let i = $index; let isFirst = $first; let isLast = $last) {
  <div [class.first]="isFirst" [class.last]="isLast">
    {{ i + 1 }}: {{ user.name }}
  </div>
}

<!-- @empty block — NEW! Shows content when the array is empty -->
@for (product of products; track product.id) {
  <app-product-card [product]="product" />
} @empty {
  <!-- ← No separate *ngIf needed to handle the empty case! -->
  <p>No products found. Try adjusting your filters.</p>
}
```

**Context variables in @for:**

| Variable | Old *ngFor | New @for | Description |
|----------|-----------|---------|-------------|
| Index | `let i = index` | `let i = $index` | Current item index (0-based) |
| Count | `let count = count` | `let c = $count` | Total number of items |
| First | `let isFirst = first` | `let f = $first` | True if first item |
| Last | `let isLast = last` | `let l = $last` | True if last item |
| Even | `let isEven = even` | `let e = $even` | True if index is even |
| Odd | `let isOdd = odd` | `let o = $odd` | True if index is odd |

### 22.5.3 New Control Flow Syntax — @switch

```html
<!-- ============================================================ -->
<!-- BEFORE (*ngSwitch): verbose, requires attribute on element    -->
<!-- ============================================================ -->
<div [ngSwitch]="userRole">
  <div *ngSwitchCase="'admin'">Admin Dashboard</div>
  <div *ngSwitchCase="'moderator'">Moderator Tools</div>
  <div *ngSwitchCase="'user'">User Profile</div>
  <div *ngSwitchDefault>Unknown Role</div>
</div>
<!-- ← The outer <div> is just a wrapper for the switch — extra DOM element -->
```

```html
<!-- ============================================================ -->
<!-- AFTER (@switch): clean, no wrapper element needed            -->
<!-- ============================================================ -->
@switch (userRole) {
  @case ('admin') {
    <app-admin-dashboard />
  }
  @case ('moderator') {
    <app-moderator-tools />
  }
  @case ('user') {
    <app-user-profile />
  }
  @default {
    <p>Unknown role. Contact support.</p>
  }
}
```

### 22.5.4 Deferrable Views (@defer)

**This is one of the most powerful features in Angular 17.** Deferrable views allow you to lazily load parts of a template — including the component code, its dependencies, and its data — based on specific triggers.

**The problem they solve:** Even with lazy-loaded routes, every component on a route is bundled and rendered together. If your dashboard has a heavy chart component, a data table, and analytics widgets, they all load together even if the user might never scroll down to see them.

**Analogy:** Imagine a restaurant where every dish on the menu is prepared and brought to your table when you sit down — even dishes you never ordered. `@defer` is like having dishes prepared only when you order them. `@defer (on viewport)` is like the waiter watching to see which dish you are about to reach for, and preparing it just before you would notice the wait.

```
BEFORE: All components load together when route activates
  Route loads → ALL components initialized → Bundle downloaded
  ┌────────────────────────────────────────────┐
  │ Dashboard                                  │
  │  ┌──────────┐ ┌────────────┐ ┌──────────┐ │
  │  │ Summary  │ │  Heavy     │ │Analytics │ │
  │  │ (fast)   │ │  Chart     │ │ Widget   │ │
  │  │ 10kb     │ │  (slow)    │ │ (slow)   │ │
  │  │          │ │  500kb     │ │ 200kb    │ │
  │  └──────────┘ └────────────┘ └──────────┘ │
  └────────────────────────────────────────────┘
  Initial load: 710kb — SLOW

AFTER: @defer loads components on demand
  Route loads → Summary loads immediately → Others deferred
  ┌────────────────────────────────────────────┐
  │ Dashboard                                  │
  │  ┌──────────┐ ┌────────────┐ ┌──────────┐ │
  │  │ Summary  │ │ [Loading   │ │[Skeleton]│ │
  │  │ (loaded) │ │  spinner]  │ │          │ │
  │  │ 10kb     │ │ loads when │ │loads on  │ │
  │  │          │ │ in viewport│ │ hover    │ │
  │  └──────────┘ └────────────┘ └──────────┘ │
  └────────────────────────────────────────────┘
  Initial load: 10kb — FAST
  Chart loads: when user scrolls to it
  Analytics loads: when user hovers over its area
```

**Complete @defer example:**

```html
<!-- dashboard.component.html -->

<!-- Eagerly loaded — shows immediately -->
<app-dashboard-summary [stats]="summaryStats" />

<!-- ============================================================ -->
<!-- @defer: lazy loads HeavyChartComponent when it enters the    -->
<!-- viewport. The component code itself is also lazy loaded!     -->
<!-- ============================================================ -->
@defer (on viewport) {
  <!-- ← HeavyChartComponent is loaded only when this enters viewport -->
  <!-- ← The JavaScript bundle for HeavyChartComponent is split out -->
  <app-heavy-chart [data]="chartData" />
}
@placeholder {
  <!-- ← Shown BEFORE the defer block loads (immediately visible) -->
  <!-- ← Placeholder is part of the initial bundle (keep it small!) -->
  <div class="chart-skeleton" style="height: 400px; background: #f0f0f0;">
    <p>Chart loading...</p>
  </div>
}
@loading (minimum 300ms) {
  <!-- ← Shown WHILE the deferred content is loading -->
  <!-- ← minimum 300ms prevents flash of loading state -->
  <div class="loading-overlay">
    <app-spinner />
    <p>Loading chart...</p>
  </div>
}
@error {
  <!-- ← Shown if the deferred content FAILS to load -->
  <!-- ← (e.g., network error, module import failure) -->
  <div class="error-message">
    <p>Failed to load chart. <button (click)="retryChart()">Retry</button></p>
  </div>
}

<!-- ============================================================ -->
<!-- @defer with interaction trigger                               -->
<!-- ============================================================ -->
@defer (on interaction) {
  <!-- ← Loads when the user clicks or focuses on the placeholder -->
  <app-analytics-widget [data]="analyticsData" />
}
@placeholder {
  <button class="load-analytics-btn">
    Click to load analytics
  </button>
}

<!-- ============================================================ -->
<!-- @defer with hover trigger                                     -->
<!-- ============================================================ -->
@defer (on hover) {
  <app-tooltip-content [data]="tooltipData" />
}
@placeholder {
  <span class="info-icon">ℹ</span>
}

<!-- ============================================================ -->
<!-- @defer with timer trigger (loads after 5 seconds)            -->
<!-- ============================================================ -->
@defer (on timer(5000)) {
  <app-promotional-banner />
}
@placeholder {
  <div></div>  <!-- ← Empty placeholder while waiting -->
}

<!-- ============================================================ -->
<!-- @defer with when condition (signal or boolean expression)     -->
<!-- ============================================================ -->
@defer (when isUserAuthenticated()) {
  <!-- ← Loads when the condition becomes true -->
  <app-user-preferences />
}
@placeholder {
  <div>Sign in to see preferences</div>
}

<!-- ============================================================ -->
<!-- @defer with prefetch — load JS early, render later           -->
<!-- ============================================================ -->
@defer (on viewport; prefetch on idle) {
  <!-- ← Shows when in viewport, but PREFETCHES the JS bundle on idle -->
  <!-- ← Great for above-the-fold content that might not be immediately visible -->
  <app-feature-section />
}
@placeholder {
  <div class="section-skeleton"></div>
}
```

**All @defer trigger conditions:**

| Trigger | Syntax | When it loads |
|---------|--------|---------------|
| Viewport | `on viewport` | When placeholder enters the viewport |
| Interaction | `on interaction` | When user clicks or focuses the placeholder |
| Hover | `on hover` | When user hovers over the placeholder |
| Idle | `on idle` | When browser is idle (requestIdleCallback) |
| Timer | `on timer(2000)` | After specified milliseconds |
| Condition | `when signal()` | When expression becomes truthy |
| Immediate | (no trigger) | As soon as possible (but still lazy) |

### 22.5.5 Angular 17 New Project Defaults

When you run `ng new my-app` with Angular 17+, the generated project is dramatically different:

```
ng new my-app (Angular 16 and earlier):
  ├── src/app/
  │   ├── app.module.ts        ← Generated (NgModule)
  │   ├── app-routing.module.ts ← Generated (routing NgModule)
  │   └── app.component.ts     ← NOT standalone by default

ng new my-app (Angular 17+):
  ├── src/app/
  │   ├── app.component.ts     ← Standalone (no app.module.ts!)
  │   ├── app.routes.ts        ← Routes array (no routing NgModule)
  │   └── app.config.ts        ← App configuration with providers
  │
  ├── (No app.module.ts!)      ← NgModule is gone by default!
  │
  And you're asked: "Do you want to enable SSR?" during setup
```

```typescript
// app.config.ts — Generated by Angular 17+ (replaces app.module.ts)
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }), // ← coalescse multiple events
    provideRouter(routes)
  ]
};
```

### 22.5.6 Application Builder (esbuild + Vite)

Angular 17 switched the default build tool from Webpack to **esbuild** (for production builds) and **Vite** (for development server).

```
BEFORE (Webpack):
  Cold start dev server:    ~30 seconds for large apps
  Hot Module Replacement:   ~2-5 seconds per change
  Production build:         ~3-10 minutes for large apps

AFTER (esbuild + Vite):
  Cold start dev server:    ~1-3 seconds for large apps
  Hot Module Replacement:   ~200ms per change
  Production build:         ~30-90 seconds for large apps

Performance improvement: 4-10x faster builds!
```

```json
// angular.json — Application builder (v17+ default)
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          // ← New application builder (was :browser before v17)
          "builder": "@angular-devkit/build-angular:application",
          "options": {
            "outputPath": "dist/my-app",
            "index": "src/index.html",
            "browser": "src/main.ts",     // ← 'browser' entry (was 'main')
            "polyfills": ["zone.js"],
            "tsConfig": "tsconfig.app.json",
            "assets": ["src/favicon.ico", "src/assets"],
            "styles": ["src/styles.scss"],
            "scripts": []
          }
        }
      }
    }
  }
}
```

---

## 22.6 Angular 18 — Stabilizing the Future

### The Big Picture

Angular 18 (May 2024) focused on stabilizing the new primitives introduced in v16 and v17. Signals graduated to stable status, zoneless change detection was introduced as an experimental option, Material Design 3 support landed, and route redirects gained function support.

### 22.6.1 Signals Stable — input(), output(), model()

In Angular 18, the signal API expanded significantly with new signal-based equivalents for `@Input()`, `@Output()`, and `[(ngModel)]`:

```typescript
import { Component, input, output, model, computed, signal } from '@angular/core';

@Component({
  selector: 'app-quantity-picker',
  standalone: true,
  template: `
    <button (click)="decrement()">-</button>
    <span>{{ quantity() }}</span>   <!-- ← model signal read like a function -->
    <button (click)="increment()">+</button>

    <p>Max allowed: {{ max() }}</p>  <!-- ← input signal read like a function -->
  `
})
export class QuantityPickerComponent {
  // ← input() replaces @Input()
  // ← Returns a Signal<number> — reads are reactive
  max = input<number>(10);               // ← optional input with default value 10
  label = input.required<string>();      // ← required input (compile error if not passed)

  // ← model() replaces @Input() + @Output() for two-way binding
  // ← model() creates a WritableSignal that automatically emits changes to parent
  quantity = model<number>(1);           // ← initial value 1

  // ← output() replaces @Output() EventEmitter
  // ← Does NOT return a signal — it's an event emitter
  outOfStock = output<void>();           // ← emits void when out of stock
  quantityChanged = output<number>();    // ← emits number when quantity changes

  // ← computed() works with input signals naturally
  isAtMax = computed(() => this.quantity() >= this.max());

  increment() {
    if (this.isAtMax()) {
      this.outOfStock.emit(); // ← emit the output signal
      return;
    }
    this.quantity.update(q => q + 1); // ← update the model signal
    this.quantityChanged.emit(this.quantity()); // ← emit the output
  }

  decrement() {
    if (this.quantity() > 0) {
      this.quantity.update(q => q - 1);
    }
  }
}
```

```html
<!-- Parent template using QuantityPickerComponent -->
<app-quantity-picker
  [max]="20"
  [(quantity)]="cartItemQuantity"
  (outOfStock)="handleOutOfStock()"
  (quantityChanged)="updateCart($event)"
/>
<!-- ← [(quantity)] is two-way binding with model() — same syntax as ngModel! -->
```

**viewChild() and contentChild() signal queries:**

```typescript
import { Component, viewChild, viewChildren, contentChild, ElementRef, AfterViewInit } from '@angular/core';
import { ChartComponent } from './chart.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  template: `
    <div #container>
      <app-chart #mainChart />
      <app-chart #secondaryChart />
    </div>
  `
})
export class DashboardComponent {
  // ← viewChild() returns a Signal<ElementRef | undefined>
  // ← No need to implement AfterViewInit to access it!
  container = viewChild<ElementRef>('container');    // ← query by template ref variable

  // ← viewChild.required() — signal is Signal<T> not Signal<T | undefined>
  mainChart = viewChild.required(ChartComponent);   // ← query by component type

  // ← viewChildren() returns Signal<ReadonlyArray<T>>
  allCharts = viewChildren(ChartComponent);

  someMethod() {
    // ← Access signal values anywhere (not just in lifecycle hooks!)
    const containerEl = this.container();  // ← ElementRef | undefined
    const chart = this.mainChart();        // ← ChartComponent (always defined — required)
    const charts = this.allCharts();       // ← ReadonlyArray<ChartComponent>

    chart.refresh(); // ← Call methods on queried components
  }
}
```

### 22.6.2 Zoneless Angular (Experimental)

**The vision:** Completely removing Zone.js from Angular applications, using Signals as the sole change detection trigger. Smaller bundles, better performance, and predictable updates.

```typescript
// main.ts — Experimental Zoneless change detection
import { bootstrapApplication } from '@angular/platform-browser';
import { provideExperimentalZonelessChangeDetection } from '@angular/core'; // ← v18

bootstrapApplication(AppComponent, {
  providers: [
    provideExperimentalZonelessChangeDetection(), // ← replaces Zone.js
    // ← Change detection now ONLY triggers when:
    //   1. A signal value changes
    //   2. markForCheck() is called manually
    //   3. An async pipe emits a new value
  ]
});
```

```json
// angular.json — Remove zone.js from polyfills
{
  "polyfills": []
  // ← Previously: ["zone.js"]
  // ← Without Zone.js, the bundle is ~100kb smaller!
}
```

**What changes in zoneless mode:**

```typescript
// ← In zoneless mode, signals MUST be used for reactive data
// ← Plain class properties do NOT trigger change detection

// WRONG in zoneless mode:
@Component({ template: '{{ name }}' })
class MyComponent {
  name = 'Angular'; // ← Plain property — changes won't be detected!

  rename() {
    this.name = 'New Name'; // ← No change detection triggered in zoneless mode!
  }
}

// CORRECT in zoneless mode:
@Component({ template: '{{ name() }}' })
class MyComponent {
  name = signal('Angular'); // ← Signal — changes trigger change detection!

  rename() {
    this.name.set('New Name'); // ← Signal update → change detection triggered!
  }
}
```

### 22.6.3 Material 3 (M3) Support

Angular Material 18 completed the migration to Material Design 3:

```typescript
// app.config.ts — Setting up Material 3 theme
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';

export const appConfig: ApplicationConfig = {
  providers: [
    provideAnimationsAsync(), // ← v18: async animations provider
    provideRouter(routes),
  ]
};
```

```scss
// styles.scss — Material 3 theme setup
@use '@angular/material' as mat;

// ← M3: theme-from-palette() replaced by define-theme()
$my-theme: mat.define-theme((
  color: (
    theme-type: light,           // ← 'light' or 'dark'
    primary: mat.$violet-palette // ← M3 palette
  ),
  typography: (
    use-system-variables: true   // ← M3: use CSS custom properties
  ),
  density: (
    scale: 0                     // ← -3 to 3, 0 is default
  )
));

html {
  @include mat.all-component-themes($my-theme); // ← Apply theme globally
}
```

### 22.6.4 Route Redirects with Functions

```typescript
// app.routes.ts — Dynamic redirectTo using a function (v18+)
export const routes: Routes = [
  {
    path: 'legacy-profile',
    // ← redirectTo can now be a function instead of a static string
    redirectTo: (redirectData) => {
      // ← redirectData contains: params, queryParams, fragment, data, etc.
      const userId = redirectData.params['id'];
      const isAdmin = redirectData.queryParams['admin'];

      // ← Return the new URL path dynamically
      if (isAdmin) {
        return `/admin/users/${userId}`;
      }
      return `/profile/${userId}`;
    }
  },
  {
    path: 'profile/:id',
    loadComponent: () => import('./profile/profile.component')
      .then(m => m.ProfileComponent)
  }
];
```

---

## 22.7 Angular 19 — Latest Features

### The Big Picture

Angular 19 (November 2024) builds on the signals foundation with powerful new APIs for data fetching, hydration improvements, and linked reactive state. This version brings the vision of a fully reactive, server-capable Angular much closer to reality.

### 22.7.1 Incremental Hydration

Building on non-destructive hydration (v16), incremental hydration allows Angular to hydrate individual parts of the page independently, triggered by the same conditions as `@defer`.

```typescript
// app.config.ts — Enable incremental hydration (v19)
import { provideClientHydration, withIncrementalHydration } from '@angular/platform-browser';

export const appConfig: ApplicationConfig = {
  providers: [
    provideClientHydration(
      withIncrementalHydration() // ← v19: hydrate parts of the page lazily
    ),
    provideRouter(routes)
  ]
};
```

```html
<!-- dashboard.component.html — Using @defer for incremental hydration -->

<!-- ← The SSR HTML is sent to the browser for ALL @defer blocks -->
<!-- ← But hydration (attaching Angular) happens only when triggered -->

<!-- This heavy component: SSR renders the HTML, but hydration deferred -->
@defer (hydrate on viewport) {
  <!-- ← HTML is in the initial response (good for SEO and LCP) -->
  <!-- ← Angular hydrates (makes interactive) only when it enters viewport -->
  <app-complex-chart [data]="chartData" />
}

@defer (hydrate on interaction) {
  <!-- ← HTML visible immediately (SSR), interactive only after click -->
  <app-interactive-table [rows]="tableData" />
}

@defer (hydrate when isReady()) {
  <!-- ← HTML visible immediately (SSR), hydrates when signal is true -->
  <app-auth-dependent-widget />
}
```

```
Incremental Hydration Flow:
  Server                        Browser
    │                              │
    ├── Render ALL HTML ──────────►│
    │   (including @defer blocks)  │ ← Full HTML in initial response (good for SEO)
    │                              │
    │                              ├── Angular boots
    │                              ├── Hydrates non-deferred components (immediate)
    │                              ├── Leaves @defer blocks as static HTML
    │                              │
    │                              ├── User scrolls to chart area
    │                              ├── Angular hydrates ONLY the chart component
    │                              └── Chart is now interactive!
```

### 22.7.2 Linked Signals

**The problem:** Sometimes you have a derived signal that should reset when its source changes. `computed()` is read-only, so you cannot modify it. Before `linkedSignal()`, you had to use `effect()` to watch changes and manually update another signal — verbose and error-prone.

**Analogy:** Imagine a shopping cart with a quantity selector. When you select a different product, the quantity should reset to 1. The quantity is "linked" to the selected product — it derives its initial value from the source but can also be independently changed.

```typescript
import { Component, signal, linkedSignal } from '@angular/core';

interface Product {
  id: number;
  name: string;
  maxQuantity: number;
}

@Component({
  selector: 'app-product-selector',
  standalone: true,
  template: `
    <select (change)="selectProduct($event)">
      @for (product of products; track product.id) {
        <option [value]="product.id">{{ product.name }}</option>
      }
    </select>

    <p>Selected: {{ selectedProduct().name }}</p>
    <p>Quantity: {{ quantity() }}</p>

    <button (click)="increment()">+</button>
    <button (click)="decrement()">-</button>
  `
})
export class ProductSelectorComponent {
  products: Product[] = [
    { id: 1, name: 'Widget', maxQuantity: 10 },
    { id: 2, name: 'Gadget', maxQuantity: 5 },
    { id: 3, name: 'Doohickey', maxQuantity: 20 }
  ];

  // ← Source signal: which product is selected
  selectedProduct = signal<Product>(this.products[0]);

  // ← linkedSignal: derived AND mutable
  // ← Resets to 1 WHENEVER selectedProduct changes
  // ← But CAN be independently changed by the user (increment/decrement)
  quantity = linkedSignal({
    source: this.selectedProduct,           // ← Watch this signal
    computation: (product) => 1,            // ← When source changes, reset quantity to 1
    // ← If user changes quantity manually, that value is used
    // ← When selectedProduct changes, computation runs again → reset to 1
  });

  // ← Simplified form: linkedSignal(() => defaultValue)
  // ← Resets to selectedProduct.maxQuantity when selectedProduct changes
  maxQuantityDisplay = linkedSignal(() => this.selectedProduct().maxQuantity);

  selectProduct(event: Event) {
    const id = Number((event.target as HTMLSelectElement).value);
    const product = this.products.find(p => p.id === id)!;
    this.selectedProduct.set(product);
    // ← quantity automatically resets to 1 (linkedSignal computation runs)
  }

  increment() {
    // ← User manually changes quantity — this is allowed!
    // ← But if selectedProduct changes later, quantity resets to 1 again
    if (this.quantity() < this.selectedProduct().maxQuantity) {
      this.quantity.update(q => q + 1);
    }
  }

  decrement() {
    if (this.quantity() > 1) {
      this.quantity.update(q => q - 1);
    }
  }
}
```

### 22.7.3 Resource API

**The problem:** Fetching async data in a signal-based component previously required RxJS or manual loading/error state management. The `resource()` API provides a declarative, signal-based way to fetch data with automatic loading and error states.

```typescript
import { Component, signal, resource, rxResource } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { inject } from '@angular/core';

interface User {
  id: number;
  name: string;
  email: string;
}

@Component({
  selector: 'app-user-detail',
  standalone: true,
  template: `
    @if (userResource.isLoading()) {
      <app-skeleton />
    } @else if (userResource.error()) {
      <p class="error">Error: {{ userResource.error() }}</p>
    } @else if (userResource.value()) {
      <div class="user-card">
        <h2>{{ userResource.value()!.name }}</h2>
        <p>{{ userResource.value()!.email }}</p>
      </div>
    }

    <button (click)="changeUser(2)">Load User 2</button>
    <button (click)="userResource.reload()">Refresh</button>
  `
})
export class UserDetailComponent {
  private http = inject(HttpClient);

  // ← Reactive source: when userId changes, resource automatically refetches
  userId = signal(1);

  // ← resource() for Promise-based fetching
  userResource = resource({
    // ← request: defines the reactive dependencies
    // ← When userId() changes, the loader runs again automatically
    request: () => ({ id: this.userId() }),  // ← Returns the request params as a signal

    // ← loader: the async function that fetches data
    // ← Receives the current request params
    loader: ({ request }) => {
      return fetch(`/api/users/${request.id}`)
        .then(res => {
          if (!res.ok) throw new Error('Failed to fetch user');
          return res.json() as Promise<User>;
        });
    }
  });

  // ← rxResource() for RxJS Observable-based fetching
  // ← Same API but loader returns an Observable instead of a Promise
  userResourceRx = rxResource({
    request: () => ({ id: this.userId() }),
    loader: ({ request }) => {
      // ← Returns Observable — automatically unsubscribed when request changes
      return this.http.get<User>(`/api/users/${request.id}`);
    }
  });

  changeUser(id: number) {
    this.userId.set(id);
    // ← userResource and userResourceRx automatically refetch!
    // ← Loading state shows, then resolved/error state
  }
}
```

**Resource state signals:**

| Signal | Type | Description |
|--------|------|-------------|
| `.value()` | `T \| undefined` | The resolved value (undefined during loading/error) |
| `.isLoading()` | `boolean` | True while request is in flight |
| `.error()` | `unknown` | The error if the request failed |
| `.status()` | `ResourceStatus` | idle / loading / resolved / error / refreshing |

### 22.7.4 Enhanced SSR — Event Replay

Angular 19 introduces **event replay** during hydration. Before event replay, if a user clicked a button while Angular was still hydrating (booting up), that click would be lost. Event replay captures user interactions before hydration and replays them after Angular is ready.

```typescript
// app.config.ts — Event replay is enabled by default with provideClientHydration()
import { provideClientHydration, withEventReplay } from '@angular/platform-browser';

export const appConfig: ApplicationConfig = {
  providers: [
    provideClientHydration(
      withEventReplay(), // ← Captures and replays events during hydration
      withIncrementalHydration() // ← Combined with incremental hydration
    )
  ]
};
```

```
Event Replay Timeline:
  t=0ms:   SSR HTML arrives, page appears interactive (it isn't yet)
  t=200ms: User clicks "Add to Cart" button
           └── WITHOUT event replay: click is LOST (Angular not ready)
           └── WITH event replay: click is CAPTURED in a queue
  t=500ms: Angular finishes hydrating
           └── Replays the "Add to Cart" click
           └── User sees their action take effect!
           └── No lost interactions!
```

---

## 22.8 Migration Guide — Step by Step

### 22.8.1 The ng update Workflow

**The golden rule: upgrade one major version at a time.**

```
CORRECT migration path:
  v14 → v15 → v16 → v17 → v18 → v19
  (run ng update at each step)

WRONG migration path:
  v14 → v19
  (skipping versions — breaking changes stack up unpredictably!)
```

**Step-by-step migration for each version:**

```bash
# ============================================================
# Step 1: Check the Angular Update Guide first!
# ============================================================
# Always visit: https://update.angular.io/
# Select your current and target version for specific instructions

# ============================================================
# Step 2: Run ng update (one major version at a time)
# ============================================================

# Upgrade from v14 to v15 (run this while on v14)
ng update @angular/core@15 @angular/cli@15

# Upgrade from v15 to v16 (run this while on v15)
ng update @angular/core@16 @angular/cli@16

# Upgrade from v16 to v17 (run this while on v16)
ng update @angular/core@17 @angular/cli@17

# Upgrade from v17 to v18 (run this while on v17)
ng update @angular/core@18 @angular/cli@18

# Upgrade from v18 to v19 (run this while on v18)
ng update @angular/core@19 @angular/cli@19

# ============================================================
# Step 3: Update other Angular packages too!
# ============================================================

# Update Angular Material (if used)
ng update @angular/material@19

# Update Angular CDK (if used)
ng update @angular/cdk@19

# Check for other Angular-related packages
ng update
# ← Lists ALL packages that can be updated
```

**What ng update does automatically:**

```
ng update:
  1. Updates package.json versions
  2. Runs npm install to get new packages
  3. Runs migration schematics automatically:
     - Renames deprecated APIs
     - Updates configuration files
     - Transforms code where possible
  4. Warns about manual steps required
```

**After each upgrade, run:**

```bash
# ← Run your full test suite after EVERY version upgrade
ng test

# ← Build to check for any compilation errors
ng build

# ← Run the app and manually verify key user flows
ng serve

# ← Check for deprecation warnings in the console
# ← Fix warnings before upgrading to the next version
```

### 22.8.2 Automated Migration Schematics

Angular provides schematics to automate common migration tasks. These are code transformation tools that modify your source files.

**Migrate to standalone components:**

```bash
# ============================================================
# Schematic: Migrate NgModule-based components to standalone
# ============================================================

# Step 1: Migrate components, directives, and pipes to standalone
ng generate @angular/core:standalone

# You will be asked:
# ? Choose the type of migration:
#   ❯ Convert all components, directives and pipes to standalone
#     Remove unnecessary NgModule classes
#     Bootstrap the project using standalone APIs

# Run each option in order!
# First: Convert components
# Second: Remove unnecessary NgModules
# Third: Update bootstrap

# ← This schematic handles:
# ← Adding standalone: true to components
# ← Moving imports from NgModule to component's imports array
# ← Updating app.module.ts to bootstrap with bootstrapApplication()
```

**Migrate to new control flow syntax:**

```bash
# ============================================================
# Schematic: Migrate *ngIf/*ngFor/*ngSwitch to @if/@for/@switch
# ============================================================
ng generate @angular/core:control-flow

# ← Automatically transforms:
# ←   *ngIf="condition" → @if (condition) { }
# ←   *ngIf="condition; else #tpl" → @if (condition) { } @else { }
# ←   *ngFor="let x of items; trackBy: fn" → @for (x of items; track fn(x))
# ←   *ngSwitch="val" → @switch (val) { @case ... }
# ← Also removes CommonModule from imports arrays where no longer needed
```

**Migrate to inject() function:**

```bash
# ============================================================
# Schematic: Migrate constructor injection to inject()
# ============================================================
ng generate @angular/core:inject-migration

# ← Transforms constructor parameters to field initializers using inject()
# ← Example:
# ←   constructor(private service: MyService) {}
# ←   → private service = inject(MyService);
```

### 22.8.3 Common Migration Tasks — Before/After Code Comparison

**Complete migration reference table:**

| Migration Area | Old Pattern (v13-) | New Pattern (v17+) | Automated? |
|----------------|-------------------|-------------------|------------|
| App bootstrap | `platformBrowserDynamic().bootstrapModule(AppModule)` | `bootstrapApplication(AppComponent, appConfig)` | Yes (standalone schematic) |
| Module declaration | `@NgModule({ declarations: [MyComp] })` | `@Component({ standalone: true })` | Yes (standalone schematic) |
| Router setup | `RouterModule.forRoot(routes)` | `provideRouter(routes)` | Yes (standalone schematic) |
| HTTP setup | `HttpClientModule` | `provideHttpClient()` | Yes (standalone schematic) |
| Animations setup | `BrowserAnimationsModule` | `provideAnimations()` | Yes (standalone schematic) |
| Guards | `implements CanActivate` class | `CanActivateFn` function | Partially |
| Resolvers | `implements Resolve<T>` class | `ResolveFn<T>` function | No — manual |
| Interceptors | `implements HttpInterceptor` class | `HttpInterceptorFn` function | No — manual |
| Conditional display | `*ngIf="cond"` | `@if (cond) { }` | Yes (control-flow schematic) |
| List rendering | `*ngFor="let x of items; trackBy: fn"` | `@for (x of items; track x.id) { }` | Yes (control-flow schematic) |
| Switch | `*ngSwitch` | `@switch` | Yes (control-flow schematic) |
| Constructor inject | `constructor(private s: Service)` | `private s = inject(Service)` | Yes (inject schematic) |
| Input | `@Input() name: string` | `name = input<string>()` | No — manual |
| Required input | `@Input() name!: string` | `name = input.required<string>()` | No — manual |
| Output | `@Output() click = new EventEmitter()` | `click = output()` | No — manual |
| Two-way binding | `@Input() val + @Output() valChange` | `val = model<T>()` | No — manual |
| ViewChild | `@ViewChild('ref') el!: ElementRef` | `el = viewChild<ElementRef>('ref')` | No — manual |
| Subscription cleanup | `takeUntil(this.destroy$) + ngOnDestroy` | `takeUntilDestroyed()` | No — manual |
| Change detection | `Zone.js (default)` | `provideExperimentalZonelessChangeDetection()` | No — manual (v18+, experimental) |

**Detailed before/after examples for key migrations:**

```typescript
// ============================================================
// MIGRATION 1: Class-based HTTP interceptor → Functional
// ============================================================

// BEFORE: Class-based interceptor
import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  constructor(private authService: AuthService) {}

  intercept(req: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    const token = this.authService.getToken();
    if (token) {
      req = req.clone({
        setHeaders: { Authorization: `Bearer ${token}` }
      });
    }
    return next.handle(req);  // ← old: next.handle()
  }
}

// Registration (in providers):
// { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true }

// AFTER: Functional interceptor (v15+)
import { inject } from '@angular/core';
import { HttpInterceptorFn } from '@angular/common/http';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService); // ← inject() in functional context
  const token = authService.getToken();

  if (token) {
    req = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
  }
  return next(req); // ← new: next is called directly (not next.handle())
};

// Registration (in main.ts):
// provideHttpClient(withInterceptors([authInterceptor]))
```

```typescript
// ============================================================
// MIGRATION 2: Old *ngFor → New @for
// ============================================================

// BEFORE (in template):
/*
<ul>
  <li *ngFor="let item of items; let i = index; trackBy: trackById"
      [class.active]="item.active">
    {{ i + 1 }}. {{ item.name }}
  </li>
</ul>
<p *ngIf="items.length === 0">No items found.</p>
*/

// In component class:
trackById(index: number, item: Item): number {
  return item.id;
}

// AFTER (in template) — after running control-flow schematic:
/*
<ul>
  @for (item of items; track item.id; let i = $index) {
    <li [class.active]="item.active">
      {{ i + 1 }}. {{ item.name }}
    </li>
  } @empty {
    <p>No items found.</p>
  }
</ul>
*/
// ← trackById function in component class can be removed!
// ← *ngIf for empty state replaced by @empty block!
```

### 22.8.4 Migration Decision Guide

```
Are you on Angular v14 or earlier?
  YES ──→ Upgrade immediately: LTS may have expired
           Run: ng update @angular/core@15 @angular/cli@15 first

Are you on v15 or later but using NgModules?
  YES ──→ Run: ng generate @angular/core:standalone
          This automates most of the migration

Still using *ngIf and *ngFor?
  YES ──→ Run: ng generate @angular/core:control-flow
          Nearly fully automated

Still using constructor injection?
  YES ──→ Optional: ng generate @angular/core:inject-migration
          Matter of preference — constructor injection still works

Using class-based guards/resolvers?
  YES ──→ Manually convert to functional (no schematic available)
          Refer to Section 22.3.2 for examples

Using the old forms API (any type)?
  YES ──→ Enable strictTemplates in tsconfig, convert to typed forms
          Refer to Section 22.2.2 for examples

Not using Signals?
  YES ──→ Start adopting signal inputs/outputs in new components
          Gradually migrate existing components when you touch them

Running Zone.js?
  YES ──→ Remain on Zone.js for now (zoneless is experimental in v18)
          Plan to migrate when v20 makes it stable
```

---

## 22.9 Angular Roadmap — What's Coming Next

### 22.9.1 Full Zoneless Support

The biggest upcoming change is the graduation of zoneless change detection from experimental to stable. When this happens:
- Zone.js becomes entirely optional
- Applications can be smaller (no 100kb+ Zone.js patch library)
- Change detection is fully predictable and deterministic
- Performance improves for complex applications

**Current status (as of v19):** Experimental (`provideExperimentalZonelessChangeDetection()`). Expected stable in v20/v21.

### 22.9.2 Signal-Based Router

The Angular Router will gain signal-based APIs:
- Route params as signals (`route.params()` instead of `route.params.pipe(...)`)
- Query params as signals
- Route data as signals
- No need for `ActivatedRoute` subscriptions

```typescript
// FUTURE: Signal-based router (not yet released)
// Current (v19):
@Component({ template: '' })
class UserComponent {
  private route = inject(ActivatedRoute);
  userId$ = this.route.params.pipe(map(p => p['id'])); // ← Observable

  constructor() {
    this.userId$.subscribe(id => this.loadUser(id));
  }
}

// FUTURE (signal router):
@Component({ template: '' })
class UserComponent {
  private route = inject(ActivatedRoute);
  userId = route.params.get('id'); // ← Signal (hypothetical)

  userResource = resource({
    request: () => this.userId(),
    loader: ({ request }) => fetch(`/api/users/${request}`)
  });
}
```

### 22.9.3 Signal-Based Forms (Stable)

Signal forms (previewed in v19) will become stable, offering:
- Form state as signals (value, valid, dirty, touched all as signals)
- Computed form state derived from signal inputs
- Better TypeScript inference than reactive forms
- No more `.valueChanges` Observables needed

### 22.9.4 Improved SSR and Streaming

- **Streaming SSR**: Send HTML to the browser progressively as it renders on the server (not wait for the full page)
- **Partial hydration improvements**: Even more granular control over what gets hydrated and when
- **Better caching**: Framework-level caching primitives for SSR responses

### 22.9.5 Where to Follow Angular Updates

| Resource | URL | What It Provides |
|----------|-----|-----------------|
| Official Blog | blog.angular.dev | Release announcements, deep dives |
| Official Docs | angular.dev | Always up-to-date documentation |
| GitHub Changelog | github.com/angular/angular/blob/main/CHANGELOG.md | Detailed changelog per version |
| GitHub Roadmap | github.com/angular/angular/discussions/categories/roadmap | Official feature roadmap |
| Angular Discord | discord.gg/angular | Community discussions |
| Angular YouTube | youtube.com/@Angular | Conference talks, tutorials |
| Twitter/X | @angular | Quick announcements |

---

## 22.10 Complete Angular Feature Matrix

This matrix maps every major Angular feature to the version it was introduced, its current status, and the phase in this curriculum where it is covered.

| Feature | Version Introduced | Current Status (v19) | Curriculum Phase |
|---------|-------------------|---------------------|-----------------|
| Components | v2 | Stable | Phase 3 |
| Services & DI | v2 | Stable | Phase 5 |
| Routing | v2 | Stable | Phase 6 |
| Template-driven Forms | v2 | Stable | Phase 7 |
| Reactive Forms (untyped) | v2 | Deprecated | Phase 7 |
| HttpClient | v4 | Stable | Phase 8 |
| RxJS integration | v2 | Stable | Phase 9 |
| NgModules | v2 | Still supported, not recommended for new code | Phase 3 |
| Ivy Renderer | v9 | Stable | Phase 3 |
| Strict Mode | v10 | Default | Phase 2 |
| `ng update` schematics | v6 | Stable | Phase 22 |
| Standalone Components | v14 | Stable | Phase 22 |
| Strictly Typed Forms | v14 | Stable | Phase 22 |
| `inject()` function | v14 | Stable | Phase 22 |
| Functional Guards | v15 | Stable | Phase 22 |
| Functional Resolvers | v15 | Stable | Phase 22 |
| `provideRouter()` | v15 | Stable | Phase 22 |
| `provideHttpClient()` | v15 | Stable | Phase 22 |
| `NgOptimizedImage` | v15 | Stable | Phase 22 |
| `loadComponent` routing | v15 | Stable | Phase 22 |
| Signals (`signal()`, `computed()`, `effect()`) | v16 (preview) | Stable (v18) | Phase 12, 22 |
| `@Input({ required: true })` | v16 | Stable | Phase 22 |
| Non-destructive Hydration | v16 | Stable | Phase 22 |
| `DestroyRef` | v16 | Stable | Phase 22 |
| `takeUntilDestroyed()` | v16 | Stable | Phase 22 |
| Self-closing component tags | v16 | Stable | Phase 22 |
| `@if` / `@else` control flow | v17 | Stable | Phase 22 |
| `@for` with `track` | v17 | Stable | Phase 22 |
| `@switch` / `@case` | v17 | Stable | Phase 22 |
| `@defer` (deferrable views) | v17 | Stable | Phase 22 |
| esbuild + Vite build | v17 | Stable | Phase 22 |
| Standalone by default (`ng new`) | v17 | Stable | Phase 22 |
| Signal `input()` | v17 (preview) | Stable (v18) | Phase 22 |
| Signal `output()` | v17 (preview) | Stable (v18) | Phase 22 |
| Signal `model()` | v17 (preview) | Stable (v18) | Phase 22 |
| Signal `viewChild()` / `contentChild()` | v17 (preview) | Stable (v18) | Phase 22 |
| Zoneless change detection | v18 | Experimental | Phase 22 |
| Material Design 3 | v18 | Stable | Phase 22 |
| Route redirectTo as function | v18 | Stable | Phase 22 |
| `provideAnimationsAsync()` | v18 | Stable | Phase 22 |
| Incremental Hydration | v19 | Developer Preview | Phase 22 |
| `linkedSignal()` | v19 | Developer Preview | Phase 22 |
| `resource()` / `rxResource()` | v19 | Developer Preview | Phase 22 |
| Event Replay during hydration | v19 | Stable | Phase 22 |
| Signal-based forms | v19 | Developer Preview | Phase 22 |
| Full Zoneless support | v20+ | Planned | — |
| Signal-based Router | v20+ | Planned | — |

---

## 22.11 Congratulations — Your Angular Journey

### You Did It

You have completed all 22 phases of this Angular curriculum. When you started Phase 1, you were learning what `let` and `const` mean. Now you understand the fine-grained reactivity model of signals, the performance implications of zoneless change detection, the SSR hydration pipeline, and how to migrate production applications across multiple major Angular versions.

That is not a small thing. Most developers never reach this depth.

### A Summary of Your Journey

```
Phase 1:   Prerequisites — TypeScript, JavaScript ES6+, Node.js, npm
Phase 2:   Angular Setup — CLI, project structure, tsconfig
Phase 3:   Core Concepts — Components, templates, data binding, directives
Phase 4:   Component Communication — @Input/@Output, ViewChild, ContentChild
Phase 5:   Services & DI — Providers, hierarchical injection, DI tokens
Phase 6:   Routing & Navigation — Routes, guards, resolvers, lazy loading
Phase 7:   Forms — Template-driven forms, reactive forms, validation
Phase 8:   HTTP & API Communication — HttpClient, error handling, interceptors
Phase 9:   RxJS & Observables — Operators, subjects, patterns
Phase 10:  State Management — Services, NgRx, component store
Phase 11:  Performance — OnPush, trackBy, virtual scrolling, lazy loading
Phase 12:  Signals — signal(), computed(), effect(), fine-grained reactivity
Phase 13:  Testing — Unit testing, component testing, integration testing
Phase 14:  Angular Material — Components, theming, accessibility
Phase 15:  Advanced Templates — Custom directives, pipes, structural patterns
Phase 16:  Advanced DI — Multi-providers, tokens, injection contexts
Phase 17:  Server-Side Rendering (SSR) — Universal, hydration, SEO
Phase 18:  Progressive Web Apps (PWA) — Service workers, offline, push notifications
Phase 19:  Internationalization (i18n) — Translations, locale, date/number formatting
Phase 20:  Microfrontends & Module Federation — Distributed Angular architecture
Phase 21:  CI/CD & Deployment — Building, testing pipelines, deployment strategies
Phase 22:  Angular New Features & Migration — v14 through v19, staying current
```

### From Zero to Expert — What You Can Now Do

You can now:

**Build from scratch:**
- Create a standalone Angular application with routing, HTTP, and forms
- Implement signal-based state management
- Add SSR with hydration for performance and SEO
- Configure authentication with functional guards and interceptors

**Write production-quality code:**
- Use typed reactive forms to eliminate form-related bugs
- Implement deferrable views for optimal performance
- Apply the OnPush change detection strategy and signals for fine-grained updates
- Write comprehensive unit and integration tests

**Maintain and upgrade existing applications:**
- Understand what each Angular version introduced
- Run `ng update` confidently with a step-by-step process
- Apply migration schematics to modernize codebases
- Recognize deprecated patterns and know their modern replacements

**Make architectural decisions:**
- Choose between NgModules and standalone (standalone for new code)
- Choose between Zone.js and zoneless (Zone.js until v20 for stability)
- Choose between RxJS and signals for reactive state
- Choose between CSR, SSR, and SSG for different use cases

### What to Do Next

**Week 1-4: Build a real project**

The fastest way to cement your knowledge is to build something real. Ideas:
- A task management app (CRUD, routing, forms, HTTP)
- A dashboard app (charts, data tables, filtering, SSR)
- A blog platform (SSR, SEO, content management)
- An e-commerce product catalog (image optimization, filters, cart)

Pick something that interests you. The technology choices matter less than building something end-to-end.

**Month 2: Contribute to open source**

Find an Angular library on GitHub with "good first issue" labels. Contributing to open source:
- Forces you to read others' code (the most underrated skill)
- Gets you feedback from experienced maintainers
- Gives you portfolio pieces
- Connects you to the Angular community

Good starting points:
- Angular Material (github.com/angular/components)
- NgRx (github.com/ngrx/platform)
- Analog.js (github.com/analogjs/analog)
- Any Angular UI library you use regularly

**Month 3: Stay current**

Angular evolves every 6 months. To stay current:
1. Subscribe to blog.angular.dev for official announcements
2. Watch Angular's YouTube channel for conference talks
3. Join Angular Discord for community discussions
4. Run `ng update` on your personal projects with each release
5. Read at least one release blog post per major version

**Long-term: Specialize and deepen**

Angular expertise compounds. As you build more applications, consider deepening in:
- **Performance:** Web Vitals, bundle analysis, profiling
- **SSR/SSG:** Analog.js, complex hydration scenarios
- **Testing:** End-to-end testing with Playwright/Cypress
- **Enterprise patterns:** Micro-frontends, design systems
- **Architecture:** Large-scale Angular applications

### A Note on Learning

There is a moment in every developer's journey where Angular (or any framework) stops feeling like a foreign language and starts feeling like a native one. You will stop translating "what I want to do" into "how do I do this in Angular" and start thinking directly in Angular concepts.

You are at that threshold now.

The remaining step is not reading more documentation or completing more tutorials. It is building, making mistakes, debugging those mistakes, and building again. That loop — build, break, fix, repeat — is where mastery lives.

Go build something.

### Resources for Your Continued Journey

| Resource | URL | Best For |
|----------|-----|----------|
| Angular Official Docs | angular.dev | Reference, tutorials |
| Angular Blog | blog.angular.dev | Version updates, deep dives |
| Angular Update Guide | update.angular.io | Version-specific migration steps |
| Angular YouTube | youtube.com/@Angular | Conference talks |
| Angular Discord | discord.gg/angular | Community Q&A |
| Angular GitHub | github.com/angular/angular | Issues, roadmap |
| TypeScript Docs | typescriptlang.org/docs | TypeScript reference |
| RxJS Docs | rxjs.dev | RxJS operators and patterns |
| Web.dev | web.dev | Web performance fundamentals |
| MDN Web Docs | developer.mozilla.org | HTML, CSS, JS reference |

---

## Congratulations

You have completed the Angular Mastery Curriculum.

```
 Phase  1: Prerequisites & Foundation              ✓ Complete
 Phase  2: Angular Setup & Project Structure       ✓ Complete
 Phase  3: Core Concepts                           ✓ Complete
 Phase  4: Component Communication                 ✓ Complete
 Phase  5: Services & Dependency Injection         ✓ Complete
 Phase  6: Routing & Navigation                    ✓ Complete
 Phase  7: Forms                                   ✓ Complete
 Phase  8: HTTP & API Communication                ✓ Complete
 Phase  9: RxJS & Observables                      ✓ Complete
 Phase 10: State Management                        ✓ Complete
 Phase 11: Performance                             ✓ Complete
 Phase 12: Signals                                 ✓ Complete
 Phase 13: Testing                                 ✓ Complete
 Phase 14: Angular Material                        ✓ Complete
 Phase 15: Advanced Templates                      ✓ Complete
 Phase 16: Advanced DI                             ✓ Complete
 Phase 17: Server-Side Rendering                   ✓ Complete
 Phase 18: Progressive Web Apps                    ✓ Complete
 Phase 19: Internationalization                    ✓ Complete
 Phase 20: Microfrontends                          ✓ Complete
 Phase 21: CI/CD & Deployment                      ✓ Complete
 Phase 22: New Features & Migration                ✓ Complete
 ─────────────────────────────────────────────────────────────
 ALL 22 PHASES COMPLETE — Angular Mastery Achieved
```

Every expert was once a beginner who decided not to give up. You chose to go deep. You chose to understand the why, not just the how. That decision sets you apart.

The Angular community is stronger because you are in it.

Now go build something great.

---

*This curriculum was designed to take you from zero to expert in Angular — covering the framework's foundations, its advanced patterns, and its continuous evolution. The knowledge in these 22 phases represents years of framework development and community learning, distilled into a structured learning path.*

*Angular v14 through v19 content reflects Angular's journey from an NgModule-centric framework to a modern, signals-driven, standalone-first, performance-optimized web platform. The framework will continue to evolve — and now you have the foundation to evolve with it.*
