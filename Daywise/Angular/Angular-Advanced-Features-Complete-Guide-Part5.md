# Angular Advanced Features Complete Guide - Part 5: Routing Features

## Category 4: Routing Features (6 Features)

This section covers advanced Angular Router features for sophisticated navigation scenarios, animations, and URL management.

---

### 1. Router Events (Navigation Lifecycle)

**Description:** Router Events provide granular insight into the navigation lifecycle. Monitor navigation start, end, errors, and route resolution for logging, loading indicators, and analytics.

#### Angular: Router Events Examples

**Basic Router Event Monitoring:**

```typescript
// router-events.service.ts
import { Injectable, inject } from '@angular/core';
import { Router, NavigationStart, NavigationEnd, NavigationCancel, NavigationError, RoutesRecognized, GuardsCheckStart, GuardsCheckEnd, ResolveStart, ResolveEnd, Event } from '@angular/router';
import { filter } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class RouterEventsService {
  private router = inject(Router);

  constructor() {
    // Subscribe to all router events
    this.router.events.subscribe((event: Event) => {
      this.logEvent(event);
    });
  }

  private logEvent(event: Event): void {
    if (event instanceof NavigationStart) {
      console.log('🔵 Navigation Started:', event.url);
      console.log('  ID:', event.id);
      console.log('  Trigger:', event.navigationTrigger);
      console.log('  Restore:', event.restoredState);
    }

    if (event instanceof RoutesRecognized) {
      console.log('🟢 Routes Recognized');
      console.log('  URL:', event.url);
      console.log('  State:', event.state);
    }

    if (event instanceof GuardsCheckStart) {
      console.log('🟡 Guards Check Started');
      console.log('  URL:', event.url);
    }

    if (event instanceof GuardsCheckEnd) {
      console.log('🟢 Guards Check Completed');
      console.log('  Should Activate:', event.shouldActivate);
    }

    if (event instanceof ResolveStart) {
      console.log('🟣 Resolve Started');
      console.log('  URL:', event.url);
    }

    if (event instanceof ResolveEnd) {
      console.log('🟢 Resolve Completed');
      console.log('  URL:', event.url);
    }

    if (event instanceof NavigationEnd) {
      console.log('✅ Navigation Completed:', event.url);
      console.log('  ID:', event.id);
    }

    if (event instanceof NavigationCancel) {
      console.log('⚠️ Navigation Cancelled:', event.url);
      console.log('  Reason:', event.reason);
    }

    if (event instanceof NavigationError) {
      console.error('❌ Navigation Error:', event.url);
      console.error('  Error:', event.error);
    }
  }

  // Listen to specific events
  onNavigationStart() {
    return this.router.events.pipe(
      filter((event): event is NavigationStart => event instanceof NavigationStart)
    );
  }

  onNavigationEnd() {
    return this.router.events.pipe(
      filter((event): event is NavigationEnd => event instanceof NavigationEnd)
    );
  }

  onNavigationError() {
    return this.router.events.pipe(
      filter((event): event is NavigationError => event instanceof NavigationError)
    );
  }
}
```

**Loading Indicator with Router Events:**

```typescript
// loading-indicator.service.ts
import { Injectable, inject } from '@angular/core';
import { Router, NavigationStart, NavigationEnd, NavigationCancel, NavigationError } from '@angular/router';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class LoadingIndicatorService {
  private router = inject(Router);
  private loadingSubject = new BehaviorSubject<boolean>(false);
  
  // Public observable for components to subscribe
  loading$ = this.loadingSubject.asObservable();

  constructor() {
    this.router.events.subscribe(event => {
      // Show loader on navigation start
      if (event instanceof NavigationStart) {
        this.loadingSubject.next(true);
      }

      // Hide loader on navigation end, cancel, or error
      if (
        event instanceof NavigationEnd ||
        event instanceof NavigationCancel ||
        event instanceof NavigationError
      ) {
        this.loadingSubject.next(false);
      }
    });
  }
}

// loading-indicator.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LoadingIndicatorService } from './loading-indicator.service';

@Component({
  selector: 'app-loading-indicator',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (loadingService.loading$ | async) {
      <div class="loading-bar">
        <div class="loading-progress"></div>
      </div>
    }
  `,
  styles: [`
    .loading-bar {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      height: 3px;
      background: rgba(0, 0, 0, 0.1);
      z-index: 9999;
      overflow: hidden;
    }
    .loading-progress {
      height: 100%;
      background: linear-gradient(90deg, #2196f3, #00bcd4);
      animation: loading 1s ease-in-out infinite;
    }
    @keyframes loading {
      0% {
        width: 0%;
        margin-left: 0%;
      }
      50% {
        width: 75%;
        margin-left: 12.5%;
      }
      100% {
        width: 0%;
        margin-left: 100%;
      }
    }
  `]
})
export class LoadingIndicatorComponent {
  loadingService = inject(LoadingIndicatorService);
}
```

**Analytics Tracking with Router Events:**

```typescript
// analytics.service.ts
import { Injectable, inject } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AnalyticsService {
  private router = inject(Router);

  constructor() {
    // Track page views on navigation end
    this.router.events.pipe(
      filter((event): event is NavigationEnd => event instanceof NavigationEnd)
    ).subscribe(event => {
      this.trackPageView(event.urlAfterRedirects);
    });
  }

  private trackPageView(url: string): void {
    console.log('📊 Page View:', url);
    
    // Send to analytics service (Google Analytics, etc.)
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('config', 'GA_MEASUREMENT_ID', {
        page_path: url
      });
    }
  }

  trackEvent(category: string, action: string, label?: string, value?: number): void {
    console.log('📊 Event:', { category, action, label, value });
    
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('event', action, {
        event_category: category,
        event_label: label,
        value: value
      });
    }
  }
}
```

**Navigation History Tracker:**

```typescript
// navigation-history.service.ts
import { Injectable, inject } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';
import { filter } from 'rxjs/operators';
import { BehaviorSubject } from 'rxjs';

interface NavigationHistoryItem {
  url: string;
  timestamp: Date;
  id: number;
}

@Injectable({
  providedIn: 'root'
})
export class NavigationHistoryService {
  private router = inject(Router);
  private historySubject = new BehaviorSubject<NavigationHistoryItem[]>([]);
  private maxHistorySize = 10;
  
  history$ = this.historySubject.asObservable();

  constructor() {
    this.router.events.pipe(
      filter((event): event is NavigationEnd => event instanceof NavigationEnd)
    ).subscribe(event => {
      this.addToHistory({
        url: event.urlAfterRedirects,
        timestamp: new Date(),
        id: event.id
      });
    });
  }

  private addToHistory(item: NavigationHistoryItem): void {
    const currentHistory = this.historySubject.value;
    const newHistory = [item, ...currentHistory].slice(0, this.maxHistorySize);
    this.historySubject.next(newHistory);
  }

  getPreviousUrl(): string | null {
    const history = this.historySubject.value;
    return history.length > 1 ? history[1].url : null;
  }

  canGoBack(): boolean {
    return this.historySubject.value.length > 1;
  }

  getHistory(): NavigationHistoryItem[] {
    return [...this.historySubject.value];
  }

  clearHistory(): void {
    this.historySubject.next([]);
  }
}

// back-button.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { NavigationHistoryService } from './navigation-history.service';

