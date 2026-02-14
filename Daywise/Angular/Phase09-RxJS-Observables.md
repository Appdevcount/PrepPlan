# Phase 9: RxJS & Observables

> "Think of RxJS as lodash for events." -- RxJS Official Tagline. Observables are the backbone of Angular's asynchronous operations -- from HTTP requests to form handling to routing events. Understanding RxJS is what separates Angular beginners from Angular experts. This phase takes you from "what is an Observable?" to confidently building reactive, stream-based applications.

---

## 9.1 What Are Observables?

### The Core Concept: Streams of Data Over Time

An **Observable** represents a stream of data that arrives over time. Unlike a regular variable that holds one value at one point, an Observable can emit zero, one, or many values -- and those values can arrive now, later, or continuously.

```
Regular variable:    value = 42           (one value, right now)
Promise:             fetch('/api')        (one value, in the future)
Observable:          clicks$, messages$   (many values, over time)
```

Think of it like this:

```
A regular variable is like a PHOTOGRAPH -- a single snapshot.
A Promise is like ordering a PACKAGE -- one delivery, eventually.
An Observable is like a LIVE VIDEO STREAM -- continuous data flowing to you.
```

### The YouTube Analogy

This is the best analogy for understanding Observables:

| RxJS Concept | YouTube Equivalent | Explanation |
|---|---|---|
| **Observable** | A YouTube Channel | It produces content (data) over time |
| **subscribe()** | Hitting the Subscribe button | You start receiving the data |
| **Observer** | You, the viewer | You watch (consume) each new video (value) |
| **next** | A new video is uploaded | A new value arrives in the stream |
| **error** | Channel gets banned / goes down | Something went wrong, stream stops |
| **complete** | Channel announces "final video, retiring!" | Stream ends successfully |
| **unsubscribe()** | Hitting Unsubscribe | You stop receiving updates |
| **Operator** | A filter on the feed (e.g., "only 4K videos") | Transform/filter the data before you see it |

```
YouTube Channel (Observable)
    │
    ├── Video 1 (next)
    ├── Video 2 (next)
    ├── Video 3 (next)
    ├── ...
    │
    └── "Channel retired!" (complete)
         OR
    └── "Channel banned!" (error)

You (Observer) hit Subscribe ──→ You start receiving videos
You hit Unsubscribe ──→ You stop receiving videos
                          (but the channel keeps uploading!)
```

**Key insight:** Just like unsubscribing from YouTube does NOT stop the channel from uploading, calling `unsubscribe()` does NOT stop the Observable from emitting. It only stops YOUR subscription from receiving values.

### How Observables Differ from Promises

This is one of the most important things to understand. Developers coming from a Promise-based background often confuse the two.

| Feature | Promise | Observable |
|---|---|---|
| **Values** | Emits a **single** value (or error) | Emits **multiple** values over time |
| **Eagerness** | **Eager** -- starts executing immediately when created | **Lazy** -- does NOTHING until someone subscribes |
| **Cancellation** | **Not cancellable** -- once started, it runs to completion | **Cancellable** -- call `unsubscribe()` to stop |
| **Operators** | Limited (`.then()`, `.catch()`, `.finally()`) | **100+ operators** (map, filter, debounce, retry, etc.) |
| **Multicast** | Shared by default -- multiple `.then()` get the same result | **Unicast** by default -- each subscriber gets its own execution |
| **Retry** | Cannot retry natively | Built-in `retry()` operator |
| **Use case** | Single async operation (one API call) | Streams (clicks, WebSocket messages, form changes) |

**Eager vs. Lazy -- This is crucial:**

```typescript
// PROMISE -- Eager: This HTTP call fires IMMEDIATELY, even if nobody is listening
const promise = fetch('/api/users');  // HTTP request already sent!

// OBSERVABLE -- Lazy: This does NOTHING until someone subscribes
const observable = this.http.get('/api/users');  // No HTTP request yet!
observable.subscribe();  // NOW the HTTP request fires
```

**Why does laziness matter?** Because you can define an Observable, pass it around, compose it with operators, and it only executes when someone actually needs the data. This gives you much more control.

**Single vs. Multiple values:**

```typescript
// Promise -- resolves ONCE, then it's done
const promise = new Promise(resolve => {
  resolve(1);
  resolve(2);  // This is IGNORED -- promise already resolved
  resolve(3);  // This is also IGNORED
});
promise.then(v => console.log(v));  // Output: 1  (only once)

// Observable -- can emit MANY values
const observable = new Observable(subscriber => {
  subscriber.next(1);   // Emits 1
  subscriber.next(2);   // Emits 2
  subscriber.next(3);   // Emits 3
  subscriber.complete(); // Done
});
observable.subscribe(v => console.log(v));
// Output: 1, 2, 3  (all three!)
```

### Where Angular Uses Observables

Angular is HEAVILY invested in Observables. They appear everywhere:

| Angular Feature | What Returns an Observable | Example |
|---|---|---|
| **HttpClient** | Every HTTP method (`get`, `post`, `put`, `delete`) | `this.http.get('/api/users')` |
| **Reactive Forms** | `valueChanges`, `statusChanges` | `this.form.valueChanges` |
| **Router** | `params`, `queryParams`, `events`, `data` | `this.route.params` |
| **@Output EventEmitter** | Event emissions (EventEmitter extends Subject) | `@Output() clicked = new EventEmitter()` |
| **Interceptors** | Request/response pipeline | `return next.handle(req)` |
| **Guards** | Can return `Observable<boolean>` | `canActivate(): Observable<boolean>` |
| **Resolvers** | Pre-fetch data before route activates | `resolve(): Observable<Data>` |
| **ViewChild with changes** | Query list changes | `@ViewChildren(ItemComponent) items` |

**Bottom line:** If you want to be effective in Angular, you MUST understand Observables and RxJS. It is not optional.

---

## 9.2 Creating Observables

RxJS provides several **creation functions** (also called creation operators) to create Observables from different data sources.

### `of()` -- Create from Known Values

`of()` creates an Observable that emits the values you give it, then completes. Think of it as "wrapping values in an Observable envelope."

```typescript
import { of } from 'rxjs';

// Emit individual values, then complete
const numbers$ = of(1, 2, 3, 4, 5);

numbers$.subscribe({
  next: value => console.log(value),     // 1, 2, 3, 4, 5
  complete: () => console.log('Done!')   // 'Done!'
});

// Emit a single object
const user$ = of({ name: 'Alice', age: 30 });

user$.subscribe(user => console.log(user));
// { name: 'Alice', age: 30 }

// Emit mixed types
const mixed$ = of(42, 'hello', true, [1, 2, 3]);

mixed$.subscribe(val => console.log(val));
// 42, 'hello', true, [1, 2, 3]
```

**When to use `of()`:**
- Mocking HTTP responses in tests
- Providing default/fallback values
- Returning a value where an Observable is expected

```typescript
// Common pattern: return a fallback in catchError
getUser(id: number): Observable<User> {
  return this.http.get<User>(`/api/users/${id}`).pipe(
    catchError(error => {
      console.error('Failed to load user', error);
      return of({ id: 0, name: 'Unknown' } as User);  // Fallback
    })
  );
}
```

### `from()` -- Convert Arrays, Promises, and Iterables

`from()` converts things that are "Observable-like" into actual Observables. It handles arrays, Promises, iterables, and other Observables.

```typescript
import { from } from 'rxjs';

// From an ARRAY -- emits each element one by one
const array$ = from([10, 20, 30, 40, 50]);

array$.subscribe(val => console.log(val));
// 10, 20, 30, 40, 50  (each as a separate emission)

// IMPORTANT: of([10, 20, 30]) vs from([10, 20, 30])
// of([10, 20, 30])   --> emits ONE value: the entire array [10, 20, 30]
// from([10, 20, 30]) --> emits THREE values: 10, then 20, then 30
```

```typescript
// From a PROMISE -- converts promise resolution into Observable emission
const promise = fetch('/api/users').then(res => res.json());
const users$ = from(promise);

users$.subscribe(data => console.log(data));
// Emits the resolved value of the promise

// From a STRING (iterable) -- emits each character
const chars$ = from('Hello');

chars$.subscribe(char => console.log(char));
// 'H', 'e', 'l', 'l', 'o'

// From a Map
const map = new Map([['a', 1], ['b', 2], ['c', 3]]);
const map$ = from(map);

map$.subscribe(entry => console.log(entry));
// ['a', 1], ['b', 2], ['c', 3]
```

**When to use `from()`:**
- Converting a Promise-based API to Observable
- Processing array elements through an operator pipeline
- Working with any iterable data source

### `interval()` -- Emit Numbers at Regular Intervals

`interval()` creates an Observable that emits sequential numbers (0, 1, 2, 3...) at a specified time interval. Think of it as a ticking clock.

```typescript
import { interval } from 'rxjs';

// Emit a number every 1000ms (1 second)
const ticker$ = interval(1000);

const subscription = ticker$.subscribe(n => console.log(n));
// t=1s: 0
// t=2s: 1
// t=3s: 2
// t=4s: 3
// ... (continues forever until unsubscribed!)

// IMPORTANT: This NEVER completes on its own. You MUST unsubscribe.
// Stop after 5 seconds:
setTimeout(() => {
  subscription.unsubscribe();
  console.log('Stopped!');
}, 5000);
```

