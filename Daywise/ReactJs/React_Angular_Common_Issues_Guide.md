# React & Angular — Common Issues, Pitfalls & Solutions
## From Beginner Mistakes to Expert-Level Debugging

> **Who this is for:** Developers preparing for front-end / full-stack interviews or code reviews who want to demonstrate production-level awareness of framework-specific bugs, anti-patterns, and their fixes.
>
> **How to use:** Each issue follows a strict template. Read the Symptom first — if you've seen it, skip to the Fix. If not, read Root Cause + Mental Model first.

---

## Table of Contents

### React Issues
- [Issue #1: Mutating State Directly](#issue-1-mutating-state-directly)
- [Issue #2: Missing Dependency Array in useEffect](#issue-2-missing-dependency-array-in-useeffect)
- [Issue #3: Calling Hooks Conditionally](#issue-3-calling-hooks-conditionally)
- [Issue #4: Using Index as Key in Lists](#issue-4-using-index-as-key-in-lists)
- [Issue #5: Async in useEffect Returns Promise](#issue-5-async-in-useeffect-returns-promise)
- [Issue #6: Event Handler vs Invocation](#issue-6-event-handler-vs-invocation)
- [Issue #7: Stale Closure in useCallback / useMemo](#issue-7-stale-closure-in-usecallback--usememo)
- [Issue #8: useEffect Cleanup Not Implemented](#issue-8-useeffect-cleanup-not-implemented)
- [Issue #9: Prop Drilling Hell](#issue-9-prop-drilling-hell)
- [Issue #10: Unnecessary Re-renders](#issue-10-unnecessary-re-renders)
- [Issue #11: Race Condition in Async Fetch](#issue-11-race-condition-in-async-fetch)
- [Issue #12: Context Causing Full Tree Re-render](#issue-12-context-causing-full-tree-re-render)
- [Issue #13: Memory Leak — Event Listeners Not Cleaned Up](#issue-13-memory-leak--event-listeners-not-cleaned-up)
- [Issue #14: Concurrent Mode Tearing](#issue-14-concurrent-mode-tearing)
- [Issue #15: useLayoutEffect vs useEffect Timing](#issue-15-uselayouteffect-vs-useeffect-timing)
- [Issue #16: Bundle Size / Code Splitting Not Done](#issue-16-bundle-size--code-splitting-not-done)
- [Issue #17: Hydration Mismatch in Next.js SSR](#issue-17-hydration-mismatch-in-nextjs-ssr)
- [Issue #18: Custom Hook Infinite Loop](#issue-18-custom-hook-infinite-loop)

### Angular Issues
- [Issue #19: Nested Subscribe Anti-pattern](#issue-19-nested-subscribe-anti-pattern)
- [Issue #20: Forgetting to Unsubscribe](#issue-20-forgetting-to-unsubscribe)
- [Issue #21: Mutating @Input() Directly in Child](#issue-21-mutating-input-directly-in-child)
- [Issue #22: Heavy Logic in Constructor](#issue-22-heavy-logic-in-constructor)
- [Issue #23: Missing Module Import](#issue-23-missing-module-import)
- [Issue #24: Not Using Async Pipe](#issue-24-not-using-async-pipe)
- [Issue #25: ExpressionChangedAfterItHasBeenCheckedError](#issue-25-expressionchangedafterithasbeencheckederror)
- [Issue #26: OnPush Not Detecting Nested Object Mutation](#issue-26-onpush-not-detecting-nested-object-mutation)
- [Issue #27: shareReplay Memory Leak](#issue-27-sharereplay-memory-leak)
- [Issue #28: Cold vs Hot Observable Confusion](#issue-28-cold-vs-hot-observable-confusion)
- [Issue #29: RxJS Operator Order Bug](#issue-29-rxjs-operator-order-bug)
- [Issue #30: Template Expression Side Effects](#issue-30-template-expression-side-effects)
- [Issue #31: Zone.js Performance — Running Outside NgZone](#issue-31-zonejs-performance--running-outside-ngzone)
- [Issue #32: OnPush + Async Pipe Broken](#issue-32-onpush--async-pipe-broken)
- [Issue #33: Circular Dependency in DI](#issue-33-circular-dependency-in-di)
- [Issue #34: Memory Leak in Route-Level Subscriptions](#issue-34-memory-leak-in-route-level-subscriptions)
- [Issue #35: Lazy-Loaded Module Service Singleton Broken](#issue-35-lazy-loaded-module-service-singleton-broken)
- [Issue #36: SSR / Universal — window/document Access](#issue-36-ssr--universal--windowdocument-access)

### Reference
- [React vs Angular Issue Equivalence Map](#react-vs-angular-issue-equivalence-map)
- [Quick Debug Checklist](#quick-debug-checklist)

---

# REACT ISSUES

## 🔴 Beginner

---

### Issue #1: Mutating State Directly
**Level:** 🔴 Beginner
**Symptom:** UI does not update after calling `arr.push(item)` or `this.state.items.push(item)`. The data is in the array when you log it, but the component never re-renders.
**Root Cause:** React uses referential equality to detect state changes. Mutating an existing object or array keeps the same reference, so React sees no difference between old and new state and skips the re-render entirely.

#### Wrong (problematic code)
```tsx
const [items, setItems] = useState<string[]>(['a', 'b']);

function addItem(newItem: string) {
  items.push(newItem);           // PROBLEM: mutates existing array — same reference
  setItems(items);               // PROBLEM: React compares old ref === new ref → true → no re-render
}
```

#### Fix
```tsx
const [items, setItems] = useState<string[]>(['a', 'b']);

function addItem(newItem: string) {
  // WHY: spread creates a NEW array reference — React detects the change
  setItems(prev => [...prev, newItem]);  // WHY: functional update reads freshest state value
}

// For objects:
const [user, setUser] = useState({ name: 'Alice', age: 30 });
function birthday() {
  // WHY: object spread creates a new reference with the updated field
  setUser(prev => ({ ...prev, age: prev.age + 1 }));
}
```

#### Mental Model
React's change detection is like a security guard who only checks your badge number (reference), not what's inside your bag — swap the badge (reference) to get let through.

#### Key Takeaway
- Never call `.push()`, `.splice()`, or direct assignment on state variables.
- Always return a new array/object from state updater functions.
- Use the functional form `setX(prev => ...)` when new state depends on old state.

---

### Issue #2: Missing Dependency Array in useEffect
**Level:** 🔴 Beginner
**Symptom:** Either (a) the effect runs on every render causing an infinite loop, or (b) the effect reads a stale value that never updates because the dependency array is `[]` even though the effect uses state.

**Root Cause:** `useEffect` without a dependency array runs after every render. With `[]` it runs only once. If variables used inside the effect are omitted from the array, the effect captures their initial values and never re-reads updated ones.

#### Wrong (problematic code)
```tsx
function Counter() {
  const [count, setCount] = useState(0);

  // PROBLEM: no dependency array → runs after every render
  useEffect(() => {
    setCount(count + 1); // this triggers a re-render → infinite loop
  });

  // PROBLEM: stale closure — count is always 0 inside this effect
  useEffect(() => {
    const id = setInterval(() => {
      console.log('count:', count); // PROBLEM: always prints 0
    }, 1000);
    return () => clearInterval(id);
  }, []); // PROBLEM: count omitted from deps
}
```

#### Fix
```tsx
function Counter() {
  const [count, setCount] = useState(0);

  // WHY: functional updater avoids needing count in deps
  useEffect(() => {
    const id = setInterval(() => {
      setCount(prev => prev + 1); // WHY: always has fresh value without dep on count
    }, 1000);
    return () => clearInterval(id); // WHY: cleanup prevents timer leak
  }, []); // WHY: truly no external deps now

  // If you DO need count in the effect, list it:
  useEffect(() => {
    document.title = `Count: ${count}`; // WHY: count is a dep, so list it
  }, [count]); // FIX: re-runs only when count changes
}
```

#### Mental Model
The dependency array is your promise to React: "I will list every outside value this effect reads." Break that promise and the effect goes blind to changes.

#### Key Takeaway
- Run `eslint-plugin-react-hooks` — it catches missing deps automatically.
- Prefer functional updater `setState(prev => ...)` to reduce deps.
- Every variable read inside `useEffect` that comes from component scope must be in the array.

---

### Issue #3: Calling Hooks Conditionally
**Level:** 🔴 Beginner
**Symptom:** React throws: `"React Hook 'useState' is called conditionally. React Hooks must be called in the exact same order in every component render."`

**Root Cause:** React tracks hooks by call order (an internal linked list). If hooks are skipped on some renders, the list shifts and the wrong state is returned to the wrong hook.

#### Wrong (problematic code)
```tsx
function UserProfile({ isLoggedIn }: { isLoggedIn: boolean }) {
  if (!isLoggedIn) return <div>Please log in</div>; // PROBLEM: early return before hooks

  const [profile, setProfile] = useState(null); // PROBLEM: not always called
  useEffect(() => { /* fetch profile */ }, []);  // PROBLEM: skipped when !isLoggedIn
}
```

#### Fix
```tsx
function UserProfile({ isLoggedIn }: { isLoggedIn: boolean }) {
  // WHY: all hooks declared unconditionally at the top level
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    if (!isLoggedIn) return; // FIX: guard inside the effect, not around the hook
    // fetch profile...
  }, [isLoggedIn]);

  if (!isLoggedIn) return <div>Please log in</div>; // FIX: early return AFTER hooks
}
```

#### Mental Model
Hooks are seats in a theater — every seat must be occupied in the same order every performance. Moving or removing a seat mid-show breaks the entire seating chart.

#### Key Takeaway
- Never put hooks inside `if`, `for`, `switch`, or after an early `return`.
- Put the guard logic inside the hook's callback, not around the hook call.

---

### Issue #4: Using Index as Key in Lists
**Level:** 🔴 Beginner
**Symptom:** Reordering or deleting list items causes wrong items to be updated, input values stick to wrong positions, or animations jump to incorrect elements.

**Root Cause:** React uses `key` to identify which DOM element corresponds to which list item across renders. When index is the key, a deleted item causes all subsequent items to shift keys, making React reuse the wrong DOM nodes.

#### Wrong (problematic code)
```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map((todo, index) => (
        <li key={index}> {/* PROBLEM: index key shifts when item deleted */}
          <input defaultValue={todo.text} /> {/* PROBLEM: input retains wrong value after delete */}
        </li>
      ))}
    </ul>
  );
}
```

#### Fix
```tsx
function TodoList({ todos }: { todos: Todo[] }) {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}> {/* WHY: stable, unique ID → React correctly identifies each item */}
          <input defaultValue={todo.text} />
        </li>
      ))}
    </ul>
  );
}
```

#### Mental Model
Using index as a key is like labeling passengers by seat number instead of passport — swap seats and you've misidentified everyone.

#### Key Takeaway
- Always use a stable, unique ID (DB id, UUID) as the `key`.
- Index as key is only safe for static, never-reordered, never-deleted lists.

---

### Issue #5: Async in useEffect Returns Promise
**Level:** 🔴 Beginner
**Symptom:** React warns: `"Warning: An update to X inside a test was not wrapped in act(...)"`; or cleanup is never called because useEffect received a Promise instead of a cleanup function.

**Root Cause:** `useEffect` expects its callback to return either `undefined` or a synchronous cleanup function. An `async` function always returns a Promise, which React ignores — meaning cleanup never runs.

#### Wrong (problematic code)
```tsx
useEffect(async () => {           // PROBLEM: async function returns Promise, not cleanup fn
  const data = await fetchData();
  setData(data);
  return () => { /* this cleanup is inside the Promise, never called by React */ };
}, []);
```

#### Fix
```tsx
useEffect(() => {
  let cancelled = false; // WHY: cancellation flag for cleanup

  async function load() {
    const data = await fetchData();
    if (!cancelled) setData(data); // WHY: guard prevents state update after unmount
  }

  load(); // WHY: call the async IIFE, effect itself stays synchronous

  return () => { cancelled = true; }; // WHY: synchronous cleanup returned correctly
}, []);
```

#### Mental Model
`useEffect` is a synchronous doorman — it can hand a cleanup ticket on your way out, but an `async` bouncer forgets to give you the ticket because they're still awaiting their coffee.

#### Key Takeaway
- Never mark the `useEffect` callback itself as `async`.
- Define an inner async function and call it immediately.
- Always handle the cancellation/unmount case for async effects.

---

### Issue #6: Event Handler vs Invocation
**Level:** 🔴 Beginner
**Symptom:** Handler fires immediately on render (before any click), or clicking does nothing because you passed the wrong type.

**Root Cause:** `onClick={handleClick()}` calls the function during render and passes its return value (often `undefined`) as the handler. `onClick={handleClick}` passes the function reference to be called on click.

#### Wrong (problematic code)
```tsx
<button onClick={handleClick()}>  {/* PROBLEM: calls handleClick NOW, on every render */}
  Submit
</button>

<button onClick={handleClick}>    {/* correct — but breaks when you need to pass args */}
  Submit
</button>

<button onClick={handleClick(userId)}> {/* PROBLEM: again calls immediately */}
  Delete
</button>
```

#### Fix
```tsx
<button onClick={handleClick}>          {/* WHY: passes reference, called only on click */}
  Submit
</button>

{/* WHY: wrap in arrow function to pass arguments without immediate invocation */}
<button onClick={() => handleDelete(userId)}>
  Delete
</button>
```

#### Mental Model
`handleClick()` is handing the bouncer the result of your performance — `handleClick` is handing them the script to perform it later.

#### Key Takeaway
- Pass function references to event props, not invocations.
- When arguments are needed, wrap in an arrow function: `() => fn(arg)`.

---

## 🟡 Intermediate

---

### Issue #7: Stale Closure in useCallback / useMemo
**Level:** 🟡 Intermediate
**Symptom:** A memoized callback reads a state value that is always the same (old) value no matter how many times state updates. Often seen in event handlers memoized with `useCallback`.

**Root Cause:** `useCallback` with a static dependency array (`[]`) captures the variable values from the first render in a closure. Subsequent state updates are invisible inside that captured snapshot.

#### Wrong (problematic code)
```tsx
function Chat() {
  const [message, setMessage] = useState('');

  // PROBLEM: empty dep array → message is always '' inside this callback
  const sendMessage = useCallback(() => {
    console.log('Sending:', message); // PROBLEM: always logs empty string
    api.send(message);
  }, []); // PROBLEM: message not listed as dependency
}
```

#### Fix
```tsx
function Chat() {
  const [message, setMessage] = useState('');

  // WHY: listing message ensures callback is recreated when message changes
  const sendMessage = useCallback(() => {
    console.log('Sending:', message);
    api.send(message);
  }, [message]); // FIX: dependency listed

  // ALTERNATIVE: use a ref to always have the latest value without re-creating callback
  const messageRef = useRef(message);
  useEffect(() => { messageRef.current = message; }, [message]); // WHY: keeps ref in sync

  const stableSend = useCallback(() => {
    api.send(messageRef.current); // WHY: reads latest value through stable ref
  }, []); // WHY: callback itself is stable — good for deeply memoized children
}
```

#### Mental Model
A `useCallback` with `[]` is like a photograph of your state — it never changes even as the world around it does. Add deps to take a new photo when needed, or use a ref as a live video feed.

#### Key Takeaway
- Always list every state/prop/context value used inside `useCallback`/`useMemo` in the deps array.
- For event handlers that need the latest value without re-creating, use the "ref trick" pattern.

---

### Issue #8: useEffect Cleanup Not Implemented
**Level:** 🟡 Intermediate
**Symptom:** Console errors after navigating away: "Can't perform a React state update on an unmounted component." Subscriptions fire for components that no longer exist.

**Root Cause:** Timers, event listeners, WebSocket connections, or Observable subscriptions set up in `useEffect` continue running after the component unmounts unless explicitly torn down in the cleanup function.

#### Wrong (problematic code)
```tsx
function LivePrice({ symbol }: { symbol: string }) {
  const [price, setPrice] = useState(0);

  useEffect(() => {
    const ws = new WebSocket(`wss://prices/${symbol}`);
    ws.onmessage = (e) => setPrice(JSON.parse(e.data).price); // PROBLEM: fires after unmount
    // PROBLEM: no return cleanup — WebSocket stays open forever
  }, [symbol]);
}
```

#### Fix
```tsx
function LivePrice({ symbol }: { symbol: string }) {
  const [price, setPrice] = useState(0);

  useEffect(() => {
    const ws = new WebSocket(`wss://prices/${symbol}`);
    ws.onmessage = (e) => setPrice(JSON.parse(e.data).price);

    return () => {          // WHY: cleanup runs on unmount OR before re-running due to symbol change
      ws.close();           // WHY: terminates the connection — no more messages
    };
  }, [symbol]);             // WHY: reconnects when symbol changes, cleans up old connection first
}
```

#### Mental Model
Not writing cleanup is like leaving your hotel room TV on when you check out — it keeps running and the hotel (browser) pays the bill.

#### Key Takeaway
- Every `useEffect` that starts something (timer, listener, subscription) must return a cleanup function.
- The cleanup runs both on unmount AND before the next effect execution when deps change.

---

### Issue #9: Prop Drilling Hell
**Level:** 🟡 Intermediate
**Symptom:** A prop is passed through 5+ component layers where middle components don't use it but must forward it. Any rename requires touching every intermediate file.

**Root Cause:** State needed by a deeply nested component is stored too high in the tree. The only way to reach it without a state manager is to thread the prop through every level.

#### Wrong (problematic code)
```tsx
// PROBLEM: theme passed through App → Layout → Sidebar → NavItem → Icon
function App() {
  const [theme, setTheme] = useState('dark');
  return <Layout theme={theme} setTheme={setTheme} />;
}
function Layout({ theme, setTheme }: any) {       // PROBLEM: Layout doesn't use theme
  return <Sidebar theme={theme} setTheme={setTheme} />;
}
function Sidebar({ theme, setTheme }: any) {       // PROBLEM: Sidebar doesn't use theme either
  return <NavItem theme={theme} setTheme={setTheme} />;
}
```

#### Fix
```tsx
// FIX: use React Context to broadcast value to any depth
const ThemeContext = createContext<{ theme: string; setTheme: (t: string) => void } | null>(null);

function App() {
  const [theme, setTheme] = useState('dark');
  return (
    // WHY: Provider wraps the tree — any descendant can consume without threading
    <ThemeContext.Provider value={{ theme, setTheme }}>
      <Layout />        {/* WHY: Layout no longer receives theme prop */}
    </ThemeContext.Provider>
  );
}

function NavItem() {
  // WHY: jumps directly to the nearest Provider — no middle components involved
  const { theme } = useContext(ThemeContext)!;
  return <Icon theme={theme} />;
}
```

#### Mental Model
Prop drilling is like passing a note down a long line of people to reach the last person — Context is a broadcast radio everyone can tune into directly.

#### Key Takeaway
- Use Context for truly global or cross-cutting concerns (theme, auth, locale).
- Context is not a silver bullet — for complex state transitions, prefer Zustand or Redux.

---

### Issue #10: Unnecessary Re-renders
**Level:** 🟡 Intermediate
**Symptom:** Profiler shows child components re-rendering on every parent state change, even though the child's props didn't change. FPS drops in lists.

**Root Cause:** Every parent render creates new object/function references. Children receive "different" props even if values are identical, defeating React's bailout optimization.

#### Wrong (problematic code)
```tsx
function Parent() {
  const [count, setCount] = useState(0);

  // PROBLEM: new function reference every render → memoized child always re-renders
  const handleClick = () => console.log('clicked');

  // PROBLEM: new object reference every render
  const config = { color: 'blue', size: 12 };

  return (
    <>
      <button onClick={() => setCount(c => c + 1)}>+</button>
      <ExpensiveChild onClick={handleClick} config={config} /> {/* PROBLEM: re-renders every time */}
    </>
  );
}

const ExpensiveChild = ({ onClick, config }: any) => {
  console.log('ExpensiveChild rendered'); // fires on every Parent render
  return <div style={config} onClick={onClick}>Hello</div>;
};
```

#### Fix
```tsx
function Parent() {
  const [count, setCount] = useState(0);

  // WHY: stable reference across renders — only changes if deps change
  const handleClick = useCallback(() => console.log('clicked'), []);

  // WHY: stable object reference — only recalculated if values change
  const config = useMemo(() => ({ color: 'blue', size: 12 }), []);

  return (
    <>
      <button onClick={() => setCount(c => c + 1)}>+</button>
      <ExpensiveChild onClick={handleClick} config={config} />
    </>
  );
}

// WHY: React.memo does shallow prop comparison — skips re-render if props unchanged
const ExpensiveChild = React.memo(({ onClick, config }: any) => {
  console.log('ExpensiveChild rendered'); // now only fires when props actually change
  return <div style={config} onClick={onClick}>Hello</div>;
});
```

#### Mental Model
`React.memo` is the bouncer who checks your ID — but if you arrive each time with a brand-new ID card (new reference), the bouncer always lets you in. `useCallback`/`useMemo` make your ID card reusable.

#### Key Takeaway
- `React.memo` only helps if props references are stable — pair with `useCallback`/`useMemo`.
- Profile first (React DevTools Profiler) before adding memoization everywhere.

---

### Issue #11: Race Condition in Async Fetch
**Level:** 🟡 Intermediate
**Symptom:** Typing quickly in a search box shows wrong results — results from an old search replace a newer one. Seen as "flickering" data or stale responses.

**Root Cause:** Multiple concurrent fetches can resolve in any order. If the user types "ab" then "abc", the "ab" fetch may resolve after "abc" and overwrite the correct result.

#### Wrong (problematic code)
```tsx
function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  useEffect(() => {
    // PROBLEM: no cancellation — old fetch can overwrite new results
    fetch(`/api/search?q=${query}`)
      .then(r => r.json())
      .then(data => setResults(data)); // PROBLEM: race — whichever resolves last wins
  }, [query]);
}
```

#### Fix
```tsx
function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  useEffect(() => {
    let active = true; // WHY: flag to ignore stale responses

    fetch(`/api/search?q=${query}`)
      .then(r => r.json())
      .then(data => {
        if (active) setResults(data); // WHY: only update if this fetch is still the latest
      });

    return () => { active = false; }; // WHY: cleanup marks this fetch as stale when query changes
  }, [query]);
}

// ALTERNATIVE: use AbortController for true cancellation
useEffect(() => {
  const controller = new AbortController();

  fetch(`/api/search?q=${query}`, { signal: controller.signal }) // WHY: cancels in-flight HTTP
    .then(r => r.json())
    .then(data => setResults(data))
    .catch(err => { if (err.name !== 'AbortError') throw err; }); // WHY: ignore abort errors

  return () => controller.abort(); // WHY: cancels the request itself, not just ignores result
}, [query]);
```

#### Mental Model
Multiple fetches are like ordering food at different times — without cancellation, a meal ordered earlier might arrive after your current order and be served instead.

#### Key Takeaway
- Always handle the stale-response case with a cancellation flag or `AbortController`.
- Libraries like React Query handle this automatically.

---

### Issue #12: Context Causing Full Tree Re-render
**Level:** 🟡 Intermediate
**Symptom:** Updating any context value (e.g., incrementing a counter) causes all context consumers to re-render, even those that only use an unrelated part of the context.

**Root Cause:** React re-renders every consumer whenever the context object reference changes. A single context with multiple values means any value change re-renders all consumers.

#### Wrong (problematic code)
```tsx
// PROBLEM: single context for auth + theme → theme-only components re-render on auth change
const AppContext = createContext({ user: null, theme: 'dark', count: 0 });

function App() {
  const [user, setUser] = useState(null);
  const [theme, setTheme] = useState('dark');
  const [count, setCount] = useState(0);

  return (
    // PROBLEM: new object reference every render → all consumers re-render
    <AppContext.Provider value={{ user, theme, count }}>
      <ThemedButton />  {/* PROBLEM: re-renders when count changes, though it only uses theme */}
    </AppContext.Provider>
  );
}
```

#### Fix
```tsx
// WHY: split context by concern — each consumer subscribes only to what it needs
const ThemeContext = createContext<string>('dark');
const AuthContext  = createContext<User | null>(null);
const CountContext = createContext<number>(0);

function App() {
  const [user, setUser] = useState<User | null>(null);
  const [theme]         = useState('dark');
  const [count, setCount] = useState(0);

  return (
    // WHY: ThemeContext value is a primitive → only changes when theme actually changes
    <ThemeContext.Provider value={theme}>
      <AuthContext.Provider value={user}>
        <CountContext.Provider value={count}>
          <ThemedButton /> {/* WHY: only re-renders when ThemeContext value changes */}
        </CountContext.Provider>
      </AuthContext.Provider>
    </ThemeContext.Provider>
  );
}
```

#### Mental Model
A single large context is a group chat where every message pings everyone — split contexts are separate DMs so only the relevant person is notified.

#### Key Takeaway
- Split large context objects into smaller, purpose-specific contexts.
- For high-frequency updates (counters, mouse pos), prefer Zustand or Jotai over Context.

---

## 🟢 Expert

---

### Issue #13: Memory Leak — Event Listeners Not Cleaned Up
**Level:** 🟢 Expert
**Symptom:** Application slows down progressively. Chrome Memory profiler shows growing heap. Handlers fire multiple times per event after navigating in and out of a component.

**Root Cause:** `addEventListener` in a `useEffect` without a corresponding `removeEventListener` in cleanup registers a new listener on every mount while the old ones accumulate.

#### Wrong (problematic code)
```tsx
function ScrollTracker() {
  const [scrollY, setScrollY] = useState(0);

  useEffect(() => {
    // PROBLEM: adds a new listener on every mount, never removes old ones
    window.addEventListener('scroll', () => setScrollY(window.scrollY));
    // PROBLEM: no cleanup returned
  }, []);
}
```

#### Fix
```tsx
function ScrollTracker() {
  const [scrollY, setScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY); // WHY: named ref needed for removal

    window.addEventListener('scroll', handleScroll);

    return () => {
      window.removeEventListener('scroll', handleScroll); // WHY: exact same function ref required
    };
  }, []); // WHY: only registers once — cleanup removes it on unmount
}
```

#### Mental Model
`addEventListener` is subscribing to a magazine — if you keep subscribing but never cancel, your mailbox (memory) overflows with duplicate copies.

#### Key Takeaway
- Always capture the handler in a named variable so `removeEventListener` can reference the exact same function.
- Arrow functions inline to `addEventListener` cannot be removed — they create a new reference each time.

---

### Issue #14: Concurrent Mode Tearing
**Level:** 🟢 Expert
**Symptom:** In React 18 with Concurrent features, different parts of the UI show inconsistent values from an external store mid-render (e.g., Zustand/Redux slice reads partially updated state).

**Root Cause:** Concurrent Mode can interrupt and resume renders. If an external (non-React) store is mutated during that pause, later parts of the render tree read a newer value than earlier parts, causing a "tear."

#### Wrong (problematic code)
```tsx
// PROBLEM: reading external store directly without useSyncExternalStore
const count = externalStore.getCount(); // PROBLEM: may return different value mid-render in CM
```

#### Fix
```typescript
import { useSyncExternalStore } from 'react'; // WHY: React 18 API for safe external store reads

function useExternalCount() {
  return useSyncExternalStore(
    externalStore.subscribe,      // WHY: React subscribes to store changes
    externalStore.getCount,       // WHY: snapshot used for client render — consistent
    externalStore.getCount        // WHY: server snapshot for SSR
  );
}
```

#### Mental Model
Without `useSyncExternalStore`, reading an external store in Concurrent Mode is like reading a document while someone edits it live — you might see paragraph 1 from version A and paragraph 2 from version B.

#### Key Takeaway
- Any external store (Redux, Zustand, MobX) should be read via `useSyncExternalStore` in React 18.
- Modern versions of Redux and Zustand implement this internally — keep them up to date.

---

### Issue #15: useLayoutEffect vs useEffect Timing
**Level:** 🟢 Expert
**Symptom:** Tooltip or dropdown briefly renders in the wrong position before jumping to the correct one (flash of incorrect layout). Or a DOM measurement returns 0 because it runs after paint.

**Root Cause:** `useEffect` runs asynchronously after the browser has painted. DOM measurements done there read post-paint values but any resulting state update causes a visible re-paint. `useLayoutEffect` fires synchronously after DOM mutations but before paint.

#### Wrong (problematic code)
```tsx
function Tooltip({ anchorRef }: { anchorRef: RefObject<HTMLElement> }) {
  const [pos, setPos] = useState({ top: 0, left: 0 });

  // PROBLEM: useEffect fires AFTER paint — user sees tooltip at (0,0) briefly
  useEffect(() => {
    const rect = anchorRef.current!.getBoundingClientRect();
    setPos({ top: rect.bottom, left: rect.left });
  }, []);
}
```

#### Fix
```tsx
function Tooltip({ anchorRef }: { anchorRef: RefObject<HTMLElement> }) {
  const [pos, setPos] = useState({ top: 0, left: 0 });

  // WHY: useLayoutEffect fires before browser paint — no flash, position correct from start
  useLayoutEffect(() => {
    const rect = anchorRef.current!.getBoundingClientRect();
    setPos({ top: rect.bottom, left: rect.left }); // WHY: update applied before user sees anything
  }, []);
}
```

```
Timeline comparison:
  useEffect:       Render → Commit → [PAINT] → Effect → setState → Re-render → [PAINT]
  useLayoutEffect: Render → Commit → LayoutEffect → setState → Re-render → [PAINT]
```

#### Mental Model
`useLayoutEffect` is a painter who measures the wall before applying paint — `useEffect` measures after the wall is already painted and requires a second coat.

#### Key Takeaway
- Use `useLayoutEffect` only for DOM measurements that must happen before paint.
- Avoid heavy work in `useLayoutEffect` — it blocks paint and can cause jank.

---

### Issue #16: Bundle Size / Code Splitting Not Done
**Level:** 🟢 Expert
**Symptom:** Initial page load is slow (3–8s on 4G). Lighthouse reports large JS bundles. Network tab shows one massive `main.js` file.

**Root Cause:** Without code splitting, webpack/Vite bundles the entire application into a single file served on first load, including routes the user may never visit.

#### Wrong (problematic code)
```tsx
// PROBLEM: all routes imported eagerly — entire app bundled together
import Dashboard from './pages/Dashboard';
import Reports   from './pages/Reports';
import Settings  from './pages/Settings';

function App() {
  return (
    <Routes>
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/reports"   element={<Reports />} />
      <Route path="/settings"  element={<Settings />} />
    </Routes>
  );
}
```

#### Fix
```tsx
import { lazy, Suspense } from 'react';

// WHY: lazy() tells bundler to split these into separate chunks loaded on demand
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Reports   = lazy(() => import('./pages/Reports'));
const Settings  = lazy(() => import('./pages/Settings'));

function App() {
  return (
    // WHY: Suspense shows fallback while the chunk is being fetched
    <Suspense fallback={<div>Loading...</div>}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/reports"   element={<Reports />} />
        <Route path="/settings"  element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

#### Mental Model
Eager imports are ordering the entire restaurant menu upfront — `lazy` lets you order one dish at a time as guests arrive.

#### Key Takeaway
- Split at route level at minimum; split at component level for heavy components (charts, editors).
- Use `/* webpackChunkName: "dashboard" */` magic comments to name chunks for debugging.

---

### Issue #17: Hydration Mismatch in Next.js SSR
**Level:** 🟢 Expert
**Symptom:** Next.js / React SSR logs: `"Warning: Text content did not match. Server: 'X' Client: 'Y'"`. Page flickers or parts disappear on load.

**Root Cause:** The server renders HTML using one set of values (e.g., no `window`, no client-side cookies) and the client renders with different values. React's hydration fails to reconcile the two trees.

#### Wrong (problematic code)
```tsx
// PROBLEM: Math.random() and Date produce different values on server vs client
function RandomWidget() {
  return <div id={Math.random().toString()}>  {/* PROBLEM: different each run */}
    <span>{new Date().toLocaleTimeString()}</span>  {/* PROBLEM: server time ≠ client time */}
  </div>;
}

// PROBLEM: direct window access crashes on server
function ClientOnlyComponent() {
  const width = window.innerWidth; // PROBLEM: window undefined on server → crash
}
```

#### Fix
```tsx
'use client'; // WHY: Next.js 13+ — marks as client component, not server-rendered

import { useState, useEffect } from 'react';

function TimeWidget() {
  // WHY: start with null to ensure server and client initial render match
  const [time, setTime] = useState<string | null>(null);

  // WHY: useEffect only runs on client — sets the real time after hydration
  useEffect(() => {
    setTime(new Date().toLocaleTimeString());
    const id = setInterval(() => setTime(new Date().toLocaleTimeString()), 1000);
    return () => clearInterval(id);
  }, []);

  // WHY: renders null on server AND initial client render → no mismatch
  if (time === null) return null;
  return <span>{time}</span>;
}

// For window access, use a utility:
function useWindowWidth() {
  const [width, setWidth] = useState<number | undefined>(undefined); // WHY: undefined on server
  useEffect(() => {
    setWidth(window.innerWidth); // WHY: only runs client-side
  }, []);
  return width;
}
```

#### Mental Model
SSR hydration is a join-the-dots puzzle — the server draws the dots, the client connects them. If the dots are in different places, the picture tears.

#### Key Takeaway
- Never use non-deterministic values (Date, Math.random, window) in the initial render tree for SSR pages.
- Use `useEffect` to set client-only state after hydration.
- `suppressHydrationWarning` exists but is a last resort — fix the root cause instead.

---

### Issue #18: Custom Hook Infinite Loop
**Level:** 🟢 Expert
**Symptom:** Browser tab freezes, maximum call stack exceeded, or the network tab shows hundreds of identical requests fired rapidly.

**Root Cause:** A custom hook returns a new object or array reference on every render. When that return value is used as a `useEffect` dependency, the effect sees a "new" value each render and fires again, causing a loop.

#### Wrong (problematic code)
```tsx
// PROBLEM: custom hook returns new array reference every call
function useFilters() {
  return { activeFilters: ['a', 'b'] }; // PROBLEM: new object each render
}

function FilteredList() {
  const { activeFilters } = useFilters();

  // PROBLEM: activeFilters is a new reference each render → infinite loop
  useEffect(() => {
    fetchData(activeFilters);
  }, [activeFilters]); // PROBLEM: this dependency changes every render
}
```

#### Fix
```tsx
// FIX: memoize the returned value inside the custom hook
function useFilters() {
  const [filters, setFilters] = useState(['a', 'b']);
  // WHY: useMemo ensures same reference is returned unless filters state changes
  return useMemo(() => ({ activeFilters: filters }), [filters]);
}

// ALTERNATIVE: return stable state directly, not wrapped in a new object
function useFilters() {
  const [activeFilters, setActiveFilters] = useState(['a', 'b']); // WHY: stable reference from useState
  return { activeFilters, setActiveFilters }; // WHY: BUT this is still a new object — use approach below

  // BEST: return primitives or stable refs
  return activeFilters; // WHY: array ref only changes when setActiveFilters is called
}
```

#### Mental Model
A hook returning a new object every call is like handing `useEffect` a new key on every visit — the door never recognizes it as the same key and keeps triggering the alarm.

#### Key Takeaway
- Memoize non-primitive return values from custom hooks with `useMemo`.
- Prefer returning stable state arrays/objects directly rather than wrapping in new objects.

---

# ANGULAR ISSUES

## 🔴 Beginner

---

### Issue #19: Nested Subscribe Anti-pattern
**Level:** 🔴 Beginner
**Symptom:** Code works but is deeply indented with subscribes inside subscribes. Hard to cancel, error handling is duplicated, and inner subscriptions may leak.

**Root Cause:** RxJS provides higher-order mapping operators to flatten observable streams. Subscribing manually inside a subscribe is the imperative equivalent and defeats the reactive model.

#### Wrong (problematic code)
```typescript
this.authService.getUser().subscribe(user => {
  // PROBLEM: inner subscribe creates an unmanaged nested observable chain
  this.orderService.getOrders(user.id).subscribe(orders => {
    // PROBLEM: and another level deep — pyramid of doom
    this.inventoryService.checkStock(orders[0].id).subscribe(stock => {
      this.stock = stock; // PROBLEM: three unmanaged subscriptions, no error handling
    });
  });
});
```

#### Fix
```typescript
import { switchMap, catchError } from 'rxjs/operators';
import { EMPTY } from 'rxjs';

this.authService.getUser().pipe(
  switchMap(user => this.orderService.getOrders(user.id)),   // WHY: flattens to single stream, cancels previous
  switchMap(orders => this.inventoryService.checkStock(orders[0].id)), // WHY: chains without nesting
  catchError(err => {                                         // WHY: single error handler for entire chain
    console.error(err);
    return EMPTY; // WHY: gracefully terminates stream on error
  })
).subscribe(stock => {
  this.stock = stock; // WHY: single subscription, clean chain
});
```

#### Mental Model
Nested subscribes are like putting a smaller box inside a bigger box to open them — `switchMap` is a conveyor belt that connects the boxes in sequence without nesting.

#### Key Takeaway
- Use `switchMap` (cancel prev), `concatMap` (queue), `mergeMap` (parallel), `exhaustMap` (ignore new until done).
- One subscribe per logical operation — chain with pipe operators.

---

### Issue #20: Forgetting to Unsubscribe
**Level:** 🔴 Beginner
**Symptom:** Memory usage grows. Handlers fire for destroyed components. `console.log` inside a subscription prints after navigating away.

**Root Cause:** Subscriptions to long-lived observables (like `interval`, `router.events`, WebSocket streams) keep the callback alive indefinitely unless explicitly cancelled.

#### Wrong (problematic code)
```typescript
@Component({ selector: 'app-timer', template: '{{count}}' })
export class TimerComponent implements OnInit {
  count = 0;

  ngOnInit() {
    interval(1000).subscribe(n => { // PROBLEM: interval never completes — subscription lives forever
      this.count = n; // PROBLEM: fires after component destroyed → memory leak + error
    });
  }
  // PROBLEM: no ngOnDestroy, no unsubscribe
}
```

#### Fix
```typescript
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({ selector: 'app-timer', template: '{{count}}' })
export class TimerComponent implements OnInit, OnDestroy {
  count = 0;
  private destroy$ = new Subject<void>(); // WHY: sentinel observable for teardown

  ngOnInit() {
    interval(1000).pipe(
      takeUntil(this.destroy$) // WHY: auto-unsubscribes when destroy$ emits
    ).subscribe(n => { this.count = n; });
  }

  ngOnDestroy() {
    this.destroy$.next();    // WHY: signal takeUntil to complete all guarded streams
    this.destroy$.complete(); // WHY: clean up the Subject itself
  }
}

// ALTERNATIVE: Angular 16+ takeUntilDestroyed
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

interval(1000).pipe(
  takeUntilDestroyed() // WHY: automatically tied to component's destroy lifecycle
).subscribe(n => { this.count = n; });
```

#### Mental Model
An unmanaged subscription is a leaky tap — `takeUntil` is the automatic shutoff valve triggered when you leave the house (component destroyed).

#### Key Takeaway
- Use `takeUntil(this.destroy$)` pattern or Angular 16+ `takeUntilDestroyed()` for all long-lived streams.
- Short-lived observables (HTTP calls) complete automatically — no manual unsubscribe needed.

---

### Issue #21: Mutating @Input() Directly in Child
**Level:** 🔴 Beginner
**Symptom:** Parent and child state become out of sync. Parent shows old data. Changes in child are lost on the next parent update.

**Root Cause:** Angular's data flow is unidirectional: parent to child via `@Input`, child to parent via `@Output`. Directly mutating an `@Input` breaks this contract and the parent's version of the data overrides the child's mutation on next change detection.

#### Wrong (problematic code)
```typescript
@Component({ selector: 'app-child' })
export class ChildComponent {
  @Input() user!: User;

  updateName(name: string) {
    this.user.name = name; // PROBLEM: mutates parent's object directly — breaks one-way flow
  }
}
```

#### Fix
```typescript
@Component({ selector: 'app-child' })
export class ChildComponent {
  @Input() user!: User;
  @Output() userChange = new EventEmitter<User>(); // WHY: proper upward communication channel

  updateName(name: string) {
    // WHY: emit a new object — parent decides whether to accept the change
    this.userChange.emit({ ...this.user, name });
  }
}

// Parent template:
// <app-child [user]="user" (userChange)="user = $event"></app-child>
```

#### Mental Model
`@Input` is a read-only library book — you can read it but must request changes through the librarian (`@Output`) rather than writing in the margins yourself.

#### Key Takeaway
- Treat `@Input` values as immutable within the child component.
- Communicate changes upward with `@Output` EventEmitter.

---

### Issue #22: Heavy Logic in Constructor
**Level:** 🔴 Beginner
**Symptom:** HTTP calls fail with dependency injection errors, or service methods are called before Angular has fully initialized the component.

**Root Cause:** The constructor runs before Angular sets up `@Input` bindings and before the component is attached to the DOM. DI providers are available but component state is not fully initialized.

#### Wrong (problematic code)
```typescript
@Component({ selector: 'app-user' })
export class UserComponent {
  user: User;

  constructor(private userService: UserService, private route: ActivatedRoute) {
    const id = this.route.snapshot.paramMap.get('id'); // PROBLEM: may work but brittle
    this.userService.getUser(id!).subscribe(u => this.user = u); // PROBLEM: HTTP in constructor
    this.initializeChart(); // PROBLEM: DOM not ready — chart setup fails
  }
}
```

#### Fix
```typescript
@Component({ selector: 'app-user' })
export class UserComponent implements OnInit {
  user!: User;

  constructor(private userService: UserService, private route: ActivatedRoute) {
    // WHY: constructor only for DI — nothing else
  }

  ngOnInit(): void {
    // WHY: @Input values are set, component is initialized — safe to fetch data
    const id = this.route.snapshot.paramMap.get('id');
    this.userService.getUser(id!).subscribe(u => this.user = u);
  }

  ngAfterViewInit(): void {
    this.initializeChart(); // WHY: DOM is ready — chart can safely access ViewChild elements
  }
}
```

#### Mental Model
The constructor is the building's foundation — you don't move furniture in during construction. `ngOnInit` is moving day, `ngAfterViewInit` is after the doors are hung.

#### Key Takeaway
- Constructor: dependency injection only.
- `ngOnInit`: data fetching, input processing.
- `ngAfterViewInit`: DOM/ViewChild manipulation.

---

### Issue #23: Missing Module Import
**Level:** 🔴 Beginner
**Symptom:** `NullInjectorError: No provider for X` or `'app-custom-component' is not a known element` or `Can't bind to 'ngModel' since it isn't a known property`.

**Root Cause:** Angular's module system requires explicit imports. Directives, pipes, and services from external modules are not available unless that module is imported in the consuming `NgModule` (or declared in standalone component imports).

#### Wrong (problematic code)
```typescript
// PROBLEM: FormsModule not imported → [(ngModel)] fails
@NgModule({
  declarations: [AppComponent],
  imports: [BrowserModule], // PROBLEM: FormsModule missing
})
export class AppModule {}

// Template: <input [(ngModel)]="name" /> → ERROR: Can't bind to 'ngModel'
```

#### Fix
```typescript
import { FormsModule }         from '@angular/forms';
import { HttpClientModule }    from '@angular/common/http';
import { ReactiveFormsModule } from '@angular/forms';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    FormsModule,          // WHY: required for ngModel (template-driven forms)
    ReactiveFormsModule,  // WHY: required for formGroup/formControl (reactive forms)
    HttpClientModule,     // WHY: required for HttpClient injection
  ],
})
export class AppModule {}

// For Angular 14+ Standalone Components:
@Component({
  standalone: true,
  imports: [FormsModule], // WHY: standalone components declare their own imports
})
export class MyComponent {}
```

#### Mental Model
NgModule imports are like inviting guests to a party — if you don't send `FormsModule` an invitation, its directives won't show up to work in your templates.

#### Key Takeaway
- `FormsModule` → template-driven forms (`ngModel`)
- `ReactiveFormsModule` → reactive forms (`formGroup`, `formControl`)
- `HttpClientModule` → `HttpClient`
- For shared components/directives, export them from a SharedModule.

---

### Issue #24: Not Using Async Pipe
**Level:** 🔴 Beginner
**Symptom:** Manual subscribe with `this.data = result`, combined with a missing `ngOnDestroy`, causes memory leaks. Observable state management scattered across lifecycle hooks.

**Root Cause:** The `async` pipe subscribes to an Observable directly in the template, automatically unsubscribes on destroy, and triggers change detection — eliminating the need for manual subscribe/unsubscribe.

#### Wrong (problematic code)
```typescript
@Component({ template: '<div>{{users}}</div>' })
export class UserListComponent implements OnInit {
  users: User[] = [];
  private sub: Subscription;

  ngOnInit() {
    this.sub = this.userService.getUsers() // PROBLEM: manual subscription management
      .subscribe(users => this.users = users);
  }

  ngOnDestroy() {
    this.sub.unsubscribe(); // PROBLEM: must remember this — easy to forget
  }
}
```

#### Fix
```typescript
@Component({
  template: `
    <div *ngFor="let user of users$ | async">{{user.name}}</div>
    <!-- WHY: async pipe auto-subscribes and auto-unsubscribes on destroy -->
  `
})
export class UserListComponent implements OnInit {
  users$!: Observable<User[]>; // WHY: expose observable, not the array

  ngOnInit() {
    this.users$ = this.userService.getUsers(); // WHY: no subscribe — template handles it
    // WHY: no ngOnDestroy needed for this observable
  }
}
```

#### Mental Model
Manual subscribe is like hiring a waiter, feeding them, and firing them yourself — the `async` pipe is a full-service restaurant that handles all that automatically.

#### Key Takeaway
- Prefer `async` pipe over manual subscribe for template-bound data.
- Use `shareReplay(1)` upstream if multiple async pipes subscribe to the same source.

---

## 🟡 Intermediate

---

### Issue #25: ExpressionChangedAfterItHasBeenCheckedError
**Level:** 🟡 Intermediate
**Symptom:** `ERROR Error: ExpressionChangedAfterItHasBeenCheckedError: Expression has changed after it was checked. Previous value: 'X'. Current value: 'Y'.` Only in dev mode.

**Root Cause:** Angular's change detection runs a second pass in dev mode to verify stability. If a lifecycle hook (`ngAfterViewInit`, `ngAfterContentInit`) mutates state that affects the parent template, the parent's already-checked value changes.

#### Wrong (problematic code)
```typescript
@Component({
  template: '<app-child (loaded)="isLoaded = $event"></app-child> <div *ngIf="isLoaded">Ready</div>'
})
export class ParentComponent {
  isLoaded = false;
}

@Component({ selector: 'app-child' })
export class ChildComponent implements AfterViewInit {
  @Output() loaded = new EventEmitter<boolean>();

  ngAfterViewInit() {
    this.loaded.emit(true); // PROBLEM: fires after parent's view check → ExpressionChangedError
  }
}
```

#### Fix
```typescript
import { ChangeDetectorRef } from '@angular/core';

@Component({ selector: 'app-child' })
export class ChildComponent implements AfterViewInit {
  @Output() loaded = new EventEmitter<boolean>();

  constructor(private cdRef: ChangeDetectorRef) {}

  ngAfterViewInit() {
    // WHY: defer to next microtask so parent's check cycle is complete
    Promise.resolve().then(() => this.loaded.emit(true));

    // ALTERNATIVE: explicitly mark parent for re-check
    // this.cdRef.detectChanges(); // WHY: runs a new CD cycle for this subtree immediately
  }
}
```

#### Mental Model
Angular's dev mode double-check is like a teacher reviewing your exam after grading — if you change an answer after they've marked it, they'll flag it. `Promise.resolve()` waits until the teacher has left the room.

#### Key Takeaway
- Never mutate parent-bound state in `ngAfterViewInit` / `ngAfterContentInit` synchronously.
- Use `Promise.resolve().then(...)` or `setTimeout(0, ...)` to defer, or call `detectChanges()`.

---

### Issue #26: OnPush Not Detecting Nested Object Mutation
**Level:** 🟡 Intermediate
**Symptom:** Component with `ChangeDetectionStrategy.OnPush` does not update when a property inside an `@Input` object is changed. The template shows the old value.

**Root Cause:** `OnPush` only triggers change detection when the Input reference changes (not when its contents change), or when an event/async pipe fires. Mutating a nested property keeps the same object reference.

#### Wrong (problematic code)
```typescript
// Parent:
this.user.name = 'Bob'; // PROBLEM: same reference → OnPush child sees no change

// Child:
@Component({
  selector: 'app-user-card',
  changeDetection: ChangeDetectionStrategy.OnPush, // PROBLEM: relies on reference equality
  template: '{{user.name}}'
})
export class UserCardComponent {
  @Input() user!: User;
}
```

#### Fix
```typescript
// Parent: always create a new reference for OnPush to detect change
this.user = { ...this.user, name: 'Bob' }; // WHY: new reference → OnPush sees Input changed

// OR: inject ChangeDetectorRef in child and mark manually when needed
@Component({
  selector: 'app-user-card',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserCardComponent {
  @Input() user!: User;

  constructor(private cdRef: ChangeDetectorRef) {}

  // WHY: called after parent mutates user — forces a CD cycle for this component
  refresh() { this.cdRef.markForCheck(); }
}
```

#### Mental Model
`OnPush` is a motion-sensor light — it only turns on if someone walks through the door (new reference). Rearranging furniture inside (mutating props) doesn't trigger it.

#### Key Takeaway
- With `OnPush`, always replace objects/arrays immutably (spread, `Object.assign`).
- Use `markForCheck()` when pushing data through non-`@Input` channels (services, streams).

---

### Issue #27: shareReplay Memory Leak
**Level:** 🟡 Intermediate
**Symptom:** HTTP requests continue to be made after all subscribers have unsubscribed. Source observable (e.g., a polling interval) never stops.

**Root Cause:** `shareReplay(1)` without `{ refCount: true }` keeps the internal subscription to the source alive even when the last subscriber unsubscribes. This is the default behavior before RxJS 6.4.

#### Wrong (problematic code)
```typescript
// PROBLEM: source stays subscribed forever even when no consumers remain
this.data$ = this.http.get('/api/data').pipe(
  shareReplay(1) // PROBLEM: no refCount — leaks HTTP connection / interval source
);
```

#### Fix
```typescript
// FIX: use refCount: true so source unsubscribes when last subscriber leaves
this.data$ = this.http.get('/api/data').pipe(
  shareReplay({ bufferSize: 1, refCount: true }) // WHY: reference-counted — auto-closes source
);

// NOTE: for caching use-cases where you WANT to keep the source alive (e.g., config loaded once):
// shareReplay({ bufferSize: 1, refCount: false }) is intentional — document it clearly
```

#### Mental Model
`shareReplay` without `refCount` is a radio station that keeps broadcasting even when the last listener tunes out — `refCount: true` turns off the transmitter when no one is listening.

#### Key Takeaway
- Default `shareReplay(1)` ≠ `shareReplay({ bufferSize: 1, refCount: true })`.
- For HTTP caching: `refCount: false` is intentional (cache survives unsub).
- For multicasting subscriptions that should close: always use `refCount: true`.

---

### Issue #28: Cold vs Hot Observable Confusion
**Level:** 🟡 Intermediate
**Symptom:** `http.get()` is called multiple times unexpectedly, or a stream replays from the start for each new subscriber.

**Root Cause:** Cold observables (like `HttpClient.get`) start a fresh execution for every subscriber. Hot observables (like `fromEvent`) share a single execution. Treating a cold observable like a hot one causes redundant side effects.

#### Wrong (problematic code)
```typescript
const data$ = this.http.get('/api/expensive'); // PROBLEM: cold observable

// PROBLEM: each subscribe triggers a new HTTP request — 3 requests total
data$.subscribe(d => console.log('A', d));
data$.subscribe(d => console.log('B', d));
data$.subscribe(d => console.log('C', d));
```

#### Fix
```typescript
// WHY: share + refCount makes it hot — all subscribers share one HTTP request
const data$ = this.http.get('/api/expensive').pipe(
  shareReplay({ bufferSize: 1, refCount: true }) // WHY: converts cold to hot with replay
);

data$.subscribe(d => console.log('A', d)); // WHY: triggers one HTTP request
data$.subscribe(d => console.log('B', d)); // WHY: gets replayed cached value — no new request
data$.subscribe(d => console.log('C', d)); // WHY: same
```

#### Mental Model
A cold observable is a DVD — each viewer gets their own copy playing from the start. A hot observable is a live TV broadcast — everyone tunes into the same stream.

#### Key Takeaway
- `http.get()`, `timer()`, `interval()` are cold by default.
- `fromEvent()`, `Subject`, `BehaviorSubject` are hot.
- Use `share()` or `shareReplay()` to convert cold to hot when sharing.

---

### Issue #29: RxJS Operator Order Bug
**Level:** 🟡 Intermediate
**Symptom:** After an HTTP error, no further actions can be dispatched in an NgRx Effect. The entire effect stream silently terminates.

**Root Cause:** `catchError` placed outside `switchMap`/`exhaustMap` handles errors at the outer stream level. When an error is caught and returned there, it terminates the outer stream — no more actions will be processed.

#### Wrong (problematic code)
```typescript
// NgRx Effect
loadUsers$ = createEffect(() =>
  this.actions$.pipe(
    ofType(UserActions.loadUsers),
    switchMap(() => this.userService.getUsers()),
    catchError(err => of(UserActions.loadUsersFailed({ err }))) // PROBLEM: outside switchMap
    // PROBLEM: stream terminates on first error — no future loadUsers actions processed
  )
);
```

#### Fix
```typescript
loadUsers$ = createEffect(() =>
  this.actions$.pipe(
    ofType(UserActions.loadUsers),
    switchMap(() =>
      this.userService.getUsers().pipe(
        // WHY: catchError INSIDE switchMap — only inner observable dies, outer stream survives
        catchError(err => of(UserActions.loadUsersFailed({ err })))
      )
    )
    // WHY: outer stream continues listening for next loadUsers action
  )
);
```

```
Stream diagram:
  WRONG:  Actions$ ──── switchMap ──── HTTP ──✖── catchError ──|  (stream ends)
  RIGHT:  Actions$ ──── switchMap ──[── HTTP ──✖── catchError ──]──── Actions$ continues
                                     inner observable restarts
```

#### Mental Model
`catchError` outside is a fire extinguisher that floods the entire building — inside `switchMap`, it's a sprinkler only in the room that's burning.

#### Key Takeaway
- Always place `catchError` inside the inner observable within `switchMap`/`concatMap`/`exhaustMap`.
- Test effects by dispatching the action twice in a row after a simulated error.

---

### Issue #30: Template Expression Side Effects
**Level:** 🟡 Intermediate
**Symptom:** Methods are called hundreds of times per second. Console logs inside template-called methods flood the console. Performance degrades with large lists.

**Root Cause:** Angular's change detection re-evaluates all template expressions on every CD cycle. If a method is called in the template, it runs on every cycle regardless of input changes.

#### Wrong (problematic code)
```html
<!-- PROBLEM: getFullName() called on every CD cycle — could be 60x/sec -->
<div>{{ getFullName(user) }}</div>
<div>{{ expensiveCalculation(orders) }}</div>  <!-- PROBLEM: heavy computation every render -->
```

```typescript
getFullName(user: User): string {
  console.log('computing name...'); // PROBLEM: logs flood console
  return `${user.firstName} ${user.lastName}`;
}
```

#### Fix
```typescript
// FIX 1: use a pure pipe — Angular only re-evaluates when input changes
@Pipe({ name: 'fullName', pure: true }) // WHY: pure pipe result is cached by input reference
export class FullNamePipe implements PipeTransform {
  transform(user: User): string {
    return `${user.firstName} ${user.lastName}`; // WHY: only computed when user reference changes
  }
}

// FIX 2: pre-compute in the component
ngOnChanges() {
  this.fullName = `${this.user.firstName} ${this.user.lastName}`; // WHY: computed once per change
}
```

```html
<!-- FIX 1: pipe approach -->
<div>{{ user | fullName }}</div>

<!-- FIX 2: pre-computed property -->
<div>{{ fullName }}</div>
```

#### Mental Model
A method in a template is a cashier recalculating your bill from scratch every time someone walks past the checkout — a pipe or pre-computed property is a receipt already printed.

#### Key Takeaway
- Never call methods in templates that have side effects or heavy computation.
- Use pure `Pipe` for transformations or pre-compute values in `ngOnChanges`/`ngOnInit`.

---

## 🟢 Expert

---

### Issue #31: Zone.js Performance — Running Outside NgZone
**Level:** 🟢 Expert
**Symptom:** Application becomes sluggish when `setTimeout`, `setInterval`, `requestAnimationFrame`, or WebSocket event handlers are active. CPU usage stays high.

**Root Cause:** Zone.js patches all async APIs and notifies Angular to run change detection on every async callback. Even callbacks unrelated to the UI trigger a full component tree check.

#### Wrong (problematic code)
```typescript
@Component({ selector: 'app-game' })
export class GameComponent implements OnInit {
  ngOnInit() {
    // PROBLEM: requestAnimationFrame runs CD on every frame (60fps) — entire tree checked
    const loop = () => {
      this.updateGameState(); // PROBLEM: triggers change detection 60x/sec even for non-UI state
      requestAnimationFrame(loop);
    };
    requestAnimationFrame(loop);
  }
}
```

#### Fix
```typescript
import { NgZone } from '@angular/core';

@Component({ selector: 'app-game' })
export class GameComponent implements OnInit {
  constructor(private ngZone: NgZone) {}

  ngOnInit() {
    // WHY: run outside Zone.js — no CD triggered by this loop
    this.ngZone.runOutsideAngular(() => {
      const loop = () => {
        this.updateGameState(); // WHY: internal state updated without triggering CD
        if (this.needsRender) {
          // WHY: only re-enter Angular zone when UI actually needs to update
          this.ngZone.run(() => this.renderFrame());
        }
        requestAnimationFrame(loop);
      };
      requestAnimationFrame(loop);
    });
  }
}
```

#### Mental Model
Zone.js is a motion sensor wired to turn on all lights in the house — `runOutsideAngular` lets you walk to the kitchen at night without waking everyone up.

#### Key Takeaway
- Use `ngZone.runOutsideAngular()` for high-frequency operations: game loops, WebSockets, scroll tracking.
- Call `ngZone.run()` only when the result must update the UI.

---

### Issue #32: OnPush + Async Pipe Broken
**Level:** 🟢 Expert
**Symptom:** `OnPush` component with a manually pushed observable (not HTTP) does not update the template even though the observable emits.

**Root Cause:** With `OnPush`, Angular only runs CD for a component when its Input reference changes, an event originates from within it, or it's explicitly marked. The `async` pipe calls `markForCheck()` — but manually updating a `BehaviorSubject` from outside doesn't signal `OnPush` components that use a raw observable without async pipe.

#### Wrong (problematic code)
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: '{{data}}'  // PROBLEM: raw property, not bound to observable
})
export class DataComponent implements OnInit {
  data: string = '';

  ngOnInit() {
    this.dataService.data$.subscribe(val => {
      this.data = val; // PROBLEM: OnPush doesn't know about this update — no re-render
    });
  }
}
```

#### Fix
```typescript
// FIX 1: use async pipe — it calls markForCheck() automatically
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: '{{ data$ | async }}' // WHY: async pipe integrates with OnPush correctly
})
export class DataComponent {
  data$ = this.dataService.data$; // WHY: expose observable directly
  constructor(private dataService: DataService) {}
}

// FIX 2: manually call markForCheck() when subscribing
@Component({ changeDetection: ChangeDetectionStrategy.OnPush })
export class DataComponent implements OnInit {
  data = '';
  constructor(private dataService: DataService, private cdRef: ChangeDetectorRef) {}

  ngOnInit() {
    this.dataService.data$.subscribe(val => {
      this.data = val;
      this.cdRef.markForCheck(); // WHY: tells OnPush scheduler to include this component next cycle
    });
  }
}
```

#### Mental Model
`OnPush` is an off-duty employee who only works when their manager (Angular CD) calls — `markForCheck()` is the phone call; `async` pipe always has that number dialed.

#### Key Takeaway
- `async` pipe is the safest way to use observables with `OnPush`.
- If subscribing manually with `OnPush`, always call `markForCheck()` after setting state.

---

### Issue #33: Circular Dependency in DI
**Level:** 🟢 Expert
**Symptom:** `Error: Circular dependency detected: ServiceA -> ServiceB -> ServiceA`. Application fails to bootstrap.

**Root Cause:** Angular's DI container constructs services lazily but requires the dependency graph to be acyclic. If A needs B and B needs A, neither can be created first.

#### Wrong (problematic code)
```typescript
@Injectable({ providedIn: 'root' })
export class ServiceA {
  constructor(private b: ServiceB) {} // PROBLEM: A depends on B
}

@Injectable({ providedIn: 'root' })
export class ServiceB {
  constructor(private a: ServiceA) {} // PROBLEM: B depends on A → circular
}
```

#### Fix
```typescript
// FIX 1: Extract shared logic into a third service
@Injectable({ providedIn: 'root' })
export class SharedService { // WHY: breaks the cycle — A and B both depend on Shared
  sharedMethod() { /* logic that was creating the cycle */ }
}

@Injectable({ providedIn: 'root' })
export class ServiceA {
  constructor(private shared: SharedService) {} // WHY: no longer needs ServiceB
}

@Injectable({ providedIn: 'root' })
export class ServiceB {
  constructor(private shared: SharedService) {} // WHY: no longer needs ServiceA
}

// FIX 2: Use Injector for lazy resolution (last resort)
@Injectable({ providedIn: 'root' })
export class ServiceA {
  constructor(private injector: Injector) {}

  doSomething() {
    // WHY: inject lazily at call time, not at construction — breaks the circular init
    const b = this.injector.get(ServiceB);
    b.method();
  }
}
```

#### Mental Model
Circular DI is like two doors that can only be opened from the other side — extract a window (shared service) that both can reach independently.

#### Key Takeaway
- The real fix is always architectural: extract the shared concern into a new service.
- Avoid the `Injector.get()` workaround except as a temporary bridge during refactoring.

---

### Issue #34: Memory Leak in Route-Level Subscriptions
**Level:** 🟢 Expert
**Symptom:** Route-change side effects fire multiple times after navigating back and forth. Memory grows with each navigation.

**Root Cause:** `Router.events` is a hot observable that never completes. Subscribing in `ngOnInit` without unsubscribing creates a new subscription on every route navigation to this component, all of which stay alive.

#### Wrong (problematic code)
```typescript
@Component({ selector: 'app-shell' })
export class ShellComponent implements OnInit {
  ngOnInit() {
    // PROBLEM: new subscription on every navigate, old ones never cleaned up
    this.router.events
      .pipe(filter(e => e instanceof NavigationEnd))
      .subscribe(e => this.trackPageView(e)); // PROBLEM: fires N times after N visits
  }
}
```

#### Fix
```typescript
@Component({ selector: 'app-shell' })
export class ShellComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();

  ngOnInit() {
    this.router.events.pipe(
      filter(e => e instanceof NavigationEnd),
      takeUntil(this.destroy$) // WHY: subscription cleaned up when component destroys
    ).subscribe(e => this.trackPageView(e));
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

#### Mental Model
`router.events` is a public address system that never turns off — without `takeUntil`, every room you enter (route) adds a new loudspeaker that never goes away.

#### Key Takeaway
- Apply `takeUntil(destroy$)` to ALL router.events subscriptions.
- Only subscribe to router events in components that exist for the application's full lifetime (App Shell, Layout) — use Guards or Resolvers for route-specific logic instead.

---

### Issue #35: Lazy-Loaded Module Service Singleton Broken
**Level:** 🟢 Expert
**Symptom:** A service provided in a lazy-loaded module has a different instance than the root-level singleton. Two components see different state.

**Root Cause:** Angular creates a new child injector for each lazy-loaded module. If a service is declared in `providers` of a lazy module, it gets its own instance rather than sharing the root instance.

#### Wrong (problematic code)
```typescript
// lazy.module.ts
@NgModule({
  providers: [CartService] // PROBLEM: creates a SECOND CartService instance in lazy injector
})
export class LazyModule {}

// CartService was also provided in AppModule — now two instances exist
```

#### Fix
```typescript
// FIX 1: provide the service at root level
@Injectable({ providedIn: 'root' }) // WHY: always uses the single root instance regardless of where injected
export class CartService {}

// Remove from lazy module providers entirely

// FIX 2: forRoot() pattern for module-scoped singletons
@NgModule({})
export class CartModule {
  static forRoot(): ModuleWithProviders<CartModule> {
    return {
      ngModule: CartModule,
      providers: [CartService], // WHY: imported once in AppModule — single instance
    };
  }
}

// AppModule: imports: [CartModule.forRoot()]  — correct
// LazyModule: imports: [CartModule]           — no providers, shares root instance
```

#### Mental Model
A service in a lazy module's `providers` is like setting up a separate HR department on each floor — `providedIn: 'root'` is a single HR office the whole building shares.

#### Key Takeaway
- Prefer `providedIn: 'root'` for shared services.
- Use `forRoot()` pattern when a module must configure its service at import time.
- Never declare shared singleton services in lazy module `providers`.

---

### Issue #36: SSR / Universal — window/document Access
**Level:** 🟢 Expert
**Symptom:** `ReferenceError: window is not defined` or `document is not defined` crashes Node.js during Angular Universal server-side rendering.

**Root Cause:** `window`, `document`, `localStorage`, and `navigator` are browser APIs that do not exist in Node.js. Code that accesses them directly will throw at SSR time.

#### Wrong (problematic code)
```typescript
@Component({ selector: 'app-banner' })
export class BannerComponent implements OnInit {
  ngOnInit() {
    const width = window.innerWidth;      // PROBLEM: window undefined in Node.js
    document.title = 'My App';            // PROBLEM: document undefined in Node.js
    localStorage.setItem('key', 'val');   // PROBLEM: localStorage undefined in Node.js
  }
}
```

#### Fix
```typescript
import { isPlatformBrowser }          from '@angular/common';
import { PLATFORM_ID, Inject }        from '@angular/core';

@Component({ selector: 'app-banner' })
export class BannerComponent implements OnInit {
  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  ngOnInit() {
    if (isPlatformBrowser(this.platformId)) { // WHY: guard — only runs in browser
      const width = window.innerWidth;
      localStorage.setItem('key', 'val');
    }
  }
}

// ALTERNATIVE: use Angular's injection tokens
import { DOCUMENT } from '@angular/common';

@Component({ selector: 'app-title' })
export class TitleComponent {
  constructor(@Inject(DOCUMENT) private document: Document) {} // WHY: Angular injects safe SSR stub

  setTitle(title: string) {
    this.document.title = title; // WHY: works on both server and browser
  }
}
```

#### Mental Model
`window` in SSR is like bringing a car key to a city with no roads — Angular's `PLATFORM_ID` guard checks whether you're in a city before trying to drive.

#### Key Takeaway
- Always guard browser-only APIs with `isPlatformBrowser(platformId)`.
- Use Angular's `DOCUMENT` injection token instead of direct `document` access.
- `localStorage` has no SSR equivalent — use cookies or transfer state via `TransferState` API.

---

# REFERENCE

## React vs Angular Issue Equivalence Map

| React Issue | Angular Equivalent | Core Concept |
|---|---|---|
| Mutating state directly (`arr.push`) | Mutating `@Input()` or OnPush observable without new ref | Immutability for change detection |
| Missing useEffect deps → stale closure | Template method called on every CD cycle | Avoiding stale / redundant computation |
| useEffect cleanup not implemented | Forgetting to unsubscribe / no `takeUntil` | Subscription / effect lifecycle management |
| Race condition in async fetch | Cold vs hot observable confusion | Async stream management |
| Context causing full tree re-render | Zone.js triggering full CD on every async event | Scoping state change propagation |
| Bundle size / code splitting not done | Lazy-loaded module service singleton broken | Module boundaries and loading strategy |
| Hydration mismatch (Next.js SSR) | SSR / Universal: window/document access | Server vs browser environment differences |
| useCallback stale closure | `shareReplay` without refCount | Caching and referential stability |
| Custom hook infinite loop | ExpressionChangedAfterItHasBeenCheckedError | Mutation during detection cycle |
| React.memo + useCallback for re-renders | OnPush + markForCheck for re-renders | Optimistic re-render prevention |
| Concurrent Mode tearing | OnPush not detecting nested object mutation | Snapshot consistency during detection |
| Prop drilling hell | Nested subscribe anti-pattern | Dependency / state propagation patterns |

---

## Quick Debug Checklist

### React Debug Checklist

```
State & Rendering
  [ ] Are all state updates returning new references (no direct mutation)?
  [ ] Does the useEffect dependency array list every variable the effect reads?
  [ ] Is React.memo applied to expensive child components?
  [ ] Are functions passed to memoized children wrapped in useCallback?
  [ ] Are objects/arrays created in render wrapped in useMemo?

Hooks
  [ ] Are all hooks called unconditionally at the top level (no conditionals, loops, early returns before hooks)?
  [ ] Does every useEffect that starts something return a cleanup function?
  [ ] Is the useEffect callback NOT marked async (inner async function used instead)?

Lists
  [ ] Do all list items have a stable, unique key (not array index)?

Event Handlers
  [ ] Are event handlers passed as references (onClick={fn}) not invocations (onClick={fn()})?

Async / Data
  [ ] Are concurrent fetches guarded with a cancellation flag or AbortController?
  [ ] Does the app handle the unmounted-component-update case?

SSR (Next.js)
  [ ] Is no non-deterministic value (Date, Math.random, window) in the initial render?
  [ ] Are browser-only APIs guarded behind useEffect or dynamic import?

Performance
  [ ] Are heavy components lazy-loaded with React.lazy + Suspense?
  [ ] Has the React DevTools Profiler confirmed which components are hot?
```

### Angular Debug Checklist

```
Subscriptions
  [ ] Does every long-lived subscription use takeUntil(destroy$) or async pipe?
  [ ] Is ngOnDestroy implemented with destroy$.next() + destroy$.complete()?
  [ ] Is shareReplay using { bufferSize: 1, refCount: true } unless caching is intentional?

RxJS Streams
  [ ] Is catchError placed INSIDE the inner observable (switchMap/concatMap), not outside?
  [ ] Are nested subscribes replaced with switchMap / concatMap / mergeMap?
  [ ] Are cold observables shared with shareReplay when multiple subscribers exist?

Change Detection
  [ ] Are OnPush components always receiving new references (not mutated inputs)?
  [ ] Does any OnPush component with manual subscribe call markForCheck()?
  [ ] Are template expressions free of side effects and heavy computation (use pipes instead)?
  [ ] Are high-frequency async operations running outside NgZone?

Lifecycle
  [ ] Is heavy initialization in ngOnInit, not in the constructor?
  [ ] Are DOM operations in ngAfterViewInit, not ngOnInit?
  [ ] Does any ngAfterViewInit emit to a parent without Promise.resolve() deferral?

Dependency Injection
  [ ] Are shared singleton services using providedIn: 'root' (not in lazy module providers)?
  [ ] Is there any circular dependency (A→B→A) that needs a SharedService extraction?

Module Setup
  [ ] Are FormsModule / ReactiveFormsModule / HttpClientModule imported where needed?
  [ ] Are shared components exported from SharedModule and imported where consumed?

SSR (Angular Universal)
  [ ] Are all window / document / localStorage accesses guarded with isPlatformBrowser()?
  [ ] Is the DOCUMENT injection token used instead of direct document access?
```

---

*End of Guide — React & Angular Common Issues, Pitfalls & Solutions*
*Style follows project conventions: inline WHY comments, mental model analogies, ASCII flow diagrams, Key Takeaways per issue.*
