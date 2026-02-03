# Angular Advanced Features Complete Guide - Part 6: Tooling & DevOps

## Category 5: Tooling & DevOps (5 Features)

This section covers development tools, build optimization, code generation, and performance monitoring for Angular applications.

---

### 1. Angular DevTools (Browser Extension)

**Description:** Angular DevTools is a Chrome/Edge extension for debugging Angular applications. Inspect component tree, view change detection cycles, profile performance, and analyze dependency injection.

#### Angular: DevTools Features

**Installation:**

1. Install from [Chrome Web Store](https://chrome.google.com/webstore/detail/angular-devtools/ienfalfjdbdpebioblfackkekamfmbnh)
2. Open Chrome DevTools (F12)
3. Select "Angular" tab

**Component Explorer:**

```typescript
// Any Angular component can be inspected
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="user-list">
      @for (user of users; track user.id) {
        <div class="user-card" (click)="selectUser(user)">
          <h3>{{ user.name }}</h3>
          <p>{{ user.email }}</p>
          <span [class.active]="selectedUser?.id === user.id">
            {{ selectedUser?.id === user.id ? 'Selected' : 'Select' }}
          </span>
        </div>
      }
    </div>
  `,
  styles: [`
    .user-card {
      padding: 16px;
      border: 1px solid #ddd;
      margin: 8px 0;
      cursor: pointer;
    }
    .user-card:hover {
      background: #f5f5f5;
    }
    .active {
      color: #2196f3;
      font-weight: bold;
    }
  `]
})
export class UserListComponent {
  users = [
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' },
    { id: 3, name: 'Bob Johnson', email: 'bob@example.com' }
  ];
  
  selectedUser: { id: number; name: string; email: string } | null = null;

  selectUser(user: typeof this.users[0]): void {
    this.selectedUser = user;
    console.log('User selected:', user);
  }
}

// DevTools Features:
// 1. Component Tree: View hierarchy of all components
// 2. Properties Panel: Inspect component properties (users, selectedUser)
// 3. Change Detection: See when component detects changes
// 4. Profiler: Measure component rendering performance
// 5. Injector Tree: View dependency injection hierarchy
```

**DevTools Features Walkthrough:**

**1. Component Tree Inspector:**
```typescript
// View component hierarchy in DevTools
// - See parent-child relationships
// - Inspect component state
// - View input/output bindings
// - Check change detection strategy

@Component({
  selector: 'app-dashboard',
  template: `
    <app-header [title]="title" />
    <app-sidebar [items]="menuItems" />
    <app-main-content [data]="contentData" />
    <app-footer />
  `
})
export class DashboardComponent {
  title = 'Dashboard';
  menuItems = ['Home', 'Profile', 'Settings'];
  contentData = { widgets: [] };
}

// DevTools shows:
// └─ app-dashboard
//    ├─ app-header (title: "Dashboard")
//    ├─ app-sidebar (items: Array[3])
//    ├─ app-main-content (data: Object)
//    └─ app-footer
```

**2. Profiler for Performance:**
```typescript
// Click "Record" in Profiler tab
// Perform actions in your app
// Click "Stop" to see performance metrics

@Component({
  selector: 'app-heavy-list',
  template: `
    <button (click)="loadMore()">Load More</button>
    <div class="list">
      @for (item of items; track item.id) {
        <div class="item">
          <h4>{{ item.title }}</h4>
          <p>{{ expensiveComputation(item) }}</p>
        </div>
      }
    </div>
  `
})
export class HeavyListComponent {
  items: any[] = [];

  loadMore(): void {
    // Add 1000 items
    const newItems = Array.from({ length: 1000 }, (_, i) => ({
      id: this.items.length + i,
      title: `Item ${this.items.length + i}`,
      value: Math.random()
    }));
    this.items = [...this.items, ...newItems];
  }

  expensiveComputation(item: any): string {
    // This will show up in profiler as slow
    let result = 0;
    for (let i = 0; i < 1000; i++) {
      result += item.value * Math.random();
    }
    return result.toFixed(2);
  }
}

// Profiler shows:
// - Change detection duration
// - Component rendering time
// - Which components are slowest
// - Change detection triggers
```

**3. Dependency Injection Inspector:**
```typescript
// View injected services in DevTools

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private users = signal([
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' }
  ]);
  
  getUsers() {
    return this.users.asReadonly();
  }
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUser = signal<User | null>(null);
  
  login(username: string, password: string) {
    // Login logic
  }
}

@Component({
  selector: 'app-dashboard',
  template: `<div>Dashboard</div>`
})
export class DashboardComponent {
  private userService = inject(UserService);
  private authService = inject(AuthService);
  private router = inject(Router);
  
  // DevTools shows all injected dependencies:
  // - UserService
  // - AuthService
  // - Router
  // Plus their injection hierarchy
}
```

**4. Change Detection Monitoring:**
```typescript
// DevTools shows change detection cycles

