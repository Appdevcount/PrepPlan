# Azure Kubernetes Service (AKS) — Complete Study Guide
### End-to-End Reference: Architecture · Code · Mental Models · Production Patterns

---

> **How to use this guide**
> - Read Sections 1–4 first to build the mental model
> - Use the Table of Contents to jump to any topic
> - Every code block has inline comments explaining *why*, not just *what*
> - Look for **Mental Model** boxes at the start of each major section
> - Look for **Key Insight** callouts for non-obvious production knowledge

---

## Table of Contents

### PART 1 — FOUNDATIONS
- [Section 1 — Introduction & Overview](#section-1--introduction--overview)
- [Section 2 — Mental Model: How to Think About Kubernetes & AKS](#section-2--mental-model-how-to-think-about-kubernetes--aks)
- [Section 3 — Core Kubernetes Vocabulary](#section-3--core-kubernetes-vocabulary)
- [Section 4 — Kubernetes Objects Hierarchy & Ownership](#section-4--kubernetes-objects-hierarchy--ownership)

### PART 2 — AKS ARCHITECTURE
- [Section 5 — AKS Architecture Deep Dive](#section-5--aks-architecture-deep-dive)
- [Section 6 — Node Pools](#section-6--node-pools)

### PART 3 — CLUSTER PROVISIONING
- [Section 7 — Cluster Provisioning: Azure CLI](#section-7--cluster-provisioning-azure-cli)
- [Section 8 — Cluster Provisioning: Bicep](#section-8--cluster-provisioning-bicep)
- [Section 9 — Cluster Provisioning: Terraform](#section-9--cluster-provisioning-terraform)

### PART 4 — WORKLOADS
- [Section 10 — Deployments](#section-10--deployments)
- [Section 11 — StatefulSets](#section-11--statefulsets)
- [Section 12 — DaemonSets](#section-12--daemonsets)
- [Section 13 — Jobs & CronJobs](#section-13--jobs--cronjobs)

### PART 5 — SERVICES & NETWORKING
- [Section 14 — Service Types](#section-14--service-types)
- [Section 15 — Ingress & Ingress Controllers](#section-15--ingress--ingress-controllers)
- [Section 16 — CNI Plugins](#section-16--cni-plugins)
- [Section 17 — Network Policies](#section-17--network-policies)
- [Section 18 — Private Clusters & Azure Private Link](#section-18--private-clusters--azure-private-link)

### PART 6 — STORAGE
- [Section 19 — Storage Architecture](#section-19--storage-architecture)
- [Section 20 — Storage Classes](#section-20--storage-classes)
- [Section 21 — PV and PVC Code Examples](#section-21--pv-and-pvc-code-examples)

### PART 7 — CONFIGURATION & SECRETS
- [Section 22 — ConfigMaps](#section-22--configmaps)
- [Section 23 — Kubernetes Secrets](#section-23--kubernetes-secrets)
- [Section 24 — Azure Key Vault Integration](#section-24--azure-key-vault-integration)

### PART 8 — RBAC & SECURITY
- [Section 25 — Kubernetes RBAC](#section-25--kubernetes-rbac)
- [Section 26 — Azure AD Integration & Azure RBAC for AKS](#section-26--azure-ad-integration--azure-rbac-for-aks)
- [Section 27 — Workload Identity](#section-27--workload-identity)
- [Section 28 — Pod Security Standards & Policy](#section-28--pod-security-standards--policy)

### PART 9 — AUTOSCALING
- [Section 29 — Horizontal Pod Autoscaler (HPA)](#section-29--horizontal-pod-autoscaler-hpa)
- [Section 30 — Vertical Pod Autoscaler (VPA)](#section-30--vertical-pod-autoscaler-vpa)
- [Section 31 — KEDA: Kubernetes Event-Driven Autoscaling](#section-31--keda-kubernetes-event-driven-autoscaling)
- [Section 32 — Cluster Autoscaler](#section-32--cluster-autoscaler)

### PART 10 — OBSERVABILITY
- [Section 33 — Azure Monitor & Container Insights](#section-33--azure-monitor--container-insights)
- [Section 34 — Prometheus & Grafana on AKS](#section-34--prometheus--grafana-on-aks)
- [Section 35 — Distributed Tracing & Logging](#section-35--distributed-tracing--logging)

### PART 11 — CI/CD
- [Section 36 — CI/CD with Azure DevOps](#section-36--cicd-with-azure-devops)
- [Section 37 — CI/CD with GitHub Actions](#section-37--cicd-with-github-actions)
- [Section 38 — Helm Package Manager](#section-38--helm-package-manager)
- [Section 39 — GitOps with ArgoCD & Flux](#section-39--gitops-with-argocd--flux)

### PART 12 — ADVANCED TOPICS
- [Section 40 — Service Mesh](#section-40--service-mesh)
- [Section 41 — Multi-Tenancy & Namespaces](#section-41--multi-tenancy--namespaces)
- [Section 42 — Windows Containers on AKS](#section-42--windows-containers-on-aks)
- [Section 43 — GPU Workloads on AKS](#section-43--gpu-workloads-on-aks)

### PART 13 — RELIABILITY & COST
- [Section 44 — High Availability & Disaster Recovery](#section-44--high-availability--disaster-recovery)
- [Section 45 — Cost Optimization](#section-45--cost-optimization)
- [Section 46 — AKS vs Alternatives Decision Tree](#section-46--aks-vs-alternatives-decision-tree)

### PART 14 — REFERENCE
- [Section 47 — kubectl Command Reference](#section-47--kubectl-command-reference)
- [Section 48 — Troubleshooting Guide](#section-48--troubleshooting-guide)
- [Section 49 — Production Readiness Checklist](#section-49--production-readiness-checklist)
- [Section 50 — Quick Reference Card](#section-50--quick-reference-card)

---

# PART 1 — FOUNDATIONS

---

## Section 1 — Introduction & Overview

### What is Azure Kubernetes Service (AKS)?

AKS is Microsoft Azure's **fully managed Kubernetes service**. It handles the complexity of running a Kubernetes control plane — provisioning, upgrading, patching, scaling the API server, etcd, scheduler — so you only manage the **worker nodes** where your applications run.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AKS MANAGED RESPONSIBILITY SPLIT                  │
├─────────────────────────────┬───────────────────────────────────────┤
│   Azure Manages (FREE)      │   You Manage (Pay for VMs)            │
├─────────────────────────────┼───────────────────────────────────────┤
│ • API Server                │ • Worker Nodes (VMs)                  │
│ • etcd (cluster state DB)   │ • Node Pools (scaling)                │
│ • Scheduler                 │ • Your container images               │
│ • Controller Manager        │ • Kubernetes manifests/Helm charts    │
│ • Cloud Controller Manager  │ • Application configuration           │
│ • Control plane upgrades    │ • Networking add-ons (optional)       │
│ • Control plane HA          │ • Storage configuration               │
│ • Control plane monitoring  │ • RBAC policies for your apps         │
└─────────────────────────────┴───────────────────────────────────────┘
```

### AKS Tiers & SLA

| Tier | Monthly SLA | Use Case | Cost |
|------|------------|----------|------|
| **Free** | No SLA | Dev/test only | $0 control plane |
| **Standard** | 99.95% | Production workloads | ~$0.10/hour/cluster |
| **Premium** | 99.99% | Mission-critical | ~$0.60/hour/cluster + LTS |

> **Key Insight:** The control plane is free (or cheaply tiered). You pay only for the **node VMs**, storage, and networking. A 3-node cluster with Standard_D4s_v3 VMs costs roughly $400–600/month — the AKS management overhead is essentially $0 to $75/month.

### AKS vs Alternatives — Quick Orientation

| When You Need | Use |
|---------------|-----|
| Full Kubernetes control, stateful workloads, custom operators | **AKS** |
| Simplified container hosting, no K8s knowledge required | **Azure Container Apps** |
| Traditional web app hosting, familiar PaaS | **Azure App Service** |
| Event-driven, short-lived functions | **Azure Functions** |
| Single containers, batch jobs, no orchestration | **Azure Container Instances** |

### Kubernetes Version Support on AKS

- AKS supports the **3 most recent minor Kubernetes versions** (e.g., 1.29, 1.28, 1.27)
- **Premium tier** includes Long Term Support (LTS) — 2 years per version
- You must upgrade proactively; deprecated versions become unsupported
- AKS upgrades are **rolling** — nodes replaced one by one with zero downtime if configured correctly

---

## Section 2 — Mental Model: How to Think About Kubernetes & AKS

> **Mental Model: Kubernetes is a self-healing city**
>
> Imagine a **city** (the cluster). The city has **districts** (namespaces). Within districts are **buildings** (nodes — the actual VMs). In each building are **apartments** (pods). Each apartment houses **residents** (containers — your actual app processes).
>
> The **City Hall** (API Server) receives all requests — build a building, evict a resident, change a zone law.
> The **City Registry** (etcd) is the single source of truth — every permit, every resident record.
> The **Urban Planning Department** (Scheduler) decides which building gets each new apartment.
> The **Building Inspectors** (kubelet, on each node) ensure each apartment matches the approved plan.
> The **City Council** (Controller Manager) continuously patrols, fixing anything that drifts from the approved blueprints.

```
┌─────────────────────────── KUBERNETES CLUSTER (The City) ────────────────────────────┐
│                                                                                        │
│  ┌─────────────── CONTROL PLANE (City Hall — Azure Managed) ──────────────────────┐   │
│  │                                                                                 │   │
│  │  ┌──────────────┐  ┌──────────┐  ┌─────────────────────┐  ┌───────────────┐   │   │
│  │  │  API Server  │  │   etcd   │  │  Controller Manager │  │   Scheduler   │   │   │
│  │  │  (front door)│  │ (registry│  │  (self-healing loop)│  │ (assignment)  │   │   │
│  │  │  REST + auth │  │  ledger) │  │  Watch → React loop │  │ fit algorithm │   │   │
│  │  └──────┬───────┘  └──────────┘  └─────────────────────┘  └───────────────┘   │   │
│  │         │                                                                       │   │
│  └─────────┼─────────────────────────────────────────────────────────────────────-┘   │
│            │  (kubectl, CI/CD pipelines, Azure Portal all talk to API Server)          │
│            ▼                                                                           │
│  ┌──────── DATA PLANE (Worker Nodes — Your VMs) ──────────────────────────────────┐   │
│  │                                                                                 │   │
│  │  ┌──────────────────────────┐   ┌──────────────────────────┐                   │   │
│  │  │     NODE 1 (VM)          │   │     NODE 2 (VM)           │   ...             │   │
│  │  │  ┌────────┐ ┌─────────┐  │   │  ┌────────┐ ┌─────────┐  │                   │   │
│  │  │  │ Pod A  │ │  Pod B  │  │   │  │ Pod C  │ │  Pod D  │  │                   │   │
│  │  │  │[ctr1]  │ │[ctr1]   │  │   │  │[ctr1]  │ │[ctr1]   │  │                   │   │
│  │  │  │[ctr2]  │ │[ctr2]   │  │   │  │        │ │[ctr2]   │  │                   │   │
│  │  │  └────────┘ └─────────┘  │   │  └────────┘ └─────────┘  │                   │   │
│  │  │  kubelet  kube-proxy      │   │  kubelet  kube-proxy      │                   │   │
│  │  │  containerd               │   │  containerd               │                   │   │
│  │  └──────────────────────────┘   └──────────────────────────┘                   │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### The Desired State Reconciliation Loop — Most Important Mental Model

Kubernetes is fundamentally a **desired state system**. You never say "go start 3 pods". Instead, you say "I **desire** 3 pods" and Kubernetes makes it so — and *keeps* it so.

```
  YOU DECLARE:                    KUBERNETES DOES:
  "I want 3 replicas"    ──────►  Compares desired vs actual
                                          │
                         ┌────────────────▼────────────────┐
                         │        Desired: 3 replicas       │
                         │        Actual:  2 replicas       │
                         │        Diff:    +1 needed        │
                         └────────────────┬────────────────┘
                                          │
                                          ▼
                                  Schedules 1 new pod
                                          │
                                          ▼
                                  Actual: 3 replicas ✓
                                          │
                         ┌────────────────▼────────────────┐
                         │  A node crashes → actual = 2     │
                         │  Controller detects diff         │
                         │  Schedules replacement pod       │
                         └─────────────────────────────────┘
```

This loop runs **constantly** — every ~15-30 seconds. This is why Kubernetes is self-healing. If a pod crashes, a node dies, or someone manually deletes a pod, the controller manager detects the drift and corrects it.

### Key Components Explained

| Component | What it Does | Analogy |
|-----------|-------------|---------|
| **API Server** | All CRUD operations on cluster objects. Central authentication/authorization point. | City Hall reception desk |
| **etcd** | Distributed key-value store holding ALL cluster state. If etcd dies, the cluster is blind. | City's official ledger/registry |
| **Scheduler** | Watches for unscheduled pods. Picks the best node using scoring algorithms (resource fit, affinity, taints). | Real estate agent finding apartments |
| **Controller Manager** | Runs 30+ controllers (Deployment controller, ReplicaSet controller, Node controller, etc.) in a single process. | City inspectors constantly auditing |
| **Cloud Controller Manager** | Bridges K8s and Azure APIs. Creates Load Balancers, manages node lifecycle, provisions disks. | Azure integration layer |
| **kubelet** | Agent on each node. Watches API Server for pods assigned to its node. Starts/stops containers via containerd. | Building superintendent |
| **kube-proxy** | Handles network rules on each node for Service routing (ClusterIP, NodePort). Uses iptables/ipvs. | Traffic cop |
| **containerd** | The container runtime. Actually pulls images and runs containers. (Docker was replaced by containerd in K8s 1.24+) | The actual apartment manager |

---

## Section 3 — Core Kubernetes Vocabulary

### Object Reference Table

| Object | Kind | Purpose | Key Fields |
|--------|------|---------|-----------|
| **Pod** | `Pod` | Smallest deployable unit. Wraps 1+ containers that share network and storage. | `spec.containers`, `spec.volumes` |
| **ReplicaSet** | `ReplicaSet` | Ensures N copies of a pod run. Rarely used directly — Deployment manages it. | `spec.replicas`, `spec.selector` |
| **Deployment** | `Deployment` | Manages ReplicaSets. Handles rolling updates, rollbacks. Use for stateless apps. | `spec.strategy`, `spec.template` |
| **StatefulSet** | `StatefulSet` | Like Deployment but gives pods stable identities (pod-0, pod-1) and stable storage. Use for databases. | `spec.volumeClaimTemplates` |
| **DaemonSet** | `DaemonSet` | Runs exactly 1 pod on every node (or selected nodes). Use for agents, log collectors. | `spec.selector`, `spec.template` |
| **Job** | `Job` | Runs pods until completion. For batch/one-off tasks. | `spec.completions`, `spec.parallelism` |
| **CronJob** | `CronJob` | Schedules Jobs on a cron schedule. | `spec.schedule`, `spec.jobTemplate` |
| **Service** | `Service` | Stable network endpoint for a set of pods. Load balances between pod instances. | `spec.type`, `spec.selector`, `spec.ports` |
| **Ingress** | `Ingress` | HTTP/HTTPS routing rules — host/path-based routing to Services. Needs an Ingress Controller. | `spec.rules`, `spec.tls` |
| **ConfigMap** | `ConfigMap` | Non-sensitive configuration data. Mounted as env vars or files. | `data`, `binaryData` |
| **Secret** | `Secret` | Sensitive data (passwords, tokens). Base64-encoded at rest (not encrypted by default). | `type`, `data` |
| **Namespace** | `Namespace` | Virtual cluster partition. Scope for most resources. | (cluster-scoped) |
| **PersistentVolume** | `PersistentVolume` | Cluster-level storage resource (Azure Disk, Azure Files). Pre-provisioned or dynamic. | `spec.capacity`, `spec.accessModes` |
| **PersistentVolumeClaim** | `PersistentVolumeClaim` | Pod's request for storage. Bound to a PV. | `spec.storageClassName`, `spec.resources` |
| **StorageClass** | `StorageClass` | Template for dynamic PV provisioning. Defines provisioner, parameters, reclaim policy. | `provisioner`, `reclaimPolicy` |
| **ServiceAccount** | `ServiceAccount` | Identity for pods within the cluster. Used for RBAC and Workload Identity. | `automountServiceAccountToken` |
| **Role** | `Role` | Set of permissions within a namespace. | `rules[].verbs`, `rules[].resources` |
| **ClusterRole** | `ClusterRole` | Set of permissions cluster-wide. | Same as Role but cluster-scoped |
| **RoleBinding** | `RoleBinding` | Binds a Role to a subject (user/group/SA) in a namespace. | `subjects`, `roleRef` |
| **ClusterRoleBinding** | `ClusterRoleBinding` | Binds a ClusterRole to a subject cluster-wide. | Same as RoleBinding but cluster-wide |
| **HPA** | `HorizontalPodAutoscaler` | Scales pod replicas based on CPU/memory/custom metrics. | `spec.metrics`, `spec.minReplicas`, `spec.maxReplicas` |
| **VPA** | `VerticalPodAutoscaler` | Adjusts pod resource requests/limits. Requires restart. | `spec.updatePolicy.updateMode` |
| **NetworkPolicy** | `NetworkPolicy` | Pod-level firewall rules. Controls ingress/egress traffic. | `spec.podSelector`, `spec.ingress`, `spec.egress` |
| **ResourceQuota** | `ResourceQuota` | Limits total resource consumption per namespace. | `spec.hard` |
| **LimitRange** | `LimitRange` | Sets default/min/max resource requests and limits for containers in a namespace. | `spec.limits` |

### Labels vs Annotations

```
Labels:
  - Key-value pairs used for SELECTION and GROUPING
  - Selectors use labels to find objects (Services find Pods by label)
  - Keep concise: app=frontend, version=v2, tier=web
  - Can filter with: kubectl get pods -l app=frontend

Annotations:
  - Key-value pairs for METADATA (not selection)
  - Used by tools: ingress controllers, cert-manager, monitoring
  - Can be long strings, URLs, JSON blobs
  - Examples: deployment.kubernetes.io/revision, kubectl.kubernetes.io/last-applied-configuration
```

---

## Section 4 — Kubernetes Objects Hierarchy & Ownership

### The Ownership Chain

Kubernetes uses **owner references** so that when a parent is deleted, children are garbage collected:

```
Deployment
    │
    ├── owns ──► ReplicaSet (v1: 3 replicas of image:v1)
    │                │
    │                ├── owns ──► Pod (app-xxx-1)
    │                ├── owns ──► Pod (app-xxx-2)
    │                └── owns ──► Pod (app-xxx-3)
    │
    └── owns ──► ReplicaSet (v2: rolling update creates new RS)
                     │
                     ├── owns ──► Pod (app-yyy-1)  ◄── new pods being created
                     └── ...

CronJob
    │
    └── owns ──► Job (each scheduled run)
                     │
                     └── owns ──► Pod (runs the job task)

StatefulSet
    │
    ├── owns ──► Pod (mydb-0)  ─── bound to ──► PVC (data-mydb-0) ──► PV
    ├── owns ──► Pod (mydb-1)  ─── bound to ──► PVC (data-mydb-1) ──► PV
    └── owns ──► Pod (mydb-2)  ─── bound to ──► PVC (data-mydb-2) ──► PV
```

### How Label Selectors Connect Objects

Labels are the **glue** of Kubernetes. A Service finds its pods through label selectors:

```yaml
# The Deployment creates pods with this label:
template:
  metadata:
    labels:
      app: frontend        # <── pod gets this label
      version: v2

# The Service selects pods using this selector:
selector:
  app: frontend            # <── matches pods with app=frontend
                           #     (version label NOT required here)
```

### The Reconciliation Loop (Controller Pattern)

Every controller in Kubernetes follows the same pattern:

```
                 ┌───────────────────────────────────────────┐
                 │           CONTROLLER LOOP                  │
                 │                                           │
  API Server ──► │  1. WATCH: Listen for object changes      │
                 │  2. GET: Read current state               │
                 │  3. COMPARE: Desired vs Actual            │
                 │  4. ACT: Create/Update/Delete resources   │
                 │  5. UPDATE STATUS: Write back to API      │
                 │     Server what happened                  │
                 │                                           │
                 │  Repeat every ~30 seconds or on event     │
                 └───────────────────────────────────────────┘
```

---

# PART 2 — AKS ARCHITECTURE

---

## Section 5 — AKS Architecture Deep Dive

> **Mental Model: AKS is an iceberg.**
>
> The control plane is the 90% below the water — massive, complex, but invisible to you. You only see and manage the 10% above water: your node pools, your pods, your workloads. Azure handles all the invisible complexity.

### Full AKS Architecture Diagram

```
┌────────────────────────── AZURE SUBSCRIPTION ──────────────────────────────────────────┐
│                                                                                         │
│  ┌──────────────────────── AKS CLUSTER ─────────────────────────────────────────────┐  │
│  │                                                                                   │  │
│  │  ┌──────────────── CONTROL PLANE (Azure-Managed, No VMs visible to you) ───────┐ │  │
│  │  │                                                                              │ │  │
│  │  │  ┌─────────────┐   ┌──────────┐   ┌──────────────────┐   ┌──────────────┐  │ │  │
│  │  │  │  API Server │   │  etcd    │   │  Controller Mgr  │   │  Scheduler   │  │ │  │
│  │  │  │  (HTTPS 443)│   │ (raft HA)│   │  (30+ controllers│   │  (bin-packing│  │ │  │
│  │  │  │  auth/authz │   │ 3 nodes  │   │   in one process)│   │   algorithm) │  │ │  │
│  │  │  └──────┬──────┘   └──────────┘   └──────────────────┘   └──────────────┘  │ │  │
│  │  │         │                                                                    │ │  │
│  │  │  ┌──────▼──────────────────────────────────────────────────────────────┐   │ │  │
│  │  │  │  Cloud Controller Manager (CCM) — Azure Integration Layer            │   │ │  │
│  │  │  │  • Watches Services of type LoadBalancer → creates Azure LB          │   │ │  │
│  │  │  │  • Watches Nodes → syncs with Azure VM lifecycle                     │   │ │  │
│  │  │  │  • Watches PVCs → triggers Azure Disk/Files provisioning             │   │ │  │
│  │  │  └─────────────────────────────────────────────────────────────────────┘   │ │  │
│  │  └──────────────────────────────────────────────────────────────────────────── ┘ │  │
│  │                                                                                   │  │
│  │  ┌─────────────────── NODE RESOURCE GROUP (MC_*) ──────────────────────────────┐ │  │
│  │  │                                                                              │ │  │
│  │  │  ┌─────────── SYSTEM NODE POOL ─────────────┐                              │ │  │
│  │  │  │  VM Scale Set (3+ nodes recommended)     │                              │ │  │
│  │  │  │  ┌────────────────┐  ┌────────────────┐  │                              │ │  │
│  │  │  │  │  Node (VM)     │  │  Node (VM)     │  │                              │ │  │
│  │  │  │  │  • kubelet     │  │  • kubelet     │  │                              │ │  │
│  │  │  │  │  • containerd  │  │  • containerd  │  │                              │ │  │
│  │  │  │  │  • kube-proxy  │  │  • kube-proxy  │  │                              │ │  │
│  │  │  │  │  Runs:         │  │  Runs:         │  │                              │ │  │
│  │  │  │  │  • CoreDNS     │  │  • kube-proxy  │  │                              │ │  │
│  │  │  │  │  • metrics-srv │  │  • Azure CNI   │  │                              │ │  │
│  │  │  │  └────────────────┘  └────────────────┘  │                              │ │  │
│  │  │  └─────────────────────────────────────────-┘                              │ │  │
│  │  │                                                                              │ │  │
│  │  │  ┌─────────── USER NODE POOL ──────────────┐                               │ │  │
│  │  │  │  VM Scale Set (your app workloads)      │                               │ │  │
│  │  │  │  ┌─────────────────────────────────────┐│                               │ │  │
│  │  │  │  │ Node  [Pod:api] [Pod:api] [Pod:db]  ││                               │ │  │
│  │  │  │  │ Node  [Pod:api] [Pod:frontend]       ││                               │ │  │
│  │  │  │  └─────────────────────────────────────┘│                               │ │  │
│  │  │  └────────────────────────────────────────-┘                               │ │  │
│  │  │                                                                              │ │  │
│  │  │  Azure Load Balancer   Azure Virtual Network    Azure Disk/Files             │ │  │
│  │  └──────────────────────────────────────────────────────────────────────────── ┘ │  │
│  └───────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                         │
│  Azure Container Registry    Azure Key Vault    Azure Monitor    Azure AD              │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

### The Node Resource Group (MC_*)

When you create an AKS cluster named `myAKS` in resource group `myRG`, Azure automatically creates a **second resource group** called `MC_myRG_myAKS_eastus` containing:

- Virtual Machine Scale Sets (the actual node VMs)
- Azure Load Balancers (for Services of type LoadBalancer)
- Virtual Network and subnets (if you use the default network)
- Managed Disks (for PersistentVolumes)
- Public IP addresses (for LoadBalancer services)
- Network Security Groups

> **Key Insight:** Do NOT manually modify resources in the MC_ resource group. AKS manages these. If you delete or modify them outside of AKS, you can break your cluster. Use Kubernetes APIs and AKS CLI to manage these resources.

### AKS Cluster Upgrade Strategy

```
UPGRADE FLOW:
  1. az aks upgrade --kubernetes-version 1.29.x

  2. AKS upgrades control plane first (zero downtime, API Server HA)

  3. AKS upgrades node pool one node at a time:
     a. Cordon node (mark unschedulable)
     b. Drain node (evict all pods — respects PodDisruptionBudgets)
     c. Delete old VM
     d. Add new VM with new K8s version
     e. Wait for node to be Ready
     f. Uncordon node
     g. Move to next node

  4. New K8s version running on all nodes
```

---

## Section 6 — Node Pools

> **Mental Model: Node pools are departments in your company.**
> The system node pool is the IT department (runs infrastructure, always needs to be running). User node pools are your business departments (sales, engineering) — you can add more departments for different teams, or spin up a temporary contractor team (spot nodes) for surge work.

### System Node Pool vs User Node Pools

| Characteristic | System Node Pool | User Node Pool |
|---------------|-----------------|----------------|
| **Purpose** | Runs AKS system components (CoreDNS, metrics-server, tunnelfront) | Runs your application workloads |
| **Count** | Exactly 1 required per cluster | 0 to 100 per cluster |
| **Taint** | `CriticalAddonsOnly=true:NoSchedule` (prevents app pods) | No default taint |
| **Min nodes** | 1 (even when paused) | Can scale to 0 |
| **VM sizes** | At least 2 vCPUs, 4GB RAM (Standard_D2s_v3 min) | Any size matching workload |
| **OS** | Linux only | Linux or Windows |

### Node Pool Operations (Azure CLI)

```bash
# ─────────────────────────────────────────────────────────────────
# List all node pools in a cluster
# ─────────────────────────────────────────────────────────────────
az aks nodepool list \
  --resource-group myRG \
  --cluster-name myAKS \
  --output table

# ─────────────────────────────────────────────────────────────────
# Add a new user node pool for CPU-intensive workloads
# ─────────────────────────────────────────────────────────────────
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --name computepool \           # pool name (lowercase, max 12 chars)
  --node-count 3 \               # initial node count
  --node-vm-size Standard_F8s_v2 \  # compute-optimized VMs
  --os-type Linux \
  --mode User \                  # User mode = for app workloads
  --node-taints workload=compute:NoSchedule \  # only pods that tolerate this go here
  --labels workload=compute \    # label for node selector
  --enable-cluster-autoscaler \  # allow this pool to auto-scale
  --min-count 1 \                # minimum 1 node (saves cost when idle)
  --max-count 10 \               # maximum 10 nodes (cost ceiling)
  --zones 1 2 3                  # spread across AZs for HA

# ─────────────────────────────────────────────────────────────────
# Add a Windows node pool (requires network plugin = azure)
# ─────────────────────────────────────────────────────────────────
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --name winpool \
  --os-type Windows \            # Windows Server containers
  --node-count 2 \
  --node-vm-size Standard_D4s_v3

# ─────────────────────────────────────────────────────────────────
# Add a Spot node pool (preemptible VMs — up to 90% discount)
# Warning: Azure can evict spot nodes with 30-second notice
# ─────────────────────────────────────────────────────────────────
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --name spotpool \
  --priority Spot \              # Spot VMs (interruptible)
  --eviction-policy Delete \     # Delete (not Deallocate) for K8s
  --spot-max-price -1 \          # -1 = pay up to on-demand price
  --node-count 0 \               # start with 0; autoscaler adds nodes
  --enable-cluster-autoscaler \
  --min-count 0 \
  --max-count 20 \
  --node-taints "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  # ^ AKS auto-applies this taint; your pods must tolerate it

# ─────────────────────────────────────────────────────────────────
# Scale a node pool manually
# ─────────────────────────────────────────────────────────────────
az aks nodepool scale \
  --resource-group myRG \
  --cluster-name myAKS \
  --name computepool \
  --node-count 5

# ─────────────────────────────────────────────────────────────────
# Upgrade a specific node pool's Kubernetes version
# ─────────────────────────────────────────────────────────────────
az aks nodepool upgrade \
  --resource-group myRG \
  --cluster-name myAKS \
  --name computepool \
  --kubernetes-version 1.29.2

# ─────────────────────────────────────────────────────────────────
# Delete a node pool (gracefully drains pods first)
# ─────────────────────────────────────────────────────────────────
az aks nodepool delete \
  --resource-group myRG \
  --cluster-name myAKS \
  --name computepool \
  --no-wait  # returns immediately; deletion runs in background
```

### Spot Node Pods: Tolerations Required

To schedule pods on Spot node pools, add these tolerations:

```yaml
# pods that run on spot nodes must tolerate spot eviction
tolerations:
  - key: "kubernetes.azure.com/scalesetpriority"
    operator: "Equal"
    value: "spot"
    effect: "NoSchedule"

# Also set node affinity to PREFER spot but fall back to regular:
affinity:
  nodeAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 1
      preference:
        matchExpressions:
        - key: "kubernetes.azure.com/scalesetpriority"
          operator: In
          values:
          - "spot"
```

---

# PART 3 — CLUSTER PROVISIONING

---

## Section 7 — Cluster Provisioning: Azure CLI

### Pre-Requisites

```bash
# ─────────────────────────────────────────────────────────────────
# 1. Install Azure CLI (>= 2.50)
# ─────────────────────────────────────────────────────────────────
az version

# ─────────────────────────────────────────────────────────────────
# 2. Install kubectl and kubelogin
# ─────────────────────────────────────────────────────────────────
az aks install-cli

# ─────────────────────────────────────────────────────────────────
# 3. Register required resource providers
# ─────────────────────────────────────────────────────────────────
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.OperationalInsights

# Check registration (wait until state = Registered):
az provider show -n Microsoft.ContainerService --query registrationState -o tsv

# ─────────────────────────────────────────────────────────────────
# 4. Login and set subscription
# ─────────────────────────────────────────────────────────────────
az login
az account set --subscription "My Subscription"
az account show
```

### Create a Production-Ready AKS Cluster

```bash
# ─────────────────────────────────────────────────────────────────
# STEP 1: Create resource group
# ─────────────────────────────────────────────────────────────────
az group create \
  --name myRG \
  --location eastus

# ─────────────────────────────────────────────────────────────────
# STEP 2: Create a Log Analytics workspace for Container Insights
# ─────────────────────────────────────────────────────────────────
az monitor log-analytics workspace create \
  --resource-group myRG \
  --workspace-name myLAWorkspace \
  --location eastus

# Capture the workspace ID for the cluster creation command below
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group myRG \
  --workspace-name myLAWorkspace \
  --query id -o tsv)

# ─────────────────────────────────────────────────────────────────
# STEP 3: Create the AKS cluster
# ─────────────────────────────────────────────────────────────────
az aks create \
  --resource-group myRG \
  --name myAKS \
  \
  # ── Kubernetes version ──────────────────────────────────────────
  --kubernetes-version 1.29.2 \         # Specify version explicitly
  \
  # ── Cluster tier (SLA) ──────────────────────────────────────────
  --tier standard \                      # standard=99.95% SLA; free=no SLA
  \
  # ── Identity & Authentication ───────────────────────────────────
  --enable-managed-identity \            # Use system-assigned managed identity
  --enable-oidc-issuer \                 # Required for Workload Identity
  --enable-workload-identity \           # Enable Azure Workload Identity
  \
  # ── System node pool ───────────────────────────────────────────
  --node-count 3 \                       # 3 nodes for HA (spread across AZs)
  --node-vm-size Standard_D4s_v3 \       # 4 vCPU, 16GB RAM — good for system pool
  --zones 1 2 3 \                        # Spread nodes across AZs for HA
  \
  # ── Network ─────────────────────────────────────────────────────
  --network-plugin azure \               # Azure CNI (pods get VNet IPs)
  --network-policy calico \             # Network policies via Calico
  --service-cidr 10.0.0.0/16 \          # IP range for Services (ClusterIP)
  --dns-service-ip 10.0.0.10 \          # CoreDNS service IP (in service-cidr)
  \
  # ── Node OS & security ──────────────────────────────────────────
  --os-sku AzureLinux \                  # Azure Linux (Mariner) — hardened OS
  --node-os-upgrade-channel SecurityPatch \  # Auto-apply OS security patches
  \
  # ── Cluster Autoscaler ──────────────────────────────────────────
  --enable-cluster-autoscaler \          # Allow nodes to scale up/down
  --min-count 1 \                        # Min 1 node (saves cost when quiet)
  --max-count 10 \                       # Max 10 nodes (cost ceiling)
  \
  # ── Monitoring ──────────────────────────────────────────────────
  --enable-addons monitoring \           # Enable Container Insights
  --workspace-resource-id $WORKSPACE_ID \  # Send logs to this workspace
  \
  # ── Azure Container Registry integration ────────────────────────
  --attach-acr myACR \                   # Grant AKS managed identity ACR Pull
  \
  # ── SSH key (for node debugging) ────────────────────────────────
  --generate-ssh-keys \                  # Generate SSH keys if not present
  \
  # ── Azure AD / RBAC ─────────────────────────────────────────────
  --enable-azure-rbac \                  # Use Azure RBAC for K8s access
  --aad-admin-group-object-ids "GROUP_OBJECT_ID"  # AAD group = cluster-admin

# ─────────────────────────────────────────────────────────────────
# STEP 4: Get credentials (merges into ~/.kube/config)
# ─────────────────────────────────────────────────────────────────
az aks get-credentials \
  --resource-group myRG \
  --name myAKS \
  --overwrite-existing   # overwrite if cluster credentials already exist

# Verify connection:
kubectl cluster-info
kubectl get nodes -o wide

# ─────────────────────────────────────────────────────────────────
# STEP 5: Add user node pool for application workloads
# ─────────────────────────────────────────────────────────────────
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --name apppool \
  --node-count 3 \
  --node-vm-size Standard_D8s_v3 \       # Larger VMs for app workloads
  --mode User \
  --os-sku AzureLinux \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 20 \
  --zones 1 2 3

# ─────────────────────────────────────────────────────────────────
# Common cluster management commands
# ─────────────────────────────────────────────────────────────────

# Show cluster details:
az aks show --resource-group myRG --name myAKS

# Check available upgrades:
az aks get-upgrades --resource-group myRG --name myAKS --output table

# Upgrade cluster:
az aks upgrade \
  --resource-group myRG \
  --name myAKS \
  --kubernetes-version 1.29.5 \
  --yes  # skip confirmation prompt

# Stop cluster (saves VM costs — control plane still billed on Standard tier):
az aks stop --resource-group myRG --name myAKS

# Start cluster:
az aks start --resource-group myRG --name myAKS

# Delete cluster:
az aks delete --resource-group myRG --name myAKS --yes --no-wait
```

---

## Section 8 — Cluster Provisioning: Bicep

### Directory Structure

```
aks-bicep/
├── main.bicep              # Orchestrator — calls all modules
├── main.bicepparam         # Parameter values for each environment
├── modules/
│   ├── network.bicep       # VNet, subnets
│   ├── identity.bicep      # Managed identities
│   ├── loganalytics.bicep  # Log Analytics workspace
│   └── aks.bicep           # AKS cluster + node pools
```

### `main.bicep` — Orchestrator

```bicep
// ─────────────────────────────────────────────────────────────────
// main.bicep — Top-level orchestrator
// Calls modules in dependency order and wires up outputs as inputs
// ─────────────────────────────────────────────────────────────────

targetScope = 'resourceGroup'  // Deploy into a resource group (not subscription)

// ── Parameters ─────────────────────────────────────────────────────
@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment tag: dev, staging, prod')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('Short name prefix for all resources')
param clusterName string

@description('Kubernetes version')
param kubernetesVersion string = '1.29.2'

@description('System node pool VM size')
param systemNodeVmSize string = 'Standard_D4s_v3'

@description('System node count — use 3 for HA, 1 for dev')
@minValue(1)
@maxValue(10)
param systemNodeCount int = 3

@description('Availability zones for node placement')
param availabilityZones array = ['1', '2', '3']

// ── Module: Networking ──────────────────────────────────────────────
module network 'modules/network.bicep' = {
  name: 'network-deployment'
  params: {
    location: location
    environment: environment
    clusterName: clusterName
  }
}

// ── Module: Log Analytics ───────────────────────────────────────────
module loganalytics 'modules/loganalytics.bicep' = {
  name: 'loganalytics-deployment'
  params: {
    location: location
    environment: environment
    clusterName: clusterName
  }
}

// ── Module: AKS Cluster ────────────────────────────────────────────
module aks 'modules/aks.bicep' = {
  name: 'aks-deployment'
  params: {
    location: location
    environment: environment
    clusterName: clusterName
    kubernetesVersion: kubernetesVersion
    systemNodeVmSize: systemNodeVmSize
    systemNodeCount: systemNodeCount
    availabilityZones: availabilityZones
    // Pass outputs from other modules as inputs:
    subnetId: network.outputs.aksSubnetId
    logAnalyticsWorkspaceId: loganalytics.outputs.workspaceId
  }
  dependsOn: [
    network      // Network must exist before AKS
    loganalytics // Workspace must exist before enabling monitoring
  ]
}

// ── Outputs ────────────────────────────────────────────────────────
output clusterName string = aks.outputs.clusterName
output clusterFqdn string = aks.outputs.clusterFqdn
output kubeletIdentityObjectId string = aks.outputs.kubeletIdentityObjectId
```

### `modules/aks.bicep` — AKS Cluster Definition

```bicep
// ─────────────────────────────────────────────────────────────────
// modules/aks.bicep — AKS cluster resource definition
// ─────────────────────────────────────────────────────────────────

param location string
param environment string
param clusterName string
param kubernetesVersion string
param systemNodeVmSize string
param systemNodeCount int
param availabilityZones array
param subnetId string                  // from network.bicep output
param logAnalyticsWorkspaceId string   // from loganalytics.bicep output

// ── Cluster name with environment suffix ────────────────────────────
var aksName = '${clusterName}-${environment}'

// ── User-assigned managed identity for AKS control plane ────────────
resource aksIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${aksName}-identity'
  location: location
}

// ── AKS Cluster Resource ────────────────────────────────────────────
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksName
  location: location
  tags: {
    environment: environment
    managedBy: 'bicep'
  }

  // Cluster tier determines SLA
  sku: {
    name: 'Base'
    tier: environment == 'prod' ? 'Standard' : 'Free'
    // Standard = 99.95% SLA for production
    // Free = no SLA, suitable for dev/staging
  }

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksIdentity.id}': {}  // Reference the managed identity created above
    }
  }

  properties: {
    // ── Kubernetes version ──────────────────────────────────────────
    kubernetesVersion: kubernetesVersion

    // ── DNS prefix for the API server FQDN ─────────────────────────
    dnsPrefix: aksName

    // ── Disable local accounts (enforce Azure AD auth only) ─────────
    disableLocalAccounts: environment == 'prod' ? true : false

    // ── Azure AD / RBAC integration ─────────────────────────────────
    aadProfile: {
      managed: true               // Azure-managed AAD integration (new mode)
      enableAzureRBAC: true       // Use Azure RBAC for K8s authorization
      // adminGroupObjectIDs: ['GROUP_GUID']  // uncomment for admin group
    }

    // ── OIDC Issuer (required for Workload Identity) ─────────────────
    oidcIssuerProfile: {
      enabled: true
    }

    // ── Workload Identity ───────────────────────────────────────────
    securityProfile: {
      workloadIdentity: {
        enabled: true  // Allows pods to use federated identity with Azure services
      }
      imageCleaner: {
        enabled: true     // Auto-clean unused images from nodes
        intervalHours: 48
      }
    }

    // ── Network configuration ───────────────────────────────────────
    networkProfile: {
      networkPlugin: 'azure'         // Azure CNI (pods get VNet IPs)
      networkPolicy: 'calico'        // Calico for NetworkPolicy support
      serviceCidr: '10.0.0.0/16'    // IP range for ClusterIP services
      dnsServiceIP: '10.0.0.10'     // CoreDNS IP (must be in serviceCidr)
      loadBalancerSku: 'standard'    // Standard LB for AZ support
      outboundType: 'loadBalancer'   // Egress via Load Balancer
    }

    // ── System node pool (the "agentPoolProfiles" array) ─────────────
    // First entry = system pool (required)
    agentPoolProfiles: [
      {
        name: 'system'                     // Pool name
        count: systemNodeCount             // Initial node count
        vmSize: systemNodeVmSize           // VM size
        osType: 'Linux'
        osSKU: 'AzureLinux'               // Azure Linux (Mariner) — hardened
        mode: 'System'                    // System mode — runs K8s components
        availabilityZones: availabilityZones
        vnetSubnetID: subnetId            // Place nodes in specific subnet
        maxPods: 30                       // Max pods per node (Azure CNI limits)

        // Cluster autoscaler settings:
        enableAutoScaling: true
        minCount: 1
        maxCount: environment == 'prod' ? 10 : 3

        // OS disk settings:
        osDiskSizeGB: 128
        osDiskType: 'Ephemeral'           // Ephemeral OS disk = faster, no extra cost

        // Auto-upgrade OS patches (not Kubernetes version):
        nodeLabels: {
          'nodepool-type': 'system'
          environment: environment
        }

        // Only system add-ons run here (app pods are blocked by taint):
        nodeTaints: ['CriticalAddonsOnly=true:NoSchedule']
      }
    ]

    // ── Addon profiles ──────────────────────────────────────────────
    addonProfiles: {
      // Container Insights (Azure Monitor integration):
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }

      // Azure Key Vault Secrets Store CSI Driver:
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'    // Auto-rotate secrets from Key Vault
          rotationPollInterval: '2m'      // Check for updated secrets every 2 min
        }
      }

      // Azure Policy for AKS (OPA Gatekeeper):
      azurepolicy: {
        enabled: true
      }
    }

    // ── Auto upgrade channel ─────────────────────────────────────────
    autoUpgradeProfile: {
      upgradeChannel: environment == 'prod' ? 'stable' : 'patch'
      // stable = upgrade to latest stable K8s minor version
      // patch = only upgrade patch versions (safer for prod)
    }

    // ── Node OS upgrade channel ─────────────────────────────────────
    nodeProvisioningProfile: {
      mode: 'Auto'  // AKS manages node provisioning (NP mode)
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// User node pool for application workloads
// Defined as a separate resource (not in agentPoolProfiles array)
// This allows independent management and updating
// ─────────────────────────────────────────────────────────────────
resource appNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2024-02-01' = {
  parent: aksCluster
  name: 'apppool'
  properties: {
    count: environment == 'prod' ? 3 : 1
    vmSize: 'Standard_D8s_v3'            // Larger for app workloads
    osType: 'Linux'
    osSKU: 'AzureLinux'
    mode: 'User'                          // User mode — no system taints
    availabilityZones: availabilityZones
    vnetSubnetID: subnetId
    maxPods: 30
    enableAutoScaling: true
    minCount: environment == 'prod' ? 2 : 0
    maxCount: environment == 'prod' ? 50 : 5
    osDiskType: 'Ephemeral'
    nodeLabels: {
      'nodepool-type': 'app'
      environment: environment
    }
  }
}

// ── Outputs ────────────────────────────────────────────────────────
output clusterName string = aksCluster.name
output clusterFqdn string = aksCluster.properties.fqdn
// Kubelet identity is needed to assign roles (e.g., ACR Pull)
output kubeletIdentityObjectId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
```

---

## Section 9 — Cluster Provisioning: Terraform

### File Structure

```
aks-terraform/
├── providers.tf        # Azure provider configuration
├── variables.tf        # Input variable declarations
├── main.tf             # Core resources: RG, VNet, AKS
├── outputs.tf          # Output values
├── terraform.tfvars    # Variable values (not committed)
└── backend.tf          # Remote state configuration
```

### `providers.tf`

```hcl
# ─────────────────────────────────────────────────────────────────
# providers.tf — Configure Terraform providers
# ─────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.7"   # Enforce minimum Terraform version

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"       # Use any 3.x.x >= 3.100
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
  }
}

# Authenticate via Azure CLI, Service Principal, or Managed Identity
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true  # Safety guard
    }
    key_vault {
      purge_soft_delete_on_destroy = false  # Keep Key Vault recoverable
    }
  }
  subscription_id = var.subscription_id
}
```

### `backend.tf` — Remote State

```hcl
# ─────────────────────────────────────────────────────────────────
# backend.tf — Store Terraform state in Azure Blob Storage
# This prevents state conflicts when multiple people run Terraform
# ─────────────────────────────────────────────────────────────────

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"     # Pre-existing RG for state
    storage_account_name = "tfstatemycompany"       # Pre-existing storage account
    container_name       = "tfstate"                # Blob container
    key                  = "aks/production.tfstate" # Path within container
    # State locking via Blob leases prevents concurrent modifications
  }
}
```

### `variables.tf`

```hcl
# ─────────────────────────────────────────────────────────────────
# variables.tf — All input variable declarations
# ─────────────────────────────────────────────────────────────────

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true   # Won't show in logs
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name: dev, staging, prod"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cluster_name" {
  description = "Base name for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "system_node_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "system_node_count" {
  description = "Node count for system pool"
  type        = number
  default     = 3
}

variable "app_node_min_count" {
  description = "Minimum nodes for app pool autoscaler"
  type        = number
  default     = 2
}

variable "app_node_max_count" {
  description = "Maximum nodes for app pool autoscaler"
  type        = number
  default     = 20
}
```

### `main.tf` — Core Resources

```hcl
# ─────────────────────────────────────────────────────────────────
# main.tf — AKS cluster and supporting resources
# ─────────────────────────────────────────────────────────────────

locals {
  # Resource naming convention: {name}-{env}
  name_prefix = "${var.cluster_name}-${var.environment}"
  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.cluster_name
  }
}

# ── Resource Group ──────────────────────────────────────────────────
resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.common_tags
}

# ── Log Analytics Workspace ─────────────────────────────────────────
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name_prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"    # Pay-per-GB ingestion
  retention_in_days   = 30             # Keep logs for 30 days
  tags                = local.common_tags
}

# ── Virtual Network ─────────────────────────────────────────────────
resource "azurerm_virtual_network" "main" {
  name                = "${local.name_prefix}-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]  # Full VNet CIDR
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  # Azure CNI: each pod gets an IP from this subnet
  # Plan for (max_pods_per_node × max_nodes) IPs
  # 30 pods × 50 nodes = 1500 IPs → /21 subnet (2046 IPs)
  address_prefixes     = ["10.1.0.0/21"]
}

# ── Managed Identity for AKS ────────────────────────────────────────
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${local.name_prefix}-aks-identity"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.common_tags
}

# Grant AKS identity rights to manage the VNet subnet
# (needed for Azure CNI to assign pod IPs)
resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_subnet.aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# ── AKS Cluster ─────────────────────────────────────────────────────
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${local.name_prefix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = local.name_prefix
  kubernetes_version  = var.kubernetes_version
  tags                = local.common_tags

  # ── Cluster tier ───────────────────────────────────────────────────
  sku_tier = var.environment == "prod" ? "Standard" : "Free"

  # ── System node pool ────────────────────────────────────────────────
  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_node_vm_size
    os_sku              = "AzureLinux"
    vnet_subnet_id      = azurerm_subnet.aks.id
    zones               = ["1", "2", "3"]
    max_pods            = 30
    os_disk_type        = "Ephemeral"          # Faster boot, no extra cost
    os_disk_size_gb     = 128

    # Enable autoscaling for system pool too:
    enable_auto_scaling = true
    min_count           = 1
    max_count           = var.environment == "prod" ? 10 : 3

    # Only critical addons run here:
    only_critical_addons_enabled = true

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    upgrade_settings {
      max_surge = "33%"  # Up to 33% extra nodes during upgrade for zero-downtime
    }
  }

  # ── Identity ─────────────────────────────────────────────────────────
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # ── Azure AD (AAD) integration ────────────────────────────────────────
  azure_active_directory_role_based_access_control {
    managed            = true           # Azure-managed AAD integration
    azure_rbac_enabled = true           # Azure RBAC for K8s
  }

  # ── OIDC + Workload Identity ──────────────────────────────────────────
  oidc_issuer_enabled       = true   # Required for Workload Identity
  workload_identity_enabled = true   # Enable pod-level Azure auth

  # ── Networking ────────────────────────────────────────────────────────
  network_profile {
    network_plugin    = "azure"         # Azure CNI
    network_policy    = "calico"        # NetworkPolicy support
    service_cidr      = "10.0.0.0/16"  # ClusterIP address range
    dns_service_ip    = "10.0.0.10"    # CoreDNS IP
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # ── Container Insights (Azure Monitor) ────────────────────────────────
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.main.id
    msi_auth_for_monitoring_enabled = true  # Use managed identity for auth
  }

  # ── Azure Key Vault CSI Driver ─────────────────────────────────────────
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # ── Maintenance window (schedule upgrades outside business hours) ──────
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [1, 2, 3, 4, 5]  # Allow maintenance 1am-6am Sunday
    }
  }

  # ── Auto-upgrade ──────────────────────────────────────────────────────
  automatic_channel_upgrade = var.environment == "prod" ? "patch" : "stable"

  depends_on = [
    azurerm_role_assignment.aks_network
  ]
}

# ── App Node Pool ─────────────────────────────────────────────────────
resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "apppool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D8s_v3"
  os_sku                = "AzureLinux"
  vnet_subnet_id        = azurerm_subnet.aks.id
  zones                 = ["1", "2", "3"]
  max_pods              = 30
  os_disk_type          = "Ephemeral"
  mode                  = "User"        # User mode — no system taints

  enable_auto_scaling = true
  min_count           = var.app_node_min_count
  max_count           = var.app_node_max_count

  node_labels = {
    "nodepool-type" = "app"
    "environment"   = var.environment
  }

  tags = local.common_tags
}
```

### `outputs.tf`

```hcl
# ─────────────────────────────────────────────────────────────────
# outputs.tf — Values to use in other Terraform modules or scripts
# ─────────────────────────────────────────────────────────────────

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_fqdn" {
  description = "Fully-qualified domain name of the API server"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity configuration"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity (for role assignments)"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "kube_config" {
  description = "Raw kubeconfig — sensitive, use with care"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}
```


---

# PART 4 — WORKLOADS

> **Reference App:** All examples in this section deploy `SimpleApi1` and `SimpleApi2` — the .NET 10 Minimal API apps from this repo. They expose `/health`, `/hello/{name?}`, `/info`, and `/weatherforecast`. The Dockerfile listens on port 80.

---

## Section 10 — Deployments

> **Mental Model: Deployment = Fleet Manager, ReplicaSet = Shift Manager, Pod = Worker**
>
> You tell the Fleet Manager "I need 5 workers". The Fleet Manager creates a Shift Manager who maintains exactly 5 workers at all times. If a worker quits (pod crashes), the Shift Manager immediately hires a replacement. When you promote a new worker profile (new image version), the Fleet Manager creates a NEW Shift Manager with the new profile, swaps workers gradually, then retires the old Shift Manager.

### Full Production Deployment — `SimpleApi1`

```yaml
# ─────────────────────────────────────────────────────────────────
# deployment-simpleapi1.yaml
# Deploys the SimpleApi1 .NET 10 application to AKS
# Apply with: kubectl apply -f deployment-simpleapi1.yaml
# ─────────────────────────────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1                        # Deployment name — used in kubectl commands
  namespace: production                   # Namespace scoping (create with: kubectl create ns production)
  labels:
    app: simpleapi1                       # Label on the Deployment object itself
    version: v1
  annotations:
    # Useful for tracking who deployed what and when:
    deployment.kubernetes.io/change-cause: "Initial deploy — SimpleApi1 v1.0.0"

spec:
  # ── How many pod replicas to maintain ───────────────────────────
  replicas: 3                             # 3 running pods — Kubernetes will maintain exactly 3

  # ── Label selector: which pods does this Deployment own? ────────
  selector:
    matchLabels:
      app: simpleapi1                     # Must match .spec.template.metadata.labels

  # ── Rolling update strategy ──────────────────────────────────────
  strategy:
    type: RollingUpdate                   # Default; alternative is Recreate (downtime)
    rollingUpdate:
      maxSurge: 1                         # Allow 1 EXTRA pod above desired during update
                                          # So during update: up to 4 pods running (3 desired + 1 new)
      maxUnavailable: 0                   # Never drop below desired count (zero downtime)
                                          # Combined: always 3 healthy pods, 1 new pod added first

  # ── Revision history (for rollback) ─────────────────────────────
  revisionHistoryLimit: 5                 # Keep last 5 ReplicaSets for rollback (default=10)

  # ── Pod template — blueprint for every pod this Deployment creates
  template:
    metadata:
      labels:
        app: simpleapi1                   # MUST match spec.selector.matchLabels
        version: v1
      annotations:
        # Prometheus scraping annotations (read by kube-prometheus-stack):
        prometheus.io/scrape: "true"
        prometheus.io/port: "80"
        prometheus.io/path: "/metrics"

    spec:
      # ── Service account for Workload Identity (see Section 27) ──
      serviceAccountName: simpleapi1-sa   # Gives pod identity to access Azure services

      # ── Security context for the entire Pod ──────────────────────
      securityContext:
        runAsNonRoot: true                # Pod MUST run as non-root user
        runAsUser: 1000                   # Specific UID
        runAsGroup: 3000
        fsGroup: 2000                     # Files created in volumes owned by this GID
        seccompProfile:
          type: RuntimeDefault            # Use container runtime's default seccomp profile

      # ── Image pull secret (if ACR is private and not auto-integrated) ──
      # imagePullSecrets:
      #   - name: acr-credentials        # Usually not needed if AKS is attached to ACR

      # ── Init containers — run to completion BEFORE app containers start ──
      initContainers:
        - name: migration-check
          image: myacr.azurecr.io/migration-tool:latest
          command: ["sh", "-c", "echo 'DB migration check complete'"]
          # Real use: run EF Core migrations before the API starts

      # ── Main application containers ──────────────────────────────
      containers:
        - name: simpleapi1                # Container name within the pod
          image: myacr.azurecr.io/simpleapi1:1.0.0   # Full image reference with tag
          # NEVER use :latest in production — always use a specific immutable tag

          # ── Container port declaration ───────────────────────────
          ports:
            - name: http                  # Named port — lets Service reference by name
              containerPort: 80           # The port the app listens on (ASPNETCORE_HTTP_PORTS=80)
              protocol: TCP

          # ── Resource requests and limits ─────────────────────────
          # Requests: what Kubernetes RESERVES for this container
          # Limits:   what Kubernetes CAPS the container at
          resources:
            requests:
              cpu: "100m"                 # 100 millicores = 0.1 vCPU
                                          # "requests" affects scheduling: pod only lands on
                                          # nodes with 100m available
              memory: "128Mi"             # 128 MiB reserved
            limits:
              cpu: "500m"                 # 0.5 vCPU max; CPU throttled if exceeded (not killed)
              memory: "256Mi"             # 256 MiB max; process KILLED if exceeded (OOMKilled)
              # Rule of thumb: limits.memory = 2x requests.memory
              # .NET apps: start with 128Mi request, 256Mi limit and tune from metrics

          # ── Environment variables ─────────────────────────────────
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: "Production"
            - name: ASPNETCORE_HTTP_PORTS
              value: "80"
            # Inject pod info (useful for logging/tracing):
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name    # Injects the actual pod name at runtime
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
            # Inject resource limits:
            - name: DOTNET_RUNNING_IN_CONTAINER
              value: "true"
            # From ConfigMap (see Section 22):
            - name: APP_FEATURE_FLAGS
              valueFrom:
                configMapKeyRef:
                  name: simpleapi1-config
                  key: feature-flags
            # From Secret (see Section 23):
            - name: DB_CONNECTION_STRING
              valueFrom:
                secretKeyRef:
                  name: simpleapi1-secrets
                  key: db-connection-string

          # ── Liveness Probe: is the container still alive? ─────────
          # If this fails N times → container is RESTARTED
          livenessProbe:
            httpGet:
              path: /health               # SimpleApi1 exposes this endpoint
              port: http                  # Named port reference
            initialDelaySeconds: 15       # Wait 15s before first probe (app startup time)
            periodSeconds: 20             # Check every 20 seconds
            timeoutSeconds: 5             # Fail if no response in 5s
            failureThreshold: 3           # 3 consecutive failures → restart container

          # ── Readiness Probe: is container ready to receive traffic? ──
          # If this fails → pod REMOVED from Service endpoints (no traffic sent)
          # Container is NOT restarted — it just stops receiving traffic
          readinessProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 5        # Check sooner than liveness (app may be up but warming)
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 3
            successThreshold: 1           # 1 success re-adds pod to load balancer

          # ── Startup Probe: gives slow-starting apps extra time ────
          # Only used during initial startup. While startup probe is failing,
          # liveness/readiness probes are DISABLED. Prevents premature restarts.
          startupProbe:
            httpGet:
              path: /health
              port: http
            initialDelaySeconds: 0
            periodSeconds: 5              # Check every 5 seconds
            failureThreshold: 30          # Give up to 30 * 5 = 150 seconds to start
            # After startup probe succeeds, liveness/readiness take over

          # ── Graceful shutdown ─────────────────────────────────────
          lifecycle:
            preStop:
              exec:
                # Sleep gives the load balancer time to remove this pod from rotation
                # before the pod actually starts shutting down.
                # Without this, in-flight requests can fail during rolling updates.
                command: ["sh", "-c", "sleep 5"]

          # ── Container security context ────────────────────────────
          securityContext:
            allowPrivilegeEscalation: false     # Cannot gain more privileges than parent
            readOnlyRootFilesystem: true         # FS is read-only (app writes to /tmp or mounted volumes)
            capabilities:
              drop:
                - ALL                            # Drop ALL Linux capabilities

          # ── Volume mounts (for ConfigMap/Secret as files) ─────────
          volumeMounts:
            - name: tmp-dir
              mountPath: /tmp              # .NET needs /tmp for temp files when root FS is read-only

      # ── Termination grace period ──────────────────────────────────
      terminationGracePeriodSeconds: 30    # Give app 30s to finish in-flight requests on SIGTERM

      # ── Node scheduling: prefer separate nodes for HA ─────────────
      affinity:
        podAntiAffinity:
          # PREFER (not require) spreading pods across nodes:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values: ["simpleapi1"]
                topologyKey: kubernetes.io/hostname  # Spread across different nodes
          # PREFER spreading across AZs:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 50
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values: ["simpleapi1"]
                topologyKey: topology.kubernetes.io/zone  # Spread across AZs

        # Only schedule on user node pool (not system pool):
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: nodepool-type
                    operator: In
                    values: ["app"]

      # ── Volumes ───────────────────────────────────────────────────
      volumes:
        - name: tmp-dir
          emptyDir: {}                     # Ephemeral in-memory/disk scratch space
```

### Service for SimpleApi1

```yaml
# ─────────────────────────────────────────────────────────────────
# service-simpleapi1.yaml
# ClusterIP service — internal access within the cluster
# Exposes pods with label app=simpleapi1 on port 80
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-svc
  namespace: production
  labels:
    app: simpleapi1
spec:
  type: ClusterIP                         # Internal-only (default)
  selector:
    app: simpleapi1                       # Routes to pods with this label
  ports:
    - name: http
      port: 80                            # Port that the Service listens on
      targetPort: http                    # Named port on the pod (maps to 80)
      protocol: TCP
```

### Pod Disruption Budget

```yaml
# ─────────────────────────────────────────────────────────────────
# pdb-simpleapi1.yaml
# PodDisruptionBudget: prevents too many pods being down at once
# Respected during: node drains, cluster upgrades, maintenance
# ─────────────────────────────────────────────────────────────────
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: simpleapi1-pdb
  namespace: production
spec:
  minAvailable: 2                         # At least 2 pods must be available
  # Alternative: maxUnavailable: 1        # At most 1 pod can be unavailable
  selector:
    matchLabels:
      app: simpleapi1
```

### Rolling Update and Rollback Commands

```bash
# ─────────────────────────────────────────────────────────────────
# Update the image to a new version (triggers rolling update)
# ─────────────────────────────────────────────────────────────────
kubectl set image deployment/simpleapi1 \
  simpleapi1=myacr.azurecr.io/simpleapi1:2.0.0 \
  -n production \
  --record   # records the command in revision history

# Watch the rollout progress:
kubectl rollout status deployment/simpleapi1 -n production

# View rollout history:
kubectl rollout history deployment/simpleapi1 -n production

# View details of a specific revision:
kubectl rollout history deployment/simpleapi1 -n production --revision=2

# ─────────────────────────────────────────────────────────────────
# ROLLBACK: something broke in v2.0.0, roll back to previous version
# ─────────────────────────────────────────────────────────────────
kubectl rollout undo deployment/simpleapi1 -n production

# Rollback to a specific revision:
kubectl rollout undo deployment/simpleapi1 -n production --to-revision=1

# ─────────────────────────────────────────────────────────────────
# Pause a rollout (e.g., to validate partial rollout)
# ─────────────────────────────────────────────────────────────────
kubectl rollout pause deployment/simpleapi1 -n production
# ... inspect, test ...
kubectl rollout resume deployment/simpleapi1 -n production

# ─────────────────────────────────────────────────────────────────
# Scale manually
# ─────────────────────────────────────────────────────────────────
kubectl scale deployment/simpleapi1 --replicas=5 -n production

# ─────────────────────────────────────────────────────────────────
# Restart all pods (rolling restart, useful when ConfigMap changes)
# ─────────────────────────────────────────────────────────────────
kubectl rollout restart deployment/simpleapi1 -n production
```

---

## Section 11 — StatefulSets

> **Mental Model: StatefulSet = Named Employees with Dedicated Desks**
>
> Unlike a Deployment where pods are interchangeable (any pod-A can replace any other pod-A), a StatefulSet gives each pod a permanent identity: `mydb-0`, `mydb-1`, `mydb-2`. Each has its own dedicated storage (desk). If `mydb-1` is restarted, it comes back as `mydb-1` with the same storage — not as some random pod. Pods are created in order (0 first, then 1, then 2) and deleted in reverse order.

### When to Use StatefulSet vs Deployment

| Scenario | Use |
|----------|-----|
| Stateless web API, workers | **Deployment** |
| Database (PostgreSQL, MongoDB, MySQL) | **StatefulSet** |
| Message broker (Kafka, RabbitMQ) | **StatefulSet** |
| Caching cluster (Redis Cluster) | **StatefulSet** |
| Any app needing stable pod hostname | **StatefulSet** |

### Full StatefulSet — Redis for SimpleApi Caching

```yaml
# ─────────────────────────────────────────────────────────────────
# statefulset-redis.yaml
# Redis deployed as a StatefulSet — each pod gets its own PVC
# Used by SimpleApi1/2 for distributed caching
# ─────────────────────────────────────────────────────────────────

# 1. Headless Service — required by StatefulSet for DNS-based pod addressing
# This creates DNS entries: redis-0.redis-headless.production.svc.cluster.local
apiVersion: v1
kind: Service
metadata:
  name: redis-headless                   # "headless" = no ClusterIP (clusterIP: None)
  namespace: production
spec:
  clusterIP: None                        # ← This makes it headless
  selector:
    app: redis
  ports:
    - port: 6379
      targetPort: 6379
---
# 2. Regular Service for client connections (round-robin across all pods)
apiVersion: v1
kind: Service
metadata:
  name: redis-svc
  namespace: production
spec:
  type: ClusterIP
  selector:
    app: redis
  ports:
    - port: 6379
      targetPort: 6379
---
# 3. The StatefulSet itself
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis                            # pods will be named: redis-0, redis-1, redis-2
  namespace: production
spec:
  serviceName: redis-headless            # MUST reference the headless service name
  replicas: 3                            # Creates redis-0, redis-1, redis-2 (in order)

  selector:
    matchLabels:
      app: redis

  # ── Update strategy ──────────────────────────────────────────────
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0                       # Update all pods; set to N to do canary (only pods >= N updated)

  # ── Pod template ─────────────────────────────────────────────────
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7.2-alpine
          ports:
            - containerPort: 6379
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          # Each pod gets its own data volume (see volumeClaimTemplates below)
          volumeMounts:
            - name: redis-data            # matches name in volumeClaimTemplates
              mountPath: /data            # Redis stores data here
          command:
            - redis-server
            - "--appendonly"
            - "yes"                       # Enable persistence (writes to /data)

  # ── VolumeClaimTemplates — per-pod PVC provisioning ──────────────
  # Each pod gets its OWN PVC created automatically:
  # redis-data-redis-0, redis-data-redis-1, redis-data-redis-2
  volumeClaimTemplates:
    - metadata:
        name: redis-data                  # name prefix for PVCs
      spec:
        accessModes:
          - ReadWriteOnce                 # Only one pod can write at a time (per disk)
        storageClassName: managed-csi     # Azure managed disk (SSD)
        resources:
          requests:
            storage: 10Gi                # 10 GiB per pod
```

### Key StatefulSet Behaviors

```bash
# Pods created in ORDER (0, 1, 2). Pod N won't start until pod N-1 is Running:
kubectl get pods -n production -l app=redis -w
# NAME      READY   STATUS    RESTARTS   AGE
# redis-0   1/1     Running   0          2m    ← first
# redis-1   1/1     Running   0          90s   ← second
# redis-2   1/1     Running   0          60s   ← third

# Pods have STABLE DNS names (serviceName.namespace.svc.cluster.local):
# redis-0.redis-headless.production.svc.cluster.local → redis-0's IP
# redis-1.redis-headless.production.svc.cluster.local → redis-1's IP

# PVCs persist even if pods are deleted:
kubectl get pvc -n production
# NAME                STATUS   VOLUME         CAPACITY   ACCESS MODES
# redis-data-redis-0  Bound    pvc-xxxx       10Gi       RWO
# redis-data-redis-1  Bound    pvc-yyyy       10Gi       RWO

# Deleting StatefulSet does NOT delete PVCs (data preserved!):
kubectl delete statefulset redis -n production
kubectl get pvc -n production   # PVCs still exist

# To also delete PVCs, delete them explicitly:
kubectl delete pvc -l app=redis -n production
```

---

## Section 12 — DaemonSets

> **Mental Model: DaemonSet = Security Guard in Every Building**
>
> You need one guard per building (node), no matter how many buildings you have. As new buildings are added (new nodes join the cluster), a guard is automatically placed there. As buildings are torn down, the guard leaves too. This is how log collectors, monitoring agents, and network plugins work.

### Full DaemonSet — Fluent Bit Log Collector

```yaml
# ─────────────────────────────────────────────────────────────────
# daemonset-fluentbit.yaml
# Fluent Bit runs on EVERY node to collect container logs
# and forward them to Azure Log Analytics
# ─────────────────────────────────────────────────────────────────
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: kube-system                 # System namespace for infrastructure pods
  labels:
    app: fluent-bit
spec:
  selector:
    matchLabels:
      app: fluent-bit

  # ── Update strategy ───────────────────────────────────────────────
  updateStrategy:
    type: RollingUpdate                  # Update one node at a time
    rollingUpdate:
      maxUnavailable: 1                  # At most 1 node without log collection during update

  template:
    metadata:
      labels:
        app: fluent-bit
    spec:
      # ── ServiceAccount for Kubernetes API access ──────────────────
      serviceAccountName: fluent-bit     # Needs read access to pod logs

      # ── Tolerations — allow this DaemonSet on system/tainted nodes ─
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          operator: Exists
          effect: NoSchedule             # Run on control plane nodes too (if any are accessible)
        - key: CriticalAddonsOnly
          operator: Exists
          effect: NoSchedule             # Run on system node pool

      # ── Host access ───────────────────────────────────────────────
      # DaemonSets often need host-level access that regular app pods don't need
      hostNetwork: false
      hostPID: false

      containers:
        - name: fluent-bit
          image: cr.fluentbit.io/fluent/fluent-bit:3.0
          resources:
            requests:
              cpu: "50m"
              memory: "50Mi"
            limits:
              cpu: "100m"
              memory: "100Mi"
          env:
            - name: FLUENT_CONF
              value: /fluent-bit/etc/fluent-bit.conf
            - name: LOG_ANALYTICS_WORKSPACE_ID
              valueFrom:
                secretKeyRef:
                  name: fluent-bit-secrets
                  key: workspace-id
          volumeMounts:
            # Mount the host's /var/log to read container logs:
            - name: varlog
              mountPath: /var/log
              readOnly: true
            # Mount the host's container log directory:
            - name: varlibdockercontainers
              mountPath: /var/lib/docker/containers
              readOnly: true
            # Fluent Bit configuration:
            - name: config
              mountPath: /fluent-bit/etc/

      # Volumes mount host paths — only DaemonSets and system pods do this
      volumes:
        - name: varlog
          hostPath:
            path: /var/log               # Host node's /var/log
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
        - name: config
          configMap:
            name: fluent-bit-config
```

### Node Selection — Targeting Specific Node Pools

```yaml
# Run DaemonSet ONLY on nodes with label nodepool-type=app
# (skip system nodes)
spec:
  template:
    spec:
      nodeSelector:
        nodepool-type: "app"             # Only app pool nodes

      # OR use node affinity for more complex rules:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/os
                    operator: In
                    values: ["linux"]    # Only Linux nodes (skip Windows)
```

---

## Section 13 — Jobs & CronJobs

> **Mental Model: Job = One-time Delivery, CronJob = Recurring Subscription**
>
> A Job is like a FedEx delivery — you create it once, it runs to completion, and then it's done. A CronJob is a subscription delivery — it triggers a new delivery on a schedule. Each triggered delivery is a new Job.

### Job — Database Migration

```yaml
# ─────────────────────────────────────────────────────────────────
# job-db-migration.yaml
# Runs EF Core migrations for SimpleApi1 before deployment
# ─────────────────────────────────────────────────────────────────
apiVersion: batch/v1
kind: Job
metadata:
  name: simpleapi1-db-migrate-v2         # Unique name per run; include version to avoid conflicts
  namespace: production
  labels:
    app: simpleapi1
    task: migration
spec:
  # ── Retry policy ──────────────────────────────────────────────────
  backoffLimit: 3                        # Retry up to 3 times before marking Job as Failed
  activeDeadlineSeconds: 300            # Kill the Job if not done in 5 minutes

  # ── Cleanup: delete pod after job succeeds ─────────────────────────
  ttlSecondsAfterFinished: 3600          # Delete completed job (and its pods) after 1 hour

  # ── Parallel execution ─────────────────────────────────────────────
  completions: 1                         # Total number of successful completions required
  parallelism: 1                         # Max pods running at once (for parallel batch processing)
  # For parallel processing: completions=10, parallelism=3 → runs 3 pods at a time, 10 total

  template:
    metadata:
      labels:
        app: simpleapi1
        task: migration
    spec:
      # Jobs MUST specify restartPolicy (Never or OnFailure):
      restartPolicy: Never               # On failure, create a NEW pod (don't restart same pod)
      # Use OnFailure to restart the SAME pod (simpler, but can lose logs)

      containers:
        - name: migration
          image: myacr.azurecr.io/simpleapi1:2.0.0   # Same image as deployment
          command: ["dotnet", "SimpleApi.dll", "--migrate"]
          # Real scenario: command: ["dotnet", "ef", "database", "update"]
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: "Production"
            - name: DB_CONNECTION_STRING
              valueFrom:
                secretKeyRef:
                  name: simpleapi1-secrets
                  key: db-connection-string
```

### CronJob — Nightly Report Generator

```yaml
# ─────────────────────────────────────────────────────────────────
# cronjob-nightly-report.yaml
# Generates and emails a nightly usage report
# ─────────────────────────────────────────────────────────────────
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-report
  namespace: production
spec:
  # ── Cron schedule syntax: minute hour day-of-month month day-of-week
  schedule: "0 2 * * *"                 # 2:00 AM every day (UTC)
  # Other examples:
  # "*/5 * * * *"  → every 5 minutes
  # "0 */6 * * *"  → every 6 hours
  # "0 9 * * 1-5"  → 9 AM Monday-Friday
  # "0 0 1 * *"    → midnight on 1st of every month

  # ── Timezone (K8s 1.27+) ─────────────────────────────────────────
  timeZone: "America/New_York"           # Schedule in Eastern time (not UTC)

  # ── Concurrency policy ────────────────────────────────────────────
  concurrencyPolicy: Forbid              # Don't start new job if previous run still going
  # Allow  = allow concurrent jobs (default)
  # Forbid = skip new job if previous still running
  # Replace = cancel previous job and start new one

  # ── Missed run handling ───────────────────────────────────────────
  startingDeadlineSeconds: 3600         # If job was missed, start it if within 1 hour of schedule
  # e.g., if cluster was down, start the 2 AM job if it's still before 3 AM

  # ── Job history ────────────────────────────────────────────────────
  successfulJobsHistoryLimit: 3         # Keep last 3 successful jobs for inspection
  failedJobsHistoryLimit: 5             # Keep last 5 failed jobs for debugging

  # ── Job template (same as a regular Job) ─────────────────────────
  jobTemplate:
    spec:
      backoffLimit: 2
      ttlSecondsAfterFinished: 86400    # Delete after 24 hours
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: report-generator
              image: myacr.azurecr.io/report-generator:1.0.0
              resources:
                requests:
                  cpu: "200m"
                  memory: "512Mi"
                limits:
                  cpu: "1000m"
                  memory: "1Gi"
```

### Job Management Commands

```bash
# View all jobs and their status:
kubectl get jobs -n production

# Watch a job's pods:
kubectl get pods -n production -l task=migration -w

# Get job logs:
kubectl logs -n production -l task=migration

# Delete a completed job:
kubectl delete job simpleapi1-db-migrate-v2 -n production

# Trigger a CronJob manually (creates a one-off Job from the CronJob template):
kubectl create job --from=cronjob/nightly-report manual-run-$(date +%s) -n production

# Suspend a CronJob (pause future runs):
kubectl patch cronjob nightly-report -n production -p '{"spec":{"suspend":true}}'

# Resume a suspended CronJob:
kubectl patch cronjob nightly-report -n production -p '{"spec":{"suspend":false}}'
```

---

# PART 5 — SERVICES & NETWORKING

---

## Section 14 — Service Types

> **Mental Model: A Service is a stable phone number for a group of pods.**
>
> Pods are ephemeral — they crash and get new IPs. A Service gives you one stable IP/DNS name that always routes to healthy pods, even as individual pods come and go. Think of it as a virtual switchboard that forwards calls to available operators.

```
WITHOUT SERVICE:                    WITH SERVICE:
  Pod-A: 10.244.1.5                   Service "simpleapi1-svc"
  Pod-B: 10.244.2.7    <── IPs        DNS: simpleapi1-svc.production.svc.cluster.local
  Pod-C: 10.244.3.9        change!    Stable ClusterIP: 10.0.0.55
  Pod-D: (crashed)                    Routes to all healthy pods automatically
```

### ClusterIP — Internal-Only Service

```yaml
# ─────────────────────────────────────────────────────────────────
# ClusterIP: only accessible WITHIN the cluster
# Default type. Used for service-to-service communication.
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-svc
  namespace: production
spec:
  type: ClusterIP                        # Default — accessible only within cluster
  selector:
    app: simpleapi1                      # Routes to pods matching this label
  ports:
    - name: http
      port: 80                           # Port clients connect TO
      targetPort: 80                     # Port on the pod to forward to

# DNS resolution within cluster:
# simpleapi1-svc                        → works within same namespace
# simpleapi1-svc.production             → works from other namespaces
# simpleapi1-svc.production.svc.cluster.local  → fully-qualified
```

### NodePort — Direct Node Access

```yaml
# ─────────────────────────────────────────────────────────────────
# NodePort: opens a port on EVERY node in the cluster
# Access: http://<node-external-ip>:<nodePort>
# Use case: dev/testing, or when you manage your own load balancer
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-nodeport
  namespace: production
spec:
  type: NodePort
  selector:
    app: simpleapi1
  ports:
    - port: 80                           # ClusterIP port
      targetPort: 80                     # Pod port
      nodePort: 30080                    # Port opened on every node (30000-32767)
      # Omit nodePort to let K8s assign a random port in range

# Traffic flow:
# Client → NodeIP:30080 → Service:80 → Pod:80
```

### LoadBalancer — Azure Load Balancer Integration

```yaml
# ─────────────────────────────────────────────────────────────────
# LoadBalancer: provisions an Azure Load Balancer with a Public IP
# This is the primary way to expose services externally in AKS.
# Azure CCM (Cloud Controller Manager) creates the Azure LB automatically.
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-lb
  namespace: production
  annotations:
    # Use internal load balancer (private IP) instead of public:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    # Specify the subnet for internal LB:
    service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "internal-lb-subnet"
    # Assign a specific static IP (must be pre-allocated in Azure):
    # service.beta.kubernetes.io/azure-pip-name: "my-static-pip"
    # Set idle timeout (seconds, 4-120):
    service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout: "30"
spec:
  type: LoadBalancer
  selector:
    app: simpleapi1
  ports:
    - name: http
      port: 80
      targetPort: 80
  # Ensure traffic only goes to nodes that have a pod (better performance):
  externalTrafficPolicy: Local           # Local = no SNAT, preserves client IP
  # Cluster = distributes across all nodes (default, adds 1 hop for non-local pods)

# After applying: kubectl get svc simpleapi1-lb -n production
# EXTERNAL-IP column shows the Azure Public/Private IP (takes ~1-2 minutes to provision)
```

### ExternalName — DNS Alias to External Service

```yaml
# ─────────────────────────────────────────────────────────────────
# ExternalName: creates a DNS alias to an external service
# No pods, no proxying — just DNS CNAME record
# Use case: reference Azure SQL, Azure Redis, or external APIs by K8s name
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: azure-sql-db
  namespace: production
spec:
  type: ExternalName
  externalName: myserver.database.windows.net   # Azure SQL server FQDN
  # Now pods can connect to "azure-sql-db" and it resolves to the Azure SQL server
  # No need to change connection strings when migrating between environments
```

### Service Type Comparison

```
Request flow diagram:

ClusterIP:
  Pod-A ──────────────────────► Service (ClusterIP: 10.0.0.55:80) ──► Pod-B
  (within cluster only)

NodePort:
  External Client ──► Node-1:30080
                  ──► Node-2:30080  ──► Service (ClusterIP) ──► Pod
                  ──► Node-3:30080

LoadBalancer:
  External Client ──► Azure LB (Public IP: 52.x.x.x:80) ──► Node:NodePort ──► Service ──► Pod

Ingress (see Section 15):
  External Client ──► Azure LB ──► Ingress Controller Pod ──► Service ──► Pod
                                   (NGINX/AGIC routes by host/path)
```

---

## Section 15 — Ingress & Ingress Controllers

> **Mental Model: Ingress is the smart receptionist, Services are internal extensions.**
>
> A LoadBalancer Service gives you one external IP per service — expensive and unwieldy. An Ingress Controller is a single reverse proxy (like NGINX) that sits at one IP and intelligently routes requests to different services based on hostname or URL path. One IP, many services.

```
WITHOUT INGRESS (expensive):           WITH INGRESS (smart):
  52.1.1.1:80 → simpleapi1-svc         52.1.1.1:80
  52.2.2.2:80 → simpleapi2-svc            /api/v1/* → simpleapi1-svc
  52.3.3.3:80 → frontend-svc             /api/v2/* → simpleapi2-svc
  = 3 Azure Load Balancers ($$$)          /       → frontend-svc
                                       = 1 Azure Load Balancer ($)
```

### Install NGINX Ingress Controller via Helm

```bash
# ─────────────────────────────────────────────────────────────────
# Add the ingress-nginx Helm repo
# ─────────────────────────────────────────────────────────────────
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# ─────────────────────────────────────────────────────────────────
# Install NGINX Ingress Controller
# Creates a LoadBalancer Service (Azure LB with public IP)
# ─────────────────────────────────────────────────────────────────
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.resources.requests.cpu=100m \
  --set controller.resources.requests.memory=90Mi

# Get the external IP assigned to the ingress controller:
kubectl get svc -n ingress-nginx ingress-nginx-controller
# NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)
# ingress-nginx-controller   LoadBalancer   10.0.0.190   52.x.x.x      80:30080/TCP,443:30443/TCP
```

### Ingress with Path-Based Routing

```yaml
# ─────────────────────────────────────────────────────────────────
# ingress-apps.yaml
# Routes requests to SimpleApi1 and SimpleApi2 based on URL path
# ─────────────────────────────────────────────────────────────────
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: apps-ingress
  namespace: production
  annotations:
    # Specify which ingress controller handles this (by class name):
    kubernetes.io/ingress.class: nginx
    # Nginx-specific annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2          # Strips prefix before sending to backend
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"       # Max request body size
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "10"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    # Rate limiting:
    nginx.ingress.kubernetes.io/limit-rps: "50"              # Max 50 req/sec per IP
    # CORS:
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://myapp.com"
spec:
  # ── IngressClass (newer way to specify controller vs annotation) ──
  ingressClassName: nginx

  # ── TLS termination ──────────────────────────────────────────────
  tls:
    - hosts:
        - api.mycompany.com
      secretName: tls-api-mycompany-com   # K8s Secret with TLS cert/key
      # cert-manager auto-creates this Secret (see below)

  # ── Routing rules ──────────────────────────────────────────────────
  rules:
    - host: api.mycompany.com             # Only match this hostname
      http:
        paths:
          # Route /api/v1/* to SimpleApi1:
          - path: /api/v1(/|$)(.*)        # Regex path (with rewrite-target: /$2)
            pathType: Prefix
            backend:
              service:
                name: simpleapi1-svc
                port:
                  number: 80

          # Route /api/v2/* to SimpleApi2:
          - path: /api/v2(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: simpleapi2-svc
                port:
                  number: 80

          # Default catch-all:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-svc
                port:
                  number: 80
```

### cert-manager — Automatic TLS Certificates

```bash
# ─────────────────────────────────────────────────────────────────
# Install cert-manager (manages TLS certs from Let's Encrypt)
# ─────────────────────────────────────────────────────────────────
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true    # Install Custom Resource Definitions
```

```yaml
# ─────────────────────────────────────────────────────────────────
# clusterissuer-letsencrypt.yaml
# Cluster-wide certificate issuer using Let's Encrypt
# ─────────────────────────────────────────────────────────────────
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory   # Let's Encrypt production
    email: admin@mycompany.com                                 # Your email for cert expiry alerts
    privateKeySecretRef:
      name: letsencrypt-prod-key                              # Stores the ACME account key
    solvers:
      - http01:                                               # HTTP-01 challenge
          ingress:
            class: nginx
```

```yaml
# Add annotation to Ingress to trigger auto-cert issuance:
metadata:
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"   # cert-manager sees this and issues cert
# cert-manager will:
# 1. Create a Certificate resource
# 2. Talk to Let's Encrypt
# 3. Create the Secret "tls-api-mycompany-com" with the cert
# 4. Auto-renew 30 days before expiry
```

---

## Section 16 — CNI Plugins

> **Mental Model: CNI = The plumbing that gives every pod its own phone line.**
>
> Every pod needs a unique IP address so it can communicate. The CNI (Container Network Interface) plugin is the plumber that wires up this network when a pod is created. The choice of CNI determines IP allocation strategy, performance, and features.

### CNI Options in AKS

| Plugin | Pod IPs | Scale | Features | Use When |
|--------|---------|-------|---------|----------|
| **Kubenet** | From pod CIDR (not VNet) | 400 nodes / 250 pods/node | Basic, UDR routing | Dev/test, small clusters, IP-constrained VNets |
| **Azure CNI** | From VNet subnet | 400 nodes / 250 pods/node | VNet integration, NSG support | Production, need VNet-native IPs |
| **Azure CNI Overlay** | From pod CIDR overlay | 1000 nodes | Conserves VNet IPs, still VNet integration | Large clusters, limited VNet IP space |
| **Azure CNI + Cilium** | From VNet or overlay | 1000 nodes | eBPF, advanced NetPol, Hubble observability | Best performance + security, eBPF networking |

### IP Planning for Azure CNI

```
PROBLEM: Azure CNI assigns VNet IPs to pods. You must plan IP space carefully.

Example cluster:
  - 10 nodes
  - 30 pods per node max
  = 10 × 30 = 300 pod IPs needed
  PLUS: 10 node IPs
  PLUS: service CIDR (10.0.0.0/16 = separate, non-overlapping)
  TOTAL: 310+ IPs → need at least a /23 subnet (512 IPs)

  For growth to 50 nodes × 30 pods = 1500 pod IPs → /21 subnet (2046 IPs)

                    ┌─── VNet: 10.1.0.0/16 ───────────────────┐
                    │                                          │
                    │  ┌── AKS Subnet: 10.1.0.0/21 ────────┐  │
                    │  │  Node IPs: 10.1.0.4 – 10.1.0.54   │  │
                    │  │  Pod IPs:  10.1.1.0 – 10.1.7.254  │  │
                    │  └──────────────────────────────────--┘  │
                    │                                          │
                    │  Service CIDR: 10.0.0.0/16 (separate)   │
                    └──────────────────────────────────────────┘
```

### Create Cluster with Azure CNI Overlay (Recommended for Large Clusters)

```bash
az aks create \
  --resource-group myRG \
  --name myAKS \
  --network-plugin azure \
  --network-plugin-mode overlay \        # ← Overlay mode conserves VNet IPs
  --pod-cidr 192.168.0.0/16 \           # Pod IPs from this range (not VNet)
  --network-policy cilium \             # Use Cilium for network policies
  --network-dataplane cilium            # Use Cilium eBPF dataplane (fastest)
```

---

## Section 17 — Network Policies

> **Mental Model: NetworkPolicy = Pod-level Firewall Rules.**
>
> By default, all pods can talk to all other pods in the cluster (no network isolation). NetworkPolicy lets you define "pod A can only receive traffic from pod B on port 5432, and nothing else." Without a NetworkPolicy, every pod is wide open.

### Default-Deny Policy (Best Practice)

```yaml
# ─────────────────────────────────────────────────────────────────
# netpol-default-deny.yaml
# Deny ALL ingress and egress traffic in the namespace by default.
# Then add explicit allow policies for what IS needed.
# Apply this first, then add specific allow policies.
# ─────────────────────────────────────────────────────────────────
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}                        # {} = select ALL pods in namespace
  policyTypes:
    - Ingress
    - Egress
  # No ingress/egress rules = deny all matching traffic types
```

### Allow Traffic Between SimpleApi1 and SimpleApi2

```yaml
# ─────────────────────────────────────────────────────────────────
# Allow simpleapi2 to call simpleapi1 on port 80
# All other ingress to simpleapi1 is denied (from default-deny above)
# ─────────────────────────────────────────────────────────────────
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-simpleapi2-to-simpleapi1
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: simpleapi1                    # This policy applies to simpleapi1 pods

  policyTypes:
    - Ingress

  ingress:
    - from:
        # Allow from pods with label app=simpleapi2:
        - podSelector:
            matchLabels:
              app: simpleapi2
        # Allow from the ingress controller namespace:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-nginx
      ports:
        - port: 80
          protocol: TCP
```

### Allow DNS Egress (Critical!)

```yaml
# ─────────────────────────────────────────────────────────────────
# After default-deny, pods cannot do DNS lookups (CoreDNS is blocked).
# This breaks service discovery. Always allow DNS egress.
# ─────────────────────────────────────────────────────────────────
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: production
spec:
  podSelector: {}                        # All pods
  policyTypes:
    - Egress
  egress:
    - ports:
        - port: 53                       # DNS
          protocol: UDP
        - port: 53
          protocol: TCP
      to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system  # CoreDNS lives here
```

---

## Section 18 — Private Clusters & Azure Private Link

> **Mental Model: Private Cluster = Your API server is behind a locked door with no public keyhole.**
>
> By default, the AKS API server has a public endpoint (you can run `kubectl` from anywhere). In a private cluster, the API server endpoint is only accessible from within your VNet (or peered networks). This removes the API server from the internet entirely.

### Options: Public vs Authorized IPs vs Private

```
PUBLIC CLUSTER (default):
  Your laptop ──────────────────► API Server (public endpoint 52.x.x.x:443)
  CI/CD agent  ──────────────────► (any IP can try to connect)
  Attacker     ──────────────────► (internet-exposed, brute-force possible)

AUTHORIZED IP RANGES (middle ground):
  Your IP      ──────────────────► API Server (public, but only from allowed IPs)
  CI/CD agent  ──────────────────► (allowlisted IPs only)
  Attacker     ──── BLOCKED ──────X (internet blocked)

PRIVATE CLUSTER (most secure):
  Your laptop ──► VPN/Bastion ──► VNet ──► API Server (private endpoint)
  CI/CD agent ──► Self-hosted agent in VNet ──► API Server
  Attacker    ──────────────────────────X (not reachable from internet)
```

### Create a Private Cluster

```bash
# ─────────────────────────────────────────────────────────────────
# Private cluster: API server only accessible via private endpoint
# You MUST access it from within the VNet (or peered/connected network)
# ─────────────────────────────────────────────────────────────────
az aks create \
  --resource-group myRG \
  --name myAKSPrivate \
  --enable-private-cluster \             # ← Private cluster
  --private-dns-zone system \            # AKS manages the private DNS zone
  # Alternative: --private-dns-zone <resource-id> for BYO DNS zone
  \
  # If you need public FQDN for monitoring tools (no kubectl access, just FQDN):
  --enable-private-cluster-public-fqdn \ # Adds public FQDN pointing to private IP
  \
  --network-plugin azure \
  --vnet-subnet-id /subscriptions/.../subnets/aks-subnet

# ─────────────────────────────────────────────────────────────────
# Authorized IP ranges (easier alternative to full private cluster)
# ─────────────────────────────────────────────────────────────────
az aks create \
  --resource-group myRG \
  --name myAKSAuth \
  --api-server-authorized-ip-ranges "10.0.0.0/8,203.0.113.5/32"
  # 10.0.0.0/8 = your corporate network
  # 203.0.113.5/32 = specific CI/CD server IP

# Update authorized IPs on existing cluster:
az aks update \
  --resource-group myRG \
  --name myAKSAuth \
  --api-server-authorized-ip-ranges "10.0.0.0/8,198.51.100.0/32"
```

---

# PART 6 — STORAGE

---

## Section 19 — Storage Architecture

> **Mental Model: Storage is like hotel rooms.**
>
> A PersistentVolume (PV) is a hotel room — a real storage resource that exists independently. A PersistentVolumeClaim (PVC) is a guest's reservation — a request for a room with specific requirements (size, bed type). The hotel manager (StorageClass) handles creating rooms on demand. Once a guest (pod) checks in, that room is their exclusive space.

```
STORAGE BINDING FLOW:

 Developer writes:          Kubernetes does:              Azure provisions:
 ┌──────────────┐          ┌───────────────┐             ┌───────────────┐
 │     PVC      │──────────►  StorageClass  │─────────────►  Azure Disk   │
 │ 10Gi / RWO   │  dynamic │  (provisioner)│  API call   │  or           │
 │ managed-csi  │  prov.   │               │             │  Azure Files  │
 └──────────────┘          └───────────────┘             └───────┬───────┘
        │                                                         │
        │           Kubernetes creates PV automatically:          │
        │           ┌───────────────┐                            │
        └───────────►      PV        │◄───────────────────────────┘
                    │ 10Gi / RWO    │  PV wraps the Azure resource
                    └───────┬───────┘
                            │ binds to
                    ┌───────▼───────┐
                    │   Pod spec    │
                    │ volumeMounts: │
                    │   /data       │
                    └───────────────┘
```

### Access Modes

| Mode | Abbreviation | Meaning | Azure Support |
|------|-------------|---------|--------------|
| `ReadWriteOnce` | RWO | One pod can read/write | Azure Disk, Azure Files |
| `ReadOnlyMany` | ROX | Many pods can read | Azure Files |
| `ReadWriteMany` | RWX | Many pods can read/write | Azure Files, Azure NetApp Files |
| `ReadWriteOncePod` | RWOP | Only ONE pod (not just one node) | Azure Disk (CSI) |

> **Key Insight:** Azure Disk is block storage — `ReadWriteOnce` only. If multiple pods need to share storage, use Azure Files (NFS/SMB) for `ReadWriteMany`.

---

## Section 20 — Storage Classes

### Built-in AKS Storage Classes

```bash
# View available storage classes:
kubectl get storageclass

# NAME                    PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE
# azurefile               file.csi.azure.com         Delete          Immediate
# azurefile-csi           file.csi.azure.com         Delete          Immediate
# azurefile-csi-premium   file.csi.azure.com         Delete          Immediate
# azurefile-premium       file.csi.azure.com         Delete          Immediate
# default (*)             disk.csi.azure.com         Delete          WaitForFirstConsumer
# managed                 disk.csi.azure.com         Delete          WaitForFirstConsumer
# managed-csi             disk.csi.azure.com         Delete          WaitForFirstConsumer  ← recommended
# managed-csi-premium     disk.csi.azure.com         Delete          WaitForFirstConsumer  ← fast SSD
# managed-premium         disk.csi.azure.com         Delete          WaitForFirstConsumer
```

### Custom StorageClass

```yaml
# ─────────────────────────────────────────────────────────────────
# storageclass-fast-ssd.yaml
# Premium SSD with RETAIN policy (don't delete disk when PVC deleted)
# ─────────────────────────────────────────────────────────────────
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd-retain
provisioner: disk.csi.azure.com          # Azure Disk CSI driver
parameters:
  skuName: Premium_LRS                   # Premium SSD locally redundant
  # Other options: Standard_LRS, StandardSSD_LRS, UltraSSD_LRS
  kind: Managed                          # Use managed disks
  cachingmode: ReadOnly                  # Read caching (for read-heavy workloads)
  # enableBursting: "true"              # Enable disk bursting (Premium only)
reclaimPolicy: Retain                    # RETAIN: when PVC deleted, PV and disk are KEPT
# Delete = disk deleted when PVC deleted (default, be careful!)
# Retain = disk kept (must manually delete; safe for databases)
volumeBindingMode: WaitForFirstConsumer  # Don't create disk until pod is scheduled
# Immediate = create disk immediately (may be in wrong AZ!)
allowVolumeExpansion: true               # Allow PVC size to be increased online
```

```yaml
# ─────────────────────────────────────────────────────────────────
# storageclass-azurefiles-rwx.yaml
# Azure Files for ReadWriteMany (shared storage between pods)
# ─────────────────────────────────────────────────────────────────
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-files-premium
provisioner: file.csi.azure.com
parameters:
  skuName: Premium_LRS                   # Premium Files (NFS, faster)
  protocol: nfs                          # NFS protocol (better than SMB for Linux)
mountOptions:
  - nconnect=8                           # Use 8 parallel TCP connections (performance)
reclaimPolicy: Delete
volumeBindingMode: Immediate             # Files can be created immediately (no AZ binding)
allowVolumeExpansion: true
```

---

## Section 21 — PV and PVC Code Examples

### Dynamic PVC Provisioning (Most Common)

```yaml
# ─────────────────────────────────────────────────────────────────
# pvc-simpleapi-data.yaml
# Dynamic PVC — StorageClass creates Azure Disk automatically
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: simpleapi-data
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce                      # Only one pod writes at a time
  storageClassName: managed-csi          # Uses Azure Disk CSI driver
  resources:
    requests:
      storage: 20Gi                      # Request 20 GiB
```

```yaml
# Reference the PVC in your Deployment/StatefulSet:
spec:
  template:
    spec:
      containers:
        - name: simpleapi1
          volumeMounts:
            - name: app-data
              mountPath: /app/data       # App reads/writes here
      volumes:
        - name: app-data
          persistentVolumeClaim:
            claimName: simpleapi-data    # References the PVC above
```

### Expand a PVC Online

```bash
# Increase PVC size (StorageClass must have allowVolumeExpansion: true):
kubectl patch pvc simpleapi-data -n production \
  -p '{"spec":{"resources":{"requests":{"storage":"50Gi"}}}}'

# Watch the expansion:
kubectl describe pvc simpleapi-data -n production
# Conditions: FileSystemResizePending → then disappears when done
# The pod does NOT need to restart for disk expansion (Azure Disk CSI v2+)
```

### Volume Snapshot and Restore

```bash
# Install Volume Snapshot CRDs and controller (if not present):
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
```

```yaml
# ─────────────────────────────────────────────────────────────────
# volumesnapshotclass-azure.yaml
# ─────────────────────────────────────────────────────────────────
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: azure-disk-snapshot
driver: disk.csi.azure.com
deletionPolicy: Delete                   # Delete snapshot when VolumeSnapshot is deleted
---
# ─────────────────────────────────────────────────────────────────
# Take a snapshot of the PVC:
# ─────────────────────────────────────────────────────────────────
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: simpleapi-data-snapshot-20240101
  namespace: production
spec:
  volumeSnapshotClassName: azure-disk-snapshot
  source:
    persistentVolumeClaimName: simpleapi-data   # Snapshot this PVC
---
# ─────────────────────────────────────────────────────────────────
# Restore snapshot into a new PVC:
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: simpleapi-data-restored
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-csi
  resources:
    requests:
      storage: 20Gi
  dataSource:
    name: simpleapi-data-snapshot-20240101   # Restore from this snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

---

# PART 7 — CONFIGURATION & SECRETS

---

## Section 22 — ConfigMaps

> **Mental Model: ConfigMap = Application's environment-specific settings file.**
>
> Instead of baking configuration into your container image (which would require rebuilding for every environment change), ConfigMaps let you inject configuration from outside the container. The same image can run in dev with dev settings and in prod with prod settings.

### Create ConfigMap from Various Sources

```bash
# ─────────────────────────────────────────────────────────────────
# From literal values:
# ─────────────────────────────────────────────────────────────────
kubectl create configmap simpleapi1-config \
  --from-literal=feature-flags="dark-mode,new-dashboard" \
  --from-literal=log-level="Information" \
  --from-literal=api-timeout="30" \
  -n production

# ─────────────────────────────────────────────────────────────────
# From a file (key = filename, value = file contents):
# ─────────────────────────────────────────────────────────────────
kubectl create configmap simpleapi1-appsettings \
  --from-file=appsettings.Production.json \
  -n production

# ─────────────────────────────────────────────────────────────────
# From an env file (.env format: KEY=VALUE per line):
# ─────────────────────────────────────────────────────────────────
kubectl create configmap simpleapi1-env \
  --from-env-file=production.env \
  -n production
```

### ConfigMap YAML Definition

```yaml
# ─────────────────────────────────────────────────────────────────
# configmap-simpleapi1.yaml
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: ConfigMap
metadata:
  name: simpleapi1-config
  namespace: production
data:
  # Simple key-value pairs:
  log-level: "Information"
  feature-flags: "dark-mode,new-dashboard"
  api-timeout: "30"

  # Multi-line config file embedded in ConfigMap:
  appsettings.json: |
    {
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft.AspNetCore": "Warning"
        }
      },
      "AppSettings": {
        "FeatureFlags": "dark-mode,new-dashboard",
        "Timeout": 30
      }
    }

  # Nginx config example:
  nginx.conf: |
    server {
      listen 80;
      location /health {
        return 200 'OK';
      }
    }
```

### Using ConfigMap in Pod

```yaml
spec:
  containers:
    - name: simpleapi1
      # ── Method 1: Inject as environment variables (individual keys) ──
      env:
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: simpleapi1-config
              key: log-level              # Inject specific key

      # ── Method 2: Inject ALL keys as env vars ──────────────────────
      envFrom:
        - configMapRef:
            name: simpleapi1-config       # ALL keys become env vars
            # log-level → LOG_LEVEL (key names become env var names)

      # ── Method 3: Mount as files in a directory ──────────────────────
      volumeMounts:
        - name: config-volume
          mountPath: /app/config          # Files appear here
          readOnly: true

  volumes:
    - name: config-volume
      configMap:
        name: simpleapi1-config           # Each key becomes a file
        # /app/config/appsettings.json  → contains the JSON from the ConfigMap
        # /app/config/nginx.conf        → contains the nginx config
        # Optional: mount only specific keys as specific file names:
        items:
          - key: appsettings.json
            path: appsettings.Production.json   # Custom file name
```

---

## Section 23 — Kubernetes Secrets

> **Key Insight: Kubernetes Secrets are NOT encrypted by default!**
> Base64 encoding is NOT encryption. Anyone with `kubectl get secret` access can decode them. For true secret management, use Azure Key Vault (Section 24) or enable Encryption At Rest via Azure Disk Encryption.

### Secret Types

| Type | Use Case |
|------|----------|
| `Opaque` | Generic secrets (passwords, API keys, tokens) |
| `kubernetes.io/tls` | TLS certificates and private keys |
| `kubernetes.io/dockerconfigjson` | Container registry credentials |
| `kubernetes.io/service-account-token` | Service account tokens (auto-created) |

### Create Secrets

```bash
# ─────────────────────────────────────────────────────────────────
# Opaque secret from literals (most common):
# ─────────────────────────────────────────────────────────────────
kubectl create secret generic simpleapi1-secrets \
  --from-literal=db-connection-string="Server=myserver;Database=mydb;User=admin;Password=mypassword" \
  --from-literal=jwt-secret-key="super-secret-key-do-not-commit" \
  -n production

# ─────────────────────────────────────────────────────────────────
# TLS secret from certificate files:
# ─────────────────────────────────────────────────────────────────
kubectl create secret tls tls-api-mycompany-com \
  --cert=./tls.crt \
  --key=./tls.key \
  -n production

# ─────────────────────────────────────────────────────────────────
# Docker registry secret (for pulling from private ACR):
# ─────────────────────────────────────────────────────────────────
kubectl create secret docker-registry acr-credentials \
  --docker-server=myacr.azurecr.io \
  --docker-username=myacr \
  --docker-password="$(az acr credential show -n myacr --query passwords[0].value -o tsv)" \
  -n production
```

### Secret YAML (Base64 encoded values)

```yaml
# ─────────────────────────────────────────────────────────────────
# secret-simpleapi1.yaml
# Values must be base64-encoded (echo -n "value" | base64)
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: Secret
metadata:
  name: simpleapi1-secrets
  namespace: production
type: Opaque
data:
  # echo -n "Server=myserver;..." | base64
  db-connection-string: U2VydmVyPW15c2VydmVy...   # base64 encoded
  jwt-secret-key: c3VwZXItc2VjcmV0...             # base64 encoded
# ─────────────────────────────────────────────────────────────────
# stringData: allows plain text (K8s base64-encodes it automatically)
# Use this in development, but do NOT commit to Git!
# ─────────────────────────────────────────────────────────────────
stringData:
  api-key: "my-plain-text-api-key"      # K8s auto-encodes this
```

---

## Section 24 — Azure Key Vault Integration

> **Mental Model: Key Vault CSI Driver = Secure vault delivery service.**
>
> Instead of your app calling Key Vault directly (requiring SDK, auth code, retry logic), the CSI Driver acts as a delivery service: it authenticates to Key Vault before your pod starts, fetches the secrets, and delivers them as files or environment variables into your pod. Your app just reads files/env vars — it never needs to know about Key Vault.

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      POD STARTUP FLOW                           │
│                                                                  │
│  1. Pod scheduled on node                                        │
│  2. CSI Driver reads SecretProviderClass (what to fetch)         │
│  3. CSI Driver uses pod's Workload Identity to auth to Key Vault │
│  4. CSI Driver fetches secrets/certs/keys from Key Vault         │
│  5. CSI Driver mounts them as files in the pod's filesystem      │
│  6. (Optional) Syncs to Kubernetes Secrets for env var use       │
│  7. Pod starts with secrets available                            │
│                                                                  │
│  Every 2 minutes: CSI Driver re-fetches to detect rotations      │
└─────────────────────────────────────────────────────────────────┘
```

### Full Setup: Key Vault → Pod

**Step 1: Create Managed Identity and grant Key Vault access**

```bash
# ─────────────────────────────────────────────────────────────────
# Create a user-assigned managed identity for SimpleApi1
# ─────────────────────────────────────────────────────────────────
az identity create \
  --name simpleapi1-identity \
  --resource-group myRG

IDENTITY_CLIENT_ID=$(az identity show \
  --name simpleapi1-identity \
  --resource-group myRG \
  --query clientId -o tsv)

IDENTITY_OBJECT_ID=$(az identity show \
  --name simpleapi1-identity \
  --resource-group myRG \
  --query principalId -o tsv)

# ─────────────────────────────────────────────────────────────────
# Grant identity access to Key Vault secrets
# ─────────────────────────────────────────────────────────────────
KEY_VAULT_ID=$(az keyvault show --name myKeyVault --query id -o tsv)

az role assignment create \
  --assignee $IDENTITY_OBJECT_ID \
  --role "Key Vault Secrets User" \       # Read secrets only (least privilege)
  --scope $KEY_VAULT_ID

# ─────────────────────────────────────────────────────────────────
# Create federated credential (links K8s ServiceAccount to managed identity)
# This is the OIDC bridge that allows the pod to authenticate
# ─────────────────────────────────────────────────────────────────
AKS_OIDC_ISSUER=$(az aks show \
  --resource-group myRG \
  --name myAKS \
  --query oidcIssuerProfile.issuerUrl -o tsv)

az identity federated-credential create \
  --name simpleapi1-federated-cred \
  --identity-name simpleapi1-identity \
  --resource-group myRG \
  --issuer $AKS_OIDC_ISSUER \
  --subject "system:serviceaccount:production:simpleapi1-sa" \
  # ^ Format: system:serviceaccount:<namespace>:<service-account-name>
  --audiences "api://AzureADTokenExchange"
```

**Step 2: Create Kubernetes ServiceAccount**

```yaml
# serviceaccount-simpleapi1.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: simpleapi1-sa                    # Must match subject in federated credential
  namespace: production
  annotations:
    # Link to the Azure managed identity:
    azure.workload.identity/client-id: "IDENTITY_CLIENT_ID_HERE"
  labels:
    azure.workload.identity/use: "true"  # Required label
```

**Step 3: Create SecretProviderClass**

```yaml
# ─────────────────────────────────────────────────────────────────
# secretproviderclass-simpleapi1.yaml
# Defines WHICH secrets to pull from Key Vault and HOW to mount them
# ─────────────────────────────────────────────────────────────────
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: simpleapi1-kv-secrets
  namespace: production
spec:
  provider: azure                        # Azure Key Vault provider

  parameters:
    usePodIdentity: "false"             # Use Workload Identity (not pod identity)
    clientID: "IDENTITY_CLIENT_ID_HERE" # Managed identity client ID

    # Key Vault URL:
    keyvaultName: myKeyVault
    tenantId: "YOUR_TENANT_ID"

    # Which secrets/keys/certs to fetch:
    objects: |
      array:
        - |
          objectName: db-connection-string      # Secret name in Key Vault
          objectType: secret                    # secret, key, or cert
          objectVersion: ""                     # "" = latest version
        - |
          objectName: jwt-signing-key
          objectType: secret
          objectVersion: ""
        - |
          objectName: tls-certificate
          objectType: cert                      # Fetches cert + private key

  # Optional: Sync to Kubernetes Secrets (for env var injection)
  secretObjects:
    - secretName: simpleapi1-kv-synced         # K8s Secret name to create
      type: Opaque
      data:
        - objectName: db-connection-string     # Must match objectName above
          key: db-connection-string            # Key in the K8s Secret
        - objectName: jwt-signing-key
          key: jwt-signing-key
```

**Step 4: Mount in Pod**

```yaml
spec:
  serviceAccountName: simpleapi1-sa      # ServiceAccount with workload identity

  containers:
    - name: simpleapi1
      # Use secrets as env vars (from synced K8s Secret):
      env:
        - name: DB_CONNECTION_STRING
          valueFrom:
            secretKeyRef:
              name: simpleapi1-kv-synced
              key: db-connection-string
      # OR mount as files:
      volumeMounts:
        - name: secrets-store
          mountPath: /mnt/secrets-store   # Each secret becomes a file here
          readOnly: true

  volumes:
    - name: secrets-store
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: simpleapi1-kv-secrets   # Reference the SPC
```


---

# PART 8 — RBAC & SECURITY

---

## Section 25 — Kubernetes RBAC

> **Mental Model: RBAC = A building's access card system.**
>
> Roles define what doors (resources) can be opened with what actions (verbs). A RoleBinding issues an access card to a person (Subject: user, group, or ServiceAccount) that grants the role's permissions. A ClusterRole is a master key that works everywhere; a Role only works on one floor (namespace).

### RBAC Object Relationships

```
              WHO can do WHAT on WHICH resources?
              │            │          │
              Subject      Verbs      Resources
              ├─ User       ├─ get     ├─ pods
              ├─ Group      ├─ list    ├─ deployments
              └─ ServiceAcct├─ create  ├─ services
                            ├─ update  ├─ secrets
                            ├─ patch   └─ ...
                            ├─ delete
                            └─ watch

              Role / ClusterRole  ←─── defines verbs+resources
                    │
              RoleBinding / ClusterRoleBinding ←─── links Subject to Role
```

### Read-Only Developer Role

```yaml
# ─────────────────────────────────────────────────────────────────
# role-developer-readonly.yaml
# Allows developers to view resources but not modify them
# Namespace-scoped (only works in "production" namespace)
# ─────────────────────────────────────────────────────────────────
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer-readonly
  namespace: production
rules:
  # Allow read-only access to workloads:
  - apiGroups: ["", "apps", "batch"]   # "" = core API group (pods, services, etc.)
    resources:
      - pods
      - pods/log                        # kubectl logs
      - pods/exec                       # kubectl exec (add if needed)
      - deployments
      - replicasets
      - statefulsets
      - daemonsets
      - jobs
      - cronjobs
      - services
      - endpoints
      - configmaps                      # Be cautious — may contain sensitive config
    verbs: ["get", "list", "watch"]     # Read-only verbs
  # Allow port-forward for debugging:
  - apiGroups: [""]
    resources: ["pods/portforward"]
    verbs: ["create"]
  # No access to secrets (sensitive data):
  # secrets are excluded from this role
---
# ─────────────────────────────────────────────────────────────────
# rolebinding-developers.yaml
# Binds the role to an Azure AD group
# ─────────────────────────────────────────────────────────────────
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developers-readonly-binding
  namespace: production
subjects:
  # Bind to an Azure AD group (all members get the role):
  - kind: Group
    name: "azure-ad-group-object-id"    # Azure AD Group Object ID
    apiGroup: rbac.authorization.k8s.io
  # Bind to a specific user:
  - kind: User
    name: "john.doe@mycompany.com"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role                            # Reference a Role (not ClusterRole)
  name: developer-readonly
  apiGroup: rbac.authorization.k8s.io
```

### CI/CD Deployment Role

```yaml
# ─────────────────────────────────────────────────────────────────
# role-cicd-deploy.yaml
# Allows CI/CD pipelines to deploy workloads
# Scoped to production namespace — pipeline can only touch this namespace
# ─────────────────────────────────────────────────────────────────
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cicd-deploy
  namespace: production
rules:
  # Full control of deployments, statefulsets, daemonsets:
  - apiGroups: ["apps"]
    resources: ["deployments", "statefulsets", "daemonsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
    # No "delete" — pipeline shouldn't delete workloads
  # Manage services and configmaps:
  - apiGroups: [""]
    resources: ["services", "configmaps"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  # Create/patch secrets (for image pull secrets):
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list", "create", "patch"]
    # Restricted to what CI/CD actually needs
  # View pods (for rollout status monitoring):
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]
  # Manage Ingress rules:
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  # Manage HPAs:
  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cicd-deploy-binding
  namespace: production
subjects:
  - kind: ServiceAccount
    name: github-actions-sa             # K8s SA used by GitHub Actions / Azure DevOps
    namespace: production
roleRef:
  kind: Role
  name: cicd-deploy
  apiGroup: rbac.authorization.k8s.io
```

### Verify RBAC Permissions

```bash
# ─────────────────────────────────────────────────────────────────
# Check what a user/serviceaccount CAN do:
# ─────────────────────────────────────────────────────────────────

# Can I list pods in production?
kubectl auth can-i list pods -n production

# Can service account cicd-sa create deployments in production?
kubectl auth can-i create deployments \
  --as=system:serviceaccount:production:cicd-sa \
  -n production

# Show ALL permissions for a service account:
kubectl auth can-i --list \
  --as=system:serviceaccount:production:cicd-sa \
  -n production

# Get all role bindings in a namespace:
kubectl get rolebindings,clusterrolebindings -n production -o wide
```

---

## Section 26 — Azure AD Integration & Azure RBAC for AKS

### Enabling Azure RBAC for Kubernetes

When `--enable-azure-rbac` is set on the cluster, Azure RBAC roles control `kubectl` access — no more managing local Kubernetes RBAC for user access. This centralizes identity management in Azure AD.

```
TRADITIONAL K8S RBAC:                AZURE RBAC FOR AKS:
  Manage Roles/RoleBindings            Manage Azure role assignments
  in cluster YAML files                in Azure Portal / CLI
  (team must have cluster access       (team manages via standard
   to grant access to others)           Azure IAM workflow)
```

### Built-in Azure Roles for AKS

| Azure Role | Equivalent K8s RBAC | Description |
|-----------|---------------------|-------------|
| `Azure Kubernetes Service RBAC Cluster Admin` | `cluster-admin` | Full cluster control |
| `Azure Kubernetes Service RBAC Admin` | `admin` (namespace) | Full namespace control |
| `Azure Kubernetes Service RBAC Writer` | `edit` | Create/update/delete resources |
| `Azure Kubernetes Service RBAC Reader` | `view` | Read-only access |

```bash
# ─────────────────────────────────────────────────────────────────
# Grant a user read-only access to the production namespace:
# ─────────────────────────────────────────────────────────────────
CLUSTER_ID=$(az aks show \
  --resource-group myRG \
  --name myAKS \
  --query id -o tsv)

# Grant read-only for ENTIRE cluster:
az role assignment create \
  --assignee john.doe@mycompany.com \
  --role "Azure Kubernetes Service RBAC Reader" \
  --scope $CLUSTER_ID

# Grant write access for a SPECIFIC NAMESPACE only:
az role assignment create \
  --assignee jane.doe@mycompany.com \
  --role "Azure Kubernetes Service RBAC Writer" \
  --scope "${CLUSTER_ID}/namespaces/production"
  # ^ Scoping to namespace is KEY for multi-team clusters

# Grant cluster-admin to the ops team (AAD group):
OPS_GROUP_ID="aad-group-object-id-here"
az role assignment create \
  --assignee $OPS_GROUP_ID \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope $CLUSTER_ID
```

---

## Section 27 — Workload Identity

> **Mental Model: Workload Identity = Pod's company badge for accessing Azure services.**
>
> Your SimpleApi1 pod needs to read secrets from Azure Key Vault. Without Workload Identity, you'd need to store Azure credentials as a Kubernetes Secret (bad: storing secrets to access secrets!). With Workload Identity, the pod carries an OIDC token signed by the cluster, Azure trusts this token, and exchanges it for an Azure access token — no stored credentials needed.

### The OIDC Token Flow

```
AKS Cluster                    Azure AD                     Azure Key Vault
    │                              │                               │
    │  Pod starts with            │                               │
    │  ServiceAccount token        │                               │
    │  (projected volume)          │                               │
    │                              │                               │
    │  App calls Azure SDK ────────►                               │
    │  SDK sends OIDC token ───────►  Validates against            │
    │  to AAD token endpoint        │  cluster's OIDC issuer URL    │
    │                              │  Checks federated credential  │
    │                              │  (SA name + namespace match?) │
    │                              │                               │
    │  ◄── Azure Access Token ──── │                               │
    │                              │                               │
    │  Access Token ───────────────────────────────────────────────►
    │                              │  Key Vault validates token    │
    │  ◄── Secret value ────────────────────────────────────────── │
```

### Full Workload Identity Setup

```bash
# ─────────────────────────────────────────────────────────────────
# Prerequisites: cluster must have OIDC issuer + workload identity enabled
# (--enable-oidc-issuer --enable-workload-identity in az aks create)
# ─────────────────────────────────────────────────────────────────

# 1. Get cluster OIDC issuer URL:
OIDC_ISSUER=$(az aks show \
  --resource-group myRG \
  --name myAKS \
  --query oidcIssuerProfile.issuerUrl -o tsv)

echo "OIDC Issuer: $OIDC_ISSUER"
# Example: https://eastus.oic.prod-aks.azure.com/tenant-id/cluster-id/

# 2. Create user-assigned managed identity:
az identity create \
  --name simpleapi1-wi \
  --resource-group myRG \
  --location eastus

MI_CLIENT_ID=$(az identity show -n simpleapi1-wi -g myRG --query clientId -o tsv)
MI_OBJECT_ID=$(az identity show -n simpleapi1-wi -g myRG --query principalId -o tsv)

# 3. Grant identity access to Azure resources (e.g., Key Vault):
az role assignment create \
  --assignee-object-id $MI_OBJECT_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Key Vault Secrets User" \
  --scope $(az keyvault show -n myKeyVault --query id -o tsv)

# 4. Create federated credential:
#    This is the TRUST link: "If the cluster presents a token for
#    ServiceAccount 'simpleapi1-sa' in namespace 'production',
#    trust it as this managed identity"
az identity federated-credential create \
  --name "simpleapi1-prod-fedcred" \
  --identity-name simpleapi1-wi \
  --resource-group myRG \
  --issuer $OIDC_ISSUER \
  --subject "system:serviceaccount:production:simpleapi1-sa" \
  --audiences "api://AzureADTokenExchange"
```

```yaml
# ─────────────────────────────────────────────────────────────────
# serviceaccount-wi.yaml
# Kubernetes ServiceAccount annotated with Managed Identity client ID
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: ServiceAccount
metadata:
  name: simpleapi1-sa
  namespace: production
  annotations:
    azure.workload.identity/client-id: "MI_CLIENT_ID_HERE"    # Managed identity's client ID
  labels:
    azure.workload.identity/use: "true"                        # Required — enables token injection
```

```yaml
# ─────────────────────────────────────────────────────────────────
# deployment with workload identity
# Pod uses the ServiceAccount above; SDK auto-detects credentials
# ─────────────────────────────────────────────────────────────────
spec:
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"   # Label on pod also needed
    spec:
      serviceAccountName: simpleapi1-sa       # Use the annotated SA

      containers:
        - name: simpleapi1
          # Azure SDK (DefaultAzureCredential) auto-detects the
          # projected service account token and exchanges it for
          # an Azure access token. No credentials in code or env vars.
          env:
            - name: AZURE_CLIENT_ID
              value: "MI_CLIENT_ID_HERE"       # Optional but speeds up credential resolution
```

### .NET Application Code using Workload Identity

```csharp
// Program.cs — SimpleApi1 reading a secret from Key Vault using Workload Identity
// No credentials in code! DefaultAzureCredential auto-detects the projected token.

using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

// ── Key Vault client using Workload Identity ──────────────────────────
// DefaultAzureCredential checks (in order):
// 1. Environment variables (AZURE_CLIENT_ID + AZURE_FEDERATED_TOKEN_FILE)
//    → Projected service account token file (Workload Identity)
// 2. Managed Identity
// 3. Azure CLI (for local dev)
// 4. Visual Studio credentials
var keyVaultUrl = builder.Configuration["KeyVault:Url"]
    ?? throw new InvalidOperationException("KeyVault:Url not configured");

var secretClient = new SecretClient(
    new Uri(keyVaultUrl),
    new DefaultAzureCredential()  // ← No secrets needed; uses OIDC token
);

// Read secret from Key Vault at startup:
var dbConnectionSecret = await secretClient.GetSecretAsync("db-connection-string");
builder.Configuration["ConnectionStrings:Default"] = dbConnectionSecret.Value.Value;

// The pod's AZURE_FEDERATED_TOKEN_FILE env var (auto-injected by workload identity webhook)
// points to a projected token file that DefaultAzureCredential reads automatically.

builder.Services.AddOpenApi();
var app = builder.Build();
app.MapOpenApi();
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));
app.Run();
```

---

## Section 28 — Pod Security Standards & Policy

> **Mental Model: Pod Security Standards = Building codes for your pods.**
>
> Just like a city enforces building codes (you can't build a skyscraper without fire escapes), Pod Security Standards enforce security rules on pods. They prevent common attack vectors like running as root, mounting host paths, or using privileged containers.

### Pod Security Admission (PSA) — K8s 1.25+

PSA replaced PodSecurityPolicy (deprecated in 1.21, removed in 1.25).

```
THREE PROFILES:
┌──────────────┬────────────────────────────────────────────────────┐
│ Privileged   │ No restrictions. For system/infrastructure pods.    │
│              │ (kube-system, monitoring agents, CSI drivers)       │
├──────────────┼────────────────────────────────────────────────────┤
│ Baseline     │ Prevents known privilege escalations.              │
│              │ Allows: running as any user (not root), no host    │
│              │ namespace, no privileged containers                 │
├──────────────┼────────────────────────────────────────────────────┤
│ Restricted   │ Follows pod hardening best practices.              │
│              │ Requires: non-root, drop ALL capabilities,         │
│              │ read-only root FS, seccomp profile                 │
└──────────────┴────────────────────────────────────────────────────┘

THREE MODES (per profile):
  enforce → Reject non-compliant pods (they won't be created)
  audit   → Allow but log non-compliant pods to audit log
  warn    → Allow but show warning to kubectl user
```

### Apply PSA via Namespace Labels

```bash
# ─────────────────────────────────────────────────────────────────
# Label a namespace to enforce security standards:
# ─────────────────────────────────────────────────────────────────

# Production: enforce restricted (most secure):
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted

# Dev: just warn (don't block, but educate developers):
kubectl label namespace development \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/audit=baseline

# System namespaces: privileged (needed for system pods):
kubectl label namespace kube-system \
  pod-security.kubernetes.io/enforce=privileged
```

### OPA Gatekeeper — Custom Policy Engine

For policies beyond Pod Security Standards (e.g., "all images must come from our ACR"):

```bash
# Install OPA Gatekeeper (AKS has it as an add-on):
# Already enabled if you used --enable-addons azure-policy in cluster creation
# Or install directly:
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm install gatekeeper gatekeeper/gatekeeper -n gatekeeper-system --create-namespace
```

```yaml
# ─────────────────────────────────────────────────────────────────
# constrainttemplate-allowedrepos.yaml
# Template: defines the schema and Rego policy logic
# ─────────────────────────────────────────────────────────────────
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: allowedrepos
spec:
  crd:
    spec:
      names:
        kind: AllowedRepos                # Name of the constraint resource
      validation:
        openAPIV3Schema:
          type: object
          properties:
            repos:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package allowedrepos
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          satisfied := [good | repo = input.parameters.repos[_]; startswith(container.image, repo); good = true]
          not any(satisfied)
          msg := sprintf("Container image '%v' is not from an allowed repository", [container.image])
        }
---
# ─────────────────────────────────────────────────────────────────
# constraint-allowedrepos.yaml
# Actual constraint: only allow images from our ACR
# ─────────────────────────────────────────────────────────────────
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: AllowedRepos
metadata:
  name: only-company-acr
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
    namespaces: ["production", "staging"]
    excludedNamespaces: ["kube-system"]
  parameters:
    repos:
      - "myacr.azurecr.io/"             # Only images from our ACR allowed
      - "mcr.microsoft.com/"            # Allow Microsoft images (base images)
```

---

# PART 9 — AUTOSCALING

---

## Section 29 — Horizontal Pod Autoscaler (HPA)

> **Mental Model: HPA = Hiring more workers when the queue grows.**
>
> When your SimpleApi1 is getting hammered with requests, CPU shoots up. HPA notices this and says "we need more workers" — it increases the replica count. When traffic drops, HPA says "we have too many idle workers" and scales back down.

```
        Traffic ──►  Pods (CPU: 80%)
        increase        │
                        ▼
                HPA: desired > target (50%)
                        │
                        ▼
                Scale up: 3 → 6 pods
                        │
        Traffic         ▼
        drops    Pods (CPU: 20%)
                        │
                        ▼
                HPA: utilization < target
                Wait stabilization window
                        │
                        ▼
                Scale down: 6 → 3 pods
```

### Full HPA — CPU and Memory Based

```yaml
# ─────────────────────────────────────────────────────────────────
# hpa-simpleapi1.yaml
# Scales SimpleApi1 based on CPU and memory utilization
# ─────────────────────────────────────────────────────────────────
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: simpleapi1-hpa
  namespace: production
spec:
  # ── Target workload ────────────────────────────────────────────
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: simpleapi1

  # ── Replica bounds ─────────────────────────────────────────────
  minReplicas: 2                         # Never scale below 2 (HA minimum)
  maxReplicas: 20                        # Never scale above 20 (cost ceiling)

  # ── Scaling metrics ────────────────────────────────────────────
  metrics:
    # Scale on CPU utilization (most common):
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60         # Target 60% CPU across all pods
                                         # If avg is 80%, scale up until avg is ~60%
                                         # If avg is 30%, scale down until avg is ~60%

    # Scale on memory utilization:
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 70         # Target 70% memory utilization

    # Scale on absolute CPU value:
    # - type: Resource
    #   resource:
    #     name: cpu
    #     target:
    #       type: AverageValue
    #       averageValue: "300m"         # Target 300 millicores per pod

  # ── Scaling behavior (prevent thrashing) ─────────────────────────
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0     # Scale up immediately (don't wait)
      policies:
        - type: Percent
          value: 100                     # Can double replicas in one step
          periodSeconds: 15
        - type: Pods
          value: 4                       # Or add up to 4 pods
          periodSeconds: 15
      selectPolicy: Max                  # Use whichever policy adds more pods

    scaleDown:
      stabilizationWindowSeconds: 300   # Wait 5 minutes before scaling down
                                         # Prevents premature scale-down when traffic is bursty
      policies:
        - type: Percent
          value: 50                      # Can remove at most 50% of replicas at once
          periodSeconds: 60
        - type: Pods
          value: 2                       # Or remove at most 2 pods
          periodSeconds: 60
      selectPolicy: Min                  # Use whichever policy removes fewer pods (conservative)
```

```bash
# View HPA status:
kubectl get hpa -n production
# NAME             REFERENCE              TARGETS           MINPODS   MAXPODS   REPLICAS
# simpleapi1-hpa   Deployment/simpleapi1  45%/60%, 60%/70%  2         20        3

# Watch HPA decisions in real time:
kubectl describe hpa simpleapi1-hpa -n production
```

---

## Section 30 — Vertical Pod Autoscaler (VPA)

> **Mental Model: VPA = Performance consultant that recommends better equipment.**
>
> Instead of adding more workers (HPA), VPA analyzes how much CPU/memory each pod actually uses and recommends (or applies) better resource requests. If you set requests too low (pod gets throttled) or too high (wastes money), VPA corrects this.

```bash
# Install VPA (not included by default in AKS):
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-up.sh
```

```yaml
# ─────────────────────────────────────────────────────────────────
# vpa-simpleapi1.yaml
# VPA adjusts resource requests for simpleapi1 pods
# ─────────────────────────────────────────────────────────────────
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: simpleapi1-vpa
  namespace: production
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: simpleapi1

  updatePolicy:
    updateMode: "Auto"                   # Modes:
    # "Off"      → Only gives recommendations, never changes requests (safest)
    # "Initial"  → Sets requests when pod first created, never updates running pods
    # "Recreate" → Evicts pods to apply new recommendations (causes restarts)
    # "Auto"     → Like Recreate today (future: in-place updates when K8s supports it)

  # Optional: constrain the recommendations:
  resourcePolicy:
    containerPolicies:
      - containerName: simpleapi1
        minAllowed:
          cpu: "50m"                     # Never recommend less than 50m CPU
          memory: "64Mi"
        maxAllowed:
          cpu: "2000m"                   # Never recommend more than 2 vCPU
          memory: "2Gi"
        controlledResources: ["cpu", "memory"]

# ─────────────────────────────────────────────────────────────────
# View VPA recommendations WITHOUT applying them (updateMode: Off):
# ─────────────────────────────────────────────────────────────────
# kubectl describe vpa simpleapi1-vpa -n production
# Status:
#   Recommendation:
#     Container Recommendations:
#       Container Name: simpleapi1
#       Lower Bound:   cpu:50m  memory:128Mi
#       Target:        cpu:150m memory:192Mi   ← Use these values
#       Upper Bound:   cpu:500m memory:512Mi
```

### VPA vs HPA: When to Use Which

| Scenario | HPA | VPA |
|----------|-----|-----|
| Traffic spikes (web API) | ✓ Scale out | ✗ Can't help with bursty traffic |
| Memory leak in app | ✗ More pods = more memory leaks | ✓ Increase memory limit |
| Right-sizing for cost | ✗ Doesn't change per-pod sizing | ✓ Reduces over-provisioned requests |
| Stateful workloads | Use carefully (sticky sessions) | ✓ Good fit |
| StatefulSets | Limited | ✓ Works well |
| **Combined use** | Use HPA for scale-out, VPA in Off mode for recommendations | Use VPA in Off mode alongside HPA |

> **Key Insight:** Do NOT use VPA Auto/Recreate mode together with HPA on the same deployment for CPU/memory metrics — they fight each other. Use VPA in `Off` mode to get recommendations, then bake those into your Deployment's resource requests. Then use HPA for scaling.

---

## Section 31 — KEDA: Kubernetes Event-Driven Autoscaling

> **Mental Model: KEDA = Auto-staffing based on actual work queue length.**
>
> HPA scales on CPU/memory. But what if your SimpleApi processes Azure Service Bus messages? CPU might be low even with 10,000 messages waiting (messages process fast). KEDA lets you scale on the QUEUE LENGTH directly — 0 pods when queue is empty, 20 pods when 1,000 messages are waiting.

### Install KEDA

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda \
  --namespace keda \
  --create-namespace
```

### ScaledObject — Service Bus Queue Scaler

```yaml
# ─────────────────────────────────────────────────────────────────
# scaledobject-servicebus.yaml
# Scales simpleapi1 based on Azure Service Bus queue length
# Scale to 0 when queue empty, scale up when messages arrive
# ─────────────────────────────────────────────────────────────────
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: simpleapi1-servicebus-scaler
  namespace: production
spec:
  scaleTargetRef:
    name: simpleapi1                     # Target Deployment name

  # ── Replica bounds ─────────────────────────────────────────────
  minReplicaCount: 0                     # Scale TO ZERO when queue empty (saves cost!)
  maxReplicaCount: 30                    # Max pods when queue is large

  # ── Polling interval ───────────────────────────────────────────
  pollingInterval: 15                    # Check queue length every 15 seconds
  cooldownPeriod: 300                    # Wait 5 min before scaling to zero (let queue drain)

  # ── Advanced scaling behavior ──────────────────────────────────
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 120

  # ── Triggers: what drives the scaling decision ─────────────────
  triggers:
    # Azure Service Bus trigger:
    - type: azure-servicebus
      metadata:
        queueName: simpleapi1-input-queue
        namespace: myservicebus.servicebus.windows.net
        messageCount: "5"                # Target: 5 messages per pod
                                         # 50 messages → 10 pods
                                         # 0 messages  → 0 pods (after cooldown)
      # Authentication: use TriggerAuthentication with Workload Identity:
      authenticationRef:
        name: servicebus-trigger-auth
---
# ─────────────────────────────────────────────────────────────────
# TriggerAuthentication using Workload Identity
# ─────────────────────────────────────────────────────────────────
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: servicebus-trigger-auth
  namespace: production
spec:
  podIdentity:
    provider: azure-workload              # Use pod's Workload Identity
    identityId: "MANAGED_IDENTITY_CLIENT_ID"
```

### ScaledObject — HTTP-Based Scaling

```yaml
# ─────────────────────────────────────────────────────────────────
# Scale based on active HTTP connections (requires KEDA HTTP add-on)
# ─────────────────────────────────────────────────────────────────
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: simpleapi1-http-scaler
  namespace: production
spec:
  scaleTargetRef:
    name: simpleapi1
  minReplicaCount: 1                     # HTTP scaler can't scale to 0 without add-on
  maxReplicaCount: 20
  triggers:
    - type: prometheus                   # Scale on Prometheus metric
      metadata:
        serverAddress: http://prometheus-server.monitoring.svc.cluster.local
        metricName: http_requests_total
        query: |
          sum(rate(http_requests_total{app="simpleapi1"}[1m]))
        threshold: "100"                 # Target: 100 req/sec per pod
```

### ScaledJob — Process Queue Messages Once and Exit

```yaml
# ─────────────────────────────────────────────────────────────────
# scaledjob-message-processor.yaml
# Creates one Job per batch of messages; each Job processes then exits
# Better for long-running message processing (vs keeping pods warm)
# ─────────────────────────────────────────────────────────────────
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: message-processor
  namespace: production
spec:
  jobTargetRef:
    template:
      spec:
        restartPolicy: Never
        containers:
          - name: processor
            image: myacr.azurecr.io/message-processor:1.0.0
  pollingInterval: 10
  maxReplicaCount: 50                    # Max 50 concurrent jobs
  triggers:
    - type: azure-servicebus
      metadata:
        queueName: heavy-processing-queue
        namespace: myservicebus.servicebus.windows.net
        messageCount: "1"                # 1 job per message
```

---

## Section 32 — Cluster Autoscaler

> **Mental Model: Cluster Autoscaler = Hiring more buildings when all apartments are full.**
>
> When HPA/KEDA need more pods but all nodes are full, pods stay in `Pending` state. The Cluster Autoscaler sees pending pods and adds a new node. When nodes are underutilized (all pods fit on fewer nodes), it cordons and drains an underutilized node, then deletes the VM.

```
POD PENDING (no space on nodes)
        │
        ▼
Cluster Autoscaler detects unschedulable pod
        │
        ▼
Evaluates: Can any new node type fit this pod?
  (Checks resource requests, taints, node affinity)
        │
        ▼
Triggers: az VMSS scale-out → New node joins cluster
        │
        ▼
Scheduler places pending pod on new node

─────────────────────────────────────────────────────

NODE UNDERUTILIZED (utilization < 50%, pods can move)
        │
        ▼
Cluster Autoscaler: all pods fit on other nodes?
  Checks: PodDisruptionBudgets, local storage, affinity
        │
        ▼
Cordon node (no new pods) → Drain node (evict pods)
        │
        ▼
Pods rescheduled to other nodes
        │
        ▼
Delete VM (cost saved!)
```

### Cluster Autoscaler Configuration

```bash
# Enable autoscaler on existing cluster:
az aks update \
  --resource-group myRG \
  --name myAKS \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 20

# Update autoscaler settings via profile:
az aks update \
  --resource-group myRG \
  --name myAKS \
  --cluster-autoscaler-profile \
    scan-interval=30s \               # How often to re-evaluate (default: 10s)
    scale-down-delay-after-add=10m \  # Wait 10 min after adding node before considering scale-down
    scale-down-unneeded-time=10m \    # Node must be unneeded for 10 min before removal
    scale-down-utilization-threshold=0.5 \  # Remove nodes below 50% utilization
    skip-nodes-with-local-storage=false \   # Allow removing nodes with emptyDir volumes
    skip-nodes-with-system-pods=true        # Don't remove nodes running system pods
```

### Key Interaction: PodDisruptionBudgets

The Cluster Autoscaler **respects PodDisruptionBudgets**. If draining a node would violate a PDB (drop below `minAvailable`), the autoscaler won't drain that node. This is why setting PDBs properly (Section 10) is critical for both upgrades and autoscaling.

```
Example:
  simpleapi1-pdb: minAvailable=2
  3 pods on 3 different nodes

  Autoscaler wants to drain node-1 (underutilized)
  → node-1 has simpleapi1 pod
  → Draining would temporarily leave 2 pods
  → 2 >= minAvailable (2) → ALLOWED (PDB satisfied)
  → Drain proceeds

  But if minAvailable=3 and only 3 pods:
  → Draining would leave 2 pods
  → 2 < minAvailable (3) → BLOCKED
  → Node NOT drained
```

---

# PART 10 — OBSERVABILITY

---

## Section 33 — Azure Monitor & Container Insights

> **Mental Model: Container Insights = Your cluster's vital signs monitor.**
>
> Without Container Insights, your cluster is a black box — you can't tell if pods are crashing, nodes are running out of memory, or which namespace is consuming the most resources. Container Insights automatically collects metrics and logs from every node and pod into Azure Log Analytics.

### Enable Container Insights

```bash
# ─────────────────────────────────────────────────────────────────
# On new cluster (in az aks create):
# --enable-addons monitoring --workspace-resource-id $WORKSPACE_ID

# On existing cluster:
# ─────────────────────────────────────────────────────────────────
az aks enable-addons \
  --resource-group myRG \
  --name myAKS \
  --addons monitoring \
  --workspace-resource-id \
    "/subscriptions/SUB_ID/resourceGroups/myRG/providers/Microsoft.OperationalInsights/workspaces/myLAWorkspace"

# Enable Azure Managed Prometheus (newer, metric-focused):
az aks update \
  --resource-group myRG \
  --name myAKS \
  --enable-azure-monitor-metrics \
  --azure-monitor-workspace-resource-id \
    "/subscriptions/SUB_ID/resourceGroups/myRG/providers/microsoft.monitor/accounts/myAMW"
```

### Key Metrics and KQL Queries

```kql
// ─────────────────────────────────────────────────────────────────
// KQL: Node CPU utilization over time
// ─────────────────────────────────────────────────────────────────
Perf
| where ObjectName == "K8SNode" and CounterName == "cpuUsageNanoCores"
| summarize avg(CounterValue) by bin(TimeGenerated, 5m), Computer
| render timechart

// ─────────────────────────────────────────────────────────────────
// KQL: Pods with high restart counts (unhealthy pods)
// ─────────────────────────────────────────────────────────────────
KubePodInventory
| where TimeGenerated > ago(1h)
| where RestartCount > 3
| summarize RestartCount = max(RestartCount) by PodName, ContainerName, Namespace
| order by RestartCount desc

// ─────────────────────────────────────────────────────────────────
// KQL: OOMKilled events (pod killed for using too much memory)
// ─────────────────────────────────────────────────────────────────
KubePodInventory
| where ContainerLastStatus == "OOMKilled"
| project TimeGenerated, PodName, ContainerName, Namespace, RestartCount

// ─────────────────────────────────────────────────────────────────
// KQL: Container logs for simpleapi1 (last 100 error logs)
// ─────────────────────────────────────────────────────────────────
ContainerLogV2
| where ContainerName == "simpleapi1"
| where LogMessage contains "Error" or LogMessage contains "Exception"
| order by TimeGenerated desc
| take 100

// ─────────────────────────────────────────────────────────────────
// KQL: Resource consumption by namespace
// ─────────────────────────────────────────────────────────────────
KubePodInventory
| where TimeGenerated > ago(1h)
| summarize PodCount = dcount(PodName) by Namespace
| order by PodCount desc

// ─────────────────────────────────────────────────────────────────
// KQL: Node disk pressure events
// ─────────────────────────────────────────────────────────────────
KubeNodeInventory
| where TimeGenerated > ago(24h)
| where Status contains "DiskPressure" or Status contains "MemoryPressure"
| project TimeGenerated, Computer, Status

// ─────────────────────────────────────────────────────────────────
// KQL: Failed pod scheduling events (pending pods)
// ─────────────────────────────────────────────────────────────────
KubeEvents
| where TimeGenerated > ago(1h)
| where Reason == "FailedScheduling"
| project TimeGenerated, Name, Namespace, Message
| order by TimeGenerated desc
```

### Alert Rules

```bash
# ─────────────────────────────────────────────────────────────────
# Create alert: pod restart count > 5 in 30 minutes
# ─────────────────────────────────────────────────────────────────
az monitor scheduled-query create \
  --resource-group myRG \
  --name "AKS-Pod-RestartAlert" \
  --scopes "/subscriptions/SUB_ID/resourceGroups/myRG/providers/Microsoft.OperationalInsights/workspaces/myLAWorkspace" \
  --condition-query "KubePodInventory | where RestartCount > 5 | summarize count()" \
  --condition-threshold 0 \
  --condition-operator GreaterThan \
  --evaluation-frequency 5 \
  --window-size 30 \
  --severity 2 \
  --action-groups "/subscriptions/SUB_ID/resourceGroups/myRG/providers/Microsoft.Insights/actionGroups/myActionGroup"
```

---

## Section 34 — Prometheus & Grafana on AKS

### Azure Managed Prometheus + Azure Managed Grafana

```bash
# ─────────────────────────────────────────────────────────────────
# Create Azure Monitor Workspace (stores Prometheus metrics):
# ─────────────────────────────────────────────────────────────────
az resource create \
  --resource-group myRG \
  --namespace microsoft.monitor \
  --resource-type accounts \
  --name myAzureMonitorWorkspace \
  --location eastus \
  --properties '{}'

# ─────────────────────────────────────────────────────────────────
# Create Azure Managed Grafana:
# ─────────────────────────────────────────────────────────────────
az grafana create \
  --name myGrafana \
  --resource-group myRG

# ─────────────────────────────────────────────────────────────────
# Link cluster → Azure Monitor Workspace → Grafana:
# ─────────────────────────────────────────────────────────────────
GRAFANA_ID=$(az grafana show --name myGrafana -g myRG --query id -o tsv)
AMW_ID=$(az resource show -g myRG -n myAzureMonitorWorkspace --namespace microsoft.monitor --resource-type accounts --query id -o tsv)

az aks update \
  --resource-group myRG \
  --name myAKS \
  --enable-azure-monitor-metrics \
  --azure-monitor-workspace-resource-id $AMW_ID \
  --grafana-resource-id $GRAFANA_ID
```

### Self-Managed Prometheus via kube-prometheus-stack

```bash
# ─────────────────────────────────────────────────────────────────
# Install kube-prometheus-stack (Prometheus + Grafana + AlertManager):
# ─────────────────────────────────────────────────────────────────
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=15d \   # Keep 15 days of metrics
  --set grafana.adminPassword=admin123 \
  --set alertmanager.enabled=true \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=managed-csi \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi
```

### Custom PrometheusRule for SimpleApi1

```yaml
# ─────────────────────────────────────────────────────────────────
# prometheusrule-simpleapi1.yaml
# Custom alerting rules for SimpleApi1
# ─────────────────────────────────────────────────────────────────
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: simpleapi1-alerts
  namespace: monitoring
  labels:
    release: prometheus                  # Must match Prometheus operator's ruleSelector
spec:
  groups:
    - name: simpleapi1.rules
      interval: 30s
      rules:
        # Alert when error rate exceeds 5%:
        - alert: SimpleApi1HighErrorRate
          expr: |
            sum(rate(http_requests_total{app="simpleapi1", status=~"5.."}[5m]))
            /
            sum(rate(http_requests_total{app="simpleapi1"}[5m]))
            > 0.05
          for: 2m                        # Must be true for 2 minutes before firing
          labels:
            severity: warning
            team: platform
          annotations:
            summary: "SimpleApi1 high error rate"
            description: "Error rate is {{ $value | humanizePercentage }} (> 5%)"

        # Alert when pod restart count is high:
        - alert: SimpleApi1FrequentRestarts
          expr: |
            increase(kube_pod_container_status_restarts_total{
              namespace="production", container="simpleapi1"
            }[1h]) > 5
          for: 0m                        # Fire immediately
          labels:
            severity: critical
          annotations:
            summary: "SimpleApi1 restarting frequently"
            description: "Pod {{ $labels.pod }} restarted {{ $value }} times in the last hour"
```

---

## Section 35 — Distributed Tracing & Logging

### Application Insights with OpenTelemetry (.NET)

```xml
<!-- Add to SimpleApi1.csproj -->
<PackageReference Include="Azure.Monitor.OpenTelemetry.AspNetCore" Version="1.*" />
```

```csharp
// Program.cs — Add Application Insights via OpenTelemetry
using Azure.Monitor.OpenTelemetry.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// ── OpenTelemetry with Azure Monitor ─────────────────────────────────
builder.Services.AddOpenTelemetry()
    .UseAzureMonitor(options =>
    {
        // Connection string from environment variable (injected via ConfigMap or Secret)
        options.ConnectionString = builder.Configuration["ApplicationInsights:ConnectionString"];
    });

// ── Add structured logging ────────────────────────────────────────────
builder.Logging.AddOpenTelemetry(logging =>
{
    logging.IncludeFormattedMessage = true;
    logging.IncludeScopes = true;
});

var app = builder.Build();

// ── Enrich spans with pod information ────────────────────────────────
// These come from downward API env vars (set in deployment.yaml):
var podName = Environment.GetEnvironmentVariable("POD_NAME") ?? "unknown";
var podNamespace = Environment.GetEnvironmentVariable("POD_NAMESPACE") ?? "unknown";

app.MapGet("/hello/{name?}", (string? name, ILogger<Program> logger) =>
{
    // Structured log with correlation — traced across services:
    logger.LogInformation("Hello request received from {PodName} in {Namespace}",
        podName, podNamespace);
    return Results.Ok(new { message = $"Hello, {name ?? "World"}!", from = podName });
});

app.Run();
```

### Fluent Bit ConfigMap for Log Forwarding

```yaml
# ─────────────────────────────────────────────────────────────────
# configmap-fluentbit.yaml
# Fluent Bit configuration: collect K8s pod logs → send to Log Analytics
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: kube-system
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush         5
        Log_Level     info
        Daemon        off
        Parsers_File  parsers.conf

    [INPUT]
        Name              tail
        Path              /var/log/containers/*.log
        multiline.parser  docker, cri
        Tag               kube.*
        Refresh_Interval  10
        DB                /run/fluent-bit/flb_kube.db
        Skip_Long_Lines   On
        # Skip system containers logs to reduce noise:
        Exclude_Path      *_kube-system_*.log

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL            https://kubernetes.default.svc:443
        Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
        Merge_Log           On        # Parse JSON logs and merge fields
        Keep_Log            Off
        K8S-Logging.Parser  On
        K8S-Logging.Exclude On

    [OUTPUT]
        Name            azure
        Match           kube.*
        Customer_ID     ${LOG_ANALYTICS_WORKSPACE_ID}
        Shared_Key      ${LOG_ANALYTICS_SHARED_KEY}
        Log_Type        KubeContainerLog
        time_key        TimeGenerated


---

# PART 11 — CI/CD

---

## Section 36 — CI/CD with Azure DevOps

> **Mental Model: CI/CD pipeline = Assembly line for your code.**
>
> Code change → automated quality gate → build container image → push to ACR → deploy to AKS. Every change goes through the same consistent, repeatable process. No manual kubectl commands in production.

### Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                    AZURE DEVOPS PIPELINE                             │
│                                                                      │
│  Commit to main ──► CI Stage ──────────────► CD Stage               │
│                     │                        │                       │
│                     ├─ dotnet build           ├─ kubectl apply        │
│                     ├─ dotnet test            │   (or helm upgrade)  │
│                     ├─ docker build           ├─ Wait for rollout     │
│                     ├─ docker push to ACR     ├─ Smoke test           │
│                     └─ vulnerability scan     └─ Notify Slack         │
└──────────────────────────────────────────────────────────────────────┘
```

### `azure-pipelines.yml` — Full Pipeline

```yaml
# ─────────────────────────────────────────────────────────────────
# azure-pipelines.yml
# CI/CD pipeline for SimpleApi1 → ACR → AKS
# ─────────────────────────────────────────────────────────────────
trigger:
  branches:
    include:
      - main                             # Run on every push to main
  paths:
    include:
      - SimpleApi1/**                    # Only when SimpleApi1 changes

variables:
  # ── Image settings ─────────────────────────────────────────────
  containerRegistry: myacr.azurecr.io
  imageRepository: simpleapi1
  imageTag: $(Build.BuildId)             # Unique tag: use build number, not 'latest'
  fullImageName: $(containerRegistry)/$(imageRepository):$(imageTag)

  # ── Kubernetes settings ────────────────────────────────────────
  namespace: production
  deploymentName: simpleapi1

  # ── Azure settings ─────────────────────────────────────────────
  azureSubscription: 'MyAzureServiceConnection'  # Service connection name
  acrServiceConnection: 'MyACRServiceConnection'
  aksResourceGroup: myRG
  aksClusterName: myAKS

stages:
  # ── STAGE 1: Build & Test ──────────────────────────────────────
  - stage: Build
    displayName: 'Build, Test & Push'
    jobs:
      - job: BuildAndPush
        displayName: 'Build Docker image and push to ACR'
        pool:
          vmImage: 'ubuntu-latest'

        steps:
          # 1. Restore and test .NET app:
          - task: DotNetCoreCLI@2
            displayName: 'dotnet restore'
            inputs:
              command: restore
              projects: 'SimpleApi1/SimpleApi.csproj'

          - task: DotNetCoreCLI@2
            displayName: 'dotnet test'
            inputs:
              command: test
              projects: 'SimpleApi1/**/*.Tests.csproj'
              arguments: '--collect:"XPlat Code Coverage"'

          # 2. Build Docker image:
          - task: Docker@2
            displayName: 'Build Docker image'
            inputs:
              command: build
              repository: $(imageRepository)
              dockerfile: SimpleApi1/Dockerfile
              containerRegistry: $(acrServiceConnection)
              tags: |
                $(imageTag)
                latest                   # Also tag as latest (for dev reference)
              arguments: '--build-arg VERSION=$(imageTag)'

          # 3. Scan for vulnerabilities (optional but recommended):
          # - task: trivy@1
          #   inputs:
          #     image: $(fullImageName)

          # 4. Push to ACR:
          - task: Docker@2
            displayName: 'Push to ACR'
            inputs:
              command: push
              repository: $(imageRepository)
              containerRegistry: $(acrServiceConnection)
              tags: |
                $(imageTag)
                latest

          # 5. Save image tag as pipeline artifact for CD stage:
          - bash: echo "$(imageTag)" > $(Build.ArtifactStagingDirectory)/image-tag.txt
            displayName: 'Save image tag'

          - publish: $(Build.ArtifactStagingDirectory)
            artifact: image-info

  # ── STAGE 2: Deploy to Staging ────────────────────────────────
  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Build
    condition: succeeded()
    variables:
      namespace: staging

    jobs:
      - deployment: DeployToStaging
        displayName: 'Deploy to staging namespace'
        environment: 'staging'           # Azure DevOps Environment (for approvals/history)
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: KubernetesManifest@1
                  displayName: 'Deploy to staging'
                  inputs:
                    action: deploy
                    connectionType: azureResourceManager
                    azureSubscriptionConnection: $(azureSubscription)
                    azureResourceGroup: $(aksResourceGroup)
                    kubernetesCluster: $(aksClusterName)
                    namespace: staging
                    manifests: |
                      manifests/deployment.yaml
                      manifests/service.yaml
                    containers: |
                      $(fullImageName)    # Replaces image tag in manifest

  # ── STAGE 3: Deploy to Production (with approval gate) ────────
  - stage: DeployProduction
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: succeeded()

    jobs:
      - deployment: DeployToProduction
        displayName: 'Deploy to production namespace'
        environment: 'production'        # Requires manual approval in Azure DevOps
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: KubernetesManifest@1
                  displayName: 'Deploy to production'
                  inputs:
                    action: deploy
                    connectionType: azureResourceManager
                    azureSubscriptionConnection: $(azureSubscription)
                    azureResourceGroup: $(aksResourceGroup)
                    kubernetesCluster: $(aksClusterName)
                    namespace: production
                    manifests: |
                      manifests/deployment.yaml
                      manifests/service.yaml
                      manifests/hpa.yaml
                    containers: |
                      $(fullImageName)

                # Verify rollout completed:
                - task: Kubernetes@1
                  displayName: 'Verify rollout'
                  inputs:
                    connectionType: Azure Resource Manager
                    azureSubscriptionEndpoint: $(azureSubscription)
                    azureResourceGroup: $(aksResourceGroup)
                    kubernetesCluster: $(aksClusterName)
                    namespace: production
                    command: rollout
                    arguments: 'status deployment/$(deploymentName) --timeout=5m'
```

---

## Section 37 — CI/CD with GitHub Actions

### Full Workflow — Build, Push, Deploy

```yaml
# ─────────────────────────────────────────────────────────────────
# .github/workflows/deploy-simpleapi1.yml
# GitHub Actions: Build → Push to ACR → Deploy to AKS
# Uses OIDC authentication — NO stored Azure credentials!
# ─────────────────────────────────────────────────────────────────
name: Deploy SimpleApi1 to AKS

on:
  push:
    branches: [main]
    paths: ['SimpleApi1/**']
  workflow_dispatch:                     # Allow manual trigger

permissions:
  id-token: write                        # Required for OIDC auth to Azure
  contents: read

env:
  ACR_NAME: myacr
  IMAGE_NAME: simpleapi1
  AKS_RESOURCE_GROUP: myRG
  AKS_CLUSTER_NAME: myAKS
  NAMESPACE: production

jobs:
  build-and-push:
    name: Build & Push to ACR
    runs-on: ubuntu-latest

    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}

    steps:
      # 1. Checkout code:
      - name: Checkout
        uses: actions/checkout@v4

      # 2. Authenticate to Azure using OIDC (no secrets stored in GitHub!):
      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}        # App registration
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          # OIDC: GitHub token is exchanged for Azure token — no password stored

      # 3. Login to ACR:
      - name: Login to ACR
        run: az acr login --name ${{ env.ACR_NAME }}

      # 4. Generate image tags:
      - name: Docker metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-          # sha-abc1234
            type=ref,event=branch         # main
            type=semver,pattern={{version}} # v1.2.3 (if tag push)

      # 5. Set up Docker Buildx (for multi-platform builds):
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # 6. Build and push:
      - name: Build and push image
        id: build
        uses: docker/build-push-action@v5
        with:
          context: ./SimpleApi1
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=registry,ref=${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:cache
          cache-to: type=registry,ref=${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:cache,mode=max

      # 7. Run container security scan:
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:sha-${{ github.sha }}
          format: table
          exit-code: 1                   # Fail pipeline on CRITICAL vulnerabilities
          severity: CRITICAL,HIGH

  deploy:
    name: Deploy to AKS
    runs-on: ubuntu-latest
    needs: build-and-push
    environment: production              # Requires approval in GitHub Environments

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      # Get kubeconfig for the cluster:
      - name: Set AKS context
        uses: azure/aks-set-context@v4
        with:
          resource-group: ${{ env.AKS_RESOURCE_GROUP }}
          cluster-name: ${{ env.AKS_CLUSTER_NAME }}
          admin: false                   # Use Azure AD auth (not admin kubeconfig)

      # Replace image tag in deployment manifest and apply:
      - name: Deploy to AKS
        env:
          IMAGE_TAG: sha-${{ github.sha }}
        run: |
          # Use kustomize or envsubst to inject the image tag:
          sed -i "s|IMAGE_TAG_PLACEHOLDER|${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:${IMAGE_TAG}|g" \
            k8s/deployment.yaml
          kubectl apply -f k8s/ -n ${{ env.NAMESPACE }}

      # Wait for rollout to complete (fail pipeline if rollout fails):
      - name: Verify rollout
        run: |
          kubectl rollout status deployment/simpleapi1 \
            -n ${{ env.NAMESPACE }} \
            --timeout=300s

      # Optional smoke test:
      - name: Smoke test
        run: |
          EXTERNAL_IP=$(kubectl get svc simpleapi1-lb -n ${{ env.NAMESPACE }} \
            -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
          curl -f "http://${EXTERNAL_IP}/health" || exit 1
          echo "Smoke test passed!"
```

---

## Section 38 — Helm Package Manager

> **Mental Model: Helm = apt/npm for Kubernetes applications.**
>
> Instead of managing 10 separate YAML files (Deployment, Service, Ingress, HPA, ConfigMap, Secret, PDB, ServiceAccount...) and having to manually update image tags in each, Helm packages them all into a "chart" with a single `values.yaml` for configuration. Deploy with one command, upgrade with one command, rollback with one command.

### Helm Chart Structure

```
simpleapi1-chart/
├── Chart.yaml              # Chart metadata (name, version, app version)
├── values.yaml             # Default configuration values
├── values-staging.yaml     # Staging overrides
├── values-production.yaml  # Production overrides
├── templates/
│   ├── deployment.yaml     # Deployment template
│   ├── service.yaml        # Service template
│   ├── ingress.yaml        # Ingress template
│   ├── hpa.yaml            # HPA template
│   ├── serviceaccount.yaml # ServiceAccount template
│   ├── configmap.yaml      # ConfigMap template
│   ├── pdb.yaml            # PodDisruptionBudget template
│   ├── _helpers.tpl        # Named template helpers (reusable snippets)
│   └── NOTES.txt           # Post-install instructions
└── .helmignore             # Files to ignore when packaging
```

### `Chart.yaml`

```yaml
apiVersion: v2
name: simpleapi1
description: SimpleApi1 .NET 10 Minimal API Helm chart
type: application
version: 0.1.0            # Chart version (increment when chart changes)
appVersion: "1.0.0"       # Application version (from your app's version)
keywords:
  - dotnet
  - api
maintainers:
  - name: Platform Team
    email: platform@mycompany.com
```

### `values.yaml` — Defaults

```yaml
# ─────────────────────────────────────────────────────────────────
# values.yaml — Default values for all environments
# Override with: helm install ... -f values-production.yaml
# Or per-value: helm install ... --set image.tag=2.0.0
# ─────────────────────────────────────────────────────────────────

# ── Image settings ──────────────────────────────────────────────
image:
  repository: myacr.azurecr.io/simpleapi1
  tag: "latest"                          # Override with specific tag in CI/CD
  pullPolicy: IfNotPresent

# ── Replica and scaling settings ────────────────────────────────
replicaCount: 2

autoscaling:
  enabled: false                         # Enable HPA (overridden in production)
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 60

# ── Service settings ─────────────────────────────────────────────
service:
  type: ClusterIP
  port: 80

# ── Ingress settings ─────────────────────────────────────────────
ingress:
  enabled: false                         # Disabled by default; enable in environments
  className: nginx
  host: api.mycompany.com
  path: /api/v1
  tls:
    enabled: false
    secretName: tls-api-cert

# ── Resource limits ──────────────────────────────────────────────
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

# ── Probes ───────────────────────────────────────────────────────
livenessProbe:
  path: /health
  initialDelaySeconds: 15
  periodSeconds: 20

readinessProbe:
  path: /health
  initialDelaySeconds: 5
  periodSeconds: 10

# ── Environment variables ─────────────────────────────────────────
env:
  ASPNETCORE_ENVIRONMENT: Production
  ASPNETCORE_HTTP_PORTS: "80"

# ── Azure Key Vault settings ──────────────────────────────────────
keyVault:
  enabled: false
  name: ""
  tenantId: ""
  identityClientId: ""

# ── Service account ───────────────────────────────────────────────
serviceAccount:
  create: true
  name: simpleapi1-sa
  workloadIdentity:
    enabled: false
    clientId: ""

# ── Node scheduling ───────────────────────────────────────────────
nodeSelector:
  nodepool-type: app

tolerations: []

podAnnotations: {}

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### `values-production.yaml` — Production Overrides

```yaml
# Only override what differs from defaults:
replicaCount: 3

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 30
  targetCPUUtilizationPercentage: 60

service:
  type: LoadBalancer                     # External LB in production

ingress:
  enabled: true
  host: api.mycompany.com
  tls:
    enabled: true
    secretName: tls-api-cert

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 512Mi

keyVault:
  enabled: true
  name: myKeyVault
  tenantId: "TENANT_ID"

serviceAccount:
  workloadIdentity:
    enabled: true
    clientId: "MI_CLIENT_ID"

podDisruptionBudget:
  minAvailable: 2
```

### `templates/deployment.yaml` — Helm Template

```yaml
# templates/deployment.yaml
# Uses Helm templating (Go templates) to generate Kubernetes YAML
{{- define "simpleapi1.labels" -}}
app: {{ .Chart.Name }}
version: {{ .Chart.AppVersion | quote }}
helm-release: {{ .Release.Name }}
{{- end }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "simpleapi1.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}   # Only set if HPA is disabled (HPA controls replicas)
  {{- end }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        {{- include "simpleapi1.labels" . | nindent 8 }}
        {{- if .Values.serviceAccount.workloadIdentity.enabled }}
        azure.workload.identity/use: "true"
        {{- end }}
    spec:
      serviceAccountName: {{ .Values.serviceAccount.name }}
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          env:
            {{- range $key, $value := .Values.env }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
          livenessProbe:
            httpGet:
              path: {{ .Values.livenessProbe.path }}
              port: http
            initialDelaySeconds: {{ .Values.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.livenessProbe.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.readinessProbe.path }}
              port: http
            initialDelaySeconds: {{ .Values.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.readinessProbe.periodSeconds }}
```

### Helm Commands

```bash
# ─────────────────────────────────────────────────────────────────
# Install chart into production:
# ─────────────────────────────────────────────────────────────────
helm install simpleapi1 ./simpleapi1-chart \
  --namespace production \
  --create-namespace \
  -f ./simpleapi1-chart/values-production.yaml \
  --set image.tag=sha-abc1234            # Override specific values

# ─────────────────────────────────────────────────────────────────
# Upgrade existing release:
# ─────────────────────────────────────────────────────────────────
helm upgrade simpleapi1 ./simpleapi1-chart \
  --namespace production \
  -f ./simpleapi1-chart/values-production.yaml \
  --set image.tag=sha-def5678 \
  --atomic \                             # Roll back automatically if upgrade fails
  --timeout 300s

# ─────────────────────────────────────────────────────────────────
# View release history:
# ─────────────────────────────────────────────────────────────────
helm history simpleapi1 -n production

# ─────────────────────────────────────────────────────────────────
# Rollback to previous release:
# ─────────────────────────────────────────────────────────────────
helm rollback simpleapi1 1 -n production   # Roll back to revision 1

# ─────────────────────────────────────────────────────────────────
# Dry run (preview what will be applied):
# ─────────────────────────────────────────────────────────────────
helm upgrade simpleapi1 ./simpleapi1-chart \
  --namespace production \
  --dry-run \
  --debug \
  -f values-production.yaml \
  --set image.tag=sha-new

# ─────────────────────────────────────────────────────────────────
# Template (render without installing):
# ─────────────────────────────────────────────────────────────────
helm template simpleapi1 ./simpleapi1-chart \
  -f values-production.yaml \
  --set image.tag=sha-new \
  > rendered-manifests.yaml             # Save to file for review

# ─────────────────────────────────────────────────────────────────
# Uninstall:
# ─────────────────────────────────────────────────────────────────
helm uninstall simpleapi1 -n production
```

---

## Section 39 — GitOps with ArgoCD & Flux

> **Mental Model: GitOps = Git is the source of truth, not your kubectl commands.**
>
> In traditional CD, a pipeline runs `kubectl apply` when code changes. In GitOps, the cluster PULLS its desired state from Git continuously. If someone manually runs `kubectl` and changes something, ArgoCD/Flux detects drift and reverts it to match Git. "If it's not in Git, it doesn't exist."

```
TRADITIONAL CD:                       GITOPS:
  Code change                           Code change
       │                                     │
       ▼                                     ▼
  Pipeline runs                         Pipeline updates
  kubectl apply                         image tag in Git repo
       │                                     │
       ▼                                     ▼
  Cluster updated                       ArgoCD/Flux detects
  (push model)                          Git changed
                                             │
                                             ▼
                                        Cluster pulled to
                                        match Git (pull model)
                                        Drift auto-corrected
```
Here’s a compact but fairly detailed walkthrough of Helm templates and helpers, with practical examples.

---

**1. Core Helm templating concepts**

- Templates use Go template syntax: `{{ ... }}`.
- `values.yaml` provides input values, accessed via `.Values`.
- The root object in a template is usually `.`, containing:
  - `.Release` (name, namespace, etc.)
  - `.Chart` (chart info)
  - `.Values` (user values)
  - `.Capabilities` (K8s version, APIs available)

Example snippet in `templates/deployment.yaml`:

```yaml
metadata:
  name: {{ .Release.Name }}-app
spec:
  replicas: {{ .Values.replicaCount }}
```

`values.yaml`:

```yaml
replicaCount: 3
```

---

**2. Defining helper templates (`_helpers.tpl`)**

Helpers are reusable template snippets. They live in `templates/_helpers.tpl`.

Syntax:

```gotemplate
{{- define "mychart.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

- `define "name"`: declares a helper.
- `. ` inside the helper receives the same context you pass when calling it.
- Use short, namespaced names: `chartname.something`.

---

**3. Using helpers with `include` and `template`**

Most common way: `include`.

```yaml
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
```

Key points:

- `include "helperName" .` returns a string; you often pipe (`|`) into format functions like `nindent`.
- `template` works similarly but writes directly to output (less used in modern charts; `include` is preferred).

---

**4. Common helper patterns (with examples)**

Create `templates/_helpers.tpl`:

```gotemplate
{{/*
Return base chart name
*/}}
{{- define "mychart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return fully qualified name (release + chart)
*/}}
{{- define "mychart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "mychart.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Standard labels
*/}}
{{- define "mychart.labels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels (usually stable)
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mychart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
ServiceAccount name
*/}}
{{- define "mychart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "mychart.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
```

Values:

```yaml
nameOverride: ""
fullnameOverride: ""
serviceAccount:
  create: true
  name: ""
```

Usage in `templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount | default 1 }}
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "mychart.selectorLabels" . | nindent 8 }}
    spec:
      serviceAccountName: {{ include "mychart.serviceAccountName" . }}
      containers:
        - name: main
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          ports:
            - containerPort: 80
```

---

**5. Important built‑in functions (with mini examples)**

All used inside `{{ ... }}` or in helpers:

- `default` – fallback if empty:
  ```gotemplate
  {{ .Values.replicas | default 1 }}
  ```

- `required` – fail if missing (validation):
  ```gotemplate
  apiKey: {{ required "apiKey is required" .Values.apiKey }}
  ```

- `quote`, `squote` – quote strings:
  ```gotemplate
  env: {{ .Values.env | quote }}
  ```

- `toYaml` – render a map/list as YAML, often with `nindent`:
  ```yaml
  env:
    {{- toYaml .Values.env | nindent 4 }}
  ```
  `values.yaml`:
  ```yaml
  env:
    - name: ASPNETCORE_ENVIRONMENT
      value: "Production"
  ```

- `nindent` / `indent` – whitespace formatting:
  ```gotemplate
  {{- include "mychart.labels" . | nindent 4 }}
  ```

- `upper`, `lower`, `replace`, `trimSuffix`, `trunc` – string manipulation:
  ```gotemplate
  {{ .Values.region | upper }}
  ```

- `ternary` – inline if/else:
  ```gotemplate
  {{ ternary "Always" "IfNotPresent" .Values.alwaysPull }}
  ```

---

**6. Conditionals and loops**

Conditionals:

```yaml
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mychart.fullname" . }}
{{- end }}
```

Loops:

```yaml
env:
{{- range $name, $value := .Values.extraEnv }}
  - name: {{ $name }}
    value: {{ $value | quote }}
{{- end }}
```

`values.yaml`:

```yaml
extraEnv:
  LOG_LEVEL: debug
  FEATURE_X_ENABLED: "true"
```

---

**7. Rendering and debugging templates**

From your chart directory:

- See rendered output:  
  `helm template myrelease .`

- Validate + render against a cluster (no install):  
  `helm install myrelease . --dry-run --debug`

This shows you exactly how helpers, functions, and values combine into final Kubernetes manifests.

---

If you’d like, I can next:  
- Build a small, complete “sample chart” in a folder (with `_helpers.tpl`, deployment, service, values) tailored for an AKS app, or  
- Walk through one specific helper type (labels, env, or service accounts) in even more depth.

### Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD initial admin password:
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Port-forward to access UI:
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: https://localhost:8080
```

### ArgoCD Application for SimpleApi1

```yaml
# ─────────────────────────────────────────────────────────────────
# argocd-app-simpleapi1.yaml
# Tells ArgoCD to sync this cluster namespace from this Git path
# ─────────────────────────────────────────────────────────────────
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: simpleapi1-production
  namespace: argocd                     # Always in argocd namespace
  finalizers:
    - resources-finalizer.argocd.argoproj.io  # Delete resources when app is deleted
spec:
  project: default                      # ArgoCD project (for multi-team isolation)

  # ── Source: where is the desired state? ────────────────────────
  source:
    repoURL: https://github.com/mycompany/k8s-manifests.git
    targetRevision: main                # Track main branch
    path: apps/simpleapi1/production    # Folder containing K8s YAML or Helm chart

    # If using Helm chart:
    # helm:
    #   valueFiles:
    #     - values-production.yaml
    #   parameters:
    #     - name: image.tag
    #       value: sha-abc1234

  # ── Destination: where to deploy? ──────────────────────────────
  destination:
    server: https://kubernetes.default.svc  # In-cluster (ArgoCD running in same cluster)
    namespace: production

  # ── Sync policy ────────────────────────────────────────────────
  syncPolicy:
    automated:
      prune: true                       # Delete resources removed from Git
      selfHeal: true                    # Auto-revert manual kubectl changes
      allowEmpty: false                 # Don't sync if Git path is empty
    syncOptions:
      - CreateNamespace=true            # Auto-create namespace if missing
      - PrunePropagationPolicy=foreground
      - ApplyOutOfSyncOnly=true         # Only apply resources that differ

    retry:
      limit: 5                          # Retry sync up to 5 times on failure
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
```

### Flux v2 — Alternative GitOps Tool

```yaml
# ─────────────────────────────────────────────────────────────────
# flux-gitrepository.yaml
# Flux tracks a Git repository for changes
# ─────────────────────────────────────────────────────────────────
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: k8s-manifests
  namespace: flux-system
spec:
  interval: 1m                          # Poll Git every 1 minute
  url: https://github.com/mycompany/k8s-manifests
  ref:
    branch: main
  secretRef:
    name: github-credentials            # Secret with GitHub token
---
# ─────────────────────────────────────────────────────────────────
# flux-kustomization.yaml
# Applies manifests from the GitRepository
# ─────────────────────────────────────────────────────────────────
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: simpleapi1-production
  namespace: flux-system
spec:
  interval: 5m                          # Reconcile every 5 minutes
  path: ./apps/simpleapi1/production    # Path in GitRepository
  prune: true                           # Delete resources removed from Git
  sourceRef:
    kind: GitRepository
    name: k8s-manifests
  targetNamespace: production
  healthChecks:                         # Wait for deployments to be healthy:
    - apiVersion: apps/v1
      kind: Deployment
      name: simpleapi1
      namespace: production
```

---

# PART 12 — ADVANCED TOPICS

---

## Section 40 — Service Mesh

> **Mental Model: Service mesh = Automatic network auditor and traffic cop for all pod-to-pod communication.**
>
> Without a mesh, your pods talk directly and there's no visibility, encryption, or control between services. A service mesh injects a sidecar proxy (Envoy) next to every pod. All traffic flows through these proxies, giving you: mTLS encryption between services, distributed tracing, traffic splitting, circuit breaking — without changing your app code.

```
WITHOUT SERVICE MESH:                  WITH SERVICE MESH (Istio/Linkerd):
  Pod-A ──HTTP──► Pod-B                  Pod-A → [Envoy] ──mTLS──► [Envoy] → Pod-B
  (plaintext, no tracing)                         │                    │
                                           traces/metrics        traces/metrics
                                                  │                    │
                                              Jaeger/Zipkin      Prometheus
```

### Istio on AKS — Setup

```bash
# ─────────────────────────────────────────────────────────────────
# Install Istio using istioctl:
# ─────────────────────────────────────────────────────────────────
curl -L https://istio.io/downloadIstio | sh -
cd istio-*/bin && export PATH=$PWD:$PATH

istioctl install --set profile=default -y
# Profiles: minimal, default, demo, empty

# Enable automatic sidecar injection in production namespace:
kubectl label namespace production istio-injection=enabled

# ─────────────────────────────────────────────────────────────────
# Verify Istio is working:
# ─────────────────────────────────────────────────────────────────
istioctl analyze -n production          # Check for misconfigurations
kubectl get pods -n istio-system        # All Istio control plane pods
```

### Traffic Splitting — Canary Deployment

```yaml
# ─────────────────────────────────────────────────────────────────
# Deploy both v1 and v2 of SimpleApi1, split traffic 90/10:
# ─────────────────────────────────────────────────────────────────

# VirtualService: defines traffic routing rules
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: simpleapi1-vs
  namespace: production
spec:
  hosts:
    - simpleapi1-svc                    # The K8s Service name
  http:
    - match:
        - headers:
            x-canary:
              exact: "true"             # 100% of requests with this header go to v2
      route:
        - destination:
            host: simpleapi1-svc
            subset: v2
    - route:                            # Default traffic split:
        - destination:
            host: simpleapi1-svc
            subset: v1
          weight: 90                    # 90% to v1
        - destination:
            host: simpleapi1-svc
            subset: v2
          weight: 10                    # 10% to v2 (canary)
---
# DestinationRule: defines the subsets (v1, v2) by pod labels
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: simpleapi1-dr
  namespace: production
spec:
  host: simpleapi1-svc
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        http2MaxRequests: 100
    outlierDetection:                   # Circuit breaker:
      consecutive5xxErrors: 5           # Eject pod after 5 consecutive 5xx errors
      interval: 30s
      baseEjectionTime: 30s
  subsets:
    - name: v1
      labels:
        version: v1                     # Matches pods with label version=v1
    - name: v2
      labels:
        version: v2
```

### Service Mesh Comparison

| Feature | Istio | Linkerd | Open Service Mesh (OSM) |
|---------|-------|---------|------------------------|
| **Proxy** | Envoy (C++) | Linkerd2-proxy (Rust) | Envoy |
| **Resource overhead** | Higher (100-200MB/pod) | Lower (10-20MB/pod) | Medium |
| **mTLS** | ✓ Automatic | ✓ Automatic | ✓ Automatic |
| **Traffic splitting** | ✓ Advanced | ✓ Basic | ✓ Basic |
| **Circuit breaking** | ✓ | Limited | Limited |
| **Observability** | ✓ Kiali UI | ✓ Dashboard | Basic |
| **AKS add-on** | No | No | Yes (deprecated) |
| **Best for** | Complex microservices | Simple mesh with less overhead | AKS-native (now deprecated) |
| **Complexity** | High | Low | Medium |

---

## Section 41 — Multi-Tenancy & Namespaces

### Namespace Isolation Strategy

```
SINGLE-TENANT APPROACH:          MULTI-TENANT APPROACH:
  One cluster, one team            One cluster, many teams
  Simple but wasteful              Cost-efficient but complex

  cluster                          cluster
    └─ production ns                 ├─ team-alpha-prod ns
         └─ all apps                 ├─ team-alpha-staging ns
                                     ├─ team-beta-prod ns
                                     └─ team-beta-staging ns
```

### ResourceQuotas Per Namespace

```yaml
# ─────────────────────────────────────────────────────────────────
# resourcequota-team-alpha.yaml
# Limits team-alpha's total resource consumption
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-alpha-quota
  namespace: team-alpha-prod
spec:
  hard:
    # Pod/workload limits:
    pods: "50"                           # Max 50 pods in this namespace
    services: "10"
    secrets: "20"
    configmaps: "20"
    persistentvolumeclaims: "10"

    # Resource limits:
    requests.cpu: "10"                   # Total CPU requests can't exceed 10 vCPU
    requests.memory: "20Gi"             # Total memory requests can't exceed 20 GiB
    limits.cpu: "20"                     # Total CPU limits
    limits.memory: "40Gi"               # Total memory limits

    # Storage:
    requests.storage: "100Gi"           # Total storage claims can't exceed 100 GiB
```

### LimitRanges — Default Pod Limits

```yaml
# ─────────────────────────────────────────────────────────────────
# limitrange-team-alpha.yaml
# Ensures every container has sensible resource constraints
# Prevents pods with no limits from consuming all node resources
# ─────────────────────────────────────────────────────────────────
apiVersion: v1
kind: LimitRange
metadata:
  name: team-alpha-limits
  namespace: team-alpha-prod
spec:
  limits:
    - type: Container
      default:                          # Applied if container doesn't specify limits:
        cpu: "500m"
        memory: "256Mi"
      defaultRequest:                   # Applied if container doesn't specify requests:
        cpu: "100m"
        memory: "128Mi"
      max:                              # Container can NEVER exceed these:
        cpu: "2000m"
        memory: "2Gi"
      min:                              # Container must request at LEAST these:
        cpu: "50m"
        memory: "64Mi"
    - type: Pod
      max:                              # Entire pod can't exceed:
        cpu: "4000m"
        memory: "4Gi"
    - type: PersistentVolumeClaim
      max:
        storage: "50Gi"                 # Max PVC size in this namespace
      min:
        storage: "1Gi"
```

---

## Section 42 — Windows Containers on AKS

### Add Windows Node Pool

```bash
# ─────────────────────────────────────────────────────────────────
# REQUIREMENTS:
# - Network plugin must be "azure" (not kubenet)
# - Cluster must have been created with Windows admin credentials
# ─────────────────────────────────────────────────────────────────

# Create cluster with Windows support:
az aks create \
  --resource-group myRG \
  --name myAKS \
  --network-plugin azure \
  --windows-admin-username azureuser \
  --windows-admin-password "P@ssw0rd1234" \
  --generate-ssh-keys

# Add Windows node pool:
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --os-type Windows \
  --name winpool \
  --node-count 2 \
  --node-vm-size Standard_D4s_v3
```

### Windows Pod Deployment

```yaml
# deployment-windows.yaml
# Deploy a Windows-based ASP.NET Framework app
apiVersion: apps/v1
kind: Deployment
metadata:
  name: legacy-api-windows
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: legacy-api
  template:
    metadata:
      labels:
        app: legacy-api
    spec:
      # ── Schedule on Windows nodes ──────────────────────────────
      nodeSelector:
        kubernetes.io/os: windows        # Only Windows nodes
        beta.kubernetes.io/os: windows   # Older label (K8s <1.14)
      tolerations:
        - key: os
          operator: Equal
          value: Windows
          effect: NoSchedule

      containers:
        - name: legacy-api
          image: myacr.azurecr.io/legacy-api-windows:1.0.0
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "250m"
              memory: "512Mi"            # Windows containers need more memory
            limits:
              cpu: "1000m"
              memory: "2Gi"
```

---

## Section 43 — GPU Workloads on AKS

```bash
# ─────────────────────────────────────────────────────────────────
# Add GPU node pool (NC series VMs = NVIDIA A100/V100):
# ─────────────────────────────────────────────────────────────────
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --name gpupool \
  --node-vm-size Standard_NC6s_v3 \     # 6 vCPU, 112GB RAM, 1x V100 GPU
  --node-count 2 \
  --node-taints "sku=gpu:NoSchedule" \  # Only GPU-requesting pods land here
  --aks-custom-headers UseGPUDedicatedVHD=true  # Use GPU-optimized OS image

# The NVIDIA device plugin DaemonSet is auto-installed on GPU nodes by AKS
# Verify:
kubectl get nodes -l accelerator=nvidia
kubectl describe node <gpu-node> | grep nvidia
```

```yaml
# ─────────────────────────────────────────────────────────────────
# job-ml-training.yaml
# ML training job on GPU nodes
# ─────────────────────────────────────────────────────────────────
apiVersion: batch/v1
kind: Job
metadata:
  name: ml-training-run-001
  namespace: ml
spec:
  template:
    spec:
      restartPolicy: Never
      tolerations:
        - key: sku
          value: gpu
          effect: NoSchedule             # Must tolerate the GPU taint

      containers:
        - name: training
          image: mcr.microsoft.com/azureml/pytorch:2.1.0
          command: ["python", "train.py", "--epochs", "100"]
          resources:
            limits:
              nvidia.com/gpu: 1          # Request 1 GPU
              cpu: "4"
              memory: "16Gi"
          volumeMounts:
            - name: training-data
              mountPath: /data
      volumes:
        - name: training-data
          persistentVolumeClaim:
            claimName: training-dataset-pvc
```

---

# PART 13 — RELIABILITY & COST

---

## Section 44 — High Availability & Disaster Recovery

### Availability Zone Node Distribution

```bash
# ─────────────────────────────────────────────────────────────────
# Create node pool spread across 3 availability zones:
# ─────────────────────────────────────────────────────────────────
az aks nodepool add \
  --resource-group myRG \
  --cluster-name myAKS \
  --name apppool \
  --node-count 3 \
  --zones 1 2 3                         # Exactly 1 node per AZ (for 3 nodes)
  # For 6 nodes: 2 per AZ
  # For 9 nodes: 3 per AZ

# View which AZ each node is in:
kubectl get nodes -o custom-columns='NODE:.metadata.name,ZONE:.metadata.labels.topology\.kubernetes\.io/zone'
```

### Topology Spread Constraints (Better Than Anti-Affinity)

```yaml
# Spread pods across AZs and nodes automatically:
spec:
  template:
    spec:
      topologySpreadConstraints:
        # Spread across availability zones:
        - maxSkew: 1                     # Max difference between AZ pod counts
          topologyKey: topology.kubernetes.io/zone
          whenUnsatisfiable: DoNotSchedule  # Require even spread
          labelSelector:
            matchLabels:
              app: simpleapi1

        # Also spread across individual nodes:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: ScheduleAnyway  # Prefer but don't require
          labelSelector:
            matchLabels:
              app: simpleapi1
```

### Velero — Cluster Backup

```bash
# ─────────────────────────────────────────────────────────────────
# Install Velero for backup/restore of K8s resources + PVCs:
# ─────────────────────────────────────────────────────────────────

# Create Azure Storage Account for Velero backups:
STORAGE_ACCOUNT=velerobackups$(date +%s)
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group myRG \
  --sku Standard_LRS

az storage container create \
  --account-name $STORAGE_ACCOUNT \
  --name velero

# Install Velero:
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm install velero vmware-tanzu/velero \
  --namespace velero \
  --create-namespace \
  --set "configuration.provider=azure" \
  --set "configuration.backupStorageLocation.bucket=velero" \
  --set "configuration.backupStorageLocation.config.storageAccount=$STORAGE_ACCOUNT" \
  --set "initContainers[0].name=velero-plugin-for-azure" \
  --set "initContainers[0].image=velero/velero-plugin-for-microsoft-azure:v1.9.0"

# ─────────────────────────────────────────────────────────────────
# Create a scheduled backup:
# ─────────────────────────────────────────────────────────────────
velero schedule create daily-backup \
  --schedule="0 2 * * *" \               # 2 AM daily
  --include-namespaces production \       # Only backup production namespace
  --ttl 168h                             # Keep for 7 days

# Manual backup:
velero backup create pre-upgrade-backup \
  --include-namespaces production

# Restore from backup:
velero restore create --from-backup pre-upgrade-backup
```

---

## Section 45 — Cost Optimization

### Cost Saving Strategies

```
┌──────────────────────────────────────────────────────────────────┐
│                   AKS COST COMPONENTS                            │
├──────────────────────────┬───────────────────────────────────────┤
│  Control Plane           │  Free (Standard tier: ~$75/month)     │
│  Node VMs                │  Biggest cost (60-80% of total)       │
│  Azure Disk (PVCs)       │  ~$0.10/GB/month                      │
│  Azure Load Balancer     │  ~$18/month per LB + data             │
│  Azure Container Registry│  Basic: $0.167/day + storage          │
│  Azure Monitor           │  ~$2.76/GB ingested                   │
│  Egress                  │  $0.087/GB after first 5GB/month      │
└──────────────────────────┴───────────────────────────────────────┘
```

### Spot Node Pool for Non-Critical Workloads

```yaml
# ─────────────────────────────────────────────────────────────────
# Deployment that runs on spot nodes (batch processing, dev workloads)
# Spot VMs are up to 90% cheaper but can be evicted with 30s notice
# ─────────────────────────────────────────────────────────────────
spec:
  template:
    spec:
      # Required tolerations for spot nodes:
      tolerations:
        - key: "kubernetes.azure.com/scalesetpriority"
          operator: "Equal"
          value: "spot"
          effect: "NoSchedule"

      # Prefer spot nodes but fall back to regular if spot is unavailable:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              preference:
                matchExpressions:
                  - key: "kubernetes.azure.com/scalesetpriority"
                    operator: In
                    values: ["spot"]

      # Handle spot eviction gracefully:
      terminationGracePeriodSeconds: 30  # Limited time before eviction
      containers:
        - name: batch-processor
          lifecycle:
            preStop:
              exec:
                command: ["sh", "-c", "save-state && exit 0"]  # Save state on eviction
```

### Stop/Start Cluster (Off-Hours Savings)

```bash
# ─────────────────────────────────────────────────────────────────
# Stop the cluster on weekends (dev/staging only!):
# Nodes are deallocated but cluster config is preserved
# Control plane still billed on Standard tier when stopped
# ─────────────────────────────────────────────────────────────────

# Stop cluster (saves node VM costs):
az aks stop --resource-group myRG --name myAKSdev --no-wait

# Start cluster:
az aks start --resource-group myRG --name myAKSdev

# Automate with Azure Automation or GitHub Actions cron job:
# .github/workflows/cluster-schedule.yml:
# on:
#   schedule:
#     - cron: '0 20 * * 1-5'   # 8 PM weekdays: stop
#     - cron: '0 7 * * 1-5'    # 7 AM weekdays: start
```

### Cost Optimization Checklist

```
☐ COMPUTE:
  ☐ Use spot nodes for batch workloads, dev/staging (up to 90% savings)
  ☐ Enable Cluster Autoscaler on all node pools
  ☐ Use VPA in Off mode to right-size requests (avoid over-provisioning)
  ☐ System node pool: Standard_D4s_v3 minimum, not larger than needed
  ☐ Use Burstable VMs (B-series) for variable workloads
  ☐ Consider Reserved Instances for system/base node pools (1-year: 40% savings, 3-year: 60%)

☐ STORAGE:
  ☐ Use Standard SSD (managed-csi) instead of Premium SSD unless IOPS needed
  ☐ Set PVC reclaim policy to Delete (not Retain) for dev workloads
  ☐ Delete unused PVCs (orphaned disks still incur charges)
  ☐ Use Azure Files only when ReadWriteMany is required (more expensive than Disk)

☐ NETWORKING:
  ☐ Minimize public Load Balancers — use Ingress controller (1 LB for many services)
  ☐ Use internal LB where external access is not needed
  ☐ Minimize cross-AZ traffic (use pod affinity to co-locate related pods)

☐ OBSERVABILITY:
  ☐ Set Log Analytics retention to minimum needed (30 days vs 90 days)
  ☐ Filter noisy logs at Fluent Bit level before ingestion
  ☐ Use Azure Managed Prometheus (cheaper than full kube-prometheus-stack)

☐ CLUSTER:
  ☐ Use Free tier for dev/staging clusters (no SLA needed)
  ☐ Stop dev/staging clusters outside business hours
  ☐ Merge multiple small apps into one cluster (multi-namespace tenancy)
```

---

## Section 46 — AKS vs Alternatives Decision Tree

```
START: "I need to run containerized workloads on Azure"
                        │
                        ▼
          Do you NEED Kubernetes specifically?
          (existing K8s manifests, custom operators,
           StatefulSets, DaemonSets, fine-grained RBAC)
                        │
           YES ─────────┘──────── NO
            │                      │
            ▼                      ▼
           AKS              Do you need CONTAINERS?
                                    │
                        YES ────────┘──── NO
                         │                │
                         ▼                ▼
              Do you want to manage     Use Azure Functions
              container infrastructure? or Logic Apps
                         │
              YES ────────┘──── NO
               │                │
               ▼                ▼
         Azure Container    Azure Container Apps
         Instances (ACI)    (Managed K8s abstraction)
         (single container, (microservices, KEDA scaling,
          no orchestration)  Dapr integration, scale-to-0)
                            OR
                            Azure App Service
                            (traditional web apps,
                             managed PaaS, slots, WebJobs)
```

### Detailed Comparison Table

| Criteria | **AKS** | **Container Apps** | **App Service** | **ACI** | **Functions** |
|----------|---------|-------------------|-----------------|---------|--------------|
| **Kubernetes expertise required** | High | Low | None | None | None |
| **Operational overhead** | High | Low | Very Low | None | None |
| **StatefulSets** | ✓ | ✗ | ✗ | ✗ | ✗ |
| **DaemonSets** | ✓ | ✗ | ✗ | ✗ | ✗ |
| **Custom operators** | ✓ | ✗ | ✗ | ✗ | ✗ |
| **Scale to zero** | Via KEDA | ✓ Native | ✓ (Consumption) | ✗ | ✓ Native |
| **Event-driven scaling** | KEDA | ✓ Native | Limited | ✗ | ✓ Native |
| **Max scale** | 5000 nodes | Unlimited | Large | Single | Unlimited |
| **GPU support** | ✓ | ✗ | ✗ | ✓ | ✗ |
| **Pricing model** | Per VM node | Per vCPU/memory-second | Per App Service Plan | Per container-second | Per execution |
| **Cost at scale** | Most efficient | Efficient | Fixed plan | Expensive | Most efficient |
| **Networking** | Full VNet control | VNet integration | VNet integration | Limited | VNet integration |

---

# PART 14 — REFERENCE

---

## Section 47 — kubectl Command Reference

### Cluster & Context

```bash
# ── View/switch clusters ───────────────────────────────────────────
kubectl config get-contexts                      # List all clusters
kubectl config current-context                   # Show current cluster
kubectl config use-context myAKS                 # Switch cluster
kubectl cluster-info                             # Show API server URL
kubectl version --client                         # kubectl version

# ── Get cluster-wide resources ─────────────────────────────────────
kubectl get nodes -o wide                        # Nodes with IPs and AZ
kubectl get namespaces                           # All namespaces
kubectl top nodes                                # Node CPU/Memory usage
kubectl top pods -n production --sort-by=cpu     # Pod CPU usage, sorted
```

### Pods

```bash
# ── Pod lifecycle ──────────────────────────────────────────────────
kubectl get pods -n production                   # List all pods
kubectl get pods -n production -w                # Watch pod changes (live)
kubectl get pods -n production -o wide           # Show IPs and node names
kubectl describe pod <pod-name> -n production    # Full pod details + events
kubectl delete pod <pod-name> -n production      # Delete pod (will be recreated)
kubectl delete pods -l app=simpleapi1 -n production  # Delete all with label

# ── Logs ──────────────────────────────────────────────────────────
kubectl logs <pod-name> -n production            # Pod logs
kubectl logs <pod-name> -n production -f         # Follow logs (tail -f)
kubectl logs <pod-name> -n production --tail=100 # Last 100 lines
kubectl logs <pod-name> -n production -c simpleapi1  # Specific container (multi-container pod)
kubectl logs <pod-name> -n production --previous # Logs from PREVIOUS (crashed) container

# ── Exec into pod ──────────────────────────────────────────────────
kubectl exec -it <pod-name> -n production -- /bin/bash
kubectl exec -it <pod-name> -n production -- sh  # If bash not available
kubectl exec <pod-name> -n production -- wget -qO- http://simpleapi2-svc/health  # Test connectivity

# ── Port forward ──────────────────────────────────────────────────
kubectl port-forward pod/<pod-name> 8080:80 -n production   # pod port 80 → local 8080
kubectl port-forward svc/simpleapi1-svc 8080:80 -n production  # via service
kubectl port-forward deploy/simpleapi1 8080:80 -n production   # via deployment
```

### Deployments

```bash
# ── Deployment management ─────────────────────────────────────────
kubectl get deployments -n production            # List deployments
kubectl describe deployment simpleapi1 -n production  # Details + events
kubectl get deployment simpleapi1 -n production -o yaml  # Full YAML
kubectl scale deployment simpleapi1 --replicas=5 -n production
kubectl set image deployment/simpleapi1 simpleapi1=myacr.azurecr.io/simpleapi1:2.0.0 -n production
kubectl rollout status deployment/simpleapi1 -n production
kubectl rollout history deployment/simpleapi1 -n production
kubectl rollout undo deployment/simpleapi1 -n production
kubectl rollout restart deployment/simpleapi1 -n production
```

### Services & Networking

```bash
# ── Services ───────────────────────────────────────────────────────
kubectl get services -n production -o wide       # Show service IPs
kubectl describe service simpleapi1-svc -n production  # Endpoints + details
kubectl get endpoints simpleapi1-svc -n production     # Pod IPs in service

# ── DNS debugging (test from inside a pod) ─────────────────────────
kubectl run dns-test --image=busybox -it --rm --restart=Never -- nslookup simpleapi1-svc.production
kubectl run curl-test --image=curlimages/curl -it --rm --restart=Never -- curl http://simpleapi1-svc.production/health
```

### Apply, Diff & Delete

```bash
# ── Apply manifests ────────────────────────────────────────────────
kubectl apply -f deployment.yaml                 # Apply single file
kubectl apply -f ./manifests/                    # Apply all files in folder
kubectl apply -f ./manifests/ -R                 # Recursive
kubectl apply -f https://raw.githubusercontent.com/.../manifest.yaml  # From URL

# ── Preview changes before applying ───────────────────────────────
kubectl diff -f deployment.yaml                  # Shows diff vs cluster state

# ── Delete ────────────────────────────────────────────────────────
kubectl delete -f deployment.yaml                # Delete by manifest
kubectl delete deployment simpleapi1 -n production  # Delete by name
kubectl delete all -l app=simpleapi1 -n production  # Delete all resources with label
```

### Useful Aliases (add to ~/.bashrc or ~/.zshrc)

```bash
alias k='kubectl'
alias kn='kubectl -n'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias klogs='kubectl logs -f'
alias kdesc='kubectl describe'
alias kroll='kubectl rollout'

# Function: switch namespace context
kubens() { kubectl config set-context --current --namespace="$1"; }
# Usage: kubens production
```

---

## Section 48 — Troubleshooting Guide

### Pod Not Starting: Diagnosis Flowchart

```
kubectl get pods -n production
    │
    ├── STATUS: Pending ──────────────────────────────────────────────────────────┐
    │   kubectl describe pod <name>                                               │
    │   Look at "Events:" section at bottom                                       │
    │   ├── "0/3 nodes available: insufficient cpu" → Add nodes or reduce requests│
    │   ├── "0/3 nodes available: node(s) had taint" → Check tolerations         │
    │   ├── "0/3 nodes available: node affinity mismatch" → Check nodeSelector   │
    │   └── "persistentvolumeclaim not found" → Check PVC/StorageClass           │
    │                                                                             │
    ├── STATUS: ImagePullBackOff / ErrImagePull ─────────────────────────────────┤
    │   kubectl describe pod <name> | grep -A5 "Failed"                          │
    │   ├── "not found" → Wrong image name or tag                                │
    │   ├── "unauthorized" → ACR not attached to cluster, or imagePullSecret missing│
    │   └── "connection refused" → Network issue reaching registry               │
    │                                                                             │
    ├── STATUS: CrashLoopBackOff ─────────────────────────────────────────────────┤
    │   kubectl logs <pod> --previous → See WHY it crashed                       │
    │   ├── Exit code 1 → App error (check logs)                                 │
    │   ├── Exit code 137 → OOMKilled (increase memory limit)                    │
    │   ├── Exit code 139 → Segfault (app bug)                                   │
    │   └── Health probe failing → Check probe path/port, initialDelaySeconds    │
    │                                                                             │
    └── STATUS: OOMKilled ────────────────────────────────────────────────────────┘
        kubectl describe pod <name> | grep -i oom
        → Increase memory limit (limits.memory)
        → Add JVM -Xmx flag for Java, DOTNET_GCHeapHardLimit for .NET
```

### Common Issues & Solutions

```bash
# ─────────────────────────────────────────────────────────────────
# ISSUE: Service not reachable (connection refused)
# ─────────────────────────────────────────────────────────────────
# 1. Check service selector matches pod labels:
kubectl get svc simpleapi1-svc -n production -o yaml | grep selector
kubectl get pods -n production --show-labels | grep simpleapi1

# 2. Check endpoints (should list pod IPs):
kubectl get endpoints simpleapi1-svc -n production
# If no endpoints: selector doesn't match any pod labels

# 3. Test from inside cluster:
kubectl run test --rm -it --image=curlimages/curl --restart=Never -- \
  curl http://simpleapi1-svc.production.svc.cluster.local/health

# ─────────────────────────────────────────────────────────────────
# ISSUE: DNS resolution failure
# ─────────────────────────────────────────────────────────────────
# Check CoreDNS is running:
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test DNS from pod:
kubectl run dns-test --rm -it --image=busybox --restart=Never -- \
  nslookup kubernetes.default
# If this fails: CoreDNS is broken
# If service lookup fails but kubernetes.default works: NetworkPolicy blocking DNS

# ─────────────────────────────────────────────────────────────────
# ISSUE: Node NotReady
# ─────────────────────────────────────────────────────────────────
kubectl describe node <node-name>
# Look for: Conditions section
# ├── MemoryPressure=True → Node is low on memory
# ├── DiskPressure=True   → Node is low on disk (clean Docker images)
# ├── PIDPressure=True    → Too many processes
# └── Ready=False         → kubelet issues (check kubelet logs on node)

# SSH to node (requires SSH key from cluster creation):
az aks nodepool show --resource-group myRG --cluster-name myAKS --name apppool \
  --query [nodeImageVersion,osType] -o tsv

# ─────────────────────────────────────────────────────────────────
# ISSUE: Ingress returning 502/503
# ─────────────────────────────────────────────────────────────────
# 1. Check Ingress controller pod is running:
kubectl get pods -n ingress-nginx

# 2. Check Ingress resource:
kubectl describe ingress apps-ingress -n production
# Look for "Address" (should be the external IP) and "Rules"

# 3. Check the backend service and endpoints:
kubectl get endpoints simpleapi1-svc -n production

# 4. Check NGINX logs:
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller -f

# ─────────────────────────────────────────────────────────────────
# ISSUE: HPA not scaling (stuck at minimum)
# ─────────────────────────────────────────────────────────────────
kubectl describe hpa simpleapi1-hpa -n production
# Look for: "unable to get metrics" → metrics-server not working
kubectl get pods -n kube-system -l k8s-app=metrics-server
kubectl top pods -n production  # If this fails, metrics-server is broken

# ─────────────────────────────────────────────────────────────────
# ISSUE: PVC stuck in Pending
# ─────────────────────────────────────────────────────────────────
kubectl describe pvc simpleapi-data -n production
# "no persistent volumes available" → Wrong StorageClass or class doesn't exist
# "WaitForFirstConsumer" → Normal for disk volumes — PVC binds when pod is scheduled
# Verify StorageClass exists: kubectl get sc
```

### Pod Debugging Toolkit

```bash
# ─────────────────────────────────────────────────────────────────
# Ephemeral debug container (K8s 1.23+) — non-invasive debugging:
# ─────────────────────────────────────────────────────────────────
kubectl debug -it <pod-name> \
  -n production \
  --image=busybox \
  --target=simpleapi1      # Share process namespace with simpleapi1 container

# ─────────────────────────────────────────────────────────────────
# Copy a debugging tool into a running pod:
# ─────────────────────────────────────────────────────────────────
kubectl cp ./debugtool.sh production/<pod-name>:/tmp/debugtool.sh
kubectl exec -it <pod-name> -n production -- sh /tmp/debugtool.sh

# ─────────────────────────────────────────────────────────────────
# Get cluster events (last 10 minutes of events, sorted):
# ─────────────────────────────────────────────────────────────────
kubectl get events -n production \
  --sort-by='.lastTimestamp' \
  --field-selector type=Warning         # Only show Warning events

# ─────────────────────────────────────────────────────────────────
# Network debugging from inside cluster:
# ─────────────────────────────────────────────────────────────────
kubectl run netshoot --rm -it \
  --image=nicolaka/netshoot \
  --restart=Never \
  -n production \
  -- /bin/bash
# Inside: curl, dig, nslookup, tcpdump, ss, ip, traceroute all available
```

---

## Section 49 — Production Readiness Checklist

### Security

```
☐ IDENTITY & ACCESS:
  ☐ Azure AD integration enabled (--enable-azure-rbac)
  ☐ Local accounts disabled in production (--disable-local-accounts)
  ☐ Workload Identity used for all pod-to-Azure-service authentication
  ☐ No long-lived credentials stored in K8s Secrets
  ☐ Azure Key Vault CSI driver for secrets management
  ☐ CI/CD service principal scoped to minimum required RBAC

☐ NETWORK:
  ☐ Private cluster or authorized IP ranges for API server
  ☐ Network Policies: default-deny with explicit allow rules
  ☐ Azure CNI with Calico or Cilium network policy support
  ☐ Ingress TLS enabled (cert-manager + Let's Encrypt or own cert)
  ☐ Internal Load Balancer where external access not needed

☐ CONTAINER SECURITY:
  ☐ Images scanned (Trivy, Defender for Containers, or ACR scanning)
  ☐ Images pulled from private ACR only (OPA Gatekeeper policy)
  ☐ Pod Security Standards: Restricted profile on production namespaces
  ☐ All containers: runAsNonRoot=true, readOnlyRootFilesystem=true
  ☐ All containers: securityContext.capabilities.drop=[ALL]
  ☐ No privileged containers in production
```

### Reliability

```
☐ HIGH AVAILABILITY:
  ☐ System node pool: minimum 3 nodes across 3 availability zones
  ☐ App node pool: minimum 2 nodes (PDB + AZ spread)
  ☐ All workloads: minimum 2 replicas (never single-pod)
  ☐ Cluster tier: Standard (99.95% SLA) or Premium (99.99%)
  ☐ PodDisruptionBudgets on all critical workloads

☐ RESILIENCE:
  ☐ Resource requests and limits set on ALL containers
  ☐ Liveness, readiness, and startup probes configured
  ☐ preStop sleep hook (5 seconds) to graceful drain load balancer
  ☐ terminationGracePeriodSeconds >= 30
  ☐ Rolling update strategy (not Recreate)
  ☐ Topology spread constraints across nodes and AZs

☐ RECOVERY:
  ☐ Velero backup scheduled (daily, 7-day retention)
  ☐ PVC snapshots for stateful workloads
  ☐ Recovery runbook documented and tested
```

### Observability

```
☐ METRICS:
  ☐ Container Insights enabled (or Azure Managed Prometheus)
  ☐ Resource utilization alerts (CPU > 80%, Memory > 85%)
  ☐ Pod restart alert (> 5 restarts in 1 hour)
  ☐ Node NotReady alert
  ☐ PVC usage alert (> 80% full)

☐ LOGGING:
  ☐ Log Analytics workspace with appropriate retention (30+ days)
  ☐ Fluent Bit or OMS Agent collecting container logs
  ☐ Application logging to stdout/stderr (not files)
  ☐ Structured JSON logging for easy querying

☐ TRACING:
  ☐ Application Insights (or OpenTelemetry collector) configured
  ☐ Distributed trace context propagated between services
  ☐ Service map available in Application Insights
```

### Cost

```
☐ AUTOSCALING:
  ☐ Cluster Autoscaler enabled on all node pools
  ☐ HPA configured for stateless workloads
  ☐ KEDA for event-driven workloads (especially scale-to-zero)

☐ RIGHT-SIZING:
  ☐ VPA in Off mode running — check recommendations quarterly
  ☐ No container with unlimited resources (limits always set)
  ☐ Spot nodes used for batch/non-critical workloads

☐ SCHEDULING:
  ☐ Dev/staging clusters stop outside business hours
  ☐ 1-year Reserved Instances for system node pool (40% savings)
```

---

## Section 50 — Quick Reference Card

### Most-Used YAML Patterns

```yaml
# Minimal Deployment (start here, add as needed):
apiVersion: apps/v1
kind: Deployment
metadata: {name: myapp, namespace: production}
spec:
  replicas: 2
  selector: {matchLabels: {app: myapp}}
  template:
    metadata: {labels: {app: myapp}}
    spec:
      containers:
      - name: myapp
        image: myacr.azurecr.io/myapp:1.0.0
        ports: [{containerPort: 80}]
        resources:
          requests: {cpu: 100m, memory: 128Mi}
          limits: {cpu: 500m, memory: 256Mi}
        livenessProbe: {httpGet: {path: /health, port: 80}}
        readinessProbe: {httpGet: {path: /health, port: 80}}
---
# Minimal ClusterIP Service:
apiVersion: v1
kind: Service
metadata: {name: myapp-svc, namespace: production}
spec:
  selector: {app: myapp}
  ports: [{port: 80, targetPort: 80}]
---
# Minimal HPA:
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: myapp-hpa, namespace: production}
spec:
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: myapp}
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource: {name: cpu, target: {type: Utilization, averageUtilization: 60}}
```

### Most-Used CLI Commands

```bash
# Get everything in a namespace:
kubectl get all -n production

# Get pod logs and follow:
kubectl logs -f deployment/simpleapi1 -n production

# Debug a pod:
kubectl exec -it deployment/simpleapi1 -n production -- sh

# Apply and watch rollout:
kubectl apply -f manifests/ -n production && \
  kubectl rollout status deployment/simpleapi1 -n production

# Emergency: scale down a misbehaving deployment:
kubectl scale deployment simpleapi1 --replicas=0 -n production

# Quick AKS cluster creation for testing:
az aks create -g myRG -n test --node-count 1 --generate-ssh-keys
az aks get-credentials -g myRG -n test
```

### Mental Model Recap

| Concept | Mental Model | Key Insight |
|---------|-------------|-------------|
| **Kubernetes** | Self-healing city | Desired state reconciliation loop runs constantly |
| **Pod** | Apartment in a building | Smallest deployable unit; ephemeral |
| **Deployment** | Fleet manager | Manages rolling updates and rollbacks |
| **StatefulSet** | Named employees with desks | Stable identity + storage per pod |
| **DaemonSet** | Guard in every building | Runs on every node automatically |
| **Service** | Stable phone number | Load balances to healthy pod IPs |
| **Ingress** | Smart receptionist | Routes HTTP/S by host/path to services |
| **HPA** | Hiring manager | Scales pods based on metrics |
| **KEDA** | Queue-length scheduler | Event-driven scaling, scale-to-zero |
| **Cluster Autoscaler** | Building more offices | Adds/removes nodes based on pod demand |
| **Workload Identity** | Employee badge | No stored credentials; OIDC token exchange |
| **GitOps** | Git as city law | Cluster constantly reconciles to Git state |

---

> **Last Updated:** February 2026
> **Kubernetes Version Coverage:** 1.27 – 1.31
> **AKS CLI Version:** Azure CLI 2.60+
> **Reference Apps:** SimpleApi1, SimpleApi2 (.NET 10 Minimal API)

---

*End of Azure Kubernetes Service Complete Guide*



