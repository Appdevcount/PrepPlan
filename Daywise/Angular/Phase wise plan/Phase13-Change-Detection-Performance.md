# Phase 13: Change Detection & Performance Optimization

> "The fastest code is the code that never runs. The secret to building blazing-fast Angular applications is not about writing faster code — it's about telling Angular to do *less work*. Understanding change detection is the single most impactful skill that separates a junior Angular developer from a senior one. Master this phase, and you will never again wonder why your app feels sluggish."

---

## 13.1 What is Change Detection?

### The Core Problem: Keeping the DOM in Sync with Component State

Every Angular application has two worlds:

1. **The JavaScript World** — Your component classes, variables, objects, arrays
2. **The DOM World** — What the user actually sees on screen (HTML elements, text, styles)

When your JavaScript data changes, the DOM must update to reflect that change. **Change detection** is the mechanism Angular uses to figure out *what changed* and *what part of the DOM needs updating*.

```
THE FUNDAMENTAL PROBLEM:
========================

  JavaScript World                    DOM World
  (your component)                    (what user sees)

  ┌───────────────────┐              ┌───────────────────┐
  │ this.userName =   │              │ <h1>              │
  │   'Alice'         │  ──SYNC?──►  │   Alice           │
  │                   │              │ </h1>             │
  └───────────────────┘              └───────────────────┘

  User clicks a button...

  ┌───────────────────┐              ┌───────────────────┐
  │ this.userName =   │              │ <h1>              │
  │   'Bob'           │  ──SYNC?──►  │   Alice  ← STALE! │
  │                   │              │ </h1>             │
  └───────────────────┘              └───────────────────┘

  Angular's change detection fixes this:

  ┌───────────────────┐   CD runs    ┌───────────────────┐
  │ this.userName =   │  ─────────►  │ <h1>              │
  │   'Bob'           │              │   Bob   ← UPDATED!│
  │                   │              │ </h1>             │
  └───────────────────┘              └───────────────────┘
```

### Why Can't We Just Update the DOM Directly?

You *could* manually do `document.getElementById('name').textContent = 'Bob'` every time data changes. But in a real application:

| Challenge | Why It's Hard |
|-----------|---------------|
| Hundreds of bindings | A single component might have 50+ `{{ }}` expressions |
| Nested components | Parent data flows to children who flow to grandchildren |
| Async events | HTTP responses, timers, user clicks all change data at unpredictable times |
| Computed values | `{{ firstName + ' ' + lastName }}` depends on two variables |
| Conditional rendering | `*ngIf` blocks appear/disappear based on data |

Angular's change detection automates ALL of this. But automation comes at a cost — it can be slow if you don't understand how to guide it.

### Real-World Analogy: Security Guard vs. Smart Motion Sensors

```
APPROACH 1: Security Guard (Default Change Detection)
=====================================================

Every time ANYTHING happens (door opens, phone rings, light flickers):

  Guard walks through EVERY room in the building:

  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
  │ Room 1  │  │ Room 2  │  │ Room 3  │  │ Room 4  │
  │ Check ✓ │→ │ Check ✓ │→ │ Check ✓ │→ │ Check ✓ │
  └─────────┘  └─────────┘  └─────────┘  └─────────┘
       ↓
  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
  │ Room 5  │  │ Room 6  │  │ Room 7  │  │ Room 8  │
  │ Check ✓ │→ │ Check ✓ │→ │ Check ✓ │→ │ Check ✓ │
  └─────────┘  └─────────┘  └─────────┘  └─────────┘

  → Works, but SLOW. Checks rooms that haven't changed.
  → 8 rooms checked, but only Room 3 actually changed!


APPROACH 2: Smart Motion Sensors (OnPush Change Detection)
==========================================================

Sensors only trigger for rooms where motion is detected:

  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
  │ Room 1  │  │ Room 2  │  │ Room 3  │  │ Room 4  │
  │ Skip  ○ │  │ Skip  ○ │  │ CHECK ● │  │ Skip  ○ │
  └─────────┘  └─────────┘  └─────────┘  └─────────┘
                                  ↑
                          Motion detected!
                          Only this room checked.

  → FAST. Only 1 room checked instead of 8!
```

---

## 13.2 Zone.js — The Magic Behind Change Detection

### The Problem: How Does Angular Know When Something Changed?

Think about this: you write `this.name = 'Bob'` in a click handler. How does Angular *know* to re-render? You didn't call any special `setState()` method (like React). You didn't dispatch an action (like Redux). You just... assigned a variable.

The answer is **Zone.js** — one of the most clever (and controversial) pieces of Angular's architecture.

### What Zone.js Actually Does

Zone.js **monkey-patches** every asynchronous browser API. "Monkey-patching" means it replaces the original browser functions with wrapped versions that notify Angular.

```
WHAT ZONE.JS MONKEY-PATCHES:
=============================

  Original Browser API          Zone.js Replacement
  ─────────────────────         ────────────────────────────
  setTimeout()            →     Zone-wrapped setTimeout()
  setInterval()           →     Zone-wrapped setInterval()
  addEventListener()      →     Zone-wrapped addEventListener()
  XMLHttpRequest          →     Zone-wrapped XMLHttpRequest
  fetch()                 →     Zone-wrapped fetch()
  Promise.then()          →     Zone-wrapped Promise.then()
  requestAnimationFrame() →     Zone-wrapped requestAnimationFrame()
  WebSocket events        →     Zone-wrapped WebSocket events
  ... and 200+ more APIs

  Each wrapper does:
  ┌──────────────────────────────────────────────┐
  │  1. Let the original API do its work         │
  │  2. After it completes, notify Angular:      │
  │     "Hey! Something async just finished!     │
  │      You should check for changes!"          │
  └──────────────────────────────────────────────┘
```

### How It Works: Step by Step

```
USER CLICKS A BUTTON
         │
         ▼
┌─────────────────────────────────────────┐
│  Zone.js intercepts the click event     │  ← Zone.js wrapped addEventListener()
│  (because addEventListener is patched)  │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Your click handler runs:               │
│    this.userName = 'Bob';               │  ← Your code executes normally
│    this.http.get('/api/data')...        │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Zone.js detects: "Async task ended!"   │
│  Calls: NgZone.onMicrotaskEmpty         │  ← Zone.js notifies Angular
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  Angular triggers Change Detection      │
│  Walks the entire component tree        │  ← Angular checks all components
│  Compares old DOM values with new ones  │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  DOM updates where values differ        │
│  <h1>Alice</h1> → <h1>Bob</h1>         │  ← Only changed elements update
└─────────────────────────────────────────┘
```

### NgZone: Angular's Wrapper Around Zone.js

Angular doesn't use Zone.js directly. It wraps it in a service called `NgZone` that gives you control:

```typescript
import { Component, NgZone } from '@angular/core';

@Component({
  selector: 'app-performance-demo',
  template: `
    <p>Counter: {{ counter }}</p>
    <p>Mouse position: tracked in console only</p>
    <button (click)="startTracking()">Start Mouse Tracking</button>
  `
})
export class PerformanceDemoComponent {
  counter = 0;

  constructor(private ngZone: NgZone) {}

  startTracking() {
    // ← BAD: This would trigger change detection on EVERY mouse move
    // document.addEventListener('mousemove', (e) => {
    //   console.log(e.clientX, e.clientY);
    // });

    // ← GOOD: Run outside Angular's zone — no change detection triggered
    this.ngZone.runOutsideAngular(() => {              // ← Escape Angular's zone
      document.addEventListener('mousemove', (e) => {
        console.log(e.clientX, e.clientY);             // ← Runs without triggering CD
        // This fires 60+ times per second!
        // Without runOutsideAngular, Angular would run
        // change detection 60+ times per second for NOTHING
      });
    });
  }

  updateCounter() {
    // ← If you're outside the zone but need to update the UI:
    this.ngZone.run(() => {                            // ← Re-enter Angular's zone
      this.counter++;                                  // ← This WILL trigger CD
    });
  }
}
```

### NgZone API Reference

| Method | What It Does | When to Use |
|--------|-------------|-------------|
| `run(fn)` | Executes `fn` INSIDE Angular's zone. Triggers CD after. | When you need UI updates from code running outside the zone |
| `runOutsideAngular(fn)` | Executes `fn` OUTSIDE Angular's zone. No CD triggered. | For performance-heavy operations that don't affect the UI |
| `onMicrotaskEmpty` | Observable that emits when all microtasks complete | For debugging or advanced scheduling |
| `onStable` | Observable that emits when the zone becomes stable | For running code after all async work finishes |
| `isStable` | Boolean — is the zone currently stable? | For testing or conditional logic |
| `hasPendingMicrotasks` | Boolean — are there pending microtasks? | For debugging async issues |

### Common Scenarios: Inside vs. Outside the Zone

```
SCENARIO: Mouse tracking for analytics (no UI update needed)
─────────────────────────────────────────────────────────────

  INSIDE ZONE (BAD):                    OUTSIDE ZONE (GOOD):
  ┌────────────────────┐                ┌─────────────────────┐
  │ mousemove fires    │                │ mousemove fires     │
  │ → CD runs (wasted) │ × 60/sec      │ → NO CD (just logs) │ × 60/sec
  │ → DOM checked      │                │ → console.log only  │
  │ → Nothing changed! │                │                     │
  └────────────────────┘                └─────────────────────┘
  Cost: ~60 CD cycles/sec              Cost: 0 CD cycles/sec


SCENARIO: WebSocket real-time feed (UI update needed periodically)
──────────────────────────────────────────────────────────────────

  INSIDE ZONE (BAD):                    SMART APPROACH:
  ┌────────────────────┐                ┌─────────────────────────┐
  │ Every WS message   │                │ Receive outside zone    │
  │ → CD runs          │ × 100/sec     │ → Buffer messages       │
  │ → All components   │                │ → Every 500ms, run()    │
  │   checked          │                │   to update UI          │
  └────────────────────┘                └─────────────────────────┘
  Cost: ~100 CD/sec                     Cost: ~2 CD/sec
```

```typescript
// ← SMART PATTERN: Buffer WebSocket messages, update UI periodically
@Component({
  selector: 'app-live-feed',
  template: `
    <div *ngFor="let msg of messages">{{ msg }}</div>
  `
})
export class LiveFeedComponent implements OnInit, OnDestroy {
  messages: string[] = [];
  private buffer: string[] = [];                      // ← Collect messages here
  private intervalId: any;

  constructor(
    private ngZone: NgZone,
    private wsService: WebSocketService
  ) {}

  ngOnInit() {
    this.ngZone.runOutsideAngular(() => {             // ← Receive messages outside zone
      this.wsService.messages$.subscribe(msg => {
        this.buffer.push(msg);                        // ← No CD triggered per message
      });

      this.intervalId = setInterval(() => {           // ← Every 500ms...
        if (this.buffer.length > 0) {
          this.ngZone.run(() => {                     // ← Re-enter zone to update UI
            this.messages = [
              ...this.messages,
              ...this.buffer                          // ← Flush the buffer
            ];
            this.buffer = [];                         // ← Clear the buffer
          });
        }
      }, 500);
    });
  }

  ngOnDestroy() {
    clearInterval(this.intervalId);                   // ← Always clean up!
  }
}
```

---

## 13.3 The Change Detection Cycle

### How Angular Traverses the Component Tree

Angular components form a tree structure. When change detection runs, Angular walks this tree **top-down, depth-first**.

