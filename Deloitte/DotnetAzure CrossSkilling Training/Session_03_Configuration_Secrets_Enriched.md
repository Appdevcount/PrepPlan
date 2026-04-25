# Session 03 — Configuration & Secrets (Enriched)

**Duration:** 60 minutes
**Audience:** Developers who completed Session 02
**Goal:** Understand how .NET manages configuration across environments, use the Options pattern for strongly typed config, and securely read secrets — covering both local patterns and full Azure integration.

---

## Agenda

| Time | Topic |
|------|-------|
| 0–5 min | The Problem with Hard-Coded Config |
| 5–18 min | appsettings.json → IConfiguration |
| 18–32 min | Options Pattern — Strongly Typed Config |
| 32–42 min | Environment Variables — The Deployment Bridge |
| 42–60 min | Azure Integration (Key Vault, App Configuration, Feature Flags, Secret Rotation) |

---

## 1. The Problem with Hard-Coded Config (0–5 min)

### Mental Model
> Configuration is **knobs and dials** — different environments (dev, staging, prod) need different settings. The code stays the same; only the knobs change. If you bake settings into the code, you can't turn the knobs without redeploying.

```csharp
// WRONG — secret in source code, committed to Git, visible to all
var connectionString = "Server=prod-sql;Database=orders;Password=SuperSecret123!";

// RIGHT — same code runs everywhere; config is injected per environment
var connectionString = builder.Configuration.GetConnectionString("Default");
```

```
Code (same binary) + Config (per environment) = Running App

Dev:     reads from appsettings.Development.json
Staging: reads from environment variables
Prod:    reads secrets from Azure Key Vault
```

---

## 2. appsettings.json → IConfiguration (5–18 min)

### The Configuration Source Hierarchy

```
┌──────────────────────────────────────────────────────────────┐
│  Sources loaded in order — later ones OVERRIDE earlier ones  │
├──────────────────────────────────────────────────────────────┤
│  1. appsettings.json             (base defaults)             │
│  2. appsettings.{Environment}.json  (env-specific overrides) │
│  3. User Secrets (dev only)      (local machine only)        │
│  4. Environment Variables        (CI/CD / container inject)  │
│  5. Azure Key Vault              (secrets, highest priority) │
│  6. Command-line arguments       (ad hoc overrides)          │
└──────────────────────────────────────────────────────────────┘
```

### appsettings.json Structure

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
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

### appsettings.Development.json (overrides for local dev only)

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug"
    }
  },
  "Database": {
    "ConnectionString": "Server=localhost;Database=OrdersDb_Dev;Trusted_Connection=True;"
  }
}
```

### Reading Config with IConfiguration

```csharp
// Direct reading — works but fragile (magic strings, no IntelliSense)
var host = builder.Configuration["Email:SmtpHost"];
var port = builder.Configuration.GetValue<int>("Email:SmtpPort");
var conn = builder.Configuration.GetConnectionString("Default");

// WHY: The ":" separator navigates nested JSON
// "Email:SmtpHost" reads { "Email": { "SmtpHost": "..." } }
```

---

## 3. Options Pattern — Strongly Typed Config (18–32 min)

### Mental Model
> The Options pattern is a **typed wrapper** over the raw config dictionary. Instead of `config["Email:SmtpHost"]` (a string that can be mistyped), you get `options.SmtpHost` (a C# property with IntelliSense and compile-time safety).

### Step 1 — Define Options Classes

```csharp
public class DatabaseOptions
{
    public const string SectionName = "Database";

    public string ConnectionString { get; set; } = string.Empty;
    public int CommandTimeout { get; set; } = 30;
}

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

### Step 2 — Register with Validation

```csharp
// WHY: ValidateOnStart crashes at startup — not on the first user request
builder.Services.AddOptions<DatabaseOptions>()
    .Bind(builder.Configuration.GetSection(DatabaseOptions.SectionName))
    .ValidateDataAnnotations()
    .ValidateOnStart();

builder.Services.AddOptions<EmailOptions>()
    .Bind(builder.Configuration.GetSection(EmailOptions.SectionName))
    .ValidateDataAnnotations()
    .ValidateOnStart();
```

### Step 3 — Inject and Use

```csharp
public class EmailService : IEmailService
{
    private readonly EmailOptions _options;

    public EmailService(IOptions<EmailOptions> options)
    {
        _options = options.Value;  // WHY: .Value unpacks the typed options object
    }

    public async Task SendAsync(string to, string subject, string body)
    {
        var client = new SmtpClient(_options.SmtpHost, _options.SmtpPort);
        // ...
    }
}
```

### IOptions vs IOptionsSnapshot vs IOptionsMonitor