```
Timeline:
0s        1s        2s        3s        4s        5s
|         |         |         |         |         |
          emit(0)   emit(1)   emit(2)   emit(3)   UNSUBSCRIBED
```

**When to use `interval()`:**
- Polling an API at regular intervals
- Creating a countdown timer
- Auto-refreshing data
- Animations

### `timer()` -- Delayed or Scheduled Emission

`timer()` can work in two modes:

**Mode 1: Single delayed emission (one argument)**
```typescript
import { timer } from 'rxjs';

// Emit 0 after 3 seconds, then complete
const delayed$ = timer(3000);

delayed$.subscribe({
  next: val => console.log(val),        // 0 (after 3 seconds)
  complete: () => console.log('Done!')  // 'Done!'
});
```

**Mode 2: Delayed start, then interval (two arguments)**
```typescript
// Wait 2 seconds, then emit every 1 second
const delayedInterval$ = timer(2000, 1000);

delayedInterval$.subscribe(n => console.log(n));
// t=2s: 0
// t=3s: 1
// t=4s: 2
// ... (continues forever, must unsubscribe)
```

```
timer(3000)          -- one-shot:
0s        1s        2s        3s
|                             |
                              emit(0) --> complete

timer(2000, 1000)    -- delayed interval:
0s        1s        2s        3s        4s        5s
|                   |         |         |         |
                    emit(0)   emit(1)   emit(2)   emit(3)...
```

**When to use `timer()`:**
- Delaying an action (e.g., show a tooltip after 500ms)
- Implementing timeout logic
- Delayed polling start

### `new Observable()` -- Custom Observable

When none of the built-in creation functions fit your needs, you can create a fully custom Observable.

```typescript
import { Observable } from 'rxjs';

// Custom Observable that emits 1, 2, 3, then completes
const custom$ = new Observable<number>(subscriber => {
  // The "subscriber" is the object your Observable uses to push values
  console.log('Observable execution started');

  subscriber.next(1);
  subscriber.next(2);
  subscriber.next(3);

  // Signal that we're done
  subscriber.complete();

  // Anything after complete() is IGNORED
  subscriber.next(4);  // This will NOT be emitted
});

custom$.subscribe({
  next: val => console.log('Received:', val),
  complete: () => console.log('Stream completed')
});
// Output:
// 'Observable execution started'
// 'Received: 1'
// 'Received: 2'
// 'Received: 3'
// 'Stream completed'
```

**Custom Observable with cleanup (teardown logic):**

```typescript
const countdown$ = new Observable<number>(subscriber => {
  let count = 10;

  const intervalId = setInterval(() => {
    if (count >= 0) {
      subscriber.next(count);
      count--;
    } else {
      subscriber.complete();
    }
  }, 1000);

  // TEARDOWN FUNCTION: runs when subscriber unsubscribes or Observable completes
  // This is how you prevent memory leaks in custom Observables
  return () => {
    console.log('Cleanup: clearing interval');
    clearInterval(intervalId);
  };
});

const sub = countdown$.subscribe(val => console.log(val));
// 10, 9, 8, 7...

// If you unsubscribe early, the teardown function clears the interval
setTimeout(() => sub.unsubscribe(), 3000);
// Output: 10, 9, 8, then 'Cleanup: clearing interval'
```

### `fromEvent()` -- From DOM Events

`fromEvent()` creates an Observable from DOM events like clicks, keypresses, mouse movements, etc.

```typescript
import { fromEvent } from 'rxjs';

// Listen to button clicks
const button = document.getElementById('myButton')!;
const clicks$ = fromEvent(button, 'click');

clicks$.subscribe(event => {
  console.log('Button clicked!', event);
});

// Listen to keyboard events on the document
const keyups$ = fromEvent<KeyboardEvent>(document, 'keyup');

keyups$.subscribe(event => {
  console.log('Key pressed:', event.key);
});

// Listen to window resize
const resize$ = fromEvent(window, 'resize');

resize$.subscribe(event => {
  console.log('Window resized:', window.innerWidth, window.innerHeight);
});
```

**When to use `fromEvent()`:**
- Handling user interactions in a reactive way
- Building complex event-driven logic (drag and drop, gestures)
- When you need to apply operators to events (debounce, throttle, etc.)

**Note:** In Angular, you will rarely use `fromEvent()` directly because Angular has its own event binding `(click)="handler()"`. However, `fromEvent()` is useful when you need to apply RxJS operators to DOM events, or when working with elements outside Angular's template system.

### Summary of Creation Functions

| Function | Creates Observable From | Completes? | Common Use |
|---|---|---|---|
| `of(1, 2, 3)` | Individual values | Yes | Mock data, defaults |
| `from([1,2,3])` | Array/Promise/Iterable | Yes | Convert existing data |
| `interval(1000)` | Timer tick (ms) | No | Polling, counters |
| `timer(3000)` | Delayed emission | Yes (1 arg) / No (2 args) | Delays, timeouts |
| `new Observable(fn)` | Custom logic | You decide | Full control |
| `fromEvent(el, 'click')` | DOM event | No | Event streams |

---

## 9.3 Subscribing and Unsubscribing

### The subscribe() Method

Subscribing is what "activates" an Observable. Remember: Observables are **lazy** -- they do nothing until you subscribe.

The `subscribe()` method accepts an **Observer** object with three callbacks:

```typescript
import { of } from 'rxjs';

const data$ = of(1, 2, 3);

// Full Observer object
data$.subscribe({
  next: value => console.log('Value:', value),   // Called for EACH emitted value
  error: err => console.error('Error:', err),     // Called if an ERROR occurs
  complete: () => console.log('Completed!')       // Called when stream FINISHES
});

// Output:
// Value: 1
// Value: 2
// Value: 3
// Completed!
```

**Understanding the three callbacks:**

```
Observable Stream
    │
    ├── next(1)      ──→ "Here's a value"
    ├── next(2)      ──→ "Here's another value"
    ├── next(3)      ──→ "Here's yet another value"
    │
    └── complete()   ──→ "I'm done, no more values"  (stream ends)
         OR
    └── error(err)   ──→ "Something broke!"           (stream ends)

NOTE: After complete() or error(), NO more next() calls will happen.
      A stream can end with complete OR error, but never both.
```

**Shorthand subscription (just the next callback):**

```typescript
// If you only care about values (not errors or completion):
data$.subscribe(value => console.log(value));

// This is equivalent to:
data$.subscribe({
  next: value => console.log(value)
  // error and complete are not handled
});
```

**Warning:** In production code, always handle errors! Unhandled Observable errors will crash your app.

```typescript
// GOOD -- always handle errors for HTTP calls
this.http.get('/api/users').subscribe({
  next: users => this.users = users,
  error: err => {
    console.error('Failed to load users:', err);
    this.errorMessage = 'Could not load users. Please try again.';
  }
});
```

### Why You MUST Unsubscribe (Memory Leaks!)

This is one of the most critical concepts in Angular development. **Failing to unsubscribe from Observables causes memory leaks.**

**What's a memory leak?** It's when your application keeps consuming memory for subscriptions that are no longer needed.

```
Scenario: User navigates to a page with a subscription, then navigates away.

WITHOUT unsubscribe:
  Page loaded   → subscribe to interval(1000)
  Page destroyed → component is gone, BUT the subscription is still running!
  Navigate back  → NEW subscription created (old one still running too!)
  Navigate away  → Now TWO orphaned subscriptions
  Navigate back  → THREE subscriptions...
  ... Eventually the browser slows down and crashes

WITH unsubscribe:
  Page loaded   → subscribe to interval(1000)
  Page destroyed → unsubscribe() called, subscription cleaned up
  Navigate back  → fresh subscription, no orphans
  Navigate away  → cleaned up again
  ... App runs smoothly forever
```

**Which Observables need unsubscribing?**

| Observable Source | Need to Unsubscribe? | Why |
|---|---|---|
| `HttpClient` (get, post, etc.) | Usually NO | HTTP calls complete after one response |
| `ActivatedRoute.params` | NO | Angular manages this internally |
| `interval()`, `timer()` (no end) | YES | They run forever |
| `fromEvent()` | YES | Event listeners run forever |
| `valueChanges` (forms) | YES | Emits until form is destroyed |
| `Subject` / `BehaviorSubject` | YES | They live until explicitly completed |
| `Router.events` | YES | Emits for every navigation |
| Any custom infinite Observable | YES | Runs until explicitly stopped |

**Rule of thumb:** If the Observable completes on its own (like HTTP calls), you are safe. If it runs indefinitely (like intervals, event listeners, or Subjects), you MUST unsubscribe.

### Pattern 1: Manual Unsubscribe in ngOnDestroy

The most straightforward approach. Store the subscription and unsubscribe when the component is destroyed.

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription, interval } from 'rxjs';

@Component({
  selector: 'app-dashboard',
  template: `<p>Count: {{ count }}</p>`
})
export class DashboardComponent implements OnInit, OnDestroy {
  count = 0;

  // Store the subscription reference
  private counterSub!: Subscription;

  ngOnInit(): void {
    // Subscribe and save the reference
    this.counterSub = interval(1000).subscribe(n => {
      this.count = n;
    });
  }

  ngOnDestroy(): void {
    // Clean up when component is destroyed
    this.counterSub.unsubscribe();
    console.log('Subscription cleaned up!');
  }
}
```

**When you have multiple subscriptions:**

```typescript
export class DashboardComponent implements OnInit, OnDestroy {
  private subscriptions: Subscription[] = [];

