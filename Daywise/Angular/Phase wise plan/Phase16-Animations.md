# Phase 16: Animations

> Motion is not decoration — it is communication. A well-animated UI guides the user's eye, confirms actions, reveals relationships, and makes your application feel alive and trustworthy. Master Angular animations and you elevate your apps from functional to exceptional.

---

## 16.1 Why Animations Matter in Angular Apps

### The Problem: Static UIs Feel Broken

Think about the last time you clicked a button and nothing visually confirmed it happened. Did you wonder "did it work?" Or imagine a list item vanishing instantly with no visual cue — was it deleted? Reordered? Did something crash?

**Static UIs cause anxiety. Animations solve this.**

```
WITHOUT animations:                 WITH animations:
┌─────────────────────┐            ┌─────────────────────┐
│  [Click Save]       │            │  [Click Save]       │
│                     │            │                     │
│  (nothing visible   │    vs.     │  ✓ Button pulses    │
│   happened...)      │            │  ✓ Form slides out  │
│                     │            │  ✓ Success appears  │
│  User: "Did it      │            │                     │
│   work?? 🤔"        │            │  User: "Got it! 😊" │
└─────────────────────┘            └─────────────────────┘
```

### Real-World Analogy: Animations are Punctuation

Imagine reading a book with no punctuation no spaces no paragraphs it would be exhausting to understand where one idea ends and another begins that is what a UI without animations feels like.

**Animation is punctuation for your UI:**
- A fade-in = a paragraph break (new section, fresh start)
- A slide transition = a comma (continuation, connected ideas)
- A bounce = an exclamation mark (attention! important!)
- A dissolve = a period (this is done, complete)

---

### UX Impact: The Three Pillars of Animation Value

**1. Perceived Performance** — Animations make apps *feel* faster even when they aren't

```
Reality: API takes 800ms to load data
Without animation: User stares at blank screen for 800ms → feels slow
With animation:    Skeleton/spinner runs → 800ms disappears → feels fast
```

**2. User Guidance** — Animations direct attention and explain spatial relationships

```
WITHOUT guidance:                   WITH guidance:
Menu appears from nowhere           Menu slides in from LEFT
  → User confused: where did        → User understands: menu
    this come from?                   lives to the left
                                    → Mental model formed ✓
```

**3. Delight** — Micro-animations create emotional connection

```
Form submission without animation:  "Data sent."
Form submission WITH animation:     Checkmark draws itself ✓ → "Well done!"
                                    The second one makes users SMILE.
```

---

### Angular Animations vs. CSS Animations vs. JavaScript Animations

| Factor | Angular Animations | CSS Animations | JavaScript (GSAP etc.) |
|---|---|---|---|
| **Integration** | Deep Angular integration | Manual class toggling | Fully manual |
| **State-driven** | Yes — driven by component state | No — class-based | Manual |
| **Data-driven** | Yes — animate based on data | No | Yes |
| **Testability** | Built-in Angular test support | Hard to test | Hard to test |
| **Performance** | Good (uses Web Animations API) | Best | Depends |
| **Learning curve** | Medium | Low | High |
| **Dynamic values** | Yes (parameterized) | Limited (CSS variables) | Yes |
| **Sequencing** | Built-in (sequence/group) | Complex (animation-delay) | Best |
| **Staggering** | Built-in (stagger) | Very complex | Easy with libraries |

### Decision Guide: Which Animation Tool to Use?

```
START HERE
    │
    ▼
Is the animation tied to Angular component STATE or DATA?
    │
    ├── YES → Use Angular Animations
    │             (open/close, show/hide, route changes, list enter/leave)
    │
    └── NO → Is it a simple, always-running decorative animation?
                │
                ├── YES → Use CSS Animations / Transitions
                │             (spinning loader, hover effects, pulse effects)
                │
                └── NO → Do you need complex sequencing, physics, or
                           scroll-based control?
                              │
                              ├── YES → Use JavaScript (GSAP, Framer Motion)
                              │
                              └── NO → CSS Transitions are probably fine
```

---

## 16.2 Setting Up Angular Animations

### The Problem: Animations Don't Work Out of the Box

Angular keeps animations in a separate package to reduce bundle size if you don't need them. You must opt in.

### Step 1: The Package (Already Installed)

`@angular/animations` comes bundled with Angular — no extra install needed:

```bash
# This is ALREADY in your package.json when you create an Angular project
# You do NOT need to run this separately:
# npm install @angular/animations  ← Already there!
```

### Step 2a: NgModule Approach — BrowserAnimationsModule

```typescript
// app.module.ts (traditional NgModule approach)
import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations'; // ← Import this

import { AppComponent } from './app.component';

@NgModule({
  declarations: [AppComponent],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,  // ← Add to imports array (NOT BrowserModule again!)
    // BrowserModule + BrowserAnimationsModule = full animation support
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

### Step 2b: Standalone Approach — provideAnimations()

```typescript
// main.ts (modern standalone / bootstrapApplication approach)
import { bootstrapApplication } from '@angular/platform-browser';
import { provideAnimations } from '@angular/platform-browser/animations'; // ← Import
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, {
  providers: [
    provideAnimations(), // ← Add as a provider — animations are now available app-wide
    // This is equivalent to importing BrowserAnimationsModule in NgModule
  ]
});
```

### Step 2c: provideAnimationsAsync() — Lazy Loading Animations

```typescript
// main.ts — for apps where animations are NOT needed on first paint
import { bootstrapApplication } from '@angular/platform-browser';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async'; // ← Note: /async

import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, {
  providers: [
    provideAnimationsAsync(), // ← Animations loaded lazily — better initial bundle size
    // Angular CLI recommends this for new projects (Angular 17+)
    // Animations code is only loaded when first needed
  ]
});
```

### Step 2d: NoopAnimationsModule — For Testing

```typescript
// In your test files or test setup
import { TestBed } from '@angular/core/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations'; // ← Noop version

// In tests, animations are a distraction — they add timing issues
// NoopAnimationsModule replaces all animations with instant no-ops
TestBed.configureTestingModule({
  imports: [
    NoopAnimationsModule, // ← Animations "work" but complete instantly (0ms)
    // This prevents flakey tests caused by animation timing
  ],
  declarations: [MyAnimatedComponent]
});
```

### Comparison: Animation Setup Methods

| Method | Use When | Bundle Impact |
|---|---|---|
| `BrowserAnimationsModule` | NgModule app | Included in main bundle |
| `provideAnimations()` | Standalone app, animations used immediately | Included in main bundle |
| `provideAnimationsAsync()` | Standalone app, animations not on first screen | Lazy loaded (better perf) |
| `NoopAnimationsModule` | Unit tests | None (replaces with no-ops) |

---

## 16.3 Animation Building Blocks

### The Mental Model: A State Machine

Angular animations are fundamentally a **state machine**. Your element can be in one of several named states, and you define what happens when it transitions between states.

```
ANIMATION STATE MACHINE:

       trigger('openClose')
      ┌─────────────────────────────────────────────────┐
      │                                                 │
      │   state('open')          state('closed')        │
      │   ┌─────────────┐        ┌─────────────┐        │
      │   │ height:200px│  ←───→ │ height: 0   │        │
      │   │ opacity: 1  │        │ opacity: 0  │        │
      │   └─────────────┘        └─────────────┘        │
      │          │  transition('open => closed')  │      │
      │          │  animate('300ms ease-in')       │      │
      │          └─────────────────────────────────┘      │
      │                                                 │
      └─────────────────────────────────────────────────┘
```

### The 5 Core Functions

```
trigger()
  │
  ├── state('open',   style({ height: '200px' }))
  ├── state('closed', style({ height: '0' }))
  │
  ├── transition('open => closed',  animate('300ms ease-in'))
  └── transition('closed => open',  animate('300ms ease-out'))

Each function's role:
┌─────────────────┬──────────────────────────────────────────────┐
│ Function        │ Purpose                                      │
├─────────────────┼──────────────────────────────────────────────┤
│ trigger()       │ Names the animation, attaches to HTML element │
│ state()         │ Defines a named "resting state" with styles   │
│ style()         │ CSS properties as a JavaScript object         │
│ transition()    │ Defines what triggers animation between states │
│ animate()       │ Duration, delay, and easing of the animation  │
└─────────────────┴──────────────────────────────────────────────┘
```

### Importing the Building Blocks

```typescript
// component.ts — import what you need from @angular/animations
import {
  trigger,      // ← Names the animation and hosts states/transitions
  state,        // ← Defines a named state's CSS styles
  style,        // ← Wraps CSS properties as a JS object
  transition,   // ← Defines when/which transitions fire
  animate,      // ← The actual animation timing and easing
  keyframes,    // ← For multi-step animations (covered in 16.9)
  group,        // ← Run multiple animations in parallel (16.10)
  sequence,     // ← Run animations one after another (16.10)
  query,        // ← Select child elements to animate (16.11)
  stagger,      // ← Delay child animations sequentially (16.11)
  animation,    // ← Create reusable animation definitions (16.13)
  useAnimation, // ← Reference a reusable animation (16.13)
  AnimationEvent // ← Type for animation callback events (16.15)
} from '@angular/animations';
```

---

## 16.4 Your First Animation — State-Based

### The Scenario: A Collapsible Panel

We want a panel that smoothly opens and closes when a button is clicked. Without animation: it jumps. With animation: it glides.

```
BEFORE (instant):          AFTER (animated):

[Toggle] → Panel gone      [Toggle] → Panel slowly collapses
                                       height: 200px → 0px
                                       opacity: 1 → 0
                                       (300ms smooth)
```

### Step 1: Define the Animation in the Component

```typescript
// collapsible-panel.component.ts
import { Component } from '@angular/core';
import {
  trigger,      // ← Wraps the whole animation definition
  state,        // ← Each named "rest position"
  style,        // ← CSS for that rest position
  transition,   // ← Rule: "when going from A to B, do this"
  animate       // ← How long and how (timing)
} from '@angular/animations';

@Component({
  selector: 'app-collapsible-panel',
  templateUrl: './collapsible-panel.component.html',
  animations: [  // ← animations array — part of @Component decorator
    trigger('openClose', [  // ← 'openClose' is the trigger NAME (use in template as [@openClose])

      // STATE 1: When the panel is open
      state('open', style({
        height: '200px',  // ← Final resting height when open
        opacity: 1,       // ← Fully visible
        backgroundColor: '#ffffff'  // ← White background when open
      })),

      // STATE 2: When the panel is closed
      state('closed', style({
        height: '0px',    // ← Collapsed — takes no space
        opacity: 0,       // ← Invisible
        backgroundColor: '#f0f0f0'  // ← Gray when closed (though invisible)
      })),

      // TRANSITION: Open → Closed (user clicks to close)
      transition('open => closed', [
        animate('300ms ease-in') // ← 300ms, starts fast then slows at end
        // Note: no style() here — Angular animates FROM the 'open' styles
        //       TO the 'closed' styles defined in state()
      ]),

      // TRANSITION: Closed → Open (user clicks to open)
      transition('closed => open', [
        animate('300ms ease-out') // ← 300ms, starts slow then accelerates
        // Different easing — opening feels more energetic than closing
      ]),
    ])
  ]
})
export class CollapsiblePanelComponent {
  isOpen: boolean = true; // ← Track current state in component

