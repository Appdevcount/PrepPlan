# Azure Static Web Apps & Azure Front Door - Comprehensive Guide

**Complete Guide for Hosting ReactJS Applications**
*Last Updated: March 2026*

---

## Table of Contents

1. [Azure Static Web Apps](#azure-static-web-apps)
2. [Azure Front Door](#azure-front-door)
3. [ReactJS Integration & Examples](#reactjs-integration--examples)
4. [Architecture Patterns](#architecture-patterns)
5. [Best Practices & Optimization](#best-practices--optimization)

---

# Azure Static Web Apps

## Overview

Azure Static Web Apps is a fully managed service that automatically builds and deploys full-stack web applications to Azure from a code repository. It's optimized for modern web frameworks like React, Angular, Vue, and Blazor.

### Key Concepts

- **Serverless APIs**: Built-in Azure Functions for backend logic
- **Global Distribution**: Content delivered via Microsoft's global CDN
- **Automatic SSL**: Free SSL certificates for custom domains
- **Built-in Authentication**: Pre-configured auth providers (GitHub, Azure AD, Twitter, etc.)
- **Staging Environments**: Automatic preview environments for pull requests
- **Zero-config Deployment**: GitHub Actions or Azure DevOps integration

### Pricing Tiers

| Tier | Price | Features |
|------|-------|----------|
| **Free** | $0/month | 100 GB bandwidth, 0.5 GB storage, 2 custom domains |
| **Standard** | ~$9/month | Unlimited bandwidth, 10 GB storage, 5 custom domains, SLA |

---

## Core Features

### 1. Automated Build & Deployment

#### GitHub Actions Integration

When you create a Static Web App, Azure automatically creates a GitHub Actions workflow:

```yaml
# .github/workflows/azure-static-web-apps.yml
name: Azure Static Web Apps CI/CD

on:
  push:
    branches:
      - main
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - main

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/" # App source code path
          api_location: "api" # Api source code path - optional
          output_location: "build" # Built app content directory
          
  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
```

### 2. Configuration File

#### staticwebapp.config.json

**IMPORTANT**: Do not create this file manually. Use Static Web Apps CLI:

```bash
# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Initialize configuration
npx swa init --yes
```

#### Complete Configuration Example

```json
{
  "routes": [
    {
      "route": "/profile",
      "allowedRoles": ["authenticated"]
    },
    {
      "route": "/admin/*",
      "allowedRoles": ["administrator"]
    },
    {
      "route": "/api/*",
      "methods": ["GET", "POST"],
      "allowedRoles": ["authenticated"]
    },
    {
      "route": "/images/*",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
      }
    },
    {
      "route": "/logout",
      "redirect": "/.auth/logout"
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*.{png,jpg,gif,ico}", "/css/*", "/api/*"]
  },
  "responseOverrides": {
    "401": {
      "redirect": "/login",
      "statusCode": 302
    },
    "404": {
      "rewrite": "/404.html",
      "statusCode": 404
    }
  },
  "globalHeaders": {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "Content-Security-Policy": "default-src 'self' https:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
  },
  "mimeTypes": {
    ".json": "application/json",
    ".wasm": "application/wasm"
  },
  "platform": {
    "apiRuntime": "node:18"
  },
  "trailingSlash": "auto",
  "networking": {
    "allowedIpRanges": []
  }
}
```

### 3. Authentication & Authorization

#### Built-in Authentication Providers

Azure Static Web Apps provides pre-configured authentication:

```javascript
// src/utils/auth.js
export const authProviders = {
  github: '/.auth/login/github',
  twitter: '/.auth/login/twitter',
  google: '/.auth/login/google',
  facebook: '/.auth/login/facebook',
  aad: '/.auth/login/aad', // Azure Active Directory
};

// Get current user info
export async function getUserInfo() {
  const response = await fetch('/.auth/me');
  const payload = await response.json();
  const { clientPrincipal } = payload;
  return clientPrincipal;
}

// Example user object structure
/*
{
  "identityProvider": "github",
  "userId": "d75b260a64504067bfc5b2905e3b8182",
  "userDetails": "username",
  "userRoles": ["anonymous", "authenticated"]
}
*/
```

#### React Authentication Component

```jsx
// src/components/Auth.jsx
import React, { useState, useEffect } from 'react';

const Auth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch('/.auth/me');
        const data = await response.json();
        setUser(data.clientPrincipal);
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, []);

  const handleLogin = (provider) => {
    window.location.href = `/.auth/login/${provider}`;
  };

  const handleLogout = () => {
    window.location.href = '/.auth/logout';
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="auth-container">
      {user ? (
        <div className="user-info">
          <p>Welcome, {user.userDetails}!</p>
          <p>Provider: {user.identityProvider}</p>
          <p>Roles: {user.userRoles.join(', ')}</p>
          <button onClick={handleLogout}>Logout</button>
        </div>
      ) : (
        <div className="login-options">
          <button onClick={() => handleLogin('github')}>Login with GitHub</button>
          <button onClick={() => handleLogin('aad')}>Login with Azure AD</button>
          <button onClick={() => handleLogin('google')}>Login with Google</button>
        </div>
      )}
    </div>
  );
};

export default Auth;
```

#### Custom Roles Configuration

```json
// staticwebapp.config.json - Custom roles via invitation
{
  "routes": [
    {
      "route": "/admin/*",
      "allowedRoles": ["administrator", "moderator"]
    }
  ],
  "auth": {
    "identityProviders": {
      "azureActiveDirectory": {
        "registration": {
          "openIdIssuer": "https://login.microsoftonline.com/{TENANT_ID}/v2.0",
          "clientIdSettingName": "AAD_CLIENT_ID",
          "clientSecretSettingName": "AAD_CLIENT_SECRET"
        }
      },
      "customOpenIdConnectProviders": {
        "auth0": {
          "registration": {
            "clientIdSettingName": "AUTH0_CLIENT_ID",
            "clientCredential": {
              "clientSecretSettingName": "AUTH0_CLIENT_SECRET"
            },
            "openIdConnectConfiguration": {
              "wellKnownOpenIdConfiguration": "https://{AUTH0_DOMAIN}/.well-known/openid-configuration"
            }
          },
          "login": {
            "nameClaimType": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name",
            "scopes": ["openid", "profile", "email"]
          }
        }
      }
    }
  }
}
```

### 4. Managed Functions (APIs)

#### Azure Functions Integration

```javascript
// api/GetProducts/index.js
module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    // Access authenticated user
    const header = req.headers['x-ms-client-principal'];
    const principal = header ? JSON.parse(Buffer.from(header, 'base64').toString('ascii')) : null;

    if (!principal) {
        context.res = {
            status: 401,
            body: 'Unauthorized'
        };
        return;
    }

    const products = [
        { id: 1, name: 'Product 1', price: 29.99 },
        { id: 2, name: 'Product 2', price: 49.99 },
        { id: 3, name: 'Product 3', price: 19.99 }
    ];

    context.res = {
        status: 200,
        headers: {
            'Content-Type': 'application/json',
            'Cache-Control': 'no-cache'
        },
        body: {
            products,
            user: principal.userDetails
        }
    };
};
```

#### Function Configuration

```json
// api/GetProducts/function.json
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": ["get"],
      "route": "products"
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
```

#### React API Integration

```jsx
// src/hooks/useProducts.js
import { useState, useEffect } from 'react';

export const useProducts = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetch('/api/products');
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        setProducts(data.products);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  return { products, loading, error };
};

// Usage in component
// const { products, loading, error } = useProducts();
```

### 5. Routing & Navigation

#### Client-side Routing with React Router

```jsx
// src/App.jsx
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';

const ProtectedRoute = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/.auth/me')
      .then(res => res.json())
      .then(data => {
        setUser(data.clientPrincipal);
        setLoading(false);
      });
  }, []);

  if (loading) return <div>Loading...</div>;
  
  return user ? children : <Navigate to="/login" />;
};

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/login" element={<Login />} />
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          } 
        />
        <Route path="/products" element={<Products />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
```

### 6. Environment Variables

#### Configuration Application Settings

Environment variables are configured in Azure Portal:

```bash
# Azure Portal: Static Web App > Configuration > Application settings

# Add settings:
REACT_APP_API_URL=https://api.example.com
REACT_APP_ENABLE_ANALYTICS=true
DATABASE_CONNECTION_STRING=secret_value  # API-only, not exposed to frontend
```

#### Accessing in React

```javascript
// src/config.js
export const config = {
  apiUrl: process.env.REACT_APP_API_URL || 'http://localhost:7071',
  enableAnalytics: process.env.REACT_APP_ENABLE_ANALYTICS === 'true',
  environment: process.env.NODE_ENV
};

// Usage
import { config } from './config';

fetch(`${config.apiUrl}/api/data`)
  .then(response => response.json())
  .then(data => console.log(data));
```

#### Accessing in API Functions

```javascript
// api/config.js
module.exports = async function (context, req) {
    const connectionString = process.env.DATABASE_CONNECTION_STRING;
    // Use connection string securely
    // Frontend cannot access this value
};
```

### 7. Custom Domains & SSL

#### Adding Custom Domain

```bash
# Using Azure CLI
az staticwebapp hostname set \
  --name my-static-web-app \
  --resource-group my-resource-group \
  --hostname www.example.com

# DNS Configuration Required:
# CNAME: www.example.com -> {your-swa}.azurestaticapps.net
# TXT: _dnsauth.www.example.com -> {validation-token}
```

#### Apex Domain Configuration

```bash
# For apex domains (example.com), use ALIAS or ANAME records
# Or use Azure DNS with alias record sets

az network dns record-set a add-record \
  --resource-group my-dns-rg \
  --zone-name example.com \
  --record-set-name @ \
  --ipv4-address {swa-ip-address}
```

#### SSL Certificate (Automatic)

- Free SSL certificates automatically provisioned
- Auto-renewal managed by Azure
- Supports TLS 1.2 and TLS 1.3

### 8. Staging Environments

#### Pull Request Environments

Every pull request automatically creates a staging environment:

```
Production: https://my-app.azurestaticapps.net
PR #42: https://my-app-42.azurestaticapps.net
```

#### Configuration per Environment

```json
// staticwebapp.config.json
{
  "environmentVariables": {
    "production": {
      "REACT_APP_API_URL": "https://api.production.com"
    },
    "staging": {
      "REACT_APP_API_URL": "https://api.staging.com"
    }
  }
}
```

### 9. Monitoring & Diagnostics

#### Application Insights Integration

```bash
# Azure Portal: Static Web App > Application Insights
# Enable Application Insights

# Connection string is automatically configured
```

#### Client-side Telemetry

```javascript
// src/telemetry.js
import { ApplicationInsights } from '@microsoft/applicationinsights-web';

const appInsights = new ApplicationInsights({
  config: {
    connectionString: process.env.REACT_APP_APPINSIGHTS_CONNECTION_STRING,
    enableAutoRouteTracking: true,
    enableCorsCorrelation: true,
    enableRequestHeaderTracking: true,
    enableResponseHeaderTracking: true
  }
});

appInsights.loadAppInsights();
appInsights.trackPageView();

export default appInsights;
```

```jsx
// src/App.jsx
import { useEffect } from 'react';
import appInsights from './telemetry';

function App() {
  useEffect(() => {
    appInsights.trackEvent({ name: 'AppLoaded' });
  }, []);

  const handleButtonClick = () => {
    appInsights.trackEvent({ 
      name: 'ButtonClicked',
      properties: { buttonId: 'submit' }
    });
  };

  return (
    <div>
      <button onClick={handleButtonClick}>Submit</button>
    </div>
  );
}
```

---

# Azure Front Door

## Overview

Azure Front Door is a global, scalable entry point that uses Microsoft's global edge network to create fast, secure, and highly available web applications. It provides Layer 7 load balancing, SSL offloading, path-based routing, and Web Application Firewall (WAF) capabilities.

### Key Features

- **Global Load Balancing**: Distribute traffic across multiple backends
- **SSL/TLS Termination**: Offload SSL processing to the edge
- **Web Application Firewall (WAF)**: Protect against OWASP Top 10 threats
- **Caching**: CDN capabilities with intelligent caching
- **Custom Domains**: Support for multiple custom domains
- **Health Probes**: Automatic failover for unhealthy backends
- **URL Rewriting**: Path-based routing and URL manipulation
- **Session Affinity**: Cookie-based session persistence

### Pricing Tiers

| Tier | Use Case | Features |
|------|----------|----------|
| **Standard** | General web apps | Basic routing, caching, SSL |
| **Premium** | Enterprise apps | WAF Premium, Private Link, enhanced security |

**Pricing Components**:
- Outbound data transfer: ~$0.03-0.15/GB
- Inbound data transfer: Free
- Routing rules: ~$0.60/rule/month
- WAF policies: ~$5/policy/month

---

## Core Features

### 1. Architecture & Components

```
┌─────────────────────────────────────────────────────────────┐
│                        Users (Global)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   Azure Front Door (Edge)                    │
│  ┌───────────────┬──────────────┬────────────────────────┐ │
│  │ WAF/Security  │   Caching    │  SSL Termination       │ │
│  └───────────────┴──────────────┴────────────────────────┘ │
└────────────────────────┬────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Backend   │  │   Backend   │  │   Backend   │
│  Pool #1    │  │  Pool #2    │  │  Pool #3    │
│  (Primary)  │  │ (Secondary) │  │  (Backup)   │
└─────────────┘  └─────────────┘  └─────────────┘
     │                │                │
     ▼                ▼                ▼
Static Web App   API Management   App Service
```

### 2. Configuration with Bicep

#### Complete Front Door Setup

```bicep
// frontdoor.bicep
param frontDoorName string
param staticWebAppHostname string
param location string = 'global'

@description('Front Door Profile')
resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: frontDoorName
  location: location
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

@description('Front Door Endpoint')
resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: frontDoorProfile
  name: '${frontDoorName}-endpoint'
  location: location
  properties: {
    enabledState: 'Enabled'
  }
}

@description('Origin Group')
resource originGroup 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: frontDoorProfile
  name: 'static-web-app-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

@description('Origin - Static Web App')
resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroup
  name: 'static-web-app-origin'
  properties: {
    hostName: staticWebAppHostname
    httpPort: 80
    httpsPort: 443
    originHostHeader: staticWebAppHostname
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

@description('Route - Default')
resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: frontDoorEndpoint
  name: 'default-route'
  dependsOn: [
    origin
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

@description('WAF Policy')
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: '${frontDoorName}wafpolicy'
  location: location
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
      requestBodyCheck: 'Enabled'
    }
    customRules: {
      rules: [
        {
          name: 'RateLimitRule'
          priority: 1
          ruleType: 'RateLimitRule'
          rateLimitThreshold: 100
          rateLimitDurationInMinutes: 1
          matchConditions: [
            {
              matchVariable: 'RequestUri'
              operator: 'Contains'
              matchValue: [
                '/api/'
              ]
            }
          ]
          action: 'Block'
        }
        {
          name: 'GeoFilterRule'
          priority: 2
          ruleType: 'MatchRule'
          matchConditions: [
            {
              matchVariable: 'RemoteAddr'
              operator: 'GeoMatch'
              negateCondition: true
              matchValue: [
                'US'
                'GB'
                'CA'
              ]
            }
          ]
          action: 'Block'
        }
      ]
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
          ruleSetAction: 'Block'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.0'
        }
      ]
    }
  }
}

@description('Security Policy')
resource securityPolicy 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
  parent: frontDoorProfile
  name: 'security-policy'
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: frontDoorEndpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

output frontDoorEndpoint string = frontDoorEndpoint.properties.hostName
output frontDoorId string = frontDoorProfile.id
```

### 3. Caching Configuration

#### Cache Behavior Settings

```bicep
// Caching Route Configuration
resource cacheRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: frontDoorEndpoint
  name: 'cache-route'
  properties: {
    originGroup: {
      id: originGroup.id
    }
    patternsToMatch: [
      '/static/*'
      '/images/*'
    ]
    cacheConfiguration: {
      queryStringCachingBehavior: 'IgnoreQueryString'
      compressionSettings: {
        contentTypesToCompress: [
          'application/javascript'
          'application/json'
          'application/xml'
          'text/css'
          'text/html'
          'text/plain'
        ]
        isCompressionEnabled: true
      }
      cacheDuration: '1.00:00:00' // 1 day
    }
    enabledState: 'Enabled'
  }
}
```

#### Cache Purging

```bash
# Azure CLI - Purge cache
az afd endpoint purge \
  --resource-group my-resource-group \
  --profile-name my-frontdoor \
  --endpoint-name my-endpoint \
  --content-paths '/*' '/css/*' '/js/*'
```

```javascript
// Programmatic cache purge using Azure SDK
const { AzureFrontDoorManagementClient } = require('@azure/arm-frontdoor');
const { DefaultAzureCredential } = require('@azure/identity');

async function purgeFrontDoorCache() {
  const credential = new DefaultAzureCredential();
  const client = new AzureFrontDoorManagementClient(credential, subscriptionId);
  
  await client.endpoints.beginPurgeContent(
    'my-resource-group',
    'my-frontdoor-profile',
    'my-endpoint',
    {
      contentPaths: ['/images/*', '/css/*', '/js/*']
    }
  );
  
  console.log('Cache purged successfully');
}
```

### 4. Custom Domains & SSL

#### Adding Custom Domain

```bicep
// Custom Domain Configuration
param customDomain string = 'www.example.com'

resource customDomainResource 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
  parent: frontDoorProfile
  name: replace(customDomain, '.', '-')
  properties: {
    hostName: customDomain
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
    dnsZoneId: null
  }
}

// Associate domain with endpoint
resource domainAssociation 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  parent: frontDoorEndpoint
  name: 'custom-domain-route'
  dependsOn: [
    customDomainResource
  ]
  properties: {
    customDomains: [
      {
        id: customDomainResource.id
      }
    ]
    originGroup: {
      id: originGroup.id
    }
    patternsToMatch: [
      '/*'
    ]
    supportedProtocols: [
      'Https'
    ]
    forwardingProtocol: 'HttpsOnly'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}
```

#### DNS Configuration

```bash
# DNS Records Required:
# CNAME: www.example.com -> {frontdoor-endpoint}.z01.azurefd.net
# TXT (validation): _dnsauth.www.example.com -> {validation-token}

# For apex domain (example.com):
# ALIAS/ANAME: example.com -> {frontdoor-endpoint}.z01.azurefd.net
```

### 5. WAF (Web Application Firewall)

#### WAF Rule Types

**1. Rate Limiting**

```bicep
{
  name: 'ApiRateLimit'
  priority: 1
  ruleType: 'RateLimitRule'
  rateLimitThreshold: 100
  rateLimitDurationInMinutes: 1
  matchConditions: [
    {
      matchVariable: 'RequestUri'
      operator: 'Contains'
      matchValue: ['/api/']
    }
  ]
  action: 'Block'
}
```

**2. Geo-Filtering**

```bicep
{
  name: 'AllowOnlyUSTraffic'
  priority: 2
  ruleType: 'MatchRule'
  matchConditions: [
    {
      matchVariable: 'RemoteAddr'
      operator: 'GeoMatch'
      negateCondition: true
      matchValue: ['US']
    }
  ]
  action: 'Block'
}
```

**3. IP Filtering**

```bicep
{
  name: 'BlockMaliciousIPs'
  priority: 3
  ruleType: 'MatchRule'
  matchConditions: [
    {
      matchVariable: 'RemoteAddr'
      operator: 'IPMatch'
      matchValue: [
        '192.0.2.1/32'
        '198.51.100.0/24'
      ]
    }
  ]
  action: 'Block'
}
```

**4. Custom Header Rules**

```bicep
{
  name: 'RequireAPIKey'
  priority: 4
  ruleType: 'MatchRule'
  matchConditions: [
    {
      matchVariable: 'RequestHeader'
      selector: 'X-API-Key'
      operator: 'Equal'
      negateCondition: true
      matchValue: ['valid-api-key']
    }
    {
      matchVariable: 'RequestUri'
      operator: 'BeginsWith'
      matchValue: ['/api/']
    }
  ]
  action: 'Block'
}
```

### 6. Health Probes & Failover

```bicep
// Advanced Health Probe Configuration
resource originGroupWithHealth 'Microsoft.Cdn/profiles/originGroups@2023-05-01' = {
  parent: frontDoorProfile
  name: 'resilient-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    healthProbeSettings: {
      probePath: '/health'
      probeRequestType: 'GET'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 30
    }
    sessionAffinityState: 'Enabled'
    trafficRestorationTimeToHealedOrNewEndpointsInMinutes: 10
  }
}

// Primary Origin
resource primaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroupWithHealth
  name: 'primary-static-web-app'
  properties: {
    hostName: 'primary.azurestaticapps.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'primary.azurestaticapps.net'
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
  }
}

// Secondary Origin (Failover)
resource secondaryOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2023-05-01' = {
  parent: originGroupWithHealth
  name: 'secondary-static-web-app'
  properties: {
    hostName: 'secondary.azurestaticapps.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'secondary.azurestaticapps.net'
    priority: 2
    weight: 500
    enabledState: 'Enabled'
  }
}
```

### 7. Rules Engine

#### URL Rewriting & Redirection

```bicep
resource ruleSet 'Microsoft.Cdn/profiles/ruleSets@2023-05-01' = {
  parent: frontDoorProfile
  name: 'global-rules'
}

// Redirect HTTP to HTTPS
resource httpsRedirectRule 'Microsoft.Cdn/profiles/ruleSets/rules@2023-05-01' = {
  parent: ruleSet
  name: 'HttpsRedirect'
  properties: {
    order: 1
    conditions: [
      {
        name: 'RequestScheme'
        parameters: {
          typeName: 'DeliveryRuleRequestSchemeConditionParameters'
          operator: 'Equal'
          matchValues: ['HTTP']
        }
      }
    ]
    actions: [
      {
        name: 'UrlRedirect'
        parameters: {
          typeName: 'DeliveryRuleUrlRedirectActionParameters'
          redirectType: 'PermanentRedirect'
          destinationProtocol: 'Https'
        }
      }
    ]
  }
}

// SPA Routing - Redirect to index.html
resource spaRoutingRule 'Microsoft.Cdn/profiles/ruleSets/rules@2023-05-01' = {
  parent: ruleSet
  name: 'SPARouting'
  properties: {
    order: 2
    conditions: [
      {
        name: 'UrlFileExtension'
        parameters: {
          typeName: 'DeliveryRuleUrlFileExtensionMatchConditionParameters'
          operator: 'GreaterThan'
          negateCondition: true
          matchValues: ['0']
        }
      }
    ]
    actions: [
      {
        name: 'RouteConfigurationOverride'
        parameters: {
          typeName: 'DeliveryRuleRouteConfigurationOverrideActionParameters'
          originGroupOverride: {
            originGroup: {
              id: originGroup.id
            }
            forwardingProtocol: 'HttpsOnly'
          }
          cacheConfiguration: {
            queryStringCachingBehavior: 'IgnoreQueryString'
            cacheBehavior: 'Override'
            cacheDuration: '00:05:00'
          }
        }
      }
    ]
  }
}

// Add custom headers
resource securityHeadersRule 'Microsoft.Cdn/profiles/ruleSets/rules@2023-05-01' = {
  parent: ruleSet
  name: 'SecurityHeaders'
  properties: {
    order: 3
    actions: [
      {
        name: 'ModifyResponseHeader'
        parameters: {
          typeName: 'DeliveryRuleHeaderActionParameters'
          headerAction: 'Append'
          headerName: 'X-Content-Type-Options'
          value: 'nosniff'
        }
      }
      {
        name: 'ModifyResponseHeader'
        parameters: {
          typeName: 'DeliveryRuleHeaderActionParameters'
          headerAction: 'Append'
          headerName: 'X-Frame-Options'
          value: 'DENY'
        }
      }
      {
        name: 'ModifyResponseHeader'
        parameters: {
          typeName: 'DeliveryRuleHeaderActionParameters'
          headerAction: 'Append'
          headerName: 'Strict-Transport-Security'
          value: 'max-age=31536000; includeSubDomains'
        }
      }
    ]
  }
}
```

### 8. Monitoring & Analytics

#### Diagnostic Settings

```bicep
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: frontDoorProfile
  name: 'frontdoor-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'FrontDoorAccessLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'FrontDoorHealthProbeLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'FrontDoorWebApplicationFirewallLog'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}
```

#### Key Metrics to Monitor

```
- RequestCount: Total number of requests
- TotalLatency: End-to-end latency
- BackendRequestCount: Requests forwarded to backends
- BackendHealthPercentage: Health of backend origins
- WebApplicationFirewallRequestCount: WAF processed requests
- CacheHitRatio: Cache efficiency
- OriginLatency: Backend response time
- BillableResponseSize: Data transfer costs
```

---

# ReactJS Integration & Examples

## Complete ReactJS Application with SWA + Front Door

### Project Structure

```
my-react-app/
├── public/
│   ├── index.html
│   ├── favicon.ico
│   └── staticwebapp.config.json
├── src/
│   ├── components/
│   │   ├── Auth.jsx
│   │   ├── Header.jsx
│   │   ├── ProtectedRoute.jsx
│   │   └── ErrorBoundary.jsx
│   ├── hooks/
│   │   ├── useAuth.js
│   │   ├── useApi.js
│   │   └── useTelemetry.js
│   ├── services/
│   │   ├── api.service.js
│   │   └── telemetry.service.js
│   ├── utils/
│   │   ├── auth.js
│   │   └── config.js
│   ├── App.jsx
│   ├── index.jsx
│   └── App.css
├── api/
│   ├── GetProducts/
│   │   ├── index.js
│   │   └── function.json
│   ├── GetUser/
│   │   ├── index.js
│   │   └── function.json
│   └── host.json
├── .github/
│   └── workflows/
│       └── azure-static-web-apps.yml
├── package.json
├── .gitignore
└── README.md
```

### 1. Authentication Hook

```javascript
// src/hooks/useAuth.js
import { useState, useEffect, createContext, useContext } from 'react';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch('/.auth/me');
        if (!response.ok) {
          throw new Error('Failed to fetch user');
        }
        const data = await response.json();
        setUser(data.clientPrincipal);
      } catch (err) {
        setError(err.message);
        setUser(null);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, []);

  const login = (provider = 'github') => {
    const redirect = window.location.pathname;
    window.location.href = `/.auth/login/${provider}?post_login_redirect_uri=${redirect}`;
  };

  const logout = () => {
    window.location.href = '/.auth/logout';
  };

  const hasRole = (role) => {
    return user?.userRoles?.includes(role) || false;
  };

  const value = {
    user,
    loading,
    error,
    login,
    logout,
    hasRole,
    isAuthenticated: !!user
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

### 2. API Service Hook

```javascript
// src/hooks/useApi.js
import { useState, useEffect, useCallback } from 'react';

export const useApi = (url, options = {}) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        }
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
      }

      const result = await response.json();
      setData(result);
      return result;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [url, JSON.stringify(options)]);

  useEffect(() => {
    if (options.immediate !== false) {
      fetchData();
    }
  }, [fetchData, options.immediate]);

  const refetch = () => fetchData();

  return { data, loading, error, refetch };
};

// Usage examples:
// const { data, loading, error } = useApi('/api/products');
// const { data, loading, error, refetch } = useApi('/api/user', { immediate: false });
```

### 3. Protected Route Component

```jsx
// src/components/ProtectedRoute.jsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';

export const ProtectedRoute = ({ children, requiredRole = null }) => {
  const { user, loading, isAuthenticated, hasRole } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Authenticating...</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  if (requiredRole && !hasRole(requiredRole)) {
    return <Navigate to="/unauthorized" replace />;
  }

  return children;
};

// Usage:
// <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
// <Route path="/admin" element={<ProtectedRoute requiredRole="administrator"><Admin /></ProtectedRoute>} />
```

### 4. Complete App Component

```jsx
// src/App.jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './hooks/useAuth';
import { ProtectedRoute } from './components/ProtectedRoute';
import { ErrorBoundary } from './components/ErrorBoundary';
import Header from './components/Header';

// Pages
import Home from './pages/Home';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Products from './pages/Products';
import Admin from './pages/Admin';
import NotFound from './pages/NotFound';
import Unauthorized from './pages/Unauthorized';

function App() {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <BrowserRouter>
          <div className="app">
            <Header />
            <main className="main-content">
              <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/login" element={<Login />} />
                
                <Route 
                  path="/dashboard" 
                  element={
                    <ProtectedRoute>
                      <Dashboard />
                    </ProtectedRoute>
                  } 
                />
                
                <Route 
                  path="/products" 
                  element={
                    <ProtectedRoute>
                      <Products />
                    </ProtectedRoute>
                  } 
                />
                
                <Route 
                  path="/admin" 
                  element={
                    <ProtectedRoute requiredRole="administrator">
                      <Admin />
                    </ProtectedRoute>
                  } 
                />
                
                <Route path="/unauthorized" element={<Unauthorized />} />
                <Route path="*" element={<NotFound />} />
              </Routes>
            </main>
          </div>
        </BrowserRouter>
      </AuthProvider>
    </ErrorBoundary>
  );
}

