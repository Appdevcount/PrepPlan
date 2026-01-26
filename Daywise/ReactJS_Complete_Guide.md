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

```jsx
// 1. Single Root Element (or Fragment)
// BAD
return (
  <h1>Title</h1>
  <p>Content</p>  // Error: Adjacent JSX elements
);

// GOOD - Wrapper div
return (
  <div>
    <h1>Title</h1>
    <p>Content</p>
  </div>
);

// BETTER - Fragment (no extra DOM node)
return (
  <>
    <h1>Title</h1>
    <p>Content</p>
  </>
);

// 2. JavaScript Expressions in Curly Braces
const name = 'John';
const element = <h1>Hello, {name}!</h1>;
const calculated = <p>Sum: {2 + 2}</p>;
const conditional = <p>{isLoggedIn ? 'Welcome!' : 'Please log in'}</p>;

// 3. Attributes use camelCase
<button onClick={handleClick} className="btn" tabIndex={0}>
  Click me
</button>

// HTML attributes that differ in JSX:
// class → className
// for → htmlFor
// tabindex → tabIndex
// onclick → onClick

// 4. Self-closing tags must have /
<input type="text" />
<img src="image.jpg" alt="description" />
<br />

// 5. Style is an object
const divStyle = {
  backgroundColor: 'blue',
  fontSize: '16px',  // camelCase, not font-size
  padding: '20px'
};
<div style={divStyle}>Styled div</div>

// Inline style
<div style={{ color: 'red', marginTop: '10px' }}>Inline styled</div>

// 6. Comments in JSX
return (
  <div>
    {/* This is a comment */}
    <h1>Hello</h1>
    {
      // Single line comment
    }
  </div>
);

// 7. Boolean attributes
<input disabled />           // Same as disabled={true}
<input disabled={false} />   // Not disabled
<button hidden>Can't see me</button>

// 8. Spread attributes
const props = { id: 'main', className: 'container', onClick: handleClick };
<div {...props}>Content</div>

// 9. Conditional Rendering
// Ternary
{isLoggedIn ? <UserDashboard /> : <LoginForm />}

// Logical AND (short-circuit)
{hasNotifications && <NotificationBadge count={5} />}

// Logical OR (fallback)
{user.name || 'Anonymous'}

// Null/undefined render nothing
{null}      // Renders nothing
{undefined} // Renders nothing
{false}     // Renders nothing
{0}         // Renders "0" (gotcha!)
```

### Rendering Lists

```jsx
// Basic list rendering
const items = ['Apple', 'Banana', 'Cherry'];

function FruitList() {
  return (
    <ul>
      {items.map((item, index) => (
        <li key={index}>{item}</li>  // index as key is not ideal
      ))}
    </ul>
  );
}

// Better: Use unique IDs as keys
const products = [
  { id: 'p1', name: 'Laptop', price: 999 },
  { id: 'p2', name: 'Phone', price: 699 },
  { id: 'p3', name: 'Tablet', price: 499 }
];

function ProductList() {
  return (
    <div>
      {products.map(product => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  );
}

// Why keys matter:
// Keys help React identify which items changed, added, or removed
// Without proper keys, React may re-render entire list unnecessarily

// BAD: Using index as key (problems with reordering, filtering)
{items.map((item, index) => <Item key={index} {...item} />)}

// GOOD: Using unique, stable ID
{items.map(item => <Item key={item.id} {...item} />)}

// Keys must be:
// 1. Unique among siblings (not globally)
// 2. Stable (don't change between renders)
// 3. Not random (Math.random() creates new key each render)
```

---

## 3. Components & Props

### Functional Components

```jsx
// Basic functional component
function Welcome(props) {
  return <h1>Hello, {props.name}!</h1>;
}

// Arrow function component
const Welcome = (props) => {
  return <h1>Hello, {props.name}!</h1>;
};

// With destructuring
const Welcome = ({ name, age }) => {
  return <h1>Hello, {name}! You are {age} years old.</h1>;
};

// With default props
const Welcome = ({ name = 'Guest', age = 0 }) => {
  return <h1>Hello, {name}!</h1>;
};

// Usage
<Welcome name="John" age={25} />
```

### Props Deep Dive

```jsx
// Props are read-only (immutable)
function BadComponent(props) {
  props.name = 'Changed'; // ❌ Error! Cannot modify props
  return <h1>{props.name}</h1>;
}

// Props can be any JavaScript value
<UserProfile
  name="John"                           // String
  age={25}                              // Number
  isAdmin={true}                        // Boolean
  roles={['user', 'editor']}            // Array
  address={{ city: 'NYC', zip: '10001' }} // Object
  onClick={handleClick}                  // Function
  icon={<StarIcon />}                    // React element
/>

// Children prop
function Card({ children, title }) {
  return (
    <div className="card">
      <h2>{title}</h2>
      <div className="card-body">
        {children}
      </div>
    </div>
  );
}

// Usage
<Card title="User Info">
  <p>Name: John Doe</p>
  <p>Email: john@example.com</p>
</Card>

// Render props pattern
function DataFetcher({ url, render }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => {
        setData(data);
        setLoading(false);
      });
  }, [url]);

  return render({ data, loading });
}

// Usage
<DataFetcher
  url="/api/users"
  render={({ data, loading }) =>
    loading ? <Spinner /> : <UserList users={data} />
  }
/>
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

### useState Hook

```jsx
import { useState } from 'react';