  toggle(): void {
    this.isOpen = !this.isOpen; // ← Flip the boolean — Angular will trigger animation
  }
}
```

### Step 2: Bind the Animation in the Template

```html
<!-- collapsible-panel.component.html -->

<!-- Toggle button — calls toggle() which flips isOpen -->
<button (click)="toggle()">
  {{ isOpen ? 'Close Panel' : 'Open Panel' }}
</button>

<!--
  [@openClose]="isOpen ? 'open' : 'closed'"
  ↑ The animation trigger binding syntax
  │
  ├── @ prefix = this is an animation binding (not a property binding)
  ├── openClose = MUST match the trigger() name in your component
  └── "isOpen ? 'open' : 'closed'" = the STATE expression
      When isOpen changes, Angular looks for a transition from old state to new state
-->
<div [@openClose]="isOpen ? 'open' : 'closed'"
     class="panel-content"
     style="overflow: hidden;">
  <p>This panel content animates smoothly open and closed.</p>
  <p>Any content can go here — it will animate with the container.</p>
</div>
```

### Step 3: Styles for the Panel

```css
/* collapsible-panel.component.css */
.panel-content {
  overflow: hidden;    /* ← Critical! Without this, content peeks out during collapse */
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 0 16px;    /* ← Horizontal padding only — vertical is controlled by animation */
  /* Do NOT set height here — the animation controls height */
}
```

### What Happens Step by Step

```
User clicks "Close Panel":

1. toggle() called → isOpen = false
2. Angular evaluates [@openClose] expression: 'open' → 'closed'
3. Angular finds matching transition: 'open => closed'
4. Animation begins: height 200px→0px, opacity 1→0 over 300ms (ease-in)
5. At 300ms: element is at 'closed' state styles permanently

User clicks "Open Panel":

1. toggle() called → isOpen = true
2. Angular evaluates [@openClose] expression: 'closed' → 'open'
3. Angular finds matching transition: 'closed => open'
4. Animation begins: height 0→200px, opacity 0→1 over 300ms (ease-out)
5. At 300ms: element is at 'open' state styles permanently
```

---

## 16.5 Transition Shortcuts

### The Problem: Writing Every Transition is Tedious

Writing `'stateA => stateB'` for every possible pair of states explodes in complexity when you have many states. Angular provides shorthand expressions.

### All Transition Expressions

```typescript
// All valid transition expressions:

// 1. SPECIFIC one-way transition
transition('open => closed', animate('300ms'))
// ← ONLY fires when going from 'open' to 'closed'
// ← Does NOT fire for 'closed' to 'open'

// 2. BIDIRECTIONAL transition (both directions)
transition('open <=> closed', animate('300ms'))
// ← Fires for 'open' to 'closed' AND 'closed' to 'open'
// ← Same animation in both directions (use when open/close look identical)

// 3. ANY state to ANY state (wildcard)
transition('* => *', animate('300ms'))
// ← Fires for every state change
// ← Useful as a default fallback

// 4. FROM any state TO a specific state
transition('* => closed', animate('500ms'))
// ← ANY state → closed fires this
// ← 'open' → 'closed': this fires
// ← 'half-open' → 'closed': this fires too

// 5. :enter — alias for 'void => *'
// Element enters the DOM (e.g., *ngIf becomes true, *ngFor adds item)
transition(':enter', [
  style({ opacity: 0 }),         // ← Start invisible
  animate('300ms', style({ opacity: 1 })) // ← Fade in
])
// 'void => *' means: coming from "not in DOM" to "any state"

// 6. :leave — alias for '* => void'
// Element leaves the DOM (e.g., *ngIf becomes false, *ngFor removes item)
transition(':leave', [
  animate('300ms', style({ opacity: 0 })) // ← Fade out before removal
])
// '* => void' means: going from "any state" to "not in DOM"

// 7. :increment — when a numeric state value increases
transition(':increment', [
  animate('300ms ease-out', style({ color: 'green' }))
])
// ← state goes from 3 → 4 → 5 (any increase), this fires

// 8. :decrement — when a numeric state value decreases
transition(':decrement', [
  animate('300ms ease-in', style({ color: 'red' }))
])
// ← state goes from 5 → 4 → 3 (any decrease), this fires
```

### Comparison Table: Transition Expressions

| Expression | Fires When | Common Use Case |
|---|---|---|
| `'a => b'` | Only a→b | One-way animation (closing only) |
| `'a <=> b'` | Both a→b and b→a | Toggle animations |
| `'* => *'` | Any state change | Catch-all fallback |
| `'* => b'` | Any state → b | "Entering" a state from anywhere |
| `'a => *'` | a → any state | "Leaving" a state to anywhere |
| `':enter'` | void → * | Element added to DOM |
| `':leave'` | * → void | Element removed from DOM |
| `':increment'` | Number increases | Counter animations |
| `':decrement'` | Number decreases | Counter animations |

### Order Matters: More Specific Rules Win

```typescript
trigger('myAnimation', [
  // More specific transitions should come FIRST
  transition('open => closed', animate('400ms ease-in')),  // ← Matches first
  transition('* => closed',   animate('200ms')),           // ← Would also match open→closed
  transition('* => *',        animate('100ms')),           // ← Catch-all fallback

  // Angular checks transitions in ORDER and uses the FIRST match
  // So 'open => closed' wins over '* => closed' which wins over '* => *'
])
```

---

## 16.6 Enter and Leave Animations

### The Problem: Elements Appear and Disappear Instantly

When you use `*ngIf` or `*ngFor`, elements are instantly added to or removed from the DOM. There's no visual continuity — the page jumps.

```
WITHOUT enter/leave animations:       WITH enter/leave animations:

Item added  → POOF! It's there        Item added  → fades/slides in smoothly
Item removed → POOF! It's gone        Item removed → fades/slides out then gone
```

### Fade In / Fade Out

```typescript
// fade-item.component.ts
import { Component } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-fade-item',
  template: `
    <div [@fadeInOut]>Content here</div>
  `,
  animations: [
    trigger('fadeInOut', [

      // :enter = 'void => *' = element is entering the DOM
      transition(':enter', [
        style({ opacity: 0 }),          // ← START state: invisible
        animate('300ms ease-in',
          style({ opacity: 1 })         // ← END state: fully visible
        )
        // Angular animates from opacity:0 → opacity:1 over 300ms
      ]),

      // :leave = '* => void' = element is leaving the DOM
      transition(':leave', [
        // No starting style() needed — Angular uses the current rendered state as start
        animate('300ms ease-out',
          style({ opacity: 0 })         // ← END state: invisible before removal
        )
        // Angular animates from current opacity → opacity:0 over 300ms
        // THEN removes the element from DOM
      ])
    ])
  ]
})
export class FadeItemComponent { }
```

### Slide In From Left

```typescript
// animations: [
trigger('slideInLeft', [

  transition(':enter', [
    style({ transform: 'translateX(-100%)', opacity: 0 }),  // ← Start: off-screen left
    animate('400ms ease-out', style({
      transform: 'translateX(0)',   // ← End: natural position
      opacity: 1                    // ← End: fully visible
    }))
  ]),

  transition(':leave', [
    animate('400ms ease-in', style({
      transform: 'translateX(-100%)', // ← End: slide back off-screen left
      opacity: 0
    }))
  ])
])
// ]

// Common slide directions:
// From left:  translateX(-100%) → translateX(0)
// From right: translateX(100%)  → translateX(0)
// From top:   translateY(-100%) → translateY(0)
// From bottom:translateY(100%)  → translateY(0)
```

### Full Example: Animated List with Enter/Leave

```typescript
// animated-list.component.ts
import { Component } from '@angular/core';
import { trigger, transition, style, animate } from '@angular/animations';

@Component({
  selector: 'app-animated-list',
  template: `
    <button (click)="addItem()">Add Item</button>

    <ul>
      <!--
        @listAnimation on the li element — not the ul!
        The animation triggers when each li enters/leaves the DOM
        via *ngFor
      -->
      <li
        *ngFor="let item of items; trackBy: trackById"
        [@listAnimation]
        class="list-item">
        {{ item.name }}
        <button (click)="removeItem(item.id)">Remove</button>
      </li>
    </ul>
  `,
  animations: [
    trigger('listAnimation', [

      // Each new item slides in from the left
      transition(':enter', [
        style({ transform: 'translateX(-30px)', opacity: 0 }), // ← Start slightly left + invisible
        animate('300ms ease-out', style({
          transform: 'translateX(0)',  // ← Natural position
          opacity: 1                   // ← Fully visible
        }))
      ]),

      // Each removed item fades out and shrinks
      transition(':leave', [
        animate('250ms ease-in', style({
          transform: 'translateX(30px)', // ← Slide slightly right while leaving
          opacity: 0,                    // ← Fade out
          height: '0',                   // ← Collapse height (requires overflow:hidden on li)
          margin: '0',                   // ← Remove margin to close the gap
          padding: '0'                   // ← Remove padding too
        }))
      ])
    ])
  ]
})
export class AnimatedListComponent {
  nextId = 1;
  items: Array<{ id: number; name: string }> = [
    { id: this.nextId++, name: 'First Item' }
  ];

  addItem(): void {
    this.items.push({ id: this.nextId++, name: `Item ${this.nextId - 1}` });
    // ← *ngFor adds a new <li> → :enter animation fires automatically
  }

  removeItem(id: number): void {
    this.items = this.items.filter(item => item.id !== id);
    // ← *ngFor removes the <li> → :leave animation fires automatically
    // ← Angular waits for :leave animation to complete BEFORE removing from DOM
  }