  ngOnInit(): void {
    // Push each subscription into the array
    this.subscriptions.push(
      interval(1000).subscribe(n => console.log('Counter:', n))
    );

    this.subscriptions.push(
      this.userService.getUser().subscribe(user => this.user = user)
    );

    this.subscriptions.push(
      this.route.params.subscribe(params => this.id = params['id'])
    );
  }

  ngOnDestroy(): void {
    // Unsubscribe from ALL at once
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}
```

**Or use a single Subscription as a container (add/remove pattern):**

```typescript
export class DashboardComponent implements OnInit, OnDestroy {
  // A single Subscription can hold child subscriptions
  private subs = new Subscription();

  ngOnInit(): void {
    // .add() registers child subscriptions
    this.subs.add(
      interval(1000).subscribe(n => console.log('Counter:', n))
    );

    this.subs.add(
      this.userService.getUser().subscribe(user => this.user = user)
    );
  }

  ngOnDestroy(): void {
    // One call unsubscribes from ALL children
    this.subs.unsubscribe();
  }
}
```

**Pros:** Simple, explicit, easy to understand.
**Cons:** Verbose, easy to forget for one subscription, lots of boilerplate.

### Pattern 2: takeUntil with a Subject (Recommended for Complex Components)

This is the most popular pattern in Angular. You create a "destroy" Subject that emits when the component is destroyed, and use `takeUntil()` to automatically complete all subscriptions.

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject, interval } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({
  selector: 'app-dashboard',
  template: `<p>Count: {{ count }}</p>`
})
export class DashboardComponent implements OnInit, OnDestroy {
  count = 0;
  user: User | null = null;

  // Step 1: Create a Subject that acts as a "kill switch"
  private destroy$ = new Subject<void>();

  constructor(
    private userService: UserService,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    // Step 2: Add takeUntil(this.destroy$) to every subscription
    interval(1000).pipe(
      takeUntil(this.destroy$)  // <-- Auto-unsubscribes when destroy$ emits
    ).subscribe(n => {
      this.count = n;
    });

    this.userService.getUser().pipe(
      takeUntil(this.destroy$)  // <-- Same pattern for every subscription
    ).subscribe(user => {
      this.user = user;
    });

    this.route.params.pipe(
      takeUntil(this.destroy$)
    ).subscribe(params => {
      console.log('Route param:', params['id']);
    });
  }

  ngOnDestroy(): void {
    // Step 3: Emit and complete the destroy$ Subject
    this.destroy$.next();     // This triggers all takeUntil operators
    this.destroy$.complete();  // Clean up the Subject itself
  }
}
```

**How it works visually:**

```
interval(1000)  ──→ 0 ──→ 1 ──→ 2 ──→ 3 ──→ 4 ──→ ...
                                           │
            takeUntil(destroy$) ───────────┤
                                           │
destroy$.next() fires here ────────────────X (stream stops)
```

**Pros:** Clean, consistent pattern. One kill switch for ALL subscriptions.
**Cons:** Must remember to add `takeUntil` to every pipe, and to call `next()/complete()` in `ngOnDestroy`.

### Pattern 3: async Pipe in Templates (BEST Approach!)

The `async` pipe is the Gold Standard for handling Observables in Angular templates. It automatically subscribes when the template renders and unsubscribes when the component is destroyed.

```typescript
// Component -- just expose the Observable, DON'T subscribe!
@Component({
  selector: 'app-user-list',
  template: `
    <!-- async pipe subscribes and unsubscribes automatically! -->
    <ul>
      <li *ngFor="let user of users$ | async">
        {{ user.name }}
      </li>
    </ul>
  `
})
export class UserListComponent implements OnInit {
  // Convention: suffix Observable properties with $
  users$!: Observable<User[]>;

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    // Just assign the Observable -- do NOT call .subscribe()
    this.users$ = this.userService.getUsers();
  }
}
```

**No `ngOnDestroy` needed. No `unsubscribe()` calls. No memory leaks. The `async` pipe handles everything.**

We will cover the `async` pipe in much more detail in section 9.6.

**Pros:** Zero boilerplate, impossible to forget, works with OnPush change detection.
**Cons:** Only works in templates, sometimes harder to compose complex logic.

### Pattern 4: take(1) for One-Time Observables

When you only need the **first** emitted value and nothing after, use `take(1)`. The Observable automatically completes after emitting one value, so no unsubscribe is needed.

```typescript
import { take } from 'rxjs/operators';

// Get current user once (at component init), then done
this.authService.currentUser$.pipe(
  take(1)  // Take the first emission, then auto-complete
).subscribe(user => {
  this.currentUser = user;
  this.initializeDashboard(user);
});
```

```
Source:   ──A──B──C──D──E──
take(1):  ──A|              (takes first value, then completes)
```

**When to use `take(1)`:**
- Getting the current/latest value of a BehaviorSubject once
- One-time initialization reads
- When you explicitly need only one value

**Warning:** Do NOT use `take(1)` on HTTP calls -- they already emit once and complete. Adding `take(1)` is redundant and misleading.

### Which Pattern Should You Use?

| Pattern | Best For | Complexity |
|---|---|---|
| **async pipe** | Displaying Observable data in templates | Simplest |
| **takeUntil** | Complex components with many subscriptions and logic | Medium |
| **Manual unsubscribe** | Simple cases with 1-2 subscriptions | Simple but verbose |
| **take(1)** | One-time value reads | Simplest |

**The general guideline:** Use `async` pipe whenever possible. Use `takeUntil` for subscriptions that need to drive component logic (not just display). Use `take(1)` for one-time reads. Use manual `unsubscribe` only in simple cases.

---

## 9.4 RxJS Operators -- The Power Tools

Operators are functions that take an Observable as input, transform or filter the data, and return a new Observable. They are the real power of RxJS.

Think of operators like stations on an assembly line:

```
Raw Material (source Observable)
    │
    ▼
┌─────────────┐
│  Station 1   │  ← filter (remove defective items)
│  (filter)    │
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  Station 2   │  ← map (reshape each item)
│  (map)       │
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  Station 3   │  ← debounceTime (wait for pause)
│  (debounce)  │
└─────┬───────┘
      │
      ▼
  Finished Product (output Observable)
```

Operators are chained inside the `.pipe()` method:

```typescript
import { of } from 'rxjs';
import { filter, map } from 'rxjs/operators';

of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10).pipe(
  filter(n => n % 2 === 0),   // Keep only even numbers: 2, 4, 6, 8, 10
  map(n => n * 10)             // Multiply each by 10: 20, 40, 60, 80, 100
).subscribe(val => console.log(val));
// Output: 20, 40, 60, 80, 100
```

---

### Transformation Operators

#### `map` -- Transform Each Value

**Analogy:** `map` is like a translator. Every message that comes in gets translated (transformed) into a different form.

```
Source:    ──1──2──3──4──5──
map(x*10): ──10──20──30──40──50──
```

```typescript
import { of } from 'rxjs';
import { map } from 'rxjs/operators';

// Transform numbers
of(1, 2, 3).pipe(
  map(n => n * 100)
).subscribe(val => console.log(val));
// 100, 200, 300

// Extract a property from objects
interface ApiResponse {
  data: User[];
  total: number;
}

this.http.get<ApiResponse>('/api/users').pipe(
  map(response => response.data)  // Extract just the data array
).subscribe(users => {
  this.users = users;  // Now you have User[], not ApiResponse
});

// Transform API data shape
this.http.get<any[]>('/api/products').pipe(
  map(products => products.map(p => ({
    id: p.product_id,
    name: p.product_name,
    price: parseFloat(p.unit_price)
  })))
).subscribe(products => this.products = products);
```

**Key point:** `map` transforms each emitted value but does NOT change the number of emissions. 3 values in, 3 values out.

#### `switchMap` -- Cancel Previous, Start New (Most Important!)

**Analogy:** Imagine you are at a restaurant. You order pizza. While the kitchen is making it, you change your mind and order pasta instead. With `switchMap`, the kitchen **throws away the pizza** and starts making pasta. Only the latest order matters.

```
Source:       ──A─────────B─────────C──
Inner Obs:       ──a1──a2─X  ──b1──X  ──c1──c2──c3──
switchMap:    ──────a1──a2────b1───────c1──c2──c3──

X = cancelled because new source value arrived
```

```typescript
import { switchMap } from 'rxjs/operators';

// CLASSIC USE CASE: Search as you type
// When the user types a new search term, cancel the previous HTTP request
this.searchControl.valueChanges.pipe(
  debounceTime(300),                           // Wait for user to stop typing
  distinctUntilChanged(),                       // Don't search if term didn't change
  switchMap(term => this.searchService.search(term))  // Cancel previous, start new search
).subscribe(results => {
  this.results = results;
});

// Route parameter changes
// When the user navigates to a different product, cancel previous product fetch
this.route.params.pipe(
  switchMap(params => this.productService.getProduct(params['id']))
).subscribe(product => {
  this.product = product;
});
```

**Why switchMap is so important:** Without it, if the user types "ang" then "angular", you'd have TWO HTTP requests in flight. The response for "ang" might arrive AFTER "angular" and overwrite the correct results. `switchMap` prevents this by cancelling the "ang" request when "angular" is typed.

#### `mergeMap` (flatMap) -- Run All in Parallel

**Analogy:** You are at a food court with multiple counters. You order from ALL counters simultaneously. Each counter works independently, and you eat each dish as it arrives, regardless of order.

```
Source:       ──A─────────B──────────
Inner Obs:       ──a1──a2──a3──
                          ──b1──b2──b3──
mergeMap:     ──────a1──a2─b1─a3─b2──b3──

All inner Observables run simultaneously!
```

```typescript
import { mergeMap } from 'rxjs/operators';

// Process a list of file uploads in PARALLEL
this.filesToUpload$.pipe(
  mergeMap(file => this.uploadService.upload(file))
  // All uploads happen simultaneously
).subscribe(response => {
  console.log('File uploaded:', response.filename);
});

// Save multiple items at once -- all API calls run concurrently
from(itemsToSave).pipe(
  mergeMap(item => this.http.post('/api/items', item))
).subscribe(result => {
  console.log('Item saved:', result);
});

// With concurrency limit (optional second parameter)
from(urls).pipe(
  mergeMap(url => this.http.get(url), 3)  // Max 3 concurrent requests
).subscribe(data => console.log(data));
```

**When to use:** When you want all operations to run at the same time and order does not matter.

#### `concatMap` -- Run One at a Time, In Order

**Analogy:** A single-lane bridge. Cars (inner Observables) cross one at a time. The next car waits until the current one has completely crossed. Order is guaranteed.

```
Source:       ──A──────B──────C──
Inner Obs:       ──a1──a2|
                          ──b1──b2|
                                   ──c1──c2|
concatMap:    ──────a1──a2──b1──b2──c1──c2──

Each inner Observable waits for the previous to complete!
```

```typescript
import { concatMap } from 'rxjs/operators';

// Sequential API calls where ORDER matters
// E.g., database migrations that must run in sequence
from(['migration1', 'migration2', 'migration3']).pipe(
  concatMap(migration => this.runMigration(migration))
  // migration2 won't start until migration1 completes
  // migration3 won't start until migration2 completes
).subscribe(result => {
  console.log('Migration completed:', result);
});

// Saving form steps in order
this.formSteps$.pipe(
  concatMap(step => this.http.post('/api/form-steps', step))
  // Each step is saved before the next one begins
).subscribe();
```

**When to use:** When operations MUST happen in sequence, and each depends on the previous one completing.

#### `exhaustMap` -- Ignore New While Current Is Running

**Analogy:** An elevator door button. Once you press it and the door starts closing, pressing it again does NOTHING until the door has fully closed and reopened. New requests are ignored while the current operation is in progress.

```
Source:       ──A──B──C──────D──────
Inner Obs:       ──a1──a2──a3|
                                 ──d1──d2|
exhaustMap:   ──────a1──a2──a3──────d1──d2──

B and C are IGNORED because A's inner Observable is still running!
D gets through because A's inner Observable has completed by then.
```

```typescript
import { exhaustMap } from 'rxjs/operators';

// PERFECT for login/submit buttons -- prevents duplicate submissions
this.loginButton$.pipe(
  exhaustMap(() => this.authService.login(this.credentials))
  // Rapid double-clicks are ignored while login request is in flight
).subscribe(response => {
  this.router.navigate(['/dashboard']);
});

// Form submission -- ignore rapid clicks
this.submitForm$.pipe(
  exhaustMap(() => this.http.post('/api/orders', this.orderData))
).subscribe(order => {
  this.showSuccess('Order placed!');
});
```

**When to use:** When you want to ignore new triggers while a current async operation is still in progress. Classic use case: preventing double-submit on buttons.

#### When to Use Which -- Decision Table

| Operator | Behavior | Use When |
|---|---|---|
| **switchMap** | Cancel previous, start new | Search/typeahead, route params, any "latest wins" |
| **mergeMap** | Run all in parallel | Parallel uploads, batch operations (order doesn't matter) |
| **concatMap** | Queue and run one by one | Sequential operations, order-dependent writes |
| **exhaustMap** | Ignore new until current completes | Login buttons, form submit, prevent double-click |

**Memory aid:**

```
switchMap   = "I changed my mind" (cancel the old, start the new)
mergeMap    = "Do everything at once" (all in parallel)
concatMap   = "Wait your turn" (one at a time, in order)
exhaustMap  = "I'm busy, come back later" (ignore while working)
```

---

### Filtering Operators

#### `filter` -- Keep Values Matching a Condition

Just like `Array.filter()`, but for Observable streams.

```
Source:       ──1──2──3──4──5──6──
filter(>3):   ──────────4──5──6──
```

```typescript
import { filter } from 'rxjs/operators';

of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10).pipe(
  filter(n => n > 5)
).subscribe(val => console.log(val));
// 6, 7, 8, 9, 10

// Filter out null/undefined values
this.userService.currentUser$.pipe(
  filter((user): user is User => user !== null)  // TypeScript type guard!
).subscribe(user => {
  // user is guaranteed to be non-null here
  console.log('User logged in:', user.name);
});

// Filter router events to only navigation end
this.router.events.pipe(
  filter(event => event instanceof NavigationEnd)
).subscribe(event => {
  console.log('Navigation completed:', event.url);
});
```

#### `take` -- Take First N Values Then Complete

```
Source:    ──1──2──3──4──5──6──
take(3):   ──1──2──3|            (completes after 3)
```

```typescript
import { take } from 'rxjs/operators';

// Take only the first 5 interval emissions
interval(1000).pipe(
  take(5)
).subscribe({
  next: n => console.log(n),      // 0, 1, 2, 3, 4
  complete: () => console.log('Done!')  // Automatically completes
});

// take(1) -- get one value and done (no need to unsubscribe)
this.store.select(selectCurrentUser).pipe(
  take(1)
).subscribe(user => {
  this.initDashboard(user);
});
```

#### `takeUntil` -- Take Until Another Observable Emits

We already covered this in the unsubscribe patterns (section 9.3), but here is the visual:

```
Source:      ──1──2──3──4──5──6──
Notifier:    ───────────X
takeUntil:   ──1──2──3──|         (completes when notifier emits)
```

```typescript
import { takeUntil } from 'rxjs/operators';
import { Subject } from 'rxjs';

// In a component:
private destroy$ = new Subject<void>();

ngOnInit() {
  interval(1000).pipe(
    takeUntil(this.destroy$)
  ).subscribe(n => console.log(n));
}

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

#### `first` -- Take the First Value (or First Matching) Then Complete

Like `take(1)`, but can also accept a predicate (condition).

```typescript
import { first } from 'rxjs/operators';

// Get the first value
of(1, 2, 3, 4, 5).pipe(
  first()
).subscribe(val => console.log(val));  // 1

// Get the first value that matches a condition
of(1, 2, 3, 4, 5).pipe(
  first(n => n > 3)
).subscribe(val => console.log(val));  // 4

// IMPORTANT difference from take(1):
// first() throws an error if the Observable completes without emitting
// take(1) simply completes without emitting or erroring
```

#### `distinctUntilChanged` -- Skip Consecutive Duplicates

**Analogy:** A bouncer who says "I just let you in, you can not enter again until someone else goes through first."

```
Source:                ──1──1──2──2──2──3──1──1──
distinctUntilChanged:  ──1─────2──────────3──1────

Only consecutive duplicates are removed, not ALL duplicates.
Notice: 1 appears again at the end because 3 was between them.
```

```typescript
import { distinctUntilChanged } from 'rxjs/operators';

of(1, 1, 1, 2, 2, 3, 3, 3, 1, 1).pipe(
  distinctUntilChanged()
).subscribe(val => console.log(val));
// 1, 2, 3, 1

// With a custom comparison function (for objects)
this.userService.currentUser$.pipe(
  distinctUntilChanged((prev, curr) => prev.id === curr.id)
  // Only emits when the user ID actually changes
).subscribe(user => {
  console.log('User changed to:', user.name);
});

// Very common with search input
this.searchInput.valueChanges.pipe(
  distinctUntilChanged()  // Don't search if the term didn't actually change
).subscribe(term => this.performSearch(term));
```

#### `debounceTime` -- Wait for a Pause in Emissions

**Analogy:** An elevator door. It waits for people to stop entering (a pause) before closing. Every time someone new enters, the timer resets.

```
Source:        ──a──b──c──────d──e──────────
debounce(300): ───────────c──────────e──────

Only emits a value after 300ms of silence.
'a' and 'b' are swallowed because 'c' came too quickly after them.
```

```typescript
import { debounceTime } from 'rxjs/operators';

// Search input -- wait for user to stop typing
this.searchControl.valueChanges.pipe(
  debounceTime(300)  // Wait 300ms after last keystroke
).subscribe(term => {
  // This fires only when the user PAUSES typing for 300ms
  this.performSearch(term);
});

// Window resize -- wait for resize to "settle"
fromEvent(window, 'resize').pipe(
  debounceTime(250)
).subscribe(() => {
  this.recalculateLayout();
});
```

**When to use:** Search inputs, resize handlers, form validation -- anywhere you want to "wait for the user to stop" before acting.

#### `throttleTime` -- Limit Emission Frequency

**Analogy:** A traffic light that lets one car through, then shows red for N milliseconds. The first car gets through immediately, then there is a mandatory waiting period.

```
Source:          ──a──b──c──d──e──f──g──h──
throttle(300):   ──a──────────e──────────h──

Emits immediately, then ignores for 300ms. First emission in each
window gets through.
```

```typescript
import { throttleTime } from 'rxjs/operators';

// Scroll events -- don't fire for every single pixel
fromEvent(document, 'scroll').pipe(
  throttleTime(200)  // At most one scroll event every 200ms
).subscribe(() => {
  this.checkScrollPosition();
});

// Button click -- prevent rapid repeated clicks
this.button$.pipe(
  throttleTime(1000)  // Allow one click per second
).subscribe(() => {
  this.performAction();
});
```

**debounceTime vs. throttleTime:**

| Feature | `debounceTime` | `throttleTime` |
|---|---|---|
| When it emits | After a **pause** (silence) | At **intervals** (regularly) |
| First emission | Delayed until pause | Immediate |
| Use case | Search input ("wait for user to finish") | Scroll/resize ("limit frequency") |
| Dropped values | All except the LAST in a burst | All except the FIRST in each window |

---

### Combination Operators

#### `combineLatest` -- Combine Latest Values from Multiple Observables

**Analogy:** A dashboard that shows "latest temperature" and "latest humidity." Whenever EITHER sensor sends a new reading, the dashboard updates with the latest values from BOTH sensors.

```
Source A:      ──1──────3────────5──
Source B:      ────2──────4────────
combineLatest: ──[1,2]─[3,2]─[3,4]─[5,4]──

After ALL sources have emitted at least once,
ANY new emission triggers output with the latest from each.
```

```typescript
import { combineLatest } from 'rxjs';

// Combine filter criteria from multiple sources
const category$ = this.categoryControl.valueChanges;
const priceRange$ = this.priceControl.valueChanges;
const sortBy$ = this.sortControl.valueChanges;

combineLatest([category$, priceRange$, sortBy$]).pipe(
  // Destructure the array of latest values
  switchMap(([category, priceRange, sortBy]) =>
    this.productService.search({ category, priceRange, sortBy })
  )
).subscribe(products => {
  this.products = products;
});

// Combine user data from multiple API calls
combineLatest([
  this.userService.getProfile(),
  this.userService.getPreferences(),
  this.userService.getNotifications()
]).subscribe(([profile, preferences, notifications]) => {
  this.profile = profile;
  this.preferences = preferences;
  this.notifications = notifications;
  this.isLoading = false;
});
```

**Important:** `combineLatest` does NOT emit until ALL source Observables have emitted at least one value. If one source never emits, you will never get any output.

#### `forkJoin` -- Wait for All to Complete (Like Promise.all)

**Analogy:** A relay race team. You wait for ALL team members to finish their legs before recording the team's time. `forkJoin` waits for ALL Observables to **complete**, then emits the LAST value from each.

```
Source A:  ──1──2──3|          (completes with 3)
Source B:  ──a──b|             (completes with b)
Source C:  ──X──Y──Z|          (completes with Z)
forkJoin:  ────────────[3,b,Z]  (emits once when ALL complete)
```

```typescript
import { forkJoin } from 'rxjs';

// Load all initial data for a dashboard page
forkJoin({
  users: this.http.get<User[]>('/api/users'),
  products: this.http.get<Product[]>('/api/products'),
  orders: this.http.get<Order[]>('/api/orders')
}).subscribe(({ users, products, orders }) => {
  // ALL three API calls have completed
  this.users = users;
  this.products = products;
  this.orders = orders;
  this.isLoading = false;
});

// With error handling
forkJoin({
  config: this.http.get('/api/config'),
  translations: this.http.get('/api/translations')
}).pipe(
  catchError(error => {
    console.error('One of the requests failed:', error);
    return of({ config: defaultConfig, translations: defaultTranslations });
  })
).subscribe(result => {
  this.config = result.config;
  this.translations = result.translations;
});
```

**forkJoin vs. combineLatest:**

| Feature | `forkJoin` | `combineLatest` |
|---|---|---|
| When it emits | **Once**, when ALL sources complete | **Every time** any source emits |
| Requires completion? | Yes, ALL sources must complete | No |
| Number of emissions | Exactly **1** | **Many** |
| Best for | Parallel HTTP calls (like `Promise.all`) | Combining live/ongoing streams |

#### `merge` -- Combine Streams Into One

**Analogy:** Multiple lanes of a highway merging into one lane. All values from all sources flow into a single output stream.

```
Source A:  ──1────3────5──
Source B:  ────2────4────6──
merge:     ──1──2──3──4──5──6──

All emissions from all sources, in chronological order.
```

```typescript
import { merge, fromEvent } from 'rxjs';

// Merge click events from multiple buttons
const save$ = fromEvent(saveBtn, 'click').pipe(map(() => 'save'));
const cancel$ = fromEvent(cancelBtn, 'click').pipe(map(() => 'cancel'));
const delete$ = fromEvent(deleteBtn, 'click').pipe(map(() => 'delete'));

merge(save$, cancel$, delete$).subscribe(action => {
  console.log('User action:', action);  // 'save', 'cancel', or 'delete'
});

// Merge data from multiple sources
const localData$ = this.localStorageService.getData();
const remoteData$ = this.http.get('/api/data');

merge(localData$, remoteData$).subscribe(data => {
  this.updateView(data);  // First local data renders, then remote replaces it
});
```

#### `zip` -- Pair Up Emissions

**Analogy:** A zipper on a jacket. Each tooth from the left side pairs with exactly one tooth from the right side. The zip only advances when both sides have a new tooth available.

```
Source A:  ──1────2────3──
Source B:  ──a──b──c──────
zip:       ──[1,a]──[2,b]──[3,c]──

Each emission is paired with the corresponding emission from the other source.
```

```typescript
import { zip, of } from 'rxjs';

// Pair up student names with their scores
const students$ = of('Alice', 'Bob', 'Charlie');
const scores$ = of(95, 87, 72);

zip(students$, scores$).subscribe(([student, score]) => {
  console.log(`${student}: ${score}`);
});
// Alice: 95
// Bob: 87
// Charlie: 72
```

#### `startWith` -- Prepend a Value

Emits a specified value BEFORE the source Observable starts emitting.

```
Source:       ──────1──2──3──
startWith(0): ──0──1──2──3──
```

```typescript
import { startWith } from 'rxjs/operators';

// Provide an initial value for a stream
this.searchControl.valueChanges.pipe(
  startWith('')  // Emit empty string immediately, before user types anything
).subscribe(term => {
  this.performSearch(term);
});

// Great with combineLatest to ensure immediate emission
combineLatest([
  this.categoryControl.valueChanges.pipe(startWith('all')),
  this.sortControl.valueChanges.pipe(startWith('name'))
]).subscribe(([category, sort]) => {
  // This fires immediately with ['all', 'name']
  // instead of waiting for the user to interact with both controls
  this.loadProducts(category, sort);
});
```

---

### Utility Operators

#### `tap` -- Side Effects Without Changing the Stream

**Analogy:** A security camera on the assembly line. It watches and records what passes through, but does NOT touch or modify the items.

```
Source:  ──1──2──3──
tap:     ──1──2──3──  (same output, but side effects happen)
```

```typescript
import { tap } from 'rxjs/operators';

this.http.get<User[]>('/api/users').pipe(
  tap(users => console.log('Raw API response:', users)),  // Logging
  map(users => users.filter(u => u.isActive)),
  tap(activeUsers => console.log('After filter:', activeUsers)),  // More logging
  tap(activeUsers => this.analytics.track('loaded_users', activeUsers.length))  // Analytics
).subscribe(users => {
  this.users = users;
});

// tap() is perfect for debugging pipelines
someComplexObservable$.pipe(
  tap(val => console.log('Step 1:', val)),
  filter(val => val > 0),
  tap(val => console.log('Step 2 (after filter):', val)),
  map(val => val * 2),
  tap(val => console.log('Step 3 (after map):', val))
).subscribe();
```

**Golden rule:** NEVER use `tap` to modify data. Use it only for side effects (logging, analytics, updating unrelated state). For data transformation, use `map`.

#### `catchError` -- Handle Errors in the Stream

**Analogy:** A safety net under a tightrope walker. If the walker falls (error), the net catches them and either gives them another chance or helps them down safely.

```
Source:       ──1──2──X (error)
catchError:   ──1──2──(fallback value or new Observable)──
```

```typescript
import { catchError } from 'rxjs/operators';
import { of, EMPTY } from 'rxjs';

// Return a fallback value on error
this.http.get<User[]>('/api/users').pipe(
  catchError(error => {
    console.error('API Error:', error);
    return of([]);  // Return empty array as fallback
  })
).subscribe(users => {
  this.users = users;  // Either real data or empty array
});

// Return EMPTY to silently swallow the error (no emission, just complete)
this.http.get('/api/optional-data').pipe(
  catchError(() => EMPTY)  // Error? Just complete silently
).subscribe();

// Re-throw a transformed error
this.http.get('/api/data').pipe(
  catchError(error => {
    if (error.status === 404) {
      return of(null);  // 404 is OK, return null
    }
    throw new Error(`Unexpected error: ${error.status}`);  // Re-throw others
  })
).subscribe();

// catchError with navigation (redirect to error page)
this.http.get<User>(`/api/users/${id}`).pipe(
  catchError(error => {
    this.router.navigate(['/error'], { queryParams: { code: error.status } });
    return EMPTY;
  })
).subscribe(user => this.user = user);
```

**Important:** `catchError` must return a new Observable (or throw to propagate the error). It replaces the errored stream with a new stream.

#### `retry` -- Retry on Error

Automatically resubscribes to the source Observable if it errors, up to a specified number of times.

```
Source (fails twice, succeeds third time):
  Attempt 1: ──X (error)
  Attempt 2: ──X (error)
  Attempt 3: ──42|

retry(3):    ──────────42|  (succeeded on 3rd try)
```

```typescript
import { retry, catchError } from 'rxjs/operators';

// Retry up to 3 times before giving up
this.http.get('/api/flaky-endpoint').pipe(
  retry(3),  // Try up to 3 additional times (4 total attempts)
  catchError(error => {
    console.error('Failed after 4 attempts:', error);
    return of(null);  // Final fallback after all retries fail
  })
).subscribe(data => {
  if (data) this.processData(data);
});

// retry with configuration (delay between retries)
import { retry, timer } from 'rxjs';

this.http.get('/api/data').pipe(
  retry({
    count: 3,                              // Number of retries
    delay: (error, retryCount) => {
      console.log(`Retry attempt ${retryCount}`);
      return timer(retryCount * 1000);     // Wait 1s, 2s, 3s (exponential backoff)
    }
  }),
  catchError(error => {
    this.notificationService.error('Failed to load data');
    return of(null);
  })
).subscribe();
```

#### `delay` -- Add a Time Delay

Delays each emitted value by the specified duration.

```
Source:     ──1──2──3──
delay(500): ─────1──2──3──   (each value shifted by 500ms)
```

```typescript
import { delay } from 'rxjs/operators';

// Simulate a slow API response (for testing loading states)
of({ name: 'Alice', age: 30 }).pipe(
  delay(2000)  // Emit after 2 seconds
).subscribe(user => {
  this.user = user;
});

// Show a success message for 3 seconds, then hide it
this.showSuccess = true;
of(false).pipe(
  delay(3000)
).subscribe(() => {
  this.showSuccess = false;
});
```

#### `finalize` -- Run Code When Stream Completes or Errors

**Analogy:** The `finally` block in a try/catch. Runs regardless of whether the stream completed successfully or errored.

```typescript
import { finalize } from 'rxjs/operators';

// Very common: hide loading spinner when request completes OR fails
this.isLoading = true;

this.http.get('/api/data').pipe(
  finalize(() => {
    // This runs whether the request succeeds OR fails
    this.isLoading = false;
    console.log('Request finished');
  })
).subscribe({
  next: data => this.data = data,
  error: err => this.errorMessage = 'Failed to load data'
});

// Combine with other operators
this.http.get('/api/users').pipe(
  tap(() => console.log('Request started')),
  retry(2),
  catchError(err => {
    this.handleError(err);
    return of([]);
  }),
  finalize(() => {
    this.isLoading = false;
    console.log('All done (success or failure)');
  })
).subscribe(users => this.users = users);
```

---

## 9.5 Subjects -- Multicasting

A **Subject** is a special type of Observable that is also an **Observer**. This means it can both **emit** values (like a producer) and be **subscribed to** (like a stream).

**Regular Observable vs. Subject:**

```
OBSERVABLE (Unicast):
  Each subscriber gets its own independent execution.

  Observable ──→ Subscriber A gets: 1, 2, 3
             ──→ Subscriber B gets: 1, 2, 3  (separate execution)

SUBJECT (Multicast):
  All subscribers share the SAME execution.

  Subject ──→ Subscriber A gets: 1, 2, 3
          ──→ Subscriber B gets: 1, 2, 3  (same execution, same values)
          ──→ Subscriber C gets: 1, 2, 3  (shared)
```

### Subject -- The Basic One

A `Subject` has no initial value. Late subscribers only receive values emitted AFTER they subscribe.

```typescript
import { Subject } from 'rxjs';

const subject = new Subject<string>();

// Subscriber A subscribes BEFORE any values
subject.subscribe(val => console.log('A:', val));

subject.next('Hello');   // A: Hello
subject.next('World');   // A: World

// Subscriber B subscribes AFTER 'Hello' and 'World' were emitted
subject.subscribe(val => console.log('B:', val));

subject.next('!');       // A: !    B: !

// B missed 'Hello' and 'World' -- it only gets values emitted AFTER it subscribed
```

```
Timeline:
  subject.next('Hello') ──→ A sees it, B hasn't subscribed yet
  subject.next('World') ──→ A sees it, B still hasn't subscribed
  B subscribes
  subject.next('!')     ──→ A sees it, B sees it
```

**Common use case in Angular -- Event bus between components:**

```typescript
// notification.service.ts
@Injectable({ providedIn: 'root' })
export class NotificationService {
  // Private Subject -- only this service can emit
  private notificationSubject = new Subject<string>();

  // Public Observable -- anyone can subscribe
  notifications$ = this.notificationSubject.asObservable();

  // Method to emit notifications
  notify(message: string): void {
    this.notificationSubject.next(message);
  }
}

// any-component.ts -- send a notification
this.notificationService.notify('Item saved successfully!');

// notification-display.component.ts -- receive notifications
this.notificationService.notifications$.subscribe(message => {
  this.showToast(message);
});
```

### BehaviorSubject -- Has Initial Value, Replays Last

A `BehaviorSubject` requires an initial value and always emits the **most recent value** to new subscribers immediately.

```typescript
import { BehaviorSubject } from 'rxjs';

// MUST provide an initial value
const subject = new BehaviorSubject<number>(0);

// Subscriber A subscribes -- immediately gets the current value (0)
subject.subscribe(val => console.log('A:', val));
// A: 0  (immediately, because BehaviorSubject replays the latest)

subject.next(1);   // A: 1
subject.next(2);   // A: 2

// Subscriber B subscribes LATE -- immediately gets the LAST emitted value (2)
subject.subscribe(val => console.log('B:', val));
// B: 2  (immediately!)

subject.next(3);   // A: 3    B: 3
```

```
Timeline:
  BehaviorSubject created with initial value: 0
  A subscribes  → A immediately gets: 0
  next(1)       → A gets: 1
  next(2)       → A gets: 2
  B subscribes  → B immediately gets: 2  (the latest value)
  next(3)       → A gets: 3, B gets: 3
```

**You can also get the current value synchronously:**

```typescript
const subject = new BehaviorSubject<string>('initial');
subject.next('updated');

console.log(subject.getValue());  // 'updated' (synchronous!)
// OR
console.log(subject.value);       // 'updated' (shorthand)
```

**BehaviorSubject is the most commonly used Subject in Angular.** Here is why:

```typescript
// auth.service.ts -- track login state
@Injectable({ providedIn: 'root' })
export class AuthService {
  // Start with null (no user logged in)
  private currentUserSubject = new BehaviorSubject<User | null>(null);

  // Public Observable for components to subscribe to
  currentUser$ = this.currentUserSubject.asObservable();

  login(credentials: LoginCredentials): Observable<User> {
    return this.http.post<User>('/api/login', credentials).pipe(
      tap(user => this.currentUserSubject.next(user))  // Update the BehaviorSubject
    );
  }

  logout(): void {
    this.currentUserSubject.next(null);
  }

  // Synchronous access when needed (e.g., in guards)
  get isLoggedIn(): boolean {
    return this.currentUserSubject.value !== null;
  }
}
```

**Why BehaviorSubject for this?** Because when any component subscribes to `currentUser$`, it immediately gets the current user (or null). No need to wait for a new emission. This is critical for components that render on page load and need to know the current state immediately.

### ReplaySubject -- Replays N Previous Values

A `ReplaySubject` replays a specified number of previous emissions to new subscribers.

```typescript
import { ReplaySubject } from 'rxjs';

// Replay the last 3 values to new subscribers
const subject = new ReplaySubject<string>(3);

subject.next('A');
subject.next('B');
subject.next('C');
subject.next('D');
subject.next('E');

// New subscriber gets the last 3 values immediately
subject.subscribe(val => console.log('Late subscriber:', val));
// Late subscriber: C
// Late subscriber: D
// Late subscriber: E
```

```
Timeline:
  next('A')  next('B')  next('C')  next('D')  next('E')  → Subscriber joins
                                                             Gets: C, D, E
  Buffer (size 3): [C, D, E]
```

**Use case -- Chat message history:**

```typescript
@Injectable({ providedIn: 'root' })
export class ChatService {
  // Replay the last 50 messages to new subscribers (e.g., when user opens chat)
  private messages = new ReplaySubject<ChatMessage>(50);

  messages$ = this.messages.asObservable();

  sendMessage(message: ChatMessage): void {
    this.messages.next(message);
  }
}
```

**ReplaySubject with time window:**

```typescript
// Replay values from the last 5 seconds (regardless of count)
const subject = new ReplaySubject<number>(Infinity, 5000);
// First arg: buffer size (Infinity = no limit)
// Second arg: window time in ms (5000 = 5 seconds)
```

### AsyncSubject -- Only Emits the Last Value on Completion

An `AsyncSubject` only emits the **very last** value it received, and only when it **completes**. If it errors, nothing is emitted.

```typescript
import { AsyncSubject } from 'rxjs';

const subject = new AsyncSubject<number>();

subject.subscribe(val => console.log('Subscriber:', val));

subject.next(1);   // Nothing yet
subject.next(2);   // Nothing yet
subject.next(3);   // Nothing yet
subject.complete(); // NOW it emits: Subscriber: 3 (only the LAST value)
```

```
Timeline:
  next(1)    next(2)    next(3)    complete()
  (silent)   (silent)   (silent)   → Emits: 3
```

**Use case:** When you only care about the final result of a computation, like caching the result of an expensive operation.

### When to Use Each Subject

| Subject Type | Initial Value? | Late Subscribers Get | Use When |
|---|---|---|---|
| **Subject** | No | Nothing (only future values) | Event bus, notifications, user actions |
| **BehaviorSubject** | Yes (required) | The LAST emitted value | State management, current user, settings |
| **ReplaySubject** | No | Last N values | Chat history, audit logs, recent events |
| **AsyncSubject** | No | Only the FINAL value (after complete) | Expensive computation result, caching |

**Decision flowchart:**

```
Do you need an initial/current value?
  ├── YES → BehaviorSubject
  └── NO
       Do late subscribers need past values?
         ├── YES → How many?
         │    ├── All past values → ReplaySubject(Infinity)
         │    ├── Last N values → ReplaySubject(N)
         │    └── Only the final value → AsyncSubject
         └── NO → Subject
```

---

## 9.6 The async Pipe

The `async` pipe is Angular's built-in pipe for working with Observables (and Promises) in templates. It is the **best practice** for handling Observables in your templates.

### What It Does

```
Component Class                          Template
   users$: Observable<User[]>   ──→   {{ users$ | async }}

The async pipe:
  1. SUBSCRIBES to the Observable automatically
  2. Returns the latest emitted value to the template
  3. UNSUBSCRIBES automatically when the component is destroyed
  4. Marks the component for change detection when a new value arrives
```

### Why It Is the Best Approach

| Benefit | Explanation |
|---|---|
| **No memory leaks** | Auto-unsubscribes on component destroy -- impossible to forget |
| **Less boilerplate** | No `ngOnDestroy`, no `Subscription` variables, no `takeUntil` |
| **OnPush compatible** | Works perfectly with `ChangeDetectionStrategy.OnPush` |
| **Cleaner component class** | No imperative subscribe/unsubscribe code |
| **Single source of truth** | The Observable IS the data, no intermediate state variable |

### Basic Usage

**Without async pipe (imperative approach):**

```typescript
// Component class -- MORE code, potential memory leaks
@Component({
  selector: 'app-user-list',
  template: `
    <ul>
      <li *ngFor="let user of users">{{ user.name }}</li>
    </ul>
  `
})
export class UserListComponent implements OnInit, OnDestroy {
  users: User[] = [];
  private subscription!: Subscription;

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    this.subscription = this.userService.getUsers().subscribe(users => {
      this.users = users;  // Manual assignment
    });
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();  // Manual cleanup
  }
}
```

**With async pipe (reactive approach):**

```typescript
// Component class -- LESS code, no memory leaks
@Component({
  selector: 'app-user-list',
  template: `
    <ul>
      <li *ngFor="let user of users$ | async">{{ user.name }}</li>
    </ul>
  `
})
export class UserListComponent implements OnInit {
  users$!: Observable<User[]>;

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    this.users$ = this.userService.getUsers();
    // That's it! No subscribe(), no unsubscribe(), no ngOnDestroy
  }
}
```

### Using with `*ngIf` and the `as` Keyword

The `as` keyword lets you capture the emitted value in a template variable. This is extremely useful for avoiding multiple subscriptions.

```html
<!-- BAD: Multiple async pipes = multiple subscriptions! -->
<div>
  <h1>{{ (user$ | async)?.name }}</h1>
  <p>{{ (user$ | async)?.email }}</p>
  <p>{{ (user$ | async)?.role }}</p>