@Component({
  selector: 'app-back-button',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button 
      (click)="goBack()" 
      [disabled]="!historyService.canGoBack()"
      class="back-button">
      ← Back
    </button>
  `,
  styles: [`
    .back-button {
      padding: 8px 16px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .back-button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
  `]
})
export class BackButtonComponent {
  private router = inject(Router);
  historyService = inject(NavigationHistoryService);

  goBack(): void {
    const previousUrl = this.historyService.getPreviousUrl();
    if (previousUrl) {
      this.router.navigateByUrl(previousUrl);
    }
  }
}
```

**Breadcrumb from Router Events:**

```typescript
// breadcrumb.service.ts
import { Injectable, inject } from '@angular/core';
import { Router, NavigationEnd, ActivatedRoute } from '@angular/router';
import { filter, map } from 'rxjs/operators';
import { BehaviorSubject } from 'rxjs';

export interface Breadcrumb {
  label: string;
  url: string;
}

@Injectable({
  providedIn: 'root'
})
export class BreadcrumbService {
  private router = inject(Router);
  private activatedRoute = inject(ActivatedRoute);
  private breadcrumbsSubject = new BehaviorSubject<Breadcrumb[]>([]);
  
  breadcrumbs$ = this.breadcrumbsSubject.asObservable();

  constructor() {
    this.router.events.pipe(
      filter((event): event is NavigationEnd => event instanceof NavigationEnd)
    ).subscribe(() => {
      const breadcrumbs = this.createBreadcrumbs(this.activatedRoute.root);
      this.breadcrumbsSubject.next(breadcrumbs);
    });
  }

  private createBreadcrumbs(route: ActivatedRoute, url = '', breadcrumbs: Breadcrumb[] = []): Breadcrumb[] {
    const children: ActivatedRoute[] = route.children;

    if (children.length === 0) {
      return breadcrumbs;
    }

    for (const child of children) {
      const routeURL: string = child.snapshot.url.map(segment => segment.path).join('/');
      if (routeURL !== '') {
        url += `/${routeURL}`;
      }

      const label = child.snapshot.data['breadcrumb'];
      if (label) {
        breadcrumbs.push({ label, url });
      }

      return this.createBreadcrumbs(child, url, breadcrumbs);
    }

    return breadcrumbs;
  }
}

// breadcrumb.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { BreadcrumbService } from './breadcrumb.service';

@Component({
  selector: 'app-breadcrumb',
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <nav class="breadcrumb">
      @for (crumb of breadcrumbService.breadcrumbs$ | async; track crumb.url; let last = $last) {
        @if (!last) {
          <a [routerLink]="crumb.url">{{ crumb.label }}</a>
          <span class="separator">/</span>
        } @else {
          <span class="current">{{ crumb.label }}</span>
        }
      }
    </nav>
  `,
  styles: [`
    .breadcrumb {
      padding: 12px;
      background: #f5f5f5;
      border-radius: 4px;
    }
    .breadcrumb a {
      color: #2196f3;
      text-decoration: none;
      margin: 0 4px;
    }
    .breadcrumb a:hover {
      text-decoration: underline;
    }
    .separator {
      color: #999;
      margin: 0 4px;
    }
    .current {
      color: #333;
      font-weight: bold;
      margin: 0 4px;
    }
  `]
})
export class BreadcrumbComponent {
  breadcrumbService = inject(BreadcrumbService);
}

// Route configuration with breadcrumbs
export const routes: Routes = [
  {
    path: 'products',
    component: ProductsComponent,
    data: { breadcrumb: 'Products' }
  },
  {
    path: 'products/:id',
    component: ProductDetailComponent,
    data: { breadcrumb: 'Product Detail' }
  }
];
```

#### React: Equivalent Router Monitoring

**React Router with Navigation Listeners:**

```tsx
// useRouterEvents.ts
import { useEffect } from 'react';
import { useLocation, useNavigationType } from 'react-router-dom';

export function useRouterEvents() {
  const location = useLocation();
  const navigationType = useNavigationType();

  useEffect(() => {
    console.log('🔵 Navigation:', {
      pathname: location.pathname,
      search: location.search,
      hash: location.hash,
      state: location.state,
      type: navigationType
    });
  }, [location, navigationType]);
}

// LoadingIndicator.tsx
import { useState, useEffect } from 'react';
import { useNavigation } from 'react-router-dom';

function LoadingIndicator() {
  const navigation = useNavigation();
  const isLoading = navigation.state === 'loading';

  return (
    <>
      {isLoading && (
        <div className="loading-bar">
          <div className="loading-progress"></div>
        </div>
      )}
    </>
  );
}

// Analytics tracking
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

function usePageTracking() {
  const location = useLocation();

  useEffect(() => {
    console.log('📊 Page View:', location.pathname);
    
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('config', 'GA_MEASUREMENT_ID', {
        page_path: location.pathname
      });
    }
  }, [location]);
}

// Navigation History
import { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';

interface HistoryItem {
  url: string;
  timestamp: Date;
}

function useNavigationHistory(maxSize = 10) {
  const location = useLocation();
  const [history, setHistory] = useState<HistoryItem[]>([]);

  useEffect(() => {
    setHistory(prev => [
      { url: location.pathname, timestamp: new Date() },
      ...prev
    ].slice(0, maxSize));
  }, [location, maxSize]);

  return {
    history,
    previousUrl: history[1]?.url || null,
    canGoBack: history.length > 1
  };
}
```

#### Comparison: Router Events

| Feature | Angular Router Events | React Router |
|---------|---------------------|-------------|
| **Event Granularity** | ✅ 10+ event types | useLocation/useNavigation |
| **Navigation Lifecycle** | ✅ Full lifecycle | Limited hooks |
| **Guards/Resolvers Events** | ✅ GuardsCheck, Resolve | No equivalent |
| **Error Handling** | NavigationError event | Error boundaries |

**When to Use:**
- **Angular Router Events:** Fine-grained navigation monitoring, loading indicators, analytics
- **React Router:** useLocation, useNavigation hooks for basic tracking

**Further Reading:**
- [Angular Router Events](https://angular.dev/api/router/Event)
- [React Router Hooks](https://reactrouter.com/en/main/hooks/use-location)

---

### 2. Auxiliary Routes (Named Outlets)

**Description:** Auxiliary routes allow multiple independent router outlets in the same view. Perfect for sidebars, modals, split views, and multi-pane layouts.

#### Angular: Auxiliary Routes Examples

**Basic Named Outlets:**

```typescript
// app.routes.ts
import { Routes } from '@angular/router';
import { MainComponent } from './main.component';
import { SidebarComponent } from './sidebar.component';
import { ChatComponent } from './chat.component';
import { NotificationsComponent } from './notifications.component';

export const routes: Routes = [
  {
    path: 'dashboard',
    component: MainComponent
  },
  {
    path: 'sidebar',
    component: SidebarComponent,
    outlet: 'side' // Named outlet
  },
  {
    path: 'chat',
    component: ChatComponent,
    outlet: 'popup' // Another named outlet
  },
  {
    path: 'notifications',
    component: NotificationsComponent,
    outlet: 'popup'
  }
];

// app.component.ts
import { Component } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RouterLink],
  template: `
    <div class="layout">
      <header>
        <h1>My App</h1>
        <nav>
          <a routerLink="/dashboard">Dashboard</a>
          <a [routerLink]="[{ outlets: { side: ['sidebar'] } }]">Open Sidebar</a>
          <a [routerLink]="[{ outlets: { popup: ['chat'] } }]">Open Chat</a>
          <a [routerLink]="[{ outlets: { popup: ['notifications'] } }]">Notifications</a>
          <a [routerLink]="[{ outlets: { side: null, popup: null } }]">Close All</a>
        </nav>
      </header>
      
      <div class="content">
        <!-- Primary outlet -->
        <main>
          <router-outlet></router-outlet>
        </main>
        
        <!-- Named outlet for sidebar -->
        <aside class="sidebar">
          <router-outlet name="side"></router-outlet>
        </aside>
        
        <!-- Named outlet for popup/modal -->
        <div class="popup-container">
          <router-outlet name="popup"></router-outlet>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .layout {
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background: #2196f3;
      color: white;
      padding: 16px;
    }
    nav a {
      color: white;
      margin: 0 8px;
      text-decoration: none;
    }
    .content {
      display: flex;
      flex: 1;
      overflow: hidden;
    }
    main {
      flex: 1;
      padding: 20px;
      overflow: auto;
    }
    .sidebar {
      width: 300px;
      background: #f5f5f5;
      border-left: 1px solid #ddd;
      padding: 20px;
      overflow: auto;
    }
    .popup-container {
      position: fixed;
      bottom: 20px;
      right: 20px;
      width: 350px;
      max-height: 500px;
      background: white;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      overflow: hidden;
    }
  `]
})
export class AppComponent {}
```

**Programmatic Auxiliary Route Navigation:**

```typescript
// navigation.service.ts
import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class NavigationService {
  private router = inject(Router);

  // Open sidebar
  openSidebar(): void {
    this.router.navigate([{ outlets: { side: ['sidebar'] } }]);
  }

  // Open chat in popup
  openChat(): void {
    this.router.navigate([{ outlets: { popup: ['chat'] } }]);
  }

  // Open notifications in popup
  openNotifications(): void {
    this.router.navigate([{ outlets: { popup: ['notifications'] } }]);
  }

  // Close specific outlet
  closeSidebar(): void {
    this.router.navigate([{ outlets: { side: null } }]);
  }

  closePopup(): void {
    this.router.navigate([{ outlets: { popup: null } }]);
  }

  // Close all auxiliary outlets
  closeAll(): void {
    this.router.navigate([{ outlets: { side: null, popup: null } }]);
  }

  // Open multiple outlets at once
  openDashboardWithSidebar(): void {
    this.router.navigate([
      'dashboard',
      { outlets: { side: ['sidebar'] } }
    ]);
  }
}
```

**Modal via Auxiliary Route:**

```typescript
// user-profile-modal.component.ts
import { Component, inject } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-profile-modal',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="modal-backdrop" (click)="close()">
      <div class="modal-content" (click)="$event.stopPropagation()">
        <div class="modal-header">
          <h2>User Profile</h2>
          <button (click)="close()" class="close-btn">×</button>
        </div>
        
        <div class="modal-body">
          <p>User ID: {{ userId }}</p>
          <p>This is a modal displayed via auxiliary route!</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .modal-backdrop {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
    }
    .modal-content {
      background: white;
      border-radius: 8px;
      max-width: 500px;
      width: 90%;
      max-height: 90vh;
      overflow: auto;
    }
    .modal-header {
      padding: 16px;
      border-bottom: 1px solid #ddd;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .modal-body {
      padding: 20px;
    }
    .close-btn {
      background: none;
      border: none;
      font-size: 28px;
      cursor: pointer;
      color: #999;
    }
  `]
})
export class UserProfileModalComponent {
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  
  userId: string | null = null;

  ngOnInit() {
    this.userId = this.route.snapshot.paramMap.get('id');
  }

  close(): void {
    // Close the modal outlet
    this.router.navigate([{ outlets: { modal: null } }]);
  }
}

// Routes configuration
export const routes: Routes = [
  {
    path: 'user/:id',
    component: UserProfileModalComponent,
    outlet: 'modal'
  }
];

// Usage in component
import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-user-list',
  template: `
    <div>
      @for (user of users; track user.id) {
        <div>
          {{ user.name }}
          <button (click)="openUserModal(user.id)">View Profile</button>
        </div>
      }
    </div>
    
    <!-- Modal outlet -->
    <router-outlet name="modal"></router-outlet>
  `
})
export class UserListComponent {
  private router = inject(Router);
  
  users = [
    { id: 1, name: 'John Doe' },
    { id: 2, name: 'Jane Smith' }
  ];

  openUserModal(userId: number): void {
    this.router.navigate([{ outlets: { modal: ['user', userId] } }]);
  }
}
```

