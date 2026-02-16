# Phase 24: Performance Optimization in Angular

> Building fast, responsive Angular applications requires understanding and applying performance best practices. This phase covers strategies, code examples, and tools to optimize your Angular apps for speed and efficiency.

---

## 24.1 Why Performance Matters

- Improves user experience and engagement
- Reduces bounce rates and increases conversions
- Essential for mobile and low-bandwidth users

---

## 24.2 Change Detection Strategies

### Default vs. OnPush
- **Default:** Angular checks every component on every change.
- **OnPush:** Angular only checks when inputs change or events occur.

```typescript
@Component({
  selector: 'app-optimized',
  template: `...`,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class OptimizedComponent {}
```

**Tip:** Use `OnPush` for stateless or data-driven components.

---

## 24.3 Lazy Loading Modules

- Load feature modules only when needed (e.g., on route navigation).

```typescript
const routes: Routes = [
  { path: 'admin', loadChildren: () => import('./admin/admin.module').then(m => m.AdminModule) }
];
```

---

## 24.4 Code Splitting & Bundling

- Use Angular CLI’s built-in support for code splitting.
- Run `ng build --prod` to generate optimized bundles.

---

## 24.5 TrackBy in *ngFor

- Prevents unnecessary DOM updates when rendering lists.

```html
<li *ngFor="let item of items; trackBy: trackById">{{ item.name }}</li>
```
```typescript
trackById(index: number, item: any) { return item.id; }
```

---

## 24.6 Avoid Memory Leaks

- Unsubscribe from Observables in `ngOnDestroy`.

```typescript
private sub: Subscription;
ngOnInit() {
  this.sub = this.service.getData().subscribe(...);
}
ngOnDestroy() {
  this.sub.unsubscribe();
}
```

---

## 24.7 Optimize Images and Assets

- Use modern formats (WebP, AVIF)
- Lazy load images with `loading="lazy"`
- Compress and resize assets

---

## 24.8 Use Pure Pipes

- Pure pipes are only recalculated when inputs change.

```typescript
@Pipe({ name: 'myPipe', pure: true })
export class MyPipe { ... }
```

---

## 24.9 Tools for Performance Analysis

- **Angular DevTools:** Inspect change detection and performance
- **Lighthouse:** Audit app performance
- **WebPageTest, Chrome DevTools:** Analyze load times and bottlenecks

---

## 24.10 Additional Tips

- Minimize use of `*ngIf`/`*ngFor` on large lists
- Avoid complex computations in templates
- Use `async` pipe for Observables
- Prefer `const` and `let` over `var`

---

## 24.11 Resources

- [Angular Performance Guide](https://angular.io/guide/performance)
- [Angular DevTools](https://angular.io/guide/devtools)
- [Lighthouse](https://web.dev/lighthouse/)
