# Phase 4: Component Communication — How Components Talk to Each Other

> This phase covers how Angular components talk to each other. In any real application, components do NOT exist in isolation. A header needs to know the logged-in user. A product list needs to tell the cart that an item was added. A sidebar needs to react when the main content changes. Component communication is the GLUE that holds your application together. Master these patterns and you will be able to architect any Angular application confidently.

---

## Why Component Communication Matters

Angular apps are **trees of components**. Data must flow through this tree.

```
AppComponent
├── HeaderComponent          ← Needs to show the user's name
│   └── SearchBarComponent   ← Needs to send search queries upward
├── SidebarComponent         ← Needs to highlight the active page
├── ProductListComponent     ← Needs to show products AND tell cart about additions
│   └── ProductCardComponent ← Needs product data from parent, emits "add to cart"
└── CartComponent            ← Needs to know what was added (from a SIBLING!)
```

**The core question:** How does `ProductCardComponent` get product data? How does it tell `CartComponent` that something was added? These components have DIFFERENT relationships:

| Relationship | Example | Communication Method |
|---|---|---|
| **Parent to Child** | `ProductList` passes product to `ProductCard` | `@Input()` |
| **Child to Parent** | `ProductCard` tells `ProductList` item was clicked | `@Output()` + `EventEmitter` |
| **Parent accesses Child** | `ProductList` calls a method on `ProductCard` | `@ViewChild` |
| **Projected Content** | A card wrapper component with customizable slots | `ng-content` + `@ContentChild` |
| **Unrelated / Siblings** | `ProductCard` tells `Cart` item was added | Shared Service with `Subject` |

Let us explore each one in depth.

---

## 4.1 Parent to Child Communication with `@Input()`

### What is `@Input()`?

`@Input()` is a decorator that marks a property in a **child** component as receivable from a **parent** component. It creates a one-way data channel: data flows DOWN from parent to child, just like passing arguments to a function.

**Why does it exist?** Without `@Input()`, every component would be an island with no way to receive data from the outside. You would have to duplicate data everywhere. `@Input()` lets you create **reusable, configurable components** that display different data depending on what the parent gives them.

**When to use it:**
- Whenever a parent component needs to pass data to a child
- When building reusable components that should work with different data
- Whenever you want a child to REACT to data changes from above

---

### How the Flow Works — Step by Step

```
1. PARENT defines data in its class          →  product = { name: 'Laptop', price: 999 };
2. PARENT binds data in its template         →  <app-child [product]="product">
3. CHILD declares @Input() in its class      →  @Input() product!: Product;
4. CHILD uses the data in its template       →  {{ product.name }}
5. Angular keeps them in sync                →  If parent changes product, child updates automatically
```

Think of it this way: the parent is a MANAGER giving instructions, and the child is a WORKER receiving those instructions. The worker cannot change the manager's instructions — data flows in ONE direction.

---

### Full Code Example — Passing Different Types

**Step 1: Create the child component**

```typescript
// child.component.ts
import { Component, Input } from '@angular/core';

// Define an interface for type safety
interface User {
  id: number;
  name: string;
  email: string;
  isActive: boolean;
}

@Component({
  selector: 'app-user-card',
  templateUrl: './user-card.component.html',
  styleUrls: ['./user-card.component.css']
})
export class UserCardComponent {

  // --- Receiving a STRING ---
  @Input() title: string = '';           // Default empty string

  // --- Receiving a NUMBER ---
  @Input() userId: number = 0;

  // --- Receiving a BOOLEAN ---
  @Input() showDetails: boolean = false;

  // --- Receiving an OBJECT ---
  @Input() user!: User;                  // The ! tells TypeScript "I know this will be set"

  // --- Receiving an ARRAY ---
  @Input() skills: string[] = [];

  // The child can USE these values but should NOT modify objects/arrays
  // passed via @Input — that would cause confusing side effects.
}
```

```html
<!-- user-card.component.html -->
<div class="user-card">
  <!-- Using the string input -->
  <h3>{{ title }}</h3>

  <!-- Using the number input -->
  <p class="user-id">User #{{ userId }}</p>

  <!-- Using the object input -->
  <div *ngIf="user">
    <p><strong>Name:</strong> {{ user.name }}</p>
    <p><strong>Email:</strong> {{ user.email }}</p>
    <span [class.active]="user.isActive"
          [class.inactive]="!user.isActive">
      {{ user.isActive ? 'Active' : 'Inactive' }}
    </span>
  </div>

  <!-- Using the boolean input to conditionally show content -->
  <div *ngIf="showDetails">
    <!-- Using the array input -->
    <h4>Skills:</h4>
    <ul>
      <li *ngFor="let skill of skills">{{ skill }}</li>
    </ul>
  </div>
</div>
```

**Step 2: Use the child in the parent's template**

```typescript
// parent.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent {
  // Data that will be passed DOWN to the child
  pageTitle = 'Team Members';

  users = [
    { id: 1, name: 'Alice Johnson', email: 'alice@company.com', isActive: true },
    { id: 2, name: 'Bob Smith', email: 'bob@company.com', isActive: false },
    { id: 3, name: 'Charlie Lee', email: 'charlie@company.com', isActive: true },
  ];

  aliceSkills = ['Angular', 'TypeScript', 'RxJS'];
  bobSkills = ['React', 'JavaScript', 'Node.js'];
  charlieSkills = ['Vue', 'Python', 'Django'];

  allSkills: { [key: number]: string[] } = {
    1: this.aliceSkills,
    2: this.bobSkills,
    3: this.charlieSkills,
  };

  showDetailedView = true;
}
```

```html
<!-- user-list.component.html -->
<h1>{{ pageTitle }}</h1>

<!-- Passing data to each child component -->
<!-- Each attribute in [] is an @Input() in the child -->
<app-user-card
  *ngFor="let user of users"
  [title]="'Team Member'"
  [userId]="user.id"
  [user]="user"
  [showDetails]="showDetailedView"
  [skills]="allSkills[user.id]">
</app-user-card>

<!-- You can also pass LITERAL values (no binding needed for static strings) -->
<app-user-card
  title="Guest User"
  [userId]="0"
  [user]="{ id: 0, name: 'Guest', email: 'N/A', isActive: false }"
  [showDetails]="false"
  [skills]="[]">
</app-user-card>
```

**Important distinction: `title="Guest"` vs `[title]="'Guest'"`**
- `title="Guest"` — passes the static string `"Guest"` (no binding, just a plain HTML attribute)
- `[title]="'Guest'"` — property binding that evaluates the EXPRESSION `'Guest'` (same result here)
- `[title]="pageTitle"` — property binding that evaluates the VARIABLE `pageTitle` from the component class

---

### @Input() with a Setter — Intercepting Changes

Sometimes you need to DO SOMETHING when an input value changes — validate it, transform it, or trigger a side effect. You can use a TypeScript setter to intercept changes.

**Why use a setter?** When you need to:
- Validate or sanitize incoming data
- Transform the value before storing it
- Log or track changes
- Trigger other logic when a value changes