  trackById(index: number, item: { id: number }): number {
    return item.id; // ← trackBy is REQUIRED for enter/leave animations in *ngFor
                    // Without trackBy, Angular re-creates all items on change,
                    // causing all items to re-animate on every add/remove
  }
}
```

```css
/* animated-list.component.css */
.list-item {
  overflow: hidden;      /* ← Required for height collapse animation to work */
  border: 1px solid #ddd;
  padding: 12px 16px;
  margin-bottom: 8px;
  border-radius: 4px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

### Critical: trackBy is Required for List Animations

```
WITHOUT trackBy:                    WITH trackBy:
*ngFor tracks by index              *ngFor tracks by item.id

Add item at top:                    Add item at top:
- All existing <li> elements        - Only the NEW <li> element
  get destroyed and recreated         gets :enter animation
- ALL items re-animate              - Existing items don't move
- Very jarring UX                   - Smooth, correct UX ✓
```

---

## 16.7 The void and * States

### Understanding the Special States

```
THE DOM LIFECYCLE OF AN ELEMENT:

Not in DOM    →    Enters DOM    →    In DOM    →    Leaves DOM    →    Not in DOM
 (void)            (void→*)        (any state)       (*→void)            (void)

     ↑                                                                       ↑
 :enter fires here                                               :leave fires here
 (void => *)                                                     (* => void)
```

### void State: The Element Doesn't Exist Yet

```typescript
// The void state is automatically applied when an element is NOT in the DOM
// This happens BEFORE *ngIf renders the element and AFTER it removes it

trigger('toastAnimation', [

  // void → * means: element is entering the DOM (same as :enter)
  transition('void => *', [
    style({
      transform: 'translateY(-20px)',  // ← Start 20px above natural position
      opacity: 0,                      // ← Start invisible
    }),
    animate('200ms ease-out', style({
      transform: 'translateY(0)',      // ← Settle into natural position
      opacity: 1,                      // ← Become visible
    }))
  ]),

  // * → void means: element is leaving the DOM (same as :leave)
  transition('* => void', [
    animate('150ms ease-in', style({
      transform: 'translateY(-20px)',  // ← Slide upward while leaving
      opacity: 0,                      // ← Fade out
    }))
  ])
])
```

### Real Example: Toast Notification

```typescript
// toast-notification.component.ts
import { Component, Input } from '@angular/core';
import { trigger, transition, style, animate, state } from '@angular/animations';

@Component({
  selector: 'app-toast',
  template: `
    <!--
      *ngIf="isVisible" controls whether the element is in the DOM
      [@toastAnimation] provides the enter/leave animation
      When isVisible changes false→true: void→* animation fires (slide down)
      When isVisible changes true→false: *→void animation fires (fade up)
    -->
    <div *ngIf="isVisible"
         [@toastAnimation]
         class="toast"
         [class.toast-success]="type === 'success'"
         [class.toast-error]="type === 'error'">
      {{ message }}
      <button (click)="dismiss()">×</button>
    </div>
  `,
  animations: [
    trigger('toastAnimation', [

      // ENTERING: slide down from above + fade in
      transition('void => *', [        // ← void→* is identical to :enter
        style({
          transform: 'translateY(-100%)', // ← Start above the viewport
          opacity: 0
        }),
        animate('300ms cubic-bezier(0.25, 0.8, 0.25, 1)', style({
          transform: 'translateY(0)', // ← Land in position
          opacity: 1
        }))
      ]),

      // LEAVING: slide up and fade out
      transition('* => void', [        // ← *→void is identical to :leave
        animate('200ms cubic-bezier(0.4, 0, 1, 1)', style({
          transform: 'translateY(-100%)', // ← Slide back up
          opacity: 0
        }))
      ])
    ])
  ]
})
export class ToastComponent {
  @Input() message: string = '';
  @Input() type: 'success' | 'error' | 'info' = 'info';
  isVisible: boolean = true;

  dismiss(): void {
    this.isVisible = false; // ← Triggers :leave animation before DOM removal
  }
}
```

### void vs Custom States: Key Differences

| Aspect | `void` State | Custom State (e.g., 'closed') |
|---|---|---|
| **What it means** | Element is NOT in the DOM | Element IS in DOM with specific styles |
| **How triggered** | `*ngIf="false"`, `*ngFor` removal | State binding changes value |
| **Physical presence** | Element truly absent | Element present but may be invisible |
| **Use case** | Enter/leave animations | Toggle, expand/collapse |
| **Syntax** | `void => *` or `:enter` | `'open => closed'` |

---

## 16.8 Animate Timing

### The Timing String Format

```
animate('duration delay easing')
         ↑        ↑      ↑
         │        │      └── CSS easing function
         │        └───────── How long to WAIT before starting (optional)
         └────────────────── How long the animation takes

Examples:
animate('300ms')                   ← 300ms, no delay, default easing
animate('1s')                      ← 1 second, no delay
animate('300ms 150ms')             ← 300ms, wait 150ms first
animate('300ms 150ms ease-in')     ← 300ms, wait 150ms, ease-in easing
animate('0.5s 0 cubic-bezier(0.4, 0, 0.2, 1)') ← Custom easing

Time units:
'300ms'  ← milliseconds
'0.3s'   ← seconds (same as 300ms)
'1s'     ← 1 second (= 1000ms)
```

### Easing Functions Explained

```
LINEAR:         ████████████████  Constant speed throughout
ease (default): ██████████████▌▌  Slow start, faster middle, slow end
ease-in:        ▌▌████████████▌▌  Slow start, accelerates toward end
ease-out:       ████████████████  Fast start, decelerates toward end
ease-in-out:    ▌████████████▌▌▌  Slow start, fast middle, slow end

MENTAL MODELS:
ease-out   = Ball rolling to a stop (natural deceleration)
ease-in    = Ball starting to roll (natural acceleration)
ease-in-out= Sliding drawer (starts and ends gently)
linear     = Mechanical/robotic movement (rarely looks natural)
```

### cubic-bezier() Deep Dive

```typescript
// cubic-bezier(x1, y1, x2, y2)
// Think of it as defining the handles of a Bezier curve

animate('300ms cubic-bezier(0.25, 0.8, 0.25, 1)')
// ↑ Material Design's standard easing — smooth and satisfying

animate('300ms cubic-bezier(0.4, 0, 0.2, 1)')
// ↑ Material Design's emphasized easing — confident and clear

animate('300ms cubic-bezier(0, 0, 0.2, 1)')
// ↑ Deceleration — objects moving to final resting point

animate('300ms cubic-bezier(0.4, 0, 1, 1)')
// ↑ Acceleration — objects leaving the screen
```

### Timing Comparison Table

| Easing | CSS Value | Feel | Use For |
|---|---|---|---|
| Linear | `linear` | Mechanical, robotic | Spinners, progress bars |
| Ease | `ease` | Natural, organic | Generic animations |
| Ease-in | `ease-in` | Accelerating, urgent | Elements LEAVING screen |
| Ease-out | `ease-out` | Decelerating, settling | Elements ENTERING screen |
| Ease-in-out | `ease-in-out` | Smooth, polished | Toggle/expand animations |
| MD Standard | `cubic-bezier(0.4, 0, 0.2, 1)` | Confident, clear | Most UI interactions |

### Recommended Durations by Animation Type

```
DURATION GUIDELINES:
                                           Feels too   Feels    Feels too
                                              slow      right      fast
Micro animations (hover, focus):           >200ms    100-150ms   <80ms
Simple transitions (show/hide):            >500ms    200-300ms   <150ms
Complex transitions (route change):        >800ms    300-500ms   <250ms
Decorative animations (hero sections):     >2000ms   600-1000ms  <400ms

DELAY GUIDELINES:
No delay (0ms):          Immediate response to user action ← usually preferred
Short delay (50-100ms):  Staggered child items, give time to notice
Medium delay (150-300ms): Secondary elements, let primary settle first
Long delay (300ms+):     Auto-playing decorative sequences only
```

---

## 16.9 Keyframe Animations

### The Problem: Two-Step Animations Are Not Enough

Sometimes you need more than A → B. You need A → B → C → D. That's what `keyframes()` gives you.

### Real-World Analogy: Film Frames

A movie is just many still frames played rapidly. Keyframes are the "key moments" in an animation — Angular (or the browser) fills in the smooth frames between them automatically.

```
A simple transition:
Start ──────────────────────────► End
 0%                               100%

A keyframe animation:
Start ──────► Mid-1 ──► Mid-2 ──► End
 0%           33%        66%       100%
 (offset: 0) (offset: 0.33)      (offset: 1)
```

### keyframes() Syntax

```typescript
// bounce-in.animation.ts
import { trigger, transition, animate, keyframes, style } from '@angular/animations';

trigger('bounceIn', [
  transition(':enter', [
    animate('600ms ease-in', keyframes([  // ← keyframes() wraps multiple style() calls
      // Each style() in keyframes() takes an 'offset' from 0.0 to 1.0
      // offset: 0 = start of animation
      // offset: 1 = end of animation

      style({ transform: 'scale(0)', opacity: 0, offset: 0 }),
      // ↑ At 0% (0ms): invisible and zero size

      style({ transform: 'scale(1.2)', opacity: 0.8, offset: 0.6 }),
      // ↑ At 60% (360ms): slightly OVERSIZED (the "bounce" overshoot)

      style({ transform: 'scale(0.9)', opacity: 0.9, offset: 0.8 }),
      // ↑ At 80% (480ms): slightly undersized (bouncing back)

      style({ transform: 'scale(1.0)', opacity: 1, offset: 1.0 }),
      // ↑ At 100% (600ms): natural size, fully visible
    ]))
  ])
])
```

### Shake Effect (for Form Validation Errors)

```typescript
// Used when a form is submitted with errors — shake the form
trigger('shake', [
  transition('* => error', [        // ← Triggered when state changes to 'error'
    animate('500ms', keyframes([

      style({ transform: 'translateX(0)',    offset: 0 }),   // ← Start at natural position
      style({ transform: 'translateX(-10px)', offset: 0.1 }),// ← Quick left
      style({ transform: 'translateX(10px)',  offset: 0.2 }),// ← Quick right
      style({ transform: 'translateX(-10px)', offset: 0.3 }),// ← Left again
      style({ transform: 'translateX(10px)',  offset: 0.4 }),// ← Right again
      style({ transform: 'translateX(-10px)', offset: 0.5 }),// ← Left
      style({ transform: 'translateX(10px)',  offset: 0.6 }),// ← Right
      style({ transform: 'translateX(-10px)', offset: 0.7 }),// ← Left (slowing)
      style({ transform: 'translateX(5px)',   offset: 0.8 }),// ← Small right
      style({ transform: 'translateX(-5px)',  offset: 0.9 }),// ← Small left
      style({ transform: 'translateX(0)',    offset: 1.0 }), // ← Rest at natural position

    ]))
  ])
])
```

### Pulse Effect (for Attention-Getting Badges)

```typescript
// notification-badge.component.ts
import { Component } from '@angular/core';
import { trigger, transition, animate, keyframes, style } from '@angular/animations';

@Component({
  selector: 'app-notification-badge',
  template: `
    <div class="badge-container">
      <button>Messages</button>
      <!--
        [@pulseBadge]="count > 0 ? 'active' : 'inactive'"
        When count increases (new notification), state stays 'active'
        but the transition fires because Angular detects the state
        value... wait, we need a different approach for repeated firing.

        Better: Use a changing STATE value, not boolean:
      -->
      <span
        *ngIf="count > 0"
        [@bounceBadge]
        class="badge">
        {{ count }}
      </span>
    </div>
  `,
  animations: [
    trigger('bounceBadge', [
      // The badge appears with a bounce when a new notification arrives
      transition(':enter', [
        animate('500ms', keyframes([
          style({ transform: 'scale(0) rotate(-45deg)', offset: 0 }),     // ← Start tiny and rotated
          style({ transform: 'scale(1.3) rotate(5deg)', offset: 0.5 }),   // ← Overshoot: big!
          style({ transform: 'scale(0.9) rotate(-3deg)', offset: 0.75 }), // ← Bounce back
          style({ transform: 'scale(1) rotate(0deg)', offset: 1 }),        // ← Settle naturally
        ]))
      ]),

      // The badge disappears with a pop when dismissed
      transition(':leave', [
        animate('200ms ease-in', keyframes([
          style({ transform: 'scale(1)', opacity: 1, offset: 0 }),    // ← Start normal
          style({ transform: 'scale(1.2)', opacity: 0.8, offset: 0.3 }), // ← Quick bulge
          style({ transform: 'scale(0)', opacity: 0, offset: 1 }),    // ← Shrink to nothing
        ]))
      ])
    ])
  ]
})
export class NotificationBadgeComponent {
  count: number = 0;

  addNotification(): void {
    this.count++;
    // ← When count goes 0→1, *ngIf becomes true, :enter fires (bounce)
    // When count is already >0, no new animation (badge already visible)
    // For "NEW notification" animation when count is already >0,
    // see 16.13 (parameterized reusable animations)
  }
}
```

---

## 16.10 Multi-Step Transitions with group() and sequence()

### The Problem: Complex Coordinated Animations

Sometimes you want multiple CSS properties to animate simultaneously (group) or one after another (sequence).

### Real-World Analogy

```
sequence() = Orchestra plays movements ONE AT A TIME:
  First movement: strings play
  THEN second movement: brass joins
  THEN third movement: full orchestra

group() = Orchestra plays ALL PARTS AT ONCE:
  Strings + brass + percussion all start together
  (though each might have different durations)
```

### group() — Parallel Animations

```typescript
import { trigger, transition, style, animate, group } from '@angular/animations';

trigger('slideAndFade', [
  transition(':enter', [
    // group() runs ALL animations inside it SIMULTANEOUSLY
    group([
      // Animation 1: Slide in from left (takes 400ms)
      animate('400ms ease-out', style({
        transform: 'translateX(0)'  // ← FROM: set in initial style() below
      })),

      // Animation 2: Fade in (takes only 250ms — shorter than the slide)
      animate('250ms ease-out', style({
        opacity: 1                  // ← FROM: set in initial style() below
      }))
    ])
  ]),

  // But wait — we need to set the starting styles BEFORE the group
  // The correct way with group():
  transition(':enter', [
    style({ transform: 'translateX(-100%)', opacity: 0 }),  // ← Initial state

    group([
      animate('400ms ease-out', style({ transform: 'translateX(0)' })),
      animate('250ms ease-out', style({ opacity: 1 }))
      // Both animations start at the same time
      // Slide finishes at 400ms, fade finishes at 250ms
      // The whole group finishes at max(400ms, 250ms) = 400ms
    ])
  ])
])

// Cleaner version (easier to read):
trigger('panelEnter', [
  transition(':enter', [
    style({
      transform: 'translateX(-50px)',  // ← Start: off to the left
      opacity: 0,                       // ← Start: invisible
      height: '0px'                     // ← Start: collapsed
    }),
    group([
      // Slide into position AND fade in SIMULTANEOUSLY
      animate('350ms ease-out', style({ transform: 'translateX(0)' })),
      animate('350ms ease-out', style({ opacity: 1 })),
      // Height expands SLOWER for a layered effect
      animate('500ms ease-out', style({ height: '200px' }))
      // Total duration: 500ms (the slowest animation in the group)
    ])
  ])
])
```

### sequence() — Sequential Animations

```typescript
import { trigger, transition, style, animate, sequence } from '@angular/animations';

trigger('popIn', [
  transition(':enter', [
    style({ transform: 'scale(0)', opacity: 0 }),  // ← Initial state

    // sequence() runs animations ONE AFTER ANOTHER
    sequence([
      // Step 1: Scale up first (takes 200ms)
      animate('200ms ease-out', style({ transform: 'scale(1.1)' })),
      // ← After 200ms, this is complete, then step 2 starts

      // Step 2: Settle to natural size + full opacity (takes 100ms, starts at 200ms)
      animate('100ms ease-in', style({ transform: 'scale(1)', opacity: 1 }))
      // ← After 300ms total, animation is complete
    ])
  ])
])

// More complex sequence: slide then highlight
trigger('slideHighlight', [
  transition(':enter', [
    style({ transform: 'translateY(-20px)', opacity: 0, backgroundColor: 'white' }),

    sequence([
      // Step 1: Slide into position and fade in (300ms)
      animate('300ms ease-out', style({
        transform: 'translateY(0)',
        opacity: 1
      })),

      // Step 2: Briefly highlight the item in yellow (200ms) — runs AFTER step 1
      animate('200ms ease-in', style({
        backgroundColor: '#fffde7'  // ← Yellow highlight
      })),

      // Step 3: Fade highlight back to white (300ms) — runs AFTER step 2
      animate('300ms ease-out', style({
        backgroundColor: 'white'   // ← Back to white
      }))
    ])
    // Total: 300ms + 200ms + 300ms = 800ms
    // The slide happens first, THEN the highlight appears, THEN it fades
  ])
])
```

### group() vs sequence() Comparison

| Feature | `group()` | `sequence()` |
|---|---|---|
| **Execution** | All animations run simultaneously | Animations run one after another |
| **Total duration** | Max of all child durations | Sum of all child durations |
| **Use case** | Multi-property simultaneous change | Step-by-step choreography |
| **Example** | Slide + Fade at same time | Slide, then highlight, then fade |

### Combining group() and sequence()

```typescript
// You can nest them!
trigger('complexEnter', [
  transition(':enter', [
    style({ transform: 'scale(0)', opacity: 0, boxShadow: 'none' }),

    sequence([
      // Step 1: Appear with scale (runs first)
      group([
        animate('200ms ease-out', style({ transform: 'scale(1)' })),
        animate('200ms ease-out', style({ opacity: 1 }))
        // ↑ Scale and fade happen simultaneously
      ]),

      // Step 2: After appearance, add shadow (runs after step 1)
      animate('150ms ease-out', style({
        boxShadow: '0 4px 6px rgba(0,0,0,0.1)'
      }))
    ])
  ])
])
```

---

## 16.11 query() and stagger() — Animating Child Elements

### The Problem: Animating Many Children

You have a grid of cards or a list of items. Instead of all appearing at once (jarring) or none animating (boring), you want them to appear one by one with a small delay between each.

```
WITHOUT stagger:                    WITH stagger:

All 6 cards appear at once:         Cards appear one by one:
┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐           ┌──┐
│  ││  ││  ││  ││  ││  │    →       │  │ (50ms later) ┌──┐
└──┘└──┘└──┘└──┘└──┘└──┘                              │  │ (50ms later) ┌──┐
POOF! All at once                                      └──┘              │  │...
                                                                         └──┘
```

### query() — Selecting Child Elements

```typescript
// query() is used inside a trigger on a PARENT element
// It selects CHILD elements to animate

import { trigger, transition, query, style, animate, stagger } from '@angular/animations';

// Applied to the PARENT container (the <ul> or <div class="grid">):
trigger('listContainerAnimation', [
  transition('* => *', [  // ← Fires when the parent state changes (or on init)

    // query() selects children matching a CSS selector
    // ':enter' means children that are entering the DOM
    query(':enter', [
      // First, set all entering children to their start state:
      style({ opacity: 0, transform: 'translateY(20px)' }),

      // Then stagger the animation for each child:
      stagger('50ms', [   // ← 50ms delay between each child's animation
        animate('300ms ease-out', style({
          opacity: 1,
          transform: 'translateY(0)'
        }))
      ])
    ], { optional: true })  // ← optional:true prevents error if no children match
  ])
])
```

### Full Example: Staggered List

```typescript
// staggered-list.component.ts
import { Component } from '@angular/core';
import {
  trigger, transition, query, style, animate, stagger
} from '@angular/animations';

@Component({
  selector: 'app-staggered-list',
  template: `
    <button (click)="loadItems()">Load Items</button>
    <button (click)="clearItems()">Clear</button>

    <!--
      [@listAnimation]="items.length" on the CONTAINER
      The trigger is on the parent ul, not individual li elements!
      When items.length changes, the transition fires,
      then query() selects the entering <li> children
    -->
    <ul [@listAnimation]="items.length" class="item-list">
      <li *ngFor="let item of items; trackBy: trackById"
          class="list-item">
        <div class="item-icon">{{ item.icon }}</div>
        <div class="item-content">
          <h3>{{ item.title }}</h3>
          <p>{{ item.description }}</p>
        </div>
      </li>
    </ul>
  `,
  animations: [
    trigger('listAnimation', [
      // When items are added (state goes from 0 → some length)
      transition('* => *', [
        query(':enter', [
          // STARTING STYLES for each entering <li>:
          style({
            opacity: 0,                       // ← Start invisible
            transform: 'translateX(-20px)'    // ← Start slightly left
          }),

          // stagger('50ms') means:
          // 1st item: starts immediately (0ms delay)
          // 2nd item: starts after 50ms
          // 3rd item: starts after 100ms
          // 4th item: starts after 150ms
          // ...etc.
          stagger('50ms', [
            animate('300ms ease-out', style({
              opacity: 1,
              transform: 'translateX(0)'  // ← Settle into natural position
            }))
          ])
        ], { optional: true }), // ← optional:true = don't error if no :enter elements

        // Also animate :leave elements (items being removed)
        query(':leave', [
          stagger('30ms', [  // ← 30ms between each leaving item
            animate('200ms ease-in', style({
              opacity: 0,
              transform: 'translateX(20px)' // ← Slide right while leaving
            }))
          ])
        ], { optional: true }) // ← optional:true = don't error if no :leave elements
      ])
    ])
  ]
})
export class StaggeredListComponent {
  nextId = 1;
  items: Array<{ id: number; title: string; description: string; icon: string }> = [];

  loadItems(): void {
    // Adding items — :enter animations will fire, staggered
    const newItems = [
      { id: this.nextId++, title: 'Angular', description: 'Frontend framework', icon: '🅰️' },
      { id: this.nextId++, title: 'RxJS', description: 'Reactive extensions', icon: '🔄' },
      { id: this.nextId++, title: 'TypeScript', description: 'Typed JavaScript', icon: '📘' },
      { id: this.nextId++, title: 'NgRx', description: 'State management', icon: '🗂️' },
      { id: this.nextId++, title: 'Material', description: 'UI components', icon: '🎨' },
    ];
    this.items = [...this.items, ...newItems];
  }

  clearItems(): void {
    this.items = []; // ← :leave animations fire for all items, staggered
  }

  trackById(index: number, item: { id: number }): number {
    return item.id;
  }
}
```

### Staggered Grid Animation

```typescript
// dashboard-cards.component.ts — cards appear in a staggered grid
@Component({
  selector: 'app-dashboard-cards',
  template: `
    <div class="cards-grid"
         [@cardsAnimation]="cards.length">
      <div *ngFor="let card of cards; trackBy: trackById"
           class="card">
        <h3>{{ card.title }}</h3>
        <p>{{ card.value }}</p>
      </div>
    </div>
  `,
  animations: [
    trigger('cardsAnimation', [
      transition('* => *', [
        query(':enter', [
          style({ opacity: 0, transform: 'scale(0.9) translateY(10px)' }),
          stagger('80ms', [  // ← Each card appears 80ms after the previous
            animate('400ms cubic-bezier(0.25, 0.8, 0.25, 1)', style({
              opacity: 1,
              transform: 'scale(1) translateY(0)'
            }))
          ])
        ], { optional: true })
      ])
    ])
  ]
})
export class DashboardCardsComponent {
  cards = [/* card data */];
  trackById = (i: number, c: any) => c.id;
}
```

### query() Selector Options

```typescript
// query() can use various selectors:

query(':enter', [...])          // ← Children entering the DOM
query(':leave', [...])          // ← Children leaving the DOM
query('.card', [...])           // ← Children with class 'card'
query('li', [...])              // ← All <li> child elements
query(':self', [...])           // ← The element itself (in route animations)
query(':animating', [...])      // ← Children currently being animated
query('li:not(.header)', [...]) // ← CSS :not() selector works too
```

---

## 16.12 Route Transition Animations

### The Problem: Route Changes Are Jarring

When navigating between routes, the content instantly replaces. No sense of where you're going or coming from. Animations provide spatial context.

```
WITHOUT route animation:            WITH route animation (slide left):

[Home] [About] [Contact]            [Home] [About] [Contact]
┌────────────────────┐              ┌────────────────────┐
│ Home Content       │   Click      │ Home Content ─────►│
│                    │  "About"     │                    │ ─ sliding left
└────────────────────┘    →         └────────────────────┘
┌────────────────────┐              ┌────────────────────┐
│ About Content      │              │◄──── About Content │
└────────────────────┘              │    (sliding in)    │
(instant replace)                   └────────────────────┘
                                    (smooth spatial transition)
```

### Step 1: Add Route Data for Animation State

```typescript
// app.routes.ts (or app-routing.module.ts)
import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { AboutComponent } from './about/about.component';
import { ContactComponent } from './contact/contact.component';

export const routes: Routes = [
  {
    path: 'home',
    component: HomeComponent,
    data: { animation: 'HomePage' }  // ← Animation state name for this route
  },
  {
    path: 'about',
    component: AboutComponent,
    data: { animation: 'AboutPage' } // ← Different state name
  },
  {
    path: 'contact',
    component: ContactComponent,
    data: { animation: 'ContactPage' }
  },
  { path: '', redirectTo: 'home', pathMatch: 'full' }
];
```

### Step 2: Create Route Animations

```typescript
// route-animations.ts — separate file for reusability
import {
  trigger, transition, style, animate, query, group
} from '@angular/animations';

export const routeAnimations = trigger('routeAnimations', [

  // === FADE TRANSITION (simple, works for all routes) ===
  transition('* <=> *', [        // ← Any route → Any route
    // Hide the new route immediately
    query(':enter', [
      style({ opacity: 0 })      // ← Entering route starts invisible
    ], { optional: true }),

    // Fade out old route, fade in new route SIMULTANEOUSLY
    group([
      query(':leave', [
        animate('200ms ease-in', style({ opacity: 0 })) // ← Old route fades out
      ], { optional: true }),

      query(':enter', [
        animate('200ms 150ms ease-out', style({ opacity: 1 })) // ← New route fades in (with 150ms delay)
      ], { optional: true })
    ])
  ])
]);

// === SLIDE LEFT/RIGHT TRANSITION (directional navigation) ===
export const slideRouteAnimations = trigger('routeAnimations', [

  // Going "deeper" into the app (e.g., list → detail)
  transition('HomePage => AboutPage, HomePage => ContactPage', [
    query(':enter, :leave', [
      style({
        position: 'absolute', // ← Required for slide: both routes visible during transition
        top: 0,
        left: 0,
        width: '100%'
      })
    ], { optional: true }),

    group([
      // Old page slides out to the LEFT
      query(':leave', [
        animate('400ms ease-in-out', style({ transform: 'translateX(-100%)' }))
      ], { optional: true }),

      // New page slides in from the RIGHT
      query(':enter', [
        style({ transform: 'translateX(100%)' }), // ← Start off-screen right
        animate('400ms ease-in-out', style({ transform: 'translateX(0)' })) // ← Slide to center
      ], { optional: true })
    ])
  ]),

  // Going "back" (e.g., detail → list)
  transition('AboutPage => HomePage, ContactPage => HomePage', [
    query(':enter, :leave', [
      style({ position: 'absolute', top: 0, left: 0, width: '100%' })
    ], { optional: true }),

    group([
      // Old page slides out to the RIGHT (reverse direction)
      query(':leave', [
        animate('400ms ease-in-out', style({ transform: 'translateX(100%)' }))
      ], { optional: true }),

      // New page slides in from the LEFT (reverse direction)
      query(':enter', [
        style({ transform: 'translateX(-100%)' }),
        animate('400ms ease-in-out', style({ transform: 'translateX(0)' }))
      ], { optional: true })
    ])
  ])
]);
```

### Step 3: Apply Animation to Router Outlet in Template

```typescript
// app.component.ts
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { routeAnimations } from './route-animations'; // ← Import your animations

@Component({
  selector: 'app-root',
  template: `
    <nav>
      <a routerLink="/home">Home</a>
      <a routerLink="/about">About</a>
      <a routerLink="/contact">Contact</a>
    </nav>

    <!--
      The animation host:
      1. #outlet="outlet" — get a reference to the RouterOutlet
      2. [routerOutlet]="outlet" — pass it to the host's animation function
      3. [@routeAnimations]="getRouteAnimationState(outlet)" — bind the animation trigger
    -->
    <div [@routeAnimations]="getRouteAnimationState(outlet)"
         style="position: relative; overflow: hidden;">
      <router-outlet #outlet="outlet"></router-outlet>
    </div>
  `,
  animations: [routeAnimations]  // ← Reference the imported animation
})
export class AppComponent {
  // This method reads the animation state from the current route's data
  getRouteAnimationState(outlet: RouterOutlet): string {
    return outlet?.activatedRouteData?.['animation'] || '';
    // ← Returns 'HomePage', 'AboutPage', etc. from route data
    // ← When state changes, the transition fires
  }
}
```

### Common Gotcha: position: absolute is Required for Slide Animations

```
WHY position: absolute is needed for slide transitions:

Without it:                    With it:
┌────────────────────┐         ┌────────────────────┐
│ Old Page           │         │ Old Page (sliding)  │
│                    │         │ New Page (behind)   │
│ New Page (below)   │         │                     │
│ (layout breaks!)   │         │ ← Both visible,     │
└────────────────────┘         │   stacked, sliding  │
                               └────────────────────┘

position: absolute removes both pages from document flow
so they can overlap during the transition
```

---

## 16.13 Reusable Animations

### The Problem: Copy-Pasting Animation Code

If you define `fadeIn` in component A, then need it in component B, you'd copy the code. This violates DRY (Don't Repeat Yourself) and makes updating animations a nightmare.

