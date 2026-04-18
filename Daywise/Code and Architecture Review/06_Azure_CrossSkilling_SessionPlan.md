# Azure Cross-Skilling Program — Team Enablement Guide
> Facilitator: Architecture Board Member | Instructed by: Associate Director
> Audience: Developers (mixed seniority) with limited Azure exposure
> Format: 1 session per day · 1 hour per session · 1 topic per session
> Purpose: Single Source of Truth — facilitator notes + content + talking points + demos

---

## Facilitator Notes (Read Before You Begin)

```
┌──────────────────────────────────────────────────────────────────────┐
│  WHO IS IN THE ROOM?                                                 │
│                                                                      │
│  Junior Devs   → Need the "what" and "why" before the "how"        │
│  Senior Devs   → Need the "how" with depth — skip basics fast       │
│                                                                      │
│  APPROACH PER SESSION:                                               │
│  ├── First 5 min  : Recap previous session (accountability)         │
│  ├── Next 10 min  : Concept + Mental Model (everyone learns)        │
│  ├── Next 25 min  : Deep dive — real patterns, code, demos          │
│  ├── Next 10 min  : Live demo or walkthrough in portal/CLI          │
│  └── Last 10 min  : Q&A + Homework + Preview of next session        │
│                                                                      │
│  GROUND RULES:                                                       │
│  • Azure Portal + Azure CLI are both shown (visual + command)       │
│  • Every session ends with one concrete homework task               │
│  • Senior devs are asked architecture questions to engage them      │
│  • Questions are parked in a shared doc if they need follow-up      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Program Overview — 5 Weeks · 25 Sessions

```
┌──────────────────────────────────────────────────────────────────────┐
│  WEEK 1 : Azure Foundation — The "What and Why"                     │
│  WEEK 2 : Compute — Running Your Code on Azure                      │
│  WEEK 3 : Data — Storage, Databases, and Caching                    │
│  WEEK 4 : Messaging & Integration — Services Talking to Services    │
│  WEEK 5 : Security, Observability, DevOps & Architecture Patterns   │
└──────────────────────────────────────────────────────────────────────┘
```

| # | Session Title | Week | Pillar |
|---|---|---|---|
| 01 | Azure 101 — The Mental Model, Portal & CLI | 1 | Foundation |
| 02 | Azure Organization — Tenants, Subscriptions & Resource Groups | 1 | Foundation |
| 03 | Azure Networking — VNets, Subnets, NSG & Private Endpoints | 1 | Networking |
| 04 | Identity in Azure — Entra ID, Managed Identity & RBAC | 1 | Identity |
| 05 | Azure Key Vault — Secrets, Certificates & Config Management | 1 | Security |
| 06 | Azure App Service — Deploy a .NET API in 1 Hour | 2 | Compute |
| 07 | Azure Container Apps — Containers Without the Kubernetes Ops | 2 | Compute |
| 08 | AKS Part 1 — Kubernetes on Azure, Cluster Setup & Workloads | 2 | Compute |
| 09 | AKS Part 2 — Networking, Scaling, Security & Ingress | 2 | Compute |
| 10 | Azure Functions — Serverless Event-Driven Programming | 2 | Compute |
| 11 | Azure SQL Database — Managed Relational DB for Developers | 3 | Data |
| 12 | Azure Cosmos DB — Globally Distributed NoSQL | 3 | Data |
| 13 | Azure Cache for Redis — Caching Patterns & Session State | 3 | Data |
| 14 | Azure Blob Storage — Files, Objects & Lifecycle Management | 3 | Data |
| 15 | Azure Service Bus — Reliable Async Messaging | 4 | Messaging |
| 16 | Azure Event Hubs — High-Throughput Event Streaming | 4 | Messaging |
| 17 | Azure Event Grid — Reactive Cloud Events & Fan-Out | 4 | Messaging |
| 18 | API Management (APIM) — The Front Door for Your APIs | 4 | Integration |
| 19 | Azure Front Door & WAF — Global Edge, CDN & Security | 4 | Integration |
| 20 | Azure Security Deep Dive — Defender, Policy & Zero Trust | 5 | Security |
| 21 | Azure Monitor, App Insights & Log Analytics | 5 | Observability |
| 22 | Azure DevOps & GitHub Actions — CI/CD Pipelines on Azure | 5 | DevOps |
| 23 | Infrastructure as Code — Bicep & Terraform for Azure | 5 | DevOps |
| 24 | Cloud-Native Architecture Patterns on Azure | 5 | Architecture |
| 25 | Capstone — Design a Cloud-Native System Together | 5 | Architecture |

---

---

# WEEK 1 — Azure Foundation

---

## Session 01 — Azure 101: The Mental Model, Portal & CLI
> Duration: 60 min | Prereqs: None | Who benefits most: Everyone

### Learning Objectives
By end of this session, developers will:
- Understand what Azure is and how it compares to on-premises infrastructure
- Navigate the Azure Portal confidently
- Run basic commands with Azure CLI
- Understand the most common resource types

### 1-Hour Breakdown

| Time | Activity |
|---|---|
| 0–5 min | Intro: Why this program exists, what we'll cover in 5 weeks |
| 5–15 min | Concept: What is Cloud? What is Azure? Mental Model |
| 15–35 min | Deep Dive: Azure Portal walkthrough + Service categories |
| 35–45 min | Demo: Azure CLI — login, create resource group, list resources |
| 45–55 min | Discussion: "What Azure services do we currently use? What are we missing?" |
| 55–60 min | Homework + Preview |

### Concept: Mental Model

```
ON-PREMISES (before Azure)              AZURE (now)
──────────────────────────────────────────────────────
Physical server in data center    →  Virtual Machine (IaaS)
Install SQL Server yourself       →  Azure SQL Database (PaaS)
Write code to read a file         →  Azure Blob Storage
Buy a load balancer               →  Azure Load Balancer / Front Door
Configure firewall rules          →  Network Security Groups
Manage SSL certificates yourself  →  Azure Key Vault + App Gateway

KEY INSIGHT: Azure removes the "undifferentiated heavy lifting"
             so developers focus on business logic, not hardware.
```

### Azure Service Categories (for developers)

```
COMPUTE    → Where your code runs
             App Service, AKS, Azure Functions, Container Apps, VMs

DATA       → Where your data lives
             Azure SQL, Cosmos DB, Redis, Blob Storage, Table Storage

MESSAGING  → How services talk asynchronously
             Service Bus, Event Hubs, Event Grid, Storage Queues

IDENTITY   → Who can access what
             Entra ID (Azure AD), Managed Identity, Key Vault

NETWORKING → How everything connects securely
             VNet, Subnets, NSG, Private Endpoints, Front Door

DEVOPS     → How you build and ship
             Azure DevOps, GitHub Actions, Container Registry

MONITORING → How you know things are working
             Application Insights, Log Analytics, Azure Monitor
```

### Demo Script: Azure CLI

```bash
# Step 1: Login to Azure
az login

# Step 2: See your subscriptions
az account list --output table

# Step 3: Set the subscription you want to work with
az account set --subscription "your-subscription-name"

# Step 4: Create your first resource group
az group create \
  --name rg-training-dev-eastus \
  --location eastus \
  --tags Environment=dev Team=backend

# Step 5: List resource groups
az group list --output table

# Step 6: Check available locations
az account list-locations --output table

