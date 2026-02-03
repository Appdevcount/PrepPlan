# Angular Advanced Features vs ReactJS: Complete Study Guide (Part 3)

> **Core Concepts Continued - Part 3 of 6**  
> This file continues with the remaining Core Concepts: ng-container, Dynamic Components, @ContentChild/@ContentChildren, @ViewChildren, ControlValueAccessor, and ChangeDetectorRef.

---

## 🟠 Core Concepts (Continued) {#core-concepts-continued}

### 4. ng-container

**Description:** `ng-container` is a logical container that doesn't create an actual DOM element. It's perfect for grouping elements when using structural directives without adding extra markup to your HTML.

#### Angular: ng-container Examples

**Basic Usage - Grouping Without Extra DOM:**

```typescript
// without-ng-container.component.ts
@Component({
  selector: 'app-without-container',
  template: `
    <!-- Problem: Extra div in DOM -->
    <div *ngIf="showUsers">
      <h3>Users</h3>
      <ul>
        <li *ngFor="let user of users">{{ user.name }}</li>
      </ul>
    </div>
  `
})
export class WithoutContainerComponent {
  showUsers = true;
  users = [
    { name: 'Alice' },
    { name: 'Bob' }
  ];
}
// Renders: <div><h3>Users</h3><ul>...</ul></div>

// with-ng-container.component.ts
@Component({
  selector: 'app-with-container',
  template: `
    <!-- Solution: No extra element in DOM -->
    <ng-container *ngIf="showUsers">
      <h3>Users</h3>
      <ul>
        <li *ngFor="let user of users">{{ user.name }}</li>
      </ul>
    </ng-container>
  `
})
export class WithContainerComponent {
  showUsers = true;
  users = [
    { name: 'Alice' },
    { name: 'Bob' }
  ];
}
// Renders: <h3>Users</h3><ul>...</ul> (no wrapper!)
```

**Multiple Structural Directives:**

```typescript
// multi-directive.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-multi-directive',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="user-list">
      <h2>User Management</h2>
      
      <!-- Using ng-container to apply multiple structural directives -->
      <ng-container *ngIf="showActiveUsers">
        <ng-container *ngFor="let user of users">
          <!-- Each user filtered and looped -->
          <div class="user-card" *ngIf="user.isActive">
            <h3>{{ user.name }}</h3>
            <p>{{ user.email }}</p>
            <span class="badge">Active</span>
          </div>
        </ng-container>
      </ng-container>
      
      <!-- Alternative: Using ng-container with ngSwitch -->
      <ng-container [ngSwitch]="viewMode">
        <ng-container *ngSwitchCase="'list'">
          <ul>
            <li *ngFor="let user of users">{{ user.name }}</li>
          </ul>
        </ng-container>
        
        <ng-container *ngSwitchCase="'grid'">
          <div class="grid">
            <div *ngFor="let user of users" class="grid-item">
              {{ user.name }}
            </div>
          </div>
        </ng-container>
        
        <ng-container *ngSwitchDefault>
          <p>Select a view mode</p>
        </ng-container>
      </ng-container>
    </div>
  `,
  styles: [`
    .user-card { border: 1px solid #ddd; padding: 16px; margin: 10px 0; }
    .badge { background: #28a745; color: white; padding: 4px 8px; border-radius: 4px; }
    .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
  `]
})
export class MultiDirectiveComponent {
  showActiveUsers = true;
  viewMode: 'list' | 'grid' | 'table' = 'list';
  