function Counter() {
  // Basic state
  const [count, setCount] = useState(0);

  // Object state
  const [user, setUser] = useState({ name: '', email: '' });

  // Array state
  const [items, setItems] = useState([]);

  // Lazy initialization (for expensive computations)
  const [data, setData] = useState(() => {
    const stored = localStorage.getItem('data');
    return stored ? JSON.parse(stored) : defaultValue;
  });

  return (
    <div>
      {/* Updating primitive state */}
      <button onClick={() => setCount(count + 1)}>
        Count: {count}
      </button>

      {/* Functional update (when new state depends on previous) */}
      <button onClick={() => setCount(prev => prev + 1)}>
        Increment
      </button>

      {/* Updating object state (must spread!) */}
      <input
        value={user.name}
        onChange={(e) => setUser({ ...user, name: e.target.value })}
      />

      {/* Updating nested object */}
      <button onClick={() => setUser(prev => ({
        ...prev,
        address: {
          ...prev.address,
          city: 'New York'
        }
      }))}>
        Update City
      </button>

      {/* Adding to array */}
      <button onClick={() => setItems(prev => [...prev, newItem])}>
        Add Item
      </button>

      {/* Removing from array */}
      <button onClick={() => setItems(prev =>
        prev.filter(item => item.id !== idToRemove)
      )}>
        Remove Item
      </button>

      {/* Updating item in array */}
      <button onClick={() => setItems(prev =>
        prev.map(item =>
          item.id === idToUpdate
            ? { ...item, name: 'Updated' }
            : item
        )
      )}>
        Update Item
      </button>
    </div>
  );
}
```

### State Batching

```jsx
// React 18 automatic batching
function handleClick() {
  // These are batched into a single re-render (React 18+)
  setCount(c => c + 1);
  setFlag(f => !f);
  setName('John');
  // Only ONE re-render happens!
}

// Before React 18, batching only worked in event handlers
// Now it works everywhere: setTimeout, promises, native event handlers

// Opt out of batching (rare use case)
import { flushSync } from 'react-dom';

function handleClick() {
  flushSync(() => {
    setCount(c => c + 1);
  });
  // DOM updated here

  flushSync(() => {
    setFlag(f => !f);
  });
  // DOM updated here
}
```

### Common State Mistakes

```jsx
// ❌ MISTAKE 1: Direct state mutation
const [user, setUser] = useState({ name: 'John', age: 25 });
user.age = 26;  // Mutating directly - won't trigger re-render!
setUser(user);  // Same reference - React thinks nothing changed

// ✅ CORRECT: Create new object
setUser({ ...user, age: 26 });

// ❌ MISTAKE 2: Using stale state
const [count, setCount] = useState(0);
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

### useEffect

```jsx
import { useEffect, useState } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Basic effect - runs after every render
  useEffect(() => {
    console.log('Component rendered');
  });

  // Effect with empty deps - runs once on mount
  useEffect(() => {
    console.log('Component mounted');
  }, []);

  // Effect with dependencies - runs when deps change
  useEffect(() => {
    console.log('userId changed:', userId);
  }, [userId]);

  // Effect with cleanup
  useEffect(() => {
    const subscription = websocket.subscribe(userId);

    // Cleanup function runs before next effect and on unmount
    return () => {
      subscription.unsubscribe();
    };
  }, [userId]);

  // Data fetching pattern
  useEffect(() => {
    let cancelled = false;  // Prevent state update on unmounted component

    async function fetchUser() {
      setLoading(true);
      setError(null);

      try {
        const response = await fetch(`/api/users/${userId}`);
        if (!response.ok) throw new Error('Failed to fetch');

        const data = await response.json();

        if (!cancelled) {
          setUser(data);
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

    fetchUser();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  // Event listener pattern
  useEffect(() => {
    function handleResize() {
      console.log('Window resized');
    }

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  // Timer pattern
  useEffect(() => {
    const intervalId = setInterval(() => {
      console.log('Tick');
    }, 1000);

    return () => {
      clearInterval(intervalId);
    };
  }, []);

  if (loading) return <Spinner />;
  if (error) return <Error message={error} />;
  if (!user) return null;

  return <div>{user.name}</div>;
}
```

### useRef

```jsx
import { useRef, useEffect, useState } from 'react';

function TextInput() {
  // DOM reference
  const inputRef = useRef(null);

  // Mutable value that persists across renders (doesn't trigger re-render)
  const renderCount = useRef(0);

  // Previous value
  const prevValue = useRef('');

  const [value, setValue] = useState('');

  useEffect(() => {
    renderCount.current += 1;
    console.log('Render count:', renderCount.current);
  });

  useEffect(() => {
    prevValue.current = value;
  }, [value]);

  // Focus input on mount
  useEffect(() => {
    inputRef.current.focus();
  }, []);

  // Access DOM methods
  const handleSelect = () => {
    inputRef.current.select();
  };

  const handleScroll = () => {
    inputRef.current.scrollIntoView({ behavior: 'smooth' });
  };

  return (
    <div>
      <input
        ref={inputRef}
        value={value}
        onChange={(e) => setValue(e.target.value)}
      />
      <p>Current: {value}</p>
      <p>Previous: {prevValue.current}</p>
      <button onClick={handleSelect}>Select All</button>
    </div>
  );
}

// Forwarding refs to child components
const FancyInput = React.forwardRef((props, ref) => {
  return <input ref={ref} className="fancy-input" {...props} />;
});

// Usage
function Parent() {
  const inputRef = useRef(null);

  return (
    <>
      <FancyInput ref={inputRef} />
      <button onClick={() => inputRef.current.focus()}>
        Focus Input
      </button>
    </>
  );
}

// useImperativeHandle - customize ref value
const FancyInput = React.forwardRef((props, ref) => {
  const inputRef = useRef(null);

  useImperativeHandle(ref, () => ({
    focus: () => inputRef.current.focus(),
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
