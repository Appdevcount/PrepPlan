# Angular Advanced Features vs ReactJS: Complete Study Guide (Part 4)

> **Advanced Features - Part 4 of 6**  
> This file covers 9 advanced Angular features: Angular Universal (SSR), Angular Elements, Service Workers/PWA, Renderer2, APP_INITIALIZER, HttpContext, Multi Providers, Environment Files, and Typed Reactive Forms.

---

## 🔥 Advanced Features {#advanced-features}

### 1. Angular Universal (Server-Side Rendering)

**Description:** Angular Universal enables server-side rendering (SSR) of Angular applications, improving initial load time, SEO, and social media sharing. It renders your Angular app on the server and sends fully rendered HTML to the client.

#### Angular: Universal SSR Implementation

**Basic SSR Setup:**

```typescript
// server.ts
import 'zone.js/node';
import { APP_BASE_HREF } from '@angular/common';
import { CommonEngine } from '@angular/ssr';
import express from 'express';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';
import bootstrap from './src/main.server';

// Express server
export function app(): express.Express {
  const server = express();
  const serverDistFolder = dirname(fileURLToPath(import.meta.url));
  const browserDistFolder = resolve(serverDistFolder, '../browser');
  const indexHtml = join(serverDistFolder, 'index.server.html');

  // Create CommonEngine instance for SSR
  const commonEngine = new CommonEngine();

  // Serve static files from /browser directory
  server.get('*.*', express.static(browserDistFolder, {
    maxAge: '1y'
  }));

  // All regular routes use the Angular engine
  server.get('*', (req, res, next) => {
    const { protocol, originalUrl, baseUrl, headers } = req;

    commonEngine
      .render({
        bootstrap, // Server bundle
        documentFilePath: indexHtml,
        url: `${protocol}://${headers.host}${originalUrl}`,
        publicPath: browserDistFolder,
        providers: [
          { provide: APP_BASE_HREF, useValue: baseUrl }
        ],
      })
      .then((html) => res.send(html))
      .catch((err) => next(err));
  });

  return server;
}

// Start the server
function run(): void {
  const port = process.env['PORT'] || 4000;
  const server = app();
  
  server.listen(port, () => {
    console.log(`Node Express server listening on http://localhost:${port}`);
  });
}

run();
```

**Transfer State for Data Hydration:**

```typescript
// article.service.ts
import { Injectable, inject, TransferState, makeStateKey } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { tap } from 'rxjs/operators';

// Create unique key for state transfer
const ARTICLES_KEY = makeStateKey<Article[]>('articles');

interface Article {
  id: number;
  title: string;
  content: string;
}

@Injectable({
  providedIn: 'root'
})
export class ArticleService {
  private http = inject(HttpClient);
  private transferState = inject(TransferState);

  getArticles(): Observable<Article[]> {
    // Check if data exists in TransferState (from server)
    const cachedArticles = this.transferState.get(ARTICLES_KEY, null);
    
    if (cachedArticles) {
      // Use cached data and remove from state
      this.transferState.remove(ARTICLES_KEY);
      return of(cachedArticles);
    }
    
    // Fetch from API and cache in TransferState
    return this.http.get<Article[]>('https://api.example.com/articles')
      .pipe(
        tap(articles => {
          // Store in TransferState for client hydration
          this.transferState.set(ARTICLES_KEY, articles);
        })
      );
  }
}

// article-list.component.ts
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ArticleService } from './article.service';

@Component({
  selector: 'app-article-list',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="articles">
      <h2>Articles</h2>
      
      @if (loading) {
        <div class="loading">Loading articles...</div>
      }
      
      @for (article of articles; track article.id) {
        <article class="article-card">
          <h3>{{ article.title }}</h3>
          <p>{{ article.content }}</p>
        </article>
      }
    </div>
  `,
  styles: [`
    .articles {
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }
    .article-card {
      padding: 20px;
      margin: 16px 0;
      border: 1px solid #ddd;
      border-radius: 8px;
    }
    .loading {
      text-align: center;
      padding: 40px;
      color: #666;
    }
  `]
})
export class ArticleListComponent implements OnInit {
  private articleService = inject(ArticleService);
  
  articles: any[] = [];
  loading = true;

  ngOnInit() {
    // Will use cached data on client if available from server
    this.articleService.getArticles().subscribe({
      next: (articles) => {
        this.articles = articles;
        this.loading = false;
      },
      error: (error) => {
        console.error('Failed to load articles:', error);
        this.loading = false;
      }
    });
  }
}
```

**Platform Detection:**

```typescript
// platform.service.ts
import { Injectable, PLATFORM_ID, inject } from '@angular/core';
import { isPlatformBrowser, isPlatformServer } from '@angular/common';

@Injectable({
  providedIn: 'root'
})
export class PlatformService {
  private platformId = inject(PLATFORM_ID);

  get isBrowser(): boolean {
    return isPlatformBrowser(this.platformId);
  }

  get isServer(): boolean {
    return isPlatformServer(this.platformId);
  }

  // Safe access to browser-only APIs
  safeWindow(): Window | null {
    return this.isBrowser ? window : null;
  }

  safeDocument(): Document | null {
    return this.isBrowser ? document : null;
  }

  safeLocalStorage(): Storage | null {
    return this.isBrowser ? localStorage : null;
  }
}

// Usage in component
import { Component, OnInit, inject } from '@angular/core';
import { PlatformService } from './platform.service';

@Component({
  selector: 'app-browser-only',
  template: `
    <div class="container">
      <h3>Platform Info</h3>
      <p>Running on: {{ platform }}</p>
      
      @if (platformService.isBrowser) {
        <div class="browser-only">
          <p>Window width: {{ windowWidth }}px</p>
          <p>User agent: {{ userAgent }}</p>
        </div>
      }
    </div>
  `
})
export class BrowserOnlyComponent implements OnInit {
  platformService = inject(PlatformService);
  
  platform = '';
  windowWidth = 0;
  userAgent = '';

  ngOnInit() {
    this.platform = this.platformService.isBrowser ? 'Browser' : 'Server';
    
    // Only access browser APIs on client side
    if (this.platformService.isBrowser) {
      this.windowWidth = window.innerWidth;
      this.userAgent = navigator.userAgent;
      
      // Add window resize listener
      window.addEventListener('resize', () => {
        this.windowWidth = window.innerWidth;
      });
    }
  }
}
```

**SEO Meta Tags with SSR:**

```typescript
// seo.service.ts
import { Injectable, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';

@Injectable({
  providedIn: 'root'
})
export class SeoService {
  private meta = inject(Meta);
  private title = inject(Title);

  updateMetaTags(config: {
    title?: string;
    description?: string;
    image?: string;
    url?: string;
    type?: string;
  }): void {
    // Update title
    if (config.title) {
      this.title.setTitle(config.title);
    }

    // Update meta tags
    const tags = [
      { name: 'description', content: config.description || '' },
      { name: 'og:title', content: config.title || '' },
      { name: 'og:description', content: config.description || '' },
      { name: 'og:image', content: config.image || '' },
      { name: 'og:url', content: config.url || '' },
      { name: 'og:type', content: config.type || 'website' },
      { name: 'twitter:card', content: 'summary_large_image' },
      { name: 'twitter:title', content: config.title || '' },
      { name: 'twitter:description', content: config.description || '' },
      { name: 'twitter:image', content: config.image || '' }
    ];

    tags.forEach(tag => {
      this.meta.updateTag(tag);
    });
  }

  removeMetaTags(): void {
    this.meta.removeTag('name="description"');
    this.meta.removeTag('name="og:title"');
    this.meta.removeTag('name="og:description"');
    // ... remove other tags
  }
}

// product-detail.component.ts
import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { SeoService } from './seo.service';

@Component({
  selector: 'app-product-detail',
  template: `
    <div class="product-detail">
      <h1>{{ product.name }}</h1>
      <img [src]="product.image" [alt]="product.name" />
      <p>{{ product.description }}</p>
      <p class="price">{{ product.price | currency }}</p>
    </div>
  `
})
export class ProductDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private seo = inject(SeoService);
  
  product = {
    name: 'Premium Laptop',
    description: 'High-performance laptop for professionals',
    image: 'https://example.com/laptop.jpg',
    price: 1299
  };

  ngOnInit() {
    // Update SEO tags - will be rendered in server HTML
    this.seo.updateMetaTags({
      title: `${this.product.name} - Buy Online`,
      description: this.product.description,
      image: this.product.image,
      url: `https://example.com/products/${this.route.snapshot.params['id']}`,
      type: 'product'
    });
  }
}
```

#### React: Equivalent SSR Patterns

**Next.js Server-Side Rendering:**

```tsx
// pages/articles/index.tsx (Next.js App Router)
import { Metadata } from 'next';

// Server Component - runs on server by default
interface Article {
  id: number;
  title: string;
  content: string;
}

// Fetch data on server
async function getArticles(): Promise<Article[]> {
  const res = await fetch('https://api.example.com/articles', {
    // Next.js will cache this request
    cache: 'force-cache'
  });
  
  if (!res.ok) {
    throw new Error('Failed to fetch articles');
  }
  
  return res.json();
}

// Generate metadata on server
export async function generateMetadata(): Promise<Metadata> {
  return {
    title: 'Articles - My Blog',
    description: 'Read our latest articles',
  };
}

// Server Component
export default async function ArticlesPage() {
  // Data fetching happens on server
  const articles = await getArticles();

  return (
    <div className="articles">
      <h2>Articles</h2>
      
      {articles.map(article => (
        <article key={article.id} className="article-card">
          <h3>{article.title}</h3>
          <p>{article.content}</p>
        </article>
      ))}
    </div>
  );
}
```

**Platform Detection:**

```tsx
// hooks/usePlatform.ts
import { useState, useEffect } from 'react';

export function usePlatform() {
  const [isBrowser, setIsBrowser] = useState(false);

  useEffect(() => {
    // This only runs on client
    setIsBrowser(true);
  }, []);

  return {
    isBrowser,
    isServer: !isBrowser,
    safeWindow: isBrowser ? window : null,
    safeDocument: isBrowser ? document : null,
    safeLocalStorage: isBrowser ? localStorage : null
  };
}

// Usage
function BrowserOnlyComponent() {
  const { isBrowser, safeWindow } = usePlatform();
  const [windowWidth, setWindowWidth] = useState(0);

  useEffect(() => {
    if (isBrowser && safeWindow) {
      setWindowWidth(safeWindow.innerWidth);
      
      const handleResize = () => {
        setWindowWidth(safeWindow.innerWidth);
      };
      
      safeWindow.addEventListener('resize', handleResize);
      return () => safeWindow.removeEventListener('resize', handleResize);
    }
  }, [isBrowser, safeWindow]);

  return (
    <div>
      <h3>Platform Info</h3>
      <p>Running on: {isBrowser ? 'Browser' : 'Server'}</p>
      
      {isBrowser && (
        <div className="browser-only">
          <p>Window width: {windowWidth}px</p>
          <p>User agent: {navigator.userAgent}</p>
        </div>
      )}
    </div>
  );
}

export default BrowserOnlyComponent;
```

**Dynamic SEO with Next.js:**

```tsx
// app/products/[id]/page.tsx
import { Metadata } from 'next';

interface Product {
  id: string;
  name: string;
  description: string;
  image: string;
  price: number;
}

async function getProduct(id: string): Promise<Product> {
  const res = await fetch(`https://api.example.com/products/${id}`);
  return res.json();
}

// Generate dynamic metadata
export async function generateMetadata({ params }: { params: { id: string } }): Promise<Metadata> {
  const product = await getProduct(params.id);
  
  return {
    title: `${product.name} - Buy Online`,
    description: product.description,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [product.image],
      type: 'product'
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.description,
      images: [product.image]
    }
  };
}

// Server Component
export default async function ProductPage({ params }: { params: { id: string } }) {
  const product = await getProduct(params.id);

  return (
    <div className="product-detail">
      <h1>{product.name}</h1>
      <img src={product.image} alt={product.name} />
      <p>{product.description}</p>
      <p className="price">${product.price}</p>
    </div>
  );
}
```

#### Comparison: SSR

| Feature | Angular Universal | Next.js / React SSR |
|---------|------------------|-------------------|
| **Setup** | Manual with @angular/ssr | Built-in framework |
| **State Transfer** | TransferState API | Automatic hydration |
| **Platform Detection** | PLATFORM_ID | useEffect (client-only) |
| **SEO** | Meta, Title services | generateMetadata |
| **Data Fetching** | Services with TransferState | Server Components / getServerSideProps |

**When to Use:**
- **Angular Universal:** SEO-critical apps, improved initial load, social media sharing
- **Next.js:** Same benefits with better DX and performance

**Further Reading:**
- [Angular Universal](https://angular.dev/guide/ssr)
- [Next.js SSR](https://nextjs.org/docs/app/building-your-application/rendering/server-components)

---

### 2. Angular Elements (Web Components)

**Description:** Angular Elements allows you to package Angular components as custom web components that can be used in any HTML page, regardless of the framework (or no framework at all).

#### Angular: Creating Web Components

**Basic Custom Element:**

```typescript
// greeting.component.ts
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-greeting',
  standalone: true,
  template: `
    <div class="greeting">
      <h2>{{ greeting }}</h2>
      <p>Hello, {{ name }}!</p>
      @if (showTime) {
        <p class="time">{{ currentTime }}</p>
      }
    </div>
  `,
  styles: [`
    .greeting {
      padding: 20px;
      border: 2px solid #007bff;
      border-radius: 8px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .greeting h2 {
      margin: 0 0 10px 0;
    }
    .time {
      font-size: 12px;
      opacity: 0.8;
      margin-top: 10px;
    }
  `]
})
export class GreetingComponent {
  @Input() name = 'Guest';
  @Input() greeting = 'Welcome';
  @Input() showTime = false;

  get currentTime(): string {
    return new Date().toLocaleTimeString();
  }
}

// main.ts - Register as Custom Element
import { createCustomElement } from '@angular/elements';
import { createApplication } from '@angular/platform-browser';
import { GreetingComponent } from './greeting.component';

(async () => {
  // Create Angular application
  const app = await createApplication({
    providers: []
  });

  // Create custom element
  const greetingElement = createCustomElement(GreetingComponent, {
    injector: app.injector
  });

  // Register custom element in browser
  customElements.define('my-greeting', greetingElement);
})();

// Usage in any HTML
/*
<!DOCTYPE html>
<html>
<head>
  <script src="greeting-element.js"></script>
</head>
<body>
  <!-- Use custom element with attributes -->
  <my-greeting name="John" greeting="Hello" show-time="true"></my-greeting>
  
  <!-- Can be used multiple times -->
  <my-greeting name="Jane" greeting="Hi"></my-greeting>
  
  <!-- Works with JavaScript -->
  <script>
    const greeting = document.createElement('my-greeting');
    greeting.setAttribute('name', 'Dynamic User');
    document.body.appendChild(greeting);
  </script>
</body>
</html>
*/
```

**Advanced: Element with Events:**

```typescript
// counter-widget.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';