```typescript
// trimmed-input.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-greeting',
  template: `<h2>Hello, {{ name }}!</h2>
             <p *ngIf="changeCount > 0">Name changed {{ changeCount }} times</p>`
})
export class GreetingComponent {
  // Private backing field — stores the actual value
  private _name = '';
  changeCount = 0;

  // The GETTER — returns the current value
  get name(): string {
    return this._name;
  }

  // The SETTER — intercepts every change from the parent
  @Input()
  set name(value: string) {
    // Validate: reject empty strings
    if (!value || value.trim().length === 0) {
      this._name = 'Anonymous';
      return;
    }
    // Transform: trim whitespace and capitalize first letter
    this._name = value.trim().charAt(0).toUpperCase() + value.trim().slice(1);
    this.changeCount++;
    console.log(`Name was set to: ${this._name}`);
  }
}
```

```html
<!-- parent template -->
<!-- Every time userName changes, the setter in GreetingComponent runs -->
<app-greeting [name]="userName"></app-greeting>

<input [(ngModel)]="userName" placeholder="Type a name">
<!-- As you type, the child's setter runs on every change -->
```

**How it works:**
1. Parent updates `userName` (e.g., user types in the input)
2. Angular detects the change and passes the new value to the child's `@Input()`
3. The **setter** runs, validating and transforming the value
4. The **getter** is used by the template when it renders `{{ name }}`

---

### @Input() with Alias

Sometimes the property name inside your component should differ from the attribute name used in the template. Aliases let you define an external-facing name.

**Why use aliases?**
- When the internal property name is different from what makes sense in the template
- When you want to prefix with the component selector (convention in directive-style components)
- When you are refactoring and want to keep backward compatibility

```typescript
// alert-box.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-alert-box',
  template: `
    <div class="alert" [class]="'alert-' + alertType">
      <strong>{{ alertTitle }}</strong>
      <p>{{ alertBody }}</p>
    </div>
  `
})
export class AlertBoxComponent {
  // The alias 'type' is what the PARENT uses in the template
  // The property name 'alertType' is what THIS component uses internally
  @Input('type') alertType: string = 'info';

  @Input('title') alertTitle: string = '';

  @Input('message') alertBody: string = '';
}
```

```html
<!-- Parent uses the ALIAS names -->
<app-alert-box
  type="warning"
  title="Watch Out!"
  message="This action cannot be undone.">
</app-alert-box>

<app-alert-box
  type="success"
  title="Done!"
  message="Your profile has been updated.">
</app-alert-box>

<!-- Without aliases, parent would have to use the internal names:
     alertType="warning" alertTitle="Watch Out!" alertBody="..."
     which is verbose and exposes internal naming -->
```

---

### Summary: @Input() Data Flow

```
┌──────────────────────────────────┐
│          PARENT COMPONENT        │
│                                  │
│   product = { name: 'Laptop' }   │
│                                  │
│   Template:                      │
│   <app-child [item]="product">   │
│              ▼                   │
└──────────────│───────────────────┘
               │  Data flows DOWN
               │
┌──────────────│───────────────────┐
│          CHILD COMPONENT         │
│              ▼                   │
│   @Input() item: Product;        │
│                                  │
│   Template:                      │
│   {{ item.name }}  →  "Laptop"   │
│                                  │
└──────────────────────────────────┘
```

**Key rules:**
1. Data flows ONE WAY: parent to child
2. The child should NOT modify `@Input()` objects directly (it causes confusing side effects since the parent holds the same reference)
3. If the parent's value changes, the child automatically updates
4. Always initialize `@Input()` properties with defaults or use `!` to tell TypeScript you know the value will be provided

---

## 4.2 Child to Parent Communication with `@Output()` and `EventEmitter`

### What are `@Output()` and `EventEmitter`?

`@Output()` is a decorator that marks a property as an **event channel** that a child can use to send data UP to a parent. `EventEmitter` is the class that actually emits (fires) the events.

**Why do they exist?** Data flows DOWN with `@Input()`, but sometimes the CHILD needs to tell the PARENT that something happened:
- "The user clicked the delete button"
- "The form was submitted — here is the form data"
- "The user selected an item from the list"
- "The counter value changed"

The child does NOT directly call the parent's methods (that would create tight coupling). Instead, the child **emits an event**, and the parent **listens** for it. This is the same concept as a button emitting a `click` event that you listen to with `(click)="handler()"`.

**When to use it:**
- Whenever a child needs to notify the parent of something
- When a child produces data that the parent needs (form submissions, selections, etc.)
- When a child action should trigger a parent reaction

---

### How the Flow Works — Step by Step

```
1. CHILD creates an EventEmitter         →  @Output() itemAdded = new EventEmitter<Product>();
2. CHILD emits an event                  →  this.itemAdded.emit(this.product);
3. PARENT listens in its template        →  <app-child (itemAdded)="onItemAdded($event)">
4. PARENT handles the event in its class →  onItemAdded(product: Product) { ... }
```

Think of it as a WALKIE-TALKIE. The child has a transmitter (`EventEmitter`), and the parent has a receiver (`(event)="handler()"`). The child broadcasts a message, and the parent picks it up.

---

### Full Code Example — Child Emits Events to Parent

**The child component — a simple counter with buttons:**

```typescript
// counter.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-counter',
  templateUrl: './counter.component.html'
})
export class CounterComponent {
  // Receives starting value from parent
  @Input() count: number = 0;
  @Input() label: string = 'Counter';

  // --- EVENT EMITTERS (output channels) ---

  // Signal-only event (no data payload)
  // Use EventEmitter<void> when you just need to say "something happened"
  @Output() reset = new EventEmitter<void>();

  // Event WITH data payload
  // Use EventEmitter<T> when you need to send data TO the parent
  @Output() countChanged = new EventEmitter<number>();

  // --- METHODS that trigger the events ---

  increment(): void {
    this.count++;
    this.countChanged.emit(this.count);   // Send the new count UP to parent
  }

  decrement(): void {
    this.count--;
    this.countChanged.emit(this.count);   // Send the new count UP to parent
  }

  onReset(): void {
    this.count = 0;
    this.countChanged.emit(this.count);   // Notify parent of new value
    this.reset.emit();                     // Also fire the "reset" signal
  }
}
```

```html
<!-- counter.component.html -->
<div class="counter">
  <h4>{{ label }}</h4>
  <button (click)="decrement()">-</button>
  <span class="count">{{ count }}</span>
  <button (click)="increment()">+</button>
  <button (click)="onReset()" class="reset-btn">Reset</button>
</div>
```

**The parent component — listens for the child's events:**

```typescript
// app.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  totalScore = 0;
  resetCount = 0;
  lastAction = '';

  // This method runs when the child emits countChanged
  // $event in the template becomes the "newCount" parameter here
  onScoreChanged(newCount: number): void {
    this.totalScore = newCount;
    this.lastAction = `Score changed to ${newCount}`;
  }

  // This method runs when the child emits reset (no data)
  onCounterReset(): void {
    this.resetCount++;
    this.lastAction = 'Counter was reset!';
  }
}
```

```html
<!-- app.component.html -->

<!-- LISTEN for child events using (eventName)="handler($event)" -->
<app-counter
  [count]="totalScore"
  [label]="'Game Score'"
  (countChanged)="onScoreChanged($event)"
  (reset)="onCounterReset()">
</app-counter>

<!-- Display state that was updated by child events -->
<p>Total Score: {{ totalScore }}</p>
<p>Reset count: {{ resetCount }}</p>
<p>Last action: {{ lastAction }}</p>
```

