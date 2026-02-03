# Angular Advanced Features vs ReactJS: Complete Study Guide (Part 2)

> **Continuation of the Complete Angular Features Guide**  
> This file continues with Core Concepts, Advanced Features, Routing Features, and Tooling & DevOps.

---

## 🟠 Core Concepts (Continued) {#core-concepts}

### 1. NgModules Deep Dive

**Description:** NgModules organize Angular applications into cohesive blocks of functionality. They define compilation context, configure dependency injection, and manage component, directive, and pipe visibility. Understanding `forRoot()` and `forChild()` patterns is essential for creating reusable modules.

#### Angular: NgModules with forRoot() and forChild()

**Basic Module:**

```typescript
// shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

// Components
import { CardComponent } from './components/card.component';
import { ButtonComponent } from './components/button.component';

// Directives
import { HighlightDirective } from './directives/highlight.directive';

// Pipes
import { TruncatePipe } from './pipes/truncate.pipe';

@NgModule({
  declarations: [
    // Components, directives, pipes declared in this module
    CardComponent,
    ButtonComponent,
    HighlightDirective,
    TruncatePipe
  ],
  imports: [
    // Modules this module depends on
    CommonModule,
    FormsModule
  ],
  exports: [
    // What this module exposes to importing modules
    CardComponent,
    ButtonComponent,
    HighlightDirective,
    TruncatePipe,
    // Re-export commonly used modules
    CommonModule,
    FormsModule
  ]
})
export class SharedModule { }
```

**forRoot() Pattern (Singleton Services):**

```typescript
// core.module.ts
import { NgModule, ModuleWithProviders } from '@angular/core';
import { CommonModule } from '@angular/common';

// Services that should be singletons
import { AuthService } from './services/auth.service';
import { LoggerService } from './services/logger.service';
import { ConfigService } from './services/config.service';

// Configuration interface
export interface CoreModuleConfig {
  apiUrl: string;
  logLevel: 'debug' | 'info' | 'warn' | 'error';
}

@NgModule({
  imports: [CommonModule],
  declarations: []
})
export class CoreModule {
  // forRoot() creates a module with providers (singletons)
  static forRoot(config: CoreModuleConfig): ModuleWithProviders<CoreModule> {
    return {
      ngModule: CoreModule,
      providers: [
        // Services provided at root level
        AuthService,
        LoggerService,
        ConfigService,
        // Configuration token
        { provide: 'APP_CONFIG', useValue: config }
      ]
    };
  }
  
  // Optional: Prevent re-importing in lazy modules
  constructor(@Optional() @SkipSelf() parentModule?: CoreModule) {
    if (parentModule) {
      throw new Error('CoreModule is already loaded. Import it only once in AppModule.');
    }
  }
}

// Usage in app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { CoreModule } from './core/core.module';

@NgModule({
  imports: [
    BrowserModule,
    // Call forRoot() only once in root module
    CoreModule.forRoot({
      apiUrl: 'https://api.example.com',
      logLevel: 'info'
    })
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

**forChild() Pattern (Feature Modules):**

```typescript
// user.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Routes } from '@angular/router';

// Feature components
import { UserListComponent } from './components/user-list.component';
import { UserDetailComponent } from './components/user-detail.component';
import { UserEditComponent } from './components/user-edit.component';

// Feature service (not singleton - one per lazy-loaded module)
import { UserService } from './services/user.service';

const routes: Routes = [
  { path: '', component: UserListComponent },
  { path: ':id', component: UserDetailComponent },
  { path: ':id/edit', component: UserEditComponent }
];

@NgModule({
  declarations: [
    UserListComponent,
    UserDetailComponent,
    UserEditComponent
  ],
  imports: [
    CommonModule,
    RouterModule.forChild(routes) // Use forChild() in feature modules
  ],
  providers: [
    UserService // Provided at feature module level
  ]
})
export class UserModule { }