@Component({
  selector: 'app-counter',
  template: `
    <div>
      <p>Count: {{ count }}</p>
      <button (click)="increment()">Increment</button>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class CounterComponent {
  count = signal(0);

  increment(): void {
    this.count.update(c => c + 1);
    // DevTools shows:
    // - Change detection triggered
    // - Components checked
    // - Time taken
  }
}
```

**Debugging with DevTools:**

```typescript
// 1. Select component in DevTools
// 2. Access in console: ng.getComponent($0)

@Component({
  selector: 'app-debug-example',
  template: `
    <div>
      <p>Value: {{ value }}</p>
      <button (click)="updateValue()">Update</button>
    </div>
  `
})
export class DebugExampleComponent {
  value = 0;

  updateValue(): void {
    this.value++;
  }
}

// In browser console:
// const component = ng.getComponent($0);
// component.value = 100; // Change property
// ng.applyChanges($0); // Trigger change detection
// component.updateValue(); // Call methods
```

#### React: Equivalent Developer Tools

**React DevTools:**

```tsx
// React DevTools (Chrome Extension)
// Similar features to Angular DevTools

function UserList() {
  const [users] = useState([
    { id: 1, name: 'John Doe', email: 'john@example.com' },
    { id: 2, name: 'Jane Smith', email: 'jane@example.com' }
  ]);
  
  const [selectedUser, setSelectedUser] = useState(null);

  return (
    <div className="user-list">
      {users.map(user => (
        <div 
          key={user.id}
          className="user-card"
          onClick={() => setSelectedUser(user)}
        >
          <h3>{user.name}</h3>
          <p>{user.email}</p>
          <span className={selectedUser?.id === user.id ? 'active' : ''}>
            {selectedUser?.id === user.id ? 'Selected' : 'Select'}
          </span>
        </div>
      ))}
    </div>
  );
}

// React DevTools Features:
// 1. Components tab: View component tree
// 2. Profiler tab: Performance profiling
// 3. Props inspection: View props and state
// 4. Hooks inspection: See hook values
// 5. Context inspection: View context values

// Console debugging:
// $r - access selected component instance
// $r.props - view props
// $r.state - view state (class components)
```

**React Profiler API:**

```tsx
import { Profiler, ProfilerOnRenderCallback } from 'react';

const onRenderCallback: ProfilerOnRenderCallback = (
  id,
  phase,
  actualDuration,
  baseDuration,
  startTime,
  commitTime
) => {
  console.log('Render:', {
    id,
    phase,
    actualDuration,
    baseDuration
  });
};

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <Dashboard />
    </Profiler>
  );
}
```

#### Comparison: DevTools

| Feature | Angular DevTools | React DevTools |
|---------|-----------------|---------------|
| **Component Tree** | ✅ Full hierarchy | ✅ Full hierarchy |
| **State Inspection** | ✅ Properties panel | ✅ Props/State |
| **Profiler** | ✅ Change detection metrics | ✅ Render metrics |
| **DI Inspector** | ✅ Injector tree | ❌ N/A |
| **Change Detection** | ✅ Detailed tracking | Render tracking |

**When to Use:**
- **Angular DevTools:** Component inspection, change detection monitoring, DI tree
- **React DevTools:** Component hierarchy, props/state, render profiling

**Further Reading:**
- [Angular DevTools](https://angular.dev/tools/devtools)
- [React DevTools](https://react.dev/learn/react-developer-tools)

---

### 2. AOT vs JIT Compilation

**Description:** Angular supports two compilation modes: Ahead-of-Time (AOT) compiles templates during build; Just-in-Time (JIT) compiles templates in the browser at runtime. AOT is production default for better performance and security.

#### Angular: Compilation Modes

**AOT (Ahead-of-Time) Compilation:**

```typescript
// AOT compilation happens during build
// Templates are converted to JavaScript before deployment

@Component({
  selector: 'app-user-profile',
  template: `
    <div class="profile">
      <h2>{{ user.name }}</h2>
      <p>Email: {{ user.email }}</p>
      <button (click)="edit()">Edit Profile</button>
      
      @if (isEditing) {
        <form (ngSubmit)="save()">
          <input [(ngModel)]="user.name" />
          <input [(ngModel)]="user.email" />
          <button type="submit">Save</button>
        </form>
      }
    </div>
  `
})
export class UserProfileComponent {
  user = { name: 'John Doe', email: 'john@example.com' };
  isEditing = false;

  edit(): void {
    this.isEditing = true;
  }

  save(): void {
    this.isEditing = false;
    // Save logic
  }
}

// AOT converts template to optimized JavaScript:
// - Type checking at build time
// - Template errors caught before runtime
// - Smaller bundle size (no compiler in production)
// - Faster rendering (pre-compiled)
// - Better security (no eval or new Function)
```

**Build Commands:**

```bash
# Production build (AOT by default)
ng build

# Explicitly enable AOT
ng build --aot

# Development with AOT (slower builds, catches errors)
ng serve --aot

# JIT mode (development only, deprecated in v13+)
ng serve --no-aot

# Build with production optimizations
ng build --configuration=production
# - AOT compilation
# - Minification
# - Tree-shaking
# - Dead code elimination
# - Bundle optimization
```

**AOT Benefits:**

```typescript
// 1. Compile-time Template Type Checking
@Component({
  selector: 'app-type-check',
  template: `
    <!-- AOT catches this error at build time -->
    <p>{{ user.nonExistentProperty }}</p>
    <!--     ^^^^^^^^^^^^^^^^^^^^^^^ Property does not exist -->
    
    <!-- AOT catches type mismatches -->
    <input [value]="count" /> <!-- OK: number coerced to string -->
    <button (click)="handleClick($event)">Click</button>
    <!-- AOT verifies handleClick accepts MouseEvent -->
  `
})
export class TypeCheckComponent {
  user = { name: 'John', email: 'john@example.com' };
  count = 42;

  handleClick(event: MouseEvent): void {
    console.log('Clicked:', event);
  }
}

// 2. Faster Rendering
// AOT pre-compiles templates, so runtime is faster
// No template parsing or compilation in browser

// 3. Smaller Bundle Size
// Compiler not shipped to browser
// Typical savings: 1-2 MB

// 4. Better Security
// No dynamic template compilation
// Prevents injection attacks via template strings
```

**Strict Template Type Checking:**

```typescript
// tsconfig.json
{
  "angularCompilerOptions": {
    "strictTemplates": true,
    "strictInputAccessModifiers": true,
    "strictInputTypes": true,
    "strictNullInputTypes": true,
    "strictAttributeTypes": true,
    "strictSafeNavigationTypes": true,
    "strictDomLocalRefTypes": true,
    "strictOutputEventTypes": true,
    "strictDomEventTypes": true,
    "strictContextGenerics": true,
    "strictLiteralTypes": true
  }
}

// Component with strict type checking
@Component({
  selector: 'app-strict-types',
  template: `
    <!-- Strict type checking enforced -->
    <input [value]="username" (input)="onInput($event)" />
    <!-- $event is correctly typed as InputEvent -->
    
    <button (click)="handleClick($event)">Click</button>
    <!-- $event is correctly typed as MouseEvent -->
    
    @if (user) {
      <!-- user.name is known to be defined inside @if -->
      <p>{{ user.name.toUpperCase() }}</p>
    }
  `
})
export class StrictTypesComponent {
  username = '';
  user: { name: string; email: string } | null = null;

  onInput(event: Event): void {
    const target = event.target as HTMLInputElement;
    this.username = target.value;
  }

  handleClick(event: MouseEvent): void {
    console.log('Clicked at:', event.clientX, event.clientY);
  }
}
```

**JIT Mode (Legacy):**

```typescript
// JIT compilation happens in the browser
// Used during development (ng serve without --aot)

// angular.json (development configuration)
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "configurations": {
            "development": {
              "optimization": false,
              "sourceMap": true,
              "namedChunks": true,
              "aot": false, // JIT mode for faster builds
              "buildOptimizer": false
            }
          }
        }
      }
    }
  }
}

// JIT Characteristics:
// - Faster builds (no template compilation)
// - Larger bundles (includes compiler ~1-2MB)
// - Slower initial rendering
// - Runtime errors instead of build errors
// - Used primarily in Angular < v13
```

**Build Optimization Comparison:**

```bash
# Development build (fast, larger)
ng build --configuration=development
# - No minification
# - Source maps included
# - No tree-shaking
# - Faster build time
# Bundle size: ~5-8 MB

# Production build (slow, smaller)
ng build --configuration=production
# - AOT compilation
# - Minification
# - Tree-shaking
# - Dead code elimination
# - Optimized bundle
# Bundle size: ~200-500 KB (gzipped)

# Stats comparison
ng build --configuration=production --stats-json
# Then analyze with webpack-bundle-analyzer
npx webpack-bundle-analyzer dist/my-app/stats.json
```

**Template Compilation Output:**

```typescript
// Source template
@Component({
  selector: 'app-example',
  template: `
    <div class="container">
      <h1>{{ title }}</h1>
      @for (item of items; track item.id) {
        <div class="item">{{ item.name }}</div>
      }
    </div>
  `
})
export class ExampleComponent {
  title = 'Example';
  items = [
    { id: 1, name: 'Item 1' },
    { id: 2, name: 'Item 2' }
  ];
}

// AOT compiles to (simplified):
function View_ExampleComponent_0() {
  return {
    create: (parentView, index) => {
      const div = document.createElement('div');
      div.className = 'container';
      
      const h1 = document.createElement('h1');
      h1.textContent = component.title;
      div.appendChild(h1);
      
      // For loop compiled to efficient DOM operations
      for (const item of component.items) {
        const itemDiv = document.createElement('div');
        itemDiv.className = 'item';
        itemDiv.textContent = item.name;
        div.appendChild(itemDiv);
      }
      
      return div;
    },
    update: (view) => {
      // Efficient update logic
    }
  };
}
```

#### React: Compilation Approaches

**Babel Transpilation:**

```tsx
// React uses Babel for JSX transformation
// JSX is compiled to React.createElement calls

// Source JSX
function UserProfile({ user }) {
  return (
    <div className="profile">
      <h2>{user.name}</h2>
      <p>Email: {user.email}</p>
      <button onClick={() => console.log('Edit')}>Edit Profile</button>
    </div>
  );
}

// Compiled output (Classic transform)
function UserProfile({ user }) {
  return React.createElement(
    'div',
    { className: 'profile' },
    React.createElement('h2', null, user.name),
    React.createElement('p', null, 'Email: ', user.email),
    React.createElement('button', { onClick: () => console.log('Edit') }, 'Edit Profile')
  );
}

// New JSX Transform (React 17+)
import { jsx as _jsx } from 'react/jsx-runtime';

function UserProfile({ user }) {
  return _jsx('div', {
    className: 'profile',
    children: [
      _jsx('h2', { children: user.name }),
      _jsx('p', { children: ['Email: ', user.email] }),
      _jsx('button', { onClick: () => console.log('Edit'), children: 'Edit Profile' })
    ]
  });
}
```

**TypeScript with React:**

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "jsx": "react-jsx", // or "react" for classic transform
    "strict": true,
    "target": "ES2020",
    "module": "esnext",
    "lib": ["DOM", "ES2020"]
  }
}

// Type checking in components
interface User {
  name: string;
  email: string;
}

interface UserProfileProps {
  user: User;
  onEdit: () => void;
}

function UserProfile({ user, onEdit }: UserProfileProps) {
  return (
    <div className="profile">
      <h2>{user.name}</h2>
      <p>Email: {user.email}</p>
      <button onClick={onEdit}>Edit Profile</button>
    </div>
  );
}
```

#### Comparison: Compilation

| Feature | Angular AOT | React Babel/TypeScript |
|---------|------------|----------------------|
| **Compilation Time** | Build time | Build time |
| **Template Type Checking** | ✅ Strict | ✅ TypeScript props |
| **Bundle Size** | Smaller (no compiler) | Depends on optimizer |
| **Runtime Performance** | ✅ Pre-compiled | ✅ Optimized |
| **Build Speed** | Slower | Faster |

**When to Use:**
- **Angular:** Always use AOT for production (default)
- **React:** Babel + TypeScript for all environments

**Further Reading:**
- [Angular AOT Compilation](https://angular.dev/tools/cli/aot-compiler)
- [React JSX Transform](https://react.dev/learn/writing-markup-with-jsx)

---

### 3. Custom Schematics (Code Generation)

**Description:** Angular Schematics are code generation tools that automate creating components, services, modules, and custom templates. Build custom schematics to enforce team conventions and boost productivity.

#### Angular: Creating Custom Schematics

**Basic Schematic Setup:**

```bash
# Install Schematics CLI
npm install -g @angular-devkit/schematics-cli

# Create new schematics collection
schematics blank my-schematics
cd my-schematics

# Install dependencies
npm install

# Directory structure:
# my-schematics/
# ├── src/
# │   ├── my-schematics/
# │   │   ├── index.ts
# │   │   └── schema.json
# │   └── collection.json
# ├── package.json
# └── tsconfig.json
```

**Simple Component Schematic:**

```typescript
// src/my-component/index.ts
import {
  Rule,
  SchematicContext,
  Tree,
  apply,
  url,
  template,
  mergeWith,
  move,
  chain,
  strings
} from '@angular-devkit/schematics';

// Schema interface for options
interface ComponentOptions {
  name: string;
  path?: string;
  standalone?: boolean;
  changeDetection?: 'Default' | 'OnPush';
}

// Main schematic function
export function myComponent(options: ComponentOptions): Rule {
  return (tree: Tree, context: SchematicContext) => {
    context.logger.info('Creating custom component...');
    
    // Normalize options
    const componentName = strings.dasherize(options.name);
    const className = strings.classify(options.name);
    const path = options.path || '/src/app';
    
    // Template variables
    const templateSource = apply(url('./files'), [
      template({
        ...options,
        ...strings,
        componentName,
        className,
        standalone: options.standalone ?? true,
        changeDetection: options.changeDetection || 'OnPush'
      }),
      move(`${path}/${componentName}`)
    ]);
    
    return mergeWith(templateSource);
  };
}
```

**Schema Definition:**

```json
// src/my-component/schema.json
{
  "$schema": "http://json-schema.org/schema",
  "id": "MyComponentSchematic",
  "title": "My Component Options Schema",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "description": "The name of the component",
      "$default": {
        "$source": "argv",
        "index": 0
      },
      "x-prompt": "What name would you like to use for the component?"
    },
    "path": {
      "type": "string",
      "format": "path",
      "description": "The path to create the component",
      "visible": false
    },
    "standalone": {
      "type": "boolean",
      "description": "Whether to create a standalone component",
      "default": true,
      "x-prompt": "Would you like to create a standalone component?"
    },
    "changeDetection": {
      "type": "string",
      "enum": ["Default", "OnPush"],
      "description": "Change detection strategy",
      "default": "OnPush",
      "x-prompt": "Which change detection strategy would you like to use?"
    }
  },
  "required": ["name"]
}
```

**Template Files:**

```typescript
// src/my-component/files/__componentName@dasherize__.component.ts.template
import { Component<% if (standalone) { %>, signal<% } %> } from '@angular/core';
<% if (standalone) { %>import { CommonModule } from '@angular/common';<% } %>