### animation() and useAnimation()

```typescript
// src/app/animations/animations.ts — your animation library

import {
  animation,    // ← Defines a reusable animation (like a function)
  useAnimation, // ← "Calls" the reusable animation
  trigger,
  transition,
  style,
  animate,
  keyframes
} from '@angular/animations';

// =====================================
// REUSABLE ANIMATION 1: fadeIn
// =====================================
export const fadeIn = animation([
  // animation() wraps the animation steps, just like a function body

  style({ opacity: '{{ startOpacity }}' }), // ← Parameterized! {{ }} = template variable

  animate('{{ duration }} {{ easing }}',    // ← Duration and easing are also parameterized
    style({ opacity: 1 })
  )
], {
  // DEFAULT PARAMETER VALUES:
  params: {
    duration: '300ms',      // ← Default: 300ms (can be overridden at call site)
    easing: 'ease-out',     // ← Default easing
    startOpacity: '0'       // ← Default: start invisible
  }
});

// =====================================
// REUSABLE ANIMATION 2: fadeOut
// =====================================
export const fadeOut = animation([
  animate('{{ duration }} {{ easing }}',
    style({ opacity: 0 })
  )
], {
  params: {
    duration: '200ms',
    easing: 'ease-in'
  }
});

// =====================================
// REUSABLE ANIMATION 3: slideInLeft
// =====================================
export const slideInLeft = animation([
  style({ transform: 'translateX({{ startX }})', opacity: 0 }),
  animate('{{ duration }}',
    style({ transform: 'translateX(0)', opacity: 1 })
  )
], {
  params: {
    duration: '400ms ease-out',
    startX: '-100%'          // ← Default: start from far left
  }
});

// =====================================
// REUSABLE ANIMATION 4: bounceIn
// =====================================
export const bounceIn = animation([
  animate('{{ duration }}', keyframes([
    style({ transform: 'scale(0)', opacity: 0, offset: 0 }),
    style({ transform: 'scale(1.2)', opacity: 0.8, offset: 0.6 }),
    style({ transform: 'scale(0.9)', opacity: 0.9, offset: 0.8 }),
    style({ transform: 'scale(1)', opacity: 1, offset: 1 }),
  ]))
], {
  params: {
    duration: '600ms ease-out'
  }
});

// =====================================
// PRE-BUILT TRIGGERS using the reusable animations
// (consumers can use these directly or build their own with useAnimation())
// =====================================

export const fadeInOut = trigger('fadeInOut', [
  transition(':enter', [useAnimation(fadeIn)]),   // ← Use default params
  transition(':leave', [useAnimation(fadeOut)])   // ← Use default params
]);

export const bounceInTrigger = trigger('bounceIn', [
  transition(':enter', [
    useAnimation(bounceIn, {
      params: { duration: '500ms ease-out' } // ← Override default duration
    })
  ])
]);
```

