# Session 03 — Configuration & Secrets

**Duration:** 60 minutes
**Audience:** Developers who completed Session 02
**Goal:** Understand how .NET manages configuration across environments, apply the Options pattern for strongly-typed config, and securely read secrets from Azure Key Vault.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | The Problem with Hard-Coded Config |
| 5–20 min | appsettings.json → IConfiguration |
| 20–35 min | Options Pattern — Strongly Typed Config |
| 35–48 min | Environment Variables + Azure Key Vault |
| 48–58 min | Azure App Configuration (Feature Flags Mention) |
| 58–60 min | Key Takeaways + Q&A |

---

## 1. The Problem with Hard-Coded Config (0–5 min)

### Mental Model
> Configuration is **knobs and dials** — different environments (dev, staging, prod) need different settings. The code stays the same; only the knobs change. If you bake the settings into the code, you can't turn the knobs without redeploying.

**The bad pattern (never do this):**
```csharp
// WRONG — secret in source code, committed to Git, visible to everyone
var connectionString = "Server=prod-sql;Database=orders;Password=SuperSecret123!";
```

**What you want:**
```
Code (same binary) + Config (per environment) = Running App

Dev:     reads from appsettings.Development.json
Staging: reads from environment variables
Prod:    reads secrets from Azure Key Vault
```

---

## 2. appsettings.json → IConfiguration (5–20 min)

### The Configuration File Hierarchy

```
┌──────────────────────────────────────────────────────────────┐
│  Sources loaded in order — later ones OVERRIDE earlier ones  │
├──────────────────────────────────────────────────────────────┤
│  1. appsettings.json             (base defaults)             │
│  2. appsettings.{Environment}.json  (env-specific overrides) │
│  3. Environment Variables        (CI/CD / container inject)  │
│  4. Azure Key Vault              (secrets, highest priority) │
│  5. Command-line arguments       (ad hoc overrides)          │
└──────────────────────────────────────────────────────────────┘
```

### appsettings.json Structure

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning"
    }
  },
  "Database": {
    "ConnectionString": "Server=localhost;Database=OrdersDb;Trusted_Connection=True;",
    "CommandTimeout": 30
  },
  "Email": {
    "SmtpHost": "smtp.example.com",
    "SmtpPort": 587,
    "SenderAddress": "noreply@example.com"
  },
  "FeatureFlags": {
    "EnableNewCheckout": false
  }
}
```

### appsettings.Development.json (overrides for local dev)

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug"    // more verbose locally
    }
  },
  "Database": {
    "ConnectionString": "Server=localhost;Database=OrdersDb_Dev;Trusted_Connection=True;"
  }
}
```

### Reading Config with IConfiguration

```csharp
// ── Direct reading — works but fragile (magic strings) ───
// WHY: string keys can be mistyped with no compile-time check
var host = builder.Configuration["Email:SmtpHost"];
var port = builder.Configuration.GetValue<int>("Email:SmtpPort");
var connStr = builder.Configuration.GetConnectionString("Default");

// Better: use the Options pattern (next section)
```

**The `:` separator navigates nested JSON:** `"Email:SmtpHost"` reads `{ "Email": { "SmtpHost": "..." } }`

---

## 3. Options Pattern — Strongly Typed Config (20–35 min)