export default App;
```

### 5. Products Page with API Integration

```jsx
// src/pages/Products.jsx
import { useState, useEffect } from 'react';
import { useApi } from '../hooks/useApi';
import { useAuth } from '../hooks/useAuth';

const Products = () => {
  const { user } = useAuth();
  const { data, loading, error, refetch } = useApi('/api/products');
  const [cart, setCart] = useState([]);

  const addToCart = (product) => {
    setCart([...cart, product]);
    // Track event
    if (window.appInsights) {
      window.appInsights.trackEvent({
        name: 'ProductAddedToCart',
        properties: {
          productId: product.id,
          productName: product.name,
          userId: user?.userId
        }
      });
    }
  };

  if (loading) {
    return <div className="loading">Loading products...</div>;
  }

  if (error) {
    return (
      <div className="error">
        <h2>Error Loading Products</h2>
        <p>{error}</p>
        <button onClick={refetch}>Retry</button>
      </div>
    );
  }

  return (
    <div className="products-page">
      <h1>Products</h1>
      <div className="products-grid">
        {data?.products?.map(product => (
          <div key={product.id} className="product-card">
            <img src={product.image} alt={product.name} />
            <h3>{product.name}</h3>
            <p className="price">${product.price}</p>
            <button onClick={() => addToCart(product)}>
              Add to Cart
            </button>
          </div>
        ))}
      </div>
      
      {cart.length > 0 && (
        <div className="cart-summary">
          <h3>Cart ({cart.length} items)</h3>
          <p>Total: ${cart.reduce((sum, p) => sum + p.price, 0).toFixed(2)}</p>
        </div>
      )}
    </div>
  );
};