@Component({
  selector: 'app-<%= componentName %>',
  <% if (standalone) { %>standalone: true,
  imports: [CommonModule],<% } %>
  templateUrl: './<%= componentName %>.component.html',
  styleUrls: ['./<%= componentName %>.component.scss']<% if (changeDetection === 'OnPush') { %>,
  changeDetection: ChangeDetectionStrategy.OnPush<% } %>
})
export class <%= className %>Component {
  // Component logic here
  <% if (standalone) { %>
  count = signal(0);
  
  increment(): void {
    this.count.update(c => c + 1);
  }
  <% } %>
}
```

```html
<!-- src/my-component/files/__componentName@dasherize__.component.html.template -->
<div class="<%= componentName %>">
  <h2><%= classify(name) %> Component</h2>
  <% if (standalone) { %>
  <p>Count: {{ count() }}</p>
  <button (click)="increment()">Increment</button>
  <% } else { %>
  <p><%= componentName %> works!</p>
  <% } %>
</div>
```

```scss
// src/my-component/files/__componentName@dasherize__.component.scss.template
.<%= componentName %> {
  padding: 20px;
  
  h2 {
    color: #2196f3;
    margin-bottom: 16px;
  }
  
  button {
    padding: 8px 16px;
    background: #2196f3;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    
    &:hover {
      background: #1976d2;
    }
  }
}
```

**Advanced Schematic with File Manipulation:**

```typescript
// src/feature-module/index.ts
import {
  Rule,
  SchematicContext,
  Tree,
  chain,
  SchematicsException
} from '@angular-devkit/schematics';
import { strings } from '@angular-devkit/core';