@Component({
  selector: 'app-counter-widget',
  standalone: true,
  template: `
    <div class="counter-widget">
      <h3>{{ title }}</h3>
      <div class="counter-display">{{ count }}</div>
      <div class="controls">
        <button (click)="decrement()">-</button>
        <button (click)="reset()">Reset</button>
        <button (click)="increment()">+</button>
      </div>
    </div>
  `,
  styles: [`
    .counter-widget {
      display: inline-block;
      padding: 20px;
      border: 2px solid #28a745;
      border-radius: 8px;
      text-align: center;
    }
    .counter-display {
      font-size: 48px;
      font-weight: bold;
      margin: 20px 0;
      color: #28a745;
    }
    .controls button {
      margin: 0 5px;
      padding: 10px 20px;
      font-size: 18px;
      border: none;
      border-radius: 4px;
      background: #28a745;
      color: white;
      cursor: pointer;
    }
    .controls button:hover {
      background: #218838;
    }
  `]
})
export class CounterWidgetComponent {
  @Input() title = 'Counter';
  @Input() initialValue = 0;
  @Output() countChange = new EventEmitter<number>();
  
  count = 0;

  ngOnInit() {
    this.count = this.initialValue;
  }

  increment() {
    this.count++;
    this.countChange.emit(this.count);
  }

  decrement() {
    this.count--;
    this.countChange.emit(this.count);
  }

  reset() {
    this.count = this.initialValue;
    this.countChange.emit(this.count);
  }
}

// main.ts
import { createCustomElement } from '@angular/elements';
import { createApplication } from '@angular/platform-browser';
import { CounterWidgetComponent } from './counter-widget.component';

(async () => {
  const app = await createApplication();
  
  const counterElement = createCustomElement(CounterWidgetComponent, {
    injector: app.injector
  });
  
  customElements.define('counter-widget', counterElement);
})();

// Usage with event handling
/*
<counter-widget id="myCounter" title="My Counter" initial-value="10"></counter-widget>

<script>
  const counter = document.getElementById('myCounter');
  
  // Listen to custom events
  counter.addEventListener('countChange', (event) => {
    console.log('Count changed to:', event.detail);
    document.getElementById('display').textContent = `Count: ${event.detail}`;
  });
</script>
*/
```

**Complex: Dashboard Widget System:**

```typescript
// widget-base.ts
export interface WidgetConfig {
  title: string;
  refreshInterval?: number;
}

// stats-widget.component.ts
import { Component, Input, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-stats-widget',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="stats-widget">
      <div class="widget-header">
        <h4>{{ title }}</h4>
        <button class="refresh-btn" (click)="refresh()">🔄</button>
      </div>
      <div class="stats-grid">
        @for (stat of stats; track stat.label) {
          <div class="stat-card">
            <div class="stat-value">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        }
      </div>
      <div class="last-update">
        Last updated: {{ lastUpdate }}
      </div>
    </div>
  `,
  styles: [`
    .stats-widget {
      padding: 16px;
      border: 1px solid #ddd;
      border-radius: 8px;
      background: white;
    }
    .widget-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .widget-header h4 {
      margin: 0;
    }
    .refresh-btn {
      border: none;
      background: none;
      font-size: 16px;
      cursor: pointer;
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 12px;
      margin-bottom: 12px;
    }
    .stat-card {
      padding: 12px;
      background: #f8f9fa;
      border-radius: 4px;
      text-align: center;
    }
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #007bff;
    }
    .stat-label {
      font-size: 12px;
      color: #666;
      margin-top: 4px;
    }
    .last-update {
      font-size: 11px;
      color: #999;
      text-align: right;
    }
  `]
})
export class StatsWidgetComponent implements OnInit, OnDestroy {
  @Input() title = 'Statistics';
  @Input() refreshInterval = 30000; // 30 seconds
  
  stats = [
    { label: 'Users', value: 0 },
    { label: 'Sessions', value: 0 },
    { label: 'Revenue', value: '$0' }
  ];
  
  lastUpdate = '';
  private intervalId?: number;

  ngOnInit() {
    this.refresh();
    
    // Auto-refresh
    if (this.refreshInterval > 0) {
      this.intervalId = window.setInterval(() => {
        this.refresh();
      }, this.refreshInterval);
    }
  }

  ngOnDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  refresh() {
    // Simulate data fetching
    this.stats = [
      { label: 'Users', value: Math.floor(Math.random() * 1000) },
      { label: 'Sessions', value: Math.floor(Math.random() * 500) },
      { label: 'Revenue', value: `$${Math.floor(Math.random() * 10000)}` }
    ];
    this.lastUpdate = new Date().toLocaleTimeString();
  }
}

// Register all widgets
import { createCustomElement } from '@angular/elements';
import { createApplication } from '@angular/platform-browser';
import { StatsWidgetComponent } from './stats-widget.component';

(async () => {
  const app = await createApplication();
  
  // Register stats widget
  const statsElement = createCustomElement(StatsWidgetComponent, {
    injector: app.injector
  });
  customElements.define('stats-widget', statsElement);
})();

// Usage - Mix with any framework or vanilla JS
/*
<!-- Plain HTML Dashboard -->
<div class="dashboard">
  <stats-widget title="User Stats" refresh-interval="5000"></stats-widget>
  <stats-widget title="Sales Stats" refresh-interval="10000"></stats-widget>
</div>

<!-- In React -->
function Dashboard() {
  return (
    <div>
      <stats-widget title="Analytics" />
    </div>
  );
}

<!-- In Vue -->
<template>
  <stats-widget title="Metrics" :refresh-interval="15000" />
</template>
*/
```

#### React: Equivalent Web Components

**React to Web Component:**

```tsx
// greeting-component.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';

interface GreetingProps {
  name?: string;
  greeting?: string;
  showTime?: boolean;
}

function Greeting({ name = 'Guest', greeting = 'Welcome', showTime = false }: GreetingProps) {
  const [currentTime, setCurrentTime] = React.useState(new Date().toLocaleTimeString());

  React.useEffect(() => {
    if (showTime) {
      const interval = setInterval(() => {
        setCurrentTime(new Date().toLocaleTimeString());
      }, 1000);
      return () => clearInterval(interval);
    }
  }, [showTime]);

  return (
    <div className="greeting">
      <h2>{greeting}</h2>
      <p>Hello, {name}!</p>
      {showTime && <p className="time">{currentTime}</p>}
    </div>
  );
}

// Wrap React component as Web Component
class GreetingElement extends HTMLElement {
  private root?: ReactDOM.Root;

  connectedCallback() {
    // Create React root
    this.root = ReactDOM.createRoot(this);
    this.render();
  }

  disconnectedCallback() {
    this.root?.unmount();
  }

  static get observedAttributes() {
    return ['name', 'greeting', 'show-time'];
  }

  attributeChangedCallback() {
    this.render();
  }

  private render() {
    if (this.root) {
      this.root.render(
        <Greeting
          name={this.getAttribute('name') || undefined}
          greeting={this.getAttribute('greeting') || undefined}
          showTime={this.getAttribute('show-time') === 'true'}
        />
      );
    }
  }
}

// Register custom element
customElements.define('my-greeting', GreetingElement);
```

**Counter with Events:**

```tsx
// counter-widget.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';

interface CounterProps {
  title?: string;
  initialValue?: number;
  onCountChange?: (count: number) => void;
}

function Counter({ title = 'Counter', initialValue = 0, onCountChange }: CounterProps) {
  const [count, setCount] = React.useState(initialValue);

  const handleChange = (newCount: number) => {
    setCount(newCount);
    onCountChange?.(newCount);
  };

  return (
    <div className="counter-widget">
      <h3>{title}</h3>
      <div className="counter-display">{count}</div>
      <div className="controls">
        <button onClick={() => handleChange(count - 1)}>-</button>
        <button onClick={() => handleChange(initialValue)}>Reset</button>
        <button onClick={() => handleChange(count + 1)}>+</button>
      </div>
    </div>
  );
}

class CounterElement extends HTMLElement {
  private root?: ReactDOM.Root;

  connectedCallback() {
    this.root = ReactDOM.createRoot(this);
    this.render();
  }

  disconnectedCallback() {
    this.root?.unmount();
  }

  static get observedAttributes() {
    return ['title', 'initial-value'];
  }

  attributeChangedCallback() {
    this.render();
  }

  private render() {
    if (this.root) {
      this.root.render(
        <Counter
          title={this.getAttribute('title') || undefined}
          initialValue={Number(this.getAttribute('initial-value')) || 0}
          onCountChange={(count) => {
            // Dispatch custom event
            this.dispatchEvent(new CustomEvent('countChange', {
              detail: count,
              bubbles: true
            }));
          }}
        />
      );
    }
  }
}

customElements.define('counter-widget', CounterElement);
```

#### Comparison: Web Components

| Feature | Angular Elements | React + Web Components |
|---------|-----------------|----------------------|
| **Setup** | @angular/elements | Manual wrapping |
| **Bundle Size** | Larger (includes Angular) | Smaller (just React) |
| **Lifecycle** | Built-in support | Manual handling |
| **Events** | @Output EventEmitter | CustomEvent dispatch |
| **Attributes** | @Input properties | observedAttributes |

**When to Use:**
- **Angular Elements:** Share Angular components across different frameworks
- **React Web Components:** Same use case, manual setup required