**The `$event` variable:**
- In the template, `$event` contains whatever the child passed to `emit()`
- `this.countChanged.emit(42)` in child makes `$event = 42` in parent template
- `this.reset.emit()` in child makes `$event = undefined` (no payload)

---

### Real-World Example: Child Form Emitting Data to Parent

This is one of the MOST common patterns in Angular — a reusable form component that emits the form data when submitted.

**The child form component:**

```typescript
// user-form.component.ts
import { Component, Output, EventEmitter, Input } from '@angular/core';

interface UserFormData {
  name: string;
  email: string;
  role: string;
}

@Component({
  selector: 'app-user-form',
  templateUrl: './user-form.component.html'
})
export class UserFormComponent {
  // Optional: parent can pass in initial data for editing
  @Input() initialData: UserFormData | null = null;

  // Emit the complete form data when user submits
  @Output() formSubmitted = new EventEmitter<UserFormData>();

  // Emit when user cancels
  @Output() formCancelled = new EventEmitter<void>();

  // Form fields (local state)
  name = '';
  email = '';
  role = 'user';

  ngOnInit(): void {
    // If parent passed initial data, populate the form (for editing)
    if (this.initialData) {
      this.name = this.initialData.name;
      this.email = this.initialData.email;
      this.role = this.initialData.role;
    }
  }

  onSubmit(): void {
    // Build the data object
    const formData: UserFormData = {
      name: this.name,
      email: this.email,
      role: this.role
    };

    // EMIT the data UP to the parent
    this.formSubmitted.emit(formData);

    // Reset the form after submission
    this.name = '';
    this.email = '';
    this.role = 'user';
  }

  onCancel(): void {
    this.formCancelled.emit();
  }
}
```

```html
<!-- user-form.component.html -->
<form (ngSubmit)="onSubmit()">
  <div class="form-group">
    <label for="name">Name:</label>
    <input id="name" [(ngModel)]="name" name="name" required>
  </div>

  <div class="form-group">
    <label for="email">Email:</label>
    <input id="email" [(ngModel)]="email" name="email" type="email" required>
  </div>

  <div class="form-group">
    <label for="role">Role:</label>
    <select id="role" [(ngModel)]="role" name="role">
      <option value="user">User</option>
      <option value="admin">Admin</option>
      <option value="editor">Editor</option>
    </select>
  </div>

  <div class="form-actions">
    <button type="submit">Submit</button>
    <button type="button" (click)="onCancel()">Cancel</button>
  </div>
</form>
```

**The parent component that uses this form:**

```typescript
// manage-users.component.ts
import { Component } from '@angular/core';

interface UserFormData {
  name: string;
  email: string;
  role: string;
}

@Component({
  selector: 'app-manage-users',
  templateUrl: './manage-users.component.html'
})
export class ManageUsersComponent {
  users: UserFormData[] = [];
  showForm = false;
  statusMessage = '';

  // Called when the child form emits formSubmitted
  onUserSubmitted(userData: UserFormData): void {
    this.users.push(userData);
    this.showForm = false;
    this.statusMessage = `User "${userData.name}" added successfully!`;

    // In a real app, you would call an API here:
    // this.userService.createUser(userData).subscribe(...)
  }

  // Called when the child form emits formCancelled
  onFormCancelled(): void {
    this.showForm = false;
    this.statusMessage = 'Form cancelled.';
  }
}
```

```html
<!-- manage-users.component.html -->
<h2>Manage Users</h2>

<button (click)="showForm = true" *ngIf="!showForm">+ Add User</button>

<!-- The form component: parent LISTENS for its events -->
<app-user-form
  *ngIf="showForm"
  (formSubmitted)="onUserSubmitted($event)"
  (formCancelled)="onFormCancelled()">
</app-user-form>

<p *ngIf="statusMessage" class="status">{{ statusMessage }}</p>

<!-- Display the list of users -->
<div *ngIf="users.length > 0">
  <h3>User List</h3>
  <table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Email</th>
        <th>Role</th>
      </tr>
    </thead>
    <tbody>
      <tr *ngFor="let user of users">
        <td>{{ user.name }}</td>
        <td>{{ user.email }}</td>
        <td>{{ user.role }}</td>
      </tr>
    </tbody>
  </table>
</div>
```

---

### Event Naming Conventions

Follow these conventions to keep your codebase consistent and readable:

| Convention | Example | Explanation |
|---|---|---|
| Use **past tense** or **action verbs** | `itemAdded`, `formSubmitted`, `userDeleted` | Describes what HAPPENED |
| Do NOT prefix with `on` | `itemAdded` (not `onItemAdded`) | `on` is for the HANDLER in the parent |
| Parent handler uses `on` prefix | `(itemAdded)="onItemAdded($event)"` | Makes it clear this is a response to an event |
| Be specific | `productSelected` (not just `selected`) | Avoids ambiguity in complex templates |
| Use `Change` suffix for value changes | `countChange`, `statusChange` | Consistent with Angular's own naming |

**Angular's own convention (banana-in-a-box pattern):** If you have an `@Input()` called `value` and an `@Output()` called `valueChange`, you get two-way binding for free:

```typescript
// custom-slider.component.ts
@Input() value: number = 0;
@Output() valueChange = new EventEmitter<number>();  // Name must be: inputName + "Change"
```

```html
<!-- Parent can now use two-way binding! -->
<app-custom-slider [(value)]="sliderValue"></app-custom-slider>

<!-- This is equivalent to: -->
<app-custom-slider [value]="sliderValue" (valueChange)="sliderValue = $event"></app-custom-slider>
```

---

### Summary: @Output() Data Flow

```
┌──────────────────────────────────┐
│          PARENT COMPONENT        │
│                                  │
│   onItemAdded(item) {            │
│     this.cart.push(item);  ◄─────│── Handler receives data
│   }                              │
│                                  │
│   Template:                      │
│   <app-child                     │
│     (itemAdded)="onItemAdded     │
│                   ($event)">     │
│              ▲                   │
└──────────────│───────────────────┘
               │  Data flows UP
               │
┌──────────────│───────────────────┐
│          CHILD COMPONENT         │
│              │                   │
│   @Output() itemAdded =          │
│     new EventEmitter<Product>(); │
│                                  │
│   addItem() {                    │
│     this.itemAdded.emit(         │
│       this.product               │
│     );  ─────────────────────►   │── emit() fires the event
│   }                              │
│                                  │
└──────────────────────────────────┘
```

---

## 4.3 @ViewChild and @ViewChildren

### What are They?

`@ViewChild` and `@ViewChildren` let a **parent component** get a direct reference to a **child component instance** (or a DOM element) that exists in the parent's own template. Once you have the reference, you can:
- Read the child's properties
- Call the child's methods
- Access a native DOM element

**Why do they exist?** Sometimes `@Input()/@Output()` is not enough. You might need to:
- Programmatically call a method on a child (e.g., `child.reset()`, `child.focus()`)
- Read the current state of a child component without waiting for an event
- Access a raw DOM element (e.g., to focus an input, scroll to an element, or measure dimensions)

