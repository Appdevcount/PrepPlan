# Phase 8: HTTP & API Communication

> "Any sufficiently complex front-end application eventually needs to talk to a server." Every real-world Angular app fetches data from APIs, sends form submissions, uploads files, authenticates users -- all through HTTP. Angular's `HttpClient` module gives you a battle-tested, Observable-based, interceptor-powered HTTP layer that turns what used to be messy callback chains into clean, composable, testable data streams. This phase teaches you everything about talking to the outside world from Angular.

---

## 8.1 What is HttpClient?

### The Problem: Why Not Just Use `fetch()`?

You might wonder -- JavaScript already has `fetch()` built into the browser. Why does Angular ship its own HTTP client?

```typescript
// Using native fetch() -- this WORKS, but has significant downsides in Angular
async loadUsers() {
  try {
    const response = await fetch('https://api.example.com/users');
    const data = await response.json();
    this.users = data;
  } catch (error) {
    console.error('Failed to load users', error);
  }
}
```

**This approach has real problems in an Angular app:**

| Problem with `fetch()` | How `HttpClient` Solves It |
|---|---|
| Returns Promises -- you can't cancel an in-flight request | Returns Observables -- unsubscribe cancels the request automatically |
| No built-in interceptors -- you manually add auth tokens to every single request | Interceptors let you modify ALL requests/responses in one place |
| No typed responses -- `response.json()` returns `any` | Generics give you fully typed responses: `http.get<User[]>(url)` |
| Hard to test -- you need to mock `window.fetch` globally | Angular provides `HttpClientTestingModule` with a mock controller |
| No automatic JSON parsing -- you call `.json()` manually | Automatically parses JSON responses |
| No progress events for uploads/downloads | Built-in support for upload/download progress tracking |
| No retry logic without external libraries | Combine with RxJS `retry()` operator natively |
| Error handling is inconsistent across browsers | Consistent `HttpErrorResponse` object for all errors |

### How HttpClient Works Internally

```
Your Component
    │
    ▼
Your Service (calls HttpClient methods)
    │
    ▼
HttpClient (creates an Observable)
    │
    ▼
Interceptor Chain (auth token, logging, error handling, etc.)
    │
    ▼
HttpBackend (actually sends the XHR/fetch request)
    │
    ▼
Server (API endpoint)
    │
    ▼ (response comes back)
    │
Interceptor Chain (can transform/log the response)
    │
    ▼
Your Service (receives Observable<T>)
    │
    ▼
Your Component (subscribes and displays data)
```

**Key insight:** `HttpClient` doesn't send the request when you call `http.get()`. It creates an Observable. The request is only sent when something **subscribes** to that Observable. This is called "cold" Observable behavior, and it means:

1. No wasted network calls if nobody subscribes
2. You can transform/combine the Observable before subscribing
3. Unsubscribing cancels the request (saves bandwidth and prevents memory leaks)

### The Five Core Methods

| Method | HTTP Verb | Purpose | Example |
|---|---|---|---|
| `http.get()` | GET | Read/fetch data | Get a list of users |
| `http.post()` | POST | Create new data | Submit a new user form |
| `http.put()` | PUT | Replace existing data entirely | Update an entire user record |
| `http.patch()` | PATCH | Update part of existing data | Change just the user's email |
| `http.delete()` | DELETE | Remove data | Delete a user account |

---

## 8.2 Setting Up HttpClient

### Step 1: Import HttpClientModule

Before you can use `HttpClient` anywhere in your app, you must import `HttpClientModule` in your root module. This is a one-time setup.

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule } from '@angular/common/http';  // <-- Import this

import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    HttpClientModule  // <-- Add it to imports array ONCE, at the root level
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

**Why at the root level?** `HttpClientModule` registers the `HttpClient` service as a singleton. If you import it in multiple modules, you can get multiple instances -- which means interceptors might not apply to all requests. Import it ONCE in `AppModule` (or in a `CoreModule` that is imported once).

> **Angular 15+ Standalone Components:** If you're using standalone components (no `NgModule`), you provide `HttpClient` differently:
>
> ```typescript
> // main.ts (standalone bootstrap)
> import { bootstrapApplication } from '@angular/platform-browser';
> import { provideHttpClient, withInterceptors } from '@angular/common/http';
> import { AppComponent } from './app/app.component';
>
> bootstrapApplication(AppComponent, {
>   providers: [
>     provideHttpClient(withInterceptors([/* your interceptors */]))
>   ]
> });
> ```

### Step 2: Create a Service That Uses HttpClient

**Critical rule: NEVER make HTTP calls directly in components.** Always go through a service.

```bash
# Generate a service for API calls
ng generate service services/api
```

```typescript
// services/api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'  // Available app-wide as a singleton
})
export class ApiService {

  // Angular's DI system injects the HttpClient instance automatically
  constructor(private http: HttpClient) { }

  // Now you can use this.http.get(), this.http.post(), etc.
}
```

### Why HTTP Calls Should Be in Services, NOT Components

This is not just a "best practice" -- it's a fundamental architectural decision. Here's why:

```typescript
// BAD -- HTTP call directly in the component
@Component({ /* ... */ })
export class UserListComponent implements OnInit {
  users: User[] = [];

  constructor(private http: HttpClient) { }  // Direct HttpClient injection

  ngOnInit() {
    // If 5 different components need user data, this code is duplicated 5 times
    this.http.get<User[]>('https://api.example.com/users').subscribe(
      data => this.users = data
    );
  }
}
```

```typescript
// GOOD -- HTTP call in a service, component just consumes data
@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'https://api.example.com/users';

  constructor(private http: HttpClient) { }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }
}

@Component({ /* ... */ })
export class UserListComponent implements OnInit {
  users: User[] = [];

  constructor(private userService: UserService) { }  // Inject the service, not HttpClient

  ngOnInit() {
    this.userService.getUsers().subscribe(data => this.users = data);
  }
}
```

**Why this matters:**

| Concern | Direct HTTP in Component | HTTP in Service |
|---|---|---|
| **Reusability** | Copy-paste the same API call in every component that needs it | Call `userService.getUsers()` from anywhere |
| **URL changes** | Hunt through every component to update the URL | Change it in one place |
| **Caching** | Each component makes its own request | Service can cache and share results |
| **Testing** | Must mock `HttpClient` in every component test | Mock just the service in component tests; test HTTP logic separately |
| **Separation of concerns** | Component knows about HTTP, URLs, headers | Component only knows "I need users" |
| **Interceptor compatibility** | Same | Same (interceptors work at the HttpClient level) |

---

## 8.3 CRUD Operations

Let's build a complete example with a `User` model and a `UserService` that performs all CRUD operations.

### First: Define Your Model

```typescript
// models/user.model.ts
export interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'editor' | 'viewer';
  isActive: boolean;
  createdAt?: string;  // Optional -- server might include this
}
```

**Why use an `interface` and not a `class`?** Interfaces exist only at compile time -- they disappear after TypeScript compiles to JavaScript. This means zero runtime overhead. Classes add extra code to your bundle. For type-checking API responses, interfaces are the right choice. Use classes only if you need methods on the model (e.g., `user.getFullName()`).

---

### 8.3.1 GET Request -- Fetching Data

GET is the most common HTTP operation. You use it to read data without modifying anything on the server.

**Fetching a list of items:**

```typescript
// services/user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  // GET /api/users -- returns an array of User objects
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
    // The generic <User[]> tells TypeScript: "The response body will be an array of User objects"
    // Without it, you'd get Observable<Object> and lose all type safety
  }

  // GET /api/users/5 -- returns a single User object
  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
    // Template literal builds the URL: "http://localhost:3000/api/users/5"
  }
}
```

**Component that uses the GET service:**

```typescript
// components/user-list/user-list.component.ts
import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';
import { User } from '../../models/user.model';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html'
})
export class UserListComponent implements OnInit {
  users: User[] = [];
  isLoading = false;
  errorMessage = '';

  constructor(private userService: UserService) { }

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.userService.getUsers().subscribe({
      // Called when the response arrives successfully
      next: (data: User[]) => {
        this.users = data;
        this.isLoading = false;
      },
      // Called if the request fails (network error, 404, 500, etc.)
      error: (error) => {
        this.errorMessage = 'Failed to load users. Please try again.';
        this.isLoading = false;
        console.error('Error loading users:', error);
      }
      // 'complete' callback is optional -- called when the Observable completes
      // For HTTP requests, complete is called immediately after next (single emission)
    });
  }
}
```