export default Products;
```

### 6. Error Boundary

```jsx
// src/components/ErrorBoundary.jsx
import React from 'react';

export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    
    // Log to Application Insights
    if (window.appInsights) {
      window.appInsights.trackException({
        exception: error,
        properties: {
          componentStack: errorInfo.componentStack
        }
      });
    }

    this.setState({
      error,
      errorInfo
    });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-boundary">
          <h1>Something went wrong</h1>
          <details style={{ whiteSpace: 'pre-wrap' }}>
            {this.state.error && this.state.error.toString()}
            <br />
            {this.state.errorInfo?.componentStack}
          </details>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### 7. Application Insights Setup

```javascript
// src/services/telemetry.service.js
import { ApplicationInsights } from '@microsoft/applicationinsights-web';
import { ReactPlugin } from '@microsoft/applicationinsights-react-js';

const reactPlugin = new ReactPlugin();

const appInsights = new ApplicationInsights({
  config: {
    connectionString: process.env.REACT_APP_APPINSIGHTS_CONNECTION_STRING,
    extensions: [reactPlugin],
    extensionConfig: {
      [reactPlugin.identifier]: {
        history: null // Will be set in App.jsx
      }
    },
    enableAutoRouteTracking: true,
    enableCorsCorrelation: true,
    enableRequestHeaderTracking: true,
    enableResponseHeaderTracking: true,
    disableFetchTracking: false,
    enableAjaxPerfTracking: true
  }
});

if (appInsights.config.connectionString) {
  appInsights.loadAppInsights();
  appInsights.trackPageView();
  
  // Make available globally for error boundary
  window.appInsights = appInsights;
}

export { appInsights, reactPlugin };
```

