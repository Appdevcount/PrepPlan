# ReactJS - Complete Knowledge Repository

## Overview
This comprehensive guide covers React from fundamentals to advanced patterns, with real-world scenarios and interview questions. Designed for Senior/SDE-2/Full-Stack Engineer interviews at top companies like Meta, Google, Netflix, and Airbnb.

---

## Table of Contents
1. [React Fundamentals](#1-react-fundamentals)
2. [JSX Deep Dive](#2-jsx-deep-dive)
3. [Components & Props](#3-components--props)
4. [State Management](#4-state-management)
5. [Hooks In-Depth](#5-hooks-in-depth)
6. [Component Lifecycle](#6-component-lifecycle)
7. [Event Handling](#7-event-handling)
8. [Forms & Controlled Components](#8-forms--controlled-components)
9. [Context API](#9-context-api)
10. [React Router](#10-react-router)
11. [Performance Optimization](#11-performance-optimization)
12. [Error Handling](#12-error-handling)
13. [Testing React Applications](#13-testing-react-applications)
14. [Advanced Patterns](#14-advanced-patterns)
15. [State Management Libraries](#15-state-management-libraries)
16. [Server-Side Rendering](#16-server-side-rendering)
17. [Real-World Scenarios](#17-real-world-scenarios)
18. [Interview Questions & Answers](#18-interview-questions--answers)

---

## Quick Start & Prerequisites

### Before You Begin

This guide assumes you have:
- ✅ **JavaScript ES6+ Knowledge**: Arrow functions, destructuring, spread operator, async/await, template literals
- ✅ **Understanding of DOM**: HTML structure, events, event listeners, DOM manipulation basics
- ✅ **Node.js & NPM**: Installed and familiar with running commands
- ✅ **TypeScript Basics** (optional but recommended): Interfaces, types, generics

### How to Get Started (5 Minutes)

**Step 1: Install Node.js**
```bash
# Download from https://nodejs.org/ (LTS version recommended)
node --version  # Verify installation
npm --version   # Verify npm
```

**Step 2: Create your first React app**
```bash
# Method 1: Using Create React App (easy, good for learning)
npx create-react-app my-app
cd my-app
npm start

# Method 2: Using Vite (faster, modern)
npm create vite@latest my-app -- --template react
cd my-app
npm install
npm run dev
```

**Step 3: Understand the folder structure**
```
my-app/
├── public/           # Static files
├── src/
│   ├── App.jsx      # Root component
│   ├── main.jsx     # Entry point
│   └── index.css    # Global styles
├── package.json     # Dependencies
└── vite.config.js   # Build config (Vite)
```

**Step 4: Write your first component (src/App.jsx)**
```jsx
// This is a React component - a reusable piece of UI
export default function App() {
  return (
    <div>
      <h1>Hello, React!</h1>
      <p>Welcome to React learning journey</p>
    </div>
  );
}
```

### How to Use This Guide Effectively

**🎯 For Learning (First Time):**
1. Read sections 1-6 (Fundamentals through Lifecycle)
2. Code along with examples after each section
3. Understand concepts, don't memorize code
4. Practice building small components

**🎯 For Interviews (Preparation):**
1. Focus on sections 5-14 (Hooks through Advanced Patterns)
2. Study the "Common Pitfalls & Best Practices" section
3. Review the Interview Checklist
4. Practice explaining concepts out loud
5. Build projects to solidify knowledge

**🎯 For Reference (During Work):**
- Use the "React Quick Reference" section
- Search for pattern you need
- Copy code and adapt to your use case

**⏱️ Time Estimates:**
- Learning all fundamentals: 4-6 weeks (2-3 hours/day)
- Deep dive into advanced patterns: 2-3 weeks
- Interview prep: 1-2 weeks intensive review
- Becoming proficient: 3-6 months of active projects

---

## 1. React Fundamentals

### What is React?

**React** is a JavaScript library for building user interfaces, developed by Meta (Facebook). It uses a component-based architecture and a virtual DOM for efficient rendering.

```
┌─────────────────────────────────────────────────────────────┐
│                    React Architecture                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │  Component  │     │  Component  │     │  Component  │  │
│   │    Tree     │────▶│   State     │────▶│   Render    │  │
│   └─────────────┘     └─────────────┘     └──────┬──────┘  │
│                                                   │         │
│                                                   ▼         │
│   ┌─────────────────────────────────────────────────────┐  │
│   │              Virtual DOM (React Element Tree)        │  │
│   └─────────────────────────────────────────────────────┘  │
│                           │                                 │
│                           │ Reconciliation                  │
│                           │ (Diffing Algorithm)             │
│                           ▼                                 │
│   ┌─────────────────────────────────────────────────────┐  │
│   │                   Real DOM                           │  │
│   │              (Browser Document)                      │  │
│   └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Virtual DOM Explained

> **What is the Virtual DOM?**
>
> The Virtual DOM is a lightweight JavaScript representation of the actual DOM. React maintains this virtual representation and uses it to determine the minimum number of operations needed to update the real DOM.

```javascript
// Real DOM element
<div id="app">
  <h1>Hello</h1>
  <p>World</p>
</div>

// Virtual DOM representation (React Element)
{
  type: 'div',
  props: {
    id: 'app',
    children: [
      { type: 'h1', props: { children: 'Hello' } },
      { type: 'p', props: { children: 'World' } }
    ]
  }
}
```

**Reconciliation Process:**
1. State changes trigger re-render
2. React creates new Virtual DOM tree
3. React diffs new tree with previous tree
4. React calculates minimal DOM operations
5. React batches and applies updates to real DOM

### React vs Other Frameworks

| Feature | React | Angular | Vue |
|---------|-------|---------|-----|
| **Type** | Library | Framework | Framework |
| **DOM** | Virtual DOM | Incremental DOM | Virtual DOM |
| **Data Binding** | One-way | Two-way | Two-way |
| **Language** | JSX (JavaScript) | TypeScript | Templates |
| **Size** | ~45KB | ~500KB | ~80KB |
| **Learning Curve** | Moderate | Steep | Easy |
| **Flexibility** | High (choose your stack) | Low (opinionated) | Medium |

---

## 2. JSX Deep Dive

### What is JSX?

**JSX (JavaScript XML)** is a syntax extension that allows writing HTML-like code in JavaScript. It's not required for React but makes code more readable.

```jsx
// JSX
const element = <h1 className="title">Hello, World!</h1>;

// Compiles to (React.createElement)
const element = React.createElement(
  'h1',
  { className: 'title' },
  'Hello, World!'
);

// React 17+ (new JSX transform - no React import needed)
import { jsx as _jsx } from 'react/jsx-runtime';
const element = _jsx('h1', { className: 'title', children: 'Hello, World!' });
```

### JSX Rules and Syntax

#### How to Write JSX Like a Pro

**Rule 1: Single Root Element (or Fragment)**
```jsx
// ❌ DON'T: Multiple root elements (will error)
return (
  <h1>Title</h1>
  <p>Content</p>  // React doesn't know how to group these
);

// ✅ DO: Use a wrapper div
return (
  <div>
    <h1>Title</h1>
    <p>Content</p>
  </div>
);

// ✅ BETTER: Use Fragment (no extra DOM node created)
// Fragment "" is just </> - invisible wrapper
return (
  <>
    <h1>Title</h1>
    <p>Content</p>
  </>
);

// Use named Fragment when you need the key prop
return (
  <React.Fragment key={item.id}>
    <dt>{item.term}</dt>
    <dd>{item.definition}</dd>
  </React.Fragment>
);
```

**Rule 2: JavaScript Expressions in Curly Braces**
```jsx
const name = 'John';
const age = 25;
const isAdmin = true;

// ✅ DO: Use curly braces for JS expressions
<h1>Hello, {name}!</h1>
<p>Age: {age}</p>
<p>Sum: {10 + 20}</p>
<p>Result: {isAdmin ? 'Admin' : 'User'}</p>

// ✅ Even method calls work
<p>Uppercase: {name.toUpperCase()}</p>
<p>Length: {name.length}</p>

// ❌ DON'T: Statements don't work in JSX
<p>{if (age > 18) 'Adult'}</p>  // ERROR: if is a statement, not expression
<p>{for (let i = 0; i < 5; i++)}</p>  // ERROR: for is a statement

// ✅ DO: Move statements outside or use ternary
const message = age > 18 ? 'Adult' : 'Minor';
<p>{message}</p>
```

**Rule 3: camelCase for Attributes (differ from HTML)**
```jsx
// Common HTML → JSX conversions:
// HTML              →  React/JSX
// class             →  className
// for (labels)      →  htmlFor
// tabindex          →  tabIndex
// onclick           →  onClick
// onchange          →  onChange
// data-testid       →  data-testid (stays the same)
// aria-label        →  aria-label (stays the same)

// ✅ DO: Use camelCase
<button onClick={handleClick} className="btn" tabIndex={0}>
  Click me
</button>

<label htmlFor="email">Email:</label>
<input id="email" type="text" onChange={handleChange} />

// ❌ DON'T: Use HTML attribute names
<button onclick={handleClick}>Click</button>  // Wrong!
<div class="container">Content</div>  // Wrong!
```

**Rule 4: Style is an Object (not a string)**
```jsx
// ✅ DO: Style object with camelCase properties
const divStyle = {
  backgroundColor: 'blue',    // not background-color
  fontSize: '16px',           // not font-size
  padding: '20px',            // not padding
  marginTop: '10px',          // not margin-top
  borderRadius: '8px'         // not border-radius
};
<div style={divStyle}>Styled div</div>

// ✅ DO: Inline style for simple cases
<div style={{ color: 'red', marginTop: '10px' }}>
  Inline styled
</div>

// ❌ DON'T: Style string (works in HTML, NOT in React)
<div style="color: red; margin-top: 10px;">
  This won't work as expected
</div>
```

**Rule 5: Self-closing Tags Must Have /**
```jsx
// ✅ DO: Self-closing tag with /
<input type="text" />
<img src="image.jpg" alt="description" />
<br />
<hr />

// ❌ DON'T: HTML-style self-closing
<input type="text">    // Works in HTML, not valid in JSX
<img src="image.jpg">  // Works in HTML, not valid in JSX
```

**Rule 6: Comments in JSX**
```jsx
// ✅ DO: Comments outside JSX
export function Component() {
  // This is a normal JS comment
  
  return (
    <div>
      {/* This is JSX comment - must be in curly braces */}
      <h1>Hello</h1>
      {
        // Another way to comment
        // inside JSX
      }
    </div>
  );
}

// ❌ DON'T: Regular comment inside JSX
return (
  <div>
    // This breaks JSX parsing!
    <h1>Hello</h1>
  </div>
);
```

**Rule 7: Boolean Attributes & Falsy Values**
```jsx
// ✅ DO: Boolean attributes (true/false)
<input disabled />               // Same as disabled={true}
<input disabled={false} />       // Not disabled
<button hidden>Can't see me</button>

// Important: 0, false, null, undefined render nothing
{false}        // Renders nothing ✅
{null}         // Renders nothing ✅
{undefined}    // Renders nothing ✅
{0}            // Renders "0" (gotcha - not nothing!)

// ✅ DO: Be careful with 0
{count === 0 ? 'Zero' : count}  // If count is 0, shows "Zero"
{count || 'No items'}            // If count is 0, shows "No items"
{count > 0 && <p>{count} items</p>}  // Shows nothing if count is 0
```

**Rule 8: Spread Attributes**
```jsx
// ✅ DO: Spread props for cleaner code
const props = { 
  id: 'main', 
  className: 'container', 
  onClick: handleClick 
};
<div {...props}>Content</div>

// Equivalent to:
<div id="main" className="container" onClick={handleClick}>
  Content
</div>

// ✅ DO: Combine spread with explicit props
<input {...inputProps} placeholder="Override placeholder" />
// inputProps spreads first, then placeholder overrides it
```



### Rendering Lists: Complete Guide

#### Understanding the KEY Prop

```jsx
// The KEY prop is CRITICAL for React list rendering
// Without it, React can't tell which items changed

// Data structure
const fruits = [
  { id: 1, name: 'Apple', quantity: 5 },
  { id: 2, name: 'Banana', quantity: 3 },
  { id: 3, name: 'Cherry', quantity: 8 }
];

// ❌ PROBLEMATIC: Using index as key
// Problems occur when:
// 1. Items are filtered/reordered - indexes change
// 2. Items have internal state - state gets mixed up
// 3. List is modified (insert/delete) - wrong items update
function FruitList() {
  return (
    <ul>
      {fruits.map((fruit, index) => (
        <li key={index}>{fruit.name}</li>  // ← index-based key is BAD
      ))}
    </ul>
  );
}
// Example: If you filter out the first item, index 0 now points to second item
// React thinks second item is the first one!

// ✅ RECOMMENDED: Using unique, stable ID
function FruitList() {
  return (
    <ul>
      {fruits.map(fruit => (
        <li key={fruit.id}>{fruit.name} - Qty: {fruit.quantity}</li>
      ))}
    </ul>
  );
}
// fruit.id is unique and stable - never changes - perfect for key!

// ❌ NEVER: Using random values
const FruitList = () => {
  return (
    <ul>
      {fruits.map(fruit => (
        // Math.random() creates NEW key every render!
        // List completely re-renders every time - super slow!
        <li key={Math.random()}>{fruit.name}</li>
      ))}
    </ul>
  );
};

// ❌ NEVER: Using Object.key() with unstable IDs
const FruitList = () => {
  return (
    <ul>
      {fruits.map((fruit, i) => (
        // Generates different ID every render - same problem as Math.random()
        <li key={`fruit-${i}-${fruit.name}`}>{fruit.name}</li>
      ))}
    </ul>
  );
};
```

#### Key Rules Summary

```jsx
// 1. Keys must be UNIQUE among siblings
// ✅ GOOD
const lists = [
  { id: 1, items: ['apple', 'banana'] },
  { id: 2, items: ['carrot', 'potato'] }
];

lists.map(list => (
  <div key={list.id}>
    {list.items.map(item => (
      <div key={item}>{item}</div>  // item is unique within this list
    ))}
  </div>
));

// 2. Keys must be STABLE (not change between renders)
// ✅ GOOD - uses unchanging data
{users.map(user => <User key={user.userId} user={user} />)}

// ❌ BAD - changes every render
{users.map((user, i) => <User key={Date.now()} user={user} />)}

// 3. Keys don't need to be globally unique, just unique per parent
// ✅ GOOD
<div>
  <div key="header">Header</div>        // key "header"
  <div key="content">Content</div>      // key "content"
</div>
<div>
  <div key="header">Different</div>     // key "header" again (OK, different parent)
</div>

// 4. When NO unique ID exists, create one
// ✅ GOOD - generate stable ID from data
const generateKey = (item, index) => `${item.type}-${item.name}`;
{items.map((item, i) => (
  <Item key={generateKey(item, i)} item={item} />
))}
```

#### How to Handle Dynamic Lists

```jsx
import { useState } from 'react';

export function DynamicList() {
  const [items, setItems] = useState([
    { id: 1, text: 'Learn React' },
    { id: 2, text: 'Build projects' },
    { id: 3, text: 'Master hooks' }
  ]);
  const [nextId, setNextId] = useState(4);

  // ADD item
  const handleAdd = (text) => {
    setItems([
      ...items,
      { id: nextId, text }  // ← Each item gets unique ID
    ]);
    setNextId(nextId + 1);
  };

  // EDIT item
  const handleEdit = (id, newText) => {
    setItems(items.map(item =>
      item.id === id ? { ...item, text: newText } : item
    ));
  };

  // DELETE item
  const handleDelete = (id) => {
    setItems(items.filter(item => item.id !== id));
  };

  // REORDER items
  const handleMove = (from, to) => {
    const newItems = [...items];
    [newItems[from], newItems[to]] = [newItems[to], newItems[from]];
    setItems(newItems);
  };

  return (
    <div>
      <ul>
        {items.map((item, i) => (
          <li key={item.id}>
            {item.text}
            <button onClick={() => handleEdit(item.id, 'Updated')}>Edit</button>
            <button onClick={() => handleDelete(item.id)}>Delete</button>
            {i > 0 && <button onClick={() => handleMove(i, i - 1)}>▲</button>}
            {i < items.length - 1 && <button onClick={() => handleMove(i, i + 1)}>▼</button>}
          </li>
        ))}
      </ul>
      <button onClick={() => handleAdd('New item')}>Add</button>
    </div>
  );
}
```



---

## 3. Components & Props

### Understanding Components: How to Structure Your App

A component is a reusable piece of UI that returns JSX.

```jsx
// ===== PATTERN 1: Basic Functional Component
// Simplest form - takes props, returns JSX
function Welcome(props) {
  return <h1>Hello, {props.name}!</h1>;
}

// Usage:
<Welcome name="John" />  // ← Props passed like HTML attributes

// ===== PATTERN 2: Arrow Function Component
// Modern, concise syntax
const Welcome = (props) => {
  return <h1>Hello, {props.name}!</h1>;
};

// ===== PATTERN 3: Destructured Props (RECOMMENDED)
// Extract props immediately - cleaner code
const Welcome = ({ name, age }) => {
  return <h1>Hello, {name}! You are {age} years old.</h1>;
};

// ===== PATTERN 4: Default Props
// Provide fallback values if props not passed
const Welcome = ({ name = 'Guest', age = 0 }) => {
  return <h1>Hello, {name}!</h1>;
};

// Usage:
<Welcome />                 // Uses defaults: "Guest", 0
<Welcome name="John" />     // age still defaults to 0
<Welcome name="John" age={25} />  // Both provided
```

### Props Deep Dive: Everything You Need to Know

```jsx
// ===== KEY RULE: Props are READ-ONLY (Immutable)
function BadComponent(props) {
  props.name = 'Changed';  // ❌ ERROR! Cannot modify props
  return <h1>{props.name}</h1>;
}
// React doesn't allow this! Props are one-way data flow.
// If you need to change data, use STATE instead

// ===== Props can be ANY JavaScript value
<UserProfile
  name="John"                           // String prop
  age={25}                              // Number prop
  isAdmin={true}                        // Boolean prop
  roles={['user', 'editor']}            // Array prop
  address={{ city: 'NYC', zip: '10001' }} // Object prop
  onClick={handleClick}                  // Function prop (callback)
  icon={<StarIcon />}                    // React element prop
  nullable={null}                       // null is valid
/>

// ===== PATTERN: Children Prop
// Special prop that contains content between opening/closing tags
function Card({ children, title }) {
  return (
    <div className="card">
      <h2>{title}</h2>
      <div className="card-body">
        {children}  {/* ← Whatever is inside <Card> */}
      </div>
    </div>
  );
}

// Usage:
<Card title="User Info">
  {/* ← Everything here becomes the 'children' prop */}
  <p>Name: John Doe</p>
  <p>Email: john@example.com</p>
</Card>

// This is how composition works - powerful pattern!

// ===== PATTERN: Multiple Children
function Grid({ children }) {
  return (
    <div className="grid">
      {children}  {/* Can be multiple elements */}
    </div>
  );
}

// Usage:
<Grid>
  <Button>Save</Button>
  <Button>Cancel</Button>
  <Button>Delete</Button>
</Grid>

// ===== PATTERN: Render Props
// Pass a function as a prop that returns JSX
function DataFetcher({ url, render }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => {
        setData(data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, [url]);

  // Call the render function (callback) with the data
  return render({ data, loading, error });
}

// Usage:
<DataFetcher
  url="/api/users"
  render={({ data, loading, error }) => {
    if (loading) return <Spinner />;
    if (error) return <Error msg={error} />;
    return <UserList users={data} />;
  }}
/>

// This pattern is less common now, but still useful
// Many libraries use this (Apollo GraphQL, Downshift, etc.)
```

### Props Best Practices

```jsx
// ❌ ANTI-PATTERN: Too many props (prop explosion)
function UserCard(
  id, name, email, phone, address, city, zipCode,
  isActive, isAdmin, createdAt, updatedAt, roles,
  onEdit, onDelete, onView, ...otherProps
) {
  // Too many props = hard to use and remember
}

// ✅ GOOD: Group related props into objects
interface UserCardProps {
  user: User;  // ← Group related data
  contact: Contact;  // ← Another logical group
  actions: {
    onEdit: () => void;
    onDelete: () => void;
    onView: () => void;
  };
}

function UserCard({ user, contact, actions }: UserCardProps) {
  return (
    <div>
      <h2>{user.name}</h2>
      <p>{contact.email}</p>
      <button onClick={actions.onEdit}>Edit</button>
    </div>
  );
}

// ✅ GOOD: Use TypeScript to document props
import { ReactNode } from 'react';

interface ButtonProps {
  children: ReactNode;
  onClick: () => void;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg';
}

function Button({
  children,
  onClick,
  variant = 'primary',
  disabled = false,
  size = 'md'
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant} btn-${size}`}
    >
      {children}
    </button>
  );
}

// Now TypeScript catches mistakes at compile time!
// <Button onClick={handleClick} variant="invalid" />  // ERROR!
```

### PropTypes (Runtime Type Checking)

```jsx
import PropTypes from 'prop-types';

function UserCard({ name, age, email, roles, onSelect }) {
  return (
    <div onClick={() => onSelect(name)}>
      <h2>{name}</h2>
      <p>Age: {age}</p>
      <p>Email: {email}</p>
      <p>Roles: {roles.join(', ')}</p>
    </div>
  );
}

UserCard.propTypes = {
  // Basic types
  name: PropTypes.string.isRequired,
  age: PropTypes.number,
  email: PropTypes.string,

  // Arrays and objects
  roles: PropTypes.arrayOf(PropTypes.string),
  address: PropTypes.shape({
    street: PropTypes.string,
    city: PropTypes.string,
    zip: PropTypes.string
  }),

  // One of specific values
  status: PropTypes.oneOf(['active', 'inactive', 'pending']),

  // One of specific types
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),

  // Function
  onSelect: PropTypes.func.isRequired,

  // React element
  icon: PropTypes.element,

  // Any renderable (number, string, element, array, fragment)
  children: PropTypes.node,

  // Custom validator
  customProp: function(props, propName, componentName) {
    if (!/^[A-Z]/.test(props[propName])) {
      return new Error(`${propName} must start with uppercase`);
    }
  }
};

UserCard.defaultProps = {
  age: 0,
  roles: [],
  status: 'active'
};
```

### TypeScript Props (Preferred for Production)

```typescript
// Interface for props
interface UserCardProps {
  name: string;
  age?: number;  // Optional
  email: string;
  roles: string[];
  status: 'active' | 'inactive' | 'pending';
  address?: {
    street: string;
    city: string;
    zip: string;
  };
  onSelect: (name: string) => void;
  children?: React.ReactNode;
}

// Functional component with TypeScript
const UserCard: React.FC<UserCardProps> = ({
  name,
  age = 0,
  email,
  roles,
  status = 'active',
  onSelect,
  children
}) => {
  return (
    <div onClick={() => onSelect(name)}>
      <h2>{name}</h2>
      <p>Age: {age}</p>
      <p>Email: {email}</p>
      <p>Status: {status}</p>
      {children}
    </div>
  );
};

// Alternative syntax (preferred - avoids implicit children)
function UserCard({
  name,
  age = 0,
  email,
  roles,
  onSelect
}: UserCardProps) {
  // ...
}

// Generic components
interface ListProps<T> {
  items: T[];
  renderItem: (item: T) => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, keyExtractor }: ListProps<T>) {
  return (
    <ul>
      {items.map(item => (
        <li key={keyExtractor(item)}>{renderItem(item)}</li>
      ))}
    </ul>
  );
}

// Usage
<List
  items={users}
  renderItem={(user) => <span>{user.name}</span>}
  keyExtractor={(user) => user.id}
/>
```

---

## 4. State Management

### useState: The Complete Guide

`useState` is the fundamental hook for managing component state. When state changes, React re-renders the component.

```jsx
import { useState } from 'react';

function Counter() {
  // ===== BASIC STATE
  // useState returns [currentValue, function to update it]
  // When setCount is called with new value, component re-renders
  const [count, setCount] = useState(0);  // ← 0 is initial value

  // ===== OBJECT STATE
  // Store complex data as object
  const [user, setUser] = useState({
    name: '',      // Store multiple related values
    email: '',
    age: 0
  });

  // ===== ARRAY STATE
  // Store lists of data
  const [items, setItems] = useState([]);

  // ===== LAZY INITIALIZATION
  // For expensive computations (expensive async/localStorage)
  // Pass function instead of value
  // Function only runs on mount, not on every render
  const [data, setData] = useState(() => {
    const stored = localStorage.getItem('data');
    return stored ? JSON.parse(stored) : defaultValue;
  });

  // ===== UPDATING PRIMITIVE STATE
  // Direct assignment works for primitives
  const handleIncrement = () => {
    setCount(count + 1);  // ← Direct value
  };

  // ===== FUNCTIONAL UPDATE (RECOMMENDED)
  // Use when new state depends on previous state
  // Solves stale closure issues
  const handleBetterIncrement = () => {
    setCount(prev => prev + 1);  // ← Use previous value
    // Guaranteed to be current, even in quick clicks
  };

  // ===== UPDATING OBJECT STATE
  // Must create NEW object, never mutate!
  const handleNameChange = (newName) => {
    // ❌ DON'T: Mutate directly
    // user.name = newName;
    // setUser(user);  // Won't work - same reference!

    // ✅ DO: Spread and update
    setUser({ ...user, name: newName });
  };

  // ===== UPDATING NESTED OBJECT STATE
  // Deep spread for nested properties
  const handleCityChange = (newCity) => {
    setUser(prev => ({
      ...prev,
      address: {
        ...prev.address,
        city: newCity
      }
    }));
  };

  // ===== ADDING TO ARRAY
  const handleAddItem = (newItem) => {
    setItems(prev => [...prev, newItem]);  // ← Spread to create new array
  };

  // ===== REMOVING FROM ARRAY
  const handleRemoveItem = (idToRemove) => {
    setItems(prev =>
      prev.filter(item => item.id !== idToRemove)  // ← Filter creates new array
    );
  };

  // ===== UPDATING ITEM IN ARRAY
  const handleUpdateItem = (idToUpdate, newName) => {
    setItems(prev =>
      prev.map(item =>
        item.id === idToUpdate
          ? { ...item, name: newName }  // ← New item object
          : item  // ← Keep others unchanged
      )
    );
  };

  // ===== REORDERING ARRAY
  const handleMoveUp = (index) => {
    if (index === 0) return;
    setItems(prev => {
      const newItems = [...prev];
      [newItems[index - 1], newItems[index]] = [newItems[index], newItems[index - 1]];
      return newItems;
    });
  };

  return (
    <div>
      <button onClick={handleIncrement}>Count: {count}</button>
      <button onClick={handleBetterIncrement}>Increment (Better)</button>
    </div>
  );
}
```

### State Batching: Automatic Optimization

```jsx
// React 18: AUTOMATIC BATCHING
// Multiple state updates in same event handler = ONE re-render
function handleClick() {
  setCount(c => c + 1);
  setFlag(f => !f);
  setName('John');
  // These 3 updates batched into 1 re-render! ✅ Performance win
}

// Before React 18, batching only worked in event handlers
// setTimeout, promises, etc. would cause separate re-renders

// Opt out of batching (very rare - only if needed)
import { flushSync } from 'react-dom';

function handleClick() {
  flushSync(() => {
    setCount(c => c + 1);  // ← Forces immediate DOM update
  });
  // DOM updated NOW - can read updated values

  flushSync(() => {
    setFlag(f => !f);  // ← Forces immediate DOM update
  });
  // DOM updated NOW again
  // Results in 2 DOM updates total (inefficient - avoid!)
}
```

### Common State Pitfalls & Solutions

```jsx
// ❌ PITFALL 1: Direct Mutation
const [user, setUser] = useState({ name: 'John', age: 25 });

user.age = 26;  // Mutating directly! ← React won't detect!
setUser(user);  // Same reference - no re-render!

// ✅ SOLUTION: Create new object
setUser({ ...user, age: 26 });

// ❌ PITFALL 2: Batching Behavior (Before React 18)
const [count, setCount] = useState(0);

async function handleClick() {
  setCount(1);
  setCount(2);
  setCount(3);
  // In React 17: 3 separate re-renders (slow!)
  // In React 18: Single batched re-render (fast!)
}

// ✅ REACT 18: Already batches automatically

// ❌ PITFALL 3: Expensive Initial State
const [largeArray, setLargeArray] = useState(
  computeExpensiveArray()  // ← Called on EVERY render!
);

// ✅ SOLUTION: Use lazy initialization
const [largeArray, setLargeArray] = useState(() =>
  computeExpensiveArray()  // ← Called only ONCE on mount
);

// ❌ PITFALL 4: Stale Closures with Multiple Clicks
const [count, setCount] = useState(0);

const handleClick = async () => {
  setCount(count + 1);
  
  setTimeout(() => {
    console.log(count);  // Logs old count! (stale closure)
  }, 1000);
};

// ✅ SOLUTION: Use functional updates
const handleClick = async () => {
  setCount(prev => prev + 1);
  
  setTimeout(() => {
    // Can't access current count here without effect
    // But functional update guarantees correct state
  }, 1000);
};

// ❌ PITFALL 5: Object Array in State
const [user, setUser] = useState({
  address: { city: 'NYC', zip: '10001' }
});

user.address.city = 'LA';  // Nested mutation!
setUser(user);  // Won't trigger re-render

// ✅ SOLUTION: Deep immutable update
setUser(prev => ({
  ...prev,
  address: {
    ...prev.address,
    city: 'LA'
  }
}));
```

function handleClick() {
  setCount(count + 1);  // Uses closure value
  setCount(count + 1);  // Still uses same closure value!
  setCount(count + 1);  // count is still 0, so this sets to 1
}

// ✅ CORRECT: Use functional updates
function handleClick() {
  setCount(prev => prev + 1);  // 0 → 1
  setCount(prev => prev + 1);  // 1 → 2
  setCount(prev => prev + 1);  // 2 → 3
}

// ❌ MISTAKE 3: Deriving state that could be computed
const [items, setItems] = useState([]);
const [itemCount, setItemCount] = useState(0);  // Unnecessary!

// ✅ CORRECT: Derive during render
const itemCount = items.length;

// ❌ MISTAKE 4: Copying props to state
function UserProfile({ user }) {
  const [localUser, setLocalUser] = useState(user);  // Anti-pattern!
  // Won't update when props change
}

// ✅ CORRECT: Use props directly or useEffect to sync
function UserProfile({ user }) {
  const [localUser, setLocalUser] = useState(user);
  useEffect(() => {
    setLocalUser(user);
  }, [user]);
}
```

---

## 5. Hooks In-Depth

### useEffect: The Complete Guide

#### Understanding useEffect

`useEffect` is React's way to handle side effects - things that affect the world outside React (API calls, subscriptions, DOM manipulation, etc.)

```jsx
import { useEffect, useState } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // ===== PATTERN 1: Effect runs EVERY RENDER (no dependency array)
  useEffect(() => {
    console.log('Runs after EVERY render');
    // Very rare to use this - usually causes performance issues
  });

  // ===== PATTERN 2: Effect runs ONCE on mount (empty dependency array)
  useEffect(() => {
    console.log('Runs ONCE when component mounts');
    console.log('Perfect for: Initial data fetch, setup listeners');
    
    // This runs ONCE on mount
    return () => {
      console.log('Runs ONCE on unmount (cleanup)');
      // Perfect for: Cleanup listeners, cancel requests
    };
  }, []);  // ← Empty array = run once

  // ===== PATTERN 3: Effect runs when DEPENDENCIES change
  useEffect(() => {
    console.log('Runs when userId changes:', userId);
    console.log('Perfect for: Re-fetching data when ID changes');
  }, [userId]);  // ← Array with dependencies

  // ===== PATTERN 4: Complete Data Fetching Example
  useEffect(() => {
    // PROBLEM: If component unmounts while fetching, 
    // React will try to setState on unmounted component = memory leak warning
    // SOLUTION: Track whether component is still mounted
    let cancelled = false;  // ← Key: Prevent state update on unmounted component

    async function fetchUser() {
      setLoading(true);  // Show loading state
      setError(null);    // Clear previous errors

      try {
        // API call
        const response = await fetch(`/api/users/${userId}`);
        if (!response.ok) throw new Error('Failed to fetch');

        const data = await response.json();

        // Only update state if component is still mounted
        if (!cancelled) {
          setUser(data);
        }
      } catch (err) {
        // Only update state if component is still mounted
        if (!cancelled) {
          setError(err.message);
        }
      } finally {
        // Only update state if component is still mounted
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    // Call the async function
    fetchUser();

    // Cleanup function: Mark as cancelled when dependencies change or unmount
    return () => {
      cancelled = true;  // ← Prevents state updates
    };
  }, [userId]);  // ← Re-run when userId changes

  // ===== PATTERN 5: Event Listener Pattern
  useEffect(() => {
    function handleResize() {
      console.log('Window resized to:', window.innerWidth);
    }

    // ADD listener
    window.addEventListener('resize', handleResize);

    // CLEANUP: Remove listener to prevent memory leaks
    return () => {
      window.removeEventListener('resize', handleResize);  // ← Critical!
    };
  }, []);  // ← Empty array: add listener once on mount

  // ===== PATTERN 6: Timer/Interval Pattern
  useEffect(() => {
    const intervalId = setInterval(() => {
      console.log('Tick');
    }, 1000);

    // CLEANUP: Clear interval to prevent multiple timers
    return () => {
      clearInterval(intervalId);  // ← Critical for memory!
    };
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return null;

  return <div>{user.name}</div>;
}

// ===== COMMON MISTAKES
export function CommonMistakes() {
  const [user, setUser] = useState(null);

  // ❌ MISTAKE: Fetching in every render
  // useEffect(() => {
  //   fetch('/api/user').then(r => r.json()).then(setUser);
  // });  // NO DEPENDENCY ARRAY = infinite fetch loop!

  // ✅ FIXED: Add empty dependency array
  useEffect(() => {
    fetch('/api/user')
      .then(r => r.json())
      .then(setUser);
  }, []);  // ← Only fetch once on mount

  // ❌ MISTAKE: Missing dependencies
  // useEffect(() => {
  //   const timer = setTimeout(() => {
  //     console.log(count);  // count might be stale!
  //   }, 1000);
  //   return () => clearTimeout(timer);
  // }, []);  // ← Missing 'count' dependency!

  // ✅ FIXED: Include all used variables
  // useEffect(() => {
  //   const timer = setTimeout(() => {
  //     console.log(count);  // count is current
  //   }, 1000);
  //   return () => clearTimeout(timer);
  // }, [count]);  // ← Include 'count'

  return null;
}
```

### useRef: Complete Guide

`useRef` is for accessing DOM directly or storing mutable values that don't trigger re-renders.

```jsx
import { useRef, useEffect, useState } from 'react';

function TextInputExample() {
  // ===== USE CASE 1: Reference to DOM element
  // useRef returns an object with .current property
  const inputRef = useRef(null);  // ← null is initial value

  // ===== USE CASE 2: Mutable value that persists across renders
  // Unlike state, updating ref.current does NOT trigger re-render
  const renderCount = useRef(0);  // ← persists across renders

  // ===== USE CASE 3: Store previous value
  const prevValue = useRef('');   // ← remembers previous value

  const [value, setValue] = useState('');

  // Track how many times component renders
  useEffect(() => {
    renderCount.current += 1;  // ← NO re-render! (unlike setState)
    console.log('Render count:', renderCount.current);
  });

  // Store previous value
  useEffect(() => {
    prevValue.current = value;  // ← Run AFTER component renders
  }, [value]);  // ← Run when value changes

  // Focus input on mount
  useEffect(() => {
    // Access DOM element via ref.current
    inputRef.current.focus();  // ← inputRef.current is the HTML element
  }, []);

  // Access DOM methods
  const handleSelectAll = () => {
    inputRef.current.select();  // ← Select all text in input
  };

  const handleScrollIntoView = () => {
    inputRef.current.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div>
      {/* ref connects ref object to DOM element */}
      <input
        ref={inputRef}  // ← Connect ref to this input
        value={value}
        onChange={(e) => setValue(e.target.value)}
        placeholder="Type something..."
      />
      
      <p>Current value: {value}</p>
      <p>Previous value: {prevValue.current}</p>
      <p>Render count: {renderCount.current}</p>
      
      <button onClick={handleSelectAll}>Select All</button>
      <button onClick={handleScrollIntoView}>Scroll Into View</button>
    </div>
  );
}

// ===== USE CASE 4: Forwarding refs to child components
// By default, you can't pass ref to child components like props
// You need React.forwardRef to enable this

const FancyInput = React.forwardRef((props, ref) => {
  // ← ref is now available as second parameter
  return (
    <input 
      ref={ref}  // ← Connect ref to DOM element
      className="fancy-input" 
      {...props} 
    />
  );
});

// Now parent can use ref
function Parent() {
  const fancyInputRef = useRef(null);

  const handleFocus = () => {
    fancyInputRef.current.focus();  // ← Works because of forwardRef
  };

  return (
    <>
      <FancyInput ref={fancyInputRef} placeholder="Focus me" />
      <button onClick={handleFocus}>Focus Input</button>
    </>
  );
}

// ===== USE CASE 5: useImperativeHandle
// Customize what properties/methods are exposed via ref
const FancyInputWithMethods = React.forwardRef((props, ref) => {
  const inputRef = useRef(null);

  // Control what parent component can access
  useImperativeHandle(ref, () => ({
    // Parent can only call these methods
    focus: () => inputRef.current.focus(),
    selectAll: () => inputRef.current.select(),
    clear: () => { inputRef.current.value = ''; },
    getValue: () => inputRef.current.value
  }));

  return <input ref={inputRef} {...props} />;
}, []);

// Parent usage
function ImperativeParent() {
  const imperativeRef = useRef(null);

  const handleClear = () => {
    imperativeRef.current.clear();  // ← Uses custom method
  };

  const handleGetValue = () => {
    console.log(imperativeRef.current.getValue());
  };

  return (
    <>
      <FancyInputWithMethods ref={imperativeRef} />
      <button onClick={handleClear}>Clear</button>
      <button onClick={handleGetValue}>Get Value</button>
    </>
  );
}

// ===== COMMON PATTERNS
export function RefPatterns() {
  // ❌ BAD: Using ref when state should be used
  // const countRef = useRef(0);
  // const increment = () => countRef.current++;
  // return <div>{countRef.current}</div>  // Won't re-render!
  
  // ✅ GOOD: Use state for values that need to trigger renders
  const [count, setCount] = useState(0);  // ← Use state!

  // ❌ BAD: Initializing ref in render
  // const ref = useRef(getData());  // getData() called every render!

  // ✅ GOOD: Initialize in callback if needed
  const ref = useRef(null);
  useEffect(() => {
    if (ref.current === null) {
      ref.current = getData();
    }
  }, []);

  // ✅ GOOD: Practical use case - debounce timer
  const debounceTimerRef = useRef(null);
  
  const handleChange = (e) => {
    // Clear previous timer
    clearTimeout(debounceTimerRef.current);
    
    // Set new timer
    debounceTimerRef.current = setTimeout(() => {
      console.log('Search:', e.target.value);
    }, 500);
  };

  return (
    <div>
      <input onChange={handleChange} placeholder="Search (debounced)" />
    </div>
  );
}
    clear: () => {
      inputRef.current.value = '';
    },
    getValue: () => inputRef.current.value
  }));

  return <input ref={inputRef} {...props} />;
});
```

### useMemo and useCallback

```jsx
import { useMemo, useCallback, useState } from 'react';

function ExpensiveComponent({ items, filter, onItemClick }) {
  // useMemo - memoize expensive calculations
  const filteredItems = useMemo(() => {
    console.log('Filtering items...');  // Only runs when items or filter change
    return items.filter(item =>
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);

  // useMemo for expensive computations
  const statistics = useMemo(() => {
    console.log('Calculating statistics...');
    return {
      total: items.length,
      average: items.reduce((a, b) => a + b.price, 0) / items.length,
      max: Math.max(...items.map(i => i.price)),
      min: Math.min(...items.map(i => i.price))
    };
  }, [items]);

  // useCallback - memoize functions
  const handleItemClick = useCallback((item) => {
    console.log('Clicked:', item);
    onItemClick(item);
  }, [onItemClick]);

  // Without useCallback, handleItemClick would be a new function every render
  // Causing child components to re-render unnecessarily

  return (
    <div>
      <Stats data={statistics} />
      <ItemList items={filteredItems} onItemClick={handleItemClick} />
    </div>
  );
}

// When to use useMemo/useCallback:
// 1. Expensive calculations
// 2. Referential equality for dependencies
// 3. Passing callbacks to memoized children

// When NOT to use:
// 1. Simple calculations (overhead not worth it)
// 2. Primitives that are recreated anyway
// 3. Functions not passed to children or used in deps

// ❌ Over-optimization
const value = useMemo(() => a + b, [a, b]);  // Addition is not expensive!

// ✅ Good use case
const sortedData = useMemo(() =>
  [...data].sort((a, b) => a.date - b.date),
  [data]
);
```

### useReducer

```jsx
import { useReducer } from 'react';

// Reducer function (similar to Redux)
function todoReducer(state, action) {
  switch (action.type) {
    case 'ADD_TODO':
      return {
        ...state,
        todos: [...state.todos, {
          id: Date.now(),
          text: action.payload,
          completed: false
        }]
      };

    case 'TOGGLE_TODO':
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };

    case 'DELETE_TODO':
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload)
      };

    case 'SET_FILTER':
      return {
        ...state,
        filter: action.payload
      };

    case 'CLEAR_COMPLETED':
      return {
        ...state,
        todos: state.todos.filter(todo => !todo.completed)
      };

    default:
      return state;
  }
}

// Initial state
const initialState = {
  todos: [],
  filter: 'all'  // 'all' | 'active' | 'completed'
};

// Component
function TodoApp() {
  const [state, dispatch] = useReducer(todoReducer, initialState);
  const [inputValue, setInputValue] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (inputValue.trim()) {
      dispatch({ type: 'ADD_TODO', payload: inputValue });
      setInputValue('');
    }
  };

  const filteredTodos = useMemo(() => {
    switch (state.filter) {
      case 'active':
        return state.todos.filter(t => !t.completed);
      case 'completed':
        return state.todos.filter(t => t.completed);
      default:
        return state.todos;
    }
  }, [state.todos, state.filter]);

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          placeholder="Add todo..."
        />
      </form>

      <ul>
        {filteredTodos.map(todo => (
          <li key={todo.id}>
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => dispatch({ type: 'TOGGLE_TODO', payload: todo.id })}
            />
            <span style={{ textDecoration: todo.completed ? 'line-through' : 'none' }}>
              {todo.text}
            </span>
            <button onClick={() => dispatch({ type: 'DELETE_TODO', payload: todo.id })}>
              Delete
            </button>
          </li>
        ))}
      </ul>

      <div>
        <button onClick={() => dispatch({ type: 'SET_FILTER', payload: 'all' })}>
          All
        </button>
        <button onClick={() => dispatch({ type: 'SET_FILTER', payload: 'active' })}>
          Active
        </button>
        <button onClick={() => dispatch({ type: 'SET_FILTER', payload: 'completed' })}>
          Completed
        </button>
      </div>

      <button onClick={() => dispatch({ type: 'CLEAR_COMPLETED' })}>
        Clear Completed
      </button>
    </div>
  );
}

// useState vs useReducer decision:
// useState: Simple state, few updates, independent values
// useReducer: Complex state, many updates, related values, state machine logic
```

### Custom Hooks

```jsx
// useFetch - Data fetching hook
function useFetch(url) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      setLoading(true);
      setError(null);

      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const json = await response.json();

        if (!cancelled) {
          setData(json);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      cancelled = true;
    };
  }, [url]);

  return { data, loading, error };
}

// Usage
function UserProfile({ userId }) {
  const { data: user, loading, error } = useFetch(`/api/users/${userId}`);

  if (loading) return <Spinner />;
  if (error) return <Error message={error} />;
  return <div>{user.name}</div>;
}

// useLocalStorage - Persist state to localStorage
function useLocalStorage(key, initialValue) {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(error);
      return initialValue;
    }
  });

  const setValue = useCallback((value) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(error);
    }
  }, [key, storedValue]);

  return [storedValue, setValue];
}

// Usage
function Settings() {
  const [theme, setTheme] = useLocalStorage('theme', 'light');
  return (
    <button onClick={() => setTheme(t => t === 'light' ? 'dark' : 'light')}>
      Current: {theme}
    </button>
  );
}

// useDebounce - Debounce a value
function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}

// Usage
function SearchInput() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 300);

  useEffect(() => {
    if (debouncedSearchTerm) {
      // Perform search
      searchAPI(debouncedSearchTerm);
    }
  }, [debouncedSearchTerm]);

  return (
    <input
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      placeholder="Search..."
    />
  );
}

// useToggle - Boolean toggle
function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => setValue(v => !v), []);
  const setTrue = useCallback(() => setValue(true), []);
  const setFalse = useCallback(() => setValue(false), []);

  return { value, toggle, setTrue, setFalse };
}

// Usage
function Modal() {
  const { value: isOpen, toggle, setFalse: close } = useToggle();

  return (
    <>
      <button onClick={toggle}>Toggle Modal</button>
      {isOpen && (
        <div className="modal">
          <button onClick={close}>Close</button>
        </div>
      )}
    </>
  );
}

// usePrevious - Track previous value
function usePrevious(value) {
  const ref = useRef();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

// useWindowSize
function useWindowSize() {
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight
  });

  useEffect(() => {
    const handleResize = () => {
      setSize({
        width: window.innerWidth,
        height: window.innerHeight
      });
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  return size;
}
```

---

### useContext Hook — Deep Dive

`useContext` is the hook that lets you **read** a value from a React Context without needing a Consumer wrapper.
It is the consumer-side of the Context API (see Section 9 for the full Context API guide).

```jsx
import { createContext, useContext, useState } from 'react';

// ─────────────────────────────────────────────────────────────────
// STEP 1: Create a context object
// createContext(defaultValue) — defaultValue is only used when there
// is NO matching Provider above the component in the tree.
// ─────────────────────────────────────────────────────────────────
const UserContext = createContext(null); // null = no default, must have Provider

// ─────────────────────────────────────────────────────────────────
// STEP 2: Create a Provider — wraps the component tree
// Any component inside this Provider can read the context value.
// ─────────────────────────────────────────────────────────────────
function UserProvider({ children }) {
  const [user, setUser] = useState({ name: 'Alice', role: 'admin' });

  return (
    // value prop is what consumers will receive via useContext
    <UserContext.Provider value={{ user, setUser }}>
      {children}  {/* ← All children can access the context */}
    </UserContext.Provider>
  );
}

// ─────────────────────────────────────────────────────────────────
// STEP 3: Create a custom hook — always wrap useContext in a hook
// This pattern: (1) provides a friendly API, (2) adds error checking,
// (3) prevents misuse outside the Provider
// ─────────────────────────────────────────────────────────────────
function useUser() {
  // useContext reads the nearest Provider's value above this component
  const context = useContext(UserContext);

  // Guard: if someone uses useUser() outside <UserProvider>, catch it immediately
  if (context === null) {
    throw new Error('useUser must be used within a <UserProvider>');
    // Without this check, you'd get confusing null-pointer errors deep in code
  }

  return context; // Returns { user, setUser }
}

// ─────────────────────────────────────────────────────────────────
// STEP 4: Consume the context — any component, anywhere in the tree
// No prop drilling needed — UserHeader doesn't need to receive user
// as a prop even if it's nested 5 levels deep
// ─────────────────────────────────────────────────────────────────
function UserHeader() {
  const { user } = useUser(); // ← reads from nearest UserProvider above it

  // Component automatically re-renders when context value changes
  return <h1>Welcome, {user.name}! Role: {user.role}</h1>;
}

function UserSettings() {
  const { user, setUser } = useUser();

  const handleNameChange = (e) => {
    // Updating context state → triggers re-render in ALL consumers
    setUser(prev => ({ ...prev, name: e.target.value }));
  };

  return (
    <input
      value={user.name}
      onChange={handleNameChange}
      placeholder="Change name"
    />
  );
}

// ─────────────────────────────────────────────────────────────────
// STEP 5: Wrap the app (or subtree) with the Provider
// Provider must be an ANCESTOR — not a sibling or child
// ─────────────────────────────────────────────────────────────────
function App() {
  return (
    <UserProvider>          {/* ← UserHeader and UserSettings can now read context */}
      <div className="app">
        <UserHeader />        {/* ← Works — inside UserProvider */}
        <main>
          <UserSettings />    {/* ← Works — inside UserProvider */}
        </main>
      </div>
    </UserProvider>
  );
}

// ─────────────────────────────────────────────────────────────────
// HOW IT WORKS INTERNALLY (mental model):
//
// When React renders a component calling useContext(UserContext):
// 1. React walks UP the component tree
// 2. Finds the nearest <UserContext.Provider>
// 3. Returns that Provider's current `value` prop
// 4. Subscribes the component to future value changes
// 5. When value changes → component re-renders automatically
//
// Tree visualization:
//   <App>
//     <UserProvider value={{user, setUser}}>   ← React finds THIS
//       <Layout>
//         <Sidebar>
//           <UserHeader>
//             useContext(UserContext) ← starts walking UP here
//           </UserHeader>
//         </Sidebar>
//       </Layout>
//     </UserProvider>
//   </App>
// ─────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────
// COMMON MISTAKE: Calling useContext outside a Provider
// ─────────────────────────────────────────────────────────────────
function StandaloneComponent() {
  // ❌ If this renders outside UserProvider, context = null
  // useUser() throws our error: "useUser must be used within UserProvider"
  const { user } = useUser();
  return <div>{user.name}</div>;
}

// ─────────────────────────────────────────────────────────────────
// PERFORMANCE NOTE: Every context value change re-renders ALL consumers
// Optimization: memoize the value object to prevent unnecessary renders
// ─────────────────────────────────────────────────────────────────
function OptimizedUserProvider({ children }) {
  const [user, setUser] = useState({ name: 'Alice', role: 'admin' });

  // useMemo ensures the value object reference only changes when user changes
  // Without this, a new object is created every render → all consumers re-render
  const value = useMemo(() => ({ user, setUser }), [user]);

  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}
```

---

### useLayoutEffect — Synchronous DOM Measurements

`useLayoutEffect` is identical to `useEffect` BUT fires **synchronously** after all DOM mutations, before the browser paints. Use it when you need to read the DOM and re-render before the user sees the intermediate state.

```jsx
import { useLayoutEffect, useEffect, useRef, useState } from 'react';

// ─────────────────────────────────────────────────────────────────
// useEffect vs useLayoutEffect TIMING:
//
// Render cycle:
// 1. React updates the DOM
// 2. useLayoutEffect fires ← synchronous, blocks paint
// 3. Browser paints (user sees the UI)
// 4. useEffect fires ← asynchronous, after paint
//
// Use useLayoutEffect when:
//   - You need to measure DOM size/position BEFORE paint
//   - You need to prevent visual flickering from DOM changes
//   - Migrating class component componentDidMount/Update that reads DOM
//
// Use useEffect (default) for:
//   - Data fetching
//   - Event listeners
//   - Subscriptions
//   - Anything that doesn't need to block painting
// ─────────────────────────────────────────────────────────────────

// Example 1: Measuring element size before paint (no flicker)
function Tooltip({ children, tooltipText }) {
  const tooltipRef = useRef(null);
  const [position, setPosition] = useState({ top: 0, left: 0 });

  // ✅ useLayoutEffect: measure BEFORE user sees anything
  // If we used useEffect, the tooltip would flash in wrong position, then jump
  useLayoutEffect(() => {
    if (tooltipRef.current) {
      const rect = tooltipRef.current.getBoundingClientRect();
      // Calculate where tooltip should appear based on actual rendered size
      setPosition({
        top: rect.top - rect.height - 8,  // above the element
        left: rect.left + rect.width / 2  // centered
      });
    }
    // Runs synchronously after DOM update, before browser paints
    // User never sees the wrong position
  }, []); // runs after initial render

  return (
    <div>
      {children}
      <div
        ref={tooltipRef}
        style={{ position: 'absolute', top: position.top, left: position.left }}
      >
        {tooltipText}
      </div>
    </div>
  );
}

// Example 2: Scroll to top synchronously (no flicker)
function PageContent({ pageId }) {
  // ❌ useEffect would cause a flash: user briefly sees old scroll position
  // useEffect(() => { window.scrollTo(0, 0); }, [pageId]);

  // ✅ useLayoutEffect fires before paint: user never sees the wrong scroll
  useLayoutEffect(() => {
    window.scrollTo(0, 0); // Reset scroll position synchronously
  }, [pageId]); // Runs every time pageId changes

  return <div>Page {pageId} content...</div>;
}

// Example 3: Read and write DOM in same effect (animated transition)
function AnimatedBox({ isExpanded }) {
  const boxRef = useRef(null);

  useLayoutEffect(() => {
    const box = boxRef.current;
    if (!box) return;

    if (isExpanded) {
      // Read current height
      const currentHeight = box.scrollHeight;
      // Set it before paint (prevents flash of wrong height)
      box.style.height = `${currentHeight}px`;
    } else {
      box.style.height = '0px';
    }
    // All of this happens before the browser repaints → smooth animation
  }, [isExpanded]);

  return (
    <div
      ref={boxRef}
      style={{ overflow: 'hidden', transition: 'height 0.3s ease' }}
    >
      <p>Expandable content here</p>
    </div>
  );
}
```

---

### React 18 Hooks — useTransition, useDeferredValue, useId

React 18 introduced **Concurrent Mode hooks** that let you separate urgent updates from non-urgent (deferred) ones, preventing UI blocking.

```jsx
import {
  useTransition,
  useDeferredValue,
  useId,
  useState,
  useMemo
} from 'react';

// ═══════════════════════════════════════════════════════════════
// useTransition — Mark state updates as non-urgent
//
// Problem: User types in a search box. Filtering 10,000 items
// is slow → typing feels laggy (input state update is blocked
// by the slow filtering render).
//
// Solution: Tell React "the filter update is low priority"
// → React updates the input FIRST (urgent), filter later (non-urgent)
// ═══════════════════════════════════════════════════════════════
function SearchWithTransition() {
  const [query, setQuery] = useState('');          // Input state — urgent
  const [results, setResults] = useState([]);      // Search results — non-urgent
  const [isPending, startTransition] = useTransition();
  //    ↑ isPending: true while the transition is running (show spinner)
  //                          ↑ startTransition: wrap non-urgent updates

  const handleSearch = (e) => {
    const value = e.target.value;

    // URGENT: update input immediately so typing feels instant
    setQuery(value);

    // NON-URGENT: heavy computation deferred — React can interrupt this
    // if user types again before this finishes
    startTransition(() => {
      // This state update is "interruptible" — React may pause it
      // to handle more urgent updates (like another keystroke)
      const filtered = hugeDataset.filter(item =>
        item.name.toLowerCase().includes(value.toLowerCase())
      );
      setResults(filtered);
    });
  };

  return (
    <div>
      <input
        value={query}
        onChange={handleSearch}
        placeholder="Search..."
      />

      {/* isPending: show loading indicator while transition is processing */}
      {isPending ? (
        <p style={{ opacity: 0.5 }}>Searching...</p>  // ← non-blocking spinner
      ) : (
        <ul>
          {results.map(item => (
            <li key={item.id}>{item.name}</li>
          ))}
        </ul>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// useDeferredValue — Defer re-rendering of a value
//
// Similar to useTransition but for VALUES (not update functions)
// Use when you don't control the state update (e.g., it comes from props)
//
// How it works:
// - Returns a "deferred" copy of the value
// - On first render: deferred === current (no delay)
// - On fast updates: deferred lags behind current (shows stale value
//   while React works on expensive re-render with new value)
// ═══════════════════════════════════════════════════════════════
function SearchWithDeferredValue({ query }) {
  // query: updates immediately (urgent — user typed it)
  // deferredQuery: React can "delay" this for expensive renders
  const deferredQuery = useDeferredValue(query);
  //    ↑ This lags behind `query` during fast updates

  // Only re-computes when deferredQuery changes (deferred, so batched)
  // Without this, EVERY KEYSTROKE triggers an expensive filter
  const filteredResults = useMemo(() =>
    hugeDataset.filter(item =>
      item.name.toLowerCase().includes(deferredQuery.toLowerCase())
    ),
    [deferredQuery]  // ← uses deferred value, not live query
  );

  // Visual indicator: if deferred hasn't caught up yet, fade the results
  const isStale = deferredQuery !== query;

  return (
    <div style={{ opacity: isStale ? 0.5 : 1 }}>
      {/* Results appear slightly faded while updating — better than blank screen */}
      {filteredResults.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
    </div>
  );
}

// useTransition vs useDeferredValue — When to use which:
//
// useTransition: You control the state setter
//   → startTransition(() => setState(newValue))
//
// useDeferredValue: You receive a value from props or context
//   → const deferred = useDeferredValue(propValue)

// ═══════════════════════════════════════════════════════════════
// useId — Generate stable, unique IDs for accessibility
//
// Problem: HTML accessibility requires form inputs to be connected
// to labels via matching id/htmlFor. Hard-coding IDs breaks with
// SSR (server-rendered IDs don't match client) and multiple instances.
//
// Solution: useId generates a unique, stable ID per component instance
// that works correctly with SSR.
// ═══════════════════════════════════════════════════════════════
function FormField({ label, type = 'text' }) {
  // useId generates a unique ID like ":r1:" for each component instance
  // Stable across SSR and client hydration
  const id = useId();
  //    ↑ guaranteed unique even if component renders multiple times

  // You can derive multiple IDs from one base ID
  const inputId = `${id}-input`;       // e.g. ":r1:-input"
  const descriptionId = `${id}-desc`;  // e.g. ":r1:-desc"

  return (
    <div>
      {/* htmlFor must match the input's id — useId makes this automatic */}
      <label htmlFor={inputId}>{label}</label>

      <input
        id={inputId}                    // ← matches label's htmlFor
        type={type}
        aria-describedby={descriptionId} // ← accessibility: links to description
      />

      <p id={descriptionId}>
        Enter your {label.toLowerCase()} above.
      </p>
    </div>
  );
}

// Usage: Multiple instances on same page — each gets unique IDs automatically
function SignupForm() {
  return (
    <form>
      {/* Each FormField gets its own unique IDs — no collision! */}
      <FormField label="Email" type="email" />
      <FormField label="Password" type="password" />
      <FormField label="Username" type="text" />
    </form>
  );
}

// ─────────────────────────────────────────────────────────────────
// DON'T use useId for list keys — it's for accessibility attributes only
// ❌ items.map(() => <li key={useId()}>...</li>)  WRONG — hooks in loops
// ✅ items.map(item => <li key={item.id}>...</li>)
// ─────────────────────────────────────────────────────────────────
```

---

### Rules of Hooks — Why They Exist

```jsx
// ─────────────────────────────────────────────────────────────────
// RULE 1: Only call Hooks at the TOP LEVEL
// Never inside loops, conditions, or nested functions
// ─────────────────────────────────────────────────────────────────

// ❌ WRONG — conditional hook call breaks the order
function BadComponent({ userId }) {
  if (userId) {
    const [user, setUser] = useState(null); // ← conditional useState
  }
  // React tracks hooks by ORDER of calls per render.
  // If this condition changes, hook order breaks → React crashes.
}

// ✅ CORRECT — always call the hook, condition goes inside
function GoodComponent({ userId }) {
  const [user, setUser] = useState(null); // ← always called

  useEffect(() => {
    if (userId) { // ← condition inside the hook
      fetchUser(userId).then(setUser);
    }
  }, [userId]);

  return user ? <div>{user.name}</div> : null;
}

// ─────────────────────────────────────────────────────────────────
// RULE 2: Only call Hooks from React functions
// Not from regular JavaScript functions, class components, or event handlers
// ─────────────────────────────────────────────────────────────────

// ❌ WRONG — hook in a regular function
function regularFunction() {
  const [count, setCount] = useState(0); // ← Not a React function!
}

// ✅ CORRECT — hook in a React component function
function Counter() {
  const [count, setCount] = useState(0); // ← Valid: component function
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}

// ✅ CORRECT — hook in a custom hook (starts with 'use')
function useCounter(initial = 0) {
  const [count, setCount] = useState(initial); // ← Valid: custom hook
  return { count, increment: () => setCount(c => c + 1) };
}

// WHY THESE RULES?
// React identifies hook calls by their ORDER in each render.
// It doesn't use names or identifiers — just "1st hook, 2nd hook, 3rd hook..."
// If order changes (due to conditions/loops), React can't match calls
// to their stored state → bug or crash.
```

---

## 6. Component Lifecycle

### Lifecycle with Hooks

```jsx
import { useState, useEffect, useRef } from 'react';

function LifecycleDemo({ userId }) {
  const [user, setUser] = useState(null);
  const mountedRef = useRef(false);

  // componentDidMount equivalent
  useEffect(() => {
    console.log('Component mounted');
    mountedRef.current = true;

    // componentWillUnmount equivalent
    return () => {
      console.log('Component will unmount');
      mountedRef.current = false;
    };
  }, []);

  // componentDidUpdate equivalent (for specific prop)
  const prevUserId = useRef(userId);
  useEffect(() => {
    if (prevUserId.current !== userId) {
      console.log('userId changed from', prevUserId.current, 'to', userId);
      prevUserId.current = userId;
    }
  }, [userId]);

  // componentDidUpdate (runs after every render)
  useEffect(() => {
    console.log('Component rendered');
  });

  // Data fetching with cleanup
  useEffect(() => {
    let cancelled = false;

    async function loadUser() {
      const data = await fetchUser(userId);
      if (!cancelled) {
        setUser(data);
      }
    }

    loadUser();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  return user ? <div>{user.name}</div> : <div>Loading...</div>;
}
```

### Class Component Lifecycle (Legacy Reference)

```jsx
class ClassLifecycle extends React.Component {
  constructor(props) {
    super(props);
    this.state = { count: 0 };
    // Initialization
  }

  static getDerivedStateFromProps(props, state) {
    // Return new state based on props
    // Rarely needed
    return null;
  }

  componentDidMount() {
    // DOM available, good for:
    // - API calls
    // - Subscriptions
    // - DOM manipulation
  }

  shouldComponentUpdate(nextProps, nextState) {
    // Return false to skip re-render (performance optimization)
    // Usually use React.memo or PureComponent instead
    return true;
  }

  getSnapshotBeforeUpdate(prevProps, prevState) {
    // Capture info from DOM before update
    // Return value passed to componentDidUpdate
    return null;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    // Called after re-render
    // Good for operations based on prop/state changes
    if (this.props.userId !== prevProps.userId) {
      this.fetchUser(this.props.userId);
    }
  }

  componentWillUnmount() {
    // Cleanup: subscriptions, timers, etc.
  }

  componentDidCatch(error, errorInfo) {
    // Error boundary
    this.setState({ hasError: true });
  }

  render() {
    return <div>{this.state.count}</div>;
  }
}
```

---

## 7. Event Handling

### Event Basics

```jsx
function EventExamples() {
  // Basic click handler
  const handleClick = () => {
    console.log('Button clicked');
  };

  // Event object
  const handleClickWithEvent = (event) => {
    console.log('Event type:', event.type);
    console.log('Target:', event.target);
    console.log('Current target:', event.currentTarget);
  };

  // Passing arguments
  const handleItemClick = (itemId) => {
    console.log('Item clicked:', itemId);
  };

  // Prevent default
  const handleSubmit = (event) => {
    event.preventDefault();
    console.log('Form submitted');
  };

  // Stop propagation
  const handleInnerClick = (event) => {
    event.stopPropagation();
    console.log('Inner clicked');
  };

  return (
    <div onClick={() => console.log('Outer clicked')}>
      <button onClick={handleClick}>Click me</button>

      <button onClick={handleClickWithEvent}>With event</button>

      {/* Passing arguments - use arrow function or bind */}
      <button onClick={() => handleItemClick(123)}>Item 123</button>

      {/* Form submission */}
      <form onSubmit={handleSubmit}>
        <button type="submit">Submit</button>
      </form>

      {/* Stop propagation */}
      <button onClick={handleInnerClick}>Inner button</button>
    </div>
  );
}
```

### Synthetic Events

> **What are Synthetic Events?**
>
> React wraps native browser events in SyntheticEvent objects to provide a consistent interface across browsers. They have the same interface as native events but work identically across all browsers.

```jsx
function SyntheticEventDemo() {
  const handleClick = (e) => {
    // SyntheticEvent properties
    console.log(e.type);        // 'click'
    console.log(e.target);      // DOM element
    console.log(e.currentTarget);
    console.log(e.bubbles);
    console.log(e.defaultPrevented);

    // Access native event
    console.log(e.nativeEvent);

    // Prevent default behavior
    e.preventDefault();

    // Stop propagation
    e.stopPropagation();
  };

  // Event pooling (React 16 and earlier)
  // Synthetic events are pooled and reused - can't access async
  const handleClickOld = (e) => {
    // ❌ Won't work in React 16
    setTimeout(() => {
      console.log(e.type);  // null (event was recycled)
    }, 100);

    // ✅ Solution in React 16
    e.persist();  // Remove from pool
    setTimeout(() => {
      console.log(e.type);  // 'click'
    }, 100);
  };

  // React 17+ - no more event pooling, always works
  const handleClickNew = (e) => {
    setTimeout(() => {
      console.log(e.type);  // 'click' - works!
    }, 100);
  };

  return <button onClick={handleClick}>Click</button>;
}
```

### Event Types

```jsx
function AllEventTypes() {
  return (
    <div>
      {/* Mouse events */}
      <button
        onClick={(e) => console.log('click')}
        onDoubleClick={(e) => console.log('double click')}
        onMouseEnter={(e) => console.log('mouse enter')}
        onMouseLeave={(e) => console.log('mouse leave')}
        onMouseDown={(e) => console.log('mouse down')}
        onMouseUp={(e) => console.log('mouse up')}
        onContextMenu={(e) => { e.preventDefault(); console.log('right click'); }}
      >
        Mouse events
      </button>

      {/* Keyboard events */}
      <input
        onKeyDown={(e) => console.log('key down:', e.key)}
        onKeyUp={(e) => console.log('key up:', e.key)}
        onKeyPress={(e) => console.log('key press:', e.key)}  // Deprecated
      />

      {/* Form events */}
      <input
        onChange={(e) => console.log('changed:', e.target.value)}
        onFocus={(e) => console.log('focused')}
        onBlur={(e) => console.log('blurred')}
        onInput={(e) => console.log('input:', e.target.value)}
      />

      <form
        onSubmit={(e) => { e.preventDefault(); console.log('submit'); }}
        onReset={(e) => console.log('reset')}
      >
        <button type="submit">Submit</button>
      </form>

      {/* Drag events */}
      <div
        draggable
        onDragStart={(e) => console.log('drag start')}
        onDrag={(e) => console.log('dragging')}
        onDragEnd={(e) => console.log('drag end')}
        onDragEnter={(e) => console.log('drag enter')}
        onDragLeave={(e) => console.log('drag leave')}
        onDragOver={(e) => { e.preventDefault(); console.log('drag over'); }}
        onDrop={(e) => console.log('dropped')}
      >
        Drag me
      </div>

      {/* Touch events (mobile) */}
      <div
        onTouchStart={(e) => console.log('touch start')}
        onTouchMove={(e) => console.log('touch move')}
        onTouchEnd={(e) => console.log('touch end')}
      >
        Touch me
      </div>

      {/* Scroll event */}
      <div
        style={{ height: 200, overflow: 'auto' }}
        onScroll={(e) => console.log('scrolled:', e.target.scrollTop)}
      >
        <div style={{ height: 1000 }}>Scroll content</div>
      </div>

      {/* Clipboard events */}
      <input
        onCopy={(e) => console.log('copied')}
        onCut={(e) => console.log('cut')}
        onPaste={(e) => console.log('pasted:', e.clipboardData.getData('text'))}
      />
    </div>
  );
}
```

---

## 8. Forms & Controlled Components

### Controlled Components

```jsx
import { useState } from 'react';

function ControlledForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    age: 18,
    bio: '',
    country: 'us',
    skills: [],
    newsletter: false,
    gender: ''
  });

  const [errors, setErrors] = useState({});

  // Generic change handler
  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;

    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  // Handle multi-select
  const handleMultiSelect = (e) => {
    const options = Array.from(e.target.selectedOptions, opt => opt.value);
    setFormData(prev => ({ ...prev, skills: options }));
  };

  // Handle checkbox group
  const handleCheckboxGroup = (e) => {
    const { value, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      skills: checked
        ? [...prev.skills, value]
        : prev.skills.filter(s => s !== value)
    }));
  };

  // Validation
  const validate = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.email.includes('@')) {
      newErrors.email = 'Invalid email address';
    }

    if (formData.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (validate()) {
      console.log('Form submitted:', formData);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Text input */}
      <div>
        <label htmlFor="name">Name:</label>
        <input
          type="text"
          id="name"
          name="name"
          value={formData.name}
          onChange={handleChange}
        />
        {errors.name && <span className="error">{errors.name}</span>}
      </div>

      {/* Email input */}
      <div>
        <label htmlFor="email">Email:</label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
        />
        {errors.email && <span className="error">{errors.email}</span>}
      </div>

      {/* Password input */}
      <div>
        <label htmlFor="password">Password:</label>
        <input
          type="password"
          id="password"
          name="password"
          value={formData.password}
          onChange={handleChange}
        />
        {errors.password && <span className="error">{errors.password}</span>}
      </div>

      {/* Number input */}
      <div>
        <label htmlFor="age">Age:</label>
        <input
          type="number"
          id="age"
          name="age"
          value={formData.age}
          onChange={handleChange}
          min={0}
          max={150}
        />
      </div>

      {/* Textarea */}
      <div>
        <label htmlFor="bio">Bio:</label>
        <textarea
          id="bio"
          name="bio"
          value={formData.bio}
          onChange={handleChange}
          rows={4}
        />
      </div>

      {/* Select dropdown */}
      <div>
        <label htmlFor="country">Country:</label>
        <select
          id="country"
          name="country"
          value={formData.country}
          onChange={handleChange}
        >
          <option value="">Select...</option>
          <option value="us">United States</option>
          <option value="uk">United Kingdom</option>
          <option value="ca">Canada</option>
        </select>
      </div>

      {/* Multi-select */}
      <div>
        <label htmlFor="skills">Skills:</label>
        <select
          id="skills"
          name="skills"
          multiple
          value={formData.skills}
          onChange={handleMultiSelect}
        >
          <option value="react">React</option>
          <option value="node">Node.js</option>
          <option value="python">Python</option>
        </select>
      </div>

      {/* Checkbox */}
      <div>
        <label>
          <input
            type="checkbox"
            name="newsletter"
            checked={formData.newsletter}
            onChange={handleChange}
          />
          Subscribe to newsletter
        </label>
      </div>

      {/* Radio buttons */}
      <div>
        <label>
          <input
            type="radio"
            name="gender"
            value="male"
            checked={formData.gender === 'male'}
            onChange={handleChange}
          />
          Male
        </label>
        <label>
          <input
            type="radio"
            name="gender"
            value="female"
            checked={formData.gender === 'female'}
            onChange={handleChange}
          />
          Female
        </label>
        <label>
          <input
            type="radio"
            name="gender"
            value="other"
            checked={formData.gender === 'other'}
            onChange={handleChange}
          />
          Other
        </label>
      </div>

      <button type="submit">Submit</button>
    </form>
  );
}
```

### Uncontrolled Components

```jsx
import { useRef } from 'react';

function UncontrolledForm() {
  const nameRef = useRef(null);
  const emailRef = useRef(null);
  const fileRef = useRef(null);

  const handleSubmit = (e) => {
    e.preventDefault();

    const formData = {
      name: nameRef.current.value,
      email: emailRef.current.value,
      file: fileRef.current.files[0]
    };

    console.log('Form data:', formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        ref={nameRef}
        defaultValue="John"  // Default value (not controlled)
      />

      <input
        type="email"
        ref={emailRef}
        defaultValue="john@example.com"
      />

      {/* File input MUST be uncontrolled */}
      <input
        type="file"
        ref={fileRef}
        accept="image/*"
      />

      <button type="submit">Submit</button>
    </form>
  );
}

// When to use uncontrolled:
// 1. File inputs (always uncontrolled)
// 2. Integration with non-React code
// 3. Simple forms where you don't need real-time validation
// 4. Performance (no re-render on every keystroke)
```

### Form Libraries (React Hook Form)

```jsx
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Validation schema
const schema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
  skills: z.array(z.object({
    name: z.string().min(1, 'Skill name required'),
    years: z.number().min(0).max(50)
  }))
}).refine(data => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword']
});

type FormData = z.infer<typeof schema>;

function AdvancedForm() {
  const {
    register,
    handleSubmit,
    watch,
    formState: { errors, isSubmitting },
    reset,
    control
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: '',
      email: '',
      password: '',
      confirmPassword: '',
      skills: [{ name: '', years: 0 }]
    }
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: 'skills'
  });

  const onSubmit = async (data: FormData) => {
    await new Promise(resolve => setTimeout(resolve, 1000));
    console.log(data);
    reset();
  };

  // Watch specific field
  const password = watch('password');

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <input {...register('name')} placeholder="Name" />
        {errors.name && <span>{errors.name.message}</span>}
      </div>

      <div>
        <input {...register('email')} placeholder="Email" />
        {errors.email && <span>{errors.email.message}</span>}
      </div>

      <div>
        <input {...register('password')} type="password" placeholder="Password" />
        {errors.password && <span>{errors.password.message}</span>}
      </div>

      <div>
        <input
          {...register('confirmPassword')}
          type="password"
          placeholder="Confirm Password"
        />
        {errors.confirmPassword && <span>{errors.confirmPassword.message}</span>}
      </div>

      {/* Dynamic fields */}
      <div>
        <h3>Skills</h3>
        {fields.map((field, index) => (
          <div key={field.id}>
            <input
              {...register(`skills.${index}.name`)}
              placeholder="Skill name"
            />
            <input
              {...register(`skills.${index}.years`, { valueAsNumber: true })}
              type="number"
              placeholder="Years"
            />
            <button type="button" onClick={() => remove(index)}>
              Remove
            </button>
          </div>
        ))}
        <button type="button" onClick={() => append({ name: '', years: 0 })}>
          Add Skill
        </button>
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
}
```

---

## 9. Context API

### Creating and Using Context

```jsx
import { createContext, useContext, useState, useMemo } from 'react';