  users = [
    { name: 'Alice', email: 'alice@example.com', isActive: true },
    { name: 'Bob', email: 'bob@example.com', isActive: false },
    { name: 'Charlie', email: 'charlie@example.com', isActive: true }
  ];
}
```

**Complex Conditionals:**

```typescript
// dashboard.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="dashboard">
      <h2>Dashboard</h2>
      
      <!-- Complex permission-based rendering without extra DOM nodes -->
      <ng-container *ngIf="user && user.permissions">
        <ng-container *ngIf="user.permissions.canViewStats">
          <div class="stats-section">
            <h3>Statistics</h3>
            <p>Total Users: {{ stats.totalUsers }}</p>
            <p>Active Sessions: {{ stats.activeSessions }}</p>
          </div>
        </ng-container>
        
        <ng-container *ngIf="user.permissions.canViewReports">
          <div class="reports-section">
            <h3>Reports</h3>
            <ul>
              <li *ngFor="let report of reports">{{ report.name }}</li>
            </ul>
          </div>
        </ng-container>
        
        <ng-container *ngIf="user.permissions.canManageUsers">
          <div class="admin-section">
            <h3>User Management</h3>
            <button>Add User</button>
            <button>View All Users</button>
          </div>
        </ng-container>
      </ng-container>
      
      <!-- Fallback for no permissions -->
      <ng-container *ngIf="!user || !user.permissions">
        <div class="no-access">
          <p>You don't have access to this dashboard.</p>
        </div>
      </ng-container>
    </div>
  `,
  styles: [`
    .dashboard > div { margin: 20px 0; padding: 16px; border: 1px solid #ddd; }
    .no-access { text-align: center; color: #999; }
  `]
})
export class DashboardComponent {
  user = {
    name: 'Admin',
    permissions: {
      canViewStats: true,
      canViewReports: true,
      canManageUsers: false
    }
  };
  
  stats = {
    totalUsers: 1250,
    activeSessions: 45
  };
  
  reports = [
    { name: 'Monthly Report' },
    { name: 'Quarterly Report' }
  ];
}
```

**With Angular 17+ Control Flow:**

```typescript
// modern-ng-container.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-modern-container',
  standalone: true,
  template: `
    <div class="products">
      <h2>Products</h2>
      
      <!-- ng-container with new @if syntax -->
      <ng-container>
        @if (loading) {
          <div class="loading">Loading products...</div>
        } @else {
          @for (product of products; track product.id) {
            <ng-container>
              @if (product.inStock) {
                <div class="product-card">
                  <h3>{{ product.name }}</h3>
                  <p>${{ product.price }}</p>
                  <button>Add to Cart</button>
                </div>
              }
            </ng-container>
          }
        }
      </ng-container>
    </div>
  `
})
export class ModernContainerComponent {
  loading = false;
  products = [
    { id: 1, name: 'Laptop', price: 999, inStock: true },
    { id: 2, name: 'Mouse', price: 29, inStock: false },
    { id: 3, name: 'Keyboard', price: 79, inStock: true }
  ];
}
```

#### React: Equivalent Patterns

**React Fragment (Similar to ng-container):**

```tsx
// UserList.tsx
import React, { Fragment } from 'react';

interface User {
  name: string;
  email: string;
  isActive: boolean;
}

function UserList() {
  const showActiveUsers = true;
  const users: User[] = [
    { name: 'Alice', email: 'alice@example.com', isActive: true },
    { name: 'Bob', email: 'bob@example.com', isActive: false },
    { name: 'Charlie', email: 'charlie@example.com', isActive: true }
  ];
  
  return (
    <div className="user-list">
      <h2>User Management</h2>
      
      {/* Fragment doesn't create DOM element - like ng-container */}
      {showActiveUsers && (
        <Fragment>
          {users.map(user => (
            <Fragment key={user.name}>
              {user.isActive && (
                <div className="user-card">
                  <h3>{user.name}</h3>
                  <p>{user.email}</p>
                  <span className="badge">Active</span>
                </div>
              )}
            </Fragment>
          ))}
        </Fragment>
      )}
      
      {/* Short syntax for Fragment */}
      {showActiveUsers && (
        <>
          {users.filter(u => u.isActive).map(user => (
            <div key={user.name} className="user-card">
              <h3>{user.name}</h3>
              <p>{user.email}</p>
              <span className="badge">Active</span>
            </div>
          ))}
        </>
      )}
    </div>
  );
}

export default UserList;
```

**Complex Conditionals with Fragments:**

```tsx
// Dashboard.tsx
import React from 'react';

interface User {
  name: string;
  permissions: {
    canViewStats: boolean;
    canViewReports: boolean;
    canManageUsers: boolean;
  };
}

function Dashboard() {
  const user: User = {
    name: 'Admin',
    permissions: {
      canViewStats: true,
      canViewReports: true,
      canManageUsers: false
    }
  };
  
  const stats = {
    totalUsers: 1250,
    activeSessions: 45
  };
  
  const reports = [
    { name: 'Monthly Report' },
    { name: 'Quarterly Report' }
  ];
  
  return (
    <div className="dashboard">
      <h2>Dashboard</h2>
      
      {/* Complex conditionals without extra DOM nodes */}
      {user && user.permissions && (
        <>
          {user.permissions.canViewStats && (
            <div className="stats-section">
              <h3>Statistics</h3>
              <p>Total Users: {stats.totalUsers}</p>
              <p>Active Sessions: {stats.activeSessions}</p>
            </div>
          )}
          
          {user.permissions.canViewReports && (
            <div className="reports-section">
              <h3>Reports</h3>
              <ul>
                {reports.map((report, index) => (
                  <li key={index}>{report.name}</li>
                ))}
              </ul>
            </div>
          )}
          
          {user.permissions.canManageUsers && (
            <div className="admin-section">
              <h3>User Management</h3>
              <button>Add User</button>
              <button>View All Users</button>
            </div>
          )}
        </>
      )}
      
      {/* Fallback */}
      {(!user || !user.permissions) && (
        <div className="no-access">
          <p>You don't have access to this dashboard.</p>
        </div>
      )}
    </div>
  );
}

export default Dashboard;
```

**Multiple Renders with Fragments:**

```tsx
// ProductList.tsx
import React from 'react';

function ProductList() {
  const [viewMode, setViewMode] = React.useState<'list' | 'grid'>('list');
  const users = [
    { name: 'Alice' },
    { name: 'Bob' },
    { name: 'Charlie' }
  ];
  
  return (
    <div>
      <button onClick={() => setViewMode('list')}>List</button>
      <button onClick={() => setViewMode('grid')}>Grid</button>
      
      {/* Switch-like behavior with fragments */}
      {viewMode === 'list' && (
        <>
          <ul>
            {users.map((user, i) => (
              <li key={i}>{user.name}</li>
            ))}
          </ul>
        </>
      )}
      
      {viewMode === 'grid' && (
        <>
          <div className="grid">
            {users.map((user, i) => (
              <div key={i} className="grid-item">
                {user.name}
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
}

export default ProductList;
```

#### Comparison: ng-container vs React.Fragment

| Feature | Angular ng-container | React Fragment / <> |
|---------|---------------------|---------------------|
| **Purpose** | Logical grouping without DOM | Logical grouping without DOM |
| **Syntax** | `<ng-container>` | `<Fragment>` or `<>` |
| **Use Case** | Structural directives | Returning multiple elements |
| **Keys** | N/A | Can add key prop to Fragment |
| **Attributes** | Cannot add attributes | Cannot add attributes (except key) |
| **Performance** | No DOM overhead | No DOM overhead |

**Key Similarities:**
1. Both don't create actual DOM elements
2. Both used for logical grouping
3. Both improve semantic HTML
4. Both have zero performance impact

**When to Use:**
- **Angular ng-container:** When using structural directives (*ngIf, *ngFor) without wanting extra DOM elements
- **React Fragment:** When returning multiple elements from a component or mapping arrays

**Further Reading:**
- [Angular ng-container](https://angular.dev/api/core/ng-container)
- [React Fragments](https://react.dev/reference/react/Fragment)

---

### 5. Dynamic Components

**Description:** Dynamic components allow you to create and insert components programmatically at runtime. This is useful for creating dynamic UIs like modals, tabs, or plugin systems.

#### Angular: Dynamic Components Examples

**Basic Dynamic Component Loading:**

```typescript
// alert.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-alert',
  standalone: true,
  template: `
    <div class="alert" [class]="'alert-' + type">
      <strong>{{ title }}</strong>
      <p>{{ message }}</p>
      <button (click)="onClose()">Close</button>
    </div>
  `,
  styles: [`
    .alert { padding: 16px; border-radius: 4px; margin: 10px 0; }
    .alert-success { background: #d4edda; color: #155724; }
    .alert-warning { background: #fff3cd; color: #856404; }
    .alert-danger { background: #f8d7da; color: #721c24; }
  `]
})
export class AlertComponent {
  @Input() title = 'Alert';
  @Input() message = '';
  @Input() type: 'success' | 'warning' | 'danger' = 'success';
  @Input() onClose: () => void = () => {};
}

// dynamic-container.component.ts
import { Component, ViewChild, ViewContainerRef, ComponentRef, inject } from '@angular/core';
import { AlertComponent } from './alert.component';

@Component({
  selector: 'app-dynamic-container',
  standalone: true,
  template: `
    <div class="container">
      <h2>Dynamic Component Example</h2>
      
      <div class="controls">
        <button (click)="createSuccessAlert()">Success Alert</button>
        <button (click)="createWarningAlert()">Warning Alert</button>
        <button (click)="createDangerAlert()">Danger Alert</button>
        <button (click)="clearAll()">Clear All</button>
      </div>
      
      <!-- Container where components will be dynamically inserted -->
      <div #dynamicContainer></div>
    </div>
  `,
  styles: [`
    .controls button { margin: 5px; padding: 8px 16px; }
  `]
})
export class DynamicContainerComponent {
  // Get reference to the container
  @ViewChild('dynamicContainer', { read: ViewContainerRef, static: true })
  containerRef!: ViewContainerRef;
  
  // Track created components for cleanup
  private componentRefs: ComponentRef<AlertComponent>[] = [];

  createSuccessAlert() {
    this.createAlert('Success!', 'Operation completed successfully.', 'success');
  }

  createWarningAlert() {
    this.createAlert('Warning!', 'Please review your input.', 'warning');
  }

  createDangerAlert() {
    this.createAlert('Error!', 'Something went wrong.', 'danger');
  }

  private createAlert(title: string, message: string, type: 'success' | 'warning' | 'danger') {
    // Create component dynamically
    const componentRef = this.containerRef.createComponent(AlertComponent);
    
    // Set input properties
    componentRef.setInput('title', title);
    componentRef.setInput('message', message);
    componentRef.setInput('type', type);
    componentRef.setInput('onClose', () => {
      // Remove this specific component
      const index = this.componentRefs.indexOf(componentRef);
      if (index > -1) {
        this.componentRefs.splice(index, 1);
      }
      componentRef.destroy();
    });
    
    // Track component reference
    this.componentRefs.push(componentRef);
  }

  clearAll() {
    // Destroy all components
    this.componentRefs.forEach(ref => ref.destroy());
    this.componentRefs = [];
    // Or simply clear the container
    // this.containerRef.clear();
  }
}
```

**Advanced: Modal Service with Dynamic Components:**

```typescript
// modal.service.ts
import { Injectable, ApplicationRef, ComponentRef, createComponent, EnvironmentInjector, inject } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ModalService {
  private appRef = inject(ApplicationRef);
  private injector = inject(EnvironmentInjector);
  private modalRefs: ComponentRef<any>[] = [];

  open<T>(component: any, inputs?: Partial<T>): ComponentRef<T> {
    // Create component dynamically
    const componentRef = createComponent(component, {
      environmentInjector: this.injector
    });
    
    // Set inputs if provided
    if (inputs) {
      Object.keys(inputs).forEach(key => {
        componentRef.setInput(key, inputs[key]);
      });
    }
    
    // Attach to application
    this.appRef.attachView(componentRef.hostView);
    
    // Append to body
    const domElem = (componentRef.hostView as any).rootNodes[0] as HTMLElement;
    document.body.appendChild(domElem);
    
    // Track reference
    this.modalRefs.push(componentRef);
    
    return componentRef;
  }

  close(componentRef: ComponentRef<any>) {
    const index = this.modalRefs.indexOf(componentRef);
    if (index > -1) {
      this.modalRefs.splice(index, 1);
    }
    
    this.appRef.detachView(componentRef.hostView);
    componentRef.destroy();
  }

  closeAll() {
    this.modalRefs.forEach(ref => {
      this.appRef.detachView(ref.hostView);
      ref.destroy();
    });
    this.modalRefs = [];
  }
}

// confirm-modal.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-confirm-modal',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="modal-overlay" (click)="onCancel()">
      <div class="modal-content" (click)="$event.stopPropagation()">
        <h2>{{ title }}</h2>
        <p>{{ message }}</p>
        <div class="modal-actions">
          <button class="btn-cancel" (click)="onCancel()">{{ cancelText }}</button>
          <button class="btn-confirm" (click)="onConfirm()">{{ confirmText }}</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .modal-overlay {
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
      padding: 24px;
      border-radius: 8px;
      min-width: 400px;
      max-width: 90%;
    }
    .modal-actions {
      display: flex;
      gap: 10px;
      justify-content: flex-end;
      margin-top: 20px;
    }
    .btn-cancel, .btn-confirm {
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .btn-cancel {
      background: #6c757d;
      color: white;
    }
    .btn-confirm {
      background: #007bff;
      color: white;
    }
  `]
})
export class ConfirmModalComponent {
  @Input() title = 'Confirm';
  @Input() message = 'Are you sure?';
  @Input() confirmText = 'Confirm';
  @Input() cancelText = 'Cancel';
  @Output() confirm = new EventEmitter<void>();
  @Output() cancel = new EventEmitter<void>();

  onConfirm() {
    this.confirm.emit();
  }

  onCancel() {
    this.cancel.emit();
  }
}

// Usage in component
import { Component, inject } from '@angular/core';
import { ModalService } from './modal.service';
import { ConfirmModalComponent } from './confirm-modal.component';

@Component({
  selector: 'app-user-list',
  template: `
    <div>
      <button (click)="deleteUser()">Delete User</button>
    </div>
  `
})
export class UserListComponent {
  private modalService = inject(ModalService);

  deleteUser() {
    const modalRef = this.modalService.open(ConfirmModalComponent, {
      title: 'Delete User',
      message: 'Are you sure you want to delete this user?',
      confirmText: 'Delete',
      cancelText: 'Cancel'
    });
    
    // Subscribe to events
    modalRef.instance.confirm.subscribe(() => {
      console.log('User deleted');
      this.modalService.close(modalRef);
    });
    
    modalRef.instance.cancel.subscribe(() => {
      console.log('Cancelled');
      this.modalService.close(modalRef);
    });
  }
}
```

**Tab System with Dynamic Components:**

```typescript
// tab-content.interface.ts
export interface TabContent {
  title: string;
  component: any;
  data?: any;
}

// tab-container.component.ts
import { Component, ViewChild, ViewContainerRef, ComponentRef, Input, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-tab-container',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="tabs-container">
      <div class="tab-headers">
        <button
          *ngFor="let tab of tabs; let i = index"
          [class.active]="i === activeIndex"
          (click)="selectTab(i)"
        >
          {{ tab.title }}
        </button>
      </div>
      
      <div class="tab-content">
        <ng-container #tabContent></ng-container>
      </div>
    </div>
  `,
  styles: [`
    .tab-headers {
      display: flex;
      border-bottom: 2px solid #ddd;
    }
    .tab-headers button {
      padding: 12px 24px;
      border: none;
      background: none;
      cursor: pointer;
      border-bottom: 3px solid transparent;
    }
    .tab-headers button.active {
      border-bottom-color: #007bff;
      color: #007bff;
    }
    .tab-content {
      padding: 20px;
    }
  `]
})
export class TabContainerComponent implements OnInit {
  @Input() tabs: TabContent[] = [];
  @ViewChild('tabContent', { read: ViewContainerRef, static: true })
  tabContentRef!: ViewContainerRef;
  
  activeIndex = 0;
  private currentComponentRef?: ComponentRef<any>;

  ngOnInit() {
    if (this.tabs.length > 0) {
      this.selectTab(0);
    }
  }

  selectTab(index: number) {
    this.activeIndex = index;
    
    // Clear previous component
    if (this.currentComponentRef) {
      this.currentComponentRef.destroy();
    }
    this.tabContentRef.clear();
    
    // Load new component
    const tab = this.tabs[index];
    this.currentComponentRef = this.tabContentRef.createComponent(tab.component);
    
    // Pass data to component if available
    if (tab.data) {
      Object.keys(tab.data).forEach(key => {
        this.currentComponentRef!.setInput(key, tab.data[key]);
      });
    }
  }
}

// Example tab components
@Component({
  selector: 'app-profile-tab',
  standalone: true,
  template: `<div><h3>Profile</h3><p>User profile information</p></div>`
})
export class ProfileTabComponent {}

@Component({
  selector: 'app-settings-tab',
  standalone: true,
  template: `<div><h3>Settings</h3><p>User settings</p></div>`
})
export class SettingsTabComponent {}

// Usage
@Component({
  template: `
    <app-tab-container [tabs]="tabs"></app-tab-container>
  `
})
export class AppComponent {
  tabs: TabContent[] = [
    { title: 'Profile', component: ProfileTabComponent },
    { title: 'Settings', component: SettingsTabComponent }
  ];
}
```

#### React: Equivalent Patterns

**Dynamic Component with State:**

```tsx
// Alert.tsx
import React from 'react';

interface AlertProps {
  title: string;
  message: string;
  type: 'success' | 'warning' | 'danger';
  onClose: () => void;
}

function Alert({ title, message, type, onClose }: AlertProps) {
  return (
    <div className={`alert alert-${type}`}>
      <strong>{title}</strong>
      <p>{message}</p>
      <button onClick={onClose}>Close</button>
    </div>
  );
}

// DynamicContainer.tsx
import React, { useState } from 'react';
import Alert from './Alert';

interface AlertData {
  id: number;
  title: string;
  message: string;
  type: 'success' | 'warning' | 'danger';
}

function DynamicContainer() {
  const [alerts, setAlerts] = useState<AlertData[]>([]);
  const [nextId, setNextId] = useState(1);

  const createAlert = (title: string, message: string, type: 'success' | 'warning' | 'danger') => {
    setAlerts([...alerts, { id: nextId, title, message, type }]);
    setNextId(nextId + 1);
  };

  const removeAlert = (id: number) => {
    setAlerts(alerts.filter(alert => alert.id !== id));
  };

  const clearAll = () => {
    setAlerts([]);
  };

  return (
    <div className="container">
      <h2>Dynamic Component Example</h2>
      
      <div className="controls">
        <button onClick={() => createAlert('Success!', 'Operation completed successfully.', 'success')}>
          Success Alert
        </button>
        <button onClick={() => createAlert('Warning!', 'Please review your input.', 'warning')}>
          Warning Alert
        </button>
        <button onClick={() => createAlert('Error!', 'Something went wrong.', 'danger')}>
          Danger Alert
        </button>
        <button onClick={clearAll}>Clear All</button>
      </div>
      
      <div>
        {alerts.map(alert => (
          <Alert
            key={alert.id}
            title={alert.title}
            message={alert.message}
            type={alert.type}
            onClose={() => removeAlert(alert.id)}
          />
        ))}
      </div>
    </div>
  );
}

export default DynamicContainer;
```

**Modal Service with React Portal:**

```tsx
// ModalService.tsx
import React, { useState, createContext, useContext, ReactNode } from 'react';
import { createPortal } from 'react-dom';

interface ModalContextType {
  openModal: (component: ReactNode) => void;
  closeModal: () => void;
}

const ModalContext = createContext<ModalContextType | null>(null);

export function ModalProvider({ children }: { children: ReactNode }) {
  const [modalContent, setModalContent] = useState<ReactNode | null>(null);

  const openModal = (component: ReactNode) => {
    setModalContent(component);
  };

  const closeModal = () => {
    setModalContent(null);
  };

  return (
    <ModalContext.Provider value={{ openModal, closeModal }}>
      {children}
      {modalContent && createPortal(
        <div className="modal-root">{modalContent}</div>,
        document.body
      )}
    </ModalContext.Provider>
  );
}

export function useModal() {
  const context = useContext(ModalContext);
  if (!context) {
    throw new Error('useModal must be used within ModalProvider');
  }
  return context;
}

// ConfirmModal.tsx
interface ConfirmModalProps {
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void;
  onCancel: () => void;
}

function ConfirmModal({
  title,
  message,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  onConfirm,
  onCancel
}: ConfirmModalProps) {
  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <h2>{title}</h2>
        <p>{message}</p>
        <div className="modal-actions">
          <button className="btn-cancel" onClick={onCancel}>{cancelText}</button>
          <button className="btn-confirm" onClick={onConfirm}>{confirmText}</button>
        </div>
      </div>
    </div>
  );
}

// Usage
function UserList() {
  const { openModal, closeModal } = useModal();

  const deleteUser = () => {
    openModal(
      <ConfirmModal
        title="Delete User"
        message="Are you sure you want to delete this user?"
        confirmText="Delete"
        cancelText="Cancel"
        onConfirm={() => {
          console.log('User deleted');
          closeModal();
        }}
        onCancel={closeModal}
      />
    );
  };

  return (
    <div>
      <button onClick={deleteUser}>Delete User</button>
    </div>
  );
}
```

**Tab System in React:**

```tsx
// TabContainer.tsx
import React, { useState, ComponentType } from 'react';

interface Tab {
  title: string;
  component: ComponentType<any>;
  props?: any;
}

interface TabContainerProps {
  tabs: Tab[];
}

function TabContainer({ tabs }: TabContainerProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  
  const ActiveComponent = tabs[activeIndex]?.component;
  const activeProps = tabs[activeIndex]?.props || {};

  return (
    <div className="tabs-container">
      <div className="tab-headers">
        {tabs.map((tab, index) => (
          <button
            key={index}
            className={index === activeIndex ? 'active' : ''}
            onClick={() => setActiveIndex(index)}
          >
            {tab.title}
          </button>
        ))}
      </div>
      
      <div className="tab-content">
        {ActiveComponent && <ActiveComponent {...activeProps} />}
      </div>
    </div>
  );
}

// Tab components
function ProfileTab() {
  return (
    <div>
      <h3>Profile</h3>
      <p>User profile information</p>
    </div>
  );
}

function SettingsTab() {
  return (
    <div>
      <h3>Settings</h3>
      <p>User settings</p>
    </div>
  );
}

// Usage
function App() {
  const tabs: Tab[] = [
    { title: 'Profile', component: ProfileTab },
    { title: 'Settings', component: SettingsTab }
  ];

  return <TabContainer tabs={tabs} />;
}

export default App;
```

#### Comparison: Dynamic Components

| Feature | Angular ViewContainerRef | React State + Portals |
|---------|-------------------------|----------------------|
| **API** | createComponent() | createPortal() + state |
| **Component Creation** | Imperative | Declarative |
| **Lifecycle** | Manual destroy() | Automatic on unmount |
| **Input/Output** | setInput() / instance | Props |
| **Portal/Overlay** | Manual DOM append | createPortal() |
| **Complexity** | More verbose | More intuitive |

**When to Use:**
- **Angular Dynamic Components:** Plugin systems, dynamic forms, modal services
- **React Dynamic Rendering:** Same use cases, but with state-driven approach

**Further Reading:**
- [Angular Dynamic Components](https://angular.dev/guide/components/advanced#dynamic-components)
- [React Portals](https://react.dev/reference/react-dom/createPortal)

---

### 6. @ContentChild / @ContentChildren

**Description:** Content projection queries allow parent components to access and manipulate content projected into them via `<ng-content>`. `@ContentChild` gets a single element, while `@ContentChildren` gets multiple elements.

#### Angular: Content Projection Queries

**Basic @ContentChild Example:**

```typescript
// card-header.component.ts
import { Component } from '@angular/core';

@Component({
  selector: 'app-card-header',
  standalone: true,
  template: `<div class="card-header"><ng-content></ng-content></div>`,
  styles: [`
    .card-header {
      background: #f8f9fa;
      padding: 12px 16px;
      border-bottom: 1px solid #dee2e6;
      font-weight: bold;
    }
  `]
})
export class CardHeaderComponent {}

// card.component.ts
import { Component, ContentChild, AfterContentInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardHeaderComponent } from './card-header.component';

@Component({
  selector: 'app-card',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card">
      <!-- Content projection slot -->
      <ng-content></ng-content>
      
      <!-- Access projected header -->
      @if (hasHeader) {
        <div class="header-info">
          Header detected: {{ headerElement ? 'Yes' : 'No' }}
        </div>
      }
    </div>
  `,
  styles: [`
    .card {
      border: 1px solid #ddd;
      border-radius: 8px;
      overflow: hidden;
      margin: 16px 0;
    }
    .header-info {
      padding: 8px;
      background: #e9ecef;
      font-size: 12px;
      color: #6c757d;
    }
  `]
})
export class CardComponent implements AfterContentInit {
  // Query for projected CardHeaderComponent
  @ContentChild(CardHeaderComponent) headerElement?: CardHeaderComponent;
  
  hasHeader = false;

  ngAfterContentInit() {
    // Content is available after this lifecycle hook
    this.hasHeader = !!this.headerElement;
    console.log('Header projected:', this.hasHeader);
  }
}

// Usage
@Component({
  selector: 'app-example',
  standalone: true,
  imports: [CardComponent, CardHeaderComponent],
  template: `
    <app-card>
      <app-card-header>User Profile</app-card-header>
      <p>Content goes here...</p>
    </app-card>
  `
})
export class ExampleComponent {}
```

**Advanced @ContentChildren Example:**

```typescript
// tab-panel.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-tab-panel',
  standalone: true,
  template: `
    <div class="tab-panel" [hidden]="!active">
      <ng-content></ng-content>
    </div>
  `,
  styles: [`
    .tab-panel {
      padding: 20px;
      border: 1px solid #ddd;
      border-top: none;
    }
  `]
})
export class TabPanelComponent {
  @Input() title = '';
  @Input() active = false;
}

// tabs.component.ts
import { Component, ContentChildren, QueryList, AfterContentInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TabPanelComponent } from './tab-panel.component';

@Component({
  selector: 'app-tabs',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="tabs-container">
      <!-- Tab headers generated from projected panels -->
      <div class="tab-headers">
        @for (tab of tabPanels; track $index; let i = $index) {
          <button
            class="tab-button"
            [class.active]="activeIndex === i"
            (click)="selectTab(i)"
          >
            {{ tab.title }}
          </button>
        }
      </div>
      
      <!-- Projected tab panels -->
      <div class="tab-content">
        <ng-content></ng-content>
      </div>
      
      <!-- Debug info -->
      <div class="tab-info">
        Total tabs: {{ tabPanels.length }} | Active: {{ activeIndex }}
      </div>
    </div>
  `,
  styles: [`
    .tab-headers {
      display: flex;
      border-bottom: 2px solid #ddd;
    }
    .tab-button {
      padding: 12px 24px;
      border: none;
      background: none;
      cursor: pointer;
      border-bottom: 3px solid transparent;
    }
    .tab-button.active {
      border-bottom-color: #007bff;
      color: #007bff;
    }
    .tab-info {
      margin-top: 10px;
      padding: 8px;
      background: #f8f9fa;
      font-size: 12px;
    }
  `]
})
export class TabsComponent implements AfterContentInit {
  // Query all projected TabPanelComponents
  @ContentChildren(TabPanelComponent) tabPanels!: QueryList<TabPanelComponent>;
  
  activeIndex = 0;

  ngAfterContentInit() {
    // Initialize first tab as active
    if (this.tabPanels.length > 0) {
      this.selectTab(0);
    }
    
    // Listen for changes to projected content
    this.tabPanels.changes.subscribe(() => {
      console.log('Tab panels changed:', this.tabPanels.length);
    });
  }

  selectTab(index: number) {
    this.activeIndex = index;
    
    // Update active state on all panels
    this.tabPanels.forEach((panel, i) => {
      panel.active = i === index;
    });
  }
}

// Usage
@Component({
  selector: 'app-example',
  standalone: true,
  imports: [TabsComponent, TabPanelComponent],
  template: `
    <app-tabs>
      <app-tab-panel title="Profile">
        <h3>User Profile</h3>
        <p>Profile information goes here</p>
      </app-tab-panel>
      
      <app-tab-panel title="Settings">
        <h3>Settings</h3>
        <p>Settings content goes here</p>
      </app-tab-panel>
      
      <app-tab-panel title="Activity">
        <h3>Recent Activity</h3>
        <p>Activity log goes here</p>
      </app-tab-panel>
    </app-tabs>
  `
})
export class ExampleComponent {}
```

**Complex Example: Accordion with QueryList:**

```typescript
// accordion-item.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-accordion-item',
  standalone: true,
  template: `
    <div class="accordion-item">
      <div class="accordion-header" (click)="toggle()">
        <span>{{ title }}</span>
        <span class="icon">{{ expanded ? '−' : '+' }}</span>
      </div>
      <div class="accordion-content" [hidden]="!expanded">
        <ng-content></ng-content>
      </div>
    </div>
  `,
  styles: [`
    .accordion-item {
      border: 1px solid #ddd;
      margin-bottom: 8px;
    }
    .accordion-header {
      padding: 12px 16px;
      background: #f8f9fa;
      cursor: pointer;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .accordion-header:hover {
      background: #e9ecef;
    }
    .accordion-content {
      padding: 16px;
    }
    .icon {
      font-size: 20px;
      font-weight: bold;
    }
  `]
})
export class AccordionItemComponent {
  @Input() title = '';
  @Input() expanded = false;
  @Output() expandedChange = new EventEmitter<boolean>();

  toggle() {
    this.expanded = !this.expanded;
    this.expandedChange.emit(this.expanded);
  }
}

// accordion.component.ts
import { Component, ContentChildren, QueryList, Input, AfterContentInit } from '@angular/core';
import { AccordionItemComponent } from './accordion-item.component';

@Component({
  selector: 'app-accordion',
  standalone: true,
  template: `
    <div class="accordion">
      <ng-content></ng-content>
    </div>
  `,
  styles: [`
    .accordion {
      max-width: 600px;
      margin: 20px auto;
    }
  `]
})
export class AccordionComponent implements AfterContentInit {
  // Allow multiple panels open at once
  @Input() allowMultiple = false;
  
  // Query all accordion items
  @ContentChildren(AccordionItemComponent) items!: QueryList<AccordionItemComponent>;

  ngAfterContentInit() {
    // Subscribe to expansion changes on each item
    this.items.forEach(item => {
      item.expandedChange.subscribe((expanded) => {
        if (expanded && !this.allowMultiple) {
          // Close other items if allowMultiple is false
          this.closeOthers(item);
        }
      });
    });
  }

  private closeOthers(currentItem: AccordionItemComponent) {
    this.items.forEach(item => {
      if (item !== currentItem) {
        item.expanded = false;
      }
    });
  }
}

// Usage
@Component({
  selector: 'app-faq',
  standalone: true,
  imports: [AccordionComponent, AccordionItemComponent],
  template: `
    <h2>FAQ</h2>
    
    <!-- Single-expand mode -->
    <app-accordion [allowMultiple]="false">
      <app-accordion-item title="What is Angular?">
        Angular is a platform for building web applications.
      </app-accordion-item>
      
      <app-accordion-item title="What are signals?">
        Signals are a new reactive primitive in Angular 16+.
      </app-accordion-item>
      
      <app-accordion-item title="What is standalone mode?">
        Standalone components don't require NgModules.
      </app-accordion-item>
    </app-accordion>
  `
})
export class FaqComponent {}
```

#### React: Equivalent Patterns

**Children Props with React.Children:**

```tsx
// Card.tsx
import React, { ReactNode, Children, isValidElement, cloneElement } from 'react';

interface CardHeaderProps {
  children: ReactNode;
}

function CardHeader({ children }: CardHeaderProps) {
  return (
    <div className="card-header">
      {children}
    </div>
  );
}

interface CardProps {
  children: ReactNode;
}

function Card({ children }: CardProps) {
  // Find CardHeader in children
  let hasHeader = false;
  
  Children.forEach(children, (child) => {
    if (isValidElement(child) && child.type === CardHeader) {
      hasHeader = true;
    }
  });

  return (
    <div className="card">
      {children}
      {hasHeader && (
        <div className="header-info">
          Header detected: Yes
        </div>
      )}
    </div>
  );
}

// Export both
Card.Header = CardHeader;
export default Card;

// Usage
function Example() {
  return (
    <Card>
      <Card.Header>User Profile</Card.Header>
      <p>Content goes here...</p>
    </Card>
  );
}
```

**Compound Component Pattern (Tabs):**

```tsx
// Tabs.tsx
import React, { createContext, useContext, useState, ReactNode, Children, isValidElement, cloneElement } from 'react';

interface TabsContextType {
  activeIndex: number;
  setActiveIndex: (index: number) => void;
}

const TabsContext = createContext<TabsContextType | null>(null);

function useTabs() {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('Tab components must be used within Tabs');
  }
  return context;
}

interface TabPanelProps {
  title: string;
  children: ReactNode;
  index?: number;
}

function TabPanel({ title, children, index }: TabPanelProps) {
  const { activeIndex } = useTabs();
  const isActive = index === activeIndex;
  
  return (
    <div className="tab-panel" hidden={!isActive}>
      {children}
    </div>
  );
}

interface TabsProps {
  children: ReactNode;
}

function Tabs({ children }: TabsProps) {
  const [activeIndex, setActiveIndex] = useState(0);
  
  // Extract TabPanel children and their titles
  const tabPanels: React.ReactElement[] = [];
  Children.forEach(children, (child) => {
    if (isValidElement(child) && child.type === TabPanel) {
      tabPanels.push(child);
    }
  });

  return (
    <TabsContext.Provider value={{ activeIndex, setActiveIndex }}>
      <div className="tabs-container">
        <div className="tab-headers">
          {tabPanels.map((panel, index) => (
            <button
              key={index}
              className={`tab-button ${activeIndex === index ? 'active' : ''}`}
              onClick={() => setActiveIndex(index)}
            >
              {panel.props.title}
            </button>
          ))}
        </div>
        
        <div className="tab-content">
          {Children.map(children, (child, index) => {
            if (isValidElement(child) && child.type === TabPanel) {
              return cloneElement(child, { index } as any);
            }
            return child;
          })}
        </div>
        
        <div className="tab-info">
          Total tabs: {tabPanels.length} | Active: {activeIndex}
        </div>
      </div>
    </TabsContext.Provider>
  );
}

Tabs.Panel = TabPanel;
export default Tabs;

// Usage
function Example() {
  return (
    <Tabs>
      <Tabs.Panel title="Profile">
        <h3>User Profile</h3>
        <p>Profile information goes here</p>
      </Tabs.Panel>
      
      <Tabs.Panel title="Settings">
        <h3>Settings</h3>
        <p>Settings content goes here</p>
      </Tabs.Panel>
      
      <Tabs.Panel title="Activity">
        <h3>Recent Activity</h3>
        <p>Activity log goes here</p>
      </Tabs.Panel>
    </Tabs>
  );
}
```

**Accordion with Children Manipulation:**

```tsx
// Accordion.tsx
import React, { useState, ReactNode, Children, isValidElement, cloneElement } from 'react';

interface AccordionItemProps {
  title: string;
  children: ReactNode;
  expanded?: boolean;
  onToggle?: () => void;
}

function AccordionItem({ title, children, expanded = false, onToggle }: AccordionItemProps) {
  return (
    <div className="accordion-item">
      <div className="accordion-header" onClick={onToggle}>
        <span>{title}</span>
        <span className="icon">{expanded ? '−' : '+'}</span>
      </div>
      <div className="accordion-content" hidden={!expanded}>
        {children}
      </div>
    </div>
  );
}

interface AccordionProps {
  children: ReactNode;
  allowMultiple?: boolean;
}

function Accordion({ children, allowMultiple = false }: AccordionProps) {
  const [expandedIndexes, setExpandedIndexes] = useState<number[]>([]);

  const handleToggle = (index: number) => {
    if (allowMultiple) {
      // Toggle this index
      setExpandedIndexes(prev =>
        prev.includes(index)
          ? prev.filter(i => i !== index)
          : [...prev, index]
      );
    } else {
      // Only allow one expanded
      setExpandedIndexes(prev =>
        prev.includes(index) ? [] : [index]
      );
    }
  };

  return (
    <div className="accordion">
      {Children.map(children, (child, index) => {
        if (isValidElement(child) && child.type === AccordionItem) {
          return cloneElement(child, {
            expanded: expandedIndexes.includes(index),
            onToggle: () => handleToggle(index)
          } as any);
        }
        return child;
      })}
    </div>
  );
}

Accordion.Item = AccordionItem;
export default Accordion;

// Usage
function FAQ() {
  return (
    <>
      <h2>FAQ</h2>
      <Accordion allowMultiple={false}>
        <Accordion.Item title="What is Angular?">
          Angular is a platform for building web applications.
        </Accordion.Item>
        
        <Accordion.Item title="What are signals?">
          Signals are a new reactive primitive in Angular 16+.
        </Accordion.Item>
        
        <Accordion.Item title="What is standalone mode?">
          Standalone components don't require NgModules.
        </Accordion.Item>
      </Accordion>
    </>
  );
}
```

#### Comparison: Content Projection Queries

| Feature | Angular @ContentChild | React Children API |
|---------|---------------------|-------------------|
| **Querying** | @ContentChild/@ContentChildren | React.Children utilities |
| **Type Safety** | QueryList<Type> | Type checking via isValidElement |
| **Lifecycle** | AfterContentInit | Immediate in render |
| **Manipulation** | Direct component access | cloneElement with props |
| **Reactivity** | QueryList.changes observable | Re-render on state change |

**When to Use:**
- **Angular @ContentChild:** When parent needs to control or access projected child components
- **React Children API:** For compound components and flexible composition patterns

**Further Reading:**
- [Angular Content Projection](https://angular.dev/guide/components/content-projection)
- [React Children API](https://react.dev/reference/react/Children)

---

### 7. @ViewChildren

**Description:** `@ViewChildren` queries for child elements in the component's own template (not projected content). It returns a QueryList that can be used to access and manipulate child components or DOM elements.

#### Angular: @ViewChildren Examples

**Querying Child Components:**

```typescript
// list-item.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-list-item',
  standalone: true,
  template: `
    <div class="list-item">
      <input
        type="checkbox"
        [(ngModel)]="checked"
        (change)="onCheckedChange()"
      />
      <span>{{ label }}</span>
    </div>
  `,
  styles: [`
    .list-item {
      padding: 8px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
  `]
})
export class ListItemComponent {
  @Input() label = '';
  checked = false;

  onCheckedChange() {
    console.log(`${this.label} checked:`, this.checked);
  }
  
  // Public method to be called by parent
  toggle() {
    this.checked = !this.checked;
  }
}

// list.component.ts
import { Component, ViewChildren, QueryList, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ListItemComponent } from './list-item.component';

@Component({
  selector: 'app-list',
  standalone: true,
  imports: [CommonModule, FormsModule, ListItemComponent],
  template: `
    <div class="list-container">
      <h3>Task List</h3>
      
      <div class="controls">
        <button (click)="selectAll()">Select All</button>
        <button (click)="deselectAll()">Deselect All</button>
        <button (click)="toggleAll()">Toggle All</button>
        <button (click)="logChecked()">Log Checked</button>
      </div>
      
      @for (item of items; track item.id) {
        <app-list-item [label]="item.label"></app-list-item>
      }
      
      <div class="summary">
        Total items: {{ listItems.length }}
      </div>
    </div>
  `,
  styles: [`
    .controls button {
      margin: 5px;
      padding: 8px 16px;
    }
    .summary {
      margin-top: 16px;
      padding: 12px;
      background: #f8f9fa;
    }
  `]
})
export class ListComponent implements AfterViewInit {
  // Query all ListItemComponent instances in the template
  @ViewChildren(ListItemComponent) listItems!: QueryList<ListItemComponent>;
  
  items = [
    { id: 1, label: 'Buy groceries' },
    { id: 2, label: 'Walk the dog' },
    { id: 3, label: 'Study Angular' },
    { id: 4, label: 'Build project' }
  ];

  ngAfterViewInit() {
    // View children are available after this lifecycle hook
    console.log('List items initialized:', this.listItems.length);
    
    // Listen for changes to child components
    this.listItems.changes.subscribe(() => {
      console.log('List items changed:', this.listItems.length);
    });
  }

  selectAll() {
    this.listItems.forEach(item => {
      item.checked = true;
    });
  }

  deselectAll() {
    this.listItems.forEach(item => {
      item.checked = false;
    });
  }

  toggleAll() {
    this.listItems.forEach(item => {
      item.toggle();
    });
  }

  logChecked() {
    const checked = this.listItems
      .filter(item => item.checked)
      .map(item => item.label);
    console.log('Checked items:', checked);
  }
}
```

**Querying DOM Elements:**

```typescript
// input-form.component.ts
import { Component, ViewChildren, QueryList, ElementRef, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-input-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <form class="input-form">
      <h3>User Registration</h3>
      
      <div class="form-group">
        <label>First Name</label>
        <input
          #nameInput
          type="text"
          class="form-control"
          [(ngModel)]="firstName"
          name="firstName"
        />
      </div>
      
      <div class="form-group">
        <label>Last Name</label>
        <input
          #nameInput
          type="text"
          class="form-control"
          [(ngModel)]="lastName"
          name="lastName"
        />
      </div>
      
      <div class="form-group">
        <label>Email</label>
        <input
          #nameInput
          type="email"
          class="form-control"
          [(ngModel)]="email"
          name="email"
        />
      </div>
      
      <div class="controls">
        <button type="button" (click)="focusFirst()">Focus First</button>
        <button type="button" (click)="clearAll()">Clear All</button>
        <button type="button" (click)="disableAll()">Disable All</button>
        <button type="button" (click)="enableAll()">Enable All</button>
      </div>
      
      <div class="info">
        Total inputs: {{ inputs.length }}
      </div>
    </form>
  `,
  styles: [`
    .form-group {
      margin-bottom: 16px;
    }
    .form-control {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .controls button {
      margin-right: 8px;
      padding: 8px 16px;
    }
    .info {
      margin-top: 16px;
      padding: 12px;
      background: #e9ecef;
    }
  `]
})
export class InputFormComponent implements AfterViewInit {
  // Query all input elements with #nameInput template reference
  @ViewChildren('nameInput') inputs!: QueryList<ElementRef<HTMLInputElement>>;
  
  firstName = '';
  lastName = '';
  email = '';

  ngAfterViewInit() {
    console.log('Input elements:', this.inputs.length);
  }

  focusFirst() {
    if (this.inputs.length > 0) {
      this.inputs.first.nativeElement.focus();
    }
  }

  clearAll() {
    this.inputs.forEach(input => {
      input.nativeElement.value = '';
    });
    // Also clear model
    this.firstName = '';
    this.lastName = '';
    this.email = '';
  }

  disableAll() {
    this.inputs.forEach(input => {
      input.nativeElement.disabled = true;
    });
  }

  enableAll() {
    this.inputs.forEach(input => {
      input.nativeElement.disabled = false;
    });
  }
}
```

**Advanced: Form Field Validation:**

```typescript
// form-field.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-form-field',
  standalone: true,
  template: `
    <div class="form-field">
      <label>{{ label }}</label>
      <ng-content></ng-content>
      @if (error) {
        <span class="error">{{ error }}</span>
      }
    </div>
  `,
  styles: [`
    .form-field {
      margin-bottom: 16px;
    }
    .error {
      color: #dc3545;
      font-size: 12px;
      display: block;
      margin-top: 4px;
    }
  `]
})
export class FormFieldComponent {
  @Input() label = '';
  error = '';

  // Public method to set error
  setError(message: string) {
    this.error = message;
  }

  // Public method to clear error
  clearError() {
    this.error = '';
  }

  // Public method to validate
  validate(value: string): boolean {
    if (!value || value.trim() === '') {
      this.setError('This field is required');
      return false;
    }
    this.clearError();
    return true;
  }
}

// registration-form.component.ts
import { Component, ViewChildren, QueryList } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { FormFieldComponent } from './form-field.component';

@Component({
  selector: 'app-registration-form',
  standalone: true,
  imports: [CommonModule, FormsModule, FormFieldComponent],
  template: `
    <form class="registration-form">
      <h2>User Registration</h2>
      
      <app-form-field label="Username">
        <input
          type="text"
          [(ngModel)]="formData.username"
          name="username"
          class="form-control"
        />
      </app-form-field>
      
      <app-form-field label="Email">
        <input
          type="email"
          [(ngModel)]="formData.email"
          name="email"
          class="form-control"
        />
      </app-form-field>
      
      <app-form-field label="Password">
        <input
          type="password"
          [(ngModel)]="formData.password"
          name="password"
          class="form-control"
        />
      </app-form-field>
      
      <app-form-field label="Confirm Password">
        <input
          type="password"
          [(ngModel)]="formData.confirmPassword"
          name="confirmPassword"
          class="form-control"
        />
      </app-form-field>
      
      <button type="button" (click)="validateForm()">Validate All</button>
      <button type="button" (click)="submit()">Submit</button>
      <button type="button" (click)="clearErrors()">Clear Errors</button>
    </form>
  `,
  styles: [`
    .registration-form {
      max-width: 500px;
      margin: 0 auto;
      padding: 20px;
    }
    .form-control {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    button {
      margin-right: 8px;
      padding: 8px 16px;
      margin-top: 16px;
    }
  `]
})
export class RegistrationFormComponent {
  // Query all FormFieldComponent instances
  @ViewChildren(FormFieldComponent) formFields!: QueryList<FormFieldComponent>;
  
  formData = {
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  };

  validateForm(): boolean {
    let isValid = true;
    const fields = this.formFields.toArray();
    
    // Validate username
    if (!fields[0].validate(this.formData.username)) {
      isValid = false;
    }
    
    // Validate email
    if (!fields[1].validate(this.formData.email)) {
      isValid = false;
    } else if (!this.isValidEmail(this.formData.email)) {
      fields[1].setError('Invalid email format');
      isValid = false;
    }
    
    // Validate password
    if (!fields[2].validate(this.formData.password)) {
      isValid = false;
    } else if (this.formData.password.length < 6) {
      fields[2].setError('Password must be at least 6 characters');
      isValid = false;
    }
    
    // Validate confirm password
    if (!fields[3].validate(this.formData.confirmPassword)) {
      isValid = false;
    } else if (this.formData.password !== this.formData.confirmPassword) {
      fields[3].setError('Passwords do not match');
      isValid = false;
    }
    
    return isValid;
  }

  submit() {
    if (this.validateForm()) {
      console.log('Form submitted:', this.formData);
      alert('Registration successful!');
    } else {
      alert('Please fix validation errors');
    }
  }

  clearErrors() {
    this.formFields.forEach(field => {
      field.clearError();
    });
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }
}
```

#### React: Equivalent Patterns with Refs

**useRef Array for Multiple Elements:**

```tsx
// TaskList.tsx
import React, { useRef, useState } from 'react';

interface Task {
  id: number;
  label: string;
  checked: boolean;
}

function TaskList() {
  const [tasks, setTasks] = useState<Task[]>([
    { id: 1, label: 'Buy groceries', checked: false },
    { id: 2, label: 'Walk the dog', checked: false },
    { id: 3, label: 'Study Angular', checked: false },
    { id: 4, label: 'Build project', checked: false }
  ]);
  
  // Array of refs for checkboxes
  const checkboxRefs = useRef<(HTMLInputElement | null)[]>([]);

  const selectAll = () => {
    setTasks(tasks.map(t => ({ ...t, checked: true })));
  };

  const deselectAll = () => {
    setTasks(tasks.map(t => ({ ...t, checked: false })));
  };

  const toggleAll = () => {
    setTasks(tasks.map(t => ({ ...t, checked: !t.checked })));
  };

  const logChecked = () => {
    const checked = tasks.filter(t => t.checked).map(t => t.label);
    console.log('Checked items:', checked);
  };

  const handleCheck = (id: number) => {
    setTasks(tasks.map(t =>
      t.id === id ? { ...t, checked: !t.checked } : t
    ));
  };

  return (
    <div className="list-container">
      <h3>Task List</h3>
      
      <div className="controls">
        <button onClick={selectAll}>Select All</button>
        <button onClick={deselectAll}>Deselect All</button>
        <button onClick={toggleAll}>Toggle All</button>
        <button onClick={logChecked}>Log Checked</button>
      </div>
      
      {tasks.map((task, index) => (
        <div key={task.id} className="list-item">
          <input
            type="checkbox"
            ref={el => checkboxRefs.current[index] = el}
            checked={task.checked}
            onChange={() => handleCheck(task.id)}
          />
          <span>{task.label}</span>
        </div>
      ))}
      
      <div className="summary">
        Total items: {tasks.length}
      </div>
    </div>
  );
}

export default TaskList;
```

**DOM Element Manipulation:**

```tsx
// InputForm.tsx
import React, { useRef, useState } from 'react';

function InputForm() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  
  // Array of refs for inputs
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const focusFirst = () => {
    inputRefs.current[0]?.focus();
  };

  const clearAll = () => {
    inputRefs.current.forEach(input => {
      if (input) input.value = '';
    });
    setFirstName('');
    setLastName('');
    setEmail('');
  };

  const disableAll = () => {
    inputRefs.current.forEach(input => {
      if (input) input.disabled = true;
    });
  };

  const enableAll = () => {
    inputRefs.current.forEach(input => {
      if (input) input.disabled = false;
    });
  };

  return (
    <form className="input-form">
      <h3>User Registration</h3>
      
      <div className="form-group">
        <label>First Name</label>
        <input
          ref={el => inputRefs.current[0] = el}
          type="text"
          className="form-control"
          value={firstName}
          onChange={(e) => setFirstName(e.target.value)}
        />
      </div>
      
      <div className="form-group">
        <label>Last Name</label>
        <input
          ref={el => inputRefs.current[1] = el}
          type="text"
          className="form-control"
          value={lastName}
          onChange={(e) => setLastName(e.target.value)}
        />
      </div>
      
      <div className="form-group">
        <label>Email</label>
        <input
          ref={el => inputRefs.current[2] = el}
          type="email"
          className="form-control"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </div>
      
      <div className="controls">
        <button type="button" onClick={focusFirst}>Focus First</button>
        <button type="button" onClick={clearAll}>Clear All</button>
        <button type="button" onClick={disableAll}>Disable All</button>
        <button type="button" onClick={enableAll}>Enable All</button>
      </div>
      
      <div className="info">
        Total inputs: {inputRefs.current.filter(r => r !== null).length}
      </div>
    </form>
  );
}

export default InputForm;
```

**useImperativeHandle for Child Control:**

```tsx
// FormField.tsx
import React, { forwardRef, useImperativeHandle, useState, ReactNode } from 'react';

interface FormFieldProps {
  label: string;
  children: ReactNode;
}

export interface FormFieldHandle {
  setError: (message: string) => void;
  clearError: () => void;
  validate: (value: string) => boolean;
}

const FormField = forwardRef<FormFieldHandle, FormFieldProps>(
  ({ label, children }, ref) => {
    const [error, setErrorState] = useState('');

    // Expose methods to parent
    useImperativeHandle(ref, () => ({
      setError(message: string) {
        setErrorState(message);
      },
      clearError() {
        setErrorState('');
      },
      validate(value: string) {
        if (!value || value.trim() === '') {
          setErrorState('This field is required');
          return false;
        }
        setErrorState('');
        return true;
      }
    }));

    return (
      <div className="form-field">
        <label>{label}</label>
        {children}
        {error && <span className="error">{error}</span>}
      </div>
    );
  }
);

export default FormField;

// RegistrationForm.tsx
import React, { useRef } from 'react';
import FormField, { FormFieldHandle } from './FormField';

function RegistrationForm() {
  const fieldRefs = useRef<(FormFieldHandle | null)[]>([]);
  const [formData, setFormData] = React.useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  });

  const validateForm = (): boolean => {
    let isValid = true;
    
    // Validate username
    if (!fieldRefs.current[0]?.validate(formData.username)) {
      isValid = false;
    }
    
    // Validate email
    if (!fieldRefs.current[1]?.validate(formData.email)) {
      isValid = false;
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      fieldRefs.current[1]?.setError('Invalid email format');
      isValid = false;
    }
    
    // Validate password
    if (!fieldRefs.current[2]?.validate(formData.password)) {
      isValid = false;
    } else if (formData.password.length < 6) {
      fieldRefs.current[2]?.setError('Password must be at least 6 characters');
      isValid = false;
    }
    
    // Validate confirm password
    if (!fieldRefs.current[3]?.validate(formData.confirmPassword)) {
      isValid = false;
    } else if (formData.password !== formData.confirmPassword) {
      fieldRefs.current[3]?.setError('Passwords do not match');
      isValid = false;
    }
    
    return isValid;
  };

  const submit = () => {
    if (validateForm()) {
      console.log('Form submitted:', formData);
      alert('Registration successful!');
    } else {
      alert('Please fix validation errors');
    }
  };

  const clearErrors = () => {
    fieldRefs.current.forEach(ref => ref?.clearError());
  };

  return (
    <form className="registration-form">
      <h2>User Registration</h2>
      
      <FormField ref={el => fieldRefs.current[0] = el} label="Username">
        <input
          type="text"
          value={formData.username}
          onChange={(e) => setFormData({ ...formData, username: e.target.value })}
          className="form-control"
        />
      </FormField>
      
      <FormField ref={el => fieldRefs.current[1] = el} label="Email">
        <input
          type="email"
          value={formData.email}
          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
          className="form-control"
        />
      </FormField>
      
      <FormField ref={el => fieldRefs.current[2] = el} label="Password">
        <input
          type="password"
          value={formData.password}
          onChange={(e) => setFormData({ ...formData, password: e.target.value })}
          className="form-control"
        />
      </FormField>
      
      <FormField ref={el => fieldRefs.current[3] = el} label="Confirm Password">
        <input
          type="password"
          value={formData.confirmPassword}
          onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
          className="form-control"
        />
      </FormField>
      
      <button type="button" onClick={validateForm}>Validate All</button>
      <button type="button" onClick={submit}>Submit</button>
      <button type="button" onClick={clearErrors}>Clear Errors</button>
    </form>
  );
}

export default RegistrationForm;
```

#### Comparison: @ViewChildren vs React Refs

| Feature | Angular @ViewChildren | React useRef Array |
|---------|---------------------|------------------|
| **Purpose** | Query child components/elements | Reference DOM elements |
| **Type** | QueryList<Type> | Array of RefObject |
| **Lifecycle** | AfterViewInit | Immediate |
| **Reactivity** | QueryList.changes | Re-render on state change |
| **Component Control** | Direct instance access | useImperativeHandle |

**When to Use:**
- **Angular @ViewChildren:** Batch operations on child components, form validation, focus management
- **React Refs:** DOM manipulation, focus control, integration with third-party libraries

**Further Reading:**
- [Angular ViewChildren](https://angular.dev/api/core/ViewChildren)
- [React useRef](https://react.dev/reference/react/useRef)
- [React useImperativeHandle](https://react.dev/reference/react/useImperativeHandle)

---

### 8. ControlValueAccessor

**Description:** ControlValueAccessor is an interface that allows custom form controls to integrate seamlessly with Angular's Reactive and Template-driven forms. It bridges the gap between your custom UI components and Angular's form APIs.

#### Angular: ControlValueAccessor Implementation

**Basic Custom Input Component:**

```typescript
// rating.component.ts
import { Component, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-rating',
  standalone: true,
  imports: [CommonModule],
  providers: [
    {
      // Register this component as a ControlValueAccessor
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => RatingComponent),
      multi: true
    }
  ],
  template: `
    <div class="rating">
      @for (star of stars; track $index; let i = $index) {
        <span
          class="star"
          [class.filled]="i < value"
          [class.disabled]="disabled"
          (click)="!disabled && setValue(i + 1)"
          (mouseenter)="!disabled && setHoverValue(i + 1)"
          (mouseleave)="!disabled && setHoverValue(0)"
        >
          {{ (hoverValue > 0 ? i < hoverValue : i < value) ? '★' : '☆' }}
        </span>
      }
      <span class="rating-value">{{ value }}/5</span>
    </div>
  `,
  styles: [`
    .rating {
      display: flex;
      align-items: center;
      gap: 5px;
    }
    .star {
      font-size: 24px;
      cursor: pointer;
      user-select: none;
      transition: color 0.2s;
    }
    .star.filled {
      color: #ffc107;
    }
    .star:not(.filled) {
      color: #ccc;
    }
    .star.disabled {
      cursor: not-allowed;
      opacity: 0.5;
    }
    .star:hover:not(.disabled) {
      transform: scale(1.2);
    }
    .rating-value {
      margin-left: 8px;
      font-size: 14px;
      color: #666;
    }
  `]
})
export class RatingComponent implements ControlValueAccessor {
  stars = [1, 2, 3, 4, 5];
  value = 0;
  hoverValue = 0;
  disabled = false;
  
