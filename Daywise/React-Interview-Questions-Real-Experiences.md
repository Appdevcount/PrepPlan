# React Real Interview Questions from Top Companies

Based on real experiences shared by developers who interviewed at FAANG, MAANG, and top service/product companies.

---

## Table of Contents

1. [Hooks & State Management](#hooks--state-management)
2. [Performance Optimization](#performance-optimization)
3. [Context API & Global State](#context-api--global-state)
4. [Custom Hooks](#custom-hooks)
5. [Server-Side Rendering (Next.js)](#server-side-rendering-nextjs)
6. [Testing](#testing)
7. [Advanced Patterns](#advanced-patterns)
8. [TypeScript with React](#typescript-with-react)
9. [Data Fetching & Caching](#data-fetching--caching)
10. [Architecture & Best Practices](#architecture--best-practices)

---

## Hooks & State Management

### Q1: Implement a shopping cart with useState and useReducer (Asked at: Amazon, Shopify)

**Question:** Create a shopping cart that manages items, quantities, and calculates totals. Compare useState vs useReducer approaches and explain when to use each.

**Implementation:**

```typescript
// types.ts
export interface Product {
  id: number;
  name: string;
  price: number;
  image: string;
  category: string;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

export interface Discount {
  code: string;
  percentage: number;
  minAmount: number;
}

// ============================================
// APPROACH 1: useState (Simple state)
// ============================================

// CartWithUseState.tsx
import React, { useState, useMemo } from 'react';

interface CartWithUseStateProps {
  products: Product[];
}

export const CartWithUseState: React.FC<CartWithUseStateProps> = ({ products }) => {
  // Separate state for each concern
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [discountCode, setDiscountCode] = useState<string>('');
  const [appliedDiscount, setAppliedDiscount] = useState<Discount | null>(null);
  
  // Available discounts
  const availableDiscounts: Discount[] = [
    { code: 'SAVE10', percentage: 10, minAmount: 100 },
    { code: 'SAVE20', percentage: 20, minAmount: 200 },
    { code: 'SAVE30', percentage: 30, minAmount: 300 }
  ];
  
  // Memoized calculations (only recalculate when cartItems or appliedDiscount changes)
  const subtotal = useMemo(() => {
    return cartItems.reduce((sum, item) => {
      return sum + (item.product.price * item.quantity);
    }, 0);
  }, [cartItems]);
  
  const discountAmount = useMemo(() => {
    if (!appliedDiscount) return 0;
    return (subtotal * appliedDiscount.percentage) / 100;
  }, [subtotal, appliedDiscount]);
  
  const total = useMemo(() => {
    return subtotal - discountAmount;
  }, [subtotal, discountAmount]);
  
  const itemCount = useMemo(() => {
    return cartItems.reduce((count, item) => count + item.quantity, 0);
  }, [cartItems]);

  /**
   * Add item to cart
   * Creates new array to maintain immutability
   */
  const addToCart = (product: Product) => {
    setCartItems(prevItems => {
      // Check if item already exists
      const existingItem = prevItems.find(item => item.product.id === product.id);
      
      if (existingItem) {
        // Update quantity immutably
        return prevItems.map(item =>
          item.product.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      } else {
        // Add new item
        return [...prevItems, { product, quantity: 1 }];
      }
    });
  };

  /**
   * Remove item from cart
   */
  const removeFromCart = (productId: number) => {
    setCartItems(prevItems => prevItems.filter(item => item.product.id !== productId));
  };

  /**
   * Update item quantity
   */
  const updateQuantity = (productId: number, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    
    setCartItems(prevItems =>
      prevItems.map(item =>
        item.product.id === productId
          ? { ...item, quantity }
          : item
      )
    );
  };

  /**
   * Apply discount code
   */
  const applyDiscount = () => {
    const discount = availableDiscounts.find(d => d.code === discountCode.toUpperCase());
    
    if (!discount) {
      alert('Invalid discount code');
      return;
    }
    
    if (subtotal < discount.minAmount) {
      alert(`Minimum amount of $${discount.minAmount} required`);
      return;
    }
    
    setAppliedDiscount(discount);
    setDiscountCode('');
  };

  /**
   * Clear cart
   */
  const clearCart = () => {
    setCartItems([]);
    setAppliedDiscount(null);
  };

  return (
    <div className="cart-container">
      <h2>Shopping Cart (useState)</h2>
      
      {/* Products Grid */}
      <div className="products-grid">
        <h3>Products</h3>
        {products.map(product => (
          <div key={product.id} className="product-card">
            <img src={product.image} alt={product.name} />
            <h4>{product.name}</h4>
            <p className="price">${product.price.toFixed(2)}</p>
            <button onClick={() => addToCart(product)}>Add to Cart</button>
          </div>
        ))}
      </div>
      
      {/* Cart Items */}
      <div className="cart-section">
        <h3>Cart ({itemCount} items)</h3>
        {cartItems.length === 0 ? (
          <p>Cart is empty</p>
        ) : (
          <>
            {cartItems.map(item => (
              <div key={item.product.id} className="cart-item">
                <div className="item-info">
                  <strong>{item.product.name}</strong>
                  <span>${item.product.price} × {item.quantity}</span>
                </div>
                
                <div className="item-controls">
                  <button onClick={() => updateQuantity(item.product.id, item.quantity - 1)}>-</button>
                  <span>{item.quantity}</span>
                  <button onClick={() => updateQuantity(item.product.id, item.quantity + 1)}>+</button>
                  <button onClick={() => removeFromCart(item.product.id)}>Remove</button>
                </div>
              </div>
            ))}
            
            {/* Discount Section */}
            <div className="discount-section">
              <input
                type="text"
                value={discountCode}
                onChange={(e) => setDiscountCode(e.target.value)}
                placeholder="Discount code"
                disabled={!!appliedDiscount}
              />
              {appliedDiscount ? (
                <button onClick={() => setAppliedDiscount(null)}>
                  Remove {appliedDiscount.code}
                </button>
              ) : (
                <button onClick={applyDiscount}>Apply</button>
              )}
            </div>
            
            {/* Summary */}
            <div className="cart-summary">
              <div>Subtotal: ${subtotal.toFixed(2)}</div>
              {appliedDiscount && (
                <div className="discount">
                  Discount ({appliedDiscount.code} - {appliedDiscount.percentage}%): 
                  -${discountAmount.toFixed(2)}
                </div>
              )}
              <div className="total">Total: ${total.toFixed(2)}</div>
              <button onClick={clearCart}>Clear Cart</button>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

// ============================================
// APPROACH 2: useReducer (Complex state logic)
// ============================================

// cartReducer.ts
type CartState = {
  items: CartItem[];
  discountCode: string;
  appliedDiscount: Discount | null;
};

type CartAction =
  | { type: 'ADD_ITEM'; payload: Product }
  | { type: 'REMOVE_ITEM'; payload: number }
  | { type: 'UPDATE_QUANTITY'; payload: { productId: number; quantity: number } }
  | { type: 'APPLY_DISCOUNT'; payload: Discount }
  | { type: 'REMOVE_DISCOUNT' }
  | { type: 'SET_DISCOUNT_CODE'; payload: string }
  | { type: 'CLEAR_CART' };

/**
 * Cart reducer - handles all cart state transitions
 * Benefits: 
 * - All state logic in one place
 * - Easier to test
 * - Better for complex state updates
 * - Predictable state transitions
 */
export const cartReducer = (state: CartState, action: CartAction): CartState => {
  switch (action.type) {
    case 'ADD_ITEM': {
      const product = action.payload;
      const existingItem = state.items.find(item => item.product.id === product.id);
      
      if (existingItem) {
        // Increment quantity
        return {
          ...state,
          items: state.items.map(item =>
            item.product.id === product.id
              ? { ...item, quantity: item.quantity + 1 }
              : item
          )
        };
      } else {
        // Add new item
        return {
          ...state,
          items: [...state.items, { product, quantity: 1 }]
        };
      }
    }
    
    case 'REMOVE_ITEM': {
      return {
        ...state,
        items: state.items.filter(item => item.product.id !== action.payload)
      };
    }
    
    case 'UPDATE_QUANTITY': {
      const { productId, quantity } = action.payload;
      
      if (quantity <= 0) {
        // Remove item if quantity is 0
        return {
          ...state,
          items: state.items.filter(item => item.product.id !== productId)
        };
      }
      
      return {
        ...state,
        items: state.items.map(item =>
          item.product.id === productId
            ? { ...item, quantity }
            : item
        )
      };
    }
    
    case 'APPLY_DISCOUNT': {
      return {
        ...state,
        appliedDiscount: action.payload,
        discountCode: ''
      };
    }
    
    case 'REMOVE_DISCOUNT': {
      return {
        ...state,
        appliedDiscount: null
      };
    }
    
    case 'SET_DISCOUNT_CODE': {
      return {
        ...state,
        discountCode: action.payload
      };
    }
    
    case 'CLEAR_CART': {
      return {
        items: [],
        discountCode: '',
        appliedDiscount: null
      };
    }
    
    default:
      return state;
  }
};

// CartWithUseReducer.tsx
import React, { useReducer, useMemo } from 'react';

const initialState: CartState = {
  items: [],
  discountCode: '',
  appliedDiscount: null
};

export const CartWithUseReducer: React.FC<CartWithUseStateProps> = ({ products }) => {
  // Use reducer for complex state management
  const [state, dispatch] = useReducer(cartReducer, initialState);
  
  const availableDiscounts: Discount[] = [
    { code: 'SAVE10', percentage: 10, minAmount: 100 },
    { code: 'SAVE20', percentage: 20, minAmount: 200 },
    { code: 'SAVE30', percentage: 30, minAmount: 300 }
  ];
  
  // Memoized selectors
  const subtotal = useMemo(() => {
    return state.items.reduce((sum, item) => {
      return sum + (item.product.price * item.quantity);
    }, 0);
  }, [state.items]);
  
  const discountAmount = useMemo(() => {
    if (!state.appliedDiscount) return 0;
    return (subtotal * state.appliedDiscount.percentage) / 100;
  }, [subtotal, state.appliedDiscount]);
  
  const total = useMemo(() => {
    return subtotal - discountAmount;
  }, [subtotal, discountAmount]);
  
  const itemCount = useMemo(() => {
    return state.items.reduce((count, item) => count + item.quantity, 0);
  }, [state.items]);

  /**
   * Actions dispatchers
   */
  const addToCart = (product: Product) => {
    dispatch({ type: 'ADD_ITEM', payload: product });
  };

  const removeFromCart = (productId: number) => {
    dispatch({ type: 'REMOVE_ITEM', payload: productId });
  };

  const updateQuantity = (productId: number, quantity: number) => {
    dispatch({ type: 'UPDATE_QUANTITY', payload: { productId, quantity } });
  };

  const applyDiscount = () => {
    const discount = availableDiscounts.find(
      d => d.code === state.discountCode.toUpperCase()
    );
    
    if (!discount) {
      alert('Invalid discount code');
      return;
    }
    
    if (subtotal < discount.minAmount) {
      alert(`Minimum amount of $${discount.minAmount} required`);
      return;
    }
    
    dispatch({ type: 'APPLY_DISCOUNT', payload: discount });
  };

  const clearCart = () => {
    dispatch({ type: 'CLEAR_CART' });
  };

  // Same JSX as useState version...
  return (
    <div className="cart-container">
      <h2>Shopping Cart (useReducer)</h2>
      {/* ... identical JSX ... */}
    </div>
  );
};
```

**When to use useState vs useReducer:**

| Scenario | useState | useReducer |
|----------|----------|------------|
| Simple state (single value) | ✅ Best choice | ❌ Overkill |
| Independent state updates | ✅ Good | ⚠️ Possible |
| Complex state object | ⚠️ Multiple setState calls | ✅ Single dispatch |
| State transitions depend on previous state | ⚠️ Can be error-prone | ✅ Safer |
| Multiple related state values | ❌ Hard to keep in sync | ✅ Grouped naturally |
| State logic needs testing | ⚠️ Harder to isolate | ✅ Pure function, easy to test |
| Need to share state logic | ❌ Duplicate code | ✅ Reusable reducer |

---

### Q2: Implement useEffect cleanup and dependency array correctly (Asked at: Google, Meta)

**Question:** Create a component that fetches data, handles race conditions, and cleans up properly. Explain common useEffect pitfalls.

**Implementation:**

```typescript
// UserProfile.tsx
import React, { useState, useEffect, useCallback } from 'react';

interface User {
  id: number;
  name: string;
  email: string;
  bio: string;
  avatar: string;
}

interface UserProfileProps {
  userId: number;
}

export const UserProfile: React.FC<UserProfileProps> = ({ userId }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  /**
   * Fetch user data with proper cleanup
   * 
   * COMMON PITFALLS TO AVOID:
   * 1. Not cleaning up async operations
   * 2. Missing dependencies in dependency array
   * 3. Stale closures
   * 4. Race conditions with rapid changes
   */
  useEffect(() => {
    // Cleanup flag to prevent state updates after unmount
    let isCancelled = false;
    
    // AbortController to cancel fetch on cleanup
    const abortController = new AbortController();
    
    const fetchUser = async () => {
      try {
        setLoading(true);
        setError(null);
        
        console.log(`Fetching user ${userId}...`);
        
        const response = await fetch(`/api/users/${userId}`, {
          signal: abortController.signal // Pass abort signal
        });
        
        if (!response.ok) {
          throw new Error('Failed to fetch user');
        }
        
        const data = await response.json();
        
        // Only update state if component is still mounted
        if (!isCancelled) {
          setUser(data);
          setLoading(false);
          console.log(`✓ User ${userId} loaded`);
        } else {
          console.log(`✗ User ${userId} fetch cancelled (component unmounted)`);
        }
      } catch (error: any) {
        // Only update state if component is still mounted and not aborted
        if (!isCancelled && error.name !== 'AbortError') {
          setError(error.message);
          setLoading(false);
          console.error(`✗ Error fetching user ${userId}:`, error);
        }
      }
    };
    
    fetchUser();
    
    // Cleanup function - runs before next effect and on unmount
    return () => {
      console.log(`Cleaning up effect for user ${userId}`);
      isCancelled = true; // Prevent state updates
      abortController.abort(); // Cancel ongoing fetch
    };
  }, [userId]); // Re-run effect when userId changes

  if (loading) {
    return <div>Loading user...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  if (!user) {
    return <div>No user found</div>;
  }

  return (
    <div className="user-profile">
      <img src={user.avatar} alt={user.name} />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
      <p>{user.bio}</p>
    </div>
  );
};

// ============================================
// EXAMPLE: WebSocket with cleanup
// ============================================

interface ChatProps {
  roomId: string;
}

export const Chat: React.FC<ChatProps> = ({ roomId }) => {
  const [messages, setMessages] = useState<string[]>([]);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    // Create WebSocket connection
    const ws = new WebSocket(`wss://chat.example.com/rooms/${roomId}`);
    
    // Connection opened
    ws.addEventListener('open', () => {
      console.log(`✓ Connected to room ${roomId}`);
      setIsConnected(true);
    });
    
    // Listen for messages
    ws.addEventListener('message', (event) => {
      console.log('Received message:', event.data);
      setMessages(prev => [...prev, event.data]);
    });
    
    // Connection closed
    ws.addEventListener('close', () => {
      console.log(`✗ Disconnected from room ${roomId}`);
      setIsConnected(false);
    });
    
    // Error handler
    ws.addEventListener('error', (error) => {
      console.error('WebSocket error:', error);
    });
    
    // Cleanup: Close WebSocket connection
    return () => {
      console.log(`Cleaning up WebSocket for room ${roomId}`);
      ws.close();
    };
  }, [roomId]); // Reconnect when roomId changes

  return (
    <div className="chat">
      <h3>Chat Room: {roomId}</h3>
      <div>Status: {isConnected ? '🟢 Connected' : '🔴 Disconnected'}</div>
      <div className="messages">
        {messages.map((msg, i) => (
          <div key={i}>{msg}</div>
        ))}
      </div>
    </div>
  );
};

// ============================================
// EXAMPLE: Event listener with cleanup
// ============================================

export const WindowSize: React.FC = () => {
  const [windowSize, setWindowSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight
  });

  useEffect(() => {
    // Handler function
    const handleResize = () => {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight
      });
    };
    
    // Add event listener
    window.addEventListener('resize', handleResize);
    
    // Cleanup: Remove event listener
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []); // Empty array = only run once (mount/unmount)

  return (
    <div>
      Window size: {windowSize.width} x {windowSize.height}
    </div>
  );
};

// ============================================
// EXAMPLE: Interval with cleanup
// ============================================

export const Timer: React.FC = () => {
  const [seconds, setSeconds] = useState(0);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    // Only set interval if timer is running
    if (!isRunning) return;
    
    // Start interval
    const intervalId = setInterval(() => {
      setSeconds(prev => prev + 1);
    }, 1000);
    
    // Cleanup: Clear interval
    return () => {
      clearInterval(intervalId);
    };
  }, [isRunning]); // Re-run when isRunning changes

  return (
    <div>
      <div>Time: {seconds}s</div>
      <button onClick={() => setIsRunning(!isRunning)}>
        {isRunning ? 'Pause' : 'Start'}
      </button>
      <button onClick={() => setSeconds(0)}>Reset</button>
    </div>
  );
};

// ============================================
// COMMON PITFALLS
// ============================================

/**
 * ❌ BAD: Missing dependency
 */
const BadExample1: React.FC = () => {
  const [count, setCount] = useState(0);
  
  useEffect(() => {
    // count is used but not in dependency array
    // This will always log 0, creating a stale closure
    const timer = setInterval(() => {
      console.log(count); // Always logs 0!
    }, 1000);
    
    return () => clearInterval(timer);
  }, []); // ❌ Missing 'count' dependency
  
  return <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>;
};

/**
 * ✅ GOOD: Include all dependencies
 */
const GoodExample1: React.FC = () => {
  const [count, setCount] = useState(0);
  
  useEffect(() => {
    const timer = setInterval(() => {
      console.log(count); // Logs current count
    }, 1000);
    
    return () => clearInterval(timer);
  }, [count]); // ✅ Includes count dependency
  
  return <button onClick={() => setCount(c => c + 1)}>Count: {count}</button>;
};

/**
 * ❌ BAD: Not cleaning up async operation
 */
const BadExample2: React.FC<{ id: number }> = ({ id }) => {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    fetch(`/api/data/${id}`)
      .then(res => res.json())
      .then(data => setData(data)); // ❌ May update state after unmount!
  }, [id]);
  
  return <div>{JSON.stringify(data)}</div>;
};

/**
 * ✅ GOOD: Proper cleanup
 */
const GoodExample2: React.FC<{ id: number }> = ({ id }) => {
  const [data, setData] = useState(null);
  
  useEffect(() => {
    let isCancelled = false; // Cleanup flag
    
    fetch(`/api/data/${id}`)
      .then(res => res.json())
      .then(data => {
        if (!isCancelled) { // ✅ Check before updating state
          setData(data);
        }
      });
    
    return () => {
      isCancelled = true; // ✅ Cleanup
    };
  }, [id]);
  
  return <div>{JSON.stringify(data)}</div>;
};
```

**useEffect Best Practices:**
1. ✅ Always clean up side effects (event listeners, timers, subscriptions)
2. ✅ Include all dependencies in the dependency array
3. ✅ Use AbortController for fetch requests
4. ✅ Use cleanup flags for async operations
5. ✅ Use functional setState for updates based on previous state
6. ✅ Avoid objects/functions as dependencies (use useMemo/useCallback)

---

## Performance Optimization

### Q3: Implement React.memo, useMemo, and useCallback correctly (Asked at: Netflix, Airbnb)

**Question:** Optimize a list component with thousands of items. Show when and how to use React.memo, useMemo, and useCallback.

**Implementation:**

```typescript
// ProductList.tsx
import React, { useState, useMemo, useCallback, memo } from 'react';

interface Product {
  id: number;
  name: string;
  price: number;
  category: string;
  inStock: boolean;
  rating: number;
}

// ============================================
// OPTIMIZED CHILD COMPONENT with React.memo
// ============================================

interface ProductCardProps {
  product: Product;
  onAddToCart: (product: Product) => void;
  onToggleFavorite: (productId: number) => void;
}

/**
 * React.memo prevents re-renders if props haven't changed
 * Uses shallow comparison by default
 * 
 * WITHOUT memo: Re-renders on every parent render
 * WITH memo: Only re-renders when props change
 */
const ProductCard = memo<ProductCardProps>(({ product, onAddToCart, onToggleFavorite }) => {
  console.log(`Rendering ProductCard ${product.id}`);
  
  return (
    <div className="product-card">
      <img src={`/images/${product.id}.jpg`} alt={product.name} />
      <h3>{product.name}</h3>
      <p className="price">${product.price.toFixed(2)}</p>
      <p className="category">{product.category}</p>
      <div className="rating">⭐ {product.rating.toFixed(1)}</div>
      <p className={product.inStock ? 'in-stock' : 'out-of-stock'}>
        {product.inStock ? 'In Stock' : 'Out of Stock'}
      </p>
      
      <button onClick={() => onAddToCart(product)} disabled={!product.inStock}>
        Add to Cart
      </button>
      
      <button onClick={() => onToggleFavorite(product.id)}>
        ❤️ Favorite
      </button>
    </div>
  );
});

ProductCard.displayName = 'ProductCard';

// ============================================
// CUSTOM COMPARISON for React.memo
// ============================================

/**
 * Custom comparison function for React.memo
 * Return true if props are equal (skip re-render)
 * Return false if props are different (re-render)
 */
const ProductCardWithCustomComparison = memo<ProductCardProps>(
  ({ product, onAddToCart, onToggleFavorite }) => {
    // ... same as above
    return <div>...</div>;
  },
  (prevProps, nextProps) => {
    // Custom comparison logic
    // Only re-render if product data actually changed
    return (
      prevProps.product.id === nextProps.product.id &&
      prevProps.product.price === nextProps.product.price &&
      prevProps.product.inStock === nextProps.product.inStock
      // Intentionally ignore callbacks (they're memoized)
    );
  }
);

// ============================================
// PARENT COMPONENT with useMemo and useCallback
// ============================================

export const ProductList: React.FC = () => {
  // State
  const [products, setProducts] = useState<Product[]>(generateProducts(1000)); // 1000 products
  const [searchQuery, setSearchQuery] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [sortBy, setSortBy] = useState<'name' | 'price' | 'rating'>('name');
  const [cart, setCart] = useState<Product[]>([]);
  const [favorites, setFavorites] = useState<Set<number>>(new Set());

  /**
   * useMemo: Memoize expensive computations
   * Only recalculates when dependencies change
   */
  const filteredProducts = useMemo(() => {
    console.log('🔄 Filtering products...');
    
    return products.filter(product => {
      // Filter by search query
      const matchesSearch = product.name.toLowerCase().includes(searchQuery.toLowerCase());
      
      // Filter by category
      const matchesCategory = categoryFilter === 'all' || product.category === categoryFilter;
      
      return matchesSearch && matchesCategory;
    });
  }, [products, searchQuery, categoryFilter]); // Only re-run when these change

  /**
   * useMemo: Sort products
   */
  const sortedProducts = useMemo(() => {
    console.log('🔄 Sorting products...');
    
    return [...filteredProducts].sort((a, b) => {
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
  }, [filteredProducts, sortBy]);

  /**
   * useMemo: Calculate statistics
   */
  const stats = useMemo(() => {
    console.log('🔄 Calculating stats...');
    
    return {
      total: sortedProducts.length,
      inStock: sortedProducts.filter(p => p.inStock).length,
      averagePrice: sortedProducts.reduce((sum, p) => sum + p.price, 0) / sortedProducts.length || 0
    };
  }, [sortedProducts]);

  /**
   * useCallback: Memoize callback functions
   * Prevents child components from re-rendering unnecessarily
   * 
   * WITHOUT useCallback: New function created on every render
   * WITH useCallback: Same function reference if dependencies haven't changed
   */
  const handleAddToCart = useCallback((product: Product) => {
    console.log('Adding to cart:', product.name);
    setCart(prevCart => [...prevCart, product]);
  }, []); // Empty deps = function never changes

  const handleToggleFavorite = useCallback((productId: number) => {
    console.log('Toggling favorite:', productId);
    setFavorites(prevFavorites => {
      const newFavorites = new Set(prevFavorites);
      if (newFavorites.has(productId)) {
        newFavorites.delete(productId);
      } else {
        newFavorites.add(productId);
      }
      return newFavorites;
    });
  }, []); // Empty deps = function never changes

  /**
   * useCallback with dependencies
   */
  const handleBulkDiscount = useCallback((percentage: number) => {
    setProducts(prevProducts =>
      prevProducts.map(product => ({
        ...product,
        price: product.price * (1 - percentage / 100)
      }))
    );
  }, []); // If percentage came from state, it would be in deps

  return (
    <div className="product-list-container">
      {/* Controls */}
      <div className="controls">
        <input
          type="text"
          placeholder="Search products..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
        
        <select value={categoryFilter} onChange={(e) => setCategoryFilter(e.target.value)}>
          <option value="all">All Categories</option>
          <option value="Electronics">Electronics</option>
          <option value="Clothing">Clothing</option>
          <option value="Books">Books</option>
        </select>
        
        <select value={sortBy} onChange={(e) => setSortBy(e.target.value as any)}>
          <option value="name">Sort by Name</option>
          <option value="price">Sort by Price</option>
          <option value="rating">Sort by Rating</option>
        </select>
      </div>
      
      {/* Stats */}
      <div className="stats">
        <div>Total: {stats.total}</div>
        <div>In Stock: {stats.inStock}</div>
        <div>Avg Price: ${stats.averagePrice.toFixed(2)}</div>
        <div>Cart: {cart.length} items</div>
        <div>Favorites: {favorites.size}</div>
      </div>
      
      {/* Products Grid */}
      <div className="products-grid">
        {sortedProducts.map(product => (
          <ProductCard
            key={product.id}
            product={product}
            onAddToCart={handleAddToCart}
            onToggleFavorite={handleToggleFavorite}
          />
        ))}
      </div>
    </div>
  );
};

/**
 * Generate mock products
 */
function generateProducts(count: number): Product[] {
  const categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports'];
  
  return Array.from({ length: count }, (_, i) => ({
    id: i + 1,
    name: `Product ${i + 1}`,
    price: Math.random() * 1000,
    category: categories[i % categories.length],
    inStock: Math.random() > 0.3,
    rating: Math.random() * 5
  }));
}
```

**Performance Optimization Comparison:**

| Technique | Purpose | When to Use | Common Mistakes |
|-----------|---------|-------------|-----------------|
| **React.memo** | Prevent component re-renders | Expensive components, pure rendering logic | Overusing on simple components, forgetting to memoize callbacks |
| **useMemo** | Memoize expensive calculations | Filtering/sorting large lists, complex calculations | Memoizing cheap operations, using for every value |
| **useCallback** | Memoize functions | Callbacks passed to memoized children | Using for internal functions, forgetting dependencies |

**When NOT to optimize:**
- ❌ Don't memo every component (adds overhead)
- ❌ Don't useMemo for simple calculations
- ❌ Don't useCallback for functions not passed to children
- ❌ Don't optimize prematurely - measure first!

---

*Continuing with more sections...*

## Context API & Global State

### Q4: Implement Context API with TypeScript and best practices (Asked at: Uber, Twitter)

**Question:** Create a theme and authentication context. Handle context updates efficiently and avoid unnecessary re-renders.

**Implementation:**

```typescript
// ============================================
// THEME CONTEXT with optimization
// ============================================

// ThemeContext.tsx
import React, { createContext, useContext, useState, useCallback, useMemo, ReactNode } from 'react';

// Theme types
type Theme = 'light' | 'dark' | 'auto';

interface ThemeColors {
  primary: string;
  secondary: string;
  background: string;
  text: string;
  border: string;
}

interface ThemeContextValue {
  theme: Theme;
  colors: ThemeColors;
  setTheme: (theme: Theme) => void;
  toggleTheme: () => void;
}

// Create context with undefined default (forces provider usage)
const ThemeContext = createContext<ThemeContextValue | undefined>(undefined);

// Theme configurations
const themes: Record<Theme, ThemeColors> = {
  light: {
    primary: '#2196f3',
    secondary: '#757575',
    background: '#ffffff',
    text: '#000000',
    border: '#dddddd'
  },
  dark: {
    primary: '#90caf9',
    secondary: '#b0b0b0',
    background: '#121212',
    text: '#ffffff',
    border: '#333333'
  },
  auto: {
    // Determined by system preference
    primary: '#2196f3',
    secondary: '#757575',
    background: '#ffffff',
    text: '#000000',
    border: '#dddddd'
  }
};

/**
 * Theme Provider Component
 * Provides theme state and update functions to children
 */
export const ThemeProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<Theme>(() => {
    // Initialize from localStorage or system preference
    const saved = localStorage.getItem('theme');
    return (saved as Theme) || 'light';
  });

  /**
   * Get current theme colors based on theme setting
   * Memoized to prevent recalculation on every render
   */
  const colors = useMemo(() => {
    if (theme === 'auto') {
      // Check system preference
      const isDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      return themes[isDark ? 'dark' : 'light'];
    }
    return themes[theme];
  }, [theme]);

  /**
   * Update theme and persist to localStorage
   * Memoized to maintain stable reference
   */
  const handleSetTheme = useCallback((newTheme: Theme) => {
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    console.log(`Theme changed to: ${newTheme}`);
  }, []);

  /**
   * Toggle between light and dark
   */
  const toggleTheme = useCallback(() => {
    setTheme(prev => prev === 'light' ? 'dark' : 'light');
  }, []);

  /**
   * Memoize context value to prevent unnecessary re-renders
   * Only recreate when theme or colors change
   */
  const contextValue = useMemo<ThemeContextValue>(() => ({
    theme,
    colors,
    setTheme: handleSetTheme,
    toggleTheme
  }), [theme, colors, handleSetTheme, toggleTheme]);

  return (
    <ThemeContext.Provider value={contextValue}>
      {children}
    </ThemeContext.Provider>
  );
};

/**
 * Custom hook to use theme context
 * Throws error if used outside provider
 */
export const useTheme = (): ThemeContextValue => {
  const context = useContext(ThemeContext);
  
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  
  return context;
};

// ============================================
// AUTHENTICATION CONTEXT with split contexts
// ============================================

// AuthContext.tsx

interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
  avatar: string;
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

interface AuthActions {
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateProfile: (updates: Partial<User>) => void;
}

/**
 * OPTIMIZATION: Split state and actions into separate contexts
 * Prevents re-renders when only actions are used
 */
const AuthStateContext = createContext<AuthState | undefined>(undefined);
const AuthActionsContext = createContext<AuthActions | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Check authentication status on mount
  React.useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('auth_token');
      if (token) {
        try {
          const response = await fetch('/api/auth/me', {
            headers: { Authorization: `Bearer ${token}` }
          });
          if (response.ok) {
            const userData = await response.json();
            setUser(userData);
          }
        } catch (error) {
          console.error('Auth check failed:', error);
        }
      }
      setIsLoading(false);
    };
    
    checkAuth();
  }, []);

  /**
   * Login function
   */
  const login = useCallback(async (email: string, password: string) => {
    try {
      setIsLoading(true);
      
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      
      if (!response.ok) {
        throw new Error('Login failed');
      }
      
      const { user, token } = await response.json();
      
      // Save token
      localStorage.setItem('auth_token', token);
      
      // Update user state
      setUser(user);
      
      console.log('✓ Logged in:', user.email);
    } catch (error) {
      console.error('✗ Login error:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  }, []);

  /**
   * Logout function
   */
  const logout = useCallback(() => {
    localStorage.removeItem('auth_token');
    setUser(null);
    console.log('✓ Logged out');
  }, []);

  /**
   * Update profile
   */
  const updateProfile = useCallback((updates: Partial<User>) => {
    setUser(prev => prev ? { ...prev, ...updates } : null);
  }, []);

  // Memoize state context value
  const stateValue = useMemo<AuthState>(() => ({
    user,
    isAuthenticated: user !== null,
    isLoading
  }), [user, isLoading]);

  // Memoize actions context value
  const actionsValue = useMemo<AuthActions>(() => ({
    login,
    logout,
    updateProfile
  }), [login, logout, updateProfile]);

  return (
    <AuthStateContext.Provider value={stateValue}>
      <AuthActionsContext.Provider value={actionsValue}>
        {children}
      </AuthActionsContext.Provider>
    </AuthStateContext.Provider>
  );
};

/**
 * Hook to access auth state
 * Components using this will re-render when user changes
 */
export const useAuthState = (): AuthState => {
  const context = useContext(AuthStateContext);
  if (context === undefined) {
    throw new Error('useAuthState must be used within AuthProvider');
  }
  return context;
};

/**
 * Hook to access auth actions
 * Components using this will NOT re-render when user changes
 */
export const useAuthActions = (): AuthActions => {
  const context = useContext(AuthActionsContext);
  if (context === undefined) {
    throw new Error('useAuthActions must be used within AuthProvider');
  }
  return context;
};

// ============================================
// USAGE EXAMPLES
// ============================================

// App.tsx
export const App: React.FC = () => {
  return (
    <ThemeProvider>
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </ThemeProvider>
  );
};

// Header component - uses auth state
const Header: React.FC = () => {
  const { user, isAuthenticated } = useAuthState();
  const { logout } = useAuthActions();
  const { theme, toggleTheme } = useTheme();
  
  console.log('Header rendered'); // Only re-renders when user changes
  
  return (
    <header>
      <h1>My App</h1>
      
      {isAuthenticated && (
        <div className="user-menu">
          <img src={user!.avatar} alt={user!.name} />
          <span>{user!.name}</span>
          <button onClick={logout}>Logout</button>
        </div>
      )}
      
      <button onClick={toggleTheme}>
        Theme: {theme}
      </button>
    </header>
  );
};

// Login button - only uses actions
const LoginButton: React.FC = () => {
  const { login } = useAuthActions(); // Doesn't cause re-renders!
  
  console.log('LoginButton rendered'); // Only renders once
  
  const handleLogin = async () => {
    try {
      await login('user@example.com', 'password');
    } catch (error) {
      alert('Login failed');
    }
  };
  
  return <button onClick={handleLogin}>Login</button>;
};

// Themed component
const ThemedCard: React.FC<{ children: ReactNode }> = ({ children }) => {
  const { colors } = useTheme();
  
  return (
    <div
      style={{
        backgroundColor: colors.background,
        color: colors.text,
        border: `1px solid ${colors.border}`,
        padding: '20px',
        borderRadius: '8px'
      }}>
      {children}
    </div>
  );
};
```

**Context Best Practices:**
1. ✅ Split state and actions into separate contexts
2. ✅ Memoize context values with useMemo
3. ✅ Memoize callbacks with useCallback
4. ✅ Create custom hooks for context access
5. ✅ Throw errors if used outside provider
6. ✅ Use TypeScript for type safety
7. ✅ Keep context focused (single responsibility)

---

## Custom Hooks

### Q5: Create reusable custom hooks (Asked at: Stripe, Salesforce)

**Question:** Build custom hooks for common patterns: data fetching with cache, form handling, and debounced input.

**Implementation:**

```typescript
// ============================================
// CUSTOM HOOK: useFetch with caching
// ============================================

// useFetch.ts
import { useState, useEffect, useRef, useCallback } from 'react';

interface UseFetchOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE';
  body?: any;
  headers?: Record<string, string>;
  enabled?: boolean; // Conditional fetching
  cacheTime?: number; // Cache duration in ms
  retry?: number; // Number of retries
}

interface UseFetchResult<T> {
  data: T | null;
  error: Error | null;
  loading: boolean;
  refetch: () => void;
}

// Simple in-memory cache
const fetchCache = new Map<string, { data: any; timestamp: number }>();

/**
 * Custom hook for data fetching with caching and retry
 */
export function useFetch<T>(
  url: string | null,
  options: UseFetchOptions = {}
): UseFetchResult<T> {
  const {
    method = 'GET',
    body,
    headers,
    enabled = true,
    cacheTime = 5 * 60 * 1000, // 5 minutes default
    retry = 0
  } = options;

  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(false);
  const [refetchTrigger, setRefetchTrigger] = useState(0);
  
  // AbortController ref for cleanup
  const abortControllerRef = useRef<AbortController | null>(null);

  /**
   * Refetch function
   */
  const refetch = useCallback(() => {
    setRefetchTrigger(prev => prev + 1);
  }, []);

  useEffect(() => {
    // Skip if URL is null or fetching is disabled
    if (!url || !enabled) {
      return;
    }

    // Cleanup flag
    let isCancelled = false;

    const fetchData = async (attemptNumber: number = 0) => {
      try {
        // Check cache first
        const cacheKey = `${method}:${url}:${JSON.stringify(body)}`;
        const cached = fetchCache.get(cacheKey);
        
        if (cached && Date.now() - cached.timestamp < cacheTime) {
          console.log(`✓ Cache hit: ${url}`);
          if (!isCancelled) {
            setData(cached.data);
            setLoading(false);
          }
          return;
        }

        // Create new AbortController for this request
        abortControllerRef.current = new AbortController();
        
        setLoading(true);
        setError(null);
        
        console.log(`Fetching: ${url} (attempt ${attemptNumber + 1})`);
        
        const response = await fetch(url, {
          method,
          headers: {
            'Content-Type': 'application/json',
            ...headers
          },
          body: body ? JSON.stringify(body) : undefined,
          signal: abortControllerRef.current.signal
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const result = await response.json();

        if (!isCancelled) {
          setData(result);
          setLoading(false);
          
          // Update cache
          fetchCache.set(cacheKey, {
            data: result,
            timestamp: Date.now()
          });
          
          console.log(`✓ Fetched: ${url}`);
        }
      } catch (err: any) {
        if (err.name === 'AbortError') {
          console.log(`✗ Fetch aborted: ${url}`);
          return;
        }

        // Retry logic
        if (attemptNumber < retry) {
          console.log(`Retrying... (${attemptNumber + 1}/${retry})`);
          setTimeout(() => fetchData(attemptNumber + 1), 1000 * Math.pow(2, attemptNumber));
          return;
        }

        if (!isCancelled) {
          setError(err);
          setLoading(false);
          console.error(`✗ Fetch error: ${url}`, err);
        }
      }
    };

    fetchData();

    // Cleanup
    return () => {
      isCancelled = true;
      abortControllerRef.current?.abort();
    };
  }, [url, method, body, headers, enabled, cacheTime, retry, refetchTrigger]);

  return { data, error, loading, refetch };
}

// ============================================
// CUSTOM HOOK: useDebounce
// ============================================

/**
 * Debounce a value - delays updating until user stops typing
 */
export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    // Set timeout to update debounced value
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    // Cleanup: cancel timeout if value changes
    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

// ============================================
// CUSTOM HOOK: useForm
// ============================================

interface UseFormOptions<T> {
  initialValues: T;
  validate?: (values: T) => Partial<Record<keyof T, string>>;
  onSubmit: (values: T) => void | Promise<void>;
}

interface UseFormReturn<T> {
  values: T;
  errors: Partial<Record<keyof T, string>>;
  touched: Partial<Record<keyof T, boolean>>;
  handleChange: (field: keyof T) => (e: React.ChangeEvent<HTMLInputElement>) => void;
  handleBlur: (field: keyof T) => () => void;
  handleSubmit: (e: React.FormEvent) => void;
  setFieldValue: (field: keyof T, value: any) => void;
  resetForm: () => void;
  isSubmitting: boolean;
}

/**
 * Custom hook for form handling
 */
export function useForm<T extends Record<string, any>>({
  initialValues,
  validate,
  onSubmit
}: UseFormOptions<T>): UseFormReturn<T> {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  /**
   * Handle input change
   */
  const handleChange = useCallback((field: keyof T) => {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      const value = e.target.type === 'checkbox' ? e.target.checked : e.target.value;
      
      setValues(prev => ({
        ...prev,
        [field]: value
      }));
      
      // Clear error when user starts typing
      if (errors[field]) {
        setErrors(prev => ({
          ...prev,
          [field]: undefined
        }));
      }
    };
  }, [errors]);

  /**
   * Handle input blur
   */
  const handleBlur = useCallback((field: keyof T) => {
    return () => {
      setTouched(prev => ({
        ...prev,
        [field]: true
      }));
      
      // Validate field on blur
      if (validate) {
        const fieldErrors = validate(values);
        setErrors(prev => ({
          ...prev,
          [field]: fieldErrors[field]
        }));
      }
    };
  }, [validate, values]);

  /**
   * Set field value programmatically
   */
  const setFieldValue = useCallback((field: keyof T, value: any) => {
    setValues(prev => ({
      ...prev,
      [field]: value
    }));
  }, []);

  /**
   * Handle form submission
   */
  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Mark all fields as touched
    const allTouched = Object.keys(values).reduce((acc, key) => ({
      ...acc,
      [key]: true
    }), {});
    setTouched(allTouched);
    
    // Validate all fields
    if (validate) {
      const formErrors = validate(values);
      setErrors(formErrors);
      
      // Stop if there are errors
      if (Object.keys(formErrors).length > 0) {
        console.log('Form has validation errors', formErrors);
        return;
      }
    }
    
    // Submit
    try {
      setIsSubmitting(true);
      await onSubmit(values);
      console.log('✓ Form submitted successfully');
    } catch (error) {
      console.error('✗ Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  }, [values, validate, onSubmit]);

  /**
   * Reset form to initial values
   */
  const resetForm = useCallback(() => {
    setValues(initialValues);
    setErrors({});
    setTouched({});
    setIsSubmitting(false);
  }, [initialValues]);

  return {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    handleSubmit,
    setFieldValue,
    resetForm,
    isSubmitting
  };
}

// ============================================
// CUSTOM HOOK: useLocalStorage
// ============================================

/**
 * Sync state with localStorage
 */
export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((prev: T) => T)) => void] {
  // Initialize from localStorage or use initial value
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  // Update localStorage when value changes
  const setValue = useCallback((value: T | ((prev: T) => T)) => {
    try {
      // Allow value to be a function (like useState)
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
      
      console.log(`✓ Saved to localStorage: ${key}`);
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  }, [key, storedValue]);

  return [storedValue, setValue];
}

// ============================================
// CUSTOM HOOK: useMediaQuery
// ============================================

/**
 * Listen to CSS media query changes
 */
export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => {
    return window.matchMedia(query).matches;
  });

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);
    
    // Update state
    const handleChange = (e: MediaQueryListEvent) => {
      setMatches(e.matches);
    };
    
    // Listen for changes
    mediaQuery.addEventListener('change', handleChange);
    
    // Cleanup
    return () => {
      mediaQuery.removeEventListener('change', handleChange);
    };
  }, [query]);

  return matches;
}

