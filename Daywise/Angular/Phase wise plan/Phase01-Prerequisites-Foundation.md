# Phase 1: Prerequisites & Foundation

> Before you write a single line of Angular code, you need a solid foundation. This phase covers everything Angular depends on — TypeScript, JavaScript (ES6+), Node.js, and npm. Skipping this phase is the #1 reason beginners struggle with Angular.

---

## 1.1 Why Prerequisites Matter for Angular

Angular is NOT like jQuery where you just drop a script tag and start coding. Angular is a **full framework** built with:

- **TypeScript** (not plain JavaScript) — Angular's source code itself is written in TypeScript
- **Node.js** — runs the development tools (CLI, build system, dev server)
- **npm** — installs and manages all Angular packages and dependencies
- **ES6+ JavaScript** — Angular heavily uses modern JS features

**Think of it this way:**
- HTML/CSS = the body of your app (structure + appearance)
- JavaScript/TypeScript = the brain (logic + behavior)
- Node.js/npm = the tools in your workshop (build, serve, test)

---

## 1.2 JavaScript ES6+ Features You MUST Know

Angular code uses modern JavaScript everywhere. Here are the features you'll encounter daily:

### 1.2.1 `let` and `const` (Block Scoping)

**Old way (var) — problematic:**
```javascript
// var is function-scoped, not block-scoped
// This means it "leaks" outside blocks like if/for

if (true) {
  var name = "Angular";
}
console.log(name); // "Angular" — var leaked outside the if block!

for (var i = 0; i < 3; i++) {
  // ...
}
console.log(i); // 3 — var leaked outside the for loop!
```

**New way (let/const) — safe:**
```javascript
// let is block-scoped — stays inside the block
if (true) {
  let name = "Angular";
}
// console.log(name); // ERROR! name is not defined outside the block

// const is also block-scoped AND cannot be reassigned
const framework = "Angular";
// framework = "React"; // ERROR! Cannot reassign a const

// BUT: const objects/arrays CAN be mutated (their contents can change)
const person = { name: "John" };
person.name = "Jane"; // This is FINE — we're changing a property, not reassigning
// person = {};        // This would ERROR — we're trying to reassign the variable
```

**Why this matters in Angular:**
- Angular components use `const` for values that shouldn't change
- `let` for variables that will change
- You'll almost never see `var` in Angular code

---

### 1.2.2 Arrow Functions

**Old way:**
```javascript
// Traditional function
function add(a, b) {
  return a + b;
}

// Or as a function expression
const multiply = function(a, b) {
  return a * b;
};
```

**New way (Arrow functions):**
```javascript
// Arrow function — shorter syntax
const add = (a, b) => a + b;

// With a body (when you need multiple lines)
const multiply = (a, b) => {
  const result = a * b;
  return result;
};

// Single parameter — parentheses optional
const double = x => x * 2;

// No parameters — empty parentheses required
const greet = () => "Hello!";
```

**The BIG difference — `this` keyword:**
```javascript
// Traditional functions create their OWN `this`
const obj = {
  name: "Angular",
  greetOld: function() {
    setTimeout(function() {
      console.log(this.name); // undefined! `this` refers to setTimeout's context
    }, 1000);
  },

  // Arrow functions INHERIT `this` from the surrounding code
  greetNew: function() {
    setTimeout(() => {
      console.log(this.name); // "Angular"! Arrow function uses obj's `this`
    }, 1000);
  }
};
```

**Why this matters in Angular:**
- Angular uses arrow functions extensively in callbacks, subscriptions, and RxJS operators
- The `this` behavior of arrow functions prevents many common bugs

---

### 1.2.3 Template Literals

```javascript
const name = "Angular";
const version = 17;

// Old way — string concatenation (messy)
const message1 = "Welcome to " + name + " version " + version + "!";

// New way — template literals (clean)
const message2 = `Welcome to ${name} version ${version}!`;

// Multi-line strings (very useful for Angular templates)
const html = `
  <div class="container">
    <h1>${name}</h1>
    <p>Version: ${version}</p>
  </div>