  // Callbacks for ControlValueAccessor
  private onChange: (value: number) => void = () => {};
  private onTouched: () => void = () => {};

  // Called when form control value changes
  writeValue(value: number): void {
    this.value = value || 0;
  }

  // Register callback for value changes
  registerOnChange(fn: (value: number) => void): void {
    this.onChange = fn;
  }

  // Register callback for touched state
  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  // Called when form control is disabled/enabled
  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  // Update value and notify Angular
  setValue(value: number): void {
    this.value = value;
    this.onChange(value); // Notify Angular of change
    this.onTouched(); // Mark as touched
  }

  setHoverValue(value: number): void {
    this.hoverValue = value;
  }
}

// Usage with Reactive Forms
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RatingComponent } from './rating.component';

@Component({
  selector: 'app-product-review',
  standalone: true,
  imports: [ReactiveFormsModule, RatingComponent],
  template: `
    <form [formGroup]="reviewForm" (ngSubmit)="onSubmit()">
      <h3>Product Review</h3>
      
      <div class="form-group">
        <label>Rating</label>
        <app-rating formControlName="rating"></app-rating>
        @if (rating.invalid && rating.touched) {
          <span class="error">Rating is required</span>
        }
      </div>
      
      <div class="form-group">
        <label>Comment</label>
        <textarea formControlName="comment"></textarea>
      </div>
      
      <button type="submit" [disabled]="reviewForm.invalid">Submit Review</button>
      
      <div class="preview">
        <h4>Form Value:</h4>
        <pre>{{ reviewForm.value | json }}</pre>
      </div>
    </form>
  `
})
export class ProductReviewComponent {
  reviewForm = new FormGroup({
    rating: new FormControl(0, [Validators.required, Validators.min(1)]),
    comment: new FormControl('', Validators.required)
  });

