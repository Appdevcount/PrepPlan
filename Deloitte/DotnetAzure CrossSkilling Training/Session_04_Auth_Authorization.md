# Session 04 — Authentication & Authorization

**Duration:** 60 minutes
**Audience:** Developers who completed Session 03
**Goal:** Understand the difference between AuthN and AuthZ, read and validate a JWT token, protect endpoints with claims and policies, and know where Entra ID and Managed Identity fit in.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | Authentication vs Authorization — The Core Distinction |
| 5–20 min | JWT Token — What's Inside and How It Works |
| 20–35 min | Protecting Endpoints in ASP.NET Core |
| 35–48 min | Policy-Based Authorization |
| 48–57 min | Microsoft Entra ID + Managed Identity (Concept) |
| 57–60 min | Key Takeaways + Q&A |

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
- Only the identity provider (Entra ID / your auth server) has the private key
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

## 3. Protecting Endpoints in ASP.NET Core (20–35 min)

### Step 1 — Add JWT Bearer Authentication

```csharp
// ── Program.cs ────────────────────────────────────────────
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // WHY: Authority is the identity provider's base URL
        // ASP.NET Core will auto-fetch public keys from {Authority}/.well-known/openid-configuration
        options.Authority = builder.Configuration["Jwt:Authority"];

        // WHY: Audience ensures this token was issued FOR this specific API
        // Prevents tokens for other apps from being used here
        options.Audience = builder.Configuration["Jwt:Audience"];

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,        // reject expired tokens
            ClockSkew = TimeSpan.Zero       // no tolerance for expiry — be strict
        };
    });

builder.Services.AddAuthorization();

// ── Middleware — order is critical ───────────────────────
app.UseAuthentication();  // must come BEFORE UseAuthorization
app.UseAuthorization();
```

### Step 2 — Protect Endpoints

```csharp
// ── Require authentication on a single endpoint ───────────
app.MapGet("/orders", async (IOrderService svc) =>
    Results.Ok(await svc.GetAllAsync()))
    .RequireAuthorization();  // returns 401 if no valid JWT

// ── Allow anonymous (public endpoint) ────────────────────
app.MapGet("/health", () => Results.Ok("Healthy"))
    .AllowAnonymous();

// ── Require a specific role ───────────────────────────────
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
    // ClaimsPrincipal is populated by JWT middleware after token validation
    var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    var email  = context.User.FindFirst(ClaimTypes.Email)?.Value;
    var roles  = context.User.FindAll(ClaimTypes.Role).Select(c => c.Value);

    return Results.Ok(new { userId, email, roles });
})
.RequireAuthorization();
```

---

## 4. Policy-Based Authorization (35–48 min)

### Mental Model
> Role checks are blunt instruments (`"Admin"` or not). **Policies** let you express rich business rules: "user must be an Admin AND from the EU region AND their account must be older than 30 days."

### Defining a Policy

```csharp
// ── Register named policies in Program.cs ────────────────
builder.Services.AddAuthorization(options =>
{
    // Simple role-based policy
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));

    // Claim-based policy
    options.AddPolicy("PremiumUser", policy =>
        policy.RequireClaim("subscription", "premium", "enterprise"));

    // Combined policy
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
.RequireAuthorization("SeniorManager");   // uses the named policy
```

### Custom Requirements (Advanced — 2-Minute Mention)

```csharp
// When built-in checks aren't enough, implement IAuthorizationRequirement
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

// Register
builder.Services.AddSingleton<IAuthorizationHandler, MinimumAgeHandler>();
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("Over18", p => p.Requirements.Add(new MinimumAgeRequirement(18)));
});
```

---

## 5. Microsoft Entra ID + Managed Identity — Concepts (48–57 min)

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
│  • Register the app in Entra ID portal (App Registration)            │
│  • Configure Authority = https://login.microsoftonline.com/{tenant}  │
│  • Configure Audience = your app's client ID                         │
└──────────────────────────────────────────────────────────────────────┘
```

### App Registration — What You Configure

```
Entra ID → App Registration → Your API App
    │
    ├── Application ID (Client ID) → your Audience value
    ├── Tenant ID → part of your Authority URL
    ├── API Scopes (e.g., "orders.read", "orders.write")
    └── Expose an API → clients must request a scope to call your API
```

### Managed Identity — Service to Service Auth

```
Scenario: Your API needs to call another internal API.
Problem:  How does API-A prove its identity to API-B?
Solution: Managed Identity

Without Managed Identity:
  API-A stores clientId + clientSecret in config → API-B validates them
  Risk: secrets can be stolen, rotated poorly

With Managed Identity:
  API-A (running on Azure) → asks Azure for a token automatically
  No credentials stored anywhere in code or config
```

```csharp
// API-A calling API-B using Managed Identity
// The SDK handles token acquisition transparently
var credential = new DefaultAzureCredential();
var token = await credential.GetTokenAsync(
    new TokenRequestContext(new[] { "https://api-b.example.com/.default" }));

httpClient.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Bearer", token.Token);
```

### The RBAC Mental Model

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

1. **AuthN first, then AuthZ** — `UseAuthentication()` must come before `UseAuthorization()` in middleware.
2. **JWT is signed, not encrypted** — anyone can read the payload; only the issuer can create a valid signature.
3. **Policies > role checks** — use named policies for rich, reusable authorization rules.
4. **Entra ID is the enterprise identity provider** — your API trusts its tokens by pointing Authority + Audience at it.
5. **Managed Identity = no credentials** — Azure-hosted services authenticate to each other without storing secrets.

---

## Q&A Prompts

1. What's the difference between `401 Unauthorized` and `403 Forbidden`? *(Answer: 401 = not authenticated, 403 = authenticated but not allowed)*
2. Why do we validate the `audience` (aud) claim in a JWT?
3. What would happen if you called `UseAuthorization()` before `UseAuthentication()`?
4. Can a JWT token be tampered with and still pass validation?

---

## What's Next — Day 5

Your API is secure. Now it needs **real data**. Next session covers Entity Framework Core — how it maps C# classes to database tables, how you write LINQ queries, and how you run migrations to keep the schema in sync with your code.
