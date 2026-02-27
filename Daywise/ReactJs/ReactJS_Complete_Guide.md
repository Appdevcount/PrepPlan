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
   - [useImperativeHandle + forwardRef](#useimperativehandle--forwardref--exposing-component-apis)
   - [useSyncExternalStore](#usesyncexternalstore--subscribe-to-external-stores)
   - [useDebugValue](#usedebugvalue--label-custom-hooks-in-devtools)
   - [React 19 — New APIs & Features](#react-19--new-apis--features)
   - [Portals (createPortal)](#portals--render-outside-the-parent-dom)
   - [React 18 — Automatic Batching & flushSync](#react-18--automatic-batching--flushsync)
6. [Component Lifecycle](#6-component-lifecycle)
7. [Event Handling](#7-event-handling)
8. [Forms & Controlled Components](#8-forms--controlled-components)
9. [Context API](#9-context-api)
10. [React Router](#10-react-router)
11. [Performance Optimization](#11-performance-optimization)
12. [Error Handling](#12-error-handling)
13. [Testing React Applications](#13-testing-react-applications)
14. [Advanced Patterns](#14-advanced-patterns)
    - [Container / Presentational Pattern](#container--presentational-pattern)
    - [Observer Pattern — Event Bus / Pub-Sub](#observer-pattern--event-bus--pub-sub)
    - [Builder Pattern — Fluent API](#builder-pattern--fluent-api-for-complex-components)
15. [State Management Libraries](#15-state-management-libraries)
16. [Server-Side Rendering](#16-server-side-rendering)
    - [Next.js App Router — Deep Dive](#nextjs-app-router--deep-dive)
17. [Real-World Scenarios](#17-real-world-scenarios)
18. [Interview Questions & Answers](#18-interview-questions--answers)
19. [Formik - Complete Form Management](#19-formik---complete-form-management)
20. [Yup - Schema Validation](#20-yup---schema-validation)
21. [React-Bootstrap - UI Component Library](#21-react-bootstrap---ui-component-library)
22. [Common Useful Libraries](#22-common-useful-libraries)
23. [Jest Unit Testing - Mental Model & Samples](#23-jest-unit-testing---mental-model--samples)
24. [Styling in React — Complete Guide](#24-styling-in-react--complete-guide)
    - [CSS Modules](#css-modules--scoped-css)
    - [Styled Components](#styled-components--css-in-js)
    - [Tailwind CSS](#tailwind-css-with-react)
25. [Accessibility (a11y) in React](#25-accessibility-a11y-in-react)
    - [Semantic HTML & ARIA](#semantic-html--aria)
    - [Focus Management](#focus-management)
    - [Keyboard Navigation](#keyboard-navigation)

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

> **Mental Model:** Every time React re-renders a component, it re-runs the entire function body — every `const`, every calculation, every function definition is brand new. `useMemo` and `useCallback` are React's **cache** for values and functions across renders. Think of it like a sticky note: "if the inputs haven't changed, reuse the answer from last time instead of recalculating."

---

#### The Core Problem: Why Functions Break `React.memo`

React re-renders a component whenever its parent re-renders. To prevent that, you wrap the child with `React.memo` — it skips re-rendering if props haven't changed. But there's a catch: **functions are objects in JS, so a new function is created every render, even if it looks identical.**

```jsx
// ❌ THE PROBLEM — breaks React.memo silently
function Parent() {
  const [count, setCount] = useState(0);

  // Every render creates a NEW function object at a new memory address
  // Even though the code inside is identical
  const handleClick = (item) => {
    console.log('clicked', item);
  };

  return (
    <>
      <button onClick={() => setCount(c => c + 1)}>Parent re-renders</button>
      {/* Child gets a NEW handleClick prop every render → React.memo is useless */}
      <ExpensiveList onItemClick={handleClick} />
    </>
  );
}

const ExpensiveList = React.memo(({ onItemClick }) => {
  console.log('ExpensiveList rendered'); // This fires on EVERY parent render!
  return <div>...</div>;
});
```

**Step-by-step trace of what happens without useCallback:**

```
Render #1:
  handleClick → memory address 0x001 (new function)
  ExpensiveList receives onItemClick=0x001 → renders ✅

User clicks "Parent re-renders" button → count changes

Render #2:
  handleClick → memory address 0x002 (DIFFERENT function — same code, new object)
  ExpensiveList receives onItemClick=0x002
  React.memo compares: 0x001 !== 0x002 → RE-RENDERS ❌ (wasted!)

Render #3:
  handleClick → memory address 0x003
  ExpensiveList → RE-RENDERS ❌ (wasted again!)
```

---

#### `useCallback` — Stabilize a Function Reference

`useCallback(fn, deps)` returns the **same function object** across renders as long as the dependencies haven't changed.

```jsx
// ✅ THE FIX — stable function reference
function Parent() {
  const [count, setCount] = useState(0);
  const [selectedId, setSelectedId] = useState(null);

  // handleClick is memoized — same reference as long as setSelectedId doesn't change
  // setSelectedId comes from useState, so it's always stable — deps array is []
  const handleClick = useCallback((item) => {
    setSelectedId(item.id); // uses state setter, not state value
  }, []); // [] = no dependencies = never recreated

  return (
    <>
      <button onClick={() => setCount(c => c + 1)}>Parent re-renders</button>
      {/* onItemClick is the SAME function reference every render */}
      <ExpensiveList onItemClick={handleClick} />
    </>
  );
}
```

**Step-by-step trace with useCallback:**

```
Render #1:
  handleClick → memoized at address 0x001
  ExpensiveList receives onItemClick=0x001 → renders ✅

User clicks "Parent re-renders" → count changes

Render #2:
  handleClick → deps [] unchanged → returns SAME 0x001
  ExpensiveList receives onItemClick=0x001
  React.memo compares: 0x001 === 0x001 → SKIPS render ✅

Render #3:
  Same → SKIPS render ✅
```

---

#### Dependency Array Rules

The deps array tells React: "only give me a new function if one of these values changed."

```jsx
// ❌ WRONG — stale closure: userId inside function is always the initial value
const fetchUser = useCallback(() => {
  fetch(`/api/user/${userId}`); // captures userId from first render only
}, []); // missing userId in deps

// ✅ CORRECT — function gets a new reference when userId changes
const fetchUser = useCallback(() => {
  fetch(`/api/user/${userId}`);
}, [userId]); // re-created only when userId changes

// ✅ BEST when possible — pass the value as an argument, keep deps empty
const fetchUser = useCallback((id) => {
  fetch(`/api/user/${id}`);
}, []); // no deps needed — id is a parameter, not a closed-over variable
```

---

#### Real-World Scenario: Search Filter + Memoized List

```jsx
import { useState, useCallback, memo } from 'react';

// Child is expensive — wrapping with memo so it only re-renders when its own props change
const ProductRow = memo(({ product, onAddToCart }) => {
  console.log(`ProductRow [${product.name}] rendered`);
  return (
    <div>
      <span>{product.name} — ${product.price}</span>
      <button onClick={() => onAddToCart(product)}>Add to Cart</button>
    </div>
  );
});

function ProductList() {
  const [search, setSearch] = useState('');
  const [cart, setCart] = useState([]);

  // ✅ Stable reference — setCart from useState is always stable, so deps is []
  // Without useCallback: every keystroke in the search box re-renders ALL ProductRow components
  // With useCallback: ProductRow re-renders only when an item is actually added to cart
  const handleAddToCart = useCallback((product) => {
    setCart(prev => [...prev, product]);
  }, []);

  const products = [
    { id: 1, name: 'Laptop', price: 999 },
    { id: 2, name: 'Phone', price: 499 },
    { id: 3, name: 'Tablet', price: 299 },
  ];

  const filtered = products.filter(p =>
    p.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div>
      <input
        value={search}
        onChange={e => setSearch(e.target.value)} // typing here causes re-renders
        placeholder="Search products..."
      />
      <p>Cart: {cart.length} items</p>
      {filtered.map(p => (
        // onAddToCart is the same reference every render → ProductRow skips re-render
        <ProductRow key={p.id} product={p} onAddToCart={handleAddToCart} />
      ))}
    </div>
  );
}
```

---

#### `useMemo` — Cache an Expensive Calculation

`useMemo(fn, deps)` caches the **return value** of a function. Use it when a calculation is genuinely expensive (not `a + b`, but sorting/filtering large arrays, building complex derived state).

```jsx
import { useMemo, useState } from 'react';

function Analytics({ orders }) {
  const [currency, setCurrency] = useState('USD');

  // ❌ Without useMemo: this runs on EVERY render (even currency toggle changes it)
  // If orders has 10,000 items, this is slow
  const stats = {
    total: orders.reduce((sum, o) => sum + o.amount, 0),
    max: Math.max(...orders.map(o => o.amount)),
    byStatus: orders.reduce((acc, o) => {
      acc[o.status] = (acc[o.status] || 0) + 1;
      return acc;
    }, {})
  };

  // ✅ With useMemo: only recalculates when `orders` changes
  // Changing `currency` doesn't trigger recalculation
  const memoStats = useMemo(() => ({
    total: orders.reduce((sum, o) => sum + o.amount, 0),
    max: Math.max(...orders.map(o => o.amount)),
    byStatus: orders.reduce((acc, o) => {
      acc[o.status] = (acc[o.status] || 0) + 1;
      return acc;
    }, {})
  }), [orders]); // recalculate only when orders array changes

  return (
    <div>
      <button onClick={() => setCurrency(c => c === 'USD' ? 'EUR' : 'USD')}>
        Toggle Currency
      </button>
      <p>Total: {memoStats.total} {currency}</p>
      <p>Max single order: {memoStats.max}</p>
    </div>
  );
}
```

**Second use of `useMemo`: stabilize object/array references for `useEffect` deps**

```jsx
// ❌ PROBLEM — options is a new object every render → useEffect fires on every render
function UserProfile({ userId, role }) {
  const options = { userId, role, includeDeleted: false }; // new object each render

  useEffect(() => {
    fetchUser(options); // runs every render — infinite loop risk!
  }, [options]); // options reference changes every time
}

// ✅ FIX — useMemo stabilizes the object reference
function UserProfile({ userId, role }) {
  const options = useMemo(
    () => ({ userId, role, includeDeleted: false }),
    [userId, role] // only new object when userId or role actually changes
  );

  useEffect(() => {
    fetchUser(options); // runs only when userId or role changes
  }, [options]);
}
```

---

#### Decision Guide: Should I use useCallback / useMemo?

```
Is the function passed as a prop to a React.memo child?
  YES → useCallback ✅
  NO  → Is the function in a useEffect/useMemo dependency array?
          YES → useCallback ✅
          NO  → Skip it, plain function is fine

Is the calculation expensive (sorting, filtering >100 items, complex reduce)?
  YES → useMemo ✅
  NO  → Is the result an object/array used in a dependency array?
          YES → useMemo ✅ (prevents reference instability)
          NO  → Skip it, inline calculation is fine
```

---

#### Common Pitfalls

```jsx
// ❌ PITFALL 1: Object/array in deps — creates new reference every render
// This defeats the purpose — handleSubmit is recreated every render
const handleSubmit = useCallback(() => {
  sendData(formData);
}, [formData]); // if formData = { name, email } object, this always changes!

// ✅ FIX: destructure to primitives
const handleSubmit = useCallback(() => {
  sendData({ name, email });
}, [name, email]); // primitives — stable comparison

// ❌ PITFALL 2: useCallback inside loops/conditions (breaks Rules of Hooks)
items.forEach(item => {
  const handler = useCallback(() => {}, []); // ILLEGAL
});

// ✅ FIX: define one handler that accepts the item as argument
const handleItemAction = useCallback((itemId) => {
  // use itemId
}, []);
// Then in JSX: onClick={() => handleItemAction(item.id)}

// ❌ PITFALL 3: Memoizing everything "just in case" — adds overhead with no benefit
const add = useCallback((a, b) => a + b, []); // math is not expensive, skip this
const label = useMemo(() => `Hello ${name}`, [name]); // string template is not expensive
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

### useImperativeHandle + forwardRef — Exposing Component APIs

> **Mental Model:** `forwardRef` lets a parent component "reach into" a child and use its DOM node or exposed methods. `useImperativeHandle` lets the child decide *exactly* what the parent can access — instead of exposing the raw DOM node, you expose a clean API.

```jsx
import { useRef, useImperativeHandle, forwardRef, useState } from 'react';

// ═══════════════════════════════════════════════════════════════
// forwardRef — Pass ref through a component to a DOM node
// ═══════════════════════════════════════════════════════════════

// Without forwardRef: parent can't pass ref to child's DOM node
// With forwardRef: parent CAN get the DOM node

// ✅ PATTERN 1: Forward ref to a DOM element
const FancyInput = forwardRef(function FancyInput({ label, ...props }, ref) {
  //                                                                    ↑ ref comes as 2nd argument
  return (
    <div className="fancy-input">
      <label>{label}</label>
      <input ref={ref} {...props} />  {/* ← ref wired to actual DOM input */}
    </div>
  );
});

// Parent usage:
function LoginForm() {
  const inputRef = useRef(null);

  const focusInput = () => {
    inputRef.current.focus();  // ← directly focuses the child's input DOM node
  };

  return (
    <div>
      <FancyInput ref={inputRef} label="Email" type="email" />
      <button onClick={focusInput}>Focus Email</button>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// useImperativeHandle — Expose a custom API instead of raw DOM
//
// Problem: forwardRef exposes the entire DOM node — parent can
// call any DOM method. That's too much power.
//
// Solution: useImperativeHandle lets you expose ONLY what you want.
// The component stays encapsulated.
// ═══════════════════════════════════════════════════════════════

// ✅ PATTERN 2: Custom imperative API with useImperativeHandle
const VideoPlayer = forwardRef(function VideoPlayer({ src }, ref) {
  const videoRef = useRef(null);
  const [isPlaying, setIsPlaying] = useState(false);

  // useImperativeHandle(ref, () => object, [deps])
  // ↑ ref: the forwarded ref
  // ↑ factory: returns the object exposed to the parent
  useImperativeHandle(ref, () => ({
    // Parent can call these methods:
    play() {
      videoRef.current.play();
      setIsPlaying(true);
    },
    pause() {
      videoRef.current.pause();
      setIsPlaying(false);
    },
    seek(seconds) {
      videoRef.current.currentTime = seconds;
    },
    get duration() {
      return videoRef.current?.duration ?? 0;
    },
    get isPlaying() {
      return isPlaying;
    }
    // Parent CANNOT access: videoRef.current.volume, .src, .load(), etc.
    // The DOM node is completely hidden — clean API!
  }), [isPlaying]);  // ← re-create exposed object when isPlaying changes

  return (
    <video
      ref={videoRef}
      src={src}
      onPlay={() => setIsPlaying(true)}
      onPause={() => setIsPlaying(false)}
    />
  );
});

// Parent usage — clean, controlled API:
function PlayerControls() {
  const playerRef = useRef(null);

  return (
    <div>
      <VideoPlayer ref={playerRef} src="/movie.mp4" />

      <button onClick={() => playerRef.current.play()}>▶ Play</button>
      <button onClick={() => playerRef.current.pause()}>⏸ Pause</button>
      <button onClick={() => playerRef.current.seek(30)}>+30s</button>
      <p>Duration: {playerRef.current?.duration}s</p>
    </div>
  );
}

// ✅ PATTERN 3: forwardRef with TypeScript
interface InputHandle {
  focus: () => void;
  clear: () => void;
  getValue: () => string;
}

interface InputProps {
  placeholder?: string;
  defaultValue?: string;
}

const SmartInput = forwardRef<InputHandle, InputProps>(
  function SmartInput({ placeholder, defaultValue }, ref) {
    const inputRef = useRef<HTMLInputElement>(null);

    useImperativeHandle(ref, () => ({
      focus: () => inputRef.current?.focus(),
      clear: () => {
        if (inputRef.current) inputRef.current.value = '';
      },
      getValue: () => inputRef.current?.value ?? '',
    }));

    return (
      <input
        ref={inputRef}
        placeholder={placeholder}
        defaultValue={defaultValue}
      />
    );
  }
);

// TypeScript usage — fully typed API:
function Form() {
  const inputRef = useRef<InputHandle>(null);

  const handleSubmit = () => {
    const value = inputRef.current?.getValue();  // ← typed!
    console.log(value);
    inputRef.current?.clear();
  };

  return (
    <>
      <SmartInput ref={inputRef} placeholder="Search..." />
      <button onClick={handleSubmit}>Submit</button>
    </>
  );
}

// ─────────────────────────────────────────────────────────────────
// When to use forwardRef + useImperativeHandle:
// ✅ Building reusable UI components (Input, Modal, VideoPlayer)
// ✅ Focus management (programmatic focus for accessibility)
// ✅ Triggering animations imperatively
// ✅ Integrating with third-party imperative APIs (charts, maps)
//
// ❌ Avoid for data passing — use props and callbacks instead
// ❌ Avoid as a workaround for lifting state up
// ─────────────────────────────────────────────────────────────────
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

### useSyncExternalStore — Subscribe to External Stores

> **Mental Model:** `useSyncExternalStore` is how you safely read from *external* state stores (Redux, Zustand internals, browser APIs like `navigator.onLine`) in a Concurrent React world. It ensures your component always sees a consistent snapshot of external state — no "tearing" between renders.

```jsx
import { useSyncExternalStore } from 'react';

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 1: Subscribe to browser online/offline status
// ═══════════════════════════════════════════════════════════════
function useOnlineStatus() {
  const isOnline = useSyncExternalStore(
    // 1. subscribe(callback): subscribe to changes, return unsubscribe
    (callback) => {
      window.addEventListener('online', callback);
      window.addEventListener('offline', callback);
      return () => {
        window.removeEventListener('online', callback);
        window.removeEventListener('offline', callback);
      };
    },
    // 2. getSnapshot(): return current value from the external store
    () => navigator.onLine,
    // 3. getServerSnapshot(): value during SSR (optional)
    () => true,  // assume online on server
  );

  return isOnline;
}

// Usage:
function StatusBar() {
  const isOnline = useOnlineStatus();
  return (
    <div className={isOnline ? 'online' : 'offline'}>
      {isOnline ? '🟢 Online' : '🔴 Offline'}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 2: Simple external store (like a mini Zustand/Redux)
// ═══════════════════════════════════════════════════════════════
// Build a tiny external store:
function createStore(initialState) {
  let state = initialState;
  const listeners = new Set();

  return {
    getState: () => state,
    setState: (newState) => {
      state = typeof newState === 'function' ? newState(state) : newState;
      listeners.forEach(l => l());  // notify all subscribers
    },
    subscribe: (listener) => {
      listeners.add(listener);
      return () => listeners.delete(listener);  // return unsubscribe
    }
  };
}

// Create a shared store:
const cartStore = createStore({ items: [], total: 0 });

// Hook that subscribes to the cart store:
function useCart() {
  return useSyncExternalStore(
    cartStore.subscribe,            // subscribe
    cartStore.getState,             // getSnapshot
  );
}

// Any component that uses useCart() will re-render when cart changes:
function CartIcon() {
  const cart = useCart();
  return <span>🛒 {cart.items.length}</span>;
}

function CartTotal() {
  const cart = useCart();
  return <span>Total: ${cart.total}</span>;
}

// Update from anywhere:
function AddToCartButton({ product }) {
  const addItem = () => {
    cartStore.setState(prev => ({
      items: [...prev.items, product],
      total: prev.total + product.price
    }));
  };
  return <button onClick={addItem}>Add to Cart</button>;
}

// ─────────────────────────────────────────────────────────────────
// useSyncExternalStore vs useState/useEffect pattern:
//
// ❌ Old way (prone to tearing in Concurrent React):
// const [value, setValue] = useState(externalStore.getState());
// useEffect(() => externalStore.subscribe(() => setValue(externalStore.getState())), []);
//
// ✅ New way (React's official API, tear-free):
// const value = useSyncExternalStore(store.subscribe, store.getState);
// ─────────────────────────────────────────────────────────────────
```

### useDebugValue — Label Custom Hooks in DevTools

> **Mental Model:** `useDebugValue` adds a label to your custom hook that appears in React DevTools. When debugging, instead of seeing an opaque value, you see a meaningful description of your hook's state.

```jsx
import { useDebugValue, useState, useEffect } from 'react';

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 1: Simple debug label
// ═══════════════════════════════════════════════════════════════
function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  // In DevTools, this hook will show:
  // useOnlineStatus: "Online"  or  "Offline"
  useDebugValue(isOnline ? 'Online' : 'Offline');
  //            ↑ This label only appears in React DevTools — no runtime cost

  useEffect(() => {
    const handler = () => setIsOnline(navigator.onLine);
    window.addEventListener('online', handler);
    window.addEventListener('offline', handler);
    return () => {
      window.removeEventListener('online', handler);
      window.removeEventListener('offline', handler);
    };
  }, []);

  return isOnline;
}

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 2: Deferred formatting (performance optimization)
// Only compute the display value if DevTools is open
// ═══════════════════════════════════════════════════════════════
function useUser(userId) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // Second arg: format function — only called when DevTools inspects this
  // Avoids expensive formatting on every render
  useDebugValue(
    user,
    (u) => u ? `${u.name} (${u.role}) — loaded` : 'Loading...'
    //          ↑ Only called if React DevTools are open and inspecting
  );

  return user;
}

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 3: Structured debug info
// ═══════════════════════════════════════════════════════════════
function useFormField(initialValue) {
  const [value, setValue] = useState(initialValue);
  const [touched, setTouched] = useState(false);
  const [error, setError] = useState(null);

  // DevTools shows: { value: "john@", touched: true, valid: false }
  useDebugValue({ value, touched, valid: !error });

  return {
    value,
    touched,
    error,
    onChange: (e) => setValue(e.target.value),
    onBlur: () => setTouched(true),
  };
}

// ─────────────────────────────────────────────────────────────────
// Rules for useDebugValue:
// ✅ Only use in custom hooks (not in components)
// ✅ Only for hooks you share with others (libraries, shared code)
// ✅ Use the format function for expensive computations
// ❌ Don't use in simple hooks (adds noise with no benefit)
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

---

### React 19 — New APIs & Features

React 19 (released December 2024) introduced major new APIs focused on server integration, optimistic UI, and simplifying common patterns.

#### `use()` Hook — Unwrap Promises and Context

> **Mental Model:** `use()` is like `await` but inside components. It lets you "unwrap" a Promise or Context value directly in render — React will automatically suspend while waiting.

```jsx
import { use, Suspense, createContext } from 'react';

// ═══════════════════════════════════════════════════════════════
// use() with Promises — "async components" without useEffect
// ═══════════════════════════════════════════════════════════════

// Create a promise (usually from a data fetching library)
const userPromise = fetch('/api/user/1').then(r => r.json());

// Component that "awaits" the promise — React suspends until resolved
function UserProfile() {
  // use() suspends the component until the promise resolves
  const user = use(userPromise);
  //    ↑ Like await, but in render — no useEffect/useState needed!

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}

// MUST wrap with Suspense to handle the loading state:
function App() {
  return (
    <Suspense fallback={<p>Loading user...</p>}>
      <UserProfile />
    </Suspense>
  );
}

// ✅ Can be called conditionally (unlike other hooks!)
function ConditionalFetch({ shouldFetch, promise }) {
  if (!shouldFetch) return <p>Skipping fetch</p>;

  // use() CAN be inside a conditional — major difference from other hooks
  const data = use(promise);
  return <div>{data.value}</div>;
}

// ═══════════════════════════════════════════════════════════════
// use() with Context — alternative to useContext
// ═══════════════════════════════════════════════════════════════
const ThemeContext = createContext('light');

function Button({ children }) {
  // use() can read context too — same as useContext but can be conditional
  const theme = use(ThemeContext);
  //    ↑ use(Context) is identical to useContext(Context)
  //    but can be called inside if/else/loops

  return (
    <button className={`btn-${theme}`}>{children}</button>
  );
}
```

#### `useActionState` — Form Actions with State

> **Mental Model:** `useActionState` replaces the `useState + async handler` pattern for forms. It gives you the form's pending state, last result, and wires everything to React 19 Server Actions or client async functions.

```jsx
import { useActionState } from 'react';

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 1: Client-side form with async action
// ═══════════════════════════════════════════════════════════════

// The "action" function: receives previous state + FormData
async function submitContactForm(prevState, formData) {
  const name = formData.get('name');
  const email = formData.get('email');
  const message = formData.get('message');

  try {
    await fetch('/api/contact', {
      method: 'POST',
      body: JSON.stringify({ name, email, message }),
      headers: { 'Content-Type': 'application/json' }
    });
    return { success: true, message: 'Message sent! We\'ll be in touch.' };
  } catch (error) {
    return { success: false, message: 'Failed to send. Please try again.' };
  }
}

function ContactForm() {
  const [state, submitAction, isPending] = useActionState(
    //   ↑ last return value    ↑ wrapped action   ↑ true while action runs
    submitContactForm,
    null,  // initial state
  );

  return (
    <form action={submitAction}>  {/* ← pass action directly to form */}
      <input name="name" placeholder="Your name" required />
      <input name="email" type="email" placeholder="Email" required />
      <textarea name="message" placeholder="Message" required />

      {/* Show result message */}
      {state && (
        <p className={state.success ? 'success' : 'error'}>
          {state.message}
        </p>
      )}

      <button type="submit" disabled={isPending}>
        {isPending ? 'Sending...' : 'Send Message'}
      </button>
    </form>
  );
}

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 2: Login form with validation errors
// ═══════════════════════════════════════════════════════════════
async function loginAction(prevState, formData) {
  const email = formData.get('email');
  const password = formData.get('password');

  if (!email || !password) {
    return { errors: { email: !email ? 'Required' : null, password: !password ? 'Required' : null } };
  }

  const result = await authenticate(email, password);
  if (!result.ok) {
    return { errors: { general: 'Invalid credentials' } };
  }

  // Redirect on success
  redirect('/dashboard');
}

function LoginForm() {
  const [state, formAction, isPending] = useActionState(loginAction, { errors: {} });

  return (
    <form action={formAction}>
      <input name="email" type="email" />
      {state.errors?.email && <span className="error">{state.errors.email}</span>}

      <input name="password" type="password" />
      {state.errors?.password && <span className="error">{state.errors.password}</span>}

      {state.errors?.general && <p className="error">{state.errors.general}</p>}

      <button disabled={isPending}>{isPending ? 'Signing in...' : 'Sign In'}</button>
    </form>
  );
}
```

#### `useFormStatus` — Pending State for Nested Form Elements

> **Mental Model:** `useFormStatus` lets *child components* inside a form know if the form is submitting — without prop drilling. The submit button doesn't need the pending state passed as a prop.

```jsx
import { useFormStatus } from 'react-dom';

// ═══════════════════════════════════════════════════════════════
// BEFORE React 19: prop drilling for loading state
// ═══════════════════════════════════════════════════════════════
function SubmitButton({ isPending }) {  // ← had to pass isPending as prop
  return (
    <button disabled={isPending}>
      {isPending ? 'Saving...' : 'Save'}
    </button>
  );
}

// ═══════════════════════════════════════════════════════════════
// AFTER React 19: useFormStatus reads from parent form
// ═══════════════════════════════════════════════════════════════
function SubmitButton() {
  const { pending, data, method, action } = useFormStatus();
  //      ↑ true while parent form is submitting
  //             ↑ FormData submitted
  //                    ↑ 'get' or 'post'
  //                           ↑ action URL or function

  return (
    <button
      type="submit"
      disabled={pending}
      aria-busy={pending}
    >
      {pending ? (
        <>
          <Spinner /> Saving...
        </>
      ) : 'Save Changes'}
    </button>
  );
}

// SubmitButton auto-detects its parent form's state — no props needed!
function ProfileForm() {
  return (
    <form action={saveProfileAction}>
      <input name="name" />
      <input name="bio" />
      <SubmitButton />  {/* ← No isPending prop needed! */}
    </form>
  );
}

// ─────────────────────────────────────────────────────────────────
// IMPORTANT: useFormStatus only works for components INSIDE a <form>
// It must be a direct or indirect child of the form element.
// ─────────────────────────────────────────────────────────────────
```

#### `useOptimistic` — Instant UI Feedback

> **Mental Model:** `useOptimistic` lets you show the *result* of an action immediately in the UI, before the server confirms it. If the action succeeds, React seamlessly transitions to the real data. If it fails, it automatically reverts.

```jsx
import { useOptimistic, useState } from 'react';

// ═══════════════════════════════════════════════════════════════
// EXAMPLE: Like button with optimistic update
// ═══════════════════════════════════════════════════════════════
function LikeButton({ postId, initialLikes, initialLiked }) {
  const [post, setPost] = useState({
    likes: initialLikes,
    liked: initialLiked
  });

  // useOptimistic(currentState, updateFn)
  // → returns [optimisticState, addOptimistic]
  const [optimisticPost, setOptimisticPost] = useOptimistic(
    post,
    // Merge function: how to apply the optimistic update
    (currentPost, optimisticValue) => ({
      ...currentPost,
      likes: currentPost.liked
        ? currentPost.likes - 1   // un-like: remove one
        : currentPost.likes + 1,  // like: add one
      liked: !currentPost.liked,  // toggle
    })
  );

  const handleLike = async () => {
    // Step 1: Immediately show optimistic update (no await!)
    setOptimisticPost({});  // triggers the merge function above

    // Step 2: Actually call the server
    try {
      const result = await toggleLike(postId);
      // Step 3: Update real state with server response
      setPost(result);
    } catch {
      // If server fails, optimistic update automatically reverts
      console.error('Failed to like post');
    }
  };

  return (
    <button onClick={handleLike} className={optimisticPost.liked ? 'liked' : ''}>
      {optimisticPost.likes}
      {/* Shows instantly, syncs with server in background */}
    </button>
  );
}

// ═══════════════════════════════════════════════════════════════
// EXAMPLE: Optimistic todo list (add items instantly)
// ═══════════════════════════════════════════════════════════════
function TodoList({ initialTodos }) {
  const [todos, setTodos] = useState(initialTodos);

  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo) => [...state, { ...newTodo, pending: true }]
    //                                                  ↑ mark as pending for visual indicator
  );

  const addTodo = async (formData) => {
    const text = formData.get('text');
    const tempTodo = { id: `temp-${Date.now()}`, text, completed: false };

    // Optimistically add (shows immediately with loading indicator)
    addOptimisticTodo(tempTodo);

    // Actually save to server
    const savedTodo = await createTodo(text);
    setTodos(prev => [...prev, savedTodo]);
  };

  return (
    <div>
      <ul>
        {optimisticTodos.map(todo => (
          <li key={todo.id} style={{ opacity: todo.pending ? 0.6 : 1 }}>
            {todo.text}
            {todo.pending && ' (saving...)'}
          </li>
        ))}
      </ul>
      <form action={addTodo}>
        <input name="text" placeholder="Add todo..." />
        <button type="submit">Add</button>
      </form>
    </div>
  );
}
```

#### `ref` as a Prop (React 19 — No More `forwardRef`)

```jsx
// React 19: ref is now a regular prop — forwardRef is no longer needed!

// ─────────────────────────────────────────────────────────────────
// BEFORE React 19 (still works, but deprecated):
// ─────────────────────────────────────────────────────────────────
const Input = forwardRef(function Input({ label }, ref) {
  return <input ref={ref} />;
});

// ─────────────────────────────────────────────────────────────────
// AFTER React 19 (simpler — ref is just a prop!):
// ─────────────────────────────────────────────────────────────────
function Input({ label, ref }) {  // ← ref received as regular prop
  return (
    <div>
      <label>{label}</label>
      <input ref={ref} />
    </div>
  );
}

// Usage stays the same:
function Form() {
  const inputRef = useRef(null);
  return <Input label="Email" ref={inputRef} />;
}

// TypeScript:
interface InputProps {
  label: string;
  ref?: React.Ref<HTMLInputElement>;
}

function Input({ label, ref }: InputProps) {
  return <input ref={ref} />;
}
```

#### React Compiler (React 19) — Automatic Memoization

> **Mental Model:** The React Compiler analyzes your code at build time and automatically adds `useMemo`, `useCallback`, and `memo` where needed. You write plain React — the compiler optimizes it.

```jsx
// BEFORE React Compiler: manually add memoization everywhere
const Component = memo(function Component({ user, onUpdate }) {
  const processedUser = useMemo(
    () => processUser(user),
    [user]
  );
  const handleClick = useCallback(
    () => onUpdate(user.id),
    [onUpdate, user.id]
  );

  return <div onClick={handleClick}>{processedUser.name}</div>;
});

// AFTER React Compiler: write plain code — compiler handles it!
function Component({ user, onUpdate }) {
  // Compiler automatically detects that processUser(user) is expensive
  // and memoizes it — NO useMemo needed!
  const processedUser = processUser(user);

  // Compiler sees this function only needs to change when onUpdate/user.id changes
  // and automatically stabilizes it — NO useCallback needed!
  const handleClick = () => onUpdate(user.id);

  return <div onClick={handleClick}>{processedUser.name}</div>;
}

// Enable React Compiler in vite.config.ts:
// import reactCompiler from 'babel-plugin-react-compiler';
// plugins: [react({ babel: { plugins: [reactCompiler] } })]

// ─────────────────────────────────────────────────────────────────
// React 19 Summary:
// ┌─────────────────────────────────────────────────────────────┐
// │  New Hook/API    │  Replaces / Improves                     │
// ├─────────────────────────────────────────────────────────────┤
// │  use()           │  useEffect + useState for async data     │
// │  useActionState  │  useState + async handler for forms      │
// │  useFormStatus   │  Prop drilling pending state to buttons  │
// │  useOptimistic   │  Manual optimistic state management      │
// │  ref as prop     │  forwardRef() wrapper                    │
// │  React Compiler  │  Manual useMemo/useCallback/memo         │
// └─────────────────────────────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────
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

---

## Portals — Render Outside the Parent DOM

> **Mental Model:** A Portal is a "teleporter" for React components. The component lives in the React tree (inherits context, events bubble up normally), but its DOM output appears *somewhere else* in the HTML — like `document.body`. Essential for modals, tooltips, and dropdowns that need to escape CSS `overflow: hidden` or `z-index` stacking contexts.

```jsx
import { createPortal } from 'react-dom';
import { useState, useEffect, useRef } from 'react';

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 1: Basic Modal with Portal
// ═══════════════════════════════════════════════════════════════
function Modal({ isOpen, onClose, title, children }) {
  // ESC key to close
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  // Prevent body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  if (!isOpen) return null;

  // createPortal(jsx, domNode)
  // → Renders jsx into domNode, but keeps it in React's component tree
  return createPortal(
    // The JSX to render:
    <div
      className="modal-overlay"
      onClick={onClose}                   // Click backdrop to close
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div
        className="modal-content"
        onClick={e => e.stopPropagation()}  // Don't close when clicking inside
      >
        <div className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button onClick={onClose} aria-label="Close modal">X</button>
        </div>
        <div className="modal-body">
          {children}
        </div>
      </div>
    </div>,
    // Where to render it in the actual DOM:
    document.body
    // ↑ Renders directly in <body>, outside any nested div with overflow:hidden!
  );
}

// Usage:
function App() {
  const [showModal, setShowModal] = useState(false);

  return (
    // Even if this div has overflow: hidden, the modal escapes it!
    <div style={{ overflow: 'hidden', position: 'relative' }}>
      <button onClick={() => setShowModal(true)}>Open Modal</button>

      {/* Modal renders in document.body — NOT inside the overflow:hidden div */}
      <Modal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        title="Confirm Delete"
      >
        <p>Are you sure you want to delete this item?</p>
        <button onClick={() => { /* delete */ setShowModal(false); }}>
          Yes, Delete
        </button>
        <button onClick={() => setShowModal(false)}>Cancel</button>
      </Modal>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// EXAMPLE 2: Tooltip Portal
// ═══════════════════════════════════════════════════════════════
function Tooltip({ children, text }) {
  const [visible, setVisible] = useState(false);
  const [position, setPosition] = useState({ top: 0, left: 0 });
  const targetRef = useRef(null);

  const showTooltip = () => {
    const rect = targetRef.current.getBoundingClientRect();
    setPosition({
      top: rect.bottom + window.scrollY + 8,
      left: rect.left + window.scrollX + rect.width / 2,
    });
    setVisible(true);
  };

  return (
    <>
      <span
        ref={targetRef}
        onMouseEnter={showTooltip}
        onMouseLeave={() => setVisible(false)}
      >
        {children}
      </span>

      {visible && createPortal(
        <div
          style={{
            position: 'absolute',
            top: position.top,
            left: position.left,
            transform: 'translateX(-50%)',
            background: '#333',
            color: 'white',
            padding: '4px 8px',
            borderRadius: '4px',
            zIndex: 9999,
            pointerEvents: 'none',
          }}
        >
          {text}
        </div>,
        document.body
      )}
    </>
  );
}

// ═══════════════════════════════════════════════════════════════
// KEY FACTS ABOUT PORTALS:
// ─────────────────────────────────────────────────────────────────
// ✅ Events bubble through React tree, NOT through DOM tree
//    → Clicking inside a portal modal DOES trigger onClick on React parent
// ✅ Context works across portals (Context.Provider in parent works in portal)
// ✅ React lifecycle works normally (effects, state, etc.)
// ✅ Can render into any DOM node: document.body, document.getElementById('modal-root')
// ❌ Portal DOM output is in a different place in HTML than React tree
// ─────────────────────────────────────────────────────────────────
```

---

## React 18 — Automatic Batching & `flushSync`

> **Mental Model:** React 18 batches *all* state updates — even inside `setTimeout`, Promises, and native event listeners — into a single re-render. This is a free performance win. `flushSync` is the escape hatch to force an immediate update when batching is wrong for your use case.

```jsx
import { useState, flushSync } from 'react';

// ═══════════════════════════════════════════════════════════════
// AUTOMATIC BATCHING (React 18 default)
// ═══════════════════════════════════════════════════════════════

function Counter() {
  const [count, setCount] = useState(0);
  const [flag, setFlag] = useState(false);

  // React 17: Inside event handlers — already batched (1 re-render)
  // React 18: ALL of these scenarios are now batched:

  // ✅ SCENARIO 1: React event handler (batched in both 17 and 18)
  const handleClick = () => {
    setCount(c => c + 1);  // ┐
    setFlag(f => !f);      // ┘ → 1 re-render (was already batched)
  };

  // ✅ SCENARIO 2: setTimeout (NEW in React 18 — was NOT batched in React 17!)
  const handleTimeout = () => {
    setTimeout(() => {
      setCount(c => c + 1);  // ┐
      setFlag(f => !f);      // ┘ → 1 re-render in React 18
                              //     2 re-renders in React 17!
    }, 1000);
  };

  // ✅ SCENARIO 3: Promise/async (NEW in React 18)
  const handleAsync = async () => {
    await fetchData();
    setCount(c => c + 1);  // ┐
    setFlag(f => !f);      // ┘ → 1 re-render in React 18
  };

  // ✅ SCENARIO 4: Native event listeners (NEW in React 18)
  useEffect(() => {
    const el = document.getElementById('my-btn');
    el.addEventListener('click', () => {
      setCount(c => c + 1);  // ┐
      setFlag(f => !f);      // ┘ → 1 re-render in React 18
    });
  }, []);
}

// ═══════════════════════════════════════════════════════════════
// flushSync — Force synchronous (unbatched) update
// Use when you NEED the DOM to update before the next line
// ═══════════════════════════════════════════════════════════════
function ScrollToBottom() {
  const [messages, setMessages] = useState([]);
  const listRef = useRef(null);

  const addMessage = (text) => {
    // ❌ Without flushSync: DOM hasn't updated yet when we try to scroll
    // setMessages(prev => [...prev, text]);
    // listRef.current.scrollTop = listRef.current.scrollHeight; // wrong height!

    // ✅ With flushSync: forces React to update the DOM synchronously first
    flushSync(() => {
      setMessages(prev => [...prev, text]);
    });
    // At this point, the DOM is updated — scroll works correctly!
    listRef.current.scrollTop = listRef.current.scrollHeight;
  };

  return (
    <div>
      <ul ref={listRef} style={{ height: '200px', overflow: 'auto' }}>
        {messages.map((msg, i) => <li key={i}>{msg}</li>)}
      </ul>
      <button onClick={() => addMessage('New message')}>Send</button>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// Batching Quick Reference:
// ┌─────────────────────────────┬──────────┬──────────┐
// │ Context                     │ React 17 │ React 18 │
// ├─────────────────────────────┼──────────┼──────────┤
// │ React event handlers        │ Batched  │ Batched  │
// │ setTimeout / setInterval    │ NOT      │ Batched  │
// │ Promise .then / async-await │ NOT      │ Batched  │
// │ Native addEventListener      │ NOT      │ Batched  │
// └─────────────────────────────┴──────────┴──────────┘
// flushSync: opts out of batching for a specific update
// ─────────────────────────────────────────────────────────────────
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

### Container / Presentational Pattern

> **Mental Model:** Split every feature component into two: a "smart" container that fetches data and manages state, and a "dumb" presentational component that just renders props. The presentational component is reusable and easy to test.

```tsx
// ─────────────────────────────────────────────────────────────────
// Presentational Component — only cares about HOW things look
// Props in, JSX out. No API calls, no state (or minimal UI state)
// ─────────────────────────────────────────────────────────────────
interface UserListProps {
  users: User[];
  loading: boolean;
  error: string | null;
  onUserSelect: (id: string) => void;
  onLoadMore: () => void;
  hasMore: boolean;
}

function UserList({ users, loading, error, onUserSelect, onLoadMore, hasMore }: UserListProps) {
  if (loading && users.length === 0) return <Skeleton count={5} />;
  if (error) return <ErrorMessage message={error} />;
  if (users.length === 0) return <EmptyState message="No users found" />;

  return (
    <div className="user-list">
      {users.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onClick={() => onUserSelect(user.id)}
        />
      ))}
      {hasMore && (
        <button onClick={onLoadMore} disabled={loading}>
          {loading ? 'Loading...' : 'Load More'}
        </button>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────
// Container Component — only cares about WHERE data comes from
// Fetches data, manages state, passes props to presentational
// ─────────────────────────────────────────────────────────────────
function UserListContainer() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    setLoading(true);
    fetchUsers({ page, pageSize: 20 })
      .then(data => {
        setUsers(prev => page === 1 ? data.users : [...prev, ...data.users]);
        setHasMore(data.hasNextPage);
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false));
  }, [page]);

  const handleUserSelect = (id: string) => {
    navigate(`/users/${id}`);
  };

  const handleLoadMore = () => {
    setPage(p => p + 1);
  };

  // Delegates ALL rendering to the presentational component:
  return (
    <UserList
      users={users}
      loading={loading}
      error={error}
      onUserSelect={handleUserSelect}
      onLoadMore={handleLoadMore}
      hasMore={hasMore}
    />
  );
}
```

### Observer Pattern — Event Bus / Pub-Sub

> **Mental Model:** An event bus lets completely unrelated components communicate without props or context. Component A publishes an event; Component B subscribes and reacts — they don't know each other exist.

```tsx
// ─────────────────────────────────────────────────────────────────
// Simple EventBus implementation:
// ─────────────────────────────────────────────────────────────────
class EventBus {
  private listeners = new Map<string, Set<Function>>();

  on(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(callback);
    return () => this.off(event, callback);  // Return unsubscribe
  }

  off(event: string, callback: Function) {
    this.listeners.get(event)?.delete(callback);
  }

  emit(event: string, data?: unknown) {
    this.listeners.get(event)?.forEach(cb => cb(data));
  }
}

export const eventBus = new EventBus();

// ─────────────────────────────────────────────────────────────────
// Custom hook to subscribe to events:
// ─────────────────────────────────────────────────────────────────
function useEventBus<T>(event: string, callback: (data: T) => void) {
  const callbackRef = useRef(callback);
  callbackRef.current = callback;

  useEffect(() => {
    const unsubscribe = eventBus.on(event, (data: T) => {
      callbackRef.current(data);
    });
    return unsubscribe;
  }, [event]);
}

// ─────────────────────────────────────────────────────────────────
// Usage: Components that don't share a common parent
// ─────────────────────────────────────────────────────────────────

// Shopping cart (publisher):
function ProductPage({ product }) {
  const addToCart = () => {
    eventBus.emit('cart:add', { product, quantity: 1 });
  };
  return <button onClick={addToCart}>Add to Cart</button>;
}

// Cart icon in header (subscriber — no shared parent with ProductPage):
function CartIcon() {
  const [count, setCount] = useState(0);

  useEventBus('cart:add', ({ product, quantity }) => {
    setCount(prev => prev + quantity);
    showToast(`${product.name} added to cart!`);
  });

  return <span>{count}</span>;
}

// Analytics tracker (another subscriber — completely separate):
function AnalyticsTracker() {
  useEventBus('cart:add', ({ product }) => {
    trackEvent('add_to_cart', { productId: product.id, price: product.price });
  });

  return null;  // No UI, just a side-effect component
}
```

### Builder Pattern — Fluent API for Complex Components

> **Mental Model:** The Builder pattern lets you construct complex UI configurations step-by-step with a fluent (chainable) API — like assembling a pizza, topping by topping.

```tsx
// Table builder — configure columns declaratively:
class TableBuilder<T> {
  private config: any = { columns: [], sortable: false, paginated: false, selectable: false };

  addColumn(key: keyof T, label: string, options?: { sortable?: boolean; render?: (val: any) => ReactNode }) {
    this.config.columns.push({ key, label, ...options });
    return this;  // ← return this for chaining
  }

  withSorting() {
    this.config.sortable = true;
    return this;
  }

  withPagination(pageSize = 10) {
    this.config.paginated = true;
    this.config.pageSize = pageSize;
    return this;
  }

  withRowSelection(onSelect: (rows: T[]) => void) {
    this.config.selectable = true;
    this.config.onSelect = onSelect;
    return this;
  }

  build() {
    return this.config;
  }
}

// Usage — fluent, readable:
const userTableConfig = new TableBuilder<User>()
  .addColumn('name', 'Name', { sortable: true })
  .addColumn('email', 'Email', { sortable: true })
  .addColumn('role', 'Role', {
    render: (role) => <Badge variant={role === 'admin' ? 'warning' : 'default'}>{role}</Badge>
  })
  .addColumn('createdAt', 'Joined', {
    render: (date) => new Date(date).toLocaleDateString()
  })
  .withSorting()
  .withPagination(20)
  .withRowSelection((rows) => console.log('Selected:', rows))
  .build();

function UsersPage() {
  const { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });

  return <DataTable data={data} config={userTableConfig} />;
}
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

### Next.js App Router — Deep Dive

#### Server vs Client Components Decision Tree

```
Is this component interactive?
(uses onClick, onChange, useState, useEffect, browser APIs)
         |
    YES -+- NO
         |       |
    'use client' |
         |       v
         |  Does it fetch data or access server resources?
         |  (databases, file system, environment secrets)
         |         |
         |    YES -+- NO
         |         |       |
         |    Server        |
         |    Component     |
         |    (default)     v
         |             Shared Component
         |             (no special marker needed)
```

```tsx
// app/layout.tsx — Root layout (Server Component)
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <header>
          <nav>...</nav>
          <UserMenu />  {/* Client Component */}
        </header>
        <main>{children}</main>
      </body>
    </html>
  );
}

// app/products/page.tsx — Server Component (data fetching)
// Runs on server — can access database directly, no API route needed!
import { db } from '@/lib/database';

export default async function ProductsPage({
  searchParams
}: {
  searchParams: { category?: string; page?: string }
}) {
  const category = searchParams.category ?? 'all';
  const page = Number(searchParams.page ?? 1);

  // Direct DB query in a component — no useEffect, no loading state!
  const products = await db.products.findMany({
    where: category !== 'all' ? { category } : undefined,
    skip: (page - 1) * 20,
    take: 20,
    orderBy: { createdAt: 'desc' },
  });

  return (
    <div>
      <h1>Products</h1>

      {/* Client component for interactivity */}
      <CategoryFilter currentCategory={category} />

      {/* Server Component renders product list */}
      <ProductGrid products={products} />
    </div>
  );
}

// app/components/CategoryFilter.tsx — Client Component
'use client';
import { useRouter, useSearchParams } from 'next/navigation';

export function CategoryFilter({ currentCategory }: { currentCategory: string }) {
  const router = useRouter();
  const searchParams = useSearchParams();

  const handleChange = (category: string) => {
    const params = new URLSearchParams(searchParams);
    params.set('category', category);
    params.set('page', '1');
    router.push(`/products?${params.toString()}`);
  };

  return (
    <div>
      {['all', 'electronics', 'clothing', 'books'].map(cat => (
        <button
          key={cat}
          onClick={() => handleChange(cat)}
          className={currentCategory === cat ? 'active' : ''}
        >
          {cat}
        </button>
      ))}
    </div>
  );
}
```

#### Server Actions — Mutate Data Without API Routes

```tsx
// app/products/[id]/page.tsx

// Server Action — runs on the server, called from client:
async function updateProduct(productId: string, formData: FormData) {
  'use server';  // ← This entire function runs on the server

  const name = formData.get('name') as string;
  const price = Number(formData.get('price'));

  // Direct DB access — no fetch() to an API route!
  await db.products.update({
    where: { id: productId },
    data: { name, price, updatedAt: new Date() },
  });

  // Invalidate the cached page:
  revalidatePath(`/products/${productId}`);

  // Optionally redirect:
  redirect(`/products/${productId}`);
}

// Server Component that uses the Server Action:
export default async function ProductDetailPage({
  params
}: {
  params: { id: string }
}) {
  const product = await db.products.findUnique({ where: { id: params.id } });

  if (!product) notFound();

  // Bind the action to this specific product:
  const updateThisProduct = updateProduct.bind(null, product.id);

  return (
    <div>
      <h1>{product.name}</h1>

      {/* form action wired directly to server function — no API route! */}
      <form action={updateThisProduct}>
        <input name="name" defaultValue={product.name} />
        <input name="price" type="number" defaultValue={product.price} />
        <button type="submit">Update Product</button>
      </form>
    </div>
  );
}
```

#### Caching in Next.js App Router

```tsx
// 1. Default: cached forever (static)
const data = await fetch('https://api.example.com/data');

// 2. Revalidate every N seconds (ISR):
const data2 = await fetch('https://api.example.com/data', {
  next: { revalidate: 60 }  // Fresh data every 60 seconds
});

// 3. Never cache (dynamic):
const data3 = await fetch('https://api.example.com/data', {
  cache: 'no-store'
});

// 4. Tag-based revalidation:
const data4 = await fetch('https://api.example.com/products', {
  next: { tags: ['products'] }
});

// Invalidate all 'products' caches on demand:
import { revalidateTag } from 'next/cache';
async function deleteProduct(id: string) {
  'use server';
  await db.products.delete({ where: { id } });
  revalidateTag('products');  // All pages fetching 'products' tag are refreshed
}

// 5. Loading UI with Suspense (app/products/loading.tsx):
// export default function Loading() {
//   return <ProductGridSkeleton />;
// }

// 6. Error handling (app/products/error.tsx):
'use client';  // Error boundaries must be client components
export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

#### Metadata & SEO in App Router

```tsx
// app/products/[id]/page.tsx — Dynamic metadata
import { Metadata } from 'next';

// Static metadata:
export const metadata: Metadata = {
  title: 'Products | My Store',
  description: 'Browse our collection of products',
};

// Dynamic metadata (based on route params):
export async function generateMetadata({
  params
}: {
  params: { id: string }
}): Promise<Metadata> {
  const product = await db.products.findUnique({ where: { id: params.id } });

  if (!product) return { title: 'Product Not Found' };

  return {
    title: `${product.name} | My Store`,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [{ url: product.imageUrl }],
    },
  };
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
9. **Formik**: Full form lifecycle (`useFormik`, `<Formik>`, `<Field>`, `FieldArray`), custom field components (`useField`), async submission, multi-step wizards
10. **Yup**: Declarative schema validation — primitives, objects, arrays, cross-field refs, conditional `.when()`, custom `.test()` validators
11. **React-Bootstrap**: Grid system, Form + validation integration, Modal, Toast, Table, Navbar, Card, Accordion, Tabs
12. **Common Libraries**: React Query (server state, mutations, cache invalidation), Axios (interceptors, cancel), React Hook Form, React Select (async/creatable), TanStack Table (sort/filter/paginate), React Toastify, date-fns, Lodash, react-error-boundary
13. **Jest Mental Model**: AAA pattern, matchers, mocking (functions/modules/spies), async testing, custom hooks (`renderHook`), provider wrappers, Formik form testing, MSW integration, snapshot testing, coverage thresholds

**Key Interview Tips:**
- Explain the "why" behind your choices
- Discuss trade-offs (Formik vs React Hook Form, Axios vs fetch, controlled vs uncontrolled)
- Show real-world experience with validation schemas and form UX
- Know when NOT to use certain patterns (snapshots, over-mocking)
- Testing: test behavior not implementation — prefer `getByRole` over `getByTestId`
- Performance: always measure first

---

## 24. Styling in React — Complete Guide

React doesn't dictate how you style components. Here are the four main approaches with their trade-offs.

### CSS Modules — Scoped CSS

> **Mental Model:** CSS Modules solve the global CSS naming collision problem. Every class is locally scoped by default — `.button` in one module never clashes with `.button` in another.

```jsx
// Button.module.css
// .button { padding: 8px 16px; border-radius: 4px; font-size: 14px; }
// .primary { background: #0070f3; color: white; }
// .secondary { background: #eaeaea; color: #333; }
// .button:hover { opacity: 0.9; }

// Button.jsx
import styles from './Button.module.css';

// styles.button becomes something like: "Button_button__3xyz" (unique hash)
// → no collision with other components' .button class!
export function Button({ variant = 'primary', children, onClick }) {
  return (
    <button
      // Combine multiple CSS Modules classes:
      className={`${styles.button} ${styles[variant]}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
}

// Using clsx or classnames library for complex class logic:
import clsx from 'clsx';

export function ButtonClsx({ variant, disabled, loading, children }) {
  return (
    <button
      className={clsx(
        styles.button,
        styles[variant],
        { [styles.disabled]: disabled },
        { [styles.loading]: loading },
      )}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Styled Components — CSS-in-JS

> **Mental Model:** Styled Components lets you write real CSS inside JavaScript template literals, producing fully encapsulated components. The style *is* the component.

```jsx
import styled from 'styled-components';

// Create a styled component (like a div with baked-in CSS):
const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
`;

// Extend existing components:
const PrimaryButton = styled.button`
  padding: 8px 16px;
  background: ${props => props.theme.colors.primary};  /* Theme access */
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: ${props => props.size === 'lg' ? '18px' : '14px'};

  &:hover {
    background: ${props => props.theme.colors.primaryHover};
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
`;

// Extend an existing styled component:
const DangerButton = styled(PrimaryButton)`
  background: #dc3545;
  &:hover { background: #c82333; }
`;

// Dynamic styles based on props:
const Badge = styled.span`
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  background: ${({ variant }) => ({
    success: '#d4edda',
    warning: '#fff3cd',
    error: '#f8d7da',
  }[variant])};
`;

// Global styles:
import { createGlobalStyle } from 'styled-components';

const GlobalStyle = createGlobalStyle`
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: system-ui, sans-serif; }
`;

// Theme provider:
import { ThemeProvider } from 'styled-components';

const theme = {
  colors: {
    primary: '#0070f3',
    primaryHover: '#0051ab',
  },
  spacing: (n) => `${n * 8}px`,
};

function App() {
  return (
    <ThemeProvider theme={theme}>
      <GlobalStyle />
      <Container>
        <PrimaryButton>Click me</PrimaryButton>
        <DangerButton>Delete</DangerButton>
        <Badge variant="success">Active</Badge>
      </Container>
    </ThemeProvider>
  );
}
```

### Tailwind CSS with React

> **Mental Model:** Tailwind provides utility classes (`flex`, `p-4`, `text-blue-500`) that you compose directly in JSX. No context switching between JS and CSS files.

```jsx
// Installation: npm install -D tailwindcss
// npx tailwindcss init -p
// tailwind.config.js: content: ["./src/**/*.{js,jsx,ts,tsx}"]
// main.css: @tailwind base; @tailwind components; @tailwind utilities;

// Basic usage:
function Card({ title, description }) {
  return (
    <div className="bg-white rounded-lg shadow-md p-6 max-w-sm hover:shadow-lg transition-shadow">
      <h2 className="text-xl font-semibold text-gray-800 mb-2">{title}</h2>
      <p className="text-gray-600 text-sm">{description}</p>
    </div>
  );
}

// Conditional classes with clsx + Tailwind:
import clsx from 'clsx';

function Button({ variant = 'primary', size = 'md', disabled, children }) {
  return (
    <button
      disabled={disabled}
      className={clsx(
        // Base styles — always applied:
        'rounded font-medium transition-colors focus:outline-none focus:ring-2',
        // Size variants:
        {
          'px-3 py-1 text-sm': size === 'sm',
          'px-4 py-2 text-base': size === 'md',
          'px-6 py-3 text-lg': size === 'lg',
        },
        // Color variants:
        {
          'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500': variant === 'primary',
          'bg-gray-200 text-gray-800 hover:bg-gray-300 focus:ring-gray-400': variant === 'secondary',
          'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500': variant === 'danger',
        },
        // Disabled state:
        { 'opacity-50 cursor-not-allowed': disabled }
      )}
    >
      {children}
    </button>
  );
}

// Responsive design with breakpoint prefixes:
function ResponsiveGrid({ items }) {
  return (
    // 1 col on mobile, 2 on tablet, 3 on desktop
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {items.map(item => (
        <Card key={item.id} {...item} />
      ))}
    </div>
  );
}

// Dark mode:
function Theme() {
  return (
    <div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white p-4">
      <p>Adapts to system dark mode automatically</p>
    </div>
  );
}
```

### Styling Approach Decision Matrix

| Approach | Bundle Size | Scoping | DX | SSR | Best For |
|----------|------------|---------|-----|-----|---------|
| CSS Modules | Minimal | Auto | Good | Yes | Most projects |
| Styled Components | ~12KB | Auto | Excellent | Yes (with setup) | Design systems |
| Tailwind CSS | ~few KB (purged) | Auto | Good | Yes | Rapid prototyping |
| Inline Styles | Zero | Auto | Poor | Yes | Dynamic values only |
| Global CSS | Minimal | Global | Good | Yes | Legacy / simple apps |

---

## 25. Accessibility (a11y) in React

> Building accessible React apps ensures your UI works for all users — including those using screen readers, keyboard navigation, or assistive technologies.

### Semantic HTML & ARIA

```jsx
// ✅ Use semantic HTML first — it's already accessible
function Navigation() {
  return (
    <nav aria-label="Main navigation">  {/* nav announces itself as navigation */}
      <ul>
        <li><a href="/">Home</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </nav>
  );
}

// ✅ ARIA roles when semantic HTML isn't enough:
function CustomDropdown({ label, options, value, onChange }) {
  const [open, setOpen] = useState(false);
  const listId = useId();

  return (
    <div>
      <button
        aria-haspopup="listbox"          // Announces this button opens a list
        aria-expanded={open}             // Announces open/closed state
        aria-controls={listId}           // Links button to the list it controls
        onClick={() => setOpen(o => !o)}
      >
        {label}: {value}
      </button>

      {open && (
        <ul
          id={listId}
          role="listbox"                 // Semantic role for dropdown list
          aria-label={label}
        >
          {options.map(opt => (
            <li
              key={opt.value}
              role="option"              // Each item is an "option"
              aria-selected={opt.value === value}
              onClick={() => { onChange(opt.value); setOpen(false); }}
            >
              {opt.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

// ✅ Live regions — announce dynamic content changes to screen readers:
function NotificationBanner({ message }) {
  return (
    <div
      role="status"             // Polite: waits for current speech to finish
      aria-live="polite"        // 'polite' | 'assertive' | 'off'
      aria-atomic="true"        // Read entire region as one unit
    >
      {message}  {/* Screen reader announces this when it changes */}
    </div>
  );
}

// For urgent alerts (like errors):
function AlertBanner({ error }) {
  return (
    <div role="alert" aria-live="assertive">
      {error}  {/* Interrupts current speech — use sparingly! */}
    </div>
  );
}
```

### Focus Management

```jsx
import { useEffect, useRef } from 'react';

// ✅ Move focus to modal when it opens:
function Modal({ isOpen, onClose, children }) {
  const modalRef = useRef(null);
  const previousFocusRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      // Save where focus was before modal opened
      previousFocusRef.current = document.activeElement;
      // Move focus into modal
      modalRef.current?.focus();
    } else {
      // Restore focus when modal closes
      previousFocusRef.current?.focus();
    }
  }, [isOpen]);

  if (!isOpen) return null;

  return createPortal(
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}         // Makes div focusable programmatically
      className="modal"
    >
      {children}
      <button onClick={onClose}>Close</button>
    </div>,
    document.body
  );
}

// ✅ Focus trap inside modal (Tab stays within modal):
function useFocusTrap(containerRef, isActive) {
  useEffect(() => {
    if (!isActive) return;

    const container = containerRef.current;
    const focusableElements = container.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    const firstEl = focusableElements[0];
    const lastEl = focusableElements[focusableElements.length - 1];

    const handleTab = (e) => {
      if (e.key !== 'Tab') return;
      if (e.shiftKey) {
        if (document.activeElement === firstEl) {
          e.preventDefault();
          lastEl.focus();  // Wrap backward
        }
      } else {
        if (document.activeElement === lastEl) {
          e.preventDefault();
          firstEl.focus();  // Wrap forward
        }
      }
    };

    container.addEventListener('keydown', handleTab);
    return () => container.removeEventListener('keydown', handleTab);
  }, [containerRef, isActive]);
}

// ✅ Skip link (keyboard users skip to main content):
function SkipLink() {
  return (
    <a
      href="#main-content"
      className="sr-only focus:not-sr-only"
      // sr-only: visually hidden but accessible
      // focus:not-sr-only: visible when focused via Tab
    >
      Skip to main content
    </a>
  );
}

// Usage at top of layout:
function Layout({ children }) {
  return (
    <>
      <SkipLink />
      <header>...</header>
      <main id="main-content" tabIndex={-1}>
        {children}
      </main>
    </>
  );
}
```

### Keyboard Navigation

```jsx
// ✅ Custom keyboard interactions:
function TabList({ tabs, activeTab, onTabChange }) {
  const handleKeyDown = (e, index) => {
    switch (e.key) {
      case 'ArrowRight':
        e.preventDefault();
        onTabChange(Math.min(index + 1, tabs.length - 1));
        break;
      case 'ArrowLeft':
        e.preventDefault();
        onTabChange(Math.max(index - 1, 0));
        break;
      case 'Home':
        e.preventDefault();
        onTabChange(0);
        break;
      case 'End':
        e.preventDefault();
        onTabChange(tabs.length - 1);
        break;
    }
  };

  return (
    <div role="tablist" aria-label="Content sections">
      {tabs.map((tab, i) => (
        <button
          key={tab.id}
          role="tab"
          aria-selected={activeTab === i}
          aria-controls={`panel-${tab.id}`}
          tabIndex={activeTab === i ? 0 : -1}  // Only active tab in tab order
          onClick={() => onTabChange(i)}
          onKeyDown={(e) => handleKeyDown(e, i)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  );
}

// ✅ Accessible form with error association:
function AccessibleForm() {
  const [errors, setErrors] = useState({});
  const emailId = useId();
  const emailErrorId = `${emailId}-error`;

  return (
    <form noValidate>
      <div>
        <label htmlFor={emailId}>
          Email <span aria-hidden="true">*</span>
          <span className="sr-only">(required)</span>
        </label>

        <input
          id={emailId}
          type="email"
          required
          aria-required="true"
          aria-invalid={!!errors.email}        // Announces input as invalid
          aria-describedby={errors.email ? emailErrorId : undefined}
        />

        {errors.email && (
          <span
            id={emailErrorId}
            role="alert"                       // Screen reader announces error
            className="error-message"
          >
            {errors.email}
          </span>
        )}
      </div>
    </form>
  );
}

// ─────────────────────────────────────────────────────────────────
// Accessibility Quick Checklist:
// ✅ All images have alt text (alt="" for decorative images)
// ✅ All form inputs have associated <label>
// ✅ Buttons have descriptive text (not just "Click here")
// ✅ Color is not the only way to convey information
// ✅ Text has sufficient contrast ratio (4.5:1 for normal text)
// ✅ Focus is visible and logical (never hidden with outline: none)
// ✅ Keyboard users can reach all interactive elements
// ✅ Dynamic content changes announced via aria-live
// ✅ Modals trap focus and restore it on close
// Tools: axe-core, eslint-plugin-jsx-a11y, Lighthouse audit
// ─────────────────────────────────────────────────────────────────
```

---

## 19. Formik - Complete Form Management

> **Mental Model**: Formik is a "form state machine" — it tracks every field's value, touched state, and error simultaneously, so you never manually wire up `onChange`/`onBlur`/error display again.

```
┌──────────────────────────────────────────────────────────────────┐
│                    Formik Data Flow                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  User Types       Formik State         Validation (Yup / fn)     │
│  ─────────        ───────────          ──────────────────────     │
│  onChange  ──▶   values { }    ──▶    errors { }                 │
│  onBlur    ──▶   touched { }   ──▶    isValid (bool)             │
│  onSubmit  ──▶   isSubmitting  ──▶    handleSubmit()             │
│                                                                   │
│  Formik wraps all this — your JSX just reads formik.values etc.  │
└──────────────────────────────────────────────────────────────────┘
```

### Installation

```bash
npm install formik yup
# yup is optional but works perfectly with formik
```

### Basic Formik Usage (useFormik hook)

```jsx
import { useFormik } from 'formik';

function LoginForm() {
  // useFormik returns the full "formik bag" — all state + helpers
  const formik = useFormik({
    initialValues: {
      email: '',       // every field needs an initial value
      password: '',
    },

    // validate is called on every change/blur — return errors object
    validate: (values) => {
      const errors = {};

      if (!values.email) {
        errors.email = 'Email is required';
      } else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(values.email)) {
        errors.email = 'Invalid email address';
      }

      if (!values.password) {
        errors.password = 'Password is required';
      } else if (values.password.length < 6) {
        errors.password = 'Minimum 6 characters';
      }

      return errors; // empty object = valid
    },

    // onSubmit only fires when validation passes
    onSubmit: async (values, { setSubmitting, resetForm, setErrors }) => {
      try {
        await loginApi(values);  // your API call
        resetForm();             // clear form on success
      } catch (err) {
        // Set server-side errors back into formik
        setErrors({ email: 'Server: ' + err.message });
      } finally {
        setSubmitting(false);    // re-enable submit button
      }
    },
  });

  return (
    <form onSubmit={formik.handleSubmit}>   {/* handleSubmit prevents default */}

      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"                        // must match initialValues key
          type="email"
          onChange={formik.handleChange}      // updates formik.values.email
          onBlur={formik.handleBlur}          // marks field as touched
          value={formik.values.email}
        />
        {/* Only show error AFTER the field was touched (user left it) */}
        {formik.touched.email && formik.errors.email && (
          <span className="error">{formik.errors.email}</span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          name="password"
          type="password"
          onChange={formik.handleChange}
          onBlur={formik.handleBlur}
          value={formik.values.password}
        />
        {formik.touched.password && formik.errors.password && (
          <span className="error">{formik.errors.password}</span>
        )}
      </div>

      {/* Disable button while submitting to prevent double-submit */}
      <button type="submit" disabled={formik.isSubmitting}>
        {formik.isSubmitting ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
}
```

### Formik with Yup Validation (validationSchema — preferred pattern)

```jsx
import { useFormik } from 'formik';
import * as Yup from 'yup';

// Define the schema OUTSIDE the component to prevent recreation on every render
const registrationSchema = Yup.object({
  firstName: Yup.string()
    .min(2, 'Too short')
    .max(50, 'Too long')
    .required('Required'),
  lastName: Yup.string()
    .min(2, 'Too short')
    .required('Required'),
  email: Yup.string()
    .email('Invalid email')     // built-in email format check
    .required('Required'),
  age: Yup.number()
    .min(18, 'Must be at least 18')
    .max(120, 'Must be realistic')
    .required('Required'),
  password: Yup.string()
    .min(8, 'Minimum 8 characters')
    .matches(/[A-Z]/, 'Must contain uppercase')
    .matches(/[0-9]/, 'Must contain a number')
    .required('Required'),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('password')], 'Passwords must match')  // cross-field validation
    .required('Required'),
  role: Yup.string()
    .oneOf(['admin', 'user', 'guest'], 'Invalid role')
    .required('Required'),
});

function RegistrationForm() {
  const formik = useFormik({
    initialValues: {
      firstName: '',
      lastName: '',
      email: '',
      age: '',
      password: '',
      confirmPassword: '',
      role: 'user',
    },
    validationSchema: registrationSchema,  // pass Yup schema here
    onSubmit: async (values) => {
      await registerApi(values);
    },
  });

  return (
    <form onSubmit={formik.handleSubmit}>
      <input
        name="firstName"
        placeholder="First Name"
        {...formik.getFieldProps('firstName')}  // shorthand: spreads value/onChange/onBlur
      />
      {formik.touched.firstName && formik.errors.firstName && (
        <div>{formik.errors.firstName}</div>
      )}

      <input name="email" {...formik.getFieldProps('email')} />
      {formik.touched.email && formik.errors.email && (
        <div>{formik.errors.email}</div>
      )}

      <input name="password" type="password" {...formik.getFieldProps('password')} />
      {formik.touched.password && formik.errors.password && (
        <div>{formik.errors.password}</div>
      )}

      <input name="confirmPassword" type="password" {...formik.getFieldProps('confirmPassword')} />
      {formik.touched.confirmPassword && formik.errors.confirmPassword && (
        <div>{formik.errors.confirmPassword}</div>
      )}

      <select name="role" {...formik.getFieldProps('role')}>
        <option value="user">User</option>
        <option value="admin">Admin</option>
        <option value="guest">Guest</option>
      </select>

      <button type="submit" disabled={formik.isSubmitting || !formik.isValid}>
        Register
      </button>
    </form>
  );
}
```

### Formik Component API (<Formik>, <Form>, <Field>, <ErrorMessage>)

```jsx
// The component-based API is more declarative — preferred for complex forms
import { Formik, Form, Field, ErrorMessage, FieldArray } from 'formik';
import * as Yup from 'yup';

const schema = Yup.object({
  username: Yup.string().required('Username required'),
  subscribe: Yup.boolean(),
  hobbies: Yup.array().of(Yup.string().required('Hobby cannot be empty')),
});

function ProfileForm() {
  return (
    // <Formik> is the context provider — replaces useFormik
    <Formik
      initialValues={{ username: '', subscribe: false, hobbies: [''] }}
      validationSchema={schema}
      onSubmit={(values, actions) => {
        console.log(values);
        actions.setSubmitting(false);
      }}
    >
      {/* Render prop pattern — formik bag is passed as argument */}
      {(formik) => (
        // <Form> auto-wires onSubmit and noValidate
        <Form>
          <div>
            {/* <Field> auto-wires name, value, onChange, onBlur */}
            <Field name="username" placeholder="Username" />
            {/* <ErrorMessage> renders error only when field is touched+invalid */}
            <ErrorMessage name="username" component="span" className="error" />
          </div>

          <div>
            {/* Checkbox: Field with type="checkbox" reads boolean */}
            <label>
              <Field type="checkbox" name="subscribe" />
              Subscribe to newsletter
            </label>
          </div>

          {/* FieldArray: manages dynamic lists of fields */}
          <FieldArray name="hobbies">
            {({ push, remove, form }) => (
              <div>
                {form.values.hobbies.map((hobby, index) => (
                  <div key={index}>
                    <Field name={`hobbies[${index}]`} placeholder="Hobby" />
                    <ErrorMessage name={`hobbies[${index}]`} component="span" />
                    <button type="button" onClick={() => remove(index)}>
                      Remove
                    </button>
                  </div>
                ))}
                <button type="button" onClick={() => push('')}>
                  Add Hobby
                </button>
              </div>
            )}
          </FieldArray>

          {/* Custom render inside Field using children render prop */}
          <Field name="username">
            {({ field, meta }) => (
              <div>
                <input
                  {...field}                    // spreads value/onChange/onBlur/name
                  className={meta.error && meta.touched ? 'input-error' : ''}
                />
                {meta.touched && meta.error && <span>{meta.error}</span>}
              </div>
            )}
          </Field>

          <button type="submit" disabled={formik.isSubmitting}>
            Save Profile
          </button>
        </Form>
      )}
    </Formik>
  );
}
```

### Formik with Custom Components (useField hook)

```jsx
import { useField } from 'formik';

// Build a reusable input that is Formik-aware
function TextInput({ label, ...props }) {
  // useField reads from formik context by name
  const [field, meta] = useField(props);  // field = {name, value, onChange, onBlur}
                                           // meta  = {touched, error, initialValue}
  return (
    <div className="form-group">
      <label htmlFor={props.id || props.name}>{label}</label>
      <input
        className={`form-control ${meta.touched && meta.error ? 'is-invalid' : ''}`}
        {...field}   // spreads name, value, onChange, onBlur
        {...props}   // spreads id, type, placeholder, etc.
      />
      {meta.touched && meta.error && (
        <div className="invalid-feedback">{meta.error}</div>
      )}
    </div>
  );
}

// Reusable select component
function SelectInput({ label, children, ...props }) {
  const [field, meta] = useField(props);
  return (
    <div className="form-group">
      <label>{label}</label>
      <select {...field} {...props}>
        {children}
      </select>
      {meta.touched && meta.error && <div className="error">{meta.error}</div>}
    </div>
  );
}

// Checkbox component using useField
function Checkbox({ children, ...props }) {
  const [field, meta] = useField({ ...props, type: 'checkbox' });
  return (
    <label>
      <input type="checkbox" {...field} {...props} />
      {children}
      {meta.touched && meta.error && <div className="error">{meta.error}</div>}
    </label>
  );
}

// Usage — clean JSX, no wiring
function SignupForm() {
  return (
    <Formik
      initialValues={{ name: '', country: '', terms: false }}
      validationSchema={Yup.object({
        name: Yup.string().required(),
        country: Yup.string().oneOf(['us', 'ca']).required(),
        terms: Yup.boolean().isTrue('You must accept terms'),
      })}
      onSubmit={(v) => console.log(v)}
    >
      <Form>
        <TextInput label="Name" name="name" type="text" placeholder="John" />
        <SelectInput label="Country" name="country">
          <option value="">Select...</option>
          <option value="us">United States</option>
          <option value="ca">Canada</option>
        </SelectInput>
        <Checkbox name="terms">I accept the Terms and Conditions</Checkbox>
        <button type="submit">Sign Up</button>
      </Form>
    </Formik>
  );
}
```

### Formik Helpers & Imperative API

```jsx
// Accessing all formik helpers imperatively
const formik = useFormik({ ... });

// Programmatic value updates
formik.setFieldValue('email', 'new@email.com');        // set one field
formik.setValues({ email: 'a@b.com', name: 'John' }); // replace all values

// Programmatic touched / errors
formik.setFieldTouched('email', true);                 // mark as touched
formik.setFieldError('email', 'Custom error message'); // set error manually
formik.setErrors({ email: 'Bad', password: 'Short' }); // set many errors

// Trigger validation manually
const errors = await formik.validateForm();            // validate all
const err    = await formik.validateField('email');    // validate one

// Reset
formik.resetForm();                                    // back to initialValues
formik.resetForm({ values: { email: 'a@b.com' } });   // reset to specific values

// Useful state flags
formik.isSubmitting   // true while onSubmit promise is pending
formik.isValidating   // true while validation is running
formik.isValid        // true when errors is empty (only reliable after first submit)
formik.dirty          // true when any value differs from initialValues
formik.submitCount    // how many times submit was attempted
```

### Formik Patterns & Best Practices

```jsx
// ─── Pattern 1: Validate on Submit Only (better UX for long forms) ───
const formik = useFormik({
  validateOnChange: false,   // don't validate while typing
  validateOnBlur: true,      // validate when leaving field
  ...
});

// ─── Pattern 2: Async validation (server-side uniqueness check) ───
validate: async (values) => {
  const errors = {};
  if (values.username) {
    const taken = await checkUsernameApi(values.username);
    if (taken) errors.username = 'Username already taken';
  }
  return errors;
},

// ─── Pattern 3: Dependent / conditional fields ───
const formik = useFormik({
  initialValues: { paymentMethod: 'card', cardNumber: '', bankAccount: '' },
  validate: (values) => {
    const errors = {};
    if (values.paymentMethod === 'card' && !values.cardNumber) {
      errors.cardNumber = 'Card number required';
    }
    if (values.paymentMethod === 'bank' && !values.bankAccount) {
      errors.bankAccount = 'Account number required';
    }
    return errors;
  },
  onSubmit: (v) => console.log(v),
});

// ─── Pattern 4: Multi-step form (wizard) ───
const [step, setStep] = useState(0);
const steps = [Step1Schema, Step2Schema, Step3Schema];

<Formik
  initialValues={allInitialValues}
  validationSchema={steps[step]}      // only validate current step schema
  onSubmit={(values, actions) => {
    if (step < steps.length - 1) {
      setStep(s => s + 1);            // advance to next step
      actions.setSubmitting(false);
    } else {
      finalSubmitApi(values);         // last step: real submit
    }
  }}
>

// ─── Pattern 5: Debounced async validation ───
import { debounce } from 'lodash';

const debouncedValidate = useCallback(
  debounce(async (values) => {
    // expensive validation (API call)
  }, 500),
  []
);
```

| Formik State Property | Type | Meaning |
|---|---|---|
| `values` | object | Current field values |
| `errors` | object | Current validation errors |
| `touched` | object | Fields user has visited |
| `isSubmitting` | boolean | onSubmit promise is pending |
| `isValid` | boolean | No errors present |
| `dirty` | boolean | Values differ from initialValues |
| `submitCount` | number | Times form was submitted |

---

## 20. Yup - Schema Validation

> **Mental Model**: Yup schemas are like TypeScript types at runtime — they describe the shape AND constraints of valid data, and produce user-friendly error messages automatically.

### Installation

```bash
npm install yup
```

### Primitive Types

```js
import * as Yup from 'yup';

// ─── String ───
Yup.string()
  .required('Field is required')          // fails on '', null, undefined
  .min(3, 'Min 3 chars')
  .max(100, 'Max 100 chars')
  .email('Must be a valid email')
  .url('Must be a valid URL')
  .uuid('Must be a valid UUID')
  .matches(/^[a-z]+$/, 'Only lowercase letters')   // custom regex
  .trim()                                 // trims whitespace before validation
  .lowercase()                            // coerces to lowercase
  .uppercase()
  .oneOf(['admin', 'user'], 'Invalid role')        // allowlist
  .notOneOf(['banned'], 'This value is not allowed') // denylist
  .nullable()                             // allows null (but not undefined)
  .optional();                            // allows undefined

// ─── Number ───
Yup.number()
  .required()
  .integer('Must be a whole number')
  .min(0, 'Must be positive')
  .max(100, 'Cannot exceed 100')
  .positive('Must be positive')
  .negative('Must be negative')
  .moreThan(5, 'Must be more than 5')
  .lessThan(10, 'Must be less than 10')
  .truncate()                             // truncates decimal before validation

// ─── Boolean ───
Yup.boolean()
  .required()
  .isTrue('You must agree')              // must be exactly true
  .isFalse('Must be unchecked');

// ─── Date ───
Yup.date()
  .required()
  .min(new Date(), 'Must be in the future')
  .max(new Date('2030-01-01'), 'Too far in the future')
  .typeError('Invalid date');            // custom message when cast fails

// ─── Mixed (any type) ───
Yup.mixed()
  .required()
  .oneOf([1, 'one', true])              // accepts multiple types
  .test('is-file', 'Must be a file', (value) => value instanceof File);
```

### Object Schema

```js
// Yup.object() validates the shape of a plain object
const addressSchema = Yup.object({
  street:  Yup.string().required(),
  city:    Yup.string().required(),
  zip:     Yup.string().matches(/^\d{5}$/, 'Must be 5 digits').required(),
  country: Yup.string().default('US'),   // default value applied during cast
});

// Nested objects
const userSchema = Yup.object({
  name:    Yup.string().required(),
  address: addressSchema,               // nest another schema
  contact: Yup.object({
    phone: Yup.string(),
    email: Yup.string().email(),
  }),
});

// .shape() adds/overrides fields after creation
const extendedSchema = userSchema.shape({
  role: Yup.string().required(),
});
```

### Array Schema

```js
// Yup.array() validates arrays of items
const tagsSchema = Yup.array()
  .of(Yup.string().min(2))             // each element must be string >= 2 chars
  .min(1, 'At least one tag required')
  .max(10, 'Maximum 10 tags')
  .required();

// Array of objects
const ordersSchema = Yup.array().of(
  Yup.object({
    productId: Yup.string().required(),
    quantity:  Yup.number().min(1).required(),
    price:     Yup.number().positive().required(),
  })
).min(1, 'Order must have at least one item');

// Unique items — custom test
const uniqueEmailsSchema = Yup.array()
  .of(Yup.string().email())
  .test('unique', 'Emails must be unique', (values) => {
    return values ? new Set(values).size === values.length : true;
  });
```

### Cross-Field Validation (Yup.ref)

```js
const passwordSchema = Yup.object({
  password: Yup.string()
    .min(8)
    .required(),

  confirmPassword: Yup.string()
    // Yup.ref('password') references the sibling field's value
    .oneOf([Yup.ref('password')], 'Passwords do not match')
    .required('Please confirm your password'),

  minAge: Yup.number().required(),

  maxAge: Yup.number()
    // this() refers to the current field, parent() refers to the parent object
    .min(Yup.ref('minAge'), 'Max age must be ≥ Min age')
    .required(),
});

// Date range: end must be after start
const dateRangeSchema = Yup.object({
  startDate: Yup.date().required(),
  endDate:   Yup.date()
    .min(Yup.ref('startDate'), 'End date must be after start date')
    .required(),
});
```

### Custom Validators (.test())

```js
// .test(name, message, testFn) — most flexible option
const customSchema = Yup.object({

  // Sync custom validator
  username: Yup.string().test(
    'no-spaces',                         // test name (internal, for debugging)
    'Username cannot contain spaces',    // error message
    (value) => !value || !value.includes(' ')  // return true = valid
  ),

  // Async validator (server check)
  email: Yup.string().email().test(
    'unique-email',
    'Email already registered',
    async (value) => {
      if (!value) return true;           // skip if empty (required handles that)
      const isTaken = await checkEmailApi(value);
      return !isTaken;                   // true = valid (email NOT taken)
    }
  ),

  // Access sibling fields in test via this.parent
  endDate: Yup.date().test(
    'after-start',
    'End must be after start',
    function(value) {
      // NOTE: must use function() not arrow fn to access this.parent
      const { startDate } = this.parent;
      return !startDate || !value || value > startDate;
    }
  ),

  // Custom error message with dynamic value
  score: Yup.number().test(
    'max-score',
    ({ value }) => `Score ${value} exceeds maximum of 100`,  // message as function
    (value) => !value || value <= 100
  ),
});
```

### Conditional Validation (.when())

```js
const conditionalSchema = Yup.object({
  // Simple condition: isEmployed controls employerName requirement
  isEmployed: Yup.boolean(),
  employerName: Yup.string().when('isEmployed', {
    is: true,                            // when isEmployed === true
    then: (schema) => schema.required('Employer name required'),
    otherwise: (schema) => schema.optional(),
  }),

  // Condition on multiple fields (pass array)
  discount: Yup.number().when(['isStudent', 'isEmployed'], {
    is: (isStudent, isEmployed) => isStudent && !isEmployed,  // condition function
    then: (schema) => schema.max(50, 'Student discount max 50%'),
    otherwise: (schema) => schema.max(20, 'Standard discount max 20%'),
  }),

  // Nested when
  paymentType: Yup.string().oneOf(['card', 'bank']),
  cardNumber: Yup.string().when('paymentType', {
    is: 'card',
    then: (schema) => schema
      .matches(/^\d{16}$/, 'Must be 16 digits')
      .required(),
  }),
  bankAccount: Yup.string().when('paymentType', {
    is: 'bank',
    then: (schema) => schema.required('Bank account required'),
  }),
});
```

### Using Yup Outside Formik

```js
// Validate manually (returns the cast/coerced value)
try {
  const validData = await userSchema.validate(rawData, {
    abortEarly: false,   // collect ALL errors, not just the first
    stripUnknown: true,  // remove fields not in schema
  });
  console.log(validData); // clean, validated data
} catch (err) {
  // err is a Yup.ValidationError
  // err.inner is an array of all individual field errors
  const fieldErrors = err.inner.reduce((acc, e) => {
    acc[e.path] = e.message;  // e.path = 'email', 'address.zip', etc.
    return acc;
  }, {});
  console.log(fieldErrors);  // { email: 'Required', 'address.zip': 'Must be 5 digits' }
}

// Synchronous validation (throws if schema has async tests)
const isValid = userSchema.isValidSync(data);              // boolean
const errors  = userSchema.validateSync(data, { abortEarly: false }); // throws

// Just check if valid without throwing
const valid = await userSchema.isValid(data);              // boolean, no throw
```

### Yup Schema Composition & Reuse

```js
// Build shared base schemas and extend them
const baseStringField = Yup.string().trim().max(255);

const emailField = baseStringField.email('Invalid email').required('Email required');
const nameField  = baseStringField.min(2, 'Too short').required('Name required');

// Compose schemas
const loginSchema     = Yup.object({ email: emailField, password: Yup.string().required() });
const registerSchema  = Yup.object({ email: emailField, name: nameField, password: Yup.string().min(8).required() });

// Extend an existing schema
const adminSchema = registerSchema.shape({
  adminCode: Yup.string().required('Admin code required'),
});

// Lazy evaluation (schema depends on runtime value)
const dynamicSchema = Yup.lazy((value) => {
  if (typeof value === 'string') return Yup.string().email();
  if (typeof value === 'number') return Yup.number().positive();
  return Yup.mixed();
});
```

| Yup Method | Purpose |
|---|---|
| `.required()` | Fails on `''`, `null`, `undefined` |
| `.nullable()` | Allows `null` through |
| `.optional()` | Allows `undefined` through |
| `.default(val)` | Provides default during cast |
| `.strip()` | Removes this field from output |
| `.label('Name')` | Custom label in error messages |
| `.typeError('msg')` | Message when type cast fails |
| `abortEarly: false` | Collect all errors, not just first |

---

## 21. React-Bootstrap - UI Component Library

> **Mental Model**: React-Bootstrap replaces raw HTML with pre-styled, accessible React components. Think of it as Bootstrap CSS grid + components but wired directly into React props instead of class names.

### Installation & Setup

```bash
npm install react-bootstrap bootstrap
```

```jsx
// main.jsx or index.js — import Bootstrap CSS ONCE at the root
import 'bootstrap/dist/css/bootstrap.min.css';
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
```

### Grid System (Container / Row / Col)

```jsx
import { Container, Row, Col } from 'react-bootstrap';

// 12-column grid — Col xs/sm/md/lg/xl control breakpoint widths
function GridDemo() {
  return (
    // Container centers content and adds horizontal padding
    <Container>
      <Row>
        {/* Full width on xs, half on md, one-third on lg */}
        <Col xs={12} md={6} lg={4}>
          <div className="p-3 bg-light border">Column 1</div>
        </Col>
        <Col xs={12} md={6} lg={4}>
          <div className="p-3 bg-light border">Column 2</div>
        </Col>
        <Col xs={12} md={12} lg={4}>
          <div className="p-3 bg-light border">Column 3</div>
        </Col>
      </Row>

      {/* Auto-sizing: all cols get equal width */}
      <Row className="mt-3">
        <Col><div className="p-3 bg-info text-white">Auto</div></Col>
        <Col><div className="p-3 bg-info text-white">Auto</div></Col>
        <Col><div className="p-3 bg-info text-white">Auto</div></Col>
      </Row>

      {/* Offset columns */}
      <Row className="mt-3">
        <Col md={{ span: 6, offset: 3 }}>  {/* centered column */}
          <div className="p-3 bg-warning">Centered</div>
        </Col>
      </Row>
    </Container>
  );
}
```

### Forms with React-Bootstrap

```jsx
import { Form, Button, FloatingLabel, InputGroup } from 'react-bootstrap';
import { useFormik } from 'formik';
import * as Yup from 'yup';

const schema = Yup.object({
  email:    Yup.string().email().required(),
  password: Yup.string().min(8).required(),
  role:     Yup.string().required(),
  agree:    Yup.boolean().isTrue('You must agree'),
});

function BootstrapForm() {
  const formik = useFormik({
    initialValues: { email: '', password: '', role: '', agree: false },
    validationSchema: schema,
    onSubmit: (v) => console.log(v),
  });

  return (
    <Form noValidate onSubmit={formik.handleSubmit}>  {/* noValidate disables browser validation */}

      {/* Floating label input */}
      <FloatingLabel label="Email address" className="mb-3">
        <Form.Control
          type="email"
          name="email"
          placeholder="name@example.com"      // required for FloatingLabel
          value={formik.values.email}
          onChange={formik.handleChange}
          onBlur={formik.handleBlur}
          isValid={formik.touched.email && !formik.errors.email}    // green border
          isInvalid={formik.touched.email && !!formik.errors.email} // red border
        />
        {/* Form.Control.Feedback renders Bootstrap's invalid text */}
        <Form.Control.Feedback type="invalid">
          {formik.errors.email}
        </Form.Control.Feedback>
      </FloatingLabel>

      {/* Regular labeled input */}
      <Form.Group className="mb-3" controlId="password">
        <Form.Label>Password</Form.Label>
        <Form.Control
          type="password"
          name="password"
          {...formik.getFieldProps('password')}
          isInvalid={formik.touched.password && !!formik.errors.password}
        />
        <Form.Control.Feedback type="invalid">
          {formik.errors.password}
        </Form.Control.Feedback>
        <Form.Text className="text-muted">Minimum 8 characters</Form.Text>
      </Form.Group>

      {/* Select dropdown */}
      <Form.Group className="mb-3" controlId="role">
        <Form.Label>Role</Form.Label>
        <Form.Select
          name="role"
          {...formik.getFieldProps('role')}
          isInvalid={formik.touched.role && !!formik.errors.role}
        >
          <option value="">Choose role...</option>
          <option value="user">User</option>
          <option value="admin">Admin</option>
        </Form.Select>
        <Form.Control.Feedback type="invalid">
          {formik.errors.role}
        </Form.Control.Feedback>
      </Form.Group>

      {/* Checkbox */}
      <Form.Group className="mb-3">
        <Form.Check
          type="checkbox"
          id="agree"
          name="agree"
          label="I agree to the terms"
          checked={formik.values.agree}
          onChange={formik.handleChange}
          isInvalid={formik.touched.agree && !!formik.errors.agree}
          feedback={formik.errors.agree}
          feedbackType="invalid"
        />
      </Form.Group>

      {/* Input with addon (prefix/suffix) */}
      <InputGroup className="mb-3">
        <InputGroup.Text>@</InputGroup.Text>   {/* prefix addon */}
        <Form.Control name="username" placeholder="Username" />
        <InputGroup.Text>.com</InputGroup.Text>  {/* suffix addon */}
      </InputGroup>

      <Button
        type="submit"
        variant="primary"
        disabled={formik.isSubmitting}
      >
        {formik.isSubmitting ? 'Submitting...' : 'Submit'}
      </Button>
    </Form>
  );
}
```

### Buttons & Variants

```jsx
import { Button, ButtonGroup, ButtonToolbar } from 'react-bootstrap';

function ButtonDemo() {
  return (
    <>
      {/* variant controls color */}
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="success">Success</Button>
      <Button variant="danger">Danger</Button>
      <Button variant="warning">Warning</Button>
      <Button variant="info">Info</Button>
      <Button variant="light">Light</Button>
      <Button variant="dark">Dark</Button>
      <Button variant="link">Link</Button>

      {/* Outline variants */}
      <Button variant="outline-primary">Outline Primary</Button>

      {/* Sizes */}
      <Button size="lg">Large</Button>
      <Button size="sm">Small</Button>

      {/* Full width */}
      <Button className="w-100">Full Width</Button>

      {/* Loading state pattern */}
      <Button disabled={isLoading}>
        {isLoading ? 'Loading...' : 'Submit'}
      </Button>

      {/* Button group */}
      <ButtonGroup>
        <Button variant="outline-primary">Left</Button>
        <Button variant="outline-primary">Middle</Button>
        <Button variant="outline-primary">Right</Button>
      </ButtonGroup>
    </>
  );
}
```

### Modal Dialog

```jsx
import { useState } from 'react';
import { Modal, Button, Form } from 'react-bootstrap';

function ConfirmDeleteModal({ onConfirm }) {
  const [show, setShow] = useState(false);

  const handleClose = () => setShow(false);
  const handleShow  = () => setShow(true);

  const handleConfirm = () => {
    onConfirm();       // execute the dangerous action
    handleClose();     // close the modal
  };

  return (
    <>
      <Button variant="danger" onClick={handleShow}>Delete Item</Button>

      <Modal
        show={show}
        onHide={handleClose}
        backdrop="static"      // prevent closing by clicking outside
        keyboard={false}       // prevent Esc key close
        centered               // vertically center the modal
        size="lg"              // sm | lg | xl | undefined (default md)
      >
        <Modal.Header closeButton>  {/* closeButton adds X button */}
          <Modal.Title>Confirm Delete</Modal.Title>
        </Modal.Header>

        <Modal.Body>
          Are you sure you want to delete this item? This action cannot be undone.
        </Modal.Body>

        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>Cancel</Button>
          <Button variant="danger" onClick={handleConfirm}>Delete</Button>
        </Modal.Footer>
      </Modal>
    </>
  );
}
```

### Alerts & Toasts

```jsx
import { Alert, Toast, ToastContainer } from 'react-bootstrap';
import { useState } from 'react';

function AlertDemo() {
  const [show, setShow] = useState(true);

  return (
    <>
      {/* Static alert */}
      <Alert variant="success">
        <Alert.Heading>Success!</Alert.Heading>
        <p>Your form was submitted successfully.</p>
      </Alert>

      {/* Dismissible alert */}
      <Alert variant="warning" dismissible onClose={() => setShow(false)} show={show}>
        This is a warning message.
      </Alert>
    </>
  );
}

function ToastDemo() {
  const [show, setShow] = useState(false);

  return (
    <>
      <Button onClick={() => setShow(true)}>Show Toast</Button>

      {/* ToastContainer positions toasts — position prop controls corner */}
      <ToastContainer position="top-end" className="p-3">
        <Toast
          show={show}
          onClose={() => setShow(false)}
          delay={3000}          // auto-hide after 3 seconds
          autohide             // enable auto-hide
          bg="success"         // background color
        >
          <Toast.Header>
            <strong className="me-auto">Notification</strong>
            <small>Just now</small>
          </Toast.Header>
          <Toast.Body className="text-white">Item saved successfully!</Toast.Body>
        </Toast>
      </ToastContainer>
    </>
  );
}
```

### Table

```jsx
import { Table, Spinner } from 'react-bootstrap';

function DataTable({ data, isLoading }) {
  if (isLoading) return <Spinner animation="border" role="status" />;

  return (
    <Table
      striped        // alternating row colors
      bordered       // borders on all cells
      hover          // highlight row on hover
      responsive     // horizontal scroll on small screens
      size="sm"      // compact padding
    >
      <thead className="table-dark">
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Email</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {data.map((row, idx) => (
          <tr key={row.id}>
            <td>{idx + 1}</td>
            <td>{row.name}</td>
            <td>{row.email}</td>
            <td>
              <Button size="sm" variant="outline-primary" className="me-1">Edit</Button>
              <Button size="sm" variant="outline-danger">Delete</Button>
            </td>
          </tr>
        ))}
        {data.length === 0 && (
          <tr>
            <td colSpan={4} className="text-center text-muted">No data found</td>
          </tr>
        )}
      </tbody>
    </Table>
  );
}
```

### Navbar & Navigation

```jsx
import { Navbar, Nav, NavDropdown, Container } from 'react-bootstrap';
import { LinkContainer } from 'react-router-bootstrap'; // bridges RRD and RB

function AppNavbar() {
  return (
    <Navbar bg="dark" variant="dark" expand="lg" sticky="top">
      <Container>
        <Navbar.Brand href="/">MyApp</Navbar.Brand>

        {/* Hamburger toggle for mobile */}
        <Navbar.Toggle aria-controls="main-nav" />

        {/* Collapsible nav links */}
        <Navbar.Collapse id="main-nav">
          <Nav className="me-auto">
            <LinkContainer to="/dashboard">
              <Nav.Link>Dashboard</Nav.Link>
            </LinkContainer>
            <LinkContainer to="/users">
              <Nav.Link>Users</Nav.Link>
            </LinkContainer>

            {/* Dropdown */}
            <NavDropdown title="Settings" id="settings-dropdown">
              <LinkContainer to="/settings/profile">
                <NavDropdown.Item>Profile</NavDropdown.Item>
              </LinkContainer>
              <NavDropdown.Divider />
              <NavDropdown.Item onClick={handleLogout}>Logout</NavDropdown.Item>
            </NavDropdown>
          </Nav>

          {/* Right-aligned items */}
          <Nav>
            <Nav.Link href="/login">Login</Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
}
```

### Cards & Layout Components

```jsx
import { Card, Badge, ListGroup, Accordion, Tabs, Tab } from 'react-bootstrap';

// Card
function ProductCard({ product }) {
  return (
    <Card style={{ width: '18rem' }}>
      <Card.Img variant="top" src={product.imageUrl} />
      <Card.Body>
        <Card.Title>
          {product.name}
          <Badge bg="success" className="ms-2">{product.category}</Badge>
        </Card.Title>
        <Card.Text>{product.description}</Card.Text>
        <Button variant="primary">Add to Cart</Button>
      </Card.Body>
      <Card.Footer className="text-muted">${product.price}</Card.Footer>
    </Card>
  );
}

// Accordion (collapsible sections)
function FAQ() {
  return (
    <Accordion defaultActiveKey="0">  {/* "0" = first item open by default */}
      <Accordion.Item eventKey="0">
        <Accordion.Header>What is React?</Accordion.Header>
        <Accordion.Body>
          React is a JavaScript library for building user interfaces.
        </Accordion.Body>
      </Accordion.Item>
      <Accordion.Item eventKey="1">
        <Accordion.Header>What is Formik?</Accordion.Header>
        <Accordion.Body>
          Formik is a form library for React that simplifies form state management.
        </Accordion.Body>
      </Accordion.Item>
    </Accordion>
  );
}

// Tabs
function TabbedContent() {
  return (
    <Tabs defaultActiveKey="profile" id="content-tabs" className="mb-3">
      <Tab eventKey="profile" title="Profile">
        <p>Profile content here</p>
      </Tab>
      <Tab eventKey="settings" title="Settings">
        <p>Settings content here</p>
      </Tab>
      <Tab eventKey="billing" title="Billing" disabled>
        <p>Billing (disabled)</p>
      </Tab>
    </Tabs>
  );
}
```

---

## 22. Common Useful Libraries

> **Key Insight**: Master the ecosystem, not just React core. These libraries solve real-world problems so you don't reinvent the wheel.

### React Query (TanStack Query) — Server State Management

```bash
npm install @tanstack/react-query
```

```jsx
import { QueryClient, QueryClientProvider, useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Create client ONCE outside components
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000,    // data fresh for 5 min (no refetch)
      retry: 2,                      // retry failed requests twice
      refetchOnWindowFocus: false,   // don't refetch when tab regains focus
    },
  },
});

// Wrap app with provider
function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <UserList />
    </QueryClientProvider>
  );
}

// ─── useQuery: fetch & cache server data ───
function UserList() {
  const {
    data,          // fetched data (undefined while loading)
    isLoading,     // true on first fetch (no cached data)
    isFetching,    // true on any fetch (including background refetch)
    isError,
    error,
    refetch,       // manually trigger refetch
  } = useQuery({
    queryKey: ['users'],            // cache key — must be unique
    queryFn: () => fetch('/api/users').then(r => r.json()),
  });

  if (isLoading) return <Spinner />;
  if (isError) return <Alert variant="danger">{error.message}</Alert>;

  return <UserTable data={data} />;
}

// useQuery with parameters — queryKey changes trigger new fetch
function UserDetail({ userId }) {
  const { data: user } = useQuery({
    queryKey: ['users', userId],    // new key = new query for each userId
    queryFn: () => fetch(`/api/users/${userId}`).then(r => r.json()),
    enabled: !!userId,              // only fetch when userId is truthy
  });
  return <div>{user?.name}</div>;
}

// ─── useMutation: POST/PUT/DELETE operations ───
function CreateUserForm() {
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: (newUser) => fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newUser),
    }).then(r => r.json()),

    onSuccess: () => {
      // Invalidate 'users' query → triggers background refetch
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
    onError: (error) => {
      console.error('Failed to create user:', error);
    },
  });

  return (
    <button
      onClick={() => mutation.mutate({ name: 'John', email: 'john@example.com' })}
      disabled={mutation.isPending}
    >
      {mutation.isPending ? 'Creating...' : 'Create User'}
    </button>
  );
}
```

### Axios — HTTP Client

```bash
npm install axios
```

```jsx
import axios from 'axios';

// ─── Axios Instance (configure once, use everywhere) ───
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api',
  timeout: 10000,                      // fail requests after 10s
  headers: { 'Content-Type': 'application/json' },
});

// Request interceptor — add auth token to every request
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor — handle 401 globally
api.interceptors.response.use(
  (response) => response.data,        // unwrap .data automatically
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login'; // redirect to login
    }
    return Promise.reject(error);
  }
);

// ─── CRUD operations ───
const userService = {
  getAll:   ()       => api.get('/users'),
  getById:  (id)     => api.get(`/users/${id}`),
  create:   (data)   => api.post('/users', data),
  update:   (id, data) => api.put(`/users/${id}`, data),
  patch:    (id, data) => api.patch(`/users/${id}`, data),
  delete:   (id)     => api.delete(`/users/${id}`),
};

// ─── File upload with progress ───
async function uploadFile(file, onProgress) {
  const formData = new FormData();
  formData.append('file', file);

  return api.post('/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
    onUploadProgress: (e) => {
      const pct = Math.round((e.loaded / e.total) * 100);
      onProgress(pct);               // update progress bar
    },
  });
}

// ─── Cancel request (cleanup on unmount) ───
function UserDetail({ id }) {
  useEffect(() => {
    const controller = new AbortController();

    api.get(`/users/${id}`, { signal: controller.signal })
      .then(setUser)
      .catch((err) => {
        if (!axios.isCancel(err)) console.error(err);
      });

    return () => controller.abort();  // cancel on unmount / id change
  }, [id]);
}
```

### React Hook Form — Lightweight Form Library

```bash
npm install react-hook-form @hookform/resolvers
```

```jsx
// React Hook Form (RHF) — uncontrolled inputs, minimal re-renders
import { useForm, Controller } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as Yup from 'yup';

const schema = Yup.object({
  email:    Yup.string().email().required(),
  password: Yup.string().min(8).required(),
});

function LoginFormRHF() {
  const {
    register,      // connects input to RHF (uncontrolled)
    handleSubmit,  // wraps your submit, only calls if valid
    formState: { errors, isSubmitting, isDirty, isValid },
    reset,         // reset to defaultValues
    setValue,      // programmatically set a value
    watch,         // watch field values reactively
    control,       // for Controller (third-party components)
  } = useForm({
    defaultValues: { email: '', password: '' },
    resolver: yupResolver(schema),   // plug in Yup validation
    mode: 'onBlur',                  // validate on blur (onSubmit | onChange | all)
  });

  const emailValue = watch('email'); // live value without extra state

  const onSubmit = async (data) => {  // data = validated form values
    await loginApi(data);
    reset();
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        type="email"
        // register() returns ref, name, onChange, onBlur — spread them
        {...register('email')}
        placeholder="Email"
      />
      {errors.email && <span>{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}

      {/* Controller wraps third-party controlled inputs (e.g. React Select) */}
      <Controller
        name="country"
        control={control}
        render={({ field }) => (
          <ReactSelect
            {...field}              // passes value, onChange, onBlur
            options={countryOptions}
          />
        )}
      />

      <button type="submit" disabled={isSubmitting || !isValid}>
        Login
      </button>
    </form>
  );
}

// RHF vs Formik comparison
// RHF: uncontrolled (refs) — fewer re-renders, better performance at scale
// Formik: controlled — simpler mental model, better ecosystem integration
```

### React Select — Searchable Dropdown

```bash
npm install react-select
```

```jsx
import Select from 'react-select';
import CreatableSelect from 'react-select/creatable';
import AsyncSelect from 'react-select/async';

// Options format: { value, label }
const countryOptions = [
  { value: 'us', label: 'United States' },
  { value: 'ca', label: 'Canada' },
  { value: 'gb', label: 'United Kingdom' },
];

function SelectDemo() {
  const [selected, setSelected] = useState(null);
  const [multi, setMulti]       = useState([]);

  return (
    <>
      {/* Basic searchable select */}
      <Select
        options={countryOptions}
        value={selected}
        onChange={setSelected}           // receives { value, label } object
        placeholder="Select country..."
        isClearable                      // show X to clear
        isSearchable                     // search/filter options (default true)
        isLoading={false}               // show spinner
        isDisabled={false}
        noOptionsMessage={() => 'No countries found'}
      />

      {/* Multi-select */}
      <Select
        isMulti
        options={countryOptions}
        value={multi}
        onChange={setMulti}             // array of { value, label }
        closeMenuOnSelect={false}       // keep open after selection
      />

      {/* Async options from API */}
      <AsyncSelect
        loadOptions={async (inputValue) => {
          const res = await searchUsersApi(inputValue);
          return res.map(u => ({ value: u.id, label: u.name }));
        }}
        defaultOptions                  // load options on mount
        placeholder="Search users..."
      />

      {/* Creatable: user can type new options */}
      <CreatableSelect
        options={countryOptions}
        onChange={setSelected}
        onCreateOption={(label) => {    // called when user types new value
          const newOption = { value: label.toLowerCase(), label };
          setSelected(newOption);
        }}
      />
    </>
  );
}

// With Formik + Controller (React Hook Form)
<Controller
  name="country"
  control={control}
  render={({ field }) => (
    <Select
      {...field}
      options={countryOptions}
      value={countryOptions.find(o => o.value === field.value)}
      onChange={(opt) => field.onChange(opt?.value)}  // store just the value string
    />
  )}
/>
```

### React Table (TanStack Table) — Headless Table

```bash
npm install @tanstack/react-table
```

```jsx
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
} from '@tanstack/react-table';
import { useState, useMemo } from 'react';

const columns = [
  // columnHelper.accessor or plain column def objects
  {
    accessorKey: 'name',              // maps to data.name
    header: 'Name',
    cell: ({ getValue }) => <strong>{getValue()}</strong>,  // custom cell renderer
  },
  {
    accessorKey: 'email',
    header: 'Email',
    enableSorting: false,             // disable sort on this column
  },
  {
    accessorKey: 'role',
    header: 'Role',
    cell: ({ getValue }) => (
      <Badge bg={getValue() === 'admin' ? 'danger' : 'secondary'}>
        {getValue()}
      </Badge>
    ),
  },
  {
    id: 'actions',                    // id required when no accessorKey
    header: 'Actions',
    cell: ({ row }) => (
      <Button size="sm" onClick={() => handleEdit(row.original)}>
        Edit
      </Button>
    ),
  },
];

function DataGrid({ data }) {
  const [sorting, setSorting]       = useState([]);
  const [globalFilter, setGlobalFilter] = useState('');

  const table = useReactTable({
    data,
    columns,
    state: { sorting, globalFilter },
    onSortingChange:       setSorting,
    onGlobalFilterChange:  setGlobalFilter,
    getCoreRowModel:       getCoreRowModel(),       // required
    getSortedRowModel:     getSortedRowModel(),     // enables sorting
    getFilteredRowModel:   getFilteredRowModel(),   // enables filtering
    getPaginationRowModel: getPaginationRowModel(), // enables pagination
    initialState: { pagination: { pageSize: 10 } },
  });

  return (
    <div>
      <input
        value={globalFilter}
        onChange={(e) => setGlobalFilter(e.target.value)}
        placeholder="Search all columns..."
      />

      <table>
        <thead>
          {table.getHeaderGroups().map(headerGroup => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map(header => (
                <th
                  key={header.id}
                  onClick={header.column.getToggleSortingHandler()}
                  style={{ cursor: header.column.getCanSort() ? 'pointer' : 'default' }}
                >
                  {flexRender(header.column.columnDef.header, header.getContext())}
                  {/* Sort indicator */}
                  {{ asc: ' ↑', desc: ' ↓' }[header.column.getIsSorted()] ?? ''}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map(row => (
            <tr key={row.id}>
              {row.getVisibleCells().map(cell => (
                <td key={cell.id}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>

      {/* Pagination controls */}
      <div>
        <button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
          Previous
        </button>
        <span>Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}</span>
        <button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
          Next
        </button>
        <select
          value={table.getState().pagination.pageSize}
          onChange={(e) => table.setPageSize(Number(e.target.value))}
        >
          {[10, 25, 50].map(size => <option key={size} value={size}>Show {size}</option>)}
        </select>
      </div>
    </div>
  );
}
```

### React Toastify — Notifications

```bash
npm install react-toastify
```

```jsx
// App.jsx — add ToastContainer once at root
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

function App() {
  return (
    <>
      <YourRoutes />
      <ToastContainer
        position="top-right"     // top-left | top-center | bottom-right | etc.
        autoClose={3000}         // ms before auto-close
        hideProgressBar={false}
        newestOnTop
        closeOnClick
        pauseOnHover
      />
    </>
  );
}

// Anywhere in your app — no props needed
import { toast } from 'react-toastify';

function UserActions() {
  const handleSave = async () => {
    try {
      await saveApi();
      toast.success('Saved successfully!');            // green
    } catch (e) {
      toast.error(`Error: ${e.message}`);              // red
    }
  };

  return (
    <>
      <button onClick={handleSave}>Save</button>
      <button onClick={() => toast.info('Info message')}>Info</button>    {/* blue */}
      <button onClick={() => toast.warning('Warning!')}>Warn</button>     {/* orange */}

      {/* Promise toast — shows loading → success/error automatically */}
      <button onClick={() =>
        toast.promise(
          saveApi(),                    // the promise
          {
            pending: 'Saving...',
            success: 'Saved!',
            error:   'Save failed',
          }
        )
      }>
        Save with Promise
      </button>

      {/* Custom toast with dismiss */}
      <button onClick={() => {
        const id = toast.loading('Processing...');
        doHeavyWork().then(() => {
          toast.update(id, { render: 'Done!', type: 'success', isLoading: false, autoClose: 2000 });
        });
      }}>
        Heavy Work
      </button>
    </>
  );
}
```

### date-fns — Date Utilities

```bash
npm install date-fns
```

```jsx
import {
  format, parseISO, formatDistanceToNow, addDays, subMonths,
  isAfter, isBefore, differenceInDays, startOfMonth, endOfMonth,
  isValid, parse,
} from 'date-fns';

// Format dates
format(new Date(), 'yyyy-MM-dd');            // '2024-03-15'
format(new Date(), 'MMM d, yyyy');           // 'Mar 15, 2024'
format(new Date(), 'h:mm a');               // '2:30 PM'
format(new Date(), "EEEE, MMMM do, yyyy");  // 'Friday, March 15th, 2024'

// Parse ISO string from API
const date = parseISO('2024-03-15T10:30:00Z');

// Relative time
formatDistanceToNow(new Date('2024-03-01'), { addSuffix: true }); // '14 days ago'

// Date math
const tomorrow  = addDays(new Date(), 1);
const lastMonth = subMonths(new Date(), 1);

// Comparisons
isAfter(new Date('2024-12-31'), new Date());   // true
isBefore(new Date('2024-01-01'), new Date());  // true
differenceInDays(new Date('2024-12-31'), new Date()); // days until end of year

// Validation
isValid(new Date('2024-13-01'));  // false (month 13 doesn't exist)

// React usage
function TimeAgo({ isoString }) {
  const date = parseISO(isoString);
  return (
    <time dateTime={isoString} title={format(date, 'PPpp')}>
      {formatDistanceToNow(date, { addSuffix: true })}
    </time>
  );
}
```

### Lodash — Utility Functions

```bash
npm install lodash-es    # tree-shakeable ES module version
```

```jsx
import debounce from 'lodash-es/debounce';
import throttle from 'lodash-es/throttle';
import groupBy  from 'lodash-es/groupBy';
import orderBy  from 'lodash-es/orderBy';
import pick     from 'lodash-es/pick';
import omit     from 'lodash-es/omit';
import cloneDeep from 'lodash-es/cloneDeep';
import uniqBy   from 'lodash-es/uniqBy';

// ─── debounce: delay execution until user stops typing ───
const searchHandler = useCallback(
  debounce((query) => {
    searchApi(query);          // only called 500ms after last keystroke
  }, 500),
  []
);
<input onChange={(e) => searchHandler(e.target.value)} />

// ─── throttle: limit to once per 200ms ───
const onScroll = throttle(() => {
  console.log('scrolled');     // fires at most once per 200ms regardless of scroll speed
}, 200);

// ─── groupBy: transform flat array to grouped object ───
const users = [
  { name: 'Alice', role: 'admin' },
  { name: 'Bob',   role: 'user' },
  { name: 'Carol', role: 'admin' },
];
groupBy(users, 'role');
// { admin: [Alice, Carol], user: [Bob] }

// ─── orderBy: sort by multiple keys ───
orderBy(users, ['role', 'name'], ['asc', 'desc']);

// ─── pick / omit: select or exclude object keys ───
pick(user, ['name', 'email']);         // { name, email }
omit(user, ['password', 'ssn']);       // everything except sensitive fields

// ─── cloneDeep: avoid mutating nested state ───
const newState = cloneDeep(state);
newState.user.address.zip = '12345';  // safe: original state untouched

// ─── uniqBy: deduplicate array of objects ───
uniqBy([...existingUsers, ...newUsers], 'id'); // remove duplicates by id
```

### React Error Boundary (react-error-boundary)

```bash
npm install react-error-boundary
```

```jsx
import { ErrorBoundary, useErrorBoundary } from 'react-error-boundary';

// Fallback UI component
function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div role="alert" className="p-4 border border-danger rounded">
      <h4>Something went wrong:</h4>
      <pre className="text-danger">{error.message}</pre>
      <Button onClick={resetErrorBoundary}>Try Again</Button>
    </div>
  );
}

// Wrap components that might throw
function App() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onError={(error, info) => {
        logErrorToService(error, info.componentStack); // send to Sentry etc.
      }}
      onReset={() => {
        // optional: reset app state when user clicks "Try Again"
        queryClient.clear();
      }}
    >
      <Dashboard />
    </ErrorBoundary>
  );
}

// Throw from inside a component to trigger nearest boundary
function RiskyComponent() {
  const { showBoundary } = useErrorBoundary();

  const handleFetch = async () => {
    try {
      await fetchData();
    } catch (e) {
      showBoundary(e);  // programmatically trigger error boundary
    }
  };
}
```

---

## 23. Jest Unit Testing - Mental Model & Samples

> **Mental Model**: Every test follows **AAA** — **Arrange** (set up data & mocks), **Act** (call the thing under test), **Assert** (verify the outcome). If you can't write AAA clearly, the code may be too coupled.

```
┌──────────────────────────────────────────────────────────────────┐
│              Jest Testing Mental Model                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  UNIT TEST PYRAMID                                               │
│                                                                   │
│         /\          ← E2E (Playwright/Cypress) — few, slow       │
│        /  \                                                       │
│       /────\        ← Integration (RTL + MSW) — moderate         │
│      /      \                                                     │
│     /────────\      ← Unit (Jest) — many, fast, isolated         │
│    /──────────\                                                   │
│                                                                   │
│  What to unit test:                                              │
│  ✓ Pure functions (utils, transformers, validators)              │
│  ✓ Hooks (renderHook)                                            │
│  ✓ Redux reducers / Zustand stores                               │
│  ✓ Service/API layer functions                                   │
│  ✓ Component rendering + interactions (via RTL)                  │
│                                                                   │
│  What NOT to unit test:                                          │
│  ✗ Implementation details (internal state, method names)         │
│  ✗ Third-party library behavior                                  │
│  ✗ CSS/visual appearance                                         │
└──────────────────────────────────────────────────────────────────┘
```

### Installation & Configuration

```bash
# For Create React App — Jest is pre-configured
npm test

# For Vite — add Jest manually
npm install --save-dev jest @types/jest jest-environment-jsdom
npm install --save-dev @testing-library/react @testing-library/jest-dom @testing-library/user-event
npm install --save-dev babel-jest @babel/preset-env @babel/preset-react
```

```js
// jest.config.js
export default {
  testEnvironment: 'jsdom',           // simulates browser DOM
  setupFilesAfterFramework: ['./src/setupTests.js'],
  moduleNameMapper: {
    '\\.(css|scss)$': 'identity-obj-proxy',  // mock CSS imports
    '^@/(.*)$': '<rootDir>/src/$1',           // resolve path aliases
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.jsx',
  ],
};

// src/setupTests.js
import '@testing-library/jest-dom'; // adds custom matchers: toBeInTheDocument, etc.
```

### Core Jest API

```js
// ─── Test structure ───
describe('Calculator', () => {           // groups related tests
  describe('add()', () => {
    test('adds two positive numbers', () => { /* ... */ });  // test == it
    it('returns 0 when adding negative and positive', () => { /* ... */ });
  });

  // skip a test temporarily
  test.skip('failing test I will fix later', () => { /* ... */ });

  // only run this test (useful while debugging)
  test.only('focused test', () => { /* ... */ });
});

// ─── Setup & teardown ───
beforeAll(() => { /* runs once before all tests in this describe */ });
afterAll(() => {  /* runs once after all tests in this describe */ });
beforeEach(() => { /* runs before EACH test — reset state here */ });
afterEach(() => {  /* runs after EACH test — cleanup here */ });
```

### Matchers — The Complete List

```js
// ─── Equality ───
expect(2 + 2).toBe(4);                // strict equality (===), use for primitives
expect({ a: 1 }).toEqual({ a: 1 });   // deep equality, use for objects/arrays
expect({ a: 1, b: 2 }).toMatchObject({ a: 1 }); // partial match — extra keys ok

// ─── Truthiness ───
expect(true).toBeTruthy();
expect(null).toBeFalsy();
expect(undefined).toBeUndefined();
expect('value').toBeDefined();
expect(null).toBeNull();

// ─── Numbers ───
expect(4.5).toBeCloseTo(4.499, 1);    // floating point comparison with precision
expect(10).toBeGreaterThan(9);
expect(10).toBeGreaterThanOrEqual(10);
expect(5).toBeLessThan(6);

// ─── Strings ───
expect('hello world').toContain('world');
expect('hello world').toMatch(/world/);
expect('hello world').toMatch('world');  // substring

// ─── Arrays ───
expect([1, 2, 3]).toContain(2);
expect([1, 2, 3]).toHaveLength(3);
expect([{ id: 1 }, { id: 2 }]).toContainEqual({ id: 1 }); // deep equality in array

// ─── Objects ───
expect({ a: 1, b: 2 }).toHaveProperty('a');
expect({ a: 1, b: 2 }).toHaveProperty('a', 1);

// ─── Errors ───
expect(() => divide(1, 0)).toThrow();
expect(() => divide(1, 0)).toThrow('Division by zero');
expect(() => divide(1, 0)).toThrow(Error);

// ─── Mocks ───
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledTimes(2);
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenLastCalledWith('last-arg');
expect(mockFn).toHaveReturnedWith('return-value');

// ─── DOM (from @testing-library/jest-dom) ───
expect(element).toBeInTheDocument();
expect(element).toBeVisible();
expect(element).toBeEnabled();
expect(element).toBeDisabled();
expect(element).toHaveTextContent('Hello');
expect(element).toHaveValue('input value');
expect(element).toHaveClass('active');
expect(element).toHaveAttribute('href', '/home');
expect(element).toHaveFocus();
expect(element).toBeChecked();
```

### Mocking — The Key Skill

```js
// ─── Mock a function ───
const mockAdd = jest.fn();                    // empty mock — returns undefined
const mockAdd = jest.fn().mockReturnValue(42); // always returns 42
const mockAdd = jest.fn()
  .mockReturnValueOnce(1)                    // first call returns 1
  .mockReturnValueOnce(2)                    // second call returns 2
  .mockReturnValue(3);                       // subsequent calls return 3

// Async mock
const mockFetch = jest.fn().mockResolvedValue({ data: 'result' });      // resolved promise
const mockFetch = jest.fn().mockRejectedValue(new Error('Network error')); // rejected promise

// Mock implementation
const mockTransform = jest.fn().mockImplementation((x) => x * 2);

// ─── Mock an entire module ───
jest.mock('./userService');                   // auto-mock: all exports become jest.fn()

// Selective mock — keep some real, mock others
jest.mock('./utils', () => ({
  ...jest.requireActual('./utils'),           // use real implementations
  formatDate: jest.fn().mockReturnValue('Jan 1, 2024'), // override this one
}));

// ─── Mock module with factory ───
jest.mock('axios', () => ({
  default: {
    get:    jest.fn(),
    post:   jest.fn(),
    create: jest.fn().mockReturnThis(),      // chainable
    interceptors: {
      request:  { use: jest.fn() },
      response: { use: jest.fn() },
    },
  },
}));

// ─── Spy on existing function (don't replace, just observe) ───
const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {}); // silence console.error
const mathSpy    = jest.spyOn(Math, 'random').mockReturnValue(0.5);

afterEach(() => {
  consoleSpy.mockRestore();                  // restore original implementation
  jest.clearAllMocks();                      // clear call history (not implementation)
  jest.resetAllMocks();                      // clear + reset implementations
  jest.restoreAllMocks();                    // restore all spies
});
```

### Testing Pure Functions (Unit)

```js
// ─── utils/calculate.js ───
export function calculateTax(amount, rate) {
  if (amount < 0) throw new Error('Amount cannot be negative');
  return Math.round(amount * rate * 100) / 100;
}

export function formatCurrency(amount, currency = 'USD') {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency }).format(amount);
}

// ─── utils/calculate.test.js ───
import { calculateTax, formatCurrency } from './calculate';

describe('calculateTax', () => {
  // AAA structure on every test
  test('calculates correct tax for positive amount', () => {
    // Arrange
    const amount = 100;
    const rate   = 0.08;

    // Act
    const result = calculateTax(amount, rate);

    // Assert
    expect(result).toBe(8.00);
  });

  test('rounds to 2 decimal places', () => {
    expect(calculateTax(100, 0.0825)).toBe(8.25);
  });

  test('returns 0 for 0 amount', () => {
    expect(calculateTax(0, 0.08)).toBe(0);
  });

  test('throws for negative amount', () => {
    expect(() => calculateTax(-100, 0.08)).toThrow('Amount cannot be negative');
  });

  // Parameterized tests — avoid repetition
  test.each([
    [100,  0.05, 5.00],
    [200,  0.10, 20.00],
    [99.9, 0.08, 7.99],
  ])('calculateTax(%s, %s) = %s', (amount, rate, expected) => {
    expect(calculateTax(amount, rate)).toBe(expected);
  });
});
```

### Testing React Components (with RTL)

```jsx
// ─── components/Counter.jsx ───
import { useState } from 'react';

export function Counter({ initialCount = 0, max = 10 }) {
  const [count, setCount] = useState(initialCount);
  const atMax = count >= max;

  return (
    <div>
      <output aria-live="polite" data-testid="count">{count}</output>
      <button onClick={() => setCount(c => c + 1)} disabled={atMax}>
        Increment
      </button>
      <button onClick={() => setCount(c => c - 1)} disabled={count <= 0}>
        Decrement
      </button>
      {atMax && <p role="alert">Maximum reached!</p>}
    </div>
  );
}

// ─── components/Counter.test.jsx ───
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

// Query priority: getByRole > getByLabelText > getByPlaceholderText > getByText > getByTestId
// get* throws if not found; query* returns null; find* is async (returns promise)

describe('Counter', () => {
  test('renders with initial count of 0 by default', () => {
    render(<Counter />);
    expect(screen.getByTestId('count')).toHaveTextContent('0');
  });

  test('renders with custom initial count', () => {
    render(<Counter initialCount={5} />);
    expect(screen.getByTestId('count')).toHaveTextContent('5');
  });

  test('increments count when Increment button is clicked', async () => {
    const user = userEvent.setup();     // creates a user-event instance
    render(<Counter />);

    await user.click(screen.getByRole('button', { name: /increment/i }));

    expect(screen.getByTestId('count')).toHaveTextContent('1');
  });

  test('does not go below 0', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={0} />);

    // Decrement button should be disabled at 0
    expect(screen.getByRole('button', { name: /decrement/i })).toBeDisabled();
  });

  test('shows max alert and disables Increment when max is reached', async () => {
    const user = userEvent.setup();
    render(<Counter initialCount={9} max={10} />);

    await user.click(screen.getByRole('button', { name: /increment/i }));

    expect(screen.getByRole('alert')).toHaveTextContent(/maximum reached/i);
    expect(screen.getByRole('button', { name: /increment/i })).toBeDisabled();
  });
});
```

### Testing Async Components & API Calls

```jsx
// ─── components/UserList.jsx ───
import { useEffect, useState } from 'react';

export function UserList() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/users')
      .then(r => { if (!r.ok) throw new Error('Failed to load'); return r.json(); })
      .then(data => { setUsers(data); setLoading(false); })
      .catch(e => { setError(e.message); setLoading(false); });
  }, []);

  if (loading) return <p>Loading users...</p>;
  if (error)   return <p role="alert">Error: {error}</p>;
  return (
    <ul>
      {users.map(u => <li key={u.id}>{u.name}</li>)}
    </ul>
  );
}

// ─── components/UserList.test.jsx ───
import { render, screen, waitFor } from '@testing-library/react';
import { UserList } from './UserList';

// Mock global fetch
global.fetch = jest.fn();

describe('UserList', () => {
  beforeEach(() => {
    jest.clearAllMocks();                // reset mock between tests
  });

  test('shows loading state initially', () => {
    fetch.mockResolvedValueOnce({
      ok: true,
      json: () => new Promise(() => {}), // never resolves — keeps in loading state
    });
    render(<UserList />);
    expect(screen.getByText(/loading users/i)).toBeInTheDocument();
  });

  test('renders users after successful fetch', async () => {
    // Arrange: mock fetch to return user data
    fetch.mockResolvedValueOnce({
      ok: true,
      json: async () => [
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' },
      ],
    });

    // Act
    render(<UserList />);

    // Assert: wait for async state update to complete
    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(screen.getByText('Bob')).toBeInTheDocument();
    });
    expect(screen.queryByText(/loading/i)).not.toBeInTheDocument();
  });

  test('shows error when fetch fails', async () => {
    fetch.mockResolvedValueOnce({ ok: false });
    render(<UserList />);

    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/error/i);
    });
  });
});
```

### Testing Custom Hooks (renderHook)

```jsx
// ─── hooks/useCounter.js ───
import { useState, useCallback } from 'react';

export function useCounter(initialValue = 0, step = 1) {
  const [count, setCount] = useState(initialValue);
  const increment = useCallback(() => setCount(c => c + step), [step]);
  const decrement = useCallback(() => setCount(c => c - step), [step]);
  const reset     = useCallback(() => setCount(initialValue),  [initialValue]);
  return { count, increment, decrement, reset };
}

// ─── hooks/useCounter.test.js ───
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  test('initializes with 0 by default', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  test('initializes with custom value', () => {
    const { result } = renderHook(() => useCounter(10));
    expect(result.current.count).toBe(10);
  });

  test('increments by step amount', () => {
    const { result } = renderHook(() => useCounter(0, 5));

    // State updates inside hooks MUST be wrapped in act()
    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(5);
  });

  test('resets to initial value', () => {
    const { result } = renderHook(() => useCounter(10));

    act(() => {
      result.current.increment();
      result.current.increment();
      result.current.reset();
    });

    expect(result.current.count).toBe(10);
  });

  test('reacts to prop changes (rerender)', () => {
    const { result, rerender } = renderHook(
      ({ step }) => useCounter(0, step),
      { initialProps: { step: 1 } }
    );

    act(() => result.current.increment());
    expect(result.current.count).toBe(1);

    // Change step and increment again
    rerender({ step: 10 });
    act(() => result.current.increment());
    expect(result.current.count).toBe(11);
  });
});
```

### Testing with Providers (Context / React Query)

```jsx
// ─── test-utils/render.jsx ───
// Custom render that wraps all providers — import this instead of RTL's render
import { render } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { BrowserRouter } from 'react-router-dom';
import { AuthContext } from '../contexts/AuthContext';

function createTestQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: { retry: false },  // don't retry in tests — faster failures
    },
    logger: { error: () => {} },  // silence error logs in tests
  });
}

export function renderWithProviders(
  ui,
  {
    authValue = { user: null, login: jest.fn(), logout: jest.fn() },
    ...renderOptions
  } = {}
) {
  const queryClient = createTestQueryClient();

  function Wrapper({ children }) {
    return (
      <QueryClientProvider client={queryClient}>
        <BrowserRouter>
          <AuthContext.Provider value={authValue}>
            {children}
          </AuthContext.Provider>
        </BrowserRouter>
      </QueryClientProvider>
    );
  }

  return render(ui, { wrapper: Wrapper, ...renderOptions });
}

// ─── Usage in tests ───
import { renderWithProviders } from '../test-utils/render';

test('shows user name when logged in', () => {
  renderWithProviders(<Navbar />, {
    authValue: { user: { name: 'Alice', role: 'admin' }, login: jest.fn(), logout: jest.fn() },
  });
  expect(screen.getByText('Alice')).toBeInTheDocument();
});

test('shows login link when logged out', () => {
  renderWithProviders(<Navbar />);  // authValue defaults to { user: null }
  expect(screen.getByRole('link', { name: /login/i })).toBeInTheDocument();
});
```

### Testing Forms (Formik + RTL)

```jsx
// ─── LoginForm.test.jsx ───
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  const mockLogin = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders all form fields', () => {
    render(<LoginForm onSubmit={mockLogin} />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /login/i })).toBeInTheDocument();
  });

  test('shows validation errors on empty submit', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockLogin} />);

    // Submit without filling anything
    await user.click(screen.getByRole('button', { name: /login/i }));

    // Wait for Formik to run validation
    await waitFor(() => {
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
      expect(screen.getByText(/password is required/i)).toBeInTheDocument();
    });

    expect(mockLogin).not.toHaveBeenCalled();
  });

  test('shows email format error for invalid email', async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={mockLogin} />);

    await user.type(screen.getByLabelText(/email/i), 'not-an-email');
    await user.tab();   // trigger onBlur

    await waitFor(() => {
      expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
  });

  test('calls onSubmit with form values when valid', async () => {
    const user = userEvent.setup();
    mockLogin.mockResolvedValueOnce({ token: 'abc' });
    render(<LoginForm onSubmit={mockLogin} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'Password1!');
    await user.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'Password1!',
      });
    });
  });

  test('disables button and shows loading while submitting', async () => {
    const user = userEvent.setup();
    // mockLogin returns a promise that never resolves — keeps form in submitting state
    mockLogin.mockReturnValue(new Promise(() => {}));
    render(<LoginForm onSubmit={mockLogin} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'Password1!');
    await user.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByRole('button', { name: /logging in/i })).toBeDisabled();
    });
  });
});
```

### Snapshot Testing

```jsx
// Snapshot tests — catch unintended UI changes
import { render } from '@testing-library/react';
import { Badge } from './Badge';

test('renders primary badge correctly', () => {
  const { container } = render(<Badge variant="primary">New</Badge>);
  expect(container).toMatchSnapshot();
  // First run: creates __snapshots__/Badge.test.jsx.snap
  // Subsequent runs: compares to saved snapshot — fails on any change
});

// Update snapshots when intentional change is made:
// jest --updateSnapshot   (or press 'u' in watch mode)

// Inline snapshot — snapshot stored in the test file itself
test('renders badge inline snapshot', () => {
  const { container } = render(<Badge variant="success">Active</Badge>);
  expect(container).toMatchInlineSnapshot(`
    <div>
      <span class="badge badge-success">
        Active
      </span>
    </div>
  `);
});

// ⚠️ Warning: Don't over-use snapshots — they break on any change
// Best used for: stable leaf components, configuration objects, error messages
// Avoid for: pages, layouts, anything that changes frequently
```

### MSW (Mock Service Worker) — API Mocking

```bash
npm install msw --save-dev
```

```jsx
// ─── mocks/handlers.js — define API mock handlers ───
import { http, HttpResponse } from 'msw';

export const handlers = [
  // GET /api/users — returns user list
  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: 1, name: 'Alice', email: 'alice@example.com' },
      { id: 2, name: 'Bob',   email: 'bob@example.com' },
    ]);
  }),

  // POST /api/users — create user
  http.post('/api/users', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 3, ...body }, { status: 201 });
  }),

  // Error scenario
  http.get('/api/users/:id', ({ params }) => {
    if (params.id === '999') {
      return HttpResponse.json({ error: 'Not found' }, { status: 404 });
    }
    return HttpResponse.json({ id: params.id, name: 'Test User' });
  }),
];

