# Phase 19: Server-Side Rendering & Angular Universal

> Angular applications are powerful — but by default, they ship an empty HTML page and let JavaScript build everything in the browser. This works great for dashboards, but it fails search engines, social media crawlers, and users on slow connections. Server-Side Rendering is the technique that sends real, pre-built HTML from the server — giving you better SEO, faster perceived load times, and a production-ready Angular app. This phase teaches you everything: how SSR works, Angular Universal (legacy and modern), hydration, platform detection, TransferState, pre-rendering, SEO, caching, and deployment.

---

## 19.1 Why Server-Side Rendering?

### The Core Problem: The Blank Page Problem

When a user opens a regular Angular app, here is what actually happens:

1. Browser requests your website
2. Server responds with an **almost-empty HTML file**:
   ```html
   <!doctype html>
   <html>
     <head><title>My App</title></head>
     <body>
       <app-root></app-root>  <!-- ← EMPTY. Nothing here yet. -->
     </body>
   </html>
   ```
3. Browser downloads `main.js` (often 300KB–1MB+)
4. JavaScript parses and executes
5. Angular bootstraps, makes HTTP calls
6. **Finally**, the user sees actual content

For a user on a slow mobile connection, steps 3–6 can take 3–8 seconds. During all that time, they see a **blank white page**.

This is the "blank page problem" — the fundamental reason SSR exists.

---

### CSR vs SSR vs SSG vs ISR — The Full Comparison Table

| Rendering Mode | Full Name | When HTML is Built | Server Needed? | Best For | Downside |
|---|---|---|---|---|---|
| **CSR** | Client-Side Rendering | In the browser, on every visit | No (just static files) | Dashboards, admin panels, apps behind login | Bad SEO, slow FCP, blank page |
| **SSR** | Server-Side Rendering | On the server, on every request | Yes (Node.js) | E-commerce, blogs, news, public pages | Server cost, slower TTFB than SSG |
| **SSG** | Static Site Generation | At build time (once) | No (just static files) | Blogs, docs, marketing pages with infrequent changes | No real-time data, long rebuild on content change |
| **ISR** | Incremental Static Regeneration | At build time + revalidated on request | Yes | High-traffic sites where content changes occasionally | More complex caching logic |

---

### ASCII Diagram: CSR vs SSR Timeline

```
CLIENT-SIDE RENDERING (CSR) Timeline:
=========================================

  0ms     100ms    500ms   1000ms   2000ms   3000ms
   |        |        |       |        |        |
   |  req   |        |       |        |        |
   |------->|        |       |        |        |
   |        | empty  |       |        |        |
   |        | HTML   |       |        |        |
   |<-------|        |       |        |        |
   |        | JS     |       |        |        |
   |        | download       |        |        |
   |        |------->|       |        |        |
   |        |        | parse |        |        |
   |        |        | JS    |        |        |
   |        |        |------>|        |        |
   |        |        |       | API    |        |
   |        |        |       | calls  |        |
   |        |        |       |------->|        |
   |        |        |       |        | RENDER |
   |        |        |       |        |------->|
   |        |        |       |        |        |
   USER SEES CONTENT ONLY AT ~3000ms  ← BAD!


SERVER-SIDE RENDERING (SSR) Timeline:
=========================================

  0ms     100ms    300ms   500ms
   |        |        |       |
   |  req   |        |       |
   |------->|        |       |
   |        | server |       |
   |        | renders|       |
   |        | HTML   |       |
   |        |------->|       |
   |        |        | full  |
   |        |        | HTML  |
   |<-------|--------|       |
   |        |        | JS    |
   |        |        | hydrate
   |        |        |------>|
   |        |        |       |
   USER SEES CONTENT AT ~300ms ← GOOD!
   APP IS INTERACTIVE AT ~500ms
```

---

### Real-World Analogy: Restaurant Serving Styles

**CSR is like cooking from scratch on demand:**
- You sit down at the restaurant
- The waiter hands you an empty plate (blank HTML)
- Then goes to the kitchen to get all ingredients (download JS)
- Then cooks your entire meal (Angular bootstraps and renders)
- 30 minutes later, food arrives (user sees content)

**SSR is like having pre-cooked meals ready to serve:**
- You sit down at the restaurant
- The waiter immediately brings a hot, ready meal (server-rendered HTML)
- While you eat, the chef adds the finishing touches (hydration — JS attaches)
- You're eating within 2 minutes

**SSG is like a buffet:**
- All the food is already cooked and displayed
- Grab your plate immediately (static files)
- No chef needed (no server)
- The dishes don't change until the buffet is restocked (new build)

---

### Why SEO Cares About SSR

Search engine crawlers (Googlebot) request your page and read the HTML. With CSR, they get this:

```html
<!-- What Googlebot sees with CSR: -->
<body>
  <app-root></app-root>
  <!-- ← Nothing here! The crawler can't execute Angular's JavaScript
       (or chooses not to wait for it). No content = not indexed. -->
</body>
```

With SSR, Googlebot gets this:

```html
<!-- What Googlebot sees with SSR: -->
<body>
  <app-root>
    <h1>Best Running Shoes of 2026</h1>
    <p>Looking for the perfect running shoe? Our expert team tested 47 models...</p>
    <div class="product-card">
      <h2>Nike Air Max 2026</h2>
      <p>Price: $159.99</p>
      <!-- ← Real content! Googlebot can index this immediately. -->
    </div>
  </app-root>
</body>
```

---

### Social Media Preview Cards Need SSR

When someone shares your link on LinkedIn, Twitter/X, or Slack, those platforms send a bot to read your Open Graph (OG) meta tags:

```html
<!-- These tags must exist in the INITIAL HTML response -->
<!-- Social bots do NOT execute JavaScript -->
<meta property="og:title" content="Best Running Shoes of 2026" />
<meta property="og:description" content="Expert reviews of 47 running shoes..." />
<meta property="og:image" content="https://example.com/shoes-banner.jpg" />
```

If these tags are added by Angular's JavaScript (CSR), social bots will never see them. The preview card will be blank or generic. With SSR, these tags are in the initial HTML response — preview cards work perfectly.

---

## 19.2 How Angular SSR Works

### The SSR Request Lifecycle

```
SSR REQUEST LIFECYCLE:
================================

Browser                Node.js Server              Angular (Server-side)
  |                         |                              |
  |-- GET /products/123 --->|                              |
  |                         |-- Router matches route ----->|
  |                         |                              |
  |                         |-- Runs Angular app on  ----->|
  |                         |   Node.js (no DOM!)          |
  |                         |                              |
  |                         |<-- fetchProduct(123) --------|
  |                         |    (HTTP call from server)   |
  |                         |                              |
  |                         |<-- Product data returned ----|
  |                         |                              |
  |                         |<-- Angular renders HTML  ----|
  |                         |    with full content         |
  |                         |                              |
  |<-- Full HTML response --|                              |
  |    with content          |                              |
  |    with meta tags        |                              |
  |    with styles           |                              |
  |                         |                              |
  |-- Browser displays HTML immediately (FCP!)             |
  |                         |                              |
  |-- Downloads main.js --->|                              |
  |                         |                              |
  |-- Angular bootstraps in browser                        |
  |-- Hydration: attaches event listeners to existing DOM  |
  |                         |                              |
  |-- App is now interactive (TTI)                         |
```

---

### The Three Phases of SSR

**Phase 1: Server Render**
- Node.js receives the HTTP request
- Angular's server-side app handles the route
- Angular renders the component tree to an HTML string
- No browser APIs (window, document, localStorage) — these don't exist on the server

**Phase 2: HTML Delivery**
- The server sends the fully-rendered HTML to the browser
- The browser can immediately display this content
- This is the First Contentful Paint (FCP) — users see real content fast

**Phase 3: Hydration**
- The browser downloads the Angular JavaScript bundle
- Angular bootstraps in the browser (client-side)
- Angular "hydrates" — attaches event listeners and component logic to the existing server-rendered DOM
- The app becomes fully interactive (Time To Interactive — TTI)

---

### The "Uncanny Valley" Problem

There's a brief period after the HTML is displayed but before hydration completes where:
- The page **looks** fully rendered and interactive
- But nothing actually **responds** to clicks

This is called the **Uncanny Valley** — the page appears ready but isn't.

```
UNCANNY VALLEY TIMELINE:
=========================

t=0ms   t=200ms   t=400ms   t=700ms   t=1200ms
  |       |         |         |          |
  |  req  |         |         |          |
  |       | HTML    |         |          |
  |       | arrives |         |          |
  |       | (looks  |         |          |
  |       | great!) |         |          |
  |       |         | JS      |          |
  |       |         | arrives |          |
  |       |         |         | Angular  |
  |       |         |         | boots    |
  |       |         |         |          | Hydration
  |       |         |         |          | complete!
  |       |         |         |          |
  |<------UNCANNY VALLEY----->|          |
  |  Page looks ready but    |          |
  |  clicks don't work yet!  |          |
```

Angular 16+ addresses this with **non-destructive hydration** — the transition is much smoother because Angular reuses existing DOM nodes instead of destroying and rebuilding them.

---

## 19.3 Setting Up Angular SSR (Angular 17+ Modern Approach)

### Adding SSR to an Existing Angular App

Angular 17+ made SSR setup dramatically simpler. One command handles everything:

```bash
# ← Add SSR support to your existing Angular application
# ← This uses Angular's new @angular/ssr package (not nguniversal)
ng add @angular/ssr

# ← Or when creating a brand new project, Angular 17+ asks if you want SSR:
ng new my-ssr-app
# > Would you like to enable Server-Side Rendering (SSR) and Static Site Generation (SSG)? Yes
```

---

### What Gets Generated

Running `ng add @angular/ssr` creates and modifies several files:

```
your-app/
├── src/
│   ├── app/
│   │   ├── app.component.ts        ← unchanged
│   │   ├── app.config.ts           ← modified (add provideClientHydration)
│   │   └── app.config.server.ts    ← NEW — server-specific providers
│   ├── main.ts                     ← unchanged (client bootstrap)
│   └── main.server.ts              ← NEW — server bootstrap entry point
├── server.ts                       ← NEW — Express server setup
├── angular.json                    ← modified (add SSR build targets)
└── package.json                    ← modified (add @angular/ssr, express)
```

---

### File-by-File Walkthrough

**`src/main.server.ts` — Server Bootstrap Entry Point:**

```typescript
// src/main.server.ts
// ← This is the entry point for the SERVER-SIDE rendering
// ← Think of it as "main.ts but for Node.js"
// ← This file is compiled separately from main.ts (browser version)

import { bootstrapApplication } from '@angular/platform-browser';
// ← We import bootstrapApplication just like the browser version...

import { AppComponent } from './app/app.component';
// ← ...and the same root component

import { config } from './app/app.config.server';
// ← ...but we use a DIFFERENT config (server-specific providers)

const bootstrap = () => bootstrapApplication(AppComponent, config);
// ← We export a bootstrap FACTORY function (not called immediately)
// ← The Angular SSR engine calls this for each incoming request
// ← This means a fresh Angular instance per request — no shared state!

export default bootstrap;
// ← Must be default export — the @angular/ssr engine expects this
```

---

**`src/app/app.config.ts` — Client-Side Configuration (Modified):**