**Split View with Auxiliary Routes:**

```typescript
// master-detail.component.ts
import { Component } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-master-detail',
  standalone: true,
  imports: [CommonModule, RouterOutlet, RouterLink],
  template: `
    <div class="split-view">
      <!-- Master panel (primary outlet) -->
      <div class="master-panel">
        <h2>Products</h2>
        <ul>
          @for (product of products; track product.id) {
            <li>
              <a [routerLink]="[{ outlets: { detail: ['product', product.id] } }]">
                {{ product.name }}
              </a>
            </li>
          }
        </ul>
      </div>
      
      <!-- Detail panel (auxiliary outlet) -->
      <div class="detail-panel">
        <router-outlet name="detail"></router-outlet>
      </div>
    </div>
  `,
  styles: [`
    .split-view {
      display: flex;
      height: 100%;
      gap: 1px;
      background: #ddd;
    }
    .master-panel {
      flex: 0 0 300px;
      background: white;
      padding: 20px;
      overflow: auto;
    }
    .detail-panel {
      flex: 1;
      background: white;
      padding: 20px;
      overflow: auto;
    }
    ul {
      list-style: none;
      padding: 0;
    }
    li {
      padding: 8px;
      border-bottom: 1px solid #eee;
    }
    li a {
      color: #2196f3;
      text-decoration: none;
    }
  `]
})
export class MasterDetailComponent {
  products = [
    { id: 1, name: 'Product A' },
    { id: 2, name: 'Product B' },
    { id: 3, name: 'Product C' }
  ];
}

// product-detail.component.ts
import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  template: `
    <div>
      <button (click)="close()">Close</button>
      <h3>Product {{ productId }}</h3>
      <p>Product details go here...</p>
    </div>
  `
})
export class ProductDetailComponent {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  
  productId: string | null = null;

  ngOnInit() {
    this.productId = this.route.snapshot.paramMap.get('id');
  }

  close(): void {
    this.router.navigate([{ outlets: { detail: null } }]);
  }
}

// Routes
export const routes: Routes = [
  {
    path: 'products',
    component: MasterDetailComponent
  },
  {
    path: 'product/:id',
    component: ProductDetailComponent,
    outlet: 'detail'
  }
];
```

#### React: Equivalent Multi-Outlet Patterns

**React with Multiple Router Outlets:**

```tsx
// App.tsx - Multiple outlets simulation
import { BrowserRouter, Routes, Route, useNavigate, useSearchParams } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <Layout />
    </BrowserRouter>
  );
}

function Layout() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  
  const sidebarOpen = searchParams.get('sidebar') === 'true';
  const popupView = searchParams.get('popup');

  const openSidebar = () => setSearchParams({ sidebar: 'true' });
  const closeSidebar = () => setSearchParams({});
  const openChat = () => setSearchParams({ popup: 'chat' });
  const closePopup = () => setSearchParams({});

  return (
    <div className="layout">
      <header>
        <h1>My App</h1>
        <nav>
          <button onClick={() => navigate('/dashboard')}>Dashboard</button>
          <button onClick={openSidebar}>Open Sidebar</button>
          <button onClick={openChat}>Open Chat</button>
          <button onClick={() => { closeSidebar(); closePopup(); }}>Close All</button>
        </nav>
      </header>
      
      <div className="content">
        <main>
          <Routes>
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/products" element={<Products />} />
          </Routes>
        </main>
        
        {sidebarOpen && (
          <aside className="sidebar">
            <Sidebar onClose={closeSidebar} />
          </aside>
        )}
        
        {popupView && (
          <div className="popup-container">
            {popupView === 'chat' && <Chat onClose={closePopup} />}
            {popupView === 'notifications' && <Notifications onClose={closePopup} />}
          </div>
        )}
      </div>
    </div>
  );
}

// Modal with URL state
function UserList() {
  const [searchParams, setSearchParams] = useSearchParams();
  const modalUserId = searchParams.get('modal');

  const users = [
    { id: '1', name: 'John Doe' },
    { id: '2', name: 'Jane Smith' }
  ];

  const openModal = (userId: string) => {
    setSearchParams({ modal: userId });
  };

  const closeModal = () => {
    setSearchParams({});
  };

  return (
    <div>
      {users.map(user => (
        <div key={user.id}>
          {user.name}
          <button onClick={() => openModal(user.id)}>View Profile</button>
        </div>
      ))}
      
      {modalUserId && (
        <UserProfileModal userId={modalUserId} onClose={closeModal} />
      )}
    </div>
  );
}
```

#### Comparison: Auxiliary Routes

| Feature | Angular Auxiliary Routes | React Outlets |
|---------|------------------------|--------------|
| **Named Outlets** | ✅ Built-in router-outlet | Manual rendering |
| **URL Representation** | `/main(side:sidebar)` | Query params or state |
| **Multiple Outlets** | ✅ Unlimited | Manual management |
| **Deep Linking** | ✅ Full support | Requires custom logic |

**When to Use:**
- **Angular Auxiliary Routes:** Multiple independent views with full routing support
- **React:** Query params, conditional rendering, or layout composition