**Further Reading:**
- [Angular Elements](https://angular.dev/guide/elements)
- [Web Components](https://developer.mozilla.org/en-US/docs/Web/Web_Components)

---

### 3. Service Workers & Progressive Web Apps (PWA)

**Description:** Angular's Service Worker support enables Progressive Web App capabilities including offline functionality, background sync, push notifications, and app-like installation experience.

#### Angular: PWA Implementation

**Basic PWA Setup:**

```typescript
// Install @angular/pwa
// ng add @angular/pwa

// ngsw-config.json - Service Worker configuration
{
  "$schema": "./node_modules/@angular/service-worker/config/schema.json",
  "index": "/index.html",
  "assetGroups": [
    {
      "name": "app",
      "installMode": "prefetch",
      "resources": {
        "files": [
          "/favicon.ico",
          "/index.html",
          "/manifest.webmanifest",
          "/*.css",
          "/*.js"
        ]
      }
    },
    {
      "name": "assets",
      "installMode": "lazy",
      "updateMode": "prefetch",
      "resources": {
        "files": [
          "/assets/**",
          "/*.(svg|cur|jpg|jpeg|png|apng|webp|avif|gif|otf|ttf|woff|woff2)"
        ]
      }
    }
  ],
  "dataGroups": [
    {
      "name": "api-cache",
      "urls": [
        "https://api.example.com/**"
      ],
      "cacheConfig": {
        "strategy": "freshness",
        "maxSize": 100,
        "maxAge": "3d",
        "timeout": "10s"
      }
    }
  ]
}

// app.config.ts - Enable Service Worker
import { ApplicationConfig, isDevMode } from '@angular/core';
import { provideServiceWorker } from '@angular/service-worker';

export const appConfig: ApplicationConfig = {
  providers: [
    provideServiceWorker('ngsw-worker.js', {
      enabled: !isDevMode(),
      registrationStrategy: 'registerWhenStable:30000'
    })
  ]
};
```

**Service Worker Update Management:**

```typescript
// sw-update.service.ts
import { Injectable, inject, ApplicationRef } from '@angular/core';
import { SwUpdate, VersionReadyEvent } from '@angular/service-worker';
import { filter, first, concat, interval } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SwUpdateService {
  private swUpdate = inject(SwUpdate);
  private appRef = inject(ApplicationRef);

  constructor() {
    if (this.swUpdate.isEnabled) {
      // Check for updates every 6 hours
      const appIsStable$ = this.appRef.isStable.pipe(
        first(isStable => isStable === true)
      );
      const everySixHours$ = interval(6 * 60 * 60 * 1000);
      const everySixHoursOnceAppIsStable$ = concat(appIsStable$, everySixHours$);

      everySixHoursOnceAppIsStable$.subscribe(async () => {
        try {
          const updateFound = await this.swUpdate.checkForUpdate();
          console.log(updateFound ? 'Update found' : 'No update found');
        } catch (err) {
          console.error('Failed to check for updates:', err);
        }
      });
    }
  }

  // Listen for version updates
  listenForUpdates(): void {
    this.swUpdate.versionUpdates
      .pipe(
        filter((evt): evt is VersionReadyEvent => evt.type === 'VERSION_READY')
      )
      .subscribe(evt => {
        if (this.promptUser()) {
          // Reload page to update app
          this.swUpdate.activateUpdate().then(() => {
            document.location.reload();
          });
        }
      });
  }

  // Check for unrecoverable state
  checkUnrecoverableState(): void {
    this.swUpdate.unrecoverable.subscribe(event => {
      console.error('Unrecoverable state:', event.reason);
      // Notify user to reload
      if (confirm('App is in an unrecoverable state. Reload to fix?')) {
        document.location.reload();
      }
    });
  }

  private promptUser(): boolean {
    return confirm('New version available. Load new version?');
  }
}

// app.component.ts - Initialize update service
import { Component, OnInit, inject } from '@angular/core';
import { SwUpdateService } from './sw-update.service';

@Component({
  selector: 'app-root',
  template: `
    <div class="app">
      <header>
        <h1>My PWA App</h1>
        @if (updateAvailable) {
          <div class="update-banner">
            <span>New version available!</span>
            <button (click)="reloadApp()">Update Now</button>
          </div>
        }
      </header>
      <router-outlet />
    </div>
  `,
  styles: [`
    .update-banner {
      background: #ff9800;
      color: white;
      padding: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .update-banner button {
      padding: 8px 16px;
      background: white;
      color: #ff9800;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
    }
  `]
})
export class AppComponent implements OnInit {
  private swUpdate = inject(SwUpdateService);
  updateAvailable = false;

  ngOnInit() {
    this.swUpdate.listenForUpdates();
    this.swUpdate.checkUnrecoverableState();
  }

  reloadApp() {
    document.location.reload();
  }
}
```

**Push Notifications:**

```typescript
// push-notification.service.ts
import { Injectable, inject } from '@angular/core';
import { SwPush } from '@angular/service-worker';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class PushNotificationService {
  private swPush = inject(SwPush);
  private http = inject(HttpClient);
  
  // VAPID public key from your server
  private readonly VAPID_PUBLIC_KEY = 'YOUR_VAPID_PUBLIC_KEY';

  // Request push subscription
  async subscribeToPush(): Promise<void> {
    if (!this.swPush.isEnabled) {
      console.error('Service Worker not enabled');
      return;
    }

    try {
      // Request permission
      const permission = await Notification.requestPermission();
      
      if (permission !== 'granted') {
        console.log('Notification permission denied');
        return;
      }

      // Subscribe to push notifications
      const subscription = await this.swPush.requestSubscription({
        serverPublicKey: this.VAPID_PUBLIC_KEY
      });

      // Send subscription to server
      await this.http.post('/api/push/subscribe', subscription).toPromise();
      console.log('Push subscription successful');
    } catch (error) {
      console.error('Could not subscribe to push:', error);
    }
  }

  // Listen for push messages
  listenToPushMessages(): void {
    this.swPush.messages.subscribe((message: any) => {
      console.log('Push message received:', message);
      
      // Show notification
      if ('Notification' in window && Notification.permission === 'granted') {
        new Notification(message.title, {
          body: message.body,
          icon: message.icon,
          badge: message.badge
        });
      }
    });
  }

  // Listen for notification clicks
  listenToNotificationClicks(): void {
    this.swPush.notificationClicks.subscribe((event: any) => {
      console.log('Notification clicked:', event);
      
      // Navigate to specific URL
      if (event.notification.data?.url) {
        window.open(event.notification.data.url, '_blank');
      }
    });
  }

  // Unsubscribe from push
  async unsubscribeFromPush(): Promise<void> {
    try {
      await this.swPush.unsubscribe();
      console.log('Unsubscribed from push notifications');
    } catch (error) {
      console.error('Could not unsubscribe:', error);
    }
  }
}

// Usage in component
import { Component, OnInit, inject } from '@angular/core';
import { PushNotificationService } from './push-notification.service';

@Component({
  selector: 'app-notifications',
  template: `
    <div class="notifications">
      <h3>Push Notifications</h3>
      
      <div class="controls">
        <button (click)="subscribe()">Subscribe</button>
        <button (click)="unsubscribe()">Unsubscribe</button>
        <button (click)="testNotification()">Test Notification</button>
      </div>
      
      <div class="status">
        Status: {{ isSubscribed ? 'Subscribed' : 'Not subscribed' }}
      </div>
    </div>
  `,
  styles: [`
    .notifications {
      padding: 20px;
    }
    .controls button {
      margin: 5px;
      padding: 8px 16px;
    }
    .status {
      margin-top: 16px;
      padding: 12px;
      background: #e3f2fd;
      border-radius: 4px;
    }
  `]
})
export class NotificationsComponent implements OnInit {
  private pushService = inject(PushNotificationService);
  isSubscribed = false;

  ngOnInit() {
    this.pushService.listenToPushMessages();
    this.pushService.listenToNotificationClicks();
  }

  async subscribe() {
    await this.pushService.subscribeToPush();
    this.isSubscribed = true;
  }

  async unsubscribe() {
    await this.pushService.unsubscribeFromPush();
    this.isSubscribed = false;
  }

  testNotification() {
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('Test Notification', {
        body: 'This is a test notification',
        icon: '/assets/icon-192x192.png'
      });
    }
  }
}
```

**Offline Support:**

```typescript
// offline.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of, throwError } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';

interface CachedData<T> {
  data: T;
  timestamp: number;
}

@Injectable({
  providedIn: 'root'
})
export class OfflineService {
  private http = inject(HttpClient);
  private cache = new Map<string, CachedData<any>>();
  private readonly CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

  // Fetch with offline fallback
  fetchWithCache<T>(url: string, useCache = true): Observable<T> {
    // Check if online
    if (!navigator.onLine && useCache) {
      return this.getCachedData<T>(url);
    }

    // Fetch from network
    return this.http.get<T>(url).pipe(
      tap(data => {
        // Cache successful response
        this.cacheData(url, data);
      }),
      catchError(error => {
        // If offline, try cache
        if (!navigator.onLine && useCache) {
          const cached = this.getCachedData<T>(url);
          if (cached) {
            return cached;
          }
        }
        return throwError(() => error);
      })
    );
  }

  private cacheData<T>(key: string, data: T): void {
    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }

  private getCachedData<T>(key: string): Observable<T> {
    const cached = this.cache.get(key);
    
    if (!cached) {
      return throwError(() => new Error('No cached data available'));
    }

    // Check if cache is still valid
    const age = Date.now() - cached.timestamp;
    if (age > this.CACHE_DURATION) {
      this.cache.delete(key);
      return throwError(() => new Error('Cache expired'));
    }

    console.log('Using cached data for:', key);
    return of(cached.data);
  }

  clearCache(): void {
    this.cache.clear();
  }

  // Monitor online/offline status
  monitorConnection(callback: (isOnline: boolean) => void): void {
    window.addEventListener('online', () => callback(true));
    window.addEventListener('offline', () => callback(false));
  }
}

// Usage
import { Component, OnInit, inject } from '@angular/core';
import { OfflineService } from './offline.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-offline-demo',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="offline-demo">
      <div class="connection-status" [class.online]="isOnline" [class.offline]="!isOnline">
        {{ isOnline ? '🟢 Online' : '🔴 Offline' }}
      </div>
      
      <h3>Products</h3>
      <button (click)="loadProducts()">Load Products</button>
      
      @if (loading) {
        <div class="loading">Loading...</div>
      }
      
      @for (product of products; track product.id) {
        <div class="product">
          <h4>{{ product.name }}</h4>
          <p>{{ product.price | currency }}</p>
        </div>
      }
      
      @if (usingCache) {
        <div class="cache-notice">
          ℹ️ Showing cached data (offline mode)
        </div>
      }
    </div>
  `,
  styles: [`
    .connection-status {
      padding: 12px;
      text-align: center;
      font-weight: bold;
      border-radius: 4px;
      margin-bottom: 16px;
    }
    .connection-status.online {
      background: #d4edda;
      color: #155724;
    }
    .connection-status.offline {
      background: #f8d7da;
      color: #721c24;
    }
    .product {
      padding: 12px;
      border: 1px solid #ddd;
      border-radius: 4px;
      margin: 8px 0;
    }
    .cache-notice {
      padding: 12px;
      background: #fff3cd;
      color: #856404;
      border-radius: 4px;
      margin-top: 16px;
    }
  `]
})
export class OfflineDemoComponent implements OnInit {
  private offlineService = inject(OfflineService);
  
  products: any[] = [];
  isOnline = navigator.onLine;
  loading = false;
  usingCache = false;

  ngOnInit() {
    this.offlineService.monitorConnection(isOnline => {
      this.isOnline = isOnline;
      console.log('Connection status changed:', isOnline ? 'online' : 'offline');
    });
  }

  loadProducts() {
    this.loading = true;
    this.usingCache = false;
    
    this.offlineService.fetchWithCache<any[]>('https://api.example.com/products')
      .subscribe({
        next: (products) => {
          this.products = products;
          this.loading = false;
          this.usingCache = !navigator.onLine;
        },
        error: (error) => {
          console.error('Failed to load products:', error);
          this.loading = false;
        }
      });
  }
}
```

#### React: Equivalent PWA Patterns

**Workbox with Create React App:**

```tsx
// service-worker.ts (using Workbox)
import { clientsClaim } from 'workbox-core';
import { ExpirationPlugin } from 'workbox-expiration';
import { precacheAndRoute, createHandlerBoundToURL } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { StaleWhileRevalidate, CacheFirst } from 'workbox-strategies';

declare const self: ServiceWorkerGlobalScope;

clientsClaim();

// Precache all assets
precacheAndRoute(self.__WB_MANIFEST);

// App shell cache strategy
const fileExtensionRegexp = new RegExp('/[^/?]+\\.[^/]+$');
registerRoute(
  ({ request, url }: { request: Request; url: URL }) => {
    if (request.mode !== 'navigate') {
      return false;
    }
    if (url.pathname.startsWith('/_')) {
      return false;
    }
    if (url.pathname.match(fileExtensionRegexp)) {
      return false;
    }
    return true;
  },
  createHandlerBoundToURL(process.env.PUBLIC_URL + '/index.html')
);

// API cache strategy
registerRoute(
  ({ url }) => url.origin === 'https://api.example.com',
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
    plugins: [
      new ExpirationPlugin({
        maxEntries: 100,
        maxAgeSeconds: 3 * 24 * 60 * 60, // 3 days
      }),
    ],
  })
);

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
```

**Service Worker Update Hook:**

```tsx
// useServiceWorker.ts
import { useEffect, useState } from 'react';
import * as serviceWorkerRegistration from './serviceWorkerRegistration';

export function useServiceWorker() {
  const [updateAvailable, setUpdateAvailable] = useState(false);
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null);

  useEffect(() => {
    serviceWorkerRegistration.register({
      onUpdate: (reg) => {
        setUpdateAvailable(true);
        setRegistration(reg);
      },
      onSuccess: (reg) => {
        console.log('Service Worker registered successfully');
      }
    });
  }, []);

  const updateServiceWorker = () => {
    if (registration && registration.waiting) {
      registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      window.location.reload();
    }
  };

  return { updateAvailable, updateServiceWorker };
}

// App.tsx
import React from 'react';
import { useServiceWorker } from './hooks/useServiceWorker';

function App() {
  const { updateAvailable, updateServiceWorker } = useServiceWorker();

  return (
    <div className="app">
      <header>
        <h1>My PWA App</h1>
        {updateAvailable && (
          <div className="update-banner">
            <span>New version available!</span>
            <button onClick={updateServiceWorker}>Update Now</button>
          </div>
        )}
      </header>
      {/* Rest of app */}
    </div>
  );
}

export default App;
```

**Push Notifications:**

```tsx
// usePushNotifications.ts
import { useState, useEffect } from 'react';

interface UsePushNotificationsReturn {
  isSupported: boolean;
  isSubscribed: boolean;
  subscribe: () => Promise<void>;
  unsubscribe: () => Promise<void>;
}

export function usePushNotifications(vapidPublicKey: string): UsePushNotificationsReturn {
  const [isSupported] = useState('serviceWorker' in navigator && 'PushManager' in window);
  const [isSubscribed, setIsSubscribed] = useState(false);

  useEffect(() => {
    if (isSupported) {
      checkSubscription();
    }
  }, [isSupported]);

  const checkSubscription = async () => {
    const registration = await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.getSubscription();
    setIsSubscribed(!!subscription);
  };

  const subscribe = async () => {
    if (!isSupported) return;

    const permission = await Notification.requestPermission();
    if (permission !== 'granted') {
      console.log('Notification permission denied');
      return;
    }

    const registration = await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(vapidPublicKey)
    });

    // Send subscription to server
    await fetch('/api/push/subscribe', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(subscription)
    });

    setIsSubscribed(true);
  };

  const unsubscribe = async () => {
    const registration = await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.getSubscription();
    
    if (subscription) {
      await subscription.unsubscribe();
      setIsSubscribed(false);
    }
  };

  return { isSupported, isSubscribed, subscribe, unsubscribe };
}

function urlBase64ToUint8Array(base64String: string): Uint8Array {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding)
    .replace(/\-/g, '+')
    .replace(/_/g, '/');
  
  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

// Usage
function NotificationsComponent() {
  const { isSupported, isSubscribed, subscribe, unsubscribe } = usePushNotifications('YOUR_VAPID_KEY');

  return (
    <div className="notifications">
      <h3>Push Notifications</h3>
      
      {!isSupported && (
        <p>Push notifications are not supported in your browser</p>
      )}
      
      {isSupported && (
        <div className="controls">
          {!isSubscribed ? (
            <button onClick={subscribe}>Subscribe</button>
          ) : (
            <button onClick={unsubscribe}>Unsubscribe</button>
          )}
        </div>
      )}
      
      <div className="status">
        Status: {isSubscribed ? 'Subscribed' : 'Not subscribed'}
      </div>
    </div>
  );
}
```

#### Comparison: PWA Support

| Feature | Angular PWA | React PWA |
|---------|------------|----------|
| **Setup** | @angular/pwa package | Workbox + manual setup |
| **Config** | ngsw-config.json | workbox-config.js |
| **Updates** | SwUpdate service | Custom hooks |
| **Push** | SwPush service | Push API directly |
| **Offline** | Built-in strategies | Workbox strategies |

**When to Use:**
- **Angular PWA:** Integrated solution with TypeScript support
- **React PWA:** Flexible with Workbox, requires more manual setup

**Further Reading:**
- [Angular Service Worker](https://angular.dev/ecosystem/service-workers)
- [Workbox](https://developers.google.com/web/tools/workbox)
- [PWA Checklist](https://web.dev/pwa-checklist/)

---

### 4. Renderer2 (Platform-Agnostic DOM Manipulation)

**Description:** Renderer2 provides a platform-agnostic API for DOM manipulation that works in both browser and server environments. It's essential for SSR compatibility and security.

#### Angular: Renderer2 Examples

**Basic DOM Manipulation:**

```typescript
// dynamic-styles.component.ts
import { Component, ElementRef, Renderer2, OnInit, inject } from '@angular/core';

@Component({
  selector: 'app-dynamic-styles',
  standalone: true,
  template: `
    <div class="container" #container>
      <h3>Dynamic Styling with Renderer2</h3>
      <p #textElement>This text will be styled dynamically</p>
      
      <div class="controls">
        <button (click)="changeColor()">Change Color</button>
        <button (click)="toggleClass()">Toggle Class</button>
        <button (click)="addBorder()">Add Border</button>
        <button (click)="setAttribute()">Set Attribute</button>
        <button (click)="removeStyles()">Remove Styles</button>
      </div>
      
      <div #dynamicContent></div>
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 8px;
    }
    .controls button {
      margin: 5px;
      padding: 8px 16px;
    }
    .highlight {
      background-color: yellow;
      font-weight: bold;
    }
  `]
})
export class DynamicStylesComponent implements OnInit {
  private renderer = inject(Renderer2);
  private elementRef = inject(ElementRef);

  ngOnInit() {
    // Safe DOM access through Renderer2
    const container = this.elementRef.nativeElement.querySelector('.container');
    // Set initial styles
    this.renderer.setStyle(container, 'transition', 'all 0.3s ease');
  }

  changeColor() {
    const textElement = this.elementRef.nativeElement.querySelector('p');
    // Generate random color
    const randomColor = `#${Math.floor(Math.random()*16777215).toString(16)}`;
    // Set style using Renderer2 (SSR-safe)
    this.renderer.setStyle(textElement, 'color', randomColor);
    this.renderer.setStyle(textElement, 'font-size', '20px');
  }

  toggleClass() {
    const textElement = this.elementRef.nativeElement.querySelector('p');
    // Check if class exists
    const hasClass = textElement.classList.contains('highlight');
    
    if (hasClass) {
      // Remove class
      this.renderer.removeClass(textElement, 'highlight');
    } else {
      // Add class
      this.renderer.addClass(textElement, 'highlight');
    }
  }

  addBorder() {
    const textElement = this.elementRef.nativeElement.querySelector('p');
    // Add multiple styles
    this.renderer.setStyle(textElement, 'border', '2px solid #007bff');
    this.renderer.setStyle(textElement, 'padding', '10px');
    this.renderer.setStyle(textElement, 'border-radius', '4px');
  }

  setAttribute() {
    const textElement = this.elementRef.nativeElement.querySelector('p');
    // Set custom attribute
    this.renderer.setAttribute(textElement, 'data-modified', 'true');
    this.renderer.setAttribute(textElement, 'title', 'Modified by Renderer2');
  }