### 8. Package.json

```json
{
  "name": "my-react-swa-app",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.21.0",
    "@microsoft/applicationinsights-web": "^3.0.5",
    "@microsoft/applicationinsights-react-js": "^17.0.1"
  },
  "devDependencies": {
    "@azure/static-web-apps-cli": "^1.1.4",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject",
    "swa:init": "swa init",
    "swa:build": "npm run build && swa build",
    "swa:start": "swa start http://localhost:3000 --api-location api",
    "swa:deploy": "swa deploy --env production"
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
```

---

# Architecture Patterns

## Pattern 1: Basic SWA with Front Door

```
Users → Front Door (WAF, SSL, Caching) → Static Web App (React + API)
```

**Use Case**: Simple global application with enhanced security

**Configuration**:
```bicep
// One Static Web App
// One Front Door with single origin
// WAF enabled
// Custom domain on Front Door
```

## Pattern 2: Multi-Region Deployment

```
                      Front Door (Global)
                            │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
   SWA (US East)    SWA (Europe)     SWA (Asia Pacific)
```

**Use Case**: Global application with regional failover

**Benefits**:
- Low latency for global users
- High availability
- Regional data compliance

## Pattern 3: SWA + API Management + Front Door

```
Users → Front Door → API Management → Backend APIs
                  ↓
            Static Web App (React)
```

