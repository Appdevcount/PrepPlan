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
11. [Interview Q&A](#11-interview-qa)

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

## 11. Interview Q&A

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