  removeStyles() {
    const textElement = this.elementRef.nativeElement.querySelector('p');
    // Remove specific styles
    this.renderer.removeStyle(textElement, 'color');
    this.renderer.removeStyle(textElement, 'font-size');
    this.renderer.removeStyle(textElement, 'border');
    this.renderer.removeStyle(textElement, 'padding');
    this.renderer.removeClass(textElement, 'highlight');
  }
}
```

**Creating and Appending Elements:**

```typescript
// notification.service.ts
import { Injectable, Renderer2, RendererFactory2, inject } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private renderer: Renderer2;
  private notificationContainer?: HTMLElement;

  constructor() {
    // Get Renderer2 instance from factory
    const rendererFactory = inject(RendererFactory2);
    this.renderer = rendererFactory.createRenderer(null, null);
  }

  show(message: string, type: 'success' | 'error' | 'info' = 'info', duration = 3000): void {
    // Create notification container if doesn't exist
    if (!this.notificationContainer) {
      this.createContainer();
    }

    // Create notification element
    const notification = this.renderer.createElement('div');
    
    // Add classes
    this.renderer.addClass(notification, 'notification');
    this.renderer.addClass(notification, `notification-${type}`);
    
    // Set text content
    const text = this.renderer.createText(message);
    this.renderer.appendChild(notification, text);
    
    // Add close button
    const closeBtn = this.renderer.createElement('button');
    this.renderer.addClass(closeBtn, 'close-btn');
    const closeBtnText = this.renderer.createText('×');
    this.renderer.appendChild(closeBtn, closeBtnText);
    
    // Add click listener to close button
    const unlisten = this.renderer.listen(closeBtn, 'click', () => {
      this.removeNotification(notification);
      unlisten(); // Remove listener
    });
    
    this.renderer.appendChild(notification, closeBtn);
    
    // Append to container
    this.renderer.appendChild(this.notificationContainer, notification);
    
    // Apply styles
    this.applyNotificationStyles(notification, type);
    
    // Auto-remove after duration
    setTimeout(() => {
      this.removeNotification(notification);
    }, duration);
  }

  private createContainer(): void {
    // Create container for notifications
    this.notificationContainer = this.renderer.createElement('div');
    this.renderer.addClass(this.notificationContainer, 'notification-container');
    
    // Style container
    this.renderer.setStyle(this.notificationContainer, 'position', 'fixed');
    this.renderer.setStyle(this.notificationContainer, 'top', '20px');
    this.renderer.setStyle(this.notificationContainer, 'right', '20px');
    this.renderer.setStyle(this.notificationContainer, 'z-index', '9999');
    
    // Append to body
    this.renderer.appendChild(document.body, this.notificationContainer);
  }

  private applyNotificationStyles(element: HTMLElement, type: string): void {
    // Base styles
    this.renderer.setStyle(element, 'padding', '16px 40px 16px 16px');
    this.renderer.setStyle(element, 'margin-bottom', '10px');
    this.renderer.setStyle(element, 'border-radius', '4px');
    this.renderer.setStyle(element, 'box-shadow', '0 2px 8px rgba(0,0,0,0.15)');
    this.renderer.setStyle(element, 'min-width', '250px');
    this.renderer.setStyle(element, 'position', 'relative');
    this.renderer.setStyle(element, 'animation', 'slideIn 0.3s ease');
    
    // Type-specific styles
    const colors = {
      success: { bg: '#d4edda', color: '#155724', border: '#c3e6cb' },
      error: { bg: '#f8d7da', color: '#721c24', border: '#f5c6cb' },
      info: { bg: '#d1ecf1', color: '#0c5460', border: '#bee5eb' }
    };
    
    const colorScheme = colors[type];
    this.renderer.setStyle(element, 'background-color', colorScheme.bg);
    this.renderer.setStyle(element, 'color', colorScheme.color);
    this.renderer.setStyle(element, 'border', `1px solid ${colorScheme.border}`);
  }

  private removeNotification(element: HTMLElement): void {
    // Add fade out animation
    this.renderer.setStyle(element, 'animation', 'slideOut 0.3s ease');
    
    // Remove after animation
    setTimeout(() => {
      if (this.notificationContainer && element.parentNode === this.notificationContainer) {
        this.renderer.removeChild(this.notificationContainer, element);
      }
    }, 300);
  }
}

// Usage in component
import { Component, inject } from '@angular/core';
import { NotificationService } from './notification.service';

@Component({
  selector: 'app-notification-demo',
  standalone: true,
  template: `
    <div class="demo">
      <h3>Notification System</h3>
      <div class="controls">
        <button (click)="showSuccess()">Success</button>
        <button (click)="showError()">Error</button>
        <button (click)="showInfo()">Info</button>
      </div>
    </div>
  `
})
export class NotificationDemoComponent {
  private notifications = inject(NotificationService);

  showSuccess() {
    this.notifications.show('Operation completed successfully!', 'success');
  }

  showError() {
    this.notifications.show('An error occurred!', 'error');
  }

  showInfo() {
    this.notifications.show('This is an informational message.', 'info');
  }
}
```

**Event Listeners and Cleanup:**

```typescript
// click-outside.directive.ts
import { Directive, ElementRef, EventEmitter, Output, Renderer2, OnInit, OnDestroy, inject } from '@angular/core';

@Directive({
  selector: '[appClickOutside]',
  standalone: true
})
export class ClickOutsideDirective implements OnInit, OnDestroy {
  @Output() clickOutside = new EventEmitter<void>();
  
  private elementRef = inject(ElementRef);
  private renderer = inject(Renderer2);
  private unlistenClick?: () => void;

  ngOnInit() {
    // Add global click listener using Renderer2
    // Will be properly cleaned up on destroy
    this.unlistenClick = this.renderer.listen('document', 'click', (event: Event) => {
      const clickedInside = this.elementRef.nativeElement.contains(event.target);
      
      if (!clickedInside) {
        // Clicked outside the element
        this.clickOutside.emit();
      }
    });
  }

  ngOnDestroy() {
    // Clean up event listener
    if (this.unlistenClick) {
      this.unlistenClick();
    }
  }
}

// dropdown.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClickOutsideDirective } from './click-outside.directive';

@Component({
  selector: 'app-dropdown',
  standalone: true,
  imports: [CommonModule, ClickOutsideDirective],
  template: `
    <div class="dropdown" appClickOutside (clickOutside)="close()">
      <button (click)="toggle()">
        {{ selectedOption || 'Select an option' }}
      </button>
      
      @if (isOpen) {
        <div class="dropdown-menu">
          @for (option of options; track option) {
            <div class="dropdown-item" (click)="select(option)">
              {{ option }}
            </div>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .dropdown {
      position: relative;
      display: inline-block;
    }
    .dropdown button {
      padding: 8px 16px;
      border: 1px solid #ddd;
      border-radius: 4px;
      background: white;
      cursor: pointer;
    }
    .dropdown-menu {
      position: absolute;
      top: 100%;
      left: 0;
      min-width: 200px;
      margin-top: 4px;
      background: white;
      border: 1px solid #ddd;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      z-index: 1000;
    }
    .dropdown-item {
      padding: 8px 16px;
      cursor: pointer;
    }
    .dropdown-item:hover {
      background: #f8f9fa;
    }
  `]
})
export class DropdownComponent {
  isOpen = false;
  selectedOption = '';
  options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  toggle() {
    this.isOpen = !this.isOpen;
  }

  select(option: string) {
    this.selectedOption = option;
    this.isOpen = false;
  }

  close() {
    this.isOpen = false;
  }
}
```

#### React: Equivalent DOM Manipulation

**Direct DOM with Refs:**

```tsx
// DynamicStyles.tsx
import React, { useRef } from 'react';

function DynamicStyles() {
  const textRef = useRef<HTMLParagraphElement>(null);

  const changeColor = () => {
    if (textRef.current) {
      const randomColor = `#${Math.floor(Math.random()*16777215).toString(16)}`;
      textRef.current.style.color = randomColor;
      textRef.current.style.fontSize = '20px';
    }
  };

  const toggleClass = () => {
    if (textRef.current) {
      textRef.current.classList.toggle('highlight');
    }
  };

  const addBorder = () => {
    if (textRef.current) {
      textRef.current.style.border = '2px solid #007bff';
      textRef.current.style.padding = '10px';
      textRef.current.style.borderRadius = '4px';
    }
  };

  const setAttribute = () => {
    if (textRef.current) {
      textRef.current.setAttribute('data-modified', 'true');
      textRef.current.setAttribute('title', 'Modified directly');
    }
  };

  const removeStyles = () => {
    if (textRef.current) {
      textRef.current.style.color = '';
      textRef.current.style.fontSize = '';
      textRef.current.style.border = '';
      textRef.current.style.padding = '';
      textRef.current.classList.remove('highlight');
    }
  };

  return (
    <div className="container">
      <h3>Dynamic Styling with Refs</h3>
      <p ref={textRef}>This text will be styled dynamically</p>
      
      <div className="controls">
        <button onClick={changeColor}>Change Color</button>
        <button onClick={toggleClass}>Toggle Class</button>
        <button onClick={addBorder}>Add Border</button>
        <button onClick={setAttribute}>Set Attribute</button>
        <button onClick={removeStyles}>Remove Styles</button>
      </div>
    </div>
  );
}

export default DynamicStyles;
```

**Creating Elements with React Portal:**

```tsx
// useNotification.ts
import { useState, useCallback } from 'react';
import ReactDOM from 'react-dom';

interface Notification {
  id: string;
  message: string;
  type: 'success' | 'error' | 'info';
}

export function useNotification() {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  const show = useCallback((message: string, type: 'success' | 'error' | 'info' = 'info', duration = 3000) => {
    const id = Math.random().toString(36).substr(2, 9);
    const notification = { id, message, type };
    
    setNotifications(prev => [...prev, notification]);
    
    setTimeout(() => {
      setNotifications(prev => prev.filter(n => n.id !== id));
    }, duration);
  }, []);

  return { notifications, show };
}

// NotificationContainer.tsx
interface NotificationContainerProps {
  notifications: Array<{
    id: string;
    message: string;
    type: 'success' | 'error' | 'info';
  }>;
  onClose: (id: string) => void;
}

function NotificationContainer({ notifications, onClose }: NotificationContainerProps) {
  if (notifications.length === 0) return null;

  return ReactDOM.createPortal(
    <div className="notification-container">
      {notifications.map(notification => (
        <div
          key={notification.id}
          className={`notification notification-${notification.type}`}
        >
          {notification.message}
          <button className="close-btn" onClick={() => onClose(notification.id)}>
            ×
          </button>
        </div>
      ))}
    </div>,
    document.body
  );
}

// Usage
function App() {
  const { notifications, show } = useNotification();

  return (
    <div>
      <button onClick={() => show('Success!', 'success')}>Success</button>
      <button onClick={() => show('Error!', 'error')}>Error</button>
      <NotificationContainer
        notifications={notifications}
        onClose={(id) => {/* handle close */}}
      />
    </div>
  );
}
```

**Click Outside Hook:**

```tsx
// useClickOutside.ts
import { useEffect, useRef, RefObject } from 'react';

export function useClickOutside<T extends HTMLElement>(
  callback: () => void
): RefObject<T> {
  const ref = useRef<T>(null);

  useEffect(() => {
    const handleClick = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        callback();
      }
    };

    document.addEventListener('click', handleClick);
    return () => document.removeEventListener('click', handleClick);
  }, [callback]);

  return ref;
}