**Further Reading:**
- [Angular Secondary Routes](https://angular.dev/guide/routing/common-router-tasks#displaying-multiple-routes-in-named-outlets)
- [React Router](https://reactrouter.com/)

---

### 3. Route Animations (Transition Animations)

**Description:** Route animations provide smooth visual transitions between route changes using Angular's animation system. Create slide, fade, zoom, and custom transition effects.

#### Angular: Route Animation Examples

**Basic Route Animations:**

```typescript
// route-animations.ts
import { trigger, transition, style, query, animate, group, animateChild } from '@angular/animations';

export const slideInAnimation =
  trigger('routeAnimations', [
    // Slide from right
    transition('HomePage => AboutPage', [
      style({ position: 'relative' }),
      query(':enter, :leave', [
        style({
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%'
        })
      ], { optional: true }),
      query(':enter', [
        style({ left: '100%' })
      ], { optional: true }),
      query(':leave', animateChild(), { optional: true }),
      group([
        query(':leave', [
          animate('300ms ease-out', style({ left: '-100%' }))
        ], { optional: true }),
        query(':enter', [
          animate('300ms ease-out', style({ left: '0%' }))
        ], { optional: true }),
      ]),
    ]),
    
    // Slide from left (back navigation)
    transition('AboutPage => HomePage', [
      style({ position: 'relative' }),
      query(':enter, :leave', [
        style({
          position: 'absolute',
          top: 0,
          right: 0,
          width: '100%'
        })
      ], { optional: true }),
      query(':enter', [
        style({ right: '100%' })
      ], { optional: true }),
      query(':leave', animateChild(), { optional: true }),
      group([
        query(':leave', [
          animate('300ms ease-out', style({ right: '-100%' }))
        ], { optional: true }),
        query(':enter', [
          animate('300ms ease-out', style({ right: '0%' }))
        ], { optional: true }),
      ]),
    ]),
    
    // Fade transition
    transition('* <=> *', [
      style({ position: 'relative' }),
      query(':enter, :leave', [
        style({
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          opacity: 1
        })
      ], { optional: true }),
      query(':enter', [
        style({ opacity: 0 })
      ], { optional: true }),
      query(':leave', animateChild(), { optional: true }),
      group([
        query(':leave', [
          animate('200ms', style({ opacity: 0 }))
        ], { optional: true }),
        query(':enter', [
          animate('200ms', style({ opacity: 1 }))
        ], { optional: true }),
      ]),
    ])
  ]);

// Fade animation
export const fadeAnimation =
  trigger('fadeAnimation', [
    transition('* <=> *', [
      query(':enter', [
        style({ opacity: 0 })
      ], { optional: true }),
      query(':leave', [
        animate('200ms', style({ opacity: 0 }))
      ], { optional: true }),
      query(':enter', [
        animate('200ms', style({ opacity: 1 }))
      ], { optional: true })
    ])
  ]);

// Zoom animation
export const zoomAnimation =
  trigger('zoomAnimation', [
    transition('* <=> *', [
      query(':enter', [
        style({ transform: 'scale(0.8)', opacity: 0 })
      ], { optional: true }),
      query(':leave', [
        animate('200ms', style({ transform: 'scale(1.2)', opacity: 0 }))
      ], { optional: true }),
      query(':enter', [
        animate('300ms', style({ transform: 'scale(1)', opacity: 1 }))
      ], { optional: true })
    ])
  ]);
```

**App Component with Route Animations:**

```typescript
// app.component.ts
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ChildrenOutletContexts } from '@angular/router';
import { slideInAnimation } from './route-animations';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  template: `
    <div class="app">
      <nav>
        <a routerLink="/home">Home</a>
        <a routerLink="/about">About</a>
        <a routerLink="/contact">Contact</a>
      </nav>
      
      <!-- Apply animation to router outlet -->
      <div [@routeAnimations]="getRouteAnimationData()">
        <router-outlet></router-outlet>
      </div>
    </div>
  `,
  animations: [slideInAnimation],
  styles: [`
    .app {
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    nav {
      padding: 16px;
      background: #2196f3;
      display: flex;
      gap: 16px;
    }
    nav a {
      color: white;
      text-decoration: none;
      padding: 8px 16px;
      border-radius: 4px;
    }
    nav a:hover {
      background: rgba(255, 255, 255, 0.2);
    }
  `]
})
export class AppComponent {
  constructor(private contexts: ChildrenOutletContexts) {}

  getRouteAnimationData() {
    // Get animation state from route data
    return this.contexts.getContext('primary')?.route?.snapshot?.data?.['animation'];
  }
}

// Routes with animation state
import { Routes } from '@angular/router';
import { HomeComponent } from './home.component';
import { AboutComponent } from './about.component';
import { ContactComponent } from './contact.component';

export const routes: Routes = [
  {
    path: 'home',
    component: HomeComponent,
    data: { animation: 'HomePage' }
  },
  {
    path: 'about',
    component: AboutComponent,
    data: { animation: 'AboutPage' }
  },
  {
    path: 'contact',
    component: ContactComponent,
    data: { animation: 'ContactPage' }
  },
  {
    path: '',
    redirectTo: '/home',
    pathMatch: 'full'
  }
];
```

**Advanced Route Animations:**

```typescript
// advanced-animations.ts
import { trigger, transition, style, query, animate, group, stagger } from '@angular/animations';

// Slide with different directions
export const slideAnimation =
  trigger('slideAnimation', [
    // Slide up
    transition(':increment', [
      style({ position: 'relative', overflow: 'hidden' }),
      query(':enter, :leave', [
        style({
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%'
        })
      ], { optional: true }),
      query(':enter', [
        style({ transform: 'translateY(100%)' })
      ], { optional: true }),
      group([
        query(':leave', [
          animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ transform: 'translateY(-100%)' }))
        ], { optional: true }),
        query(':enter', [
          animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ transform: 'translateY(0%)' }))
        ], { optional: true }),
      ]),
    ]),
    
    // Slide down
    transition(':decrement', [
      style({ position: 'relative', overflow: 'hidden' }),
      query(':enter, :leave', [
        style({
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%'
        })
      ], { optional: true }),
      query(':enter', [
        style({ transform: 'translateY(-100%)' })
      ], { optional: true }),
      group([
        query(':leave', [
          animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ transform: 'translateY(100%)' }))
        ], { optional: true }),
        query(':enter', [
          animate('400ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({ transform: 'translateY(0%)' }))
        ], { optional: true }),
      ]),
    ]),
  ]);

// Staggered list animation
export const listAnimation =
  trigger('listAnimation', [
    transition('* <=> *', [
      query(':enter', [
        style({ opacity: 0, transform: 'translateY(20px)' }),
        stagger(50, [
          animate('300ms ease-out', style({ opacity: 1, transform: 'translateY(0)' }))
        ])
      ], { optional: true })
    ])
  ]);

// Complex page transition
export const complexPageAnimation =
  trigger('complexPageAnimation', [
    transition('* <=> *', [
      // Set container styles
      style({ position: 'relative', overflow: 'hidden' }),
      
      // Position both pages
      query(':enter, :leave', [
        style({
          position: 'absolute',
          top: 0,
          left: 0,
          width: '100%',
          height: '100%'
        })
      ], { optional: true }),
      
      // Enter page starts scaled down and transparent
      query(':enter', [
        style({
          transform: 'scale(0.9)',
          opacity: 0,
          filter: 'blur(10px)'
        })
      ], { optional: true }),
      
      // Animate both pages
      group([
        // Leave page: zoom out and fade
        query(':leave', [
          animate('500ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({
            transform: 'scale(1.1)',
            opacity: 0,
            filter: 'blur(10px)'
          }))
        ], { optional: true }),
        
        // Enter page: zoom in and fade in
        query(':enter', [
          animate('500ms 100ms cubic-bezier(0.4, 0.0, 0.2, 1)', style({
            transform: 'scale(1)',
            opacity: 1,
            filter: 'blur(0)'
          }))
        ], { optional: true }),
      ]),
    ])
  ]);
```

**Route Animation with Page Numbers:**

```typescript
// stepper.component.ts
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ChildrenOutletContexts } from '@angular/router';
import { slideAnimation } from './advanced-animations';

@Component({
  selector: 'app-stepper',
  standalone: true,
  imports: [RouterOutlet],
  template: `
    <div class="stepper">
      <div class="steps">
        <div class="step" [class.active]="currentStep === 1">Step 1</div>
        <div class="step" [class.active]="currentStep === 2">Step 2</div>
        <div class="step" [class.active]="currentStep === 3">Step 3</div>
      </div>
      
      <div class="content" [@slideAnimation]="getStepNumber()">
        <router-outlet></router-outlet>
      </div>
      
      <div class="navigation">
        <button (click)="previousStep()" [disabled]="currentStep === 1">Previous</button>
        <button (click)="nextStep()" [disabled]="currentStep === 3">Next</button>
      </div>
    </div>
  `,
  animations: [slideAnimation],
  styles: [`
    .stepper {
      padding: 20px;
    }
    .steps {
      display: flex;
      justify-content: center;
      gap: 20px;
      margin-bottom: 40px;
    }
    .step {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background: #ddd;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
    }
    .step.active {
      background: #2196f3;
      color: white;
    }
    .content {
      min-height: 400px;
      position: relative;
      overflow: hidden;
    }
    .navigation {
      display: flex;
      justify-content: center;
      gap: 16px;
      margin-top: 20px;
    }
  `]
})
export class StepperComponent {
  currentStep = 1;

  constructor(private contexts: ChildrenOutletContexts) {}

  getStepNumber() {
    return this.contexts.getContext('primary')?.route?.snapshot?.data?.['step'] || 0;
  }

  nextStep() {
    if (this.currentStep < 3) {
      this.currentStep++;
      // Navigate to next step
    }
  }

  previousStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
      // Navigate to previous step
    }
  }
}

// Routes with step numbers
export const stepperRoutes: Routes = [
  {
    path: 'step1',
    component: Step1Component,
    data: { step: 1 }
  },
  {
    path: 'step2',
    component: Step2Component,
    data: { step: 2 }
  },
  {
    path: 'step3',
    component: Step3Component,
    data: { step: 3 }
  }
];
```

#### React: Equivalent Animation Libraries

**Framer Motion with React Router:**

```tsx
// AnimatedRoutes.tsx
import { motion, AnimatePresence } from 'framer-motion';
import { Routes, Route, useLocation } from 'react-router-dom';

function AnimatedRoutes() {
  const location = useLocation();

  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        <Route path="/home" element={
          <motion.div
            initial={{ opacity: 0, x: 100 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -100 }}
            transition={{ duration: 0.3 }}
          >
            <Home />
          </motion.div>
        } />
        
        <Route path="/about" element={
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 1.1 }}
            transition={{ duration: 0.3 }}
          >
            <About />
          </motion.div>
        } />
      </Routes>
    </AnimatePresence>
  );
}

// Reusable page transition component
function PageTransition({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
      transition={{ duration: 0.3 }}
    >
      {children}
    </motion.div>
  );
}

// Usage
<Route path="/home" element={<PageTransition><Home /></PageTransition>} />
```

**React Transition Group:**

```tsx
import { CSSTransition, TransitionGroup } from 'react-transition-group';
import { Routes, Route, useLocation } from 'react-router-dom';
import './page-transitions.css';

function AnimatedApp() {
  const location = useLocation();

  return (
    <TransitionGroup>
      <CSSTransition
        key={location.key}
        classNames="page"
        timeout={300}
      >
        <Routes location={location}>
          <Route path="/home" element={<Home />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </CSSTransition>
    </TransitionGroup>
  );
}

// page-transitions.css
/*
.page-enter {
  opacity: 0;
  transform: translateX(100%);
}
.page-enter-active {
  opacity: 1;
  transform: translateX(0);
  transition: all 300ms ease-out;
}
.page-exit {
  opacity: 1;
  transform: translateX(0);
}
.page-exit-active {
  opacity: 0;
  transform: translateX(-100%);
  transition: all 300ms ease-out;
}
*/
```

#### Comparison: Route Animations

| Feature | Angular Animations | React Libraries |
|---------|------------------|----------------|
| **Built-in** | ✅ @angular/animations | External (framer-motion) |
| **Declarative** | ✅ Animation triggers | JSX-based |
| **Route Data** | ✅ Animation state in routes | Location-based |
| **Complex Sequences** | ✅ query, stagger, group | Custom logic needed |

**When to Use:**
- **Angular:** Built-in animation system with route data integration
- **React:** Framer Motion or React Transition Group

**Further Reading:**
- [Angular Route Animations](https://angular.dev/guide/animations/route-animations)
- [Framer Motion](https://www.framer.com/motion/)

---

### 4. Matrix Parameters (URL Segments)

**Description:** Matrix parameters (also called matrix URL notation) allow optional parameters within URL segments, not just at the end. Perfect for filters, view modes, and segment-specific metadata.

#### Angular: Matrix Parameters Examples

**Basic Matrix Parameters:**

```typescript
// product-list.component.ts
import { Component, inject } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';

interface Product {
  id: number;
  name: string;
  category: string;
  price: number;
}

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="filters">
      <h3>Filters</h3>
      <label>
        <input type="checkbox" [(ngModel)]="showInStock" (change)="applyFilters()" />
        In Stock Only
      </label>
      <label>
        Sort:
        <select [(ngModel)]="sortBy" (change)="applyFilters()">
          <option value="name">Name</option>
          <option value="price">Price</option>
        </select>
      </label>
      <label>
        View:
        <select [(ngModel)]="viewMode" (change)="applyFilters()">
          <option value="grid">Grid</option>
          <option value="list">List</option>
        </select>
      </label>
    </div>
    
    <div class="products" [class.grid-view]="viewMode === 'grid'" [class.list-view]="viewMode === 'list'">
      @for (product of filteredProducts; track product.id) {
        <div class="product">
          <h4>{{ product.name }}</h4>
          <p>{{ product.category }}</p>
          <p>\${{ product.price }}</p>
        </div>
      }
    </div>
    
    <div class="current-url">
      Current URL: {{ router.url }}
    </div>
  `,
  styles: [`
    .filters {
      padding: 16px;
      background: #f5f5f5;
      margin-bottom: 20px;
    }
    .filters label {
      display: block;
      margin: 8px 0;
    }
    .products {
      padding: 20px;
    }
    .grid-view {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 16px;
    }
    .list-view .product {
      border: 1px solid #ddd;
      padding: 16px;
      margin-bottom: 8px;
    }
    .product {
      border: 1px solid #ddd;
      padding: 16px;
      border-radius: 4px;
    }
  `]
})
export class ProductListComponent {
  router = inject(Router);
  private route = inject(ActivatedRoute);
  
  products: Product[] = [
    { id: 1, name: 'Product A', category: 'Electronics', price: 299 },
    { id: 2, name: 'Product B', category: 'Clothing', price: 49 },
    { id: 3, name: 'Product C', category: 'Books', price: 19 }
  ];
  
  filteredProducts = [...this.products];
  showInStock = false;
  sortBy = 'name';
  viewMode = 'grid';

  ngOnInit() {
    // Read matrix parameters from route
    const params = this.route.snapshot.params;
    this.showInStock = params['inStock'] === 'true';
    this.sortBy = params['sort'] || 'name';
    this.viewMode = params['view'] || 'grid';
    
    this.applyFiltersLogic();
  }

  applyFilters() {
    // Navigate with matrix parameters
    // URL will be: /products;inStock=true;sort=price;view=list
    this.router.navigate(['/products', {
      inStock: this.showInStock,
      sort: this.sortBy,
      view: this.viewMode
    }]);
    
    this.applyFiltersLogic();
  }

  private applyFiltersLogic() {
    this.filteredProducts = [...this.products];
    
    // Sort
    if (this.sortBy === 'price') {
      this.filteredProducts.sort((a, b) => a.price - b.price);
    } else {
      this.filteredProducts.sort((a, b) => a.name.localeCompare(b.name));
    }
  }
}
```

**Matrix Parameters in Nested Routes:**

```typescript
// Routes with matrix parameters
export const routes: Routes = [
  {
    path: 'products',
    component: ProductListComponent
  },
  {
    path: 'products/:id',
    component: ProductDetailComponent,
    children: [
      {
        path: 'reviews',
        component: ReviewsComponent
      },
      {
        path: 'specifications',
        component: SpecificationsComponent
      }
    ]
  }
];

// Navigation with matrix parameters at different levels
// URL: /products;category=electronics/123;view=detailed/reviews;sort=recent

@Component({
  selector: 'app-navigation-demo',
  template: `
    <button (click)="navigateToFilteredProducts()">
      Filtered Products
    </button>
    <button (click)="navigateToProductDetail()">
      Product Detail
    </button>
    <button (click)="navigateToReviews()">
      Recent Reviews
    </button>
  `
})
export class NavigationDemoComponent {
  private router = inject(Router);

  // Navigate to products with filters
  navigateToFilteredProducts() {
    this.router.navigate(['/products', {
      category: 'electronics',
      inStock: true,
      maxPrice: 500
    }]);
    // URL: /products;category=electronics;inStock=true;maxPrice=500
  }

  // Navigate to product detail with view mode
  navigateToProductDetail() {
    this.router.navigate(['/products', 123, {
      view: 'detailed',
      highlight: 'features'
    }]);
    // URL: /products/123;view=detailed;highlight=features
  }

  // Navigate to reviews with sorting
  navigateToReviews() {
    this.router.navigate(['/products', 123, {
      view: 'detailed'
    }, 'reviews', {
      sort: 'recent',
      rating: 5
    }]);
    // URL: /products/123;view=detailed/reviews;sort=recent;rating=5
  }
}
```

**Reading Matrix Parameters:**

```typescript
// matrix-params.service.ts
import { Injectable, inject } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class MatrixParamsService {
  private route = inject(ActivatedRoute);

  // Get matrix parameters as observable
  getParams(): Observable<Params> {
    return this.route.params;
  }

  // Get specific parameter
  getParam(key: string): Observable<string | null> {
    return this.route.params.pipe(
      map(params => params[key] || null)
    );
  }

  // Get all matrix parameters from snapshot
  getSnapshot(): Params {
    return this.route.snapshot.params;
  }

  // Get matrix parameters from parent route
  getParentParams(): Params {
    return this.route.parent?.snapshot.params || {};
  }
}

// Using the service
@Component({
  selector: 'app-product-detail',
  template: `
    <div>
      <h2>Product {{ productId }}</h2>
      <p>View Mode: {{ viewMode }}</p>
      <p>Highlight: {{ highlight }}</p>
    </div>
  `
})
export class ProductDetailComponent {
  private matrixParamsService = inject(MatrixParamsService);
  
  productId: string | null = null;
  viewMode: string = 'normal';
  highlight: string = 'none';

  ngOnInit() {
    // Subscribe to parameter changes
    this.matrixParamsService.getParams().subscribe(params => {
      this.productId = params['id'];
      this.viewMode = params['view'] || 'normal';
      this.highlight = params['highlight'] || 'none';
    });
  }
}
```

**Matrix Parameters with Auxiliary Routes:**

```typescript
// Combining matrix parameters with auxiliary routes
@Component({
  selector: 'app-advanced-navigation',
  template: `
    <button (click)="openSidebarWithFilters()">
      Open Sidebar with Filters
    </button>
  `
})
export class AdvancedNavigationComponent {
  private router = inject(Router);

  openSidebarWithFilters() {
    // Navigate to main content and sidebar with matrix parameters
    this.router.navigate([
      'products', {
        category: 'electronics',
        inStock: true
      },
      {
        outlets: {
          sidebar: ['filters', {
            priceRange: '0-500',
            sort: 'price'
          }]
        }
      }
    ]);
    // URL: /products;category=electronics;inStock=true(sidebar:filters;priceRange=0-500;sort=price)
  }
}
```

#### React: Equivalent Query Parameters

**React Router with Query Params:**

```tsx
// ProductList.tsx
import { useSearchParams, useNavigate } from 'react-router-dom';

function ProductList() {
  const [searchParams, setSearchParams] = useSearchParams();
  const navigate = useNavigate();
  
  // Read parameters
  const showInStock = searchParams.get('inStock') === 'true';
  const sortBy = searchParams.get('sort') || 'name';
  const viewMode = searchParams.get('view') || 'grid';
  
  const applyFilters = (inStock: boolean, sort: string, view: string) => {
    // Update URL query parameters
    setSearchParams({
      inStock: inStock.toString(),
      sort,
      view
    });
    // URL: /products?inStock=true&sort=price&view=list
  };

  return (
    <div>
      <div className="filters">
        <label>
          <input
            type="checkbox"
            checked={showInStock}
            onChange={(e) => applyFilters(e.target.checked, sortBy, viewMode)}
          />
          In Stock Only
        </label>
        
        <select
          value={sortBy}
          onChange={(e) => applyFilters(showInStock, e.target.value, viewMode)}
        >
          <option value="name">Name</option>
          <option value="price">Price</option>
        </select>
        
        <select
          value={viewMode}
          onChange={(e) => applyFilters(showInStock, sortBy, e.target.value)}
        >
          <option value="grid">Grid</option>
          <option value="list">List</option>
        </select>
      </div>
      
      <div className={viewMode === 'grid' ? 'grid-view' : 'list-view'}>
        {/* Product list */}
      </div>
    </div>
  );
}

// Custom hook for query parameters
function useQueryParams() {
  const [searchParams, setSearchParams] = useSearchParams();
  
  const getParam = (key: string, defaultValue?: string) => {
    return searchParams.get(key) || defaultValue || null;
  };
  
  const setParam = (key: string, value: string) => {
    const newParams = new URLSearchParams(searchParams);
    newParams.set(key, value);
    setSearchParams(newParams);
  };
  
  const setParams = (params: Record<string, string>) => {
    setSearchParams(params);
  };
  
  return { getParam, setParam, setParams, searchParams };
}
```

#### Comparison: Matrix Parameters

| Feature | Angular Matrix Params | React Query Params |
|---------|---------------------|------------------|
| **URL Format** | `/path;key=value` | `/path?key=value` |
| **Segment-specific** | ✅ Per segment | Global to URL |
| **Built-in Support** | ✅ Router.navigate() | useSearchParams |
| **Auxiliary Routes** | ✅ Combined support | Separate management |

**When to Use:**
- **Angular Matrix Params:** Segment-specific parameters, complex multi-level routing
- **React:** Query parameters with useSearchParams

**Further Reading:**
- [Angular Matrix URL Notation](https://angular.dev/guide/routing/common-router-tasks#optional-parameters)
- [React Router Search Params](https://reactrouter.com/en/main/hooks/use-search-params)

---

### 5. Title Strategy (Custom Page Titles)

**Description:** Title Strategy allows custom page title resolution from route data. Automatically set browser tab titles, implement breadcrumb-style titles, and integrate with SEO metadata.

#### Angular: Title Strategy Examples

**Default Title Strategy:**

```typescript
// Routes with title
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'home',
    component: HomeComponent,
    title: 'Home - My App'
  },
  {
    path: 'products',
    component: ProductsComponent,
    title: 'Products - My App'
  },
  {
    path: 'products/:id',
    component: ProductDetailComponent,
    title: 'Product Detail - My App'
  },
  {
    path: 'about',
    component: AboutComponent,
    title: 'About Us - My App'
  }
];

// app.config.ts - Default title strategy is automatic
import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes)
  ]
};
```

**Custom Title Strategy:**

```typescript
// custom-title-strategy.ts
import { Injectable, inject } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { RouterStateSnapshot, TitleStrategy } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class CustomTitleStrategy extends TitleStrategy {
  private readonly title = inject(Title);
  private readonly appName = 'My Awesome App';

  override updateTitle(snapshot: RouterStateSnapshot): void {
    // Get title from route data
    const title = this.buildTitle(snapshot);
    
    if (title) {
      // Add app name suffix
      this.title.setTitle(`${title} | ${this.appName}`);
    } else {
      // Default title
      this.title.setTitle(this.appName);
    }
  }
}

// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, TitleStrategy } from '@angular/router';
import { routes } from './app.routes';
import { CustomTitleStrategy } from './custom-title-strategy';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    { provide: TitleStrategy, useClass: CustomTitleStrategy }
  ]
};
```

**Advanced Title Strategy with Breadcrumbs:**

```typescript
// breadcrumb-title-strategy.ts
import { Injectable, inject } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { RouterStateSnapshot, TitleStrategy, ActivatedRouteSnapshot } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class BreadcrumbTitleStrategy extends TitleStrategy {
  private readonly title = inject(Title);

  override updateTitle(snapshot: RouterStateSnapshot): void {
    // Build breadcrumb-style title
    const titles = this.collectTitles(snapshot.root);
    
    if (titles.length > 0) {
      // Join with ' > ' separator
      const breadcrumbTitle = titles.join(' > ');
      this.title.setTitle(breadcrumbTitle);
    }
  }

  private collectTitles(route: ActivatedRouteSnapshot): string[] {
    const titles: string[] = [];
    
    // Traverse route tree
    let current: ActivatedRouteSnapshot | null = route;
    while (current) {
      // Get title from route data
      if (current.data['title']) {
        titles.unshift(current.data['title']);
      }
      
      // Move to first child
      current = current.firstChild;
    }
    
    return titles;
  }
}

