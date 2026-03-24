# 07 — Security Patterns

> **Mental Model:** Security is like an onion — multiple layers, each independent.
> If one layer is bypassed, the next still holds. Never rely on a single check.
> Validate at every boundary. Trust nothing from outside your process.

---

## Authentication — JWT + Refresh Token Pattern

```csharp
// ── JWT validation setup ──────────────────────────────────────────────────────
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            // WHY from Key Vault: never store signing keys in appsettings or env vars
            IssuerSigningKey = new SymmetricSecurityKey(
                Convert.FromBase64String(builder.Configuration["Jwt:SigningKey"]!)),

            ValidateIssuer   = true,
            ValidIssuer      = builder.Configuration["Jwt:Issuer"],

            ValidateAudience = true,
            ValidAudience    = builder.Configuration["Jwt:Audience"],

            ValidateLifetime = true,
            // WHY 0 ClockSkew: default is 5 min — tokens stay valid 5min after expiry.
            //   In an enterprise setting, 5min is a long window for a stolen token.
            ClockSkew = TimeSpan.Zero,

            // WHY NameClaimType: maps the standard "sub" claim to User.Identity.Name
            NameClaimType   = ClaimTypes.NameIdentifier,
            RoleClaimType   = ClaimTypes.Role
        };

        // Support token from query string for SignalR connections
        // WHY: WebSocket handshake can't set custom headers in browsers
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = ctx =>
            {
                var token = ctx.Request.Query["access_token"];
                if (!string.IsNullOrEmpty(token) &&
                    ctx.Request.Path.StartsWithSegments("/hubs"))
                {
                    ctx.Token = token;
                }
                return Task.CompletedTask;
            }
        };
    });

// ── Authorization policies ────────────────────────────────────────────────────
builder.Services.AddAuthorization(opts =>
{
    // Default policy — all routes require auth unless explicitly [AllowAnonymous]
    // WHY: opt-out is safer than opt-in. Forgetting to add [Authorize] = security hole.
    opts.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();

    opts.AddPolicy("OrderWrite", policy =>
        policy.RequireRole("Admin", "OrderManager")
              .RequireClaim("department", "operations"));

    opts.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin")
              .RequireClaim("mfa_verified", "true"));   // require MFA for admin actions
});
```

---

## HMAC Signature Validation (Webhook Security)

```csharp
// WHY HMAC: proves the webhook was sent by the expected source.
//   Anyone can POST to your endpoint. HMAC signature means only the holder of
//   the shared secret could have generated this exact payload.

public class WebhookSignatureValidator(IOptions<WebhookOptions> opts)
{
    private readonly byte[] _secretBytes = Encoding.UTF8.GetBytes(opts.Value.Secret);

    public async Task<bool> IsValidAsync(HttpRequest request, CancellationToken ct)
    {
        // Read raw body BEFORE any deserialization — signature is over the exact bytes
        request.EnableBuffering();   // WHY: allows re-reading the body after signature check
        using var reader = new StreamReader(request.Body, leaveOpen: true);
        var body = await reader.ReadToEndAsync(ct);
        request.Body.Position = 0;   // reset for model binding after validation

        var receivedSignature = request.Headers["X-Webhook-Signature"].FirstOrDefault();
        if (string.IsNullOrEmpty(receivedSignature))
            return false;

        // Compute expected signature
        var computedHash = HMACSHA256.HashData(_secretBytes, Encoding.UTF8.GetBytes(body));
        var expectedSignature = $"sha256={Convert.ToHexString(computedHash).ToLower()}";

        // WHY CryptographicEquals not string ==:
        //   Standard string comparison short-circuits on first mismatch.
        //   Timing attacks measure how long comparison takes to determine secret length.
        //   CryptographicEquals always takes the same time regardless of where mismatch is.
        return CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(receivedSignature),
            Encoding.UTF8.GetBytes(expectedSignature));
    }
}
```

---

## Input Validation — Defence at Boundaries

