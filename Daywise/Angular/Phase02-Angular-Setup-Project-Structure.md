# Phase 2: Angular Setup & Project Structure

> This phase gets Angular installed on your machine, creates your first app, and explains every single file and folder so you know exactly what's happening under the hood.

---

## 2.1 What is Angular CLI?

**CLI = Command Line Interface**

Angular CLI is a powerful tool that:
- **Creates** new Angular projects with proper structure
- **Generates** components, services, modules, pipes, guards, etc.
- **Serves** your app locally with live reload
- **Builds** your app for production (optimized, minified)
- **Tests** your app (unit tests and end-to-end tests)
- **Lints** your code for errors and style issues

**Why use it?**
Without CLI, you'd need to manually configure:
- TypeScript compiler
- Webpack bundler
- Development server
- Test runners
- File structure
- Build optimization

The CLI does ALL of this for you. It's like having an expert configure your project perfectly every time.

---

## 2.2 Installing Angular CLI

```bash
# Install Angular CLI globally
npm install -g @angular/cli

# Verify installation
ng version
# Output shows Angular CLI version, Node version, OS, etc.
```

**What `ng` means:**
- `ng` is the command for Angular CLI
- It stands for "A**ng**ular"
- Every Angular CLI command starts with `ng`

**What `-g` means:**
- Installs the package globally on your computer
- Makes the `ng` command available from ANY directory
- Without `-g`, it would only install in the current project

---

## 2.3 Creating Your First Angular App

```bash
# Create a new Angular project
ng new my-first-app
```

**The CLI will ask you questions:**

```
? Would you like to add Angular routing? (y/N)
```
- **Choose Yes** — routing lets your app have multiple pages/views
- Without routing, you'd have a single-page app with no navigation

```
? Which stylesheet format would you like to use?
  CSS
  SCSS
  Sass
  Less
```
- **CSS** — plain CSS, simplest option for beginners
- **SCSS** — CSS with superpowers (variables, nesting, mixins). Most popular choice
- The others are alternatives to SCSS

**What happens behind the scenes when you run `ng new`:**

1. Creates the folder structure
2. Generates all configuration files (tsconfig, angular.json, etc.)
3. Creates the root module and root component
4. Sets up routing (if chosen)
5. Runs `npm install` to download all dependencies (this takes a minute)
6. Initializes a git repository

---

## 2.4 Running the App

```bash
# Navigate into the project
cd my-first-app

# Start the development server
ng serve
```

**What `ng serve` does:**

1. **Compiles** TypeScript to JavaScript
2. **Bundles** all your code using Webpack/esbuild
3. **Starts** a development server at `http://localhost:4200`
4. **Watches** for file changes — when you save a file, it auto-recompiles and refreshes the browser

```bash
# Useful flags
ng serve --open          # Automatically opens browser (shortcut: -o)
ng serve --port 3000     # Use a different port
ng serve --host 0.0.0.0  # Allow access from other devices on network
```

**Open http://localhost:4200** in your browser — you'll see the Angular welcome page!

---

## 2.5 Complete Project Structure Explained

Here's what every file and folder does:

```
my-first-app/
│
├── node_modules/            ← Downloaded packages (NEVER edit)
│
├── src/                     ← YOUR CODE LIVES HERE
│   ├── app/                 ← Application code
│   │   ├── app.component.ts       ← Root component (TypeScript logic)
│   │   ├── app.component.html     ← Root component template (UI)
│   │   ├── app.component.css      ← Root component styles
│   │   ├── app.component.spec.ts  ← Root component tests
│   │   ├── app.module.ts          ← Root module (registers everything)
│   │   └── app-routing.module.ts  ← Routing configuration
│   │
│   ├── assets/              ← Static files (images, icons, fonts)
│   ├── environments/        ← Environment-specific config (removed in v15+)
│   ├── index.html           ← THE single HTML page (SPA entry point)
│   ├── main.ts              ← Application entry point (bootstraps Angular)
│   ├── styles.css           ← Global styles (apply to entire app)
│   └── favicon.ico          ← Browser tab icon
│
├── angular.json             ← CLI configuration (build, serve, test settings)
├── package.json             ← Dependencies and npm scripts
├── package-lock.json        ← Locked dependency versions
├── tsconfig.json            ← TypeScript compiler options (base)
├── tsconfig.app.json        ← TypeScript options for the app
├── tsconfig.spec.json       ← TypeScript options for tests
├── .gitignore               ← Files git should ignore
├── .editorconfig            ← Editor formatting rules
└── README.md                ← Project documentation
```

---

## 2.6 Deep Dive: Each File Explained

### 2.6.1 `index.html` — The Single Page

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>MyFirstApp</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
</head>
<body>
  <app-root></app-root>   <!-- THIS IS THE KEY LINE -->