// ─── mocks/server.js ───
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// ─── setupTests.js ───
import { server } from './mocks/server';
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());   // reset overrides between tests
afterAll(() => server.close());

// ─── In tests — override handlers for specific scenarios ───
import { server } from '../mocks/server';
import { http, HttpResponse } from 'msw';

test('shows error when API fails', async () => {
  // Override the handler just for this test
  server.use(
    http.get('/api/users', () => {
      return HttpResponse.json({ error: 'Server error' }, { status: 500 });
    })
  );

  render(<UserList />);
  await waitFor(() => {
    expect(screen.getByRole('alert')).toHaveTextContent(/error/i);
  });
});
```

### Coverage & Quality

```bash
# Run tests with coverage report
npm test -- --coverage

# Coverage thresholds in jest.config.js
coverageThreshold: {
  global: {
    branches:   80,    // % of if/else branches executed
    functions:  80,    // % of functions called
    lines:      80,    // % of lines executed
    statements: 80,    // % of statements executed
  },
},
```

```
Coverage Report Example:
─────────────────────────────────────────────────────────
File               | Stmts | Branch | Funcs | Lines
─────────────────────────────────────────────────────────
calculate.js       |   100 |    100 |   100 |   100   ✓
UserList.jsx       |    95 |     80 |   100 |    95   ✓
LoginForm.jsx      |    60 |     50 |    75 |    60   ✗ (needs more tests)
─────────────────────────────────────────────────────────
```

### Jest + TypeScript

```bash
npm install --save-dev ts-jest @types/jest
```

```ts
// jest.config.ts
export default {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.tsx?$': ['ts-jest', { tsconfig: './tsconfig.json' }],
  },
};

// Typed mock
const mockFn = jest.fn<Promise<User>, [string]>(); // fn(id: string) => Promise<User>
mockFn.mockResolvedValue({ id: '1', name: 'Alice' } as User);

// jest.mocked() preserves types
import { getUser } from './userService';
jest.mock('./userService');
const mockGetUser = jest.mocked(getUser);           // typed as jest.MockedFunction<typeof getUser>
mockGetUser.mockResolvedValue({ id: '1', name: 'Alice' });
```

### Testing Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| Testing implementation details | Tests break on refactor | Test behavior/output |
| `getByTestId` overuse | Fragile, not user-facing | Prefer `getByRole`, `getByLabelText` |
| No `beforeEach` cleanup | Tests leak state into each other | `jest.clearAllMocks()` in `beforeEach` |
| Mocking everything | Tests don't reflect reality | Mock only boundaries (network, time) |
| `waitFor` with `fireEvent` | Race conditions | Use `userEvent` + `await` |
| Snapshot everything | False security, noisy diffs | Snapshot only stable leaf components |
| Testing third-party libs | Not your code | Trust the library, test your integration |
| `act()` warnings ignored | Hidden async bugs | Fix by awaiting state updates properly |
