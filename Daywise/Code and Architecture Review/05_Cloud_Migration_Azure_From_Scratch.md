# Building a Cloud-Native App on Azure — From Scratch
> Sequential process guide: Day 1 to Production
> Intention: Understand the exact order of Azure resources and organizational steps — what comes first, what depends on what, and why.

---

## Mental Model — Think of It Like Building a House

```
┌──────────────────────────────────────────────────────────────────────┐
│  You don't install furniture before pouring the foundation.          │
│  You don't wire electricity before raising the walls.               │
│                                                                      │
│  Azure is the same:                                                  │
│                                                                      │
│  LAND       → Azure Tenant + Subscriptions                          │
│  FOUNDATION → Networking (VNet, Subnets)                            │
│  WALLS      → Identity & Security Baseline                          │
│  UTILITIES  → Key Vault, Monitoring, Container Registry              │
│  ROOMS      → Compute (AKS / Functions / App Service)               │
│  PLUMBING   → Databases, Messaging, Cache                            │
│  DOORS      → API Management, Front Door                            │
│  FURNITURE  → Your Application Code                                  │
│  ALARM      → Alerts, Runbooks, DR Plan                             │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Overview — The 10 Phases

```
Phase 1  →  Azure Foundation (Tenant, Subscriptions, Governance)
Phase 2  →  Networking (VNet, Subnets, NSG, Private DNS)
Phase 3  →  Identity & Access (RBAC, Managed Identities, Workload Identity)
Phase 4  →  Security Baseline (Key Vault, Defender, Policy)
Phase 5  →  Container Registry & CI/CD Foundation
Phase 6  →  Compute Platform (AKS / App Service / Functions)
Phase 7  →  Data Layer (SQL / Cosmos / Redis / Storage)
Phase 8  →  Messaging Layer (Service Bus / Event Hubs)
Phase 9  →  API Gateway & Edge (APIM, Front Door, WAF)
Phase 10 →  Observability, Alerting & Go-Live Readiness
```

| Phase | What | Why This Order |
| --- | --- | --- |
| 1 — Foundation | Tenant, Management Groups, Subscriptions, Naming, Tagging | Everything else lives inside these |
| 2 — Networking | VNet, Subnets, NSG, DNS Zones, Peering | AKS/SQL cannot be moved to a VNet after creation |
| 3 — Identity | RBAC, Managed Identities, Workload Identity | Must exist before assigning permissions to any resource |
| 4 — Security Baseline | Key Vault, Defender, Azure Policy | Secrets needed before compute; policies enforce from day 1 |
| 5 — Registry & CI/CD | ACR, CI pipeline, IaC pipeline | Need image storage before deploying apps |
| 6 — Compute | AKS / Functions / Container Apps | With AKS: cluster → add-ons → namespaces → Network Policies |
| 7 — Data Layer | SQL, Cosmos, Redis, Storage | Each with private endpoint + Managed Identity access |
| 8 — Messaging | Service Bus, Event Hubs | DLQ config, Topics/Subscriptions, RBAC |
| 9 — API Gateway | APIM, Front Door, WAF | Built on top of working compute + backends |
| 10 — Observability | Log Analytics, App Insights, Alerts, Go-Live Checklist | Alerts BEFORE first production traffic |
---

## Phase 1 — Azure Foundation
> Duration: Day 1–2 | Done once per organization

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The org-level containers that everything else lives inside.        │
│  Think: company registration before you can open a bank account.   │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 1.1 — Azure Tenant (Entra ID)

- Azure Tenant = your organization's identity boundary in Azure
- Created automatically when your org signs up for Azure
- Everything (users, apps, subscriptions) lives under one Tenant
- **Action**: Verify your org's Tenant ID in `portal.azure.com → Entra ID → Overview`

### Step 1.2 — Management Group Hierarchy

```
Tenant Root Group
│
├── Platform MG               ← shared infra (networking, identity, monitoring)
│   ├── Connectivity Sub
│   └── Management Sub
│
└── Workloads MG              ← your applications
    ├── Non-Production Sub    ← dev + staging
    └── Production Sub        ← prod only
```

- **Why**: Policies and RBAC applied at MG level cascade down to all subscriptions
- **Action**: Create Management Groups in `Azure Portal → Management Groups`

### Step 1.3 — Subscriptions

- Create separate subscriptions per environment
  - `company-connectivity` → shared networking hub
  - `company-management` → monitoring, Key Vault, ACR
  - `company-workload-nonprod` → dev and staging
  - `company-workload-prod` → production only
- **Why separate subscriptions**: blast radius isolation, cost tracking, policy independence

### Step 1.4 — Naming Convention (Decide FIRST — cannot rename most resources)

```
Format:  {resource-type}-{app-name}-{environment}-{region}-{instance}