# Step 7: Clean up
az group delete --name rg-training-dev-eastus --yes
```

### Discussion Questions (engage senior devs)
- "If you were migrating our current monolith to Azure, where would you start?"
- "What's the difference between IaaS, PaaS, and SaaS? Give an Azure example of each."

### Homework
> Create a free Azure account (if not already done), create a resource group named `rg-{yourname}-learning`, and screenshot it in the portal.

---

## Session 02 — Azure Organization: Tenants, Subscriptions & Resource Groups
> Duration: 60 min | Prereqs: Session 01 | Who benefits most: Everyone

### Learning Objectives
- Understand the Tenant → Management Group → Subscription → Resource Group hierarchy
- Know WHY organizations use multiple subscriptions
- Understand how billing, access, and policies flow through this hierarchy

### 1-Hour Breakdown

| Time | Activity |
|---|---|
| 0–5 min | Recap Session 01 — show homework screenshots |
| 5–20 min | Concept: Hierarchy + Mental Model |
| 20–40 min | Deep Dive: Subscriptions, RGs, naming, tagging |
| 40–50 min | Demo: Exploring the portal hierarchy, setting tags via CLI |
| 50–60 min | Q&A + Homework |

### Concept: The Container Hierarchy

```
AZURE TENANT (your company's identity boundary)
│   = Your company's "country" in Azure
│   = One Entra ID directory
│
├── Management Group  (optional grouping)
│   = "Departments" — policies cascade down
│
├── SUBSCRIPTION  (billing + access boundary)
│   = "Bank account" — bills arrive here
│   = Separate subscription per environment (dev/prod)
│   = Blast radius isolation
│
└── RESOURCE GROUP  (logical container for related resources)
    = "Project folder" — delete the group, delete everything in it
    = All resources in a group are managed, billed, and secured together
    = One lifecycle: resources that deploy together, live in the same RG
```

### Why Separate Subscriptions?

```
┌────────────────────────────────────────────────────────────────────┐
│  REASON              │ EXAMPLE                                     │
├────────────────────────────────────────────────────────────────────┤
│ Billing isolation    │ Each team/project gets its own invoice      │
│ Blast radius         │ Prod issue cannot affect dev subscription   │
│ Policy independence  │ Dev has relaxed policy, Prod is strict      │
│ Quota management     │ 20,000 cores limit per subscription         │
│ Access control       │ Contractors access Dev, not Prod            │
└────────────────────────────────────────────────────────────────────┘
```

### Naming Convention — The Most Important Decision

```
Rule: Once created, most Azure resources CANNOT be renamed.
      Get naming right before creating anything.

Pattern:  {type}-{app}-{env}-{region}-{instance}

Examples:
  rg-payments-prod-eus-001        ← Resource Group
  vnet-hub-prod-eus-001           ← Virtual Network
  aks-orders-prod-eus-001         ← AKS Cluster
  sql-orders-prod-eus-001         ← Azure SQL Server
  kv-platform-prod-eus-001        ← Key Vault  (max 24 chars!)
  func-notifications-prod-eus-001 ← Azure Function
  acr-company-prod-eus-001        ← Container Registry (alphanumeric only!)
```

### Tagging Strategy

```bash
# Tags answer: "Why does this resource exist? Who owns it? What is it for?"

Required tags on EVERY resource:
  Environment  = prod | staging | dev
  Application  = orders | payments | platform
  CostCenter   = CC-1234
  Owner        = team-platform@company.com

# CLI: Set tags on a resource group
az group update \
  --name rg-orders-prod-eus \
  --tags Environment=prod Application=orders CostCenter=CC-1234 Owner=teamA@company.com
```

### Homework
> Map out our actual Azure subscription structure. Which subscriptions exist? Do we have separate dev/prod? Who is the subscription owner? Report back next session.

---

## Session 03 — Azure Networking: VNets, Subnets, NSG & Private Endpoints
> Duration: 60 min | Prereqs: Session 02 | Who benefits most: Everyone

### Learning Objectives
- Understand why networking is the foundation of secure Azure design
- Know what a VNet, Subnet, NSG, and Private Endpoint are and how they relate
- Understand why all PaaS services should be behind private endpoints

### 1-Hour Breakdown

| Time | Activity |
|---|---|
| 0–5 min | Recap Session 02 |
| 5–20 min | Concept: The VNet mental model |
| 20–40 min | Deep Dive: Subnets, NSG rules, Private Endpoints, DNS |
| 40–50 min | Demo: Create VNet + Subnet + NSG via CLI |
| 50–60 min | Q&A + Homework |

### Concept: Mental Model

```
Think of Azure Networking like a city:

  AZURE REGION        = The city limits
  VIRTUAL NETWORK     = Your private gated neighborhood
  SUBNET              = Different streets within your neighborhood
  NSG                 = Security guard at each street entrance
  PRIVATE ENDPOINT    = A private mailbox for a shop (Azure service)
                        instead of the shop being on a public street
  PUBLIC IP           = A billboard visible to anyone on the internet
  DNS ZONE            = The address book that maps names to IPs

Without a VNet, your services sit on the public internet.
With a VNet, only traffic you explicitly allow can reach your services.
```

### VNet & Subnet Design (the talk track for developers)

```
Key rules developers must know:
  1. VNets are regional — a VNet lives in one Azure region
  2. VNets do not span subscriptions — use VNet Peering to connect them
  3. Subnets cannot overlap — 10.1.0.0/24 and 10.1.0.128/25 conflict
  4. AKS needs a large subnet — /22 at minimum (1,024 IPs for pods)
  5. You CANNOT resize a subnet while resources are deployed in it

Typical subnet split for a production workload:
  aks-system-subnet      10.1.0.0/24    ← 256 IPs for system pods
  aks-user-subnet        10.1.4.0/22    ← 1024 IPs for app pods
  data-subnet            10.1.8.0/24    ← Private endpoints for SQL, Redis
  functions-subnet       10.1.9.0/24    ← Functions VNet integration
  apim-subnet            10.1.10.0/27   ← APIM (needs /27 = 32 IPs min)
```

### Network Security Groups (NSG)

```
NSG = A stateful firewall attached to a subnet or NIC

Rule structure: Priority | Source | Destination | Port | Protocol | Allow/Deny

Example NSG rules for the data subnet:
  Priority  Source              Dest        Port   Action
  ────────────────────────────────────────────────────────
  100       aks-user-subnet     data-subnet 1433   Allow  ← SQL from AKS pods only
  100       aks-user-subnet     data-subnet 6380   Allow  ← Redis from AKS pods only
  4096      *                   *           *      Deny   ← Deny everything else

KEY INSIGHT: "Deny all inbound, allow only what you need" is the rule.
```

### Private Endpoints — Why They Matter

```
WITHOUT Private Endpoint:
  Your app → Internet → Public IP of Azure SQL → Your SQL Database
  Problem: SQL is reachable from anywhere on the internet

WITH Private Endpoint:
  Your app → Private VNet IP (10.1.8.5) → Azure SQL → Your SQL Database
  The private IP is only reachable from within your VNet
  Azure SQL's public endpoint can be DISABLED entirely

Steps to create:
  1. Create a Private Endpoint resource in your data-subnet
  2. Link it to the target resource (e.g., Azure SQL server)
  3. Azure automatically registers a DNS record in the Private DNS Zone
  4. Your app resolves sql-server.database.windows.net → 10.1.8.5 (private IP)
```

### Demo Script

```bash
# Create VNet with two subnets
az network vnet create \
  --name vnet-orders-prod-eus \
  --resource-group rg-network-prod \
  --address-prefix 10.1.0.0/16 \
  --subnet-name aks-user-subnet \
  --subnet-prefix 10.1.4.0/22

# Add a second subnet (data)
az network vnet subnet create \
  --name data-subnet \
  --vnet-name vnet-orders-prod-eus \
  --resource-group rg-network-prod \
  --address-prefix 10.1.8.0/24

# Create NSG
az network nsg create \
  --name nsg-data-subnet \
  --resource-group rg-network-prod

# Add NSG deny-all inbound rule (lowest priority = last resort)
az network nsg rule create \
  --name DenyAllInbound \
  --nsg-name nsg-data-subnet \
  --resource-group rg-network-prod \
  --priority 4096 \
  --direction Inbound \
  --access Deny \
  --protocol '*' --source-address-prefixes '*' --destination-port-ranges '*'

# Associate NSG with subnet
az network vnet subnet update \
  --name data-subnet \
  --vnet-name vnet-orders-prod-eus \
  --resource-group rg-network-prod \
  --network-security-group nsg-data-subnet
```

### Homework
> Draw a diagram of the current network architecture of any Azure workload you're familiar with. Or: describe what would happen if our SQL database had no private endpoint and the NSG was accidentally removed.

---

## Session 04 — Identity in Azure: Entra ID, Managed Identity & RBAC
> Duration: 60 min | Prereqs: Session 02 | Who benefits most: Everyone

### Learning Objectives
- Understand how identity works in Azure (for humans AND for services)
- Understand RBAC and how to assign roles correctly
- Understand Managed Identity — the single most important security concept for developers

### 1-Hour Breakdown

| Time | Activity |
|---|---|
| 0–5 min | Recap Session 03 |
| 5–20 min | Concept: Identity types + Mental Model |
| 20–40 min | Deep Dive: RBAC, Managed Identity, Workload Identity |
| 40–50 min | Demo: Assign RBAC, create Managed Identity, show MSI token |
| 50–60 min | Q&A + Homework |

### Concept: Mental Model

```
TWO TYPES OF IDENTITY IN AZURE:

  HUMAN IDENTITY           SERVICE IDENTITY
  ─────────────────────────────────────────────────────────
  Person logs into Azure   Your app connecting to Azure SQL
  Uses Entra ID account    Uses Managed Identity
  Multi-Factor Auth (MFA)  No password — Azure manages it
  Gets RBAC roles          Gets RBAC roles
  Logs in via browser/CLI  App gets a token automatically

THE GOLDEN RULE: Services should NEVER use usernames/passwords
                 to connect to Azure services. Use Managed Identity.

WHY: No password = no password to rotate, steal, or accidentally commit to git.
```

### RBAC — Role-Based Access Control

```
RBAC answers: "Who can do what on which resource?"

  WHO   = User, Group, Service Principal, or Managed Identity
  WHAT  = Role (built-in or custom)  e.g., "Storage Blob Data Reader"
  WHERE = Scope: Management Group > Subscription > Resource Group > Resource

Built-in roles developers need to know:
  Owner              → Full control including access management (AVOID on apps)
  Contributor        → Create/manage resources, NO access management
  Reader             → Read-only view
  User Access Admin  → Manage access (not resources)

  Storage Blob Data Contributor    → Read/write blobs
  Storage Queue Data Contributor   → Read/write queue messages
  Key Vault Secrets User           → Read secrets (no write)
  Key Vault Secrets Officer        → Read + write secrets
  Azure Service Bus Data Sender    → Send messages
  Azure Service Bus Data Receiver  → Receive messages
  AcrPull                          → Pull images from Container Registry
  AcrPush                          → Push images to Container Registry
```

### Managed Identity — The Hero of Azure Security

```
SYSTEM-ASSIGNED vs USER-ASSIGNED MANAGED IDENTITY:

  System-Assigned:
    ├── Tied to ONE resource (e.g., one Function App)
    ├── Deleted when the resource is deleted
    └── Use: simple scenarios, one resource

  User-Assigned:
    ├── Standalone resource — can be assigned to MULTIPLE resources
    ├── Survives resource deletion
    └── Use: multiple services sharing the same permissions (preferred)

HOW IT WORKS (no code needed for auth):
  1. You create a Managed Identity for your app
  2. You assign RBAC roles to that identity (e.g., "SQL DB Contributor")
  3. Your app code calls Azure SDK — SDK auto-fetches a token from Azure metadata endpoint
  4. Token used transparently — no password, no key, no rotation needed

C# Code Example:
  // Before Managed Identity (BAD):
  var connStr = "Server=sql.database.windows.net;User=admin;Password=P@ssw0rd!";

  // After Managed Identity (GOOD):
  var credential = new DefaultAzureCredential(); // auto-picks MSI in Azure, developer login locally
  var token = await credential.GetTokenAsync(new TokenRequestContext(
      ["https://database.windows.net/.default"]));
  // EF Core uses this token automatically when configured
```

### Demo Script

```bash
# Create a User-Assigned Managed Identity
az identity create \
  --name id-orders-service-prod \
  --resource-group rg-security-prod

# Get the principal ID (needed for RBAC assignment)
PRINCIPAL_ID=$(az identity show \
  --name id-orders-service-prod \
  --resource-group rg-security-prod \
  --query principalId --output tsv)

# Get the scope (a specific resource group)
SCOPE=$(az group show --name rg-data-prod --query id --output tsv)

# Assign "Key Vault Secrets User" role to the Managed Identity
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Key Vault Secrets User" \
  --scope $SCOPE

# List role assignments to verify
az role assignment list \
  --assignee $PRINCIPAL_ID \
  --output table
```

### Homework
> For any service you own or work on: identify what credentials it currently uses to connect to databases or external services. Are any of those credentials hardcoded? Could Managed Identity replace them?

---

## Session 05 — Azure Key Vault: Secrets, Certificates & Config Management
> Duration: 60 min | Prereqs: Session 04 | Who benefits most: Everyone

### Learning Objectives
- Understand what Key Vault is and what goes in it
- Know how to read secrets in .NET using DefaultAzureCredential
- Understand how to reference Key Vault in App Service / Functions / AKS

### 1-Hour Breakdown

| Time | Activity |
|---|---|
| 0–5 min | Recap Session 04 |
| 5–15 min | Concept: What is Key Vault? What belongs in it? |
| 15–35 min | Deep Dive: Secrets, keys, certs, access model, CSI driver |
| 35–50 min | Demo: Create KV, store secret, read in C#, KV reference in App Settings |
| 50–60 min | Q&A + Homework |

### Concept: Mental Model

```
KEY VAULT = A bank safe managed by Azure.

  YOU      → put sensitive things in
  AZURE    → manages the lock, the building, the keys to the building
  YOUR APP → presents its identity badge (Managed Identity)
             and Azure hands out only what it's allowed to see

WHAT GOES IN KEY VAULT:
  ✅ Database connection strings
  ✅ External API keys (payment gateway, SMS provider, etc.)
  ✅ TLS/SSL certificates
  ✅ Encryption keys (HSM-backed)
  ✅ Storage account keys (until Managed Identity replaces them)

WHAT DOES NOT GO IN KEY VAULT:
  ❌ Non-sensitive config (feature flags, timeouts, URLs without auth)
     → Use Azure App Configuration for those
  ❌ Secrets you've already moved to Managed Identity connections
```

### Three Ways to Use Key Vault in .NET

```csharp
// ── METHOD 1: Direct SDK access (inside application code) ─────────

// Register Key Vault as a configuration source in Program.cs
// WHY: Secrets appear as standard IConfiguration entries — no special code
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{keyVaultName}.vault.azure.net/"),
    new DefaultAzureCredential());  // uses Managed Identity in Azure, dev login locally