// 1. Create Context
const ThemeContext = createContext(null);

// 2. Create Provider Component
function ThemeProvider({ children }) {
  const [theme, setTheme] = useState('light');

  // Memoize context value to prevent unnecessary re-renders
  const value = useMemo(() => ({
    theme,
    toggleTheme: () => setTheme(t => t === 'light' ? 'dark' : 'light'),
    setTheme
  }), [theme]);

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
}

// 3. Create Custom Hook
function useTheme() {
  const context = useContext(ThemeContext);
  if (context === null) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}

// 4. Use in Components
function ThemedButton() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button
      onClick={toggleTheme}
      style={{
        background: theme === 'light' ? '#fff' : '#333',
        color: theme === 'light' ? '#333' : '#fff'
      }}
    >
      Current: {theme}
    </button>
  );
}

// 5. Wrap App with Provider
function App() {
  return (
    <ThemeProvider>
      <Header />
      <Main />
      <Footer />
    </ThemeProvider>
  );
}
```

### Complex Context Example (Auth)

```jsx
import { createContext, useContext, useState, useCallback, useMemo, useEffect } from 'react';

// Types
interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
}

// Create context
const AuthContext = createContext<AuthContextType | null>(null);

// Provider
function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Check auth status on mount
  useEffect(() => {
    async function checkAuth() {
      try {
        const token = localStorage.getItem('token');
        if (token) {
          const response = await fetch('/api/auth/me', {
            headers: { Authorization: `Bearer ${token}` }
          });

          if (response.ok) {
            const userData = await response.json();
            setUser(userData);
          } else {
            localStorage.removeItem('token');
          }
        }
      } catch (error) {
        console.error('Auth check failed:', error);
      } finally {
        setIsLoading(false);
      }
    }

    checkAuth();
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });

    if (!response.ok) {
      throw new Error('Login failed');
    }

    const { user, token } = await response.json();
    localStorage.setItem('token', token);
    setUser(user);
  }, []);

  const logout = useCallback(async () => {
    await fetch('/api/auth/logout', { method: 'POST' });
    localStorage.removeItem('token');
    setUser(null);
  }, []);

  const register = useCallback(async (data: RegisterData) => {
    const response = await fetch('/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      throw new Error('Registration failed');
    }

    const { user, token } = await response.json();
    localStorage.setItem('token', token);
    setUser(user);
  }, []);

  const value = useMemo(() => ({
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    register
  }), [user, isLoading, login, logout, register]);

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook
function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}