// ============================================
// USAGE EXAMPLES
// ============================================

// Example 1: Search with debounce and fetch
const SearchComponent: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearchTerm = useDebounce(searchTerm, 500);
  
  const { data, loading, error } = useFetch<{ results: any[] }>(
    debouncedSearchTerm ? `/api/search?q=${debouncedSearchTerm}` : null,
    {
      enabled: debouncedSearchTerm.length >= 3,
      cacheTime: 2 * 60 * 1000 // 2 minutes
    }
  );

  return (
    <div>
      <input
        type="text"
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        placeholder="Search..."
      />
      
      {loading && <div>Searching...</div>}
      {error && <div>Error: {error.message}</div>}
      {data && (
        <ul>
          {data.results.map((item, i) => (
            <li key={i}>{item.name}</li>
          ))}
        </ul>
      )}
    </div>
  );
};

// Example 2: Login form
interface LoginFormValues {
  email: string;
  password: string;
  rememberMe: boolean;
}

const LoginForm: React.FC = () => {
  const form = useForm<LoginFormValues>({
    initialValues: {
      email: '',
      password: '',
      rememberMe: false
    },
    validate: (values) => {
      const errors: Partial<Record<keyof LoginFormValues, string>> = {};
      
      if (!values.email) {
        errors.email = 'Email is required';
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(values.email)) {
        errors.email = 'Invalid email address';
      }
      
      if (!values.password) {
        errors.password = 'Password is required';
      } else if (values.password.length < 8) {
        errors.password = 'Password must be at least 8 characters';
      }
      
      return errors;
    },
    onSubmit: async (values) => {
      console.log('Logging in...', values);
      await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate API call
      alert('Login successful!');
    }
  });

  return (
    <form onSubmit={form.handleSubmit}>
      <div>
        <input
          type="email"
          value={form.values.email}
          onChange={form.handleChange('email')}
          onBlur={form.handleBlur('email')}
          placeholder="Email"
        />
        {form.touched.email && form.errors.email && (
          <span className="error">{form.errors.email}</span>
        )}
      </div>
      
      <div>
        <input
          type="password"
          value={form.values.password}
          onChange={form.handleChange('password')}
          onBlur={form.handleBlur('password')}
          placeholder="Password"
        />
        {form.touched.password && form.errors.password && (
          <span className="error">{form.errors.password}</span>
        )}
      </div>
      
      <div>
        <label>
          <input
            type="checkbox"
            checked={form.values.rememberMe}
            onChange={form.handleChange('rememberMe')}
          />
          Remember me
        </label>
      </div>
      
      <button type="submit" disabled={form.isSubmitting}>
        {form.isSubmitting ? 'Logging in...' : 'Login'}
      </button>
    </form>
  );
};