Examples:
  rg-orders-prod-eastus-001        ← Resource Group
  vnet-hub-prod-eastus-001         ← VNet
  aks-orders-prod-eastus-001       ← AKS Cluster
  sql-orders-prod-eastus-001       ← Azure SQL
  kv-orders-prod-eastus-001        ← Key Vault
```

- **Action**: Define and document naming convention in a wiki BEFORE creating any resource

### Step 1.5 — Tagging Strategy (Decide FIRST — enforce via Policy)

```
Required Tags on ALL resources:
  Environment   = prod | staging | dev
  Application   = orders | payments | notifications
  CostCenter    = CC-1234
  Owner         = team-platform@company.com
  CreatedBy     = terraform | bicep | manual
```

### Step 1.6 — Resource Groups

- Create resource groups per concern, per environment
```
rg-network-prod-eastus
rg-security-prod-eastus
rg-compute-prod-eastus
rg-data-prod-eastus
rg-monitoring-prod-eastus
```

---

## Phase 2 — Networking
> Duration: Day 2–3 | Must exist BEFORE any compute or PaaS resource

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The private road network inside your city.                         │
│  Everything travels on this — you cannot add roads after buildings  │
│  are placed without major disruption.                               │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 2.1 — Plan IP Address Space (On Paper First)

```
Hub VNet:          10.0.0.0/16   (shared services)
Prod Spoke VNet:   10.1.0.0/16   (production workloads)
Dev Spoke VNet:    10.2.0.0/16   (dev/staging workloads)

── Prod Spoke Subnets ──────────────────────────────────────
  aks-system-subnet       10.1.0.0/24    ← AKS system node pool
  aks-user-subnet         10.1.1.0/22    ← AKS user node pools (needs large range)
  appservice-subnet       10.1.5.0/24    ← App Service VNet integration
  functions-subnet        10.1.6.0/24    ← Functions VNet integration
  data-subnet             10.1.7.0/24    ← Private endpoints for SQL, Redis, Cosmos
  apim-subnet             10.1.8.0/24    ← APIM (needs /27 minimum)
  agw-subnet              10.1.9.0/24    ← Application Gateway (WAF)
```

- **Why plan first**: VNet address spaces CANNOT overlap. AKS needs a large subnet. Cannot resize subnets with resources.

### Step 2.2 — Create Hub VNet + Spoke VNets

```
Order:
1. Hub VNet (in Connectivity subscription)
2. Prod Spoke VNet (in Production subscription)
3. Dev Spoke VNet (in Non-Production subscription)
4. VNet Peering: Hub ↔ Prod Spoke
5. VNet Peering: Hub ↔ Dev Spoke
```

### Step 2.3 — Network Security Groups (NSG)

- Create one NSG per subnet
- Start with: deny all inbound, allow only what is required
- Associate NSG to subnet immediately after subnet creation

```
nsg-aks-system-subnet    → attached to aks-system-subnet
nsg-aks-user-subnet      → attached to aks-user-subnet
nsg-data-subnet          → deny all inbound except from aks-user-subnet on DB port
```

### Step 2.4 — Azure Private DNS Zones

- Create before private endpoints (endpoints register DNS records here)
```
privatelink.database.windows.net          ← Azure SQL
privatelink.redis.cache.windows.net       ← Redis
privatelink.documents.azure.com           ← Cosmos DB
privatelink.servicebus.windows.net        ← Service Bus
privatelink.vaultcore.azure.net           ← Key Vault
privatelink.azurecr.io                    ← Container Registry
```
- Link each Private DNS Zone to the Hub VNet (DNS resolves from here)

### Step 2.5 — Azure Firewall or NVA (Optional but Recommended)

- Deploy Azure Firewall in Hub VNet's AzureFirewallSubnet
- Route all spoke outbound traffic through Firewall via Route Table
- Define allowed egress rules (AKS needs specific egress for control plane communication)

---

## Phase 3 — Identity & Access
> Duration: Day 3–4 | Must exist BEFORE assigning permissions to any resource

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The ID cards and access badges for people AND services.            │
│  People get Entra ID accounts. Services get Managed Identities.    │
│  No passwords shared between services — ever.                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 3.1 — Human Access (RBAC for Team Members)

```
Role assignments (minimum required):

  Platform Engineers   → Contributor on Platform subscriptions
  App Dev Teams        → Contributor on Non-Prod subscription
                         Reader on Prod subscription
  DevOps/Release Mgr   → Contributor on Prod (or approval-gated pipeline identity)
  Security Team        → Security Reader + Security Admin
  Finance/FinOps       → Cost Management Reader