// Then read anywhere:
var connStr = builder.Configuration["ConnectionStrings--SqlServer"];
// Key Vault secret named "ConnectionStrings--SqlServer" maps to ConnectionStrings:SqlServer

// ── METHOD 2: App Service / Functions — Key Vault Reference ───────

// In Azure Portal → App Service → Configuration → App Settings:
// Name:  ConnectionStrings__SqlServer
// Value: @Microsoft.KeyVault(SecretUri=https://kv-orders-prod.vault.azure.net/secrets/SqlConnectionString)
// Result: App Service fetches the secret at startup — your code reads it as a normal env var

// ── METHOD 3: AKS — CSI Driver (mounts secret as env var or file) ─

# SecretProviderClass tells the CSI driver what to fetch from Key Vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: orders-secrets
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: "{managed-identity-client-id}"
    keyvaultName: "kv-orders-prod"
    objects: |
      array:
        - |
          objectName: SqlConnectionString
          objectType: secret
```

### Demo Script

```bash
# Create Key Vault
az keyvault create \
  --name kv-training-dev \
  --resource-group rg-security-dev \
  --location eastus \
  --enable-purge-protection true \
  --enable-soft-delete true \
  --retention-days 90

# Store a secret
az keyvault secret set \
  --vault-name kv-training-dev \
  --name SqlConnectionString \
  --value "Server=tcp:sql-orders.database.windows.net;Authentication=Active Directory Default;"

# Assign Managed Identity permission to read secrets
az keyvault set-policy \
  --name kv-training-dev \
  --object-id {managed-identity-principal-id} \
  --secret-permissions get list

# List secrets (shows names only — values never shown in CLI list)
az keyvault secret list --vault-name kv-training-dev --output table