// Routes with nested titles
export const routes: Routes = [
  {
    path: 'dashboard',
    data: { title: 'Dashboard' },
    component: DashboardComponent,
    children: [
      {
        path: 'analytics',
        data: { title: 'Analytics' },
        component: AnalyticsComponent
      },
      {
        path: 'reports',
        data: { title: 'Reports' },
        component: ReportsComponent,
        children: [
          {
            path: ':id',
            data: { title: 'Report Details' },
            component: ReportDetailComponent
          }
        ]
      }
    ]
  }
];
// Resulting titles:
// /dashboard -> "Dashboard"
// /dashboard/analytics -> "Dashboard > Analytics"
// /dashboard/reports/123 -> "Dashboard > Reports > Report Details"
```

**Dynamic Title with Route Parameters:**

```typescript
// dynamic-title-strategy.ts
import { Injectable, inject } from '@angular/core';
import { Title } from '@angular/platform-browser';
import { RouterStateSnapshot, TitleStrategy, ActivatedRouteSnapshot } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class DynamicTitleStrategy extends TitleStrategy {
  private readonly title = inject(Title);

  override updateTitle(snapshot: RouterStateSnapshot): void {
    const title = this.buildTitle(snapshot);
    
    if (title) {
      // Replace placeholders with route parameters
      const resolvedTitle = this.resolvePlaceholders(title, snapshot.root);
      this.title.setTitle(resolvedTitle);
    }
  }

  private resolvePlaceholders(title: string, route: ActivatedRouteSnapshot): string {
    let resolvedTitle = title;
    
    // Collect all route parameters
    const params = this.collectParams(route);
    
    // Replace placeholders like :id with actual values
    Object.entries(params).forEach(([key, value]) => {
      resolvedTitle = resolvedTitle.replace(`:${key}`, value);
    });
    
    return resolvedTitle;
  }

  private collectParams(route: ActivatedRouteSnapshot): { [key: string]: string } {
    const params: { [key: string]: string } = {};
    
    let current: ActivatedRouteSnapshot | null = route;
    while (current) {
      // Merge parameters from all route levels
      Object.assign(params, current.params);
      current = current.firstChild;
    }
    
    return params;
  }
}