```typescript
// src/app/app.config.ts
// ← Modified by ng add @angular/ssr to add hydration support

import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideClientHydration } from '@angular/platform-browser';
// ← provideClientHydration is the KEY addition for SSR
// ← It tells Angular: "this app was server-rendered, do non-destructive hydration"

import { routes } from './app.routes';
import { provideHttpClient, withFetch } from '@angular/common/http';
// ← withFetch() tells Angular to use the Fetch API instead of XMLHttpRequest
// ← This works on BOTH browser AND Node.js (Node 18+ has native fetch)

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),          // ← Standard router
    provideClientHydration(),       // ← *** KEY: Enable non-destructive hydration ***
    provideHttpClient(withFetch()), // ← Use fetch API (works on server too)
  ]
};
```

---

**`src/app/app.config.server.ts` — Server-Side Configuration:**

```typescript
// src/app/app.config.server.ts
// ← This config is ONLY used during server-side rendering
// ← It MERGES with the client config (appConfig) using mergeApplicationConfig

import { mergeApplicationConfig, ApplicationConfig } from '@angular/core';
import { provideServerRendering } from '@angular/platform-server';
// ← provideServerRendering enables the server-side rendering platform
// ← This replaces all browser-specific services with server-safe equivalents

import { appConfig } from './app.config';
// ← We import the base config (client config)

const serverConfig: ApplicationConfig = {
  providers: [
    provideServerRendering(),
    // ← On the server, Angular uses a fake DOM (domino library)
    // ← provideServerRendering sets up all the server-safe providers
    // ← Things like: server-safe HttpClient, server renderer, etc.
  ]
};

export const config = mergeApplicationConfig(appConfig, serverConfig);
// ← mergeApplicationConfig COMBINES the two configs
// ← The server config EXTENDS the client config
// ← Providers in serverConfig override/augment providers in appConfig
// ← This way you don't duplicate shared providers
```

---

**`server.ts` — The Express Server:**

```typescript
// server.ts
// ← This is the actual Node.js/Express server that:
//   1. Serves static files (CSS, JS bundles, images)
//   2. Handles SSR requests using Angular Universal engine

import 'zone.js/node';
// ← Zone.js must be loaded FIRST on the server
// ← It provides change detection and async tracking in server environment

import { APP_BASE_HREF } from '@angular/common';
// ← Used to tell Angular what the base href is when running on server

import { CommonEngine } from '@angular/ssr';
// ← CommonEngine is Angular's SSR engine
// ← It takes your Angular bootstrap function and renders it to HTML string

import express from 'express';
// ← Express is the HTTP server framework
// ← Angular SSR uses Express as the default, but you could use Fastify, Koa, etc.

import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import bootstrap from './src/main.server';
// ← The bootstrap factory from main.server.ts
// ← CommonEngine will call this function to render each request

// ← __dirname equivalent for ES modules
const serverDistFolder = dirname(fileURLToPath(import.meta.url));
const browserDistFolder = resolve(serverDistFolder, '../browser');
// ← Path to the browser bundle (CSS, JS, images) built by Angular CLI
const indexHtml = join(serverDistFolder, 'index.server.html');
// ← The server HTML template (slightly different from browser's index.html)

export function app(): express.Express {
  const server = express();
  // ← Create Express application instance

  const commonEngine = new CommonEngine();
  // ← Create the Angular SSR engine
  // ← This is what actually renders Angular to HTML

  // ← Serve static files FIRST (before SSR handler)
  // ← Static files (JS bundles, CSS, images) don't need SSR
  server.get('*.*', express.static(browserDistFolder, {
    maxAge: '1y'  // ← Cache static assets for 1 year (they have content hashes)
  }));

  // ← All other routes are handled by Angular SSR
  server.get('*', (req, res, next) => {
    const { protocol, originalUrl, baseUrl, headers } = req;

    commonEngine
      .render({
        bootstrap,         // ← Our Angular app factory
        documentFilePath: indexHtml, // ← HTML template
        url: `${protocol}://${headers.host}${originalUrl}`,
        // ← Full URL so Angular Router knows which route to render
        publicPath: browserDistFolder,
        // ← Where to find static files
        providers: [
          { provide: APP_BASE_HREF, useValue: baseUrl },
          // ← Tell Angular the base URL
        ],
      })
      .then((html) => res.send(html))
      // ← Send the rendered HTML back to the browser
      .catch((err) => next(err));
      // ← Pass errors to Express error handler
  });

  return server;
}

function run(): void {
  const port = process.env['PORT'] || 4000;
  // ← Use PORT environment variable (standard for cloud deployments)
  // ← Default to 4000 for local development

  const server = app();
  server.listen(port, () => {
    console.log(`Node Express server listening on http://localhost:${port}`);
    // ← Confirm the server is running
  });
}

run();
// ← Start the server
```

---

### Building and Running the SSR App

```bash
# Build the SSR application
# ← This creates two builds:
#   - dist/my-app/browser/ (client-side bundle for hydration)
#   - dist/my-app/server/ (server-side bundle + server.ts)
npm run build

# Run the SSR server locally
npm run serve:ssr

# Or run directly
node dist/my-app/server/server.mjs
# ← The compiled server.ts becomes server.mjs (ES module)
```

---

### Angular.json Changes for SSR

```json
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "options": {
            "server": "src/main.server.ts",
            "prerender": true,
            "ssr": {
              "entry": "server.ts"
            }
          }
        }
      }
    }
  }
}
```

---

## 19.4 Angular Universal (Pre-Angular 17 — Legacy Approach)

### Why You Need to Know This

Many production Angular applications were built before Angular 17. If you join a team maintaining an Angular 12–16 app, you'll encounter the **Angular Universal** approach using `@nguniversal/express-engine`. Understanding both is essential.

---

### Adding Angular Universal (Legacy):

```bash
# ← Legacy command for Angular 12-16 projects
ng add @nguniversal/express-engine

# ← This installs:
#   @nguniversal/express-engine — the SSR engine
#   express — the HTTP server
#   @nguniversal/builders — build tools
```

---

### What Gets Generated (Legacy):

```
your-app/
├── src/
│   ├── app/
│   │   ├── app.module.ts          ← modified
│   │   └── app.server.module.ts   ← NEW — server-specific NgModule
│   ├── main.ts                    ← unchanged
│   └── main.server.ts             ← NEW (different from Angular 17+ version)
├── server.ts                      ← NEW Express server
└── tsconfig.server.json           ← NEW TypeScript config for server build
```

---

**`src/app/app.server.module.ts` — The Server NgModule:**

```typescript
// src/app/app.server.module.ts
// ← LEGACY (pre-Angular 17) approach
// ← In older Angular, SSR used NgModules instead of standalone components
// ← This is the server-specific NgModule that adds server rendering capabilities

import { NgModule } from '@angular/core';
import { ServerModule } from '@angular/platform-server';
// ← ServerModule is the legacy equivalent of provideServerRendering()
// ← It provides all the server-safe implementations of browser services

import { AppModule } from './app.module';
// ← Import the main app module

import { AppComponent } from './app.component';
// ← Import the root component (will be bootstrapped on server)

@NgModule({
  imports: [
    AppModule,      // ← Include the full app
    ServerModule,   // ← Add server-side rendering capabilities
  ],
  bootstrap: [AppComponent],  // ← Bootstrap the same root component
})
export class AppServerModule {}
// ← This module is what the server renders
// ← It extends AppModule with ServerModule features
```

---

**`src/main.server.ts` — Legacy Server Entry Point:**

```typescript
// src/main.server.ts (LEGACY pre-Angular 17 version)
// ← Very different from the modern version!
// ← Exports the NgModule instead of a bootstrap factory

export { AppServerModule as default } from './app/app.server.module';
// ← Export AppServerModule as the default export
// ← The nguniversal engine expects an NgModule here, not a function
```

---

**Legacy `server.ts` with Express Engine:**

```typescript
// server.ts (LEGACY nguniversal approach)
import 'zone.js/node';

import { ngExpressEngine } from '@nguniversal/express-engine';
// ← The nguniversal Express engine (different from Angular 17's CommonEngine)

import * as express from 'express';
import { join } from 'path';
import { AppServerModule } from './src/main.server';
// ← Import the AppServerModule (NgModule approach)

import { APP_BASE_HREF } from '@angular/common';
import { existsSync } from 'fs';

const app = express();
const distFolder = join(process.cwd(), 'dist/my-app/browser');
const indexHtml = existsSync(join(distFolder, 'index.original.html'))
  ? 'index.original.html'
  : 'index';

// ← Register Angular Universal as the view engine for Express
app.engine('html', ngExpressEngine({
  bootstrap: AppServerModule,
  // ← Tell the engine which NgModule to use for rendering
  // ← In modern Angular 17+, this would be the bootstrap function
}));

app.set('view engine', 'html');
app.set('views', distFolder);

// ← Serve static files
app.get('*.*', express.static(distFolder, { maxAge: '1y' }));

// ← All routes rendered by Angular Universal
app.get('*', (req, res) => {
  res.render(indexHtml, {
    req,
    providers: [
      { provide: APP_BASE_HREF, useValue: req.baseUrl }
    ]
  });
  // ← render() calls the Angular Universal engine
  // ← Engine renders AppServerModule to HTML
  // ← Express sends the HTML response
});

const port = process.env['PORT'] || 4000;
app.listen(port, () => {
  console.log(`Node Express server listening on http://localhost:${port}`);
});
```

---

### Legacy vs Modern Comparison

| Aspect | Legacy (nguniversal) | Modern (Angular 17+) |
|---|---|---|
| Package | `@nguniversal/express-engine` | `@angular/ssr` |
| Architecture | NgModule-based | Standalone components |
| Server module | `AppServerModule` extends `AppModule` | `app.config.server.ts` merges configs |
| Engine | `ngExpressEngine` | `CommonEngine` |
| Entry point | Exports NgModule | Exports bootstrap factory function |
| Hydration | Destructive (rebuilds DOM) | Non-destructive (reuses DOM) |
| Setup command | `ng add @nguniversal/express-engine` | `ng add @angular/ssr` |

---

## 19.5 Hydration

### What Is Hydration?

Hydration is the process of **attaching Angular's JavaScript to the server-rendered HTML**.

When the server sends HTML, it looks perfect on screen — but it's just static HTML. Buttons don't react to clicks, forms don't validate, `(click)` handlers don't fire. The HTML is like a photograph of a car — it looks like a car, but you can't drive it.

Hydration is the moment Angular "brings the photograph to life" — attaching all the event listeners, component instances, and change detection to the already-visible HTML.

---

### ASCII Diagram: Hydration Process

```
HYDRATION PROCESS:
==================

BEFORE HYDRATION (server HTML received):
-----------------------------------------
<div class="product-card">           ← Just HTML, no Angular
  <h2>Nike Air Max</h2>              ← Static text
  <button>Add to Cart</button>       ← Click does NOTHING
</div>

        Angular JS downloads and bootstraps...
                        ↓
DURING HYDRATION (Angular scanning DOM):
-----------------------------------------
<div class="product-card">           ← Angular finds this element
  <h2>Nike Air Max</h2>              ← Matches ProductCardComponent template
  <button>Add to Cart</button>       ← Angular attaches (click)="addToCart()"
</div>

Angular's hydration algorithm:
1. Walks server-rendered DOM
2. Matches DOM nodes to component templates
3. Attaches component instances to existing DOM nodes
4. Binds event listeners
5. Sets up change detection

AFTER HYDRATION (fully interactive):
--------------------------------------
<div class="product-card">           ← ProductCardComponent instance attached
  <h2>Nike Air Max</h2>              ← Two-way bound to component.product.name
  <button (click)="addToCart()">     ← Event handler is LIVE
    Add to Cart
  </button>
