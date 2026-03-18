# CareCoordination Backend — Memory Leak, Performance & GC Analysis Report

**Date:** 2026-03-18
**Solution:** CareCoordination Backend (.NET 9.0)
**Scope:** Memory leaks · Performance bottlenecks · GC pressure · Resource disposal

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Issue Index by Severity](#2-issue-index-by-severity)
3. [CRITICAL — Memory Leaks](#3-critical--memory-leaks)
   - [3.1 DbService — Undisposed SqlConnection (Scoped Lifetime)](#31-dbservice--undisposed-sqlconnection-scoped-lifetime)
   - [3.2 FileHandler — Blocking Async + Undisposed HttpResponseMessage](#32-filehandler--blocking-async--undisposed-httpresponsemessage)
   - [3.3 ApiTokenCacheClient — Blocking .Result + Undisposed HttpResponseMessage](#33-apitokencacheclient--blocking-result--undisposed-httpresponsemessage)
4. [HIGH — Performance Overhead](#4-high--performance-overhead)
   - [4.1 Reflection in Hot Path (ObjectExtensionsManagement)](#41-reflection-in-hot-path-objectextensionsmanagement)
   - [4.2 Non-Compiled Regex Allocated per Call (DashboardView)](#42-non-compiled-regex-allocated-per-call-dashboardview)
   - [4.3 JwtHelper — Allocates Dictionary + Parses JWT per Request](#43-jwthelper--allocates-dictionary--parses-jwt-per-request)
   - [4.4 Duplicate IDbConnection Registration vs DbService](#44-duplicate-idbconnection-registration-vs-dbservice)
5. [HIGH — GC Pressure](#5-high--gc-pressure)
   - [5.1 Thread Pool Starvation via .Result/.GetAwaiter().GetResult()](#51-thread-pool-starvation-via-resultgetawaitergetresult)
   - [5.2 DataTable Created on Every Dashboard Request](#52-datatable-created-on-every-dashboard-request)
   - [5.3 Large Object Heap Pressure from Combined Search Results](#53-large-object-heap-pressure-from-combined-search-results)
6. [MEDIUM — Resource & Disposal Issues](#6-medium--resource--disposal-issues)
   - [6.1 IGridReaderWrapper Does Not Extend IDisposable — Consumers Cannot Use `using`](#61-igridreaderwrapper-does-not-extend-idisposable--consumers-cannot-use-using)
   - [6.2 HttpClientHandler Allocated per Request but Never Pooled](#62-httpclienthandler-allocated-per-request-but-never-pooled)
   - [6.3 AppInsightsLogger — TelemetryClient Created per Singleton Instance](#63-appinsightslogger--telemetryclient-created-per-singleton-instance)
   - [6.4 Stream from OpenReadStream Never Explicitly Closed](#64-stream-from-openreadstream-never-explicitly-closed)
7. [MEDIUM — Concurrency & Cache Issues](#7-medium--concurrency--cache-issues)
   - [7.1 Static Lock in ApiTokenCacheClient Causes Thread Contention](#71-static-lock-in-apitokencacheclient-causes-thread-contention)
   - [7.2 Cache Expiration Uses DateTime.Now Instead of DateTime.UtcNow](#72-cache-expiration-uses-datetimenow-instead-of-datetimeutcnow)
   - [7.3 CacheItemPriority.High Prevents Memory Pressure Eviction](#73-cacheitempriorityHigh-prevents-memory-pressure-eviction)
8. [MEDIUM — Rate Limiter Fail-Open Design](#8-medium--rate-limiter-fail-open-design)
9. [LOW — Code Quality & Minor Overhead](#9-low--code-quality--minor-overhead)
   - [9.1 Hardcoded "Sleep Testing" Bypass in Production Code](#91-hardcoded-sleep-testing-bypass-in-production-code)
   - [9.2 DI Lifetime Inconsistency — Mixed Scoped/Transient Dependencies](#92-di-lifetime-inconsistency--mixed-scopedtransient-dependencies)
   - [9.3 AutoMapper Loaded via AppDomain Scan](#93-automapper-loaded-via-appdomain-scan)
   - [9.4 Unnecessary Program.cs Using Statements](#94-unnecessary-programcs-using-statements)
10. [Summary Table](#10-summary-table)

---

## 1. Executive Summary

This report documents **18 distinct issues** across the CareCoordination backend solution, ranging from memory leaks that will cause production incidents under sustained load, to GC pressure that reduces throughput, to minor code-quality concerns.

The most critical finding is the combination of:
- A `SqlConnection` created inside `DbService` that is **never disposed**, held for the lifetime of the HTTP scope.
- Widespread use of `.Result` / `.GetAwaiter().GetResult()` in `FileHandler` and `ApiTokenCacheClient`, which blocks ASP.NET Core thread-pool threads and can cause **thread pool starvation** under moderate concurrent load.
- `HttpResponseMessage` objects that are **never disposed**, causing socket handles and native memory to accumulate until the finalizer thread catches up.

These three issues compound each other: blocked threads hold open scoped services (including the undisposed `SqlConnection`), keeping SQL Server connections checked out of the pool until the connection pool is exhausted.

---

## 2. Issue Index by Severity

| # | Severity | File | Issue |
|---|----------|------|-------|
| 3.1 | 🔴 CRITICAL | `DbService.cs` | Undisposed SqlConnection held for entire scope |
| 3.2 | 🔴 CRITICAL | `FileHandler.cs` | Blocking `.Result` + undisposed `HttpResponseMessage` (3 methods) |
| 3.3 | 🔴 CRITICAL | `ApiTokenCacheClient.cs` | Blocking `.Result` on `PostAsync` + undisposed response |
| 4.1 | 🟠 HIGH | `ObjectExtensionsManagement.cs` | Reflection in per-result hot path, no caching |
| 4.2 | 🟠 HIGH | `DashboardView.cs` | New Regex instance per call, no compiled/cached regex |
| 4.3 | 🟠 HIGH | `JwtHelper.cs` | New `JwtSecurityTokenHandler` + Dictionary per request |
| 4.4 | 🟠 HIGH | `DAL/ServiceRegistration.cs` | Duplicate `IDbConnection` registration creates orphan connection |
| 5.1 | 🟠 HIGH | `FileHandler.cs`, `ApiTokenCacheClient.cs` | Thread pool starvation via sync-over-async |
| 5.2 | 🟠 HIGH | `DashboardView.cs` | `DataTable` allocated on every dashboard request |
| 5.3 | 🟡 MEDIUM | `RequestSearchController` / handlers | Large combined result sets causing LOH allocations |
| 6.1 | 🟡 MEDIUM | `IGridReaderWrapper.cs` / `DashboardView.cs` | `IGridReaderWrapper` does not extend `IDisposable` |
| 6.2 | 🟡 MEDIUM | `FileHandler.cs` | `HttpClientHandler` allocated per method, never pooled |
| 6.3 | 🟡 MEDIUM | `AppInsightsLogger.cs` | `TelemetryConfiguration` created inline, may not flush |
| 6.4 | 🟡 MEDIUM | `FileHandler.cs` | `Stream` from `OpenReadStream()` disposal unclear |
| 7.1 | 🟡 MEDIUM | `ApiTokenCacheClient.cs` | `static readonly` lock causes cross-request contention |
| 7.2 | 🟡 MEDIUM | `ApiTokenCacheClient.cs` | `DateTime.Now` vs token's `DateTime.UtcNow` mismatch |
| 7.3 | 🟡 MEDIUM | `ApiTokenCacheClient.cs` | `CacheItemPriority.High` blocks eviction under memory pressure |
| 8 | 🟡 MEDIUM | `DistributedRateLimiterService.cs` | Fail-open on Redis failure disables rate limiting entirely |
| 9.1 | 🔵 LOW | `DashboardView.cs` | Hardcoded `"Sleep Testing"` whitelist bypass |
| 9.2 | 🔵 LOW | `DAL/ServiceRegistration.cs` | Scoped `DbService` consumed by Transient services |
| 9.3 | 🔵 LOW | `Program.cs` | `AppDomain.CurrentDomain.GetAssemblies()` for AutoMapper scans all loaded assemblies |
| 9.4 | 🔵 LOW | `Program.cs` | ~15 unnecessary `using` directives |

---

## 3. CRITICAL — Memory Leaks

### 3.1 DbService — Undisposed SqlConnection (Scoped Lifetime)

**File:** `CareCoordination.DAL/Implementation/DbService.cs` lines 18–25
**Registration:** `CareCoordination.DAL/ServiceRegistration.cs` line 31

#### Problematic Code

```csharp
// DbService.cs
public class DbService : IDbService
{
    private readonly IDbConnection _db;

    public DbService(IConfiguration config)
    {
        _db = new SqlConnection(config.GetConnectionString("PreAuthin")); // ← created in ctor
    }

    // IDbService does NOT extend IDisposable
    // _db is NEVER disposed
}
```

```csharp
// DAL/ServiceRegistration.cs
services.AddScoped<IDbService, DbService>(); // ← Scoped = one instance per HTTP request
```

#### Root Cause

`DbService` creates a `SqlConnection` in its constructor and stores it as a field. Because:

1. `IDbService` does not extend `IDisposable`.
2. `DbService` itself does not implement `IDisposable`.
3. ASP.NET Core's DI container only disposes scoped services that implement `IDisposable`.

The connection is **never returned to the SQL Server connection pool**. Each HTTP request creates one unclosed `SqlConnection`. Under a sustained load of 100 concurrent users, 100 connections are opened and never released. SQL Server's default pool maximum is 100 connections — the application will hit connection pool exhaustion, surfacing as `"Timeout expired. The timeout period elapsed prior to obtaining a connection from the pool."`.

Furthermore, `ServiceRegistration.cs` also registers an **additional** `IDbConnection` (line 38–43) pointing to the same connection string:

```csharp
// ServiceRegistration.cs lines 38–43
services.AddScoped<IDbConnection>(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    var connectioString = configuration.GetConnectionString("PreAuthin");
    return new SqlConnection(connectioString); // ← second orphaned connection per scope
});
```

This second registration is never injected anywhere (no service depends on `IDbConnection` directly), so it creates a scoped `SqlConnection` that is also never disposed.

#### Impact

- **Connection pool exhaustion** under moderate load
- **Memory leak**: each `SqlConnection` holds a socket, native memory handles, and internal buffers
- **Silent degradation**: timeouts appear non-deterministically as pool fills up

#### Recommended Fix

```csharp
// DbService.cs — implement IDisposable and open connection lazily
public class DbService : IDbService, IDisposable
{
    private readonly string _connectionString;
    private IDbConnection? _db;
    private bool _disposed;

    public DbService(IConfiguration config)
    {
        _connectionString = config.GetConnectionString("PreAuthin")
            ?? throw new InvalidOperationException("Connection string 'PreAuthin' not configured.");
    }

    private IDbConnection GetConnection()
    {
        if (_db == null || _db.State == ConnectionState.Closed)
        {
            _db = new SqlConnection(_connectionString);
        }
        return _db;
    }

    public async Task<IEnumerable<T>> QueryAsync<T>(string command, object? parms,
        CommandType? commandType, IDbTransaction? transaction = null, int? commandTimeout = null)
    {
        return await GetConnection().QueryAsync<T>(command, parms, transaction, commandTimeout, commandType);
    }

    // ... other methods use GetConnection() the same way

    public void Dispose()
    {
        if (!_disposed)
        {
            _db?.Dispose();
            _disposed = true;
        }
        GC.SuppressFinalize(this);
    }
}

// ServiceRegistration.cs — remove the redundant IDbConnection registration (lines 38-43)
// Remove: services.AddScoped<IDbConnection>(sp => { ... });
```

---

### 3.2 FileHandler — Blocking Async + Undisposed HttpResponseMessage

**File:** `CareCoordination.Services/Implementation/FileHandler.cs`

#### Problematic Code

**Method `PostToOVEndpoint` (lines 83–92):**
```csharp
HttpResponseMessage response = client.SendAsync(request).Result; // ← BLOCKS thread
if (response.IsSuccessStatusCode)
{
    string resultAsString = response.Content.ReadAsStringAsync().Result; // ← BLOCKS again
    // ... response is NEVER disposed
}
// response goes out of scope — finalizer must clean up socket handles
```

**Method `GetListOfObjects` (lines 124, 149–155):**
```csharp
var token = apiTokenCacheClient.GetApiToken(AccessTokenURLAsKey).Result; // ← BLOCKS
// ...
HttpResponseMessage response = client.SendAsync(request).Result; // ← BLOCKS
if (response.IsSuccessStatusCode)
{
    string resultAsString = response.Content.ReadAsStringAsync().Result; // ← BLOCKS
    uploadedfiles = JsonConvert.DeserializeObject<List<UploadedFileDataModel>>(resultAsString);
    // response is NEVER disposed
}
```

**Method `DeleteFile` (lines 220, 240):**
```csharp
var token = apiTokenCacheClient.GetApiToken(AccessTokenURLAsKey).Result; // ← BLOCKS
// ...
HttpResponseMessage response = client.SendAsync(request).Result; // ← BLOCKS
// response is NEVER disposed in either the success or failure branch
```

#### Root Cause

**Issue A — Blocking (.Result):** `.Result` on a `Task` blocks the calling thread synchronously. ASP.NET Core thread-pool threads are finite. Under concurrent load, all threads become blocked waiting for I/O completion, and no threads are available to service new requests. This is **thread pool starvation** — a well-known deadlock-inducing pattern in ASP.NET Core.

**Issue B — Undisposed `HttpResponseMessage`:** `HttpResponseMessage` implements `IDisposable`. It wraps an `HttpContent` which holds the response body stream. Internally, `HttpContent` may hold a `MemoryStream` buffer. If the response is not disposed, the stream is not returned/released until the GC finalizer runs. Under sustained traffic, finalizers queue up faster than they run, increasing memory pressure and Gen2 GC frequency.

Additionally, the `HttpClientHandler` is created inside each method:
```csharp
// lines 57-59, 130-132, 176-180, 227-229
HttpClientHandler handler = new HttpClientHandler();
handler.ClientCertificateOptions = ClientCertificateOption.Manual;
handler.ClientCertificates.Add(ClientCertificateHelper.GetX509Certificate2(config));
```

This `handler` is **never used** (it's created but never passed to `HttpClient`). The `HttpClient` used is the one from `_httpClientFactory.CreateClient()`, which uses its own internally managed handler. The locally created `HttpClientHandler` is just wasted allocation.

#### Impact

- Thread pool starvation under > ~10 concurrent file operations
- Native socket/memory handle accumulation from undisposed responses
- Increased Gen2 GC frequency from finalizer-driven cleanup

#### Recommended Fix

```csharp
// PostToOVEndpoint — convert to async and use using
public async Task<UploadedFilePropertiesModel?> PostToOVEndpointAsync(
    UploadedFileModel uploadedFile, HttpContext httpContext)
{
    var client = _httpClientFactory.CreateClient();
    client.Timeout = TimeSpan.FromSeconds(30);
    UploadedFilePropertiesModel? res = null;

    var token = await apiTokenCacheClient.GetApiToken("OVAccessToken");
    if (string.IsNullOrEmpty(token)) return res;

    var file = uploadedFile.file;
    var fileNameSafe = RemoveSpecialCharacters(file?.FileName ?? "");
    var amSPostUrl = config.GetSection("OAuthSettings:OV:AMSPost").Value ?? string.Empty;

    using var request = new HttpRequestMessage(HttpMethod.Post, amSPostUrl);
    // ... add headers ...
    request.Headers.Add("Authorization", "Bearer " + token);

    await using var uploadStream = file?.OpenReadStream() ?? Stream.Null;
    request.Content = new StreamContent(uploadStream);
    request.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

    using var response = await client.SendAsync(request); // ← proper async + disposal
    if (response.IsSuccessStatusCode)
    {
        var resultAsString = await response.Content.ReadAsStringAsync();
        if (!string.IsNullOrEmpty(resultAsString))
        {
            res = JsonConvert.DeserializeObject<UploadedFilePropertiesModel>(resultAsString);
            // ... insert tracking
        }
    }
    return res;
}
```

---

### 3.3 ApiTokenCacheClient — Blocking .Result + Undisposed HttpResponseMessage

**File:** `CareCoordination.Services/Implementation/ApiTokenCacheClient.cs` lines 108–139

#### Problematic Code

```csharp
public async Task<AccessTokenItem?> GetOAuthToken(string api_name)
{
    var client = _httpClientFactory.CreateClient();
    client.Timeout = TimeSpan.FromSeconds(30);
    // ...
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

    // Line 129 — async method marked, but blocks synchronously inside
    HttpResponseMessage response = client.PostAsync(AccessTokenURL, new FormUrlEncodedContent(oAuthData)).Result;

    if (response.IsSuccessStatusCode)
    {
        string resultAsString = await response.Content.ReadAsStringAsync(); // ← mix: .Result then await
        oauthResult = JsonConvert.DeserializeObject<AccessTokenItem>(resultAsString) ?? new AccessTokenItem();
        oauthResult.ExpiresIn = DateTime.UtcNow.AddSeconds(oauthResult.Expires_in);
    }

    return oauthResult;
    // response is NEVER disposed — socket handle leak
}
```

#### Root Cause

- The method is declared `async Task<>` but uses `.Result` on line 129, negating the async benefit and risking deadlock if called from a synchronization context.
- `FormUrlEncodedContent` wraps client credentials (ClientSecret). If the response is not disposed, the request and response body buffers remain alive until GC.
- Every token refresh (which happens approximately every 10 minutes per sliding window expiry) leaks one socket/handle until the finalizer runs.

#### Impact

- Hidden socket handle leak on each token refresh cycle
- Potential deadlock under certain ASP.NET Core synchronization contexts
- Inconsistent error handling: if `PostAsync` throws, the exception propagates on a thread-pool thread via `.Result`, potentially as an `AggregateException`

#### Recommended Fix

```csharp
public async Task<AccessTokenItem?> GetOAuthToken(string api_name)
{
    using var client = _httpClientFactory.CreateClient();
    client.Timeout = TimeSpan.FromSeconds(30);
    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

    var oAuthData = CreateOAuthTokenFetchHeaders(api_name);
    // Determine URL based on api_name ...
    var accessTokenUrl = ResolveAccessTokenUrl(api_name);

    using var content = new FormUrlEncodedContent(oAuthData);
    using var response = await client.PostAsync(accessTokenUrl, content); // ← fully async + disposed

    if (!response.IsSuccessStatusCode) return null;

    var resultAsString = await response.Content.ReadAsStringAsync();
    var oauthResult = JsonConvert.DeserializeObject<AccessTokenItem>(resultAsString) ?? new AccessTokenItem();
    oauthResult.ExpiresIn = DateTime.UtcNow.AddSeconds(oauthResult.Expires_in);

    _applicationlogger.LogInformation("GetOAuthToken response successful, Api Name: {api_name}", api_name);
    return oauthResult;
}
```

---

## 4. HIGH — Performance Overhead

### 4.1 Reflection in Hot Path (ObjectExtensionsManagement)

**File:** `CareCoordination.Application/Handlers/ObjectExtensionsManagement.cs` lines 14–42
**Called from:** `RequestSearchManagement.cs` line 33, `DashboardViewManagement.cs` line 32

#### Problematic Code

```csharp
public static T MaskPropertiesExcept<T>(this T obj, string propertyToExclude)
    where T : class, new()
{
    ArgumentNullException.ThrowIfNull(obj);

    T maskedObj = new T();
    // ← Called EVERY TIME, for EVERY result object in search results
    PropertyInfo[] properties = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);

    foreach (var prop in properties)
    {
        if (!prop.CanRead || !prop.CanWrite) continue;

        if (string.Equals(prop.Name, "IsRestrictedMember", ...) || ...)
        {
            prop.SetValue(maskedObj, prop.GetValue(obj));    // reflection set/get
        }
        else
        {
            object maskedValue = GetMaskedValue(prop.PropertyType)!;
            prop.SetValue(maskedObj, maskedValue);           // reflection set
        }
    }
    return maskedObj;
}
```

**Called in dashboard:**
```csharp
// DashboardViewManagement.cs lines 28–35
response.DashboardDetails = response.DashboardDetails?.Select(result =>
{
    if (result.IsRestrictedMember && !user.HasLEA)
    {
        return result.MaskPropertiesExcept<DashboardDetail>("CareCoordinationEpisodeId"); // ← per row
    }
    return result;
}).ToList();
```

#### Root Cause

`typeof(T).GetProperties()` uses reflection to enumerate all properties at runtime. This:
- Allocates a new `PropertyInfo[]` array on every invocation
- Each `prop.GetValue()` / `prop.SetValue()` is ~10–100× slower than direct property access
- For a dashboard with 50 restricted rows, `GetProperties()` is called 50 times and returns the same array each time — 50 redundant allocations

#### Impact

- Measurable latency spike on dashboard loads with large restricted member sets
- Significant Gen0 GC pressure from repeated `PropertyInfo[]` allocations
- CPU-bound work that can be entirely eliminated

#### Recommended Fix

Cache the `PropertyInfo[]` in a `static ConcurrentDictionary<Type, PropertyInfo[]>`:

```csharp
private static readonly ConcurrentDictionary<Type, PropertyInfo[]> _propertyCache
    = new ConcurrentDictionary<Type, PropertyInfo[]>();

public static T MaskPropertiesExcept<T>(this T obj, string propertyToExclude)
    where T : class, new()
{
    ArgumentNullException.ThrowIfNull(obj);

    T maskedObj = new T();

    // Cache lookup — GetProperties() called only ONCE per type ever
    var properties = _propertyCache.GetOrAdd(
        typeof(T),
        t => t.GetProperties(BindingFlags.Public | BindingFlags.Instance));

    foreach (var prop in properties)
    {
        if (!prop.CanRead || !prop.CanWrite) continue;
        // ... rest unchanged
    }
    return maskedObj;
}
```

For maximum performance in the long term, replace with source-generated or compiled expression trees.

---

### 4.2 Non-Compiled Regex Allocated per Call (DashboardView)

**File:** `CareCoordination.DAL/Implementation/DashboardView.cs` lines 121–131

#### Problematic Code

```csharp
public static bool IsSafeInput(string input)
{
    if (input.Equals("Sleep Testing", StringComparison.OrdinalIgnoreCase))
        return true;

    // ← New Regex NFA state machine compiled on EVERY call
    string pattern = @"\b(WAITFOR|DELAY|SLEEP|EXEC|UNION|SELECT|INSERT|DELETE|UPDATE|DROP)\b|--|;|'|""";
    return !Regex.IsMatch(input, pattern, RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(500));
}
```

This method is called for **every filter value** in `ConvertFilterDictionaryToDataTable`, plus once for `SearchTerm` and once for `SearchColumn` on every dashboard request. A request with 5 filter key-value pairs calls `IsSafeInput` 7 times, generating 7 regex compilations.

#### Root Cause

`Regex.IsMatch(string, string, ...)` with a pattern string (not a pre-compiled `Regex` object) compiles the regular expression each time (unless it is found in .NET's internal regex cache, which has a fixed size and is subject to eviction). Pre-compiling with `RegexOptions.Compiled` generates IL at startup once and reuses it indefinitely.

#### Impact

- CPU allocation on every dashboard request proportional to number of filters
- Regex NFA objects discarded to Gen0 GC after each call

#### Recommended Fix

```csharp
// Declare at class level — compiled once at class load time
private static readonly Regex _sqlInjectionPattern = new Regex(
    @"\b(WAITFOR|DELAY|SLEEP|EXEC|UNION|SELECT|INSERT|DELETE|UPDATE|DROP)\b|--|;|'|""",
    RegexOptions.IgnoreCase | RegexOptions.Compiled,
    matchTimeout: TimeSpan.FromMilliseconds(100)); // reduce timeout

public static bool IsSafeInput(string input)
{
    if (input.Equals("Sleep Testing", StringComparison.OrdinalIgnoreCase))
        return true;

    return !_sqlInjectionPattern.IsMatch(input);
}
```

---

### 4.3 JwtHelper — Allocates Dictionary + Parses JWT per Request

**File:** `CareCoordination.Api/Helpers/JwtHelper.cs` lines 8–23

#### Problematic Code

```csharp
public static string GetUserId(HttpRequest request)
{
    var token = request.Headers.Authorization.ToString().Split(" ").Last();
    if (string.IsNullOrEmpty(token)) return string.Empty;

    // ← New Dictionary allocation per call
    Dictionary<string, string> claimList = new Dictionary<string, string>();

    // ← New JwtSecurityTokenHandler per call (stateful, should be shared)
    var handler = new JwtSecurityTokenHandler();
    var jwtToken = handler.ReadJwtToken(token);
    var claims = jwtToken.Claims;

    foreach (var claim in claims)
    {
        claimList.Add(claim.Type, claim.Value); // ← O(n) dictionary fill just to do one key lookup
    }

    var userid = claimList["sub"];
    return userid;
}
```

`JwtSecurityTokenHandler` is a stateful class with internal caches. Creating a new instance per call wastes those caches. The `Dictionary<string, string>` is only used to perform a single key lookup (`"sub"`) and is immediately discarded.

#### Impact

- Two unnecessary object allocations per authenticated controller action that calls this helper
- `JwtSecurityTokenHandler` internal caches are cold every time

#### Recommended Fix

```csharp
private static readonly JwtSecurityTokenHandler _jwtHandler = new JwtSecurityTokenHandler();

public static string GetUserId(HttpRequest request)
{
    var authHeader = request.Headers.Authorization.ToString();
    var token = authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase)
        ? authHeader["Bearer ".Length..].Trim()
        : authHeader.Split(' ').Last();

    if (string.IsNullOrEmpty(token)) return string.Empty;

    var jwtToken = _jwtHandler.ReadJwtToken(token);
    return jwtToken.Claims.FirstOrDefault(c => c.Type == "sub")?.Value ?? string.Empty;
}
```

---

### 4.4 Duplicate IDbConnection Registration vs DbService

**File:** `CareCoordination.DAL/ServiceRegistration.cs` lines 31, 38–43

#### Problematic Code

```csharp
services.AddScoped<IDbService, DbService>(); // Line 31 — DbService creates its OWN connection

// Lines 38–43 — registers a SECOND scoped SqlConnection
services.AddScoped<IDbConnection>(sp =>
{
    var configuration = sp.GetRequiredService<IConfiguration>();
    var connectioString = configuration.GetConnectionString("PreAuthin");
    return new SqlConnection(connectioString); // ← orphan, never consumed
});
```

`DbService` internally creates its own `SqlConnection` in its constructor (see Issue 3.1). The separately registered `IDbConnection` is never injected into any service (nothing depends on `IDbConnection` directly). This creates two `SqlConnection` objects per HTTP scope: one inside `DbService` and one from the `IDbConnection` registration, both unclosed.

#### Impact

- Two connection pool slots consumed per request instead of one
- The orphan `IDbConnection` registration, even if `.AddScoped<IDbConnection>` eventually gets a consumer, would create a third unclosed connection

#### Recommended Fix

Remove the redundant `IDbConnection` registration entirely (lines 38–43), and fix `DbService` per Issue 3.1.

---

## 5. HIGH — GC Pressure

### 5.1 Thread Pool Starvation via .Result/.GetAwaiter().GetResult()

**Files:** `FileHandler.cs` (lines 47, 83, 86, 124, 149, 152, 220, 240), `ApiTokenCacheClient.cs` (line 129)

#### Problematic Code

```csharp
// FileHandler.cs — 8 separate blocking calls spread across 4 methods
var token = apiTokenCacheClient.GetApiToken(AccessTokenURLAsKey).GetAwaiter().GetResult(); // line 47
HttpResponseMessage response = client.SendAsync(request).Result;                             // line 83
string resultAsString = response.Content.ReadAsStringAsync().Result;                         // line 86

var token = apiTokenCacheClient.GetApiToken(AccessTokenURLAsKey).Result;                     // line 124
HttpResponseMessage response = client.SendAsync(request).Result;                             // line 149
string resultAsString = response.Content.ReadAsStringAsync().Result;                         // line 152

var token = apiTokenCacheClient.GetApiToken(AccessTokenURLAsKey).Result;                     // line 220
HttpResponseMessage response = client.SendAsync(request).Result;                             // line 240

// ApiTokenCacheClient.cs
HttpResponseMessage response = client.PostAsync(AccessTokenURL, new FormUrlEncodedContent(oAuthData)).Result; // line 129
```

#### Root Cause

ASP.NET Core's thread pool starts with `Environment.ProcessorCount` threads. Under I/O-bound work (HTTP calls, SQL queries), the runtime expects threads to be yielded back via `await`. When `.Result` is used instead:

1. Thread A calls `.Result` → blocks waiting for I/O
2. Thread pool must create a new thread to handle the next request (takes ~500ms per new thread under starvation)
3. Under N concurrent file operations, N threads are blocked, and the thread pool thrashes trying to create new threads
4. Latency spikes exponentially

The `GetAwaiter().GetResult()` pattern (line 47) is equally blocking and additionally **wraps exceptions** in `AggregateException`, making error handling more complex.

#### Impact

- Latency degrades under 10+ concurrent file operations
- Server appears unresponsive despite CPU being idle
- Risk of deadlock if a synchronization context is in scope

#### Recommended Fix

The calling chain must be made fully async. `PostToOVEndpoint`, `GetListOfObjects`, and `DeleteFile` must be converted from sync to `async Task<>`, and all callers (in `AttachmentManagement`, controllers) updated accordingly:

```csharp
// AttachmentManagement.cs
public async Task<UploadedFilePropertiesModel?> PostToOVEndpointAsync(
    UploadedFileModel fileToUpload, HttpContext httpContext)
{
    return await _fileHandler.PostToOVEndpointAsync(fileToUpload, httpContext);
}
```

---

### 5.2 DataTable Created on Every Dashboard Request

**File:** `CareCoordination.DAL/Implementation/DashboardView.cs` lines 61–75, 99–119

#### Problematic Code

```csharp
public async Task<DashboardLoadResponseModel> GetDashboardDetails(DashboardLoadRequestModel request)
{
    // ...

    // ← DataTable allocated even when FilterDetails is null/empty
    DataTable filterDetailsDataTable = new DataTable();
    filterDetailsDataTable.Columns.Add("FilterKey", typeof(string));
    filterDetailsDataTable.Columns.Add("FilterValue", typeof(string));

    if (request?.FilterDetails?.Count > 0)
    {
        filterDetailsDataTable = ConvertFilterDictionaryToDataTable(request?.FilterDetails);
        // ← if ANY filter fails validation, returns yet another new DataTable()
        if (filterDetailsDataTable.Rows.Count == 0)
        {
            toRet.IsSuccess = false;
            toRet.Error = "SQL Injection detected. Canceling the execution.";
            return toRet;
        }
    }
    // ...
}

public static DataTable ConvertFilterDictionaryToDataTable(Dictionary<string, string>? filterDetails)
{
    var dataTable = new DataTable(); // ← Third DataTable potentially created here
    // ...
    if (...fails...)
    {
        return new DataTable(); // ← Fourth DataTable if injection detected
    }
    return dataTable;
}
```

`DataTable` is a heavyweight object: it allocates internal `DataColumnCollection`, `DataRowCollection`, constraint lists, and event handlers. Creating 2–4 `DataTable` instances per dashboard request (the initial one in `GetDashboardDetails` is always created and then potentially discarded), plus one inside `ConvertFilterDictionaryToDataTable`, is wasteful.

#### Impact

- Each `DataTable` creation involves ~10+ internal object allocations
- Most of these are short-lived, adding pressure to Gen0 GC on every dashboard load
- Under high dashboard usage, this can increase GC pause frequency

#### Recommended Fix

```csharp
// Avoid creating DataTable until needed
DataTable? filterDetailsDataTable = null;

if (request?.FilterDetails?.Count > 0)
{
    filterDetailsDataTable = ConvertFilterDictionaryToDataTable(request.FilterDetails);
    if (filterDetailsDataTable.Rows.Count == 0)
    {
        toRet.IsSuccess = false;
        toRet.Error = "SQL Injection detected. Canceling the execution.";
        return toRet;
    }
}

// Pass empty/null to the TVP helper if no filters
filterDetailsDataTable ??= CreateEmptyFilterTable();
parameters.Add("@FilterDetails", filterDetailsDataTable.AsTableValuedParameter("FilterDetailsType"));
```

---

### 5.3 Large Object Heap Pressure from Combined Search Results

**Files:** `RequestSearchManagement.cs`, `RequestSearchController.cs`

#### Problematic Code

```csharp
// RequestSearchManagement.cs
public async Task<List<RequestSearchResult>> GetRequests(GetCareCoordinationRequestModel request)
{
    List<RequestSearchResult> response = await _requestSearch.GetRequests(request);  // unbounded
    User user = _userRepository.GetUserDetails(request.UserName!);
    response = response.Select(result =>
    {
        if (result.IsRestrictedMember && !user.HasLEA)
            return result.MaskPropertiesExcept<RequestSearchResult>("CareCoordinationEpisodeId");
        return result;
    }).ToList(); // ← materialises entire result in memory
    return response;
}
```

#### Root Cause

`List<RequestSearchResult>` is returned without any server-side pagination constraint enforced at the application layer. If a stored procedure returns 1,000+ rows, each `RequestSearchResult` with 20+ properties, the list may exceed 85 KB — crossing the Large Object Heap (LOH) threshold. LOH allocations:

- Are not compacted by default (require `GCSettings.LargeObjectHeapCompactionMode = GCLargeObjectHeapCompactionMode.CompactOnce`)
- Are collected only during Gen2 GC, which is infrequent and expensive (stop-the-world)
- Fragment the LOH over time, increasing virtual memory consumption

The `.Select(...).ToList()` also materialises a second list in memory alongside the original, temporarily doubling memory usage during the LINQ projection.

#### Impact

- LOH fragmentation under high-volume search usage
- Increased Gen2 GC frequency and pause duration
- Memory usage that grows over application lifetime without compaction

#### Recommended Fix

- Enforce pagination in the DAL/stored procedure layer and reject unbounded queries
- Use `IAsyncEnumerable<T>` streaming from Dapper instead of buffered `IEnumerable<T>` for large result sets
- Project the mask operation in the LINQ query without materialising an intermediate list:

```csharp
// Stream results, apply masking inline, avoid double-materialisation
var results = await _requestSearch.GetRequests(request);
var user = _userRepository.GetUserDetails(request.UserName!);
return results
    .Select(r => r.IsRestrictedMember && !user.HasLEA
        ? r.MaskPropertiesExcept<RequestSearchResult>("CareCoordinationEpisodeId")
        : r)
    .ToList(); // single materialisation
```

---

## 6. MEDIUM — Resource & Disposal Issues

### 6.1 IGridReaderWrapper Does Not Extend IDisposable — Consumers Cannot Use `using`

**Files:**
`CareCoordination.Application/Abstracts/DALInterfaces/IGridReaderWrapper.cs`
`CareCoordination.DAL/Implementation/GridReaderWrapper.cs`
`CareCoordination.DAL/Implementation/DashboardView.cs` line 76

#### Problematic Code

```csharp
// IGridReaderWrapper.cs — does NOT extend IDisposable
public interface IGridReaderWrapper
{
    Task<IEnumerable<T>> ReadAsync<T>(bool buffered = true);
    Task<T?> ReadSingleOrDefaultAsync<T>();
    // No Dispose() method in interface
}

// GridReaderWrapper.cs — implements IDisposable, but through the concrete class only
public class GridReaderWrapper : IGridReaderWrapper
{
    private readonly SqlMapper.GridReader _gridReader;
    // Dispose() implemented on GridReaderWrapper, but NOT on IGridReaderWrapper

    public void Dispose() { ... }
}

// DashboardView.cs line 76 — uses the interface reference
using (var multi = await _dbservice.QueryMultipleAsync("CC_GetDashboardDetails", ...))
{
    // ← 'multi' is IGridReaderWrapper — compiler allows this because...
    // Wait: this only works if IGridReaderWrapper inherits IDisposable!
    // If it doesn't, this is a compiler error or the using applies to the wrong type
}
```

#### Root Cause

If `IGridReaderWrapper` does not extend `IDisposable`, callers working with the interface type cannot use the `using` statement. Any code that receives `IGridReaderWrapper` from `IDbService.QueryMultipleAsync()` and forgets to cast to `GridReaderWrapper` before disposing will leave the underlying `SqlMapper.GridReader` (and therefore its `IDataReader`) open, holding a SQL Server connection in a non-reusable state.

The `QueryMultipleAsyncForRequestDetails` in `DbService` (lines 51–62) uses `using var multi` on the raw Dapper `GridReader` (correct), but `QueryMultipleAsync` (lines 45–49) wraps it in a `GridReaderWrapper` and returns it without any disposal guarantee.

#### Impact

- SQL data reader left open if caller does not cast and dispose
- SQL connection held in "reader open" state — cannot be reused until reader is closed
- Progressive connection pool depletion

#### Recommended Fix

```csharp
// IGridReaderWrapper.cs
public interface IGridReaderWrapper : IDisposable
{
    Task<IEnumerable<T>> ReadAsync<T>(bool buffered = true);
    Task<T?> ReadSingleOrDefaultAsync<T>();
}

// All callers can now safely do:
using var multi = await _dbservice.QueryMultipleAsync(...);
```

---

### 6.2 HttpClientHandler Allocated per Request but Never Pooled

**File:** `CareCoordination.Services/Implementation/FileHandler.cs` lines 57–59, 130–132, 176–180, 227–229

#### Problematic Code

```csharp
// Created in PostToOVEndpoint, GetListOfObjects, GetFileByObjectId, DeleteFile
HttpClientHandler handler = new HttpClientHandler();
handler.ClientCertificateOptions = ClientCertificateOption.Manual;
handler.ClientCertificates.Add(ClientCertificateHelper.GetX509Certificate2(config));

// handler is NEVER passed to any HttpClient constructor
// The HttpClient used is: _httpClientFactory.CreateClient() — which has its own handler
// handler is just abandoned
```

The locally created `HttpClientHandler` is dead code — it is allocated but never referenced by the `HttpClient` that actually makes the request. It is also never disposed.

#### Impact

- Wasted allocation per file operation (4 methods × each invocation)
- `HttpClientHandler` holds a `SocketsHttpHandler` internally; abandoning it without disposal can hold OS resources until GC finalizer

#### Recommended Fix

Remove the orphaned `HttpClientHandler` creation from all four methods. If client certificates are needed, configure them via a named `HttpClient` registration in DI at startup:

```csharp
// Services/ServiceRegistration.cs
services.AddHttpClient("OVClient")
    .ConfigurePrimaryHttpMessageHandler(() =>
    {
        var handler = new HttpClientHandler();
        handler.ClientCertificateOptions = ClientCertificateOption.Manual;
        handler.ClientCertificates.Add(ClientCertificateHelper.GetX509Certificate2(config));
        return handler;
    });

// FileHandler.cs — use named client
var client = _httpClientFactory.CreateClient("OVClient");
```

---

### 6.3 AppInsightsLogger — TelemetryClient Created per Singleton Instance

**File:** `CareCoordination.Application/Logger/AppInsightsLogger.cs` lines 19–23

#### Problematic Code

```csharp
public class AppInsightsLogger : IApplicationLogger
{
    private readonly TelemetryClient telemetryClient;

    public AppInsightsLogger(IConfiguration configuration)
    {
        // ← TelemetryConfiguration created inline, not from DI
        var telementryConfig = new TelemetryConfiguration();
        telementryConfig.ConnectionString = configuration["ApplicationInsights:ConnectionString"];
        telemetryClient = new TelemetryClient(telementryConfig);
    }
```

`AppInsightsLogger` is registered as **Singleton** (`services.AddSingleton<IApplicationLogger, AppInsightsLogger>()`). The problem is that `TelemetryConfiguration` created inline is not the same as the one registered by `services.AddApplicationInsightsTelemetry()`. This means:

1. Telemetry items may not be batched/flushed properly when the application shuts down
2. The inline `TelemetryConfiguration` does not participate in Application Insights' channel lifecycle
3. `TelemetryClient` has internal background threads and timer; creating it outside the standard DI pipeline means it is not properly disposed

#### Impact

- Telemetry data may be lost on application shutdown (channel not flushed)
- Internal background timer/thread from `TelemetryConfiguration` may not be stopped
- Memory held by the non-DI-managed `TelemetryConfiguration` indefinitely

#### Recommended Fix

```csharp
// Register Application Insights properly in Program.cs
builder.Services.AddApplicationInsightsTelemetry(builder.Configuration);

// AppInsightsLogger.cs — inject TelemetryClient from DI
public class AppInsightsLogger : IApplicationLogger
{
    private readonly TelemetryClient _telemetryClient;

    public AppInsightsLogger(TelemetryClient telemetryClient) // injected by DI
    {
        _telemetryClient = telemetryClient;
    }
    // ...
}
```

---

### 6.4 Stream from OpenReadStream Never Explicitly Closed

**File:** `CareCoordination.Services/Implementation/FileHandler.cs` lines 78–81

#### Problematic Code

```csharp
Stream uploadfilestream = file?.OpenReadStream() ?? Stream.Null;
var streamContent = new StreamContent(uploadfilestream);
streamContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
request.Content = streamContent;

// uploadfilestream is never explicitly closed
// StreamContent disposes its inner stream when IT is disposed
// BUT: request.Content (StreamContent) is also never disposed (see Issue 3.2)
```

#### Root Cause

`IFormFile.OpenReadStream()` returns a stream backed by the multipart upload buffer. If neither `streamContent` nor `uploadfilestream` is disposed, the underlying buffer may be held in memory longer than necessary. Under file upload scenarios, this compounds with the undisposed `HttpResponseMessage` (Issue 3.2) to hold both the input and output buffers alive simultaneously.

#### Impact

- Extended lifetime of upload buffer memory during concurrent file uploads
- Risk of `ObjectDisposedException` if the ASP.NET Core form data is cleaned up before the stream is fully consumed (framework may dispose the form after the action method returns)

#### Recommended Fix

```csharp
await using var uploadfilestream = file?.OpenReadStream() ?? Stream.Null;
using var streamContent = new StreamContent(uploadfilestream);
streamContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
request.Content = streamContent;
// Both disposed deterministically after use
```

---

## 7. MEDIUM — Concurrency & Cache Issues

### 7.1 Static Lock in ApiTokenCacheClient Causes Thread Contention

**File:** `CareCoordination.Services/Implementation/ApiTokenCacheClient.cs` lines 22, 150–153

#### Problematic Code

```csharp
// Line 22 — static lock shared across ALL instances AND ALL API names
private static readonly Object _lock = new Object();

private void AddToCache(string key, AccessTokenItem? accessTokenItem)
{
    var cacheExpiryOptions = new MemoryCacheEntryOptions { ... };
    lock (_lock) // ← ALL threads writing ANY cache key compete on ONE lock
    {
        _cache.Set(key, accessTokenItem, cacheExpiryOptions);
    }
}
```

`IMemoryCache.Set()` is already thread-safe. The outer `lock` is redundant. Worse, it is a **static** lock — all instances of `ApiTokenCacheClient` (which is registered as **Transient**, creating a new instance per request) share the same lock object. Every concurrent token fetch blocks all others globally, serialising what should be an independent operation per API name.

#### Impact

- Under concurrent requests for different API tokens (e.g., `OVAccessToken` and `AetnaAuthToken` simultaneously), the lock forces serial execution
- Thread contention visible in profiler as lock wait time
- Latency added to every request that requires a fresh token

#### Recommended Fix

Remove the `lock` entirely — `IMemoryCache` is already thread-safe:

```csharp
private void AddToCache(string key, AccessTokenItem? accessTokenItem)
{
    var cacheExpiryOptions = new MemoryCacheEntryOptions
    {
        AbsoluteExpiration = DateTimeOffset.UtcNow.AddHours(1),
        SlidingExpiration = TimeSpan.FromMinutes(10),
        Priority = CacheItemPriority.Normal // see Issue 7.3
    };
    _cache.Set(key, accessTokenItem, cacheExpiryOptions); // thread-safe without lock
}
```

---

### 7.2 Cache Expiration Uses DateTime.Now Instead of DateTime.UtcNow

**File:** `CareCoordination.Services/Implementation/ApiTokenCacheClient.cs` line 146

#### Problematic Code

```csharp
var cacheExpiryOptions = new MemoryCacheEntryOptions
{
    AbsoluteExpiration = DateTime.Now.AddHours(1),  // ← Local time
    SlidingExpiration = TimeSpan.FromMinutes(10),
    Priority = CacheItemPriority.High
};
```

But the token's own expiration is set using `DateTime.UtcNow`:

```csharp
// ApiTokenCacheClient.cs line 134
oauthResult.ExpiresIn = DateTime.UtcNow.AddSeconds(oauthResult.Expires_in);
```

And checked against UTC:
```csharp
// Line 42 / 172
if (accessToken != null && accessToken.ExpiresIn > DateTime.UtcNow)
```

#### Root Cause

`MemoryCacheEntryOptions.AbsoluteExpiration` accepts a `DateTimeOffset`. Passing `DateTime.Now` (local time) is implicitly converted with the local time zone offset. On servers configured in a time zone ahead of UTC (e.g., UTC+5:30), the cache entry expires 5.5 hours *later* than intended, holding stale tokens in memory. On servers behind UTC it expires early.

#### Impact

- On UTC+ servers: expired OAuth tokens (by their intrinsic `expires_in`) remain in cache; callers receive tokens that will be rejected by the OAuth provider
- Inconsistent behaviour between development (local timezone) and production (typically UTC)

#### Recommended Fix

```csharp
AbsoluteExpiration = DateTimeOffset.UtcNow.AddHours(1),
```

---

### 7.3 CacheItemPriority.High Prevents Memory Pressure Eviction

**File:** `CareCoordination.Services/Implementation/ApiTokenCacheClient.cs` line 148

#### Problematic Code

```csharp
var cacheExpiryOptions = new MemoryCacheEntryOptions
{
    AbsoluteExpiration = DateTime.Now.AddHours(1),
    SlidingExpiration = TimeSpan.FromMinutes(10),
    Priority = CacheItemPriority.High  // ← Never evicted under memory pressure
};
```

`CacheItemPriority.High` means the `MemoryCache` eviction algorithm (which runs when memory limits are approached) will never remove these entries regardless of memory pressure. Only `CacheItemPriority.NeverRemove` is higher.

For OAuth tokens (small objects, naturally few in number per API), this is unnecessary. If the cache ever grows beyond expected bounds (bug in cache key generation, for example), these entries will never self-heal.

#### Impact

- Token entries cannot be evicted under memory pressure
- Any bug that creates unexpected cache entries (e.g., unique key per user instead of per API) causes unbounded memory growth

#### Recommended Fix

```csharp
Priority = CacheItemPriority.Normal, // Allow eviction under memory pressure
```

---

## 8. MEDIUM — Rate Limiter Fail-Open Design

**File:** `CareCoordination.Api/RateLimiting/Core/DistributedRateLimiterService.cs` lines 63–103

#### Problematic Code

```csharp
public async Task<bool> IsRequestAllowedAsync(
    string key, string limiterType, int maxRequests, TimeSpan timeWindow)
{
    if (!_useDistributed)
    {
        // If distributed rate limiting is disabled:
        return true; // ← ALL requests allowed, no limiting at all
    }

    try
    {
        // ... Redis calls
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Distributed rate limiter error: {ex.Message}");

        if (_fallbackToInMemory)
        {
            Console.WriteLine($"Falling back to in-memory rate limiting for key: {key}");
            return true; // ← "Fallback" is actually: allow ALL requests (no actual limiting)
        }
        throw;
    }
}
```

The comment says "Fallback to in-memory rate limiting" but the implementation just returns `true` (allow). There is no actual in-memory fallback — it is fail-open.

Additionally, errors are logged via `Console.WriteLine` instead of the application's structured logger (`ILogger`), meaning these events are invisible in Application Insights.

#### Impact

- Redis outage = rate limiting completely disabled = potential DoS vulnerability
- No visibility into fallback events in production monitoring
- Distributed and in-memory rate limiters (`Program.cs`) are configured independently and not coordinated — requests may bypass the distributed limiter entirely if it is disabled

#### Recommended Fix

```csharp
// Inject ILogger and implement real in-memory fallback using a ConcurrentDictionary
// or use ASP.NET Core's built-in in-memory rate limiter as the actual fallback

private readonly ILogger<DistributedRateLimiterService> _logger;
// In-memory fallback counter dictionary...

catch (RedisException ex)
{
    _logger.LogWarning(ex, "Redis rate limiter unavailable for key {Key}, using in-memory fallback", key);
    return _inMemoryFallback.IsAllowed(key, maxRequests, timeWindow); // real implementation
}
```

---

## 9. LOW — Code Quality & Minor Overhead

### 9.1 Hardcoded "Sleep Testing" Bypass in Production Code

**File:** `CareCoordination.DAL/Implementation/DashboardView.cs` lines 123–127

#### Problematic Code

```csharp
public static bool IsSafeInput(string input)
{
    // ← Hardcoded whitelist bypass — any user can send "Sleep Testing" as a search term
    if (input.Equals("Sleep Testing", StringComparison.OrdinalIgnoreCase))
    {
        return true;
    }
    // regex check follows...
}
```

The string `"SLEEP"` is in the SQL injection detection pattern (it matches `WAITFOR|DELAY|SLEEP|...`). This bypass allows `"Sleep Testing"` through the injection filter explicitly, likely added during development to test time-based SQL injection resistance. It should not be in production code — any attacker who knows this bypass can use `"Sleep Testing"` as a search parameter.

#### Recommended Fix

Remove the bypass entirely. If testing sleep-based queries is needed, do it in a test environment with test-only configuration or a dedicated test endpoint protected by environment checks.

---

### 9.2 DI Lifetime Inconsistency — Mixed Scoped/Transient Dependencies

**File:** `CareCoordination.DAL/ServiceRegistration.cs` lines 23–35

#### Problematic Code

```csharp
services.AddTransient<IRequestSearch, RequestSearch>();       // Transient
services.AddTransient<IDashboardView, DashboardView>();       // Transient — depends on IDbService (Scoped)
services.AddScoped<IDbService, DbService>();                  // Scoped
services.AddScoped<ITokenRepository, TokenRepository>();      // Scoped
services.AddScoped<IUserRepository, UserRepository>();        // Scoped
services.AddTransient<IAttachmentDetails, AttachmentDetails>(); // Transient
```

`DashboardView` (Transient) depends on `IDbService` (Scoped). While ASP.NET Core resolves this correctly within a request scope (the Scoped `IDbService` is injected into the Transient `DashboardView`), it means every time `DashboardView` is resolved, it shares the same `IDbService` instance as other Transient services resolved in the same scope. This is generally fine but:

1. If `DashboardView` is resolved outside a scope (background service, static context), it will capture the Scoped `IDbService` incorrectly.
2. The inconsistency makes reasoning about service lifetimes harder for future developers.
3. `IApiTokenCacheClient` is **Transient** but `IMemoryCache` (which it depends on) is a **Singleton** — this means a new `ApiTokenCacheClient` is created per request but all share the same cache, which is the correct intent but the Transient lifetime creates unnecessary object churn.

#### Recommended Fix

- `ApiTokenCacheClient` should be **Singleton** (it wraps a Singleton cache and its own state is stateless per-call):

```csharp
services.AddSingleton<IApiTokenCacheClient, ApiTokenCacheClient>();
```

- Review all Transient services that depend on Scoped services and determine if they should be Scoped themselves.

---

### 9.3 AutoMapper Loaded via AppDomain Scan

**File:** `CareCoordination.Api/Program.cs` line 539

#### Problematic Code

```csharp
builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
```

`AppDomain.CurrentDomain.GetAssemblies()` returns all assemblies currently loaded into the application domain. At startup, this may include framework assemblies, NuGet package assemblies, and reflection-loaded assemblies. AutoMapper scans all of them for `Profile` subclasses, which:

- Slows application startup (assembly scanning)
- Is non-deterministic — if an assembly is loaded lazily later, its profiles won't be registered

#### Recommended Fix

```csharp
// Specify only the assemblies that contain AutoMapper profiles
builder.Services.AddAutoMapper(
    typeof(APIMappingProfile).Assembly,        // CareCoordination.Api
    typeof(SomeApplicationProfile).Assembly);  // CareCoordination.Application (if applicable)
```

---

### 9.4 Unnecessary Program.cs Using Statements

**File:** `CareCoordination.Api/Program.cs` lines 1–38

#### Problematic Code

```csharp
using System.Collections;         // unused
using System.Collections.Generic; // unused (top-level implicit)
using System.Diagnostics.Metrics;  // unused
using System.Net.Sockets;          // unused
using System.Resources;            // unused
using System.ServiceModel.Channels;// unused
using static System.Runtime.InteropServices.JavaScript.JSType; // unused — JavaScript interop in a backend API?
using static Dapper.SqlMapper;     // unused in Program.cs
```

While unused `using` directives do not cause runtime memory issues, they increase compilation time, are picked up by assembly scanners (AutoMapper, reflection-based tools), and indicate code that was not cleaned up after copy-paste or experimentation.

#### Recommended Fix

Run IDE cleanup / `dotnet format` to remove unused directives. Enable `<Nullable>enable</Nullable>` and `<ImplicitUsings>enable</ImplicitUsings>` (already set per `.csproj`) and remove explicit `using` directives covered by global usings.

---

## 10. Summary Table

| # | Severity | File | Lines | Category | Fix Complexity |
|---|----------|------|-------|----------|----------------|
| 3.1 | 🔴 CRITICAL | `DbService.cs` | 18–25 | Memory Leak | Medium |
| 3.2 | 🔴 CRITICAL | `FileHandler.cs` | 83, 86, 149, 152, 240 | Memory Leak + Thread Starvation | High |
| 3.3 | 🔴 CRITICAL | `ApiTokenCacheClient.cs` | 129 | Memory Leak + Blocking | Medium |
| 4.1 | 🟠 HIGH | `ObjectExtensionsManagement.cs` | 19 | CPU/GC Overhead | Low |
| 4.2 | 🟠 HIGH | `DashboardView.cs` | 129–130 | CPU Overhead | Low |
| 4.3 | 🟠 HIGH | `JwtHelper.cs` | 13, 12 | Allocation Overhead | Low |
| 4.4 | 🟠 HIGH | `DAL/ServiceRegistration.cs` | 38–43 | Orphan Connection | Low |
| 5.1 | 🟠 HIGH | `FileHandler.cs` multiple | 47, 83, 124, 149, 220, 240 | Thread Pool Starvation | High |
| 5.2 | 🟠 HIGH | `DashboardView.cs` | 61–74 | GC Pressure | Low |
| 5.3 | 🟡 MEDIUM | `RequestSearchManagement.cs` | 27–36 | LOH Pressure | Medium |
| 6.1 | 🟡 MEDIUM | `IGridReaderWrapper.cs` | — | Disposal Gap | Low |
| 6.2 | 🟡 MEDIUM | `FileHandler.cs` | 57, 130, 176, 227 | Wasted Allocation | Low |
| 6.3 | 🟡 MEDIUM | `AppInsightsLogger.cs` | 20–22 | Telemetry Loss | Low |
| 6.4 | 🟡 MEDIUM | `FileHandler.cs` | 78–81 | Unclear Disposal | Low |
| 7.1 | 🟡 MEDIUM | `ApiTokenCacheClient.cs` | 22, 150 | Thread Contention | Low |
| 7.2 | 🟡 MEDIUM | `ApiTokenCacheClient.cs` | 146 | Cache Staleness Bug | Trivial |
| 7.3 | 🟡 MEDIUM | `ApiTokenCacheClient.cs` | 148 | Cache Eviction Blocked | Trivial |
| 8 | 🟡 MEDIUM | `DistributedRateLimiterService.cs` | 63–103 | Security / Fail-Open | Medium |
| 9.1 | 🔵 LOW | `DashboardView.cs` | 123–127 | Security Bypass | Trivial |
| 9.2 | 🔵 LOW | `DAL/ServiceRegistration.cs` | 26–30 | DI Lifetime | Low |
| 9.3 | 🔵 LOW | `Program.cs` | 539 | Startup Performance | Low |
| 9.4 | 🔵 LOW | `Program.cs` | 1–38 | Code Hygiene | Trivial |

---

### Prioritised Action Plan

**Sprint 1 — Stop active leaks:**
1. Fix `DbService` — implement `IDisposable`, dispose connection, remove orphan `IDbConnection` registration (Issues 3.1, 4.4)
2. Fix `FileHandler` — convert all 4 methods to full `async/await`, wrap `HttpResponseMessage` in `using` (Issues 3.2, 5.1)
3. Fix `ApiTokenCacheClient.GetOAuthToken` — replace `.Result` with `await`, wrap response in `using` (Issue 3.3)

**Sprint 2 — Reduce GC & CPU pressure:**
4. Cache `PropertyInfo[]` in `ObjectExtensionsManagement` (Issue 4.1)
5. Convert `DashboardView.IsSafeInput` regex to compiled static field (Issue 4.2)
6. Add `IDisposable` to `IGridReaderWrapper` (Issue 6.1)
7. Remove orphaned `HttpClientHandler` allocations; use named `HttpClient` (Issue 6.2)

**Sprint 3 — Correctness & reliability:**
8. Fix `DateTime.Now` → `DateTimeOffset.UtcNow` in cache options (Issue 7.2)
9. Remove `static` lock from `ApiTokenCacheClient` (Issue 7.1)
10. Change `CacheItemPriority.High` → `Normal` (Issue 7.3)
11. Implement real in-memory fallback in `DistributedRateLimiterService` (Issue 8)
12. Fix `AppInsightsLogger` to use DI-managed `TelemetryClient` (Issue 6.3)

**Sprint 4 — Hygiene:**
13. Remove `"Sleep Testing"` bypass (Issue 9.1)
14. Change `ApiTokenCacheClient` to Singleton (Issue 9.2)
15. Narrow `AddAutoMapper` to specific assemblies (Issue 9.3)
16. Remove unused `using` directives in `Program.cs` (Issue 9.4)
17. Add `JwtSecurityTokenHandler` static instance in `JwtHelper` (Issue 4.3)

---

*Report generated by static code analysis of CareCoordination Backend — .NET 9.0*