</div>
<!-- This creates 3 separate subscriptions to user$! -->

<!-- GOOD: Use *ngIf with 'as' to subscribe ONCE -->
<div *ngIf="user$ | async as user">
  <h1>{{ user.name }}</h1>
  <p>{{ user.email }}</p>
  <p>{{ user.role }}</p>
</div>
<!-- Only ONE subscription, and 'user' is the unwrapped value -->
```

**How `*ngIf="obs$ | async as variable"` works:**

1. `async` subscribes to `obs$` and gets the emitted value
2. `as user` assigns that value to a local template variable called `user`
3. `*ngIf` checks if `user` is truthy -- if so, it renders the block
4. Inside the block, `user` is the actual value (not the Observable)

**Showing a loading state:**

```html
<!-- Show loading until data arrives -->
<div *ngIf="user$ | async as user; else loading">
  <h1>{{ user.name }}</h1>
  <p>Email: {{ user.email }}</p>
</div>

<ng-template #loading>
  <p>Loading user data...</p>
  <div class="spinner"></div>
</ng-template>
```

**Handling empty arrays (ngIf treats [] as truthy):**

```html
<!-- This works because [] is truthy in JavaScript -->
<div *ngIf="users$ | async as users">
  <p *ngIf="users.length === 0">No users found.</p>
  <ul>
    <li *ngFor="let user of users">{{ user.name }}</li>
  </ul>