// Example 3: Responsive component
const ResponsiveComponent: React.FC = () => {
  const isMobile = useMediaQuery('(max-width: 768px)');
  const isTablet = useMediaQuery('(min-width: 769px) and (max-width: 1024px)');
  const isDesktop = useMediaQuery('(min-width: 1025px)');

  return (
    <div>
      {isMobile && <div>Mobile Layout</div>}
      {isTablet && <div>Tablet Layout</div>}
      {isDesktop && <div>Desktop Layout</div>}
    </div>
  );
};

// Example 4: Settings with localStorage
const SettingsComponent: React.FC = () => {
  const [settings, setSettings] = useLocalStorage('app-settings', {
    notifications: true,
    theme: 'light',
    language: 'en'
  });

  return (
    <div>
      <label>
        <input
          type="checkbox"
          checked={settings.notifications}
          onChange={(e) => setSettings({ ...settings, notifications: e.target.checked })}
        />
        Enable notifications
      </label>
      
      <select
        value={settings.theme}
        onChange={(e) => setSettings({ ...settings, theme: e.target.value })}>
        <option value="light">Light</option>
        <option value="dark">Dark</option>
      </select>
    </div>
  );
};
```

**Custom Hooks Best Practices:**
1. ✅ Start with "use" prefix
2. ✅ Follow hooks rules (don't call conditionally)
3. ✅ Return arrays for simple values, objects for complex state
4. ✅ Memoize callbacks with useCallback
5. ✅ Clean up side effects properly
6. ✅ Add TypeScript for type safety
7. ✅ Make hooks reusable and composable

---

## Server-Side Rendering (Next.js)

### Q6: Implement SSR, SSG, and ISR in Next.js (Asked at: Vercel, Shopify)

**Question:** Build a blog with different rendering strategies. Show when to use SSR, SSG, and ISR.

**Implementation:**

```typescript
// ============================================
// STATIC SITE GENERATION (SSG)
// ============================================