// Dropdown.tsx
function Dropdown() {
  const [isOpen, setIsOpen] = React.useState(false);
  const [selectedOption, setSelectedOption] = React.useState('');
  const dropdownRef = useClickOutside<HTMLDivElement>(() => setIsOpen(false));
  
  const options = ['Option 1', 'Option 2', 'Option 3', 'Option 4'];

  return (
    <div className="dropdown" ref={dropdownRef}>
      <button onClick={() => setIsOpen(!isOpen)}>
        {selectedOption || 'Select an option'}
      </button>
      
      {isOpen && (
        <div className="dropdown-menu">
          {options.map(option => (
            <div
              key={option}
              className="dropdown-item"
              onClick={() => {
                setSelectedOption(option);
                setIsOpen(false);
              }}
            >
              {option}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

#### Comparison: Renderer2 vs Direct DOM

| Feature | Angular Renderer2 | React Direct DOM |
|---------|------------------|-----------------|
| **SSR Safety** | ✅ Platform-agnostic | ❌ Browser-only |
| **API** | Renderer2 methods | Direct element access |
| **Event Listeners** | listen() with auto-cleanup | addEventListener + manual cleanup |
| **Element Creation** | createElement() | document.createElement() |
| **Security** | Built-in sanitization | Manual sanitization |

**When to Use:**
- **Angular Renderer2:** Always for SSR compatibility and security
- **React:** Direct DOM manipulation with refs (SSR requires checks)

**Further Reading:**
- [Angular Renderer2](https://angular.dev/api/core/Renderer2)
- [React Refs](https://react.dev/reference/react/useRef)

---

### 5. APP_INITIALIZER

**Description:** APP_INITIALIZER is a DI token that allows you to run initialization logic before the app starts. Perfect for loading configuration, checking authentication, or setting up app-wide services.

#### Angular: APP_INITIALIZER Examples

**Loading Configuration:**

```typescript
// config.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

export interface AppConfig {
  apiUrl: string;
  environment: string;
  features: {
    enableAnalytics: boolean;
    enableNotifications: boolean;
  };
}

@Injectable({
  providedIn: 'root'
})
export class ConfigService {
  private config?: AppConfig;

  constructor(private http: HttpClient) {}

  // Load config before app starts
  async loadConfig(): Promise<void> {
    try {
      // Fetch configuration from server
      this.config = await firstValueFrom(
        this.http.get<AppConfig>('/assets/config.json')
      );
      console.log('Configuration loaded:', this.config);
    } catch (error) {
      console.error('Failed to load configuration:', error);
      // Provide fallback config
      this.config = {
        apiUrl: 'https://api.example.com',
        environment: 'production',
        features: {
          enableAnalytics: false,
          enableNotifications: false
        }
      };
    }
  }

  getConfig(): AppConfig {
    if (!this.config) {
      throw new Error('Configuration not loaded!');
    }
    return this.config;
  }

  get apiUrl(): string {
    return this.getConfig().apiUrl;
  }

  get environment(): string {
    return this.getConfig().environment;
  }

  isFeatureEnabled(feature: keyof AppConfig['features']): boolean {
    return this.getConfig().features[feature];
  }
}

// app.config.ts
import { ApplicationConfig, APP_INITIALIZER } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';
import { ConfigService } from './config.service';

// Factory function for APP_INITIALIZER
export function initializeApp(configService: ConfigService): () => Promise<void> {
  return () => configService.loadConfig();
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(),
    {
      provide: APP_INITIALIZER,
      useFactory: initializeApp,
      deps: [ConfigService],
      multi: true // Important: allows multiple initializers
    }
  ]
};

// Usage in component
import { Component, OnInit, inject } from '@angular/core';
import { ConfigService } from './config.service';

@Component({
  selector: 'app-root',
  template: `
    <div class="app">
      <h1>App Configuration</h1>
      <div class="config-info">
        <p>API URL: {{ config.apiUrl }}</p>
        <p>Environment: {{ config.environment }}</p>
        <p>Analytics: {{ config.features.enableAnalytics ? 'Enabled' : 'Disabled' }}</p>
        <p>Notifications: {{ config.features.enableNotifications ? 'Enabled' : 'Disabled' }}</p>
      </div>
    </div>
  `
})
export class AppComponent implements OnInit {
  private configService = inject(ConfigService);
  config!: AppConfig;

  ngOnInit() {
    // Config is guaranteed to be loaded
    this.config = this.configService.getConfig();
  }
}
```

**Authentication Initialization:**

```typescript
// auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, firstValueFrom } from 'rxjs';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUserSubject = new BehaviorSubject<User | null>(null);
  currentUser$ = this.currentUserSubject.asObservable();

  constructor(private http: HttpClient) {}

  // Initialize authentication state
  async initialize(): Promise<void> {
    const token = localStorage.getItem('auth_token');
    
    if (!token) {
      console.log('No token found');
      return;
    }

    try {
      // Verify token and get user
      const user = await firstValueFrom(
        this.http.get<User>('/api/auth/verify', {
          headers: { Authorization: `Bearer ${token}` }
        })
      );
      
      this.currentUserSubject.next(user);
      console.log('User authenticated:', user);
    } catch (error) {
      console.error('Token verification failed:', error);
      localStorage.removeItem('auth_token');
    }
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }

  isAuthenticated(): boolean {
    return this.currentUserSubject.value !== null;
  }

  hasRole(role: string): boolean {
    const user = this.getCurrentUser();
    return user?.role === role;
  }
}

// app.config.ts with multiple initializers
import { ApplicationConfig, APP_INITIALIZER } from '@angular/core';
import { ConfigService } from './config.service';
import { AuthService } from './auth.service';

export function initializeConfig(configService: ConfigService) {
  return () => configService.loadConfig();
}

export function initializeAuth(authService: AuthService) {
  return () => authService.initialize();
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(),
    // Multiple APP_INITIALIZER providers
    {
      provide: APP_INITIALIZER,
      useFactory: initializeConfig,
      deps: [ConfigService],
      multi: true
    },
    {
      provide: APP_INITIALIZER,
      useFactory: initializeAuth,
      deps: [AuthService],
      multi: true
    }
  ]
};
```

**Complex Initialization with Dependencies:**

```typescript
// translation.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ConfigService } from './config.service';
import { firstValueFrom } from 'rxjs';

interface Translations {
  [key: string]: string;
}

@Injectable({
  providedIn: 'root'
})
export class TranslationService {
  private translations: Translations = {};
  private currentLang = 'en';

  constructor(
    private http: HttpClient,
    private config: ConfigService
  ) {}

  // Initialize translations - depends on ConfigService
  async initialize(): Promise<void> {
    // Get default language from config
    const defaultLang = this.config.getConfig().defaultLanguage || 'en';
    
    // Load browser language or stored preference
    const storedLang = localStorage.getItem('language');
    const browserLang = navigator.language.split('-')[0];
    this.currentLang = storedLang || browserLang || defaultLang;
    
    try {
      // Load translations
      this.translations = await firstValueFrom(
        this.http.get<Translations>(`/assets/i18n/${this.currentLang}.json`)
      );
      console.log(`Translations loaded for: ${this.currentLang}`);
    } catch (error) {
      console.error('Failed to load translations:', error);
      // Load fallback language
      if (this.currentLang !== defaultLang) {
        this.translations = await firstValueFrom(
          this.http.get<Translations>(`/assets/i18n/${defaultLang}.json`)
        );
      }
    }
  }

  translate(key: string): string {
    return this.translations[key] || key;
  }

  setLanguage(lang: string): void {
    this.currentLang = lang;
    localStorage.setItem('language', lang);
    // Reload translations
    this.initialize();
  }
}

// app.config.ts with ordered initialization
import { ApplicationConfig, APP_INITIALIZER } from '@angular/core';
import { ConfigService } from './config.service';
import { AuthService } from './auth.service';
import { TranslationService } from './translation.service';

// Initializers run in order of registration
export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(),
    // 1. Load config first
    {
      provide: APP_INITIALIZER,
      useFactory: (config: ConfigService) => () => config.loadConfig(),
      deps: [ConfigService],
      multi: true
    },
    // 2. Then initialize auth
    {
      provide: APP_INITIALIZER,
      useFactory: (auth: AuthService) => () => auth.initialize(),
      deps: [AuthService],
      multi: true
    },
    // 3. Finally load translations (depends on config)
    {
      provide: APP_INITIALIZER,
      useFactory: (translation: TranslationService) => () => translation.initialize(),
      deps: [TranslationService],
      multi: true
    }
  ]
};
```

#### React: Equivalent Initialization Patterns

**Configuration Loading:**

```tsx
// ConfigContext.tsx
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface AppConfig {
  apiUrl: string;
  environment: string;
  features: {
    enableAnalytics: boolean;
    enableNotifications: boolean;
  };
}

interface ConfigContextType {
  config: AppConfig | null;
  loading: boolean;
}

const ConfigContext = createContext<ConfigContextType | null>(null);

export function ConfigProvider({ children }: { children: ReactNode }) {
  const [config, setConfig] = useState<AppConfig | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadConfig = async () => {
      try {
        const response = await fetch('/assets/config.json');
        const data = await response.json();
        setConfig(data);
      } catch (error) {
        console.error('Failed to load configuration:', error);
        // Fallback config
        setConfig({
          apiUrl: 'https://api.example.com',
          environment: 'production',
          features: {
            enableAnalytics: false,
            enableNotifications: false
          }
        });
      } finally {
        setLoading(false);
      }
    };

    loadConfig();
  }, []);

  if (loading) {
    return <div>Loading configuration...</div>;
  }

  return (
    <ConfigContext.Provider value={{ config, loading }}>
      {children}
    </ConfigContext.Provider>
  );
}

export function useConfig() {
  const context = useContext(ConfigContext);
  if (!context) {
    throw new Error('useConfig must be used within ConfigProvider');
  }
  return context;
}

// App.tsx
function App() {
  return (
    <ConfigProvider>
      <MainApp />
    </ConfigProvider>
  );
}

function MainApp() {
  const { config } = useConfig();

  return (
    <div>
      <h1>App Configuration</h1>
      <p>API URL: {config?.apiUrl}</p>
      <p>Environment: {config?.environment}</p>
    </div>
  );
}
```

**Authentication Initialization:**

```tsx
// AuthContext.tsx
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const initializeAuth = async () => {
      const token = localStorage.getItem('auth_token');
      
      if (!token) {
        setLoading(false);
        return;
      }

      try {
        const response = await fetch('/api/auth/verify', {
          headers: { Authorization: `Bearer ${token}` }
        });
        const userData = await response.json();
        setUser(userData);
      } catch (error) {
        console.error('Token verification failed:', error);
        localStorage.removeItem('auth_token');
      } finally {
        setLoading(false);
      }
    };

    initializeAuth();
  }, []);

  if (loading) {
    return <div>Authenticating...</div>;
  }

  return (
    <AuthContext.Provider value={{ user, loading, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

**Combined Initialization:**

```tsx
// AppProviders.tsx
import React, { ReactNode } from 'react';
import { ConfigProvider } from './ConfigContext';
import { AuthProvider } from './AuthContext';
import { TranslationProvider } from './TranslationContext';

export function AppProviders({ children }: { children: ReactNode }) {
  return (
    <ConfigProvider>
      <AuthProvider>
        <TranslationProvider>
          {children}
        </TranslationProvider>
      </AuthProvider>
    </ConfigProvider>
  );
}

// App.tsx
import { AppProviders } from './AppProviders';

function App() {
  return (
    <AppProviders>
      <MainApp />
    </AppProviders>
  );
}
```

#### Comparison: APP_INITIALIZER

| Feature | Angular APP_INITIALIZER | React Context Init |
|---------|------------------------|-------------------|
| **Timing** | Before app bootstrap | During render |
| **Blocking** | Blocks app startup | Shows loading state |
| **Dependencies** | DI system | Props/context nesting |
| **Multiple Init** | multi: true | Nested providers |
| **Error Handling** | Promise rejection | Try/catch + state |

**When to Use:**
- **Angular APP_INITIALIZER:** Critical data needed before app renders
- **React:** Context providers with loading states

**Further Reading:**
- [Angular APP_INITIALIZER](https://angular.dev/api/core/APP_INITIALIZER)
- [React Context](https://react.dev/reference/react/useContext)

---

### 6. HttpContext (Request-Specific Metadata)

**Description:** HttpContext allows you to pass metadata with HTTP requests without modifying headers. Perfect for configuring interceptors on a per-request basis (authentication, caching, retry logic).

#### Angular: HttpContext Examples

**Basic HttpContext Usage:**

```typescript
// http-context-tokens.ts
import { HttpContextToken } from '@angular/common/http';

// Define context tokens
export const BYPASS_AUTH = new HttpContextToken<boolean>(() => false);
export const CACHE_ENABLED = new HttpContextToken<boolean>(() => true);
export const RETRY_COUNT = new HttpContextToken<number>(() => 0);
export const SHOW_LOADER = new HttpContextToken<boolean>(() => true);

// api.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpContext } from '@angular/common/http';
import { Observable } from 'rxjs';
import { BYPASS_AUTH, CACHE_ENABLED, RETRY_COUNT, SHOW_LOADER } from './http-context-tokens';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private http = inject(HttpClient);
  private readonly API_URL = 'https://api.example.com';

  // Request with authentication
  getProtectedData(): Observable<any> {
    return this.http.get(`${this.API_URL}/protected`, {
      context: new HttpContext()
        .set(BYPASS_AUTH, false) // Require authentication
        .set(CACHE_ENABLED, true)
        .set(SHOW_LOADER, true)
    });
  }

  // Public request without authentication
  getPublicData(): Observable<any> {
    return this.http.get(`${this.API_URL}/public`, {
      context: new HttpContext()
        .set(BYPASS_AUTH, true) // Skip auth interceptor
        .set(CACHE_ENABLED, true)
        .set(SHOW_LOADER, false) // Don't show loader
    });
  }

  // Request with retry logic
  getUnreliableData(): Observable<any> {
    return this.http.get(`${this.API_URL}/unreliable`, {
      context: new HttpContext()
        .set(RETRY_COUNT, 3) // Retry 3 times on failure
        .set(CACHE_ENABLED, false)
    });
  }

  // Silent background request
  refreshData(): Observable<any> {
    return this.http.get(`${this.API_URL}/refresh`, {
      context: new HttpContext()
        .set(SHOW_LOADER, false) // Don't show loader
        .set(BYPASS_AUTH, false)
    });
  }
}
```

**Auth Interceptor with HttpContext:**

```typescript
// auth.interceptor.ts
import { HttpInterceptorFn, HttpContext } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from './auth.service';
import { BYPASS_AUTH } from './http-context-tokens';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  // Check if request should bypass authentication
  if (req.context.get(BYPASS_AUTH)) {
    console.log('Bypassing auth for:', req.url);
    return next(req);
  }

  // Get auth service
  const authService = inject(AuthService);
  const token = authService.getToken();

  if (!token) {
    console.warn('No auth token available');
    return next(req);
  }

  // Clone request and add auth header
  const authReq = req.clone({
    headers: req.headers.set('Authorization', `Bearer ${token}`)
  });

  console.log('Adding auth token to:', req.url);
  return next(authReq);
};

// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { authInterceptor } from './auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor])
    )
  ]
};
```

**Cache Interceptor with HttpContext:**

```typescript
// cache.interceptor.ts
import { HttpInterceptorFn, HttpResponse } from '@angular/common/http';
import { of } from 'rxjs';
import { tap } from 'rxjs/operators';
import { CACHE_ENABLED } from './http-context-tokens';

// Simple in-memory cache
const cache = new Map<string, HttpResponse<any>>();

export const cacheInterceptor: HttpInterceptorFn = (req, next) => {
  // Check if caching is enabled for this request
  if (!req.context.get(CACHE_ENABLED)) {
    return next(req);
  }

  // Only cache GET requests
  if (req.method !== 'GET') {
    return next(req);
  }

  // Check cache
  const cachedResponse = cache.get(req.urlWithParams);
  if (cachedResponse) {
    console.log('Returning cached response for:', req.url);
    return of(cachedResponse.clone());
  }

  // Make request and cache response
  return next(req).pipe(
    tap(event => {
      if (event instanceof HttpResponse) {
        console.log('Caching response for:', req.url);
        cache.set(req.urlWithParams, event.clone());
      }
    })
  );
};
```

**Retry Interceptor with HttpContext:**

```typescript
// retry.interceptor.ts
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { retry, timer } from 'rxjs';
import { RETRY_COUNT } from './http-context-tokens';

export const retryInterceptor: HttpInterceptorFn = (req, next) => {
  const retryCount = req.context.get(RETRY_COUNT);

  if (retryCount === 0) {
    return next(req);
  }

  console.log(`Retry enabled (${retryCount} times) for:`, req.url);

  return next(req).pipe(
    retry({
      count: retryCount,
      delay: (error: HttpErrorResponse, retryAttempt: number) => {
        // Exponential backoff
        const delayMs = Math.min(1000 * Math.pow(2, retryAttempt), 10000);
        console.log(`Retry attempt ${retryAttempt} after ${delayMs}ms`);
        return timer(delayMs);
      },
      resetOnSuccess: true
    })
  );
};
```

**Loading Interceptor with HttpContext:**

```typescript
// loading.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { finalize } from 'rxjs';
import { LoadingService } from './loading.service';
import { SHOW_LOADER } from './http-context-tokens';

export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  // Check if loader should be shown
  if (!req.context.get(SHOW_LOADER)) {
    return next(req);
  }

  const loadingService = inject(LoadingService);
  
  // Show loader
  loadingService.show();

  return next(req).pipe(
    finalize(() => {
      // Hide loader when request completes
      loadingService.hide();
    })
  );
};

// loading.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class LoadingService {
  private loadingSubject = new BehaviorSubject<boolean>(false);
  loading$ = this.loadingSubject.asObservable();

  show(): void {
    this.loadingSubject.next(true);
  }

  hide(): void {
    this.loadingSubject.next(false);
  }
}

// loading.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LoadingService } from './loading.service';

@Component({
  selector: 'app-loading',
  standalone: true,
  imports: [CommonModule],
  template: `
    @if (loadingService.loading$ | async) {
      <div class="loading-overlay">
        <div class="spinner"></div>
      </div>
    }
  `,
  styles: [`
    .loading-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 9999;
    }
    .spinner {
      width: 50px;
      height: 50px;
      border: 5px solid #f3f3f3;
      border-top: 5px solid #3498db;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  `]
})
export class LoadingComponent {
  loadingService = inject(LoadingService);
}
```

**Complete Interceptor Chain:**

```typescript
// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { authInterceptor } from './auth.interceptor';
import { cacheInterceptor } from './cache.interceptor';
import { retryInterceptor } from './retry.interceptor';
import { loadingInterceptor } from './loading.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([
        loadingInterceptor,  // First: show/hide loader
        authInterceptor,     // Second: add auth token
        cacheInterceptor,    // Third: check/store cache
        retryInterceptor     // Last: retry on failure
      ])
    )
  ]
};
```

#### React: Equivalent Request Configuration

**Axios with Request Config:**

```tsx
// api.ts
import axios, { AxiosRequestConfig } from 'axios';

// Custom config interface
interface CustomRequestConfig extends AxiosRequestConfig {
  skipAuth?: boolean;
  enableCache?: boolean;
  retryCount?: number;
  showLoader?: boolean;
}

const api = axios.create({
  baseURL: 'https://api.example.com'
});

// Auth interceptor
api.interceptors.request.use((config: any) => {
  if (config.skipAuth) {
    return config;
  }
  
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  
  return config;
});

// Response interceptor for retry
api.interceptors.response.use(
  response => response,
  async error => {
    const config: any = error.config;
    const retryCount = config.retryCount || 0;
    
    if (retryCount > 0 && !config._retry) {
      config._retry = true;
      config._retryAttempts = (config._retryAttempts || 0) + 1;
      
      if (config._retryAttempts <= retryCount) {
        const delay = Math.min(1000 * Math.pow(2, config._retryAttempts), 10000);
        await new Promise(resolve => setTimeout(resolve, delay));
        return api(config);
      }
    }
    
    return Promise.reject(error);
  }
);

// API methods with custom config
export const apiService = {
  getProtectedData: () => 
    api.get('/protected', {
      skipAuth: false,
      enableCache: true,
      showLoader: true
    } as CustomRequestConfig),
  
  getPublicData: () =>
    api.get('/public', {
      skipAuth: true,
      enableCache: true,
      showLoader: false
    } as CustomRequestConfig),
  
  getUnreliableData: () =>
    api.get('/unreliable', {
      retryCount: 3,
      enableCache: false
    } as CustomRequestConfig)
};
```

**React Query with Custom Config:**

```tsx
// useApiQuery.ts
import { useQuery, QueryKey } from '@tanstack/react-query';
import axios from 'axios';