### Using Reusable Animations in Components

```typescript
// modal.component.ts — using reusable animations
import { Component } from '@angular/core';
import { trigger, transition, useAnimation } from '@angular/animations';
import { fadeIn, fadeOut, slideInLeft } from '../animations/animations'; // ← Import

@Component({
  selector: 'app-modal',
  template: `
    <div *ngIf="isOpen" [@modalAnimation] class="modal-overlay">
      <div class="modal-content">
        <h2>Modal Title</h2>
        <p>Modal content here...</p>
        <button (click)="close()">Close</button>
      </div>
    </div>
  `,
  animations: [
    trigger('modalAnimation', [
      // USE the reusable fadeIn animation with CUSTOM parameters
      transition(':enter', [
        useAnimation(fadeIn, {
          params: {
            duration: '200ms',      // ← Override: faster than default 300ms
            easing: 'ease-in',      // ← Override: different easing
            startOpacity: '0'       // ← Same as default
          }
        })
      ]),

      // USE the reusable fadeOut animation with default parameters
      transition(':leave', [
        useAnimation(fadeOut)  // ← No params = uses all defaults from animation()
      ])
    ])
  ]
})
export class ModalComponent {
  isOpen = false;
  open(): void { this.isOpen = true; }
  close(): void { this.isOpen = false; }
}

// sidebar.component.ts — same reusable animation, different config
import { Component } from '@angular/core';
import { trigger, transition, useAnimation } from '@angular/animations';
import { slideInLeft, fadeOut } from '../animations/animations';

@Component({
  selector: 'app-sidebar',
  template: `
    <div *ngIf="isOpen" [@sidebarAnimation] class="sidebar">
      <nav><!-- sidebar nav items --></nav>
    </div>
  `,
  animations: [
    trigger('sidebarAnimation', [
      transition(':enter', [
        useAnimation(slideInLeft, {
          params: {
            duration: '300ms ease-out',
            startX: '-280px'  // ← 280px = sidebar width (not full 100%)
          }
        })
      ]),
      transition(':leave', [
        useAnimation(fadeOut, {
          params: { duration: '150ms' }  // ← Faster exit than entry
        })
      ])
    ])
  ]
})
export class SidebarComponent {
  isOpen = false;
}
```

### animation() vs trigger(): What's the Difference?

```
animation()   = The animation STEPS only (no trigger, no transitions)
               Like a function definition — reusable, parameterizable
               Used with useAnimation() inside a transition()

trigger()     = The complete animation unit: name + states + transitions
               Applied to elements in the template with [@triggerName]
               Can CONTAIN useAnimation() calls in its transitions

ANALOGY:
animation()   = A dance move (the steps themselves)
trigger()     = A choreographed routine (which move, when, triggered by what)
useAnimation()= "Do that dance move now" (calling the routine)
```