```
COMPONENT TREE:
═══════════════

                    AppComponent             ← CD starts here (root)
                   /            \
                  /              \
          HeaderComponent    MainComponent   ← Then checks these
          /                  /          \
         /                  /            \
  NavComponent    SidebarComponent   ContentComponent  ← Then these
                                     /        \
                                    /          \
                            CardComponent  TableComponent  ← Then these
                                           /      \
                                          /        \
                                   RowComponent  PaginationComponent  ← Finally these


TRAVERSAL ORDER (Default Strategy):
════════════════════════════════════

  1. AppComponent        ✓ Check
  2. HeaderComponent     ✓ Check
  3. NavComponent        ✓ Check
  4. MainComponent       ✓ Check
  5. SidebarComponent    ✓ Check
  6. ContentComponent    ✓ Check
  7. CardComponent       ✓ Check
  8. TableComponent      ✓ Check
  9. RowComponent        ✓ Check
  10. PaginationComponent ✓ Check

  → ALL 10 components checked, even if only NavComponent's data changed!
```

### What "Checking" a Component Means

For each component, Angular:

1. Evaluates ALL template expressions (`{{ }}`, `[property]`, etc.)
2. Compares the new values with the previously rendered values
3. Updates only the DOM elements where values differ

```typescript
@Component({
  selector: 'app-user-card',
  template: `
    <!-- Angular evaluates ALL of these during change detection: -->
    <div class="card" [class.active]="isActive">        <!-- ← Expression 1: isActive -->
      <h2>{{ user.name }}</h2>                           <!-- ← Expression 2: user.name -->
      <p>{{ user.email }}</p>                            <!-- ← Expression 3: user.email -->
      <p>Age: {{ calculateAge(user.birthDate) }}</p>     <!-- ← Expression 4: calls function! -->
      <p>Status: {{ isActive ? 'Online' : 'Offline' }}</p>  <!-- ← Expression 5 -->
      <span>{{ user.posts.length }} posts</span>         <!-- ← Expression 6: user.posts.length -->
    </div>
  `
})
export class UserCardComponent {
  @Input() user!: User;
  @Input() isActive = false;

  calculateAge(birthDate: Date): number {               // ← Called EVERY CD cycle!
    // This runs even if birthDate hasn't changed
    const today = new Date();
    const age = today.getFullYear() - birthDate.getFullYear();
    return age;
  }
}
```

### ExpressionChangedAfterItHasBeenCheckedError

This is one of Angular's most confusing errors. It happens **only in development mode** (Angular runs change detection TWICE in dev mode as a safety check).

```
WHY THIS ERROR EXISTS:
══════════════════════

  Dev Mode Change Detection runs TWICE:

  FIRST PASS:                           SECOND PASS (verification):
  ┌──────────────────────┐              ┌──────────────────────────┐
  │ Evaluate: {{ name }} │              │ Evaluate: {{ name }}     │
  │ Result: 'Alice'      │              │ Result: 'Bob' ← CHANGED!│
  └──────────────────────┘              └──────────────────────────┘
                                                     │
                                                     ▼
                                        ExpressionChangedAfterItHas
                                        BeenCheckedError!!!

  → The value changed BETWEEN the two CD passes
  → This means something is modifying data DURING change detection
  → Angular considers this a bug in your code
```

```typescript
// ← BAD: This causes the error
@Component({
  selector: 'app-broken',
  template: `<p>{{ currentTime }}</p>`
})
export class BrokenComponent {
  get currentTime() {
    return new Date().toISOString();     // ← Returns different value every time!
    // First CD pass: "2024-01-15T10:30:00.123Z"
    // Second CD pass: "2024-01-15T10:30:00.456Z"  ← Different! ERROR!
  }
}

// ← ALSO BAD: Modifying data in ngAfterViewInit
@Component({
  selector: 'app-also-broken',
  template: `<p>{{ title }}</p>`
})
export class AlsoBrokenComponent implements AfterViewInit {
  title = 'Hello';

  ngAfterViewInit() {
    this.title = 'World';                // ← Changes data AFTER view is checked
    // CD already checked {{ title }} as 'Hello'
    // Now it's 'World' — ERROR!
  }
}

// ← FIX 1: Use setTimeout to push the change to the next CD cycle
@Component({
  selector: 'app-fixed-v1',
  template: `<p>{{ title }}</p>`
})
export class FixedV1Component implements AfterViewInit {
  title = 'Hello';

  ngAfterViewInit() {
    setTimeout(() => {                   // ← Pushes to next macrotask
      this.title = 'World';             // ← Runs in a NEW CD cycle
    });
  }
}

// ← FIX 2: Use ChangeDetectorRef.detectChanges()
@Component({
  selector: 'app-fixed-v2',
  template: `<p>{{ title }}</p>`
})
export class FixedV2Component implements AfterViewInit {
  title = 'Hello';

  constructor(private cdr: ChangeDetectorRef) {}

  ngAfterViewInit() {
    this.title = 'World';
    this.cdr.detectChanges();            // ← Manually trigger another CD cycle
  }
}
```

### Common Causes and Fixes

| Cause | Example | Fix |
|-------|---------|-----|
| Getter returns new value each call | `get now() { return Date.now(); }` | Store in a variable, update via interval |
| Changing data in `ngAfterViewInit` | `this.title = 'new'` in `ngAfterViewInit` | Use `setTimeout()` or `cdr.detectChanges()` |
| Parent modifies child @Input in lifecycle hook | Parent changes child binding in `ngAfterViewInit` | Use `setTimeout()` or restructure data flow |
| Pipe returns new object reference | Pure pipe that creates new array | Ensure pipe returns same reference if data unchanged |
| Shared service emitting during CD | Service emits value that changes a binding | Use `async` pipe or handle timing carefully |

---

## 13.4 Default Change Detection Strategy

### How Default Strategy Works

By default, Angular uses `ChangeDetectionStrategy.Default`. This means: **check EVERY component on EVERY change detection cycle**, regardless of whether anything actually changed.

```typescript
@Component({
  selector: 'app-example',
  // changeDetection: ChangeDetectionStrategy.Default  ← This is the DEFAULT
  // You don't even need to write it — it's implied
  template: `<p>{{ data }}</p>`
})
export class ExampleComponent {
  data = 'Hello';
}
```

### When Does Default CD Trigger?

| Trigger | Example | Components Checked |
|---------|---------|-------------------|
| Any DOM event | Click, keypress, mousemove, scroll | ALL components |
| `setTimeout` / `setInterval` completes | `setTimeout(() => {}, 1000)` | ALL components |
| HTTP response arrives | `this.http.get()` completes | ALL components |
| Promise resolves | `somePromise.then(...)` | ALL components |
| `requestAnimationFrame` callback | Animation tick | ALL components |

```
DEFAULT STRATEGY VISUALIZATION:
═══════════════════════════════

User clicks a button in ComponentD:

         AppComponent ─── ✓ CHECKED
        /            \
  CompA ── ✓ CHECKED  CompB ── ✓ CHECKED
  /    \              /    \
CompC   CompD      CompE   CompF
✓ CHK   ✓ CHK     ✓ CHK   ✓ CHK
         ↑
    (click happened here)

Result: ALL 7 components checked!
But only CompD's data changed!

For 7 components → fine, barely noticeable
For 700 components → performance disaster
```

### The Cost of Default Change Detection

```typescript
// ← Imagine a dashboard with many components
@Component({
  selector: 'app-dashboard',
  template: `
    <!-- Each of these is a component with its own template expressions -->
    <app-header [user]="currentUser"></app-header>           <!-- ← 5 expressions -->
    <app-sidebar [menu]="menuItems"></app-sidebar>           <!-- ← 12 expressions -->
    <app-stats-panel [stats]="stats"></app-stats-panel>      <!-- ← 20 expressions -->
    <app-data-table [rows]="tableData"></app-data-table>     <!-- ← 500 expressions (100 rows × 5 cols) -->
    <app-chart [data]="chartData"></app-chart>               <!-- ← 50 expressions -->
    <app-notifications [items]="notifications"></app-notifications> <!-- ← 30 expressions -->
    <app-footer></app-footer>                                <!-- ← 3 expressions -->
  `
})
export class DashboardComponent {
  // Every time the user types in a search box,
  // Angular evaluates ALL 620 expressions!
  // Even if search only affects app-data-table!
}
```

---

## 13.5 OnPush Change Detection Strategy

### The Solution: Tell Angular to Skip Unchanged Components

`ChangeDetectionStrategy.OnPush` tells Angular: **"Don't check this component unless I tell you something changed."**

```typescript
import { Component, ChangeDetectionStrategy, Input } from '@angular/core';

@Component({
  selector: 'app-user-card',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← THE KEY LINE
  template: `
    <div class="card">
      <h2>{{ user.name }}</h2>
      <p>{{ user.email }}</p>
    </div>
  `
})
export class UserCardComponent {
  @Input() user!: User;                                // ← Only re-checks when 'user' INPUT reference changes
}
```

### When OnPush Triggers Change Detection

OnPush components are ONLY checked when one of these four things happens:

```
ONPUSH TRIGGER #1: @Input Reference Changes
════════════════════════════════════════════

  Parent passes a NEW object reference to child's @Input:

  // Parent:
  this.user = { ...this.user, name: 'Bob' };    ← New object! CD triggers ✓
  this.user.name = 'Bob';                         ← Same object! CD SKIPPED ✗

  OLD reference ──→ NEW reference
  0x001A            0x002B         ← Different memory address = trigger
  { name: 'Alice' } { name: 'Bob' }


ONPUSH TRIGGER #2: Event Originates IN the Component's Template
═══════════════════════════════════════════════════════════════

  <button (click)="doSomething()">Click</button>    ← Event IN template = trigger ✓

  // But NOT events from child components' internal logic
  // NOT events from services
  // NOT events from document.addEventListener


ONPUSH TRIGGER #3: Async Pipe Receives a New Value
══════════════════════════════════════════════════

  <p>{{ data$ | async }}</p>    ← async pipe calls markForCheck() internally

  // The async pipe is OnPush's best friend!
  // It automatically notifies change detection when the Observable emits


ONPUSH TRIGGER #4: Manually Calling markForCheck() or detectChanges()
════════════════════════════════════════════════════════════════════

  this.cdr.markForCheck();      ← Marks component (and ancestors) for check
  this.cdr.detectChanges();     ← Immediately runs CD on this component
```

### ASCII Diagram: OnPush Skipping Subtrees

```
SCENARIO: Click event in CompD. CompB and CompE are OnPush.
═══════════════════════════════════════════════════════════

         AppComponent ─── ✓ CHECKED (always — it's the root)
        /            \
  CompA ── ✓ CHECKED  CompB (OnPush) ── ✗ SKIPPED!
  /    \              /    \
CompC   CompD      CompE   CompF
✓ CHK   ✓ CHK    (OnPush)
         ↑        ✗ SKIP   ✗ SKIP
    (click here)       ↑        ↑
                  Skipped because parent was skipped

Result: 4 components checked instead of 7!
CompB's entire subtree was SKIPPED because:
  - CompB is OnPush
  - No @Input reference changed on CompB
  - No event originated inside CompB's template
  - No async pipe emitted in CompB
  - No manual markForCheck() was called


WITH MORE ONPUSH COMPONENTS:
════════════════════════════

         AppComponent ─── ✓ CHECKED
        /            \
  CompA (OnPush)     CompB (OnPush)
  ✗ SKIP             ✗ SKIP
  /    \              /    \
CompC   CompD      CompE   CompF
✗ SKIP  ✗ SKIP    ✗ SKIP  ✗ SKIP

Only AppComponent checked! Everything else skipped!
(Assuming the event came from something like a setTimeout in AppComponent)
```

