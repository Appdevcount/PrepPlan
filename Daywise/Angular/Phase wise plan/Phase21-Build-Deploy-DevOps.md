# Phase 21: Build, Deploy & DevOps

> **A great Angular developer does not stop at writing code — they ensure that code reaches users reliably, efficiently, and repeatedly. Mastering the build and deployment pipeline transforms you from a developer who builds features into an engineer who ships products.**

---

## 21.1 Why Build & Deploy Knowledge Matters

### The Problem: "It Works on My Machine"

Every developer has heard (or said) this phrase. You write beautiful Angular code, it runs perfectly on your laptop, and then everything breaks in production. Understanding the full build and deploy pipeline eliminates this problem permanently.

**Why frontend developers must understand DevOps:**
- You own the performance of what users actually receive
- Debugging production issues requires knowing how the build transformed your code
- Bundle size, caching strategies, and deployment configuration directly affect user experience
- Modern teams expect full-stack awareness — including CI/CD

### Real-World Analogy: The Chef Who Never Serves

Imagine a chef who spends all day perfecting recipes in the kitchen but has no idea how the food gets to the table. They don't know:
- How long dishes sit under the heat lamp before reaching the customer (latency)
- Whether the waiter drops the plate (deployment failure)
- If the portion sizes match what was ordered (bundle size expectations)
- Whether the dish is still hot when it arrives (caching policies)

A great chef understands the entire journey from kitchen to customer. A great Angular developer understands the entire journey from `git push` to the user's browser.

```
THE FULL JOURNEY
================

Your Code                    User's Browser
─────────────────────────────────────────────────────────────────
  [TypeScript]                    [Rendered HTML]
      ↓                               ↑
  [Build Pipeline]            [CDN / Server]
      ↓                               ↑
  [Docker Image]         [Deployed Bundles]
      ↓                               ↑
  [CI/CD Pipeline] ──────────────────┘
      ↓
  [Git Repository]
```

Without understanding this pipeline, you are the chef who only cooks but never serves.

---

## 21.2 Angular Build Process

### What Happens When You Run `ng build`?

When you type `ng build`, Angular does not simply copy your files to a folder. It runs your TypeScript and HTML templates through a sophisticated compilation and bundling pipeline.

```
ng build — Under the Hood
═══════════════════════════════════════════════════════════════════

  Source Files                  Build Pipeline                Output
  ────────────                  ─────────────                 ──────

  *.ts (TypeScript)
       │
       ▼
  TypeScript Compiler (tsc)     ← Type checking happens here
       │
       ▼
  Angular Compiler (ngc)        ← Compiles templates to JS (AOT)
       │                          Converts HTML → TypeScript factory functions
       ▼
  Tree Shaking                  ← Removes unused code
       │
       ▼
  Bundler (Webpack or esbuild)  ← Combines modules into bundles
       │
       ▼
  Minification / Uglification   ← Renames variables to a, b, c...
       │
       ▼
  Code Splitting                ← Splits into main + lazy chunks
       │
       ▼
  Output Hashing                ← main.abc123.js (cache busting)
       │
       ▼                        dist/my-app/
  Output                        ├── index.html
                                 ├── main.abc123.js
                                 ├── polyfills.def456.js
                                 ├── styles.ghi789.css
                                 └── chunk-ROUTE-NAME.jkl012.js
```

### AOT vs JIT Compilation

**Just-in-Time (JIT) Compilation** — compile in the browser, at runtime.
**Ahead-of-Time (AOT) Compilation** — compile during the build, before shipping to the browser.

**The Analogy:** JIT is like translating a book for a foreign reader while they sit waiting — slow and wasteful. AOT is like shipping the pre-translated book — the reader opens it and starts reading immediately.

```
JIT Compilation (old way — Angular 8 and below default for dev)
═══════════════════════════════════════════════════════════════

  Browser receives:
    main.js        ← Contains Angular compiler + your app code
       │
       ▼
    Browser downloads Angular compiler (~200KB extra!)
       │
       ▼
    Compiler reads your HTML templates as strings at runtime
       │
       ▼
    Compiles templates → JavaScript (takes time during page load)
       │
       ▼
    App becomes interactive  (SLOW STARTUP)


AOT Compilation (default since Angular 9 — Ivy)
═══════════════════════════════════════════════════════════════

  Build machine runs:
    Angular compiler reads your HTML templates
       │
       ▼
    Converts templates → optimized JavaScript factory functions
       │
       ▼
    Angular compiler is NOT included in the bundle
       │
       ▼
  Browser receives:
    main.js        ← Pre-compiled JS, no compiler needed
       │
       ▼
    App becomes interactive  (FAST STARTUP)
```

**AOT Benefits:**

| Benefit | Explanation |
|---------|-------------|
| **Faster rendering** | Browser executes pre-compiled JS — no compilation step at startup |
| **Smaller bundles** | Angular compiler (~200KB) is NOT shipped to the browser |
| **Fewer async requests** | Inlined HTML/CSS, fewer separate template requests |
| **Template error detection** | `<div *ngIf="user.nmae">` — typo caught at BUILD time, not runtime |
| **Better security** | Templates compiled to JS — no HTML injection via eval() |

**Comparison Table: AOT vs JIT**

| Feature | AOT | JIT |
|---------|-----|-----|
| When compilation happens | Build time (server/CI) | Runtime (browser) |
| Angular compiler in bundle | No | Yes (~200KB overhead) |
| Template errors detected | At build time | At runtime (in browser console) |
| Startup performance | Fast | Slower |
| Build time | Slower | Faster |
| Default since Angular | 9 (Ivy) | 2-8 (dev mode) |
| `--aot` flag needed? | No (default) | `--aot=false` to disable |
| Production builds | Always AOT | N/A |
| Use case today | Always | Rarely (legacy debugging only) |

**Code example showing AOT template error detection:**

```typescript
// user.component.html — AOT CATCHES THIS AT BUILD TIME
<div>{{ user.nmae }}</div>
//                  ↑
// AOT: "Property 'nmae' does not exist on type 'User'"
// JIT: Renders blank — silent failure at runtime!

// user.ts
interface User {
  name: string;    // ← correct property name
  email: string;
}
```

```bash
# Build commands
ng build                    # ← Development build (AOT on, no optimization)
ng build --configuration=production  # ← Production build (AOT + optimization)
ng build --aot=false        # ← Disable AOT (almost never do this)
```

---

## 21.3 Build Configurations

### The Problem: One App, Many Environments

Your app runs in development (localhost), staging (test.myapp.com), UAT (uat.myapp.com), and production (myapp.com). Each environment needs:
- Different API URLs
- Different logging levels
- Different feature flags
- Different optimization levels

**Analogy:** A camera has different shooting modes — portrait, landscape, sports, manual. Same camera hardware, different configuration for each use case. `angular.json` is your camera's mode selector.

### Angular.json Build Configuration Structure

```json
// angular.json — the central configuration file for Angular CLI
{
  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "version": 1,
  "projects": {
    "my-angular-app": {                        // ← your project name
      "architect": {
        "build": {                             // ← the build target
          "builder": "@angular-devkit/build-angular:application",
          // ↑ "application" = esbuild (Angular 17+)
          // use "browser" for webpack (legacy)

          "options": {
            // ─── BASE OPTIONS (apply to ALL configurations) ───────────────
            "outputPath": "dist/my-angular-app",   // ← where output files go
            "index": "src/index.html",             // ← the HTML entry point
            "browser": "src/main.ts",              // ← JS entry point
            "polyfills": ["zone.js"],              // ← browser compatibility shims
            "tsConfig": "tsconfig.app.json",       // ← TypeScript config

            "assets": [                            // ← files copied as-is
              "src/favicon.ico",
              "src/assets",
              {
                "glob": "**/*",
                "input": "public",                 // ← Angular 17+ public folder
                "output": "/"
              }
            ],

            "styles": [
              "src/styles.css"                     // ← global stylesheets
            ],

            "scripts": []                          // ← global JS scripts (avoid these)
          },

          "configurations": {

            // ─── PRODUCTION CONFIGURATION ────────────────────────────────
            "production": {
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "500kB",        // ← warn if initial bundle > 500KB
                  "maximumError": "1MB"             // ← fail build if > 1MB
                },
                {
                  "type": "anyComponentStyle",
                  "maximumWarning": "2kB",          // ← warn if component CSS > 2KB
                  "maximumError": "4kB"             // ← fail if component CSS > 4KB
                }
              ],

              "outputHashing": "all",
              // ↑ Appends content hash to filenames: main.abc123.js
              // This is CACHE BUSTING — browsers cache by filename,
              // so changing content = changing filename = cache miss = fresh file

              "optimization": true,
              // ↑ Enables: minification, tree shaking, dead code elimination
              // Renames variables: myLongVariableName → a
              // Removes whitespace, comments, console.log (with proper config)

              "sourceMap": false,
              // ↑ DO NOT ship source maps to production (exposes your source code)
              // Exception: use hidden source maps + Sentry for error tracking

              "namedChunks": false,
              // ↑ Lazy chunks get random names: chunk-ABCD1234.js
              // In dev you might want: chunk-home.js for easier debugging

              "extractLicenses": true,
              // ↑ Extract third-party license comments to a separate file

              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.prod.ts"
                }
                // ↑ AT BUILD TIME: swap environment.ts with environment.prod.ts
                // This is how apiUrl changes between dev and prod!
              ]
            },

            // ─── DEVELOPMENT CONFIGURATION ───────────────────────────────
            "development": {
              "optimization": false,               // ← keep code readable for debugging
              "extractLicenses": false,
              "sourceMap": true,                   // ← enable source maps so browser DevTools shows TS
              "namedChunks": true,                 // ← chunk-home.js instead of random hash
              "outputHashing": "none",             // ← no hashing: main.js stays main.js
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.development.ts"
                }
              ]
            },

            // ─── STAGING CONFIGURATION (CUSTOM) ──────────────────────────
            "staging": {
              "optimization": true,                // ← same as prod for realistic testing
              "sourceMap": true,                   // ← but keep source maps for debugging
              "outputHashing": "all",
              "namedChunks": false,
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "600kB",        // ← slightly more lenient than prod
                  "maximumError": "1.2MB"
                }
              ],
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.staging.ts"
                }
              ]
            },

            // ─── UAT CONFIGURATION (CUSTOM) ──────────────────────────────
            "uat": {
              "optimization": true,
              "sourceMap": false,
              "outputHashing": "all",
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.uat.ts"
                }
              ]
            }
          },

          // ─── DEFAULT CONFIGURATION ─────────────────────────────────────
          "defaultConfiguration": "production"
          // ↑ ng build without --configuration uses this
        },

        // ─── SERVE TARGET (ng serve) ─────────────────────────────────────
        "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "configurations": {
            "production": {
              "buildTarget": "my-angular-app:build:production"
            },
            "development": {
              "buildTarget": "my-angular-app:build:development"
            },
            "staging": {
              "buildTarget": "my-angular-app:build:staging"
            }
          },
          "defaultConfiguration": "development"
        }
      }
    }
  }
}
```

**Running different configurations:**

```bash
# Production build (default)
ng build
ng build --configuration=production

# Development build
ng build --configuration=development

# Staging build (custom)
ng build --configuration=staging

# UAT build (custom)
ng build --configuration=uat

# Serve with staging config
ng serve --configuration=staging
```

### Development vs Production: Side-by-Side Comparison

