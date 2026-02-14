# Phase 7: Forms — Template-Driven & Reactive

> Forms are the bread and butter of business applications. Almost every app you build will have login screens, registration pages, search bars, checkout flows, settings panels, and data-entry interfaces. Angular doesn't just give you one way to handle forms — it gives you TWO complete systems, each optimized for different scenarios. Mastering both is non-negotiable for any serious Angular developer.

---

## 7.1 Why Angular Has Two Form Approaches

### The Core Problem Forms Must Solve

HTML forms on their own are dumb. They don't validate in real-time, they don't track whether a user has touched a field, they don't know if a value has changed, and they have no concept of "this field depends on that field." Angular's form systems solve ALL of these problems — but they do it in two philosophically different ways.

### Template-Driven Forms — "Let the template do the work"

Template-driven forms put the logic in the HTML template. You use directives like `ngModel` to bind form controls, and Angular creates the underlying model objects (`FormControl`, `FormGroup`) **automatically behind the scenes**. You never explicitly create these objects in your TypeScript code.

**Philosophy:** Declarative. You declare what you want in the template, and Angular figures out the rest. This is similar to how AngularJS (Angular 1.x) forms worked.

### Reactive Forms — "Let the component class do the work"

Reactive forms put the logic in the TypeScript component class. You explicitly create `FormControl`, `FormGroup`, and `FormArray` objects, define validators, and wire everything up programmatically. The template just binds to these objects.

**Philosophy:** Imperative and functional. You have full programmatic control. You can test the form logic without the DOM. You can react to value changes as observable streams.

### The Surprise: They Use the SAME Underlying Model

Both approaches use the exact same core classes under the hood:

```
FormControl  →  Tracks a single input (e.g., an email field)
FormGroup    →  Tracks a group of FormControls (e.g., an entire form)
FormArray    →  Tracks an array of FormControls or FormGroups (e.g., dynamic rows)
```

The difference is simply **where and how** these objects are created:

| Aspect | Template-Driven | Reactive |
|---|---|---|
| **Where model is defined** | In the template (HTML) | In the component class (TypeScript) |
| **Model creation** | Automatic (Angular creates it via directives) | Manual (you create FormControl, FormGroup, etc.) |
| **Module to import** | `FormsModule` | `ReactiveFormsModule` |
| **Key directive** | `ngModel` | `formControlName` |
| **Data flow** | Two-way (via `[(ngModel)]`) | Typically one-way (reactive streams) |
| **Validation** | HTML attributes + directives | `Validators` class in TypeScript |
| **Testability** | Harder (requires DOM to test) | Easier (pure TypeScript, no DOM needed) |
| **Dynamic forms** | Difficult | Easy (FormArray, add/remove controls) |
| **Best for** | Simple forms, prototypes, small apps | Complex forms, enterprise apps, dynamic fields |
| **Learning curve** | Lower | Higher |
| **Value change tracking** | Callback-based (`ngModelChange`) | Observable-based (`valueChanges`) |

### When to Use Which?

**Use Template-Driven when:**
- The form is simple (login, search, basic contact form)
- You have few fields (under 5-7)
- Validation is straightforward (required, email, minlength)
- You want to get something working quickly
- The team is more comfortable with HTML

**Use Reactive when:**
- The form is complex (multi-step wizards, dynamic fields)
- You need to add/remove fields dynamically
- You need cross-field validation (e.g., password confirmation)
- You want to unit-test form logic without the DOM
- You need to react to value changes with RxJS operators (debounce, switchMap, etc.)
- You're building enterprise/production applications

**Industry reality:** Most professional Angular teams standardize on **Reactive Forms** for everything. They're more powerful, more testable, and more predictable. Template-driven forms are great for learning and for very simple scenarios.

---

## 7.2 Template-Driven Forms

### Step 1: Import FormsModule

Before using ANY template-driven form feature, you must import `FormsModule` into your module.

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { FormsModule } from '@angular/forms';  // ← THIS IS REQUIRED

import { AppComponent } from './app.component';
import { RegistrationComponent } from './registration/registration.component';