// Lazy loading in app routing
const appRoutes: Routes = [
  {
    path: 'users',
    loadChildren: () => import('./user/user.module').then(m => m.UserModule)
  }
];
```

**Advanced: Configurable Feature Module:**

```typescript
// payment.module.ts
import { NgModule, ModuleWithProviders } from '@angular/core';
import { CommonModule } from '@angular/common';

import { PaymentComponent } from './payment.component';
import { PaymentService } from './payment.service';

export interface PaymentConfig {
  apiKey: string;
  environment: 'sandbox' | 'production';
  currency: string;
}

@NgModule({
  declarations: [PaymentComponent],
  imports: [CommonModule],
  exports: [PaymentComponent]
})
export class PaymentModule {
  // forRoot() for app-wide configuration
  static forRoot(config: PaymentConfig): ModuleWithProviders<PaymentModule> {
    return {
      ngModule: PaymentModule,
      providers: [
        PaymentService,
        { provide: 'PAYMENT_CONFIG', useValue: config }
      ]
    };
  }
  
  // forChild() for lazy-loaded modules
  static forChild(): ModuleWithProviders<PaymentModule> {
    return {
      ngModule: PaymentModule,
      providers: [] // No providers in child
    };
  }
}

// Usage:
// In AppModule: PaymentModule.forRoot({ apiKey: 'xxx', environment: 'sandbox', currency: 'USD' })
// In Lazy Module: PaymentModule.forChild()
```

#### React: Equivalent Patterns

**React doesn't have NgModules, but similar patterns exist:**

**Shared Components (Similar to SharedModule):**

```tsx
// components/index.ts
export { Card } from './Card';
export { Button } from './Button';
export { useHighlight } from './useHighlight';
export { truncate } from './truncate';

// Usage in other files
import { Card, Button, useHighlight, truncate } from './components';
```

**Context with Configuration (Similar to forRoot()):**

```tsx
// CoreContext.tsx
import React, { createContext, useContext, ReactNode } from 'react';

interface CoreConfig {
  apiUrl: string;
  logLevel: 'debug' | 'info' | 'warn' | 'error';
}

interface CoreServices {
  auth: AuthService;
  logger: LoggerService;
  config: CoreConfig;
}

const CoreContext = createContext<CoreServices | null>(null);

export function CoreProvider({ 
  config, 
  children 
}: { 
  config: CoreConfig; 
  children: ReactNode;
}) {
  // Create singleton services
  const services = React.useMemo(() => ({
    auth: new AuthService(),
    logger: new LoggerService(config.logLevel),
    config
  }), [config]);
  
  return (
    <CoreContext.Provider value={services}>
      {children}
    </CoreContext.Provider>
  );
}

export function useCoreServices() {
  const context = useContext(CoreContext);
  if (!context) {
    throw new Error('useCoreServices must be used within CoreProvider');
  }
  return context;
}