**When to use:**
- When you need to imperatively call a child's method
- When you need to read a child's state directly
- When you need access to a native DOM element
- When event-based communication (`@Output`) is too indirect for the use case

**When NOT to use:**
- For simple data passing — use `@Input()` instead
- For notifying the parent — use `@Output()` instead
- Overusing `@ViewChild` creates tight coupling between parent and child

---

### @ViewChild — Accessing a Single Child Component

**The child component with public methods:**

```typescript
// timer.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-timer',
  template: `
    <div class="timer">
      <h3>Timer: {{ seconds }}s</h3>
      <p>Status: {{ isRunning ? 'Running' : 'Stopped' }}</p>
    </div>
  `
})
export class TimerComponent {
  seconds = 0;
  isRunning = false;
  private intervalId: any = null;

  // PUBLIC methods — the parent will call these via @ViewChild
  start(): void {
    if (this.isRunning) return;
    this.isRunning = true;
    this.intervalId = setInterval(() => {
      this.seconds++;
    }, 1000);
  }

  stop(): void {
    this.isRunning = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  reset(): void {
    this.stop();
    this.seconds = 0;
  }

  // Read the current time
  getCurrentTime(): number {
    return this.seconds;
  }

  ngOnDestroy(): void {
    this.stop();  // Clean up the interval
  }
}
```

**The parent component using @ViewChild:**

```typescript
// app.component.ts
import { Component, ViewChild, AfterViewInit } from '@angular/core';
import { TimerComponent } from './timer/timer.component';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements AfterViewInit {

  // @ViewChild gives you a reference to the child component INSTANCE
  // The argument is the COMPONENT CLASS (or a template reference variable name)
  @ViewChild(TimerComponent) timerComponent!: TimerComponent;

  savedTime = 0;

  // IMPORTANT: The child reference is NOT available in the constructor or ngOnInit!
  // It is only available AFTER the view has been initialized.
  ngAfterViewInit(): void {
    // Now timerComponent is available
    console.log('Timer component:', this.timerComponent);
    // You CAN access child properties here
    console.log('Initial seconds:', this.timerComponent.seconds);
  }

  // Parent can call child methods directly
  startTimer(): void {
    this.timerComponent.start();
  }

  stopTimer(): void {
    this.timerComponent.stop();
  }

  resetTimer(): void {
    this.timerComponent.reset();
  }

  saveCurrentTime(): void {
    // Read child's state directly
    this.savedTime = this.timerComponent.getCurrentTime();
  }
}
```

```html
<!-- app.component.html -->
<h1>Timer Control Panel</h1>

<!-- The child component in the template -->
<app-timer></app-timer>

<!-- Parent controls that call child methods via @ViewChild -->
<div class="controls">
  <button (click)="startTimer()">Start</button>
  <button (click)="stopTimer()">Stop</button>
  <button (click)="resetTimer()">Reset</button>
  <button (click)="saveCurrentTime()">Save Time</button>
</div>

<p *ngIf="savedTime > 0">Saved time: {{ savedTime }}s</p>
```

---

### @ViewChild — Accessing DOM Elements with Template Reference Variables

You can also use `@ViewChild` with a **template reference variable** (`#ref`) to get access to a native DOM element.

```typescript
// search.component.ts
import { Component, ViewChild, ElementRef, AfterViewInit } from '@angular/core';

@Component({
  selector: 'app-search',
  template: `
    <div class="search-container">
      <!-- #searchInput is a template reference variable -->
      <input #searchInput
             type="text"
             placeholder="Search..."
             (keyup.enter)="onSearch()">
      <button (click)="onSearch()">Search</button>
      <button (click)="clearAndFocus()">Clear</button>

      <p #resultsParagraph>{{ resultsMessage }}</p>
    </div>
  `
})
export class SearchComponent implements AfterViewInit {

  // Access the native <input> element via its template reference variable name
  // ElementRef wraps the native DOM element
  @ViewChild('searchInput') searchInput!: ElementRef<HTMLInputElement>;

  @ViewChild('resultsParagraph') resultsEl!: ElementRef<HTMLParagraphElement>;

  resultsMessage = '';

  ngAfterViewInit(): void {
    // Auto-focus the search input when the component loads
    this.searchInput.nativeElement.focus();
  }

  onSearch(): void {
    // Read the value directly from the DOM element
    const query = this.searchInput.nativeElement.value;
    this.resultsMessage = `Searching for: "${query}"...`;
  }

  clearAndFocus(): void {
    // Manipulate the DOM element directly
    this.searchInput.nativeElement.value = '';
    this.searchInput.nativeElement.focus();
    this.resultsMessage = '';

    // You can also access styles, attributes, etc.
    this.resultsEl.nativeElement.style.color = 'gray';
  }
}
```

**`ElementRef` vs Component reference:**
- `@ViewChild(TimerComponent)` gives you the **component instance** (with all its properties and methods)
- `@ViewChild('searchInput')` with a `#ref` gives you an **`ElementRef`** wrapping the native DOM element
- Use `elementRef.nativeElement` to access the actual DOM element

---

### @ViewChild — The `static` Option

The `static` option controls WHEN the `@ViewChild` query resolves:

```typescript
// static: false (DEFAULT) — resolves AFTER change detection
// Use this when the child is inside *ngIf, *ngFor, or *ngSwitch
@ViewChild('myRef', { static: false }) myRef!: ElementRef;  // Available in ngAfterViewInit

// static: true — resolves BEFORE change detection
// Use this when the child is ALWAYS present (not inside *ngIf, etc.)
// Advantage: available in ngOnInit (not just ngAfterViewInit)
@ViewChild('myRef', { static: true }) myRef!: ElementRef;   // Available in ngOnInit
```

**When to use which:**

```typescript
@Component({
  template: `
    <!-- This input is ALWAYS present — use static: true -->
    <input #alwaysHere type="text">

    <!-- This input is CONDITIONALLY present — use static: false (default) -->
    <input *ngIf="showSearch" #sometimesHere type="text">
  `
})
export class ExampleComponent implements OnInit, AfterViewInit {
  showSearch = false;

  @ViewChild('alwaysHere', { static: true }) alwaysHereRef!: ElementRef;
  @ViewChild('sometimesHere', { static: false }) sometimesHereRef!: ElementRef;

  ngOnInit(): void {
    // alwaysHereRef IS available here (because static: true)
    console.log(this.alwaysHereRef.nativeElement);

    // sometimesHereRef is NOT available here yet
  }

  ngAfterViewInit(): void {
    // Both are available here (if the *ngIf condition is true)
  }
}
```

**Rule of thumb:** Leave it as `static: false` (the default) unless you have a specific reason to need the reference in `ngOnInit`. Most of the time, using `ngAfterViewInit` is the correct approach.

---

### @ViewChildren — Accessing Multiple Children with QueryList

When you have MULTIPLE instances of a child component (e.g., inside an `*ngFor`), use `@ViewChildren` to get ALL of them as a `QueryList`.