</div>
```

### Using with `*ngFor`

```html
<!-- Direct usage -->
<ul>
  <li *ngFor="let product of products$ | async">
    {{ product.name }} - {{ product.price | currency }}
  </li>
</ul>

<!-- With trackBy for performance -->
<ul>
  <li *ngFor="let product of products$ | async; trackBy: trackByProductId">
    {{ product.name }} - {{ product.price | currency }}
  </li>
</ul>
```

```typescript
trackByProductId(index: number, product: Product): number {
  return product.id;
}
```

### Multiple Async Pipes in One Template

Sometimes you need data from multiple Observables. There are a couple of clean patterns:

**Pattern 1: Multiple `*ngIf` with `as`**

```html
<ng-container *ngIf="user$ | async as user">
  <ng-container *ngIf="orders$ | async as orders">
    <h1>Welcome, {{ user.name }}</h1>
    <p>You have {{ orders.length }} orders.</p>
    <ul>
      <li *ngFor="let order of orders">
        Order #{{ order.id }}: {{ order.total | currency }}
      </li>
    </ul>
  </ng-container>
</ng-container>
```

**Pattern 2: Combine in the component using `combineLatest` (cleaner)**

```typescript
@Component({
  selector: 'app-dashboard',
  template: `
    <div *ngIf="vm$ | async as vm">
      <h1>Welcome, {{ vm.user.name }}</h1>
      <p>You have {{ vm.orders.length }} orders</p>
      <p>Notifications: {{ vm.notifications.length }}</p>
    </div>
  `
})
export class DashboardComponent implements OnInit {
  vm$!: Observable<{
    user: User;
    orders: Order[];
    notifications: Notification[];
  }>;

