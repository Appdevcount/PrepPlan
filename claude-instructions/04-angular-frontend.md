# 04 — Angular Frontend Development

> **Mental Model:** Angular is a city with strict zoning laws.
> Components are buildings (UI), Services are utilities (data/logic),
> Signals are whiteboards (current state), Observables are rivers (streams over time).
> Never mix zones — no HTTP calls in components, no UI logic in services.

---

## Folder Structure

```
src/
├── app/
│   ├── core/                          ← Singleton services, interceptors, guards
│   │   ├── interceptors/
│   │   │   ├── auth.interceptor.ts
│   │   │   └── error.interceptor.ts
│   │   ├── guards/
│   │   │   ├── auth.guard.ts
│   │   │   └── role.guard.ts
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   └── notification.service.ts
│   │   └── core.module.ts             (or provideCore() for standalone)
│   │
│   ├── shared/                        ← Reusable components, pipes, directives
│   │   ├── components/
│   │   │   ├── spinner/
│   │   │   └── error-banner/
│   │   ├── pipes/
│   │   └── directives/
│   │
│   ├── features/                      ← Feature modules (lazy loaded)
│   │   ├── orders/
│   │   │   ├── components/
│   │   │   │   ├── order-list/
│   │   │   │   │   ├── order-list.component.ts
│   │   │   │   │   ├── order-list.component.html
│   │   │   │   │   └── order-list.component.scss
│   │   │   │   └── order-detail/
│   │   │   ├── services/
│   │   │   │   └── order.service.ts
│   │   │   ├── models/
│   │   │   │   └── order.model.ts
│   │   │   ├── store/                 (NgRx if needed)
│   │   │   └── orders.routes.ts       (standalone routing)
│   │   └── customers/
│   │
│   ├── app.routes.ts                  ← Root routing with lazy-loaded features
│   └── app.config.ts                  ← provideRouter, provideHttpClient, etc.
│
├── environments/
└── assets/
```

---

## Component Architecture — Standalone, Signals-First

```typescript
// ── RULE: Standalone components (no NgModule boilerplate) ────────────────────
// ── RULE: Signals for local state, RxJS for async data streams ───────────────
// ── RULE: OnPush change detection always — explicit reactivity ───────────────

@Component({
  selector: 'app-order-list',
  standalone: true,                                    // WHY standalone: no module needed
  changeDetection: ChangeDetectionStrategy.OnPush,     // WHY OnPush: only re-render when
                                                       //   inputs change or signals update.
                                                       //   Default CD checks whole tree — expensive.
  imports: [CommonModule, RouterLink, CurrencyPipe],
  templateUrl: './order-list.component.html'
})
export class OrderListComponent {
  private orderService = inject(OrderService);         // WHY inject(): cleaner than constructor DI

  // ── Signals — synchronous local state ────────────────────────────────────
  selectedOrderId = signal<string | null>(null);       // WHY signal: template reads synchronously
  filterStatus    = signal<string>('all');

  // ── toSignal — bridge HTTP Observable → Signal ───────────────────────────
  // WHY toSignal: no subscribe in component, no takeUntil, no memory leak.
  //   Angular manages the subscription lifecycle automatically.
  orders = toSignal(
    this.orderService.getOrders().pipe(
      catchError(() => of([] as Order[]))              // fallback prevents error in template
    ),
    { initialValue: [] as Order[] }                    // WHY initialValue: signal always has a value
  );

  // ── computed — derived state, auto-memoized ──────────────────────────────
  // WHY computed: recalculates ONLY when orders() or filterStatus() changes.
  //   Plain getter recalculates on every CD cycle.
  filteredOrders = computed(() => {
    const status = this.filterStatus();
    return status === 'all'
      ? this.orders()
      : this.orders().filter(o => o.status === status);
  });

  orderCount = computed(() => this.filteredOrders().length);

  // ── effect — side effects that react to signal changes ───────────────────
  constructor() {
    // WHY in constructor: effect() must run inside an injection context
    effect(() => {
      // Reads selectedOrderId() — becomes a dependency automatically
      const id = this.selectedOrderId();
      if (id) {
        console.log(`Order selected: ${id}`);   // e.g. analytics, localStorage sync
      }
    });
  }

  selectOrder(id: string): void {
    this.selectedOrderId.set(id);                     // signal.set() triggers computed/effects
  }

  setFilter(status: string): void {
    this.filterStatus.set(status);                    // filteredOrders recomputes automatically
  }
}
```

---

## Service Pattern — Data Access