</div>
```

---

### Destructive vs Non-Destructive Hydration

**Destructive Hydration (Old Way — Angular 15 and earlier):**

```
1. Server sends HTML (user sees it)
2. Angular boots
3. Angular DESTROYS the server-rendered HTML (flickering!)
4. Angular REBUILDS the DOM from scratch using JavaScript
5. Now interactive

Problem: The "flash" between server HTML and rebuilt HTML
         Unnecessary DOM destruction and recreation
         Extra CPU work
         Layout shift (bad UX)
```

**Non-Destructive Hydration (Angular 16+ — The Right Way):**

```
1. Server sends HTML (user sees it)
2. Angular boots
3. Angular REUSES the existing server-rendered DOM nodes
4. Attaches event listeners and component instances to existing nodes
5. No flickering, no rebuilding

Benefit: Seamless transition
         No layout shift
         Less CPU work
         Better Core Web Vitals scores
```

---

### Enabling Non-Destructive Hydration

```typescript
// src/app/app.config.ts
import { provideClientHydration } from '@angular/platform-browser';
// ← This single function enables non-destructive hydration

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideClientHydration(),
    // ← Add this to enable non-destructive hydration
    // ← Angular 16+ feature
    // ← Without this, Angular uses destructive hydration (old behavior)
    provideHttpClient(withFetch()),
  ]
};
```

---

### Hydration with Event Replay (Angular 18+)

```typescript
// Angular 18+ introduced Event Replay during hydration
// ← User clicks BEFORE hydration completes → events are CAPTURED and REPLAYED after hydration

import { provideClientHydration, withEventReplay } from '@angular/platform-browser';

export const appConfig: ApplicationConfig = {
  providers: [
    provideClientHydration(
      withEventReplay()
      // ← Records user interactions that happen before hydration
      // ← Replays them once hydration completes
      // ← Eliminates the "my click did nothing" problem during hydration
    ),
  ]
};
```

---

### Common Hydration Errors and Fixes

**Error 1: DOM Mismatch**

```
ERROR: NG0500: During hydration Angular expected <div> but found <p>
```

This happens when the server renders different HTML than the client would render. Common causes:

```typescript
// BAD — Hydration mismatch example:
@Component({
  template: `
    <!-- ← This renders different HTML on server vs browser! -->
    <div *ngIf="isBrowser">Browser content</div>
    <div *ngIf="!isBrowser">Server content</div>
  `
})
export class BadComponent {
  isBrowser = typeof window !== 'undefined';
  // ← On server: isBrowser = false → renders "Server content"
  // ← On client: isBrowser = true → renders "Browser content"
  // ← Server HTML and client HTML DON'T MATCH → HYDRATION ERROR!
}

// GOOD — Use ngSkipHydration for components with known mismatches:
@Component({
  template: `
    <div ngSkipHydration>
      <!-- ← Tell Angular to skip hydration for this component -->
      <!-- ← Angular will destroy and rebuild this component's DOM -->
      <!-- ← Use sparingly — defeats purpose of non-destructive hydration -->
      <canvas-chart [data]="chartData"></canvas-chart>
    </div>
  `
})
export class GoodComponent {}
```

---

**Error 2: Server-only code running on client causing mismatch**

```typescript
// BAD — Date/Time causes hydration mismatch:
@Component({
  template: `<p>Current time: {{ currentTime }}</p>`
  // ← Server renders: "Current time: 10:00:01"
  // ← Client renders: "Current time: 10:00:03"  ← MISMATCH!
})
export class BadTimeComponent {
  currentTime = new Date().toLocaleTimeString();
}

// GOOD — Avoid rendering dynamic server-only values in the initial render:
@Component({
  template: `<p>Last updated: {{ lastUpdated }}</p>`
})
export class GoodTimeComponent {
  lastUpdated = '';

  constructor() {
    // ← Set after hydration using afterNextRender
    afterNextRender(() => {
      this.lastUpdated = new Date().toLocaleTimeString();
      // ← Only runs in browser, after hydration — no mismatch
    });
  }
}
```

---

## 19.6 Platform Detection

### The Core Problem: Browser APIs Don't Exist on the Server

Node.js doesn't have `window`, `document`, or `localStorage`. If your Angular code uses them directly, the SSR server will crash:

```
ReferenceError: window is not defined
ReferenceError: document is not defined
ReferenceError: localStorage is not defined
```

The solution: detect which platform you're running on and conditionally execute browser-only code.

---

### isPlatformBrowser() and isPlatformServer()

```typescript
// products.component.ts
import { Component, OnInit, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser, isPlatformServer } from '@angular/common';
// ← isPlatformBrowser returns true only when running in a browser
// ← isPlatformServer returns true only when running in Node.js SSR

@Component({
  selector: 'app-products',
  template: `<div>...</div>`
})
export class ProductsComponent implements OnInit {

  constructor(
    @Inject(PLATFORM_ID) private platformId: Object
    // ← PLATFORM_ID is an Angular injection token
    // ← Its value is 'browser' when in browser, 'server' when in Node.js
    // ← We inject it to check which platform we're on
  ) {}

  ngOnInit(): void {
    if (isPlatformBrowser(this.platformId)) {
      // ← This code block ONLY runs in the browser
      // ← Safe to use window, document, localStorage here
      const scrollY = window.scrollY;
      localStorage.setItem('visited', 'true');
      document.title = 'Products Page';
    }

    if (isPlatformServer(this.platformId)) {
      // ← This code block ONLY runs on the server (during SSR)
      // ← Useful for server-specific initialization
      // ← Example: log server-side metrics, use server-only APIs
      console.log('Rendering products on server');
    }
  }
}
```

---

### afterNextRender() and afterRender() — Angular 16+

Angular 16 introduced lifecycle hooks that ONLY run in the browser, never on the server. This is the modern, preferred approach:

```typescript
// modern-component.component.ts
import { Component, afterNextRender, afterRender } from '@angular/core';
// ← afterNextRender: runs ONCE after the next render cycle completes (in browser only)
// ← afterRender: runs after EVERY render cycle (in browser only)
// ← Neither runs on the server — perfect for browser-only code!

@Component({
  selector: 'app-analytics',
  template: `<div>Analytics loaded</div>`
})
export class AnalyticsComponent {

  constructor() {
    afterNextRender(() => {
      // ← This runs ONCE after the component's first render IN THE BROWSER
      // ← Perfect for:
      //   - Initializing third-party libraries (e.g., Chart.js, Google Maps)
      //   - Reading DOM dimensions (getBoundingClientRect)
      //   - Setting up scroll listeners
      //   - localStorage access
      //   - Analytics initialization

      // ← Safe to use browser APIs here:
      const element = document.getElementById('chart-container');
      // ← document IS defined here — we're guaranteed to be in the browser

      window.analytics?.init({ trackingId: 'UA-12345' });
      // ← window IS defined here

      localStorage.setItem('app-loaded', Date.now().toString());
      // ← localStorage IS defined here
    });

    afterRender(() => {
      // ← This runs after EVERY render (every change detection cycle in browser)
      // ← Use sparingly — it runs very frequently!
      // ← Good for: updating canvas/WebGL based on component state changes
      // ← Avoid heavy computation here
    });
  }
}
```

---

### Handling localStorage Safely

```typescript
// storage.service.ts
// ← A safe wrapper around localStorage that works on both server and browser