| Setting | Development | Production |
|---------|-------------|------------|
| `optimization` | false | true |
| `sourceMap` | true | false (or hidden) |
| `outputHashing` | none | all |
| `namedChunks` | true | false |
| `extractLicenses` | false | true |
| `buildOptimizer` | false | true |
| Bundle size | Large (readable) | Small (minified) |
| Error messages | Detailed | Generic |
| Angular debug mode | On | Off |

### Common Gotcha: Budget Errors

```
Error: bundle initial exceeded maximum budget.
Budget 1048576 bytes.
Actual: 1231472 bytes.
```

This is a BUILD FAILURE from budget configuration. Solutions:

```json
// Option 1: Increase the budget (not ideal)
{
  "type": "initial",
  "maximumWarning": "1MB",
  "maximumError": "2MB"   // ← increase limit
}

// Option 2: Find and reduce what's bloating the bundle (BETTER)
// → Use bundle analysis (Section 21.4)
// → Use lazy loading for routes (Section 21.4)
// → Replace large libraries with smaller alternatives
```

---

## 21.4 Bundle Analysis & Optimization

### The Problem: Your App is 4MB — Why?

```
Before optimization:              After optimization:
  initial bundle: 3.8MB             initial bundle: 280KB
  Time to interactive: 12s          Time to interactive: 1.2s
  User retention: 40%               User retention: 85%
```

Bundle bloat is one of the most common Angular performance problems. You need tools to diagnose it.

### Setting Up source-map-explorer

```bash
# Install
npm install --save-dev source-map-explorer

# Build with source maps (required for analysis)
ng build --source-map=true

# Analyze the bundle
npx source-map-explorer dist/my-app/main.*.js
```

```json
// package.json — add a convenient script
{
  "scripts": {
    "analyze": "ng build --source-map=true && npx source-map-explorer dist/my-angular-app/browser/main.*.js"
    // ↑ Build with source maps THEN open the analyzer
    // source-map-explorer reads the .map files to map minified code
    // back to original source files and shows you what takes up space
  }
}
```

### Setting Up webpack-bundle-analyzer

```bash
# Install
npm install --save-dev webpack-bundle-analyzer

# Build with stats file (webpack only, not esbuild)
ng build --stats-json

# Run the analyzer
npx webpack-bundle-analyzer dist/my-angular-app/browser/stats.json
```

**This opens an interactive treemap in your browser** showing every module's size and relationship.

### Angular Budgets in Detail

```json
// angular.json budgets configuration with explanations
"budgets": [
  {
    "type": "initial",
    // ↑ The size of the initial page load bundles
    // (main.js + polyfills.js + styles.css) combined
    "maximumWarning": "500kB",    // ← yellow warning in build output
    "maximumError": "1MB"         // ← RED ERROR — build FAILS
  },
  {
    "type": "anyComponentStyle",
    // ↑ The size of any SINGLE component's style file
    // Good incentive to keep styles lean and scoped
    "maximumWarning": "2kB",
    "maximumError": "4kB"
  },
  {
    "type": "any",
    // ↑ Any single JS file (including lazy chunks)
    "maximumWarning": "1MB",
    "maximumError": "2MB"
  },
  {
    "type": "allScript",
    // ↑ TOTAL size of ALL scripts combined
    "maximumWarning": "2MB",
    "maximumError": "5MB"
  }
]
```

### Tree Shaking: The Magic Garbage Collector

**What is tree shaking?**

Tree shaking is the process of removing code that is never imported or used. The name comes from the metaphor: shake a tree, dead leaves (unused code) fall off.

```
Tree Shaking Visualized
═══════════════════════════════════════════════════════════════

  Your Code Imports:
    import { format } from 'date-fns';    ← only imports `format`

  date-fns library contains:
  ┌─────────────────────────────────────────────────────────┐
  │  format ✓  ← USED, kept in bundle                      │
  │  addDays ✗  ← NOT imported, removed by tree shaking    │
  │  subMonths ✗  ← NOT imported, removed                  │
  │  differenceInDays ✗  ← NOT imported, removed           │
  │  ... (200+ other functions) ✗  ← all removed           │
  └─────────────────────────────────────────────────────────┘

  Result: Only `format` ends up in your bundle!
```

**What PREVENTS tree shaking:**

```typescript
// BAD — importing the entire library (prevents tree shaking)
import * as _ from 'lodash';
// ↑ This imports ALL of lodash (~70KB) even if you use one function!
_.isEmpty(myArray);   // using only isEmpty

// GOOD — named import (enables tree shaking)
import { isEmpty } from 'lodash-es';
// ↑ Only imports `isEmpty` function (~1KB)
// Note: must use lodash-ES (ES modules), not plain lodash (CommonJS)

// BAD — side effect imports confuse tree shaker
import 'some-library/styles.css';   // ← this is fine (CSS)
import 'some-library/polyfill';     // ← this is a side effect

// BAD — CommonJS modules cannot be tree-shaken
const _ = require('lodash');  // ← require() = CommonJS = no tree shaking
```

**Side effects in package.json:**

```json
// package.json — telling bundlers about side effects
{
  "name": "my-library",
  "sideEffects": false
  // ↑ "Every file in this library is safe to tree-shake"
  // This is a PROMISE that importing a file has no side effects
  // (no global state changes, no DOM manipulation, no polyfills)
}

// OR — specify which files DO have side effects
{
  "sideEffects": [
    "*.css",          // ← CSS files are always side effects
    "src/polyfills.ts" // ← polyfills modify global objects
  ]
}
```

### Code Splitting Strategies

**Route-level code splitting (recommended — built into Angular):**

```typescript
// app-routing.module.ts (or app.routes.ts in standalone)
const routes: Routes = [
  {
    path: 'dashboard',
    loadChildren: () => import('./dashboard/dashboard.module').then(m => m.DashboardModule)
    // ↑ This creates a SEPARATE CHUNK for the dashboard
    // It is only downloaded when user navigates to /dashboard
    // chunk-DASHBOARD-HASH.js
  },
  {
    path: 'reports',
    loadComponent: () => import('./reports/reports.component').then(c => c.ReportsComponent)
    // ↑ Standalone component lazy loading (Angular 14+)
    // Creates chunk-REPORTS-HASH.js
  }
];

// Result in dist/:
// main.js         ← app shell (small - ~200KB)
// chunk-abc.js    ← dashboard (loaded on demand)
// chunk-def.js    ← reports (loaded on demand)
// Instead of:
// main.js         ← EVERYTHING (large - ~2MB)
```

**Component-level code splitting:**

```typescript
// Using Angular's defer block (Angular 17+)
@Component({
  template: `
    <app-header />

    @defer (on viewport) {
      <!-- ↑ Only load this when it enters the viewport -->
      <app-heavy-chart [data]="chartData" />
    } @placeholder {
      <div class="chart-placeholder">Loading chart...</div>
    }

    @defer (on interaction) {
      <!-- ↑ Only load when user clicks -->
      <app-comments [postId]="postId" />
    }
  `
})
export class ArticleComponent { }
```

### Differential Loading (Legacy — Angular < 13)

```
Differential Loading
═══════════════════════════════════════════════════════════════

  Angular used to build TWO versions of your app:

  Modern browsers (ES2015+):          Legacy browsers (ES5):
    main-es2015.abc.js                  main-es5.def.js
    (smaller, no transpilation)         (larger, transpiled with Babel)

  index.html served BOTH:
    <script type="module" src="main-es2015.abc.js">
    <!-- ↑ Modern browsers: use this (smaller) -->
    <script nomodule src="main-es5.def.js">
    <!-- ↑ Legacy browsers (IE11): use this -->

  Angular 13+: Dropped IE11 support → only build ES2015+
  This alone reduced bundle sizes by ~15-20%
```

### Full Example: Diagnosing and Fixing a Bloated Bundle

```
SCENARIO: Initial bundle is 2.1MB (over 1MB budget limit)
BUILD FAILS WITH: Error: bundle initial exceeded maximum budget
```

**Step 1: Generate source map and analyze**

```bash
ng build --source-map=true
npx source-map-explorer "dist/my-app/browser/main.*.js"
```

**Step 2: Identify culprits (hypothetical results)**

```
Hypothetical source-map-explorer output:
  node_modules/moment/moment.js        → 285KB  ← HUGE!
  node_modules/lodash/lodash.js        → 71KB   ← Tree shaking not working
  node_modules/chart.js/chart.js       → 200KB  ← Loaded eagerly (should be lazy)
  node_modules/rxjs/...                → 45KB   ← OK
  src/app/...                          → 180KB  ← OK
```

**Step 3: Fix each issue**

```typescript
// FIX 1: Replace moment.js with date-fns (tree-shakeable)
// BEFORE:
import moment from 'moment';                    // ← 285KB, always entire library
const formatted = moment(date).format('MM/DD/YYYY');

// AFTER:
import { format } from 'date-fns';              // ← ~1KB, only what we use
const formatted = format(date, 'MM/dd/yyyy');

// FIX 2: Fix lodash tree shaking
// BEFORE:
import * as _ from 'lodash';                   // ← 71KB entire lodash
_.isEmpty(arr);

// AFTER:
import { isEmpty } from 'lodash-es';           // ← ~1KB, tree-shakeable
isEmpty(arr);

// FIX 3: Lazy load chart module
// BEFORE (in routing):
{
  path: 'analytics',
  component: AnalyticsComponent              // ← chart.js loaded for ALL users on startup
}

// AFTER:
{
  path: 'analytics',
  loadComponent: () =>
    import('./analytics/analytics.component').then(c => c.AnalyticsComponent)
  // ↑ chart.js only loads for users who visit /analytics
}
```

**Step 4: Results**

```
BEFORE:  initial bundle = 2.1MB  ← BUILD FAILS
AFTER:   initial bundle = 290KB  ← Well under 500KB warning threshold

Savings:
  moment → date-fns:     -284KB
  lodash → lodash-es:    -70KB
  lazy chart.js:         -200KB
  Total savings:         -554KB
```

---

## 21.5 esbuild vs Webpack (Angular 17+)

### The Problem: Webpack is Slow

Webpack has powered Angular builds for years, but it has a fundamental limitation: it is single-threaded and written in JavaScript. For large projects, production builds can take 3-5 minutes. Hot Module Replacement (HMR) can take 5-10 seconds.

**Analogy:** Webpack is like a single chef doing everything — chopping, cooking, plating. esbuild is like a professional kitchen brigade where everything happens in parallel.

### Angular's Migration to esbuild

```
Angular Build Evolution
═══════════════════════════════════════════════════════════════

  Angular 2-16:  Webpack
                 @angular-devkit/build-angular:browser
                 JavaScript, single-threaded
                 Large project build: ~3-5 minutes

  Angular 16:    esbuild EXPERIMENTAL
                 @angular-devkit/build-angular:browser-esbuild

  Angular 17+:   esbuild DEFAULT (new projects)
                 @angular-devkit/build-angular:application
                 Written in Go, massively parallel
                 Same project build: ~20-30 seconds  (10x faster!)

  Angular 17+:   Vite for ng serve (dev server)
                 Uses esbuild for transforms
                 HMR: <200ms (was 5-10 seconds)
```

### Builder Configuration Comparison

```json
// angular.json — using esbuild (Angular 17+ DEFAULT for new projects)
{
  "architect": {
    "build": {
      "builder": "@angular-devkit/build-angular:application",
      //                                         ↑ "application" = esbuild
      "options": {
        "browser": "src/main.ts",              // ← note: "browser" not "main"
        "outputPath": "dist/my-app",
        // esbuild also puts files in a "browser" subfolder:
        // dist/my-app/browser/main.js
        "ssr": false                           // ← SSR support built-in (set true for SSR)
      }
    }
  }
}

// angular.json — using Webpack (legacy, pre-Angular 17 or migration path)
{
  "architect": {
    "build": {
      "builder": "@angular-devkit/build-angular:browser",
      //                                         ↑ "browser" = webpack
      "options": {
        "main": "src/main.ts",                 // ← note: "main" not "browser"
        "outputPath": "dist/my-app"
        // webpack puts files directly: dist/my-app/main.js
      }
    }
  }
}
```