interface ApiQueryOptions {
  skipAuth?: boolean;
  enableCache?: boolean;
  retryCount?: number;
  showLoader?: boolean;
}

export function useApiQuery<T>(
  key: QueryKey,
  url: string,
  options: ApiQueryOptions = {}
) {
  const {
    skipAuth = false,
    enableCache = true,
    retryCount = 0,
    showLoader = true
  } = options;

  return useQuery<T>({
    queryKey: key,
    queryFn: async () => {
      const config: any = {
        headers: {}
      };
      
      // Add auth if needed
      if (!skipAuth) {
        const token = localStorage.getItem('auth_token');
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
      }
      
      const response = await axios.get<T>(url, config);
      return response.data;
    },
    staleTime: enableCache ? 5 * 60 * 1000 : 0, // 5 minutes
    retry: retryCount,
    retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 10000)
  });
}

// Usage
function ProtectedDataComponent() {
  const { data, isLoading } = useApiQuery(
    ['protectedData'],
    '/api/protected',
    {
      skipAuth: false,
      enableCache: true,
      showLoader: true
    }
  );

  if (isLoading) return <div>Loading...</div>;
  
  return <div>{JSON.stringify(data)}</div>;
}
```

#### Comparison: HttpContext

| Feature | Angular HttpContext | React Custom Config |
|---------|-------------------|-------------------|
| **Type Safety** | ✅ HttpContextToken | ⚠️ Interface extension |
| **Interceptor Access** | context.get(TOKEN) | Custom config properties |
| **Per-Request Config** | ✅ Built-in | Manual implementation |
| **Default Values** | Token factory function | Default parameters |

**When to Use:**
- **Angular HttpContext:** Type-safe per-request configuration for interceptors
- **React:** Axios/React Query config options

**Further Reading:**
- [Angular HttpContext](https://angular.dev/api/common/http/HttpContext)
- [Axios Interceptors](https://axios-http.com/docs/interceptors)

---

### 7. Multi Providers (Multiple Implementations)

**Description:** Multi providers allow multiple values to be injected for a single token. Perfect for plugin systems, event handlers, and extensible architectures.

#### Angular: Multi Provider Examples

**HTTP Interceptors (Built-in Multi Provider):**

```typescript
// Interceptors are a perfect example of multi providers
// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { loggingInterceptor } from './logging.interceptor';
import { authInterceptor } from './auth.interceptor';
import { errorInterceptor } from './error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      // Multiple interceptors - multi provider pattern
      withInterceptors([
        loggingInterceptor,
        authInterceptor,
        errorInterceptor
      ])
    )
  ]
};
```

**Custom Multi Provider for Validators:**

```typescript
// validator.interface.ts
export interface Validator {
  name: string;
  validate(value: any): boolean;
  errorMessage(value: any): string;
}

// validator.token.ts
import { InjectionToken } from '@angular/core';
import { Validator } from './validator.interface';

export const VALIDATORS = new InjectionToken<Validator[]>('VALIDATORS');

// email.validator.ts
import { Validator } from './validator.interface';

export class EmailValidator implements Validator {
  name = 'email';

  validate(value: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  }

  errorMessage(value: string): string {
    return `"${value}" is not a valid email address`;
  }
}

// phone.validator.ts
import { Validator } from './validator.interface';

export class PhoneValidator implements Validator {
  name = 'phone';

  validate(value: string): boolean {
    return /^\d{3}-\d{3}-\d{4}$/.test(value);
  }

  errorMessage(value: string): string {
    return `"${value}" must be in format: XXX-XXX-XXXX`;
  }
}

// url.validator.ts
import { Validator } from './validator.interface';

export class UrlValidator implements Validator {
  name = 'url';

  validate(value: string): boolean {
    try {
      new URL(value);
      return true;
    } catch {
      return false;
    }
  }

  errorMessage(value: string): string {
    return `"${value}" is not a valid URL`;
  }
}

// app.config.ts - Register multiple validators
import { ApplicationConfig } from '@angular/core';
import { VALIDATORS } from './validator.token';
import { EmailValidator } from './email.validator';
import { PhoneValidator } from './phone.validator';
import { UrlValidator } from './url.validator';

export const appConfig: ApplicationConfig = {
  providers: [
    // Multi provider: multiple implementations for same token
    { provide: VALIDATORS, useClass: EmailValidator, multi: true },
    { provide: VALIDATORS, useClass: PhoneValidator, multi: true },
    { provide: VALIDATORS, useClass: UrlValidator, multi: true }
  ]
};

// validation.service.ts
import { Injectable, inject } from '@angular/core';
import { VALIDATORS } from './validator.token';
import { Validator } from './validator.interface';

@Injectable({
  providedIn: 'root'
})
export class ValidationService {
  // Inject all validators
  private validators = inject(VALIDATORS);

  validate(type: string, value: any): { valid: boolean; error?: string } {
    const validator = this.validators.find(v => v.name === type);
    
    if (!validator) {
      return { valid: false, error: `No validator found for type: ${type}` };
    }

    const valid = validator.validate(value);
    return {
      valid,
      error: valid ? undefined : validator.errorMessage(value)
    };
  }

  getAvailableValidators(): string[] {
    return this.validators.map(v => v.name);
  }
}

// Usage in component
import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ValidationService } from './validation.service';