  get rating() {
    return this.reviewForm.get('rating')!;
  }

  onSubmit() {
    if (this.reviewForm.valid) {
      console.log('Review submitted:', this.reviewForm.value);
    }
  }
}
```

**Advanced: Custom Date Range Picker:**

```typescript
// date-range.model.ts
export interface DateRange {
  start: Date | null;
  end: Date | null;
}

// date-range-picker.component.ts
import { Component, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { DateRange } from './date-range.model';

@Component({
  selector: 'app-date-range-picker',
  standalone: true,
  imports: [CommonModule, FormsModule],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => DateRangePickerComponent),
      multi: true
    }
  ],
  template: `
    <div class="date-range-picker" [class.disabled]="disabled">
      <div class="input-group">
        <label>Start Date</label>
        <input
          type="date"
          [value]="formatDate(value?.start)"
          (change)="onStartChange($event)"
          [disabled]="disabled"
        />
      </div>
      
      <div class="separator">to</div>
      
      <div class="input-group">
        <label>End Date</label>
        <input
          type="date"
          [value]="formatDate(value?.end)"
          (change)="onEndChange($event)"
          [disabled]="disabled"
          [min]="formatDate(value?.start)"
        />
      </div>
      
      @if (value?.start && value?.end) {
        <div class="range-info">
          Duration: {{ calculateDays() }} days
        </div>
      }
    </div>
  `,
  styles: [`
    .date-range-picker {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 12px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .date-range-picker.disabled {
      opacity: 0.5;
      pointer-events: none;
    }
    .input-group {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .input-group label {
      font-size: 12px;
      color: #666;
    }
    .input-group input {
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .separator {
      color: #999;
      font-weight: bold;
    }
    .range-info {
      padding: 8px;
      background: #e3f2fd;
      border-radius: 4px;
      font-size: 12px;
    }
  `]
})
export class DateRangePickerComponent implements ControlValueAccessor {
  value: DateRange = { start: null, end: null };
  disabled = false;
  