// pages/blog/[slug].tsx
import { GetStaticProps, GetStaticPaths } from 'next';

interface Post {
  id: string;
  slug: string;
  title: string;
  content: string;
  author: string;
  publishedAt: string;
  tags: string[];
}

interface BlogPostProps {
  post: Post;
}

/**
 * Static Site Generation (SSG)
 * - Builds pages at build time
 * - Best for content that doesn't change often
 * - Fast: served from CDN
 * - Great for SEO
 */
export default function BlogPost({ post }: BlogPostProps) {
  return (
    <article>
      <h1>{post.title}</h1>
      <div className="meta">
        <span>By {post.author}</span>
        <span>{new Date(post.publishedAt).toLocaleDateString()}</span>
      </div>
      
      <div className="tags">
        {post.tags.map(tag => (
          <span key={tag} className="tag">{tag}</span>
        ))}
      </div>
      
      <div className="content" dangerouslySetInnerHTML={{ __html: post.content }} />
    </article>
  );
}

/**
 * getStaticPaths: Generate paths at build time
 * Runs at build time in production
 */
export const getStaticPaths: GetStaticPaths = async () => {
  // Fetch all blog posts
  const response = await fetch('https://api.example.com/posts');
  const posts: Post[] = await response.json();
  
  // Generate paths for all posts
  const paths = posts.map(post => ({
    params: { slug: post.slug }
  }));
  
  console.log(`Generated ${paths.length} static paths`);
  
  return {
    paths,
    fallback: 'blocking' // 'blocking' | false | true
    // false: 404 for paths not returned
    // true: serve fallback, generate in background
    // 'blocking': wait for generation (recommended)
  };
};

/**
 * getStaticProps: Fetch data at build time
 * Runs at build time in production
 */
export const getStaticProps: GetStaticProps<BlogPostProps> = async ({ params }) => {
  const slug = params?.slug as string;
  
  try {
    // Fetch post data
    const response = await fetch(`https://api.example.com/posts/${slug}`);
    
    if (!response.ok) {
      return { notFound: true };
    }
    
    const post: Post = await response.json();
    
    console.log(`Generated static page for: ${slug}`);
    
    return {
      props: { post },
      revalidate: 60 // Incremental Static Regeneration (ISR): revalidate every 60 seconds
    };
  } catch (error) {
    console.error(`Error generating page for ${slug}:`, error);
    return { notFound: true };
  }
};

// ============================================
// SERVER-SIDE RENDERING (SSR)
// ============================================

// pages/dashboard.tsx
import { GetServerSideProps } from 'next';

interface DashboardProps {
  user: {
    id: string;
    name: string;
    email: string;
  };
  stats: {
    views: number;
    likes: number;
    comments: number;
  };
  recentActivity: Array<{
    id: string;
    type: string;
    message: string;
    timestamp: string;
  }>;
}

/**
 * Server-Side Rendering (SSR)
 * - Renders on every request
 * - Best for personalized, frequently changing data
 * - Slower than SSG (runs on each request)
 * - Good for SEO with dynamic content
 */