  constructor(
    private userService: UserService,
    private orderService: OrderService,
    private notifService: NotificationService
  ) {}

  ngOnInit(): void {
    // Combine all data into a single "View Model" Observable
    this.vm$ = combineLatest({
      user: this.userService.currentUser$,
      orders: this.orderService.getOrders(),
      notifications: this.notifService.getNotifications()
    });
  }
}
```

This "View Model" pattern (`vm$`) is an Angular best practice for complex components. A single `async` pipe subscription gives you all the data your template needs.

---

## 9.7 Practical Patterns

### Pattern 1: Search with Debounce (Typeahead Search)

This is the classic RxJS pattern. A search input that calls an API as the user types, but intelligently handles rapid typing.

```typescript
import { Component, OnInit } from '@angular/core';
import { FormControl } from '@angular/forms';
import { Observable, of } from 'rxjs';
import {
  debounceTime,
  distinctUntilChanged,
  switchMap,
  catchError,
  tap,
  filter
} from 'rxjs/operators';

@Component({
  selector: 'app-search',
  template: `
    <div class="search-container">
      <input
        type="text"
        [formControl]="searchControl"
        placeholder="Search products...">

      <!-- Loading indicator -->
      <div *ngIf="isLoading" class="spinner">Searching...</div>

      <!-- Results -->
      <ul *ngIf="results$ | async as results">
        <li *ngFor="let result of results">
          {{ result.name }} - {{ result.price | currency }}
        </li>
        <li *ngIf="results.length === 0">No results found.</li>
      </ul>
    </div>
  `
})
export class SearchComponent implements OnInit {
  searchControl = new FormControl('');
  results$!: Observable<Product[]>;
  isLoading = false;