// Protected Route Component
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, isLoading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      navigate('/login');
    }
  }, [isAuthenticated, isLoading, navigate]);

  if (isLoading) {
    return <LoadingSpinner />;
  }

  return isAuthenticated ? children : null;
}

// Usage
function Dashboard() {
  const { user, logout } = useAuth();

  return (
    <div>
      <h1>Welcome, {user?.name}!</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />
      </Routes>
    </AuthProvider>
  );
}
```

### Context Performance Optimization

```jsx
// Problem: Context causes all consumers to re-render on ANY change
const AppContext = createContext();

function AppProvider({ children }) {
  const [user, setUser] = useState(null);
  const [theme, setTheme] = useState('light');
  const [notifications, setNotifications] = useState([]);

  // Every change causes ALL consumers to re-render!
  return (
    <AppContext.Provider value={{ user, theme, notifications, setUser, setTheme, setNotifications }}>
      {children}
    </AppContext.Provider>
  );
}

// Solution 1: Split contexts
const UserContext = createContext();
const ThemeContext = createContext();
const NotificationContext = createContext();

function AppProvider({ children }) {
  return (
    <UserProvider>
      <ThemeProvider>
        <NotificationProvider>
          {children}
        </NotificationProvider>
      </ThemeProvider>
    </UserProvider>
  );
}