# Get a secret value (for debugging — never in application code)
az keyvault secret show --vault-name kv-training-dev --name SqlConnectionString --query value
```

### Homework
> Audit one service: find every place where a connection string, API key, or password is stored (appsettings.json, environment variables, pipeline variables). Write down a migration plan to move each one to Key Vault.

---

---

# WEEK 2 — Compute: Running Your Code on Azure

---

## Session 06 — Azure App Service: Deploy a .NET API
> Duration: 60 min | Prereqs: Sessions 01–05 | Who benefits most: Junior/Mid devs

### Learning Objectives
- Understand what App Service is and when to choose it
- Deploy a .NET Minimal API to App Service via CLI and GitHub Actions
- Understand deployment slots for zero-downtime deployments

### 1-Hour Breakdown

| Time | Activity |
|---|---|
| 0–5 min | Recap Week 1 key points |
| 5–15 min | Concept: App Service — what it is, tiers, when to use |
| 15–35 min | Deep Dive: Deployment, VNet integration, slots, scale-out |
| 35–50 min | Demo: Deploy a .NET API to App Service via CLI |
| 50–60 min | Q&A + Homework |

### Concept: When to Choose App Service

```
CHOOSE APP SERVICE WHEN:
  ✅ You have a .NET web app or API and want simplicity
  ✅ Team is new to Azure — lowest ops overhead of all compute options
  ✅ No container orchestration complexity needed
  ✅ Built-in autoscale, deployment slots, health checks are sufficient

SKIP APP SERVICE WHEN:
  ❌ You need container orchestration (→ AKS)
  ❌ You need per-event billing (→ Functions)
  ❌ You need complex networking between many services (→ AKS)
  ❌ Your workload runs in containers and needs sidecar patterns (→ AKS/Container Apps)

TIER GUIDE:
  Free/Shared  → Dev only, no SLA, shared compute, no VNet
  Basic        → Dev/test, no autoscale, no deployment slots
  Standard     → Production minimum, autoscale, 5 slots, VNet
  Premium v3   → Production recommended, AZ redundancy, better perf
```

### Key Developer Concepts

```
DEPLOYMENT SLOTS:
  staging slot → test your new version here
  production slot → live traffic goes here
  SWAP operation → staging becomes production INSTANTLY with zero downtime
  If something breaks → SWAP BACK in under 30 seconds

ALWAYS ON:
  Default: App sleeps after 20 min of inactivity → cold start on next request
  Always On: Enabled → app always warm (required for production)

VNET INTEGRATION:
  Outbound: App Service can reach resources in your VNet (SQL, Redis)
  Inbound: Use Private Endpoint to make App Service private (no public URL)
```

### Demo Script

```bash
# Create App Service Plan
az appservice plan create \
  --name asp-orders-prod \
  --resource-group rg-compute-prod \
  --sku P1v3 \
  --is-linux

# Create Web App for .NET 9
az webapp create \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod \
  --plan asp-orders-prod \
  --runtime "DOTNETCORE:9.0"

# Enable Managed Identity
az webapp identity assign \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod

# Configure Key Vault reference as App Setting
az webapp config appsettings set \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod \
  --settings "ConnectionStrings__Sql=@Microsoft.KeyVault(SecretUri=https://kv-orders-prod.vault.azure.net/secrets/SqlConn)"

# Enable VNet Integration
az webapp vnet-integration add \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod \
  --vnet vnet-orders-prod \
  --subnet functions-subnet

# Create a staging deployment slot
az webapp deployment slot create \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod \
  --slot staging

# Deploy via zip (or GitHub Actions — show both)
az webapp deploy \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod \
  --slot staging \
  --src-path ./publish.zip \
  --type zip

# Swap staging → production (zero-downtime)
az webapp deployment slot swap \
  --name app-orders-prod-eus \
  --resource-group rg-compute-prod \
  --slot staging \
  --target-slot production
```

### Homework
> Take any existing .NET API from our codebase. Create an App Service in your dev subscription. Deploy it. Verify the /health endpoint responds. Show us next session.

---

## Session 07 — Azure Container Apps: Containers Without Kubernetes Ops
> Duration: 60 min | Prereqs: Session 06 + basic Docker knowledge

### Learning Objectives
- Understand Azure Container Apps and when to choose it over AKS or App Service
- Deploy a containerized .NET app with KEDA-based auto-scaling
- Understand environments, revisions, and Dapr basics

### Concept

```
CONTAINER APPS = "Kubernetes features without managing Kubernetes"

  ✅ Run containers                     (like AKS)
  ✅ KEDA-based auto-scaling            (like AKS)
  ✅ Scale to zero                      (like Functions)
  ✅ No cluster management              (unlike AKS)
  ✅ Ingress built-in                   (unlike raw AKS)
  ✅ Revision management (canary/A-B)   (unique)
  ✅ Dapr sidecar support               (unique)

CHOOSE CONTAINER APPS WHEN:
  Team wants containers but nobody owns K8s operations
  You need scale-to-zero for cost optimization
  You want Dapr service-to-service calls out of the box

SKIP CONTAINER APPS WHEN:
  You need direct control over K8s primitives (custom CRDs, etc.)
  You have complex multi-cluster needs
  You need Windows containers
```

### Key Concepts: Revisions & Traffic Splitting

```
REVISION = An immutable snapshot of your container app

  v1 revision ──→ 90% of traffic  (current stable)
  v2 revision ──→ 10% of traffic  (canary testing)

  When v2 is validated:
  → Shift 100% traffic to v2
  → Deactivate v1

This is blue-green / canary deployment built into the platform.
```

### Demo Script

```bash
# Create Container Apps Environment with VNet
az containerapp env create \
  --name cae-orders-prod \
  --resource-group rg-compute-prod \
  --location eastus \
  --infrastructure-subnet-resource-id {subnet-id}

# Deploy a container app
az containerapp create \
  --name ca-orders-api \
  --resource-group rg-compute-prod \
  --environment cae-orders-prod \
  --image acr-company-prod.azurecr.io/orders-api:v1.0.0 \
  --target-port 8080 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 20 \
  --scale-rule-name servicebus-scaler \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata "queueName=orders-queue" "messageCount=10"

# Update to new image version (creates a new revision)
az containerapp update \
  --name ca-orders-api \
  --resource-group rg-compute-prod \
  --image acr-company-prod.azurecr.io/orders-api:v1.1.0

# Split traffic: 90% old, 10% new
az containerapp ingress traffic set \
  --name ca-orders-api \
  --resource-group rg-compute-prod \
  --revision-weight ca-orders-api--v1=90 ca-orders-api--v2=10
```

### Homework
> Containerize any simple .NET service (or use the one from Session 06). Build it with docker build, push to ACR, deploy as a Container App. Verify it scales when load is applied.

---

## Session 08 — AKS Part 1: Kubernetes on Azure, Cluster Setup & Workloads
> Duration: 60 min | Prereqs: Sessions 03–05 + Docker basics

### Learning Objectives
- Understand Kubernetes core concepts from a developer perspective
- Understand AKS-specific features (private cluster, OIDC, Workload Identity)
- Deploy a Deployment + Service + ConfigMap to AKS

### Concept: Kubernetes Mental Model for Developers

```
KUBERNETES OBJECTS developers need to know:

  POD          = one running container (or a few sidecar containers)
               = the smallest deployable unit
               = ephemeral — can die and be replaced anytime

  DEPLOYMENT   = "I want 3 replicas of my pod, always"
               = manages rolling updates and rollbacks

  SERVICE      = stable DNS name + IP for a set of pods
               = ClusterIP: internal only
               = LoadBalancer: gets an Azure public/internal IP

  INGRESS      = HTTP routing: /api/orders → orders-service:80
               = L7 load balancer inside the cluster

  CONFIGMAP    = non-sensitive config (URLs, feature flags)
  SECRET       = sensitive config (but prefer Key Vault CSI driver)

  NAMESPACE    = logical isolation within a cluster
               = separate namespaces per team or service
```

### AKS-Specific Features (talk track for developers)

```
PRIVATE CLUSTER
  The Kubernetes API server has no public IP.
  You access it via VPN, Bastion, or a jump-box in the VNet.
  WHY: The API server is the control plane — exposing it publicly is risky.

WORKLOAD IDENTITY
  Your pod gets a Kubernetes Service Account.
  That KSA is federated with an Azure Managed Identity.
  The pod can call Azure APIs (SQL, Key Vault, Service Bus) with no passwords.
  WHY: Same zero-secret philosophy as Managed Identity, but inside AKS.

AZURE CNI OVERLAY
  Each pod gets an IP from a virtual overlay network (not your VNet range).
  WHY: Saves VNet IP addresses — standard CNI uses one VNet IP per pod.

NODE POOLS
  System pool: runs Kubernetes system pods (kube-dns, metrics-server)
  User pools: runs YOUR application pods
  WHY: Taints on system pool prevent your pods from scheduling there.