```

- Assign roles at **Management Group or Subscription** level — cascades down
- **Never assign Owner to individuals** — use PIM for just-in-time Owner access

### Step 3.2 — Service Identities (Managed Identities)

- Create a User-Assigned Managed Identity per service (preferred over system-assigned for reuse)
```
id-orders-service-prod      ← used by Orders API pods and Functions
id-payments-service-prod    ← used by Payments API
id-platform-pipeline-prod   ← used by CI/CD pipeline
```

- **Why User-Assigned**: Can be pre-created before the resource; same identity reused across resources

### Step 3.3 — Workload Identity for AKS (if using AKS)

- Enable OIDC Issuer on AKS cluster
- Create Kubernetes Service Account per application
- Federate the KSA with the Azure Managed Identity
- Result: AKS pod gets an Azure token without mounting any secret

```
AKS Pod (orders-service)
  └── Kubernetes Service Account (ksa-orders)
        └── Federated to → Azure Managed Identity (id-orders-service-prod)
              └── Has RBAC → Service Bus Data Sender + SQL Db Contributor + Key Vault Secrets User
```

### Step 3.4 — CI/CD Pipeline Identity

- Create a Managed Identity or App Registration for your pipeline
- Configure Workload Identity Federation between GitHub Actions / Azure DevOps and Azure
- Assign only what the pipeline needs: push to ACR, deploy to AKS, update App Settings

---

## Phase 4 — Security Baseline
> Duration: Day 4–5 | Must exist BEFORE storing any secret or deploying any resource

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The safe, the alarm system, and the compliance rulebook.           │
│  Everything sensitive goes here. Policies enforce the rules.       │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 4.1 — Azure Key Vault (per environment)

```
Create:
  kv-platform-prod-eastus-001      ← prod secrets
  kv-platform-staging-eastus-001   ← staging secrets
  kv-platform-dev-eastus-001       ← dev secrets

Settings:
  ✅ Soft delete: Enabled (90 days)
  ✅ Purge protection: Enabled
  ✅ Access model: Azure RBAC (not legacy Access Policies)
  ✅ Private endpoint: Yes (using privatelink.vaultcore.azure.net)
  ✅ Public network access: Disabled

Initial secrets to store:
  - DB connection strings
  - External API keys (payment gateway, SMS provider)
  - Storage account connection strings (until Managed Identity replaces them)
  - TLS certificates
```

### Step 4.2 — Microsoft Defender for Cloud

- Enable on all subscriptions
- Enable specific plans:
  - Defender for Containers (AKS scanning)
  - Defender for Databases (SQL threat detection)
  - Defender for Key Vault
  - Defender for App Service
- Review Secure Score baseline — document current score

### Step 4.3 — Azure Policy

- Assign built-in policy initiatives at Management Group level:
  - "Azure Security Benchmark" initiative
  - "Require a tag on resources" (cost center, environment, owner)
  - "Allowed locations" (restrict to approved regions)
  - "Deny public IP on SQL servers"
  - "Require private endpoints for storage accounts"

- Effect: **Deny** for CRITICAL policies, **Audit** for monitoring policies

---

## Phase 5 — Container Registry & CI/CD Foundation
> Duration: Day 5–6 | Must exist BEFORE you can build and push images

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The factory where your application is packaged (ACR)               │
│  and the assembly line (pipelines) that builds and ships it.       │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 5.1 — Azure Container Registry (ACR)

```
Create:
  acr-company-prod-eastus-001

Settings:
  ✅ SKU: Premium (required for private endpoints, geo-replication, content trust)
  ✅ Private endpoint: Yes
  ✅ Public access: Disabled
  ✅ Geo-replication: Secondary region (for multi-region deployments)
  ✅ Managed Identity of pipeline → AcrPush role
  ✅ Managed Identity of AKS → AcrPull role
  ✅ Image scanning: Enable Microsoft Defender for Containers
```

### Step 5.2 — Source Code Repository

- GitHub or Azure DevOps repo structure per service:
```
/src                  ← application code
/infra                ← Bicep or Terraform IaC
/k8s or /helm         ← Kubernetes manifests or Helm charts
/.github/workflows    ← CI/CD pipeline definitions
/tests                ← unit + integration tests
```

### Step 5.3 — CI Pipeline (per service)

```
Trigger: Every PR + Every merge to main