// Solution 2: Separate state and dispatch contexts
const StateContext = createContext();
const DispatchContext = createContext();

function AppProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <StateContext.Provider value={state}>
      <DispatchContext.Provider value={dispatch}>
        {children}
      </DispatchContext.Provider>
    </StateContext.Provider>
  );
}

// Consumers that only dispatch don't re-render on state change
function AddButton() {
  const dispatch = useContext(DispatchContext);  // Stable reference
  return <button onClick={() => dispatch({ type: 'ADD' })}>Add</button>;
}

// Solution 3: Memoize components that use context
const UserProfile = React.memo(function UserProfile() {
  const { user } = useContext(UserContext);
  return <div>{user.name}</div>;
});
```

---

### How Context API Works — The Mental Model

Understanding the internals helps you avoid bugs and performance pitfalls.

```jsx
// ─────────────────────────────────────────────────────────────────
// THE PROBLEM CONTEXT SOLVES: Prop Drilling
//
// Without Context — you must pass data through EVERY level even if
// middle components don't need it:
//
// App (has user data)
//  └── Layout (passes user down, doesn't use it)
//       └── Sidebar (passes user down, doesn't use it)
//            └── UserMenu (passes user down, doesn't use it)
//                 └── UserAvatar ← ACTUALLY NEEDS user
//
// Each layer must accept and pass `user` as a prop = prop drilling
// ─────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────
// WITH CONTEXT: UserAvatar reads directly from the provider
//
// App → <UserProvider value={user}>  (stores user in Context)
//  └── Layout (no user prop needed)
//       └── Sidebar (no user prop needed)
//            └── UserMenu (no user prop needed)
//                 └── UserAvatar → useContext(UserContext) ← gets user directly
// ─────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────
// COMPLETE WORKING EXAMPLE: Shopping Cart Context
// Shows all patterns together with detailed inline comments
// ─────────────────────────────────────────────────────────────────