```

### Demo Script: Deploy to AKS

```yaml
# orders-deployment.yaml

# ── Deployment ────────────────────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-api
  namespace: orders-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: orders-api
  template:
    metadata:
      labels:
        app: orders-api
        azure.workload.identity/use: "true"  # enables Workload Identity
    spec:
      serviceAccountName: sa-orders          # bound to Azure Managed Identity
      containers:
        - name: orders-api
          image: acr-company-prod.azurecr.io/orders-api:a1b2c3d  # SHA tag
          ports:
            - containerPort: 8080
          resources:
            requests: { cpu: "250m", memory: "256Mi" }
            limits:   { cpu: "1000m", memory: "512Mi" }
          readinessProbe:
            httpGet: { path: /health/ready, port: 8080 }
            initialDelaySeconds: 10
          livenessProbe:
            httpGet: { path: /health/live, port: 8080 }
            initialDelaySeconds: 30
---
# ── Service ──────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: orders-api
  namespace: orders-prod
spec:
  selector:
    app: orders-api
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP   # internal only — Ingress handles external routing
```

```bash
# Get AKS credentials
az aks get-credentials --name aks-orders-prod --resource-group rg-compute-prod

# Apply the manifest
kubectl apply -f orders-deployment.yaml

# Watch rollout
kubectl rollout status deployment/orders-api -n orders-prod

# Scale manually
kubectl scale deployment/orders-api --replicas=5 -n orders-prod

# Check pod logs
kubectl logs -l app=orders-api -n orders-prod --tail=50

# Exec into a pod for debugging
kubectl exec -it {pod-name} -n orders-prod -- /bin/sh
```

### Homework
> Write a Deployment + Service manifest for any service. Deploy it to a dev AKS cluster. Show kubectl get pods and kubectl get svc output. Bonus: Add a readiness probe.

---

## Session 09 — AKS Part 2: Networking, Scaling, Security & Ingress
> Duration: 60 min | Prereqs: Session 08

### Learning Objectives
- Understand HPA, KEDA, and Cluster Autoscaler
- Configure NGINX Ingress for HTTP routing
- Apply Network Policies and Pod Security

### Key Topics

**HPA (Horizontal Pod Autoscaler)**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: orders-api-hpa
  namespace: orders-prod
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: orders-api
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70  # scale out when CPU > 70%
```

**KEDA (Event-Driven Scale)**
```yaml
# Scale pods based on Service Bus queue depth — not CPU
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: orders-processor-scaler
  namespace: orders-prod
spec:
  scaleTargetRef:
    name: orders-processor
  minReplicaCount: 0   # scale to ZERO when queue is empty
  maxReplicaCount: 50
  triggers:
    - type: azure-servicebus
      metadata:
        queueName: orders-queue
        messageCount: "10"  # 1 pod per 10 messages
```

**NGINX Ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: orders-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  tls:
    - hosts: [api.company.com]
      secretName: tls-api-company-com
  rules:
    - host: api.company.com
      http:
        paths:
          - path: /orders
            pathType: Prefix
            backend:
              service:
                name: orders-api
                port: { number: 80 }
```

**Network Policy (deny-all default)**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: orders-prod
spec:
  podSelector: {}     # applies to ALL pods in namespace
  policyTypes:
    - Ingress
  # No ingress rules = deny all inbound traffic to all pods
```

---

## Session 10 — Azure Functions: Serverless Event-Driven Programming
> Duration: 60 min | Prereqs: Sessions 04–05

### Learning Objectives
- Understand when Functions is the right choice
- Know the trigger types and when to use each
- Understand Durable Functions for long-running workflows

### Concept: When to Choose Functions

```
CHOOSE FUNCTIONS WHEN:
  ✅ Event-driven work (process message, respond to blob upload)
  ✅ Scheduled batch jobs (timer trigger)
  ✅ Variable/unpredictable load — pay only for executions
  ✅ Short-lived operations (< 10 min unless Durable)
  ✅ Glue code between services

TRIGGER TYPES:
  HTTP Trigger     → REST API endpoint (APIM calls this)
  Timer Trigger    → Runs on CRON schedule  "0 */5 * * * *"
  Service Bus Trigger → Processes messages from queue/topic
  Blob Trigger     → Fires when a file is uploaded to Storage
  Event Grid       → Reacts to any Azure resource event
  Event Hub        → Processes high-volume streaming events
  Cosmos DB        → Reacts to document changes (Change Feed)
```

### Key Patterns

```csharp
// ── Timer Trigger — Scheduled Job ────────────────────────────────
[Function("DailyReportGenerator")]
public async Task RunDailyReport(
    [TimerTrigger("0 0 6 * * *")] TimerInfo timer,  // every day at 6 AM
    CancellationToken ct)
{
    _logger.LogInformation("Daily report started at {Time}", DateTime.UtcNow);
    await _reportService.GenerateAsync(ct);
}

// ── Service Bus Trigger — Process Order Message ───────────────────
[Function("ProcessOrderMessage")]
public async Task ProcessOrder(
    [ServiceBusTrigger("orders-topic", "fulfillment-sub",
        Connection = "ServiceBusConnection")]
    ServiceBusReceivedMessage message,
    ServiceBusMessageActions actions,
    CancellationToken ct)
{
    var order = JsonSerializer.Deserialize<OrderMessage>(message.Body);
    try
    {
        await _fulfillmentService.FulfillAsync(order, ct);
        await actions.CompleteMessageAsync(message, ct);  // ✅ success
    }
    catch (TransientException)
    {
        await actions.AbandonMessageAsync(message, ct);   // retry
    }
}

// ── Durable Orchestrator — Multi-Step Workflow ────────────────────
[Function("OrderProcessingOrchestrator")]
public async Task<string> RunOrchestration(
    [OrchestrationTrigger] TaskOrchestrationContext context)
{
    var orderId = context.GetInput<string>();

    // WHY: Orchestrator is deterministic — all side effects in Activities
    await context.CallActivityAsync("ValidateInventory", orderId);
    await context.CallActivityAsync("ChargePayment", orderId);
    await context.CallActivityAsync("SendConfirmationEmail", orderId);

    return "completed";
}
```

### Homework
> Write a Service Bus-triggered Function that reads an "order" message, logs the order ID, and completes the message. Deploy it with Managed Identity authentication to Service Bus (no connection string password).

---

---

# WEEK 3 — Data Layer

---

## Session 11 — Azure SQL Database: Managed Relational DB for Developers
> Duration: 60 min | Prereqs: Sessions 03–05

### Learning Objectives
- Understand Azure SQL tiers and HA options
- Connect using Managed Identity (no passwords)
- Understand EF Core migration best practices on Azure SQL

### Concept: Azure SQL vs SQL Server

```
SQL SERVER (on-prem / VM)          AZURE SQL DATABASE (PaaS)
──────────────────────────────────────────────────────────────
You patch the OS                   Azure patches automatically
You manage backups                 Azure backs up automatically (35 day PITR)
You configure HA (Always On)       Azure has built-in HA (ZR option)
You size the server                DTU or vCore model — you pick compute
You manage failover                Failover Groups — automatic or manual
Single machine                     Business Critical = 4 readable replicas

WHY PaaS WINS: 80% of DBA work is eliminated.
```

### Connecting with Managed Identity (no password)

```csharp
// Program.cs — EF Core + Managed Identity
builder.Services.AddDbContext<OrdersDbContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("Sql"),
        sqlOptions =>
        {
            // WHY: Add resilience for transient SQL errors (deadlocks, timeouts)
            sqlOptions.EnableRetryOnFailure(
                maxRetryCount: 5,
                maxRetryDelay: TimeSpan.FromSeconds(30),
                errorNumbersToAdd: null);
        });
});

// Connection string in appsettings (NO PASSWORD — MSI handles auth):
// "Server=tcp:sql-orders-prod.database.windows.net;
//  Authentication=Active Directory Default;Database=orders-db;"

// In Azure SQL, create the user for your Managed Identity:
// CREATE USER [id-orders-service-prod] FROM EXTERNAL PROVIDER;
// ALTER ROLE db_datareader ADD MEMBER [id-orders-service-prod];
// ALTER ROLE db_datawriter ADD MEMBER [id-orders-service-prod];
```

### EF Core Migration Strategy on Azure