**Use Case**: Enterprise application with complex API requirements

**Features**:
- API versioning
- Rate limiting
- API transformations
- Developer portal

## Pattern 4: Microservices Architecture

```
                    Front Door
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   Static Web App   API Management   Azure Functions
        │               │               │
        └───────────────┴───────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   Cosmos DB      SQL Database    Event Hub
```

**Use Case**: Large-scale enterprise application

---

# Best Practices & Optimization

## Performance Optimization

### 1. Code Splitting

```jsx
// Lazy load routes
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Products = lazy(() => import('./pages/Products'));
const Admin = lazy(() => import('./pages/Admin'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/products" element={<Products />} />
        <Route path="/admin" element={<Admin />} />
      </Routes>
    </Suspense>
  );
}
```

### 2. Asset Optimization

```json
// staticwebapp.config.json
{
  "routes": [
    {
      "route": "/static/*",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
      }
    },
    {
      "route": "/*.{js,css}",
      "headers": {
        "cache-control": "public, max-age=604800"
      }
    }
  ]
}
```

### 3. Image Optimization

```jsx
// Responsive images
const ProductImage = ({ product }) => (
  <picture>
    <source 
      srcSet={`${product.imageUrlWebP} 1x, ${product.imageUrlWebP2x} 2x`}
      type="image/webp"
    />
    <img 
      src={product.imageUrl}
      srcSet={`${product.imageUrl} 1x, ${product.imageUrl2x} 2x`}
      alt={product.name}
      loading="lazy"
      width={300}
      height={300}
    />
  </picture>
);
```