### Performance Comparison

| Metric | Webpack (`browser`) | esbuild (`application`) |
|--------|--------------------|-----------------------|
| Initial build (large app) | 3-5 minutes | 15-30 seconds |
| Incremental rebuild | 5-10 seconds | <300ms |
| `ng serve` startup | 15-30 seconds | 2-5 seconds |
| HMR update | 5-10 seconds | 100-300ms |
| Bundle size output | Similar | Similar (slightly smaller) |
| Custom webpack config | Yes (webpack.config.js) | Limited |
| SSR support | Via Universal | Built-in (`ssr: true`) |

### When to Use Which

| Use Case | Recommendation |
|----------|---------------|
| New Angular 17+ project | `application` (esbuild) — default |
| Migrating Angular 16 and below | Start with `application`, test thoroughly |
| Need custom webpack plugins | `browser` (webpack) until esbuild supports it |
| SSR / Angular Universal | `application` (esbuild) — has built-in SSR |
| Third-party builders that need webpack | `browser` (webpack) |

**Migrating from webpack to esbuild:**

```bash
# Run Angular's migration schematic
ng update @angular/cli

# This may automatically update builder from "browser" to "application"
# Check angular.json after running

# Manual migration: in angular.json change:
#   "builder": "@angular-devkit/build-angular:browser"
# to:
#   "builder": "@angular-devkit/build-angular:application"
# AND rename "main" option to "browser"
```

---

## 21.6 Environment Configuration

### The Problem: Hard-Coded URLs

```typescript
// BAD — hard-coded production URL in development
export class ApiService {
  private baseUrl = 'https://api.myapp.com';  // ← breaks in development!
}
```

### The Environment File Pattern

```
Environment Files
═══════════════════════════════════════════════════════════════

  src/environments/
  ├── environment.ts              ← BASE file (imported in code)
  ├── environment.development.ts  ← DEV values (replaces base in dev build)
  ├── environment.staging.ts      ← STAGING values (replaces base in staging)
  ├── environment.uat.ts          ← UAT values
  └── environment.prod.ts         ← PROD values (replaces base in prod build)

  The Angular compiler performs fileReplacements at build time:
  ng build --configuration=production
    → src/environments/environment.ts
    → REPLACED BY src/environments/environment.prod.ts

  Your app code always imports from environment.ts — it never
  needs to know which environment it is in!
```

```typescript
// src/environments/environment.ts — BASE (used in app code imports)
export const environment = {
  production: false,            // ← always false in base file
  apiUrl: 'http://localhost:3000/api',  // ← local dev server
  featureFlags: {
    newDashboard: true,         // ← might enable experimental features in dev
    betaReports: true
  },
  logLevel: 'debug',            // ← verbose logging in development
  sentryDsn: ''                 // ← no error tracking in development
};

// src/environments/environment.prod.ts — PRODUCTION overrides
export const environment = {
  production: true,             // ← enables Angular's production mode
  apiUrl: 'https://api.myapp.com/api',  // ← real production API
  featureFlags: {
    newDashboard: true,
    betaReports: false          // ← beta features OFF in production
  },
  logLevel: 'error',            // ← only log errors in production
  sentryDsn: 'https://abc123@sentry.io/456'  // ← real error tracking DSN
};

// src/environments/environment.staging.ts — STAGING overrides
export const environment = {
  production: false,
  apiUrl: 'https://staging-api.myapp.com/api',  // ← staging API server
  featureFlags: {
    newDashboard: true,
    betaReports: true           // ← all features enabled for testing
  },
  logLevel: 'warn',
  sentryDsn: 'https://xyz789@sentry.io/staging-project'
};
```

```typescript
// Using the environment in your service — always import from environment.ts
import { environment } from '../environments/environment';
// ↑ At BUILD TIME this import is swapped to environment.prod.ts automatically
// Your code never changes — only the environment file changes!

@Injectable({ providedIn: 'root' })
export class ApiService {
  private http = inject(HttpClient);
  private baseUrl = environment.apiUrl;        // ← reads from current env

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.baseUrl}/users`);
    // Development:  GET http://localhost:3000/api/users
    // Production:   GET https://api.myapp.com/api/users
    // Same code — different URL — magic!
  }
}
```

### Runtime Configuration: When Build-Time Is Not Enough

**Problem with build-time environment files:** You need a separate build artifact for each environment. This violates the 12-factor app principle: "Build once, deploy anywhere."

**Solution: Load configuration at runtime from a JSON file.**

```
Runtime Configuration Pattern
═══════════════════════════════════════════════════════════════

  BUILD ONCE:
    ng build → dist/my-app/
                ├── main.js
                ├── index.html
                └── assets/
                    └── config.json  ← EMPTY PLACEHOLDER

  DEPLOY TO DEV:
    Replace config.json with development config
    { "apiUrl": "http://localhost:3000" }

  DEPLOY TO STAGING:
    Replace config.json with staging config
    { "apiUrl": "https://staging-api.myapp.com" }

  DEPLOY TO PROD:
    Replace config.json with production config
    { "apiUrl": "https://api.myapp.com" }

  SAME BUILD, DIFFERENT CONFIG — 12 Factor App!
```

**Full example: Runtime config with APP_INITIALIZER**

```typescript
// src/app/config/app-config.model.ts
export interface AppConfig {
  apiUrl: string;               // ← API base URL
  featureFlags: {
    newDashboard: boolean;
    betaReports: boolean;
  };
  logLevel: 'debug' | 'warn' | 'error';
  maxUploadSizeMB: number;
}
```

```typescript
// src/app/config/app-config.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { AppConfig } from './app-config.model';

@Injectable({ providedIn: 'root' })
export class AppConfigService {
  private config!: AppConfig;           // ← will be populated at startup
  private http = inject(HttpClient);

  // Called by APP_INITIALIZER BEFORE the app bootstraps
  load(): Promise<void> {
    return this.http
      .get<AppConfig>('/assets/config.json')
      // ↑ Fetches /assets/config.json from the server
      // This file can be different on each server!
      .toPromise()
      .then(config => {
        this.config = config!;           // ← store the loaded config
        console.log('AppConfig loaded:', this.config);
      })
      .catch(err => {
        console.error('Failed to load app config:', err);
        // ← If config fails to load, app cannot start
        // This is intentional — prevents running with wrong config
        throw err;
      });
  }

  // Getter methods so other services can read config
  getApiUrl(): string {
    return this.config.apiUrl;
  }

  getFeatureFlags(): AppConfig['featureFlags'] {
    return this.config.featureFlags;
  }

  isFeatureEnabled(feature: keyof AppConfig['featureFlags']): boolean {
    return this.config.featureFlags[feature];
  }
}
```

```typescript
// src/app/app.config.ts (standalone app config)
import { ApplicationConfig, APP_INITIALIZER } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { AppConfigService } from './config/app-config.service';
import { routes } from './app.routes';

// Factory function that returns the initializer function
function initializeApp(configService: AppConfigService) {
  return () => configService.load();
  // ↑ APP_INITIALIZER expects a function that returns a Promise or Observable
  // Angular will WAIT for this promise before bootstrapping
  // The app will show a blank page until config is loaded
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(),

    {
      provide: APP_INITIALIZER,
      useFactory: initializeApp,         // ← factory function
      deps: [AppConfigService],          // ← inject these into the factory
      multi: true                        // ← allows multiple APP_INITIALIZERs
      // ↑ multi: true means other libraries can also use APP_INITIALIZER
      // Angular waits for ALL of them to complete
    }
  ]
};
```

```json
// src/assets/config.json — development placeholder (committed to git)
{
  "apiUrl": "http://localhost:3000/api",
  "featureFlags": {
    "newDashboard": true,
    "betaReports": true
  },
  "logLevel": "debug",
  "maxUploadSizeMB": 50
}
```

```json
// assets/config.staging.json — staging config (NOT committed; injected by CI/CD)
{
  "apiUrl": "https://staging-api.myapp.com/api",
  "featureFlags": {
    "newDashboard": true,
    "betaReports": false
  },
  "logLevel": "warn",
  "maxUploadSizeMB": 25
}
```

### 12-Factor App Principles Applied to Angular

| Factor | Angular Application |
|--------|---------------------|
| **I. Codebase** | One repo, many environments via config |
| **II. Dependencies** | Declared in package.json |
| **III. Config** | Stored in environment files OR runtime config.json |
| **IV. Backing services** | API URLs configurable, not hard-coded |
| **V. Build, release, run** | `ng build` → artifact → deploy to env |
| **VI. Processes** | Stateless — no server-side sessions |
| **VII. Port binding** | Dev server on port 4200, configurable |
| **VIII. Concurrency** | Scale by adding CDN nodes |
| **IX. Disposability** | Static files — fast start, graceful shutdown |
| **X. Dev/prod parity** | Runtime config makes environments identical |
| **XI. Logs** | Structured logs, configurable log level |
| **XII. Admin processes** | Build scripts in package.json |

---

## 21.7 Progressive Web Apps (PWA)

### What Is a PWA?

A Progressive Web App is a web application that uses modern web APIs to deliver app-like experiences. Key capabilities:

```
PWA Capabilities
═══════════════════════════════════════════════════════════════

  Regular Web App:              PWA (Progressive Web App):
  ────────────────              ────────────────────────────
  ✗ No offline support          ✓ Works offline (service worker)
  ✗ No install prompt           ✓ "Add to Home Screen" / installable
  ✗ No push notifications       ✓ Push notifications
  ✗ No background sync          ✓ Background data sync
  ✗ Slow on slow networks       ✓ Cache-first, fast on slow networks
  ✗ No splash screen            ✓ Native-like splash screen
  ✓ Works in browser            ✓ Works in browser AND installed
```

**Analogy:** A PWA is like a web app that went to the gym and got superpowers. It looks like a web app, but it can do things previously only native apps could do.

### Adding PWA Support to Angular

```bash
# Add PWA support (installs service worker + config)
ng add @angular/pwa