// Usage in App.tsx
function App() {
  return (
    <CoreProvider config={{ apiUrl: 'https://api.example.com', logLevel: 'info' }}>
      <Router>
        <Routes>
          {/* routes */}
        </Routes>
      </Router>
    </CoreProvider>
  );
}
```

**Code Splitting (Similar to Lazy Loading):**

```tsx
// App.tsx with React Router
import React, { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';

// Lazy load feature modules
const UserModule = lazy(() => import('./features/user/UserModule'));
const PaymentModule = lazy(() => import('./features/payment/PaymentModule'));

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<div>Loading...</div>}>
        <Routes>
          <Route path="/users/*" element={<UserModule />} />
          <Route path="/payment/*" element={<PaymentModule />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

// UserModule.tsx
function UserModule() {
  return (
    <Routes>
      <Route index element={<UserList />} />
      <Route path=":id" element={<UserDetail />} />
      <Route path=":id/edit" element={<UserEdit />} />
    </Routes>
  );
}
```

#### Comparison: NgModules vs React Patterns

| Feature | Angular NgModules | React |
|---------|------------------|-------|
| **Organization** | NgModule with metadata | Folder structure + exports |
| **Singleton Services** | `forRoot()` pattern | Context Provider at root |
| **Feature Modules** | `forChild()` pattern | Lazy-loaded components |
| **Dependency Declaration** | `imports` array | ES6 imports |
| **Exports** | `exports` array | Named/default exports |
| **Lazy Loading** | `loadChildren` | `React.lazy()` |
| **Configuration** | `ModuleWithProviders` | Provider props |

**Key Differences:**
1. **Angular:** Explicit module system with metadata decorators
2. **React:** Implicit via ES6 modules and component composition
3. **Angular forRoot():** Creates configured module with providers
4. **React:** Configuration via provider props or hooks

**When to Use:**
- **Angular:** Understand for legacy code; prefer standalone components for new projects
- **React:** Use lazy loading and context for similar organization

**Further Reading:**
- [Angular NgModules](https://angular.dev/guide/ngmodules)
- [React Code Splitting](https://react.dev/reference/react/lazy)

---

### 2. View Encapsulation

**Description:** View Encapsulation controls how component styles are scoped. Angular provides three modes: Emulated (default), ShadowDom (native Shadow DOM), and None (global styles).

#### Angular: View Encapsulation Examples

```typescript
// emulated-encapsulation.component.ts
import { Component, ViewEncapsulation } from '@angular/core';

// ViewEncapsulation.Emulated (Default)
// Angular adds unique attributes to scope styles to this component
@Component({
  selector: 'app-emulated',
  template: `
    <div class="container">
      <h2>Emulated Encapsulation</h2>
      <p class="text">Styles are scoped to this component</p>
    </div>
  `,
  styles: [`
    .container {
      border: 2px solid blue;
      padding: 20px;
    }
    .text {
      color: blue;
    }
  `],
  encapsulation: ViewEncapsulation.Emulated // Default
})
export class EmulatedComponent { }
// Generated HTML: <div class="container" _ngcontent-abc-123>
// Generated CSS: .container[_ngcontent-abc-123] { border: 2px solid blue; }

// ViewEncapsulation.ShadowDom
// Uses native browser Shadow DOM for true encapsulation
@Component({
  selector: 'app-shadow',
  template: `
    <div class="container">
      <h2>Shadow DOM Encapsulation</h2>
      <p class="text">Completely isolated with Shadow DOM</p>
      <slot></slot> <!-- Shadow DOM content projection -->
    </div>
  `,
  styles: [`
    .container {
      border: 2px solid green;
      padding: 20px;
    }
    .text {
      color: green;
    }
  `],
  encapsulation: ViewEncapsulation.ShadowDom
})
export class ShadowComponent { }
// This creates a real Shadow DOM: #shadow-root
// Styles are completely isolated, no attribute mangling

// ViewEncapsulation.None
// No encapsulation - styles are global
@Component({
  selector: 'app-none',
  template: `
    <div class="container">
      <h2>No Encapsulation</h2>
      <p class="text">Styles are global</p>
    </div>
  `,
  styles: [`
    .container {
      border: 2px solid red;
      padding: 20px;
    }
    .text {
      color: red;
    }
  `],
  encapsulation: ViewEncapsulation.None
})
export class NoneComponent { }
// Styles added to <head> and affect entire app
```

**Practical Example:**

```typescript
// theme-card.component.ts
import { Component, ViewEncapsulation, Input } from '@angular/core';

@Component({
  selector: 'app-theme-card',
  template: `
    <div class="card">
      <div class="card-header">
        <h3>{{ title }}</h3>
      </div>
      <div class="card-body">
        <ng-content></ng-content> <!-- Content projection -->
      </div>
      <div class="card-footer">
        <button class="btn">Action</button>
      </div>
    </div>
  `,
  styles: [`
    /* These styles are scoped to this component only */
    .card {
      border: 1px solid #ddd;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .card-header {
      background: #f5f5f5;
      padding: 16px;
      border-bottom: 1px solid #ddd;
    }
    .card-body {
      padding: 16px;
    }
    .card-footer {
      padding: 16px;
      border-top: 1px solid #ddd;
      background: #fafafa;
    }
    .btn {
      background: #007bff;
      color: white;
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    .btn:hover {
      background: #0056b3;
    }
  `],
  encapsulation: ViewEncapsulation.Emulated // Default, can be omitted
})
export class ThemeCardComponent {
  @Input() title = 'Card Title';
}

// Usage
@Component({
  template: `
    <app-theme-card title="User Profile">
      <p>This is the card content</p>
      <button class="btn">This won't get card's btn styles</button>
    </app-theme-card>
  `
})
export class ParentComponent { }
```

**Piercing Encapsulation:**

```typescript
// parent.component.ts
@Component({
  selector: 'app-parent',
  template: `
    <app-theme-card title="Styled Card">
      <p class="custom-content">Custom styled content</p>
    </app-theme-card>
  `,
  styles: [`
    /* These styles won't affect ThemeCardComponent's internals */
    .card {
      border: 5px solid red; /* Won't work due to encapsulation */
    }
    
    /* But you can style projected content */
    .custom-content {
      color: purple; /* Works! */
    }
    
    /* Or use ::ng-deep (deprecated but still works) */
    :host ::ng-deep .card-header {
      background: yellow; /* Penetrates encapsulation */
    }
  `]
})
export class ParentComponent { }
```

#### React: Equivalent Styling Approaches

**CSS Modules (Similar to Emulated):**

```tsx
// Card.module.css
.card {
  border: 1px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
.card_header {
  background: #f5f5f5;
  padding: 16px;
  border-bottom: 1px solid #ddd;
}
.card_body {
  padding: 16px;
}
.card_footer {
  padding: 16px;
  border-top: 1px solid #ddd;
  background: #fafafa;
}
.btn {
  background: #007bff;
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.btn:hover {
  background: #0056b3;
}

// Card.tsx
import React, { ReactNode } from 'react';
import styles from './Card.module.css'; // CSS Modules

interface CardProps {
  title: string;
  children: ReactNode;
}

function Card({ title, children }: CardProps) {
  return (
    <div className={styles.card}>
      <div className={styles.card_header}>
        <h3>{title}</h3>
      </div>
      <div className={styles.card_body}>
        {children}
      </div>
      <div className={styles.card_footer}>
        <button className={styles.btn}>Action</button>
      </div>
    </div>
  );
}

export default Card;
// CSS Modules generate unique class names like: Card_card__a3d9f
```

**Styled Components (Similar to ShadowDom isolation):**

```tsx
// Card.tsx with styled-components
import React, { ReactNode } from 'react';
import styled from 'styled-components';

// Styled components have scoped styles
const StyledCard = styled.div`
  border: 1px solid #ddd;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
`;

const CardHeader = styled.div`
  background: #f5f5f5;
  padding: 16px;
  border-bottom: 1px solid #ddd;
`;

const CardBody = styled.div`
  padding: 16px;
`;

const CardFooter = styled.div`
  padding: 16px;
  border-top: 1px solid #ddd;
  background: #fafafa;
`;

const Button = styled.button`
  background: #007bff;
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  
  &:hover {
    background: #0056b3;
  }
`;

interface CardProps {
  title: string;
  children: ReactNode;
}

function Card({ title, children }: CardProps) {
  return (
    <StyledCard>
      <CardHeader>
        <h3>{title}</h3>
      </CardHeader>
      <CardBody>
        {children}
      </CardBody>
      <CardFooter>
        <Button>Action</Button>
      </CardFooter>
    </StyledCard>
  );
}

export default Card;
```

**Global Styles (Similar to None):**

```tsx
// App.css (global)
.card {
  border: 1px solid #ddd;
  /* Affects all elements with .card class */
}

// App.tsx
import './App.css'; // Global import

function App() {
  return (
    <div className="card">
      {/* Uses global styles */}
    </div>
  );
}
```

**Shadow DOM in React (Web Components):**

```tsx
// ShadowCard.tsx - React with Shadow DOM
import React, { useEffect, useRef } from 'react';
import { createRoot } from 'react-dom/client';

function ShadowCard({ title, children }: { title: string; children: React.ReactNode }) {
  const hostRef = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    if (!hostRef.current) return;
    
    // Create Shadow DOM
    const shadowRoot = hostRef.current.attachShadow({ mode: 'open' });
    
    // Add styles to Shadow DOM
    const style = document.createElement('style');
    style.textContent = `
      .card { border: 1px solid #ddd; padding: 20px; }
      .card-header { background: #f5f5f5; padding: 16px; }
      /* Completely isolated */
    `;
    shadowRoot.appendChild(style);
    
    // Create container for React content
    const container = document.createElement('div');
    shadowRoot.appendChild(container);
    
    // Render React into Shadow DOM
    const root = createRoot(container);
    root.render(
      <div className="card">
        <div className="card-header">
          <h3>{title}</h3>
        </div>
        <div className="card-body">
          {children}
        </div>
      </div>
    );
    
    return () => root.unmount();
  }, [title, children]);
  
  return <div ref={hostRef}></div>;
}

export default ShadowCard;
```

#### Comparison: View Encapsulation

| Feature | Angular Emulated | Angular ShadowDom | Angular None | React CSS Modules | React Styled-Components |
|---------|-----------------|-------------------|--------------|-------------------|------------------------|
| **Scoping** | Component-scoped | Shadow DOM isolated | Global | Component-scoped | Component-scoped |
| **Implementation** | Attribute mangling | Native Shadow DOM | No encapsulation | Build-time class hashing | Runtime CSS injection |
| **Performance** | Good | Good (native) | Best | Excellent | Good |
| **Browser Support** | All | Modern browsers | All | All | All |
| **Global Overrides** | ⚠️ ::ng-deep | ❌ Impossible | ✅ Easy | ⚠️ :global() | ⚠️ createGlobalStyle |
| **SSR Support** | ✅ | ⚠️ Limited | ✅ | ✅ | ✅ |

**When to Use:**
- **Angular Emulated:** Default choice—good balance of encapsulation and compatibility
- **Angular ShadowDom:** True isolation needed, modern browsers only
- **Angular None:** Global theming, legacy integration
- **React CSS Modules:** Standard approach—excellent performance and scoping
- **React Styled-Components:** Dynamic theming, component-centric styling

**Further Reading:**
- [Angular View Encapsulation](https://angular.dev/guide/components/styling#view-encapsulation)
- [CSS Modules](https://github.com/css-modules/css-modules)
- [Styled Components](https://styled-components.com/)

---

### 3. ng-template & ngTemplateOutlet

**Description:** `ng-template` defines reusable template blocks that aren't rendered by default. `ngTemplateOutlet` allows you to instantiate these templates dynamically with context.

#### Angular: ng-template Examples

**Basic Template Reuse:**

```typescript
// template-demo.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-template-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="demo">
      <h2>Template Reuse Example</h2>
      
      <!-- Define a reusable template -->
      <ng-template #userCard let-user="user" let-index="index">
        <div class="card">
          <h3>{{ index + 1 }}. {{ user.name }}</h3>
          <p>Email: {{ user.email }}</p>
          <p>Role: {{ user.role }}</p>
        </div>
      </ng-template>
      
      <!-- Use the template multiple times with different data -->
      <div class="grid">
        <ng-container *ngTemplateOutlet="userCard; context: { user: users[0], index: 0 }">
        </ng-container>
        
        <ng-container *ngTemplateOutlet="userCard; context: { user: users[1], index: 1 }">
        </ng-container>
        
        <ng-container *ngTemplateOutlet="userCard; context: { user: users[2], index: 2 }">
        </ng-container>
      </div>
      
      <!-- Or use in a loop -->
      <div class="list">
        <ng-container *ngFor="let user of users; let i = index">
          <ng-container *ngTemplateOutlet="userCard; context: { user: user, index: i }">
          </ng-container>
        </ng-container>
      </div>
    </div>
  `,
  styles: [`
    .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
    .card { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
  `]
})
export class TemplateDemoComponent {
  users = [
    { name: 'Alice', email: 'alice@example.com', role: 'Admin' },
    { name: 'Bob', email: 'bob@example.com', role: 'User' },
    { name: 'Charlie', email: 'charlie@example.com', role: 'Editor' }
  ];
}
```

**Advanced: Configurable Components with Templates:**

```typescript
// card-container.component.ts
import { Component, Input, TemplateRef, ContentChild } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-card-container',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card-container">
      <!-- Header template -->
      <div class="header" *ngIf="headerTemplate">
        <ng-container *ngTemplateOutlet="headerTemplate; context: { $implicit: title }">
        </ng-container>
      </div>
      
      <!-- Default header if no template provided -->
      <div class="header" *ngIf="!headerTemplate">
        <h2>{{ title }}</h2>
      </div>
      
      <!-- Body (projected content) -->
      <div class="body">
        <ng-content></ng-content>
      </div>
      
      <!-- Footer template -->
      <div class="footer" *ngIf="footerTemplate">
        <ng-container *ngTemplateOutlet="footerTemplate; context: footerContext">
        </ng-container>
      </div>
    </div>
  `,
  styles: [`
    .card-container {
      border: 2px solid #007bff;
      border-radius: 8px;
      overflow: hidden;
    }
    .header {
      background: #007bff;
      color: white;
      padding: 16px;
    }
    .body {
      padding: 20px;
    }
    .footer {
      background: #f5f5f5;
      padding: 12px;
      border-top: 1px solid #ddd;
    }
  `]
})
export class CardContainerComponent {
  @Input() title = 'Card Title';
  @Input() headerTemplate?: TemplateRef<any>;
  @Input() footerTemplate?: TemplateRef<any>;
  @Input() footerContext: any = {};
}