## Security Best Practices

### 1. Content Security Policy

```json
{
  "globalHeaders": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.monitor.azure.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https://*.azurestaticapps.net https://*.applicationinsights.azure.com; frame-ancestors 'none';",
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block",
    "Referrer-Policy": "strict-origin-when-cross-origin",
    "Permissions-Policy": "geolocation=(), microphone=(), camera=()"
  }
}
```

### 2. API Security

```javascript
// api/SecureEndpoint/index.js
module.exports = async function (context, req) {
    // Verify authentication
    const clientPrincipal = req.headers['x-ms-client-principal'];
    if (!clientPrincipal) {
        context.res = { status: 401, body: 'Unauthorized' };
        return;
    }

    const user = JSON.parse(Buffer.from(clientPrincipal, 'base64').toString());
    
    // Verify role
    if (!user.userRoles.includes('administrator')) {
        context.res = { status: 403, body: 'Forbidden' };
        return;
    }

    // Validate input
    const { data } = req.body;
    if (!data || typeof data !== 'string' || data.length > 1000) {
        context.res = { status: 400, body: 'Invalid input' };
        return;
    }

    // Process request
    context.res = {
        status: 200,
        body: { success: true }
    };
};
```

## Cost Optimization

### 1. Choose Appropriate Tier

```
Free Tier:
- Dev/test environments
- Small personal projects
- POCs

Standard Tier:
- Production applications
- Custom domains required
- SLA needed
```