# This command:
#   1. Installs @angular/service-worker
#   2. Creates ngsw-config.json (service worker config)
#   3. Creates src/manifest.webmanifest (installability config)
#   4. Adds <link rel="manifest"> to index.html
#   5. Registers service worker in app.config.ts
#   6. Modifies angular.json to copy ngsw-config.json to dist
```

### Service Worker Configuration (ngsw-config.json)

```json
// ngsw-config.json — the service worker's instruction manual
{
  "$schema": "./node_modules/@angular/service-worker/config/schema.json",

  "index": "/index.html",
  // ↑ The main HTML file (served for all navigation requests)

  "assetGroups": [
    // ↑ Static assets: cache these files (they change with app versions)

    {
      "name": "app",
      // ↑ Name for this group (arbitrary, for your reference)

      "installMode": "prefetch",
      // ↑ PREFETCH: Download and cache these when SW installs
      // These are CRITICAL files — cache immediately on first visit

      "resources": {
        "files": [
          "/favicon.ico",
          "/index.html",
          "/manifest.webmanifest",
          "/*.css",            // ← all CSS files
          "/*.js"              // ← all JS files (main bundle)
        ]
      }
    },

    {
      "name": "assets",

      "installMode": "lazy",
      // ↑ LAZY: Only cache when first requested by the app
      // These are secondary assets — cache on demand

      "updateMode": "prefetch",
      // ↑ But when a new SW version arrives, prefetch updates immediately

      "resources": {
        "files": [
          "/assets/**",             // ← images, fonts, icons
          "/*.(svg|cur|jpg|jpeg|png|apng|webp|avif|gif|otf|ttf|woff|woff2)"
        ]
      }
    }
  ],

  "dataGroups": [
    // ↑ API data: cache strategies for HTTP requests

    {
      "name": "api-performance",
      // ↑ For API calls where slightly stale data is OK (news, lists)

      "urls": ["/api/news/**", "/api/articles/**"],

      "cacheConfig": {
        "strategy": "performance",
        // ↑ PERFORMANCE (cache-first):
        //   1. Check cache first — return immediately if cached
        //   2. Fetch from network in background
        //   3. Update cache for next request
        //   Good for: data that doesn't change often

        "maxSize": 100,             // ← max 100 cached responses
        "maxAge": "1d",             // ← cached response expires after 1 day
        "timeout": "10s"            // ← fallback to cache if network > 10 seconds
      }
    },

    {
      "name": "api-freshness",
      // ↑ For API calls where fresh data is CRITICAL (user profile, transactions)

      "urls": ["/api/user/**", "/api/transactions/**"],

      "cacheConfig": {
        "strategy": "freshness",
        // ↑ FRESHNESS (network-first):
        //   1. Try network first (fresh data)
        //   2. If network fails/times out → use cache
        //   3. If no cache → error
        //   Good for: user data, financial data

        "maxSize": 20,
        "maxAge": "1h",             // ← cached fallback expires after 1 hour
        "timeout": "5s"             // ← if network doesn't respond in 5s, use cache
      }
    }
  ]
}
```

### Caching Strategy Decision Guide

```
Which caching strategy to choose?
═══════════════════════════════════════════════════════════════

  START
    │
    ▼
  Is stale data dangerous?
    │
    ├── YES (financial, medical, user-specific)
    │         → Use FRESHNESS (network-first)
    │           Tolerates short outages, but always tries network first
    │
    └── NO (news, products, articles)
              ▼
          How often does data change?
              │
              ├── Rarely (hours/days)
              │         → Use PERFORMANCE (cache-first)
              │           Fastest user experience
              │
              └── Frequently (minutes)
                        → Use FRESHNESS with short maxAge
                          or skip caching entirely