// Usage component
@Component({
  selector: 'app-template-usage',
  standalone: true,
  imports: [CommonModule, CardContainerComponent],
  template: `
    <div class="demo">
      <!-- Card with default header -->
      <app-card-container title="Simple Card">
        <p>This uses the default header</p>
      </app-card-container>
      
      <!-- Card with custom header template -->
      <app-card-container [headerTemplate]="customHeader" [title]="'Custom Card'">
        <p>This has a custom header from a template</p>
      </app-card-container>
      
      <!-- Card with custom header and footer -->
      <app-card-container 
        [headerTemplate]="fancyHeader" 
        [footerTemplate]="actionFooter"
        [footerContext]="{ actions: ['Save', 'Cancel', 'Delete'] }"
        [title]="'Full Custom Card'">
        <p>This has both custom header and footer</p>
      </app-card-container>
      
      <!-- Define templates -->
      <ng-template #customHeader let-title>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <h2>🎨 {{ title }}</h2>
          <button>⚙️</button>
        </div>
      </ng-template>
      
      <ng-template #fancyHeader let-title>
        <div style="text-align: center;">
          <h2 style="margin: 0;">✨ {{ title }} ✨</h2>
          <p style="margin: 4px 0 0 0; font-size: 0.9em;">Subtitle text here</p>
        </div>
      </ng-template>
      
      <ng-template #actionFooter let-actions="actions">
        <div style="display: flex; gap: 8px; justify-content: flex-end;">
          <button *ngFor="let action of actions" style="padding: 8px 16px;">
            {{ action }}
          </button>
        </div>
      </ng-template>
    </div>
  `
})
export class TemplateUsageComponent { }
```

**Dynamic Template Selection:**

```typescript
// dynamic-template.component.ts
import { Component, ViewChild, TemplateRef } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-dynamic-template',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="dynamic-demo">
      <h2>Dynamic Template Selection</h2>
      
      <div class="controls">
        <button (click)="currentTemplate = 'list'">List View</button>
        <button (click)="currentTemplate = 'grid'">Grid View</button>
        <button (click)="currentTemplate = 'table'">Table View</button>
      </div>
      
      <!-- Dynamically select template -->
      <div class="content">
        <ng-container [ngTemplateOutlet]="getTemplate()" [ngTemplateOutletContext]="{ items: products }">
        </ng-container>
      </div>
      
      <!-- Define multiple templates -->
      <ng-template #listView let-items="items">
        <ul class="list-view">
          <li *ngFor="let item of items">
            <strong>{{ item.name }}</strong> - ${{ item.price }}
          </li>
        </ul>
      </ng-template>
      
      <ng-template #gridView let-items="items">
        <div class="grid-view">
          <div *ngFor="let item of items" class="grid-item">
            <h4>{{ item.name }}</h4>
            <p>${{ item.price }}</p>
          </div>
        </div>
      </ng-template>
      
      <ng-template #tableView let-items="items">
        <table class="table-view">
          <thead>
            <tr>
              <th>Name</th>
              <th>Price</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let item of items">
              <td>{{ item.name }}</td>
              <td>${{ item.price }}</td>
            </tr>
          </tbody>
        </table>
      </ng-template>
    </div>
  `,
  styles: [`
    .controls { margin: 20px 0; }
    .controls button { margin-right: 10px; padding: 8px 16px; }
    .grid-view { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
    .grid-item { border: 1px solid #ddd; padding: 16px; border-radius: 8px; }
    .table-view { width: 100%; border-collapse: collapse; }
    .table-view th, .table-view td { border: 1px solid #ddd; padding: 8px; }
  `]
})
export class DynamicTemplateComponent {
  @ViewChild('listView', { static: true }) listView!: TemplateRef<any>;
  @ViewChild('gridView', { static: true }) gridView!: TemplateRef<any>;
  @ViewChild('tableView', { static: true }) tableView!: TemplateRef<any>;
  
  currentTemplate: 'list' | 'grid' | 'table' = 'list';
  
  products = [
    { name: 'Laptop', price: 999 },
    { name: 'Mouse', price: 29 },
    { name: 'Keyboard', price: 79 },
    { name: 'Monitor', price: 299 }
  ];
  
  getTemplate(): TemplateRef<any> {
    switch (this.currentTemplate) {
      case 'list': return this.listView;
      case 'grid': return this.gridView;
      case 'table': return this.tableView;
    }
  }
}
```

#### React: Equivalent Patterns

**Render Props Pattern:**

```tsx
// CardContainer.tsx
import React, { ReactNode } from 'react';

interface CardContainerProps {
  title: string;
  children: ReactNode;
  renderHeader?: (title: string) => ReactNode;
  renderFooter?: (context: any) => ReactNode;
  footerContext?: any;
}

function CardContainer({ 
  title, 
  children, 
  renderHeader, 
  renderFooter, 
  footerContext 
}: CardContainerProps) {
  return (
    <div className="card-container">
      <div className="header">
        {renderHeader ? renderHeader(title) : <h2>{title}</h2>}
      </div>
      
      <div className="body">
        {children}
      </div>
      
      {renderFooter && (
        <div className="footer">
          {renderFooter(footerContext)}
        </div>
      )}
    </div>
  );
}

// Usage
function App() {
  return (
    <div>
      {/* Simple card */}
      <CardContainer title="Simple Card">
        <p>This uses the default header</p>
      </CardContainer>
      
      {/* Card with custom header */}
      <CardContainer
        title="Custom Card"
        renderHeader={(title) => (
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <h2>🎨 {title}</h2>
            <button>⚙️</button>
          </div>
        )}
      >
        <p>This has a custom header</p>
      </CardContainer>
      
      {/* Card with header and footer */}
      <CardContainer
        title="Full Custom Card"
        renderHeader={(title) => (
          <div style={{ textAlign: 'center' }}>
            <h2>✨ {title} ✨</h2>
            <p>Subtitle text here</p>
          </div>
        )}
        renderFooter={({ actions }) => (
          <div style={{ display: 'flex', gap: '8px', justifyContent: 'flex-end' }}>
            {actions.map((action: string) => (
              <button key={action}>{action}</button>
            ))}
          </div>
        )}
        footerContext={{ actions: ['Save', 'Cancel', 'Delete'] }}
      >
        <p>This has both custom header and footer</p>
      </CardContainer>
    </div>
  );
}
```

**Dynamic Component Pattern:**

```tsx
// DynamicView.tsx
import React, { useState } from 'react';

interface Product {
  name: string;
  price: number;
}

// View components
function ListView({ items }: { items: Product[] }) {
  return (
    <ul className="list-view">
      {items.map((item, index) => (
        <li key={index}>
          <strong>{item.name}</strong> - ${item.price}
        </li>
      ))}
    </ul>
  );
}

function GridView({ items }: { items: Product[] }) {
  return (
    <div className="grid-view">
      {items.map((item, index) => (
        <div key={index} className="grid-item">
          <h4>{item.name}</h4>
          <p>${item.price}</p>
        </div>
      ))}
    </div>
  );
}

function TableView({ items }: { items: Product[] }) {
  return (
    <table className="table-view">
      <thead>
        <tr>
          <th>Name</th>
          <th>Price</th>
        </tr>
      </thead>
      <tbody>
        {items.map((item, index) => (
          <tr key={index}>
            <td>{item.name}</td>
            <td>${item.price}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function DynamicView() {
  const [currentView, setCurrentView] = useState<'list' | 'grid' | 'table'>('list');
  
  const products = [
    { name: 'Laptop', price: 999 },
    { name: 'Mouse', price: 29 },
    { name: 'Keyboard', price: 79 },
    { name: 'Monitor', price: 299 }
  ];
  
  const getComponent = () => {
    switch (currentView) {
      case 'list': return ListView;
      case 'grid': return GridView;
      case 'table': return TableView;
    }
  };
  
  const ViewComponent = getComponent();
  
  return (
    <div className="dynamic-demo">
      <h2>Dynamic Template Selection</h2>
      
      <div className="controls">
        <button onClick={() => setCurrentView('list')}>List View</button>
        <button onClick={() => setCurrentView('grid')}>Grid View</button>
        <button onClick={() => setCurrentView('table')}>Table View</button>
      </div>
      
      <div className="content">
        <ViewComponent items={products} />
      </div>
    </div>
  );
}

export default DynamicView;
```

#### Comparison: ng-template vs Render Props

| Feature | Angular ng-template | React Render Props |
|---------|---------------------|-------------------|
| **Syntax** | `<ng-template #ref>` | Function as prop |
| **Context Passing** | `let-var="prop"` | Function parameters |
| **Reuse** | `*ngTemplateOutlet` | Call function |
| **Dynamic Selection** | ViewChild + TemplateRef | Component variable |
| **Type Safety** | ⚠️ Limited | ✅ Full TypeScript |
| **Performance** | Good | Good |

**When to Use:**
- **Angular ng-template:** Template customization, reusable UI patterns
- **React Render Props:** Same use cases, but with full JavaScript flexibility

**Further Reading:**
- [Angular ng-template](https://angular.dev/api/core/ng-template)
- [React Render Props](https://react.dev/reference/react/cloneElement#passing-data-with-a-render-prop)

---

*To be continued with remaining Core Concepts (ng-container, Dynamic Components, @ContentChild, @ViewChildren, ControlValueAccessor, ChangeDetectorRef), Advanced Features, Routing Features, and Tooling & DevOps...*