</body>
</html>
```

**Explanation:**
- This is the ONLY HTML file in your entire Angular app
- `<base href="/">` tells Angular where the app lives (important for routing)
- `<app-root></app-root>` is NOT a standard HTML tag — it's your Angular component
- When Angular starts, it finds `<app-root>` and replaces it with your `AppComponent`'s template
- The CLI automatically injects script tags during build (you won't see them in the source)

**Why only one HTML page?**
This is a **Single Page Application (SPA)**. Instead of loading a new HTML page for each route, Angular dynamically swaps content inside this one page. This makes navigation instant — no server round-trips.

---

### 2.6.2 `main.ts` — The Bootstrap File

```typescript
import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));
```

**Explanation — line by line:**

1. `platformBrowserDynamic` — tells Angular to run in a web browser (Angular can also run on servers, mobile, etc.)
2. `AppModule` — your root module, the starting point of your app
3. `bootstrapModule(AppModule)` — "Start the app using AppModule as the entry point"
4. `.catch(err => ...)` — if something goes wrong during startup, log the error

**The startup sequence:**
```
Browser loads index.html
  → index.html loads JavaScript bundles (generated from main.ts)
    → main.ts calls bootstrapModule(AppModule)
      → Angular reads AppModule's configuration
        → Finds AppComponent as the bootstrap component
          → Looks for <app-root> in index.html
            → Renders AppComponent's template inside <app-root>
```

**In newer Angular (v17+), standalone apps use a simpler bootstrap:**
```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig)
  .catch(err => console.error(err));
```

---

### 2.6.3 `app.module.ts` — The Root Module

```typescript
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

@NgModule({
  declarations: [
    AppComponent    // List ALL components, directives, pipes that belong to this module
  ],
  imports: [
    BrowserModule,      // Required for running in a browser
    AppRoutingModule    // Routing configuration
  ],
  providers: [],        // Services registered here (or use providedIn: 'root')
  bootstrap: [AppComponent]  // The component to start with
})
export class AppModule { }
```

**Explanation of each section:**

| Property | Purpose | Example |
|---|---|---|
| `declarations` | Components, directives, pipes that THIS module owns | `[AppComponent, HeaderComponent]` |
| `imports` | OTHER modules this module needs | `[BrowserModule, FormsModule, HttpClientModule]` |
| `providers` | Services available to this module | `[UserService, AuthService]` |
| `bootstrap` | The FIRST component to render when the app starts | `[AppComponent]` |

**Think of @NgModule as a box:**
- `declarations` = what's INSIDE the box (components I created)
- `imports` = other boxes I need (modules from Angular or third-party)
- `providers` = services (shared tools available to everything in the box)
- `bootstrap` = the entry door (which component starts first)

---

### 2.6.4 `app.component.ts` — The Root Component

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',           // The HTML tag: <app-root></app-root>
  templateUrl: './app.component.html',  // The HTML template file
  styleUrls: ['./app.component.css']    // The CSS file(s)
})
export class AppComponent {
  title = 'my-first-app';   // A property — can be used in the template
}
```

**Explanation of @Component metadata:**

| Property | What it does | Example |
|---|---|---|
| `selector` | The custom HTML tag to use this component | `'app-root'` → `<app-root>` |
| `templateUrl` | Path to the HTML template file | `'./app.component.html'` |
| `template` | Inline HTML template (alternative to templateUrl) | `` `<h1>Hello</h1>` `` |
| `styleUrls` | Path to CSS file(s) — scoped to this component | `['./app.component.css']` |
| `styles` | Inline CSS (alternative to styleUrls) | `` [`h1 { color: red; }`] `` |

**Important concept — Style Encapsulation:**
CSS in `app.component.css` ONLY applies to `app.component.html`. It won't leak to other components. Angular achieves this by adding unique attributes to elements (like `_ngcontent-abc-1`).

---

### 2.6.5 `app.component.html` — The Root Template

```html
<!-- Default template (Angular v17+) -->
<h1>Hello, {{ title }}</h1>
<p>Welcome to your Angular app!</p>

<!-- The router-outlet renders child route components -->
<router-outlet></router-outlet>
```

**`{{ title }}`** — This is **interpolation**. It displays the value of the `title` property from `app.component.ts`. When `title` changes, the display updates automatically.

**`<router-outlet>`** — This is a **placeholder**. When you navigate to different URLs, Angular renders the matching component inside this tag.

---

### 2.6.6 `angular.json` — Project Configuration

This file configures the Angular CLI. Key sections:

```json
{
  "projects": {
    "my-first-app": {
      "architect": {
        "build": {
          "options": {
            "outputPath": "dist/my-first-app",  // Where built files go
            "index": "src/index.html",           // Entry HTML
            "main": "src/main.ts",               // Entry TypeScript
            "assets": ["src/favicon.ico", "src/assets"],  // Static files
            "styles": ["src/styles.css"],         // Global styles
            "scripts": []                         // Global scripts
          }
        },
        "serve": {
          "options": {
            "port": 4200    // Dev server port
          }
        }
      }
    }
  }
}
```