export default function Dashboard({ user, stats, recentActivity }: DashboardProps) {
  return (
    <div className="dashboard">
      <h1>Welcome, {user.name}!</h1>
      
      <div className="stats-grid">
        <div className="stat-card">
          <h3>Views</h3>
          <p>{stats.views.toLocaleString()}</p>
        </div>
        <div className="stat-card">
          <h3>Likes</h3>
          <p>{stats.likes.toLocaleString()}</p>
        </div>
        <div className="stat-card">
          <h3>Comments</h3>
          <p>{stats.comments.toLocaleString()}</p>
        </div>
      </div>
      
      <div className="recent-activity">
        <h2>Recent Activity</h2>
        {recentActivity.map(activity => (
          <div key={activity.id} className="activity-item">
            <span className="type">{activity.type}</span>
            <span className="message">{activity.message}</span>
            <span className="time">{new Date(activity.timestamp).toLocaleString()}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

/**
 * getServerSideProps: Fetch data on every request
 * Runs on every request
 */
export const getServerSideProps: GetServerSideProps<DashboardProps> = async ({ req, res }) => {
  // Get user from session/cookie
  const token = req.cookies.auth_token;
  
  if (!token) {
    // Redirect to login if not authenticated
    return {
      redirect: {
        destination: '/login',
        permanent: false
      }
    };
  }
  
  try {
    // Fetch user data
    const userResponse = await fetch('https://api.example.com/user', {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    if (!userResponse.ok) {
      throw new Error('Failed to fetch user');
    }
    
    const user = await userResponse.json();
    
    // Fetch stats and activity in parallel
    const [statsResponse, activityResponse] = await Promise.all([
      fetch(`https://api.example.com/stats/${user.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      }),
      fetch(`https://api.example.com/activity/${user.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      })
    ]);
    
    const stats = await statsResponse.json();
    const recentActivity = await activityResponse.json();
    
    // Set cache headers (optional)
    res.setHeader(
      'Cache-Control',
      'private, s-maxage=10, stale-while-revalidate=59'
    );
    
    console.log(`SSR: Generated dashboard for user ${user.id}`);
    
    return {
      props: {
        user,
        stats,
        recentActivity
      }
    };
  } catch (error) {
    console.error('SSR Error:', error);
    
    // Return error page or redirect
    return {
      redirect: {
        destination: '/error',
        permanent: false
      }
    };
  }
};

// ============================================
// INCREMENTAL STATIC REGENERATION (ISR)
// ============================================

// pages/products/[id].tsx
import { GetStaticProps, GetStaticPaths } from 'next';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  image: string;
  stock: number;
}

interface ProductPageProps {
  product: Product;
  generatedAt: string;
}

/**
 * Incremental Static Regeneration (ISR)
 * - Static generation with automatic revalidation
 * - Best of both worlds: fast + fresh
 * - Regenerates in background when stale
 */
export default function ProductPage({ product, generatedAt }: ProductPageProps) {
  return (
    <div className="product-page">
      <img src={product.image} alt={product.name} />
      
      <div className="product-info">
        <h1>{product.name}</h1>
        <p className="price">${product.price.toFixed(2)}</p>
        <p className="stock">
          {product.stock > 0 ? `${product.stock} in stock` : 'Out of stock'}
        </p>
        <p className="description">{product.description}</p>
        
        <button disabled={product.stock === 0}>
          {product.stock > 0 ? 'Add to Cart' : 'Out of Stock'}
        </button>
      </div>
      
      {/* Debug info */}
      <small>Page generated at: {generatedAt}</small>
    </div>
  );
}

export const getStaticPaths: GetStaticPaths = async () => {
  // Only pre-generate popular products
  const response = await fetch('https://api.example.com/products/popular?limit=100');
  const products: Product[] = await response.json();
  
  const paths = products.map(product => ({
    params: { id: product.id }
  }));
  
  return {
    paths,
    fallback: 'blocking' // Generate less popular products on-demand
  };
};

export const getStaticProps: GetStaticProps<ProductPageProps> = async ({ params }) => {
  const id = params?.id as string;
  
  try {
    const response = await fetch(`https://api.example.com/products/${id}`);
    
    if (!response.ok) {
      return { notFound: true };
    }
    
    const product: Product = await response.json();
    
    return {
      props: {
        product,
        generatedAt: new Date().toISOString()
      },
      revalidate: 30 // Revalidate every 30 seconds
      // How ISR works:
      // 1. First request serves stale page
      // 2. Triggers regeneration in background
      // 3. Next request gets fresh page
      // 4. CDN cache is updated
    };
  } catch (error) {
    return { notFound: true };
  }
};

// ============================================
// CLIENT-SIDE RENDERING (CSR)
// ============================================

// pages/feed.tsx
import { useState, useEffect } from 'react';

interface Post {
  id: string;
  content: string;
  author: string;
  likes: number;
}

/**
 * Client-Side Rendering (CSR)
 * - Renders in browser
 * - Best for highly interactive, real-time data
 * - No SEO (unless using dynamic rendering)
 * - Faster initial load, slower content display
 */
export default function Feed() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    // Fetch posts on client side
    fetch('/api/feed')
      .then(res => res.json())
      .then(data => {
        setPosts(data);
        setLoading(false);
      });
  }, []);
  
  if (loading) {
    return <div>Loading feed...</div>;
  }
  
  return (
    <div className="feed">
      {posts.map(post => (
        <div key={post.id} className="post">
          <p>{post.content}</p>
          <span>By {post.author} · {post.likes} likes</span>
        </div>
      ))}
    </div>
  );
}
```

**Rendering Strategy Comparison:**

| Strategy | When to Use | Pros | Cons |
|----------|------------|------|------|
| **SSG** | Blogs, documentation, marketing pages | ⚡ Fastest, 🎯 Best SEO, 💰 Cheap hosting | ❌ Requires rebuild for updates |
| **ISR** | E-commerce, news, content sites | ⚡ Fast, 🎯 Good SEO, 🔄 Auto-updates | ⚠️ Complexity, possible stale data |
| **SSR** | Dashboards, personalized content | 🎯 Best SEO, ✅ Always fresh | 🐌 Slower, 💰 More expensive |
| **CSR** | Admin panels, real-time apps | ⚡ Fast initial load, 💪 Interactive | ❌ No SEO, slower content display |

---

## Testing

### Q7: Write comprehensive tests with Jest and React Testing Library (Asked at: Google, Airbnb)

**Question:** Test a complex component with user interactions, async operations, and error handling.

**Implementation:**

```typescript
// ============================================
// COMPONENT TO TEST
// ============================================

// UserList.tsx
import React, { useState, useEffect } from 'react';

interface User {
  id: number;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

interface UserListProps {
  onUserSelect?: (user: User) => void;
}

export const UserList: React.FC<UserListProps> = ({ onUserSelect }) => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | 'admin' | 'user'>('all');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch('/api/users');
      
      if (!response.ok) {
        throw new Error('Failed to load users');
      }
      
      const data = await response.json();
      setUsers(data);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const deleteUser = async (userId: number) => {
    if (!window.confirm('Are you sure?')) {
      return;
    }
    
    try {
      const response = await fetch(`/api/users/${userId}`, {
        method: 'DELETE'
      });
      
      if (!response.ok) {
        throw new Error('Failed to delete user');
      }
      
      setUsers(users.filter(u => u.id !== userId));
    } catch (err: any) {
      setError(err.message);
    }
  };

  const filteredUsers = users
    .filter(user => filter === 'all' || user.role === filter)
    .filter(user => user.name.toLowerCase().includes(searchQuery.toLowerCase()));

  if (loading) {
    return <div>Loading users...</div>;
  }

  if (error) {
    return (
      <div>
        <div className="error">Error: {error}</div>
        <button onClick={loadUsers}>Retry</button>
      </div>
    );
  }

  return (
    <div className="user-list">
      <div className="controls">
        <input
          type="text"
          placeholder="Search users..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          aria-label="Search users"
        />
        
        <select
          value={filter}
          onChange={(e) => setFilter(e.target.value as any)}
          aria-label="Filter by role">
          <option value="all">All Users</option>
          <option value="admin">Admins</option>
          <option value="user">Users</option>
        </select>
      </div>
      
      {filteredUsers.length === 0 ? (
        <div className="empty">No users found</div>
      ) : (
        <ul>
          {filteredUsers.map(user => (
            <li key={user.id} className="user-item">
              <div className="user-info">
                <strong>{user.name}</strong>
                <span>{user.email}</span>
                <span className="role">{user.role}</span>
              </div>
              
              <div className="actions">
                <button onClick={() => onUserSelect?.(user)}>View</button>
                <button onClick={() => deleteUser(user.id)}>Delete</button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

// ============================================
// COMPREHENSIVE TESTS
// ============================================

// UserList.test.tsx
import { render, screen, waitFor, fireEvent, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserList } from './UserList';

// Mock fetch globally
global.fetch = jest.fn();

// Mock data
const mockUsers: User[] = [
  { id: 1, name: 'John Doe', email: 'john@example.com', role: 'admin' },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'user' },
  { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'user' },
  { id: 4, name: 'Alice Brown', email: 'alice@example.com', role: 'admin' }
];

/**
 * Helper to create mock fetch response
 */
const mockFetchSuccess = (data: any) => {
  (global.fetch as jest.Mock).mockResolvedValueOnce({
    ok: true,
    json: async () => data
  });
};

const mockFetchError = (message: string = 'Failed to fetch') => {
  (global.fetch as jest.Mock).mockRejectedValueOnce(new Error(message));
};

describe('UserList Component', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
    
    // Mock window.confirm
    window.confirm = jest.fn(() => true);
  });

  /**
   * TEST GROUP: Initial Rendering
   */
  describe('Initial Rendering', () => {
    test('should show loading state initially', () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      // Check for loading indicator
      expect(screen.getByText(/loading users/i)).toBeInTheDocument();
    });

    test('should display users after successful fetch', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      // Wait for users to load
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Check all users are displayed
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
      expect(screen.getByText('Bob Johnson')).toBeInTheDocument();
      expect(screen.getByText('Alice Brown')).toBeInTheDocument();
    });

    test('should call fetch with correct URL', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(global.fetch).toHaveBeenCalledWith('/api/users');
        expect(global.fetch).toHaveBeenCalledTimes(1);
      });
    });
  });

  /**
   * TEST GROUP: Error Handling
   */
  describe('Error Handling', () => {
    test('should display error message when fetch fails', async () => {
      mockFetchError('Network error');
      
      render(<UserList />);
      
      // Wait for error to appear
      await waitFor(() => {
        expect(screen.getByText(/error: network error/i)).toBeInTheDocument();
      });
      
      // Check retry button exists
      expect(screen.getByRole('button', { name: /retry/i })).toBeInTheDocument();
    });

    test('should retry loading users when retry button is clicked', async () => {
      // First call fails
      mockFetchError('Network error');
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText(/error/i)).toBeInTheDocument();
      });
      
      // Second call succeeds
      mockFetchSuccess(mockUsers);
      
      // Click retry button
      const retryButton = screen.getByRole('button', { name: /retry/i });
      fireEvent.click(retryButton);
      
      // Check users are loaded
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
    });
  });

  /**
   * TEST GROUP: Search Functionality
   */
  describe('Search Functionality', () => {
    test('should filter users by search query', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      // Wait for users to load
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Get search input
      const searchInput = screen.getByLabelText(/search users/i);
      
      // Type search query
      await userEvent.type(searchInput, 'john');
      
      // Check filtered results
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Bob Johnson')).toBeInTheDocument();
      expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument();
      expect(screen.queryByText('Alice Brown')).not.toBeInTheDocument();
    });

    test('should show "No users found" when search has no matches', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      const searchInput = screen.getByLabelText(/search users/i);
      await userEvent.type(searchInput, 'nonexistent');
      
      expect(screen.getByText(/no users found/i)).toBeInTheDocument();
    });

    test('should clear search and show all users', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      const searchInput = screen.getByLabelText(/search users/i);
      
      // Search
      await userEvent.type(searchInput, 'john');
      expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument();
      
      // Clear search
      await userEvent.clear(searchInput);
      
      // All users should be visible
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    });
  });

  /**
   * TEST GROUP: Filter Functionality
   */
  describe('Filter Functionality', () => {
    test('should filter users by role', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Get filter dropdown
      const filterSelect = screen.getByLabelText(/filter by role/i);
      
      // Filter by admin
      await userEvent.selectOptions(filterSelect, 'admin');
      
      // Check only admins are shown
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Alice Brown')).toBeInTheDocument();
      expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument();
      expect(screen.queryByText('Bob Johnson')).not.toBeInTheDocument();
    });

    test('should filter users by user role', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      const filterSelect = screen.getByLabelText(/filter by role/i);
      await userEvent.selectOptions(filterSelect, 'user');
      
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
      expect(screen.getByText('Bob Johnson')).toBeInTheDocument();
      expect(screen.queryByText('John Doe')).not.toBeInTheDocument();
      expect(screen.queryByText('Alice Brown')).not.toBeInTheDocument();
    });

    test('should combine search and filter', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Search for "john"
      const searchInput = screen.getByLabelText(/search users/i);
      await userEvent.type(searchInput, 'john');
      
      // Filter by user role
      const filterSelect = screen.getByLabelText(/filter by role/i);
      await userEvent.selectOptions(filterSelect, 'user');
      
      // Only Bob Johnson matches both criteria
      expect(screen.getByText('Bob Johnson')).toBeInTheDocument();
      expect(screen.queryByText('John Doe')).not.toBeInTheDocument(); // admin
      expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument(); // doesn't match search
    });
  });

  /**
   * TEST GROUP: User Interactions
   */
  describe('User Interactions', () => {
    test('should call onUserSelect when View button is clicked', async () => {
      mockFetchSuccess(mockUsers);
      
      const handleUserSelect = jest.fn();
      render(<UserList onUserSelect={handleUserSelect} />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Find View button for John Doe
      const userItem = screen.getByText('John Doe').closest('li');
      const viewButton = within(userItem!).getByRole('button', { name: /view/i });
      
      fireEvent.click(viewButton);
      
      // Check callback was called with correct user
      expect(handleUserSelect).toHaveBeenCalledWith(mockUsers[0]);
      expect(handleUserSelect).toHaveBeenCalledTimes(1);
    });

    test('should delete user when Delete button is clicked', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Mock delete request
      (global.fetch as jest.Mock).mockResolvedValueOnce({
        ok: true,
        json: async () => ({})
      });
      
      // Find Delete button for Jane Smith
      const userItem = screen.getByText('Jane Smith').closest('li');
      const deleteButton = within(userItem!).getByRole('button', { name: /delete/i });
      
      fireEvent.click(deleteButton);
      
      // Wait for deletion
      await waitFor(() => {
        expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument();
      });
      
      // Check delete API was called
      expect(global.fetch).toHaveBeenCalledWith('/api/users/2', {
        method: 'DELETE'
      });
    });

    test('should not delete user when confirmation is cancelled', async () => {
      mockFetchSuccess(mockUsers);
      
      // Mock confirm to return false
      window.confirm = jest.fn(() => false);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      const userItem = screen.getByText('John Doe').closest('li');
      const deleteButton = within(userItem!).getByRole('button', { name: /delete/i });
      
      fireEvent.click(deleteButton);
      
      // User should still be in the list
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      
      // Delete API should not be called
      expect(global.fetch).toHaveBeenCalledTimes(1); // Only initial fetch
    });

    test('should show error when delete fails', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Mock failed delete
      (global.fetch as jest.Mock).mockRejectedValueOnce(new Error('Delete failed'));
      
      const userItem = screen.getByText('John Doe').closest('li');
      const deleteButton = within(userItem!).getByRole('button', { name: /delete/i });
      
      fireEvent.click(deleteButton);
      
      // Check error is displayed
      await waitFor(() => {
        expect(screen.getByText(/error: delete failed/i)).toBeInTheDocument();
      });
      
      // User should still be in the list
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });
  });

  /**
   * TEST GROUP: Accessibility
   */
  describe('Accessibility', () => {
    test('should have proper ARIA labels', async () => {
      mockFetchSuccess(mockUsers);
      
      render(<UserList />);
      
      await waitFor(() => {
        expect(screen.getByText('John Doe')).toBeInTheDocument();
      });
      
      // Check ARIA labels
      expect(screen.getByLabelText(/search users/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/filter by role/i)).toBeInTheDocument();
    });
  });
});
```

**Testing Best Practices:**
1. ✅ Test user interactions, not implementation
2. ✅ Use `screen` queries (getByRole, getByLabelText)
3. ✅ Wait for async operations with `waitFor`
4. ✅ Mock external dependencies (fetch, localStorage)
5. ✅ Test error states and edge cases
6. ✅ Group related tests with `describe`
7. ✅ Use `userEvent` for realistic interactions
8. ✅ Test accessibility (ARIA labels, keyboard navigation)

---

## Advanced Patterns

### Q8: Implement compound components and render props (Asked at: Meta, LinkedIn)

**Question:** Build a flexible Tab component using compound components pattern and a DataTable with render props.

**Implementation:**

```typescript
// ============================================
// COMPOUND COMPONENTS PATTERN
// ============================================

// Tabs.tsx
import React, { createContext, useContext, useState, ReactNode, ReactElement } from 'react';

/**
 * COMPOUND COMPONENTS PATTERN
 * - Parent component manages state
 * - Child components receive state via context
 * - Flexible composition
 * - Intuitive API
 */