@NgModule({
  declarations: [
    AppComponent,
    RegistrationComponent
  ],
  imports: [
    BrowserModule,
    FormsModule  // ← Add it here. Without this, ngModel won't work!
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

**Common mistake:** Forgetting to import `FormsModule` is the #1 reason `ngModel` doesn't work. Angular will throw an error: `Can't bind to 'ngModel' since it isn't a known property of 'input'`.

If you're using standalone components (Angular 14+), import `FormsModule` directly in the component:

```typescript
@Component({
  selector: 'app-registration',
  standalone: true,
  imports: [FormsModule, CommonModule],  // ← Import here for standalone
  templateUrl: './registration.component.html'
})
export class RegistrationComponent { }
```

---

### Step 2: Understanding ngModel, ngForm, and ngModelGroup

Angular provides three key directives for template-driven forms:

| Directive | What it does | Creates | Example |
|---|---|---|---|
| `ngModel` | Tracks a single form field | `FormControl` | `<input ngModel name="email">` |
| `ngForm` | Tracks the entire form | `FormGroup` | Automatically applied to `<form>` tags |
| `ngModelGroup` | Groups related fields | A nested `FormGroup` | `<div ngModelGroup="address">` |

**Key insight:** When Angular sees a `<form>` tag in a template that has `FormsModule` imported, it AUTOMATICALLY attaches the `ngForm` directive to it. You don't need to add it yourself. That's why `<form>` tags in Angular "just work" — Angular is silently managing them.

---

### Step 3: Template Reference Variables

To access the form's state in the template, you use template reference variables:

```html
<!-- #myForm captures the ngForm directive instance -->
<form #myForm="ngForm">

  <!-- #emailField captures the ngModel directive instance for this specific field -->
  <input ngModel name="email" #emailField="ngModel">

</form>
```

**Why the `="ngForm"` and `="ngModel"` part?** Without it, the template reference variable would point to the raw HTML element. By saying `="ngForm"`, you're telling Angular: "I don't want the HTML element — I want the Angular directive instance that's attached to this element." This gives you access to properties like `valid`, `invalid`, `dirty`, `touched`, etc.

---

### Step 4: Form State Properties

Every form and every field has these state properties:

| Property | Meaning | When it's `true` |
|---|---|---|
| `valid` | All validators pass | Form/field has no errors |
| `invalid` | At least one validator fails | Form/field has errors |
| `dirty` | User has changed the value | User typed something |
| `pristine` | User has NOT changed the value | No user interaction with value |
| `touched` | User has focused and then blurred | User clicked in, then clicked out |
| `untouched` | User has NOT blurred the field | User hasn't left the field yet |
| `pending` | Async validators are running | Waiting for server response |

**Why do these matter?** They let you control WHEN to show error messages. You don't want to scream "EMAIL IS REQUIRED!" the moment the page loads — the user hasn't had a chance to type yet. Instead, you show errors only after the user has `touched` the field (clicked in and out without filling it) or after the field is `dirty` (they typed something but it's still invalid).

**CSS classes Angular adds automatically:**

Angular also adds CSS classes to form fields based on their state:

| State | CSS Class Added | Opposite CSS Class |
|---|---|---|
| Valid | `ng-valid` | `ng-invalid` |
| Pristine | `ng-pristine` | `ng-dirty` |
| Untouched | `ng-untouched` | `ng-touched` |

You can use these for styling:

```css
/* Red border when a field is invalid AND the user has touched it */
input.ng-invalid.ng-touched {
  border: 2px solid red;
}

/* Green border when a field is valid */
input.ng-valid.ng-touched {
  border: 2px solid green;
}
```

---

### Step 5: Full Working Example — Template-Driven Registration Form

Here's a complete, production-quality template-driven form with validation.

**registration.component.ts:**

```typescript
import { Component } from '@angular/core';

@Component({
  selector: 'app-registration',
  templateUrl: './registration.component.html',
  styleUrls: ['./registration.component.css']
})
export class RegistrationComponent {
  // The model object — ngModel will bind to these properties
  user = {
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    gender: '',
    agreeToTerms: false
  };

  // Called when the form is submitted
  onSubmit(form: any): void {
    // The 'form' parameter is the ngForm instance
    console.log('Form Valid?', form.valid);
    console.log('Form Values:', form.value);
    // form.value gives you: { name: 'John', email: 'john@test.com', ... }

    if (form.valid) {
      console.log('Submitting to server:', this.user);
      // In a real app: this.authService.register(this.user).subscribe(...)
    }
  }

  // You can also reset the form programmatically
  resetForm(form: any): void {
    form.reset();
    // This resets all fields AND resets dirty/touched states back to pristine/untouched
  }
}
```

**registration.component.html:**

```html
<div class="form-container">
  <h2>Create an Account</h2>

  <!--
    #regForm="ngForm" — captures the form's Angular directive instance.
    (ngSubmit)="onSubmit(regForm)" — calls our method when the form is submitted.
    We pass the form reference so we can check validity in the component.
  -->
  <form #regForm="ngForm" (ngSubmit)="onSubmit(regForm)">

    <!-- ============ NAME FIELD ============ -->
    <div class="form-group">
      <label for="name">Full Name</label>
      <!--
        [(ngModel)]="user.name" — two-way binding to our model property.
        name="name" — REQUIRED. ngModel uses this to register the control.
        required — HTML5 validation attribute. Angular picks this up.
        minlength="3" — must be at least 3 characters.
        #nameField="ngModel" — lets us access this field's state in the template.
      -->
      <input
        type="text"
        id="name"
        [(ngModel)]="user.name"
        name="name"
        required
        minlength="3"
        #nameField="ngModel"
        placeholder="Enter your full name"
      >
      <!--
        Show errors ONLY when the field is invalid AND (dirty OR touched).
        This prevents showing errors when the page first loads.
      -->
      <div class="error-messages" *ngIf="nameField.invalid && (nameField.dirty || nameField.touched)">
        <!--
          nameField.errors is an object like { required: true } or { minlength: { requiredLength: 3, actualLength: 1 } }
          We check for each specific error to show the right message.
        -->
        <small class="error" *ngIf="nameField.errors?.['required']">
          Name is required.
        </small>
        <small class="error" *ngIf="nameField.errors?.['minlength']">
          Name must be at least {{ nameField.errors?.['minlength'].requiredLength }} characters.
          You have typed {{ nameField.errors?.['minlength'].actualLength }}.
        </small>
      </div>
    </div>

    <!-- ============ EMAIL FIELD ============ -->
    <div class="form-group">
      <label for="email">Email</label>
      <input
        type="email"
        id="email"
        [(ngModel)]="user.email"
        name="email"
        required
        email
        #emailField="ngModel"
        placeholder="Enter your email"
      >
      <!--
        The 'email' validator is a built-in Angular validator.
        It checks for a valid email format (contains @ and domain).
      -->
      <div class="error-messages" *ngIf="emailField.invalid && (emailField.dirty || emailField.touched)">
        <small class="error" *ngIf="emailField.errors?.['required']">
          Email is required.
        </small>
        <small class="error" *ngIf="emailField.errors?.['email']">
          Please enter a valid email address.
        </small>
      </div>
    </div>

    <!-- ============ PASSWORD FIELD ============ -->
    <div class="form-group">
      <label for="password">Password</label>
      <input
        type="password"
        id="password"
        [(ngModel)]="user.password"
        name="password"
        required
        minlength="8"
        pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$"
        #passwordField="ngModel"
        placeholder="Enter a strong password"
      >
      <!--
        The 'pattern' attribute uses a regex.
        This regex requires: at least one lowercase, one uppercase, and one digit.
      -->
      <div class="error-messages" *ngIf="passwordField.invalid && (passwordField.dirty || passwordField.touched)">
        <small class="error" *ngIf="passwordField.errors?.['required']">
          Password is required.
        </small>
        <small class="error" *ngIf="passwordField.errors?.['minlength']">
          Password must be at least 8 characters.
        </small>
        <small class="error" *ngIf="passwordField.errors?.['pattern']">
          Password must contain at least one uppercase letter, one lowercase letter, and one number.
        </small>
      </div>
    </div>

    <!-- ============ CONFIRM PASSWORD FIELD ============ -->
    <div class="form-group">
      <label for="confirmPassword">Confirm Password</label>
      <input
        type="password"
        id="confirmPassword"
        [(ngModel)]="user.confirmPassword"
        name="confirmPassword"
        required
        #confirmPasswordField="ngModel"
        placeholder="Re-enter your password"
      >
      <div class="error-messages"
           *ngIf="confirmPasswordField.touched && user.password !== user.confirmPassword">
        <!--
          Cross-field validation in template-driven forms is clunky.
          We have to compare the model values directly in the template.
          This is one reason Reactive forms are preferred for complex validation.
        -->
        <small class="error">
          Passwords do not match.
        </small>
      </div>
    </div>

    <!-- ============ GENDER (Radio Buttons) ============ -->
    <div class="form-group">
      <label>Gender</label>
      <div class="radio-group">
        <label>
          <input type="radio" [(ngModel)]="user.gender" name="gender" value="male" required>
          Male
        </label>
        <label>
          <input type="radio" [(ngModel)]="user.gender" name="gender" value="female">
          Female
        </label>
        <label>
          <input type="radio" [(ngModel)]="user.gender" name="gender" value="other">
          Other
        </label>
      </div>
    </div>

    <!-- ============ TERMS CHECKBOX ============ -->
    <div class="form-group">
      <label>
        <input
          type="checkbox"
          [(ngModel)]="user.agreeToTerms"
          name="agreeToTerms"
          required
          #termsField="ngModel"
        >
        I agree to the Terms and Conditions
      </label>
      <div class="error-messages" *ngIf="termsField.invalid && termsField.touched">
        <small class="error">You must agree to the terms.</small>
      </div>
    </div>

    <!-- ============ SUBMIT BUTTON ============ -->
    <!--
      [disabled]="regForm.invalid" — the button is disabled until the ENTIRE form is valid.
      This prevents submission of incomplete/invalid data.
    -->
    <button type="submit" [disabled]="regForm.invalid" class="submit-btn">
      Register
    </button>

    <button type="button" (click)="resetForm(regForm)" class="reset-btn">
      Reset
    </button>

    <!-- ============ DEBUG: Show form state (remove in production) ============ -->
    <div class="debug" style="margin-top: 20px; padding: 10px; background: #f5f5f5;">
      <h4>Debug Info (remove in production):</h4>
      <p>Form Valid: {{ regForm.valid }}</p>
      <p>Form Dirty: {{ regForm.dirty }}</p>
      <p>Form Touched: {{ regForm.touched }}</p>
      <pre>Form Value: {{ regForm.value | json }}</pre>
      <pre>Model Value: {{ user | json }}</pre>
    </div>
  </form>
</div>
```

**registration.component.css:**

```css
.form-container {
  max-width: 500px;
  margin: 20px auto;
  padding: 20px;
}

.form-group {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}

input[type="text"],
input[type="email"],
input[type="password"] {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 14px;
}

/* Angular automatically adds these classes based on form state */
input.ng-invalid.ng-touched {
  border-color: red;
}

input.ng-valid.ng-touched {
  border-color: green;
}

.error {
  color: red;
  display: block;
  margin-top: 4px;
}

.submit-btn {
  padding: 10px 20px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.submit-btn:disabled {
  background: #cccccc;
  cursor: not-allowed;
}

.reset-btn {
  padding: 10px 20px;
  margin-left: 10px;
  background: #6c757d;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
```

### How Two-Way Binding with ngModel Actually Works

`[(ngModel)]` is Angular's "banana in a box" syntax. It's actually shorthand for TWO separate bindings combined:

```html
<!-- This: -->
<input [(ngModel)]="user.name" name="name">

<!-- Is shorthand for this: -->
<input [ngModel]="user.name" (ngModelChange)="user.name = $event" name="name">

<!-- Breaking it down:
  [ngModel]="user.name"              → Property binding: pushes value FROM component TO input
  (ngModelChange)="user.name = $event" → Event binding: pushes value FROM input TO component
-->
```

**When would you use the expanded form?** When you need to DO something when the value changes:

```html
<!-- Run custom logic on every keystroke -->
<input
  [ngModel]="user.email"
  (ngModelChange)="onEmailChange($event)"
  name="email"
>
```

```typescript
onEmailChange(newEmail: string): void {
  this.user.email = newEmail;
  this.checkEmailAvailability(newEmail);  // Extra logic!
}
```

### Important Rule: ngModel REQUIRES a name Attribute

Every `ngModel` directive MUST be paired with a `name` attribute (or `[ngModelOptions]="{standalone: true}"`). Angular uses the `name` to register the control within the form's `FormGroup`. Without it, you'll get an error:

```
ERROR: If ngModel is used within a form tag, either the name attribute must be set
or the form control must be defined as 'standalone' in ngModelOptions.
```

---

## 7.3 Reactive Forms

Reactive forms shift control from the template to the component class. You create the form model explicitly in TypeScript, giving you complete programmatic control.

### Step 1: Import ReactiveFormsModule

```typescript
// app.module.ts
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule } from '@angular/forms';  // ← Note: NOT FormsModule

@NgModule({
  declarations: [AppComponent, RegistrationComponent],
  imports: [
    BrowserModule,
    ReactiveFormsModule  // ← This enables reactive form directives
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

**Important:** You CAN import both `FormsModule` and `ReactiveFormsModule` in the same module if you need both approaches. But don't mix template-driven and reactive approaches on the SAME form — pick one per form.

---

### Step 2: FormControl — The Atomic Unit

A `FormControl` represents a single input field. It tracks the field's value, validation status, and user interaction state.

```typescript
import { FormControl } from '@angular/forms';

// Creating a FormControl with an initial value
const nameControl = new FormControl('');           // Initial value: empty string
const ageControl = new FormControl(25);            // Initial value: 25
const activeControl = new FormControl(true);       // Initial value: true
const emailControl = new FormControl('test@test.com');  // Initial value: pre-filled

// You can also pass validators as the second argument
import { Validators } from '@angular/forms';
const emailControl2 = new FormControl('', [Validators.required, Validators.email]);
```

**What can you do with a FormControl?**

```typescript
const name = new FormControl('John');

name.value;           // 'John' — current value
name.valid;           // true/false — does it pass all validators?
name.invalid;         // opposite of valid
name.dirty;           // has the user changed the value?
name.pristine;        // opposite of dirty
name.touched;         // has the user focused and blurred?
name.untouched;       // opposite of touched
name.errors;          // null if valid, or an object like { required: true }
name.status;          // 'VALID', 'INVALID', 'PENDING', or 'DISABLED'

name.setValue('Jane');      // Set a new value
name.reset();               // Reset to initial value and clear dirty/touched
name.disable();             // Disable the control (excluded from form value)
name.enable();              // Re-enable the control

// Observables — the POWER of reactive forms
name.valueChanges.subscribe(value => {
  console.log('Name changed to:', value);
});

name.statusChanges.subscribe(status => {
  console.log('Validation status:', status);  // 'VALID' or 'INVALID'
});
```

---

### Step 3: FormGroup — Grouping Controls

A `FormGroup` bundles multiple `FormControl`s into a single object. Think of it as "the entire form" or "a section of the form."

```typescript
import { FormGroup, FormControl, Validators } from '@angular/forms';

// Creating a FormGroup
const registrationForm = new FormGroup({
  name: new FormControl('', [Validators.required, Validators.minLength(3)]),
  email: new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required, Validators.minLength(8)])
});

// Accessing individual controls
registrationForm.get('email');                  // Returns the email FormControl
registrationForm.get('email')?.value;           // The email value
registrationForm.get('email')?.valid;           // Is the email valid?

// Getting all values at once
registrationForm.value;
// Returns: { name: '', email: '', password: '' }

// Checking form-level validity (ALL controls must be valid)
registrationForm.valid;     // true only if ALL fields are valid
registrationForm.invalid;   // true if ANY field is invalid
```

**Nested FormGroups** — useful for grouping related fields like an address:

```typescript
const profileForm = new FormGroup({
  name: new FormControl(''),
  email: new FormControl(''),
  address: new FormGroup({            // ← Nested FormGroup
    street: new FormControl(''),
    city: new FormControl(''),
    state: new FormControl(''),
    zip: new FormControl('')
  })
});

// Accessing nested controls
profileForm.get('address.city')?.value;  // Access nested control with dot notation
```

---

### Step 4: FormArray — Dynamic Lists

A `FormArray` is like a `FormGroup`, but instead of named keys, it uses numeric indices. This is perfect for dynamic lists — things like "add another phone number" or "add another skill."

```typescript
import { FormArray, FormGroup, FormControl, Validators } from '@angular/forms';

const form = new FormGroup({
  name: new FormControl(''),
  // An array of phone number controls
  phones: new FormArray([
    new FormControl('', Validators.required),  // First phone (index 0)
    new FormControl('')                         // Second phone (index 1)
  ])
});

// Access the FormArray
const phones = form.get('phones') as FormArray;

// Get a specific control by index
phones.at(0).value;   // Value of the first phone

// Add a new phone field dynamically
phones.push(new FormControl('', Validators.required));

// Remove a phone field by index
phones.removeAt(1);

// Get all phone values
phones.value;  // ['555-1234', '555-5678', ...]

// Get the length
phones.length;  // How many phone fields exist
```

We'll cover FormArray in much more detail in Section 7.5.

---

### Step 5: Full Working Example — Reactive Registration Form

Let's rebuild the same registration form from Section 7.2, but using reactive forms.

**registration.component.ts:**

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-registration',
  templateUrl: './registration.component.html',
  styleUrls: ['./registration.component.css']
})
export class RegistrationComponent implements OnInit, OnDestroy {
  // Define the form model in the component class — THIS is what makes it "reactive"
  registrationForm!: FormGroup;

  // Store subscriptions so we can clean up on destroy
  private subscriptions: Subscription[] = [];

  ngOnInit(): void {
    // Create the form structure
    this.registrationForm = new FormGroup({
      // Each FormControl takes: initial value, sync validators, async validators
      name: new FormControl('', [
        Validators.required,
        Validators.minLength(3)
      ]),
      email: new FormControl('', [
        Validators.required,
        Validators.email
      ]),
      password: new FormControl('', [
        Validators.required,
        Validators.minLength(8),
        Validators.pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/)
      ]),
      confirmPassword: new FormControl('', [
        Validators.required
      ]),
      gender: new FormControl('', Validators.required),
      agreeToTerms: new FormControl(false, Validators.requiredTrue)
      // Validators.requiredTrue — the checkbox must be checked (true), not just present
    });

    // REACTIVE POWER: Subscribe to value changes
    // This is something template-driven forms can't do easily
    const emailSub = this.registrationForm.get('email')!.valueChanges.subscribe(
      (emailValue: string) => {
        console.log('Email changed to:', emailValue);
        // You could debounce this and check the server for availability
      }
    );
    this.subscriptions.push(emailSub);

    // Subscribe to the entire form's value changes
    const formSub = this.registrationForm.valueChanges.subscribe(
      (formValue) => {
        console.log('Form changed:', formValue);
      }
    );
    this.subscriptions.push(formSub);

    // Subscribe to status changes (VALID, INVALID, PENDING)
    const statusSub = this.registrationForm.statusChanges.subscribe(
      (status: string) => {
        console.log('Form status:', status);
      }
    );
    this.subscriptions.push(statusSub);
  }

  ngOnDestroy(): void {
    // IMPORTANT: Always unsubscribe to prevent memory leaks
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  onSubmit(): void {
    // No need to pass the form from the template — we already have it
    if (this.registrationForm.valid) {
      console.log('Form Values:', this.registrationForm.value);
      // Output: { name: 'John', email: 'john@test.com', password: '...', ... }

      // getRawValue() includes disabled fields too (value excludes them)
      console.log('Raw Values:', this.registrationForm.getRawValue());
    } else {
      // Mark all fields as touched to trigger validation display
      this.registrationForm.markAllAsTouched();
    }
  }

  // Convenience getter methods — makes template code cleaner
  // Instead of: registrationForm.get('name')
  // You write: nameCtrl
  get nameCtrl(): FormControl {
    return this.registrationForm.get('name') as FormControl;
  }

  get emailCtrl(): FormControl {
    return this.registrationForm.get('email') as FormControl;
  }

  get passwordCtrl(): FormControl {
    return this.registrationForm.get('password') as FormControl;
  }

  get confirmPasswordCtrl(): FormControl {
    return this.registrationForm.get('confirmPassword') as FormControl;
  }

  resetForm(): void {
    // reset() clears all values AND resets dirty/touched states
    this.registrationForm.reset();

    // You can also reset to specific values
    // this.registrationForm.reset({ name: '', email: '', gender: 'male' });
  }

  // Demonstrating setValue vs patchValue
  fillSampleData(): void {
    // setValue — MUST provide ALL controls. If you miss one, it throws an error.
    this.registrationForm.setValue({
      name: 'John Doe',
      email: 'john@example.com',
      password: 'MyPass123',
      confirmPassword: 'MyPass123',
      gender: 'male',
      agreeToTerms: true
    });

    // patchValue — only updates the controls you specify. Ignores missing ones.
    // this.registrationForm.patchValue({
    //   name: 'Jane Doe',
    //   email: 'jane@example.com'
    //   // Other fields remain unchanged
    // });
  }
}
```

**registration.component.html:**

```html
<div class="form-container">
  <h2>Create an Account (Reactive)</h2>

  <!--
    [formGroup]="registrationForm" — binds this <form> to our FormGroup.
    (ngSubmit)="onSubmit()" — calls our method on submit. No need to pass the form.
  -->
  <form [formGroup]="registrationForm" (ngSubmit)="onSubmit()">

    <!-- ============ NAME FIELD ============ -->
    <div class="form-group">
      <label for="name">Full Name</label>
      <!--
        formControlName="name" — binds this input to the 'name' FormControl.
        Note: NO [(ngModel)] here! Reactive forms use formControlName instead.
        The "name" string must match the key in our FormGroup definition.
      -->
      <input
        type="text"
        id="name"
        formControlName="name"
        placeholder="Enter your full name"
      >
      <!--
        We use our getter methods (nameCtrl) for cleaner template code.
        Same pattern: show errors only when invalid AND (dirty OR touched).
      -->
      <div class="error-messages" *ngIf="nameCtrl.invalid && (nameCtrl.dirty || nameCtrl.touched)">
        <small class="error" *ngIf="nameCtrl.hasError('required')">
          Name is required.
        </small>
        <small class="error" *ngIf="nameCtrl.hasError('minlength')">
          Name must be at least {{ nameCtrl.getError('minlength').requiredLength }} characters.
        </small>
      </div>
    </div>

    <!-- ============ EMAIL FIELD ============ -->
    <div class="form-group">
      <label for="email">Email</label>
      <input
        type="email"
        id="email"
        formControlName="email"
        placeholder="Enter your email"
      >
      <div class="error-messages" *ngIf="emailCtrl.invalid && (emailCtrl.dirty || emailCtrl.touched)">
        <small class="error" *ngIf="emailCtrl.hasError('required')">
          Email is required.
        </small>
        <small class="error" *ngIf="emailCtrl.hasError('email')">
          Please enter a valid email address.
        </small>
      </div>
    </div>

    <!-- ============ PASSWORD FIELD ============ -->
    <div class="form-group">
      <label for="password">Password</label>
      <input
        type="password"
        id="password"
        formControlName="password"
        placeholder="Enter a strong password"
      >
      <div class="error-messages" *ngIf="passwordCtrl.invalid && (passwordCtrl.dirty || passwordCtrl.touched)">
        <small class="error" *ngIf="passwordCtrl.hasError('required')">
          Password is required.
        </small>
        <small class="error" *ngIf="passwordCtrl.hasError('minlength')">
          Password must be at least 8 characters.
        </small>
        <small class="error" *ngIf="passwordCtrl.hasError('pattern')">
          Must contain uppercase, lowercase, and a number.
        </small>
      </div>
    </div>

    <!-- ============ CONFIRM PASSWORD ============ -->
    <div class="form-group">
      <label for="confirmPassword">Confirm Password</label>
      <input
        type="password"
        id="confirmPassword"
        formControlName="confirmPassword"
        placeholder="Re-enter your password"
      >
      <!--
        Cross-field validation is messy here without a custom validator.
        We'll fix this properly in Section 7.4 with a cross-field validator.
      -->
      <div class="error-messages"
           *ngIf="confirmPasswordCtrl.touched &&
                  passwordCtrl.value !== confirmPasswordCtrl.value">
        <small class="error">Passwords do not match.</small>
      </div>
    </div>

    <!-- ============ GENDER (Radio Buttons) ============ -->
    <div class="form-group">
      <label>Gender</label>
      <div class="radio-group">
        <label>
          <input type="radio" formControlName="gender" value="male"> Male
        </label>
        <label>
          <input type="radio" formControlName="gender" value="female"> Female
        </label>
        <label>
          <input type="radio" formControlName="gender" value="other"> Other
        </label>
      </div>
    </div>

    <!-- ============ TERMS CHECKBOX ============ -->
    <div class="form-group">
      <label>
        <input type="checkbox" formControlName="agreeToTerms">
        I agree to the Terms and Conditions
      </label>
    </div>

    <!-- ============ BUTTONS ============ -->
    <button type="submit" [disabled]="registrationForm.invalid" class="submit-btn">
      Register
    </button>
    <button type="button" (click)="resetForm()" class="reset-btn">
      Reset
    </button>
    <button type="button" (click)="fillSampleData()" class="fill-btn">
      Fill Sample Data
    </button>

    <!-- ============ DEBUG ============ -->
    <pre style="margin-top: 20px; background: #f5f5f5; padding: 10px;">
Form Value: {{ registrationForm.value | json }}
Form Valid: {{ registrationForm.valid }}
Form Status: {{ registrationForm.status }}
    </pre>
  </form>
</div>
```

### setValue vs patchValue — When to Use Which

This is a common interview question and a frequent source of bugs:

```typescript
const form = new FormGroup({
  name: new FormControl(''),
  email: new FormControl(''),
  age: new FormControl(0)
});

// setValue — STRICT. Must provide ALL controls. Missing any = error.
form.setValue({
  name: 'John',
  email: 'john@test.com',
  age: 30
});
// If you omit 'age', you get:
// ERROR: Must supply a value for form control with name: 'age'

// patchValue — FLEXIBLE. Provide only what you want to update. Rest unchanged.
form.patchValue({
  name: 'Jane'
  // email and age remain unchanged
});
```

**Rule of thumb:**
- Use `setValue` when you're loading a complete object from the server (e.g., editing an existing user)
- Use `patchValue` when you want to update specific fields (e.g., auto-filling a city based on zip code)

### valueChanges and statusChanges — The Reactive Power

The killer feature of reactive forms is that every `FormControl`, `FormGroup`, and `FormArray` exposes RxJS observables:

```typescript
// Listen to a single field changing
this.registrationForm.get('email')!.valueChanges
  .pipe(
    debounceTime(300),          // Wait 300ms after user stops typing
    distinctUntilChanged(),     // Only emit if value actually changed
    switchMap(email =>          // Cancel previous HTTP request
      this.userService.checkEmailAvailable(email)
    )
  )
  .subscribe(isAvailable => {
    if (!isAvailable) {
      this.registrationForm.get('email')!.setErrors({ emailTaken: true });
    }
  });

// Listen to the entire form changing
this.registrationForm.valueChanges.subscribe(formValue => {
  // Auto-save to localStorage
  localStorage.setItem('registration-draft', JSON.stringify(formValue));
});

// Listen to validation status changes
this.registrationForm.statusChanges.subscribe(status => {
  // status is 'VALID', 'INVALID', 'PENDING', or 'DISABLED'
  this.isFormValid = status === 'VALID';
});
```

**This is something template-driven forms simply cannot do.** The ability to treat form values as observable streams and compose them with RxJS operators is what makes reactive forms so powerful for complex scenarios.

---

## 7.4 Validation

### Built-in Validators

Angular provides these validators out of the box via the `Validators` class:

| Validator | What it checks | Template-Driven | Reactive |
|---|---|---|---|
| `required` | Field is not empty | `required` attribute | `Validators.required` |
| `requiredTrue` | Checkbox is checked | N/A (use custom) | `Validators.requiredTrue` |
| `minLength(n)` | Min character count | `minlength="n"` | `Validators.minLength(n)` |
| `maxLength(n)` | Max character count | `maxlength="n"` | `Validators.maxLength(n)` |
| `min(n)` | Min numeric value | `min="n"` | `Validators.min(n)` |
| `max(n)` | Max numeric value | `max="n"` | `Validators.max(n)` |
| `pattern(regex)` | Matches a regex | `pattern="regex"` | `Validators.pattern(regex)` |
| `email` | Valid email format | `email` attribute | `Validators.email` |

### Applying Validators in Template-Driven Forms

Validators are applied as HTML attributes in the template:

```html
<input
  type="text"
  ngModel
  name="username"
  required                      <!-- required validator -->
  minlength="3"                 <!-- minimum 3 characters -->
  maxlength="20"                <!-- maximum 20 characters -->
  pattern="^[a-zA-Z0-9_]+$"    <!-- only letters, numbers, underscore -->
  #usernameField="ngModel"
>
```

### Applying Validators in Reactive Forms

Validators are passed as the second argument to `FormControl`:

```typescript
import { Validators } from '@angular/forms';

// Single validator — pass directly
const name = new FormControl('', Validators.required);

// Multiple validators — pass as an array
const email = new FormControl('', [
  Validators.required,
  Validators.email,
  Validators.maxLength(100)
]);

// Validator with argument
const age = new FormControl('', [
  Validators.required,
  Validators.min(18),
  Validators.max(120)
]);

// Pattern validator with regex
const phone = new FormControl('', [
  Validators.required,
  Validators.pattern(/^\d{10}$/)  // Exactly 10 digits
]);
```

### Adding and Removing Validators Dynamically

With reactive forms, you can add or remove validators at runtime:

```typescript
const emailControl = this.form.get('email')!;

// Add validators
emailControl.setValidators([Validators.required, Validators.email]);

// Clear all validators
emailControl.clearValidators();

// IMPORTANT: After changing validators, you MUST call updateValueAndValidity()
// Otherwise the form won't re-evaluate with the new validators
emailControl.updateValueAndValidity();
```

**Real-world use case:** A form has a "shipping address" section that's optional. But if the user checks "Ship to different address", you dynamically add `Validators.required` to all address fields.

---

### Creating Custom Validators (Synchronous)

A custom validator is just a function. It takes a control and returns either `null` (valid) or an error object (invalid).

**Validator function signature:**

```typescript
(control: AbstractControl): ValidationErrors | null
```

**Example 1: No whitespace validator**

```typescript
// validators/no-whitespace.validator.ts

import { AbstractControl, ValidationErrors } from '@angular/forms';

// A validator is just a function!
// It receives the control (FormControl, FormGroup, or FormArray)
// It returns null if valid, or an error object if invalid
export function noWhitespaceValidator(control: AbstractControl): ValidationErrors | null {
  // If the value is empty, let 'required' handle that — don't double-validate
  if (!control.value) {
    return null;
  }

  // Check if the value is ONLY whitespace
  const isWhitespace = (control.value as string).trim().length === 0;

  // Return null = valid, return object = invalid
  // The object key ('whitespace') becomes the error name you check in the template
  return isWhitespace ? { whitespace: true } : null;
}
```

**Using it:**

```typescript
import { noWhitespaceValidator } from './validators/no-whitespace.validator';

const name = new FormControl('', [
  Validators.required,
  noWhitespaceValidator  // ← Used just like built-in validators
]);
```

```html
<div *ngIf="nameCtrl.hasError('whitespace')">
  Name cannot be only whitespace.
</div>
```

**Example 2: Forbidden name validator (parameterized)**

Sometimes you need a validator that takes a parameter. In that case, you create a **factory function** — a function that returns a validator function:

```typescript
// validators/forbidden-name.validator.ts

import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

// This is a FACTORY — it takes a parameter and RETURNS a validator function
export function forbiddenNameValidator(forbiddenName: RegExp): ValidatorFn {
  // The returned function is the actual validator
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) {
      return null;
    }

    const isForbidden = forbiddenName.test(control.value);
    // If forbidden, return an error object with details
    return isForbidden ? { forbiddenName: { value: control.value } } : null;
  };
}
```

**Using it:**

```typescript
const name = new FormControl('', [
  Validators.required,
  forbiddenNameValidator(/admin/i)  // Call the factory, pass the parameter
]);
```

```html
<div *ngIf="nameCtrl.hasError('forbiddenName')">
  "{{ nameCtrl.getError('forbiddenName').value }}" is not allowed as a name.
</div>
```

**Example 3: Using custom validators in Template-Driven Forms**

For template-driven forms, you need to wrap your validator in a directive:

```typescript
// validators/no-whitespace.directive.ts

import { Directive } from '@angular/core';
import { NG_VALIDATORS, Validator, AbstractControl, ValidationErrors } from '@angular/forms';

@Directive({
  selector: '[appNoWhitespace]',  // Used as an attribute in the template
  providers: [
    {
      provide: NG_VALIDATORS,       // Register with Angular's validator system
      useExisting: NoWhitespaceDirective,
      multi: true                   // Allow multiple validators on the same element
    }
  ]
})
export class NoWhitespaceDirective implements Validator {
  validate(control: AbstractControl): ValidationErrors | null {
    if (!control.value) return null;
    const isWhitespace = (control.value as string).trim().length === 0;
    return isWhitespace ? { whitespace: true } : null;
  }
}
```

```html
<!-- Using it in the template — just add the directive's selector as an attribute -->
<input
  ngModel
  name="username"
  required
  appNoWhitespace
  #usernameField="ngModel"
>

<div *ngIf="usernameField.hasError('whitespace')">
  Username cannot be only whitespace.
</div>
```

---

### Creating Custom Async Validators

Async validators are for validations that require a server call — like checking if a username or email already exists.

**Async validator function signature:**

```typescript
(control: AbstractControl): Observable<ValidationErrors | null> | Promise<ValidationErrors | null>
```

**Example: Check if username is taken**

```typescript
// validators/username-available.validator.ts

import { AbstractControl, ValidationErrors, AsyncValidatorFn } from '@angular/forms';
import { Observable, of } from 'rxjs';
import { map, catchError, delay, switchMap } from 'rxjs/operators';

// Simulated service call (replace with actual HTTP call)
function checkUsernameOnServer(username: string): Observable<boolean> {
  const takenUsernames = ['admin', 'root', 'superuser', 'test'];
  // Simulate network delay
  return of(!takenUsernames.includes(username.toLowerCase())).pipe(delay(1000));
}

// Factory function that returns an async validator
export function usernameAvailableValidator(): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    if (!control.value) {
      return of(null);  // Don't validate empty (let 'required' handle it)
    }

    return checkUsernameOnServer(control.value).pipe(
      map(isAvailable => {
        // null = valid (username is available)
        // { usernameTaken: true } = invalid (username already exists)
        return isAvailable ? null : { usernameTaken: true };
      }),
      catchError(() => of(null))  // If the server call fails, don't block the form
    );
  };
}
```

**Using it in a component:**

```typescript
import { usernameAvailableValidator } from './validators/username-available.validator';

// Async validators are the THIRD argument to FormControl
const username = new FormControl(
  '',                                           // Initial value
  [Validators.required, Validators.minLength(3)],  // Sync validators (2nd arg)
  [usernameAvailableValidator()]                    // Async validators (3rd arg)
);
```

**Handling async validation states in the template:**

```html
<div class="form-group">
  <label for="username">Username</label>
  <input type="text" id="username" formControlName="username">

  <!-- Show a loading spinner while async validation is running -->
  <div *ngIf="usernameCtrl.pending" class="info">
    Checking availability...
  </div>

  <div *ngIf="usernameCtrl.hasError('usernameTaken')" class="error">
    This username is already taken. Please choose another.
  </div>

  <div *ngIf="usernameCtrl.valid && usernameCtrl.dirty" class="success">
    Username is available!
  </div>
</div>
```

**Important notes about async validators:**
1. They run AFTER all sync validators pass. If sync validation fails, async validators are skipped (saves unnecessary server calls).
2. The control's status becomes `'PENDING'` while async validators are running.
3. Always handle errors in your async validators — a failed HTTP call shouldn't break the form.
4. Consider debouncing to avoid hammering the server on every keystroke (use `debounceTime` in the `valueChanges` approach, or set `updateOn: 'blur'`).

**Controlling when validation fires:**

```typescript
// Validate only on blur (when user leaves the field) — reduces server calls
const username = new FormControl('', {
  validators: [Validators.required],
  asyncValidators: [usernameAvailableValidator()],
  updateOn: 'blur'   // ← Only validate when the user tabs/clicks away
});
```

---

### Cross-Field Validation (Password Match Example)

Cross-field validators operate at the **FormGroup level**, not the FormControl level. They have access to all controls in the group.

```typescript
// validators/password-match.validator.ts

import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function passwordMatchValidator(): ValidatorFn {
  // This validator is applied to the FormGroup, not a single FormControl
  // So 'control' here is the FormGroup
  return (control: AbstractControl): ValidationErrors | null => {
    const password = control.get('password');
    const confirmPassword = control.get('confirmPassword');

    // Don't validate if either control is missing (shouldn't happen, but be safe)
    if (!password || !confirmPassword) {
      return null;
    }

    // Don't validate if either field is empty (let 'required' handle that)
    if (!password.value || !confirmPassword.value) {
      return null;
    }

    // Compare the values
    if (password.value !== confirmPassword.value) {
      // Set the error on the confirmPassword control (for field-level display)
      confirmPassword.setErrors({ passwordMismatch: true });
      // Also return the error at the group level
      return { passwordMismatch: true };
    }

    // If passwords match BUT confirmPassword had a mismatch error, clear it
    // (but preserve any other errors it might have)
    if (confirmPassword.hasError('passwordMismatch')) {
      confirmPassword.setErrors(null);
    }

    return null;
  };
}
```

**Applying the cross-field validator to the FormGroup:**

```typescript
import { passwordMatchValidator } from './validators/password-match.validator';

this.registrationForm = new FormGroup({
  name: new FormControl('', Validators.required),
  email: new FormControl('', [Validators.required, Validators.email]),
  password: new FormControl('', [Validators.required, Validators.minLength(8)]),
  confirmPassword: new FormControl('', Validators.required)
}, {
  validators: passwordMatchValidator()  // ← Applied to the GROUP, not a single control
});
```

**Displaying the error in the template:**

```html
<!-- Option 1: Check the group-level error -->
<div *ngIf="registrationForm.hasError('passwordMismatch')" class="error">
  Passwords do not match.
</div>

<!-- Option 2: Check the confirmPassword control error -->
<div *ngIf="confirmPasswordCtrl.hasError('passwordMismatch')" class="error">
  Passwords do not match.
</div>
```

---

## 7.5 Dynamic Forms with FormArray

`FormArray` is what you use when users need to add or remove form fields dynamically. Common real-world examples:

- Add multiple phone numbers
- Add multiple email addresses
- Skills/tags that users can add/remove
- Order items in a shopping cart
- Multiple addresses (home, work, etc.)

### Full Example: Dynamic Phone Numbers

**dynamic-form.component.ts:**

```typescript
import { Component, OnInit } from '@angular/core';
import { FormGroup, FormControl, FormArray, Validators } from '@angular/forms';

@Component({
  selector: 'app-dynamic-form',
  templateUrl: './dynamic-form.component.html',
  styleUrls: ['./dynamic-form.component.css']
})
export class DynamicFormComponent implements OnInit {
  contactForm!: FormGroup;

  ngOnInit(): void {
    this.contactForm = new FormGroup({
      name: new FormControl('', Validators.required),
      email: new FormControl('', [Validators.required, Validators.email]),

      // FormArray of simple FormControls (phone numbers)
      phones: new FormArray([
        // Start with one phone field by default
        new FormControl('', [Validators.required, Validators.pattern(/^\d{10}$/)])
      ]),

      // FormArray of FormGroups (addresses — each address has multiple fields)
      addresses: new FormArray([
        this.createAddressGroup()  // Start with one address
      ])
    });
  }

  // ===== PHONE NUMBERS (FormArray of FormControls) =====

  // Getter for easy access in the template
  get phones(): FormArray {
    return this.contactForm.get('phones') as FormArray;
  }

  addPhone(): void {
    // Push a new FormControl into the phones array
    this.phones.push(
      new FormControl('', [Validators.required, Validators.pattern(/^\d{10}$/)])
    );
  }

  removePhone(index: number): void {
    // Don't allow removing the last phone (must have at least one)
    if (this.phones.length > 1) {
      this.phones.removeAt(index);
    }
  }

  // ===== ADDRESSES (FormArray of FormGroups) =====

  // Getter for easy access in the template
  get addresses(): FormArray {
    return this.contactForm.get('addresses') as FormArray;
  }

  // Factory method to create an address FormGroup
  // This avoids code duplication — every new address has the same structure
  createAddressGroup(): FormGroup {
    return new FormGroup({
      type: new FormControl('home', Validators.required),  // 'home' or 'work'
      street: new FormControl('', Validators.required),
      city: new FormControl('', Validators.required),
      state: new FormControl('', Validators.required),
      zip: new FormControl('', [Validators.required, Validators.pattern(/^\d{5}$/)])
    });
  }

  addAddress(): void {
    this.addresses.push(this.createAddressGroup());
  }

  removeAddress(index: number): void {
    if (this.addresses.length > 1) {
      this.addresses.removeAt(index);
    }
  }

  onSubmit(): void {
    if (this.contactForm.valid) {
      console.log('Form Value:', this.contactForm.value);
      /*
      Output will look like:
      {
        name: "John Doe",
        email: "john@test.com",
        phones: ["1234567890", "0987654321"],
        addresses: [
          { type: "home", street: "123 Main St", city: "NYC", state: "NY", zip: "10001" },
          { type: "work", street: "456 Office Rd", city: "NYC", state: "NY", zip: "10002" }
        ]
      }
      */
    } else {
      this.contactForm.markAllAsTouched();
    }
  }
}
```

**dynamic-form.component.html:**

```html
<div class="form-container">
  <h2>Contact Information</h2>

  <form [formGroup]="contactForm" (ngSubmit)="onSubmit()">

    <!-- Name and Email -->
    <div class="form-group">
      <label>Name</label>
      <input type="text" formControlName="name" placeholder="Full name">
    </div>

    <div class="form-group">
      <label>Email</label>
      <input type="email" formControlName="email" placeholder="Email address">
    </div>

    <!-- ===== PHONE NUMBERS (FormArray of FormControls) ===== -->
    <div class="section">
      <h3>Phone Numbers</h3>

      <!--
        formArrayName="phones" — tells Angular this section maps to the 'phones' FormArray.
        Inside this div, we iterate over the controls with *ngFor.
      -->
      <div formArrayName="phones">
        <!--
          *ngFor iterates over the FormArray's controls.
          [formControlName]="i" — binds each input to the FormControl at index i.
          Note: formControlName here uses the INDEX as the name, not a string key.
        -->
        <div *ngFor="let phone of phones.controls; let i = index" class="dynamic-row">
          <input
            type="text"
            [formControlName]="i"
            [placeholder]="'Phone ' + (i + 1)"
          >
          <button
            type="button"
            (click)="removePhone(i)"
            [disabled]="phones.length === 1"
            class="remove-btn"
          >
            Remove
          </button>

          <!-- Validation for each phone -->
          <div *ngIf="phones.at(i).invalid && phones.at(i).touched" class="error">
            <small *ngIf="phones.at(i).hasError('required')">Phone is required.</small>
            <small *ngIf="phones.at(i).hasError('pattern')">Must be 10 digits.</small>
          </div>
        </div>
      </div>

      <button type="button" (click)="addPhone()" class="add-btn">
        + Add Phone Number
      </button>
    </div>

    <!-- ===== ADDRESSES (FormArray of FormGroups) ===== -->
    <div class="section">
      <h3>Addresses</h3>

      <div formArrayName="addresses">
        <!--
          Each address is a FormGroup inside the FormArray.
          [formGroupName]="i" — binds each iteration to the FormGroup at index i.
          Inside this div, we use formControlName for individual fields.
        -->
        <div
          *ngFor="let address of addresses.controls; let i = index"
          [formGroupName]="i"
          class="address-card"
        >
          <h4>
            Address {{ i + 1 }}
            <button
              type="button"
              (click)="removeAddress(i)"
              [disabled]="addresses.length === 1"
              class="remove-btn"
            >
              Remove
            </button>
          </h4>

          <div class="form-group">
            <label>Type</label>
            <select formControlName="type">
              <option value="home">Home</option>
              <option value="work">Work</option>
              <option value="other">Other</option>
            </select>
          </div>

          <div class="form-group">
            <label>Street</label>
            <input type="text" formControlName="street" placeholder="Street address">
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>City</label>
              <input type="text" formControlName="city" placeholder="City">
            </div>

            <div class="form-group">
              <label>State</label>
              <input type="text" formControlName="state" placeholder="State">
            </div>

            <div class="form-group">
              <label>ZIP</label>
              <input type="text" formControlName="zip" placeholder="ZIP code">
            </div>
          </div>
        </div>
      </div>

      <button type="button" (click)="addAddress()" class="add-btn">
        + Add Address
      </button>
    </div>

    <!-- Submit -->
    <button type="submit" [disabled]="contactForm.invalid" class="submit-btn">
      Save Contact
    </button>

    <!-- Debug -->
    <pre style="margin-top: 20px; background: #f5f5f5; padding: 10px; font-size: 12px;">
{{ contactForm.value | json }}
    </pre>
  </form>
</div>
```

### Key FormArray Concepts Summarized

```
FormArray of FormControls:
  formArrayName="phones"
    [formControlName]="i"          ← Use the index as the control name

FormArray of FormGroups:
  formArrayName="addresses"
    [formGroupName]="i"            ← Use the index as the group name
      formControlName="street"     ← Normal control names inside each group
      formControlName="city"
```

### Common FormArray Operations

```typescript
const arr = this.form.get('items') as FormArray;

arr.push(new FormControl('new'));     // Add at the end
arr.insert(0, new FormControl(''));   // Insert at specific index
arr.removeAt(2);                      // Remove at index
arr.clear();                          // Remove ALL controls
arr.at(0);                            // Get control at index
arr.length;                           // Number of controls
arr.controls;                         // Array of AbstractControl objects
arr.value;                            // Array of values: ['val1', 'val2', ...]
```

---

## 7.6 FormBuilder — Shortcut Syntax

### The Problem FormBuilder Solves

Writing `new FormGroup({ key: new FormControl('', [...]) })` over and over is verbose. `FormBuilder` is a service that provides shortcut methods to create `FormControl`, `FormGroup`, and `FormArray` with less typing.

**FormBuilder doesn't do anything different functionally.** It creates the exact same objects. It's purely syntactic sugar.

### Import and Inject FormBuilder

```typescript
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({ ... })
export class MyComponent {
  myForm!: FormGroup;

  // Inject FormBuilder via constructor
  constructor(private fb: FormBuilder) { }

  ngOnInit(): void {
    // Use this.fb instead of new FormGroup / new FormControl
  }
}
```

### Side-by-Side Comparison

**Without FormBuilder (verbose):**

```typescript
import { FormGroup, FormControl, FormArray, Validators } from '@angular/forms';

this.profileForm = new FormGroup({
  name: new FormControl('', [Validators.required, Validators.minLength(3)]),
  email: new FormControl('', [Validators.required, Validators.email]),
  age: new FormControl(null, [Validators.required, Validators.min(18)]),
  address: new FormGroup({
    street: new FormControl('', Validators.required),
    city: new FormControl('', Validators.required),
    state: new FormControl(''),
    zip: new FormControl('', [Validators.required, Validators.pattern(/^\d{5}$/)])
  }),
  hobbies: new FormArray([
    new FormControl('Reading'),
    new FormControl('Coding')
  ])
});
```

**With FormBuilder (concise):**

```typescript
import { FormBuilder, Validators } from '@angular/forms';

// Inject FormBuilder in the constructor
constructor(private fb: FormBuilder) { }

ngOnInit(): void {
  this.profileForm = this.fb.group({
    // Each control: ['initialValue', [validators]]
    // If no validators needed, just pass the value directly
    name: ['', [Validators.required, Validators.minLength(3)]],
    email: ['', [Validators.required, Validators.email]],
    age: [null, [Validators.required, Validators.min(18)]],

    // Nested group — use this.fb.group() again
    address: this.fb.group({
      street: ['', Validators.required],
      city: ['', Validators.required],
      state: [''],
      zip: ['', [Validators.required, Validators.pattern(/^\d{5}$/)]]
    }),

    // FormArray — use this.fb.array()
    hobbies: this.fb.array([
      ['Reading'],    // Each element is a shorthand for FormControl
      ['Coding']
    ])
  });
}
```

### FormBuilder Shorthand Cheat Sheet

```typescript
// Creating a FormControl
new FormControl('initial', Validators.required)
// becomes:
this.fb.control('initial', Validators.required)
// or inside fb.group(), just use the array syntax:
name: ['initial', Validators.required]

// Creating a FormGroup
new FormGroup({ name: new FormControl('') })
// becomes:
this.fb.group({ name: [''] })

// Creating a FormArray
new FormArray([new FormControl(''), new FormControl('')])
// becomes:
this.fb.array(['', ''])

// With validators on the FormGroup itself (e.g., cross-field validation)
this.fb.group({
  password: ['', Validators.required],
  confirmPassword: ['', Validators.required]
}, {
  validators: passwordMatchValidator()  // Group-level validator
});
```

**When to use FormBuilder vs manual construction?**

Always use FormBuilder. There is no scenario where the manual `new FormGroup(new FormControl(...))` approach is better. FormBuilder is shorter, cleaner, and produces the exact same result. The only reason to know the manual approach is to understand what FormBuilder is doing under the hood.

---

## 7.7 Practical Example: Complete Contact Form

This example combines everything from this phase into a single, production-quality form: FormBuilder, multiple validators, custom validators, async validators, FormArray, cross-field validation, and proper error display.

### The Custom Validators

**validators/form-validators.ts:**

```typescript
import { AbstractControl, ValidationErrors, ValidatorFn, AsyncValidatorFn } from '@angular/forms';
import { Observable, of } from 'rxjs';
import { delay, map } from 'rxjs/operators';

// ====== SYNC VALIDATORS ======

/**
 * Validates that a string does not consist entirely of whitespace.
 *
 * WHY: Validators.required allows "   " (all spaces) to pass.
 * This validator catches that edge case.
 */
export function noWhitespaceValidator(control: AbstractControl): ValidationErrors | null {
  if (!control.value) return null;
  const isWhitespace = (control.value as string).trim().length === 0;
  return isWhitespace ? { whitespace: { message: 'Value cannot be only whitespace' } } : null;
}

/**
 * Cross-field validator: ensures two fields have matching values.
 * Applied at the FormGroup level.
 *
 * @param field1 - The name of the first control (e.g., 'password')
 * @param field2 - The name of the second control (e.g., 'confirmPassword')
 */
export function fieldMatchValidator(field1: string, field2: string): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    const control1 = group.get(field1);
    const control2 = group.get(field2);

    if (!control1 || !control2) return null;
    if (!control1.value || !control2.value) return null;

    if (control1.value !== control2.value) {
      // Set error on the second field for per-field error display
      control2.setErrors({ ...control2.errors, fieldMismatch: true });
      return { fieldMismatch: { field1, field2 } };
    }

    // Clear the mismatch error from the second field (but keep other errors)
    if (control2.errors?.['fieldMismatch']) {
      const errors = { ...control2.errors };
      delete errors['fieldMismatch'];
      control2.setErrors(Object.keys(errors).length ? errors : null);
    }

    return null;
  };
}

/**
 * Validates that a value does not contain a forbidden word.
 * Factory function — takes a parameter.
 */
export function forbiddenWordValidator(forbidden: string): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;
    const hasForbidden = control.value.toLowerCase().includes(forbidden.toLowerCase());
    return hasForbidden ? { forbiddenWord: { word: forbidden } } : null;
  };
}

// ====== ASYNC VALIDATORS ======

/**
 * Simulates checking if an email is already registered.
 * In production, this would call an HTTP endpoint.
 */
export function emailExistsValidator(): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    if (!control.value) return of(null);

    // Simulate server call with a delay
    const registeredEmails = [
      'admin@example.com',
      'test@example.com',
      'user@example.com'
    ];

    return of(control.value).pipe(
      delay(800),  // Simulate network latency
      map(email => {
        const exists = registeredEmails.includes(email.toLowerCase());
        return exists ? { emailExists: { email } } : null;
      })
    );
  };
}
```

### The Component

**contact-form.component.ts:**

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, Validators, FormControl } from '@angular/forms';
import { Subscription } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import {
  noWhitespaceValidator,
  fieldMatchValidator,
  forbiddenWordValidator,
  emailExistsValidator
} from './validators/form-validators';

@Component({
  selector: 'app-contact-form',
  templateUrl: './contact-form.component.html',
  styleUrls: ['./contact-form.component.css']
})
export class ContactFormComponent implements OnInit, OnDestroy {
  contactForm!: FormGroup;
  formSubmitted = false;
  submittedData: any = null;
  private subscriptions: Subscription[] = [];

  // Inject FormBuilder
  constructor(private fb: FormBuilder) { }

  ngOnInit(): void {
    this.buildForm();
    this.setupReactiveListeners();
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  /**
   * Build the entire form using FormBuilder.
   * This is the single source of truth for the form structure.
   */
  private buildForm(): void {
    this.contactForm = this.fb.group({
      // ---- Personal Info ----
      firstName: ['', [
        Validators.required,
        Validators.minLength(2),
        Validators.maxLength(50),
        noWhitespaceValidator,
        forbiddenWordValidator('admin')
      ]],
      lastName: ['', [
        Validators.required,
        Validators.minLength(2),
        noWhitespaceValidator
      ]],

      // ---- Account Info ----
      // Email has an async validator (3rd argument in the array)
      email: ['', {
        validators: [Validators.required, Validators.email],
        asyncValidators: [emailExistsValidator()],
        updateOn: 'blur'  // Only validate on blur to avoid hammering the "server"
      }],
      password: ['', [
        Validators.required,
        Validators.minLength(8),
        Validators.pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).+$/)
      ]],
      confirmPassword: ['', Validators.required],

      // ---- Contact Info ----
      // FormArray of phone numbers (simple FormControls)
      phones: this.fb.array([
        this.createPhoneControl()
      ]),

      // ---- Addresses ----
      // FormArray of address FormGroups
      addresses: this.fb.array([
        this.createAddressGroup()
      ]),

      // ---- Preferences ----
      newsletter: [false],
      preferredContact: ['email', Validators.required],
      comments: ['', Validators.maxLength(500)]
    }, {
      // Group-level validator for cross-field validation
      validators: fieldMatchValidator('password', 'confirmPassword')
    });
  }

  /**
   * Set up reactive listeners to respond to value changes.
   */
  private setupReactiveListeners(): void {
    // Auto-save draft to localStorage with debounce
    const formSub = this.contactForm.valueChanges.pipe(
      debounceTime(500),         // Wait 500ms after user stops typing
      distinctUntilChanged()     // Only emit if values actually changed
    ).subscribe(value => {
      localStorage.setItem('contact-form-draft', JSON.stringify(value));
      console.log('Draft auto-saved');
    });
    this.subscriptions.push(formSub);

    // When preferredContact changes, make corresponding fields required
    const prefSub = this.contactForm.get('preferredContact')!.valueChanges
      .subscribe(preference => {
        this.updateContactValidation(preference);
      });
    this.subscriptions.push(prefSub);
  }

  /**
   * Dynamically update validation based on preferred contact method.
   * If user prefers phone contact, phone becomes required.
   * This shows the power of reactive forms — dynamic validator management.
   */
  private updateContactValidation(preference: string): void {
    const phonesArray = this.phones;
    if (preference === 'phone' && phonesArray.length > 0) {
      // First phone is required when phone is preferred contact
      phonesArray.at(0).setValidators([
        Validators.required,
        Validators.pattern(/^\d{10}$/)
      ]);
    } else if (phonesArray.length > 0) {
      phonesArray.at(0).setValidators([Validators.pattern(/^\d{10}$/)]);
    }
    if (phonesArray.length > 0) {
      phonesArray.at(0).updateValueAndValidity();
    }
  }

  // ===== FACTORY METHODS for FormArray items =====

  createPhoneControl(): FormControl {
    return this.fb.control('', Validators.pattern(/^\d{10}$/)) as FormControl;
  }

  createAddressGroup(): FormGroup {
    return this.fb.group({
      label: ['Home', Validators.required],
      street: ['', Validators.required],
      city: ['', Validators.required],
      state: ['', Validators.required],
      zip: ['', [Validators.required, Validators.pattern(/^\d{5}(-\d{4})?$/)]]
    });
  }

  // ===== GETTERS for template convenience =====

  get firstName() { return this.contactForm.get('firstName') as FormControl; }
  get lastName() { return this.contactForm.get('lastName') as FormControl; }
  get email() { return this.contactForm.get('email') as FormControl; }
  get password() { return this.contactForm.get('password') as FormControl; }
  get confirmPassword() { return this.contactForm.get('confirmPassword') as FormControl; }
  get phones() { return this.contactForm.get('phones') as FormArray; }
  get addresses() { return this.contactForm.get('addresses') as FormArray; }
  get comments() { return this.contactForm.get('comments') as FormControl; }

  // ===== FORM ARRAY ACTIONS =====

  addPhone(): void {
    this.phones.push(this.createPhoneControl());
  }

  removePhone(index: number): void {
    if (this.phones.length > 1) {
      this.phones.removeAt(index);
    }
  }

  addAddress(): void {
    this.addresses.push(this.createAddressGroup());
  }

  removeAddress(index: number): void {
    if (this.addresses.length > 1) {
      this.addresses.removeAt(index);
    }
  }

  // ===== FORM ACTIONS =====

  onSubmit(): void {
    if (this.contactForm.valid) {
      this.formSubmitted = true;
      this.submittedData = this.contactForm.value;
      console.log('Submitting:', this.submittedData);

      // Clear draft from localStorage
      localStorage.removeItem('contact-form-draft');

      // In a real app:
      // this.contactService.saveContact(this.contactForm.value).subscribe(...)
    } else {
      // Mark all controls as touched to trigger all validation messages
      this.contactForm.markAllAsTouched();
      console.log('Form is invalid. Errors:', this.getFormErrors());
    }
  }

  resetForm(): void {
    this.contactForm.reset({
      preferredContact: 'email',
      newsletter: false
    });
    this.formSubmitted = false;
    this.submittedData = null;

    // Reset FormArrays to one item each
    while (this.phones.length > 1) {
      this.phones.removeAt(1);
    }
    while (this.addresses.length > 1) {
      this.addresses.removeAt(1);
    }
  }

  loadDraft(): void {
    const draft = localStorage.getItem('contact-form-draft');
    if (draft) {
      const draftData = JSON.parse(draft);
      // Use patchValue because the draft might not have all fields
      // (e.g., if FormArrays had different lengths)
      this.contactForm.patchValue(draftData);
      console.log('Draft loaded');
    }
  }

  /**
   * Helper: Collect all form errors (useful for debugging and logging).
   */
  private getFormErrors(): any {
    const errors: any = {};
    Object.keys(this.contactForm.controls).forEach(key => {
      const control = this.contactForm.get(key);
      if (control?.errors) {
        errors[key] = control.errors;
      }
    });
    return errors;
  }
}
```

### The Template

**contact-form.component.html:**

```html
<div class="form-container">
  <h2>Contact Form</h2>
  <p class="subtitle">Complete all required fields to submit.</p>

  <form [formGroup]="contactForm" (ngSubmit)="onSubmit()">

    <!-- ========== PERSONAL INFO SECTION ========== -->
    <fieldset>
      <legend>Personal Information</legend>

      <!-- First Name -->
      <div class="form-group">
        <label for="firstName">First Name *</label>
        <input
          type="text"
          id="firstName"
          formControlName="firstName"
          placeholder="Enter first name"
          [class.is-invalid]="firstName.invalid && (firstName.dirty || firstName.touched)"
          [class.is-valid]="firstName.valid && firstName.dirty"
        >
        <div class="error-messages" *ngIf="firstName.invalid && (firstName.dirty || firstName.touched)">
          <small *ngIf="firstName.hasError('required')">First name is required.</small>
          <small *ngIf="firstName.hasError('minlength')">
            Minimum {{ firstName.getError('minlength').requiredLength }} characters required.
          </small>
          <small *ngIf="firstName.hasError('maxlength')">
            Maximum {{ firstName.getError('maxlength').requiredLength }} characters allowed.
          </small>
          <small *ngIf="firstName.hasError('whitespace')">Cannot be only whitespace.</small>
          <small *ngIf="firstName.hasError('forbiddenWord')">
            Cannot contain "{{ firstName.getError('forbiddenWord').word }}".
          </small>
        </div>
      </div>

      <!-- Last Name -->
      <div class="form-group">
        <label for="lastName">Last Name *</label>
        <input
          type="text"
          id="lastName"
          formControlName="lastName"
          placeholder="Enter last name"
          [class.is-invalid]="lastName.invalid && (lastName.dirty || lastName.touched)"
          [class.is-valid]="lastName.valid && lastName.dirty"
        >
        <div class="error-messages" *ngIf="lastName.invalid && (lastName.dirty || lastName.touched)">
          <small *ngIf="lastName.hasError('required')">Last name is required.</small>
          <small *ngIf="lastName.hasError('minlength')">
            Minimum {{ lastName.getError('minlength').requiredLength }} characters required.
          </small>
          <small *ngIf="lastName.hasError('whitespace')">Cannot be only whitespace.</small>
        </div>
      </div>
    </fieldset>

    <!-- ========== ACCOUNT INFO SECTION ========== -->
    <fieldset>
      <legend>Account Information</legend>

      <!-- Email (with async validation) -->
      <div class="form-group">
        <label for="email">Email *</label>
        <input
          type="email"
          id="email"
          formControlName="email"
          placeholder="you@example.com"
          [class.is-invalid]="email.invalid && (email.dirty || email.touched)"
          [class.is-valid]="email.valid && email.dirty"
        >
        <!-- Show spinner during async validation -->
        <small class="info" *ngIf="email.pending">Checking availability...</small>
        <div class="error-messages" *ngIf="email.invalid && (email.dirty || email.touched)">
          <small *ngIf="email.hasError('required')">Email is required.</small>
          <small *ngIf="email.hasError('email')">Please enter a valid email.</small>
          <small *ngIf="email.hasError('emailExists')">
            This email ({{ email.getError('emailExists').email }}) is already registered.
          </small>
        </div>
        <small class="success" *ngIf="email.valid && email.dirty">
          Email is available.
        </small>
      </div>

      <!-- Password -->
      <div class="form-group">
        <label for="password">Password *</label>
        <input
          type="password"
          id="password"
          formControlName="password"
          placeholder="Strong password"
          [class.is-invalid]="password.invalid && (password.dirty || password.touched)"
        >
        <div class="error-messages" *ngIf="password.invalid && (password.dirty || password.touched)">
          <small *ngIf="password.hasError('required')">Password is required.</small>
          <small *ngIf="password.hasError('minlength')">Must be at least 8 characters.</small>
          <small *ngIf="password.hasError('pattern')">
            Must include uppercase, lowercase, number, and special character (@$!%*?&).
          </small>
        </div>
      </div>

      <!-- Confirm Password -->
      <div class="form-group">
        <label for="confirmPassword">Confirm Password *</label>
        <input
          type="password"
          id="confirmPassword"
          formControlName="confirmPassword"
          placeholder="Re-enter password"
          [class.is-invalid]="confirmPassword.invalid && (confirmPassword.dirty || confirmPassword.touched)"
        >
        <div class="error-messages"
             *ngIf="confirmPassword.invalid && (confirmPassword.dirty || confirmPassword.touched)">
          <small *ngIf="confirmPassword.hasError('required')">Please confirm your password.</small>
          <small *ngIf="confirmPassword.hasError('fieldMismatch')">Passwords do not match.</small>
        </div>
      </div>
    </fieldset>

    <!-- ========== PHONE NUMBERS (FormArray) ========== -->
    <fieldset>
      <legend>Phone Numbers</legend>

      <div formArrayName="phones">
        <div *ngFor="let phone of phones.controls; let i = index" class="dynamic-row">
          <div class="input-with-button">
            <input
              type="tel"
              [formControlName]="i"
              [placeholder]="'Phone ' + (i + 1) + ' (10 digits)'"
              [class.is-invalid]="phone.invalid && phone.touched"
            >
            <button
              type="button"
              class="remove-btn"
              (click)="removePhone(i)"
              [disabled]="phones.length <= 1"
              title="Remove this phone"
            >
              X
            </button>
          </div>
          <div class="error-messages" *ngIf="phone.invalid && phone.touched">
            <small *ngIf="phone.hasError('required')">Phone number is required.</small>
            <small *ngIf="phone.hasError('pattern')">Must be exactly 10 digits.</small>
          </div>
        </div>
      </div>

      <button type="button" class="add-btn" (click)="addPhone()">
        + Add Another Phone
      </button>
    </fieldset>

    <!-- ========== ADDRESSES (FormArray of FormGroups) ========== -->
    <fieldset>
      <legend>Addresses</legend>

      <div formArrayName="addresses">
        <div
          *ngFor="let addr of addresses.controls; let i = index"
          [formGroupName]="i"
          class="address-card"
        >
          <div class="address-header">
            <h4>Address {{ i + 1 }}</h4>
            <button
              type="button"
              class="remove-btn"
              (click)="removeAddress(i)"
              [disabled]="addresses.length <= 1"
            >
              Remove
            </button>
          </div>

          <div class="form-group">
            <label>Label</label>
            <select formControlName="label">
              <option value="Home">Home</option>
              <option value="Work">Work</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div class="form-group">
            <label>Street *</label>
            <input type="text" formControlName="street" placeholder="123 Main St">
          </div>

          <div class="form-row">
            <div class="form-group flex-grow">
              <label>City *</label>
              <input type="text" formControlName="city" placeholder="City">
            </div>
            <div class="form-group">
              <label>State *</label>
              <input type="text" formControlName="state" placeholder="ST" maxlength="2">
            </div>
            <div class="form-group">
              <label>ZIP *</label>
              <input type="text" formControlName="zip" placeholder="12345">
            </div>
          </div>
        </div>
      </div>

      <button type="button" class="add-btn" (click)="addAddress()">
        + Add Another Address
      </button>
    </fieldset>

    <!-- ========== PREFERENCES ========== -->
    <fieldset>
      <legend>Preferences</legend>

      <div class="form-group">
        <label>Preferred Contact Method *</label>
        <div class="radio-group">
          <label>
            <input type="radio" formControlName="preferredContact" value="email"> Email
          </label>
          <label>
            <input type="radio" formControlName="preferredContact" value="phone"> Phone
          </label>
        </div>
      </div>

      <div class="form-group">
        <label>
          <input type="checkbox" formControlName="newsletter">
          Subscribe to newsletter
        </label>
      </div>

      <div class="form-group">
        <label for="comments">Comments (optional)</label>
        <textarea
          id="comments"
          formControlName="comments"
          rows="4"
          placeholder="Any additional information..."
          maxlength="500"
        ></textarea>
        <small class="char-count">
          {{ comments.value?.length || 0 }} / 500 characters
        </small>
      </div>
    </fieldset>

    <!-- ========== FORM ACTIONS ========== -->
    <div class="form-actions">
      <button type="submit" class="submit-btn" [disabled]="contactForm.invalid">
        Submit
      </button>
      <button type="button" class="reset-btn" (click)="resetForm()">
        Reset
      </button>
      <button type="button" class="draft-btn" (click)="loadDraft()">
        Load Draft
      </button>
    </div>

    <!-- ========== FORM STATUS ========== -->
    <div class="form-status">
      <span [class.valid]="contactForm.valid" [class.invalid]="contactForm.invalid">
        Form Status: {{ contactForm.status }}
      </span>
    </div>

    <!-- ========== SUCCESS MESSAGE ========== -->
    <div *ngIf="formSubmitted" class="success-message">
      <h3>Form Submitted Successfully!</h3>
      <pre>{{ submittedData | json }}</pre>
    </div>

  </form>