import { Injectable, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

@Injectable({ providedIn: 'root' })
export class StorageService {

  private isBrowser: boolean;

  constructor(@Inject(PLATFORM_ID) platformId: Object) {
    this.isBrowser = isPlatformBrowser(platformId);
    // ← Check at construction time — platform doesn't change during app lifetime
    // ← Store as boolean for easy reuse throughout the service
  }

  getItem(key: string): string | null {
    if (!this.isBrowser) {
      return null;
      // ← On server: pretend localStorage is empty
      // ← This prevents crashes and allows server-side rendering to continue
    }
    return localStorage.getItem(key);
    // ← On browser: normal localStorage access
  }

  setItem(key: string, value: string): void {
    if (!this.isBrowser) {
      return;
      // ← On server: ignore localStorage writes (nothing to save)
    }
    localStorage.setItem(key, value);
  }

  removeItem(key: string): void {
    if (!this.isBrowser) return;
    // ← Guard pattern: early return if not browser
    localStorage.removeItem(key);
  }

  clear(): void {
    if (!this.isBrowser) return;
    localStorage.clear();
  }
}
```

---

### Handling window.scroll and DOM Manipulation

```typescript
// scroll-tracker.component.ts
import { Component, OnInit, OnDestroy, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

@Component({
  selector: 'app-scroll-tracker',
  template: `<div class="scroll-tracker">Scroll: {{ scrollY }}px</div>`
})
export class ScrollTrackerComponent implements OnInit, OnDestroy {

  scrollY = 0;
  private scrollListener?: () => void;
  // ← Store reference to listener so we can remove it on destroy

  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  ngOnInit(): void {
    if (isPlatformBrowser(this.platformId)) {
      // ← ONLY set up window listeners in browser
      // ← On server: window doesn't exist, this would crash

      this.scrollListener = () => {
        this.scrollY = window.scrollY;
        // ← Read scroll position from window
      };

      window.addEventListener('scroll', this.scrollListener);
      // ← Attach scroll listener to window
    }
  }

  ngOnDestroy(): void {
    if (isPlatformBrowser(this.platformId) && this.scrollListener) {
      window.removeEventListener('scroll', this.scrollListener);
      // ← CRITICAL: Remove listener to prevent memory leaks
      // ← Without this, even after component destroys, the listener persists
    }
  }
}
```

---

### Platform Detection Decision Guide

```
SHOULD I USE PLATFORM DETECTION?
==================================

Does your code use browser-specific APIs?
    ├── window.*          → YES, guard with isPlatformBrowser()
    ├── document.*        → YES, guard with isPlatformBrowser()
    ├── localStorage.*    → YES, guard with isPlatformBrowser()
    ├── sessionStorage.*  → YES, guard with isPlatformBrowser()
    ├── navigator.*       → YES, guard with isPlatformBrowser()
    ├── history.*         → YES, guard with isPlatformBrowser()
    └── setTimeout/setInterval for UI → CAREFUL (see section 19.12)

Is this browser-only initialization (third-party libs)?
    → Use afterNextRender() — cleaner than PLATFORM_ID check

Does it need to work differently on server for SEO?
    → Use isPlatformServer() for server-specific logic

Is it a service that wraps browser APIs?
    → Create a service with isPlatformBrowser() guard (like StorageService above)
    → Inject the service everywhere instead of checking platform repeatedly
```

---

## 19.7 TransferState — Avoiding Duplicate HTTP Calls

### The Problem: Double Data Fetching

Without TransferState, here's what happens with SSR:

```
WITHOUT TRANSFERSTATE:
========================

1. Browser requests /products
2. Server-side Angular runs → calls GET /api/products → gets 50 products
3. Server renders beautiful HTML with all 50 products
4. HTML is sent to browser
5. Browser displays the products (great!)
6. Browser downloads main.js
7. Angular bootstraps in browser
8. ngOnInit() runs → calls GET /api/products AGAIN → gets same 50 products
9. Angular re-renders with the SAME data (redundant!)

Problems:
- 2 HTTP calls instead of 1 (wasted bandwidth, slower)
- Brief flash as Angular re-renders
- Server load doubled
```

**TransferState solves this by embedding server-fetched data into the HTML, then reading it on the client:**

```
WITH TRANSFERSTATE:
====================

1. Browser requests /products
2. Server-side Angular runs → calls GET /api/products → gets 50 products
3. Server STORES products in TransferState (embedded in HTML as JSON)
4. Server renders HTML with all 50 products
5. HTML (with embedded data JSON) is sent to browser
6. Browser displays the products
7. Browser downloads main.js
8. Angular bootstraps in browser
9. ngOnInit() checks TransferState FIRST → finds data! → SKIPS API call
10. Uses existing data — no duplicate request!

Result: 1 HTTP call, no duplication
```

---

### ASCII Diagram: TransferState Flow

```
TRANSFERSTATE FLOW:
====================

  SERVER SIDE                          CLIENT SIDE
  ===========                          ===========

  products.service.ts                  products.service.ts
       |                                    |
  [check TransferState]               [check TransferState]
       |                                    |
   not found                           FOUND! (from server)
       |                                    |
  [fetch from API]                   [use cached data]
       |                                    |
  [store in TransferState]            [remove from cache]
       |
  [render HTML]
       |
       v
  <script id="serverApp"...>
    {"products_key": [...50 products...]}
  </script>
                     ↑ embedded in HTML ↑
                     This travels to client
                     Client reads it on bootstrap
```

---

### Implementing TransferState

**Set up HTTP with TransferState (Angular 17+ way):**

```typescript
// src/app/app.config.ts
import { provideHttpClient, withFetch } from '@angular/common/http';
// ← withFetch is needed for SSR-compatible HTTP

export const appConfig: ApplicationConfig = {
  providers: [
    provideClientHydration(),   // ← Required for hydration
    provideHttpClient(withFetch()),
    // ← withFetch() uses the Fetch API
    // ← The Angular SSR engine automatically caches HTTP calls
    // ← and transfers them via TransferState when you use withFetch()
    // ← This is the AUTOMATIC way — no manual TransferState needed!
  ]
};
```

**The automatic way (Angular 17+, recommended):**

```typescript
// products.service.ts
// ← When you use provideHttpClient(withFetch()), Angular AUTOMATICALLY:
//   - Caches HTTP calls made during SSR
//   - Transfers the cache to the browser
//   - Reuses cached responses instead of making duplicate calls
// ← No manual TransferState code needed!

import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Product } from './product.model';

@Injectable({ providedIn: 'root' })
export class ProductsService {

  constructor(private http: HttpClient) {}

  getProducts(): Observable<Product[]> {
    return this.http.get<Product[]>('/api/products');
    // ← Angular SSR with withFetch() automatically handles TransferState
    // ← Server makes this call, caches the result
    // ← Browser sees the cache, skips the call
    // ← Looks like a normal HTTP call — SSR magic happens automatically!
  }
}
```

---

**The manual way (Angular 15–16, or for custom caching needs):**

```typescript
// products.service.ts — Manual TransferState approach
import { Injectable, Inject, PLATFORM_ID, TransferState, makeStateKey } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { tap } from 'rxjs/operators';
import { isPlatformBrowser } from '@angular/common';
import { Product } from './product.model';

// ← Create a unique key for storing products in TransferState
// ← makeStateKey creates a typed key for type-safe TransferState access
const PRODUCTS_KEY = makeStateKey<Product[]>('products');
// ← 'products' is the string key used to store/retrieve data
// ← Product[] is the TypeScript type of the data

@Injectable({ providedIn: 'root' })
export class ProductsService {

  constructor(
    private http: HttpClient,
    private transferState: TransferState,
    // ← Inject TransferState service
    // ← Angular provides this automatically for SSR apps
    @Inject(PLATFORM_ID) private platformId: Object
  ) {}

  getProducts(): Observable<Product[]> {
    // ← Check if data was already fetched on server and transferred:
    if (this.transferState.hasKey(PRODUCTS_KEY)) {
      // ← TransferState HAS the data (we're in browser after SSR)
      const products = this.transferState.get(PRODUCTS_KEY, []);
      // ← Retrieve the data from TransferState
      // ← Second argument ([]) is the default value if key doesn't exist

      this.transferState.remove(PRODUCTS_KEY);
      // ← IMPORTANT: Remove from TransferState after use
      // ← Keeps memory clean — data is only needed once

      return of(products);
      // ← Return as Observable without making HTTP call
    }

    // ← No cached data found — either we're on server OR data wasn't cached
    return this.http.get<Product[]>('/api/products').pipe(
      tap((products) => {
        if (isPlatformServer(this.platformId)) {
          // ← ONLY store in TransferState when on server
          // ← On server: store data so it travels to browser
          this.transferState.set(PRODUCTS_KEY, products);
          // ← This data will be embedded in the HTML response
          // ← Browser will find it when Angular bootstraps
        }
      })
    );
  }
}
```

---

## 19.8 Pre-rendering (Static Site Generation)

### What is Pre-rendering?

Pre-rendering generates static HTML files at **build time** rather than at request time. The result is a set of HTML files that can be served directly without a Node.js server.

```
PRE-RENDERING (SSG) FLOW:
==========================

  BUILD TIME:
  -----------
  ng build --prerender
       |
  Angular runs on Node.js
       |
  Visits every configured route
       |
  /               → generates index.html
  /about          → generates about/index.html
  /products       → generates products/index.html
  /products/1     → generates products/1/index.html
  /products/2     → generates products/2/index.html
       |
  Static HTML files saved to dist/

  SERVE TIME:
  -----------
  User requests /products/1
       |
  Web server returns products/1/index.html
       |
  No Node.js, no server-side rendering
  Just a static file server (CDN, S3, Netlify, etc.)
```

---

### Configuring Pre-rendering in Angular 17+

```json
// angular.json
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "options": {
            "prerender": {
              "routesFile": "routes.txt"
            }
          }
        }
      }
    }
  }
}
```

```
// routes.txt — List all routes to pre-render
/
/about
/contact
/products
/products/1
/products/2
/products/3
/blog
/blog/angular-ssr-guide
/blog/typescript-best-practices
```

---

### Pre-rendering Dynamic Routes

```typescript
// app.routes.ts — Configure routes with SSG support
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'blog/:slug',
    component: BlogPostComponent,
    // ← Angular CLI can discover dynamic routes if you provide a function
  }
];
```

```typescript
// In angular.json, you can specify a routesFile or use the routes config:
// For Angular 17+, Angular SSR can automatically discover static routes
// For dynamic routes (/blog/:slug), you need to list them explicitly

// Or programmatically via a custom build script:
// generate-routes.ts
import { writeFileSync } from 'fs';

const posts = await fetch('https://api.example.com/posts').then(r => r.json());
const routes = [
  '/',
  '/about',
  '/blog',
  ...posts.map((p: any) => `/blog/${p.slug}`),
  // ← Generate a route for each blog post
];

writeFileSync('routes.txt', routes.join('\n'));
// ← Write routes.txt that angular.json references
```

---

### SSR vs SSG Decision Guide

| Criteria | Use SSR | Use SSG |
|---|---|---|
| Content changes frequently | Yes — real-time data | No — requires rebuild |
| Content is user-specific | Yes — personalized pages | No — same HTML for all |
| Traffic volume | High — server can be bottleneck | Any — CDN handles it |
| Server cost | Higher — always-on Node.js | Lower — just static hosting |
| SEO needed | Yes — works perfectly | Yes — works perfectly |
| Social previews needed | Yes — works perfectly | Yes — works perfectly |
| Build time | Fast — no pre-rendering | Slower — pre-renders all pages |
| Good examples | E-commerce, news, social | Blogs, docs, marketing sites |
| Hosting | Node.js server, Docker | S3, Netlify, Vercel, CDN |

---

### When to Use Each Rendering Strategy

```
RENDERING STRATEGY DECISION TREE:
===================================

Does the page need user-specific content?
├── YES → CSR (behind login, dashboard, admin)
│         OR SSR with authentication
└── NO
    │
    Does the content change frequently? (more than once/day)
    ├── YES → SSR (real-time content, live prices, etc.)
    └── NO
        │
        Is the content truly static? (docs, blog posts)
        ├── YES → SSG (pre-render at build time)
        └── SOMETIMES → SSR with caching OR ISR
```

---

## 19.9 SEO Optimization with SSR

### Meta Service — Dynamic Meta Tags

```typescript
// blog-post.component.ts
// ← Complete example of dynamic SEO meta tags for a blog post page

import { Component, OnInit } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
// ← Meta service: add/update/remove <meta> tags dynamically
// ← Title service: update the <title> element

import { ActivatedRoute } from '@angular/router';
import { BlogService } from '../blog.service';
import { BlogPost } from '../models/blog-post.model';

@Component({
  selector: 'app-blog-post',
  templateUrl: './blog-post.component.html',
})
export class BlogPostComponent implements OnInit {

  post?: BlogPost;

  constructor(
    private meta: Meta,         // ← Inject Meta service
    private titleService: Title, // ← Inject Title service
    private route: ActivatedRoute,
    private blogService: BlogService,
  ) {}

  ngOnInit(): void {
    const slug = this.route.snapshot.paramMap.get('slug')!;
    // ← Get blog post slug from URL params

    this.blogService.getPost(slug).subscribe((post) => {
      this.post = post;
      this.updateMetaTags(post);
      // ← Update meta tags once post data is loaded
    });
  }

  private updateMetaTags(post: BlogPost): void {
    // ← Update the page title
    this.titleService.setTitle(`${post.title} | My Blog`);
    // ← Format: "Article Title | Site Name" — best practice for SEO

    // ← Standard SEO meta tags
    this.meta.updateTag({ name: 'description', content: post.excerpt });
    // ← updateTag: updates existing tag OR creates it if it doesn't exist
    // ← description: shown in Google search results under the title

    this.meta.updateTag({ name: 'keywords', content: post.tags.join(', ') });
    // ← keywords: less important for modern SEO but doesn't hurt

    // ← Open Graph tags (Facebook, LinkedIn, Slack previews)
    this.meta.updateTag({ property: 'og:title', content: post.title });
    // ← Note: OG tags use 'property' not 'name' — common mistake!

    this.meta.updateTag({ property: 'og:description', content: post.excerpt });

    this.meta.updateTag({
      property: 'og:image',
      content: `https://myblog.com${post.heroImageUrl}`
      // ← Use absolute URL for OG image — relative URLs don't work in social cards
    });

    this.meta.updateTag({ property: 'og:url', content: `https://myblog.com/blog/${post.slug}` });
    // ← Canonical URL for the Open Graph

    this.meta.updateTag({ property: 'og:type', content: 'article' });
    // ← Type: website, article, product, etc.

    this.meta.updateTag({ property: 'og:site_name', content: 'My Blog' });

    // ← Twitter Card tags (Twitter/X uses these, not OG tags)
    this.meta.updateTag({ name: 'twitter:card', content: 'summary_large_image' });
    // ← summary_large_image: big image preview; summary: small image; player: video

    this.meta.updateTag({ name: 'twitter:title', content: post.title });
    this.meta.updateTag({ name: 'twitter:description', content: post.excerpt });
    this.meta.updateTag({
      name: 'twitter:image',
      content: `https://myblog.com${post.heroImageUrl}`
    });
    this.meta.updateTag({ name: 'twitter:site', content: '@myblog' });
    // ← Your Twitter/X handle

    // ← Canonical URL (prevents duplicate content penalty)
    this.meta.updateTag({
      rel: 'canonical',
      href: `https://myblog.com/blog/${post.slug}`
    });
    // ← Tells search engines: "this is the authoritative URL for this content"
  }