```typescript
// app.component.ts
import { Component, ViewChildren, QueryList, AfterViewInit } from '@angular/core';
import { TimerComponent } from './timer/timer.component';

@Component({
  selector: 'app-root',
  template: `
    <h1>Multiple Timers</h1>

    <app-timer *ngFor="let label of timerLabels"></app-timer>

    <div class="controls">
      <button (click)="startAll()">Start All</button>
      <button (click)="stopAll()">Stop All</button>
      <button (click)="resetAll()">Reset All</button>
      <button (click)="logAllTimes()">Log All Times</button>
    </div>

    <pre>{{ allTimes | json }}</pre>
  `
})
export class AppComponent implements AfterViewInit {
  timerLabels = ['Timer A', 'Timer B', 'Timer C'];
  allTimes: number[] = [];

  // QueryList<TimerComponent> — a live list of all TimerComponent instances
  @ViewChildren(TimerComponent) timers!: QueryList<TimerComponent>;

  ngAfterViewInit(): void {
    console.log(`Found ${this.timers.length} timers`);

    // QueryList has a .changes observable that emits when items are added/removed
    this.timers.changes.subscribe((updatedList: QueryList<TimerComponent>) => {
      console.log(`Timer count changed to: ${updatedList.length}`);
    });
  }

  startAll(): void {
    // Iterate over all child instances
    this.timers.forEach(timer => timer.start());
  }

  stopAll(): void {
    this.timers.forEach(timer => timer.stop());
  }

  resetAll(): void {
    this.timers.forEach(timer => timer.reset());
  }

  logAllTimes(): void {
    // Read state from all children
    this.allTimes = this.timers.map(timer => timer.getCurrentTime());
  }
}
```

**Key `QueryList` properties and methods:**

| Property / Method | Description |
|---|---|
| `length` | Number of items in the list |
| `first` | First item in the list |
| `last` | Last item in the list |
| `forEach(fn)` | Iterate over each item |
| `map(fn)` | Map each item to a new value |
| `filter(fn)` | Filter items |
| `find(fn)` | Find a single item |
| `toArray()` | Convert to a regular array |
| `changes` | Observable that emits when the list changes (items added/removed) |

---

### AfterViewInit — The Critical Lifecycle Hook

`@ViewChild` and `@ViewChildren` references are **only guaranteed to be available** after the view has been fully initialized. This is why you use the `AfterViewInit` lifecycle hook.

```typescript
import { Component, ViewChild, AfterViewInit, OnInit } from '@angular/core';

export class MyComponent implements OnInit, AfterViewInit {
  @ViewChild('myElement') myEl!: ElementRef;

  ngOnInit(): void {
    // WARNING: @ViewChild reference may NOT be available here yet!
    // console.log(this.myEl);  // Could be undefined
  }

  ngAfterViewInit(): void {
    // SAFE: @ViewChild reference IS available here
    console.log(this.myEl.nativeElement);  // Works!
  }
}
```

**Lifecycle order recap:**
```
ngOnInit          → Component class is initialized (@Input values ready)
ngAfterViewInit   → View (template) is ready (@ViewChild references ready)
ngAfterContentInit → Projected content is ready (@ContentChild references ready)
```

---

## 4.4 @ContentChild and Content Projection (`ng-content`)

### What is Content Projection?

Content projection lets you **pass HTML content INTO a component** from the outside. If you are familiar with React, it is exactly like React's `children` prop or Vue's `slots`.

**Why does it exist?** Some components are WRAPPERS — they provide structure, styling, or behavior, but the CONTENT inside them should be customizable by whoever uses them. Think of:
- A card component where the header, body, and footer are different every time
- A modal/dialog component where the content changes
- A tab component where each tab's content is unique
- A layout component with sidebar and main content areas

Without content projection, you would have to pass ALL content through `@Input()` as strings or complex objects, which is ugly and limiting.

---

### Single-Slot Projection

The simplest form: one `<ng-content>` slot that accepts EVERYTHING passed between the component's tags.

```typescript
// card.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <div class="card-body">
        <!-- ng-content is the "slot" where projected content will appear -->
        <ng-content></ng-content>
      </div>
    </div>
  `,
  styles: [`
    .card {
      border: 1px solid #ddd;
      border-radius: 8px;
      margin: 10px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .card-body {
      padding: 16px;
    }
  `]
})
export class CardComponent { }
```

```html
<!-- Using the card component — content goes BETWEEN the tags -->

<!-- Card 1: Simple text content -->
<app-card>
  <h3>Welcome!</h3>
  <p>This is a simple card with projected content.</p>
</app-card>

<!-- Card 2: Complex content with a form -->
<app-card>
  <h3>Login</h3>
  <form>
    <input type="email" placeholder="Email">
    <input type="password" placeholder="Password">
    <button type="submit">Sign In</button>
  </form>
</app-card>

<!-- Card 3: Content with another component -->
<app-card>
  <app-user-profile [user]="currentUser"></app-user-profile>
</app-card>
```

**How it works:**
1. The parent writes HTML **between** `<app-card>` and `</app-card>`
2. Angular takes that HTML and injects it where `<ng-content>` is in the card's template
3. The card component provides the wrapper (border, shadow, padding)
4. The parent provides the content (whatever it wants)

---

### Multi-Slot Projection with `select`

For more complex components, you need MULTIPLE slots. Use the `select` attribute on `<ng-content>` to specify WHICH content goes WHERE.

```typescript
// panel.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-panel',
  template: `
    <div class="panel">
      <!-- SLOT 1: Header — only content with the attribute "panel-header" goes here -->
      <div class="panel-header">
        <ng-content select="[panel-header]"></ng-content>
      </div>

      <!-- SLOT 2: Body — only content with the CSS class "panel-body" goes here -->
      <div class="panel-body">
        <ng-content select=".panel-body"></ng-content>
      </div>

      <!-- SLOT 3: Footer — only content with the tag "panel-footer" goes here -->
      <div class="panel-footer">
        <ng-content select="panel-footer"></ng-content>
      </div>

      <!-- DEFAULT SLOT: Everything else that does not match any select goes here -->
      <div class="panel-extra">
        <ng-content></ng-content>
      </div>
    </div>
  `,
  styles: [`
    .panel { border: 1px solid #ccc; border-radius: 4px; margin: 16px 0; }
    .panel-header { background: #f5f5f5; padding: 12px 16px; font-weight: bold;
                    border-bottom: 1px solid #ccc; }
    .panel-body { padding: 16px; }
    .panel-footer { background: #f5f5f5; padding: 12px 16px;
                    border-top: 1px solid #ccc; text-align: right; }
    .panel-extra { padding: 8px 16px; font-style: italic; color: #666; }
  `]
})
export class PanelComponent { }
```

```html
<!-- Using the multi-slot panel -->
<app-panel>
  <!-- This matches select="[panel-header]" (attribute selector) -->
  <div panel-header>
    <h2>User Settings</h2>
  </div>

  <!-- This matches select=".panel-body" (class selector) -->
  <div class="panel-body">
    <p>Configure your account preferences below.</p>
    <form>
      <label>
        <input type="checkbox"> Enable notifications
      </label>
      <label>
        <input type="checkbox"> Dark mode
      </label>
    </form>
  </div>

  <!-- This matches select="panel-footer" (element/tag selector) -->
  <panel-footer>
    <button>Cancel</button>
    <button class="primary">Save Changes</button>
  </panel-footer>

  <!-- This does NOT match any select — goes to the default <ng-content> -->
  <p>This is extra content that falls into the default slot.</p>
