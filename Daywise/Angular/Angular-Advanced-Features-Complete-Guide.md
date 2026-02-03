# Angular Advanced Features vs ReactJS: Complete Study Guide

> **Single Source of Truth for Studying Angular 14-17+ Features**  
> This comprehensive guide covers all modern Angular features with detailed code examples, inline comments, explanations, and direct comparisons to ReactJS.

---

## Table of Contents
1. [Critical Modern Features (Angular 16-17+)](#critical-modern-features)
2. [Core Concepts](#core-concepts)
3. [Advanced Features](#advanced-features)
4. [Routing Features](#routing-features)
5. [Tooling & DevOps](#tooling-devops)

---

## 🔴 Critical Modern Features (Angular 16-17+) {#critical-modern-features}

### 1. Signals (Angular 16+)

**Description:** Signals are Angular's new built-in reactive primitive for state management, enabling fine-grained reactivity and efficient change detection. They provide a more performant alternative to traditional observables for simple state management.

#### Angular: Full Example with Signals

```typescript
// counter.component.ts
import { Component, signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <div class="counter-container">
      <h2>Angular Signals Counter</h2>
      
      <!-- Reading signal values in template requires () -->
      <div class="display">
        <p>Count: {{ count() }}</p>
        <p>Double: {{ double() }}</p>
        <p>Is Even: {{ isEven() ? 'Yes' : 'No' }}</p>
      </div>
      
      <div class="controls">
        <button (click)="increment()">Increment</button>
        <button (click)="decrement()">Decrement</button>
        <button (click)="reset()">Reset</button>
      </div>
      
      <p class="status">{{ statusMessage() }}</p>
    </div>
  `,
  styles: [`
    .counter-container { padding: 20px; border: 2px solid #007bff; }
    .display { font-size: 1.2em; margin: 10px 0; }
    .controls button { margin: 5px; padding: 10px 20px; }
  `]
})
export class CounterComponent {
  // Create a writable signal - this is the source of truth for count
  count = signal(0);
  
  // Computed signals automatically update when dependencies change
  // These are read-only and cached until dependencies change
  double = computed(() => this.count() * 2);
  isEven = computed(() => this.count() % 2 === 0);
  
  // Computed signal with multiple dependencies
  statusMessage = computed(() => {
    const value = this.count();
    if (value === 0) return 'Starting point';
    if (value > 0) return `Positive: ${value}`;
    return `Negative: ${value}`;
  });

  constructor() {
    // Effects run automatically when any signal they read changes
    // This is useful for side effects like logging, API calls, etc.
    effect(() => {
      console.log('Count changed to:', this.count());
      console.log('Double is now:', this.double());
    });
    
    // Effects can also perform cleanup
    effect((onCleanup) => {
      const currentCount = this.count();
      const timer = setTimeout(() => {
        console.log('Delayed log:', currentCount);
      }, 1000);
      
      // Cleanup function runs before next effect execution
      onCleanup(() => clearTimeout(timer));
    });
  }

  // Methods to update the signal
  increment() {
    // Use .set() to replace the value
    this.count.set(this.count() + 1);
    
    // Or use .update() to transform the current value
    // this.count.update(current => current + 1);
  }

  decrement() {
    this.count.update(current => current - 1);
  }

  reset() {
    this.count.set(0);
  }
}
```

**Advanced Signals Example: Todo List**

```typescript
// todo-list.component.ts
import { Component, signal, computed } from '@angular/core';

interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

@Component({
  selector: 'app-todo-list',
  standalone: true,
  template: `
    <div class="todo-app">
      <h2>Todo List with Signals</h2>
      
      <input 
        #todoInput 
        (keyup.enter)="addTodo(todoInput.value); todoInput.value=''"
        placeholder="Add a todo..." 
      />
      
      <div class="stats">
        <p>Total: {{ totalCount() }}</p>
        <p>Active: {{ activeCount() }}</p>
        <p>Completed: {{ completedCount() }}</p>
      </div>
      
      <ul>
        @for (todo of todos(); track todo.id) {
          <li [class.completed]="todo.completed">
            <input 
              type="checkbox" 
              [checked]="todo.completed"
              (change)="toggleTodo(todo.id)"
            />
            <span>{{ todo.text }}</span>
            <button (click)="removeTodo(todo.id)">Delete</button>
          </li>
        }
      </ul>
    </div>
  `
})
export class TodoListComponent {
  // Signal holding an array of todos
  todos = signal<Todo[]>([
    { id: 1, text: 'Learn Signals', completed: false },
    { id: 2, text: 'Build an app', completed: false }
  ]);
  
  private nextId = signal(3);
  
  // Computed signals for derived state
  totalCount = computed(() => this.todos().length);
  activeCount = computed(() => this.todos().filter(t => !t.completed).length);
  completedCount = computed(() => this.todos().filter(t => t.completed).length);

  addTodo(text: string) {
    if (text.trim()) {
      // Use .update() to modify the array immutably
      this.todos.update(current => [
        ...current,
        { id: this.nextId(), text, completed: false }
      ]);
      this.nextId.update(id => id + 1);
    }
  }

  toggleTodo(id: number) {
    this.todos.update(current =>
      current.map(todo =>
        todo.id === id ? { ...todo, completed: !todo.completed } : todo
      )
    );
  }

  removeTodo(id: number) {
    this.todos.update(current => current.filter(todo => todo.id !== id));
  }
}
```

#### React: Equivalent Counter with useState/useEffect

```jsx
// Counter.jsx
import React, { useState, useEffect, useMemo } from 'react';

function Counter() {
  // State variable - equivalent to signal()
  const [count, setCount] = useState(0);
  
  // Derived state - equivalent to computed()
  // useMemo caches the value until dependencies change
  const double = useMemo(() => count * 2, [count]);
  const isEven = useMemo(() => count % 2 === 0, [count]);
  
  const statusMessage = useMemo(() => {
    if (count === 0) return 'Starting point';
    if (count > 0) return `Positive: ${count}`;
    return `Negative: ${count}`;
  }, [count]);

  // Side effects - equivalent to effect()
  useEffect(() => {
    console.log('Count changed to:', count);
    console.log('Double is now:', double);
  }, [count, double]);
  
  // Effect with cleanup
  useEffect(() => {
    const timer = setTimeout(() => {
      console.log('Delayed log:', count);
    }, 1000);
    
    // Cleanup function
    return () => clearTimeout(timer);
  }, [count]);

  const increment = () => setCount(count + 1);
  const decrement = () => setCount(count - 1);
  const reset = () => setCount(0);

  return (
    <div className="counter-container" style={{ padding: '20px', border: '2px solid #007bff' }}>
      <h2>React Counter</h2>
      
      <div className="display" style={{ fontSize: '1.2em', margin: '10px 0' }}>
        <p>Count: {count}</p>
        <p>Double: {double}</p>
        <p>Is Even: {isEven ? 'Yes' : 'No'}</p>
      </div>
      
      <div className="controls">
        <button onClick={increment} style={{ margin: '5px', padding: '10px 20px' }}>
          Increment
        </button>
        <button onClick={decrement} style={{ margin: '5px', padding: '10px 20px' }}>
          Decrement
        </button>
        <button onClick={reset} style={{ margin: '5px', padding: '10px 20px' }}>
          Reset
        </button>
      </div>
      
      <p className="status">{statusMessage}</p>
    </div>
  );
}

export default Counter;
```

**React: Todo List Equivalent**

```jsx
// TodoList.jsx
import React, { useState, useMemo } from 'react';

function TodoList() {
  const [todos, setTodos] = useState([
    { id: 1, text: 'Learn React', completed: false },
    { id: 2, text: 'Build an app', completed: false }
  ]);
  const [nextId, setNextId] = useState(3);
  const [inputValue, setInputValue] = useState('');
  
  // Derived state with useMemo
  const totalCount = useMemo(() => todos.length, [todos]);
  const activeCount = useMemo(() => todos.filter(t => !t.completed).length, [todos]);
  const completedCount = useMemo(() => todos.filter(t => t.completed).length, [todos]);

  const addTodo = () => {
    if (inputValue.trim()) {
      setTodos([...todos, { id: nextId, text: inputValue, completed: false }]);
      setNextId(nextId + 1);
      setInputValue('');
    }
  };

  const toggleTodo = (id) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  };

  const removeTodo = (id) => {
    setTodos(todos.filter(todo => todo.id !== id));
  };

  return (
    <div className="todo-app">
      <h2>Todo List with React</h2>
      
      <input
        value={inputValue}
        onChange={(e) => setInputValue(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && addTodo()}
        placeholder="Add a todo..."
      />
      
      <div className="stats">
        <p>Total: {totalCount}</p>
        <p>Active: {activeCount}</p>
        <p>Completed: {completedCount}</p>
      </div>
      
      <ul>
        {todos.map(todo => (
          <li key={todo.id} className={todo.completed ? 'completed' : ''}>
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => toggleTodo(todo.id)}
            />
            <span>{todo.text}</span>
            <button onClick={() => removeTodo(todo.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default TodoList;
```

#### Comparison: Signals vs useState/useMemo

| Feature | Angular Signals | React useState/useMemo |
|---------|----------------|------------------------|
| **State Declaration** | `signal(value)` | `useState(value)` |
| **Reading Value** | `count()` (function call) | `count` (direct access) |
| **Updating Value** | `.set()` or `.update()` | `setState()` |
| **Derived State** | `computed()` (automatic) | `useMemo()` (manual deps) |
| **Side Effects** | `effect()` (automatic tracking) | `useEffect()` (manual deps) |
| **Performance** | Fine-grained reactivity | Component-level re-renders |
| **Granularity** | Updates only affected parts | Re-renders entire component |
| **Outside Components** | ✅ Can be used anywhere | ❌ Only in function components |
| **Auto Cleanup** | ✅ Built-in | ⚠️ Manual return function |

**Key Differences:**
1. **Granularity:** Angular signals update only the specific parts of the template that depend on them, while React re-renders the entire component.
2. **Dependency Tracking:** Angular signals automatically track dependencies in `computed()` and `effect()`, while React requires manual dependency arrays.
3. **Flexibility:** Signals can be created and used outside components (e.g., in services), while React hooks are limited to function components.
4. **Syntax:** Angular requires `()` to read signal values, React accesses values directly.

**When to Use:**
- **Angular Signals:** For fine-grained reactivity, shared state in services, or when you want automatic dependency tracking.
- **React Hooks:** For component-local state, when you need the flexibility of the React ecosystem.

**Further Reading:**
- [Angular Signals Documentation](https://angular.dev/guide/signals)
- [React useState Hook](https://react.dev/reference/react/useState)
- [React useMemo Hook](https://react.dev/reference/react/useMemo)

---

### 2. Standalone Components (Angular 14+)

**Description:** Standalone components eliminate the need for NgModules, allowing you to create self-contained components with their own dependencies. This drastically simplifies Angular's architecture and makes it more similar to React's component model.

#### Angular: Full Standalone Component Example

**Basic Standalone Component:**

```typescript
// user-card.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common'; // Provides *ngIf, *ngFor, pipes, etc.
import { FormsModule } from '@angular/forms'; // Provides ngModel for two-way binding

@Component({
  selector: 'app-user-card',
  standalone: true, // This is the key: no NgModule needed!
  imports: [
    CommonModule,  // Import directives and pipes
    FormsModule    // Import form directives
  ],
  template: `
    <div class="user-card">
      <div class="header">
        <h3>{{ user.name }}</h3>
        <span class="badge" [class.active]="user.isActive">
          {{ user.isActive ? 'Active' : 'Inactive' }}
        </span>
      </div>
      
      <!-- Using CommonModule's *ngIf -->
      <div class="details" *ngIf="showDetails">
        <p><strong>Email:</strong> {{ user.email }}</p>
        <p><strong>Role:</strong> {{ user.role }}</p>
        <p><strong>Joined:</strong> {{ user.joinedDate | date:'medium' }}</p>
      </div>
      
      <!-- Using FormsModule's ngModel -->
      <div class="edit-mode" *ngIf="isEditing">
        <input [(ngModel)]="user.name" placeholder="Name" />
        <input [(ngModel)]="user.email" placeholder="Email" />
      </div>
      
      <div class="actions">
        <button (click)="toggleDetails()">
          {{ showDetails ? 'Hide' : 'Show' }} Details
        </button>
        <button (click)="toggleEdit()">
          {{ isEditing ? 'Save' : 'Edit' }}
        </button>
        <button (click)="toggleActive()" [class.danger]="user.isActive">
          {{ user.isActive ? 'Deactivate' : 'Activate' }}
        </button>
      </div>
    </div>
  `,
  styles: [`
    .user-card {
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 16px;
      margin: 10px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }
    .badge {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 0.8em;
      background-color: #ccc;
    }
    .badge.active {
      background-color: #28a745;
      color: white;
    }
    .actions button {
      margin: 5px;
      padding: 8px 12px;
    }
    .danger {
      background-color: #dc3545;
      color: white;
    }
  `]
})
export class UserCardComponent {
  user = {
    name: 'John Doe',
    email: 'john@example.com',
    role: 'Developer',
    isActive: true,
    joinedDate: new Date('2023-01-15')
  };
  
  showDetails = false;
  isEditing = false;

  toggleDetails() {
    this.showDetails = !this.showDetails;
  }

  toggleEdit() {
    this.isEditing = !this.isEditing;
  }

  toggleActive() {
    this.user.isActive = !this.user.isActive;
  }
}
```

**Using the Standalone Component:**

```typescript
// app.component.ts
import { Component } from '@angular/core';
import { UserCardComponent } from './user-card.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [UserCardComponent], // Simply import the component
  template: `
    <div class="app-container">
      <h1>User Management</h1>
      <app-user-card></app-user-card>
      <app-user-card></app-user-card>
    </div>
  `
})
export class AppComponent {}
```

**Bootstrap the App (main.ts):**

```typescript
// main.ts
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';

// No NgModule needed! Bootstrap directly with a component
bootstrapApplication(AppComponent, {
  providers: [
    // Add global providers here if needed
  ]
}).catch(err => console.error(err));
```

**Standalone Component with Services:**

```typescript
// data.service.ts
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root' // Makes service available app-wide
})
export class DataService {
  getUsers() {
    return [
      { id: 1, name: 'Alice' },
      { id: 2, name: 'Bob' }
    ];
  }
}

// user-list.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DataService } from './data.service';

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <ul>
      <li *ngFor="let user of users">{{ user.name }}</li>
    </ul>
  `
})
export class UserListComponent implements OnInit {
  users: any[] = [];

  // Inject service via constructor (traditional way)
  constructor(private dataService: DataService) {}

  ngOnInit() {
    this.users = this.dataService.getUsers();
  }
}
```

#### React: Equivalent Component

```jsx
// UserCard.jsx
import React, { useState } from 'react';
import './UserCard.css'; // External styles

function UserCard() {
  const [user, setUser] = useState({
    name: 'John Doe',
    email: 'john@example.com',
    role: 'Developer',
    isActive: true,
    joinedDate: new Date('2023-01-15')
  });
  
  const [showDetails, setShowDetails] = useState(false);
  const [isEditing, setIsEditing] = useState(false);

  const toggleDetails = () => setShowDetails(!showDetails);
  const toggleEdit = () => setIsEditing(!isEditing);
  const toggleActive = () => setUser({ ...user, isActive: !user.isActive });

  return (
    <div className="user-card">
      <div className="header">
        <h3>{user.name}</h3>
        <span className={`badge ${user.isActive ? 'active' : ''}`}>
          {user.isActive ? 'Active' : 'Inactive'}
        </span>
      </div>
      
      {/* Conditional rendering */}
      {showDetails && (
        <div className="details">
          <p><strong>Email:</strong> {user.email}</p>
          <p><strong>Role:</strong> {user.role}</p>
          <p><strong>Joined:</strong> {user.joinedDate.toLocaleString()}</p>
        </div>
      )}
      
      {/* Edit mode */}
      {isEditing && (
        <div className="edit-mode">
          <input
            value={user.name}
            onChange={(e) => setUser({ ...user, name: e.target.value })}
            placeholder="Name"
          />
          <input
            value={user.email}
            onChange={(e) => setUser({ ...user, email: e.target.value })}
            placeholder="Email"
          />
        </div>
      )}
      
      <div className="actions">
        <button onClick={toggleDetails}>
          {showDetails ? 'Hide' : 'Show'} Details
        </button>
        <button onClick={toggleEdit}>
          {isEditing ? 'Save' : 'Edit'}
        </button>
        <button 
          onClick={toggleActive}
          className={user.isActive ? 'danger' : ''}
        >
          {user.isActive ? 'Deactivate' : 'Activate'}
        </button>
      </div>
    </div>
  );
}

export default UserCard;
```

```jsx
// App.jsx
import React from 'react';
import UserCard from './UserCard';

function App() {
  return (
    <div className="app-container">
      <h1>User Management</h1>
      <UserCard />
      <UserCard />
    </div>
  );
}

export default App;
```

**React with Services (Context API):**

```jsx
// DataContext.jsx
import React, { createContext, useContext } from 'react';

const DataContext = createContext();

export function DataProvider({ children }) {
  const getUsers = () => [
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' }
  ];

  return (
    <DataContext.Provider value={{ getUsers }}>
      {children}
    </DataContext.Provider>
  );
}

export function useData() {
  return useContext(DataContext);
}

// UserList.jsx
import React, { useState, useEffect } from 'react';
import { useData } from './DataContext';

function UserList() {
  const [users, setUsers] = useState([]);
  const { getUsers } = useData();

  useEffect(() => {
    setUsers(getUsers());
  }, [getUsers]);

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}

export default UserList;
```

#### Comparison: Standalone Components

| Aspect | Angular (Before v14) | Angular (v14+ Standalone) | React |
|--------|---------------------|---------------------------|-------|
| **Module System** | Required NgModule | No NgModule needed | No module system |
| **Imports** | Declared in NgModule | Declared in component | Import at top of file |
| **Boilerplate** | High (module files) | Low (component only) | Very low |
| **Component Portability** | Low (tied to module) | High (self-contained) | Very high |
| **Learning Curve** | Steep (modules + components) | Moderate (components) | Low (just components) |
| **Dependencies** | Module-level imports | Component-level imports | File-level imports |

**Key Differences:**
1. **Angular Standalone:** Uses `imports: []` array in the `@Component` decorator to declare dependencies.
2. **React:** Uses ES6 `import` statements at the file level—no special decorator or configuration.
3. **Migration:** Angular standalone components are a step toward making Angular more like React, reducing boilerplate and complexity.

**When to Use:**
- **Angular Standalone:** Always use for new Angular 14+ projects. Simpler, more maintainable, and aligned with modern practices.
- **React:** Default approach—all React components are already standalone.

**Further Reading:**
- [Angular Standalone Components Guide](https://angular.dev/guide/components/importing)
- [React Component Basics](https://react.dev/learn/your-first-component)

---

### 3. New Control Flow (@if, @for, @switch, @empty) (Angular 17+)

**Description:** Angular 17 introduced a revolutionary new template syntax for control flow that closely resembles JavaScript syntax, replacing the older `*ngIf`, `*ngFor`, and `*ngSwitch` structural directives. This makes templates more intuitive and easier to read.

#### Angular: Full Control Flow Example

```typescript
// product-list.component.ts
import { Component, signal, computed } from '@angular/core';
import { CommonModule } from '@angular/common';

interface Product {
  id: number;
  name: string;
  price: number;
  category: 'electronics' | 'clothing' | 'food';
  inStock: boolean;
  rating: number;
}

type FilterType = 'all' | 'inStock' | 'outOfStock';
type SortType = 'name' | 'price' | 'rating';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="product-list-container">
      <h2>Product Catalog</h2>

      <!-- Filters and Controls -->
      <div class="controls">
        <select [(ngModel)]="filterType">
          <option value="all">All Products</option>
          <option value="inStock">In Stock Only</option>
          <option value="outOfStock">Out of Stock Only</option>
        </select>
        
        <select [(ngModel)]="sortBy">
          <option value="name">Sort by Name</option>
          <option value="price">Sort by Price</option>
          <option value="rating">Sort by Rating</option>
        </select>
        
        <button (click)="toggleLoading()">Toggle Loading</button>
      </div>

      <!-- Loading State with @if -->
      @if (isLoading()) {
        <div class="loading">
          <div class="spinner"></div>
          <p>Loading products...</p>
        </div>
      } @else {
        <!-- Main Product List with @for and @empty -->
        <div class="products-grid">
          @for (product of filteredProducts(); track product.id) {
            <div class="product-card">
              <h3>{{ product.name }}</h3>
              <p class="price">${{ product.price }}</p>
              
              <!-- Category Badge with @switch -->
              @switch (product.category) {
                @case ('electronics') {
                  <span class="badge badge-blue">📱 Electronics</span>
                }
                @case ('clothing') {
                  <span class="badge badge-purple">👕 Clothing</span>
                }
                @case ('food') {
                  <span class="badge badge-green">🍔 Food</span>
                }
                @default {
                  <span class="badge badge-gray">📦 Other</span>
                }
              }
              
              <!-- Stock Status with @if/@else -->
              @if (product.inStock) {
                <div class="stock in-stock">
                  <span class="icon">✓</span>
                  <span>In Stock</span>
                </div>
              } @else {
                <div class="stock out-of-stock">
                  <span class="icon">✗</span>
                  <span>Out of Stock</span>
                </div>
              }
              
              <!-- Rating Stars with nested @for -->
              <div class="rating">
                @for (star of [1,2,3,4,5]; track star) {
                  @if (star <= product.rating) {
                    <span class="star filled">★</span>
                  } @else {
                    <span class="star empty">☆</span>
                  }
                }
              </div>
              
              <button 
                [disabled]="!product.inStock"
                (click)="addToCart(product)"
              >
                Add to Cart
              </button>
            </div>
          } @empty {
            <!-- Shown when filtered list is empty -->
            <div class="empty-state">
              <h3>No products found</h3>
              <p>Try adjusting your filters</p>
              <button (click)="resetFilters()">Reset Filters</button>
            </div>
          }
        </div>
        
        <!-- Summary Section -->
        <div class="summary">
          @if (filteredProducts().length > 0) {
            <p>Showing {{ filteredProducts().length }} of {{ products().length }} products</p>
            <p>Total value: ${{ totalValue() }}</p>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .product-list-container { padding: 20px; }
    .controls { margin: 20px 0; }
    .controls select, .controls button { margin-right: 10px; padding: 8px; }
    .loading { text-align: center; padding: 40px; }
    .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #3498db;
                border-radius: 50%; width: 40px; height: 40px;
                animation: spin 1s linear infinite; margin: 0 auto; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    .products-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                     gap: 20px; margin: 20px 0; }
    .product-card { border: 1px solid #ddd; border-radius: 8px; padding: 16px;
                    background: white; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .badge { padding: 4px 8px; border-radius: 4px; font-size: 0.85em; display: inline-block; }
    .badge-blue { background: #3498db; color: white; }
    .badge-purple { background: #9b59b6; color: white; }
    .badge-green { background: #27ae60; color: white; }
    .badge-gray { background: #95a5a6; color: white; }
    .stock { margin: 10px 0; padding: 8px; border-radius: 4px; }
    .in-stock { background: #d4edda; color: #155724; }
    .out-of-stock { background: #f8d7da; color: #721c24; }
    .rating .star { font-size: 1.2em; }
    .rating .filled { color: #f39c12; }
    .rating .empty { color: #ccc; }
    .empty-state { text-align: center; padding: 60px; grid-column: 1 / -1; }
    .summary { margin-top: 20px; padding: 16px; background: #f8f9fa; border-radius: 8px; }
  `]
})
export class ProductListComponent {
  // State signals
  isLoading = signal(false);
  filterType = signal<FilterType>('all');
  sortBy = signal<SortType>('name');
  
  // Product data
  products = signal<Product[]>([
    { id: 1, name: 'Laptop', price: 999, category: 'electronics', inStock: true, rating: 5 },
    { id: 2, name: 'Mouse', price: 29, category: 'electronics', inStock: false, rating: 4 },
    { id: 3, name: 'T-Shirt', price: 19, category: 'clothing', inStock: true, rating: 3 },
    { id: 4, name: 'Pizza', price: 12, category: 'food', inStock: true, rating: 5 },
    { id: 5, name: 'Headphones', price: 79, category: 'electronics', inStock: true, rating: 4 },
  ]);
  
  // Computed: Filtered and sorted products
  filteredProducts = computed(() => {
    let result = this.products();
    
    // Apply filter
    switch (this.filterType()) {
      case 'inStock':
        result = result.filter(p => p.inStock);
        break;
      case 'outOfStock':
        result = result.filter(p => !p.inStock);
        break;
    }
    
    // Apply sort
    return result.sort((a, b) => {
      switch (this.sortBy()) {
        case 'name':
          return a.name.localeCompare(b.name);
        case 'price':
          return a.price - b.price;
        case 'rating':
          return b.rating - a.rating;
        default:
          return 0;
      }
    });
  });
  
  // Computed: Total value of filtered products
  totalValue = computed(() => 
    this.filteredProducts().reduce((sum, p) => sum + p.price, 0)
  );

  toggleLoading() {
    this.isLoading.set(!this.isLoading());
  }

  resetFilters() {
    this.filterType.set('all');
    this.sortBy.set('name');
  }

  addToCart(product: Product) {
    console.log('Added to cart:', product.name);
  }
}
```

#### React: Equivalent Control Flow

```jsx
// ProductList.jsx
import React, { useState, useMemo } from 'react';
import './ProductList.css';

function ProductList() {
  const [isLoading, setIsLoading] = useState(false);
  const [filterType, setFilterType] = useState('all');
  const [sortBy, setSortBy] = useState('name');
  
  const [products] = useState([
    { id: 1, name: 'Laptop', price: 999, category: 'electronics', inStock: true, rating: 5 },
    { id: 2, name: 'Mouse', price: 29, category: 'electronics', inStock: false, rating: 4 },
    { id: 3, name: 'T-Shirt', price: 19, category: 'clothing', inStock: true, rating: 3 },
    { id: 4, name: 'Pizza', price: 12, category: 'food', inStock: true, rating: 5 },
    { id: 5, name: 'Headphones', price: 79, category: 'electronics', inStock: true, rating: 4 },
  ]);
  
  // Filtered and sorted products (equivalent to computed)
  const filteredProducts = useMemo(() => {
    let result = [...products];
    
    // Apply filter
    if (filterType === 'inStock') {
      result = result.filter(p => p.inStock);
    } else if (filterType === 'outOfStock') {
      result = result.filter(p => !p.inStock);
    }
    
    // Apply sort
    return result.sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.name.localeCompare(b.name);
        case 'price':
          return a.price - b.price;
        case 'rating':
          return b.rating - a.rating;
        default:
          return 0;
      }
    });
  }, [products, filterType, sortBy]);
  
  // Total value (equivalent to computed)
  const totalValue = useMemo(() => 
    filteredProducts.reduce((sum, p) => sum + p.price, 0),
    [filteredProducts]
  );

  const getCategoryBadge = (category) => {
    // Using object mapping (equivalent to @switch)
    const badges = {
      electronics: <span className="badge badge-blue">📱 Electronics</span>,
      clothing: <span className="badge badge-purple">👕 Clothing</span>,
      food: <span className="badge badge-green">🍔 Food</span>
    };
    return badges[category] || <span className="badge badge-gray">📦 Other</span>;
  };

  const renderStars = (rating) => {
    return [1, 2, 3, 4, 5].map(star => (
      <span key={star} className={`star ${star <= rating ? 'filled' : 'empty'}`}>
        {star <= rating ? '★' : '☆'}
      </span>
    ));
  };

  return (
    <div className="product-list-container">
      <h2>Product Catalog</h2>

      <div className="controls">
        <select value={filterType} onChange={(e) => setFilterType(e.target.value)}>
          <option value="all">All Products</option>
          <option value="inStock">In Stock Only</option>
          <option value="outOfStock">Out of Stock Only</option>
        </select>
        
        <select value={sortBy} onChange={(e) => setSortBy(e.target.value)}>
          <option value="name">Sort by Name</option>
          <option value="price">Sort by Price</option>
          <option value="rating">Sort by Rating</option>
        </select>
        
        <button onClick={() => setIsLoading(!isLoading)}>Toggle Loading</button>
      </div>

      {/* Conditional rendering with ternary (equivalent to @if/@else) */}
      {isLoading ? (
        <div className="loading">
          <div className="spinner"></div>
          <p>Loading products...</p>
        </div>
      ) : (
        <>
          <div className="products-grid">
            {/* Loop with map (equivalent to @for) */}
            {filteredProducts.length > 0 ? (
              filteredProducts.map(product => (
                <div key={product.id} className="product-card">
                  <h3>{product.name}</h3>
                  <p className="price">${product.price}</p>
                  
                  {/* Category badge */}
                  {getCategoryBadge(product.category)}
                  
                  {/* Stock status (equivalent to @if/@else) */}
                  {product.inStock ? (
                    <div className="stock in-stock">
                      <span className="icon">✓</span>
                      <span>In Stock</span>
                    </div>
                  ) : (
                    <div className="stock out-of-stock">
                      <span className="icon">✗</span>
                      <span>Out of Stock</span>
                    </div>
                  )}
                  
                  {/* Rating stars */}
                  <div className="rating">{renderStars(product.rating)}</div>
                  
                  <button
                    disabled={!product.inStock}
                    onClick={() => console.log('Added to cart:', product.name)}
                  >
                    Add to Cart
                  </button>
                </div>
              ))
            ) : (
              /* Empty state (equivalent to @empty) */
              <div className="empty-state">
                <h3>No products found</h3>
                <p>Try adjusting your filters</p>
                <button onClick={() => { setFilterType('all'); setSortBy('name'); }}>
                  Reset Filters
                </button>
              </div>
            )}
          </div>
          
          {/* Summary section */}
          {filteredProducts.length > 0 && (
            <div className="summary">
              <p>Showing {filteredProducts.length} of {products.length} products</p>
              <p>Total value: ${totalValue}</p>
            </div>
          )}
        </>
      )}
    </div>
  );
}

export default ProductList;
```

#### Comparison: Control Flow Syntax

| Feature | Angular 17+ | Angular Legacy | React |
|---------|-------------|----------------|-------|
| **Conditional** | `@if {...} @else {...}` | `*ngIf="condition"` | `{condition ? ... : ...}` or `{condition && ...}` |
| **Loop** | `@for (item of items; track item.id) {...}` | `*ngFor="let item of items; trackBy: trackFn"` | `{items.map(item => <div key={item.id}>...</div>)}` |
| **Empty State** | `@empty {...}` | N/A (manual check) | `{items.length ? ... : ...}` |
| **Switch** | `@switch (value) { @case ('a') {...} @default {...} }` | `*ngSwitch="value"` | Object mapping or if-else chain |
| **Syntax Style** | Template-based, JavaScript-like | Directive-based | Pure JavaScript in JSX |

**Key Differences:**

1. **Angular @for vs React map():**
   - Angular: `@for (item of items; track item.id)` - built into template syntax
   - React: `items.map(item => ...)` - standard JavaScript array method

2. **Angular @if/@else vs React ternary:**
   - Angular: Block-based, more readable for complex conditions
   - React: Expression-based, more flexible with JavaScript

3. **Angular @empty vs React length check:**
   - Angular: Built-in empty state handling in `@for` blocks
   - React: Manual check with `items.length === 0`

4. **Angular @switch vs React object mapping:**
   - Angular: Template-based switch statement
   - React: JavaScript switch, object mapping, or if-else chains

**Performance Considerations:**
- **Angular `track`:** Required in `@for` for optimal rendering (like React's `key`)
- **React `key`:** Required in `map()` for efficient reconciliation
- Both frameworks use these identifiers to minimize DOM operations

**When to Use:**
- **Angular @if/@for/@switch:** Use in Angular 17+ projects for cleaner, more readable templates
- **React JSX:** Leverage full JavaScript power—more flexible but requires understanding of JavaScript expressions

**Further Reading:**
- [Angular Control Flow Syntax](https://angular.dev/essentials/conditionals-and-loops)
- [React Conditional Rendering](https://react.dev/learn/conditional-rendering)
- [React Lists and Keys](https://react.dev/learn/rendering-lists)

---

### 4. Deferrable Views (@defer, @placeholder, @loading, @error) (Angular 17+)

**Description:** Deferrable views provide declarative lazy loading and state management directly in Angular templates. This feature optimizes initial bundle size, improves performance, and provides built-in handling for loading, error, and placeholder states—all without additional code.

#### Angular: Full Deferrable Views Example

```typescript
// dashboard.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="dashboard">
      <h1>Analytics Dashboard</h1>
      
      <!-- Example 1: Defer on Viewport (Intersection Observer) -->
      <section class="section">
        <h2>Sales Chart (Loads when visible)</h2>
        @defer (on viewport) {
          <!-- Heavy component loaded only when scrolled into view -->
          <app-sales-chart></app-sales-chart>
        } @placeholder {
          <!-- Shown before user scrolls to this section -->
          <div class="placeholder-box">
            <p>📊 Chart will load when you scroll here</p>
          </div>
        } @loading (minimum 500ms) {
          <!-- Shown while loading, minimum 500ms to prevent flashing -->
          <div class="loading-box">
            <div class="spinner"></div>
            <p>Loading sales data...</p>
          </div>
        } @error {
          <!-- Shown if component fails to load -->
          <div class="error-box">
            <p>❌ Failed to load sales chart</p>
            <button (click)="retryLoad()">Retry</button>
          </div>
        }
      </section>

      <!-- Example 2: Defer on User Interaction -->
      <section class="section">
        <h2>User Statistics</h2>
        <button #statsBtn class="load-btn">Load User Stats</button>
        
        @defer (on interaction(statsBtn)) {
          <!-- Loads when button is clicked -->
          <app-user-stats></app-user-stats>
        } @placeholder {
          <div class="placeholder-box">
            <p>👆 Click the button above to load statistics</p>
          </div>
        } @loading (minimum 1s) {
          <div class="loading-box">
            <div class="spinner"></div>
            <p>Fetching user statistics...</p>
          </div>
        }
      </section>

      <!-- Example 3: Defer on Idle (requestIdleCallback) -->
      <section class="section">
        <h2>Recommendations (Loads when browser is idle)</h2>
        @defer (on idle) {
          <!-- Loads during browser idle time -->
          <app-recommendations></app-recommendations>
        } @placeholder {
          <div class="placeholder-box">
            <p>🔄 Recommendations will load automatically...</p>
          </div>
        } @loading {
          <div class="loading-box">Loading recommendations...</div>
        }
      </section>

      <!-- Example 4: Defer on Timer -->
      <section class="section">
        <h2>Notifications (Loads after 3 seconds)</h2>
        @defer (on timer(3s)) {
          <!-- Loads after specified delay -->
          <app-notifications></app-notifications>
        } @placeholder {
          <div class="placeholder-box">
            <p>⏱️ Notifications will appear shortly...</p>
          </div>
        } @loading {
          <div class="loading-box">Loading notifications...</div>
        }
      </section>

      <!-- Example 5: Defer on Hover -->
      <section class="section">
        <h2>User Profile</h2>
        <div class="hover-area" #profileArea>
          Hover over this area to load profile
        </div>
        
        @defer (on hover(profileArea)) {
          <app-user-profile></app-user-profile>
        } @placeholder {
          <div class="placeholder-box">
            <p>👋 Hover above to see profile details</p>
          </div>
        } @loading {
          <div class="loading-box">Loading profile...</div>
        }
      </section>

      <!-- Example 6: Combined Triggers -->
      <section class="section">
        <h2>Advanced Analytics (Multiple triggers)</h2>
        <button #analyticsBtn>Load Analytics</button>
        
        @defer (on interaction(analyticsBtn); on viewport; on idle) {
          <!-- Loads on ANY of: button click, scroll into view, or idle -->
          <app-advanced-analytics></app-advanced-analytics>
        } @placeholder (minimum 200ms) {
          <!-- Placeholder with minimum display time -->
          <div class="placeholder-box">
            <p>📈 Analytics ready to load</p>
            <small>Will load on: button click, scroll, or browser idle</small>
          </div>
        } @loading (minimum 800ms; after 100ms) {
          <!-- Loading state with minimum display and delay before showing -->
          <div class="loading-box">
            <div class="spinner"></div>
            <p>Processing analytics data...</p>
            <small>This may take a moment...</small>
          </div>
        } @error {
          <div class="error-box">
            <p>❌ Analytics unavailable</p>
            <p>Please try again later</p>
          </div>
        }
      </section>

      <!-- Example 7: Prefetch Strategy -->
      <section class="section">
        <h2>Reports (Prefetched on Idle)</h2>
        @defer (on interaction; prefetch on idle) {
          <!-- Prefetches code during idle, executes on interaction -->
          <app-reports></app-reports>
        } @placeholder {
          <div class="placeholder-box">
            <p>📄 Click to view reports (prefetching in background)</p>
          </div>
        } @loading {
          <div class="loading-box">Initializing reports...</div>
        }
      </section>
    </div>
  `,
  styles: [`
    .dashboard { padding: 20px; max-width: 1200px; margin: 0 auto; }
    .section { margin: 30px 0; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
    .placeholder-box { padding: 40px; background: #f0f0f0; border: 2px dashed #ccc;
                       text-align: center; border-radius: 8px; }
    .loading-box { padding: 40px; background: #e3f2fd; text-align: center;
                   border-radius: 8px; }
    .error-box { padding: 40px; background: #ffebee; text-align: center;
                 border-radius: 8px; color: #c62828; }
    .spinner { border: 4px solid #f3f3f3; border-top: 4px solid #2196f3;
               border-radius: 50%; width: 40px; height: 40px;
               animation: spin 1s linear infinite; margin: 0 auto 10px; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    .load-btn { padding: 10px 20px; font-size: 1em; cursor: pointer; }
    .hover-area { padding: 30px; background: #fff3e0; border: 2px solid #ff9800;
                  border-radius: 8px; text-align: center; cursor: pointer; }
    .hover-area:hover { background: #ffe0b2; }
  `]
})
export class DashboardComponent {
  retryLoad() {
    // Retry logic would be implemented here
    window.location.reload();
  }
}
```

**Heavy Component Examples (Lazy Loaded):**

```typescript
// sales-chart.component.ts
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-sales-chart',
  standalone: true,
  template: `
    <div class="chart-container">
      <h3>📊 Sales Chart Component</h3>
      <div class="chart-placeholder">
        [Complex Chart Library Would Render Here]
      </div>
      <p>This component includes heavy charting libraries</p>
    </div>
  `,
  styles: [`
    .chart-container { padding: 20px; background: white; border-radius: 8px; }
    .chart-placeholder { height: 300px; background: #f5f5f5; 
                        display: flex; align-items: center; justify-content: center;
                        border: 1px solid #ddd; margin: 10px 0; }
  `]
})
export class SalesChartComponent implements OnInit {
  ngOnInit() {
    console.log('📊 Sales Chart loaded!');
    // Simulate loading heavy chart library
  }
}

// user-stats.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-user-stats',
  standalone: true,
  template: `
    <div class="stats-grid">
      <div class="stat-card">
        <h4>Total Users</h4>
        <p class="stat-value">12,543</p>
      </div>
      <div class="stat-card">
        <h4>Active Today</h4>
        <p class="stat-value">2,891</p>
      </div>
      <div class="stat-card">
        <h4>New This Week</h4>
        <p class="stat-value">437</p>
      </div>
    </div>
  `,
  styles: [`
    .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
    .stat-card { padding: 20px; background: #e8f5e9; border-radius: 8px; text-align: center; }
    .stat-value { font-size: 2em; font-weight: bold; color: #2e7d32; margin: 10px 0; }
  `]
})
export class UserStatsComponent {
  constructor() {
    console.log('📈 User Stats loaded!');
  }
}
```

#### React: Equivalent with Suspense, Lazy Loading, and Intersection Observer

```jsx
// Dashboard.jsx
import React, { Suspense, lazy, useState, useEffect, useRef } from 'react';
import { ErrorBoundary } from 'react-error-boundary';
import './Dashboard.css';

// Lazy load components
const SalesChart = lazy(() => import('./SalesChart'));
const UserStats = lazy(() => import('./UserStats'));
const Recommendations = lazy(() => import('./Recommendations'));
const Notifications = lazy(() => import('./Notifications'));
const UserProfile = lazy(() => import('./UserProfile'));

// Custom hook for Intersection Observer (viewport detection)
function useInView(options = {}) {
  const [isInView, setIsInView] = useState(false);
  const [hasLoaded, setHasLoaded] = useState(false);
  const ref = useRef(null);

  useEffect(() => {
    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting && !hasLoaded) {
        setIsInView(true);
        setHasLoaded(true);
      }
    }, options);

    if (ref.current) {
      observer.observe(ref.current);
    }

    return () => {
      if (ref.current) {
        observer.unobserve(ref.current);
      }
    };
  }, [hasLoaded]);

  return [ref, isInView];
}

// Custom hook for idle callback
function useIdleLoad() {
  const [shouldLoad, setShouldLoad] = useState(false);

  useEffect(() => {
    if ('requestIdleCallback' in window) {
      const idleId = requestIdleCallback(() => {
        setShouldLoad(true);
      });
      return () => cancelIdleCallback(idleId);
    } else {
      // Fallback for browsers without requestIdleCallback
      const timeout = setTimeout(() => setShouldLoad(true), 1000);
      return () => clearTimeout(timeout);
    }
  }, []);

  return shouldLoad;
}

// Custom hook for delayed load
function useDelayedLoad(delay) {
  const [shouldLoad, setShouldLoad] = useState(false);

  useEffect(() => {
    const timeout = setTimeout(() => {
      setShouldLoad(true);
    }, delay);
    return () => clearTimeout(timeout);
  }, [delay]);

  return shouldLoad;
}

// Error fallback component
function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div className="error-box">
      <p>❌ Failed to load component</p>
      <button onClick={resetErrorBoundary}>Retry</button>
    </div>
  );
}

function Dashboard() {
  const [showStats, setShowStats] = useState(false);
  const [isHovering, setIsHovering] = useState(false);
  
  // Use custom hooks for different loading strategies
  const [chartRef, isChartInView] = useInView({ threshold: 0.1 });
  const shouldLoadRecommendations = useIdleLoad();
  const shouldLoadNotifications = useDelayedLoad(3000); // 3 seconds

  return (
    <div className="dashboard">
      <h1>Analytics Dashboard</h1>
      
      {/* Example 1: Load on Viewport */}
      <section className="section">
        <h2>Sales Chart (Loads when visible)</h2>
        <div ref={chartRef}>
          {isChartInView ? (
            <ErrorBoundary FallbackComponent={ErrorFallback}>
              <Suspense fallback={
                <div className="loading-box">
                  <div className="spinner"></div>
                  <p>Loading sales data...</p>
                </div>
              }>
                <SalesChart />
              </Suspense>
            </ErrorBoundary>
          ) : (
            <div className="placeholder-box">
              <p>📊 Chart will load when you scroll here</p>
            </div>
          )}
        </div>
      </section>

      {/* Example 2: Load on User Interaction */}
      <section className="section">
        <h2>User Statistics</h2>
        <button className="load-btn" onClick={() => setShowStats(true)}>
          Load User Stats
        </button>
        
        {showStats ? (
          <Suspense fallback={
            <div className="loading-box">
              <div className="spinner"></div>
              <p>Fetching user statistics...</p>
            </div>
          }>
            <UserStats />
          </Suspense>
        ) : (
          <div className="placeholder-box">
            <p>👆 Click the button above to load statistics</p>
          </div>
        )}
      </section>

      {/* Example 3: Load on Idle */}
      <section className="section">
        <h2>Recommendations (Loads when browser is idle)</h2>
        {shouldLoadRecommendations ? (
          <Suspense fallback={
            <div className="loading-box">Loading recommendations...</div>
          }>
            <Recommendations />
          </Suspense>
        ) : (
          <div className="placeholder-box">
            <p>🔄 Recommendations will load automatically...</p>
          </div>
        )}
      </section>

      {/* Example 4: Load on Timer */}
      <section className="section">
        <h2>Notifications (Loads after 3 seconds)</h2>
        {shouldLoadNotifications ? (
          <Suspense fallback={
            <div className="loading-box">Loading notifications...</div>
          }>
            <Notifications />
          </Suspense>
        ) : (
          <div className="placeholder-box">
            <p>⏱️ Notifications will appear shortly...</p>
          </div>
        )}
      </section>

      {/* Example 5: Load on Hover */}
      <section className="section">
        <h2>User Profile</h2>
        <div 
          className="hover-area"
          onMouseEnter={() => setIsHovering(true)}
        >
          Hover over this area to load profile
        </div>
        
        {isHovering ? (
          <Suspense fallback={
            <div className="loading-box">Loading profile...</div>
          }>
            <UserProfile />
          </Suspense>
        ) : (
          <div className="placeholder-box">
            <p>👋 Hover above to see profile details</p>
          </div>
        )}
      </section>
    </div>
  );
}

export default Dashboard;
```

**React Lazy Components:**

```jsx
// SalesChart.jsx
import React, { useEffect } from 'react';

function SalesChart() {
  useEffect(() => {
    console.log('📊 Sales Chart loaded!');
  }, []);

  return (
    <div className="chart-container">
      <h3>📊 Sales Chart Component</h3>
      <div className="chart-placeholder">
        [Complex Chart Library Would Render Here]
      </div>
      <p>This component includes heavy charting libraries</p>
    </div>
  );
}

export default SalesChart;

// UserStats.jsx
import React from 'react';

function UserStats() {
  console.log('📈 User Stats loaded!');
  
  return (
    <div className="stats-grid">
      <div className="stat-card">
        <h4>Total Users</h4>
        <p className="stat-value">12,543</p>
      </div>
      <div className="stat-card">
        <h4>Active Today</h4>
        <p className="stat-value">2,891</p>
      </div>
      <div className="stat-card">
        <h4>New This Week</h4>
        <p className="stat-value">437</p>
      </div>
    </div>
  );
}

export default UserStats;
```

#### Comparison: Deferrable Views

| Feature | Angular @defer | React Lazy + Suspense |
|---------|---------------|----------------------|
| **Syntax** | Declarative in template | Imperative with hooks/state |
| **Viewport Trigger** | Built-in: `on viewport` | Manual: Intersection Observer API |
| **Interaction Trigger** | Built-in: `on interaction(element)` | Manual: onClick handler + state |
| **Idle Trigger** | Built-in: `on idle` | Manual: requestIdleCallback |
| **Timer Trigger** | Built-in: `on timer(3s)` | Manual: setTimeout |
| **Hover Trigger** | Built-in: `on hover(element)` | Manual: onMouseEnter + state |
| **Placeholder** | Built-in: `@placeholder` block | Manual: conditional rendering |
| **Loading** | Built-in: `@loading` block | Suspense fallback prop |
| **Error** | Built-in: `@error` block | ErrorBoundary component |
| **Minimum Display Time** | Built-in: `minimum 500ms` | Manual: additional state + timer |
| **Prefetch** | Built-in: `prefetch on idle` | Manual: link prefetch or custom logic |
| **Multiple Triggers** | Built-in: Multiple conditions | Manual: Complex state management |

**Key Differences:**

1. **Declarative vs Imperative:**
   - **Angular:** Declarative—all logic in template
   - **React:** Imperative—requires custom hooks, state management, and conditional rendering

2. **Built-in Triggers:**
   - **Angular:** 7+ built-in triggers (viewport, idle, timer, interaction, hover, immediate, prefetch)
   - **React:** No built-in triggers—must implement with browser APIs

3. **Error Handling:**
   - **Angular:** `@error` block automatically catches loading errors
   - **React:** Requires separate ErrorBoundary component

4. **Loading States:**
   - **Angular:** `@loading` with options like `minimum` and `after` for UX control
   - **React:** Suspense fallback—no built-in timing controls

5. **Complexity:**
   - **Angular:** Simple for common patterns, limited customization
   - **React:** More code required, but fully customizable

**Performance Benefits:**
- Both approaches reduce initial bundle size
- Both enable progressive loading for better First Contentful Paint (FCP)
- Angular's built-in approach requires less custom code
- React's approach provides more fine-grained control

**When to Use:**
- **Angular @defer:** Use for most lazy loading scenarios in Angular 17+. Less code, built-in optimizations, easier maintenance.
- **React lazy():** Use for code splitting in React. More manual setup, but integrates well with Suspense and ErrorBoundary patterns.

**Further Reading:**
- [Angular Deferrable Views](https://angular.dev/guide/defer)
- [React Suspense](https://react.dev/reference/react/Suspense)
- [React lazy()](https://react.dev/reference/react/lazy)
- [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)

---

### 5. Required Inputs

**Description:** Angular's required inputs feature enforces that specific `@Input()` properties must be provided when using a component. This adds compile-time type safety and prevents runtime errors from missing props.

#### Angular: Required Inputs Example

```typescript
// user-profile.component.ts
import { Component, Input } from '@angular/core';

interface User {
  id: number;
  name: string;
  email: string;
  avatar?: string;
}

@Component({
  selector: 'app-user-profile',
  standalone: true,
  template: `
    <div class="profile-card">
      <img 
        [src]="avatar || 'default-avatar.png'" 
        [alt]="userName + ' avatar'"
        class="avatar"
      />
      <h2>{{ userName }}</h2>
      <p>{{ userEmail }}</p>
      <p *ngIf="bio">{{ bio }}</p>
      <p class="user-id">ID: {{ userId }}</p>
    </div>
  `,
  styles: [`
    .profile-card { padding: 20px; border: 1px solid #ccc; border-radius: 8px; }
    .avatar { width: 100px; height: 100px; border-radius: 50%; }
  `]
})
export class UserProfileComponent {
  // Required inputs - MUST be provided or compile error
  @Input({ required: true }) userId!: number;
  @Input({ required: true }) userName!: string;
  @Input({ required: true }) userEmail!: string;
  
  // Optional inputs - can be omitted
  @Input() avatar?: string;
  @Input() bio?: string;
  
  // You can also use the full object syntax with transforms
  @Input({ required: true, alias: 'user' }) userObject?: User;
}
```

**Usage (Will Compile Successfully):**

```typescript
// parent.component.ts
import { Component } from '@angular/core';
import { UserProfileComponent } from './user-profile.component';

@Component({
  selector: 'app-parent',
  standalone: true,
  imports: [UserProfileComponent],
  template: `
    <!-- ✅ All required inputs provided -->
    <app-user-profile
      [userId]="123"
      [userName]="'John Doe'"
      [userEmail]="'john@example.com'"
      [avatar]="'john-avatar.png'"
      [bio]="'Software Engineer'"
    ></app-user-profile>
    
    <!-- ✅ Optional inputs can be omitted -->
    <app-user-profile
      [userId]="456"
      [userName]="'Jane Smith'"
      [userEmail]="'jane@example.com'"
    ></app-user-profile>
  `
})
export class ParentComponent {}
```

**Usage (Will FAIL at Compile Time):**

```typescript
// This will show TypeScript errors in your IDE and fail compilation
@Component({
  template: `
    <!-- ❌ ERROR: Missing required input 'userName' -->
    <app-user-profile
      [userId]="123"
      [userEmail]="'john@example.com'"
    ></app-user-profile>
  `
})
```

**Advanced Example with Transforms:**

```typescript
// price-display.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-price-display',
  standalone: true,
  template: `
    <div class="price">
      <span class="currency">{{ currency }}</span>
      <span class="amount">{{ formattedAmount }}</span>
    </div>
  `
})
export class PriceDisplayComponent {
  // Required with transform function
  @Input({ 
    required: true,
    transform: (value: string | number) => {
      // Transform string to number if needed
      return typeof value === 'string' ? parseFloat(value) : value;
    }
  }) 
  amount!: number;
  
  @Input() currency: string = 'USD';
  
  get formattedAmount(): string {
    return this.amount.toFixed(2);
  }
}
```

#### React: Equivalent with TypeScript and PropTypes

**React with TypeScript (Compile-Time Validation):**

```tsx
// UserProfile.tsx
import React from 'react';

interface UserProfileProps {
  userId: number;        // Required (no ?)
  userName: string;      // Required
  userEmail: string;     // Required
  avatar?: string;       // Optional
  bio?: string;          // Optional
}

function UserProfile({ 
  userId, 
  userName, 
  userEmail, 
  avatar, 
  bio 
}: UserProfileProps) {
  return (
    <div className="profile-card">
      <img 
        src={avatar || 'default-avatar.png'} 
        alt={`${userName} avatar`}
        className="avatar"
      />
      <h2>{userName}</h2>
      <p>{userEmail}</p>
      {bio && <p>{bio}</p>}
      <p className="user-id">ID: {userId}</p>
    </div>
  );
}

export default UserProfile;
```

**Usage (Will Compile Successfully):**

```tsx
// Parent.tsx
import React from 'react';
import UserProfile from './UserProfile';

function Parent() {
  return (
    <>
      {/* ✅ All required props provided */}
      <UserProfile
        userId={123}
        userName="John Doe"
        userEmail="john@example.com"
        avatar="john-avatar.png"
        bio="Software Engineer"
      />
      
      {/* ✅ Optional props can be omitted */}
      <UserProfile
        userId={456}
        userName="Jane Smith"
        userEmail="jane@example.com"
      />
    </>
  );
}

export default Parent;
```

**Usage (Will FAIL at Compile Time):**

```tsx
// ❌ TypeScript error: Property 'userName' is missing
<UserProfile
  userId={123}
  userEmail="john@example.com"
/>
```

**React with PropTypes (Runtime Validation):**

```jsx
// UserProfile.jsx
import React from 'react';
import PropTypes from 'prop-types';

function UserProfile({ userId, userName, userEmail, avatar, bio }) {
  return (
    <div className="profile-card">
      <img 
        src={avatar || 'default-avatar.png'} 
        alt={`${userName} avatar`}
        className="avatar"
      />
      <h2>{userName}</h2>
      <p>{userEmail}</p>
      {bio && <p>{bio}</p>}
      <p className="user-id">ID: {userId}</p>
    </div>
  );
}

// PropTypes validation (runtime)
UserProfile.propTypes = {
  userId: PropTypes.number.isRequired,     // Required
  userName: PropTypes.string.isRequired,   // Required
  userEmail: PropTypes.string.isRequired,  // Required
  avatar: PropTypes.string,                // Optional
  bio: PropTypes.string                    // Optional
};

// Default props for optional values
UserProfile.defaultProps = {
  avatar: 'default-avatar.png',
  bio: null
};

export default UserProfile;
```

**React with Default Values (Modern Syntax):**

```tsx
// UserProfile.tsx with default parameters
import React from 'react';

interface UserProfileProps {
  userId: number;
  userName: string;
  userEmail: string;
  avatar?: string;
  bio?: string;
}

function UserProfile({ 
  userId, 
  userName, 
  userEmail, 
  avatar = 'default-avatar.png',  // Default value
  bio 
}: UserProfileProps) {
  return (
    <div className="profile-card">
      <img src={avatar} alt={`${userName} avatar`} className="avatar" />
      <h2>{userName}</h2>
      <p>{userEmail}</p>
      {bio && <p>{bio}</p>}
      <p className="user-id">ID: {userId}</p>
    </div>
  );
}

export default UserProfile;
```

#### Comparison: Required Inputs/Props

| Feature | Angular @Input({ required: true }) | React TypeScript | React PropTypes |
|---------|-----------------------------------|-----------------|----------------|
| **Validation Time** | Compile-time | Compile-time | Runtime |
| **Type Safety** | ✅ Full TypeScript support | ✅ Full TypeScript support | ⚠️ Runtime only |
| **Syntax** | `@Input({ required: true })` | Interface with required props | `.isRequired` |
| **IDE Support** | ✅ Excellent | ✅ Excellent | ⚠️ Limited |
| **Error Feedback** | Compile error | Compile error | Console warning |
| **Performance** | No runtime cost | No runtime cost | Small runtime cost |
| **Transform/Alias** | ✅ Built-in | ❌ Manual | ❌ Manual |
| **Default Values** | Property initializer | Function params | `defaultProps` |

**Key Differences:**

1. **Validation Timing:**
   - **Angular:** Compile-time enforcement in templates
   - **React TypeScript:** Compile-time enforcement
   - **React PropTypes:** Runtime validation only

2. **Syntax:**
   - **Angular:** Uses `@Input()` decorator with `required` option
   - **React:** Uses TypeScript interfaces or PropTypes

3. **Transforms:**
   - **Angular:** Can transform input values with `transform` option
   - **React:** Must handle transforms manually in component logic

4. **Aliases:**
   - **Angular:** Can alias inputs with `alias` option: `@Input({ alias: 'userName' })`
   - **React:** Props use their declared names

**Best Practices:**

**Angular:**
```typescript
// Use required for critical inputs
@Input({ required: true }) userId!: number;

// Provide defaults for optional inputs
@Input() theme: 'light' | 'dark' = 'light';

// Use transform for type conversion
@Input({ 
  transform: (v: string | number) => typeof v === 'string' ? parseInt(v) : v 
}) 
count!: number;
```

**React TypeScript:**
```typescript
// Use TypeScript interfaces for type safety
interface Props {
  userId: number;          // Required
  theme?: 'light' | 'dark'; // Optional
}

// Use default parameters for optional props
function Component({ userId, theme = 'light' }: Props) {
  // ...
}
```

**React PropTypes:**
```javascript
// Use isRequired for critical props
Component.propTypes = {
  userId: PropTypes.number.isRequired,
  theme: PropTypes.oneOf(['light', 'dark'])
};

// Use defaultProps for optional props
Component.defaultProps = {
  theme: 'light'
};
```

**When to Use:**
- **Angular Required Inputs:** Always use in Angular 14+ for better type safety
- **React TypeScript:** Preferred approach for React—best type safety
- **React PropTypes:** Use only for runtime validation or when not using TypeScript

**Further Reading:**
- [Angular Input](https://angular.dev/guide/components/inputs)
- [React TypeScript](https://react.dev/learn/typescript)
- [React PropTypes](https://react.dev/reference/react/Component#static-proptypes)

---

### 6. inject() Function

**Description:** The `inject()` function enables functional dependency injection in Angular, allowing you to inject services and tokens outside of constructor parameters. This is particularly useful in functional guards, standalone functions, and within class methods.

#### Angular: inject() Function Examples

**Basic Service Injection:**

```typescript
// logger.service.ts
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class LoggerService {
  log(message: string) {
    console.log(`[LOG]: ${message}`);
  }
  
  error(message: string) {
    console.error(`[ERROR]: ${message}`);
  }
}

// Traditional constructor injection
import { Component } from '@angular/core';
import { LoggerService } from './logger.service';

@Component({
  selector: 'app-old-style',
  template: `<p>Check console for logs</p>`
})
export class OldStyleComponent {
  // Traditional way: constructor injection
  constructor(private logger: LoggerService) {
    this.logger.log('Component initialized');
  }
}

// Modern inject() function
import { Component, OnInit, inject } from '@angular/core';

@Component({
  selector: 'app-new-style',
  standalone: true,
  template: `<p>Check console for logs</p>`
})
export class NewStyleComponent implements OnInit {
  // Modern way: inject() function
  private logger = inject(LoggerService);
  
  ngOnInit() {
    this.logger.log('Component initialized with inject()');
  }
}
```

**Using inject() in Functions (Functional Guards):**

```typescript
// auth.service.ts
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private isAuthenticated = false;
  
  login() {
    this.isAuthenticated = true;
  }
  
  logout() {
    this.isAuthenticated = false;
  }
  
  isLoggedIn(): boolean {
    return this.isAuthenticated;
  }
}

// auth.guard.ts - OLD CLASS-BASED APPROACH
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class OldAuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}
  
  canActivate(): boolean {
    if (this.authService.isLoggedIn()) {
      return true;
    }
    this.router.navigate(['/login']);
    return false;
  }
}

// auth.guard.ts - NEW FUNCTIONAL APPROACH with inject()
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from './auth.service';

// Functional guard using inject()
export const authGuard: CanActivateFn = (route, state) => {
  // inject() allows DI in functional context
  const authService = inject(AuthService);
  const router = inject(Router);
  
  if (authService.isLoggedIn()) {
    return true;
  }
  
  // Redirect to login if not authenticated
  return router.createUrlTree(['/login']);
};

// Usage in routes
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { 
    path: 'dashboard', 
    component: DashboardComponent,
    canActivate: [authGuard] // Use functional guard
  }
];
```

**Advanced: inject() with Custom Tokens:**

```typescript
// config.token.ts
import { InjectionToken } from '@angular/core';

export interface AppConfig {
  apiUrl: string;
  apiKey: string;
  timeout: number;
}

// Create an injection token
export const APP_CONFIG = new InjectionToken<AppConfig>('app.config');

// main.ts - Provide the config
import { bootstrapApplication } from '@angular/platform-browser';
import { APP_CONFIG } from './app/config.token';

bootstrapApplication(AppComponent, {
  providers: [
    {
      provide: APP_CONFIG,
      useValue: {
        apiUrl: 'https://api.example.com',
        apiKey: 'secret-key-123',
        timeout: 5000
      }
    }
  ]
});

// api.service.ts - Inject custom token
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { APP_CONFIG, AppConfig } from './config.token';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  // Inject custom token using inject()
  private config = inject(APP_CONFIG);
  private http = inject(HttpClient);
  
  getData() {
    return this.http.get(`${this.config.apiUrl}/data`, {
      headers: { 'X-API-Key': this.config.apiKey },
      timeout: this.config.timeout
    });
  }
}
```

**inject() in Utility Functions:**

```typescript
// utils/validation.ts
import { inject } from '@angular/core';
import { FormControl, ValidationErrors } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { map, catchError } from 'rxjs/operators';

// Async validator function using inject()
export function uniqueUsernameValidator(control: FormControl): Observable<ValidationErrors | null> {
  // inject() works in validator functions too!
  const http = inject(HttpClient);
  
  if (!control.value) {
    return of(null);
  }
  
  return http.get<{ exists: boolean }>(`/api/check-username/${control.value}`).pipe(
    map(response => response.exists ? { usernameTaken: true } : null),
    catchError(() => of(null))
  );
}

// Usage in component
import { Component, inject } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { uniqueUsernameValidator } from './utils/validation';

@Component({
  selector: 'app-register',
  template: `
    <form [formGroup]="form">
      <input formControlName="username" placeholder="Username" />
      <div *ngIf="form.get('username')?.hasError('usernameTaken')">
        Username is already taken
      </div>
    </form>
  `
})
export class RegisterComponent {
  private fb = inject(FormBuilder);
  
  form: FormGroup = this.fb.group({
    username: ['', [], [uniqueUsernameValidator]]
  });
}
```

**inject() with Optional Dependencies:**

```typescript
// feature-flag.service.ts
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class FeatureFlagService {
  isFeatureEnabled(flag: string): boolean {
    return Math.random() > 0.5; // Simplified
  }
}

// component.ts
import { Component, inject, Optional } from '@angular/core';
import { FeatureFlagService } from './feature-flag.service';

@Component({
  selector: 'app-feature',
  standalone: true,
  template: `
    <div *ngIf="showNewFeature">
      <h2>New Feature!</h2>
    </div>
  `
})
export class FeatureComponent {
  // Optional injection - won't error if service not provided
  private featureFlags = inject(FeatureFlagService, { optional: true });
  
  showNewFeature = this.featureFlags?.isFeatureEnabled('new-ui') ?? false;
}
```

#### React: Equivalent with Context and Custom Hooks

**React Context API (Dependency Injection Pattern):**

```tsx
// LoggerContext.tsx
import React, { createContext, useContext, ReactNode } from 'react';

// Logger service interface
interface Logger {
  log: (message: string) => void;
  error: (message: string) => void;
}

// Create logger implementation
const createLogger = (): Logger => ({
  log: (message: string) => console.log(`[LOG]: ${message}`),
  error: (message: string) => console.error(`[ERROR]: ${message}`)
});

// Create context
const LoggerContext = createContext<Logger | null>(null);

// Provider component
export function LoggerProvider({ children }: { children: ReactNode }) {
  const logger = createLogger();
  
  return (
    <LoggerContext.Provider value={logger}>
      {children}
    </LoggerContext.Provider>
  );
}

// Custom hook (equivalent to inject())
export function useLogger(): Logger {
  const logger = useContext(LoggerContext);
  if (!logger) {
    throw new Error('useLogger must be used within LoggerProvider');
  }
  return logger;
}

// Usage in component
function MyComponent() {
  const logger = useLogger(); // Similar to inject(LoggerService)
  
  React.useEffect(() => {
    logger.log('Component initialized');
  }, [logger]);
  
  return <p>Check console for logs</p>;
}
```

**React Router with Context (Guard Pattern):**

```tsx
// AuthContext.tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

interface AuthContextType {
  isAuthenticated: boolean;
  login: () => void;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  
  const login = () => setIsAuthenticated(true);
  const logout = () => setIsAuthenticated(false);
  
  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

// ProtectedRoute.tsx (Guard equivalent)
import { Navigate } from 'react-router-dom';

interface ProtectedRouteProps {
  children: React.ReactElement;
}

function ProtectedRoute({ children }: ProtectedRouteProps) {
  const { isAuthenticated } = useAuth(); // Similar to inject(AuthService)
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return children;
}

// Usage in App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';

function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<LoginComponent />} />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <DashboardComponent />
              </ProtectedRoute>
            }
          />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
```

**React with Config Provider:**

```tsx
// ConfigContext.tsx
import React, { createContext, useContext, ReactNode } from 'react';

interface AppConfig {
  apiUrl: string;
  apiKey: string;
  timeout: number;
}

const ConfigContext = createContext<AppConfig | null>(null);

export function ConfigProvider({ 
  config, 
  children 
}: { 
  config: AppConfig; 
  children: ReactNode;
}) {
  return (
    <ConfigContext.Provider value={config}>
      {children}
    </ConfigContext.Provider>
  );
}

export function useConfig(): AppConfig {
  const config = useContext(ConfigContext);
  if (!config) {
    throw new Error('useConfig must be used within ConfigProvider');
  }
  return config;
}

// ApiService.tsx (Custom hook)
import axios from 'axios';

export function useApi() {
  const config = useConfig(); // Similar to inject(APP_CONFIG)
  
  const getData = async () => {
    const response = await axios.get(`${config.apiUrl}/data`, {
      headers: { 'X-API-Key': config.apiKey },
      timeout: config.timeout
    });
    return response.data;
  };
  
  return { getData };
}

// Usage in main App
import ReactDOM from 'react-dom/client';

const appConfig: AppConfig = {
  apiUrl: 'https://api.example.com',
  apiKey: 'secret-key-123',
  timeout: 5000
};

ReactDOM.createRoot(document.getElementById('root')!).render(
  <ConfigProvider config={appConfig}>
    <App />
  </ConfigProvider>
);
```

**React with Optional Context:**

```tsx
// FeatureFlagContext.tsx
import React, { createContext, useContext, ReactNode } from 'react';

interface FeatureFlagService {
  isFeatureEnabled: (flag: string) => boolean;
}

const FeatureFlagContext = createContext<FeatureFlagService | null>(null);

export function FeatureFlagProvider({ children }: { children: ReactNode }) {
  const service: FeatureFlagService = {
    isFeatureEnabled: (flag: string) => Math.random() > 0.5
  };
  
  return (
    <FeatureFlagContext.Provider value={service}>
      {children}
    </FeatureFlagContext.Provider>
  );
}

// Optional hook (won't throw if not provided)
export function useFeatureFlags(): FeatureFlagService | null {
  return useContext(FeatureFlagContext);
}

// Usage
function FeatureComponent() {
  const featureFlags = useFeatureFlags(); // Optional, similar to inject(, {optional: true})
  const showNewFeature = featureFlags?.isFeatureEnabled('new-ui') ?? false;
  
  return (
    <div>
      {showNewFeature && (
        <div>
          <h2>New Feature!</h2>
        </div>
      )}
    </div>
  );
}
```

#### Comparison: inject() vs useContext/Custom Hooks

| Feature | Angular inject() | React useContext |
|---------|-----------------|------------------|
| **Syntax** | `inject(Service)` | `useContext(Context)` |
| **Setup Required** | Service with `@Injectable` | Context + Provider |
| **Type Safety** | ✅ Automatic | ✅ With TypeScript |
| **Tree Shaking** | ✅ Excellent | ⚠️ Context always bundled |
| **Scope** | Module/Root/Component | Provider subtree |
| **Optional Injection** | `inject(Service, {optional: true})` | Return null pattern |
| **Multiple Instances** | ✅ Via providers | ✅ Via nested providers |
| **Constructor Injection** | ✅ Supported | ❌ N/A |
| **Functional Context** | ✅ inject() anywhere | ✅ useContext in components |
| **Testing** | ✅ TestBed mocking | ⚠️ Provider wrapping |

**Key Differences:**

1. **Registration:**
   - **Angular:** Services registered via `@Injectable` or providers array
   - **React:** Must create Context, Provider, and custom hook

2. **Injection Point:**
   - **Angular:** Can inject in constructors, class properties, or functions with `inject()`
   - **React:** Can only use hooks in function components/custom hooks

3. **Scoping:**
   - **Angular:** Root, module, or component-level scoping
   - **React:** Provider subtree scoping

4. **Boilerplate:**
   - **Angular:** Less boilerplate for services
   - **React:** More boilerplate (Context + Provider + Hook)

**When to Use:**
- **Angular inject():** Use for all dependency injection—cleaner than constructor injection, works in functional contexts
- **React useContext:** Use for sharing state/services across component tree, but consider state management libraries for complex apps

**Further Reading:**
- [Angular inject() Function](https://angular.dev/api/core/inject)
- [React Context API](https://react.dev/reference/react/useContext)

---

### 7. takeUntilDestroyed()

**Description:** `takeUntilDestroyed()` is an RxJS operator that automatically unsubscribes from observables when a component is destroyed, preventing memory leaks without manual cleanup code.

#### Angular: takeUntilDestroyed() Examples

**Basic Usage:**

```typescript
// data.service.ts
import { Injectable } from '@angular/core';
import { Observable, interval } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  // Emits every second
  liveData$: Observable<number> = interval(1000);
  
  // Simulated API call
  getUserData(): Observable<{ name: string; age: number }> {
    return new Observable(observer => {
      setTimeout(() => {
        observer.next({ name: 'John Doe', age: 30 });
        observer.complete();
      }, 2000);
    });
  }
}

// OLD WAY: Manual unsubscribe
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-old-way',
  template: `<p>Live data: {{ liveData }}</p>`
})
export class OldWayComponent implements OnInit, OnDestroy {
  liveData = 0;
  private subscription!: Subscription;
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    // Must manually track subscription
    this.subscription = this.dataService.liveData$.subscribe(data => {
      this.liveData = data;
    });
  }
  
  ngOnDestroy() {
    // Must remember to unsubscribe
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }
}

// OLD WAY: Subject pattern
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({
  selector: 'app-subject-way',
  template: `<p>Live data: {{ liveData }}</p>`
})
export class SubjectWayComponent implements OnInit, OnDestroy {
  liveData = 0;
  private destroy$ = new Subject<void>();
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    this.dataService.liveData$
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => {
        this.liveData = data;
      });
  }
  
  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}

// NEW WAY: takeUntilDestroyed()
import { Component, OnInit } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-new-way',
  standalone: true,
  template: `<p>Live data: {{ liveData }}</p>`
})
export class NewWayComponent implements OnInit {
  liveData = 0;
  
  constructor(private dataService: DataService) {
    // takeUntilDestroyed() in constructor automatically cleans up
    this.dataService.liveData$
      .pipe(takeUntilDestroyed())
      .subscribe(data => {
        this.liveData = data;
      });
  }
  
  ngOnInit() {
    // Can also use in ngOnInit if DestroyRef is injected
  }
}
```

**Advanced Usage with Multiple Subscriptions:**

```typescript
// dashboard.component.ts
import { Component, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { HttpClient } from '@angular/common/http';
import { interval, fromEvent } from 'rxjs';
import { switchMap, debounceTime } from 'rxjs/operators';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  template: `
    <div class="dashboard">
      <h2>Live Dashboard</h2>
      
      <div class="stats">
        <div class="stat-card">
          <h3>Timer</h3>
          <p>{{ timer }}</p>
        </div>
        
        <div class="stat-card">
          <h3>Users Online</h3>
          <p>{{ usersOnline }}</p>
        </div>
        
        <div class="stat-card">
          <h3>Window Width</h3>
          <p>{{ windowWidth }}px</p>
        </div>
      </div>
      
      <div class="search">
        <input #searchInput type="text" placeholder="Search..." />
        <div *ngIf="searchResults.length">
          <h4>Results:</h4>
          <ul>
            <li *ngFor="let result of searchResults">{{ result }}</li>
          </ul>
        </div>
      </div>
    </div>
  `
})
export class DashboardComponent implements OnInit {
  private http = inject(HttpClient);
  
  timer = 0;
  usersOnline = 0;
  windowWidth = window.innerWidth;
  searchResults: string[] = [];
  
  constructor() {
    // All these subscriptions automatically cleaned up on destroy!
    
    // Timer - updates every second
    interval(1000)
      .pipe(takeUntilDestroyed())
      .subscribe(value => {
        this.timer = value;
      });
    
    // Simulated live data - polls every 5 seconds
    interval(5000)
      .pipe(
        takeUntilDestroyed(),
        switchMap(() => this.http.get<{ count: number }>('/api/users-online'))
      )
      .subscribe(response => {
        this.usersOnline = response.count;
      });
    
    // Window resize listener
    fromEvent(window, 'resize')
      .pipe(
        takeUntilDestroyed(),
        debounceTime(300)
      )
      .subscribe(() => {
        this.windowWidth = window.innerWidth;
      });
  }
  
  ngOnInit() {
    // Can set up more subscriptions here with takeUntilDestroyed()
  }
  
  setupSearch(searchInput: HTMLInputElement) {
    fromEvent(searchInput, 'input')
      .pipe(
        takeUntilDestroyed(),
        debounceTime(500),
        switchMap(event => {
          const query = (event.target as HTMLInputElement).value;
          return this.http.get<string[]>(`/api/search?q=${query}`);
        })
      )
      .subscribe(results => {
        this.searchResults = results;
      });
  }
}
```

**Using with DestroyRef for Flexibility:**

```typescript
// flexible.component.ts
import { Component, inject, DestroyRef } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { interval } from 'rxjs';

@Component({
  selector: 'app-flexible',
  standalone: true,
  template: `<p>Counter: {{ counter }}</p>`
})
export class FlexibleComponent {
  private destroyRef = inject(DestroyRef);
  counter = 0;
  
  constructor() {
    // Pass DestroyRef explicitly for more control
    interval(1000)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(value => {
        this.counter = value;
      });
  }
  
  // Can use in methods too!
  startAnotherTimer() {
    interval(2000)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(value => {
        console.log('Second timer:', value);
      });
  }
}
```

**Service with takeUntilDestroyed:**

```typescript
// notification.service.ts
import { Injectable, DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { WebSocketSubject, webSocket } from 'rxjs/webSocket';

@Injectable()
export class NotificationService {
  private destroyRef = inject(DestroyRef);
  private ws$: WebSocketSubject<any>;
  
  constructor() {
    this.ws$ = webSocket('ws://localhost:8080/notifications');
    
    // WebSocket connection automatically closed when service is destroyed
    this.ws$
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(
        message => console.log('Notification:', message),
        error => console.error('WebSocket error:', error)
      );
  }
  
  sendNotification(message: string) {
    this.ws$.next({ message });
  }
}
```

#### React: Equivalent with useEffect Cleanup

```tsx
// Dashboard.tsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';

function Dashboard() {
  const [timer, setTimer] = useState(0);
  const [usersOnline, setUsersOnline] = useState(0);
  const [windowWidth, setWindowWidth] = useState(window.innerWidth);
  const [searchResults, setSearchResults] = useState<string[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  
  // Timer effect with cleanup
  useEffect(() => {
    const intervalId = setInterval(() => {
      setTimer(prev => prev + 1);
    }, 1000);
    
    // Cleanup function (equivalent to takeUntilDestroyed)
    return () => clearInterval(intervalId);
  }, []);
  
  // Polling effect with cleanup
  useEffect(() => {
    const fetchUsers = async () => {
      const response = await axios.get<{ count: number }>('/api/users-online');
      setUsersOnline(response.data.count);
    };
    
    fetchUsers(); // Initial fetch
    const intervalId = setInterval(fetchUsers, 5000);
    
    // Cleanup
    return () => clearInterval(intervalId);
  }, []);
  
  // Window resize effect with cleanup
  useEffect(() => {
    const handleResize = () => {
      setWindowWidth(window.innerWidth);
    };
    
    window.addEventListener('resize', handleResize);
    
    // Cleanup (removes event listener)
    return () => window.removeEventListener('resize', handleResize);
  }, []);
  
  // Search effect with debounce and cleanup
  useEffect(() => {
    if (!searchQuery) {
      setSearchResults([]);
      return;
    }
    
    const timeoutId = setTimeout(async () => {
      const response = await axios.get<string[]>(`/api/search?q=${searchQuery}`);
      setSearchResults(response.data);
    }, 500);
    
    // Cleanup (cancels pending request)
    return () => clearTimeout(timeoutId);
  }, [searchQuery]);
  
  return (
    <div className="dashboard">
      <h2>Live Dashboard</h2>
      
      <div className="stats">
        <div className="stat-card">
          <h3>Timer</h3>
          <p>{timer}</p>
        </div>
        
        <div className="stat-card">
          <h3>Users Online</h3>
          <p>{usersOnline}</p>
        </div>
        
        <div className="stat-card">
          <h3>Window Width</h3>
          <p>{windowWidth}px</p>
        </div>
      </div>
      
      <div className="search">
        <input
          type="text"
          placeholder="Search..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        {searchResults.length > 0 && (
          <div>
            <h4>Results:</h4>
            <ul>
              {searchResults.map((result, index) => (
                <li key={index}>{result}</li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}

export default Dashboard;
```

**React with Custom Hook for WebSocket:**

```tsx
// useWebSocket.ts
import { useEffect, useRef } from 'react';

interface UseWebSocketOptions {
  onMessage: (message: any) => void;
  onError?: (error: Event) => void;
}

export function useWebSocket(url: string, options: UseWebSocketOptions) {
  const ws = useRef<WebSocket | null>(null);
  
  useEffect(() => {
    // Create WebSocket connection
    ws.current = new WebSocket(url);
    
    ws.current.onmessage = (event) => {
      const message = JSON.parse(event.data);
      options.onMessage(message);
    };
    
    ws.current.onerror = (error) => {
      options.onError?.(error);
    };
    
    // Cleanup function (closes connection on unmount)
    return () => {
      if (ws.current) {
        ws.current.close();
      }
    };
  }, [url]); // Reconnect if URL changes
  
  const sendMessage = (message: any) => {
    if (ws.current?.readyState === WebSocket.OPEN) {
      ws.current.send(JSON.stringify(message));
    }
  };
  
  return { sendMessage };
}

// Usage
function NotificationComponent() {
  const { sendMessage } = useWebSocket('ws://localhost:8080/notifications', {
    onMessage: (message) => {
      console.log('Notification:', message);
    },
    onError: (error) => {
      console.error('WebSocket error:', error);
    }
  });
  
  return (
    <button onClick={() => sendMessage({ text: 'Hello' })}>
      Send Notification
    </button>
  );
}
```

#### Comparison: takeUntilDestroyed() vs useEffect Cleanup

| Feature | Angular takeUntilDestroyed() | React useEffect Cleanup |
|---------|------------------------------|-------------------------|
| **Syntax** | `.pipe(takeUntilDestroyed())` | `return () => cleanup()` |
| **Boilerplate** | Minimal (one operator) | More verbose |
| **RxJS Integration** | ✅ Native | ⚠️ Manual patterns |
| **Memory Leaks** | ✅ Auto-prevented | ⚠️ Must remember cleanup |
| **Multiple Observables** | Easy to manage | One effect per subscription |
| **Conditional Cleanup** | Via operators | Via effect dependencies |
| **Testing** | RxJS testing utils | Mock cleanup functions |

**Key Differences:**

1. **Automatic vs Manual:**
   - **Angular:** Automatic unsubscribe with operator
   - **React:** Manual cleanup function required

2. **RxJS vs Promises:**
   - **Angular:** Built for RxJS observables
   - **React:** Built for any async operation

3. **Complexity:**
   - **Angular:** Less code, cleaner for multiple observables
   - **React:** More explicit, but more boilerplate

**Common Pitfalls:**

**Angular:**
- Must call `takeUntilDestroyed()` in constructor or with explicit DestroyRef
- Cannot use in class methods without DestroyRef

**React:**
- Forgetting cleanup function leads to memory leaks
- Dependencies array must be correct to avoid stale closures

**When to Use:**
- **Angular takeUntilDestroyed():** Use for all RxJS subscriptions in components—prevents memory leaks with minimal code
- **React useEffect cleanup:** Use for all subscriptions, timers, and event listeners—manual but flexible

**Further Reading:**
- [Angular takeUntilDestroyed()](https://angular.dev/api/core/rxjs-interop/takeUntilDestroyed)
- [React useEffect Cleanup](https://react.dev/reference/react/useEffect#cleaning-up-side-effects)

---

### 8. DestroyRef

**Description:** `DestroyRef` provides a way to register cleanup callbacks that run when a component, directive, or service is destroyed. It's an alternative to implementing `OnDestroy` and works particularly well with the `inject()` function.

#### Angular: DestroyRef Examples

**Basic Usage:**

```typescript
// cleanup.component.ts
import { Component, DestroyRef, inject } from '@angular/core';

@Component({
  selector: 'app-cleanup',
  standalone: true,
  template: `
    <div>
      <h2>Component with Cleanup</h2>
      <p>Check console when this component is destroyed</p>
    </div>
  `
})
export class CleanupComponent {
  private destroyRef = inject(DestroyRef);
  
  constructor() {
    // Register cleanup callback - runs when component is destroyed
    this.destroyRef.onDestroy(() => {
      console.log('Component is being destroyed!');
      console.log('Performing cleanup...');
    });
    
    // Can register multiple cleanup callbacks
    this.destroyRef.onDestroy(() => {
      console.log('Second cleanup callback');
    });
    
    // Cleanup callbacks run in registration order
    this.destroyRef.onDestroy(() => {
      console.log('Third cleanup callback');
    });
  }
}
```

**Advanced: Managing Resources:**

```typescript
// resource-manager.component.ts
import { Component, DestroyRef, inject, OnInit } from '@angular/core';

@Component({
  selector: 'app-resource-manager',
  standalone: true,
  template: `
    <div class="manager">
      <h2>Resource Manager</h2>
      <p>Managing {{ activeConnections }} connections</p>
      <button (click)="addConnection()">Add Connection</button>
    </div>
  `
})
export class ResourceManagerComponent implements OnInit {
  private destroyRef = inject(DestroyRef);
  private connections: Set<number> = new Set();
  activeConnections = 0;
  
  ngOnInit() {
    // Simulate opening a database connection
    const dbConnection = this.openDatabaseConnection();
    
    // Register cleanup for database connection
    this.destroyRef.onDestroy(() => {
      console.log('Closing database connection...');
      this.closeDatabaseConnection(dbConnection);
    });
    
    // Start a timer
    const timerId = setInterval(() => {
      console.log('Timer tick');
    }, 1000);
    
    // Auto-cleanup timer
    this.destroyRef.onDestroy(() => {
      console.log('Clearing timer...');
      clearInterval(timerId);
    });
    
    // Set up event listener
    const handleClick = () => console.log('Document clicked');
    document.addEventListener('click', handleClick);
    
    // Auto-cleanup event listener
    this.destroyRef.onDestroy(() => {
      console.log('Removing event listener...');
      document.removeEventListener('click', handleClick);
    });
  }
  
  addConnection() {
    const connectionId = Date.now();
    this.connections.add(connectionId);
    this.activeConnections = this.connections.size;
    
    // Clean up this specific connection on destroy
    this.destroyRef.onDestroy(() => {
      console.log(`Closing connection ${connectionId}`);
      this.connections.delete(connectionId);
    });
  }
  
  private openDatabaseConnection() {
    return { id: 'db-conn-1', isOpen: true };
  }
  
  private closeDatabaseConnection(connection: any) {
    connection.isOpen = false;
    console.log('Database connection closed');
  }
}
```

**DestroyRef in Services:**

```typescript
// websocket.service.ts
import { Injectable, DestroyRef, inject } from '@angular/core';

@Injectable()
export class WebSocketService {
  private destroyRef = inject(DestroyRef);
  private ws: WebSocket | null = null;
  
  constructor() {
    this.connect();
    
    // Cleanup WebSocket when service is destroyed
    this.destroyRef.onDestroy(() => {
      console.log('Closing WebSocket connection...');
      if (this.ws) {
        this.ws.close();
        this.ws = null;
      }
    });
  }
  
  private connect() {
    this.ws = new WebSocket('ws://localhost:8080');
    
    this.ws.onopen = () => {
      console.log('WebSocket connected');
    };
    
    this.ws.onmessage = (event) => {
      console.log('Message received:', event.data);
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
  }
  
  send(message: string) {
    if (this.ws?.readyState === WebSocket.OPEN) {
      this.ws.send(message);
    }
  }
}

// Usage in component
@Component({
  selector: 'app-chat',
  providers: [WebSocketService], // Service scoped to component
  template: `
    <div>
      <input #msgInput type="text" />
      <button (click)="send(msgInput.value)">Send</button>
    </div>
  `
})
export class ChatComponent {
  private wsService = inject(WebSocketService);
  
  send(message: string) {
    this.wsService.send(message);
  }
}
```

**Utility Function with DestroyRef:**

```typescript
// utils/auto-save.ts
import { DestroyRef } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { debounceTime } from 'rxjs/operators';

export function setupAutoSave(
  form: FormGroup,
  saveFn: (value: any) => void,
  destroyRef: DestroyRef
) {
  const subscription = form.valueChanges
    .pipe(debounceTime(1000))
    .subscribe(value => {
      console.log('Auto-saving...', value);
      saveFn(value);
    });
  
  // Register cleanup via DestroyRef
  destroyRef.onDestroy(() => {
    console.log('Stopping auto-save');
    subscription.unsubscribe();
  });
}

// Usage in component
import { Component, DestroyRef, inject } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { setupAutoSave } from './utils/auto-save';

@Component({
  selector: 'app-form',
  template: `
    <form [formGroup]="form">
      <input formControlName="name" placeholder="Name" />
      <input formControlName="email" placeholder="Email" />
    </form>
  `
})
export class FormComponent {
  private fb = inject(FormBuilder);
  private destroyRef = inject(DestroyRef);
  
  form: FormGroup = this.fb.group({
    name: [''],
    email: ['']
  });
  
  constructor() {
    // Set up auto-save with automatic cleanup
    setupAutoSave(
      this.form,
      (value) => {
        // Save to backend
        console.log('Saving:', value);
      },
      this.destroyRef
    );
  }
}
```

**Comparison with OnDestroy:**

```typescript
// OLD WAY: Using OnDestroy interface
import { Component, OnDestroy } from '@angular/core';

@Component({
  selector: 'app-old-destroy',
  template: `<p>Old way</p>`
})
export class OldDestroyComponent implements OnDestroy {
  private timerId?: number;
  
  constructor() {
    this.timerId = setInterval(() => {
      console.log('Tick');
    }, 1000);
  }
  
  ngOnDestroy() {
    if (this.timerId) {
      clearInterval(this.timerId);
    }
  }
}

// NEW WAY: Using DestroyRef
import { Component, DestroyRef, inject } from '@angular/core';

@Component({
  selector: 'app-new-destroy',
  standalone: true,
  template: `<p>New way</p>`
})
export class NewDestroyComponent {
  private destroyRef = inject(DestroyRef);
  
  constructor() {
    const timerId = setInterval(() => {
      console.log('Tick');
    }, 1000);
    
    // Cleaner: register cleanup inline
    this.destroyRef.onDestroy(() => {
      clearInterval(timerId);
    });
  }
}
```

#### React: Equivalent with useEffect Cleanup

```tsx
// CleanupComponent.tsx
import React, { useEffect } from 'react';

function CleanupComponent() {
  useEffect(() => {
    console.log('Component mounted');
    
    // Cleanup function (equivalent to DestroyRef.onDestroy)
    return () => {
      console.log('Component is being destroyed!');
      console.log('Performing cleanup...');
    };
  }, []);
  
  return (
    <div>
      <h2>Component with Cleanup</h2>
      <p>Check console when this component is destroyed</p>
    </div>
  );
}

export default CleanupComponent;
```

**Resource Manager in React:**

```tsx
// ResourceManager.tsx
import React, { useState, useEffect, useRef } from 'react';

function ResourceManager() {
  const [activeConnections, setActiveConnections] = useState(0);
  const connectionsRef = useRef<Set<number>>(new Set());
  
  useEffect(() => {
    // Simulate opening database connection
    const dbConnection = openDatabaseConnection();
    console.log('Database connection opened');
    
    // Start timer
    const timerId = setInterval(() => {
      console.log('Timer tick');
    }, 1000);
    
    // Set up event listener
    const handleClick = () => console.log('Document clicked');
    document.addEventListener('click', handleClick);
    
    // Cleanup function combines all cleanup logic
    return () => {
      console.log('Closing database connection...');
      closeDatabaseConnection(dbConnection);
      
      console.log('Clearing timer...');
      clearInterval(timerId);
      
      console.log('Removing event listener...');
      document.removeEventListener('click', handleClick);
      
      // Close all connections
      connectionsRef.current.forEach(connectionId => {
        console.log(`Closing connection ${connectionId}`);
      });
      connectionsRef.current.clear();
    };
  }, []);
  
  const addConnection = () => {
    const connectionId = Date.now();
    connectionsRef.current.add(connectionId);
    setActiveConnections(connectionsRef.current.size);
  };
  
  const openDatabaseConnection = () => {
    return { id: 'db-conn-1', isOpen: true };
  };
  
  const closeDatabaseConnection = (connection: any) => {
    connection.isOpen = false;
    console.log('Database connection closed');
  };
  
  return (
    <div className="manager">
      <h2>Resource Manager</h2>
      <p>Managing {activeConnections} connections</p>
      <button onClick={addConnection}>Add Connection</button>
    </div>
  );
}

export default ResourceManager;
```

**WebSocket Service in React:**

```tsx
// useWebSocketService.ts
import { useEffect, useRef } from 'react';

export function useWebSocketService(url: string) {
  const wsRef = useRef<WebSocket | null>(null);
  
  useEffect(() => {
    // Connect
    wsRef.current = new WebSocket(url);
    
    wsRef.current.onopen = () => {
      console.log('WebSocket connected');
    };
    
    wsRef.current.onmessage = (event) => {
      console.log('Message received:', event.data);
    };
    
    wsRef.current.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    // Cleanup function (closes WebSocket on unmount)
    return () => {
      console.log('Closing WebSocket connection...');
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
    };
  }, [url]);
  
  const send = (message: string) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(message);
    }
  };
  
  return { send };
}

// Usage
function ChatComponent() {
  const { send } = useWebSocketService('ws://localhost:8080');
  const [message, setMessage] = React.useState('');
  
  return (
    <div>
      <input
        type="text"
        value={message}
        onChange={(e) => setMessage(e.target.value)}
      />
      <button onClick={() => send(message)}>Send</button>
    </div>
  );
}
```

**Auto-save Utility in React:**

```tsx
// useAutoSave.ts
import { useEffect } from 'react';

export function useAutoSave<T>(
  value: T,
  saveFn: (value: T) => void,
  delay: number = 1000
) {
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      console.log('Auto-saving...', value);
      saveFn(value);
    }, delay);
    
    // Cleanup: cancel pending save
    return () => {
      console.log('Cancelling auto-save');
      clearTimeout(timeoutId);
    };
  }, [value, saveFn, delay]);
}

// Usage
function FormComponent() {
  const [formData, setFormData] = React.useState({
    name: '',
    email: ''
  });
  
  useAutoSave(formData, (data) => {
    // Save to backend
    console.log('Saving:', data);
  });
  
  return (
    <form>
      <input
        type="text"
        value={formData.name}
        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        placeholder="Name"
      />
      <input
        type="email"
        value={formData.email}
        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
        placeholder="Email"
      />
    </form>
  );
}
```

#### Comparison: DestroyRef vs useEffect Cleanup

| Feature | Angular DestroyRef | React useEffect |
|---------|-------------------|-----------------|
| **Syntax** | `destroyRef.onDestroy(() => {})` | `return () => {}` |
| **Multiple Callbacks** | ✅ Register multiple | ⚠️ One per effect |
| **Execution Order** | Registration order | Effect order |
| **Outside Components** | ✅ Works in services | ❌ Hooks only in components |
| **Functional Context** | ✅ Via inject() | ✅ Via custom hooks |
| **Testing** | TestBed cleanup | Mock cleanup |
| **Boilerplate** | Less (for multiple cleanups) | More (one effect per cleanup) |

**Key Differences:**

1. **Multiple Cleanup Callbacks:**
   - **Angular:** Can register multiple `onDestroy()` callbacks that run in order
   - **React:** One cleanup function per useEffect, need multiple effects

2. **Scope:**
   - **Angular:** Works in components, directives, and services
   - **React:** Only in function components or custom hooks

3. **Explicit vs Implicit:**
   - **Angular:** Explicit registration with `onDestroy()`
   - **React:** Implicit return function in useEffect

**When to Use:**
- **Angular DestroyRef:** Modern alternative to OnDestroy—cleaner for multiple cleanup operations, works with inject()
- **React useEffect:** Standard pattern for all cleanup—familiar, well-documented, works with all hooks

**Further Reading:**
- [Angular DestroyRef](https://angular.dev/api/core/DestroyRef)
- [React useEffect Cleanup](https://react.dev/reference/react/useEffect#cleanup-function)

---

## 🟠 Core Concepts {#core-concepts}

### 1. NgModules Deep Dive

**Description:** NgModules are Angular's organizational system for grouping related components, directives, pipes, and services. While standalone components are now preferred, understanding modules is essential for legacy code and advanced patterns like `forRoot()` and `forChild()`.

#### Angular: NgModules Examples