### Common Mistake: Mutating Objects with OnPush

This is the **#1 source of OnPush bugs**:

```typescript
// ← THE BUG: Mutating an object instead of creating a new one
@Component({
  selector: 'app-parent',
  template: `
    <app-user-card [user]="user"></app-user-card>
    <button (click)="updateName()">Update Name</button>
  `
})
export class ParentComponent {
  user: User = { name: 'Alice', email: 'alice@example.com' };

  updateName() {
    // ← BAD: Mutating the same object reference
    this.user.name = 'Bob';
    // Object reference is STILL 0x001A
    // OnPush child sees: "Same reference? Nothing changed. Skip!"
    // UI shows 'Alice' even though data is 'Bob' — BUG!
  }
}

// ← THE FIX: Create a new object reference
@Component({
  selector: 'app-parent',
  template: `
    <app-user-card [user]="user"></app-user-card>
    <button (click)="updateName()">Update Name</button>
  `
})
export class ParentComponent {
  user: User = { name: 'Alice', email: 'alice@example.com' };

  updateName() {
    // ← GOOD: Spread operator creates a NEW object reference
    this.user = { ...this.user, name: 'Bob' };
    // New reference 0x002B created!
    // OnPush child sees: "New reference! I should check!" ✓
    // UI correctly shows 'Bob'
  }
}
```

```
MUTATION vs IMMUTABLE UPDATE:
═════════════════════════════

MUTATION (BAD with OnPush):
┌─────────────────┐     ┌─────────────────┐
│ this.user       │     │ this.user       │
│ ref: 0x001A     │ ──► │ ref: 0x001A     │  ← SAME reference
│ name: 'Alice'   │     │ name: 'Bob'     │    OnPush says: "No change"
└─────────────────┘     └─────────────────┘

IMMUTABLE (GOOD with OnPush):
┌─────────────────┐     ┌─────────────────┐
│ this.user       │     │ this.user       │
│ ref: 0x001A     │     │ ref: 0x002B     │  ← NEW reference
│ name: 'Alice'   │     │ name: 'Bob'     │    OnPush says: "Changed!"
└─────────────────┘     └─────────────────┘
        ↑                       ↑
   old (garbage             new object
   collected)               (used now)
```

### Full OnPush Example with Async Pipe

```typescript
// ← user-list.component.ts — OnPush + Observables + Async Pipe
@Component({
  selector: 'app-user-list',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush enabled
  template: `
    <!-- async pipe automatically calls markForCheck when data arrives -->
    <div *ngIf="users$ | async as users; else loading">
      <app-user-card
        *ngFor="let user of users; trackBy: trackByUserId"
        [user]="user"                                  <!-- ← New array = new references -->
      ></app-user-card>
    </div>

    <ng-template #loading>
      <p>Loading users...</p>
    </ng-template>

    <button (click)="refresh()">Refresh</button>       <!-- ← Template event triggers CD -->
  `
})
export class UserListComponent {
  users$: Observable<User[]>;                          // ← Observable, not a plain array

  constructor(private userService: UserService) {
    this.users$ = this.userService.getUsers();         // ← Data flows via Observable
  }

  refresh() {
    this.users$ = this.userService.getUsers();         // ← New Observable = new emission via async pipe
  }

  trackByUserId(index: number, user: User): number {
    return user.id;                                    // ← trackBy for ngFor performance
  }
}
```

### Decision Guide: Default vs OnPush

```
SHOULD I USE ONPUSH?
════════════════════

START
  │
  ├── Is this a leaf/presentation component?
  │   (just receives data via @Input and displays it)
  │     │
  │     YES → USE ONPUSH ✓ (easiest win)
  │
  ├── Does the component use Observables with async pipe?
  │     │
  │     YES → USE ONPUSH ✓ (async pipe handles everything)
  │
  ├── Is the component part of a large list (100+ items)?
  │     │
  │     YES → USE ONPUSH ✓ (critical for performance)
  │
  ├── Does the component mutate objects/arrays directly?
  │     │
  │     YES → REFACTOR to immutable patterns FIRST, then use OnPush
  │
  ├── Is this the AppComponent or a top-level container?
  │     │
  │     YES → USE ONPUSH ✓ (benefits cascade to children)
  │
  └── Are you starting a new project?
        │
        YES → USE ONPUSH EVERYWHERE from the start ✓
              (Much easier than retrofitting later)
```

---

## 13.6 ChangeDetectorRef Deep Dive

### The ChangeDetectorRef API

`ChangeDetectorRef` is an injectable service that gives you fine-grained control over change detection for a specific component.

```typescript
import { ChangeDetectorRef } from '@angular/core';

@Component({ /* ... */ })
export class MyComponent {
  constructor(private cdr: ChangeDetectorRef) {}       // ← Inject it
}
```

### The Four Methods

```typescript
// ═══════════════════════════════════════════════════════
// METHOD 1: detectChanges()
// ═══════════════════════════════════════════════════════
// What: Immediately runs change detection on THIS component and its children
// When: You need an immediate UI update RIGHT NOW
// Think: "Check me and my kids NOW"

@Component({
  selector: 'app-live-clock',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `<p>{{ time }}</p>`
})
export class LiveClockComponent implements OnInit, OnDestroy {
  time = '';
  private intervalId: any;

  constructor(private cdr: ChangeDetectorRef) {}

  ngOnInit() {
    this.intervalId = setInterval(() => {
      this.time = new Date().toLocaleTimeString();
      this.cdr.detectChanges();                        // ← Force check THIS component NOW
      // Without this, OnPush would never show the updated time
      // because no @Input changed and no template event fired
    }, 1000);
  }

  ngOnDestroy() {
    clearInterval(this.intervalId);
  }
}


// ═══════════════════════════════════════════════════════
// METHOD 2: markForCheck()
// ═══════════════════════════════════════════════════════
// What: Marks this component AND ALL ANCESTORS up to the root for checking
//       on the NEXT change detection cycle
// When: Data changed outside Angular's awareness, and you want the
//       NEXT CD cycle to pick it up
// Think: "Hey Angular, remember to check me next time"

@Component({
  selector: 'app-notification',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div *ngFor="let n of notifications">{{ n.message }}</div>
  `
})
export class NotificationComponent implements OnInit {
  notifications: Notification[] = [];

  constructor(
    private cdr: ChangeDetectorRef,
    private notifService: NotificationService
  ) {}

  ngOnInit() {
    // ← Service pushes data outside of template events
    this.notifService.notifications$.subscribe(notifs => {
      this.notifications = notifs;
      this.cdr.markForCheck();                         // ← Mark for checking on next CD
      // Without this, OnPush would never know to re-render
      // because the subscription callback isn't a template event
    });
  }
}


// ═══════════════════════════════════════════════════════
// METHOD 3: detach()
// ═══════════════════════════════════════════════════════
// What: Completely REMOVES this component from the change detection tree
//       Angular will NEVER check it automatically
// When: You want total control — you'll manually call detectChanges()
// Think: "Leave me alone, I'll handle it myself"

@Component({
  selector: 'app-frozen',
  template: `<p>{{ data }}</p>`
})
export class FrozenComponent implements OnInit {
  data = 'Initial';

  constructor(private cdr: ChangeDetectorRef) {}

  ngOnInit() {
    this.cdr.detach();                                 // ← Remove from CD tree completely!
    // Now even Default strategy won't check this component
    // Button clicks, HTTP responses — nothing triggers CD here
  }

  // Only update when you explicitly call this
  manualUpdate(newData: string) {
    this.data = newData;
    this.cdr.detectChanges();                          // ← Manual check
  }
}


// ═══════════════════════════════════════════════════════
// METHOD 4: reattach()
// ═══════════════════════════════════════════════════════
// What: Re-adds a previously detached component back to the CD tree
// When: You temporarily detached for performance, now want normal behavior
// Think: "OK Angular, you can check me again"

@Component({
  selector: 'app-toggle-cd',
  template: `
    <p>{{ data }}</p>
    <button (click)="toggleCD()">Toggle Change Detection</button>
  `
})
export class ToggleCDComponent {
  data = 'Hello';
  private isDetached = false;

  constructor(private cdr: ChangeDetectorRef) {}

  toggleCD() {
    if (this.isDetached) {
      this.cdr.reattach();                             // ← Resume automatic checking
      this.isDetached = false;
    } else {
      this.cdr.detach();                               // ← Stop automatic checking
      this.isDetached = true;
    }
  }
}
```

### Decision Table: Which Method to Use

```
┌──────────────────────┬──────────────────────────────────────────────┬───────────────────────┐
│ Method               │ Use When                                     │ Example Scenario      │
├──────────────────────┼──────────────────────────────────────────────┼───────────────────────┤
│ detectChanges()      │ You need immediate UI update from            │ setInterval clock,    │
│                      │ outside Angular's awareness                  │ WebSocket message     │
├──────────────────────┼──────────────────────────────────────────────┼───────────────────────┤
│ markForCheck()       │ Data changed via service/subscription,       │ Store subscription,   │
│                      │ OK to wait for next CD cycle                 │ push notification     │
├──────────────────────┼──────────────────────────────────────────────┼───────────────────────┤
│ detach()             │ Component rarely needs to update,            │ Static data display,  │
│                      │ you want total manual control                │ performance-critical  │
├──────────────────────┼──────────────────────────────────────────────┼───────────────────────┤
│ reattach()           │ Previously detached component needs          │ Re-enable CD after a  │
│                      │ to participate in CD again                   │ heavy operation ends  │
└──────────────────────┴──────────────────────────────────────────────┴───────────────────────┘
```

### detectChanges() vs markForCheck()

This distinction confuses many developers. Here's the key difference:

```
detectChanges():
════════════════
  - Runs CD immediately, RIGHT NOW, synchronously
  - Checks THIS component + its children
  - Does NOT check ancestors
  - Can cause ExpressionChanged error if misused

  Component Tree:
       App
      / \
     A   B
    / \
   C   D ← detectChanges() called here
       |
       E

  Checked: D, E (this component and children only)
  NOT checked: App, A, B, C


markForCheck():
═══════════════
  - Does NOT run CD immediately
  - Marks THIS component and ALL ANCESTORS up to root
  - They'll be checked on the NEXT CD cycle
  - Safer than detectChanges()

  Component Tree:
       App ← MARKED (ancestor)
      / \
     A   B
    / \
   C   D ← markForCheck() called here, MARKED
       |
       E

  Marked for next CD: App, A, D
  (path from root to the component)
  Actual CD runs later when something triggers it
```

---

## 13.7 Immutability Patterns for OnPush

### Why Immutability Matters for OnPush

OnPush compares object **references**, not deep values. If you mutate an object, the reference stays the same, and OnPush thinks nothing changed.

```
MUTABLE (reference stays same):          IMMUTABLE (new reference):
═══════════════════════════════          ═══════════════════════════

const arr = [1, 2, 3];                  const arr = [1, 2, 3];
arr.push(4);                            const newArr = [...arr, 4];

