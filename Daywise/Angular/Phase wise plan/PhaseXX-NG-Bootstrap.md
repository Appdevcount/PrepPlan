# Phase 23: NG Bootstrap — Bootstrap Components for Angular

> NG Bootstrap brings the power of Bootstrap’s UI components to Angular, implemented natively with no jQuery dependency. This guide provides detailed explanations, code samples, and best practices for using NG Bootstrap in your Angular projects.

---

## 23.1 What is NG Bootstrap?

- A library of Bootstrap 4/5 components for Angular
- No jQuery required; fully native Angular
- Integrates seamlessly with Angular forms and change detection

**Why use NG Bootstrap?**
- Quickly add responsive, accessible Bootstrap UI elements
- Use familiar Bootstrap styles with Angular’s power
- No need for external JS dependencies

---

## 23.2 Installing NG Bootstrap

1. **Install Bootstrap and NG Bootstrap:**
   ```bash
   npm install @ng-bootstrap/ng-bootstrap bootstrap
   ```
2. **Add Bootstrap CSS to angular.json:**
   ```json
   "styles": [
     "node_modules/bootstrap/dist/css/bootstrap.min.css",
     "src/styles.css"
   ]
   ```
3. **Import NgbModule in your AppModule:**
   ```typescript
   import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
   @NgModule({
     imports: [NgbModule],
   })
   export class AppModule {}
   ```

---

## 23.3 Using NG Bootstrap Components (with More Examples)


### 1. Alert
```html
<ngb-alert type="success" [dismissible]="true">Operation successful!</ngb-alert>
```
**Explanation:**
- Use `<ngb-alert>` for contextual feedback messages.
- The `type` attribute sets the color (success, info, warning, danger).
- `[dismissible]` allows the user to close the alert.

**Dynamic Alerts Example:**
```typescript
alerts = [
  { type: 'success', message: 'Profile updated!' },
  { type: 'danger', message: 'Error saving data.' }
];
```
```html
<ngb-alert *ngFor="let alert of alerts" [type]="alert.type" [dismissible]="true">
  {{ alert.message }}
</ngb-alert>
```


### 2. Modal
**Open a modal dialog from a component:**
```typescript
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { Component } from '@angular/core';

@Component({
  selector: 'app-modal-demo',
  template: `
    <button (click)="openModal(content)">Open Modal</button>
    <ng-template #content let-modal>
      <div class="modal-header">
        <h4 class="modal-title">Modal Title</h4>
        <button type="button" class="close" aria-label="Close" (click)="modal.dismiss('Cross click')">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p>This is a modal body.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-dark" (click)="modal.close('Ok click')">OK</button>
      </div>
    </ng-template>`
})
export class ModalDemoComponent {
  constructor(private modalService: NgbModal) {}
  openModal(content: any) {
    this.modalService.open(content, { centered: true }); // Centered modal
  }
}
```

**Explanation:**
- Use `<ng-template #content>` for modal content.
- Inject `NgbModal` and call `open()` to show the modal.
- You can pass options (e.g., `{ centered: true }`).

**Passing Data to Modals:**
```typescript
openModal(content: any) {
  const modalRef = this.modalService.open(content);
  modalRef.componentInstance.data = { name: 'Angular' };
}
```


### 3. Carousel
```html
<ngb-carousel>
  <ng-template ngbSlide>
    <img src="/assets/slide1.jpg" alt="First slide">
    <div class="carousel-caption">
      <h3>First Slide</h3>
    </div>
  </ng-template>
  <ng-template ngbSlide>
    <img src="/assets/slide2.jpg" alt="Second slide">
    <div class="carousel-caption">
      <h3>Second Slide</h3>
    </div>
  </ng-template>
</ngb-carousel>
```

**Explanation:**
- Each slide is wrapped in `<ng-template ngbSlide>`.
- Add images and captions as needed.
- You can control the interval, navigation, and pause on hover.

**Customizing Carousel:**
```html
<ngb-carousel [interval]="3000" [pauseOnHover]="true" [showNavigationArrows]="true">
  <!-- slides -->
</ngb-carousel>
```


### 4. Accordion
```html
<ngb-accordion #acc="ngbAccordion" activeIds="panel-0">
  <ngb-panel id="panel-0" title="Panel 1">
    <ng-template ngbPanelContent>
      Content of Panel 1
    </ng-template>
  </ngb-panel>
  <ngb-panel id="panel-1" title="Panel 2">
    <ng-template ngbPanelContent>
      Content of Panel 2
    </ng-template>
  </ngb-panel>
</ngb-accordion>
```