```html
<!-- components/user-list/user-list.component.html -->
<div class="user-list">
  <h2>Users</h2>

  <!-- Loading state -->
  <div *ngIf="isLoading" class="loading">
    <p>Loading users...</p>
  </div>

  <!-- Error state -->
  <div *ngIf="errorMessage" class="error">
    <p>{{ errorMessage }}</p>
    <button (click)="loadUsers()">Retry</button>
  </div>

  <!-- Data state -->
  <table *ngIf="!isLoading && !errorMessage && users.length > 0">
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Role</th>
        <th>Status</th>
      </tr>
    </thead>
    <tbody>
      <tr *ngFor="let user of users">
        <td>{{ user.id }}</td>
        <td>{{ user.name }}</td>
        <td>{{ user.email }}</td>
        <td>{{ user.role }}</td>
        <td>{{ user.isActive ? 'Active' : 'Inactive' }}</td>
      </tr>
    </tbody>
  </table>

  <!-- Empty state -->
  <p *ngIf="!isLoading && !errorMessage && users.length === 0">
    No users found.
  </p>
</div>
```

**What happens step by step:**

1. Component initializes, `ngOnInit()` calls `loadUsers()`
2. `loadUsers()` sets `isLoading = true` and calls `userService.getUsers()`
3. `getUsers()` returns an `Observable<User[]>` (no request sent yet!)
4. `.subscribe()` triggers the actual HTTP GET request
5. Angular's `HttpClient` sends `GET http://localhost:3000/api/users`
6. When the server responds, the `next` callback fires with the parsed JSON
7. We assign the data to `this.users` and set `isLoading = false`
8. Angular's change detection updates the template

---

### 8.3.2 POST Request -- Creating Data

POST sends data to the server to create a new resource. The request includes a body (the data to create).

```typescript
// In user.service.ts -- add this method

  // POST /api/users -- creates a new user and returns the created user (with ID assigned by server)
  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
    // First argument: URL
    // Second argument: request body (automatically serialized to JSON)
    // HttpClient automatically sets Content-Type: application/json
  }
```

**Why `Omit<User, 'id'>`?** When creating a new user, the server assigns the `id`. We don't want the caller to provide one. `Omit<User, 'id'>` creates a type that has all `User` properties except `id`. This is TypeScript helping you avoid bugs at compile time.

**Component that creates a user:**

```typescript
// components/user-form/user-form.component.ts
import { Component } from '@angular/core';
import { UserService } from '../../services/user.service';
import { User } from '../../models/user.model';

@Component({
  selector: 'app-user-form',
  templateUrl: './user-form.component.html'
})
export class UserFormComponent {
  // Form model
  newUser = {
    name: '',
    email: '',
    role: 'viewer' as 'admin' | 'editor' | 'viewer',
    isActive: true
  };

  isSubmitting = false;
  successMessage = '';
  errorMessage = '';

  constructor(private userService: UserService) { }

  onSubmit(): void {
    this.isSubmitting = true;
    this.successMessage = '';
    this.errorMessage = '';

    this.userService.createUser(this.newUser).subscribe({
      next: (createdUser: User) => {
        // The server returns the newly created user WITH the assigned id
        this.successMessage = `User "${createdUser.name}" created with ID ${createdUser.id}`;
        this.isSubmitting = false;
        this.resetForm();
      },
      error: (error) => {
        this.errorMessage = 'Failed to create user. Please try again.';
        this.isSubmitting = false;
        console.error('Error creating user:', error);
      }
    });
  }

  resetForm(): void {
    this.newUser = { name: '', email: '', role: 'viewer', isActive: true };
  }
}
```

```html
<!-- components/user-form/user-form.component.html -->
<div class="user-form">
  <h2>Create New User</h2>

  <div *ngIf="successMessage" class="success">{{ successMessage }}</div>
  <div *ngIf="errorMessage" class="error">{{ errorMessage }}</div>

  <form (ngSubmit)="onSubmit()">
    <div>
      <label for="name">Name:</label>
      <input id="name" [(ngModel)]="newUser.name" name="name" required />
    </div>

    <div>
      <label for="email">Email:</label>
      <input id="email" [(ngModel)]="newUser.email" name="email" type="email" required />
    </div>

    <div>
      <label for="role">Role:</label>
      <select id="role" [(ngModel)]="newUser.role" name="role">
        <option value="admin">Admin</option>
        <option value="editor">Editor</option>
        <option value="viewer">Viewer</option>
      </select>
    </div>

    <div>
      <label>
        <input type="checkbox" [(ngModel)]="newUser.isActive" name="isActive" />
        Active
      </label>
    </div>

    <button type="submit" [disabled]="isSubmitting">
      {{ isSubmitting ? 'Creating...' : 'Create User' }}
    </button>
  </form>
</div>
```

---

### 8.3.3 PUT Request -- Full Update

PUT replaces the **entire** resource on the server. If you send a PUT request with only `{ name: 'New Name' }`, the server should replace the whole user record with just that -- meaning all other fields (email, role, etc.) would be lost. That's why you always send the complete object.

```typescript
// In user.service.ts -- add this method

  // PUT /api/users/5 -- replaces the entire user record
  updateUser(user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${user.id}`, user);
    // The complete user object is sent as the request body
    // The URL identifies WHICH user to update (by id)
    // The body contains WHAT the user should look like now
  }
```

**Component usage:**

```typescript
// In an edit component
saveUser(): void {
  // this.user contains ALL fields -- name, email, role, isActive, etc.
  this.userService.updateUser(this.user).subscribe({
    next: (updatedUser: User) => {
      console.log('User fully updated:', updatedUser);
      // Navigate back to the list or show success message
    },
    error: (error) => {
      console.error('Update failed:', error);
    }
  });
}
```

---

### 8.3.4 PATCH Request -- Partial Update

PATCH is different from PUT -- it only updates the fields you send. The server keeps all other fields unchanged. This is more efficient for small changes.

```typescript
// In user.service.ts -- add this method

  // PATCH /api/users/5 -- updates only the provided fields
  patchUser(id: number, changes: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.apiUrl}/${id}`, changes);
    // Partial<User> means: any subset of User properties
    // You can send { isActive: false } and only the isActive field changes
  }
```

**When to use PATCH vs PUT:**

```typescript
// Use PATCH when you're changing a small part of the record
// Example: deactivating a user -- only the isActive field changes
this.userService.patchUser(userId, { isActive: false }).subscribe({
  next: (updatedUser) => console.log('User deactivated'),
  error: (error) => console.error('Failed to deactivate:', error)
});

// Use PUT when you're replacing the entire record
// Example: full edit form where the user can change any field
this.userService.updateUser(this.completeUserObject).subscribe({
  next: (updatedUser) => console.log('User fully updated'),
  error: (error) => console.error('Failed to update:', error)
});
```

**Real-world rule of thumb:**
- **PUT** = "Here's the complete new version of this resource, replace everything"
- **PATCH** = "Here are just the changes, keep everything else the same"

---

### 8.3.5 DELETE Request -- Removing Data

DELETE removes a resource from the server. It typically doesn't have a request body.

```typescript
// In user.service.ts -- add this method

  // DELETE /api/users/5 -- removes the user
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
    // <void> because DELETE usually returns no body (just a 204 No Content status)
    // Some APIs return the deleted object -- in that case use Observable<User>
  }
```

**Component with delete confirmation:**

```typescript
// In user-list.component.ts -- add this method

  deleteUser(user: User): void {
    // Always confirm before deleting!
    const confirmed = confirm(`Are you sure you want to delete ${user.name}?`);
    if (!confirmed) return;

    this.userService.deleteUser(user.id).subscribe({
      next: () => {
        // Remove the user from the local array (no need to refetch the entire list)
        this.users = this.users.filter(u => u.id !== user.id);
        console.log(`User ${user.name} deleted successfully`);
      },
      error: (error) => {
        console.error('Failed to delete user:', error);
        this.errorMessage = `Failed to delete ${user.name}. Please try again.`;
      }
    });
  }
```

```html
<!-- Add a delete button to each row in the user table -->
<tr *ngFor="let user of users">
  <td>{{ user.id }}</td>
  <td>{{ user.name }}</td>
  <td>{{ user.email }}</td>
  <td>{{ user.role }}</td>
  <td>{{ user.isActive ? 'Active' : 'Inactive' }}</td>
  <td>
    <button (click)="deleteUser(user)" class="btn-danger">Delete</button>
  </td>
</tr>
```

