# Session 04 — Authentication & Authorization (Enriched)

**Duration:** 60 minutes
**Audience:** Developers who completed Session 03
**Goal:** Understand the difference between AuthN and AuthZ, read and validate a JWT token, protect endpoints with claims and policies, know OAuth 2.0 flows, and understand where Entra ID and Managed Identity fit.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | Authentication vs Authorization — The Core Distinction |
| 5–20 min | JWT Token — What's Inside and How It Works |
| 20–32 min | OAuth 2.0 Flows + Refresh Tokens |
| 32–45 min | Protecting Endpoints in ASP.NET Core |
| 45–55 min | Policy-Based Authorization |
| 55–60 min | Key Takeaways + Q&A |

---

## 1. Authentication vs Authorization (0–5 min)

### Mental Model
> **Authentication** = the hotel front desk checking your ID and giving you a key card. **Authorization** = the elevator knowing which floors your key card can access.

```
┌──────────────────────────────────────────────────────────────┐
│  Authentication (AuthN)          Authorization (AuthZ)       │
├──────────────────────────────────────────────────────────────┤
│  WHO are you?                    WHAT can you do?            │
│  Verify identity                 Enforce permissions         │
│  Runs first                      Runs second                 │
│  Result: ClaimsPrincipal         Result: Allow / Deny        │
│                                                              │
│  Example: JWT validation         Example: "must be Admin"    │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. JWT Token — What's Inside and How It Works (5–20 min)

### Mental Model
> A JWT is a **tamper-proof envelope**. Anyone can read what's inside (it's just Base64), but only the server that signed it can create a valid one. If anyone changes even one byte, the signature check fails.

### JWT Structure

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9
    .
eyJzdWIiOiJ1c2VyLTEyMyIsIm5hbWUiOiJBbGljZSIsInJvbGUiOiJBZG1pbiIsImV4cCI6MTcwMDAwMDAwMH0
    .
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

│── Header ──│     │──────────── Payload (Claims) ──────────────│     │── Signature ──│
```

**Decoded Header:**
```json
{
  "alg": "RS256",
  "typ": "JWT"
}
```

**Decoded Payload (Claims):**
```json
{
  "sub": "user-123",          // subject — the user's unique ID
  "name": "Alice",
  "email": "alice@example.com",
  "role": "Admin",
  "iat": 1699999999,          // issued at (Unix timestamp)
  "exp": 1700003599           // expires at — reject after this time
}
```

**Signature:** `RSASHA256(Base64(header) + "." + Base64(payload), privateKey)`
- Only the identity provider has the private key
- Your API verifies with the **public key** — no secret needed on your API server

### The Auth Flow

```
1. User logs in to Identity Provider (Entra ID / your auth server)
   └─ Provider validates credentials → issues JWT

2. Client sends JWT in every request:
   Authorization: Bearer eyJhbGci...

3. ASP.NET Core middleware validates the JWT:
   ├─ Signature valid? (using public key from provider)
   ├─ Not expired? (checks exp claim)
   └─ Correct audience/issuer? (checks aud and iss claims)

4. If valid → HttpContext.User is populated with claims
   If invalid → 401 Unauthorized returned immediately
```

### Decode a Real Token (Live Demo)
Go to **jwt.io** and paste a token to see its claims decoded in real time.

---

## 3. OAuth 2.0 Flows + Refresh Tokens (20–32 min)

### Mental Model
> OAuth 2.0 is a **delegation protocol** — it lets a user grant your app limited access to their resources without sharing their password. Think of it as a valet key: it opens the car but doesn't access the trunk.

### The Two Flows You Need to Know

```
┌──────────────────────────────────────────────────────────────────────┐
│  Flow                      │  When to Use                           │
├──────────────────────────────────────────────────────────────────────┤
│  Authorization Code Flow   │  User-facing apps (web, mobile)        │
│  Client Credentials Flow   │  Service-to-service (no user involved)  │
└──────────────────────────────────────────────────────────────────────┘
```

### Authorization Code Flow — User Login

```
User clicks "Login"
    │
    ▼
Your App → redirects to Identity Provider (Entra ID)
    │      with: client_id, scope, redirect_uri
    ▼
Identity Provider shows login page
    │
User enters credentials
    │
    ▼
Identity Provider → redirects back to your app
    │               with: authorization_code (short-lived, one-time)
    ▼
Your App → exchanges code for tokens (server-side, secret stays safe)
    │       POST /token with: code + client_secret
    ▼
Identity Provider → returns:
    ├── access_token  (short-lived JWT — sent with every API call)
    ├── id_token      (user identity info)
    └── refresh_token (long-lived — used to get new access tokens silently)
```