---

## 16.14 AnimationBuilder — Programmatic Animations

### The Problem: Sometimes You Can't Use Template Decorators

Scenarios where `[@trigger]` in templates won't work:
- Animating elements inside a third-party component you can't modify
- Triggering animations based on scroll position
- Running animations from inside a service (no template)
- Highly dynamic animations computed at runtime

### AnimationBuilder API

```typescript
// scroll-animation.component.ts
import {
  Component, ElementRef, OnInit, OnDestroy, ViewChild
} from '@angular/core';
import {
  AnimationBuilder,   // ← The builder service — inject it
  AnimationFactory,   // ← Type: the built animation (before it plays)
  AnimationPlayer,    // ← Type: the playing animation (can pause/stop)
  style,
  animate,
  keyframes
} from '@angular/animations';

@Component({
  selector: 'app-scroll-animation',
  template: `
    <div class="scroll-container" (scroll)="onScroll($event)">
      <div #animatedBox class="box">
        Scroll to animate me!
      </div>
    </div>
  `
})
export class ScrollAnimationComponent implements OnInit, OnDestroy {
  @ViewChild('animatedBox', { static: true })
  animatedBox!: ElementRef;  // ← Reference to the DOM element to animate

  private player: AnimationPlayer | null = null;  // ← Current playing animation

  constructor(
    private animationBuilder: AnimationBuilder  // ← Inject the builder
  ) {}

  onScroll(event: Event): void {
    const scrollTop = (event.target as HTMLElement).scrollTop;

    // Dynamically calculate animation values based on scroll position
    const opacity = Math.min(1, scrollTop / 200);        // ← 0→1 as you scroll 0→200px
    const translateY = Math.max(0, 50 - scrollTop / 4);  // ← 50px → 0px as you scroll

    // If there's a playing animation, destroy it before creating a new one
    if (this.player) {
      this.player.destroy();   // ← Clean up previous animation
    }

    // Build the animation dynamically based on scroll position
    const factory: AnimationFactory = this.animationBuilder.build([
      // animate() with 0ms = instant (no interpolation, just set the value)
      animate('0ms', style({
        opacity: opacity,
        transform: `translateY(${translateY}px)`
      }))
    ]);
    // ↑ AnimationBuilder.build() creates an AnimationFactory
    //   Think of it like a "prepared animation ready to run"

    // Create a player by attaching the factory to a DOM element
    this.player = factory.create(this.animatedBox.nativeElement);
    // ↑ factory.create(element) returns an AnimationPlayer
    //   The player knows: what to animate + which element

    this.player.play(); // ← Execute the animation
  }

  ngOnDestroy(): void {
    // ALWAYS clean up players to prevent memory leaks
    if (this.player) {
      this.player.destroy(); // ← Removes animation and event listeners
    }
  }
}
```

### AnimationPlayer API Reference

```typescript
// All methods available on an AnimationPlayer:

player.play();      // ← Start or resume the animation
player.pause();     // ← Pause at current position
player.restart();   // ← Reset to beginning and play
player.reset();     // ← Reset to beginning but don't play
player.finish();    // ← Jump to end state
player.destroy();   // ← Clean up, remove animation (call on destroy!)

// Event callbacks:
player.onStart(() => {
  console.log('Animation started');
});

player.onDone(() => {
  console.log('Animation completed');
});

// Progress (0 to 1):
player.getPosition();  // ← Returns current position (0=start, 1=end)
player.setPosition(0.5); // ← Jump to middle of animation

// Timing:
player.totalTime;  // ← Total duration in ms
```

### More Complete AnimationBuilder Example: Button Click Ripple

```typescript
// ripple-button.component.ts
import { Component, ElementRef } from '@angular/core';
import { AnimationBuilder, style, animate } from '@angular/animations';

@Component({
  selector: 'app-ripple-button',
  template: `
    <button (click)="onClick($event)" class="ripple-button">
      <ng-content></ng-content>
    </button>
  `,
  styles: [`
    .ripple-button { position: relative; overflow: hidden; }
  `]
})
export class RippleButtonComponent {
  constructor(
    private builder: AnimationBuilder,
    private el: ElementRef
  ) {}

  onClick(event: MouseEvent): void {
    // Create a ripple div element programmatically
    const ripple = document.createElement('div');
    ripple.classList.add('ripple');

    // Position ripple at click location
    const rect = this.el.nativeElement.getBoundingClientRect();
    ripple.style.left = `${event.clientX - rect.left}px`;
    ripple.style.top = `${event.clientY - rect.top}px`;

    this.el.nativeElement.querySelector('button').appendChild(ripple);

    // Build and play the ripple animation
    const factory = this.builder.build([
      style({ transform: 'scale(0)', opacity: 0.5 }),  // ← Start: tiny, semi-opaque
      animate('400ms ease-out', style({
        transform: 'scale(4)',   // ← End: 4x size
        opacity: 0               // ← End: invisible (fades out as it expands)
      }))
    ]);

    const player = factory.create(ripple);

    player.onDone(() => {
      ripple.remove();  // ← Clean up DOM element after animation
      player.destroy(); // ← Clean up animation player
    });

    player.play();
  }
}
```

---

## 16.15 Animation Callbacks

### The Problem: Reacting to Animation Lifecycle

Sometimes you need to:
- Disable a button while an animation is playing
- Show content AFTER an animation completes
- Log analytics when an animation runs
- Chain behaviors after animations

### Animation Events: @trigger.start and @trigger.done

```typescript
// loading-card.component.ts
import { Component } from '@angular/core';
import {
  trigger, transition, style, animate,
  AnimationEvent  // ← Import the event type
} from '@angular/animations';

@Component({
  selector: 'app-loading-card',
  template: `
    <!--
      (@cardAnimation.start)="onAnimationStart($event)"
      ← Fires when the animation BEGINS
      ← $event is an AnimationEvent object

      (@cardAnimation.done)="onAnimationDone($event)"
      ← Fires when the animation COMPLETES
      ← $event has: fromState, toState, totalTime, phaseName
    -->
    <div
      [@cardAnimation]="cardState"
      (@cardAnimation.start)="onAnimationStart($event)"
      (@cardAnimation.done)="onAnimationDone($event)"
      class="card">

      <h2>Card Title</h2>
      <p>Content here</p>

      <!--
        Button is disabled DURING the animation
        isAnimating is set true on start, false on done
      -->
      <button
        [disabled]="isAnimating"
        (click)="toggleCard()">
        {{ isAnimating ? 'Animating...' : 'Toggle' }}
      </button>
    </div>

    <!-- This text only shows AFTER the open animation completes -->
    <p *ngIf="showContent" class="reveal-text">
      Animation complete! Content revealed.
    </p>
  `,
  animations: [
    trigger('cardAnimation', [
      transition('void => *', [
        style({ opacity: 0, transform: 'scale(0.8)' }),
        animate('500ms ease-out', style({ opacity: 1, transform: 'scale(1)' }))
      ]),
      transition('* => void', [
        animate('300ms ease-in', style({ opacity: 0, transform: 'scale(0.8)' }))
      ])
    ])
  ]
})
export class LoadingCardComponent {
  cardState = 'visible';
  isAnimating = false;    // ← Tracks if animation is currently running
  showContent = false;    // ← Only set to true after animation completes

  toggleCard(): void {
    this.cardState = this.cardState === 'visible' ? 'hidden' : 'visible';
  }

  onAnimationStart(event: AnimationEvent): void {
    // AnimationEvent properties:
    // event.fromState   ← The state the animation started from (e.g., 'void', 'open')
    // event.toState     ← The state the animation is going to (e.g., '*', 'closed')
    // event.totalTime   ← Duration of animation in ms
    // event.phaseName   ← 'start' or 'done'
    // event.element     ← The DOM element being animated

    console.log(`Animation starting: ${event.fromState} → ${event.toState}`);
    console.log(`Duration: ${event.totalTime}ms`);

    this.isAnimating = true;  // ← Disable the toggle button during animation
  }

  onAnimationDone(event: AnimationEvent): void {
    console.log(`Animation complete: ${event.fromState} → ${event.toState}`);

    this.isAnimating = false;  // ← Re-enable the toggle button

    // React based on WHICH transition just completed:
    if (event.toState === '*' || event.toState === 'visible') {
      // The "enter" animation just finished (element appeared)
      this.showContent = true;  // ← Reveal additional content
    } else if (event.toState === 'void' || event.toState === 'hidden') {
      // The "leave" animation just finished (element disappeared)
      this.showContent = false;
    }
  }
}
```

### Common Use Cases for Callbacks

```typescript
// 1. ANALYTICS — track when users see animations (engagement metrics)
onAnimationDone(event: AnimationEvent): void {
  if (event.toState === 'expanded') {
    this.analyticsService.track('accordion_expanded', {
      duration: event.totalTime
    });
  }
}

// 2. CLEANUP — remove elements after leave animations
onAnimationDone(event: AnimationEvent): void {
  if (event.phaseName === 'done' && event.toState === 'void') {
    // Animation is complete AND element is leaving
    this.cleanupService.cleanup(this.itemId);
  }
}

// 3. CHAINING — start next animation after current completes
onAnimationDone(event: AnimationEvent): void {
  if (event.toState === 'step1Complete') {
    // Immediately trigger the next step
    this.animationState = 'step2';
  }
}

// 4. FOCUS MANAGEMENT — move focus after animation (accessibility)
onAnimationDone(event: AnimationEvent): void {
  if (event.toState === 'open') {
    // After modal opens, move focus to the close button
    this.closeButton.nativeElement.focus();
  }
}
```

---

## 16.16 Performance Considerations

### The Cardinal Rule: Animate Transform and Opacity

```
CHEAP TO ANIMATE (GPU-accelerated, no layout recalculation):
✓ transform: translateX, translateY, scale, rotate, skew
✓ opacity
✓ filter (blur, brightness etc.) — on GPU-capable browsers

EXPENSIVE TO ANIMATE (triggers layout recalculation on every frame):
✗ width, height
✗ margin, padding
✗ top, left, right, bottom (unless using transform instead!)
✗ border-width
✗ font-size
✗ display, visibility (not animatable — instant changes only)
```

### Why This Matters: The Browser Rendering Pipeline

```
Every animation frame, the browser does:

EXPENSIVE (avoid):             CHEAP (prefer):
┌─────────────────┐            ┌─────────────────┐
│ 1. JavaScript   │            │ 1. JavaScript   │
│ 2. Style        │            │ 2. Style        │
│ 3. Layout  ← ← ← width/height│ 3. Layout       │
│    recalc!  recalculated     │    (skipped!)   │
│ 4. Paint   ← ← ← Every frame│ 4. Paint        │
│    repaints everything       │    (skipped!)   │
│ 5. Composite    │            │ 5. Composite ← ← transform/opacity
└─────────────────┘            └─────────────────┘
                                    handled by GPU!
```

### Before and After: Performance Fix