// 1. Define types for what the context will hold
// (Using JSDoc for plain JS — use TypeScript interfaces in TS projects)

/**
 * @typedef {Object} CartItem
 * @property {string} id
 * @property {string} name
 * @property {number} price
 * @property {number} quantity
 */

/**
 * @typedef {Object} CartContextValue
 * @property {CartItem[]} items - Items in the cart
 * @property {number} totalPrice - Computed total
 * @property {Function} addItem - Add or increment item
 * @property {Function} removeItem - Remove item completely
 * @property {Function} updateQuantity - Change item quantity
 * @property {Function} clearCart - Empty the cart
 */

// 2. Create the Context
// Pass null as default — we'll validate usage in the custom hook
const CartContext = createContext(null);

// 3. The Reducer — centralize all cart state logic
// Separate from the Provider so it's testable independently
function cartReducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existing = state.items.find(item => item.id === action.payload.id);

      if (existing) {
        // Item exists → increment quantity (immutable update with map)
        return {
          ...state,
          items: state.items.map(item =>
            item.id === action.payload.id
              ? { ...item, quantity: item.quantity + 1 }  // new object!
              : item
          )
        };
      }

      // New item → add to array (spread creates new array)
      return {
        ...state,
        items: [...state.items, { ...action.payload, quantity: 1 }]
      };
    }

    case 'REMOVE_ITEM':
      // Filter creates a new array without the removed item
      return {
        ...state,
        items: state.items.filter(item => item.id !== action.payload)
      };

    case 'UPDATE_QUANTITY':
      if (action.payload.quantity <= 0) {
        // Quantity 0 or less → remove item
        return {
          ...state,
          items: state.items.filter(item => item.id !== action.payload.id)
        };
      }
      return {
        ...state,
        items: state.items.map(item =>
          item.id === action.payload.id
            ? { ...item, quantity: action.payload.quantity }
            : item
        )
      };

    case 'CLEAR_CART':
      return { ...state, items: [] };

    default:
      return state; // unknown action → return current state unchanged
  }
}

// 4. The Provider Component — owns the state and exposes actions
function CartProvider({ children }) {
  const [state, dispatch] = useReducer(cartReducer, { items: [] });

  // Derived state: compute total price from items
  // useMemo prevents recomputing on every render — only when items change
  const totalPrice = useMemo(
    () => state.items.reduce((sum, item) => sum + item.price * item.quantity, 0),
    [state.items]  // ← only recompute when items array changes
  );

  // Action creators: useCallback ensures stable function references
  // Without useCallback, these functions are recreated each render
  // → context value changes → ALL consumers re-render (performance issue)
  const addItem = useCallback((item) => {
    dispatch({ type: 'ADD_ITEM', payload: item });
  }, []); // no dependencies — dispatch is stable from useReducer

  const removeItem = useCallback((itemId) => {
    dispatch({ type: 'REMOVE_ITEM', payload: itemId });
  }, []);

  const updateQuantity = useCallback((itemId, quantity) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { id: itemId, quantity } });
  }, []);

  const clearCart = useCallback(() => {
    dispatch({ type: 'CLEAR_CART' });
  }, []);

  // Build the context value — memoized to prevent unnecessary re-renders
  // Only changes when items or totalPrice actually change
  const contextValue = useMemo(() => ({
    items: state.items,
    totalPrice,
    addItem,
    removeItem,
    updateQuantity,
    clearCart
  }), [state.items, totalPrice, addItem, removeItem, updateQuantity, clearCart]);

  return (
    // Provide the memoized value to all children
    <CartContext.Provider value={contextValue}>
      {children}
    </CartContext.Provider>
  );
}

// 5. Custom Hook — the public API for consumers
// Always create a custom hook instead of exposing useContext directly
function useCart() {
  const context = useContext(CartContext);

  // This guard catches: components used outside CartProvider
  // React's error message without this would be: "Cannot read property
  // 'items' of null" — confusing! Our error message is clear.
  if (context === null) {
    throw new Error('useCart must be used within a <CartProvider>');
  }

  return context;
}

// 6. Consumer Components — use the hook, don't pass props down

// Product page — adds to cart
function ProductCard({ product }) {
  const { addItem } = useCart(); // ← reads only what it needs from context

  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>${product.price}</p>
      {/* When user clicks, dispatches ADD_ITEM action via context */}
      <button onClick={() => addItem(product)}>Add to Cart</button>
    </div>
  );
}

// Cart icon in header — shows count
function CartIcon() {
  const { items } = useCart();

  // Derived from context state — no props needed from parent
  const itemCount = items.reduce((total, item) => total + item.quantity, 0);

  return (
    <div className="cart-icon">
      🛒 {itemCount > 0 && <span className="badge">{itemCount}</span>}
    </div>
  );
}

// Cart drawer — shows all items
function CartDrawer() {
  const { items, totalPrice, removeItem, updateQuantity, clearCart } = useCart();

  if (items.length === 0) {
    return <div className="cart-empty">Your cart is empty</div>;
  }

  return (
    <div className="cart-drawer">
      {items.map(item => (
        <div key={item.id} className="cart-item">
          <span>{item.name}</span>

          {/* Update quantity — dispatches UPDATE_QUANTITY via context */}
          <input
            type="number"
            value={item.quantity}
            onChange={(e) => updateQuantity(item.id, parseInt(e.target.value))}
            min="0"
          />

          <span>${(item.price * item.quantity).toFixed(2)}</span>

          {/* Remove — dispatches REMOVE_ITEM via context */}
          <button onClick={() => removeItem(item.id)}>Remove</button>
        </div>
      ))}

      {/* Total price — computed via useMemo in Provider */}
      <div className="cart-total">Total: ${totalPrice.toFixed(2)}</div>

      <button onClick={clearCart}>Clear Cart</button>
    </div>
  );
}

// 7. Wire everything together at the app root
function App() {
  return (
    // CartProvider wraps entire app — both ProductCard and CartIcon
    // can communicate through context without direct connection
    <CartProvider>
      <header>
        <CartIcon />       {/* reads items count from context */}
      </header>

      <main>
        <ProductGrid />    {/* contains ProductCards that addItem to context */}
      </main>

      <aside>
        <CartDrawer />     {/* reads full cart from context */}
      </aside>
    </CartProvider>
  );
}

// ─────────────────────────────────────────────────────────────────
// WHEN TO USE CONTEXT vs OTHER STATE SOLUTIONS:
//
// USE CONTEXT when:
//   ✅ Data is needed by many components at different nesting levels
//   ✅ Data changes infrequently (theme, user auth, locale)
//   ✅ You want to avoid prop drilling through 3+ levels
//
// CONSIDER REDUX/ZUSTAND when:
//   ⚠️  Very frequent updates affecting many components
//   ⚠️  Complex state with many actions
//   ⚠️  Need time-travel debugging or middleware
//   ⚠️  Team already uses Redux
//
// KEEP AS LOCAL STATE when:
//   ✅ State belongs to one component or its direct children
//   ✅ No other component outside this subtree cares about it
// ─────────────────────────────────────────────────────────────────
```

---

## 10. React Router

### Basic Setup (React Router v6)

```jsx
import {
  BrowserRouter,
  Routes,
  Route,
  Link,
  NavLink,
  Navigate,
  useNavigate,
  useParams,
  useSearchParams,
  useLocation,
  Outlet
} from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
        <NavLink
          to="/products"
          className={({ isActive }) => isActive ? 'active' : ''}
        >
          Products
        </NavLink>
      </nav>

      <Routes>
        {/* Basic routes */}
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />

        {/* Route with params */}
        <Route path="/products/:productId" element={<ProductDetail />} />

        {/* Nested routes */}
        <Route path="/dashboard" element={<Dashboard />}>
          <Route index element={<DashboardHome />} />
          <Route path="profile" element={<Profile />} />
          <Route path="settings" element={<Settings />} />
        </Route>

        {/* Protected routes */}
        <Route element={<ProtectedRoutes />}>
          <Route path="/admin" element={<Admin />} />
          <Route path="/admin/users" element={<AdminUsers />} />
        </Route>

        {/* Redirect */}
        <Route path="/old-page" element={<Navigate to="/new-page" replace />} />

        {/* 404 catch-all */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}