</app-panel>
```

**The `select` attribute supports:**

| Selector Type | Syntax | Matches |
|---|---|---|
| **Attribute** | `select="[panel-header]"` | `<div panel-header>` |
| **CSS class** | `select=".panel-body"` | `<div class="panel-body">` |
| **Element/Tag** | `select="panel-footer"` | `<panel-footer>` |
| **Combination** | `select="div.special"` | `<div class="special">` |
| **Default** | no `select` attribute | Everything that does not match other slots |

---

### Real-World Example: Card Component with Header/Body/Footer Slots

This is a production-ready pattern you will see in many Angular UI libraries.

```typescript
// reusable-card.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-reusable-card',
  template: `
    <div class="card" [class.card-elevated]="elevated">
      <!-- Header slot (optional — only shows wrapper if content is projected) -->
      <div class="card-header" *ngIf="hasHeader">
        <ng-content select="[card-header]"></ng-content>
      </div>

      <!-- Body slot (the main content) -->
      <div class="card-body">
        <ng-content></ng-content>
      </div>

      <!-- Footer slot (optional) -->
      <div class="card-footer" *ngIf="hasFooter">
        <ng-content select="[card-footer]"></ng-content>
      </div>
    </div>
  `
})
export class ReusableCardComponent {
  @Input() elevated = false;

  // These can be set based on @ContentChild (shown in the next section)
  // For now, always show the header/footer wrappers
  hasHeader = true;
  hasFooter = true;
}
```

```html
<!-- Usage 1: Full card with all slots -->
<app-reusable-card [elevated]="true">
  <div card-header>
    <h3>Order Summary</h3>
    <span class="badge">3 items</span>
  </div>

  <!-- Default slot = body content -->
  <ul>
    <li>Laptop - $999</li>
    <li>Mouse - $29</li>
    <li>Keyboard - $79</li>
  </ul>

  <div card-footer>
    <strong>Total: $1,107</strong>
    <button>Checkout</button>
  </div>
</app-reusable-card>

<!-- Usage 2: Card with only body (no header/footer) -->
<app-reusable-card>
  <p>A simple card with just body content. No header. No footer.</p>
</app-reusable-card>

<!-- Usage 3: Card with header and body only -->
<app-reusable-card>
  <div card-header>
    <h3>Notifications</h3>
  </div>
  <p>You have no new notifications.</p>
</app-reusable-card>
```

---

### @ContentChild — Accessing Projected Content

`@ContentChild` is like `@ViewChild`, but for **projected content** (content that comes through `<ng-content>`). It lets the wrapper component access and interact with the content that was projected into it.

**Key difference:**
- `@ViewChild` — accesses elements in the component's **own template**
- `@ContentChild` — accesses elements in the **projected content** (from the parent)

```typescript
// expandable-panel.component.ts
import { Component, ContentChild, AfterContentInit, ElementRef, TemplateRef } from '@angular/core';

// A directive to mark the header element
import { Directive } from '@angular/core';

@Directive({ selector: '[panelTitle]' })
export class PanelTitleDirective { }

@Component({
  selector: 'app-expandable-panel',
  template: `
    <div class="expandable-panel">
      <div class="panel-header" (click)="toggle()">
        <!-- Project the title content here -->
        <ng-content select="[panelTitle]"></ng-content>
        <span class="toggle-icon">{{ isExpanded ? '▼' : '►' }}</span>
      </div>
      <div class="panel-content" *ngIf="isExpanded">
        <ng-content></ng-content>
      </div>
    </div>
  `
})
export class ExpandablePanelComponent implements AfterContentInit {
  isExpanded = false;

  // Access the projected content that has the panelTitle directive
  @ContentChild(PanelTitleDirective, { read: ElementRef }) titleElement!: ElementRef;

  // IMPORTANT: Use ngAfterContentInit, NOT ngAfterViewInit
  // Because we are accessing PROJECTED CONTENT, not the component's own view
  ngAfterContentInit(): void {
    if (this.titleElement) {
      console.log('Title text:', this.titleElement.nativeElement.textContent);
    }
  }

  toggle(): void {
    this.isExpanded = !this.isExpanded;
  }
}
```

```html
<!-- Using the expandable panel -->
<app-expandable-panel>
  <!-- This is the projected title (matched by @ContentChild) -->
  <h3 panelTitle>Click to Expand — Section A</h3>

  <!-- This is the projected body (default slot) -->
  <p>This is the expandable content of Section A.</p>
  <p>It can contain anything — text, forms, other components.</p>
</app-expandable-panel>

<app-expandable-panel>
  <h3 panelTitle>Click to Expand — Section B</h3>
  <ul>
    <li>Item 1</li>
    <li>Item 2</li>
    <li>Item 3</li>
  </ul>
</app-expandable-panel>
```

**`@ContentChild` vs `@ViewChild` — side by side:**

| Feature | `@ViewChild` | `@ContentChild` |
|---|---|---|
| What it accesses | Component's OWN template | PROJECTED content from parent |
| Lifecycle hook | `ngAfterViewInit` | `ngAfterContentInit` |
| Decorator | `@ViewChild(...)` | `@ContentChild(...)` |
| Plural version | `@ViewChildren(...)` | `@ContentChildren(...)` |
| When to use | Access your own child elements | Access elements projected via `ng-content` |

---

## 4.5 Communication via a Shared Service

### When Parent-Child Is Not Enough

So far, all our communication patterns assume a **parent-child relationship**. But what about:
- **Sibling components** (e.g., `SidebarComponent` and `MainContentComponent`)
- **Deeply nested components** (passing data through 5 levels of parents and children is painful)
- **Completely unrelated components** (e.g., a header notification badge and a notification panel elsewhere on the page)

For these cases, Angular provides a much more powerful pattern: **a shared service** using RxJS `Subject` or `BehaviorSubject`.

---

### How It Works — The Concept

```
┌─────────────┐       ┌───────────────────────┐       ┌─────────────┐
│ Component A │──────►│    Shared Service      │◄──────│ Component B │
│ (Publisher)  │       │                       │       │ (Subscriber) │
│             │       │  Subject/              │       │             │
│ Calls       │       │  BehaviorSubject       │       │ Subscribes  │
│ service     │       │                       │       │ to service  │
│ .send()     │       │  Holds the data and   │       │ .getData()  │
│             │       │  broadcasts to all    │       │             │
│             │       │  subscribers          │       │             │
└─────────────┘       └───────────────────────┘       └─────────────┘
```

The service acts as a **message broker** — components do not need to know about each other. They only know about the service. This is loose coupling at its best.

---

### Subject vs BehaviorSubject — Which to Use?

| Feature | `Subject` | `BehaviorSubject` |
|---|---|---|
| **Initial value** | No | Yes (required) |
| **Late subscribers** | Miss values emitted before they subscribed | Immediately receive the LAST emitted value |
| **When to use** | Events/actions (e.g., "user clicked button") | State/data (e.g., "current user", "cart items") |
| **Analogy** | Live TV — you miss it if you are not watching | DVR — you can always see the last recording |

**`Subject`** — use for one-time events where you do NOT care about the previous value:
```typescript
// "A notification appeared" — if you missed it, it is gone
private notificationSubject = new Subject<string>();
```

**`BehaviorSubject`** — use for state that should always have a current value:
```typescript
// "The current logged-in user" — new components need to know who is logged in RIGHT NOW
private userSubject = new BehaviorSubject<User | null>(null);  // initial value: null
```

---

### Full Example: Notification Service Shared Between Components

**Step 1: Create the shared service**

```typescript
// notification.service.ts
import { Injectable } from '@angular/core';
import { Subject, BehaviorSubject, Observable } from 'rxjs';