  private onChange: (value: DateRange) => void = () => {};
  private onTouched: () => void = () => {};

  writeValue(value: DateRange): void {
    this.value = value || { start: null, end: null };
  }

  registerOnChange(fn: (value: DateRange) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  onStartChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.value = {
      ...this.value,
      start: input.value ? new Date(input.value) : null
    };
    this.onChange(this.value);
    this.onTouched();
  }

  onEndChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    this.value = {
      ...this.value,
      end: input.value ? new Date(input.value) : null
    };
    this.onChange(this.value);
    this.onTouched();
  }

  formatDate(date: Date | null | undefined): string {
    if (!date) return '';
    return new Date(date).toISOString().split('T')[0];
  }

  calculateDays(): number {
    if (!this.value.start || !this.value.end) return 0;
    const diff = this.value.end.getTime() - this.value.start.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  }
}

// Usage
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { DateRangePickerComponent } from './date-range-picker.component';

@Component({
  selector: 'app-booking-form',
  standalone: true,
  imports: [ReactiveFormsModule, DateRangePickerComponent],
  template: `
    <form [formGroup]="bookingForm" (ngSubmit)="onSubmit()">
      <h3>Hotel Booking</h3>
      
      <app-date-range-picker formControlName="dateRange"></app-date-range-picker>
      
      <button type="submit">Book Now</button>
      
      <pre>{{ bookingForm.value | json }}</pre>
    </form>
  `
})
export class BookingFormComponent {
  bookingForm = new FormGroup({
    dateRange: new FormControl<DateRange>({
      start: new Date(),
      end: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    })
  });