### Mental Model
> The Options pattern is a **typed wrapper** over the raw config dictionary. Instead of `config["Email:SmtpHost"]` (a string that can be mistyped), you get `options.SmtpHost` (a C# property with IntelliSense and compile-time safety).

### Step 1 — Define the Options Class

```csharp
// ── Options classes are plain C# POCOs ───────────────────
public class DatabaseOptions
{
    // WHY: "Database" must match the JSON section name exactly
    public const string SectionName = "Database";

    public string ConnectionString { get; set; } = string.Empty;
    public int CommandTimeout { get; set; } = 30;
}

public class EmailOptions
{
    public const string SectionName = "Email";

    public string SmtpHost { get; set; } = string.Empty;
    public int SmtpPort { get; set; } = 587;
    public string SenderAddress { get; set; } = string.Empty;
}
```

### Step 2 — Register in Program.cs

```csharp
// ── Bind the JSON section to the options class ────────────
builder.Services.Configure<DatabaseOptions>(
    builder.Configuration.GetSection(DatabaseOptions.SectionName));

builder.Services.Configure<EmailOptions>(
    builder.Configuration.GetSection(EmailOptions.SectionName));
```

### Step 3 — Inject and Use with IOptions<T>

```csharp
public class EmailService : IEmailService
{
    private readonly EmailOptions _options;

    // WHY: IOptions<T> is a thin wrapper — inject it, then read .Value
    public EmailService(IOptions<EmailOptions> options)
    {
        _options = options.Value;
    }

    public async Task SendAsync(string to, string subject, string body)
    {
        // Use strongly typed properties — no magic strings
        var client = new SmtpClient(_options.SmtpHost, _options.SmtpPort);
        // ...
    }
}
```

### IOptions vs IOptionsSnapshot vs IOptionsMonitor

```
┌──────────────────────┬──────────────────────────────────────────────────┐
│  Type                │  Behavior                                        │
├──────────────────────┼──────────────────────────────────────────────────┤
│  IOptions<T>         │  Singleton — reads once at startup               │
│  IOptionsSnapshot<T> │  Scoped — reads once per HTTP request            │
│  IOptionsMonitor<T>  │  Singleton — reacts to live config changes       │
└──────────────────────┴──────────────────────────────────────────────────┘
```

**Use `IOptions<T>`** for most cases.
**Use `IOptionsMonitor<T>`** only when you need hot-reload (e.g., log level changes without restart).

### Validation — Fail Fast at Startup

```csharp
// ── Validate options at startup so the app fails immediately if misconfigured ──
builder.Services.AddOptions<EmailOptions>()
    .Bind(builder.Configuration.GetSection(EmailOptions.SectionName))
    .ValidateDataAnnotations()          // validates [Required], [Range] etc.
    .ValidateOnStart();                 // crash at startup, not on first use

public class EmailOptions
{
    public const string SectionName = "Email";

    [Required]
    public string SmtpHost { get; set; } = string.Empty;

    [Range(1, 65535)]
    public int SmtpPort { get; set; } = 587;

    [Required, EmailAddress]
    public string SenderAddress { get; set; } = string.Empty;
}
```

---

## 4. Environment Variables + Azure Key Vault (35–48 min)

### Environment Variables

```bash
# Override any config value with an environment variable
# __ (double underscore) replaces : for nesting
# WHY: : is not valid in some OS environment variable names

# Equivalent to "Database:ConnectionString" in appsettings.json
Database__ConnectionString="Server=prod-sql;..."

# In Docker Compose
environment:
  - Database__ConnectionString=Server=prod-sql;Database=orders;...
  - Email__SmtpHost=smtp.sendgrid.com
```

```csharp
// In code — same IConfiguration reads env vars transparently
var conn = builder.Configuration["Database:ConnectionString"];
// Returns env var value if set, falls back to appsettings.json
```

### Azure Key Vault — Production Secrets

```
┌──────────────────────────────────────────────────────────────────┐
│  Why Key Vault?                                                  │
│                                                                  │
│  • Connection strings never live in code, config files, or Git  │
│  • Rotated centrally — all apps get the new value automatically  │
│  • Access controlled by Azure RBAC + Managed Identity           │
│  • Audited — every read is logged                               │
└──────────────────────────────────────────────────────────────────┘
```

### Step 1 — Add the NuGet Package

```bash
dotnet add package Azure.Extensions.AspNetCore.Configuration.Secrets
dotnet add package Azure.Identity
```

### Step 2 — Wire It Up in Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

// ── Add Key Vault as a config source ─────────────────────
// WHY: DefaultAzureCredential uses Managed Identity in Azure,
// developer credentials locally — zero credential management
var keyVaultUri = new Uri(builder.Configuration["KeyVault:Uri"]!);

builder.Configuration.AddAzureKeyVault(
    keyVaultUri,
    new DefaultAzureCredential());

// From here on, any config key is transparently read from Key Vault
// e.g., "Database--ConnectionString" in Key Vault maps to "Database:ConnectionString"
```

### Key Vault Secret Naming Convention

```
Key Vault secret name         →   Configuration key in .NET
──────────────────────────────────────────────────────────
Database--ConnectionString    →   Database:ConnectionString
Email--SmtpPassword           →   Email:SmtpPassword
```

*Key Vault doesn't allow `:` in names — use `--` (double dash) as a separator.*

### Managed Identity — No Credentials Needed

```
Without Managed Identity:
  App → reads clientId + clientSecret from config → authenticates to Key Vault
  Problem: you need a secret to get secrets 🔄

With Managed Identity:
  App (running on Azure App Service) → Azure automatically authenticates to Key Vault
  No credentials anywhere in code or config ✓
```

```csharp
// DefaultAzureCredential tries these in order:
// 1. Environment variables (for CI/CD pipelines)
// 2. Managed Identity (when running on Azure — App Service, AKS, Functions)
// 3. Visual Studio credentials (for local dev)
// 4. Azure CLI credentials (for local dev with az login)
// You write one line of code and it works everywhere
new DefaultAzureCredential()
```

---

## 5. Azure App Configuration — Brief Overview (48–58 min)

### When Key Vault Isn't Enough

| Need | Key Vault | App Configuration |
|------|-----------|-------------------|
| Store secrets | ✓ | ✗ (not for secrets) |
| Feature flags | ✗ | ✓ |
| Centralized non-secret config | Works but is extra | ✓ |
| Real-time config push to all instances | ✗ | ✓ |

### Feature Flags — The Concept

```csharp
// ── appsettings.json feature flag ────────────────────────
{
  "FeatureFlags": {
    "EnableNewCheckout": false
  }
}

// ── Reading the flag ──────────────────────────────────────
public class CheckoutService
{
    private readonly IConfiguration _config;

    public CheckoutService(IConfiguration config) => _config = config;

    public Task<CheckoutResult> CheckoutAsync(Cart cart)
    {
        bool useNewFlow = _config.GetValue<bool>("FeatureFlags:EnableNewCheckout");

        return useNewFlow
            ? ProcessNewCheckoutAsync(cart)
            : ProcessLegacyCheckoutAsync(cart);
    }
}
```

**With Azure App Configuration:** flip the flag in the Azure portal → all running instances pick it up within seconds, no redeploy needed.

---

## Configuration Decision Tree

```
Is it a secret (password, API key, certificate)?
    YES → Azure Key Vault
    NO  → Is it environment-specific?
              YES → appsettings.{Environment}.json or environment variable
              NO  → Is it a feature toggle needing live updates?
                        YES → Azure App Configuration
                        NO  → appsettings.json
```

---

## Key Takeaways

1. **Config sources stack** — later sources override earlier ones; Key Vault wins over appsettings.
2. **Options pattern = typed config** — bind JSON sections to C# classes; get IntelliSense and compile-time safety.
3. **Validate at startup** — `ValidateOnStart()` crashes the app immediately if config is wrong, not on the first user request.
4. **Managed Identity = no credentials** — running on Azure, `DefaultAzureCredential` handles auth to Key Vault automatically.
5. **`--` in Key Vault names = `:` in .NET** — Key Vault doesn't allow colons; double-dash maps to config hierarchy.

---

## Q&A Prompts

1. What's the difference between `IOptions<T>` and `IOptionsMonitor<T>`?
2. If a secret is in both `appsettings.json` and Azure Key Vault, which one wins?
3. Why do we use `DefaultAzureCredential` instead of a client ID/secret?
4. What happens if a required config value is missing and you've called `ValidateOnStart()`?

---

## What's Next — Day 4

Config is secure. Now we tackle **who is calling your API**. Next session covers JWT tokens, claims-based identity, and how to protect endpoints with policies — plus a brief look at Microsoft Entra ID and Managed Identity for service-to-service auth.