```csharp
// ── RULE: Validate ALL input at system boundaries (API endpoints, queue consumers).
//    Assume all input is hostile until proven otherwise.

// ── 1. FluentValidation — business rules ─────────────────────────────────────
public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty()
            .Must(id => id != Guid.Empty).WithMessage("Customer ID cannot be empty GUID");

        RuleFor(x => x.Items)
            .NotEmpty().WithMessage("Order must have at least one item")
            .Must(items => items.Count <= 100).WithMessage("Order cannot exceed 100 items");

        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.Quantity).InclusiveBetween(1, 1000);
            item.RuleFor(i => i.UnitPrice).GreaterThan(0);
            // WHY max price: prevents accidental $999999.99 orders from a client bug
            item.RuleFor(i => i.UnitPrice).LessThanOrEqualTo(50_000);
        });
    }
}

// ── 2. SQL Injection — always use parameterised queries ───────────────────────

// ❌ WRONG — string interpolation = SQL injection
var orders = db.Database.ExecuteSqlRaw(
    $"SELECT * FROM Orders WHERE Status = '{status}'");

// ✅ CORRECT — parameterised (EF Core or raw SQL)
var orders = db.Orders.Where(o => o.Status == status).ToList();

// ✅ CORRECT — raw SQL with parameters
var orders = db.Orders.FromSqlRaw(
    "SELECT * FROM Orders WHERE Status = {0}", status).ToList();

// ── 3. Never trust user-controlled file paths ─────────────────────────────────

// ❌ WRONG — path traversal: attacker sends "../../../etc/passwd"
var content = File.ReadAllText(Path.Combine(basePath, userProvidedFileName));

// ✅ CORRECT — sanitise and validate path stays within allowed directory
public string SafeReadFile(string basePath, string userFileName)
{
    // Normalise and resolve to absolute path
    var fullPath = Path.GetFullPath(Path.Combine(basePath, userFileName));

    // Ensure the resolved path is still within the allowed directory
    if (!fullPath.StartsWith(basePath, StringComparison.OrdinalIgnoreCase))
        throw new UnauthorizedAccessException("Path traversal attempt detected");

    return File.ReadAllText(fullPath);
}
```

---

## Secrets — Never in Code or Config

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  Secret Type               │  Storage Location         │  Access Method       │
├──────────────────────────────────────────────────────────────────────────────┤
│  DB connection strings     │  Azure Key Vault           │  Managed Identity    │
│  API keys (third-party)    │  Azure Key Vault           │  Managed Identity    │
│  JWT signing keys          │  Azure Key Vault           │  Managed Identity    │
│  Service Bus conn strings  │  Azure Key Vault           │  Managed Identity    │
│  Local dev secrets         │  dotnet user-secrets       │  IConfiguration      │
│  CI/CD pipeline secrets    │  Azure DevOps Secrets      │  Pipeline variable   │
└──────────────────────────────────────────────────────────────────────────────┘

NEVER:
  ❌ Store secrets in appsettings.json (committed to git)
  ❌ Store secrets in environment variables in production (visible in process list)
  ❌ Log secrets or tokens (even partially — "Bearer tok..." in logs)
  ❌ Return secrets in API responses (even for debugging)
  ❌ Commit .env files (add to .gitignore on day one)
```

---

## Error Response Security

```csharp
// ── RULE: Never expose internal details in error responses ────────────────────

// ❌ WRONG — exposes stack trace, connection string, internal class names
return Results.Problem(
    detail: ex.ToString(),          // full stack trace in response
    title: ex.GetType().Name        // internal class name
);

// ✅ CORRECT — log internally, return safe generic message + trace ID
app.UseExceptionHandler(errApp => errApp.Run(async ctx =>
{
    var feature = ctx.Features.Get<IExceptionHandlerFeature>();
    var ex = feature?.Error;

    // Log with full detail internally — correlate with trace ID
    logger.LogError(ex, "Unhandled exception. TraceId: {TraceId}", ctx.TraceIdentifier);

    ctx.Response.StatusCode = StatusCodes.Status500InternalServerError;
    await ctx.Response.WriteAsJsonAsync(new
    {
        // Only the trace ID goes to the client — operations can look it up in logs
        TraceId = ctx.TraceIdentifier,
        Message = "An unexpected error occurred. Contact support with TraceId."
        // WHY no stack trace: attackers use class names and paths to probe the system
    });
}));
```

---

## CORS — Strict Configuration

```csharp
// WHY explicit origins: wildcard "*" with credentials is a CORS vulnerability.
//   Always enumerate allowed origins explicitly.

builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
    {
        policy.WithOrigins(
                builder.Configuration.GetSection("AllowedOrigins").Get<string[]>()!)
              .WithMethods("GET", "POST", "PUT", "DELETE")   // WHY not AllowAnyMethod: least privilege
              .WithHeaders("Content-Type", "Authorization", "X-Correlation-Id")
              .AllowCredentials();   // WHY: cookies/auth headers need this
    });
});

// ❌ WRONG — opens to all origins (XSS + CORS = data theft)
policy.AllowAnyOrigin().AllowCredentials();   // not allowed by browsers anyway
```

---

## Security Headers

```csharp
// WHY security headers: defend against XSS, clickjacking, MIME sniffing.
//   Browser enforces these — cheap protection with no code changes needed.

app.Use(async (ctx, next) =>
{
    ctx.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    // WHY nosniff: prevents browser from guessing MIME type — blocks some XSS vectors

    ctx.Response.Headers.Append("X-Frame-Options", "DENY");
    // WHY DENY: prevents clickjacking — page cannot be embedded in an iframe

    ctx.Response.Headers.Append("X-XSS-Protection", "1; mode=block");

    ctx.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    // WHY: prevents URL leakage (e.g. /orders/12345 in Referer header to third parties)

    ctx.Response.Headers.Append("Content-Security-Policy",
        "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'");
    // WHY CSP: mitigates XSS by whitelisting allowed script/style sources

    await next();
});
```
