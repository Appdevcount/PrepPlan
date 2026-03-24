# 11 — React.js Patterns

> **Mental Model:** React is a UI function machine — give it state, it returns UI.
> Components are pure functions of props + state. Side effects live in hooks.
> Global state is a shared signal. The component tree is a tree of pure renders.

---

## Project Structure — Feature-Based

```
src/
├── app/                          ← App shell, routing, providers
│   ├── store/                    Redux store setup
│   ├── router/                   Route definitions (lazy loaded)
│   └── App.tsx
│
├── features/                     ← One folder per domain feature
│   ├── orders/
│   │   ├── components/           UI components for this feature
│   │   │   ├── OrderList.tsx
│   │   │   └── OrderDetail.tsx
│   │   ├── hooks/                Feature-specific custom hooks
│   │   │   └── useOrders.ts
│   │   ├── store/                Redux slice for this feature
│   │   │   └── ordersSlice.ts
│   │   ├── api/                  RTK Query or fetch wrappers
│   │   │   └── ordersApi.ts
│   │   ├── types/                TypeScript interfaces
│   │   │   └── order.types.ts
│   │   └── index.ts              Public barrel export
│   └── auth/
│
├── shared/                       ← Reusable across features
│   ├── components/               Button, Modal, Spinner, ErrorBanner
│   ├── hooks/                    useDebounce, useLocalStorage, useMediaQuery
│   └── utils/                    formatCurrency, parseDate
│
└── styles/                       Global CSS / Tailwind config
```

---

## Component Patterns

```tsx
// ── RULE: Components are display logic only. No HTTP, no complex transforms. ──
// ── RULE: Co-locate state as close to where it's used as possible. ───────────
// ── RULE: useMemo / useCallback only when profiling proves it's needed. ───────

// ── Functional component with proper TypeScript types ────────────────────────
interface OrderCardProps {
  order: Order;
  onSelect: (id: string) => void;
  isSelected?: boolean;     // optional with default
}

// WHY named export not default: enables IDE rename refactoring and better tree-shaking
export function OrderCard({ order, onSelect, isSelected = false }: OrderCardProps) {
  // Derive display values inline — no useEffect needed for pure derivations
  const statusColor = order.status === 'confirmed' ? 'green' : 'gray';
  const formattedTotal = new Intl.NumberFormat('en-US', {
    style: 'currency', currency: order.currency
  }).format(order.total);

  return (
    <div
      className={`order-card ${isSelected ? 'selected' : ''}`}
      onClick={() => onSelect(order.id)}
      // WHY role+aria: makes clickable divs accessible to screen readers
      role="button"
      aria-pressed={isSelected}
      tabIndex={0}
    >
      <span className={`status-badge status-${statusColor}`}>{order.status}</span>
      <h3>Order #{order.id.slice(-6)}</h3>
      <p>{formattedTotal}</p>
    </div>
  );
}

// ── Compound component pattern — for related UI pieces ────────────────────────
// WHY compound: keeps related components together, shared implicit state via context
// e.g. <Tabs>, <Tabs.List>, <Tabs.Tab>, <Tabs.Panel>

interface TabsContextValue {
  activeTab: string;
  setActiveTab: (id: string) => void;
}
const TabsContext = createContext<TabsContextValue | null>(null);

function useTabsContext() {
  const ctx = useContext(TabsContext);
  // WHY throw: consuming Tab outside Tabs is a developer error — fail loudly
  if (!ctx) throw new Error('Tab must be used inside <Tabs>');
  return ctx;
}

export function Tabs({ children, defaultTab }: { children: ReactNode; defaultTab: string }) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {children}
    </TabsContext.Provider>
  );
}

Tabs.Tab = function Tab({ id, children }: { id: string; children: ReactNode }) {
  const { activeTab, setActiveTab } = useTabsContext();
  return (
    <button
      role="tab"
      aria-selected={activeTab === id}
      onClick={() => setActiveTab(id)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function Panel({ id, children }: { id: string; children: ReactNode }) {
  const { activeTab } = useTabsContext();
  // WHY hidden not null: keeps DOM node mounted (preserves scroll/form state)
  return <div role="tabpanel" hidden={activeTab !== id}>{children}</div>;
};
```

---

## Custom Hooks — Data Fetching