// Using route params
function ProductDetail() {
  const { productId } = useParams();

  return <div>Product ID: {productId}</div>;
}

// Programmatic navigation
function LoginForm() {
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    await login();
    navigate('/dashboard');
    // Or with replace (no back button)
    navigate('/dashboard', { replace: true });
    // Or with state
    navigate('/dashboard', { state: { from: '/login' } });
  };

  return <form onSubmit={handleSubmit}>...</form>;
}

// Using search params (query string)
function ProductList() {
  const [searchParams, setSearchParams] = useSearchParams();

  const category = searchParams.get('category') || 'all';
  const sort = searchParams.get('sort') || 'name';

  return (
    <div>
      <select
        value={category}
        onChange={(e) => setSearchParams({ ...Object.fromEntries(searchParams), category: e.target.value })}
      >
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
      </select>
    </div>
  );
}

// Nested route with Outlet
function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <nav>
        <Link to="">Home</Link>
        <Link to="profile">Profile</Link>
        <Link to="settings">Settings</Link>
      </nav>
      <Outlet />  {/* Child routes render here */}
    </div>
  );
}

// Protected routes wrapper
function ProtectedRoutes() {
  const { isAuthenticated } = useAuth();
  const location = useLocation();

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <Outlet />;
}

// Access location state after redirect
function Dashboard() {
  const location = useLocation();
  const from = location.state?.from?.pathname || '/';

  return <div>Redirected from: {from}</div>;
}
```

### Data Loading with Loaders (React Router v6.4+)

```jsx
import {
  createBrowserRouter,
  RouterProvider,
  useLoaderData,
  useNavigation,
  defer,
  Await
} from 'react-router-dom';

// Define loader
async function productLoader({ params }) {
  const response = await fetch(`/api/products/${params.productId}`);
  if (!response.ok) {
    throw new Response('Product not found', { status: 404 });
  }
  return response.json();
}

// Define action (for forms)
async function updateProductAction({ request, params }) {
  const formData = await request.formData();
  const data = Object.fromEntries(formData);

  const response = await fetch(`/api/products/${params.productId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });

  return { ok: response.ok };
}

// Create router with data APIs
const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    errorElement: <ErrorBoundary />,
    children: [
      {
        index: true,
        element: <Home />,
      },
      {
        path: 'products/:productId',
        element: <ProductDetail />,
        loader: productLoader,
        action: updateProductAction,
      },
      {
        path: 'products',
        element: <ProductList />,
        loader: async () => {
          // Deferred loading for streaming
          return defer({
            products: fetch('/api/products').then(r => r.json()),
            categories: fetch('/api/categories').then(r => r.json())
          });
        }
      }
    ]
  }
]);

function App() {
  return <RouterProvider router={router} />;
}

// Using loader data
function ProductDetail() {
  const product = useLoaderData();
  const navigation = useNavigation();

  if (navigation.state === 'loading') {
    return <Spinner />;
  }

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
    </div>
  );
}

// Using deferred data
function ProductList() {
  const { products, categories } = useLoaderData();

  return (
    <div>
      <Suspense fallback={<Spinner />}>
        <Await resolve={products}>
          {(resolvedProducts) => (
            <ul>
              {resolvedProducts.map(p => (
                <li key={p.id}>{p.name}</li>
              ))}
            </ul>
          )}
        </Await>
      </Suspense>
    </div>
  );
}
```

---

## 11. Performance Optimization

### React.memo

```jsx
import { memo, useState, useCallback } from 'react';

// Without memo - re-renders on every parent render
function ExpensiveList({ items, onItemClick }) {
  console.log('ExpensiveList rendered');
  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => onItemClick(item)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}

// With memo - only re-renders when props change
const MemoizedList = memo(function ExpensiveList({ items, onItemClick }) {
  console.log('MemoizedList rendered');
  return (
    <ul>
      {items.map(item => (
        <li key={item.id} onClick={() => onItemClick(item)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
});

// Custom comparison function
const MemoizedListCustom = memo(
  function ExpensiveList({ items, onItemClick }) {
    return <ul>...</ul>;
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip re-render)
    // Return false if props changed (re-render)
    return prevProps.items.length === nextProps.items.length &&
           prevProps.items.every((item, i) => item.id === nextProps.items[i].id);
  }
);

// Parent component
function Parent() {
  const [count, setCount] = useState(0);
  const [items] = useState([{ id: 1, name: 'Item 1' }]);

  // ❌ New function created every render - defeats memo!
  const handleClick = (item) => {
    console.log(item);
  };

  // ✅ Stable function reference with useCallback
  const handleClickStable = useCallback((item) => {
    console.log(item);
  }, []);

  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>
        Count: {count}
      </button>

      {/* Re-renders every time count changes due to new handleClick */}
      <MemoizedList items={items} onItemClick={handleClick} />

      {/* Only re-renders when items changes */}
      <MemoizedList items={items} onItemClick={handleClickStable} />
    </div>
  );
}
```

### Code Splitting & Lazy Loading

```jsx
import { lazy, Suspense, startTransition } from 'react';

// Lazy load components
const Dashboard = lazy(() => import('./Dashboard'));
const Settings = lazy(() => import('./Settings'));
const AdminPanel = lazy(() => import('./AdminPanel'));

// With named exports
const Profile = lazy(() =>
  import('./UserComponents').then(module => ({ default: module.Profile }))
);

// Preload on hover/focus
const preloadSettings = () => import('./Settings');

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
        <Route path="/admin" element={<AdminPanel />} />
      </Routes>
    </Suspense>
  );
}

// Nested Suspense boundaries
function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>

      <Suspense fallback={<ChartSkeleton />}>
        <Charts />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <DataTable />
      </Suspense>
    </div>
  );
}

// Route-based code splitting with React Router
const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        path: 'dashboard',
        lazy: () => import('./Dashboard'),  // React Router's lazy loading
      },
      {
        path: 'settings',
        lazy: () => import('./Settings'),
      }
    ]
  }
]);
```

### Virtualization for Long Lists

```jsx
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef } from 'react';

function VirtualizedList({ items }) {
  const parentRef = useRef(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,  // Estimated row height
    overscan: 5,  // Number of items to render outside viewport
  });

  return (
    <div
      ref={parentRef}
      style={{ height: '400px', overflow: 'auto' }}
    >
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          width: '100%',
          position: 'relative'
        }}
      >
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}

// Can render 100,000+ items smoothly!
// Only ~20 DOM nodes at a time
```

### Profiling & Debugging Performance

```jsx
import { Profiler } from 'react';

function App() {
  const onRenderCallback = (
    id,                // Profiler id
    phase,             // "mount" | "update"
    actualDuration,    // Time spent rendering
    baseDuration,      // Estimated time without memoization
    startTime,         // When React started rendering
    commitTime,        // When React committed
    interactions       // Set of interactions
  ) => {
    console.log({
      id,
      phase,
      actualDuration,
      baseDuration,
      startTime,
      commitTime
    });
  };

  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Header />
      <Profiler id="MainContent" onRender={onRenderCallback}>
        <MainContent />
      </Profiler>
      <Footer />
    </Profiler>
  );
}

// React DevTools Profiler (recommended)
// 1. Install React DevTools browser extension
// 2. Open DevTools → Profiler tab
// 3. Click record, interact with app, stop recording
// 4. Analyze flame graph and ranked chart
```

---

## 12. Error Handling

### Error Boundaries

```jsx
import { Component } from 'react';

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  static getDerivedStateFromError(error) {
    // Update state to show fallback UI
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    // Log error to monitoring service
    console.error('Error caught:', error);
    console.error('Error info:', errorInfo);

    // Send to error tracking (Sentry, LogRocket, etc.)
    logErrorToService(error, errorInfo);

    this.setState({ errorInfo });
  }

  render() {
    if (this.state.hasError) {
      // Render fallback UI
      return this.props.fallback || (
        <div className="error-boundary">
          <h2>Something went wrong</h2>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.toString()}</pre>
            <pre>{this.state.errorInfo?.componentStack}</pre>
          </details>
          <button onClick={() => this.setState({ hasError: false })}>
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage
function App() {
  return (
    <ErrorBoundary fallback={<ErrorPage />}>
      <Header />
      <ErrorBoundary fallback={<ContentError />}>
        <MainContent />
      </ErrorBoundary>
      <Footer />
    </ErrorBoundary>
  );
}

// Note: Error boundaries do NOT catch:
// - Event handlers (use try/catch)
// - Async code (promises, setTimeout)
// - Server-side rendering
// - Errors in the boundary itself
```

### Error Handling in Event Handlers and Async Code

```jsx
function DataComponent() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  // Event handler error handling
  const handleClick = () => {
    try {
      doSomethingRisky();
    } catch (error) {
      setError(error.message);
      // Or show toast notification
      toast.error('Action failed');
    }
  };

  // Async error handling
  const fetchData = async () => {
    try {
      const response = await fetch('/api/data');
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      const json = await response.json();
      setData(json);
    } catch (error) {
      setError(error.message);
    }
  };

  // Using error boundary for async errors (React Query pattern)
  useEffect(() => {
    fetchData().catch(error => {
      // To propagate to error boundary, throw in render
      setError(error);
    });
  }, []);

  // Throw during render to trigger error boundary
  if (error) {
    throw new Error(error);
  }

  return <div>{data}</div>;
}
```

---

## Common Pitfalls & Best Practices

### Pitfall #1: Stale Closures in Effects

**❌ Problem:**
```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      console.log(count);  // Always logs 0 (stale!)
    }, 1000);
    return () => clearInterval(timer);
  }, []);  // Missing dependencies!
}
```

**✅ Solution:**
```jsx
function Counter() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      console.log(count);  // Logs current value
    }, 1000);
    return () => clearInterval(timer);
  }, [count]);  // Include dependency!
}
```

### Pitfall #2: Index as Key in Lists

**❌ Problem:**
```jsx
// When list is filtered/reordered, indexes change
// React gets confused about which item is which
{items.map((item, index) => (
  <Item key={index} item={item} />  // Index changes = wrong item updates
))}

// Example: If items = [A, B, C] then filter to [B, C]
// B is still at index 0, but was at index 1 before
// React thinks B is A! State/inputs get mixed up
```

**✅ Solution:**
```jsx
// Use stable, unique IDs
{items.map(item => (
  <Item key={item.id} item={item} />  // item.id never changes
))}
```

### Pitfall #3: Creating Objects/Arrays in Render

**❌ Problem:**
```jsx
function MyComponent({ items }) {
  // New object created every render!
  const style = { color: 'red', fontSize: '16px' };
  
  // New array created every render!
  const options = items.filter(i => i.active);

  return (
    <div style={style}>
      <List options={options} />  // List re-renders every time!
    </div>
  );
}
```

**✅ Solution:**
```jsx
// Move outside component or use useMemo
function MyComponent({ items }) {
  // Created once (outside render)
  const style = useMemo(
    () => ({ color: 'red', fontSize: '16px' }),
    []  // No dependencies = created once
  );
  
  // Memoize computed values
  const options = useMemo(
    () => items.filter(i => i.active),
    [items]  // Recalculate only when items changes
  );

  return (
    <div style={style}>
      <List options={options} />  // Only re-renders when items changes
    </div>
  );
}
```

### Pitfall #4: Missing useCallback Dependencies

**❌ Problem:**
```jsx
function Parent({ userId }) {
  const handleClick = useCallback(() => {
    console.log(userId);  // Stale userId if parent re-renders!
  }, []);  // Missing userId!

  return <Child onClick={handleClick} />;
}
// userId changed in parent, but callback still uses old userId
```

**✅ Solution:**
```jsx
function Parent({ userId }) {
  const handleClick = useCallback(() => {
    console.log(userId);  // Current userId
  }, [userId]);  // Include dependency!

  return <Child onClick={handleClick} />;
}
```

### Pitfall #5: setState Not Batched Properly

**❌ Problem:**
```jsx
function Form() {
  const [data, setData] = useState({});

  const handleChange = (e) => {
    // Each setState causes separate re-render = slow
    setData({ ...data, name: e.target.value });
    setData({ ...data, email: e.target.value });
    setData({ ...data, age: e.target.value });
    // 3 re-renders!
  };

  return <input onChange={handleChange} />;
}
```

**✅ Solution:**
```jsx
function Form() {
  // Option 1: Use single state update
  const [data, setData] = useState({});
  const handleChange = (e) => {
    const { name, value } = e.target;
    setData(prev => ({ ...prev, [name]: value }));
    // Still just 1 re-render (automatic batching in React 18)
  };

  // Option 2: Use React Hook Form (better for complex forms)
  const { register, handleSubmit, watch } = useForm();
  
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('name')} />
      <input {...register('email')} />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Best Practice #1: Use TypeScript for Props

```jsx
// ❌ NO TYPE SAFETY
function Button(props) {
  return <button onClick={props.onClick}>{props.children}</button>;
}

// ✅ WITH TYPESCRIPT
interface ButtonProps {
  onClick: () => void;
  children: React.ReactNode;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

function Button({ onClick, children, variant = 'primary', disabled }: ButtonProps) {
  return (
    <button 
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
    >
      {children}
    </button>
  );
}

// Now TypeScript catches mistakes:
// <Button onClick={() => {}} text="Hello" />  // ERROR: text should be children
// <Button onClick={() => {}} variant="danger" />  // ERROR: danger not allowed
```

### Best Practice #2: Use Composition Over Props Drilling

**❌ Prop Drilling (passing through many levels):**
```jsx
<App theme={theme}>
  <Sidebar theme={theme}>
    <Menu theme={theme}>
      <MenuItem theme={theme} />
    </Menu>
  </Sidebar>
</App>
```

**✅ Use Context:**
```jsx
const ThemeContext = createContext();

function App() {
  return (
    <ThemeContext.Provider value={theme}>
      <Sidebar />   {/* Don't pass theme */}
    </ThemeContext.Provider>
  );
}

function MenuItem() {
  const theme = useContext(ThemeContext);  // Access anywhere!
  return <button style={{ color: theme.color }}>Item</button>;
}
```

### Best Practice #3: Code Split Large Components

**❌ Monolithic Component (slow):**
```jsx
function Dashboard() {
  // 1000+ lines, does everything
  return (
    <div>
      <Analytics />
      <Reports />
      <ChartContainer />
      <BigTable />
    </div>
  );
}
```

**✅ Split into focused components:**
```jsx
// Split responsibility
const Analytics = lazy(() => import('./Analytics'));
const Reports = lazy(() => import('./Reports'));

function Dashboard() {
  return (
    <Suspense fallback={<Loading />}>
      <Analytics />
      <Reports />
    </Suspense>
  );
}
```

---

## 13. Testing React Applications

### Testing with Jest and React Testing Library

```jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { rest } from 'msw';
import { setupServer } from 'msw/node';

// Component to test
function Counter({ initialCount = 0 }) {
  const [count, setCount] = useState(initialCount);

  return (
    <div>
      <span data-testid="count">{count}</span>
      <button onClick={() => setCount(c => c + 1)}>Increment</button>
      <button onClick={() => setCount(c => c - 1)}>Decrement</button>
    </div>
  );
}

// Basic tests
describe('Counter', () => {
  test('renders initial count', () => {
    render(<Counter initialCount={5} />);
    expect(screen.getByTestId('count')).toHaveTextContent('5');
  });

  test('increments count on click', async () => {
    const user = userEvent.setup();
    render(<Counter />);

    await user.click(screen.getByRole('button', { name: /increment/i }));

    expect(screen.getByTestId('count')).toHaveTextContent('1');
  });

  test('decrements count on click', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={5} />);

    await user.click(screen.getByRole('button', { name: /decrement/i }));

    expect(screen.getByTestId('count')).toHaveTextContent('4');
  });
});

// Testing async components
const server = setupServer(
  rest.get('/api/user', (req, res, ctx) => {
    return res(ctx.json({ name: 'John Doe', email: 'john@example.com' }));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`/api/user/${userId}`)
      .then(res => res.json())
      .then(data => {
        setUser(data);
        setLoading(false);
      });
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  return <div>Hello, {user.name}!</div>;
}

describe('UserProfile', () => {
  test('loads and displays user', async () => {
    render(<UserProfile userId="123" />);

    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText(/hello, john doe/i)).toBeInTheDocument();
    });
  });

  test('handles error', async () => {
    server.use(
      rest.get('/api/user/:id', (req, res, ctx) => {
        return res(ctx.status(500));
      })
    );

    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument();
    });
  });
});

// Testing forms
describe('LoginForm', () => {
  test('submits form with user data', async () => {
    const handleSubmit = jest.fn();
    const user = userEvent.setup();

    render(<LoginForm onSubmit={handleSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'john@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'john@example.com',
      password: 'password123'
    });
  });

  test('shows validation errors', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={jest.fn()} />);

    await user.click(screen.getByRole('button', { name: /submit/i }));

    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    expect(screen.getByText(/password is required/i)).toBeInTheDocument();
  });
});

// Testing with context
function renderWithProviders(ui, { initialState, ...options } = {}) {
  function Wrapper({ children }) {
    return (
      <AuthProvider initialState={initialState}>
        <ThemeProvider>
          {children}
        </ThemeProvider>
      </AuthProvider>
    );
  }

  return render(ui, { wrapper: Wrapper, ...options });
}

test('renders user name when logged in', () => {
  renderWithProviders(<UserInfo />, {
    initialState: { user: { name: 'John' } }
  });

  expect(screen.getByText(/john/i)).toBeInTheDocument();
});
```

---

## 14. Advanced Patterns

### Compound Components

```jsx
import { createContext, useContext, useState } from 'react';

// Context for sharing state
const AccordionContext = createContext();