```
┌──────────────────────┬───────────────────────────────────────────────────┐
│  Type                │  Behavior                                         │
├──────────────────────┼───────────────────────────────────────────────────┤
│  IOptions<T>         │  Singleton — reads config once at startup         │
│  IOptionsSnapshot<T> │  Scoped — reads config once per HTTP request      │
│  IOptionsMonitor<T>  │  Singleton — reacts to live config file changes   │
└──────────────────────┴───────────────────────────────────────────────────┘
```

Use `IOptions<T>` for most cases. Use `IOptionsMonitor<T>` only when you need hot-reload without restarting.

---

## 4. Environment Variables — The Deployment Bridge (32–42 min)

### Mental Model
> Environment variables are the **handoff point** between infrastructure and your app. CI/CD pipelines, Docker containers, and cloud platforms inject values here — your app reads them transparently via `IConfiguration`.

```bash
# Use __ (double underscore) as the hierarchy separator
# WHY: ":" is not valid in environment variable names on some OS

Database__ConnectionString="Server=prod-sql;..."

# In Docker Compose
environment:
  - Database__ConnectionString=Server=prod-sql;Database=orders;...
  - Email__SmtpHost=smtp.sendgrid.com
```

### User Secrets — Safe Local Development

```bash
# Store secrets on your dev machine — NOT in the project folder
# WHY: never commit real passwords, keys, or connection strings to Git
dotnet user-secrets init
dotnet user-secrets set "Database:ConnectionString" "Server=localhost;Password=dev123"
dotnet user-secrets set "Email:SmtpPassword" "mypassword"

# Stored in %APPDATA%\Microsoft\UserSecrets\{guid}\secrets.json
# Only accessible on your machine — not in source control
```

---

## Azure Integration

> **For the Azure-focused audience** — this section covers the full Azure configuration stack: Key Vault for secrets, App Configuration for centralized non-secret settings, Feature Flags with real SDK, and secret rotation.

### Azure Key Vault — Production Secrets

```
┌──────────────────────────────────────────────────────────────────┐
│  Why Key Vault?                                                  │
│  • Connection strings never live in code, config files, or Git  │
│  • Rotated centrally — all apps pick up the new value           │
│  • Access controlled by Azure RBAC + Managed Identity           │
│  • Every read is audited in Azure Monitor                       │
└──────────────────────────────────────────────────────────────────┘
```

```bash
dotnet add package Azure.Extensions.AspNetCore.Configuration.Secrets
dotnet add package Azure.Identity
```

```csharp
var builder = WebApplication.CreateBuilder(args);

// WHY: DefaultAzureCredential uses Managed Identity on Azure,
// developer credentials locally — zero credential management in code
var keyVaultUri = new Uri(builder.Configuration["KeyVault:Uri"]!);

builder.Configuration.AddAzureKeyVault(keyVaultUri, new DefaultAzureCredential());
// "Database--ConnectionString" in Key Vault → "Database:ConnectionString" in .NET
```

### Key Vault Secret Naming Convention

```
Key Vault secret name          →   Configuration key in .NET
───────────────────────────────────────────────────────────
Database--ConnectionString     →   Database:ConnectionString
Email--SmtpPassword            →   Email:SmtpPassword
ExternalApi--ApiKey            →   ExternalApi:ApiKey
```

*Key Vault doesn't allow `:` in names — use `--` (double dash) as the section separator.*

### Managed Identity — No Credentials Anywhere

```
Without Managed Identity:
  App reads clientId + clientSecret → authenticates to Key Vault
  Problem: you need a secret to get secrets

With Managed Identity:
  App running on Azure App Service / AKS → Azure authenticates it automatically
  No credentials in code or config — Azure handles the identity
```

```csharp
// DefaultAzureCredential tries these in order:
// 1. Environment variables     (for CI/CD pipelines)
// 2. Managed Identity          (when running on Azure)
// 3. Visual Studio credentials (local dev)
// 4. Azure CLI credentials     (local dev with 'az login')
new DefaultAzureCredential()
```

### Azure App Configuration — Centralized Non-Secret Settings

```
Problem it solves:
  You have 10 microservices. Changing "MaxPageSize" requires
  updating 10 appsettings.json files and redeploying all 10.

With Azure App Configuration:
  One change in the portal → all 10 services pick it up instantly
```

```bash
dotnet add package Microsoft.Azure.AppConfiguration.AspNetCore
```

```csharp
builder.Configuration.AddAzureAppConfiguration(options =>
{
    options.Connect(builder.Configuration["AppConfig:ConnectionString"])
           .ConfigureRefresh(refresh =>
               refresh.Register("App:Sentinel", refreshAll: true)
                      .SetCacheExpiration(TimeSpan.FromSeconds(30)));
});

app.UseAzureAppConfiguration();
```

