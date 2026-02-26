# Azure Container Apps - Complete End-to-End Guide

## Table of Contents
1. [Mental Model & Core Concepts](#mental-model--core-concepts)
2. [Architecture Overview](#architecture-overview)
3. [Key Features & Capabilities](#key-features--capabilities)
4. [Container Apps vs Other Azure Services](#container-apps-vs-other-azure-services)
5. [Getting Started - Prerequisites](#getting-started---prerequisites)
6. [Environment Setup](#environment-setup)
7. [Building Containerized .NET APIs](#building-containerized-net-apis)
8. [Deploying to Azure Container Apps](#deploying-to-azure-container-apps)
9. [Configuration Management](#configuration-management)
10. [Networking & Ingress](#networking--ingress)
11. [Scaling Strategies](#scaling-strategies)
12. [Revisions & Traffic Management](#revisions--traffic-management)
13. [Service-to-Service Communication](#service-to-service-communication)
14. [Secrets & Managed Identity](#secrets--managed-identity)
15. [Monitoring & Observability](#monitoring--observability)
16. [Continuous Deployment](#continuous-deployment)
17. [Advanced Scenarios](#advanced-scenarios)
18. [Best Practices](#best-practices)
19. [Troubleshooting](#troubleshooting)
20. [Cost Optimization](#cost-optimization)

---

## Mental Model & Core Concepts

### 🧠 The Big Picture

Think of **Azure Container Apps** as a **managed Kubernetes-like platform** without the complexity. It's designed for running containerized microservices and event-driven applications.

```
┌─────────────────────────────────────────────────────────────┐
│                    AZURE CONTAINER APPS                      │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         Container Apps Environment                  │    │
│  │  (Your Virtual Network Boundary)                   │    │
│  │                                                     │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │    │
│  │  │ Container    │  │ Container    │  │ Shared  │ │    │
│  │  │ App 1        │  │ App 2        │  │ Resources│ │    │
│  │  │ (SimpleApi1) │  │ (SimpleApi2) │  │ - Logs  │ │    │
│  │  │              │  │              │  │ - VNet  │ │    │
│  │  │ Revisions:   │  │ Revisions:   │  │ - DNS   │ │    │
│  │  │ - v1 (50%)   │  │ - v1 (100%)  │  └─────────┘ │    │
│  │  │ - v2 (50%)   │  └──────────────┘              │    │
│  │  └──────────────┘                                 │    │
│  │                                                     │    │
│  │  Ingress ──> Load Balancer ──> Containers         │    │
│  │  Scaling: 0-30 instances (dynamic)                │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  Built on: KEDA + Envoy + Kubernetes (fully managed)       │
└─────────────────────────────────────────────────────────────┘
```

### 🔑 Core Concepts

#### 1. **Container Apps Environment**
- **What**: A secure boundary that hosts one or more container apps
- **Mental Model**: Think of it as a "shared apartment building" where each container app is an apartment
- **Shared Resources**:
  - Virtual Network (VNet)
  - Log Analytics workspace
  - DNS configuration
  - Dapr components (if using Dapr)

#### 2. **Container App**
- **What**: Your actual application running in containers
- **Mental Model**: Like a deployment in Kubernetes, but simpler
- **Key Properties**:
  - Image source (Docker registry)
  - CPU/Memory allocations
  - Scaling rules
  - Ingress configuration

#### 3. **Revisions**
- **What**: Immutable snapshots of your container app configuration
- **Mental Model**: Like Git commits - each change creates a new revision
- **Use Cases**:
  - Blue-Green deployments
  - A/B testing
  - Canary releases
  - Quick rollbacks

#### 4. **Replicas**
- **What**: Running instances of a specific revision
- **Mental Model**: Horizontal scaling - more replicas = more capacity
- **Range**: 0 to 30 replicas (can scale to zero!)

---

## Architecture Overview

### High-Level Architecture

```
                        INTERNET / PRIVATE NETWORK
                                   │
                                   ▼
                        ┌──────────────────────┐
                        │   Azure Front Door   │ (Optional)
                        │   or App Gateway     │
                        └──────────┬───────────┘
                                   │
                        ┌──────────▼───────────┐
                        │  Container Apps      │
                        │  Environment         │
                        │                      │
                        │  ┌────────────────┐ │
                        │  │  Ingress       │ │
                        │  │  (Envoy Proxy) │ │
                        │  └────────┬───────┘ │
                        │           │         │
                        │  ┌────────▼───────┐ │
                        │  │  Load Balancer │ │
                        │  └────────┬───────┘ │
                        │           │         │
              ┌─────────┼───────────┼─────────┼─────────┐
              │         │           │         │         │
         ┌────▼────┐ ┌─▼────┐ ┌───▼───┐ ┌───▼───┐     │
         │ Replica │ │ Rep  │ │ Rep   │ │ Rep   │     │
         │    1    │ │  2   │ │   3   │ │   4   │     │
         └─────────┘ └──────┘ └───────┘ └───────┘     │
              │                                         │
              │     Container App (e.g., SimpleApi1)   │
              └─────────────────────────────────────────┘
                               │
                    ┌──────────┼──────────┐
                    │          │          │
         ┌──────────▼──┐  ┌───▼───────┐  ┌─▼────────────┐
         │ Azure SQL   │  │ Service   │  │ Storage      │
         │ Database    │  │ Bus       │  │ Account      │
         └─────────────┘  └───────────┘  └──────────────┘
```

### Component Breakdown

#### **Envoy Proxy (Ingress Controller)**
- Handles HTTP/HTTPS traffic routing
- SSL/TLS termination
- Load balancing across replicas
- Built-in retry and circuit breaker patterns

#### **KEDA (Kubernetes Event-Driven Autoscaling)**
- Scales your app based on:
  - HTTP traffic
  - Queue depth (Service Bus, Storage Queue)
  - Custom metrics
  - Schedule (cron-based scaling)

#### **Dapr (Distributed Application Runtime)** - Optional
- Service-to-service communication
- State management
- Pub/sub messaging
- Bindings to external systems

---

## Key Features & Capabilities

### ⚡ Auto-Scaling (Scale-to-Zero)

```yaml
# Can scale down to 0 replicas when idle
# Saves costs significantly!
minReplicas: 0
maxReplicas: 30

# Scale triggers:
- HTTP concurrent requests
- CPU/Memory usage
- Queue length
- Custom metrics (via KEDA scalers)
```

**Mental Model**: Like a lambda function, but with containers. Pay only when your app is actively serving requests.

### 🔄 Built-in Load Balancing

- **Automatic**: No need to configure load balancers manually
- **Smart Routing**: Routes traffic across healthy replicas
- **Session Affinity**: Optional sticky sessions

### 🚀 Zero-Downtime Deployments

```
Old Revision (v1)  ────▶ 100% traffic
                         
Deploy new revision...

Old Revision (v1)  ────▶ 70% traffic  ┐ Blue-Green
New Revision (v2)  ────▶ 30% traffic  ┘ Canary Testing

After validation...

New Revision (v2)  ────▶ 100% traffic
Old Revision (v1)  ────▶ Deactivated (kept for rollback)
```

### 🌐 Ingress Configuration

- **External Ingress**: Public internet access
- **Internal Ingress**: VNet-only access (private)
- **No Ingress**: Background jobs, queue processors

### 🔐 Security Features

- **Managed Identity**: No hard-coded credentials
- **Secrets Management**: Integrated with Azure Key Vault
- **Network Isolation**: VNet integration
- **HTTPS by Default**: Automatic SSL certificates

---

## Container Apps vs Other Azure Services

| Feature | Container Apps | App Service | AKS | Container Instances |
|---------|---------------|-------------|-----|---------------------|
| **Complexity** | Low | Low | High | Very Low |
| **Kubernetes** | Managed (hidden) | No | Full Control | No |
| **Scale to Zero** | ✅ Yes | ❌ No | ⚠️ Manual | N/A (per-second billing) |
| **Microservices** | ✅ Excellent | ⚠️ Limited | ✅ Excellent | ❌ Single container |
| **Event-Driven** | ✅ Built-in (KEDA) | ⚠️ Limited | ⚠️ Manual setup | ❌ No |
| **Dapr Support** | ✅ Native | ❌ No | ⚠️ Manual install | ❌ No |
| **Cost (Low Traffic)** | Very Low | Medium | High | Low |
| **Multi-Container** | ✅ Yes | ⚠️ Limited | ✅ Yes | ❌ Single pod |
| **Revisions** | ✅ Built-in | ⚠️ Slots | Manual | N/A |

### When to Use Container Apps

✅ **Perfect For:**
- Microservices architectures
- Event-driven applications
- APIs with variable traffic
- Background job processors
- Serverless containers
- Multi-container applications

❌ **Not Ideal For:**
- Windows containers (Linux only)
- Stateful applications (without external state store)
- Applications requiring persistent storage
- Complex Kubernetes customizations

---

## Getting Started - Prerequisites

### Required Tools

```bash
# 1. Azure CLI (version 2.53.0 or later)
az --version

# 2. Install Container Apps extension
az extension add --name containerapp --upgrade

# 3. Docker Desktop (for building images)
docker --version

# 4. .NET SDK 10.0 (for our sample APIs)
dotnet --version

# 5. Azure subscription
az login
az account show
```

### Register Required Providers

```bash
# Register the Microsoft.App namespace (Container Apps)
az provider register --namespace Microsoft.App

# Register the operational insights provider (for Log Analytics)
az provider register --namespace Microsoft.OperationalInsights

# Verify registration
az provider show -n Microsoft.App --query "registrationState"
az provider show -n Microsoft.OperationalInsights --query "registrationState"
```

---

## Environment Setup

### Create Resource Group

```bash
# Define variables for reusability
RESOURCE_GROUP="rg-containerapp-demo"
LOCATION="eastus"
ENVIRONMENT="env-containerapp-demo"
LOG_ANALYTICS_WORKSPACE="law-containerapp-demo"

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

**Why Resource Groups?** Logical container for all related resources. Easy cleanup by deleting the entire group.

### Create Log Analytics Workspace

```bash
# Container Apps sends logs and metrics here
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE \
  --location $LOCATION

# Get workspace credentials (needed for Container Apps Environment)
LOG_ANALYTICS_WORKSPACE_CLIENT_ID=$(az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE \
  --query customerId \
  --output tsv)

LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=$(az monitor log-analytics workspace get-shared-keys \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE \
  --query primarySharedKey \
  --output tsv)
```

**Mental Model**: Log Analytics is the "black box recorder" for your containers - stores all logs, metrics, and events.

### Create Container Apps Environment

```bash
# The environment is the "virtual boundary" for your apps
az containerapp env create \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET

# Verify environment creation
az containerapp env show \
  --name $ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --output table
```

**What Happens Behind the Scenes:**
1. Azure creates a managed VNet (or uses your custom VNet)
2. Deploys Envoy proxies for ingress
3. Sets up KEDA for autoscaling
4. Configures DNS and load balancing

---

## Building Containerized .NET APIs

### Understanding Our Sample APIs

We have two identical .NET 10 minimal APIs with these endpoints:

```csharp
// ===================================================================
// ENDPOINT 1: Health Check
// Purpose: Kubernetes-style liveness/readiness probe
// Used by Container Apps to determine if replica is healthy
// ===================================================================
app.MapGet("/health", () => 
    Results.Ok(new { 
        status = "healthy", 
        timestamp = DateTime.UtcNow 
    }))
   .WithName("Health");

// ===================================================================
// ENDPOINT 2: Hello with optional name parameter
// Purpose: Simple greeting endpoint to demonstrate routing
// ===================================================================
app.MapGet("/hello/{name?}", (string? name) =>
    Results.Ok(new { 
        message = $"Hello, {name ?? "World"}!", 
        from = "SimpleApi" 
    }))
   .WithName("Hello");

// ===================================================================
// ENDPOINT 3: Environment Info
// Purpose: Shows container-specific information
// Useful for demonstrating:
//   - Multiple replicas (different machine names)
//   - Environment variables
//   - Container metadata
// ===================================================================
app.MapGet("/info", () => Results.Ok(new
{
    machineName   = Environment.MachineName,      // Unique per replica
    osVersion     = Environment.OSVersion.VersionString,
    dotnetVersion = Environment.Version.ToString(),
    environment   = app.Environment.EnvironmentName  // Development/Production
}))
.WithName("Info");

// ===================================================================
// ENDPOINT 4: Weather Forecast (demo endpoint)
// Purpose: Return random weather data
// ===================================================================
app.MapGet("/weatherforecast", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast(
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        )).ToArray();
    return forecast;
})
.WithName("GetWeatherForecast");
```

### Dockerfile Explained

```dockerfile
# ═══════════════════════════════════════════════════════════════════
# STAGE 1: BUILD
# Purpose: Compile the .NET application
# Base image: SDK (contains compiler, NuGet, build tools)
# ═══════════════════════════════════════════════════════════════════
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# ───────────────────────────────────────────────────────────────────
# Copy ONLY .csproj first for layer caching optimization
# Why? Docker caches layers. If .csproj doesn't change, 
#      dependencies won't be re-downloaded
# ───────────────────────────────────────────────────────────────────
COPY SimpleApi.csproj .
RUN dotnet restore

# ───────────────────────────────────────────────────────────────────
# Now copy all source code and build
# ───────────────────────────────────────────────────────────────────
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore
# Output: /app/publish contains compiled DLLs, dependencies, config

# ═══════════════════════════════════════════════════════════════════
# STAGE 2: RUNTIME
# Purpose: Create minimal runtime image (no SDK, only ASP.NET runtime)
# Why? Smaller image size = faster deployments, less attack surface
# ═══════════════════════════════════════════════════════════════════
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# ───────────────────────────────────────────────────────────────────
# Container Apps uses reverse proxy (Envoy)
# So we expose port 80 (HTTP) - HTTPS handled at ingress level
# ───────────────────────────────────────────────────────────────────
ENV ASPNETCORE_HTTP_PORTS=80

# Copy compiled artifacts from build stage
COPY --from=build /app/publish .

# Expose port 80 to Container Apps
EXPOSE 80

# ───────────────────────────────────────────────────────────────────
# Entry point: Run the application
# Container Apps will execute this command when starting a replica
# ───────────────────────────────────────────────────────────────────
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
```

### Building and Pushing Images

#### Option 1: Azure Container Registry (ACR)

```bash
# ═══════════════════════════════════════════════════════════════════
# Step 1: Create Azure Container Registry
# ═══════════════════════════════════════════════════════════════════
ACR_NAME="acrdemocontainerapps"  # Must be globally unique, lowercase

az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# ───────────────────────────────────────────────────────────────────
# Why admin-enabled? 
# - Simplifies authentication for demo
# - Production: Use Managed Identity instead
# ───────────────────────────────────────────────────────────────────

# ═══════════════════════════════════════════════════════════════════
# Step 2: Login to ACR
# ═══════════════════════════════════════════════════════════════════
az acr login --name $ACR_NAME

# ═══════════════════════════════════════════════════════════════════
# Step 3: Build and push SimpleApi1
# ═══════════════════════════════════════════════════════════════════
cd SimpleApi1

# Build image locally
docker build -t simpleapi1:latest .

# Tag for ACR
docker tag simpleapi1:latest $ACR_NAME.azurecr.io/simpleapi1:v1

# Push to ACR
docker push $ACR_NAME.azurecr.io/simpleapi1:v1

# ═══════════════════════════════════════════════════════════════════
# Step 4: Build and push SimpleApi2
# ═══════════════════════════════════════════════════════════════════
cd ../SimpleApi2

docker build -t simpleapi2:latest .
docker tag simpleapi2:latest $ACR_NAME.azurecr.io/simpleapi2:v1
docker push $ACR_NAME.azurecr.io/simpleapi2:v1

cd ..
```

#### Option 2: ACR Build (Cloud Build)

```bash
# ═══════════════════════════════════════════════════════════════════
# Build directly in Azure (no local Docker needed!)
# Useful for CI/CD pipelines
# ═══════════════════════════════════════════════════════════════════

# Build SimpleApi1 in the cloud
az acr build \
  --registry $ACR_NAME \
  --image simpleapi1:v1 \
  --file SimpleApi1/Dockerfile \
  SimpleApi1/

# Build SimpleApi2 in the cloud
az acr build \
  --registry $ACR_NAME \
  --image simpleapi2:v1 \
  --file SimpleApi2/Dockerfile \
  SimpleApi2/
```

**Mental Model**: ACR is like Docker Hub, but private and integrated with Azure. Images stored here are close to your Container Apps (same region).

---

## Deploying to Azure Container Apps

### Deploy SimpleApi1 (External Ingress)

```bash
# ═══════════════════════════════════════════════════════════════════
# Create Container App with EXTERNAL ingress
# This will be publicly accessible on the internet
# ═══════════════════════════════════════════════════════════════════

CONTAINERAPPS_NAME_1="simpleapi1-app"

az containerapp create \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/simpleapi1:v1 \
  --target-port 80 \
  --ingress 'external' \
  --registry-server $ACR_NAME.azurecr.io \
  --registry-username $(az acr credential show --name $ACR_NAME --query username -o tsv) \
  --registry-password $(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv) \
  --cpu 0.25 \
  --memory 0.5Gi \
  --min-replicas 1 \
  --max-replicas 5 \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

**Parameter Breakdown**:

| Parameter | Value | Explanation |
|-----------|-------|-------------|
| `--name` | simpleapi1-app | Name of your container app |
| `--environment` | env-containerapp-demo | Environment created earlier |
| `--image` | acr.../simpleapi1:v1 | Docker image from ACR |
| `--target-port` | 80 | Port your container listens on |
| `--ingress` | external | Public internet access |
| `--cpu` | 0.25 | 0.25 vCPU per replica |
| `--memory` | 0.5Gi | 512 MB RAM per replica |
| `--min-replicas` | 1 | Always have at least 1 replica running |
| `--max-replicas` | 5 | Scale up to 5 replicas under load |

### Deploy SimpleApi2 (Internal Ingress)

```bash
# ═══════════════════════════════════════════════════════════════════
# Create Container App with INTERNAL ingress
# Only accessible from within the Container Apps Environment
# Perfect for microservices that shouldn't be exposed publicly
# ═══════════════════════════════════════════════════════════════════

CONTAINERAPPS_NAME_2="simpleapi2-app"

az containerapp create \
  --name $CONTAINERAPPS_NAME_2 \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/simpleapi2:v1 \
  --target-port 80 \
  --ingress 'internal' \
  --registry-server $ACR_NAME.azurecr.io \
  --registry-username $(az acr credential show --name $ACR_NAME --query username -o tsv) \
  --registry-password $(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv) \
  --cpu 0.5 \
  --memory 1.0Gi \
  --min-replicas 0 \
  --max-replicas 10 \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

**Key Difference**: Notice `--min-replicas 0` - this app can scale to zero when idle!

### Get App URLs

```bash
# ═══════════════════════════════════════════════════════════════════
# Retrieve the fully qualified domain names (FQDNs)
# ═══════════════════════════════════════════════════════════════════

API1_URL=$(az containerapp show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

echo "SimpleApi1 URL: https://$API1_URL"
echo "Health check: https://$API1_URL/health"
echo "Hello endpoint: https://$API1_URL/hello/Azure"
echo "Info endpoint: https://$API1_URL/info"
```

### Test Your Deployment

```bash
# ═══════════════════════════════════════════════════════════════════
# Test endpoints using curl
# ═══════════════════════════════════════════════════════════════════

# Health check
curl https://$API1_URL/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "2026-02-26T10:30:00Z"
# }

# Hello endpoint
curl https://$API1_URL/hello/ContainerApps

# Expected response:
# {
#   "message": "Hello, ContainerApps!",
#   "from": "SimpleApi"
# }

# Info endpoint (reveals replica details)
curl https://$API1_URL/info

# Expected response:
# {
#   "machineName": "simpleapi1-app--abc123-xyz789",
#   "osVersion": "Linux 5.15.0",
#   "dotnetVersion": "10.0.0",
#   "environment": "Production"
# }
```

---

## Configuration Management

### Environment Variables

Environment variables are the primary way to configure containerized applications.

```bash
# ═══════════════════════════════════════════════════════════════════
# Add environment variables to existing container app
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars \
    "ASPNETCORE_ENVIRONMENT=Production" \
    "AppSettings__ApiVersion=1.0" \
    "AppSettings__EnableSwagger=true"
```

**In Your .NET Code**:

```csharp
// ═══════════════════════════════════════════════════════════════════
// Access environment variables in Program.cs
// ═══════════════════════════════════════════════════════════════════

var builder = WebApplication.CreateBuilder(args);

// Environment variables automatically loaded into configuration
var apiVersion = builder.Configuration["AppSettings:ApiVersion"];
var enableSwagger = builder.Configuration.GetValue<bool>("AppSettings:EnableSwagger");

// Or via Environment class
var aspNetEnv = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");

app.MapGet("/config", () => Results.Ok(new
{
    apiVersion,
    enableSwagger,
    environment = aspNetEnv
}));
```

### Configuration Files (appsettings.json)

Container Apps can use mounted volumes for configuration files, but environment variables are preferred for:
- Security (no files to accidentally expose)
- Dynamic updates
- Integration with Key Vault

**Enhanced appsettings.json**:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "AppSettings": {
    "ApiName": "SimpleApi1",
    "ApiVersion": "1.0.0",
    "Features": {
      "EnableCaching": true,
      "EnableDetailedErrors": false
    }
  },
  "ConnectionStrings": {
    // Never store actual connection strings here in production!
    // Use environment variables or Key Vault
    "Database": "OVERRIDE_WITH_ENV_VAR"
  }
}
```

---

## Networking & Ingress

### Ingress Configuration Types

#### 1. External Ingress (Public Internet)

```bash
# ═══════════════════════════════════════════════════════════════════
# Public-facing API accessible from anywhere
# Gets a public FQDN: <app-name>.<unique-id>.<region>.azurecontainerapps.io
# ═══════════════════════════════════════════════════════════════════

az containerapp ingress enable \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --type external \
  --target-port 80 \
  --transport http \
  --allow-insecure false  # Force HTTPS
```

**Use Case**: Public APIs, webhooks, customer-facing applications

#### 2. Internal Ingress (VNet Only)

```bash
# ═══════════════════════════════════════════════════════════════════
# Private API accessible only within the VNet
# Gets an internal FQDN: <app-name>.internal.<unique-id>.<region>.azurecontainerapps.io
# ═══════════════════════════════════════════════════════════════════

az containerapp ingress enable \
  --name $CONTAINERAPPS_NAME_2 \
  --resource-group $RESOURCE_GROUP \
  --type internal \
  --target-port 80 \
  --transport http
```

**Use Case**: Backend services, databases, internal microservices

**Mental Model**:
```
┌──────────────────────────────────────────────────────┐
│                    INTERNET                          │
│                       │                              │
│                       ▼                              │
│              ┌─────────────────┐                     │
│              │ External Ingress│                     │
│              │  (SimpleApi1)   │                     │
│              └────────┬────────┘                     │
│                       │                              │
│                       │ VNet                         │
│                       │                              │
│                       ▼                              │
│              ┌─────────────────┐                     │
│              │ Internal Ingress│                     │
│              │  (SimpleApi2)   │                     │
│              └─────────────────┘                     │
│                       │                              │
│                       ▼                              │
│              ┌─────────────────┐                     │
│              │  Azure SQL DB   │                     │
│              └─────────────────┘                     │
└──────────────────────────────────────────────────────┘
```

#### 3. No Ingress (Background Jobs)

```bash
# ═══════════════════════════════════════════════════════════════════
# Background job processor (e.g., queue consumer)
# No HTTP endpoints exposed
# ═══════════════════════════════════════════════════════════════════

az containerapp create \
  --name "background-processor" \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image myacr.azurecr.io/processor:latest \
  --cpu 1.0 \
  --memory 2.0Gi \
  --min-replicas 1 \
  --max-replicas 3
  # No --ingress parameter!
```

**Use Case**: Queue processors, scheduled jobs, event handlers

### Custom Domains & SSL

```bash
# ═══════════════════════════════════════════════════════════════════
# Add custom domain to Container App
# Requires: DNS validation
# ═══════════════════════════════════════════════════════════════════

# Step 1: Add custom domain
az containerapp hostname add \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --hostname api.mycompany.com

# Step 2: Get validation details
az containerapp hostname list \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP

# Step 3: Add TXT record to DNS provider
# Name: asuid.api.mycompany.com
# Value: <validation-token>

# Step 4: Bind SSL certificate (managed certificate)
az containerapp hostname bind \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --hostname api.mycompany.com \
  --validation-method CNAME
```

### CORS Configuration

```csharp
// ═══════════════════════════════════════════════════════════════════
// Configure CORS in Program.cs
// Important for frontend apps calling your API
// ═══════════════════════════════════════════════════════════════════

var builder = WebApplication.CreateBuilder(args);

// Add CORS before building the app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
            "https://myfrontend.azurecontainerapps.io",
            "https://www.mycompany.com"
        )
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials();
    });
});

var app = builder.Build();

// Enable CORS middleware
app.UseCors("AllowFrontend");

app.MapGet("/api/data", () => Results.Ok(new { data = "Accessible from frontend" }))
   .RequireCors("AllowFrontend");
```

---

## Scaling Strategies

### HTTP-Based Scaling (Default)

```bash
# ═══════════════════════════════════════════════════════════════════
# Scale based on concurrent HTTP requests per replica
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 1 \
  --max-replicas 10 \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50
```

**How It Works**:
- If average requests/replica > 50, scale up
- If average requests/replica < 50, scale down
- Example: 150 concurrent requests = 3 replicas (150 / 50)

**Mental Model**:
```
Requests: 25  ──▶ 1 replica  (25 < 50)
Requests: 75  ──▶ 2 replicas (75 / 50 = 1.5, round up to 2)
Requests: 300 ──▶ 6 replicas (300 / 50 = 6)
```

### CPU/Memory-Based Scaling

```bash
# ═══════════════════════════════════════════════════════════════════
# Scale based on resource utilization
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --scale-rule-name cpu-rule \
  --scale-rule-type cpu \
  --scale-rule-metadata \
    type=Utilization \
    value=70
```

**Trigger**: Scale up when CPU usage exceeds 70% across all replicas

### Azure Service Bus Queue Scaling

```bash
# ═══════════════════════════════════════════════════════════════════
# Scale based on queue length
# Perfect for background processors
# ═══════════════════════════════════════════════════════════════════

SERVICEBUS_CONNECTION="Endpoint=sb://mybus.servicebus.windows.net/..."

az containerapp create \
  --name "queue-processor" \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image myacr.azurecr.io/processor:latest \
  --min-replicas 0 \
  --max-replicas 30 \
  --scale-rule-name queue-rule \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata \
    queueName=orders \
    messageCount=10 \
    namespace=mybus \
  --scale-rule-auth connection=servicebus-connection
```

**How It Works**:
- Queue has 0 messages = 0 replicas (scaled to zero)
- Queue has 15 messages = 2 replicas (15 / 10 = 1.5, round up)
- Queue has 100 messages = 10 replicas

### Custom Metrics (KEDA Scalers)

Container Apps supports 50+ scalers via KEDA:

| Scaler | Use Case | Example Metric |
|--------|----------|----------------|
| azure-servicebus | Queue/Topic processing | Message count |
| azure-blob | Blob processing | Blob count |
| azure-storage-queue | Queue processing | Queue length |
| cron | Scheduled scaling | Time-based |
| prometheus | Custom metrics | App-specific metrics |
| postgresql | Database scaling | Connection count |
| rabbitmq | Message broker | Queue depth |

**Example: Cron-based scaling (scale up during business hours)**

```bash
# ═══════════════════════════════════════════════════════════════════
# Scale to 5 replicas on weekdays from 9 AM to 5 PM (UTC)
# Scale to 1 replica outside business hours
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --scale-rule-name business-hours \
  --scale-rule-type cron \
  --scale-rule-metadata \
    timezone="America/New_York" \
    start="0 9 * * 1-5" \
    end="0 17 * * 1-5" \
    desiredReplicas=5
```

### Scale to Zero Configuration

```bash
# ═══════════════════════════════════════════════════════════════════
# Enable scale-to-zero for cost savings
# Perfect for dev/test environments
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_2 \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 0 \
  --max-replicas 10
```

**Behavior**:
- After 60 seconds of no traffic, scale to 0
- First request after scale-to-zero: ~2-3 second cold start
- Subsequent requests: Normal latency

**Cost Impact**:
```
Standard App (min-replicas: 1):
  Cost: 24 hours/day × 30 days = 720 hours/month

Scale-to-Zero App (traffic only 8 hours/day):
  Cost: 8 hours/day × 30 days = 240 hours/month
  Savings: 66%!
```

---

## Revisions & Traffic Management

### Understanding Revisions

**Mental Model**: Revisions are like immutable Git commits. Each configuration change creates a new revision.

```
Revision 1 ──▶ Image: v1, CPU: 0.25, Env: PROD
     │
     ├──▶ Deploy new image
     │
Revision 2 ──▶ Image: v2, CPU: 0.25, Env: PROD
     │
     ├──▶ Change CPU allocation
     │
Revision 3 ──▶ Image: v2, CPU: 0.5, Env: PROD
```

### Revision Modes

#### 1. Single Revision Mode (Default)
- Only one revision active at a time
- New deployment deactivates old revision
- Simple but no traffic splitting

#### 2. Multiple Revision Mode
- Multiple revisions active simultaneously
- Enable traffic splitting and blue-green deployments

```bash
# ═══════════════════════════════════════════════════════════════════
# Enable multiple revision mode
# ═══════════════════════════════════════════════════════════════════

az containerapp revision set-mode \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --mode multiple
```

### Blue-Green Deployment

```bash
# ═══════════════════════════════════════════════════════════════════
# STEP 1: Deploy new version (v2) without switching traffic
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --image $ACR_NAME.azurecr.io/simpleapi1:v2 \
  --revision-suffix v2

# At this point:
# - Revision v1: 100% traffic (production)
# - Revision v2: 0% traffic (ready for testing)

# ═══════════════════════════════════════════════════════════════════
# STEP 2: Test the new revision via direct URL
# ═══════════════════════════════════════════════════════════════════

# Get revision-specific URL
REVISION_V2_URL=$(az containerapp revision show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision simpleapi1-app--v2 \
  --query properties.fqdn \
  --output tsv)

# Test v2 revision
curl https://$REVISION_V2_URL/health

# ═══════════════════════════════════════════════════════════════════
# STEP 3: Switch 100% traffic to v2 (cutover)
# ═══════════════════════════════════════════════════════════════════

az containerapp ingress traffic set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision-weight simpleapi1-app--v2=100 simpleapi1-app--v1=0

# ═══════════════════════════════════════════════════════════════════
# STEP 4 (Optional): Rollback if issues detected
# ═══════════════════════════════════════════════════════════════════

az containerapp ingress traffic set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision-weight simpleapi1-app--v1=100 simpleapi1-app--v2=0
```

### Canary Deployment (Gradual Rollout)

```bash
# ═══════════════════════════════════════════════════════════════════
# Gradually shift traffic from v1 to v2
# ═══════════════════════════════════════════════════════════════════

# Step 1: 10% canary
az containerapp ingress traffic set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision-weight simpleapi1-app--v1=90 simpleapi1-app--v2=10

# Monitor metrics for 30 minutes...

# Step 2: 50% canary
az containerapp ingress traffic set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision-weight simpleapi1-app--v1=50 simpleapi1-app--v2=50

# Monitor metrics for 30 minutes...

# Step 3: 100% to v2
az containerapp ingress traffic set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision-weight simpleapi1-app--v2=100
```

**Mental Model**:
```
Time: T0    ──▶ v1: 100%, v2: 0%    (Deploy v2)
Time: T30   ──▶ v1: 90%,  v2: 10%   (Initial canary)
Time: T60   ──▶ v1: 50%,  v2: 50%   (Expand canary)
Time: T90   ──▶ v1: 0%,   v2: 100%  (Full rollout)
```

### A/B Testing

```bash
# ═══════════════════════════════════════════════════════════════════
# Run two versions simultaneously for A/B testing
# 50% users see v1 (old UI), 50% see v2 (new UI)
# ═══════════════════════════════════════════════════════════════════

az containerapp ingress traffic set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision-weight simpleapi1-app--v1=50 simpleapi1-app--v2=50
```

**Use Case**: Compare feature performance, conversion rates, or user experience between two versions.

### Revision Labels

```bash
# ═══════════════════════════════════════════════════════════════════
# Labels provide stable URLs for specific revisions
# Useful for: staging, preview environments, feature branches
# ═══════════════════════════════════════════════════════════════════

# Add 'staging' label to v2 revision
az containerapp revision label add \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --revision simpleapi1-app--v2 \
  --label staging

# Access via label URL: https://simpleapi1-app---staging.<environment>.azurecontainerapps.io
```

---

## Service-to-Service Communication

### Scenario: SimpleApi1 calls SimpleApi2

```csharp
// ═══════════════════════════════════════════════════════════════════
// SimpleApi1/Program.cs - Enhanced with HttpClient
// ═══════════════════════════════════════════════════════════════════

var builder = WebApplication.CreateBuilder(args);

// ───────────────────────────────────────────────────────────────────
// Register HttpClient for calling SimpleApi2
// ───────────────────────────────────────────────────────────────────
builder.Services.AddHttpClient("SimpleApi2", client =>
{
    // SimpleApi2 has INTERNAL ingress, so use its internal FQDN
    var api2BaseUrl = Environment.GetEnvironmentVariable("SIMPLEAPI2_URL") 
                      ?? "https://simpleapi2-app.internal.<env-id>.<region>.azurecontainerapps.io";
    client.BaseAddress = new Uri(api2BaseUrl);
    client.Timeout = TimeSpan.FromSeconds(30);
});

var app = builder.Build();

// ───────────────────────────────────────────────────────────────────
// Endpoint that calls SimpleApi2
// ───────────────────────────────────────────────────────────────────
app.MapGet("/call-api2", async (IHttpClientFactory httpClientFactory) =>
{
    var client = httpClientFactory.CreateClient("SimpleApi2");
    
    try
    {
        // Call SimpleApi2's /info endpoint
        var response = await client.GetAsync("/info");
        response.EnsureSuccessStatusCode();
        
        var content = await response.Content.ReadAsStringAsync();
        
        return Results.Ok(new
        {
            message = "Successfully called SimpleApi2",
            api2Response = content,
            calledFrom = Environment.MachineName
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(
            detail: ex.Message,
            statusCode: 500,
            title: "Error calling SimpleApi2"
        );
    }
})
.WithName("CallApi2");

app.Run();
```

### Configure Environment Variable

```bash
# ═══════════════════════════════════════════════════════════════════
# Set SimpleApi2 URL as environment variable in SimpleApi1
# ═══════════════════════════════════════════════════════════════════

# Get SimpleApi2's internal FQDN
API2_INTERNAL_URL=$(az containerapp show \
  --name $CONTAINERAPPS_NAME_2 \
  --resource-group $RESOURCE_GROUP \
  --query properties.configuration.ingress.fqdn \
  --output tsv)

# Update SimpleApi1 with API2's URL
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "SIMPLEAPI2_URL=https://$API2_INTERNAL_URL"
```

### Using Dapr for Service Discovery

Dapr provides automatic service discovery, retries, and circuit breakers.

```bash
# ═══════════════════════════════════════════════════════════════════
# Enable Dapr for both apps
# ═══════════════════════════════════════════════════════════════════

az containerapp dapr enable \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --dapr-app-id simpleapi1 \
  --dapr-app-port 80

az containerapp dapr enable \
  --name $CONTAINERAPPS_NAME_2 \
  --resource-group $RESOURCE_GROUP \
  --dapr-app-id simpleapi2 \
  --dapr-app-port 80
```

**Enhanced C# Code with Dapr**:

```csharp
// ═══════════════════════════════════════════════════════════════════
// SimpleApi1/Program.cs - Using Dapr for service invocation
// ═══════════════════════════════════════════════════════════════════

var builder = WebApplication.CreateBuilder(args);

// Add Dapr client
builder.Services.AddDaprClient();

var app = builder.Build();

app.MapGet("/call-api2-dapr", async (DaprClient daprClient) =>
{
    try
    {
        // Dapr automatically discovers SimpleApi2 by app-id
        // No need for URLs, DNS, or service discovery!
        var response = await daprClient.InvokeMethodAsync<object>(
            HttpMethod.Get,
            "simpleapi2",  // Dapr app-id of SimpleApi2
            "info"         // Endpoint path
        );
        
        return Results.Ok(new
        {
            message = "Called SimpleApi2 via Dapr",
            api2Response = response
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message);
    }
})
.WithName("CallApi2Dapr");
```

**Benefits of Dapr**:
- ✅ Automatic service discovery (no hardcoded URLs)
- ✅ Built-in retries and circuit breakers
- ✅ mTLS encryption between services
- ✅ Observability (automatic tracing)

---

## Secrets & Managed Identity

### Storing Secrets in Container Apps

```bash
# ═══════════════════════════════════════════════════════════════════
# Add secrets to Container App
# Secrets are encrypted at rest and in transit
# ═══════════════════════════════════════════════════════════════════

az containerapp secret set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --secrets \
    db-connection-string="Server=myserver.database.windows.net;Database=mydb;..." \
    api-key="super-secret-key-12345"

# Reference secrets as environment variables
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars \
    "ConnectionStrings__Database=secretref:db-connection-string" \
    "ApiKey=secretref:api-key"
```

**In Your .NET Code**:

```csharp
// Secrets are automatically available via IConfiguration
var dbConnectionString = builder.Configuration["ConnectionStrings:Database"];
var apiKey = builder.Configuration["ApiKey"];
```

### Azure Key Vault Integration

```bash
# ═══════════════════════════════════════════════════════════════════
# STEP 1: Create Managed Identity for Container App
# ═══════════════════════════════════════════════════════════════════

az containerapp identity assign \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --system-assigned

# Get the identity's principal ID
IDENTITY_ID=$(az containerapp identity show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --query principalId \
  --output tsv)

# ═══════════════════════════════════════════════════════════════════
# STEP 2: Grant Container App access to Key Vault
# ═══════════════════════════════════════════════════════════════════

KEYVAULT_NAME="kv-containerapp-demo"

# Create Key Vault
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Grant access to Container App's managed identity
az keyvault set-policy \
  --name $KEYVAULT_NAME \
  --object-id $IDENTITY_ID \
  --secret-permissions get list

# ═══════════════════════════════════════════════════════════════════
# STEP 3: Store secret in Key Vault
# ═══════════════════════════════════════════════════════════════════

az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name "DbConnectionString" \
  --value "Server=myserver.database.windows.net;Database=mydb;User Id=myuser;Password=..."

# ═══════════════════════════════════════════════════════════════════
# STEP 4: Reference Key Vault secret in Container App
# ═══════════════════════════════════════════════════════════════════

KEYVAULT_SECRET_URL=$(az keyvault secret show \
  --vault-name $KEYVAULT_NAME \
  --name "DbConnectionString" \
  --query id \
  --output tsv)

az containerapp secret set \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --secrets "db-connection=keyvaultref:$KEYVAULT_SECRET_URL,identityref:system"

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "ConnectionStrings__Database=secretref:db-connection"
```

**Mental Model**:
```
Container App ──▶ Managed Identity ──▶ Key Vault ──▶ Secret
     │                                                   │
     └───────────────────────────────────────────────────┘
              (No passwords in code!)
```

### Using Managed Identity with Azure SQL

```csharp
// ═══════════════════════════════════════════════════════════════════
// Connect to Azure SQL using Managed Identity (passwordless!)
// ═══════════════════════════════════════════════════════════════════

using Azure.Identity;
using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);

// Build connection string without password
var sqlConnectionString = new SqlConnectionStringBuilder
{
    DataSource = "myserver.database.windows.net",
    InitialCatalog = "mydb",
    TrustServerCertificate = false,
    Encrypt = true
}.ConnectionString;

var app = builder.Build();

app.MapGet("/query-db", async () =>
{
    try
    {
        // Use Managed Identity to get access token
        var credential = new DefaultAzureCredential();
        var token = await credential.GetTokenAsync(
            new Azure.Core.TokenRequestContext(new[] 
            { 
                "https://database.windows.net/.default" 
            })
        );

        using var connection = new SqlConnection(sqlConnectionString);
        using var cmd = new SqlCommand("SELECT COUNT(*) FROM Users", connection);
        
        // Set access token (instead of username/password)
        connection.AccessToken = token.Token;
        
        await connection.OpenAsync();
        var count = (int)await cmd.ExecuteScalarAsync();
        
        return Results.Ok(new { userCount = count });
    }
    catch (Exception ex)
    {
        return Results.Problem(detail: ex.Message);
    }
});
```

---

## Monitoring & Observability

### Log Analytics Queries

```bash
# ═══════════════════════════════════════════════════════════════════
# View logs in Azure Portal or via CLI
# ═══════════════════════════════════════════════════════════════════

# Stream live logs
az containerapp logs show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --follow

# Query logs via Log Analytics
az monitor log-analytics query \
  --workspace $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --analytics-query "ContainerAppConsoleLogs_CL | where ContainerAppName_s == 'simpleapi1-app' | top 100 by TimeGenerated desc" \
  --output table
```

### Kusto (KQL) Queries

**View All Container Logs**:

```kql
// ═══════════════════════════════════════════════════════════════════
// All console logs from SimpleApi1
// ═══════════════════════════════════════════════════════════════════
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "simpleapi1-app"
| where TimeGenerated > ago(1h)
| project TimeGenerated, Log_s, RevisionName_s
| order by TimeGenerated desc
```

**View System Logs (Scaling Events)**:

```kql
// ═══════════════════════════════════════════════════════════════════
// Scaling events (replicas added/removed)
// ═══════════════════════════════════════════════════════════════════
ContainerAppSystemLogs_CL
| where ContainerAppName_s == "simpleapi1-app"
| where Log_s contains "scale"
| project TimeGenerated, Log_s, Reason_s
| order by TimeGenerated desc
```

**View HTTP Requests**:

```kql
// ═══════════════════════════════════════════════════════════════════
// HTTP request metrics (latency, status codes)
// ═══════════════════════════════════════════════════════════════════
AppRequests
| where AppRoleName == "simpleapi1-app"
| summarize 
    RequestCount = count(),
    AvgDuration = avg(DurationMs),
    P95Duration = percentile(DurationMs, 95)
    by bin(TimeGenerated, 5m), ResultCode
| order by TimeGenerated desc
```

### Application Insights Integration

```bash
# ═══════════════════════════════════════════════════════════════════
# Create Application Insights
# ═══════════════════════════════════════════════════════════════════

APPINSIGHTS_NAME="ai-containerapp-demo"

az monitor app-insights component create \
  --app $APPINSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --workspace $LOG_ANALYTICS_WORKSPACE

# Get instrumentation key
APPINSIGHTS_KEY=$(az monitor app-insights component show \
  --app $APPINSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey \
  --output tsv)

# Add to Container App
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$APPINSIGHTS_KEY"
```

**Add Application Insights SDK to .NET App**:

```xml
<!-- SimpleApi.csproj -->
<ItemGroup>
  <PackageReference Include="Microsoft.ApplicationInsights.AspNetCore" Version="2.21.0" />
</ItemGroup>
```

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add Application Insights telemetry
builder.Services.AddApplicationInsightsTelemetry();

var app = builder.Build();

// Custom telemetry
app.MapGet("/track-event", (TelemetryClient telemetry) =>
{
    telemetry.TrackEvent("CustomEvent", new Dictionary<string, string>
    {
        { "UserId", "user123" },
        { "Action", "ViewedDashboard" }
    });
    
    return Results.Ok("Event tracked");
});
```

### Health Probes

```bash
# ═══════════════════════════════════════════════════════════════════
# Configure health probes (liveness, readiness, startup)
# ═══════════════════════════════════════════════════════════════════

az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --health-probe-liveness-path "/health" \
  --health-probe-liveness-interval 30 \
  --health-probe-liveness-timeout 5 \
  --health-probe-liveness-failure-threshold 3
```

**Probe Types**:

1. **Liveness Probe**: Is the app alive?
   - If fails, restart the replica
   
2. **Readiness Probe**: Is the app ready to serve traffic?
   - If fails, remove from load balancer

3. **Startup Probe**: Has the app finished starting?
   - Useful for slow-starting apps

**Enhanced Health Endpoint**:

```csharp
// ═══════════════════════════════════════════════════════════════════
// Production-ready health check with dependencies
// ═══════════════════════════════════════════════════════════════════

using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

// Add health checks for dependencies
builder.Services.AddHealthChecks()
    .AddCheck("self", () => HealthCheckResult.Healthy())
    .AddSqlServer(
        builder.Configuration["ConnectionStrings:Database"],
        name: "database",
        timeout: TimeSpan.FromSeconds(5))
    .AddUrlGroup(
        new Uri("https://simpleapi2-app.internal.../health"),
        name: "simpleapi2",
        timeout: TimeSpan.FromSeconds(5));

var app = builder.Build();

// Liveness endpoint (just check if app is running)
app.MapGet("/health/live", () => Results.Ok(new { status = "alive" }));

// Readiness endpoint (check dependencies)
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = JsonSerializer.Serialize(new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                duration = e.Value.Duration.TotalMilliseconds
            })
        });
        await context.Response.WriteAsync(result);
    }
});
```

---

## Continuous Deployment

### GitHub Actions Deployment

**.github/workflows/deploy-containerapp.yml**:

```yaml
# ═══════════════════════════════════════════════════════════════════
# GitHub Actions workflow for Container Apps deployment
# ═══════════════════════════════════════════════════════════════════

name: Deploy to Azure Container Apps

on:
  push:
    branches: [ main ]
    paths:
      - 'SimpleApi1/**'
  workflow_dispatch:

env:
  RESOURCE_GROUP: rg-containerapp-demo
  CONTAINERAPP_NAME: simpleapi1-app
  ACR_NAME: acrdemocontainerapps
  IMAGE_NAME: simpleapi1

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
      # ─────────────────────────────────────────────────────────────
      # STEP 1: Checkout code
      # ─────────────────────────────────────────────────────────────
      - name: Checkout code
        uses: actions/checkout@v3
      
      # ─────────────────────────────────────────────────────────────
      # STEP 2: Login to Azure
      # Requires: Service Principal stored in GitHub Secrets
      # ─────────────────────────────────────────────────────────────
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      # ─────────────────────────────────────────────────────────────
      # STEP 3: Build and push Docker image to ACR
      # ─────────────────────────────────────────────────────────────
      - name: Build and push to ACR
        run: |
          # Login to ACR
          az acr login --name ${{ env.ACR_NAME }}
          
          # Build image with Git SHA as tag (for traceability)
          IMAGE_TAG=${{ github.sha }}
          IMAGE_FULL_NAME=${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:$IMAGE_TAG
          
          # Build
          docker build -t $IMAGE_FULL_NAME ./SimpleApi1
          
          # Also tag as 'latest'
          docker tag $IMAGE_FULL_NAME ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:latest
          
          # Push both tags
          docker push $IMAGE_FULL_NAME
          docker push ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:latest
          
          # Output for next step
          echo "IMAGE_FULL_NAME=$IMAGE_FULL_NAME" >> $GITHUB_ENV
      
      # ─────────────────────────────────────────────────────────────
      # STEP 4: Deploy to Container Apps
      # ─────────────────────────────────────────────────────────────
      - name: Deploy to Container Apps
        run: |
          az containerapp update \
            --name ${{ env.CONTAINERAPP_NAME }} \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --image ${{ env.IMAGE_FULL_NAME }} \
            --revision-suffix sha-${{ github.sha }}
      
      # ─────────────────────────────────────────────────────────────
      # STEP 5: Verify deployment
      # ─────────────────────────────────────────────────────────────
      - name: Verify deployment
        run: |
          # Get app URL
          APP_URL=$(az containerapp show \
            --name ${{ env.CONTAINERAPP_NAME }} \
            --resource-group ${{ env.RESOURCE_GROUP }} \
            --query properties.configuration.ingress.fqdn \
            --output tsv)
          
          # Health check
          curl --fail https://$APP_URL/health || exit 1
          
          echo "✅ Deployment successful: https://$APP_URL"
```

### Create Azure Service Principal for GitHub

```bash
# ═══════════════════════════════════════════════════════════════════
# Create service principal for GitHub Actions
# ═══════════════════════════════════════════════════════════════════

SUBSCRIPTION_ID=$(az account show --query id --output tsv)

az ad sp create-for-rbac \
  --name "sp-github-containerapp" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth

# Copy the JSON output and store in GitHub Secrets as:
# Name: AZURE_CREDENTIALS
# Value: { "clientId": "...", "clientSecret": "...", ... }
```

### Azure DevOps Pipeline

**azure-pipelines.yml**:

```yaml
# ═══════════════════════════════════════════════════════════════════
# Azure DevOps pipeline for Container Apps
# ═══════════════════════════════════════════════════════════════════

trigger:
  branches:
    include:
      - main
  paths:
    include:
      - SimpleApi1/*

variables:
  resourceGroup: 'rg-containerapp-demo'
  containerAppName: 'simpleapi1-app'
  acrName: 'acrdemocontainerapps'
  imageName: 'simpleapi1'

stages:
  - stage: Build
    jobs:
      - job: BuildAndPush
        pool:
          vmImage: 'ubuntu-latest'
        
        steps:
          # Build Docker image using ACR
          - task: AzureCLI@2
            displayName: 'Build and push to ACR'
            inputs:
              azureSubscription: 'Azure-ServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                IMAGE_TAG=$(Build.BuildId)
                
                az acr build \
                  --registry $(acrName) \
                  --image $(imageName):$IMAGE_TAG \
                  --image $(imageName):latest \
                  --file SimpleApi1/Dockerfile \
                  SimpleApi1/

  - stage: Deploy
    dependsOn: Build
    jobs:
      - deployment: DeployToContainerApps
        environment: 'Production'
        pool:
          vmImage: 'ubuntu-latest'
        
        strategy:
          runOnce:
            deploy:
              steps:
                - task: AzureCLI@2
                  displayName: 'Deploy to Container Apps'
                  inputs:
                    azureSubscription: 'Azure-ServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      IMAGE_TAG=$(Build.BuildId)
                      
                      az containerapp update \
                        --name $(containerAppName) \
                        --resource-group $(resourceGroup) \
                        --image $(acrName).azurecr.io/$(imageName):$IMAGE_TAG \
                        --revision-suffix build-$IMAGE_TAG
                
                - task: AzureCLI@2
                  displayName: 'Health check'
                  inputs:
                    azureSubscription: 'Azure-ServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      APP_URL=$(az containerapp show \
                        --name $(containerAppName) \
                        --resource-group $(resourceGroup) \
                        --query properties.configuration.ingress.fqdn \
                        --output tsv)
                      
                      curl --fail https://$APP_URL/health
```

---

## Advanced Scenarios

### Multi-Container Applications (Sidecar Pattern)

```yaml
# ═══════════════════════════════════════════════════════════════════
# YAML template for multi-container app
# Main container + sidecar (e.g., logging agent, proxy)
# ═══════════════════════════════════════════════════════════════════

properties:
  template:
    containers:
      # Main application container
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v1
        resources:
          cpu: 0.5
          memory: 1.0Gi
        env:
          - name: ASPNETCORE_ENVIRONMENT
            value: Production
      
      # Sidecar container (e.g., Fluent Bit for log forwarding)
      - name: log-forwarder
        image: fluent/fluent-bit:latest
        resources:
          cpu: 0.25
          memory: 0.5Gi
        volumeMounts:
          - name: shared-logs
            mountPath: /var/log
    
    volumes:
      - name: shared-logs
        emptyDir: {}
```

**Deploy Multi-Container App**:

```bash
az containerapp create \
  --name multi-container-app \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --yaml multi-container.yaml
```

### Init Containers

```yaml
# ═══════════════════════════════════════════════════════════════════
# Init containers run before main container starts
# Use cases: Database migrations, pre-warming cache, downloading config
# ═══════════════════════════════════════════════════════════════════

properties:
  template:
    initContainers:
      # Run database migrations before starting API
      - name: db-migrator
        image: acrdemo.azurecr.io/db-migrator:latest
        env:
          - name: ConnectionString
            secretRef: db-connection-string
    
    containers:
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v1
        # ... rest of config
```

### Jobs (One-Time or Scheduled Tasks)

```bash
# ═══════════════════════════════════════════════════════════════════
# Create a job that runs on schedule or manually triggered
# Use cases: Data processing, ETL, cleanup tasks
# ═══════════════════════════════════════════════════════════════════

az containerapp job create \
  --name "nightly-report-job" \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --trigger-type "Schedule" \
  --cron-expression "0 2 * * *" \
  --image acrdemo.azurecr.io/report-generator:latest \
  --cpu 1.0 \
  --memory 2.0Gi \
  --replica-timeout 3600 \
  --replica-retry-limit 2

# Manually trigger a job execution
az containerapp job start \
  --name "nightly-report-job" \
  --resource-group $RESOURCE_GROUP
```

### gRPC Support

```bash
# ═══════════════════════════════════════════════════════════════════
# Configure Container Apps for gRPC
# ═══════════════════════════════════════════════════════════════════

az containerapp create \
  --name grpc-service \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image acrdemo.azurecr.io/grpc-service:latest \
  --target-port 5000 \
  --ingress external \
  --transport http2  # Important for gRPC!
```

**gRPC .NET Service Example**:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Add gRPC services
builder.Services.AddGrpc();

var app = builder.Build();

// Map gRPC services
app.MapGrpcService<GreeterService>();

app.Run();

// Services/GreeterService.cs
public class GreeterService : Greeter.GreeterBase
{
    public override Task<HelloReply> SayHello(HelloRequest request, ServerCallContext context)
    {
        return Task.FromResult(new HelloReply
        {
            Message = $"Hello {request.Name} from Container Apps!"
        });
    }
}
```

### WebSocket Support

```bash
# ═══════════════════════════════════════════════════════════════════
# WebSockets work out of the box with Container Apps
# No special configuration needed (uses HTTP/1.1 upgrade)
# ═══════════════════════════════════════════════════════════════════

az containerapp create \
  --name websocket-app \
  --resource-group $RESOURCE_GROUP \
  --environment $ENVIRONMENT \
  --image acrdemo.azurecr.io/websocket-app:latest \
  --target-port 80 \
  --ingress external
```

---

## Best Practices

### 1. **Container Image Optimization**

```dockerfile
# ❌ BAD: Large image, inefficient caching
FROM mcr.microsoft.com/dotnet/sdk:10.0
COPY . /app
WORKDIR /app
RUN dotnet publish -c Release
ENTRYPOINT ["dotnet", "SimpleApi.dll"]

# ✅ GOOD: Multi-stage build, layer caching
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY *.csproj .
RUN dotnet restore  # Cached if .csproj unchanged
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0  # Smaller runtime image
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
```

**Benefits**:
- Smaller image size (50-70% reduction)
- Faster deployments
- Better layer caching

### 2. **Resource Allocation**

```bash
# ❌ BAD: Over-provisioning (wastes money)
--cpu 2.0 --memory 4.0Gi

# ✅ GOOD: Right-size based on actual usage
--cpu 0.5 --memory 1.0Gi

# Monitor and adjust:
# - Check CPU/Memory metrics in Log Analytics
# - Start small, scale up if needed
```

### 3. **Scaling Configuration**

```bash
# ❌ BAD: Can't scale to zero, expensive
--min-replicas 3 --max-replicas 5

# ✅ GOOD: Scale to zero for dev/test
--min-replicas 0 --max-replicas 10

# ✅ GOOD: Production with buffer
--min-replicas 2 --max-replicas 20
```

### 4. **Health Checks**

```csharp
// ❌ BAD: No health check or too simple
app.MapGet("/health", () => "OK");

// ✅ GOOD: Check dependencies
app.MapHealthChecks("/health", new HealthCheckOptions
{
    Predicate = _ => true,
    ResponseWriter = async (context, report) =>
    {
        // Return detailed status including dependencies
        var result = JsonSerializer.Serialize(new
        {
            status = report.Status.ToString(),
            duration = report.TotalDuration.TotalMilliseconds,
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString()
            })
        });
        await context.Response.WriteAsync(result);
    }
});
```

### 5. **Secrets Management**

```bash
# ❌ BAD: Hardcoded secrets
--set-env-vars "DbPassword=SuperSecret123"

# ✅ GOOD: Use secrets
az containerapp secret set --secrets "db-password=SuperSecret123"
az containerapp update --set-env-vars "DbPassword=secretref:db-password"

# ✅ BETTER: Use Key Vault
az containerapp secret set --secrets "db-password=keyvaultref:<vault-uri>,identityref:system"
```

### 6. **Logging Best Practices**

```csharp
// ✅ GOOD: Structured logging with log levels
app.Logger.LogInformation("Processing request for user {UserId}", userId);
app.Logger.LogWarning("Slow query detected: {Duration}ms", duration);
app.Logger.LogError(ex, "Failed to process order {OrderId}", orderId);

// ❌ BAD: Unstructured logging
Console.WriteLine($"User {userId} logged in");  // Hard to query
```

### 7. **Revision Management**

```bash
# ✅ GOOD: Use descriptive revision suffixes
--revision-suffix "v2-feature-x-$(date +%Y%m%d)"

# ✅ GOOD: Clean up old revisions
az containerapp revision deactivate \
  --name simpleapi1-app \
  --resource-group $RESOURCE_GROUP \
  --revision simpleapi1-app--old-revision
```

### 8. **Network Isolation**

```bash
# ✅ GOOD: Public APIs = external ingress
az containerapp create --ingress external ...

# ✅ GOOD: Internal services = internal ingress
az containerapp create --ingress internal ...

# ✅ GOOD: Background workers = no ingress
az containerapp create (no --ingress parameter)
```

### 9. **Cost Optimization**

- Use scale-to-zero for non-production environments
- Right-size CPU/memory allocations
- Use internal ingress when possible (cheaper)
- Implement efficient scaling rules
- Clean up unused revisions and environments

### 10. **Security Hardening**

```bash
# ✅ Use non-root containers
USER nonroot

# ✅ Enable managed identity
az containerapp identity assign --system-assigned

# ✅ Disable admin credentials on ACR
az acr update --admin-enabled false

# ✅ Use private ACR or restrict access
az acr update --public-network-enabled false
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. **Container Fails to Start**

**Symptoms**:
- Replicas stuck in "Provisioning" state
- Health checks failing

**Diagnosis**:

```bash
# View container logs
az containerapp logs show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --follow

# Check revision status
az containerapp revision list \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --output table
```

**Common Causes**:
- ❌ Wrong port configuration (target-port doesn't match container)
- ❌ Missing environment variables
- ❌ Image pull failures (authentication issues)

**Solution**:

```bash
# Verify port configuration
az containerapp show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.targetPort"

# Update if incorrect
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --target-port 80
```

#### 2. **High Latency or Slow Response Times**

**Diagnosis**:

```kql
// Query Application Insights for slow requests
AppRequests
| where AppRoleName == "simpleapi1-app"
| where DurationMs > 1000  // Requests slower than 1 second
| summarize SlowRequestCount = count() by bin(TimeGenerated, 5m)
| render timechart
```

**Common Causes**:
- ❌ Insufficient replicas (under-scaled)
- ❌ CPU/memory constraints
- ❌ Slow database queries

**Solution**:

```bash
# Increase max replicas
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --max-replicas 15

# Increase resources per replica
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --cpu 1.0 \
  --memory 2.0Gi
```

#### 3. **503 Service Unavailable**

**Common Causes**:
- ❌ All replicas scaled to zero and cold start taking too long
- ❌ Health checks failing
- ❌ Ingress misconfigured

**Solution**:

```bash
# Ensure min-replicas > 0 for production
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 2

# Verify health check endpoint works
curl https://$API1_URL/health
```

#### 4. **Cannot Access Internal App from Another App**

**Diagnosis**:

```bash
# Check ingress type
az containerapp show \
  --name $CONTAINERAPPS_NAME_2 \
  --resource-group $RESOURCE_GROUP \
  --query "properties.configuration.ingress.external"
# Should return "false" for internal apps
```

**Solution**: Ensure both apps are in the same Container Apps Environment:

```bash
# Verify environment
az containerapp show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --query "properties.managedEnvironmentId"
```

#### 5. **Secrets Not Loading**

**Diagnosis**:

```bash
# List secrets
az containerapp secret list \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP

# Check environment variables
az containerapp show \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --query "properties.template.containers[0].env"
```

**Solution**:

```bash
# Verify secret reference syntax
az containerapp update \
  --name $CONTAINERAPPS_NAME_1 \
  --resource-group $RESOURCE_GROUP \
  --set-env-vars "ConnectionString=secretref:db-connection-string"
# Note: 'secretref:' prefix is required
```

---

## Cost Optimization

### Pricing Model

Container Apps uses **consumption-based pricing**:

```
Cost = (vCPU-seconds × CPU rate) + (GiB-seconds × Memory rate) + Requests
```

**Rates (approximate, varies by region)**:
- vCPU: $0.000012 per vCPU-second
- Memory: $0.000002 per GiB-second
- Requests: $0.40 per million requests

### Cost Calculation Examples

#### Scenario 1: Continuous Load (No Scale-to-Zero)

```
Configuration:
- 2 replicas (min-replicas: 2)
- 0.5 vCPU, 1 GiB memory per replica
- Running 24/7 for 30 days

Calculation:
- Total vCPU-seconds: 2 × 0.5 × 2,592,000 seconds = 2,592,000
- Total GiB-seconds: 2 × 1 × 2,592,000 = 5,184,000
- Cost: (2,592,000 × $0.000012) + (5,184,000 × $0.000002)
      = $31.10 + $10.37 = $41.47/month
```

#### Scenario 2: Scale-to-Zero (Development)

```
Configuration:
- 0-5 replicas (min-replicas: 0)
- 0.25 vCPU, 0.5 GiB memory per replica
- Active only 8 hours/day on weekdays (160 hours/month)

Calculation:
- Total vCPU-seconds: 1 × 0.25 × 576,000 seconds = 144,000
- Total GiB-seconds: 1 × 0.5 × 576,000 = 288,000
- Cost: (144,000 × $0.000012) + (288,000 × $0.000002)
      = $1.73 + $0.58 = $2.31/month
```

**Savings: 94%!**

### Cost Optimization Strategies

#### 1. **Enable Scale-to-Zero for Dev/Test**

```bash
# Development environment
az containerapp update \
  --name dev-api \
  --resource-group $RESOURCE_GROUP \
  --min-replicas 0 \
  --max-replicas 5
```

#### 2. **Right-Size Resources**

```bash
# Start small and monitor
--cpu 0.25 --memory 0.5Gi  # $1.73/month per replica @ 8hrs/day

# Instead of over-provisioning
--cpu 1.0 --memory 2.0Gi   # $13.82/month per replica @ 8hrs/day
```

#### 3. **Use Consumption Plan When Possible**

Container Apps offers two plans:
- **Consumption**: Pay-per-use (default)
- **Dedicated (Workload Profiles)**: Reserved capacity (for high-scale, predictable workloads)

Use Consumption for most scenarios.

#### 4. **Implement Efficient Scaling Rules**

```bash
# Scale aggressively down
--scale-rule-http-concurrency 100  # Higher = fewer replicas
```

#### 5. **Share Environments**

Multiple apps can share a single environment (saves on infrastructure overhead):

```bash
# Create environment once
az containerapp env create --name shared-env ...

# Deploy multiple apps to same environment
az containerapp create --environment shared-env --name app1 ...
az containerapp create --environment shared-env --name app2 ...
az containerapp create --environment shared-env --name app3 ...
```

#### 6. **Clean Up Unused Resources**

```bash
# Delete inactive revisions
az containerapp revision deactivate ...

# Delete unused environments
az containerapp env delete --name old-env ...
```

### Cost Monitoring

**Azure Cost Management Query**:

```kql
// View Container Apps costs by resource
AzureResourceGroupCosts
| where ResourceType == "Microsoft.App/containerApps"
| summarize TotalCost = sum(Cost) by ResourceName, bin(Date, 1d)
| render timechart
```

---

## Summary and Quick Reference

### 🎯 When to Use Azure Container Apps

| Scenario | Recommendation |
|----------|----------------|
| Microservices architecture | ✅ Excellent |
| Event-driven applications | ✅ Excellent |
| APIs with variable traffic | ✅ Excellent |
| Serverless containers | ✅ Perfect fit |
| Background jobs/queue processors | ✅ Great with scale-to-zero |
| Need Kubernetes features | ⚠️ Use AKS instead |
| Windows containers | ❌ Not supported (Linux only) |
| Stateful apps requiring persistent storage | ⚠️ Use external state store |

### 📝 Essential Commands Cheat Sheet

```bash
# ═══ ENVIRONMENT ═══
az containerapp env create --name <env> --resource-group <rg> --location <loc>
az containerapp env list --output table

# ═══ CREATE APP ═══
az containerapp create \
  --name <app> \
  --resource-group <rg> \
  --environment <env> \
  --image <image> \
  --target-port 80 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 10

# ═══ UPDATE APP ═══
az containerapp update --name <app> --resource-group <rg> --image <new-image>

# ═══ SCALING ═══
az containerapp update --name <app> --min-replicas 2 --max-replicas 20

# ═══ TRAFFIC SPLITTING ═══
az containerapp ingress traffic set \
  --name <app> \
  --revision-weight <rev1>=50 <rev2>=50

# ═══ SECRETS ═══
az containerapp secret set --name <app> --secrets key1=value1 key2=value2
az containerapp update --name <app> --set-env-vars "VAR=secretref:key1"

# ═══ LOGS ═══
az containerapp logs show --name <app> --follow

# ═══ REVISIONS ═══
az containerapp revision list --name <app> --output table
az containerapp revision deactivate --name <app> --revision <rev>

# ═══ DELETE ═══
az containerapp delete --name <app> --resource-group <rg>
az containerapp env delete --name <env> --resource-group <rg>
```

### 🔗 Architecture Decision Tree

```
Need to run containers in Azure?
│
├─ Need full Kubernetes control?
│  └─ YES ──▶ Use Azure Kubernetes Service (AKS)
│
├─ Running single containers occasionally?
│  └─ YES ──▶ Use Azure Container Instances (ACI)
│
├─ Deploying web apps/APIs?
│  ├─ Need to scale to zero?
│  │  └─ YES ──▶ Azure Container Apps ✅
│  │
│  ├─ Event-driven/microservices?
│  │  └─ YES ──▶ Azure Container Apps ✅
│  │
│  └─ Traditional web app?
│     └─ Use Azure App Service
│
└─ Batch jobs/scheduled tasks?
   └─ Azure Container Apps Jobs ✅
```

---

## Conclusion

**Azure Container Apps** bridges the gap between serverless and Kubernetes, providing:

✅ **Simplicity** of serverless (no cluster management)  
✅ **Power** of Kubernetes (microservices, scaling, revisions)  
✅ **Cost-effectiveness** (scale-to-zero, pay-per-use)  
✅ **Developer-friendly** (containers, no vendor lock-in)

**Key Takeaways**:

1. **Environments** are shared boundaries for multiple apps
2. **Revisions** enable blue-green, canary, A/B testing
3. **Scale-to-zero** dramatically reduces costs
4. **KEDA** provides powerful event-driven scaling
5. **Dapr** simplifies microservices communication
6. **Managed Identity** eliminates credential management

**Your Next Steps**:

1. Deploy the SimpleApi1 and SimpleApi2 from this guide
2. Experiment with traffic splitting between revisions
3. Implement service-to-service communication
4. Set up CI/CD with GitHub Actions or Azure DevOps
5. Enable Application Insights for observability
6. Explore advanced features like Dapr and init containers

**🚀 Happy containerizing!**

---

## Additional Resources

### Official Documentation
- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Container Apps Pricing](https://azure.microsoft.com/pricing/details/container-apps/)
- [KEDA Scalers](https://keda.sh/docs/scalers/)
- [Dapr Documentation](https://docs.dapr.io/)

### Sample Code Repository
- [Azure Container Apps Samples](https://github.com/Azure-Samples/container-apps-samples)

### Learning Paths
- [Microsoft Learn: Deploy to Azure Container Apps](https://learn.microsoft.com/training/paths/deploy-azure-container-apps/)

---

**📅 Document Version**: 1.0  
**📅 Last Updated**: February 26, 2026  
**👤 Prepared for**: Comprehensive Azure Container Apps Study Guide  
**🏷️ Tags**: Azure, Container Apps, .NET, Microservices, Docker, DevOps, Kubernetes, Serverless
