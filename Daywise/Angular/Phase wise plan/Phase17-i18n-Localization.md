# Phase 17: Internationalization (i18n) & Localization

> Your app speaks English fluently — but the world speaks 7,000+ languages. Internationalization is the engineering discipline that lets your Angular app speak them all. A truly global product is not translated after the fact; it is *designed* from the start to carry meaning across every culture, calendar system, and writing direction on Earth.

---

## 17.1 Why i18n Matters

### The Problem: Building Only for One Language

Imagine you have built a beautiful e-commerce app. Every label, button, error message, and date is hard-coded in English. Then your company decides to expand to Germany, Japan, and Brazil. What happens?

```
Without i18n planning:
  "Submit Order" is buried in 47 different TypeScript files
  Date "12/05/2024" means December 5 in the US but May 12 in Europe
  "$1,234.56" means nothing to a user who expects "1.234,56 €"
  Arabic and Hebrew users see text flowing the wrong direction
  Your app shows "1 items" instead of "1 item" (pluralization bug)
  Result: emergency refactor that touches every file in the codebase
```

```
With i18n planning from day one:
  Every user-facing string is in a translation key
  Dates, numbers, currencies render according to locale settings
  Layout adapts automatically to RTL languages
  Translators use a proper workflow (not grep-and-replace)
  Adding a new language is a configuration change, not a code change
```

### The Restaurant Menu Analogy

Think of your app like a restaurant that wants to serve an international clientele.

```
┌─────────────────────────────────────────────────────────────────────┐
│                      THE GLOBAL RESTAURANT                          │
│                                                                     │
│  INTERNATIONALIZATION (i18n) = Building the kitchen infrastructure  │
│  ─────────────────────────────────────────────────────────────────  │
│  • The kitchen can cook any dish (template structure)               │
│  • Menus are stored as data, not printed on the walls               │
│  • Staff can swap the menu book at any time                         │
│  • Oven works for every cuisine (Unicode support)                   │
│                                                                     │
│  LOCALIZATION (l10n) = Writing each language's menu                 │
│  ─────────────────────────────────────────────────────────────────  │
│  • Spanish menu: "Filete de ternera con patatas"                    │
│  • Japanese menu: "じゃがいも添えビーフステーキ"                       │
│  • Arabic menu: right-to-left text, different portion names         │
│  • Prices shown in local currency with local formatting             │
└─────────────────────────────────────────────────────────────────────┘
```

The restaurant (your app) only needs ONE kitchen (codebase). Each language's menu (locale file) plugs into that kitchen.

### i18n vs l10n: The Critical Distinction

| Concept | Full Name | What It Means | Who Does It | Example |
|---|---|---|---|---|
| **i18n** | Internationalization (18 letters between i and n) | Making the *app* capable of supporting multiple languages — the engineering work | Developers | Wrapping text in `i18n` attributes, setting up build pipeline |
| **l10n** | Localization (10 letters between l and n) | Providing the *actual translations and cultural adaptations* for a specific locale | Translators + Designers | Writing "Enviar pedido" for Spanish, using `€` symbol |
| **g11n** | Globalization | The full business process of i18n + l10n combined | Product teams | Planning, executing, and shipping globally |
| **a11y** | Accessibility | Making apps usable for everyone regardless of ability | Developers | (Related discipline, often co-considered with i18n) |

### The Business Case

```
Global internet users by language (approximate):
┌──────────────────────────────────────────────────┐
│ English     ████████████████  25.9%              │
│ Chinese     ████████████████  19.4%              │
│ Spanish     ████████           8.1%              │
│ Arabic      ██████             4.8%              │
│ Portuguese  █████              3.9%              │
│ Indonesian  ████               3.3%              │
│ French      ████               3.0%              │
│ Japanese    ████               2.6%              │
│ Russian     ████               2.6%              │
│ Others      ████████████████  26.4%              │
└──────────────────────────────────────────────────┘

If your app only speaks English, you are invisible to 74% of the web.
```

---

## 17.2 Angular's Built-in i18n (@angular/localize)

### How Angular's i18n Works — The Big Picture

Angular's built-in i18n uses a **build-time** approach: you mark strings in your templates, extract them into a translation file, have translators fill in the translations, then build separate bundles for each locale.

```
┌───────────────────────────────────────────────────────────────────────┐
│                   ANGULAR i18n BUILD-TIME FLOW                        │
│                                                                       │
│  1. MARK         2. EXTRACT       3. TRANSLATE     4. BUILD           │
│  ─────────       ───────────      ───────────      ─────────          │
│  Add i18n        ng extract-i18n  Translators      ng build           │
│  attributes  →   generates    →   fill in      →   --localize         │
│  to templates    messages.xlf     target text       creates           │
│                                                     dist/en/          │
│                                                     dist/es/          │
│                                                     dist/ar/          │
└───────────────────────────────────────────────────────────────────────┘
```

### Step 1: Install @angular/localize

```bash
# Add @angular/localize to the project
# This modifies polyfills.ts and package.json automatically
ng add @angular/localize

# What this command does under the hood:
# 1. npm install @angular/localize
# 2. Adds import '@angular/localize/init'; to polyfills.ts
# 3. Updates angular.json with i18n settings
```

After installation, verify your `polyfills.ts` contains:

```typescript
// polyfills.ts
import '@angular/localize/init';  // ← MUST be here — enables $localize globally
```

### Step 2: Marking Text in Templates with `i18n`

The `i18n` attribute is how you tell Angular "this text needs translation."

```html
<!-- product-card.component.html -->

<!-- BASIC TEXT MARKING — simplest form -->
<h1 i18n>Welcome to our store</h1>
<!-- ↑ The i18n attribute tells the extractor: "this text is translatable"
     The text "Welcome to our store" becomes the SOURCE text in the translation file -->

<!-- PARAGRAPH TEXT -->
<p i18n>
  Your order has been placed successfully.
  You will receive a confirmation email shortly.
</p>
<!-- ↑ Multi-line text is fine — whitespace is normalized -->

<!-- BUTTON TEXT -->
<button i18n>Add to Cart</button>

<!-- WITHOUT i18n — this text will NOT be translated -->
<span class="product-id">SKU-12345</span>
<!-- ↑ No i18n attribute means no extraction — good for dynamic data, IDs, etc. -->
```

### Marking Attributes with i18n-*

Text attributes like `placeholder`, `title`, `aria-label`, and `alt` need translation too. You mark them with `i18n-attributeName`.

```html
<!-- form-field.component.html -->

<!-- PLACEHOLDER ATTRIBUTE -->
<input
  type="text"
  i18n-placeholder
  placeholder="Search for products..."
  class="search-input"
/>
<!-- ↑ i18n-placeholder extracts the placeholder value separately -->

<!-- TITLE ATTRIBUTE (tooltip) -->
<button
  i18n-title
  title="Click to add item to your shopping cart"
  (click)="addToCart()"
>
  <mat-icon>shopping_cart</mat-icon>
</button>

<!-- ARIA-LABEL for accessibility -->
<nav
  i18n-aria-label
  aria-label="Main navigation menu"
>
  <!-- nav items -->
</nav>

<!-- ALT TEXT for images -->
<img
  src="/assets/hero.jpg"
  i18n-alt
  alt="Happy customers using our product"
/>

<!-- MULTIPLE ATTRIBUTES — mark each one separately -->
<input
  type="email"
  i18n-placeholder
  placeholder="Enter your email"
  i18n-title
  title="We will send a confirmation to this email"
/>
```

### Custom IDs with `@@id`

By default Angular generates message IDs from the text content. Custom IDs give you stable identifiers that don't change when wording is tweaked.

```html
<!-- Without custom ID — ID is auto-generated from the text hash -->
<h1 i18n>Welcome back!</h1>
<!-- Generates ID like: "3782938492847" — opaque and changes if text changes -->

<!-- WITH custom ID — stable, human-readable -->
<h1 i18n="@@welcomeHeading">Welcome back!</h1>
<!--    ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
        @@ prefix signals a custom ID
        The ID "welcomeHeading" will appear in the XLF file
        Even if you change "Welcome back!" to "Hello again!", the ID stays the same
        Translators already have the translation — no re-work needed -->

<!-- More custom IDs -->
<p i18n="@@orderConfirmation">Your order has been confirmed.</p>
<button i18n="@@addToCartButton">Add to Cart</button>
<span i18n="@@outOfStockLabel">Out of Stock</span>
```

### Meaning and Description for Translators

Translators need context! The full `i18n` attribute format is:
`i18n="meaning|description@@id"`

```html
<!-- FULL FORMAT: meaning | description @@ id -->

<!-- The word "Save" is ambiguous — does it mean save money or save a file? -->
<button i18n="user action|Save changes to the user profile form@@saveProfileButton">
  Save
</button>
<!--
  meaning:     "user action"
  description: "Save changes to the user profile form"
  id:          "saveProfileButton"

  In the XLF file, translators will see:
    <note from="description">Save changes to the user profile form</note>
    <note from="meaning">user action</note>
  This eliminates ambiguity!
-->

<!-- Another example: "Back" as navigation vs physical back -->
<a i18n="navigation|Go back to the previous page in the breadcrumb@@backLink">
  Back
</a>

<!-- "Post" as in "Post a comment" (verb) vs "Post" as in "mail post" -->
<button i18n="forum action|Publish a new comment to the forum@@postCommentButton">
  Post
</button>

<!-- Description only (no meaning) -->
<h2 i18n="The heading displayed on the checkout page@@checkoutHeading">
  Checkout
</h2>

<!-- ID only (most common for clearly named strings) -->
<p i18n="@@emptyCartMessage">Your cart is empty.</p>
```

### Complete Page Marked for Translation

```html
<!-- checkout.component.html — Fully marked for i18n -->

<div class="checkout-page">

  <!-- PAGE TITLE -->
  <h1 i18n="page heading|The main heading of the checkout page@@checkoutTitle">
    Checkout
  </h1>

  <!-- SECTION HEADINGS -->
  <section class="shipping-section">
    <h2 i18n="@@shippingAddressHeading">Shipping Address</h2>

    <form [formGroup]="shippingForm">
      <!-- FORM LABELS -->
      <label for="firstName" i18n="@@firstNameLabel">First Name</label>
      <input
        id="firstName"
        formControlName="firstName"
        i18n-placeholder="@@firstNamePlaceholder"
        placeholder="Enter your first name"
      />

      <label for="lastName" i18n="@@lastNameLabel">Last Name</label>
      <input
        id="lastName"
        formControlName="lastName"
        i18n-placeholder="@@lastNamePlaceholder"
        placeholder="Enter your last name"
      />

      <label for="email" i18n="@@emailLabel">Email Address</label>
      <input
        id="email"
        type="email"
        formControlName="email"
        i18n-placeholder="@@emailPlaceholder"
        placeholder="your@email.com"
        i18n-title="@@emailTitle"
        title="We will send your order confirmation to this email"
      />
    </form>
  </section>

  <section class="order-summary">
    <h2 i18n="@@orderSummaryHeading">Order Summary</h2>

    <div *ngFor="let item of cartItems" class="cart-item">
      <span class="item-name">{{ item.name }}</span>
      <!-- NOTE: Dynamic data (prices, quantities) is NOT marked for i18n
           The NUMBER 29.99 is data, not a string to translate.
           Use pipes (CurrencyPipe, DecimalPipe) for locale formatting. -->
      <span class="item-price">{{ item.price | currency }}</span>
    </div>

    <div class="total-row">
      <span i18n="@@totalLabel">Total</span>
      <span class="total-amount">{{ totalPrice | currency }}</span>
    </div>
  </section>

  <!-- BUTTONS -->
  <div class="action-buttons">
    <button
      type="button"
      class="btn-secondary"
      i18n="navigation action|Return to the previous shopping cart page@@backToCartButton"
    >
      Back to Cart
    </button>

    <button
      type="submit"
      class="btn-primary"
      [disabled]="shippingForm.invalid"
      i18n="purchase action|Complete the purchase and place the order@@placeOrderButton"
    >
      Place Order
    </button>
  </div>

  <!-- TRUST SIGNALS -->
  <p
    class="security-note"
    i18n="trust message|Informs customer their payment is secure@@securePaymentNote"
  >
    Your payment information is encrypted and secure.
  </p>

</div>
```