`;

// Expressions inside ${}
const price = 29.99;
const tax = 0.08;
const total = `Total: $${(price * (1 + tax)).toFixed(2)}`; // "Total: $32.39"
```

**Why this matters in Angular:**
- Angular component templates can be written inline using template literals
- Useful in string interpolation within TypeScript code

---

### 1.2.4 Destructuring

**Extracting values from objects and arrays in one step:**

```javascript
// --- OBJECT DESTRUCTURING ---

const person = { name: "John", age: 30, city: "NYC" };

// Old way
const name1 = person.name;
const age1 = person.age;

// New way — destructuring
const { name, age, city } = person;
console.log(name); // "John"
console.log(age);  // 30

// Rename while destructuring
const { name: personName, age: personAge } = person;
console.log(personName); // "John"

// Default values
const { name: n, country = "USA" } = person;
console.log(country); // "USA" (default, since person has no country)

// --- ARRAY DESTRUCTURING ---

const colors = ["red", "green", "blue"];

// Old way
const first1 = colors[0];

// New way
const [first, second, third] = colors;
console.log(first);  // "red"
console.log(second); // "green"

// Skip elements
const [, , lastColor] = colors;
console.log(lastColor); // "blue"

// --- FUNCTION PARAMETER DESTRUCTURING ---
// Very common in Angular!
function displayUser({ name, age }) {
  console.log(`${name} is ${age} years old`);
}
displayUser(person); // "John is 30 years old"
```

**Why this matters in Angular:**
- Used in component inputs, service responses, route parameters
- Common pattern: `const { data, error } = response;`

---

### 1.2.5 Spread & Rest Operators (`...`)

```javascript
// --- SPREAD: "Expands" an array or object ---

// Array spread
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const combined = [...arr1, ...arr2]; // [1, 2, 3, 4, 5, 6]

// Object spread (very common in Angular for immutable updates)
const user = { name: "John", age: 30 };
const updatedUser = { ...user, age: 31 }; // { name: "John", age: 31 }
// Original `user` is NOT modified — this is immutability

// --- REST: "Collects" remaining items ---

// In function parameters
function sum(...numbers) {
  return numbers.reduce((total, n) => total + n, 0);
}
sum(1, 2, 3, 4); // 10

// In destructuring
const [first, ...remaining] = [1, 2, 3, 4, 5];
console.log(first);     // 1
console.log(remaining); // [2, 3, 4, 5]
```

**Why this matters in Angular:**
- State management (NgRx) relies heavily on spread for immutable state updates
- Commonly used when copying objects to avoid mutations

---

### 1.2.6 Promises & Async/Await

```javascript
// --- PROMISES ---
// A Promise represents a value that will be available in the future

// Creating a promise
const fetchData = () => {
  return new Promise((resolve, reject) => {
    // Simulate API call
    setTimeout(() => {
      const success = true;
      if (success) {
        resolve({ id: 1, name: "Angular" }); // Success — pass data
      } else {
        reject("Something went wrong");        // Failure — pass error
      }
    }, 2000);
  });
};

// Consuming a promise with .then/.catch
fetchData()
  .then(data => console.log("Got data:", data))
  .catch(error => console.log("Error:", error));

// --- ASYNC/AWAIT (cleaner way to work with Promises) ---

async function loadData() {
  try {
    const data = await fetchData(); // Waits here until promise resolves
    console.log("Got data:", data);
  } catch (error) {
    console.log("Error:", error);
  }
}

loadData();
```

**Why this matters in Angular:**
- While Angular primarily uses Observables (RxJS), you'll still encounter Promises
- HTTP calls can be converted to Promises using `.toPromise()` or `firstValueFrom()`
- Understanding async patterns is essential

---

### 1.2.7 Modules (import/export)