@Component({
  selector: 'app-validator-demo',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="validator-demo">
      <h3>Multi Provider Validators</h3>
      
      <div class="form-group">
        <label>Validator Type:</label>
        <select [(ngModel)]="validatorType">
          @for (type of validatorTypes; track type) {
            <option [value]="type">{{ type }}</option>
          }
        </select>
      </div>
      
      <div class="form-group">
        <label>Value to Validate:</label>
        <input [(ngModel)]="value" (ngModelChange)="onValueChange()" />
      </div>
      
      @if (result) {
        <div class="result" [class.valid]="result.valid" [class.invalid]="!result.valid">
          @if (result.valid) {
            <span>✓ Valid {{ validatorType }}</span>
          } @else {
            <span>✗ {{ result.error }}</span>
          }
        </div>
      }
    </div>
  `,
  styles: [`
    .validator-demo {
      padding: 20px;
      max-width: 500px;
    }
    .form-group {
      margin-bottom: 16px;
    }
    .form-group label {
      display: block;
      margin-bottom: 4px;
      font-weight: bold;
    }
    .form-group input,
    .form-group select {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .result {
      padding: 12px;
      border-radius: 4px;
      margin-top: 16px;
    }
    .result.valid {
      background: #d4edda;
      color: #155724;
      border: 1px solid #c3e6cb;
    }
    .result.invalid {
      background: #f8d7da;
      color: #721c24;
      border: 1px solid #f5c6cb;
    }
  `]
})
export class ValidatorDemoComponent {
  private validationService = inject(ValidationService);
  
  validatorTypes: string[] = [];
  validatorType = 'email';
  value = '';
  result: { valid: boolean; error?: string } | null = null;

  ngOnInit() {
    this.validatorTypes = this.validationService.getAvailableValidators();
  }

  onValueChange() {
    if (this.value) {
      this.result = this.validationService.validate(this.validatorType, this.value);
    } else {
      this.result = null;
    }
  }
}
```

**Plugin System with Multi Providers:**

```typescript
// plugin.interface.ts
export interface Plugin {
  name: string;
  version: string;
  initialize(): void;
  execute(data: any): any;
}

// plugin.token.ts
import { InjectionToken } from '@angular/core';
import { Plugin } from './plugin.interface';

export const PLUGINS = new InjectionToken<Plugin[]>('PLUGINS');

// analytics.plugin.ts
import { Injectable } from '@angular/core';
import { Plugin } from './plugin.interface';

@Injectable()
export class AnalyticsPlugin implements Plugin {
  name = 'Analytics';
  version = '1.0.0';

  initialize(): void {
    console.log('Analytics plugin initialized');
  }

  execute(data: any): any {
    console.log('Tracking event:', data);
    // Send to analytics service
    return { tracked: true, data };
  }
}

// logging.plugin.ts
import { Injectable } from '@angular/core';
import { Plugin } from './plugin.interface';

@Injectable()
export class LoggingPlugin implements Plugin {
  name = 'Logging';
  version = '1.0.0';

  initialize(): void {
    console.log('Logging plugin initialized');
  }

  execute(data: any): any {
    console.log('[LOG]', new Date().toISOString(), data);
    return { logged: true, data };
  }
}

// notification.plugin.ts
import { Injectable } from '@angular/core';
import { Plugin } from './plugin.interface';

@Injectable()
export class NotificationPlugin implements Plugin {
  name = 'Notification';
  version = '1.0.0';

  initialize(): void {
    console.log('Notification plugin initialized');
  }

  execute(data: any): any {
    if (data.type === 'error') {
      alert(`Error: ${data.message}`);
    }
    return { notified: true, data };
  }
}

// plugin.service.ts
import { Injectable, inject } from '@angular/core';
import { PLUGINS } from './plugin.token';
import { Plugin } from './plugin.interface';

@Injectable({
  providedIn: 'root'
})
export class PluginService {
  private plugins = inject(PLUGINS);

  constructor() {
    // Initialize all plugins
    this.plugins.forEach(plugin => {
      plugin.initialize();
    });
  }

  executeAll(data: any): any[] {
    return this.plugins.map(plugin => plugin.execute(data));
  }

  executeByName(name: string, data: any): any {
    const plugin = this.plugins.find(p => p.name === name);
    return plugin ? plugin.execute(data) : null;
  }

  getPlugins(): { name: string; version: string }[] {
    return this.plugins.map(p => ({ name: p.name, version: p.version }));
  }
}

// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { PLUGINS } from './plugin.token';
import { AnalyticsPlugin } from './analytics.plugin';
import { LoggingPlugin } from './logging.plugin';
import { NotificationPlugin } from './notification.plugin';

export const appConfig: ApplicationConfig = {
  providers: [
    // Register multiple plugins
    { provide: PLUGINS, useClass: AnalyticsPlugin, multi: true },
    { provide: PLUGINS, useClass: LoggingPlugin, multi: true },
    { provide: PLUGINS, useClass: NotificationPlugin, multi: true }
  ]
};
```

#### React: Equivalent Multi-Implementation Patterns

**Plugin System with Context:**

```tsx
// PluginContext.tsx
import React, { createContext, useContext, ReactNode } from 'react';

interface Plugin {
  name: string;
  version: string;
  initialize: () => void;
  execute: (data: any) => any;
}

interface PluginContextType {
  plugins: Plugin[];
  executeAll: (data: any) => any[];
  executeByName: (name: string, data: any) => any;
}

const PluginContext = createContext<PluginContextType | null>(null);

export function PluginProvider({ children, plugins }: { children: ReactNode; plugins: Plugin[] }) {
  React.useEffect(() => {
    // Initialize all plugins
    plugins.forEach(plugin => plugin.initialize());
  }, [plugins]);

  const executeAll = (data: any) => {
    return plugins.map(plugin => plugin.execute(data));
  };

  const executeByName = (name: string, data: any) => {
    const plugin = plugins.find(p => p.name === name);
    return plugin ? plugin.execute(data) : null;
  };

  return (
    <PluginContext.Provider value={{ plugins, executeAll, executeByName }}>
      {children}
    </PluginContext.Provider>
  );
}

export function usePlugins() {
  const context = useContext(PluginContext);
  if (!context) {
    throw new Error('usePlugins must be used within PluginProvider');
  }
  return context;
}

// plugins.ts
export const analyticsPlugin: Plugin = {
  name: 'Analytics',
  version: '1.0.0',
  initialize() {
    console.log('Analytics plugin initialized');
  },
  execute(data: any) {
    console.log('Tracking event:', data);
    return { tracked: true, data };
  }
};

export const loggingPlugin: Plugin = {
  name: 'Logging',
  version: '1.0.0',
  initialize() {
    console.log('Logging plugin initialized');
  },
  execute(data: any) {
    console.log('[LOG]', new Date().toISOString(), data);
    return { logged: true, data };
  }
};

// App.tsx
import { PluginProvider } from './PluginContext';
import { analyticsPlugin, loggingPlugin } from './plugins';

function App() {
  return (
    <PluginProvider plugins={[analyticsPlugin, loggingPlugin]}>
      <MainApp />
    </PluginProvider>
  );
}
```

**Validator System with Array:**

```tsx
// validators.ts
export interface Validator {
  name: string;
  validate: (value: any) => boolean;
  errorMessage: (value: any) => string;
}

export const emailValidator: Validator = {
  name: 'email',
  validate(value: string) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  },
  errorMessage(value: string) {
    return `"${value}" is not a valid email address`;
  }
};

export const phoneValidator: Validator = {
  name: 'phone',
  validate(value: string) {
    return /^\d{3}-\d{3}-\d{4}$/.test(value);
  },
  errorMessage(value: string) {
    return `"${value}" must be in format: XXX-XXX-XXXX`;
  }
};

export const urlValidator: Validator = {
  name: 'url',
  validate(value: string) {
    try {
      new URL(value);
      return true;
    } catch {
      return false;
    }
  },
  errorMessage(value: string) {
    return `"${value}" is not a valid URL`;
  }
};

// useValidation.ts
import { useMemo } from 'react';
import { Validator } from './validators';

export function useValidation(validators: Validator[]) {
  return useMemo(() => ({
    validate(type: string, value: any) {
      const validator = validators.find(v => v.name === type);
      
      if (!validator) {
        return { valid: false, error: `No validator found for type: ${type}` };
      }

      const valid = validator.validate(value);
      return {
        valid,
        error: valid ? undefined : validator.errorMessage(value)
      };
    },
    getAvailableValidators() {
      return validators.map(v => v.name);
    }
  }), [validators]);
}

// Usage
import { emailValidator, phoneValidator, urlValidator } from './validators';
import { useValidation } from './useValidation';

function ValidatorDemo() {
  const validation = useValidation([emailValidator, phoneValidator, urlValidator]);
  const [validatorType, setValidatorType] = React.useState('email');
  const [value, setValue] = React.useState('');
  
  const result = value ? validation.validate(validatorType, value) : null;
  
  return (
    <div>
      <select value={validatorType} onChange={(e) => setValidatorType(e.target.value)}>
        {validation.getAvailableValidators().map(type => (
          <option key={type} value={type}>{type}</option>
        ))}
      </select>
      
      <input value={value} onChange={(e) => setValue(e.target.value)} />
      
      {result && (
        <div className={result.valid ? 'valid' : 'invalid'}>
          {result.valid ? '✓ Valid' : `✗ ${result.error}`}
        </div>
      )}
    </div>
  );
}
```

#### Comparison: Multi Providers

| Feature | Angular Multi Providers | React Array/Context |
|---------|------------------------|-------------------|
| **Registration** | DI with multi: true | Array or Context |
| **Type Safety** | ✅ InjectionToken | Interface only |
| **Extensibility** | ✅ Easy to extend | Manual array management |
| **Injection** | Automatic | Props/Context |

**When to Use:**
- **Angular Multi Providers:** Plugin systems, validators, interceptors
- **React:** Context with arrays or custom hooks

**Further Reading:**
- [Angular Multi Providers](https://angular.dev/guide/di/dependency-injection-providers#using-the-multi-option)
- [React Composition](https://react.dev/learn/passing-data-deeply-with-context)

---

### 8. Environment Files (Environment-Specific Configuration)

**Description:** Environment files allow different configurations for development, staging, and production. Angular replaces these files at build time using file replacements in angular.json.

#### Angular: Environment File Examples

**Environment File Structure:**

```typescript
// src/environments/environment.ts (Development)
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api',
  apiKey: 'dev-key-12345',
  enableDebugMode: true,
  enableAnalytics: false,
  firebaseConfig: {
    apiKey: 'dev-firebase-key',
    authDomain: 'myapp-dev.firebaseapp.com',
    projectId: 'myapp-dev',
    storageBucket: 'myapp-dev.appspot.com',
    messagingSenderId: '123456789',
    appId: '1:123456789:web:abcdef'
  },
  features: {
    newDashboard: true,
    betaFeatures: true,
    experimentalUI: true
  },
  logLevel: 'debug' as const,
  cacheTimeout: 60000, // 1 minute
  maxRetries: 3
};

// src/environments/environment.staging.ts (Staging)
export const environment = {
  production: false,
  apiUrl: 'https://staging-api.example.com/api',
  apiKey: 'staging-key-67890',
  enableDebugMode: true,
  enableAnalytics: true,
  firebaseConfig: {
    apiKey: 'staging-firebase-key',
    authDomain: 'myapp-staging.firebaseapp.com',
    projectId: 'myapp-staging',
    storageBucket: 'myapp-staging.appspot.com',
    messagingSenderId: '987654321',
    appId: '1:987654321:web:ghijkl'
  },
  features: {
    newDashboard: true,
    betaFeatures: true,
    experimentalUI: false
  },
  logLevel: 'info' as const,
  cacheTimeout: 300000, // 5 minutes
  maxRetries: 3
};

// src/environments/environment.prod.ts (Production)
export const environment = {
  production: true,
  apiUrl: 'https://api.example.com/api',
  apiKey: 'prod-key-abcde',
  enableDebugMode: false,
  enableAnalytics: true,
  firebaseConfig: {
    apiKey: 'prod-firebase-key',
    authDomain: 'myapp.firebaseapp.com',
    projectId: 'myapp-prod',
    storageBucket: 'myapp-prod.appspot.com',
    messagingSenderId: '555555555',
    appId: '1:555555555:web:mnopqr'
  },
  features: {
    newDashboard: true,
    betaFeatures: false,
    experimentalUI: false
  },
  logLevel: 'error' as const,
  cacheTimeout: 600000, // 10 minutes
  maxRetries: 5
};
```

**angular.json Configuration:**

```json
{
  "projects": {
    "my-app": {
      "architect": {
        "build": {
          "configurations": {
            "production": {
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.prod.ts"
                }
              ],
              "optimization": true,
              "outputHashing": "all",
              "sourceMap": false,
              "namedChunks": false,
              "extractLicenses": true,
              "vendorChunk": false,
              "buildOptimizer": true,
              "budgets": [
                {
                  "type": "initial",
                  "maximumWarning": "500kb",
                  "maximumError": "1mb"
                }
              ]
            },
            "staging": {
              "fileReplacements": [
                {
                  "replace": "src/environments/environment.ts",
                  "with": "src/environments/environment.staging.ts"
                }
              ],
              "optimization": true,
              "outputHashing": "all",
              "sourceMap": true,
              "namedChunks": false,
              "extractLicenses": true
            }
          }
        },
        "serve": {
          "configurations": {
            "production": {
              "buildTarget": "my-app:build:production"
            },
            "staging": {
              "buildTarget": "my-app:build:staging"
            }
          }
        }
      }
    }
  }
}
```

**Using Environment in Services:**

```typescript
// api.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private http = inject(HttpClient);
  
  // Use environment configuration
  private readonly API_URL = environment.apiUrl;
  private readonly API_KEY = environment.apiKey;

  getData<T>(endpoint: string): Observable<T> {
    const url = `${this.API_URL}/${endpoint}`;
    
    // Include API key in headers
    return this.http.get<T>(url, {
      headers: {
        'X-API-Key': this.API_KEY
      }
    });
  }

  postData<T>(endpoint: string, data: any): Observable<T> {
    const url = `${this.API_URL}/${endpoint}`;
    
    if (environment.enableDebugMode) {
      console.log('POST Request:', url, data);
    }
    
    return this.http.post<T>(url, data, {
      headers: {
        'X-API-Key': this.API_KEY
      }
    });
  }
}

// logger.service.ts
import { Injectable } from '@angular/core';
import { environment } from '../environments/environment';

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

@Injectable({
  providedIn: 'root'
})
export class LoggerService {
  private readonly logLevel = environment.logLevel;
  
  // Log levels: debug < info < warn < error
  private readonly levels: LogLevel[] = ['debug', 'info', 'warn', 'error'];

  private shouldLog(level: LogLevel): boolean {
    const currentLevelIndex = this.levels.indexOf(this.logLevel);
    const requestedLevelIndex = this.levels.indexOf(level);
    return requestedLevelIndex >= currentLevelIndex;
  }

  debug(message: string, ...args: any[]): void {
    if (this.shouldLog('debug')) {
      console.log(`[DEBUG] ${message}`, ...args);
    }
  }

  info(message: string, ...args: any[]): void {
    if (this.shouldLog('info')) {
      console.info(`[INFO] ${message}`, ...args);
    }
  }

  warn(message: string, ...args: any[]): void {
    if (this.shouldLog('warn')) {
      console.warn(`[WARN] ${message}`, ...args);
    }
  }

  error(message: string, ...args: any[]): void {
    if (this.shouldLog('error')) {
      console.error(`[ERROR] ${message}`, ...args);
    }
  }
}

// analytics.service.ts
import { Injectable } from '@angular/core';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AnalyticsService {
  private enabled = environment.enableAnalytics;

  trackEvent(event: string, data?: any): void {
    if (!this.enabled) {
      return;
    }

    // Send to analytics service
    console.log('Analytics Event:', event, data);
  }

  trackPageView(page: string): void {
    if (!this.enabled) {
      return;
    }

    console.log('Page View:', page);
  }
}

// feature-flag.service.ts
import { Injectable } from '@angular/core';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class FeatureFlagService {
  private features = environment.features;

  isEnabled(feature: keyof typeof environment.features): boolean {
    return this.features[feature] ?? false;
  }

  getAll(): typeof environment.features {
    return { ...this.features };
  }
}
```

**Environment-Aware Component:**

```typescript
// app.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { environment } from '../environments/environment';
import { FeatureFlagService } from './feature-flag.service';
import { LoggerService } from './logger.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="app">
      <header>
        <h1>My App</h1>
        @if (!isProduction) {
          <span class="env-badge">{{ envName }}</span>
        }
      </header>
      
      <main>
        @if (featureFlags.isEnabled('newDashboard')) {
          <new-dashboard />
        } @else {
          <legacy-dashboard />
        }
        
        @if (featureFlags.isEnabled('betaFeatures')) {
          <beta-features-panel />
        }
      </main>
      
      @if (showDebugInfo) {
        <div class="debug-panel">
          <h3>Debug Info</h3>
          <pre>{{ debugInfo | json }}</pre>
        </div>
      }
    </div>
  `,
  styles: [`
    .env-badge {
      display: inline-block;
      padding: 4px 8px;
      background: #ff9800;
      color: white;
      border-radius: 4px;
      font-size: 12px;
      margin-left: 10px;
    }
    .debug-panel {
      position: fixed;
      bottom: 0;
      right: 0;
      background: rgba(0, 0, 0, 0.9);
      color: #0f0;
      padding: 16px;
      max-width: 400px;
      font-family: monospace;
      font-size: 12px;
    }
  `]
})
export class AppComponent {
  private logger = inject(LoggerService);
  featureFlags = inject(FeatureFlagService);
  
  isProduction = environment.production;
  showDebugInfo = environment.enableDebugMode;
  envName = environment.production ? 'Production' : 'Development';
  
  debugInfo = {
    environment: this.envName,
    apiUrl: environment.apiUrl,
    features: environment.features,
    logLevel: environment.logLevel
  };

  ngOnInit() {
    this.logger.info('App initialized', this.debugInfo);
    
    // Log enabled features
    const enabledFeatures = Object.entries(environment.features)
      .filter(([, enabled]) => enabled)
      .map(([feature]) => feature);
    
    this.logger.debug('Enabled features:', enabledFeatures);
  }
}
```

**Build Commands:**

```bash
# Development (default)
ng serve
ng build

# Staging
ng serve --configuration=staging
ng build --configuration=staging

# Production
ng serve --configuration=production
ng build --configuration=production
```

#### React: Equivalent Environment Configuration

**Environment Files (.env):**

```bash
# .env.development
REACT_APP_API_URL=http://localhost:3000/api
REACT_APP_API_KEY=dev-key-12345
REACT_APP_ENABLE_DEBUG=true
REACT_APP_ENABLE_ANALYTICS=false
REACT_APP_FIREBASE_API_KEY=dev-firebase-key
REACT_APP_FIREBASE_AUTH_DOMAIN=myapp-dev.firebaseapp.com
REACT_APP_FEATURE_NEW_DASHBOARD=true
REACT_APP_FEATURE_BETA=true
REACT_APP_LOG_LEVEL=debug

# .env.staging
REACT_APP_API_URL=https://staging-api.example.com/api
REACT_APP_API_KEY=staging-key-67890
REACT_APP_ENABLE_DEBUG=true
REACT_APP_ENABLE_ANALYTICS=true
REACT_APP_FIREBASE_API_KEY=staging-firebase-key
REACT_APP_FIREBASE_AUTH_DOMAIN=myapp-staging.firebaseapp.com
REACT_APP_FEATURE_NEW_DASHBOARD=true
REACT_APP_FEATURE_BETA=true
REACT_APP_LOG_LEVEL=info

# .env.production
REACT_APP_API_URL=https://api.example.com/api
REACT_APP_API_KEY=prod-key-abcde
REACT_APP_ENABLE_DEBUG=false
REACT_APP_ENABLE_ANALYTICS=true
REACT_APP_FIREBASE_API_KEY=prod-firebase-key
REACT_APP_FIREBASE_AUTH_DOMAIN=myapp.firebaseapp.com
REACT_APP_FEATURE_NEW_DASHBOARD=true
REACT_APP_FEATURE_BETA=false
REACT_APP_LOG_LEVEL=error
```

**Environment Config Module:**

```tsx
// config.ts
export const config = {
  production: process.env.NODE_ENV === 'production',
  apiUrl: process.env.REACT_APP_API_URL || 'http://localhost:3000/api',
  apiKey: process.env.REACT_APP_API_KEY || '',
  enableDebugMode: process.env.REACT_APP_ENABLE_DEBUG === 'true',
  enableAnalytics: process.env.REACT_APP_ENABLE_ANALYTICS === 'true',
  firebaseConfig: {
    apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
    authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
    projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
    storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.REACT_APP_FIREBASE_APP_ID
  },
  features: {
    newDashboard: process.env.REACT_APP_FEATURE_NEW_DASHBOARD === 'true',
    betaFeatures: process.env.REACT_APP_FEATURE_BETA === 'true',
    experimentalUI: process.env.REACT_APP_FEATURE_EXPERIMENTAL === 'true'
  },
  logLevel: (process.env.REACT_APP_LOG_LEVEL || 'info') as 'debug' | 'info' | 'warn' | 'error'
};

// apiService.ts
import axios from 'axios';
import { config } from './config';

const api = axios.create({
  baseURL: config.apiUrl,
  headers: {
    'X-API-Key': config.apiKey
  }
});

export const apiService = {
  getData<T>(endpoint: string) {
    if (config.enableDebugMode) {
      console.log('GET Request:', endpoint);
    }
    return api.get<T>(endpoint);
  },
  
  postData<T>(endpoint: string, data: any) {
    if (config.enableDebugMode) {
      console.log('POST Request:', endpoint, data);
    }
    return api.post<T>(endpoint, data);
  }
};

// useFeatureFlag.ts
import { config } from './config';

export function useFeatureFlag(feature: keyof typeof config.features): boolean {
  return config.features[feature] ?? false;
}

// App.tsx
import { config } from './config';
import { useFeatureFlag } from './useFeatureFlag';

function App() {
  const showNewDashboard = useFeatureFlag('newDashboard');
  const showBeta = useFeatureFlag('betaFeatures');
  
  return (
    <div className="app">
      <header>
        <h1>My App</h1>
        {!config.production && (
          <span className="env-badge">
            {process.env.NODE_ENV}
          </span>
        )}
      </header>
      
      <main>
        {showNewDashboard ? <NewDashboard /> : <LegacyDashboard />}
        {showBeta && <BetaFeaturesPanel />}
      </main>
      
      {config.enableDebugMode && (
        <div className="debug-panel">
          <h3>Debug Info</h3>
          <pre>{JSON.stringify(config, null, 2)}</pre>
        </div>
      )}
    </div>
  );
}
```

**package.json Scripts:**

```json
{
  "scripts": {
    "start": "react-scripts start",
    "start:staging": "env-cmd -f .env.staging react-scripts start",
    "build": "react-scripts build",
    "build:staging": "env-cmd -f .env.staging react-scripts build",
    "build:production": "env-cmd -f .env.production react-scripts build"
  },
  "devDependencies": {
    "env-cmd": "^10.1.0"
  }
}
```

#### Comparison: Environment Configuration

| Feature | Angular Environments | React .env Files |
|---------|---------------------|-----------------|
| **File Replacement** | ✅ Build-time (angular.json) | Runtime (process.env) |
| **Type Safety** | ✅ TypeScript exports | ⚠️ String env vars |
| **Tree Shaking** | ✅ Unused code removed | ⚠️ All vars included |
| **Complex Objects** | ✅ Nested objects | Manual parsing |
| **Secret Protection** | Both require .gitignore | Both require .gitignore |

**When to Use:**
- **Angular:** Build-time file replacement with full TypeScript support
- **React:** Runtime environment variables with process.env

**Further Reading:**
- [Angular Environments](https://angular.dev/tools/cli/environments)
- [React Environment Variables](https://create-react-app.dev/docs/adding-custom-environment-variables/)

---

### 9. Typed Reactive Forms (Type-Safe Forms)

**Description:** Angular 14+ introduced strictly typed reactive forms, providing compile-time type safety for form controls, groups, and arrays. Prevents runtime errors and improves developer experience with autocomplete.

#### Angular: Typed Reactive Forms Examples

**Basic Typed Forms:**

```typescript
// user-form.component.ts
import { Component } from '@angular/core';
import { ReactiveFormsModule, FormControl, FormGroup, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';

// Define form interface
interface UserForm {
  firstName: FormControl<string>;
  lastName: FormControl<string>;
  email: FormControl<string>;
  age: FormControl<number | null>;
  acceptTerms: FormControl<boolean>;
}

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="userForm" (ngSubmit)="onSubmit()">
      <div class="form-group">
        <label>First Name:</label>
        <input formControlName="firstName" />
        @if (userForm.controls.firstName.invalid && userForm.controls.firstName.touched) {
          <span class="error">First name is required</span>
        }
      </div>
      
      <div class="form-group">
        <label>Last Name:</label>
        <input formControlName="lastName" />
      </div>
      
      <div class="form-group">
        <label>Email:</label>
        <input formControlName="email" type="email" />
        @if (userForm.controls.email.errors?.['required'] && userForm.controls.email.touched) {
          <span class="error">Email is required</span>
        }
        @if (userForm.controls.email.errors?.['email']) {
          <span class="error">Invalid email format</span>
        }
      </div>
      
      <div class="form-group">
        <label>Age:</label>
        <input formControlName="age" type="number" />
      </div>
      
      <div class="form-group">
        <label>
          <input formControlName="acceptTerms" type="checkbox" />
          Accept Terms
        </label>
      </div>
      
      <button type="submit" [disabled]="userForm.invalid">Submit</button>
    </form>
    
    <div class="form-value">
      <h3>Form Value (Typed):</h3>
      <pre>{{ userForm.value | json }}</pre>
    </div>
  `,
  styles: [`
    .form-group {
      margin-bottom: 16px;
    }
    .form-group label {
      display: block;
      margin-bottom: 4px;
      font-weight: bold;
    }
    .form-group input {
      width: 100%;
      padding: 8px;
      border: 1px solid #ddd;
      border-radius: 4px;
    }
    .error {
      color: #d32f2f;
      font-size: 12px;
      margin-top: 4px;
      display: block;
    }
    button {
      padding: 10px 20px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
    }
    button:disabled {
      background: #ccc;
      cursor: not-allowed;
    }
    .form-value {
      margin-top: 20px;
      padding: 16px;
      background: #f5f5f5;
      border-radius: 4px;
    }
  `]
})
export class UserFormComponent {
  // Typed form group
  userForm = new FormGroup<UserForm>({
    firstName: new FormControl('', { 
      nonNullable: true,
      validators: [Validators.required]
    }),
    lastName: new FormControl('', { nonNullable: true }),
    email: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.email]
    }),
    age: new FormControl<number | null>(null),
    acceptTerms: new FormControl(false, { nonNullable: true })
  });

  onSubmit() {
    if (this.userForm.valid) {
      // value is typed: { firstName: string, lastName: string, ... }
      const formValue = this.userForm.value;
      console.log('Form submitted:', formValue);
      
      // getRawValue() includes disabled controls
      const rawValue = this.userForm.getRawValue();
      console.log('Raw value:', rawValue);
    }
  }
}
```

**Nested FormGroups:**

```typescript
// address-form.component.ts
import { Component } from '@angular/core';
import { ReactiveFormsModule, FormControl, FormGroup, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';

// Nested form interfaces
interface AddressForm {
  street: FormControl<string>;
  city: FormControl<string>;
  state: FormControl<string>;
  zipCode: FormControl<string>;
}

interface PersonForm {
  name: FormControl<string>;
  email: FormControl<string>;
  address: FormGroup<AddressForm>;
}

@Component({
  selector: 'app-address-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="personForm" (ngSubmit)="onSubmit()">
      <h3>Personal Info</h3>
      
      <div class="form-group">
        <label>Name:</label>
        <input formControlName="name" />
      </div>
      
      <div class="form-group">
        <label>Email:</label>
        <input formControlName="email" type="email" />
      </div>
      
      <h3>Address</h3>
      <div formGroupName="address">
        <div class="form-group">
          <label>Street:</label>
          <input formControlName="street" />
        </div>
        
        <div class="form-group">
          <label>City:</label>
          <input formControlName="city" />
        </div>
        
        <div class="form-group">
          <label>State:</label>
          <input formControlName="state" />
        </div>
        
        <div class="form-group">
          <label>Zip Code:</label>
          <input formControlName="zipCode" />
        </div>
      </div>
      
      <button type="submit" [disabled]="personForm.invalid">Submit</button>
    </form>
  `
})
export class AddressFormComponent {
  personForm = new FormGroup<PersonForm>({
    name: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required]
    }),
    email: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.email]
    }),
    address: new FormGroup<AddressForm>({
      street: new FormControl('', { nonNullable: true }),
      city: new FormControl('', {
        nonNullable: true,
        validators: [Validators.required]
      }),
      state: new FormControl('', {
        nonNullable: true,
        validators: [Validators.required]
      }),
      zipCode: new FormControl('', {
        nonNullable: true,
        validators: [Validators.required, Validators.pattern(/^\d{5}$/)]
      })
    })
  });

  onSubmit() {
    if (this.personForm.valid) {
      const value = this.personForm.getRawValue();
      // Typed as: { name: string, email: string, address: { street: string, ... } }
      console.log('Person:', value);
      console.log('Address:', value.address);
    }
  }
}
```

**FormArray with Type Safety:**

```typescript
// skills-form.component.ts
import { Component } from '@angular/core';
import { ReactiveFormsModule, FormControl, FormGroup, FormArray, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';

interface SkillForm {
  name: FormControl<string>;
  level: FormControl<'beginner' | 'intermediate' | 'expert'>;
  yearsOfExperience: FormControl<number>;
}

interface ProfileForm {
  username: FormControl<string>;
  skills: FormArray<FormGroup<SkillForm>>;
}

@Component({
  selector: 'app-skills-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="profileForm" (ngSubmit)="onSubmit()">
      <div class="form-group">
        <label>Username:</label>
        <input formControlName="username" />
      </div>
      
      <h3>Skills</h3>
      <div formArrayName="skills">
        @for (skill of skills.controls; track $index) {
          <div [formGroupName]="$index" class="skill-item">
            <div class="form-group">
              <label>Skill Name:</label>
              <input formControlName="name" />
            </div>
            
            <div class="form-group">
              <label>Level:</label>
              <select formControlName="level">
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="expert">Expert</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Years:</label>
              <input formControlName="yearsOfExperience" type="number" />
            </div>
            
            <button type="button" (click)="removeSkill($index)">Remove</button>
          </div>
        }
      </div>
      
      <button type="button" (click)="addSkill()">Add Skill</button>
      <button type="submit" [disabled]="profileForm.invalid">Submit</button>
      
      <div class="form-value">
        <pre>{{ profileForm.value | json }}</pre>
      </div>
    </form>
  `,
  styles: [`
    .skill-item {
      border: 1px solid #ddd;
      padding: 16px;
      margin-bottom: 16px;
      border-radius: 4px;
      background: #f9f9f9;
    }
    .form-group {
      margin-bottom: 12px;
    }
    button {
      margin-right: 8px;
    }
  `]
})
export class SkillsFormComponent {
  profileForm = new FormGroup<ProfileForm>({
    username: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required]
    }),
    skills: new FormArray<FormGroup<SkillForm>>([])
  });

  get skills() {
    return this.profileForm.controls.skills;
  }

  addSkill() {
    const skillGroup = new FormGroup<SkillForm>({
      name: new FormControl('', {
        nonNullable: true,
        validators: [Validators.required]
      }),
      level: new FormControl<'beginner' | 'intermediate' | 'expert'>('beginner', {
        nonNullable: true
      }),
      yearsOfExperience: new FormControl(0, {
        nonNullable: true,
        validators: [Validators.min(0)]
      })
    });

    this.skills.push(skillGroup);
  }

  removeSkill(index: number) {
    this.skills.removeAt(index);
  }

  onSubmit() {
    if (this.profileForm.valid) {
      const value = this.profileForm.getRawValue();
      // Typed as: { username: string, skills: Array<{ name: string, level: ..., yearsOfExperience: number }> }
      console.log('Profile:', value);
    }
  }
}
```

**FormBuilder with Types:**

```typescript
// product-form.component.ts
import { Component, inject } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';

interface Product {
  name: string;
  price: number;
  inStock: boolean;
  category: string;
}

@Component({
  selector: 'app-product-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <form [formGroup]="productForm" (ngSubmit)="onSubmit()">
      <div class="form-group">
        <label>Product Name:</label>
        <input formControlName="name" />
      </div>
      
      <div class="form-group">
        <label>Price:</label>
        <input formControlName="price" type="number" step="0.01" />
      </div>
      
      <div class="form-group">
        <label>
          <input formControlName="inStock" type="checkbox" />
          In Stock
        </label>
      </div>
      
      <div class="form-group">
        <label>Category:</label>
        <select formControlName="category">
          <option value="electronics">Electronics</option>
          <option value="clothing">Clothing</option>
          <option value="books">Books</option>
        </select>
      </div>
      
      <button type="submit" [disabled]="productForm.invalid">Submit</button>
    </form>
  `
})
export class ProductFormComponent {
  private fb = inject(FormBuilder);

  // FormBuilder with type inference
  productForm = this.fb.group<Product>({
    name: this.fb.control('', {
      nonNullable: true,
      validators: [Validators.required]
    }),
    price: this.fb.control(0, {
      nonNullable: true,
      validators: [Validators.required, Validators.min(0)]
    }),
    inStock: this.fb.control(true, { nonNullable: true }),
    category: this.fb.control('electronics', {
      nonNullable: true
    })
  });

  onSubmit() {
    if (this.productForm.valid) {
      const product: Product = this.productForm.getRawValue();
      console.log('Product:', product);
    }
  }
}
```

#### React: Equivalent Typed Form Solutions

**React Hook Form with TypeScript:**

```tsx
// UserForm.tsx
import { useForm, SubmitHandler } from 'react-hook-form';

interface UserFormData {
  firstName: string;
  lastName: string;
  email: string;
  age: number | null;
  acceptTerms: boolean;
}

function UserForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isValid },
    watch
  } = useForm<UserFormData>({
    defaultValues: {
      firstName: '',
      lastName: '',
      email: '',
      age: null,
      acceptTerms: false
    },
    mode: 'onChange'
  });

  const onSubmit: SubmitHandler<UserFormData> = (data) => {
    console.log('Form submitted:', data);
    // data is typed as UserFormData
  };

  const formValue = watch();

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="form-group">
        <label>First Name:</label>
        <input {...register('firstName', { required: 'First name is required' })} />
        {errors.firstName && <span className="error">{errors.firstName.message}</span>}
      </div>
      
      <div className="form-group">
        <label>Last Name:</label>
        <input {...register('lastName')} />
      </div>
      
      <div className="form-group">
        <label>Email:</label>
        <input
          type="email"
          {...register('email', {
            required: 'Email is required',
            pattern: {
              value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
              message: 'Invalid email format'
            }
          })}
        />
        {errors.email && <span className="error">{errors.email.message}</span>}
      </div>
      
      <div className="form-group">
        <label>Age:</label>
        <input
          type="number"
          {...register('age', { valueAsNumber: true })}
        />
      </div>
      
      <div className="form-group">
        <label>
          <input type="checkbox" {...register('acceptTerms')} />
          Accept Terms
        </label>
      </div>
      
      <button type="submit" disabled={!isValid}>Submit</button>
      
      <div className="form-value">
        <h3>Form Value (Typed):</h3>
        <pre>{JSON.stringify(formValue, null, 2)}</pre>
      </div>
    </form>
  );
}
```

**Nested Forms with React Hook Form:**

```tsx
// AddressForm.tsx
import { useForm, SubmitHandler } from 'react-hook-form';