---

### Summary of All CRUD Methods

```typescript
// The complete UserService with all CRUD operations
@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  // CREATE
  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user);
  }

  // READ (all)
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }

  // READ (single)
  getUserById(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }

  // UPDATE (full replace)
  updateUser(user: User): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${user.id}`, user);
  }

  // UPDATE (partial)
  patchUser(id: number, changes: Partial<User>): Observable<User> {
    return this.http.patch<User>(`${this.apiUrl}/${id}`, changes);
  }

  // DELETE
  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

---

## 8.4 Handling Responses

### 8.4.1 The subscribe() Pattern

Every HTTP call returns an Observable. You must subscribe to it to trigger the request and receive the response. The `subscribe()` method accepts an Observer object with three optional callbacks:

```typescript
this.userService.getUsers().subscribe({
  next: (users) => {
    // SUCCESS -- called when data arrives
    // For HTTP requests, this fires exactly ONCE with the full response
    this.users = users;
  },
  error: (error) => {
    // FAILURE -- called if the request fails
    // Receives an HttpErrorResponse object
    // The Observable terminates after an error (no more emissions)
    console.error('Request failed:', error);
  },
  complete: () => {
    // DONE -- called when the Observable completes
    // For HTTP requests, this fires right after 'next' (since HTTP emits once then completes)
    // Rarely used for HTTP, more useful for WebSocket streams
    console.log('Request completed');
  }
});
```

**Important:** For HTTP Observables, the emission pattern is always:
- **Success:** `next` (once) -> `complete` (once)
- **Failure:** `error` (once, and nothing else -- no `complete` after `error`)

### 8.4.2 Using pipe() with RxJS Operators

`pipe()` lets you transform the Observable BEFORE subscribing. This is where RxJS operators shine.

```typescript
import { Observable, throwError } from 'rxjs';
import { map, tap, catchError, retry } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl).pipe(
      // tap -- Side effects. Does NOT modify the data. Perfect for logging.
      tap(users => console.log(`Fetched ${users.length} users`)),

      // map -- Transform the data. Returns a new value.
      map(users => users.filter(u => u.isActive)),
      // Now the subscriber only gets active users

      // catchError -- Handle errors. Must return a new Observable or throw.
      catchError(error => {
        console.error('Failed to fetch users:', error);
        // Return an empty array so the component doesn't break
        return of([] as User[]);  // 'of' creates an Observable that emits this value
      })
    );
  }
}
```

**Why use `pipe()` in the service instead of handling everything in the component?**

Because the service is the "data expert." It knows:
- How to transform API responses into the shape the app needs
- What errors mean and how to handle them
- Whether to cache, retry, or fall back to defaults

The component should just receive clean, ready-to-display data.

### 8.4.3 Common RxJS Operators for HTTP

Here's what each operator does and when to use it:

**`tap()` -- Side effects without modifying data:**

```typescript
// Use tap for: logging, caching, triggering analytics, debugging
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(this.apiUrl).pipe(
    tap({
      next: (data) => console.log('API returned:', data),
      error: (err) => console.error('API error:', err),
      complete: () => console.log('Request finished')
    })
  );
}
```

**`map()` -- Transform the response:**

```typescript
// Use map when: the API returns data in a different shape than you need
// Example: API wraps data in { data: [...], meta: {...} }
interface ApiResponse<T> {
  data: T;
  meta: { total: number; page: number };
}

getUsers(): Observable<User[]> {
  return this.http.get<ApiResponse<User[]>>(this.apiUrl).pipe(
    map(response => response.data)  // Extract just the data array
  );
}

// Example: Transform property names (API uses snake_case, you want camelCase)
getUsers(): Observable<User[]> {
  return this.http.get<any[]>(this.apiUrl).pipe(
    map(users => users.map(u => ({
      id: u.id,
      name: u.full_name,       // API returns full_name
      email: u.email_address,   // API returns email_address
      isActive: u.is_active     // API returns is_active
    })))
  );
}
```

**`catchError()` -- Handle errors gracefully:**

```typescript
import { catchError, throwError, of } from 'rxjs';

// Pattern 1: Return a fallback value
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(this.apiUrl).pipe(
    catchError(error => {
      console.error('Error:', error);
      return of([]);  // Return empty array as fallback
      // The subscriber's next() fires with [], error() is NOT called
    })
  );
}

// Pattern 2: Re-throw a transformed error
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(this.apiUrl).pipe(
    catchError(error => {
      // Transform the error into something meaningful for the component
      const message = this.getErrorMessage(error);
      return throwError(() => new Error(message));
      // The subscriber's error() fires with this new Error
    })
  );
}

// Helper to create user-friendly error messages
private getErrorMessage(error: HttpErrorResponse): string {
  if (error.status === 0) {
    // Network error -- server is down or no internet
    return 'Unable to connect to the server. Check your internet connection.';
  }
  if (error.status === 404) {
    return 'The requested resource was not found.';
  }
  if (error.status === 403) {
    return 'You do not have permission to access this resource.';
  }
  if (error.status === 500) {
    return 'The server encountered an error. Please try again later.';
  }
  // Fallback
  return `An unexpected error occurred (${error.status}).`;
}
```

### 8.4.4 Retry Logic

Sometimes network requests fail temporarily (server is busy, network hiccup, etc.). Instead of immediately showing an error, you can retry automatically.