**Explanation:**
- Use `<ngb-accordion>` for collapsible panels.
- `activeIds` sets which panels are open by default.
- You can control the accordion programmatically using the template reference variable (`#acc`).

**Accordion with Dynamic Panels:**
```typescript
panels = [
  { id: 'panel-0', title: 'Panel 1', content: 'Content 1' },
  { id: 'panel-1', title: 'Panel 2', content: 'Content 2' }
];
```
```html
<ngb-accordion>
  <ngb-panel *ngFor="let p of panels" [id]="p.id" [title]="p.title">
    <ng-template ngbPanelContent>{{ p.content }}</ng-template>
  </ngb-panel>
</ngb-accordion>
```


### 5. Datepicker
```html
<input class="form-control" placeholder="yyyy-mm-dd" name="dp" ngbDatepicker #d="ngbDatepicker">
<button class="btn btn-outline-secondary" (click)="d.toggle()" type="button">Toggle</button>
```

**Explanation:**
- Add `ngbDatepicker` directive to an input for a popup calendar.
- Use a button to toggle the datepicker.
- Bind the input to a model for reactive forms.

**Datepicker with Model Binding:**
```typescript
dateModel: { year: number, month: number, day: number };
```
```html
<input [(ngModel)]="dateModel" ngbDatepicker>
```

---

### 6. Pagination
```html
<ngb-pagination [collectionSize]="100" [(page)]="page" [pageSize]="10"></ngb-pagination>
```
```typescript
page = 1;
```
**Explanation:**
- Use `<ngb-pagination>` for paginated lists.
- Bind `collectionSize` to the total number of items, `pageSize` to items per page, and `[(page)]` to the current page.

---

### 7. Tooltip & Popover
```html
<button ngbTooltip="Tooltip text">Hover for tooltip</button>
<button ngbPopover="Popover content" popoverTitle="Popover title">Click for popover</button>
```
**Explanation:**
- Use `ngbTooltip` for simple hover tooltips.
- Use `ngbPopover` for richer, clickable popovers.

---

### 8. Typeahead (Autocomplete)
```html
<input id="typeahead-basic" type="text" class="form-control" [(ngModel)]="model" [ngbTypeahead]="search">
```
```typescript
model: any;
search = (text$: Observable<string>) =>
  text$.pipe(
    debounceTime(200),
    distinctUntilChanged(),
    map(term => term.length < 2 ? [] : states.filter(v => v.toLowerCase().indexOf(term.toLowerCase()) > -1))
  );
states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California'];
```
**Explanation:**
- Use `[ngbTypeahead]` for autocomplete inputs.
- Provide a search function that returns an observable of results.

---

---

## 23.4 How to Use NG Bootstrap in a New Project (Step-by-Step)

1. **Create a new Angular project:**
   ```bash
   ng new my-ng-bootstrap-app
   cd my-ng-bootstrap-app
   ```
2. **Install NG Bootstrap and Bootstrap:**
   ```bash
   npm install @ng-bootstrap/ng-bootstrap bootstrap
   ```
3. **Add Bootstrap CSS to angular.json:**
   ```json
   "styles": [
     "node_modules/bootstrap/dist/css/bootstrap.min.css",
     "src/styles.css"
   ]
   ```
4. **Import NgbModule in AppModule:**
   ```typescript
   import { NgbModule } from '@ng-bootstrap/ng-bootstrap';
   @NgModule({ imports: [NgbModule] })
   export class AppModule {}
   ```
5. **Use NG Bootstrap components in your templates as shown above.**

---

## 23.5 Best Practices and Tips

- Use Angular’s reactive forms with NG Bootstrap for robust form handling.
- Always use Bootstrap’s grid system for responsive layouts.
- Prefer Angular’s built-in security features (avoid direct DOM manipulation).
- Read the [NG Bootstrap documentation](https://ng-bootstrap.github.io/#/home) for advanced usage and customization.

---

## 23.6 Resources

- [NG Bootstrap Documentation](https://ng-bootstrap.github.io/#/home)
- [Bootstrap Documentation](https://getbootstrap.com/docs/5.0/getting-started/introduction/)
- [Angular Forms Guide](https://angular.io/guide/forms)