```
NEVER run dotnet ef database update in production from your machine.

CORRECT APPROACH:
  Option A: Pipeline runs migrations before deploying the app
    - "dotnet ef database update" step in CI/CD pipeline
    - Pipeline identity has db_owner on the database (not the app identity)

  Option B: App applies migrations at startup (small teams/dev)
    - context.Database.MigrateAsync() in Program.cs
    - Simple but risky at scale (migration timeout on large tables)

  Option C: Generate SQL script, apply via DBA-reviewed PR
    - dotnet ef migrations script → reviewed SQL → applied by DBA
    - Best for production compliance environments

EXPAND-CONTRACT for zero-downtime:
  Never drop a column in the same release that stops writing to it.
  Step 1: Deploy new code that ignores the old column
  Step 2: Drop the column in next release
```

---

## Session 12 — Azure Cosmos DB: Globally Distributed NoSQL
> Duration: 60 min | Prereqs: Session 03–05

### Learning Objectives
- Understand Cosmos DB data model and partition key design
- Know consistency levels and when to use each
- Query with .NET SDK using LINQ

### Concept: Mental Model

```
COSMOS DB = A distributed document database that spans the globe

  ACCOUNT  → the top-level resource
  DATABASE → logical grouping (like a schema in SQL)
  CONTAINER→ where documents live (like a table — but schema-flexible)
  DOCUMENT → JSON document (like a row — but any shape)

PARTITION KEY = the field that determines which physical partition stores the document
  Good partition key: CustomerId, TenantId, OrderId
  Bad partition key: OrderStatus (only 5 values = hot partition)

RULE: All documents with the same partition key live on the same physical partition.
      Cross-partition queries are expensive — design to avoid them.
```

### Consistency Levels (choose ONE per account, override per request)

```
STRONG           → Read always sees latest write (highest latency, highest cost)
BOUNDED STALENESS→ Read may lag behind by N seconds or N operations (configurable)
SESSION          → Within your client session, reads always see your own writes ← DEFAULT, USE THIS
CONSISTENT PREFIX→ Reads never see out-of-order writes
EVENTUAL         → Reads may be stale but fastest and cheapest

DEVELOPER GUIDE:
  User-facing reads/writes  → SESSION consistency (reads own writes guaranteed)
  Analytics / reports       → EVENTUAL consistency (slight staleness OK, cheaper)
  Financial transactions    → STRONG (if truly needed, otherwise Saga + SESSION)
```

### Code Example

```csharp
// ── Cosmos DB SDK with Managed Identity ──────────────────────────

var client = new CosmosClient(
    "https://cosmos-orders-prod.documents.azure.com:443/",
    new DefaultAzureCredential());  // Managed Identity — no key!

var container = client.GetContainer("orders-db", "orders");

// Write a document
var order = new Order { Id = "ord-123", CustomerId = "cust-456", Status = "Pending" };
await container.CreateItemAsync(order,
    new PartitionKey(order.CustomerId));  // partition key must be specified

// Read by ID (fast — single partition)
var response = await container.ReadItemAsync<Order>(
    "ord-123",
    new PartitionKey("cust-456"));

// Query (include partition key in WHERE to avoid cross-partition scan)
var query = new QueryDefinition(
    "SELECT * FROM c WHERE c.customerId = @customerId AND c.status = @status")
    .WithParameter("@customerId", "cust-456")
    .WithParameter("@status", "Pending");

using var iterator = container.GetItemQueryIterator<Order>(query,
    requestOptions: new() { PartitionKey = new PartitionKey("cust-456") });

while (iterator.HasMoreResults)
{
    var page = await iterator.ReadNextAsync();
    foreach (var item in page) { /* process */ }
}
```

---

## Session 13 — Azure Cache for Redis: Caching Patterns & Session State
> Duration: 60 min | Prereqs: Sessions 11–12

### Key Topics

**Cache-Aside Pattern** (most common)
```csharp
public async Task<OrderDto?> GetOrderAsync(string orderId, CancellationToken ct)
{
    var cacheKey = $"order:{orderId}";

    // 1. Try cache first
    var cached = await _cache.GetStringAsync(cacheKey, ct);
    if (cached is not null)
        return JsonSerializer.Deserialize<OrderDto>(cached);

    // 2. Cache miss — go to DB
    var order = await _repository.GetByIdAsync(orderId, ct);
    if (order is null) return null;

    // 3. Store in cache with expiry
    // WHY: 5-min TTL balances freshness vs DB load reduction
    await _cache.SetStringAsync(cacheKey,
        JsonSerializer.Serialize(order),
        new DistributedCacheEntryOptions
            { SlidingExpiration = TimeSpan.FromMinutes(5) },
        ct);

    return order;
}
```

**When to use Redis vs in-memory cache:**
- `IMemoryCache` → single instance only (useless when scaled to 3 pods)
- `IDistributedCache` (Redis) → shared across all pod instances ← use this in Azure

---

## Session 14 — Azure Blob Storage: Files, Objects & Lifecycle Management
> Duration: 60 min | Prereqs: Sessions 03–05

### Key Topics

```csharp
// ── Upload with Managed Identity ─────────────────────────────────
var blobServiceClient = new BlobServiceClient(
    new Uri("https://storders-prod.blob.core.windows.net"),
    new DefaultAzureCredential());

var containerClient = blobServiceClient.GetBlobContainerClient("uploads");
var blobClient = containerClient.GetBlobClient($"invoices/{orderId}.pdf");

await using var stream = File.OpenRead(localFilePath);
await blobClient.UploadAsync(stream, overwrite: true);

// ── Generate a short-lived SAS URL for client download ───────────
// WHY: Never expose your storage account key in the front-end
//      Generate a SAS token server-side, return to client
var sasBuilder = new BlobSasBuilder
{
    BlobContainerName = "uploads",
    BlobName = $"invoices/{orderId}.pdf",
    Resource = "b",
    ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(15)
};
sasBuilder.SetPermissions(BlobSasPermissions.Read);
var sasUri = blobClient.GenerateSasUri(sasBuilder);
return sasUri.ToString();
```

---

---

# WEEK 4 — Messaging & Integration

---

## Session 15 — Azure Service Bus: Reliable Async Messaging
> Duration: 60 min | Prereqs: Sessions 04–05

### Learning Objectives
- Understand queues vs topics vs subscriptions
- Implement the Outbox pattern for guaranteed delivery
- Understand DLQ and idempotency

### Concept: Mental Model

```
SERVICE BUS = A guaranteed postal service between services

  QUEUE    = One sender → One receiver  (point-to-point)
  TOPIC    = One sender → Many receivers (pub/sub via subscriptions)
  DLQ      = The "undeliverable mail" pile — messages that failed too many times

THE GUARANTEE: Service Bus holds a message until the receiver
               explicitly says "I processed it successfully" (Complete).
               If receiver crashes, Service Bus redelivers it.

WHY THIS MATTERS:
  Without Service Bus: Orders service calls Inventory service directly.
                       If Inventory is down → order is lost.
  With Service Bus:    Orders service sends to bus.
                       Bus holds message until Inventory is ready.
                       No data loss. Services are decoupled.
```

### Outbox Pattern (most important integration pattern)

```
PROBLEM: Your code does this:
  1. Save order to DB
  2. Publish "OrderPlaced" message to Service Bus
  
  What if step 2 fails? DB has the order but no message was sent.
  What if crash happens between step 1 and 2?

SOLUTION: Outbox Pattern
  1. Save order to DB + save message to OutboxMessages table (ONE transaction)
  2. Background worker reads OutboxMessages table and publishes to Service Bus
  3. Mark message as Published after successful send

This guarantees: either both the order AND the message are saved, or neither.
```

```csharp
// ── OutboxMessage table entity ────────────────────────────────────
public class OutboxMessage
{
    public Guid Id { get; set; }
    public string MessageType { get; set; } = default!;
    public string Payload { get; set; } = default!;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset? PublishedAt { get; set; }
}

// ── Command Handler — one transaction for DB + outbox ────────────
public async Task Handle(PlaceOrderCommand cmd, CancellationToken ct)
{
    var order = Order.Create(cmd.CustomerId, cmd.Items);
    await _orders.AddAsync(order, ct);

    // Write to Outbox in SAME DB transaction — never lost
    await _outbox.AddAsync(new OutboxMessage {
        Id = Guid.NewGuid(),
        MessageType = "OrderPlaced",
        Payload = JsonSerializer.Serialize(new { order.Id, order.CustomerId }),
        CreatedAt = DateTimeOffset.UtcNow
    }, ct);

    await _uow.SaveChangesAsync(ct);  // atomic commit
}

// ── Background Worker publishes from Outbox ───────────────────────
// Polls OutboxMessages WHERE PublishedAt IS NULL
// Sends to Service Bus
// Updates PublishedAt = now
```