```javascript
// --- file: math-utils.js ---

// Named exports (can have multiple per file)
export const PI = 3.14159;
export function add(a, b) { return a + b; }
export function multiply(a, b) { return a * b; }

// Default export (only ONE per file)
export default class Calculator {
  add(a, b) { return a + b; }
}

// --- file: app.js ---

// Import named exports (use curly braces)
import { PI, add, multiply } from './math-utils';

// Import default export (no curly braces, any name works)
import Calculator from './math-utils';
import Calc from './math-utils'; // Same thing, different name

// Import everything
import * as MathUtils from './math-utils';
MathUtils.add(1, 2);
MathUtils.PI;
```

**Why this matters in Angular:**
- Angular is entirely module-based
- Every component, service, pipe, and directive uses `import` and `export`
- You'll write `import { Component } from '@angular/core'` in EVERY component

---

### 1.2.8 Array Methods (used constantly in Angular)

```javascript
const users = [
  { name: "Alice", age: 25, active: true },
  { name: "Bob", age: 30, active: false },
  { name: "Charlie", age: 35, active: true }
];

// map — transform each item (returns NEW array)
const names = users.map(user => user.name);
// ["Alice", "Bob", "Charlie"]

// filter — keep items that match condition (returns NEW array)
const activeUsers = users.filter(user => user.active);
// [{ name: "Alice"... }, { name: "Charlie"... }]

// find — get FIRST item that matches (returns single item or undefined)
const bob = users.find(user => user.name === "Bob");
// { name: "Bob", age: 30, active: false }

// some — does ANY item match? (returns boolean)
const hasInactive = users.some(user => !user.active); // true

// every — do ALL items match? (returns boolean)
const allActive = users.every(user => user.active); // false

// reduce — accumulate a single value
const totalAge = users.reduce((sum, user) => sum + user.age, 0); // 90

// Chaining — combine methods
const activeNames = users
  .filter(user => user.active)
  .map(user => user.name);
// ["Alice", "Charlie"]
```

**Why this matters in Angular:**
- Used everywhere: transforming API responses, filtering lists, processing form data
- RxJS operators follow similar patterns (map, filter, reduce)

---

## 1.3 TypeScript — Angular's Language

### Why TypeScript?

TypeScript is JavaScript with **types**. Angular chose TypeScript because:

1. **Catch errors BEFORE runtime** — types tell you about bugs while you code
2. **Better IDE support** — autocomplete, refactoring, navigation
3. **Self-documenting** — types describe what a function expects and returns
4. **Decorators** — Angular uses decorators (`@Component`, `@Injectable`) which TypeScript supports

### 1.3.1 Basic Types

```typescript
// --- Primitive Types ---
let name: string = "Angular";
let version: number = 17;
let isStable: boolean = true;
let nothing: null = null;
let notDefined: undefined = undefined;

// --- Arrays ---
let frameworks: string[] = ["Angular", "React", "Vue"];
let numbers: Array<number> = [1, 2, 3]; // Alternative syntax

// --- Tuple (fixed-length array with specific types) ---
let person: [string, number] = ["John", 30];

// --- Enum (named constants) ---
enum Direction {
  Up = "UP",
  Down = "DOWN",
  Left = "LEFT",
  Right = "RIGHT"
}
let move: Direction = Direction.Up;

// --- Any (escape hatch — avoid when possible) ---
let flexible: any = "hello";
flexible = 42;     // No error
flexible = true;   // No error
// WHY AVOID: defeats the purpose of TypeScript

// --- Unknown (safer than any) ---
let input: unknown = "hello";
// input.toUpperCase(); // ERROR! Must check type first
if (typeof input === "string") {
  input.toUpperCase(); // OK — TypeScript now knows it's a string
}

// --- Void (function returns nothing) ---
function logMessage(msg: string): void {
  console.log(msg);
  // no return statement
}

// --- Never (function never returns — throws or infinite loop) ---
function throwError(msg: string): never {
  throw new Error(msg);
}
```

### 1.3.2 Interfaces

**What:** A contract that defines the shape of an object.
**Why:** Ensures consistency — if an object claims to be a `User`, it MUST have the required properties.