Stages:
  1. Restore & Build         → dotnet build
  2. Unit Tests              → dotnet test
  3. Security Scan           → CodeQL / Snyk / dotnet list package --vulnerable
  4. Docker Build            → docker build -t {image}:{commit-sha}
  5. Image Scan              → Trivy / Defender scan — fail on HIGH vulnerabilities
  6. Push to ACR             → docker push (using Workload Identity Federation)
  7. Integration Tests       → spin up Testcontainers, run integration test suite
```

### Step 5.4 — IaC Pipeline (for infrastructure)

```
Trigger: Changes to /infra directory

Stages:
  1. Validate    → bicep build / terraform validate
  2. Plan/WhatIf → terraform plan / az deployment what-if  (output reviewed)
  3. Approval    → manual gate for production changes
  4. Apply       → terraform apply / az deployment create
```

---

## Phase 6 — Compute Platform
> Duration: Day 6–10 | The "rooms" where your application code runs

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The servers (virtual or managed) that execute your application.   │
│  Choose ONE primary compute platform per workload type.            │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 6.1 — Choose Your Compute (Decision First)

```
┌────────────────────────────────────────────────────────────────────┐
│  COMPUTE CHOICE GUIDE                                              │
│                                                                    │
│  Microservices + containers + complex networking?                  │
│    → AKS                                                           │
│                                                                    │
│  Event-driven, serverless, pay-per-use?                           │
│    → Azure Functions                                               │
│                                                                    │
│  Containers but simpler ops?                                      │
│    → Azure Container Apps                                          │
│                                                                    │
│  Web app / API with simple PaaS ops?                              │
│    → Azure App Service                                             │
└────────────────────────────────────────────────────────────────────┘
```

### Step 6.2a — If AKS: Create Cluster

```
Order of operations:
1. Create AKS cluster (private, OIDC-enabled, Workload Identity enabled)
   - Deploy into aks-system-subnet and aks-user-subnet
   - Enable Azure CNI Overlay or Cilium
   - System node pool: 3 nodes × Standard_D4s_v5 across 3 AZs
   - User node pool: starts at 3, autoscales to 20 across 3 AZs

2. Attach ACR to AKS
   az aks update --attach-acr {acr-name}

3. Install cluster add-ons
   - Azure Key Vault CSI driver (for secrets from Key Vault)
   - NGINX Ingress Controller (for HTTP routing)
   - cert-manager (for TLS certificates)
   - KEDA (for event-driven pod autoscaling)
   - Azure Monitor / Prometheus adapter (for metrics)

4. Create namespaces per service
   kubectl create namespace orders-prod
   kubectl create namespace payments-prod

5. Apply Network Policies (deny all intra-pod by default)

6. Configure Workload Identity per service
   - Create Service Account
   - Annotate with Managed Identity Client ID
   - Federate

7. Apply resource quotas per namespace
```

### Step 6.2b — If Azure Functions: Create Function App

```
Order:
1. Create App Service Plan (Premium EP1/EP2 for VNet + no cold start)
2. Create Storage Account for function runtime state
3. Create Function App
   - Enable Managed Identity
   - Configure VNet Integration (outbound through functions-subnet)
   - Restrict inbound to APIM subnet or VNet only
   - Reference secrets from Key Vault (@Microsoft.KeyVault(...))
4. Configure Application Settings (pointing to Key Vault references)
5. Deploy function code via CI/CD pipeline
```

### Step 6.2c — If Container Apps: Create Environment

```
Order:
1. Create Container Apps Environment (with custom VNet)
2. Create Container App per service
   - Configure Managed Identity
   - Configure KEDA scaling rules
   - Configure min/max replicas
   - Reference Key Vault secrets
3. Configure ingress (internal vs external)
```

---

## Phase 7 — Data Layer
> Duration: Day 7–12 | Databases, Cache, Storage — provisioned BEFORE application needs them

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  Where your application's data lives at rest.                      │
│  Provision in data-subnet using private endpoints.                 │
│  NO public access. Managed Identity for all connections.           │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 7.1 — Azure SQL Database

```
Order:
1. Create SQL Server (logical server)
   - Enable Entra ID authentication
   - Set Entra ID Admin (a group, not an individual)
   - Disable SQL authentication (enforce AAD only)
   - Disable public endpoint

2. Create SQL Database
   - SKU: General Purpose or Business Critical based on SLA
   - Enable Zone Redundancy
   - Enable Long-Term Retention backup policy

