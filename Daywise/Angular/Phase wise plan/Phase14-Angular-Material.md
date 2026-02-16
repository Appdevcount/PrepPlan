
# Phase 14: Angular Material — UI Components & Theming

> Angular Material is a UI component library that implements Google’s Material Design. It helps you build beautiful, consistent, and accessible user interfaces quickly. This guide provides in-depth explanations, step-by-step instructions, and detailed code samples to help you confidently use Angular Material in your projects.

---

## 14.1 What is Angular Material?

- A set of reusable, well-tested UI components for Angular
- Follows Material Design guidelines for consistency and usability
- Includes themes, typography, and accessibility features out of the box

**Why use Angular Material?**
- Rapidly build modern, professional UIs
- Consistent look and feel across your app
- Built-in accessibility and responsiveness

---

## 14.2 Installing Angular Material

Install Angular Material, Angular CDK, and Angular Animations:

```bash
ng add @angular/material
```

You’ll be prompted to select a prebuilt theme, set up global typography, and enable animations. For most projects, choose a prebuilt theme to get started quickly.

**Tip:** You can always customize the theme later.

---

## 14.3 Using Angular Material Components

Angular Material provides a wide range of UI components. Here are some of the most commonly used, with detailed usage examples:

### 1. Button

```html
<!-- app.component.html -->
<button mat-raised-button color="primary">Primary Button</button>
<button mat-stroked-button color="accent">Accent Button</button>
```

**How it works:**
- Add the `mat-raised-button` or `mat-stroked-button` directive to a `<button>` element.
- Use the `color` attribute for theme colors (`primary`, `accent`, `warn`).

### 2. Toolbar

```html
<mat-toolbar color="primary">
  <span>My App</span>
</mat-toolbar>
```

### 3. Sidenav

```html
<mat-sidenav-container style="height: 100vh">
  <mat-sidenav mode="side" opened>Sidenav content</mat-sidenav>
  <mat-sidenav-content>Main content</mat-sidenav-content>
</mat-sidenav-container>
```

### 4. Card

```html
<mat-card>
  <mat-card-header>
    <mat-card-title>Card Title</mat-card-title>
    <mat-card-subtitle>Subtitle</mat-card-subtitle>
  </mat-card-header>
  <mat-card-content>
    <p>This is some content inside a Material card.</p>
  </mat-card-content>
  <mat-card-actions>
    <button mat-button>Action</button>
  </mat-card-actions>
</mat-card>
```

### 5. Input

```html
<mat-form-field appearance="fill">
  <mat-label>Email</mat-label>
  <input matInput placeholder="Enter your email" type="email">
</mat-form-field>
```

### 6. Table

```typescript
// app.component.ts
import { Component } from '@angular/core';

export interface User {
  name: string;
  age: number;
}

const USER_DATA: User[] = [
  { name: 'Alice', age: 25 },
  { name: 'Bob', age: 30 },
];

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
})
export class AppComponent {
  displayedColumns: string[] = ['name', 'age'];
  dataSource = USER_DATA;
}
```

```html
<!-- app.component.html -->
<table mat-table [dataSource]="dataSource" class="mat-elevation-z8">
  <!-- Name Column -->
  <ng-container matColumnDef="name">
    <th mat-header-cell *matHeaderCellDef>Name</th>
    <td mat-cell *matCellDef="let user">{{user.name}}</td>
  </ng-container>

  <!-- Age Column -->
  <ng-container matColumnDef="age">
    <th mat-header-cell *matHeaderCellDef>Age</th>
    <td mat-cell *matCellDef="let user">{{user.age}}</td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
</table>
```

### 7. Dialog

```typescript
// dialog-example.component.ts
import { Component } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

@Component({
  selector: 'app-dialog-example',
  template: `<button mat-button (click)="openDialog()">Open Dialog</button>`
})
export class DialogExampleComponent {
  constructor(private dialog: MatDialog) {}

  openDialog() {
    this.dialog.open(DialogContentComponent);
  }
}

@Component({
  template: `<h2 mat-dialog-title>Hello!</h2><mat-dialog-content>This is a dialog.</mat-dialog-content>`
})
export class DialogContentComponent {}
```

### 8. Snackbar

```typescript
import { MatSnackBar } from '@angular/material/snack-bar';

constructor(private snackBar: MatSnackBar) {}

showMessage() {
  this.snackBar.open('Message sent!', 'Close', { duration: 2000 });
}
```

---

## 14.4 Theming and Customization

Angular Material supports both prebuilt and custom themes. You can easily change the look and feel of your app.

### Using a Prebuilt Theme

When you run `ng add @angular/material`, you can select a prebuilt theme (e.g., Indigo/Pink, Deep Purple/Amber). This automatically updates your `angular.json` to include the theme CSS.

### Creating a Custom Theme

Edit your `styles.scss`:

```scss
@use '@angular/material' as mat;
@include mat.core();

$my-theme: mat.define-light-theme((
  color: (
    primary: mat.define-palette(mat.$indigo-palette),
    accent: mat.define-palette(mat.$pink-palette),
    warn: mat.define-palette(mat.$red-palette),
  ),
  typography: mat.define-typography-config(),
));

@include mat.all-component-themes($my-theme);
```

**Inline comments:**
- `@use '@angular/material' as mat;` — imports Material theming functions
- `mat.core()` — sets up core styles
- `mat.define-light-theme` — creates a light theme with your chosen palettes
- `mat.all-component-themes` — applies the theme to all Material components

---

## 14.5 Accessibility & Responsiveness

- All Angular Material components are accessible by default (ARIA, keyboard navigation, focus indicators)
- Use [Angular Flex Layout](https://github.com/angular/flex-layout) or CSS Grid for responsive layouts

**Example: Responsive Toolbar**

```html
<mat-toolbar color="primary">
  <span>My App</span>
  <span class="spacer"></span>
  <button mat-button>Login</button>
</mat-toolbar>
```

```css
.spacer {
  flex: 1 1 auto;
}
mat-toolbar {
  display: flex;
}
```

---

## 14.6 Step-by-Step: Adding Angular Material to a New Project

1. **Create a new Angular project:**
   ```bash
   ng new my-material-app
   cd my-material-app
   ```
2. **Add Angular Material:**
   ```bash
   ng add @angular/material
   ```
3. **Import a component module:**
   ```typescript
   // app.module.ts
   import { MatButtonModule } from '@angular/material/button';
   @NgModule({
     imports: [MatButtonModule],
   })
   export class AppModule {}
   ```
4. **Use the component in your template:**
   ```html
   <button mat-raised-button color="primary">Click Me</button>
   ```

---

## 14.7 Resources

- [Angular Material Docs](https://material.angular.io/)
- [Material Design Guidelines](https://material.io/design)
- [Theming Guide](https://material.angular.io/guide/theming)
- [Angular Flex Layout](https://github.com/angular/flex-layout)