```typescript
// Define the contract
interface User {
  id: number;
  name: string;
  email: string;
  age?: number;          // ? means optional
  readonly createdAt: Date; // readonly — cannot be changed after creation
}

// Use the contract
const user: User = {
  id: 1,
  name: "John",
  email: "john@example.com",
  createdAt: new Date()
  // age is optional, so we can skip it
};

// user.createdAt = new Date(); // ERROR! It's readonly

// --- Interfaces for function signatures ---
interface MathOperation {
  (a: number, b: number): number;
}

const add: MathOperation = (a, b) => a + b;
const subtract: MathOperation = (a, b) => a - b;

// --- Extending interfaces ---
interface Employee extends User {
  department: string;
  salary: number;
}

const employee: Employee = {
  id: 1,
  name: "Jane",
  email: "jane@company.com",
  createdAt: new Date(),
  department: "Engineering",
  salary: 95000
};
```

**Why this matters in Angular:**
- You'll create interfaces for API response models, component inputs, form data
- Angular's own APIs use interfaces extensively (e.g., `OnInit`, `OnDestroy`)

---

### 1.3.3 Classes

**What:** Blueprints for creating objects with properties and methods.
**Why:** Angular components and services ARE TypeScript classes.

```typescript
class Animal {
  // Properties
  name: string;
  private sound: string;      // Only accessible inside this class
  protected species: string;  // Accessible in this class and subclasses
  readonly legs: number;      // Cannot be changed after initialization

  // Constructor — runs when you create a new instance
  constructor(name: string, sound: string, species: string, legs: number) {
    this.name = name;
    this.sound = sound;
    this.species = species;
    this.legs = legs;
  }

  // Method
  makeSound(): string {
    return `${this.name} says ${this.sound}`;
  }
}

// Create an instance
const dog = new Animal("Buddy", "Woof", "Canine", 4);
console.log(dog.makeSound());  // "Buddy says Woof"
console.log(dog.name);         // "Buddy"
// console.log(dog.sound);     // ERROR! 'sound' is private

// --- SHORTHAND CONSTRUCTOR ---
// TypeScript lets you declare and assign properties in the constructor directly:

class Person {
  // This does BOTH: declares the property AND assigns it
  constructor(
    public name: string,
    private age: number,
    protected email: string
  ) {
    // No need for this.name = name, etc. — TypeScript does it automatically!
  }

  greet(): string {
    return `Hi, I'm ${this.name}, age ${this.age}`;
  }
}

// --- INHERITANCE ---
class Dog extends Animal {
  breed: string;

  constructor(name: string, breed: string) {
    super(name, "Woof", "Canine", 4); // Call parent constructor
    this.breed = breed;
  }

  fetch(item: string): string {
    return `${this.name} fetches the ${item}`;
  }
}

const myDog = new Dog("Rex", "German Shepherd");
console.log(myDog.makeSound());     // "Rex says Woof" (inherited method)
console.log(myDog.fetch("ball"));   // "Rex fetches the ball"
```

**Why this matters in Angular:**
- Every Angular component is a class: `export class AppComponent { ... }`
- Every service is a class: `export class UserService { ... }`
- The shorthand constructor is used EVERYWHERE for dependency injection

---

### 1.3.4 Access Modifiers

| Modifier | Accessible From | Usage |
|---|---|---|
| `public` | Anywhere | Default. Properties/methods used in templates |
| `private` | Same class only | Internal logic, not exposed |
| `protected` | Same class + subclasses | When child classes need access |
| `readonly` | Anywhere (read), nowhere (write after init) | Constants, immutable values |

```typescript
class BankAccount {
  public owner: string;           // Anyone can see who owns the account
  private balance: number;        // Only the class can see the balance
  protected accountType: string;  // Class and subclasses can see this
  readonly accountNumber: string; // Set once, never changed

  constructor(owner: string, initialBalance: number, accountNumber: string) {
    this.owner = owner;
    this.balance = initialBalance;
    this.accountType = "Savings";
    this.accountNumber = accountNumber;
  }

  // Public method — anyone can call
  public deposit(amount: number): void {
    this.balance += amount; // Private property accessed inside class — OK
  }

  // Public method — controlled access to private balance
  public getBalance(): number {
    return this.balance;
  }