```typescript
// ── RULE: Services own ALL HTTP calls. Components never use HttpClient directly.
// ── RULE: Service returns Observable<T>, not Promise<T> — composable with RxJS.
// ── RULE: catchError in service translates HttpErrorResponse → domain Error.

@Injectable({ providedIn: 'root' })
export class OrderService {
  // inject() over constructor — works in any injection context (including non-class)
  private http   = inject(HttpClient);
  private router = inject(Router);

  getOrders(filter?: OrderFilter): Observable<Order[]> {
    const params = filter ? this.buildParams(filter) : {};
    return this.http.get<Order[]>('/api/v1/orders', { params }).pipe(
      // catchError in service — WHY here:
      //   1. Single place to handle errors for all callers
      //   2. Component receives clean Error, not raw HttpErrorResponse
      //   3. Logging happens once (not per component)
      catchError(this.handleError)
    );
  }

  getById(id: string): Observable<Order> {
    return this.http.get<Order>(`/api/v1/orders/${id}`).pipe(
      catchError(this.handleError)
    );
  }

  createOrder(request: CreateOrderRequest): Observable<OrderCreatedResponse> {
    return this.http.post<OrderCreatedResponse>('/api/v1/orders', request).pipe(
      tap(response => {
        // WHY tap not subscribe: side effect without breaking the stream.
        //   tap lets the caller still subscribe and receive the value.
        console.log('Order created:', response.id);
      }),
      catchError(this.handleError)
    );
  }

  // ── Error translation — HttpErrorResponse → domain Error ─────────────────
  private handleError = (err: HttpErrorResponse): Observable<never> => {
    // status 0 = network error (no internet, CORS, DNS failure)
    const message = err.status === 0
      ? 'Network error — please check your connection'
      : err.error?.message ?? `Server error (${err.status})`;

    // throwError returns an Observable that immediately errors
    // WHY arrow function not method: preserves `this` context when used as operator
    return throwError(() => new Error(message));
  };
}
```

---

## RxJS Operator Reference (with WHY)

```typescript
// ── Use these operators — know WHY each one exists ───────────────────────────

// switchMap — cancel previous inner Observable, start new one
// WHY: search-as-you-type. User types "angu" — previous HTTP call for "ang" is CANCELLED.
//   Without switchMap (using mergeMap): all calls complete, responses arrive out of order.
searchTerm$.pipe(
  debounceTime(300),          // wait 300ms after user stops typing
  distinctUntilChanged(),     // skip if value is the same as last
  switchMap(term =>           // cancel previous, start new HTTP
    this.http.get<string[]>(`/api/search?q=${term}`).pipe(
      catchError(() => of([]))  // WHY per-inner: prevents switchMap stream dying on error
    )
  )
)

// mergeMap — run all inner Observables concurrently, don't cancel
// WHY: fire-and-forget parallel operations (logging, analytics pings)
//   where order doesn't matter and you want all to complete
clicks$.pipe(
  mergeMap(event => this.analyticsService.track(event))
)

// concatMap — queue inner Observables, run one at a time in order
// WHY: sequential operations where order matters (file upload chunks, ordered commands)
uploadQueue$.pipe(
  concatMap(file => this.uploadService.upload(file))
)

// exhaustMap — ignore new Observables while current one is running
// WHY: prevent duplicate form submits. Button click fires HTTP — ignore subsequent
//   clicks until the first request completes.
submitButton$.pipe(
  exhaustMap(() => this.orderService.createOrder(formValue))
)

// combineLatest — emit when ALL sources have emitted; re-emit when ANY changes
// WHY: build a view model from multiple independent signals/streams
//   Dashboard driven by user preferences + live data — re-renders on either change
combineLatest([
  this.store.select(selectUser),
  this.store.select(selectSettings),
  this.http.get('/api/dashboard')
]).pipe(
  map(([user, settings, data]) => ({ user, settings, data }))
)

// takeUntilDestroyed — auto-unsubscribe when component is destroyed
// WHY: replaces takeUntil(destroy$) + Subject boilerplate.
//   Must be called in injection context (constructor or field initializer).
private destroy$ = inject(DestroyRef);
this.someStream$.pipe(
  takeUntilDestroyed(this.destroy$)   // no ngOnDestroy needed
).subscribe(...)

// shareReplay(1) — share one HTTP call among multiple subscribers
// WHY: without it, every subscriber triggers a new HTTP call.
//   With shareReplay(1): first subscriber makes the call; others get the cached result.
readonly config$ = this.http.get<Config>('/api/config').pipe(
  shareReplay(1)   // WHY 1: keep last emission in buffer for late subscribers
);
```

---

## Guards — canActivate vs canLoad