### 2. Front Door Caching Strategy

```bicep
// Cache static assets aggressively
{
  patternsToMatch: ['/static/*', '/images/*']
  cacheDuration: '365.00:00:00' // 1 year
  queryStringCachingBehavior: 'IgnoreQueryString'
}

// Cache API responses conservatively
{
  patternsToMatch: ['/api/products']
  cacheDuration: '00:05:00' // 5 minutes
  queryStringCachingBehavior: 'UseQueryString'
}

// Don't cache dynamic content
{
  patternsToMatch: ['/api/user', '/api/checkout']
  cacheBehavior: 'BypassCache'
}
```

### 3. Monitor Bandwidth Usage

```kusto
// Log Analytics Query
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN"
| where Category == "FrontDoorAccessLog"
| summarize TotalBytes = sum(toint(responseSize_d)) by bin(TimeGenerated, 1d)
| render timechart
```

## Deployment Best Practices

### 1. Use Static Web Apps CLI

```bash
# Initialize
npx swa init --yes

# Local development
npx swa start http://localhost:3000 --api-location api

# Build
npx swa build

# Pre-deployment validation
# Verify appLocation and outputLocation are different

# Deploy
npx swa deploy --env production
```

### 2. Environment-Specific Configuration

```javascript
// src/config/environments.js
const environments = {
  development: {
    apiUrl: 'http://localhost:7071',
    appInsightsKey: '',
    features: { analytics: false }
  },
  staging: {
    apiUrl: 'https://staging-api.azurestaticapps.net',
    appInsightsKey: 'staging-key',
    features: { analytics: true }
  },
  production: {
    apiUrl: 'https://api.example.com',
    appInsightsKey: process.env.REACT_APP_APPINSIGHTS_KEY,
    features: { analytics: true }
  }
};

export const config = environments[process.env.REACT_APP_ENV || 'development'];
```

### 3. Preview Environments

```yaml
# .github/workflows/azure-static-web-apps.yml
# Automatically creates preview environment for each PR

on:
  pull_request:
    types: [opened, synchronize, reopened]

# Each PR gets unique URL:
# https://my-app-{pr-number}.azurestaticapps.net
```

## Monitoring & Observability

### 1. Application Insights Queries

```kusto
// Track user sessions
customEvents
| where name == "PageView"
| summarize Sessions = dcount(session_Id) by bin(timestamp, 1h)
| render timechart

// API performance
requests
| where name startswith "GET /api/"
| summarize 
    Count = count(),
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95)
    by name
| order by Count desc

// Error tracking
exceptions
| where timestamp > ago(24h)
| summarize Count = count() by type, outerMessage
| order by Count desc
```

### 2. Front Door Diagnostics

