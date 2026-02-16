# React vs Angular: Complete Architect's Guide
## For React Developers Transitioning to Angular

> **Your Background**: React.js, Redux, Large-scale apps, Cross-cutting concerns, JWT Auth, Performance optimization

---

## Table of Contents
1. [Quick Start & Prerequisites](#quick-start--prerequisites)
2. [Project Structure](#1-project-structure)
3. [Components & Lifecycle](#2-components--lifecycle)
4. [State Management: Redux vs NgRx](#3-state-management-redux-vs-ngrx)
5. [Cross-Cutting Concerns](#4-cross-cutting-concerns)
6. [JWT Authentication](#5-jwt-authentication)
7. [Performance Optimization](#6-performance-optimization)
8. [Routing](#7-routing)
9. [Forms](#8-forms)
10. [HTTP & API Calls](#9-http--api-calls)
11. [Dependency Injection (Angular Unique)](#10-dependency-injection-angular-unique)
12. [RxJS Deep Dive (Angular Unique)](#11-rxjs-deep-dive-angular-unique)
13. [React-Only Features](#12-react-only-features)
14. [Angular-Only Features](#13-angular-only-features)
15. [Popular Libraries Comparison](#14-popular-libraries-comparison)
16. [Architecture Patterns](#15-architecture-patterns)

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
      .subscribe(user => {
        // Called when data arrives - update component state
        this.user = user;
        this.loading = false;
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
private destroy$ = new Subject<void>();

ngOnInit() {
  this.userService.getUser()
    .pipe(takeUntil(this.destroy$))
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
      ofType(AuthActions.login),
      exhaustMap(({ credentials }) =>
        this.authService.login(credentials).pipe(
          map(response => AuthActions.loginSuccess({
            user: response.user,
            token: response.token
          })),
          catchError(error => of(AuthActions.loginFailure({ error: error.message })))
        )
      )
    )
  );

  // Effect for side effects without dispatching new action
  loginSuccess$ = createEffect(() =>
    this.actions$.pipe(
      ofType(AuthActions.loginSuccess),
      tap(({ token }) => {
        localStorage.setItem('token', token);
        this.router.navigate(['/dashboard']);
      })
    ),
    { dispatch: false }  // No new action dispatched
  );

  logout$ = createEffect(() =>
    this.actions$.pipe(
      ofType(AuthActions.logout),
      tap(() => {
        localStorage.removeItem('token');
        this.router.navigate(['/login']);
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
  private refreshTokenSubject = new BehaviorSubject<string | null>(null);

  constructor(private authService: AuthService) {}

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // Add token to all requests
    const token = this.authService.getToken();
    if (token) {
      request = this.addToken(request, token);
    }

    return next.handle(request).pipe(
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401) {
          return this.handle401Error(request, next);
        }
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
      this.refreshTokenSubject.next(null);

      return this.authService.refreshToken().pipe(
        switchMap((token: string) => {
          this.isRefreshing = false;
          this.refreshTokenSubject.next(token);
          return next.handle(this.addToken(request, token));
        }),
        catchError((err) => {
          this.isRefreshing = false;
          this.authService.logout();
          return throwError(() => err);
        })
      );
    }

    // Queue requests while refreshing
    return this.refreshTokenSubject.pipe(
      filter(token => token !== null),
      take(1),
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
import { Injectable } from '@angular/core';
import { CanActivate, CanActivateChild, CanLoad, Router, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';
import { map, take } from 'rxjs/operators';
import { Store } from '@ngrx/store';
import { selectIsAuthenticated } from '../store/auth.selectors';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate, CanActivateChild, CanLoad {
  constructor(private store: Store, private router: Router) {}

  canActivate(): Observable<boolean | UrlTree> {
    return this.checkAuth();
  }

  canActivateChild(): Observable<boolean | UrlTree> {
    return this.checkAuth();
  }

  canLoad(): Observable<boolean | UrlTree> {
    return this.checkAuth();
  }

  private checkAuth(): Observable<boolean | UrlTree> {
    return this.store.select(selectIsAuthenticated).pipe(
      take(1),
      map(isAuthenticated =>
        isAuthenticated ? true : this.router.createUrlTree(['/login'])
      )
    );
  }
}

// core/guards/role.guard.ts
@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(private store: Store, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): Observable<boolean | UrlTree> {
    const requiredRoles = route.data['roles'] as string[];

    return this.store.select(selectUser).pipe(
      take(1),
      map(user => {
        if (!user) return this.router.createUrlTree(['/login']);

        const hasRole = requiredRoles.some(role => user.roles.includes(role));
        return hasRole ? true : this.router.createUrlTree(['/forbidden']);
      })
    );
  }
}

// Usage in routing
const routes: Routes = [
  {
    path: 'admin',
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['admin', 'superadmin'] },
    loadChildren: () => import('./features/admin/admin.module').then(m => m.AdminModule)
  }
];
```

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
      map(response => {
        localStorage.setItem('token', response.token);
        this.setToken(response.token);
        this.startRefreshTokenTimer();
        return response.token;
      }),
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
      debounceTime(300),
      distinctUntilChanged(),
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

// Resolver - Pre-fetch data before navigation
@Injectable({ providedIn: 'root' })
export class UserResolver implements Resolve<User> {
  constructor(private userService: UserService) {}

  resolve(route: ActivatedRouteSnapshot): Observable<User> {
    const userId = route.paramMap.get('userId')!;
    return this.userService.getUser(userId);
  }
}

// Component using resolver and route params
@Component({
  template: `
    <h1>User: {{ user.name }}</h1>
    <nav>
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

  constructor(private route: ActivatedRoute, private router: Router) {}

  ngOnInit() {
    // Resolver data
    this.user = this.route.snapshot.data['user'];

    // Or subscribe to route data for dynamic updates
    this.route.data.subscribe(data => {
      this.user = data['user'];
    });

    // Query params
    this.route.queryParamMap.subscribe(params => {
      this.tab = params.get('tab') || 'overview';
    });
  }

  // Programmatic navigation
  navigateToSettings() {
    this.router.navigate(['/user', this.user.id], {
      queryParams: { tab: 'settings' },
      queryParamsHandling: 'merge'  // Keep existing params
    });
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

#### Angular Approach (Step-by-Step)

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

**Step 3**: Build form structure with FormBuilder
```typescript
this.userForm = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  password: ['', Validators.min(8)]
});
```

**Step 4**: Bind form to template
```html
<form [formGroup]="userForm">
  <input formControlName="email">
  <button type="submit">Submit</button>
</form>
```

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
      debounceTime(300),
      map(exists => exists ? { emailTaken: true } : null),
      first()
    );
  }

  onSubmit(): void {
    if (this.userForm.valid) {
      this.isSubmitting = true;
      this.userService.createUser(this.userForm.value).subscribe({
        next: () => {
          this.isSubmitting = false;
          this.userForm.reset();
        },
        error: () => this.isSubmitting = false
      });
    } else {
      // Mark all controls as touched to show errors
      this.userForm.markAllAsTouched();
    }
  }
}
```

### Forms Comparison

| Feature | React Hook Form | Angular Reactive Forms |
|---------|----------------|----------------------|
| Validation | Zod/Yup schemas | Built-in + custom validators |
| Async Validation | Custom async validate | `AsyncValidator` |
| Cross-field Validation | `.refine()` in schema | Form-level validators |
| Dynamic Arrays | `useFieldArray` | `FormArray` |
| Nested Objects | Dot notation paths | `FormGroup` nesting |
| Performance | Uncontrolled (minimal re-renders) | Tree-shakable, OnPush friendly |
| Type Safety | `z.infer<typeof schema>` | Typed `FormGroup<T>` (v14+) |

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

  // Simple cache with BehaviorSubject
  private usersCache$ = new BehaviorSubject<User[] | null>(null);
  private cacheValid = false;

  constructor(private http: HttpClient) {}

  // GET all with caching
  getUsers(forceRefresh = false): Observable<User[]> {
    if (!forceRefresh && this.cacheValid && this.usersCache$.value) {
      return this.usersCache$.asObservable() as Observable<User[]>;
    }

    return this.http.get<User[]>(this.baseUrl).pipe(
      tap(users => {
        this.usersCache$.next(users);
        this.cacheValid = true;
      }),
      shareReplay(1)  // Share among multiple subscribers
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

  // POST
  createUser(userData: CreateUserDto): Observable<User> {
    return this.http.post<User>(this.baseUrl, userData).pipe(
      tap(() => this.invalidateCache())
    );
  }

  // PUT
  updateUser(id: string, userData: UpdateUserDto): Observable<User> {
    return this.http.put<User>(`${this.baseUrl}/${id}`, userData).pipe(
      tap(() => this.invalidateCache())
    );
  }

  // PATCH
  patchUser(id: string, partialData: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.baseUrl}/${id}`, partialData).pipe(
      tap(() => this.invalidateCache())
    );
  }

  // DELETE
  deleteUser(id: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(
      tap(() => this.invalidateCache())
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
        observe: 'events'  // Get upload progress
      }
    ).pipe(
      // Filter to only get the response
      filter(event => event.type === HttpEventType.Response),
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
      switchMap(() => this.userService.getUsers(true)),  // Refresh list
      finalize(() => this.creating = false)
    ).subscribe({
      next: users => this.users$ = of(users),
      error: err => this.error = err.message
    });
  }
}
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
// CREATION OPERATORS
// ============================================

// From Promise (what React devs know)
const promise$ = from(fetch('/api/users').then(r => r.json()));

// From array
const array$ = from([1, 2, 3, 4, 5]);

// From event
const click$ = fromEvent(document, 'click');

// Timer / Interval
const timer$ = timer(1000);  // Emit once after 1s
const interval$ = interval(1000);  // Emit every 1s

// ============================================
// SUBJECTS (Observable + Observer)
// ============================================

// Subject - Basic pub/sub
const subject = new Subject<string>();
subject.next('Hello');  // Nothing happens (no subscribers)
subject.subscribe(val => console.log(val));
subject.next('World');  // Logs: "World"

// BehaviorSubject - Has current value, emits to new subscribers
const behavior = new BehaviorSubject<number>(0);  // Initial value required
console.log(behavior.value);  // 0 (sync access)
behavior.subscribe(val => console.log('Sub1:', val));  // Immediately logs: 0
behavior.next(1);  // Logs: 1
behavior.subscribe(val => console.log('Sub2:', val));  // Immediately logs: 1 (current value)

// ReplaySubject - Replays N values to new subscribers
const replay = new ReplaySubject<number>(3);  // Buffer last 3 values
replay.next(1); replay.next(2); replay.next(3); replay.next(4);
replay.subscribe(val => console.log(val));  // Logs: 2, 3, 4

// ============================================
// TRANSFORMATION OPERATORS
// ============================================

// map - Transform each value
of(1, 2, 3).pipe(
  map(x => x * 10)
).subscribe(console.log);  // 10, 20, 30

// filter - Only emit matching values
of(1, 2, 3, 4, 5).pipe(
  filter(x => x % 2 === 0)
).subscribe(console.log);  // 2, 4

// tap - Side effects without modifying stream
of(1, 2, 3).pipe(
  tap(x => console.log('Before:', x)),
  map(x => x * 10),
  tap(x => console.log('After:', x))
).subscribe();

// scan - Like reduce, but emits each accumulated value
of(1, 2, 3, 4, 5).pipe(
  scan((acc, val) => acc + val, 0)
).subscribe(console.log);  // 1, 3, 6, 10, 15

// ============================================
// FLATTENING OPERATORS (CRITICAL!)
// ============================================

// switchMap - Cancel previous, switch to new (MOST COMMON)
// Use for: Search, navigation, latest value matters
searchInput$.pipe(
  debounceTime(300),
  switchMap(query => this.http.get(`/search?q=${query}`))
  // If user types again before response, previous request is cancelled
).subscribe(results => this.results = results);

// mergeMap - Run all in parallel
// Use for: Independent requests, order doesn't matter
userIds$.pipe(
  mergeMap(id => this.http.get(`/users/${id}`))
  // All requests run simultaneously
).subscribe(user => this.users.push(user));

// concatMap - Run sequentially, maintain order
// Use for: Order matters, queue operations
saveOperations$.pipe(
  concatMap(data => this.http.post('/save', data))
  // Each save waits for previous to complete
).subscribe();

// exhaustMap - Ignore new while processing
// Use for: Prevent double-submit, button clicks
submitButton$.pipe(
  exhaustMap(() => this.http.post('/submit', this.form.value))
  // Clicks while request is pending are ignored
).subscribe();

// ============================================
// COMBINATION OPERATORS
// ============================================

// combineLatest - Emit when any source emits (after all have emitted once)
const user$ = this.store.select(selectUser);
const settings$ = this.store.select(selectSettings);

combineLatest([user$, settings$]).pipe(
  map(([user, settings]) => ({ user, settings }))
).subscribe(data => this.viewModel = data);

// forkJoin - Wait for all to complete, emit final values
forkJoin({
  user: this.http.get<User>('/user'),
  posts: this.http.get<Post[]>('/posts'),
  comments: this.http.get<Comment[]>('/comments')
}).subscribe(({ user, posts, comments }) => {
  // All three requests completed
});

// merge - Combine multiple streams into one
merge(
  fromEvent(saveBtn, 'click').pipe(map(() => 'save')),
  fromEvent(deleteBtn, 'click').pipe(map(() => 'delete'))
).subscribe(action => this.handleAction(action));

// ============================================
// ERROR HANDLING
// ============================================

this.http.get('/api/data').pipe(
  retry(3),  // Retry up to 3 times on error
  catchError(error => {
    console.error('Error:', error);
    return of([]);  // Return fallback value
    // Or: return throwError(() => error);  // Re-throw
  })
).subscribe();

// retryWhen with exponential backoff
this.http.get('/api/data').pipe(
  retryWhen(errors => errors.pipe(
    scan((retryCount, error) => {
      if (retryCount >= 3) throw error;
      return retryCount + 1;
    }, 0),
    delayWhen(retryCount => timer(Math.pow(2, retryCount) * 1000))
  ))
).subscribe();

// ============================================
// PRACTICAL PATTERNS
// ============================================

// 1. Typeahead Search
@Component({
  template: `<input [formControl]="searchControl">`
})
export class SearchComponent {
  searchControl = new FormControl('');
  results$: Observable<Result[]>;

  constructor(private searchService: SearchService) {
    this.results$ = this.searchControl.valueChanges.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      filter(query => query.length >= 2),
      switchMap(query => this.searchService.search(query).pipe(
        catchError(() => of([]))  // Don't break on error
      )),
      shareReplay(1)  // Share result among template subscriptions
    );
  }
}

// 2. Polling with pause/resume
export class PollingService {
  private pause$ = new BehaviorSubject<boolean>(false);

  data$ = this.pause$.pipe(
    switchMap(paused => paused ? EMPTY : interval(5000).pipe(
      startWith(0),
      switchMap(() => this.http.get('/api/data'))
    )),
    shareReplay(1)
  );

  pause() { this.pause$.next(true); }
  resume() { this.pause$.next(false); }
}

// 3. Optimistic updates
updateUser(user: User): Observable<User> {
  const optimistic$ = of(user);  // Immediately return optimistic value
  const server$ = this.http.put<User>(`/users/${user.id}`, user).pipe(
    catchError(error => {
      this.notificationService.error('Update failed, reverting...');
      return this.http.get<User>(`/users/${user.id}`);  // Revert to server state
    })
  );

  return merge(
    optimistic$,
    server$.pipe(delay(0))  // Server response comes after optimistic
  );
}

// 4. Caching with expiry
private cache$ = new Map<string, Observable<any>>();
private cacheTime = 5 * 60 * 1000;  // 5 minutes

getData(key: string): Observable<Data> {
  if (!this.cache$.has(key)) {
    const request$ = this.http.get<Data>(`/api/${key}`).pipe(
      shareReplay({ bufferSize: 1, refCount: true }),
      timeout(this.cacheTime),
      catchError(() => {
        this.cache$.delete(key);  // Remove from cache on expiry/error
        return this.getData(key);  // Retry
      })
    );
    this.cache$.set(key, request$);
  }
  return this.cache$.get(key)!;
}

// 5. Coordinated loading state
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
  private load$ = new Subject<void>();

  vm$ = this.load$.pipe(
    switchMap(() => this.dataService.getData().pipe(
      map(data => ({ loading: false, error: null, data })),
      startWith({ loading: true, error: null, data: null }),
      catchError(error => of({ loading: false, error: error.message, data: null }))
    ))
  );

  ngOnInit() {
    this.load$.next();
  }

  refresh() {
    this.load$.next();
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
private destroy$ = new Subject<void>();

ngOnInit() {
  this.service.data$
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