arr === arr  →  true                    arr === newArr  →  false
// OnPush: "Same ref, skip"             // OnPush: "New ref, check!"
```

### Object Immutability Patterns

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  address: {
    city: string;
    zip: string;
  };
  tags: string[];
}

// ═══════════════════════════════════════════════════
// UPDATING A TOP-LEVEL PROPERTY
// ═══════════════════════════════════════════════════

// ← BAD: Mutation
this.user.name = 'Bob';                               // ← Same reference, OnPush won't detect

// ← GOOD: Spread operator creates new object
this.user = { ...this.user, name: 'Bob' };             // ← New reference ✓


// ═══════════════════════════════════════════════════
// UPDATING A NESTED OBJECT
// ═══════════════════════════════════════════════════

// ← BAD: Mutation
this.user.address.city = 'Boston';                     // ← Same reference

// ← GOOD: Spread at every nesting level
this.user = {
  ...this.user,                                        // ← New user object
  address: {
    ...this.user.address,                              // ← New address object
    city: 'Boston'                                     // ← Updated city
  }
};


// ═══════════════════════════════════════════════════
// UPDATING AN ARRAY INSIDE AN OBJECT
// ═══════════════════════════════════════════════════

// ← BAD: Mutation
this.user.tags.push('admin');                          // ← Same reference

// ← GOOD: Spread array too
this.user = {
  ...this.user,
  tags: [...this.user.tags, 'admin']                   // ← New array ✓
};
```

### Array Immutability Patterns

```typescript
// ═══════════════════════════════════════════════════
// COMPARISON TABLE: Mutating vs Immutable Array Operations
// ═══════════════════════════════════════════════════

// ┌──────────────────────┬───────────────────────────────┬──────────────────────────────────────┐
// │ Operation            │ MUTATING (bad for OnPush)     │ IMMUTABLE (good for OnPush)          │
// ├──────────────────────┼───────────────────────────────┼──────────────────────────────────────┤
// │ Add item to end      │ arr.push(item)                │ [...arr, item]                       │
// │ Add item to start    │ arr.unshift(item)             │ [item, ...arr]                       │
// │ Remove by index      │ arr.splice(i, 1)              │ arr.filter((_, idx) => idx !== i)    │
// │ Remove by value      │ (find & splice)               │ arr.filter(x => x.id !== id)         │
// │ Update item          │ arr[i] = newItem              │ arr.map(x => x.id === id ? new : x)  │
// │ Sort                 │ arr.sort()                    │ [...arr].sort()                      │
// │ Reverse              │ arr.reverse()                 │ [...arr].reverse()                   │
// │ Clear                │ arr.length = 0                │ []                                   │
// │ Concatenate          │ arr1.push(...arr2)            │ [...arr1, ...arr2]                   │
// └──────────────────────┴───────────────────────────────┴──────────────────────────────────────┘

// Full examples:

// ← ADD
this.items = [...this.items, newItem];                 // ← Append
this.items = [newItem, ...this.items];                 // ← Prepend

// ← REMOVE
this.items = this.items.filter(                        // ← Remove by ID
  item => item.id !== idToRemove
);

// ← UPDATE ONE ITEM
this.items = this.items.map(item =>                    // ← Update matching item
  item.id === updatedItem.id
    ? { ...item, ...updatedItem }                      // ← Create new object for that item
    : item                                             // ← Keep others unchanged
);

// ← SORT (without mutating)
this.items = [...this.items].sort(                     // ← Spread first, then sort the COPY
  (a, b) => a.name.localeCompare(b.name)
);

// ← INSERT AT POSITION
const pos = 2;
this.items = [
  ...this.items.slice(0, pos),                         // ← Items before insertion point
  newItem,                                             // ← New item
  ...this.items.slice(pos)                             // ← Items after insertion point
];
```

### Quick Reference Card

```
IMMUTABILITY CHEAT SHEET FOR ONPUSH:
═════════════════════════════════════

Objects:
  Update property:    { ...obj, key: newValue }
  Remove property:    const { keyToRemove, ...rest } = obj; // rest = new obj without key
  Nested update:      { ...obj, nested: { ...obj.nested, key: newValue } }

Arrays:
  Add:      [...arr, item]
  Remove:   arr.filter(x => x.id !== id)
  Update:   arr.map(x => x.id === id ? { ...x, prop: val } : x)
  Sort:     [...arr].sort(compareFn)
  Reverse:  [...arr].reverse()

Maps:
  Add/Update:  new Map([...map, [key, value]])
  Remove:      new Map([...map].filter(([k]) => k !== key))

Sets:
  Add:      new Set([...set, item])
  Remove:   new Set([...set].filter(x => x !== item))
```

---

## 13.8 Performance Optimization Techniques

### 13.8.1 trackBy in *ngFor

#### The Problem: ngFor Destroys and Recreates DOM Elements

When you use `*ngFor` without `trackBy`, Angular identifies list items by **object reference**. If the array reference changes (which it does with immutable patterns), Angular thinks ALL items are new and destroys/recreates ALL DOM elements.

```
WITHOUT trackBy:
════════════════

Initial render:          After data refresh (new array):
┌──────────────┐         ┌──────────────┐
│ <div> Alice  │ ←DESTROY│ <div> Alice  │ ←CREATE (same data, new DOM!)
│ <div> Bob    │ ←DESTROY│ <div> Bob    │ ←CREATE (same data, new DOM!)
│ <div> Carol  │ ←DESTROY│ <div> Carol  │ ←CREATE (same data, new DOM!)
│              │         │ <div> Dave   │ ←CREATE (actually new)
└──────────────┘         └──────────────┘

4 DOM destructions + 4 DOM creations = 8 operations
Only 1 item actually changed (Dave was added)!


WITH trackBy (tracking by user.id):
════════════════════════════════════

Initial render:          After data refresh:
┌──────────────┐         ┌──────────────┐
│ <div> Alice  │ ←KEEP   │ <div> Alice  │ ←REUSED (same id=1)
│ <div> Bob    │ ←KEEP   │ <div> Bob    │ ←REUSED (same id=2)
│ <div> Carol  │ ←KEEP   │ <div> Carol  │ ←REUSED (same id=3)
│              │         │ <div> Dave   │ ←CREATE (new id=4)
└──────────────┘         └──────────────┘

0 destructions + 1 creation = 1 operation!
```

```typescript
// ← WITHOUT trackBy (default behavior)
@Component({
  selector: 'app-user-list',
  template: `
    <!-- BAD: No trackBy — all items re-created on every data change -->
    <div *ngFor="let user of users">
      <app-user-card [user]="user"></app-user-card>
    </div>
  `
})
export class UserListComponent {
  users: User[] = [];

  refresh() {
    this.http.get<User[]>('/api/users').subscribe(data => {
      this.users = data;                               // ← New array reference
      // Without trackBy, ALL user-card components are destroyed and recreated
    });
  }
}


// ← WITH trackBy (optimized)
@Component({
  selector: 'app-user-list',
  template: `
    <!-- GOOD: trackBy tells Angular how to identify items across renders -->
    <div *ngFor="let user of users; trackBy: trackByUserId">
      <app-user-card [user]="user"></app-user-card>
    </div>
  `
})
export class UserListComponent {
  users: User[] = [];

  trackByUserId(index: number, user: User): number {   // ← Track by unique ID
    return user.id;                                    // ← Same id = same DOM element
  }

  refresh() {
    this.http.get<User[]>('/api/users').subscribe(data => {
      this.users = data;
      // With trackBy, only genuinely new/removed items cause DOM changes
    });
  }
}
```

### 13.8.2 Pure Pipes vs Methods in Templates

#### The Problem: Methods in Templates Run on EVERY Change Detection

```typescript
// ═══════════════════════════════════════════════════
// BAD: Method call in template
// ═══════════════════════════════════════════════════
@Component({
  selector: 'app-product-list',
  template: `
    <div *ngFor="let product of products">
      <!-- getDiscountedPrice() is called on EVERY change detection cycle -->
      <!-- For 100 products × 10 CD cycles = 1000 function calls! -->
      <p>{{ getDiscountedPrice(product) }}</p>          <!-- ← Called EVERY CD cycle -->
    </div>
  `
})
export class ProductListComponent {
  products: Product[] = [];

  getDiscountedPrice(product: Product): number {
    console.log('Calculating price for', product.name); // ← Watch your console explode
    // Even an expensive calculation runs every time
    return product.price * (1 - product.discount / 100);
  }
}


// ═══════════════════════════════════════════════════
// GOOD: Pure Pipe (cached by Angular)
// ═══════════════════════════════════════════════════
@Pipe({
  name: 'discountedPrice',
  pure: true                                           // ← DEFAULT, but explicit for clarity
})
export class DiscountedPricePipe implements PipeTransform {
  transform(product: Product): number {
    console.log('Pipe: calculating for', product.name); // ← Only runs when product reference changes!
    return product.price * (1 - product.discount / 100);
  }
}

@Component({
  selector: 'app-product-list',
  template: `
    <div *ngFor="let product of products; trackBy: trackById">
      <!-- Pure pipe only recalculates when the input REFERENCE changes -->
      <p>{{ product | discountedPrice }}</p>            <!-- ← Cached! Much faster -->
    </div>
  `
})
export class ProductListComponent {
  products: Product[] = [];
  trackById = (i: number, p: Product) => p.id;
}
```

```
METHOD vs PURE PIPE COMPARISON:
═══════════════════════════════

Template Method:
  CD Cycle 1: getPrice(product) → calculates → returns $45
  CD Cycle 2: getPrice(product) → calculates → returns $45  ← SAME INPUT, WASTED WORK
  CD Cycle 3: getPrice(product) → calculates → returns $45  ← SAME INPUT, WASTED WORK
  CD Cycle 4: getPrice(product) → calculates → returns $45  ← SAME INPUT, WASTED WORK
  CD Cycle 5: getPrice(product) → calculates → returns $42  ← input changed, needed calc
  Total calculations: 5 (4 wasted)

Pure Pipe:
  CD Cycle 1: pipe(product) → calculates → returns $45, CACHES result
  CD Cycle 2: pipe(product) → same ref? YES → returns cached $45     ← SKIPPED
  CD Cycle 3: pipe(product) → same ref? YES → returns cached $45     ← SKIPPED
  CD Cycle 4: pipe(product) → same ref? YES → returns cached $45     ← SKIPPED
  CD Cycle 5: pipe(newProduct) → new ref! → calculates → returns $42
  Total calculations: 2 (0 wasted)
```

### When to Use Pipe vs Method vs Computed Property

| Approach | When to Use | Performance |
|----------|-------------|-------------|
| Pure Pipe | Transforming data for display (formatting, filtering, calculations) | Best — cached by input reference |
| Getter/Property | Simple, cheap computations that rarely change | Good — evaluated each CD but fast |
| Method in template | NEVER for expensive operations | Worst — runs every CD cycle |
| Memoized function | Complex calculations with multiple inputs | Good — manual cache management |

### 13.8.3 Lazy Loading

#### The Problem: Loading Everything Upfront