  ngOnDestroy(): void {
    // ← IMPORTANT: Remove tags when leaving the page
    // ← Without cleanup, old meta tags remain for the next page
    this.meta.removeTag('name="description"');
    this.meta.removeTag('name="keywords"');
    this.meta.removeTag('property="og:title"');
    this.meta.removeTag('property="og:description"');
    this.meta.removeTag('property="og:image"');
    // ← Or use addTag with updateTag strategy instead for cleaner approach
  }
}
```

---

### Structured Data (JSON-LD) for Rich Search Results

```typescript
// blog-post.component.ts — Adding JSON-LD structured data
import { Component, OnInit, Renderer2, Inject } from '@angular/core';
import { DOCUMENT } from '@angular/common';
// ← DOCUMENT token gives access to the DOM document safely (works on server too!)

@Component({ selector: 'app-blog-post', templateUrl: './blog-post.component.html' })
export class BlogPostComponent implements OnInit {

  constructor(
    private renderer: Renderer2,
    // ← Renderer2: Angular's safe abstraction for DOM manipulation
    // ← Always use Renderer2 instead of document.createElement directly
    // ← Renderer2 works in both browser and server environments

    @Inject(DOCUMENT) private document: Document
    // ← DOCUMENT token: Angular's way to access the document object
    // ← Works in both browser and SSR server environments
  ) {}

  private addStructuredData(post: BlogPost): void {
    // ← JSON-LD structured data helps search engines understand your content
    // ← Enables Rich Results (breadcrumbs, star ratings, etc.) in Google

    const script = this.renderer.createElement('script');
    // ← Use Renderer2.createElement for SSR-safe DOM manipulation

    this.renderer.setAttribute(script, 'type', 'application/ld+json');
    // ← Set type to application/ld+json — tells browser this is structured data

    const structuredData = {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',          // ← Schema.org type for blog posts
      'headline': post.title,
      'description': post.excerpt,
      'image': `https://myblog.com${post.heroImageUrl}`,
      'author': {
        '@type': 'Person',
        'name': post.author.name,
        'url': `https://myblog.com/authors/${post.author.slug}`
      },
      'publisher': {
        '@type': 'Organization',
        'name': 'My Blog',
        'logo': {
          '@type': 'ImageObject',
          'url': 'https://myblog.com/logo.png'
        }
      },
      'datePublished': post.publishedAt,
      'dateModified': post.updatedAt,
      'mainEntityOfPage': {
        '@type': 'WebPage',
        '@id': `https://myblog.com/blog/${post.slug}`
      }
    };

    this.renderer.setProperty(
      script,
      'textContent',
      JSON.stringify(structuredData)
      // ← Embed the JSON-LD in the script tag
    );

    this.renderer.appendChild(this.document.head, script);
    // ← Append to <head> — where structured data should live
  }
}
```

---

### SEO Service — Reusable Meta Tag Management

```typescript
// seo.service.ts — Centralized SEO management service

