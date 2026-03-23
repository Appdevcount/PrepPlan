# React vs Angular: Complete Architect's Guide
## For React Developers Transitioning to Angular

> **Your Background**: React.js, Redux, Large-scale apps, Cross-cutting concerns, JWT Auth, Performance optimization

---

## Table of Contents
1. [Quick Start & Prerequisites](#quick-start--prerequisites)
2. [Project Structure](#1-project-structure)
3. [Components & Lifecycle](#2-components--lifecycle)
4. [Angular 17+ New Control Flow Syntax](#25-angular-17-new-control-flow-syntax-latest-features)
5. [State Management: Redux vs NgRx](#3-state-management-redux-vs-ngrx)
6. [Cross-Cutting Concerns](#4-cross-cutting-concerns)
6.5. [React Context API & Hooks — Deep Dive](#45-react-context-api--hooks--deep-dive)
7. [JWT Authentication](#5-jwt-authentication)
8. [Performance Optimization](#6-performance-optimization)
9. [Routing](#7-routing)
10. [Forms](#8-forms)
11. [HTTP & API Calls](#9-http--api-calls)
12. [Dependency Injection (Angular Unique)](#10-dependency-injection-angular-unique)
13. [RxJS Deep Dive (Angular Unique)](#11-rxjs-deep-dive-angular-unique)
14. [React-Only Features](#12-react-only-features)
15. [Angular-Only Features](#13-angular-only-features)
16. [Popular Libraries Comparison](#14-popular-libraries-comparison)
17. [Architecture Patterns](#15-architecture-patterns)

---

## Quick Start & Prerequisites

### Before You Begin

This guide assumes you have:
- ✅ **React Experience**: Familiar with hooks, functional components, state management
- ✅ **TypeScript Knowledge**: Understanding of types, interfaces, decorators
- ✅ **JavaScript ES6+**: Arrow functions, destructuring, async/await
- ✅ **Web Development Basics**: HTML, CSS, HTTP, REST APIs

### Key Mindset Shifts When Moving from React to Angular

```
❌ React Mindset          →  ✅ Angular Mindset
─────────────────────────────────────────────
Flexibility              →  Structure & Convention
Minimalist core          →  Complete framework
Large ecosystem          →  Built-in solutions
Imperative             →  Declarative with DI
Hooks for everything     →  Services + Decorators
Props drilling          →  Dependency Injection
Any folder structure     →  NgModules + feature folders
```

---

## 1. Project Structure

### React (Typical Large-Scale)
```
src/
├── components/
│   ├── common/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.styles.ts
│   │   │   └── Button.test.tsx
│   │   └── Modal/
│   ├── features/
│   │   └── auth/
│   │       ├── LoginForm.tsx
│   │       └── RegisterForm.tsx
├── hooks/
│   ├── useAuth.ts
│   └── useApi.ts
├── store/
│   ├── slices/
│   │   ├── authSlice.ts
│   │   └── userSlice.ts
│   └── store.ts
├── services/
│   └── api.ts
├── utils/
├── types/
└── App.tsx
```

### Angular (Modular Architecture)
```
src/app/
├── core/                      # Singleton services, guards, interceptors
│   ├── guards/
│   │   └── auth.guard.ts
│   ├── interceptors/
│   │   └── jwt.interceptor.ts
│   ├── services/
│   │   └── auth.service.ts
│   └── core.module.ts
├── shared/                    # Reusable components, pipes, directives
│   ├── components/
│   │   ├── button/
│   │   │   ├── button.component.ts
│   │   │   ├── button.component.html
│   │   │   ├── button.component.scss
│   │   │   └── button.component.spec.ts
│   │   └── modal/
│   ├── directives/
│   ├── pipes/
│   └── shared.module.ts
├── features/                  # Feature modules (lazy-loaded)
│   ├── auth/
│   │   ├── components/
│   │   ├── services/
│   │   ├── store/            # NgRx feature state
│   │   ├── auth.module.ts
│   │   └── auth-routing.module.ts
│   └── dashboard/
├── store/                     # Root NgRx store
│   ├── app.state.ts
│   └── app.effects.ts
└── app.module.ts
```

**Key Difference**: Angular enforces modular architecture with `NgModules`. React is more flexible but requires discipline.

### How to Structure Your First Angular Project (Step-by-Step)

**Step 1: Create the project**
```bash
# Install Angular CLI globally
npm install -g @angular/cli

# Create new project with routing and styling preset
ng new my-awesome-app --routing --style=scss --skip-git=true

# Navigate to project
cd my-awesome-app
```

**Step 2: Understand the main files**
- `src/main.ts` - Entry point, bootstraps the root module
- `src/app/app.module.ts` - Root module, declares all components/pipes/directives
- `src/app/app.component.ts` - Root component (like App.tsx in React)
- `angular.json` - Build configuration (like webpack config)
- `tsconfig.json` - TypeScript configuration

**Step 3: Generate your first feature**
```bash
# Generate a feature module with routing
ng generate module features/dashboard --routing

# Generate components inside that module
ng generate component features/dashboard/components/dashboard
ng generate component features/dashboard/components/stats

# Generate a service
ng generate service features/dashboard/services/dashboard
```

**Step 4: Verify the folder structure created**
```
src/app/
├── features/
│   └── dashboard/
│       ├── components/
│       │   ├── dashboard/
│       │   │   ├── dashboard.component.ts
│       │   │   ├── dashboard.component.html
│       │   │   ├── dashboard.component.scss
│       │   │   └── dashboard.component.spec.ts
│       │   └── stats/
│       ├── services/
│       │   └── dashboard.service.ts
│       ├── dashboard.module.ts
│       └── dashboard-routing.module.ts
```

### React vs Angular Folder Organization Comparison

| Aspect | React | Angular |
|--------|-------|---------|
| **Enforced?** | No - up to you | Yes - NgModules required |
| **Grouping** | By type (components/hooks/store) OR feature | By feature/domain |
| **Flexibility** | Complete freedom | Follow conventions |
| **Scalability** | Requires discipline | Built-in structure |
| **Learning Curve** | Easier initially | Steeper, but clear pattern |

**React Pro Tip**: While React doesn't enforce structure, use feature-based folders for large apps - it matches Angular's approach and scales better.

### How to Structure Your First Angular Project

**Step 1: Create the project**
```bash
# Install Angular CLI globally
npm install -g @angular/cli

# Create new project with routing and styling preset
ng new my-awesome-app --routing --style=scss --skip-git=true

# Navigate to project
cd my-awesome-app
```

**Step 2: Understand the main files**
- `src/main.ts` - Entry point, bootstraps the root module
- `src/app/app.module.ts` - Root module, declares all components/pipes/directives
- `src/app/app.component.ts` - Root component (like App.tsx in React)
- `angular.json` - Build configuration (like webpack config)
- `tsconfig.json` - TypeScript configuration

**Step 3: Generate your first feature**
```bash
# Generate a feature module with routing
ng generate module features/dashboard --routing

# Generate components inside that module
ng generate component features/dashboard/components/dashboard
g generate component features/dashboard/components/stats
```

**Step 4: Verify the folder structure created**
```
src/app/
├── features/
│   └── dashboard/
│       ├── components/
│       │   ├── dashboard/
│       │   │   ├── dashboard.component.ts
│       │   │   ├── dashboard.component.html
│       │   │   ├── dashboard.component.scss
│       │   │   └── dashboard.component.spec.ts
│       │   └── stats/
│       └── dashboard.module.ts
│       └── dashboard-routing.module.ts
```

### React vs Angular Folder Organization Comparison

| Aspect | React | Angular |
|--------|-------|----------|
| **Enforced?** | No - up to you | Yes - NgModules required |
| **Grouping** | By type (components/hooks/store) OR feature | By feature/domain |
| **Flexibility** | Complete freedom | Follow conventions |
| **Scalability** | Requires discipline | Built-in structure |
| **Learning Curve** | Easier initially | Steeper, but clear pattern |

**React Pro Tip**: While React doesn't enforce structure, use feature-based folders for large apps - it matches Angular's approach and scales better.

---

## 2. Components & Lifecycle

### Understanding the Lifecycle

**React Approach**: Uses effects that run based on dependency arrays (functional)
**Angular Approach**: Uses lifecycle hooks that fire at specific moments (declarative)

Think of it like ordering a coffee:
- **React**: "When these ingredients (deps) change, do this (effect)"
- **Angular**: "When you're initialized, do this. When inputs change, do that. When cleaning up, do that."

### How to Create a React Component (Step-by-Step)

**1. Import required hooks and types**
**2. Define your props interface**
**3. Use hooks for state, effects, and memoization**
**4. Return JSX**

### React Component
```tsx
// React: Function Component with Hooks
import React, { useState, useEffect, useMemo, useCallback, useRef } from 'react';

// STEP 1: Define the component props with TypeScript interface
// This ensures type safety and auto-completion in parent components

interface UserCardProps {
  userId: string;              // ← Required input prop
  onSelect: (id: string) => void;  // ← Callback to parent (like @Output)
}

export const UserCard: React.FC<UserCardProps> = ({ userId, onSelect }) => {
  // STEP 2: Declare state using hooks
  // useState returns [value, setter] and triggers re-render when updated
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // STEP 3: Create refs for direct DOM access (like @ViewChild in Angular)
  // Refs don't trigger re-renders when updated
  const cardRef = useRef<HTMLDivElement>(null);

  // STEP 4: Memoize computed values
  // useMemo caches the result and only recalculates when deps change
  // Without this, fullName is recalculated on every render
  const fullName = useMemo(() =>
    user ? `${user.firstName} ${user.lastName}` : '',
    [user]  // ← Dependency array: recalculate only if 'user' changes
  );

  // STEP 5: Memoize callback functions to prevent child re-renders
  // useCallback returns same function reference if deps haven't changed
  // Pass this to child components to avoid unnecessary renders
  const handleClick = useCallback(() => {
    onSelect(userId);
  }, [userId, onSelect]);  // ← Recalculate if inputs change

  // STEP 6: Handle side effects like data fetching
  // This effect runs:
  // - On component mount (empty dependency array means once)
  // - When userId changes (dependency array includes userId)
  // - Cleanup function runs before next effect or on unmount
  useEffect(() => {
    let cancelled = false;  // ← Race condition prevention

    fetchUser(userId).then(data => {
      // Only update state if component is still mounted
      if (!cancelled) setUser(data);
    });

    // Cleanup/Unsubscribe: runs when component unmounts or userId changes
    // Equivalent to ngOnDestroy or subscription takeUntil in Angular
    return () => { cancelled = true; };
  }, [userId]);  // ← Run effect when userId changes

  // Lifecycle: On every render
  useEffect(() => {
    console.log('Component rendered');
  });

  if (loading) return <div>Loading...</div>;

  return (
    <div ref={cardRef} onClick={handleClick} className="user-card">
      <h2>{fullName}</h2>
      <p>{user?.email}</p>
      {/* Conditional rendering */}
      {user?.isAdmin && <span className="badge">Admin</span>}
    </div>
  );
};
```

### How to Create an Angular Component (Step-by-Step)

**1. Create the component file and template**
**2. Use the @Component decorator to define metadata**
**3. Declare @Input for props and @Output for callbacks**
**4. Implement lifecycle interfaces (OnInit, OnDestroy, etc)**
**5. Subscribe to observables and manage cleanup**

### Angular Component
```typescript
// Angular: Component with Decorators
import {
  Component, Input, Output, EventEmitter,  // ← Decorators for properties
  OnInit, OnDestroy, OnChanges, SimpleChanges,  // ← Lifecycle interface
  ViewChild, ElementRef, ChangeDetectionStrategy  // ← Extra Angular features
} from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({
  selector: 'app-user-card',  // ← HTML tag name for this component
  templateUrl: './user-card.component.html',  // ← External template file
  styleUrls: ['./user-card.component.scss'],  // ← Component styles
  changeDetection: ChangeDetectionStrategy.OnPush  // ← Like React.memo: only update when inputs change or event fires
})
export class UserCardComponent implements OnInit, OnDestroy, OnChanges {
  // STEP 1: Declare inputs (like function props in React)
  // When parent component changes userId, Angular automatically updates this
  @Input() userId!: string;  // ← ! means required, no default value

  // STEP 2: Declare outputs (like callbacks passed as props)
  // Emit values to parent: this.select.emit(value)
  @Output() select = new EventEmitter<string>();  // ← Parent listens with (select)="onSelect($event)"

  // STEP 3: Reference template elements (like useRef in React)
  // Access #cardElement from template using this.cardRef.nativeElement
  @ViewChild('cardElement') cardRef!: ElementRef<HTMLDivElement>;  // ← ! means optional but don't provide default

  // STEP 4: Declare component state (like useState in React)
  user: User | null = null;  // ← Component property, not a hook
  loading = true;

  // STEP 5: Create subject for managing subscriptions and cleanup
  // This replaces multiple unsubscribe calls - very clean pattern
  private destroy$ = new Subject<void>();  // ← $ suffix indicates Observable by convention

  // STEP 6: Create computed properties (cached getters)
  // Unlike useMemo, this recalculates every access
  // For expensive calculations, use async pipe and pure pipes instead
  get fullName(): string {
    return this.user ? `${this.user.firstName} ${this.user.lastName}` : '';
  }

  // STEP 7: Inject dependencies in constructor
  // Angular's DI automatically resolves UserService from providers
  // This is dependency injection - React doesn't have built-in DI
  constructor(private userService: UserService) {}

  // STEP 8: Respond to component initialization
  // Angular lifecycle: constructor → ngOnInit → ngAfterViewInit
  // ngOnInit is called AFTER inputs are set, perfect for API calls
  ngOnInit(): void {
    this.loadUser();
  }

  // STEP 9: Respond to input changes
  // Called when @Input properties change
  // This is like useEffect with dependency array in React
  ngOnChanges(changes: SimpleChanges): void {
    // Check if userId changed (and it's not the first change)
    if (changes['userId'] && !changes['userId'].firstChange) {
      this.loadUser();  // Fetch new user when userId prop changes
    }
  }

  // STEP 10: Cleanup when component destroys
  // Called when Angular removes the component from DOM
  // Equivalent to cleanup function in useEffect or ngOnDestroy
  ngOnDestroy(): void {
    this.destroy$.next();  // ← Signal all subscriptions to stop
    this.destroy$.complete();  // ← Mark subject as complete
  }

  // STEP 11: Fetch data from service
  private loadUser(): void {
    this.loading = true;
    this.userService.getUser(this.userId)
      .pipe(
        takeUntil(this.destroy$)  // ← Automatically unsubscribe on destroy
      )
      // SHORTHAND subscribe(fn) — passes a single function as the `next` callback only.
      // WHY shorthand here: this is a demo component. In production always use the object form
      //   { next, error } so HTTP failures don't silently fall into the global error handler.
      // `next` fires once when getUser() emits the User object, then the HTTP Observable completes.
      .subscribe(user => {
        // next callback — called when the Observable emits the user value
        this.user = user;
        this.loading = false;
        // complete() fires automatically after this (HTTP Observable always completes) — not handled here
        // error callback omitted — if the HTTP request fails, the error is unhandled (use object form instead)
      });
  }

  handleClick(): void {
    this.select.emit(this.userId);
  }
}
```

```html
<!-- user-card.component.html -->
<div #cardElement (click)="handleClick()" class="user-card" *ngIf="!loading; else loadingTpl">
  <h2>{{ fullName }}</h2>
  <p>{{ user?.email }}</p>
  <!-- Conditional rendering -->
  <span class="badge" *ngIf="user?.isAdmin">Admin</span>
</div>

<ng-template #loadingTpl>
  <div>Loading...</div>
</ng-template>
```

### Lifecycle Comparison Table

| React Hook | Angular Lifecycle | Purpose |
|------------|------------------|---------|
| `useEffect(() => {}, [])` | `ngOnInit` | Component mount |
| `useEffect return` | `ngOnDestroy` | Cleanup |
| `useEffect` with deps | `ngOnChanges` | React to prop changes |
| `useMemo` | getter or `pipe` | Computed values |
| `useCallback` | Method (auto-bound) | Memoized functions |
| `useRef` | `@ViewChild` | DOM references |
| `useState` | Class property | Local state |

### How to Debug Component Issues (Practical Troubleshooting)

**React Common Mistakes & Solutions:**

```tsx
// ❌ PROBLEM: Infinite loop - effect runs every render
useEffect(() => { 
  fetchUser(); 
}, [])  // Missing dependency

// ✅ SOLUTION: Add dependency array
useEffect(() => { 
  fetchUser(); 
}, [userId])  // Run when userId changes

// ❌ PROBLEM: Memory leak from uncleared subscriptions
useEffect(() => { 
  subscription.subscribe(...)
  // No cleanup function!
})

// ✅ SOLUTION: Add cleanup function
useEffect(() => {
  const sub = subscription.subscribe(...)
  return () => sub.unsubscribe()  // Cleanup on unmount
}, [])

// ❌ PROBLEM: Stale closure in useCallback
const handleClick = useCallback(() => {
  console.log(count);  // Always logs old value
}, [])  // Missing dependency

// ✅ SOLUTION: Include dependency
const handleClick = useCallback(() => {
  console.log(count);
}, [count])  // Include all used variables
```

**Angular Common Mistakes & Solutions:**

```typescript
// ❌ PROBLEM: Memory leak - subscription not cleaned up
ngOnInit() {
  this.userService.getUser().subscribe(user => {
    this.user = user;
  })
  // No unsubscribe!
}

// ✅ SOLUTION: Use takeUntil pattern
// Subject<void> — a signal-only stream (void = we only care about WHEN it fires, not what value)
// WHY: Subject is used here purely as a "kill switch". We never need to read its value —
//      we just need it to emit once in ngOnDestroy to signal "time to stop everything"
private destroy$ = new Subject<void>();

ngOnInit() {
  this.userService.getUser()
    .pipe(
      // takeUntil(destroy$) — automatically unsubscribe when destroy$ emits
      // WHY: This is the primary memory leak prevention pattern in Angular.
      //      When ngOnDestroy fires, destroy$.next() → destroy$.complete() causes
      //      takeUntil to complete the subscription — no manual unsubscribe needed.
      //      Without this, the subscription lives on forever after the component is destroyed.
      takeUntil(this.destroy$)
    )
    .subscribe(user => this.user = user);
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}

// ❌ PROBLEM: N+1 performance issue with *ngFor
<li *ngFor="let item of items">
  {{ item.name }}  // Angular re-creates DOM for every item
</li>

// ✅ SOLUTION: Use trackBy
<li *ngFor="let item of items; trackBy: trackById">
  {{ item.name }}
</li>

trackById = (index: number, item: Item) => item.id;

// ❌ PROBLEM: Slow change detection
@Component({
  template: `{{ user.name }}`
  // Default change detection checks entire component tree
})

// ✅ SOLUTION: Use OnPush strategy
@Component({
  template: `{{ user.name }}`,
  changeDetection: ChangeDetectionStrategy.OnPush  // Only updateif @Input changes
})
```

### Debugging Tools & Commands

**React Debugging:**
```bash
# Install React Developer Tools browser extension
# Or use built-in Chrome DevTools

# Add logging
console.log('User:', user);
console.table(userList);  // Pretty print arrays/objects

# React.Profiler to measure performance
import { Profiler } from 'react';
<Profiler id="UserCard" onRender={onRenderCallback}>
  <UserCard />
</Profiler>
```

**Angular Debugging:**
```bash
# Enable production mode logging
ng serve --configuration=development

# Augury browser extension (Angular-specific DevTools)
# Install: "Angular DevTools" extension

# Add logging
console.log('User:', user);
console.table(this.userList);

# Breakpoints in Chrome DevTools
# Sources tab → find component.ts → set breakpoints

# ng test for unit testing with debugging
ng test --browsers=Chrome --watch=true
```

---

## 2.5 Angular 17+ New Control Flow Syntax (Latest Features)

> **IMPORTANT**: Angular 17+ introduced a brand new control flow syntax that replaces structural directives. This is a game-changer for developers and brings Angular closer to React's familiar patterns.

### Why New Control Flow Syntax?

Angular 17+ introduced a new syntax for control flow that:
- ✅ Is **more readable** and closer to standard JavaScript
- ✅ **Improves performance** with better change detection
- ✅ **Reduces bugs** by eliminating microsyntax learning curve
- ✅ **Better tree-shaking** - unused branches are removed
- ✅ **Familiar to React devs** - feels similar to JSX conditional rendering

### New Control Flow Overview

```
┌────────────────────────────────────────────────────────────┐
│         Angular 17+ Control Flow Features                   │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  @if condition { }              ←  Replaces *ngIf          │
│  @for item of array { }         ←  Replaces *ngFor         │
│  @switch value {                ←  Replaces *ngSwitch      │
│    @case caseValue { }          ←  Replaces *ngSwitchCase  │
│    @default { }                 ←  Replaces [ngSwitchDefault]
│  }                                                          │
│  @try { }                       ←  BRAND NEW - Error handling
│  @catch error { }               ←  BRAND NEW - Error display
│  @defer (when condition) { }    ←  BRAND NEW - Lazy loading
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### 1. @if Control Flow (Replaces *ngIf)

**Old Syntax (*ngIf):**
```html
<!-- React Dev: This is confusing! What's ngIf? -->
<div *ngIf="!loading; else loadingTpl" class="user-card">
  <h2>{{ user?.name }}</h2>
</div>

<ng-template #loadingTpl>
  <div>Loading...</div>
</ng-template>
```

**Angular 17+ @if Syntax:**
```html
<!-- React Dev: This looks familiar! Like a JavaScript if-else! -->
@if (!loading) {
  <div class="user-card">
    <h2>{{ user?.name }}</h2>
  </div>
} @else {
  <div>Loading...</div>
}
```

**Key Differences:**
- No need for `ng-template` placeholder
- No cryptic `*ngIf="condition; else template"`
- Works just like JavaScript `if-else`
- Better IDE support and syntax highlighting

**Detailed Examples:**

```html
<!-- PATTERN 1: Simple if condition -->
@if (user.isAdmin) {
  <div class="admin-badge">Admin User</div>
}

<!-- PATTERN 2: if-else condition -->
@if (user.isLoggedIn) {
  <div>Welcome, {{ user.name }}!</div>
} @else {
  <button (click)="login()">Login</button>
}

<!-- PATTERN 3: if-else if-else chain -->
@if (status === 'loading') {
  <div class="spinner">Loading...</div>
} @else if (status === 'error') {
  <div class="error">{{ errorMessage }}</div>
} @else if (status === 'success') {
  <div class="success">✓ Loaded successfully</div>
} @else {
  <div>Unknown state</div>
}

<!-- PATTERN 4: Conditional with async data -->
@if ((user$ | async) as user) {
  <div>
    <h2>{{ user.name }}</h2>
    <p>{{ user.email }}</p>
  </div>
} @else {
  <p>User not found</p>
}

<!-- PATTERN 5: Negation syntax -->
@if (!user) {
  <button>Register</button>
}

<!-- PATTERN 6: Complex conditions -->
@if (user.isLoggedIn && user.isPremium && !user.isSuspended) {
  <div class="premium-content">
    Access to exclusive features
  </div>
}
```

### 2. @for Loop (Replaces *ngFor)

**Old Syntax (*ngFor):**
```html
<!-- Very cryptic for React developers -->
<li *ngFor="let item of items; trackBy: trackById; let i = index" [key]="item.id">
  {{ i }}: {{ item.name }}
</li>
```

**Angular 17+ @for Syntax:**
```html
<!-- Much clearer! Closer to JavaScript for-of loop -->
@for (item of items; track item.id) {
  <li>{{ item.name }}</li>
}
```

**Key Improvements:**
- No cryptic `trackBy` property required
- Use `track` keyword for performance optimization
- Direct loop variable declaration: `item of items`
- Index access using special variable: `$index`
- Better performance with built-in tracking

**Detailed Examples:**

```html
<!-- PATTERN 1: Simple iteration -->
@for (user of users) {
  <div class="user-card">
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
  </div>
}

<!-- PATTERN 2: With index access -->
@for (user of users; let i = $index) {
  <div class="user-item">
    #{{ i + 1 }}: {{ user.name }}
  </div>
}

<!-- PATTERN 3: With even/odd detection -->
@for (user of users; let isEven = $even; let isOdd = $odd) {
  <div [class.row-even]="isEven" [class.row-odd]="isOdd">
    {{ user.name }}
  </div>
}

<!-- PATTERN 4: With first/last detection -->
@for (user of users; let isFirst = $first; let isLast = $last) {
  <div>
    {{ user.name }}
    @if (isFirst) {
      <span class="badge">First User</span>
    }
    @if (isLast) {
      <span class="badge">Last User</span>
    }
  </div>
}

<!-- PATTERN 5: Performance optimization with track -->
<!-- ✅ GOOD: Track by unique identifier -->
@for (product of products; track product.id) {
  <div class="product">{{ product.name }} - ${{ product.price }}</div>
}

<!-- ❌ BAD: Track by index (causes bugs on reorder/filter) -->
@for (product of products; track $index) {
  <div class="product">{{ product.name }}</div>
}

<!-- PATTERN 6: Nested loops -->
@for (category of categories) {
  <div class="category">
    <h3>{{ category.name }}</h3>
    @for (item of category.items) {
      <div class="item">{{ item.name }}</div>
    }
  </div>
}

<!-- PATTERN 7: Empty state handling -->
@for (item of items; track item.id) {
  <div class="item">{{ item.name }}</div>
} @empty {
  <div class="empty-state">No items found</div>
}
```

### 3. @switch/@case (Replaces *ngSwitch)

**Old Syntax (*ngSwitch):**
```html
<!-- Hard to read, requires ng-template -->
<div [ngSwitch]="userRole">
  <div *ngSwitchCase="'admin'">Admin Dashboard</div>
  <div *ngSwitchCase="'user'">User Profile</div>
  <div *ngSwitchCase="'guest'">Guest View</div>
  <div *ngSwitchDefault>Unknown Role</div>
</div>
```

**Angular 17+ @switch/@case Syntax:**
```html
<!-- Looks like JavaScript switch-case! -->
@switch (userRole) {
  @case ('admin') {
    <div>Admin Dashboard</div>
  }
  @case ('user') {
    <div>User Profile</div>
  }
  @case ('guest') {
    <div>Guest View</div>
  }
  @default {
    <div>Unknown Role</div>
  }
}
```

**Detailed Examples:**

```html
<!-- PATTERN 1: Simple switch-case -->
@switch (status) {
  @case ('pending') {
    <span class="badge-yellow">Pending</span>
  }
  @case ('approved') {
    <span class="badge-green">✓ Approved</span>
  }
  @case ('rejected') {
    <span class="badge-red">✗ Rejected</span>
  }
  @default {
    <span class="badge-gray">Unknown</span>
  }
}

<!-- PATTERN 2: Switch with complex cases -->
@switch (paymentMethod) {
  @case ('credit-card') {
    <div>
      <h4>Credit Card</h4>
      <p>Card ending in {{ lastFourDigits }}</p>
      <button>Update</button>
    </div>
  }
  @case ('paypal') {
    <div>
      <h4>PayPal</h4>
      <p>{{ paypalEmail }}</p>
      <button>Reconnect</button>
    </div>
  }
  @case ('bank-transfer') {
    <div>
      <h4>Bank Transfer</h4>
      <p>Account: {{ bankAccount }}</p>
      <button>Verify</button>
    </div>
  }
  @default {
    <p>No payment method selected</p>
  }
}

<!-- PATTERN 3: Switch with multiple matching cases (fall-through) -->
@switch (userLevel) {
  @case ('advanced') {
    <button>Advanced Features</button>
  }
  @case ('expert') {
    <!-- Expert users also see advanced features -->
    <button>Advanced Features</button>
    <button>Expert Tools</button>
  }
  @case ('pro') {
    <button>Pro Features</button>
  }
  @default {
    <button>Basic Features</button>
  }
}

<!-- PATTERN 4: Switch with numeric cases -->
@switch (httpStatus) {
  @case (200) {
    <div class="success">Request successful</div>
  }
  @case (400) {
    <div class="error">Bad request</div>
  }
  @case (401) {
    <div class="error">Unauthorized</div>
  }
  @case (500) {
    <div class="error">Server error</div>
  }
  @default {
    <div class="info">Status: {{ httpStatus }}</div>
  }
}
```

### 4. @try/@catch (Brand New - Error Handling)

> **This is brand new in Angular 17+!** No JavaScript equivalent, Angular's unique feature for template error handling.

```html
<!-- Handle errors gracefully in templates! -->
@try {
  <div>{{ riskyValue.property.nested }}</div>
} @catch (error) {
  <div class="error-message">
    Error: {{ error.message }}
  </div>
}
```

**Why This Matters:**
- ✅ Handle runtime errors gracefully
- ✅ No need for guards like `riskyValue?.property?.nested`
- ✅ Prevents entire component from crashing
- ✅ Better user experience

**Detailed Examples:**

```html
<!-- PATTERN 1: Try-catch with safe fallbacks -->
@try {
  <div>
    <h2>{{ user.profile.fullName }}</h2>
    <p>{{ user.profile.bio }}</p>
  </div>
} @catch (error) {
  <div class="alert alert-danger">
    Unable to load user profile. Please refresh the page.
  </div>
}

<!-- PATTERN 2: Try-catch with data transformation -->
@try {
  <!-- Might throw if data format is wrong -->
  <div>
    Price: ${{ (product.price * exchangeRate).toFixed(2) }}
  </div>
} @catch (error) {
  <div>
    <p>Unable to calculate price</p>
    <p class="text-muted">Error: {{ error }}</p>
  </div>
}

<!-- PATTERN 3: Nested try-catch -->
@try {
  <div class="payment-form">
    @try {
      <label>Card Number</label>
      <input [value]="cardData.number | maskCardNumber" />
    } @catch (error) {
      <p>Invalid card format</p>
    }
    
    @try {
      <label>Expiry</label>
      <input [value]="cardData.expiry | formatExpiry" />
    } @catch (error) {
      <p>Invalid expiry format</p>
    }
  </div>
} @catch (error) {
  <p>Unable to load payment form</p>
}

<!-- PATTERN 4: Try-catch with recovery action -->
@try {
  <div>{{ complexCalculation() }}</div>
} @catch (error) {
  <div class="error-boundary">
    <p>⚠️ An error occurred while processing your request</p>
    <button (click)="retryComplexCalculation()">Retry</button>
    <p class="text-muted">Error ID: {{ error?.stack }}</p>
  </div>
}
```

### 5. @defer (Lazy Loading - Brand New)

> **Another brand new Angular 17+ feature!** Automatically defer rendering components until needed.

```html
<!-- Don't render until user scrolls here -->
@defer (on viewport) {
  <heavy-component></heavy-component>
} @placeholder {
  <div class="skeleton"></div>
} @loading (minimum 1s) {
  <div>Loading...</div>
} @error {
  <div>Failed to load</div>
}
```

**Key Benefits:**
- ✅ **Improves initial load time** - defer heavy components
- ✅ **On-demand rendering** - show when needed
- ✅ **Skeleton screens** - better UX
- ✅ **Automatic cleanup** - reclaim memory

**Detailed Examples:**

```html
<!-- PATTERN 1: Defer on viewport (lazy load on scroll) -->
@defer (on viewport) {
  <app-detailed-product-info 
    [productId]="productId"
  ></app-detailed-product-info>
} @placeholder {
  <div class="product-info-skeleton">
    <div class="skeleton-line"></div>
    <div class="skeleton-line"></div>
  </div>
}

<!-- PATTERN 2: Defer on interaction (load when user interacts) -->
@defer (on interaction) {
  <app-comments-section 
    [postId]="postId"
  ></app-comments-section>
} @placeholder {
  <button class="load-comments">Load Comments</button>
} @loading (minimum 500ms) {
  <p>Loading comments...</p>
} @error {
  <p>Unable to load comments</p>
}

<!-- PATTERN 3: Defer on timer -->
@defer (on timer(5000)) {
  <app-recommended-products></app-recommended-products>
} @placeholder {
  <p>Recommendations coming soon...</p>
}

<!-- PATTERN 4: Defer with custom condition -->
<button (click)="showAdvancedOptions = true">
  Show Advanced Options
</button>

@defer (when showAdvancedOptions) {
  <app-advanced-filter-panel
    (onFilter)="applyFilter($event)"
  ></app-advanced-filter-panel>
} @placeholder {
  <div class="filter-skeleton"></div>
}

<!-- PATTERN 5: Multiple defer blocks for different sections -->
<div class="dashboard">
  <!-- Critical content - no defer -->
  <app-dashboard-header></app-dashboard-header>
  
  <!-- Secondary content - defer on viewport -->
  @defer (on viewport) {
    <app-analytics-charts></app-analytics-charts>
  } @placeholder {
    <div class="chart-skeleton"></div>
  }
  
  <!-- Heavy component - defer on interaction -->
  @defer (on interaction) {
    <app-report-generator></app-report-generator>
  } @placeholder {
    <button>Generate Report</button>
  }
</div>
```

### Migration: Old vs New Syntax Comparison

```html
<!-- ================================================================ -->
<!-- COMPARISON 1: Conditional Rendering (*ngIf → @if) -->
<!-- ================================================================ -->

<!-- BEFORE (Angular 16 and earlier) -->
<ng-container *ngIf="user; else noUser">
  <h2>{{ user.name }}</h2>
  <p>{{ user.email }}</p>
</ng-container>
<ng-template #noUser>
  <p>No user data available</p>
</ng-template>

<!-- AFTER (Angular 17+) -->
@if (user) {
  <h2>{{ user.name }}</h2>
  <p>{{ user.email }}</p>
} @else {
  <p>No user data available</p>
}

<!-- ================================================================ -->
<!-- COMPARISON 2: Loops (*ngFor → @for) -->
<!-- ================================================================ -->

<!-- BEFORE (Angular 16 and earlier) -->
<ul>
  <li *ngFor="let item of items; trackBy: trackById; let i = index">
    #{{ i + 1 }}: {{ item.name }}
  </li>
</ul>

<!-- AFTER (Angular 17+) -->
<ul>
  @for (item of items; let i = $index; track item.id) {
    <li>#{{ i + 1 }}: {{ item.name }}</li>
  }
</ul>

<!-- ================================================================ -->
<!-- COMPARISON 3: Conditional Chains -->
<!-- ================================================================ -->

<!-- BEFORE (Angular 16 and earlier) - Very Verbose! -->
<div [ngSwitch]="status">
  <div *ngSwitchCase="'loading'">Loading...</div>
  <div *ngSwitchCase="'success'">Success!</div>
  <div *ngSwitchCase="'error'">Error!</div>
  <div *ngSwitchDefault>Unknown</div>
</div>

<!-- AFTER (Angular 17+) - Much Clearer! -->
@switch (status) {
  @case ('loading') { <div>Loading...</div> }
  @case ('success') { <div>Success!</div> }
  @case ('error') { <div>Error!</div> }
  @default { <div>Unknown</div> }
}
```

### Performance Tips with New Control Flow

```html
<!-- ✅ GOOD: Use track for optimal performance in loops -->
@for (item of largeList; track item.id) {
  <div>{{ item.name }}</div>
}

<!-- ❌ BAD: Without track, Angular re-creates DOM on every change -->
@for (item of largeList) {
  <div>{{ item.name }}</div>
}

<!-- ✅ GOOD: Use @defer for heavy components -->
@defer (on viewport) {
  <app-heavy-computation></app-heavy-computation>
} @placeholder {
  <div class="skeleton"></div>
}

<!-- ❌ BAD: Render everything upfront (slower initial load) -->
<app-heavy-computation></app-heavy-computation>

<!-- ✅ GOOD: Use @try/@catch to prevent component crashes -->
@try {
  <div>{{ riskyOperation() }}</div>
} @catch (error) {
  <div>Error handled gracefully</div>
}

<!-- ❌ BAD: Unhandled errors crash entire section -->
<div>{{ riskyOperation() }}</div>
```

### Browser & Version Support

| Feature | Introduced | Minimum Angular |
|---------|-----------|-----------------|
| `@if` | Angular 17 | 17.0.0 |
| `@for` | Angular 17 | 17.0.0 |
| `@switch/@case` | Angular 17 | 17.0.0 |
| `@try/@catch` | Angular 17 | 17.0.0 |
| `@defer` | Angular 17 | 17.0.0 |
| `@empty` in `@for` | Angular 17 | 17.0.0 |

### Common Pitfalls with New Control Flow

```typescript
// ❌ PROBLEM: Forgetting track in @for with large lists
@for (item of items) {
  <div>{{ item.name }}</div>  // Creates new DOM every time items change
}

// ✅ SOLUTION: Always use track for performance
@for (item of items; track item.id) {
  <div>{{ item.name }}</div>  // Reuses existing DOM, better performance
}

// ❌ PROBLEM: @defer without proper loading state
@defer (on viewport) {
  <app-heavy></app-heavy>
}
// User sees nothing until component loads!

// ✅ SOLUTION: Provide placeholder and loading states
@defer (on viewport) {
  <app-heavy></app-heavy>
} @placeholder {
  <div class="skeleton"></div>
} @loading (minimum 500ms) {
  <p>Loading...</p>
}

// ❌ PROBLEM: Complex logic in @if condition
@if (user && user.role === 'admin' && user.permissions.includes('manage-users') && !user.isSuspended) {
  <div>Admin Panel</div>
}

// ✅ SOLUTION: Move logic to component class
@if (canAccessAdminPanel) {
  <div>Admin Panel</div>
}

// In component.ts
get canAccessAdminPanel(): boolean {
  return this.user 
    && this.user.role === 'admin' 
    && this.user.permissions.includes('manage-users')
    && !this.user.isSuspended;
}
```

---

## 3. State Management: Redux vs NgRx

### Redux (React)
```typescript
// store/slices/authSlice.ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  token: null,
  loading: false,
  error: null,
};

// Async Thunk (side effects)
export const login = createAsyncThunk(
  'auth/login',
  async (credentials: LoginCredentials, { rejectWithValue }) => {
    try {
      const response = await authApi.login(credentials);
      localStorage.setItem('token', response.token);
      return response;
    } catch (error) {
      return rejectWithValue(error.message);
    }
  }
);

export const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    logout: (state) => {
      state.user = null;
      state.token = null;
      localStorage.removeItem('token');
    },
    setUser: (state, action: PayloadAction<User>) => {
      state.user = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.loading = false;
        state.user = action.payload.user;
        state.token = action.payload.token;
      })
      .addCase(login.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

// Usage in Component
import { useSelector, useDispatch } from 'react-redux';
import { login, logout } from './authSlice';

const LoginComponent = () => {
  const dispatch = useDispatch<AppDispatch>();
  const { user, loading, error } = useSelector((state: RootState) => state.auth);

  const handleLogin = async (credentials: LoginCredentials) => {
    const result = await dispatch(login(credentials));
    if (login.fulfilled.match(result)) {
      navigate('/dashboard');
    }
  };

  return (/* JSX */);
};
```

### NgRx (Angular)
```typescript
// store/auth/auth.actions.ts
import { createAction, props } from '@ngrx/store';

export const login = createAction(
  '[Auth] Login',
  props<{ credentials: LoginCredentials }>()
);
export const loginSuccess = createAction(
  '[Auth] Login Success',
  props<{ user: User; token: string }>()
);
export const loginFailure = createAction(
  '[Auth] Login Failure',
  props<{ error: string }>()
);
export const logout = createAction('[Auth] Logout');
```

```typescript
// store/auth/auth.reducer.ts
import { createReducer, on } from '@ngrx/store';
import * as AuthActions from './auth.actions';

export interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

const initialState: AuthState = {
  user: null,
  token: null,
  loading: false,
  error: null,
};

export const authReducer = createReducer(
  initialState,
  on(AuthActions.login, (state) => ({
    ...state,
    loading: true,
    error: null,
  })),
  on(AuthActions.loginSuccess, (state, { user, token }) => ({
    ...state,
    loading: false,
    user,
    token,
  })),
  on(AuthActions.loginFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error,
  })),
  on(AuthActions.logout, () => initialState)
);
```

```typescript
// store/auth/auth.effects.ts - THIS IS THE KEY DIFFERENCE!
import { Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, exhaustMap, catchError, tap } from 'rxjs/operators';
import * as AuthActions from './auth.actions';

@Injectable()
export class AuthEffects {
  // Effects handle side effects (API calls, localStorage, navigation)
  login$ = createEffect(() =>
    this.actions$.pipe(
      // ofType() — filter the action stream to only 'login' actions
      // WHY: The actions$ stream carries ALL dispatched actions from the entire app.
      //      ofType() acts like a filter() so this effect only reacts to AuthActions.login
      ofType(AuthActions.login),

      // exhaustMap() — ignore new login actions while a login HTTP call is in flight
      // WHY: Prevents double-login if user clicks the button rapidly.
      //      Unlike switchMap (which would cancel the in-flight request), exhaustMap
      //      simply ignores new login attempts until the current one resolves.
      exhaustMap(({ credentials }) =>
        this.authService.login(credentials).pipe(
          // map() — transform the HTTP response into a success Action
          // WHY: Effects must return Actions (not raw data). map() wraps the API
          //      response into the correct NgRx action shape for the reducer to consume.
          map(response => AuthActions.loginSuccess({
            user: response.user,
            token: response.token
          })),

          // catchError() — catch HTTP error, dispatch failure Action (don't throw)
          // WHY: If placed outside exhaustMap, a failed login KILLS the entire effect stream —
          //      no future logins would work. Placed inside, each login attempt is isolated.
          //      of() wraps the failure action as an Observable so the stream continues.
          catchError(error => of(AuthActions.loginFailure({ error: error.message })))
        )
      )
    )
  );

  // tap() — run side effects (localStorage write + navigation) WITHOUT emitting a new Action
  // WHY: tap() lets us "do something" mid-stream without transforming the value.
  //      Here we store the token and navigate — purely side effects, no new action needed.
  //      { dispatch: false } tells NgRx this effect won't dispatch a follow-up action.
  loginSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(AuthActions.loginSuccess),
      tap(({ token }) => {
        localStorage.setItem('token', token);   // WHY: persist token for page reload
        this.router.navigate(['/dashboard']);    // WHY: redirect after successful login
      })
    ),
    { dispatch: false }  // No new action dispatched — tap() handles side effects only
  );

  logout$ = createEffect(() =>
    this.actions$.pipe(
      ofType(AuthActions.logout),
      // tap() again — cleanup side effects on logout without dispatching another action
      // WHY: Clearing storage and redirecting are fire-and-forget side effects.
      //      Using tap() keeps the stream alive while executing imperative cleanup.
      tap(() => {
        localStorage.removeItem('token');       // WHY: clear auth token from storage
        this.router.navigate(['/login']);        // WHY: send user back to login page
      })
    ),
    { dispatch: false }
  );

  constructor(
    private actions$: Actions,
    private authService: AuthService,
    private router: Router
  ) {}
}
```

```typescript
// store/auth/auth.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { AuthState } from './auth.reducer';

export const selectAuthState = createFeatureSelector<AuthState>('auth');

export const selectUser = createSelector(
  selectAuthState,
  (state) => state.user
);

export const selectIsAuthenticated = createSelector(
  selectAuthState,
  (state) => !!state.token
);

export const selectAuthLoading = createSelector(
  selectAuthState,
  (state) => state.loading
);

export const selectAuthError = createSelector(
  selectAuthState,
  (state) => state.error
);

// Composed selector
export const selectUserWithPermissions = createSelector(
  selectUser,
  selectPermissions,
  (user, permissions) => ({ user, permissions })
);
```

```typescript
// Usage in Component
import { Component } from '@angular/core';
import { Store } from '@ngrx/store';
import { Observable } from 'rxjs';
import * as AuthActions from './store/auth.actions';
import * as AuthSelectors from './store/auth.selectors';

@Component({
  selector: 'app-login',
  template: `
    <form (ngSubmit)="onLogin()">
      <input [(ngModel)]="credentials.email" name="email">
      <input [(ngModel)]="credentials.password" name="password" type="password">
      <button type="submit" [disabled]="loading$ | async">
        {{ (loading$ | async) ? 'Loading...' : 'Login' }}
      </button>
      <div *ngIf="error$ | async as error" class="error">{{ error }}</div>
    </form>
  `
})
export class LoginComponent {
  credentials = { email: '', password: '' };

  // Selectors return Observables - use async pipe in template
  loading$ = this.store.select(AuthSelectors.selectAuthLoading);
  error$ = this.store.select(AuthSelectors.selectAuthError);

  constructor(private store: Store) {}

  onLogin(): void {
    this.store.dispatch(AuthActions.login({ credentials: this.credentials }));
  }
}
```

### Redux vs NgRx Comparison

| Concept | Redux Toolkit | NgRx |
|---------|--------------|------|
| Actions | `createSlice` auto-generates | `createAction` - explicit |
| Reducers | Inside `createSlice` | `createReducer` with `on()` |
| Side Effects | `createAsyncThunk` | `Effects` (RxJS-based) |
| Selectors | `useSelector` hook | `store.select()` + `async` pipe |
| DevTools | Redux DevTools | Redux DevTools (same!) |
| Middleware | Custom middleware | Effects + Meta-reducers |

---

## 4. Cross-Cutting Concerns

### React: Custom Hooks + Context + HOCs

```typescript
// hooks/useApi.ts - Centralized API handling
import { useState, useCallback } from 'react';
import axios, { AxiosRequestConfig } from 'axios';
import { useAuth } from './useAuth';

interface UseApiOptions<T> {
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
}

export function useApi<T>() {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const { token, logout } = useAuth();

  const execute = useCallback(async (
    config: AxiosRequestConfig,
    options?: UseApiOptions<T>
  ) => {
    setLoading(true);
    setError(null);

    try {
      const response = await axios({
        ...config,
        headers: {
          ...config.headers,
          Authorization: token ? `Bearer ${token}` : undefined,
        },
      });
      setData(response.data);
      options?.onSuccess?.(response.data);
      return response.data;
    } catch (err: any) {
      if (err.response?.status === 401) {
        logout();  // Cross-cutting: auto logout on 401
      }
      const error = new Error(err.response?.data?.message || err.message);
      setError(error);
      options?.onError?.(error);
      throw error;
    } finally {
      setLoading(false);
    }
  }, [token, logout]);

  return { data, loading, error, execute };
}

// Higher-Order Component for auth protection
export function withAuth<P extends object>(
  WrappedComponent: React.ComponentType<P>
): React.FC<P> {
  return function WithAuthComponent(props: P) {
    const { isAuthenticated, loading } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
      if (!loading && !isAuthenticated) {
        navigate('/login');
      }
    }, [isAuthenticated, loading, navigate]);

    if (loading) return <LoadingSpinner />;
    if (!isAuthenticated) return null;

    return <WrappedComponent {...props} />;
  };
}

// Error Boundary (Class component - React limitation)
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}
```

### Angular: Interceptors, Guards, and Services

```typescript
// core/interceptors/jwt.interceptor.ts
import { Injectable } from '@angular/core';
import {
  HttpInterceptor, HttpRequest, HttpHandler,
  HttpEvent, HttpErrorResponse
} from '@angular/common/http';
import { Observable, throwError, BehaviorSubject } from 'rxjs';
import { catchError, filter, take, switchMap } from 'rxjs/operators';

@Injectable()
export class JwtInterceptor implements HttpInterceptor {
  private isRefreshing = false;

  // BehaviorSubject<string | null> — shared token state across concurrent 401s
  // WHY: When multiple requests fail with 401 simultaneously, only ONE should trigger
  //      a token refresh. The others queue here waiting for the new token.
  //      null = "refresh in progress, don't proceed yet"
  //      string = "new token ready, all queued requests can retry now"
  private refreshTokenSubject = new BehaviorSubject<string | null>(null);

  constructor(private authService: AuthService) {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = this.authService.getToken();
    if (token) {
      request = this.addToken(request, token);
    }

    return next.handle(request).pipe(
      // catchError() — intercept HTTP errors mid-stream
      // WHY: Every HTTP response flows through here. We specifically look for 401
      //      (Unauthorized) to trigger token refresh. All other errors are re-thrown.
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401) {
          return this.handle401Error(request, next);  // WHY: refresh token and retry
        }
        // throwError() — re-throw non-401 errors as an Observable error
        // WHY: Converts a plain error back into an Observable so the pipe chain
        //      propagates it correctly to the component's error handler
        return throwError(() => error);
      })
    );
  }

  private addToken(request: HttpRequest<any>, token: string): HttpRequest<any> {
    return request.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
  }

  private handle401Error(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    if (!this.isRefreshing) {
      this.isRefreshing = true;
      this.refreshTokenSubject.next(null);  // WHY: signal "refresh in progress" to queued requests

      return this.authService.refreshToken().pipe(
        // switchMap() — when refresh succeeds, use the new token to retry the original request
        // WHY: switchMap flattens the token response into a new HTTP call (the retried request).
        //      The original failed request is replayed with the fresh Bearer token.
        switchMap((token: string) => {
          this.isRefreshing = false;
          this.refreshTokenSubject.next(token);  // WHY: unblock all queued requests with new token
          return next.handle(this.addToken(request, token));
        }),

        // catchError() — if refresh itself fails, log out the user
        // WHY: Refresh token is also expired/invalid — user must re-authenticate.
        //      throwError() propagates the error to the original caller.
        catchError((err) => {
          this.isRefreshing = false;
          this.authService.logout();
          return throwError(() => err);
        })
      );
    }

    // Already refreshing — queue this request until the new token is ready
    return this.refreshTokenSubject.pipe(
      // filter(token => token !== null) — wait while refreshTokenSubject is null
      // WHY: null means "refresh in progress". Hold all queued requests here
      //      until refreshTokenSubject emits an actual token string.
      filter(token => token !== null),

      // take(1) — complete after receiving the first token value
      // WHY: Once we get the new token, this queued request only needs it once.
      //      Without take(1), this subscription would stay alive indefinitely.
      take(1),

      // switchMap() — retry the original request with the newly refreshed token
      // WHY: switchMap maps the token value into a new HTTP call (the retried request).
      //      All queued requests now replay simultaneously with the fresh token.
      switchMap(token => next.handle(this.addToken(request, token!)))
    );
  }
}

// core/interceptors/error.interceptor.ts
@Injectable()
export class ErrorInterceptor implements HttpInterceptor {
  constructor(
    private notificationService: NotificationService,
    private router: Router
  ) {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(request).pipe(
      // catchError() — intercept ALL HTTP errors globally, show notification, re-throw
      // WHY: This interceptor provides a single location for user-facing error messages.
      //      Every HTTP error in the app flows through here — no per-component error handling needed.
      catchError((error: HttpErrorResponse) => {
        let errorMessage = 'An error occurred';

        if (error.error instanceof ErrorEvent) {
          // Client-side error
          errorMessage = error.error.message;
        } else {
          // Server-side error
          switch (error.status) {
            case 400:
              errorMessage = error.error?.message || 'Bad Request';
              break;
            case 403:
              errorMessage = 'Access Denied';
              this.router.navigate(['/forbidden']);
              break;
            case 404:
              errorMessage = 'Resource not found';
              break;
            case 500:
              errorMessage = 'Server Error';
              break;
          }
        }

        this.notificationService.showError(errorMessage);
        return throwError(() => new Error(errorMessage));
      })
    );
  }
}

// core/interceptors/loading.interceptor.ts
@Injectable()
export class LoadingInterceptor implements HttpInterceptor {
  private activeRequests = 0;

  constructor(private loadingService: LoadingService) {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    if (this.activeRequests === 0) {
      this.loadingService.show();
    }
    this.activeRequests++;

    return next.handle(request).pipe(
      // finalize() — runs cleanup whether the HTTP request completes OR errors
      // WHY: Like a finally{} block for Observables. Decrement counter + hide spinner
      //      regardless of success or failure — prevents stuck loading indicators.
      finalize(() => {
        this.activeRequests--;
        if (this.activeRequests === 0) {
          this.loadingService.hide();
        }
      })
    );
  }
}

// Register in app.module.ts
@NgModule({
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: JwtInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: LoadingInterceptor, multi: true },
  ]
})
export class AppModule {}
```

```typescript
// core/guards/auth.guard.ts
//
// 🔒 WHAT IS A GUARD?
// A Guard is a service that the Angular Router calls BEFORE activating a route.
// It acts as a gatekeeper: return true → allow navigation,
//                          return false/UrlTree → block and optionally redirect.
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// canActivate  vs  canLoad  — THE KEY DIFFERENCE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │  canActivate  — controls whether a route can be RENDERED                │
// │  canLoad      — controls whether the JS bundle is even DOWNLOADED       │
// └─────────────────────────────────────────────────────────────────────────┘
//
//  WITHOUT canLoad  (only canActivate on a lazy route):
//  ─────────────────────────────────────────────────────
//  User navigates to /admin
//        │
//        ▼
//  Angular downloads admin.chunk.js  ← ⚠️ JS is fetched from server HERE
//        │                              (unauthenticated user now has the code)
//        ▼
//  canActivate() runs — returns false/UrlTree
//        │
//        ▼
//  Redirect to /login  (bundle already downloaded — too late to protect it)
//
//  WITH canLoad  (guard on the lazy load itself):
//  ──────────────────────────────────────────────
//  User navigates to /admin
//        │
//        ▼
//  canLoad() runs — returns false/UrlTree  ← ✅ checked BEFORE any download
//        │
//        ▼
//  Redirect to /login  (admin.chunk.js was NEVER fetched — bundle is protected)
//
// ─────────────────────────────────────────────────────────────────────────────
// WHEN TO USE WHICH:
//
//  canActivate   → use on EVERY protected route (eager or lazy).
//                  Runs every visit, so it re-validates the session on each nav.
//                  E.g. token expired mid-session → next navigation is caught here.
//
//  canLoad       → use ONLY on lazy-loaded routes (loadChildren / loadComponent).
//                  Prevents the bundle download entirely for unauthorized users.
//                  Runs ONCE — when the module is first loaded. Subsequent visits
//                  to the same lazy route skip canLoad (bundle is already in memory).
//
//  BEST PRACTICE: use BOTH together on sensitive lazy routes:
//    canActivate: [AuthGuard]  — re-validates on every visit (session expiry etc.)
//    canLoad:     [AuthGuard]  — prevents initial bundle download
//
// ─────────────────────────────────────────────────────────────────────────────
// SIDE-BY-SIDE COMPARISON:
// ┌──────────────────┬───────────────────────────┬────────────────────────────┐
// │ Aspect           │ canActivate               │ canLoad                    │
// ├──────────────────┼───────────────────────────┼────────────────────────────┤
// │ Called when      │ Every navigation to route │ First load of lazy module  │
// │ Protects         │ Route rendering/view      │ JS bundle download         │
// │ Works on         │ Eager + lazy routes       │ Lazy routes ONLY           │
// │ Runs again?      │ Yes, every visit          │ No, only first time        │
// │ Access to route  │ ActivatedRouteSnapshot    │ Route + Segments           │
// │ Can redirect?    │ Yes (UrlTree)             │ Yes (UrlTree)              │
// │ Session expiry   │ ✅ catches it             │ ❌ won't re-run            │
// │ Bundle security  │ ❌ bundle already loaded  │ ✅ prevents download       │
// └──────────────────┴───────────────────────────┴────────────────────────────┘
//
// WHEN DOES THE ROUTER CALL EACH INTERFACE METHOD?
// ┌─────────────────────┬───────────────────────────────────────────────────────┐
// │ Interface           │ Called when...                                        │
// ├─────────────────────┼───────────────────────────────────────────────────────┤
// │ CanActivate         │ User navigates TO a route (every visit)               │
// │ CanActivateChild    │ User navigates to any CHILD route under this parent   │
// │ CanLoad             │ Lazy-loaded module is about to be DOWNLOADED (once)   │
// └─────────────────────┴───────────────────────────────────────────────────────┘
import { Injectable } from '@angular/core';
import { CanActivate, CanActivateChild, CanLoad, Router, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';
import { map, take } from 'rxjs/operators';
import { Store } from '@ngrx/store';
import { selectIsAuthenticated } from '../store/auth.selectors';

// providedIn: 'root' — singleton, one instance shared across the whole app
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate, CanActivateChild, CanLoad {
  constructor(private store: Store, private router: Router) {}

  // ── canActivate ─────────────────────────────────────────────────────────────
  // WHEN: Router calls this on EVERY navigation attempt to this route.
  // WHAT IT PROTECTS: whether the route's component is rendered.
  // KEY POINT: by the time canActivate runs on a lazy route, the JS chunk has
  //   already been downloaded. canActivate guards the VIEW, not the download.
  // USE CASE: re-validate the session on every visit (catches token expiry,
  //   logout in another tab, role changes mid-session).
  // RECEIVES: ActivatedRouteSnapshot (path params, data, queryParams)
  canActivate(): Observable<boolean | UrlTree> {
    return this.checkAuth();
    // → true        : component renders normally
    // → UrlTree     : router redirects, component never renders
  }

  // ── canActivateChild ─────────────────────────────────────────────────────────
  // WHEN: Router calls this before activating ANY child route of the parent.
  // WHAT IT PROTECTS: child route rendering under a parent route.
  // WHY USE IT: instead of adding canActivate:[AuthGuard] on every child route
  //   individually, put canActivateChild:[AuthGuard] once on the parent and ALL
  //   children are protected automatically — DRY, easier to maintain.
  // DIFFERENCE FROM canActivate: canActivate protects the parent route itself;
  //   canActivateChild protects the children without restricting the parent shell.
  canActivateChild(): Observable<boolean | UrlTree> {
    return this.checkAuth();
  }

  // ── canLoad ──────────────────────────────────────────────────────────────────
  // WHEN: Router calls this BEFORE fetching the lazy-loaded JS chunk from server.
  // WHAT IT PROTECTS: the network request for the bundle itself.
  // KEY DIFFERENCE FROM canActivate:
  //   canActivate  → bundle downloaded first, THEN guard runs (protects rendering)
  //   canLoad      → guard runs FIRST, bundle only downloads if guard passes
  //                  (protects both rendering AND the JS source code)
  // RUNS ONLY ONCE: after the module loads into memory, canLoad is never called
  //   again for that module — use canActivate alongside it for per-visit checks.
  // USE CASE: prevent unauthenticated users from ever receiving admin/feature code.
  //   Saves bandwidth + hides proprietary business logic from anonymous users.
  canLoad(): Observable<boolean | UrlTree> {
    return this.checkAuth();
    // If false/UrlTree → loadChildren() import() is NEVER called → chunk stays on server
  }

  // ─── Shared auth logic ───────────────────────────────────────────────────────
  // All three guard methods funnel into this one, keeping the logic DRY.
  private checkAuth(): Observable<boolean | UrlTree> {
    // store.select() returns a hot, infinite NgRx selector stream that replays
    // the current state value immediately and then emits on every state change.
    return this.store.select(selectIsAuthenticated).pipe(

      // take(1) — snap the CURRENT auth state and then COMPLETE the observable
      // WHY: Guards must return a completing Observable so the router knows the
      //      decision is final. NgRx selectors never complete on their own — they
      //      keep emitting forever as the store changes. take(1) takes the first
      //      emission (the current value right now), completes the stream, and
      //      unsubscribes automatically. Without it, the guard would hang forever.
      take(1),

      // map() — convert the boolean auth flag into the value the router expects
      // WHY: The router accepts Observable<boolean | UrlTree>.
      //      • true         → allow the navigation to proceed
      //      • false        → block navigation (shows nothing, bad UX)
      //      • UrlTree      → block AND redirect to the specified path (preferred)
      // createUrlTree(['/login']) builds a UrlTree the router uses to navigate
      // the user to /login instead of just silently blocking them.
      map(isAuthenticated =>
        isAuthenticated
          ? true                                     // ✅ authenticated — let them through
          : this.router.createUrlTree(['/login'])    // ❌ not logged in — redirect to /login
      )
    );
  }
}

// core/guards/role.guard.ts
//
// 🔑 WHAT IS RoleGuard?
// AuthGuard answers "are you logged in?". RoleGuard answers "do you have PERMISSION?".
// They are layered: AuthGuard runs first (configured in canActivate array order).
// If AuthGuard passes, RoleGuard checks whether the authenticated user holds one
// of the roles listed in route.data['roles'].
//
// HOW ROLES REACH THE GUARD:
// Route config  →  data: { roles: ['admin'] }
//                          ↓
// canActivate(route)  →  route.data['roles']  →  ['admin']
//                                                     ↓
//                               user.roles.includes('admin')  →  true/false
@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(private store: Store, private router: Router) {}

  // route: ActivatedRouteSnapshot — snapshot of the route being activated.
  // Contains path params, query params, and static data (our roles array).
  canActivate(route: ActivatedRouteSnapshot): Observable<boolean | UrlTree> {

    // Read the roles required for this specific route from its static data config.
    // Defined in the route as: data: { roles: ['admin', 'superadmin'] }
    // WHY string[]?: roles differ per route — the guard is generic, routes are specific.
    const requiredRoles = route.data['roles'] as string[];

    // store.select(selectUser) — stream of the currently authenticated user object
    // (or null if unauthenticated). Emits current value immediately, then on changes.
    return this.store.select(selectUser).pipe(

      // take(1) — take the current user snapshot and complete
      // WHY: Same reason as AuthGuard — guards must complete. Selectors don't.
      //      We only need to know the user's roles at THIS moment, not track changes.
      take(1),

      // map() — perform the role check and return allow/redirect decision
      // WHY: All logic lives here so the stream stays functional (no subscribe inside).
      //      Two separate redirects for two different failure cases (better UX):
      //        → not logged in at all  →  /login   (need to authenticate first)
      //        → logged in, wrong role →  /forbidden (authenticated but unauthorized)
      map(user => {
        // Guard against null: if no user in store, send to login
        // (Shouldn't normally reach here if AuthGuard runs first, but defensive.)
        if (!user) return this.router.createUrlTree(['/login']);

        // Array.some() — returns true if the user has AT LEAST ONE of the required roles.
        // WHY some() not every(): routes typically allow multiple qualifying roles
        // e.g. ['admin', 'superadmin'] — either role is sufficient.
        const hasRole = requiredRoles.some(role => user.roles.includes(role));

        return hasRole
          ? true                                         // ✅ has a qualifying role — allow
          : this.router.createUrlTree(['/forbidden']);   // ❌ authenticated but wrong role
      })
    );
  }
}

// ─── Usage in routing — canActivate + canLoad together ────────────────────────
//
// WHY use BOTH on the same route?
//   canLoad      → prevents the admin bundle being downloaded on first visit
//                  (runs once, before the import() ever fires)
//   canActivate  → re-validates auth on EVERY subsequent visit to /admin
//                  (canLoad won't re-run once the module is cached in memory)
//
// Together they give full protection:
//   • First visit unauthenticated  → canLoad blocks, bundle never fetched
//   • First visit authenticated    → canLoad passes, bundle downloads, canActivate passes, page renders
//   • Return visit, token expired  → canLoad skipped (bundle cached), canActivate catches expiry → /login
//   • Return visit, role revoked   → canLoad skipped, canActivate+RoleGuard catch it → /forbidden
//
// Guard execution ORDER within canActivate[]:
//   [AuthGuard, RoleGuard] — Angular runs them left to right.
//   If AuthGuard returns UrlTree, RoleGuard is never called (short-circuit).
const routes: Routes = [
  {
    path: 'admin',

    // canLoad — runs BEFORE import() fires; blocks bundle download for unauth users
    // Only AuthGuard needed here (RoleGuard isn't useful at download-time — roles
    // are per-page, not per-bundle; use canActivate for role enforcement)
    canLoad: [AuthGuard],

    // canActivate — runs on every visit; layered auth + role check
    // 1st guard: AuthGuard  → "are you logged in?"
    // 2nd guard: RoleGuard  → "do you have admin/superadmin role?"
    // Short-circuits: if AuthGuard fails, RoleGuard never runs
    canActivate: [AuthGuard, RoleGuard],

    // data.roles — static config passed to RoleGuard via route.data['roles']
    // ['admin', 'superadmin'] means EITHER role is sufficient (Array.some logic)
    data: { roles: ['admin', 'superadmin'] },

    // loadChildren — the import() only fires if canLoad passes
    // After first load, Angular caches the module; canLoad won't run again
    loadChildren: () => import('./features/admin/admin.module').then(m => m.AdminModule)
  }
];
```

---

## 4.5 React Context API & Hooks — Deep Dive

> **Why this section exists**: Context API and Hooks are the two most transformative features in modern React. They replace class components, eliminate prop drilling, and allow shared logic to be extracted into composable functions. Angular achieves similar goals via Services + Dependency Injection — understanding both reveals the fundamental design philosophies of each framework.

---

### Mental Model: What problem does each solve?

| Problem | React Solution | Angular Solution |
|---------|---------------|-----------------|
| Share state across components without prop drilling | **Context API** | **Services + DI** |
| Reuse stateful logic between components | **Custom Hooks** | **Services / Mixins** |
| Manage local state in functional components | **useState** | **Component properties / Signals** |
| Handle side effects (API calls, subscriptions) | **useEffect** | **ngOnInit / ngOnDestroy / RxJS** |
| Expensive computations | **useMemo** | **Pure Pipes / Getters** |
| Stable callback references | **useCallback** | **Methods (auto-stable)** |
| Direct DOM/child access | **useRef** | **@ViewChild** |
| Complex state with actions | **useReducer** | **NgRx / BehaviorSubject** |

---

### Part 1: Core Hooks — Detailed Explanation

#### 1.1 `useState` — Local Component State

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// useState: The most fundamental hook. Adds reactive state to a function
// component. When the setter is called, React schedules a re-render.
// ─────────────────────────────────────────────────────────────────────────────

import React, { useState } from 'react';

// ── BASIC USAGE ──────────────────────────────────────────────────────────────
const Counter = () => {
  // useState returns a TUPLE: [currentValue, setterFunction]
  // TypeScript infers <number> from the initial value (0)
  const [count, setCount] = useState(0);

  // ❌ WRONG: Mutating state directly — React won't detect this change
  // count = count + 1;

  // ✅ CORRECT: Call the setter. React diffs and re-renders only what changed.
  return (
    <div>
      <p>Count: {count}</p>
      {/* Functional update form: use when new value depends on old value */}
      {/* This is safe even in async/batched updates */}
      <button onClick={() => setCount(prev => prev + 1)}>Increment</button>
      <button onClick={() => setCount(prev => prev - 1)}>Decrement</button>
      <button onClick={() => setCount(0)}>Reset</button>
    </div>
  );
};

// ── OBJECT STATE ──────────────────────────────────────────────────────────────
interface UserForm {
  name: string;
  email: string;
  age: number;
}

const UserFormComponent = () => {
  // When state is an object, useState does NOT deep-merge — you must spread manually
  const [form, setForm] = useState<UserForm>({ name: '', email: '', age: 0 });

  const handleChange = (field: keyof UserForm, value: string | number) => {
    // Spread the existing state, then override only the changed field
    // Without spread: setForm({ name: value }) would ERASE email and age!
    setForm(prev => ({ ...prev, [field]: value }));
  };

  return (
    <form>
      <input
        value={form.name}
        onChange={e => handleChange('name', e.target.value)}
      />
      <input
        value={form.email}
        onChange={e => handleChange('email', e.target.value)}
      />
    </form>
  );
};

// ── LAZY INITIALIZATION ───────────────────────────────────────────────────────
// Pass a function instead of a value when the initial state is expensive to compute.
// React calls this function ONLY on the first render (not every re-render).
const ExpensiveComponent = () => {
  const [data, setData] = useState<number[]>(() => {
    // This runs once. If you wrote `useState(computeExpensiveData())`,
    // computeExpensiveData() would run on EVERY render even though its
    // result is discarded after the first render.
    console.log('Computing initial data — only runs once!');
    return [1, 2, 3].map(n => n * 100);
  });

  return <div>{data.join(', ')}</div>;
};
```

**Angular Equivalent:**
```typescript
// Angular: State is just a class property. No special syntax needed.
// Change detection reads properties during its check cycle.
@Component({ selector: 'app-counter', template: `
  <p>Count: {{ count }}</p>
  <button (click)="increment()">+</button>
  <button (click)="decrement()">-</button>
` })
export class CounterComponent {
  count = 0;  // ← Plain property; Angular's CD detects mutations automatically

  increment() { this.count++; }     // Angular: mutate directly — CD picks it up
  decrement() { this.count--; }

  // Angular 17+ Signals alternative (closer to useState mental model):
  // count = signal(0);
  // increment() { this.count.update(v => v + 1); }
}
```

---

#### 1.2 `useEffect` — Side Effects & Lifecycle

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// useEffect: Run side effects (API calls, subscriptions, DOM manipulation)
// after the browser has painted. The dependency array controls WHEN it runs.
//
// Lifecycle mapping:
//   []           → componentDidMount    (run once on mount)
//   [dep1, dep2] → componentDidUpdate   (run when deps change)
//   no array     → runs after EVERY render
//   return fn    → componentWillUnmount (cleanup)
// ─────────────────────────────────────────────────────────────────────────────

import React, { useState, useEffect } from 'react';

interface Post { id: number; title: string; body: string; }

const PostViewer = ({ postId }: { postId: number }) => {
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // ── EFFECT 1: Fetch data when postId changes ──────────────────────────────
  useEffect(() => {
    // Reset state whenever postId changes (avoids showing stale data)
    setLoading(true);
    setError(null);

    // AbortController lets us cancel the fetch if postId changes
    // before the previous fetch completes (race condition prevention)
    const controller = new AbortController();

    const fetchPost = async () => {
      try {
        const response = await fetch(
          `https://jsonplaceholder.typicode.com/posts/${postId}`,
          { signal: controller.signal }  // ← Pass abort signal to fetch
        );

        if (!response.ok) throw new Error('Failed to fetch');

        const data: Post = await response.json();
        setPost(data);
      } catch (err) {
        // Ignore AbortError — it's expected when we cancel
        if ((err as Error).name !== 'AbortError') {
          setError((err as Error).message);
        }
      } finally {
        setLoading(false);
      }
    };

    fetchPost();

    // ── CLEANUP FUNCTION ──────────────────────────────────────────────────
    // React calls this before:
    //   1. The effect runs again (when postId changes)
    //   2. The component unmounts
    // Without this cleanup, if postId changes quickly, you'd get race conditions
    // where an old response overwrites a newer one.
    return () => controller.abort();

  }, [postId]); // ← Dependency array: re-run when postId changes

  // ── EFFECT 2: Document title (runs on every post change) ─────────────────
  useEffect(() => {
    if (post) {
      document.title = `Post: ${post.title}`;  // Side effect: DOM mutation
    }
    // Cleanup: restore title when component unmounts
    return () => { document.title = 'My App'; };
  }, [post]); // Only re-run when post changes, not on every render

  // ── EFFECT 3: Event listener (runs once on mount) ────────────────────────
  useEffect(() => {
    const handleKeyPress = (e: KeyboardEvent) => {
      if (e.key === 'Escape') console.log('Escape pressed!');
    };

    window.addEventListener('keydown', handleKeyPress);

    // CRITICAL: Remove the listener on unmount to prevent memory leaks
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, []); // ← Empty array = "run once when component mounts"

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!post) return null;

  return <article><h1>{post.title}</h1><p>{post.body}</p></article>;
};
```

**Angular Equivalent:**
```typescript
@Component({
  selector: 'app-post-viewer',
  template: `
    <div *ngIf="loading">Loading...</div>
    <div *ngIf="error">Error: {{ error }}</div>
    <article *ngIf="post">
      <h1>{{ post.title }}</h1>
      <p>{{ post.body }}</p>
    </article>
  `
})
export class PostViewerComponent implements OnInit, OnChanges, OnDestroy {
  @Input() postId!: number;

  post: Post | null = null;
  loading = true;
  error: string | null = null;

  // RxJS Subject used for cleanup — equivalent to AbortController
  private destroy$ = new Subject<void>();

  constructor(private http: HttpClient) {}

  // ← Equivalent to useEffect([], []) — runs once on mount
  ngOnInit(): void {
    this.fetchPost();
  }

  // ← Equivalent to useEffect([postId]) — runs when @Input changes
  ngOnChanges(changes: SimpleChanges): void {
    if (changes['postId'] && !changes['postId'].firstChange) {
      this.fetchPost();
    }
  }

  // ← Equivalent to the useEffect cleanup return function
  ngOnDestroy(): void {
    this.destroy$.next();    // Signal all subscriptions to complete
    this.destroy$.complete();
  }

  private fetchPost(): void {
    this.loading = true;
    this.error = null;

    this.http.get<Post>(`/api/posts/${this.postId}`)
      .pipe(takeUntil(this.destroy$))  // ← Auto-unsubscribe on destroy
      // Object form subscribe — explicitly handles both success and failure paths.
      // WHY object form over shorthand: HTTP calls can fail (network, 4xx, 5xx).
      //   Shorthand subscribe(fn) has no `error` handler — unhandled errors crash the stream silently.
      .subscribe({
        // next — fires ONCE when the HTTP response arrives with the Post body
        // WHY: HTTP GET Observables emit exactly ONE value then complete — so next fires once only
        next: post => { this.post = post; this.loading = false; },

        // error — fires if HTTP returns 4xx/5xx or the network fails; next/complete won't fire after this
        // WHY reset loading: prevents the spinner from being stuck on screen after a failure
        // NOTE: `complete` is intentionally omitted — not needed here because we don't need a "done" callback
        //   (loading=false is already handled in both next and error above)
        error: err => { this.error = err.message; this.loading = false; }
      });
  }
}
```

---

#### 1.3 `useMemo` & `useCallback` — Memoization

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// React re-renders components on every state change.
// useMemo: Cache an expensive computed VALUE.
// useCallback: Cache a FUNCTION reference (prevents child re-renders).
//
// Rule of thumb: Only memoize when you can measure a performance problem.
// Premature memoization adds complexity for no gain.
// ─────────────────────────────────────────────────────────────────────────────

import React, { useState, useMemo, useCallback, memo } from 'react';

interface Product { id: number; name: string; price: number; category: string; }

// ── React.memo: Only re-render if props actually changed ───────────────────
// Without memo, ProductItem re-renders every time parent renders,
// even if its props didn't change.
const ProductItem = memo(({ product, onSelect }: {
  product: Product;
  onSelect: (id: number) => void;
}) => {
  console.log(`Rendering product: ${product.name}`); // Shows memoization working
  return (
    <div onClick={() => onSelect(product.id)}>
      <h3>{product.name}</h3>
      <p>${product.price}</p>
    </div>
  );
});

const ProductList = ({ products }: { products: Product[] }) => {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc');
  const [selectedId, setSelectedId] = useState<number | null>(null);

  // ── useMemo: Expensive filter+sort computation ────────────────────────────
  // Without useMemo, this runs on EVERY render (including unrelated state changes)
  // With useMemo, it only re-runs when products, selectedCategory, or sortOrder changes
  const filteredProducts = useMemo(() => {
    console.log('Computing filtered products...'); // You'd see this less often with useMemo
    const filtered = selectedCategory === 'all'
      ? products
      : products.filter(p => p.category === selectedCategory);

    return [...filtered].sort((a, b) =>
      sortOrder === 'asc' ? a.price - b.price : b.price - a.price
    );
  }, [products, selectedCategory, sortOrder]); // ← Recompute when these change

  // ── useMemo: Derived statistics ───────────────────────────────────────────
  const stats = useMemo(() => ({
    total: filteredProducts.length,
    avgPrice: filteredProducts.reduce((sum, p) => sum + p.price, 0) / filteredProducts.length || 0,
    categories: [...new Set(products.map(p => p.category))]
  }), [filteredProducts, products]);

  // ── useCallback: Stable function reference for child components ──────────
  // Without useCallback, handleSelect is a NEW function on every render.
  // Since ProductItem uses React.memo and receives onSelect as a prop,
  // a new function reference would cause ProductItem to re-render anyway.
  // useCallback returns the SAME function reference as long as deps don't change.
  const handleSelect = useCallback((id: number) => {
    setSelectedId(id);
    console.log(`Selected product: ${id}`);
    // If you need to track analytics, call it here
  }, []); // ← No deps: function never changes (uses only stable setters)

  return (
    <div>
      <p>Showing {stats.total} products, avg price: ${stats.avgPrice.toFixed(2)}</p>

      <select onChange={e => setSelectedCategory(e.target.value)}>
        <option value="all">All</option>
        {stats.categories.map(cat => (
          <option key={cat} value={cat}>{cat}</option>
        ))}
      </select>

      <button onClick={() => setSortOrder(o => o === 'asc' ? 'desc' : 'asc')}>
        Sort {sortOrder === 'asc' ? '↑' : '↓'}
      </button>

      {filteredProducts.map(product => (
        // handleSelect is stable (useCallback), so ProductItem.memo works correctly
        <ProductItem key={product.id} product={product} onSelect={handleSelect} />
      ))}
    </div>
  );
};
```

**Angular Equivalent:**
```typescript
// Angular uses Pure Pipes for computed values (equivalent to useMemo)
// and OnPush change detection to prevent unnecessary renders (equivalent to React.memo)

@Pipe({ name: 'filterProducts', pure: true }) // pure: true = only recalculates when inputs change
export class FilterProductsPipe implements PipeTransform {
  transform(products: Product[], category: string, sort: 'asc' | 'desc'): Product[] {
    const filtered = category === 'all' ? products : products.filter(p => p.category === category);
    return [...filtered].sort((a, b) => sort === 'asc' ? a.price - b.price : b.price - a.price);
  }
}

@Component({
  // OnPush: Only re-render when @Input reference changes or event fires
  // Equivalent to React.memo wrapping every child
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <!-- Pure pipe = memoized — only recalculates when products/category/sort change -->
    <div *ngFor="let product of products | filterProducts:category:sort">
      {{ product.name }}
    </div>
  `
})
export class ProductListComponent {
  @Input() products: Product[] = [];
  category = 'all';
  sort: 'asc' | 'desc' = 'asc';
  // Angular methods are already stable references — no useCallback needed
}
```

---

#### 1.4 `useRef` — Mutable Refs & DOM Access

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// useRef has TWO use cases:
//   1. DOM access: get a direct reference to a DOM element
//   2. Mutable instance variable: store a value that persists across renders
//      WITHOUT triggering a re-render when changed (unlike useState)
// ─────────────────────────────────────────────────────────────────────────────

import React, { useState, useEffect, useRef } from 'react';

// ── USE CASE 1: DOM Access ────────────────────────────────────────────────
const AutoFocusInput = () => {
  // Ref starts as null; React assigns the DOM element after mount
  // TypeScript: HTMLInputElement is the element type for <input>
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    // After component mounts, programmatically focus the input
    // inputRef.current is null until after first render
    inputRef.current?.focus();
  }, []); // Only on mount

  return <input ref={inputRef} placeholder="I auto-focus on mount!" />;
};

// ── USE CASE 2: Previous Value Tracker (no re-render side effect) ─────────
function usePrevious<T>(value: T): T | undefined {
  // useRef stores the previous value WITHOUT causing a re-render
  // If you used useState here, updating previous would cause infinite loops
  const ref = useRef<T>();

  useEffect(() => {
    // After render completes, save current value for next render's comparison
    ref.current = value;
  }); // No dependency array: runs after every render

  return ref.current; // Returns the value from BEFORE this render
}

const PriceTracker = ({ price }: { price: number }) => {
  const prevPrice = usePrevious(price);

  return (
    <div>
      <span>Current: ${price}</span>
      {prevPrice !== undefined && (
        <span style={{ color: price > prevPrice ? 'green' : 'red' }}>
          {price > prevPrice ? '▲' : '▼'} was ${prevPrice}
        </span>
      )}
    </div>
  );
};

// ── USE CASE 3: Timer/Interval without stale closure ─────────────────────
const Stopwatch = () => {
  const [elapsed, setElapsed] = useState(0);
  const [running, setRunning] = useState(false);

  // Store interval ID in a ref so it persists across renders
  // and doesn't trigger re-renders when changed
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const start = () => {
    if (running) return;
    setRunning(true);
    intervalRef.current = setInterval(() => {
      // Functional update: reads current state, never stale
      setElapsed(prev => prev + 1);
    }, 1000);
  };

  const stop = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current); // Clear using the stored ID
      intervalRef.current = null;
    }
    setRunning(false);
  };

  // Cleanup on unmount — critical to avoid memory leaks
  useEffect(() => () => stop(), []);

  return (
    <div>
      <p>{elapsed}s</p>
      <button onClick={start} disabled={running}>Start</button>
      <button onClick={stop} disabled={!running}>Stop</button>
    </div>
  );
};
```

**Angular Equivalent:**
```typescript
// Angular equivalent of useRef for DOM access
@Component({ template: `<input #myInput placeholder="Auto focus">` })
export class AutoFocusComponent implements AfterViewInit {
  // @ViewChild equivalent to useRef<HTMLInputElement>
  @ViewChild('myInput') inputRef!: ElementRef<HTMLInputElement>;

  ngAfterViewInit(): void {
    // Equivalent to useEffect([], []) + ref.current?.focus()
    this.inputRef.nativeElement.focus();
  }
}
```

---

#### 1.5 `useReducer` — Complex State Management

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// useReducer is useState for complex state.
// Use it when:
//   • State has multiple sub-values that change together
//   • Next state depends on previous state in non-trivial ways
//   • You want to centralize state transition logic (like a mini Redux)
// ─────────────────────────────────────────────────────────────────────────────

import React, { useReducer } from 'react';

// ── Define the shape of your state ────────────────────────────────────────
interface CartState {
  items: Array<{ id: number; name: string; price: number; quantity: number }>;
  total: number;
  discount: number;
  couponCode: string | null;
}

// ── Define all possible actions with discriminated unions ─────────────────
// Discriminated union: TypeScript narrows the type based on the `type` field
type CartAction =
  | { type: 'ADD_ITEM'; payload: { id: number; name: string; price: number } }
  | { type: 'REMOVE_ITEM'; payload: { id: number } }
  | { type: 'UPDATE_QUANTITY'; payload: { id: number; quantity: number } }
  | { type: 'APPLY_COUPON'; payload: { code: string; discount: number } }
  | { type: 'CLEAR_CART' };

// ── Reducer: pure function (state, action) → new state ───────────────────
// PURE: no side effects, no mutations, same input always gives same output
// This makes it testable and predictable
function cartReducer(state: CartState, action: CartAction): CartState {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find(i => i.id === action.payload.id);

      const updatedItems = existingItem
        // Item already in cart: increment quantity
        ? state.items.map(i =>
            i.id === action.payload.id ? { ...i, quantity: i.quantity + 1 } : i
          )
        // New item: append with quantity 1
        : [...state.items, { ...action.payload, quantity: 1 }];

      return {
        ...state,
        items: updatedItems,
        // Recalculate total when items change
        total: updatedItems.reduce((sum, i) => sum + i.price * i.quantity, 0)
      };
    }

    case 'REMOVE_ITEM': {
      const updatedItems = state.items.filter(i => i.id !== action.payload.id);
      return {
        ...state,
        items: updatedItems,
        total: updatedItems.reduce((sum, i) => sum + i.price * i.quantity, 0)
      };
    }

    case 'UPDATE_QUANTITY': {
      const updatedItems = state.items.map(i =>
        i.id === action.payload.id
          ? { ...i, quantity: Math.max(0, action.payload.quantity) }
          : i
      ).filter(i => i.quantity > 0); // Remove items with quantity 0

      return {
        ...state,
        items: updatedItems,
        total: updatedItems.reduce((sum, i) => sum + i.price * i.quantity, 0)
      };
    }

    case 'APPLY_COUPON':
      return { ...state, couponCode: action.payload.code, discount: action.payload.discount };

    case 'CLEAR_CART':
      return { items: [], total: 0, discount: 0, couponCode: null };

    default:
      return state; // Always return state for unknown actions
  }
}

const initialCartState: CartState = { items: [], total: 0, discount: 0, couponCode: null };

const ShoppingCart = () => {
  // useReducer returns [state, dispatch]
  // dispatch(action) → calls reducer → returns new state → triggers re-render
  const [cart, dispatch] = useReducer(cartReducer, initialCartState);

  const finalTotal = cart.total * (1 - cart.discount / 100);

  return (
    <div>
      <button onClick={() => dispatch({
        type: 'ADD_ITEM',
        payload: { id: 1, name: 'Widget', price: 29.99 }
      })}>
        Add Widget
      </button>

      {cart.items.map(item => (
        <div key={item.id}>
          <span>{item.name} × {item.quantity}</span>
          <button onClick={() => dispatch({
            type: 'UPDATE_QUANTITY',
            payload: { id: item.id, quantity: item.quantity + 1 }
          })}>+</button>
          <button onClick={() => dispatch({
            type: 'REMOVE_ITEM',
            payload: { id: item.id }
          })}>Remove</button>
        </div>
      ))}

      <p>Total: ${finalTotal.toFixed(2)}</p>
      <button onClick={() => dispatch({ type: 'CLEAR_CART' })}>Clear Cart</button>
    </div>
  );
};
```

**Angular Equivalent:**
```typescript
// Angular: Use a Service with BehaviorSubject (or NgRx for larger scale)
@Injectable({ providedIn: 'root' })
export class CartService {
  // BehaviorSubject = reactive state container, similar to useReducer state
  private cartState = new BehaviorSubject<CartState>({ items: [], total: 0, discount: 0, couponCode: null });

  // Public observable — components subscribe to this (not the Subject directly)
  cart$ = this.cartState.asObservable();

  // Methods = dispatch functions
  addItem(product: { id: number; name: string; price: number }): void {
    const current = this.cartState.getValue();
    // ... same logic as reducer ...
    this.cartState.next(updatedState);
  }

  removeItem(id: number): void { /* ... */ }
  clearCart(): void { this.cartState.next({ items: [], total: 0, discount: 0, couponCode: null }); }
}

@Component({ template: `<div *ngFor="let item of (cart$ | async)?.items">{{ item.name }}</div>` })
export class CartComponent {
  cart$ = this.cartService.cart$; // Subscribe via async pipe (auto-unsubscribes)
  constructor(private cartService: CartService) {}
  add(product: Product) { this.cartService.addItem(product); }
}
```

---

### Part 2: Context API — Deep Dive

#### 2.1 How Context Works Internally

```
Before Context (Prop Drilling):
  App (has user)
    └── Layout
          └── Sidebar
                └── UserAvatar ← needs user (passed through Layout & Sidebar!)

With Context:
  App
    └── UserContext.Provider (value={user})
          └── Layout             ← doesn't need user
                └── Sidebar      ← doesn't need user
                      └── UserAvatar ← reads from context directly!
```

Context creates a **vertical channel** through the component tree. Any component inside the Provider can read the value without intermediate components needing to know about it.

#### 2.2 Building a Complete Context System

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// FILE: context/ThemeContext.tsx
//
// Pattern: Create context → Create Provider component → Create custom hook
// This is the standard, production-grade way to use Context in React.
// ─────────────────────────────────────────────────────────────────────────────

import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';

// ── Step 1: Define the shape of your context value ────────────────────────
type Theme = 'light' | 'dark' | 'system';

interface ThemeContextValue {
  theme: Theme;              // Current theme value
  setTheme: (theme: Theme) => void;  // Setter
  isDark: boolean;           // Derived value (computed from theme)
  toggleTheme: () => void;  // Convenience method
}

// ── Step 2: Create the context with a default value ───────────────────────
// The default value is used ONLY when a component reads context
// without being wrapped in a Provider. In practice, you should
// throw an error instead of silently returning a default (see hook below).
// Using `undefined` as default forces us to handle the "no provider" case.
const ThemeContext = createContext<ThemeContextValue | undefined>(undefined);

// ── Step 3: Create the Provider component ────────────────────────────────
// This wraps part (or all) of your app and provides the context value.
// Children don't care where the value comes from — they just consume it.
export const ThemeProvider = ({ children }: { children: ReactNode }) => {
  const [theme, setThemeState] = useState<Theme>(() => {
    // Lazy init: read from localStorage on first render only
    return (localStorage.getItem('theme') as Theme) || 'system';
  });

  // Determine if we're in dark mode
  // (system preference detection via matchMedia)
  const isDark = theme === 'dark' ||
    (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

  // Wrap setTheme to also persist to localStorage
  const setTheme = useCallback((newTheme: Theme) => {
    setThemeState(newTheme);
    localStorage.setItem('theme', newTheme); // Side effect: persist preference
    document.documentElement.setAttribute('data-theme', newTheme); // Apply to DOM
  }, []);

  const toggleTheme = useCallback(() => {
    setTheme(isDark ? 'light' : 'dark');
  }, [isDark, setTheme]);

  // The value prop is what all consumers receive
  // Tip: Memoize this object if the Provider is high in the tree and
  // context value changes often — prevents unnecessary consumer re-renders
  const value: ThemeContextValue = { theme, setTheme, isDark, toggleTheme };

  return (
    <ThemeContext.Provider value={value}>
      {/* Apply theme class to a wrapper so CSS can respond */}
      <div className={isDark ? 'dark-theme' : 'light-theme'}>
        {children}
      </div>
    </ThemeContext.Provider>
  );
};

// ── Step 4: Create a custom hook for safe consumption ─────────────────────
// This is the ONLY way components should access this context.
// Benefits:
//   1. Throws a descriptive error if used outside the provider
//   2. Hides implementation detail (consumers don't import ThemeContext directly)
//   3. Easy to refactor later (change context to Redux without touching consumers)
export const useTheme = (): ThemeContextValue => {
  const context = useContext(ThemeContext);

  if (context === undefined) {
    // This error tells developers exactly what went wrong and how to fix it
    throw new Error('useTheme must be used within a <ThemeProvider>. ' +
      'Wrap your component tree with <ThemeProvider> in App.tsx');
  }

  return context;
};
```

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// FILE: App.tsx — Provider Setup
// ─────────────────────────────────────────────────────────────────────────────

import { ThemeProvider } from './context/ThemeContext';
import { AuthProvider } from './context/AuthContext';
import { NotificationProvider } from './context/NotificationContext';

// Providers nest like Russian dolls. Order matters when one Provider
// depends on another (e.g., NotificationProvider might use AuthContext).
const App = () => (
  <AuthProvider>          {/* Outermost: Auth needed by everything */}
    <ThemeProvider>       {/* Theme needed by UI */}
      <NotificationProvider>  {/* Notifications need Auth */}
        <Router>
          <AppRoutes />
        </Router>
      </NotificationProvider>
    </ThemeProvider>
  </AuthProvider>
);
```

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// FILE: components/Header.tsx — Consuming Context
// Note: This component doesn't receive theme as a prop.
// It reads it directly from context via the custom hook.
// ─────────────────────────────────────────────────────────────────────────────

import { useTheme } from '../context/ThemeContext';

const Header = () => {
  // Single line to access all theme values and methods
  const { theme, isDark, toggleTheme } = useTheme();

  return (
    <header className="header">
      <nav>...</nav>
      <button
        onClick={toggleTheme}
        aria-label={`Switch to ${isDark ? 'light' : 'dark'} mode`}
      >
        {isDark ? '☀️ Light' : '🌙 Dark'}
      </button>
      <span>Current: {theme}</span>
    </header>
  );
};

// DeepNested can use theme without Header or anything in between knowing about it
const DeepNested = () => {
  const { isDark } = useTheme(); // Works anywhere inside <ThemeProvider>
  return <div style={{ background: isDark ? '#333' : '#fff' }}>Deep component</div>;
};
```

---

#### 2.3 Context + useReducer = Mini Redux

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// FILE: context/GlobalStateContext.tsx
//
// Combining Context + useReducer gives you a lightweight global state solution
// that looks and feels like a mini Redux — without any library.
// Use this for small-medium apps before reaching for Redux or Zustand.
// ─────────────────────────────────────────────────────────────────────────────

import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// ── Global State Shape ────────────────────────────────────────────────────
interface GlobalState {
  user: { id: string; name: string; role: string } | null;
  notifications: Array<{ id: string; message: string; type: 'info' | 'error' | 'success' }>;
  sidebarOpen: boolean;
  isLoading: boolean;
}

// ── All possible global actions ───────────────────────────────────────────
type GlobalAction =
  | { type: 'SET_USER'; payload: GlobalState['user'] }
  | { type: 'LOGOUT' }
  | { type: 'ADD_NOTIFICATION'; payload: Omit<GlobalState['notifications'][0], 'id'> }
  | { type: 'DISMISS_NOTIFICATION'; payload: string }
  | { type: 'TOGGLE_SIDEBAR' }
  | { type: 'SET_LOADING'; payload: boolean };

// ── Reducer (pure function — easy to test in isolation) ───────────────────
function globalReducer(state: GlobalState, action: GlobalAction): GlobalState {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };

    case 'LOGOUT':
      return { ...state, user: null, sidebarOpen: false };

    case 'ADD_NOTIFICATION':
      return {
        ...state,
        notifications: [
          ...state.notifications,
          { ...action.payload, id: crypto.randomUUID() } // Generate ID here
        ]
      };

    case 'DISMISS_NOTIFICATION':
      return {
        ...state,
        notifications: state.notifications.filter(n => n.id !== action.payload)
      };

    case 'TOGGLE_SIDEBAR':
      return { ...state, sidebarOpen: !state.sidebarOpen };

    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };

    default:
      return state;
  }
}

// ── Separate state and dispatch into two contexts ─────────────────────────
// Why two contexts? Components that only dispatch actions (buttons, forms)
// don't need to re-render when state changes. Splitting prevents unnecessary
// re-renders in dispatch-only components.
const GlobalStateContext = createContext<GlobalState | undefined>(undefined);
const GlobalDispatchContext = createContext<React.Dispatch<GlobalAction> | undefined>(undefined);

const initialState: GlobalState = {
  user: null,
  notifications: [],
  sidebarOpen: false,
  isLoading: false
};

export const GlobalStateProvider = ({ children }: { children: ReactNode }) => {
  const [state, dispatch] = useReducer(globalReducer, initialState);

  return (
    // Two providers: state consumers re-render on state change,
    // dispatch consumers NEVER re-render (dispatch is always the same reference)
    <GlobalStateContext.Provider value={state}>
      <GlobalDispatchContext.Provider value={dispatch}>
        {children}
      </GlobalDispatchContext.Provider>
    </GlobalStateContext.Provider>
  );
};

// ── Custom hooks — one for state, one for dispatch ────────────────────────
export const useGlobalState = () => {
  const context = useContext(GlobalStateContext);
  if (!context) throw new Error('useGlobalState must be within GlobalStateProvider');
  return context;
};

export const useGlobalDispatch = () => {
  const context = useContext(GlobalDispatchContext);
  if (!context) throw new Error('useGlobalDispatch must be within GlobalStateProvider');
  return context;
};

// ── Action creator hooks (optional but recommended for complex apps) ───────
// Encapsulate dispatch logic behind meaningful function names
export const useGlobalActions = () => {
  const dispatch = useGlobalDispatch();

  return {
    setUser: (user: GlobalState['user']) =>
      dispatch({ type: 'SET_USER', payload: user }),

    logout: () =>
      dispatch({ type: 'LOGOUT' }),

    notify: (message: string, type: 'info' | 'error' | 'success' = 'info') =>
      dispatch({ type: 'ADD_NOTIFICATION', payload: { message, type } }),

    dismissNotification: (id: string) =>
      dispatch({ type: 'DISMISS_NOTIFICATION', payload: id }),

    toggleSidebar: () =>
      dispatch({ type: 'TOGGLE_SIDEBAR' }),
  };
};

// ── Usage in components ───────────────────────────────────────────────────
const UserProfile = () => {
  const { user } = useGlobalState();    // Re-renders when state changes
  const { logout } = useGlobalActions(); // Stable — won't cause re-renders

  if (!user) return <div>Not logged in</div>;
  return (
    <div>
      <p>Hello, {user.name} ({user.role})</p>
      <button onClick={logout}>Log out</button>
    </div>
  );
};

const SomeButton = () => {
  const { toggleSidebar } = useGlobalActions(); // Dispatch-only: never re-renders from state changes
  return <button onClick={toggleSidebar}>Menu</button>;
};
```

---

### Part 3: Custom Hooks — Patterns & Best Practices

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// Custom hooks = extract and reuse stateful logic between components.
//
// Rules:
//   1. Name must start with "use" (allows React linting to enforce hook rules)
//   2. Can call other hooks (useState, useEffect, useContext, etc.)
//   3. Each component that calls a hook gets its OWN isolated state
//      (hooks don't share state — they share LOGIC)
// ─────────────────────────────────────────────────────────────────────────────

// ── PATTERN 1: Data fetching hook ─────────────────────────────────────────
// Replaces repeated loading/error/data boilerplate in every component

interface FetchState<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

function useFetch<T>(url: string): FetchState<T> & { refetch: () => void } {
  const [state, setState] = useState<FetchState<T>>({
    data: null,
    loading: true,
    error: null
  });
  // useRef to trigger manual refetch without changing url
  const refetchRef = useRef(0);

  useEffect(() => {
    const controller = new AbortController();

    setState(prev => ({ ...prev, loading: true, error: null }));

    fetch(url, { signal: controller.signal })
      .then(r => { if (!r.ok) throw new Error(`HTTP ${r.status}`); return r.json(); })
      .then(data => setState({ data, loading: false, error: null }))
      .catch(err => {
        if (err.name !== 'AbortError') {
          setState(prev => ({ ...prev, loading: false, error: err }));
        }
      });

    return () => controller.abort();
  }, [url, refetchRef.current]); // Re-run when url changes OR refetch is triggered

  const refetch = useCallback(() => { refetchRef.current += 1; }, []);

  return { ...state, refetch };
}

// Usage — clean component, zero boilerplate
const UserProfile = ({ userId }: { userId: string }) => {
  const { data: user, loading, error, refetch } = useFetch<User>(`/api/users/${userId}`);

  if (loading) return <Spinner />;
  if (error) return <Error message={error.message} onRetry={refetch} />;
  return <div>{user?.name}</div>;
};

// ── PATTERN 2: Form hook ──────────────────────────────────────────────────
function useForm<T extends Record<string, unknown>>(initialValues: T) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});

  // Generic field change handler — works for any field
  const handleChange = useCallback((field: keyof T, value: unknown) => {
    setValues(prev => ({ ...prev, [field]: value }));
    // Clear error when user starts typing
    setErrors(prev => ({ ...prev, [field]: undefined }));
  }, []);

  const handleBlur = useCallback((field: keyof T) => {
    setTouched(prev => ({ ...prev, [field]: true }));
  }, []);

  const reset = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
  }, [initialValues]);

  // Computed: form is valid when no errors exist
  const isValid = Object.keys(errors).length === 0;

  return { values, errors, touched, isValid, handleChange, handleBlur, reset, setErrors };
}

// Usage
const LoginForm = () => {
  const { values, errors, touched, handleChange, handleBlur, setErrors } = useForm({
    email: '',
    password: ''
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const newErrors: typeof errors = {};
    if (!values.email.includes('@')) newErrors.email = 'Invalid email';
    if (values.password.length < 8) newErrors.password = 'Min 8 characters';
    if (Object.keys(newErrors).length > 0) { setErrors(newErrors); return; }
    await login(values);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={values.email}
        onChange={e => handleChange('email', e.target.value)}
        onBlur={() => handleBlur('email')}
      />
      {touched.email && errors.email && <span>{errors.email}</span>}
      {/* ... password field ... */}
    </form>
  );
};

// ── PATTERN 3: Browser API hooks ──────────────────────────────────────────

// useLocalStorage: Persist state to localStorage automatically
function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  const [stored, setStored] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue; // Graceful fallback if JSON parse fails
    }
  });

  const setValue = useCallback((value: T) => {
    setStored(value);
    localStorage.setItem(key, JSON.stringify(value));
  }, [key]);

  return [stored, setValue];
}

// useMediaQuery: Respond to CSS breakpoints in JS
function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(
    () => window.matchMedia(query).matches // Lazy init from current state
  );

  useEffect(() => {
    const media = window.matchMedia(query);
    const handler = (e: MediaQueryListEvent) => setMatches(e.matches);
    media.addEventListener('change', handler);
    return () => media.removeEventListener('change', handler); // Cleanup
  }, [query]);

  return matches;
}

// useDebounce: Delay state updates (search inputs, resize handlers)
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer); // Cancel timer if value changes before delay
  }, [value, delay]);

  return debounced;
}

// Compose hooks naturally
const SmartSearch = () => {
  const isMobile = useMediaQuery('(max-width: 768px)');
  const [query, setQuery] = useLocalStorage('lastSearch', '');
  const debouncedQuery = useDebounce(query, isMobile ? 500 : 300); // Slower debounce on mobile

  useEffect(() => {
    if (debouncedQuery) {
      searchApi(debouncedQuery); // Only fires after user stops typing
    }
  }, [debouncedQuery]);

  return <input value={query} onChange={e => setQuery(e.target.value)} />;
};
```

**Angular equivalent of custom hooks — Services:**
```typescript
// Angular: Logic reuse = Services. Unlike hooks, services are singletons
// by default (shared state across ALL consumers unless scoped to a component).

@Injectable({ providedIn: 'root' }) // Singleton: shared across entire app
export class UserDataService {
  // BehaviorSubject<User | null> — holds current user state, replays it to every new subscriber
  // WHY: Any component that subscribes to user$ immediately gets the current user value —
  //      no need to wait for a new emission. null = user not yet loaded or not logged in.
  private userSubject = new BehaviorSubject<User | null>(null);
  user$ = this.userSubject.asObservable();

  constructor(private http: HttpClient) {}

  loadUser(id: string): Observable<User> {
    return this.http.get<User>(`/api/users/${id}`).pipe(
      // tap() — push the fetched user into the shared BehaviorSubject as a side effect
      // WHY: Any component subscribed to user$ across the app gets the update immediately.
      //      tap() doesn't change what flows downstream — the user object still reaches .subscribe()
      tap(user => this.userSubject.next(user)),

      // catchError() + EMPTY — swallow the error gracefully, complete without emitting
      // WHY: EMPTY is an Observable that completes immediately with no values.
      //      Returning EMPTY means the error doesn't propagate to subscribers — the stream
      //      just ends silently. Use when a failed load should be a no-op (not a crash).
      //      Alternative: return of(null) if you need to signal "no user loaded"
      catchError(err => { console.error(err); return EMPTY; })
    );
  }
}

// Key difference from hooks:
// Hook: Each component gets its OWN isolated state copy
// Service: All components share the SAME service instance and state
```

---

### Part 4: Context API Performance Pitfalls & Solutions

```tsx
// ─────────────────────────────────────────────────────────────────────────────
// PITFALL: Every consumer re-renders when context value changes,
// even if the specific value they use didn't change.
// ─────────────────────────────────────────────────────────────────────────────

// ❌ BAD: Creating context value object inline causes all consumers to re-render
// on every Provider render (new object reference = React thinks value changed)
const BadProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState('light');

  // This object is RECREATED on every render, triggering all consumers
  return (
    <AppContext.Provider value={{ user, theme, setUser, setTheme }}>
      {children}
    </AppContext.Provider>
  );
};

// ✅ GOOD SOLUTION 1: useMemo to stabilize the context value object
const GoodProvider1 = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState('light');

  // Only creates a new object when user or theme actually changes
  const value = useMemo(
    () => ({ user, theme, setUser, setTheme }),
    [user, theme] // setUser and setTheme from useState are always stable references
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
};

// ✅ GOOD SOLUTION 2: Split contexts by update frequency
// Components that only need user don't re-render when theme changes
const UserContext = createContext<User | null>(null);
const ThemeContext = createContext<string>('light');

const SplitProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [theme, setTheme] = useState('light');

  return (
    <UserContext.Provider value={user}>
      <ThemeContext.Provider value={theme}>
        {children}
      </ThemeContext.Provider>
    </UserContext.Provider>
  );
};

// ✅ GOOD SOLUTION 3: Separate state and dispatch (as shown in Context+useReducer above)
// Dispatch consumers (buttons) never re-render when state changes
```

---

### Summary: When to Use What

| Scenario | React Tool | Angular Tool |
|----------|-----------|-------------|
| Simple toggle / counter | `useState` | Component property / Signal |
| API call on mount | `useEffect([], [])` | `ngOnInit` + HttpClient |
| React to prop change | `useEffect([prop])` | `ngOnChanges` |
| Expensive computation | `useMemo` | Pure Pipe / Getter |
| Prevent child re-render | `React.memo` + `useCallback` | `OnPush` CD |
| DOM reference | `useRef` | `@ViewChild` |
| Complex state transitions | `useReducer` | Service + BehaviorSubject / NgRx |
| Share state without props | **Context API** | **Services + DI** |
| Reuse stateful logic | **Custom Hooks** | **Services** |
| Global app state | Context + useReducer / Zustand / Redux | NgRx / Signals |

> **Key Insight**: React's hooks + Context give you maximum flexibility with minimal abstractions. Angular's services + DI give you structure and testability by convention. Neither is objectively better — they reflect different design philosophies: React is a library, Angular is a framework.

---

## 5. JWT Authentication

### React Implementation
```typescript
// context/AuthContext.tsx
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { jwtDecode } from 'jwt-decode';

interface AuthContextType {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<string>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Initialize from localStorage on mount
  useEffect(() => {
    const storedToken = localStorage.getItem('token');
    if (storedToken && !isTokenExpired(storedToken)) {
      setToken(storedToken);
      setUser(jwtDecode<User>(storedToken));
    }
    setLoading(false);
  }, []);

  // Auto-refresh token before expiry
  useEffect(() => {
    if (!token) return;

    const decoded = jwtDecode<{ exp: number }>(token);
    const expiresIn = decoded.exp * 1000 - Date.now();
    const refreshTime = expiresIn - 60000; // Refresh 1 min before expiry

    if (refreshTime > 0) {
      const timeout = setTimeout(() => {
        refreshToken();
      }, refreshTime);
      return () => clearTimeout(timeout);
    }
  }, [token]);

  const login = useCallback(async (credentials: LoginCredentials) => {
    const response = await authApi.login(credentials);
    localStorage.setItem('token', response.token);
    localStorage.setItem('refreshToken', response.refreshToken);
    setToken(response.token);
    setUser(response.user);
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    setToken(null);
    setUser(null);
  }, []);

  const refreshToken = useCallback(async () => {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) throw new Error('No refresh token');

    const response = await authApi.refresh(refreshToken);
    localStorage.setItem('token', response.token);
    setToken(response.token);
    return response.token;
  }, []);

  return (
    <AuthContext.Provider value={{
      user,
      token,
      isAuthenticated: !!token,
      loading,
      login,
      logout,
      refreshToken,
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};

// Axios interceptor setup
axios.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

### Angular Implementation
```typescript
// core/services/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable, of, throwError } from 'rxjs';
import { tap, map, catchError, switchMap } from 'rxjs/operators';
import { jwtDecode } from 'jwt-decode';
import { Router } from '@angular/router';

interface TokenPayload {
  sub: string;
  email: string;
  roles: string[];
  exp: number;
  iat: number;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private tokenSubject = new BehaviorSubject<string | null>(null);
  private userSubject = new BehaviorSubject<User | null>(null);
  private refreshTokenTimeout?: ReturnType<typeof setTimeout>;

  token$ = this.tokenSubject.asObservable();
  user$ = this.userSubject.asObservable();
  // map() — derive a boolean "is logged in" stream from the token stream
  // WHY: Components and guards need boolean, not raw token. Using map() keeps
  //      isAuthenticated$ reactive — it updates automatically whenever token$ changes.
  isAuthenticated$ = this.token$.pipe(map(token => !!token));

  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    this.loadStoredToken();
  }

  private loadStoredToken(): void {
    const token = localStorage.getItem('token');
    if (token && !this.isTokenExpired(token)) {
      this.setToken(token);
    }
  }

  login(credentials: LoginCredentials): Observable<AuthResponse> {
    return this.http.post<AuthResponse>('/api/auth/login', credentials).pipe(
      // tap() — persist tokens and update state as a side effect, without altering the stream
      // WHY: tap() is the correct tool here because the caller (component) still needs to receive
      //      the AuthResponse to navigate or show success UI. Using map() would require returning
      //      the value explicitly; tap() handles side effects transparently.
      tap(response => {
        localStorage.setItem('token', response.token);
        localStorage.setItem('refreshToken', response.refreshToken);
        this.setToken(response.token);
        this.startRefreshTokenTimer();
      })
    );
  }

  logout(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    this.tokenSubject.next(null);
    this.userSubject.next(null);
    this.stopRefreshTokenTimer();
    this.router.navigate(['/login']);
  }

  refreshToken(): Observable<string> {
    const refreshToken = localStorage.getItem('refreshToken');
    if (!refreshToken) {
      return throwError(() => new Error('No refresh token'));
    }

    return this.http.post<{ token: string }>('/api/auth/refresh', { refreshToken }).pipe(
      // map() — extract the token string from the HTTP response body
      // WHY: Callers (JwtInterceptor) need a plain string token, not the full response object.
      //      map() projects the response into just the token so the caller doesn't know about
      //      the HTTP response shape.
      map(response => {
        localStorage.setItem('token', response.token);
        this.setToken(response.token);
        this.startRefreshTokenTimer();
        return response.token;
      }),
      // catchError() — if refresh fails, force logout and re-throw the error
      // WHY: A failed refresh means the refresh token is expired or revoked — the user
      //      must log in again. Calling logout() clears state; throwError() propagates
      //      the error to the JwtInterceptor so it can handle the failed retry.
      catchError(error => {
        this.logout();
        return throwError(() => error);
      })
    );
  }

  getToken(): string | null {
    return this.tokenSubject.value;
  }

  hasRole(role: string): Observable<boolean> {
    return this.user$.pipe(
      // map() — project the User object to a boolean role-membership check
      // WHY: Guards and templates need a boolean, not the full User object.
      //      map() keeps the stream reactive — any time user$ updates (login/logout),
      //      hasRole() automatically emits the new role status.
      map(user => user?.roles?.includes(role) ?? false)
    );
  }

  private setToken(token: string): void {
    this.tokenSubject.next(token);
    const decoded = jwtDecode<TokenPayload>(token);
    this.userSubject.next({
      id: decoded.sub,
      email: decoded.email,
      roles: decoded.roles,
    });
  }

  private isTokenExpired(token: string): boolean {
    const decoded = jwtDecode<TokenPayload>(token);
    return decoded.exp * 1000 < Date.now();
  }

  private startRefreshTokenTimer(): void {
    const token = this.getToken();
    if (!token) return;

    const decoded = jwtDecode<TokenPayload>(token);
    const expires = new Date(decoded.exp * 1000);
    const timeout = expires.getTime() - Date.now() - 60000; // 1 min before expiry

    this.stopRefreshTokenTimer();
    this.refreshTokenTimeout = setTimeout(() => {
      this.refreshToken().subscribe();
    }, timeout);
  }

  private stopRefreshTokenTimer(): void {
    if (this.refreshTokenTimeout) {
      clearTimeout(this.refreshTokenTimeout);
    }
  }
}
```

---

## 6. Performance Optimization

### React Performance
```tsx
// 1. React.memo - Prevent unnecessary re-renders
const ExpensiveList = React.memo<{ items: Item[] }>(({ items }) => {
  return (
    <ul>
      {items.map(item => <li key={item.id}>{item.name}</li>)}
    </ul>
  );
}, (prevProps, nextProps) => {
  // Custom comparison (optional)
  return prevProps.items.length === nextProps.items.length;
});

// 2. useMemo - Memoize expensive computations
const Dashboard = ({ data }: { data: DataPoint[] }) => {
  const processedData = useMemo(() => {
    return data
      .filter(d => d.active)
      .map(d => ({ ...d, calculated: heavyCalculation(d) }))
      .sort((a, b) => b.calculated - a.calculated);
  }, [data]);

  return <Chart data={processedData} />;
};

// 3. useCallback - Memoize callbacks
const ParentComponent = () => {
  const [count, setCount] = useState(0);

  // Without useCallback, this creates new function every render
  const handleClick = useCallback((id: string) => {
    console.log('Clicked:', id);
  }, []); // Empty deps = never changes

  return <ChildComponent onClick={handleClick} />;
};

// 4. Code Splitting with React.lazy
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

const App = () => (
  <Suspense fallback={<Loading />}>
    <HeavyComponent />
  </Suspense>
);

// 5. Virtualization for long lists
import { FixedSizeList } from 'react-window';

const VirtualList = ({ items }: { items: Item[] }) => (
  <FixedSizeList
    height={400}
    itemCount={items.length}
    itemSize={50}
    width="100%"
  >
    {({ index, style }) => (
      <div style={style}>{items[index].name}</div>
    )}
  </FixedSizeList>
);

// 6. Debouncing expensive operations
const SearchInput = () => {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);

  useEffect(() => {
    if (debouncedQuery) {
      searchApi(debouncedQuery);
    }
  }, [debouncedQuery]);

  return <input value={query} onChange={e => setQuery(e.target.value)} />;
};
```

### Angular Performance
```typescript
// 1. OnPush Change Detection - Like React.memo
@Component({
  selector: 'app-expensive-list',
  template: `
    <ul>
      <li *ngFor="let item of items; trackBy: trackById">{{ item.name }}</li>
    </ul>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush  // KEY!
})
export class ExpensiveListComponent {
  @Input() items: Item[] = [];

  // trackBy prevents re-rendering unchanged items
  trackById(index: number, item: Item): string {
    return item.id;
  }
}

// 2. Pure Pipes - Like useMemo (cached by Angular)
@Pipe({ name: 'heavyCalc', pure: true })  // pure: true is default
export class HeavyCalcPipe implements PipeTransform {
  transform(data: DataPoint[]): ProcessedData[] {
    // This only runs when 'data' reference changes
    return data
      .filter(d => d.active)
      .map(d => ({ ...d, calculated: heavyCalculation(d) }))
      .sort((a, b) => b.calculated - a.calculated);
  }
}

// Usage in template
// <app-chart [data]="data | heavyCalc"></app-chart>

// 3. Lazy Loading Modules
const routes: Routes = [
  {
    path: 'dashboard',
    loadChildren: () => import('./features/dashboard/dashboard.module')
      .then(m => m.DashboardModule)
  },
  {
    path: 'admin',
    loadChildren: () => import('./features/admin/admin.module')
      .then(m => m.AdminModule),
    canLoad: [AuthGuard]  // Don't even load if not authorized!
  }
];

// 4. Virtual Scrolling (CDK)
import { ScrollingModule } from '@angular/cdk/scrolling';

@Component({
  template: `
    <cdk-virtual-scroll-viewport itemSize="50" class="viewport">
      <div *cdkVirtualFor="let item of items; trackBy: trackById">
        {{ item.name }}
      </div>
    </cdk-virtual-scroll-viewport>
  `,
  styles: [`.viewport { height: 400px; }`]
})
export class VirtualListComponent {
  @Input() items: Item[] = [];
  trackById = (index: number, item: Item) => item.id;
}

// 5. Async Pipe - Automatic subscription management
@Component({
  template: `
    <!-- Async pipe subscribes, unsubscribes, and triggers change detection -->
    <div *ngIf="user$ | async as user">
      Welcome, {{ user.name }}
    </div>

    <!-- Multiple subscriptions? Use ngIf with object -->
    <ng-container *ngIf="{
      user: user$ | async,
      settings: settings$ | async
    } as data">
      <app-header [user]="data.user" [settings]="data.settings"></app-header>
    </ng-container>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class HeaderComponent {
  user$ = this.store.select(selectUser);
  settings$ = this.store.select(selectSettings);

  constructor(private store: Store) {}
}

// 6. Debouncing with RxJS
@Component({
  template: `<input [formControl]="searchControl">`
})
export class SearchComponent implements OnInit {
  searchControl = new FormControl('');

  ngOnInit() {
    this.searchControl.valueChanges.pipe(
      // debounceTime(300) — suppress rapid-fire emissions, only emit after 300ms of silence
      // WHY: FormControl.valueChanges fires on EVERY keystroke. Without debounce,
      //      typing "angular" sends 7 HTTP requests. With 300ms debounce, only 1 fires.
      debounceTime(300),

      // distinctUntilChanged() — skip if value is identical to the previous emission
      // WHY: If the user types "a", deletes it, types "a" again — the value is "a" both times.
      //      Without distinctUntilChanged, a redundant HTTP call fires. This blocks it.
      distinctUntilChanged(),

      // switchMap() — cancel previous search HTTP call when new query arrives
      // WHY: User types "ang" (HTTP fires), then "angu" (previous HTTP CANCELLED, new one fires).
      //      Prevents stale earlier results from overwriting fresher later results.
      switchMap(query => this.searchService.search(query))
    ).subscribe(results => {
      // Handle results
    });
  }
}

// 7. Preloading Strategies
@NgModule({
  imports: [
    RouterModule.forRoot(routes, {
      preloadingStrategy: PreloadAllModules  // Load lazy modules in background
    })
  ]
})
export class AppRoutingModule {}

// Custom preloading strategy
@Injectable({ providedIn: 'root' })
export class SelectivePreloadStrategy implements PreloadAllModules {
  preload(route: Route, load: () => Observable<any>): Observable<any> {
    // of(null) — creates an observable that emits null immediately then completes (no-op preload)
    // WHY: The preload method MUST return an Observable. of(null) is the conventional
    //      "don't preload this route" return value — it completes immediately with no side effects.
    return route.data?.['preload'] ? load() : of(null);
  }
}
```

---

## 7. Routing

### React Router
```tsx
// App.tsx
import { BrowserRouter, Routes, Route, Navigate, Outlet } from 'react-router-dom';

// Protected Route wrapper
const ProtectedRoute = () => {
  const { isAuthenticated, loading } = useAuth();
  const location = useLocation();

  if (loading) return <Loading />;
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  return <Outlet />;
};

// Role-based Route
const RoleRoute = ({ roles }: { roles: string[] }) => {
  const { user } = useAuth();

  if (!user || !roles.some(role => user.roles.includes(role))) {
    return <Navigate to="/forbidden" replace />;
  }
  return <Outlet />;
};

const App = () => (
  <BrowserRouter>
    <Routes>
      {/* Public routes */}
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />

      {/* Protected routes */}
      <Route element={<ProtectedRoute />}>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="profile" element={<Profile />} />

          {/* Nested protected + role-based */}
          <Route element={<RoleRoute roles={['admin']} />}>
            <Route path="admin" element={<AdminLayout />}>
              <Route index element={<AdminDashboard />} />
              <Route path="users" element={<UserManagement />} />
            </Route>
          </Route>
        </Route>
      </Route>

      {/* Lazy loaded route */}
      <Route
        path="/reports/*"
        element={
          <Suspense fallback={<Loading />}>
            <LazyReports />
          </Suspense>
        }
      />

      {/* Catch-all */}
      <Route path="*" element={<NotFound />} />
    </Routes>
  </BrowserRouter>
);

// Programmatic navigation
const LoginForm = () => {
  const navigate = useNavigate();
  const location = useLocation();

  const handleLogin = async () => {
    await login(credentials);
    // Navigate to where they came from, or dashboard
    const from = location.state?.from?.pathname || '/';
    navigate(from, { replace: true });
  };
};

// Route params
const UserDetail = () => {
  const { userId } = useParams<{ userId: string }>();
  const [searchParams, setSearchParams] = useSearchParams();
  const tab = searchParams.get('tab') || 'overview';

  return (
    <div>
      <h1>User: {userId}</h1>
      <button onClick={() => setSearchParams({ tab: 'settings' })}>
        Settings
      </button>
    </div>
  );
};
```

### Angular Router
```typescript
// app-routing.module.ts
const routes: Routes = [
  // Public routes
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },

  // Protected routes with layout
  {
    path: '',
    component: LayoutComponent,
    canActivate: [AuthGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: DashboardComponent },
      { path: 'profile', component: ProfileComponent },

      // Nested with role guard
      {
        path: 'admin',
        component: AdminLayoutComponent,
        canActivate: [RoleGuard],
        data: { roles: ['admin'] },
        children: [
          { path: '', component: AdminDashboardComponent },
          { path: 'users', component: UserManagementComponent },
        ]
      }
    ]
  },

  // Lazy loaded feature module
  {
    path: 'reports',
    loadChildren: () => import('./features/reports/reports.module')
      .then(m => m.ReportsModule),
    canLoad: [AuthGuard]
  },

  // Route with resolver (pre-fetch data)
  {
    path: 'user/:userId',
    component: UserDetailComponent,
    resolve: { user: UserResolver }
  },

  // Catch-all
  { path: '**', component: NotFoundComponent }
];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// snapshot  vs  Observable (paramMap / queryParamMap) — THE KEY DIFFERENCE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// ActivatedRoute exposes BOTH a snapshot (frozen value) and reactive Observables
// for path params and query params. Choosing the wrong one causes subtle bugs.
//
//  route.snapshot.paramMap.get('id')       ← reads value ONCE at the moment of construction
//  route.paramMap.subscribe(...)           ← reactive stream, re-emits whenever URL changes
//
// ┌────────────────────┬──────────────────────────────┬────────────────────────────────────┐
// │ Aspect             │ snapshot                     │ Observable (paramMap)               │
// ├────────────────────┼──────────────────────────────┼────────────────────────────────────┤
// │ Value timing       │ Frozen at component creation │ Live — emits on every URL change   │
// │ Re-emits?          │ No — single read only        │ Yes — on every navigation           │
// │ Component reused?  │ Misses subsequent changes    │ Always receives latest value        │
// │ Use when           │ Component always re-created  │ Component is REUSED across navs    │
// │ Memory leak risk   │ No (no subscription)         │ Yes — must unsubscribe             │
// │ Example scenario   │ Fresh page load, guards      │ Tab changes, pagination, filters   │
// └────────────────────┴──────────────────────────────┴────────────────────────────────────┘
//
// WHEN DOES ANGULAR REUSE A COMPONENT?
//   By default Angular DESTROYS and RE-CREATES the component on each navigation.
//   snapshot is safe in that case — ngOnInit runs fresh each time.
//
//   BUT: if you navigate from /users/1 → /users/2 and Angular decides to REUSE
//   the component (same route, different param), ngOnInit does NOT re-run.
//   snapshot still holds '1'. Only the Observable detects '2'.
//
//   Route reuse happens:
//     • Same route, different params  (e.g. pagination: /products?page=1 → ?page=2)
//     • Parent route with child outlets
//     • Custom RouteReuseStrategy
//
// SAME RULES APPLY TO QUERY PARAMS:
//   route.snapshot.queryParamMap.get('tab')   ← one-time read
//   route.queryParamMap.subscribe(...)         ← reactive — updates as ?tab= changes

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Resolver - Pre-fetch data BEFORE navigation completes
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WHY Resolver: without it, the component renders with an empty user, shows a
//   loading spinner, then re-renders when data arrives (flash of empty content).
//   With a Resolver, Angular waits for the HTTP call to complete BEFORE activating
//   the route — component always receives fully loaded data in route.data.
//
// resolve() receives ActivatedRouteSnapshot (not ActivatedRoute) because:
//   - Resolvers run BEFORE the component is instantiated — no live route object yet
//   - A snapshot is sufficient: the resolver just needs the current URL params once
@Injectable({ providedIn: 'root' })
export class UserResolver implements Resolve<User> {
  constructor(private userService: UserService) {}

  // route: ActivatedRouteSnapshot — frozen snapshot of the route being resolved.
  // WHY snapshot here (not Observable): resolver runs once per navigation, reads
  //   the path param, fires the HTTP call, and completes. No need to react to changes.
  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    // paramMap.get() — reads a path segment variable defined as :userId in the route config
    // WHY paramMap over params: paramMap.get() returns string|null (type-safe);
    //   route.params['userId'] returns any (no null safety)
    // ! (non-null assertion) — safe here because the route wouldn't activate without :userId
    const userId = route.paramMap.get('userId')!;
    return this.userService.getUser(userId);
    // Router waits for this Observable to COMPLETE before rendering the component.
    // The resolved value is placed into route.data['user'] automatically.
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Component — snapshot vs Observable, query param updates
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@Component({
  template: `
    <h1>User: {{ user.name }}</h1>
    <nav>
      <!--
        [routerLink]="[]"  — empty array = STAY on the current route path
        WHY []: we only want to UPDATE the query params, not navigate to a new path.
              [] means "same URL, same path, just change the ?tab= part".

        [queryParams]="{ tab: 'overview' }" — sets ?tab=overview in the URL.
        WHY update URL: makes the tab state bookmarkable + browser-back-button works.
              The component reads ?tab= from queryParamMap and reacts automatically.
      -->
      <a [routerLink]="[]" [queryParams]="{ tab: 'overview' }"
         [class.active]="tab === 'overview'">Overview</a>
      <a [routerLink]="[]" [queryParams]="{ tab: 'settings' }"
         [class.active]="tab === 'settings'">Settings</a>
    </nav>
  `
})
export class UserDetailComponent implements OnInit {
  user!: User;
  tab = 'overview';

  // ActivatedRoute — the live route object for THIS component instance.
  // Exposes both .snapshot (frozen) and reactive Observables (.paramMap, .queryParamMap, .data).
  // Router — for programmatic navigation (navigating by code, not template links).
  constructor(private route: ActivatedRoute, private router: Router) {}

  ngOnInit() {
    // ── SNAPSHOT: read resolver data ONCE ──────────────────────────────────────
    // route.snapshot.data — frozen map of all resolved data at the time of activation.
    // WHY snapshot here: resolver data is loaded once before the component activates.
    //   If user navigated away and back, the component is DESTROYED and RE-CREATED,
    //   so snapshot is fresh each time. No need for a live subscription.
    // DANGER: if the component is REUSED (e.g. navigating /users/1 → /users/2
    //   without destroy), snapshot.data still holds the OLD user. Use .data Observable then.
    this.user = this.route.snapshot.data['user'];  // 'user' matches the resolve key in route config

    // ── OBSERVABLE: subscribe to resolver data for reused components ───────────
    // route.data — reactive stream that re-emits whenever the resolver runs again.
    // WHY subscribe here too: if this component is reused across navigations
    //   (same route, different path param), snapshot won't update but .data will.
    // NOTE: adds a subscription — should be paired with takeUntil(destroy$) in production.
    this.route.data.subscribe(data => {
      this.user = data['user'];  // always the freshest resolved value
    });

    // ── OBSERVABLE: query params — reactive tab state ──────────────────────────
    // route.queryParamMap — Observable<ParamMap> that re-emits whenever ?anything= changes.
    // WHY Observable (not snapshot): the user clicks tab links which ONLY change query params
    //   without destroying/recreating this component. snapshot.queryParamMap would be frozen
    //   at '?tab=overview' forever — tab clicks would not reflect in this.tab.
    //
    // ParamMap vs plain object:
    //   params.get('tab')        → string | null  (type-safe, null if param absent)
    //   route.queryParams['tab'] → any             (no null safety, use only if needed)
    this.route.queryParamMap.subscribe(params => {
      // || 'overview' — fallback when ?tab= is absent (direct URL load, no query string)
      this.tab = params.get('tab') || 'overview';
    });
  }

  // ── PROGRAMMATIC NAVIGATION — updating query params by code ────────────────
  navigateToSettings() {
    this.router.navigate(
      ['/user', this.user.id],  // path: /user/abc-123
      {
        // queryParams — sets the query string on the new URL
        // This produces: /user/abc-123?tab=settings
        queryParams: { tab: 'settings' },

        // queryParamsHandling — controls what happens to EXISTING query params
        // ┌────────────┬──────────────────────────────────────────────────────────┐
        // │ Value      │ Behaviour                                                │
        // ├────────────┼──────────────────────────────────────────────────────────┤
        // │ ''         │ Default: replace ALL existing params with the new ones   │
        // │            │ /user/1?sort=asc&page=2  + { tab:'settings' }            │
        // │            │ → /user/1?tab=settings  (sort and page are LOST)         │
        // ├────────────┼──────────────────────────────────────────────────────────┤
        // │ 'merge'    │ Merge: keeps all existing params, adds/overwrites new    │
        // │            │ /user/1?sort=asc&page=2  + { tab:'settings' }            │
        // │            │ → /user/1?sort=asc&page=2&tab=settings  (sort/page kept) │
        // ├────────────┼──────────────────────────────────────────────────────────┤
        // │ 'preserve' │ Ignore the new queryParams entirely, keep existing as-is │
        // │            │ /user/1?sort=asc  + { tab:'settings' }                   │
        // │            │ → /user/1?sort=asc  (tab is NOT added)                   │
        // └────────────┴──────────────────────────────────────────────────────────┘
        // WHY 'merge' here: navigating to settings tab should not wipe out any
        //   other filters/pagination that might be in the URL at the same time.
        queryParamsHandling: 'merge'
      }
    );
    // After navigate() resolves, route.queryParamMap emits {tab:'settings'}
    // → this.tab updates to 'settings' via the subscription in ngOnInit above.
  }
}

// CanDeactivate Guard - Prevent leaving with unsaved changes
@Injectable({ providedIn: 'root' })
export class UnsavedChangesGuard implements CanDeactivate<ComponentWithUnsavedChanges> {
  canDeactivate(component: ComponentWithUnsavedChanges): Observable<boolean> | boolean {
    if (component.hasUnsavedChanges()) {
      return confirm('You have unsaved changes. Leave anyway?');
    }
    return true;
  }
}
```

---

## 8. Forms

### How to Build a Form: React vs Angular

#### React Approach (Step-by-Step)

**Step 1**: Install dependencies
```bash
npm install react-hook-form zod @hookform/resolvers
```

**Step 2**: Define validation schema using Zod
```typescript
// This defines the shape and validation rules for your form
const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});
```

**Step 3**: Create form component with useForm hook
```typescript
const { register, handleSubmit, formState } = useForm({
  resolver: zodResolver(userSchema)
});
```

**Step 4**: Render form with form fields
```typescript
<input {...register('email')} />
<button type="submit">Submit</button>
```

#### Angular Approach A — Reactive Forms (Step-by-Step)

> Best for: complex forms, dynamic controls, unit testing, cross-field validation

**Step 1**: Import ReactiveFormsModule in your module
```typescript
import { ReactiveFormsModule } from '@angular/forms';

@NgModule({
  imports: [ReactiveFormsModule]
})
export class MyModule {}
```

**Step 2**: Create FormBuilder in component
```typescript
constructor(private fb: FormBuilder) {}
```

**Step 3**: Build form structure with FormBuilder — all validation lives in TypeScript
```typescript
this.userForm = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  password: ['', Validators.minLength(8)]
});
```

**Step 4**: Bind form to template using directives
```html
<form [formGroup]="userForm" (ngSubmit)="onSubmit()">
  <input formControlName="email">
  <span *ngIf="userForm.get('email')?.errors?.['required']">Required</span>
  <button type="submit" [disabled]="userForm.invalid">Submit</button>
</form>
```

---

#### Angular Approach B — Template-Driven Forms (Step-by-Step)

> Best for: simple forms (login, search, settings), quick prototyping, beginners transitioning from AngularJS

**Step 1**: Import `FormsModule` (not ReactiveFormsModule) in your module
```typescript
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [FormsModule]   // ← FormsModule, NOT ReactiveFormsModule
})
export class MyModule {}
```

**Step 2**: No TypeScript class setup — bind directly in the HTML with `ngModel`
```typescript
// Component class is simple — just data properties
export class LoginComponent {
  email = '';
  password = '';
}
```

**Step 3**: Use `[(ngModel)]` for two-way binding. Add `name` attribute (required).
Validation rules go on the HTML element as attributes.
```html
<input [(ngModel)]="email" name="email" required email #emailRef="ngModel">
```

**Step 4**: Access form and field state via template reference variables
```html
<form #f="ngForm" (ngSubmit)="onSubmit(f)">
  <input [(ngModel)]="email" name="email" required email #emailRef="ngModel">
  <span *ngIf="emailRef.invalid && emailRef.touched">Invalid email</span>
  <button type="submit" [disabled]="f.invalid">Submit</button>
</form>
```

**Key difference from Reactive Forms:**

| | Template-Driven | Reactive |
|--|-----------------|---------|
| Validation location | HTML attributes (`required email minlength`) | TypeScript (`Validators.required, Validators.email`) |
| Form control access | `#ref="ngModel"` in template | `form.get('field')` in TypeScript |
| Form object | Angular creates it implicitly | You build it explicitly with `FormBuilder` |
| Boilerplate | Minimal | More, but more control |
| Unit testable | Harder (DOM needed) | Easy (pure TypeScript) |

### React Forms (with React Hook Form)
```tsx
// Using react-hook-form + zod for validation
// react-hook-form: minimal re-renders, highly performant
// zod: runtime type checking with great error messages
import { useForm, Controller, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// STEP 1: Define your validation schema with Zod
// This ensures all data matches expected types and validates constraints
const userSchema = z.object({
  email: z.string().email('Invalid email'),  // ← Email format validation
  password: z.string().min(8, 'Min 8 characters'),  // ← Length validation
  confirmPassword: z.string(),  // ← Will compare with password below
  profile: z.object({  // ← Nested object
    firstName: z.string().min(1, 'Required'),
    lastName: z.string().min(1, 'Required'),
    age: z.number().min(18, 'Must be 18+'),
  }),
  addresses: z.array(z.object({  // ← Dynamic array of objects
    street: z.string().min(1),
    city: z.string().min(1),
  })).min(1, 'At least one address'),
}).refine(data => data.password === data.confirmPassword, {  // ← Cross-field validation
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

type UserFormData = z.infer<typeof userSchema>;  // ← Auto-typed from schema

const UserForm = () => {
  // STEP 2: Initialize form with useForm hook
  // resolver validates data against schema
  // Mode: when to validate (onChange, onBlur, onSubmit)
  const {
    register,              // ← Function to register inputs
    handleSubmit,          // ← Wrapper for form submission
    control,               // ← Control for complex fields
    watch,                 // ← Watch field values
    formState: { errors, isSubmitting, isDirty }  // ← Form state
  } = useForm<UserFormData>({
    resolver: zodResolver(userSchema),  // ← Validate against schema
    mode: 'onChange',  // ← Validate on each change
    defaultValues: {   // ← Initial values
      addresses: [{ street: '', city: '' }]
    }
  });

  // STEP 3: Use useFieldArray for dynamic form sections
  // This handles adding/removing field groups
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'addresses'  // ← Name of the field array in schema
  });

  // STEP 4: Watch specific field value
  // Useful for conditional rendering or dependent fields
  const password = watch('password');

  // STEP 5: Handle form submission
  const onSubmit = async (data: UserFormData) => {
    // data is guaranteed to match userSchema type
    await api.createUser(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input {...register('email')} placeholder="Email" />
        {errors.email && <span>{errors.email.message}</span>}
      </div>

      <div>
        <input {...register('password')} type="password" />
        {errors.password && <span>{errors.password.message}</span>}
      </div>

      <div>
        <input {...register('confirmPassword')} type="password" />
        {errors.confirmPassword && <span>{errors.confirmPassword.message}</span>}
      </div>

      {/* Nested object */}
      <fieldset>
        <legend>Profile</legend>
        <input {...register('profile.firstName')} placeholder="First Name" />
        <input {...register('profile.lastName')} placeholder="Last Name" />
        <Controller
          name="profile.age"
          control={control}
          render={({ field }) => (
            <input
              type="number"
              {...field}
              onChange={e => field.onChange(parseInt(e.target.value))}
            />
          )}
        />
      </fieldset>

      {/* Dynamic array */}
      <fieldset>
        <legend>Addresses</legend>
        {fields.map((field, index) => (
          <div key={field.id}>
            <input {...register(`addresses.${index}.street`)} placeholder="Street" />
            <input {...register(`addresses.${index}.city`)} placeholder="City" />
            <button type="button" onClick={() => remove(index)}>Remove</button>
          </div>
        ))}
        <button type="button" onClick={() => append({ street: '', city: '' })}>
          Add Address
        </button>
      </fieldset>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Saving...' : 'Submit'}
      </button>
    </form>
  );
};
```

### Angular Forms (Reactive Forms)
```typescript
// Angular Reactive Forms with custom validators
import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, Validators, AbstractControl, ValidationErrors } from '@angular/forms';
import { Observable } from 'rxjs';
import { map, debounceTime, distinctUntilChanged, first } from 'rxjs/operators';

@Component({
  selector: 'app-user-form',
  template: `
    <form [formGroup]="userForm" (ngSubmit)="onSubmit()">
      <div>
        <input formControlName="email" placeholder="Email">
        <span *ngIf="userForm.get('email')?.errors?.['required']">Required</span>
        <span *ngIf="userForm.get('email')?.errors?.['email']">Invalid email</span>
        <span *ngIf="userForm.get('email')?.errors?.['emailTaken']">Email already taken</span>
      </div>

      <div>
        <input formControlName="password" type="password" placeholder="Password">
        <span *ngIf="userForm.get('password')?.errors?.['minlength']">
          Min {{ userForm.get('password')?.errors?.['minlength'].requiredLength }} characters
        </span>
      </div>

      <div>
        <input formControlName="confirmPassword" type="password" placeholder="Confirm Password">
        <span *ngIf="userForm.errors?.['passwordMismatch']">Passwords don't match</span>
      </div>

      <!-- Nested FormGroup -->
      <fieldset formGroupName="profile">
        <legend>Profile</legend>
        <input formControlName="firstName" placeholder="First Name">
        <input formControlName="lastName" placeholder="Last Name">
        <input formControlName="age" type="number" placeholder="Age">
      </fieldset>

      <!-- FormArray -->
      <fieldset>
        <legend>Addresses</legend>
        <div formArrayName="addresses">
          <div *ngFor="let address of addresses.controls; let i = index" [formGroupName]="i">
            <input formControlName="street" placeholder="Street">
            <input formControlName="city" placeholder="City">
            <button type="button" (click)="removeAddress(i)">Remove</button>
          </div>
        </div>
        <button type="button" (click)="addAddress()">Add Address</button>
      </fieldset>

      <button type="submit" [disabled]="userForm.invalid || isSubmitting">
        {{ isSubmitting ? 'Saving...' : 'Submit' }}
      </button>

      <!-- Debug -->
      <pre>{{ userForm.value | json }}</pre>
      <pre>Valid: {{ userForm.valid }}, Dirty: {{ userForm.dirty }}</pre>
    </form>
  `
})
export class UserFormComponent implements OnInit {
  userForm!: FormGroup;
  isSubmitting = false;

  constructor(
    private fb: FormBuilder,
    private userService: UserService
  ) {}

  ngOnInit(): void {
    this.userForm = this.fb.group({
      email: ['', [
        Validators.required,
        Validators.email
      ], [
        this.emailExistsValidator.bind(this)  // Async validator
      ]],
      password: ['', [Validators.required, Validators.minLength(8)]],
      confirmPassword: ['', Validators.required],
      profile: this.fb.group({
        firstName: ['', Validators.required],
        lastName: ['', Validators.required],
        age: [null, [Validators.required, Validators.min(18)]],
      }),
      addresses: this.fb.array([
        this.createAddressGroup()
      ], [Validators.minLength(1)])
    }, {
      validators: [this.passwordMatchValidator]  // Cross-field validator
    });
  }

  // Getter for FormArray
  get addresses(): FormArray {
    return this.userForm.get('addresses') as FormArray;
  }

  createAddressGroup(): FormGroup {
    return this.fb.group({
      street: ['', Validators.required],
      city: ['', Validators.required]
    });
  }

  addAddress(): void {
    this.addresses.push(this.createAddressGroup());
  }

  removeAddress(index: number): void {
    this.addresses.removeAt(index);
  }

  // Custom sync validator
  passwordMatchValidator(control: AbstractControl): ValidationErrors | null {
    const password = control.get('password')?.value;
    const confirmPassword = control.get('confirmPassword')?.value;

    if (password && confirmPassword && password !== confirmPassword) {
      return { passwordMismatch: true };
    }
    return null;
  }

  // Custom async validator
  emailExistsValidator(control: AbstractControl): Observable<ValidationErrors | null> {
    return this.userService.checkEmailExists(control.value).pipe(
      // debounceTime(300) — wait for user to stop changing the email field
      // WHY: Async validators run on every valueChange. Without debounce, every character
      //      typed in the email field fires an HTTP call to check uniqueness — very wasteful.
      debounceTime(300),

      // map() — transform the boolean HTTP response into a ValidationErrors object (or null)
      // WHY: Angular validators must return ValidationErrors | null.
      //      null = valid. { emailTaken: true } = invalid with this specific error key.
      //      The template can then show: *ngIf="form.get('email').errors?.emailTaken"
      map(exists => exists ? { emailTaken: true } : null),

      // first() — complete the Observable after its first emission
      // WHY: Async validators MUST complete for Angular's form engine to process the result.
      //      Without first(), the Observable stays open indefinitely and the form
      //      never leaves "PENDING" status. first() ensures exactly one value + completion.
      first()
    );
  }

  onSubmit(): void {
    if (this.userForm.valid) {
      this.isSubmitting = true;
      // Object form subscribe — POST requests MUST handle errors; shorthand would silently lose failures.
      this.userService.createUser(this.userForm.value).subscribe({
        // next — HTTP POST succeeded (2xx response). Void return type — we only care it worked.
        // WHY void: the API returns 201 Created with no body we need, so next() carries nothing useful.
        next: () => {
          this.isSubmitting = false;  // re-enable submit button
          this.userForm.reset();       // clear all form fields and reset validation state
          // complete() fires immediately after this — not handled, no cleanup needed
        },

        // error — HTTP POST failed (validation error 422, auth error 401, network failure, etc.)
        // WHY only reset isSubmitting: we keep form values intact so the user can fix and retry.
        // NOTE: complete() is NOT called after error fires — stream terminates here.
        error: () => this.isSubmitting = false
      });
    } else {
      // Mark all controls as touched to show errors
      this.userForm.markAllAsTouched();
    }
  }
}
```

### Angular Forms — Template-Driven (Full Example)

```typescript
// ─────────────────────────────────────────────────────────────────────────────
// TEMPLATE-DRIVEN FORMS
// Mental Model: Angular reads the template and builds the form model for you.
// You decorate inputs with directives (ngModel, required, minlength) and Angular
// creates FormControl/FormGroup instances implicitly behind the scenes.
// React equivalent: like HTML5 native forms + controlled components — but Angular
// adds automatic validation state tracking and two-way binding.
// ─────────────────────────────────────────────────────────────────────────────

// ─── MODULE SETUP ────────────────────────────────────────────────────────────
// app.module.ts
import { FormsModule } from '@angular/forms';   // ← REQUIRED for ngModel + ngForm

@NgModule({
  imports: [
    FormsModule   // ← Enables: ngModel, NgForm, ngModelGroup, NgModel directives
    // DO NOT also import ReactiveFormsModule unless you need both approaches
  ]
})
export class AppModule {}

// For standalone components:
// @Component({ standalone: true, imports: [FormsModule] })


// ─── EXAMPLE 1: SIMPLE LOGIN FORM ────────────────────────────────────────────
// ★ This is the "Hello World" of template-driven forms
// ★ Equivalent to React: useState + onChange handlers on every input

@Component({
  selector: 'app-login',
  template: `
    <!--
      #loginForm="ngForm"  → creates a template ref variable pointing to the NgForm directive
                             Angular automatically wraps this <form> in a NgForm instance
      (ngSubmit)           → fires ONLY when form is valid (vs regular (submit) which always fires)
    -->
    <form #loginForm="ngForm" (ngSubmit)="onSubmit(loginForm)">

      <div>
        <label>Email</label>
        <!--
          [(ngModel)]="email"  → two-way binding: input value ↔ component property
          name="email"         → REQUIRED. Angular uses this to register the control on NgForm
          required             → built-in HTML5 validator — Angular picks it up automatically
          email                → Angular's email format validator directive
          #emailCtrl="ngModel" → template ref to this control's NgModel instance
                                 gives access to: .valid .invalid .touched .dirty .errors
        -->
        <input
          [(ngModel)]="credentials.email"
          name="email"
          type="email"
          required
          email
          #emailCtrl="ngModel"
          placeholder="Enter email">

        <!-- Show errors only after user has interacted (touched) with the field -->
        <div *ngIf="emailCtrl.invalid && emailCtrl.touched">
          <span *ngIf="emailCtrl.errors?.['required']">Email is required</span>
          <span *ngIf="emailCtrl.errors?.['email']">Must be a valid email address</span>
        </div>
      </div>

      <div>
        <label>Password</label>
        <input
          [(ngModel)]="credentials.password"
          name="password"
          type="password"
          required
          minlength="8"          <!-- built-in: Angular validates minimum length -->
          #passwordCtrl="ngModel"
          placeholder="Enter password">

        <div *ngIf="passwordCtrl.invalid && passwordCtrl.touched">
          <span *ngIf="passwordCtrl.errors?.['required']">Password is required</span>
          <span *ngIf="passwordCtrl.errors?.['minlength']">
            Min {{ passwordCtrl.errors?.['minlength'].requiredLength }} characters
            ({{ passwordCtrl.errors?.['minlength'].actualLength }} entered)
          </span>
        </div>
      </div>

      <!--
        loginForm.invalid → true when ANY control in this NgForm is invalid
        loginForm.pristine → true when NO control has been changed yet
        Disable button while form is invalid OR while API call is running
      -->
      <button type="submit" [disabled]="loginForm.invalid || isLoading">
        {{ isLoading ? 'Logging in...' : 'Login' }}
      </button>

      <!-- Debug panel (remove in production) -->
      <pre *ngIf="showDebug">
Form valid:   {{ loginForm.valid }}
Form dirty:   {{ loginForm.dirty }}
Form touched: {{ loginForm.touched }}
Form value:   {{ loginForm.value | json }}
      </pre>
    </form>
  `
})
export class LoginComponent {
  // Simple flat object — ngModel binds directly to these properties
  credentials = { email: '', password: '' };
  isLoading = false;
  showDebug = false;

  constructor(private authService: AuthService, private router: Router) {}

  // ngForm is passed in from the template — gives you full form state in TypeScript
  onSubmit(form: NgForm): void {
    if (form.invalid) return;  // safety check (button should already be disabled)

    this.isLoading = true;
    // Object form — login HTTP call must handle both success and failure explicitly.
    // WHY isLoading is set to true BEFORE subscribe: gives immediate UI feedback.
    // isLoading is reset to false in error only — in next() we navigate away (component destroyed).
    this.authService.login(this.credentials).subscribe({
      // next — login POST returned 200 with a token.
      // WHY we don't reset isLoading here: router.navigate() destroys this component
      //   immediately, so keeping isLoading=true prevents a flicker of the button re-enabling.
      next: () => {
        form.resetForm();            // ← resets value AND all validation state (touched, dirty)
        this.router.navigate(['/dashboard']);
        // complete() fires after this — component is being destroyed, nothing to do
      },

      // error — login failed (401 wrong password, 403 locked, network error).
      // WHY re-enable the button: user needs to correct credentials and try again.
      // NOTE: next() did NOT fire — form values are still intact so user can edit them.
      error: () => { this.isLoading = false; }
    });
  }
}


// ─── EXAMPLE 2: REGISTRATION FORM WITH ALL VALIDATORS ────────────────────────

@Component({
  selector: 'app-register',
  template: `
    <form #regForm="ngForm" (ngSubmit)="onRegister(regForm)" novalidate>

      <!-- TEXT INPUT — required + minlength + maxlength -->
      <div>
        <input
          [(ngModel)]="user.firstName"
          name="firstName"
          required
          minlength="2"
          maxlength="50"
          #firstNameCtrl="ngModel"
          placeholder="First name">
        <div *ngIf="firstNameCtrl.invalid && firstNameCtrl.touched">
          <span *ngIf="firstNameCtrl.errors?.['required']">Required</span>
          <span *ngIf="firstNameCtrl.errors?.['minlength']">Min 2 characters</span>
          <span *ngIf="firstNameCtrl.errors?.['maxlength']">Max 50 characters</span>
        </div>
      </div>

      <!-- EMAIL -->
      <div>
        <input
          [(ngModel)]="user.email"
          name="email"
          type="email"
          required
          email
          #emailCtrl="ngModel"
          placeholder="Email">
        <div *ngIf="emailCtrl.invalid && emailCtrl.touched">
          <span *ngIf="emailCtrl.errors?.['required']">Required</span>
          <span *ngIf="emailCtrl.errors?.['email']">Invalid email</span>
        </div>
      </div>

      <!-- PATTERN VALIDATOR — phone number format -->
      <div>
        <input
          [(ngModel)]="user.phone"
          name="phone"
          pattern="^[0-9]{10}$"    <!-- regex: exactly 10 digits -->
          #phoneCtrl="ngModel"
          placeholder="10-digit phone (optional)">
        <div *ngIf="phoneCtrl.invalid && phoneCtrl.touched">
          <span *ngIf="phoneCtrl.errors?.['pattern']">Must be exactly 10 digits</span>
        </div>
      </div>

      <!-- NUMBER INPUT — min/max -->
      <div>
        <input
          [(ngModel)]="user.age"
          name="age"
          type="number"
          required
          min="18"
          max="120"
          #ageCtrl="ngModel"
          placeholder="Age">
        <div *ngIf="ageCtrl.invalid && ageCtrl.touched">
          <span *ngIf="ageCtrl.errors?.['required']">Required</span>
          <span *ngIf="ageCtrl.errors?.['min']">Must be at least 18</span>
          <span *ngIf="ageCtrl.errors?.['max']">Must be under 120</span>
        </div>
      </div>

      <!-- SELECT -->
      <div>
        <select
          [(ngModel)]="user.country"
          name="country"
          required
          #countryCtrl="ngModel">
          <option value="">-- Select country --</option>
          <option *ngFor="let c of countries" [value]="c.code">{{ c.name }}</option>
        </select>
        <span *ngIf="countryCtrl.invalid && countryCtrl.touched">Country is required</span>
      </div>

      <!-- CHECKBOX -->
      <div>
        <input
          [(ngModel)]="user.acceptTerms"
          name="acceptTerms"
          type="checkbox"
          required
          #termsCtrl="ngModel">
        <label>I accept the terms and conditions</label>
        <span *ngIf="termsCtrl.invalid && termsCtrl.touched">Must accept terms</span>
      </div>

      <!-- ngModelGroup — groups related controls into a sub-object -->
      <!-- Equivalent to a nested FormGroup in Reactive Forms -->
      <fieldset ngModelGroup="address" #addressGroup="ngModelGroup">
        <legend>Address</legend>
        <input [(ngModel)]="user.address.street" name="street" required placeholder="Street">
        <input [(ngModel)]="user.address.city"   name="city"   required placeholder="City">
        <input [(ngModel)]="user.address.zip"    name="zip"
               pattern="^[0-9]{5}$" placeholder="ZIP (5 digits)">

        <!-- Access group-level state via #addressGroup -->
        <div *ngIf="addressGroup.invalid && addressGroup.touched">
          Please complete all address fields
        </div>
      </fieldset>

      <!-- Form-level submit button — disabled if ANY control is invalid -->
      <button type="submit" [disabled]="regForm.invalid || isSubmitting">
        {{ isSubmitting ? 'Registering...' : 'Register' }}
      </button>

      <!-- Trigger validation on all fields if user tries to submit empty form -->
      <!-- (ngSubmit handles this, but you can also trigger manually) -->
    </form>
  `
})
export class RegisterComponent {
  user = {
    firstName: '',
    email: '',
    phone: '',
    age: null as number | null,
    country: '',
    acceptTerms: false,
    address: { street: '', city: '', zip: '' }
  };

  isSubmitting = false;
  countries = [
    { code: 'US', name: 'United States' },
    { code: 'IN', name: 'India' },
    { code: 'GB', name: 'United Kingdom' },
  ];

  constructor(private userService: UserService) {}

  onRegister(form: NgForm): void {
    if (form.invalid) {
      // If user somehow bypasses disabled button, mark everything touched to show all errors
      Object.values(form.controls).forEach(ctrl => ctrl.markAsTouched());
      return;
    }

    this.isSubmitting = true;
    // Object form — POST calls always need an error handler. Shorthand would lose server errors silently.
    this.userService.createUser(this.user).subscribe({
      // next — server returned 201/200. Registration succeeded.
      // WHY void: we only need success confirmation, not the response body.
      next: () => {
        this.isSubmitting = false;
        form.resetForm();   // ← clears values + resets pristine/touched/dirty state (NgForm)
        // complete() fires right after — HTTP POST always completes after emitting once
      },

      // error — registration failed (e.g. 409 email already taken, 422 validation, network error).
      // WHY keep form values: user needs to read their input to fix the problem.
      // complete() will NOT fire — stream terminated by error.
      error: () => { this.isSubmitting = false; }
    });
  }
}


// ─── EXAMPLE 3: DYNAMIC FORM (add/remove items without FormArray) ─────────────
// Template-driven approach to dynamic lists using *ngFor + index-based names

@Component({
  selector: 'app-dynamic-td',
  template: `
    <form #dynForm="ngForm" (ngSubmit)="onSubmit(dynForm)">

      <h3>Skills</h3>
      <div *ngFor="let skill of skills; let i = index; trackBy: trackByIndex">
        <input
          [(ngModel)]="skills[i]"
          [name]="'skill-' + i"    <!-- CRITICAL: each control needs a unique name -->
          required
          minlength="2"
          [attr.placeholder]="'Skill ' + (i + 1)">
        <button type="button" (click)="removeSkill(i)"
                [disabled]="skills.length === 1">
          Remove
        </button>
      </div>

      <button type="button" (click)="addSkill()">+ Add Skill</button>

      <button type="submit" [disabled]="dynForm.invalid">Save</button>
    </form>
  `
})
export class DynamicTdFormComponent {
  skills: string[] = [''];   // start with one empty skill

  addSkill(): void {
    this.skills.push('');
  }

  removeSkill(index: number): void {
    this.skills.splice(index, 1);
  }

  // CRITICAL: trackBy must use index, not value, for dynamic ngModel bindings
  // WHY: ngModel binds by name. Without trackBy, Angular re-creates controls
  //      on every change, losing validation state.
  trackByIndex(index: number): number {
    return index;
  }

  onSubmit(form: NgForm): void {
    if (form.valid) {
      console.log('Skills:', this.skills.filter(s => s.trim()));
    }
  }
}


// ─── TEMPLATE-DRIVEN: FORM STATE QUICK REFERENCE ─────────────────────────────
/*
  CONTROL STATE FLAGS (same on NgModel and NgForm):
  ─────────────────────────────────────────────────
  .valid      → all validators pass
  .invalid    → at least one validator fails
  .pristine   → value has NOT been changed by user
  .dirty      → value HAS been changed
  .untouched  → user has not focused + left the field
  .touched    → user focused then blurred the field
  .pending    → async validator is running
  .errors     → object of active error keys, e.g. { required: true, minlength: { requiredLength: 8, actualLength: 3 } }

  CSS CLASSES Angular adds automatically:
  ─────────────────────────────────────────
  .ng-valid / .ng-invalid
  .ng-pristine / .ng-dirty
  .ng-untouched / .ng-touched
  Use these for styling: input.ng-invalid.ng-touched { border: 2px solid red; }

  BUILT-IN VALIDATORS (used as HTML attributes):
  ────────────────────────────────────────────────
  required                  → field must have a value
  minlength="n"             → min character length
  maxlength="n"             → max character length
  min="n"                   → min numeric value (for type="number")
  max="n"                   → max numeric value
  email                     → must be valid email format
  pattern="regex"           → must match regular expression

  PROGRAMMATIC CONTROL:
  ────────────────────────────────────────────────
  form.resetForm()          → reset values + validation state
  form.resetForm({ email: 'default@test.com' })  → reset with values
  form.setValue({...})      → set all values at once
  ctrl.markAsTouched()      → manually mark a control as touched
  ctrl.markAsDirty()        → manually mark as dirty
*/
```

---

### Forms Comparison

| Feature | React Hook Form | Angular Template-Driven | Angular Reactive Forms |
|---------|----------------|------------------------|----------------------|
| **Setup** | `npm install react-hook-form` | Import `FormsModule` | Import `ReactiveFormsModule` |
| **Validation location** | Zod/Yup schema in TS | HTML attributes (`required email minlength`) | TypeScript (`Validators.required`) |
| **Two-way binding** | `register()` + `onChange` | `[(ngModel)]` | `formControlName` + value stream |
| **Access control state** | `formState.errors.fieldName` | `#ref="ngModel"` in template | `form.get('field')?.errors` in TS |
| **Async Validation** | `validate: async (val) => ...` | Not supported natively | `AsyncValidatorFn` |
| **Cross-field Validation** | `.refine()` in schema | Not supported natively | Form-group level validator |
| **Dynamic Arrays** | `useFieldArray` | `*ngFor` + index-based names | `FormArray` |
| **Nested Objects** | Dot notation `profile.name` | `ngModelGroup` | Nested `FormGroup` |
| **Unit testability** | Easy (pure functions) | Hard (needs DOM) | Easy (pure TypeScript) |
| **Boilerplate** | Low | Very low | Medium |
| **Best for** | React apps of any size | Simple Angular forms | Complex/dynamic Angular forms |
| **Performance** | Uncontrolled (minimal re-renders) | OnPush compatible | OnPush + `valueChanges` stream |
| **Type Safety** | `z.infer<typeof schema>` | Loose | Typed `FormGroup<T>` (v14+) |

**Quick decision rule:**
```
Simple form (login, search, settings, 2–4 fields)?    → Template-Driven
Complex form (multi-step, dynamic fields, unit tests)? → Reactive
React app?                                             → React Hook Form + Zod
```

---

## 9. HTTP & API Calls

### How to Make HTTP Requests: React vs Angular

#### React Approach (Step-by-Step)

**Step 1**: Install dependencies
```bash
npm install axios @tanstack/react-query
```

**Step 2**: Create API service
```typescript
// Create a file: services/api.ts
// This handles all HTTP requests and interceptors
```

**Step 3**: Create custom hooks
```typescript
// Create a file: hooks/useUsers.ts
// This manages loading, error, and data states
```

**Step 4**: Use in component
```tsx
const UserList = () => {
  const { data, isLoading, error } = useUsers();
  // Components use hooks for data
};
```

#### Angular Approach (Step-by-Step)

**Step 1**: Import HttpClientModule in app.module.ts
```typescript
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';

@NgModule({
  imports: [
    HttpClientModule,
    // Add interceptors
    { provide: HTTP_INTERCEPTORS, useClass: JwtInterceptor, multi: true }
  ]
})
export class AppModule {}
```

**Step 2**: Create service
```bash
ng generate service services/user
```

**Step 3**: Inject and use in component
```typescript
constructor(private userService: UserService) { }
ngOnInit() {
  this.users$ = this.userService.getUsers();
}
```

**Key Differences**:
- React: Hooks handle state, need React Query for caching
- Angular: Services handle data, HttpClient built-in, caching via pipes/subjects

### React (Axios + React Query)
```typescript
// services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
});

// Request interceptor - Add token to every request
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor - Handle errors globally
api.interceptors.response.use(
  response => response,
  async error => {
    if (error.response?.status === 401) {
      // Handle refresh token logic
    }
    return Promise.reject(error);
  }
);

// API service - centralized place for all endpoints
export const userApi = {
  getAll: () => api.get<User[]>('/users'),  // GET /api/users
  getById: (id: string) => api.get<User>(`/users/${id}`),  // GET /api/users/{id}
  create: (data: CreateUserDto) => api.post<User>('/users', data),  // POST /api/users
  update: (id: string, data: UpdateUserDto) => api.put<User>(`/users/${id}`, data),  // PUT /api/users/{id}
  delete: (id: string) => api.delete(`/users/${id}`),  // DELETE /api/users/{id}
};

// Using React Query for caching & state management
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Custom hook for users - Queries (GET requests with caching)
export function useUsers() {
  return useQuery({
    queryKey: ['users'],  // Cache key - used to deduplicate requests
    queryFn: () => userApi.getAll().then(res => res.data),  // Function to fetch data
    staleTime: 5 * 60 * 1000,  // Data is fresh for 5 minutes
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => userApi.getById(id).then(res => res.data),
    enabled: !!id,  // Don't fetch if no id
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: userApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

// Usage in component
const UserList = () => {
  const { data: users, isLoading, error } = useUsers();
  const createUser = useCreateUser();

  if (isLoading) return <Loading />;
  if (error) return <Error error={error} />;

  return (
    <div>
      {users?.map(user => <UserCard key={user.id} user={user} />)}
      <button
        onClick={() => createUser.mutate({ name: 'New User' })}
        disabled={createUser.isPending}
      >
        Add User
      </button>
    </div>
  );
};
```

### Angular (HttpClient + RxJS)
```typescript
// services/user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError } from 'rxjs';
import { map, catchError, tap, shareReplay, switchMap } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UserService {
  private baseUrl = '/api/users';

  // BehaviorSubject<User[] | null> — reactive cache container
  // WHY: BehaviorSubject holds the current cached value in memory.
  //      Any component can immediately read .value synchronously, or subscribe for updates.
  //      null = cache is empty / not yet loaded
  private usersCache$ = new BehaviorSubject<User[] | null>(null);
  private cacheValid = false;

  constructor(private http: HttpClient) {}

  // GET all with caching
  getUsers(forceRefresh = false): Observable<User[]> {
    if (!forceRefresh && this.cacheValid && this.usersCache$.value) {
      return this.usersCache$.asObservable() as Observable<User[]>;
    }

    return this.http.get<User[]>(this.baseUrl).pipe(
      // tap() — populate the BehaviorSubject cache as a side effect, don't alter the stream
      // WHY: tap() is the RIGHT tool here because we want to store the result in the cache
      //      AND pass the same users array down to the subscriber unchanged.
      //      Using map() would require returning the value — tap() is cleaner for side effects.
      tap(users => {
        this.usersCache$.next(users);  // WHY: update shared state so all subscribers see fresh data
        this.cacheValid = true;
      }),
      // shareReplay(1) — multicast + cache the HTTP result for concurrent subscribers
      // WHY: If 3 components call getUsers() simultaneously, without shareReplay
      //      you'd get 3 separate HTTP requests. shareReplay(1) fires ONE request
      //      and replays the cached result to all 3 subscribers.
      shareReplay(1)
    );
  }

  // GET with query params
  searchUsers(query: string, page = 1, limit = 10): Observable<PaginatedResponse<User>> {
    const params = new HttpParams()
      .set('q', query)
      .set('page', page.toString())
      .set('limit', limit.toString());

    return this.http.get<PaginatedResponse<User>>(this.baseUrl, { params });
  }

  // GET single
  getUser(id: string): Observable<User> {
    return this.http.get<User>(`${this.baseUrl}/${id}`);
  }

  // POST — tap() invalidates cache after write so next getUsers() fetches fresh
  createUser(userData: CreateUserDto): Observable<User> {
    return this.http.post<User>(this.baseUrl, userData).pipe(
      // tap() — invalidate cache as a side effect after successful creation
      // WHY: The user list is now stale. tap() lets us bust the cache without
      //      modifying the Observable's value (the created User still flows through)
      tap(() => this.invalidateCache())
    );
  }

  // PUT — same tap() cache-bust pattern as createUser
  updateUser(id: string, userData: UpdateUserDto): Observable<User> {
    return this.http.put<User>(`${this.baseUrl}/${id}`, userData).pipe(
      tap(() => this.invalidateCache())  // WHY: updated user means cached list is stale
    );
  }

  // PATCH — same tap() cache-bust pattern
  patchUser(id: string, partialData: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.baseUrl}/${id}`, partialData).pipe(
      tap(() => this.invalidateCache())  // WHY: partial update also invalidates the list cache
    );
  }

  // DELETE — same tap() cache-bust pattern
  deleteUser(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(
      tap(() => this.invalidateCache())  // WHY: user deleted — list cache is definitely stale
    );
  }

  // File upload
  uploadAvatar(userId: string, file: File): Observable<{ url: string }> {
    const formData = new FormData();
    formData.append('avatar', file);

    return this.http.post<{ url: string }>(
      `${this.baseUrl}/${userId}/avatar`,
      formData,
      {
        reportProgress: true,
        observe: 'events'  // WHY: 'events' mode emits UploadProgress + Response events for progress bars
      }
    ).pipe(
      // filter() — only let the final Response event through (ignore UploadProgress events)
      // WHY: With observe:'events', the stream emits many HttpEvent types (Sent, UploadProgress, Response).
      //      We only care about the final Response — filter() drops everything else.
      filter(event => event.type === HttpEventType.Response),
      // map() — extract the response body from the HttpResponse wrapper
      // WHY: The HttpResponse wraps the actual body. map() unwraps it to get { url: string }
      map(event => (event as HttpResponse<{ url: string }>).body!)
    );
  }

  private invalidateCache(): void {
    this.cacheValid = false;
  }
}

// Usage in component
@Component({
  template: `
    <div *ngIf="loading">Loading...</div>
    <div *ngIf="error" class="error">{{ error }}</div>

    <div *ngFor="let user of users$ | async">
      {{ user.name }}
    </div>

    <button (click)="addUser()" [disabled]="creating">
      {{ creating ? 'Adding...' : 'Add User' }}
    </button>
  `
})
export class UserListComponent implements OnInit {
  users$!: Observable<User[]>;
  loading = false;
  error: string | null = null;
  creating = false;

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    this.users$ = this.userService.getUsers();
  }

  addUser(): void {
    this.creating = true;
    this.userService.createUser({ name: 'New User' }).pipe(
      // switchMap() — after create succeeds, switch to a fresh getUsers() call
      // WHY: We need to chain TWO sequential HTTP calls: POST (create) → GET (refresh list).
      //      switchMap flattens the inner Observable (getUsers) into the outer pipe chain.
      //      The created user is discarded (we pass void) and we switch to fetching the full list.
      //      Using concatMap would also work here; switchMap is fine since we only fire once.
      switchMap(() => this.userService.getUsers(true)),  // forceRefresh=true bypasses cache

      // finalize() — run cleanup code whether the observable completes OR errors
      // WHY: Like a finally{} block for Observables. Ensures creating=false is reset
      //      regardless of success or failure — prevents stuck "Adding..." button state.
      finalize(() => this.creating = false)
    // NOTE: finalize() above already handles resetting `creating=false` for BOTH success and error paths.
    //   That is why the subscribe callbacks here are lean — no need to repeat cleanup logic.
    ).subscribe({
      // next — the full refreshed user list arrived after the create succeeded.
      // of(users) — wraps the plain User[] array back into an Observable so the async pipe can consume it.
      // WHY of(): this.users$ is typed as Observable<User[]>; we can't assign a plain array to it.
      next: users => this.users$ = of(users),

      // error — create OR getUsers failed. finalize() already ran (creating=false reset).
      // WHY still handle error here: finalize doesn't swallow the error — it still propagates.
      //   We capture the message to display an error banner in the template.
      // complete() — fires after next() if the pipe completes normally. Not handled — nothing to do.
      error: err => this.error = err.message
    });
  }
}
```

---

### Detailed HTTP Call Examples (Angular HttpClient — All Patterns)

> **Mental Model:** `HttpClient` is a thin RxJS wrapper around the browser's `fetch` API.
> Every method (`get`, `post`, `put`, `patch`, `delete`) returns a **cold Observable** —
> nothing happens until `.subscribe()` (or `| async` pipe) is called.
> You can pipe RxJS operators between the call and the subscription to transform,
> cache, retry, or cancel the request.

```
HTTP CALL LIFECYCLE
──────────────────
Component / Service           HttpClient              Server
      │                           │                     │
      │── .get<T>(url).pipe() ──▶ │── fetch(url) ──────▶│
      │                           │                     │
      │◀── tap() side effects ────│◀─── 200 JSON ───────│
      │◀── map() transform        │                     │
      │◀── catchError() fallback  │      (or 4xx/5xx)   │
      │                           │                     │
   subscribe()                  done                  done
```

#### 1. GET — Fetch a list with typed response

```typescript
// services/product.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams, HttpHeaders } from '@angular/common/http';
import {
  Observable, throwError, BehaviorSubject, EMPTY, of, forkJoin
} from 'rxjs';
import {
  map, catchError, tap, retry, timeout,
  switchMap, concatMap, mergeMap, exhaustMap,
  takeUntil, finalize, shareReplay, startWith
} from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class ProductService {
  private readonly baseUrl = '/api/products';

  constructor(private http: HttpClient) {}

  // ── GET all products ───────────────────────────────────────────────────────
  // http.get<T>() — sends GET, deserializes JSON body into T automatically
  // WHY generic <Product[]>: TypeScript infers the type of the emitted value so
  //   callers get full intellisense without any manual casting
  getProducts(): Observable<Product[]> {
    return this.http.get<Product[]>(this.baseUrl).pipe(

      // map() — project the raw array into a sorted copy (never mutate server data in place)
      // WHY: keeps the service boundary clean; callers always get a consistently sorted list
      map(products => [...products].sort((a, b) => a.name.localeCompare(b.name))),

      // catchError() — intercept any HTTP error and return a safe fallback
      // WHY: returning EMPTY completes the stream silently (no value emitted),
      //      so the async pipe shows nothing rather than crashing the template.
      //      Use of([]) if you need to emit an empty array instead.
      catchError(err => {
        console.error('Failed to load products', err);
        return EMPTY;   // stream ends cleanly, no value, no error propagated to template
      })
    );
  }

  // ── GET with query parameters ──────────────────────────────────────────────
  // HttpParams is immutable — each .set() returns a NEW params object
  // WHY immutable: prevents accidental shared-state bugs across multiple calls
  searchProducts(query: string, category: string, page = 1): Observable<PaginatedResult<Product>> {
    const params = new HttpParams()
      .set('q', query)           // ?q=shoes
      .set('category', category) // &category=footwear
      .set('page', page)         // &page=1
      .set('limit', 20);         // &limit=20

    // HttpClient automatically serializes params into the URL query string
    return this.http.get<PaginatedResult<Product>>(this.baseUrl, { params }).pipe(

      // timeout(10_000) — error if the server hasn't responded within 10 seconds
      // WHY: Without a timeout, a hung server causes the Observable to wait forever.
      //      The error propagates to catchError below for graceful handling.
      timeout(10_000),

      // retry(2) — re-subscribe (resend the request) up to 2 times on error
      // WHY: transient network hiccups (brief connectivity loss, server restart)
      //      often resolve on the next attempt. retry() sits BEFORE catchError so
      //      it gets a chance to recover before the error handler gives up.
      retry(2),

      catchError(err => {
        // throwError() re-throws as an Observable error so the caller's
        // error callback / catchError in the chain receives it
        return throwError(() => new Error(`Search failed: ${err.message}`));
      })
    );
  }

  // ── GET single item ────────────────────────────────────────────────────────
  getProduct(id: string): Observable<Product> {
    // Template literal builds: /api/products/abc-123
    return this.http.get<Product>(`${this.baseUrl}/${id}`).pipe(

      // tap() — log for debugging WITHOUT touching the stream value
      // WHY: console.log inside map() would work but forces you to return the value;
      //      tap() is specifically designed for side effects with no return value
      tap(product => console.log('Loaded product:', product.id)),

      catchError(err => {
        if (err.status === 404) {
          // 404 = resource genuinely missing — return null so caller can show "not found" UI
          return of(null as unknown as Product);
        }
        return throwError(() => err);  // all other errors re-throw to caller
      })
    );
  }
}
```

#### 2. POST — Create a resource

```typescript
// ── POST — create new product ──────────────────────────────────────────────
// http.post<T>(url, body) — serializes body to JSON, sends Content-Type: application/json
// WHY generic <Product>: server returns the created product (with generated id, timestamps)
createProduct(dto: CreateProductDto): Observable<Product> {
  // Custom headers — e.g. idempotency key to prevent duplicate submissions on retry
  const headers = new HttpHeaders({
    'X-Idempotency-Key': crypto.randomUUID()  // server deduplicates retried POSTs
  });

  return this.http.post<Product>(this.baseUrl, dto, { headers }).pipe(

    // tap() — trigger cache invalidation as a side effect after successful creation
    // WHY: the product list cache is now stale; tap() busts it without altering
    //      the stream value (the newly created Product still flows to the subscriber)
    tap(newProduct => {
      console.log('Created:', newProduct.id);
      this.invalidateCache();  // force next getProducts() to re-fetch from server
    }),

    catchError(err => {
      if (err.status === 409) {
        // 409 Conflict = duplicate record — surface a clear message to the UI
        return throwError(() => new Error('A product with this name already exists'));
      }
      return throwError(() => err);
    })
  );
}
```

#### 3. PUT / PATCH — Update a resource

```typescript
// ── PUT — full replace (send the entire updated object) ───────────────────
// WHY PUT not PATCH: PUT semantics = "replace the whole resource".
//   Omitting a field in a PUT body means the server REMOVES that field.
updateProduct(id: string, dto: UpdateProductDto): Observable<Product> {
  return this.http.put<Product>(`${this.baseUrl}/${id}`, dto).pipe(
    tap(() => this.invalidateCache()),
    catchError(err => throwError(() => err))
  );
}

// ── PATCH — partial update (send only changed fields) ─────────────────────
// WHY PATCH: more efficient than PUT when only one or two fields change.
//   Partial<UpdateProductDto> enforces that only a subset of fields is sent.
patchProduct(id: string, changes: Partial<UpdateProductDto>): Observable<Product> {
  return this.http.patch<Product>(`${this.baseUrl}/${id}`, changes).pipe(
    tap(() => this.invalidateCache()),
    catchError(err => throwError(() => err))
  );
}
```

#### 4. DELETE — Remove a resource

```typescript
// ── DELETE ─────────────────────────────────────────────────────────────────
// http.delete<void>() — <void> because DELETE responses typically have no body
// WHY not <any>: using <void> makes the intent explicit and prevents callers
//   from accidentally reading a body that doesn't exist
deleteProduct(id: string): Observable<void> {
  return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(
    tap(() => {
      this.invalidateCache();
      console.log('Deleted product', id);
    }),
    catchError(err => {
      if (err.status === 404) {
        // Already deleted — treat as success (idempotent delete)
        return of(undefined as unknown as void);
      }
      return throwError(() => err);
    })
  );
}
```

#### 5. Chaining HTTP Calls (sequential & parallel)

```typescript
// ── SEQUENTIAL: concatMap — create product, THEN upload image ─────────────
// concatMap() — waits for the first Observable to complete before starting the next
// WHY concatMap not switchMap: we MUST NOT cancel mid-chain. If the user triggers
//   another call while the POST is in flight, concatMap queues it; switchMap would
//   cancel the POST (data loss). Use concatMap for writes that must complete in order.
createProductWithImage(dto: CreateProductDto, imageFile: File): Observable<Product> {
  return this.createProduct(dto).pipe(

    concatMap(createdProduct =>
      // runs ONLY after createProduct() completes successfully
      this.uploadImage(createdProduct.id, imageFile).pipe(
        // map() — attach the uploaded image URL to the product before returning
        // WHY: callers get a fully enriched Product object in one chained call
        map(uploadResult => ({
          ...createdProduct,
          imageUrl: uploadResult.url
        }))
      )
    ),

    catchError(err => {
      console.error('Create+upload failed', err);
      return throwError(() => err);
    })
  );
}

// ── PARALLEL: forkJoin — load product + reviews + seller simultaneously ────
// forkJoin([obs1, obs2, obs3]) — subscribes to ALL at once, emits ONE array
//   of the LAST values when ALL observables complete (like Promise.all)
// WHY forkJoin not combineLatest: forkJoin is for one-shot HTTP calls that
//   complete; combineLatest keeps re-emitting whenever any source changes —
//   correct for live streams, wrong for HTTP which completes after one response
loadProductPage(id: string): Observable<ProductPageData> {
  return forkJoin([
    this.getProduct(id),                          // GET /api/products/:id
    this.http.get<Review[]>(`/api/reviews?productId=${id}`),   // GET /api/reviews
    this.http.get<Seller>(`/api/sellers?productId=${id}`)      // GET /api/sellers
  ]).pipe(
    // map() — destructure the results array into a typed object
    // WHY: callers deal with a clean { product, reviews, seller } shape,
    //      not a positional [0][1][2] tuple
    map(([product, reviews, seller]) => ({ product, reviews, seller })),

    catchError(err => {
      // If ANY of the three calls fails, forkJoin errors immediately.
      // WHY: one missing piece means we can't render the full page anyway.
      console.error('Failed to load product page data', err);
      return throwError(() => err);
    })
  );
}

// ── PARALLEL with independent errors: mergeMap over array ─────────────────
// mergeMap() — subscribes to all inner Observables concurrently
// WHY mergeMap not forkJoin: we want ALL items attempted even if some fail
//   (forkJoin fails-fast; mergeMap lets each item resolve independently)
deleteMultipleProducts(ids: string[]): Observable<{ id: string; success: boolean }[]> {
  return of(...ids).pipe(   // of(...ids) emits each id as a separate emission

    mergeMap(id =>          // for each id, fire a DELETE in parallel
      this.deleteProduct(id).pipe(
        map(() => ({ id, success: true })),
        catchError(() => of({ id, success: false }))  // swallow per-item errors, log them
      )
    )

    // Results arrive in the ORDER RESPONSES COME BACK — not the original array order.
    // Use concatMap instead of mergeMap if you need guaranteed sequential execution.
  );
}
```

#### 6. Cancel HTTP Calls with takeUntil

```typescript
// ── Cancel in-flight request when component is destroyed ──────────────────
// Pattern: tie the subscription lifetime to the component's lifecycle
@Component({ template: `<div *ngFor="let p of products">{{ p.name }}</div>` })
export class ProductListComponent implements OnInit, OnDestroy {
  products: Product[] = [];

  // Subject<void> — a "kill switch" Observable used purely as a signal
  // WHY void: we never care about the emitted VALUE, only WHEN it emits
  private destroy$ = new Subject<void>();

  constructor(private productService: ProductService) {}

  ngOnInit(): void {
    this.productService.getProducts().pipe(

      // takeUntil(destroy$) — automatically unsubscribes when destroy$ emits
      // WHY: Without this, the subscription outlives the component. If the HTTP
      //   response arrives after ngOnDestroy, Angular tries to update a destroyed
      //   component's view → memory leak + "ExpressionChangedAfterCheck" error.
      //   takeUntil is the standard Angular pattern for tying subscriptions to
      //   the component lifecycle without storing a Subscription reference to unsubscribe.
      takeUntil(this.destroy$)

    ).subscribe(products => this.products = products);
  }

  ngOnDestroy(): void {
    // Emit once to trigger takeUntil in every active pipe in this component
    // WHY next() + complete(): next() signals takeUntil, complete() prevents
    //   the Subject itself from being a memory leak (GC can collect it)
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

#### 7. Upload with Progress Tracking

```typescript
// ── File upload with real-time progress percentage ─────────────────────────
uploadImage(productId: string, file: File): Observable<number | string> {
  const formData = new FormData();
  formData.append('image', file, file.name);  // 'image' = field name the server expects

  return this.http.post('/api/upload', formData, {
    // observe: 'events' — tells HttpClient to emit EVERY HTTP event (not just the response)
    // WHY: default observe:'body' only emits the final response. 'events' gives us
    //   UploadProgress events so we can calculate % and show a progress bar.
    observe: 'events',

    // reportProgress: true — enables UploadProgress events in the stream
    // WHY: must be combined with observe:'events'; without it, progress events are suppressed
    reportProgress: true
  }).pipe(

    // map() — convert raw HttpEvent into a progress % (number) or final URL (string)
    // WHY: callers shouldn't deal with HttpEvent types — map() provides a clean union type
    map(event => {
      if (event.type === HttpEventType.UploadProgress && event.total) {
        // UploadProgress event: calculate 0–100 percentage
        return Math.round(100 * event.loaded / event.total);  // e.g. 45 (= 45%)
      }
      if (event.type === HttpEventType.Response) {
        // Response event: upload complete — return the server-assigned URL
        return (event.body as { url: string }).url;            // e.g. 'https://cdn.../img.jpg'
      }
      return 0;  // Sent / other events — treat as 0% to avoid gaps in the progress bar
    }),

    // filter() — skip zero-progress events (Sent, other non-meaningful events)
    // WHY: emitting 0 after 45 would reset the progress bar visually — filter it out
    filter(value => value !== 0),

    catchError(err => throwError(() => new Error(`Upload failed: ${err.message}`)))
  );
}

// ── Component wiring for the progress bar ─────────────────────────────────
@Component({
  template: `
    <input type="file" (change)="onFileSelected($event)" />
    <div *ngIf="uploadProgress !== null">
      <!-- Show % while uploading, URL when done -->
      <ng-container *ngIf="isNumber(uploadProgress)">
        Uploading... {{ uploadProgress }}%
        <progress [value]="uploadProgress" max="100"></progress>
      </ng-container>
      <ng-container *ngIf="!isNumber(uploadProgress)">
        Done! <a [href]="uploadProgress">View image</a>
      </ng-container>
    </div>
  `
})
export class UploadComponent {
  uploadProgress: number | string | null = null;
  isNumber = (v: unknown): v is number => typeof v === 'number';

  constructor(private productService: ProductService) {}

  onFileSelected(event: Event): void {
    const file = (event.target as HTMLInputElement).files?.[0];
    if (!file) return;

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // subscribe() ANATOMY — all three callbacks explained
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    //
    //  subscribe(fn)                   ← SHORTHAND — only handles `next`. Errors are
    //                                    silently swallowed into the global error handler.
    //                                    NEVER use for HTTP calls — you'll miss failures.
    //
    //  subscribe({ next, error, complete }) ← OBJECT FORM — handle all three phases:
    //
    //  ┌───────────┬──────────────────────────────────────────────────────────────────┐
    //  │ Callback  │ When it fires                                                    │
    //  ├───────────┼──────────────────────────────────────────────────────────────────┤
    //  │ next      │ Every time the Observable emits a value (0 → N times).           │
    //  │           │ For HTTP GET: fires exactly ONCE (the response), then complete.  │
    //  │           │ For upload with reportProgress: fires MANY times (% progress).   │
    //  │           │ For BehaviorSubject: fires immediately + on every .next() call.  │
    //  ├───────────┼──────────────────────────────────────────────────────────────────┤
    //  │ error     │ Fires ONCE if the Observable errors. The stream TERMINATES here. │
    //  │           │ `complete` is NEVER called after `error`.                        │
    //  │           │ Common sources: HTTP 4xx/5xx, network failure, thrown exception. │
    //  │           │ After `error` fires — no more `next`, no `complete`.             │
    //  ├───────────┼──────────────────────────────────────────────────────────────────┤
    //  │ complete  │ Fires ONCE when the stream ends SUCCESSFULLY with no more values.│
    //  │           │ `error` is NEVER called after `complete`.                        │
    //  │           │ HTTP calls: always complete after emitting the response.         │
    //  │           │ BehaviorSubject/interval: NEVER complete unless you call         │
    //  │           │   subject.complete() / takeUntil explicitly.                     │
    //  └───────────┴──────────────────────────────────────────────────────────────────┘
    //
    //  LIFECYCLE DIAGRAM:
    //
    //  ── Happy path ──────────────────────────────────────────────────────────────
    //  next(10%) → next(40%) → next(70%) → next(100%) → complete()
    //              (stream is DONE — no more callbacks will fire)
    //
    //  ── Error path ──────────────────────────────────────────────────────────────
    //  next(10%) → next(40%) → error(NetworkError)
    //              (stream TERMINATED — complete() will NOT fire)
    //
    //  ── Unsubscribed path (takeUntil / component destroy) ───────────────────────
    //  next(10%) → next(40%) → [unsubscribe] → silence (no error, no complete)
    //
    //  WHY this upload Observable fires `next` MANY times:
    //    uploadImage() uses HttpClient with { reportProgress: true, observe: 'events' }.
    //    HttpClient emits HttpUploadProgressEvent on each chunk, then HttpResponse on done.
    //    The pipe maps each event to a % number — so next fires repeatedly until 100%.
    //    Most HTTP GET/POST observables only emit ONE value then complete immediately.
    this.productService.uploadImage('product-123', file).subscribe({
      // next — called for EACH upload progress event (10%, 40%, 70%, 100%)
      // WHY: update the progress bar UI on every chunk — gives the user live feedback
      next: progress => this.uploadProgress = progress,

      // error — called ONCE if the upload fails (network drop, server error, timeout)
      // WHY: show an error message to the user; complete() will NOT fire after this
      error: err    => console.error(err),

      // complete — called ONCE after the final next() when the stream finishes successfully
      // WHY: show "Upload done!" message or navigate away — only fires on clean finish
      // NOTE: complete is NOT called if error fires first
      // NOTE: for plain GET/POST requests, complete fires right after the single next()
      complete: ()  => console.log('Upload complete')
    });
  }
}
```

#### 8. HTTP Error Handling Patterns — Reference Table

```
┌─────────────────────┬──────────────────────────────────────────────────────────────────┐
│ Scenario            │ RxJS Pattern                                                     │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ Transient failure   │ retry(3) — resend up to 3 times before giving up                 │
│ Timeout             │ timeout(5000) — error if no response within 5 s                  │
│ Fallback value      │ catchError(() => of(defaultValue))                               │
│ Silent failure      │ catchError(() => EMPTY) — stream ends, no value, no crash        │
│ Re-throw to caller  │ catchError(err => throwError(() => err))                         │
│ 401 → refresh token │ catchError → switchMap(refresh) → retry original (interceptor)   │
│ Chain on success    │ switchMap / concatMap inside pipe()                              │
│ Parallel calls      │ forkJoin([obs1, obs2]) — all must complete                       │
│ Cancel on destroy   │ takeUntil(destroy$)                                              │
│ Progress tracking   │ observe:'events' + reportProgress:true + filter(HttpEventType)   │
└─────────────────────┴──────────────────────────────────────────────────────────────────┘
```

---

## 10. Dependency Injection (Angular Unique)

> **This is one of Angular's most powerful features with no direct React equivalent.**

```typescript
// Understanding Angular's Hierarchical DI System

// 1. Root-level Singleton (most common)
@Injectable({ providedIn: 'root' })  // Tree-shakable singleton
export class AuthService {
  // Same instance everywhere in the app
}

// 2. Module-level (shared within module)
@Injectable()  // Must be added to module providers
export class FeatureService {}

@NgModule({
  providers: [FeatureService]  // New instance per lazy-loaded module
})
export class FeatureModule {}

// 3. Component-level (new instance per component)
@Component({
  providers: [FormValidationService]  // New instance for each component instance
})
export class FormComponent {
  constructor(private validation: FormValidationService) {}
}

// 4. Injection Tokens for non-class values
import { InjectionToken } from '@angular/core';

export const API_CONFIG = new InjectionToken<ApiConfig>('api.config');

@NgModule({
  providers: [
    { provide: API_CONFIG, useValue: { baseUrl: '/api', timeout: 5000 } }
  ]
})
export class AppModule {}

// Usage
@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(@Inject(API_CONFIG) private config: ApiConfig) {
    console.log(this.config.baseUrl);
  }
}

// 5. Factory Providers
export const LOGGER = new InjectionToken<Logger>('logger');

@NgModule({
  providers: [
    {
      provide: LOGGER,
      useFactory: (env: Environment) => {
        return env.production ? new ProductionLogger() : new DevLogger();
      },
      deps: [Environment]  // Inject dependencies into factory
    }
  ]
})

// 6. Abstract class as interface (common pattern)
export abstract class StorageService {
  abstract get(key: string): string | null;
  abstract set(key: string, value: string): void;
  abstract remove(key: string): void;
}

@Injectable()
export class LocalStorageService extends StorageService {
  get(key: string) { return localStorage.getItem(key); }
  set(key: string, value: string) { localStorage.setItem(key, value); }
  remove(key: string) { localStorage.removeItem(key); }
}

@Injectable()
export class SessionStorageService extends StorageService {
  get(key: string) { return sessionStorage.getItem(key); }
  set(key: string, value: string) { sessionStorage.setItem(key, value); }
  remove(key: string) { sessionStorage.removeItem(key); }
}

// Swap implementation easily
@NgModule({
  providers: [
    { provide: StorageService, useClass: LocalStorageService }
    // Or for testing: { provide: StorageService, useClass: MockStorageService }
  ]
})

// 7. Optional and Self decorators
@Injectable({ providedIn: 'root' })
export class ChildService {
  constructor(
    @Optional() private optionalService: OptionalService,  // null if not provided
    @Self() private selfService: SelfService,  // Only look in own injector
    @SkipSelf() private parentService: ParentService,  // Skip own, look in parent
    @Host() private hostService: HostService  // Only look up to host component
  ) {}
}

// 8. Multi Providers (multiple values for same token)
export const HTTP_INTERCEPTORS = new InjectionToken<HttpInterceptor[]>('interceptors');

@NgModule({
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: LoggingInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },
  ]
})
// All interceptors will be injected as an array
```

### React Alternative: Context + Custom Hooks
```tsx
// React doesn't have DI, but you can simulate some patterns

// 1. Singleton-like with module scope
const authService = new AuthService();  // Module-level singleton
export const useAuth = () => authService;

// 2. Context for dependency injection
const ServiceContext = createContext<Services | null>(null);

export const ServiceProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const services = useMemo(() => ({
    auth: new AuthService(),
    api: new ApiService(),
    storage: new StorageService(),
  }), []);

  return (
    <ServiceContext.Provider value={services}>
      {children}
    </ServiceContext.Provider>
  );
};

export const useServices = () => {
  const context = useContext(ServiceContext);
  if (!context) throw new Error('Must be within ServiceProvider');
  return context;
};

// 3. Component-level instances (not really DI)
const Form = () => {
  const validator = useMemo(() => new FormValidator(), []);
  // New instance per component mount
};
```

---

## 11. RxJS Deep Dive (Angular Unique)

> **RxJS is Angular's superpower. React uses Promises; Angular uses Observables.**

```typescript
// RxJS Fundamentals for React Developers
// ─────────────────────────────────────────────────────────────────────────────
// MENTAL MODEL: Think of RxJS Observables as "smart arrays that emit over time"
//   Regular Array:   [1, 2, 3]               → all values available NOW
//   Promise:         fetch('/api')            → ONE value, in the FUTURE
//   Observable:      interval(1000)           → MANY values, over TIME, cancellable
//
// The key insight: pipe() chains operators like UNIX pipes → each transforms the stream
// ─────────────────────────────────────────────────────────────────────────────

import {
  Observable, Subject, BehaviorSubject, ReplaySubject,
  of, from, interval, timer, fromEvent, forkJoin, combineLatest, merge
} from 'rxjs';
import {
  map, filter, tap, switchMap, mergeMap, concatMap, exhaustMap,
  debounceTime, distinctUntilChanged, throttleTime,
  take, takeUntil, takeWhile, skip, first, last,
  catchError, retry, retryWhen, timeout,
  shareReplay, share, publishReplay, refCount,
  startWith, pairwise, scan, reduce,
  delay, delayWhen
} from 'rxjs/operators';

// ============================================
// CREATION OPERATORS — Wrap existing data sources as Observables
// ============================================

// from() — Wraps a Promise, array, or iterable as an Observable
// WHY: Bridges the React/JS world (Promises) with the Angular/RxJS world (Observables)
//      so you can chain pipe() operators on top of async data sources
const promise$ = from(fetch('/api/users').then(r => r.json()));

// from(array) — Converts an array into a stream that emits each item sequentially
// WHY: Lets you apply RxJS operators (map, filter, mergeMap) over array items
const array$ = from([1, 2, 3, 4, 5]);

// fromEvent() — Turns DOM events into an Observable stream
// WHY: Instead of addEventListener + removeEventListener (manual cleanup),
//      fromEvent gives you a stream you can pipe, filter, debounce, and
//      unsubscribe cleanly with takeUntil
const click$ = fromEvent(document, 'click');

// timer(ms) — Emits ONE value after a delay, then completes
// WHY: Use for one-shot delays, retry backoffs, or debouncing without setInterval.
//      Unlike setTimeout, it's cancellable via unsubscribe()
const timer$ = timer(1000);

// interval(ms) — Emits incrementing numbers repeatedly (like setInterval, but as a stream)
// WHY: Use for polling. Unlike setInterval, the whole polling pipeline can be
//      paused, resumed, or cancelled by changing upstream Observables
const interval$ = interval(1000);

// ============================================
// SUBJECTS (Observable + Observer) — The bridges between imperative and reactive code
// ============================================

// Subject — Pure event bus: no memory, no initial value
// WHY: Use when you want to manually push values into a stream.
//      Like an event emitter (Node.js EventEmitter), but as an Observable.
//      Late subscribers MISS past values — only get future emissions.
// MENTAL MODEL: A radio broadcast — tune in late and you've missed what was said
const subject = new Subject<string>();
subject.next('Hello');  // Nothing happens — no subscribers yet
subject.subscribe(val => console.log(val));
subject.next('World');  // Logs: "World" — subscriber only gets this one

// BehaviorSubject — Holds current state + emits it to every new subscriber
// WHY: The #1 tool for shared state in Angular services.
//      New subscribers ALWAYS get the current value immediately (no missed data).
//      Use for: currentUser$, cartItems$, selectedTheme$, isLoading$
// MENTAL MODEL: A TV with replay — any viewer who tunes in sees the current frame
const behavior = new BehaviorSubject<number>(0);  // Initial value REQUIRED
console.log(behavior.value);  // 0 — can read current value synchronously
behavior.subscribe(val => console.log('Sub1:', val));  // Immediately logs: 0
behavior.next(1);  // Logs: 1 to Sub1
behavior.subscribe(val => console.log('Sub2:', val));  // Immediately logs: 1 (current!)

// ReplaySubject(n) — Buffers the last N values, replays them to every new subscriber
// WHY: Use when late subscribers need history (e.g., last 3 notifications,
//      audit log, or chat messages that must be visible to latecomers)
// MENTAL MODEL: DVR recording — rewinds last N frames for any new viewer
const replay = new ReplaySubject<number>(3);  // Buffer last 3 values
replay.next(1); replay.next(2); replay.next(3); replay.next(4);
replay.subscribe(val => console.log(val));  // Logs: 2, 3, 4 (skips 1 — buffer is 3)

// ============================================
// TRANSFORMATION OPERATORS — Shape data as it flows through the pipe
// ============================================

// map() — Transform each emitted value into a new value (same as Array.map)
// WHY: Most common operator. Use to project API response fields, convert types,
//      or compute derived values without breaking the stream
of(1, 2, 3).pipe(
  map(x => x * 10)  // WHY: scale each number — same value shape, different magnitude
).subscribe(console.log);  // 10, 20, 30

// filter() — Only let matching values through (same as Array.filter)
// WHY: Gate the stream. Avoids unnecessary downstream processing.
//      Example: filter(event => event.type === 'click') on a mixed event stream
of(1, 2, 3, 4, 5).pipe(
  filter(x => x % 2 === 0)  // WHY: only even numbers pass — odd numbers are dropped
).subscribe(console.log);  // 2, 4

// tap() — Run a side effect on each value WITHOUT changing it
// WHY: Perfect for debugging (log values mid-pipe), analytics, or updating external
//      state (BehaviorSubject) without interrupting the data flow.
//      Never mutate the stream value inside tap — it's for side effects only.
of(1, 2, 3).pipe(
  tap(x => console.log('Before:', x)),  // WHY: inspect value BEFORE map transforms it
  map(x => x * 10),
  tap(x => console.log('After:', x))   // WHY: inspect the transformed value — great for debugging
).subscribe();

// scan() — Running accumulator that emits each intermediate result (like Array.reduce but streams)
// WHY: Build up state incrementally from a stream of actions/events.
//      Use for: running totals, accumulating items into arrays,
//      Redux-style state machines from an action stream
of(1, 2, 3, 4, 5).pipe(
  scan((acc, val) => acc + val, 0)  // WHY: running sum — emits 1, 3, 6, 10, 15 (not just final 15)
).subscribe(console.log);  // 1, 3, 6, 10, 15

// ============================================
// FLATTENING OPERATORS — Handle Observables that produce inner Observables
// ============================================
// MENTAL MODEL: You have a stream of search queries. Each query triggers an HTTP call.
// You now have an Observable OF Observables. These operators "flatten" that into one stream.
// The ONLY difference between them is what happens when a NEW outer value arrives
// while an inner Observable is still running.

// ─────────────────────────────────────
// switchMap() — CANCEL previous inner, SWITCH to new one (MOST COMMON in Angular)
// ─────────────────────────────────────
// WHY: Prevents stale data. If user types "ang" then "angu" before the first HTTP
//      completes, the "ang" request is cancelled. Only the result for "angu" arrives.
// USE FOR: Autocomplete/search, route param changes, any "latest value wins" scenario
// DANGER: Do NOT use for writes (PUT/POST/DELETE) — cancelling mid-write corrupts data
searchInput$.pipe(
  debounceTime(300),    // WHY: wait 300ms after user stops typing before firing HTTP
  switchMap(query => this.http.get(`/search?q=${query}`))
  // ↑ If user types again before response, previous HTTP request is CANCELLED
  // Only the most recent query's result will reach .subscribe()
).subscribe(results => this.results = results);

// ─────────────────────────────────────
// mergeMap() — Run ALL inner Observables CONCURRENTLY (parallel)
// ─────────────────────────────────────
// WHY: When order doesn't matter and you want maximum throughput.
//      All requests fire immediately — no waiting, no cancellation.
// USE FOR: Fetching multiple independent users/files in parallel, bulk operations
// DANGER: No backpressure — too many concurrent requests can overwhelm the server
userIds$.pipe(
  mergeMap(id => this.http.get(`/users/${id}`))
  // ↑ All requests fire simultaneously — responses arrive in any order
).subscribe(user => this.users.push(user));

// ─────────────────────────────────────
// concatMap() — Queue inner Observables SEQUENTIALLY (one at a time, in order)
// ─────────────────────────────────────
// WHY: When ORDER matters. Each inner Observable must complete before the next starts.
// USE FOR: Sequential saves, ordered API calls, step-by-step wizard submissions
// TRADE-OFF: Slowest — each operation waits for the previous (but guarantees order)
saveOperations$.pipe(
  concatMap(data => this.http.post('/save', data))
  // ↑ Save 1 must complete before Save 2 starts. Order guaranteed.
).subscribe();

// ─────────────────────────────────────
// exhaustMap() — IGNORE new values while current inner is still running
// ─────────────────────────────────────
// WHY: Prevents double-submissions. While the login HTTP call is in flight,
//      any additional button clicks are silently dropped.
// USE FOR: Login buttons, form submit buttons, any "one at a time" action
// MENTAL MODEL: A bouncer — only lets one person in at a time; latecomers wait outside (dropped)
submitButton$.pipe(
  exhaustMap(() => this.http.post('/submit', this.form.value))
  // ↑ All clicks during the active request are IGNORED — no double-submit possible
).subscribe();

// ┌──────────────────────────────────────────────────────────────┐
// │  FLATMAP DECISION CHART                                       │
// │  switchMap  → Latest wins, cancel old  (search, navigation)  │
// │  mergeMap   → All run in parallel      (bulk fetch)          │
// │  concatMap  → Sequential queue         (ordered writes)       │
// │  exhaustMap → Ignore while busy        (login, submit)       │
// └──────────────────────────────────────────────────────────────┘

// ============================================
// COMBINATION OPERATORS — Merge multiple streams into one
// ============================================

// combineLatest() — Wait for ALL sources to emit once, then re-emit on ANY change
// WHY: Build a view-model from multiple independent data sources.
//      Whenever user$ OR settings$ emits a new value, you get a fresh combined snapshot.
//      Critical for dashboards, filter pages, or any UI driven by multiple observables.
// GOTCHA: Does NOT emit until ALL sources have emitted at least once
const user$ = this.store.select(selectUser);
const settings$ = this.store.select(selectSettings);

combineLatest([user$, settings$]).pipe(
  map(([user, settings]) => ({ user, settings }))  // WHY: merge into single viewModel object
).subscribe(data => this.viewModel = data);

// forkJoin() — Like Promise.all: wait for ALL to COMPLETE, emit only their final values
// WHY: When you need multiple HTTP calls to ALL finish before rendering the page.
//      Once any source errors, the whole forkJoin fails (like Promise.all).
// USE FOR: Page init that requires data from 3+ endpoints simultaneously
// GOTCHA: If any source never completes, forkJoin never emits
forkJoin({
  user: this.http.get<User>('/user'),
  posts: this.http.get<Post[]>('/posts'),
  comments: this.http.get<Comment[]>('/comments')
}).subscribe(({ user, posts, comments }) => {
  // ↑ ALL three requests completed — data is fully available here
});

// merge() — Combine multiple streams, pass through ALL values from ALL sources
// WHY: Listen to multiple event sources simultaneously as one unified stream.
//      Unlike combineLatest, each value passes through independently (no combining).
// USE FOR: Listening to multiple button clicks, multiple event types, multiple data feeds
merge(
  fromEvent(saveBtn, 'click').pipe(map(() => 'save')),    // WHY: normalise click → action string
  fromEvent(deleteBtn, 'click').pipe(map(() => 'delete')) // WHY: both clicks go to one handler
).subscribe(action => this.handleAction(action));

// ============================================
// ERROR HANDLING — Handle failures gracefully without breaking the stream
// ============================================

this.http.get('/api/data').pipe(
  // retry(n) — Re-subscribe to the source Observable up to n times on error
  // WHY: Handles transient network failures automatically (503s, timeouts)
  //      without any manual retry logic. Counts fresh from 1 each time.
  retry(3),

  // catchError() — Intercept an error and recover by returning a new Observable
  // WHY: Like try/catch for async streams. Returning of([]) means the stream
  //      CONTINUES with an empty array instead of crashing.
  //      Returning throwError() re-throws so upstream handlers can catch it.
  catchError(error => {
    console.error('Error:', error);
    return of([]);           // ← recover with fallback value — stream survives
    // return throwError(() => error);  // ← re-throw — propagates to subscribe's error handler
  })
).subscribe();

// retryWhen() + scan() + delayWhen() — Exponential backoff retry strategy
// WHY: Don't hammer a failing server. Wait 1s, 2s, 4s, 8s between retries.
//      retryWhen gives you control over WHEN to retry (vs retry which retries immediately).
//      scan() tracks the retry count. delayWhen() delays based on that count.
this.http.get('/api/data').pipe(
  retryWhen(errors => errors.pipe(
    // scan() — accumulate retry count; throw after 3 to stop retrying
    scan((retryCount, error) => {
      if (retryCount >= 3) throw error;  // WHY: bail out after 3 attempts
      return retryCount + 1;
    }, 0),
    // delayWhen() — dynamic delay: 2^retryCount seconds (1s, 2s, 4s...)
    // WHY: Exponential backoff prevents thundering herd on a recovering server
    delayWhen(retryCount => timer(Math.pow(2, retryCount) * 1000))
  ))
).subscribe();

// ============================================
// PRACTICAL PATTERNS — Real-world compositions of the above operators
// ============================================

// ─────────────────────────────────────
// PATTERN 1: Typeahead Search
// Operators: debounceTime → distinctUntilChanged → filter → switchMap → catchError → shareReplay
// ─────────────────────────────────────
@Component({
  template: `<input [formControl]="searchControl">`
})
export class SearchComponent {
  searchControl = new FormControl('');
  results$: Observable<Result[]>;

  constructor(private searchService: SearchService) {
    this.results$ = this.searchControl.valueChanges.pipe(
      // debounceTime(300) — wait 300ms after the user STOPS typing
      // WHY: Without this, every single keystroke fires an HTTP call (terrible UX + performance)
      debounceTime(300),

      // distinctUntilChanged() — skip if value hasn't changed since last emission
      // WHY: If user types "ang" then clicks elsewhere and back, value is still "ang"
      //      — no need to re-fetch the same results
      distinctUntilChanged(),

      // filter() — only proceed if query is long enough to be meaningful
      // WHY: Prevents fetching results for 1-character queries ("a" would return thousands)
      filter(query => query.length >= 2),

      // switchMap() — cancel previous HTTP call, fire new one for latest query
      // WHY: If user types fast, only the LAST query's HTTP call matters.
      //      Previous in-flight calls are cancelled — prevents race conditions and stale results
      switchMap(query => this.searchService.search(query).pipe(
        // catchError() INSIDE switchMap — critical placement
        // WHY: If placed inside, only this search fails gracefully.
        //      If placed outside, any error would TERMINATE the entire results$ stream
        catchError(() => of([]))  // recover with empty array — search box stays functional
      )),

      // shareReplay(1) — multicast the result to multiple template subscriptions
      // WHY: The template may have multiple | async pipes consuming results$.
      //      Without shareReplay, each async pipe would trigger a separate HTTP call.
      //      shareReplay(1) executes ONE HTTP call and shares the cached result.
      shareReplay(1)
    );
  }
}

// ─────────────────────────────────────
// PATTERN 2: Polling with pause/resume
// Operators: BehaviorSubject → switchMap → EMPTY / interval → startWith → shareReplay
// ─────────────────────────────────────
export class PollingService {
  // BehaviorSubject<boolean> — current pause state; false = running
  // WHY: Gives us a reactive on/off switch. Any change immediately affects data$
  private pause$ = new BehaviorSubject<boolean>(false);

  data$ = this.pause$.pipe(
    // switchMap() — react to pause state changes
    // WHY: When pause$ flips from false→true, switchMap CANCELS the active interval.
    //      When it flips back, a new interval starts fresh.
    switchMap(paused => paused
      ? EMPTY  // WHY: EMPTY completes immediately → effectively stops polling
      : interval(5000).pipe(
          // startWith(0) — trigger immediately on subscribe (don't wait 5s for first tick)
          // WHY: Users see data on load, not after a 5 second blank screen
          startWith(0),
          // switchMap() nested — for each tick, fetch fresh data
          // WHY: Cancel any in-flight HTTP from the previous tick if still pending
          switchMap(() => this.http.get('/api/data'))
        )
    ),
    // shareReplay(1) — all subscribers share one active poll, get last value on subscribe
    // WHY: If 5 components subscribe, there's still only ONE interval running
    shareReplay(1)
  );

  pause()  { this.pause$.next(true);  }  // flip BehaviorSubject → kills interval via switchMap
  resume() { this.pause$.next(false); }  // flip BehaviorSubject → restarts interval via switchMap
}

// ─────────────────────────────────────
// PATTERN 3: Optimistic updates
// Operators: of() → merge() → catchError
// ─────────────────────────────────────
updateUser(user: User): Observable<User> {
  // of(user) — emit the local user object immediately (no HTTP wait)
  // WHY: UI updates instantly, making the app feel snappy
  const optimistic$ = of(user);

  const server$ = this.http.put<User>(`/users/${user.id}`, user).pipe(
    // catchError() — if server rejects the update, revert by re-fetching server state
    // WHY: Optimistic update failed → show error + rollback to truth from server
    catchError(error => {
      this.notificationService.error('Update failed, reverting...');
      return this.http.get<User>(`/users/${user.id}`);  // revert to real server state
    })
  );

  // merge() — emit optimistic value FIRST, then server value when it arrives
  // WHY: Component sees instant update (optimistic$) then final value (server$).
  //      If server confirms: same value = no visual change.
  //      If server rejects: catchError provides the reverted value.
  return merge(
    optimistic$,
    server$.pipe(delay(0))  // WHY: delay(0) puts server$ in next microtask after optimistic$
  );
}

// ─────────────────────────────────────
// PATTERN 4: HTTP Caching with expiry
// Operators: shareReplay → timeout → catchError
// ─────────────────────────────────────
private cache$ = new Map<string, Observable<any>>();
private cacheTime = 5 * 60 * 1000;  // 5 minutes

getData(key: string): Observable<Data> {
  if (!this.cache$.has(key)) {
    const request$ = this.http.get<Data>(`/api/${key}`).pipe(
      // shareReplay({ bufferSize: 1, refCount: true }) — cache + multicast
      // WHY: bufferSize:1 = keep last value. refCount:true = clear when all unsubscribe.
      //      Multiple components calling getData('users') share ONE HTTP call.
      shareReplay({ bufferSize: 1, refCount: true }),

      // timeout(ms) — throw an error if no emission within cacheTime
      // WHY: Forces cache expiry — after 5 minutes, the next subscriber triggers a fresh fetch
      timeout(this.cacheTime),

      // catchError() — on timeout or error, remove stale cache entry and retry fresh
      // WHY: Ensures stale cache entries don't serve expired data indefinitely
      catchError(() => {
        this.cache$.delete(key);  // evict stale entry
        return this.getData(key);  // recursive retry with fresh HTTP call
      })
    );
    this.cache$.set(key, request$);
  }
  return this.cache$.get(key)!;
}

// ─────────────────────────────────────
// PATTERN 5: Coordinated loading state (loading/error/data ViewModel)
// Operators: Subject → switchMap → map → startWith → catchError
// ─────────────────────────────────────
@Component({
  template: `
    <div *ngIf="vm$ | async as vm">
      <div *ngIf="vm.loading">Loading...</div>
      <div *ngIf="vm.error">{{ vm.error }}</div>
      <div *ngIf="vm.data">{{ vm.data | json }}</div>
    </div>
  `
})
export class DataComponent {
  // Subject<void> — manual trigger (no value needed, just the signal)
  // WHY: Using a Subject as a trigger lets you re-fire the data load from refresh()
  //      without re-subscribing. Push void → data$ pipeline runs again.
  private load$ = new Subject<void>();

  vm$ = this.load$.pipe(
    // switchMap() — when load$ fires, cancel any in-flight HTTP, start fresh
    // WHY: If user hits "Refresh" rapidly, only the LAST click's HTTP call completes
    switchMap(() => this.dataService.getData().pipe(
      // map() — wrap successful data in the ViewModel shape
      map(data => ({ loading: false, error: null, data })),

      // startWith() — emit loading state BEFORE the HTTP call completes
      // WHY: Without this, the template shows nothing until data arrives.
      //      With this, loading spinner shows immediately when load$ fires.
      //      MUST be INSIDE switchMap so each refresh resets to loading: true
      startWith({ loading: true, error: null, data: null }),

      // catchError() INSIDE switchMap — recover per-request, not globally
      // WHY: If placed outside, a single HTTP error would kill vm$ permanently.
      //      Placed inside, each failed request emits the error state and the stream lives on.
      catchError(error => of({ loading: false, error: error.message, data: null }))
    ))
  );

  ngOnInit() {
    this.load$.next();  // WHY: kick off the initial load
  }

  refresh() {
    this.load$.next();  // WHY: trigger pipeline again — switchMap cancels old, starts new
  }
}
```

---

## 12. React-Only Features

### Features that don't exist in Angular (or work differently)

```tsx
// 1. JSX - HTML in JavaScript
// React: JSX is JavaScript expressions
const UserCard = ({ user, onDelete }) => (
  <div className={`card ${user.isActive ? 'active' : ''}`}>
    <h2>{user.name}</h2>
    {user.avatar && <img src={user.avatar} alt={user.name} />}
    {user.roles.map(role => (
      <span key={role} className="badge">{role}</span>
    ))}
    <button onClick={() => onDelete(user.id)}>Delete</button>
  </div>
);

// Angular: Separate template file or template string
// Uses directives: *ngIf, *ngFor, [class], (click)
// Less flexible but more structured

// 2. Hooks - Composable logic
// React: Hooks compose naturally
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

// Compose hooks together
function useSearch(query: string) {
  const debouncedQuery = useDebounce(query, 300);
  const [results, setResults] = useLocalStorage<Result[]>('lastSearch', []);
  // ...
}

// Angular: Services + RxJS achieve similar but differently
// No hook-like composition, use services and pipes

// 3. Context - Prop drilling solution
const ThemeContext = createContext<Theme>('light');
const UserContext = createContext<User | null>(null);

// Multiple contexts compose cleanly
const App = () => (
  <ThemeContext.Provider value="dark">
    <UserContext.Provider value={currentUser}>
      <Layout />
    </UserContext.Provider>
  </ThemeContext.Provider>
);

// Consume anywhere in tree
const Button = () => {
  const theme = useContext(ThemeContext);
  const user = useContext(UserContext);
  // ...
};

// Angular: Services with DI provide similar functionality
// But context is simpler for pure "passing down" values

// 4. Portals - Render outside DOM hierarchy
const Modal = ({ children, isOpen }) => {
  if (!isOpen) return null;

  return ReactDOM.createPortal(
    <div className="modal-overlay">
      <div className="modal-content">{children}</div>
    </div>,
    document.getElementById('modal-root')!
  );
};

// Angular: Uses ViewContainerRef or CDK Portal
// More complex setup required

// 5. Fragments - Return multiple elements
const Columns = () => (
  <>
    <td>Column 1</td>
    <td>Column 2</td>
    <td>Column 3</td>
  </>
);

// Angular: <ng-container> serves similar purpose
// <ng-container *ngFor="let item of items">...</ng-container>

// 6. Error Boundaries - Catch rendering errors
class ErrorBoundary extends React.Component<
  { children: ReactNode; fallback: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    logError(error, info);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

// Angular: Uses ErrorHandler service (global only)
// No component-level error boundary

// 7. Suspense - Declarative loading states
const LazyComponent = React.lazy(() => import('./HeavyComponent'));

const App = () => (
  <Suspense fallback={<Loading />}>
    <LazyComponent />
  </Suspense>
);

// Angular: Uses route-level loading or manual *ngIf
// No Suspense equivalent yet

// 8. Concurrent Features (React 18+)
const [isPending, startTransition] = useTransition();

const handleChange = (value: string) => {
  // Urgent: Update input immediately
  setInputValue(value);

  // Non-urgent: Can be interrupted
  startTransition(() => {
    setSearchResults(filterResults(value));
  });
};

// Angular: No equivalent - uses Zone.js for change detection
// Different paradigm entirely

// 9. Server Components (Next.js / React 19)
// Components that render on server, never ship JS to client
async function ProductList() {
  const products = await db.products.findMany();  // Direct DB access!
  return (
    <ul>
      {products.map(p => <li key={p.id}>{p.name}</li>)}
    </ul>
  );
}

// Angular: Has SSR with Angular Universal, but different approach
// Components are universal, not server-only
```

---

## 13. Angular-Only Features

### Features that don't exist in React (or require libraries)

```typescript
// 1. Dependency Injection (covered in section 10)
// Built into the framework, hierarchical, powerful

// 2. Decorators - Metadata-driven development
@Component({...})
@Injectable({...})
@Pipe({...})
@Directive({...})
@Input() @Output()
@ViewChild() @ContentChild()
@HostBinding() @HostListener()

// React: No decorators (though you can use them with Babel)

// 3. Directives - Extend HTML
// Structural Directive (modifies DOM structure)
@Directive({ selector: '[appRepeat]' })
export class RepeatDirective {
  constructor(
    private templateRef: TemplateRef<any>,
    private viewContainer: ViewContainerRef
  ) {}

  @Input() set appRepeat(times: number) {
    this.viewContainer.clear();
    for (let i = 0; i < times; i++) {
      this.viewContainer.createEmbeddedView(this.templateRef, { index: i });
    }
  }
}
// Usage: <div *appRepeat="5; let i = index">Item {{ i }}</div>

// Attribute Directive (modifies element behavior)
@Directive({ selector: '[appHighlight]' })
export class HighlightDirective {
  @Input() appHighlight = 'yellow';

  @HostBinding('style.backgroundColor')
  get bgColor() { return this.appHighlight; }

  @HostListener('mouseenter')
  onMouseEnter() { this.appHighlight = 'lightblue'; }

  @HostListener('mouseleave')
  onMouseLeave() { this.appHighlight = 'yellow'; }
}
// Usage: <p appHighlight="pink">Hover me</p>

// React: Would need HOC or custom hook + explicit props

// 4. Pipes - Transform data in templates
@Pipe({ name: 'fileSize' })
export class FileSizePipe implements PipeTransform {
  transform(bytes: number, decimals = 2): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(decimals)) + ' ' + sizes[i];
  }
}
// Usage: {{ file.size | fileSize:1 }}

// Async Pipe - Auto subscribe/unsubscribe
// {{ observable$ | async }}

// React: Must create components or use render props

// 5. Two-Way Binding
@Component({
  template: `<input [(ngModel)]="name">`  // Two-way binding syntax
})
export class FormComponent {
  name = '';  // Automatically synced with input
}

// React: Must implement both value and onChange
// <input value={name} onChange={e => setName(e.target.value)} />

// 6. Template Reference Variables
@Component({
  template: `
    <input #nameInput>
    <button (click)="greet(nameInput.value)">Greet</button>
  `
})
export class GreetComponent {
  greet(name: string) {
    alert(`Hello, ${name}!`);
  }
}

// React: Would need useRef

// 7. Content Projection (Transclusion)
// Single slot
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <ng-content></ng-content>
    </div>
  `
})
export class CardComponent {}
// Usage: <app-card><p>Card content</p></app-card>

// Multi-slot projection
@Component({
  selector: 'app-layout',
  template: `
    <header><ng-content select="[header]"></ng-content></header>
    <main><ng-content select="[body]"></ng-content></main>
    <footer><ng-content select="[footer]"></ng-content></footer>
  `
})
export class LayoutComponent {}
// Usage:
// <app-layout>
//   <div header>Header Content</div>
//   <div body>Body Content</div>
//   <div footer>Footer Content</div>
// </app-layout>

// React: Uses children prop or named slots via props

// 8. Built-in HTTP Client
// Angular has HttpClientModule built-in with:
// - Interceptors
// - Progress events
// - Typed responses
// - Request/Response transformation
// React: Needs axios, fetch wrapper, etc.

// 9. Built-in Forms Module
// Angular has two form approaches built-in:
// - Template-driven forms (NgModel)
// - Reactive forms (FormBuilder, FormControl, FormGroup, FormArray)
// React: Needs react-hook-form, formik, etc.

// 10. Built-in Router
// Angular Router is part of the framework with:
// - Guards (CanActivate, CanDeactivate, CanLoad, Resolve)
// - Lazy loading
// - Route animations
// - Auxiliary routes
// React: Needs react-router-dom

// 11. Animations Module
@Component({
  animations: [
    trigger('fadeInOut', [
      state('in', style({ opacity: 1 })),
      transition(':enter', [
        style({ opacity: 0 }),
        animate('300ms ease-in')
      ]),
      transition(':leave', [
        animate('300ms ease-out', style({ opacity: 0 }))
      ])
    ])
  ],
  template: `<div *ngIf="visible" @fadeInOut>Animated content</div>`
})
export class AnimatedComponent {
  visible = true;
}

// React: Needs framer-motion, react-spring, etc.

// 12. Zone.js - Automatic Change Detection
// Angular automatically detects changes via Zone.js
// No need to call setState or dispatch

// React: Must explicitly update state

// 13. Schematics - Code Generation
// $ ng generate component user-profile
// $ ng generate service auth
// $ ng generate guard auth
// Creates files with boilerplate + updates modules

// React: CRA has limited generation, or use third-party tools

// 14. Angular CLI - Built-in Build System
// $ ng build --prod --source-map
// $ ng test --code-coverage
// $ ng e2e
// Webpack configuration is abstracted

// React: CRA or Vite, but less integrated
```

### Angular 17+ Brand New Features (Game Changers!)

Angular 17 introduced a complete modernization of the framework. Here's what's new:

#### 1. **New Control Flow Syntax (Already Covered in Section 2.5)**

- `@if` replaces `*ngIf`
- `@for` replaces `*ngFor`
- `@switch/@case` replaces `*ngSwitch`
- `@try/@catch` - Error handling
- `@defer` - Lazy loading components

**Key Benefit**: Much more readable, like JavaScript, better performance.

#### 2. **Standalone Components (Simplified Architecture)**

```typescript
// BEFORE (Angular 16 and earlier)
// Required NgModules for everything

@NgModule({
  declarations: [UserComponent],
  imports: [CommonModule],
  exports: [UserComponent]
})
export class UserModule {}

// AFTER (Angular 17+) - Much simpler!
@Component({
  selector: 'app-user',
  standalone: true,  // ← No NgModule needed!
  imports: [CommonModule],
  template: `...`
})
export class UserComponent {}
```

**Why This Matters:**
- ✅ No more module boilerplate
- ✅ Tree-shakeable - only used components included
- ✅ Faster development
- ✅ Easier to understand component dependencies

#### 3. **New Angular Signals (Reactive State Management)**

```typescript
// Angular's new answer to React's useState!

import { signal, computed } from '@angular/core';

@Component({
  template: `
    <div>Count: {{ count() }}</div>
    <button (click)="increment()">+</button>
    <p>Is even: {{ isEven() }}</p>
  `
})
export class CounterComponent {
  // Signal = reactive state
  count = signal(0);
  
  // Computed = derived state (auto-updates when dependencies change)
  isEven = computed(() => this.count() % 2 === 0);
  
  increment() {
    this.count.set(this.count() + 1);  // or this.count.update(v => v + 1)
  }
}
```

**Key Benefits:**
- ✅ Fine-grained reactivity (like React hooks)
- ✅ Better performance (only affected components re-render)
- ✅ Simpler than RxJS Observables for many cases
- ✅ No subscription management needed

**Comparison with Observable-based approach:**

```typescript
// OLD: RxJS Observable approach
count$ = new BehaviorSubject(0);
isEven$ = this.count$.pipe(
  // map() — derives a boolean "is even" stream from the count stream
  // WHY: Keeps isEven$ reactive — automatically updates whenever count$ changes.
  map(count => count % 2 === 0)
);

increment() {
  this.count$.next(this.count$.value + 1);
}

// Template needs async pipe
<div>Count: {{ count$ | async }}</div>

// NEW: Signal-based approach (much simpler!)
count = signal(0);
isEven = computed(() => this.count() % 2 === 0);

increment() {
  this.count.update(v => v + 1);
}

// Template just calls the function
<div>Count: {{ count() }}</div>
```

#### 4. **New Angular Router (with standalone API)**

```typescript
// BEFORE: Complex route configuration in modules
const routes = [
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard.module')
      .then(m => m.DashboardModule)
  }
];

// AFTER: Simpler, type-safe routing
const routes: Routes = [
  {
    path: 'dashboard',
    loadComponent: () => import('./dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  }
];
```

#### 5. **Hydration and Server-Side Rendering Improvements**

```typescript
// New hydration API for Angular Universal
bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideClientHydration()  // ← NEW in Angular 17
  ]
});

// Makes server-side rendering and caching much faster
```

#### 6. **New @Component Features**

```typescript
@Component({
  selector: 'app-card',
  standalone: true,
  imports: [CommonModule],
  
  // NEW: Safer, cleaner template binding
  host: {
    'class': 'card-component',
    '[attr.data-type]': 'type'
  },
  
  // NEW: Host directives (composition)
  hostDirectives: [MyCustomDirective],
  
  template: `...`
})
export class CardComponent {}
```

#### 7. **New Dependency Injection Features**

```typescript
// NEW: More intuitive parameter syntax
@Injectable()
export class UserService {
  constructor(
    private http = inject(HttpClient),  // ← Function-based DI
    private auth = inject(AuthService)
  ) {}
}

// You can provide at app level
bootstrapApplication(AppComponent, {
  providers: [
    provideHttpClient(),
    provideRouter(routes),
    { provide: MY_TOKEN, useValue: 'value' }
  ]
});
```

#### 8. **Typed Forms (Type Safety)**

```typescript
// NEW in Angular 17: Strongly typed reactive forms

const form = new FormGroup({
  email: new FormControl<string>('', { nonNullable: true }),
  age: new FormControl<number | null>(null)
});

// TypeScript now knows:
form.controls.email     // ✅ Knows it's FormControl<string>
form.controls.age       // ✅ Knows it's FormControl<number | null>
form.get('email')?.value  // ✅ Type is string
```

#### 9. **New Image Directive (`NgOptimizedImage`)**

```typescript
// BEFORE: Basic img tag (poor performance)
<img src="hero.jpg" alt="Hero">

// AFTER: Optimized image loading
<img 
  ngSrc="hero.jpg" 
  alt="Hero"
  width="400"
  height="300"
  priority  // Load immediately
>

// ImageLoaderConfig for CDN integration
bootstrapApplication(AppComponent, {
  providers: [
    provideImageKitLoader('https://ik.imagekit.io/demo')
  ]
});

// Automatic:
// - Lazy loading
// - Responsive images
// - WebP format support
// - LCP (Largest Contentful Paint) optimization
```

#### 10. **New Development Experience (ng serve)**

```bash
# Faster builds with esbuild
# Instant restart on file changes
# Better dev server

ng serve  # Blazing fast!
```

### Quick Reference: Are You on Angular 17+?

```typescript
// Check Angular version
import { VERSION } from '@angular/core';
console.log(VERSION.major);  // 17, 18, etc.

// Modern Angular 17+ checklist:
✅ Using standalone components (no NgModules)
✅ Using signals for state (not always RxJS)
✅ Using @if/@for in templates (not *ngIf/*ngFor)
✅ Using bootstrapApplication (not NgModule bootstrap)
✅ Using provideXxx() for dependencies (not module imports)
```

---

## 14. Popular Libraries Comparison

| Category | React | Angular |
|----------|-------|---------|
| **State Management** | Redux Toolkit, Zustand, Jotai, Recoil, MobX | NgRx, NGXS, Akita, Elf |
| **Forms** | React Hook Form, Formik | Built-in (Reactive Forms) |
| **Routing** | React Router, TanStack Router | Built-in (@angular/router) |
| **HTTP** | Axios, TanStack Query, SWR | Built-in (HttpClient) |
| **UI Components** | MUI, Chakra UI, Ant Design, Radix | Angular Material, PrimeNG, ng-bootstrap, Nebular |
| **Testing** | Jest, React Testing Library, Vitest | Jasmine, Karma, Jest (with setup) |
| **E2E Testing** | Cypress, Playwright | Protractor (deprecated), Cypress, Playwright |
| **Animation** | Framer Motion, React Spring | Built-in (@angular/animations) |
| **i18n** | react-intl, i18next | ngx-translate, Built-in (@angular/localize) |
| **Date Handling** | date-fns, day.js, Luxon | Same libraries work |
| **Charts** | Recharts, Victory, Chart.js | ngx-charts, ng2-charts |
| **Tables** | TanStack Table, AG Grid | AG Grid, ngx-datatable, PrimeNG Table |
| **Drag & Drop** | react-beautiful-dnd, dnd-kit | @angular/cdk/drag-drop |
| **Virtual Scroll** | react-window, react-virtuoso | @angular/cdk/scrolling |
| **Icons** | react-icons, Lucide React | Angular FontAwesome, Material Icons |
| **Meta Tags / SEO** | react-helmet-async | @angular/platform-browser (Meta, Title) |
| **SSR** | Next.js, Remix | Angular Universal |

### Library Code Examples

```typescript
// NgRx (like Redux Toolkit)
// Install: ng add @ngrx/store @ngrx/effects @ngrx/store-devtools

// NGXS (simpler alternative)
// Install: npm install @ngxs/store

@State<AuthStateModel>({
  name: 'auth',
  defaults: { user: null, token: null }
})
@Injectable()
export class AuthState {
  @Selector()
  static user(state: AuthStateModel) { return state.user; }

  @Action(Login)
  login(ctx: StateContext<AuthStateModel>, action: Login) {
    return this.authService.login(action.payload).pipe(
      // tap() — update NGXS state as a side effect without altering the stream value
      // WHY: tap() is the NGXS pattern for updating state inside an @Action handler.
      //      patchState() is called for its side effect; the auth response still flows through.
      tap(result => ctx.patchState({ user: result.user, token: result.token }))
    );
  }
}

// Angular Material
// Install: ng add @angular/material

import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';

@Component({
  template: `
    <mat-form-field>
      <mat-label>Email</mat-label>
      <input matInput formControlName="email">
    </mat-form-field>
    <button mat-raised-button color="primary">Submit</button>
  `
})

// ngx-translate
// Install: npm install @ngx-translate/core @ngx-translate/http-loader

@Component({
  template: `
    <h1>{{ 'HOME.TITLE' | translate }}</h1>
    <p>{{ 'HOME.WELCOME' | translate:{ name: userName } }}</p>
  `
})
export class HomeComponent {
  constructor(private translate: TranslateService) {
    translate.setDefaultLang('en');
    translate.use('en');
  }
}

// Angular CDK Drag & Drop
import { DragDropModule } from '@angular/cdk/drag-drop';

@Component({
  template: `
    <div cdkDropList (cdkDropListDropped)="drop($event)">
      <div *ngFor="let item of items" cdkDrag>{{ item }}</div>
    </div>
  `
})
export class DragDropComponent {
  items = ['Item 1', 'Item 2', 'Item 3'];

  drop(event: CdkDragDrop<string[]>) {
    moveItemInArray(this.items, event.previousIndex, event.currentIndex);
  }
}
```

---

## 15. Architecture Patterns

### React Architecture (Feature-Based)
```
src/
├── app/
│   ├── store.ts
│   ├── App.tsx
│   └── routes.tsx
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── AuthProvider.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── services/
│   │   │   └── authService.ts
│   │   ├── store/
│   │   │   └── authSlice.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts            # Public API
│   └── users/
│       ├── components/
│       ├── hooks/
│       └── ...
├── shared/
│   ├── components/
│   │   ├── Button/
│   │   └── Modal/
│   ├── hooks/
│   │   ├── useDebounce.ts
│   │   └── useLocalStorage.ts
│   ├── utils/
│   └── types/
└── infrastructure/
    ├── api/
    │   └── apiClient.ts
    └── config/
```

### Angular Architecture (Domain-Driven)
```
src/app/
├── core/                           # Singleton services, app-wide
│   ├── guards/
│   │   ├── auth.guard.ts
│   │   └── role.guard.ts
│   ├── interceptors/
│   │   ├── jwt.interceptor.ts
│   │   ├── error.interceptor.ts
│   │   └── loading.interceptor.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── notification.service.ts
│   │   └── storage.service.ts
│   ├── models/
│   │   └── user.model.ts
│   └── core.module.ts
├── shared/                         # Shared across features
│   ├── components/
│   │   ├── button/
│   │   ├── modal/
│   │   └── table/
│   ├── directives/
│   │   └── highlight.directive.ts
│   ├── pipes/
│   │   ├── file-size.pipe.ts
│   │   └── time-ago.pipe.ts
│   └── shared.module.ts
├── features/                       # Feature modules (lazy-loaded)
│   ├── auth/
│   │   ├── components/
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── services/
│   │   │   └── auth-api.service.ts
│   │   ├── store/                  # Feature-specific NgRx
│   │   │   ├── auth.actions.ts
│   │   │   ├── auth.reducer.ts
│   │   │   ├── auth.effects.ts
│   │   │   └── auth.selectors.ts
│   │   ├── auth.module.ts
│   │   └── auth-routing.module.ts
│   ├── dashboard/
│   └── admin/
├── store/                          # Root store
│   ├── app.state.ts
│   ├── app.reducer.ts
│   └── index.ts
├── app.component.ts
├── app.module.ts
└── app-routing.module.ts
```

### Smart vs Dumb Components Pattern

```typescript
// ANGULAR - Container (Smart) Component
@Component({
  selector: 'app-user-list-container',
  template: `
    <app-user-list
      [users]="users$ | async"
      [loading]="loading$ | async"
      (userSelect)="onUserSelect($event)"
      (userDelete)="onUserDelete($event)">
    </app-user-list>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserListContainerComponent {
  users$ = this.store.select(selectUsers);
  loading$ = this.store.select(selectUsersLoading);

  constructor(private store: Store) {}

  onUserSelect(userId: string) {
    this.store.dispatch(selectUser({ userId }));
  }

  onUserDelete(userId: string) {
    this.store.dispatch(deleteUser({ userId }));
  }
}

// ANGULAR - Presentational (Dumb) Component
@Component({
  selector: 'app-user-list',
  template: `
    <div *ngIf="loading" class="loading">Loading...</div>
    <ul *ngIf="!loading">
      <li *ngFor="let user of users; trackBy: trackById">
        <span (click)="userSelect.emit(user.id)">{{ user.name }}</span>
        <button (click)="userDelete.emit(user.id)">Delete</button>
      </li>
    </ul>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserListComponent {
  @Input() users: User[] = [];
  @Input() loading = false;
  @Output() userSelect = new EventEmitter<string>();
  @Output() userDelete = new EventEmitter<string>();

  trackById = (index: number, user: User) => user.id;
}
```

```tsx
// REACT - Container (Smart) Component
const UserListContainer: React.FC = () => {
  const dispatch = useDispatch();
  const users = useSelector(selectUsers);
  const loading = useSelector(selectUsersLoading);

  const handleUserSelect = useCallback((userId: string) => {
    dispatch(selectUser({ userId }));
  }, [dispatch]);

  const handleUserDelete = useCallback((userId: string) => {
    dispatch(deleteUser({ userId }));
  }, [dispatch]);

  return (
    <UserList
      users={users}
      loading={loading}
      onUserSelect={handleUserSelect}
      onUserDelete={handleUserDelete}
    />
  );
};

// REACT - Presentational (Dumb) Component
interface UserListProps {
  users: User[];
  loading: boolean;
  onUserSelect: (userId: string) => void;
  onUserDelete: (userId: string) => void;
}

const UserList: React.FC<UserListProps> = React.memo(({
  users,
  loading,
  onUserSelect,
  onUserDelete
}) => {
  if (loading) return <div className="loading">Loading...</div>;

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>
          <span onClick={() => onUserSelect(user.id)}>{user.name}</span>
          <button onClick={() => onUserDelete(user.id)}>Delete</button>
        </li>
      ))}
    </ul>
  );
});
```

---

## Quick Reference Cheat Sheet

| Concept | React | Angular |
|---------|-------|---------|
| Component | Function + Hooks | Class + Decorators |
| Template | JSX | HTML + Directives |
| Styling | CSS-in-JS / CSS Modules | Component-scoped SCSS |
| Props | `props` object | `@Input()` |
| Events | Callback props | `@Output()` + EventEmitter |
| State | `useState` | Class properties |
| Effects | `useEffect` | `ngOnInit`, `ngOnChanges`, `ngOnDestroy` |
| Ref | `useRef` | `@ViewChild` |
| Context | `createContext` + `useContext` | Services + DI |
| Memo | `React.memo`, `useMemo` | `OnPush`, Pure Pipes |
| Conditional | `{condition && <X/>}` | `*ngIf` |
| Loop | `{items.map(...)}` | `*ngFor` |
| Class binding | `className={...}` | `[class]`, `[ngClass]` |
| Style binding | `style={{...}}` | `[style]`, `[ngStyle]` |
| Form Input | `value` + `onChange` | `[(ngModel)]` or `formControl` |
| HTTP | Axios / fetch | HttpClient |
| Router | react-router-dom | @angular/router |
| Animation | framer-motion | @angular/animations |
| Testing | Jest + RTL | Jasmine + Karma |

---

## Best Practices & Common Patterns (Practical Guide)

### React Best Practices

**1. State Management Strategy**
```tsx
// ❌ DON'T: Multiple useState calls scattered
const [user, setUser] = useState(null);
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);

// ✅ DO: Use useReducer for complex state or custom hook
const [state, dispatch] = useReducer(userReducer, initialState);
// or create custom hook:
const { user, loading, error } = useUserData(userId);
```

**2. Avoid Prop Drilling (Use Context)**
```tsx
// ❌ DON'T: Pass props through many levels
<Parent theme={theme}>
  <Child theme={theme}>
    <GrandChild theme={theme} />
  </Child>
</Parent>

// ✅ DO: Use Context for shared state
<ThemeProvider value={theme}>
  <Component /> {/* Access theme anywhere */}
</ThemeProvider>
```

**3. Optimize Re-renders**
```tsx
// ✅ DO: Use React.memo, useMemo, useCallback
const MemoizedChild = React.memo(Child);

const Parent = () => {
  const handleClick = useCallback(() => {...}, [deps]);
  const data = useMemo(() => expensiveCalc(), [deps]);
  return <MemoizedChild onClick={handleClick} data={data} />;
};
```

### Angular Best Practices

**1. Use OnPush Change Detection**
```typescript
// ✅ DO: Optimize change detection
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush
  // Only check when @Input changes or event fires
})
export class MyComponent { }
```

**2. Unsubscribe from Observables**
```typescript
// ✅ DO: Use takeUntil pattern for automatic cleanup
// Subject<void> — a destroy signal; void = we only care WHEN it fires, not the value
// WHY: Subject acts as a kill switch. next() in ngOnDestroy triggers all takeUntil operators.
private destroy$ = new Subject<void>();

ngOnInit() {
  this.service.data$
    // takeUntil() — unsubscribes when destroy$ emits (in ngOnDestroy)
    // WHY: Primary Angular memory-leak prevention pattern. No manual unsubscribe calls needed.
    .pipe(takeUntil(this.destroy$))
    .subscribe(data => this.data = data);
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

**3. Use trackBy in *ngFor**
```html
<!-- ✅ DO: Prevent unnecessary DOM recreation -->
<div *ngFor="let item of items; trackBy: trackById">
  {{ item.name }}
</div>
```

**4. Lazy Load Feature Modules**
```typescript
// ✅ DO: Load modules only when needed
const routes = [
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule),
    canLoad: [AuthGuard]  // Don't even download if not authorized!
  }
];
```

---

## Angular Signals — Reactive Primitives

> **Mental Model:**
> An RxJS Observable is a **river** — data flows through pipes, you subscribe at the bank and
> watch it pass. A Signal is a **whiteboard** — anyone can read the current value at any time,
> and Angular automatically knows which components need re-drawing when the value changes.

---

### What is a Signal?

A Signal is a **synchronous reactive value holder** introduced in Angular 16+.
It always holds a current value (unlike Observables which may never emit).
Angular's change-detection engine tracks which signals a template reads and
re-renders only those components when a signal changes — no `subscribe`, no
`async` pipe, no `takeUntil` needed.

```
┌────────────────────────────────────────────────────────────────────────────┐
│                    SIGNAL vs OBSERVABLE — CORE COMPARISON                  │
├────────────────────────┬───────────────────────┬───────────────────────────┤
│ Aspect                 │ Signal                 │ Observable (RxJS)         │
├────────────────────────┼───────────────────────┼───────────────────────────┤
│ Has a current value?   │ YES — always           │ NO — emits over time      │
│ Synchronous read?      │ YES — call signal()    │ NO — must subscribe       │
│ Lazy (cold)?           │ NO — always active     │ YES — cold until subscribed│
│ Operators (map/filter)?│ computed() only        │ Full RxJS operator library │
│ Async (HTTP, WS)?      │ NO — sync only         │ YES — built for async      │
│ subscribe() needed?    │ NO                     │ YES                       │
│ Memory leak risk?      │ NO — framework manages │ YES — must unsubscribe    │
│ Change detection       │ Fine-grained / zoneless│ Zone.js or markForCheck   │
│ Available since        │ Angular 16             │ Always (Angular 2+)       │
└────────────────────────┴───────────────────────┴───────────────────────────┘
```

---

### The Three Signal Primitives

```typescript
import { signal, computed, effect } from '@angular/core';

// ─────────────────────────────────────────────────────────────────────────────
// 1. signal(initialValue) — writable reactive value
// ─────────────────────────────────────────────────────────────────────────────
// WHY: Replace simple component state (boolean flags, primitive values, objects)
//      that used to be plain class fields + manual change detection.
const count = signal(0);           // WritableSignal<number>

count();                           // READ  — call it like a function → returns current value (0)
count.set(5);                      // WRITE — replace the value entirely
count.update(n => n + 1);          // UPDATE — derive new value from current (like setState)
count.mutate(arr => arr.push(item)); // MUTATE — for arrays/objects in-place (Angular 16/17)
// WHY .update() over .set(): when new value depends on old value (increment, toggle)
// WHY .mutate(): avoids spreading large arrays just to trigger reactivity

// ─────────────────────────────────────────────────────────────────────────────
// 2. computed(() => derivedValue) — read-only derived signal
// ─────────────────────────────────────────────────────────────────────────────
// WHY: Like a spreadsheet formula — auto-recalculates when dependencies change.
//      Angular memoizes the result — only recomputes when input signals change.
//      Equivalent to a BehaviorSubject derived via combineLatest + map in RxJS.
const doubled = computed(() => count() * 2);  // Signal<number> — read-only
const label   = computed(() =>
  count() === 0 ? 'empty' : `${count()} items`
);
// doubled() → 2 (if count is 1)
// WHY NOT a plain getter: plain getters recompute on EVERY read;
//   computed() recomputes ONLY when dependencies (count) change — memoized.

// ─────────────────────────────────────────────────────────────────────────────
// 3. effect(() => sideEffect) — runs when dependencies change
// ─────────────────────────────────────────────────────────────────────────────
// WHY: Run imperative side effects (logging, localStorage, DOM manipulation)
//      in response to signal changes — replaces ngOnChanges + manual subscription.
// IMPORTANT: effects run at least once immediately (reactive, like ngOnInit + watcher).
// IMPORTANT: do NOT update a signal inside an effect that reads it — infinite loop.
const logEffect = effect(() => {
  // Angular automatically tracks which signals are read inside here
  console.log('count changed to:', count());
  // WHY: every time count changes, this re-runs automatically
  // No subscribe, no unsubscribe — framework manages the lifecycle
});
// effects are destroyed when the enclosing component/injection context is destroyed
```

---

### Signals in Components — Full Example

```typescript
import { Component, signal, computed, effect, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { catchError, of, EMPTY, finalize } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

interface Product { id: number; name: string; price: number; }

@Component({
  selector: 'app-products',
  standalone: true,
  template: `
    <!-- Signals are read directly in templates — no async pipe needed       -->
    <!-- WHY no async pipe: signals are synchronous, always have a value     -->

    <p *ngIf="loading()">Loading...</p>

    <!-- errorMessage() reads the signal — template re-renders only when it changes -->
    <p *ngIf="errorMessage()" class="error">{{ errorMessage() }}</p>

    <!-- cartCount/cartTotal — derived via computed, update automatically    -->
    <p>Cart: {{ cartCount() }} items | Total: {{ cartTotal() | currency }}</p>

    <ul>
      <!-- products() reads the signal — only re-renders when products change -->
      <li *ngFor="let p of sortedProducts()">
        {{ p.name }} — {{ p.price | currency }}
        <button (click)="addToCart(p)">Add</button>
      </li>
    </ul>

    <button (click)="clearCart()">Clear Cart</button>
  `
})
export class ProductsComponent implements OnInit {

  // ── Writable signals — replace plain class fields ──────────────────────
  // WHY signal over plain field: Angular tracks reads in templates automatically
  //   and only re-renders this component when these specific values change.
  //   With plain fields + zone.js, Angular re-checks the WHOLE component tree.
  products     = signal<Product[]>([]);         // starts empty, filled after HTTP
  loading      = signal(false);                 // tracks HTTP in-flight state
  errorMessage = signal<string | null>(null);   // null = no error
  cart         = signal<Product[]>([]);         // items added to cart

  // ── Computed signals — derived state, auto-memoized ────────────────────
  // WHY computed: recalculates only when cart() changes, not on every render
  cartCount = computed(() => this.cart().length);
  cartTotal = computed(() =>
    // cart() — reading this signal makes cartTotal depend on cart
    this.cart().reduce((sum, p) => sum + p.price, 0)
  );

  // ── Expensive computed — Angular caches until dependency changes ────────
  sortedProducts = computed(() =>
    // products() — dependency tracked automatically
    [...this.products()].sort((a, b) => a.price - b.price)
    // WHY spread: computed must not mutate the original signal array
  );

  constructor(private http: HttpClient) {
    // effect() — side effect: sync cart to localStorage whenever it changes.
    // WHY in constructor (injection context): effects must be created inside an
    //   injection context (constructor, field initializer) — NOT in ngOnInit.
    effect(() => {
      // Reading cart() here registers it as a dependency of this effect
      localStorage.setItem('cart', JSON.stringify(this.cart()));
      // WHY: every time user adds/removes from cart, localStorage stays in sync.
      // No manual subscribe, no ngOnChanges watcher needed.
    });
  }

  ngOnInit(): void {
    this.loadProducts();
  }

  // ── HTTP call — still uses Observable/subscribe for async work ──────────
  // WHY still Observable here: Signals are synchronous — they cannot represent
  //   an HTTP request that hasn't completed yet. Use Observable for async work,
  //   then push the result INTO a signal once data arrives.
  loadProducts(): void {
    this.loading.set(true);       // signal.set() — update value
    this.errorMessage.set(null);  // clear previous error

    this.http.get<Product[]>('/api/products').pipe(
      // catchError in pipe — provides fallback [] if HTTP fails
      // WHY: sortedProducts() computed always receives an array — never null/undefined
      catchError((err) => {
        // Push error message INTO a signal — template reacts automatically
        this.errorMessage.set(`Failed to load products: ${err.message}`);
        return of([] as Product[]);  // fallback empty array
      }),
      // finalize — resets loading whether HTTP succeeded or failed
      // WHY finalize not complete callback: complete doesn't fire after error
      finalize(() => this.loading.set(false))
    ).subscribe({
      // next — bridge from async (Observable) to sync (Signal) via .set()
      // WHY .set() here: this is the only correct bridge between the two worlds
      next: products => this.products.set(products)
      // error will NOT fire — catchError above swallowed it and returned of([])
      // complete fires after next — finalize() above handles loading reset
    });
  }

  addToCart(product: Product): void {
    // update() — derive new value from current
    // WHY update over set: we need to read the current array to append to it
    this.cart.update(current => [...current, product]);
    // Angular detects cart changed → cartCount and cartTotal recompute automatically
  }

  clearCart(): void {
    this.cart.set([]);  // set() — replace entirely
    // cartCount() becomes 0, cartTotal() becomes 0 — no manual update needed
  }
}
```

---

### toSignal / toObservable — Bridging Signals and Observables

```typescript
import { toSignal, toObservable } from '@angular/core/rxjs-interop';
import { inject } from '@angular/core';
import { debounceTime, distinctUntilChanged, switchMap } from 'rxjs/operators';

// ─────────────────────────────────────────────────────────────────────────────
// toSignal() — convert an Observable INTO a Signal
// ─────────────────────────────────────────────────────────────────────────────
// WHY: you have an existing Observable (route params, store selector, HTTP)
//      but want to read it in a template without async pipe.
//      toSignal subscribes internally and unsubscribes when the injection context
//      (component) is destroyed — NO manual takeUntil needed.

@Component({ standalone: true, template: `<p>{{ userName() }}</p>` })
export class ProfileComponent {
  private route = inject(ActivatedRoute);
  private http  = inject(HttpClient);

  // Convert route queryParamMap Observable → Signal
  // WHY: template reads userName() synchronously — no async pipe, no subscribe
  // initialValue: what to return before the Observable emits its first value
  userName = toSignal(
    this.route.queryParamMap.pipe(
      map(params => params.get('name') ?? 'Guest')
    ),
    { initialValue: 'Guest' }
    // WHY initialValue: Signals must always have a value — toSignal needs
    //   a starting value for the moment before the Observable emits
  );

  // toSignal with HTTP Observable — simplest possible approach
  // WHY: removes subscribe + manual field assignment in ngOnInit entirely
  // Products is [] until HTTP resolves, then automatically updates
  products = toSignal(
    this.http.get<Product[]>('/api/products').pipe(
      catchError(() => of([] as Product[]))  // fallback inside pipe as usual
    ),
    { initialValue: [] as Product[] }
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// toObservable() — convert a Signal INTO an Observable
// ─────────────────────────────────────────────────────────────────────────────
// WHY: you have a signal (e.g. search input) but need RxJS operators like
//      debounceTime / switchMap that don't exist on signals.

@Component({ standalone: true })
export class SearchComponent {
  private http = inject(HttpClient);

  // User's search input as a signal — updated on every keystroke
  searchTerm = signal('');

  // Convert signal → Observable to access RxJS operators → back to Signal for template
  results = toSignal(
    toObservable(this.searchTerm).pipe(
      // debounceTime — wait 300ms after user stops typing before firing HTTP
      // WHY: without debounce, HTTP fires on every keystroke (expensive)
      debounceTime(300),

      // distinctUntilChanged — skip if value hasn't changed
      // WHY: prevents duplicate HTTP calls (user types then deletes to same value)
      distinctUntilChanged(),

      // switchMap — cancel previous HTTP call when new search term arrives
      // WHY: user types "ang" (HTTP starts), then "angu" → previous HTTP CANCELLED
      switchMap(term =>
        term.length < 2
          ? of([])   // don't search single characters
          : this.http.get<string[]>(`/api/search?q=${term}`).pipe(
              // catchError PER INNER OBSERVABLE — prevents switchMap stream dying on error
              // WHY here not outside: if catchError were outside switchMap, a single HTTP
              //   error would kill the ENTIRE search stream permanently
              catchError(() => of([] as string[]))
            )
      )
    ),
    { initialValue: [] as string[] }
  );
  // In template: results() → string[] — auto-updates as user types, no subscribe
}
```

---

### Error Handling with Signals — Three-State Pattern

```typescript
// ─────────────────────────────────────────────────────────────────────────────
// Three-state signal replaces boolean flag soup
// ─────────────────────────────────────────────────────────────────────────────
// ❌ WRONG (boolean flags) — can reach invalid states:
//    isLoading=true AND isError=true simultaneously — which wins in the template?
//    isLoading  = false;
//    isError    = false;
//    isSuccess  = false;

// ✅ CORRECT — discriminated union: only ONE valid state at a time
type LoadState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; message: string };

@Component({
  standalone: true,
  template: `
    <ng-container [ngSwitch]="state().status">
      <p *ngSwitchCase="'loading'">Loading...</p>
      <p *ngSwitchCase="'error'" class="error">{{ state().message }}</p>
      <ul *ngSwitchCase="'success'">
        <li *ngFor="let u of state().data">{{ u.name }}</li>
      </ul>
    </ng-container>
  `
})
export class UsersComponent implements OnInit {

  // Single signal — impossible to be in two states at once
  state = signal<LoadState<User[]>>({ status: 'idle' });

  // computed — derive boolean helpers so template stays readable
  // WHY computed: template uses isLoading() instead of state().status === 'loading'
  isLoading = computed(() => this.state().status === 'loading');
  hasError  = computed(() => this.state().status === 'error');

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.state.set({ status: 'loading' });  // single .set() replaces 3 boolean updates

    this.http.get<User[]>('/api/users').pipe(
      catchError((err: HttpErrorResponse) => {
        // Push error state INTO signal — template reacts immediately
        this.state.set({ status: 'error', message: `Error ${err.status}: ${err.message}` });
        // Return EMPTY — no next() fires, complete fires, subscribe stays clean
        // WHY EMPTY over of([]): we already set error state above; we don't want
        //   next() to overwrite it with { status: 'success', data: [] }
        return EMPTY;
      })
    ).subscribe({
      // next — only fires if catchError was NOT triggered (HTTP succeeded)
      next: users => this.state.set({ status: 'success', data: users }),
      // error will NOT fire — catchError returned EMPTY (swallowed the error)
      // complete fires after next — state already set, nothing to do
    });
  }
}
```

---

### Signals vs RxJS — When to Use Each

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DECISION GUIDE                                      │
└─────────────────────────────────────────────────────────────────────────────┘

Use SIGNALS for:                          Use OBSERVABLES (RxJS) for:
────────────────────────────────────────  ──────────────────────────────────────
✅ Component state (count, isOpen,        ✅ HTTP calls (async, one-shot)
   selectedTab, formMode)                ✅ WebSockets (long-lived streams)
✅ Derived/computed values                ✅ Route params / queryParams
   (total, filteredList, label)          ✅ User events (debounce + switchMap)
✅ Sharing state between components       ✅ Polling with interval()
   via a service (replaces BehaviorSubject✅ Combining multiple async sources
   for simple shared values)                 (combineLatest, forkJoin)
✅ Simple synchronous reactive UI         ✅ Complex operator chains
✅ Zoneless Angular (signal-based CD)         (retry, throttle, buffer, audit)

Use BOTH (bridge with toSignal / toObservable):
  ✅ HTTP call → subscribe → signal.set()            async source, sync result
  ✅ toSignal(http.get(...))                          no subscribe in component
  ✅ toObservable(signal) → debounce → switchMap      signal drives async pipeline
```

---

### Interview Questions You'll Be Asked

**Q: How do you prevent memory leaks in React vs Angular?**

```tsx
// React: Cleanup function
useEffect(() => {
  const sub = subscription.subscribe(...);
  return () => sub.unsubscribe();  // ← Critical for cleanup
}, []);
```

```typescript
// Angular: takeUntil pattern
private destroy$ = new Subject<void>();

constructor(private service: Service) {}

ngOnInit() {
  this.service.data$
    .pipe(takeUntil(this.destroy$))  // ← Auto-unsubscribe
    .subscribe(...);
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

**Q: What's OnPush change detection and why use it?**

Angular has two change detection strategies:
- **Default**: Checks entire component tree on every event (slower)
- **OnPush**: Only checks when @Input changes or event fires (faster)

Use OnPush for performance: checking 1000 components on every event = slow app.

**Q: How do you handle large lists?**

```tsx
// React: Virtual scrolling with react-window
<FixedSizeList height={400} itemCount={items.length}>
  {({index}) => <div>{items[index]}</div>}
</FixedSizeList>

// Angular: CDK virtual scroll + trackBy
<cdk-virtual-scroll-viewport itemSize="50">
  <div *ngFor="let item of items; trackBy: trackById">
    {{ item.name }}
  </div>
</cdk-virtual-scroll-viewport>
```

### When to Use React vs Angular

**Use React when:**
- ✅ You need maximum flexibility
- ✅ Your team is strong in JavaScript
- ✅ Building smaller to medium-sized apps
- ✅ You want to pick your own tooling

**Use Angular when:**
- ✅ You need a complete, integrated framework
- ✅ Building large enterprise applications
- ✅ Your team is strong in TypeScript & OOP
- ✅ You want everything built-in (forms, routing, HTTP, DI)
- ✅ You need strict structure and consistency

---

## Getting Started Commands

```bash
# Angular CLI
npm install -g @angular/cli
ng new my-app --routing --style=scss
cd my-app

# Add essentials
ng add @angular/material
ng add @ngrx/store
ng add @ngrx/effects
ng add @ngrx/store-devtools

# Generate
ng generate component features/auth/components/login
ng generate service core/services/auth
ng generate guard core/guards/auth
ng generate pipe shared/pipes/file-size
ng generate directive shared/directives/highlight
ng generate module features/admin --routing

# Build & Run
ng serve
ng build --configuration production
ng test
ng e2e
```

---

## Common Pitfalls When Transitioning React → Angular

### Pitfall #1: Forgetting to Unsubscribe from Observables

**❌ Problem:**
```typescript
ngOnInit() {
  this.service.data$.subscribe(data => {
    this.data = data;
  });
  // No unsubscribe = memory leak!
}
```

**✅ Solution:**
```typescript
private destroy$ = new Subject<void>();

ngOnInit() {
  this.service.data$.pipe(
    takeUntil(this.destroy$)  // Auto-unsubscribe
  ).subscribe(data => this.data = data);
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

### Pitfall #2: Using Default Change Detection with Large Lists

**❌ Problem:**
```typescript
// Checks ENTIRE component tree on every mouse move, click, etc.
@Component({...})
export class MyList {
  items: Item[] = new Array(10000); // Slow!
}
```

**✅ Solution:**
```typescript
// Only checks when @Input changes or event fires
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class MyList {
  @Input() items: Item[] = [];
}

// + use trackBy in template
<div *ngFor="let item of items; trackBy: trackById">
  {{ item.name }}
</div>
```

### Pitfall #3: Not Using trackBy in *ngFor

**❌ Problem:**
```html
<!-- Recreates DOM for ALL items when list changes -->
<div *ngFor="let item of items">
  {{ item.name }}
</div>
<!-- 1000 items change → DOM recreated 1000 times = slow! -->
```

**✅ Solution:**
```typescript
// In component
trackById = (index: number, item: Item) => item.id;
```

```html
<!-- Only recreates changed items -->
<div *ngFor="let item of items; trackBy: trackById">
  {{ item.name }}
</div>
```

### Pitfall #4: Not Using Lazy Loading for Feature Modules

**❌ Problem:**
```typescript
// Entire app (including admin) downloads on app start
// If user isn't admin = wasted bandwidth & slower startup
@NgModule({
  imports: [
    AdminModule,  // Downloaded immediately
    UsersModule,
    SettingsModule
  ]
})
export class AppModule { }
```

**✅ Solution:**
```typescript
const routes = [
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.module')
      .then(m => m.AdminModule),
    canLoad: [AuthGuard]  // Only download if authorized
  }
];
```

### Pitfall #5: Treating Angular Components Like React Components

**❌ React Thinking (Wrong in Angular):**
```typescript
// React style - treating everything as data
export class UserList implements OnInit {
  users = [];

  ngOnInit() {
    this.users = this.service.getUsers();  // Missing: Observable!
  }
}
```

**✅ Angular Thinking:**
```typescript
// Angular style - use Observables throughout
export class UserList {
  users$ = this.service.users$;  // Observable, never subscribe!

  constructor(private service: UserService) {}
}
```

```html
<!-- Use async pipe - automatic subscription management -->
<div *ngFor="let user of users$ | async">
  {{ user.name }}
</div>
<!-- Automatically unsubscribes on destroy! No memory leaks! -->
```

### Pitfall #6: Prop Drilling (React Problem, Avoid in Angular Too)

**❌ Problem (More of React issue, but bad pattern everywhere):**
```typescript
// Pass token through many component levels
Parent → Child → GrandChild → GrandGrandChild
```

**✅ Solution (Use Services + DI):**
```typescript
// Inject service directly where needed - no prop drilling!
constructor(private authService: AuthService) {
  authService.token$.subscribe(token => ...);
}
```

### Pitfall #7: Not Understanding RxJS Operators

**❌ Problem:**
```typescript
// Subscribes to observable inside another subscription
// = nested callbacks (callback hell)
this.users$ = this.userService.getUsers().subscribe(users => {
  this.posts$ = this.postsService.getPosts().subscribe(posts => {
    // nested subscription hell
  });
});
```

**✅ Solution (Use switchMap, mergeMap, etc):**
```typescript
// Flat observable chain - no nesting!
this.data$ = this.userService.getUsers().pipe(
  // switchMap() — cancels previous inner observable and switches to new one
  // WHY: Flattens the nested subscription into a single stream. No callback hell.
  //      The users result is available in the outer scope, and we can use it if needed.
  //      Use concatMap instead if you need to process users before fetching posts.
  switchMap(users => this.postsService.getPosts()),
  // Posts data flows through, never nested
);
```

### Pitfall #8: Not Using Interfaces/Types

**❌ Problem:**
```typescript
getUser(id: any) {  // ← any = no type safety!
  return this.http.get('/users/' + id);  // Typo?
}

// Usage
user = this.service.getUser(123);
console.log(user.naaaame);  // Typo not caught until runtime!
```

**✅ Solution:**
```typescript
interface User {
  id: number;
  name: string;
  email: string;
}

getUser(id: number): Observable<User> {  // ← Explicit types
  return this.http.get<User>(`/users/${id}`);
}

// Usage
user$ = this.service.getUser(123);
// user.naaaame ← TypeScript catches typo immediately!
```

### Quick Migration Checklist

```
[ ] Installed Angular CLI: $ npm install -g @angular/cli
[ ] Created new project: $ ng new my-app --routing
[ ] Understand NgModules (no React parallel)
[ ] Understand @Input/@Output (props + callbacks)
[ ] Understand Dependency Injection (services)
[ ] Learn RxJS basics (Observables, operators)
[ ] Setup HTTP interceptors (like axios interceptors)
[ ] Setup guards (like route protection middleware)
[ ] Setup state management (NgRx or similar)
[ ] Always use OnPush change detection
[ ] Always use trackBy in *ngFor  
[ ] Always unsubscribe from Observables
[ ] Always lazy-load feature modules
[ ] Always use async pipe in template when possible
```

---

*This guide provides a comprehensive comparison for React developers transitioning to Angular. The patterns and practices shown here represent production-ready approaches used in enterprise applications.*

**Key Takeaway**: Angular is stricter but more powerful. React gives you freedom but requires discipline. Both are excellent frameworks - pick based on your project needs and team expertise.




# Angular Complete Mindmap — All Phases Quick Reference

> **Purpose:** One-file visual brain-dump to recall every Angular concept across all phases. Use this for revision, interviews, and mental model building.
> **Format:** Tree → bullets → tables → quick insights. No long code — just the "what, why, key rules."

---

## TABLE OF CONTENTS

| # | Topic | Phase |
|---|-------|-------|
| 1 | [Foundation — JS ES6+ & TypeScript](#1-foundation--js-es6--typescript) | Ph 1 |
| 2 | [Project Setup & CLI](#2-project-setup--cli) | Ph 2 |
| 3 | [Core Concepts — Components, Binding, Directives, Pipes](#3-core-concepts) | Ph 3 |
| 4 | [Component Communication](#4-component-communication) | Ph 4 |
| 5 | [Services & Dependency Injection](#5-services--dependency-injection) | Ph 5 |
| 6 | [Routing & Navigation](#6-routing--navigation) | Ph 6 |
| 7 | [Forms](#7-forms) | Ph 7 |
| 8 | [HTTP & API Communication](#8-http--api-communication) | Ph 8 |
| 9 | [RxJS & Observables](#9-rxjs--observables) | Ph 9 |
| 10 | [State Management](#10-state-management) | Ph 10 |
| 11 | [Modules & Standalone Architecture](#11-modules--standalone-architecture) | Ph 11 |
| 12 | [Signals & Modern Reactivity](#12-signals--modern-reactivity) | Ph 12 |
| 13 | [Change Detection & Performance](#13-change-detection--performance) | Ph 13 |
| 14 | [Angular Material](#14-angular-material) | Ph 14 |
| 15 | [Testing](#15-testing) | Ph 15 |
| 16 | [Animations](#16-animations) | Ph 16 |
| 17 | [i18n & Localization](#17-i18n--localization) | Ph 17 |
| 18 | [Security](#18-security) | Ph 18 |
| 19 | [SSR & Angular Universal](#19-ssr--angular-universal) | Ph 19 |
| 20 | [Advanced Patterns & Architecture](#20-advanced-patterns--architecture) | Ph 20 |
| 21 | [Build, Deploy & DevOps](#21-build-deploy--devops) | Ph 21 |
| 22 | [Angular New Features v14–v19](#22-angular-new-features-v14v19) | Ph 22 |
| 23 | [NG Bootstrap](#23-ng-bootstrap) | Ph 23 |
| 24 | [Performance Optimization](#24-performance-optimization) | Ph 24 |

---

## 1. Foundation — JS ES6+ & TypeScript

```
FOUNDATION
├── JavaScript ES6+
│   ├── let / const          ← block-scoped; never use var
│   ├── Arrow functions      ← inherit `this` from enclosing scope
│   ├── Template literals    ← `Hello ${name}` | multi-line strings
│   ├── Destructuring        ← const { a, b } = obj | [x, y] = arr
│   ├── Spread / Rest        ← {...obj, key: val} (immutable update) | ...args
│   ├── Promises / async-await ← async fn + await + try/catch
│   ├── import / export      ← named: { fn } | default: fn | *: all
│   └── Array methods        ← map / filter / find / reduce / some / every
│
└── TypeScript
    ├── Primitives           ← string | number | boolean | null | undefined
    ├── Arrays               ← string[] or Array<string>
    ├── Tuple / Enum / any / unknown / void / never
    ├── Interfaces           ← shape contract; optional ?, readonly
    ├── Classes              ← public/private/protected/readonly access
    │   └── Shorthand DI     ← constructor(private svc: SvcType) {}
    ├── Generics             ← <T> placeholder; HttpClient.get<User[]>()
    ├── Decorators           ← @Component @Injectable @NgModule @Input @Output
    └── Union / Alias        ← type Status = 'active'|'inactive'
```

**Quick rules:**
- `const` for objects/arrays you don't reassign; `let` for primitives that change
- Arrow functions fix `this` in callbacks (critical in RxJS)
- Prefer `unknown` over `any` — forces type check before use
- Interfaces = contracts; Classes = blueprints (Angular components are classes)

---

## 2. Project Setup & CLI

```
SETUP
├── Install           npm install -g @angular/cli
├── Create            ng new my-app  (→ routing? Yes | CSS/SCSS?)
├── Serve             ng serve -o   (port 4200, live-reload)
├── Build             ng build --configuration=production
├── Test              ng test
└── Generate
    ├── Component     ng g c header
    ├── Service       ng g s user
    ├── Module        ng g m products --route products --module app
    ├── Guard         ng g guard auth
    ├── Pipe          ng g p truncate
    └── Directive     ng g d highlight
```

**Project file map:**

| File | Role |
|------|------|
| `src/index.html` | Single HTML page — `<app-root>` lives here |
| `src/main.ts` | Bootstrap entry: `bootstrapModule(AppModule)` |
| `src/app/app.module.ts` | Root NgModule — declarations, imports, providers |
| `src/app/app.component.ts` | Root component — selector `app-root` |
| `angular.json` | CLI config — styles, scripts, build targets |
| `tsconfig.json` | TS compiler — `experimentalDecorators: true` is key |

**Boot sequence:**
```
index.html → main.ts → AppModule → bootstrap: [AppComponent]
           → finds <app-root> → renders AppComponent template
```

---

## 3. Core Concepts

### 3A. Components

```
COMPONENT = Class (.ts) + Template (.html) + Styles (.css)
├── @Component({ selector, templateUrl, styleUrls })
├── Selector types:  element | [attribute] | .class
└── Lifecycle Hooks (in order):
    constructor        → DI only, no data fetching
    ngOnChanges        → fires when @Input() values change (has SimpleChanges)
    ngOnInit ★         → FETCH DATA HERE (runs once, after inputs set)
    ngDoCheck          → every CD cycle (expensive, avoid)
    ngAfterContentInit → <ng-content> ready
    ngAfterViewInit    → component's own view ready
    ngOnDestroy ★      → CLEAN UP (unsubscribe, clear timers)
```

> **Key rule:** Use `ngOnInit` for init logic, not `constructor`. Use `ngOnDestroy` for cleanup.

---

### 3B. Data Binding

```
DATA BINDING TYPES
│
├── {{ expression }}      ← Interpolation   — Class → View  (string display)
├── [property]="expr"     ← Property Bind   — Class → View  (any type, DOM props)
├── (event)="handler()"  ← Event Bind      — View  → Class ($event = DOM event)
└── [(ngModel)]="prop"   ← Two-Way Bind    — Both  ↔       (requires FormsModule)
```

| Syntax | Direction | Example | Use When |
|--------|-----------|---------|----------|
| `{{ val }}` | → | `{{ user.name }}` | Display strings |
| `[src]="url"` | → | `<img [src]="imgUrl">` | Non-string props, booleans |
| `(click)="fn()"` | ← | `<button (click)="save()">` | User events |
| `[(ngModel)]="x"` | ↔ | `<input [(ngModel)]="search">` | Form inputs, live sync |

> **Banana in a box:** `[()]` = `[ngModel]` + `(ngModelChange)` combined.

---

### 3C. Directives

```
DIRECTIVES
├── Structural (change DOM)      ← * prefix
│   ├── *ngIf="cond"            ← removes/adds element; else #tpl
│   ├── *ngFor="let x of arr"   ← index, first, last, even, odd; trackBy
│   └── [ngSwitch] / *ngSwitchCase / *ngSwitchDefault
│
├── Attribute (change appearance)  ← no *
│   ├── [ngClass]="{ 'cls': bool }"
│   ├── [ngStyle]="{ 'color': val }"
│   └── Custom: @Directive({ selector: '[appHighlight]' })
│              ElementRef | @HostListener | @Input
│
└── Components — directives WITH a template
```

**`*ngIf` vs `[hidden]`:**
- `*ngIf false` → removes from DOM (runs `ngOnDestroy`; resets state)
- `[hidden]` → CSS `display:none` (keeps DOM; preserves state)

**`trackBy` rule:** Always use for lists that change; prevents full DOM recreation.

```html
*ngFor="let p of products; trackBy: trackById"
trackById(index, item) { return item.id; }
```

---

### 3D. Pipes

```
PIPES  →  value | pipeName:arg1:arg2
│
├── String:    uppercase | lowercase | titlecase
├── Date:      date | date:'dd/MM/yyyy' | date:'short'
├── Number:    number:'1.2-2' | currency:'USD' | percent
├── Object:    json (debug!) | keyvalue | slice:0:3
│
└── Custom:    @Pipe({ name: 'truncate' })
               transform(value: string, limit = 50): string
```

| Pure (default) | Impure (`pure: false`) |
|---|---|
| Runs only when input reference changes | Runs every CD cycle |
| Fast — use by default | Slow — use sparingly |
| Misses array.push() mutations | Catches mutations |
| Fix: spread new array `[...arr, item]` | Fix: prefer pure with immutable updates |

**Chaining:** `{{ date | date:'fullDate' | uppercase }}`

---

### 3E. Template Helpers

| Element | Purpose |
|---------|---------|
| `<ng-template #ref>` | Invisible block; renders only when referenced |
| `<ng-container>` | Invisible wrapper — no extra DOM element |
| `<ng-content>` | Slot for projected content (like slots in web components) |

> Use `ng-container` when you need two structural directives on the "same" element (not allowed directly).

---

## 4. Component Communication

```
COMMUNICATION PATTERNS
│
├── Parent → Child       @Input()  propertyName
├── Child → Parent       @Output() event = new EventEmitter<T>()
│                        parent listens: (event)="handler($event)"
│
├── Parent → Child       @ViewChild(ChildComp)  child!: ChildComp
│  (direct access)       ready in ngAfterViewInit
│                        @ViewChildren → QueryList<T>
│
├── Content Projection   <ng-content>  (child defines slots)
│   (slot pattern)       @ContentChild / @ContentChildren
│
└── Sibling / Any        Shared Service + BehaviorSubject (see Ph 10)
    (via service)        OR NgRx Store (see Ph 10)
```

**Decision tree:**
```
Direct parent-child?  →  @Input / @Output
Need child's method?  →  @ViewChild
Unrelated / distant?  →  Service (BehaviorSubject) or NgRx
Slot content?         →  ng-content
```

---

## 5. Services & Dependency Injection

```
SERVICES
├── @Injectable({ providedIn: 'root' })  ← singleton, app-wide
├── @Injectable({ providedIn: 'any' })   ← new instance per lazy module
│
└── DI Hierarchy (inner shadows outer):
    root injector → module injector → component injector
    (component-level: provide in @Component.providers — not singleton!)
```

**Key patterns:**
```
constructor(private userService: UserService) {}   ← inject via constructor
inject(UserService)                                 ← functional injection (v14+)
```

**Providers tokens:**
```
{ provide: TOKEN, useClass: Impl }         ← swap implementation
{ provide: TOKEN, useValue: value }        ← inject constants
{ provide: TOKEN, useFactory: fn, deps: [DEP] }
{ provide: TOKEN, useExisting: other }     ← alias
```

---

## 6. Routing & Navigation

```
ROUTING
├── Setup
│   ├── RouterModule.forRoot(routes)   ← once, in AppRoutingModule
│   ├── RouterModule.forChild(routes)  ← in feature modules
│   └── provideRouter(routes)          ← standalone apps
│
├── Route config keys
│   ├── path, component, redirectTo, pathMatch
│   ├── children: []                   ← nested router-outlet in parent
│   ├── data: { title: 'X' }          ← static data
│   ├── canActivate, canDeactivate, resolve, canLoad
│   └── loadChildren / loadComponent  ← lazy load
│
├── Template
│   ├── <router-outlet>                ← where components render
│   ├── routerLink="/about"            ← no page reload (vs href)
│   └── routerLinkActive="active"      ← CSS class when active
│       [routerLinkActiveOptions]="{ exact: true }"  ← exact match
│
├── Route params
│   ├── Path:  /products/:id           → route.snapshot.paramMap.get('id')
│   │                                    route.paramMap.subscribe(...)
│   └── Query: /products?page=2        → route.snapshot.queryParamMap.get('page')
│
└── Programmatic: this.router.navigate(['/products', id], { queryParams: { x: 1 }})
```

**Guards quick reference:**

| Guard | When Runs | Use For |
|-------|-----------|---------|
| `CanActivate` / `canActivateFn` | Before entering | Auth check |
| `CanActivateChild` | Before child route | Protect all children |
| `CanDeactivate` | Before leaving | Unsaved changes warning |
| `Resolve` | Before route loads | Pre-fetch data |
| `CanLoad` | Before lazy module download | Don't even download if unauthorized |

**Lazy loading:**
```typescript
loadChildren: () => import('./products/products.module').then(m => m.ProductsModule)
loadComponent: () => import('./page.component').then(c => c.PageComponent)  // standalone
```

**`pathMatch`:** Always `'full'` for empty-path redirects; `'prefix'` is default (matches everything).

---

## 7. Forms

```
FORMS — Two systems
│
├── TEMPLATE-DRIVEN (simple forms)
│   ├── Import FormsModule
│   ├── Use [(ngModel)]="field" on inputs
│   ├── #f="ngForm" on <form>  →  f.valid / f.value
│   ├── #input="ngModel"       →  input.valid / input.touched
│   └── Validators via attributes: required, minlength="3", email
│
└── REACTIVE (complex / dynamic forms)
    ├── Import ReactiveFormsModule
    ├── FormControl('initialValue', [Validators.required])
    ├── FormGroup({ name: new FormControl(), email: new FormControl() })
    ├── FormArray  ← dynamic list of controls
    ├── FormBuilder ← shorthand: fb.group({ name: ['', Validators.required] })
    ├── Template: [formGroup]="form" | formControlName="name"
    └── Validators:
        built-in: required, min, max, minLength, maxLength, pattern, email
        custom:   fn(control) => ValidationErrors | null
        async:    fn(control) => Observable<ValidationErrors | null>
```

**Comparison:**

| Feature | Template-Driven | Reactive |
|---------|----------------|---------|
| Logic in | HTML template | TypeScript class |
| Testability | Harder | Easy (pure functions) |
| Dynamic controls | Difficult | Easy (FormArray) |
| Validation | HTML attrs | Code |
| Best for | Simple login/search | Complex multi-step, dynamic |

**Control state flags:** `valid / invalid / pristine / dirty / touched / untouched / pending`

**Cross-field validator:** attach to `FormGroup`, not individual control.

---

## 8. HTTP & API Communication

```
HTTP
├── Setup: provideHttpClient() (standalone) OR import HttpClientModule
├── Inject: constructor(private http: HttpClient) {}
│
├── Methods → return Observable<T>
│   ├── http.get<User[]>('/api/users')
│   ├── http.post<User>('/api/users', body)
│   ├── http.put('/api/users/1', body)
│   ├── http.patch('/api/users/1', partial)
│   └── http.delete('/api/users/1')
│
├── Options
│   ├── headers: new HttpHeaders({ 'Authorization': 'Bearer ...' })
│   ├── params:  new HttpParams().set('page', '1')
│   ├── responseType: 'text' | 'blob' | 'arraybuffer'
│   └── observe: 'response' (full HttpResponse) | 'events'
│
├── Interceptors (cross-cutting concerns)
│   ├── ng g interceptor auth
│   ├── Intercept request: add auth token
│   ├── Intercept response: global error handling
│   └── Register: provideHttpClient(withInterceptors([authInterceptorFn]))
│
└── Error Handling
    ├── pipe(catchError(err => throwError(() => err)))
    ├── pipe(retry(3))
    └── HttpErrorResponse.status  (400, 401, 403, 404, 500)
```

**Interceptor mental model:** Middleware for HTTP. One interceptor → auth. Another → logging. Another → loading spinner.

---

## 9. RxJS & Observables

```
RXJS — Streams of data over time
│
├── Core concepts
│   ├── Observable  = stream definition (lazy — nothing happens until subscribe)
│   ├── Observer    = { next, error, complete }
│   ├── Subscription = handle to stop stream (.unsubscribe())
│   └── Subject     = Observable + Observer (can emit AND be subscribed to)
│
├── Subject types
│   ├── Subject              ← no initial value; only future subscribers get values
│   ├── BehaviorSubject(val) ← has initial; new subscribers get LAST value ★ most used
│   ├── ReplaySubject(n)     ← replays last n values to new subscribers
│   └── AsyncSubject         ← only emits last value on complete
│
├── Creation operators
│   of(1,2,3)           interval(1000)    timer(2000)
│   from(array/promise) fromEvent(el, 'click')
│   combineLatest([a$, b$])   forkJoin([a$, b$])   zip([a$, b$])
│   merge(a$, b$)   concat(a$, b$)   EMPTY   NEVER
│
├── Transform operators (most important)
│   ├── map(x => x*2)            ← transform each value
│   ├── filter(x => x > 0)       ← keep matching values
│   ├── tap(x => log(x))         ← side-effect, pass through
│   ├── switchMap(x => obs$)     ← cancel prev, start new ★ (search, navigation)
│   ├── mergeMap(x => obs$)      ← run all concurrently (upload files)
│   ├── concatMap(x => obs$)     ← queue sequentially (order matters)
│   ├── exhaustMap(x => obs$)    ← ignore new until current completes (login btn)
│   ├── debounceTime(300)        ← wait for silence (autocomplete)
│   ├── distinctUntilChanged()   ← only emit if value changed
│   ├── throttleTime(1000)       ← max 1 emit per second
│   ├── take(n)                  ← complete after n values
│   ├── takeUntil(stop$)         ← complete when stop$ emits ★ cleanup
│   ├── takeUntilDestroyed()     ← v16+ auto cleanup (inject DestroyRef)
│   ├── startWith(val)           ← prepend initial value
│   ├── scan((acc, val) => ...)  ← running accumulator
│   └── shareReplay(1)           ← multicast + replay (cache HTTP)
│
└── Error handling
    catchError(err => of(fallback))
    retry(3)
    retryWhen(errors$ => errors$.pipe(delay(1000)))
```

**flatMap cheatsheet:**

| Operator | Inner obs behavior | Use case |
|----------|-------------------|----------|
| `switchMap` | Cancel previous | Search-as-you-type, route changes |
| `mergeMap` | Run all at once | Parallel uploads |
| `concatMap` | Wait for previous | Sequential operations |
| `exhaustMap` | Ignore new | Login, prevent double-submit |

**Memory leak rule:** Always unsubscribe. Use `takeUntilDestroyed()`, `async pipe`, or `takeUntil(destroy$)`.

---

## 10. State Management

```
STATE TYPES
├── UI State        → component properties (isOpen, activeTab)
├── Form State      → Reactive Forms controls
├── URL State       → Router (query params, path params)
├── Server State    → HttpClient responses
└── Client State    → across components (cart, user session)

STATE SOLUTIONS (by complexity)
│
├── Component props          ← 1-2 components, no sharing needed
├── @Input/@Output           ← direct parent-child sharing
├── Service + BehaviorSubject ← shared across siblings/unrelated ★ most common
├── NgRx                     ← large app, team, time-travel debug
└── Signals (v17+)           ← modern, fine-grained reactivity
```

**NgRx flow:**
```
Action → Reducer → State (Store)
             ↑           ↓
           Effect    Selector → Component
             ↓
          HTTP / Side Effect
```

**NgRx key concepts:**

| Concept | Role | Location |
|---------|------|---------|
| `Action` | "What happened" event | actions/*.actions.ts |
| `Reducer` | Pure fn: (state, action) → newState | reducers/*.reducer.ts |
| `Selector` | Derive/slice state | selectors/*.selectors.ts |
| `Effect` | Side effects (HTTP, routing) | effects/*.effects.ts |
| `Store` | Single source of truth | Injectable service |
| `Entity` | Normalized CRUD state | EntityAdapter |

---

## 11. Modules & Standalone Architecture

```
NgModule (traditional)
├── @NgModule({
│     declarations: [/* components, directives, pipes I OWN */],
│     imports:      [/* other modules I need */],
│     providers:    [/* services */],
│     exports:      [/* what others can use from me */],
│     bootstrap:    [AppComponent]  // root only
│   })
│
├── Types:
│   ├── Root (AppModule)       ← one per app, has bootstrap
│   ├── Feature (ProductsModule) ← domain grouping, lazy loadable
│   ├── Shared (SharedModule)  ← reusable components/pipes/directives
│   └── Core (CoreModule)      ← singletons (guards, interceptors); import once

Standalone (v15+ stable) ★ Modern approach
├── @Component({ standalone: true, imports: [NgIf, NgFor, ReactiveFormsModule] })
├── No NgModule needed
├── Bootstrap: bootstrapApplication(AppComponent, appConfig)
└── Config: provideRouter(), provideHttpClient(), provideAnimations()
```

**Feature folder structure:**
```
src/app/
├── core/               ← app-level singletons
├── shared/             ← reusable components/pipes/directives
├── features/
│   ├── products/       ← feature module (lazy loaded)
│   │   ├── components/
│   │   ├── services/
│   │   ├── models/
│   │   └── products.routes.ts
│   └── orders/
└── app.routes.ts
```

---

## 12. Signals & Modern Reactivity

```
SIGNALS — Fine-grained, synchronous reactivity (v16 preview → v17/18 stable)
│
├── signal(value)          ← writable signal (like ref in Vue)
│   count.set(5)           ← replace value
│   count.update(v => v+1) ← transform value
│   count()                ← read value (call it like a function)
│
├── computed(() => expr)   ← derived, read-only, auto-updates
│   doubleCount = computed(() => count() * 2)
│
├── effect(() => { ... })  ← side-effect on signal change (like useEffect)
│
├── input() / output()     ← v17+ signal-based @Input / @Output
│   name = input<string>('default')
│   clicked = output<void>()
│
├── toSignal(obs$)         ← convert Observable → Signal
└── toObservable(sig)      ← convert Signal → Observable
```

**Signal vs Observable:**

| Aspect | Signal | Observable |
|--------|--------|-----------|
| Sync/Async | Synchronous | Async |
| Subscription | No need to subscribe | Must subscribe |
| Memory leak | No leak risk | Must unsubscribe |
| Best for | UI state, computed values | HTTP, events, time-based |

**Zoneless (v18+ experimental):**
```typescript
bootstrapApplication(AppComponent, {
  providers: [provideZonelessChangeDetection()]
})
```
Removes Zone.js → smaller bundle, faster apps.

---

## 13. Change Detection & Performance

```
CHANGE DETECTION
│
├── Zone.js (default)
│   ├── Monkey-patches all async APIs (setTimeout, fetch, events)
│   ├── Notifies Angular "something may have changed"
│   └── Angular walks ENTIRE tree → checks every component
│
├── Strategies
│   ├── Default (CheckAlways)  ← check every component, every CD cycle
│   └── OnPush ★               ← check ONLY when:
│       ├── @Input() reference changes (not mutation!)
│       ├── Component's event fires (click, input)
│       ├── async pipe emits
│       └── markForCheck() / detectChanges() called manually
│
├── Manual control
│   ├── ChangeDetectorRef.markForCheck()   ← schedule check on this + ancestors
│   ├── ChangeDetectorRef.detectChanges()  ← check this component NOW (sync)
│   └── ChangeDetectorRef.detach()         ← remove from tree entirely
│
└── Immutability rule for OnPush:
    ✗ this.items.push(x)          ← same reference, OnPush won't see it
    ✓ this.items = [...this.items, x]  ← new reference, OnPush detects
```

**Performance checklist:**
- `ChangeDetectionStrategy.OnPush` on all leaf components
- `trackBy` on every `*ngFor`
- `async` pipe instead of manual subscriptions
- Pure pipes for transforms
- `shareReplay(1)` for shared HTTP Observable

---

## 14. Angular Material

```
ANGULAR MATERIAL (Material Design components)
│
├── Install: ng add @angular/material  (picks theme, animations)
│
├── Components (import per module or standalone)
│   ├── Layout:   MatToolbar, MatSidenav, MatCard, MatGrid
│   ├── Inputs:   MatInput, MatSelect, MatCheckbox, MatRadio, MatSlider
│   ├── Buttons:  mat-button | mat-raised-button | mat-icon-button
│   ├── Data:     MatTable + MatSort + MatPaginator, MatList
│   ├── Overlay:  MatDialog, MatSnackBar, MatBottomSheet, MatMenu
│   ├── Nav:      MatTabs, MatStepperModule, MatExpansionPanel
│   └── Display:  MatBadge, MatChips, MatProgressBar/Spinner, MatTooltip
│
├── CDK (Component Dev Kit — lower level)
│   ├── DragDropModule     ← drag and drop lists
│   ├── OverlayModule      ← custom popups
│   └── ScrollingModule    ← virtual scroll (CdkVirtualScrollViewport)
│
└── Theming
    ├── Prebuilt: indigo-pink, deeppurple-amber, pink-bluegrey, purple-green
    ├── Custom: define-palette + create-light-theme + include-theme mixin
    └── CSS Variables (M3, v18+)
```

---

## 15. Testing

```
TESTING LEVELS
├── Unit Tests (Jasmine + Karma)
│   ├── TestBed.configureTestingModule({ declarations, imports, providers })
│   ├── fixture = TestBed.createComponent(MyComponent)
│   ├── component = fixture.componentInstance
│   ├── fixture.detectChanges()   ← trigger CD
│   ├── fixture.nativeElement.querySelector(...)  ← DOM assertions
│   └── Mocks: spyOn(service, 'method').and.returnValue(of(data))
│
├── Service Tests
│   ├── TestBed with HttpClientTestingModule
│   ├── HttpTestingController.expectOne('/api/url')
│   └── req.flush(mockData)
│
└── E2E Tests
    ├── Cypress (most popular)     ← cy.visit(), cy.get(), cy.click()
    └── Playwright                 ← cross-browser, MS backed
```

**Test anatomy:**
```
describe('ComponentName', () => {
  beforeEach(() => { /* setup */ })
  it('should do X', () => {
    // Arrange → Act → Assert
    expect(component.value).toBe(expected)
  })
})
```

**Spy patterns:**
```
spyOn(service, 'getUsers').and.returnValue(of([]))     // stub
spyOn(service, 'save').and.callThrough()               // real call
jasmine.createSpyObj('Router', ['navigate'])            // full mock
```

---

## 16. Animations

```
ANGULAR ANIMATIONS (@angular/animations)
│
├── Setup: provideAnimations() or BrowserAnimationsModule
│         in @Component: animations: [trigger('name', [...])]
│
├── Core functions
│   ├── trigger('name', [...])      ← declare animation
│   ├── state('active', style({...}))  ← named state with styles
│   ├── transition('void => *', [...]) ← :enter  (element appears)
│   ├── transition('* => void', [...]) ← :leave  (element disappears)
│   ├── transition('a => b', [...])   ← state A to state B
│   ├── animate('300ms ease-in', style({...}))  ← duration + easing + target
│   ├── keyframes([style({offset:0}), style({offset:1})])
│   ├── group([...])    ← parallel animations
│   ├── sequence([...]) ← sequential animations
│   └── query(':enter', [animate(...)]) ← animate children
│
└── Template usage
    <div [@triggerName]="stateProp">...</div>
    <div [@.disabled]="true">← disable animation</div>
```

**Common transitions:**
```
void => *   (enter/fade-in)   style({opacity:0}) → animate('300ms') + style({opacity:1})
* => void   (leave/fade-out)  style({opacity:1}) → animate('300ms') + style({opacity:0})
```

---

## 17. i18n & Localization

```
i18n (Internationalization) — design; l10n (Localization) — actual translations
│
├── Built-in Angular i18n
│   ├── Mark text: <h1 i18n="description|meaning">Hello</h1>
│   ├── Extract:   ng extract-i18n   → messages.xlf
│   ├── Translate: create messages.fr.xlf (give to translator)
│   └── Build per locale: ng build --localize
│
├── Runtime i18n: @angular/localize + $localize template tag
│   $localize`Hello ${name}`
│
├── Pipes adapt to locale automatically
│   date | currency | number | percent
│   (set LOCALE_ID provider or use registerLocaleData)
│
└── RTL (Arabic, Hebrew, Farsi)
    dir="rtl" on html tag + mirror layout with logical CSS props
```

**Key config:**
```typescript
providers: [
  { provide: LOCALE_ID, useValue: 'fr-FR' }
]
```

---

## 18. Security

```
SECURITY THREATS & ANGULAR MITIGATIONS
│
├── XSS (Cross-Site Scripting)
│   ├── Angular auto-escapes: {{ userInput }} is safe
│   ├── [innerHTML] is DANGEROUS — avoid with untrusted data
│   └── DomSanitizer.bypassSecurityTrustHtml() — only for trusted content
│
├── CSRF
│   └── HttpClient auto-sends XSRF-TOKEN cookie as X-XSRF-TOKEN header
│       Server validates the header (Spring, ASP.NET handle this)
│
├── Auth — JWT pattern
│   ├── Store JWT in httpOnly cookie (not localStorage — XSS vulnerable)
│   ├── Auth interceptor: add Authorization: Bearer <token> to every request
│   └── Guard: check token validity before allowing route
│
├── Route Security
│   ├── canActivate guard → block unauthorized navigation
│   └── Never trust client-side only — server must also authorize
│
└── CSP (Content Security Policy)
    Set via HTTP headers or <meta> — controls which scripts can run
```

**Safe vs Dangerous:**

| Operation | Safe | Dangerous |
|-----------|------|-----------|
| Display text | `{{ val }}` | `[innerHTML]="val"` |
| Navigate URL | `routerLink` | `href="javascript:..."` |
| Inject HTML | `DomSanitizer.sanitize()` | Direct DOM manipulation |

---

## 19. SSR & Angular Universal

```
RENDERING MODES
│
├── CSR (Client-Side) — default Angular
│   Empty HTML → download JS → Angular builds DOM
│   ✓ Good for: dashboards, admin panels, auth-gated
│   ✗ Bad for: SEO, first paint, slow connections
│
├── SSR (Server-Side)
│   Server runs Angular → sends full HTML → JS hydrates
│   ✓ Good for: e-commerce, blogs, SEO pages
│   ✗ Server needed, more TTFB than SSG
│
├── SSG (Static Site Generation)
│   Build-time pre-rendering → static HTML files
│   ✓ Good for: docs, marketing, infrequent changes
│
└── ISR (Incremental Static Regeneration)
    SSG + on-demand revalidation per page
```

**Setup (v17+):**
```bash
ng add @angular/ssr        # adds server.ts + hydration
```

**Key APIs:**
```typescript
isPlatformBrowser(platformId)   // skip browser-only code on server
isPlatformServer(platformId)
inject(PLATFORM_ID)

// TransferState — pass server data to client (avoid double HTTP)
private transferState = inject(TransferState)
```

**Hydration (v16+):**
```typescript
providers: [provideClientHydration()]
// Reuses server-rendered DOM instead of destroying and rebuilding
```

---

## 20. Advanced Patterns & Architecture

```
ARCHITECTURAL PATTERNS
│
├── Smart / Dumb Components (Container / Presentational)
│   ├── Smart (container): fetches data, knows about state
│   └── Dumb (presentational): only @Input/@Output, no services
│
├── Facade Pattern
│   ├── Single service per feature: ProductFacade
│   ├── Wraps NgRx/state complexity from components
│   └── Component talks to facade; facade talks to store/services
│
├── Repository Pattern
│   ├── DataRepository handles ALL data access (HTTP + caching + error)
│   └── Services consume repository, never call HttpClient directly
│
├── SCAM (Single Component Angular Module)
│   Each component has its own tiny NgModule — max isolation
│   (Less relevant with standalone components)
│
├── Nx Monorepo
│   ├── Multiple apps + libraries in one repo
│   ├── Enforce boundaries: feature libs can't import each other directly
│   └── Shared: util, ui, data-access, feature separation
│
└── Feature Flags
    Control new features at runtime without deploy
```

**Clean Architecture layers:**
```
UI (Components)
    ↓ calls
Application (Facades / Use Cases)
    ↓ calls
Domain (Models, Domain Services)
    ↓ calls
Infrastructure (Repositories, HTTP, Storage)
```

---

## 21. Build, Deploy & DevOps

```
BUILD
├── ng build                        ← dev build
├── ng build --configuration=production  ← minify + AOT + tree-shake
│
├── AOT (Ahead-of-Time) compilation ← default in prod
│   Templates compiled at build time (not runtime) → faster, smaller
├── Tree shaking                    ← removes unused code
├── Differential loading            ← ES5 for old, ES2015 for modern browsers
│
├── Budgets (angular.json)
│   "budgets": [{ "maximumWarning": "500kb", "maximumError": "1mb" }]
│
└── Environment files
    environment.ts / environment.production.ts
    fileReplacements in angular.json

DEPLOYMENT OPTIONS
├── Static hosting: Netlify, Vercel, Firebase Hosting, GitHub Pages
│   ng build → upload dist/ folder
│
├── Nginx (serve SPA correctly)
│   try_files $uri $uri/ /index.html;  ← fallback to index for routing
│
├── Docker
│   Multi-stage: node:build → nginx:serve
│
└── CI/CD
    ├── GitHub Actions:   on: [push] → npm ci → ng build → deploy
    └── Azure Pipelines:  similar pipeline steps

BUNDLE ANALYSIS
└── npx source-map-explorer dist/**/*.js  ← visualize what's in the bundle
```

---

## 22. Angular New Features v14–v19

```
VERSION TIMELINE
│
v14 (2022)
├── Standalone Components (preview)
├── Typed Reactive Forms  ← FormControl<string>, no more `any`
└── inject() function
│
v15 (2022)
├── Standalone APIs STABLE
├── Functional Route Guards  (no class needed)
├── NgOptimizedImage directive  ← LCP optimization
└── NgModule optional for standalone
│
v16 (2023)
├── Signals (Developer Preview)  ← signal(), computed(), effect()
├── Required inputs:  @Input({ required: true })
├── Non-destructive hydration (SSR)
└── takeUntilDestroyed()
│
v17 (2023) ★ Big release
├── New control flow:  @if / @else / @for / @switch  (replaces *ngIf/*ngFor)
├── Deferrable views:  @defer (on viewport) { <HeavyComp> }
├── Vite + esbuild   ← MUCH faster builds
└── New angular.io → angular.dev
│
v18 (2024)
├── Signals STABLE
├── Zoneless (experimental):  provideZonelessChangeDetection()
├── Angular Material 3 (M3)
└── fallback content in @defer
│
v19 (2024)
├── Incremental Hydration  ← @defer drives SSR hydration
├── Linked Signals:  linkedSignal(() => source())
├── resource() API  ← async data loading with signals
└── Hot Module Replacement (HMR) for styles
```

**New control flow (v17+) — quick compare:**

| Old | New |
|-----|-----|
| `*ngIf="x"` | `@if (x) { }` |
| `*ngIf="x; else tpl"` | `@if (x) { } @else { }` |
| `*ngFor="let i of arr"` | `@for (i of arr; track i.id) { }` |
| `[ngSwitch]` + `*ngSwitchCase` | `@switch (x) { @case ('a') { } }` |

**Deferrable views (v17+):**
```html
@defer (on viewport; prefetch on hover) {
  <heavy-chart />
} @placeholder { <div>Loading...</div> }
@loading { <spinner /> }
@error { <p>Failed</p> }
```

---

## 23. NG Bootstrap

```
NG BOOTSTRAP (Bootstrap UI for Angular — no jQuery)
│
├── Install
│   npm install @ng-bootstrap/ng-bootstrap bootstrap
│   Add Bootstrap CSS to angular.json styles
│   Import NgbModule (or specific modules like NgbModalModule)
│
└── Key Components
    ├── NgbAlert       ← <ngb-alert type="success">
    ├── NgbModal       ← modalService.open(ContentComponent)
    ├── NgbTooltip     ← ngbTooltip="Tooltip text"
    ├── NgbPopover     ← ngbPopover="Content" popoverTitle="Title"
    ├── NgbDropdown    ← ngbDropdown + ngbDropdownToggle + ngbDropdownMenu
    ├── NgbAccordion   ← <ngb-accordion>
    ├── NgbDatepicker  ← <ngb-datepicker [(ngModel)]="date">
    ├── NgbTimepicker  ← <ngb-timepicker [(ngModel)]="time">
    ├── NgbPagination  ← <ngb-pagination [collectionSize]="total" [(page)]="p">
    ├── NgbProgressbar ← <ngb-progressbar [value]="50" type="success">
    ├── NgbCarousel    ← <ngb-carousel>
    └── NgbTabset      ← (legacy) → use NgbNav
```

---

## 24. Performance Optimization

```
PERFORMANCE TOOLKIT
│
├── Change Detection
│   ChangeDetectionStrategy.OnPush  ← on all leaf/presentational components
│   Avoid mutating objects/arrays   ← return new references
│   Use async pipe                  ← auto unsubscribe, auto triggers CD
│
├── Lazy Loading
│   ├── Lazy routes (loadChildren / loadComponent)
│   ├── @defer for heavy components (v17+)
│   └── Virtual scroll for long lists (CdkVirtualScrollViewport)
│
├── Template Optimizations
│   ├── trackBy on every *ngFor
│   ├── Pure pipes (default)       ← avoid impure
│   └── ng-container over wrapping divs
│
├── Bundle Size
│   ├── ng build --configuration=production  ← AOT + minification
│   ├── Remove unused Angular Material modules
│   ├── Import specific operators: import { map } from 'rxjs/operators'
│   └── Analyze: npx source-map-explorer
│
├── Image Optimization
│   NgOptimizedImage directive (v15+)
│   <img ngSrc="photo.jpg" width="800" height="600" priority>
│   ← lazy loading, LCP hints, format negotiation
│
├── HTTP Caching
│   shareReplay(1) on shared GET requests
│   Cache-Control headers from server
│
└── Server-Side Rendering (SSR)
    Faster First Contentful Paint (FCP)
    Better Largest Contentful Paint (LCP) score
```

---

## QUICK RECALL CHEATSHEET

### Decorators at a Glance

| Decorator | Marks | Key Metadata |
|-----------|-------|-------------|
| `@NgModule` | Module class | declarations, imports, providers, bootstrap |
| `@Component` | Component class | selector, template, styles, changeDetection |
| `@Directive` | Directive class | selector (attribute style `[appDir]`) |
| `@Pipe` | Pipe class | name, pure |
| `@Injectable` | Service class | providedIn |
| `@Input()` | Property | alias, required (v16+) |
| `@Output()` | EventEmitter property | alias |
| `@ViewChild` | Property | type, static, read |
| `@HostListener` | Method | event name |

### Angular Symbols Cheatsheet

| Symbol | Meaning |
|--------|---------|
| `{{ }}` | Interpolation |
| `[ ]` | Property binding |
| `( )` | Event binding |
| `[( )]` | Two-way binding (banana in a box) |
| `*` prefix | Structural directive |
| `#ref` | Template reference variable |
| `async \|` | Async pipe |
| `$event` | DOM event in template |

### RxJS Operator Decision

```
Need to transform each value?           → map
Need to filter values?                  → filter
Need to flatten (HTTP in pipe)?
  Cancel previous request?              → switchMap
  Allow concurrent?                     → mergeMap
  Wait for each to finish?              → concatMap
  Ignore new while busy?                → exhaustMap
Debounce user input?                    → debounceTime(300)
Only emit when changed?                 → distinctUntilChanged()
Share one HTTP call among subscribers?  → shareReplay(1)
Combine latest from multiple streams?   → combineLatest
Wait for all to complete?               → forkJoin
```

### Form Selection Guide

```
Is the form simple (login, search, 3 fields)?     → Template-Driven
Does the form have dynamic fields?                 → Reactive (FormArray)
Do you need cross-field validation?                → Reactive (group validator)
Do you need to unit test form logic?               → Reactive
Is the form complex or multi-step?                 → Reactive
```

### Routing Params Guide

```
Identifies a resource?                            → Path param  /products/:id
Optional filter / sort / pagination?              → Query param ?page=2&sort=name
Component needs to react as same URL rerenders?   → Observable paramMap
Component always created fresh on navigation?     → snapshot.paramMap
```

---

## ANGULAR INTERVIEW QUESTIONS — ALL LEVELS

> Format: **Q** → question | **A** → expected answer (concise, interview-ready)
> Legend: 🟢 Basic · 🟡 Intermediate · 🔴 Advanced

---

### SECTION 1 — Architecture & Core Concepts

---

**🟢 Q1. What is Angular? How is it different from AngularJS?**

**A:** Angular (v2+) is a TypeScript-based, component-driven front-end framework by Google. AngularJS (v1.x) was JavaScript-based and used two-way data binding via `$scope` and dirty checking. Angular uses a component tree, unidirectional data flow, RxJS-based change detection, AOT compilation, and TypeScript — making it faster, more modular, and easier to scale. AngularJS is effectively deprecated.

---

**🟢 Q2. What is a Component? What are its three parts?**

**A:** A component is the basic UI building block of Angular. It consists of:
- **Class (`.ts`)** — data and logic
- **Template (`.html`)** — what the user sees
- **Styles (`.css/.scss`)** — scoped visual rules

Decorated with `@Component({ selector, templateUrl, styleUrls })`. Angular apps are a tree of nested components.

---

**🟢 Q3. What is data binding? List all 4 types.**

**A:**
| Type | Syntax | Direction |
|------|--------|-----------|
| Interpolation | `{{ val }}` | Class → Template |
| Property Binding | `[property]="expr"` | Class → Template |
| Event Binding | `(event)="fn()"` | Template → Class |
| Two-way Binding | `[(ngModel)]="prop"` | Both ways |

Two-way binding is shorthand for `[ngModel]` + `(ngModelChange)` — called "banana in a box."

---

**🟢 Q4. What is the difference between `*ngIf` and `[hidden]`?**

**A:**
- `*ngIf="false"` → **removes** the element from the DOM entirely. `ngOnDestroy` fires; component resets when re-added.
- `[hidden]="true"` → keeps the element in DOM but sets `display: none`.

Use `*ngIf` when the component has subscriptions or API calls (avoids memory waste). Use `[hidden]` when you need frequent toggling and want to preserve form state.

---

**🟢 Q5. What are lifecycle hooks? Name the most important ones.**

**A:** Lifecycle hooks let you run code at specific moments in a component's life.

| Hook | When | Use For |
|------|------|---------|
| `ngOnChanges` | Each `@Input()` change | React to parent data changes |
| `ngOnInit` ★ | Once, after first `ngOnChanges` | Fetch data, setup |
| `ngOnDestroy` ★ | Before removal from DOM | Unsubscribe, clear timers |
| `ngAfterViewInit` | After view (template) is ready | Access `@ViewChild` |

**Key rule:** Never fetch data in `constructor` — use `ngOnInit`. `constructor` should only do dependency injection.

---

**🟢 Q6. What is `NgModule`? What are its key properties?**

**A:** `@NgModule` is a decorator that organises related code into a cohesive block.

| Property | Purpose |
|----------|---------|
| `declarations` | Components, directives, pipes owned by this module |
| `imports` | Other modules this module needs |
| `providers` | Services registered here |
| `exports` | What this module makes available to importers |
| `bootstrap` | Root component (only in AppModule) |

---

**🟢 Q7. What is dependency injection in Angular?**

**A:** DI is a design pattern where a class declares its dependencies rather than creating them. Angular's DI system reads constructor parameters, looks up the injector hierarchy, and provides the correct instance.

```typescript
constructor(private userService: UserService) {}
```

Angular creates a **singleton** by default (`providedIn: 'root'`). The same instance is shared across the app. Component-level providers create a **new instance per component**.

---

**🟡 Q8. Explain `@Input()` and `@Output()`. How does component communication work?**

**A:**
- `@Input()` — parent passes data **down** to child via property binding: `<child [data]="parentVal">`
- `@Output()` — child emits events **up** to parent via `EventEmitter`: `<child (saved)="onSave($event)">`

Full pattern:
```typescript
// Child
@Input() user: User;
@Output() userSaved = new EventEmitter<User>();
save() { this.userSaved.emit(this.user); }

// Parent template
<app-child [user]="currentUser" (userSaved)="handleSave($event)">
```

For unrelated components: use a shared service with `BehaviorSubject`.

---

**🟡 Q9. What is `ViewChild` vs `ContentChild`?**

**A:**
- `@ViewChild` — access a child component/element from the parent's **own template** (`.html`). Available in `ngAfterViewInit`.
- `@ContentChild` — access content that was **projected into** the component via `<ng-content>`. Available in `ngAfterContentInit`.

```typescript
@ViewChild(ChildComponent) child!: ChildComponent;    // own template
@ContentChild(SlotComponent) slot!: SlotComponent;    // projected content
```

---

**🟡 Q10. What is the difference between `Observable` and `Promise`?**

**A:**

| Feature | Promise | Observable |
|---------|---------|------------|
| Values | One (resolved once) | Zero, one, or many (stream) |
| Cancellable | No | Yes (unsubscribe) |
| Lazy | No (executes immediately) | Yes (executes on subscribe) |
| Operators | `.then/.catch` only | Full RxJS (map, filter, switchMap…) |
| Angular preference | Rare | Used everywhere (HTTP, forms, router) |

`Promise` is fire-and-forget. `Observable` is a composable stream. Convert: `firstValueFrom(obs$)` or `obs$.toPromise()`.

---

**🟡 Q11. What is `switchMap`? When would you use it over `mergeMap`?**

**A:** Both flatten inner Observables but differ in concurrency:

- `switchMap` — **cancels** the previous inner Observable when a new outer value arrives. Use for search-as-you-type, route param changes. Prevents stale results.
- `mergeMap` — **runs all concurrently**. Use when order doesn't matter (parallel file uploads).
- `concatMap` — **queues** sequentially. Use when order matters.
- `exhaustMap` — **ignores** new values while one is active. Use for login buttons (prevent double submit).

---

**🟡 Q12. What is `BehaviorSubject`? Why use it over a plain `Subject`?**

**A:** `BehaviorSubject(initialValue)` holds the **current value** and replays it immediately to any new subscriber. A plain `Subject` only delivers future values — late subscribers miss past emissions.

Use `BehaviorSubject` for state in services (current user, cart, theme) where any component subscribing late should still get the current state immediately.

---

**🟡 Q13. What are Angular Route Guards? List the types.**

**A:** Guards are functions/classes that decide if navigation to/from a route is allowed.

| Guard | Purpose |
|-------|---------|
| `canActivate` | Block entry to a route (auth check) |
| `canActivateChild` | Block entry to all child routes |
| `canDeactivate` | Prevent leaving (unsaved changes) |
| `resolve` | Pre-fetch data before route renders |
| `canLoad` | Prevent lazy module download entirely |

Modern Angular (v14+) uses **functional guards** — no class needed:
```typescript
export const authGuard: CanActivateFn = (route, state) => {
  return inject(AuthService).isLoggedIn() || inject(Router).createUrlTree(['/login']);
};
```

---

**🟡 Q14. What is lazy loading? How do you implement it?**

**A:** Lazy loading splits the app into separate JS bundles. A module/component is only downloaded when the user navigates to its route — improving initial load time.

```typescript
// app.routes.ts
{
  path: 'admin',
  loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule)
  // OR for standalone:
  loadComponent: () => import('./admin/admin.component').then(c => c.AdminComponent)
}
```

The feature module uses `RouterModule.forChild(routes)` — **never** `forRoot`.

---

**🟡 Q15. Template-Driven vs Reactive Forms — when to use each?**

**A:**

| | Template-Driven | Reactive |
|--|-----------------|---------|
| Setup | `FormsModule` + `[(ngModel)]` | `ReactiveFormsModule` + `FormBuilder` |
| Logic in | HTML template | TypeScript class |
| Dynamic fields | Hard | Easy (`FormArray`) |
| Unit testable | Harder | Easy |
| Validation | HTML attributes | Code, composable validators |

**Rule:** Use Reactive Forms for anything non-trivial. Template-Driven only for simple 2–3 field forms.

---

**🟡 Q16. What is an HTTP Interceptor? Give a real use case.**

**A:** An interceptor sits between the app and the HTTP layer, transforming every request or response.

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = inject(AuthService).getToken();
  const authReq = req.clone({ headers: req.headers.set('Authorization', `Bearer ${token}`) });
  return next(authReq);
};
```

**Common use cases:** add auth tokens, handle 401→redirect to login, show/hide loading spinner, log all requests, retry on failure, transform error responses globally.

---

**🟡 Q17. What is `ChangeDetectionStrategy.OnPush`? When should you use it?**

**A:** Default strategy checks **every component** on every browser event. `OnPush` tells Angular: only re-check this component when:
1. A bound `@Input()` **reference** changes (not mutation)
2. An event originates from this component
3. An `async` pipe emits a new value
4. `markForCheck()` is called manually

**Use it on all "dumb" (presentational) components.** Combined with immutable data patterns it dramatically reduces CD work. Key rule: never mutate arrays/objects — always return new references (`[...arr, item]`).

---

**🟡 Q18. What is the `async` pipe? Why is it preferred?**

**A:** The `async` pipe subscribes to an Observable or Promise in the template and automatically:
- Unwraps the emitted value for display
- Unsubscribes when the component is destroyed (no memory leak)
- Triggers change detection when a new value arrives (critical with `OnPush`)

```html
<div *ngIf="users$ | async as users">
  <li *ngFor="let u of users">{{ u.name }}</li>
</div>
```

Preferred over manual `subscribe()` in `ngOnInit` because it removes the need for `ngOnDestroy` cleanup.

---

**🟡 Q19. What is `ng-content`? What is content projection?**

**A:** Content projection lets a parent inject HTML into a child component's template via `<ng-content>`. Like named slots in web components.

```html
<!-- child component template -->
<div class="card">
  <ng-content select="[card-header]"></ng-content>   ← named slot
  <ng-content></ng-content>                           ← default slot
</div>

<!-- parent usage -->
<app-card>
  <h2 card-header>Title</h2>
  <p>Body content goes here</p>
</app-card>
```

Useful for building reusable container components (cards, modals, tabs) where the consumer controls the inner content.

---

**🔴 Q20. Explain Angular's Change Detection mechanism. How does Zone.js fit in?**

**A:** Angular has two "worlds": the JS component state and the DOM. Change detection (CD) keeps them in sync.

**Zone.js** monkey-patches all browser async APIs (`setTimeout`, `fetch`, `addEventListener`). When any wrapped operation completes, Zone.js notifies Angular: "something may have changed." Angular then runs CD — walking the component tree from root down, comparing old vs new values, and updating the DOM where differences exist.

**Problem:** Zone.js can't know *which* component changed — it tells Angular to check *everything*. This is why `OnPush` + immutability matters.

**Future:** Angular v18+ introduces zoneless mode (`provideZonelessChangeDetection()`) — Signals directly notify Angular exactly which computed values changed, skipping the full tree walk.

---

**🔴 Q21. What are Angular Signals? How do they differ from Observables?**

**A:** Signals (`signal()`, `computed()`, `effect()`) are a **synchronous, fine-grained reactivity primitive** introduced in v16 (stable v17+).

```typescript
count = signal(0);
double = computed(() => count() * 2);   // auto-recomputes when count changes
effect(() => console.log(count()));      // runs when count changes
```

Key differences from Observables:
- **Synchronous** — reads are instant, no async pipe needed
- **No subscription** — no memory leak risk
- **Glitch-free** — computed signals never produce intermediate values
- **Framework-integrated** — Angular tracks them at component level for precise CD

Observables are still preferred for HTTP, time-based streams, and complex async composition. Signals are for reactive UI state.

---

**🔴 Q22. What is the difference between `forRoot()` and `forChild()`?**

**A:**
- `RouterModule.forRoot(routes)` — creates the **Router service singleton**. Must be called **exactly once** in the app's root routing module.
- `RouterModule.forChild(routes)` — registers additional routes **without** creating a new Router service. Used in every feature module.

Calling `forRoot()` in a feature module (especially lazy loaded) creates a second Router instance, breaking navigation. This is a common bug.

---

**🔴 Q23. Explain the NgRx data flow. What problem does it solve?**

**A:** NgRx implements the Redux pattern for Angular. It solves "state chaos" in large apps where many components share and mutate the same data unpredictably.

**Unidirectional flow:**
```
Component dispatches Action
    ↓
Reducer (pure function) → produces new immutable State
    ↓
Store (single source of truth) → notifies Selectors
    ↓
Selectors (memoized) → deliver slices to Components
    ↓ (side effects)
Effects listen to Actions → call HTTP/API → dispatch new Actions
```

Benefits: predictable state, time-travel debugging (Redux DevTools), easy testing (reducers are pure functions), clear separation of concerns.

---

**🔴 Q24. What is Server-Side Rendering? What is hydration?**

**A:** SSR runs Angular on a Node.js server, generating full HTML before sending it to the browser. This solves the "blank page problem" of CSR (where the browser downloads JS, then builds the DOM).

**Hydration** (Angular v16+): instead of Angular destroying the server-rendered DOM and rebuilding it from scratch (old behaviour), hydration **reuses** the existing server DOM. Angular "attaches" event listeners and marks it live without touching the pixels — dramatically reducing the flickering and layout shift.

Setup: `ng add @angular/ssr`. Use `isPlatformBrowser()` to guard browser-only APIs.

---

**🔴 Q25. What are standalone components? How do they change the architecture?**

**A:** Standalone components (`standalone: true`, stable v15+) don't need an `NgModule` to be declared in. They declare their own dependencies directly in `imports: []`.

```typescript
@Component({
  standalone: true,
  imports: [NgIf, NgFor, ReactiveFormsModule, RouterModule],
  template: `...`
})
export class ProductListComponent {}
```

**Bootstrap standalone app:**
```typescript
bootstrapApplication(AppComponent, {
  providers: [provideRouter(routes), provideHttpClient()]
});
```

This reduces boilerplate, makes tree-shaking more effective, simplifies lazy loading (a single component can be lazy loaded), and is now the **recommended approach** in Angular v17+.

---

**🔴 Q26. How do you prevent memory leaks in Angular?**

**A:** Memory leaks in Angular are almost always caused by **un-unsubscribed Observables**. Strategies:

| Approach | How |
|----------|-----|
| `async` pipe | Auto-unsubscribes on component destroy |
| `takeUntilDestroyed()` | v16+ — ties subscription to component lifetime |
| `takeUntil(destroy$)` | Manual with `Subject` + `complete()` in `ngOnDestroy` |
| `take(1)` / `first()` | Completes after first emission (one-off HTTP) |
| Avoid `subscribe()` in templates | Use `async` pipe instead |

Also watch for: `setInterval` not cleared, `fromEvent` not unsubscribed, router event subscriptions.

---

**🔴 Q27. What is `shareReplay(1)` and when do you use it?**

**A:** `shareReplay(1)` multicasts an Observable to multiple subscribers AND replays the last emission to late subscribers. It prevents duplicate HTTP calls when multiple components subscribe to the same data stream.

```typescript
// Without shareReplay: 3 components = 3 HTTP calls
users$ = this.http.get<User[]>('/api/users');

// With shareReplay: 3 components = 1 HTTP call, all get the cached result
users$ = this.http.get<User[]>('/api/users').pipe(shareReplay(1));
```

Use it in services for shared GET requests that don't need to refetch on every subscription.

---

**🔴 Q28. Explain the difference between `snapshot` and `paramMap.subscribe()` in routing.**

**A:**
- `route.snapshot.paramMap.get('id')` — reads the parameter **once** at the moment of component creation. Correct when the component is always freshly created (navigating from a different route).
- `route.paramMap.subscribe(params => ...)` — **reacts** to parameter changes. Required when navigating from `/products/1` to `/products/2` — Angular reuses the same component instance and only changes the params. Snapshot would show stale data.

**Safe default:** always use `paramMap.subscribe()` — it works in both cases.

---

**🔴 Q29. How does Angular achieve style encapsulation?**

**A:** Angular uses **ViewEncapsulation** to scope component styles:

| Mode | Behaviour |
|------|-----------|
| `Emulated` (default) | Angular adds unique attribute (`_ngcontent-xxx`) to elements and rewrites CSS selectors to match only that component's DOM |
| `None` | No encapsulation — styles leak globally |
| `ShadowDom` | Uses native browser Shadow DOM — strongest isolation |

With `Emulated`, `h1 { color: red }` in a component becomes `h1[_ngcontent-c1] { color: red }` in the rendered CSS — so it only applies to that component's `h1` tags.

---

**🔴 Q30. What are the new control flow blocks (`@if`, `@for`) and how do they differ from `*ngIf`, `*ngFor`?**

**A:** Introduced in Angular v17, the new built-in control flow replaces structural directives:

```html
<!-- Old -->
<div *ngIf="user; else loading"><p>{{ user.name }}</p></div>
<ng-template #loading><spinner /></ng-template>

<!-- New -->
@if (user) { <p>{{ user.name }}</p> } @else { <spinner /> }

<!-- Old -->
<li *ngFor="let item of items; trackBy: trackById">{{ item.name }}</li>

<!-- New — track is REQUIRED (enforces best practice) -->
@for (item of items; track item.id) { <li>{{ item.name }}</li> } @empty { <p>None</p> }
```

**Advantages of new syntax:**
- No import needed (built into compiler, not a directive)
- `track` is mandatory in `@for` (forces `trackBy` — avoids accidental perf issues)
- `@empty` block built-in for `@for`
- Type narrowing works naturally inside `@if` blocks
- Slightly smaller bundle (no NgIf/NgFor directive overhead)

---

### QUICK ANSWER FLASH CARDS

| Question | One-Line Answer |
|----------|----------------|
| What is AOT? | Ahead-of-Time: templates compiled at build time → smaller, faster |
| What is tree shaking? | Dead code elimination — unused exports removed from final bundle |
| What is `forRoot()` rule? | Call once in root; feature modules use `forChild()` |
| What does `ng-container` do? | Groups elements without adding a DOM node |
| What is `ng-template`? | Defines template block not rendered until explicitly referenced |
| What is a pure pipe? | Only recalculates when input reference changes (default, fast) |
| What is an impure pipe? | Recalculates every CD cycle (use sparingly) |
| Difference: Subject vs BehaviorSubject? | BehaviorSubject has initial value + replays last to new subscribers |
| What is `TrackBy`? | Function telling `*ngFor` how to identify items → avoids full DOM recreate |
| `providedIn: 'root'` vs component provider? | Root = singleton app-wide; component = new instance per component |
| What is hydration (SSR)? | Reusing server-rendered DOM instead of rebuilding it in the browser |
| When use `exhaustMap`? | Ignore new requests while current is active (login, form submit) |
| What triggers OnPush? | New `@Input()` reference, component event, async pipe emit, `markForCheck()` |
| What is `DomSanitizer`? | Angular service to safely handle HTML/URL/style values (XSS prevention) |
| What is `TransferState`? | Pass data from server render to client to avoid double HTTP calls in SSR |
| What is zoneless Angular? | v18+ experimental: no Zone.js; Signals drive CD — smaller, faster |

---

## MID-SCALE ANGULAR APP — FOLDER STRUCTURE

> Represents a real-world app with ~10–20 features, lazy-loaded modules, shared UI library, state management, and CI/CD. Annotations explain the **why** behind every folder decision.

```
my-angular-app/
│
├── .github/
│   └── workflows/
│       └── ci.yml                  ← GitHub Actions: lint → test → build → deploy
│
├── src/
│   ├── index.html                  ← Single HTML page; only <app-root> here
│   ├── main.ts                     ← bootstrapApplication(AppComponent, appConfig)
│   ├── styles.scss                 ← Global styles (resets, typography, CSS vars)
│   │
│   └── app/
│       │
│       ├── app.component.ts        ← Root component (shell: nav + router-outlet)
│       ├── app.component.html
│       ├── app.component.scss
│       │
│       ├── app.config.ts           ← Standalone bootstrap config
│       │   │                          provideRouter, provideHttpClient,
│       │   │                          provideAnimations, provideStore (NgRx)
│       │   └── app.routes.ts       ← Top-level route definitions (lazy loadChildren)
│       │
│       ├── core/                   ← Singleton services, app-level concerns
│       │   │                          Imported ONCE (in app.config or AppModule)
│       │   ├── auth/
│       │   │   ├── auth.service.ts         ← Login, logout, token management
│       │   │   ├── auth.guard.ts           ← canActivate functional guard
│       │   │   └── auth.interceptor.ts     ← Attach Bearer token to every request
│       │   │
│       │   ├── http/
│       │   │   ├── error.interceptor.ts    ← Global HTTP error handler (401→login, 500→toast)
│       │   │   └── loading.interceptor.ts  ← Show/hide global spinner on HTTP activity
│       │   │
│       │   ├── layout/
│       │   │   ├── header/
│       │   │   │   ├── header.component.ts
│       │   │   │   └── header.component.html
│       │   │   ├── sidebar/
│       │   │   │   └── sidebar.component.ts
│       │   │   └── footer/
│       │   │       └── footer.component.ts
│       │   │
│       │   └── services/
│       │       ├── logger.service.ts       ← App-wide logging (console + remote)
│       │       ├── notification.service.ts ← Toast/snackbar messages
│       │       └── theme.service.ts        ← Dark/light mode toggle
│       │
│       ├── shared/                 ← Reusable UI: components, pipes, directives
│       │   │                          No business logic here — pure presentation
│       │   ├── components/
│       │   │   ├── button/
│       │   │   │   ├── button.component.ts
│       │   │   │   └── button.component.html
│       │   │   ├── card/
│       │   │   │   └── card.component.ts
│       │   │   ├── modal/
│       │   │   │   └── modal.component.ts
│       │   │   ├── data-table/
│       │   │   │   └── data-table.component.ts  ← Generic table (sort, paginate, filter)
│       │   │   ├── spinner/
│       │   │   │   └── spinner.component.ts
│       │   │   └── empty-state/
│       │   │       └── empty-state.component.ts ← "No results found" placeholder
│       │   │
│       │   ├── directives/
│       │   │   ├── highlight.directive.ts
│       │   │   ├── click-outside.directive.ts   ← Close dropdowns on outside click
│       │   │   └── has-role.directive.ts         ← *hasRole="'admin'" (show/hide by role)
│       │   │
│       │   ├── pipes/
│       │   │   ├── truncate.pipe.ts
│       │   │   ├── time-ago.pipe.ts
│       │   │   └── safe-html.pipe.ts             ← DomSanitizer wrapper
│       │   │
│       │   ├── validators/
│       │   │   ├── password-match.validator.ts   ← Cross-field reactive form validator
│       │   │   └── unique-email.validator.ts     ← Async validator (HTTP check)
│       │   │
│       │   └── models/                           ← Shared interfaces/types (DTOs)
│       │       ├── api-response.model.ts         ← ApiResponse<T> generic wrapper
│       │       ├── pagination.model.ts
│       │       └── user.model.ts
│       │
│       ├── features/               ← Feature modules — each lazy loaded by the router
│       │   │                          Each feature is self-contained: components + service + state
│       │   │
│       │   ├── dashboard/
│       │   │   ├── dashboard.routes.ts           ← forChild routes for this feature
│       │   │   ├── dashboard.component.ts        ← Smart (container) component
│       │   │   ├── dashboard.component.html
│       │   │   ├── components/
│       │   │   │   ├── stats-card/
│       │   │   │   │   └── stats-card.component.ts   ← Dumb (presentational)
│       │   │   │   └── activity-feed/
│       │   │   │       └── activity-feed.component.ts
│       │   │   └── services/
│       │   │       └── dashboard.service.ts      ← Dashboard-specific HTTP calls
│       │   │
│       │   ├── products/
│       │   │   ├── products.routes.ts
│       │   │   ├── pages/
│       │   │   │   ├── product-list/
│       │   │   │   │   ├── product-list.component.ts   ← Smart: owns state, calls service
│       │   │   │   │   └── product-list.component.html
│       │   │   │   └── product-detail/
│       │   │   │       ├── product-detail.component.ts
│       │   │   │       └── product-detail.component.html
│       │   │   ├── components/
│       │   │   │   ├── product-card/
│       │   │   │   │   └── product-card.component.ts   ← Dumb: @Input product, @Output add
│       │   │   │   └── product-filter/
│       │   │   │       └── product-filter.component.ts
│       │   │   ├── services/
│       │   │   │   └── product.service.ts        ← HTTP + caching (shareReplay)
│       │   │   ├── store/                        ← NgRx state for products (optional)
│       │   │   │   ├── product.actions.ts
│       │   │   │   ├── product.reducer.ts
│       │   │   │   ├── product.effects.ts
│       │   │   │   └── product.selectors.ts
│       │   │   └── models/
│       │   │       └── product.model.ts          ← Feature-specific interface
│       │   │
│       │   ├── orders/
│       │   │   └── ... (same pattern as products)
│       │   │
│       │   ├── users/
│       │   │   └── ... (same pattern)
│       │   │
│       │   └── auth/
│       │       ├── auth.routes.ts
│       │       ├── pages/
│       │       │   ├── login/
│       │       │   │   └── login.component.ts    ← Reactive form + auth.service.login()
│       │       │   ├── register/
│       │       │   │   └── register.component.ts
│       │       │   └── forgot-password/
│       │       │       └── forgot-password.component.ts
│       │       └── components/
│       │           └── auth-form/
│       │               └── auth-form.component.ts ← Reusable form shell
│       │
│       └── store/                  ← Root NgRx store (app-level state only)
│           ├── app.state.ts        ← AppState interface (top-level)
│           ├── router/
│           │   └── router.reducer.ts ← @ngrx/router-store integration
│           └── ui/
│               ├── ui.actions.ts   ← setLoading, setTheme, showNotification
│               ├── ui.reducer.ts
│               └── ui.selectors.ts
│
├── environments/
│   ├── environment.ts              ← Dev: apiUrl, featureFlags, debug: true
│   └── environment.production.ts  ← Prod: apiUrl, featureFlags, debug: false
│
├── assets/
│   ├── i18n/
│   │   ├── en.json                 ← Translation strings (ngx-translate or @angular/localize)
│   │   └── fr.json
│   ├── images/
│   └── icons/
│
├── angular.json                    ← CLI config: budgets, styles, assets, build targets
├── package.json
├── tsconfig.json                   ← Base TS config (strict: true, paths aliases)
├── tsconfig.app.json
├── tsconfig.spec.json
├── .eslintrc.json                  ← ESLint + @angular-eslint rules
├── .prettierrc                     ← Code formatting rules
└── karma.conf.js                   ← Unit test runner config
```

---

### KEY ARCHITECTURAL RULES (enforce via linting/code review)

```
RULE 1 — Feature modules are islands
  features/products/ imports ONLY from shared/ and core/
  features/products/ NEVER imports from features/orders/
  Cross-feature data: go through the NgRx store or a shared service in core/

RULE 2 — Smart vs Dumb components
  pages/*         → Smart  (inject services, own Observable subscriptions)
  components/*    → Dumb   (only @Input/@Output, OnPush, no service injection)

RULE 3 — One service per domain
  products.service.ts   handles ALL product HTTP
  Components never import HttpClient directly

RULE 4 — Lazy loading is mandatory for every feature
  app.routes.ts:
    { path: 'products', loadChildren: () => import('./features/products/products.routes') }
  Never eagerly import a feature into AppModule/AppConfig

RULE 5 — Shared module exports nothing it doesn't declare
  No re-exporting CommonModule or ReactiveFormsModule from SharedModule
  Use standalone component imports instead (v15+)

RULE 6 — Environment variables only via injection token
  const API_URL = new InjectionToken<string>('API_URL')
  Never read environment.ts directly inside a service (breaks testability)
```

---

### DATA FLOW DIAGRAM

```
Browser Event (click, input, route change)
          │
          ▼
  Component (Smart / Page)
  ├── dispatches Action    ──────────────────► NgRx Store
  │                                            ├── Reducer  → new State
  │                                            ├── Selector → slice$ (Observable)
  │                                            └── Effect   → calls Service
  │                                                              │
  └── calls Service directly (non-NgRx)                         ▼
              │                                         HTTP (via HttpClient)
              ▼                                              │
     Service (business logic)                               ▼
     ├── shareReplay cache                         API / Backend
     └── returns Observable<T>
              │
              ▼
  Component (async pipe) ──► DOM update (Change Detection)
```

---

### LAZY ROUTE WIRING (how it all connects)

```typescript
// app.routes.ts
export const appRoutes: Routes = [
  { path: '',        redirectTo: 'dashboard', pathMatch: 'full' },
  { path: 'login',   loadComponent: () => import('./features/auth/pages/login/login.component') },
  {
    path: '',
    component: ShellComponent,              // ← layout wrapper (header + sidebar + footer)
    canActivate: [authGuard],               // ← protect everything inside
    children: [
      { path: 'dashboard', loadChildren: () => import('./features/dashboard/dashboard.routes') },
      { path: 'products',  loadChildren: () => import('./features/products/products.routes')  },
      { path: 'orders',    loadChildren: () => import('./features/orders/orders.routes')      },
      { path: 'users',     loadChildren: () => import('./features/users/users.routes')        },
    ]
  },
  { path: '**', loadComponent: () => import('./shared/components/not-found/not-found.component') }
];
```

---

*Generated from Phases 1–24 — Angular Complete Reference*