```typescript
import { retry, retryWhen, delay, take, catchError } from 'rxjs/operators';
import { throwError, timer } from 'rxjs';

// Simple retry -- retry up to 3 times immediately
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(this.apiUrl).pipe(
    retry(3),  // If the request fails, retry up to 3 times
    // Total attempts: 1 original + 3 retries = 4
    catchError(error => {
      // Only reaches here if ALL 4 attempts failed
      return throwError(() => new Error('Failed after 3 retries'));
    })
  );
}

// Retry with delay -- wait before retrying (better for server overload)
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(this.apiUrl).pipe(
    retry({
      count: 3,     // Maximum 3 retries
      delay: 1000   // Wait 1 second between retries
    }),
    catchError(error => {
      return throwError(() => new Error('Failed after 3 retries with delay'));
    })
  );
}

// Exponential backoff -- increasingly longer delays (the gold standard for production)
// First retry after 1s, second after 2s, third after 4s
getUsers(): Observable<User[]> {
  return this.http.get<User[]>(this.apiUrl).pipe(
    retry({
      count: 3,
      delay: (error, retryCount) => {
        // retryCount starts at 1
        const delayMs = Math.pow(2, retryCount - 1) * 1000;  // 1s, 2s, 4s
        console.log(`Retry #${retryCount} after ${delayMs}ms`);
        return timer(delayMs);  // timer() creates an Observable that emits after the delay
      }
    }),
    catchError(error => {
      return throwError(() => new Error('Failed after retries with exponential backoff'));
    })
  );
}
```

**When to retry vs. when NOT to:**

| Scenario | Retry? | Why |
|---|---|---|
| GET request failed with 500 | Yes | Server might be temporarily overloaded |
| GET request failed with 0 (network) | Yes | User might regain internet shortly |
| POST request failed with 500 | Be careful | Retrying a POST could create duplicate records |
| Request failed with 401 | No | Retrying won't help -- the user needs to log in again |
| Request failed with 404 | No | The resource doesn't exist -- retrying won't create it |
| Request failed with 400 | No | Bad request -- the client sent invalid data |

### 8.4.5 The Complete Error Handling Pattern

Here's a production-grade pattern that combines everything:

```typescript
import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, retry, tap } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl).pipe(
      // Step 1: Log the response for debugging (remove in production)
      tap(data => console.log('Raw API response:', data)),

      // Step 2: Retry transient failures
      retry({ count: 2, delay: 1000 }),

      // Step 3: Catch and transform errors
      catchError(this.handleError)
    );
  }

  createUser(user: Omit<User, 'id'>): Observable<User> {
    return this.http.post<User>(this.apiUrl, user).pipe(
      // No retry for POST -- could create duplicates
      catchError(this.handleError)
    );
  }

  // Centralized error handler -- reused across all methods
  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An unknown error occurred';

    if (error.status === 0) {
      // Client-side or network error
      errorMessage = 'Network error. Please check your connection.';
    } else {
      // Server-side error
      // The error body might contain a message from the server
      errorMessage = error.error?.message || `Server error: ${error.status} ${error.statusText}`;
    }

    console.error(`HTTP Error [${error.status}]:`, errorMessage);

    // throwError creates an Observable that immediately errors
    // The component's error callback will receive this Error
    return throwError(() => new Error(errorMessage));
  }
}
```

---

## 8.5 HTTP Headers and Options

### 8.5.1 Setting Custom Headers

Many APIs require specific headers -- authentication tokens, content types, custom headers for API versioning, etc.

```typescript
import { HttpClient, HttpHeaders } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  // Method 1: Create headers object and pass as options
  getUsersWithAuth(): Observable<User[]> {
    const headers = new HttpHeaders({
      'Authorization': 'Bearer my-jwt-token-here',
      'Content-Type': 'application/json',
      'X-Custom-Header': 'my-custom-value'
    });

    return this.http.get<User[]>(this.apiUrl, { headers });
    // The second argument to get() is an options object
  }

  // Method 2: Build headers with chaining (HttpHeaders is immutable!)
  getUsersWithChainedHeaders(): Observable<User[]> {
    // IMPORTANT: HttpHeaders is IMMUTABLE
    // Each .set() or .append() returns a NEW HttpHeaders object
    const headers = new HttpHeaders()
      .set('Authorization', 'Bearer my-jwt-token-here')
      .set('Accept', 'application/json')
      .set('X-Request-ID', crypto.randomUUID());

    // BAD -- this does NOT work because HttpHeaders is immutable:
    // const headers = new HttpHeaders();
    // headers.set('Authorization', '...');  // Returns a new object, doesn't modify 'headers'

    return this.http.get<User[]>(this.apiUrl, { headers });
  }

  // Method 3: Pass headers directly in the options (most concise)
  getUsersInline(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl, {
      headers: { 'Authorization': 'Bearer token', 'Accept': 'application/json' }
      // You can pass a plain object -- Angular converts it to HttpHeaders internally
    });
  }
}
```

**Why is `HttpHeaders` immutable?** This prevents accidental mutation. If you pass a headers object to a function, that function can't change your original headers. Immutability makes the code more predictable and thread-safe.

### 8.5.2 HttpParams for Query Parameters

Query parameters are the `?key=value&other=thing` part of URLs. Instead of manually building URL strings, use `HttpParams` for a clean, bug-free approach.

```typescript
import { HttpClient, HttpParams } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  // Search users with query parameters
  // Resulting URL: /api/users?role=admin&isActive=true&page=1&limit=10
  searchUsers(role: string, isActive: boolean, page: number, limit: number): Observable<User[]> {
    // HttpParams is also IMMUTABLE -- each .set() returns a new object
    const params = new HttpParams()
      .set('role', role)
      .set('isActive', isActive.toString())  // Values must be strings
      .set('page', page.toString())
      .set('limit', limit.toString());

    return this.http.get<User[]>(this.apiUrl, { params });
  }

  // Alternative: pass params as a plain object (Angular 5+)
  searchUsersSimple(filters: { role?: string; page?: number }): Observable<User[]> {
    // Only include params that have values
    let params = new HttpParams();
    if (filters.role) {
      params = params.set('role', filters.role);
    }
    if (filters.page) {
      params = params.set('page', filters.page.toString());
    }

    return this.http.get<User[]>(this.apiUrl, { params });
  }

  // Using fromObject for cleaner syntax when you have all params ready
  searchUsersFromObject(): Observable<User[]> {
    const params = new HttpParams({
      fromObject: {
        role: 'admin',
        page: '1',
        limit: '20',
        sort: 'name',
        order: 'asc'
      }
    });

    return this.http.get<User[]>(this.apiUrl, { params });
    // URL becomes: /api/users?role=admin&page=1&limit=20&sort=name&order=asc
  }
}
```

### 8.5.3 Observing Different Response Types

By default, `HttpClient` returns just the response body. But sometimes you need headers, status codes, or progress events.

```typescript
import { HttpClient, HttpResponse, HttpEvent, HttpEventType } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = 'http://localhost:3000/api/users';

  constructor(private http: HttpClient) { }

  // Default: observe 'body' -- returns just the parsed JSON body
  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
    // Same as: this.http.get<User[]>(this.apiUrl, { observe: 'body' })
  }

  // observe: 'response' -- returns the FULL HttpResponse object
  // Use this when you need status codes, headers, etc.
  getUsersWithFullResponse(): Observable<HttpResponse<User[]>> {
    return this.http.get<User[]>(this.apiUrl, { observe: 'response' });
  }

  // observe: 'events' -- returns ALL HTTP events (progress, sent, response)
  // Use this for file uploads/downloads where you need progress tracking
  uploadFile(file: File): Observable<HttpEvent<any>> {
    const formData = new FormData();
    formData.append('file', file);

    return this.http.post('http://localhost:3000/api/upload', formData, {
      observe: 'events',
      reportProgress: true  // Enable progress tracking
    });
  }
}
```

**Using the full response:**

```typescript
// In a component
this.userService.getUsersWithFullResponse().subscribe({
  next: (response: HttpResponse<User[]>) => {
    console.log('Status code:', response.status);           // 200
    console.log('Status text:', response.statusText);       // "OK"
    console.log('Headers:', response.headers.get('X-Total-Count'));  // Custom header
    console.log('Body:', response.body);                    // User[]

    // Useful for pagination: read total count from a custom header
    this.totalCount = Number(response.headers.get('X-Total-Count'));
    this.users = response.body || [];
  }
});
```

**Using progress events for file upload:**

```typescript
// In a component
uploadProgress = 0;

onFileSelected(event: Event): void {
  const file = (event.target as HTMLInputElement).files?.[0];
  if (!file) return;

  this.userService.uploadFile(file).subscribe({
    next: (event: HttpEvent<any>) => {
      switch (event.type) {
        case HttpEventType.UploadProgress:
          // Calculate upload percentage
          if (event.total) {
            this.uploadProgress = Math.round(100 * event.loaded / event.total);
            console.log(`Upload progress: ${this.uploadProgress}%`);
          }
          break;

        case HttpEventType.Response:
          // Upload complete!
          console.log('Upload complete:', event.body);
          this.uploadProgress = 100;
          break;
      }
    },
    error: (error) => {
      console.error('Upload failed:', error);
    }
  });
}
```

### 8.5.4 responseType Options

By default, `HttpClient` assumes the response is JSON and parses it automatically. But APIs can return other formats.

```typescript
@Injectable({ providedIn: 'root' })
export class FileService {
  constructor(private http: HttpClient) { }

  // Default: 'json' -- parses response as JSON
  getJsonData(): Observable<any> {
    return this.http.get('http://localhost:3000/api/data');
    // Same as: this.http.get('...', { responseType: 'json' })
  }

  // 'text' -- returns response as a plain string
  getTextContent(): Observable<string> {
    return this.http.get('http://localhost:3000/api/readme', {
      responseType: 'text'
    });
  }

  // 'blob' -- returns response as a Blob (for file downloads)
  downloadFile(fileId: string): Observable<Blob> {
    return this.http.get(`http://localhost:3000/api/files/${fileId}`, {
      responseType: 'blob'
    });
  }

  // 'arraybuffer' -- returns raw binary data (for low-level processing)
  getBinaryData(): Observable<ArrayBuffer> {
    return this.http.get('http://localhost:3000/api/binary', {
      responseType: 'arraybuffer'
    });
  }
}
```

**Practical example -- downloading a file and triggering the browser's download dialog:**

```typescript
// In a component
downloadReport(): void {
  this.fileService.downloadFile('report-2024').subscribe({
    next: (blob: Blob) => {
      // Create a URL for the blob
      const url = window.URL.createObjectURL(blob);
      // Create a temporary <a> element to trigger the download
      const link = document.createElement('a');
      link.href = url;
      link.download = 'report-2024.pdf';  // Set the filename
      link.click();
      // Clean up
      window.URL.revokeObjectURL(url);
    },
    error: (error) => {
      console.error('Download failed:', error);
    }
  });
}
```

---

## 8.6 HTTP Interceptors

### What Are Interceptors?

Interceptors are **middleware for HTTP requests**. They sit between your application code and the actual network request, allowing you to inspect and transform every request and/or response that flows through `HttpClient`.

```
Your Service
    │
    ▼