function Accordion({ children, defaultOpen = null }) {
  const [openItem, setOpenItem] = useState(defaultOpen);

  const toggle = (id) => {
    setOpenItem(prev => prev === id ? null : id);
  };

  return (
    <AccordionContext.Provider value={{ openItem, toggle }}>
      <div className="accordion">{children}</div>
    </AccordionContext.Provider>
  );
}

function AccordionItem({ id, children }) {
  const { openItem } = useContext(AccordionContext);
  const isOpen = openItem === id;

  return (
    <div className={`accordion-item ${isOpen ? 'open' : ''}`}>
      {children}
    </div>
  );
}

function AccordionTrigger({ id, children }) {
  const { toggle } = useContext(AccordionContext);

  return (
    <button
      className="accordion-trigger"
      onClick={() => toggle(id)}
    >
      {children}
    </button>
  );
}

function AccordionContent({ id, children }) {
  const { openItem } = useContext(AccordionContext);
  const isOpen = openItem === id;

  if (!isOpen) return null;

  return (
    <div className="accordion-content">
      {children}
    </div>
  );
}

// Attach sub-components
Accordion.Item = AccordionItem;
Accordion.Trigger = AccordionTrigger;
Accordion.Content = AccordionContent;

// Usage - Clean, flexible API
function FAQ() {
  return (
    <Accordion defaultOpen="q1">
      <Accordion.Item id="q1">
        <Accordion.Trigger id="q1">What is React?</Accordion.Trigger>
        <Accordion.Content id="q1">
          React is a JavaScript library for building user interfaces.
        </Accordion.Content>
      </Accordion.Item>

      <Accordion.Item id="q2">
        <Accordion.Trigger id="q2">What are hooks?</Accordion.Trigger>
        <Accordion.Content id="q2">
          Hooks let you use state and other features without classes.
        </Accordion.Content>
      </Accordion.Item>
    </Accordion>
  );
}
```

### Render Props Pattern

```jsx
// Mouse position tracker
function MouseTracker({ render }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handleMouseMove = (e) => {
      setPosition({ x: e.clientX, y: e.clientY });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return render(position);
}

// Usage
function App() {
  return (
    <MouseTracker
      render={({ x, y }) => (
        <div>
          Mouse position: ({x}, {y})
        </div>
      )}
    />
  );
}

// Children as function pattern (variation)
function Toggle({ children }) {
  const [on, setOn] = useState(false);

  return children({
    on,
    toggle: () => setOn(prev => !prev),
    setOn
  });
}

// Usage
function App() {
  return (
    <Toggle>
      {({ on, toggle }) => (
        <div>
          <button onClick={toggle}>
            {on ? 'ON' : 'OFF'}
          </button>
        </div>
      )}
    </Toggle>
  );
}

// Modern alternative: Custom hook (usually preferred)
function useToggle(initialValue = false) {
  const [on, setOn] = useState(initialValue);

  const toggle = useCallback(() => setOn(prev => !prev), []);

  return { on, toggle, setOn };
}
```

### Higher-Order Components (HOC)

```jsx
// HOC for adding loading state
function withLoading(WrappedComponent) {
  return function WithLoadingComponent({ isLoading, ...props }) {
    if (isLoading) {
      return <LoadingSpinner />;
    }
    return <WrappedComponent {...props} />;
  };
}

// HOC for adding authentication check
function withAuth(WrappedComponent) {
  return function WithAuthComponent(props) {
    const { isAuthenticated, isLoading } = useAuth();
    const navigate = useNavigate();

    useEffect(() => {
      if (!isLoading && !isAuthenticated) {
        navigate('/login');
      }
    }, [isAuthenticated, isLoading, navigate]);

    if (isLoading) return <LoadingSpinner />;
    if (!isAuthenticated) return null;

    return <WrappedComponent {...props} />;
  };
}

// Usage
const UserListWithLoading = withLoading(UserList);
const ProtectedDashboard = withAuth(Dashboard);

// HOC for data fetching
function withData(WrappedComponent, fetchData) {
  return function WithDataComponent(props) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
      fetchData(props)
        .then(setData)
        .catch(setError)
        .finally(() => setLoading(false));
    }, [props.id]); // Assuming id is the dependency

    return (
      <WrappedComponent
        {...props}
        data={data}
        loading={loading}
        error={error}
      />
    );
  };
}

// Note: Custom hooks are often preferred over HOCs in modern React
```

---

## 15. State Management Libraries

### Redux Toolkit (Modern Redux)

```jsx
import { configureStore, createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { Provider, useSelector, useDispatch } from 'react-redux';

// Create slice (reducer + actions)
const todosSlice = createSlice({
  name: 'todos',
  initialState: {
    items: [],
    status: 'idle',
    error: null
  },
  reducers: {
    addTodo: (state, action) => {
      // Immer allows "mutation" - actually creates immutable update
      state.items.push({
        id: Date.now(),
        text: action.payload,
        completed: false
      });
    },
    toggleTodo: (state, action) => {
      const todo = state.items.find(t => t.id === action.payload);
      if (todo) {
        todo.completed = !todo.completed;
      }
    },
    removeTodo: (state, action) => {
      state.items = state.items.filter(t => t.id !== action.payload);
    }
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchTodos.pending, (state) => {
        state.status = 'loading';
      })
      .addCase(fetchTodos.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.items = action.payload;
      })
      .addCase(fetchTodos.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.error.message;
      });
  }
});

// Async thunk
const fetchTodos = createAsyncThunk(
  'todos/fetchTodos',
  async () => {
    const response = await fetch('/api/todos');
    return response.json();
  }
);

// Configure store
const store = configureStore({
  reducer: {
    todos: todosSlice.reducer,
    // other slices...
  }
});

// Export actions
export const { addTodo, toggleTodo, removeTodo } = todosSlice.actions;

// Usage in components
function TodoList() {
  const dispatch = useDispatch();
  const { items, status, error } = useSelector(state => state.todos);

  useEffect(() => {
    dispatch(fetchTodos());
  }, [dispatch]);

  if (status === 'loading') return <Spinner />;
  if (status === 'failed') return <Error message={error} />;

  return (
    <ul>
      {items.map(todo => (
        <li key={todo.id}>
          <input
            type="checkbox"
            checked={todo.completed}
            onChange={() => dispatch(toggleTodo(todo.id))}
          />
          {todo.text}
          <button onClick={() => dispatch(removeTodo(todo.id))}>
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
}

// App wrapper
function App() {
  return (
    <Provider store={store}>
      <TodoList />
    </Provider>
  );
}
```

### Zustand (Lightweight Alternative)

```jsx
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Create store
const useTodoStore = create(
  persist(
    (set, get) => ({
      todos: [],
      filter: 'all',

      // Actions
      addTodo: (text) => set((state) => ({
        todos: [...state.todos, { id: Date.now(), text, completed: false }]
      })),

      toggleTodo: (id) => set((state) => ({
        todos: state.todos.map(todo =>
          todo.id === id ? { ...todo, completed: !todo.completed } : todo
        )
      })),

      removeTodo: (id) => set((state) => ({
        todos: state.todos.filter(todo => todo.id !== id)
      })),

      setFilter: (filter) => set({ filter }),

      // Computed values (using get)
      filteredTodos: () => {
        const { todos, filter } = get();
        switch (filter) {
          case 'active': return todos.filter(t => !t.completed);
          case 'completed': return todos.filter(t => t.completed);
          default: return todos;
        }
      }
    }),
    {
      name: 'todo-storage' // localStorage key
    }
  )
);

// Usage - No Provider needed!
function TodoList() {
  const todos = useTodoStore(state => state.filteredTodos());
  const addTodo = useTodoStore(state => state.addTodo);
  const toggleTodo = useTodoStore(state => state.toggleTodo);

  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id} onClick={() => toggleTodo(todo.id)}>
          {todo.text}
        </li>
      ))}
    </ul>
  );
}
```

### React Query (Server State)

```jsx
import { QueryClient, QueryClientProvider, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,  // 5 minutes
      cacheTime: 10 * 60 * 1000, // 10 minutes
      retry: 3,
      refetchOnWindowFocus: true
    }
  }
});

// Fetch function
const fetchTodos = async () => {
  const response = await fetch('/api/todos');
  if (!response.ok) throw new Error('Network response was not ok');
  return response.json();
};

const createTodo = async (newTodo) => {
  const response = await fetch('/api/todos', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(newTodo)
  });
  return response.json();
};

function TodoList() {
  const queryClient = useQueryClient();

  // Query
  const { data: todos, isLoading, error } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos
  });

  // Mutation
  const mutation = useMutation({
    mutationFn: createTodo,
    onSuccess: () => {
      // Invalidate and refetch
      queryClient.invalidateQueries({ queryKey: ['todos'] });
    },
    // Optimistic update
    onMutate: async (newTodo) => {
      await queryClient.cancelQueries({ queryKey: ['todos'] });
      const previousTodos = queryClient.getQueryData(['todos']);

      queryClient.setQueryData(['todos'], old => [...old, newTodo]);

      return { previousTodos };
    },
    onError: (err, newTodo, context) => {
      queryClient.setQueryData(['todos'], context.previousTodos);
    }
  });

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return (
    <div>
      <button onClick={() => mutation.mutate({ text: 'New Todo' })}>
        Add Todo
      </button>
      <ul>
        {todos.map(todo => (
          <li key={todo.id}>{todo.text}</li>
        ))}
      </ul>
    </div>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <TodoList />
    </QueryClientProvider>
  );
}
```

---

## 16. Server-Side Rendering

### Next.js Basics

```jsx
// pages/index.js - Static Generation (SSG)
export default function Home({ posts }) {
  return (
    <div>
      {posts.map(post => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.excerpt}</p>
        </article>
      ))}
    </div>
  );
}

export async function getStaticProps() {
  const res = await fetch('https://api.example.com/posts');
  const posts = await res.json();

  return {
    props: { posts },
    revalidate: 60 // Regenerate every 60 seconds (ISR)
  };
}

// pages/posts/[id].js - Dynamic SSG
export default function Post({ post }) {
  return (
    <article>
      <h1>{post.title}</h1>
      <div>{post.content}</div>
    </article>
  );
}

export async function getStaticPaths() {
  const res = await fetch('https://api.example.com/posts');
  const posts = await res.json();

  const paths = posts.map(post => ({
    params: { id: post.id.toString() }
  }));

  return {
    paths,
    fallback: 'blocking' // or true or false
  };
}

export async function getStaticProps({ params }) {
  const res = await fetch(`https://api.example.com/posts/${params.id}`);
  const post = await res.json();

  return {
    props: { post },
    revalidate: 60
  };
}

// pages/dashboard.js - Server-Side Rendering (SSR)
export default function Dashboard({ user, data }) {
  return (
    <div>
      <h1>Welcome, {user.name}</h1>
      <DashboardContent data={data} />
    </div>
  );
}

export async function getServerSideProps(context) {
  const { req, res, query } = context;

  // Check authentication
  const session = await getSession(req);
  if (!session) {
    return {
      redirect: {
        destination: '/login',
        permanent: false
      }
    };
  }

  // Fetch data for authenticated user
  const data = await fetchDashboardData(session.userId);

  return {
    props: {
      user: session.user,
      data
    }
  };
}
```

### Next.js 13+ App Router (Server Components)

```jsx
// app/page.tsx - Server Component (default)
async function Home() {
  // This runs on the server
  const posts = await fetch('https://api.example.com/posts').then(r => r.json());

  return (
    <div>
      {posts.map(post => (
        <article key={post.id}>
          <h2>{post.title}</h2>
        </article>
      ))}
    </div>
  );
}

// app/components/Counter.tsx - Client Component
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}

// Mixing Server and Client Components
// app/page.tsx
import { Counter } from './components/Counter';

async function Home() {
  const data = await fetchData(); // Server-side

  return (
    <div>
      <h1>{data.title}</h1>
      <Counter />  {/* Client component */}
    </div>
  );
}
```

---

## 17. Real-World Scenarios

### Scenario 1: Data Table with Filtering, Sorting, Pagination

```jsx
import { useState, useMemo, useCallback } from 'react';
import { useQuery } from '@tanstack/react-query';