### Client Credentials Flow — Service to Service

```
API-A needs to call API-B (no user involved)

API-A
    │  POST /token
    │  client_id=api-a-id
    │  client_secret=*** (or Managed Identity — no secret needed)
    │  grant_type=client_credentials
    ▼
Identity Provider → returns access_token for API-B's scope
    │
    ▼
API-A calls API-B with the access_token in Authorization header
API-B validates the token
```

### Refresh Tokens — Why Access Tokens Are Short-Lived

```
Why short-lived access tokens?
  If a token is stolen, it only works for a brief window (e.g., 1 hour)
  Attacker can't use it indefinitely

Refresh flow:
  1. Access token expires (401 Unauthorized)
  2. Client sends refresh_token to Identity Provider
  3. Identity Provider issues new access_token (silently, no re-login)
  4. User never sees a login prompt

Refresh token lifetime: typically 24 hours to 90 days
  If refresh token also expires → user must login again
```

```csharp
// Client-side: detect 401 and automatically refresh
// This is handled by MSAL (Microsoft Authentication Library)
// Your backend just validates the access token — no refresh logic needed there
```

---

## 4. Protecting Endpoints in ASP.NET Core (32–45 min)

### Step 1 — Add JWT Bearer Authentication

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // WHY: Authority is the identity provider's base URL
        // ASP.NET Core auto-fetches public keys from {Authority}/.well-known/openid-configuration
        options.Authority = builder.Configuration["Jwt:Authority"];

        // WHY: Audience ensures this token was issued FOR this specific API
        options.Audience = builder.Configuration["Jwt:Audience"];

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero  // no tolerance for expiry — be strict
        };
    });

builder.Services.AddAuthorization();

// Middleware — order is critical
app.UseAuthentication();  // must come BEFORE UseAuthorization
app.UseAuthorization();
```

### Step 2 — Protect Endpoints

```csharp
// Require authentication
app.MapGet("/orders", async (IOrderService svc) =>
    Results.Ok(await svc.GetAllAsync()))
    .RequireAuthorization();  // 401 if no valid JWT

// Allow anonymous (public endpoint)
app.MapGet("/health", () => Results.Ok("Healthy"))
    .AllowAnonymous();

// Require a specific role
app.MapDelete("/orders/{id:guid}", async (Guid id, IOrderService svc) =>
{
    await svc.DeleteAsync(id);
    return Results.NoContent();
})
.RequireAuthorization(policy => policy.RequireRole("Admin"));
```

### Reading Claims in Your Code

```csharp
app.MapGet("/me", (HttpContext context) =>
{
    var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    var email  = context.User.FindFirst(ClaimTypes.Email)?.Value;
    var roles  = context.User.FindAll(ClaimTypes.Role).Select(c => c.Value);

    return Results.Ok(new { userId, email, roles });
})
.RequireAuthorization();
```

---

## 5. Policy-Based Authorization (45–55 min)

### Mental Model
> Role checks are blunt instruments. **Policies** let you express rich business rules: "user must be an Admin AND from the EU region AND their account must be older than 30 days."

### Defining a Policy

```csharp
builder.Services.AddAuthorization(options =>
{
    // Simple role-based
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));

    // Claim-based
    options.AddPolicy("PremiumUser", policy =>
        policy.RequireClaim("subscription", "premium", "enterprise"));

    // Combined
    options.AddPolicy("SeniorManager", policy =>
    {
        policy.RequireRole("Manager");
        policy.RequireClaim("department", "Finance", "Operations");
        policy.RequireAuthenticatedUser();
    });
});
```

### Using Policies on Endpoints

```csharp
app.MapPost("/orders/{id}/approve", async (Guid id, IOrderService svc) =>
{
    await svc.ApproveAsync(id);
    return Results.Ok();
})
.RequireAuthorization("SeniorManager");
```

### Custom Requirements

```csharp
// When built-in checks aren't enough
public class MinimumAgeRequirement : IAuthorizationRequirement
{
    public int MinimumAge { get; }
    public MinimumAgeRequirement(int age) => MinimumAge = age;
}

public class MinimumAgeHandler : AuthorizationHandler<MinimumAgeRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        MinimumAgeRequirement requirement)
    {
        var birthDateClaim = context.User.FindFirst("birthdate");
        if (birthDateClaim != null &&
            DateTime.TryParse(birthDateClaim.Value, out var birthDate))
        {
            int age = DateTime.Today.Year - birthDate.Year;
            if (age >= requirement.MinimumAge)
                context.Succeed(requirement);
        }
        return Task.CompletedTask;
    }
}

