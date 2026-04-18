# Azure Architecture Review Guidelines — Principal Engineer Perspective
> Comprehensive, categorized review checkpoints for Azure-native solutions
> Lens: Well-Architected Framework · AKS · Service Bus · Functions · Cosmos · SQL · Key Vault · APIM · Networking · Security · Cost · Reliability

---

## Table of Contents

1. [Mental Model & Review Philosophy](#1-mental-model)
2. [Azure Well-Architected Framework (WAF) Quick Reference](#2-waf-reference)
3. [Category A — Identity & Access Management](#3-identity-access)
4. [Category B — Networking & Connectivity](#4-networking)
5. [Category C — Compute — AKS (Azure Kubernetes Service)](#5-aks)
6. [Category D — Compute — Azure App Service & Container Apps](#6-app-service-container-apps)
7. [Category E — Compute — Azure Functions](#7-azure-functions)
8. [Category F — Messaging — Azure Service Bus](#8-service-bus)
9. [Category G — Messaging — Azure Event Hubs](#9-event-hubs)
10. [Category H — Messaging — Azure Event Grid](#10-event-grid)
11. [Category I — Data — Azure SQL Database](#11-azure-sql)
12. [Category J — Data — Azure Cosmos DB](#12-cosmos-db)
13. [Category K — Data — Azure Cache for Redis](#13-redis)
14. [Category L — Data — Azure Storage (Blob, Queue, Table)](#14-azure-storage)
15. [Category M — API Management (APIM)](#15-apim)
16. [Category N — Security Services (Key Vault, Defender, Sentinel)](#16-security-services)
17. [Category O — Observability (Monitor, App Insights, Log Analytics)](#17-observability)
18. [Category P — Reliability & Disaster Recovery](#18-reliability-dr)
19. [Category Q — Cost Optimization](#19-cost)
20. [Category R — DevOps, CI/CD & IaC](#20-devops-iac)
21. [Architecture Patterns Review — Decision Trees](#21-patterns)
22. [Azure Architecture Review Scorecard](#22-scorecard)

---

## 1. Mental Model

```
┌──────────────────────────────────────────────────────────────────────┐
│  AZURE ARCHITECTURE REVIEW = PRODUCTION RISK AUDIT                  │
│                                                                      │
│  The Azure Well-Architected Framework asks 5 fundamental questions: │
│                                                                      │
│  1. RELIABILITY    — Does it survive failure without data loss?     │
│  2. SECURITY       — Is the blast radius of a breach minimized?     │
│  3. COST           — Is every dollar of spend justified?            │
│  4. OPERATIONAL    — Can the team run this in production safely?    │
│     EXCELLENCE                                                       │
│  5. PERFORMANCE    — Does it meet SLOs under 10× expected load?     │
│     EFFICIENCY                                                       │
│                                                                      │
│  PLUS the 6th pillar added in 2023:                                 │
│  6. SUSTAINABILITY — Is resource consumption minimized?             │
│                                                                      │
│  Every checkpoint below maps to one or more of these pillars.       │
└──────────────────────────────────────────────────────────────────────┘
```

**How to use this document:**
- During **design reviews**: Work through relevant categories before building
- During **PR reviews**: Check service-specific categories when new Azure resources are added
- During **quarterly health checks**: Run the scorecard against each workload
- During **incident post-mortems**: Identify which checkpoint was missing

---

## 2. Azure Well-Architected Framework (WAF) Quick Reference

```
┌──────────────────┬────────────────────────────────────────────────────┐
│ Pillar           │ Key Questions                                       │
├──────────────────┼────────────────────────────────────────────────────┤
│ Reliability      │ SLA targets defined? Failure modes mapped?          │
│                  │ RTO/RPO tested? Health probes live?                 │
├──────────────────┼────────────────────────────────────────────────────┤
│ Security         │ Least privilege enforced? Secrets in Key Vault?     │
│                  │ Network segmented? PII protected? Audit logs on?    │
├──────────────────┼────────────────────────────────────────────────────┤
│ Cost Optimization│ Right-sizing done? Reserved instances considered?   │
│                  │ Dev environments auto-shutdown? Orphaned resources? │
├──────────────────┼────────────────────────────────────────────────────┤
│ Operational      │ IaC for all infra? Runbooks written? Alerts         │
│ Excellence       │ actionable? Deployment automated end-to-end?        │
├──────────────────┼────────────────────────────────────────────────────┤
│ Performance      │ Load tested? Autoscaling configured? Caching in     │
│ Efficiency       │ place? Database queries indexed?                    │
├──────────────────┼────────────────────────────────────────────────────┤
│ Sustainability   │ Scale-to-zero where possible? Spot instances used?  │
│                  │ Data retention policies enforced?                   │
└──────────────────┴────────────────────────────────────────────────────┘
```

---

## 3. Category A — Identity & Access Management

// ── Entra ID · Managed Identity · RBAC · Workload Identity ──────

### A1 — Service Authentication (Zero Secrets)

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| A1.1 | All Azure service connections use Managed Identity or Workload Identity Federation — never service principal client secrets | Security | CRITICAL |
| A1.2 | AKS pods use Workload Identity (federated credentials) to call Azure APIs — not pod-mounted secrets | Security | CRITICAL |
| A1.3 | Azure Functions use Managed Identity to connect to Service Bus, SQL, Key Vault, Storage | Security | CRITICAL |
| A1.4 | No client secrets or certificates stored in code, appsettings, or environment variables | Security | BLOCKER |
| A1.5 | Client secret rotation is automated where MSI is not possible (Logic Apps, some connectors) | Security | HIGH |

### A2 — RBAC & Least Privilege

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| A2.1 | RBAC roles are assigned at the lowest applicable scope (resource, not subscription) | Security | HIGH |
| A2.2 | No "Owner" or "Contributor" roles assigned to application identities — use purpose-built roles | Security | CRITICAL |
| A2.3 | Custom RBAC roles defined for application-specific needs rather than over-permissive built-in roles | Security | MEDIUM |
| A2.4 | Service accounts (Managed Identities) follow least-privilege — only access services they need | Security | HIGH |
| A2.5 | Azure AD Privileged Identity Management (PIM) used for just-in-time admin access | Security | HIGH |
| A2.6 | No wildcard resource permissions (`*`) in custom role definitions | Security | CRITICAL |

### A3 — End-User Authentication

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| A3.1 | Entra ID (formerly Azure AD) used for end-user authentication — no homegrown auth | Security | CRITICAL |
| A3.2 | Multi-Factor Authentication (MFA) enforced via Conditional Access policies | Security | CRITICAL |
| A3.3 | OAuth 2.0 + OIDC standard flows used — no legacy auth protocols (Basic Auth, NTLM) | Security | HIGH |
| A3.4 | JWT access token lifetime ≤ 15 minutes; refresh tokens have appropriate sliding window | Security | HIGH |
| A3.5 | Conditional Access policies enforce device compliance and location restrictions | Security | MEDIUM |
| A3.6 | B2C or External ID configured for customer-facing authentication | Security | HIGH |

**Review Questions:**
```
? "Show me how Service A connects to the database. Where does the credential come from?"
? "If the AKS node is compromised, what Azure resources can the attacker access?"
? "How do you rotate secrets for the payment API integration?"
? "Which identity does the Azure Function use to read from Service Bus?"
```

---

## 4. Category B — Networking & Connectivity

// ── VNet · NSG · Private Endpoints · Front Door · DNS ───────────

### B1 — Virtual Network Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| B1.1 | All services deployed within a VNet — no public endpoints for PaaS services (SQL, Redis, Service Bus) | Security | CRITICAL |
| B1.2 | VNet address space planned with room for growth — no /28 subnets for AKS node pools | Reliability | HIGH |
| B1.3 | Subnet delegation configured where required (AKS, App Service, Azure SQL MI) | Reliability | HIGH |
| B1.4 | Hub-and-spoke topology implemented for enterprise workloads (hub VNet for shared services) | Security | HIGH |
| B1.5 | VNet peering configured for spoke-to-spoke communication where applicable | Reliability | MEDIUM |
| B1.6 | Azure Route Tables configured to force tunnel internet traffic through Network Virtual Appliance (NVA) or Azure Firewall | Security | HIGH |

### B2 — Network Security Groups (NSG)

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| B2.1 | NSGs follow deny-all-inbound default with explicit allow rules per application port | Security | CRITICAL |
| B2.2 | NSG rules use Application Security Groups (ASGs) instead of individual IP ranges | Security | MEDIUM |
| B2.3 | NSG Flow Logs enabled and routed to Log Analytics | Operational | HIGH |
| B2.4 | No NSG rules allowing SSH/RDP (port 22/3389) from the internet (use Bastion) | Security | BLOCKER |
| B2.5 | Intra-subnet traffic restricted (not assuming subnet = trust boundary) | Security | HIGH |
| B2.6 | NSG rules reviewed for stale rules (old IP ranges, decommissioned services) | Security | MEDIUM |

### B3 — Private Endpoints

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| B3.1 | Azure SQL, Cosmos DB, Service Bus, Event Hubs, Key Vault, Storage — all using private endpoints | Security | CRITICAL |
| B3.2 | Public network access disabled on all PaaS services that have private endpoints | Security | CRITICAL |
| B3.3 | Azure Private DNS Zones configured for each private endpoint (not using public DNS) | Reliability | HIGH |
| B3.4 | DNS resolution chain verified: App → Azure DNS → Private DNS Zone → Private IP | Reliability | HIGH |
| B3.5 | Private endpoints deployed in the same VNet or peered VNet as consumers | Reliability | HIGH |

### B4 — Ingress & Edge Security

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| B4.1 | Azure Front Door or Azure Application Gateway used for external-facing traffic | Security | HIGH |
| B4.2 | Web Application Firewall (WAF) policy deployed in Prevention mode (not Detection only) | Security | CRITICAL |
| B4.3 | Custom WAF rules added for application-specific patterns (SQLi, XSS, rate limiting) | Security | HIGH |
| B4.4 | Azure DDoS Protection Standard enabled for production VNets hosting public IPs | Security | HIGH |
| B4.5 | TLS 1.2+ enforced; TLS 1.0 / 1.1 disabled on all endpoints | Security | CRITICAL |
| B4.6 | HTTPS-only redirect configured; HTTP traffic rejected (not silently accepted) | Security | HIGH |
| B4.7 | Azure CDN configured for static assets with appropriate cache-control headers | Performance | MEDIUM |

### B5 — DNS

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| B5.1 | Azure Private DNS Resolver used for hybrid DNS resolution (on-prem ↔ Azure) | Reliability | HIGH |
| B5.2 | DNS records for private endpoints managed via Azure DNS Private Zones (not manual) | Reliability | HIGH |
| B5.3 | Public DNS records have appropriate TTLs (not 300s for rarely-changing records) | Performance | LOW |
| B5.4 | DNS zone delegation configured for subdomains used by Azure services | Reliability | MEDIUM |

**Review Questions:**
```
? "Can the Azure SQL database be reached from the public internet? Show me."
? "What happens if the on-premises VPN gateway goes down — can the app still function?"
? "How does the AKS pod resolve the private endpoint for Service Bus?"
? "Which WAF rules are currently enabled and in what mode?"
```

---

## 5. Category C — Compute: AKS (Azure Kubernetes Service)

// ── Cluster Design · Node Pools · Workloads · Security · Scaling

### C1 — Cluster Configuration

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C1.1 | AKS cluster is private (API server endpoint not publicly accessible) | Security | CRITICAL |
| C1.2 | Kubernetes version is within N-2 of the latest supported AKS release | Reliability | HIGH |
| C1.3 | Automatic upgrades configured with planned maintenance windows | Operational | HIGH |
| C1.4 | System node pool is dedicated and not shared with user workloads (taint: `CriticalAddonsOnly`) | Reliability | HIGH |
| C1.5 | Azure CNI Overlay or Cilium CNI chosen deliberately based on IP space analysis | Reliability | HIGH |
| C1.6 | Cluster uses Azure AD integration for RBAC — no local accounts in production | Security | CRITICAL |
| C1.7 | Diagnostic settings enabled — API server, audit, controller-manager logs → Log Analytics | Operational | HIGH |

### C2 — Node Pool Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C2.1 | Multiple user node pools per workload type (CPU-optimized, memory-optimized, GPU) | Performance | MEDIUM |
| C2.2 | Availability Zones used for node pools — nodes spread across AZ1, AZ2, AZ3 | Reliability | CRITICAL |
| C2.3 | Spot node pools used for batch / non-critical workloads with node affinity rules | Cost | MEDIUM |
| C2.4 | Node OS disk type: Ephemeral OS disk configured for stateless workloads (lower latency, lower cost) | Performance | MEDIUM |
| C2.5 | Node pool minimum size ≥ 2 per zone for HA (minimum 6 nodes across 3 AZs) | Reliability | HIGH |
| C2.6 | Node pool max size planned for peak load with headroom | Reliability | HIGH |

### C3 — Workload Security

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C3.1 | Pod Security Admission (PSA) enforced — `restricted` profile in production namespaces | Security | CRITICAL |
| C3.2 | Containers running as non-root user (UID ≥ 1000) | Security | CRITICAL |
| C3.3 | Read-only root filesystem configured where possible | Security | HIGH |
| C3.4 | Privilege escalation disabled (`allowPrivilegeEscalation: false`) | Security | CRITICAL |
| C3.5 | Capabilities dropped to minimum (`drop: [ALL]`, add only what's required) | Security | HIGH |
| C3.6 | Workload Identity configured for pods calling Azure APIs — no pod-mounted secrets | Security | CRITICAL |
| C3.7 | Azure Key Vault CSI driver used for secrets injection — not Kubernetes Secrets in plain base64 | Security | HIGH |
| C3.8 | Image scanning integrated in CI (Trivy, Microsoft Defender for Containers) | Security | HIGH |
| C3.9 | Images using specific digest or SHA tag — never `:latest` in production | Reliability | HIGH |

### C4 — Resource Management

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C4.1 | CPU and memory requests AND limits set for all containers | Reliability | CRITICAL |
| C4.2 | LimitRange and ResourceQuota configured per namespace | Reliability | HIGH |
| C4.3 | Requests sized accurately to actual P95 usage (not guessed — based on metrics) | Cost | HIGH |
| C4.4 | Limits set conservatively higher than requests (not 1:1 — leaves burst headroom) | Performance | MEDIUM |
| C4.5 | VPA (Vertical Pod Autoscaler) in recommendation mode to right-size requests | Cost | LOW |

### C5 — Scaling

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C5.1 | HPA configured for all stateless services based on CPU and/or custom metrics | Performance | HIGH |
| C5.2 | KEDA deployed for event-driven scaling (scale to 0 on Service Bus queue depth) | Cost | HIGH |
| C5.3 | Cluster Autoscaler enabled with appropriate min/max node counts | Reliability | HIGH |
| C5.4 | Scale-down stabilization window set to avoid flapping | Reliability | MEDIUM |
| C5.5 | Topology spread constraints configured to distribute pods across AZs | Reliability | HIGH |

### C6 — Networking (AKS-specific)

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C6.1 | Kubernetes Network Policies deployed to restrict pod-to-pod traffic | Security | CRITICAL |
| C6.2 | NGINX Ingress or AGIC (Application Gateway Ingress Controller) deployed and configured | Reliability | HIGH |
| C6.3 | Ingress TLS certificates managed via cert-manager with Let's Encrypt or custom CA | Security | HIGH |
| C6.4 | Internal services use ClusterIP — only ingress-required services use NodePort/LoadBalancer | Security | HIGH |
| C6.5 | Azure CNI private cluster with API server authorized IP ranges configured | Security | HIGH |

### C7 — Reliability (AKS-specific)

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| C7.1 | Pod Disruption Budgets (PDB) configured — minimum available replicas ≥ 1 during disruptions | Reliability | CRITICAL |
| C7.2 | Readiness probes configured and distinct from liveness probes | Reliability | CRITICAL |
| C7.3 | Liveness probes configured with appropriate failure thresholds (not too aggressive) | Reliability | HIGH |
| C7.4 | Startup probes used for slow-starting containers (not inflating liveness `initialDelaySeconds`) | Reliability | MEDIUM |
| C7.5 | `terminationGracePeriodSeconds` aligned to application drain time | Reliability | HIGH |
| C7.6 | `preStop` hook implemented for graceful connection drain | Reliability | HIGH |
| C7.7 | Anti-affinity rules configured to prevent all replicas scheduling on same node | Reliability | HIGH |

**Canonical Deployment Manifest Review**

```yaml
# ── AKS Production Deployment Checklist in YAML ──────────────────

apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-service
  namespace: evicore-prod
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0     # WHY: Zero-downtime — never take pods below desired count
      maxSurge: 1           # WHY: Add one extra pod during rollout
  selector:
    matchLabels:
      app: orders-service
  template:
    metadata:
      labels:
        app: orders-service
        azure.workload.identity/use: "true"   # WHY: Enables Workload Identity for this pod
    spec:
      serviceAccountName: orders-workload-sa  # WHY: Bound to Azure Managed Identity
      securityContext:
        runAsNonRoot: true          # ✅ Non-root
        runAsUser: 1001
        fsGroup: 2000
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule  # WHY: Force spread across AZs
          labelSelector:
            matchLabels:
              app: orders-service
      containers:
        - name: orders-service
          image: evicore.azurecr.io/orders-service:sha-a1b2c3d  # WHY: SHA tag, never :latest
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "1000m"
              memory: "512Mi"
          securityContext:
            allowPrivilegeEscalation: false   # ✅ No privilege escalation
            readOnlyRootFilesystem: true      # ✅ Immutable container filesystem
            capabilities:
              drop: ["ALL"]                   # ✅ No Linux capabilities
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 5
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /health/live
              port: 8080
            initialDelaySeconds: 30           # WHY: Give app time to warm up
            periodSeconds: 10
            failureThreshold: 5
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 5"]  # WHY: Allow load balancer to drain connections
```

---

## 6. Category D — Compute: App Service & Container Apps

// ── App Service Plans · Container Apps · Environment ────────────

### D1 — Azure App Service

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| D1.1 | Premium v3 plan used for production (supports AZ redundancy and VNet integration) | Reliability | HIGH |
| D1.2 | Availability Zone redundancy enabled (minimum 3 instances across AZs) | Reliability | HIGH |
| D1.3 | Always-On enabled to prevent cold starts for non-consumption plans | Performance | HIGH |
| D1.4 | Deployment slots used for blue-green deployments (staging → production swap) | Operational | HIGH |
| D1.5 | VNet Integration configured — outbound traffic through private VNet | Security | HIGH |
| D1.6 | App Service Environment (ASE) evaluated for highly regulated workloads | Security | MEDIUM |
| D1.7 | Managed Identity used for all service connections | Security | CRITICAL |
| D1.8 | HTTPS-only enabled; minimum TLS 1.2 enforced | Security | HIGH |
| D1.9 | Remote debugging disabled in production | Security | HIGH |
| D1.10 | Client certificate authentication evaluated for B2B scenarios | Security | MEDIUM |

### D2 — Azure Container Apps

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| D2.1 | Dedicated environment used for production (not Consumption-only) for VNet support | Security | HIGH |
| D2.2 | Workload profiles selected based on resource requirements (Consumption / Dedicated) | Cost | HIGH |
| D2.3 | Minimum replicas ≥ 1 for always-available services; 0 for event-driven only | Cost | MEDIUM |
| D2.4 | KEDA-based scaling rules configured for Service Bus queue depth | Performance | HIGH |
| D2.5 | Container Apps environment uses custom VNet for private connectivity | Security | HIGH |
| D2.6 | Managed Identity configured for all Azure service connections | Security | CRITICAL |
| D2.7 | Health probes (liveness, readiness, startup) configured | Reliability | HIGH |
| D2.8 | Secrets stored in Container Apps secrets or Key Vault references — not env vars | Security | HIGH |

---

## 7. Category E — Compute: Azure Functions

// ── Hosting Plans · Triggers · Durable · Cold Start ─────────────

### E1 — Hosting Plan

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| E1.1 | Consumption plan not used for latency-sensitive or VNet-requiring workloads | Performance | HIGH |
| E1.2 | Premium plan used for: VNet integration, no cold start, long-running (> 10 min) | Reliability | HIGH |
| E1.3 | Dedicated (App Service) plan used when Functions and App Service share resources | Cost | MEDIUM |
| E1.4 | Container Apps plan evaluated for complex multi-container scenarios | Performance | LOW |
| E1.5 | Pre-warmed instances configured on Premium plan for consistent cold-start avoidance | Performance | HIGH |

### E2 — Function Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| E2.1 | Functions are stateless — state stored in Durable Functions, DB, or cache | Reliability | CRITICAL |
| E2.2 | HTTP-triggered Functions protected with Function Keys or Entra ID auth | Security | CRITICAL |
| E2.3 | Service Bus-triggered Functions configure `maxConcurrentCalls` to prevent overload | Reliability | HIGH |
| E2.4 | Timer triggers use NCRONTAB syntax reviewed for correct schedule and timezone | Operational | HIGH |
| E2.5 | Durable orchestrators are deterministic — no non-deterministic code in orchestrators | Reliability | CRITICAL |
| E2.6 | Large payloads use Blob trigger + Blob input binding (Claim Check pattern) — not inline | Reliability | HIGH |
| E2.7 | Function timeout configured explicitly (`functionTimeout` in host.json) | Reliability | HIGH |
| E2.8 | Dependencies injected via DI (registered in `Program.cs`) — not instantiated inside function | Performance | HIGH |

### E3 — Durable Functions

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| E3.1 | Orchestrator functions contain no I/O, no random, no DateTime.Now — activity calls only | Reliability | CRITICAL |
| E3.2 | Activity functions handle idempotency (replayed by Durable Task Framework) | Reliability | CRITICAL |
| E3.3 | External event handlers (webhooks) use DurableClient.RaiseEventAsync | Reliability | HIGH |
| E3.4 | Instance IDs are deterministic and business-meaningful (not Guid.NewGuid()) | Operational | MEDIUM |
| E3.5 | Fan-out/fan-in uses `Task.WhenAll` on activity calls — not sequential awaits | Performance | HIGH |
| E3.6 | Compensation logic (saga rollback) implemented for multi-step workflows | Reliability | HIGH |
| E3.7 | History cleanup policy configured (purge history older than N days) | Cost | MEDIUM |

### E4 — Security & Secrets

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| E4.1 | Managed Identity used for all service connections (Service Bus, SQL, Key Vault, Storage) | Security | CRITICAL |
| E4.2 | Application settings reference Key Vault secrets (`@Microsoft.KeyVault(...)`) — not plaintext | Security | CRITICAL |
| E4.3 | CORS policy restrictive — not `*` wildcard | Security | HIGH |
| E4.4 | Functions app deployed in VNet — not exposed to public internet (except intentional HTTP triggers) | Security | HIGH |

---

## 8. Category F — Messaging: Azure Service Bus

// ── Namespaces · Topics · Queues · Sessions · DLQ ───────────────

### F1 — Namespace & Tier

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| F1.1 | Premium tier used for production (required for: VNet, private endpoints, geo-DR, > 1MB messages) | Security | CRITICAL |
| F1.2 | Namespace geo-disaster recovery (DR) paired namespace configured for critical workloads | Reliability | HIGH |
| F1.3 | Namespace deployed in same region as consumers (minimize cross-region latency) | Performance | HIGH |
| F1.4 | Namespace diagnostic settings enabled → Log Analytics | Operational | HIGH |
| F1.5 | Private endpoint configured; public network access disabled | Security | CRITICAL |

### F2 — Queues & Topics

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| F2.1 | Topic subscriptions use SQL filter rules to route messages — not consumer-side filtering | Performance | HIGH |
| F2.2 | Message TTL configured appropriately — no infinite TTL | Operational | HIGH |
| F2.3 | `MaxDeliveryCount` set appropriately for retry strategy (default 10 — review per workload) | Reliability | HIGH |
| F2.4 | Dead-letter queue (DLQ) monitored with Alert Rules on message count threshold | Operational | CRITICAL |
| F2.5 | Session-enabled queues/topics configured when ordering within a partition is required | Reliability | HIGH |
| F2.6 | Duplicate detection window configured for deduplication scenarios | Reliability | HIGH |
| F2.7 | Forward-to chaining configured for routing patterns (avoid complex consumer logic) | Design | MEDIUM |

### F3 — Message Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| F3.1 | Messages are idempotent — processing the same message twice has no side effect | Reliability | CRITICAL |
| F3.2 | `MessageId` set to business-meaningful value for deduplication tracking | Reliability | HIGH |
| F3.3 | `PartitionKey` set for ordered delivery within a partition | Reliability | HIGH |
| F3.4 | Large messages (> 256KB) use Claim Check pattern (payload in Blob, reference in message) | Reliability | HIGH |
| F3.5 | Outbox pattern used to ensure atomic DB write + message publish | Reliability | CRITICAL |
| F3.6 | Message schema versioned (`MessageVersion` property in ApplicationProperties) | Operational | HIGH |
| F3.7 | W3C trace context (`traceparent`) propagated in ApplicationProperties | Operational | HIGH |

### F4 — Consumer Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| F4.1 | `CompleteMessageAsync` called only after successful processing | Reliability | CRITICAL |
| F4.2 | `AbandonMessageAsync` called for transient failures (triggers retry via delivery count) | Reliability | CRITICAL |
| F4.3 | `DeadLetterMessageAsync` called for poison messages with meaningful reason | Operational | HIGH |
| F4.4 | Lock renewal implemented for processing that may exceed the lock duration | Reliability | HIGH |
| F4.5 | `maxConcurrentCalls` configured — not defaulting to 1 (under-utilization) or unlimited | Performance | HIGH |
| F4.6 | Consumer uses `ServiceBusProcessor` with auto-complete disabled | Reliability | HIGH |

---

## 9. Category G — Messaging: Azure Event Hubs

// ── Partitions · Consumer Groups · Capture · Schema Registry ────

### G1 — Namespace & Configuration

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| G1.1 | Premium or Dedicated tier for production (Standard lacks Kafka, Schema Registry, private endpoints) | Security | HIGH |
| G1.2 | Partition count set based on peak throughput (1 partition ≈ 1 MB/s ingress, 2 MB/s egress) | Performance | CRITICAL |
| G1.3 | Partition count cannot be decreased after creation — initial sizing must be future-proof | Reliability | CRITICAL |
| G1.4 | Event retention period configured (1–90 days) based on replay requirements | Reliability | HIGH |
| G1.5 | Private endpoint configured; public network access disabled | Security | CRITICAL |

### G2 — Producer Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| G2.1 | Partition key set for events requiring ordering (all events for the same entity use same key) | Reliability | HIGH |
| G2.2 | Events batched using `EventDataBatch` for throughput (not single-event sends) | Performance | HIGH |
| G2.3 | Event payload follows CloudEvents schema for interoperability | Design | MEDIUM |
| G2.4 | Schema Registry used for schema validation and evolution control | Reliability | HIGH |

### G3 — Consumer Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| G3.1 | Separate consumer group per consumer application (not sharing the `$Default` group) | Reliability | CRITICAL |
| G3.2 | Checkpointing strategy reviewed — checkpoint frequency balances throughput vs re-processing cost | Reliability | HIGH |
| G3.3 | Consumer lag monitored via metrics (`consumer_lag` / incoming vs outgoing message rate) | Operational | HIGH |
| G3.4 | Event Hub Capture configured for long-term storage (Avro in Blob/ADLS) | Cost | MEDIUM |
| G3.5 | Consumer handles duplicate events (at-least-once delivery) | Reliability | CRITICAL |

---

## 10. Category H — Messaging: Azure Event Grid

// ── Topics · System Topics · Subscriptions · Delivery ───────────

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| H1 | System Topics used for Azure resource events (Blob created, Resource Group changes) — not custom topics | Design | MEDIUM |
| H2 | Custom Topics used for domain events with CloudEvents schema | Design | MEDIUM |
| H3 | Dead-lettering configured on subscriptions with Blob Storage destination | Operational | HIGH |
| H4 | Retry policy configured (max delivery attempts, event TTL) | Reliability | HIGH |
| H5 | Webhook subscriptions use HTTPS + Entra ID or shared secret validation | Security | CRITICAL |
| H6 | Push delivery (webhook) vs pull delivery (Event Grid namespace) chosen based on receiver availability | Reliability | HIGH |
| H7 | Advanced filters configured on subscriptions to reduce unnecessary deliveries | Performance | MEDIUM |
| H8 | Private endpoint configured for custom topic endpoints | Security | HIGH |

---

## 11. Category I — Data: Azure SQL Database

// ── Tier Selection · HA · Backup · Security · Performance ────────

### I1 — Tier & Configuration

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| I1.1 | Business Critical or General Purpose tier with Zone Redundancy enabled | Reliability | CRITICAL |
| I1.2 | Elastic Pool evaluated for multi-tenant workloads with variable load patterns | Cost | MEDIUM |
| I1.3 | Serverless tier evaluated for dev/test — not production (cold start latency) | Cost | MEDIUM |
| I1.4 | Hyperscale evaluated for > 4TB databases | Performance | MEDIUM |
| I1.5 | SQL Managed Instance evaluated for workloads requiring full SQL Server compatibility | Design | MEDIUM |

### I2 — High Availability & Backup

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| I2.1 | Zone-Redundant HA enabled (Business Critical has built-in AZ replicas) | Reliability | CRITICAL |
| I2.2 | Active Geo-Replication or Failover Group configured for multi-region HA | Reliability | HIGH |
| I2.3 | Long-Term Retention (LTR) backup policy configured per compliance requirements | Reliability | HIGH |
| I2.4 | Point-in-time restore tested — RTO/RPO validated against SLA targets | Reliability | HIGH |
| I2.5 | Failover Group auto-failover policy configured with appropriate grace period | Reliability | HIGH |

### I3 — Security

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| I3.1 | Private endpoint configured; public endpoint disabled | Security | CRITICAL |
| I3.2 | Entra ID (Azure AD) authentication enforced — SQL authentication disabled where possible | Security | CRITICAL |
| I3.3 | Transparent Data Encryption (TDE) using Customer-Managed Key (CMK) in Key Vault | Security | HIGH |
| I3.4 | Advanced Threat Protection / Microsoft Defender for SQL enabled | Security | HIGH |
| I3.5 | SQL Auditing enabled to Log Analytics (captures all queries, logins, schema changes) | Security | HIGH |
| I3.6 | Dynamic Data Masking applied to PII columns (SSN, email, phone) for non-privileged users | Security | HIGH |
| I3.7 | Row-Level Security implemented for multi-tenant data isolation | Security | HIGH |
| I3.8 | Application login uses Managed Identity — no SQL username/password in connection strings | Security | CRITICAL |

### I4 — Performance

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| I4.1 | Query Performance Insight reviewed — top 5 CPU/IO queries optimized | Performance | HIGH |
| I4.2 | Missing index recommendations from DMV reviewed and applied | Performance | HIGH |
| I4.3 | Auto-tuning enabled (automatic index creation/dropping) | Performance | MEDIUM |
| I4.4 | Read Scale-Out / Read Replicas used for reporting queries | Performance | HIGH |
| I4.5 | Connection pool sizing configured in EF Core (default 100 — review per workload) | Performance | HIGH |
| I4.6 | Execution plans reviewed for key OLTP queries — no table scans on large tables | Performance | HIGH |
| I4.7 | Retry logic in EF Core for transient failures (SQL Error 1205 deadlock, etc.) | Reliability | HIGH |

---

## 12. Category J — Data: Azure Cosmos DB

// ── API · Partition Keys · Consistency · Indexing · Cost ─────────

### J1 — API & Configuration

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| J1.1 | NoSQL API (formerly Core SQL) chosen for new workloads; Mongo/Cassandra only for migration | Design | MEDIUM |
| J1.2 | Serverless vs Provisioned Throughput decision documented based on traffic pattern | Cost | HIGH |
| J1.3 | Autoscale configured for provisioned throughput — not manual (avoids over-provisioning) | Cost | HIGH |
| J1.4 | Multi-region writes enabled for active-active scenarios | Reliability | HIGH |
| J1.5 | Private endpoint configured; public access disabled | Security | CRITICAL |

### J2 — Partition Key Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| J2.1 | Partition key has high cardinality — not a boolean or low-cardinality field | Performance | CRITICAL |
| J2.2 | Partition key avoids hot partitions — load is distributed across partitions | Performance | CRITICAL |
| J2.3 | Partition key chosen to align with most common query patterns (co-locate related data) | Performance | HIGH |
| J2.4 | Hierarchical partition keys (up to 3 levels) used where needed for tenant isolation | Design | MEDIUM |
| J2.5 | Single partition size stays within 20GB logical limit | Reliability | CRITICAL |

### J3 — Consistency Level

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| J3.1 | Consistency level explicitly chosen — not defaulting to Session without analysis | Design | CRITICAL |
| J3.2 | Strong consistency used only when required (highest cost, lowest availability) | Cost | MEDIUM |
| J3.3 | Bounded Staleness used for multi-region reads requiring bounded lag | Design | MEDIUM |
| J3.4 | Session consistency used for user-centric scenarios (reads own writes guaranteed) | Design | MEDIUM |
| J3.5 | Eventual consistency used only for analytics/read models where staleness is acceptable | Design | MEDIUM |

### J4 — Indexing & Cost

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| J4.1 | Custom indexing policy defined — not relying on default (index all fields = expensive writes) | Cost | HIGH |
| J4.2 | Unused index paths excluded from indexing policy to reduce RU cost on writes | Cost | HIGH |
| J4.3 | Composite indexes added for multi-field ORDER BY and WHERE combinations | Performance | HIGH |
| J4.4 | Query RU cost monitored via `x-ms-request-charge` header logging | Cost | HIGH |
| J4.5 | Cross-partition queries minimized — queries include partition key where possible | Performance | CRITICAL |
| J4.6 | TTL configured on documents that expire (session data, temp records) — auto-purge | Cost | MEDIUM |

---

## 13. Category K — Data: Azure Cache for Redis

// ── Tier · Eviction · Connection · Patterns ──────────────────────

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| K1 | Enterprise / Enterprise Flash tier used for production requiring clustering or geo-replication | Reliability | HIGH |
| K2 | Standard tier minimum for production (has replication; Basic has no replication — dev only) | Reliability | CRITICAL |
| K3 | Zone Redundancy enabled on Standard/Premium tier | Reliability | HIGH |
| K4 | Private endpoint configured; public access disabled | Security | CRITICAL |
| K5 | Entra ID authentication used — not access key authentication | Security | HIGH |
| K6 | Eviction policy chosen deliberately (`allkeys-lru` for cache, `noeviction` for session store) | Reliability | HIGH |
| K7 | `maxmemory-policy` configured and monitored — alerts on eviction rate | Reliability | HIGH |
| K8 | Connection multiplexing via `ConnectionMultiplexer.Connect` — shared singleton | Performance | HIGH |
| K9 | StackExchange.Redis retry policy configured | Reliability | HIGH |
| K10 | Cache key naming convention defined and namespaced per service | Operational | MEDIUM |
| K11 | Cache-aside pattern implemented — not direct cache coupling in domain | Design | HIGH |
| K12 | Redis Geo-replication evaluated for multi-region active-active scenarios | Reliability | MEDIUM |
| K13 | Data serialization format chosen (JSON vs MessagePack) — documented decision | Performance | MEDIUM |

---

## 14. Category L — Data: Azure Storage

// ── Blob · Queue · Table · ADLS · Security ──────────────────────

### L1 — Account Configuration

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| L1.1 | StorageV2 account type (not legacy Blob or Table accounts) | Design | HIGH |
| L1.2 | Zone-redundant storage (ZRS) or geo-zone-redundant (GZRS) used for production | Reliability | HIGH |
| L1.3 | Public blob access disabled at account level (not per-container) | Security | CRITICAL |
| L1.4 | Shared Access Signatures (SAS) use User Delegation SAS (not Account SAS based on key) | Security | HIGH |
| L1.5 | Private endpoint configured — no public internet access for application storage | Security | CRITICAL |
| L1.6 | Soft delete enabled for blobs and containers (minimum 7 days retention) | Reliability | HIGH |
| L1.7 | Versioning enabled for critical document storage | Reliability | MEDIUM |
| L1.8 | Immutability policies (WORM) configured for compliance/audit log storage | Security | HIGH |

### L2 — Blob Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| L2.1 | Blob lifecycle management rules configured (tier to Cool/Archive/Delete based on age) | Cost | HIGH |
| L2.2 | Large blob operations use parallel upload (BlobClient.UploadAsync with options) | Performance | HIGH |
| L2.3 | CDN fronting Blob Storage for public-read assets (not direct Blob URL) | Performance | HIGH |
| L2.4 | SAS token expiry set appropriately — no long-lived SAS (prefer short + refresh) | Security | HIGH |
| L2.5 | Stored Access Policies used for SAS tokens (allows instant revocation) | Security | HIGH |

---

## 15. Category M — API Management (APIM)

// ── Gateway · Policies · Security · Versioning · Developer Portal

### M1 — Configuration

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| M1.1 | Premium tier used for VNet integration and multi-region deployment | Security | HIGH |
| M1.2 | Internal VNet mode for internal-only APIs; External mode for public APIs | Security | HIGH |
| M1.3 | Managed Identity configured for calling backend services | Security | CRITICAL |
| M1.4 | Zone Redundancy enabled on Premium tier | Reliability | HIGH |
| M1.5 | Custom domain with SSL certificate (managed or Key Vault-backed) | Security | HIGH |
| M1.6 | APIM in same region as AKS/backend — minimize inter-region hop | Performance | HIGH |

### M2 — Security Policies

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| M2.1 | Subscription key required for all APIs — not open access | Security | CRITICAL |
| M2.2 | Entra ID OAuth 2.0 JWT validation policy applied (`validate-jwt` policy) | Security | CRITICAL |
| M2.3 | Rate limiting (`rate-limit-by-key`) configured per API and per subscription | Reliability | HIGH |
| M2.4 | IP filtering policy applied where appropriate (restrict to known IP ranges) | Security | HIGH |
| M2.5 | CORS policy explicitly defined — not wildcard `*` | Security | HIGH |
| M2.6 | Sensitive response headers removed in transformation policies | Security | HIGH |
| M2.7 | Named values (APIM Key Vault references) used for secrets in policies | Security | HIGH |

### M3 — API Design & Versioning

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| M3.1 | API versioning scheme defined and enforced (`v1`, `v2` in URL path) | Design | HIGH |
| M3.2 | Products configured for access tier grouping (Basic, Standard, Premium) | Design | MEDIUM |
| M3.3 | Mock responses configured for APIs under development | Operational | LOW |
| M3.4 | OpenAPI spec imported and kept synchronized with backend | Operational | HIGH |
| M3.5 | Caching policies applied for GET responses where appropriate | Performance | MEDIUM |
| M3.6 | Backend circuit breaker policy configured (APIM 2023+ native support) | Reliability | HIGH |

---

## 16. Category N — Security Services

// ── Key Vault · Microsoft Defender · Sentinel · Policy ──────────

### N1 — Azure Key Vault

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| N1.1 | Soft delete AND purge protection enabled — prevents accidental/malicious deletion | Reliability | CRITICAL |
| N1.2 | Azure RBAC used for Key Vault access (not legacy Access Policies) | Security | HIGH |
| N1.3 | Private endpoint configured; public access disabled | Security | CRITICAL |
| N1.4 | Diagnostic logs enabled → Log Analytics (tracks all secret reads/writes) | Security | HIGH |
| N1.5 | Secret versioning used — old versions retained but disabled after rotation | Security | HIGH |
| N1.6 | Certificate management configured (auto-renewal before expiry) | Reliability | HIGH |
| N1.7 | Key rotation policy configured and automated | Security | HIGH |
| N1.8 | Separate Key Vaults per environment (Dev/Staging/Prod) — no shared Vault | Security | HIGH |
| N1.9 | Key Vault CSI driver or `@Microsoft.KeyVault()` references used — no manual secret copying | Security | CRITICAL |

### N2 — Microsoft Defender for Cloud

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| N2.1 | Microsoft Defender for Cloud enabled across all subscriptions | Security | CRITICAL |
| N2.2 | Defender for Containers enabled for AKS cluster scanning | Security | HIGH |
| N2.3 | Defender for SQL enabled for all Azure SQL databases | Security | HIGH |
| N2.4 | Defender for Key Vault enabled | Security | HIGH |
| N2.5 | Secure Score monitored — target ≥ 80% and improving | Security | HIGH |
| N2.6 | Security recommendations triaged and tracked in backlog | Security | HIGH |
| N2.7 | Regulatory compliance assessment configured (ISO 27001, SOC 2, HIPAA as applicable) | Security | HIGH |

### N3 — Azure Policy & Governance

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| N3.1 | Azure Policy initiatives applied to enforce security baselines (e.g., no public IPs, require TLS) | Security | HIGH |
| N3.2 | Policy effects: Deny for CRITICAL violations, Audit for monitoring | Security | HIGH |
| N3.3 | Resource tagging policy enforced (cost center, environment, owner, application) | Cost | HIGH |
| N3.4 | Resource locks applied to production infrastructure to prevent accidental deletion | Reliability | HIGH |
| N3.5 | Management Groups used for hierarchical policy inheritance | Security | MEDIUM |

---

## 17. Category O — Observability

// ── Application Insights · Log Analytics · Alerts · Dashboards ──

### O1 — Logging

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| O1.1 | All services send structured logs (JSON) to a central Log Analytics Workspace | Operational | CRITICAL |
| O1.2 | Structured logging used in code (`{OrderId}` not `$"{orderId}"` in log templates) | Operational | HIGH |
| O1.3 | Log levels used consistently — no Debug logs in production by default | Cost | HIGH |
| O1.4 | PII/sensitive data NOT present in logs (masked at source) | Security | CRITICAL |
| O1.5 | Correlation IDs (TraceId) present in all log entries | Operational | HIGH |
| O1.6 | Log retention period defined per compliance requirements | Security | HIGH |
| O1.7 | Log Analytics ingestion cost monitored — daily cap configured for dev workspaces | Cost | MEDIUM |

### O2 — Metrics & Dashboards

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| O2.1 | Golden Signals (Latency, Traffic, Errors, Saturation) measured per service | Operational | CRITICAL |
| O2.2 | Azure Monitor Workbooks or Grafana dashboards built for each service | Operational | HIGH |
| O2.3 | SLO dashboards showing error budget burn rate | Operational | HIGH |
| O2.4 | Custom business metrics emitted (orders/sec, payment success rate, queue depth) | Operational | HIGH |
| O2.5 | AKS cluster metrics (node CPU/memory, pod restarts, PVC capacity) visible | Operational | HIGH |

### O3 — Distributed Tracing

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| O3.1 | OpenTelemetry SDK integrated across all services | Operational | HIGH |
| O3.2 | W3C TraceContext (`traceparent`) propagated across HTTP calls and Service Bus messages | Operational | HIGH |
| O3.3 | Application Insights end-to-end transaction view shows full request trace | Operational | HIGH |
| O3.4 | Dependency tracking auto-configured (SQL, HTTP, Service Bus, Redis) | Operational | HIGH |
| O3.5 | Sampling rate configured — 100% in dev, adaptive or ≤ 10% in high-volume prod | Cost | MEDIUM |

### O4 — Alerting

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| O4.1 | Every alert has a runbook — no alert fires without a documented response | Operational | CRITICAL |
| O4.2 | SLO burn rate alerts configured (multi-window: 1h + 6h fast burn) | Operational | HIGH |
| O4.3 | DLQ message count threshold alerts configured | Operational | CRITICAL |
| O4.4 | Error rate alerts per endpoint (not just overall error rate) | Operational | HIGH |
| O4.5 | Certificate expiry alerts (30 days, 14 days, 7 days) | Reliability | HIGH |
| O4.6 | Budget alerts configured at 80% and 100% of monthly forecast | Cost | HIGH |
| O4.7 | Action groups configured with Teams/PagerDuty integration | Operational | HIGH |
| O4.8 | Alerts tested (fire drill) — not just created and forgotten | Operational | HIGH |

### O5 — Health Probes

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| O5.1 | `/health/live` endpoint — checks process is alive (not external dependencies) | Reliability | CRITICAL |
| O5.2 | `/health/ready` endpoint — checks dependencies are reachable before accepting traffic | Reliability | CRITICAL |
| O5.3 | `/health/startup` endpoint — used by AKS startup probe for slow-starting apps | Reliability | HIGH |
| O5.4 | Health checks include: DB connectivity, Service Bus connection, Redis ping | Reliability | HIGH |
| O5.5 | Health check timeout ≤ 3 seconds per dependency | Reliability | HIGH |

---

## 18. Category P — Reliability & Disaster Recovery

// ── SLA · RTO · RPO · Multi-Region · Backup ─────────────────────

### P1 — SLA & Availability Targets

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| P1.1 | Composite SLA calculated from all component SLAs — target is achievable | Reliability | CRITICAL |
| P1.2 | SLOs defined and documented for each service (P99 latency, error rate, availability) | Reliability | HIGH |
| P1.3 | Error budgets calculated and tracked monthly | Reliability | HIGH |
| P1.4 | SLA gap analysis done — if composite SLA < target, redundancy added | Reliability | CRITICAL |

```
┌──────────────────────────────────────────────────────────────────────┐
│  COMPOSITE SLA EXAMPLE CALCULATION                                   │
│                                                                      │
│  Component         SLA                                               │
│  ─────────────────────────────────────────────────────              │
│  AKS               99.95%                                            │
│  Azure SQL (ZR)    99.99%                                            │
│  Service Bus       99.9%                                             │
│  Key Vault         99.99%                                            │
│  Azure Front Door  99.99%                                            │
│                                                                      │
│  Composite = 0.9995 × 0.9999 × 0.999 × 0.9999 × 0.9999            │
│           ≈ 99.83%  →  ~13 hours downtime/year                      │
│                                                                      │
│  IF target is 99.95%: Need geo-redundancy for Service Bus           │
│  (Geo-DR paired namespace brings SLA contribution up)               │
└──────────────────────────────────────────────────────────────────────┘
```

### P2 — Multi-Region Design

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| P2.1 | Active-passive or active-active multi-region design documented | Reliability | HIGH |
| P2.2 | Azure Front Door / Traffic Manager routing policy defined (failover, weighted, priority) | Reliability | HIGH |
| P2.3 | Data replication strategy per data store documented (Cosmos multi-write, SQL geo-replication) | Reliability | CRITICAL |
| P2.4 | Failover runbook tested — not just designed | Reliability | CRITICAL |
| P2.5 | Secondary region warmed up (pre-scaled) before planned failover | Reliability | HIGH |
| P2.6 | DNS TTLs reduced before planned failover to minimize propagation delay | Reliability | HIGH |

### P3 — Backup & Recovery

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| P3.1 | Backup policies defined for each data store with tested restore procedures | Reliability | CRITICAL |
| P3.2 | RTO and RPO targets defined per service and validated via DR drills | Reliability | CRITICAL |
| P3.3 | Azure Backup configured for VMs, File Shares, and SQL databases | Reliability | HIGH |
| P3.4 | Backup data stored in a different region from primary | Reliability | HIGH |
| P3.5 | Backup restore tested quarterly — not just scheduled and assumed working | Reliability | CRITICAL |

---

## 19. Category Q — Cost Optimization

// ── Right-Sizing · Reservations · Tagging · Waste Detection ─────

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| Q1 | Azure Cost Management budgets and alerts configured per environment | Cost | HIGH |
| Q2 | Reserved Instances (1-year or 3-year) purchased for stable, predictable workloads | Cost | HIGH |
| Q3 | Azure Spot VMs/Spot node pools used for non-critical / batch workloads | Cost | MEDIUM |
| Q4 | Azure Hybrid Benefit applied for Windows Server and SQL Server licenses | Cost | HIGH |
| Q5 | Dev/Test environments auto-shutdown outside business hours (AKS scale to 0, VMs stopped) | Cost | HIGH |
| Q6 | Resource tagging policy enforced (cost center, environment, team) for charge-back | Cost | HIGH |
| Q7 | Orphaned resources audit run (unattached disks, unused IPs, empty resource groups) | Cost | HIGH |
| Q8 | Storage lifecycle policies configured — cold/archive tier for old data | Cost | HIGH |
| Q9 | Log Analytics ingestion and retention costs reviewed — workspace archiving used | Cost | MEDIUM |
| Q10 | APIM API caching policies reducing backend calls for cacheable responses | Cost | MEDIUM |
| Q11 | Azure Advisor cost recommendations reviewed and actioned quarterly | Cost | HIGH |
| Q12 | Cosmos DB RU consumption reviewed — autoscale minimum not set too high | Cost | HIGH |
| Q13 | Scale-to-zero configured for non-production AKS node pools and Container Apps | Cost | HIGH |
| Q14 | Premium service tiers justified — downgrade to Standard where Premium features unused | Cost | MEDIUM |

---

## 20. Category R — DevOps, CI/CD & Infrastructure as Code

// ── Bicep · Terraform · GitHub Actions · Azure DevOps · GitOps ──

### R1 — Infrastructure as Code

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| R1.1 | 100% of production infrastructure defined in IaC (Bicep or Terraform) — no ClickOps | Operational | CRITICAL |
| R1.2 | IaC is the source of truth — manual changes in portal are overwritten by next deployment | Operational | CRITICAL |
| R1.3 | IaC code reviewed via PR process same as application code | Operational | HIGH |
| R1.4 | State file (Terraform) stored in Azure Blob Storage with state locking | Operational | CRITICAL |
| R1.5 | Bicep modules / Terraform modules used for reusable infrastructure patterns | Operational | MEDIUM |
| R1.6 | `what-if` / `plan` review required before applying any IaC change to production | Operational | CRITICAL |
| R1.7 | Environment-specific parameter files (dev.bicepparam, prod.bicepparam) | Operational | HIGH |

### R2 — CI/CD Pipeline Security

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| R2.1 | Pipeline uses Workload Identity Federation to authenticate to Azure — no service principal secrets stored in pipelines | Security | CRITICAL |
| R2.2 | Pipeline secrets stored in Key Vault / GitHub Secrets / Azure DevOps Secure Files | Security | CRITICAL |
| R2.3 | Secrets never echoed to pipeline logs | Security | CRITICAL |
| R2.4 | Container image scanning (Trivy / Defender) runs in CI and blocks on HIGH vulnerabilities | Security | HIGH |
| R2.5 | SAST (Static Application Security Testing) scan in CI (CodeQL, Snyk, SonarQube) | Security | HIGH |
| R2.6 | Dependency vulnerability scan in CI (`dotnet list package --vulnerable`) | Security | HIGH |

### R3 — Deployment Strategy

| # | Checkpoint | Pillar | Severity |
|---|---|---|---|
| R3.1 | Blue-green or canary deployment configured — no big-bang deployments to production | Reliability | HIGH |
| R3.2 | Approval gate required for production deployments | Operational | HIGH |
| R3.3 | Rollback procedure documented and tested — can rollback within 5 minutes | Reliability | HIGH |
| R3.4 | Smoke tests execute automatically after each production deployment | Reliability | HIGH |
| R3.5 | Feature flags (Azure App Configuration) used for gradual feature rollout | Reliability | MEDIUM |
| R3.6 | GitOps with ArgoCD or Flux for Kubernetes deployments | Operational | MEDIUM |
| R3.7 | Image tags use commit SHA — never `:latest` in production | Reliability | CRITICAL |

---

## 21. Architecture Patterns Review — Decision Trees

// ── When to Use What ─────────────────────────────────────────────

### Compute Decision Tree

```
┌──────────────────────────────────────────────────────────────────────┐
│  COMPUTE SELECTION GUIDE                                             │
│                                                                      │
│  Need containerized microservices with complex orchestration?        │
│    YES → AKS                                                         │
│    NO ↓                                                              │
│                                                                      │
│  Need serverless event-driven with pay-per-execution?                │
│    YES → Azure Functions (Consumption / Premium)                     │
│    NO ↓                                                              │
│                                                                      │
│  Need containerized apps with minimal ops overhead?                  │
│    YES → Azure Container Apps                                        │
│    NO ↓                                                              │
│                                                                      │
│  Need simple web app or API with PaaS simplicity?                   │
│    YES → Azure App Service                                           │
└──────────────────────────────────────────────────────────────────────┘
```

### Messaging Decision Tree

```
┌──────────────────────────────────────────────────────────────────────┐
│  MESSAGING SELECTION GUIDE                                           │
│                                                                      │
│  Need guaranteed delivery, ordering, DLQ, sessions, transactions?   │
│    YES → Azure Service Bus                                           │
│                                                                      │
│  Need very high throughput (millions/sec), streaming, Kafka compat? │
│    YES → Azure Event Hubs                                            │
│                                                                      │
│  Need reactive cloud events, fan-out, serverless triggers?          │
│    YES → Azure Event Grid                                            │
│                                                                      │
│  Need simple FIFO queue with no advanced features?                  │
│    YES → Azure Storage Queue (cost-effective, simple)               │
└──────────────────────────────────────────────────────────────────────┘
```

### Data Store Decision Tree

```
┌──────────────────────────────────────────────────────────────────────┐
│  DATA STORE SELECTION GUIDE                                          │
│                                                                      │
│  Need ACID transactions, relational model, complex queries?          │
│    YES → Azure SQL Database                                          │
│                                                                      │
│  Need globally distributed, multi-model, elastic scale?             │
│    YES → Azure Cosmos DB                                             │
│                                                                      │
│  Need sub-millisecond caching, session store, pub/sub?              │
│    YES → Azure Cache for Redis                                       │
│                                                                      │
│  Need unstructured file/blob storage?                               │
│    YES → Azure Blob Storage                                          │
│                                                                      │
│  Need time-series / analytics at scale?                             │
│    YES → Azure Data Explorer (Kusto)                                │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 22. Azure Architecture Review Scorecard

```
┌────────────────────────────────────────────────────────────────────────┐
│  AZURE ARCHITECTURE REVIEW SCORECARD                                   │
│  Score: 0 = Not present  1 = Partial  2 = Implemented  3 = Excellent  │
├──────────────────────────────────────────┬────────┬────────────────────┤
│ Category                                 │ Score  │ Critical Gaps      │
├──────────────────────────────────────────┼────────┼────────────────────┤
│ A. Identity & Access Management          │   /3   │                    │
│ B. Networking & Connectivity             │   /3   │                    │
│ C. AKS — Compute                         │   /3   │                    │
│ D. App Service / Container Apps          │   /3   │                    │
│ E. Azure Functions                       │   /3   │                    │
│ F. Azure Service Bus                     │   /3   │                    │
│ G. Azure Event Hubs                      │   /3   │                    │
│ H. Azure Event Grid                      │   /3   │                    │
│ I. Azure SQL Database                    │   /3   │                    │
│ J. Azure Cosmos DB                       │   /3   │                    │
│ K. Azure Cache for Redis                 │   /3   │                    │
│ L. Azure Storage                         │   /3   │                    │
│ M. API Management (APIM)                 │   /3   │                    │
│ N. Security Services (KV, Defender)      │   /3   │                    │
│ O. Observability                         │   /3   │                    │
│ P. Reliability & DR                      │   /3   │                    │
│ Q. Cost Optimization                     │   /3   │                    │
│ R. DevOps, CI/CD & IaC                   │   /3   │                    │
├──────────────────────────────────────────┼────────┼────────────────────┤
│ TOTAL                                    │   /54  │                    │
├──────────────────────────────────────────┴────────┴────────────────────┤
│  Scoring Guide                                                         │
│  49–54 : Production-ready, minor polish needed                         │
│  40–48 : Solid foundation, 2–3 sprint remediation plan needed          │
│  27–39 : Significant gaps — do NOT go to production without a plan     │
│   0–26 : High risk — architectural rework required before production   │
└────────────────────────────────────────────────────────────────────────┘
```

### Mandatory Blockers (Any BLOCKER below = Do Not Deploy)

```
☐ Public endpoints on databases/message buses without private endpoints
☐ Secrets (passwords, API keys) stored in code, appsettings, or pipeline env vars
☐ AKS containers running as root with privileged security context
☐ No authentication on HTTP-triggered Azure Functions
☐ SQL authentication used with hardcoded username/password (no Managed Identity)
☐ WAF disabled or in Detection mode only
☐ No backup or restore testing performed
☐ IaC does not exist — all infrastructure created manually in the portal
☐ No alerting on DLQ depth, error rate, or availability
☐ No Key Vault — secrets hardcoded in application settings
```

---

*Azure Architecture Review Guidelines v1.0 — Principal Engineer Edition*
*Covers: AKS · App Service · Container Apps · Functions · Service Bus · Event Hubs · Event Grid · SQL · Cosmos DB · Redis · Storage · APIM · Key Vault · Defender · Monitor · WAF · Front Door · Networking · CI/CD*
