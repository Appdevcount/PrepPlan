# RxJS Error Handling — `subscribe({ error })` vs `pipe(catchError())`

> **Mental Model:**
> `catchError` is a **surgeon inside the operating room** — it intercepts the problem mid-stream,
> can heal it (return a fallback Observable), and lets the pipeline continue or gracefully end.
> `subscribe({ error })` is the **ambulance at the exit** — it receives the corpse after the
> stream has already died. You can log and react, but you cannot resurrect the stream.

---

## Table of Contents
1. [The Core Difference — One Sentence](#1-the-core-difference)
2. [What Happens to the Stream After Each?](#2-what-happens-to-the-stream-after-each)
3. [Anatomy Diagrams](#3-anatomy-diagrams)
4. [Deep Dive — `subscribe({ error })`](#4-subscribe-error)
5. [Deep Dive — `pipe(catchError())`](#5-pipecatcherror)
6. [Side-by-Side Code Comparison](#6-side-by-side-code-comparison)
7. [Decision Guide — When to Use Which](#7-decision-guide)
8. [Common Patterns (Beginner → Expert)](#8-common-patterns)
9. [Combining Both — The Right Architecture](#9-combining-both)
10. [The 5 Most Common Mistakes](#10-the-5-most-common-mistakes)
11. [Signals — Angular's Reactive Primitive](#11-signals)
12. [Interview Q&A](#12-interview-qa)

---

## 1. The Core Difference

```
                        ┌──────────────────────────────────────────────────────┐
                        │                                                      │
                        │  subscribe({ error })  =  terminal handler           │
                        │                           runs AFTER stream dies      │
                        │                           cannot recover the stream   │
                        │                           cannot return a fallback    │
                        │                                                      │
                        │  pipe(catchError())    =  recovery operator           │
                        │                           runs INSIDE the pipe        │
                        │                           CAN return a new Observable │
                        │                           CAN let stream survive      │
                        │                                                      │
                        └──────────────────────────────────────────────────────┘
```

| Aspect | `subscribe({ error })` | `pipe(catchError())` |
|---|---|---|
| Where it runs | **Outside** the pipe — last stop | **Inside** the pipe — mid-stream |
| Stream alive after? | **No** — stream is dead | **Yes** — if you return a new Observable |
| Can return fallback? | **No** — void return only | **Yes** — return `of([])`, `EMPTY`, etc. |
| Can retry? | **No** | **Yes** — call `retry()` before or inside |
| Scope | This one subscription only | Reusable — stays in the service pipe |
| `complete()` fires after? | **No** — error and complete are mutually exclusive | Depends — if you return `EMPTY`, complete fires |
| Use for | Logging, UI error state, cleanup | Recovery, fallback, retry, transformation |

---

## 2. What Happens to the Stream After Each?

```
══════════════════════════════════════════════════════════════════════════
 PATH 1 — Only subscribe({ error }) — NO catchError in pipe
══════════════════════════════════════════════════════════════════════════

  source$  ──── next(1) ──── next(2) ──── ✗ HTTP 500 error
                                                │
                                    pipe passes error through unchanged
                                                │
                                     subscribe error callback fires
                                                │
                                      Stream is DEAD. Done.
                                      complete() will NOT fire.
                                      next() will NOT fire again.

══════════════════════════════════════════════════════════════════════════
 PATH 2 — catchError returns of(fallback) — stream SURVIVES
══════════════════════════════════════════════════════════════════════════

  source$  ──── next(1) ──── next(2) ──── ✗ HTTP 500 error
                                                │
                                  catchError intercepts the error HERE
                                  returns of([])  ← new Observable
                                                │
                               next([]) fires in subscribe
                               complete() fires  ← stream ended cleanly
                               subscribe's error callback NEVER fires

══════════════════════════════════════════════════════════════════════════
 PATH 3 — catchError returns EMPTY — stream ends silently
══════════════════════════════════════════════════════════════════════════

  source$  ──── next(1) ──── next(2) ──── ✗ HTTP 500 error
                                                │
                                  catchError returns EMPTY
                                                │
                               next() fires 0 times
                               complete() fires immediately
                               error callback NEVER fires
                               WHY: EMPTY is an Observable that completes
                                    with zero emissions

══════════════════════════════════════════════════════════════════════════
 PATH 4 — catchError re-throws — error still reaches subscribe
══════════════════════════════════════════════════════════════════════════

  source$  ──── ✗ HTTP 500 error
                      │
          catchError intercepts, logs it, re-throws
          return throwError(() => error)
                      │
          subscribe error callback fires
          Stream is DEAD.
          WHY re-throw: you want to log/transform the error in the service
            but still let the component's subscribe handle the UI response
```

---

## 3. Anatomy Diagrams

### `subscribe({ error })` — what it is

```typescript
observable$.pipe(
  // ... operators ...
).subscribe({
  next:     value  => { /* called per emitted value    */ },
  error:    err    => { /* called ONCE if stream errors  */ },
  //                     ↑ stream is DEAD after this fires
  //                     cannot return anything meaningful
  //                     cannot affect what happens upstream
  complete: ()     => { /* called ONCE when stream ends  */ },
  //                     ↑ NEVER called if error fired first
});
//
// subscribe() returns a Subscription object.
// The error callback is a void function — return value is ignored.
// You CANNOT swap in a new Observable here.
```

### `catchError()` — what it is

```typescript
observable$.pipe(
  // ... operators before ...

  catchError((err: HttpErrorResponse, caught: Observable<T>) => {
    //         ↑ the error object           ↑ the original source Observable
    //                                        use `caught` to RETRY the original

    // You MUST return an Observable here — three choices:
    //  1. of(fallbackValue)           → emit fallback, complete cleanly
    //  2. EMPTY                       → complete with zero emissions
    //  3. throwError(() => err)       → re-throw (error reaches subscribe)
    //  4. caught.pipe(take(3))        → retry the original source Observable

    return of(fallbackValue);  // ← stream survives, next(fallbackValue) fires
  }),

  // ... operators after (run on fallbackValue, not on the error) ...
).subscribe({ next, error, complete });
//
// catchError() is an operator — it sits in the pipe and returns a new Observable.
// The callback MUST return an Observable — TypeScript enforces this.
```

---

## 4. Deep Dive — `subscribe({ error })`

```typescript
// ─────────────────────────────────────────────────────────────────────────────
// BEGINNER — What subscribe error does
// ─────────────────────────────────────────────────────────────────────────────

this.http.get<User[]>('/api/users').subscribe({
  // next: called when HTTP 2xx response arrives with data
  next: users => {
    this.users = users;
    this.loading = false;
  },

  // error: called when HTTP fails (4xx, 5xx, network timeout, CORS error)
  // WHY handle here: update UI to show error state to the user
  // The err object is HttpErrorResponse for Angular HttpClient errors
  error: (err: HttpErrorResponse) => {
    this.loading = false;
    // err.status     → HTTP status code (404, 500, 0 for network failure)
    // err.message    → human-readable description
    // err.error      → the parsed response body (server's error payload)
    this.errorMessage = err.status === 404
      ? 'Users not found'
      : 'Something went wrong. Please try again.';

    // IMPORTANT: After this callback fires:
    //   • next() will NEVER fire again
    //   • complete() will NEVER fire
    //   • The subscription is automatically cleaned up — no memory leak
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// WHAT YOU CANNOT DO in subscribe error (common misconceptions)
// ─────────────────────────────────────────────────────────────────────────────

this.http.get('/api/data').subscribe({
  error: err => {
    // ❌ WRONG — returning of([]) here does NOTHING
    // The return value of this callback is completely ignored by RxJS
    return of([]);   // ← has no effect

    // ❌ WRONG — you cannot "restart" the Observable from here
    // The stream is already dead by the time this callback runs

    // ✅ CORRECT — you can only react: log, update UI state, navigate
    this.error = err.message;
    this.router.navigate(['/error']);
  }
});
```

---

## 5. Deep Dive — `pipe(catchError())`

```typescript
import { catchError, of, EMPTY, throwError, retry, retryWhen, timer } from 'rxjs';
import { HttpErrorResponse } from '@angular/common/http';

// ─────────────────────────────────────────────────────────────────────────────
// PATTERN 1 — Return fallback value (stream survives, next fires with fallback)
// ─────────────────────────────────────────────────────────────────────────────

this.http.get<User[]>('/api/users').pipe(
  // catchError returns of([]) — an Observable that emits [] immediately then completes.
  // WHY: the component's next() handler receives [] and renders an empty list
  //      instead of crashing or showing no data at all.
  // subscribe error callback will NOT fire because catchError swallowed the error.
  catchError((err: HttpErrorResponse) => {
    console.error('Failed to load users:', err.message);
    return of([] as User[]);   // ← fallback empty array; type must match T
  })
).subscribe({
  next: users => this.users = users,  // ← fires with [] if the HTTP call failed
  // error callback will NOT fire — catchError above handled it
  complete: () => this.loading = false  // ← always fires (fallback Observable also completes)
});

// ─────────────────────────────────────────────────────────────────────────────
// PATTERN 2 — Return EMPTY (stream ends silently, next never fires)
// ─────────────────────────────────────────────────────────────────────────────

this.http.get<Config>('/api/config').pipe(
  // EMPTY is an Observable that completes immediately without emitting anything.
  // WHY use EMPTY: when you want to silently skip the error and do nothing —
  //   the component just stays in its current state (no update, no crash).
  // Use when the failed request is optional / non-critical.
  catchError(err => {
    this.logger.warn('Config load failed, using defaults', err);
    return EMPTY;  // ← next() never fires; complete() fires; error() never fires
  })
).subscribe({
  next: config => this.config = config,  // ← NOT called if catchError returned EMPTY
  complete: () => console.log('done')    // ← IS called (EMPTY completes immediately)
});

// ─────────────────────────────────────────────────────────────────────────────
// PATTERN 3 — Re-throw transformed error (error reaches subscribe)
// ─────────────────────────────────────────────────────────────────────────────

this.http.get<Order[]>('/api/orders').pipe(
  // catchError intercepts the raw HttpErrorResponse, extracts a clean message,
  // then re-throws a plain Error so the component doesn't need to know about HTTP.
  // WHY: the SERVICE translates HTTP errors into domain errors (separation of concerns).
  //      The COMPONENT just receives a plain Error in its subscribe error handler.
  catchError((err: HttpErrorResponse) => {
    const message = err.status === 403
      ? 'You do not have permission to view orders'
      : `Failed to load orders (${err.status})`;
    // throwError() — creates an Observable that immediately errors with the given value
    return throwError(() => new Error(message));
    // ↑ subscribe's error callback WILL fire with this clean Error object
  })
).subscribe({
  next: orders => this.orders = orders,
  // error receives our clean Error, not the raw HttpErrorResponse
  error: (err: Error) => this.errorMessage = err.message
});

// ─────────────────────────────────────────────────────────────────────────────
// PATTERN 4 — Retry using the `caught` second argument
// ─────────────────────────────────────────────────────────────────────────────

this.http.get<Data>('/api/data').pipe(
  // catchError's second argument `caught` is the original source Observable.
  // Returning `caught` from catchError re-subscribes to the original — i.e., retries.
  // WHY: retry transient failures (network blip, 503 temporary outage) without the
  //      user seeing an error at all.
  // DANGER: you MUST limit retries — returning `caught` unconditionally = infinite loop.
  catchError((err, caught) => {
    if (this.retryCount < 3 && err.status >= 500) {
      this.retryCount++;
      return caught;  // ← re-subscribes to the original HTTP call
    }
    // After 3 retries, give up and re-throw
    return throwError(() => err);
  })
).subscribe({ next: d => this.data = d, error: e => this.error = e.message });

// ─────────────────────────────────────────────────────────────────────────────
// PATTERN 5 — Use retry() operator BEFORE catchError (cleaner retry)
// ─────────────────────────────────────────────────────────────────────────────

this.http.get<Product[]>('/api/products').pipe(
  // retry(2) — automatically re-subscribes up to 2 times on any error BEFORE
  //            catchError runs. Only if all retries fail does catchError receive it.
  // WHY before catchError: retry handles transient failures silently;
  //     catchError handles the final failure after retries are exhausted.
  retry(2),
  catchError(err => {
    console.error('All 3 attempts failed:', err);
    return of([] as Product[]);
  })
).subscribe(products => this.products = products);
```

---

## 6. Side-by-Side Code Comparison

### Scenario: Load user list, show error message on failure

```typescript
// ══════════════════════════════════════════════════════
// APPROACH A — subscribe({ error }) only
// ══════════════════════════════════════════════════════

loadUsers_A(): void {
  this.http.get<User[]>('/api/users').subscribe({
    next: users => {
      this.users = users;    // ← users is User[] — happy path
      this.loading = false;
    },
    // error handler in subscribe — stream is already dead here
    // WHY it works here: we only need to update UI state (no recovery needed)
    error: (err: HttpErrorResponse) => {
      this.loading = false;
      this.errorMessage = `Error ${err.status}: ${err.message}`;
      // Cannot provide a fallback [] to the template here
      // this.users remains undefined — template must guard against this
    }
    // complete not handled — not needed; loading is reset in both next and error
  });
}

// ══════════════════════════════════════════════════════
// APPROACH B — catchError in pipe, no error in subscribe
// ══════════════════════════════════════════════════════

loadUsers_B(): void {
  this.http.get<User[]>('/api/users').pipe(
    // catchError swallows the error and returns a safe fallback
    // WHY: component ALWAYS receives an array — template never needs to null-guard
    catchError((err: HttpErrorResponse) => {
      this.errorMessage = `Error ${err.status}: ${err.message}`;
      return of([] as User[]);  // ← fallback — next() gets this instead of nothing
    })
  ).subscribe({
    // next ALWAYS fires (either real data or [] fallback)
    next: users => {
      this.users = users;
      this.loading = false;
    }
    // error will NEVER fire — catchError handled it above
    // complete fires after next() — could reset loading here too
  });
}

// ══════════════════════════════════════════════════════
// APPROACH C — Both catchError AND subscribe({ error })
// (recommended for services + components separation)
// ══════════════════════════════════════════════════════

// service.ts — translates HTTP errors to domain errors (no HTTP knowledge leaks out)
getUsers(): Observable<User[]> {
  return this.http.get<User[]>('/api/users').pipe(
    // catchError in service: logs error, transforms to clean domain error, re-throws
    // WHY in service: the component should not know about HttpErrorResponse internals
    catchError((err: HttpErrorResponse) => {
      this.logger.error('getUsers failed', err);
      const msg = err.status === 0
        ? 'No internet connection'
        : `Server error (${err.status})`;
      return throwError(() => new Error(msg));  // clean Error, not HttpErrorResponse
    })
  );
}

// component.ts — handles clean Error from service (no HTTP coupling)
loadUsers_C(): void {
  this.userService.getUsers().subscribe({
    next: users => { this.users = users; this.loading = false; },

    // error receives a clean Error (not HttpErrorResponse) because service transformed it
    // WHY this.loading = false here too: catchError re-threw, so we must reset it
    error: (err: Error) => {
      this.loading = false;
      this.errorMessage = err.message;  // already human-readable from service
    }
  });
}
```

---

## 7. Decision Guide — When to Use Which

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ERROR HANDLING DECISION TREE                           │
└─────────────────────────────────────────────────────────────────────────────┘

Do you need to RECOVER the stream / provide fallback data?
  │
  ├── YES → Use pipe(catchError())
  │           └── What should happen after catchError?
  │                 ├── Show fallback data    → return of(fallbackValue)
  │                 ├── End silently          → return EMPTY
  │                 ├── Retry automatically  → return caught  OR use retry() before
  │                 └── Re-throw cleaner err → return throwError(() => new Error(...))
  │
  └── NO (just react to the failure in the component)
        │
        ├── Do you write this code in a SERVICE?
        │     └── YES → still use catchError to translate HttpErrorResponse to domain error
        │                 then re-throw → component gets clean Error in subscribe({ error })
        │
        └── Simple component-level UI update only?
              └── subscribe({ error }) is sufficient
                    • reset loading spinner
                    • show error banner
                    • log to console
```

| Situation | Recommended approach |
|---|---|
| HTTP call in a service, multiple components use it | `catchError` in service (translate error) |
| Component needs a fallback value if request fails | `catchError` → `of(fallback)` in pipe |
| Optional request — silence failure, continue | `catchError` → `EMPTY` |
| Transient failures (server briefly unavailable) | `retry(n)` + `catchError` |
| Only need to update UI (show error message) | `subscribe({ error })` alone is fine |
| Need both: transform error AND update UI | `catchError` (transform/re-throw) + `subscribe({ error })` |
| Multiple independent requests on one page | `forkJoin` + `catchError` per inner |

---

## 8. Common Patterns (Beginner → Expert)

### BEGINNER — No error handling (never do this in production)

```typescript
// ❌ WRONG — if HTTP fails, nothing happens. User sees loading spinner forever.
// Error goes to the global unhandled error handler (browser console).
ngOnInit() {
  this.http.get<User[]>('/api/users').subscribe(users => {
    this.users = users;
    this.loading = false;
    // If this errors: loading stays true, users stays undefined, no feedback to user
  });
}
```

### BEGINNER — subscribe({ error }) — minimum viable error handling

```typescript
// ✅ CORRECT minimum — always use object form for HTTP calls
ngOnInit() {
  this.http.get<User[]>('/api/users').subscribe({
    next: users => {
      this.users = users;
      this.loading = false;
    },
    // error callback — fired if HTTP returns error or network fails
    // WHY: at minimum you must reset loading and show a message
    error: (err: HttpErrorResponse) => {
      this.loading = false;
      this.errorMessage = 'Failed to load users. Please try again.';
      console.error(err);  // log full error for debugging
    }
  });
}
```

### INTERMEDIATE — catchError in service, object form in component

```typescript
// ─── users.service.ts ────────────────────────────────────────────────────────

@Injectable({ providedIn: 'root' })
export class UsersService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<User[]> {
    return this.http.get<User[]>('/api/users').pipe(

      // catchError in service — WHY here:
      //   1. Keeps HTTP knowledge (HttpErrorResponse) out of components
      //   2. Single place to handle errors for all callers
      //   3. Can log to an error tracking service (Sentry, etc.)
      catchError((err: HttpErrorResponse) => {
        // Log to observability platform — every caller benefits from this
        console.error('[UsersService.getAll]', err.status, err.message);

        // Transform to domain error — component receives simple Error, not HTTP internals
        if (err.status === 0) {
          // status 0 = network error (no internet, CORS, server unreachable)
          return throwError(() => new Error('Network error — check your connection'));
        }
        if (err.status === 403) {
          return throwError(() => new Error('Access denied'));
        }
        // Generic fallback for all other HTTP errors
        return throwError(() => new Error(`Failed to load users (${err.status})`));
      })
    );
  }
}

// ─── users.component.ts ──────────────────────────────────────────────────────

@Component({ /* ... */ })
export class UsersComponent implements OnInit, OnDestroy {
  users: User[] = [];
  loading = false;
  errorMessage: string | null = null;
  private destroy$ = new Subject<void>();

  constructor(private usersService: UsersService) {}

  ngOnInit() {
    this.loading = true;
    this.usersService.getAll().pipe(
      // takeUntil — auto-unsubscribe when component is destroyed
      // WHY: prevents setting this.users / this.loading on a dead component (memory leak + error)
      takeUntil(this.destroy$)
    ).subscribe({
      next: users => {
        this.users = users;
        this.loading = false;
      },
      // Receives clean Error (not HttpErrorResponse) because service transformed it
      // WHY: component only needs the human-readable message — no HTTP coupling
      error: (err: Error) => {
        this.loading = false;
        this.errorMessage = err.message;
      }
    });
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

### EXPERT — Retry + exponential backoff + catchError + subscribe

```typescript
// ─── Exponential backoff helper ──────────────────────────────────────────────

import { Observable, throwError, timer } from 'rxjs';
import { mergeMap, retryWhen, scan, catchError } from 'rxjs/operators';

// Generic retry with exponential backoff — reusable across any Observable
function retryWithBackoff<T>(maxRetries = 3, baseDelayMs = 1000) {
  return (source$: Observable<T>): Observable<T> =>
    source$.pipe(
      // retryWhen — gives you control over WHEN to retry (delay between attempts)
      // WHY over retry(n): retry() retries immediately — hammers an already-struggling server
      //   retryWhen lets you add delays (exponential backoff: 1s, 2s, 4s)
      retryWhen(errors$ =>
        errors$.pipe(
          // scan() tracks attempt count across retries (running accumulator)
          // WHY scan not take: scan lets us check the count AND re-throw after max
          scan((attempts, err) => {
            if (attempts >= maxRetries) {
              // Max retries exceeded — re-throw to exit retryWhen and reach catchError
              throw err;
            }
            return attempts + 1;
          }, 0),
          // delayWhen — dynamic delay: 2^attempt * baseDelay (1s → 2s → 4s)
          // WHY exponential: prevents thundering herd — all clients don't retry simultaneously
          mergeMap(attempt => timer(Math.pow(2, attempt) * baseDelayMs))
        )
      )
    );
}

// ─── Usage in service ─────────────────────────────────────────────────────────

@Injectable({ providedIn: 'root' })
export class OrdersService {
  constructor(private http: HttpClient, private logger: LoggerService) {}

  getOrders(): Observable<Order[]> {
    return this.http.get<Order[]>('/api/orders').pipe(
      // 1. Apply retry with exponential backoff for transient failures
      //    WHY first: retry runs before catchError — only calls catchError after all retries fail
      retryWithBackoff(3, 500),

      // 2. catchError — after all retries failed, handle the final error in service
      //    WHY in service: log once (not per retry), transform to domain error
      catchError((err: HttpErrorResponse) => {
        // Log to error tracking after all retries exhausted
        this.logger.error('getOrders permanently failed', {
          status: err.status,
          url: err.url,
          retries: 3
        });

        // Return domain-specific error type
        if (err.status === 401) {
          return throwError(() => new UnauthorizedError('Session expired'));
        }
        return throwError(() => new ServiceError('orders', err.status, err.message));
      })
    );
  }
}

// ─── Component: observe loading + error + success states ─────────────────────

@Component({
  template: `
    <app-spinner *ngIf="state === 'loading'"></app-spinner>
    <app-error-banner *ngIf="state === 'error'" [message]="errorMessage"></app-error-banner>
    <app-order-list *ngIf="state === 'success'" [orders]="orders"></app-order-list>
  `
})
export class OrdersComponent implements OnInit, OnDestroy {
  orders: Order[] = [];
  state: 'loading' | 'success' | 'error' = 'loading';
  errorMessage = '';
  private destroy$ = new Subject<void>();

  constructor(private ordersService: OrdersService) {}

  ngOnInit() {
    this.ordersService.getOrders().pipe(
      takeUntil(this.destroy$)
    ).subscribe({
      // next — all retries succeeded or first attempt worked
      next: orders => {
        this.orders = orders;
        this.state = 'success';
      },
      // error — all retries failed, catchError re-threw a domain error
      // WHY handle here and not in catchError: component owns UI state transitions
      error: (err: ServiceError) => {
        this.state = 'error';
        this.errorMessage = err instanceof UnauthorizedError
          ? 'Please log in again'
          : err.message;
      }
      // complete fires after next — not handled here (state already set to 'success')
    });
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

---

## 9. Combining Both — The Right Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                   LAYERED ERROR HANDLING                            │
│                                                                     │
│  HTTP call                                                          │
│       │                                                             │
│       ▼                                                             │
│  pipe(catchError)  ←── SERVICE LAYER                               │
│       │  • log to monitoring                                        │
│       │  • transform HttpErrorResponse → domain Error              │
│       │  • decide: fallback? retry? re-throw?                      │
│       │                                                             │
│       ▼                                                             │
│  subscribe({ error }) ←── COMPONENT LAYER                         │
│       • update UI state (loading, error, success)                  │
│       • show user-friendly message                                  │
│       • navigate if needed (e.g. 401 → /login)                    │
└─────────────────────────────────────────────────────────────────────┘
```

```typescript
// ─── This architecture in code ────────────────────────────────────────────────

// SERVICE: responsible for data access + error translation
getProduct(id: string): Observable<Product> {
  return this.http.get<Product>(`/api/products/${id}`).pipe(
    retry(1),                           // silent retry once for transient failures
    catchError((err: HttpErrorResponse) => {
      this.analytics.track('product_load_error', { id, status: err.status });
      return throwError(() => this.mapError(err));  // translate to domain error
    })
  );
}

private mapError(err: HttpErrorResponse): Error {
  switch (err.status) {
    case 404: return new NotFoundError(`Product ${id} does not exist`);
    case 403: return new ForbiddenError('You cannot view this product');
    default:  return new Error(`Failed to load product (${err.status})`);
  }
}

// COMPONENT: responsible for UI state only
loadProduct(): void {
  this.loading = true;
  this.productService.getProduct(this.id).pipe(
    takeUntil(this.destroy$),
    // finalize — runs regardless of success OR error
    // WHY finalize instead of resetting in both next and error:
    //   single place to guarantee loading=false, no risk of forgetting
    finalize(() => this.loading = false)
  ).subscribe({
    next: product => this.product = product,

    // error — already translated by service, component just updates UI
    error: (err: Error) => {
      this.errorMessage = err.message;
      if (err instanceof ForbiddenError) {
        this.router.navigate(['/403']);
      }
    }
  });
}
```

---

## 10. The 5 Most Common Mistakes

### Mistake 1 — Returning value from subscribe error (no effect)

```typescript
// ❌ WRONG — return value of subscribe error callback is IGNORED by RxJS
subscribe({
  error: err => {
    return of([]);  // ← does NOTHING. Stream is already dead.
  }
});

// ✅ CORRECT — put the fallback inside catchError
.pipe(catchError(err => of([])))
.subscribe({ next: data => this.data = data });
```

### Mistake 2 — Forgetting catchError in long-lived streams

```typescript
// ❌ WRONG — if the WebSocket errors once, the whole stream dies permanently
// User has to refresh the page to get updates again
this.webSocket.messages$.pipe(
  takeUntil(this.destroy$)
).subscribe(msg => this.messages.push(msg));

// ✅ CORRECT — catchError + EMPTY prevents permanent stream death
// But for long-lived streams, you may need to reconnect — see retryWhen
this.webSocket.messages$.pipe(
  catchError(err => {
    console.error('WebSocket error — attempting reconnect', err);
    return EMPTY;  // or: return this.webSocket.reconnect()
  }),
  takeUntil(this.destroy$)
).subscribe(msg => this.messages.push(msg));
```

### Mistake 3 — catchError position matters in the pipe

```typescript
// ❌ WRONG — catchError BEFORE the operator that might throw
// The error from map() will NOT be caught because catchError runs before map
.pipe(
  catchError(err => of('fallback')),  // ← this runs first, sees no error
  map(value => value.someUndefinedProperty.name)  // ← throws AFTER catchError
)

// ✅ CORRECT — catchError AFTER the operator that might throw
.pipe(
  map(value => value.someUndefinedProperty.name),  // ← might throw
  catchError(err => of('fallback'))  // ← catches the above throw
)
```

### Mistake 4 — Nested subscribes instead of catchError

```typescript
// ❌ WRONG — nested subscribes (callback hell), inner errors unhandled
this.userService.getUser().subscribe(user => {
  this.postsService.getPosts(user.id).subscribe(posts => {
    this.posts = posts;
    // If getPosts errors, outer subscribe's error never fires — it's a different subscription
  });
});

// ✅ CORRECT — flatten with switchMap + single catchError covers the whole chain
this.userService.getUser().pipe(
  switchMap(user => this.postsService.getPosts(user.id)),
  // catchError covers both getUser AND getPosts errors — single handler
  catchError(err => {
    this.errorMessage = err.message;
    return EMPTY;
  })
).subscribe(posts => this.posts = posts);
```

### Mistake 5 — Not resetting loading state on error

```typescript
// ❌ WRONG — if HTTP errors, loading stays true forever (spinner never hides)
ngOnInit() {
  this.loading = true;
  this.http.get('/api/data').subscribe({
    next: data => {
      this.data = data;
      this.loading = false;  // ← only resets on success
    }
    // No error handler — loading never resets on failure
  });
}

// ✅ CORRECT option A — finalize() resets loading in BOTH paths
ngOnInit() {
  this.loading = true;
  this.http.get('/api/data').pipe(
    // finalize — like finally{} — runs after next+complete OR after error
    finalize(() => this.loading = false)  // ← guaranteed to run regardless
  ).subscribe({
    next: data => this.data = data,
    error: err => this.errorMessage = err.message
  });
}

// ✅ CORRECT option B — handle in both next and error explicitly
ngOnInit() {
  this.loading = true;
  this.http.get('/api/data').subscribe({
    next: data => { this.data = data; this.loading = false; },
    error: err  => { this.errorMessage = err.message; this.loading = false; }
  });
}
```

---

## 11. Signals — Angular's Reactive Primitive

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
const count = signal(0);          // WritableSignal<number>

count();           // READ  — call it like a function → returns current value (0)
count.set(5);      // WRITE — replace the value entirely
count.update(n => n + 1);  // UPDATE — derive new value from current (like setState)
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
// IMPORTANT: effects run at least once immediately (like useEffect with no deps but reactive).
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
import { catchError, of } from 'rxjs';

interface Product { id: number; name: string; price: number; }

@Component({
  selector: 'app-products',
  standalone: true,
  template: `
    <!-- Signals are read directly in templates — no async pipe needed -->
    <!-- WHY no async pipe: signals are synchronous, always have a value -->

    <p *ngIf="loading()">Loading...</p>

    <!-- errorMessage() reads the signal — template re-renders only when it changes -->
    <p *ngIf="errorMessage()" class="error">{{ errorMessage() }}</p>

    <!-- items in cart — derived via computed, updates automatically -->
    <p>Cart: {{ cartCount() }} items | Total: {{ cartTotal() | currency }}</p>

    <ul>
      <!-- products() reads the signal — only re-renders this list when products change -->
      <li *ngFor="let p of products()">
        {{ p.name }} — {{ p.price | currency }}
        <button (click)="addToCart(p)">Add</button>
      </li>
    </ul>

    <button (click)="clearCart()">Clear Cart</button>
  `
})
export class ProductsComponent implements OnInit {

  // ── Writable signals — replace plain class fields ────────────────────────
  // WHY signal over plain field: Angular tracks reads in templates automatically
  //   and only re-renders this component when these specific values change.
  //   With plain fields + zone.js, Angular re-checks the WHOLE component tree.
  products   = signal<Product[]>([]);   // starts empty, filled after HTTP call
  loading    = signal(false);           // tracks HTTP in-flight state
  errorMessage = signal<string | null>(null);  // null = no error
  cart       = signal<Product[]>([]);   // items added to cart

  // ── Computed signals — derived state, auto-memoized ─────────────────────
  // WHY computed: recalculates only when cart() changes, not on every render cycle
  cartCount = computed(() => this.cart().length);
  cartTotal = computed(() =>
    // cart() — reading this signal makes cartTotal depend on cart
    this.cart().reduce((sum, p) => sum + p.price, 0)
  );

  // ── Expensive computed — Angular caches until dependency changes ──────────
  sortedProducts = computed(() =>
    // products() — dependency tracked automatically
    [...this.products()].sort((a, b) => a.price - b.price)
    // WHY spread: computed must not mutate the original signal array
  );

  constructor(private http: HttpClient) {
    // effect() — side effect that syncs cart to localStorage whenever it changes
    // WHY in constructor (injection context): effects must be created inside an
    //   injection context (constructor, field initializer) — NOT in ngOnInit.
    effect(() => {
      // Reading cart() here registers it as a dependency of this effect
      localStorage.setItem('cart', JSON.stringify(this.cart()));
      // WHY: every time user adds/removes from cart, localStorage stays in sync
      // No manual subscribe, no ngOnChanges watcher needed
    });
  }

  ngOnInit(): void {
    this.loadProducts();
  }

  // ── HTTP call — still uses Observable/subscribe for async operations ──────
  // WHY still Observable here: Signals are synchronous — they cannot represent
  //   an HTTP request that hasn't completed yet. Use Observable for async work,
  //   then push the result INTO a signal once data arrives.
  loadProducts(): void {
    this.loading.set(true);       // signal.set() — update the value
    this.errorMessage.set(null);  // clear previous error

    this.http.get<Product[]>('/api/products').pipe(
      // catchError in pipe — provides fallback [] if HTTP fails
      // WHY catchError here (not subscribe error): component always gets an array
      //   so sortedProducts() computed never receives null/undefined
      catchError((err) => {
        // Push error message INTO a signal — template reacts automatically
        this.errorMessage.set(`Failed to load products: ${err.message}`);
        return of([] as Product[]);  // fallback empty array
      })
    ).subscribe({
      // next — push HTTP result into the signal
      // WHY .set() here: this is the bridge from async (Observable) to sync (Signal)
      next: products => this.products.set(products),

      // error will NOT fire (catchError above swallowed it and returned of([]))
      // complete fires after next — reset loading flag
      complete: () => this.loading.set(false)
      // WHY in complete not next: finalize/complete guarantees loading resets
      //   even if products.set throws (defensive programming)
    });
  }

  addToCart(product: Product): void {
    // update() — derive new value from current
    // WHY update over set: we need to read the current array to append to it
    this.cart.update(current => [...current, product]);
    // Angular detects cart changed → cartCount and cartTotal recompute automatically
  }

  clearCart(): void {
    this.cart.set([]);  // set() — replace entirely with empty array
    // cartCount() becomes 0, cartTotal() becomes 0 — no manual update needed
  }
}
```

---

### toSignal / toObservable — Bridging the Two Worlds

```typescript
import { toSignal, toObservable } from '@angular/core/rxjs-interop';
import { inject } from '@angular/core';

// ─────────────────────────────────────────────────────────────────────────────
// toSignal() — convert an Observable INTO a Signal
// ─────────────────────────────────────────────────────────────────────────────
// WHY: you have an existing Observable (route params, store selector, HTTP)
//      but want to read it in a template without async pipe.
//      toSignal subscribes internally and unsubscribes when the injection context
//      (component) is destroyed — NO manual takeUntil needed.

@Component({ standalone: true, template: `<p>{{ userName() }}</p>` })
export class ProfileComponent {
  private route  = inject(ActivatedRoute);
  private http   = inject(HttpClient);

  // Convert route queryParamMap Observable → Signal
  // WHY: template reads userName() synchronously, no async pipe needed
  // initialValue: what to return before the Observable emits its first value
  userName = toSignal(
    this.route.queryParamMap.pipe(
      map(params => params.get('name') ?? 'Guest')
    ),
    { initialValue: 'Guest' }
    // WHY initialValue: Signals must always have a value — toSignal needs
    //   a starting value for the moment before the Observable emits
  );

  // toSignal with HTTP Observable — emits once then completes
  // WHY: removes the need for subscribe + manual field assignment in ngOnInit
  // undefined until the HTTP call resolves (use initialValue or check for undefined)
  products = toSignal(
    this.http.get<Product[]>('/api/products').pipe(
      catchError(() => of([] as Product[]))  // fallback inside pipe as usual
    ),
    { initialValue: [] as Product[] }
  );
  // In template: products() → Product[] immediately ([] until HTTP resolves)
}

// ─────────────────────────────────────────────────────────────────────────────
// toObservable() — convert a Signal INTO an Observable
// ─────────────────────────────────────────────────────────────────────────────
// WHY: you have a signal (e.g. search term from an input) but need RxJS operators
//      like debounceTime / switchMap that don't exist on signals.

@Component({ standalone: true })
export class SearchComponent {
  private http = inject(HttpClient);

  // User's search input as a signal — updated on every keystroke
  searchTerm = signal('');

  // Convert signal → Observable to get access to RxJS operators
  // WHY toObservable: signals have no debounce/switchMap — we need the Observable
  //   pipeline to debounce keystrokes and cancel stale HTTP calls
  results = toSignal(
    toObservable(this.searchTerm).pipe(
      // debounceTime — wait 300ms after user stops typing before firing HTTP
      // WHY: without debounce, HTTP fires on EVERY keystroke (expensive)
      debounceTime(300),

      // distinctUntilChanged — skip if value hasn't actually changed
      // WHY: prevents duplicate HTTP calls when user types then deletes to same value
      distinctUntilChanged(),

      // switchMap — cancel previous HTTP call when new search term arrives
      // WHY: user types "ang" (HTTP starts), then "angu" (previous HTTP CANCELLED)
      //      only the most recent query reaches .subscribe / toSignal
      switchMap(term =>
        term.length < 2
          ? of([])  // don't search for single characters
          : this.http.get<string[]>(`/api/search?q=${term}`).pipe(
              // catchError per inner Observable — prevents switchMap from dying on error
              // WHY here and not outside: if catchError were outside switchMap, a single
              //   HTTP error would kill the entire search stream permanently
              catchError(() => of([] as string[]))
            )
      )
    ),
    { initialValue: [] as string[] }
  );
  // In template: results() → string[] — auto-updates as user types, no subscribe needed
}
```

---

### Error Handling with Signals

```typescript
// ─────────────────────────────────────────────────────────────────────────────
// Pattern — three-state signal (loading | success | error)
// ─────────────────────────────────────────────────────────────────────────────
// WHY: clean state machine using signals — no boolean flag soup
//      (isLoading + isError + isSuccess all managed separately = prone to invalid states)

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
  // Single signal holds ALL load states — impossible to reach invalid combinations
  // e.g. isLoading=true AND isError=true at the same time (impossible with LoadState type)
  state = signal<LoadState<User[]>>({ status: 'idle' });

  // computed — derive boolean helpers from the single state signal
  // WHY computed: template can use isLoading() without repeating state().status === 'loading'
  isLoading = computed(() => this.state().status === 'loading');
  hasError  = computed(() => this.state().status === 'error');

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    // Set loading state — single .set() replaces all boolean flag updates
    this.state.set({ status: 'loading' });

    this.http.get<User[]>('/api/users').pipe(
      // catchError in pipe — translates HTTP errors to clean state update
      catchError((err: HttpErrorResponse) => {
        // Push error state into signal — template reacts immediately
        this.state.set({ status: 'error', message: `Error ${err.status}: ${err.message}` });
        // Return EMPTY — no next() fires, complete fires, subscribe is clean
        // WHY EMPTY over of([]): we've already set the error state above;
        //   we don't want next() to overwrite it with success state
        return EMPTY;
      })
    ).subscribe({
      // next — only fires if catchError returned EMPTY (no error) or of(data)
      next: users => this.state.set({ status: 'success', data: users }),
      // error will NOT fire — catchError returned EMPTY (swallowed the error)
      // complete fires after next — no action needed (state already set)
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

Use SIGNALS for:                        Use OBSERVABLES (RxJS) for:
──────────────────────────────────────  ────────────────────────────────────────
✅ Component state (count, isOpen,      ✅ HTTP calls (async, one-shot)
   selectedTab, formMode)              ✅ WebSockets (long-lived streams)
✅ Derived/computed values              ✅ Route params / queryParams
   (total, filteredList, label)        ✅ User events (debounce + switchMap)
✅ Sharing state between components     ✅ Polling with interval()
   via a service (like BehaviorSubject) ✅ Combining multiple async sources
✅ Simple synchronous reactive UI           (combineLatest, forkJoin)
✅ Replacing BehaviorSubject for         ✅ Complex operator chains
   simple shared values                    (retry, throttle, buffer, audit)
✅ Zoneless Angular (signal-based CD)

Use BOTH (bridge with toSignal / toObservable):
✅ HTTP call → subscribe → signal.set()         (async source, sync result)
✅ toSignal(http.get(...))                       (no subscribe needed in component)
✅ toObservable(signal) → debounce → switchMap  (signal drives async pipeline)
```

---

## 12. Interview Q&A

**Q1. What is the difference between `subscribe({ error })` and `catchError` in the pipe?**

**A:** `subscribe({ error })` is a terminal observer callback — it runs **after** the stream has
already died from an error. You can react to it (update UI, log) but cannot recover the stream.
`catchError` is a pipe **operator** — it intercepts the error **inside** the pipeline before it
reaches the subscriber. It must return a new Observable, which means you can provide a fallback
(`of([])`), end silently (`EMPTY`), retry the source, or re-throw a transformed error. The key
difference: `catchError` can keep the stream alive or swap in new data; `subscribe error` cannot.

---

**Q2. When would you use `catchError` → `of(fallback)` vs `catchError` → `throwError`?**

**A:**
- `of(fallback)` — when the component should receive a default value and render normally even if
  the request failed (e.g. empty list, cached data, default config). The subscribe `error` callback
  will NOT fire; the `next` callback fires with the fallback.
- `throwError` — when you want to transform the error (e.g. translate `HttpErrorResponse` to a
  domain-specific error) and still let the subscribe `error` callback handle the UI reaction.
  Typical pattern: service uses `catchError → throwError` (to translate), component uses
  `subscribe({ error })` (to update UI state).

---

**Q3. Does `complete` fire after `catchError` returns `of(fallback)`?**

**A:** Yes. `of(fallback)` emits one value then completes. The subscribe `next` callback receives
the fallback value, then `complete` fires. The `error` callback never fires.

---

**Q4. Why is placing `catchError` BEFORE a potentially-throwing operator a bug?**

**A:** Operators in a pipe run in order. An error thrown by operator N is only caught by a
`catchError` that appears **after** operator N in the pipe. A `catchError` before operator N has
already executed and is no longer in the error path. Always place `catchError` after the operator
that may fail.

---

**Q5. What does `finalize` do and how is it different from the `complete` callback?**

**A:** `finalize(() => fn())` in the pipe runs `fn()` whether the Observable completes **or**
errors — equivalent to a `finally {}` block. The `complete` callback in `subscribe` only fires on
clean completion, not on error. Use `finalize` for cleanup that must happen regardless (e.g.
`this.loading = false`, closing a connection) — it removes the need to duplicate the reset in both
`next+complete` and `error`.