```
WITHOUT LAZY LOADING:
═════════════════════

User visits homepage:

  Browser downloads:
  ┌─────────────────────────────────────────────┐
  │  main.js (2.5 MB)                           │
  │  ├── HomeModule code         (50 KB)  ← Needed now      │
  │  ├── ProductsModule code     (200 KB) ← NOT needed yet  │
  │  ├── AdminModule code        (500 KB) ← NOT needed yet  │
  │  ├── ReportsModule code      (300 KB) ← NOT needed yet  │
  │  ├── UserProfileModule code  (150 KB) ← NOT needed yet  │
  │  └── SettingsModule code     (100 KB) ← NOT needed yet  │
  └─────────────────────────────────────────────┘

  User waits for ALL 2.5 MB to download and parse!
  But they only needed 50 KB for the homepage!


WITH LAZY LOADING:
══════════════════

User visits homepage:

  Browser downloads:
  ┌─────────────────────────────────────┐
  │  main.js (100 KB)                   │
  │  └── HomeModule code (50 KB)        │  ← Only what's needed NOW
  └─────────────────────────────────────┘

  User navigates to /products:

  ┌─────────────────────────────────────┐
  │  products.chunk.js (200 KB)         │  ← Downloaded on demand
  └─────────────────────────────────────┘

  User navigates to /admin:

  ┌─────────────────────────────────────┐
  │  admin.chunk.js (500 KB)            │  ← Downloaded on demand
  └─────────────────────────────────────┘

  Initial load: 100 KB instead of 2.5 MB!
```

```typescript
// ← app-routing.module.ts — Lazy loading configuration
const routes: Routes = [
  {
    path: '',
    component: HomeComponent                           // ← Eagerly loaded (in main bundle)
  },
  {
    path: 'products',
    loadChildren: () =>                                // ← LAZY: loaded only when user navigates here
      import('./products/products.module')
        .then(m => m.ProductsModule)
  },
  {
    path: 'admin',
    loadChildren: () =>                                // ← LAZY: large admin module loaded on demand
      import('./admin/admin.module')
        .then(m => m.AdminModule)
  },
  {
    path: 'reports',
    loadComponent: () =>                               // ← LAZY: standalone component (Angular 14+)
      import('./reports/reports.component')
        .then(c => c.ReportsComponent)
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
```

```typescript
// ← Preloading strategy: load lazy modules in the background AFTER initial load
@NgModule({
  imports: [
    RouterModule.forRoot(routes, {
      preloadingStrategy: PreloadAllModules             // ← Start downloading lazy modules
      // after the initial page loads, in the background
      // User sees fast initial load AND fast navigation later
    })
  ]
})
export class AppRoutingModule {}
```

### 13.8.4 Virtual Scrolling with CDK

#### The Problem: Rendering Thousands of DOM Elements

```
WITHOUT VIRTUAL SCROLLING:
══════════════════════════

10,000 items in a list → 10,000 DOM elements created

  ┌───────────────────────────────────┐
  │ Visible viewport (10 items)       │  ← User can see these
  │ ┌─────────────────────────────┐   │
  │ │ Item 1                      │   │
  │ │ Item 2                      │   │
  │ │ ...                         │   │
  │ │ Item 10                     │   │
  │ └─────────────────────────────┘   │
  │                                   │
  │ Below viewport (9,990 items)      │  ← INVISIBLE but still in DOM!
  │ Item 11 through Item 10,000       │     Each one costs memory and slows
  │ ALL rendered as real DOM elements  │     down change detection
  └───────────────────────────────────┘

  DOM elements: 10,000
  Memory: ~50 MB
  CD time: ~500ms (checking 10,000 bindings)


WITH VIRTUAL SCROLLING:
═══════════════════════

10,000 items, but only ~15 DOM elements exist at any time

  ┌───────────────────────────────────┐
  │ Buffer (2 items above viewport)   │  ← Pre-rendered for smooth scrolling
  │ ┌─────────────────────────────┐   │
  │ │ Item 499                    │   │
  │ │ Item 500                    │   │
  │ └─────────────────────────────┘   │
  │ Visible viewport (10 items)       │
  │ ┌─────────────────────────────┐   │
  │ │ Item 501                    │   │
  │ │ Item 502                    │   │
  │ │ ...                         │   │
  │ │ Item 510                    │   │
  │ └─────────────────────────────┘   │
  │ Buffer (2 items below viewport)   │
  │ ┌─────────────────────────────┐   │
  │ │ Item 511                    │   │
  │ │ Item 512                    │   │
  │ └─────────────────────────────┘   │
  └───────────────────────────────────┘

  DOM elements: ~15 (not 10,000!)
  Memory: ~0.1 MB
  CD time: ~1ms
```

```typescript
// ← Step 1: Install Angular CDK (if not already)
// npm install @angular/cdk

// ← Step 2: Import ScrollingModule
import { ScrollingModule } from '@angular/cdk/scrolling';

@NgModule({
  imports: [ScrollingModule]                           // ← Add to your module
})
export class MyModule {}

// ← Step 3: Use cdk-virtual-scroll-viewport
@Component({
  selector: 'app-large-list',
  template: `
    <!-- itemSize = height of each item in pixels -->
    <cdk-virtual-scroll-viewport
      itemSize="50"
      class="viewport"
    >
      <!-- *cdkVirtualFor replaces *ngFor -->
      <div
        *cdkVirtualFor="let item of items; trackBy: trackById"
        class="item"
      >
        {{ item.name }} — {{ item.description }}
      </div>
    </cdk-virtual-scroll-viewport>
  `,
  styles: [`
    .viewport {
      height: 500px;                                   /* ← Fixed height required */
      width: 100%;
    }
    .item {
      height: 50px;                                    /* ← Must match itemSize */
      display: flex;
      align-items: center;
      border-bottom: 1px solid #eee;
      padding: 0 16px;
    }
  `]
})
export class LargeListComponent {
  items: Item[] = [];                                  // ← Can hold 100,000+ items

  constructor() {
    // Generate test data
    this.items = Array.from({ length: 100_000 }, (_, i) => ({
      id: i,
      name: `Item ${i}`,
      description: `Description for item ${i}`
    }));
  }

  trackById(index: number, item: Item): number {
    return item.id;
  }
}
```

### 13.8.5 Web Workers

#### The Problem: Heavy Computation Blocks the UI

JavaScript is single-threaded. If you run a heavy computation (sorting 1M records, parsing a CSV), the UI freezes because the main thread is busy.

```
WITHOUT WEB WORKER:
═══════════════════

  Main Thread:
  ──[UI]──[UI]──[HEAVY COMPUTATION........................]──[UI]──
                 ↑                                         ↑
           UI freezes here                           UI resumes
           (button clicks, scrolling — nothing works)


WITH WEB WORKER:
════════════════

  Main Thread:
  ──[UI]──[UI]──[Send to worker]──[UI]──[UI]──[UI]──[Receive result]──[UI]──
                       │                                    ↑
                       ▼                                    │
  Worker Thread:       [HEAVY COMPUTATION.................] │
                                                    Done!───┘
  UI stays responsive the entire time!
```

```typescript
// ← Step 1: Generate a web worker
// ng generate web-worker my-worker

// ← Step 2: my-worker.worker.ts
/// <reference lib="webworker" />

addEventListener('message', ({ data }) => {            // ← Listen for messages from main thread
  console.log('Worker received:', data);

  // Heavy computation that would freeze the UI
  const result = data.numbers
    .map((n: number) => fibonacci(n))                  // ← CPU-intensive work
    .sort((a: number, b: number) => a - b);

  postMessage(result);                                 // ← Send result back to main thread
});

function fibonacci(n: number): number {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);         // ← Intentionally slow for demo
}


// ← Step 3: Use the worker in a component
@Component({
  selector: 'app-heavy-calc',
  template: `
    <button (click)="calculate()">Start Heavy Calculation</button>
    <p>Status: {{ status }}</p>
    <p>Result: {{ result }}</p>
    <!-- UI stays responsive while worker computes! -->
    <button (click)="counter = counter + 1">
      Click counter: {{ counter }}                     <!-- ← This keeps working! -->
    </button>
  `
})
export class HeavyCalcComponent {
  status = 'Idle';
  result = '';
  counter = 0;
  private worker: Worker | undefined;

  calculate() {
    if (typeof Worker !== 'undefined') {               // ← Check browser support
      this.worker = new Worker(
        new URL('./my-worker.worker', import.meta.url) // ← Angular CLI handles bundling
      );

      this.worker.onmessage = ({ data }) => {          // ← Receive result
        this.status = 'Done!';
        this.result = JSON.stringify(data);
      };

      this.status = 'Calculating...';
      this.worker.postMessage({                        // ← Send data to worker
        numbers: [35, 36, 37, 38, 39, 40]
      });
    } else {
      // Web Workers not supported — fall back to main thread
      this.status = 'Workers not supported';
    }
  }

  ngOnDestroy() {
    this.worker?.terminate();                          // ← Clean up!
  }
}
```

### 13.8.6 NgOptimizedImage

#### The Problem: Images Are the #1 Performance Killer

Images account for ~50% of page weight on most websites. Unoptimized images cause slow loading, poor Core Web Vitals scores, and bad user experience.

```
UNOPTIMIZED IMAGE LOADING:
══════════════════════════

  Browser requests page
  │
  ├── Downloads 20 images simultaneously
  │   ├── hero-banner.jpg (5 MB, full resolution)     ← Way too large
  │   ├── thumbnail-1.jpg (2 MB, not lazy loaded)     ← Below the fold, wasted bandwidth
  │   ├── thumbnail-2.jpg (2 MB, no sizing)           ← Causes layout shift
  │   └── ... (17 more)
  │
  └── Result: 45 MB of images, 8 second load time, layout shifts everywhere


OPTIMIZED WITH NgOptimizedImage:
════════════════════════════════

  Browser requests page
  │
  ├── LCP image preloaded (priority)
  │   └── hero-banner.jpg (200 KB, resized, WebP)     ← Correct size for viewport
  │
  ├── Below-fold images lazy loaded
  │   ├── thumbnail-1.jpg (50 KB, loaded when visible) ← Loaded on demand
  │   ├── thumbnail-2.jpg (50 KB, width/height set)    ← No layout shift
  │   └── ... (loaded as user scrolls)
  │
  └── Result: 200 KB initial, sub-second LCP, no layout shifts
```

```typescript
// ← Step 1: Import NgOptimizedImage
import { NgOptimizedImage } from '@angular/common';

@Component({
  selector: 'app-product-page',
  standalone: true,
  imports: [NgOptimizedImage],                         // ← Import the directive
  template: `
    <!-- HERO IMAGE: Use 'priority' for the Largest Contentful Paint image -->
    <img
      ngSrc="assets/hero-banner.jpg"
      width="1200"
      height="600"
      priority
    />
    <!-- priority adds: fetchpriority="high" and preload link in <head> -->
    <!-- width/height prevent layout shift (CLS) -->

    <!-- BELOW-THE-FOLD IMAGES: Automatically lazy loaded -->
    <div *ngFor="let product of products">
      <img
        [ngSrc]="product.imageUrl"
        width="300"
        height="200"
        placeholder
      />
      <!-- Without 'priority', NgOptimizedImage adds loading="lazy" automatically -->
      <!-- 'placeholder' shows a blurred low-res version while loading -->
    </div>
  `
})
export class ProductPageComponent {
  products: Product[] = [];
}
```

#### NgOptimizedImage Features