  onSubmit() {
    console.log('Booking:', this.bookingForm.value);
  }
}
```

**Complex: Tags Input Component:**

```typescript
// tags-input.component.ts
import { Component, forwardRef } from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-tags-input',
  standalone: true,
  imports: [CommonModule, FormsModule],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => TagsInputComponent),
      multi: true
    }
  ],
  template: `
    <div class="tags-input" [class.disabled]="disabled" (click)="inputElement.focus()">
      <div class="tags-container">
        @for (tag of value; track tag; let i = $index) {
          <span class="tag">
            {{ tag }}
            <button
              type="button"
              class="remove-tag"
              (click)="removeTag(i)"
              [disabled]="disabled"
            >
              ×
            </button>
          </span>
        }
        
        <input
          #inputElement
          type="text"
          class="tag-input"
          [(ngModel)]="inputValue"
          (keydown.enter)="addTag($event)"
          (keydown.backspace)="onBackspace($event)"
          (blur)="onBlur()"
          [disabled]="disabled"
          placeholder="{{ value.length === 0 ? 'Add tags...' : '' }}"
        />
      </div>
    </div>
  `,
  styles: [`
    .tags-input {
      min-height: 40px;
      padding: 4px;
      border: 1px solid #ddd;
      border-radius: 4px;
      cursor: text;
    }
    .tags-input.disabled {
      background: #f5f5f5;
      cursor: not-allowed;
    }
    .tags-container {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
      align-items: center;
    }
    .tag {
      display: inline-flex;
      align-items: center;
      padding: 4px 8px;
      background: #007bff;
      color: white;
      border-radius: 12px;
      font-size: 14px;
      gap: 4px;
    }
    .remove-tag {
      border: none;
      background: none;
      color: white;
      font-size: 18px;
      cursor: pointer;
      padding: 0;
      width: 16px;
      height: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .remove-tag:hover {
      background: rgba(255, 255, 255, 0.2);
      border-radius: 50%;
    }
    .tag-input {
      border: none;
      outline: none;
      flex: 1;
      min-width: 100px;
      padding: 4px;
      font-size: 14px;
    }
  `]
})
export class TagsInputComponent implements ControlValueAccessor {
  value: string[] = [];
  inputValue = '';
  disabled = false;
  
  private onChange: (value: string[]) => void = () => {};
  private onTouched: () => void = () => {};