---

## Session 16 — Azure Event Hubs: High-Throughput Event Streaming
> Duration: 60 min | Prereqs: Session 15

### Concept: Service Bus vs Event Hubs

```
┌─────────────────────────────────────────────────────────────────────┐
│              SERVICE BUS              │         EVENT HUBS           │
├───────────────────────────────────────┼──────────────────────────────┤
│ Reliable delivery guaranteed          │ Best-effort + retention log  │
│ One receiver per message              │ Multiple consumer groups     │
│ Max 1 MB per message                  │ Up to 1 MB per event         │
│ 80 GB max storage                     │ Days/weeks of log retention  │
│ DLQ built-in                          │ No DLQ concept               │
│ Use: business commands & events       │ Use: telemetry, logs, streams│
│ Examples: PlaceOrder, PaymentFailed   │ Examples: IoT, click events  │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Concept: Consumer Groups & Partitions

```
PARTITION = independent ordered stream of events
  → Events in the same partition are ordered
  → One consumer reads from one partition at a time

CONSUMER GROUP = independent "cursor" in the log
  → analytics-consumer group reads at its own pace
  → monitoring-consumer group reads at its own pace
  → Both see ALL events, independently

ANALOGY: Event Hubs is like a TV broadcast (everyone sees it)
         Service Bus is like a phone call (one person gets it)
```

---

## Session 17 — Azure Event Grid: Reactive Cloud Events
> Duration: 60 min | Prereqs: Session 15

### Concept

```
EVENT GRID = Azure's routing layer for events between services

  Source (publisher) → Event Grid Topic → Subscription → Handler (subscriber)

SYSTEM TOPICS (built-in Azure events):
  Blob Storage → "BlobCreated" → trigger an Azure Function to process it
  Resource Group → "ResourceDeleted" → notify compliance team

CUSTOM TOPICS (your domain events):
  Orders service → "OrderPlaced" → Notification service + Audit service

PUSH vs PULL:
  Push: Event Grid delivers to your webhook/Function/Queue
  Pull: Your service polls Event Grid namespace queue (newer model)
```

---

## Session 18 — API Management (APIM): The Front Door for Your APIs
> Duration: 60 min | Prereqs: Sessions 03–05

### Concept: Why APIM?

```
WITHOUT APIM:
  Client → directly hits Orders Service IP
  Client → directly hits Payments Service IP
  Each service handles: auth, rate limiting, CORS, logging, versioning
  → Duplicated cross-cutting concern logic everywhere

WITH APIM:
  Client → APIM → Orders Service (internal private IP)
  Client → APIM → Payments Service (internal private IP)
  APIM handles: auth, rate limiting, CORS, logging, versioning ONCE
  → Services focus on business logic only
  → Clients see a single, consistent API surface
```

### Key Policy Examples

```xml
<!-- Global policy — applies to ALL APIs -->
<policies>
  <inbound>
    <!-- WHY: Validate JWT from Entra ID before any backend is called -->
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401">
      <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-config"/>
      <required-claims>
        <claim name="aud" match="any">
          <value>api://orders-api</value>
        </claim>
      </required-claims>
    </validate-jwt>

    <!-- WHY: Rate limit prevents any single client from overwhelming backends -->
    <rate-limit-by-key calls="1000" renewal-period="60"
      counter-key="@(context.Subscription.Id)" />

    <!-- WHY: Inject correlation ID so all downstream logs are traceable -->
    <set-header name="X-Correlation-Id" exists-action="skip">
      <value>@(Guid.NewGuid().ToString())</value>
    </set-header>
  </inbound>

  <outbound>
    <!-- WHY: Remove server header — don't reveal technology stack -->
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
</policies>
```

---

## Session 19 — Azure Front Door & WAF: Global Edge and Security
> Duration: 60 min | Prereqs: Session 18

### Concept

```
FRONT DOOR = Azure's global CDN + Load Balancer + WAF combined

  User in India → Azure Front Door POP in Mumbai → routes to nearest backend
  User in UK    → Azure Front Door POP in London  → routes to nearest backend