```

### SwUpdate Service: Handling App Updates

When you deploy a new version, users with the old app cached need to get the update. SwUpdate handles this.

```typescript
// src/app/core/pwa-update.service.ts
import { Injectable, inject } from '@angular/core';
import { SwUpdate, VersionReadyEvent } from '@angular/service-worker';
import { filter, map } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class PwaUpdateService {
  private swUpdate = inject(SwUpdate);

  initializeUpdateCheck(): void {
    // Only run if service worker is enabled
    // (not in development where SW is usually disabled)
    if (!this.swUpdate.isEnabled) {
      console.log('Service Worker is disabled (development mode)');
      return;
    }

    // Listen for "version ready" events
    this.swUpdate.versionUpdates
      .pipe(
        filter((event): event is VersionReadyEvent =>
          event.type === 'VERSION_READY'
          // ↑ Filter to only 'VERSION_READY' events
          // (other events: VERSION_DETECTED, VERSION_INSTALLATION_FAILED)
        ),
        map(event => ({
          current: event.currentVersion,
          available: event.latestVersion
        }))
      )
      .subscribe(({ current, available }) => {
        console.log(`New version available!
          Current: ${current.hash}
          Available: ${available.hash}`);

        // Ask user if they want to update
        const updateConfirmed = confirm(
          'A new version of this application is available. Reload to update?'
        );

        if (updateConfirmed) {
          // Activate the new version and reload
          this.swUpdate.activateUpdate().then(() => {
            document.location.reload();
            // ↑ Reload the page to use the new version
          });
        }
      });

    // Periodically check for updates (every 6 hours)
    setInterval(() => {
      this.swUpdate.checkForUpdate().then(updateFound => {
        if (updateFound) {
          console.log('Update check found a new version!');
        }
      });
    }, 6 * 60 * 60 * 1000);  // ← 6 hours in milliseconds
  }
}
```

```typescript
// src/app/app.component.ts — initialize update checking on startup
import { Component, OnInit, inject } from '@angular/core';
import { PwaUpdateService } from './core/pwa-update.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {
  private pwaUpdateService = inject(PwaUpdateService);

  ngOnInit(): void {
    this.pwaUpdateService.initializeUpdateCheck();
    // ↑ Start checking for updates as soon as app loads
  }
}
```

### SwPush Service: Push Notifications

```typescript
// src/app/notifications/push-notification.service.ts
import { Injectable, inject } from '@angular/core';
import { SwPush } from '@angular/service-worker';
import { HttpClient } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class PushNotificationService {
  private swPush = inject(SwPush);
  private http = inject(HttpClient);

  // VAPID public key (get from your push notification server)
  private readonly VAPID_PUBLIC_KEY = 'YOUR_VAPID_PUBLIC_KEY_HERE';

  subscribeToNotifications(): void {
    // Request permission and get push subscription
    this.swPush.requestSubscription({
      serverPublicKey: this.VAPID_PUBLIC_KEY
      // ↑ This triggers the browser's "Allow notifications" prompt
    })
    .then(subscription => {
      console.log('User subscribed to push notifications');

      // Send the subscription to your server
      this.http.post('/api/notifications/subscribe', subscription)
        .subscribe({
          next: () => console.log('Subscription saved to server'),
          error: err => console.error('Failed to save subscription', err)
        });
    })
    .catch(err => {
      console.error('Push subscription failed:', err);
      // User denied permission, or browser doesn't support it
    });

    // Listen for incoming push messages
    this.swPush.messages.subscribe(message => {
      console.log('Received push message:', message);
    });

    // Listen for notification clicks
    this.swPush.notificationClicks.subscribe(({ action, notification }) => {
      console.log(`Notification clicked: ${notification.title}, action: ${action}`);
      // Navigate to relevant page based on notification data
      window.open(notification.data?.url || '/', '_blank');
    });
  }
}
```

### Web App Manifest

```json
// src/manifest.webmanifest — makes the app installable
{
  "name": "My Angular App",
  // ↑ Full name shown in install dialogs and splash screen

  "short_name": "AngularApp",
  // ↑ Short name for home screen icon (keep under 12 chars)

  "theme_color": "#1976d2",
  // ↑ Color of the browser chrome when app is open (must match meta tag in index.html)

  "background_color": "#fafafa",
  // ↑ Color shown on splash screen while app loads

  "display": "standalone",
  // ↑ HOW it appears when installed:
  //   standalone: looks like native app (no browser chrome)
  //   minimal-ui: browser with minimal controls
  //   fullscreen: completely fullscreen
  //   browser: regular browser tab (no install behavior)

  "scope": "/",
  // ↑ Which URLs are "inside" this PWA
  // Navigation outside this scope opens in browser

  "start_url": "/",
  // ↑ Which URL opens when launching from home screen
  // Add analytics: "start_url": "/?utm_source=homescreen"

  "icons": [
    {
      "src": "assets/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png",
      "purpose": "maskable any"
      // ↑ purpose "maskable" allows icon to be cropped to shape by Android
    },
    {
      "src": "assets/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "assets/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable any"
    },
    {
      "src": "assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable any"
    }
  ]
}
```

---

## 21.8 Docker for Angular

### Why Docker?

**Analogy:** Shipping containers revolutionized global trade. Before containers, cargo was loaded piece by piece — slow and inconsistent. After containers, the same container goes on a ship, truck, or train without repacking. Docker does the same for software.

Without Docker: "It works on my Mac but not on the Linux server."
With Docker: "It runs in a container — the same container everywhere."

### Multi-Stage Dockerfile

The key insight: **you need Node.js to BUILD Angular, but you only need Nginx to SERVE it.** A multi-stage build uses Node for building and Nginx for serving — the final image is small and has no unnecessary build tools.

```
Multi-Stage Docker Build
═══════════════════════════════════════════════════════════════

  Stage 1: Builder              Stage 2: Server
  ─────────────────             ─────────────────
  node:20-alpine                nginx:alpine
  npm install                   ONLY contains:
  ng build                        ├── dist/my-app/*  (copied from Stage 1)
                                   └── nginx config
  This stage is DISCARDED
  after build completes
  (no node_modules in final image!)

  Stage 1 size: ~800MB          Stage 2 size: ~25MB
```

```dockerfile
# Dockerfile — full multi-stage Angular Docker build

# ═══════════════════════════════════════════════════════════════
# STAGE 1: Build the Angular application
# ═══════════════════════════════════════════════════════════════
FROM node:20-alpine AS builder
# ↑ Use Node.js 20 on Alpine Linux (lightweight ~40MB base)
# "AS builder" names this stage so we can reference it later
# Alpine is a minimal Linux distro — keeps image small

WORKDIR /app
# ↑ Set the working directory inside the container
# All subsequent commands run from /app

# Copy ONLY package files first (for Docker layer caching)
COPY package*.json ./
# ↑ IMPORTANT: Copy package.json and package-lock.json BEFORE source code
# Docker caches each layer. If package.json hasn't changed,
# Docker reuses the cached npm install layer — saves 2-5 minutes per build!
# Only if package.json changes does npm install run again.

RUN npm ci --only=production
# ↑ npm ci: clean install (uses package-lock.json exactly)
# --only=production: skip devDependencies? Actually WRONG for Angular build
# We need devDependencies for ng build...
# Better: npm ci (no --only=production flag)

# NOTE: Actually for Angular we need ALL dependencies including devDependencies
# because @angular/cli is a devDependency
RUN npm ci
# ↑ Use package-lock.json for deterministic installs
# 'ci' stands for 'clean install' — always installs exact locked versions

# Now copy the rest of the source code
COPY . .
# ↑ Copy everything: src/, angular.json, tsconfig.json, etc.
# This is done AFTER npm ci so changing source doesn't invalidate npm cache

# Build the Angular app for production
RUN npm run build -- --configuration=production
# ↑ Runs 'ng build --configuration=production'
# Output goes to dist/my-angular-app/browser/ (esbuild)
# or dist/my-angular-app/ (webpack)

# ═══════════════════════════════════════════════════════════════
# STAGE 2: Serve with Nginx
# ═══════════════════════════════════════════════════════════════
FROM nginx:alpine AS server
# ↑ Start fresh with just Nginx — NO Node.js, NO node_modules
# This final image will be ~25MB vs ~800MB for the builder stage

# Remove default Nginx config (we provide our own)
RUN rm /etc/nginx/conf.d/default.conf
# ↑ Nginx's default config serves from /usr/share/nginx/html
# We replace it with our SPA-aware configuration

# Copy our custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/
# ↑ Nginx reads .conf files from /etc/nginx/conf.d/
# Our nginx.conf handles Angular SPA routing (see below)

# Copy the Angular build output from the builder stage
COPY --from=builder /app/dist/my-angular-app/browser /usr/share/nginx/html
# ↑ --from=builder: reference the "builder" stage
# Copy dist output → into Nginx's web root
# Note: esbuild output is in /browser/ subdirectory
# For webpack builder, remove /browser: /app/dist/my-angular-app

EXPOSE 80
# ↑ Document that this container listens on port 80
# This is documentation only — doesn't actually open the port
# You open the port with -p flag in docker run

# Nginx starts automatically as the container's CMD
# (defined in the official nginx image)
```

### Nginx Configuration for Angular SPA

```nginx
# nginx.conf — proper Nginx config for Angular Single Page Applications

server {
    listen 80;
    # ↑ Listen on port 80 (HTTP)

    server_name localhost;
    # ↑ In production, replace with your domain: myapp.com

    root /usr/share/nginx/html;
    # ↑ Serve files from this directory
    # (Where we copied Angular's dist output in Dockerfile)

    index index.html;
    # ↑ Default file to serve when accessing a directory

    # ─── Gzip Compression ───────────────────────────────────────
    gzip on;
    # ↑ Enable gzip compression — reduces transfer size by ~70%!

    gzip_types
        text/plain
        text/css
        text/javascript
        application/javascript
        application/json
        application/xml
        image/svg+xml;
    # ↑ Compress these MIME types
    # Binary formats (images, fonts) are already compressed

    gzip_min_length 1024;
    # ↑ Only compress files larger than 1KB
    # (tiny files: compression overhead > savings)

    # ─── Caching for Static Assets ──────────────────────────────
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        # ↑ Match static asset file extensions (regex)
        expires 1y;
        # ↑ Set Cache-Control: max-age=31536000 (1 year!)
        # Angular uses content hashing (main.abc123.js)
        # so old URLs become invalid when content changes
        # This aggressive caching is SAFE with hashed filenames

        add_header Cache-Control "public, immutable";
        # ↑ "immutable" tells the browser to NEVER revalidate
        # (since hashed filename guarantees freshness)
    }

    # ─── No Cache for index.html ────────────────────────────────
    location = /index.html {
        # ↑ = means EXACT match for /index.html
        expires -1;
        # ↑ Disable caching for index.html
        # Why? index.html has the script tags pointing to hashed filenames
        # If we cached index.html, users would get old script tags after deploy!

        add_header Cache-Control "no-cache, no-store, must-revalidate";
        # ↑ Always fetch fresh index.html from server
    }

    # ─── Angular SPA Routing ────────────────────────────────────
    location / {
        try_files $uri $uri/ /index.html;
        # ↑ This is THE CRITICAL SETTING for Angular SPA!
        #
        # When user navigates to /dashboard/reports:
        #   1. $uri: try /usr/share/nginx/html/dashboard/reports (file)
        #   2. $uri/: try /usr/share/nginx/html/dashboard/reports/ (directory)
        #   3. /index.html: file not found → serve index.html
        #
        # Step 3 is what makes Angular routing work!
        # Without this: Nginx returns 404 for /dashboard/reports
        # With this: Angular receives the URL and handles routing itself
    }

    # ─── Security Headers ───────────────────────────────────────
    add_header X-Frame-Options "SAMEORIGIN";
    # ↑ Prevents clickjacking (embedding in iframes on other sites)

    add_header X-Content-Type-Options "nosniff";
    # ↑ Prevents browsers from guessing MIME type
    # (security: prevents executing scripts disguised as images)

    add_header X-XSS-Protection "1; mode=block";
    # ↑ Legacy XSS protection for older browsers

    add_header Referrer-Policy "strict-origin-when-cross-origin";
    # ↑ Controls how much referrer info is sent with requests
}
```

### Docker Compose for Local Development

```yaml
# docker-compose.yml — local development environment

version: '3.8'

services:

  # ─── Angular Frontend ────────────────────────────────────────
  frontend:
    build:
      context: .                    # ← build from current directory
      dockerfile: Dockerfile        # ← use our Dockerfile
      target: server                # ← only build up to "server" stage
    ports:
      - "4200:80"                   # ← map host port 4200 to container port 80
      # access at http://localhost:4200
    depends_on:
      - api                         # ← start api before frontend
    environment:
      - NGINX_HOST=localhost        # ← nginx environment variable

  # ─── Backend API ─────────────────────────────────────────────
  api:
    image: node:20-alpine           # ← use pre-built Node.js image
    working_dir: /app
    volumes:
      - ./api:/app                  # ← mount local api folder into container
      - /app/node_modules           # ← exclude node_modules from mount
    command: npm run dev            # ← run development server
    ports:
      - "3000:3000"                 # ← access API at http://localhost:3000

  # ─── Database ────────────────────────────────────────────────
  db:
    image: postgres:15-alpine       # ← PostgreSQL database
    environment:
      POSTGRES_DB: myapp            # ← database name
      POSTGRES_USER: admin          # ← database user
      POSTGRES_PASSWORD: password   # ← NEVER do this in production! Use secrets
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data  # ← persist data between restarts

volumes:
  postgres_data:                    # ← named volume for database persistence
```

**Docker commands:**

```bash
# Build the Docker image
docker build -t my-angular-app:latest .

# Run the container
docker run -p 4200:80 my-angular-app:latest
# → access at http://localhost:4200

# Docker Compose — start all services
docker-compose up --build

# Stop all services
docker-compose down

# Stop and remove volumes (fresh database)
docker-compose down -v
```

---

## 21.9 CI/CD Pipelines

### What is CI/CD?

```
CI/CD Pipeline Explained
═══════════════════════════════════════════════════════════════

  CONTINUOUS INTEGRATION (CI):       CONTINUOUS DELIVERY (CD):
  ────────────────────────────       ──────────────────────────
  Developer pushes code              On successful CI:
       │                                  │
       ▼                                  ▼
  Automated checks run:              Build production artifact
    ✓ Code linting                        │
    ✓ Unit tests                          ▼
    ✓ E2E tests                      Deploy to staging
    ✓ Build verification                  │
    ✓ Security scanning                   ▼
                                     (Optionally) Deploy to prod

  Goal: Catch bugs BEFORE            Goal: Always have deployable
  they reach production              software ready

  Traditional: "Works on my         CI/CD: "Broken? The pipeline
  machine" + big bang deployments    told me in 5 minutes"
```

### 21.9.1 GitHub Actions

GitHub Actions is free for public repos and very affordable for private repos. YAML-based workflow files live in `.github/workflows/`.

```yaml
# .github/workflows/ci.yml — Full CI/CD pipeline for Angular

name: Angular CI/CD
# ↑ The name shown in GitHub's "Actions" tab

on:
  # ↑ Trigger conditions
  push:
    branches:
      - main          # ← Run on every push to main
      - develop       # ← Run on pushes to develop branch
  pull_request:
    branches:
      - main          # ← Run on every PR targeting main
      - develop

env:
  # ↑ Environment variables available to ALL jobs
  NODE_VERSION: '20'              # ← Node.js version to use
  ANGULAR_CLI_VERSION: '17'      # ← Angular CLI version

jobs:

  # ───────────────────────────────────────────────────────────
  # JOB 1: Lint (fast check — runs in parallel with test)
  # ───────────────────────────────────────────────────────────
  lint:
    name: Lint
    runs-on: ubuntu-latest        # ← Use GitHub's Ubuntu runner (free)

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        # ↑ Official action: clones your repository

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}   # ← use env variable
          cache: 'npm'
          # ↑ Cache npm packages between runs
          # GitHub stores ~/.npm cache keyed by package-lock.json hash
          # MASSIVE time savings — avoids re-downloading packages

      - name: Install dependencies
        run: npm ci
        # ↑ npm ci: clean install using package-lock.json
        # Faster than npm install, reproducible, safe for CI

      - name: Run ESLint
        run: npm run lint
        # ↑ Runs: ng lint
        # Catches: unused imports, any types, style violations
        # If lint fails → job fails → PR shows red X → merge blocked

  # ───────────────────────────────────────────────────────────
  # JOB 2: Test (unit tests with coverage)
  # ───────────────────────────────────────────────────────────
  test:
    name: Unit Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run unit tests
        run: npm run test:ci
        # ↑ Runs: ng test --watch=false --browsers=ChromeHeadless --code-coverage
        # --watch=false: don't watch for changes (one-time run)
        # --browsers=ChromeHeadless: run Chrome without UI (server has no display)
        # --code-coverage: generate coverage report

      - name: Upload coverage report
        uses: codecov/codecov-action@v3
        # ↑ Optional: upload coverage to codecov.io
        # Adds coverage badge to your README
        with:
          file: ./coverage/my-angular-app/lcov.info
          fail_ci_if_error: false    # ← don't fail if codecov is down

  # ───────────────────────────────────────────────────────────
  # JOB 3: Build (runs after lint and test pass)
  # ───────────────────────────────────────────────────────────
  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, test]
    # ↑ Only run build if BOTH lint and test succeed
    # This prevents wasting build time on bad code

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build production bundle
        run: npm run build -- --configuration=production
        # ↑ ng build --configuration=production
        # Fails if budget limits exceeded, type errors found

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        # ↑ Save the dist/ folder so the deploy job can use it
        with:
          name: angular-dist
          path: dist/
          # ↑ Upload the entire dist/ directory as "angular-dist" artifact
          retention-days: 7        # ← Keep artifact for 7 days

  # ───────────────────────────────────────────────────────────
  # JOB 4: Docker Build & Push (only on main branch)
  # ───────────────────────────────────────────────────────────
  docker:
    name: Docker Build & Push
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    # ↑ ONLY run on pushes to main branch (not on PRs)
    # PRs get lint+test+build but NOT deployed

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        # ↑ Enables advanced Docker build features (multi-platform, cache)

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_HUB_USERNAME }}
          password: ${{ secrets.DOCKER_HUB_TOKEN }}
          # ↑ ${{ secrets.XXX }} reads from GitHub repository secrets
          # Set these in: Repository → Settings → Secrets and variables → Actions

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true               # ← Actually push to registry
          tags: |
            myuser/my-angular-app:latest
            myuser/my-angular-app:${{ github.sha }}
          # ↑ Tag with both "latest" and the git commit SHA
          # myuser/my-angular-app:abc1234 allows rollback to specific commit
          cache-from: type=gha    # ← Use GitHub Actions cache for Docker layers
          cache-to: type=gha,mode=max

  # ───────────────────────────────────────────────────────────
  # JOB 5: Deploy to Firebase (only on main branch)
  # ───────────────────────────────────────────────────────────
  deploy:
    name: Deploy to Firebase
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    environment:
      name: production             # ← GitHub environment (with protection rules)
      url: 'https://my-angular-app.web.app'

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download build artifact
        uses: actions/download-artifact@v4
        # ↑ Download the dist/ folder from the build job
        with:
          name: angular-dist
          path: dist/

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}        # ← built-in token
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live          # ← deploy to production (not preview channel)
          projectId: my-firebase-project
```

**Package.json scripts for CI:**

```json
// package.json
{
  "scripts": {
    "test:ci": "ng test --watch=false --browsers=ChromeHeadless --code-coverage",
    // ↑ Headless Chrome for CI environments (no display available)
    "build:prod": "ng build --configuration=production",
    "lint": "ng lint",
    "analyze": "ng build --source-map=true && npx source-map-explorer dist/**/*.js"
  }
}
```

### 21.9.2 Azure DevOps

```yaml
# azure-pipelines.yml — Angular CI/CD for Azure DevOps