| Feature | What It Does | HTML Generated |
|---------|-------------|----------------|
| `ngSrc` | Replaces `src`, enables all optimizations | `<img src="..." loading="lazy">` |
| `priority` | Marks as LCP image, disables lazy load, adds preload | `<img fetchpriority="high">` |
| `width` + `height` | Prevents layout shift (required) | `<img width="300" height="200">` |
| `placeholder` | Shows blurred placeholder while loading | Blurred base64 image |
| `fill` | Image fills its container (like `object-fit: cover`) | No width/height needed |
| `sizes` | Responsive image sizes for different viewports | `<img sizes="(max-width: 768px) 100vw, 50vw">` |
| Image loader | Integrates with CDNs (Cloudinary, Imgix, etc.) | Generates optimized URLs |

```typescript
// ← Configure an image loader for a CDN
import { provideCloudinaryLoader } from '@angular/common';

@NgModule({
  providers: [
    provideCloudinaryLoader('https://res.cloudinary.com/myapp')  // ← CDN base URL
  ]
})
export class AppModule {}

// Now ngSrc automatically generates optimized CDN URLs:
// <img ngSrc="products/shoe.jpg" width="300" height="200">
// Becomes: https://res.cloudinary.com/myapp/image/upload/w_300,h_200/products/shoe.jpg
```

---

## 13.9 Bundle Size Optimization

### Why Bundle Size Matters

```
BUNDLE SIZE IMPACT ON USER EXPERIENCE:
══════════════════════════════════════

Bundle Size    Parse Time (avg phone)    User Perception
─────────────  ───────────────────────   ──────────────────────
< 100 KB       < 0.5s                   Instant ✓
100-300 KB     0.5-1.5s                 Acceptable ✓
300-500 KB     1.5-3s                   Noticeable delay ⚠
500 KB-1 MB    3-6s                     Frustrating ✗
> 1 MB         6-12s+                   Users leave ✗✗

Every 100 KB of JavaScript:
  → ~0.5s additional parse time on mid-range phones
  → ~1% bounce rate increase on mobile
```

### Tree Shaking

Tree shaking is the process of removing unused code from your bundle. Angular CLI does this automatically in production builds, but you can accidentally break it.

```typescript
// ═══════════════════════════════════════════════════
// TREE-SHAKABLE (good)
// ═══════════════════════════════════════════════════

// ← Only imported functions are included in the bundle
import { map, filter } from 'rxjs/operators';          // ← Only map and filter imported

// ← providedIn: 'root' makes services tree-shakable
@Injectable({
  providedIn: 'root'                                   // ← If nobody injects this, it's removed!
})
export class AnalyticsService {}


// ═══════════════════════════════════════════════════
// NOT TREE-SHAKABLE (bad)
// ═══════════════════════════════════════════════════

// ← Barrel imports can prevent tree shaking
import * as _ from 'lodash';                           // ← Imports ENTIRE lodash (70 KB)!
// FIX: import debounce from 'lodash/debounce';       // ← Only debounce (3 KB)

// ← Providing in module prevents tree shaking
@NgModule({
  providers: [AnalyticsService]                        // ← Always included, even if unused
})
export class AppModule {}
```

### Analyzing Bundle Size with source-map-explorer

```bash
# Step 1: Build with source maps
ng build --source-map

# Step 2: Install source-map-explorer
npm install -g source-map-explorer

# Step 3: Analyze
source-map-explorer dist/my-app/main.*.js
```

```
WHAT SOURCE-MAP-EXPLORER SHOWS:
═══════════════════════════════

┌──────────────────────────────────────────────────────┐
│                    main.js (450 KB)                   │
│                                                      │
│ ┌──────────────────┐  ┌──────────────┐ ┌──────────┐ │
│ │  @angular/core   │  │   rxjs       │ │  lodash  │ │
│ │  (120 KB)        │  │   (80 KB)    │ │ (70 KB!) │ │
│ │                  │  │              │ │ ← WHY?!  │ │
│ └──────────────────┘  └──────────────┘ └──────────┘ │
│ ┌──────────┐ ┌────────┐ ┌──────────────────────────┐│
│ │ app code │ │ moment │ │  chart.js (60 KB)        ││
│ │ (50 KB)  │ │(50 KB!)│ │  ← only used on 1 page  ││
│ └──────────┘ └────────┘ └──────────────────────────┘│
└──────────────────────────────────────────────────────┘

Insights:
  1. lodash is 70 KB — replace with individual imports or native JS
  2. moment.js is 50 KB — replace with date-fns or dayjs (2 KB)
  3. chart.js is 60 KB — lazy load it (only used on reports page)
```

### Angular Budgets

Angular CLI has built-in budget warnings. Configure them in `angular.json`:

```json
{
  "budgets": [
    {
      "type": "initial",
      "maximumWarning": "500kb",
      "maximumError": "1mb"
    },
    {
      "type": "anyComponentStyle",
      "maximumWarning": "2kb",
      "maximumError": "4kb"
    }
  ]
}
```

```
BUDGET TYPES:
═════════════

┌─────────────────────────┬────────────────────────────────────────────────┐
│ Budget Type             │ What It Measures                               │
├─────────────────────────┼────────────────────────────────────────────────┤
│ initial                 │ Total size of JS loaded on initial page load   │
│ allScript               │ Total of ALL JavaScript files                  │
│ all                     │ Total of ALL files (JS + CSS + assets)         │
│ anyComponentStyle       │ Size of any single component's styles          │
│ anyScript               │ Size of any single JavaScript file             │
│ any                     │ Size of any single file                        │
│ bundle                  │ Size of a specific named bundle                │
└─────────────────────────┴────────────────────────────────────────────────┘

When a budget is exceeded:
  - maximumWarning → Yellow warning in build output (build succeeds)
  - maximumError → Red error (build FAILS — cannot deploy)
```

### Bundle Size Reduction Checklist

```
BUNDLE SIZE OPTIMIZATION CHECKLIST:
═══════════════════════════════════

□ Lazy load feature modules (Section 13.8.3)
□ Replace moment.js with date-fns or dayjs
□ Import lodash functions individually, not the whole library
□ Use providedIn: 'root' for services (tree-shakable)
□ Remove unused imports (IDE can help)
□ Enable production mode: ng build --configuration production
□ Use Angular budgets to catch regressions
□ Analyze bundle with source-map-explorer regularly
□ Consider replacing large libraries with smaller alternatives:

  ┌────────────────────┬─────────┬──────────────────────┬─────────┐
  │ Heavy Library      │ Size    │ Lightweight Alt      │ Size    │
  ├────────────────────┼─────────┼──────────────────────┼─────────┤
  │ moment.js          │ 72 KB   │ date-fns             │ 7 KB    │
  │ lodash (full)      │ 70 KB   │ lodash-es (tree)     │ ~5 KB   │
  │ jQuery             │ 87 KB   │ Remove entirely      │ 0 KB    │
  │ rxjs (full)        │ 52 KB   │ Import operators only│ ~10 KB  │
  │ chart.js           │ 60 KB   │ Lazy load it         │ 0 KB*   │
  └────────────────────┴─────────┴──────────────────────┴─────────┘
                                              * 0 KB in initial bundle
```

---

## 13.10 Zoneless Angular (Experimental)

### The Problem with Zone.js

Zone.js has served Angular well, but it has drawbacks:

| Problem | Impact |
|---------|--------|
| Bundle size | Zone.js adds ~13 KB (gzipped) to every Angular app |
| Monkey-patching | Modifies 200+ browser APIs, can conflict with third-party code |
| Debugging | Stack traces become harder to read due to zone frames |
| Over-triggering | ANY async operation triggers CD, even if no UI data changed |
| SSR complications | Server-side rendering becomes more complex |

### Zoneless Change Detection (Angular 16+)

Angular is moving towards a "zoneless" future where you explicitly tell Angular when data changes, using **Signals**.

```typescript
// ← bootstrapping with zoneless change detection
import {
  bootstrapApplication,
  provideExperimentalZonelessChangeDetection  // ← Experimental API (Angular 18+)
} from '@angular/core';

bootstrapApplication(AppComponent, {
  providers: [
    provideExperimentalZonelessChangeDetection()       // ← No Zone.js needed!
  ]
});

// ← Also remove zone.js from polyfills in angular.json:
// "polyfills": []   ← Remove "zone.js" from this array
```

```typescript
// ← Zoneless component using Signals
import { Component, signal, computed } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <h2>Count: {{ count() }}</h2>                      <!-- ← Signal read in template -->
    <p>Double: {{ doubled() }}</p>                     <!-- ← Computed signal -->
    <button (click)="increment()">+1</button>
    <button (click)="decrement()">-1</button>
  `
})
export class CounterComponent {
  count = signal(0);                                   // ← Signal replaces plain property
  doubled = computed(() => this.count() * 2);          // ← Computed signal auto-updates

  increment() {
    this.count.update(c => c + 1);                     // ← Signal update triggers CD
    // No Zone.js needed! Angular knows count changed
    // because Signals notify their consumers directly
  }

  decrement() {
    this.count.update(c => c - 1);
  }
}
```

```
HOW ZONELESS CHANGE DETECTION WORKS:
═════════════════════════════════════

WITH ZONE.JS (traditional):
  Event → Zone.js intercepts → Triggers CD on ALL components → DOM updates

  ┌────────┐    ┌──────────┐    ┌─────────────────┐    ┌─────────┐
  │ Click  │ →  │ Zone.js  │ →  │ Check ALL comps │ →  │ Update  │
  │ event  │    │ catches  │    │ top to bottom   │    │ DOM     │
  └────────┘    └──────────┘    └─────────────────┘    └─────────┘


WITHOUT ZONE.JS (Signals):
  Signal.set() → Angular notified directly → Only affected components checked

  ┌────────┐    ┌──────────────┐    ┌──────────────────┐    ┌─────────┐
  │ Click  │ →  │ signal.set() │ →  │ Check ONLY comps │ →  │ Update  │
  │ event  │    │ notifies     │    │ using this signal│    │ DOM     │
  └────────┘    └──────────────┘    └──────────────────┘    └─────────┘

  Result: Fewer components checked, no monkey-patching overhead!
```

### Signals Quick Reference

```typescript
// ═══════════════════════════════════════════════════
// WRITABLE SIGNAL — holds a value you can change
// ═══════════════════════════════════════════════════
const name = signal('Alice');                          // ← Create with initial value
console.log(name());                                   // ← Read: call it as a function → 'Alice'
name.set('Bob');                                       // ← Set: replace the value entirely
name.update(current => current + '!');                 // ← Update: transform based on current value


// ═══════════════════════════════════════════════════
// COMPUTED SIGNAL — derived from other signals
// ═══════════════════════════════════════════════════
const firstName = signal('Alice');
const lastName = signal('Smith');
const fullName = computed(                             // ← Automatically recalculates
  () => `${firstName()} ${lastName()}`                 // ← when firstName or lastName change
);
// fullName() → 'Alice Smith'
// firstName.set('Bob');
// fullName() → 'Bob Smith' (auto-updated!)


// ═══════════════════════════════════════════════════
// EFFECT — side effects when signals change
// ═══════════════════════════════════════════════════
effect(() => {
  console.log(`Name changed to: ${name()}`);           // ← Runs whenever name changes
  // Use for logging, analytics, localStorage, etc.
});
```

### Should You Go Zoneless Today?

```
DECISION GUIDE: ZONELESS ANGULAR
═════════════════════════════════

