
# Phase 18: Security in Angular Applications

> Security is critical for protecting your users and data. This phase is a comprehensive guide to Angular security, with detailed explanations, best practices, and code samples for real-world implementation.

---

## 18.1 Common Security Threats (Explained)

- **Cross-Site Scripting (XSS):**
  - Attackers inject malicious scripts into your app, which run in the user's browser.
  - Example: Displaying unsanitized user input with `innerHTML`.

- **Cross-Site Request Forgery (CSRF):**
  - Tricks users into submitting requests they didn’t intend (e.g., clicking a hidden form).

- **Insecure APIs:**
  - Exposing sensitive data or operations without proper authentication/authorization.

- **Authentication & Authorization Flaws:**
  - Weak login, missing access checks, or leaking tokens.

---

## 18.2 Angular Security Features (with Code)

### 1. Automatic HTML Escaping

Angular templates automatically escape values to prevent XSS:

```html
<!-- Safe: Angular escapes the value -->
<div>{{ userInput }}</div>

<!-- Dangerous: Avoid using [innerHTML] with untrusted data -->
<div [innerHTML]="userInput"></div>
```

### 2. Sanitization with DomSanitizer

Use Angular’s `DomSanitizer` to safely handle HTML, URLs, and styles:

```typescript
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

constructor(private sanitizer: DomSanitizer) {}

getSafeHtml(html: string): SafeHtml {
  // Only use this for trusted content!
  return this.sanitizer.bypassSecurityTrustHtml(html);
}
```

**Warning:** Only use `bypassSecurityTrust...` for content you fully trust. Never use with user input.

### 3. HTTP Interceptors for Authentication

Add tokens to requests and handle errors globally:

```typescript
import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = localStorage.getItem('authToken');
    let authReq = req;
    if (token) {
      // Clone the request and set the new header
      authReq = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
    }
    return next.handle(authReq);
  }
}
```

Register the interceptor in your module:

```typescript
import { HTTP_INTERCEPTORS } from '@angular/common/http';
@NgModule({
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true }
  ]
})
export class AppModule {}
```

### 4. Route Guards for Authorization

Protect routes based on authentication or user roles:

```typescript
import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private auth: AuthService, private router: Router) {}

  canActivate(): boolean {
    if (this.auth.isLoggedIn()) {
      return true;
    } else {
      // Redirect to login if not authenticated
      this.router.navigate(['/login']);
      return false;
    }
  }
}
```

Add the guard to your routes:

```typescript
const routes: Routes = [
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
];
```

---

## 18.3 Best Practices (with Explanations)

- **Never trust user input:** Always validate and sanitize on both client and server.
- **Avoid bypassing Angular's security mechanisms:** Don’t use `bypassSecurityTrust...` unless absolutely necessary.
- **Use HTTPS:** Always serve your app and APIs over HTTPS.
- **Keep dependencies up to date:** Security patches are released frequently.
- **Implement proper authentication and authorization:** Use JWTs, OAuth, or similar standards.
- **Store secrets securely:** Never commit API keys or secrets to your codebase. Use environment variables or secure vaults.

---

## 18.4 Step-by-Step: Securing a New Angular Project

1. **Always use Angular’s built-in template binding:**
   ```html
   <!-- Safe -->
   <div>{{ userInput }}</div>
   <!-- Avoid [innerHTML] unless sanitized -->
   ```
2. **Add an HTTP interceptor for authentication:**
   - See code above for `AuthInterceptor`.
3. **Implement route guards:**
   - See code above for `AuthGuard`.
4. **Validate and sanitize all user input:**
   - Use Angular forms with validators.
   ```typescript
   import { FormControl, Validators } from '@angular/forms';
   email = new FormControl('', [Validators.required, Validators.email]);
   ```
5. **Keep dependencies updated:**
   ```bash
   ng update @angular/core @angular/cli
   ```
6. **Use environment variables for secrets:**
   - Store API keys in `environment.ts` (never in code or templates).

---

## 18.5 Resources

- [Angular Security Guide](https://angular.io/guide/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Web Security Fundamentals](https://web.dev/security/)

- [Angular Security Guide](https://angular.io/guide/security)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Web Security Fundamentals](https://web.dev/security/)