```typescript
// BEFORE: Animating height (triggers layout every frame = janky)
trigger('expandPanel', [
  transition(':enter', [
    style({ height: 0 }),          // ← EXPENSIVE: triggers layout
    animate('300ms', style({ height: '200px' })) // ← EXPENSIVE every frame!
  ])
])

// AFTER: Animating transform + opacity (GPU-accelerated = smooth)
trigger('expandPanel', [
  transition(':enter', [
    style({ transform: 'scaleY(0)', opacity: 0, transformOrigin: 'top' }),
    animate('300ms ease-out', style({
      transform: 'scaleY(1)',  // ← CHEAP: GPU handles this
      opacity: 1               // ← CHEAP: GPU handles this
    }))
  ])
])
// scaleY achieves a similar "expanding" effect without the layout cost
```

### will-change CSS Property

```css
/* Tell the browser to prepare the GPU layer BEFORE animation starts */
.animated-element {
  will-change: transform, opacity;
  /* ↑ Browser allocates GPU resources in advance
     ↑ Reduces jank at animation start
     ↑ WARNING: Don't apply to ALL elements — uses GPU memory! */
}

/* Remove will-change after animation completes (via class toggling): */
.animated-element.animation-complete {
  will-change: auto; /* ← Release GPU resources when not animating */
}
```

### Decision Table: When to Use What

| Scenario | Recommendation | Reason |
|---|---|---|
| Route transitions | Angular Animations | Tied to router state |
| List enter/leave | Angular Animations | Tied to *ngFor data |
| Hover effects | CSS Transitions | Simple, no state needed |
| Loading spinners | CSS Animations | Runs continuously, no state |
| Scroll-driven | AnimationBuilder or CSS scroll-timeline | Dynamic values |
| Complex sequences | Angular Animations with group/sequence | Built-in coordination |
| Third-party elements | AnimationBuilder | Can't add template bindings |
| Performance-critical | CSS Animations | Moves off main thread |
| Physics/Spring | GSAP or custom | Angular doesn't have physics |

### Common Performance Mistakes

```typescript
// MISTAKE 1: Animating margin (layout-triggering)
transition(':enter', [
  style({ marginTop: '-100px' }),    // ← EXPENSIVE!
  animate('300ms', style({ marginTop: '0' })) // ← EXPENSIVE!
])

// FIX: Use transform instead
transition(':enter', [
  style({ transform: 'translateY(-100px)' }),  // ← CHEAP!
  animate('300ms', style({ transform: 'translateY(0)' }))
])

// MISTAKE 2: Forgetting optional:true on query()
transition('* => *', [
  query(':enter', [...])  // ← Throws error if no :enter elements exist!
])

// FIX:
transition('* => *', [
  query(':enter', [...], { optional: true }) // ← Safe even if no :enter elements
])

// MISTAKE 3: Not using trackBy with list animations
// Without trackBy, *ngFor recreates ALL items on change
// causing ALL items to fire :enter animation simultaneously
// (instead of only new items) → very jarring

// MISTAKE 4: Very long animations on frequently-triggered events
// (scroll events, mousemove) — builds up a queue of animations!
// FIX: destroy() previous player before creating new one
```

---

## 16.17 Practical Example — Animated Dashboard

### Overview

This is a complete, production-ready animated dashboard combining everything from this phase. It features:
1. Animated sidebar toggle (state-based)
2. Staggered card entrance (query + stagger)
3. Route transitions (fade)
4. Animated notification toasts (enter/leave)
5. Expandable stat panels (keyframes)

### animations/dashboard-animations.ts — Centralized Animation Library

```typescript
// src/app/animations/dashboard-animations.ts

import {
  trigger, state, style, transition, animate,
  query, stagger, keyframes, group, sequence,
  animation, useAnimation
} from '@angular/animations';

// ============================================================
// REUSABLE ANIMATION PRIMITIVES
// ============================================================

export const fadeAnimation = animation([
  style({ opacity: '{{ startOpacity }}' }),
  animate('{{ duration }}', style({ opacity: '{{ endOpacity }}' }))
], { params: { startOpacity: '0', endOpacity: '1', duration: '300ms ease-out' } });

export const slideAnimation = animation([
  style({ transform: 'translateX({{ startX }})' }),
  animate('{{ duration }}', style({ transform: 'translateX(0)' }))
], { params: { startX: '-100%', duration: '300ms ease-out' } });

// ============================================================
// 1. SIDEBAR TOGGLE ANIMATION
// ============================================================
export const sidebarAnimation = trigger('sidebarState', [

  state('open', style({
    width: '250px',     // ← Full sidebar width
    opacity: 1,
    overflow: 'hidden'  // ← Clip content during animation
  })),

  state('closed', style({
    width: '0px',       // ← Completely collapsed
    opacity: 0,
    overflow: 'hidden'
  })),

  // Opening: first expand width, then fade in content
  transition('closed => open', [
    animate('350ms cubic-bezier(0.25, 0.8, 0.25, 1)') // ← Width + opacity together
  ]),

  // Closing: fade out content then collapse width
  transition('open => closed', [
    animate('250ms cubic-bezier(0.4, 0, 1, 1)')
  ])
]);

// ============================================================
// 2. DASHBOARD CARDS STAGGERED ENTRANCE
// ============================================================
export const cardsContainerAnimation = trigger('cardsContainer', [
  transition('* => *', [

    // 2a. Handle cards leaving (if any)
    query(':leave', [
      animate('200ms ease-in', style({ opacity: 0, transform: 'scale(0.95)' }))
    ], { optional: true }),

    // 2b. Handle cards entering (staggered)
    query(':enter', [
      style({ opacity: 0, transform: 'translateY(20px)' }), // ← All cards start invisible + below
      stagger('60ms', [             // ← Each card appears 60ms after previous
        animate('400ms cubic-bezier(0.25, 0.8, 0.25, 1)', style({
          opacity: 1,
          transform: 'translateY(0)'  // ← Rise to natural position
        }))
      ])
    ], { optional: true })
  ])
]);

// ============================================================
// 3. ROUTE FADE TRANSITION
// ============================================================
export const routeFadeAnimation = trigger('routeFade', [
  transition('* <=> *', [
    group([
      // Old route fades out
      query(':leave', [
        animate('200ms ease-in', style({ opacity: 0 }))
      ], { optional: true }),

      // New route fades in (slightly delayed to let old finish first)
      query(':enter', [
        style({ opacity: 0 }),
        animate('300ms 150ms ease-out', style({ opacity: 1 }))
      ], { optional: true })
    ])
  ])
]);

// ============================================================
// 4. NOTIFICATION TOAST ANIMATION
// ============================================================
export const toastAnimation = trigger('toast', [
  // Enter: slide down from top + fade in
  transition(':enter', [
    style({ transform: 'translateY(-100%)', opacity: 0 }),
    animate('300ms cubic-bezier(0.25, 0.8, 0.25, 1)', style({
      transform: 'translateY(0)',
      opacity: 1
    }))
  ]),

  // Leave: slide right + fade out
  transition(':leave', [
    animate('200ms ease-in', style({
      transform: 'translateX(110%)', // ← Swipe out to the right (like dismissing)
      opacity: 0
    }))
  ])
]);

// ============================================================
// 5. STAT PANEL EXPAND ANIMATION (with keyframes for bounce)
// ============================================================
export const panelExpandAnimation = trigger('panelExpand', [
  state('collapsed', style({
    height: '60px',      // ← Just the header
    overflow: 'hidden'
  })),

  state('expanded', style({
    height: '*',         // ← '*' means: use the element's natural height
    overflow: 'hidden'
  })),

  transition('collapsed => expanded', [
    animate('400ms', keyframes([
      style({ height: '60px', offset: 0 }),
      style({ height: '{{ naturalHeight }}', offset: 0.7 }), // ← Slightly overshoot... wait, better simpler:
      style({ height: '*', offset: 1 })
      // Note: for a true bounce you'd use a fixed pixel value
      // '*' = auto height is best for the end state only
    ]))
  ]),

  // Simpler non-keyframe version:
  transition('expanded => collapsed', [
    animate('300ms ease-in', style({ height: '60px' }))
  ])
]);

// Cleaner stat panel (without keyframes for height):
export const statPanelAnimation = trigger('statPanel', [
  state('collapsed', style({ maxHeight: '60px', overflow: 'hidden' })),
  state('expanded', style({ maxHeight: '500px', overflow: 'hidden' })),
  transition('collapsed <=> expanded', animate('350ms ease-in-out'))
]);

// ============================================================
// 6. NOTIFICATION BADGE BOUNCE
// ============================================================
export const badgeBounceAnimation = trigger('badgeBounce', [
  transition(':enter', [
    animate('500ms', keyframes([
      style({ transform: 'scale(0)', opacity: 0, offset: 0 }),
      style({ transform: 'scale(1.3)', opacity: 1, offset: 0.5 }),
      style({ transform: 'scale(0.9)', offset: 0.75 }),
      style({ transform: 'scale(1)', offset: 1 })
    ]))
  ]),
  transition(':leave', [
    animate('150ms ease-in', style({ transform: 'scale(0)', opacity: 0 }))
  ])
]);
```

### dashboard.component.ts — Putting It All Together

```typescript
// src/app/dashboard/dashboard.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import {
  sidebarAnimation,
  cardsContainerAnimation,
  toastAnimation,
  statPanelAnimation,
  badgeBounceAnimation
} from '../animations/dashboard-animations';

interface DashboardCard {
  id: number;
  title: string;
  value: string;
  trend: string;
  icon: string;
  panelState: 'collapsed' | 'expanded';
}

interface Toast {
  id: number;
  message: string;
  type: 'success' | 'error' | 'info' | 'warning';
}

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  animations: [
    sidebarAnimation,          // ← Sidebar open/close
    cardsContainerAnimation,   // ← Staggered card entrance
    toastAnimation,            // ← Toast enter/leave
    statPanelAnimation,        // ← Panel expand/collapse
    badgeBounceAnimation       // ← Notification badge bounce
  ]
})
export class DashboardComponent implements OnInit, OnDestroy {

  // ── Sidebar State ──────────────────────────────────────────
  sidebarState: 'open' | 'closed' = 'open';

  toggleSidebar(): void {
    this.sidebarState = this.sidebarState === 'open' ? 'closed' : 'open';
    // ← Changes state → sidebarAnimation fires automatically
  }

  // ── Dashboard Cards ────────────────────────────────────────
  cards: DashboardCard[] = [];
  cardCount = 0;

  loadCards(): void {
    const newCards: DashboardCard[] = [
      { id: ++this.cardCount, title: 'Total Revenue', value: '$48,295', trend: '+12%', icon: '💰', panelState: 'collapsed' },
      { id: ++this.cardCount, title: 'Active Users', value: '1,429', trend: '+5%', icon: '👥', panelState: 'collapsed' },
      { id: ++this.cardCount, title: 'Conversions', value: '284', trend: '+8%', icon: '🎯', panelState: 'collapsed' },
      { id: ++this.cardCount, title: 'Avg. Session', value: '4m 32s', trend: '-2%', icon: '⏱️', panelState: 'collapsed' },
    ];
    this.cards = newCards;
    // ← cardsContainerAnimation detects :enter and staggers the reveal
  }

  togglePanel(card: DashboardCard): void {
    card.panelState = card.panelState === 'collapsed' ? 'expanded' : 'collapsed';
    // ← statPanelAnimation fires: collapses → expands (or vice versa)
  }

  trackCardById(index: number, card: DashboardCard): number {
    return card.id;
  }

  // ── Toast Notifications ────────────────────────────────────
  toasts: Toast[] = [];
  toastIdCounter = 0;

  showToast(message: string, type: Toast['type'] = 'info'): void {
    const toast: Toast = { id: ++this.toastIdCounter, message, type };
    this.toasts.push(toast);
    // ← toastAnimation :enter fires (slide down from top)

    // Auto-dismiss after 3 seconds
    setTimeout(() => this.dismissToast(toast.id), 3000);
  }

  dismissToast(id: number): void {
    this.toasts = this.toasts.filter(t => t.id !== id);
    // ← toastAnimation :leave fires (slide out to right) THEN removed from DOM
  }

  // ── Notification Badge ─────────────────────────────────────
  notificationCount = 0;

  addNotification(): void {
    this.notificationCount++;
    this.showToast(`New notification! (${this.notificationCount} total)`, 'info');
    // ← Badge pops in with bounce when notificationCount goes 0 → 1
  }

  clearNotifications(): void {
    this.notificationCount = 0;
    // ← Badge leaves DOM with pop animation when notificationCount goes >0 → 0
  }

  ngOnInit(): void {
    this.loadCards();
    // Simulate a welcome notification
    setTimeout(() => this.showToast('Dashboard loaded successfully!', 'success'), 500);
  }

  ngOnDestroy(): void {
    // Clear any pending timeouts in a real app
  }
}
```