---

## 17.3 Extracting Translation Files

### The Extraction Command

After marking your templates, you extract all the marked strings into a translation source file:

```bash
# Basic extraction — outputs to src/locale/messages.xlf (XLIFF 1.2 format)
ng extract-i18n

# Specify output directory
ng extract-i18n --output-path src/locale

# Choose format (xlf = XLIFF 1.2, xlf2 = XLIFF 2.0, xmb = XML Message Bundle)
ng extract-i18n --output-path src/locale --format xlf

# Choose output file name
ng extract-i18n --output-path src/locale --out-file messages.xlf

# Full command with all options
ng extract-i18n \
  --output-path src/locale \
  --format xlf2 \
  --out-file messages.en.xlf
```

### Output Format Comparison

| Format | Flag | File Extension | Used By | Notes |
|---|---|---|---|---|
| **XLIFF 1.2** | `--format xlf` | `.xlf` | Angular default, most tools | Most widely supported |
| **XLIFF 2.0** | `--format xlf2` | `.xlf` | Newer tools | Smaller file size, stricter spec |
| **XMB** | `--format xmb` | `.xmb` | Google Closure, some CAT tools | Less common |

### Understanding the Generated messages.xlf File

```xml
<!-- src/locale/messages.xlf — Auto-generated by ng extract-i18n -->
<?xml version="1.0" encoding="UTF-8" ?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
  <file
    source-language="en-US"
    datatype="plaintext"
    original="ng2"
  >
    <body>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- TRANSLATION UNIT — one <trans-unit> per i18n string     -->
      <!-- ═══════════════════════════════════════════════════════ -->

      <!-- Unit with custom ID @@checkoutTitle -->
      <trans-unit id="checkoutTitle" datatype="html">
        <!-- SOURCE: the original English text from your template -->
        <source>Checkout</source>
        <!-- NOTE: from "description" — what you wrote as the i18n description -->
        <note priority="1" from="description">
          The main heading of the checkout page
        </note>
        <!-- NOTE: from "meaning" — the meaning context -->
        <note priority="1" from="meaning">page heading</note>
      </trans-unit>

      <!-- Unit without custom ID — auto-generated hash ID -->
      <trans-unit id="4678324789234789234" datatype="html">
        <source>Add to Cart</source>
      </trans-unit>

      <!-- Unit with placeholder for dynamic content -->
      <trans-unit id="welcomeUser" datatype="html">
        <source>Welcome, <x id="INTERPOLATION" equiv-text="{{ userName }}"/>!</source>
        <!-- ↑ Dynamic values become <x> placeholders in the XLF file
               Translators MUST keep the <x> element in their translation
               They only translate the surrounding text -->
      </trans-unit>

      <!-- Unit from an attribute (i18n-placeholder) -->
      <trans-unit id="firstNamePlaceholder" datatype="html">
        <source>Enter your first name</source>
        <!-- Note: extracted from placeholder attribute, not element content -->
        <context-group purpose="location">
          <context context-type="sourcefile">
            src/app/checkout/checkout.component.html
          </context>
          <context context-type="linenumber">24</context>
        </context-group>
      </trans-unit>

      <!-- Unit with ICU plural (explained in 17.7) -->
      <trans-unit id="cartItemCount" datatype="html">
        <source>
          {VAR_PLURAL, plural,
            =0 {No items}
            =1 {One item}
            other {<x id="INTERPOLATION"/> items}
          }
        </source>
      </trans-unit>

    </body>
  </file>
</xliff>
```

### Key Elements of a Translation Unit

| Element | Purpose | Who Uses It |
|---|---|---|
| `<trans-unit id="...">` | Container for one translatable string | Framework |
| `<source>` | The original English text | Reference for translators |
| `<target>` | The translated text (ADDED by translators) | Framework reads at build time |
| `<note from="description">` | Context you provided in `i18n="description"` | Translators |
| `<note from="meaning">` | Meaning you provided in `i18n="meaning|..."` | Translators |
| `<context-group>` | File path and line number where this string lives | Developers |
| `<x id="INTERPOLATION">` | Placeholder for `{{ expression }}` in the template | Translators (must keep it) |

---

## 17.4 Creating Translation Files

### The Workflow

```
┌────────────────────────────────────────────────────────────────────┐
│               TRANSLATION FILE CREATION WORKFLOW                   │
│                                                                    │
│  1. Generate source:  ng extract-i18n → messages.xlf              │
│                                                                    │
│  2. Copy for each locale:                                          │
│     cp messages.xlf messages.es.xlf   (Spanish)                   │
│     cp messages.xlf messages.fr.xlf   (French)                    │
│     cp messages.xlf messages.ar.xlf   (Arabic)                    │
│     cp messages.xlf messages.de.xlf   (German)                    │
│                                                                    │
│  3. Send copies to translators (or translation platform)          │
│                                                                    │
│  4. Translators add <target> elements                             │
│                                                                    │
│  5. Build with ng build --localize                                │
└────────────────────────────────────────────────────────────────────┘
```

### English Source File (messages.xlf)

```xml
<!-- src/locale/messages.xlf — The source (auto-generated) -->
<?xml version="1.0" encoding="UTF-8" ?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
  <file source-language="en-US" datatype="plaintext" original="ng2">
    <body>

      <trans-unit id="checkoutTitle" datatype="html">
        <source>Checkout</source>
        <note priority="1" from="description">
          The main heading of the checkout page
        </note>
      </trans-unit>

      <trans-unit id="addToCartButton" datatype="html">
        <source>Add to Cart</source>
        <note priority="1" from="description">
          Button to add the current product to the shopping cart
        </note>
      </trans-unit>

      <trans-unit id="emptyCartMessage" datatype="html">
        <source>Your cart is empty.</source>
      </trans-unit>

      <trans-unit id="placeOrderButton" datatype="html">
        <source>Place Order</source>
      </trans-unit>

      <trans-unit id="securePaymentNote" datatype="html">
        <source>Your payment information is encrypted and secure.</source>
      </trans-unit>

      <trans-unit id="outOfStockLabel" datatype="html">
        <source>Out of Stock</source>
      </trans-unit>

    </body>
  </file>
</xliff>
```

### Spanish Translation (messages.es.xlf)

```xml
<!-- src/locale/messages.es.xlf — Spanish translations -->
<?xml version="1.0" encoding="UTF-8" ?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
  <file
    source-language="en-US"
    target-language="es"   <!-- ← Specify the target locale -->
    datatype="plaintext"
    original="ng2"
  >
    <body>

      <trans-unit id="checkoutTitle" datatype="html">
        <source>Checkout</source>
        <target>Finalizar compra</target>
        <!-- ↑ <target> element added by the translator
               The English source stays for reference
               Angular uses ONLY the <target> value at build time -->
      </trans-unit>

      <trans-unit id="addToCartButton" datatype="html">
        <source>Add to Cart</source>
        <target>Añadir al carrito</target>
      </trans-unit>

      <trans-unit id="emptyCartMessage" datatype="html">
        <source>Your cart is empty.</source>
        <target>Tu carrito está vacío.</target>
      </trans-unit>

      <trans-unit id="placeOrderButton" datatype="html">
        <source>Place Order</source>
        <target>Realizar pedido</target>
      </trans-unit>

      <trans-unit id="securePaymentNote" datatype="html">
        <source>Your payment information is encrypted and secure.</source>
        <target>Tu información de pago está cifrada y es segura.</target>
        <!-- ↑ Note: this is longer than English — text expansion is real! -->
      </trans-unit>

      <trans-unit id="outOfStockLabel" datatype="html">
        <source>Out of Stock</source>
        <target>Agotado</target>
      </trans-unit>

    </body>
  </file>
</xliff>
```

### French Translation (messages.fr.xlf)

```xml
<!-- src/locale/messages.fr.xlf — French translations -->
<?xml version="1.0" encoding="UTF-8" ?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
  <file
    source-language="en-US"
    target-language="fr"
    datatype="plaintext"
    original="ng2"
  >
    <body>

      <trans-unit id="checkoutTitle" datatype="html">
        <source>Checkout</source>
        <target>Passer la commande</target>
      </trans-unit>

      <trans-unit id="addToCartButton" datatype="html">
        <source>Add to Cart</source>
        <target>Ajouter au panier</target>
      </trans-unit>

      <trans-unit id="emptyCartMessage" datatype="html">
        <source>Your cart is empty.</source>
        <target>Votre panier est vide.</target>
      </trans-unit>

      <trans-unit id="placeOrderButton" datatype="html">
        <source>Place Order</source>
        <target>Passer commande</target>
      </trans-unit>

      <trans-unit id="securePaymentNote" datatype="html">
        <source>Your payment information is encrypted and secure.</source>
        <target>Vos informations de paiement sont chiffrées et sécurisées.</target>
      </trans-unit>

      <trans-unit id="outOfStockLabel" datatype="html">
        <source>Out of Stock</source>
        <target>Rupture de stock</target>
      </trans-unit>

    </body>
  </file>
</xliff>
```

### Translation Management Tools

For real projects, copy-pasting XLF files quickly becomes unmanageable. These platforms handle the workflow:

| Tool | Type | Key Features | Best For |
|---|---|---|---|
| **Crowdin** | Cloud SaaS | Auto-sync with GitHub, AI suggestions, TM | Large teams, open source |
| **Lokalise** | Cloud SaaS | Real-time collaboration, in-context editing | Enterprise, fast-moving teams |
| **POEditor** | Cloud SaaS | Simple UI, affordable | Small-medium projects |
| **Phrase (Memsource)** | Cloud SaaS | Professional TM, CAT tools | Professional translation agencies |
| **Weblate** | Self-hosted | Open source, Git integration | Privacy-conscious orgs |
| **Transifex** | Cloud SaaS | Best community localization support | Open source communities |

**TM = Translation Memory** — stores previous translations so similar strings don't need re-translating.

---

## 17.5 Building for Multiple Locales

### Configuring angular.json

The `angular.json` file is where you declare all the locales your app supports:

```json
// angular.json — i18n configuration section
{
  "projects": {
    "my-shop": {
      "i18n": {
        // The locale of your source code (what you write in templates)
        "sourceLocale": "en-US",

        // All the additional locales you want to build for
        "locales": {
          "es": {
            // Path to the translation file for Spanish
            "translation": "src/locale/messages.es.xlf",
            // Base href for this locale (used in deployment)
            "baseHref": "/es/"
          },
          "fr": {
            "translation": "src/locale/messages.fr.xlf",
            "baseHref": "/fr/"
          },
          "ar": {
            "translation": "src/locale/messages.ar.xlf",
            "baseHref": "/ar/"
          },
          "de": {
            "translation": "src/locale/messages.de.xlf",
            "baseHref": "/de/"
          },
          "ja": {
            "translation": "src/locale/messages.ja.xlf",
            "baseHref": "/ja/"
          }
        }
      },

      "architect": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/my-shop",
            "index": "src/index.html",
            "main": "src/main.ts",
            "polyfills": "src/polyfills.ts",
            "tsConfig": "tsconfig.app.json",
            // ... other options
            "i18nMissingTranslation": "warning"
            // ↑ What to do if a translation is missing:
            //   "error"   = fail the build (strictest, recommended for production)
            //   "warning" = log a warning but continue (good during development)
            //   "ignore"  = silently fall back to source text
          },
          "configurations": {
            "production": {
              "localize": true,
              // ↑ Build ALL configured locales in production
              "optimization": true,
              "outputHashing": "all"
            },
            "development": {
              // During development, serve ONE locale at a time for speed
              "localize": ["es"],
              // ↑ Only build/serve Spanish during dev
              "optimization": false
            },
            // You can also create per-locale development configs:
            "es": {
              "localize": ["es"]
            },
            "fr": {
              "localize": ["fr"]
            }
          }
        },

        "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "configurations": {
            "production": {
              "buildTarget": "my-shop:build:production"
            },
            "development": {
              "buildTarget": "my-shop:build:development"
            },
            // Serve Spanish during development
            "es": {
              "buildTarget": "my-shop:build:es"
            }
          }
        }
      }
    }
  }
}
```

