# Phase 3: Core Concepts — Components, Data Binding, Directives, Pipes

> This is the HEART of Angular. Everything you build in Angular revolves around these four concepts. Master this phase and you'll understand 70% of Angular development.

---

## 3.1 Components — The Building Blocks

### What is a Component?

A component is a **self-contained piece of UI**. It controls a section of the screen. Every Angular app is a TREE of components.

```
AppComponent (root)
├── HeaderComponent
│   ├── LogoComponent
│   └── NavComponent
├── MainComponent
│   ├── SidebarComponent
│   └── ContentComponent
│       ├── ArticleComponent
│       └── CommentsComponent
└── FooterComponent
```

**Each component has 3 parts:**

| Part | File | Purpose |
|---|---|---|
| **Class** | `*.component.ts` | Logic, data, methods (the brain) |
| **Template** | `*.component.html` | What the user sees (the face) |
| **Styles** | `*.component.css` | How it looks (the clothing) |

**Why components?**
1. **Reusability** — build once, use everywhere (e.g., a button component)
2. **Maintainability** — each component is small and focused
3. **Testability** — test each piece independently
4. **Team collaboration** — different developers can work on different components

---

### Creating a Component

```bash
# Full command
ng generate component header

# Shortcut
ng g c header
```

**What this creates:**
```
src/app/header/
├── header.component.ts        ← Component class
├── header.component.html      ← Template
├── header.component.css       ← Styles
└── header.component.spec.ts   ← Unit test file
```

**AND it automatically registers the component in `app.module.ts`:**
```typescript
@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent  // ← CLI added this automatically!
  ],
  // ...
})
```

---

### Anatomy of a Component

```typescript
// header.component.ts

import { Component } from '@angular/core';  // Step 1: Import the decorator

@Component({                                // Step 2: Apply the decorator
  selector: 'app-header',                  //   - HTML tag name
  templateUrl: './header.component.html',   //   - Template file path
  styleUrls: ['./header.component.css']     //   - Style file(s) path
})
export class HeaderComponent {              // Step 3: Export the class
  // Properties (data)
  title: string = 'My Application';
  isLoggedIn: boolean = false;
  userName: string = '';

  // Methods (behavior)
  login(): void {
    this.isLoggedIn = true;
    this.userName = 'John';
  }

  logout(): void {
    this.isLoggedIn = false;
    this.userName = '';
  }
}
```

```html
<!-- header.component.html -->
<header>
  <h1>{{ title }}</h1>
  <div>
    <span *ngIf="isLoggedIn">Welcome, {{ userName }}!</span>
    <button *ngIf="!isLoggedIn" (click)="login()">Login</button>
    <button *ngIf="isLoggedIn" (click)="logout()">Logout</button>
  </div>
</header>
```

```css
/* header.component.css — these styles ONLY apply to this component */
header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
  background-color: #333;
  color: white;
}
```

**Using the component in another template:**
```html
<!-- app.component.html -->
<app-header></app-header>   <!-- Angular renders HeaderComponent here -->
<main>
  <p>Main content goes here</p>
</main>
```

---

### Component Lifecycle Hooks

Angular components go through a lifecycle — creation, updates, destruction. You can "hook into" these stages to run code at specific moments.

```typescript
import { Component, OnInit, OnDestroy, OnChanges, SimpleChanges } from '@angular/core';

@Component({
  selector: 'app-user-profile',
  templateUrl: './user-profile.component.html',
  styleUrls: ['./user-profile.component.css']
})
export class UserProfileComponent implements OnInit, OnDestroy, OnChanges {

  // --- MOST IMPORTANT HOOKS ---

  // 1. ngOnChanges — runs when @Input() properties change
  // When: Every time a parent passes new data via @Input
  // Use for: Reacting to input changes
  ngOnChanges(changes: SimpleChanges): void {
    console.log('Input changed:', changes);
  }

  // 2. ngOnInit — runs ONCE after the component is created
  // When: After the first ngOnChanges (after inputs are set)
  // Use for: Fetching data, setting up the component
  // THIS IS THE MOST COMMONLY USED HOOK
  ngOnInit(): void {
    console.log('Component initialized!');
    // Fetch user data from API
    // Set up initial state
    // This is like "componentDidMount" in React
  }

  // 3. ngOnDestroy — runs when the component is about to be removed
  // When: Component is removed from the DOM (e.g., *ngIf becomes false, navigating away)
  // Use for: Cleaning up (unsubscribe from observables, clear timers)
  ngOnDestroy(): void {
    console.log('Component destroyed!');
    // Unsubscribe from observables
    // Clear setInterval/setTimeout
    // Remove event listeners
  }

  // --- LESS COMMON HOOKS ---

  // ngDoCheck — runs on EVERY change detection cycle (expensive!)
  // ngAfterContentInit — after projected content is initialized
  // ngAfterContentChecked — after projected content is checked
  // ngAfterViewInit — after the component's view is initialized
  // ngAfterViewChecked — after the component's view is checked
}
```