// Context for sharing tab state
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextValue | undefined>(undefined);

const useTabs = () => {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('Tabs compound components must be used within Tabs');
  }
  return context;
};

// ============================================
// MAIN TABS COMPONENT
// ============================================

interface TabsProps {
  children: ReactNode;
  defaultTab?: string;
  onChange?: (tab: string) => void;
}

export const Tabs: React.FC<TabsProps> & {
  List: typeof TabList;
  Tab: typeof Tab;
  Panels: typeof TabPanels;
  Panel: typeof TabPanel;
} = ({ children, defaultTab, onChange }) => {
  const [activeTab, setActiveTab] = useState(defaultTab || '');

  const handleTabChange = (tab: string) => {
    setActiveTab(tab);
    onChange?.(tab);
  };

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab: handleTabChange }}>
      <div className="tabs-container">{children}</div>
    </TabsContext.Provider>
  );
};

// ============================================
// TAB LIST (Container for tabs)
// ============================================

interface TabListProps {
  children: ReactNode;
  'aria-label'?: string;
}

const TabList: React.FC<TabListProps> = ({ children, 'aria-label': ariaLabel }) => {
  return (
    <div role="tablist" aria-label={ariaLabel} className="tabs-list">
      {children}
    </div>
  );
};

// ============================================
// INDIVIDUAL TAB
// ============================================

interface TabProps {
  id: string;
  children: ReactNode;
  disabled?: boolean;
}

const Tab: React.FC<TabProps> = ({ id, children, disabled = false }) => {
  const { activeTab, setActiveTab } = useTabs();
  const isActive = activeTab === id;

  return (
    <button
      role="tab"
      aria-selected={isActive}
      aria-controls={`panel-${id}`}
      id={`tab-${id}`}
      onClick={() => !disabled && setActiveTab(id)}
      disabled={disabled}
      className={`tab ${isActive ? 'active' : ''} ${disabled ? 'disabled' : ''}`}>
      {children}
    </button>
  );
};

// ============================================
// TAB PANELS CONTAINER
// ============================================

interface TabPanelsProps {
  children: ReactNode;
}

const TabPanels: React.FC<TabPanelsProps> = ({ children }) => {
  return <div className="tab-panels">{children}</div>;
};

// ============================================
// INDIVIDUAL TAB PANEL
// ============================================

interface TabPanelProps {
  id: string;
  children: ReactNode;
}

const TabPanel: React.FC<TabPanelProps> = ({ id, children }) => {
  const { activeTab } = useTabs();
  const isActive = activeTab === id;

  if (!isActive) return null;

  return (
    <div
      role="tabpanel"
      id={`panel-${id}`}
      aria-labelledby={`tab-${id}`}
      className="tab-panel">
      {children}
    </div>
  );
};

// Attach compound components
Tabs.List = TabList;
Tabs.Tab = Tab;
Tabs.Panels = TabPanels;
Tabs.Panel = TabPanel;

// ============================================
// USAGE EXAMPLE
// ============================================

export const TabsExample: React.FC = () => {
  return (
    <Tabs defaultTab="profile" onChange={(tab) => console.log('Active tab:', tab)}>
      <Tabs.List aria-label="User settings">
        <Tabs.Tab id="profile">Profile</Tabs.Tab>
        <Tabs.Tab id="account">Account</Tabs.Tab>
        <Tabs.Tab id="security">Security</Tabs.Tab>
        <Tabs.Tab id="billing" disabled>Billing (Coming Soon)</Tabs.Tab>
      </Tabs.List>

      <Tabs.Panels>
        <Tabs.Panel id="profile">
          <h2>Profile Settings</h2>
          <form>
            <input type="text" placeholder="Name" />
            <textarea placeholder="Bio" />
            <button>Save</button>
          </form>
        </Tabs.Panel>

        <Tabs.Panel id="account">
          <h2>Account Settings</h2>
          <div>
            <label>Email: user@example.com</label>
            <button>Change Email</button>
          </div>
        </Tabs.Panel>

        <Tabs.Panel id="security">
          <h2>Security Settings</h2>
          <div>
            <button>Change Password</button>
            <button>Enable 2FA</button>
          </div>
        </Tabs.Panel>
      </Tabs.Panels>
    </Tabs>
  );
};

// ============================================
// RENDER PROPS PATTERN
// ============================================

// DataTable.tsx

interface Column<T> {
  key: keyof T;
  header: string;
  render?: (value: T[keyof T], item: T) => ReactNode;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  renderRow?: (item: T, index: number) => ReactNode;
  renderEmpty?: () => ReactNode;
  renderLoading?: () => ReactNode;
  renderHeader?: (columns: Column<T>[]) => ReactNode;
  loading?: boolean;
  onRowClick?: (item: T) => void;
}

/**
 * RENDER PROPS PATTERN
 * - Flexible rendering logic
 * - Share component logic
 * - Customizable presentation
 * - Inversion of control
 */
export function DataTable<T extends { id: number | string }>({
  data,
  columns,
  renderRow,
  renderEmpty,
  renderLoading,
  renderHeader,
  loading = false,
  onRowClick
}: DataTableProps<T>) {
  // Loading state
  if (loading) {
    if (renderLoading) {
      return <>{renderLoading()}</>;
    }
    return <div className="table-loading">Loading...</div>;
  }

  // Empty state
  if (data.length === 0) {
    if (renderEmpty) {
      return <>{renderEmpty()}</>;
    }
    return <div className="table-empty">No data available</div>;
  }

  return (
    <table className="data-table">
      {/* Table Header */}
      <thead>
        {renderHeader ? (
          renderHeader(columns)
        ) : (
          <tr>
            {columns.map(column => (
              <th key={String(column.key)}>{column.header}</th>
            ))}
          </tr>
        )}
      </thead>

      {/* Table Body */}
      <tbody>
        {data.map((item, index) => {
          // Custom row rendering
          if (renderRow) {
            return <React.Fragment key={item.id}>{renderRow(item, index)}</React.Fragment>;
          }

          // Default row rendering
          return (
            <tr
              key={item.id}
              onClick={() => onRowClick?.(item)}
              className={onRowClick ? 'clickable' : ''}>
              {columns.map(column => {
                const value = item[column.key];
                
                return (
                  <td key={String(column.key)}>
                    {/* Use custom cell renderer if provided */}
                    {column.render ? column.render(value, item) : String(value)}
                  </td>
                );
              })}
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

// ============================================
// USAGE EXAMPLES
// ============================================

interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  status: 'active' | 'inactive';
  lastLogin: string;
}

export const DataTableExample: React.FC = () => {
  const users: User[] = [
    {
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      role: 'Admin',
      status: 'active',
      lastLogin: '2024-01-30T10:00:00Z'
    },
    {
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      role: 'User',
      status: 'inactive',
      lastLogin: '2024-01-25T15:30:00Z'
    }
  ];

  const columns: Column<User>[] = [
    {
      key: 'name',
      header: 'Name'
    },
    {
      key: 'email',
      header: 'Email',
      render: (email) => <a href={`mailto:${email}`}>{email}</a>
    },
    {
      key: 'role',
      header: 'Role',
      render: (role) => <span className={`badge role-${role.toLowerCase()}`}>{role}</span>
    },
    {
      key: 'status',
      header: 'Status',
      render: (status) => (
        <span className={`status ${status}`}>
          {status === 'active' ? '🟢' : '🔴'} {status}
        </span>
      )
    },
    {
      key: 'lastLogin',
      header: 'Last Login',
      render: (date) => new Date(date).toLocaleDateString()
    }
  ];

  // Example 1: Basic usage
  return (
    <div>
      <h2>Users</h2>
      <DataTable
        data={users}
        columns={columns}
        onRowClick={(user) => console.log('Clicked:', user.name)}
      />
    </div>
  );
};

// Example 2: Custom rendering
export const CustomDataTableExample: React.FC = () => {
  const [loading, setLoading] = useState(true);
  const [users, setUsers] = useState<User[]>([]);

  useEffect(() => {
    setTimeout(() => {
      setUsers([
        /* ... users ... */
      ]);
      setLoading(false);
    }, 2000);
  }, []);

  return (
    <DataTable
      data={users}
      columns={[
        { key: 'name', header: 'Name' },
        { key: 'email', header: 'Email' }
      ]}
      loading={loading}
      // Custom loading renderer
      renderLoading={() => (
        <div className="custom-loading">
          <div className="spinner" />
          <p>Loading users...</p>
        </div>
      )}
      // Custom empty state
      renderEmpty={() => (
        <div className="custom-empty">
          <img src="/empty-state.svg" alt="No users" />
          <h3>No users found</h3>
          <button>Add User</button>
        </div>
      )}
      // Custom header
      renderHeader={(columns) => (
        <tr className="custom-header">
          {columns.map(col => (
            <th key={String(col.key)}>
              {col.header}
              <button className="sort-btn">↕</button>
            </th>
          ))}
          <th>Actions</th>
        </tr>
      )}
      // Custom row
      renderRow={(user, index) => (
        <tr key={user.id} className={index % 2 === 0 ? 'even' : 'odd'}>
          <td>
            <img src={`/avatars/${user.id}.jpg`} alt="" className="avatar" />
            {user.name}
          </td>
          <td>{user.email}</td>
          <td>
            <button>Edit</button>
            <button>Delete</button>
          </td>
        </tr>
      )}
    />
  );
};
```

**Advanced Patterns Summary:**

| Pattern | Use Case | Pros | Cons |
|---------|----------|------|------|
| **Compound Components** | Related components working together | ✅ Flexible API, ✅ Clear relationships | ⚠️ More complex to build |
| **Render Props** | Customizable rendering logic | ✅ Maximum flexibility, ✅ Share logic | ⚠️ Callback hell, less readable |
| **Higher-Order Components** | Cross-cutting concerns | ✅ Reusable logic | ❌ Wrapper hell, props collision |
| **Custom Hooks** | Logic reuse | ✅ Clean, ✅ Composable | ⚠️ Rules of hooks apply |

---

## TypeScript with React

### Q9: Advanced TypeScript patterns with React (Asked at: Microsoft, Amazon)

**Question:** Implement type-safe components with generics, discriminated unions, and utility types.

**Implementation:**

```typescript
// ============================================
// GENERIC COMPONENTS
// ============================================

// Select.tsx
import React, { useState } from 'react';

/**
 * Generic Select component with type safety
 * T: Type of option value
 */
interface Option<T> {
  value: T;
  label: string;
  disabled?: boolean;
}

interface SelectProps<T> {
  options: Option<T>[];
  value: T;
  onChange: (value: T) => void;
  placeholder?: string;
  disabled?: boolean;
  renderOption?: (option: Option<T>) => React.ReactNode;
}

export function Select<T extends string | number>({
  options,
  value,
  onChange,
  placeholder = 'Select...',
  disabled = false,
  renderOption
}: SelectProps<T>) {
  const selectedOption = options.find(opt => opt.value === value);

  return (
    <select
      value={String(value)}
      onChange={(e) => {
        const selectedValue = options.find(
          opt => String(opt.value) === e.target.value
        )?.value;
        if (selectedValue !== undefined) {
          onChange(selectedValue);
        }
      }}
      disabled={disabled}>
      {placeholder && <option value="">{placeholder}</option>}
      
      {options.map(option => (
        <option
          key={String(option.value)}
          value={String(option.value)}
          disabled={option.disabled}>
          {renderOption ? renderOption(option) : option.label}
        </option>
      ))}
    </select>
  );
}

// Usage with type inference
const StatusSelect = () => {
  type Status = 'active' | 'inactive' | 'pending';
  const [status, setStatus] = useState<Status>('active');

  return (
    <Select<Status>
      value={status}
      onChange={setStatus} // Type-safe!
      options={[
        { value: 'active', label: 'Active' },
        { value: 'inactive', label: 'Inactive' },
        { value: 'pending', label: 'Pending' }
      ]}
    />
  );
};

// ============================================
// DISCRIMINATED UNIONS
// ============================================

/**
 * API Response with discriminated unions
 */
type ApiResponse<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

/**
 * Component that handles all response states type-safely
 */
interface DataDisplayProps<T> {
  response: ApiResponse<T>;
  render: (data: T) => React.ReactNode;
}

function DataDisplay<T>({ response, render }: DataDisplayProps<T>) {
  // TypeScript knows which properties exist based on status
  switch (response.status) {
    case 'idle':
      return <div>Waiting to load...</div>;
    
    case 'loading':
      return <div>Loading...</div>;
    
    case 'success':
      // TypeScript knows 'data' exists here
      return <>{render(response.data)}</>;
    
    case 'error':
      // TypeScript knows 'error' exists here
      return <div className="error">Error: {response.error}</div>;
    
    default:
      // Exhaustive check - TypeScript ensures all cases are handled
      const _exhaustive: never = response;
      return null;
  }
}

// Usage
interface User {
  id: number;
  name: string;
}

const UserDisplay: React.FC = () => {
  const [response, setResponse] = useState<ApiResponse<User>>({ status: 'idle' });

  const loadUser = async () => {
    setResponse({ status: 'loading' });
    
    try {
      const res = await fetch('/api/user');
      const data = await res.json();
      setResponse({ status: 'success', data }); // Type-safe!
    } catch (error) {
      setResponse({ status: 'error', error: 'Failed to load user' });
    }
  };

  return (
    <div>
      <button onClick={loadUser}>Load User</button>
      <DataDisplay
        response={response}
        render={(user) => (
          <div>
            <h2>{user.name}</h2>
            <p>ID: {user.id}</p>
          </div>
        )}
      />
    </div>
  );
};

// ============================================
// UTILITY TYPES
// ============================================

/**
 * Form field type from existing interface
 */
interface UserForm {
  name: string;
  email: string;
  age: number;
  agreeToTerms: boolean;
}

// Extract field names as union type
type UserFormField = keyof UserForm; // 'name' | 'email' | 'age' | 'agreeToTerms'

// Create validation errors type
type ValidationErrors = Partial<Record<UserFormField, string>>;

// Field component with type safety
interface FieldProps<K extends UserFormField> {
  name: K;
  value: UserForm[K]; // Type of value matches field type!
  onChange: (name: K, value: UserForm[K]) => void;
  error?: string;
}

function Field<K extends UserFormField>({
  name,
  value,
  onChange,
  error
}: FieldProps<K>) {
  return (
    <div className="field">
      <label>{name}</label>
      
      {typeof value === 'boolean' ? (
        <input
          type="checkbox"
          checked={value}
          onChange={(e) => onChange(name, e.target.checked as UserForm[K])}
        />
      ) : typeof value === 'number' ? (
        <input
          type="number"
          value={value}
          onChange={(e) => onChange(name, Number(e.target.value) as UserForm[K])}
        />
      ) : (
        <input
          type="text"
          value={value}
          onChange={(e) => onChange(name, e.target.value as UserForm[K])}
        />
      )}
      
      {error && <span className="error">{error}</span>}
    </div>
  );
}

// ============================================
// CONDITIONAL TYPES
// ============================================

/**
 * Button variant based on props
 */
type ButtonVariant = 'primary' | 'secondary' | 'danger';

// Conditional props based on variant
type ButtonProps<V extends ButtonVariant> = {
  variant: V;
  children: React.ReactNode;
  onClick?: () => void;
} & (V extends 'danger'
  ? { confirmMessage: string } // Danger buttons require confirmation
  : {});

function Button<V extends ButtonVariant>(props: ButtonProps<V>) {
  const { variant, children, onClick } = props;

  const handleClick = () => {
    if (variant === 'danger') {
      // TypeScript knows confirmMessage exists for danger variant
      const dangerProps = props as ButtonProps<'danger'>;
      if (window.confirm(dangerProps.confirmMessage)) {
        onClick?.();
      }
    } else {
      onClick?.();
    }
  };

  return (
    <button className={`btn btn-${variant}`} onClick={handleClick}>
      {children}
    </button>
  );
}

// Usage
const ButtonExamples = () => (
  <div>
    {/* ✅ Valid */}
    <Button variant="primary" onClick={() => console.log('Click')}>
      Save
    </Button>
    
    {/* ✅ Valid - confirmMessage required for danger */}
    <Button
      variant="danger"
      confirmMessage="Are you sure?"
      onClick={() => console.log('Delete')}>
      Delete
    </Button>
    
    {/* ❌ Type Error - confirmMessage missing for danger */}
    {/* <Button variant="danger" onClick={() => {}}>Delete</Button> */}
  </div>
);

// ============================================
// MAPPED TYPES
// ============================================

/**
 * Create form state from any interface
 */
type FormState<T> = {
  values: T;
  errors: Partial<Record<keyof T, string>>;
  touched: Partial<Record<keyof T, boolean>>;
};

type FormHandlers<T> = {
  [K in keyof T as `handle${Capitalize<string & K>}Change`]: (value: T[K]) => void;
};

// Example: Generates handleNameChange, handleEmailChange, etc.
type UserFormHandlers = FormHandlers<UserForm>;
// {
//   handleNameChange: (value: string) => void;
//   handleEmailChange: (value: string) => void;
//   handleAgeChange: (value: number) => void;
//   handleAgreeToTermsChange: (value: boolean) => void;
// }

/**
 * Make all properties optional and nullable
 */
type Nullable<T> = {
  [K in keyof T]: T[K] | null;
};

type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K];
};

// ============================================
// COMPONENT PROPS WITH GENERICS
// ============================================

/**
 * List component with flexible rendering
 */
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T, index: number) => string | number;
  emptyMessage?: string;
  loading?: boolean;
  onItemClick?: (item: T) => void;
}

function List<T>({
  items,
  renderItem,
  keyExtractor,
  emptyMessage = 'No items',
  loading = false,
  onItemClick
}: ListProps<T>) {
  if (loading) {
    return <div>Loading...</div>;
  }

  if (items.length === 0) {
    return <div className="empty">{emptyMessage}</div>;
  }

  return (
    <ul className="list">
      {items.map((item, index) => {
        const key = keyExtractor(item, index);
        
        return (
          <li
            key={key}
            onClick={() => onItemClick?.(item)}
            className={onItemClick ? 'clickable' : ''}>
            {renderItem(item, index)}
          </li>
        );
      })}
    </ul>
  );
}

// Usage with different types
const ListExamples = () => {
  const users = [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' }
  ];

  const products = [
    { sku: 'A1', title: 'Product 1', price: 99.99 },
    { sku: 'A2', title: 'Product 2', price: 149.99 }
  ];

  return (
    <div>
      {/* User list */}
      <List
        items={users}
        keyExtractor={(user) => user.id}
        renderItem={(user) => <strong>{user.name}</strong>}
        onItemClick={(user) => console.log(user.name)} // Type-safe!
      />

      {/* Product list */}
      <List
        items={products}
        keyExtractor={(product) => product.sku}
        renderItem={(product) => (
          <div>
            <h3>{product.title}</h3>
            <span>${product.price}</span>
          </div>
        )}
      />
    </div>
  );
};

// ============================================
// ADVANCED: As Prop Pattern
// ============================================

/**
 * Polymorphic component that can render as any HTML element
 */
type AsProp<C extends React.ElementType> = {
  as?: C;
};

type PropsToOmit<C extends React.ElementType, P> = keyof (AsProp<C> & P);

type PolymorphicComponentProps<
  C extends React.ElementType,
  Props = {}
> = React.PropsWithChildren<Props & AsProp<C>> &
  Omit<React.ComponentPropsWithoutRef<C>, PropsToOmit<C, Props>>;

type TextProps<C extends React.ElementType> = PolymorphicComponentProps<
  C,
  {
    color?: 'primary' | 'secondary' | 'danger';
    size?: 'sm' | 'md' | 'lg';
  }
>;

type TextComponent = <C extends React.ElementType = 'span'>(
  props: TextProps<C>
) => React.ReactElement | null;

/**
 * Text component that can render as any element
 */
const Text: TextComponent = ({
  as,
  color = 'primary',
  size = 'md',
  children,
  ...restProps
}) => {
  const Component = as || 'span';
  
  return (
    <Component
      className={`text text-${color} text-${size}`}
      {...restProps}>
      {children}
    </Component>
  );
};

// Usage
const TextExamples = () => (
  <div>
    {/* Renders as span (default) */}
    <Text color="primary">Default span</Text>
    
    {/* Renders as h1 with h1 props */}
    <Text as="h1" color="danger">
      Heading
    </Text>
    
    {/* Renders as button with button props */}
    <Text
      as="button"
      onClick={() => console.log('Clicked')}
      disabled={false}>
      Button Text
    </Text>
    
    {/* Renders as link with anchor props */}
    <Text as="a" href="https://example.com" target="_blank">
      Link
    </Text>
  </div>
);
```

**TypeScript Best Practices:**
1. ✅ Use generics for reusable components
2. ✅ Leverage discriminated unions for state management
3. ✅ Use utility types (Partial, Pick, Omit, Record)
4. ✅ Type event handlers properly
5. ✅ Avoid `any` - use `unknown` if necessary
6. ✅ Use strict TypeScript config
7. ✅ Extract types to separate files for reusability

---

## Data Fetching & Caching

### Q10: Implement React Query patterns (Asked at: Spotify, Uber)

**Question:** Build a data fetching solution with caching, optimistic updates, and infinite scroll.

**Implementation:**

```typescript
// ============================================
// REACT QUERY SETUP
// ============================================

// queryClient.ts
import { QueryClient } from '@tanstack/react-query';

/**
 * Configure React Query client
 */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // Data is fresh for 5 minutes
      cacheTime: 10 * 60 * 1000, // Cache for 10 minutes
      retry: 3, // Retry failed requests 3 times
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      refetchOnWindowFocus: false, // Don't refetch on window focus
      refetchOnReconnect: true // Refetch when internet reconnects
    },
    mutations: {
      retry: 1 // Retry mutations once
    }
  }
});