### Building Commands

```bash
# BUILD ALL LOCALES for production
ng build --configuration=production
# Produces:
#   dist/my-shop/en-US/  (or just dist/my-shop/ if no baseHref)
#   dist/my-shop/es/
#   dist/my-shop/fr/
#   dist/my-shop/ar/
#   dist/my-shop/de/
#   dist/my-shop/ja/

# BUILD SPECIFIC LOCALE (faster during development)
ng build --configuration=es

# SERVE a specific locale during development
ng serve --configuration=es
# Navigate to http://localhost:4200/es/

# CHECK how many translation units need attention
ng build --configuration=es 2>&1 | grep -i missing
```

### Deployment Strategies

```
STRATEGY 1: Path-prefix (most common)
─────────────────────────────────────
myshop.com/         → English (redirect to /en-US/)
myshop.com/en-US/   → English
myshop.com/es/      → Spanish
myshop.com/fr/      → French
myshop.com/ar/      → Arabic

Nginx config:
  location /es/ { root /var/www/my-shop/es; }
  location /fr/ { root /var/www/my-shop/fr; }

Pros:  Simple, single domain, easy SSL
Cons:  SEO impact — Google treats these as different pages of same site

─────────────────────────────────────
STRATEGY 2: Subdomain
─────────────────────────────────────
myshop.com          → English (or auto-detect)
es.myshop.com       → Spanish
fr.myshop.com       → French
ar.myshop.com       → Arabic

Pros:  Search engines can geotarget, cleaner URLs
Cons:  Multiple SSL certs, DNS management complexity

─────────────────────────────────────
STRATEGY 3: Country-code TLD
─────────────────────────────────────
myshop.com          → English (US)
myshop.es           → Spanish
myshop.fr           → French
myshop.de           → German

Pros:  Strongest local SEO signals
Cons:  Expensive (buy every TLD), complex infrastructure

─────────────────────────────────────
STRATEGY 4: Language detection + redirect
─────────────────────────────────────
Server reads Accept-Language header:
  GET / HTTP/1.1
  Accept-Language: es-ES,es;q=0.9,en;q=0.8

  → Redirect 302 to /es/

Pros:  Auto-routes users to their language
Cons:  Must always offer manual override (users travel!)
```

---

## 17.6 $localize Tagged Template (In TypeScript)

### Why You Need This

The `i18n` attribute only works in HTML templates. But what about strings in your TypeScript code — services, component class files, console messages?

```typescript
// THE PROBLEM: translating strings in TypeScript
export class ProductService {
  getErrorMessage(): string {
    // This is in TypeScript — you CAN'T use i18n attribute here!
    return 'Failed to load products. Please try again.';
    // ↑ This will NEVER be translated with just i18n attributes
  }

  getSuccessMessage(count: number): string {
    return `${count} items added to your cart`;
    // ↑ Also not translatable with template i18n alone
  }
}
```

### The Solution: $localize

`$localize` is a tagged template literal that marks strings for extraction in TypeScript files.

```typescript
// product.service.ts
import '@angular/localize/init';
// ↑ This import is usually in polyfills.ts, but shown here for clarity

export class ProductService {

  // BASIC $localize — static string
  getErrorMessage(): string {
    return $localize`Failed to load products. Please try again.`;
    //      ↑ $localize tag before the backtick
    //        This string will be extracted by ng extract-i18n
    //        At build time it is replaced with the translated string
  }

  // $localize WITH INTERPOLATION — dynamic values
  getSuccessMessage(count: number): string {
    return $localize`${count} items added to your cart`;
    //                ↑ Dynamic values are automatically handled as placeholders
    //                  In the XLF file: "${VAR_COUNT} items added to your cart"
  }

  // $localize WITH NAMED PLACEHOLDER
  // By default Angular names placeholders VAR_1, VAR_2, etc.
  // You can give them meaningful names for translators:
  getWelcomeMessage(userName: string): string {
    return $localize`:@@welcomeUserMessage:Welcome, ${userName}:userName:!`;
    //               ↑ Format: :description@@id:text ${value}:placeholderName:
    //               The :userName: suffix names the placeholder for translators
  }

  // $localize WITH CUSTOM ID
  getOutOfStockMessage(productName: string): string {
    return $localize`:Out of stock notification for a product@@outOfStockTs:${productName}:productName: is currently out of stock`;
    //               ↑ Full format: :description@@id:text
  }

}
```

### $localize Format Reference

```typescript
// FORMAT REFERENCE — all variations

// 1. Simple static string with custom ID
$localize`:@@myId:Some static text`;

// 2. Static string with description AND ID
$localize`:Description of the string@@myId:Some static text`;

// 3. Dynamic value (automatic placeholder name)
$localize`Hello ${name}`;
// → Placeholder named "INTERPOLATION" in XLF

// 4. Dynamic value with named placeholder
$localize`Hello ${name}:name:`;
// → Placeholder named "name" in XLF — much clearer for translators

// 5. Multiple placeholders
$localize`${firstName}:firstName: ${lastName}:lastName: has ${count}:count: items`;

// 6. Full form: description + ID + named placeholders
$localize`:Greeting for returning user@@greetReturning:Welcome back, ${name}:name:!`;
```

### When to Use Template i18n vs $localize

| Situation | Use | Why |
|---|---|---|
| Text content in HTML template | `i18n` attribute | Simpler syntax, better context |
| Attribute value in HTML template | `i18n-attr` attribute | Only option for attributes |
| String returned from a method | `$localize` | Template i18n cannot reach TypeScript |
| String in a service | `$localize` | Services have no template |
| Alert or toast message built in TypeScript | `$localize` | Dynamic runtime text |
| Error messages in validators | `$localize` | Logic lives in TypeScript |
| Window title set via `Title` service | `$localize` | Set programmatically |

```typescript
// title.service.usage.ts — setting page title with translation
import { Title } from '@angular/platform-browser';

@Component({ /* ... */ })
export class CheckoutComponent implements OnInit {
  constructor(private titleService: Title) {}

  ngOnInit(): void {
    // Window title set via TypeScript — MUST use $localize
    this.titleService.setTitle(
      $localize`:@@checkoutPageTitle:Checkout - My Shop`
    );
    // ↑ Without $localize, the browser tab title is always English
  }
}
```

---

## 17.7 ICU Message Format — Pluralization & Selection

### The Problem with Simple Pluralization

```typescript
// WRONG APPROACH — common mistake
getCartMessage(count: number): string {
  if (count === 0) return 'No items in cart';
  if (count === 1) return '1 item in cart';
  return `${count} items in cart`;
}
// WHY IS THIS WRONG?
// 1. Each string is a separate translation unit — 3x the translator work
// 2. Russian has 4 plural forms (1, few, many, other)
// 3. Arabic has 6 plural forms
// 4. You can't use this logic in a template easily
```

### ICU Plural Expressions in Templates

Angular supports ICU (International Components for Unicode) message format directly in templates:

```html
<!-- cart-badge.component.html -->

<!-- PLURAL EXPRESSION — correct way to handle "N items" -->
<span class="cart-count">
  {cartItemCount, plural,
    =0 {No items in your cart}
    =1 {1 item in your cart}
    other {{{cartItemCount}} items in your cart}
  }
</span>
<!--
  SYNTAX BREAKDOWN:
  {expression, plural,
    case {text for this case}
    ...
  }

  expression:   cartItemCount — the TypeScript variable to evaluate
  plural:       tells Angular this is a plural switch
  =0 {...}:     EXACTLY zero → "No items in your cart"
  =1 {...}:     EXACTLY one → "1 item in your cart"
  =2 {...}:     EXACTLY two (useful for Arabic, Irish, Welsh)
  one {...}:    "one" category per CLDR plural rules (locale-aware)
  few {...}:    "few" category (used in Russian, Polish, etc.)
  many {...}:   "many" category (used in Arabic)
  other {...}:  the default / fallback case (REQUIRED)

  INSIDE the braces: {{ cartItemCount }} is regular Angular interpolation
  NOTE the triple braces:
    outer {{ }} = the ICU expression delimiter in templates
    inner {{ }} = standard Angular interpolation
    Combined: {{ cartItemCount }} inside the ICU = {{{cartItemCount}}}
-->

<!-- REAL-WORLD EXAMPLE: Shopping cart with full messaging -->
<div class="cart-summary">
  <!-- Pluralized item count -->
  <p>
    {itemCount, plural,
      =0 {Your cart is empty}
      =1 {You have 1 item}
      other {You have {{itemCount}} items}
    }
  </p>

  <!-- Separate message for free shipping threshold -->
  <p class="shipping-note">
    {itemCount, plural,
      =0 {Add items to qualify for free shipping}
      =1 {Add {{remainingForFreeShipping | currency}} more for free shipping}
      other {Add {{remainingForFreeShipping | currency}} more for free shipping}
    }
  </p>
</div>

<!-- MARKING THE WHOLE ICU FOR TRANSLATION with i18n + custom ID -->
<span i18n="cart item count@@cartItemCountMessage">
  {cartItemCount, plural,
    =0 {No items}
    =1 {One item}
    other {{{cartItemCount}} items}
  }
</span>
```

### ICU Select Expressions

Select expressions work like a switch statement on a string value:

```html
<!-- user-greeting.component.html -->

<!-- SELECT EXPRESSION — for categorical choices -->
<p i18n="@@genderGreeting">
  {userGender, select,
    male   {Mr. {{lastName}}, welcome back!}
    female {Ms. {{lastName}}, welcome back!}
    other  {{{lastName}}, welcome back!}
  }
</p>
<!--
  SYNTAX:
  {expression, select,
    value1 {text for value1}
    value2 {text for value2}
    other  {fallback text}   ← REQUIRED
  }

  userGender: the TypeScript variable (string type expected)
  "other":    handles any value not explicitly listed — REQUIRED
-->

<!-- SELECT for shipping method -->
<span i18n="@@shippingMethodDescription">
  {selectedShipping, select,
    standard  {Arrives in 5-7 business days}
    express   {Arrives in 2-3 business days}
    overnight {Arrives tomorrow}
    other     {Shipping time varies}
  }
</span>

<!-- SELECT for order status -->
<span
  [class]="'status-' + orderStatus"
  i18n="@@orderStatusMessage"
>
  {orderStatus, select,
    pending    {Your order is being processed}
    confirmed  {Your order has been confirmed}
    shipped    {Your order is on its way}
    delivered  {Your order has been delivered}
    cancelled  {Your order has been cancelled}
    other      {Order status unknown}
  }
</span>
```

### Nested ICU Expressions

```html
<!-- NESTED ICU — plural inside select (advanced) -->
<p i18n="@@cartGreetingWithGender">
  {gender, select,
    male {
      {itemCount, plural,
        =0    {Sir, your cart is empty}
        =1    {Sir, you have 1 item}
        other {Sir, you have {{itemCount}} items}
      }
    }
    female {
      {itemCount, plural,
        =0    {Ma'am, your cart is empty}
        =1    {Ma'am, you have 1 item}
        other {Ma'am, you have {{itemCount}} items}
      }
    }
    other {
      {itemCount, plural,
        =0    {Your cart is empty}
        =1    {You have 1 item}
        other {You have {{itemCount}} items}
      }
    }
  }
</p>

<!-- NOTE: Nested ICU creates many translation units in the XLF file.
     Use only when truly necessary. Often a simpler design avoids nesting. -->
```

### Plural Categories by Language

This is why ICU plurals matter — different languages have different rules:

| Language | Plural Categories | Example |
|---|---|---|
| English | 2 (one, other) | 1 item, 2 items |
| French | 2 (one, other) | 1 article, 2 articles |
| German | 2 (one, other) | 1 Artikel, 2 Artikel |
| Russian | 4 (one, few, many, other) | 1 товар, 2 товара, 5 товаров, 21 товар |
| Arabic | 6 (zero, one, two, few, many, other) | ٠ عناصر، عنصر واحد، عنصران، ٣ عناصر... |
| Japanese | 1 (other) | Everything is "other" — no plural! |
| Polish | 4 (one, few, many, other) | 1 przedmiot, 2 przedmioty, 5 przedmiotów |
| Slovenian | 4 (one, two, few, other) | Different form for exactly 2! |

```typescript
// ICU handles ALL of this automatically when the locale is set correctly.
// You just write:
//   {count, plural, =0 {No items} =1 {1 item} other {{{count}} items}}
// Angular picks the right plural category for the current locale.
```

---

## 17.8 Date, Number & Currency Locale Formatting

### The Problem

```typescript
// WRONG: Hard-coded formatting that ignores locale
const price = 1234.56;
const displayPrice = '$' + price.toFixed(2);  // Always "$1234.56"

// A German user expects:  "1.234,56 €"
// An Indian user expects: "₹1,234.56"
// A Japanese user expects: "¥1,235" (no decimals for yen)
// A Swiss user expects:    "CHF 1'234.56"
```

### Angular's Locale-Aware Pipes

Angular's built-in pipes automatically format data according to the current locale when configured correctly:

```typescript
// app.module.ts — Setting up locale support
import { NgModule, LOCALE_ID } from '@angular/core';
import { registerLocaleData } from '@angular/common';

// Import locale data for each language you support
import localeEs from '@angular/common/locales/es';
import localeFr from '@angular/common/locales/fr';
import localeDe from '@angular/common/locales/de';
import localeJa from '@angular/common/locales/ja';
import localeAr from '@angular/common/locales/ar';
import localeHiIn from '@angular/common/locales/hi';    // Hindi/India

// REGISTER each locale's data before using it
// This loads: number formats, date formats, currency symbols, etc.
registerLocaleData(localeEs);
registerLocaleData(localeFr);
registerLocaleData(localeDe);
registerLocaleData(localeJa);
registerLocaleData(localeAr);
registerLocaleData(localeHiIn);

@NgModule({
  // ...
  providers: [
    // Provide the locale to use throughout the app
    // In a build-time i18n approach, this is set by the build system
    // In a runtime i18n approach (ngx-translate), you set this dynamically
    { provide: LOCALE_ID, useValue: 'de' }
    // ↑ All locale-aware pipes (DatePipe, CurrencyPipe, etc.) will
    //   use German formatting rules
  ]
})
export class AppModule {}
```

### Using Locale-Aware Pipes in Templates

```html
<!-- product-details.component.html -->

<!-- CURRENCY PIPE — locale-aware -->
<span class="price">{{ product.price | currency }}</span>
<!-- With LOCALE_ID='de': "1.234,56 €"
     With LOCALE_ID='en-US': "$1,234.56"
     With LOCALE_ID='ja': "¥1,235"
     The pipe reads the locale from LOCALE_ID automatically -->

<!-- Currency pipe with explicit currency code override -->
<span>{{ product.price | currency:'EUR' }}</span>
<!-- Forces Euro regardless of locale — but format (decimal, grouping) still locale-aware -->

<!-- Currency with display format options -->
<span>{{ product.price | currency:'USD':'symbol':'1.2-2' }}</span>
<!-- 'USD'    = currency code
     'symbol' = show symbol ($) not code (USD)
     '1.2-2'  = minimum 1 digit before decimal, 2-2 digits after -->

<!-- DECIMAL PIPE — locale-aware number formatting -->
<span>{{ rating | number:'1.1-2' }}</span>
<!-- en-US: "4.5"
     de:    "4,5"  (European uses comma as decimal separator)
     fr:    "4,5" -->

<span>{{ largeNumber | number }}</span>
<!-- 1234567 in en-US: "1,234,567" (comma thousands separator)
     1234567 in de:    "1.234.567" (period thousands separator)
     1234567 in hi:    "12,34,567" (Indian numbering system!) -->

<!-- PERCENT PIPE — locale-aware -->
<span>{{ discountRate | percent:'1.0-1' }}</span>
<!-- 0.25 → "25%" in en-US
     0.25 → "25 %" in fr (space before %)
     0.25 → "25%" in de -->

<!-- DATE PIPE — locale-aware -->
<span>{{ order.date | date:'shortDate' }}</span>
<!-- en-US: "12/5/2024"
     de:    "05.12.2024"
     ja:    "2024/12/05"
     ar:    "٠٥/١٢/٢٠٢٤"  (Arabic-Indic numerals!) -->

<span>{{ order.date | date:'longDate' }}</span>
<!-- en-US: "December 5, 2024"
     de:    "5. Dezember 2024"
     fr:    "5 décembre 2024"
     ja:    "2024年12月5日" -->

<span>{{ order.date | date:'medium' }}</span>
<!-- en-US: "Dec 5, 2024, 3:30:45 PM"
     de:    "05.12.2024, 15:30:45" (24-hour clock) -->
```

### Comprehensive Locale Formatting Comparison Table

| Format | en-US (American English) | de (German) | ja (Japanese) | hi-IN (Hindi/India) | ar (Arabic) |
|---|---|---|---|---|---|
| Number: 1234567.89 | 1,234,567.89 | 1.234.567,89 | 1,234,567.89 | 12,34,567.89 | ١٬٢٣٤٬٥٦٧٫٨٩ |
| Currency: 1234.56 | $1,234.56 | 1.234,56 € | ¥1,235 | ₹1,234.56 | ١٬٢٣٤٫٥٦ د.إ. |
| Short Date | 12/5/2024 | 05.12.2024 | 2024/12/05 | 05/12/2024 | ٠٥/١٢/٢٠٢٤ |
| Long Date | December 5, 2024 | 5. Dezember 2024 | 2024年12月5日 | 5 दिसंबर 2024 | ٥ ديسمبر ٢٠٢٤ |
| Time (3:30 PM) | 3:30 PM | 15:30 Uhr | 15:30 | 3:30 PM | ٣:٣٠ م |
| Percent: 0.256 | 25.6% | 25,6 % | 25.6% | 25.6% | 25.6% |
| Week start | Sunday | Monday | Sunday | Sunday | Saturday |
| Calendar | Gregorian | Gregorian | Gregorian | Gregorian | Gregorian (+ Hijri option) |

### Getting LOCALE_ID Dynamically

```typescript
// locale.service.ts — For runtime locale detection
import { Injectable, LOCALE_ID, Inject } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class LocaleService {

  constructor(
    @Inject(LOCALE_ID) private localeId: string  // ← Inject current locale
  ) {}

  getCurrentLocale(): string {
    return this.localeId;  // Returns 'en-US', 'de', 'es', etc.
  }

  // Format a number programmatically using the current locale
  formatCurrency(amount: number, currencyCode: string = 'USD'): string {
    return new Intl.NumberFormat(this.localeId, {
      style: 'currency',
      currency: currencyCode
    }).format(amount);
    // ↑ Intl.NumberFormat is the browser native API — locale-aware
    // Angular's CurrencyPipe uses this internally
  }

  formatDate(date: Date, options?: Intl.DateTimeFormatOptions): string {
    return new Intl.DateTimeFormat(this.localeId, options).format(date);
  }
}
```

---

## 17.9 RTL (Right-to-Left) Support

### What is RTL and Why It Matters

English and most European languages are LTR (Left-to-Right). But over 600 million people read languages that flow Right-to-Left:

```
LTR languages (Left → Right):
  English:  "Hello World"    reads left to right
  Spanish:  "Hola Mundo"     reads left to right
  German:   "Hallo Welt"     reads left to right

RTL languages (Right ← Left):
  Arabic:   "مرحبا بالعالم"  reads right to left
  Hebrew:   "שלום עולם"      reads right to left
  Urdu:     "ہیلو ورلڈ"      reads right to left
  Farsi:    "سلام دنیا"      reads right to left

Bidirectional (Bidi) — number within RTL text:
  "The price is $5.99" in Arabic:
  "السعر هو $5.99"  ← text is RTL, number stays LTR
```

In RTL mode, the ENTIRE page layout mirrors:

```
LTR LAYOUT:                    RTL LAYOUT:
┌─────────────────────────┐    ┌─────────────────────────┐
│ [LOGO]     NAV LINKS    │    │    SKNIL VAN     [OGOL] │
├─────────────────────────┤    ├─────────────────────────┤
│ SIDEBAR │ MAIN CONTENT  │    │  TNETNO NIAM │ RABEDIS  │
│         │               │    │              │          │
│         │               │    │              │          │
├─────────────────────────┤    ├─────────────────────────┤
│ BACK [←]  NEXT [→]     │    │    [←] TXEN  [→] KCAB  │
└─────────────────────────┘    └─────────────────────────┘
```

### Setting Direction on the HTML Element

```html
<!-- index.html — The root direction -->

<!-- WRONG for RTL: hard-coded LTR -->
<html lang="en" dir="ltr">
<!-- ↑ This will NEVER flip for Arabic users -->

<!-- CORRECT: Let Angular/i18n set the direction -->
<html lang="{{ locale }}" [attr.dir]="isRtl ? 'rtl' : 'ltr'">

<!-- For build-time i18n: Angular's build system sets lang automatically
     For Arabic, add dir="rtl" in your Arabic-specific index.html:
     src/locale/index.ar.html -->
```

For build-time approach, create locale-specific HTML files:

```html
<!-- src/locale/index.ar.html — Arabic-specific index -->
<!doctype html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <title>متجري</title>
  <base href="/ar/">
  <!-- Arabic-specific fonts, if needed -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Naskh+Arabic" rel="stylesheet">
</head>
<body>
  <app-root></app-root>
</body>
</html>
```

### CSS Logical Properties — The RTL-Safe Way

Old CSS uses physical properties (`left`, `right`, `margin-left`) which break in RTL. CSS logical properties adapt automatically:

```css
/* product-card.component.css */

/* ══════════════════════════════════════════════════════ */
/* WRONG: Physical properties — break in RTL             */
/* ══════════════════════════════════════════════════════ */
.product-image {
  float: left;           /* LTR: image on left — RTL: still on left (WRONG!) */
  margin-right: 16px;    /* LTR: space after image — RTL: space before (wrong side!) */
}

.price {
  text-align: right;     /* LTR: right-aligned — RTL: that's the START, not end! */
}

.back-button {
  padding-left: 8px;     /* Padding before arrow — flips meaning in RTL */
}

/* ══════════════════════════════════════════════════════ */
/* CORRECT: Logical properties — auto-flip in RTL        */
/* ══════════════════════════════════════════════════════ */
.product-image {
  float: inline-start;           /* = left in LTR, right in RTL */
  margin-inline-end: 16px;       /* = margin-right in LTR, margin-left in RTL */
}

.price {
  text-align: end;               /* = right in LTR, left in RTL */
}

.back-button {
  padding-inline-start: 8px;    /* = padding-left in LTR, padding-right in RTL */
}

/* FULL MAPPING TABLE: Physical → Logical */
/*
  margin-left       → margin-inline-start
  margin-right      → margin-inline-end
  padding-left      → padding-inline-start
  padding-right     → padding-inline-end
  border-left       → border-inline-start
  border-right      → border-inline-end
  left: 0           → inset-inline-start: 0
  right: 0          → inset-inline-end: 0
  text-align: left  → text-align: start
  text-align: right → text-align: end
  float: left       → float: inline-start
  float: right      → float: inline-end
  width → inline-size
  height → block-size
  top → inset-block-start
  bottom → inset-block-end
*/
```

### Angular CDK Bidi Module

For programmatic RTL detection and response in Angular:

```typescript
// Install Angular CDK if not already present:
// ng add @angular/cdk

// app.module.ts
import { BidiModule } from '@angular/cdk/bidi';

@NgModule({
  imports: [
    BidiModule,   // ← Enables RTL-aware directives and services
    // ...
  ]
})
export class AppModule {}
```