3. Create Private Endpoint
   - In data-subnet
   - DNS record registered in privatelink.database.windows.net zone

4. Grant access via RBAC (not connection strings with passwords)
   - App Managed Identity → "db_datareader" + "db_datawriter" via SQL:
     CREATE USER [id-orders-service-prod] FROM EXTERNAL PROVIDER;
     ALTER ROLE db_datareader ADD MEMBER [id-orders-service-prod];

5. Run EF Core migrations from pipeline (using pipeline identity)
```

### Step 7.2 — Azure Cosmos DB (if using)

```
Order:
1. Create Cosmos DB Account
   - API: NoSQL
   - Enable Multi-region (if needed)
   - Disable public access
   - Choose consistency level

2. Create Database and Containers
   - Define partition key BEFORE creating (cannot change later)

3. Create Private Endpoint → data-subnet

4. Grant RBAC role to Managed Identity
   az cosmosdb sql role assignment create \
     --role-definition-name "Cosmos DB Built-in Data Contributor" \
     --principal-id {managed-identity-object-id}
```

### Step 7.3 — Azure Cache for Redis

```
Order:
1. Create Redis Cache
   - SKU: Standard C1 minimum for prod (has replication)
   - Enable Zone Redundancy (Premium tier)
   - Disable non-SSL port

2. Create Private Endpoint → data-subnet

3. Application connects using Entra ID + Managed Identity (or access key stored in Key Vault)

4. Configure eviction policy in redis.conf:
   - allkeys-lru for pure caching
   - noeviction for session store
```

### Step 7.4 — Azure Storage Account

```
Order:
1. Create Storage Account
   - StorageV2, ZRS or GZRS
   - Disable public blob access at account level
   - Enable soft delete (blobs: 14 days, containers: 14 days)
   - Enable versioning for critical containers

2. Create Private Endpoints (Blob + Queue + Table — separate endpoint per service)

3. Create containers/queues for the application:
   uploads-raw          ← incoming user uploads
   uploads-processed    ← post-processing output
   audit-logs           ← append-only audit trail

4. Assign Storage RBAC roles to Managed Identity:
   "Storage Blob Data Contributor" for read/write
   "Storage Queue Data Contributor" for queue operations
```

---

## Phase 8 — Messaging Layer
> Duration: Day 8–11 | Async communication backbone between services

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The postal service between your microservices.                    │
│  Messages are guaranteed, durable, and decoupled.                  │
│  Provision BEFORE the services that need to send/receive.          │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 8.1 — Azure Service Bus

```
Order:
1. Create Service Bus Namespace
   - Tier: Premium (required for private endpoints, VNet, 1MB+ messages)
   - Enable Zone Redundancy

2. Create Private Endpoint → data-subnet (same subnet as data resources)

3. Create Topics (for pub/sub between multiple consumers)
   orders-topic
     ├── orders-fulfillment-subscription
     ├── orders-notification-subscription
     └── orders-audit-subscription

   payments-topic
     ├── payments-ledger-subscription
     └── payments-notification-subscription

4. Create Queues (for point-to-point)
   email-send-queue          ← email service reads from here
   sms-send-queue            ← SMS service reads from here

5. Configure each queue/topic:
   - Dead letter queue: enabled (always)
   - Message TTL: 7 days (review per workload)
   - MaxDeliveryCount: 5 (retry 5 times before DLQ)
   - Duplicate detection: enabled (if idempotency required)

6. Assign RBAC to Managed Identities:
   Producer (orders-service) → "Azure Service Bus Data Sender" on orders-topic
   Consumer (fulfillment-service) → "Azure Service Bus Data Receiver" on subscription
```

### Step 8.2 — Azure Event Hubs (if high-volume streaming needed)

```
Order:
1. Create Event Hubs Namespace
   - Tier: Standard or Premium
   - Enable Zone Redundancy

2. Create Private Endpoint

3. Create Event Hubs
   telemetry-hub    (32 partitions for high throughput)
   audit-hub        (4 partitions)

4. Create Consumer Groups per consuming application
   telemetry-hub → $default (avoid), analytics-consumer, monitoring-consumer

5. Assign RBAC to Managed Identities
```

---

## Phase 9 — API Gateway & Edge
> Duration: Day 10–13 | The front door to your application — controlled entry point

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The reception desk and security checkpoint for all external       │
│  traffic entering your system.                                     │
│  External traffic never reaches services directly.                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 9.1 — Azure API Management (APIM)

```
Order:
1. Create APIM instance
   - Tier: Premium (VNet integration, multi-region, zone redundancy)
   - VNet Mode: External (public APIs) or Internal (private APIs only)
   - Deploy into apim-subnet