HttpClient.get() / .post() / etc.
    │
    ▼
┌─────────────────────────────┐
│ Interceptor 1 (Auth)        │  ← Adds JWT token to Authorization header
│         │                   │
│         ▼                   │
│ Interceptor 2 (Logging)     │  ← Logs request URL, method, and timing
│         │                   │
│         ▼                   │
│ Interceptor 3 (Error)       │  ← Catches and transforms errors globally
│         │                   │
│         ▼                   │
│ Interceptor 4 (Loading)     │  ← Shows/hides loading spinner
└─────────────────────────────┘
    │
    ▼
HttpBackend (actual network request)
    │
    ▼ (response travels back UP through the chain in REVERSE order)
```

**Why interceptors are powerful:**
- **DRY (Don't Repeat Yourself):** Instead of adding `Authorization: Bearer token` to every single HTTP call in every service, do it ONCE in an interceptor
- **Separation of concerns:** Services focus on business logic; interceptors handle cross-cutting concerns (auth, logging, error handling)
- **Composable:** Each interceptor handles ONE thing, and they chain together
- **Global:** They apply to ALL HTTP requests made through `HttpClient`

### Creating Interceptors

```bash
# Generate an interceptor using the CLI
ng generate interceptor interceptors/auth
ng generate interceptor interceptors/error
ng generate interceptor interceptors/loading
ng generate interceptor interceptors/logging
```

---

### 8.6.1 Auth Interceptor -- Adding JWT Token to Every Request

This is the most common interceptor. It automatically attaches the JWT (JSON Web Token) to every outgoing request, so your services don't need to worry about authentication.

```typescript
// interceptors/auth.interceptor.ts
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor
} from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  // The intercept method is called for EVERY HTTP request
  intercept(
    request: HttpRequest<unknown>,  // The outgoing request
    next: HttpHandler               // The next handler in the chain
  ): Observable<HttpEvent<unknown>> {

    // Step 1: Get the auth token (from localStorage, a service, etc.)
    const authToken = localStorage.getItem('auth_token');

    // Step 2: If we have a token, clone the request and add the header
    if (authToken) {
      // IMPORTANT: HttpRequest is IMMUTABLE -- you cannot modify it directly
      // You must clone() it with the desired changes
      const authRequest = request.clone({
        setHeaders: {
          Authorization: `Bearer ${authToken}`
        }
        // setHeaders MERGES with existing headers (doesn't replace them)
      });

      // Step 3: Pass the MODIFIED request to the next handler
      return next.handle(authRequest);
    }

    // If no token, pass the ORIGINAL request unchanged
    return next.handle(request);
  }
}
```

**Why clone?** `HttpRequest` is immutable for the same reason `HttpHeaders` is -- to prevent unexpected side effects. If interceptors could mutate requests, one interceptor's changes could unexpectedly affect another. Cloning ensures each interceptor works with a predictable state.

**Advanced: Only add token for your own API, not third-party APIs:**

```typescript
intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
  const authToken = localStorage.getItem('auth_token');

  // Only add the token if the request is going to YOUR API
  // Don't send your JWT to third-party APIs (Google Maps, Stripe, etc.)
  const isApiRequest = request.url.startsWith('http://localhost:3000/api') ||
                       request.url.startsWith('https://myapp.com/api');

  if (authToken && isApiRequest) {
    const authRequest = request.clone({
      setHeaders: { Authorization: `Bearer ${authToken}` }
    });
    return next.handle(authRequest);
  }

  return next.handle(request);
}
```

---

### 8.6.2 Error Interceptor -- Global Error Handling

Instead of handling errors in every service method, you can catch and transform errors globally.

```typescript
// interceptors/error.interceptor.ts
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';

@Injectable()
export class ErrorInterceptor implements HttpInterceptor {

  constructor(private router: Router) { }

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    return next.handle(request).pipe(
      // catchError on the RESPONSE -- intercept errors coming back from the server
      catchError((error: HttpErrorResponse) => {

        // Handle specific HTTP status codes globally
        switch (error.status) {
          case 401:
            // Unauthorized -- token expired or invalid
            // Clear stored auth data and redirect to login
            localStorage.removeItem('auth_token');
            this.router.navigate(['/login'], {
              queryParams: { returnUrl: this.router.url }
            });
            break;

          case 403:
            // Forbidden -- user doesn't have permission
            this.router.navigate(['/forbidden']);
            break;

          case 404:
            // Not Found -- resource doesn't exist
            // Let the calling service handle this (they might want to show a specific message)
            break;

          case 500:
            // Internal Server Error
            console.error('Server error occurred:', error.message);
            // Could show a global notification/toast
            break;

          case 0:
            // Network error -- no internet or server is down
            console.error('Network error -- server unreachable');
            break;
        }

        // Re-throw the error so services/components can ALSO handle it if needed
        return throwError(() => error);
      })
    );
  }
}
```

**Key insight:** The error interceptor catches errors, handles global concerns (like redirecting on 401), but still re-throws the error. This way, individual services can also handle errors in their own specific way. It's a layered approach.

---

### 8.6.3 Loading Interceptor -- Show/Hide Loading Spinner

This interceptor tracks active HTTP requests and shows/hides a loading indicator automatically.

**First, create a loading service:**

```typescript
// services/loading.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class LoadingService {
  // BehaviorSubject holds the current value and emits it to new subscribers
  private loadingSubject = new BehaviorSubject<boolean>(false);
  loading$ = this.loadingSubject.asObservable();  // Public read-only Observable

  private activeRequests = 0;

  show(): void {
    this.activeRequests++;
    this.loadingSubject.next(true);
  }

  hide(): void {
    this.activeRequests--;
    // Only hide when ALL requests are complete
    if (this.activeRequests <= 0) {
      this.activeRequests = 0;  // Safety: prevent negative count
      this.loadingSubject.next(false);
    }
  }
}
```

**The loading interceptor:**

```typescript
// interceptors/loading.interceptor.ts
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { finalize } from 'rxjs/operators';
import { LoadingService } from '../services/loading.service';

@Injectable()
export class LoadingInterceptor implements HttpInterceptor {

  constructor(private loadingService: LoadingService) { }

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Show the loading indicator when a request starts
    this.loadingService.show();

    return next.handle(request).pipe(
      // finalize() runs when the Observable completes OR errors
      // This guarantees the loading indicator is hidden, even if the request fails
      finalize(() => {
        this.loadingService.hide();
      })
    );
  }
}
```

**Using the loading service in a component (e.g., app.component.html):**

```typescript
// app.component.ts
import { Component } from '@angular/core';
import { LoadingService } from './services/loading.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent {
  constructor(public loadingService: LoadingService) { }
}
```

```html
<!-- app.component.html -->
<!-- Global loading overlay that appears during ANY HTTP request -->
<div *ngIf="loadingService.loading$ | async" class="loading-overlay">
  <div class="spinner">Loading...</div>
</div>

<router-outlet></router-outlet>
```

**How `finalize()` works:** It's like a `finally` block in try/catch/finally. Whether the Observable completes successfully or errors out, `finalize()` always runs. This prevents the loading spinner from getting "stuck" on screen after a failed request.

---

### 8.6.4 Logging Interceptor -- Log All Requests and Responses

Incredibly useful during development. Logs every request/response with timing information.

```typescript
// interceptors/logging.interceptor.ts
import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpResponse
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class LoggingInterceptor implements HttpInterceptor {

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Record the start time
    const startTime = Date.now();

    // Log the outgoing request
    console.log(`[HTTP] --> ${request.method} ${request.urlWithParams}`);
    if (request.body) {
      console.log('[HTTP] Request body:', request.body);
    }

    return next.handle(request).pipe(
      tap({
        next: (event: HttpEvent<unknown>) => {
          // Only log the final response (not intermediate events like progress)
          if (event instanceof HttpResponse) {
            const elapsed = Date.now() - startTime;
            console.log(
              `[HTTP] <-- ${request.method} ${request.urlWithParams} ` +
              `${event.status} (${elapsed}ms)`
            );
          }
        },
        error: (error) => {
          const elapsed = Date.now() - startTime;
          console.error(
            `[HTTP] <-- ${request.method} ${request.urlWithParams} ` +
            `FAILED ${error.status} (${elapsed}ms)`,
            error.message
          );
        }
      })
    );
  }
}
```

**Sample console output:**

```
[HTTP] --> GET http://localhost:3000/api/users?role=admin
[HTTP] <-- GET http://localhost:3000/api/users?role=admin 200 (142ms)