interface FeatureModuleOptions {
  name: string;
  routing?: boolean;
  components?: string[];
}

export function featureModule(options: FeatureModuleOptions): Rule {
  return chain([
    // 1. Create module file
    createModuleFile(options),
    // 2. Create routing file if needed
    options.routing ? createRoutingFile(options) : () => {},
    // 3. Create components
    ...(options.components || []).map(name => 
      createComponentForModule(name, options.name)
    ),
    // 4. Update app routing
    options.routing ? updateAppRouting(options) : () => {}
  ]);
}

function createModuleFile(options: FeatureModuleOptions): Rule {
  return (tree: Tree, context: SchematicContext) => {
    const moduleName = strings.classify(options.name);
    const modulePath = `/src/app/${strings.dasherize(options.name)}/${strings.dasherize(options.name)}.module.ts`;
    
    const moduleContent = `
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
${options.routing ? `import { ${moduleName}RoutingModule } from './${strings.dasherize(options.name)}-routing.module';` : ''}

@NgModule({
  declarations: [],
  imports: [
    CommonModule${options.routing ? `,\n    ${moduleName}RoutingModule` : ''}
  ]
})
export class ${moduleName}Module { }
    `.trim();
    
    tree.create(modulePath, moduleContent);
    context.logger.info(`Created ${modulePath}`);
    
    return tree;
  };
}

function createRoutingFile(options: FeatureModuleOptions): Rule {
  return (tree: Tree, context: SchematicContext) => {
    const moduleName = strings.classify(options.name);
    const routingPath = `/src/app/${strings.dasherize(options.name)}/${strings.dasherize(options.name)}-routing.module.ts`;
    
    const routingContent = `
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class ${moduleName}RoutingModule { }
    `.trim();
    
    tree.create(routingPath, routingContent);
    context.logger.info(`Created ${routingPath}`);
    
    return tree;
  };
}

function updateAppRouting(options: FeatureModuleOptions): Rule {
  return (tree: Tree, context: SchematicContext) => {
    const appRoutingPath = '/src/app/app.routes.ts';
    
    if (!tree.exists(appRoutingPath)) {
      context.logger.warn('app.routes.ts not found');
      return tree;
    }
    
    const content = tree.read(appRoutingPath)?.toString('utf-8');
    if (!content) {
      throw new SchematicsException('Could not read app.routes.ts');
    }
    
    const moduleName = strings.dasherize(options.name);
    const newRoute = `
  {
    path: '${moduleName}',
    loadChildren: () => import('./${moduleName}/${moduleName}.module').then(m => m.${strings.classify(moduleName)}Module)
  }`;
    
    // Insert route before the last closing bracket
    const updatedContent = content.replace(
      /(\];)/,
      `,${newRoute}\n$1`
    );
    
    tree.overwrite(appRoutingPath, updatedContent);
    context.logger.info(`Updated ${appRoutingPath}`);
    
    return tree;
  };
}
```

**Collection Configuration:**

```json
// src/collection.json
{
  "$schema": "../node_modules/@angular-devkit/schematics/collection-schema.json",
  "schematics": {
    "my-component": {
      "description": "Create a custom component",
      "factory": "./my-component/index#myComponent",
      "schema": "./my-component/schema.json"
    },
    "feature-module": {
      "description": "Create a feature module with routing",
      "factory": "./feature-module/index#featureModule",
      "schema": "./feature-module/schema.json"
    }
  }
}
```

**Using Custom Schematics:**

```bash
# Build schematics
npm run build