```
Key Vault vs App Configuration — Decision Guide:
  ┌────────────────────────┬──────────────────┬──────────────────────┐
  │  Need                  │  Key Vault       │  App Configuration   │
  ├────────────────────────┼──────────────────┼──────────────────────┤
  │  Passwords / API keys  │  YES             │  No                  │
  │  Certificates          │  YES             │  No                  │
  │  Non-secret settings   │  Works but heavy │  YES                 │
  │  Feature flags         │  No              │  YES                 │
  │  Live config updates   │  No              │  YES                 │
  │  Centralize across svcs│  Possible        │  YES (designed for)  │
  └────────────────────────┴──────────────────┴──────────────────────┘
```

### Feature Flags with IFeatureManager

```bash
dotnet add package Microsoft.FeatureManagement.AspNetCore
```

```json
{
  "FeatureManagement": {
    "EnableNewCheckout": false,
    "BetaDashboard": {
      "EnabledFor": [
        { "Name": "Percentage", "Parameters": { "Value": 10 } }
      ]
    }
  }
}
```

```csharp
builder.Services.AddFeatureManagement();

public class CheckoutService
{
    private readonly IFeatureManager _featureManager;

    public CheckoutService(IFeatureManager featureManager)
        => _featureManager = featureManager;

    public async Task<CheckoutResult> CheckoutAsync(Cart cart)
    {
        // WHY: feature flag checked at runtime — no redeploy to flip the switch
        if (await _featureManager.IsEnabledAsync("EnableNewCheckout"))
            return await ProcessNewCheckoutAsync(cart);

        return await ProcessLegacyCheckoutAsync(cart);
    }
}
```

### Secret Rotation — The Concept

```
Problem: Secrets expire or get compromised. Updating them requires downtime.

With Key Vault + Managed Identity:
  1. Security team rotates the secret in Key Vault portal
  2. Old secret version stays accessible briefly (overlap period)
  3. App restart / App Configuration refresh picks up the new version
  4. Zero downtime — apps seamlessly transition to the new secret

Your code never changes. The rotation is entirely infrastructure-level.

Key Vault Versioning:
  Secret "Database--ConnectionString":
    └── version-1: old password (still active for 24h)
    └── version-2: new password (current)
```

---

## Configuration Decision Tree

```
Is it a secret (password, API key, certificate)?
    YES → Azure Key Vault
    NO  → Is it environment-specific?
              YES → appsettings.{Environment}.json or environment variable
              NO  → Is it a feature toggle needing live updates?
                        YES → Azure App Configuration with IFeatureManager
                        NO  → Is it shared across many microservices?
                                  YES → Azure App Configuration
                                  NO  → appsettings.json
```

---

## Key Takeaways

1. **Config sources stack** — later sources override earlier ones; Key Vault wins over everything.
2. **Options pattern = typed config** — bind JSON sections to C# classes for IntelliSense and compile-time safety.
3. **Validate at startup** — `ValidateOnStart()` crashes the app immediately if config is wrong.
4. **Managed Identity = no credentials** — on Azure, `DefaultAzureCredential` handles Key Vault auth automatically.
5. **Feature flags decouple deployment from release** — ship code dark, flip the flag when ready, no redeploy needed.

---

## Q&A Prompts

**1. What's the difference between `IOptions<T>` and `IOptionsMonitor<T>`?**

**Answer:** `IOptions<T>` is a Singleton — it reads the configuration once at startup and never changes. `IOptionsMonitor<T>` is also a Singleton but subscribes to configuration change events — it reloads when the underlying config source changes (e.g., when you update appsettings.json locally or when Azure App Configuration pushes a change). Use `IOptions<T>` for most cases; use `IOptionsMonitor<T>` only for settings that legitimately need to change without restarting the app (like log levels).

---

**2. If a secret is in both `appsettings.json` and Azure Key Vault, which one wins?**

**Answer:** Azure Key Vault wins because it's added last in the configuration pipeline — later sources override earlier ones. This is intentional: `appsettings.json` can hold non-secret defaults while Key Vault silently overrides the sensitive values in production with no code change.

---

**3. Why do we use `DefaultAzureCredential` instead of a client ID and secret?**

**Answer:** Using a client ID and secret to authenticate to Key Vault creates a "secret to get secrets" problem — you need to store credentials somewhere to retrieve credentials. `DefaultAzureCredential` uses Managed Identity when running on Azure (Azure handles the identity automatically — no stored credentials at all) and falls back to developer credentials locally. This eliminates the entire class of "where do I store my Key Vault credentials" problems.

---

**4. What happens if a required config value is missing and you've called `ValidateOnStart()`?**

**Answer:** The application crashes immediately at startup with a clear `OptionsValidationException` listing exactly which values failed validation. This is the desired behavior — it's far better for the app to fail loudly at startup (when a developer or deployment engineer is watching) than to fail silently on the first user request that happens to trigger the missing config path. "Fail fast, fail loud" is the principle.

---

## What's Next — Day 4

Config is secure. Now we tackle **who is calling your API**. Next session covers JWT tokens, claims-based identity, and protecting endpoints with policies — plus Microsoft Entra ID and Managed Identity for service-to-service auth.