Is your project brand new (greenfield)?
  │
  ├── YES: Are you comfortable with experimental APIs?
  │   │
  │   ├── YES → Consider zoneless + Signals ✓
  │   │         (Prepare for API changes)
  │   │
  │   └── NO → Use Zone.js + OnPush + Signals gradually
  │
  └── NO (existing project): Is it large with performance issues?
      │
      ├── YES → Migrate to OnPush first, then adopt Signals incrementally
      │         Zoneless migration is NOT trivial for existing apps
      │
      └── NO → Stay with Zone.js. Focus on OnPush + trackBy + pipes
              These give 90% of the performance benefit with 10% of the effort
```

---

## 13.11 Angular DevTools

### What Are Angular DevTools?

Angular DevTools is a browser extension (Chrome/Edge) that lets you inspect and debug Angular-specific features including change detection.

```
ANGULAR DEVTOOLS FEATURES:
══════════════════════════

┌──────────────────────────────────────────────────────────────┐
│  Angular DevTools Browser Extension                          │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  Component Explorer Tab                             │     │
│  │                                                     │     │
│  │  Component Tree:         Component Details:         │     │
│  │  ▼ AppComponent          @Input() user: {...}       │     │
│  │    ▼ HeaderComponent     @Output() search           │     │
│  │      NavComponent        State:                     │     │
│  │    ▼ MainComponent         isOpen: true             │     │
│  │      SidebarComponent      items: [...]             │     │
│  │      ▼ ContentComponent  Change Detection:          │     │
│  │        CardComponent       Strategy: OnPush         │     │
│  │        TableComponent                               │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐     │
│  │  Profiler Tab                                       │     │
│  │                                                     │     │
│  │  Change Detection Cycles:                           │     │
│  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                  │     │
│  │  │ 2ms │ │ 5ms │ │ 1ms │ │15ms │ ← slow!          │     │
│  │  └─────┘ └─────┘ └─────┘ └─────┘                   │     │
│  │                                                     │     │
│  │  Cycle 4 breakdown:                                 │     │
│  │  AppComponent        0.1ms                          │     │
│  │  HeaderComponent     0.1ms                          │     │
│  │  DataTableComponent  14ms ← BOTTLENECK!             │     │
│  │  FooterComponent     0.1ms                          │     │
│  └─────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

### Using the Profiler

```
HOW TO PROFILE CHANGE DETECTION:
═════════════════════════════════

1. Open Angular DevTools → Profiler tab
2. Click "Record" (red circle)
3. Interact with your app (click buttons, navigate, scroll)
4. Click "Stop Recording"
5. Analyze the flame chart:

  ┌─────────────────────────────────────────────────────┐
  │  Flame Chart:                                       │
  │                                                     │
  │  ████████████████████████████████████  AppComponent  │
  │  ███████████        ████████████████  Header  Main  │
  │  ██████                 ████████████  Nav     Content│
  │                         ████████████  DataTable      │
  │                         ████████████  ← 14ms here!  │
  │                                                     │
  │  Wider bars = more time spent in that component     │
  │  Tall stacks = deep component trees                 │
  └─────────────────────────────────────────────────────┘

WHAT TO LOOK FOR:
  → Components that take > 5ms (they need optimization)
  → Components that check frequently but rarely change (add OnPush)
  → Deep trees with many checked components (add OnPush at top)
  → Many CD cycles from mousemove/scroll (use runOutsideAngular)
```

### Setting Up Angular DevTools

```
INSTALLATION:
═════════════

1. Chrome Web Store → Search "Angular DevTools" → Install
2. Open your Angular app in Chrome
3. Open Chrome DevTools (F12)
4. Look for the "Angular" tab

NOTE: Angular DevTools only works with:
  ✓ Angular 12+ applications
  ✓ Development mode (ng serve)
  ✗ Does NOT work with production builds (by design)
  ✗ Does NOT work with AngularJS (1.x)
```

### Debugging Change Detection with console.log

When DevTools isn't enough, strategic logging can reveal CD patterns:

```typescript
@Component({
  selector: 'app-debug-cd',
  template: `<p>{{ getData() }}</p>`
})
export class DebugCDComponent {
  private cdCount = 0;

  getData(): string {
    this.cdCount++;
    console.log(                                       // ← See how often CD runs
      `%c[DebugCD] Check #${this.cdCount}`,
      'color: orange; font-weight: bold'               // ← Styled console output for visibility
    );
    return 'Some data';
  }

  // In production, you'd NEVER have a method in the template
  // This is ONLY for debugging CD frequency
}
```

---

## 13.12 Practical Example — Optimizing a Slow Dashboard

### The Scenario

You've been asked to fix a dashboard that feels sluggish. It has:
- A header with user info
- A sidebar with navigation
- A stats panel with 4 KPI cards
- A data table with 500 rows
- A real-time notification feed (WebSocket)
- A chart that updates every 5 seconds

### Step 1: The SLOW Version (Before Optimization)

```typescript
// ═══════════════════════════════════════════════════
// SLOW DASHBOARD — Everything wrong
// ═══════════════════════════════════════════════════

// dashboard.component.ts — The problematic parent
@Component({
  selector: 'app-dashboard',
  template: `
    <app-header [user]="currentUser"></app-header>
    <app-sidebar [menuItems]="menuItems"></app-sidebar>

    <div class="main-content">
      <app-stats-panel [stats]="stats"></app-stats-panel>

      <!-- BAD: No trackBy on 500 rows -->
      <table>
        <tr *ngFor="let row of tableData">
          <!-- BAD: Method call in template — runs 500× per CD cycle -->
          <td>{{ formatDate(row.date) }}</td>
          <td>{{ row.name }}</td>
          <!-- BAD: Another method call — runs 500× per CD cycle -->
          <td>{{ calculateTotal(row) }}</td>
          <!-- BAD: Filtering in template — runs 500× per CD cycle -->
          <td>{{ getStatusLabel(row.status) }}</td>
        </tr>
      </table>

      <app-notification-feed></app-notification-feed>
      <app-chart [data]="chartData"></app-chart>
    </div>
  `
})
export class DashboardComponent implements OnInit {
  currentUser: User | null = null;
  menuItems: MenuItem[] = [];
  stats: Stats = {} as Stats;
  tableData: any[] = [];
  chartData: any[] = [];

  constructor(
    private dashService: DashboardService,
    private wsService: WebSocketService
  ) {}

  ngOnInit() {
    this.dashService.getUser().subscribe(u => this.currentUser = u);
    this.dashService.getMenu().subscribe(m => this.menuItems = m);
    this.dashService.getStats().subscribe(s => this.stats = s);
    this.dashService.getTableData().subscribe(d => this.tableData = d);

    // BAD: Every WS message triggers change detection on ALL components
    this.wsService.messages$.subscribe(msg => {
      this.notifications.push(msg);                    // ← Mutation! And triggers full CD
    });

    // BAD: Chart data refresh triggers full CD every 5 seconds
    setInterval(() => {
      this.dashService.getChartData().subscribe(d => {
        this.chartData = d;
      });
    }, 5000);
  }

  // BAD: These methods run on EVERY change detection cycle × 500 rows
  formatDate(date: string): string {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });                                                // ← Called 500 times per CD cycle!
  }

  calculateTotal(row: any): number {
    return row.items.reduce(                           // ← Array reduction 500 times per CD cycle!
      (sum: number, item: any) => sum + item.price * item.quantity, 0
    );
  }

  getStatusLabel(status: string): string {
    const labels: Record<string, string> = {           // ← Object creation 500 times per CD cycle!
      active: 'Active',
      inactive: 'Inactive',
      pending: 'Pending Review'
    };
    return labels[status] || 'Unknown';
  }

  notifications: any[] = [];
}
```

```
PERFORMANCE PROBLEM ANALYSIS:
═════════════════════════════

Every time ANY event happens (click, WS message, interval tick):

  Change Detection runs on ALL components:
  ┌─────────────────────────────────────────────────────────────┐
  │  DashboardComponent                                         │
  │  ├── HeaderComponent        (5 expressions checked)         │
  │  ├── SidebarComponent       (12 expressions checked)        │
  │  ├── StatsPanelComponent    (20 expressions checked)        │
  │  ├── 500 × table rows       (2000 expressions checked!)     │
  │  │   ├── formatDate()       × 500 = 500 function calls      │
  │  │   ├── calculateTotal()   × 500 = 500 function calls      │
  │  │   └── getStatusLabel()   × 500 = 500 function calls      │
  │  ├── NotificationFeed       (30 expressions checked)        │
  │  └── ChartComponent         (50 expressions checked)        │
  └─────────────────────────────────────────────────────────────┘

  Total per CD cycle: ~2117 expressions + 1500 function calls
  WebSocket: ~10 messages/sec = 10 CD cycles/sec
  setInterval: 1 CD cycle every 5 sec
  User interactions: ~2-5 CD cycles/sec

  Result: ~15 CD cycles/sec × 1500 function calls = 22,500 calls/sec!
  The browser is struggling!
```

### Step 2: The FAST Version (After Optimization)

```typescript
// ═══════════════════════════════════════════════════
// OPTIMIZED DASHBOARD — Every technique applied
// ═══════════════════════════════════════════════════

// ── STEP 1: Create Pure Pipes for template calculations ──

// format-date.pipe.ts
@Pipe({
  name: 'formatDate',
  pure: true                                           // ← Pure = cached by input reference
})
export class FormatDatePipe implements PipeTransform {
  transform(date: string): string {
    return new Date(date).toLocaleDateString('en-US', {
      year: 'numeric', month: 'short', day: 'numeric'
    });
    // ← Only recalculates when 'date' string reference changes
    // ← For 500 rows with same dates: calculated once, cached!
  }
}

// calculate-total.pipe.ts
@Pipe({
  name: 'calculateTotal',
  pure: true
})
export class CalculateTotalPipe implements PipeTransform {
  transform(row: any): number {
    return row.items.reduce(
      (sum: number, item: any) => sum + item.price * item.quantity, 0
    );
    // ← Only recalculates when row REFERENCE changes (OnPush + immutable)
  }
}

// status-label.pipe.ts
@Pipe({
  name: 'statusLabel',
  pure: true
})
export class StatusLabelPipe implements PipeTransform {
  private labels: Record<string, string> = {           // ← Created ONCE, not per call
    active: 'Active',
    inactive: 'Inactive',
    pending: 'Pending Review'
  };

  transform(status: string): string {
    return this.labels[status] || 'Unknown';
  }
}


// ── STEP 2: Optimize the Dashboard Component ──

// dashboard.component.ts
@Component({
  selector: 'app-dashboard',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush on the container!
  template: `
    <!-- OnPush child — only re-renders when user reference changes -->
    <app-header [user]="currentUser$ | async"></app-header>

    <!-- OnPush child — menuItems rarely change -->
    <app-sidebar [menuItems]="menuItems$ | async"></app-sidebar>

    <div class="main-content">
      <!-- OnPush child — stats update periodically -->
      <app-stats-panel [stats]="stats$ | async"></app-stats-panel>

      <!-- Optimized table — see data-table component below -->
      <app-data-table [rows]="tableData$ | async"></app-data-table>

      <!-- Notification feed handles its own updates -->
      <app-notification-feed></app-notification-feed>

      <!-- Chart with OnPush — only updates when new data arrives -->
      <app-chart [data]="chartData$ | async"></app-chart>
    </div>
  `
})
export class DashboardComponent {
  // ← ALL data flows through Observables — works perfectly with OnPush + async pipe
  currentUser$ = this.dashService.getUser();
  menuItems$ = this.dashService.getMenu();
  stats$ = this.dashService.getStats();
  tableData$ = this.dashService.getTableData();