import { Injectable, Inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { DOCUMENT } from '@angular/common';
import { Router } from '@angular/router';

export interface SeoConfig {
  title: string;
  description: string;
  image?: string;
  type?: 'website' | 'article' | 'product';
  canonicalUrl?: string;
  noIndex?: boolean;  // ← For pages you DON'T want indexed (e.g., /admin)
}

@Injectable({ providedIn: 'root' })
export class SeoService {

  private readonly siteUrl = 'https://myapp.com';
  private readonly siteName = 'My App';
  private readonly defaultImage = `${this.siteUrl}/assets/og-default.jpg`;

  constructor(
    private meta: Meta,
    private titleService: Title,
    @Inject(DOCUMENT) private document: Document,
    private router: Router,
  ) {}

  updateSeo(config: SeoConfig): void {
    const fullTitle = `${config.title} | ${this.siteName}`;
    // ← Format: "Page Title | Site Name"

    const canonicalUrl = config.canonicalUrl
      || `${this.siteUrl}${this.router.url}`;
    // ← Default canonical URL uses current route

    const imageUrl = config.image || this.defaultImage;

    // ← Update basic meta
    this.titleService.setTitle(fullTitle);
    this.updateTag('description', config.description);

    // ← Update Open Graph
    this.updateProperty('og:title', fullTitle);
    this.updateProperty('og:description', config.description);
    this.updateProperty('og:image', imageUrl);
    this.updateProperty('og:url', canonicalUrl);
    this.updateProperty('og:type', config.type || 'website');
    this.updateProperty('og:site_name', this.siteName);

    // ← Update Twitter Card
    this.updateTag('twitter:card', 'summary_large_image');
    this.updateTag('twitter:title', fullTitle);
    this.updateTag('twitter:description', config.description);
    this.updateTag('twitter:image', imageUrl);

    // ← Handle noIndex pages (login, admin, etc.)
    if (config.noIndex) {
      this.updateTag('robots', 'noindex, nofollow');
      // ← Tell search engines to NOT index this page
    } else {
      this.updateTag('robots', 'index, follow');
      // ← Default: allow indexing
    }

    // ← Update canonical link element
    this.updateCanonicalUrl(canonicalUrl);
  }

  private updateTag(name: string, content: string): void {
    this.meta.updateTag({ name, content });
  }

  private updateProperty(property: string, content: string): void {
    this.meta.updateTag({ property, content });
  }

  private updateCanonicalUrl(url: string): void {
    // ← Find existing canonical link element or create one
    let link: HTMLLinkElement = this.document.querySelector('link[rel="canonical"]')!;

    if (!link) {
      link = this.document.createElement('link');
      link.setAttribute('rel', 'canonical');
      this.document.head.appendChild(link);
    }

    link.setAttribute('href', url);
  }
}
```

---

## 19.10 Performance Optimization for SSR

### Caching Strategies for SSR

Without caching, every request renders the Angular app from scratch — expensive for high-traffic sites.

```typescript
// server.ts — Adding in-memory page-level caching to Express

import express from 'express';
import { CommonEngine } from '@angular/ssr';

// ← Simple in-memory cache using a Map
// ← For production, use Redis (see below)
const pageCache = new Map<string, { html: string; timestamp: number }>();
const CACHE_TTL = 5 * 60 * 1000;  // ← 5 minutes in milliseconds

function getCachedPage(url: string): string | null {
  const cached = pageCache.get(url);
  if (!cached) return null;

  const isExpired = Date.now() - cached.timestamp > CACHE_TTL;
  if (isExpired) {
    pageCache.delete(url);
    // ← Remove expired cache entry
    return null;
  }

  return cached.html;
  // ← Return cached HTML
}

function cachePage(url: string, html: string): void {
  pageCache.set(url, { html, timestamp: Date.now() });
  // ← Store rendered HTML with timestamp
}

// ← In your Express handler:
server.get('*', async (req, res, next) => {
  const url = req.url;

  // ← Check cache first
  const cachedHtml = getCachedPage(url);
  if (cachedHtml) {
    res.setHeader('X-Cache', 'HIT');
    // ← Useful for debugging — shows this was served from cache
    res.setHeader('Cache-Control', 'public, max-age=300');
    // ← Tell CDNs they can cache this response for 5 minutes
    return res.send(cachedHtml);
  }

  // ← Not in cache — render with Angular
  try {
    const html = await commonEngine.render({ bootstrap, url: `...${url}` });

    cachePage(url, html);
    // ← Cache the rendered result

    res.setHeader('X-Cache', 'MISS');
    res.setHeader('Cache-Control', 'public, max-age=300');
    res.send(html);
  } catch (err) {
    next(err);
  }
});
```

---

### Redis Caching for Production

```typescript
// redis-cache.service.ts
// ← For production, use Redis instead of in-memory Map
// ← Redis survives server restarts and works across multiple instances

import { createClient } from 'redis';

const redis = createClient({ url: process.env['REDIS_URL'] });
// ← Connect to Redis instance (local or managed like AWS ElastiCache)

await redis.connect();

async function getCachedPage(url: string): Promise<string | null> {
  const cached = await redis.get(`page:${url}`);
  // ← Redis GET — returns null if key doesn't exist or expired
  return cached;
}

async function cachePage(url: string, html: string, ttl = 300): Promise<void> {
  await redis.setEx(`page:${url}`, ttl, html);
  // ← setEx = SET with EXpiration
  // ← key: 'page:/products/123'
  // ← ttl: 300 seconds (5 minutes)
  // ← html: rendered HTML string
}

// ← Cache invalidation: when content changes, clear the cache
async function invalidatePage(url: string): Promise<void> {
  await redis.del(`page:${url}`);
}

async function invalidateAll(): Promise<void> {
  const keys = await redis.keys('page:*');
  // ← Find all cached page keys
  if (keys.length > 0) {
    await redis.del(keys);
    // ← Delete all cached pages at once
  }
}
```

---

### Cache-Control Headers for CDN Caching

```typescript
// server.ts — Setting appropriate Cache-Control headers
server.get('*', (req, res, next) => {
  commonEngine.render({ ... }).then((html) => {

    // ← Different caching strategies for different content types:

    if (req.url.startsWith('/api/')) {
      // ← API responses: no caching (always fresh data)
      res.setHeader('Cache-Control', 'no-store, no-cache');
    } else if (req.url === '/' || req.url === '/about') {
      // ← Homepage/static pages: cache for 10 minutes
      // ← public: CDNs can cache; max-age: seconds; s-maxage: CDN-specific TTL
      res.setHeader('Cache-Control', 'public, max-age=600, s-maxage=600, stale-while-revalidate=60');
      // ← stale-while-revalidate: serve stale content while fetching fresh copy in background
    } else if (req.url.startsWith('/blog/')) {
      // ← Blog posts: cache for 1 hour (content doesn't change often)
      res.setHeader('Cache-Control', 'public, max-age=3600, s-maxage=3600');
    } else if (req.url.startsWith('/user/')) {
      // ← User-specific pages: never cache publicly
      res.setHeader('Cache-Control', 'private, no-cache');
    }

    res.send(html);
  }).catch(next);
});
```

---

### Avoiding Long-Running Operations on Server

```typescript
// BAD — Heavy computation blocks the SSR thread:
@Component({...})
export class BadProductListComponent implements OnInit {
  products: Product[] = [];

  ngOnInit() {
    // ← This runs synchronously on every SSR request!
    // ← If this takes 500ms, every user waits 500ms
    this.products = this.computeExpensiveRecommendations();
    // ← Heavy computation on server = slow TTFB for ALL users
  }

  computeExpensiveRecommendations(): Product[] {
    // ← O(n²) algorithm running on server for every request
    return heavyComputation();
  }
}

// GOOD — Defer heavy work to the browser:
@Component({...})
export class GoodProductListComponent implements OnInit {
  products: Product[] = [];
  recommendations: Product[] = [];

  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  ngOnInit() {
    // ← Always fetch main content (needed for SSR/SEO)
    this.productService.getProducts().subscribe(p => this.products = p);
  }

  ngAfterViewInit() {
    if (isPlatformBrowser(this.platformId)) {
      // ← Defer heavy work to browser — runs after SSR response is sent
      // ← User sees the page quickly, then recommendations load
      setTimeout(() => {
        this.recommendations = this.computeExpensiveRecommendations();
      }, 0);
      // ← Even setTimeout(0) moves work out of the critical render path
    }
  }
}
```

---

## 19.11 Deployment

### Deploying to Node.js Server

```bash
# ← Step 1: Build the application
npm run build
# ← Creates:
#   dist/my-app/browser/    (client-side bundles)
#   dist/my-app/server/     (server bundle + server.mjs)

# ← Step 2: Start the server
node dist/my-app/server/server.mjs

# ← Or with PM2 for production process management:
pm2 start dist/my-app/server/server.mjs --name "my-app"
pm2 save         # ← Save PM2 process list
pm2 startup      # ← Make PM2 start on system boot
```

---

### PM2 Ecosystem File

```javascript
// ecosystem.config.js — PM2 configuration
module.exports = {
  apps: [{
    name: 'angular-ssr-app',
    script: './dist/my-app/server/server.mjs',
    // ← Path to compiled server

    instances: 'max',
    // ← Use all available CPU cores
    // ← PM2 creates one process per CPU core (cluster mode)

    exec_mode: 'cluster',
    // ← Cluster mode: multiple Node.js processes sharing the same port
    // ← Dramatically improves throughput for CPU-bound SSR

    env_production: {
      NODE_ENV: 'production',
      PORT: 4000,
      REDIS_URL: 'redis://localhost:6379',
    },

    max_memory_restart: '500M',
    // ← Restart if process uses more than 500MB
    // ← Prevents memory leaks from crashing the server

    error_file: '/var/log/my-app/error.log',
    out_file: '/var/log/my-app/out.log',
    // ← Log file locations for debugging
  }]
};

// ← Start with: pm2 start ecosystem.config.js --env production
```

---

### Docker Container for Angular SSR

```dockerfile
# Dockerfile
# ← Multi-stage build: separate build stage from runtime stage
# ← This keeps the final image small (no dev dependencies)

# Stage 1: Build
FROM node:20-alpine AS builder
# ← Use Alpine Linux for smaller image size
# ← Node 20 LTS for stability

WORKDIR /app
# ← Set working directory inside container

COPY package*.json ./
# ← Copy package files first (for layer caching)
# ← If package.json doesn't change, npm install layer is cached

RUN npm ci --only=production
# ← ci = clean install (faster, more reliable than npm install in CI)
# ← --only=production skips devDependencies... wait, we need build tools
# ← Actually for build stage, install ALL dependencies:

RUN npm ci
# ← Install all dependencies including devDependencies for build

COPY . .
# ← Copy source code

RUN npm run build
# ← Build the Angular app (both browser and server bundles)

# Stage 2: Runtime
FROM node:20-alpine AS runner
# ← Fresh, clean image — no build tools, no source code, no dev dependencies

WORKDIR /app

COPY --from=builder /app/dist ./dist
# ← Copy ONLY the built output from builder stage
# ← dist/ contains browser bundle + server bundle

COPY --from=builder /app/package*.json ./
# ← Copy package files for production dependencies

RUN npm ci --only=production
# ← Install ONLY production dependencies (express, zone.js, etc.)
# ← No Angular CLI, TypeScript, etc. — keeps image small

ENV NODE_ENV=production
ENV PORT=4000
# ← Set environment variables

EXPOSE 4000
# ← Document which port the app uses
# ← Doesn't actually open the port — just metadata

CMD ["node", "dist/my-app/server/server.mjs"]
# ← Start the SSR server
```

```bash
# Build and run the Docker container:
docker build -t my-angular-ssr-app .
docker run -p 4000:4000 -e REDIS_URL=redis://redis:6379 my-angular-ssr-app

# Or with Docker Compose:
# docker-compose up -d
```

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "4000:4000"
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped
    # ← Auto-restart if the container crashes

  redis:
    image: redis:7-alpine
    # ← Redis for page caching
    volumes:
      - redis-data:/data
    restart: unless-stopped

volumes:
  redis-data:
    # ← Persist Redis data across container restarts
```

---

### Firebase Hosting with Cloud Functions

```bash
# ← Firebase is great for Angular SSR because:
#   - Firebase Hosting serves static files (browser bundle) from CDN
#   - Cloud Functions handles SSR requests (Node.js)
#   - Automatic SSL, global CDN, easy deployments

npm install -g firebase-tools
firebase login
firebase init
# ← Select: Hosting + Functions
# ← Public directory: dist/my-app/browser
# ← Configure as SPA: NO (SSR handles routing)
# ← Set up automatic builds: Yes
```

```javascript
// functions/index.js — Firebase Cloud Function for SSR
const functions = require('firebase-functions');
const { app } = require('./dist/my-app/server/server.mjs');
// ← Import your Express app from the compiled server

exports.ssr = functions.https.onRequest(app);
// ← Expose the Express app as a Firebase Cloud Function
// ← Firebase routes all non-static requests to this function
```

---

### Vercel Deployment

```json
// vercel.json — Vercel configuration for Angular SSR
{
  "builds": [
    {
      "src": "dist/my-app/server/server.mjs",
      "use": "@vercel/node"
    },
    {
      "src": "dist/my-app/browser/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*\\..*)",
      "dest": "/dist/my-app/browser/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/dist/my-app/server/server.mjs"
    }
  ]
}
```

---

## 19.12 Common Pitfalls & Solutions

### The Complete SSR Pitfalls Reference Table

| Error | Cause | Solution |
|---|---|---|
| `window is not defined` | Accessing `window` object on server | Use `isPlatformBrowser()` or `afterNextRender()` |
| `document is not defined` | Accessing `document` on server | Use `DOCUMENT` token or `Renderer2` |
| `localStorage is not defined` | Accessing localStorage on server | Create a `StorageService` with platform check |
| `navigator is not defined` | Accessing `navigator` on server | Guard with `isPlatformBrowser()` |
| Memory leaks on server | `setInterval` never cleared | Always clear intervals in `ngOnDestroy` |
| Third-party lib crashes | Library accesses `window` on import | Use dynamic `import()` inside `isPlatformBrowser()` |
| Hydration mismatch | Server/client render different HTML | Use `ngSkipHydration` or fix the difference |
| Infinite redirect loop | Auth guard redirects before data loads | Use `ResolveFn` to pre-fetch before navigation |
| Slow SSR responses | No caching, heavy computation on server | Add Redis cache, move computation to browser |
| Cookie not available | Cookie parsing not set up in Express | Add `cookie-parser` middleware |

---

### Each Pitfall with Fix

**Pitfall 1: window is not defined**

```typescript
// BAD — crashes on server:
@Component({ template: `<div>{{ windowWidth }}</div>` })
export class BadComponent {
  windowWidth = window.innerWidth;
  // ← ReferenceError: window is not defined (on server)
}

// GOOD — safe version:
@Component({ template: `<div>{{ windowWidth }}</div>` })
export class GoodComponent {
  windowWidth = 0;
  // ← Default value for server render

  constructor() {
    afterNextRender(() => {
      this.windowWidth = window.innerWidth;
      // ← Only runs in browser — window is guaranteed to exist here
    });
  }
}
```

---

**Pitfall 2: Third-Party Libraries That Assume Browser**

```typescript
// PROBLEM: Some npm packages crash when imported on server
// They do things like: const canvas = document.createElement('canvas')
// at module load time

// BAD — importing a browser-only library normally:
import * as Chart from 'chart.js';
// ← If chart.js accesses window/document at module load, this CRASHES on server

// GOOD — Dynamic import inside browser-only code:
@Component({...})
export class ChartComponent {
  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  async ngAfterViewInit() {
    if (isPlatformBrowser(this.platformId)) {
      // ← Only import (and run) Chart.js in the browser
      const { Chart, registerables } = await import('chart.js');
      // ← Dynamic import() — the module is NOT loaded on server
      Chart.register(...registerables);

      const ctx = document.getElementById('myChart') as HTMLCanvasElement;
      new Chart(ctx, { type: 'bar', data: this.chartData });
    }
  }
}
```

---

**Pitfall 3: setTimeout/setInterval Memory Leaks on Server**

```typescript
// PROBLEM: On the server, each SSR request creates a new Angular instance
// If you set up intervals in the constructor/ngOnInit without cleanup,
// those intervals keep running after the request is done = MEMORY LEAK

// BAD — Memory leak:
@Component({ template: `{{ currentTime }}` })
export class BadTimerComponent implements OnInit {
  currentTime = '';

  ngOnInit() {
    setInterval(() => {
      this.currentTime = new Date().toLocaleTimeString();
      // ← This interval runs FOREVER on the server
      // ← Each SSR request creates another interval that never stops
    }, 1000);
  }
}

// GOOD — Clean version:
@Component({ template: `{{ currentTime }}` })
export class GoodTimerComponent implements OnDestroy {
  currentTime = '';
  private intervalId?: ReturnType<typeof setInterval>;

  constructor(@Inject(PLATFORM_ID) private platformId: Object) {}

  ngOnInit() {
    if (isPlatformBrowser(this.platformId)) {
      // ← Only run timers in browser — no timers on server!
      this.intervalId = setInterval(() => {
        this.currentTime = new Date().toLocaleTimeString();
      }, 1000);
    }
  }

  ngOnDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      // ← Always clear intervals on component destroy
    }
  }
}
```

---

**Pitfall 4: Cookies in SSR**

```typescript
// PROBLEM: req.cookies not available without cookie-parser middleware

// server.ts — Add cookie-parser:
import cookieParser from 'cookie-parser';
server.use(cookieParser());
// ← Now req.cookies is available in Express handlers

// ← Pass cookies to Angular as a REQUEST token:
import { REQUEST } from '@angular/ssr/tokens';
// ← Angular SSR provides REQUEST and RESPONSE tokens

server.get('*', (req, res, next) => {
  commonEngine.render({
    bootstrap,
    url: `...`,
    providers: [
      { provide: REQUEST, useValue: req },
      // ← Now Angular components can inject REQUEST to access cookies
      { provide: RESPONSE, useValue: res },
    ],
  }).then(html => res.send(html)).catch(next);
});

// ← In an Angular service:
@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(
    @Optional() @Inject(REQUEST) private request: Request | null,
    @Inject(PLATFORM_ID) private platformId: Object,
  ) {}

  getAuthToken(): string | null {
    if (isPlatformBrowser(this.platformId)) {
      return localStorage.getItem('auth_token');
    }
    // ← On server: read from cookies (injected via REQUEST token)
    return this.request?.cookies?.['auth_token'] ?? null;
  }
}
```

---

## 19.13 Practical Example — SSR Blog with SEO

### Project Structure

```
blog-app/
├── src/
│   ├── app/
│   │   ├── app.component.ts
│   │   ├── app.config.ts           ← provideClientHydration, provideHttpClient(withFetch)
│   │   ├── app.config.server.ts    ← mergeApplicationConfig with provideServerRendering
│   │   ├── app.routes.ts           ← Blog routes
│   │   ├── core/
│   │   │   └── seo.service.ts      ← Reusable SEO service
│   │   ├── blog/
│   │   │   ├── blog-list/
│   │   │   │   └── blog-list.component.ts  ← List of posts
│   │   │   └── blog-post/
│   │   │       └── blog-post.component.ts  ← Individual post
│   │   └── shared/
│   │       └── storage.service.ts  ← SSR-safe localStorage
│   ├── main.ts
│   └── main.server.ts
└── server.ts
```

---

### App Configuration

```typescript
// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideClientHydration, withEventReplay } from '@angular/platform-browser';
import { provideHttpClient, withFetch } from '@angular/common/http';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(
      routes,
      withComponentInputBinding()
      // ← Route params automatically bind to component inputs
      // ← @Input() slug maps to /blog/:slug param
    ),
    provideClientHydration(
      withEventReplay()
      // ← Angular 18+: capture clicks during hydration, replay after
    ),
    provideHttpClient(
      withFetch()
      // ← Works on both browser and server
      // ← Automatic TransferState integration
    ),
  ]
};
```

---

### App Routes

```typescript
// src/app/app.routes.ts
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./blog/blog-list/blog-list.component')
      .then(m => m.BlogListComponent),
    // ← Lazy-loaded: blog list is code-split to its own chunk
    title: 'Blog | Angular SSR Examples'
    // ← Static title for the list page
  },
  {
    path: 'blog/:slug',
    loadComponent: () => import('./blog/blog-post/blog-post.component')
      .then(m => m.BlogPostComponent),
    // ← Lazy-loaded: individual blog post
    // ← Dynamic title set by the component based on post data
  },
  {
    path: '**',
    loadComponent: () => import('./not-found/not-found.component')
      .then(m => m.NotFoundComponent),
    title: 'Page Not Found | Blog'
  }
];
```

---

### Blog Post Model

```typescript
// src/app/models/blog-post.model.ts
export interface BlogPost {
  id: number;
  slug: string;              // ← URL-friendly identifier: "angular-ssr-guide"
  title: string;             // ← "Complete Guide to Angular SSR"
  excerpt: string;           // ← Short description for SEO meta and cards
  content: string;           // ← Full HTML content
  author: {
    name: string;
    slug: string;
    avatarUrl: string;
  };
  heroImageUrl: string;      // ← Used for OG image
  tags: string[];            // ← ["angular", "ssr", "performance"]
  publishedAt: string;       // ← ISO 8601 date: "2026-02-14T10:00:00Z"
  updatedAt: string;
  readTimeMinutes: number;
}
```

---

### Blog Service with Automatic TransferState

```typescript
// src/app/blog/blog.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { BlogPost } from '../models/blog-post.model';

@Injectable({ providedIn: 'root' })
export class BlogService {

  private readonly apiUrl = '/api/blog';
  // ← Relative URL — works on both server and browser
  // ← On server: Express proxies /api/* to the backend
  // ← On browser: Same domain, same proxy

  constructor(private http: HttpClient) {}
  // ← HttpClient configured with withFetch() in app.config.ts
  // ← Angular SSR AUTOMATICALLY handles TransferState for HttpClient calls!
  // ← No manual TransferState code needed when using withFetch()

  getPosts(): Observable<BlogPost[]> {
    return this.http.get<BlogPost[]>(`${this.apiUrl}/posts`);
    // ← Angular SSR caches this call during server render
    // ← Browser skips the call and uses the cached data
    // ← Completely transparent — no special code needed
  }

  getPost(slug: string): Observable<BlogPost> {
    return this.http.get<BlogPost>(`${this.apiUrl}/posts/${slug}`);
    // ← Same — cached automatically by Angular SSR with withFetch()
  }
}
```

---

### Blog List Component

```typescript
// src/app/blog/blog-list/blog-list.component.ts
import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { Meta, Title } from '@angular/platform-browser';
import { BlogService } from '../blog.service';
import { BlogPost } from '../../models/blog-post.model';
import { SeoService } from '../../core/seo.service';

@Component({
  selector: 'app-blog-list',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    <main class="blog-list">
      <h1>Latest Articles</h1>

      @if (isLoading) {
        <div class="loading" aria-live="polite">
          <!-- ← aria-live: screen readers announce content changes -->
          <p>Loading articles...</p>
        </div>
      }

      @if (posts.length > 0) {
        <div class="posts-grid">
          @for (post of posts; track post.id) {
            <!-- ← track post.id: Angular uses id for efficient DOM updates -->
            <article class="post-card">
              <!-- ← article: semantic HTML for blog posts (better SEO) -->
              <img
                [src]="post.heroImageUrl"
                [alt]="post.title"
                loading="lazy"
                <!-- ← loading="lazy": don't load images until they're visible -->
                <!-- ← alt: required for accessibility and SEO -->
              />
              <div class="post-content">
                <div class="meta">
                  <time [dateTime]="post.publishedAt">
                    <!-- ← time element: semantic HTML for dates (SEO + accessibility) -->
                    <!-- ← dateTime attribute: machine-readable ISO 8601 format -->
                    {{ post.publishedAt | date:'longDate' }}
                  </time>
                  <span class="read-time">{{ post.readTimeMinutes }} min read</span>
                </div>
                <h2>
                  <a [routerLink]="['/blog', post.slug]">{{ post.title }}</a>
                </h2>
                <p class="excerpt">{{ post.excerpt }}</p>
                <div class="tags">
                  @for (tag of post.tags; track tag) {
                    <span class="tag">{{ tag }}</span>
                  }
                </div>
              </div>
            </article>
          }
        </div>
      }

      @if (!isLoading && posts.length === 0) {
        <p>No articles found.</p>
      }
    </main>
  `,
  styleUrls: ['./blog-list.component.scss']
})
export class BlogListComponent implements OnInit {