  writeValue(value: string[]): void {
    this.value = value || [];
  }

  registerOnChange(fn: (value: string[]) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }

  addTag(event: Event): void {
    event.preventDefault();
    const tag = this.inputValue.trim();
    
    if (tag && !this.value.includes(tag)) {
      this.value = [...this.value, tag];
      this.inputValue = '';
      this.onChange(this.value);
      this.onTouched();
    }
  }

  removeTag(index: number): void {
    this.value = this.value.filter((_, i) => i !== index);
    this.onChange(this.value);
    this.onTouched();
  }

  onBackspace(event: KeyboardEvent): void {
    // Remove last tag if input is empty
    if (this.inputValue === '' && this.value.length > 0) {
      event.preventDefault();
      this.removeTag(this.value.length - 1);
    }
  }

  onBlur(): void {
    // Add tag on blur if there's input
    if (this.inputValue.trim()) {
      const tag = this.inputValue.trim();
      if (!this.value.includes(tag)) {
        this.value = [...this.value, tag];
        this.onChange(this.value);
      }
      this.inputValue = '';
    }
    this.onTouched();
  }
}

// Usage
import { Component } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { TagsInputComponent } from './tags-input.component';

@Component({
  selector: 'app-article-form',
  standalone: true,
  imports: [ReactiveFormsModule, TagsInputComponent],
  template: `
    <form [formGroup]="articleForm" (ngSubmit)="onSubmit()">
      <h3>Create Article</h3>
      
      <div class="form-group">
        <label>Title</label>
        <input type="text" formControlName="title" />
      </div>
      
      <div class="form-group">
        <label>Tags</label>
        <app-tags-input formControlName="tags"></app-tags-input>
        @if (tags.invalid && tags.touched) {
          <span class="error">At least one tag is required</span>
        }
      </div>
      
      <button type="submit" [disabled]="articleForm.invalid">Publish</button>
      
      <pre>{{ articleForm.value | json }}</pre>
    </form>
  `
})
export class ArticleFormComponent {
  articleForm = new FormGroup({
    title: new FormControl('', Validators.required),
    tags: new FormControl<string[]>([], [Validators.required, Validators.minLength(1)])
  });

  get tags() {
    return this.articleForm.get('tags')!;
  }

  onSubmit() {
    if (this.articleForm.valid) {
      console.log('Article published:', this.articleForm.value);
    }
  }
}
```

#### React: Equivalent Patterns

**Controlled Component Pattern:**

```tsx
// Rating.tsx
import React, { useState } from 'react';

interface RatingProps {
  value: number;
  onChange: (value: number) => void;
  disabled?: boolean;
}

function Rating({ value, onChange, disabled = false }: RatingProps) {
  const [hoverValue, setHoverValue] = useState(0);
  const stars = [1, 2, 3, 4, 5];

  return (
    <div className="rating">
      {stars.map((star, index) => (
        <span
          key={star}
          className={`star ${index < value ? 'filled' : ''} ${disabled ? 'disabled' : ''}`}
          onClick={() => !disabled && onChange(index + 1)}
          onMouseEnter={() => !disabled && setHoverValue(index + 1)}
          onMouseLeave={() => !disabled && setHoverValue(0)}
        >
          {(hoverValue > 0 ? index < hoverValue : index < value) ? '★' : '☆'}
        </span>
      ))}
      <span className="rating-value">{value}/5</span>
    </div>
  );
}