[HTTP] --> POST http://localhost:3000/api/users
[HTTP] Request body: { name: "Alice", email: "alice@example.com", role: "editor" }
[HTTP] <-- POST http://localhost:3000/api/users 201 (87ms)

[HTTP] --> DELETE http://localhost:3000/api/users/42
[HTTP] <-- DELETE http://localhost:3000/api/users/42 FAILED 403 (65ms) Forbidden
```

---

### 8.6.5 Registering Interceptors

Interceptors must be registered as providers using the `HTTP_INTERCEPTORS` injection token. Angular doesn't discover them automatically.

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';

import { AppComponent } from './app.component';
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { LoggingInterceptor } from './interceptors/logging.interceptor';
import { LoadingInterceptor } from './interceptors/loading.interceptor';
import { ErrorInterceptor } from './interceptors/error.interceptor';

@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule, HttpClientModule],
  providers: [
    // Interceptors execute in the ORDER they are listed here
    // Request:  Logging → Auth → Loading → Error → (Server)
    // Response: Error → Loading → Auth → Logging → (Your Code)
    {
      provide: HTTP_INTERCEPTORS,
      useClass: LoggingInterceptor,
      multi: true  // CRITICAL: 'multi: true' tells Angular this is ONE OF MANY interceptors
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: LoadingInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,
      multi: true
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

**What does `multi: true` do?** Normally, Angular DI replaces the previous value for the same token. With `multi: true`, Angular collects ALL values into an array. So `HTTP_INTERCEPTORS` becomes an array of all your interceptors, and Angular calls them in order.

**If you forget `multi: true`:** Only the LAST registered interceptor will work, and all previous ones will be silently replaced. This is a very common mistake.

### 8.6.6 Interceptor Chain and Order Explained

The order you register interceptors MATTERS. Think of it as a tunnel:

```
REQUEST goes IN through the tunnel (left to right):

  [Logging] → [Auth] → [Loading] → [Error] → ... → SERVER

RESPONSE comes BACK through the tunnel (right to left):

  SERVER → ... → [Error] → [Loading] → [Auth] → [Logging]
```

**Why order matters -- practical example:**

1. **Logging first:** Logs the request BEFORE Auth adds the token, so you can see the "raw" request. Logs the response AFTER Error has handled errors, so you see the final result.
2. **Auth second:** Adds the JWT token before the request reaches the server. This happens before Loading starts tracking (which is fine).
3. **Loading third:** Starts the spinner after auth is added. Stops the spinner before error handling.
4. **Error last (before server):** Catches errors from the server and can transform them. Since it's last in the outgoing chain, it's first to see the response coming back.

**Recommended order for most applications:**

```
1. Logging       -- Log raw requests
2. Auth          -- Add authentication tokens
3. Cache         -- Check cache before hitting the network (if you have one)
4. Loading       -- Track active requests
5. Error         -- Handle errors globally
```

> **Angular 15+ Standalone approach with functional interceptors:**
>
> ```typescript
> // main.ts
> import { provideHttpClient, withInterceptors } from '@angular/common/http';
> import { authInterceptor } from './interceptors/auth.interceptor';
> import { loggingInterceptor } from './interceptors/logging.interceptor';
>
> bootstrapApplication(AppComponent, {
>   providers: [
>     provideHttpClient(
>       withInterceptors([loggingInterceptor, authInterceptor])
>     )
>   ]
> });
>
> // Functional interceptor (simpler than class-based)
> // interceptors/auth.interceptor.ts
> import { HttpInterceptorFn } from '@angular/common/http';
>
> export const authInterceptor: HttpInterceptorFn = (req, next) => {
>   const token = localStorage.getItem('auth_token');
>   if (token) {
>     const authReq = req.clone({
>       setHeaders: { Authorization: `Bearer ${token}` }
>     });
>     return next(authReq);
>   }
>   return next(req);
> };
> ```

---

## 8.7 Environment Configuration

### Why You Need Environment Files

Your Angular app will run in different environments (development, staging, production), and each will have different API URLs, feature flags, and settings. Hardcoding these values is a recipe for bugs.

```typescript
// BAD -- hardcoded API URL
private apiUrl = 'http://localhost:3000/api/users';
// What happens when you deploy to production? You have to find and change every single URL.
```

### Angular Environment Files

Angular CLI creates environment files by default:

```
src/
  environments/
    environment.ts           ← Used during development (ng serve)
    environment.prod.ts      ← Used for production build (ng build --configuration production)
```

**Development environment:**

```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiBaseUrl: 'http://localhost:3000/api',
  enableLogging: true,
  enableMockData: false,
  authTokenKey: 'dev_auth_token',
  appTitle: 'MyApp (DEV)'
};
```

**Production environment:**

```typescript
// src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiBaseUrl: 'https://api.myapp.com/api',
  enableLogging: false,       // Don't pollute production console
  enableMockData: false,
  authTokenKey: 'auth_token',
  appTitle: 'MyApp'
};
```

### How Angular Swaps Them

In `angular.json`, the build configuration specifies file replacements:

```json
{
  "configurations": {
    "production": {
      "fileReplacements": [
        {
          "replace": "src/environments/environment.ts",
          "with": "src/environments/environment.prod.ts"
        }
      ]
    }
  }
}
```

When you run `ng build --configuration production`, Angular literally replaces the file. Your code always imports from `environment.ts`, but the build system swaps in the production version. No code changes needed.

### Using Environment Variables in Services

```typescript
// services/user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';  // Always import from environment.ts (not .prod.ts)
import { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserService {
  // Use the environment variable for the base URL
  private apiUrl = `${environment.apiBaseUrl}/users`;

  constructor(private http: HttpClient) { }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
    // In dev:  GET http://localhost:3000/api/users
    // In prod: GET https://api.myapp.com/api/users
    // Same code, different behavior based on build configuration
  }
}
```

**Using environment variables in interceptors:**

```typescript
// interceptors/logging.interceptor.ts
import { environment } from '../../environments/environment';

intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
  // Only log in development
  if (environment.enableLogging) {
    console.log(`[HTTP] --> ${request.method} ${request.urlWithParams}`);
  }

  return next.handle(request).pipe(
    tap(event => {
      if (event instanceof HttpResponse && environment.enableLogging) {
        console.log(`[HTTP] <-- ${event.status}`);
      }
    })
  );
}
```

### Adding Custom Environments (e.g., Staging)

You can add more environments beyond `dev` and `prod`:

```typescript
// src/environments/environment.staging.ts
export const environment = {
  production: false,
  apiBaseUrl: 'https://staging-api.myapp.com/api',
  enableLogging: true,
  enableMockData: false,
  authTokenKey: 'staging_auth_token',
  appTitle: 'MyApp (STAGING)'
};
```

Add the configuration to `angular.json`:

```json
{
  "configurations": {
    "staging": {
      "fileReplacements": [
        {
          "replace": "src/environments/environment.ts",
          "with": "src/environments/environment.staging.ts"
        }
      ]
    }
  }
}
```

```bash
# Build for staging
ng build --configuration staging
```

---

## 8.8 Practical Example: Full CRUD Application

Let's build a complete, production-grade example that ties together everything from this phase: a User Management module with a service, component, error handling, loading states, and typed responses.

### The Model

```typescript
// models/user.model.ts
export interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'editor' | 'viewer';
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// Used for creating new users (server assigns id, createdAt, updatedAt)
export type CreateUserRequest = Omit<User, 'id' | 'createdAt' | 'updatedAt'>;

// Used for updating users (all fields optional except id)
export type UpdateUserRequest = Partial<Omit<User, 'id' | 'createdAt' | 'updatedAt'>>;