  posts: BlogPost[] = [];
  isLoading = true;

  constructor(
    private blogService: BlogService,
    private seoService: SeoService,
    // ← Inject our reusable SEO service
  ) {}

  ngOnInit(): void {
    // ← Set SEO for the blog list page
    this.seoService.updateSeo({
      title: 'Blog',
      description: 'Read the latest articles about Angular, TypeScript, and web development.',
      image: 'https://myblog.com/assets/blog-hero.jpg',
      type: 'website',
    });

    // ← Fetch posts (auto-cached by Angular SSR + withFetch)
    this.blogService.getPosts().subscribe({
      next: (posts) => {
        this.posts = posts;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Failed to load posts:', err);
        this.isLoading = false;
      }
    });
  }
}
```

---

### Blog Post Component (Full SSR + SEO Example)

```typescript
// src/app/blog/blog-post/blog-post.component.ts
import {
  Component, OnInit, OnDestroy, Input,
  Inject, PLATFORM_ID
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { isPlatformBrowser } from '@angular/common';
import { BlogService } from '../blog.service';
import { BlogPost } from '../../models/blog-post.model';
import { SeoService } from '../../core/seo.service';

@Component({
  selector: 'app-blog-post',
  standalone: true,
  imports: [CommonModule, RouterModule],
  template: `
    @if (post) {
      <article class="blog-post">
        <!-- ← article: semantic HTML, great for SEO -->

        <header class="post-header">
          <div class="breadcrumb">
            <!-- ← Breadcrumb: improves navigation and SEO -->
            <a routerLink="/">Blog</a>
            <span>/</span>
            <span>{{ post.title }}</span>
          </div>

          <h1>{{ post.title }}</h1>
          <!-- ← h1: should match the og:title for SEO consistency -->

          <div class="post-meta">
            <div class="author">
              <img
                [src]="post.author.avatarUrl"
                [alt]="post.author.name"
                class="avatar"
              />
              <div>
                <span class="author-name">{{ post.author.name }}</span>
                <time [dateTime]="post.publishedAt" class="date">
                  {{ post.publishedAt | date:'MMMM d, y' }}
                </time>
              </div>
            </div>
            <span class="read-time">{{ post.readTimeMinutes }} min read</span>
          </div>
        </header>

        <img
          [src]="post.heroImageUrl"
          [alt]="post.title"
          class="hero-image"
          loading="eager"
          <!-- ← eager: load hero image immediately (above the fold) -->
          <!-- ← Contrast with lazy for below-fold images -->
        />

        <div class="post-body">
          <div [innerHTML]="post.content"></div>
          <!-- ← innerHTML for rich HTML content from CMS -->
          <!-- ← In production, sanitize this content! Angular's DomSanitizer -->
        </div>

        <footer class="post-footer">
          <div class="tags">
            <strong>Tags:</strong>
            @for (tag of post.tags; track tag) {
              <a [routerLink]="['/']" [queryParams]="{ tag: tag }" class="tag">
                {{ tag }}
              </a>
            }
          </div>
          <div class="share">
            <button (click)="shareToTwitter()">Share on Twitter</button>
            <button (click)="shareToLinkedIn()">Share on LinkedIn</button>
            <!-- ← Share buttons: only work in browser, guarded below -->
          </div>
        </footer>
      </article>
    } @else if (isLoading) {
      <div class="loading" aria-live="polite">
        <p>Loading article...</p>
      </div>
    } @else {
      <div class="error">
        <h1>Article Not Found</h1>
        <p>The article you're looking for doesn't exist.</p>
        <a routerLink="/">Back to Blog</a>
      </div>
    }
  `,
  styleUrls: ['./blog-post.component.scss']
})
export class BlogPostComponent implements OnInit, OnDestroy {

  @Input() slug!: string;
  // ← withComponentInputBinding() maps route param :slug to this @Input
  // ← Angular 16+ feature — cleaner than injecting ActivatedRoute

  post?: BlogPost;
  isLoading = true;

  constructor(
    private blogService: BlogService,
    private seoService: SeoService,
    @Inject(PLATFORM_ID) private platformId: Object,
    // ← For platform-specific code (share buttons, etc.)
  ) {}

  ngOnInit(): void {
    this.blogService.getPost(this.slug).subscribe({
      next: (post) => {
        this.post = post;
        this.isLoading = false;
        this.updateSeo(post);
        // ← Update SEO AFTER post data is available
        // ← This runs on BOTH server and browser
        // ← On server: meta tags are in the HTML response (SEO works!)
        // ← On browser: meta tags update for SPA navigation
      },
      error: () => {
        this.isLoading = false;
        // ← 404 state — show error template
      }
    });
  }

  private updateSeo(post: BlogPost): void {
    this.seoService.updateSeo({
      title: post.title,
      description: post.excerpt,
      image: `https://myblog.com${post.heroImageUrl}`,
      type: 'article',
      canonicalUrl: `https://myblog.com/blog/${post.slug}`,
    });
    // ← All SEO is handled by the SEO service
    // ← Structured data, OG tags, Twitter cards, canonical URL
  }

  shareToTwitter(): void {
    if (isPlatformBrowser(this.platformId)) {
      // ← Guard: window.open only works in browser
      const text = encodeURIComponent(`${this.post?.title} - via @myblog`);
      const url = encodeURIComponent(window.location.href);
      window.open(
        `https://twitter.com/intent/tweet?text=${text}&url=${url}`,
        '_blank',
        'width=600,height=400'
      );
    }
  }

  shareToLinkedIn(): void {
    if (isPlatformBrowser(this.platformId)) {
      const url = encodeURIComponent(window.location.href);
      window.open(
        `https://www.linkedin.com/sharing/share-offsite/?url=${url}`,
        '_blank'
      );
    }
  }

  ngOnDestroy(): void {
    // ← Clean up: reset meta tags to defaults when leaving
    // ← Prevents stale tags from showing on next page
    this.seoService.updateSeo({
      title: 'Blog',
      description: 'Read the latest articles about Angular and web development.',
    });
  }
}
```

---

### Complete server.ts with Caching

```typescript
// server.ts — Production-ready SSR server
import 'zone.js/node';
import { APP_BASE_HREF } from '@angular/common';
import { CommonEngine } from '@angular/ssr';
import express from 'express';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import bootstrap from './src/main.server';
import compression from 'compression';
// ← compression: gzip responses to reduce bandwidth

const serverDistFolder = dirname(fileURLToPath(import.meta.url));
const browserDistFolder = resolve(serverDistFolder, '../browser');
const indexHtml = join(serverDistFolder, 'index.server.html');

// ← In-memory cache (replace with Redis in production)
const cache = new Map<string, { html: string; ts: number }>();
const CACHE_TTL_MS = 10 * 60 * 1000; // ← 10 minutes

export function app(): express.Express {
  const server = express();
  const commonEngine = new CommonEngine();

  // ← Enable gzip compression for all responses
  server.use(compression());
  // ← Reduces HTML response size by 70-80%

  // ← Security headers
  server.use((req, res, next) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    // ← Prevents browsers from MIME-sniffing responses
    res.setHeader('X-Frame-Options', 'DENY');
    // ← Prevents your app from being embedded in iframes (clickjacking)
    res.setHeader('X-XSS-Protection', '1; mode=block');
    // ← XSS protection header
    next();
  });

  // ← Health check endpoint (for load balancers, Kubernetes)
  server.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
    // ← Load balancers poll this endpoint to check if server is healthy
  });

  // ← Serve static files from browser build
  server.get('*.*', express.static(browserDistFolder, {
    maxAge: '1y',
    // ← Cache static assets for 1 year
    // ← Angular CLI adds content hashes to filenames (main.a3b4c5d6.js)
    // ← So when files change, their filenames change → no stale cache
    immutable: true,
    // ← Tell CDNs these files never change (for files with content hashes)
  }));

  // ← SSR handler with caching
  server.get('*', async (req, res, next) => {
    const url = req.url;

    // ← Don't cache certain routes
    const isPrivate = url.startsWith('/user/') || url.startsWith('/account/');
    const isCacheable = !isPrivate;

    if (isCacheable) {
      const cached = cache.get(url);
      if (cached && Date.now() - cached.ts < CACHE_TTL_MS) {
        // ← Serve from cache
        res.setHeader('X-Cache', 'HIT');
        res.setHeader('Cache-Control', 'public, max-age=600');
        return res.send(cached.html);
      }
    }

    // ← Render with Angular SSR
    try {
      const { protocol, originalUrl, baseUrl, headers } = req;
      const html = await commonEngine.render({
        bootstrap,
        documentFilePath: indexHtml,
        url: `${protocol}://${headers.host}${originalUrl}`,
        publicPath: browserDistFolder,
        providers: [
          { provide: APP_BASE_HREF, useValue: baseUrl },
        ],
      });

      if (isCacheable) {
        cache.set(url, { html, ts: Date.now() });
        // ← Cache the rendered result
      }

      res.setHeader('X-Cache', 'MISS');
      res.setHeader('Cache-Control', isPrivate
        ? 'private, no-cache'      // ← User-specific: never cache publicly
        : 'public, max-age=600');  // ← Public: cache for 10 minutes

      res.send(html);
    } catch (err) {
      next(err);
    }
  });

  // ← Error handler
  server.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error('SSR Error:', err.message);
    res.status(500).send('An error occurred rendering this page.');
    // ← In production, you might fallback to CSR (send empty HTML)
    // ← so users still get a working app even if SSR fails
  });

  return server;
}