2. Configure Managed Identity for APIM (to call backend services)

3. Import APIs (from OpenAPI specs of each backend service)
   - Orders API  → https://orders-internal.company.local
   - Payments API → https://payments-internal.company.local

4. Configure Global Policies (apply to ALL APIs):
   <policies>
     <inbound>
       validate-jwt               ← validate Entra ID tokens
       rate-limit-by-key          ← 1000 calls/min per subscription
       correlation-id             ← inject correlation ID header
       remove-header name="X-Powered-By"
     </inbound>
     <backend>
       forward-request            ← route to backend
     </backend>
     <outbound>
       set-header name="X-Content-Type-Options" value="nosniff"
     </outbound>
   </policies>

5. Create Products (tiers):
   Internal    ← for internal service-to-service calls
   External    ← for third-party / customer API consumers

6. Create Named Values (pointing to Key Vault) for secrets in policies
```

### Step 9.2 — Azure Front Door (Global Entry Point)

```
Order:
1. Create Azure Front Door profile (Standard or Premium)
   - Premium: required for Private Link origin (APIM behind private endpoint)

2. Create Endpoint (custom domain: api.company.com)

3. Create Origin Group → points to APIM instance

4. Configure WAF Policy
   - Mode: Prevention
   - Managed rule sets: DefaultRuleSet_2.1 + BotManagerRuleSet_1.0
   - Custom rules: rate limiting, geo-blocking if applicable

5. Configure TLS:
   - Managed certificate (auto-renewed by Front Door)
   - Minimum TLS 1.2