trigger:
  branches:
    include:
      - main           # ← trigger on pushes to main
      - develop        # ← trigger on pushes to develop
  paths:
    exclude:
      - '*.md'         # ← don't trigger on README changes
      - docs/**        # ← don't trigger on doc changes

pool:
  vmImage: 'ubuntu-latest'
  # ↑ Use Microsoft-hosted Ubuntu agent
  # Alternatives: 'windows-latest', 'macOS-latest'

variables:
  nodeVersion: '20.x'           # ← Node.js version
  angularProject: 'my-angular-app'

stages:

  # ─── STAGE 1: Validate ───────────────────────────────────────
  - stage: Validate
    displayName: 'Validate Code'
    jobs:
      - job: LintAndTest
        displayName: 'Lint & Test'
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)
            displayName: 'Install Node.js'
            # ↑ Azure DevOps task to install Node.js

          - task: Cache@2
            inputs:
              key: 'npm | "$(Agent.OS)" | package-lock.json'
              restoreKeys: |
                npm | "$(Agent.OS)"
              path: $(npm_config_cache)
            displayName: 'Cache npm packages'
            # ↑ Azure DevOps cache task — similar to GitHub Actions cache

          - script: npm ci
            displayName: 'Install dependencies'

          - script: npm run lint
            displayName: 'Run ESLint'

          - script: npm run test:ci
            displayName: 'Run unit tests'

          - task: PublishTestResults@2
            condition: always()
            # ↑ Publish test results even if tests fail
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles: 'test-results/results.xml'
            displayName: 'Publish test results'

          - task: PublishCodeCoverageResults@1
            inputs:
              codeCoverageTool: 'Cobertura'
              summaryFileLocation: 'coverage/my-angular-app/cobertura-coverage.xml'
            displayName: 'Publish coverage report'

  # ─── STAGE 2: Build ──────────────────────────────────────────
  - stage: Build
    displayName: 'Build Application'
    dependsOn: Validate          # ← only if Validate stage succeeded
    condition: succeeded()
    jobs:
      - job: BuildProduction
        displayName: 'Build Production Bundle'
        steps:
          - task: NodeTool@0
            inputs:
              versionSpec: $(nodeVersion)

          - script: npm ci
            displayName: 'Install dependencies'

          - script: npm run build:prod
            displayName: 'Build for production'

          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: 'dist/'
              ArtifactName: 'angular-dist'
              # ↑ Publish dist/ as pipeline artifact for deploy stage
            displayName: 'Publish build artifact'

  # ─── STAGE 3: Deploy to Azure App Service ────────────────────
  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    # ↑ Only deploy if Build succeeded AND we're on main branch

    jobs:
      - deployment: DeployWebApp
        displayName: 'Deploy to Azure App Service'
        environment: 'production'  # ← Azure DevOps environment (with approvals)
        strategy:
          runOnce:
            deploy:
              steps:
                - task: DownloadBuildArtifacts@1
                  inputs:
                    buildType: 'current'
                    artifactName: 'angular-dist'
                  displayName: 'Download build artifact'

                - task: AzureWebApp@1
                  inputs:
                    azureSubscription: 'My Azure Subscription'  # ← service connection
                    appName: 'my-angular-app'
                    package: '$(System.ArtifactsDirectory)/angular-dist'
                  displayName: 'Deploy to Azure App Service'
```

### 21.9.3 GitLab CI

```yaml
# .gitlab-ci.yml — Angular CI/CD for GitLab

stages:
  - install
  - validate
  - build
  - deploy

variables:
  NODE_VERSION: "20"
  # ↑ Variables available to all jobs

cache:
  key:
    files:
      - package-lock.json       # ← cache key based on lock file content
  paths:
    - node_modules/             # ← what to cache
  # ↑ GitLab CI cache: reuses node_modules if package-lock.json unchanged

install-deps:
  stage: install
  image: node:20-alpine         # ← Docker image to use for this job
  script:
    - npm ci
  artifacts:
    paths:
      - node_modules/           # ← pass node_modules to later stages
    expire_in: 1 hour

lint:
  stage: validate
  image: node:20-alpine
  needs: [install-deps]         # ← wait for install-deps job
  script:
    - npm run lint

test:
  stage: validate
  image: node:20-alpine
  needs: [install-deps]
  services:
    - name: browserless/chrome  # ← headless Chrome as a service
      alias: chrome
  script:
    - npm run test:ci
  coverage: '/Lines\s*:\s*(\d+(?:\.\d+)?)%/'  # ← regex to extract coverage %
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build-production:
  stage: build
  image: node:20-alpine
  needs: [lint, test]
  script:
    - npm run build:prod
  artifacts:
    paths:
      - dist/                   # ← keep dist/ for deploy stage
    expire_in: 1 week
  only:
    - main                      # ← only build on main branch

deploy-firebase:
  stage: deploy
  image: node:20-alpine
  needs: [build-production]
  script:
    - npm install -g firebase-tools
    - firebase deploy --only hosting --token "$FIREBASE_TOKEN"
    # ↑ $FIREBASE_TOKEN set in GitLab → Settings → CI/CD → Variables
  environment:
    name: production
    url: https://my-app.web.app
  only:
    - main
```

---

## 21.10 Deployment Targets

### Firebase Hosting

Firebase Hosting is Google's CDN-backed static file hosting. Excellent for Angular apps.

```bash
# Step 1: Install Firebase CLI
npm install -g firebase-tools

# Step 2: Login
firebase login

# Step 3: Add Firebase to your Angular project
ng add @angular/fire
# ↑ Installs @angular/fire, creates .firebaserc and firebase.json
# Prompts you to select your Firebase project

# Step 4: Initialize (if not using ng add)
firebase init hosting
# Prompts:
#   ? What do you want to use as your public directory? dist/my-angular-app/browser
#   ? Configure as a single-page app? YES (adds rewrite rules)
#   ? Set up automatic builds? No (we handle that in CI/CD)

# Step 5: Build and Deploy
ng build --configuration=production
firebase deploy

# Step 6: Preview channels for PR previews
firebase hosting:channel:deploy pr-123
# ↑ Creates a temporary URL: https://my-app--pr-123-abc123.web.app
# Perfect for reviewing PR changes before merging
```

```json
// firebase.json — Firebase Hosting configuration
{
  "hosting": {
    "public": "dist/my-angular-app/browser",
    // ↑ The directory to deploy (esbuild output)

    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    // ↑ Files to exclude from deployment

    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
        // ↑ CRITICAL: Rewrite all URLs to index.html
        // This is Firebase's equivalent of Nginx try_files
        // Without this, refreshing /dashboard gives 404
      }
    ],

    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000, immutable"
            // ↑ 1 year cache for hashed JS/CSS files
          }
        ]
      },
      {
        "source": "**",
        "headers": [
          {
            "key": "X-Frame-Options",
            "value": "SAMEORIGIN"
          },
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          }
        ]
      }
    ]
  }
}
```

### Vercel

Vercel is the easiest deployment platform — push code, get a URL.

```json
// vercel.json — Vercel deployment configuration
{
  "buildCommand": "ng build --configuration=production",
  // ↑ How to build the Angular app

  "outputDirectory": "dist/my-angular-app/browser",
  // ↑ Where the built files are (esbuild output directory)

  "installCommand": "npm ci",
  // ↑ How to install dependencies

  "framework": "angular",
  // ↑ Tell Vercel this is Angular (enables Angular-specific optimizations)

  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
      // ↑ SPA routing: all paths → index.html
    }
  ],

  "headers": [
    {
      "source": "/(.*).js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/(.*).css",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/index.html",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "no-cache"
          // ↑ Never cache index.html
        }
      ]
    }
  ]
}
```

```bash
# Deploy to Vercel
npm install -g vercel

# Login
vercel login

# Deploy (from project directory)
vercel
# → Prompts for project settings on first run

# Deploy to production
vercel --prod

# The CLI gives you a URL immediately: https://my-app-abc123.vercel.app
```

### Netlify

```toml
# netlify.toml — Netlify deployment configuration

[build]
  command = "ng build --configuration=production"
  # ↑ Build command to run

  publish = "dist/my-angular-app/browser"
  # ↑ Directory to serve (esbuild output)

[build.environment]
  NODE_VERSION = "20"
  # ↑ Node.js version for the build environment

# ─── Redirect rules for SPA routing ───────────────────────────
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
  # ↑ status 200 = "rewrite" (not redirect)
  # All URLs serve index.html but keep the original URL
  # This is Netlify's equivalent of Nginx try_files

# ─── Custom headers ────────────────────────────────────────────
[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/index.html"
  [headers.values]
    Cache-Control = "no-cache"

# ─── Deploy previews for PRs ──────────────────────────────────
[context.deploy-preview]
  command = "ng build --configuration=staging"
  # ↑ PRs get built with staging config (not production)

[context.branch-deploy]
  command = "ng build --configuration=staging"
```

Alternatively, create a `_redirects` file in `src/`:

```
# src/_redirects — simple Netlify redirect rules (copy to dist via angular.json assets)
/*  /index.html  200
# ↑ One line: all URLs → index.html with 200 status (rewrite, not redirect)
```

### AWS S3 + CloudFront

```
AWS Architecture for Angular
═══════════════════════════════════════════════════════════════

  User Browser
       │
       ▼
  CloudFront CDN
  (Global edge locations — 400+ worldwide)
  ├── Cache-Control headers respected
  ├── HTTPS termination
  ├── Gzip/Brotli compression
  └── Custom error pages
       │
       ▼
  S3 Bucket (Static Website Hosting)
  ├── index.html
  ├── main.abc123.js
  ├── styles.def456.css
  └── assets/
```

```bash
#!/bin/bash
# deploy-aws.sh — deploy Angular to AWS S3 + CloudFront

# Variables
BUCKET_NAME="my-angular-app-prod"          # ← your S3 bucket name
CLOUDFRONT_ID="EXXXXXXXXXXXXX"              # ← your CloudFront distribution ID
DIST_FOLDER="dist/my-angular-app/browser"   # ← esbuild output

echo "Building Angular app..."
ng build --configuration=production

echo "Syncing to S3..."
aws s3 sync "$DIST_FOLDER" "s3://$BUCKET_NAME" \
  --delete \
  # ↑ Delete S3 files that no longer exist locally
  # (removes old hashed bundles)

  --cache-control "max-age=31536000,immutable" \
  # ↑ Set aggressive caching for ALL files by default

  --exclude "index.html"
  # ↑ Exclude index.html from this sync (handle separately below)

# Upload index.html with no-cache headers
aws s3 cp "$DIST_FOLDER/index.html" "s3://$BUCKET_NAME/index.html" \
  --cache-control "no-cache,no-store,must-revalidate" \
  --content-type "text/html"
  # ↑ index.html must never be cached
  # It references hashed filenames — must always be fresh

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id "$CLOUDFRONT_ID" \
  --paths "/index.html" "/*"
  # ↑ Tell CloudFront to fetch fresh content from S3
  # Without this, CloudFront serves cached OLD files for hours/days
  # /index.html: critical to invalidate immediately
  # /*: invalidate everything (slower but thorough)

echo "Deployment complete!"
echo "Visit: https://myapp.com"
```

**S3 Bucket Policy for Public Access:**

```json
// S3 Bucket Policy — allow CloudFront to read objects
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
        // ↑ Only allow CloudFront, not direct S3 access
        // Users MUST go through CloudFront (HTTPS enforcement)
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-angular-app-prod/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::123456789:distribution/EXXXXX"
          // ↑ Only YOUR specific CloudFront distribution
        }
      }
    }
  ]
}
```

### Azure Static Web Apps

```yaml
# .github/workflows/azure-static-web-apps.yml
# Auto-generated by Azure Static Web Apps when you link your repo

name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

jobs:
  build_and_deploy:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy

    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true

      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"                    # ← root where package.json is
          output_location: "dist/my-angular-app/browser"
          app_build_command: "npm run build:prod"
```

```json
// staticwebapp.config.json — Azure Static Web Apps routing config
{
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif}", "/css/*"]
    // ↑ Rewrite all unmatched URLs to index.html
    // EXCEPT images and CSS (serve those as-is)
  },
  "globalHeaders": {
    "cache-control": "no-store"    // ← default: no cache (override per route)
  },
  "routes": [
    {
      "route": "/*.js",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
        // ↑ 1 year cache for JS bundles (hashed filenames)
      }
    },
    {
      "route": "/*.css",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
      }
    }
  ]
}
```

---

## 21.11 Monitoring & Error Tracking

### The Problem: Production Errors Are Invisible

Without error tracking, production errors are silent. A user gets a blank screen and leaves. You never know. With Sentry, you get an email the moment an error occurs, with a full stack trace.

**Analogy:** A car without a warning dashboard. You don't know the engine is overheating until smoke appears. Error tracking is your application's warning dashboard.

### Sentry Integration for Angular

```bash
# Install Sentry Angular SDK
npm install @sentry/angular

# Optional: Sentry CLI for source map uploads
npm install --save-dev @sentry/cli
```

```typescript
// main.ts — Initialize Sentry BEFORE Angular bootstraps
import * as Sentry from '@sentry/angular';
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';
import { environment } from './environments/environment';

// Initialize Sentry FIRST (before Angular)
Sentry.init({
  dsn: environment.sentryDsn,
  // ↑ Your Sentry project DSN (Data Source Name)
  // Different DSN per environment (dev: empty, prod: real DSN)

  environment: environment.production ? 'production' : 'development',
  // ↑ Tag events with environment name
  // Sentry lets you filter events by environment

  release: 'my-angular-app@' + environment.appVersion,
  // ↑ Tag events with the deployed version
  // When you get an error, you know which version caused it

  integrations: [
    Sentry.browserTracingIntegration(),
    // ↑ Automatic performance monitoring
    // Tracks: page load times, API calls, route changes

    Sentry.replayIntegration({
      maskAllText: true,          // ← GDPR: mask sensitive text in replays
      blockAllMedia: true         // ← GDPR: block images/videos in replays
    })
    // ↑ Session replay: record what user was doing when error occurred
  ],

  tracesSampleRate: environment.production ? 0.1 : 1.0,
  // ↑ What % of transactions to trace for performance monitoring
  // Production: 10% (reduces cost/volume)
  // Development: 100% (trace everything for testing)

  replaysSessionSampleRate: 0.1,
  // ↑ 10% of all sessions get recorded (for replay)

  replaysOnErrorSampleRate: 1.0,
  // ↑ 100% of sessions WITH errors get recorded
  // (error sessions are the important ones!)

  beforeSend(event) {
    // ↑ Hook to modify or filter events before sending to Sentry
    if (environment.production === false) {
      // Don't send errors in development (would pollute Sentry)
      console.error('Sentry event (not sent in dev):', event);
      return null;                // ← returning null DROPS the event
    }
    return event;                 // ← returning event SENDS it
  }
});

bootstrapApplication(AppComponent, appConfig)
  .catch(err => Sentry.captureException(err));
  // ↑ If Angular fails to bootstrap, send that error to Sentry too
```

```typescript
// src/app/app.config.ts — Register Sentry Angular providers
import { ApplicationConfig, ErrorHandler } from '@angular/core';
import { provideRouter, withNavigationErrorHandler } from '@angular/router';
import * as Sentry from '@sentry/angular';
import { Router } from '@angular/router';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),

    {
      provide: ErrorHandler,
      useValue: Sentry.createErrorHandler({
        showDialog: false,
        // ↑ Whether to show a "Report Feedback" dialog on errors
        // Useful for beta/staging, disable for production
      })
      // ↑ Replace Angular's default ErrorHandler with Sentry's
      // Now ALL unhandled errors in Angular are automatically sent to Sentry
    },

    {
      provide: Sentry.TraceService,
      deps: [Router]
      // ↑ Enables route change tracking in Sentry
      // Each navigation appears as a "transaction" in performance monitoring
    }
  ]
};
```

```typescript
// Manual error capture and breadcrumbs
import * as Sentry from '@sentry/angular';

@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient);

  updateUserProfile(userId: string, data: Partial<User>): Observable<User> {
    return this.http.put<User>(`/api/users/${userId}`, data).pipe(
      catchError(error => {
        // Add context breadcrumb
        Sentry.addBreadcrumb({
          category: 'api',
          message: `Failed to update user ${userId}`,
          level: 'error',
          data: {
            userId,
            errorCode: error.status,
            errorMessage: error.message
          }
          // ↑ Breadcrumbs appear in Sentry before the error event
          // Like browser history — shows what user was doing
        });

        // Set user context for the error
        Sentry.setUser({
          id: userId,
          // ↑ Sentry shows which user experienced this error
          // GDPR note: don't include email/name without consent
        });

        // Add custom tags for filtering
        Sentry.setTag('api.endpoint', '/api/users');
        Sentry.setTag('api.method', 'PUT');

        // Manually capture the error with extra context
        Sentry.captureException(error, {
          extra: {
            userId,
            requestData: data
          }
        });

        return throwError(() => error);
      })
    );
  }
}
```

### Source Maps for Production Debugging

Without source maps, Sentry shows minified code: `a.b.c(d, e.f)`. With source maps, it shows your real code.

```typescript
// angular.json — hidden source maps for Sentry
"production": {
  "sourceMap": {
    "scripts": true,           // ← Generate source maps
    "hidden": true             // ← "hidden" = don't reference in bundle
    // "hidden" source maps are generated but NOT linked from the bundle
    // Users can't download them, but Sentry can upload them separately
  }
}
```

```bash
# Upload source maps to Sentry after build
# Using Sentry CLI in your CI/CD pipeline

# Install Sentry CLI
npm install --save-dev @sentry/cli

# Authenticate (use env var in CI)
# SENTRY_AUTH_TOKEN=your_token

# In your deploy script:
npx sentry-cli releases new my-angular-app@$VERSION

npx sentry-cli releases files my-angular-app@$VERSION upload-sourcemaps \
  dist/my-angular-app/browser \
  --rewrite \
  --url-prefix '~/static/'

npx sentry-cli releases finalize my-angular-app@$VERSION
```

---

## 21.12 Angular CLI Custom Builders & Schematics

### What Are Builders?

Builders are plugins that execute custom build steps through the Angular CLI. Instead of running raw npm scripts, builders integrate with `ng build`, `ng serve`, `ng test`.

```
Angular CLI Builders
═══════════════════════════════════════════════════════════════

  Standard builders:
    @angular-devkit/build-angular:application   ← esbuild
    @angular-devkit/build-angular:browser       ← webpack
    @angular-devkit/build-angular:dev-server    ← ng serve
    @angular-devkit/build-angular:karma         ← ng test

  Custom builders you might write:
    my-org/build-angular:deploy-s3     ← ng run app:deploy-s3
    my-org/build-angular:storybook     ← ng run app:storybook
    my-org/build-angular:lighthouse    ← ng run app:lighthouse

  When to create custom builders:
    - Company-specific deployment steps
    - Custom linting rules
    - Automated performance audits
    - Integration with internal tooling
```

### What Are Schematics?

Schematics are code generators — they create, modify, or delete files based on rules. The `ng generate component` command runs Angular's built-in schematics.

```bash
# Built-in schematics you already use:
ng generate component my-component      # ← runs @schematics/angular:component
ng generate service my-service          # ← runs @schematics/angular:service
ng generate pipe my-pipe                # ← runs @schematics/angular:pipe

# Custom schematic example:
ng generate my-company:feature-module my-feature
# ↑ Could generate:
#   my-feature/
#   ├── my-feature.module.ts          ← with company-standard boilerplate
#   ├── my-feature.component.ts       ← with company-standard header
#   ├── my-feature.service.ts         ← with standard error handling
#   ├── my-feature.store.ts           ← with NgRx setup
#   └── my-feature.routes.ts          ← with standard route structure
```

**When to create custom schematics:**
1. Your team generates the same boilerplate for every feature
2. You have company-specific patterns every component must follow
3. You want to enforce architecture decisions through code generation
4. You're building an Angular library and want `ng add my-library` to work

**Basic schematic structure:**

```typescript
// schematics/feature-module/index.ts
import { Rule, SchematicContext, Tree, apply, url, template, mergeWith } from '@angular-devkit/schematics';
import { strings } from '@angular-devkit/core';

export function featureModule(options: any): Rule {
  return (tree: Tree, context: SchematicContext) => {
    // ↑ A Rule is a function that transforms a Tree (virtual file system)

    const templateSource = apply(
      url('./files'),           // ← template files in ./files/
      [
        template({
          ...strings,           // ← dasherize, classify, camelize utilities
          ...options            // ← CLI options passed by user
        })
      ]
    );

    return mergeWith(templateSource)(tree, context);
    // ↑ Merge generated files into the project tree
  };
}
```

---

## 21.13 Practical Example: Complete CI/CD Pipeline

This section ties everything together into a complete, production-grade pipeline.

### Scenario

A healthcare Angular application with:
- GitHub repository
- Multi-environment (dev, staging, production)
- Firebase Hosting (production)
- Sentry error tracking
- Docker image for enterprise deployment

```
COMPLETE PIPELINE
═══════════════════════════════════════════════════════════════

  Developer pushes code
         │
         ▼
  GitHub Detects Push
         │
         ▼
  ┌─────────────────────────────────────────────────────────┐
  │  GitHub Actions CI Pipeline                             │
  │                                                         │
  │  PARALLEL:                                              │
  │  ├── Job: Lint (2 min)                                  │
  │  └── Job: Unit Tests (5 min)                            │
  │         │                                               │
  │         ▼ (both must pass)                              │
  │  Job: Build Production (3 min)                          │
  │         │                                               │
  │         ▼ (if on main branch)                           │
  │  PARALLEL:                                              │
  │  ├── Job: Docker Build & Push (5 min)                   │
  │  ├── Job: Upload Source Maps to Sentry (1 min)          │
  │  └── Job: Deploy to Firebase (2 min)                    │
  │         │                                               │
  │         ▼                                               │
  │  Job: Post-deploy Smoke Tests (2 min)                   │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
  Production Live! ← with error tracking, monitoring active
```

### Complete Pipeline Implementation

```yaml
# .github/workflows/ci-cd-complete.yml

name: Complete Angular CI/CD Pipeline

on:
  push:
    branches: [main, develop, 'release/**']
  pull_request:
    branches: [main, develop]

env:
  NODE_VERSION: '20'
  APP_NAME: 'my-angular-app'

jobs:
  # ═══════════════════════════════════════════════════════════
  # PARALLEL GROUP 1: Code Quality
  # ═══════════════════════════════════════════════════════════

  lint:
    name: Lint Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci

      - name: Lint TypeScript and templates
        run: npm run lint
        # ↑ ng lint — checks ESLint rules

      - name: Check for circular dependencies
        run: npx madge --circular --extensions ts src/
        # ↑ Circular dependency checker — catches import cycles
        # Circular deps cause: undefined values, hard-to-debug issues

  unit-test:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci

      - name: Run unit tests with coverage
        run: npm run test:ci

      - name: Check coverage thresholds
        run: |
          # Fail if coverage drops below thresholds
          npx istanbul check-coverage \
            --statements 80 \
            --branches 70 \
            --functions 80 \
            --lines 80
          # ↑ Enforce minimum coverage requirements
          # Prevents coverage from silently dropping

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          file: coverage/${{ env.APP_NAME }}/lcov.info

  # ═══════════════════════════════════════════════════════════
  # BUILD: After quality checks pass
  # ═══════════════════════════════════════════════════════════

  build:
    name: Production Build
    runs-on: ubuntu-latest
    needs: [lint, unit-test]
    # ↑ Only build if ALL quality checks pass

    outputs:
      version: ${{ steps.version.outputs.version }}
      # ↑ Share the version string with downstream jobs

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci

      - name: Generate version string
        id: version
        run: |
          VERSION="${{ github.ref_name }}-$(echo ${{ github.sha }} | cut -c1-8)"
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "Building version: $VERSION"
          # ↑ Create version: "main-abc12345"
          # Used for Sentry release tagging

      - name: Inject version into environment
        run: |
          sed -i "s/APP_VERSION_PLACEHOLDER/${{ steps.version.outputs.version }}/g" \
            src/environments/environment.prod.ts
          # ↑ Replace placeholder in environment file with actual version
          # environment.prod.ts must have: appVersion: 'APP_VERSION_PLACEHOLDER'

      - name: Build production bundle
        run: ng build --configuration=production

      - name: Analyze bundle sizes
        run: |
          echo "Bundle sizes:"
          ls -lh dist/${{ env.APP_NAME }}/browser/*.js | awk '{print $5, $9}'
          # ↑ Log bundle sizes for monitoring over time

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: angular-dist
          path: dist/
          retention-days: 30      # ← Keep for 30 days (rollback capability)

  # ═══════════════════════════════════════════════════════════
  # PARALLEL GROUP 2: Deploy (only on main branch)
  # ═══════════════════════════════════════════════════════════

  deploy-firebase:
    name: Deploy to Firebase
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment:
      name: production
      url: 'https://my-angular-app.web.app'
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: angular-dist
          path: dist/

      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: my-firebase-project

  docker-build-push:
    name: Docker Build & Push
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io         # ← GitHub Container Registry
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          # ↑ GitHub Token has permission to push to GHCR automatically

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository_owner }}/${{ env.APP_NAME }}:latest
            ghcr.io/${{ github.repository_owner }}/${{ env.APP_NAME }}:${{ needs.build.outputs.version }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  upload-sourcemaps:
    name: Upload Source Maps to Sentry
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: angular-dist
          path: dist/

      - name: Create Sentry release and upload source maps
        env:
          SENTRY_AUTH_TOKEN: ${{ secrets.SENTRY_AUTH_TOKEN }}
          SENTRY_ORG: my-org
          SENTRY_PROJECT: my-angular-app
        run: |
          VERSION="${{ needs.build.outputs.version }}"

          # Create a new release in Sentry
          npx @sentry/cli releases new "$VERSION"

          # Upload source maps to this release
          npx @sentry/cli releases files "$VERSION" upload-sourcemaps \
            dist/${{ env.APP_NAME }}/browser \
            --rewrite \
            --url-prefix '~/'
          # ↑ --rewrite: modifies source map URLs to match production
          # --url-prefix: the URL prefix where JS files are served

          # Mark the release as deployed to production
          npx @sentry/cli releases deploys "$VERSION" new \
            --env production

          # Finalize the release
          npx @sentry/cli releases finalize "$VERSION"

  # ═══════════════════════════════════════════════════════════
  # SMOKE TESTS: Verify production is working
  # ═══════════════════════════════════════════════════════════

  smoke-test:
    name: Production Smoke Tests
    runs-on: ubuntu-latest
    needs: [deploy-firebase]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - name: Wait for deployment to propagate
        run: sleep 30
        # ↑ Give CDN time to propagate the new deployment

      - name: Run smoke tests against production
        run: |
          # Test that index.html is accessible
          STATUS=$(curl -o /dev/null -s -w "%{http_code}" https://my-angular-app.web.app)
          if [ "$STATUS" != "200" ]; then
            echo "SMOKE TEST FAILED: index.html returned $STATUS"
            exit 1
          fi

          # Test that SPA routing works (not 404)
          STATUS=$(curl -o /dev/null -s -w "%{http_code}" https://my-angular-app.web.app/dashboard)
          if [ "$STATUS" != "200" ]; then
            echo "SMOKE TEST FAILED: /dashboard route returned $STATUS"
            exit 1
          fi

          echo "Smoke tests passed!"

      - name: Notify on failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          text: 'Production smoke tests FAILED! Deployment may have issues.'
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### PR Preview Deployments

```yaml
# Add this job for PR previews (Firebase preview channels)

  deploy-preview:
    name: Deploy PR Preview
    runs-on: ubuntu-latest
    needs: [build]
    if: github.event_name == 'pull_request'
    # ↑ ONLY on pull requests (not on main branch pushes)
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: angular-dist
          path: dist/

      - name: Deploy to Firebase Preview Channel
        uses: FirebaseExtended/action-hosting-deploy@v0
        id: firebase_preview
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          projectId: my-firebase-project
          channelId: pr-${{ github.event.pull_request.number }}
          # ↑ Creates: https://my-app--pr-123-abc123.web.app
          expires: 7d            # ← preview expires after 7 days

      - name: Comment preview URL on PR
        uses: actions/github-script@v7
        with:
          script: |
            const url = '${{ steps.firebase_preview.outputs.details_url }}';
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `Preview deployed! Visit: ${url}`
            });
```

---

## 21.14 Summary

This phase covered the complete journey from writing Angular code to reliably delivering it to users.

### Key Concepts Recap

```
COMPLETE BUILD & DEPLOY KNOWLEDGE MAP
═══════════════════════════════════════════════════════════════

  21.2 BUILD PROCESS
  ══════════════════
  TypeScript → ngc (AOT) → Bundler → Optimized JS
  AOT: Compile at build time (FAST runtime, smaller bundles)
  JIT: Compile at runtime (SLOW startup, larger bundles)

  21.3 BUILD CONFIGURATIONS
  ══════════════════════════
  angular.json: configurations block
  development: no optimization, source maps ON
  production: optimization ON, source maps OFF, hashing ON
  custom: staging, uat, qa — same mechanism
  fileReplacements: how environment.ts gets swapped

  21.4 BUNDLE OPTIMIZATION
  ════════════════════════
  source-map-explorer: visualize what's in your bundle
  Tree shaking: remove unused code (ES modules required)
  Code splitting: lazy-load routes and components
  Budget limits: build fails if bundles exceed thresholds

  21.5 ESBUILD VS WEBPACK
  ═══════════════════════
  Angular 17+: @angular-devkit/build-angular:application (esbuild)
  Legacy: @angular-devkit/build-angular:browser (webpack)
  esbuild: 10x faster builds, same output quality

  21.6 ENVIRONMENT CONFIG
  ═══════════════════════
  Build-time: fileReplacements in angular.json
  Runtime: APP_INITIALIZER + fetch /assets/config.json
  12-factor: Build once, configure with env/runtime config

  21.7 PWA
  ════════
  ng add @angular/pwa → service worker + manifest
  ngsw-config.json: assetGroups (performance/freshness)
  SwUpdate: handle app updates gracefully
  cache-first vs network-first strategies

  21.8 DOCKER
  ════════════
  Multi-stage: node (build) → nginx (serve)
  nginx.conf: try_files for SPA routing
  Final image: ~25MB (only nginx + dist files)

  21.9 CI/CD
  ══════════
  GitHub Actions: .github/workflows/ci.yml
  Azure DevOps: azure-pipelines.yml
  GitLab CI: .gitlab-ci.yml
  Key jobs: install → lint → test → build → deploy

  21.10 DEPLOYMENT TARGETS
  ════════════════════════
  Firebase: firebase.json rewrites, ng add @angular/fire
  Vercel: vercel.json, zero-config, instant deploys
  Netlify: netlify.toml, _redirects file
  AWS S3+CloudFront: cache invalidation on deploy
  Azure Static Web Apps: staticwebapp.config.json

  21.11 MONITORING
  ════════════════
  Sentry: ErrorHandler replacement, automatic capture
  Source maps: "hidden" maps uploaded to Sentry
  Performance: tracesSampleRate, browserTracingIntegration

  21.12 BUILDERS & SCHEMATICS
  ═══════════════════════════
  Builders: custom ng build/serve/test steps
  Schematics: custom ng generate templates
```

### Decision Guide: Choosing Your Deployment Target

```
DEPLOYMENT TARGET DECISION GUIDE
═══════════════════════════════════════════════════════════════

  START: What is your situation?
         │
         ├── Personal project / side project
         │         → Vercel (easiest, free tier)
         │           or Netlify (easy, free tier)
         │
         ├── Google ecosystem (Firebase, GCP)
         │         → Firebase Hosting
         │           Excellent for Angular (same team!)
         │
         ├── Microsoft ecosystem (Azure AD, .NET backend)
         │         → Azure Static Web Apps
         │           Native AD integration
         │
         ├── Need full control / enterprise
         │         → AWS S3 + CloudFront
         │           Most flexible, most control
         │           Higher setup cost
         │
         └── Need to run containerized
                   → Docker + Kubernetes
                     or Docker + your cloud's container service
```

### Before/After: The Developer Who Understands DevOps

**Before this phase:**
- "I just write the Angular code, someone else deploys it"
- "It works on my machine — maybe the server is wrong?"
- "Why is production slow? My app is fast locally!"
- "I don't know why the build failed — the error message makes no sense"

**After this phase:**
- Build configurations are second nature
- Bundle analysis reveals exactly what's making the app slow
- CI/CD pipeline catches bugs before users see them
- Docker ensures "works on my machine" = "works everywhere"
- Sentry tells you about production errors before users complain
- Multiple deployment targets available depending on project needs

### Common Mistakes and Gotchas

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Not setting up budgets | Bundle grows unnoticed | Set budget limits in angular.json |
| Caching index.html | Users get old app after deploy | `Cache-Control: no-cache` for index.html |
| No SPA routing config | Refreshing /dashboard gives 404 | Configure `try_files` / rewrites |
| Source maps in production bundle | Users can read your source code | Use `"hidden": true` source maps |
| Hard-coded environment values | Wrong API URL in wrong environment | Use environment files + fileReplacements |
| `import * as _ from 'lodash'` | No tree shaking, 71KB lodash in bundle | Use `lodash-es` with named imports |
| Not running tests in CI | Broken code gets deployed | Always include test job in pipeline |
| Not invalidating CloudFront | Stale content served after deploy | `aws cloudfront create-invalidation` |
| Skipping linting in CI | Code quality degrades over time | Lint job required to pass before build |
| No error tracking | Silent production failures | Add Sentry from day one |

### The Complete Mental Model

```
THINK OF YOUR ANGULAR APP LIKE A PRODUCT BEING MANUFACTURED
═══════════════════════════════════════════════════════════════

  DESIGN (Development):
    Write TypeScript, HTML, CSS
    ng serve for local feedback loop

  QUALITY CONTROL (CI):
    Lint: coding standards check
    Unit tests: individual component tests
    Build: verify it compiles and fits in budget

  MANUFACTURING (Build):
    ng build --configuration=production
    AOT compilation + tree shaking + minification + hashing

  PACKAGING (Docker):
    Multi-stage Dockerfile
    Small nginx image with compiled artifacts

  DISTRIBUTION (Deploy):
    Upload to CDN (Firebase/Vercel/S3)
    Set cache headers correctly
    Invalidate CDN caches

  WARRANTY SERVICE (Monitoring):
    Sentry catches and reports defects
    Source maps allow debugging minified code
    Performance monitoring tracks user experience
```

---

> **Next Phase:** [Phase 22: Angular New Features & Migration](Phase22-Angular-New-Features-Migration.md)