WHAT IT DOES:
  ✅ Global HTTP load balancing (route to nearest healthy region)
  ✅ SSL termination at the edge (backend serves HTTP internally)
  ✅ WAF (Web Application Firewall) — blocks SQL injection, XSS, bots
  ✅ DDoS mitigation at the edge
  ✅ Caching for static content
  ✅ URL path-based routing  /api/* → APIM,  /* → Static website

WAF RULE SETS:
  DefaultRuleSet_2.1    → OWASP Top 10 rules (SQLi, XSS, etc.)
  BotManagerRuleSet_1.0 → Blocks known bad bots, scrapers, scanners

MODES:
  Detection  → Logs threats but doesn't block — USE FOR INITIAL TUNING ONLY
  Prevention → Actively blocks requests matching rules — PRODUCTION MODE
```

---

---

# WEEK 5 — Security, Observability, DevOps & Architecture

---

## Session 20 — Azure Security Deep Dive: Defender, Policy & Zero Trust
> Duration: 60 min | Prereqs: Sessions 03–05 + 19

### Key Topics

**Zero Trust Principles (applied to Azure)**
```
NEVER TRUST, ALWAYS VERIFY:
  1. Verify identity explicitly → Entra ID + MFA for all access
  2. Use least privilege access → Minimum RBAC roles only
  3. Assume breach → Segment everything, audit all access

NETWORK: Don't trust the network — use private endpoints and NSGs even inside VNet
IDENTITY: Don't trust the caller — validate JWT on every request (APIM + backend)
DATA: Don't trust the storage — encrypt at rest (TDE-CMK) and in transit (TLS 1.2+)
```

**Microsoft Defender for Cloud — Your Security Dashboard**
```
WHAT IT DOES:
  → Scans all your resources for misconfigurations
  → Scores you 0–100 (Secure Score)
  → Gives prioritized recommendations
  → Alerts on real threats (unusual login, SQL injection attempt)

PLANS TO ENABLE FOR A .NET + AZURE APP:
  Defender for Containers (AKS image scanning, runtime protection)
  Defender for Databases   (SQL threat detection, unusual queries)
  Defender for Key Vault   (detect unusual secret access patterns)
  Defender for App Service (detect web app attacks)
```

---

## Session 21 — Azure Monitor, App Insights & Log Analytics
> Duration: 60 min | Prereqs: Sessions 06–10

### Learning Objectives
- Implement structured logging in .NET with OpenTelemetry
- Query logs with KQL in Log Analytics
- Set up alerts with runbooks

### Structured Logging in .NET

```csharp
// Program.cs — wire up OpenTelemetry
builder.Services.AddOpenTelemetry()
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddEntityFrameworkCoreInstrumentation()
        .AddAzureMonitorTraceExporter())
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddAzureMonitorMetricExporter())
    .WithLogging(logging => logging
        .AddAzureMonitorLogExporter());

// In any service — structured logging (NOT string interpolation!)
// ❌ Wrong:
_logger.LogInformation($"Order {orderId} placed for customer {customerId}");

// ✅ Correct: named placeholders — queryable in KQL
_logger.LogInformation("Order {OrderId} placed for {CustomerId}", orderId, customerId);
```

### KQL (Kusto Query Language) — Top 5 Queries Every Developer Needs

```kql
// 1. All errors in the last hour from orders service
exceptions
| where timestamp > ago(1h)
| where cloud_RoleName == "orders-api"
| project timestamp, message, outerMessage, type
| order by timestamp desc

// 2. P95 latency per endpoint
requests
| where timestamp > ago(1h)
| summarize percentile(duration, 95) by name
| order by percentile_duration_95 desc

// 3. Find all requests that touched a specific order
union requests, traces, exceptions, dependencies
| where timestamp > ago(24h)
| where * has "ord-12345"          // search all tables for this order ID
| project timestamp, itemType, message, name
| order by timestamp asc

// 4. Error rate over time
requests
| where timestamp > ago(6h)
| summarize
    total = count(),
    failed = countif(resultCode >= "500")
  by bin(timestamp, 5m)
| extend errorRate = failed * 100.0 / total
| render timechart

// 5. Service Bus DLQ messages (from diagnostic logs)
AzureDiagnostics
| where ResourceType == "NAMESPACES" and Category == "DeadletterMessages"
| where TimeGenerated > ago(1h)
| project TimeGenerated, entityName_s, messageId_g, deadLetterReason_s
```

### Setting Up Alerts

```
Alert Rule Components:
  Signal    → What to measure (metric or log query)
  Condition → When to fire (error rate > 1% for 5 min)
  Action    → What to do when it fires (notify Teams, trigger runbook)
  Severity  → 0=Critical, 1=Error, 2=Warning, 3=Informational

RULE: Every alert must have a runbook URL in its description.
      An alert without a runbook is an on-call engineer's nightmare.
```

---

## Session 22 — Azure DevOps & GitHub Actions: CI/CD Pipelines
> Duration: 60 min | Prereqs: Sessions 05–06

### Learning Objectives
- Build a complete CI/CD pipeline for a .NET + AKS workload
- Understand environment-based approvals and gates
- Implement Workload Identity Federation (no stored secrets in pipelines)

### Complete CI Pipeline (GitHub Actions)

```yaml
name: CI — Build, Test, Scan, Push

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  id-token: write     # WHY: Required for Workload Identity Federation
  contents: read

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET 9
        uses: actions/setup-dotnet@v4
        with: { dotnet-version: '9.x' }

      - name: Build
        run: dotnet build --configuration Release

      - name: Unit Tests
        run: dotnet test --configuration Release --no-build

      - name: Vulnerability Scan
        run: dotnet list package --vulnerable --highest-patch

      - name: Login to Azure (Workload Identity — NO SECRETS!)
        uses: azure/login@v2
        with:
          client-id: ${{ vars.AZURE_CLIENT_ID }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.AZURE_SUBSCRIPTION_ID }}

      - name: Login to ACR
        run: az acr login --name acr-company-prod

      - name: Build & Push Docker Image
        run: |
          IMAGE=acr-company-prod.azurecr.io/orders-api:${{ github.sha }}
          docker build -t $IMAGE .
          docker push $IMAGE

      - name: Scan Image (Trivy)
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: acr-company-prod.azurecr.io/orders-api:${{ github.sha }}
          severity: HIGH,CRITICAL
          exit-code: '1'   # fail pipeline on HIGH vulnerabilities
```

---

## Session 23 — Infrastructure as Code: Bicep & Terraform
> Duration: 60 min | Prereqs: Sessions 01–05

### Concept: Why IaC?

```
WITHOUT IaC (ClickOps):
  → Infrastructure is undocumented — only the person who clicked knows what's there
  → Cannot reproduce the environment in another region or subscription
  → One person's portal mistake takes down production
  → Auditors cannot see what changed, when, and who changed it

WITH IaC (Bicep/Terraform):
  → Infrastructure is code — reviewed in PRs, versioned in git
  → Any environment can be recreated in minutes
  → Changes are planned (terraform plan) before applied
  → Change history is in git blame
```

### Bicep Example (Azure SQL with Private Endpoint)

```bicep
// sql-database.bicep

param sqlServerName string
param location string = resourceGroup().location
param administratorObjectId string  // Entra ID group object ID

// ── SQL Server ────────────────────────────────────────────────────
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    // WHY: Force Entra ID auth — no SQL username/password allowed
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: 'dba-team'
      sid: administratorObjectId
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: true   // disables SQL auth entirely
    }
    publicNetworkAccess: 'Disabled'     // WHY: private endpoint only
  }
}

// ── SQL Database ──────────────────────────────────────────────────
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: 'orders-db'
  location: location
  sku: {
    name: 'GP_Gen5_2'
    tier: 'GeneralPurpose'
  }
  properties: {
    zoneRedundant: true   // WHY: HA across AZs
    backupStorageRedundancy: 'GeoZone'
  }
}
```

---

## Session 24 — Cloud-Native Architecture Patterns on Azure
> Duration: 60 min | Prereqs: All previous sessions

### Key Patterns Every Developer Must Know

```
PATTERN 1: STRANGLER FIG (migrate monolith to microservices)
  → Put APIM in front of the monolith
  → Route new features to new microservices
  → Gradually strangle the monolith

PATTERN 2: OUTBOX (guaranteed messaging)
  → Atomic DB write + event publish (covered in Session 15)

PATTERN 3: SAGA (distributed transactions without 2PC)
  → Long-running workflow across services using events + compensation

PATTERN 4: CQRS (separate read and write paths)
  → Writes go to SQL → publish event → Cosmos DB read model updated
  → Read queries hit Cosmos DB (optimized for reads)
  → Scale reads and writes independently

PATTERN 5: CIRCUIT BREAKER (fault isolation)
  → If Payment API fails 50% of the time → open circuit
  → Stop calling it for 30 seconds → let it recover
  → Use Polly in .NET for this

PATTERN 6: CLAIM CHECK (large message handling)
  → Message > 256KB is too big for Service Bus
  → Store payload in Blob Storage
  → Put only the blob reference in the message
  → Consumer downloads payload from blob
```

---

## Session 25 — Capstone: Design a Cloud-Native System Together
> Duration: 60 min | Prereqs: All 24 sessions

### Format: Collaborative Design Session

```
SCENARIO (give this to the team):

  "We need to build an Order Management System for a retail company.
   Requirements:
   - REST API for placing orders (< 200ms P99 latency)
   - 10,000 orders/day peak, up to 100,000 on sale days
   - Payments processed via external payment gateway
   - Email + SMS notifications after order confirmation
   - Admin dashboard showing real-time order stats
   - Must be 99.9% available (< 9 hours downtime/year)
   - All data must stay in Australia East region
   - Team of 5 developers, no dedicated Ops team"

WHITEBOARD EXERCISE (30 min):
  Round 1 (10 min): Teams sketch a solution independently
  Round 2 (10 min): Compare approaches — what's different? Why?
  Round 3 (10 min): Build consensus on the best combined approach

ARCHITECTURE BOARD REVIEW (20 min):
  Facilitator asks:
  "Which compute did you choose? Why not the others?"
  "How do you guarantee no order is lost if the payment API is down?"
  "How would you scale from 10K to 100K orders with zero code change?"
  "Where do the secrets live? How does the API connect to the database?"
  "What's your DR plan if Australia East has an outage?"

WRAP UP (10 min):
  Recap the 5-week journey
  Each person names their biggest learning
  Share recording/notes with wider team
  Schedule follow-up sessions on specific deep-dives they want
```

---

## Program Completion Checklist

```
After all 25 sessions, each developer should be able to:

  Foundation
  ☐ Navigate Azure Portal and write basic Azure CLI commands
  ☐ Explain Tenant → Subscription → Resource Group hierarchy
  ☐ Explain why private endpoints matter and how DNS resolution works
  ☐ Assign an RBAC role and explain least privilege

  Identity & Security
  ☐ Create a Managed Identity and assign RBAC roles to it
  ☐ Connect a .NET app to Azure SQL using DefaultAzureCredential
  ☐ Store and reference a Key Vault secret from an app

  Compute
  ☐ Deploy a .NET API to App Service or Container Apps
  ☐ Write a Kubernetes Deployment manifest with health probes
  ☐ Write a Service Bus-triggered Azure Function

  Data & Messaging
  ☐ Connect EF Core to Azure SQL with Managed Identity
  ☐ Implement cache-aside with Redis
  ☐ Implement Outbox pattern with Service Bus

  DevOps & Observability
  ☐ Write a GitHub Actions CI pipeline with Workload Identity
  ☐ Write a KQL query to find errors in App Insights
  ☐ Create an alert rule with an action group

  Architecture
  ☐ Design a simple cloud-native system on a whiteboard
  ☐ Identify and explain at least 3 architecture patterns
  ☐ Participate in an architecture design review
```

---

*Azure Cross-Skilling Program — Facilitator Guide v1.0*
*25 Sessions · 5 Weeks · 1 Hour/Day*
*Audience: Developers (mixed seniority) | Facilitator: Architecture Board*