```tsx
// ── RULE: Custom hooks extract logic, not just state. ─────────────────────────
// ── RULE: Hook names start with "use". Return object not array for >2 values. ─

// ── useOrders — encapsulates all order-fetching logic ────────────────────────
interface UseOrdersOptions {
  status?: string;
  page?: number;
  pageSize?: number;
}

interface UseOrdersResult {
  orders: Order[];
  isLoading: boolean;
  isError: boolean;
  error: string | null;
  totalCount: number;
  refetch: () => void;
}

export function useOrders(options: UseOrdersOptions = {}): UseOrdersResult {
  const [orders, setOrders]       = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isError, setIsError]     = useState(false);
  const [error, setError]         = useState<string | null>(null);
  const [totalCount, setTotal]    = useState(0);

  // WHY useCallback: stable reference prevents infinite re-fetch loop
  //   when fetchOrders is a dependency of useEffect
  const fetchOrders = useCallback(async () => {
    setIsLoading(true);
    setIsError(false);
    setError(null);

    try {
      const result = await ordersApi.getAll(options);
      setOrders(result.items);
      setTotal(result.totalCount);
    } catch (err) {
      setIsError(true);
      setError(err instanceof Error ? err.message : 'Failed to load orders');
    } finally {
      setIsLoading(false);   // WHY finally: always reset loading regardless of success/error
    }
  }, [options.status, options.page, options.pageSize]);
  // WHY destructure deps: object reference changes on every render — would infinite loop

  useEffect(() => {
    fetchOrders();
  }, [fetchOrders]);

  return { orders, isLoading, isError, error, totalCount, refetch: fetchOrders };
}

// ── useDebounce — delay value updates ────────────────────────────────────────
// WHY: search input fires on every keystroke. Debounce waits until user pauses.
export function useDebounce<T>(value: T, delayMs: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delayMs);
    // WHY return cleanup: cancel the timer if value changes before delay expires.
    //   Without cleanup: timer from "an" fires after 300ms even if user has typed "angular"
    return () => clearTimeout(timer);
  }, [value, delayMs]);

  return debouncedValue;
}

// ── useLocalStorage — persistent state ───────────────────────────────────────
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    // WHY lazy initializer (function form): runs only on mount, not every render
    try {
      const stored = localStorage.getItem(key);
      return stored ? JSON.parse(stored) : initialValue;
    } catch {
      return initialValue;   // WHY catch: corrupt localStorage JSON shouldn't crash the app
    }
  });

  const setStoredValue = useCallback((newValue: T | ((prev: T) => T)) => {
    setValue(prev => {
      const resolved = typeof newValue === 'function'
        ? (newValue as (prev: T) => T)(prev)
        : newValue;
      localStorage.setItem(key, JSON.stringify(resolved));
      return resolved;
    });
  }, [key]);

  return [value, setStoredValue] as const;
}
```

---

## Redux Toolkit — State Management

```tsx
// ── ordersSlice.ts ─────────────────────────────────────────────────────────────
import { createSlice, createAsyncThunk, createSelector } from '@reduxjs/toolkit';

// ── Async thunk — encapsulates async logic outside the component ──────────────
// WHY createAsyncThunk: handles pending/fulfilled/rejected states automatically.
//   Component dispatches it; slice handles state transitions.
export const fetchOrders = createAsyncThunk(
  'orders/fetchAll',
  async (filter: OrderFilter, { rejectWithValue }) => {
    try {
      return await ordersApi.getAll(filter);
    } catch (err) {
      // WHY rejectWithValue not throw: lets us put the error in state as a string.
      //   Throwing makes Redux Toolkit reject with a SerializedError — harder to display.
      return rejectWithValue(err instanceof Error ? err.message : 'Unknown error');
    }
  }
);

// ── Slice — state + reducers + actions ───────────────────────────────────────
interface OrdersState {
  items: Order[];
  status: 'idle' | 'loading' | 'succeeded' | 'failed';   // WHY union: impossible invalid states
  error: string | null;
  selectedId: string | null;
}

const ordersSlice = createSlice({
  name: 'orders',
  initialState: { items: [], status: 'idle', error: null, selectedId: null } as OrdersState,

  reducers: {
    // Synchronous reducers — pure state transitions
    selectOrder(state, action: PayloadAction<string>) {
      state.selectedId = action.payload;
      // WHY direct mutation: Immer (inside RTK) produces immutable update under the hood
    },
    clearSelection(state) {
      state.selectedId = null;
    },
  },

  // Async thunk state transitions
  extraReducers: (builder) => {
    builder
      .addCase(fetchOrders.pending, (state) => {
        state.status = 'loading';
        state.error = null;     // WHY clear error: fresh attempt — old error is stale
      })
      .addCase(fetchOrders.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.items = action.payload.items;
      })
      .addCase(fetchOrders.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload as string;
      });
  },
});

export const { selectOrder, clearSelection } = ordersSlice.actions;
export default ordersSlice.reducer;

// ── Memoized selectors — prevent unnecessary re-renders ──────────────────────
// WHY createSelector: recomputes only when input (items, status) changes.
//   Plain function re-runs on every render even if data is the same.
const selectAllOrders = (state: RootState) => state.orders.items;
const selectOrdersStatus = (state: RootState) => state.orders.status;

export const selectConfirmedOrders = createSelector(
  [selectAllOrders],
  // WHY memoized: filter creates new array — without memo, triggers re-render every time
  (orders) => orders.filter(o => o.status === 'confirmed')
);

export const selectOrdersViewModel = createSelector(
  [selectAllOrders, selectOrdersStatus],
  (orders, status) => ({
    orders,
    isLoading: status === 'loading',
    isEmpty: status === 'succeeded' && orders.length === 0,
  })
);

// ── Component — reads from Redux ──────────────────────────────────────────────
export function OrderListPage() {
  const dispatch = useAppDispatch();
  // WHY useAppDispatch/useAppSelector: typed wrappers — no casting needed
  const { orders, isLoading, isEmpty } = useAppSelector(selectOrdersViewModel);

  useEffect(() => {
    dispatch(fetchOrders({ status: 'all' }));
  }, [dispatch]);   // WHY [dispatch]: dispatch is stable — won't cause extra fetches

  if (isLoading) return <Spinner />;
  if (isEmpty)   return <EmptyState message="No orders found" />;

  return <OrderList orders={orders} />;
}
```