  // Private method — internal use only
  private logTransaction(type: string, amount: number): void {
    console.log(`${type}: $${amount}`);
  }
}

const account = new BankAccount("John", 1000, "ACC-001");
account.deposit(500);
console.log(account.getBalance()); // 1500
// account.balance;                // ERROR! Private
// account.accountNumber = "NEW";  // ERROR! Readonly
```

---

### 1.3.5 Generics

**What:** Write code that works with ANY type, while still being type-safe.
**Why:** Avoid duplicating code for different types. Angular uses generics in HTTP calls, Observables, and more.

```typescript
// --- WITHOUT GENERICS (duplicated code) ---
function getFirstString(arr: string[]): string {
  return arr[0];
}
function getFirstNumber(arr: number[]): number {
  return arr[0];
}

// --- WITH GENERICS (one function for all types) ---
function getFirst<T>(arr: T[]): T {
  return arr[0];
}

// T is a placeholder — it becomes whatever type you pass
const firstStr = getFirst<string>(["a", "b", "c"]);  // T = string, returns string
const firstNum = getFirst<number>([1, 2, 3]);         // T = number, returns number
const firstUser = getFirst<User>([user1, user2]);     // T = User, returns User

// TypeScript can also INFER the type
const inferred = getFirst([1, 2, 3]); // TypeScript knows T = number

// --- Generic Interface ---
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

// Use with different types
const userResponse: ApiResponse<User> = {
  data: { id: 1, name: "John", email: "john@test.com", createdAt: new Date() },
  status: 200,
  message: "Success"
};

const usersResponse: ApiResponse<User[]> = {
  data: [user1, user2],
  status: 200,
  message: "Success"
};

// --- Generic Class ---
class DataStore<T> {
  private items: T[] = [];

  add(item: T): void {
    this.items.push(item);
  }

  getAll(): T[] {
    return this.items;
  }

  getById(index: number): T {
    return this.items[index];
  }
}

const userStore = new DataStore<User>();
userStore.add(user1);
const allUsers = userStore.getAll(); // Type: User[]
```

**Why this matters in Angular:**
- `HttpClient.get<User[]>('/api/users')` — tells Angular what type the API returns
- `Observable<User>` — an observable stream of User objects
- `EventEmitter<string>` — emits string values

---

### 1.3.6 Decorators

**What:** Special annotations that add metadata to classes, properties, or methods.
**Why:** Angular is BUILT on decorators. Every component, service, module, pipe uses one.

```typescript
// A decorator is just a function that receives the thing it decorates

// --- Simple class decorator ---
function Logger(constructor: Function) {
  console.log(`Class ${constructor.name} was created`);
}

@Logger
class MyClass {
  constructor() {
    console.log("MyClass instance created");
  }
}
// Output: "Class MyClass was created"

// --- Decorator Factory (decorator that accepts parameters) ---
function Component(config: { selector: string; template: string }) {
  return function(constructor: Function) {
    console.log(`Component registered with selector: ${config.selector}`);
    // In reality, Angular stores this metadata and uses it later
  };
}

@Component({
  selector: 'app-root',
  template: '<h1>Hello</h1>'
})
class AppComponent {
  title = "My App";
}

// --- This is EXACTLY how Angular works! ---
// Angular provides decorators like:
// @Component()  — marks a class as a component
// @Injectable() — marks a class as a service
// @NgModule()   — marks a class as a module
// @Directive()  — marks a class as a directive
// @Pipe()       — marks a class as a pipe
// @Input()      — marks a property as an input
// @Output()     — marks a property as an output
```

**Why this matters in Angular:**
- You literally cannot write Angular without decorators
- They tell Angular what each class IS and how to use it

---

### 1.3.7 Type Aliases & Union Types

```typescript
// --- Type Alias: Give a name to a type ---
type ID = string | number;  // ID can be either string or number

let userId: ID = 123;
userId = "abc-123"; // Also valid

// --- Union Types: Variable can be one of several types ---
type Status = "active" | "inactive" | "pending";

let userStatus: Status = "active";   // OK
// userStatus = "deleted";           // ERROR! Not in the union