</div>
```

---

## 7.8 Template-Driven vs Reactive — Summary Table

| Feature | Template-Driven | Reactive |
|---|---|---|
| **Module import** | `FormsModule` | `ReactiveFormsModule` |
| **Form model defined in** | Template (HTML) | Component class (TypeScript) |
| **Model creation** | Implicit (Angular creates via directives) | Explicit (`new FormGroup(...)` or `fb.group(...)`) |
| **Key directives** | `ngModel`, `ngForm`, `ngModelGroup` | `formControlName`, `formGroup`, `formArrayName` |
| **Data binding** | Two-way `[(ngModel)]` | One-way `[formGroup]` + observables |
| **Validation defined in** | Template (HTML attributes) | Component class (`Validators.*`) |
| **Custom validators** | Requires a directive wrapper | Just a function |
| **Async validators** | Possible but awkward | Natural (returns Observable) |
| **Dynamic fields** | Very difficult | Easy (`FormArray.push/removeAt`) |
| **Cross-field validation** | Manual comparison in template | Group-level validator function |
| **Testing** | Requires TestBed + DOM | Pure TypeScript unit tests possible |
| **Value change tracking** | `(ngModelChange)` event | `valueChanges` Observable (supports RxJS operators) |
| **Status change tracking** | Limited | `statusChanges` Observable |
| **Programmatic control** | Limited | Full (`setValue`, `patchValue`, `reset`, `disable`, etc.) |
| **Code structure** | Logic spread across template + component | Logic centralized in component class |
| **Scalability** | Poor for complex forms | Excellent for complex forms |
| **Learning curve** | Lower (familiar HTML-like syntax) | Higher (requires RxJS understanding) |
| **Best suited for** | Simple forms, prototyping | Enterprise apps, complex workflows |
| **Industry preference** | Rarely used in production | Standard in production apps |

### Quick Decision Flowchart

```
Is your form simple (< 5 fields, basic validation)?
├── YES → Template-Driven is fine
└── NO → Use Reactive Forms
         │
         Do you need dynamic fields (add/remove)?
         ├── YES → Definitely Reactive (FormArray)
         └── NO → Reactive is still recommended
                  │
                  Do you need cross-field validation?
                  ├── YES → Reactive (group-level validators)
                  └── NO → Reactive is still easier to test and maintain
```

### Key Takeaways

1. **Both approaches create the same underlying objects** (`FormControl`, `FormGroup`, `FormArray`). The difference is just where and how you define them.

2. **Template-driven forms** are great for learning Angular forms because the syntax is HTML-centric and intuitive. But they become unmanageable as forms grow in complexity.

3. **Reactive forms** require more upfront code but pay off enormously in testability, maintainability, and power. The ability to use RxJS operators on `valueChanges` alone justifies using reactive forms.

4. **FormBuilder** is not a third approach — it's syntactic sugar for creating reactive form objects with less typing. Always use it.

5. **Custom validators** are just functions. Sync validators return `null` or an error object. Async validators return an `Observable` or `Promise` of the same. This simplicity means you can test validators in isolation.

6. **Cross-field validation** (like password matching) is a group-level concern. Apply the validator to the `FormGroup`, not individual `FormControl`s.

7. **FormArray** unlocks dynamic forms — the ability to add and remove fields at runtime. This is one of the biggest advantages of reactive forms over template-driven.

8. **Always unsubscribe** from `valueChanges` and `statusChanges` in `ngOnDestroy()` to prevent memory leaks.

---

**Next:** [Phase 8 — HTTP & API Communication](./Phase08-HTTP-API-Communication.md)