  chartData$ = interval(5000).pipe(                    // ← RxJS interval instead of setInterval
    switchMap(() => this.dashService.getChartData()),   // ← Auto-cancels previous request
    startWith(null)                                    // ← Show loading state initially
  );

  constructor(private dashService: DashboardService) {}
  // ← No manual subscriptions! No memory leaks! async pipe handles everything
}


// ── STEP 3: Optimize the Data Table Component ──

// data-table.component.ts
@Component({
  selector: 'app-data-table',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush
  template: `
    <!-- Virtual scrolling for 500+ rows -->
    <cdk-virtual-scroll-viewport itemSize="48" class="table-viewport">
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Name</th>
            <th>Total</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <!-- cdkVirtualFor + trackBy = minimal DOM operations -->
          <tr *cdkVirtualFor="let row of rows; trackBy: trackByRowId">
            <!-- Pure pipes instead of method calls -->
            <td>{{ row.date | formatDate }}</td>
            <td>{{ row.name }}</td>
            <td>{{ row | calculateTotal | currency }}</td>
            <td>{{ row.status | statusLabel }}</td>
          </tr>
        </tbody>
      </table>
    </cdk-virtual-scroll-viewport>
  `,
  styles: [`
    .table-viewport {
      height: 600px;                                   /* ← Fixed height for virtual scrolling */
    }
    tr {
      height: 48px;                                    /* ← Matches itemSize */
    }
  `]
})
export class DataTableComponent {
  @Input() rows: any[] = [];

  trackByRowId(index: number, row: any): number {
    return row.id;                                     // ← Track by unique ID
  }
}


// ── STEP 4: Optimize the Notification Feed ──

// notification-feed.component.ts
@Component({
  selector: 'app-notification-feed',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush
  template: `
    <div class="notifications">
      <div
        *ngFor="let notif of notifications$ | async; trackBy: trackByNotifId"
        class="notification"
      >
        {{ notif.message }} — {{ notif.timestamp | formatDate }}
      </div>
    </div>
  `
})
export class NotificationFeedComponent {
  notifications$: Observable<Notification[]>;

  constructor(
    private wsService: WebSocketService,
    private ngZone: NgZone
  ) {
    // ← Receive WebSocket messages OUTSIDE Angular's zone
    this.notifications$ = new Observable<Notification[]>(subscriber => {
      const notifications: Notification[] = [];
      const buffer: Notification[] = [];

      this.ngZone.runOutsideAngular(() => {            // ← No CD per message
        this.wsService.messages$.subscribe(msg => {
          buffer.push(msg);                            // ← Buffer messages
        });

        // ← Flush buffer every 500ms (2 CD cycles/sec instead of 10+)
        setInterval(() => {
          if (buffer.length > 0) {
            notifications.push(...buffer);
            buffer.length = 0;
            this.ngZone.run(() => {                    // ← Re-enter zone to update UI
              subscriber.next([...notifications]);     // ← New array ref for OnPush
            });
          }
        }, 500);
      });
    });
  }

  trackByNotifId(index: number, notif: Notification): string {
    return notif.id;
  }
}


// ── STEP 5: OnPush on ALL child components ──

// header.component.ts
@Component({
  selector: 'app-header',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush
  template: `
    <header>
      <h1>Dashboard</h1>
      <span *ngIf="user">{{ user.name }}</span>
    </header>
  `
})
export class HeaderComponent {
  @Input() user: User | null = null;                   // ← Only re-renders on new user ref
}

// sidebar.component.ts
@Component({
  selector: 'app-sidebar',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush
  template: `
    <nav>
      <a *ngFor="let item of menuItems; trackBy: trackByPath"
         [routerLink]="item.path">
        {{ item.label }}
      </a>
    </nav>
  `
})
export class SidebarComponent {
  @Input() menuItems: MenuItem[] = [];
  trackByPath = (i: number, item: MenuItem) => item.path;
}

// stats-panel.component.ts
@Component({
  selector: 'app-stats-panel',
  changeDetection: ChangeDetectionStrategy.OnPush,     // ← OnPush
  template: `
    <div class="stats" *ngIf="stats">
      <app-kpi-card
        *ngFor="let kpi of stats.kpis; trackBy: trackByLabel"
        [kpi]="kpi"
      ></app-kpi-card>
    </div>
  `
})
export class StatsPanelComponent {
  @Input() stats: Stats | null = null;
  trackByLabel = (i: number, kpi: KPI) => kpi.label;
}
```

### Performance Comparison: Before vs After

```
BEFORE OPTIMIZATION:
════════════════════

  CD Frequency:     ~15 cycles/sec (WebSocket + interval + user events)
  Components checked: ALL (10 components every cycle)
  Template expressions evaluated: ~2117 per cycle
  Function calls per cycle: 1500 (3 methods × 500 rows)
  DOM elements for table: 500 rows × 4 cells = 2000 elements

  Total work per second:
  15 × (2117 expressions + 1500 function calls) = 54,255 operations/sec

  Result: Jank, dropped frames, sluggish UI


AFTER OPTIMIZATION:
═══════════════════

  CD Frequency:     ~2-3 cycles/sec (buffered WS + RxJS interval)
  Components checked: Only those with new @Input references (OnPush)
  Template expressions evaluated: ~20-50 per cycle (only changed components)
  Function calls per cycle: 0 (all replaced with pure pipes)
  DOM elements for table: ~15 rows (virtual scrolling)

  Total work per second:
  3 × 50 expressions = 150 operations/sec

  Result: Smooth 60fps, instant interactions


IMPROVEMENT:
════════════

  ┌────────────────────────┬──────────┬──────────┬──────────────┐
  │ Metric                 │ Before   │ After    │ Improvement  │
  ├────────────────────────┼──────────┼──────────┼──────────────┤
  │ CD cycles/sec          │ 15       │ 3        │ 5x fewer     │
  │ Components checked/CD  │ 10       │ 1-3      │ 3-10x fewer  │
  │ Function calls/CD      │ 1500     │ 0        │ Eliminated!  │
  │ DOM elements (table)   │ 2000     │ 60       │ 33x fewer    │
  │ Operations/sec         │ 54,255   │ 150      │ 361x fewer   │
  │ Frame rate             │ ~20 fps  │ 60 fps   │ 3x better    │
  └────────────────────────┴──────────┴──────────┴──────────────┘
```

### Optimization Techniques Applied (Summary)

```
TECHNIQUE                          WHERE APPLIED                 IMPACT
─────────────────────────────────  ────────────────────────────  ──────────────
OnPush on all components           Every component               Skips unchanged subtrees
Async pipe for all data            Dashboard template            Auto markForCheck + unsubscribe
Pure pipes instead of methods      Data table cells              Cached calculations
Virtual scrolling (CDK)            Data table (500 rows)         15 DOM elements vs 2000
trackBy on all *ngFor              Every list                    Reuses DOM elements
runOutsideAngular for WebSocket    Notification feed             No CD per WS message
Buffered updates (500ms)           Notification feed             2 updates/sec vs 10+
RxJS interval + switchMap          Chart data refresh            Auto-cancel, no memory leak
Observable streams (not imperative) All data flows               Clean, OnPush-compatible
```

---

## 13.13 Summary

### Change Detection at a Glance

```
CHANGE DETECTION MENTAL MODEL:
══════════════════════════════

  ┌─────────────────────────────────────────────────────────────────────┐
  │                                                                     │
  │  EVENT (click, HTTP, timer, WebSocket)                             │
  │    │                                                               │
  │    ▼                                                               │
  │  ZONE.JS intercepts the event                                     │
  │    │                                                               │
  │    ▼                                                               │
  │  ANGULAR CHANGE DETECTION starts                                   │
  │    │                                                               │
  │    ├── DEFAULT strategy: Check ALL components (top-down)           │
  │    │                                                               │
  │    └── ONPUSH strategy: Check ONLY components where:               │
  │        ├── @Input reference changed                                │
  │        ├── Template event fired                                    │
  │        ├── Async pipe emitted                                      │
  │        └── markForCheck() / detectChanges() called                 │
  │    │                                                               │
  │    ▼                                                               │
  │  DOM UPDATES where values differ                                   │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘
```

### Complete Decision Guide

```
PERFORMANCE OPTIMIZATION DECISION TREE:
═══════════════════════════════════════

Is the app slow?
│
├── Profile first! Use Angular DevTools Profiler.
│   Don't optimize blindly.
│
├── Which components are slow?
│   │
│   ├── They check too often → Add OnPush + use async pipe
│   │
│   ├── They have expensive template expressions → Replace with pure pipes
│   │
│   ├── They render too many DOM elements → Use virtual scrolling (CDK)
│   │
│   └── They re-create DOM elements unnecessarily → Add trackBy to *ngFor
│
├── Is the bundle too large?
│   │
│   ├── YES → Lazy load feature modules
│   ├── YES → Analyze with source-map-explorer
│   ├── YES → Replace heavy libraries
│   └── YES → Set Angular budgets
│
├── Do async events trigger too much CD?
│   │
│   ├── WebSocket messages → runOutsideAngular + buffer
│   ├── mousemove/scroll → runOutsideAngular
│   ├── setInterval → RxJS interval + switchMap
│   └── Multiple HTTP calls → Combine with forkJoin
│
└── Looking to the future?
    │
    ├── Learn Signals (Angular 16+)
    ├── Experiment with zoneless change detection
    └── Use standalone components with lazy loading
```

### Key Takeaways

| Concept | One-Line Summary |
|---------|-----------------|
| Change Detection | How Angular keeps the DOM in sync with component state |
| Zone.js | Monkey-patches async APIs to auto-trigger change detection |
| Default Strategy | Checks every component on every event — simple but wasteful |
| OnPush Strategy | Only checks when @Input ref changes, template event fires, or async pipe emits |
| ChangeDetectorRef | Manual control: `detectChanges()`, `markForCheck()`, `detach()`, `reattach()` |
| Immutability | Create new references instead of mutating — required for OnPush |
| trackBy | Tells `*ngFor` how to identify items — prevents unnecessary DOM recreation |
| Pure Pipes | Cached template transformations — replace method calls in templates |
| Virtual Scrolling | Only renders visible items — essential for large lists |
| Lazy Loading | Load code on demand — smaller initial bundle |
| NgOptimizedImage | Automatic image optimization — lazy loading, sizing, CDN support |
| Bundle Budgets | Catch bundle size regressions at build time |
| Zoneless | The future — Signals replace Zone.js for precise change detection |
| Angular DevTools | Profile and debug change detection visually |

### Performance Optimization Priority Order

```
START HERE (biggest impact, least effort):
══════════════════════════════════════════

  1. ★★★★★  OnPush on presentation/leaf components
  2. ★★★★★  Replace template methods with pure pipes
  3. ★★★★☆  trackBy on ALL *ngFor directives
  4. ★★★★☆  Lazy load feature modules/routes
  5. ★★★☆☆  Virtual scrolling for lists with 100+ items
  6. ★★★☆☆  runOutsideAngular for frequent events (mouse, WS)
  7. ★★☆☆☆  NgOptimizedImage for image-heavy pages
  8. ★★☆☆☆  Bundle analysis + budget enforcement
  9. ★☆☆☆☆  Web Workers for CPU-intensive calculations
  10. ★☆☆☆☆  Zoneless + Signals (future — experimental today)
```

---

> **Next Phase:** [Phase 14: Testing](Phase14-Testing.md)