export interface Notification {
  id: number;
  message: string;
  type: 'success' | 'error' | 'warning' | 'info';
  timestamp: Date;
}

@Injectable({
  providedIn: 'root'  // Available application-wide (singleton)
})
export class NotificationService {
  // ---- PRIVATE subjects (only the service can emit) ----

  // BehaviorSubject for the notification list (state — always has a current value)
  private notificationsSubject = new BehaviorSubject<Notification[]>([]);

  // Subject for "a new notification just arrived" events
  private newNotificationSubject = new Subject<Notification>();

  // Counter for unique IDs
  private nextId = 1;

  // ---- PUBLIC observables (components subscribe to these) ----

  // Use .asObservable() to expose a READ-ONLY stream
  // Components can subscribe but CANNOT call .next() on these
  notifications$: Observable<Notification[]> = this.notificationsSubject.asObservable();
  newNotification$: Observable<Notification> = this.newNotificationSubject.asObservable();

  // ---- PUBLIC methods (components call these to trigger changes) ----

  addNotification(message: string, type: Notification['type'] = 'info'): void {
    const notification: Notification = {
      id: this.nextId++,
      message,
      type,
      timestamp: new Date()
    };

    // Get the current list, add the new notification, emit the updated list
    const currentList = this.notificationsSubject.getValue();
    const updatedList = [...currentList, notification];
    this.notificationsSubject.next(updatedList);

    // Also emit the single new notification event
    this.newNotificationSubject.next(notification);
  }

  removeNotification(id: number): void {
    const currentList = this.notificationsSubject.getValue();
    const updatedList = currentList.filter(n => n.id !== id);
    this.notificationsSubject.next(updatedList);
  }

  clearAll(): void {
    this.notificationsSubject.next([]);
  }

  // Get the current count (useful for badge display)
  getCount(): number {
    return this.notificationsSubject.getValue().length;
  }
}
```

**Step 2: Component A — Sends notifications (Publisher)**

```typescript
// product-actions.component.ts
import { Component } from '@angular/core';
import { NotificationService } from '../services/notification.service';

@Component({
  selector: 'app-product-actions',
  template: `
    <div class="product-actions">
      <h3>Product Actions</h3>
      <button (click)="onAddToCart()">Add to Cart</button>
      <button (click)="onSaveForLater()">Save for Later</button>
      <button (click)="onDeleteProduct()">Delete Product</button>
    </div>
  `
})
export class ProductActionsComponent {
  // Inject the shared service
  constructor(private notificationService: NotificationService) { }

  onAddToCart(): void {
    // Send a notification through the service
    // ANY component subscribed to the service will receive this
    this.notificationService.addNotification('Product added to cart!', 'success');
  }

  onSaveForLater(): void {
    this.notificationService.addNotification('Product saved for later.', 'info');
  }

  onDeleteProduct(): void {
    this.notificationService.addNotification('Product deleted.', 'warning');
  }
}
```

**Step 3: Component B — Displays notifications (Subscriber)**

```typescript
// notification-panel.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription } from 'rxjs';
import { NotificationService, Notification } from '../services/notification.service';

@Component({
  selector: 'app-notification-panel',
  template: `
    <div class="notification-panel">
      <h3>Notifications ({{ notifications.length }})</h3>
      <button (click)="clearAll()" *ngIf="notifications.length > 0">Clear All</button>

      <div *ngIf="notifications.length === 0" class="empty">
        No notifications.
      </div>

      <div *ngFor="let notification of notifications"
           class="notification"
           [ngClass]="'notification-' + notification.type">
        <p>{{ notification.message }}</p>
        <small>{{ notification.timestamp | date:'shortTime' }}</small>
        <button (click)="dismiss(notification.id)" class="dismiss">x</button>
      </div>
    </div>
  `
})
export class NotificationPanelComponent implements OnInit, OnDestroy {
  notifications: Notification[] = [];

  // Store the subscription so we can clean it up
  private subscription!: Subscription;

  constructor(private notificationService: NotificationService) { }

  ngOnInit(): void {
    // Subscribe to the notifications$ observable
    // Because it is a BehaviorSubject, we IMMEDIATELY get the current list
    // AND we get updates whenever the list changes
    this.subscription = this.notificationService.notifications$.subscribe(
      (notifications: Notification[]) => {
        this.notifications = notifications;
      }
    );
  }

  dismiss(id: number): void {
    this.notificationService.removeNotification(id);
  }

  clearAll(): void {
    this.notificationService.clearAll();
  }

  // CRITICAL: Always unsubscribe when the component is destroyed!
  // Otherwise you get MEMORY LEAKS
  ngOnDestroy(): void {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }
}
```

**Step 4: Component C — Shows a notification badge in the header (Another Subscriber)**

```typescript
// header-badge.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription } from 'rxjs';
import { NotificationService, Notification } from '../services/notification.service';

@Component({
  selector: 'app-header-badge',
  template: `
    <span class="badge" *ngIf="count > 0">{{ count }}</span>
  `
})
export class HeaderBadgeComponent implements OnInit, OnDestroy {
  count = 0;
  private subscription!: Subscription;

  constructor(private notificationService: NotificationService) { }

  ngOnInit(): void {
    this.subscription = this.notificationService.notifications$.subscribe(
      (notifications: Notification[]) => {
        this.count = notifications.length;
      }
    );
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
}
```

**How the whole system works together:**

```
User clicks "Add to Cart" in ProductActionsComponent
    │
    ▼
ProductActionsComponent calls notificationService.addNotification(...)
    │
    ▼
NotificationService updates its BehaviorSubject with the new notification
    │
    ├──► NotificationPanelComponent receives the update → shows the notification
    │
    └──► HeaderBadgeComponent receives the update → updates the badge count
```

All three components are **completely independent**. They do not know about each other. They only know about the `NotificationService`. You can add or remove components without affecting anything else.

---

### The Subscribe/Unsubscribe Pattern

**Why unsubscribe?** When a component subscribes to an observable, the subscription stays ALIVE even after the component is destroyed (removed from the DOM). This causes:
- **Memory leaks** — the destroyed component still holds references in memory
- **Ghost updates** — the subscription keeps receiving data and trying to update a component that no longer exists
- **Bugs** — multiple subscriptions pile up if the component is created and destroyed repeatedly

**Pattern 1: Manual unsubscribe (simple cases)**

```typescript
export class MyComponent implements OnInit, OnDestroy {
  private subscription!: Subscription;

  ngOnInit(): void {
    this.subscription = this.myService.data$.subscribe(data => {
      this.data = data;
    });
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
}
```

**Pattern 2: Subscription sink (multiple subscriptions)**

```typescript
export class MyComponent implements OnInit, OnDestroy {
  private subscriptions = new Subscription();

