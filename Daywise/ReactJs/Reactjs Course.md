# ReactJS Complete Course - Detailed Guide

---

## Table of Contents

1. [What is ReactJS?](#1-what-is-reactjs)
2. [Major Features of React](#2-major-features-of-react)
3. [Virtual DOM and How It Works](#3-virtual-dom-and-how-it-works)
4. [Components in React](#4-components-in-react)
5. [What is JSX?](#5-what-is-jsx)
6. [Export and Import Components](#6-export-and-import-components)
7. [Nested Components](#7-nested-components)
8. [State in React](#8-state-in-react)
9. [How to Update State in React](#9-how-to-update-state-in-react)
10. [What is setState Callback](#10-what-is-setstate-callback)
11. [Why Not Update State Directly](#11-why-not-update-state-directly)
12. [Props in React](#12-props-in-react)
13. [Difference Between State and Props](#13-difference-between-state-and-props)
14. [Lifting State Up](#14-lifting-state-up)
15. [Children Prop](#15-children-prop)
16. [DefaultProps](#16-defaultprops)
17. [Fragments](#17-fragments)
18. [Styling in React](#18-styling-in-react)
19. [Conditional Rendering](#19-conditional-rendering)
20. [Rendering List of Data](#20-rendering-list-of-data)
21. [Key Prop](#21-key-prop)
22. [Why Indexes for Keys Are Not Recommended](#22-why-indexes-for-keys-are-not-recommended)
23. [Handling Buttons](#23-handling-buttons)
24. [Handling Inputs](#24-handling-inputs)
25. [Lifecycle Methods](#25-lifecycle-methods)
26. [Popular Hooks in React](#26-popular-hooks-in-react)
27. [useState Hook](#27-usestate-hook)
28. [useEffect Hook](#28-useeffect-hook)
29. [Data Fetching in React](#29-data-fetching-in-react)
30. [Prop Drilling and Context API](#30-prop-drilling-and-context-api)
31. [Context API in React](#31-context-api-in-react)
32. [useContext Hook](#32-usecontext-hook)
33. [Updating Context Values](#33-updating-context-values)
34. [Multiple Contexts](#34-multiple-contexts)
35. [Context API vs Prop Drilling](#35-context-api-vs-prop-drilling)
36. [useReducer Hook](#36-usereducer-hook)
37. [useReducer with Complex State](#37-usereducer-with-complex-state)
38. [Passing Additional Arguments to Reducer](#38-passing-additional-arguments-to-reducer)
39. [Side Effects with useReducer](#39-side-effects-with-usereducer)
40. [useRef Hook](#40-useref-hook)
41. [useRef for Mutable Values](#41-useref-for-mutable-values)
42. [forwardRef](#42-forwardref)
43. [Managing Forms in React](#43-managing-forms-in-react)
44. [Custom Hooks](#44-custom-hooks)
45. [useFetch Custom Hook](#45-usefetch-custom-hook)
46. [useWindowResize Custom Hook](#46-usewindowresize-custom-hook)
47. [React Router DOM](#47-react-router-dom)
48. [Basic Route in React Router DOM](#48-basic-route-in-react-router-dom)
49. [Implement Basic Routing](#49-implement-basic-routing)
50. [Link Component](#50-link-component)
51. [URL Parameters / Dynamic Routing](#51-url-parameters--dynamic-routing)
52. [Redirect in React Router DOM](#52-redirect-in-react-router-dom)
53. [Routes Component](#53-routes-component)
54. [Nested Routes](#54-nested-routes)
55. [404 Error Handling](#55-404-error-handling)
56. [Programmatic Navigation](#56-programmatic-navigation)
57. [useCallback Hook](#57-usecallback-hook)
58. [useMemo Hook](#58-usememo-hook)
59. [React.memo](#59-reactmemo)
60. [Reconciliation Process](#60-reconciliation-process)
61. [Pure Components](#61-pure-components)
62. [Higher Order Components](#62-higher-order-components)
63. [Redux Core Principles](#63-redux-core-principles)
64. [Actions in Redux](#64-actions-in-redux)
65. [Reducers in Redux](#65-reducers-in-redux)
66. [Redux Store](#66-redux-store)
67. [Connect React to Redux](#67-connect-react-to-redux)
68. [useSelector and useDispatch](#68-useselector-and-usedispatch)
69. [Redux Toolkit](#69-redux-toolkit)
70. [Configure Store in Redux Toolkit](#70-configure-store-in-redux-toolkit)
71. [createSlice in Redux Toolkit](#71-createslice-in-redux-toolkit)
72. [Controlled Components](#72-controlled-components)
73. [Uncontrolled Components](#73-uncontrolled-components)
74. [Performance Optimization](#74-performance-optimization)
75. [Code Splitting](#75-code-splitting)
76. [Render Props](#76-render-props)
77. [Portals](#77-portals)
78. [Lazy Loading](#78-lazy-loading)
79. [TypeScript with React - Props](#79-typescript-with-react---props)
80. [useState with TypeScript](#80-usestate-with-typescript)
81. [Event Handlers with TypeScript](#81-event-handlers-with-typescript)
82. [Optional Props with TypeScript](#82-optional-props-with-typescript)
83. [useReducer with TypeScript](#83-usereducer-with-typescript)
84. [Context API with TypeScript](#84-context-api-with-typescript)
85. [Testing with Jest](#85-testing-with-jest)
86. [Rendering Components for Testing](#86-rendering-components-for-testing)
87. [Finding Elements in DOM](#87-finding-elements-in-dom)
88. [Simulating User Events](#88-simulating-user-events)
89. [Testing Component Props](#89-testing-component-props)
90. [Hands-on: Controlled Input Component](#90-hands-on-controlled-input-component)
91. [Hands-on: Toggle Visibility](#91-hands-on-toggle-visibility)
92. [Hands-on: Fetch Data from API](#92-hands-on-fetch-data-from-api)
93. [Hands-on: Reusable Button Component](#93-hands-on-reusable-button-component)
94. [Hands-on: Effect with Cleanup](#94-hands-on-effect-with-cleanup)
95. [Hands-on: Context with Reducer](#95-hands-on-context-with-reducer)
96. [Hands-on: Conditional Rendering Based on Props](#96-hands-on-conditional-rendering-based-on-props)
97. [Hands-on: Simple Form Component](#97-hands-on-simple-form-component)
98. [Appendix: Document Upload and Listing Component](#98-appendix-document-upload-and-listing-component)

---

## 1. What is ReactJS?

**ReactJS** is an open-source **JavaScript library** created by **Facebook (Meta)** in 2013, used for building **user interfaces (UIs)**, especially for **single-page applications (SPAs)**.

### Key Points:
- React is a **library**, not a framework (it focuses only on the View layer)
- It allows developers to build **reusable UI components**
- React uses a **declarative** approach — you describe *what* the UI should look like, and React handles *how* to update the DOM
- It follows a **component-based architecture** — the entire UI is broken into small, isolated, reusable pieces called components

### Why React?
| Feature | Explanation |
|---------|-------------|
| **Declarative** | You describe the desired UI state, React updates the DOM efficiently |
| **Component-Based** | Build encapsulated components that manage their own state |
| **Learn Once, Write Anywhere** | React can render on the server (Next.js), mobile (React Native), desktop (Electron) |

```jsx
// A simple React application
import React from 'react';
import ReactDOM from 'react-dom/client';

// This is a React component — a JavaScript function that returns UI (JSX)
function App() {
  return <h1>Hello, React!</h1>;
}

// ReactDOM renders the App component into the HTML element with id="root"
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
```

---

## 2. Major Features of React

React has several features that make it powerful and popular:

### 1. Virtual DOM
- React creates an in-memory representation of the real DOM
- When state changes, React compares the new Virtual DOM with the old one (diffing) and updates only what changed

### 2. JSX (JavaScript XML)
- A syntax extension that lets you write HTML-like code inside JavaScript
- Makes code more readable and easier to write

### 3. Component-Based Architecture
- UI is divided into independent, reusable pieces
- Each component has its own logic and rendering

### 4. One-Way Data Binding (Unidirectional Data Flow)
- Data flows from **parent to child** through props
- Makes data flow predictable and easier to debug

### 5. Declarative UI
- You describe **what** the UI should look like for each state
- React automatically handles the DOM updates

### 6. React Hooks
- Functions that let you use state and lifecycle features in functional components
- Examples: `useState`, `useEffect`, `useContext`, `useReducer`

### 7. Community and Ecosystem
- Large community, rich ecosystem of third-party libraries
- Tools like Redux, React Router, Next.js, etc.

```jsx
// Example showing multiple features in action
import React, { useState } from 'react';

// FEATURE: Component-Based Architecture - a reusable Greeting component
function Greeting({ name }) {  // FEATURE: One-Way Data Binding via props
  return <p>Hello, {name}!</p>; // FEATURE: JSX syntax
}

function App() {
  // FEATURE: React Hooks (useState) for state management
  const [user, setUser] = useState('World');

  // FEATURE: Declarative UI - describe what the UI looks like
  return (
    <div>
      <Greeting name={user} />
      <button onClick={() => setUser('React Developer')}>
        Change Name
      </button>
    </div>
  );
}

export default App;
```

---

## 3. Virtual DOM and How It Works

### What is the DOM?
The **DOM (Document Object Model)** is a tree-like structure that represents the HTML of a web page. The browser uses it to render content on the screen. Manipulating the real DOM directly is **slow and expensive**.

### What is the Virtual DOM?
The **Virtual DOM** is a **lightweight JavaScript copy** (in-memory representation) of the real DOM. React uses it to optimize updates.

### How Does It Work? (Step by Step)

1. **Initial Render**: React creates a Virtual DOM tree that mirrors the real DOM
2. **State/Props Change**: When data changes, React creates a **new Virtual DOM** tree
3. **Diffing Algorithm**: React compares the new Virtual DOM with the previous one to find differences (this process is called **"diffing"** or **"reconciliation"**)
4. **Batch Update**: React calculates the minimum number of changes needed and updates **only those parts** of the real DOM (this process is called **"patching"**)

### Visual Flow:
```
State Change → New Virtual DOM → Diff with Old Virtual DOM → Patch Real DOM
```

### Why is Virtual DOM Faster?
- **Batch Updates**: Multiple state changes are batched together into a single DOM update
- **Minimal Changes**: Only the changed elements are updated, not the entire page
- **In-Memory Operations**: Comparing JavaScript objects (Virtual DOM) is much faster than manipulating real DOM nodes

```jsx
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  // When setCount is called:
  // 1. React creates a NEW Virtual DOM with updated count
  // 2. React DIFFS the new VDOM against the old VDOM
  // 3. React finds that only the <p> text changed
  // 4. React updates ONLY that <p> element in the real DOM
  //    (not the entire component or page)
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}

export default Counter;
```

---

## 4. Components in React

**Components** are the **building blocks** of a React application. They are independent, reusable pieces of UI that can accept inputs (props) and return React elements (JSX) describing what should appear on the screen.

React has **two types** of components:

### Class Components

Class components are ES6 classes that extend `React.Component`. They have:
- A `render()` method that returns JSX
- Access to `state` and lifecycle methods
- `this` keyword to access props, state, and methods

```jsx
import React, { Component } from 'react';

// Class component MUST extend React.Component
class Welcome extends Component {
  // constructor is used to initialize state
  constructor(props) {
    super(props); // MUST call super(props) to access this.props
    this.state = {
      message: 'Welcome to React!',
    };
  }

  // render() is the ONLY required method in a class component
  // It returns JSX that describes what the UI should look like
  render() {
    return (
      <div>
        {/* Access props using this.props */}
        <h1>Hello, {this.props.name}!</h1>
        {/* Access state using this.state */}
        <p>{this.state.message}</p>
      </div>
    );
  }
}

// Usage: <Welcome name="John" />
export default Welcome;
```

### Functional Components

Functional components are **plain JavaScript functions** that accept props and return JSX. They are simpler, easier to read, and the **recommended approach** in modern React.

```jsx
import React, { useState } from 'react';

// Functional component — a plain JavaScript function
// It receives props as a parameter (object)
function Welcome({ name }) {
  // useState hook replaces this.state in class components
  const [message, setMessage] = useState('Welcome to React!');

  // No render() method needed — just return JSX directly
  return (
    <div>
      <h1>Hello, {name}!</h1>
      <p>{message}</p>
      <button onClick={() => setMessage('You clicked the button!')}>
        Click Me
      </button>
    </div>
  );
}

// Arrow function syntax (also valid)
const Goodbye = ({ name }) => {
  return <h2>Goodbye, {name}!</h2>;
};

// Usage: <Welcome name="John" />
export default Welcome;
```

### Class vs Functional Components Comparison:
| Feature | Class Component | Functional Component |
|---------|----------------|---------------------|
| Syntax | ES6 class with `render()` | Plain function |
| State | `this.state` + `this.setState()` | `useState()` hook |
| Lifecycle | Lifecycle methods (`componentDidMount`, etc.) | `useEffect()` hook |
| `this` keyword | Required | Not needed |
| Performance | Slightly heavier | Slightly lighter |
| Modern Usage | Legacy (still supported) | **Recommended** |

---

## 5. What is JSX?

**JSX (JavaScript XML)** is a syntax extension for JavaScript that allows you to write **HTML-like code** inside JavaScript. It is **not valid JavaScript** — Babel compiles (transpiles) JSX into regular JavaScript function calls (`React.createElement()`).

### Key Rules of JSX:
1. **Return a single root element** — wrap multiple elements in a `<div>` or `<React.Fragment>`
2. **Close all tags** — self-closing tags must have `/>`  (e.g., `<img />`, `<br />`)
3. **Use `className` instead of `class`** — because `class` is a reserved word in JS
4. **Use `htmlFor` instead of `for`** — because `for` is a reserved word in JS
5. **JavaScript expressions go inside `{}`** — variables, functions, ternaries, etc.
6. **CamelCase for attributes** — `onClick`, `onChange`, `tabIndex`, etc.

```jsx
import React from 'react';

function JSXExample() {
  const name = 'React Developer';
  const isLoggedIn = true;
  const items = ['Apple', 'Banana', 'Cherry'];

  return (
    // RULE 1: Single root element — everything wrapped in one <div>
    <div>
      {/* RULE 3: Use className instead of class */}
      <h1 className="title">Hello JSX!</h1>

      {/* RULE 5: JavaScript expressions inside curly braces {} */}
      <p>Welcome, {name}</p>

      {/* Ternary operator for conditional rendering */}
      <p>{isLoggedIn ? 'You are logged in' : 'Please log in'}</p>

      {/* JavaScript expressions — calling .map() on an array */}
      <ul>
        {items.map((item, index) => (
          <li key={index}>{item}</li>
        ))}
      </ul>

      {/* RULE 2: Self-closing tags must end with /> */}
      <img src="logo.png" alt="Logo" />
      <br />

      {/* RULE 6: CamelCase for event handlers */}
      <button onClick={() => alert('Clicked!')}>Click Me</button>

      {/* RULE 4: Use htmlFor instead of for */}
      <label htmlFor="email">Email:</label>
      <input id="email" type="email" />
    </div>
  );
}

export default JSXExample;
```

### JSX Under the Hood:
```jsx
// What you write (JSX):
const element = <h1 className="greeting">Hello, world!</h1>;

// What Babel compiles it to (JavaScript):
const element = React.createElement(
  'h1',                          // tag name
  { className: 'greeting' },    // props/attributes
  'Hello, world!'               // children (content)
);
```

---

## 6. Export and Import Components

React uses **ES6 modules** to organize code. There are two types of exports:

### Default Export (one per file)
```jsx
// ---- Greeting.jsx ----
// Default export — you can import it with ANY name
function Greeting() {
  return <h1>Hello!</h1>;
}

export default Greeting;

// ---- App.jsx ----
// Import with any name (no curly braces needed)
import Greeting from './Greeting';       // works
import MyGreeting from './Greeting';     // also works — same component
```

### Named Export (multiple per file)
```jsx
// ---- utils.jsx ----
// Named exports — you can have MULTIPLE named exports in one file
export function Add(a, b) {
  return a + b;
}

export function Subtract(a, b) {
  return a - b;
}

export const PI = 3.14159;

// ---- App.jsx ----
// Import with EXACT name inside curly braces {}
import { Add, Subtract, PI } from './utils';

// You can also rename using 'as'
import { Add as Sum } from './utils';
```

### Combining Both:
```jsx
// ---- components.jsx ----
// Default export
function MainComponent() {
  return <h1>Main</h1>;
}

// Named exports
export function Header() {
  return <header>Header</header>;
}

export function Footer() {
  return <footer>Footer</footer>;
}

export default MainComponent;

// ---- App.jsx ----
// Import default AND named exports together
import MainComponent, { Header, Footer } from './components';
```

---

## 7. Nested Components

**Nested components** means using one component inside another. This is how you build complex UIs from small, reusable pieces.

```jsx
import React from 'react';

// Child component 1 — a simple header
function Header() {
  return (
    <header>
      <h1>My Website</h1>
      <Navigation /> {/* Nesting Navigation inside Header */}
    </header>
  );
}

// Child component 2 — navigation menu
function Navigation() {
  return (
    <nav>
      <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/about">About</a></li>
        <li><a href="/contact">Contact</a></li>
      </ul>
    </nav>
  );
}

// Child component 3 — main content area
function MainContent() {
  return (
    <main>
      <h2>Welcome to my site!</h2>
      <p>This is the main content area.</p>
      <Card title="Card 1" description="First card" />  {/* Nested Card */}
      <Card title="Card 2" description="Second card" /> {/* Nested Card */}
    </main>
  );
}

// Reusable child component with props
function Card({ title, description }) {
  return (
    <div className="card">
      <h3>{title}</h3>
      <p>{description}</p>
    </div>
  );
}

// Child component 4 — footer
function Footer() {
  return <footer><p>&copy; 2024 My Website</p></footer>;
}

// PARENT component — composes all children together
function App() {
  return (
    <div>
      <Header />       {/* Nested child component */}
      <MainContent />  {/* Nested child component */}
      <Footer />       {/* Nested child component */}
    </div>
  );
}

// Component tree structure:
// App
// ├── Header
// │   └── Navigation
// ├── MainContent
// │   ├── Card
// │   └── Card
// └── Footer

export default App;
```

---

## 8. State in React

**State** is a built-in object that stores **data that belongs to a component** and can **change over time**. When state changes, React **re-renders** the component to reflect the new data.

### Key Points:
- State is **local** and **private** to the component
- State is **mutable** (can be changed) — unlike props
- Changing state triggers a **re-render** of the component
- State should hold data that the UI depends on

### State in Class Components:
```jsx
import React, { Component } from 'react';

class Counter extends Component {
  // Initialize state in the constructor
  constructor(props) {
    super(props);
    // state is always an object in class components
    this.state = {
      count: 0,
      name: 'Counter App',
    };
  }

  render() {
    return (
      <div>
        <h1>{this.state.name}</h1>
        {/* Access state values using this.state.propertyName */}
        <p>Count: {this.state.count}</p>
        <button onClick={() => this.setState({ count: this.state.count + 1 })}>
          Increment
        </button>
      </div>
    );
  }
}

export default Counter;
```

### State in Functional Components (with `useState`):
```jsx
import React, { useState } from 'react';

function Counter() {
  // useState returns an array: [currentValue, setterFunction]
  // 0 is the initial value of count
  const [count, setCount] = useState(0);
  const [name, setName] = useState('Counter App');

  return (
    <div>
      <h1>{name}</h1>
      <p>Count: {count}</p>
      {/* Use the setter function to update state */}
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}

export default Counter;
```

---

## 9. How to Update State in React

### In Class Components — `this.setState()`
```jsx
import React, { Component } from 'react';

class Counter extends Component {
  constructor(props) {
    super(props);
    this.state = { count: 0 };
  }

  increment = () => {
    // METHOD 1: Pass an object — merges with existing state
    this.setState({ count: this.state.count + 1 });

    // METHOD 2: Pass a function — use when new state depends on previous state
    // This is the RECOMMENDED approach for dependent updates
    this.setState((prevState) => ({
      count: prevState.count + 1,
    }));
  };

  render() {
    return (
      <div>
        <p>Count: {this.state.count}</p>
        <button onClick={this.increment}>Increment</button>
      </div>
    );
  }
}
```

### In Functional Components — setter from `useState`
```jsx
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  const increment = () => {
    // METHOD 1: Pass a direct value
    setCount(count + 1);

    // METHOD 2: Pass a function (RECOMMENDED for dependent updates)
    // prevCount is guaranteed to be the latest value
    setCount((prevCount) => prevCount + 1);
  };

  // Updating objects in state (must create a NEW object)
  const [user, setUser] = useState({ name: 'John', age: 25 });

  const updateAge = () => {
    // CORRECT: Spread existing state and override specific fields
    setUser((prevUser) => ({ ...prevUser, age: prevUser.age + 1 }));
  };

  // Updating arrays in state (must create a NEW array)
  const [items, setItems] = useState(['Apple', 'Banana']);

  const addItem = () => {
    // CORRECT: Spread existing array and add new item
    setItems((prevItems) => [...prevItems, 'Cherry']);
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={increment}>Increment</button>

      <p>Name: {user.name}, Age: {user.age}</p>
      <button onClick={updateAge}>Increase Age</button>

      <ul>{items.map((item, i) => <li key={i}>{item}</li>)}</ul>
      <button onClick={addItem}>Add Cherry</button>
    </div>
  );
}

export default Counter;
```

---

## 10. What is setState Callback?

In **class components**, `this.setState()` is **asynchronous**. React may batch multiple `setState` calls for performance. If you need to run code **after** the state has been updated, use the **callback** (second argument of `setState`).

```jsx
import React, { Component } from 'react';

class CallbackExample extends Component {
  constructor(props) {
    super(props);
    this.state = { count: 0 };
  }

  increment = () => {
    // setState is ASYNCHRONOUS — the state is NOT updated immediately
    this.setState({ count: this.state.count + 1 });
    console.log(this.state.count); // Logs OLD value (e.g., 0), NOT updated value

    // SOLUTION: Use the callback (second argument)
    // The callback runs AFTER state is updated and the component re-renders
    this.setState(
      { count: this.state.count + 1 },
      () => {
        // This runs AFTER state is updated
        console.log('Updated count:', this.state.count); // Logs NEW value (e.g., 1)
        // You can do anything here: API calls, logging, triggering other actions
      }
    );
  };

  render() {
    return (
      <div>
        <p>Count: {this.state.count}</p>
        <button onClick={this.increment}>Increment</button>
      </div>
    );
  }
}

export default CallbackExample;
```

### In Functional Components:
There is **no callback** for `useState`. Use `useEffect` to react to state changes instead:

```jsx
import React, { useState, useEffect } from 'react';

function CallbackExample() {
  const [count, setCount] = useState(0);

  // useEffect runs AFTER the component re-renders when 'count' changes
  // This is the functional component equivalent of setState callback
  useEffect(() => {
    console.log('Updated count:', count);
    // Run side effects here (API calls, logging, etc.)
  }, [count]); // dependency array — runs when 'count' changes

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount((prev) => prev + 1)}>Increment</button>
    </div>
  );
}

export default CallbackExample;
```

---

## 11. Why Not Update State Directly?

You should **never** modify state directly. Always use `setState()` (class) or the setter function (functional).

### Why?
1. **No re-render**: Directly mutating state does NOT trigger a re-render, so the UI won't update
2. **Lost updates**: React may overwrite your direct mutations during the next `setState` call
3. **Breaks React's internal tracking**: React relies on immutability to detect changes via the diffing algorithm

```jsx
import React, { Component } from 'react';

class DirectMutationExample extends Component {
  constructor(props) {
    super(props);
    this.state = { count: 0, items: ['Apple', 'Banana'] };
  }

  // WRONG — directly mutating state
  wrongUpdate = () => {
    this.state.count = this.state.count + 1;  // Direct mutation
    console.log(this.state.count); // Value changes in memory but...
    // ...the component does NOT re-render! UI shows old value.
  };

  // CORRECT — using setState
  correctUpdate = () => {
    this.setState({ count: this.state.count + 1 });
    // React detects the change, re-renders, and updates the UI
  };

  // WRONG — mutating array directly
  wrongArrayUpdate = () => {
    this.state.items.push('Cherry'); // Mutates the SAME array reference
    this.setState({ items: this.state.items }); // React may NOT detect change
  };

  // CORRECT — creating a new array
  correctArrayUpdate = () => {
    this.setState({
      items: [...this.state.items, 'Cherry'], // New array reference
    });
  };

  render() {
    return (
      <div>
        <p>Count: {this.state.count}</p>
        <button onClick={this.wrongUpdate}>Wrong Update</button>
        <button onClick={this.correctUpdate}>Correct Update</button>
      </div>
    );
  }
}

export default DirectMutationExample;
```

### Functional Component — Same Rule Applies:
```jsx
import React, { useState } from 'react';

function Example() {
  const [user, setUser] = useState({ name: 'John', age: 25 });

  // WRONG — mutating state directly
  const wrongUpdate = () => {
    user.age = 30; // Directly mutating the state object
    setUser(user); // React sees the SAME reference — may skip re-render!
  };

  // CORRECT — creating a new object
  const correctUpdate = () => {
    setUser({ ...user, age: 30 }); // New object reference — React detects change
  };

  return (
    <div>
      <p>{user.name}, Age: {user.age}</p>
      <button onClick={correctUpdate}>Update Age</button>
    </div>
  );
}

export default Example;
```

---

## 12. Props in React

**Props (short for Properties)** are **read-only** inputs passed from a **parent** component to a **child** component. They allow data to flow **downward** through the component tree.

### Key Points:
- Props are **immutable** (read-only) — a child cannot modify its own props
- Props enable **one-way data flow** (parent → child)
- Props can be any JavaScript value: strings, numbers, arrays, objects, functions, even other components

```jsx
import React from 'react';

// Child component receives props as a parameter
// Using destructuring to extract individual props
function UserCard({ name, age, email, isAdmin, hobbies, onGreet }) {
  return (
    <div className="user-card">
      {/* String prop */}
      <h2>{name}</h2>

      {/* Number prop */}
      <p>Age: {age}</p>

      {/* String prop */}
      <p>Email: {email}</p>

      {/* Boolean prop — conditional rendering */}
      {isAdmin && <span className="badge">Admin</span>}

      {/* Array prop */}
      <ul>
        {hobbies.map((hobby, index) => (
          <li key={index}>{hobby}</li>
        ))}
      </ul>

      {/* Function prop — callback passed from parent */}
      <button onClick={onGreet}>Say Hello</button>
    </div>
  );
}

// Parent component passes props to child
function App() {
  const handleGreet = () => {
    alert('Hello from the parent!');
  };

  return (
    <div>
      {/* Passing various types of props */}
      <UserCard
        name="John Doe"           // String prop
        age={30}                  // Number prop (use {} for non-string values)
        email="john@example.com"  // String prop
        isAdmin={true}            // Boolean prop
        hobbies={['Reading', 'Coding', 'Gaming']} // Array prop
        onGreet={handleGreet}     // Function prop
      />
    </div>
  );
}

export default App;
```

---

## 13. Difference Between State and Props

| Feature | State | Props |
|---------|-------|-------|
| **Owner** | Owned by the component itself | Passed from parent to child |
| **Mutability** | Mutable (can change via `setState` / setter) | Immutable (read-only) |
| **Where Declared** | Inside the component | Passed as attributes in JSX |
| **Triggers Re-render** | Yes, when updated | Yes, when parent re-renders with new props |
| **Purpose** | Internal data management | Communication between components |
| **Who Can Modify** | Only the component that owns it | Only the parent that passes it |

```jsx
import React, { useState } from 'react';

// Child component — uses PROPS (received from parent)
function Display({ message, count }) {
  // Props are READ-ONLY — you cannot do: message = "new value" ❌
  return (
    <div>
      <p>Message (from prop): {message}</p>
      <p>Count (from prop): {count}</p>
    </div>
  );
}

// Parent component — manages STATE and passes it as PROPS
function App() {
  // STATE — owned by this component, can be changed
  const [count, setCount] = useState(0);
  const [message, setMessage] = useState('Hello!');

  return (
    <div>
      {/* State values are passed as props to the child */}
      <Display message={message} count={count} />

      {/* Only the parent (state owner) can update the state */}
      <button onClick={() => setCount(count + 1)}>Increment</button>
      <button onClick={() => setMessage('Updated!')}>Change Message</button>
    </div>
  );
}

export default App;
```

---

## 14. Lifting State Up

**Lifting state up** means moving state from a child component to the **nearest common parent** so that multiple sibling components can **share** and **sync** the same data.

### When to use:
- When two or more sibling components need access to the same data
- When a child component needs to communicate data to a sibling

```jsx
import React, { useState } from 'react';

// BEFORE lifting state up — each component has its own independent state
// Problem: TemperatureInput components can't share data with each other

// AFTER lifting state up:

// Child 1 — Celsius input (does NOT own state, receives via props)
function CelsiusInput({ temperature, onTemperatureChange }) {
  return (
    <div>
      <label>Celsius: </label>
      <input
        type="number"
        value={temperature}
        // Calls the parent's function to update state
        onChange={(e) => onTemperatureChange(e.target.value)}
      />
    </div>
  );
}

// Child 2 — Fahrenheit display (does NOT own state, receives via props)
function FahrenheitDisplay({ celsius }) {
  // Convert celsius to fahrenheit
  const fahrenheit = celsius ? (parseFloat(celsius) * 9) / 5 + 32 : '';
  return <p>Fahrenheit: {fahrenheit}</p>;
}

// Child 3 — Water status (does NOT own state, receives via props)
function WaterStatus({ celsius }) {
  if (celsius >= 100) return <p>Water is boiling!</p>;
  if (celsius <= 0) return <p>Water is freezing!</p>;
  return <p>Water is liquid.</p>;
}

// PARENT — owns the shared state (state is "lifted up" here)
function TemperatureCalculator() {
  // State is managed HERE and shared with all children via props
  const [celsius, setCelsius] = useState('');

  return (
    <div>
      <h2>Temperature Calculator</h2>
      {/* Pass state value AND updater function to child */}
      <CelsiusInput
        temperature={celsius}
        onTemperatureChange={setCelsius}
      />
      {/* Both siblings receive the same state as props */}
      <FahrenheitDisplay celsius={celsius} />
      <WaterStatus celsius={celsius} />
    </div>
  );
}

// Flow:
// 1. User types in CelsiusInput
// 2. CelsiusInput calls onTemperatureChange (parent's setCelsius)
// 3. Parent state updates → re-renders
// 4. New celsius value is passed as props to ALL children
// 5. FahrenheitDisplay and WaterStatus update automatically

export default TemperatureCalculator;
```

---

## 15. Children Prop

The **`children` prop** is a special prop that contains whatever you put **between the opening and closing tags** of a component. It is used to create **wrapper/container** components.

```jsx
import React from 'react';

// Wrapper component that uses children prop
// Everything placed between <Card> and </Card> is accessible via children
function Card({ title, children }) {
  return (
    <div style={{
      border: '1px solid #ccc',
      borderRadius: '8px',
      padding: '16px',
      margin: '10px',
    }}>
      <h3>{title}</h3>
      <div className="card-content">
        {/* children renders whatever is placed between <Card>...</Card> */}
        {children}
      </div>
    </div>
  );
}

// Layout component using children
function PageLayout({ children }) {
  return (
    <div className="page-layout">
      <header><h1>My Website</h1></header>
      <main>{children}</main> {/* Page content goes here */}
      <footer><p>Footer</p></footer>
    </div>
  );
}

// Modal component using children
function Modal({ isOpen, onClose, children }) {
  if (!isOpen) return null; // Don't render if modal is closed

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        {children} {/* Any content can go inside the modal */}
        <button onClick={onClose}>Close</button>
      </div>
    </div>
  );
}

// App — uses the wrapper components with children
function App() {
  return (
    <PageLayout>
      {/* Everything here becomes the 'children' prop of PageLayout */}

      <Card title="User Profile">
        {/* Everything here becomes the 'children' prop of Card */}
        <p>Name: John Doe</p>
        <p>Age: 30</p>
        <button>Edit Profile</button>
      </Card>

      <Card title="Product Info">
        {/* Different children for the same Card component */}
        <img src="product.jpg" alt="Product" />
        <p>Price: $29.99</p>
      </Card>
    </PageLayout>
  );
}

export default App;
```

---

## 16. DefaultProps

**`defaultProps`** allow you to define **default values** for props that are not provided by the parent component.

```jsx
import React from 'react';

// METHOD 1: Default values using destructuring (RECOMMENDED for functional components)
function Button({ text = 'Click Me', color = 'blue', size = 'medium', onClick }) {
  const sizes = { small: '12px', medium: '16px', large: '20px' };

  return (
    <button
      onClick={onClick}
      style={{
        backgroundColor: color,
        fontSize: sizes[size],
        padding: '10px 20px',
        color: 'white',
        border: 'none',
        borderRadius: '4px',
        cursor: 'pointer',
      }}
    >
      {text}
    </button>
  );
}

// METHOD 2: Using defaultProps property (works for both class and functional)
function Greeting({ name, greeting, punctuation }) {
  return <h1>{greeting}, {name}{punctuation}</h1>;
}

// Define default values as a static property
Greeting.defaultProps = {
  name: 'Guest',
  greeting: 'Hello',
  punctuation: '!',
};

// App — demonstrates default props in action
function App() {
  return (
    <div>
      {/* All defaults used — renders "Click Me" button in blue, medium size */}
      <Button />

      {/* Override some defaults */}
      <Button text="Submit" color="green" />

      {/* Override all defaults */}
      <Button text="Delete" color="red" size="large" onClick={() => alert('Deleted!')} />

      {/* Greeting with all defaults: "Hello, Guest!" */}
      <Greeting />

      {/* Override name only: "Hello, John!" */}
      <Greeting name="John" />

      {/* Override everything: "Welcome, Sarah." */}
      <Greeting name="Sarah" greeting="Welcome" punctuation="." />
    </div>
  );
}

export default App;
```

---

## 17. Fragments

**React Fragments** let you **group multiple elements** without adding an extra DOM node (like a `<div>`). This keeps the DOM tree clean.

### Why Fragments?
- JSX requires a **single root element**
- Using `<div>` as a wrapper creates unnecessary DOM nodes
- Fragments solve this by grouping elements **without adding to the DOM**

```jsx
import React, { Fragment } from 'react';

// PROBLEM: Without fragments, you add unnecessary divs to the DOM
function WithoutFragment() {
  return (
    <div> {/* This div is ONLY for wrapping — it adds an unnecessary DOM node */}
      <h1>Title</h1>
      <p>Description</p>
    </div>
  );
}

// SOLUTION 1: Using React.Fragment (full syntax)
function WithFragment() {
  return (
    <React.Fragment>
      <h1>Title</h1>
      <p>Description</p>
    </React.Fragment>
  );
}

// SOLUTION 2: Using short syntax <> </> (RECOMMENDED)
function WithShortFragment() {
  return (
    <>
      <h1>Title</h1>
      <p>Description</p>
    </>
  );
}

// Use full syntax when you need the 'key' prop (e.g., in lists)
function ItemList({ items }) {
  return (
    <dl>
      {items.map((item) => (
        // Short syntax <> does NOT support key prop
        // Use <Fragment key={}> when mapping
        <Fragment key={item.id}>
          <dt>{item.term}</dt>
          <dd>{item.description}</dd>
        </Fragment>
      ))}
    </dl>
  );
}

// Practical example: Table rows (divs inside <table> are invalid HTML)
function TableRows() {
  return (
    <table>
      <tbody>
        <tr>
          {/* Using <div> here would break the table structure! */}
          {/* Fragment keeps the DOM valid */}
          <>
            <td>Name</td>
            <td>Age</td>
            <td>Email</td>
          </>
        </tr>
      </tbody>
    </table>
  );
}

export default WithShortFragment;
```

### Advantages of Fragments:
1. **No extra DOM nodes** — cleaner HTML output
2. **Better performance** — fewer DOM elements to render
3. **Valid HTML structure** — avoids breaking elements like `<table>`, `<ul>`, `<select>`
4. **Supports `key` prop** — useful when rendering lists with `<Fragment key={...}>`

---

## 18. Styling in React

React offers multiple ways to style components:

### Method 1: Inline Styles
```jsx
function InlineStyleExample() {
  // Inline styles are JavaScript objects (camelCase properties, values as strings)
  const headingStyle = {
    color: 'blue',
    fontSize: '24px',      // camelCase (not font-size)
    backgroundColor: '#f0f0f0',
    padding: '10px',
    borderRadius: '8px',
  };

  return (
    <div>
      {/* Pass style object to the style attribute */}
      <h1 style={headingStyle}>Styled Heading</h1>

      {/* Inline style directly (double curly braces: outer={} for JSX, inner={} for object) */}
      <p style={{ color: 'red', fontWeight: 'bold' }}>Red bold text</p>
    </div>
  );
}
```

### Method 2: External CSS File
```css
/* styles.css */
.card {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.card-title {
  color: #333;
  font-size: 20px;
}

.btn-primary {
  background-color: #007bff;
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
```

```jsx
// Import the CSS file
import './styles.css';

function ExternalCSSExample() {
  return (
    // Use className (not class) to apply CSS classes
    <div className="card">
      <h2 className="card-title">Card Title</h2>
      <p>Card content goes here.</p>
      <button className="btn-primary">Click Me</button>
    </div>
  );
}
```

### Method 3: CSS Modules (scoped styles — prevents class name conflicts)
```css
/* Button.module.css */
.button {
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.primary {
  background-color: blue;
  color: white;
}
```

```jsx
// Import as a module — class names become properties of the styles object
import styles from './Button.module.css';

function CSSModuleExample() {
  return (
    // Access class names as properties: styles.button, styles.primary
    <button className={`${styles.button} ${styles.primary}`}>
      Module Button
    </button>
  );
}
```

### Method 4: Conditional Styling
```jsx
function ConditionalStyleExample({ isActive, isError }) {
  return (
    <div>
      {/* Conditional class names */}
      <p className={isActive ? 'active' : 'inactive'}>Status</p>

      {/* Multiple conditional classes */}
      <p className={`base-class ${isError ? 'error' : ''} ${isActive ? 'active' : ''}`}>
        Dynamic Classes
      </p>

      {/* Conditional inline styles */}
      <p style={{ color: isError ? 'red' : 'green' }}>
        {isError ? 'Error occurred' : 'All good'}
      </p>
    </div>
  );
}
```

---

## 19. Conditional Rendering

**Conditional rendering** means showing or hiding components/elements based on conditions — just like `if/else` in JavaScript.

```jsx
import React, { useState } from 'react';

function ConditionalRendering() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [role, setRole] = useState('user');
  const [items, setItems] = useState([]);
  const [error, setError] = useState(null);

  return (
    <div>
      {/* METHOD 1: Ternary Operator (condition ? true : false) */}
      {/* Best for: choosing between TWO elements */}
      <h1>{isLoggedIn ? 'Welcome back!' : 'Please log in'}</h1>
      {isLoggedIn ? (
        <button onClick={() => setIsLoggedIn(false)}>Logout</button>
      ) : (
        <button onClick={() => setIsLoggedIn(true)}>Login</button>
      )}

      {/* METHOD 2: Logical AND (&&) */}
      {/* Best for: showing/hiding a SINGLE element */}
      {/* Renders the element ONLY if the condition is true */}
      {isLoggedIn && <p>You are logged in.</p>}
      {error && <p className="error">{error}</p>}
      {items.length > 0 && <p>You have {items.length} items</p>}

      {/* METHOD 3: Logical OR (||) */}
      {/* Renders fallback if first value is falsy */}
      <p>Role: {role || 'No role assigned'}</p>

      {/* METHOD 4: if/else using a helper function */}
      {renderContent(role)}

      {/* METHOD 5: Nullish coalescing */}
      <p>Status: {error ?? 'No errors'}</p>
    </div>
  );
}

// Helper function for complex conditional logic
function renderContent(role) {
  if (role === 'admin') {
    return <AdminDashboard />;
  } else if (role === 'user') {
    return <UserDashboard />;
  } else {
    return <GuestPage />;
  }
}

// Using switch statement for multiple conditions
function StatusBadge({ status }) {
  switch (status) {
    case 'active':
      return <span style={{ color: 'green' }}>Active</span>;
    case 'inactive':
      return <span style={{ color: 'red' }}>Inactive</span>;
    case 'pending':
      return <span style={{ color: 'orange' }}>Pending</span>;
    default:
      return <span>Unknown</span>;
  }
}

// Returning null to render nothing
function WarningBanner({ show, message }) {
  // Returning null prevents the component from rendering
  if (!show) return null;

  return <div className="warning">{message}</div>;
}

export default ConditionalRendering;
```

---

## 20. Rendering List of Data

Use the JavaScript `Array.map()` method to render lists of data in React.

```jsx
import React from 'react';

function ListRendering() {
  // Simple array of strings
  const fruits = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

  // Array of objects
  const users = [
    { id: 1, name: 'John', email: 'john@email.com', isActive: true },
    { id: 2, name: 'Jane', email: 'jane@email.com', isActive: false },
    { id: 3, name: 'Bob', email: 'bob@email.com', isActive: true },
  ];

  return (
    <div>
      {/* Rendering a simple list of strings */}
      <h2>Fruits</h2>
      <ul>
        {/* .map() iterates over each item and returns JSX for each */}
        {fruits.map((fruit, index) => (
          <li key={index}>{fruit}</li>
          // key prop helps React identify which items changed
        ))}
      </ul>

      {/* Rendering a list of objects */}
      <h2>Users</h2>
      <div>
        {users.map((user) => (
          // Use unique ID as key (better than index)
          <div key={user.id} className="user-card">
            <h3>{user.name}</h3>
            <p>Email: {user.email}</p>
            <p>Status: {user.isActive ? 'Active' : 'Inactive'}</p>
          </div>
        ))}
      </div>

      {/* Rendering with a separate component */}
      <h2>User Cards</h2>
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}

      {/* Filtering and rendering */}
      <h2>Active Users Only</h2>
      {users
        .filter((user) => user.isActive)  // Filter first
        .map((user) => (                  // Then map
          <p key={user.id}>{user.name} is active</p>
        ))}
    </div>
  );
}

// Separate component for rendering each user
function UserCard({ user }) {
  return (
    <div style={{ border: '1px solid #ccc', padding: '10px', margin: '5px' }}>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  );
}

export default ListRendering;
```

---

## 21. Key Prop

The **`key` prop** is a special attribute you must include when creating lists of elements. It helps React **identify which items have changed, been added, or removed**.

```jsx
import React, { useState } from 'react';

function KeyPropExample() {
  const [items, setItems] = useState([
    { id: 101, text: 'Learn React' },
    { id: 102, text: 'Build a project' },
    { id: 103, text: 'Deploy to production' },
  ]);

  const addItem = () => {
    const newItem = { id: Date.now(), text: `New Item ${items.length + 1}` };
    setItems([newItem, ...items]); // Add to beginning
  };

  const removeItem = (id) => {
    setItems(items.filter((item) => item.id !== id));
  };

  return (
    <div>
      <button onClick={addItem}>Add Item</button>
      <ul>
        {items.map((item) => (
          // CORRECT: Use a unique, stable identifier as key
          <li key={item.id}>
            {item.text}
            <button onClick={() => removeItem(item.id)}>Remove</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default KeyPropExample;
```

### Rules for Keys:
1. **Keys must be unique among siblings** (not globally unique)
2. **Keys should be stable** — don't change between renders
3. **Use unique IDs** from your data (database IDs, UUIDs)
4. **Don't use array indexes** as keys (explained in next section)
5. **Keys are NOT passed as props** — they're used internally by React

---

## 22. Why Indexes for Keys Are Not Recommended

Using array indexes as keys can cause **bugs** when the list is **reordered, filtered, or items are added/removed**.

```jsx
import React, { useState } from 'react';

// PROBLEM DEMONSTRATION
function IndexKeyProblem() {
  const [items, setItems] = useState(['Apple', 'Banana', 'Cherry']);

  const addToStart = () => {
    setItems(['New Fruit', ...items]); // Add to beginning of array
  };

  return (
    <div>
      <button onClick={addToStart}>Add to Start</button>

      {/* BAD: Using index as key */}
      {/* When "New Fruit" is added at index 0:
          - "New Fruit" gets key=0 (Apple's old key!)
          - "Apple" gets key=1 (Banana's old key!)
          - "Banana" gets key=2 (Cherry's old key!)
          - "Cherry" gets key=3 (new key)
          React thinks items 0, 1, 2 were UPDATED (not shifted)
          This causes unnecessary re-renders and can break input states! */}
      <h3>Bad (index keys):</h3>
      {items.map((item, index) => (
        <div key={index}>
          <span>{item}: </span>
          <input type="text" placeholder="Type here..." />
          {/* Bug: Input values won't follow their items when list reorders! */}
        </div>
      ))}
    </div>
  );
}

// SOLUTION: Use unique IDs
function UniqueKeyCorrect() {
  const [items, setItems] = useState([
    { id: 1, name: 'Apple' },
    { id: 2, name: 'Banana' },
    { id: 3, name: 'Cherry' },
  ]);

  const addToStart = () => {
    setItems([{ id: Date.now(), name: 'New Fruit' }, ...items]);
  };

  return (
    <div>
      <button onClick={addToStart}>Add to Start</button>

      {/* GOOD: Using unique IDs as keys */}
      {/* Each item keeps its identity regardless of position */}
      <h3>Good (unique keys):</h3>
      {items.map((item) => (
        <div key={item.id}>
          <span>{item.name}: </span>
          <input type="text" placeholder="Type here..." />
          {/* Input values correctly follow their items */}
        </div>
      ))}
    </div>
  );
}

export default UniqueKeyCorrect;
```

### When Index Keys Are OK:
- The list is **static** and will never change
- Items are **never reordered, filtered, or modified**
- Items have **no stable unique ID**

---

## 23. Handling Buttons in React

```jsx
import React, { useState } from 'react';

function ButtonHandling() {
  const [count, setCount] = useState(0);
  const [message, setMessage] = useState('');

  // Method 1: Inline arrow function
  // Good for simple one-liners

  // Method 2: Named function handler
  const handleClick = () => {
    setCount((prev) => prev + 1);
  };

  // Method 3: Handler with parameters
  const handleGreet = (name) => {
    setMessage(`Hello, ${name}!`);
  };

  // Method 4: Accessing the event object
  const handleButtonInfo = (event) => {
    console.log('Button text:', event.target.textContent);
    console.log('Button type:', event.target.type);
    // event is a SyntheticEvent (React's cross-browser wrapper around native events)
  };

  // Method 5: Handler with both event and custom parameter
  const handleAction = (action, event) => {
    event.preventDefault(); // Prevent default behavior
    setMessage(`Action: ${action}`);
  };

  return (
    <div>
      {/* Method 1: Inline handler */}
      <button onClick={() => setCount(count + 1)}>
        Inline: {count}
      </button>

      {/* Method 2: Named handler (no parentheses — pass reference, don't call) */}
      <button onClick={handleClick}>Named: {count}</button>

      {/* Method 3: Handler with arguments (wrap in arrow function) */}
      <button onClick={() => handleGreet('John')}>Greet John</button>
      <button onClick={() => handleGreet('Jane')}>Greet Jane</button>

      {/* Method 4: Event object (automatically passed when no args) */}
      <button onClick={handleButtonInfo}>Show Info</button>

      {/* Method 5: Both event and custom parameter */}
      <button onClick={(e) => handleAction('save', e)}>Save</button>

      <p>{message}</p>
    </div>
  );
}

export default ButtonHandling;
```

> **Important**: Write `onClick={handleClick}` (pass reference), NOT `onClick={handleClick()}` (calling immediately on render).

---

## 24. Handling Inputs in React

```jsx
import React, { useState } from 'react';

function InputHandling() {
  // Single input
  const [name, setName] = useState('');

  // Multiple inputs using a single state object
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    age: '',
  });

  // Handle single input change
  const handleNameChange = (event) => {
    setName(event.target.value); // event.target.value = current input value
  };

  // Handle multiple inputs with a SINGLE handler
  // Uses the input's 'name' attribute to determine which field to update
  const handleFormChange = (event) => {
    const { name, value } = event.target; // Destructure name and value
    setFormData((prev) => ({
      ...prev,       // Spread existing form data
      [name]: value, // Update only the changed field (computed property name)
    }));
  };

  // Handle form submission
  const handleSubmit = (event) => {
    event.preventDefault(); // Prevent page reload
    console.log('Form Data:', formData);
    alert(`Submitted: ${JSON.stringify(formData)}`);
  };

  return (
    <div>
      {/* Single controlled input */}
      <h3>Single Input</h3>
      <input
        type="text"
        value={name}             // Controlled: value comes from state
        onChange={handleNameChange} // Updates state on every keystroke
        placeholder="Enter your name"
      />
      <p>Hello, {name || 'stranger'}!</p>

      {/* Form with multiple controlled inputs */}
      <h3>Form with Multiple Inputs</h3>
      <form onSubmit={handleSubmit}>
        <input
          type="email"
          name="email"               // 'name' matches the state property
          value={formData.email}
          onChange={handleFormChange}  // Same handler for all inputs
          placeholder="Email"
        />
        <br />
        <input
          type="password"
          name="password"
          value={formData.password}
          onChange={handleFormChange}
          placeholder="Password"
        />
        <br />
        <input
          type="number"
          name="age"
          value={formData.age}
          onChange={handleFormChange}
          placeholder="Age"
        />
        <br />
        <button type="submit">Submit</button>
      </form>

      {/* Live preview */}
      <pre>{JSON.stringify(formData, null, 2)}</pre>
    </div>
  );
}

export default InputHandling;
```

---

## 25. Lifecycle Methods in React

Lifecycle methods are special methods in **class components** that run at specific stages of a component's life: **Mounting**, **Updating**, and **Unmounting**.

### The Three Phases:

```
MOUNTING (Birth)          UPDATING (Growth)           UNMOUNTING (Death)
─────────────────         ──────────────────          ─────────────────
constructor()             static getDerivedStateFromProps()   componentWillUnmount()
static getDerivedStateFromProps()   shouldComponentUpdate()
render()                  render()
componentDidMount()       getSnapshotBeforeUpdate()
                          componentDidUpdate()
```

```jsx
import React, { Component } from 'react';

class LifecycleDemo extends Component {
  // ─── PHASE 1: MOUNTING (component is being created and inserted into DOM) ───

  // 1. constructor() — called FIRST when component is created
  constructor(props) {
    super(props);
    this.state = { count: 0, data: null };
    console.log('1. constructor — component is being created');
    // Use for: initializing state, binding methods
    // Do NOT: call setState(), make API calls, or access DOM here
  }

  // 2. static getDerivedStateFromProps() — rarely used
  // Called before EVERY render (both mounting and updating)
  static getDerivedStateFromProps(props, state) {
    console.log('2. getDerivedStateFromProps');
    // Return an object to update state, or null for no update
    return null;
  }

  // 3. render() — REQUIRED method, returns JSX
  // Called during both mounting and updating
  // Must be PURE — no side effects, no setState calls here
  render() {
    console.log('3. render — creating the JSX output');
    return (
      <div>
        <h1>Lifecycle Demo</h1>
        <p>Count: {this.state.count}</p>
        <button onClick={() => this.setState({ count: this.state.count + 1 })}>
          Increment
        </button>
      </div>
    );
  }

  // 4. componentDidMount() — called ONCE after component is rendered to DOM
  componentDidMount() {
    console.log('4. componentDidMount — component is now in the DOM');
    // Use for: API calls, subscriptions, timers, DOM manipulation
    // This is the BEST place for side effects during mounting
    this.timer = setInterval(() => {
      console.log('Timer tick');
    }, 1000);
  }

  // ─── PHASE 2: UPDATING (component is re-rendering due to state/prop changes) ───

  // 5. shouldComponentUpdate() — performance optimization
  shouldComponentUpdate(nextProps, nextState) {
    console.log('5. shouldComponentUpdate');
    // Return true to allow re-render, false to prevent it
    // Default is true — override for optimization
    return true; // or: return nextState.count !== this.state.count;
  }

  // 6. getSnapshotBeforeUpdate() — rarely used
  // Captures info from DOM before it changes (e.g., scroll position)
  getSnapshotBeforeUpdate(prevProps, prevState) {
    console.log('6. getSnapshotBeforeUpdate');
    return null; // return value is passed to componentDidUpdate
  }

  // 7. componentDidUpdate() — called after every re-render
  componentDidUpdate(prevProps, prevState, snapshot) {
    console.log('7. componentDidUpdate — DOM has been updated');
    // Use for: reacting to prop/state changes, API calls based on changes
    // IMPORTANT: Always wrap setState in a condition to avoid infinite loops
    if (prevState.count !== this.state.count) {
      console.log('Count changed from', prevState.count, 'to', this.state.count);
    }
  }

  // ─── PHASE 3: UNMOUNTING (component is being removed from DOM) ───

  // 8. componentWillUnmount() — called just before component is destroyed
  componentWillUnmount() {
    console.log('8. componentWillUnmount — cleaning up');
    // Use for: cleanup (clear timers, cancel API calls, unsubscribe)
    clearInterval(this.timer);
  }
}

export default LifecycleDemo;
```

### Lifecycle Methods → Hooks Mapping:
| Lifecycle Method | Hook Equivalent |
|-----------------|-----------------|
| `constructor` | `useState()` |
| `componentDidMount` | `useEffect(() => {}, [])` |
| `componentDidUpdate` | `useEffect(() => {}, [dependency])` |
| `componentWillUnmount` | `useEffect(() => { return () => cleanup }, [])` |
| `shouldComponentUpdate` | `React.memo()` |

---

## 26. Popular Hooks in React

**Hooks** are functions that let you use React features (state, lifecycle, context, etc.) in **functional components**. Introduced in React 16.8.

### Rules of Hooks:
1. **Only call hooks at the top level** — never inside loops, conditions, or nested functions
2. **Only call hooks from React functions** — functional components or custom hooks

### Overview of Popular Hooks:

| Hook | Purpose |
|------|---------|
| `useState` | Manage local state |
| `useEffect` | Handle side effects (API calls, subscriptions, timers) |
| `useContext` | Consume context values |
| `useReducer` | Complex state management (alternative to useState) |
| `useRef` | Access DOM elements, store mutable values |
| `useMemo` | Memoize expensive calculations |
| `useCallback` | Memoize functions to prevent unnecessary re-creation |
| `useLayoutEffect` | Like useEffect but fires synchronously after DOM mutations |

```jsx
import React, { useState, useEffect, useContext, useReducer, useRef, useMemo, useCallback } from 'react';

function HooksOverview() {
  // useState — manage simple state
  const [count, setCount] = useState(0);

  // useRef — reference a DOM element or store mutable value
  const inputRef = useRef(null);

  // useMemo — memoize expensive computation (only recalculates when count changes)
  const expensiveValue = useMemo(() => {
    return count * 100; // imagine a heavy calculation here
  }, [count]);

  // useCallback — memoize a function (prevents re-creation on every render)
  const handleClick = useCallback(() => {
    setCount((prev) => prev + 1);
  }, []);

  // useEffect — side effects (runs after render)
  useEffect(() => {
    document.title = `Count: ${count}`;
    return () => {
      // Cleanup function (runs before next effect or unmount)
    };
  }, [count]);

  return (
    <div>
      <p>Count: {count}</p>
      <p>Expensive Value: {expensiveValue}</p>
      <button onClick={handleClick}>Increment</button>
      <input ref={inputRef} />
      <button onClick={() => inputRef.current.focus()}>Focus Input</button>
    </div>
  );
}

export default HooksOverview;
```

---

## 27. useState Hook

`useState` is the most fundamental hook for managing state in functional components.

```jsx
import React, { useState } from 'react';

function UseStateExamples() {
  // ─── Basic Usage ───
  // useState returns [currentValue, setterFunction]
  // Argument is the initial value
  const [count, setCount] = useState(0);      // number
  const [name, setName] = useState('');        // string
  const [isVisible, setIsVisible] = useState(false); // boolean

  // ─── Object State ───
  const [user, setUser] = useState({
    firstName: 'John',
    lastName: 'Doe',
    age: 25,
  });

  // Update a single property in an object (MUST spread the rest)
  const updateAge = () => {
    setUser((prevUser) => ({
      ...prevUser,       // keep all existing properties
      age: prevUser.age + 1, // update only age
    }));
  };

  // ─── Array State ───
  const [todos, setTodos] = useState([
    { id: 1, text: 'Learn React', done: false },
    { id: 2, text: 'Build project', done: false },
  ]);

  // Add item to array
  const addTodo = () => {
    setTodos((prev) => [
      ...prev,
      { id: Date.now(), text: 'New Todo', done: false },
    ]);
  };

  // Remove item from array
  const removeTodo = (id) => {
    setTodos((prev) => prev.filter((todo) => todo.id !== id));
  };

  // Update item in array
  const toggleTodo = (id) => {
    setTodos((prev) =>
      prev.map((todo) =>
        todo.id === id ? { ...todo, done: !todo.done } : todo
      )
    );
  };

  // ─── Lazy Initialization ───
  // When initial value is expensive to compute, pass a FUNCTION
  // This function runs ONLY on the first render
  const [expensiveState] = useState(() => {
    console.log('This runs only once — on first render');
    return someExpensiveCalculation();
  });

  // ─── Functional Updates ───
  // When new state depends on previous state, use the function form
  const incrementThreeTimes = () => {
    // WRONG: All three use the SAME stale count value
    // setCount(count + 1); // count is 0
    // setCount(count + 1); // count is still 0
    // setCount(count + 1); // count is still 0  → result: 1

    // CORRECT: Each gets the LATEST previous state
    setCount((prev) => prev + 1); // prev = 0 → 1
    setCount((prev) => prev + 1); // prev = 1 → 2
    setCount((prev) => prev + 1); // prev = 2 → 3  → result: 3
  };

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>+1</button>
      <button onClick={incrementThreeTimes}>+3 (correct)</button>

      <p>{user.firstName} {user.lastName}, Age: {user.age}</p>
      <button onClick={updateAge}>Increase Age</button>

      <ul>
        {todos.map((todo) => (
          <li key={todo.id} style={{ textDecoration: todo.done ? 'line-through' : 'none' }}>
            {todo.text}
            <button onClick={() => toggleTodo(todo.id)}>Toggle</button>
            <button onClick={() => removeTodo(todo.id)}>Delete</button>
          </li>
        ))}
      </ul>
      <button onClick={addTodo}>Add Todo</button>
    </div>
  );
}

function someExpensiveCalculation() {
  return Array.from({ length: 1000 }, (_, i) => i).reduce((a, b) => a + b, 0);
}

export default UseStateExamples;
```

---

## 28. useEffect Hook

`useEffect` lets you perform **side effects** in functional components. Side effects include: data fetching, subscriptions, timers, DOM manipulation, logging.

```jsx
import React, { useState, useEffect } from 'react';

function UseEffectExamples() {
  const [count, setCount] = useState(0);
  const [name, setName] = useState('');
  const [windowWidth, setWindowWidth] = useState(window.innerWidth);

  // ─── PATTERN 1: Run on EVERY render (no dependency array) ───
  useEffect(() => {
    console.log('Runs after EVERY render (mount + every update)');
    // Use case: logging, analytics
  }); // No dependency array

  // ─── PATTERN 2: Run ONCE on mount (empty dependency array) ───
  useEffect(() => {
    console.log('Runs ONLY ONCE when component mounts');
    // Use case: initial data fetching, one-time setup
    // Equivalent to: componentDidMount
  }, []); // Empty array = run once

  // ─── PATTERN 3: Run when specific values change ───
  useEffect(() => {
    console.log(`Count changed to: ${count}`);
    document.title = `Count: ${count}`;
    // Runs on mount AND whenever 'count' changes
    // Equivalent to: componentDidMount + componentDidUpdate (for count)
  }, [count]); // Only re-run when 'count' changes

  // ─── PATTERN 4: Cleanup function (returned function) ───
  useEffect(() => {
    // Setup: subscribe to window resize
    const handleResize = () => setWindowWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);

    // Cleanup: RETURNED function runs before next effect or when component unmounts
    // Equivalent to: componentWillUnmount
    return () => {
      console.log('Cleanup: removing event listener');
      window.removeEventListener('resize', handleResize);
    };
  }, []); // Empty array = setup once, cleanup on unmount

  // ─── PATTERN 5: Timer with cleanup ───
  useEffect(() => {
    const intervalId = setInterval(() => {
      console.log('Tick');
    }, 1000);

    // Cleanup: clear the interval when component unmounts
    return () => clearInterval(intervalId);
  }, []);

  // ─── PATTERN 6: Multiple dependencies ───
  useEffect(() => {
    console.log(`Name: ${name}, Count: ${count}`);
    // Runs when EITHER name OR count changes
  }, [name, count]);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount((c) => c + 1)}>Increment</button>

      <p>Name: {name}</p>
      <input value={name} onChange={(e) => setName(e.target.value)} />

      <p>Window Width: {windowWidth}px</p>
    </div>
  );
}

export default UseEffectExamples;
```

### useEffect Dependency Array Summary:
| Dependency Array | When Effect Runs |
|-----------------|-----------------|
| None (`useEffect(fn)`) | After **every** render |
| Empty (`useEffect(fn, [])`) | Only **once** on mount |
| With values (`useEffect(fn, [a, b])`) | On mount + when `a` or `b` change |

---

## 29. Data Fetching in React

```jsx
import React, { useState, useEffect } from 'react';

// ─── Basic Data Fetching ───
function UserList() {
  const [users, setUsers] = useState([]);       // Data state
  const [loading, setLoading] = useState(true);  // Loading state
  const [error, setError] = useState(null);      // Error state

  useEffect(() => {
    // Define an async function inside useEffect
    // (useEffect callback itself cannot be async)
    const fetchUsers = async () => {
      try {
        setLoading(true);  // Start loading
        setError(null);    // Clear previous errors

        // Fetch data from API
        const response = await fetch('https://jsonplaceholder.typicode.com/users');

        // Check if the response is OK (status 200-299)
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }

        // Parse JSON response
        const data = await response.json();

        // Update state with fetched data
        setUsers(data);
      } catch (err) {
        // Handle errors (network issues, parsing errors, etc.)
        setError(err.message);
      } finally {
        // Always stop loading, whether success or error
        setLoading(false);
      }
    };

    fetchUsers(); // Call the async function
  }, []); // Empty array = fetch once on mount

  // ─── Managing Loading State ───
  if (loading) {
    return (
      <div className="loading">
        <p>Loading users...</p>
        {/* You can add a spinner component here */}
      </div>
    );
  }

  // ─── Managing Error State ───
  if (error) {
    return (
      <div className="error">
        <p>Error: {error}</p>
        <button onClick={() => window.location.reload()}>Retry</button>
      </div>
    );
  }

  // ─── Render Data ───
  return (
    <div>
      <h2>Users ({users.length})</h2>
      <ul>
        {users.map((user) => (
          <li key={user.id}>
            <strong>{user.name}</strong> — {user.email}
          </li>
        ))}
      </ul>
    </div>
  );
}

// ─── Data Fetching with Search/Filter (dependency in useEffect) ───
function SearchableUsers() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Don't fetch if query is empty
    if (!query.trim()) {
      setResults([]);
      return;
    }

    const fetchResults = async () => {
      setLoading(true);
      try {
        const response = await fetch(
          `https://jsonplaceholder.typicode.com/users?name_like=${query}`
        );
        const data = await response.json();
        setResults(data);
      } catch (err) {
        console.error('Search failed:', err);
      } finally {
        setLoading(false);
      }
    };

    // Debounce: wait 500ms after user stops typing before fetching
    const timerId = setTimeout(fetchResults, 500);

    // Cleanup: cancel the timeout if query changes before 500ms
    return () => clearTimeout(timerId);
  }, [query]); // Re-run when query changes

  return (
    <div>
      <input
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search users..."
      />
      {loading && <p>Searching...</p>}
      <ul>
        {results.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
}

export default UserList;
```

---

## 30. Prop Drilling and Context API

**Prop drilling** is the process of passing data from a parent component through multiple intermediate components that don't need the data, just to reach a deeply nested child component.

```jsx
// ─── THE PROBLEM: PROP DRILLING ───
// The 'user' prop has to pass through EVERY component, even though
// only the deeply nested component actually uses it

function App() {
  const user = { name: 'John', role: 'Admin' };
  // Level 0 → passes user to Level 1
  return <Dashboard user={user} />;
}

function Dashboard({ user }) {
  // Level 1 → doesn't use 'user', but must pass it to Level 2
  return <Sidebar user={user} />;
}

function Sidebar({ user }) {
  // Level 2 → doesn't use 'user', but must pass it to Level 3
  return <UserMenu user={user} />;
}

function UserMenu({ user }) {
  // Level 3 → FINALLY uses 'user'
  return <p>Welcome, {user.name}!</p>;
}

// Problems with Prop Drilling:
// 1. Intermediate components carry props they don't need
// 2. Adding a new prop requires modifying EVERY component in the chain
// 3. Hard to maintain and refactor
// 4. Makes components tightly coupled

// SOLUTION: Use Context API (explained in next sections)
```

---

## 31. Context API in React

The **Context API** provides a way to pass data through the component tree **without passing props manually** at every level. It creates a "global" state accessible to any component in the tree.

### Three Steps:
1. **Create** a Context (`React.createContext`)
2. **Provide** the Context value (wrap components with `Provider`)
3. **Consume** the Context value (`useContext` hook)

```jsx
import React, { createContext, useState, useContext } from 'react';

// STEP 1: Create a Context with a default value
// The default value is used when a component doesn't have a matching Provider above it
const ThemeContext = createContext('light');

// STEP 2: Create a Provider component
// The Provider wraps components that need access to the context
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  // The 'value' prop is what gets shared with all consumers
  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

// STEP 3: Consume context in any child component (no prop drilling!)
function Header() {
  // useContext reads the value from the nearest Provider above
  const { theme, toggleTheme } = useContext(ThemeContext);

  return (
    <header style={{ background: theme === 'dark' ? '#333' : '#fff' }}>
      <h1>Theme: {theme}</h1>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </header>
  );
}

function Content() {
  const { theme } = useContext(ThemeContext);
  return (
    <main style={{ color: theme === 'dark' ? '#fff' : '#000' }}>
      <p>This content follows the theme!</p>
    </main>
  );
}

// App — wrap the tree with the Provider
function App() {
  return (
    <ThemeProvider>
      {/* ALL components inside ThemeProvider can access theme context */}
      {/* No props need to be passed through intermediate components */}
      <Header />
      <Content />
    </ThemeProvider>
  );
}

export default App;
```

---

## 32. useContext Hook

`useContext` is a hook that lets you **consume** a context value directly in a functional component, without needing to use `Context.Consumer`.

```jsx
import React, { createContext, useState, useContext } from 'react';

// Create context
const UserContext = createContext(null);

function UserProvider({ children }) {
  const [user, setUser] = useState({ name: 'John', role: 'Admin' });

  const login = (name) => setUser({ name, role: 'User' });
  const logout = () => setUser(null);

  return (
    <UserContext.Provider value={{ user, login, logout }}>
      {children}
    </UserContext.Provider>
  );
}

// ─── Consuming context with useContext ───
function Navbar() {
  // useContext(UserContext) returns whatever was passed as 'value' in the Provider
  const { user, logout } = useContext(UserContext);

  return (
    <nav>
      {user ? (
        <>
          <span>Welcome, {user.name} ({user.role})</span>
          <button onClick={logout}>Logout</button>
        </>
      ) : (
        <span>Please log in</span>
      )}
    </nav>
  );
}

function Profile() {
  const { user } = useContext(UserContext);

  if (!user) return <p>Not logged in</p>;

  return (
    <div>
      <h2>Profile</h2>
      <p>Name: {user.name}</p>
      <p>Role: {user.role}</p>
    </div>
  );
}

function App() {
  return (
    <UserProvider>
      <Navbar />
      <Profile />
    </UserProvider>
  );
}

export default App;
```

---

## 33. Updating Context Values

To update context values, include an **updater function** in the context value and call it from any consumer.

```jsx
import React, { createContext, useState, useContext } from 'react';

// Context with both state AND updater functions
const CartContext = createContext();

function CartProvider({ children }) {
  const [cartItems, setCartItems] = useState([]);

  // Updater functions that modify the context state
  const addItem = (item) => {
    setCartItems((prev) => [...prev, { ...item, id: Date.now() }]);
  };

  const removeItem = (id) => {
    setCartItems((prev) => prev.filter((item) => item.id !== id));
  };

  const clearCart = () => {
    setCartItems([]);
  };

  const totalItems = cartItems.length;

  // Expose state AND updater functions via the Provider value
  return (
    <CartContext.Provider value={{ cartItems, addItem, removeItem, clearCart, totalItems }}>
      {children}
    </CartContext.Provider>
  );
}

// Any component can READ and UPDATE the context
function ProductList() {
  const { addItem } = useContext(CartContext); // Access updater function

  const products = [
    { name: 'Laptop', price: 999 },
    { name: 'Phone', price: 699 },
    { name: 'Tablet', price: 499 },
  ];

  return (
    <div>
      <h2>Products</h2>
      {products.map((product) => (
        <div key={product.name}>
          <span>{product.name} — ${product.price}</span>
          {/* Calling the updater function updates the context for ALL consumers */}
          <button onClick={() => addItem(product)}>Add to Cart</button>
        </div>
      ))}
    </div>
  );
}

function CartSummary() {
  const { cartItems, removeItem, clearCart, totalItems } = useContext(CartContext);

  return (
    <div>
      <h2>Cart ({totalItems} items)</h2>
      {cartItems.map((item) => (
        <div key={item.id}>
          <span>{item.name} — ${item.price}</span>
          <button onClick={() => removeItem(item.id)}>Remove</button>
        </div>
      ))}
      {totalItems > 0 && <button onClick={clearCart}>Clear Cart</button>}
    </div>
  );
}

function App() {
  return (
    <CartProvider>
      <ProductList />
      <CartSummary />
    </CartProvider>
  );
}

export default App;
```

---

## 34. Multiple Contexts

You can use **multiple contexts** in a single component by nesting providers and calling `useContext` for each.

```jsx
import React, { createContext, useState, useContext } from 'react';

// ─── Create multiple contexts ───
const ThemeContext = createContext();
const LanguageContext = createContext();
const AuthContext = createContext();

// ─── Individual Providers ───
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');
  const toggleTheme = () => setTheme((prev) => (prev === 'light' ? 'dark' : 'light'));
  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

function LanguageProvider({ children }) {
  const [language, setLanguage] = useState('en');
  return (
    <LanguageContext.Provider value={{ language, setLanguage }}>
      {children}
    </LanguageContext.Provider>
  );
}

function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const login = (name) => setUser({ name });
  const logout = () => setUser(null);
  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// ─── Component consuming MULTIPLE contexts ───
function Dashboard() {
  // Consume all three contexts in a single component
  const { theme, toggleTheme } = useContext(ThemeContext);
  const { language, setLanguage } = useContext(LanguageContext);
  const { user, login, logout } = useContext(AuthContext);

  return (
    <div style={{ background: theme === 'dark' ? '#333' : '#fff', color: theme === 'dark' ? '#fff' : '#000', padding: '20px' }}>
      <h1>Dashboard</h1>
      <p>Theme: {theme} <button onClick={toggleTheme}>Toggle</button></p>
      <p>Language: {language}
        <button onClick={() => setLanguage('en')}>EN</button>
        <button onClick={() => setLanguage('es')}>ES</button>
      </p>
      <p>User: {user ? user.name : 'Not logged in'}
        {user
          ? <button onClick={logout}>Logout</button>
          : <button onClick={() => login('John')}>Login</button>
        }
      </p>
    </div>
  );
}

// ─── Nest Providers in App ───
function App() {
  return (
    // Providers are nested — order doesn't matter for functionality
    <ThemeProvider>
      <LanguageProvider>
        <AuthProvider>
          <Dashboard />
        </AuthProvider>
      </LanguageProvider>
    </ThemeProvider>
  );
}

export default App;
```

---

## 35. Context API vs Prop Drilling

| Feature | Prop Drilling | Context API |
|---------|--------------|-------------|
| **Data Flow** | Through every intermediate component | Directly to any nested consumer |
| **Intermediate Components** | Must receive and pass props they don't use | Not involved at all |
| **Scalability** | Poor — hard to manage as app grows | Good — centralized data sharing |
| **Maintenance** | Adding new data requires changing every component in chain | Change only Provider and Consumer |
| **Coupling** | High — components depend on prop chain | Low — consumers connect directly to context |
| **Performance** | No extra overhead | All consumers re-render when context changes |
| **Use When** | Small apps, 1-2 levels deep | Medium/large apps, deeply nested data |
| **Debugging** | Easy to trace prop flow | Can be harder to trace data source |

---

## 36. useReducer Hook

`useReducer` is an alternative to `useState` for managing **complex state logic**. It is similar to how **Redux** works — you dispatch **actions** to a **reducer** function that returns the new state.

### When to use `useReducer` over `useState`:
- State logic is **complex** (multiple sub-values, many transitions)
- Next state depends on the **previous state**
- Multiple actions can update the state in different ways

```jsx
import React, { useReducer } from 'react';

// STEP 1: Define the initial state
const initialState = { count: 0 };

// STEP 2: Define the reducer function
// A reducer takes (currentState, action) and returns NEW state
// It MUST be a pure function (no side effects, no mutations)
function reducer(state, action) {
  // action.type determines WHAT to do
  switch (action.type) {
    case 'INCREMENT':
      return { count: state.count + 1 };
    case 'DECREMENT':
      return { count: state.count - 1 };
    case 'RESET':
      return initialState;
    case 'SET':
      // action.payload carries additional data
      return { count: action.payload };
    default:
      // Throw error for unknown action types (helps catch bugs)
      throw new Error(`Unknown action type: ${action.type}`);
  }
}

// STEP 3: Use useReducer in the component
function Counter() {
  // useReducer returns [currentState, dispatchFunction]
  // Arguments: (reducerFunction, initialState)
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <div>
      <h2>Count: {state.count}</h2>

      {/* dispatch sends an ACTION to the reducer */}
      {/* An action is an object with a 'type' property */}
      <button onClick={() => dispatch({ type: 'INCREMENT' })}>+1</button>
      <button onClick={() => dispatch({ type: 'DECREMENT' })}>-1</button>
      <button onClick={() => dispatch({ type: 'RESET' })}>Reset</button>

      {/* Actions can include a 'payload' for additional data */}
      <button onClick={() => dispatch({ type: 'SET', payload: 100 })}>Set to 100</button>
    </div>
  );
}

export default Counter;
```

### Flow:
```
User clicks button → dispatch({ type: 'INCREMENT' }) → reducer(state, action) → returns new state → component re-renders
```

---

## 37. useReducer with Complex State

```jsx
import React, { useReducer } from 'react';

// Complex state with multiple properties
const initialState = {
  users: [],
  loading: false,
  error: null,
  filter: 'all', // 'all', 'active', 'inactive'
  searchTerm: '',
};

// Reducer handling multiple actions for complex state
function userReducer(state, action) {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null };

    case 'FETCH_SUCCESS':
      return { ...state, loading: false, users: action.payload };

    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload };

    case 'ADD_USER':
      return { ...state, users: [...state.users, action.payload] };

    case 'REMOVE_USER':
      return {
        ...state,
        users: state.users.filter((user) => user.id !== action.payload),
      };

    case 'TOGGLE_STATUS':
      return {
        ...state,
        users: state.users.map((user) =>
          user.id === action.payload
            ? { ...user, isActive: !user.isActive }
            : user
        ),
      };

    case 'SET_FILTER':
      return { ...state, filter: action.payload };

    case 'SET_SEARCH':
      return { ...state, searchTerm: action.payload };

    default:
      throw new Error(`Unknown action: ${action.type}`);
  }
}

function UserManagement() {
  const [state, dispatch] = useReducer(userReducer, initialState);

  const addUser = () => {
    dispatch({
      type: 'ADD_USER',
      payload: {
        id: Date.now(),
        name: `User ${state.users.length + 1}`,
        isActive: true,
      },
    });
  };

  // Filter users based on current state
  const filteredUsers = state.users
    .filter((user) => {
      if (state.filter === 'active') return user.isActive;
      if (state.filter === 'inactive') return !user.isActive;
      return true;
    })
    .filter((user) =>
      user.name.toLowerCase().includes(state.searchTerm.toLowerCase())
    );

  return (
    <div>
      <h2>User Management</h2>

      <input
        placeholder="Search users..."
        value={state.searchTerm}
        onChange={(e) => dispatch({ type: 'SET_SEARCH', payload: e.target.value })}
      />

      <select
        value={state.filter}
        onChange={(e) => dispatch({ type: 'SET_FILTER', payload: e.target.value })}
      >
        <option value="all">All</option>
        <option value="active">Active</option>
        <option value="inactive">Inactive</option>
      </select>

      <button onClick={addUser}>Add User</button>

      {state.loading && <p>Loading...</p>}
      {state.error && <p>Error: {state.error}</p>}

      <ul>
        {filteredUsers.map((user) => (
          <li key={user.id}>
            {user.name} — {user.isActive ? 'Active' : 'Inactive'}
            <button onClick={() => dispatch({ type: 'TOGGLE_STATUS', payload: user.id })}>
              Toggle
            </button>
            <button onClick={() => dispatch({ type: 'REMOVE_USER', payload: user.id })}>
              Remove
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default UserManagement;
```

---

## 38. Passing Additional Arguments to Reducer

The reducer only receives `(state, action)`. To pass extra data, include it in the **action's payload**.

```jsx
import React, { useReducer } from 'react';

const initialState = { items: [], total: 0 };

function cartReducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM':
      // action.payload contains the extra data: { name, price, quantity }
      return {
        items: [...state.items, action.payload],
        total: state.total + action.payload.price * action.payload.quantity,
      };

    case 'UPDATE_QUANTITY':
      // action.payload has: { id, newQuantity }
      const updatedItems = state.items.map((item) =>
        item.id === action.payload.id
          ? { ...item, quantity: action.payload.newQuantity }
          : item
      );
      const newTotal = updatedItems.reduce(
        (sum, item) => sum + item.price * item.quantity,
        0
      );
      return { items: updatedItems, total: newTotal };

    case 'APPLY_DISCOUNT':
      // action.payload is the discount percentage
      return {
        ...state,
        total: state.total * (1 - action.payload / 100),
      };

    default:
      return state;
  }
}

function ShoppingCart() {
  const [state, dispatch] = useReducer(cartReducer, initialState);

  // Pass additional arguments via action.payload
  const handleAddItem = (name, price) => {
    dispatch({
      type: 'ADD_ITEM',
      payload: { id: Date.now(), name, price, quantity: 1 },
      // 'payload' carries all the extra data the reducer needs
    });
  };

  return (
    <div>
      <h2>Shopping Cart</h2>
      <button onClick={() => handleAddItem('Laptop', 999)}>Add Laptop</button>
      <button onClick={() => handleAddItem('Phone', 699)}>Add Phone</button>
      <button onClick={() => dispatch({ type: 'APPLY_DISCOUNT', payload: 10 })}>
        Apply 10% Discount
      </button>
      <ul>
        {state.items.map((item) => (
          <li key={item.id}>{item.name} — ${item.price} x {item.quantity}</li>
        ))}
      </ul>
      <p><strong>Total: ${state.total.toFixed(2)}</strong></p>
    </div>
  );
}

export default ShoppingCart;
```

---

## 39. Side Effects with useReducer

`useReducer` itself is for **pure state transitions**. Side effects (API calls, logging) should be handled **outside** the reducer, typically in `useEffect`.

```jsx
import React, { useReducer, useEffect } from 'react';

const initialState = {
  posts: [],
  loading: false,
  error: null,
};

// Reducer is PURE — no side effects (no fetch, no console.log, no timers)
function postsReducer(state, action) {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null };
    case 'FETCH_SUCCESS':
      return { ...state, loading: false, posts: action.payload };
    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload };
    case 'DELETE_POST':
      return {
        ...state,
        posts: state.posts.filter((post) => post.id !== action.payload),
      };
    default:
      return state;
  }
}

function PostsList() {
  const [state, dispatch] = useReducer(postsReducer, initialState);

  // Side effects go in useEffect, NOT in the reducer
  useEffect(() => {
    const fetchPosts = async () => {
      dispatch({ type: 'FETCH_START' }); // Update state: loading = true

      try {
        const response = await fetch('https://jsonplaceholder.typicode.com/posts?_limit=5');
        const data = await response.json();
        dispatch({ type: 'FETCH_SUCCESS', payload: data }); // Update state with data
      } catch (err) {
        dispatch({ type: 'FETCH_ERROR', payload: err.message }); // Update state with error
      }
    };

    fetchPosts();
  }, []);

  // Side effect for delete (also in handler, not in reducer)
  const handleDelete = async (id) => {
    try {
      await fetch(`https://jsonplaceholder.typicode.com/posts/${id}`, {
        method: 'DELETE',
      });
      dispatch({ type: 'DELETE_POST', payload: id }); // Update state after API call
    } catch (err) {
      console.error('Delete failed:', err);
    }
  };

  if (state.loading) return <p>Loading...</p>;
  if (state.error) return <p>Error: {state.error}</p>;

  return (
    <div>
      <h2>Posts</h2>
      {state.posts.map((post) => (
        <div key={post.id}>
          <h3>{post.title}</h3>
          <button onClick={() => handleDelete(post.id)}>Delete</button>
        </div>
      ))}
    </div>
  );
}

export default PostsList;
```