```typescript
// navigation.component.ts
import { Component, OnInit } from '@angular/core';
import { Directionality } from '@angular/cdk/bidi';

@Component({
  selector: 'app-navigation',
  templateUrl: './navigation.component.html',
  styleUrls: ['./navigation.component.css']
})
export class NavigationComponent implements OnInit {

  isRtl: boolean = false;
  // ↑ We'll set this from the CDK Directionality service

  constructor(
    private dir: Directionality
    // ↑ Inject the CDK service — reads direction from the DOM
    //   automatically detects dir="rtl" on parent elements
  ) {}

  ngOnInit(): void {
    // Get the current direction
    this.isRtl = this.dir.value === 'rtl';

    // React to direction changes (important for runtime language switching)
    this.dir.change.subscribe((newDir) => {
      this.isRtl = newDir === 'rtl';
      // ↑ 'rtl' or 'ltr'
    });
  }

  // Use direction to determine which icon to show
  getBackArrowIcon(): string {
    return this.isRtl ? 'arrow_forward' : 'arrow_back';
    // ↑ In RTL, "back" means going RIGHT (→), not left (←)
  }

  getNextArrowIcon(): string {
    return this.isRtl ? 'arrow_back' : 'arrow_forward';
  }
}
```

```html
<!-- navigation.component.html -->

<!-- Use CDK's dir directive to set direction per-component -->
<div cdkDir>
  <!-- ↑ This div (and all children) respect the document direction -->

  <!-- Conditional icon based on direction -->
  <button (click)="goBack()">
    <mat-icon>{{ getBackArrowIcon() }}</mat-icon>
    <span i18n="@@backButtonText">Back</span>
  </button>

  <!-- CSS class based on direction -->
  <div [class.rtl-layout]="isRtl" [class.ltr-layout]="!isRtl">
    <!-- Content that needs custom RTL styling -->
  </div>
</div>
```

```css
/* navigation.component.css */

/* Use :host-context for direction-aware styling */
:host-context([dir='rtl']) .back-icon {
  transform: scaleX(-1);   /* Flip the arrow icon in RTL */
}

/* Or use @layer and logical properties */
.sidebar {
  /* PHYSICAL (breaks RTL): border-right: 1px solid #ccc; */
  border-inline-end: 1px solid #ccc;   /* ← logical: right in LTR, left in RTL */
}

.product-grid {
  /* Text and inline content auto-flip with dir="rtl" — no CSS needed */
  /* But explicit layout needs logical properties */
  margin-inline-start: auto;
  margin-inline-end: auto;
}
```

---

## 17.10 Runtime Translation with ngx-translate

### Why ngx-translate Exists

Angular's built-in i18n is a **build-time** solution: you build one bundle per locale. This means:
- To switch language, the browser must navigate to a different URL (`/es/`, `/fr/`)
- You cannot change language within a running app without a full page reload
- This is perfectly fine for most apps

But some apps need **runtime** language switching:

```
USE CASES FOR RUNTIME TRANSLATION (ngx-translate):
  ✓ SaaS apps where users set their language in their profile
  ✓ Apps where users travel and want to switch languages live
  ✓ Admin tools that need to serve multiple team members
  ✓ Apps that cannot afford multiple deployment URLs
  ✓ Progressive Web Apps (PWA) with offline support

WHEN BUILT-IN i18n IS BETTER:
  ✓ Public-facing apps with URL-per-language SEO
  ✓ Apps where locale is set by geography/domain
  ✓ Performance-critical apps (no runtime translation overhead)
  ✓ Apps using static site generation (SSG)
```

### Installation and Setup

```bash
# Install ngx-translate and its HTTP loader
npm install @ngx-translate/core @ngx-translate/http-loader

# The http-loader fetches JSON translation files at runtime
```

```typescript
// app.module.ts — Setting up ngx-translate
import { NgModule } from '@angular/core';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import {
  TranslateModule,
  TranslateLoader,
  TranslateService
} from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';

// FACTORY FUNCTION — tells ngx-translate how to load translation files
// This returns a loader that fetches JSON from /assets/i18n/
export function HttpLoaderFactory(http: HttpClient): TranslateHttpLoader {
  return new TranslateHttpLoader(
    http,
    './assets/i18n/',  // ← path to translation files
    '.json'            // ← file extension
    // Combined: ./assets/i18n/en.json, ./assets/i18n/es.json, etc.
  );
}

@NgModule({
  imports: [
    HttpClientModule,   // ← Required for HTTP loading of translation files

    TranslateModule.forRoot({
      // ↑ forRoot() = root-level setup (do this ONCE in AppModule)
      defaultLanguage: 'en',
      // ↑ Fallback language if a translation is missing

      loader: {
        provide: TranslateLoader,
        useFactory: HttpLoaderFactory,
        deps: [HttpClient]  // ← Inject HttpClient into the factory
      }
    })
  ],
  // ...
})
export class AppModule {}

// Also initialize the language in your AppComponent:
// constructor(private translate: TranslateService) {
//   translate.setDefaultLang('en');
//   translate.use('en');  // ← Start with English
// }
```

### JSON Translation Files

ngx-translate uses JSON files instead of XLF:

```json
// src/assets/i18n/en.json — English translations
{
  "COMMON": {
    "LOADING": "Loading...",
    "ERROR": "An error occurred",
    "RETRY": "Try Again"
  },
  "NAV": {
    "HOME": "Home",
    "PRODUCTS": "Products",
    "CART": "Cart",
    "ACCOUNT": "My Account"
  },
  "PRODUCT": {
    "ADD_TO_CART": "Add to Cart",
    "OUT_OF_STOCK": "Out of Stock",
    "PRICE": "Price",
    "DESCRIPTION": "Description",
    "REVIEWS": "Customer Reviews"
  },
  "CART": {
    "TITLE": "Shopping Cart",
    "EMPTY": "Your cart is empty",
    "ITEM_COUNT_zero": "No items",
    "ITEM_COUNT_one": "{{count}} item",
    "ITEM_COUNT_other": "{{count}} items",
    "CHECKOUT": "Proceed to Checkout",
    "CONTINUE_SHOPPING": "Continue Shopping"
  },
  "CHECKOUT": {
    "TITLE": "Checkout",
    "PLACE_ORDER": "Place Order",
    "SECURE_PAYMENT": "Your payment is secure and encrypted",
    "FIRST_NAME": "First Name",
    "LAST_NAME": "Last Name",
    "EMAIL": "Email Address"
  },
  "GREETING": "Hello, {{name}}!"
}
```

```json
// src/assets/i18n/es.json — Spanish translations
{
  "COMMON": {
    "LOADING": "Cargando...",
    "ERROR": "Ocurrió un error",
    "RETRY": "Intentar de nuevo"
  },
  "NAV": {
    "HOME": "Inicio",
    "PRODUCTS": "Productos",
    "CART": "Carrito",
    "ACCOUNT": "Mi cuenta"
  },
  "PRODUCT": {
    "ADD_TO_CART": "Añadir al carrito",
    "OUT_OF_STOCK": "Agotado",
    "PRICE": "Precio",
    "DESCRIPTION": "Descripción",
    "REVIEWS": "Reseñas de clientes"
  },
  "CART": {
    "TITLE": "Carrito de compras",
    "EMPTY": "Tu carrito está vacío",
    "ITEM_COUNT_zero": "Sin artículos",
    "ITEM_COUNT_one": "{{count}} artículo",
    "ITEM_COUNT_other": "{{count}} artículos",
    "CHECKOUT": "Proceder al pago",
    "CONTINUE_SHOPPING": "Seguir comprando"
  },
  "CHECKOUT": {
    "TITLE": "Finalizar compra",
    "PLACE_ORDER": "Realizar pedido",
    "SECURE_PAYMENT": "Tu pago está seguro y cifrado",
    "FIRST_NAME": "Nombre",
    "LAST_NAME": "Apellido",
    "EMAIL": "Correo electrónico"
  },
  "GREETING": "¡Hola, {{name}}!"
}
```

```json
// src/assets/i18n/ar.json — Arabic translations (RTL)
{
  "COMMON": {
    "LOADING": "جارٍ التحميل...",
    "ERROR": "حدث خطأ",
    "RETRY": "حاول مرة أخرى"
  },
  "NAV": {
    "HOME": "الرئيسية",
    "PRODUCTS": "المنتجات",
    "CART": "السلة",
    "ACCOUNT": "حسابي"
  },
  "PRODUCT": {
    "ADD_TO_CART": "أضف إلى السلة",
    "OUT_OF_STOCK": "غير متوفر",
    "PRICE": "السعر",
    "DESCRIPTION": "الوصف",
    "REVIEWS": "آراء العملاء"
  },
  "CART": {
    "TITLE": "سلة التسوق",
    "EMPTY": "سلتك فارغة",
    "ITEM_COUNT_zero": "لا توجد عناصر",
    "ITEM_COUNT_one": "عنصر واحد",
    "ITEM_COUNT_other": "{{count}} عناصر",
    "CHECKOUT": "متابعة الدفع",
    "CONTINUE_SHOPPING": "متابعة التسوق"
  },
  "CHECKOUT": {
    "TITLE": "إتمام الطلب",
    "PLACE_ORDER": "تأكيد الطلب",
    "SECURE_PAYMENT": "دفعتك آمنة ومشفرة",
    "FIRST_NAME": "الاسم الأول",
    "LAST_NAME": "اسم العائلة",
    "EMAIL": "البريد الإلكتروني"
  },
  "GREETING": "مرحباً، {{name}}!"
}
```

### Using TranslateService in TypeScript

```typescript
// language-switcher.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { TranslateService, LangChangeEvent } from '@ngx-translate/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';

@Component({
  selector: 'app-language-switcher',
  templateUrl: './language-switcher.component.html'
})
export class LanguageSwitcherComponent implements OnInit, OnDestroy {

  currentLang: string = 'en';
  private destroy$ = new Subject<void>();

  availableLanguages = [
    { code: 'en', label: 'English', flag: '🇺🇸', dir: 'ltr' },
    { code: 'es', label: 'Español', flag: '🇪🇸', dir: 'ltr' },
    { code: 'fr', label: 'Français', flag: '🇫🇷', dir: 'ltr' },
    { code: 'de', label: 'Deutsch', flag: '🇩🇪', dir: 'ltr' },
    { code: 'ar', label: 'العربية', flag: '🇸🇦', dir: 'rtl' },
    { code: 'ja', label: '日本語',  flag: '🇯🇵', dir: 'ltr' }
  ];

  constructor(private translate: TranslateService) {}

  ngOnInit(): void {
    // Get the initial language
    this.currentLang = this.translate.currentLang || 'en';

    // LISTEN for language changes (e.g., user switches language)
    this.translate.onLangChange
      .pipe(takeUntil(this.destroy$))
      .subscribe((event: LangChangeEvent) => {
        this.currentLang = event.lang;
        // Update the document dir attribute for RTL support
        const langConfig = this.availableLanguages.find(l => l.code === event.lang);
        document.documentElement.setAttribute('dir', langConfig?.dir || 'ltr');
        document.documentElement.setAttribute('lang', event.lang);
      });
  }

  // SWITCH LANGUAGE — called when user selects a language
  switchLanguage(langCode: string): void {
    this.translate.use(langCode);
    // ↑ ngx-translate:
    //   1. Fetches /assets/i18n/langCode.json if not already loaded
    //   2. Sets the active language
    //   3. Emits onLangChange event
    //   4. Updates all {{ 'KEY' | translate }} pipes automatically
    //   No page reload needed!

    // Persist user preference
    localStorage.setItem('preferredLanguage', langCode);
  }

  ngOnDestroy(): void {
    this.destroy$.next();     // ← Stop all subscriptions
    this.destroy$.complete();
  }
}
```