  constructor(private searchService: SearchService) {}

  ngOnInit(): void {
    this.results$ = this.searchControl.valueChanges.pipe(
      // Step 1: Wait 300ms after the user stops typing
      // Why? To avoid firing an API call for every single keystroke
      debounceTime(300),

      // Step 2: Only proceed if the value actually changed
      // Why? If user types "abc", deletes "c", types "c" again -> still "abc"
      distinctUntilChanged(),

      // Step 3: Only search if there are at least 2 characters
      filter(term => term !== null && term.length >= 2),

      // Step 4: Show loading indicator
      tap(() => this.isLoading = true),

      // Step 5: switchMap cancels the previous HTTP request if a new term arrives
      // Why switchMap? Because we only care about the LATEST search results
      switchMap(term =>
        this.searchService.search(term).pipe(
          // Handle errors within the inner Observable so the outer stream survives
          catchError(error => {
            console.error('Search failed:', error);
            return of([]);  // Return empty results on error
          })
        )
      ),

      // Step 6: Hide loading indicator
      tap(() => this.isLoading = false)
    );
  }
}
```

**The data flow visualized:**

```
User types: "a" "an" "ang" "angu" "angul" "angular"
              │    │    │     │      │       │
debounce(300) │    │    │     │      │       │
              X    X    X     X      X       ✓ (only "angular" survives)
              │                              │