```kusto
// Cache hit ratio
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN"
| where Category == "FrontDoorAccessLog"
| summarize 
    TotalRequests = count(),
    CacheHits = countif(cacheStatus_s == "HIT"),
    CacheMisses = countif(cacheStatus_s == "MISS")
| extend HitRatio = (CacheHits * 100.0) / TotalRequests

// WAF blocked requests
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN"
| where Category == "FrontDoorWebApplicationFirewallLog"
| where action_s == "Block"
| summarize Count = count() by ruleName_s
| order by Count desc
```

## Testing Strategy

### 1. Unit Tests

```javascript
// src/hooks/__tests__/useAuth.test.js
import { renderHook, waitFor } from '@testing-library/react';
import { useAuth } from '../useAuth';

global.fetch = jest.fn();

test('useAuth fetches user on mount', async () => {
  fetch.mockResolvedValueOnce({
    ok: true,
    json: async () => ({ 
      clientPrincipal: { 
        userId: '123', 
        userDetails: 'testuser' 
      } 
    })
  });

  const { result } = renderHook(() => useAuth());

  expect(result.current.loading).toBe(true);

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.user.userId).toBe('123');
});
```

### 2. Integration Tests

```javascript
// src/integration/__tests__/api.test.js
describe('API Integration', () => {
  test('products endpoint returns data', async () => {
    const response = await fetch('/api/products');
    expect(response.status).toBe(200);
    
    const data = await response.json();
    expect(data.products).toBeInstanceOf(Array);
    expect(data.products.length).toBeGreaterThan(0);
  });

  test('authenticated endpoint requires auth', async () => {
    const response = await fetch('/api/user');
    expect(response.status).toBe(401);
  });
});
```

### 3. End-to-End Tests

```javascript
// e2e/auth.spec.js (Playwright)
import { test, expect } from '@playwright/test';

test('user can login with GitHub', async ({ page }) => {
  await page.goto('/');
  
  await page.click('text=Login');
  await page.click('text=Login with GitHub');
  
  // Complete OAuth flow (mocked in test environment)
  
  await expect(page.locator('text=Welcome')).toBeVisible();
  await expect(page.locator('[data-testid="user-menu"]')).toBeVisible();
});
```

---

## Complete Deployment Checklist

### Pre-Deployment

- [ ] Install Static Web Apps CLI: `npm install -g @azure/static-web-apps-cli`
- [ ] Initialize SWA config: `npx swa init --yes`
- [ ] Verify `appLocation` and `outputLocation` are different
- [ ] Configure environment variables in Azure Portal
- [ ] Set up Application Insights
- [ ] Configure authentication providers
- [ ] Define user roles and permissions
- [ ] Create `staticwebapp.config.json` with routing rules
- [ ] Implement error handling and boundaries
- [ ] Add security headers
- [ ] Configure CSP policy

### Deployment

- [ ] Build application: `npx swa build`
- [ ] Test locally: `npx swa start`
- [ ] Deploy to staging: `npx swa deploy --env staging`
- [ ] Run smoke tests on staging
- [ ] Deploy to production: `npx swa deploy --env production`
- [ ] Verify deployment URL returned by CLI

### Post-Deployment

- [ ] Configure custom domain
- [ ] Set up Front Door (if needed)
- [ ] Enable WAF policies
- [ ] Configure caching rules
- [ ] Set up health probes
- [ ] Configure monitoring alerts
- [ ] Test from multiple regions
- [ ] Verify SSL certificates
- [ ] Check Application Insights data
- [ ] Monitor error rates
- [ ] Validate cache hit ratio

### Production Monitoring

- [ ] Set up Log Analytics workspace
- [ ] Create monitoring dashboard
- [ ] Configure availability tests
- [ ] Set up cost alerts
- [ ] Review security recommendations
- [ ] Monitor WAF logs
- [ ] Track performance metrics
- [ ] Review user analytics

---

## Quick Reference Commands

```bash
# Static Web Apps CLI
npm install -g @azure/static-web-apps-cli
swa init
swa login
swa build
swa start [dev-server-uri] --api-location [api]
swa deploy --env [environment]

# Azure CLI - Static Web Apps
az staticwebapp list
az staticwebapp show --name <name> --resource-group <rg>
az staticwebapp create --name <name> --resource-group <rg> --source <repo-url>
az staticwebapp environment list --name <name> --resource-group <rg>
az staticwebapp hostname set --name <name> --hostname <domain>
az staticwebapp secrets list --name <name> --resource-group <rg>

# Azure CLI - Front Door
az afd profile list
az afd endpoint list --profile-name <profile> --resource-group <rg>
az afd route list --profile-name <profile> --endpoint-name <endpoint> --resource-group <rg>
az afd endpoint purge --profile-name <profile> --endpoint-name <endpoint> --content-paths '/*' --resource-group <rg>
az afd waf-policy list --resource-group <rg>

# Monitor logs
az monitor log-analytics query -w <workspace-id> --analytics-query "AzureDiagnostics | where ResourceProvider == 'MICROSOFT.CDN'"
```

---

## Additional Resources

### Official Documentation
- [Azure Static Web Apps Documentation](https://learn.microsoft.com/azure/static-web-apps/)
- [Azure Front Door Documentation](https://learn.microsoft.com/azure/frontdoor/)
- [Static Web Apps CLI](https://azure.github.io/static-web-apps-cli/)

### Sample Repositories
- [React + Azure SWA Examples](https://github.com/Azure-Samples/azure-static-web-apps-samples)
- [Front Door + WAF Samples](https://github.com/Azure-Samples/azure-frontdoor-samples)

### Learning Paths
- Microsoft Learn: Azure Static Web Apps
- Microsoft Learn: Azure Front Door
- GitHub Learning Lab: Deploy to Azure Static Web Apps

---

**Document Version**: 1.0  
**Last Updated**: March 2026  
**Maintained By**: Architecture Team