### dashboard.component.html — The Template

```html
<!-- src/app/dashboard/dashboard.component.html -->
<div class="dashboard-layout">

  <!-- ── SIDEBAR ── -->
  <!--
    [@sidebarState]="sidebarState"
    Binds to the sidebarAnimation trigger.
    When sidebarState changes 'open'↔'closed', the animation fires.
  -->
  <aside
    [@sidebarState]="sidebarState"
    class="sidebar">
    <nav class="sidebar-nav">
      <a routerLink="/dashboard/overview">Overview</a>
      <a routerLink="/dashboard/analytics">Analytics</a>
      <a routerLink="/dashboard/settings">Settings</a>
    </nav>
  </aside>

  <!-- ── MAIN CONTENT ── -->
  <main class="main-content">

    <!-- ── HEADER ── -->
    <header class="dashboard-header">
      <button (click)="toggleSidebar()" class="sidebar-toggle">
        {{ sidebarState === 'open' ? '◀ Close' : '▶ Open' }}
      </button>

      <h1>Dashboard</h1>

      <!-- NOTIFICATION BELL WITH ANIMATED BADGE -->
      <div class="notification-bell">
        <button (click)="addNotification()">🔔 Bell</button>

        <!--
          *ngIf="notificationCount > 0" — badge only exists when there are notifications
          [@badgeBounce] — fires :enter when badge appears, :leave when it disappears
        -->
        <span
          *ngIf="notificationCount > 0"
          [@badgeBounce]
          class="notification-badge"
          (click)="clearNotifications()">
          {{ notificationCount }}
        </span>
      </div>
    </header>

    <!-- ── STAT CARDS GRID ── -->
    <!--
      [@cardsContainer]="cards.length"
      The trigger is on the CONTAINER, not individual cards.
      When cards.length changes, the transition fires,
      then query(':enter') selects the new card elements.
    -->
    <div
      [@cardsContainer]="cards.length"
      class="cards-grid">

      <div
        *ngFor="let card of cards; trackBy: trackCardById"
        class="stat-card"
        [class.expanded]="card.panelState === 'expanded'">

        <!-- Card Header (always visible) -->
        <div class="card-header" (click)="togglePanel(card)">
          <span class="card-icon">{{ card.icon }}</span>
          <h3>{{ card.title }}</h3>
          <span class="card-trend">{{ card.trend }}</span>
          <span class="expand-icon">
            {{ card.panelState === 'collapsed' ? '▼' : '▲' }}
          </span>
        </div>

        <!-- Card Body (animated expand/collapse) -->
        <!--
          [@statPanel]="card.panelState"
          Binds to statPanelAnimation.
          When panelState changes 'collapsed'↔'expanded', maxHeight animates.
        -->
        <div
          [@statPanel]="card.panelState"
          class="card-body">
          <div class="card-value">{{ card.value }}</div>
          <div class="card-details">
            <p>30-day performance data</p>
            <p>Last updated: just now</p>
          </div>
        </div>

      </div>
    </div>

    <!-- ── ACTION BUTTONS ── -->
    <div class="action-buttons">
      <button (click)="loadCards()">Reload Cards</button>
      <button (click)="showToast('Test message', 'success')">Show Success Toast</button>
      <button (click)="showToast('Something went wrong!', 'error')">Show Error Toast</button>
    </div>

  </main>

</div>

<!-- ── TOAST NOTIFICATIONS (fixed position, outside main layout) ── -->
<div class="toast-container">
  <!--
    *ngFor iterates toasts
    [@toast] provides enter/leave animation for each toast
    (@toast.done)="..." is NOT needed here (auto-dismiss is via setTimeout)
  -->
  <div
    *ngFor="let toast of toasts; trackBy: trackToastById"
    [@toast]
    [class]="'toast toast-' + toast.type"
    (click)="dismissToast(toast.id)">
    {{ toast.message }}
    <span class="toast-close">×</span>
  </div>
</div>
```

### dashboard.component.css — Minimal Styles

```css
/* dashboard.component.css */
.dashboard-layout {
  display: flex;
  height: 100vh;
  overflow: hidden;  /* ← Important: clips sidebar during animation */
}

.sidebar {
  background: #1a1a2e;
  color: white;
  flex-shrink: 0;   /* ← Prevents sidebar from being squeezed by main content */
  /* Width is controlled by the animation trigger — don't set fixed width here! */
}

.sidebar-nav a {
  display: block;
  padding: 12px 20px;
  color: rgba(255,255,255,0.8);
  text-decoration: none;
}

.main-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f5f5f5;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
  margin: 20px 0;
}

.stat-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  overflow: hidden;  /* ← Required for expand animation to clip properly */
}

.card-header {
  display: flex;
  align-items: center;
  padding: 16px;
  cursor: pointer;
  user-select: none;
}

.card-body {
  overflow: hidden;  /* ← Required for max-height animation to work */
  padding: 0 16px;  /* ← Horizontal padding only, vertical is animated */
}

.card-value {
  font-size: 2em;
  font-weight: bold;
  padding: 8px 0;
}

.notification-bell {
  position: relative;
  display: inline-block;
}

.notification-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: #e53935;
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  cursor: pointer;
}

/* Toast container - fixed at top right */
.toast-container {
  position: fixed;
  top: 16px;
  right: 16px;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  gap: 8px;
  overflow: hidden;  /* ← Required for toast slide animation */
}

.toast {
  padding: 12px 16px;
  border-radius: 4px;
  cursor: pointer;
  min-width: 280px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}

.toast-success { background: #43a047; color: white; }
.toast-error   { background: #e53935; color: white; }
.toast-info    { background: #1e88e5; color: white; }
.toast-warning { background: #fb8c00; color: white; }

/* Animation hint: these elements will be animated */
.sidebar, .stat-card, .toast {
  will-change: transform, opacity; /* ← Hint to browser: GPU-accelerate these */
}
```

---

## 16.18 Summary

### What You've Learned in Phase 16

```
Angular Animations — Complete Mental Map:

                         @angular/animations
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
    SETUP             BUILDING BLOCKS         ADVANCED
          │                   │                   │
   ┌──────┴──────┐    ┌────────┴────────┐   ┌─────┴──────┐
   │BrowserAnims │    │trigger()        │   │query()     │
   │Module       │    │state()          │   │stagger()   │
   │provideAnim- │    │style()          │   │keyframes() │
   │ations()     │    │transition()     │   │group()     │
   │provideAnim- │    │animate()        │   │sequence()  │
   │ationsAsync()│    │:enter / :leave  │   │animation() │
   │NoopAnims    │    │void / *         │   │useAnimation│
   └─────────────┘    └─────────────────┘   └────────────┘
                                │
                        ┌───────┴───────┐
                        │               │
                   PROGRAMMATIC     CALLBACKS
                        │               │
               ┌────────┴────┐   ┌──────┴──────┐
               │AnimBuilder  │   │@trigger.start│
               │AnimFactory  │   │@trigger.done │
               │AnimPlayer   │   │AnimationEvent│
               └─────────────┘   └─────────────┘
```

### Key Principles to Remember

| Principle | Rule | Why |
|---|---|---|
| **GPU First** | Animate `transform` and `opacity` only | No layout recalculation |
| **trackBy is required** | Always use `trackBy` with `*ngFor` + animations | Prevents all-items re-animation |
| **optional: true** | Always add `{ optional: true }` to `query()` | Prevents errors when no children match |
| **:enter / :leave shorthand** | Prefer `:enter` over `'void => *'` | More readable |
| **Player cleanup** | Always call `player.destroy()` in `ngOnDestroy()` | Prevents memory leaks |
| **Reuse animations** | Use `animation()` + `useAnimation()` | DRY, consistent |
| **NoopAnimations for tests** | Use `NoopAnimationsModule` in tests | No timing issues |
| **duration guidelines** | UI interactions: 150-300ms, routes: 300-500ms | User perception sweet spot |

### Common Gotchas Quick Reference

```
Gotcha 1: Animation not working?
  → Is BrowserAnimationsModule imported? (or provideAnimations() in providers?)
  → Is the trigger name in [@triggerName] matching the trigger() name exactly?

Gotcha 2: List animations not working?
  → Are you using trackBy in *ngFor?
  → Is the trigger on the CONTAINER (parent), not the items, when using query()?
  → Did you add { optional: true } to query()?

Gotcha 3: Leave animation not completing?
  → Angular waits for :leave to finish. Check for errors in console.
  → Make sure the :leave animation has a finite duration (not '0s')

Gotcha 4: Slide animation breaks layout?
  → Do you have position: absolute on both :enter and :leave in route animations?
  → Does the container have position: relative and overflow: hidden?

Gotcha 5: Animation fires multiple times?
  → Each change to the trigger expression fires a transition
  → Make sure state values aren't constantly changing

Gotcha 6: Animations in tests are flaky?
  → Switch to NoopAnimationsModule in TestBed configuration
```

### Phase 16 Checklist

Before moving on, verify you can:
- [ ] Set up `BrowserAnimationsModule` and `provideAnimations()`
- [ ] Write a state-based animation with `trigger()`, `state()`, `style()`, `transition()`, `animate()`
- [ ] Use `:enter` and `:leave` for element enter/leave animations with `*ngIf` and `*ngFor`
- [ ] Apply `keyframes()` for multi-step animations (bounce, shake, pulse)
- [ ] Coordinate animations with `group()` (parallel) and `sequence()` (sequential)
- [ ] Animate child elements with `query()` and `stagger()`
- [ ] Implement route transition animations
- [ ] Create reusable animations with `animation()` and `useAnimation()`
- [ ] Use `AnimationBuilder` for programmatic animations
- [ ] Handle animation callbacks with `(@trigger.start)` and `(@trigger.done)`
- [ ] Choose `transform`/`opacity` over layout-triggering properties for performance
- [ ] Use `NoopAnimationsModule` in unit tests

---

> **Next Phase:** [Phase 17: Internationalization (i18n) & Localization](Phase17-i18n-Localization.md)