```typescript
// ┌──────────────────────────────────────────────────────────────────────────┐
// │  Guard         │ When it runs               │ Use for                    │
// ├──────────────────────────────────────────────────────────────────────────┤
// │ canActivate    │ Every navigation attempt    │ Auth check on every visit  │
// │                │ to the route               │ Catches token expiry       │
// ├──────────────────────────────────────────────────────────────────────────┤
// │ canLoad        │ Only when lazy module is   │ Prevent bundle DOWNLOAD    │
// │ (canMatch)     │ first downloaded           │ for unauthorized users     │
// │                │ Does NOT re-run            │                            │
// └──────────────────────────────────────────────────────────────────────────┘
// RULE: Use canActivate for auth. Use canLoad/canMatch to prevent bundle download.
//       Never use canLoad alone — it won't catch token expiry after first load.

// canActivate — functional guard (Angular 15+, preferred over class-based)
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router      = inject(Router);

  return authService.isAuthenticated$.pipe(
    take(1),              // WHY take(1): guard must complete — streams don't complete on their own
    map(isAuth => {
      if (isAuth) return true;

      // UrlTree redirect — cleaner than router.navigate() in a guard
      // WHY UrlTree: Angular handles the navigation internally, no race conditions
      // returnUrl: remembers where user was trying to go → redirects after login
      return router.createUrlTree(['/login'], {
        queryParams: { returnUrl: state.url }
      });
    })
  );
};

// Role guard with ActivatedRouteSnapshot
export const roleGuard: CanActivateFn = (route) => {
  const store  = inject(Store);
  const router = inject(Router);

  // route.data['roles'] — roles defined in the route config:
  //   { path: 'admin', canActivate: [roleGuard], data: { roles: ['Admin'] } }
  const requiredRoles: string[] = route.data['roles'] ?? [];

  return store.select(selectCurrentUser).pipe(
    take(1),   // WHY take(1): same reason — guard must emit once and complete
    map(user => {
      if (!user) return router.createUrlTree(['/login']);

      // Check if user has at least one required role
      const hasRole = requiredRoles.some(role => user.roles.includes(role));
      return hasRole ? true : router.createUrlTree(['/forbidden']);
    })
  );
};
```

---

## HTTP Interceptors

```typescript
// ── Auth Interceptor — attach JWT to every outgoing request ──────────────────
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getAccessToken();

  // WHY clone: HttpRequest is immutable — must clone to modify headers
  const authReq = token
    ? req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
    : req;   // pass through without header if no token (public endpoints)

  return next(authReq);
};

// ── Error Interceptor — centralized HTTP error handling ──────────────────────
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router  = inject(Router);
  const toastr  = inject(NotificationService);

  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      switch (err.status) {
        case 401:
          // WHY navigate not alert: 401 means token expired — send to login
          router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
          break;
        case 403:
          // 403 = authenticated but not authorized — show forbidden page
          router.navigate(['/forbidden']);
          break;
        case 429:
          toastr.warn('Too many requests. Please slow down.');
          break;
        case 0:
          toastr.error('Network error — check your connection');
          break;
        default:
          // 5xx errors — show generic message, log trace ID
          if (err.status >= 500)
            toastr.error(`Server error (${err.headers.get('X-Correlation-Id') ?? 'unknown'})`);
      }
      return throwError(() => err);   // re-throw so component can also react if needed
    })
  );
};

// Register in app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor, errorInterceptor])
      // WHY withInterceptors (functional): replaces HTTP_INTERCEPTORS multi-provider.
      //   Order matters: authInterceptor runs first (attaches token), then error handler.
    )
  ]
};
```

---

## Reactive Forms Pattern

```typescript
@Component({ ... })
export class CreateOrderFormComponent {
  private fb = inject(FormBuilder);
  private orderService = inject(OrderService);
  private router = inject(Router);
  private destroy$ = inject(DestroyRef);

  // WHY nonNullable: validators ensure these are never null.
  //   Without nonNullable, TypeScript types each control as T | null.
  form = this.fb.nonNullable.group({
    customerId: ['', [Validators.required, Validators.minLength(36)]],
    notes: [''],   // optional — no validators
    items: this.fb.array(
      [this.createItemGroup()],
      Validators.minLength(1)   // WHY array validator: at least one item required
    )
  });

  // ── Signals for UI state ──────────────────────────────────────────────────
  submitting = signal(false);
  submitError = signal<string | null>(null);

  get items(): FormArray { return this.form.controls.items; }

  createItemGroup(): FormGroup {
    return this.fb.nonNullable.group({
      productId: ['', Validators.required],
      quantity:  [1,  [Validators.required, Validators.min(1)]]
    });
  }

  addItem(): void { this.items.push(this.createItemGroup()); }

  removeItem(index: number): void {
    if (this.items.length > 1)   // WHY: form validator requires at least one item
      this.items.removeAt(index);
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();   // WHY: shows validation errors on all fields
      return;
    }

    this.submitting.set(true);
    this.submitError.set(null);

    this.orderService.createOrder(this.form.getRawValue()).pipe(
      takeUntilDestroyed(this.destroy$),
      finalize(() => this.submitting.set(false))   // always reset loading
    ).subscribe({
      next: response => this.router.navigate(['/orders', response.id]),
      error: (err: Error) => this.submitError.set(err.message)
    });
  }
}
```