# Link for local testing
npm link

# Use in Angular project
cd /path/to/angular-project
npm link my-schematics

# Run schematic
ng generate my-schematics:my-component my-feature
ng generate my-schematics:feature-module admin --routing --components=user-list,user-detail

# Or use with schematics CLI
schematics my-schematics:my-component my-feature --name=hero
```

#### React: Equivalent Code Generation

**Plop.js for React:**

```bash
# Install Plop
npm install --save-dev plop

# Create plopfile.js
```

```javascript
// plopfile.js
module.exports = function (plop) {
  // Component generator
  plop.setGenerator('component', {
    description: 'Create a React component',
    prompts: [
      {
        type: 'input',
        name: 'name',
        message: 'Component name:'
      },
      {
        type: 'confirm',
        name: 'typescript',
        message: 'Use TypeScript?',
        default: true
      },
      {
        type: 'confirm',
        name: 'styled',
        message: 'Include styled-components?',
        default: false
      }
    ],
    actions: function(data) {
      const actions = [];
      
      // Add component file
      actions.push({
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.{{#if typescript}}tsx{{else}}jsx{{/if}}',
        templateFile: 'plop-templates/Component.hbs'
      });
      
      // Add test file
      actions.push({
        type: 'add',
        path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.test.{{#if typescript}}tsx{{else}}jsx{{/if}}',
        templateFile: 'plop-templates/Component.test.hbs'
      });
      
      // Add styled component if needed
      if (data.styled) {
        actions.push({
          type: 'add',
          path: 'src/components/{{pascalCase name}}/{{pascalCase name}}.styles.ts',
          templateFile: 'plop-templates/Component.styles.hbs'
        });
      }
      
      return actions;
    }
  });
};
```

```handlebars
{{!-- plop-templates/Component.hbs --}}
{{#if typescript}}
import React from 'react';
{{#if styled}}
import { Container } from './{{pascalCase name}}.styles';
{{/if}}

interface {{pascalCase name}}Props {
  // Define props here
}

export const {{pascalCase name}}: React.FC<{{pascalCase name}}Props> = (props) => {
  return (
    {{#if styled}}<Container>{{else}}<div>{{/if}}
      <h2>{{pascalCase name}} Component</h2>
    {{#if styled}}</Container>{{else}}</div>{{/if}}
  );
};
{{else}}
import React from 'react';

export const {{pascalCase name}} = (props) => {
  return (
    <div>
      <h2>{{pascalCase name}} Component</h2>
    </div>
  );
};
{{/if}}
```

```bash
# Run generator
npm run plop component
# or
plop component
```

#### Comparison: Code Generation

| Feature | Angular Schematics | React Plop/Hygen |
|---------|------------------|-----------------|
| **Official Support** | ✅ Built into Angular CLI | External tools |
| **Template Engine** | TypeScript + EJS | Handlebars/EJS |
| **File Manipulation** | ✅ AST-based | Text-based |
| **Workspace Integration** | ✅ ng generate | Custom scripts |

**When to Use:**
- **Angular Schematics:** Automated component/module generation with CLI integration
- **React:** Plop.js or Hygen for custom templates

**Further Reading:**
- [Angular Schematics](https://angular.dev/tools/cli/schematics)
- [Plop.js](https://plopjs.com/)

---

### 4. Budgets & Bundle Analysis (Performance Optimization)

**Description:** Budgets enforce size limits on your application bundles, preventing performance regression. Configure thresholds for initial load, lazy chunks, and assets to maintain fast load times.

#### Angular: Budget Configuration

**angular.json Budget Setup:**

```json
// angular.json
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/my-app",
            "index": "src/index.html",
            "main": "src/main.ts",
            "polyfills": ["zone.js"],
            "tsConfig": "tsconfig.app.json",
            "assets": ["src/favicon.ico", "src/assets"],
            "styles": ["src/styles.scss"],
            "scripts": []
          },
          "configurations": {
            "production": {
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "500kb",
                  "maximumError": "1mb"
                },
                {
                  "type": "anyComponentStyle",
                  "maximumWarning": "6kb",
                  "maximumError": "10kb"
                },
                {
                  "type": "bundle",
                  "name": "main",
                  "maximumWarning": "500kb",
                  "maximumError": "1mb"
                },
                {
                  "type": "bundle",
                  "name": "polyfills",
                  "maximumWarning": "50kb",
                  "maximumError": "100kb"
                },
                {
                  "type": "anyLazyBundle",
                  "maximumWarning": "300kb",
                  "maximumError": "500kb"
                },
                {
                  "type": "anyScript",
                  "maximumWarning": "10kb",
                  "maximumError": "20kb"
                },
                {
                  "type": "all",
                  "maximumWarning": "2mb",
                  "maximumError": "5mb"
                }
              ],
              "outputHashing": "all"
            }
          }
        }
      }
    }
  }
}
```

**Budget Types Explained:**

```typescript
// Budget type: "initial"
// Applies to: main.js, polyfills.js, styles.css
// Description: Bundle loaded on app initialization
{
  "type": "initial",
  "maximumWarning": "500kb",  // Warning at 500kb
  "maximumError": "1mb"        // Build fails at 1mb
}

// Budget type: "anyComponentStyle"
// Applies to: Individual component styles
// Description: Enforces component-level CSS limits
{
  "type": "anyComponentStyle",
  "maximumWarning": "6kb",
  "maximumError": "10kb"
}

// Budget type: "bundle"
// Applies to: Specific named bundles
// Description: Target a specific bundle by name
{
  "type": "bundle",
  "name": "main",
  "maximumWarning": "500kb",
  "maximumError": "1mb"
}

// Budget type: "anyLazyBundle"
// Applies to: All lazy-loaded route modules
// Description: Ensures lazy chunks stay small
{
  "type": "anyLazyBundle",
  "maximumWarning": "300kb",
  "maximumError": "500kb"
}

// Budget type: "anyScript"
// Applies to: Third-party scripts
// Description: Limits external script sizes
{
  "type": "anyScript",
  "maximumWarning": "10kb",
  "maximumError": "20kb"
}

// Budget type: "all"
// Applies to: Total application size
// Description: Overall size limit for entire app
{
  "type": "all",
  "maximumWarning": "2mb",
  "maximumError": "5mb"
}
```

**Build with Budget Checks:**

```bash
# Production build with budget checks
ng build --configuration=production

# Example output:
# Budgets:
# ✓ initial: 487.2 KB (< 500 KB warning, < 1 MB error)
# ⚠ main: 523.4 KB (> 500 KB warning, < 1 MB error)
# ✓ polyfills: 45.3 KB (< 50 KB warning, < 100 KB error)
# ✓ styles.css: 12.1 KB
# ✓ lazy-admin.js: 234.5 KB (< 300 KB warning, < 500 KB error)
# ✓ Total: 1.8 MB (< 2 MB warning, < 5 MB error)

# Warning: build succeeds with warnings
# Error: build fails if error threshold exceeded
```

**Bundle Analysis:**

```bash
# Generate stats file
ng build --configuration=production --stats-json

# Analyze with webpack-bundle-analyzer
npm install --save-dev webpack-bundle-analyzer
npx webpack-bundle-analyzer dist/my-app/stats.json

# Or use source-map-explorer
npm install --save-dev source-map-explorer
npx source-map-explorer dist/my-app/**/*.js
```

**Optimization Strategies:**

```typescript
// 1. Lazy Loading Routes
// Split large features into separate bundles

// app.routes.ts
export const routes: Routes = [
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.routes').then(m => m.ADMIN_ROUTES)
    // Creates separate lazy bundle: admin-*.js
  },
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard.routes').then(m => m.DASHBOARD_ROUTES)
    // Creates separate lazy bundle: dashboard-*.js
  }
];

// 2. Code Splitting with Dynamic Imports
@Component({
  selector: 'app-heavy-feature',
  template: `
    <button (click)="loadHeavyLibrary()">Load Feature</button>
  `
})
export class HeavyFeatureComponent {
  async loadHeavyLibrary(): Promise<void> {
    // Dynamically import heavy library
    const { HeavyLibrary } = await import('heavy-library');
    const lib = new HeavyLibrary();
    lib.doSomething();
    // Creates separate chunk: heavy-library-*.js
  }
}

// 3. Tree Shaking - Remove Unused Code
// Only import what you need
import { map, filter } from 'rxjs/operators'; // ✓ Good
// import * as operators from 'rxjs/operators'; // ✗ Bad (imports everything)

// 4. OnPush Change Detection
// Reduces change detection overhead
@Component({
  selector: 'app-optimized',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class OptimizedComponent {}

// 5. Defer Loading (@defer)
// Defer non-critical components
@Component({
  template: `
    @defer (on viewport) {
      <app-heavy-chart />
    } @placeholder {
      <div>Loading chart...</div>
    }
  `
})
export class DashboardComponent {}
```

**Performance Budgets Example:**

```json
// Strict budgets for high-performance app
{
  "budgets": [
    {
      "type": "initial",
      "maximumWarning": "300kb",
      "maximumError": "500kb"
    },
    {
      "type": "anyComponentStyle",
      "maximumWarning": "4kb",
      "maximumError": "6kb"
    },
    {
      "type": "anyLazyBundle",
      "maximumWarning": "200kb",
      "maximumError": "300kb"
    }
  ]
}

// Relaxed budgets for feature-rich app
{
  "budgets": [
    {
      "type": "initial",
      "maximumWarning": "1mb",
      "maximumError": "2mb"
    },
    {
      "type": "anyComponentStyle",
      "maximumWarning": "10kb",
      "maximumError": "20kb"
    },
    {
      "type": "anyLazyBundle",
      "maximumWarning": "500kb",
      "maximumError": "1mb"
    }
  ]
}
```

**CI/CD Budget Enforcement:**

```yaml
# .github/workflows/build.yml
name: Build and Check Budgets

on:
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build production
        run: npm run build -- --configuration=production
        # This will fail if budgets exceeded
      
      - name: Generate bundle stats
        run: npm run build -- --configuration=production --stats-json
      
      - name: Analyze bundle size
        run: |
          npx webpack-bundle-analyzer dist/my-app/stats.json --mode static -O
          # Upload report as artifact
      
      - name: Comment PR with bundle sizes
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const stats = JSON.parse(fs.readFileSync('dist/my-app/stats.json', 'utf8'));
            // Post comment with bundle sizes
```

#### React: Equivalent Bundle Analysis

**Create React App Budgets:**

```javascript
// package.json
{
  "scripts": {
    "build": "react-scripts build",
    "analyze": "source-map-explorer 'build/static/js/*.js'"
  },
  "devDependencies": {
    "source-map-explorer": "^2.5.3"
  }
}

// Build and analyze
npm run build
npm run analyze
```

**Vite Bundle Analysis:**

```javascript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    react(),
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true
    })
  ],
  build: {
    // Set chunk size warnings
    chunkSizeWarningLimit: 500, // KB
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom'],
          'ui': ['@mui/material']
        }
      }
    }
  }
});
```

**Custom Budget Script:**

```javascript
// check-bundle-size.js
const fs = require('fs');
const path = require('path');
const gzipSize = require('gzip-size');