// App.tsx
import { QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

export const App = () => (
  <QueryClientProvider client={queryClient}>
    <YourApp />
    <ReactQueryDevtools initialIsOpen={false} />
  </QueryClientProvider>
);

// ============================================
// API CLIENT
// ============================================

// api/client.ts

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function apiClient<T>(
  endpoint: string,
  { body, ...customConfig }: RequestInit = {}
): Promise<T> {
  const config: RequestInit = {
    method: body ? 'POST' : 'GET',
    ...customConfig,
    headers: {
      'Content-Type': 'application/json',
      ...customConfig.headers
    },
    body: body ? JSON.stringify(body) : undefined
  };

  const response = await fetch(`https://api.example.com${endpoint}`, config);

  if (!response.ok) {
    throw new ApiError(response.status, `HTTP ${response.status}: ${response.statusText}`);
  }

  return response.json();
}

// ============================================
// DATA FETCHING WITH REACT QUERY
// ============================================

// hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  category: string;
}

/**
 * Fetch all products
 */
export function useProducts(category?: string) {
  return useQuery({
    queryKey: ['products', category], // Cache key includes category
    queryFn: () => apiClient<Product[]>(`/products${category ? `?category=${category}` : ''}`),
    staleTime: 2 * 60 * 1000, // Fresh for 2 minutes
    onSuccess: (data) => {
      console.log(`Loaded ${data.length} products`);
    },
    onError: (error) => {
      console.error('Failed to load products:', error);
    }
  });
}

/**
 * Fetch single product
 */
export function useProduct(productId: number) {
  return useQuery({
    queryKey: ['products', productId],
    queryFn: () => apiClient<Product>(`/products/${productId}`),
    enabled: productId > 0, // Only fetch if ID is valid
    staleTime: 5 * 60 * 1000
  });
}

/**
 * Create product mutation
 */
export function useCreateProduct() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (newProduct: Omit<Product, 'id'>) =>
      apiClient<Product>('/products', {
        method: 'POST',
        body: newProduct as any
      }),
    
    onSuccess: (newProduct) => {
      // Invalidate and refetch products list
      queryClient.invalidateQueries({ queryKey: ['products'] });
      
      console.log('✓ Product created:', newProduct.id);
    },
    
    onError: (error) => {
      console.error('✗ Failed to create product:', error);
    }
  });
}

/**
 * Update product with optimistic update
 */
export function useUpdateProduct() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, updates }: { id: number; updates: Partial<Product> }) =>
      apiClient<Product>(`/products/${id}`, {
        method: 'PUT',
        body: updates as any
      }),
    
    // Optimistic update
    onMutate: async ({ id, updates }) => {
      // Cancel any outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['products', id] });
      
      // Snapshot previous value
      const previousProduct = queryClient.getQueryData<Product>(['products', id]);
      
      // Optimistically update cache
      queryClient.setQueryData<Product>(['products', id], (old) => {
        if (!old) return old;
        return { ...old, ...updates };
      });
      
      console.log('⚡ Optimistic update applied');
      
      // Return context with previous value
      return { previousProduct };
    },
    
    onError: (error, variables, context) => {
      // Rollback on error
      if (context?.previousProduct) {
        queryClient.setQueryData(['products', variables.id], context.previousProduct);
        console.log('↩️ Rolled back optimistic update');
      }
    },
    
    onSuccess: (updatedProduct) => {
      // Update cache with server response
      queryClient.setQueryData(['products', updatedProduct.id], updatedProduct);
      
      // Invalidate products list
      queryClient.invalidateQueries({ queryKey: ['products'] });
      
      console.log('✓ Product updated:', updatedProduct.id);
    }
  });
}

/**
 * Delete product
 */
export function useDeleteProduct() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (productId: number) =>
      apiClient(`/products/${productId}`, { method: 'DELETE' }),
    
    onMutate: async (productId) => {
      await queryClient.cancelQueries({ queryKey: ['products'] });
      
      // Remove from cache optimistically
      queryClient.setQueryData<Product[]>(['products'], (old) => {
        if (!old) return old;
        return old.filter(p => p.id !== productId);
      });
    },
    
    onSuccess: (_, productId) => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
      console.log('✓ Product deleted:', productId);
    }
  });
}

// ============================================
// INFINITE SCROLL
// ============================================

// hooks/useInfiniteProducts.ts
import { useInfiniteQuery } from '@tanstack/react-query';

interface ProductsPage {
  products: Product[];
  nextCursor: number | null;
  hasMore: boolean;
}

export function useInfiniteProducts(category?: string) {
  return useInfiniteQuery({
    queryKey: ['products', 'infinite', category],
    
    queryFn: ({ pageParam = 0 }) =>
      apiClient<ProductsPage>(
        `/products?cursor=${pageParam}${category ? `&category=${category}` : ''}`
      ),
    
    getNextPageParam: (lastPage) => {
      // Return next cursor or undefined to stop
      return lastPage.hasMore ? lastPage.nextCursor : undefined;
    },
    
    staleTime: 2 * 60 * 1000
  });
}

// ============================================
// COMPONENT EXAMPLES
// ============================================

// ProductList.tsx
import React from 'react';