// Usage
function ProductReview() {
  const [formData, setFormData] = useState({
    rating: 0,
    comment: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const newErrors: Record<string, string> = {};
    if (formData.rating < 1) newErrors.rating = 'Rating is required';
    if (!formData.comment) newErrors.comment = 'Comment is required';
    
    setErrors(newErrors);
    
    if (Object.keys(newErrors).length === 0) {
      console.log('Review submitted:', formData);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h3>Product Review</h3>
      
      <div className="form-group">
        <label>Rating</label>
        <Rating
          value={formData.rating}
          onChange={(rating) => setFormData({ ...formData, rating })}
        />
        {errors.rating && <span className="error">{errors.rating}</span>}
      </div>
      
      <div className="form-group">
        <label>Comment</label>
        <textarea
          value={formData.comment}
          onChange={(e) => setFormData({ ...formData, comment: e.target.value })}
        />
        {errors.comment && <span className="error">{errors.comment}</span>}
      </div>
      
      <button type="submit">Submit Review</button>
      
      <pre>{JSON.stringify(formData, null, 2)}</pre>
    </form>
  );
}

export default ProductReview;
```

**Date Range Picker:**

```tsx
// DateRangePicker.tsx
import React from 'react';

interface DateRange {
  start: Date | null;
  end: Date | null;
}

interface DateRangePickerProps {
  value: DateRange;
  onChange: (value: DateRange) => void;
  disabled?: boolean;
}

function DateRangePicker({ value, onChange, disabled = false }: DateRangePickerProps) {
  const formatDate = (date: Date | null): string => {
    if (!date) return '';
    return date.toISOString().split('T')[0];
  };

  const calculateDays = (): number => {
    if (!value.start || !value.end) return 0;
    const diff = value.end.getTime() - value.start.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  };

  return (
    <div className={`date-range-picker ${disabled ? 'disabled' : ''}`}>
      <div className="input-group">
        <label>Start Date</label>
        <input
          type="date"
          value={formatDate(value.start)}
          onChange={(e) => onChange({
            ...value,
            start: e.target.value ? new Date(e.target.value) : null
          })}
          disabled={disabled}
        />
      </div>
      
      <div className="separator">to</div>
      
      <div className="input-group">
        <label>End Date</label>
        <input
          type="date"
          value={formatDate(value.end)}
          onChange={(e) => onChange({
            ...value,
            end: e.target.value ? new Date(e.target.value) : null
          })}
          disabled={disabled}
          min={formatDate(value.start)}
        />
      </div>
      
      {value.start && value.end && (
        <div className="range-info">
          Duration: {calculateDays()} days
        </div>
      )}
    </div>
  );
}

// Usage
function BookingForm() {
  const [dateRange, setDateRange] = React.useState<DateRange>({
    start: new Date(),
    end: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Booking:', dateRange);
  };

  return (
    <form onSubmit={handleSubmit}>
      <h3>Hotel Booking</h3>
      <DateRangePicker value={dateRange} onChange={setDateRange} />
      <button type="submit">Book Now</button>
      <pre>{JSON.stringify(dateRange, null, 2)}</pre>
    </form>
  );
}

export default BookingForm;
```

**Tags Input:**

```tsx
// TagsInput.tsx
import React, { useState, useRef, KeyboardEvent } from 'react';

interface TagsInputProps {
  value: string[];
  onChange: (value: string[]) => void;
  disabled?: boolean;
}

function TagsInput({ value, onChange, disabled = false }: TagsInputProps) {
  const [inputValue, setInputValue] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  const addTag = () => {
    const tag = inputValue.trim();
    if (tag && !value.includes(tag)) {
      onChange([...value, tag]);
      setInputValue('');
    }
  };

  const removeTag = (index: number) => {
    onChange(value.filter((_, i) => i !== index));
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      addTag();
    } else if (e.key === 'Backspace' && inputValue === '' && value.length > 0) {
      e.preventDefault();
      removeTag(value.length - 1);
    }
  };

  const handleBlur = () => {
    if (inputValue.trim()) {
      addTag();
    }
  };

  return (
    <div
      className={`tags-input ${disabled ? 'disabled' : ''}`}
      onClick={() => inputRef.current?.focus()}
    >
      <div className="tags-container">
        {value.map((tag, index) => (
          <span key={index} className="tag">
            {tag}
            <button
              type="button"
              className="remove-tag"
              onClick={() => removeTag(index)}
              disabled={disabled}
            >
              ×
            </button>
          </span>
        ))}
        
        <input
          ref={inputRef}
          type="text"
          className="tag-input"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyDown={handleKeyDown}
          onBlur={handleBlur}
          disabled={disabled}
          placeholder={value.length === 0 ? 'Add tags...' : ''}
        />
      </div>
    </div>
  );
}

// Usage
function ArticleForm() {
  const [formData, setFormData] = useState({
    title: '',
    tags: [] as string[]
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const newErrors: Record<string, string> = {};
    if (!formData.title) newErrors.title = 'Title is required';
    if (formData.tags.length === 0) newErrors.tags = 'At least one tag is required';
    
    setErrors(newErrors);
    
    if (Object.keys(newErrors).length === 0) {
      console.log('Article published:', formData);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h3>Create Article</h3>
      
      <div className="form-group">
        <label>Title</label>
        <input
          type="text"
          value={formData.title}
          onChange={(e) => setFormData({ ...formData, title: e.target.value })}
        />
        {errors.title && <span className="error">{errors.title}</span>}
      </div>
      
      <div className="form-group">
        <label>Tags</label>
        <TagsInput
          value={formData.tags}
          onChange={(tags) => setFormData({ ...formData, tags })}
        />
        {errors.tags && <span className="error">{errors.tags}</span>}
      </div>
      
      <button type="submit">Publish</button>
      
      <pre>{JSON.stringify(formData, null, 2)}</pre>
    </form>
  );
}

export default ArticleForm;
```

#### Comparison: ControlValueAccessor

| Feature | Angular CVA | React Controlled Components |
|---------|------------|---------------------------|
| **Integration** | NG_VALUE_ACCESSOR | Props (value + onChange) |
| **Validation** | Integrated with forms | Manual or library |
| **API** | writeValue, registerOnChange | value, onChange props |
| **Disabled State** | setDisabledState | disabled prop |
| **Touched State** | registerOnTouched | onBlur handling |

**When to Use:**
- **Angular ControlValueAccessor:** Custom form controls that integrate with Reactive/Template-driven forms
- **React Controlled Components:** Custom inputs with value/onChange pattern

**Further Reading:**
- [Angular ControlValueAccessor](https://angular.dev/api/forms/ControlValueAccessor)
- [React Controlled Components](https://react.dev/reference/react-dom/components/input#controlling-an-input-with-a-state-variable)

---

### 9. ChangeDetectorRef

**Description:** ChangeDetectorRef allows you to manually control change detection in Angular. This is useful for performance optimization, working with third-party libraries, or handling complex asynchronous scenarios.

#### Angular: ChangeDetectorRef Examples

**Manual Change Detection:**

```typescript
// counter.component.ts
import { Component, ChangeDetectorRef, ChangeDetectionStrategy, inject } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  // OnPush: only check when inputs change or events fire
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="counter">
      <h3>Counter: {{ count }}</h3>
      <p>Last update: {{ lastUpdate }}</p>
      
      <div class="controls">
        <button (click)="increment()">Increment (Detects)</button>
        <button (click)="incrementSilent()">Increment Silent</button>
        <button (click)="detectChanges()">Detect Changes</button>
        <button (click)="markForCheck()">Mark for Check</button>
      </div>
      
      <div class="info">
        <p>This component uses OnPush change detection.</p>
        <p>Silent increment won't update view until detection triggered.</p>
      </div>
    </div>
  `,
  styles: [`
    .counter {
      padding: 20px;
      border: 2px solid #007bff;
      border-radius: 8px;
    }
    .controls button {
      margin: 5px;
      padding: 8px 16px;
    }
    .info {
      margin-top: 16px;
      padding: 12px;
      background: #e7f3ff;
      border-radius: 4px;
      font-size: 14px;
    }
  `]
})
export class CounterComponent {
  private cdr = inject(ChangeDetectorRef);
  
  count = 0;
  lastUpdate = new Date().toLocaleTimeString();

  // Normal increment - triggers change detection automatically
  increment() {
    this.count++;
    this.lastUpdate = new Date().toLocaleTimeString();
  }

  // Silent increment - doesn't trigger change detection
  incrementSilent() {
    this.count++;
    this.lastUpdate = new Date().toLocaleTimeString();
    // View won't update because of OnPush strategy
  }

  // Manually trigger change detection
  detectChanges() {
    this.cdr.detectChanges();
  }

  // Mark component and ancestors for check in next cycle
  markForCheck() {
    this.cdr.markForCheck();
  }
}
```

**Detaching and Reattaching:**

```typescript
// live-data.component.ts
import { Component, ChangeDetectorRef, OnInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-live-data',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="live-data">
      <h3>Live Data Stream</h3>
      
      <div class="stats">
        <div class="stat">
          <label>Updates Received:</label>
          <span>{{ updateCount }}</span>
        </div>
        <div class="stat">
          <label>Render Count:</label>
          <span>{{ renderCount }}</span>
        </div>
        <div class="stat">
          <label>Current Value:</label>
          <span>{{ currentValue }}</span>
        </div>
        <div class="stat">
          <label>Status:</label>
          <span [class]="'status-' + status">{{ status }}</span>
        </div>
      </div>
      
      <div class="controls">
        <button (click)="start()">Start</button>
        <button (click)="pause()">Pause (Detach)</button>
        <button (click)="resume()">Resume (Reattach)</button>
        <button (click)="refresh()">Manual Refresh</button>
      </div>
      
      <div class="info">
        <p><strong>Detached:</strong> Updates still arrive but view doesn't re-render</p>
        <p><strong>Efficiency:</strong> {{ efficiency }}%</p>
      </div>
    </div>
  `,
  styles: [`
    .live-data {
      padding: 20px;
      border: 2px solid #28a745;
      border-radius: 8px;
    }
    .stats {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 12px;
      margin: 16px 0;
    }
    .stat {
      padding: 12px;
      background: #f8f9fa;
      border-radius: 4px;
    }
    .stat label {
      display: block;
      font-size: 12px;
      color: #666;
      margin-bottom: 4px;
    }
    .stat span {
      font-size: 20px;
      font-weight: bold;
    }
    .status-active {
      color: #28a745;
    }
    .status-paused {
      color: #ffc107;
    }
    .status-stopped {
      color: #dc3545;
    }
    .controls button {
      margin: 5px;
      padding: 8px 16px;
    }
    .info {
      margin-top: 16px;
      padding: 12px;
      background: #d4edda;
      border-radius: 4px;
    }
  `]
})
export class LiveDataComponent implements OnInit, OnDestroy {
  private cdr = inject(ChangeDetectorRef);
  private intervalId?: number;
  
  updateCount = 0;
  renderCount = 0;
  currentValue = 0;
  status: 'active' | 'paused' | 'stopped' = 'stopped';
  
  get efficiency(): number {
    if (this.updateCount === 0) return 100;
    return Math.round((this.renderCount / this.updateCount) * 100);
  }

  ngOnInit() {
    this.start();
  }

  ngOnDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  start() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
    
    this.status = 'active';
    this.cdr.reattach(); // Ensure attached
    
    // Simulate data updates every 100ms
    this.intervalId = window.setInterval(() => {
      this.updateCount++;
      this.renderCount++;
      this.currentValue = Math.floor(Math.random() * 1000);
    }, 100);
  }

  pause() {
    this.status = 'paused';
    // Detach change detection - updates continue but no rendering
    this.cdr.detach();
  }

  resume() {
    this.status = 'active';
    // Reattach change detection
    this.cdr.reattach();
  }

  refresh() {
    // Manually detect changes while detached
    this.renderCount++;
    this.cdr.detectChanges();
  }
}
```

**Working with Observables:**

```typescript
// async-data.component.ts
import { Component, ChangeDetectorRef, ChangeDetectionStrategy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { interval, Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

interface DataPoint {
  timestamp: Date;
  value: number;
}

@Component({
  selector: 'app-async-data',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="async-data">
      <h3>Async Data with Manual Detection</h3>
      
      @if (loading) {
        <div class="loading">Loading...</div>
      } @else {
        <div class="data-list">
          @for (point of dataPoints; track point.timestamp) {
            <div class="data-point">
              <span class="time">{{ point.timestamp.toLocaleTimeString() }}</span>
              <span class="value">{{ point.value }}</span>
            </div>
          }
        </div>
      }
      
      <div class="summary">
        Total points: {{ dataPoints.length }}
      </div>
    </div>
  `,
  styles: [`
    .async-data {
      padding: 20px;
      border: 2px solid #6c757d;
      border-radius: 8px;
    }
    .data-point {
      display: flex;
      justify-content: space-between;
      padding: 8px;
      border-bottom: 1px solid #ddd;
    }
    .time {
      color: #666;
      font-size: 14px;
    }
    .value {
      font-weight: bold;
      font-size: 18px;
    }
    .summary {
      margin-top: 16px;
      padding: 12px;
      background: #e9ecef;
      text-align: center;
    }
    .loading {
      text-align: center;
      padding: 40px;
      color: #666;
    }
  `]
})
export class AsyncDataComponent implements OnInit {
  private cdr = inject(ChangeDetectorRef);
  private destroy$ = new Subject<void>();
  
  dataPoints: DataPoint[] = [];
  loading = true;

  ngOnInit() {
    // Simulate async data stream
    interval(1000)
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => {
        // Data updates outside Angular zone
        this.dataPoints.push({
          timestamp: new Date(),
          value: Math.floor(Math.random() * 100)
        });
        
        // Manually trigger change detection
        this.cdr.markForCheck();
        
        if (this.dataPoints.length === 1) {
          this.loading = false;
        }
      });
  }

  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

#### React: Equivalent Patterns

**Force Update Pattern:**

```tsx
// Counter.tsx
import React, { useState, useReducer } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  const [, forceUpdate] = useReducer(x => x + 1, 0);
  const [lastUpdate, setLastUpdate] = useState(new Date().toLocaleTimeString());
  
  // Mutable ref that doesn't trigger re-render
  const silentCountRef = React.useRef(0);

  const increment = () => {
    setCount(count + 1);
    setLastUpdate(new Date().toLocaleTimeString());
  };

  const incrementSilent = () => {
    // Update ref - doesn't trigger re-render
    silentCountRef.current++;
    console.log('Silent count:', silentCountRef.current);
  };

  const forceRender = () => {
    // Force re-render to show silent updates
    forceUpdate();
    setLastUpdate(new Date().toLocaleTimeString());
  };

  return (
    <div className="counter">
      <h3>Counter: {count}</h3>
      <h3>Silent Counter: {silentCountRef.current}</h3>
      <p>Last update: {lastUpdate}</p>
      
      <div className="controls">
        <button onClick={increment}>Increment (Re-renders)</button>
        <button onClick={incrementSilent}>Increment Silent</button>
        <button onClick={forceRender}>Force Re-render</button>
      </div>
      
      <div className="info">
        <p>Silent increment updates ref but doesn't trigger re-render.</p>
      </div>
    </div>
  );
}

export default Counter;
```

**Live Data with Manual Control:**

```tsx
// LiveData.tsx
import React, { useState, useEffect, useRef } from 'react';

function LiveData() {
  const [updateCount, setUpdateCount] = useState(0);
  const [renderCount, setRenderCount] = useState(0);
  const [currentValue, setCurrentValue] = useState(0);
  const [status, setStatus] = useState<'active' | 'paused' | 'stopped'>('stopped');
  
  const intervalRef = useRef<number>();
  const pausedDataRef = useRef({ updateCount: 0, value: 0 });

  const start = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
    
    setStatus('active');
    
    intervalRef.current = window.setInterval(() => {
      setUpdateCount(prev => prev + 1);
      setRenderCount(prev => prev + 1);
      setCurrentValue(Math.floor(Math.random() * 1000));
    }, 100);
  };

  const pause = () => {
    setStatus('paused');
    // Store current state but keep interval running
    if (intervalRef.current) {
      clearInterval(intervalRef.current);
    }
    
    // Continue updating in background without triggering renders
    intervalRef.current = window.setInterval(() => {
      pausedDataRef.current.updateCount++;
      pausedDataRef.current.value = Math.floor(Math.random() * 1000);
    }, 100);
  };

  const resume = () => {
    setStatus('active');
    // Sync state with paused data
    setUpdateCount(prev => prev + pausedDataRef.current.updateCount);
    setCurrentValue(pausedDataRef.current.value);
    pausedDataRef.current = { updateCount: 0, value: 0 };
    start();
  };

  const refresh = () => {
    // Manual refresh - sync paused data
    setRenderCount(prev => prev + 1);
    setUpdateCount(prev => prev + pausedDataRef.current.updateCount);
    setCurrentValue(pausedDataRef.current.value);
    pausedDataRef.current = { updateCount: 0, value: 0 };
  };

  useEffect(() => {
    start();
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  const efficiency = updateCount === 0 ? 100 : Math.round((renderCount / updateCount) * 100);

  return (
    <div className="live-data">
      <h3>Live Data Stream</h3>
      
      <div className="stats">
        <div className="stat">
          <label>Updates Received:</label>
          <span>{updateCount}</span>
        </div>
        <div className="stat">
          <label>Render Count:</label>
          <span>{renderCount}</span>
        </div>
        <div className="stat">
          <label>Current Value:</label>
          <span>{currentValue}</span>
        </div>
        <div className="stat">
          <label>Status:</label>
          <span className={`status-${status}`}>{status}</span>
        </div>
      </div>
      
      <div className="controls">
        <button onClick={start}>Start</button>
        <button onClick={pause}>Pause</button>
        <button onClick={resume}>Resume</button>
        <button onClick={refresh}>Manual Refresh</button>
      </div>
      
      <div className="info">
        <p><strong>Paused:</strong> Updates still arrive but view doesn't re-render</p>
        <p><strong>Efficiency:</strong> {efficiency}%</p>
      </div>
    </div>
  );
}

export default LiveData;
```

#### Comparison: ChangeDetectorRef

| Feature | Angular ChangeDetectorRef | React Re-render Control |
|---------|-------------------------|----------------------|
| **Manual Detection** | detectChanges() | forceUpdate() |
| **Mark for Check** | markForCheck() | setState() |
| **Detach** | detach() | useRef (skip renders) |
| **Reattach** | reattach() | useState (resume renders) |
| **Strategy** | ChangeDetectionStrategy | React.memo, useMemo |

**When to Use:**
- **Angular ChangeDetectorRef:** OnPush optimization, third-party library integration, complex async scenarios
- **React:** useMemo, React.memo for optimization; forceUpdate for edge cases

**Further Reading:**
- [Angular Change Detection](https://angular.dev/best-practices/runtime-performance)
- [React Optimization](https://react.dev/reference/react/memo)

---

## 📝 Summary: Core Concepts (Part 3 Complete)

This part covered the final 6 Core Concepts:

1. ✅ **ng-container** - Logical grouping without DOM overhead
2. ✅ **Dynamic Components** - Runtime component creation and insertion
3. ✅ **@ContentChild/@ContentChildren** - Accessing projected content
4. ✅ **@ViewChildren** - Querying child elements in template
5. ✅ **ControlValueAccessor** - Custom form control integration
6. ✅ **ChangeDetectorRef** - Manual change detection control

**Next:** Part 4 will cover all 9 Advanced Features (Angular Universal SSR, Angular Elements, Service Workers, etc.)