const BUDGETS = {
  'main': 500 * 1024,        // 500 KB
  'vendor': 300 * 1024,      // 300 KB
  'total': 1 * 1024 * 1024   // 1 MB
};

const buildDir = path.join(__dirname, 'build/static/js');
const files = fs.readdirSync(buildDir);

let totalSize = 0;
let failed = false;

files.forEach(file => {
  if (!file.endsWith('.js')) return;
  
  const filePath = path.join(buildDir, file);
  const size = gzipSize.sync(fs.readFileSync(filePath));
  totalSize += size;
  
  const sizeKB = (size / 1024).toFixed(2);
  console.log(`${file}: ${sizeKB} KB`);
  
  // Check against budgets
  const chunkName = file.split('.')[0];
  if (BUDGETS[chunkName] && size > BUDGETS[chunkName]) {
    console.error(`❌ ${file} exceeds budget: ${sizeKB} KB > ${(BUDGETS[chunkName] / 1024).toFixed(0)} KB`);
    failed = true;
  }
});

const totalKB = (totalSize / 1024).toFixed(2);
console.log(`\nTotal: ${totalKB} KB`);

if (totalSize > BUDGETS.total) {
  console.error(`❌ Total bundle size exceeds budget: ${totalKB} KB > ${(BUDGETS.total / 1024).toFixed(0)} KB`);
  failed = true;
}