export const ProductList: React.FC = () => {
  const [category, setCategory] = React.useState<string>();
  
  // Fetch products
  const { data, isLoading, error, refetch } = useProducts(category);

  if (isLoading) {
    return <div>Loading products...</div>;
  }

  if (error) {
    return (
      <div>
        <div className="error">Error: {error.message}</div>
        <button onClick={() => refetch()}>Retry</button>
      </div>
    );
  }

  return (
    <div>
      <select onChange={(e) => setCategory(e.target.value || undefined)}>
        <option value="">All Categories</option>
        <option value="electronics">Electronics</option>
        <option value="clothing">Clothing</option>
      </select>

      <div className="products-grid">
        {data?.map(product => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
};

// ProductCard.tsx
interface ProductCardProps {
  product: Product;
}

const ProductCard: React.FC<ProductCardProps> = ({ product }) => {
  const updateProduct = useUpdateProduct();
  const deleteProduct = useDeleteProduct();

  const handleToggleFavorite = () => {
    updateProduct.mutate({
      id: product.id,
      updates: { favorite: !product.favorite }
    });
  };

  const handleDelete = () => {
    if (window.confirm('Delete this product?')) {
      deleteProduct.mutate(product.id);
    }
  };

  return (
    <div className="product-card">
      <h3>{product.name}</h3>
      <p>${product.price}</p>
      
      <button
        onClick={handleToggleFavorite}
        disabled={updateProduct.isLoading}>
        {updateProduct.isLoading ? '...' : product.favorite ? '❤️' : '🤍'}
      </button>
      
      <button
        onClick={handleDelete}
        disabled={deleteProduct.isLoading}>
        Delete
      </button>
    </div>
  );
};

// InfiniteProductList.tsx
import React from 'react';
import { useInView } from 'react-intersection-observer';

export const InfiniteProductList: React.FC = () => {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
    error
  } = useInfiniteProducts();

  // Trigger fetch when sentinel is in view
  const { ref, inView } = useInView();

  React.useEffect(() => {
    if (inView && hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [inView, hasNextPage, isFetchingNextPage, fetchNextPage]);

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  return (
    <div>
      <div className="products-grid">
        {data?.pages.map((page, pageIndex) => (
          <React.Fragment key={pageIndex}>
            {page.products.map(product => (
              <ProductCard key={product.id} product={product} />
            ))}
          </React.Fragment>
        ))}
      </div>

      {/* Sentinel element */}
      <div ref={ref} className="loading-sentinel">
        {isFetchingNextPage ? 'Loading more...' : hasNextPage ? 'Scroll for more' : 'All loaded'}
      </div>
    </div>
  );
};
```

**React Query Benefits:**
1. ✅ Automatic caching and background refetching
2. ✅ Optimistic updates for better UX
3. ✅ Built-in loading and error states
4. ✅ Request deduplication
5. ✅ Automatic garbage collection
6. ✅ Window focus refetching
7. ✅ Pagination and infinite scroll support

---

## Architecture & Best Practices

### Q11: Design scalable React application architecture (Asked at: Amazon, Thoughtworks)

**Question:** Propose a folder structure and patterns for a large-scale React application with multiple teams.

**Implementation:**

```typescript
// ============================================
// FOLDER STRUCTURE
// ============================================

/**
 * Scalable React Application Structure
 * 
 * src/
 * ├── app/                         # App-level configuration
 * │   ├── App.tsx                  # Root component
 * │   ├── Router.tsx               # Route configuration
 * │   ├── providers/               # Global providers
 * │   │   ├── AppProviders.tsx     # Combined providers
 * │   │   ├── ThemeProvider.tsx
 * │   │   └── AuthProvider.tsx
 * │   └── store/                   # Global state (if using Redux/Zustand)
 * │       ├── index.ts
 * │       └── slices/
 * │
 * ├── features/                    # Feature-based modules
 * │   ├── auth/
 * │   │   ├── components/          # Feature-specific components
 * │   │   │   ├── LoginForm.tsx
 * │   │   │   └── RegisterForm.tsx
 * │   │   ├── hooks/               # Feature-specific hooks
 * │   │   │   ├── useAuth.ts
 * │   │   │   └── useLogin.ts
 * │   │   ├── api/                 # Feature API functions
 * │   │   │   └── authApi.ts
 * │   │   ├── types/               # Feature types
 * │   │   │   └── auth.types.ts
 * │   │   ├── utils/               # Feature utilities
 * │   │   │   └── tokenStorage.ts
 * │   │   └── index.ts             # Public API
 * │   │
 * │   ├── products/
 * │   │   ├── components/
 * │   │   ├── hooks/
 * │   │   ├── api/
 * │   │   ├── types/
 * │   │   └── index.ts
 * │   │
 * │   └── checkout/
 * │       ├── components/
 * │       ├── hooks/
 * │       ├── api/
 * │       └── index.ts
 * │
 * ├── shared/                      # Shared across features
 * │   ├── components/              # Reusable UI components
 * │   │   ├── Button/
 * │   │   │   ├── Button.tsx
 * │   │   │   ├── Button.test.tsx
 * │   │   │   ├── Button.module.css
 * │   │   │   └── index.ts
 * │   │   ├── Input/
 * │   │   └── Modal/
 * │   │
 * │   ├── hooks/                   # Reusable hooks
 * │   │   ├── useDebounce.ts
 * │   │   ├── useLocalStorage.ts
 * │   │   └── useFetch.ts
 * │   │
 * │   ├── utils/                   # Utility functions
 * │   │   ├── formatters.ts
 * │   │   ├── validators.ts
 * │   │   └── helpers.ts
 * │   │
 * │   ├── types/                   # Shared types
 * │   │   └── common.types.ts
 * │   │
 * │   └── constants/               # App constants
 * │       └── config.ts
 * │
 * ├── api/                         # API layer
 * │   ├── client.ts                # API client setup
 * │   ├── endpoints.ts             # API endpoints
 * │   └── interceptors.ts          # Request/response interceptors
 * │
 * ├── layouts/                     # Layout components
 * │   ├── MainLayout.tsx
 * │   ├── AuthLayout.tsx
 * │   └── DashboardLayout.tsx
 * │
 * ├── pages/                       # Page components (route-level)
 * │   ├── HomePage.tsx
 * │   ├── ProductsPage.tsx
 * │   └── CheckoutPage.tsx
 * │
 * └── assets/                      # Static assets
 *     ├── images/
 *     ├── fonts/
 *     └── icons/
 */

// ============================================
// FEATURE MODULE EXAMPLE
// ============================================

// features/products/index.ts
/**
 * Public API for products feature
 * Only export what other features need
 */
export { ProductList } from './components/ProductList';
export { ProductDetail } from './components/ProductDetail';
export { useProducts, useProduct } from './hooks/useProducts';
export type { Product, ProductFilter } from './types/product.types';

// features/products/types/product.types.ts
export interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  category: string;
  images: string[];
  inStock: boolean;
}

export interface ProductFilter {
  category?: string;
  minPrice?: number;
  maxPrice?: number;
  search?: string;
}

// features/products/api/productsApi.ts
import { apiClient } from '@/api/client';
import type { Product, ProductFilter } from '../types/product.types';

export const productsApi = {
  /**
   * Get all products with optional filters
   */
  async getProducts(filters?: ProductFilter): Promise<Product[]> {
    const params = new URLSearchParams();
    
    if (filters?.category) params.append('category', filters.category);
    if (filters?.minPrice) params.append('minPrice', String(filters.minPrice));
    if (filters?.maxPrice) params.append('maxPrice', String(filters.maxPrice));
    if (filters?.search) params.append('search', filters.search);
    
    const query = params.toString();
    return apiClient<Product[]>(`/products${query ? `?${query}` : ''}`);
  },

  /**
   * Get single product by ID
   */
  async getProduct(id: number): Promise<Product> {
    return apiClient<Product>(`/products/${id}`);
  },

  /**
   * Create new product
   */
  async createProduct(product: Omit<Product, 'id'>): Promise<Product> {
    return apiClient<Product>('/products', {
      method: 'POST',
      body: product as any
    });
  },

  /**
   * Update product
   */
  async updateProduct(id: number, updates: Partial<Product>): Promise<Product> {
    return apiClient<Product>(`/products/${id}`, {
      method: 'PUT',
      body: updates as any
    });
  },

  /**
   * Delete product
   */
  async deleteProduct(id: number): Promise<void> {
    return apiClient(`/products/${id}`, {
      method: 'DELETE'
    });
  }
};

// features/products/hooks/useProducts.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi } from '../api/productsApi';
import type { Product, ProductFilter } from '../types/product.types';

/**
 * Hook for fetching products
 */
export function useProducts(filters?: ProductFilter) {
  return useQuery({
    queryKey: ['products', filters],
    queryFn: () => productsApi.getProducts(filters)
  });
}

/**
 * Hook for fetching single product
 */
export function useProduct(id: number) {
  return useQuery({
    queryKey: ['products', id],
    queryFn: () => productsApi.getProduct(id),
    enabled: id > 0
  });
}

/**
 * Hook for creating product
 */
export function useCreateProduct() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: productsApi.createProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['products'] });
    }
  });
}

// ============================================
// API CLIENT
// ============================================

// api/client.ts
import { API_BASE_URL, API_TIMEOUT } from '@/shared/constants/config';

/**
 * Centralized API client
 */
export async function apiClient<T>(
  endpoint: string,
  config: RequestInit = {}
): Promise<T> {
  // Get auth token
  const token = localStorage.getItem('auth_token');
  
  // Build request
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), API_TIMEOUT);
  
  const response = await fetch(`${API_BASE_URL}${endpoint}`, {
    ...config,
    signal: controller.signal,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...config.headers
    }
  });
  
  clearTimeout(timeoutId);
  
  // Handle errors
  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new ApiError(
      response.status,
      error.message || `HTTP ${response.status}`
    );
  }
  
  return response.json();
}

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

// ============================================
// SHARED COMPONENTS
// ============================================

// shared/components/Button/Button.tsx
import React from 'react';
import styles from './Button.module.css';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  fullWidth?: boolean;
}

/**
 * Reusable Button component
 */
export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  loading = false,
  fullWidth = false,
  disabled,
  className,
  ...props
}) => {
  return (
    <button
      className={`
        ${styles.button}
        ${styles[variant]}
        ${styles[size]}
        ${fullWidth ? styles.fullWidth : ''}
        ${className || ''}
      `}
      disabled={disabled || loading}
      {...props}>
      {loading ? <span className={styles.spinner} /> : children}
    </button>
  );
};

// shared/components/Button/index.ts
export { Button } from './Button';
export type { ButtonProps } from './Button';

// ============================================
// ROUTER CONFIGURATION
// ============================================

// app/Router.tsx
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { MainLayout } from '@/layouts/MainLayout';
import { HomePage } from '@/pages/HomePage';
import { ProductsPage } from '@/pages/ProductsPage';
import { ProductDetailPage } from '@/pages/ProductDetailPage';

const router = createBrowserRouter([
  {
    path: '/',
    element: <MainLayout />,
    children: [
      {
        index: true,
        element: <HomePage />
      },
      {
        path: 'products',
        element: <ProductsPage />
      },
      {
        path: 'products/:id',
        element: <ProductDetailPage />
      }
    ]
  }
]);

export const AppRouter = () => <RouterProvider router={router} />;

// ============================================
// ERROR BOUNDARY
// ============================================

// shared/components/ErrorBoundary.tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

/**
 * Error boundary component
 */
export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
    
    // Log to error reporting service
    // logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }
      
      return (
        <div className="error-boundary">
          <h1>Something went wrong</h1>
          <p>{this.state.error?.message}</p>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

**Architecture Best Practices:**
1. ✅ Feature-based folder structure
2. ✅ Clear separation of concerns
3. ✅ Public APIs for features (index.ts)
4. ✅ Centralized API client
5. ✅ Shared components library
6. ✅ Type safety with TypeScript
7. ✅ Error boundaries
8. ✅ Code splitting and lazy loading
9. ✅ Consistent naming conventions
10. ✅ Documentation and comments

---

## Summary

### Key Interview Topics Covered

1. **Hooks & State Management** (Q1-Q2)
   - useState vs useReducer comparison
   - useEffect cleanup and dependencies
   - Race condition handling

2. **Performance Optimization** (Q3)
   - React.memo for component memoization
   - useMemo for expensive calculations
   - useCallback for stable function references

3. **Context API** (Q4)
   - Theme and authentication contexts
   - Split contexts for optimization
   - Custom hooks for context access

4. **Custom Hooks** (Q5)
   - useFetch with caching
   - useDebounce
   - useForm
   - useLocalStorage

5. **Server-Side Rendering** (Q6)
   - SSG vs SSR vs ISR comparison
   - getStaticProps and getServerSideProps
   - Next.js rendering strategies

6. **Testing** (Q7)
   - React Testing Library
   - User interaction testing
   - Async operation testing
   - Mocking and error handling

7. **Advanced Patterns** (Q8)
   - Compound components
   - Render props
   - Flexible component APIs

8. **TypeScript** (Q9)
   - Generic components
   - Discriminated unions
   - Utility types
   - Type-safe props

9. **Data Fetching** (Q10)
   - React Query setup
   - Caching strategies
   - Optimistic updates
   - Infinite scroll

10. **Architecture** (Q11)
    - Scalable folder structure
    - Feature modules
    - API layer design
    - Error boundaries

### Interview Preparation Tips

1. **Practice Coding**: Implement these patterns from scratch
2. **Understand Trade-offs**: Know when to use each approach
3. **Real-world Scenarios**: Think about production use cases
4. **Performance**: Understand rendering and optimization
5. **Testing**: Write tests for your components
6. **TypeScript**: Master advanced types
7. **Best Practices**: Follow React community standards

### Additional Resources

- [React Documentation](https://react.dev/)
- [React Query Docs](https://tanstack.com/query/latest)
- [Next.js Documentation](https://nextjs.org/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Testing Library](https://testing-library.com/)
- [React Patterns](https://reactpatterns.com/)

---

**Good luck with your interviews! 🚀**