// Routes with parameter placeholders
export const routes: Routes = [
  {
    path: 'users/:id',
    component: UserProfileComponent,
    title: 'User :id Profile'
  },
  {
    path: 'products/:category/:id',
    component: ProductDetailComponent,
    title: ':category - Product :id'
  }
];
// /users/john -> "User john Profile"
// /products/electronics/laptop -> "electronics - Product laptop"
```

**Title Strategy with Resolvers:**

```typescript
// user-title.resolver.ts
import { inject } from '@angular/core';
import { ResolveFn, ActivatedRouteSnapshot } from '@angular/router';
import { UserService } from './user.service';
import { map } from 'rxjs/operators';

export const userTitleResolver: ResolveFn<string> = (route: ActivatedRouteSnapshot) => {
  const userService = inject(UserService);
  const userId = route.paramMap.get('id');
  
  if (!userId) {
    return 'User Profile';
  }
  
  // Fetch user data and return name for title
  return userService.getUser(userId).pipe(
    map(user => `${user.firstName} ${user.lastName} - Profile`)
  );
};

// Routes with title resolver
export const routes: Routes = [
  {
    path: 'users/:id',
    component: UserProfileComponent,
    title: userTitleResolver
  }
];

// More complex resolver with multiple data sources
export const productTitleResolver: ResolveFn<string> = (route: ActivatedRouteSnapshot) => {
  const productService = inject(ProductService);
  const productId = route.paramMap.get('id');
  
  if (!productId) {
    return 'Product Details';
  }
  
  return productService.getProduct(productId).pipe(
    map(product => `${product.name} - $${product.price}`)
  );
};

// app.config.ts with custom title strategy
import { provideRouter, TitleStrategy } from '@angular/router';
import { CustomTitleStrategy } from './custom-title-strategy';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    { provide: TitleStrategy, useClass: CustomTitleStrategy }
  ]
};
```

**SEO-Enhanced Title Strategy:**

```typescript
// seo-title-strategy.ts
import { Injectable, inject } from '@angular/core';
import { Title, Meta } from '@angular/platform-browser';
import { RouterStateSnapshot, TitleStrategy } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class SeoTitleStrategy extends TitleStrategy {
  private readonly title = inject(Title);
  private readonly meta = inject(Meta);

  override updateTitle(snapshot: RouterStateSnapshot): void {
    // Get title from route
    const pageTitle = this.buildTitle(snapshot);
    
    // Get SEO data from route data
    const route = snapshot.root;
    const seoData = this.getSeoData(route);
    
    // Set page title
    if (pageTitle) {
      this.title.setTitle(pageTitle);
      
      // Update meta tags
      this.meta.updateTag({ property: 'og:title', content: pageTitle });
      this.meta.updateTag({ name: 'twitter:title', content: pageTitle });
    }
    
    // Update description if provided
    if (seoData.description) {
      this.meta.updateTag({ name: 'description', content: seoData.description });
      this.meta.updateTag({ property: 'og:description', content: seoData.description });
      this.meta.updateTag({ name: 'twitter:description', content: seoData.description });
    }
    
    // Update keywords if provided
    if (seoData.keywords) {
      this.meta.updateTag({ name: 'keywords', content: seoData.keywords.join(', ') });
    }
    
    // Update image if provided
    if (seoData.image) {
      this.meta.updateTag({ property: 'og:image', content: seoData.image });
      this.meta.updateTag({ name: 'twitter:image', content: seoData.image });
    }
  }

  private getSeoData(route: any): any {
    let data = {};
    let current = route;
    
    while (current) {
      if (current.data && current.data['seo']) {
        data = { ...data, ...current.data['seo'] };
      }
      current = current.firstChild;
    }
    
    return data;
  }
}

// Routes with SEO metadata
export const routes: Routes = [
  {
    path: 'products/:id',
    component: ProductDetailComponent,
    title: 'Product Details',
    data: {
      seo: {
        description: 'View detailed information about this product',
        keywords: ['product', 'shop', 'buy'],
        image: 'https://example.com/product-image.jpg'
      }
    }
  }
];
```

#### React: Equivalent Title Management

**React Helmet for Dynamic Titles:**

```tsx
// ProductDetail.tsx
import { Helmet } from 'react-helmet-async';
import { useParams } from 'react-router-dom';

function ProductDetail() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);

  useEffect(() => {
    // Fetch product data
    fetchProduct(id).then(setProduct);
  }, [id]);

  if (!product) return <div>Loading...</div>;

  return (
    <>
      <Helmet>
        <title>{product.name} - My Store</title>
        <meta name="description" content={product.description} />
        <meta property="og:title" content={product.name} />
        <meta property="og:description" content={product.description} />
        <meta property="og:image" content={product.image} />
      </Helmet>
      
      <div>
        <h1>{product.name}</h1>
        <p>{product.description}</p>
      </div>
    </>
  );
}

// App with HelmetProvider
import { HelmetProvider } from 'react-helmet-async';

function App() {
  return (
    <HelmetProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/products/:id" element={<ProductDetail />} />
        </Routes>
      </BrowserRouter>
    </HelmetProvider>
  );
}
```

**Custom Hook for Title Management:**

```tsx
// useDocumentTitle.ts
import { useEffect } from 'react';

export function useDocumentTitle(title: string, suffix = ' | My App') {
  useEffect(() => {
    const previousTitle = document.title;
    document.title = title + suffix;
    
    return () => {
      document.title = previousTitle;
    };
  }, [title, suffix]);
}

// Usage
function HomePage() {
  useDocumentTitle('Home');
  
  return <div>Home Page</div>;
}

function ProductPage() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  
  useDocumentTitle(product ? product.name : 'Loading...');
  
  return <div>{product?.name}</div>;
}
```

#### Comparison: Title Strategy

| Feature | Angular Title Strategy | React Helmet |
|---------|----------------------|-------------|
| **Built-in** | ✅ TitleStrategy | External library |
| **Route Integration** | ✅ Route data & resolvers | Component-level |
| **Custom Logic** | ✅ Override updateTitle | Custom hooks |
| **SEO Meta Tags** | Meta service | Helmet meta tags |

**When to Use:**
- **Angular:** TitleStrategy with route data and resolvers
- **React:** React Helmet Async or custom hooks

**Further Reading:**
- [Angular Title Strategy](https://angular.dev/api/router/TitleStrategy)
- [React Helmet Async](https://github.com/staylor/react-helmet-async)

---

### 6. withComponentInputBinding (Route Params as Inputs)

**Description:** withComponentInputBinding (Angular 16+) automatically binds route parameters, query parameters, and data to component inputs. Eliminates manual ActivatedRoute subscription boilerplate.

#### Angular: withComponentInputBinding Examples

**Basic Input Binding:**

```typescript
// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(
      routes,
      withComponentInputBinding() // Enable input binding
    )
  ]
};

// user-profile.component.ts
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="profile">
      <h2>User Profile</h2>
      <p>User ID: {{ id }}</p>
      <p>Tab: {{ tab }}</p>
      <p>Query Search: {{ search }}</p>
    </div>
  `
})
export class UserProfileComponent {
  // Route parameters automatically bound to inputs
  @Input() id?: string; // From route param :id
  @Input() tab?: string; // From route param :tab
  @Input() search?: string; // From query param ?search=...
}

// Routes
export const routes: Routes = [
  {
    path: 'users/:id/:tab',
    component: UserProfileComponent
  }
];

// Navigate to /users/123/settings?search=john
// Component receives: id="123", tab="settings", search="john"
```

**Input Transforms:**

```typescript
// product-detail.component.ts
import { Component, Input, numberAttribute, booleanAttribute } from '@angular/core';

@Component({
  selector: 'app-product-detail',
  standalone: true,
  template: `
    <div>
      <h2>Product {{ id }}</h2>
      <p>Price: ${{ price }}</p>
      <p>Featured: {{ featured ? 'Yes' : 'No' }}</p>
      <p>Category: {{ category }}</p>
    </div>
  `
})
export class ProductDetailComponent {
  // Transform route param to number
  @Input({ transform: numberAttribute }) id?: number;
  
  // Transform query param to number
  @Input({ transform: numberAttribute }) price?: number;
  
  // Transform query param to boolean
  @Input({ transform: booleanAttribute }) featured?: boolean;
  
  // String param (no transform)
  @Input() category?: string;
}

// Routes
export const routes: Routes = [
  {
    path: 'products/:id',
    component: ProductDetailComponent
  }
];

// Navigate to /products/42?price=299&featured=true&category=electronics
// Component receives: id=42 (number), price=299 (number), featured=true (boolean), category="electronics"
```

**Route Data as Input:**