---

## Performance — React.memo, useMemo, useCallback

```tsx
// ── RULE: Profile before optimising. Don't add memo/callback blindly. ─────────
// ── When to memo: list items, expensive renders, stable prop references needed ─

// ── React.memo — skip re-render if props haven't changed ─────────────────────
// WHY: OrderRow is in a large list. Parent re-renders on filter change.
//   Without memo: all 100 rows re-render even if their data didn't change.
//   With memo: only rows with changed order data re-render.
export const OrderRow = React.memo(function OrderRow({
  order,
  onSelect,
}: {
  order: Order;
  onSelect: (id: string) => void;
}) {
  return <tr onClick={() => onSelect(order.id)}><td>{order.id}</td></tr>;
});
// WHY named function inside memo: improves React DevTools display name
// WHY NOT wrap everything in memo: has a comparison cost — defeats purpose on cheap renders

// ── useCallback — stable function reference for memoized children ─────────────
function OrderListPage() {
  const dispatch = useAppDispatch();

  // WHY useCallback here: onSelect passed to React.memo'd OrderRow.
  //   Without useCallback: new function reference on every render → memo is useless.
  const handleSelect = useCallback((id: string) => {
    dispatch(selectOrder(id));
  }, [dispatch]);   // stable because dispatch is stable

  return <OrderRow order={order} onSelect={handleSelect} />;
}

// ── useMemo — expensive computation ──────────────────────────────────────────
function OrderSummary({ orders }: { orders: Order[] }) {
  // WHY useMemo: sorting + aggregation runs only when orders changes.
  //   Without it: re-runs on EVERY render of OrderSummary (including unrelated state changes).
  const stats = useMemo(() => ({
    total: orders.reduce((sum, o) => sum + o.total, 0),
    confirmed: orders.filter(o => o.status === 'confirmed').length,
    sorted: [...orders].sort((a, b) => b.total - a.total),
  }), [orders]);   // WHY [orders]: recompute only when orders array reference changes

  return <div>Total: {stats.total} | Confirmed: {stats.confirmed}</div>;
}
```

---

## Error Boundaries

```tsx
// WHY Error Boundary: unhandled render errors crash the whole app without it.
//   Error boundaries catch render errors in the component tree and show fallback UI.
//   NOTE: class component required — no functional equivalent yet in React 18.

class ErrorBoundary extends React.Component<
  { children: ReactNode; fallback?: ReactNode },
  { hasError: boolean; error: Error | null }
> {
  state = { hasError: false, error: null };

  // WHY static: called during render phase — must not cause side effects
  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    // WHY componentDidCatch: commit phase — safe for side effects (logging)
    console.error('ErrorBoundary caught:', error, info.componentStack);
    errorTracker.report(error, { componentStack: info.componentStack });
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div role="alert">
          <h2>Something went wrong</h2>
          <button onClick={() => this.setState({ hasError: false, error: null })}>
            Try again
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

// Usage — wrap feature sections, not individual components
function App() {
  return (
    <ErrorBoundary fallback={<FullPageError />}>
      <ErrorBoundary fallback={<SectionError section="orders" />}>
        <OrdersPage />
      </ErrorBoundary>
      <ErrorBoundary fallback={<SectionError section="customers" />}>
        <CustomersPage />
      </ErrorBoundary>
    </ErrorBoundary>
  );
}
```

---

## Code Splitting & Lazy Loading

```tsx
// WHY lazy + Suspense: load feature code only when navigated to.
//   Orders bundle doesn't download until user visits /orders.
//   Initial load is faster — critical for perceived performance.

const OrdersPage    = lazy(() => import('../features/orders/OrdersPage'));
const CustomersPage = lazy(() => import('../features/customers/CustomersPage'));

function AppRouter() {
  return (
    // WHY Suspense at router level: one fallback for all lazy routes
    <Suspense fallback={<PageLoadingSpinner />}>
      <Routes>
        <Route path="/orders"    element={<OrdersPage />} />
        <Route path="/customers" element={<CustomersPage />} />
      </Routes>
    </Suspense>
  );
}

// WHY /* webpackChunkName */: gives the bundle a readable name in DevTools
const HeavyChart = lazy(
  () => import(/* webpackChunkName: "charts" */ '../shared/components/HeavyChart')
);
```