```typescript
// product.component.ts — Using TranslateService programmatically
import { Component } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

@Component({ /* ... */ })
export class ProductComponent {

  constructor(private translate: TranslateService) {}

  // METHOD 1: translate.get() — returns Observable<string>
  showAddedToast(productName: string): void {
    this.translate.get('CART.ITEM_ADDED', { name: productName })
      .subscribe((translatedMsg: string) => {
        // Use the translated message in a toast notification
        this.toastService.show(translatedMsg);
      });
  }

  // METHOD 2: translate.instant() — synchronous, use ONLY when translations are loaded
  getPageTitle(): string {
    return this.translate.instant('PRODUCT.TITLE');
    // ↑ WARNING: Returns the key itself ('PRODUCT.TITLE') if translations
    //   aren't loaded yet. Only use in methods called AFTER language is ready.
  }

  // METHOD 3: translate.stream() — Observable that emits on language change
  // Use this in components to auto-update when language changes:
  getReactiveTitle() {
    return this.translate.stream('PRODUCT.TITLE');
    // ↑ Returns Observable<string> that re-emits on every language change
    //   Perfect for dynamic titles, placeholders, etc.
  }
}
```

### The translate Pipe in Templates

```html
<!-- product-list.component.html -->

<!-- BASIC translate pipe -->
<h1>{{ 'PRODUCT.TITLE' | translate }}</h1>
<!-- ↑ The pipe reads 'PRODUCT.TITLE' from the current language's JSON
     When language changes, the pipe automatically updates -->

<!-- With interpolation params -->
<p>{{ 'GREETING' | translate:{ name: user.firstName } }}</p>
<!-- JSON: "GREETING": "Hello, {{name}}!"
     Output: "Hello, John!" -->

<!-- On attributes -->
<input [placeholder]="'CHECKOUT.EMAIL' | translate" type="email" />

<!-- On aria labels -->
<button [attr.aria-label]="'PRODUCT.ADD_TO_CART' | translate">
  <mat-icon>add_shopping_cart</mat-icon>
</button>

<!-- The [translate] DIRECTIVE (alternative to pipe) -->
<h2 translate>CART.TITLE</h2>
<!-- ↑ Can use directive on element — less flexible than pipe but cleaner -->

<h2 [translate]="'CART.TITLE'"></h2>
<!-- ↑ Bound version — allows dynamic key -->

<!-- Dynamic translation key -->
<span [translate]="'STATUS.' + order.status"></span>
<!-- If order.status = 'SHIPPED':
     Reads: 'STATUS.SHIPPED' from JSON → "Your order is on its way" -->
```

### Lazy Loading Translations Per Module

For large apps, load only the translations needed for the current feature:

```typescript
// products/products.module.ts — Lazy loading with per-module translations
import { NgModule } from '@angular/core';
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';
import { HttpClient } from '@angular/common/http';

// Separate loader for the products module translations
export function ProductsTranslateLoader(http: HttpClient) {
  return new TranslateHttpLoader(http, './assets/i18n/products/', '.json');
  // ↑ Loads from: /assets/i18n/products/en.json, /assets/i18n/products/es.json
}

@NgModule({
  imports: [
    TranslateModule.forChild({
      // ↑ forChild() for lazy-loaded modules (NOT forRoot()!)
      loader: {
        provide: TranslateLoader,
        useFactory: ProductsTranslateLoader,
        deps: [HttpClient]
      },
      isolate: false   // ← false = share parent's translations, extend them
                       // true  = completely separate translation scope
    })
  ]
})
export class ProductsModule {}
```

### @angular/localize vs ngx-translate Comparison

| Feature | @angular/localize | ngx-translate |
|---|---|---|
| **Approach** | Build-time | Runtime |
| **Language switch** | Requires page reload / URL change | Instant, no reload |
| **Bundle size** | Smaller (translations compiled in) | Larger (runtime overhead ~50KB) |
| **SEO** | Excellent (separate URLs per locale) | Harder (single URL) |
| **Angular support** | Official, built-in | Third-party library |
| **ICU pluralization** | Native support | Manual with i18n-polyfill |
| **Template syntax** | `i18n` attribute | `translate` pipe/directive |
| **TypeScript strings** | `$localize` tag | `translate.instant()` / `translate.get()` |
| **Translation format** | XLIFF / XMB | JSON |
| **Missing translation** | Build error/warning | Falls back to key name |
| **Best for** | Public apps, multi-URL, SSG | SaaS, single-URL, profile-based lang |

---

## 17.11 Translation Best Practices

### Never Concatenate Translated Strings

This is the most common and most damaging i18n mistake:

```typescript
// ❌ WRONG — String concatenation
getWelcomeMessage(name: string, count: number): string {
  return this.translate.instant('HELLO') + ' ' + name + '! ' +
         this.translate.instant('YOU_HAVE') + ' ' + count + ' ' +
         this.translate.instant('ITEMS');
  // WHY THIS IS WRONG:
  // English: "Hello John! You have 5 items"      ← Correct
  // German:  "Hallo John! Du hast 5 Artikel"     ← Works by luck
  // Japanese: "こんにちはJohn！ あなたは5アイテムを持っています" ← Wrong word order!
  // Arabic:  Subject/verb/object order changes completely
  // Some languages put the quantity AFTER the noun
}

// ✅ CORRECT — Single key with parameters
getWelcomeMessage(name: string, count: number): string {
  return this.translate.instant('WELCOME_WITH_ITEMS', { name, count });
}
// JSON:
// en: "Hello, {{name}}! You have {{count}} items."
// ja: "{{name}}さん、こんにちは！{{count}}個のアイテムがあります。"
// ar: "مرحباً {{name}}! لديك {{count}} عناصر."
// ↑ Each language can arrange the parameters in its own natural order
```

### Provide Context for Translators

```html
<!-- WITHOUT context — translator cannot know what "Post" means -->
<button i18n="@@postButton">Post</button>
<!-- "Post" = publish a message? A type of mail? A fence post? -->

<!-- WITH context — absolutely clear -->
<button i18n="forum|Publishes the user's comment to the forum thread@@postCommentButton">
  Post
</button>
<!-- Now translator knows: this is a forum action, publishing a comment -->

<!-- MORE EXAMPLES OF CONTEXT -->
<span i18n="label|Shows the current status of the user's order in the order list@@orderStatusLabel">
  Status
</span>

<a i18n="navigation|Returns the user to the previous page in browser history@@browserBackLink">
  Back
</a>
```

### Handle Text Expansion

Different languages use different amounts of text:

```
ENGLISH (baseline):  "Add to Cart"          (11 chars)
GERMAN:              "In den Warenkorb"      (17 chars) +55%
PORTUGUESE:          "Adicionar ao carrinho" (21 chars) +91%
FRENCH:              "Ajouter au panier"     (17 chars) +55%
FINNISH:             "Lisää ostoskoriin"     (17 chars) +55%
SPANISH:             "Añadir al carrito"     (17 chars) +55%
JAPANESE:            "カートに追加"            (7 chars)  -36% (shorter!)
ARABIC:              "أضف إلى السلة"          (13 chars)  +18%

RULE OF THUMB: Design for 40% more text than English.
```

```css
/* button-design for text expansion */

/* ❌ WRONG: Fixed width that clips German text */
.add-to-cart-btn {
  width: 120px;          /* Enough for "Add to Cart" but not "In den Warenkorb" */
  overflow: hidden;      /* Clips the translated text — invisible to German users! */
  white-space: nowrap;
}

/* ✅ CORRECT: Flexible sizing */
.add-to-cart-btn {
  min-width: 120px;      /* Never smaller than original design */
  width: auto;           /* Expands to fit translated text */
  padding: 8px 16px;     /* Padding-based, not width-based */
  white-space: normal;   /* Allow wrapping if needed */
  text-align: center;
}
```

### Pseudo-Localization for Testing

Pseudo-localization is a technique to test your i18n implementation WITHOUT real translations:

```
Original: "Add to Cart"
Pseudo:   "[Àdd ŧō Çàrŧ]"

The pseudo-locale:
  • Replaces letters with accented equivalents
  • Wraps text in [brackets] to spot truncation
  • Makes text longer (~30%) to test text expansion
  • Uses obviously "foreign" characters to spot hard-coded strings
  • If you see "[" cut off in the UI, your layout is too narrow!
```

```bash
# Generate a pseudo-locale build to test your layout
# First, create a messages.en-x-pseudo.xlf translation file programmatically
# Then build with:
ng build --configuration=en-x-pseudo
```

### Common Mistakes Checklist

```
COMMON i18n MISTAKES:
═══════════════════════════════════════════════════════════
1. ❌ Concatenating translated strings
   ✅ Use single keys with {{param}} placeholders

2. ❌ Hard-coding currency symbols ("$" + price)
   ✅ Use CurrencyPipe with locale-aware formatting

3. ❌ Assuming singular/plural is always just one/many
   ✅ Use ICU plural expressions (some languages have 6 forms)

4. ❌ Using physical CSS (margin-left, float: left)
   ✅ Use CSS logical properties for RTL support

5. ❌ Not providing context to translators
   ✅ Use i18n="meaning|description@@id" fully

6. ❌ Using fixed widths that clip translated text
   ✅ Design for 40%+ text expansion

7. ❌ Formatting dates as "12/05/2024" (ambiguous MM/DD/YYYY vs DD/MM/YYYY)
   ✅ Use DatePipe which formats per locale

8. ❌ Using translate.instant() before translations are loaded
   ✅ Use translate.get() (Observable) or ensure lang is loaded first

9. ❌ Not registering locale data for non-English locales
   ✅ Call registerLocaleData() for each locale you support

10. ❌ Translating unit IDs that change when source text changes
    ✅ Use custom IDs with @@myId to stabilize translation units

11. ❌ Leaving <x id="INTERPOLATION"/> out of translations
    ✅ Translators MUST keep all <x> elements from source in target

12. ❌ Testing only in English — bugs only appear in other locales
    ✅ Test with pseudo-locale + at least 2 real locales
═══════════════════════════════════════════════════════════
```

---

## 17.12 Practical Example — Multi-Language E-Commerce App