  ngOnInit(): void {
    // Add multiple subscriptions to the sink
    this.subscriptions.add(
      this.serviceA.data$.subscribe(data => { this.dataA = data; })
    );

    this.subscriptions.add(
      this.serviceB.data$.subscribe(data => { this.dataB = data; })
    );
  }

  ngOnDestroy(): void {
    // One call unsubscribes ALL
    this.subscriptions.unsubscribe();
  }
}
```

**Pattern 3: takeUntil with a destroy Subject (popular pattern)**

```typescript
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

export class MyComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();

  ngOnInit(): void {
    // takeUntil automatically unsubscribes when destroy$ emits
    this.serviceA.data$
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => { this.dataA = data; });

    this.serviceB.data$
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => { this.dataB = data; });
  }

  ngOnDestroy(): void {
    this.destroy$.next();     // Emit a value to trigger takeUntil
    this.destroy$.complete(); // Clean up the subject itself
  }
}
```

**Pattern 4: Async pipe (BEST — no manual subscribe/unsubscribe needed)**

```typescript
// component.ts
export class MyComponent {
  // Expose the observable directly — do NOT subscribe
  notifications$ = this.notificationService.notifications$;

  constructor(private notificationService: NotificationService) { }
}
```

```html
<!-- component.html -->
<!-- The async pipe subscribes AND unsubscribes automatically -->
<div *ngFor="let notification of notifications$ | async">
  {{ notification.message }}
</div>

<!-- With *ngIf -->
<div *ngIf="(notifications$ | async) as notifications">
  <p>You have {{ notifications.length }} notifications.</p>
</div>
```

The `async` pipe is the recommended approach because:
- No manual subscription management
- No risk of memory leaks
- Angular handles subscribe and unsubscribe automatically
- Cleaner code

---

### Why Shared Services Are Sometimes Better Than @Input/@Output Chains

Consider this component tree where `ComponentD` needs data from `ComponentA`:

```
AppComponent
└── ComponentA  (has the data)
    └── ComponentB  (does not need the data)
        └── ComponentC  (does not need the data)
            └── ComponentD  (NEEDS the data!)
```

**With @Input/@Output (prop drilling):** You would have to pass the data through B and C even though they do not use it. This is called **"prop drilling"** and it creates:
- Cluttered intermediate components with unnecessary `@Input()`/`@Output()` properties
- Tight coupling — if you restructure the tree, everything breaks
- Maintenance burden — every change requires modifying multiple components

**With a shared service:** ComponentA puts data in the service, ComponentD reads from the service. B and C are not involved at all. Clean, simple, maintainable.

**Rule of thumb:**
- **1 level deep?** Use `@Input()` / `@Output()` — simple and direct
- **2 levels deep?** Possibly still `@Input()` / `@Output()`, but consider a service
- **3+ levels deep, siblings, or unrelated?** Use a shared service

---

## 4.6 Summary — Comparing All Communication Methods

| Method | Direction | Relationship | Best For | Complexity |
|---|---|---|---|---|
| `@Input()` | Parent → Child | Direct parent-child | Passing data down | Low |
| `@Output()` + `EventEmitter` | Child → Parent | Direct child-parent | Notifying parent of events | Low |
| `@ViewChild` / `@ViewChildren` | Parent → Child | Direct parent-child | Calling child methods, accessing DOM | Medium |
| `ng-content` + `@ContentChild` | Parent → Child (projected) | Wrapper-content | Reusable wrapper components | Medium |
| Shared Service + `Subject` | Any → Any | Any (siblings, unrelated) | Cross-component communication | Medium-High |

### Quick Decision Guide

```
Need to pass data DOWN to a child?
  └── Use @Input()

Need to notify the PARENT that something happened?
  └── Use @Output() + EventEmitter

Need to call a method on a child component?
  └── Use @ViewChild

Need to create a reusable wrapper with customizable content?
  └── Use ng-content (content projection)

Need to communicate between SIBLINGS or UNRELATED components?
  └── Use a shared service with Subject/BehaviorSubject

Need to pass data through MANY levels of components?
  └── Use a shared service (avoid prop drilling)
```

### Data Flow Diagram — All Methods at a Glance

```
                    SHARED SERVICE
                   ┌─────────────┐
         ┌────────►│  Subject /  │◄────────┐
         │         │ BehaviorSub │         │
         │         └─────────────┘         │
         │                                 │
    ┌────┴─────┐                     ┌─────┴────┐
    │ Comp A   │                     │ Comp B   │
    │ (sibling)│                     │ (sibling)│
    └──────────┘                     └──────────┘


    ┌────────────────────────────────────────────┐
    │              PARENT COMPONENT              │
    │                                            │
    │  @ViewChild ──► access child instance      │
    │  (event)="handler($event)" ◄── listens     │
    │  [input]="data" ──► passes data down       │
    │                                            │
    │  Template:                                 │
    │  <app-child [data]="x" (event)="fn($e)">  │
    │    <div card-header>Projected</div>        │
    │  </app-child>                              │
    │                                            │
    └──────────────────┬─────────────────────────┘
                       │
    ┌──────────────────▼─────────────────────────┐
    │              CHILD COMPONENT               │
    │                                            │
    │  @Input() data ◄── receives from parent    │
    │  @Output() event = new EventEmitter()      │
    │  this.event.emit(value) ──► sends to parent│
    │                                            │
    │  <ng-content> ◄── receives projected HTML  │
    │  @ContentChild ──► accesses projected el   │
    │                                            │
    └────────────────────────────────────────────┘
```

---

### Common Interview Questions on Component Communication

1. **What is the difference between `@Input()` and `@Output()`?**
   - `@Input()` passes data from parent to child (downward). `@Output()` emits events from child to parent (upward). Together they form Angular's primary parent-child communication mechanism.

2. **Why should you avoid modifying `@Input()` values in the child?**
   - For primitives (string, number, boolean), the child has its own copy, so mutations do not affect the parent. But for objects and arrays, the child holds the SAME REFERENCE as the parent. Modifying the object in the child silently modifies it in the parent too, which leads to confusing, hard-to-debug behavior.

3. **When would you use `@ViewChild` over `@Output`?**
   - Use `@ViewChild` when you need to imperatively call a method on a child (e.g., `childComponent.reset()`). Use `@Output` when the child should notify the parent of events. `@Output` is more loosely coupled and generally preferred.

4. **What is content projection and when would you use it?**
   - Content projection (`ng-content`) lets you pass HTML content into a component from the outside, like React's `children` or Vue's `slots`. Use it for reusable wrapper components (cards, modals, tabs, layouts) where the structure is fixed but the content varies.

5. **How do sibling components communicate?**
   - Through a shared service using RxJS `Subject` or `BehaviorSubject`. Component A calls a method on the service, the service emits a value, Component B (subscribed to the service) receives it.

6. **Why is it important to unsubscribe from observables?**
   - To prevent memory leaks. If a component subscribes but never unsubscribes, the subscription lives on even after the component is destroyed, consuming memory and potentially causing bugs. Use `ngOnDestroy`, `takeUntil`, or the `async` pipe to manage subscriptions.

---

**Next:** [Phase 5 — Services & Dependency Injection](./Phase05-Services-Dependency-Injection.md)