// API response wrapper (many APIs use this pattern)
export interface ApiResponse<T> {
  data: T;
  message: string;
  success: boolean;
}
```

### The Service

```typescript
// services/user.service.ts
import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpParams } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, map, tap, retry } from 'rxjs/operators';
import { environment } from '../../environments/environment';
import {
  User,
  CreateUserRequest,
  UpdateUserRequest,
  ApiResponse
} from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserService {
  private apiUrl = `${environment.apiBaseUrl}/users`;

  constructor(private http: HttpClient) { }

  // ─── READ ALL ──────────────────────────────────────────
  // Supports optional filtering and pagination
  getUsers(filters?: {
    role?: string;
    isActive?: boolean;
    page?: number;
    limit?: number;
    search?: string;
  }): Observable<User[]> {
    let params = new HttpParams();

    // Build query parameters from the filters object
    if (filters) {
      if (filters.role) params = params.set('role', filters.role);
      if (filters.isActive !== undefined) params = params.set('isActive', String(filters.isActive));
      if (filters.page) params = params.set('page', String(filters.page));
      if (filters.limit) params = params.set('limit', String(filters.limit));
      if (filters.search) params = params.set('q', filters.search);
    }

    return this.http.get<ApiResponse<User[]>>(this.apiUrl, { params }).pipe(
      map(response => response.data),  // Extract users from the wrapper
      retry({ count: 2, delay: 1000 }),
      tap(users => {
        if (!environment.production) {
          console.log(`[UserService] Fetched ${users.length} users`);
        }
      }),
      catchError(this.handleError)
    );
  }

  // ─── READ ONE ──────────────────────────────────────────
  getUserById(id: number): Observable<User> {
    return this.http.get<ApiResponse<User>>(`${this.apiUrl}/${id}`).pipe(
      map(response => response.data),
      retry({ count: 1, delay: 500 }),
      catchError(this.handleError)
    );
  }

  // ─── CREATE ────────────────────────────────────────────
  createUser(user: CreateUserRequest): Observable<User> {
    return this.http.post<ApiResponse<User>>(this.apiUrl, user).pipe(
      map(response => response.data),
      tap(newUser => {
        if (!environment.production) {
          console.log(`[UserService] Created user: ${newUser.name} (ID: ${newUser.id})`);
        }
      }),
      // No retry for POST -- could create duplicates
      catchError(this.handleError)
    );
  }

  // ─── UPDATE (FULL) ────────────────────────────────────
  updateUser(id: number, user: CreateUserRequest): Observable<User> {
    return this.http.put<ApiResponse<User>>(`${this.apiUrl}/${id}`, user).pipe(
      map(response => response.data),
      catchError(this.handleError)
    );
  }

  // ─── UPDATE (PARTIAL) ─────────────────────────────────
  patchUser(id: number, changes: UpdateUserRequest): Observable<User> {
    return this.http.patch<ApiResponse<User>>(`${this.apiUrl}/${id}`, changes).pipe(
      map(response => response.data),
      catchError(this.handleError)
    );
  }

  // ─── DELETE ────────────────────────────────────────────
  deleteUser(id: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.apiUrl}/${id}`).pipe(
      map(() => void 0),  // Convert to void
      tap(() => {
        if (!environment.production) {
          console.log(`[UserService] Deleted user ID: ${id}`);
        }
      }),
      catchError(this.handleError)
    );
  }

  // ─── TOGGLE ACTIVE STATUS ─────────────────────────────
  // A convenience method that uses PATCH
  toggleUserActive(id: number, isActive: boolean): Observable<User> {
    return this.patchUser(id, { isActive });
  }

  // ─── CENTRALIZED ERROR HANDLER ─────────────────────────
  private handleError(error: HttpErrorResponse): Observable<never> {
    let userMessage: string;

    if (error.status === 0) {
      userMessage = 'Unable to connect to the server. Please check your internet connection.';
    } else if (error.status === 400) {
      // Bad request -- server sent a validation error
      userMessage = error.error?.message || 'Invalid data submitted. Please check your input.';
    } else if (error.status === 401) {
      userMessage = 'Your session has expired. Please log in again.';
    } else if (error.status === 403) {
      userMessage = 'You do not have permission to perform this action.';
    } else if (error.status === 404) {
      userMessage = 'The requested resource was not found.';
    } else if (error.status === 409) {
      userMessage = 'A conflict occurred. The resource may have been modified by someone else.';
    } else if (error.status >= 500) {
      userMessage = 'A server error occurred. Please try again later.';
    } else {
      userMessage = `An unexpected error occurred (${error.status}).`;
    }

    // Log the full technical error for debugging
    console.error(`[UserService] HTTP Error:`, {
      status: error.status,
      statusText: error.statusText,
      url: error.url,
      message: error.message,
      serverMessage: error.error?.message
    });

    return throwError(() => new Error(userMessage));
  }
}
```

### The Component (TypeScript)

```typescript
// components/user-management/user-management.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { UserService } from '../../services/user.service';
import { User, CreateUserRequest } from '../../models/user.model';

@Component({
  selector: 'app-user-management',
  templateUrl: './user-management.component.html',
  styleUrls: ['./user-management.component.css']
})
export class UserManagementComponent implements OnInit, OnDestroy {
  // ─── STATE ──────────────────────────────────────────────
  users: User[] = [];
  selectedUser: User | null = null;

  // UI state
  isLoading = false;
  isSaving = false;
  errorMessage = '';
  successMessage = '';

  // Form state
  showForm = false;
  isEditing = false;
  formData: CreateUserRequest = this.getEmptyForm();

  // Filter state
  filterRole = '';
  searchTerm = '';

  // Used to unsubscribe all Observables when the component is destroyed
  // This prevents memory leaks
  private destroy$ = new Subject<void>();

  constructor(private userService: UserService) { }

  // ─── LIFECYCLE ──────────────────────────────────────────
  ngOnInit(): void {
    this.loadUsers();
  }

  ngOnDestroy(): void {
    // Emit a value on destroy$ to complete all subscriptions that use takeUntil
    this.destroy$.next();
    this.destroy$.complete();
  }

  // ─── READ ───────────────────────────────────────────────
  loadUsers(): void {
    this.isLoading = true;
    this.clearMessages();

    this.userService.getUsers({
      role: this.filterRole || undefined,
      search: this.searchTerm || undefined
    })
    .pipe(takeUntil(this.destroy$))  // Auto-unsubscribe when component is destroyed
    .subscribe({
      next: (users) => {
        this.users = users;
        this.isLoading = false;
      },
      error: (error: Error) => {
        this.errorMessage = error.message;
        this.isLoading = false;
      }
    });
  }

  // ─── CREATE ─────────────────────────────────────────────
  openCreateForm(): void {
    this.showForm = true;
    this.isEditing = false;
    this.formData = this.getEmptyForm();
    this.clearMessages();
  }

  // ─── UPDATE (starts editing) ────────────────────────────
  editUser(user: User): void {
    this.showForm = true;
    this.isEditing = true;
    this.selectedUser = user;
    this.formData = {
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive
    };
    this.clearMessages();
  }

  // ─── SAVE (handles both create and update) ──────────────
  saveUser(): void {
    this.isSaving = true;
    this.clearMessages();

    const operation$ = this.isEditing && this.selectedUser
      ? this.userService.updateUser(this.selectedUser.id, this.formData)
      : this.userService.createUser(this.formData);

    operation$
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (savedUser) => {
          if (this.isEditing) {
            // Replace the old user in the array with the updated one
            const index = this.users.findIndex(u => u.id === savedUser.id);
            if (index !== -1) {
              this.users[index] = savedUser;
            }
            this.successMessage = `User "${savedUser.name}" updated successfully.`;
          } else {
            // Add the new user to the array
            this.users.push(savedUser);
            this.successMessage = `User "${savedUser.name}" created successfully.`;
          }

          this.isSaving = false;
          this.cancelForm();
        },
        error: (error: Error) => {
          this.errorMessage = error.message;
          this.isSaving = false;
        }
      });
  }

  // ─── DELETE ─────────────────────────────────────────────
  deleteUser(user: User): void {
    const confirmed = confirm(`Are you sure you want to delete "${user.name}"? This action cannot be undone.`);
    if (!confirmed) return;

    this.clearMessages();

    this.userService.deleteUser(user.id)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: () => {
          this.users = this.users.filter(u => u.id !== user.id);
          this.successMessage = `User "${user.name}" deleted successfully.`;

          // If we were editing this user, close the form
          if (this.selectedUser?.id === user.id) {
            this.cancelForm();
          }
        },
        error: (error: Error) => {
          this.errorMessage = error.message;
        }
      });
  }

  // ─── TOGGLE ACTIVE ─────────────────────────────────────
  toggleActive(user: User): void {
    this.clearMessages();

    this.userService.toggleUserActive(user.id, !user.isActive)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (updatedUser) => {
          const index = this.users.findIndex(u => u.id === updatedUser.id);
          if (index !== -1) {
            this.users[index] = updatedUser;
          }
          const status = updatedUser.isActive ? 'activated' : 'deactivated';
          this.successMessage = `User "${updatedUser.name}" ${status}.`;
        },
        error: (error: Error) => {
          this.errorMessage = error.message;
        }
      });
  }

  // ─── FILTER ─────────────────────────────────────────────
  onFilterChange(): void {
    this.loadUsers();
  }

  // ─── HELPERS ────────────────────────────────────────────
  cancelForm(): void {
    this.showForm = false;
    this.isEditing = false;
    this.selectedUser = null;
    this.formData = this.getEmptyForm();
  }

  private getEmptyForm(): CreateUserRequest {
    return {
      name: '',
      email: '',
      role: 'viewer',
      isActive: true
    };
  }

  private clearMessages(): void {
    this.errorMessage = '';
    this.successMessage = '';
  }
}
```

### The Template (HTML)

```html
<!-- components/user-management/user-management.component.html -->
<div class="user-management">
  <h1>User Management</h1>

  <!-- ─── MESSAGES ──────────────────────────────────────── -->
  <div *ngIf="successMessage" class="alert alert-success">
    {{ successMessage }}
    <button (click)="successMessage = ''">&times;</button>
  </div>

  <div *ngIf="errorMessage" class="alert alert-danger">
    {{ errorMessage }}
    <button (click)="errorMessage = ''">&times;</button>
  </div>

  <!-- ─── TOOLBAR ───────────────────────────────────────── -->
  <div class="toolbar">
    <button (click)="openCreateForm()" [disabled]="showForm" class="btn btn-primary">
      + New User
    </button>

    <div class="filters">
      <input
        type="text"
        [(ngModel)]="searchTerm"
        (input)="onFilterChange()"
        placeholder="Search by name..."
        class="search-input"
      />

      <select [(ngModel)]="filterRole" (change)="onFilterChange()" class="role-filter">
        <option value="">All Roles</option>
        <option value="admin">Admin</option>
        <option value="editor">Editor</option>
        <option value="viewer">Viewer</option>
      </select>

      <button (click)="loadUsers()" class="btn btn-secondary" title="Refresh">
        Refresh
      </button>
    </div>
  </div>

  <!-- ─── CREATE/EDIT FORM ──────────────────────────────── -->
  <div *ngIf="showForm" class="user-form card">
    <h3>{{ isEditing ? 'Edit User' : 'Create New User' }}</h3>

    <form (ngSubmit)="saveUser()">
      <div class="form-group">
        <label for="name">Name *</label>
        <input
          id="name"
          type="text"
          [(ngModel)]="formData.name"
          name="name"
          required
          placeholder="Enter full name"
        />
      </div>

      <div class="form-group">
        <label for="email">Email *</label>
        <input
          id="email"
          type="email"
          [(ngModel)]="formData.email"
          name="email"
          required
          placeholder="Enter email address"
        />
      </div>

      <div class="form-group">
        <label for="role">Role *</label>
        <select id="role" [(ngModel)]="formData.role" name="role">
          <option value="admin">Admin</option>
          <option value="editor">Editor</option>
          <option value="viewer">Viewer</option>
        </select>
      </div>

      <div class="form-group">
        <label>
          <input type="checkbox" [(ngModel)]="formData.isActive" name="isActive" />
          Active
        </label>
      </div>

      <div class="form-actions">
        <button type="submit" [disabled]="isSaving" class="btn btn-primary">
          {{ isSaving ? 'Saving...' : (isEditing ? 'Update User' : 'Create User') }}
        </button>
        <button type="button" (click)="cancelForm()" [disabled]="isSaving" class="btn btn-secondary">
          Cancel
        </button>
      </div>
    </form>
  </div>

  <!-- ─── LOADING STATE ────────────────────────────────── -->
  <div *ngIf="isLoading" class="loading">
    <p>Loading users...</p>
  </div>

  <!-- ─── USER TABLE ────────────────────────────────────── -->
  <table *ngIf="!isLoading && users.length > 0" class="user-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Email</th>
        <th>Role</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <tr *ngFor="let user of users" [class.inactive]="!user.isActive">
        <td>{{ user.id }}</td>
        <td>{{ user.name }}</td>
        <td>{{ user.email }}</td>
        <td>
          <span class="badge" [ngClass]="{
            'badge-admin': user.role === 'admin',
            'badge-editor': user.role === 'editor',
            'badge-viewer': user.role === 'viewer'
          }">
            {{ user.role }}
          </span>
        </td>
        <td>
          <button
            (click)="toggleActive(user)"
            class="btn-toggle"
            [class.active]="user.isActive"
          >
            {{ user.isActive ? 'Active' : 'Inactive' }}
          </button>
        </td>
        <td class="actions">
          <button (click)="editUser(user)" class="btn btn-small btn-edit">Edit</button>
          <button (click)="deleteUser(user)" class="btn btn-small btn-danger">Delete</button>
        </td>
      </tr>
    </tbody>
  </table>

  <!-- ─── EMPTY STATE ──────────────────────────────────── -->
  <div *ngIf="!isLoading && users.length === 0 && !errorMessage" class="empty-state">
    <p>No users found.</p>
    <button (click)="openCreateForm()" class="btn btn-primary">Create your first user</button>
  </div>
</div>
```

### Key Patterns Used in This Example

| Pattern | Where | Why |
|---|---|---|
| **takeUntil(this.destroy$)** | Every subscription | Prevents memory leaks by auto-unsubscribing when the component is destroyed |
| **Typed responses** | Service methods return `Observable<User>` / `Observable<User[]>` | TypeScript catches bugs at compile time |
| **Centralized error handling** | `handleError()` in the service | Consistent error messages without duplicating logic |
| **Optimistic local updates** | After delete, we remove from the array locally | Faster UI -- no need to refetch the entire list |
| **Loading/saving states** | `isLoading` and `isSaving` booleans | Disables buttons and shows spinners to prevent double-submissions |
| **Conditional operations** | `saveUser()` checks `isEditing` | Single form handles both create and edit |
| **Environment-based URLs** | `environment.apiBaseUrl` | Same code works for dev, staging, and production |

---

## 8.9 Summary

| Concept | What You Learned |
|---|---|
| `HttpClient` | Angular's built-in, Observable-based HTTP client with typed responses |
| `HttpClientModule` | Must be imported once in `AppModule` to make `HttpClient` available |
| Services for HTTP | Always place HTTP calls in services, never directly in components |
| `http.get<T>()` | Fetch data with type-safe generics |
| `http.post<T>()` | Create new resources by sending data in the request body |
| `http.put<T>()` | Replace an entire resource (full update) |
| `http.patch<T>()` | Update specific fields of a resource (partial update) |
| `http.delete<T>()` | Remove a resource from the server |
| `subscribe()` | Triggers the HTTP request and handles success/error responses |
| `pipe()` with operators | Transform, log, catch errors, and retry before the subscriber sees data |
| `catchError` + `throwError` | The standard pattern for handling and re-throwing HTTP errors |
| `retry()` | Automatically retry failed requests with optional delay and backoff |
| `HttpHeaders` | Set custom headers (Authorization, Content-Type, etc.) -- immutable |
| `HttpParams` | Build query parameters cleanly -- immutable |
| `observe: 'response'` | Get the full `HttpResponse` including status codes and headers |
| `observe: 'events'` | Track upload/download progress events |
| `responseType` | Parse responses as JSON, text, blob, or arraybuffer |
| Interceptors | Middleware that processes every HTTP request/response globally |
| Auth interceptor | Automatically attach JWT tokens to outgoing requests |
| Error interceptor | Handle errors globally (redirect on 401, log on 500, etc.) |
| Loading interceptor | Show/hide a loading spinner for all HTTP requests |
| Logging interceptor | Log request/response details with timing information |
| `HTTP_INTERCEPTORS` | The DI token used to register interceptors (with `multi: true`) |
| Interceptor order | Interceptors execute in registration order (requests) and reverse order (responses) |
| Environment files | `environment.ts` for dev, `environment.prod.ts` for production -- auto-swapped during build |
| `takeUntil(destroy$)` | Prevent memory leaks by unsubscribing when a component is destroyed |

---

**Next:** [Phase 9 -- RxJS & Observables](./Phase09-RxJS-Observables.md)