### App Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                   MULTI-LANGUAGE SHOP                                │
│                                                                      │
│  Supported: English (en-US), Spanish (es), Arabic (ar) with RTL     │
│  Approach: ngx-translate (runtime switching)                         │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────┐         │
│  │  Language Switcher (EN | ES | العربية)                   │         │
│  ├─────────────────────────────────────────────────────────┤         │
│  │  Navbar: Home / Products / Cart (3 items) / My Account  │         │
│  ├──────────────┬──────────────────────────────────────────┤         │
│  │              │  Product: Wireless Headphones             │         │
│  │  Categories  │  Price: $89.99 / 89,99 € / ٨٩٫٩٩ $      │         │
│  │  (sidebar)   │  Status: In Stock                         │         │
│  │              │  [Add to Cart]  [Save for Later]          │         │
│  │              │  Reviews: 4.5 stars (1,234 reviews)        │         │
│  │              │  Added: December 5, 2024                  │         │
│  └──────────────┴──────────────────────────────────────────┘         │
│  Footer: © 2024 My Shop. All rights reserved.                        │
└─────────────────────────────────────────────────────────────────────┘
```

### File Structure

```
src/
├── assets/
│   └── i18n/
│       ├── en.json          ← English translations
│       ├── es.json          ← Spanish translations
│       └── ar.json          ← Arabic translations
├── app/
│   ├── app.module.ts        ← TranslateModule setup
│   ├── app.component.ts     ← Language init, dir management
│   ├── language-switcher/
│   │   ├── language-switcher.component.ts
│   │   └── language-switcher.component.html
│   └── product/
│       ├── product-card.component.ts
│       └── product-card.component.html
```

### Translation Files

```json
// src/assets/i18n/en.json
{
  "APP": {
    "TITLE": "My Shop",
    "COPYRIGHT": "© {{year}} My Shop. All rights reserved."
  },
  "NAV": {
    "HOME": "Home",
    "PRODUCTS": "Products",
    "CART": "Cart",
    "CART_BADGE_zero": "Empty cart",
    "CART_BADGE_one": "{{count}} item",
    "CART_BADGE_other": "{{count}} items",
    "ACCOUNT": "My Account"
  },
  "PRODUCT": {
    "ADD_TO_CART": "Add to Cart",
    "SAVE_FOR_LATER": "Save for Later",
    "IN_STOCK": "In Stock",
    "OUT_OF_STOCK": "Out of Stock",
    "PRICE_LABEL": "Price",
    "REVIEWS_COUNT_zero": "No reviews yet",
    "REVIEWS_COUNT_one": "1 review",
    "REVIEWS_COUNT_other": "{{count}} reviews",
    "ADDED_ON": "Added on {{date}}"
  },
  "CART": {
    "TITLE": "Shopping Cart",
    "EMPTY": "Your cart is empty",
    "EMPTY_CTA": "Browse our products",
    "SUMMARY_zero": "Your cart is empty",
    "SUMMARY_one": "You have 1 item in your cart",
    "SUMMARY_other": "You have {{count}} items in your cart",
    "CHECKOUT": "Proceed to Checkout",
    "CONTINUE": "Continue Shopping"
  },
  "ERRORS": {
    "LOAD_FAILED": "Failed to load products. Please try again.",
    "CART_FULL": "Cannot add more items to cart"
  }
}
```

```json
// src/assets/i18n/es.json
{
  "APP": {
    "TITLE": "Mi Tienda",
    "COPYRIGHT": "© {{year}} Mi Tienda. Todos los derechos reservados."
  },
  "NAV": {
    "HOME": "Inicio",
    "PRODUCTS": "Productos",
    "CART": "Carrito",
    "CART_BADGE_zero": "Carrito vacío",
    "CART_BADGE_one": "{{count}} artículo",
    "CART_BADGE_other": "{{count}} artículos",
    "ACCOUNT": "Mi cuenta"
  },
  "PRODUCT": {
    "ADD_TO_CART": "Añadir al carrito",
    "SAVE_FOR_LATER": "Guardar para después",
    "IN_STOCK": "En stock",
    "OUT_OF_STOCK": "Agotado",
    "PRICE_LABEL": "Precio",
    "REVIEWS_COUNT_zero": "Aún sin reseñas",
    "REVIEWS_COUNT_one": "1 reseña",
    "REVIEWS_COUNT_other": "{{count}} reseñas",
    "ADDED_ON": "Añadido el {{date}}"
  },
  "CART": {
    "TITLE": "Carrito de compras",
    "EMPTY": "Tu carrito está vacío",
    "EMPTY_CTA": "Explorar productos",
    "SUMMARY_zero": "Tu carrito está vacío",
    "SUMMARY_one": "Tienes 1 artículo en tu carrito",
    "SUMMARY_other": "Tienes {{count}} artículos en tu carrito",
    "CHECKOUT": "Proceder al pago",
    "CONTINUE": "Seguir comprando"
  },
  "ERRORS": {
    "LOAD_FAILED": "No se pudieron cargar los productos. Inténtalo de nuevo.",
    "CART_FULL": "No se pueden añadir más artículos al carrito"
  }
}
```

```json
// src/assets/i18n/ar.json
{
  "APP": {
    "TITLE": "متجري",
    "COPYRIGHT": "© {{year}} متجري. جميع الحقوق محفوظة."
  },
  "NAV": {
    "HOME": "الرئيسية",
    "PRODUCTS": "المنتجات",
    "CART": "السلة",
    "CART_BADGE_zero": "السلة فارغة",
    "CART_BADGE_one": "{{count}} عنصر",
    "CART_BADGE_other": "{{count}} عناصر",
    "ACCOUNT": "حسابي"
  },
  "PRODUCT": {
    "ADD_TO_CART": "أضف إلى السلة",
    "SAVE_FOR_LATER": "احفظ لوقت لاحق",
    "IN_STOCK": "متوفر",
    "OUT_OF_STOCK": "غير متوفر",
    "PRICE_LABEL": "السعر",
    "REVIEWS_COUNT_zero": "لا توجد تقييمات بعد",
    "REVIEWS_COUNT_one": "تقييم واحد",
    "REVIEWS_COUNT_other": "{{count}} تقييمات",
    "ADDED_ON": "أُضيف في {{date}}"
  },
  "CART": {
    "TITLE": "سلة التسوق",
    "EMPTY": "سلتك فارغة",
    "EMPTY_CTA": "تصفح منتجاتنا",
    "SUMMARY_zero": "سلتك فارغة",
    "SUMMARY_one": "لديك عنصر واحد في سلتك",
    "SUMMARY_other": "لديك {{count}} عناصر في سلتك",
    "CHECKOUT": "متابعة الدفع",
    "CONTINUE": "متابعة التسوق"
  },
  "ERRORS": {
    "LOAD_FAILED": "فشل تحميل المنتجات. يرجى المحاولة مرة أخرى.",
    "CART_FULL": "لا يمكن إضافة المزيد من العناصر إلى السلة"
  }
}
```

### App Module Setup

```typescript
// app.module.ts
import { NgModule, LOCALE_ID } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { TranslateModule, TranslateLoader } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';
import { BidiModule } from '@angular/cdk/bidi';
import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';
import localeAr from '@angular/common/locales/ar';

// Register locale data for non-English locales
registerLocaleData(localeEs);   // ← Required for Spanish formatting
registerLocaleData(localeAr);   // ← Required for Arabic formatting

export function HttpLoaderFactory(http: HttpClient) {
  return new TranslateHttpLoader(http, './assets/i18n/', '.json');
}

@NgModule({
  imports: [
    BrowserModule,
    HttpClientModule,
    BidiModule,           // ← CDK RTL support
    TranslateModule.forRoot({
      defaultLanguage: 'en',
      loader: {
        provide: TranslateLoader,
        useFactory: HttpLoaderFactory,
        deps: [HttpClient]
      }
    })
  ],
  providers: [
    // LOCALE_ID defaults to 'en-US'
    // In a real app you'd set this dynamically — see note below
    { provide: LOCALE_ID, useValue: 'en-US' }
  ],
  // ...
})
export class AppModule {}

