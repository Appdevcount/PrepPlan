# Azure API Management (APIM) - Complete Guide

## 📋 Table of Contents
1. [What is Azure APIM](#what-is-azure-apim)
2. [Core Concepts & Mental Models](#core-concepts--mental-models)
3. [APIM Architecture](#apim-architecture)
4. [Policy Structure & Execution Order](#policy-structure--execution-order)
5. [Inbound Policies](#inbound-policies)
6. [Backend Policies](#backend-policies)
7. [Outbound Policies](#outbound-policies)
8. [On-Error Policies](#on-error-policies)
9. [Common Policy Scenarios](#common-policy-scenarios)
10. [Advanced Topics](#advanced-topics)
11. [Best Practices](#best-practices)

---

## What is Azure APIM

**Azure API Management** is a fully managed service that enables you to publish, secure, transform, maintain, and monitor APIs. It acts as a **facade** or **gateway** between your backend services and API consumers.

### 🎯 Mental Model: APIM as a Smart Proxy
```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│   Client    │ ──────► │   APIM Gateway   │ ──────► │  Backend    │
│ (Consumer)  │         │  (Smart Proxy)   │         │  Service    │
└─────────────┘         └──────────────────┘         └─────────────┘
                              │
                              ├─ Authentication
                              ├─ Rate Limiting
                              ├─ Caching
                              ├─ Transformation
                              ├─ Monitoring
                              └─ Security
```

### Key Components
1. **API Gateway** - Request/response proxy
2. **Management Plane** - API configuration & management
3. **Developer Portal** - API documentation & testing
4. **Analytics** - Monitoring & insights

---

## Core Concepts & Mental Models

### 🧠 Mental Model 1: Request Pipeline (Assembly Line)
Think of APIM policies as stations on an assembly line where the request is modified:

```
Request Flow:
Client → [Inbound Policies] → [Backend Policies] → Backend Service
                                                           ↓
Client ← [Outbound Policies] ← [Backend Policies] ← Response
         [On-Error Policies] (if error occurs at any stage)
```

### 🧠 Mental Model 2: Policy Scopes (Nested Boxes)
Policies can be defined at different scopes, like Russian nesting dolls:

```
┌─────────────────────── Global ───────────────────────┐
│                                                       │
│  ┌──────────────── Product ─────────────────┐       │
│  │                                           │       │
│  │  ┌────────── API ──────────┐            │       │
│  │  │                          │            │       │
│  │  │  ┌── Operation ──┐      │            │       │
│  │  │  │   GET /users  │      │            │       │
│  │  │  └───────────────┘      │            │       │
│  │  └──────────────────────────┘            │       │
│  └──────────────────────────────────────────┘       │
└──────────────────────────────────────────────────────┘

Execution Order: Global → Product → API → Operation
```

### 🧠 Mental Model 3: Policy XML as Middleware Chain
```csharp
// Similar to ASP.NET Core middleware
app.Use(async (context, next) => {
    // Inbound processing
    await next(); // Call backend
    // Outbound processing
});
```

---

## APIM Architecture

### Tiers & Deployment Options

| Tier | Use Case | SLA | V-Net Support |
|------|----------|-----|---------------|
| **Consumption** | Serverless, pay-per-use | None | No |
| **Developer** | Dev/Test, no SLA | No | No |
| **Basic** | Small production | 99.95% | No |
| **Standard** | Mid-size production | 99.95% | Yes |
| **Premium** | Enterprise, multi-region | 99.99% | Yes |

### Component Architecture
```
┌────────────────────────────────────────────────────────┐
│                    APIM Instance                       │
│                                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │   Gateway    │  │  Management  │  │  Developer  │ │
│  │   (Runtime)  │  │    Plane     │  │   Portal    │ │
│  └──────┬───────┘  └──────────────┘  └─────────────┘ │
│         │                                             │
│         │ Policies Applied Here                       │
│         ↓                                             │
│  ┌──────────────────────────────────────────────┐    │
│  │  Request → Inbound → Backend → Outbound      │    │
│  └──────────────────────────────────────────────┘    │
└────────────────────────────────────────────────────────┘
           │
           ↓
    Backend Services
```

---

## Policy Structure & Execution Order

### Basic Policy Structure
```xml
<policies>
    <!-- Applied on every request before forwarding to backend -->
    <inbound>
        <base /> <!-- Inherit from higher scopes -->
        <!-- Your inbound policies here -->
    </inbound>
    
    <!-- Applied before/after calling backend -->
    <backend>
        <base />
        <!-- Your backend policies here -->
    </backend>
    
    <!-- Applied after receiving response from backend -->
    <outbound>
        <base />
        <!-- Your outbound policies here -->
    </outbound>
    
    <!-- Applied when error occurs in any section -->
    <on-error>
        <base />
        <!-- Your error handling policies here -->
    </on-error>
</policies>
```

### 🎯 Execution Flow
```
1. INBOUND Section
   ↓
   - Validate JWT token
   - Check rate limits  
   - Transform request body
   - Set backend URL
   ↓
2. BACKEND Section
   ↓
   - Forward request to backend
   - OR use mock/cached response
   ↓
3. OUTBOUND Section
   ↓
   - Transform response body
   - Set custom headers
   - Remove sensitive data
   - Cache response
   ↓
4. Return to client

   [If error at ANY stage → ON-ERROR section]
```

### The `<base />` Tag
The `<base />` tag is crucial - it determines where parent scope policies execute:

```xml
<!-- EARLY EXECUTION: Parent policies run FIRST -->
<inbound>
    <base /> <!-- Parent policies execute here -->
    <set-header name="x-custom" exists-action="override">
        <value>my-value</value>
    </set-header>
</inbound>

<!-- LATE EXECUTION: Child policies run FIRST -->
<inbound>
    <set-header name="x-custom" exists-action="override">
        <value>my-value</value>
    </set-header>
    <base /> <!-- Parent policies execute after above -->
</inbound>
```

---

## Inbound Policies

### 🎯 Purpose
Transform and validate incoming requests BEFORE they reach the backend.

### 1. Authentication & Authorization

#### JWT Validation
```xml
<inbound>
    <!-- Validate JWT token from Azure AD -->
    <validate-jwt 
        header-name="Authorization" 
        failed-validation-httpcode="401" 
        failed-validation-error-message="Unauthorized">
        
        <!-- Where to get signing keys -->
        <openid-config url="https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid-configuration" />
        
        <!-- Expected audience claim -->
        <audiences>
            <audience>api://my-api-client-id</audience>
        </audiences>
        
        <!-- Expected issuer -->
        <issuers>
            <issuer>https://sts.windows.net/{tenant-id}/</issuer>
        </issuers>
        
        <!-- Required claims (optional) -->
        <required-claims>
            <claim name="roles" match="any">
                <value>Admin</value>
                <value>User</value>
            </claim>
        </required-claims>
    </validate-jwt>
</inbound>
```

**When to use:** Every API requiring OAuth 2.0/OpenID Connect authentication.

#### Check HTTP Header
```xml
<inbound>
    <!-- Ensure required header exists -->
    <check-header name="x-api-version" failed-check-httpcode="400" failed-check-error-message="API version header missing">
        <value>v1</value>
        <value>v2</value>
    </check-header>
</inbound>
```

**When to use:** API versioning via headers, custom authentication schemes.

### 2. Rate Limiting & Quotas

#### Rate Limit by Key
```xml
<inbound>
    <!-- Limit requests per subscription -->
    <rate-limit-by-key 
        calls="100" 
        renewal-period="60" 
        counter-key="@(context.Subscription.Id)" />
    
    <!-- OR limit by IP address -->
    <rate-limit-by-key 
        calls="10" 
        renewal-period="60" 
        counter-key="@(context.Request.IpAddress)" />
    
    <!-- OR limit by JWT claim (userId) -->
    <rate-limit-by-key 
        calls="1000" 
        renewal-period="3600" 
        counter-key="@{
            var jwt = context.Request.Headers.GetValueOrDefault("Authorization", "")
                            .Replace("Bearer ", "");
            var token = jwt.AsJwt();
            return token?.Claims.GetValueOrDefault("sub", "anonymous");
        }" />
</inbound>
```

**When to use:** 
- Prevent API abuse
- Enforce fair usage
- Protect backend from overload

#### Quota by Subscription
```xml
<inbound>
    <!-- Monthly quota -->
    <quota-by-key 
        calls="1000000" 
        bandwidth="10485760"
        renewal-period="2629800"
        counter-key="@(context.Subscription.Id)" />
</inbound>
```

**When to use:** Subscription-based billing models.

### 3. Request Transformation

#### Set Backend Service URL
```xml
<inbound>
    <!-- Static backend -->
    <set-backend-service base-url="https://my-backend-service.azurewebsites.net" />
    
    <!-- Dynamic backend based on environment -->
    <set-backend-service base-url="@{
        var env = context.Request.Headers.GetValueOrDefault("x-environment", "prod");
        return env == "dev" 
            ? "https://dev-backend.azurewebsites.net"
            : "https://prod-backend.azurewebsites.net";
    }" />
</inbound>
```

**When to use:** 
- Multiple backend environments
- A/B testing
- Blue-green deployments

#### Rewrite URL
```xml
<inbound>
    <!-- Simple rewrite -->
    <rewrite-uri template="/api/v2/users/{id}" />
    
    <!-- Conditional rewrite -->
    <rewrite-uri template="@{
        var version = context.Request.Headers.GetValueOrDefault("x-api-version", "v1");
        return version == "v2" ? "/api/v2/users" : "/api/v1/users";
    }" />
</inbound>
```

**When to use:** Backend URL differs from public API URL.

#### Set Headers
```xml
<inbound>
    <!-- Add correlation ID -->
    <set-header name="x-correlation-id" exists-action="override">
        <value>@(Guid.NewGuid().ToString())</value>
    </set-header>
    
    <!-- Add API version -->
    <set-header name="x-api-version" exists-action="skip">
        <value>1.0</value>
    </set-header>
    
    <!-- Remove sensitive headers -->
    <set-header name="x-internal-key" exists-action="delete" />
    
    <!-- Forward client IP -->
    <set-header name="x-forwarded-for" exists-action="override">
        <value>@(context.Request.IpAddress)</value>
    </set-header>
</inbound>
```

**exists-action values:**
- `override` - Always set/replace
- `skip` - Only set if doesn't exist
- `append` - Add to existing values
- `delete` - Remove header

**When to use:** 
- Correlation/tracing
- Backend requirements
- Security (remove sensitive info)

#### Set Query Parameters
```xml
<inbound>
    <!-- Add query parameter -->
    <set-query-parameter name="api_key" exists-action="override">
        <value>{{backend-api-key}}</value> <!-- Named value -->
    </set-query-parameter>
    
    <!-- Remove query parameter -->
    <set-query-parameter name="debug" exists-action="delete" />
</inbound>
```

**When to use:** Backend requires different query params than public API.

#### Transform Request Body (JSON)
```xml
<inbound>
    <!-- Transform JSON request -->
    <set-body>@{
        var body = context.Request.Body.As<JObject>(preserveContent: true);
        
        // Add timestamp
        body["timestamp"] = DateTime.UtcNow.ToString("o");
        
        // Rename field
        if (body["userName"] != null) {
            body["username"] = body["userName"];
            body.Remove("userName");
        }
        
        return body.ToString();
    }</set-body>
</inbound>
```

**When to use:** 
- API contract differs from backend
- Add metadata to requests
- Data enrichment

#### Transform Request Body (SOAP to REST)
```xml
<inbound>
    <!-- Convert REST to SOAP -->
    <set-header name="Content-Type" exists-action="override">
        <value>text/xml</value>
    </set-header>
    
    <set-body>@{
        var json = context.Request.Body.As<JObject>(preserveContent: true);
        var name = json["name"]?.ToString();
        
        return $@"<?xml version=""1.0"" encoding=""utf-8""?>
        <soap:Envelope xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">
            <soap:Body>
                <GetUser xmlns=""http://tempuri.org/"">
                    <name>{name}</name>
                </GetUser>
            </soap:Body>
        </soap:Envelope>";
    }</set-body>
</inbound>
```

**When to use:** Legacy SOAP backend with modern REST API.

### 4. Caching

#### Check Cache
```xml
<inbound>
    <!-- Check if response is cached -->
    <cache-lookup 
        vary-by-developer="false" 
        vary-by-developer-groups="false" 
        downstream-caching-type="none">
        
        <!-- Cache key components -->
        <vary-by-header>Accept</vary-by-header>
        <vary-by-header>Accept-Charset</vary-by-header>
        <vary-by-query-parameter>category</vary-by-query-parameter>
    </cache-lookup>
</inbound>
```

**When to use:** 
- Read-heavy APIs
- Static/slowly changing data
- Reduce backend load

### 5. IP Filtering

```xml
<inbound>
    <!-- Whitelist IP addresses -->
    <ip-filter action="allow">
        <address>13.66.201.169</address>
        <address-range from="13.66.140.128" to="13.66.140.143" />
    </ip-filter>
    
    <!-- OR Blacklist IP addresses -->
    <ip-filter action="forbid">
        <address>13.66.201.169</address>
    </ip-filter>
</inbound>
```

**When to use:** 
- Restrict API to corporate network
- Block malicious IPs
- Geo-restrictions (with expressions)

### 6. CORS

```xml
<inbound>
    <!-- Enable CORS -->
    <cors allow-credentials="true">
        <allowed-origins>
            <origin>https://myapp.azurewebsites.net</origin>
            <origin>https://localhost:3000</origin>
        </allowed-origins>
        <allowed-methods preflight-result-max-age="300">
            <method>GET</method>
            <method>POST</method>
            <method>PUT</method>
            <method>DELETE</method>
        </allowed-methods>
        <allowed-headers>
            <header>*</header>
        </allowed-headers>
        <expose-headers>
            <header>x-correlation-id</header>
        </expose-headers>
    </cors>
</inbound>
```

**When to use:** Browser-based clients need to call API from different domain.

### 7. Request Validation

#### Validate Content
```xml
<inbound>
    <!-- Validate against OpenAPI schema -->
    <validate-content unspecified-content-type-action="prevent" 
                      max-size="102400" 
                      size-exceeded-action="detect" 
                      errors-variable-name="requestBodyValidation">
        <content type="application/json" 
                 validate-as="json" 
                 action="prevent" />
    </validate-content>
</inbound>
```

**When to use:** Ensure requests match OpenAPI/Swagger schema.

#### Validate Parameters
```xml
<inbound>
    <!-- Validate query/header/path parameters against schema -->
    <validate-parameters specified-parameter-action="prevent" 
                        unspecified-parameter-action="prevent" 
                        errors-variable-name="requestParameterValidation" />
</inbound>
```

**When to use:** Strict API contract enforcement.

### 8. Send Request (Call External Service)

```xml
<inbound>
    <!-- Call external service for enrichment -->
    <send-request mode="new" response-variable-name="userProfile" timeout="10" ignore-error="false">
        <set-url>https://userservice.com/api/profile/@(context.Request.Headers.GetValueOrDefault("x-user-id"))</set-url>
        <set-method>GET</set-method>
        <set-header name="Authorization" exists-action="override">
            <value>Bearer {{external-service-token}}</value>
        </set-header>
    </send-request>
    
    <!-- Add enriched data to request -->
    <set-header name="x-user-email" exists-action="override">
        <value>@{
            var response = (IResponse)context.Variables["userProfile"];
            var user = response.Body.As<JObject>();
            return user["email"]?.ToString() ?? "unknown";
        }</value>
    </set-header>
</inbound>
```

**mode values:**
- `new` - Don't wait, execute async (parallel)
- `copy` - Wait for response (sequential)

**When to use:** 
- Data enrichment
- Authorization checks
- Service-to-service calls

---

## Backend Policies

### 🎯 Purpose
Control how the request is forwarded to the backend service (or skip forwarding entirely).

### 1. Forward Request

```xml
<backend>
    <!-- Default: forward to backend -->
    <forward-request />
    
    <!-- With timeout -->
    <forward-request timeout="60" />
    
    <!-- Follow redirects -->
    <forward-request follow-redirects="true" />
</backend>
```

### 2. Retry Policy

```xml
<backend>
    <!-- Retry on failure -->
    <retry condition="@(context.Response.StatusCode >= 500)" 
           count="3" 
           interval="1" 
           delta="1" 
           max-interval="10"
           first-fast-retry="true">
        
        <forward-request timeout="10" />
        
        <!-- Optional: Exponential backoff logic -->
        <set-variable name="retryCount" value="@(context.Variables.GetValueOrDefault<int>("retryCount", 0) + 1)" />
    </retry>
</backend>
```

**When to use:** Transient failures, network issues, backend restarts.

### 3. Mock Response (Skip Backend)

```xml
<backend>
    <!-- Return mock response without calling backend -->
    <mock-response status-code="200" content-type="application/json" />
</backend>

<!-- In outbound, set mock body -->
<outbound>
    <set-body>@{
        return new JObject(
            new JProperty("id", 123),
            new JProperty("name", "Mock User"),
            new JProperty("email", "mock@example.com")
        ).ToString();
    }</set-body>
</outbound>
```

**When to use:** 
- API prototyping
- Backend not ready
- Testing

### 4. Choose Backend (Conditional Routing)

```xml
<backend>
    <!-- Route based on condition -->
    <choose>
        <when condition="@(context.Request.Headers.GetValueOrDefault("x-beta-user", "false") == "true")">
            <set-backend-service base-url="https://beta-backend.com" />
            <forward-request />
        </when>
        <when condition="@(context.Request.Url.Path.Contains("/legacy/"))">
            <set-backend-service base-url="https://legacy-backend.com" />
            <forward-request />
        </when>
        <otherwise>
            <set-backend-service base-url="https://prod-backend.com" />
            <forward-request />
        </otherwise>
    </choose>
</backend>
```

**When to use:** 
- A/B testing
- Canary deployments
- Multi-backend routing

### 5. Service Fabric Backend

```xml
<backend>
    <!-- Forward to Service Fabric backend -->
    <set-backend-service 
        sf-service-instance-name="fabric:/MyApp/MyService"
        sf-partition-key="@(context.Request.MatchedParameters["userId"])" />
    
    <forward-request />
</backend>
```

**When to use:** Microservices on Azure Service Fabric.

---

## Outbound Policies

### 🎯 Purpose
Transform and modify responses BEFORE they are sent to the client.

### 1. Response Transformation

#### Transform JSON Response
```xml
<outbound>
    <!-- Modify response body -->
    <set-body>@{
        var response = context.Response.Body.As<JObject>(preserveContent: true);
        
        // Remove sensitive fields
        response.Remove("internalId");
        response.Remove("secretKey");
        
        // Add metadata
        response["_metadata"] = new JObject(
            new JProperty("apiVersion", "1.0"),
            new JProperty("timestamp", DateTime.UtcNow.ToString("o")),
            new JProperty("correlationId", context.RequestId)
        );
        
        // Rename fields
        if (response["user_name"] != null) {
            response["username"] = response["user_name"];
            response.Remove("user_name");
        }
        
        return response.ToString();
    }</set-body>
</outbound>
```

**When to use:** 
- Hide internal implementation
- Add API metadata
- Normalize response format

#### Transform XML to JSON
```xml
<outbound>
    <!-- Convert SOAP/XML response to JSON -->
    <xml-to-json kind="direct" apply="always" consider-accept-header="false" />
</outbound>
```

**kind values:**
- `direct` - Direct conversion
- `javascript-friendly` - Convert attributes to properties

**When to use:** Modernize SOAP API responses.

#### Transform Collection (Array mapping)
```xml
<outbound>
    <set-body>@{
        var response = context.Response.Body.As<JObject>(preserveContent: true);
        var items = response["items"] as JArray;
        
        if (items != null) {
            var transformed = new JArray();
            foreach (var item in items) {
                transformed.Add(new JObject(
                    new JProperty("id", item["userId"]),
                    new JProperty("name", item["fullName"]),
                    new JProperty("email", item["emailAddress"])
                ));
            }
            response["users"] = transformed;
            response.Remove("items");
        }
        
        return response.ToString();
    }</set-body>
</outbound>
```

**When to use:** Backend response structure differs from API contract.

### 2. Set Response Headers

```xml
<outbound>
    <!-- Add security headers -->
    <set-header name="X-Content-Type-Options" exists-action="override">
        <value>nosniff</value>
    </set-header>
    <set-header name="X-Frame-Options" exists-action="override">
        <value>DENY</value>
    </set-header>
    <set-header name="Strict-Transport-Security" exists-action="override">
        <value>max-age=31536000; includeSubDomains</value>
    </set-header>
    
    <!-- Remove backend headers -->
    <set-header name="X-AspNet-Version" exists-action="delete" />
    <set-header name="X-Powered-By" exists-action="delete" />
    <set-header name="Server" exists-action="delete" />
    
    <!-- Add correlation ID -->
    <set-header name="x-correlation-id" exists-action="override">
        <value>@(context.RequestId)</value>
    </set-header>
</outbound>
```

**When to use:** 
- Security hardening
- Hide backend technology
- Response tracking

### 3. Cache Response

```xml
<outbound>
    <!-- Store response in cache -->
    <cache-store duration="3600" />
    
    <!-- OR with custom cache key -->
    <cache-store duration="3600" cache-response="true">
        <vary-by-header>Accept</vary-by-header>
        <vary-by-query-parameter>category</vary-by-query-parameter>
    </cache-store>
</outbound>
```

**When to use:** Paired with `cache-lookup` in inbound section.

### 4. Set Status Code

```xml
<outbound>
    <!-- Override status code -->
    <set-status code="200" reason="OK" />
    
    <!-- Conditional status -->
    <choose>
        <when condition="@(context.Response.Body.As<JObject>()["items"]?.Count() == 0)">
            <set-status code="204" reason="No Content" />
        </when>
    </choose>
</outbound>
```

**When to use:** 
- Normalize status codes across backends
- Custom error codes

### 5. JSONP

```xml
<outbound>
    <!-- Enable JSONP for legacy browser support -->
    <jsonp callback-parameter-name="callback" />
</outbound>
```

**When to use:** Support old browsers without CORS.

### 6. Find and Replace

```xml
<outbound>
    <!-- String replacement in response -->
    <find-and-replace from="http://" to="https://" />
    
    <!-- Replace internal URLs with public ones -->
    <find-and-replace from="internal-api.local" to="api.mycompany.com" />
</outbound>
```

**When to use:** 
- Fix URLs in responses
- Remove sensitive patterns

### 7. Set Variable for Logging

```xml
<outbound>
    <!-- Extract data for logging -->
    <set-variable name="responseTime" value="@(context.Elapsed.TotalMilliseconds)" />
    <set-variable name="statusCode" value="@(context.Response.StatusCode)" />
    <set-variable name="responseSize" value="@(context.Response.Body.As<string>().Length)" />
</outbound>
```

**When to use:** Custom logging/analytics (paired with `log-to-eventhub`).

---

## On-Error Policies

### 🎯 Purpose
Handle errors that occur in inbound, backend, or outbound sections.

### 1. Basic Error Handling

```xml
<on-error>
    <!-- Log error -->
    <set-variable name="errorReason" value="@(context.LastError.Reason)" />
    <set-variable name="errorMessage" value="@(context.LastError.Message)" />
    <set-variable name="errorScope" value="@(context.LastError.Scope)" />
    <set-variable name="errorSection" value="@(context.LastError.Section)" />
    
    <!-- Return custom error response -->
    <return-response>
        <set-status code="500" reason="Internal Server Error" />
        <set-header name="Content-Type" exists-action="override">
            <value>application/json</value>
        </set-header>
        <set-body>@{
            return new JObject(
                new JProperty("error", new JObject(
                    new JProperty("code", "InternalError"),
                    new JProperty("message", "An unexpected error occurred"),
                    new JProperty("correlationId", context.RequestId),
                    new JProperty("timestamp", DateTime.UtcNow.ToString("o"))
                ))
            ).ToString();
        }</set-body>
    </return-response>
</on-error>
```

### 2. Specific Error Handling

```xml
<on-error>
    <!-- Check error type -->
    <choose>
        <!-- JWT validation failed -->
        <when condition="@(context.LastError.Reason == "Unauthorized")">
            <return-response>
                <set-status code="401" reason="Unauthorized" />
                <set-body>@{
                    return new JObject(
                        new JProperty("error", "Invalid or expired token")
                    ).ToString();
                }</set-body>
            </return-response>
        </when>
        
        <!-- Rate limit exceeded -->
        <when condition="@(context.LastError.Reason == "QuotaExceeded")">
            <return-response>
                <set-status code="429" reason="Too Many Requests" />
                <set-header name="Retry-After" exists-action="override">
                    <value>60</value>
                </set-header>
                <set-body>@{
                    return new JObject(
                        new JProperty("error", "Rate limit exceeded. Try again later.")
                    ).ToString();
                }</set-body>
            </return-response>
        </when>
        
        <!-- Backend timeout -->
        <when condition="@(context.LastError.Reason == "Timeout")">
            <return-response>
                <set-status code="504" reason="Gateway Timeout" />
                <set-body>@{
                    return new JObject(
                        new JProperty("error", "Backend service timeout")
                    ).ToString();
                }</set-body>
            </return-response>
        </when>
        
        <!-- Default error -->
        <otherwise>
            <return-response>
                <set-status code="500" reason="Internal Server Error" />
                <set-body>@{
                    return new JObject(
                        new JProperty("error", "An unexpected error occurred"),
                        new JProperty("correlationId", context.RequestId)
                    ).ToString();
                }</set-body>
            </return-response>
        </otherwise>
    </choose>
</on-error>
```

### 3. Error Logging to External System

```xml
<on-error>
    <!-- Log to Application Insights -->
    <log-to-eventhub logger-id="appinsights-logger">@{
        return new JObject(
            new JProperty("timestamp", DateTime.UtcNow.ToString("o")),
            new JProperty("requestId", context.RequestId),
            new JProperty("error", new JObject(
                new JProperty("reason", context.LastError.Reason),
                new JProperty("message", context.LastError.Message),
                new JProperty("scope", context.LastError.Scope),
                new JProperty("section", context.LastError.Section),
                new JProperty("source", context.LastError.Source)
            )),
            new JProperty("request", new JObject(
                new JProperty("method", context.Request.Method),
                new JProperty("url", context.Request.Url.ToString()),
                new JProperty("ipAddress", context.Request.IpAddress)
            ))
        ).ToString();
    }</log-to-eventhub>
    
    <!-- Return generic error -->
    <return-response>
        <set-status code="500" />
        <set-body>@{
            return new JObject(
                new JProperty("error", "Internal server error"),
                new JProperty("correlationId", context.RequestId)
            ).ToString();
        }</set-body>
    </return-response>
</on-error>
```

### 4. Custom Error Object Structure

```xml
<on-error>
    <return-response>
        <set-status code="500" />
        <set-header name="Content-Type" exists-action="override">
            <value>application/problem+json</value>
        </set-header>
        <set-body>@{
            // RFC 7807 Problem Details format
            return new JObject(
                new JProperty("type", "https://api.example.com/errors/internal-error"),
                new JProperty("title", "Internal Server Error"),
                new JProperty("status", 500),
                new JProperty("detail", "An unexpected error occurred while processing your request"),
                new JProperty("instance", context.Request.Url.Path),
                new JProperty("traceId", context.RequestId),
                new JProperty("timestamp", DateTime.UtcNow.ToString("o"))
            ).ToString();
        }</set-body>
    </return-response>
</on-error>
```

---

## Common Policy Scenarios

### Scenario 1: Secure API with JWT + Rate Limiting + Caching

```xml
<policies>
    <inbound>
        <base />
        
        <!-- 1. Validate JWT token -->
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
            <openid-config url="https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration" />
            <audiences>
                <audience>api://my-api</audience>
            </audiences>
        </validate-jwt>
        
        <!-- 2. Rate limit per user -->
        <rate-limit-by-key 
            calls="100" 
            renewal-period="60" 
            counter-key="@{
                var jwt = context.Request.Headers.GetValueOrDefault("Authorization", "").Replace("Bearer ", "").AsJwt();
                return jwt?.Claims.GetValueOrDefault("sub", "anonymous");
            }" />
        
        <!-- 3. Check cache -->
        <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" />
        
        <!-- 4. Add correlation ID -->
        <set-header name="x-correlation-id" exists-action="override">
            <value>@(context.RequestId)</value>
        </set-header>
    </inbound>
    
    <backend>
        <forward-request timeout="30" />
    </backend>
    
    <outbound>
        <base />
        
        <!-- Store in cache for 5 minutes -->
        <cache-store duration="300" />
        
        <!-- Remove sensitive headers -->
        <set-header name="X-Internal-Key" exists-action="delete" />
        
        <!-- Add security headers -->
        <set-header name="X-Content-Type-Options" exists-action="override">
            <value>nosniff</value>
        </set-header>
    </outbound>
    
    <on-error>
        <base />
        <return-response>
            <set-status code="500" />
            <set-body>@{
                return new JObject(
                    new JProperty("error", "Internal error"),
                    new JProperty("correlationId", context.RequestId)
                ).ToString();
            }</set-body>
        </return-response>
    </on-error>
</policies>
```

### Scenario 2: API Composition (Aggregating Multiple Backend Calls)

```xml
<policies>
    <inbound>
        <base />
        
        <!-- Extract user ID from JWT -->
        <set-variable name="userId" value="@{
            var jwt = context.Request.Headers.GetValueOrDefault("Authorization", "").Replace("Bearer ", "").AsJwt();
            return jwt?.Claims.GetValueOrDefault("sub", "");
        }" />
        
        <!-- Call user service -->
        <send-request mode="new" response-variable-name="userResponse" timeout="10">
            <set-url>https://user-service.com/api/users/@((string)context.Variables["userId"])</set-url>
            <set-method>GET</set-method>
        </send-request>
        
        <!-- Call orders service -->
        <send-request mode="new" response-variable-name="ordersResponse" timeout="10">
            <set-url>https://order-service.com/api/orders?userId=@((string)context.Variables["userId"])</set-url>
            <set-method>GET</set-method>
        </send-request>
        
        <!-- Call recommendations service -->
        <send-request mode="new" response-variable-name="recsResponse" timeout="10">
            <set-url>https://rec-service.com/api/recommendations/@((string)context.Variables["userId"])</set-url>
            <set-method>GET</set-method>
        </send-request>
    </inbound>
    
    <backend>
        <!-- Don't call backend, we're composing response from multiple services -->
        <return-response>
            <set-status code="200" />
            <set-header name="Content-Type" exists-action="override">
                <value>application/json</value>
            </set-header>
            <set-body>@{
                var userResp = ((IResponse)context.Variables["userResponse"]).Body.As<JObject>();
                var ordersResp = ((IResponse)context.Variables["ordersResponse"]).Body.As<JObject>();
                var recsResp = ((IResponse)context.Variables["recsResponse"]).Body.As<JObject>();
                
                return new JObject(
                    new JProperty("user", userResp),
                    new JProperty("orders", ordersResp["items"]),
                    new JProperty("recommendations", recsResp["items"])
                ).ToString();
            }</set-body>
        </return-response>
    </backend>
    
    <outbound>
        <base />
    </outbound>
    
    <on-error>
        <base />
    </on-error>
</policies>
```

### Scenario 3: Request/Response Logging with Masking

```xml
<policies>
    <inbound>
        <base />
        
        <!-- Log request (mask sensitive data) -->
        <set-variable name="requestBody" value="@(context.Request.Body.As<string>(preserveContent: true))" />
        
        <log-to-eventhub logger-id="audit-logger">@{
            var body = (string)context.Variables["requestBody"];
            
            // Mask credit card numbers
            var maskedBody = System.Text.RegularExpressions.Regex.Replace(
                body, 
                @"\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}", 
                "****-****-****-****"
            );
            
            // Mask SSN
            maskedBody = System.Text.RegularExpressions.Regex.Replace(
                maskedBody, 
                @"\d{3}-\d{2}-\d{4}", 
                "***-**-****"
            );
            
            return new JObject(
                new JProperty("timestamp", DateTime.UtcNow.ToString("o")),
                new JProperty("requestId", context.RequestId),
                new JProperty("method", context.Request.Method),
                new JProperty("url", context.Request.Url.ToString()),
                new JProperty("body", maskedBody),
                new JProperty("ipAddress", context.Request.IpAddress)
            ).ToString();
        }</log-to-eventhub>
    </inbound>
    
    <backend>
        <forward-request />
    </backend>
    
    <outbound>
        <base />
        
        <!-- Log response -->
        <log-to-eventhub logger-id="audit-logger">@{
            return new JObject(
                new JProperty("timestamp", DateTime.UtcNow.ToString("o")),
                new JProperty("requestId", context.RequestId),
                new JProperty("statusCode", context.Response.StatusCode),
                new JProperty("elapsed", context.Elapsed.TotalMilliseconds)
            ).ToString();
        }</log-to-eventhub>
    </outbound>
    
    <on-error>
        <base />
    </on-error>
</policies>
```

### Scenario 4: A/B Testing with Canary Deployment

```xml
<policies>
    <inbound>
        <base />
        
        <!-- Randomly assign 10% traffic to beta -->
        <set-variable name="isBetaUser" value="@{
            var random = new Random(context.RequestId.GetHashCode());
            return random.Next(100) < 10; // 10% to beta
        }" />
        
        <!-- OR: Beta users based on header -->
        <set-variable name="isBetaUser" value="@(
            context.Request.Headers.GetValueOrDefault("x-beta-tester", "false") == "true"
        )" />
    </inbound>
    
    <backend>
        <choose>
            <when condition="@((bool)context.Variables["isBetaUser"])">
                <!-- Route to beta backend -->
                <set-backend-service base-url="https://beta-api.example.com" />
                <set-header name="x-backend-version" exists-action="override">
                    <value>beta</value>
                </set-header>
            </when>
            <otherwise>
                <!-- Route to production backend -->
                <set-backend-service base-url="https://api.example.com" />
                <set-header name="x-backend-version" exists-action="override">
                    <value>production</value>
                </set-header>
            </otherwise>
        </choose>
        
        <forward-request />
    </backend>
    
    <outbound>
        <base />
        
        <!-- Indicate which backend served the request -->
        <set-header name="x-served-by" exists-action="override">
            <value>@(context.Variables.GetValueOrDefault<bool>("isBetaUser") ? "beta" : "production")</value>
        </set-header>
    </outbound>
    
    <on-error>
        <base />
    </on-error>
</policies>
```

### Scenario 5: Circuit Breaker Pattern

```xml
<policies>
    <inbound>
        <base />
        
        <!-- Check if circuit is open (using cache to store state) -->
        <cache-lookup-value key="circuit-breaker-state" variable-name="circuitState" />
        
        <choose>
            <when condition="@(context.Variables.GetValueOrDefault<string>("circuitState") == "open")">
                <!-- Circuit open, return cached response or error -->
                <return-response>
                    <set-status code="503" reason="Service Unavailable" />
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", "Service temporarily unavailable due to high error rate")
                        ).ToString();
                    }</set-body>
                </return-response>
            </when>
        </choose>
    </inbound>
    
    <backend>
        <forward-request timeout="10" />
    </backend>
    
    <outbound>
        <base />
        
        <!-- Reset circuit breaker on success -->
        <cache-store-value key="circuit-breaker-state" value="closed" duration="60" />
        <cache-store-value key="circuit-breaker-failures" value="0" duration="60" />
    </outbound>
    
    <on-error>
        <!-- Increment failure count -->
        <cache-lookup-value key="circuit-breaker-failures" variable-name="failures" />
        <set-variable name="failureCount" value="@{
            var current = context.Variables.GetValueOrDefault<int>("failures", 0);
            return current + 1;
        }" />
        <cache-store-value key="circuit-breaker-failures" value="@((int)context.Variables["failureCount"])" duration="60" />
        
        <!-- Open circuit if failures exceed threshold -->
        <choose>
            <when condition="@((int)context.Variables["failureCount"] >= 5)">
                <cache-store-value key="circuit-breaker-state" value="open" duration="300" /> <!-- Open for 5 minutes -->
            </when>
        </choose>
        
        <return-response>
            <set-status code="503" />
            <set-body>@{
                return new JObject(
                    new JProperty("error", "Backend service error")
                ).ToString();
            }</set-body>
        </return-response>
    </on-error>
</policies>
```

### Scenario 6: GraphQL to REST Transformation

```xml
<policies>
    <inbound>
        <base />
        
        <!-- Parse GraphQL query -->
        <set-variable name="graphqlQuery" value="@{
            var body = context.Request.Body.As<JObject>(preserveContent: true);
            return body["query"]?.ToString() ?? "";
        }" />
        
        <!-- Determine REST endpoint based on GraphQL query -->
        <choose>
            <!-- Query: { user(id: "123") { name, email } } -->
            <when condition="@(((string)context.Variables["graphqlQuery"]).Contains("user("))">
                <set-variable name="userId" value="@{
                    var query = (string)context.Variables["graphqlQuery"];
                    var match = System.Text.RegularExpressions.Regex.Match(query, @"user\(id:\s*""(\w+)""\)");
                    return match.Success ? match.Groups[1].Value : "";
                }" />
                <rewrite-uri template="/api/users/@((string)context.Variables["userId"])" />
            </when>
            
            <!-- Query: { users { name, email } } -->
            <when condition="@(((string)context.Variables["graphqlQuery"]).Contains("users"))">
                <rewrite-uri template="/api/users" />
            </when>
        </choose>
    </inbound>
    
    <backend>
        <forward-request />
    </backend>
    
    <outbound>
        <base />
        
        <!-- Transform REST response to GraphQL format -->
        <set-body>@{
            var response = context.Response.Body.As<JObject>(preserveContent: true);
            
            return new JObject(
                new JProperty("data", response)
            ).ToString();
        }</set-body>
    </outbound>
    
    <on-error>
        <base />
    </on-error>
</policies>
```

---

## Advanced Topics

### 1. Named Values & Key Vault Integration

Named values allow you to store configuration without hardcoding in policies.

```xml
<!-- Using named values -->
<inbound>
    <set-header name="Authorization" exists-action="override">
        <value>Bearer {{backend-api-token}}</value>
    </set-header>
    
    <set-backend-service base-url="{{backend-url}}" />
</inbound>
```

**Key Vault Integration:**
1. Store secret in Azure Key Vault
2. Grant APIM managed identity access to Key Vault
3. Create named value referencing Key Vault secret:
   - Name: `backend-api-token`
   - Type: Key Vault
   - Secret identifier: `https://mykv.vault.azure.net/secrets/api-token`

### 2. Policy Expressions Context Object

Available properties in `context` object:

```csharp
// Request
context.Request.Method              // GET, POST, etc.
context.Request.Url                 // Full URL
context.Request.Url.Path            // /api/users
context.Request.Url.Query           // Query string
context.Request.Headers             // Header collection
context.Request.Body.As<T>()        // Parse body
context.Request.IpAddress           // Client IP
context.Request.MatchedParameters   // Route parameters

// Response
context.Response.StatusCode         // 200, 404, etc.
context.Response.StatusReason       // OK, Not Found, etc.
context.Response.Headers            // Header collection
context.Response.Body.As<T>()       // Parse body

// API & Product
context.Api.Id                      // API identifier
context.Api.Name                    // API name
context.Product.Name                // Product name
context.Subscription.Id             // Subscription ID
context.Subscription.Key            // Subscription key

// User (if authenticated)
context.User.Id                     // User ID
context.User.Email                  // User email

// Misc
context.RequestId                   // Unique request ID (GUID)
context.Deployment.Region           // Azure region
context.Elapsed                     // TimeSpan since request started
context.LastError                   // Error details (in on-error)
context.Variables                   // Custom variables
```

### 3. Policy Fragments (Reusable Policies)

Create reusable policy fragments:

```xml
<!-- Fragment: add-correlation-id -->
<fragment>
    <set-header name="x-correlation-id" exists-action="skip">
        <value>@(context.RequestId)</value>
    </set-header>
</fragment>

<!-- Usage in policy -->
<inbound>
    <include-fragment fragment-id="add-correlation-id" />
</inbound>
```

### 4. Custom Error Responses

```xml
<!-- Define at global scope -->
<policies>
    <inbound />
    <backend />
    <outbound />
    <on-error>
        <choose>
            <when condition="@(context.LastError.Reason == "Unauthorized")">
                <return-response>
                    <set-status code="401" />
                    <set-header name="WWW-Authenticate" exists-action="override">
                        <value>Bearer realm="api", error="invalid_token"</value>
                    </set-header>
                    <set-body>@{
                        return new JObject(
                            new JProperty("error", new JObject(
                                new JProperty("code", "Unauthorized"),
                                new JProperty("message", "Invalid or expired authentication token")
                            ))
                        ).ToString();
                    }</set-body>
                </return-response>
            </when>
        </choose>
    </on-error>
</policies>
```

### 5. Dapr Integration

```xml
<policies>
    <inbound>
        <!-- Invoke Dapr service -->
        <set-backend-service backend-id="dapr" dapr-app-id="my-service" />
        <set-header name="dapr-app-id" exists-action="override">
            <value>my-service</value>
        </set-header>
    </inbound>
    
    <backend>
        <forward-request />
    </backend>
    
    <outbound />
    <on-error />
</policies>
```

### 6. WebSocket APIs

```xml
<policies>
    <inbound>
        <!-- Validate WebSocket upgrade request -->
        <choose>
            <when condition="@(context.Request.Headers.GetValueOrDefault("Upgrade", "") != "websocket")">
                <return-response>
                    <set-status code="400" reason="Bad Request" />
                </return-response>
            </when>
        </choose>
    </inbound>
    
    <backend>
        <forward-request />
    </backend>
    
    <outbound />
    <on-error />
</policies>
```

### 7. Emit Metrics to Application Insights

```xml
<inbound>
    <!-- Emit custom metric -->
    <emit-metric name="RequestsPerUser" value="1" namespace="CustomMetrics">
        <dimension name="UserId" value="@{
            var jwt = context.Request.Headers.GetValueOrDefault("Authorization", "").Replace("Bearer ", "").AsJwt();
            return jwt?.Claims.GetValueOrDefault("sub", "anonymous");
        }" />
        <dimension name="ApiName" value="@(context.Api.Name)" />
    </emit-metric>
</inbound>
```

### 8. Managed Identity for Backend Auth

```xml
<inbound>
    <!-- Get token from managed identity -->
    <authentication-managed-identity resource="https://management.azure.com/" 
                                     output-token-variable-name="msi-access-token" />
    
    <!-- Use token to call Azure resource -->
    <set-header name="Authorization" exists-action="override">
        <value>@("Bearer " + (string)context.Variables["msi-access-token"])</value>
    </set-header>
</inbound>
```

---

## Best Practices

### 1. Security Best Practices

#### ✅ DO:
- Always validate JWT tokens for authenticated APIs
- Use Key Vault for secrets (don't hardcode in policies)
- Remove backend technology headers (Server, X-Powered-By)
- Implement rate limiting to prevent abuse
- Use IP filtering for internal APIs
- Enable CORS only for trusted origins
- Use HTTPS only (redirect HTTP to HTTPS)

#### ❌ DON'T:
- Don't expose internal error details to clients
- Don't log sensitive data (passwords, tokens, PII)
- Don't trust client-provided headers without validation

```xml
<!-- Good: Secure setup -->
<inbound>
    <validate-jwt header-name="Authorization" />
    <rate-limit-by-key calls="100" renewal-period="60" />
    <ip-filter action="allow">
        <address-range from="10.0.0.0" to="10.0.255.255" />
    </ip-filter>
</inbound>
```

### 2. Performance Best Practices

#### ✅ DO:
- Use caching for read-heavy APIs
- Keep policy expressions simple (complex logic impacts latency)
- Use `send-request` mode="new" for parallel calls
- Set appropriate timeouts
- Minimize transformations (do in backend if possible)

#### ❌ DON'T:
- Don't make synchronous external calls in hot path
- Don't perform complex JSON transformations on large payloads
- Don't use retry without timeout limits

```xml
<!-- Good: Parallel external calls -->
<inbound>
    <send-request mode="new" response-variable-name="service1" timeout="5">
        <set-url>https://service1.com/api</set-url>
    </send-request>
    <send-request mode="new" response-variable-name="service2" timeout="5">
        <set-url>https://service2.com/api</set-url>
    </send-request>
</inbound>
```

### 3. Maintainability Best Practices

#### ✅ DO:
- Use policy fragments for reusable logic
- Document complex policy expressions with comments
- Use named values for configuration
- Organize policies by scope (global, product, API, operation)
- Version your APIs explicitly

#### ❌ DON'T:
- Don't duplicate logic across multiple policies
- Don't create overly complex nested conditions
- Don't mix concerns (auth, rate limiting, transformation) without structure

```xml
<!-- Good: Clear structure with comments -->
<inbound>
    <!-- Step 1: Authentication -->
    <include-fragment fragment-id="jwt-validation" />
    
    <!-- Step 2: Authorization -->
    <include-fragment fragment-id="rate-limiting" />
    
    <!-- Step 3: Request enrichment -->
    <set-header name="x-correlation-id" exists-action="override">
        <value>@(context.RequestId)</value>
    </set-header>
</inbound>
```

### 4. Error Handling Best Practices

#### ✅ DO:
- Always implement on-error section
- Return consistent error format
- Include correlation IDs in errors
- Log errors to monitoring system
- Use appropriate HTTP status codes

```xml
<!-- Good: Structured error handling -->
<on-error>
    <log-to-eventhub logger-id="error-logger">
        @(context.LastError.Reason + ": " + context.LastError.Message)
    </log-to-eventhub>
    
    <return-response>
        <set-status code="500" />
        <set-body>@{
            return new JObject(
                new JProperty("error", new JObject(
                    new JProperty("code", "InternalError"),
                    new JProperty("message", "An error occurred"),
                    new JProperty("correlationId", context.RequestId)
                ))
            ).ToString();
        }</set-body>
    </return-response>
</on-error>
```

### 5. Testing Best Practices

#### Test Checklist:
- [ ] Test with valid and invalid JWT tokens
- [ ] Test rate limiting by exceeding limits
- [ ] Test caching (first call, cached call, cache expiry)
- [ ] Test error scenarios (backend down, timeout, invalid input)
- [ ] Test CORS with different origins
- [ ] Test with large payloads
- [ ] Load test with expected traffic

### 6. Monitoring Best Practices

#### ✅ DO:
- Enable Application Insights integration
- Use emit-metric for custom metrics
- Log important business events
- Monitor rate limit hits
- Track backend response times

```xml
<!-- Good: Comprehensive logging -->
<outbound>
    <emit-metric name="ApiResponseTime" value="@(context.Elapsed.TotalMilliseconds)" />
    <emit-metric name="ApiCalls" value="1">
        <dimension name="StatusCode" value="@(context.Response.StatusCode.ToString())" />
        <dimension name="Operation" value="@(context.Operation.Name)" />
    </emit-metric>
</outbound>
```

---

## Quick Reference Card

### Most Common Policies

| Category | Policy | Usage |
|----------|--------|-------|
| **Auth** | `validate-jwt` | Validate OAuth/OIDC tokens |
| **Rate Limiting** | `rate-limit-by-key` | Limit calls per time period |
| **Transformation** | `set-body` | Modify request/response body |
| **Routing** | `set-backend-service` | Change backend URL |
| **Caching** | `cache-lookup` / `cache-store` | Cache responses |
| **Headers** | `set-header` | Add/modify/remove headers |
| **CORS** | `cors` | Enable cross-origin requests |
| **Logging** | `log-to-eventhub` | Send logs to Event Hub |
| **External Call** | `send-request` | Call external service |
| **Error** | `return-response` | Return custom response |

### Policy Execution Order

```
Global → Product → API → Operation
   ↓        ↓       ↓       ↓
Inbound → Backend → Outbound
                ↓
          (On-Error if any error)
```

### Context Properties

```csharp
context.Request.Method              // HTTP method
context.Request.Url.Path            // URL path
context.Request.Headers["name"]     // Header value
context.Response.StatusCode         // Status code
context.RequestId                   // Correlation ID
context.Subscription.Id             // Subscription
context.Variables["name"]           // Custom variable
```

---

## Summary

Azure APIM is a powerful API gateway that provides:
- **Security**: JWT validation, IP filtering, rate limiting
- **Transformation**: Request/response modification, protocol bridging
- **Routing**: Dynamic backend selection, load balancing
- **Caching**: Response caching for performance
- **Monitoring**: Logging, metrics, analytics
- **Developer Experience**: Portal, documentation, testing

### 🎯 Mental Model Recap:
1. **Assembly Line**: Request flows through inbound → backend → outbound
2. **Nested Boxes**: Policies inherit from global → product → API → operation
3. **Middleware Chain**: Similar to ASP.NET Core middleware pipeline
4. **Smart Proxy**: APIM sits between clients and backends, adding intelligence

Use this guide as a reference when designing and implementing APIM policies for your APIs!