6. Configure Routing Rules:
   /api/* → APIM origin
   /* → static site or Blob Storage
```

---

## Phase 10 — Observability, Alerting & Go-Live Readiness
> Duration: Day 12–15 | You cannot operate what you cannot see

```
┌─────────────────────────────────────────────────────────────────────┐
│  WHAT YOU ARE SETTING UP                                            │
│  The control room: dashboards, alerts, and runbooks.               │
│  This should be partially set up EARLY and refined before go-live. │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 10.1 — Log Analytics Workspace

```
Order:
1. Create ONE central Log Analytics Workspace (per environment)
   - Workspace for prod: law-platform-prod-eastus-001
   - Retention: 90 days active + 2 years archive (adjust for compliance)

2. Connect all resources to this workspace:
   - AKS Diagnostic Settings → workspace
   - Azure SQL Audit logs → workspace
   - Key Vault Diagnostic Settings → workspace
   - Service Bus Diagnostic Settings → workspace
   - APIM Diagnostic Settings → workspace
   - Azure Firewall logs → workspace
   - NSG Flow Logs → workspace
```

### Step 10.2 — Application Insights

```
Order:
1. Create Application Insights resource (workspace-based, linked to Log Analytics)
   - One per service (or one per environment if simpler to start)

2. Add OpenTelemetry SDK to each .NET service:
   builder.Services.AddOpenTelemetry()
     .WithTracing(...)
     .WithMetrics(...)
     .WithLogging(...);

3. Configure connection string from Key Vault
   (APPLICATIONINSIGHTS_CONNECTION_STRING → Key Vault reference)
```

### Step 10.3 — Health Checks

```
In each .NET service:

builder.Services.AddHealthChecks()
  .AddSqlServer(connectionString, name: "sql")
  .AddRedis(redisConnectionString, name: "redis")
  .AddAzureServiceBusTopic(connectionString, topicName, name: "servicebus");

app.MapHealthChecks("/health/live",  new() { Predicate = _ => false }); // process only
app.MapHealthChecks("/health/ready", new() { Predicate = _ => true  }); // all deps

In Kubernetes:
  readinessProbe: /health/ready
  livenessProbe:  /health/live
```

### Step 10.4 — Alerts (Create BEFORE Go-Live)

```
Mandatory alerts:

  Service Health
  ├── Azure Service Health alert (notify on Azure outages in your regions)

  Application
  ├── Error rate > 1% for 5 min → Critical (PagerDuty)
  ├── P99 latency > 2s for 5 min → Warning
  ├── Failed health checks → Critical
  └── Pod restart count > 5 in 10 min (AKS) → Warning

  Messaging
  ├── DLQ message count > 0 → Warning (act within 1 hour)
  ├── DLQ message count > 10 → Critical
  └── Service Bus namespace throttling → Warning

  Data
  ├── SQL DTU/CPU > 80% for 10 min → Warning
  ├── SQL failed connections > 5/min → Critical
  └── Redis eviction rate > 0 → Warning

  Cost
  ├── Budget at 80% of monthly forecast → Warning
  └── Budget at 100% → Critical

Each alert → Action Group → Teams channel + PagerDuty escalation
Each alert → must have a runbook URL in the alert description
```

### Step 10.5 — Dashboards

```
Create Azure Monitor Workbook or Grafana dashboard per service:

  Sections:
  ├── Golden Signals (Latency P50/P95/P99, Traffic RPS, Error Rate %, Saturation %)
  ├── SLO burn rate (error budget remaining)
  ├── AKS cluster health (node CPU, memory, pod count, restarts)
  ├── Messaging health (DLQ depth, processing rate, consumer lag)
  ├── Database health (DTU%, connections, deadlocks, slow queries)
  └── Cost trend (daily spend vs forecast)
```

### Step 10.6 — Go-Live Readiness Checklist

```
Before production traffic:

  Infrastructure
  ☐ All resources deployed via IaC — no manual portal resources
  ☐ Private endpoints enabled — zero public access on databases/messaging
  ☐ Managed Identity used — no passwords or secrets in code/config
  ☐ Key Vault populated with all secrets
  ☐ NSGs in place — deny-all-inbound baseline

  Application
  ☐ Health checks responding correctly (/health/live, /health/ready)
  ☐ Structured logging with correlation IDs in all services
  ☐ Graceful shutdown implemented (preStop hook, drain period)
  ☐ Pod disruption budgets configured
  ☐ Resource limits set on all containers

  Reliability
  ☐ HPA / autoscaling configured and tested
  ☐ AZ redundancy enabled on all critical resources
  ☐ Backup configured and restore tested
  ☐ Failover runbook written

  Security
  ☐ WAF in Prevention mode
  ☐ Microsoft Defender for Cloud Secure Score reviewed
  ☐ Penetration test / security review complete
  ☐ No HIGH/CRITICAL vulnerabilities in container images

  Operations
  ☐ Alerts active and tested (fire-drill at least DLQ and error rate alerts)
  ☐ Runbooks written for every alert
  ☐ On-call rotation defined
  ☐ Rollback procedure documented and tested
  ☐ Load test run at 2× expected peak (results accepted)
```

---

## The Full Sequential Order — One-Page Summary

```
┌──────────────────────────────────────────────────────────────────────┐
│  AZURE CLOUD-NATIVE APP — CREATION ORDER                             │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  DAY 1-2  │ PHASE 1: FOUNDATION                                     │
│           │  1. Azure Tenant (already exists at org signup)         │
│           │  2. Management Group hierarchy                           │
│           │  3. Subscriptions (connectivity, mgmt, nonprod, prod)   │
│           │  4. Naming convention + Tagging strategy (document)     │
│           │  5. Resource Groups per concern per environment         │
│           │                                                          │
│  DAY 2-3  │ PHASE 2: NETWORKING                                     │
│           │  6. IP address plan (on paper)                          │
│           │  7. Hub VNet + Spoke VNets                              │
│           │  8. Subnets (AKS, data, apim, agw, functions)          │
│           │  9. NSGs (one per subnet, deny-all default)             │
│           │  10. VNet Peering (Hub ↔ Spokes)                       │
│           │  11. Azure Private DNS Zones (one per PaaS service)    │
│           │  12. Azure Firewall / Route Tables (optional)          │
│           │                                                          │
│  DAY 3-4  │ PHASE 3: IDENTITY                                       │
│           │  13. RBAC assignments for team members                  │
│           │  14. User-Assigned Managed Identities (per service)    │
│           │  15. Workload Identity Federation (for AKS/pipeline)   │
│           │                                                          │
│  DAY 4-5  │ PHASE 4: SECURITY BASELINE                             │
│           │  16. Key Vault (per environment, private endpoint)      │
│           │  17. Microsoft Defender for Cloud (enable all plans)   │
│           │  18. Azure Policy (tagging, deny public, allowed locs)  │
│           │                                                          │
│  DAY 5-6  │ PHASE 5: REGISTRY & CI/CD PIPELINE                     │
│           │  19. Azure Container Registry (Premium, private)        │
│           │  20. CI pipeline (build → test → scan → push to ACR)   │
│           │  21. IaC pipeline (validate → plan → apply)             │
│           │                                                          │
│  DAY 6-10 │ PHASE 6: COMPUTE                                        │
│           │  22. AKS cluster (private, OIDC, Workload Identity)    │
│           │  23. AKS add-ons (CSI, ingress, cert-manager, KEDA)   │
│           │  24. Namespaces, Network Policies, Resource Quotas     │
│           │  OR: Azure Functions / Container Apps                   │
│           │                                                          │
│  DAY 7-12 │ PHASE 7: DATA LAYER                                     │
│           │  25. Azure SQL (private endpoint, AAD auth, ZR)        │
│           │  26. Azure Cosmos DB (private endpoint, RBAC)          │
│           │  27. Azure Cache for Redis (private endpoint)           │
│           │  28. Azure Storage Account (private endpoint, ZRS)     │
│           │                                                          │
│  DAY 8-11 │ PHASE 8: MESSAGING                                      │
│           │  29. Service Bus Namespace (Premium, private endpoint)  │
│           │  30. Topics + Subscriptions + Queues + DLQ config      │
│           │  31. Event Hubs (if high-volume streaming needed)      │
│           │                                                          │
│  DAY 10-13│ PHASE 9: API GATEWAY & EDGE                             │
│           │  32. API Management (Premium, VNet internal)            │
│           │  33. Import APIs, configure JWT validation, rate limit  │
│           │  34. Azure Front Door + WAF (Prevention mode)          │
│           │  35. Custom domain + TLS certificates                   │
│           │                                                          │
│  DAY 12-15│ PHASE 10: OBSERVABILITY & GO-LIVE                       │
│           │  36. Log Analytics Workspace (connect all resources)   │
│           │  37. Application Insights (one per service)             │
│           │  38. Health check endpoints in application             │
│           │  39. Azure Monitor Alerts (DLQ, error rate, latency)   │
│           │  40. Dashboards (golden signals, SLO burn rate)         │
│           │  41. Go-Live Readiness Checklist ✅                     │
│           │  42. Load test + DR drill                               │
│           │  43. PRODUCTION TRAFFIC                                 │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Dependency Chain — What Blocks What

```
Tenant
  └─ Management Groups
       └─ Subscriptions
            └─ Resource Groups
                 ├─ Networking (VNet, Subnets, NSG, DNS Zones)   ← MUST BE FIRST
                 │    └─ Private Endpoints (created last — need VNet)
                 │
                 ├─ Managed Identities                            ← BEFORE any resource
                 │
                 ├─ Key Vault (needs VNet for private endpoint)  ← BEFORE secrets needed
                 │
                 ├─ ACR (needs VNet for private endpoint)        ← BEFORE compute
                 │
                 ├─ AKS (needs VNet, ACR, Key Vault, MSI)       ← BEFORE app deploy
                 │
                 ├─ SQL / Cosmos / Redis / Storage               ← BEFORE app deploy
                 │    └─ Private Endpoints (needs VNet + DNS)
                 │
                 ├─ Service Bus / Event Hubs                     ← BEFORE app deploy
                 │    └─ Private Endpoints
                 │
                 ├─ APIM (needs VNet subnet, backend services)  ← AFTER compute
                 │
                 ├─ Front Door / WAF (needs APIM or backend)    ← AFTER APIM
                 │
                 └─ Observability (can start early, refine later)
```

---

## Common Mistakes to Avoid

| Mistake | Impact | Prevention |
|---|---|---|
| Creating VNet after compute | AKS cannot be moved to a VNet after creation | Always network first |
| Wrong subnet size for AKS | Cannot resize — cluster recreation required | Plan /22 minimum for user node pool |
| Using `:latest` image tag | Uncontrolled deployments, no rollback | Use commit SHA from day 1 |
| Hardcoding secrets in app settings | Security breach, rotation nightmare | Key Vault references from day 1 |
| Skipping Private DNS Zones | Private endpoints resolve to public IPs | Create DNS Zones with VNet link before private endpoints |
| Manual portal changes | Drift from IaC — next pipeline run overwrites | IaC pipeline from phase 5 |
| Single region deployment | One region outage = full downtime | Plan for AZ redundancy at minimum |
| No DLQ alerting | Messages fail silently for days | Alerts before first message sent |
| Shared Key Vault across environments | Dev experiment corrupts prod secrets | One KV per environment |
| WAF in Detection mode "temporarily" | WAF in Detection blocks nothing — false security | Set Prevention mode from day 1 |

---

*Cloud-Native Azure — From Scratch Sequential Guide v1.0*
*Covers: Foundation → Networking → Identity → Security → Registry → Compute → Data → Messaging → API Gateway → Observability*
