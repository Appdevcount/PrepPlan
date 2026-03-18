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

*Generated from Phases 1–24 — Angular Complete Reference*