distinctUntilChanged                         │ (different from last, proceed)
              │                              │
filter(len>=2)                               │ (length 7 >= 2, proceed)
              │                              │
switchMap ─── │ ──────────────────── HTTP GET /api/search?q=angular
              │                              │
              │                              ▼
              │                        [results array]
              │                              │
              ▼                              ▼
           Nothing                    Template renders results
```

### Pattern 2: Combining HTTP Calls

**Sequential calls (second depends on first):**

```typescript
// Get user, then use user.id to get their orders
this.userService.getCurrentUser().pipe(
  switchMap(user =>
    this.orderService.getOrdersByUser(user.id).pipe(
      // Combine user and orders into one object
      map(orders => ({ user, orders }))
    )
  )
).subscribe(({ user, orders }) => {
  this.user = user;
  this.orders = orders;
});
```

**Parallel calls (independent of each other):**

```typescript
// Load all dashboard data at once
forkJoin({
  stats: this.dashboardService.getStats(),
  recentOrders: this.orderService.getRecent(5),
  notifications: this.notificationService.getUnread(),
  weather: this.weatherService.getCurrent()
}).subscribe(({ stats, recentOrders, notifications, weather }) => {
  this.stats = stats;
  this.recentOrders = recentOrders;
  this.notifications = notifications;
  this.weather = weather;
  this.isLoading = false;
});
```

**Sequential then parallel (get config, then use it for multiple parallel calls):**

```typescript
this.configService.getConfig().pipe(
  switchMap(config =>
    forkJoin({
      users: this.http.get<User[]>(`${config.apiUrl}/users`),
      products: this.http.get<Product[]>(`${config.apiUrl}/products`)
    })
  )
).subscribe(({ users, products }) => {
  this.users = users;
  this.products = products;
});
```

### Pattern 3: Polling (Repeated API Calls)

**Simple polling -- refresh data every N seconds:**

```typescript
import { interval, switchMap, startWith } from 'rxjs';

@Component({
  selector: 'app-live-dashboard',
  template: `
    <div *ngIf="data$ | async as data">
      <h2>Live Stats (updates every 10s)</h2>
      <p>Active Users: {{ data.activeUsers }}</p>
      <p>Orders Today: {{ data.ordersToday }}</p>
      <p>Last Updated: {{ lastUpdated | date:'medium' }}</p>
    </div>
  `
})
export class LiveDashboardComponent implements OnInit {
  data$!: Observable<DashboardData>;
  lastUpdated = new Date();

  constructor(private dashboardService: DashboardService) {}

  ngOnInit(): void {
    this.data$ = interval(10000).pipe(   // Every 10 seconds
      startWith(0),                       // Also fire immediately (don't wait 10s)
      switchMap(() =>                     // Cancel previous if it's still running
        this.dashboardService.getStats().pipe(
          catchError(err => {
            console.error('Polling failed:', err);
            return of(null);              // Return null on error, keep polling
          })
        )
      ),
      filter((data): data is DashboardData => data !== null),
      tap(() => this.lastUpdated = new Date())
    );
    // async pipe handles subscribe/unsubscribe
    // When user navigates away, polling STOPS automatically!
  }
}
```

**Polling with pause/resume:**

```typescript
export class LiveDashboardComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  private pause$ = new BehaviorSubject<boolean>(false);

  data$!: Observable<DashboardData>;

  ngOnInit(): void {
    this.data$ = this.pause$.pipe(
      switchMap(isPaused => {
        if (isPaused) {
          return EMPTY;  // Stop polling when paused
        }
        return interval(10000).pipe(
          startWith(0),
          switchMap(() => this.dashboardService.getStats())
        );
      }),
      takeUntil(this.destroy$)
    );
  }

  togglePolling(): void {
    this.pause$.next(!this.pause$.value);
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

### Pattern 4: Error Handling and Retry

**Comprehensive error handling pattern:**

```typescript
import { Component, OnInit } from '@angular/core';
import { Observable, of, timer, EMPTY } from 'rxjs';
import { catchError, retry, tap, finalize, switchMap } from 'rxjs/operators';

@Component({
  selector: 'app-data-loader',
  template: `
    <div *ngIf="isLoading" class="loading">
      <div class="spinner"></div>
      <p>Loading data...</p>
    </div>

    <div *ngIf="error" class="error-banner">
      <p>{{ error }}</p>
      <button (click)="reload()">Try Again</button>
    </div>

    <div *ngIf="data$ | async as data">
      <h2>Data Loaded Successfully</h2>
      <pre>{{ data | json }}</pre>
    </div>
  `
})
export class DataLoaderComponent implements OnInit {
  data$!: Observable<any>;
  isLoading = false;
  error: string | null = null;

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.error = null;
    this.isLoading = true;

    this.data$ = this.http.get('/api/data').pipe(
      // Log for debugging
      tap(data => console.log('Data received:', data)),

      // Retry with exponential backoff
      retry({
        count: 3,
        delay: (error, retryCount) => {
          const delayMs = Math.pow(2, retryCount) * 1000; // 2s, 4s, 8s
          console.warn(`Retry ${retryCount} in ${delayMs}ms...`);
          return timer(delayMs);
        }
      }),

      // After all retries exhausted, handle the error
      catchError(error => {
        console.error('All retries failed:', error);

        // Set user-friendly error message based on error type
        if (error.status === 0) {
          this.error = 'Cannot connect to server. Check your internet connection.';
        } else if (error.status === 404) {
          this.error = 'The requested data was not found.';
        } else if (error.status === 500) {
          this.error = 'Server error. Please try again later.';
        } else {
          this.error = 'An unexpected error occurred.';
        }

        return EMPTY;  // Complete without emitting
      }),

      // Always hide loading spinner
      finalize(() => {
        this.isLoading = false;
      })
    );
  }

  reload(): void {
    this.loadData();  // Re-create the Observable pipeline
  }
}
```

**Error handling in a service (centralized):**

```typescript
@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(
    private http: HttpClient,
    private notificationService: NotificationService
  ) {}

  // Generic method with built-in error handling
  get<T>(url: string, fallback?: T): Observable<T> {
    return this.http.get<T>(url).pipe(
      retry({
        count: 2,
        delay: (_, retryCount) => timer(retryCount * 1000)
      }),
      catchError(error => {
        this.notificationService.showError(`Failed to load: ${url}`);

        if (fallback !== undefined) {
          return of(fallback);
        }

        throw error;  // Re-throw if no fallback provided
      })
    );
  }
}

// Usage in a component:
this.apiService.get<User[]>('/api/users', []).subscribe(users => {
  this.users = users;  // Either real data or empty array fallback
});
```

---

## 9.8 Summary

| Concept | What You Learned |
|---|---|
| **Observable** | A stream of data emitted over time; lazy, cancellable, supports multiple values |
| **Observer** | The consumer: `{ next, error, complete }` callbacks |
| **subscribe()** | Activates an Observable; triggers execution |
| **unsubscribe()** | Stops receiving values; prevents memory leaks |
| **of(), from()** | Create Observables from values, arrays, or promises |
| **interval(), timer()** | Create time-based Observables |
| **pipe()** | Chain operators to transform, filter, and compose streams |
| **map** | Transform each emitted value |
| **switchMap** | Cancel previous inner Observable, start new (typeahead!) |
| **mergeMap** | Run all inner Observables in parallel |
| **concatMap** | Run inner Observables one at a time, in order |
| **exhaustMap** | Ignore new triggers while current is running (button clicks!) |
| **filter** | Keep only values matching a condition |
| **debounceTime** | Wait for a pause before emitting (search input!) |
| **throttleTime** | Limit emission frequency (scroll events!) |
| **distinctUntilChanged** | Skip consecutive duplicate values |
| **take, takeUntil, first** | Control how many values to receive |
| **combineLatest** | Combine latest values from multiple streams |
| **forkJoin** | Wait for all Observables to complete (like Promise.all) |
| **merge** | Combine multiple streams into one |
| **tap** | Side effects (logging) without changing the stream |
| **catchError** | Handle errors gracefully with fallbacks |
| **retry** | Automatically retry failed operations |
| **finalize** | Run cleanup code on complete or error |
| **Subject** | Observable + Observer; no initial value; event bus |
| **BehaviorSubject** | Has initial value; replays last value to late subscribers |
| **ReplaySubject** | Replays N previous values to late subscribers |
| **AsyncSubject** | Emits only the last value, only on completion |
| **async pipe** | Auto-subscribe/unsubscribe in templates (best practice!) |
| **Typeahead pattern** | debounceTime + distinctUntilChanged + switchMap |
| **Polling** | interval + startWith + switchMap |
| **Error handling** | retry + catchError + finalize |

**Key takeaways:**

1. **Always use the `async` pipe** when displaying Observable data in templates.
2. **Always unsubscribe** from long-lived Observables (use `takeUntil` or `async` pipe).
3. **Use `switchMap`** for search/typeahead -- it is the most important higher-order mapping operator.
4. **Use `exhaustMap`** for button clicks to prevent double-submit.
5. **Use `BehaviorSubject`** for state management in services.
6. **Handle errors** with `catchError` and provide user-friendly fallbacks.
7. **Use `forkJoin`** for parallel HTTP calls that all need to complete.

---

**Next:** [Phase 10 -- Modules & Architecture](./Phase10-Modules-Architecture.md)