builder.Services.AddSingleton<IAuthorizationHandler, MinimumAgeHandler>();
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Over18", p => p.Requirements.Add(new MinimumAgeRequirement(18)));
});
```

---

## Azure Integration

> **For the Azure-focused audience** — this section covers Microsoft Entra ID setup, RBAC, and Managed Identity for zero-credential service authentication.

### Microsoft Entra ID (formerly Azure Active Directory)

```
┌──────────────────────────────────────────────────────────────────────┐
│  Entra ID = Microsoft's cloud identity provider                      │
│                                                                      │
│  What it does:                                                       │
│  • Manages user identities (employees, B2B guests, B2C customers)    │
│  • Issues JWT tokens (OAuth 2.0 / OpenID Connect)                   │
│  • Enforces MFA, Conditional Access policies                         │
│  • Single Sign-On across Microsoft 365, Azure, and your apps        │
│                                                                      │
│  Your app's role:                                                    │
│  • Register the app in Entra ID (App Registration)                  │
│  • Configure Authority = https://login.microsoftonline.com/{tenant}  │
│  • Configure Audience = your app's client ID                         │
└──────────────────────────────────────────────────────────────────────┘
```

### App Registration — What You Configure

```
Entra ID → App Registration → Your API App
    │
    ├── Application ID (Client ID)  → your Audience value
    ├── Tenant ID                   → part of Authority URL
    ├── API Scopes (e.g., "orders.read", "orders.write")
    └── Expose an API → clients must request a scope to call your API
```

### Managed Identity — Service to Service Auth

```
Problem: API-A needs to call API-B. How does API-A prove its identity?

Without Managed Identity:
  API-A stores clientId + clientSecret in config → risk: secret leaks

With Managed Identity:
  API-A (running on Azure) → asks Azure for a token automatically
  No credentials stored anywhere
```

```csharp
// API-A calling API-B using Managed Identity
var credential = new DefaultAzureCredential();
var token = await credential.GetTokenAsync(
    new TokenRequestContext(new[] { "https://api-b.example.com/.default" }));

httpClient.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Bearer", token.Token);
```

### RBAC Mental Model

```
Entra ID Identity (user or managed identity)
    │
    ▼
Assigned a Role  (e.g., "Storage Blob Data Reader")
    │
    ▼
On a Resource Scope  (e.g., a specific Storage Account)
    │
    ▼
Result: identity can read blobs from that account only
```

---

## Key Takeaways

1. **AuthN first, then AuthZ** — `UseAuthentication()` must come before `UseAuthorization()`.
2. **JWT is signed, not encrypted** — anyone can read the payload; only the issuer can create a valid signature.
3. **OAuth 2.0 flows** — Authorization Code for user-facing apps, Client Credentials for service-to-service.
4. **Refresh tokens enable silent renewal** — access tokens are short-lived; refresh tokens allow re-issuance without re-login.
5. **Managed Identity = no credentials** — Azure-hosted services authenticate to each other without storing secrets.

---

## Q&A Prompts

**1. What's the difference between `401 Unauthorized` and `403 Forbidden`?**

**Answer:** `401 Unauthorized` means the request lacks valid authentication — either no token was provided, or the token is invalid/expired. The client should re-authenticate. `403 Forbidden` means the request is authenticated (we know who you are) but you don't have permission to perform this action. The client should not retry — they need elevated access.

---

**2. Why do we validate the `audience` (aud) claim in a JWT?**

**Answer:** The audience claim identifies who the token was intended for. If API-B issues a token for API-A, you don't want that token to be reusable on API-C. Validating `aud` ensures that a token issued for one API can't be replayed against another API in the same tenant, which prevents token substitution attacks.

---

**3. What would happen if you called `UseAuthorization()` before `UseAuthentication()`?**

**Answer:** Authorization would run before authentication has populated `HttpContext.User` with claims. Every `[Authorize]`-protected endpoint would fail with `403 Forbidden` (or redirect to login) because `User.Identity.IsAuthenticated` would always be false — the user's identity from the JWT was never validated and set. Always: `UseAuthentication` → then → `UseAuthorization`.

---

**4. What is the difference between Authorization Code Flow and Client Credentials Flow?**

**Answer:** Authorization Code Flow involves a real user — it shows a login page, gets consent, and issues tokens tied to that user's identity. Used for user-facing apps (web, mobile, SPA). Client Credentials Flow has no user — the app (a service or daemon) authenticates using its own identity (client ID + secret, or Managed Identity). Used for background jobs, APIs calling other APIs, scheduled tasks.

---

## What's Next — Day 5

Your API is secure. Now it needs **real data**. Next session covers Entity Framework Core — how it maps C# classes to database tables, how you write LINQ queries, and how you run migrations to keep the schema in sync with your code.