if (failed) {
  process.exit(1);
}
```

#### Comparison: Budgets

| Feature | Angular Budgets | React Bundle Analysis |
|---------|----------------|---------------------|
| **Built-in** | ✅ angular.json | Custom scripts |
| **Budget Types** | ✅ Multiple types | Manual implementation |
| **Build Failure** | ✅ Automatic | Custom script |
| **Analysis Tools** | webpack-bundle-analyzer | source-map-explorer |

**When to Use:**
- **Angular:** Built-in budgets with automated enforcement
- **React:** Custom scripts or Vite plugins

**Further Reading:**
- [Angular Budgets](https://angular.dev/tools/cli/build#configuring-size-budgets)
- [Webpack Bundle Analyzer](https://www.npmjs.com/package/webpack-bundle-analyzer)

---

### 5. Zone.js Internals (Change Detection Mechanism)

**Description:** Zone.js is Angular's automatic change detection mechanism. It patches async APIs to detect when data might have changed, triggering change detection automatically. Understanding Zone.js helps optimize performance.

#### Angular: Zone.js Deep Dive

**How Zone.js Works:**

```typescript
// Zone.js patches async APIs to track execution context
// Patched APIs: setTimeout, setInterval, Promise, XMLHttpRequest, addEventListener

// Without Zone.js (manual change detection)
class ManualComponent {
  count = 0;
  
  incrementManually(): void {
    setTimeout(() => {
      this.count++;
      // Need to manually trigger change detection
      this.changeDetectorRef.detectChanges();
    }, 1000);
  }
}

// With Zone.js (automatic change detection)
@Component({
  selector: 'app-auto',
  template: `<div>Count: {{ count }}</div>`
})
export class AutoComponent {
  count = 0;
  
  incrementAutomatically(): void {
    setTimeout(() => {
      this.count++;
      // Zone.js automatically triggers change detection
    }, 1000);
  }
}
```

**Zone.js Patched APIs:**

```typescript
// 1. Timers
setTimeout(() => {
  // Change detection triggered after callback
  console.log('Timer completed');
}, 1000);

setInterval(() => {
  // Change detection triggered after each interval
  console.log('Interval tick');
}, 1000);

// 2. Promises
fetch('/api/data')
  .then(response => response.json())
  .then(data => {
    // Change detection triggered after promise resolves
    this.data = data;
  });

// 3. Events
button.addEventListener('click', () => {
  // Change detection triggered after event handler
  this.handleClick();
});

// 4. XHR/Fetch
const xhr = new XMLHttpRequest();
xhr.onload = () => {
  // Change detection triggered after XHR completes
  this.data = JSON.parse(xhr.responseText);
};
xhr.open('GET', '/api/data');
xhr.send();
```

**Running Outside Zone:**

```typescript
// Use NgZone to run code outside Angular's zone
// Useful for performance-critical operations

@Component({
  selector: 'app-outside-zone',
  template: `
    <div>
      <p>Count: {{ count }}</p>
      <p>Progress: {{ progress }}%</p>
    </div>
  `
})
export class OutsideZoneComponent {
  private ngZone = inject(NgZone);
  
  count = 0;
  progress = 0;

  // Heavy computation that updates frequently
  startHeavyTask(): void {
    // Run outside Angular zone to avoid change detection on every update
    this.ngZone.runOutsideAngular(() => {
      let current = 0;
      const interval = setInterval(() => {
        current += 1;
        this.progress = current;
        
        if (current >= 100) {
          clearInterval(interval);
          
          // Re-enter Angular zone to trigger change detection once
          this.ngZone.run(() => {
            this.count++;
            console.log('Task completed');
          });
        }
      }, 10); // Updates every 10ms, but doesn't trigger CD each time
    });
  }

  // Animation loop outside zone
  startAnimation(): void {
    this.ngZone.runOutsideAngular(() => {
      const canvas = document.getElementById('canvas') as HTMLCanvasElement;
      const ctx = canvas.getContext('2d')!;
      
      const animate = () => {
        // Draw frame (no change detection)
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.fillRect(Math.random() * canvas.width, Math.random() * canvas.height, 10, 10);
        
        requestAnimationFrame(animate);
      };
      
      animate();
    });
  }
}
```

**Zone.js Configuration:**

```typescript
// main.ts - Customize Zone.js behavior
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';

// Configure Zone.js before bootstrap
(window as any).__Zone_disable_requestAnimationFrame = true; // Disable RAF patching
(window as any).__Zone_disable_timers = true; // Disable setTimeout/setInterval patching
(window as any).__Zone_disable_on_property = true; // Disable event listener patching

bootstrapApplication(AppComponent, {
  providers: [
    // Use NgZone with event coalescing
    { provide: NgZone, useFactory: () => new NgZone({ shouldCoalesceEventChangeDetection: true }) }
  ]
});
```

**Zoneless Angular (Experimental):**

```typescript
// main.ts - Bootstrap without Zone.js
import { bootstrapApplication } from '@angular/platform-browser';
import { provideExperimentalZonelessChangeDetection } from '@angular/core';
import { AppComponent } from './app/app.component';

// Remove zone.js from polyfills in angular.json
bootstrapApplication(AppComponent, {
  providers: [
    provideExperimentalZonelessChangeDetection()
  ]
});

// With zoneless, use signals for reactive updates
@Component({
  selector: 'app-zoneless',
  template: `
    <div>
      <p>Count: {{ count() }}</p>
      <button (click)="increment()">Increment</button>
    </div>
  `
})
export class ZonelessComponent {
  // Signals trigger change detection automatically
  count = signal(0);