**When you'd edit this file:**
- Adding global CSS libraries (e.g., Bootstrap): add to `styles` array
- Adding global JS libraries: add to `scripts` array
- Changing the build output path
- Configuring proxies for API calls during development
- Adding custom environments

---

### 2.6.7 `tsconfig.json` — TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2022",           // Compile to this JS version
    "module": "ES2022",           // Module system
    "strict": true,               // Enable all strict type checks
    "sourceMap": true,            // Generate source maps for debugging
    "experimentalDecorators": true, // Enable @Component, @Injectable, etc.
    "moduleResolution": "node",   // How to find modules
    "baseUrl": "./",              // Base path for imports
    "outDir": "./dist/out-tsc",   // Where compiled JS goes
    "declaration": false,
    "downlevelIteration": true,
    "importHelpers": true,
    "lib": ["ES2022", "dom"]      // Available APIs (ES2022 + browser DOM)
  }
}
```

**Key takeaway:** `experimentalDecorators: true` is what makes `@Component()` and other decorators work. Without it, TypeScript wouldn't understand decorators.

---

## 2.7 How Angular Boots Up — The Complete Flow

Understanding the startup sequence is crucial:

```
1. User opens http://localhost:4200
   ↓
2. Server sends index.html
   ↓
3. Browser parses index.html
   - Finds <app-root></app-root>
   - Loads JavaScript bundles (main.js, vendor.js, etc.)
   ↓
4. main.ts executes
   - Calls platformBrowserDynamic().bootstrapModule(AppModule)
   ↓
5. Angular reads @NgModule metadata from AppModule
   - Sees bootstrap: [AppComponent]
   - Reads AppComponent's @Component metadata
   - Sees selector: 'app-root'
   ↓
6. Angular finds <app-root> in index.html
   ↓
7. Angular compiles AppComponent's template
   - Resolves {{ title }} → "my-first-app"
   - Renders the final HTML
   ↓
8. The compiled HTML replaces <app-root> in the DOM
   ↓
9. App is running! Angular listens for changes and updates the DOM
```

---

## 2.8 Essential CLI Commands to Know Now

```bash
# --- Creating things ---
ng new my-app                    # New project
ng generate component header     # New component (shortcut: ng g c header)
ng generate service user         # New service (shortcut: ng g s user)

# --- Running the app ---
ng serve                         # Start dev server
ng serve -o                      # Start and open browser
ng serve --port 3000             # Use port 3000

# --- Building ---
ng build                         # Dev build
ng build --configuration production  # Production build

# --- Testing ---
ng test                          # Run unit tests

# --- Getting help ---
ng help                          # See all commands
ng generate --help               # See all generate options
```

---

## 2.9 Your First Code Change

Let's modify the app to prove everything works:

**Step 1:** Open `src/app/app.component.ts`
```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'Angular Learning Journey';    // Changed!
  message = 'I am learning Angular!';   // Added!
}
```

**Step 2:** Open `src/app/app.component.html` and replace ALL content with:
```html
<div class="container">
  <h1>{{ title }}</h1>
  <p>{{ message }}</p>
  <p>2 + 2 = {{ 2 + 2 }}</p>
  <p>Today is {{ today }}</p>
</div>
```

Wait — we used `{{ today }}` but didn't define it! Let's fix that.

**Step 3:** Update `app.component.ts`:
```typescript
export class AppComponent {
  title = 'Angular Learning Journey';
  message = 'I am learning Angular!';
  today = new Date().toLocaleDateString();  // Added!
}
```

**Step 4:** Add some styles in `app.component.css`:
```css
.container {
  max-width: 600px;
  margin: 50px auto;
  padding: 20px;
  font-family: Arial, sans-serif;
  text-align: center;
}

h1 {
  color: #dd0031;  /* Angular red */
}
```

Save all files. The browser should auto-refresh and show your changes!

**What just happened:**
- You defined properties in the component CLASS (`title`, `message`, `today`)
- You displayed them in the TEMPLATE using interpolation `{{ }}`
- You added SCOPED styles that only affect this component
- Angular detected your file changes, recompiled, and refreshed the browser

---

## 2.10 Summary

| Concept | What You Learned |
|---|---|
| Angular CLI | Tool to create, serve, build, test Angular apps |
| `ng new` | Creates a complete project with all config |
| `ng serve` | Runs dev server with live reload |
| `index.html` | The single page in your SPA |
| `main.ts` | Bootstraps/starts the Angular application |
| `app.module.ts` | Root module — registers all parts of the app |
| `app.component.ts` | Root component — the first UI element |
| `angular.json` | CLI build/serve configuration |
| `tsconfig.json` | TypeScript compiler configuration |
| Boot sequence | index.html → main.ts → AppModule → AppComponent → DOM |

---

**Next:** [Phase 3 — Core Concepts (Components, Data Binding, Directives, Pipes)](./Phase03-Core-Concepts.md)