```typescript
// page-with-data.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-page-with-data',
  standalone: true,
  template: `
    <div>
      <h2>{{ pageTitle }}</h2>
      <p>{{ pageDescription }}</p>
      <p>Show Sidebar: {{ showSidebar ? 'Yes' : 'No' }}</p>
    </div>
  `
})
export class PageWithDataComponent {
  // Route data automatically bound to inputs
  @Input() pageTitle?: string;
  @Input() pageDescription?: string;
  @Input() showSidebar?: boolean;
}

// Routes with data
export const routes: Routes = [
  {
    path: 'about',
    component: PageWithDataComponent,
    data: {
      pageTitle: 'About Us',
      pageDescription: 'Learn more about our company',
      showSidebar: true
    }
  },
  {
    path: 'contact',
    component: PageWithDataComponent,
    data: {
      pageTitle: 'Contact',
      pageDescription: 'Get in touch with us',
      showSidebar: false
    }
  }
];
```

**Complete Example with All Input Types:**

```typescript
// advanced-component.component.ts
import { Component, Input, OnInit, numberAttribute, booleanAttribute } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-advanced-component',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="container">
      <h2>Advanced Component</h2>
      
      <section>
        <h3>Route Parameters</h3>
        <p>ID: {{ id }} (type: {{ typeof id }})</p>
        <p>Slug: {{ slug }}</p>
      </section>
      
      <section>
        <h3>Query Parameters</h3>
        <p>Page: {{ page }} (type: {{ typeof page }})</p>
        <p>Sort: {{ sort }}</p>
        <p>Descending: {{ desc ? 'Yes' : 'No' }}</p>
      </section>
      
      <section>
        <h3>Route Data</h3>
        <p>Title: {{ title }}</p>
        <p>Category: {{ category }}</p>
        <p>Featured: {{ featured ? 'Yes' : 'No' }}</p>
      </section>
      
      <section>
        <h3>Matrix Parameters</h3>
        <p>View: {{ view }}</p>
        <p>Filter: {{ filter }}</p>
      </section>
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
    }
    section {
      margin: 20px 0;
      padding: 16px;
      background: #f5f5f5;
      border-radius: 4px;
    }
    h3 {
      margin-top: 0;
      color: #2196f3;
    }
  `]
})
export class AdvancedComponent implements OnInit {
  // Route parameters
  @Input({ transform: numberAttribute }) id?: number;
  @Input() slug?: string;
  
  // Query parameters
  @Input({ transform: numberAttribute }) page?: number;
  @Input() sort?: string;
  @Input({ transform: booleanAttribute }) desc?: boolean;
  
  // Route data
  @Input() title?: string;
  @Input() category?: string;
  @Input({ transform: booleanAttribute }) featured?: boolean;
  
  // Matrix parameters
  @Input() view?: string;
  @Input() filter?: string;
  
  typeof = typeof; // For template

  ngOnInit() {
    console.log('Component Inputs:', {
      id: this.id,
      slug: this.slug,
      page: this.page,
      sort: this.sort,
      desc: this.desc,
      title: this.title,
      category: this.category,
      featured: this.featured,
      view: this.view,
      filter: this.filter
    });
  }
}

// Routes
export const routes: Routes = [
  {
    path: 'items/:id/:slug',
    component: AdvancedComponent,
    data: {
      title: 'Item Details',
      category: 'Products',
      featured: true
    }
  }
];

// Navigation example
@Component({
  selector: 'app-navigation',
  template: `
    <button (click)="navigateToItem()">View Item</button>
  `
})
export class NavigationComponent {
  private router = inject(Router);

  navigateToItem() {
    this.router.navigate(
      ['/items', 42, 'awesome-product', { view: 'detailed', filter: 'new' }],
      { queryParams: { page: 2, sort: 'price', desc: true } }
    );
    // URL: /items/42/awesome-product;view=detailed;filter=new?page=2&sort=price&desc=true
    // Component receives all parameters as typed inputs
  }
}
```

**Comparison with Traditional Approach:**

```typescript
// WITHOUT withComponentInputBinding (old approach)
@Component({
  selector: 'app-old-way',
  template: `<div>User {{ userId }}</div>`
})
export class OldWayComponent implements OnInit {
  private route = inject(ActivatedRoute);
  userId?: string;

  ngOnInit() {
    // Manual subscription to route params
    this.route.params.subscribe(params => {
      this.userId = params['id'];
    });
    
    // Or snapshot (no updates)
    this.userId = this.route.snapshot.params['id'];
  }
}

// WITH withComponentInputBinding (new approach)
@Component({
  selector: 'app-new-way',
  template: `<div>User {{ id }}</div>`
})
export class NewWayComponent {
  @Input() id?: string; // Automatically bound, reactive to changes
}
```

**Input Binding with Resolvers:**

```typescript
// user.resolver.ts
import { inject } from '@angular/core';
import { ResolveFn } from '@angular/router';
import { UserService } from './user.service';

export interface User {
  id: number;
  name: string;
  email: string;
}

export const userResolver: ResolveFn<User> = (route) => {
  const userService = inject(UserService);
  const userId = route.paramMap.get('id');
  return userService.getUser(Number(userId));
};

// user-profile.component.ts
@Component({
  selector: 'app-user-profile',
  standalone: true,
  template: `
    <div>
      <h2>{{ user?.name }}</h2>
      <p>Email: {{ user?.email }}</p>
      <p>User ID from route: {{ id }}</p>
    </div>
  `
})
export class UserProfileComponent {
  @Input() id?: string; // From route param
  @Input() user?: User; // From resolver
}

// Routes with resolver
export const routes: Routes = [
  {
    path: 'users/:id',
    component: UserProfileComponent,
    resolve: {
      user: userResolver
    }
  }
];
```

#### React: Equivalent Hook-Based Routing

**React Router Hooks:**

```tsx
// UserProfile.tsx
import { useParams, useSearchParams } from 'react-router-dom';

interface RouteParams {
  id: string;
  tab: string;
}

function UserProfile() {
  // Get route parameters
  const { id, tab } = useParams<RouteParams>();
  
  // Get query parameters
  const [searchParams] = useSearchParams();
  const search = searchParams.get('search');
  
  // Convert to number if needed
  const userId = id ? Number(id) : undefined;

  return (
    <div className="profile">
      <h2>User Profile</h2>
      <p>User ID: {userId}</p>
      <p>Tab: {tab}</p>
      <p>Query Search: {search}</p>
    </div>
  );
}

// Custom hook for typed parameters
function useTypedParams<T>() {
  const params = useParams();
  return params as T;
}

function useQueryParam(key: string, defaultValue?: string): string | null {
  const [searchParams] = useSearchParams();
  return searchParams.get(key) || defaultValue || null;
}

function useNumberQueryParam(key: string, defaultValue?: number): number | null {
  const value = useQueryParam(key);
  return value ? Number(value) : defaultValue || null;
}

// Usage with custom hooks
function ProductDetail() {
  const { id } = useTypedParams<{ id: string }>();
  const price = useNumberQueryParam('price');
  const featured = useQueryParam('featured') === 'true';
  
  return (
    <div>
      <h2>Product {id}</h2>
      <p>Price: ${price}</p>
      <p>Featured: {featured ? 'Yes' : 'No'}</p>
    </div>
  );
}
```

#### Comparison: Component Input Binding

| Feature | Angular withComponentInputBinding | React Router Hooks |
|---------|----------------------------------|------------------|
| **Automatic Binding** | ✅ @Input() decorator | useParams() hook |
| **Type Transforms** | ✅ numberAttribute, booleanAttribute | Manual conversion |
| **Query Params** | ✅ Auto-bound as inputs | useSearchParams() |
| **Route Data** | ✅ Auto-bound as inputs | No equivalent |
| **Reactive Updates** | ✅ Automatic | Re-render on change |

**When to Use:**
- **Angular:** withComponentInputBinding for automatic input binding
- **React:** useParams, useSearchParams hooks

**Further Reading:**
- [Angular Component Input Binding](https://angular.dev/guide/routing/common-router-tasks#getting-route-information)
- [React Router Hooks](https://reactrouter.com/en/main/hooks/use-params)

---

## Part 5 Summary

This part covered **6 Routing Features**:

1. ✅ **Router Events** - Navigation lifecycle monitoring
2. ✅ **Auxiliary Routes** - Named outlets for multi-pane layouts
3. ✅ **Route Animations** - Transition effects between routes
4. ✅ **Matrix Parameters** - Segment-specific URL parameters
5. ✅ **Title Strategy** - Custom page title resolution
6. ✅ **withComponentInputBinding** - Automatic route param binding

**Progress: 32/38 features complete (84%)**

**Next:** Part 6 will cover **5 Tooling & DevOps Features** (Angular DevTools, AOT vs JIT, Custom Schematics, Budgets, Zone.js)