  increment(): void {
    this.count.update(c => c + 1);
  }

  // For async operations, use signals
  async fetchData(): Promise<void> {
    const response = await fetch('/api/data');
    const data = await response.json();
    
    // Update signal to trigger change detection
    this.dataSignal.set(data);
  }
}
```

**Zone.js Performance Tips:**

```typescript
// 1. Use OnPush change detection
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class OptimizedComponent {}

// 2. Detach change detector for manual control
@Component({
  selector: 'app-manual-cd',
  template: `<div>{{ value }}</div>`
})
export class ManualCDComponent {
  private cdr = inject(ChangeDetectorRef);
  value = 0;

  ngOnInit() {
    // Detach from change detection
    this.cdr.detach();
    
    // Manually trigger when needed
    setInterval(() => {
      this.value++;
      this.cdr.detectChanges();
    }, 1000);
  }
}

// 3. Use pure pipes for expensive computations
@Pipe({
  name: 'expensiveTransform',
  pure: true // Only re-run when input changes
})
export class ExpensivePipe implements PipeTransform {
  transform(value: any): any {
    // Expensive computation
    return heavyCalculation(value);
  }
}

// 4. Avoid function calls in templates
// ✗ Bad: called on every change detection
@Component({
  template: `<div>{{ getExpensiveValue() }}</div>`
})

// ✓ Good: computed once
@Component({
  template: `<div>{{ expensiveValue }}</div>`
})
export class GoodComponent {
  expensiveValue = computed(() => this.heavyCalculation());
}
```

**Zone.js Debugging:**

```typescript
// Enable Zone.js debugging
// Add to polyfills.ts or main.ts
(window as any).__Zone_enable_long_stack_trace = true;

// This provides better error stack traces showing
// where async operations originated

// Example: Debug change detection
import { ApplicationRef } from '@angular/core';

@Component({
  selector: 'app-debug',
  template: `<button (click)="debug()">Debug CD</button>`
})
export class DebugComponent {
  private appRef = inject(ApplicationRef);

  debug(): void {
    // Check if change detection is enabled
    console.log('Tick count:', this.appRef.tick.name);
    
    // Subscribe to stability
    this.appRef.isStable.subscribe(stable => {
      console.log('App stable:', stable);
    });
    
    // Manually trigger change detection
    this.appRef.tick();
  }
}
```

#### React: No Zone.js Equivalent

**React's Reconciliation:**

```tsx
// React doesn't use Zone.js
// Change detection triggered by:
// 1. setState/useState
// 2. useReducer dispatch
// 3. forceUpdate (class components)

function ReactComponent() {
  const [count, setCount] = useState(0);

  // Triggers re-render
  const increment = () => {
    setCount(c => c + 1);
  };

  // Does NOT trigger re-render (need to call setCount)
  useEffect(() => {
    setTimeout(() => {
      // Must use setCount to trigger re-render
      setCount(c => c + 1);
    }, 1000);
  }, []);

  return <div>Count: {count}</div>;
}

// React 18 Concurrent Features
import { startTransition } from 'react';

function ConcurrentComponent() {
  const [value, setValue] = useState('');
  const [results, setResults] = useState([]);

  const handleChange = (e) => {
    setValue(e.target.value);
    
    // Low priority update
    startTransition(() => {
      setResults(expensiveSearch(e.target.value));
    });
  };

  return (
    <div>
      <input value={value} onChange={handleChange} />
      <Results items={results} />
    </div>
  );
}
```

#### Comparison: Change Detection

| Feature | Angular Zone.js | React Reconciliation |
|---------|----------------|---------------------|
| **Automatic** | ✅ All async APIs | Manual setState |
| **Performance** | Can be overhead | Optimized by default |
| **Control** | NgZone, OnPush | useMemo, memo() |
| **Future** | Zoneless + Signals | Concurrent features |

**When to Use:**
- **Angular:** Zone.js (default) or Zoneless with Signals
- **React:** Built-in reconciliation with hooks

**Further Reading:**
- [Angular Zone.js](https://angular.dev/guide/zone)
- [React Reconciliation](https://react.dev/learn/render-and-commit)

---

## Part 6 Summary

This part covered **5 Tooling & DevOps Features**:

1. ✅ **Angular DevTools** - Browser extension for debugging and profiling
2. ✅ **AOT vs JIT** - Compilation strategies and optimization
3. ✅ **Custom Schematics** - Code generation and scaffolding
4. ✅ **Budgets** - Bundle size monitoring and enforcement
5. ✅ **Zone.js** - Automatic change detection mechanism

**Progress: 38/38 features complete (100%)** 🎉

---

## Complete Guide Summary

This comprehensive guide covered **38 Angular Advanced Features** across 6 parts:

### Part 1: Critical Modern Features (8)
✅ Signals, Standalone Components, Control Flow, Deferrable Views, Required Inputs, inject(), takeUntilDestroyed(), DestroyRef

### Part 2: Core Concepts - First Section (3)
✅ NgModules, View Encapsulation, ng-template

### Part 3: Core Concepts - Remaining (6)
✅ ng-container, Dynamic Components, @ContentChild/@ContentChildren, @ViewChildren, ControlValueAccessor, ChangeDetectorRef

### Part 4: Advanced Features (9)
✅ Angular Universal (SSR), Angular Elements, Service Workers/PWA, Renderer2, APP_INITIALIZER, HttpContext, Multi Providers, Environment Files, Typed Reactive Forms

### Part 5: Routing Features (6)
✅ Router Events, Auxiliary Routes, Route Animations, Matrix Parameters, Title Strategy, withComponentInputBinding

### Part 6: Tooling & DevOps (5)
✅ Angular DevTools, AOT vs JIT, Custom Schematics, Budgets, Zone.js

---

**Total: 38 Features Documented with:**
- ✅ Detailed TypeScript/Angular implementations
- ✅ Extensive inline code comments
- ✅ React/Next.js equivalent patterns
- ✅ Comparison tables
- ✅ Best practices and when to use
- ✅ Further reading links

**Your single source of truth for studying Angular 14-17+ advanced features is now complete!**

