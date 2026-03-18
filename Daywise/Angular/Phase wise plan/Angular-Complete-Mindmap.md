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