**Lifecycle order:**
```
constructor        → Class is created (DON'T fetch data here)
ngOnChanges        → Input properties received/changed
ngOnInit           → Component initialized (FETCH DATA HERE)
ngDoCheck          → Change detection runs
ngAfterContentInit → <ng-content> is ready
ngAfterContentChecked
ngAfterViewInit    → View (template) is ready
ngAfterViewChecked
ngOnDestroy        → Component is about to be removed (CLEAN UP HERE)
```

**Why `ngOnInit` instead of `constructor`?**
- The `constructor` runs BEFORE Angular sets up `@Input()` values
- `ngOnInit` runs AFTER inputs are available
- Keep the constructor simple (just dependency injection)

---

### Inline Templates and Styles

For small components, you can skip separate files:

```typescript
@Component({
  selector: 'app-greeting',
  // Inline template (instead of templateUrl)
  template: `
    <div class="greeting">
      <h2>Hello, {{ name }}!</h2>
      <p>Welcome to our app</p>
    </div>
  `,
  // Inline styles (instead of styleUrls)
  styles: [`
    .greeting {
      padding: 20px;
      border: 1px solid #ccc;
      border-radius: 8px;
    }
    h2 { color: #dd0031; }
  `]
})
export class GreetingComponent {
  name = 'World';
}
```

**When to use inline vs separate files:**
- **Inline:** Small components with < 10 lines of HTML, < 5 style rules
- **Separate files:** Anything bigger. Most components use separate files.

---

## 3.2 Data Binding — Connecting Data to UI

Data binding is HOW you connect your component's data (TypeScript) to the template (HTML). There are **4 types**.

### 3.2.1 String Interpolation `{{ }}`

**Direction:** Component → Template (one-way, class to view)
**What it does:** Displays a value from your component class in the template

```typescript
// product.component.ts
export class ProductComponent {
  productName = 'Laptop';
  price = 999.99;
  inStock = true;

  getDiscountPrice(): number {
    return this.price * 0.9;  // 10% discount
  }
}
```

```html
<!-- product.component.html -->

<!-- Display a property -->
<h2>{{ productName }}</h2>

<!-- Display a number -->
<p>Price: ${{ price }}</p>

<!-- Call a method -->
<p>After discount: ${{ getDiscountPrice() }}</p>

<!-- Use expressions -->
<p>Tax: ${{ price * 0.08 }}</p>

<!-- Use ternary operator -->
<p>Status: {{ inStock ? 'Available' : 'Out of Stock' }}</p>

<!-- String concatenation inside interpolation -->
<p>{{ 'Product: ' + productName }}</p>
```

**Rules for interpolation:**
- Must resolve to a string (Angular calls `.toString()` automatically)
- Can use simple expressions (math, ternary, method calls)
- CANNOT use: assignments (`=`), `new`, chaining (`;`), `++`, `--`
- Keep expressions SIMPLE — complex logic belongs in the component class

---

### 3.2.2 Property Binding `[property]`

**Direction:** Component → Template (one-way, class to view)
**What it does:** Binds a component property to an HTML element's property

```typescript
// product.component.ts
export class ProductComponent {
  imageUrl = 'assets/laptop.jpg';
  isDisabled = true;
  buttonColor = 'red';
  inputType = 'password';
}
```

```html
<!-- product.component.html -->

<!-- Bind to the src property of <img> -->
<img [src]="imageUrl" alt="Product">

<!-- Bind to the disabled property of <button> -->
<button [disabled]="isDisabled">Add to Cart</button>

<!-- Bind to any HTML attribute -->
<div [style.color]="buttonColor">Colored text</div>

<!-- Bind to input type -->
<input [type]="inputType" placeholder="Enter password">

<!-- Bind to class -->
<div [class.active]="isActive">This div</div>
<div [class]="currentClass">This div</div>

<!-- Bind to style -->
<div [style.font-size.px]="fontSize">Sized text</div>
<div [style.background-color]="bgColor">Colored background</div>
```

**Interpolation vs Property Binding — when to use which?**

```html
<!-- These two are EQUIVALENT for string values: -->
<img src="{{ imageUrl }}">      <!-- Interpolation -->
<img [src]="imageUrl">          <!-- Property binding -->

<!-- But property binding can handle NON-string values: -->
<button [disabled]="isDisabled">  <!-- Boolean — use property binding -->
<div [hidden]="isHidden">        <!-- Boolean — use property binding -->

<!-- Rule of thumb:
     - String values: either works, but property binding is cleaner
     - Non-string values (boolean, number, object): use property binding
-->
```

---

### 3.2.3 Event Binding `(event)`

**Direction:** Template → Component (one-way, view to class)
**What it does:** Listens for DOM events and calls component methods

```typescript
// counter.component.ts
export class CounterComponent {
  count = 0;
  message = '';

  increment(): void {
    this.count++;
  }

  decrement(): void {
    this.count--;
  }

  onMouseEnter(): void {
    this.message = 'Mouse is over the counter!';
  }

  onMouseLeave(): void {
    this.message = '';
  }

  onInputChange(event: Event): void {
    // $event contains the DOM event object
    const input = event.target as HTMLInputElement;
    this.message = input.value;
  }

  onKeyPress(event: KeyboardEvent): void {
    if (event.key === 'Enter') {
      this.message = 'Enter was pressed!';
    }
  }
}
```

```html
<!-- counter.component.html -->

<!-- Click event -->
<button (click)="increment()">+</button>
<span>{{ count }}</span>
<button (click)="decrement()">-</button>

<!-- Mouse events -->
<div (mouseenter)="onMouseEnter()" (mouseleave)="onMouseLeave()">
  Hover over me!
</div>
<p>{{ message }}</p>

<!-- Input events with $event -->
<input (input)="onInputChange($event)" placeholder="Type something">

<!-- Keyboard events -->
<input (keyup)="onKeyPress($event)" placeholder="Press Enter">

<!-- Keyboard shortcut: filter specific keys -->
<input (keyup.enter)="onKeyPress($event)" placeholder="Press Enter">
<input (keyup.escape)="clearInput()" placeholder="Press Escape to clear">

<!-- Inline expressions (for simple operations) -->
<button (click)="count = count + 1">Quick increment</button>
<button (click)="count = 0">Reset</button>
```

**The `$event` object:**
- `$event` is a special variable in Angular templates
- It contains the native DOM event object
- For `(click)` → `MouseEvent`
- For `(keyup)` → `KeyboardEvent`
- For `(input)` → `Event` (use `event.target` to get the element)

---

### 3.2.4 Two-Way Binding `[(ngModel)]`

**Direction:** Both ways (class ↔ view)
**What it does:** Keeps the component property and the input value in sync

```typescript
// search.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-search',
  templateUrl: './search.component.html'
})
export class SearchComponent {
  searchTerm = '';
  username = '';
  selectedColor = 'red';
}
```

```html
<!-- search.component.html -->

<!-- Two-way binding: typing updates searchTerm, changing searchTerm updates the input -->
<input [(ngModel)]="searchTerm" placeholder="Search...">
<p>You are searching for: {{ searchTerm }}</p>

<!-- Works with different input types -->
<input [(ngModel)]="username" type="text" placeholder="Username">

<!-- Works with select -->
<select [(ngModel)]="selectedColor">
  <option value="red">Red</option>
  <option value="blue">Blue</option>
  <option value="green">Green</option>
</select>
<p>Selected color: {{ selectedColor }}</p>

<!-- Works with checkbox -->
<input [(ngModel)]="isSubscribed" type="checkbox"> Subscribe
<p>Subscribed: {{ isSubscribed }}</p>

<!-- Works with textarea -->
<textarea [(ngModel)]="comments" placeholder="Your comments"></textarea>
```

**IMPORTANT:** To use `ngModel`, you MUST import `FormsModule`:

```typescript
// app.module.ts
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [
    BrowserModule,
    FormsModule  // ← REQUIRED for [(ngModel)]
  ],
  // ...
})
export class AppModule { }
```

**How two-way binding actually works (the "banana in a box"):**

`[(ngModel)]` is actually shorthand for BOTH property binding AND event binding:

```html
<!-- This: -->
<input [(ngModel)]="searchTerm">

<!-- Is shorthand for this: -->
<input [ngModel]="searchTerm" (ngModelChange)="searchTerm = $event">

<!-- Breaking it down:
     [ngModel]="searchTerm"              → Property binding (data → input)
     (ngModelChange)="searchTerm = $event" → Event binding (input → data)
-->
```

The `[( )]` syntax is called **"banana in a box"** — `( )` inside `[ ]`.

---

### Data Binding Summary

```
Component ──────────────────────────── Template
    │                                      │
    │  {{ value }}                          │  String Interpolation
    │  ────────────────────────────>        │  (Class → View)
    │                                      │
    │  [property]="value"                  │  Property Binding
    │  ────────────────────────────>        │  (Class → View)
    │                                      │
    │  (event)="handler()"                 │  Event Binding
    │  <────────────────────────────        │  (View → Class)
    │                                      │
    │  [(ngModel)]="value"                 │  Two-Way Binding
    │  <──────────────────────────>        │  (Both directions)
    │                                      │
```

---

## 3.3 Directives — Modifying the DOM

### What are Directives?

Directives are **instructions that tell Angular to change the DOM**. Think of them as custom attributes that add behavior to HTML elements.

**Three types:**

| Type | Purpose | Example |
|---|---|---|
| **Components** | Directives WITH a template | `<app-header>` (you already know these!) |
| **Structural** | ADD or REMOVE DOM elements | `*ngIf`, `*ngFor`, `*ngSwitch` |
| **Attribute** | CHANGE appearance or behavior | `ngClass`, `ngStyle`, custom directives |

The `*` asterisk on structural directives means "this directive changes the DOM structure."

---

### 3.3.1 `*ngIf` — Conditional Rendering

**What:** Shows or hides an element based on a condition.
**How:** When the condition is `false`, Angular completely REMOVES the element from the DOM (not just hiding it with CSS).

```typescript
// user.component.ts
export class UserComponent {
  isLoggedIn = false;
  user = { name: 'John', role: 'admin' };
  items: string[] = [];
  isLoading = true;
}
```

```html
<!-- user.component.html -->

<!-- Basic usage -->
<div *ngIf="isLoggedIn">
  Welcome back, {{ user.name }}!
</div>

<!-- With else block -->
<div *ngIf="isLoggedIn; else loginTemplate">
  <p>Welcome, {{ user.name }}!</p>
  <button (click)="isLoggedIn = false">Logout</button>
</div>
<ng-template #loginTemplate>
  <p>Please log in to continue.</p>
  <button (click)="isLoggedIn = true">Login</button>
</ng-template>

<!-- With then and else -->
<div *ngIf="isLoading; then loadingTpl; else contentTpl"></div>
<ng-template #loadingTpl>
  <p>Loading... Please wait.</p>
</ng-template>
<ng-template #contentTpl>
  <p>Content loaded successfully!</p>
</ng-template>

<!-- Common pattern: check if array has items -->
<div *ngIf="items.length > 0; else noItems">
  <p>Found {{ items.length }} items</p>
</div>
<ng-template #noItems>
  <p>No items found.</p>
</ng-template>

<!-- Multiple conditions -->
<div *ngIf="isLoggedIn && user.role === 'admin'">
  Admin panel goes here
</div>

<!-- Assign result to a variable (useful with async pipe) -->
<div *ngIf="user as currentUser">
  {{ currentUser.name }} - {{ currentUser.role }}
</div>
```

**`*ngIf` vs `[hidden]` — what's the difference?**

```html
<!-- *ngIf: REMOVES element from DOM entirely -->
<div *ngIf="isVisible">I'm gone from the DOM when false</div>

<!-- [hidden]: Hides with CSS (display: none) but element stays in DOM -->
<div [hidden]="!isVisible">I'm hidden but still in the DOM</div>

<!-- When to use which:
     *ngIf:   When the element is expensive (has subscriptions, API calls)
              or when you want ngOnInit to re-run when it appears
     [hidden]: When you need frequent toggle and want to preserve state
               (e.g., a form that shouldn't lose its data)
-->
```

---

### 3.3.2 `*ngFor` — Loop/Repeat Elements

**What:** Repeats an element for each item in an array.
**Why:** Most apps display lists — user lists, product cards, menu items, etc.

```typescript
// product-list.component.ts
export class ProductListComponent {
  products = [
    { id: 1, name: 'Laptop', price: 999, inStock: true },
    { id: 2, name: 'Phone', price: 699, inStock: true },
    { id: 3, name: 'Tablet', price: 499, inStock: false },
    { id: 4, name: 'Watch', price: 299, inStock: true },
  ];

  users = ['Alice', 'Bob', 'Charlie', 'Diana'];
}
```

```html
<!-- product-list.component.html -->

<!-- Basic usage -->
<ul>
  <li *ngFor="let product of products">
    {{ product.name }} - ${{ product.price }}
  </li>
</ul>

<!-- With index -->
<ul>
  <li *ngFor="let user of users; let i = index">
    {{ i + 1 }}. {{ user }}
  </li>
</ul>
<!-- Output: 1. Alice, 2. Bob, 3. Charlie, 4. Diana -->

<!-- All available variables -->
<div *ngFor="let product of products;
             let i = index;
             let isFirst = first;
             let isLast = last;
             let isEven = even;
             let isOdd = odd">

  <div [class.highlight]="isFirst"
       [class.striped]="isEven">
    {{ i + 1 }}. {{ product.name }}
    <span *ngIf="isFirst"> (FIRST!)</span>
    <span *ngIf="isLast"> (LAST!)</span>
  </div>
</div>

<!-- Practical example: Product cards -->
<div class="product-grid">
  <div class="product-card" *ngFor="let product of products">
    <h3>{{ product.name }}</h3>
    <p class="price">${{ product.price }}</p>
    <p [class.in-stock]="product.inStock"
       [class.out-of-stock]="!product.inStock">
      {{ product.inStock ? 'In Stock' : 'Out of Stock' }}
    </p>
    <button [disabled]="!product.inStock" (click)="addToCart(product)">
      Add to Cart
    </button>
  </div>
</div>

<!-- Nested loops -->
<div *ngFor="let category of categories">
  <h2>{{ category.name }}</h2>
  <ul>
    <li *ngFor="let item of category.items">
      {{ item }}
    </li>
  </ul>
</div>
```

**`trackBy` — Performance Optimization:**

When Angular re-renders an `*ngFor` list, it destroys and recreates ALL DOM elements by default. `trackBy` tells Angular how to identify each item so it only updates what changed.

```typescript
// Without trackBy: Angular destroys and recreates ALL <li> elements when the array changes
// With trackBy: Angular only updates the items that actually changed

export class ProductListComponent {
  products = [/* ... */];

  // trackBy function — tells Angular to track items by their id
  trackByProductId(index: number, product: any): number {
    return product.id;
  }
}
```

```html
<!-- With trackBy -->
<li *ngFor="let product of products; trackBy: trackByProductId">
  {{ product.name }}
</li>
```

**Why trackBy matters:**
- Without it: Change 1 item in a list of 1000 → Angular recreates 1000 DOM elements
- With it: Change 1 item → Angular updates just that 1 element
- Always use trackBy for lists that change frequently or have many items

---

### 3.3.3 `*ngSwitch` — Multiple Conditions

**What:** Like a JavaScript switch statement, but for templates.
**Why:** Cleaner than multiple `*ngIf` when checking the same variable against many values.

```typescript
// dashboard.component.ts
export class DashboardComponent {
  currentView = 'home';  // 'home', 'profile', 'settings', 'admin'

  switchView(view: string): void {
    this.currentView = view;
  }
}
```

```html
<!-- dashboard.component.html -->

<!-- Navigation -->
<nav>
  <button (click)="switchView('home')">Home</button>
  <button (click)="switchView('profile')">Profile</button>
  <button (click)="switchView('settings')">Settings</button>
  <button (click)="switchView('admin')">Admin</button>
</nav>

<!-- Content changes based on currentView -->
<div [ngSwitch]="currentView">

  <div *ngSwitchCase="'home'">
    <h2>Home Dashboard</h2>
    <p>Welcome to the home page!</p>
  </div>

  <div *ngSwitchCase="'profile'">
    <h2>Your Profile</h2>
    <p>Edit your profile here.</p>
  </div>

  <div *ngSwitchCase="'settings'">
    <h2>Settings</h2>
    <p>Configure your preferences.</p>
  </div>

  <div *ngSwitchCase="'admin'">
    <h2>Admin Panel</h2>
    <p>Manage users and permissions.</p>
  </div>

  <div *ngSwitchDefault>
    <h2>Page Not Found</h2>
    <p>The selected view doesn't exist.</p>
  </div>

</div>
```

**Notice the syntax differences:**
- `[ngSwitch]` — uses property binding (no `*`)
- `*ngSwitchCase` — uses structural directive (has `*`)
- `*ngSwitchDefault` — uses structural directive (has `*`)

---

### 3.3.4 Attribute Directives: `ngClass` and `ngStyle`

**`ngClass` — dynamically add/remove CSS classes:**

```typescript
export class CardComponent {
  isActive = true;
  isHighlighted = false;
  status = 'success'; // 'success', 'warning', 'error'
  theme = 'dark';
}
```

```html
<!-- Method 1: Single class toggle -->
<div [class.active]="isActive">Toggle single class</div>

<!-- Method 2: ngClass with an object (most common) -->
<div [ngClass]="{
  'active': isActive,
  'highlighted': isHighlighted,
  'dark-theme': theme === 'dark'
}">
  Multiple conditional classes
</div>

<!-- Method 3: ngClass with an array -->
<div [ngClass]="['base-class', status === 'success' ? 'text-green' : 'text-red']">
  Array of classes
</div>

<!-- Method 4: ngClass with a string -->
<div [ngClass]="'class1 class2 class3'">
  Space-separated classes
</div>

<!-- Practical example: status badge -->
<span [ngClass]="{
  'badge': true,
  'badge-success': status === 'success',
  'badge-warning': status === 'warning',
  'badge-error': status === 'error'
}">
  {{ status }}
</span>
```

**`ngStyle` — dynamically set inline styles:**

```typescript
export class StyledComponent {
  fontSize = 16;
  textColor = '#333';
  bgColor = '#fff';
  isImportant = true;
}
```

```html
<!-- Method 1: Single style -->
<div [style.color]="textColor">Single style</div>
<div [style.font-size.px]="fontSize">With unit</div>

<!-- Method 2: ngStyle with an object -->
<div [ngStyle]="{
  'color': textColor,
  'background-color': bgColor,
  'font-size.px': fontSize,
  'font-weight': isImportant ? 'bold' : 'normal',
  'padding.px': 10
}">
  Multiple dynamic styles
</div>

<!-- Practical: progress bar -->
<div class="progress-bar">
  <div class="progress-fill"
       [ngStyle]="{ 'width.%': progressPercent, 'background-color': getProgressColor() }">
    {{ progressPercent }}%
  </div>
</div>
```

**`ngClass` vs `ngStyle` — when to use which?**
- **`ngClass`:** When you have predefined CSS classes. Preferred for maintainability.
- **`ngStyle`:** When styles need to be computed dynamically (e.g., width based on data). Use sparingly.

---

### 3.3.5 Creating a Custom Directive

You can create your own attribute directives!

```bash
ng generate directive highlight
# or
ng g d highlight
```

```typescript
// highlight.directive.ts
import { Directive, ElementRef, HostListener, Input } from '@angular/core';

@Directive({
  selector: '[appHighlight]'  // Usage: <p appHighlight>text</p>
})
export class HighlightDirective {
  // Input to customize the highlight color
  @Input() appHighlight = 'yellow';  // Default color
  @Input() highlightTextColor = 'black';

  // ElementRef gives us access to the DOM element
  constructor(private el: ElementRef) { }

  // Listen for mouse events on the host element
  @HostListener('mouseenter') onMouseEnter() {
    this.highlight(this.appHighlight, this.highlightTextColor);
  }

  @HostListener('mouseleave') onMouseLeave() {
    this.highlight('', '');
  }

  private highlight(bgColor: string, textColor: string) {
    this.el.nativeElement.style.backgroundColor = bgColor;
    this.el.nativeElement.style.color = textColor;
  }
}
```

**Using the custom directive:**
```html
<!-- Default yellow highlight -->
<p appHighlight>Hover over me — I'll turn yellow!</p>

<!-- Custom color highlight -->
<p [appHighlight]="'lightblue'" [highlightTextColor]="'white'">
  Hover over me — I'll turn light blue!
</p>

<!-- Dynamic color from component -->
<p [appHighlight]="userColor">
  Hover over me — color comes from the component!
</p>
```

**Explanation of key concepts:**
- `@Directive({ selector: '[appHighlight]' })` — the `[]` means it's an ATTRIBUTE selector (not a tag)
- `ElementRef` — gives direct access to the DOM element the directive is on
- `@HostListener` — listens for events on the element that has the directive
- `@Input()` — lets you pass values to the directive

---

## 3.4 Pipes — Transforming Display Data

### What are Pipes?

Pipes **transform data for display** WITHOUT changing the underlying data. They're used in templates with the `|` symbol.

**Think of it like a water pipe:** data flows in one end, gets transformed, and comes out the other end.

```
Raw Data ──→ | Pipe | ──→ Formatted Display
"john doe"   uppercase    "JOHN DOE"
1234.5       currency     "$1,234.50"
Date object  date         "Feb 13, 2026"
```

---

### 3.4.1 Built-in Pipes

```typescript
// pipes-demo.component.ts
export class PipesDemoComponent {
  name = 'john doe';
  price = 1234.567;
  today = new Date();
  birthday = new Date(1990, 5, 15);
  user = { name: 'John', age: 30, email: 'john@test.com' };
  percentage = 0.856;
  largeNumber = 1234567890;
  items = ['Angular', 'React', 'Vue'];
  text = 'This is a long paragraph that should be truncated at some point for display purposes.';
}
```

```html
<!-- pipes-demo.component.html -->

<!-- === UPPERCASE / LOWERCASE / TITLECASE === -->
<p>{{ name | uppercase }}</p>          <!-- JOHN DOE -->
<p>{{ name | lowercase }}</p>          <!-- john doe -->
<p>{{ name | titlecase }}</p>          <!-- John Doe -->

<!-- === DATE PIPE (very commonly used) === -->
<p>{{ today | date }}</p>              <!-- Feb 13, 2026 (default format) -->
<p>{{ today | date:'short' }}</p>      <!-- 2/13/26, 12:00 AM -->
<p>{{ today | date:'medium' }}</p>     <!-- Feb 13, 2026, 12:00:00 AM -->
<p>{{ today | date:'long' }}</p>       <!-- February 13, 2026 at 12:00:00 AM GMT+5 -->
<p>{{ today | date:'full' }}</p>       <!-- Friday, February 13, 2026 at 12:00:00 AM -->
<p>{{ today | date:'shortDate' }}</p>  <!-- 2/13/26 -->
<p>{{ today | date:'longDate' }}</p>   <!-- February 13, 2026 -->

<!-- Custom date formats -->
<p>{{ today | date:'dd/MM/yyyy' }}</p>       <!-- 13/02/2026 -->
<p>{{ today | date:'yyyy-MM-dd' }}</p>       <!-- 2026-02-13 -->
<p>{{ today | date:'dd MMM yyyy' }}</p>      <!-- 13 Feb 2026 -->
<p>{{ today | date:'EEEE, dd MMMM' }}</p>    <!-- Friday, 13 February -->
<p>{{ today | date:'hh:mm a' }}</p>          <!-- 12:00 AM -->

<!-- === CURRENCY PIPE === -->
<p>{{ price | currency }}</p>                <!-- $1,234.57 (default USD) -->
<p>{{ price | currency:'EUR' }}</p>          <!-- €1,234.57 -->
<p>{{ price | currency:'GBP':'symbol' }}</p> <!-- £1,234.57 -->
<p>{{ price | currency:'INR' }}</p>          <!-- ₹1,234.57 -->
<p>{{ price | currency:'USD':'symbol':'1.0-0' }}</p>  <!-- $1,235 (no decimals) -->

<!-- === NUMBER / DECIMAL PIPE === -->
<p>{{ price | number }}</p>                  <!-- 1,234.567 -->
<p>{{ price | number:'1.2-2' }}</p>          <!-- 1,234.57 -->
<!-- Format: 'minIntDigits.minFracDigits-maxFracDigits' -->
<p>{{ price | number:'4.1-3' }}</p>          <!-- 1,234.567 -->
<p>{{ price | number:'1.0-0' }}</p>          <!-- 1,235 (rounded) -->

<!-- === PERCENT PIPE === -->
<p>{{ percentage | percent }}</p>             <!-- 86% -->
<p>{{ percentage | percent:'1.1-2' }}</p>     <!-- 85.60% -->

<!-- === JSON PIPE (great for debugging!) === -->
<pre>{{ user | json }}</pre>
<!-- Output:
{
  "name": "John",
  "age": 30,
  "email": "john@test.com"
}
-->

<!-- === SLICE PIPE (like Array.slice) === -->
<p>{{ items | slice:0:2 }}</p>               <!-- Angular,React -->
<p>{{ text | slice:0:30 }}...</p>            <!-- This is a long paragraph th... -->

<!-- === KEYVALUE PIPE (iterate over objects) === -->
<div *ngFor="let item of user | keyvalue">
  {{ item.key }}: {{ item.value }}
</div>
<!-- Output: age: 30, email: john@test.com, name: John -->
```

---

### 3.4.2 Chaining Pipes

You can chain multiple pipes — the output of one becomes the input of the next:

```html
<!-- Chain: first apply date, then uppercase -->
<p>{{ birthday | date:'fullDate' | uppercase }}</p>
<!-- FRIDAY, JUNE 15, 1990 -->

<!-- Chain: slice then uppercase -->
<p>{{ name | slice:0:4 | uppercase }}</p>
<!-- JOHN -->
```

---

### 3.4.3 Creating a Custom Pipe

```bash
ng generate pipe truncate
# or
ng g p truncate
```

**Example: A pipe that truncates long text:**

```typescript
// truncate.pipe.ts
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'truncate'  // This is the name you use in templates
})
export class TruncatePipe implements PipeTransform {

  // The transform method is REQUIRED
  // value = the data being piped
  // limit = optional parameter (default 50)
  // trail = what to append when truncated (default '...')
  transform(value: string, limit: number = 50, trail: string = '...'): string {
    // Safety check
    if (!value) return '';

    // If text is shorter than limit, return as-is
    if (value.length <= limit) return value;

    // Otherwise, truncate and add trail
    return value.substring(0, limit) + trail;
  }
}
```

**Using the custom pipe:**
```html
<!-- Default: truncate at 50 characters with '...' -->
<p>{{ longText | truncate }}</p>

<!-- Custom limit: truncate at 20 characters -->
<p>{{ longText | truncate:20 }}</p>

<!-- Custom limit AND trail -->
<p>{{ longText | truncate:30:'---' }}</p>
```

**Another example: A pipe that filters an array:**

```typescript
// filter.pipe.ts
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filter'
})
export class FilterPipe implements PipeTransform {
  transform(items: any[], searchText: string, property: string): any[] {
    if (!items) return [];
    if (!searchText) return items;

    searchText = searchText.toLowerCase();

    return items.filter(item => {
      return item[property].toLowerCase().includes(searchText);
    });
  }
}
```

```html
<!-- Filter products by name based on searchTerm -->
<input [(ngModel)]="searchTerm" placeholder="Search products...">

<div *ngFor="let product of products | filter:searchTerm:'name'">
  {{ product.name }} - ${{ product.price }}
</div>
```

**Another example: A time-ago pipe:**

```typescript
// time-ago.pipe.ts
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'timeAgo'
})
export class TimeAgoPipe implements PipeTransform {
  transform(value: Date): string {
    if (!value) return '';

    const now = new Date();
    const seconds = Math.floor((now.getTime() - new Date(value).getTime()) / 1000);

    if (seconds < 60) return 'just now';
    if (seconds < 3600) return Math.floor(seconds / 60) + ' minutes ago';
    if (seconds < 86400) return Math.floor(seconds / 3600) + ' hours ago';
    if (seconds < 2592000) return Math.floor(seconds / 86400) + ' days ago';
    if (seconds < 31536000) return Math.floor(seconds / 2592000) + ' months ago';
    return Math.floor(seconds / 31536000) + ' years ago';
  }
}
```

```html
<p>Posted {{ post.createdAt | timeAgo }}</p>
<!-- Output: "Posted 3 hours ago" -->
```

---

### 3.4.4 Pure vs Impure Pipes

```typescript
// PURE pipe (default) — only runs when the INPUT REFERENCE changes
@Pipe({ name: 'myPipe', pure: true })  // pure: true is the default

// IMPURE pipe — runs on EVERY change detection cycle
@Pipe({ name: 'myPipe', pure: false })
```

**When does each run?**
- **Pure:** Only when the input value's REFERENCE changes (new string, new array reference)
- **Impure:** Every time Angular runs change detection (can be many times per second)

**Example of the problem:**
```typescript
// This array is being mutated (push), not replaced
this.items.push('new item');  // Same reference! Pure pipe won't notice

// This creates a NEW array (new reference) — pure pipe WILL notice
this.items = [...this.items, 'new item'];
```

**Rule of thumb:**
- Use **pure** pipes (default) for most cases — better performance
- Use **impure** pipes only when you MUST react to internal mutations (rare)
- Better approach: instead of impure pipes, create new array references when data changes

---

## 3.5 `ng-template` and `ng-container`

### `<ng-template>` — Invisible Template Block

`ng-template` defines a piece of HTML that is NOT rendered by default. It's only rendered when explicitly told to (via `*ngIf`, `*ngFor`, or programmatically).

```html
<!-- This template is NOT rendered until referenced -->
<ng-template #greeting>
  <h2>Hello, World!</h2>
  <p>This is a template block</p>
</ng-template>

<!-- Used with *ngIf else -->
<div *ngIf="isLoggedIn; else loginTpl">
  Welcome back!
</div>
<ng-template #loginTpl>
  <p>Please log in</p>
</ng-template>
```

### `<ng-container>` — Invisible Wrapper

`ng-container` is a grouping element that doesn't create any extra DOM element. It's perfect when you need a structural directive but don't want an extra `<div>`.

```html
<!-- Problem: extra unwanted <div> in the DOM -->
<div *ngIf="isLoggedIn">
  <span>Welcome, {{ user.name }}</span>
</div>

<!-- Solution: ng-container doesn't create any DOM element -->
<ng-container *ngIf="isLoggedIn">
  <span>Welcome, {{ user.name }}</span>
</ng-container>

<!-- Useful when you need TWO structural directives on the same element -->
<!-- THIS DOESN'T WORK: -->
<!-- <div *ngIf="isVisible" *ngFor="let item of items">{{ item }}</div> -->

<!-- THIS WORKS: -->
<ng-container *ngIf="isVisible">
  <div *ngFor="let item of items">{{ item }}</div>
</ng-container>

<!-- Useful in tables (where extra divs would break the structure) -->
<table>
  <tr *ngFor="let user of users">
    <ng-container *ngIf="user.active">
      <td>{{ user.name }}</td>
      <td>{{ user.email }}</td>
    </ng-container>
  </tr>
</table>
```

---

## 3.6 Summary

| Concept | What You Learned |
|---|---|
| Components | Self-contained UI pieces (class + template + styles) |
| `ng g c name` | Generate a new component |
| Lifecycle Hooks | `ngOnInit` (setup), `ngOnDestroy` (cleanup), `ngOnChanges` (input changes) |
| Interpolation `{{ }}` | Display component data in template |
| Property Binding `[]` | Bind component properties to HTML attributes |
| Event Binding `()` | Handle user actions (click, input, etc.) |
| Two-Way Binding `[()]` | Keep input and property in sync |
| `*ngIf` | Conditionally show/hide elements |
| `*ngFor` | Repeat elements for each item in an array |
| `*ngSwitch` | Show one of many elements based on a value |
| `ngClass` / `ngStyle` | Dynamically apply classes/styles |
| Custom Directives | Create your own reusable DOM behaviors |
| Built-in Pipes | Transform data for display (date, currency, etc.) |
| Custom Pipes | Create your own data transformations |
| `ng-template` | Define reusable template blocks |
| `ng-container` | Group elements without extra DOM nodes |

---

**Next:** [Phase 4 — Component Communication](./Phase04-Component-Communication.md)