function run(): void {
  const port = process.env['PORT'] || 4000;
  app().listen(port, () => {
    console.log(`SSR server running at http://localhost:${port}`);
  });
}

run();
```

---

### Pre-rendering Configuration for the Blog

```json
// angular.json — Configure pre-rendering for static blog pages
{
  "projects": {
    "blog-app": {
      "architect": {
        "build": {
          "options": {
            "prerender": {
              "routesFile": "prerender-routes.txt",
              "discoverRoutes": true
            },
            "ssr": {
              "entry": "server.ts"
            }
          }
        }
      }
    }
  }
}
```

```
# prerender-routes.txt
# ← Static pages — always pre-render these:
/
/about
/contact
/blog

# ← Dynamic blog posts — generated by a script at build time:
/blog/introduction-to-angular-ssr
/blog/angular-17-standalone-components
/blog/rxjs-best-practices
/blog/angular-performance-optimization
```

```typescript
// generate-prerender-routes.ts — Build script to generate routes.txt
// ← Run this before ng build: ts-node generate-prerender-routes.ts

import { writeFileSync } from 'fs';

interface Post { slug: string; }

async function generateRoutes(): Promise<void> {
  // ← Fetch all blog posts from your CMS/API
  const response = await fetch('https://api.myblog.com/posts?fields=slug');
  const posts: Post[] = await response.json();

  const staticRoutes = ['/', '/about', '/contact', '/blog'];
  // ← Static pages always included

  const dynamicRoutes = posts.map(post => `/blog/${post.slug}`);
  // ← Generate a route for every blog post

  const allRoutes = [...staticRoutes, ...dynamicRoutes];

  writeFileSync('prerender-routes.txt', allRoutes.join('\n'));
  // ← Write routes file for angular.json to read

  console.log(`Generated ${allRoutes.length} routes for pre-rendering`);
}

generateRoutes().catch(console.error);
```

---

### Build Commands for the Blog App

```json
// package.json — Build scripts
{
  "scripts": {
    "start": "ng serve",
    "build": "ng build",
    "build:ssr": "ng build --configuration=production",
    "serve:ssr": "node dist/blog-app/server/server.mjs",
    "prerender": "ts-node generate-prerender-routes.ts && ng build",
    "dev:ssr": "ng run blog-app:serve-ssr",
    "lint": "ng lint",
    "test": "ng test"
  }
}
```

---

## 19.14 Summary

### What You've Learned

Server-Side Rendering transforms an Angular app from a JavaScript-first experience into a web-standards-compliant application that works for everyone — search engines, social media bots, users on slow connections, and users with JavaScript disabled.

---

### Key Concepts at a Glance

| Concept | What It Is | When to Use |
|---|---|---|
| SSR | Server renders HTML on each request | Public pages, e-commerce, news |
| SSG/Pre-rendering | HTML generated at build time | Blogs, docs, marketing pages |
| Hydration | Attaching Angular to server-rendered DOM | Always with SSR |
| Non-destructive hydration | Reusing server DOM nodes (Angular 16+) | Default; always prefer this |
| TransferState | Transfer server data to client | Avoid duplicate HTTP calls |
| PLATFORM_ID | Token to detect browser vs server | Guard browser-only code |
| afterNextRender() | Runs only in browser, once | Third-party lib init, DOM access |
| Meta service | Dynamic meta/OG/Twitter tags | Every public page |
| provideClientHydration() | Enable hydration | Every SSR app |
| provideHttpClient(withFetch()) | SSR-compatible HTTP | Every SSR app |
| CommonEngine | Angular's SSR rendering engine | In server.ts |

---

### SSR Setup Checklist

```
ANGULAR SSR SETUP CHECKLIST:
==============================

[ ] Run: ng add @angular/ssr
[ ] Add provideClientHydration() to app.config.ts
[ ] Add provideHttpClient(withFetch()) to app.config.ts
[ ] Guard all browser-only code with isPlatformBrowser()
[ ] Use afterNextRender() for third-party library initialization
[ ] Wrap localStorage in a platform-aware service
[ ] Implement TransferState (or use withFetch() for automatic)
[ ] Add Meta and Title service calls to all public routes
[ ] Set up caching in server.ts for production
[ ] Add proper Cache-Control headers
[ ] Configure pre-rendering for static pages
[ ] Test SSR: curl http://localhost:4000 and check HTML
[ ] Check for hydration errors in browser console
[ ] Test with JavaScript disabled (should still see content)
[ ] Test with Lighthouse (check FCP, LCP, TTI scores)
[ ] Test social sharing (use Twitter Card Validator)
[ ] Test Google search preview (use Google Rich Results Test)
[ ] Deploy to Node.js server or containerize with Docker
[ ] Set up PM2 or process manager for production
```

---

### Before/After: The Impact of SSR

```
BEFORE SSR (CSR only):
=======================
Google Lighthouse scores:
  Performance:      45/100
  SEO:              62/100
  Accessibility:    78/100
  Best Practices:   85/100

First Contentful Paint:   3.2s
Time to Interactive:      4.8s
Google Search Ranking:    Page 3-4
Social media previews:    Blank cards
Mobile users (3G):        8+ seconds to content


AFTER SSR (with caching + hydration):
======================================
Google Lighthouse scores:
  Performance:      92/100
  SEO:              100/100
  Accessibility:    95/100
  Best Practices:   95/100

First Contentful Paint:   0.4s (cached) / 0.8s (uncached)
Time to Interactive:      1.2s
Google Search Ranking:    Page 1
Social media previews:    Rich cards with image + description
Mobile users (3G):        0.4s to see content
```

---

### Common Patterns Quick Reference

```typescript
// Pattern 1: Platform Detection
constructor(@Inject(PLATFORM_ID) private platformId: Object) {}
if (isPlatformBrowser(this.platformId)) { /* browser only */ }

// Pattern 2: Browser-only initialization
constructor() {
  afterNextRender(() => { /* runs once in browser only */ });
}

// Pattern 3: Safe localStorage
// → Use the StorageService from section 19.6

// Pattern 4: Dynamic meta tags
this.seoService.updateSeo({ title, description, image, type });

// Pattern 5: Avoid double HTTP calls
// → Use provideHttpClient(withFetch()) — automatic TransferState

// Pattern 6: Pre-rendering
// → List routes in routes.txt, set prerender in angular.json

// Pattern 7: Skip hydration for problematic components
// → Add ngSkipHydration attribute to element

// Pattern 8: Event replay during hydration
// → provideClientHydration(withEventReplay())
```

---

### Core Web Vitals Impact

SSR directly improves the metrics Google uses for search ranking:

| Metric | Description | SSR Impact |
|---|---|---|
| **LCP** (Largest Contentful Paint) | How fast the main content loads | Major improvement — HTML arrives immediately |
| **FCP** (First Contentful Paint) | How fast first content appears | Major improvement — content in initial HTML |
| **FID/INP** (First Input Delay/Interaction to Next Paint) | Responsiveness to user input | Minor improvement — hydration completes faster |
| **CLS** (Cumulative Layout Shift) | Visual stability (no layout jumps) | Improvement — server HTML matches client HTML |
| **TTFB** (Time to First Byte) | How fast server responds | Small regression — rendering takes time (offset by caching) |

---

### Final Architecture Diagram

```
PRODUCTION ANGULAR SSR ARCHITECTURE:
=======================================

  Users
    |
    v
  CDN (CloudFront, Fastly, Cloudflare)
    |
    |-- Static files (.js, .css, images) → served from CDN edge
    |
    v
  Load Balancer (nginx / AWS ALB)
    |
    v
  PM2 Cluster (4 Node.js processes on 4 CPUs)
    |
    |-- GET /                  → Cache HIT  → return cached HTML
    |-- GET /blog/ssr-guide    → Cache MISS → render with Angular → cache → return
    |-- GET /user/dashboard    → No cache   → render with Angular → return
    |
    v
  Angular CommonEngine
    |-- Renders component tree
    |-- Makes HTTP calls to backend API
    |-- Returns HTML string
    |
    v
  Redis Cache
    |-- Stores rendered HTML for public pages
    |-- TTL: 5-10 minutes
    |-- Invalidated on content updates
    |
    v
  Backend API (separate service)
    |-- Returns data (products, blog posts, etc.)
    |-- Cached at API level too (Redis, CDN)
```

This architecture handles millions of requests per day with sub-second response times, perfect SEO scores, and minimal server costs.

---

> **Next Phase:** [Phase 20: Advanced Patterns & Architecture](Phase20-Advanced-Patterns-Architecture.md)