// ── IMPORTANT NOTE ──────────────────────────────────────────────────
// LOCALE_ID is read ONCE at app startup. It does NOT update dynamically
// when TranslateService.use() switches languages.
//
// For runtime locale formatting (CurrencyPipe, DatePipe) to follow
// the selected language, you need either:
//   1. A locale factory that reads from TranslateService
//   2. Using Intl.* API directly (not Angular pipes)
//   3. Or accept that number/date formatting is set at startup
// ────────────────────────────────────────────────────────────────────
```

### App Component — Language Initialization

```typescript
// app.component.ts
import { Component, OnInit } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit {

  constructor(private translate: TranslateService) {
    // Define all supported languages
    this.translate.addLangs(['en', 'es', 'ar']);
    // ↑ Tells TranslateService what languages are available

    // Set the fallback language (used when a key is missing in target language)
    this.translate.setDefaultLang('en');
    // ↑ If 'es' is missing "CART.CHECKOUT", fall back to English "Proceed to Checkout"
  }

  ngOnInit(): void {
    // Check if user has a saved language preference
    const savedLang = localStorage.getItem('preferredLanguage');

    // Or try to detect browser language
    const browserLang = this.translate.getBrowserLang() || 'en';
    // ↑ Returns 'en', 'es', 'fr', etc. from browser settings

    // Choose the language to use:
    const langToUse = savedLang
      || (this.translate.getLangs().includes(browserLang) ? browserLang : 'en');
    // ↑ Priority: saved preference → browser language → default 'en'

    // Apply the language
    this.translate.use(langToUse);

    // Set document direction
    this.updateDocumentDirection(langToUse);

    // Listen for future language changes
    this.translate.onLangChange.subscribe(event => {
      this.updateDocumentDirection(event.lang);
    });
  }

  private updateDocumentDirection(lang: string): void {
    const rtlLanguages = ['ar', 'he', 'ur', 'fa'];
    const isRtl = rtlLanguages.includes(lang);
    document.documentElement.setAttribute('dir', isRtl ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', lang);
    // ↑ This makes ALL CSS logical properties work correctly throughout the app
  }
}
```

### Language Switcher Component

```typescript
// language-switcher.component.ts
import { Component } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

interface Language {
  code: string;
  nativeName: string;     // Name in that language itself (for the dropdown)
  flag: string;
}

@Component({
  selector: 'app-language-switcher',
  templateUrl: './language-switcher.component.html',
  styleUrls: ['./language-switcher.component.css']
})
export class LanguageSwitcherComponent {

  languages: Language[] = [
    { code: 'en', nativeName: 'English',  flag: 'US' },
    { code: 'es', nativeName: 'Español',  flag: 'ES' },
    { code: 'ar', nativeName: 'العربية', flag: 'SA' }
  ];

  get currentLang(): string {
    return this.translate.currentLang || 'en';
  }

  constructor(private translate: TranslateService) {}

  switchTo(langCode: string): void {
    if (langCode === this.currentLang) return;  // ← Don't reload same language

    this.translate.use(langCode).subscribe(() => {
      // ↑ .use() returns Observable — emits when translation file is loaded
      console.log(`Language switched to: ${langCode}`);
      localStorage.setItem('preferredLanguage', langCode);
    });
  }
}
```

```html
<!-- language-switcher.component.html -->
<div class="lang-switcher">
  <button
    *ngFor="let lang of languages"
    class="lang-btn"
    [class.active]="lang.code === currentLang"
    (click)="switchTo(lang.code)"
    [attr.aria-label]="'Switch to ' + lang.nativeName"
    [attr.lang]="lang.code"
  >
    <!-- Native name ensures the button is readable to speakers of that language -->
    {{ lang.nativeName }}
  </button>
</div>
```

```css
/* language-switcher.component.css */
.lang-switcher {
  display: flex;
  gap: 8px;
  /* Use logical properties for RTL safety */
  margin-inline-start: auto;  /* Push to end regardless of direction */
}

.lang-btn {
  padding: 4px 12px;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  background: transparent;
  font-size: 14px;
}

.lang-btn.active {
  background: #0066cc;
  color: white;
  border-color: #0066cc;
}
```

### Product Card Component

```typescript
// product-card.component.ts
import { Component, Input } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

export interface Product {
  id: number;
  name: string;          // Note: In a real app, product name would also be translated
  price: number;
  currency: string;
  inStock: boolean;
  reviewCount: number;
  averageRating: number;
  addedDate: Date;
}

@Component({
  selector: 'app-product-card',
  templateUrl: './product-card.component.html',
  styleUrls: ['./product-card.component.css']
})
export class ProductCardComponent {

  @Input() product!: Product;

  cartCount: number = 0;  // ← Track items in cart

  constructor(private translate: TranslateService) {}

  addToCart(): void {
    this.cartCount++;

    // Translate a dynamic notification message
    this.translate.get(
      this.cartCount === 1 ? 'CART.SUMMARY_one' : 'CART.SUMMARY_other',
      { count: this.cartCount }
    ).subscribe(message => {
      // Show translated toast notification
      console.log(message);  // In real app: this.snackBar.open(message);
    });
  }

  // Return the correct plural key for review count
  getReviewKey(): string {
    if (this.product.reviewCount === 0) return 'PRODUCT.REVIEWS_COUNT_zero';
    if (this.product.reviewCount === 1) return 'PRODUCT.REVIEWS_COUNT_one';
    return 'PRODUCT.REVIEWS_COUNT_other';
  }
}
```

```html
<!-- product-card.component.html -->
<article class="product-card" [attr.aria-label]="product.name">

  <!-- PRODUCT NAME — in a real app, names would also be in translation JSON -->
  <h2 class="product-name">{{ product.name }}</h2>

  <!-- PRICE — locale-aware currency formatting -->
  <div class="price-section">
    <span class="price-label">{{ 'PRODUCT.PRICE_LABEL' | translate }}:</span>
    <span class="price-value">
      {{ product.price | currency:product.currency:'symbol':'1.2-2' }}
      <!-- ↑ currency pipe: locale formats the number
           product.currency = 'USD', 'EUR', etc.
           'symbol' = show '$' not 'USD'
           '1.2-2'  = always 2 decimal places -->
    </span>
  </div>

  <!-- STOCK STATUS -->
  <span
    class="stock-status"
    [class.in-stock]="product.inStock"
    [class.out-of-stock]="!product.inStock"
  >
    {{ (product.inStock ? 'PRODUCT.IN_STOCK' : 'PRODUCT.OUT_OF_STOCK') | translate }}
  </span>

  <!-- REVIEW COUNT — using dynamic translation key -->
  <div class="reviews">
    <span class="stars">{{ product.averageRating | number:'1.1-1' }}</span>
    <!-- ↑ number pipe: locale-aware decimal — "4.5" in en, "4,5" in de -->
    <span class="review-text">
      {{ getReviewKey() | translate:{ count: product.reviewCount } }}
      <!-- Dynamic key selection + parameter interpolation -->
    </span>
  </div>

  <!-- ADDED DATE — locale-aware date formatting -->
  <p class="added-date">
    {{ 'PRODUCT.ADDED_ON' | translate:{
      date: (product.addedDate | date:'longDate')
    } }}
    <!--
      Step 1: DatePipe formats the date per current locale:
              en: "December 5, 2024"
              es: "5 de diciembre de 2024"
              ar: "٥ ديسمبر ٢٠٢٤"
      Step 2: TranslateService inserts that formatted date into:
              en: "Added on December 5, 2024"
              es: "Añadido el 5 de diciembre de 2024"
              ar: "أُضيف في ٥ ديسمبر ٢٠٢٤"
    -->
  </p>

  <!-- ACTION BUTTONS -->
  <div class="actions">
    <button
      class="btn-primary"
      [disabled]="!product.inStock"
      (click)="addToCart()"
      [attr.aria-label]="'PRODUCT.ADD_TO_CART' | translate"
    >
      {{ 'PRODUCT.ADD_TO_CART' | translate }}
    </button>

    <button
      class="btn-secondary"
      [attr.aria-label]="'PRODUCT.SAVE_FOR_LATER' | translate"
    >
      {{ 'PRODUCT.SAVE_FOR_LATER' | translate }}
    </button>
  </div>

  <!-- CART SUMMARY (shown when items added) -->
  <div *ngIf="cartCount > 0" class="cart-feedback">
    {{ 'CART.SUMMARY_' + (cartCount === 1 ? 'one' : 'other') | translate:{ count: cartCount } }}
    <!--
      Result in English:
        cartCount = 1: "You have 1 item in your cart"
        cartCount = 5: "You have 5 items in your cart"
      Result in Spanish:
        cartCount = 1: "Tienes 1 artículo en tu carrito"
        cartCount = 5: "Tienes 5 artículos en tu carrito"
      Result in Arabic:
        cartCount = 1: "لديك عنصر واحد في سلتك"
        cartCount = 5: "لديك 5 عناصر في سلتك"
    -->
  </div>

</article>
```

```css
/* product-card.component.css */
.product-card {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 20px;

  /* Use logical properties for RTL layout */
  margin-inline-start: 0;
  margin-inline-end: 0;

  /* Text alignment follows document direction — no override needed */
}

.price-section {
  display: flex;
  align-items: center;
  gap: 8px;
}

.actions {
  display: flex;
  gap: 12px;
  /* Direction-aware layout — buttons flow correctly in both LTR and RTL */
  flex-direction: row;   /* stays row; browser flips order with dir="rtl" */
  margin-block-start: 16px;   /* logical: margin-top regardless of direction */
}

.in-stock { color: #22c55e; }   /* green */
.out-of-stock { color: #ef4444; /* red */ }

/* RTL-specific overrides using dir attribute selector */
:host-context([dir='rtl']) .stars::before {
  /* Put star on the correct side in RTL */
  content: '★ ';
  order: 1;    /* Move star to the end visually (inline-end in RTL) */
}
```

### Cart Component with Pluralization

```typescript
// cart.component.ts
import { Component, OnInit } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';

@Component({
  selector: 'app-cart',
  templateUrl: './cart.component.html'
})
export class CartComponent {
  cartItems = [
    { name: 'Wireless Headphones', price: 89.99, qty: 2 },
    { name: 'Phone Case',          price: 14.99, qty: 1 }
  ];

  get itemCount(): number {
    return this.cartItems.reduce((sum, item) => sum + item.qty, 0);
  }

  get total(): number {
    return this.cartItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
  }

  get cartSummaryKey(): string {
    // Select correct plural key based on count
    if (this.itemCount === 0) return 'CART.SUMMARY_zero';
    if (this.itemCount === 1) return 'CART.SUMMARY_one';
    return 'CART.SUMMARY_other';
  }
}
```

```html
<!-- cart.component.html -->
<div class="cart-page">

  <h1>{{ 'CART.TITLE' | translate }}</h1>

  <!-- PLURALIZED CART SUMMARY -->
  <p class="cart-summary">
    {{ cartSummaryKey | translate:{ count: itemCount } }}
    <!--
      0 items: "Your cart is empty"          / "Tu carrito está vacío"
      1 item:  "You have 1 item in your cart" / "Tienes 1 artículo en tu carrito"
      3 items: "You have 3 items in your cart"/ "Tienes 3 artículos en tu carrito"
    -->
  </p>

  <!-- EMPTY STATE -->
  <div *ngIf="itemCount === 0" class="empty-cart">
    <p>{{ 'CART.EMPTY' | translate }}</p>
    <a routerLink="/products">{{ 'CART.EMPTY_CTA' | translate }}</a>
  </div>

  <!-- CART ITEMS -->
  <ul *ngIf="itemCount > 0" class="cart-items">
    <li *ngFor="let item of cartItems" class="cart-item">
      <span class="item-name">{{ item.name }}</span>
      <span class="item-qty">× {{ item.qty | number }}</span>
      <span class="item-price">{{ item.price * item.qty | currency:'USD' }}</span>
    </li>
  </ul>

  <!-- TOTAL -->
  <div *ngIf="itemCount > 0" class="cart-total">
    <span>Total:</span>
    <span>{{ total | currency:'USD' }}</span>
  </div>

  <!-- ACTION BUTTONS -->
  <div *ngIf="itemCount > 0" class="cart-actions">
    <button class="btn-secondary" routerLink="/products">
      {{ 'CART.CONTINUE' | translate }}
    </button>
    <button class="btn-primary" routerLink="/checkout">
      {{ 'CART.CHECKOUT' | translate }}
    </button>
  </div>

</div>
```

### Visual Summary: Everything Working Together

```
USER SELECTS ARABIC:
═══════════════════════════════════════════════════════════
                                                      ┐RTL
  ┌────────────────────────────────────────────────┐  │
  │   متجري           English | Español | العربية  │  │
  ├────────────────────────────────────────────────┤  │
  │  حسابي  |  السلة(٣)  |  المنتجات  |  الرئيسية │  │
  ├────────────────────────────────────────────────┤  │
  │                        سماعات لاسلكية          │  │
  │                      ٨٩٫٩٩ دولار              │  │
  │                           متوفر               │  │
  │       [احفظ لوقت لاحق]    [أضف إلى السلة]     │  │
  │                  تقييم واحد  4.5              │  │
  │           أُضيف في ٥ ديسمبر ٢٠٢٤             │  │
  └────────────────────────────────────────────────┘  │
  © 2024 متجري. جميع الحقوق محفوظة.               RTL┘

TranslateService.use('ar') triggered:
  1. Fetches /assets/i18n/ar.json                    ✓
  2. Updates all {{ key | translate }} expressions   ✓
  3. onLangChange emits 'ar'                         ✓
  4. AppComponent sets dir="rtl" on <html>           ✓
  5. CSS logical properties flip layout              ✓
  6. DatePipe renders in Arabic numerals             ✓
  7. Number/currency format per locale               ✓
  8. Browser tab title updated via TranslateService  ✓
```

---

## 17.13 Summary

### What We Covered

```
┌────────────────────────────────────────────────────────────────────┐
│                    PHASE 17 COMPLETE MAP                           │
│                                                                    │
│  17.1  WHY i18n          → Business case, analogies, i18n vs l10n │
│                                                                    │
│  17.2  ANGULAR i18n      → i18n attr, i18n-attr, @@id,            │
│                            meaning|description@@id syntax          │
│                                                                    │
│  17.3  EXTRACTING        → ng extract-i18n, XLIFF formats,        │
│                            structure of messages.xlf               │
│                                                                    │
│  17.4  TRANSLATION FILES → Creating locale files, adding          │
│                            <target>, translation tools             │
│                                                                    │
│  17.5  BUILD CONFIG      → angular.json i18n setup, ng build      │
│                            --localize, deployment strategies       │
│                                                                    │
│  17.6  $localize          → TypeScript string translation,        │
│                            named placeholders, when to use        │
│                                                                    │
│  17.7  ICU FORMAT        → Plural expressions, select             │
│                            expressions, nested ICU                 │
│                                                                    │
│  17.8  LOCALE FORMATTING → DatePipe, CurrencyPipe, DecimalPipe,   │
│                            LOCALE_ID, registerLocaleData           │
│                                                                    │
│  17.9  RTL SUPPORT       → dir attribute, CSS logical props,      │
│                            CDK BidiModule, Directionality          │
│                                                                    │
│  17.10 NGX-TRANSLATE     → Runtime translation, TranslateService, │
│                            translate pipe, JSON files              │
│                                                                    │
│  17.11 BEST PRACTICES    → Concatenation, context, expansion,     │
│                            pseudo-locale, mistakes checklist       │
│                                                                    │
│  17.12 PRACTICAL EXAMPLE → Full e-commerce app with lang switch,  │
│                            RTL, plurals, locale formatting         │
└────────────────────────────────────────────────────────────────────┘
```

### Decision Guide: Which Approach to Use?

```
START HERE
    │
    ▼
Does your app need to switch languages WITHOUT a page reload?
    │
    ├─ YES ──→ Use ngx-translate
    │           • Runtime language switching
    │           • JSON translation files
    │           • TranslateService + translate pipe
    │
    └─ NO ───→ Use @angular/localize (built-in)
                │
                ├─ Is SEO critical with per-language URLs?
                │   YES: Built-in i18n is perfect (/en/, /es/, /ar/)
                │   NO:  Either approach works
                │
                ├─ Do you need ICU plurals?
                │   YES: Built-in i18n has native ICU support
                │   NO:  Both work
                │
                └─ Do strings appear in TypeScript (not templates)?
                    YES: Use $localize in TypeScript
                    NO:  Use i18n attributes in templates
```

### Key Formulas to Remember

```typescript
// 1. Marking template text
<p i18n="meaning|description@@customId">Translatable text</p>

// 2. Marking attribute
<input i18n-placeholder placeholder="Text here" />

// 3. Extracting
ng extract-i18n --output-path src/locale --format xlf

// 4. Building all locales
ng build --configuration=production  // (with "localize": true in angular.json)

// 5. TypeScript translation
$localize`:description@@id:Text with ${value}:valueName:`;

// 6. ICU plural
{count, plural, =0 {Zero} =1 {One} other {{{count}} items}}

// 7. ICU select
{status, select, active {Active} inactive {Inactive} other {Unknown}}

// 8. ngx-translate setup
TranslateModule.forRoot({ defaultLanguage: 'en', loader: { ... } })

// 9. ngx-translate usage in template
{{ 'KEY.PATH' | translate }}
{{ 'KEY.WITH_PARAM' | translate:{ param: value } }}

// 10. ngx-translate switch language
this.translate.use('es').subscribe(() => console.log('Switched!'));

// 11. Register locale data
registerLocaleData(localeEs);
// Then use LOCALE_ID provider or locale-aware pipes directly
```

### Before and After

```
BEFORE PHASE 17:                    AFTER PHASE 17:
─────────────────                   ────────────────
Hard-coded English strings          i18n attributes + translation files
"$" + price.toFixed(2)              {{ price | currency }} (locale-aware)
margin-left: 20px                   margin-inline-start: 20px (RTL-safe)
No plural handling ("1 items")      ICU: {count, plural, =1 {1 item} ...}
One build for all users             ng build --localize → per-locale bundles
No language switch                  ngx-translate runtime switching
Invisible to 74% of the web         Global audience, true i18n
```

---

> **Next Phase:** [Phase 18: Security](Phase18-Security.md)