interface Address {
  street: string;
  city: string;
  state: string;
  zipCode: string;
}

interface PersonFormData {
  name: string;
  email: string;
  address: Address;
}

function AddressForm() {
  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm<PersonFormData>({
    defaultValues: {
      name: '',
      email: '',
      address: {
        street: '',
        city: '',
        state: '',
        zipCode: ''
      }
    }
  });

  const onSubmit: SubmitHandler<PersonFormData> = (data) => {
    console.log('Person:', data);
    console.log('Address:', data.address);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <h3>Personal Info</h3>
      
      <div className="form-group">
        <label>Name:</label>
        <input {...register('name', { required: true })} />
      </div>
      
      <div className="form-group">
        <label>Email:</label>
        <input
          type="email"
          {...register('email', { required: true })}
        />
      </div>
      
      <h3>Address</h3>
      
      <div className="form-group">
        <label>Street:</label>
        <input {...register('address.street')} />
      </div>
      
      <div className="form-group">
        <label>City:</label>
        <input {...register('address.city', { required: true })} />
      </div>
      
      <div className="form-group">
        <label>State:</label>
        <input {...register('address.state', { required: true })} />
      </div>
      
      <div className="form-group">
        <label>Zip Code:</label>
        <input
          {...register('address.zipCode', {
            required: true,
            pattern: /^\d{5}$/
          })}
        />
      </div>
      
      <button type="submit">Submit</button>
    </form>
  );
}
```

**Dynamic Arrays with React Hook Form:**

```tsx
// SkillsForm.tsx
import { useForm, useFieldArray, SubmitHandler } from 'react-hook-form';

interface Skill {
  name: string;
  level: 'beginner' | 'intermediate' | 'expert';
  yearsOfExperience: number;
}

interface ProfileFormData {
  username: string;
  skills: Skill[];
}

function SkillsForm() {
  const {
    register,
    control,
    handleSubmit,
    watch
  } = useForm<ProfileFormData>({
    defaultValues: {
      username: '',
      skills: []
    }
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: 'skills'
  });

  const onSubmit: SubmitHandler<ProfileFormData> = (data) => {
    console.log('Profile:', data);
  };

  const addSkill = () => {
    append({
      name: '',
      level: 'beginner',
      yearsOfExperience: 0
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div className="form-group">
        <label>Username:</label>
        <input {...register('username', { required: true })} />
      </div>
      
      <h3>Skills</h3>
      {fields.map((field, index) => (
        <div key={field.id} className="skill-item">
          <div className="form-group">
            <label>Skill Name:</label>
            <input {...register(`skills.${index}.name`, { required: true })} />
          </div>
          
          <div className="form-group">
            <label>Level:</label>
            <select {...register(`skills.${index}.level`)}>
              <option value="beginner">Beginner</option>
              <option value="intermediate">Intermediate</option>
              <option value="expert">Expert</option>
            </select>
          </div>
          
          <div className="form-group">
            <label>Years:</label>
            <input
              type="number"
              {...register(`skills.${index}.yearsOfExperience`, {
                valueAsNumber: true,
                min: 0
              })}
            />
          </div>
          
          <button type="button" onClick={() => remove(index)}>Remove</button>
        </div>
      ))}
      
      <button type="button" onClick={addSkill}>Add Skill</button>
      <button type="submit">Submit</button>
      
      <div className="form-value">
        <pre>{JSON.stringify(watch(), null, 2)}</pre>
      </div>
    </form>
  );
}
```

#### Comparison: Typed Forms

| Feature | Angular Typed Forms | React Hook Form |
|---------|-------------------|----------------|
| **Type Safety** | ✅ Built-in | ✅ TypeScript generics |
| **Validation** | Validators | register() options |
| **Nested Forms** | FormGroup<T> | Dot notation |
| **Dynamic Arrays** | FormArray<T> | useFieldArray |
| **Value Access** | form.getRawValue() | watch() or form state |

**When to Use:**
- **Angular:** Built-in typed reactive forms with strong validation
- **React:** React Hook Form with TypeScript for type safety

**Further Reading:**
- [Angular Typed Forms](https://angular.dev/guide/forms/typed-forms)
- [React Hook Form](https://react-hook-form.com/get-started#TypeScript)

---

## Part 4 Summary

This part covered **9 Advanced Features**:

1. ✅ **Angular Universal (SSR)** - Server-side rendering with TransferState
2. ✅ **Angular Elements** - Web Components with createCustomElement
3. ✅ **Service Workers/PWA** - Offline support and push notifications
4. ✅ **Renderer2** - Platform-agnostic DOM manipulation
5. ✅ **APP_INITIALIZER** - Application initialization hooks
6. ✅ **HttpContext** - Request-specific metadata for interceptors
7. ✅ **Multi Providers** - Multiple implementations for plugin systems
8. ✅ **Environment Files** - Environment-specific configuration
9. ✅ **Typed Reactive Forms** - Type-safe form controls

**Progress: 26/38 features complete (68%)**

**Next:** Part 5 will cover **6 Routing Features** (Router Events, Auxiliary Routes, Route Animations, Matrix Parameters, Title Strategy, withComponentInputBinding)