// --- Intersection Types: Combine multiple types ---
type HasName = { name: string };
type HasAge = { age: number };
type Person = HasName & HasAge; // Must have BOTH name AND age

const person: Person = { name: "John", age: 30 }; // OK
// const bad: Person = { name: "John" };           // ERROR! Missing age

// --- Literal Types ---
type Theme = "light" | "dark";
type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";
```

---

## 1.4 Node.js & npm

### What is Node.js?

Node.js is a **JavaScript runtime** that lets you run JavaScript OUTSIDE the browser.

**Why Angular needs it:**
- Angular CLI runs on Node.js
- The development server (ng serve) runs on Node.js
- Build tools (Webpack/esbuild under the hood) run on Node.js
- You do NOT need to write Node.js code — Angular just uses it as tooling

### Installing Node.js

```bash
# Download from https://nodejs.org (LTS version recommended)

# Verify installation
node -v     # Should show version like v20.x.x
npm -v      # Should show version like 10.x.x
```

### What is npm?

npm = **Node Package Manager**. It:
1. Downloads and installs packages (libraries) from the npm registry
2. Manages project dependencies via `package.json`
3. Runs scripts defined in `package.json`

### Essential npm Commands

```bash
# --- Project Setup ---
npm init                  # Create a new package.json (interactive)
npm init -y               # Create package.json with defaults

# --- Installing Packages ---
npm install               # Install all dependencies from package.json
npm install lodash        # Install a package (adds to dependencies)
npm install -D jest       # Install as dev dependency (-D or --save-dev)
npm install -g @angular/cli  # Install globally (-g) — available everywhere

# --- Understanding package.json ---
# dependencies:    needed at runtime (Angular, RxJS)
# devDependencies: needed only for development (testing tools, linters)

# --- Removing Packages ---
npm uninstall lodash      # Remove a package

# --- Running Scripts ---
npm start                 # Run the "start" script from package.json
npm test                  # Run the "test" script
npm run build             # Run the "build" script
npm run <any-script>      # Run any custom script

# --- Useful Commands ---
npm list                  # See installed packages
npm outdated              # Check for outdated packages
npm update                # Update packages to latest compatible version
```

### Understanding package.json

```json
{
  "name": "my-angular-app",
  "version": "1.0.0",
  "scripts": {
    "start": "ng serve",
    "build": "ng build",
    "test": "ng test"
  },
  "dependencies": {
    "@angular/core": "^17.0.0",
    "@angular/common": "^17.0.0",
    "rxjs": "^7.8.0"
  },
  "devDependencies": {
    "@angular/cli": "^17.0.0",
    "typescript": "^5.2.0",
    "karma": "^6.4.0"
  }
}
```

**Understanding version numbers: `^17.0.0`**
- `17` = Major version (breaking changes)
- `0` = Minor version (new features, backwards compatible)
- `0` = Patch version (bug fixes)
- `^` = Allow minor and patch updates (^17.0.0 → any 17.x.x)
- `~` = Allow only patch updates (~17.0.0 → any 17.0.x)

### package-lock.json

- **What:** Auto-generated file that locks EXACT versions of every dependency
- **Why:** Ensures everyone on the team gets identical versions
- **Rule:** Never edit it manually. Always commit it to version control.

---

## 1.5 Summary Checklist

Before moving to Phase 2, make sure you understand:

- [ ] `let`, `const` vs `var`
- [ ] Arrow functions and `this` behavior
- [ ] Template literals
- [ ] Destructuring (objects and arrays)
- [ ] Spread/rest operators
- [ ] Promises and async/await
- [ ] import/export modules
- [ ] Array methods (map, filter, find, reduce)
- [ ] TypeScript types, interfaces, classes
- [ ] Access modifiers (public, private, protected, readonly)
- [ ] Generics (`<T>`)
- [ ] Decorators (`@`)
- [ ] Node.js and npm basics

---

**Next:** [Phase 2 — Angular Setup & Project Structure](./Phase02-Angular-Setup-Project-Structure.md)