function DataTable() {
  const [filters, setFilters] = useState({ search: '', status: 'all' });
  const [sorting, setSorting] = useState({ field: 'name', direction: 'asc' });
  const [pagination, setPagination] = useState({ page: 1, pageSize: 10 });

  // Fetch data
  const { data, isLoading } = useQuery({
    queryKey: ['users', filters, sorting, pagination],
    queryFn: () => fetchUsers({ ...filters, ...sorting, ...pagination })
  });

  // Column definitions
  const columns = useMemo(() => [
    { key: 'name', label: 'Name', sortable: true },
    { key: 'email', label: 'Email', sortable: true },
    { key: 'status', label: 'Status', sortable: false },
    { key: 'createdAt', label: 'Created', sortable: true }
  ], []);

  // Handle sort
  const handleSort = useCallback((field) => {
    setSorting(prev => ({
      field,
      direction: prev.field === field && prev.direction === 'asc' ? 'desc' : 'asc'
    }));
  }, []);

  // Handle filter
  const handleFilterChange = useCallback((key, value) => {
    setFilters(prev => ({ ...prev, [key]: value }));
    setPagination(prev => ({ ...prev, page: 1 })); // Reset to first page
  }, []);

  if (isLoading) return <TableSkeleton />;

  return (
    <div>
      {/* Filters */}
      <div className="filters">
        <input
          type="search"
          value={filters.search}
          onChange={(e) => handleFilterChange('search', e.target.value)}
          placeholder="Search..."
        />
        <select
          value={filters.status}
          onChange={(e) => handleFilterChange('status', e.target.value)}
        >
          <option value="all">All Status</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>

      {/* Table */}
      <table>
        <thead>
          <tr>
            {columns.map(col => (
              <th
                key={col.key}
                onClick={() => col.sortable && handleSort(col.key)}
                style={{ cursor: col.sortable ? 'pointer' : 'default' }}
              >
                {col.label}
                {sorting.field === col.key && (
                  <span>{sorting.direction === 'asc' ? ' ▲' : ' ▼'}</span>
                )}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.items.map(user => (
            <tr key={user.id}>
              <td>{user.name}</td>
              <td>{user.email}</td>
              <td>{user.status}</td>
              <td>{formatDate(user.createdAt)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Pagination */}
      <div className="pagination">
        <button
          disabled={pagination.page === 1}
          onClick={() => setPagination(p => ({ ...p, page: p.page - 1 }))}
        >
          Previous
        </button>
        <span>Page {pagination.page} of {data.totalPages}</span>
        <button
          disabled={pagination.page === data.totalPages}
          onClick={() => setPagination(p => ({ ...p, page: p.page + 1 }))}
        >
          Next
        </button>
      </div>
    </div>
  );
}
```

### Scenario 2: Real-Time Chat Application

```jsx
import { useState, useEffect, useRef, useCallback } from 'react';

function ChatRoom({ roomId, currentUser }) {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [typingUsers, setTypingUsers] = useState([]);

  const socketRef = useRef(null);
  const messagesEndRef = useRef(null);
  const typingTimeoutRef = useRef(null);

  // Connect to WebSocket
  useEffect(() => {
    socketRef.current = new WebSocket(`wss://chat.example.com/rooms/${roomId}`);

    socketRef.current.onopen = () => {
      setIsConnected(true);
      socketRef.current.send(JSON.stringify({
        type: 'join',
        userId: currentUser.id,
        roomId
      }));
    };

    socketRef.current.onmessage = (event) => {
      const data = JSON.parse(event.data);

      switch (data.type) {
        case 'message':
          setMessages(prev => [...prev, data.message]);
          break;
        case 'typing':
          setTypingUsers(data.users);
          break;
        case 'history':
          setMessages(data.messages);
          break;
      }
    };

    socketRef.current.onclose = () => {
      setIsConnected(false);
    };

    return () => {
      socketRef.current?.close();
    };
  }, [roomId, currentUser.id]);

  // Auto-scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Send message
  const sendMessage = useCallback((e) => {
    e.preventDefault();

    if (!newMessage.trim() || !isConnected) return;

    socketRef.current.send(JSON.stringify({
      type: 'message',
      content: newMessage,
      userId: currentUser.id,
      roomId
    }));

    setNewMessage('');
  }, [newMessage, isConnected, currentUser.id, roomId]);

  // Handle typing indicator
  const handleTyping = useCallback((e) => {
    setNewMessage(e.target.value);

    // Send typing indicator
    socketRef.current?.send(JSON.stringify({
      type: 'typing',
      userId: currentUser.id,
      roomId
    }));

    // Clear previous timeout
    clearTimeout(typingTimeoutRef.current);

    // Stop typing after 2 seconds
    typingTimeoutRef.current = setTimeout(() => {
      socketRef.current?.send(JSON.stringify({
        type: 'stopTyping',
        userId: currentUser.id,
        roomId
      }));
    }, 2000);
  }, [currentUser.id, roomId]);

  return (
    <div className="chat-room">
      <div className="connection-status">
        {isConnected ? '🟢 Connected' : '🔴 Disconnected'}
      </div>

      <div className="messages">
        {messages.map(msg => (
          <div
            key={msg.id}
            className={`message ${msg.userId === currentUser.id ? 'own' : ''}`}
          >
            <span className="author">{msg.userName}</span>
            <span className="content">{msg.content}</span>
            <span className="time">{formatTime(msg.timestamp)}</span>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {typingUsers.length > 0 && (
        <div className="typing-indicator">
          {typingUsers.map(u => u.name).join(', ')} {typingUsers.length === 1 ? 'is' : 'are'} typing...
        </div>
      )}

      <form onSubmit={sendMessage} className="message-input">
        <input
          type="text"
          value={newMessage}
          onChange={handleTyping}
          placeholder="Type a message..."
          disabled={!isConnected}
        />
        <button type="submit" disabled={!isConnected || !newMessage.trim()}>
          Send
        </button>
      </form>
    </div>
  );
}
```

---

## 18. Interview Questions & Answers

### Q1: What is the Virtual DOM and how does it work?

**Answer:**

"The Virtual DOM is a lightweight JavaScript representation of the actual DOM. When state changes in a React component:

1. React creates a new Virtual DOM tree representing the updated UI
2. React compares (diffs) the new tree with the previous one
3. React calculates the minimum set of changes needed
4. React batches and applies only those changes to the real DOM

This is faster than directly manipulating the DOM because:
- JavaScript object operations are faster than DOM operations
- Batching reduces expensive reflows and repaints
- The diffing algorithm (reconciliation) optimizes updates

The key insight is that React doesn't re-render the entire page - it surgically updates only what changed."

---

### Q2: Explain the difference between controlled and uncontrolled components.

**Answer:**

"**Controlled components** have their form state managed by React:

```jsx
function ControlledInput() {
  const [value, setValue] = useState('');
  return <input value={value} onChange={e => setValue(e.target.value)} />;
}
```

React is the 'single source of truth' - the input always reflects the state.

**Uncontrolled components** manage their own state internally:

```jsx
function UncontrolledInput() {
  const inputRef = useRef();
  return <input ref={inputRef} defaultValue='initial' />;
}
```

The DOM is the source of truth - you query it when needed.

**When to use each:**
- Controlled: Most cases - real-time validation, conditional submit buttons, input formatting
- Uncontrolled: File inputs (always uncontrolled), simple forms, integrating with non-React code

I prefer controlled components because they give you full control over the data and make the component behavior predictable."

---

### Q3: What are React Hooks and what problems do they solve?

**Answer:**

"Hooks are functions that let you use state and lifecycle features in functional components. Before Hooks, we needed class components for state.

**Problems they solve:**

1. **Sharing stateful logic**: Before, we used HOCs or render props, which created 'wrapper hell'. Now we use custom hooks.

2. **Complex lifecycle logic**: componentDidMount often had unrelated logic mixed together. useEffect lets you group related logic.

3. **Classes are confusing**: `this` binding, boilerplate code, hard to minify. Functions are simpler.

**Key Hooks:**
- useState: State management
- useEffect: Side effects (data fetching, subscriptions)
- useContext: Access context without Consumer
- useRef: DOM refs and mutable values
- useMemo/useCallback: Performance optimization
- useReducer: Complex state logic

**Rules of Hooks:**
1. Only call at top level (not in loops/conditions)
2. Only call from React functions (components or custom hooks)

Custom hooks let you extract reusable stateful logic - something impossible before without patterns like HOCs."

---

### Q4: How does useEffect differ from componentDidMount?

**Answer:**

"While useEffect with empty deps `[]` is similar to componentDidMount, there are important differences:

1. **Timing**: componentDidMount runs synchronously after DOM mutation. useEffect runs asynchronously after paint (doesn't block browser).

2. **Cleanup**: useEffect has built-in cleanup mechanism via return function. Class components needed separate componentWillUnmount.

3. **Dependencies**: useEffect can run on specific prop/state changes. componentDidUpdate needed manual comparison.

```jsx
// componentDidMount + componentDidUpdate + componentWillUnmount combined
useEffect(() => {
  // Setup (like componentDidMount)
  const subscription = subscribe(userId);

  // Cleanup (like componentWillUnmount)
  return () => subscription.unsubscribe();
}, [userId]); // Run when userId changes (like componentDidUpdate)
```

For synchronous effects after DOM mutation (like measuring elements), use `useLayoutEffect` which runs synchronously like componentDidMount."

---

### Q5: Explain React's reconciliation algorithm.

**Answer:**

"Reconciliation is how React decides what to update in the DOM. It uses a diffing algorithm with these heuristics:

1. **Different types = destroy and rebuild**: If an element changes type (div to span, or ComponentA to ComponentB), React destroys the entire subtree and rebuilds.

2. **Same type = update attributes**: If the type is the same, React updates only changed attributes and recurses on children.

3. **Keys for lists**: Keys help React identify which items changed/moved/were added/removed. Without keys, React re-renders the entire list.

**The algorithm:**

```jsx
// Before
<ul>
  <li>first</li>
  <li>second</li>
</ul>

// After (insert at beginning)
<ul>
  <li>zero</li>  // Without keys: React thinks 'first' changed to 'zero'
  <li>first</li> // React thinks 'second' changed to 'first'
  <li>second</li> // New element
</ul>

// With keys - React knows to insert new element
<ul>
  <li key='zero'>zero</li>
  <li key='first'>first</li>
  <li key='second'>second</li>
</ul>
```

This is why using index as key is problematic for dynamic lists - it breaks the optimization."

---

### Q6: How would you optimize a slow React application?

**Answer:**

"My optimization process:

1. **Profile first**: Use React DevTools Profiler to identify slow components. Don't optimize blindly.

2. **Avoid unnecessary re-renders**:
   - `React.memo` for components with expensive renders
   - `useMemo` for expensive calculations
   - `useCallback` for callbacks passed to children

3. **Code splitting**:
   - `React.lazy` and `Suspense` for route-based splitting
   - Dynamic imports for heavy components

4. **Virtualization**: For long lists, use react-window or react-virtual to render only visible items.

5. **State management**:
   - Keep state close to where it's used
   - Split context to avoid unnecessary re-renders
   - Consider Zustand or Jotai for fine-grained reactivity

6. **Image optimization**: Lazy load images, use proper formats (WebP), implement progressive loading.

7. **Network**: Use React Query for caching, implement optimistic updates.

8. **Production build**: Ensure you're using production builds (not development).

The key is measuring before and after - I've seen people add memoization everywhere thinking it helps, but it can actually hurt performance if the comparison cost exceeds the render cost."

---

### Q7: What is the Context API and when would you use it vs Redux?

**Answer:**

"Context provides a way to pass data through the component tree without prop drilling.

**When to use Context:**
- Theme data (light/dark mode)
- User authentication state
- Locale/language settings
- Feature flags
- Any truly global state that doesn't change frequently

**When Context falls short:**
- Frequent updates cause all consumers to re-render
- No built-in middleware/devtools
- No time-travel debugging

**When to use Redux (or Zustand/Jotai):**
- Complex state with many updates
- Need middleware (logging, async actions)
- Need time-travel debugging
- State used in many components with different slices

**My approach:**
- Small apps: Context + useReducer
- Medium apps: Zustand (simpler API, good devtools)
- Large apps: Redux Toolkit (proven at scale, excellent devtools)
- Server state: React Query (not Redux!)

I don't use Redux for server-cached data anymore - React Query handles that better with caching, background refetching, and optimistic updates."

---

### Q8: Explain the useCallback and useMemo hooks.

**Answer:**

"Both are optimization hooks that memoize values between renders.

**useMemo**: Memoizes a computed value
```jsx
const expensiveValue = useMemo(() => {
  return items.filter(i => i.price > 100).sort((a, b) => a.price - b.price);
}, [items]);
```

**useCallback**: Memoizes a function reference
```jsx
const handleClick = useCallback((id) => {
  console.log('Clicked:', id);
}, []);
```

**When to use:**

1. **Expensive calculations**: useMemo for computations that are slow
2. **Referential equality**: When passing to `React.memo` children or as useEffect dependencies
3. **Preventing child re-renders**: useCallback for event handlers passed to memoized children

**When NOT to use:**
- Simple calculations (overhead exceeds benefit)
- Primitives (numbers, strings are cheap to compare)
- Functions not passed to children or deps

```jsx
// ❌ Over-optimization
const value = useMemo(() => a + b, [a, b]);

// ✅ Good use case
const sortedItems = useMemo(() =>
  [...items].sort((a, b) => a.date - b.date),
  [items]
);
```

Remember: premature optimization is the root of all evil. Profile first, optimize specific bottlenecks."

---

### Q9: How do you handle errors in React?

**Answer:**

"React has different error handling strategies for different scenarios:

**1. Error Boundaries (render errors)**:
```jsx
class ErrorBoundary extends Component {
  state = { hasError: false };

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return <ErrorFallback />;
    }
    return this.props.children;
  }
}
```

**2. Event handler errors**: Use try/catch
```jsx
const handleClick = () => {
  try {
    riskyOperation();
  } catch (error) {
    toast.error('Something went wrong');
  }
};
```

**3. Async errors**: Handle in the promise chain or async/await
```jsx
useEffect(() => {
  fetchData()
    .catch(error => setError(error));
}, []);
```

**Best practices:**
- Wrap routes with error boundaries for isolation
- Use multiple boundaries for different UI sections
- Log errors to monitoring service (Sentry, LogRocket)
- Show user-friendly messages, not technical details
- Provide recovery options (retry, go home)

Note: Error boundaries don't catch errors in event handlers, async code, SSR, or in the boundary itself."

---

### Q10: Describe the component lifecycle in React.

**Answer:**

"With Hooks, we think of lifecycle in terms of synchronization rather than mount/update/unmount phases:

```jsx
function Component({ userId }) {
  // 'Mount': Initial setup
  useEffect(() => {
    console.log('Component mounted');
    return () => console.log('Component will unmount');
  }, []);

  // 'Update': Sync with external system
  useEffect(() => {
    const subscription = subscribe(userId);
    return () => subscription.unsubscribe();
  }, [userId]); // Re-runs when userId changes

  // Every render
  useEffect(() => {
    console.log('After every render');
  });
}
```

**Mental model:**
- Don't think 'lifecycle methods' - think 'synchronize this effect with these dependencies'
- Effects run after render, not blocking paint
- Cleanup runs before next effect and on unmount

**For class components (legacy reference):**
1. Mounting: constructor → getDerivedStateFromProps → render → componentDidMount
2. Updating: getDerivedStateFromProps → shouldComponentUpdate → render → getSnapshotBeforeUpdate → componentDidUpdate
3. Unmounting: componentWillUnmount

The Hooks mental model is simpler and more powerful - effects are about synchronization, not lifecycle phases."

---

## Quick Reference

### Hook Rules
1. Only call at top level
2. Only call from React functions
3. Custom hooks must start with `use`

### Performance Checklist
- [ ] Profile before optimizing
- [ ] Use React.memo for expensive renders
- [ ] Use useMemo/useCallback appropriately
- [ ] Code split routes
- [ ] Virtualize long lists
- [ ] Optimize images
- [ ] Use production builds

### State Management Decision
| Scenario | Solution |
|----------|----------|
| Simple component state | useState |
| Complex component state | useReducer |
| Shared UI state | Context |
| Complex global state | Redux/Zustand |
| Server data | React Query |
| Form state | React Hook Form |

---

## React Interview Preparation Checklist

### Fundamental Concepts (Must Know)

- [ ] Virtual DOM: How it works and why it matters
- [ ] React Element vs Component
- [ ] JSX: What it is and how it compiles
- [ ] Props: Read-only, can be any JavaScript value
- [ ] State: Mutable, triggers re-render
- [ ] Rendering: Why components re-render
- [ ] Key prop: Why it's critical for lists

### Hooks & State Management

- [ ] useState: How to manage component state
- [ ] useEffect: Dependency array, cleanup function
- [ ] useCallback: When and why to use it
- [ ] useMemo: Memoizing expensive calculations
- [ ] useRef: DOM access and mutable values
- [ ] Custom hooks: Creating reusable logic
- [ ] Context API: Avoiding prop drilling
- [ ] useReducer: Complex state logic

### Performance & Optimization

- [ ] React.memo: Preventing unnecessary re-renders
- [ ] useMemo vs useCallback: Differences
- [ ] Code splitting with React.lazy
- [ ] Virtual scrolling for large lists
- [ ] Bundle size analysis
- [ ] Identifying performance bottlenecks

### Architecture & Patterns

- [ ] Composition over inheritance
- [ ] Smart vs dumb components
- [ ] Render props pattern
- [ ] Custom hooks pattern
- [ ] Higher-order components (legacy)
- [ ] Thinking in React (component structure)

### Testing Skills

- [ ] Unit testing with Jest
- [ ] Component testing with React Testing Library
- [ ] Testing hooks with @testing-library/react
- [ ] Mocking modules and API calls
- [ ] Testing async code
- [ ] Testing error boundaries

### Real-World Skills

- [ ] Forms: React Hook Form or similar
- [ ] API calls: Fetch, Axios, React Query
- [ ] Routing: React Router
- [ ] State management: Redux, Zustand, Jotai
- [ ] Authentication: JWT, session management
- [ ] Error handling: Error boundaries, try/catch

---

## React Quick Reference Guide

### Common Patterns at a Glance

```jsx
// ===== STATE MANAGEMENT =====
// Simple state
const [count, setCount] = useState(0);

// Complex state
const [state, dispatch] = useReducer(reducer, initialState);

// Shared state (avoid prop drilling)
const AppContext = createContext();
<AppContext.Provider value={data}>
  <Child />  {/* Can access from anywhere */}
</AppContext.Provider>

// ===== EFFECTS =====
// Run once on mount
useEffect(() => { /* ... */ }, []);

// Run when dependencies change
useEffect(() => { /* ... */ }, [dependency]);

// Run on every render
useEffect(() => { /* ... */ });

// Cleanup
useEffect(() => {
  return () => { /* cleanup */ };
}, []);

// ===== PERFORMANCE =====
// Skip re-render if props same
const MemoComponent = React.memo(Component);

// Memoize expensive calculation
const value = useMemo(() => expensiveCalc(), [deps]);

// Memoize callback
const handleClick = useCallback(() => {}, [deps]);

// ===== LISTS =====
// Always use stable ID, not index
{items.map(item => (
  <Item key={item.id} item={item} />
))}

// ===== CONDITIONAL RENDERING =====
// Ternary (best for mutually exclusive)
{condition ? <ComponentA /> : <ComponentB />}

// Logical AND (show if true)
{condition && <Component />}

// Logical OR (fallback)
{value || 'default'}

// Switch
{(() => {
  switch(status) {
    case 'loading': return <Loading />;
    case 'error': return <Error />;
    default: return <Content />;
  }
})()}

// ===== HANDLING EVENTS =====
// Click handler
<button onClick={handleClick}>Click</button>

// Form input
<input onChange={(e) => setValue(e.target.value)} />

// Prevent default
<form onSubmit={(e) => { e.preventDefault(); }}>

// Event object
function handleChange(e) {
  e.target.value  // Current value
  e.target.name   // Input name
  e.stopPropagation()  // Stop bubbling
}

// ===== FORMS =====
// Controlled input
const [value, setValue] = useState('');
<input value={value} onChange={e => setValue(e.target.value)} />

// Form with React Hook Form
const { register, handleSubmit, watch } = useForm();
<form onSubmit={handleSubmit(onSubmit)}>
  <input {...register('name')} />
  <button type="submit">Submit</button>
</form>

// ===== ASYNC DATA =====
// useEffect with fetch
useEffect(() => {
  let mounted = true;
  fetch('/api/data')
    .then(r => r.json())
    .then(data => mounted && setData(data));
  return () => { mounted = false; };
}, []);

// React Query (better)
const { data, isLoading, error } = useQuery(['key'], fetchFn);

// ===== ROUTING =====
import { BrowserRouter, Routes, Route } from 'react-router-dom';

<BrowserRouter>
  <Routes>
    <Route path="/" element={<Home />} />
    <Route path="/about" element={<About />} />
  </Routes>
</BrowserRouter>

// Navigate
const navigate = useNavigate();
navigate('/path');

// Get params
const { id } = useParams();
```

### Common Mistakes to Avoid

| Mistake | Problem | Solution |
|---------|---------|----------|
| Index as key | List items mixed up | Use stable unique ID |
| Missing useEffect deps | Stale values | Include all dependencies |
| setState in render | Infinite loop | Move to useEffect |
| Creating objects in render | Child re-renders | Use useMemo |
| Missing cleanup | Memory leaks | Return cleanup function |
| Direct mutation | React can't detect | Use setState |
| Complex state in useState | Hard to manage | Use useReducer |
| Prop drilling | Hard to maintain | Use Context API |

### Performance Tips (In Order of Impact)

1. **Identify real bottleneck**: Use React DevTools Profiler
2. **Lazy load routes**: `React.lazy()` + `Suspense`
3. **Memoize expensive components**: `React.memo`
4. **Virtual scroll large lists**: `react-window`
5. **Debounce/throttle expensive operations**: `lodash-es`
6. **Code split by route**: `webpack` or `Vite`
7. **Use `useMemo` sparingly**: Only when proven necessary
8. **Optimize images**: Use modern formats (WebP)
9. **MinifyCSS/JS**: Build process handles this

### Testing Patterns

```jsx
// Setup
import { render, screen, fireEvent, waitFor } from '@testing-library/react';

// Render component
render(<Component />);

// Query elements
screen.getByRole('button', { name: /submit/i });
screen.getByText(/hello/i);
screen.getByPlaceholderText(/search/i);
screen.getByTestId('custom-id');

// Interact
fireEvent.click(button);
userEvent.type(input, 'text');

// Wait for async
await waitFor(() => {
  expect(screen.getByText(/success/i)).toBeInTheDocument();
});

// Mock fetch
jest.mock('global', { fetch: jest.fn() });
```

---

## Summary

This guide covered React comprehensively:

1. **Fundamentals**: Virtual DOM, JSX, components, props
2. **State**: useState, useReducer, state patterns
3. **Hooks**: useEffect, useRef, useMemo, useCallback, custom hooks
4. **Patterns**: Compound components, render props, HOCs
5. **Performance**: Memoization, code splitting, virtualization
6. **State Management**: Context, Redux, Zustand, React Query
7. **Testing**: Jest, React Testing Library, MSW
8. **SSR**: Next.js, Server Components

**Key Interview Tips:**
- Explain the "why" behind your choices
- Discuss trade-offs
- Show real-world experience
- Know when NOT to use certain patterns
- Performance: always measure first
