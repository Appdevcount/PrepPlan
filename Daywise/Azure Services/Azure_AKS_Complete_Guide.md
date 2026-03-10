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

### PART 15 — kubectl, kubeconfig & kubelet — Fundamentals Deep Dive
- [15.1 — The Kubernetes Client-Server Architecture](#151--the-kubernetes-client-server-architecture)
- [15.2 — Installing kubectl](#152--installing-kubectl)
- [15.3 — kubeconfig Deep Dive](#153--kubeconfig-deep-dive)
- [15.4 — kubelet: The Node Agent](#154--kubelet-the-node-agent)
- [15.5 — kubectl Commands with Sample Outputs](#155--kubectl-commands-with-sample-outputs)
- [15.6 — kubectl Output Formats](#156--kubectl-output-formats)

### PART 16 — Service-to-Service Communication Deep Dive
- [16.1 — Kubernetes DNS: The Full Name Format](#161--kubernetes-dns-the-full-name-format)
- [16.2 — Two-Service YAML Setup (SimpleApi1 → SimpleApi2)](#162--kubernetes-yaml-two-service-setup-simpleapi1--simpleapi2)
- [16.3 — .NET HttpClientFactory Pattern for Service Calls](#163--net-10-code-httpclient-factory-pattern-for-service-calls)
- [16.4 — Communication Patterns Diagram](#164--communication-patterns-diagram)
- [16.5 — Cross-Namespace Communication](#165--cross-namespace-communication)
- [16.6 — Service Mesh for Advanced Communication (Istio)](#166--service-mesh-for-advanced-communication-istio)
- [16.7 — Verifying Service-to-Service Connectivity](#167--verifying-service-to-service-connectivity)

### PART 17 — Volume Types — Complete Deep Dive
- [17.1 — Volume Types Overview](#171--volume-types-overview)
- [17.2 — emptyDir](#172--emptydir)
- [17.3 — hostPath](#173--hostpath)
- [17.4 — configMap Volume Mount](#174--configmap-volume-mount)
- [17.5 — Secret Volume Mount](#175--secret-volume-mount)
- [17.6 — Projected Volumes](#176--projected-volumes-combining-multiple-sources)
- [17.7 — Azure Disk (ReadWriteOnce)](#177--azure-disk-persistentvolume--readwriteonce)
- [17.8 — Azure Files (ReadWriteMany)](#178--azure-files-readwritemany--shared-storage)
- [17.9 — StatefulSet with VolumeClaimTemplates](#179--statefulset-with-volumeclaimtemplates)
- [17.10 — Volume Snapshots](#1710--volume-snapshots)

### PART 18 — 10 Real-World AKS Challenges & Solutions
- [Challenge 1: CrashLoopBackOff](#challenge-1-crashloopbackoff)
- [Challenge 2: OOMKilled](#challenge-2-oomkilled)
- [Challenge 3: Pod Stuck in Pending](#challenge-3-pod-stuck-in-pending)
- [Challenge 4: ImagePullBackOff](#challenge-4-imagepullbackoff)
- [Challenge 5: Service Not Reachable (502/503)](#challenge-5-service-not-reachable-502503)
- [Challenge 6: Rolling Update Causes Downtime](#challenge-6-rolling-update-causes-downtime)
- [Challenge 7: DNS Resolution Failures](#challenge-7-dns-resolution-failures)
- [Challenge 8: HPA Not Scaling](#challenge-8-hpa-not-scaling)
- [Challenge 9: Azure Disk Not Mounting](#challenge-9-azure-disk-not-mounting)
- [Challenge 10: Workload Identity 401 Errors](#challenge-10-workload-identity-401-errors)

### PART 19 — Interview Q&A for .NET Developers
- [19.1 — Conceptual Questions](#191--conceptual-questions)
- [19.2 — .NET-Specific Scenarios](#192--net-specific-scenarios)
- [19.3 — Architecture & Design Questions](#193--architecture--design-questions)
- [19.4 — Operational Questions](#194--operational-questions)

### PART 20 — AKS Development & Deployment — End-to-End Walkthrough
- [20.1 — The Full Development Workflow](#201--the-full-development-workflow)
- [20.2 — Step 1: Containerize the .NET App](#202--step-1-containerize-the-net-app)
- [20.3 — Step 2: Push to Azure Container Registry](#203--step-2-push-to-azure-container-registry)
- [20.4 — Step 3: Provision AKS Cluster](#204--step-3-provision-aks-cluster)
- [20.5 — Step 4: Deploy Applications](#205--step-4-deploy-applications)
- [20.6 — Step 5: Configure Autoscaling](#206--step-5-configure-autoscaling)
- [20.7 — Step 6: CI/CD Pipeline (Azure DevOps)](#207--step-6-cicd-pipeline-azure-devops)
- [20.8 — Step 7: Monitor in Production](#208--step-7-monitor-in-production)

### PART 21 — [Offline-Laptop] Practice AKS & Helm End-to-End Without Cloud
- [21.1 — Tool Choices: Which Local Kubernetes to Use?](#211--tool-choices-which-local-kubernetes-to-use)
- [21.2 — Prerequisites Installation (Windows)](#212--prerequisites-installation-windows)
- [21.3 — Start minikube with Production-Like Settings](#213--start-minikube-with-production-like-settings)
- [21.4 — Build the .NET Apps for Local Kubernetes](#214--build-the-net-apps-for-local-kubernetes)
- [21.5 — Build & Load Images into minikube](#215--build--load-images-into-minikube)
- [21.6 — Namespace & Core Kubernetes Objects](#216--namespace--core-kubernetes-objects)
- [21.7 — ConfigMap & Secret](#217--configmap--secret)
- [21.8 — Ingress (NGINX)](#218--ingress-nginx--replaces-app-gatewayagic-locally)
- [21.9 — Persistent Volumes (Local Storage)](#219--persistent-volumes-local-storage)
- [21.10 — HPA with Load Test](#2110--hpa-horizontal-pod-autoscaler--load-test)
- [21.11 — KEDA (Event-Driven Autoscaling) Locally](#2111--keda-event-driven-autoscaling-locally)
- [21.12 — Helm: Package Manager End-to-End](#2112--helm-package-manager-end-to-end)
- [21.13 — Prometheus & Grafana via Helm](#2113--prometheus--grafana-via-helm-local-monitoring)
- [21.14 — ArgoCD (GitOps) Locally](#2114--argocd-gitops-locally)
- [21.15 — Network Policies Locally (Calico)](#2115--network-policies-locally-calico)
- [21.16 — StatefulSet with Local Storage](#2116--statefulset-with-local-storage)
- [21.17 — DaemonSet (Runs on Every Node)](#2117--daemonset-runs-on-every-node)
- [21.18 — RBAC: Local Practice](#2118--rbac-local-practice)
- [21.19 — Full Cleanup & Restart Script](#2119--full-cleanup--restart-script)
- [21.20 — Feature Coverage Map: Local vs Cloud](#2120--feature-coverage-map-local-vs-cloud)
- [21.21 — Quick Reference: All Local Commands in Order](#2121--quick-reference-all-local-commands-in-order)

### PART 22 — Merged Insights: Unique Content from Reference Guide
- [22.1 — YAML Files Quick Index](#221--yaml-files-quick-index-orientation-map)
- [22.2 — .NET API-Level Auth with Entra ID (JWT Bearer)](#222--net-api-level-authentication-with-entra-id-jwt-bearer)
- [22.3 — Application Insights Full Integration for .NET on AKS](#223--application-insights-full-integration-for-net-on-aks)
- [22.4 — Structured Logging with ILogger in .NET Minimal API](#224--structured-logging-with-ilogger-in-net-minimal-api)
- [22.5 — AGIC + Azure DNS Complete Setup](#225--agic-application-gateway-ingress-controller--azure-dns)
- [22.6 — Helm Go Template Functions Deep Dive](#226--helm-go-template-functions-deep-dive)
- [22.7 — Sequential Troubleshooting Playbook](#227--sequential-troubleshooting-playbook)
- [22.8 — Architect-Level Reference: AKS Platform Patterns](#228--architect-level-reference-aks-platform-patterns)
- [22.9 — Command Output Interpretation Reference](#229--command-output-interpretation-reference)

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

# Sample Output:
# {
#   "azure-cli": "2.61.0",
#   "azure-cli-core": "2.61.0",
#   "azure-cli-telemetry": "1.1.0",
#   "extensions": {}
# }

# ─────────────────────────────────────────────────────────────────
# 2. Install kubectl and kubelogin
# ─────────────────────────────────────────────────────────────────
az aks install-cli

# Sample Output:
# Downloading client to "/usr/local/bin/kubectl" from "https://storage.googleapis.com/kubernetes-release/release/v1.31.2/bin/linux/amd64/kubectl"
# Downloading client to "/usr/local/bin/kubelogin" from "https://github.com/Azure/kubelogin/releases/download/v0.1.3/kubelogin-linux-amd64.zip"

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

# Sample Output:
# Registered

# ─────────────────────────────────────────────────────────────────
# 4. Login and set subscription
# ─────────────────────────────────────────────────────────────────
az login
az account set --subscription "My Subscription"
az account show

# Sample Output:
# {
#   "environmentName": "AzureCloud",
#   "id": "abc12345-1234-1234-1234-abcdef123456",
#   "name": "My Subscription",
#   "state": "Enabled",
#   "tenantId": "tenant-guid-here",
#   "user": { "name": "user@example.com", "type": "user" }
# }
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
# Sample Output (kubectl cluster-info):
# Kubernetes control plane is running at https://myaks-abc123.hcp.eastus.azmk8s.io:443
# CoreDNS is running at https://myaks-abc123.hcp.eastus.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
#
# Sample Output (kubectl get nodes -o wide):
# NAME                                STATUS   ROLES   AGE   VERSION   INTERNAL-IP   OS-IMAGE
# aks-nodepool1-12345678-vmss000000   Ready    agent   5d    v1.31.2   10.240.0.4    Ubuntu 22.04.3
# aks-nodepool1-12345678-vmss000001   Ready    agent   5d    v1.31.2   10.240.0.5    Ubuntu 22.04.3
# aks-nodepool1-12345678-vmss000002   Ready    agent   5d    v1.31.2   10.240.0.6    Ubuntu 22.04.3

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
# Output: deployment.apps/simpleapi1 image updated

# Watch the rollout progress:
kubectl rollout status deployment/simpleapi1 -n production
# Sample Output:
# Waiting for deployment "simpleapi1" rollout to finish: 1 out of 3 new replicas updated...
# Waiting for deployment "simpleapi1" rollout to finish: 2 out of 3 new replicas updated...
# Waiting for deployment "simpleapi1" rollout to finish: 1 old replicas pending termination...
# deployment "simpleapi1" successfully rolled out

# View rollout history:
kubectl rollout history deployment/simpleapi1 -n production
# Sample Output:
# REVISION  CHANGE-CAUSE
# 1         kubectl apply --filename=deployment.yaml --record=true
# 2         kubectl set image deployment/simpleapi1 simpleapi1=myacr.azurecr.io/simpleapi1:2.0.0 --record=true

# View details of a specific revision:
kubectl rollout history deployment/simpleapi1 -n production --revision=2
# Sample Output:
# deployment.apps/simpleapi1 with revision #2
# Pod Template:
#   Labels: app=simpleapi1, pod-template-hash=6c5d7b8e9
#   Annotations: kubernetes.io/change-cause: kubectl set image ... simpleapi1:2.0.0
#   Containers:
#    simpleapi1:
#     Image: myacr.azurecr.io/simpleapi1:2.0.0

# ─────────────────────────────────────────────────────────────────
# ROLLBACK: something broke in v2.0.0, roll back to previous version
# ─────────────────────────────────────────────────────────────────
kubectl rollout undo deployment/simpleapi1 -n production
# Output: deployment.apps/simpleapi1 rolled back

# Rollback to a specific revision:
kubectl rollout undo deployment/simpleapi1 -n production --to-revision=1
# Output: deployment.apps/simpleapi1 rolled back

# ─────────────────────────────────────────────────────────────────
# Pause a rollout (e.g., to validate partial rollout)
# ─────────────────────────────────────────────────────────────────
kubectl rollout pause deployment/simpleapi1 -n production
# Output: deployment.apps/simpleapi1 paused
# ... inspect, test ...
kubectl rollout resume deployment/simpleapi1 -n production
# Output: deployment.apps/simpleapi1 resumed

# ─────────────────────────────────────────────────────────────────
# Scale manually
# ─────────────────────────────────────────────────────────────────
kubectl scale deployment/simpleapi1 --replicas=5 -n production
# Output: deployment.apps/simpleapi1 scaled

# ─────────────────────────────────────────────────────────────────
# Restart all pods (rolling restart, useful when ConfigMap changes)
# ─────────────────────────────────────────────────────────────────
kubectl rollout restart deployment/simpleapi1 -n production
# Output: deployment.apps/simpleapi1 restarted
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
# Sample Output:
# NAME                          COMPLETIONS   DURATION   AGE
# simpleapi1-db-migrate-v2      1/1           38s        10m
# nightly-report-28500000       1/1           2m15s      8h
# nightly-report-28499940       1/1           2m08s      14h

# Watch a job's pods:
kubectl get pods -n production -l task=migration -w
# Sample Output:
# NAME                                   READY   STATUS      RESTARTS   AGE
# simpleapi1-db-migrate-v2-xkj2p         0/1     Pending     0          2s
# simpleapi1-db-migrate-v2-xkj2p         0/1     Init:0/1    0          4s
# simpleapi1-db-migrate-v2-xkj2p         0/1     Running     0          8s
# simpleapi1-db-migrate-v2-xkj2p         0/1     Completed   0          38s

# Get job logs:
kubectl logs -n production -l task=migration
# Sample Output:
# [2024-01-15 10:05:12] Starting database migration for simpleapi1 v2.0.0
# [2024-01-15 10:05:13] Applying migration: 20240115_AddUserTable
# [2024-01-15 10:05:14] Applying migration: 20240115_AddIndexes
# [2024-01-15 10:05:18] All migrations applied successfully. Total: 2

# Delete a completed job:
kubectl delete job simpleapi1-db-migrate-v2 -n production
# Output: job.batch/simpleapi1-db-migrate-v2 deleted

# Trigger a CronJob manually (creates a one-off Job from the CronJob template):
kubectl create job --from=cronjob/nightly-report manual-run-$(date +%s) -n production
# Output: job.batch/manual-run-1705312800 created

# Suspend a CronJob (pause future runs):
kubectl patch cronjob nightly-report -n production -p '{"spec":{"suspend":true}}'
# Output: cronjob.batch/nightly-report patched

# Resume a suspended CronJob:
kubectl patch cronjob nightly-report -n production -p '{"spec":{"suspend":false}}'
# Output: cronjob.batch/nightly-report patched
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

### Why Azure Load Balancer and Not Application Gateway?

> **Short Answer:** Azure Load Balancer (L4) and Application Gateway (L7) solve **different problems** and are often used **together** — not as alternatives. Understanding the OSI layer distinction is the key.

```
┌──────────────────────────────────────────────────────────────────────────┐
│         AZURE LOAD BALANCER  vs  APPLICATION GATEWAY IN AKS              │
│                                                                          │
│  OSI Model Layer                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ Layer 7 (HTTP/S)  │  Application Gateway / NGINX Ingress         │   │
│  │                   │  • Host-based routing (api.contoso.com)      │   │
│  │                   │  • Path-based routing (/api/v1, /api/v2)     │   │
│  │                   │  • SSL termination (TLS 1.3)                 │   │
│  │                   │  • WAF (Web Application Firewall)            │   │
│  │                   │  • Cookie-based session affinity             │   │
│  │                   │  • URL rewriting / redirects                 │   │
│  │                   │  • Health probes at HTTP level               │   │
│  ├──────────────────────────────────────────────────────────────────┤   │
│  │ Layer 4 (TCP/UDP) │  Azure Load Balancer (Service: LoadBalancer) │   │
│  │                   │  • Forwards TCP/UDP packets by port          │   │
│  │                   │  • Cannot read HTTP headers or paths         │   │
│  │                   │  • Ultra-low latency (hardware-level)        │   │
│  │                   │  • Auto-provisioned by AKS Cloud Controller  │   │
│  │                   │  • Handles ALL protocols (not just HTTP)     │   │
│  │                   │  • Scales to millions of connections         │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
```

**Why `Service: LoadBalancer` uses Azure Load Balancer (L4), not App Gateway:**

| Reason | Explanation |
|--------|-------------|
| **Automatic provisioning** | AKS Cloud Controller Manager creates the Azure LB automatically when you declare `type: LoadBalancer`. App Gateway requires manual setup + AGIC add-on. |
| **Protocol agnostic** | gRPC, TCP sockets, UDP, databases — App Gateway only handles HTTP/HTTPS. LB handles everything. |
| **Per-Service granularity** | Each `LoadBalancer` Service gets its own external IP. App Gateway is a single entry point for all HTTP traffic. |
| **Performance** | LB operates at hardware level — microsecond overhead. App Gateway is a software proxy — adds ~10-50ms. |
| **Simpler for non-HTTP** | Service Bus, Redis, SQL, gRPC — none work with App Gateway. All work with LB. |

**When to use Application Gateway (or NGINX Ingress) INSTEAD:**

| Use Case | Use App Gateway / NGINX Ingress |
|----------|---------------------------------|
| Multiple services on one IP via URL paths | `api.contoso.com/orders` → orders-svc, `/payments` → payments-svc |
| SSL termination (manage certs in one place) | TLS cert on App Gateway, plain HTTP to pods |
| WAF (block SQL injection, XSS) | App Gateway WAF v2 |
| Host-based routing (multiple subdomains) | `orders.contoso.com` vs `payments.contoso.com` |
| WebSocket or HTTP/2 | NGINX Ingress supports both |
| Cost (one IP for all services) | One App Gateway instead of 10 Load Balancers |

**The typical production pattern — use BOTH:**
```
Internet
   │
   ▼
Azure Application Gateway (L7)      ← handles: SSL, WAF, path routing, host routing
   │
   ▼
NGINX Ingress Controller            ← handles: fine-grained Kubernetes Ingress rules
   │
   ▼                      ▼
simpleapi1-svc          simpleapi2-svc    ← ClusterIP Services
   │                      │
   ▼                      ▼
Pods                     Pods

Azure Load Balancer is used internally by AKS node pools
(e.g., for internal services, non-HTTP traffic, health probes to nodes)
```

> **Key Insight:** Use `Service: LoadBalancer` for **non-HTTP protocols or quick external access during development**. Use **Ingress** (backed by NGINX or App Gateway) for **all production HTTP/HTTPS traffic** — better cost, SSL centralization, and routing flexibility.

---

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
# Output: configmap/simpleapi1-config created

# ─────────────────────────────────────────────────────────────────
# From a file (key = filename, value = file contents):
# ─────────────────────────────────────────────────────────────────
kubectl create configmap simpleapi1-appsettings \
  --from-file=appsettings.Production.json \
  -n production
# Output: configmap/simpleapi1-appsettings created

# ─────────────────────────────────────────────────────────────────
# From an env file (.env format: KEY=VALUE per line):
# ─────────────────────────────────────────────────────────────────
kubectl create configmap simpleapi1-env \
  --from-env-file=production.env \
  -n production
# Output: configmap/simpleapi1-env created
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
# Output: secret/simpleapi1-secrets created

# ─────────────────────────────────────────────────────────────────
# TLS secret from certificate files:
# ─────────────────────────────────────────────────────────────────
kubectl create secret tls tls-api-mycompany-com \
  --cert=./tls.crt \
  --key=./tls.key \
  -n production
# Output: secret/tls-api-mycompany-com created

# ─────────────────────────────────────────────────────────────────
# Docker registry secret (for pulling from private ACR):
# ─────────────────────────────────────────────────────────────────
kubectl create secret docker-registry acr-credentials \
  --docker-server=myacr.azurecr.io \
  --docker-username=myacr \
  --docker-password="$(az acr credential show -n myacr --query passwords[0].value -o tsv)" \
  -n production
# Output: secret/acr-credentials created
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
# yes

# Can service account cicd-sa create deployments in production?
kubectl auth can-i create deployments \
  --as=system:serviceaccount:production:cicd-sa \
  -n production
# yes

# Show ALL permissions for a service account:
kubectl auth can-i --list \
  --as=system:serviceaccount:production:cicd-sa \
  -n production
# Sample Output:
# Resources                                    Non-Resource URLs   Resource Names   Verbs
# deployments.apps                             []                  []               [get list watch create update patch delete]
# pods                                         []                  []               [get list watch]
# services                                     []                  []               [get list watch]
# configmaps                                   []                  []               [get list]
# secrets                                      []                  []               [get]

# Get all role bindings in a namespace:
kubectl get rolebindings,clusterrolebindings -n production -o wide
# Sample Output:
# NAME                                        ROLE                           AGE   USERS   GROUPS   SERVICEACCOUNTS
# rolebinding.rbac.../cicd-deploy-binding     Role/cicd-deploy               5d                     production/cicd-sa
# rolebinding.rbac.../developer-binding       Role/developer-read-only       5d            devs
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
# Output: namespace/production labeled

# Dev: just warn (don't block, but educate developers):
kubectl label namespace development \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/audit=baseline
# Output: namespace/development labeled

# System namespaces: privileged (needed for system pods):
kubectl label namespace kube-system \
  pod-security.kubernetes.io/enforce=privileged
# Output: namespace/kube-system labeled
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
# Output: namespace/argocd created

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Sample Output:
# customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
# customresourcedefinition.apiextensions.k8s.io/applicationsets.argoproj.io created
# customresourcedefinition.apiextensions.k8s.io/appprojects.argoproj.io created
# serviceaccount/argocd-application-controller created
# serviceaccount/argocd-server created
# clusterrole.rbac.authorization.k8s.io/argocd-application-controller created
# clusterrolebinding.rbac.authorization.k8s.io/argocd-application-controller created
# service/argocd-server created
# deployment.apps/argocd-server created
# deployment.apps/argocd-application-controller created

# Get ArgoCD initial admin password:
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
# Output: Abc1defGH2ijklMN

# Port-forward to access UI:
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Forwarding from 127.0.0.1:8080 -> 443
# Forwarding from [::1]:8080 -> 443
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
# Output: namespace/production labeled

# ─────────────────────────────────────────────────────────────────
# Verify Istio is working:
# ─────────────────────────────────────────────────────────────────
istioctl analyze -n production          # Check for misconfigurations
# Output: ✔ No validation issues found when analyzing namespace: production.

kubectl get pods -n istio-system        # All Istio control plane pods
# Sample Output:
# NAME                                    READY   STATUS    RESTARTS   AGE
# istiod-6b9f5d8c7-xkj2p                 1/1     Running   0          3d
# istio-ingressgateway-7d4b8c9f6-abc12   1/1     Running   0          3d
# istio-egressgateway-5c6d7b8e9-def34    1/1     Running   0          3d
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
# Sample Output:
# NAME                               STATUS   ROLES   AGE   VERSION
# aks-gpupool-12345678-vmss000000    Ready    agent   2d    v1.31.2

kubectl describe node <gpu-node> | grep nvidia
# Sample Output:
# nvidia.com/gpu:     1                          (capacity)
# nvidia.com/gpu:     1                          (allocatable)
# nvidia-device-plugin-daemonset   DaemonSet      nvidia/k8s-device-plugin:v0.14.5
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

### kubectl Command Mind Map — Full Tree

> **Mental Model:** kubectl is like a Swiss Army knife for Kubernetes. Each blade (subcommand) has a purpose, and flags are the settings on each blade. The tree below maps every major command → its flags/properties → what it controls.

```
kubectl
│
├── ── CLUSTER & CONTEXT ──────────────────────────────────────────────────────
│   │
│   ├── config
│   │   ├── get-contexts                   # List all clusters in kubeconfig
│   │   │   └── flags: -o name             # Just names (scriptable)
│   │   ├── current-context                # Show active cluster
│   │   ├── use-context <name>             # Switch active cluster
│   │   ├── set-context --current          # Modify current context in-place
│   │   │   └── --namespace=<ns>           # Change default namespace
│   │   ├── view                           # Print full kubeconfig
│   │   │   └── --minify                   # Show only active context
│   │   └── delete-context <name>          # Remove a cluster entry
│   │
│   ├── cluster-info                       # API server URL + addons
│   │   └── dump                           # Full cluster state dump (debugging)
│   │
│   └── version
│       ├── --client                       # kubectl binary version only
│       └── --output=yaml                  # Machine-readable version info
│
├── ── NAMESPACE ──────────────────────────────────────────────────────────────
│   │
│   ├── get namespaces / ns                # List all namespaces
│   │   └── flags: -o wide | -o yaml
│   ├── create namespace <name>            # Create a namespace
│   ├── delete namespace <name>            # Delete namespace + ALL resources in it
│   └── config set-context --current      # Set default namespace for session
│       └── --namespace=production
│
├── ── GET (read resources) ───────────────────────────────────────────────────
│   │
│   ├── get <resource>                     # Core read command
│   │   │
│   │   ├── RESOURCE TYPES:
│   │   │   ├── pods / po                  # Running workload instances
│   │   │   ├── deployments / deploy       # ReplicaSet managers
│   │   │   ├── services / svc             # Network endpoints
│   │   │   ├── configmaps / cm            # Key-value configs
│   │   │   ├── secrets                    # Encoded sensitive config
│   │   │   ├── ingress / ing              # HTTP routing rules
│   │   │   ├── nodes / no                 # Cluster machines
│   │   │   ├── namespaces / ns            # Logical partitions
│   │   │   ├── events                     # Cluster event log
│   │   │   ├── replicasets / rs           # Pod replica controllers
│   │   │   ├── statefulsets / sts         # Stateful app controllers
│   │   │   ├── daemonsets / ds            # Per-node pod controllers
│   │   │   ├── jobs                       # One-time workloads
│   │   │   ├── cronjobs / cj              # Scheduled jobs
│   │   │   ├── hpa                        # Horizontal Pod Autoscalers
│   │   │   ├── pv                         # PersistentVolumes (cluster-wide)
│   │   │   ├── pvc                        # PersistentVolumeClaims (namespaced)
│   │   │   ├── serviceaccounts / sa       # Pod identity for API access
│   │   │   ├── roles                      # Namespace-scoped RBAC
│   │   │   ├── clusterroles               # Cluster-scoped RBAC
│   │   │   ├── rolebindings               # Bind role to user/sa (namespaced)
│   │   │   └── clusterrolebindings        # Bind clusterrole (cluster-wide)
│   │   │
│   │   └── FLAGS (apply to all get commands):
│   │       ├── -n / --namespace <ns>      # Target namespace
│   │       ├── -A / --all-namespaces      # Show across all namespaces
│   │       ├── -l / --selector <label>    # Filter by label  e.g. app=api
│   │       ├── -o wide                    # Extra columns (node, IP)
│   │       ├── -o yaml                    # Full YAML definition
│   │       ├── -o json                    # Full JSON definition
│   │       ├── -o jsonpath='{.items[*].metadata.name}'   # Extract fields
│   │       ├── -o custom-columns=NAME:.metadata.name     # Custom table
│   │       ├── -w / --watch               # Live stream changes
│   │       ├── --show-labels              # Show all labels column
│   │       └── --field-selector           # Filter by field  e.g. status.phase=Running
│
├── ── DESCRIBE (human-readable deep-dive) ────────────────────────────────────
│   │
│   ├── describe pod <name>                # Events, conditions, mounts, limits
│   ├── describe deployment <name>         # Strategy, conditions, replicas
│   ├── describe node <name>              # Capacity, allocatable, taints
│   ├── describe service <name>            # Endpoints, selectors, ports
│   └── describe ingress <name>            # Rules, TLS, backend mapping
│       └── flags: -n <ns>
│
├── ── PODS (runtime operations) ──────────────────────────────────────────────
│   │
│   ├── logs <pod>                         # Print container logs
│   │   ├── -f / --follow                  # Stream live (like tail -f)
│   │   ├── --tail=<N>                     # Last N lines
│   │   ├── --since=1h                     # Logs from last 1 hour
│   │   ├── --since-time=<timestamp>       # Logs since ISO timestamp
│   │   ├── -c / --container=<name>        # Specific container in pod
│   │   ├── --previous                     # Logs from CRASHED container
│   │   └── -l app=simpleapi1              # Logs from ALL matching pods
│   │
│   ├── exec -it <pod> -- <cmd>            # Run command inside pod
│   │   ├── -- /bin/bash                   # Interactive shell
│   │   ├── -- sh                          # Minimal shell (alpine)
│   │   ├── -- env                         # Print env vars
│   │   ├── -- cat /etc/hosts             # Read a file
│   │   └── -c <container>                 # Target container in multi-container pod
│   │
│   ├── port-forward <target> <local>:<pod>
│   │   ├── pod/<pod-name> 8080:80         # Forward from pod
│   │   ├── svc/<svc-name> 8080:80         # Forward from service
│   │   ├── deploy/<deploy> 8080:80        # Forward from deployment
│   │   └── --address=0.0.0.0             # Bind to all interfaces (share LAN)
│   │
│   ├── cp <pod>:<path> <local-path>       # Copy file out of pod
│   │   └── <local-path> <pod>:<path>      # Copy file into pod
│   │
│   └── run <name> --image=<img>           # Create ad-hoc pod (debugging)
│       ├── -it --rm --restart=Never       # Interactive + auto-delete
│       ├── --image=busybox                # Network debug (nslookup, wget)
│       ├── --image=curlimages/curl        # HTTP test
│       └── -- <command>                   # Override entrypoint
│
├── ── DEPLOYMENTS (lifecycle) ────────────────────────────────────────────────
│   │
│   ├── apply -f <file|dir>                # Create or update (declarative)
│   │   ├── -f deployment.yaml             # Single file
│   │   ├── -f ./manifests/                # All files in directory
│   │   ├── -R                             # Recursive directory apply
│   │   └── --dry-run=client              # Validate without applying
│   │
│   ├── diff -f <file>                     # Show what WOULD change (safe preview)
│   │
│   ├── scale deployment/<name>            # Change replica count
│   │   └── --replicas=<N>
│   │
│   ├── set image deployment/<name>        # Update container image
│   │   └── <container>=<image>:<tag>
│   │
│   ├── rollout                            # Manage deployment rollouts
│   │   ├── status deployment/<name>       # Watch rollout progress
│   │   ├── history deployment/<name>      # List revision history
│   │   │   └── --revision=<N>            # Show specific revision details
│   │   ├── undo deployment/<name>         # Roll back to previous revision
│   │   │   └── --to-revision=<N>         # Roll back to specific revision
│   │   ├── restart deployment/<name>      # Rolling restart (new pods)
│   │   └── pause / resume <deploy>        # Pause/resume rolling update
│   │
│   ├── create deployment <name>           # Imperative create (quick testing)
│   │   ├── --image=<image>
│   │   └── --replicas=<N>
│   │
│   └── delete deployment/<name>           # Remove deployment
│       ├── -f <file>                      # Delete by manifest
│       ├── -l <label>                     # Delete by label selector
│       └── --grace-period=0               # Force immediate delete
│
├── ── SERVICES & NETWORKING ──────────────────────────────────────────────────
│   │
│   ├── get svc -n <ns> -o wide            # List services with IPs
│   ├── describe svc <name>                # Endpoints, selector, port rules
│   ├── get endpoints <svc>                # Pod IPs behind a service
│   ├── expose deployment/<name>           # Create service for deployment
│   │   ├── --port=80
│   │   ├── --target-port=8080
│   │   └── --type=ClusterIP|NodePort|LoadBalancer
│   │
│   └── run <debug-pod> --image=busybox    # Test DNS / connectivity from inside cluster
│       └── -- nslookup <svc>.<ns>
│
├── ── CONFIG & SECRETS ───────────────────────────────────────────────────────
│   │
│   ├── get configmap <name> -o yaml       # View config data
│   ├── create configmap <name>            # Create from literal/file
│   │   ├── --from-literal=KEY=VALUE
│   │   ├── --from-file=config.json        # File key = filename
│   │   └── --from-env-file=app.env
│   │
│   ├── get secret <name> -o yaml          # View secret (base64 encoded)
│   ├── create secret generic <name>       # Create opaque secret
│   │   ├── --from-literal=KEY=VALUE
│   │   └── --from-file=cert.pem
│   │
│   └── create secret docker-registry      # Docker pull secret for private registry
│       ├── --docker-server=<ACR_URL>
│       ├── --docker-username=<user>
│       └── --docker-password=<token>
│
├── ── RBAC ───────────────────────────────────────────────────────────────────
│   │
│   ├── get roles / clusterroles           # List RBAC roles
│   ├── get rolebindings / clusterrolebindings
│   ├── describe rolebinding <name>        # Who → what role in namespace
│   ├── create role <name>                 # Define namespace permissions
│   │   ├── --verb=get,list,watch
│   │   └── --resource=pods,deployments
│   ├── create rolebinding <name>          # Assign role to subject
│   │   ├── --role=<role>
│   │   ├── --serviceaccount=<ns>:<sa>
│   │   └── --user=<AAD_object_id>
│   └── auth can-i <verb> <resource>       # Check your own permissions
│       ├── --as=<user>                    # Impersonate for testing
│       └── -n <ns>
│
├── ── STORAGE ────────────────────────────────────────────────────────────────
│   │
│   ├── get pv                             # Cluster-wide persistent volumes
│   ├── get pvc -n <ns>                    # Namespace PV claims
│   ├── describe pvc <name>                # Binding status, capacity, events
│   └── delete pvc <name>                  # Release storage (data may be lost!)
│
├── ── AUTOSCALING ────────────────────────────────────────────────────────────
│   │
│   ├── get hpa -n <ns>                    # Horizontal Pod Autoscalers
│   ├── describe hpa <name>                # Min/max replicas, current metrics
│   └── autoscale deployment/<name>        # Create HPA imperatively
│       ├── --min=2
│       ├── --max=10
│       └── --cpu-percent=70
│
├── ── OBSERVABILITY & DEBUGGING ──────────────────────────────────────────────
│   │
│   ├── top nodes                          # Node CPU/Memory usage
│   │   └── --sort-by=cpu|memory
│   ├── top pods -n <ns>                   # Pod CPU/Memory usage
│   │   └── --sort-by=cpu|memory
│   ├── get events -n <ns>                 # Recent cluster events (errors visible here)
│   │   ├── --sort-by=.lastTimestamp       # Sort chronologically
│   │   └── --field-selector=involvedObject.name=<pod>  # Events for specific pod
│   ├── describe node <name>               # Node conditions, taints, resource pressure
│   └── debug node/<node>                  # Node-level debugging shell (K8s 1.23+)
│       ├── --image=busybox
│       └── -it
│
├── ── APPLY / DELETE / PATCH ─────────────────────────────────────────────────
│   │
│   ├── apply -f <file>                    # Declarative create-or-update
│   ├── delete -f <file>                   # Delete all resources in manifest
│   ├── delete <resource> <name>           # Delete by type + name
│   │   ├── --grace-period=0               # Immediate kill (no graceful shutdown)
│   │   └── --force                        # Force delete stuck pods
│   └── patch <resource> <name>            # In-place field update (JSON/strategic merge)
│       ├── --patch '{"spec":{"replicas":5}}'
│       └── --type=json                    # JSON patch format
│
├── ── OUTPUT FORMATS (-o flag) ───────────────────────────────────────────────
│   │
│   ├── -o wide                            # Extra columns (IPs, nodes)
│   ├── -o yaml                            # Full YAML definition
│   ├── -o json                            # Full JSON definition
│   ├── -o name                            # Resource type/name only (for scripts)
│   ├── -o jsonpath='{.spec.replicas}'     # Extract single field with JSONPath
│   ├── -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'  # Loop items
│   └── -o custom-columns=\               # Custom table layout
│       NAME:.metadata.name,\
│       IMAGE:.spec.containers[0].image,\
│       READY:.status.readyReplicas
│
└── ── SHORTCUTS & ALIASES ────────────────────────────────────────────────────
    │
    ├── kubectl api-resources               # List ALL resource types + short names
    ├── kubectl api-versions                # List all API groups/versions
    ├── kubectl explain <resource>          # Inline documentation for a resource
    │   └── kubectl explain pod.spec.containers.resources
    ├── kubectl completion bash             # Generate shell completion script
    └── COMMON ALIASES:
        ├── k  = kubectl
        ├── kgp = kubectl get pods
        ├── kgs = kubectl get svc
        ├── kgd = kubectl get deploy
        ├── kaf = kubectl apply -f
        ├── kdf = kubectl delete -f
        ├── kl  = kubectl logs -f
        └── kd  = kubectl describe
```

---

### kubectl Flag Quick Reference (Most Used)

| Flag | Short | Meaning | Example |
|------|-------|---------|---------|
| `--namespace` | `-n` | Target namespace | `-n production` |
| `--all-namespaces` | `-A` | All namespaces | `kubectl get pods -A` |
| `--output` | `-o` | Output format | `-o yaml`, `-o wide`, `-o json` |
| `--watch` | `-w` | Live stream changes | `kubectl get pods -w` |
| `--selector` | `-l` | Label filter | `-l app=api,env=prod` |
| `--field-selector` | — | Field filter | `--field-selector=status.phase=Running` |
| `--follow` | `-f` | Tail logs live | `kubectl logs -f <pod>` |
| `--previous` | — | Crashed container logs | `kubectl logs --previous <pod>` |
| `--dry-run` | — | Validate only | `--dry-run=client` |
| `--force` | — | Skip graceful delete | `kubectl delete pod --force` |
| `--grace-period` | — | Seconds before kill | `--grace-period=0` |
| `--from-literal` | — | Inline config/secret | `--from-literal=KEY=VAL` |
| `--replicas` | — | Desired replica count | `--replicas=5` |
| `--container` | `-c` | Target container | `-c sidecar` |
| `--as` | — | Impersonate user | `--as=system:serviceaccount:ns:sa` |
| `--sort-by` | — | Sort resource list | `--sort-by=.metadata.creationTimestamp` |
| `--show-labels` | — | Show all labels | `kubectl get pods --show-labels` |
| `--recursive` | `-R` | Recursive directory | `kubectl apply -f ./k8s/ -R` |

---

### kubectl Decision Tree — "Which command do I need?"

```
What do you want to do?
│
├── READ state
│   ├── Quick overview?           → kubectl get <resource> -n <ns>
│   ├── Deep details + events?    → kubectl describe <resource> <name>
│   ├── Raw YAML/JSON?            → kubectl get <resource> <name> -o yaml
│   └── Extract a single field?   → kubectl get <resource> <name> -o jsonpath='...'
│
├── MODIFY resources
│   ├── Apply a manifest?         → kubectl apply -f <file>
│   ├── Preview before applying?  → kubectl diff -f <file>
│   ├── Scale pods fast?          → kubectl scale deploy/<n> --replicas=<N>
│   ├── Restart all pods?         → kubectl rollout restart deploy/<n>
│   ├── Update image?             → kubectl set image deploy/<n> <c>=<image>:<tag>
│   └── Quick field change?       → kubectl patch <resource> <name> --patch '{...}'
│
├── DEBUG a problem
│   ├── Pod won't start?          → kubectl describe pod <name>  (check Events:)
│   ├── Container crashed?        → kubectl logs --previous <pod>
│   ├── Network issue?            → kubectl run debug --image=busybox -it --rm --restart=Never
│   ├── High resource use?        → kubectl top pods -n <ns> --sort-by=cpu
│   ├── Recent errors?            → kubectl get events -n <ns> --sort-by=.lastTimestamp
│   └── Node unhealthy?           → kubectl describe node <name>
│
├── ROLLOUT operations
│   ├── Check rollout progress?   → kubectl rollout status deploy/<name>
│   ├── View history?             → kubectl rollout history deploy/<name>
│   ├── Roll back?                → kubectl rollout undo deploy/<name>
│   └── Roll to specific rev?     → kubectl rollout undo deploy/<name> --to-revision=<N>
│
└── PERMISSIONS / RBAC
    ├── Can I do X?               → kubectl auth can-i <verb> <resource>
    ├── Can user Y do X?          → kubectl auth can-i <verb> <resource> --as=<user>
    └── Who has access?           → kubectl get rolebindings -n <ns> -o yaml
```

---

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
# Sample Outputs:
# kubectl config get-contexts:
# CURRENT   NAME        CLUSTER     AUTHINFO    NAMESPACE
# *         myAKS       myAKS       myAKS       production
#           myAKS-dev   myAKS-dev   myAKS-dev   default
#
# kubectl config current-context:
# myAKS
#
# kubectl config use-context myAKS:
# Switched to context "myAKS".
#
# kubectl cluster-info:
# Kubernetes control plane is running at https://myaks-abc123.hcp.eastus.azmk8s.io:443
#
# kubectl get nodes -o wide:
# NAME                               STATUS  ROLES  AGE  VERSION   INTERNAL-IP  OS-IMAGE
# aks-nodepool1-12345678-vmss000000  Ready   agent  5d   v1.31.2   10.240.0.4   Ubuntu 22.04.3
# aks-nodepool1-12345678-vmss000001  Ready   agent  5d   v1.31.2   10.240.0.5   Ubuntu 22.04.3
#
# kubectl get namespaces:
# NAME              STATUS   AGE
# default           Active   30d
# kube-system       Active   30d
# production        Active   25d
# ingress-nginx     Active   20d
#
# kubectl top nodes:
# NAME                                CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
# aks-nodepool1-12345678-vmss000000   312m         8%     2847Mi          21%
# aks-nodepool1-12345678-vmss000001   248m         6%     3102Mi          23%
#
# kubectl top pods -n production --sort-by=cpu:
# NAME                          CPU(cores)   MEMORY(bytes)
# simpleapi1-7d4b8c9f6-2xkpq   18m          45Mi
# simpleapi2-6c5d7b8e9-4vwxy   12m          38Mi
# simpleapi1-7d4b8c9f6-8mnlr   8m           42Mi

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
# Sample Outputs:
# kubectl get pods -n production:
# NAME                          READY   STATUS    RESTARTS   AGE
# simpleapi1-7d4b8c9f6-2xkpq   1/1     Running   0          2h
# simpleapi1-7d4b8c9f6-8mnlr   1/1     Running   0          2h
# simpleapi2-6c5d7b8e9-4vwxy   1/1     Running   0          2h
#
# kubectl get pods -n production -o wide:
# NAME                          READY  STATUS   RESTARTS  AGE  IP            NODE
# simpleapi1-7d4b8c9f6-2xkpq   1/1    Running  0         2h   10.244.1.15   aks-nodepool1-...-000000
# simpleapi1-7d4b8c9f6-8mnlr   1/1    Running  0         2h   10.244.2.8    aks-nodepool1-...-000001
#
# kubectl exec <pod> -n production -- wget -qO- http://simpleapi2-svc/health:
# {"status":"healthy","service":"simpleapi2"}
#
# kubectl port-forward svc/simpleapi1-svc 8080:80 -n production:
# Forwarding from 127.0.0.1:8080 -> 80
# Forwarding from [::1]:8080 -> 80

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
# Sample Outputs:
# kubectl get deployments -n production:
# NAME         READY   UP-TO-DATE   AVAILABLE   AGE
# simpleapi1   3/3     3            3           5d
# simpleapi2   3/3     3            3           5d
#
# kubectl scale deployment simpleapi1 --replicas=5 -n production:
# deployment.apps/simpleapi1 scaled
#
# kubectl set image deployment/simpleapi1 ...:
# deployment.apps/simpleapi1 image updated
#
# kubectl rollout status deployment/simpleapi1 -n production:
# Waiting for deployment "simpleapi1" rollout to finish: 2 out of 3 new replicas updated...
# deployment "simpleapi1" successfully rolled out
#
# kubectl rollout history deployment/simpleapi1 -n production:
# REVISION  CHANGE-CAUSE
# 1         Initial deployment v1
# 2         Update to v2.0.0
#
# kubectl rollout undo deployment/simpleapi1 -n production:
# deployment.apps/simpleapi1 rolled back
#
# kubectl rollout restart deployment/simpleapi1 -n production:
# deployment.apps/simpleapi1 restarted

### Services & Networking

```bash
# ── Services ───────────────────────────────────────────────────────
kubectl get services -n production -o wide       # Show service IPs
kubectl describe service simpleapi1-svc -n production  # Endpoints + details
kubectl get endpoints simpleapi1-svc -n production     # Pod IPs in service

# ── DNS debugging (test from inside a pod) ─────────────────────────
kubectl run dns-test --image=busybox -it --rm --restart=Never -- nslookup simpleapi1-svc.production
kubectl run curl-test --image=curlimages/curl -it --rm --restart=Never -- curl http://simpleapi1-svc.production/health
# Sample Outputs:
# kubectl get services -n production -o wide:
# NAME             TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)   AGE   SELECTOR
# simpleapi1-svc   ClusterIP      10.0.42.18    <none>           80/TCP    5d    app=simpleapi1
# simpleapi2-svc   ClusterIP      10.0.15.42    <none>           80/TCP    5d    app=simpleapi2
#
# kubectl get endpoints simpleapi1-svc -n production:
# NAME             ENDPOINTS                               AGE
# simpleapi1-svc   10.244.1.15:80,10.244.2.8:80           5d
#
# kubectl run dns-test ... -- nslookup simpleapi1-svc.production:
# Server:    10.0.0.10
# Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local
# Name:      simpleapi1-svc.production.svc.cluster.local
# Address 1: 10.0.42.18 simpleapi1-svc.production.svc.cluster.local
#
# kubectl run curl-test ... -- curl http://simpleapi1-svc.production/health:
# {"status":"healthy","service":"simpleapi1"}

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
# Sample Outputs:
# kubectl apply -f deployment.yaml:
# deployment.apps/simpleapi1 configured
#
# kubectl apply -f ./manifests/:
# deployment.apps/simpleapi1 configured
# service/simpleapi1-svc unchanged
# configmap/simpleapi1-config configured
# horizontalpodautoscaler.autoscaling/simpleapi1-hpa unchanged
#
# kubectl diff -f deployment.yaml:
# diff -u -N /tmp/LIVE-1234/apps.v1.Deployment.production.simpleapi1 /tmp/MERGED-1234/...
# --- /tmp/LIVE-1234/... 2024-01-15 10:00:00
# +++ /tmp/MERGED-1234/... 2024-01-15 10:05:00
# @@ -35,7 +35,7 @@
#    spec:
#      containers:
# -      image: acrdemo.azurecr.io/simpleapi1:v1
# +      image: acrdemo.azurecr.io/simpleapi1:v2
#
# kubectl delete deployment simpleapi1 -n production:
# deployment.apps/simpleapi1 deleted
#
# kubectl delete all -l app=simpleapi1 -n production:
# pod/simpleapi1-7d4b8c9f6-2xkpq deleted
# service/simpleapi1-svc deleted
# deployment.apps/simpleapi1 deleted

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
# selector: {app: simpleapi1}
kubectl get pods -n production --show-labels | grep simpleapi1
# simpleapi1-7d4b8c9f6-2xkpq  1/1  Running  0  2h  app=simpleapi1,pod-template-hash=7d4b8c9f6

# 2. Check endpoints (should list pod IPs):
kubectl get endpoints simpleapi1-svc -n production
# NAME             ENDPOINTS                        AGE
# simpleapi1-svc   10.244.1.15:80,10.244.2.8:80    5d
# If no endpoints: selector doesn't match any pod labels

# 3. Test from inside cluster:
kubectl run test --rm -it --image=curlimages/curl --restart=Never -- \
  curl http://simpleapi1-svc.production.svc.cluster.local/health
# {"status":"healthy","service":"simpleapi1"}

# ─────────────────────────────────────────────────────────────────
# ISSUE: DNS resolution failure
# ─────────────────────────────────────────────────────────────────
# Check CoreDNS is running:
kubectl get pods -n kube-system -l k8s-app=kube-dns
# NAME                       READY   STATUS    RESTARTS   AGE
# coredns-789d4b5c76-abc12   1/1     Running   0          30d
# coredns-789d4b5c76-def34   1/1     Running   0          30d

# Test DNS from pod:
kubectl run dns-test --rm -it --image=busybox --restart=Never -- \
  nslookup kubernetes.default
# Server:    10.0.0.10
# Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local
# Name:      kubernetes.default.svc.cluster.local
# Address 1: 10.0.0.1 kubernetes.default.svc.cluster.local
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
# NAME                                        READY   STATUS    RESTARTS   AGE
# ingress-nginx-controller-6b9df5c5fd-xkj2p   1/1     Running   0          10d

# 2. Check Ingress resource:
kubectl describe ingress apps-ingress -n production
# Look for "Address" (should be the external IP) and "Rules"

# 3. Check the backend service and endpoints:
kubectl get endpoints simpleapi1-svc -n production
# NAME             ENDPOINTS                        AGE
# simpleapi1-svc   10.244.1.15:80,10.244.2.8:80    5d

# 4. Check NGINX logs:
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller -f

# ─────────────────────────────────────────────────────────────────
# ISSUE: HPA not scaling (stuck at minimum)
# ─────────────────────────────────────────────────────────────────
kubectl describe hpa simpleapi1-hpa -n production
# Look for: "unable to get metrics" → metrics-server not working
kubectl get pods -n kube-system -l k8s-app=metrics-server
# NAME                              READY   STATUS    RESTARTS   AGE
# metrics-server-6d96f5b9d8-p8rzs   1/1     Running   0          25d
kubectl top pods -n production  # If this fails, metrics-server is broken
# NAME                          CPU(cores)   MEMORY(bytes)
# simpleapi1-7d4b8c9f6-2xkpq   5m           28Mi
# simpleapi2-6c5d7b8e9-4vwxy   6m           31Mi

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
# (no output on success)
kubectl exec -it <pod-name> -n production -- sh /tmp/debugtool.sh

# ─────────────────────────────────────────────────────────────────
# Get cluster events (last 10 minutes of events, sorted):
# ─────────────────────────────────────────────────────────────────
kubectl get events -n production \
  --sort-by='.lastTimestamp' \
  --field-selector type=Warning         # Only show Warning events
# Sample Output:
# LAST SEEN   TYPE      REASON      OBJECT                      MESSAGE
# 2m          Warning   BackOff     Pod/simpleapi1-crash-...    Back-off restarting failed container
# 5m          Warning   Failed      Pod/simpleapi1-crash-...    Failed to pull image: unauthorized

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
# Sample Output:
# NAME                               READY   STATUS    RESTARTS   AGE
# pod/simpleapi1-7d4b8c9f6-2xkpq    1/1     Running   0          2h
# pod/simpleapi1-7d4b8c9f6-8mnlr    1/1     Running   0          2h
# pod/simpleapi2-6c5d7b8e9-4vwxy    1/1     Running   0          2h
# NAME                    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
# service/simpleapi1-svc  ClusterIP   10.0.42.18   <none>        80/TCP    5d
# service/simpleapi2-svc  ClusterIP   10.0.15.42   <none>        80/TCP    5d
# NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.apps/simpleapi1  3/3     3            3           5d
# deployment.apps/simpleapi2  3/3     3            3           5d
# NAME                                   DESIRED   CURRENT   READY   AGE
# replicaset.apps/simpleapi1-7d4b8c9f6   3         3         3       2h

# Get pod logs and follow:
kubectl logs -f deployment/simpleapi1 -n production
# Sample Output:
# info: Microsoft.Hosting.Lifetime[14]
#       Now listening on: http://[::]:80
# info: Microsoft.Hosting.Lifetime[0]
#       Application started. Press Ctrl+C to shut down.
# info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
#       Request starting HTTP/1.1 GET http://10.244.0.1/health

# Debug a pod:
kubectl exec -it deployment/simpleapi1 -n production -- sh
# (opens interactive shell — no output displayed)

# Apply and watch rollout:
kubectl apply -f manifests/ -n production && \
  kubectl rollout status deployment/simpleapi1 -n production
# deployment.apps/simpleapi1 configured
# service/simpleapi1-svc unchanged
# configmap/simpleapi1-config configured
# Waiting for deployment "simpleapi1" rollout to finish: 1 out of 3 new replicas updated...
# deployment "simpleapi1" successfully rolled out

# Emergency: scale down a misbehaving deployment:
kubectl scale deployment simpleapi1 --replicas=0 -n production
# deployment.apps/simpleapi1 scaled

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

---

## PART 15: kubectl, kubeconfig & kubelet — Fundamentals Deep Dive

> **Mental Model:** Think of kubectl as your TV remote, kubeconfig as the remote's channel list (which TV/cluster to control), and kubelet as the smart TV's built-in firmware that carries out what the remote commands.

---

### 15.1 — The Kubernetes Client-Server Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HOW kubectl TALKS TO AKS                         │
│                                                                     │
│  Your Laptop                                                        │
│  ┌──────────────────────┐                                           │
│  │  kubectl             │   HTTPS REST API call                    │
│  │  (CLI client)        │ ─────────────────────────────────►       │
│  │                      │   e.g. GET /api/v1/namespaces/           │
│  │  reads ~/.kube/config│        default/pods                      │
│  └──────────────────────┘                                           │
│           │                      AKS Control Plane (Azure-managed)  │
│           │ reads          ┌─────────────────────────────────────┐  │
│           ▼                │   kube-apiserver                    │  │
│  ┌─────────────────┐       │   (validates, authenticates,        │  │
│  │  kubeconfig     │       │    persists to etcd, notifies       │  │
│  │  ~/.kube/config │       │    controllers)                     │  │
│  │                 │       └──────────────┬──────────────────────┘  │
│  │  clusters:      │                      │                          │
│  │  - name: myAKS  │              schedules pods                    │
│  │  users:         │                      ▼                          │
│  │  - name: myUser │       Worker Node (VM in node pool)            │
│  │  contexts:      │       ┌─────────────────────────────────────┐  │
│  │  - context:     │       │  kubelet                            │  │
│  │    cluster:myAKS│       │  (watches API server for pods       │  │
│  │    user: myUser │       │   assigned to this node,            │  │
│  └─────────────────┘       │   creates containers via containerd)│  │
│                            └─────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 15.2 — Installing kubectl

#### On Windows (via winget)
```powershell
# Install kubectl using winget
winget install -e --id Kubernetes.kubectl

# Verify installation
kubectl version --client

# Sample Output:
# Client Version: v1.31.0
# Kustomize Version: v5.4.2
```

#### On Windows (via curl)
```powershell
# Download latest stable kubectl
$version = (Invoke-WebRequest "https://dl.k8s.io/release/stable.txt").Content.Trim()
Invoke-WebRequest "https://dl.k8s.io/release/$version/bin/windows/amd64/kubectl.exe" -OutFile kubectl.exe

# Move to a directory in PATH
Move-Item .\kubectl.exe C:\Windows\System32\kubectl.exe
```

#### On Linux / WSL / Azure Cloud Shell
```bash
# Using apt (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl

# Verify
kubectl version --client --output=yaml
# Output:
# clientVersion:
#   major: "1"
#   minor: "31"
#   gitVersion: v1.31.0
#   platform: linux/amd64
```

#### Via Azure CLI (auto-installs matching version)
```bash
# This downloads the kubectl version that matches your AKS cluster
az aks install-cli

# Sample Output:
# Downloading client to "/usr/local/bin/kubectl" from "https://storage.googleapis.com/..."
# Please ensure that /usr/local/bin is in your search PATH...
# Downloading client to "/usr/local/bin/kubelogin" from "https://github.com/..."
```

#### Enable kubectl Shell Completion (Bash)
```bash
# Add to ~/.bashrc for persistent auto-completion
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc

# Now you can type: k get po<TAB>  →  k get pods
```

---

### 15.3 — kubeconfig Deep Dive

> **Mental Model:** kubeconfig is your "credentials wallet" for multiple Kubernetes clusters. Each entry is a card telling kubectl: where the cluster lives, what certificate to trust, and what identity to use.

#### The kubeconfig File Structure

```yaml
# ~/.kube/config — Annotated anatomy of a kubeconfig file
# ─────────────────────────────────────────────────────────

apiVersion: v1          # Always v1 for kubeconfig
kind: Config            # Always Config

# ── PREFERENCES ──────────────────────────────────────────
preferences: {}         # Optional: colors, editor preferences

# ── CLUSTERS ─────────────────────────────────────────────
# Each entry = one Kubernetes cluster (API server endpoint + CA cert)
clusters:
- name: myAKS-dev       # Friendly name you give this cluster entry
  cluster:
    # The HTTPS endpoint of the kube-apiserver
    server: https://myaks-dev-abc123.hcp.eastus.azmk8s.io:443

    # Base64-encoded PEM certificate of the cluster's Certificate Authority
    # kubectl uses this to verify the server's TLS cert (prevents MITM attacks)
    certificate-authority-data: LS0tLS1CRUdJTi...

    # Alternative: point to a file instead of inline data
    # certificate-authority: /path/to/ca.crt

- name: myAKS-prod
  cluster:
    server: https://myaks-prod-xyz789.hcp.eastus.azmk8s.io:443
    certificate-authority-data: LS0tLS1CRUdJTi...

# ── USERS ────────────────────────────────────────────────
# Each entry = one identity (how to authenticate to a cluster)
users:
- name: myAKS-dev-admin
  user:
    # For AKS with Azure AD, kubelogin handles token acquisition
    # This exec block calls kubelogin to get a bearer token
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: kubelogin          # Azure-specific kubectl credential plugin
      args:
      - get-token
      - --environment
      - AzurePublicCloud
      - --server-id             # Azure AD app ID of the AKS server
      - 6dae42f8-4368-4678-94ff-3960e28e3630
      - --client-id             # Your service principal or managed identity
      - 80faf920-1908-4b52-b5ef-a8e912690b2e
      - --tenant-id
      - 72f988bf-86f1-41af-91ab-2d7cd011db47
      env: null
      provideClusterInfo: false

- name: myAKS-prod-admin
  user:
    # Alternative: static client certificate auth (less common in AKS)
    client-certificate-data: LS0tLS1CRUdJTi...
    client-key-data: LS0tLS1CRUdJTi...

# ── CONTEXTS ─────────────────────────────────────────────
# A context = a named pairing of (cluster + user + optional namespace)
# This is what you switch between with: kubectl config use-context
contexts:
- name: myAKS-dev             # The context name you use in kubectl
  context:
    cluster: myAKS-dev        # References the cluster entry above
    user: myAKS-dev-admin     # References the user entry above
    namespace: default        # Optional: default namespace for this context

- name: myAKS-prod
  context:
    cluster: myAKS-prod
    user: myAKS-prod-admin
    namespace: production     # All kubectl commands default to this namespace

# ── CURRENT CONTEXT ──────────────────────────────────────
# The active context — which cluster/user kubectl uses right now
current-context: myAKS-dev
```

#### kubeconfig Diagram: Multi-Context Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                   kubeconfig CONTEXT SWITCHING                     │
│                                                                    │
│  ~/.kube/config                                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  contexts:                                                  │  │
│  │   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   │  │
│  │   │ myAKS-dev    │   │ myAKS-staging│   │ myAKS-prod   │   │  │
│  │   │ cluster: dev │   │ cluster: stg │   │ cluster: prd │   │  │
│  │   │ user: dev-sp │   │ user: stg-sp │   │ user: prd-sp │   │  │
│  │   │ ns: default  │   │ ns: staging  │   │ ns: production│  │  │
│  │   └──────┬───────┘   └──────┬───────┘   └──────┬───────┘   │  │
│  └──────────┼───────────────────┼───────────────────┼──────────┘  │
│             │                   │                   │              │
│    current-context ─────────────►                                  │
│    = myAKS-dev                  ↑                                  │
│                    kubectl config use-context myAKS-staging        │
│                                                                    │
│  Commands:                                                         │
│  kubectl config get-contexts          # list all contexts          │
│  kubectl config current-context       # show active context        │
│  kubectl config use-context myAKS-prod # switch context           │
│  kubectl config set-context --current --namespace=kube-system      │
└────────────────────────────────────────────────────────────────────┘
```

#### Getting AKS Credentials (Adds Entry to kubeconfig)
```bash
# Merge AKS credentials into ~/.kube/config
# This adds a new cluster + user + context entry
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster

# Sample Output:
# Merged "myAKSCluster" as current context in /home/user/.kube/config

# Get credentials as admin (bypasses Azure AD — for break-glass access)
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --admin

# Overwrite existing entry if cluster was recreated
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --overwrite-existing

# Save to a specific file instead of ~/.kube/config
az aks get-credentials \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --file ./myaks-kubeconfig.yaml

# Use a non-default kubeconfig file for one command
KUBECONFIG=./myaks-kubeconfig.yaml kubectl get nodes
```

#### Managing Multiple Clusters
```bash
# View all contexts
kubectl config get-contexts

# Sample Output:
# CURRENT   NAME              CLUSTER           AUTHINFO              NAMESPACE
# *         myAKS-dev         myAKS-dev         clusterUser_myRG_dev  default
#           myAKS-prod        myAKS-prod        clusterUser_myRG_prd  production
#           minikube          minikube          minikube              default

# Switch to prod context
kubectl config use-context myAKS-prod
# Output: Switched to context "myAKS-prod".

# View the current context
kubectl config current-context
# Output: myAKS-prod

# Set default namespace for current context (avoid typing -n every time)
kubectl config set-context --current --namespace=my-team

# Merge two kubeconfig files into one
KUBECONFIG=~/.kube/config:./new-cluster.yaml kubectl config view --flatten > ~/.kube/merged-config
mv ~/.kube/merged-config ~/.kube/config

# Delete a context (e.g., decommissioned cluster)
kubectl config delete-context myAKS-old
kubectl config delete-cluster myAKS-old
kubectl config delete-user clusterUser_myRG_old
```

---

### 15.4 — kubelet: The Node Agent

> **Mental Model:** If the API server is the brain sending orders ("Run this pod!"), kubelet is the hands on each node that actually carry out those orders — pulling images, creating containers, mounting volumes, running health checks, and reporting status back.

#### What kubelet Does

```
┌────────────────────────────────────────────────────────────────────┐
│                    KUBELET RESPONSIBILITIES                        │
│                                                                    │
│  AKS Worker Node (VM)                                              │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │  kubelet (system process, runs as root)                      │ │
│  │                                                              │ │
│  │  1. WATCH API SERVER                                         │ │
│  │     Polls for PodSpecs assigned to this node                 │ │
│  │     (via node name field in pod spec)                        │ │
│  │                                                              │ │
│  │  2. PULL IMAGES                                              │ │
│  │     Calls containerd CRI to pull container images            │ │
│  │     from ACR / Docker Hub                                    │ │
│  │                                                              │ │
│  │  3. CREATE CONTAINERS                                        │ │
│  │     Calls containerd to start containers in pod              │ │
│  │     Sets up namespaces: network, PID, IPC, UTS               │ │
│  │                                                              │ │
│  │  4. MOUNT VOLUMES                                            │ │
│  │     Calls CSI drivers to attach Azure Disk/Files             │ │
│  │     Mounts ConfigMaps and Secrets as files                   │ │
│  │                                                              │ │
│  │  5. RUN HEALTH PROBES                                        │ │
│  │     Liveness: restart container if unhealthy                 │ │
│  │     Readiness: remove from Service endpoints if not ready    │ │
│  │     Startup: give slow-starting containers extra time        │ │
│  │                                                              │ │
│  │  6. REPORT STATUS BACK                                       │ │
│  │     Updates Pod status in API server every ~10 seconds       │ │
│  │     Reports node conditions (Ready, MemoryPressure, etc.)    │ │
│  │                                                              │ │
│  │  ┌─────────────┐    ┌──────────────┐    ┌─────────────────┐ │ │
│  │  │  containerd │    │  CSI drivers │    │  CNI plugins    │ │ │
│  │  │  (container │    │  (Azure Disk │    │  (Azure CNI /   │ │ │
│  │  │   runtime)  │    │   Azure Files│    │   Cilium)       │ │ │
│  │  └─────────────┘    └──────────────┘    └─────────────────┘ │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

#### kubelet in AKS — What Azure Manages vs What You Configure

| Aspect | Azure Manages | You Configure |
|--------|--------------|---------------|
| kubelet binary | Auto-updated during node upgrades | Not directly |
| kubelet config | Sensible defaults | `--kubelet-config` via node pool |
| Container runtime | containerd (AKS 1.19+) | Not changeable |
| Node registration | Auto-registers with API server | Node labels/taints |
| Log rotation | Managed | Log analytics integration |
| Image GC | Automatic (disk pressure) | GC thresholds via kubelet config |

#### Inspecting kubelet on an AKS Node
```bash
# SSH into a node (AKS uses ephemeral OS disks — use debug pod instead)
kubectl debug node/aks-nodepool1-12345678-vmss000000 -it --image=mcr.microsoft.com/cbl-mariner/busybox:2.0

# Inside the debug pod (chroot to host)
chroot /host

# Check kubelet process
systemctl status kubelet
# Output:
# ● kubelet.service - kubelet: The Kubernetes Node Agent
#    Loaded: loaded (/etc/systemd/system/kubelet.service; enabled)
#    Active: active (running) since Mon 2026-02-23 09:15:32 UTC; 3 days ago
#  Main PID: 1234 (kubelet)

# View kubelet flags and configuration
ps aux | grep kubelet
# Output snippet:
# /usr/local/bin/kubelet
#   --cloud-provider=external
#   --container-runtime-endpoint=unix:///run/containerd/containerd.sock
#   --node-labels=agentpool=nodepool1,kubernetes.azure.com/agentpool=nodepool1
#   --pod-infra-container-image=mcr.microsoft.com/oss/kubernetes/pause:3.6

# View kubelet logs
journalctl -u kubelet -n 100 --no-pager
```

#### Node Conditions Reported by kubelet
```bash
kubectl describe node aks-nodepool1-12345678-vmss000000

# Sample Output (Conditions section):
# Conditions:
#   Type                 Status  Reason                       Message
#   ─────────────────── ──────  ──────                       ───────
#   NetworkUnavailable   False   RouteCreated                 RouteController created...
#   MemoryPressure       False   KubeletHasSufficientMemory   kubelet has sufficient memory
#   DiskPressure         False   KubeletHasNoDiskPressure     kubelet has no disk pressure
#   PIDPressure          False   KubeletHasSufficientPIDs     kubelet has sufficient PIDs
#   Ready                True    KubeletReady                 kubelet is posting ready status
#
# Capacity:
#   cpu:                4        ← Total CPUs on VM
#   memory:             16Gi     ← Total RAM
#   pods:               110      ← Max pods (default kubelet limit)
#   ephemeral-storage:  128Gi
#
# Allocatable:          ← What's available AFTER system/kubelet reservations
#   cpu:                3800m    ← 200m reserved for kubelet/OS
#   memory:             13Gi     ← ~3Gi reserved for system
#   pods:               110
```

---

### 15.5 — kubectl Commands with Sample Outputs

#### Cluster Information
```bash
# Display API server endpoint and cluster info
kubectl cluster-info

# Sample Output:
# Kubernetes control plane is running at https://myaks-abc123.hcp.eastus.azmk8s.io:443
# CoreDNS is running at https://myaks-abc123.hcp.eastus.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

# List all nodes with status, roles, age, and K8s version
kubectl get nodes

# Sample Output:
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-nodepool1-12345678-vmss000000   Ready    agent   5d    v1.31.2
# aks-nodepool1-12345678-vmss000001   Ready    agent   5d    v1.31.2
# aks-nodepool1-12345678-vmss000002   Ready    agent   5d    v1.31.2

# Wide output — shows internal IP, OS image, kernel
kubectl get nodes -o wide

# Sample Output:
# NAME                               STATUS  ROLES  AGE  VERSION   INTERNAL-IP   OS-IMAGE
# aks-nodepool1-12345678-vmss000000  Ready   agent  5d   v1.31.2   10.240.0.4    Ubuntu 22.04.3
# aks-nodepool1-12345678-vmss000001  Ready   agent  5d   v1.31.2   10.240.0.5    Ubuntu 22.04.3

# Show node resource usage (requires metrics-server)
kubectl top nodes

# Sample Output:
# NAME                                CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
# aks-nodepool1-12345678-vmss000000   312m         8%     2847Mi          21%
# aks-nodepool1-12345678-vmss000001   248m         6%     3102Mi          23%
```

#### Working with Pods
```bash
# List pods in current namespace
kubectl get pods

# Sample Output:
# NAME                          READY   STATUS    RESTARTS   AGE
# simpleapi1-7d4b8c9f6-2xkpq   1/1     Running   0          2h
# simpleapi1-7d4b8c9f6-8mnlr   1/1     Running   0          2h
# simpleapi2-6c5d7b8e9-4vwxy   1/1     Running   0          2h

# List pods in ALL namespaces
kubectl get pods --all-namespaces
# or shorthand:
kubectl get pods -A

# Sample Output:
# NAMESPACE     NAME                              READY   STATUS    RESTARTS
# kube-system   coredns-789d4b5c76-abc12          1/1     Running   0
# kube-system   coredns-789d4b5c76-def34          1/1     Running   0
# kube-system   azure-ip-masq-agent-xxxx          1/1     Running   0
# kube-system   kube-proxy-xxxx                   1/1     Running   0
# simple-apis   simpleapi1-7d4b8c9f6-2xkpq        1/1     Running   0

# Show pod details (events, volumes, probes, node placement)
kubectl describe pod simpleapi1-7d4b8c9f6-2xkpq -n simple-apis

# Sample Output (abbreviated):
# Name:             simpleapi1-7d4b8c9f6-2xkpq
# Namespace:        simple-apis
# Node:             aks-nodepool1-12345678-vmss000000/10.240.0.4
# Status:           Running
# IP:               10.244.1.15
# Controlled By:    ReplicaSet/simpleapi1-7d4b8c9f6
# Containers:
#   simpleapi1:
#     Image:          acrdemo.azurecr.io/simpleapi1:v1
#     Limits:         cpu: 500m, memory: 512Mi
#     Requests:       cpu: 100m, memory: 128Mi
#     Liveness:       http-get http://:80/health delay=15s timeout=5s
#     Readiness:      http-get http://:80/health delay=5s timeout=3s
# Events:
#   Normal  Scheduled  2h    Successfully assigned simple-apis/simpleapi1-... to node
#   Normal  Pulled     2h    Successfully pulled image "acrdemo.azurecr.io/simpleapi1:v1"
#   Normal  Created    2h    Created container simpleapi1
#   Normal  Started    2h    Started container simpleapi1

# Show pod resource usage
kubectl top pod -n simple-apis

# Sample Output:
# NAME                          CPU(cores)   MEMORY(bytes)
# simpleapi1-7d4b8c9f6-2xkpq   5m           28Mi
# simpleapi1-7d4b8c9f6-8mnlr   4m           26Mi
# simpleapi2-6c5d7b8e9-4vwxy   6m           31Mi
```

#### Logs
```bash
# Stream logs from a pod
kubectl logs simpleapi1-7d4b8c9f6-2xkpq -n simple-apis

# Follow (tail -f equivalent)
kubectl logs -f simpleapi1-7d4b8c9f6-2xkpq -n simple-apis

# Last 50 lines only
kubectl logs --tail=50 simpleapi1-7d4b8c9f6-2xkpq -n simple-apis

# Logs from previous container instance (useful after crash)
kubectl logs simpleapi1-7d4b8c9f6-2xkpq -n simple-apis --previous

# Logs from all pods matching a label selector
kubectl logs -l app=simpleapi1 -n simple-apis --all-containers=true

# Sample Output:
# info: Microsoft.Hosting.Lifetime[14]
#       Now listening on: http://[::]:80
# info: Microsoft.Hosting.Lifetime[0]
#       Application started. Press Ctrl+C to shut down.
# info: Microsoft.AspNetCore.Hosting.Diagnostics[1]
#       Request starting HTTP/1.1 GET http://10.244.1.1/health - null 0
# info: Microsoft.AspNetCore.Routing.EndpointMiddleware[0]
#       Executing endpoint 'HTTP: GET /health'
```

#### Exec Into a Container
```bash
# Open interactive bash shell in a running container
kubectl exec -it simpleapi1-7d4b8c9f6-2xkpq -n simple-apis -- /bin/bash

# Run a single command without interactive shell
kubectl exec simpleapi1-7d4b8c9f6-2xkpq -n simple-apis -- env

# Sample Output:
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# ASPNETCORE_HTTP_PORTS=80
# SIMPLEAPI2_SVC_SERVICE_HOST=10.0.15.42
# SIMPLEAPI2_SVC_SERVICE_PORT=80
# KUBERNETES_SERVICE_HOST=10.0.0.1
# KUBERNETES_SERVICE_PORT=443

# Test DNS resolution from inside pod
kubectl exec simpleapi1-7d4b8c9f6-2xkpq -n simple-apis -- \
  nslookup simpleapi2-svc.simple-apis.svc.cluster.local

# Sample Output:
# Server:    10.0.0.10
# Address 1: 10.0.0.10 kube-dns.kube-system.svc.cluster.local
# Name:      simpleapi2-svc.simple-apis.svc.cluster.local
# Address 1: 10.0.15.42 simpleapi2-svc.simple-apis.svc.cluster.local
```

#### Deployments & Rollouts
```bash
# List deployments
kubectl get deployments -n simple-apis

# Sample Output:
# NAME         READY   UP-TO-DATE   AVAILABLE   AGE
# simpleapi1   3/3     3            3           2d
# simpleapi2   3/3     3            3           2d

# Check rollout status
kubectl rollout status deployment/simpleapi1 -n simple-apis

# Sample Output (in-progress):
# Waiting for deployment "simpleapi1" rollout to finish: 1 out of 3 new replicas updated...
# Waiting for deployment "simpleapi1" rollout to finish: 2 out of 3 new replicas updated...
# Waiting for deployment "simpleapi1" rollout to finish: 1 old replicas are pending termination...
# deployment "simpleapi1" successfully rolled out

# View rollout history
kubectl rollout history deployment/simpleapi1 -n simple-apis

# Sample Output:
# REVISION  CHANGE-CAUSE
# 1         Initial deployment v1
# 2         Update to v2 — add /metrics endpoint
# 3         Hotfix: fix null reference in /weatherforecast

# Rollback to previous version
kubectl rollout undo deployment/simpleapi1 -n simple-apis
# Output: deployment.apps/simpleapi1 rolled back

# Rollback to specific revision
kubectl rollout undo deployment/simpleapi1 --to-revision=2 -n simple-apis
```

#### Services & Endpoints
```bash
# List services
kubectl get services -n simple-apis

# Sample Output:
# NAME             TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
# simpleapi1-svc   ClusterIP      10.0.42.18    <none>           80/TCP         2d
# simpleapi2-svc   ClusterIP      10.0.15.42    <none>           80/TCP         2d
# api-lb           LoadBalancer   10.0.200.5    52.186.142.10    80:31204/TCP   2d

# Get the endpoints backing a service (actual pod IPs)
kubectl get endpoints simpleapi1-svc -n simple-apis

# Sample Output:
# NAME             ENDPOINTS                                     AGE
# simpleapi1-svc   10.244.1.15:80,10.244.2.8:80,10.244.3.4:80   2d

# Port-forward service to local machine (for testing without Ingress)
kubectl port-forward svc/simpleapi1-svc 8080:80 -n simple-apis

# Sample Output:
# Forwarding from 127.0.0.1:8080 -> 80
# Forwarding from [::1]:8080 -> 80
# Now open: http://localhost:8080/health
```

#### Events (crucial for debugging)
```bash
# Show recent events in namespace (sorted by time)
kubectl get events -n simple-apis --sort-by='.lastTimestamp'

# Sample Output:
# LAST SEEN   TYPE      REASON              OBJECT                          MESSAGE
# 5m          Normal    Scheduled           Pod/simpleapi1-7d4b8...        Assigned to node
# 5m          Normal    Pulling             Pod/simpleapi1-7d4b8...        Pulling image "acrdemo..."
# 4m          Normal    Pulled              Pod/simpleapi1-7d4b8...        Successfully pulled image
# 4m          Normal    Created             Pod/simpleapi1-7d4b8...        Created container
# 4m          Normal    Started             Pod/simpleapi1-7d4b8...        Started container
# 2m          Warning   BackOff             Pod/simpleapi1-crash...        Back-off restarting failed container

# Show events for a specific object
kubectl describe deployment simpleapi1 -n simple-apis | grep -A 20 Events
```

---

### 15.6 — kubectl Output Formats

```bash
# Default table output
kubectl get pods -n simple-apis

# YAML output (shows full object spec + status)
kubectl get pod simpleapi1-7d4b8c9f6-2xkpq -n simple-apis -o yaml

# JSON output
kubectl get pod simpleapi1-7d4b8c9f6-2xkpq -n simple-apis -o json

# JSONPath — extract specific field
kubectl get pod simpleapi1-7d4b8c9f6-2xkpq -n simple-apis \
  -o jsonpath='{.status.podIP}'
# Output: 10.244.1.15

# Get all pod IPs in a namespace
kubectl get pods -n simple-apis \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.podIP}{"\n"}{end}'
# Output:
# simpleapi1-7d4b8c9f6-2xkpq   10.244.1.15
# simpleapi1-7d4b8c9f6-8mnlr   10.244.2.8
# simpleapi2-6c5d7b8e9-4vwxy   10.244.3.4

# Custom columns
kubectl get pods -n simple-apis \
  -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
# Output:
# NAME                          STATUS    NODE
# simpleapi1-7d4b8c9f6-2xkpq   Running   aks-nodepool1-12345678-vmss000000
# simpleapi2-6c5d7b8e9-4vwxy   Running   aks-nodepool1-12345678-vmss000001
```

---

## PART 16: Service-to-Service Communication Deep Dive

> **Mental Model:** Every service in Kubernetes gets a stable "internal phone number" (DNS name). Pod IPs change constantly, but DNS names never do. When SimpleApi1 calls SimpleApi2, it uses the DNS name — Kubernetes' internal DNS (CoreDNS) resolves it to the correct pod IPs and load-balances.

---

### 16.1 — Kubernetes DNS: The Full Name Format

```
┌────────────────────────────────────────────────────────────────────┐
│              KUBERNETES SERVICE DNS RESOLUTION                     │
│                                                                    │
│  Full DNS Name Format:                                             │
│  <service-name>.<namespace>.svc.cluster.local                     │
│                                                                    │
│  Example:                                                          │
│  simpleapi2-svc.simple-apis.svc.cluster.local                     │
│       │            │          │       │                            │
│       │            │          │       └── Zone root (fixed)        │
│       │            │          └────────── "svc" subdomain (fixed)  │
│       │            └───────────────────── namespace name           │
│       └────────────────────────────────── Service name            │
│                                                                    │
│  Short forms (work within same namespace):                         │
│  simpleapi2-svc              ← same namespace only                 │
│  simpleapi2-svc.simple-apis  ← cross-namespace short              │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  CoreDNS (kube-system)                                      │  │
│  │                                                             │  │
│  │  When a pod looks up "simpleapi2-svc.simple-apis":          │  │
│  │  1. Pod sends DNS query to nameserver 10.0.0.10             │  │
│  │     (injected into /etc/resolv.conf by kubelet)             │  │
│  │  2. CoreDNS receives query                                  │  │
│  │  3. CoreDNS looks up Service in API server                  │  │
│  │  4. Returns ClusterIP: 10.0.15.42                           │  │
│  │  5. kube-proxy routes TCP to one of the pod IPs             │  │
│  └─────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

#### /etc/resolv.conf Inside Every Pod
```bash
kubectl exec simpleapi1-7d4b8c9f6-2xkpq -n simple-apis -- cat /etc/resolv.conf

# Output:
# search simple-apis.svc.cluster.local svc.cluster.local cluster.local
# nameserver 10.0.0.10    ← CoreDNS ClusterIP
# options ndots:5
#
# The "search" domains mean: when you use short name "simpleapi2-svc",
# DNS resolver appends these suffixes in order until it gets an answer:
#  1. simpleapi2-svc.simple-apis.svc.cluster.local ← FOUND → returns IP
```

---

### 16.2 — Kubernetes YAML: Two-Service Setup (SimpleApi1 → SimpleApi2)

#### SimpleApi2 Deployment & Service
```yaml
# simpleapi2-deployment.yaml
# ─────────────────────────────────────────────────────────────────────
# SimpleApi2: the "backend" service that SimpleApi1 calls internally
# ─────────────────────────────────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi2                    # Name of the Deployment object
  namespace: simple-apis              # Must exist: kubectl create ns simple-apis
  labels:
    app: simpleapi2
    tier: backend
spec:
  replicas: 2                         # 2 pods for HA
  selector:
    matchLabels:
      app: simpleapi2                 # Selects pods with this label
  template:
    metadata:
      labels:
        app: simpleapi2
        tier: backend
    spec:
      containers:
      - name: simpleapi2
        image: acrdemo.azurecr.io/simpleapi2:v1
        ports:
        - containerPort: 80           # Port the app listens on inside container
        resources:
          requests:
            cpu: "100m"               # Guaranteed CPU (0.1 vCPU)
            memory: "128Mi"           # Guaranteed memory
          limits:
            cpu: "500m"               # Max CPU before throttling
            memory: "512Mi"           # Max memory before OOMKill
        env:
        - name: ASPNETCORE_HTTP_PORTS
          value: "80"
        readinessProbe:               # Pod added to Service endpoints only when ready
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5      # Wait 5s before first probe
          periodSeconds: 10           # Probe every 10s
        livenessProbe:                # Restart container if unhealthy
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20

---
# simpleapi2-service.yaml
# ClusterIP Service — only reachable from inside the cluster
# This is the "stable phone number" SimpleApi1 will call
apiVersion: v1
kind: Service
metadata:
  name: simpleapi2-svc                # DNS name: simpleapi2-svc.simple-apis.svc.cluster.local
  namespace: simple-apis
  labels:
    app: simpleapi2
spec:
  type: ClusterIP                     # Internal-only (no external IP)
  selector:
    app: simpleapi2                   # Routes to all pods with label app=simpleapi2
  ports:
  - name: http
    protocol: TCP
    port: 80                          # Port exposed by this Service
    targetPort: 80                    # Port on the pod (container port)
```
In your YAML snippet, the `protocol: TCP` line under the `ports` section specifies the **network protocol** that the Kubernetes Service will use to forward traffic to the pods.  

Here’s what it means in context:

- **TCP vs. UDP**: Kubernetes Services can expose ports using either TCP or UDP. TCP is the most common choice because it provides reliable, connection-oriented communication (used by HTTP, HTTPS, gRPC, etc.). UDP is connectionless and often used for DNS, streaming, or gaming traffic.
- **Your case**: Since the Service is exposing port 80 for HTTP traffic, it makes sense to declare `protocol: TCP`. HTTP relies on TCP to ensure ordered, reliable delivery of requests and responses.
- **Effect**: When another pod (like `SimpleApi1`) calls `simpleapi2-svc.simple-apis.svc.cluster.local:80`, Kubernetes routes that traffic using TCP to one of the pods labeled `app=simpleapi2` on their port 80.

So, in short: **`protocol: TCP` tells Kubernetes that this Service should handle traffic over TCP connections, which is the standard for HTTP.**

Would you like me to also break down how Kubernetes decides *which pod* gets the traffic when multiple pods match the selector? That’s where load balancing comes into play.
Great question — TCP and HTTP often get mixed up, but they’re not the same thing. Think of them as **different layers of communication**:

### TCP (Transport Layer)
- **What it is**: A transport protocol that ensures reliable, ordered delivery of data between two endpoints.
- **Role**: Like the postal service making sure every letter arrives in the right order without being lost.
- **Features**:
  - Connection-oriented (handshake before sending data).
  - Guarantees delivery and order.
  - Used by many higher-level protocols (HTTP, HTTPS, FTP, SMTP, etc.).

### HTTP (Application Layer)
- **What it is**: An application-level protocol built on top of TCP.
- **Role**: Defines how web clients (browsers, APIs) and servers exchange requests and responses.
- **Features**:
  - Text-based, human-readable format (GET, POST, headers, etc.).
  - Relies on TCP underneath for reliable transport.
  - Used specifically for web communication.

### Analogy
- **TCP** = the road system that ensures vehicles can travel safely and reliably.
- **HTTP** = the specific type of vehicle (say, a delivery truck) carrying web content along those roads.

### In Your YAML
When you set `protocol: TCP`, you’re telling Kubernetes:  
“Use TCP as the transport mechanism for traffic on port 80.”  

Then, inside that TCP connection, your app (SimpleApi2) speaks **HTTP**. Kubernetes doesn’t care about the application-level protocol — it just routes TCP packets.  

So:  
- **TCP** is the foundation.  
- **HTTP** is the language spoken on top of it.  

Would you like me to also show you how this looks in a **layered diagram** (OSI model style) so you can visualize where TCP and HTTP sit?

#### SimpleApi1 Deployment — Calling SimpleApi2
```yaml
# simpleapi1-deployment.yaml
# SimpleApi1: the "frontend API" that receives external traffic
# and calls SimpleApi2 internally
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1
  namespace: simple-apis
  labels:
    app: simpleapi1
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: simpleapi1
  template:
    metadata:
      labels:
        app: simpleapi1
        tier: frontend
    spec:
      containers:
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v1
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_HTTP_PORTS
          value: "80"
        - name: SIMPLEAPI2_BASE_URL
          # ← Use Kubernetes DNS name — works cross-namespace too
          # Format: http://<service>.<namespace>.svc.cluster.local
          value: "http://simpleapi2-svc.simple-apis.svc.cluster.local"
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

---

### 16.3 — .NET 10 Code: HttpClient Factory Pattern for Service Calls

#### Program.cs — SimpleApi1 Calling SimpleApi2
```csharp
// Program.cs — SimpleApi1
// Uses IHttpClientFactory (recommended over new HttpClient())
// IHttpClientFactory:
//   - Manages HttpClient lifecycle (avoids socket exhaustion)
//   - Supports named clients with preset base addresses
//   - Integrates with Polly for retry/circuit breaker
//   - Built-in connection pooling

var builder = WebApplication.CreateBuilder(args);

// ── Register named HttpClient for SimpleApi2 ──────────────────────
// Named client approach: pre-configured base URL + timeout
builder.Services.AddHttpClient("SimpleApi2", client =>
{
    // Read base URL from environment variable (injected by Kubernetes)
    // Falls back to localhost for local development
    var baseUrl = builder.Configuration["SIMPLEAPI2_BASE_URL"]
                  ?? "http://localhost:5002";
    client.BaseAddress = new Uri(baseUrl);

    // Timeout applies per request
    client.Timeout = TimeSpan.FromSeconds(30);

    // Default headers sent with every request
    client.DefaultRequestHeaders.Add("X-Source-Service", "simpleapi1");
})
// ── Polly: Retry policy ───────────────────────────────────────────
// Retry 3 times with exponential backoff on transient HTTP failures
.AddTransientHttpErrorPolicy(policy =>
    policy.WaitAndRetryAsync(
        retryCount: 3,
        // Exponential backoff: 2s, 4s, 8s
        sleepDurationProvider: attempt => TimeSpan.FromSeconds(Math.Pow(2, attempt)),
        onRetry: (outcome, timespan, attempt, context) =>
        {
            // Log the retry attempt (use ILogger in production)
            Console.WriteLine($"[Retry {attempt}] waiting {timespan} before retrying. " +
                              $"Reason: {outcome.Exception?.Message ?? outcome.Result?.StatusCode.ToString()}");
        }
    )
)
// ── Polly: Circuit Breaker ────────────────────────────────────────
// Open circuit after 5 failures in 30s — stop hammering the failing service
.AddTransientHttpErrorPolicy(policy =>
    policy.CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 5,  // failures before opening
        durationOfBreak: TimeSpan.FromSeconds(30) // how long circuit stays open
    )
);

// ── Register services ─────────────────────────────────────────────
builder.Services.AddScoped<ISimpleApi2Client, SimpleApi2Client>();

var app = builder.Build();

// ── Health endpoint ───────────────────────────────────────────────
app.MapGet("/health", () => Results.Ok(new { status = "healthy", service = "simpleapi1" }));

// ── Endpoint that calls SimpleApi2 ───────────────────────────────
app.MapGet("/combined-data", async (ISimpleApi2Client api2Client) =>
{
    try
    {
        var api2Data = await api2Client.GetDataAsync();
        return Results.Ok(new
        {
            from_api1 = "SimpleApi1 response",
            from_api2 = api2Data,
            timestamp = DateTime.UtcNow
        });
    }
    catch (HttpRequestException ex)
    {
        // Circuit open or all retries exhausted
        return Results.Problem(
            detail: $"SimpleApi2 is unavailable: {ex.Message}",
            statusCode: 503
        );
    }
});

app.Run();
```

#### SimpleApi2Client.cs — Typed Client Wrapper
```csharp
// ISimpleApi2Client.cs
public interface ISimpleApi2Client
{
    Task<SimpleApi2Response?> GetDataAsync(CancellationToken ct = default);
}

// SimpleApi2Client.cs
public class SimpleApi2Client : ISimpleApi2Client
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<SimpleApi2Client> _logger;

    // IHttpClientFactory injects the pre-configured named client
    public SimpleApi2Client(IHttpClientFactory factory, ILogger<SimpleApi2Client> logger)
    {
        // Creates an HttpClient with the "SimpleApi2" configuration
        _httpClient = factory.CreateClient("SimpleApi2");
        _logger = logger;
    }

    public async Task<SimpleApi2Response?> GetDataAsync(CancellationToken ct = default)
    {
        _logger.LogInformation("Calling SimpleApi2 at {BaseAddress}", _httpClient.BaseAddress);

        // GET http://simpleapi2-svc.simple-apis.svc.cluster.local/info
        var response = await _httpClient.GetAsync("/info", ct);

        // Throws HttpRequestException for 4xx/5xx — triggers Polly retry
        response.EnsureSuccessStatusCode();

        return await response.Content.ReadFromJsonAsync<SimpleApi2Response>(ct);
    }
}

// Response model
public record SimpleApi2Response(string Service, string Version, DateTime Timestamp);
```

---

### 16.4 — Communication Patterns Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│              SERVICE-TO-SERVICE COMMUNICATION PATTERNS                 │
│                                                                        │
│  PATTERN 1: Direct HTTP (ClusterIP)                                    │
│  ─────────────────────────────────────────────────                     │
│  [SimpleApi1 Pod] ──HTTP GET──► [simpleapi2-svc ClusterIP]             │
│                                         │                              │
│                              kube-proxy (iptables/IPVS)                │
│                                    ┌────┴────┐                         │
│                                    ▼         ▼                         │
│                             [Pod: api2-a] [Pod: api2-b]                │
│                                                                        │
│  PATTERN 2: Headless Service (StatefulSet pods addressed directly)     │
│  ──────────────────────────────────────────────────────                │
│  [Client] ──DNS──► simpledb-0.simpledb.namespace.svc.cluster.local     │
│                    (resolves directly to pod IP, bypasses ClusterIP)   │
│                                                                        │
│  PATTERN 3: gRPC (HTTP/2 + Protobuf)                                   │
│  ─────────────────────────────────                                     │
│  [SimpleApi1] ──gRPC──► simpleapi2-grpc-svc:50051                     │
│  (requires: service port name must start with "grpc" or "h2c")        │
│                                                                        │
│  PATTERN 4: Async via Azure Service Bus (decoupled)                    │
│  ────────────────────────────────────────────────                      │
│  [SimpleApi1] ──Send Msg──► [Service Bus Queue]                        │
│                                     │                                  │
│                              KEDA ScaledObject                         │
│                                     ▼                                  │
│                             [SimpleApi2 pods scale up]                 │
│                             [SimpleApi2 processes message]             │
└────────────────────────────────────────────────────────────────────────┘
```

---

### 16.5 — Cross-Namespace Communication

```yaml
# NetworkPolicy: Allow SimpleApi1 in namespace "simple-apis"
# to call SimpleApi2 in namespace "backend-apis"
# ─────────────────────────────────────────────────────────
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-simpleapi1-to-api2
  namespace: backend-apis              # Policy applies to pods IN this namespace
spec:
  podSelector:
    matchLabels:
      app: simpleapi2                  # This policy governs ingress TO simpleapi2 pods
  policyTypes:
  - Ingress                           # Controlling inbound connections
  ingress:
  - from:
    - namespaceSelector:              # Allow traffic from this namespace
        matchLabels:
          kubernetes.io/metadata.name: simple-apis
      podSelector:                    # And only from pods with this label
        matchLabels:
          app: simpleapi1
    ports:
    - protocol: TCP
      port: 80                        # Only allow port 80
```

---

### 16.6 — Service Mesh for Advanced Communication (Istio)

```yaml
# VirtualService: Traffic splitting — send 90% to v1, 10% to v2 (canary)
# Use case: gradually roll out SimpleApi2 v2 without risk
# ─────────────────────────────────────────────────────────────────────
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: simpleapi2-vs
  namespace: simple-apis
spec:
  hosts:
  - simpleapi2-svc                    # Intercepts calls to this service
  http:
  - route:
    - destination:
        host: simpleapi2-svc
        subset: v1                    # 90% to stable v1
      weight: 90
    - destination:
        host: simpleapi2-svc
        subset: v2                    # 10% to new v2 (canary)
      weight: 10
    retries:                          # Istio handles retries at mesh level
      attempts: 3
      perTryTimeout: 5s
      retryOn: "5xx,reset,connect-failure"

---
# DestinationRule: defines subsets (v1/v2) by pod label
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: simpleapi2-dr
  namespace: simple-apis
spec:
  host: simpleapi2-svc
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http2MaxRequests: 1000
    outlierDetection:                 # Circuit breaker at mesh level
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
  subsets:
  - name: v1
    labels:
      version: v1                     # Pods with label version=v1
  - name: v2
    labels:
      version: v2                     # Pods with label version=v2
```

---

### 16.7 — Verifying Service-to-Service Connectivity

```bash
# Deploy a temporary debug pod to test connectivity
kubectl run debug-pod --image=curlimages/curl:latest \
  --restart=Never -n simple-apis \
  --command -- sleep 3600

# Test that SimpleApi1 can reach SimpleApi2
kubectl exec debug-pod -n simple-apis -- \
  curl -s http://simpleapi2-svc.simple-apis.svc.cluster.local/health

# Expected Output:
# {"status":"healthy","service":"simpleapi2"}

# Test cross-namespace
kubectl exec debug-pod -n simple-apis -- \
  curl -s http://simpleapi2-svc.backend-apis.svc.cluster.local/health

# Test with verbose headers (to verify mTLS, load balancing)
kubectl exec debug-pod -n simple-apis -- \
  curl -sv http://simpleapi2-svc/info 2>&1 | head -30

# Clean up debug pod
kubectl delete pod debug-pod -n simple-apis
```

---

## PART 17: Volume Types — Complete Deep Dive

> **Mental Model:** Volumes are like USB drives you plug into your container. Some are temporary (emptyDir = RAM disk that disappears when pod dies), some are persistent (Azure Disk = external hard drive that survives pod restarts), and some mount configuration (ConfigMap volume = read-only config file cabinet).

---

### 17.1 — Volume Types Overview

```
┌────────────────────────────────────────────────────────────────────────┐
│                    KUBERNETES VOLUME TAXONOMY                          │
│                                                                        │
│  EPHEMERAL (live and die with the Pod)                                 │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐              │
│  │  emptyDir   │  │  configMap   │  │     secret      │              │
│  │  (temp dir) │  │  (config     │  │  (secret files) │              │
│  │             │  │   files)     │  │                 │              │
│  └─────────────┘  └──────────────┘  └─────────────────┘              │
│  ┌─────────────────┐  ┌───────────────────┐                           │
│  │    projected    │  │    downwardAPI     │                           │
│  │ (combine multi  │  │ (expose pod/node   │                           │
│  │  volume sources)│  │  metadata as files)│                           │
│  └─────────────────┘  └───────────────────┘                           │
│                                                                        │
│  NODE-LOCAL (tied to a specific node)                                  │
│  ┌─────────────┐  ┌──────────────────────┐                            │
│  │  hostPath   │  │  local (StorageClass) │                            │
│  │ (node dir)  │  │  (node local disk)    │                            │
│  └─────────────┘  └──────────────────────┘                            │
│                                                                        │
│  PERSISTENT (survive pod/node restarts — via PVC)                      │
│  ┌───────────────────────────────────────────────────────────────────┐│
│  │  Azure Disk (CSI)    │  Azure Files (CSI)  │  Azure NetApp Files  ││
│  │  ReadWriteOnce       │  ReadWriteMany       │  ReadWriteMany       ││
│  │  (block storage)     │  (SMB/NFS share)     │  (enterprise NFS)    ││
│  └───────────────────────────────────────────────────────────────────┘│
└────────────────────────────────────────────────────────────────────────┘
```

---

### 17.2 — emptyDir

**What it is:** A temporary directory created when a pod starts, shared between all containers in the pod. Deleted when pod is removed.

**Use cases:** Temporary scratch space, sharing files between containers in a pod (sidecar pattern), caching.

```yaml
# emptyDir example: web server + sidecar log processor sharing a volume
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-with-sidecar
  namespace: simple-apis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api-with-sidecar
  template:
    metadata:
      labels:
        app: api-with-sidecar
    spec:
      volumes:
      - name: shared-logs              # Volume definition at pod level
        emptyDir: {}                   # {} = use node disk; {medium: Memory} = RAM-backed (tmpfs)

      - name: fast-cache               # RAM-backed emptyDir — fast but limited
        emptyDir:
          medium: Memory               # Stored in RAM — survives container restarts but NOT pod restarts
          sizeLimit: 256Mi             # Cap so one pod can't exhaust all node RAM

      containers:
      # Container 1: The main API — writes logs to shared volume
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v1
        volumeMounts:
        - name: shared-logs
          mountPath: /app/logs         # API writes logs here
        - name: fast-cache
          mountPath: /app/cache        # Cache mounted in RAM

      # Container 2: Log forwarder sidecar — reads logs from shared volume
      - name: log-forwarder
        image: fluent/fluent-bit:latest
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log/app      # Reads logs written by container 1
          readOnly: true               # Sidecar only reads; main app writes
```

---

### 17.3 — hostPath

**What it is:** Mounts a directory from the worker node's filesystem into the pod.

**Use cases:** DaemonSets reading node logs (`/var/log`), node-level monitoring agents, Docker socket access.

**Warning:** Avoid for application workloads — creates node affinity and security risks.

```yaml
# hostPath example: DaemonSet log collector reading node logs
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-log-collector
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: node-log-collector
  template:
    metadata:
      labels:
        app: node-log-collector
    spec:
      volumes:
      - name: node-logs
        hostPath:
          path: /var/log/containers    # Actual path on the worker node
          type: Directory              # Must exist; options: Directory, File,
                                       # DirectoryOrCreate, FileOrCreate,
                                       # Socket, CharDevice, BlockDevice

      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock   # For tools that need container runtime access
          type: Socket

      containers:
      - name: log-collector
        image: fluent/fluent-bit:latest
        volumeMounts:
        - name: node-logs
          mountPath: /host/var/log/containers
          readOnly: true               # Read-only — never write to node filesystem
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule             # Allow scheduling on control plane nodes too
```

---

### 17.4 — configMap Volume Mount

**What it is:** Mounts ConfigMap keys as files in the container filesystem.

**Use cases:** App configuration files (appsettings.json), Nginx config, SSL certs.

```yaml
# Step 1: Create ConfigMap with appsettings content
apiVersion: v1
kind: ConfigMap
metadata:
  name: simpleapi1-config
  namespace: simple-apis
data:
  # Each key becomes a file in the mounted directory
  appsettings.Production.json: |
    {
      "Logging": {
        "LogLevel": {
          "Default": "Information",
          "Microsoft.AspNetCore": "Warning"
        }
      },
      "ConnectionStrings": {
        "Redis": "myredis.redis.cache.windows.net:6380,ssl=true"
      },
      "FeatureFlags": {
        "EnableNewCheckout": true
      }
    }
  nginx.conf: |
    server {
        listen 80;
        location /health { return 200 'OK'; }
        location / { proxy_pass http://localhost:5000; }
    }

---
# Step 2: Mount ConfigMap as volume in Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1
  namespace: simple-apis
spec:
  template:
    spec:
      volumes:
      - name: app-config
        configMap:
          name: simpleapi1-config      # Reference the ConfigMap
          # Optional: only mount specific keys
          items:
          - key: appsettings.Production.json   # ConfigMap key
            path: appsettings.Production.json  # Filename inside mountPath
            mode: 0444                         # File permissions (octal): read-only
          - key: nginx.conf
            path: nginx.conf
            mode: 0444

      containers:
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v1
        volumeMounts:
        - name: app-config
          mountPath: /app/config       # ConfigMap keys become files here
          readOnly: true               # Best practice: config should be read-only
        # File will be at: /app/config/appsettings.Production.json
        # .NET reads this automatically if ASPNETCORE_ENVIRONMENT=Production
```

---

### 17.5 — Secret Volume Mount

**What it is:** Same as ConfigMap volume but for Secrets. Values are base64-decoded at mount time.

```yaml
# Mount TLS certificate from Secret as files
apiVersion: v1
kind: Secret
metadata:
  name: simpleapi1-tls
  namespace: simple-apis
type: kubernetes.io/tls               # TLS secret type
data:
  tls.crt: LS0tLS1CRUdJTi...         # Base64-encoded certificate
  tls.key: LS0tLS1CRUdJTi...         # Base64-encoded private key

---
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      volumes:
      - name: tls-certs
        secret:
          secretName: simpleapi1-tls   # Reference Secret
          defaultMode: 0400            # Very restrictive: owner read-only
                                       # Private key should not be world-readable

      containers:
      - name: simpleapi1
        volumeMounts:
        - name: tls-certs
          mountPath: /etc/ssl/certs    # Files: /etc/ssl/certs/tls.crt and tls.key
          readOnly: true
```

---

### 17.6 — Projected Volumes (Combining Multiple Sources)

**What it is:** Merges multiple volume sources (ConfigMap, Secret, ServiceAccount token, downwardAPI) into a single directory.

```yaml
# Combine config + secret + pod info into /etc/pod-config
spec:
  volumes:
  - name: combined-config
    projected:
      sources:
      - configMap:
          name: simpleapi1-config      # /etc/pod-config/appsettings.Production.json
      - secret:
          name: simpleapi1-tls         # /etc/pod-config/tls.crt, tls.key
      - serviceAccountToken:           # Automatic SA token (OIDC) for workload identity
          path: token
          audience: api://AzureADTokenExchange   # Azure Workload Identity audience
          expirationSeconds: 3600      # Token refreshed before expiry
      - downwardAPI:                   # Expose pod metadata as files
          items:
          - path: "pod-name"
            fieldRef:
              fieldPath: metadata.name          # /etc/pod-config/pod-name = pod name
          - path: "pod-namespace"
            fieldRef:
              fieldPath: metadata.namespace
          - path: "cpu-limit"
            resourceFieldRef:
              containerName: simpleapi1
              resource: limits.cpu     # /etc/pod-config/cpu-limit = "500m"
  containers:
  - name: simpleapi1
    volumeMounts:
    - name: combined-config
      mountPath: /etc/pod-config
      readOnly: true
```

---

### 17.7 — Azure Disk (PersistentVolume — ReadWriteOnce)

**What it is:** Azure Managed Disk attached to one node. Best for databases, stateful apps needing high IOPS.

**Limitation:** `ReadWriteOnce` — only ONE pod/node can mount at a time (use Azure Files for shared access).

```yaml
# Dynamic provisioning with StorageClass (recommended approach)

# Step 1: PersistentVolumeClaim — request storage
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: simpleapi-data-pvc
  namespace: simple-apis
spec:
  accessModes:
  - ReadWriteOnce                      # Only one pod can mount (Azure Disk limitation)
  storageClassName: managed-csi        # AKS built-in StorageClass for Azure Disk CSI
                                       # Other options: managed-premium-csi (SSD),
                                       #               azuredisk-csi-zrs (zone-redundant)
  resources:
    requests:
      storage: 32Gi                    # Requested disk size — Azure rounds to next tier

---
# Step 2: Use PVC in a Pod
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-with-disk
  namespace: simple-apis
spec:
  replicas: 1                          # MUST be 1 for ReadWriteOnce (only one pod can attach)
  selector:
    matchLabels:
      app: api-with-disk
  template:
    metadata:
      labels:
        app: api-with-disk
    spec:
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: simpleapi-data-pvc  # Reference PVC by name
          readOnly: false

      containers:
      - name: app
        image: acrdemo.azurecr.io/simpleapi1:v1
        volumeMounts:
        - name: data-volume
          mountPath: /app/data           # Persistent data stored here
```

```bash
# Check PVC status
kubectl get pvc -n simple-apis

# Sample Output:
# NAME                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# simpleapi-data-pvc     Bound    pvc-abc123de-1234-5678-abcd-ef0123456789   32Gi       RWO            managed-csi    5m

# STATUS meanings:
# Pending → PVC created but no PV bound yet (Azure Disk not provisioned)
# Bound   → PV created and attached; pod can mount
# Lost    → Bound PV was deleted (data may be lost)

# Describe PVC for details (provisioning errors show here)
kubectl describe pvc simpleapi-data-pvc -n simple-apis
```

---

### 17.8 — Azure Files (ReadWriteMany — Shared Storage)

**What it is:** Azure Files SMB/NFS share — multiple pods on multiple nodes can read/write simultaneously.

**Use cases:** Shared config, upload directories, legacy apps requiring shared filesystem.

```yaml
# StorageClass for Azure Files with NFS protocol (better than SMB for Linux)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi-nfs              # Custom StorageClass name
provisioner: file.csi.azure.com        # Azure Files CSI driver
parameters:
  skuName: Standard_LRS                # Storage tier: Standard_LRS, Premium_LRS
  protocol: nfs                        # nfs (Linux) or smb (Windows)
  networkEndpointType: privateEndpoint # Use private endpoint for security
reclaimPolicy: Retain                  # Retain: keep Azure Files share when PVC deleted
                                       # Delete: delete share (DEFAULT — be careful!)
volumeBindingMode: Immediate           # Provision Azure Files share immediately
allowVolumeExpansion: true             # Allow PVC size increase without downtime

---
# PVC using Azure Files
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-uploads-pvc
  namespace: simple-apis
spec:
  accessModes:
  - ReadWriteMany                      # Multiple pods on multiple nodes can mount
  storageClassName: azurefile-csi-nfs
  resources:
    requests:
      storage: 100Gi

---
# Use PVC in Deployment — all replicas share the same files!
apiVersion: apps/v1
kind: Deployment
metadata:
  name: upload-service
  namespace: simple-apis
spec:
  replicas: 3                          # All 3 pods share /app/uploads
  selector:
    matchLabels:
      app: upload-service
  template:
    metadata:
      labels:
        app: upload-service
    spec:
      volumes:
      - name: shared-uploads
        persistentVolumeClaim:
          claimName: shared-uploads-pvc
      containers:
      - name: app
        image: acrdemo.azurecr.io/simpleapi1:v1
        volumeMounts:
        - name: shared-uploads
          mountPath: /app/uploads      # All pods see same files via Azure Files NFS
```

---

### 17.9 — StatefulSet with VolumeClaimTemplates

**What it is:** Each pod in a StatefulSet gets its own dedicated PVC automatically. Named `<template-name>-<pod-name>`.

```yaml
# StatefulSet: each replica gets its own Azure Disk
# Pod simpledb-0 → PVC data-simpledb-0
# Pod simpledb-1 → PVC data-simpledb-1
# Pod simpledb-2 → PVC data-simpledb-2
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: simpledb
  namespace: simple-apis
spec:
  serviceName: simpledb-headless       # Must match headless service name
  replicas: 3
  selector:
    matchLabels:
      app: simpledb
  template:
    metadata:
      labels:
        app: simpledb
    spec:
      containers:
      - name: db
        image: postgres:16
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
        volumeMounts:
        - name: data                   # References the volumeClaimTemplate name
          mountPath: /var/lib/postgresql/data

  # VolumeClaimTemplates: creates a PVC for EACH pod automatically
  volumeClaimTemplates:
  - metadata:
      name: data                       # This becomes the volume name in volumeMounts
    spec:
      accessModes:
      - ReadWriteOnce                  # Each pod gets its own dedicated disk
      storageClassName: managed-premium-csi  # SSD for database performance
      resources:
        requests:
          storage: 50Gi               # Each pod gets 50Gi dedicated disk
```

---

### 17.10 — Volume Snapshots

```bash
# Install VolumeSnapshot CRDs (already installed in AKS 1.19+)
kubectl get volumesnapshotclasses

# Sample Output:
# NAME                    DRIVER                DELETIONPOLICY   AGE
# csi-azuredisk-vsc       disk.csi.azure.com    Delete           5d
# csi-azurefile-vsc       file.csi.azure.com    Delete           5d
```

```yaml
# Create a point-in-time snapshot of a PVC
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: simpleapi-data-snapshot-20260226
  namespace: simple-apis
spec:
  volumeSnapshotClassName: csi-azuredisk-vsc  # Use Azure Disk snapshot driver
  source:
    persistentVolumeClaimName: simpleapi-data-pvc  # Which PVC to snapshot

---
# Restore: Create new PVC from snapshot
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: simpleapi-data-restored
  namespace: simple-apis
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: managed-csi
  resources:
    requests:
      storage: 32Gi                    # Must be >= snapshot size
  dataSource:                          # Restore from snapshot
    name: simpleapi-data-snapshot-20260226
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
```

---

## PART 18: 10 Real-World AKS Challenges & Solutions

> These are the issues engineers actually hit in production. Each challenge includes: root cause diagnosis, fix, and prevention.

---

### Challenge 1: CrashLoopBackOff — Pod Keeps Restarting

**Symptom:**
```bash
kubectl get pods -n simple-apis
# NAME                          READY   STATUS             RESTARTS   AGE
# simpleapi1-7d4b8c9f6-2xkpq   0/1     CrashLoopBackOff   8          15m
```

**Diagnosis:**
```bash
# Step 1: Check the logs from the CURRENT crashed container
kubectl logs simpleapi1-7d4b8c9f6-2xkpq -n simple-apis

# Step 2: Check logs from the PREVIOUS container (before restart)
kubectl logs simpleapi1-7d4b8c9f6-2xkpq -n simple-apis --previous

# Sample Output (DB connection failure):
# Unhandled exception. Microsoft.Data.SqlClient.SqlException:
#   Cannot open server 'myserver' requested by the login. Client with IP address '10.244.1.15' is not allowed to access the server.

# Step 3: Describe pod — check Events and Exit Codes
kubectl describe pod simpleapi1-7d4b8c9f6-2xkpq -n simple-apis

# Sample Events output:
# Warning  BackOff  2m  kubelet  Back-off restarting failed container simpleapi1
# Exit Code: 1  (app crashed) or  139 (segfault) or  137 (OOMKilled)
```

**Common Causes & Fixes:**

| Exit Code | Cause | Fix |
|-----------|-------|-----|
| 1 | App threw unhandled exception | Fix the code; check env vars/secrets |
| 137 | OOMKilled (out of memory) | Increase memory limit |
| 139 | Segfault | Usually native code bug |
| 143 | SIGTERM not handled | Implement graceful shutdown |

```yaml
# Fix 1: Missing environment variable causing null reference
# Add required env vars to deployment:
env:
- name: ConnectionStrings__DefaultConnection
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: connection-string
      optional: false              # If secret missing, pod won't even start (better than crash)

# Fix 2: Startup takes longer than liveness probe allows — increase initialDelaySeconds
livenessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 60         # Was 15 — increase for slow-starting apps
  periodSeconds: 20
  failureThreshold: 3             # Allow 3 failures before restart

# Fix 3: Use startupProbe for slow-starting containers (prevents liveness killing them)
startupProbe:
  httpGet:
    path: /health
    port: 80
  failureThreshold: 30            # 30 × 10s = 300s (5 min) for app to start
  periodSeconds: 10
```

---

### Challenge 2: OOMKilled — Pod Running Out of Memory

**Symptom:**
```bash
kubectl describe pod simpleapi1-7d4b8c9f6-2xkpq -n simple-apis | grep -A5 "OOM"

# Output:
# Last State: Terminated
#   Reason: OOMKilled
#   Exit Code: 137
#   Started: Mon, 24 Feb 2026 10:15:00 +0000
#   Finished: Mon, 24 Feb 2026 10:16:30 +0000
```

**Diagnosis:**
```bash
# Check current memory usage vs limits
kubectl top pod -n simple-apis

# Sample Output:
# NAME                          CPU(cores)   MEMORY(bytes)
# simpleapi1-7d4b8c9f6-2xkpq   450m         498Mi    ← approaching 512Mi limit!

# Check node-level memory pressure
kubectl describe node aks-nodepool1-12345678-vmss000000 | grep -A5 "MemoryPressure"
```

**Fix:**
```yaml
# Option A: Increase memory limit (if app legitimately needs more)
resources:
  requests:
    memory: "256Mi"
  limits:
    memory: "1Gi"            # Was 512Mi — doubled

# Option B: Enable GC tuning for .NET (reduce memory footprint)
env:
- name: DOTNET_GCConserveMemory    # 0-9: higher = more aggressive GC
  value: "7"
- name: DOTNET_GCHeapHardLimit     # Hard cap on GC heap in bytes
  value: "419430400"               # 400MB
- name: DOTNET_GCHeapHardLimitPercent
  value: "75"                      # GC heap = 75% of container memory limit

# Option C: Use VPA to right-size automatically
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: simpleapi1-vpa
  namespace: simple-apis
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: simpleapi1
  updatePolicy:
    updateMode: "Off"          # "Off" = recommendations only, no auto-change
                               # "Initial" = set on new pods only
                               # "Auto" = live resize (restarts pods)
  resourcePolicy:
    containerPolicies:
    - containerName: simpleapi1
      minAllowed:
        memory: 128Mi
      maxAllowed:
        memory: 2Gi            # VPA won't recommend more than this
```

---

### Challenge 3: Pods Stuck in Pending — Not Scheduling

**Symptom:**
```bash
kubectl get pods -n simple-apis
# NAME                          READY   STATUS    RESTARTS   AGE
# simpleapi1-7d4b8c9f6-zxpqr   0/1     Pending   0          10m
```

**Diagnosis:**
```bash
kubectl describe pod simpleapi1-7d4b8c9f6-zxpqr -n simple-apis

# Common Event messages that reveal the cause:
# "0/3 nodes are available: 3 Insufficient cpu"
#   → Pod requests more CPU than any node has free
#
# "0/3 nodes are available: 3 node(s) had untolerated taint {CriticalAddonsOnly: true}"
#   → Pod needs tolerations for system node pool taints
#
# "0/3 nodes are available: 3 node(s) didn't match node affinity/selector"
#   → nodeSelector or affinity rules don't match any nodes
#
# "persistentvolumeclaim 'my-pvc' not found"
#   → PVC doesn't exist or is in wrong namespace
```

**Fixes:**
```bash
# Fix 1: Not enough CPU/memory — scale out node pool
az aks nodepool scale \
  --resource-group myRG \
  --cluster-name myAKS \
  --name nodepool1 \
  --node-count 5          # Add more nodes

# Fix 2: Enable Cluster Autoscaler (automatic scale-out)
az aks nodepool update \
  --resource-group myRG \
  --cluster-name myAKS \
  --name nodepool1 \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 10

# Fix 3: Wrong node selector — check what labels nodes have
kubectl get nodes --show-labels
# Then fix the nodeSelector in your Deployment to match actual labels
```

```yaml
# Fix 4: Taint on system node pool — add toleration to your pod
tolerations:
- key: "CriticalAddonsOnly"
  operator: "Exists"
  effect: "NoSchedule"

# Fix 5: Pod requests too high — reduce requests to realistic values
resources:
  requests:
    cpu: "100m"           # Was 4000m (4 CPUs!) — reduce to what app actually needs
    memory: "128Mi"
```

---

### Challenge 4: ImagePullBackOff — Cannot Pull Container Image

**Symptom:**
```bash
kubectl get pods -n simple-apis
# NAME                          READY   STATUS             RESTARTS
# simpleapi1-xxx                0/1     ImagePullBackOff   0

kubectl describe pod simpleapi1-xxx -n simple-apis | grep -A5 "Failed"
# Failed to pull image "acrdemo.azurecr.io/simpleapi1:v99":
#   rpc error: code = Unknown desc = failed to pull and unpack image:
#   unauthorized: authentication required
```

**Root Causes & Fixes:**
```bash
# Cause 1: ACR not attached to AKS cluster
# Fix: Attach ACR to AKS (grants AcrPull role to kubelet identity)
az aks update \
  --resource-group myRG \
  --name myAKS \
  --attach-acr myACRName

# Verify attachment
az aks check-acr \
  --resource-group myRG \
  --name myAKS \
  --acr myACRName
# Output: ✓ Your cluster can pull images from myACRName.azurecr.io

# Cause 2: Image tag doesn't exist
# Fix: Check available tags in ACR
az acr repository show-tags \
  --name myACRName \
  --repository simpleapi1 \
  --output table
# Output:
# Result
# ────────
# v1
# v2
# latest

# Cause 3: Wrong image name / typo
kubectl get deployment simpleapi1 -n simple-apis -o jsonpath='{.spec.template.spec.containers[0].image}'
# Output: acrdemo.azurecr.io/simpleapi1:v99   ← v99 doesn't exist, should be v1
```

```yaml
# Cause 4: Private registry (non-ACR) — need imagePullSecret
# Step 1: Create docker-registry secret
# kubectl create secret docker-registry acr-secret \
#   --docker-server=myacr.azurecr.io \
#   --docker-username=myACRUser \
#   --docker-password=myACRPassword \
#   --namespace simple-apis

# Step 2: Reference in Pod spec
spec:
  imagePullSecrets:
  - name: acr-secret               # Reference the Secret
  containers:
  - name: simpleapi1
    image: myacr.azurecr.io/simpleapi1:v1
```

---

### Challenge 5: Service Not Reachable — 502/503 Errors

**Symptom:** Ingress returns 502 Bad Gateway or curl to service times out.

**Diagnosis Flow:**
```bash
# Step 1: Check if pods are Running AND Ready
kubectl get pods -n simple-apis -l app=simpleapi1
# READY column must show 1/1 (not 0/1)
# If 0/1 — readiness probe is failing

# Step 2: Check Service endpoints (are pods registered?)
kubectl get endpoints simpleapi1-svc -n simple-apis
# If ENDPOINTS column shows "<none>" — no pods match service selector!

# Step 3: Verify service selector matches pod labels
kubectl get service simpleapi1-svc -n simple-apis -o yaml | grep selector -A5
# selector:
#   app: simpleapi1
kubectl get pods -n simple-apis --show-labels | grep simpleapi1
# If labels don't match selector → pods never get registered as endpoints

# Step 4: Port-forward directly to test the pod (bypass Service)
kubectl port-forward pod/simpleapi1-7d4b8c9f6-2xkpq 8080:80 -n simple-apis
curl http://localhost:8080/health
# If this works but Service doesn't → networking issue between Service and pods

# Step 5: Test via ClusterIP from inside cluster
kubectl run debug --image=curlimages/curl --restart=Never -n simple-apis -- \
  curl -sv http://simpleapi1-svc/health
kubectl logs debug -n simple-apis
kubectl delete pod debug -n simple-apis
```

```yaml
# Fix: Readiness probe too strict — pod is healthy but probe fails
readinessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 10      # Was 0 — give .NET app time to start up
  periodSeconds: 5
  successThreshold: 1          # How many successes needed to become Ready
  failureThreshold: 3          # Fail 3 times before removing from endpoints
  timeoutSeconds: 3            # Request timeout per probe
```

---

### Challenge 6: Rolling Update Causes Downtime

**Symptom:** During `kubectl rollout`, users experience 502 errors for 5-10 seconds.

**Root Cause:** New pods start receiving traffic before they're ready, OR old pods are killed before connections drain.

**Fix:**
```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0          # Never kill old pod until new pod is Ready
                                 # (0 = zero-downtime; default is 25%)
      maxSurge: 1                # Allow 1 extra pod during rollout

  template:
    spec:
      # Graceful shutdown: wait for in-flight requests to complete
      terminationGracePeriodSeconds: 60   # K8s waits 60s for SIGTERM handler
      containers:
      - name: simpleapi1
        # Handle SIGTERM gracefully in .NET:
        # var cts = new CancellationTokenSource();
        # app.Lifetime.ApplicationStopping.Register(() => cts.Cancel());
        # await app.RunAsync(cts.Token);
        lifecycle:
          preStop:
            exec:
              # Sleep 15s before app shutdown begins
              # Allows load balancer to stop routing to this pod
              # (load balancer deregistration takes ~5-10 seconds)
              command: ["/bin/sh", "-c", "sleep 15"]

      # Pod Disruption Budget: never have fewer than 2 pods during voluntary disruption
# (prevents ALL pods being killed simultaneously during node drain)
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: simpleapi1-pdb
  namespace: simple-apis
spec:
  minAvailable: 2                # Always keep at least 2 pods running
  # OR: maxUnavailable: 1       # Never allow more than 1 pod to be unavailable
  selector:
    matchLabels:
      app: simpleapi1
```

---

### Challenge 7: DNS Resolution Failures in Pods

**Symptom:**
```bash
kubectl exec simpleapi1-xxx -n simple-apis -- \
  curl http://simpleapi2-svc/health
# curl: (6) Could not resolve host: simpleapi2-svc
```

**Diagnosis:**
```bash
# Test DNS directly
kubectl exec simpleapi1-xxx -n simple-apis -- \
  nslookup simpleapi2-svc.simple-apis.svc.cluster.local

# If fails: check CoreDNS pods
kubectl get pods -n kube-system -l k8s-app=kube-dns
# All CoreDNS pods must be Running

# Check CoreDNS logs for errors
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50

# Common CoreDNS log errors:
# [ERROR] plugin/errors: 2 SERVFAIL  → upstream DNS failing
# [WARNING] No resolv.conf file found → node DNS misconfiguration
```

```yaml
# Fix 1: Custom DNS policy for pods that need external DNS
spec:
  dnsPolicy: "None"              # Override all defaults
  dnsConfig:
    nameservers:
    - 10.0.0.10                  # CoreDNS ClusterIP (get with: kubectl get svc -n kube-system kube-dns)
    searches:
    - simple-apis.svc.cluster.local
    - svc.cluster.local
    - cluster.local
    options:
    - name: ndots
      value: "5"

# Fix 2: Increase CoreDNS replicas if DNS queries are timing out under load
kubectl scale deployment coredns --replicas=3 -n kube-system
```

---

### Challenge 8: Horizontal Pod Autoscaler Not Scaling

**Symptom:**
```bash
kubectl get hpa -n simple-apis
# NAME            REFERENCE              TARGETS         MINPODS   MAXPODS   REPLICAS
# simpleapi1-hpa  Deployment/simpleapi1  <unknown>/60%   2         10        2
# ↑ "unknown" target means HPA can't read CPU metrics
```

**Diagnosis:**
```bash
kubectl describe hpa simpleapi1-hpa -n simple-apis

# Common warning messages:
# "unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API:
#  the server could not find the requested resource (get pods.metrics.k8s.io)"
#  → metrics-server not installed

# "missing request for cpu"
#  → Container has no CPU request defined — HPA needs requests to calculate %

# Verify metrics-server is running
kubectl get deployment metrics-server -n kube-system
kubectl top pods -n simple-apis   # Should work if metrics-server is up
```

```bash
# Fix 1: Install metrics-server (AKS usually has it, but verify)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Fix 2: Ensure all containers have CPU requests defined
# (HPA calculates "current CPU %" as: actual / requested — needs requested to be set)
```

```yaml
# Fix 3: Use KEDA instead of HPA for Azure-native metrics (Service Bus, Event Hubs)
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: simpleapi1-scaledobject
  namespace: simple-apis
spec:
  scaleTargetRef:
    name: simpleapi1
  minReplicaCount: 2
  maxReplicaCount: 20
  cooldownPeriod: 300
  triggers:
  - type: azure-servicebus
    metadata:
      queueName: order-queue
      namespace: myservicebus
      messageCount: "10"         # Scale when > 10 messages per pod
    authenticationRef:
      name: keda-azure-servicebus-auth
```

---

### Challenge 9: Persistent Volume Not Mounting (Azure Disk)

**Symptom:**
```bash
kubectl describe pod simpleapi1-xxx -n simple-apis | grep -A10 "Events"
# Warning  FailedAttachVolume  2m  attachdetach-controller
#   AttachVolume.Attach failed for volume "pvc-abc123":
#   Attach timeout for volume /subscriptions/.../disks/pvc-abc123

# Or:
# Warning  FailedMount  90s  kubelet
#   Unable to attach or mount volumes: unmounted volumes=[data]:
#   timed out waiting for the condition
```

**Root Causes & Fixes:**
```bash
# Cause 1: Azure Disk stuck on old node (ReadWriteOnce can only attach to 1 node)
# If previous pod was on node A and new pod scheduled on node B,
# disk must detach from A before attaching to B — can take up to 5 minutes

# Check which node the disk is attached to
az disk show \
  --ids /subscriptions/.../disks/pvc-abc123 \
  --query "managedBy" -o tsv
# Output: .../virtualMachines/aks-nodepool1-xxx-vmss_0   ← still on old node

# Wait for detach or manually force detach via Azure CLI
az disk update \
  --ids /subscriptions/.../disks/pvc-abc123 \
  --disk-state Unattached

# Cause 2: Zone mismatch — disk in zone 1 but pod scheduled to zone 2
# Fix: Use zone-redundant disk (zrs) or add node affinity to keep pod in same zone
```

```yaml
# Fix: Add node affinity to keep pod in same zone as disk
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
            - eastus-1               # Match zone where disk lives

# Or: Use zone-redundant StorageClass (no zone pinning needed)
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-csi-zrs
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_ZRS              # Zone-redundant SSD — attaches from any zone
reclaimPolicy: Retain
allowVolumeExpansion: true
```

---

### Challenge 10: Workload Identity Not Working — 401 Unauthorized

**Symptom:** .NET app in pod gets `AuthenticationFailedException` when accessing Key Vault or Storage.

```bash
kubectl logs simpleapi1-xxx -n simple-apis | grep -i "auth"
# Azure.Identity.AuthenticationFailedException:
#   DefaultAzureCredential failed to retrieve a token from the included credentials.
```

**Diagnosis Checklist:**
```bash
# 1. Verify OIDC issuer is enabled on cluster
az aks show -g myRG -n myAKS --query "oidcIssuerProfile.issuerUrl" -o tsv
# Must return a URL like: https://eastus.oic.prod-aks.azure.com/tenant-id/cluster-id/

# 2. Verify Workload Identity add-on is enabled
az aks show -g myRG -n myAKS --query "addonProfiles.azureKeyvaultSecretsProvider" -o json
# AND
az aks show -g myRG -n myAKS --query "securityProfile.workloadIdentity.enabled" -o tsv
# Must return: true

# 3. Check ServiceAccount has correct annotation
kubectl get serviceaccount simpleapi1-sa -n simple-apis -o yaml | grep annotations -A5
# Must have:
# annotations:
#   azure.workload.identity/client-id: <managed-identity-client-id>

# 4. Check pod has workload identity label
kubectl get pod simpleapi1-xxx -n simple-apis -o yaml | grep "azure.workload.identity/use"
# Must have label: azure.workload.identity/use: "true"

# 5. Check federated credential exists on Managed Identity
az identity federated-credential list \
  --identity-name simpleapi1-identity \
  --resource-group myRG \
  --query "[].{Subject:subject, Issuer:issuer}" -o table
# Subject must be: system:serviceaccount:simple-apis:simpleapi1-sa
```

```bash
# Full fix script — recreate the workload identity chain
SUBSCRIPTION=$(az account show --query id -o tsv)
TENANT=$(az account show --query tenantId -o tsv)
RG="myRG"
CLUSTER="myAKS"
NS="simple-apis"
SA_NAME="simpleapi1-sa"
MI_NAME="simpleapi1-identity"

# Get OIDC issuer URL
OIDC_ISSUER=$(az aks show -g $RG -n $CLUSTER --query "oidcIssuerProfile.issuerUrl" -o tsv)

# Create Managed Identity
az identity create -g $RG -n $MI_NAME
MI_CLIENT_ID=$(az identity show -g $RG -n $MI_NAME --query clientId -o tsv)

# Create federated credential
az identity federated-credential create \
  --identity-name $MI_NAME \
  --resource-group $RG \
  --name "aks-${NS}-${SA_NAME}" \
  --issuer "$OIDC_ISSUER" \
  --subject "system:serviceaccount:${NS}:${SA_NAME}" \
  --audience "api://AzureADTokenExchange"

# Grant MI access to Key Vault
KV_ID=$(az keyvault show -n myKeyVault -g $RG --query id -o tsv)
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee-object-id $(az identity show -g $RG -n $MI_NAME --query principalId -o tsv) \
  --scope $KV_ID
```

```yaml
# Kubernetes ServiceAccount with correct annotation
apiVersion: v1
kind: ServiceAccount
metadata:
  name: simpleapi1-sa
  namespace: simple-apis
  annotations:
    azure.workload.identity/client-id: "<MI_CLIENT_ID>"   # From az identity show

---
# Pod/Deployment with workload identity label
spec:
  serviceAccountName: simpleapi1-sa  # Use the annotated SA
  template:
    metadata:
      labels:
        azure.workload.identity/use: "true"  # This label MUST be present
```

```csharp
// .NET: DefaultAzureCredential automatically uses Workload Identity token
// when running in Kubernetes pod with proper setup
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var credential = new DefaultAzureCredential();
// In pod: uses AZURE_CLIENT_ID + projected OIDC token at
// /var/run/secrets/azure/tokens/azure-identity-token

var kvClient = new SecretClient(
    new Uri("https://myKeyVault.vault.azure.net/"),
    credential);

var secret = await kvClient.GetSecretAsync("my-connection-string");
Console.WriteLine(secret.Value.Value);
```

---

## PART 19: Interview Q&A for .NET Developers — Expert Level

> Answers are structured for interview delivery: 1-sentence summary → explanation → analogy → code/example → trade-offs.

---

### 19.1 — Conceptual Questions

---

**Q1: What is Kubernetes and why do we use AKS over self-managed Kubernetes?**

**Answer:**
Kubernetes is a container orchestration platform that automates deployment, scaling, and management of containerized applications using a desired-state reconciliation model.

We use **AKS** because Azure manages the control plane (API server, etcd, scheduler) at no extra cost, handles OS patches and Kubernetes version upgrades, integrates natively with Azure AD, Azure Monitor, and ACR, and provides SLAs (99.95% for Standard tier). Self-managing Kubernetes means you're responsible for etcd backups, control plane HA, upgrades — significant operational overhead.

**Mental Model:** AKS is like hiring a building management company (Azure) to handle the electricity, plumbing, and structural maintenance, while you only worry about what's inside your apartment (your containers).

---

**Q2: Explain the Kubernetes desired-state reconciliation model.**

**Answer:**
Kubernetes never "runs commands" — it constantly compares **actual state** (what's running) against **desired state** (what you declared in YAML) and makes changes to close the gap. This is called the reconciliation loop.

Every controller (Deployment controller, ReplicaSet controller, HPA controller) runs an infinite loop:
1. Watch API server for changes to its resource type
2. Compare actual state vs desired state
3. If they differ → take action (create pod, delete pod, scale)
4. Update status in etcd

**Mental Model:** Like a thermostat. You set 72°F (desired). The thermostat reads current temperature (actual). If actual < desired → turns on heat. If actual > desired → turns on AC. It never stops checking.

**Why this matters in interviews:** This is why kubectl apply is idempotent — if you apply the same YAML twice, the second apply finds actual == desired and does nothing.

---

**Q3: What is the difference between a Deployment and a StatefulSet?**

**Answer:**

| | Deployment | StatefulSet |
|--|-----------|-------------|
| **Pod identity** | Random names (`api-xxx-yyy`) | Stable, ordered (`db-0`, `db-1`) |
| **Pod scheduling** | Any order, simultaneously | Sequential (`db-0` before `db-1`) |
| **Storage** | Shared PVC or no PVC | Each pod gets its own PVC (VolumeClaimTemplate) |
| **DNS** | Via Service (not per-pod) | Per-pod DNS: `db-0.db-svc.ns.svc.cluster.local` |
| **Use case** | Stateless APIs, web apps | Databases, Kafka, Zookeeper, Redis |

**Mental Model:**
- Deployment = a call center with interchangeable workers. Any worker can handle any call. If one leaves, a replacement is identical.
- StatefulSet = a hospital with named doctors. "Dr. Smith" has a specific office and patient list. If Dr. Smith leaves, her replacement is specifically Dr. Smith's replacement — not just any doctor.

---

**Q4: Explain how Kubernetes Services work — specifically ClusterIP.**

**Answer:**
A ClusterIP Service is a stable virtual IP assigned by kube-proxy to a set of pods selected by label selector. When a request hits the ClusterIP, kube-proxy (running on each node using iptables or IPVS) load-balances the connection to one of the backing pod IPs.

The ClusterIP never changes even when pods restart (and get new IPs). That's the whole point — pods are ephemeral, Services are stable.

**DNS:** CoreDNS automatically creates a DNS entry: `<service>.<namespace>.svc.cluster.local → ClusterIP`

**Mental Model:** Service is like a department's phone extension (1234). The people answering that extension change (pods come and go), but the extension number stays the same. The switchboard (kube-proxy) routes calls to whoever is available.

```bash
# Practical: verify service resolution
kubectl exec myapp-pod -- nslookup simpleapi2-svc.simple-apis.svc.cluster.local
# Returns: 10.0.15.42 (ClusterIP — never changes)
```

---

**Q5: What is the difference between liveness, readiness, and startup probes?**

**Answer:**

| Probe | Question it answers | Action on failure | Use case |
|-------|-------------------|-------------------|----------|
| **Liveness** | "Is the container still alive?" | Restart container | Detect deadlocks, infinite loops |
| **Readiness** | "Is the container ready for traffic?" | Remove from Service endpoints | DB not connected, warm-up |
| **Startup** | "Has the container finished starting up?" | Restart if not ready in time | Slow-starting apps (Java, .NET) |

**Key insight:** Startup probe runs FIRST. While startup probe is pending, liveness and readiness probes are disabled. This prevents liveness probe from killing a slow-starting container before it has a chance to initialize.

**Mental Model:**
- Startup = "Is the store open for the first time today?" (door unlocking)
- Readiness = "Is the cashier ready to serve customers?" (can receive traffic)
- Liveness = "Is the cashier still awake and working?" (not stuck)

```yaml
# .NET health check integration
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>()           # Checks DB connectivity
    .AddAzureKeyVault(kvUri, credential);        # Checks KV access

app.MapHealthChecks("/health/live",   new HealthCheckOptions { Predicate = _ => false }); # Always returns healthy (liveness)
app.MapHealthChecks("/health/ready",  new HealthCheckOptions());                           # Full check (readiness)
```

---

**Q6: How does Workload Identity work and why is it better than storing secrets in environment variables?**

**Answer:**
Workload Identity allows pods to authenticate to Azure services (Key Vault, Storage, Service Bus) using a Managed Identity — **no passwords, no client secrets, no stored credentials**.

**How it works (5-step chain):**
1. AKS OIDC issuer issues a token for the pod's ServiceAccount
2. The ServiceAccount is annotated with a Managed Identity's Client ID
3. A Federated Credential on the Managed Identity trusts this specific ServiceAccount
4. When the pod calls Azure SDK (`DefaultAzureCredential`), it reads the OIDC token from `/var/run/secrets/azure/tokens/`
5. Azure AD exchanges the OIDC token for an Azure access token → grants access

**Why better than env vars:**
- Env var secrets can be read by anyone with `kubectl describe pod` or `kubectl exec`
- Secrets in etcd need encryption at rest configured
- Managed Identity tokens auto-rotate every hour
- No risk of accidental commit to Git

**Mental Model:** Instead of giving a contractor a key to your building (password), you give them a badge that the security system recognizes (OIDC token). The badge auto-expires and is issued by a trusted authority.

---

**Q7: Explain KEDA and when to use it over HPA.**

**Answer:**
KEDA (Kubernetes Event-Driven Autoscaling) scales pods based on external event sources like queue length, topic lag, HTTP request rate, or custom metrics. HPA scales based on CPU/memory metrics from the pod itself.

**When to use KEDA:**
- Scale based on Azure Service Bus queue depth (process messages faster when queue grows)
- Scale-to-zero when there are no messages (save cost during quiet periods)
- Scale based on Event Hubs consumer group lag
- Scale based on Prometheus metrics not available in metrics-server

**When to use HPA:**
- CPU-bound workloads (web APIs with consistent CPU correlation to load)
- Memory-based scaling (caching services)
- When metrics-server is sufficient

**Mental Model:** HPA is like hiring more checkout cashiers when the lines get long (after the fact — based on actual congestion). KEDA is like pre-staffing based on how many customers are in the parking lot (event-driven — scale before congestion hits).

---

**Q8: What is GitOps and how does ArgoCD implement it?**

**Answer:**
GitOps is an operational model where Git is the single source of truth for cluster configuration. You never run `kubectl apply` directly in production — instead, you push to Git, and a controller (ArgoCD/Flux) automatically synchronizes the cluster to match Git.

**ArgoCD implementation:**
1. You push a new Deployment YAML to Git
2. ArgoCD polls Git every 3 minutes (or gets webhook notification)
3. ArgoCD compares Git state vs live cluster state
4. If drift detected → ArgoCD applies the change to bring cluster in sync
5. ArgoCD shows "Synced" / "OutOfSync" status per Application

**Benefits:**
- Full audit trail (every change = a Git commit)
- Easy rollback (`git revert`)
- Drift detection (manual changes to cluster get overwritten)
- Multi-cluster management from one Git repo

**Mental Model:** Imagine a blueprint for a building. With GitOps, if a builder makes an unauthorized change to the building, an automated inspector detects the deviation from the blueprint and reverts it. The blueprint (Git) always wins.

---

### 19.2 — .NET-Specific Scenarios

---

**Q9: How would you containerize a .NET 10 Minimal API for AKS?**

**Answer with code:**
```dockerfile
# Multi-stage Dockerfile for .NET 10 Minimal API
# Stage 1: Build (uses full SDK)
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj first (layer caching — only re-runs dotnet restore when .csproj changes)
COPY SimpleApi1/SimpleApi1.csproj SimpleApi1/
RUN dotnet restore SimpleApi1/SimpleApi1.csproj

# Copy rest of source and build
COPY SimpleApi1/ SimpleApi1/
WORKDIR /src/SimpleApi1
RUN dotnet publish -c Release -o /app/publish \
    --no-restore \
    /p:UseAppHost=false      # Disable OS-specific executable

# Stage 2: Runtime (much smaller — no SDK)
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# Run as non-root user for security
RUN adduser --disabled-password --no-create-home appuser
USER appuser

COPY --from=build /app/publish .

# Tell ASP.NET Core to listen on port 80
ENV ASPNETCORE_HTTP_PORTS=80
EXPOSE 80

ENTRYPOINT ["dotnet", "SimpleApi1.dll"]
```

**Key points to mention in interview:**
- Multi-stage reduces final image size from ~900MB to ~200MB
- Non-root user prevents container escape attacks
- Layer caching: copy .csproj first so `dotnet restore` only runs when dependencies change
- `UseAppHost=false`: don't create OS-specific binary — use `dotnet` to run

---

**Q10: How would you implement zero-downtime deployment for a .NET API on AKS?**

**Answer:**
Zero-downtime requires coordination between Kubernetes deployment strategy and ASP.NET Core graceful shutdown.

```csharp
// Program.cs — Graceful shutdown handling
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

var app = builder.Build();

// Health endpoints for probes
app.MapHealthChecks("/health/live",  new HealthCheckOptions { Predicate = _ => false });
app.MapHealthChecks("/health/ready", new HealthCheckOptions());

// When SIGTERM is received:
// 1. K8s removes pod from Service endpoints (readiness probe will fail OR we respond 503)
// 2. Wait for in-flight requests (preStop hook gives us 15s)
// 3. App drains and exits
app.Lifetime.ApplicationStopping.Register(() =>
{
    Console.WriteLine("SIGTERM received — draining...");
    Thread.Sleep(5000);  // Wait 5s for load balancer to deregister us
});

app.Run();
```

```yaml
# Deployment strategy for zero-downtime
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0      # Never kill old pod before new pod is Ready
      maxSurge: 1            # Create 1 extra pod temporarily during rollout
  template:
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: simpleapi1
        lifecycle:
          preStop:
            exec:
              command: ["sh", "-c", "sleep 15"]  # Wait for LB deregistration
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 10    # Time for .NET to start
          periodSeconds: 5
```

---

**Q11: How do you access Azure Key Vault secrets in a .NET app running in AKS?**

**Answer — two approaches:**

**Approach A: CSI Driver (mounts secrets as files)**
```yaml
# SecretProviderClass — defines what to fetch from Key Vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: simpleapi1-kv
  namespace: simple-apis
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: "<managed-identity-client-id>"
    keyvaultName: "myKeyVault"
    tenantId: "<tenant-id>"
    objects: |
      array:
        - |
          objectName: ConnectionStrings--DefaultConnection
          objectType: secret
  secretObjects:            # Also sync as K8s Secret (for env var use)
  - secretName: app-secrets
    type: Opaque
    data:
    - objectName: ConnectionStrings--DefaultConnection
      key: connection-string
```

**Approach B: Azure SDK in code (recommended for .NET)**
```csharp
// Program.cs — fetch secrets directly at startup
builder.Configuration.AddAzureKeyVault(
    new Uri("https://myKeyVault.vault.azure.net/"),
    new DefaultAzureCredential()
    // DefaultAzureCredential uses Workload Identity token when in pod
    // Uses local az login when developing locally
);

// Access like normal config
var connStr = builder.Configuration["ConnectionStrings:DefaultConnection"];
```

**Which to use:**
- CSI Driver: when other teams/systems also need the secrets, or when you need them as env vars
- Azure SDK: cleaner for .NET — uses standard `IConfiguration` pattern

---

**Q12: How would you debug a .NET app that's not starting properly in AKS?**

**Step-by-step answer:**
```bash
# Step 1: Check pod status
kubectl get pods -n simple-apis
# Look for: CrashLoopBackOff, Error, Pending, Init:0/1

# Step 2: Read the application logs (most useful)
kubectl logs <pod-name> -n simple-apis
kubectl logs <pod-name> -n simple-apis --previous   # If already crashed

# Step 3: Look at Kubernetes events
kubectl describe pod <pod-name> -n simple-apis
# Events section shows: image pull errors, volume mount failures, probe failures

# Step 4: Check if it's a config issue — verify env vars
kubectl exec <pod-name> -n simple-apis -- env | sort

# Step 5: Interactive debugging
kubectl exec -it <pod-name> -n simple-apis -- /bin/bash
# Inside container: check /app/config files, test DB connections

# Step 6: If pod won't start at all — run a debug container
kubectl debug <pod-name> -n simple-apis \
  --image=mcr.microsoft.com/dotnet/sdk:10.0 \
  --share-processes --copy-to=debug-copy
```

---

### 19.3 — Architecture & Design Questions

---

**Q13: How would you design a multi-tenant AKS setup for different teams?**

**Answer:**
Use **namespace-per-team** isolation with ResourceQuotas, NetworkPolicies, and RBAC:

```yaml
# 1. Namespace per team
kubectl create namespace team-payments
kubectl create namespace team-orders

# 2. ResourceQuota — limit what each team can consume
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-payments-quota
  namespace: team-payments
spec:
  hard:
    requests.cpu: "8"          # Total CPU requests across all pods
    requests.memory: 16Gi
    limits.cpu: "16"
    limits.memory: 32Gi
    count/pods: "50"           # Max 50 pods in this namespace
    count/services: "20"

# 3. NetworkPolicy — namespace isolation (pods can't talk cross-namespace by default)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cross-namespace
  namespace: team-payments
spec:
  podSelector: {}               # Applies to ALL pods in namespace
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector: {}           # Allow from pods IN SAME namespace only
```

---

**Q14: How does KEDA scale to zero and what are the implications for .NET APIs?**

**Answer:**
KEDA can scale a Deployment to 0 replicas when there are no messages in a queue (or HTTP requests, or other trigger events). When a message arrives, KEDA scales from 0 to 1+ replicas before the message processor starts.

**Implication for .NET APIs:** Cold start time. A .NET 10 Minimal API starts in ~2-5 seconds. With scale-to-zero:
- First request after idle period → 3-7 second delay (pod start + .NET init)
- Subsequent requests → normal latency

**Mitigations:**
```yaml
# Keep minimum 1 replica during business hours (no cold start)
spec:
  minReplicaCount: 1         # Always at least 1 pod (no cold start)
  maxReplicaCount: 20

# Use KEDA CronScaler to pre-scale before peak hours
- type: cron
  metadata:
    timezone: "America/New_York"
    start: "55 8 * * 1-5"    # Scale up at 8:55 AM weekdays
    end:   "0 18 * * 1-5"    # Scale down at 6:00 PM weekdays
    desiredReplicas: "3"
```

---

**Q15: What is the difference between Azure CNI and Kubenet networking in AKS?**

**Answer:**

| | Kubenet | Azure CNI | Azure CNI Overlay |
|--|---------|-----------|-------------------|
| **Pod IPs** | Not in VNet — private overlay | Real VNet IPs consumed | Overlay IPs, not from VNet |
| **IP usage** | Efficient | High (1 IP per pod from subnet) | Efficient |
| **Subnet size needed** | Small | Large (nodes × max-pods per node) | Small |
| **Network policy** | Calico only | Calico or Azure | Cilium recommended |
| **Performance** | Extra NAT hop | Direct routing | Near-native |
| **Windows nodes** | Not supported | Supported | Limited |

**When to choose:**
- **Azure CNI:** Need pods accessible from on-prem via ExpressRoute, need Windows nodes
- **Azure CNI Overlay:** New clusters — best balance of IP efficiency + direct routing
- **Kubenet:** Small clusters, dev/test, limited IP space

**Mental Model:** Kubenet = private phone network inside a company (pods use internal extensions, get NAT'd to public). Azure CNI = every employee gets a direct external phone number (real VNet IP).

---

**Q16: How would you implement blue/green deployment in AKS?**

**Answer:**
Blue/green uses two identical Deployments (blue=current, green=new). Traffic is switched by changing the Service selector label.

```yaml
# Blue Deployment (currently serving traffic)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1-blue
  namespace: simple-apis
spec:
  replicas: 3
  selector:
    matchLabels:
      app: simpleapi1
      version: blue
  template:
    metadata:
      labels:
        app: simpleapi1
        version: blue      # ← this label used for traffic switching
    spec:
      containers:
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v1

---
# Green Deployment (new version, not serving traffic yet)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1-green
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: simpleapi1
        version: green
    spec:
      containers:
      - name: simpleapi1
        image: acrdemo.azurecr.io/simpleapi1:v2   # New version

---
# Service: currently pointing to blue
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-svc
spec:
  selector:
    app: simpleapi1
    version: blue           # ← change to "green" to switch all traffic instantly
  ports:
  - port: 80
```

```bash
# Switch traffic to green (instant cutover)
kubectl patch service simpleapi1-svc -n simple-apis \
  -p '{"spec":{"selector":{"version":"green"}}}'

# Verify switch
kubectl get endpoints simpleapi1-svc -n simple-apis
# Should show green pod IPs

# If green has issues — instant rollback
kubectl patch service simpleapi1-svc -n simple-apis \
  -p '{"spec":{"selector":{"version":"blue"}}}'
```

---

### 19.4 — Operational Questions

---

**Q17: How do you ensure high availability for workloads in AKS?**

**Answer (5 key pillars):**

1. **Multiple replicas + PodDisruptionBudget**
```yaml
spec:
  replicas: 3                # Never run less than 3 for HA
---
apiVersion: policy/v1
kind: PodDisruptionBudget
spec:
  minAvailable: 2            # During node drain, always keep 2 pods running
```

2. **Availability Zones for node pools**
```bash
az aks nodepool add \
  --cluster-name myAKS \
  --name hapoolz \
  --zones 1 2 3 \            # Spread nodes across 3 AZs
  --node-count 3             # 1 node per zone
```

3. **Pod anti-affinity to spread across nodes/zones**
```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: simpleapi1
        topologyKey: topology.kubernetes.io/zone  # Spread across AZs
```

4. **Resource limits** — prevents one pod from consuming all node resources

5. **Health probes** — ensures unhealthy pods are removed from Service endpoints

---

**Q18: Explain the AKS upgrade process and risks.**

**Answer:**
AKS upgrades happen in two phases:
1. **Control plane upgrade:** Azure updates API server, scheduler, etcd. Usually transparent (~5 min).
2. **Node pool upgrade:** Done node by node via cordon → drain → replace.

```bash
# Check available upgrades
az aks get-upgrades -g myRG -n myAKS --output table
# Output:
# Name     KubernetesVersion   Upgrades
# ───────  ─────────────────   ────────
# default  1.29.9              1.30.5, 1.31.2

# Upgrade control plane only
az aks upgrade -g myRG -n myAKS --kubernetes-version 1.31.2 --control-plane-only

# Upgrade node pool separately (with --max-surge for faster upgrade)
az aks nodepool upgrade \
  --resource-group myRG \
  --cluster-name myAKS \
  --name nodepool1 \
  --kubernetes-version 1.31.2 \
  --max-surge 33%    # Create extra nodes to speed up upgrade
```

**Risks & mitigations:**
- API deprecations between versions → check deprecations before upgrade
- PodDisruptionBudgets can block drain → ensure minAvailable allows drain
- StatefulSet pods need careful ordering → test in dev first
- Use Blue/Green node pools for zero-risk: add new v1.31 pool, drain old pool, delete old pool

---

**Q19: What metrics and alerts would you set up for a production AKS cluster?**

**Answer:**

```bash
# Key metrics to alert on (via Azure Monitor / Prometheus)

# 1. Pod restarts > 5 in 1 hour → likely CrashLoop
# KQL in Log Analytics:
# KubePodInventory
# | where RestartCount > 5
# | summarize count() by Name, Namespace

# 2. Node memory utilization > 85% → risk of OOMKills
# 3. PVC disk usage > 80% → storage running out
# 4. Pending pods > 0 for > 10 min → scheduling failure
# 5. HTTP 5xx error rate > 1% → app errors
# 6. P99 latency > 2000ms → performance degradation
# 7. HPA at max replicas → need larger limits or more nodes
```

```yaml
# Prometheus alert rules (if using kube-prometheus-stack)
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: aks-critical-alerts
  namespace: monitoring
spec:
  groups:
  - name: pod.alerts
    rules:
    - alert: PodCrashLooping
      expr: |
        rate(kube_pod_container_status_restarts_total[15m]) * 60 * 15 > 5
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Pod {{ $labels.pod }} is crash looping"

    - alert: HighMemoryUtilization
      expr: |
        (sum(container_memory_working_set_bytes{container!=""}) by (node))
        / (sum(machine_memory_bytes) by (node)) > 0.85
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Node {{ $labels.node }} memory usage > 85%"
```

---

## PART 20: AKS Development & Deployment — End-to-End Walkthrough

> **Special Section:** Container orchestration, scaling, and deployment — from zero to production.

This section walks through the complete journey: local development → containerization → push to ACR → deploy to AKS → scale → monitor.

---

### 20.1 — The Full Development Workflow

```
┌────────────────────────────────────────────────────────────────────────────┐
│              END-TO-END AKS DEVELOPMENT & DEPLOYMENT WORKFLOW              │
│                                                                            │
│  LOCAL DEV          BUILD              REGISTRY         CLUSTER            │
│  ┌──────────┐       ┌──────────┐       ┌──────────┐     ┌──────────────┐  │
│  │ .NET App │──────►│ docker   │──────►│  Azure   │────►│ AKS Cluster  │  │
│  │ SimpleApi│  build│  build   │  push │ Container│ pull│              │  │
│  │          │       │          │       │ Registry │     │  Deployment  │  │
│  └──────────┘       └──────────┘       └──────────┘     │  Service     │  │
│       │                                                  │  Ingress     │  │
│  docker run         Dockerfile                           └──────┬───────┘  │
│  (local test)       (multi-stage)                               │          │
│                                                          ┌──────▼───────┐  │
│  SCALE ◄──────── HPA / KEDA / Cluster Autoscaler ────── │  Users/LB    │  │
│                                                          └──────────────┘  │
│  OBSERVE ◄───── Azure Monitor / Container Insights / Prometheus           │
│                                                                            │
│  CI/CD: Azure DevOps Pipeline / GitHub Actions                             │
│  IaC: Bicep / Terraform provisions cluster, ACR, Key Vault                │
└────────────────────────────────────────────────────────────────────────────┘
```

---

### 20.2 — Step 1: Containerize the .NET App

```bash
# Build SimpleApi1 image locally
docker build -t simpleapi1:local -f SimpleApi1/Dockerfile SimpleApi1/
# Sample Output:
# [+] Building 12.4s (12/12) FINISHED
# => [internal] load build definition from Dockerfile           0.1s
# => [internal] load .dockerignore                              0.1s
# => [1/4] FROM mcr.microsoft.com/dotnet/aspnet:10.0           3.2s
# => [2/4] WORKDIR /app                                         0.0s
# => [3/4] COPY . .                                             0.1s
# => [4/4] RUN dotnet publish -c Release -o /app/publish        7.8s
# => exporting to image                                         1.1s
# => naming to docker.io/library/simpleapi1:local               0.0s

# Test locally
docker run -p 8080:80 simpleapi1:local
# Sample Output:
# info: Microsoft.Hosting.Lifetime[14]
#       Now listening on: http://[::]:80
# info: Microsoft.Hosting.Lifetime[0]
#       Application started. Press Ctrl+C to shut down.
curl http://localhost:8080/health
# Output: {"status":"healthy","service":"simpleapi1"}

# Multi-container local test with docker-compose
cat > docker-compose.yml << 'EOF'
services:
  simpleapi1:
    build: ./SimpleApi1
    ports: ["8080:80"]
    environment:
      SIMPLEAPI2_BASE_URL: http://simpleapi2:80
    depends_on: [simpleapi2]

  simpleapi2:
    build: ./SimpleApi2
    environment:
      ASPNETCORE_HTTP_PORTS: "80"
EOF

docker-compose up
curl http://localhost:8080/combined-data
```

---

### 20.3 — Step 2: Push to Azure Container Registry

```bash
# Create ACR
az acr create \
  --resource-group myRG \
  --name acrdemoaks \
  --sku Standard \
  --admin-enabled false    # Use managed identity, not admin credentials

# Login to ACR (uses current az login identity)
az acr login --name acrdemoaks

# Tag and push
docker tag simpleapi1:local acrdemoaks.azurecr.io/simpleapi1:v1
# (no output on success)
docker push acrdemoaks.azurecr.io/simpleapi1:v1
# Sample Output:
# The push refers to repository [acrdemoaks.azurecr.io/simpleapi1]
# abc123ef: Pushed
# def456ab: Layer already exists
# v1: digest: sha256:abc123def456789abcdef0123456789abcdef0123456789abcdef0123456789 size: 1234

docker tag simpleapi2:local acrdemoaks.azurecr.io/simpleapi2:v1
# (no output on success)
docker push acrdemoaks.azurecr.io/simpleapi2:v1
# Sample Output:
# The push refers to repository [acrdemoaks.azurecr.io/simpleapi2]
# bcd234ef: Pushed
# def456ab: Layer already exists
# v1: digest: sha256:bcd234ef5678901bcdef1234567890bcdef1234567890bcdef1234567890bc size: 1232

# Verify images in ACR
az acr repository list --name acrdemoaks --output table
# Output:
# Result
# ──────────
# simpleapi1
# simpleapi2

az acr repository show-tags --name acrdemoaks --repository simpleapi1 --output table
# Result
# ──────
# v1
```

---

### 20.4 — Step 3: Provision AKS Cluster

```bash
# Create resource group
az group create --name myRG --location eastus

# Create AKS cluster with all production-ready settings
az aks create \
  --resource-group myRG \
  --name myAKSCluster \
  --kubernetes-version 1.31.2 \
  --node-count 3 \
  --node-vm-size Standard_D4s_v3 \
  --enable-managed-identity \
  --enable-oidc-issuer \
  --enable-workload-identity \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 10 \
  --tier standard \
  --zones 1 2 3 \
  --attach-acr acrdemoaks \
  --enable-addons monitoring \
  --workspace-resource-id /subscriptions/.../resourcegroups/myRG/providers/microsoft.operationalinsights/workspaces/myLAW

# Get credentials
az aks get-credentials --resource-group myRG --name myAKSCluster

# Verify
kubectl get nodes
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-nodepool1-12345678-vmss000000   Ready    agent   2m    v1.31.2
# aks-nodepool1-12345678-vmss000001   Ready    agent   2m    v1.31.2
# aks-nodepool1-12345678-vmss000002   Ready    agent   2m    v1.31.2
```

---

### 20.5 — Step 4: Deploy Applications

```bash
# Create namespace
kubectl create namespace simple-apis

# Apply all manifests
kubectl apply -f k8s/simpleapi2-deployment.yaml -n simple-apis
kubectl apply -f k8s/simpleapi1-deployment.yaml -n simple-apis
kubectl apply -f k8s/ingress.yaml -n simple-apis

# Watch rollout
kubectl rollout status deployment/simpleapi1 -n simple-apis
kubectl rollout status deployment/simpleapi2 -n simple-apis

# Verify everything is running
kubectl get all -n simple-apis
# NAME                              READY   STATUS    RESTARTS
# pod/simpleapi1-xxx-1              1/1     Running   0
# pod/simpleapi1-xxx-2              1/1     Running   0
# pod/simpleapi1-xxx-3              1/1     Running   0
# pod/simpleapi2-xxx-1              1/1     Running   0
# pod/simpleapi2-xxx-2              1/1     Running   0
#
# NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP
# service/simpleapi1-svc ClusterIP      10.0.42.18    <none>
# service/simpleapi2-svc ClusterIP      10.0.15.42    <none>
# service/api-lb         LoadBalancer   10.0.200.5    52.186.142.10
#
# NAME                         READY   UP-TO-DATE   AVAILABLE
# deployment.apps/simpleapi1   3/3     3            3
# deployment.apps/simpleapi2   2/2     2            2
```

---

### 20.6 — Step 5: Configure Autoscaling

```yaml
# HPA for CPU-based scaling
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: simpleapi1-hpa
  namespace: simple-apis
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: simpleapi1
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60     # Scale when avg CPU > 60%
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 75
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 30   # React quickly to load spikes
    scaleDown:
      stabilizationWindowSeconds: 300  # Wait 5 min before scaling down
```

```bash
# Apply and test HPA
kubectl apply -f k8s/hpa.yaml -n simple-apis

# Monitor HPA in real time
kubectl get hpa -n simple-apis -w
# NAME            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS
# simpleapi1-hpa  Deployment/simpleapi1  8%/60%    2         20        2
# simpleapi1-hpa  Deployment/simpleapi1  85%/60%   2         20        3    ← scaled up!
# simpleapi1-hpa  Deployment/simpleapi1  92%/60%   2         20        5    ← more pods!
```

---

### 20.7 — Step 6: CI/CD Pipeline (Azure DevOps)

```yaml
# azure-pipelines.yml — Full multi-stage pipeline
trigger:
  branches:
    include: [main, release/*]
  paths:
    include: [SimpleApi1/**, SimpleApi2/**, k8s/**]

variables:
  ACR_NAME: acrdemoaks
  AKS_CLUSTER: myAKSCluster
  RESOURCE_GROUP: myRG
  NAMESPACE: simple-apis

stages:
# ── STAGE 1: BUILD & PUSH ──────────────────────────────────────────
- stage: Build
  displayName: 'Build and Push Images'
  jobs:
  - job: BuildPush
    pool:
      vmImage: ubuntu-latest
    steps:
    - task: AzureCLI@2
      displayName: 'Build and Push to ACR'
      inputs:
        azureSubscription: 'MyServiceConnection'
        scriptType: bash
        scriptLocation: inlineScript
        inlineScript: |
          # Login to ACR using managed identity (no stored passwords)
          az acr login --name $(ACR_NAME)

          # Build with git commit SHA as tag (immutable, traceable)
          IMAGE_TAG=$(Build.SourceVersion | cut -c1-8)

          docker build -t $(ACR_NAME).azurecr.io/simpleapi1:$IMAGE_TAG \
            -f SimpleApi1/Dockerfile SimpleApi1/
          docker push $(ACR_NAME).azurecr.io/simpleapi1:$IMAGE_TAG

          docker build -t $(ACR_NAME).azurecr.io/simpleapi2:$IMAGE_TAG \
            -f SimpleApi2/Dockerfile SimpleApi2/
          docker push $(ACR_NAME).azurecr.io/simpleapi2:$IMAGE_TAG

          # Write tag to pipeline variable for next stage
          echo "##vso[task.setvariable variable=IMAGE_TAG;isOutput=true]$IMAGE_TAG"
      name: buildStep

# ── STAGE 2: DEPLOY TO DEV ─────────────────────────────────────────
- stage: DeployDev
  displayName: 'Deploy to Dev'
  dependsOn: Build
  condition: succeeded()
  variables:
    IMAGE_TAG: $[stageDependencies.Build.BuildPush.outputs['buildStep.IMAGE_TAG']]
  jobs:
  - deployment: DeployToDev
    environment: 'dev'                 # Azure DevOps environment (tracks deployments)
    pool:
      vmImage: ubuntu-latest
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            displayName: 'Deploy to AKS Dev'
            inputs:
              azureSubscription: 'MyServiceConnection'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az aks get-credentials \
                  --resource-group $(RESOURCE_GROUP) \
                  --name $(AKS_CLUSTER)-dev

                # Update image tags using kubectl set image (or helm upgrade)
                kubectl set image deployment/simpleapi1 \
                  simpleapi1=$(ACR_NAME).azurecr.io/simpleapi1:$(IMAGE_TAG) \
                  -n $(NAMESPACE)

                kubectl set image deployment/simpleapi2 \
                  simpleapi2=$(ACR_NAME).azurecr.io/simpleapi2:$(IMAGE_TAG) \
                  -n $(NAMESPACE)

                # Wait for rollout to complete
                kubectl rollout status deployment/simpleapi1 -n $(NAMESPACE) --timeout=5m
                kubectl rollout status deployment/simpleapi2 -n $(NAMESPACE) --timeout=5m

# ── STAGE 3: DEPLOY TO PROD (manual approval gate) ─────────────────
- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: DeployDev
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToProd
    environment: 'production'          # Requires manual approval in Azure DevOps
    pool:
      vmImage: ubuntu-latest
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            displayName: 'Deploy to AKS Prod'
            inputs:
              azureSubscription: 'MyServiceConnection'
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                az aks get-credentials \
                  --resource-group $(RESOURCE_GROUP) \
                  --name $(AKS_CLUSTER)-prod

                kubectl set image deployment/simpleapi1 \
                  simpleapi1=$(ACR_NAME).azurecr.io/simpleapi1:$(IMAGE_TAG) \
                  -n $(NAMESPACE)

                kubectl rollout status deployment/simpleapi1 \
                  -n $(NAMESPACE) --timeout=10m

                echo "Deployment complete: $(ACR_NAME).azurecr.io/simpleapi1:$(IMAGE_TAG)"
```

---

### 20.8 — Step 7: Monitor in Production

```bash
# Real-time pod monitoring
watch kubectl get pods -n simple-apis

# Live HPA watching (see scaling in action)
watch kubectl get hpa -n simple-apis

# Stream logs from all pods with a label
kubectl logs -f -l app=simpleapi1 -n simple-apis --all-containers=true --prefix=true

# Check resource utilization
kubectl top pods -n simple-apis
kubectl top nodes

# KQL query in Log Analytics — find all errors in last 1 hour
# ContainerLogV2
# | where TimeGenerated > ago(1h)
# | where LogMessage contains "Exception" or LogMessage contains "Error"
# | where Namespace == "simple-apis"
# | project TimeGenerated, PodName, ContainerName, LogMessage
# | order by TimeGenerated desc

# View Azure Monitor metrics in Azure Portal:
# AKS → Insights → Containers → Filter by namespace: simple-apis
```

---

---

## PART 21: [Offline-Laptop] Practice AKS & Helm End-to-End Without Cloud

> **Goal:** Reproduce a production-grade AKS environment on your laptop — namespaces, deployments, services, ingress, helm, HPA, KEDA, Prometheus, Grafana, ArgoCD — all locally. No Azure subscription needed.

---

### 21.1 — Tool Choices: Which Local Kubernetes to Use?

```
┌──────────────────────────────────────────────────────────────────────────┐
│         LOCAL KUBERNETES TOOLS — COMPARISON                              │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Docker Desktop (Windows/Mac)                                   │    │
│  │  ✓ Single click — enable K8s in Settings                        │    │
│  │  ✓ Best Windows experience (WSL2 backend)                       │    │
│  │  ✓ Shares Docker daemon — images available immediately          │    │
│  │  ✗ Only 1 node (no node pool simulation)                        │    │
│  │  ✗ Slower to start (~3 min)                                     │    │
│  │  Recommended for: Windows developers, beginners                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  minikube                                                        │    │
│  │  ✓ Multi-node support (--nodes 3)                               │    │
│  │  ✓ Many addons: ingress, dashboard, metrics-server, registry    │    │
│  │  ✓ Works with Docker, Podman, Hyper-V, VirtualBox driver        │    │
│  │  ✓ minikube tunnel exposes LoadBalancer services                │    │
│  │  ✗ Slightly heavier than kind                                   │    │
│  │  Recommended for: full feature practice, addons                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  kind (Kubernetes in Docker)                                     │    │
│  │  ✓ Fastest startup (~30 seconds)                                │    │
│  │  ✓ Multi-node via simple YAML config                            │    │
│  │  ✓ Best for CI/CD pipelines                                     │    │
│  │  ✗ LoadBalancer services need MetalLB (extra step)              │    │
│  │  ✗ No built-in addons                                           │    │
│  │  Recommended for: CI/CD testing, fast iteration                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ► This guide uses minikube (best for feature coverage on Windows)      │
│  ► You can use either Docker or Podman — both are fully supported       │
│  ► Podman is a lightweight, rootless alternative to Docker              │
└──────────────────────────────────────────────────────────────────────────┘
```

---

### 21.2 — Prerequisites Installation (Windows)

**Install in this order — each depends on the previous:**

#### Option A: Using Docker Desktop (Most Common)

```powershell
# ── Step 1: Install Chocolatey package manager (run as Administrator) ──
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ── Step 2: Install all tools at once ──────────────────────────────────
choco install -y `
  docker-desktop `          # Docker Engine + WSL2 backend
  minikube `                # Local Kubernetes
  kubernetes-cli `          # kubectl
  helm `                    # Helm package manager
  git `                     # Git (for GitOps)
  dotnet-sdk `              # .NET SDK 10
  vscode                    # VS Code

# ── Step 3: Verify installations ──────────────────────────────────────
docker --version
# Docker version 27.x.x

kubectl version --client
# Client Version: v1.31.x

minikube version
# minikube version: v1.34.x

helm version
# version.BuildInfo{Version:"v3.16.x"}

dotnet --version
# 10.0.x
```

> **WSL2 Required on Windows:** Docker Desktop needs WSL2 (Windows Subsystem for Linux 2).
> Enable it: `wsl --install` in an elevated PowerShell, then reboot.

---

#### Option B: Using Podman (Open-Source, Rootless Alternative)

```powershell
# ── Step 1: Install Chocolatey package manager (run as Administrator) ──
# (Same as above if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# ── Step 2: Install Podman and other tools ────────────────────────────
choco install -y `
  podman-desktop `          # Podman Desktop (includes podman CLI + GUI)
  minikube `                # Local Kubernetes
  kubernetes-cli `          # kubectl
  helm `                    # Helm package manager
  git `                     # Git (for GitOps)
  dotnet-sdk `              # .NET SDK 10
  vscode                    # VS Code

# ── Alternative: Install Podman CLI only (without GUI) ────────────────
# choco install -y podman

# ── Step 3: Initialize Podman machine ──────────────────────────────────
# Podman on Windows runs containers in a lightweight Linux VM
podman machine init --cpus 4 --memory 8192 --disk-size 50
# Sample Output:
# Extracting compressed file: podman-machine-default-arm64.raw.gz
# Machine init complete

podman machine start
# Sample Output:
# Starting machine "podman-machine-default"
# Machine "podman-machine-default" started successfully

# ── Step 4: Verify installations ───────────────────────────────────────
podman --version
# podman version 5.x.x

podman info | Select-String "rootless"
# rootless: true  ← Podman runs without root privileges!

kubectl version --client
# Client Version: v1.31.x

minikube version
# minikube version: v1.34.x

helm version
# version.BuildInfo{Version:"v3.16.x"}

dotnet --version
# 10.0.x
```

> **Key Differences:**
> - **Docker Desktop:** Single daemon, requires WSL2, GUI-focused, commercial licensing
> - **Podman:** Daemonless (rootless), open-source, CLI-first, OCI-compliant, drop-in replacement
> - **Compatibility:** Podman commands are identical to Docker: `podman build`, `podman run`, etc.
> - **Alias Tip:** Run `Set-Alias docker podman` in PowerShell to use `docker` command with Podman

> **WSL2 Still Recommended for Podman:** While Podman can run natively on Windows using Hyper-V,
> WSL2 provides better performance and integration. Install with `wsl --install`, then reboot.

---

### 21.3 — Start minikube with Production-Like Settings

#### Option A: Using Docker Driver

```bash
# ── Start minikube — sized like a real dev cluster ─────────────────────
minikube start \
  --driver=docker \         # Use Docker as the VM driver (no Hyper-V needed)
  --cpus=4 \                # Allocate 4 CPUs to minikube VM
  --memory=8192 \           # 8GB RAM (Prometheus + Grafana need ~2GB)
  --nodes=2 \               # 2 nodes — simulates node pool (1 control-plane, 1 worker)
  --kubernetes-version=v1.31.0 \
  --container-runtime=containerd \   # Matches AKS default runtime
  --addons=ingress,metrics-server,dashboard

# Sample Output:
# 😄  minikube v1.34.0 on Windows 11
# ✨  Using the docker driver based on user configuration
# 👍  Starting "minikube" primary control-plane node in "minikube" cluster
# 🚜  Pulling base image v0.0.45 ...
# 🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
# 🐳  Preparing Kubernetes v1.31.0 on Docker ...
# 🔎  Verifying Kubernetes components...
# 🌟  Enabled addons: ingress, metrics-server, dashboard, storage-provisioner
# 🏄  Done! kubectl is now configured to use "minikube" cluster

# Verify nodes
kubectl get nodes
# NAME           STATUS   ROLES           AGE   VERSION
# minikube       Ready    control-plane   2m    v1.31.0
# minikube-m02   Ready    <none>          90s   v1.31.0

# View full cluster info
kubectl cluster-info
# Kubernetes control plane is running at https://127.0.0.1:57987
# CoreDNS is running at https://127.0.0.1:57987/api/v1/namespaces/kube-system/...

# WHY --nodes=2: Simulates AKS node pool — practice pod scheduling,
# anti-affinity, DaemonSets running on both nodes
# WHY metrics-server: Required for HPA (Horizontal Pod Autoscaler)
# WHY ingress: NGINX Ingress Controller — replaces Azure App Gateway locally
```

---

#### Option B: Using Podman Driver

```bash
# ── Start minikube with Podman driver ───────────────────────────────────
minikube start \
  --driver=podman \         # Use Podman as the container driver
  --cpus=4 \                # Allocate 4 CPUs to minikube VM
  --memory=8192 \           # 8GB RAM (Prometheus + Grafana need ~2GB)
  --nodes=2 \               # 2 nodes — simulates node pool (1 control-plane, 1 worker)
  --kubernetes-version=v1.31.0 \
  --container-runtime=containerd \   # Matches AKS default runtime
  --addons=ingress,metrics-server,dashboard

# Sample Output:
# 😄  minikube v1.34.0 on Windows 11
# ✨  Using the podman driver based on user configuration
# 👍  Starting "minikube" primary control-plane node in "minikube" cluster
# 🚜  Pulling base image v0.0.45 ...
# 🔥  Creating podman container (CPUs=4, Memory=8192MB) ...
# 🐳  Preparing Kubernetes v1.31.0 on Docker ...
# 🔎  Verifying Kubernetes components...
# 🌟  Enabled addons: ingress, metrics-server, dashboard, storage-provisioner
# 🏄  Done! kubectl is now configured to use "minikube" cluster

# Verify nodes
kubectl get nodes
# NAME           STATUS   ROLES           AGE   VERSION
# minikube       Ready    control-plane   2m    v1.31.0
# minikube-m02   Ready    <none>          90s   v1.31.0

# View full cluster info
kubectl cluster-info
# Kubernetes control plane is running at https://127.0.0.1:57987
# CoreDNS is running at https://127.0.0.1:57987/api/v1/namespaces/kube-system/...

# WHY --nodes=2: Simulates AKS node pool — practice pod scheduling,
# anti-affinity, DaemonSets running on both nodes
# WHY metrics-server: Required for HPA (Horizontal Pod Autoscaler)
# WHY ingress: NGINX Ingress Controller — replaces Azure App Gateway locally
```

> **Podman Driver Notes:**
> - Requires Podman 4.0+ installed and podman machine running (`podman machine start`)
> - Fully compatible with all Kubernetes features used in this guide
> - Rootless by default — better security isolation
> - If you get "driver not found" error: `minikube config set driver podman`

---

### 21.4 — Build the .NET Apps for Local Kubernetes

```bash
# ── Create project structure ───────────────────────────────────────────
mkdir -p ~/aks-local/{SimpleApi1,SimpleApi2,k8s,helm-chart}
cd ~/aks-local

# ── Create SimpleApi1 (.NET Minimal API) ──────────────────────────────
dotnet new webapi -n SimpleApi1 --use-minimal-apis -o SimpleApi1 --no-openapi
cd SimpleApi1

# Replace Program.cs with our full app
cat > Program.cs << 'EOF'
var builder = WebApplication.CreateBuilder(args);

// Register HttpClient for service-to-service calls
builder.Services.AddHttpClient("SimpleApi2", client =>
{
    // In Kubernetes: use DNS name. Locally: use localhost fallback
    client.BaseAddress = new Uri(
        builder.Configuration["SIMPLEAPI2_URL"] ?? "http://localhost:5002"
    );
    client.Timeout = TimeSpan.FromSeconds(10);
});

builder.Services.AddHealthChecks();

var app = builder.Build();

// ── Health endpoint (used by liveness + readiness probes) ─────────────
app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    service = "simpleapi1",
    timestamp = DateTime.UtcNow
}));

// ── Basic endpoint ─────────────────────────────────────────────────────
app.MapGet("/", () => new { message = "Hello from SimpleApi1!", env = app.Environment.EnvironmentName });

// ── Call SimpleApi2 (service-to-service) ──────────────────────────────
app.MapGet("/combined", async (IHttpClientFactory factory) =>
{
    try
    {
        var client = factory.CreateClient("SimpleApi2");
        var result = await client.GetFromJsonAsync<object>("/info");
        return Results.Ok(new { from_api1 = "SimpleApi1 data", from_api2 = result });
    }
    catch (Exception ex)
    {
        return Results.Problem($"Cannot reach SimpleApi2: {ex.Message}", statusCode: 503);
    }
});

// ── Info endpoint ──────────────────────────────────────────────────────
app.MapGet("/info", () => new
{
    service   = "simpleapi1",
    version   = "v1",
    pod       = Environment.GetEnvironmentVariable("HOSTNAME") ?? "local",
    node      = Environment.GetEnvironmentVariable("MY_NODE_NAME") ?? "local",
    namespace = Environment.GetEnvironmentVariable("MY_NAMESPACE") ?? "local"
});

app.MapHealthChecks("/health/live",  new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions { Predicate = _ => false });
app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions());

app.Run();
EOF

cd ~/aks-local

# ── Create SimpleApi2 (identical structure, different service name) ───
dotnet new webapi -n SimpleApi2 --use-minimal-apis -o SimpleApi2 --no-openapi
cat > SimpleApi2/Program.cs << 'EOF'
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();
var app = builder.Build();

app.MapGet("/health", () => Results.Ok(new { status = "healthy", service = "simpleapi2" }));
app.MapGet("/", () => new { message = "Hello from SimpleApi2!" });
app.MapGet("/info", () => new
{
    service   = "simpleapi2",
    version   = "v1",
    pod       = Environment.GetEnvironmentVariable("HOSTNAME") ?? "local",
    data      = new[] { "item1", "item2", "item3" }
});
app.MapHealthChecks("/health/live",  new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions { Predicate = _ => false });
app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions());
app.Run();
EOF
```

#### Dockerfiles
```dockerfile
# ~/aks-local/SimpleApi1/Dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY SimpleApi1.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
RUN adduser --disabled-password --no-create-home appuser && chown -R appuser /app
USER appuser
COPY --from=build /app/publish .
ENV ASPNETCORE_HTTP_PORTS=80
EXPOSE 80
ENTRYPOINT ["dotnet", "SimpleApi1.dll"]
```

```bash
# Copy same Dockerfile for SimpleApi2 (just change the dll name)
cp SimpleApi1/Dockerfile SimpleApi2/Dockerfile
sed -i 's/SimpleApi1.dll/SimpleApi2.dll/' SimpleApi2/Dockerfile
```

---

### 21.5 — Build & Load Images into minikube

```bash
# KEY INSIGHT: minikube runs in its own container/Docker context.
# Images built with your regular "docker/podman build" are NOT visible inside minikube.
# You must either:
#   A) Build directly inside minikube's daemon (eval $(minikube docker-env))
#   B) Use minikube image load after building
#   C) Use a local registry
```

---

#### Option A: Using Docker

```bash
# ── Recommended: Build directly in minikube's Docker daemon ───────────
eval $(minikube docker-env)
# This command sets DOCKER_HOST, DOCKER_CERT_PATH etc to point at minikube's daemon
# All subsequent docker commands go INTO minikube

cd ~/aks-local
docker build -t simpleapi1:v1 -f SimpleApi1/Dockerfile SimpleApi1/
docker build -t simpleapi2:v1 -f SimpleApi2/Dockerfile SimpleApi2/
# Sample Output (docker build -t simpleapi1:v1 ...):
# [+] Building 11.2s (12/12) FINISHED
# => [1/4] FROM mcr.microsoft.com/dotnet/aspnet:10.0    0.0s (cached)
# => [4/4] RUN dotnet publish -c Release -o /app/publish  6.9s
# => exporting to image                                    0.9s
# => naming to docker.io/library/simpleapi1:v1             0.0s

# Verify images exist inside minikube
docker images | grep simpleapi
# simpleapi1  v1  abc123  2 minutes ago  210MB
# simpleapi2  v1  def456  2 minutes ago  210MB

# CRITICAL: Set imagePullPolicy: Never in your deployments!
# (tells Kubernetes: don't try to pull from registry — use local image)

# Reset your terminal to use host Docker again
eval $(minikube docker-env -u)

# ── Alternative: Build locally then load into minikube ────────────────
docker build -t simpleapi1:v1 -f SimpleApi1/Dockerfile SimpleApi1/
minikube image load simpleapi1:v1

# Sample Output:
# ❗  This file does not exist in the host system. Will load from path...
# 📤  Loading image from path 'simpleapi1:v1'...
# ✅  Loaded image: simpleapi1:v1
```

---

#### Option B: Using Podman

```bash
# ── Option 1 (Recommended): Build directly in minikube's context ──────
# Set environment to use minikube's Podman/Docker daemon
eval $(minikube -p minikube podman-env)
# OR for PowerShell:
# & minikube -p minikube podman-env --shell powershell | Invoke-Expression

# This points Podman to minikube's container runtime
cd ~/aks-local
podman build -t simpleapi1:v1 -f SimpleApi1/Dockerfile SimpleApi1/
podman build -t simpleapi2:v1 -f SimpleApi2/Dockerfile SimpleApi2/
# Sample Output (podman build -t simpleapi1:v1 ...):
# STEP 1/8: FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
# STEP 2/8: WORKDIR /src
# STEP 3/8: COPY SimpleApi1.csproj .
# ...
# STEP 8/8: ENTRYPOINT ["dotnet", "SimpleApi1.dll"]
# COMMIT simpleapi1:v1
# Successfully tagged localhost/simpleapi1:v1

# Verify images exist inside minikube
podman images | grep simpleapi
# localhost/simpleapi1  v1  abc123  2 minutes ago  210MB
# localhost/simpleapi2  v1  def456  2 minutes ago  210MB

# CRITICAL: Set imagePullPolicy: Never in your deployments!
# (tells Kubernetes: don't try to pull from registry — use local image)

# Reset your terminal to use host Podman again
eval $(minikube podman-env -u)
# OR for PowerShell:
# & minikube podman-env -u --shell powershell | Invoke-Expression

# ── Option 2: Build locally then load into minikube ───────────────────
podman build -t simpleapi1:v1 -f SimpleApi1/Dockerfile SimpleApi1/
podman build -t simpleapi2:v1 -f SimpleApi2/Dockerfile SimpleApi2/

# Save image as tar archive
podman save simpleapi1:v1 -o simpleapi1.tar
podman save simpleapi2:v1 -o simpleapi2.tar

# Load into minikube
minikube image load simpleapi1.tar
minikube image load simpleapi2.tar
# OR use minikube's newer syntax:
minikube image load simpleapi1:v1
minikube image load simpleapi2:v1

# Sample Output:
# 📤  Loading image from path 'simpleapi1:v1'...
# ✅  Loaded image: simpleapi1:v1

# Verify images in minikube
minikube ssh -- crictl images | grep simpleapi
# localhost/simpleapi1  v1  abc123..  210MB
# localhost/simpleapi2  v1  def456..  210MB

# Clean up tar files
rm simpleapi1.tar simpleapi2.tar
```

> **Podman-Specific Tips:**
> - Podman stores images locally in your user context (rootless)
> - The `podman-env` command works similarly to `docker-env`
> - If using Docker alias (`Set-Alias docker podman`), you can use same commands as Docker
> - Images are OCI-compliant — fully compatible with Kubernetes/containerd
> - For PowerShell: Use `& minikube podman-env --shell powershell | Invoke-Expression`

---

### 21.6 — Namespace & Core Kubernetes Objects

```bash
# Create namespace
kubectl create namespace simple-apis
kubectl config set-context --current --namespace=simple-apis
# Now all kubectl commands default to simple-apis namespace
```

#### SimpleApi2 Deployment (deploy backend first)
```yaml
# ~/aks-local/k8s/simpleapi2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi2
  namespace: simple-apis
spec:
  replicas: 2
  selector:
    matchLabels:
      app: simpleapi2
  template:
    metadata:
      labels:
        app: simpleapi2
        version: v1
    spec:
      containers:
      - name: simpleapi2
        image: simpleapi2:v1
        imagePullPolicy: Never         # CRITICAL for local — never pull from registry
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_HTTP_PORTS
          value: "80"
        - name: MY_NODE_NAME           # Expose node name as env var (downwardAPI)
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health/live
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: simpleapi2-svc
  namespace: simple-apis
spec:
  type: ClusterIP
  selector:
    app: simpleapi2
  ports:
  - port: 80
    targetPort: 80
```

#### SimpleApi1 Deployment (frontend, calls SimpleApi2)
```yaml
# ~/aks-local/k8s/simpleapi1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1
  namespace: simple-apis
spec:
  replicas: 2
  selector:
    matchLabels:
      app: simpleapi1
  template:
    metadata:
      labels:
        app: simpleapi1
        version: v1
    spec:
      containers:
      - name: simpleapi1
        image: simpleapi1:v1
        imagePullPolicy: Never
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_HTTP_PORTS
          value: "80"
        - name: SIMPLEAPI2_URL
          value: "http://simpleapi2-svc.simple-apis.svc.cluster.local"
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: MY_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        resources:
          requests:
            cpu: "50m"
            memory: "64Mi"
          limits:
            cpu: "200m"
            memory: "256Mi"
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health/live
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-svc
  namespace: simple-apis
spec:
  type: ClusterIP
  selector:
    app: simpleapi1
  ports:
  - port: 80
    targetPort: 80
```

```bash
# Apply all manifests
kubectl apply -f k8s/simpleapi2.yaml
kubectl apply -f k8s/simpleapi1.yaml

# Verify pods are Running
kubectl get pods -n simple-apis -w
# NAME                          READY   STATUS    RESTARTS   AGE
# simpleapi1-xxx-1              1/1     Running   0          30s
# simpleapi1-xxx-2              1/1     Running   0          30s
# simpleapi2-xxx-1              1/1     Running   0          45s
# simpleapi2-xxx-2              1/1     Running   0          45s

# Verify service-to-service connectivity
kubectl exec -it $(kubectl get pod -l app=simpleapi1 -o name | head -1) -- \
  wget -qO- http://simpleapi2-svc/info
# {"service":"simpleapi2","version":"v1","pod":"simpleapi2-xxx-1",...}

# Test the /combined endpoint (calls SimpleApi2 internally)
kubectl exec -it $(kubectl get pod -l app=simpleapi1 -o name | head -1) -- \
  wget -qO- http://localhost/combined
# {"from_api1":"SimpleApi1 data","from_api2":{"service":"simpleapi2",...}}
```

---

### 21.7 — ConfigMap & Secret

```bash
# ── ConfigMap: non-sensitive configuration ────────────────────────────
kubectl create configmap simpleapi1-config \
  --from-literal=ENVIRONMENT=local-dev \
  --from-literal=LOG_LEVEL=Debug \
  --from-literal=FEATURE_FLAG_NEW_UI=true \
  -n simple-apis

# View ConfigMap
kubectl describe configmap simpleapi1-config -n simple-apis
# Data:
# ────
# ENVIRONMENT:  local-dev
# FEATURE_FLAG_NEW_UI:  true
# LOG_LEVEL:  Debug

# ── Secret: sensitive data ─────────────────────────────────────────────
kubectl create secret generic simpleapi1-secrets \
  --from-literal=DB_PASSWORD=SuperSecret123! \
  --from-literal=API_KEY=myapikey-abc-xyz \
  -n simple-apis

# Secrets are base64 encoded in etcd (NOT encrypted — for local this is fine)
kubectl get secret simpleapi1-secrets -o yaml
# data:
#   DB_PASSWORD: U3VwZXJTZWNyZXQxMjMh   ← base64("SuperSecret123!")
#   API_KEY: bXlhcGlrZXktYWJjLXh5eg==
```

```yaml
# Use ConfigMap + Secret in deployment
spec:
  template:
    spec:
      containers:
      - name: simpleapi1
        envFrom:
        - configMapRef:
            name: simpleapi1-config     # All ConfigMap keys become env vars
        - secretRef:
            name: simpleapi1-secrets    # All Secret keys become env vars
        # Or mount as files:
        volumeMounts:
        - name: config-volume
          mountPath: /app/config
          readOnly: true
      volumes:
      - name: config-volume
        configMap:
          name: simpleapi1-config
```

---

### 21.8 — Ingress (NGINX — replaces App Gateway/AGIC locally)

```bash
# minikube ingress addon was enabled at startup
# Verify NGINX Ingress Controller is running
kubectl get pods -n ingress-nginx
# NAME                                        READY   STATUS    RESTARTS
# ingress-nginx-controller-xxxxx              1/1     Running   0

# Get the minikube IP (your "external IP" locally)
minikube ip
# 192.168.49.2
```

```yaml
# ~/aks-local/k8s/ingress.yaml
# Path-based routing — same pattern as production Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-apis-ingress
  namespace: simple-apis
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /       # Strip prefix path
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx                               # Use the NGINX Ingress class
  rules:
  - host: simple-apis.local                            # Fake local hostname
    http:
      paths:
      - path: /api1(/|$)(.*)                           # /api1/* → simpleapi1
        pathType: ImplementationSpecific
        backend:
          service:
            name: simpleapi1-svc
            port:
              number: 80
      - path: /api2(/|$)(.*)                           # /api2/* → simpleapi2
        pathType: ImplementationSpecific
        backend:
          service:
            name: simpleapi2-svc
            port:
              number: 80
```

```bash
kubectl apply -f k8s/ingress.yaml

# Add entry to hosts file (so browser resolves simple-apis.local)
# On Windows — run as Administrator:
echo "$(minikube ip) simple-apis.local" >> C:\Windows\System32\drivers\etc\hosts
# On Mac/Linux:
echo "$(minikube ip) simple-apis.local" | sudo tee -a /etc/hosts

# Test routing
curl http://simple-apis.local/api1/info
# {"service":"simpleapi1","version":"v1",...}

curl http://simple-apis.local/api1/combined
# {"from_api1":"SimpleApi1 data","from_api2":{"service":"simpleapi2",...}}

curl http://simple-apis.local/api2/info
# {"service":"simpleapi2","data":["item1","item2","item3"]}
```

---

### 21.9 — Persistent Volumes (Local Storage)

```bash
# minikube provides a built-in StorageClass using hostPath
kubectl get storageclass
# NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE
# standard (default)   k8s.io/minikube-hostpath   Delete          Immediate
```

```yaml
# ~/aks-local/k8s/pvc.yaml
# PVC using minikube's default storageclass (local hostPath)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: api-data-pvc
  namespace: simple-apis
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard     # minikube's default (equivalent to managed-csi on AKS)
  resources:
    requests:
      storage: 1Gi

---
# Pod using the PVC
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1-with-storage
  namespace: simple-apis
spec:
  replicas: 1                    # RWO = only 1 pod
  selector:
    matchLabels:
      app: simpleapi1-storage
  template:
    metadata:
      labels:
        app: simpleapi1-storage
    spec:
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: api-data-pvc
      containers:
      - name: simpleapi1
        image: simpleapi1:v1
        imagePullPolicy: Never
        volumeMounts:
        - name: data
          mountPath: /app/data
```

```bash
kubectl apply -f k8s/pvc.yaml

kubectl get pvc -n simple-apis
# NAME           STATUS   VOLUME                     CAPACITY   ACCESS MODES
# api-data-pvc   Bound    pvc-abc123-...             1Gi        RWO

# Write data to persistent volume
kubectl exec -it deploy/simpleapi1-with-storage -- \
  sh -c "echo 'hello from pod' > /app/data/test.txt"

# Delete and recreate pod — data persists!
kubectl rollout restart deployment/simpleapi1-with-storage
kubectl exec -it deploy/simpleapi1-with-storage -- cat /app/data/test.txt
# hello from pod   ← still there after pod restart!
```

---

### 21.10 — HPA (Horizontal Pod Autoscaler) — Load Test

```yaml
# ~/aks-local/k8s/hpa.yaml
# metrics-server addon was enabled at start — required for HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: simpleapi1-hpa
  namespace: simple-apis
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: simpleapi1
  minReplicas: 2
  maxReplicas: 8                 # Lower max for local (limited resources)
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50   # Scale when avg CPU > 50%
```

```bash
kubectl apply -f k8s/hpa.yaml

# Watch HPA status (open in a separate terminal)
kubectl get hpa -n simple-apis -w

# ── Generate load to trigger scaling ────────────────────────────────────
# Run a load generator pod
kubectl run load-gen \
  --image=busybox:latest \
  --restart=Never \
  -n simple-apis \
  -- sh -c "while true; do wget -q -O- http://simpleapi1-svc/info; done"

# Watch HPA react (in original terminal):
# NAME            REFERENCE             TARGETS    MINPODS  MAXPODS  REPLICAS
# simpleapi1-hpa  Deployment/simpleapi1 8%/50%     2        8        2
# simpleapi1-hpa  Deployment/simpleapi1 72%/50%    2        8        3    ← scaling up!
# simpleapi1-hpa  Deployment/simpleapi1 91%/50%    2        8        5

# Stop the load generator
kubectl delete pod load-gen -n simple-apis

# HPA scales back down after 5 minutes (stabilizationWindow)
# simpleapi1-hpa  Deployment/simpleapi1 2%/50%     2        8        2    ← scaled down
```

---

### 21.11 — KEDA (Event-Driven Autoscaling) Locally

```bash
# Install KEDA via Helm
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

helm install keda kedacore/keda \
  --namespace keda \
  --create-namespace \
  --wait

# Verify KEDA pods
kubectl get pods -n keda
# NAME                                      READY   STATUS
# keda-operator-xxx                         1/1     Running
# keda-operator-metrics-apiserver-xxx       1/1     Running
```

```yaml
# KEDA: Scale based on HTTP request count (KEDA HTTP Add-on) or Prometheus metric
# For local practice, use the CPU scaler as a simple trigger
# Or use the cron scaler (no external dependencies needed)

# ~/aks-local/k8s/keda-scaledobject.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: simpleapi1-keda
  namespace: simple-apis
spec:
  scaleTargetRef:
    name: simpleapi1
  minReplicaCount: 0             # Scale to ZERO when no activity! (cost saving)
  maxReplicaCount: 5
  cooldownPeriod: 60             # Wait 60s before scaling down to 0
  triggers:
  # ── Cron trigger: scale up during business hours, scale to 0 at night ──
  - type: cron
    metadata:
      timezone: "America/New_York"
      start: "0 9 * * 1-5"      # Scale to 2 replicas at 9am Mon-Fri
      end:   "0 18 * * 1-5"     # Scale to 0 at 6pm
      desiredReplicas: "2"
  # ── CPU trigger: scale beyond 2 if CPU is high ──────────────────────
  - type: cpu
    metricType: Utilization
    metadata:
      value: "50"
```

```bash
kubectl apply -f k8s/keda-scaledobject.yaml

kubectl get scaledobject -n simple-apis
# NAME               SCALETARGETKIND   SCALETARGETNAME   MIN   MAX   TRIGGERS
# simpleapi1-keda    apps/Deployment   simpleapi1        0     5     cron,cpu

# Watch pods go to 0 outside business hours
kubectl get pods -n simple-apis -w
```

---

### 21.12 — Helm: Package Manager End-to-End

```bash
# ── Add popular Helm repos ────────────────────────────────────────────
helm repo add stable      https://charts.helm.sh/stable
helm repo add bitnami     https://charts.bitnami.com/bitnami
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# ── Create a Helm chart for SimpleApi1 ────────────────────────────────
helm create simple-apis-chart
cd simple-apis-chart

# Default structure created:
# simple-apis-chart/
# ├── Chart.yaml           ← Chart metadata
# ├── values.yaml          ← Default values (overridable per environment)
# ├── charts/              ← Sub-charts (dependencies)
# └── templates/
#     ├── deployment.yaml  ← Deployment template (uses {{ .Values.xxx }})
#     ├── service.yaml
#     ├── ingress.yaml
#     ├── hpa.yaml
#     ├── _helpers.tpl     ← Named templates (reusable snippets)
#     └── NOTES.txt        ← Post-install notes
```

#### Chart.yaml
```yaml
# simple-apis-chart/Chart.yaml
apiVersion: v2
name: simple-apis-chart
description: SimpleApi1 and SimpleApi2 AKS practice chart
type: application
version: 0.1.0              # Chart version (bump on chart changes)
appVersion: "v1"            # Application version
```

#### values.yaml
```yaml
# simple-apis-chart/values.yaml
# Default values — override with: helm install -f myvalues.yaml OR --set key=value

replicaCount: 2

image:
  repository: simpleapi1
  tag: v1
  pullPolicy: Never          # Never pull — use local image in minikube

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  host: simple-apis.local
  path: /api1

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 8
  targetCPUUtilizationPercentage: 50

simpleapi2:
  url: "http://simpleapi2-svc.simple-apis.svc.cluster.local"

env:
  MY_NODE_NAME:
    fieldRef: spec.nodeName
```

#### templates/deployment.yaml
```yaml
# simple-apis-chart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "simple-apis-chart.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "simple-apis-chart.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}   {{/* Only set replicas if HPA is disabled */}}
  {{- end }}
  selector:
    matchLabels:
      {{- include "simple-apis-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "simple-apis-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80
        env:
        - name: ASPNETCORE_HTTP_PORTS
          value: "80"
        - name: SIMPLEAPI2_URL
          value: {{ .Values.simpleapi2.url | quote }}
        - name: MY_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health/live
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
```

#### templates/hpa.yaml
```yaml
# simple-apis-chart/templates/hpa.yaml
{{- if .Values.autoscaling.enabled }}    {{/* Only create HPA if enabled in values */}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "simple-apis-chart.fullname" . }}-hpa
  namespace: {{ .Release.Namespace }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "simple-apis-chart.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
```

#### templates/_helpers.tpl
```
{{/*
  _helpers.tpl — reusable named templates
  Called with: {{ include "simple-apis-chart.fullname" . }}
*/}}

{{/* Expand the name of the chart */}}
{{- define "simple-apis-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a default fully qualified app name */}}
{{- define "simple-apis-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/* Common labels for all objects */}}
{{- define "simple-apis-chart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "simple-apis-chart.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels — used in matchLabels */}}
{{- define "simple-apis-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "simple-apis-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

```bash
# ── Lint the chart (catch YAML errors before install) ─────────────────
helm lint simple-apis-chart/
# ==> Linting simple-apis-chart/
# [INFO] Chart.yaml: icon is recommended
# 1 chart(s) linted, 0 chart(s) failed

# ── Dry-run: preview generated YAML without applying ─────────────────
helm install simple-apis simple-apis-chart/ \
  --namespace simple-apis \
  --dry-run --debug 2>&1 | head -80

# ── Install the chart ─────────────────────────────────────────────────
helm install simple-apis simple-apis-chart/ \
  --namespace simple-apis \
  --create-namespace \
  --set image.repository=simpleapi1 \
  --set image.tag=v1

# Sample Output:
# NAME: simple-apis
# LAST DEPLOYED: Wed Feb 26 10:15:00 2026
# NAMESPACE: simple-apis
# STATUS: deployed
# REVISION: 1

# ── List releases ─────────────────────────────────────────────────────
helm list -n simple-apis
# NAME          NAMESPACE    REVISION  STATUS    CHART                   APP VERSION
# simple-apis   simple-apis  1         deployed  simple-apis-chart-0.1.0 v1

# ── Upgrade (new image version) ───────────────────────────────────────
helm upgrade simple-apis simple-apis-chart/ \
  -n simple-apis \
  --set image.tag=v2 \
  --atomic \             # Rollback automatically if upgrade fails
  --timeout 5m

# ── Override with environment-specific values ─────────────────────────
cat > values-prod.yaml << 'EOF'
replicaCount: 5
resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 512Mi
autoscaling:
  maxReplicas: 20
EOF

helm upgrade simple-apis simple-apis-chart/ -n simple-apis -f values-prod.yaml

# ── Rollback to previous revision ────────────────────────────────────
helm rollback simple-apis 1 -n simple-apis
# Rollback was a success! Happy Helming!

# ── View history ─────────────────────────────────────────────────────
helm history simple-apis -n simple-apis
# REVISION  STATUS      DESCRIPTION
# 1         superseded  Install complete
# 2         superseded  Upgrade complete
# 3         deployed    Rollback to 1

# ── Uninstall ────────────────────────────────────────────────────────
helm uninstall simple-apis -n simple-apis
```

---

### 21.13 — Prometheus & Grafana via Helm (Local Monitoring)

```bash
# ── Install kube-prometheus-stack (Prometheus + Grafana + Alertmanager) ─
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.retention=2d \    # Keep 2 days of data locally
  --wait \
  --timeout 10m

# Sample Output:
# NAME: monitoring
# STATUS: deployed
# NOTES:
#   Get Grafana admin password: kubectl get secret ... -o jsonpath=...
#   Get Grafana URL: kubectl port-forward svc/monitoring-grafana 3000:80

# ── Check what got installed ─────────────────────────────────────────
kubectl get pods -n monitoring
# NAME                                                    READY   STATUS
# alertmanager-monitoring-kube-prometheus-alertmanager-0  2/2     Running
# monitoring-grafana-xxx                                  3/3     Running
# monitoring-kube-prometheus-operator-xxx                 1/1     Running
# monitoring-kube-state-metrics-xxx                       1/1     Running
# monitoring-prometheus-node-exporter-xxx                 1/1     Running (DaemonSet)
# prometheus-monitoring-kube-prometheus-prometheus-0      2/2     Running

# ── Access Grafana dashboard ──────────────────────────────────────────
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
# Open browser: http://localhost:3000
# Username: admin   Password: admin123
#
# Pre-built dashboards to explore:
#   - Kubernetes / Compute Resources / Cluster
#   - Kubernetes / Compute Resources / Namespace (Pods)
#   - Kubernetes / Networking / Namespace (Pods)
#   - Node Exporter / USE Method / Node

# ── Access Prometheus UI ──────────────────────────────────────────────
kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring
# Open browser: http://localhost:9090
# Try PromQL queries:
#   container_memory_working_set_bytes{namespace="simple-apis"}
#   rate(container_cpu_usage_seconds_total{namespace="simple-apis"}[5m])
#   kube_pod_container_status_restarts_total{namespace="simple-apis"}
```

#### Custom PrometheusRule Alert
```yaml
# ~/aks-local/k8s/prometheus-alert.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: simple-apis-alerts
  namespace: monitoring
  labels:
    # These labels tell the Prometheus operator to load this rule
    release: monitoring          # Must match helm release name
    app: kube-prometheus-stack
spec:
  groups:
  - name: simple-apis
    rules:
    - alert: HighRestartCount
      expr: |
        rate(kube_pod_container_status_restarts_total{
          namespace="simple-apis"
        }[15m]) * 60 * 15 > 3
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.pod }} restarted > 3 times in 15m"
```

---

### 21.14 — ArgoCD (GitOps) Locally

```bash
# ── Install ArgoCD ────────────────────────────────────────────────────
kubectl create namespace argocd
kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available deployment/argocd-server \
  -n argocd --timeout=5m

# ── Get admin password ─────────────────────────────────────────────────
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
# Output: XYZrandom123   ← initial password

# ── Port-forward ArgoCD UI ─────────────────────────────────────────────
kubectl port-forward svc/argocd-server 8080:443 -n argocd
# Open browser: https://localhost:8080
# Username: admin   Password: (from above)
```

#### Create ArgoCD Application (pointing to local Git repo)
```bash
# Initialize a local git repo with your k8s manifests
cd ~/aks-local
git init
git add k8s/
git commit -m "Initial k8s manifests"

# For ArgoCD to sync a local repo, use a file:// URL
# Or push to GitHub and use that URL
```

```yaml
# ~/aks-local/argocd-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: simple-apis
  namespace: argocd              # Application lives in argocd namespace
  finalizers:
  - resources-finalizer.argocd.argoproj.io   # Delete K8s resources when app deleted
spec:
  project: default
  source:
    # For GitHub (recommended for real GitOps practice):
    repoURL: https://github.com/yourusername/aks-local
    targetRevision: main
    path: k8s                   # Deploy all manifests in this folder

    # For Helm chart in Git:
    # helm:
    #   valueFiles:
    #   - values.yaml

  destination:
    server: https://kubernetes.default.svc    # Local cluster
    namespace: simple-apis

  syncPolicy:
    automated:
      prune: true               # Delete resources removed from Git
      selfHeal: true            # Revert manual kubectl changes
    syncOptions:
    - CreateNamespace=true      # Auto-create namespace if missing
```

```bash
kubectl apply -f argocd-app.yaml

# Check sync status
kubectl get applications -n argocd
# NAME          SYNC STATUS   HEALTH STATUS
# simple-apis   Synced        Healthy

# Watch ArgoCD detect a change:
# 1. Edit k8s/simpleapi1.yaml (change replicas: 2 to replicas: 3)
# 2. git add . && git commit -m "Scale to 3" && git push
# 3. ArgoCD detects change within 3 minutes (or click "Sync" in UI)
# 4. kubectl get pods -n simple-apis   → shows 3 pods!
```

---

### 21.15 — Network Policies Locally (Calico)

```bash
# minikube uses kindnet CNI by default (no network policy support)
# Restart minikube with Calico CNI for network policy support

minikube stop
minikube start \
  --driver=docker \
  --cpus=4 \
  --memory=8192 \
  --cni=calico \               # Calico supports NetworkPolicy
  --addons=ingress,metrics-server

# Verify Calico is running
kubectl get pods -n kube-system | grep calico
# calico-kube-controllers-xxx    1/1   Running
# calico-node-xxx                1/1   Running (DaemonSet on each node)
```

```yaml
# Default-deny all ingress in namespace (zero-trust model)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: simple-apis
spec:
  podSelector: {}               # Applies to ALL pods
  policyTypes:
  - Ingress                     # Block all inbound

---
# Allow only simpleapi1 to call simpleapi2
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api1-to-api2
  namespace: simple-apis
spec:
  podSelector:
    matchLabels:
      app: simpleapi2           # Policy for simpleapi2 pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: simpleapi1       # Only simpleapi1 pods can call
    ports:
    - protocol: TCP
      port: 80
```

```bash
kubectl apply -f k8s/network-policy.yaml

# Test: simpleapi1 can reach simpleapi2 (should work)
kubectl exec -it $(kubectl get pod -l app=simpleapi1 -o name | head -1) -- \
  wget -qO- http://simpleapi2-svc/info
# {"service":"simpleapi2",...}   ← success

# Test: random pod CANNOT reach simpleapi2 (blocked by NetworkPolicy)
kubectl run test-blocked --image=busybox --restart=Never -n simple-apis -- \
  wget --timeout=5 -O- http://simpleapi2-svc/info
kubectl logs test-blocked -n simple-apis
# wget: download timed out   ← correctly blocked!
kubectl delete pod test-blocked -n simple-apis
```

---

### 21.16 — StatefulSet with Local Storage

```yaml
# ~/aks-local/k8s/statefulset.yaml
# Simulates a database with per-pod storage
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: localdb
  namespace: simple-apis
spec:
  serviceName: localdb-headless   # Headless service for stable DNS
  replicas: 2
  selector:
    matchLabels:
      app: localdb
  template:
    metadata:
      labels:
        app: localdb
    spec:
      containers:
      - name: db
        image: busybox:latest
        command: ["sh", "-c", "while true; do echo $(date) >> /data/log.txt; sleep 5; done"]
        volumeMounts:
        - name: data
          mountPath: /data
  # Each pod gets its own PVC automatically:
  # localdb-0 → data-localdb-0
  # localdb-1 → data-localdb-1
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ReadWriteOnce]
      storageClassName: standard   # minikube's default
      resources:
        requests:
          storage: 100Mi

---
apiVersion: v1
kind: Service
metadata:
  name: localdb-headless
  namespace: simple-apis
spec:
  clusterIP: None                 # Headless = no ClusterIP; DNS returns pod IPs directly
  selector:
    app: localdb
  ports:
  - port: 80
```

```bash
kubectl apply -f k8s/statefulset.yaml

kubectl get statefulset -n simple-apis
# NAME      READY   AGE
# localdb   2/2     1m

# Each pod has stable DNS name:
# localdb-0.localdb-headless.simple-apis.svc.cluster.local
# localdb-1.localdb-headless.simple-apis.svc.cluster.local

kubectl exec localdb-0 -n simple-apis -- cat /data/log.txt
# Thu Feb 26 10:00:00 UTC 2026
# Thu Feb 26 10:00:05 UTC 2026

# Delete pod — it comes back with SAME name and SAME storage
kubectl delete pod localdb-0 -n simple-apis
kubectl get pods -n simple-apis | grep localdb
# localdb-0   1/1   Running   0   15s    ← back with same name!

kubectl exec localdb-0 -n simple-apis -- cat /data/log.txt
# Thu Feb 26 10:00:00 UTC 2026   ← old data still there
# Thu Feb 26 10:02:30 UTC 2026   ← new data after restart
```

---

### 21.17 — DaemonSet (Runs on Every Node)

```yaml
# ~/aks-local/k8s/daemonset.yaml
# Simulates a node-level log collector (like Fluent Bit in production)
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-logger
  namespace: simple-apis
spec:
  selector:
    matchLabels:
      app: node-logger
  template:
    metadata:
      labels:
        app: node-logger
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule         # Run on control-plane node too
      containers:
      - name: logger
        image: busybox:latest
        command: ["sh", "-c", "while true; do echo [$(date)] Node: $MY_NODE; sleep 10; done"]
        env:
        - name: MY_NODE
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        volumeMounts:
        - name: node-logs
          mountPath: /host-logs
          readOnly: true
      volumes:
      - name: node-logs
        hostPath:
          path: /var/log
          type: Directory
```

```bash
kubectl apply -f k8s/daemonset.yaml

kubectl get daemonset -n simple-apis
# NAME          DESIRED   CURRENT   READY   NODE SELECTOR
# node-logger   2         2         2       <none>
# ↑ 2 = one pod per node (minikube has 2 nodes)

kubectl get pods -n simple-apis -l app=node-logger -o wide
# NAME               READY  STATUS    NODE
# node-logger-abc    1/1    Running   minikube       ← on node 1
# node-logger-def    1/1    Running   minikube-m02   ← on node 2
```

---

### 21.18 — RBAC: Local Practice

```yaml
# Create a read-only role for a developer who can only view pods/logs
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-viewer
  namespace: simple-apis

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: simple-apis
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]   # Read-only: get, list, watch (NOT create/delete)
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-viewer-binding
  namespace: simple-apis
subjects:
- kind: ServiceAccount
  name: dev-viewer
  namespace: simple-apis
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f k8s/rbac.yaml

# Test: Use the ServiceAccount to run a pod and verify permissions
kubectl run rbac-test \
  --image=bitnami/kubectl:latest \
  --restart=Never \
  --serviceaccount=dev-viewer \
  -n simple-apis \
  --command -- sleep 3600

# Can read pods (allowed)
kubectl exec rbac-test -n simple-apis -- kubectl get pods
# NAME            READY   STATUS   RESTARTS
# simpleapi1-xxx  1/1     Running  0

# Cannot delete pods (forbidden)
kubectl exec rbac-test -n simple-apis -- \
  kubectl delete pod simpleapi1-xxx
# Error from server (Forbidden): pods "simpleapi1-xxx" is forbidden:
# User "system:serviceaccount:simple-apis:dev-viewer" cannot delete resource "pods"

kubectl delete pod rbac-test -n simple-apis
```

---

### 21.19 — Full Cleanup & Restart Script

```bash
#!/bin/bash
# ~/aks-local/scripts/reset.sh
# Tear down everything and start fresh

echo "=== Deleting all resources in simple-apis namespace ==="
kubectl delete namespace simple-apis --ignore-not-found

echo "=== Removing Helm releases ==="
helm uninstall simple-apis -n simple-apis 2>/dev/null || true
helm uninstall monitoring -n monitoring 2>/dev/null || true
helm uninstall keda -n keda 2>/dev/null || true

echo "=== Stopping minikube ==="
minikube stop

echo "=== Deleting minikube cluster (full reset) ==="
minikube delete

echo "=== Done. Run: minikube start to begin fresh ==="
```

---

### 21.20 — Feature Coverage Map: Local vs Cloud

| AKS Feature | Local Tool | Cloud Equivalent | Notes |
|------------|-----------|------------------|-------|
| Container runtime | containerd (minikube) | containerd (AKS) | Identical |
| Ingress | NGINX Ingress (minikube addon) | AGIC / NGINX on AKS | Same YAML |
| Persistent Volumes | hostPath (minikube) | Azure Disk CSI | Same PVC API |
| Shared Volumes | hostPath RWX trick | Azure Files CSI | Limited locally |
| HPA | metrics-server addon | Azure Monitor metrics | Identical behavior |
| KEDA | Helm install | AKS add-on | Identical |
| Network Policy | Calico (restart with --cni=calico) | Azure CNI Cilium | Same K8s API |
| RBAC | kubectl apply | Azure RBAC + K8s RBAC | Identical K8s RBAC |
| Secrets | K8s Secrets | Azure Key Vault CSI | No KV locally |
| Monitoring | Prometheus + Grafana (Helm) | Azure Monitor + Managed Grafana | Same dashboards |
| GitOps | ArgoCD (Helm) | ArgoCD or Flux | Identical |
| StatefulSet | minikube storageclass | managed-premium-csi | Same YAML |
| DaemonSet | hostPath /var/log | Azure Monitor agent | Same YAML |
| LoadBalancer service | minikube tunnel | Azure Load Balancer | Same behavior |
| Multi-tenancy | Namespaces + ResourceQuota | Same | Identical |
| Service Mesh | Istio (Helm) | Istio AKS add-on | Same CRDs |

```bash
# ── Extra: Enable LoadBalancer type services locally ──────────────────
# In a second terminal, run:
minikube tunnel
# This creates a network route so LoadBalancer services get a real IP
# Sample Output:
# Status: Running
# machine: minikube
# pid: 12345
# route: 10.96.0.0/12 -> 192.168.49.2
# minikube: Running
# services: [simpleapi1-lb]
#   namespace   name              loadbalancer-ip  ports
#   simple-apis simpleapi1-lb     10.100.0.10      80

# Now LoadBalancer services work like in real AKS!
kubectl expose deployment simpleapi1 \
  --type=LoadBalancer --port=80 --name=simpleapi1-lb -n simple-apis
kubectl get svc simpleapi1-lb -n simple-apis
# NAME            TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)
# simpleapi1-lb   LoadBalancer   10.100.0.10   10.100.0.10   80:xxxxx/TCP
curl http://10.100.0.10/info
```

---

### 21.21 — Quick Reference: All Local Commands in Order

```bash
# ═══════════════════════════════════════════════════════════════════
#  COMPLETE LOCAL AKS SETUP — SEQUENCE OF COMMANDS
# ═══════════════════════════════════════════════════════════════════

# 1. Start cluster
minikube start --driver=docker --cpus=4 --memory=8192 \
  --nodes=2 --addons=ingress,metrics-server,dashboard

# 2. Build images inside minikube
eval $(minikube docker-env)
docker build -t simpleapi1:v1 -f SimpleApi1/Dockerfile SimpleApi1/
# Sample Output:
# [+] Building 11.2s (12/12) FINISHED
# => [1/4] FROM mcr.microsoft.com/dotnet/aspnet:10.0    0.0s (cached)
# => [4/4] RUN dotnet publish -c Release -o /app/publish  6.9s
# => naming to docker.io/library/simpleapi1:v1             0.0s
docker build -t simpleapi2:v1 -f SimpleApi2/Dockerfile SimpleApi2/
# Sample Output:
# [+] Building 10.8s (12/12) FINISHED
# => [1/4] FROM mcr.microsoft.com/dotnet/aspnet:10.0    0.0s (cached)
# => [4/4] RUN dotnet publish -c Release -o /app/publish  6.6s
# => naming to docker.io/library/simpleapi2:v1             0.0s
eval $(minikube docker-env -u)

# 3. Create namespace and deploy
kubectl create namespace simple-apis
kubectl apply -f k8s/ -n simple-apis

# 4. Install Helm chart
helm install simple-apis ./simple-apis-chart -n simple-apis

# 5. Install monitoring
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace --set grafana.adminPassword=admin123

# 6. Install KEDA
helm install keda kedacore/keda -n keda --create-namespace

# 7. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 8. Access services
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring &
kubectl port-forward svc/argocd-server 8080:443 -n argocd &
minikube dashboard &             # Kubernetes Dashboard
minikube tunnel &                # Enable LoadBalancer IPs

# 9. Verify everything
kubectl get all -n simple-apis
kubectl get all -n monitoring
kubectl get all -n keda
kubectl get all -n argocd

echo "Simple API: http://simple-apis.local/api1/info"
echo "Grafana:    http://localhost:3000"
echo "ArgoCD:     https://localhost:8080"
echo "Dashboard:  (opens in browser)"
```

---

---

## PART 22: Merged Insights — Unique Content from Reference Guide

> This part captures patterns and guidance unique to the companion reference file that enrich this guide with different angles, additional .NET integration patterns, and practical quick-reference formats.

---

### 22.1 — YAML Files Quick Index (Orientation Map)

> **Mental model:** Before writing any YAML, know what role it plays. Every Kubernetes file addresses exactly one concern. This table is your map.

| File | Kind(s) | Concern | Configures |
|------|---------|---------|-----------|
| `k8s-simpleapi1.yaml` | Deployment + Service | Workload + Networking | Pods, replicas, ClusterIP |
| `k8s-simpleapi2.yaml` | Deployment + Service | Workload + Networking | Backend service pods |
| `k8s-ingress.yaml` | Ingress | External HTTP routing | Path `/api1` → api1-svc, `/api2` → api2-svc |
| `k8s-config.yaml` | ConfigMap | Non-sensitive config | Feature flags, app names, log levels |
| `k8s-secrets.yaml` | Secret | Sensitive config | Connection strings, API keys |
| `k8s-hpa.yaml` | HorizontalPodAutoscaler | Scaling | CPU/Memory-based auto-scale |
| `k8s-pvc.yaml` | PVC + StorageClass | Storage | Durable disk for uploads/data |
| `k8s-networkpolicy.yaml` | NetworkPolicy | Security | Which pods can talk to which |
| `k8s-rbac.yaml` | ServiceAccount + Role + RoleBinding | Access Control | Who can do what in namespace |
| `k8s-pdb.yaml` | PodDisruptionBudget | Reliability | Min pods during node drain/upgrade |

```
Deployment (replicas, image, probes, resources)
    └── controlled by HPA (scale replicas based on CPU/memory)
    └── selected by Service (stable IP/DNS → pods)
              └── routed by Ingress (HTTP paths → service)
    └── reads ConfigMap + Secret (env vars / file mounts)
    └── mounts PVC (durable storage)
    └── runs as ServiceAccount (workload identity for Azure access)
    └── governed by NetworkPolicy (which pods can reach it)
    └── protected by PodDisruptionBudget (safe during upgrades)
```

---

### 22.2 — .NET API-Level Authentication with Entra ID (JWT Bearer)

> **Context:** Kubernetes RBAC controls cluster access. Workload Identity controls Azure resource access. But **who can call your API endpoints** is controlled inside your .NET app using JWT tokens from Entra ID. These are three distinct, independent layers.

```
Layer 1 (Cluster level):   Kubernetes RBAC + Workload Identity
Layer 2 (Application level): Entra ID JWT Bearer   ← this section
                              → Controls which callers can hit which endpoints

Client → "Authorization: Bearer <JWT>" → NGINX Ingress → SimpleApi1
                                                   ↓
                                       ASP.NET Core JwtBearer middleware
                                       validates token against Entra ID
                                                   ↓
                                       [Authorize] attribute on endpoints
```

```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

```csharp
// Program.cs — Entra ID JWT Bearer auth for a .NET minimal API
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // Entra ID v2 token issuer for your tenant
        // TenantId injected via env var (ConfigMap) — not hardcoded
        options.Authority =
            $"https://login.microsoftonline.com/{builder.Configuration["AzureAd:TenantId"]}/v2.0";

        options.TokenValidationParameters = new TokenValidationParameters
        {
            // API's App ID URI or Client ID registered in Entra ID
            ValidAudience = builder.Configuration["AzureAd:ClientId"],
            ValidateLifetime = true,
            ValidateIssuer  = true       // Prevent cross-tenant token reuse
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddHealthChecks();

var app = builder.Build();

// UseAuthentication BEFORE UseAuthorization — order matters!
app.UseAuthentication();
app.UseAuthorization();

// Public — no token required
app.MapGet("/health", () => Results.Ok(new { status = "healthy" }));

// Protected — must present valid Entra ID JWT
app.MapGet("/secure-data", () =>
    Results.Ok(new { secret = "sensitive data", ts = DateTime.UtcNow }))
    .RequireAuthorization();

// Role-protected — token must have "Admin" role claim
app.MapGet("/admin-only", (HttpContext ctx) =>
{
    var caller = ctx.User.FindFirst("preferred_username")?.Value;
    return Results.Ok(new { message = $"Hello admin: {caller}" });
})
.RequireAuthorization(p => p.RequireRole("Admin"));

app.Run();
```

```yaml
# Inject Entra ID config via Secret (never hardcode tenant/client IDs in images)
env:
- name: AzureAd__TenantId
  valueFrom:
    secretKeyRef:
      name: entra-config
      key: tenantId
- name: AzureAd__ClientId
  valueFrom:
    secretKeyRef:
      name: entra-config
      key: clientId
```

```bash
# Test with a real Entra ID token
TOKEN=$(az account get-access-token --resource "api://<YOUR_CLIENT_ID>" --query accessToken -o tsv)
curl -H "Authorization: Bearer $TOKEN" http://$INGRESS_IP/api1/secure-data
# 200: {"secret":"sensitive data",...}

curl http://$INGRESS_IP/api1/secure-data   # No token
# 401 Unauthorized
```

---

### 22.3 — Application Insights Full Integration for .NET on AKS

> `kubectl logs` shows raw stdout. Application Insights gives you request durations, dependency calls (DB, downstream APIs), exceptions with stack traces, and custom events — all queryable in Azure Portal.

```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Auto-reads APPLICATIONINSIGHTS_CONNECTION_STRING env var
// OR builder.Configuration["ApplicationInsights:ConnectionString"]
builder.Services.AddApplicationInsightsTelemetry();

var app = builder.Build();

// AI automatically tracks:
//   HTTP requests (URL, duration, status) → "requests" table
//   Exceptions (stack traces)             → "exceptions" table
//   Downstream HTTP calls                 → "dependencies" table
//   ILogger entries                       → "traces" table

app.MapGet("/hello/{name?}", (string? name, ILogger<Program> logger) =>
{
    // This log line appears in App Insights "traces" with Property "Name"
    logger.LogInformation("Handling /hello for {Name}", name ?? "World");
    return Results.Ok(new { message = $"Hello, {name ?? "World"}!" });
});

app.Run();
```

```yaml
# Deployment env var — connection string from Key Vault Secret
env:
- name: APPLICATIONINSIGHTS_CONNECTION_STRING
  valueFrom:
    secretKeyRef:
      name: app-secrets
      key: ai-connection-string
```

#### KQL Queries for App Insights

```kusto
// Failed requests in last 1 hour
requests
| where timestamp > ago(1h)
| where success == false
| where cloud_RoleName == "simpleapi1"
| project timestamp, name, duration, resultCode, operation_Id
| order by timestamp desc

// P95 latency by endpoint
requests
| where timestamp > ago(1h)
| where cloud_RoleName == "simpleapi1"
| summarize avg(duration), percentile(duration, 95), count() by name
| order by percentile_duration_95 desc

// Exceptions with full details
exceptions
| where timestamp > ago(1h)
| where cloud_RoleName == "simpleapi1"
| project timestamp, type, outerMessage, innermostMessage, operation_Id
| take 20

// Downstream service call latency (SimpleApi1 → SimpleApi2)
dependencies
| where timestamp > ago(1h)
| where cloud_RoleName == "simpleapi1"
| summarize avg(duration), countif(success==false) by target, name

// Log volume by severity (for cost monitoring)
traces
| where timestamp > ago(24h)
| where cloud_RoleName == "simpleapi1"
| summarize count() by severityLevel
```

---

### 22.4 — Structured Logging with ILogger in .NET Minimal API

> **Why it matters:** Unstructured text in logs is unsearchable. Structured logs with `{PropertyName}` placeholders become queryable columns in Log Analytics.

```csharp
// Program.cs — Structured logging setup for AKS
var builder = WebApplication.CreateBuilder(args);

builder.Logging.ClearProviders();
builder.Logging.AddConsole(o => o.FormatterName = "json");  // JSON = parseable by Azure Monitor

// Reduce noise (and cost!) in production
builder.Logging.SetMinimumLevel(
    builder.Environment.IsProduction() ? LogLevel.Warning : LogLevel.Information);

var app = builder.Build();

app.MapGet("/hello/{name?}", (string? name, ILogger<Program> logger) =>
{
    var n = name ?? "World";

    // {Name} and {PodName} become SEARCHABLE PROPERTIES in Log Analytics:
    // ContainerLogV2 | where Properties.Name == "Alice"
    logger.LogInformation("Handling /hello for {Name} on pod {PodName}",
        n,
        Environment.GetEnvironmentVariable("HOSTNAME"));  // K8s sets this to pod name

    return Results.Ok(new { message = $"Hello, {n}!" });
});

app.MapGet("/process", async (ILogger<Program> logger) =>
{
    var sw = System.Diagnostics.Stopwatch.StartNew();
    try
    {
        await Task.Delay(10);  // simulate work
        logger.LogInformation("Process completed in {Duration}ms", sw.ElapsedMilliseconds);
        return Results.Ok("done");
    }
    catch (Exception ex)
    {
        // LogError with exception object: captures full stack trace
        logger.LogError(ex, "Process failed. RequestId={RequestId}", Guid.NewGuid());
        return Results.Problem("Processing failed");
    }
});

app.Run();
```

```json
// appsettings.Production.json — mount as ConfigMap volume in AKS
// Avoids rebuilding image just to change log levels
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.Hosting.Lifetime": "Information",
      "SimpleApi1": "Information"
    }
  }
}
```

---

### 22.5 — AGIC (Application Gateway Ingress Controller) + Azure DNS

> **When to choose AGIC over NGINX:** You need Azure WAF, ExpressRoute integration, Azure-managed SSL certificates, or your organization's security standard requires Azure-native components.

```bash
RG="rg-aks-demo"; LOCATION="eastus"
VNET="vnet-aks-appgw"; AKS_SUBNET="snet-aks"; APPGW_SUBNET="snet-appgw"
APPGW_NAME="appgw-simpleapis"; AKS_NAME="aks-simpleapis"

# Step 1: VNet with two dedicated subnets
# App Gateway MUST have its own subnet (cannot share with AKS nodes)
az network vnet create -g $RG -n $VNET \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name $AKS_SUBNET --subnet-prefixes 10.0.0.0/24

az network vnet subnet create -g $RG --vnet-name $VNET \
  --name $APPGW_SUBNET --address-prefixes 10.0.1.0/24

# Step 2: Static public IP for DNS A record (must be Standard SKU)
az network public-ip create -g $RG -n pip-appgw \
  --sku Standard --allocation-method Static --zone 1 2 3

# Step 3: Application Gateway (WAF_v2 = WAF + autoscaling)
az network application-gateway create -g $RG -n $APPGW_NAME \
  --sku WAF_v2 --public-ip-address pip-appgw \
  --vnet-name $VNET --subnet $APPGW_SUBNET

APPGW_ID=$(az network application-gateway show -g $RG -n $APPGW_NAME --query id -o tsv)

# Step 4: AKS in same VNet (Azure CNI required — AGIC doesn't work with kubenet)
AKS_SUBNET_ID=$(az network vnet subnet show -g $RG \
  --vnet-name $VNET --name $AKS_SUBNET --query id -o tsv)

az aks create -g $RG -n $AKS_NAME --node-count 2 \
  --network-plugin azure \
  --vnet-subnet-id $AKS_SUBNET_ID \
  --enable-managed-identity --generate-ssh-keys

# Step 5: Enable AGIC add-on
az aks enable-addons -g $RG -n $AKS_NAME \
  --addons ingress-appgw --appgw-id $APPGW_ID

az aks get-credentials -g $RG -n $AKS_NAME
kubectl get pods -n kube-system | grep ingress-appgw
# ingress-appgw-deployment-xxx   1/1   Running   0   2m ← AGIC controller running
```

```yaml
# Ingress with AGIC — only the annotation differs from NGINX
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-apis-agic
  namespace: simple-apis
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway  # AGIC
    # NGINX equivalent: kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: api.mycompany.com
    http:
      paths:
      - path: /api1
        pathType: Prefix
        backend:
          service:
            name: simpleapi1-svc
            port:
              number: 80
      - path: /api2
        pathType: Prefix
        backend:
          service:
            name: simpleapi2-svc
            port:
              number: 80
```

```bash
# Step 6: Azure DNS — map api.mycompany.com to App Gateway IP
DNS_ZONE="mycompany.com"
az network dns zone create -g $RG -n $DNS_ZONE

APPGW_IP=$(az network public-ip show -g $RG -n pip-appgw --query ipAddress -o tsv)

# A record: api.mycompany.com → App Gateway public IP
az network dns record-set a add-record -g $RG \
  --zone-name $DNS_ZONE --record-set-name api \
  --ipv4-address $APPGW_IP --ttl 300

# End-to-end test (after DNS propagates, ~5 min)
curl http://api.mycompany.com/api1/health
# {"status":"healthy","service":"simpleapi1"}
```

---

### 22.6 — Helm Go Template Functions Deep Dive

> The Helm section covers structure. This section covers the Go template functions used inside every `templates/*.yaml` — the syntax that trips up everyone initially.

```gotemplate
{{/* ── Whitespace control ─────────────────────────────────────────── */}}
{{-   trim preceding whitespace/newlines      }}
{{    no trim                                 -}}
{{-   trim both sides                         -}}

{{/* ── Value access ──────────────────────────────────────────────── */}}
{{ .Values.replicaCount }}          {{/* user-defined value */}}
{{ .Release.Name }}                  {{/* helm install <NAME> ... */}}
{{ .Release.Namespace }}
{{ .Chart.Name }}                    {{/* from Chart.yaml */}}
{{ .Chart.AppVersion }}

{{/* ── default: fallback when value is empty ───────────────────── */}}
replicas: {{ .Values.replicaCount | default 2 }}
tag: "{{ .Values.image.tag | default .Chart.AppVersion }}"

{{/* ── required: fail chart render with message if value unset ─── */}}
connStr: {{ required "connectionString must be set!" .Values.connectionString | quote }}

{{/* ── quote / squote: wrap in "double" or 'single' quotes ──────── */}}
value: {{ .Values.flag | quote }}        {{/* "true" */}}
value: {{ .Values.txt  | squote }}       {{/* 'my text' */}}

{{/* ── toYaml + nindent: embed a complex map/list as YAML ────────── */}}
{{/* Most used for: resources, env, tolerations, affinity, annotations */}}
resources:
  {{- toYaml .Values.resources | nindent 2 }}
{{/* Renders .Values.resources as properly indented YAML block */}}

{{/* ── nindent vs indent ────────────────────────────────────────── */}}
{{/* nindent = newline THEN indent (use with {{- include ... }})    */}}
{{/* indent  = indent only (no leading newline)                     */}}
labels:
  {{- include "mychart.labels" . | nindent 2 }}   {{/* standard pattern */}}

{{/* ── ternary: inline if-else ─────────────────────────────────── */}}
pullPolicy: {{ ternary "Always" "IfNotPresent" (eq .Values.image.tag "latest") }}

{{/* ── printf: string formatting ────────────────────────────────── */}}
image: "{{ printf "%s:%s" .Values.image.repository .Values.image.tag }}"

{{/* ── trunc + trimSuffix: DNS-safe names (K8s name limit = 63) ─── */}}
name: {{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}

{{/* ── replace: string substitution ────────────────────────────── */}}
name: {{ .Values.appName | replace "." "-" }}    {{/* app.v1 → app-v1 */}}
```

```gotemplate
{{/* ── Conditionals ─────────────────────────────────────────────── */}}
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
...
{{- else }}
replicas: {{ .Values.replicaCount }}   {{/* static replica count when no HPA */}}
{{- end }}

{{/* ── with: set dot (.) to a sub-object, skip block if nil ──────── */}}
{{- with .Values.ingress.annotations }}
annotations:
  {{- toYaml . | nindent 4 }}
{{- end }}   {{/* entire block skipped if .Values.ingress.annotations is nil */}}

{{/* ── range over a list ─────────────────────────────────────────── */}}
env:
{{- range .Values.extraEnvVars }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}
{{/* values.yaml:  extraEnvVars: [{name: LOG_LEVEL, value: debug}] */}}

{{/* ── range over a map (key/value pairs) ──────────────────────── */}}
annotations:
{{- range $key, $value := .Values.podAnnotations }}
  {{ $key }}: {{ $value | quote }}
{{- end }}
```

```bash
# Debug: render templates locally without installing
helm template my-release ./mychart/
helm template my-release ./mychart/ --set image.tag=v3 --debug

# Lint the chart before pushing
helm lint ./mychart/

# Validate against live cluster (checks API compatibility, no install)
helm install my-release ./mychart/ --dry-run --debug
```

---

### 22.7 — Sequential Troubleshooting Playbook

> **Rule:** Debug from pod outward. Start closest to the symptom and work toward the entry point. Never check Ingress before verifying the pod is healthy.

```
SYMPTOM: "API is not responding" or "getting errors"
    │
    ▼
[1] Is cluster healthy?
    kubectl get nodes  → all Ready?
    az aks show -g $RG -n $AKS --query powerState -o tsv  → Running?
    If NO → node issue (drain, disk pressure, VM failure)
    │
    ▼
[2] Are pods Running and Ready?
    kubectl get pods -n simple-apis
    READY = 1/1 and STATUS = Running?
    If NO → kubectl describe pod <pod> → Events section (ImagePullBackOff, OOMKilled?)
    │
    ▼
[3] Does pod respond directly? (bypass Service and Ingress)
    kubectl port-forward pod/<pod> 8080:80 -n simple-apis
    curl http://localhost:8080/health
    If NO → app code bug, missing env var, config error
             kubectl exec <pod> -- env | sort  to check env vars
    │
    ▼
[4] Does Service route to pods?
    kubectl get endpoints simpleapi1-svc -n simple-apis
    ENDPOINTS column = pod IPs (not <none>)?
    If <none> → Service selector doesn't match pod labels
    │
    ▼
[5] Does Ingress have an ADDRESS and correct rules?
    kubectl get ingress -n simple-apis  → ADDRESS present?
    kubectl describe ingress  → check Rules and Default backend
    If no ADDRESS → Ingress controller issue
    │
    ▼
[6] What do the application logs say?
    kubectl logs deployment/simpleapi1 -n simple-apis
    kubectl logs <pod> --previous  (logs from crashed container)
    Look for: unhandled exceptions, DB connection failures, auth errors
    │
    ▼
[7] What do Kubernetes Events say?
    kubectl get events -n simple-apis --sort-by='.lastTimestamp'
    Look for: Warning events — quota exceeded, failed scheduling, probe failures
```

```bash
# One-liner: full namespace status at a glance
kubectl get pods,svc,ingress,hpa,pvc,events -n simple-apis \
  --sort-by='.lastTimestamp' 2>/dev/null | head -60

# Find all Warning events cluster-wide
kubectl get events -A --field-selector type=Warning \
  --sort-by='.lastTimestamp' | tail -20
```

---

### 22.8 — Architect-Level Reference: AKS Platform Patterns

#### Entry Point Layer Decision Guide

```
External Client Request
       │
       ▼
┌─────────────────────────────────────────────────────────────────┐
│  OPTIONAL: Azure API Management (APIM)                          │
│  Use when: API product catalog, developer portal, rate limiting │
│            per-consumer analytics, API versioning, auth offload │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  OPTIONAL: Azure Application Gateway                            │
│  Use when: Azure WAF required, ExpressRoute integration,        │
│            Azure-managed TLS certs, cookie-based session affinity│
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  ALWAYS: Kubernetes Ingress (NGINX or AGIC)                     │
│  Use for: path/host routing, TLS termination, pod-level routing │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
                 Kubernetes Services → Pods
```
Session affinity (cookie-based) is about **making sure a client keeps talking to the same backend pod** in Kubernetes, rather than being load-balanced to different pods each time.  

### How it works
- Normally, a Kubernetes Service load-balances requests across all matching pods.
- With **session affinity**, Kubernetes tries to "stick" a client to one pod for consistency.
- There are two main types:
  1. **Client IP-based affinity**: The client’s IP address determines which pod it gets routed to.
  2. **Cookie-based affinity**: The Service (or an Ingress/LoadBalancer in front of it) sets a special cookie in the client’s browser. That cookie tells the load balancer to keep sending requests from that client to the same pod.

### Why it matters
- Useful for **stateful applications** where a user’s session data is stored in memory on a pod (e.g., shopping carts, login sessions).
- Without affinity, a user might hit different pods and lose session continuity unless you use external session storage (like Redis).

### Example
Imagine you have 3 pods running `simpleapi2`.  
- Without affinity: User A’s requests might go to Pod 1, then Pod 2, then Pod 3.  
- With cookie-based affinity: User A gets a cookie, and all their requests keep going to Pod 1 until the session expires.  

### Important note
Cookie-based affinity is usually configured at the **Ingress controller or LoadBalancer level**, not directly in a ClusterIP Service. Kubernetes Services themselves only support **ClientIP affinity** (`sessionAffinity: ClientIP`). Cookie-based affinity is an extra feature provided by controllers like NGINX Ingress or cloud load balancers.


#### IP Address Planning for Azure CNI

```bash
# Azure CNI: every pod gets a REAL VNet IP — plan BEFORE creating cluster
# Formula: nodes × max_pods_per_node + buffer
#
# 5 nodes × 30 pods = 150 pods needed → /24 (256 IPs) ✓
# 20 nodes × 30 pods = 600 pods needed → /22 (1024 IPs) ✓
#
# Check what's configured
kubectl get nodes -o custom-columns=\
'NAME:.metadata.name,MAX-PODS:.status.allocatable.pods'
```

#### Multi-Environment Namespace Strategy

```yaml
# ResourceQuota: prevent dev from consuming prod-scale resources
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: simple-apis-dev
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
    count/pods: "20"
    count/services: "10"
```

---

### 22.9 — Command Output Interpretation Reference

```bash
# ═══════════════════════════════════════════════════════════════════
#  HEALTHY vs UNHEALTHY — what to look for
# ═══════════════════════════════════════════════════════════════════

# kubectl get pods:
# HEALTHY:   1/1   Running   0   (READY=1/1, STATUS=Running, RESTARTS=0)
# UNHEALTHY: 0/1   CrashLoopBackOff  8   ← restarting repeatedly
# UNHEALTHY: 0/1   Pending   0            ← can't schedule (resources/taint/PVC)
# UNHEALTHY: 0/1   Error     0            ← crashed, not retrying
# UNHEALTHY: 1/1   Running   15           ← running BUT 15 restarts = unstable

# kubectl get deployments:
# HEALTHY:   3/3   3   3   ← READY=3/3, UP-TO-DATE=3, AVAILABLE=3
# UNHEALTHY: 1/3   1   1   ← only 1 of 3 pods running

# kubectl get hpa:
# HEALTHY:   30%/60%   ← current/target, well under threshold
# SCALING:   85%/60%   ← above threshold, HPA adding replicas NOW
# BROKEN:    <unknown>/60%  ← metrics-server not running OR missing CPU requests

# kubectl get pvc:
# HEALTHY:   Bound   pvc-abc123   32Gi   RWO   ← disk provisioned and attached
# BROKEN:    Pending             ← provisioner failed (check describe pvc)
# BROKEN:    Lost                ← PV was deleted (data may be gone)

# kubectl get ingress:
# HEALTHY:   ADDRESS=20.50.100.200   ← external IP assigned
# BROKEN:    ADDRESS=<empty>         ← ingress controller not running

# kubectl get nodes:
# HEALTHY:   Ready   agent   5d   v1.31.2
# BROKEN:    NotReady             ← kubelet lost contact with API server
# BROKEN:    SchedulingDisabled   ← node cordoned (manual or during upgrade)
```

---

## Part 15 — Docker · Docker Compose · kubectl: Complete Command Reference

> **Mental Model:** Docker = single container lifecycle on one machine. Docker Compose = multi-container app on one machine. kubectl = multi-container workloads across a cluster. The progression is: *build locally → compose locally → deploy to cluster.*

---

### 15.1 Docker Commands — Complete Reference

#### Container Lifecycle

```bash
# ── BUILD ──────────────────────────────────────────────────────────────────
docker build -t myapp:1.0 .
# Builds image from Dockerfile in current directory, tags as myapp:1.0
```
**Sample Output:**
```
[+] Building 12.3s (10/10) FINISHED
 => [internal] load build definition from Dockerfile           0.0s
 => [internal] load .dockerignore                              0.0s
 => [1/5] FROM mcr.microsoft.com/dotnet/aspnet:10.0           4.1s
 => [2/5] COPY *.csproj ./                                     0.1s
 => [3/5] RUN dotnet restore                                   5.2s
 => [4/5] COPY . .                                             0.1s
 => [5/5] RUN dotnet publish -c Release -o /app               2.5s
 => exporting to image                                         0.1s
 => => naming to docker.io/library/myapp:1.0                   0.0s
```

```bash
docker build -t myapp:1.0 -f Dockerfile.prod --no-cache .
# Forces fresh build ignoring layer cache; uses specific Dockerfile
```
**Sample Output:**
```
[+] Building 28.7s (10/10) FINISHED       ← longer; no cache hits
```

```bash
docker build --target build-stage -t myapp:debug .
# Builds only up to a named stage (multi-stage Dockerfile)
```

---

```bash
# ── RUN ────────────────────────────────────────────────────────────────────
docker run myapp:1.0
# Runs container in foreground (Ctrl+C to stop)
```
**Sample Output:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
```

```bash
docker run -d -p 8080:80 --name api myapp:1.0
# -d detached, -p host:container port mapping, --name gives container a name
```
**Sample Output:**
```
a3f9d1c2b4e8f7a6d5c4b3a2e1f0d9c8b7a6e5f4d3c2b1a0e9f8d7c6b5a4
```
*(just the container ID — container is running in background)*

```bash
docker run -d \
  -p 8080:80 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e ConnectionStrings__Default="Server=db;Database=mydb;User=sa;Password=P@ss!" \
  -v $(pwd)/logs:/app/logs \
  --network mynet \
  --restart unless-stopped \
  --memory 512m --cpus 1.0 \
  --name api myapp:1.0
# Full production-style run: env vars, volume mount, network, restart policy, resource limits
```

```bash
docker run --rm -it myapp:1.0 /bin/bash
# --rm removes container when it exits; -it = interactive + tty (gives you a shell)
```
**Sample Output:**
```
root@7a3f9d1c:/app#           ← you are now inside the container
```

---

```bash
# ── EXEC ───────────────────────────────────────────────────────────────────
# Open interactive shell in a running container
docker exec -it api /bin/bash
```
**Sample Output:**
```
root@a3f9d1c2:/app#
```

```bash
# Run a single command without interactive shell
docker exec api env
```
**Sample Output:**
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ASPNETCORE_HTTP_PORTS=80
ASPNETCORE_ENVIRONMENT=Production
DOTNET_RUNNING_IN_CONTAINER=true
HOME=/root
```

```bash
docker exec api dotnet --info
# Runs a single command non-interactively inside running container
```
**Sample Output:**
```
.NET SDK:
 Version:           10.0.100
 Commit:            abc123def

Runtime Environment:
 OS Name:     debian
 OS Version:  12
```

```bash
docker exec -it api env | grep ASPNET
# Print env vars inside the container, filter for ASPNET
```
**Sample Output:**
```
ASPNETCORE_HTTP_PORTS=80
ASPNETCORE_ENVIRONMENT=Production
```

---

```bash
# ── LOGS ───────────────────────────────────────────────────────────────────
docker logs api
# Print all logs from container named "api"
```
**Sample Output:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started.
warn: MyApp.Controllers.WeatherController[0]
      Slow response detected: 2340ms
```

```bash
docker logs -f api
# Follow (tail) logs in real-time (like tail -f)
```

```bash
docker logs --tail 50 api
# Last 50 lines only
```

```bash
docker logs --since 5m api
# Logs from last 5 minutes
```

```bash
docker logs --timestamps api
# Show timestamps with each log line
```
**Sample Output:**
```
2026-03-02T09:14:23.541Z  info: App started.
2026-03-02T09:14:25.812Z  warn: Slow response: 2340ms
```

---

```bash
# ── PS / INSPECT ───────────────────────────────────────────────────────────
docker ps
# List running containers
```
**Sample Output:**
```
CONTAINER ID   IMAGE        COMMAND              CREATED        STATUS        PORTS                  NAMES
a3f9d1c2b4e8   myapp:1.0    "dotnet MyApp.dll"   2 hours ago    Up 2 hours    0.0.0.0:8080->80/tcp   api
9f8e7d6c5b4a   redis:7      "docker-entrypoint"  2 hours ago    Up 2 hours    0.0.0.0:6379->6379/tcp redis
```

```bash
docker ps -a
# All containers including stopped
```
**Sample Output:**
```
CONTAINER ID   IMAGE        COMMAND              CREATED        STATUS                    NAMES
a3f9d1c2b4e8   myapp:1.0    "dotnet MyApp.dll"   2 hours ago    Up 2 hours                api
b4e5f6a7b8c9   myapp:0.9    "dotnet MyApp.dll"   3 days ago     Exited (0) 3 days ago     api-old
```

```bash
docker ps -q
# Quiet mode: only container IDs (useful in scripts: docker stop $(docker ps -q))
```
**Sample Output:**
```
a3f9d1c2b4e8
9f8e7d6c5b4a
```

```bash
docker inspect api
# Full JSON metadata: mounts, network, env, config, state
```
**Sample Output (abbreviated):**
```json
[
  {
    "Id": "a3f9d1c2b4e8...",
    "State": { "Status": "running", "Running": true, "Pid": 12345 },
    "Mounts": [
      { "Type": "bind", "Source": "/host/logs", "Destination": "/app/logs" }
    ],
    "NetworkSettings": {
      "Ports": { "80/tcp": [{ "HostIp": "0.0.0.0", "HostPort": "8080" }] },
      "IPAddress": "172.17.0.2"
    }
  }
]
```

```bash
docker stats
# Live CPU/memory/network usage for all running containers
```
**Sample Output:**
```
CONTAINER ID   NAME    CPU %   MEM USAGE / LIMIT     MEM %   NET I/O          BLOCK I/O
a3f9d1c2b4e8   api     0.42%   128MiB / 512MiB       25.0%   1.2MB / 456kB    0B / 8kB
9f8e7d6c5b4a   redis   0.01%   12.4MiB / 1.5GiB      0.8%    88kB / 72kB      0B / 0B
```

```bash
docker top api
# Show running processes inside container (like ps aux)
```
**Sample Output:**
```
UID    PID     PPID    C   STIME   TTY   TIME       CMD
root   12345   12300   0   09:14   ?     00:00:02   dotnet MyApp.dll
```

---

```bash
# ── STOP / START / RESTART / REMOVE ────────────────────────────────────────
docker stop api              # SIGTERM → wait 10s → SIGKILL
docker stop -t 30 api        # Wait 30 seconds before SIGKILL
docker kill api              # Immediate SIGKILL (no graceful shutdown)
docker start api             # Start a stopped container
docker restart api           # Stop then start
docker pause api             # Freeze container (SIGSTOP)
docker unpause api           # Resume frozen container
docker rm api                # Remove stopped container
docker rm -f api             # Force remove even if running
docker rm $(docker ps -aq)   # Remove ALL stopped containers
```
**Sample Output (docker stop api):**
```
api                          ← prints container name on success
```

---

```bash
# ── IMAGES ─────────────────────────────────────────────────────────────────
docker images
# or: docker image ls
```
**Sample Output:**
```
REPOSITORY   TAG       IMAGE ID       CREATED        SIZE
myapp        1.0       d1e2f3a4b5c6   2 hours ago    215MB
myapp        0.9       e2f3a4b5c6d7   3 days ago     218MB
redis        7         f3a4b5c6d7e8   1 week ago     117MB
```

```bash
docker pull nginx:1.25              # Download image from registry
docker push myregistry.io/myapp:1.0 # Push image to registry
docker tag myapp:1.0 myregistry.io/myapp:1.0  # Tag for pushing
docker rmi myapp:0.9                # Remove image by tag
docker rmi -f d1e2f3a4b5c6          # Force remove image by ID
docker image prune                  # Remove dangling images (untagged)
docker image prune -a               # Remove ALL unused images
```

```bash
docker history myapp:1.0
# Show image layer history (sizes, commands)
```
**Sample Output:**
```
IMAGE          CREATED        CREATED BY                                      SIZE
d1e2f3a4b5c6   2 hours ago    ENTRYPOINT ["dotnet" "MyApp.dll"]               0B
<missing>      2 hours ago    COPY /app /app                                  45.2MB
<missing>      2 hours ago    RUN dotnet publish -c Release -o /app           98.4MB
<missing>      4 weeks ago    FROM mcr.microsoft.com/dotnet/aspnet:10.0       68.7MB
```

```bash
docker save myapp:1.0 -o myapp.tar    # Export image to tar file
docker load -i myapp.tar              # Import image from tar file
docker export api > container.tar     # Export container filesystem
docker import container.tar myapp:v2  # Import as new image
```

---

```bash
# ── VOLUMES ────────────────────────────────────────────────────────────────
docker volume create mydata
docker volume ls
docker volume inspect mydata
docker volume rm mydata
docker volume prune              # Remove all unused volumes
```

**docker volume ls Sample Output:**
```
DRIVER    VOLUME NAME
local     mydata
local     redis-data
local     pgdata
```

**docker volume inspect mydata Sample Output:**
```json
[
  {
    "Name": "mydata",
    "Driver": "local",
    "Mountpoint": "/var/lib/docker/volumes/mydata/_data",
    "CreatedAt": "2026-03-02T09:00:00Z",
    "Labels": {}
  }
]
```

---

```bash
# ── NETWORKS ───────────────────────────────────────────────────────────────
docker network create mynet
docker network create --driver bridge --subnet 192.168.100.0/24 mynet
docker network ls
docker network inspect mynet
docker network connect mynet api       # Attach running container to network
docker network disconnect mynet api    # Detach container from network
docker network rm mynet
docker network prune                   # Remove all unused networks
```

**docker network ls Sample Output:**
```
NETWORK ID     NAME      DRIVER    SCOPE
b1c2d3e4f5a6   bridge    bridge    local
c2d3e4f5a6b7   host      host      local
d3e4f5a6b7c8   mynet     bridge    local
e4f5a6b7c8d9   none      null      local
```

---

```bash
# ── SYSTEM / CLEANUP ───────────────────────────────────────────────────────
docker system df
# Show disk usage by images, containers, volumes
```
**Sample Output:**
```
TYPE            TOTAL   ACTIVE   SIZE      RECLAIMABLE
Images          8       3        1.42GB    892MB (62%)
Containers      5       2        2.1MB     1.8MB (85%)
Local Volumes   4       2        512MB     128MB (25%)
Build Cache     42               245MB     245MB
```

```bash
docker system prune           # Remove stopped containers, unused networks, dangling images
docker system prune -a        # Also remove all unused images (not just dangling)
docker system prune -a --volumes  # Nuclear option: also remove unused volumes
```
**Sample Output (docker system prune):**
```
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache
Are you sure you want to continue? [y/N] y

Deleted Containers:
b4e5f6a7b8c9

Deleted Networks:
oldnet

Total reclaimed space: 218.4MB
```

```bash
docker info
# System-wide information: containers, images, storage driver, runtime
```
**Sample Output:**
```
Client: Docker Engine - Community
 Version:    26.1.0
 Context:    default

Server:
 Containers: 5
  Running: 2
  Paused: 0
  Stopped: 3
 Images: 8
 Server Version: 26.1.0
 Storage Driver: overlay2
 Logging Driver: json-file
 Cgroup Driver: systemd
 Runtimes: io.containerd.runc.v2
 Total Memory: 15.5GiB
 CPUs: 8
 Docker Root Dir: /var/lib/docker
```

```bash
docker version
# Client and server version info
```
**Sample Output:**
```
Client: Docker Engine - Community
 Version:           26.1.0
 API version:       1.45
 Go version:        go1.21.9
 OS/Arch:           linux/amd64

Server: Docker Engine - Community
 Engine:
  Version:          26.1.0
  API version:      1.45 (minimum version 1.12)
```

---

```bash
# ── COPY / DIFF ────────────────────────────────────────────────────────────
docker cp api:/app/logs/app.log ./app.log   # Copy file from container to host
docker cp ./config.json api:/app/config.json # Copy file from host to container

docker diff api
# Show filesystem changes made to running container
```
**Sample Output (docker diff):**
```
C /app
A /app/logs
A /app/logs/app.log        ← A=Added, C=Changed, D=Deleted
```

```bash
docker commit api myapp:with-logs
# Create new image from current container state (avoid in prod; prefer Dockerfile)
```

---

### 15.2 Docker Compose Commands — Complete Reference

> **Mental Model:** Compose reads `docker-compose.yml` / `compose.yaml` and treats it as a single application definition. One command starts all your containers, networks, and volumes together.

```yaml
# ── REFERENCE compose.yaml USED IN EXAMPLES ────────────────────────────────
services:
  api:
    build: .
    ports: ["8080:80"]
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    depends_on: [db, redis]
    volumes: ["./logs:/app/logs"]
    networks: [backend]

  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      SA_PASSWORD: "P@ssw0rd!"
      ACCEPT_EULA: "Y"
    volumes: ["sqldata:/var/opt/mssql"]
    networks: [backend]

  redis:
    image: redis:7-alpine
    networks: [backend]

volumes:
  sqldata:

networks:
  backend:
```

---

```bash
# ── UP / DOWN ──────────────────────────────────────────────────────────────
docker compose up
# Build (if needed), create, start all services; attach to logs
```
**Sample Output:**
```
[+] Running 3/3
 ✔ Container myapp-db-1     Created   0.1s
 ✔ Container myapp-redis-1  Created   0.1s
 ✔ Container myapp-api-1    Created   0.2s
Attaching to myapp-api-1, myapp-db-1, myapp-redis-1
myapp-db-1     | SQL Server is now ready for client connections.
myapp-api-1    | info: Now listening on: http://[::]:80
```

```bash
docker compose up -d
# Detached mode (background)
```
**Sample Output:**
```
[+] Running 3/3
 ✔ Container myapp-db-1     Started   1.2s
 ✔ Container myapp-redis-1  Started   0.8s
 ✔ Container myapp-api-1    Started   2.1s
```

```bash
docker compose up -d --build
# Force rebuild images before starting (picks up code changes)
```

```bash
docker compose up -d --scale api=3
# Start 3 replicas of the api service
```
**Sample Output:**
```
[+] Running 5/5
 ✔ Container myapp-db-1     Running   0.0s
 ✔ Container myapp-redis-1  Running   0.0s
 ✔ Container myapp-api-1    Started   0.5s
 ✔ Container myapp-api-2    Started   0.6s
 ✔ Container myapp-api-3    Started   0.7s
```

```bash
docker compose down
# Stop and remove containers + networks (volumes preserved)
```
**Sample Output:**
```
[+] Running 4/4
 ✔ Container myapp-api-1    Removed   0.3s
 ✔ Container myapp-redis-1  Removed   0.1s
 ✔ Container myapp-db-1     Removed   0.5s
 ✔ Network myapp_backend    Removed   0.1s
```

```bash
docker compose down -v
# Also remove named volumes (DATA LOSS — drops sqldata volume)
```

```bash
docker compose down --rmi all
# Also remove all images built for this project
```

---

```bash
# ── START / STOP / RESTART ─────────────────────────────────────────────────
docker compose start          # Start stopped services (no rebuild)
docker compose stop           # Stop running services (containers kept)
docker compose restart        # Restart all services
docker compose restart api    # Restart only the api service
docker compose pause          # Pause all services
docker compose unpause        # Unpause all services
```
**Sample Output (docker compose stop):**
```
[+] Stopping 3/3
 ✔ Container myapp-api-1    Stopped   1.0s
 ✔ Container myapp-redis-1  Stopped   0.1s
 ✔ Container myapp-db-1     Stopped   1.5s
```

---

```bash
# ── LOGS ───────────────────────────────────────────────────────────────────
docker compose logs
# All service logs combined
```
**Sample Output:**
```
myapp-db-1     | 2026-03-02 09:14:20.00 Server   SQL Server is now ready.
myapp-api-1    | info: Application started.
myapp-api-1    | info: Request: GET /health → 200 (12ms)
myapp-redis-1  | 1:M 02 Mar 2026 09:14:19.543 * Ready to accept connections tcp
```

```bash
docker compose logs -f api          # Follow api service logs only
docker compose logs --tail 50 api   # Last 50 lines
docker compose logs --timestamps    # Include timestamps
```

---

```bash
# ── PS / TOP / STATS ───────────────────────────────────────────────────────
docker compose ps
# List containers for this project
```
**Sample Output:**
```
NAME               IMAGE        COMMAND              SERVICE   CREATED      STATUS         PORTS
myapp-api-1        myapp-api    "dotnet MyApp.dll"   api       2 hours ago  Up 2 hours     0.0.0.0:8080->80/tcp
myapp-db-1         mssql:2022   "/opt/mssql/bin/sq"  db        2 hours ago  Up 2 hours
myapp-redis-1      redis:7      "docker-entrypoint"  redis     2 hours ago  Up 2 hours     6379/tcp
```

```bash
docker compose ps -a              # Include stopped services
docker compose top                # Processes inside each service
docker compose stats              # Live resource usage per service
```

---

```bash
# ── EXEC / RUN ─────────────────────────────────────────────────────────────
# Open interactive shell in a running service container
docker compose exec api /bin/bash
```
**Sample Output:**
```
root@myapp-api-1:/app#
```

```bash
# Run a single command without interactive shell
docker compose exec api env
```
**Sample Output:**
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ASPNETCORE_HTTP_PORTS=80
ASPNETCORE_ENVIRONMENT=Development
DOTNET_RUNNING_IN_CONTAINER=true
HOME=/root
```

```bash
docker compose exec api dotnet --info
# Run command in running service container

docker compose run --rm api dotnet test
# Spin up NEW container for api service, run command, then remove
# Useful for one-off tasks (migrations, seed data)
```
**Sample Output (docker compose run):**
```
[+] Creating 1/0
 ✔ Container myapp-api-run-abcd  Created   0.2s
Test run for /app/MyApp.Tests.dll (.NETCoreApp,Version=v10.0)
...
Passed!  - Failed:     0, Passed:    42, Skipped:     0, Total:    42
```

---

```bash
# ── BUILD / PULL / PUSH ────────────────────────────────────────────────────
docker compose build             # Build all service images
docker compose build api         # Build only api service
docker compose build --no-cache  # Force rebuild without cache
docker compose pull              # Pull latest base images for all services
docker compose push              # Push built images to registry
```
**Sample Output (docker compose build):**
```
[+] Building 12.3s (10/10) FINISHED
 => [api] FROM mcr.microsoft.com/dotnet/aspnet:10.0            4.1s
 => [api] COPY . .                                             0.1s
 => [api] RUN dotnet publish -c Release -o /app               6.8s
 => [api] exporting to image                                   0.2s
```

---

```bash
# ── CONFIG / VERSION ───────────────────────────────────────────────────────
docker compose config
# Validate and print resolved compose file (with env substitutions applied)
```
**Sample Output:**
```
name: myapp
services:
  api:
    build:
      context: /home/user/myapp
    environment:
      ASPNETCORE_ENVIRONMENT: Development
    networks:
      backend: null
    ports:
      - 8080:80/tcp
  ...
```

```bash
docker compose version
```
**Sample Output:**
```
Docker Compose version v2.27.0
```

---

### 15.3 kubectl Commands — Complete Reference

> **Mental Model:** kubectl is your control plane remote control. Every command is `kubectl <verb> <resource> <name> [flags]`. Verbs: get, describe, apply, delete, exec, logs, port-forward, rollout, scale, top, drain, cordon, label, annotate, patch.

---

#### Cluster & Context Management

```bash
# ── CONTEXTS ──────────────────────────────────────────────────────────────
kubectl config get-contexts
# List all kubeconfig contexts
```
**Sample Output:**
```
CURRENT   NAME               CLUSTER            AUTHINFO           NAMESPACE
*         aks-prod           aks-prod           clusterUser-prod   default
          aks-dev            aks-dev            clusterUser-dev    default
          docker-desktop     docker-desktop     docker-desktop     default
```

```bash
kubectl config use-context aks-dev
# Switch active context
```
**Sample Output:**
```
Switched to context "aks-dev".
```

```bash
kubectl config current-context          # Show current context
kubectl config view                     # Full kubeconfig contents
kubectl config set-context --current --namespace=myapp  # Set default namespace
```

```bash
kubectl cluster-info
# Show control plane and DNS addresses
```
**Sample Output:**
```
Kubernetes control plane is running at https://myaks-prod-api.hcp.eastus.azmk8s.io:443
CoreDNS is running at https://myaks-prod-api.hcp.eastus.azmk8s.io:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

```bash
kubectl version
# Client and server Kubernetes versions
```
**Sample Output:**
```
Client Version: v1.31.2
Kustomize Version: v5.4.2
Server Version: v1.31.2
```

---

#### Namespaces

```bash
kubectl get namespaces
# or: kubectl get ns
```
**Sample Output:**
```
NAME              STATUS   AGE
default           Active   30d
kube-node-lease   Active   30d
kube-public       Active   30d
kube-system       Active   30d
myapp             Active   5d
monitoring        Active   15d
```

```bash
kubectl create namespace myapp
kubectl delete namespace myapp

# Use -n flag for all resource commands:
kubectl get pods -n myapp
kubectl get pods --all-namespaces    # or: kubectl get pods -A
```
**Sample Output (kubectl get pods -A):**
```
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   coredns-5dd5756b68-4j9lp             1/1     Running   0          30d
kube-system   coredns-5dd5756b68-nbtmr             1/1     Running   0          30d
myapp         api-deployment-6b9c5d4f8-x7k2p       1/1     Running   0          2d
myapp         api-deployment-6b9c5d4f8-m3n9q       1/1     Running   0          2d
monitoring    prometheus-0                          1/1     Running   0          15d
```

---

#### Nodes

```bash
kubectl get nodes
```
**Sample Output:**
```
NAME                             STATUS   ROLES   AGE   VERSION
aks-nodepool1-12345678-vmss000000   Ready    agent   30d   v1.31.2
aks-nodepool1-12345678-vmss000001   Ready    agent   30d   v1.31.2
aks-nodepool1-12345678-vmss000002   Ready    agent   30d   v1.31.2
```

```bash
kubectl get nodes -o wide
# Extra columns: OS, kernel, container runtime, internal/external IPs
```
**Sample Output:**
```
NAME                           STATUS   ROLES   AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION   CONTAINER-RUNTIME
aks-nodepool1-...-vmss000000   Ready    agent   30d   v1.31.2   10.240.0.4     <none>        Ubuntu 22.04.4 LTS   5.15.0-1060      containerd://1.7.15
aks-nodepool1-...-vmss000001   Ready    agent   30d   v1.31.2   10.240.0.5     <none>        Ubuntu 22.04.4 LTS   5.15.0-1060      containerd://1.7.15
```

```bash
kubectl describe node aks-nodepool1-12345678-vmss000000
# Full node detail: capacity, allocatable, conditions, events, pods running
```
**Sample Output (abbreviated):**
```
Name:               aks-nodepool1-12345678-vmss000000
Roles:              agent
Labels:             agentpool=nodepool1
                    kubernetes.io/arch=amd64
                    node.kubernetes.io/instance-type=Standard_DS2_v2
Capacity:
  cpu:                2
  memory:             7121700Ki
  pods:               110
Allocatable:
  cpu:                1900m
  memory:             5515876Ki
  pods:               110
Conditions:
  Type                Status   Message
  ----                ------   -------
  MemoryPressure      False    kubelet has sufficient memory
  DiskPressure        False    kubelet has sufficient disk space
  PIDPressure         False    kubelet has sufficient PID
  Ready               True     kubelet is posting ready status
Non-terminated Pods:
  myapp     api-deployment-6b9c5d4f8-x7k2p   100m (5%)    128Mi (2%)
  myapp     api-deployment-6b9c5d4f8-m3n9q   100m (5%)    128Mi (2%)
Events:     <none>
```

```bash
kubectl top nodes
# CPU and memory usage (requires metrics-server)
```
**Sample Output:**
```
NAME                             CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
aks-nodepool1-12345678-vmss000000   187m         9%     2412Mi          43%
aks-nodepool1-12345678-vmss000001   94m          4%     1876Mi          34%
aks-nodepool1-12345678-vmss000002   203m         10%    2589Mi          46%
```

```bash
kubectl cordon aks-nodepool1-12345678-vmss000000
# Mark node unschedulable (no new pods placed here)
```
**Sample Output:**
```
node/aks-nodepool1-12345678-vmss000000 cordoned
```

```bash
kubectl uncordon aks-nodepool1-12345678-vmss000000
# Re-enable scheduling on node

kubectl drain aks-nodepool1-12345678-vmss000000 --ignore-daemonsets --delete-emptydir-data
# Evict all pods from node (for maintenance/upgrades)
```
**Sample Output (kubectl drain):**
```
node/aks-nodepool1-12345678-vmss000000 cordoned
evicting pod myapp/api-deployment-6b9c5d4f8-x7k2p
pod/api-deployment-6b9c5d4f8-x7k2p evicted
node/aks-nodepool1-12345678-vmss000000 drained
```

---

#### Pods

```bash
kubectl get pods -n myapp
```
**Sample Output:**
```
NAME                              READY   STATUS    RESTARTS   AGE
api-deployment-6b9c5d4f8-x7k2p   1/1     Running   0          2d
api-deployment-6b9c5d4f8-m3n9q   1/1     Running   0          2d
api-deployment-6b9c5d4f8-r5t8w   0/1     Pending   0          30s
```

```bash
kubectl get pods -n myapp -o wide
# Extra: node placement, IP address
```
**Sample Output:**
```
NAME                              READY   STATUS    RESTARTS   AGE   IP            NODE
api-deployment-6b9c5d4f8-x7k2p   1/1     Running   0          2d    10.244.1.15   aks-nodepool1-...-vmss000000
api-deployment-6b9c5d4f8-m3n9q   1/1     Running   0          2d    10.244.2.18   aks-nodepool1-...-vmss000001
```

```bash
kubectl get pods -n myapp -w
# Watch mode: continuously prints changes (like tail -f)
```

```bash
kubectl get pods -n myapp -l app=api
# Filter by label selector
```
**Sample Output:**
```
NAME                              READY   STATUS    RESTARTS   AGE
api-deployment-6b9c5d4f8-x7k2p   1/1     Running   0          2d
api-deployment-6b9c5d4f8-m3n9q   1/1     Running   0          2d
```

```bash
kubectl describe pod api-deployment-6b9c5d4f8-x7k2p -n myapp
# Full pod detail: events, containers, env, mounts, conditions
```
**Sample Output (abbreviated):**
```
Name:             api-deployment-6b9c5d4f8-x7k2p
Namespace:        myapp
Node:             aks-nodepool1-...-vmss000000/10.240.0.4
Start Time:       Mon, 02 Mar 2026 09:14:23 +0000
Labels:           app=api
                  pod-template-hash=6b9c5d4f8
Status:           Running
IP:               10.244.1.15
Containers:
  api:
    Image:         myregistry.io/myapp:1.0
    Port:          80/TCP
    Limits:        cpu=500m, memory=512Mi
    Requests:      cpu=100m, memory=128Mi
    Ready:         True
    Restart Count: 0
    Environment:
      ASPNETCORE_ENVIRONMENT:  Production
Conditions:
  Ready             True
  ContainersReady   True
  PodScheduled      True
Events:
  Normal  Scheduled  2d    default-scheduler  Successfully assigned myapp/api-... to node
  Normal  Pulled     2d    kubelet            Successfully pulled image in 3.2s
  Normal  Started    2d    kubelet            Started container api
```

```bash
kubectl logs api-deployment-6b9c5d4f8-x7k2p -n myapp
```
**Sample Output:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started.
```

```bash
kubectl logs -f api-deployment-6b9c5d4f8-x7k2p -n myapp       # Follow
kubectl logs --tail=100 api-deployment-6b9c5d4f8-x7k2p -n myapp  # Last 100 lines
kubectl logs --previous api-deployment-6b9c5d4f8-x7k2p -n myapp  # Previous container (after crash)
kubectl logs -l app=api -n myapp                                 # Logs from ALL pods with label
kubectl logs api-deployment-6b9c5d4f8-x7k2p -c sidecar -n myapp # Specific container in multi-container pod
```

```bash
kubectl exec -it api-deployment-6b9c5d4f8-x7k2p -n myapp -- /bin/bash
# Interactive shell inside pod
```
**Sample Output:**
```
root@api-deployment-6b9c5d4f8-x7k2p:/app#
```

```bash
kubectl exec api-deployment-6b9c5d4f8-x7k2p -n myapp -- env | grep ASPNET
# Run single command; -- separates kubectl flags from container command
```
**Sample Output:**
```
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_HTTP_PORTS=80
```

```bash
kubectl port-forward pod/api-deployment-6b9c5d4f8-x7k2p 8080:80 -n myapp
# Forward local port 8080 → pod port 80 (for local debugging)
```
**Sample Output:**
```
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
```

```bash
kubectl cp myapp/api-deployment-6b9c5d4f8-x7k2p:/app/logs/app.log ./app.log
# Copy file from pod to local
kubectl cp ./config.json myapp/api-deployment-6b9c5d4f8-x7k2p:/app/config.json
# Copy file from local to pod

kubectl top pod -n myapp
# CPU/memory per pod
```
**Sample Output (kubectl top pod):**
```
NAME                              CPU(cores)   MEMORY(bytes)
api-deployment-6b9c5d4f8-x7k2p   23m          134Mi
api-deployment-6b9c5d4f8-m3n9q   18m          128Mi
```

```bash
kubectl delete pod api-deployment-6b9c5d4f8-x7k2p -n myapp
# Delete pod (Deployment will immediately create a replacement)
```
**Sample Output:**
```
pod "api-deployment-6b9c5d4f8-x7k2p" deleted
```

```bash
kubectl debug -it api-deployment-6b9c5d4f8-x7k2p --image=busybox -n myapp
# Attach an ephemeral debug container to a running pod (k8s 1.23+)
```

---

#### Deployments

```bash
kubectl get deployments -n myapp
# or: kubectl get deploy -n myapp
```
**Sample Output:**
```
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
api-deployment   3/3     3            3           5d
```

```bash
kubectl describe deployment api-deployment -n myapp
```
**Sample Output (abbreviated):**
```
Name:                   api-deployment
Namespace:              myapp
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:    app=api
  Containers:
    api:
      Image:  myregistry.io/myapp:1.0
      Port:   80/TCP
      Limits: cpu=500m, memory=512Mi
Conditions:
  Type          Status   Reason
  Available     True     MinimumReplicasAvailable
  Progressing   True     NewReplicaSetAvailable
Events:
  Normal  ScalingReplicaSet  5d  deployment-controller  Scaled up to 3
```

```bash
kubectl apply -f deployment.yaml -n myapp
# Apply (create or update) from YAML file; idempotent
```
**Sample Output:**
```
deployment.apps/api-deployment created
# or on update:
deployment.apps/api-deployment configured
```

```bash
kubectl apply -f ./k8s/                   # Apply all YAML files in directory
kubectl apply -k ./k8s/overlays/prod/     # Apply kustomize overlay

kubectl delete -f deployment.yaml -n myapp # Delete resources defined in file
```

```bash
kubectl scale deployment api-deployment --replicas=5 -n myapp
```
**Sample Output:**
```
deployment.apps/api-deployment scaled
```

```bash
kubectl set image deployment/api-deployment api=myregistry.io/myapp:2.0 -n myapp
# Update container image (triggers rolling update)
```
**Sample Output:**
```
deployment.apps/api-deployment image updated
```

```bash
kubectl rollout status deployment/api-deployment -n myapp
# Watch rolling update progress
```
**Sample Output:**
```
Waiting for deployment "api-deployment" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "api-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "api-deployment" rollout to finish: 1 old replicas are pending termination...
deployment "api-deployment" successfully rolled out
```

```bash
kubectl rollout history deployment/api-deployment -n myapp
# Show revision history
```
**Sample Output:**
```
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment/api-deployment api=myapp:2.0
3         kubectl set image deployment/api-deployment api=myapp:3.0
```

```bash
kubectl rollout undo deployment/api-deployment -n myapp
# Roll back to previous revision
```
**Sample Output:**
```
deployment.apps/api-deployment rolled back
```

```bash
kubectl rollout undo deployment/api-deployment --to-revision=1 -n myapp
# Roll back to specific revision

kubectl rollout pause deployment/api-deployment -n myapp   # Pause rolling update
kubectl rollout resume deployment/api-deployment -n myapp  # Resume paused update
kubectl rollout restart deployment/api-deployment -n myapp # Force restart all pods
```

```bash
kubectl edit deployment api-deployment -n myapp
# Open deployment YAML in $EDITOR for live editing
```

---

#### Services

```bash
kubectl get services -n myapp
# or: kubectl get svc -n myapp
```
**Sample Output:**
```
NAME          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
api-service   LoadBalancer   10.0.45.123    52.149.12.34    80:31245/TCP   5d
db-service    ClusterIP      10.0.102.88    <none>          1433/TCP       5d
redis         ClusterIP      10.0.78.55     <none>          6379/TCP       5d
```

```bash
kubectl describe service api-service -n myapp
```
**Sample Output:**
```
Name:                     api-service
Namespace:                myapp
Type:                     LoadBalancer
IP:                       10.0.45.123
LoadBalancer Ingress:     52.149.12.34
Port:                     http  80/TCP
TargetPort:               80/TCP
NodePort:                 31245/TCP
Endpoints:                10.244.1.15:80,10.244.2.18:80,10.244.3.21:80
Selector:                 app=api
```

```bash
kubectl port-forward service/api-service 8080:80 -n myapp
# Tunnel to service (doesn't go through load balancer; useful for internal services)
```

```bash
kubectl expose deployment api-deployment --type=LoadBalancer --port=80 -n myapp
# Create a Service exposing a Deployment (imperative style; prefer YAML)
```

---

#### ConfigMaps & Secrets

```bash
kubectl get configmaps -n myapp
# or: kubectl get cm -n myapp
```
**Sample Output:**
```
NAME               DATA   AGE
app-config         3      5d
nginx-config       1      5d
kube-root-ca.crt   1      30d
```

```bash
kubectl describe configmap app-config -n myapp
```
**Sample Output:**
```
Name:         app-config
Namespace:    myapp
Data
====
ASPNETCORE_ENVIRONMENT:  Production
FeatureFlags__DarkMode:  true
Logging__Level:          Warning
```

```bash
kubectl create configmap app-config \
  --from-literal=ASPNETCORE_ENVIRONMENT=Production \
  --from-literal=FeatureFlags__DarkMode=true \
  -n myapp

kubectl create configmap nginx-config --from-file=nginx.conf -n myapp

kubectl get secret -n myapp
```
**Sample Output:**
```
NAME                  TYPE                DATA   AGE
db-credentials        Opaque              2      5d
tls-cert              kubernetes.io/tls   2      30d
regcred               kubernetes.io/dockerconfigjson  1  5d
```

```bash
kubectl create secret generic db-credentials \
  --from-literal=SA_PASSWORD="P@ssw0rd!" \
  --from-literal=ConnectionString="Server=db;Database=mydb;User=sa;Password=P@ssw0rd!" \
  -n myapp

kubectl get secret db-credentials -o jsonpath='{.data.SA_PASSWORD}' -n myapp | base64 --decode
# Decode a secret value
```
**Sample Output:**
```
P@ssw0rd!
```

```bash
kubectl delete configmap app-config -n myapp
kubectl delete secret db-credentials -n myapp
```

---

#### Ingress

```bash
kubectl get ingress -n myapp
# or: kubectl get ing -n myapp
```
**Sample Output:**
```
NAME          CLASS   HOSTS                    ADDRESS        PORTS     AGE
api-ingress   nginx   api.myapp.com            52.149.12.34   80, 443   5d
```

```bash
kubectl describe ingress api-ingress -n myapp
```
**Sample Output:**
```
Name:             api-ingress
Namespace:        myapp
IngressClass:     nginx
Rules:
  Host          Path  Backends
  ----          ----  --------
  api.myapp.com
                /     api-service:80 (10.244.1.15:80,10.244.2.18:80)
TLS:
  tls-cert terminates api.myapp.com
Annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
  nginx.ingress.kubernetes.io/proxy-body-size: 10m
```

---

#### Persistent Volumes & Claims

```bash
kubectl get pv                          # Cluster-wide (no -n needed)
kubectl get pvc -n myapp
```
**Sample Output (kubectl get pvc):**
```
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
sqldata     Bound    pvc-a1b2c3d4-e5f6-7890-abcd-ef1234567890   32Gi       RWO            managed-csi    5d
```

```bash
kubectl describe pvc sqldata -n myapp
```
**Sample Output:**
```
Name:          sqldata
Namespace:     myapp
StorageClass:  managed-csi
Status:        Bound
Volume:        pvc-a1b2c3d4-e5f6-7890-abcd-ef1234567890
Capacity:      32Gi
Access Modes:  RWO
Events:
  Normal  ProvisioningSucceeded  5d  disk.csi.azure.com  Successfully provisioned volume
```

---

#### HPA / VPA / KEDA

```bash
kubectl get hpa -n myapp
```
**Sample Output:**
```
NAME          REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
api-hpa       Deployment/api-deployment     23%/60%         2         10        3          5d
```

```bash
kubectl describe hpa api-hpa -n myapp
```
**Sample Output:**
```
Name:                                                  api-hpa
Namespace:                                             myapp
Reference:                                             Deployment/api-deployment
Metrics:     ( current / target )
  resource cpu on pods (as a percentage of request):  23% (23m) / 60%
Min replicas:                                          2
Max replicas:                                          10
Deployment pods:                                       3 current / 3 desired
Events:
  Normal  SuccessfulRescale  1h  horizontal-pod-autoscaler  New size: 4; reason: cpu resource above target
  Normal  SuccessfulRescale  45m horizontal-pod-autoscaler  New size: 3; reason: All metrics below target
```

---

#### Jobs & CronJobs

```bash
kubectl get jobs -n myapp
kubectl get cronjobs -n myapp
```
**Sample Output (kubectl get jobs):**
```
NAME              COMPLETIONS   DURATION   AGE
db-migration      1/1           45s        1d
data-seed-abc12   0/1           5m         5m    ← still running
```

```bash
kubectl create job manual-run --from=cronjob/daily-report -n myapp
# Manually trigger a CronJob
```
**Sample Output:**
```
job.batch/manual-run created
```

---

#### Output Formats

```bash
# ── OUTPUT FORMAT FLAGS (apply to any get command) ─────────────────────────
kubectl get pods -n myapp -o wide         # Extra columns
kubectl get pods -n myapp -o yaml         # Full YAML definition
kubectl get pods -n myapp -o json         # Full JSON definition
kubectl get pods -n myapp -o name         # Only resource names
kubectl get pods -n myapp -o jsonpath='{.items[*].metadata.name}'  # JSONPath extraction
kubectl get pods -n myapp -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName
```
**Sample Output (-o name):**
```
pod/api-deployment-6b9c5d4f8-x7k2p
pod/api-deployment-6b9c5d4f8-m3n9q
pod/api-deployment-6b9c5d4f8-r5t8w
```
**Sample Output (-o jsonpath):**
```
api-deployment-6b9c5d4f8-x7k2p api-deployment-6b9c5d4f8-m3n9q api-deployment-6b9c5d4f8-r5t8w
```
**Sample Output (-o custom-columns):**
```
NAME                              STATUS    NODE
api-deployment-6b9c5d4f8-x7k2p   Running   aks-nodepool1-...-vmss000000
api-deployment-6b9c5d4f8-m3n9q   Running   aks-nodepool1-...-vmss000001
```

---

#### Labels, Annotations, Patches

```bash
kubectl label pod api-deployment-6b9c5d4f8-x7k2p env=production -n myapp
# Add or update label
```
**Sample Output:**
```
pod/api-deployment-6b9c5d4f8-x7k2p labeled
```

```bash
kubectl label pod api-deployment-6b9c5d4f8-x7k2p env- -n myapp
# Remove label (trailing dash)

kubectl annotate deployment api-deployment kubernetes.io/change-cause="Deploy v2.0" -n myapp
# Add annotation (used for rollout history CHANGE-CAUSE)

kubectl patch deployment api-deployment -n myapp \
  -p '{"spec":{"replicas":5}}'
# Inline JSON patch (strategic merge patch by default)

kubectl patch deployment api-deployment -n myapp \
  --type=json \
  -p '[{"op":"replace","path":"/spec/replicas","value":5}]'
# JSON Patch (RFC 6902) — precise path operations
```

---

#### RBAC

```bash
kubectl get clusterroles
kubectl get clusterrolebindings
kubectl get roles -n myapp
kubectl get rolebindings -n myapp

kubectl auth can-i create pods -n myapp
# Check if current user has permission
```
**Sample Output:**
```
yes
```

```bash
kubectl auth can-i create pods -n myapp --as=serviceaccount:myapp:api-sa
# Check permissions as a specific service account
```
**Sample Output:**
```
no
```

---

#### Apply / Diff / Dry-run

```bash
kubectl diff -f deployment.yaml -n myapp
# Show what would change BEFORE applying (like terraform plan)
```
**Sample Output:**
```
diff -u -N /tmp/LIVE/apps.v1.Deployment.myapp.api-deployment /tmp/MERGED/apps.v1.Deployment.myapp.api-deployment
--- /tmp/LIVE/...
+++ /tmp/MERGED/...
@@ -20,7 +20,7 @@
       containers:
       - name: api
-        image: myregistry.io/myapp:1.0
+        image: myregistry.io/myapp:2.0
```

```bash
kubectl apply -f deployment.yaml --dry-run=client -n myapp
# Validate locally without hitting the API server
```
**Sample Output:**
```
deployment.apps/api-deployment configured (dry run)
```

```bash
kubectl apply -f deployment.yaml --dry-run=server -n myapp
# Validate on server (catches webhook / admission controller rejections)
```

---

### 15.4 Side-by-Side Comparison: Docker vs Docker Compose vs kubectl

| Task | Docker | Docker Compose | kubectl |
|------|--------|----------------|---------|
| **Run app** | `docker run -d -p 8080:80 myapp:1.0` | `docker compose up -d` | `kubectl apply -f deployment.yaml` |
| **Stop app** | `docker stop api` | `docker compose down` | `kubectl delete -f deployment.yaml` |
| **Scale** | `docker run` (multiple times) | `docker compose up --scale api=3` | `kubectl scale deployment api --replicas=3` |
| **See running** | `docker ps` | `docker compose ps` | `kubectl get pods -n myapp` |
| **Logs** | `docker logs -f api` | `docker compose logs -f api` | `kubectl logs -f <pod-name>` |
| **Shell into container** | `docker exec -it api bash` | `docker compose exec api bash` | `kubectl exec -it <pod> -- bash` |
| **Env vars** | `-e KEY=value` flag | `environment:` in YAML | ConfigMap / Secret / `env:` in pod spec |
| **Volumes** | `-v /host:/container` | `volumes:` in YAML | PersistentVolumeClaim |
| **Networking** | `--network mynet` | automatic per project | Service (ClusterIP / LoadBalancer) |
| **Forward port locally** | `-p 8080:80` | `ports:` in YAML | `kubectl port-forward` |
| **Copy file** | `docker cp api:/path ./path` | `docker compose cp api:/path ./path` | `kubectl cp ns/pod:/path ./path` |
| **Live resource usage** | `docker stats` | `docker compose stats` | `kubectl top pods` |
| **Restart service** | `docker restart api` | `docker compose restart api` | `kubectl rollout restart deployment/api` |
| **Rolling update** | N/A (single container) | `docker compose up -d --build` | `kubectl set image deployment/api api=img:2.0` |
| **Rollback** | `docker run myapp:1.0` (manually) | change image tag + `up -d` | `kubectl rollout undo deployment/api` |
| **Health check** | `HEALTHCHECK` in Dockerfile | `healthcheck:` in YAML | `livenessProbe` / `readinessProbe` in pod spec |
| **Multi-service start order** | manual / scripting | `depends_on:` | `initContainers` / readiness gates |
| **Config / Secrets** | `-e` flag or `.env` file | `environment:` / `.env` file | ConfigMap + Secret objects |
| **Cleanup all** | `docker system prune -a` | `docker compose down -v --rmi all` | `kubectl delete namespace myapp` |
| **Inspect full config** | `docker inspect api` | `docker compose config` | `kubectl get pod <name> -o yaml` |
| **Disk usage** | `docker system df` | N/A | `kubectl get pvc -n myapp` |
| **Image build** | `docker build -t img:tag .` | `docker compose build` | Build outside k8s, push to registry |
| **Scope** | Single container, one host | Multi-container, one host | Multi-container, multi-node cluster |

---

### 15.5 Equivalent Pattern: "Run a web app with a database"

#### Docker (manual, two containers)
```bash
docker network create mynet
docker volume create sqldata

docker run -d \
  --name db \
  --network mynet \
  -e SA_PASSWORD="P@ssw0rd!" \
  -e ACCEPT_EULA="Y" \
  -v sqldata:/var/opt/mssql \
  mcr.microsoft.com/mssql/server:2022-latest

docker run -d \
  --name api \
  --network mynet \
  -p 8080:80 \
  -e ConnectionStrings__Default="Server=db;Database=mydb;User=sa;Password=P@ssw0rd!" \
  myapp:1.0
```

#### Docker Compose (declarative, same machine)
```yaml
# compose.yaml
services:
  api:
    build: .
    ports: ["8080:80"]
    environment:
      ConnectionStrings__Default: "Server=db;Database=mydb;User=sa;Password=P@ssw0rd!"
    depends_on: [db]
  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      SA_PASSWORD: "P@ssw0rd!"
      ACCEPT_EULA: "Y"
    volumes: ["sqldata:/var/opt/mssql"]
volumes:
  sqldata:
```
```bash
docker compose up -d
```

#### kubectl (declarative, cluster)
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: api, namespace: myapp }
spec:
  replicas: 3
  selector: { matchLabels: { app: api } }
  template:
    metadata: { labels: { app: api } }
    spec:
      containers:
      - name: api
        image: myregistry.io/myapp:1.0
        ports: [{ containerPort: 80 }]
        env:
        - name: ConnectionStrings__Default
          valueFrom:
            secretKeyRef: { name: db-credentials, key: ConnectionString }
---
apiVersion: v1
kind: Service
metadata: { name: api-service, namespace: myapp }
spec:
  type: LoadBalancer
  selector: { app: api }
  ports: [{ port: 80, targetPort: 80 }]
```
```bash
kubectl apply -f deployment.yaml
kubectl get svc api-service -n myapp   # wait for EXTERNAL-IP
```

---

### 15.6 Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                      DOCKER / COMPOSE / kubectl QUICK CARD                              │
├──────────────────────┬──────────────────────────┬──────────────────────────────────────┤
│ DOCKER               │ DOCKER COMPOSE           │ kubectl                              │
├──────────────────────┼──────────────────────────┼──────────────────────────────────────┤
│ build -t img:tag .   │ build                    │ (external: docker build + push)      │
│ run -d -p 8080:80    │ up -d                    │ apply -f deploy.yaml                 │
│ stop api             │ stop                     │ scale deploy/api --replicas=0        │
│ rm api               │ down                     │ delete -f deploy.yaml                │
│ ps                   │ ps                       │ get pods -n ns                       │
│ ps -a                │ ps -a                    │ get pods -A                          │
│ logs -f api          │ logs -f api              │ logs -f <pod>                        │
│ exec -it api bash    │ exec api bash            │ exec -it <pod> -- bash               │
│ stats                │ stats                    │ top pods                             │
│ inspect api          │ config                   │ get pod <name> -o yaml               │
│ cp api:/path ./path  │ cp api:/path ./path      │ cp ns/pod:/path ./path               │
│ images               │ images                   │ get pods (images in describe)        │
│ pull nginx:1.25      │ pull                     │ (set image in deploy spec)           │
│ rmi myapp:0.9        │ (rmi all: down --rmi all)│ (remove from registry)               │
│ network create       │ (auto per project)       │ (Service object)                     │
│ volume create        │ (volumes: section)       │ PVC + StorageClass                   │
│ system prune -a      │ down -v --rmi all        │ delete namespace myapp               │
│ version              │ version                  │ version                              │
│ info                 │ (docker info)            │ cluster-info                         │
└──────────────────────┴──────────────────────────┴──────────────────────────────────────┘
```

---

### 15.7 Azure Networking Layers: Load Balancer → App Gateway → APIM

> **Mental Model:** Each layer adds one capability tier on top of the previous.
> L4 routing (get packets to pods) → L7 WAF (inspect and filter HTTP) → API policies (authenticate, throttle, transform).
> You only pay for the layers you actually need.

---

#### The Full Production Stack

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                               INTERNET                                               │
└─────────────────────────────────┬────────────────────────────────────────────────────┘
                                  │  HTTPS :443
           ┌──────────────────────▼──────────────────────────┐
           │         Azure Application Gateway (L7)           │
           │  • WAF (OWASP 3.2 rules, bot protection)         │  ← Network security perimeter
           │  • SSL/TLS termination  (your cert lives here)   │    Stops malicious traffic
           │  • URL/path-based routing  (/api → svc A)        │    before it reaches app logic
           │  • HTTP→HTTPS redirect, header rewrites          │
           │  Public IP: 52.149.12.34                         │
           └──────────────────────┬──────────────────────────┘
                                  │  HTTP or re-encrypted HTTPS (internal VNet)
           ┌──────────────────────▼──────────────────────────┐
           │         Azure API Management (APIM)              │
           │  • JWT / OAuth2 / API-key validation             │  ← API contract enforcer
           │  • Rate limiting & throttling (per consumer)     │    Handles auth, transforms,
           │  • Request/response transformation               │    versioning, dev portal
           │  • API versioning  (/v1/, /v2/ → different AKS)  │
           │  • Caching, logging, circuit breaker policies    │
           │  • Developer portal  (self-service docs + keys)  │
           │  Mode: Internal VNet  (no public IP)             │
           └──────────────────────┬──────────────────────────┘
                                  │  HTTP to internal AKS service IP
           ┌──────────────────────▼──────────────────────────┐
           │   AKS — Internal Azure Load Balancer (L4)        │
           │  • Provisioned by: Service type: LoadBalancer    │  ← Transport routing
           │    + internal annotation                         │    Distributes TCP across
           │  • Private IP only (e.g. 10.240.0.100)          │    healthy pod endpoints
           │  • Health-probes pod readiness endpoints         │
           └──────────────────────┬──────────────────────────┘
                                  │
           ┌──────────────────────▼──────────────────────────┐
           │                  AKS Pods                        │
           │  (ClusterIP services — never directly exposed)   │
           └──────────────────────────────────────────────────┘
```

---

#### Layer 1 — Service `type: LoadBalancer` → Azure Load Balancer (L4)

When AKS sees a `Service` of type `LoadBalancer`, the **Azure Cloud Controller Manager** calls the Azure API and provisions an Azure Standard Load Balancer automatically.

**External Load Balancer (default — gets public IP):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
  namespace: myapp
spec:
  type: LoadBalancer          # ← triggers Azure LB provisioning
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 80
```
```bash
kubectl apply -f service.yaml -n myapp
kubectl get svc api-service -n myapp
```
**Sample Output:**
```
NAME          TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
api-service   LoadBalancer   10.0.45.123    52.149.12.34    80:31245/TCP   2m
                                            ↑
                          Azure provisioned this public IP automatically
```

**Internal Load Balancer (private VNet IP — used behind App Gateway / APIM):**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service-internal
  namespace: myapp
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"   # ← KEY annotation
    service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "aks-subnet"
spec:
  type: LoadBalancer
  selector:
    app: api
  ports:
    - port: 80
      targetPort: 80
```
```bash
kubectl get svc api-service-internal -n myapp
```
**Sample Output:**
```
NAME                    TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)       AGE
api-service-internal    LoadBalancer   10.0.78.55    10.240.0.100   80:30512/TCP  1m
                                                     ↑
                                      Private VNet IP — unreachable from internet
                                      Only App Gateway / APIM can reach this
```

**What the L4 Load Balancer does and does NOT do:**
```
DOES:
  ✔ Distribute TCP connections to healthy pods
  ✔ Health-probe readiness endpoints (/healthz)
  ✔ Assign public or private IP
  ✔ Handle any TCP protocol (HTTP, gRPC, SQL, MQTT, custom)

DOES NOT:
  ✗ Inspect HTTP headers, URLs, or cookies
  ✗ Terminate TLS (pods receive raw TLS or plain HTTP)
  ✗ Route by path (/api vs /web)
  ✗ Apply WAF rules or block OWASP threats
  ✗ Know about API keys or JWT tokens
```

---

#### Layer 2 — Azure Application Gateway (L7 — HTTP/HTTPS aware)

App Gateway is deployed **outside AKS** in its own subnet. It communicates with pods directly via VNet peering (pod CIDR must be routable to the App Gateway subnet).

**In AKS: AGIC (App Gateway Ingress Controller)**
- AGIC runs as a pod inside AKS
- It watches Kubernetes `Ingress` objects
- Translates them into App Gateway listener/rule/backend pool config
- Pods get `ClusterIP` services; App Gateway calls pod IPs directly (bypasses kube-proxy)

```
┌─────────────────────────────────────────────────────┐
│                   AKS Cluster                        │
│                                                      │
│  ┌──────────────────┐   watches    ┌──────────────┐ │
│  │  AGIC Pod        │────Ingress──▶│  App Gateway │ │
│  │ (azure/ingress-  │   objects    │  (external)  │ │
│  │  azure-ingress)  │◀─programs────│              │ │
│  └──────────────────┘              └──────┬───────┘ │
│                                           │         │
│  ┌──────────┐  ┌──────────┐              │ direct  │
│  │  Pod     │  │  Pod     │◀─────────────┘  pod IP │
│  │ 10.244.1 │  │ 10.244.2 │                        │
│  │  .15:80  │  │  .18:80  │                        │
│  └──────────┘  └──────────┘                        │
└─────────────────────────────────────────────────────┘
```

**Sample Ingress YAML (AGIC):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  namespace: myapp
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/ssl-redirect: "true"
    appgw.ingress.kubernetes.io/waf-policy-for-path: /subscriptions/.../wafpolicies/my-waf
spec:
  tls:
    - hosts: [api.myapp.com]
      secretName: tls-cert              # ← TLS cert stored as K8s Secret
  rules:
    - host: api.myapp.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service: { name: api-service, port: { number: 80 } }
          - path: /admin
            pathType: Prefix
            backend:
              service: { name: admin-service, port: { number: 80 } }
```

**Provision App Gateway + AGIC via Azure CLI:**
```bash
# Create App Gateway in its own subnet
az network application-gateway create \
  --name myAppGateway \
  --resource-group myRG \
  --location eastus \
  --vnet-name myVNet \
  --subnet appgw-subnet \
  --sku WAF_v2 \
  --capacity 2 \
  --frontend-port 443 \
  --public-ip-address myAppGwPublicIP

# Enable AGIC add-on on AKS cluster
az aks enable-addons \
  --resource-group myRG \
  --name myAKSCluster \
  --addons ingress-appgw \
  --appgw-id /subscriptions/.../resourceGroups/myRG/providers/Microsoft.Network/applicationGateways/myAppGateway
```

---

#### Layer 3 — Azure API Management (APIM)

APIM sits **between App Gateway and AKS**. Deployed in **internal VNet mode** — no public IP; only App Gateway can reach it.

```
App Gateway (public) → APIM (internal VNet) → AKS Internal LB (private)
```

**What APIM adds that App Gateway cannot do:**
```
JWT Validation:    Validates Bearer tokens; rejects unauthenticated before hitting AKS
Rate Limiting:     3 calls/second per subscription; 1000/day per consumer tier
Transformation:    Add/remove headers, rewrite body, convert SOAP→REST
Versioning:        /v1/* → AKS deployment v1;  /v2/* → AKS deployment v2
Caching:           Cache GET /products 60s — AKS never called for cached responses
Dev Portal:        Auto-generated docs; devs self-register and get API keys
Mock:              Return 200 {"status":"ok"} while backend is still being built
Circuit Breaker:   If AKS returns 5xx 3x in 10s → return 503 without hitting AKS
```

**Sample APIM Policy XML (JWT validation + rate limiting + versioned routing):**
```xml
<policies>
  <inbound>
    <base />

    <!-- Validate JWT Bearer token -->
    <validate-jwt header-name="Authorization"
                  failed-validation-httpcode="401"
                  failed-validation-error-message="Unauthorized">
      <openid-config url="https://login.microsoftonline.com/{tenant}/.well-known/openid-configuration" />
      <required-claims>
        <claim name="aud">
          <value>api://myapp-client-id</value>
        </claim>
      </required-claims>
    </validate-jwt>

    <!-- Rate limit: 5 calls per 10 seconds per subscription key -->
    <rate-limit-by-key calls="5"
                       renewal-period="10"
                       counter-key="@(context.Subscription.Id)" />

    <!-- Route v1 and v2 to different AKS Internal LB IPs -->
    <choose>
      <when condition="@(context.Request.Url.Path.StartsWith("/v2"))">
        <set-backend-service base-url="http://10.240.0.101" />   <!-- AKS v2 Internal LB -->
      </when>
      <otherwise>
        <set-backend-service base-url="http://10.240.0.100" />   <!-- AKS v1 Internal LB -->
      </otherwise>
    </choose>

    <!-- Strip version prefix before forwarding -->
    <rewrite-uri template="@(context.Request.Url.Path.Replace("/v1","").Replace("/v2",""))" />
  </inbound>
  <outbound>
    <base />
    <!-- Remove internal headers before returning to caller -->
    <set-header name="X-Powered-By" exists-action="delete" />
    <set-header name="Server" exists-action="delete" />
  </outbound>
</policies>
```

**Provision APIM in internal VNet mode:**
```bash
az apim create \
  --name myAPIM \
  --resource-group myRG \
  --location eastus \
  --publisher-email admin@myapp.com \
  --publisher-name "My Company" \
  --sku-name Developer \
  --virtual-network Internal

# Point the APIM backend to the AKS Internal Load Balancer
az apim api create \
  --service-name myAPIM \
  --resource-group myRG \
  --api-id myapp-api \
  --display-name "MyApp API" \
  --path "/" \
  --protocols https \
  --service-url "http://10.240.0.100"   # ← AKS Internal LB private IP
```

---

#### Why App Gateway BEFORE APIM (not after)?

| Concern | App Gateway | APIM |
|---------|-------------|------|
| WAF / OWASP rule sets | Yes — WAF_v2 SKU | No |
| DDoS & bot protection | Yes | No |
| SSL/TLS termination | Yes — offloads certs | Yes (but hand off to AppGW) |
| URL/path-based routing | Yes — listener rules | Yes — policy-based |
| JWT / OAuth2 validation | No | Yes |
| Rate limiting per consumer | No | Yes |
| Request body transformation | No | Yes |
| Developer portal | No | Yes |
| API versioning | No | Yes |
| Response caching | Yes (basic) | Yes (fine-grained) |
| **Sits at** | **Network security perimeter** | **API contract enforcer** |

> **Key Insight:** App Gateway blocks *malicious traffic* (SQLi, XSS, bot floods) before it wastes APIM or AKS resources. APIM then enforces *business rules* on legitimate traffic. Reversing the order would expose APIM's management plane to raw internet attacks.

---

#### When to Skip Layers — Decision Table

| Scenario | Stack | Reason |
|----------|-------|--------|
| Internal microservices only | `ClusterIP` | No external exposure needed |
| Internal tool / low-traffic API | `Service: LoadBalancer` (internal) | AppGW + APIM adds ~$300+/month |
| Public API, WAF required, no API management | App Gateway (AGIC) → AKS pods | WAF needed; no rate-limit/portal required |
| Enterprise API platform (partners + devs) | App Gateway → APIM → AKS Internal LB | Full: WAF + policies + versioning + portal |
| Global high-throughput CDN | Azure Front Door → AKS Internal LB | Front Door = global PoPs + DDoS; replaces AppGW |
| Hybrid internal + external consumers | App Gateway (internet) + APIM (VNet) | AppGW faces internet; APIM also serves VPN partners |

---

#### Traffic Flow: One Request End-to-End

```
1. Client → GET https://api.myapp.com/v2/orders/123
   │
2. [App Gateway — WAF checks]
   │  WAF: no SQLi/XSS detected in path ✔
   │  SSL terminated, certificate validated
   │  Route rule: *.myapp.com → APIM backend pool (10.x.x.x:443)
   │
3. [APIM — inbound policy pipeline]
   │  validate-jwt: Bearer token valid, aud=api://myapp ✔
   │  rate-limit: subscription XYZ under 5/10s limit ✔
   │  choose: path starts /v2 → set-backend-service 10.240.0.101
   │  rewrite-uri: /v2/orders/123 → /orders/123
   │
4. [AKS Internal Load Balancer — 10.240.0.101]
   │  Health probe passes on pod 10.244.2.18 ✔
   │  Forward TCP to pod 10.244.2.18:80
   │
5. [Pod — api-deployment-v2 container]
   │  dotnet handles GET /orders/123
   │  Returns 200 { "orderId": 123, "status": "shipped" }
   │
6. Response travels back:
   Pod → AKS LB → APIM (outbound: strip X-Powered-By, Server headers)
       → App Gateway → Client
```

---

### 15.8 Session Affinity Across the Stack: App Gateway → APIM → AKS

> **Mental Model:** APIM is an identity launderer. It receives requests with a client IP and a session cookie, then makes brand-new connections to AKS using its own IP. The AKS Load Balancer sees only APIM — the client is invisible. Every affinity mechanism must be retrofitted at the application layer, not the network layer.

---

#### The Core Problem

```
Without APIM:
  Client (1.2.3.4) ─────────────────────────────▶ Azure LB ─▶ Pod A (sticky to 1.2.3.4)

With APIM in the middle:
  Client (1.2.3.4) ──▶ App Gateway ──▶ APIM (10.0.0.5) ──▶ Azure LB
                                                                 ├──▶ Pod A
                                                                 ├──▶ Pod B
                                                                 └──▶ Pod C
                                        ↑
                          AKS LB sees only APIM's IP (10.0.0.5)
                          ALL clients look like one source
                          5-tuple hash distributes randomly across pods
```

The **Azure Standard Load Balancer uses a 5-tuple hash** (source IP, source port, dest IP, dest port, protocol). Because APIM opens new TCP connections per request (or uses a connection pool with rotating source ports), even the source port varies — stickiness at the Azure LB level is **unreliable and cannot be relied upon**.

---

#### Layer 1 — App Gateway: ARR Cookie (Client → APIM stickiness)

App Gateway can pin each client to a **specific APIM backend instance** using a cookie (`AppGwAffinity`). This ensures the same client always hits the same APIM node — useful when APIM itself caches per-session policy state.

```bash
# Enable cookie-based affinity in App Gateway backend HTTP settings (pointing to APIM)
az network application-gateway http-settings update \
  --gateway-name myAppGateway \
  --resource-group myRG \
  --name apimHttpSettings \
  --cookie-based-affinity Enabled \
  --affinity-cookie-name "AppGwAffinity"
```

```
Client A ──[AppGwAffinity=hash-A]──▶ APIM Instance 1 ──▶ AKS Pod ?
Client B ──[AppGwAffinity=hash-B]──▶ APIM Instance 2 ──▶ AKS Pod ?
```

**What this solves:** Stable APIM node per client.
**What this does NOT solve:** Which AKS pod the request lands on — APIM still makes a new connection to AKS.

---

#### Layer 2 — APIM: Four Options for Session Identity

**Option A — Forward Client IP (basic, limited)**
```xml
<inbound>
  <!-- Tell AKS the real client IP; NGINX Ingress can use this for routing -->
  <set-header name="X-Forwarded-For" exists-action="override">
    <value>@(context.Request.IpAddress)</value>
  </set-header>
  <set-header name="X-Original-Client-IP" exists-action="override">
    <value>@(context.Request.IpAddress)</value>
  </set-header>
</inbound>
```
The Azure LB ignores this header — only works if NGINX Ingress or app code reads `X-Forwarded-For` for routing logic.

---

**Option B — Pass Through Session Cookie (for NGINX Ingress stickiness)**
```xml
<inbound>
  <!-- APIM forwards the client's INGRESSCOOKIE untouched to AKS -->
  <!-- NGINX Ingress reads this cookie and routes to the pinned pod -->
  <!-- No policy needed: APIM passes all request headers by default -->
  <base />
</inbound>
```
This works automatically — APIM does not strip cookies by default. Pair with NGINX Ingress annotation (see Layer 3 below).

---

**Option C — APIM Cache-Based Sticky Routing (production-grade)**

APIM uses its **internal cache** to remember which backend group was assigned to each session, then uses `set-backend-service` to enforce it:

```xml
<inbound>
  <base />

  <!-- Extract a stable session key: prefer JWT sub, fall back to cookie, then IP -->
  <set-variable name="sessionKey" value="@{
    // Try JWT subject claim first (most stable identifier)
    var jwtSub = context.Request.Headers.GetValueOrDefault("Authorization","")
                   .Replace("Bearer ","");
    if (!string.IsNullOrEmpty(jwtSub)) {
      try {
        var jwt = new System.IdentityModel.Tokens.Jwt.JwtSecurityToken(jwtSub);
        var sub = jwt.Subject;
        if (!string.IsNullOrEmpty(sub)) return sub;
      } catch {}
    }
    // Fall back to session cookie value
    var cookie = context.Request.Headers.GetValueOrDefault("Cookie","")
                   .Split(';')
                   .Select(c => c.Trim())
                   .FirstOrDefault(c => c.StartsWith("SessionId="));
    if (cookie != null) return cookie.Replace("SessionId=","");
    // Last resort: client IP
    return context.Request.IpAddress;
  }" />

  <!-- Look up any previously cached backend assignment for this session -->
  <cache-lookup-value
    key="@("sticky-backend-" + (string)context.Variables["sessionKey"])"
    variable-name="stickyBackend" />

  <choose>
    <!-- Known session: route to previously assigned backend -->
    <when condition="@(context.Variables.ContainsKey("stickyBackend") && !string.IsNullOrEmpty((string)context.Variables["stickyBackend"]))">
      <set-backend-service base-url="@((string)context.Variables["stickyBackend"])" />
    </when>
    <!-- New session: assign backend by consistent hash, cache the assignment -->
    <otherwise>
      <set-variable name="assignedBackend" value="@{
        var backends = new[] {
          "http://10.240.0.100",   // AKS Internal LB — deployment group A
          "http://10.240.0.101"    // AKS Internal LB — deployment group B
        };
        var idx = Math.Abs(((string)context.Variables["sessionKey"]).GetHashCode())
                  % backends.Length;
        return backends[idx];
      }" />
      <!-- Cache for 1 hour (adjust to match your session timeout) -->
      <cache-store-value
        key="@("sticky-backend-" + (string)context.Variables["sessionKey"])"
        value="@((string)context.Variables["assignedBackend"])"
        duration="3600" />
      <set-backend-service base-url="@((string)context.Variables["assignedBackend"])" />
    </otherwise>
  </choose>
</inbound>
```

```
Request 1 (user=alice): no cache entry → assign 10.240.0.100 → cache "sticky-backend-alice"=10.240.0.100
Request 2 (user=alice): cache hit → always route to 10.240.0.100
Request 3 (user=bob):   no cache entry → assign 10.240.0.101 → cache "sticky-backend-bob"=10.240.0.101
```

---

#### Layer 3 — NGINX Ingress: Cookie Affinity at Pod Level

If NGINX Ingress Controller is used as the final hop (instead of a raw ClusterIP service), it can do **cookie-based pod stickiness**. The `INGRESSCOOKIE` travels all the way: Client → App Gateway → APIM (pass-through) → NGINX → same Pod every time.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress-sticky
  namespace: myapp
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/affinity: "cookie"              # ← enable cookie affinity
    nginx.ingress.kubernetes.io/session-cookie-name: "INGRESSCOOKIE"
    nginx.ingress.kubernetes.io/session-cookie-expires: "3600"  # seconds
    nginx.ingress.kubernetes.io/session-cookie-max-age: "3600"
    nginx.ingress.kubernetes.io/session-cookie-path: "/"
    nginx.ingress.kubernetes.io/session-cookie-samesite: "Lax"
spec:
  rules:
    - host: api.myapp.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service: { name: api-service, port: { number: 80 } }
```

**How the cookie travels through the stack:**
```
1. First request (no cookie):
   Client ──▶ AppGW ──▶ APIM (pass-through) ──▶ NGINX ──▶ Pod A
   Response: Set-Cookie: INGRESSCOOKIE=podA-hash (travels back through APIM, AppGW to Client)

2. Subsequent requests (cookie present):
   Client ──[INGRESSCOOKIE=podA-hash]──▶ AppGW ──▶ APIM (forwards cookie) ──▶ NGINX ──▶ Pod A (always)
                                                    ↑
                              APIM passes request cookies through by default
                              No policy change needed for this to work
```

**Important:** APIM does NOT strip request cookies by default, so this works without any policy change. APIM also passes `Set-Cookie` response headers back to the client transparently.

---

#### Why NOT to Use `sessionAffinity: ClientIP` on the K8s Service

```yaml
# AVOID this pattern when APIM is in the chain:
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  sessionAffinity: ClientIP          # ← problematic with APIM
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

**The problem:**
```
APIM Instance 1 IP: 10.0.0.5
APIM Instance 2 IP: 10.0.0.6

ClientIP affinity: 10.0.0.5 → always Pod A
                   10.0.0.6 → always Pod B

Result: ALL traffic from APIM node 1 goes to Pod A
        ALL traffic from APIM node 2 goes to Pod B
        Pods C, D, E get zero traffic → uneven load distribution
```

Use NGINX Ingress cookie affinity or APIM cache-based routing instead.

---

#### Decision Tree: Which Approach to Use

```
Does your AKS app require session stickiness?
│
├── NO (stateless pods) ──▶ No affinity config needed anywhere. Done.
│                           Use distributed cache (Azure Cache for Redis)
│                           for any session state that crosses requests.
│
└── YES ──▶ What kind of stickiness?
            │
            ├── WebSocket / SignalR (long-lived connection to same pod)
            │     ──▶ App Gateway ARR cookie (client → APIM node)
            │         + NGINX Ingress cookie affinity (APIM → pod)
            │         + APIM: set-backend-service bypass policy
            │
            ├── Multi-step form / file upload chunks (same pod for N requests)
            │     ──▶ APIM cache-based routing (Option C above)
            │         + NGINX Ingress cookie affinity as belt-and-suspenders
            │
            └── Legacy in-memory session (HttpContext.Session in ASP.NET)
                  ──▶ BEST: Migrate to Redis IDistributedCache (1-day effort)
                      WORKAROUND: NGINX Ingress cookie affinity
                                  + APIM cookie pass-through (default)
```

---

#### Summary Table

| Layer | Mechanism | Pins | Limitation |
|-------|-----------|------|------------|
| App Gateway | ARR affinity cookie | Client → APIM node | Only helps if APIM is stateful |
| APIM (Option A) | `X-Forwarded-For` header | Passes client IP downstream | Azure LB ignores it; app code must use it |
| APIM (Option B) | Cookie pass-through (default) | Client cookie → NGINX reads it | Requires NGINX Ingress (not Azure LB) as backend |
| APIM (Option C) | Cache-based `set-backend-service` | Session key → backend group | APIM cache is the single source of truth; TTL must match session lifetime |
| K8s `sessionAffinity: ClientIP` | Source IP hash | APIM IP → pod | All APIM traffic → 1 pod; breaks load distribution |
| NGINX Ingress cookie affinity | `INGRESSCOOKIE` header | Cookie hash → specific pod | Requires NGINX Ingress; cookie must survive AppGW → APIM round-trip (it does by default) |

> **Key Insight:** The cleanest production solution is: **stateless pods + Redis for session state**. If you must have stickiness, **NGINX Ingress cookie affinity** is the most reliable mechanism in this stack because the cookie travels transparently through App Gateway and APIM without any policy configuration.

---

*End of Azure Kubernetes Service Complete Guide*

> **Last Updated:** February 2026
> **Kubernetes Version Coverage:** 1.27 – 1.31
> **AKS CLI Version:** Azure CLI 2.60+
> **Reference Apps:** SimpleApi1, SimpleApi2 (.NET 10 Minimal API)
> **Total Sections:** 22 Parts, 80+ Topics


# Kubernetes Manifest Objects — Expanded Mind Map

## Legend
```
  ●  Common field  — shared across 3 or more manifest kinds
  ◆  Unique field  — specific to this manifest kind only
  ⊛  Selector     — label / name / ref matching that LINKS objects together
  ▸  Enum values  — allowed options for a field
```
---

```
K8s Manifest Objects
│
│  ╔══════════════════════════════════════════════════════════╗
│  ║  EVERY manifest shares this metadata block              ║
│  ║  ● metadata.name          (required)                    ║
│  ║  ● metadata.namespace     (omit for cluster-scoped)     ║
│  ║  ● metadata.labels        (key: value pairs)            ║
│  ║  ● metadata.annotations   (key: value pairs)            ║
│  ║  ● metadata.finalizers[]  (prevents deletion until done)║
│  ╚══════════════════════════════════════════════════════════╝
│
├─────────────────────────────────────────────────────────────
│  WORKLOADS
├─────────────────────────────────────────────────────────────
│
│   ┌─── Pod  (base building block; all workloads wrap a pod template)
│   │
│   │   spec
│   │   │
│   │   ├── containers[]                               ●
│   │   │   ├── name                                   ●
│   │   │   ├── image                                  ●
│   │   │   ├── imagePullPolicy                        ●  ▸ Always | IfNotPresent | Never
│   │   │   ├── ports[]                                ●
│   │   │   │   ├── containerPort                      ●
│   │   │   │   ├── name                               ●  (referenced by Service targetPort)
│   │   │   │   └── protocol                           ●  ▸ TCP | UDP | SCTP
│   │   │   ├── env[]                                  ●
│   │   │   │   ├── name / value                       ●  (literal value)
│   │   │   │   └── valueFrom                          ●
│   │   │   │       ├── configMapKeyRef.name / key     ●  ⊛ links to ConfigMap
│   │   │   │       ├── secretKeyRef.name / key        ●  ⊛ links to Secret
│   │   │   │       ├── fieldRef.fieldPath             ●  (downward API: pod metadata)
│   │   │   │       └── resourceFieldRef               ●  (downward API: cpu/mem)
│   │   │   ├── envFrom[]                              ●
│   │   │   │   ├── configMapRef.name                  ●  ⊛ links entire ConfigMap
│   │   │   │   ├── secretRef.name                     ●  ⊛ links entire Secret
│   │   │   │   └── prefix                             ●  (adds prefix to all keys)
│   │   │   ├── resources                              ●
│   │   │   │   ├── requests.cpu / memory              ●  (scheduler uses this)
│   │   │   │   └── limits.cpu / memory                ●  (enforced at runtime)
│   │   │   ├── volumeMounts[]                         ●
│   │   │   │   ├── name                               ●  ⊛ matches spec.volumes[].name
│   │   │   │   ├── mountPath                          ●
│   │   │   │   ├── subPath                            ●  (mount single file in volume)
│   │   │   │   └── readOnly                           ●
│   │   │   ├── livenessProbe                          ●  (restart if fails)
│   │   │   │   ├── httpGet.path / port / scheme       ●
│   │   │   │   ├── exec.command[]                     ●
│   │   │   │   ├── tcpSocket.port                     ●
│   │   │   │   ├── initialDelaySeconds                ●
│   │   │   │   ├── periodSeconds                      ●
│   │   │   │   ├── failureThreshold                   ●
│   │   │   │   └── successThreshold                   ●
│   │   │   ├── readinessProbe                         ●  (remove from Service endpoints if fails)
│   │   │   │   └── (same sub-fields as livenessProbe) ●
│   │   │   ├── startupProbe                           ●  (gate liveness until app ready)
│   │   │   │   └── (same sub-fields as livenessProbe) ●
│   │   │   ├── securityContext                        ●
│   │   │   │   ├── runAsUser / runAsGroup             ●
│   │   │   │   ├── runAsNonRoot                       ●
│   │   │   │   ├── allowPrivilegeEscalation           ●
│   │   │   │   ├── readOnlyRootFilesystem             ●
│   │   │   │   └── capabilities.add[] / drop[]        ●
│   │   │   ├── command[]                              ●  (overrides ENTRYPOINT)
│   │   │   ├── args[]                                 ●  (overrides CMD)
│   │   │   └── lifecycle.postStart / preStop          ●  (hooks)
│   │   │
│   │   ├── initContainers[]                           ●  (run sequentially before containers)
│   │   │   └── (same shape as containers[])           ●
│   │   │
│   │   ├── volumes[]                                  ●
│   │   │   ├── name                                   ●  ⊛ referenced by volumeMounts[].name
│   │   │   ├── configMap.name                         ●  ⊛ links to ConfigMap
│   │   │   │   └── items[].key / path                 ●  (mount specific keys as files)
│   │   │   ├── secret.secretName                      ●  ⊛ links to Secret
│   │   │   │   └── items[].key / path                 ●
│   │   │   ├── persistentVolumeClaim.claimName        ●  ⊛ links to PVC
│   │   │   ├── emptyDir: {}                           ●  (ephemeral; lives with pod)
│   │   │   │   └── medium: Memory                     ◆  (RAM-backed tmpfs)
│   │   │   ├── hostPath.path / type                   ◆  (node filesystem; avoid in prod)
│   │   │   ├── projected.sources[]                    ◆  (combine CM + Secret + SA token)
│   │   │   └── csi.driver / volumeAttributes          ◆  (CSI inline volume)
│   │   │
│   │   ├── serviceAccountName                         ●  ⊛ links to ServiceAccount
│   │   ├── automountServiceAccountToken               ●  (false to disable token mount)
│   │   ├── imagePullSecrets[].name                    ●  ⊛ links to Secret (dockerconfig type)
│   │   │
│   │   ├── nodeSelector                               ●  ⊛ simple label match on Node
│   │   ├── tolerations[]                              ●  ⊛ match Node taints
│   │   │   ├── key / value / operator                 ●
│   │   │   └── effect ▸ NoSchedule|PreferNoSchedule|NoExecute
│   │   ├── affinity                                   ●
│   │   │   ├── nodeAffinity                           ●  ⊛ advanced Node label matching
│   │   │   │   ├── requiredDuringSchedulingIgnoredDuringExecution
│   │   │   │   │   └── nodeSelectorTerms[].matchExpressions[]
│   │   │   │   └── preferredDuringSchedulingIgnoredDuringExecution
│   │   │   │       └── weight + preference.matchExpressions[]
│   │   │   ├── podAffinity                            ●  ⊛ co-locate with matching pods
│   │   │   │   └── requiredDuringScheduling... / preferredDuringScheduling...
│   │   │   └── podAntiAffinity                        ●  ⊛ spread away from matching pods
│   │   │
│   │   ├── topologySpreadConstraints[]                ◆
│   │   │   ├── maxSkew                                ◆
│   │   │   ├── topologyKey                            ◆  ⊛ node label key for zones
│   │   │   ├── whenUnsatisfiable ▸ DoNotSchedule | ScheduleAnyway
│   │   │   └── labelSelector                          ◆  ⊛ which pods to count
│   │   │
│   │   ├── restartPolicy                              ●  ▸ Always(Pod) | OnFailure(Job) | Never
│   │   ├── terminationGracePeriodSeconds              ●
│   │   ├── dnsPolicy ▸ ClusterFirst | None | Default  ◆
│   │   ├── dnsConfig.nameservers[] / searches[]       ◆
│   │   ├── hostNetwork: true                          ◆  (share node network namespace)
│   │   ├── hostPID / hostIPC                          ◆
│   │   ├── priorityClassName                          ●  ⊛ links to PriorityClass
│   │   └── securityContext (pod-level)                ●
│   │       ├── runAsUser / runAsGroup / fsGroup       ●
│   │       ├── runAsNonRoot                           ●
│   │       └── sysctls[]                              ◆
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── Deployment  (manages ReplicaSets; rolling updates)
│   │
│   │   spec
│   │   ├── replicas                                   ●  (also StatefulSet)
│   │   ├── selector                                   ●  ⊛ MUST match template.metadata.labels
│   │   │   └── matchLabels / matchExpressions         ●  ⊛ (immutable after creation)
│   │   ├── strategy                                   ◆
│   │   │   ├── type ▸ RollingUpdate | Recreate        ◆
│   │   │   └── rollingUpdate                          ◆
│   │   │       ├── maxSurge       (extra pods; default 25%)   ◆
│   │   │       └── maxUnavailable (pods down; default 25%)    ◆
│   │   ├── minReadySeconds                            ◆  (wait before marking pod ready)
│   │   ├── revisionHistoryLimit                       ◆  (kept ReplicaSets; default 10)
│   │   ├── progressDeadlineSeconds                    ◆  (fail if no progress in N sec)
│   │   ├── paused                                     ◆  (pause rollout)
│   │   └── template                                   ●  ⊛ → Pod metadata + spec
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── StatefulSet  (ordered pods; stable identity + storage)
│   │
│   │   spec
│   │   ├── serviceName                                ◆  ⊛ name of Headless Service (required)
│   │   ├── replicas                                   ●  (also Deployment)
│   │   ├── selector                                   ●  ⊛ matchLabels (immutable)
│   │   ├── podManagementPolicy ▸ OrderedReady|Parallel◆
│   │   ├── updateStrategy                             ◆
│   │   │   ├── type ▸ RollingUpdate | OnDelete        ◆
│   │   │   └── rollingUpdate.partition                ◆  (only update pods ≥ partition index)
│   │   ├── volumeClaimTemplates[]                     ◆  (PVC created per pod; survives pod delete)
│   │   │   ├── metadata.name                          ◆
│   │   │   └── spec (accessModes / resources / storageClassName)  ◆
│   │   ├── persistentVolumeClaimRetentionPolicy       ◆
│   │   │   ├── whenDeleted ▸ Retain | Delete          ◆
│   │   │   └── whenScaled  ▸ Retain | Delete          ◆
│   │   └── template                                   ●  ⊛ → Pod metadata + spec
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── DaemonSet  (one pod per node; no replicas)
│   │
│   │   spec
│   │   ├── selector                                   ●  ⊛ matchLabels (immutable)
│   │   ├── updateStrategy                             ◆
│   │   │   ├── type ▸ RollingUpdate | OnDelete        ◆
│   │   │   └── rollingUpdate.maxUnavailable           ◆
│   │   ├── minReadySeconds                            ◆
│   │   └── template                                   ●  ⊛ → Pod metadata + spec
│   │   ── NO spec.replicas (one pod per matching node) ◆
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── Job  (run-to-completion; batch tasks)
│   │
│   │   spec
│   │   ├── completions                                ◆  (total successful pods needed)
│   │   ├── parallelism                                ◆  (max pods running simultaneously)
│   │   ├── completionMode ▸ NonIndexed | Indexed      ◆  (Indexed → env JOB_COMPLETION_INDEX)
│   │   ├── backoffLimit                               ◆  (retry count before marking failed)
│   │   ├── backoffLimitPerIndex                       ◆  (per index retry in Indexed mode)
│   │   ├── activeDeadlineSeconds                      ◆  (hard timeout for entire Job)
│   │   ├── ttlSecondsAfterFinished                    ◆  (auto-delete after completion)
│   │   ├── suspend                                    ◆  (pause job; pods are deleted)
│   │   ├── manualSelector                             ◆  (true to hand-craft selector)
│   │   ├── selector                                   ●  ⊛ auto-generated unless manualSelector
│   │   └── template                                   ●  ⊛ → Pod spec (restartPolicy: Never|OnFailure)
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── CronJob  (scheduled Jobs; like cron + Job)
│   │
│   │   spec
│   │   ├── schedule                                   ◆  "min hr dom mon dow" e.g. "*/5 * * * *"
│   │   ├── timezone                                   ◆  e.g. "America/New_York"
│   │   ├── concurrencyPolicy ▸ Allow|Forbid|Replace   ◆
│   │   ├── startingDeadlineSeconds                    ◆  (skip if missed by N sec)
│   │   ├── suspend                                    ◆  (pause without deleting)
│   │   ├── successfulJobsHistoryLimit                 ◆  (default 3)
│   │   ├── failedJobsHistoryLimit                     ◆  (default 1)
│   │   └── jobTemplate                                ◆  → Job spec (not a pod template directly)
│   │
│   └───────────────────────────────────────────────────────
│
├─────────────────────────────────────────────────────────────
│  NETWORKING
├─────────────────────────────────────────────────────────────
│
│   ┌─── Service  (stable IP/DNS endpoint in front of pods)
│   │
│   │   spec
│   │   ├── selector                                   ●  ⊛ key:value → pods by label
│   │   │   └── (omit → manual Endpoints/EndpointSlice)●  ⊛ headless or external
│   │   ├── type                                       ◆  ▸ ClusterIP | NodePort | LoadBalancer | ExternalName
│   │   │   ├── ClusterIP     → internal virtual IP    ◆
│   │   │   ├── NodePort      → port on every node     ◆
│   │   │   ├── LoadBalancer  → cloud LB (wraps NP)   ◆
│   │   │   └── ExternalName  → CNAME alias; no proxy  ◆
│   │   ├── ports[]                                    ◆
│   │   │   ├── name                                   ◆  (multi-port: must name each)
│   │   │   ├── protocol ▸ TCP | UDP | SCTP            ◆
│   │   │   ├── appProtocol                            ◆  (e.g. kubernetes.io/h2c)
│   │   │   ├── port                                   ◆  (service-side port)
│   │   │   ├── targetPort                             ◆  ⊛ pod port number OR named port
│   │   │   └── nodePort                               ◆  (30000-32767; NodePort/LB only)
│   │   ├── clusterIP                                  ◆  ("None" → headless; "" → auto-assign)
│   │   ├── clusterIPs[]                               ◆  (dual-stack IPv4/IPv6)
│   │   ├── externalName                               ◆  ⊛ FQDN for ExternalName type
│   │   ├── externalIPs[]                              ◆  (external IPs that route to service)
│   │   ├── sessionAffinity ▸ None | ClientIP          ◆
│   │   ├── sessionAffinityConfig.clientIP.timeoutSeconds ◆
│   │   ├── externalTrafficPolicy ▸ Cluster | Local    ◆  (Local preserves src IP)
│   │   ├── internalTrafficPolicy ▸ Cluster | Local    ◆
│   │   ├── loadBalancerIP                             ◆  (request specific LB IP)
│   │   ├── loadBalancerSourceRanges[]                 ◆  (allowlist CIDRs)
│   │   └── publishNotReadyAddresses                   ◆  (include unready pods in DNS)
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── Ingress  (HTTP/S routing into the cluster via IngressController)
│   │
│   │   metadata.annotations  (controller-specific config)   ◆
│   │   ├── kubernetes.io/ingress.class                ◆
│   │   ├── nginx.ingress.kubernetes.io/rewrite-target ◆
│   │   ├── nginx.ingress.kubernetes.io/ssl-redirect   ◆
│   │   ├── nginx.ingress.kubernetes.io/proxy-body-size◆
│   │   ├── nginx.ingress.kubernetes.io/use-regex      ◆
│   │   └── cert-manager.io/cluster-issuer             ◆  ⊛ links to ClusterIssuer
│   │
│   │   spec
│   │   ├── ingressClassName                           ◆  ⊛ links to IngressClass resource
│   │   ├── defaultBackend                             ◆  (catch-all if no rule matches)
│   │   │   └── service.name / port.number             ◆  ⊛ links to Service
│   │   ├── tls[]                                      ◆
│   │   │   ├── hosts[]                                ◆
│   │   │   └── secretName                             ◆  ⊛ links to Secret (kubernetes.io/tls)
│   │   └── rules[]                                    ◆
│   │       ├── host                                   ◆  (FQDN; omit for wildcard)
│   │       └── http.paths[]                           ◆
│   │           ├── path                               ◆
│   │           ├── pathType ▸ Exact|Prefix|ImplementationSpecific  ◆
│   │           └── backend.service.name / port.number ◆  ⊛ links to Service
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── NetworkPolicy  (L3/L4 firewall rules for pods)
│   │
│   │   spec
│   │   ├── podSelector                                ◆  ⊛ which pods THIS policy applies to
│   │   │   ├── matchLabels {}  (empty = all pods in ns)◆  ⊛
│   │   │   └── matchExpressions[]                     ◆  ⊛
│   │   ├── policyTypes[]                              ◆  ▸ Ingress | Egress (or both)
│   │   ├── ingress[]                                  ◆  (allow inbound rules; omit = deny all in)
│   │   │   ├── from[]                                 ◆
│   │   │   │   ├── podSelector.matchLabels            ◆  ⊛ pods in SAME namespace
│   │   │   │   ├── namespaceSelector.matchLabels      ◆  ⊛ pods in SELECTED namespaces
│   │   │   │   └── ipBlock.cidr / except[]            ◆  (CIDR-based; for external IPs)
│   │   │   └── ports[]                                ◆
│   │   │       ├── port                               ◆
│   │   │       └── protocol ▸ TCP | UDP               ◆
│   │   └── egress[]                                   ◆  (allow outbound rules; omit = deny all out)
│   │       ├── to[]  (same selectors as ingress.from[])◆  ⊛
│   │       └── ports[].port / protocol                ◆
│   │
│   └───────────────────────────────────────────────────────
│
├─────────────────────────────────────────────────────────────
│  CONFIG & SECRETS
├─────────────────────────────────────────────────────────────
│
│   ┌─── ConfigMap  (non-sensitive configuration data)
│   │
│   │   ├── data                                       ◆  key: plain-text-value
│   │   ├── binaryData                                 ◆  key: base64-value
│   │   └── immutable                                  ◆  (true → prevent changes; better perf)
│   │   ── consumed via ──────────────────────────────────
│   │   ├── envFrom[].configMapRef.name                ●  ⊛ all keys → env vars
│   │   ├── env[].valueFrom.configMapKeyRef.name + key ●  ⊛ single key → env var
│   │   └── volumes[].configMap.name                   ●  ⊛ keys mounted as files
│   │       └── items[].key + path                     ●  (selective file mount)
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── Secret  (sensitive data; base64 encoded at rest; use RBAC to guard)
│   │
│   │   ├── type                                       ◆
│   │   │   ├── Opaque                      (generic; default)    ◆
│   │   │   ├── kubernetes.io/tls           (tls.crt + tls.key)   ◆
│   │   │   ├── kubernetes.io/dockerconfigjson  (.dockerconfigjson) ◆
│   │   │   ├── kubernetes.io/service-account-token                 ◆
│   │   │   └── kubernetes.io/basic-auth    (username + password)  ◆
│   │   ├── data                                       ◆  key: base64-encoded-value
│   │   ├── stringData                                 ◆  key: plain-text (write-only shortcut)
│   │   └── immutable                                  ◆  (true → prevent changes)
│   │   ── consumed via ──────────────────────────────────
│   │   ├── envFrom[].secretRef.name                   ●  ⊛ all keys → env vars
│   │   ├── env[].valueFrom.secretKeyRef.name + key    ●  ⊛ single key → env var
│   │   ├── volumes[].secret.secretName                ●  ⊛ keys mounted as files
│   │   └── imagePullSecrets[].name                    ●  ⊛ (dockerconfigjson type)
│   │
│   └───────────────────────────────────────────────────────
│
├─────────────────────────────────────────────────────────────
│  STORAGE
├─────────────────────────────────────────────────────────────
│
│   ┌─── PersistentVolume  (PV)  (cluster-scoped storage asset)
│   │
│   │   spec
│   │   ├── capacity.storage                           ◆  e.g. "100Gi"
│   │   ├── accessModes[]                              ●  (also PVC; must overlap)
│   │   │   ├── ReadWriteOnce   (RWO) — one node rw   ●
│   │   │   ├── ReadOnlyMany    (ROX) — many nodes ro  ●
│   │   │   ├── ReadWriteMany   (RWX) — many nodes rw  ●
│   │   │   └── ReadWriteOncePod(RWOP)— one pod rw     ◆
│   │   ├── persistentVolumeReclaimPolicy              ◆
│   │   │   ├── Retain  — keep data; admin cleans up   ◆
│   │   │   ├── Delete  — auto-delete on PVC release   ◆
│   │   │   └── Recycle — deprecated basic scrub       ◆
│   │   ├── storageClassName                           ●  ⊛ links to StorageClass
│   │   ├── volumeMode ▸ Filesystem | Block            ●  (also PVC)
│   │   ├── mountOptions[]                             ◆  (e.g. "hard","nfsvers=4.1")
│   │   ├── nodeAffinity                               ◆  ⊛ pin PV to specific Nodes
│   │   │   └── required.nodeSelectorTerms[].matchExpressions[]  ◆  ⊛
│   │   └── <driver-block>  (exactly one)              ◆
│   │       ├── csi.driver / volumeHandle / fsType / volumeAttributes  ◆
│   │       ├── nfs.server / path                      ◆
│   │       ├── hostPath.path / type                   ◆
│   │       └── azureDisk / azureFile (legacy)         ◆
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── PersistentVolumeClaim  (PVC)  (user's request for storage)
│   │
│   │   spec
│   │   ├── accessModes[]                              ●  (must be subset of target PV)
│   │   ├── resources.requests.storage                 ◆  e.g. "20Gi"
│   │   ├── storageClassName                           ●  ⊛ links to StorageClass (dynamic provisioning)
│   │   ├── volumeMode ▸ Filesystem | Block            ●
│   │   ├── volumeName                                 ◆  ⊛ pin-bind to specific PV by name
│   │   ├── selector.matchLabels                       ◆  ⊛ select PV by labels (static bind)
│   │   └── dataSource                                 ◆
│   │       ├── kind ▸ VolumeSnapshot | PersistentVolumeClaim  ◆  ⊛
│   │       └── name                                   ◆  ⊛ source snapshot or PVC to clone
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── StorageClass  (cluster-scoped; defines HOW to provision PVs)
│   │
│   │   ├── provisioner                                ◆  ⊛ driver name (links to CSI driver)
│   │   │   ├── disk.csi.azure.com                     ◆
│   │   │   ├── file.csi.azure.com                     ◆
│   │   │   └── ebs.csi.aws.com / etc.                 ◆
│   │   ├── parameters {}                              ◆  (driver-specific)
│   │   │   ├── skuName ▸ Premium_LRS | Standard_LRS   ◆
│   │   │   ├── kind    ▸ Managed | Shared             ◆
│   │   │   └── fsType  ▸ ext4 | xfs                   ◆
│   │   ├── reclaimPolicy ▸ Delete | Retain            ◆
│   │   ├── allowVolumeExpansion                       ◆  (true → allow resize after bind)
│   │   ├── mountOptions[]                             ◆
│   │   ├── volumeBindingMode                          ◆
│   │   │   ├── Immediate          (provision on PVC create)   ◆
│   │   │   └── WaitForFirstConsumer (wait for pod scheduling) ◆
│   │   └── allowedTopologies[]                        ◆  ⊛ restrict to zones/regions
│   │       └── matchLabelExpressions[].key / values[] ◆  ⊛
│   │
│   └───────────────────────────────────────────────────────
│
├─────────────────────────────────────────────────────────────
│  RBAC
├─────────────────────────────────────────────────────────────
│
│   ┌─── ServiceAccount  (identity for processes inside pods)
│   │
│   │   ├── metadata.name / namespace                  ●  ⊛ referenced by pod.spec.serviceAccountName
│   │   ├── automountServiceAccountToken               ◆  (false → disable auto-mount)
│   │   ├── imagePullSecrets[].name                    ●  ⊛ inherited by pods using this SA
│   │   └── secrets[]                                  ◆  (legacy token secrets; K8s 1.24+ auto-managed)
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── Role  (namespaced permissions)
│   │   ClusterRole  (cluster-wide permissions; same structure)
│   │
│   │   ├── rules[]                                    ◆
│   │   │   ├── apiGroups[]                            ◆  ("" = core | "apps" | "batch" | "networking.k8s.io" …)
│   │   │   ├── resources[]                            ◆  (pods | deployments | secrets | services …)
│   │   │   ├── resourceNames[]                        ◆  (optional; limit to named instances)
│   │   │   └── verbs[]                                ◆  (get | list | watch | create | update | patch | delete | *)
│   │   └── aggregationRule  (ClusterRole only)        ◆
│   │       └── clusterRoleSelectors[].matchLabels     ◆  ⊛ merge other ClusterRoles by label
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── RoleBinding  (bind Role or ClusterRole in one namespace)
│   │   ClusterRoleBinding  (cluster-wide binding; same structure)
│   │
│   │   ├── subjects[]                                 ◆
│   │   │   ├── kind ▸ User | Group | ServiceAccount   ◆
│   │   │   ├── name                                   ◆  ⊛ exact name of user/group/SA
│   │   │   ├── namespace                              ◆  ⊛ required for ServiceAccount subject
│   │   │   └── apiGroup: rbac.authorization.k8s.io   ◆
│   │   └── roleRef                                    ◆  ⊛ (immutable after creation)
│   │       ├── kind ▸ Role | ClusterRole              ◆  ⊛
│   │       ├── name                                   ◆  ⊛ name of the Role/ClusterRole
│   │       └── apiGroup: rbac.authorization.k8s.io   ◆
│   │
│   └───────────────────────────────────────────────────────
│
├─────────────────────────────────────────────────────────────
│  AUTOSCALING
├─────────────────────────────────────────────────────────────
│
│   ┌─── HorizontalPodAutoscaler  (HPA)  (scales replicas based on metrics)
│   │
│   │   spec
│   │   ├── scaleTargetRef                             ◆  ⊛ which workload to scale
│   │   │   ├── apiVersion                             ◆  ⊛
│   │   │   ├── kind ▸ Deployment | StatefulSet        ◆  ⊛
│   │   │   └── name                                   ◆  ⊛
│   │   ├── minReplicas                                ◆
│   │   ├── maxReplicas                                ◆
│   │   ├── metrics[]                                  ◆
│   │   │   ├── type: Resource                         ◆
│   │   │   │   └── resource.name (cpu|memory)         ◆
│   │   │   │       └── target.type ▸ Utilization | AverageValue | Value  ◆
│   │   │   │           └── averageUtilization / averageValue / value      ◆
│   │   │   ├── type: ContainerResource                ◆  (per-container metrics)
│   │   │   ├── type: Pods                             ◆
│   │   │   │   └── pods.metric.name / target.averageValue  ◆
│   │   │   ├── type: Object                           ◆  (e.g. requests-per-second on Ingress)
│   │   │   └── type: External                         ◆  (KEDA; external queue depth etc.)
│   │   └── behavior                                   ◆
│   │       ├── scaleDown.stabilizationWindowSeconds   ◆  (cool-down; default 300s)
│   │       ├── scaleDown.policies[].type / value / periodSeconds  ◆
│   │       ├── scaleUp.stabilizationWindowSeconds     ◆  (default 0)
│   │       └── scaleUp.policies[].type / value / periodSeconds    ◆
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── VerticalPodAutoscaler  (VPA)  (right-sizes CPU/memory requests)
│   │
│   │   spec
│   │   ├── targetRef                                  ◆  ⊛ same shape as HPA.scaleTargetRef
│   │   ├── updatePolicy.updateMode                    ◆  ▸ Off | Initial | Recreate | Auto
│   │   └── resourcePolicy.containerPolicies[]         ◆
│   │       ├── containerName                          ◆  ⊛ (or "*" for all containers)
│   │       ├── minAllowed.cpu / memory                ◆
│   │       ├── maxAllowed.cpu / memory                ◆
│   │       ├── controlledResources[]                  ◆  (cpu | memory)
│   │       └── controlledValues ▸ RequestsAndLimits | RequestsOnly  ◆
│   │
│   └───────────────────────────────────────────────────────
│
├─────────────────────────────────────────────────────────────
│  POLICY & LIMITS
├─────────────────────────────────────────────────────────────
│
│   ┌─── LimitRange  (default + ceilings per container/pod/PVC in a namespace)
│   │
│   │   spec.limits[]                                  ◆
│   │   ├── type ▸ Container | Pod | PersistentVolumeClaim  ◆
│   │   ├── default          (applied if limits not set)    ◆
│   │   │   └── cpu / memory                          ◆
│   │   ├── defaultRequest   (applied if requests not set)  ◆
│   │   │   └── cpu / memory                          ◆
│   │   ├── max              (upper ceiling; request+limit ≤ max)  ◆
│   │   │   └── cpu / memory / storage (for PVC type)  ◆
│   │   ├── min              (lower floor)              ◆
│   │   │   └── cpu / memory                          ◆
│   │   └── maxLimitRequestRatio                       ◆  (limit must be ≤ ratio × request)
│   │       └── cpu / memory                          ◆
│   │
│   └───────────────────────────────────────────────────────
│
│   ┌─── ResourceQuota  (namespace-level aggregate ceilings)
│   │
│   │   spec
│   │   ├── hard {}                                    ◆
│   │   │   ├── requests.cpu / requests.memory        ◆
│   │   │   ├── limits.cpu / limits.memory             ◆
│   │   │   ├── pods                                   ◆
│   │   │   ├── services / services.nodeports / services.loadbalancers  ◆
│   │   │   ├── secrets / configmaps / persistentvolumeclaims  ◆
│   │   │   ├── count/<resource>.<group>               ◆
│   │   │   └── requests.storage / <storageClassName>.storageclass.storage.k8s.io/requests.storage  ◆
│   │   ├── scopeSelector                              ◆  ⊛ limit quota to pod subset
│   │   │   └── matchExpressions[].scopeName / operator / values  ◆  ⊛
│   │   └── scopes[]                                   ◆  ▸ BestEffort|NotBestEffort|Terminating|NotTerminating
│   │
│   └───────────────────────────────────────────────────────
│
└─────────────────────────────────────────────────────────────
   CLUSTER
└─────────────────────────────────────────────────────────────

    ┌─── Namespace  (isolation boundary; scope for most resources)
    │
    │   ├── metadata.name                              ◆
    │   ├── metadata.labels                            ●  ⊛ targeted by NetworkPolicy namespaceSelector
    │   └── spec.finalizers[]                          ◆  (e.g. kubernetes; prevent delete until empty)
    │
    └───────────────────────────────────────────────────────

    ┌─── Node  (managed by control plane; rarely hand-authored)
    │
    │   ├── metadata.labels {}                         ◆  ⊛ targeted by nodeSelector / nodeAffinity
    │   ├── spec.taints[]                              ◆  ⊛ repel pods unless they tolerate
    │   │   ├── key / value                            ◆
    │   │   └── effect ▸ NoSchedule|PreferNoSchedule|NoExecute  ◆
    │   ├── spec.unschedulable                         ◆  (true = cordoned; kubectl cordon)
    │   ├── status.conditions[]                        ◆  (Ready | MemoryPressure | DiskPressure …)
    │   ├── status.capacity.cpu / memory / pods        ◆
    │   └── status.allocatable.cpu / memory / pods     ◆  (capacity minus system reserved)
    │
    └───────────────────────────────────────────────────────
```

---

## Cross-Object Selector Map

```
Who selects          ──via──              What it selects
────────────────────────────────────────────────────────────────────────────────
Deployment           spec.selector        ──⊛──> Pods (by label)
StatefulSet          spec.selector        ──⊛──> Pods (by label)
DaemonSet            spec.selector        ──⊛──> Pods (by label)
Job                  spec.selector        ──⊛──> Pods (by label; auto-generated)
Service              spec.selector        ──⊛──> Pods (by label) → Endpoints
Ingress              spec.rules.backend   ──⊛──> Service (by name)
Ingress              spec.tls.secretName  ──⊛──> Secret (tls type)
NetworkPolicy        spec.podSelector     ──⊛──> Pods this policy applies to
NetworkPolicy        ingress.from.podSelector  ──⊛──> allowed source Pods
NetworkPolicy        ingress.from.namespaceSelector ──⊛──> allowed source Namespaces
HPA                  spec.scaleTargetRef  ──⊛──> Deployment / StatefulSet (by name)
VPA                  spec.targetRef       ──⊛──> Deployment / StatefulSet (by name)
RoleBinding          roleRef              ──⊛──> Role / ClusterRole (by name)
RoleBinding          subjects[].name      ──⊛──> User / Group / ServiceAccount
Pod                  serviceAccountName   ──⊛──> ServiceAccount (by name)
Pod                  nodeSelector         ──⊛──> Node (by label)
Pod                  tolerations          ──⊛──> Node taints (key+effect match)
Pod                  affinity.nodeAffinity──⊛──> Nodes (by label expressions)
Pod                  affinity.podAffinity ──⊛──> Pods (co-locate by label)
Pod                  affinity.podAntiAffinity ──⊛──> Pods (spread by label)
Pod                  env.configMapKeyRef  ──⊛──> ConfigMap (by name + key)
Pod                  env.secretKeyRef     ──⊛──> Secret (by name + key)
Pod                  volumes.configMap    ──⊛──> ConfigMap (by name)
Pod                  volumes.secret       ──⊛──> Secret (by name)
Pod                  volumes.pvc          ──⊛──> PersistentVolumeClaim (by name)
PVC                  storageClassName     ──⊛──> StorageClass (by name)
PVC                  volumeName           ──⊛──> PersistentVolume (by name, static bind)
PVC                  selector.matchLabels ──⊛──> PersistentVolume (by label, static bind)
PV                   storageClassName     ──⊛──> StorageClass (by name)
PV                   nodeAffinity         ──⊛──> Nodes (zone/region pin)
StorageClass         provisioner          ──⊛──> CSI Driver (by name)
StatefulSet          spec.serviceName     ──⊛──> Headless Service (by name)
```

---

## apiVersion Quick Reference

| Kind | apiVersion |
|---|---|
| Pod, Service, ConfigMap, Secret, Namespace, PV, PVC, ServiceAccount, LimitRange, ResourceQuota | `v1` |
| Deployment, StatefulSet, DaemonSet, ReplicaSet | `apps/v1` |
| Job, CronJob | `batch/v1` |
| Ingress, NetworkPolicy, IngressClass | `networking.k8s.io/v1` |
| HPA | `autoscaling/v2` |
| VPA | `autoscaling.k8s.io/v1` |
| StorageClass, VolumeSnapshot | `storage.k8s.io/v1` |
| Role, ClusterRole, RoleBinding, ClusterRoleBinding | `rbac.authorization.k8s.io/v1` |
| Node | `v1` (rarely authored) |

---

## Minimal Skeleton (every manifest)

```yaml
apiVersion: <group/version>    #  e.g. apps/v1
kind:        <Kind>            #  e.g. Deployment
metadata:
  name:       my-object        #  ● required
  namespace:  my-ns            #  ● omit for cluster-scoped kinds
  labels:                      #  ● key: value — used by selectors
    app: my-app
  annotations:                 #  ● key: value — used by controllers/tools
    note: "human readable"
spec:
  ...                          #  kind-specific fields above
```


**In Azure Kubernetes Service (AKS), interservice communication between two .NET APIs can be handled using multiple approaches such as direct service-to-service REST calls, asynchronous messaging with queues, or advanced techniques like service mesh (Istio/Linkerd). Each approach has trade-offs in resiliency, scalability, and complexity.**  

---

## 🔑 Approaches for Interservice Communication in AKS

### 1. **Direct REST/HTTP Calls**
- **Scenario**: API-A calls API-B synchronously for data.
- **Implementation**:
  - Deploy both APIs as Kubernetes services (`ClusterIP` for internal communication).
  - Use **DNS-based service discovery**: `http://api-b-service/api/endpoint`.
  - In .NET, use `HttpClient` or `WebClient` for calls.
- **Techniques**:
  - Add **retry policies** with Polly.
  - Use **circuit breakers** to handle failures.
- **Best for**: Simple synchronous communication where latency is acceptable.

---

### 2. **gRPC Communication**
- **Scenario**: Low-latency, strongly typed communication between APIs.
- **Implementation**:
  - Define `.proto` contracts for both APIs.
  - Deploy services with gRPC endpoints.
  - Use **Kubernetes service discovery** for routing.
- **Techniques**:
  - TLS for secure communication.
  - Load balancing via Kubernetes.
- **Best for**: High-performance internal communication with strict contracts.

---

### 3. **Asynchronous Messaging (Queues/Topics)**
- **Scenario**: API-A publishes events, API-B consumes them.
- **Implementation**:
  - Use **Azure Service Bus** or **Azure Event Grid**.
  - API-A sends messages to a queue/topic.
  - API-B subscribes and processes asynchronously.
- **Techniques**:
  - Dead-letter queues for error handling.
  - Message sessions for ordered processing.
- **Best for**: Decoupled communication, event-driven architectures.

---

### 4. **Service Mesh (Istio/Linkerd)**
- **Scenario**: Complex microservice ecosystem with observability and resiliency needs.
- **Implementation**:
  - Deploy Istio or Linkerd in AKS.
  - Sidecar proxies handle communication between services.
  - Configure traffic routing, retries, and monitoring via mesh policies.
- **Techniques**:
  - mTLS for secure communication.
  - Distributed tracing with Jaeger/Zipkin.
- **Best for**: Large-scale systems requiring observability, traffic management, and security.

---

### 5. **API Gateway Approach**
- **Scenario**: External clients call API-A, which routes to API-B internally.
- **Implementation**:
  - Use **Azure API Management** or **NGINX Ingress Controller**.
  - Define routing rules for requests.
- **Techniques**:
  - Centralized authentication/authorization.
  - Rate limiting and throttling.
- **Best for**: Unified entry point with cross-cutting concerns.

---

## 📊 Comparison Table

| Approach              | Latency | Coupling | Resiliency | Best Use Case |
|-----------------------|---------|----------|------------|---------------|
| REST/HTTP             | Medium  | Tight    | Moderate   | Simple sync calls |
| gRPC                  | Low     | Tight    | Moderate   | High-performance APIs |
| Messaging (Service Bus)| High   | Loose    | High       | Event-driven systems |
| Service Mesh          | Low     | Loose    | Very High  | Large-scale microservices |
| API Gateway           | Medium  | Moderate | High       | External client integration |

---

## ⚠️ Key Considerations
- **Resiliency**: Always implement retries, timeouts, and circuit breakers.
- **Security**: Use TLS/mTLS for communication inside AKS.
- **Scalability**: Prefer asynchronous messaging for high-load scenarios.
- **Observability**: Service mesh provides tracing, logging, and monitoring out-of-the-box.

---

👉 For your **two .NET APIs in AKS**, start with **REST/HTTP calls** for simplicity. If performance is critical, move to **gRPC**. For decoupled workflows, adopt **Azure Service Bus**. If you anticipate scaling to many microservices, consider **Istio service mesh** for advanced traffic management.  

**In AKS, DNS-based service discovery lets your .NET APIs communicate using service names instead of IPs, while mTLS ensures that both client and server authenticate each other with certificates for secure communication. Together, they provide reliable routing and strong encryption for interservice traffic.**

---

## 🔎 DNS-Based Service Discovery in AKS
DNS resolution in AKS is powered by **CoreDNS**, which automatically assigns DNS names to services.  
- **Service Naming Convention**:  
  ```
  <service-name>.<namespace>.svc.cluster.local
  ```
  Example: `api-b.default.svc.cluster.local`

- **Implementation Steps**:
  1. **Define Kubernetes Service for API-B**:
     ```yaml
     apiVersion: v1
     kind: Service
     metadata:
       name: api-b
     spec:
       selector:
         app: api-b
       ports:
         - protocol: TCP
           port: 80
           targetPort: 5000
       type: ClusterIP
     ```
  2. **API-A Calls API-B via DNS**:
     ```csharp
     using System.Net.Http;
     using System.Threading.Tasks;

     public class ApiService
     {
         private readonly HttpClient _client;
         public ApiService(HttpClient client) => _client = client;

         public async Task<string> CallApiB()
         {
             var response = await _client.GetStringAsync("http://api-b.default.svc.cluster.local/api/data");
             return response;
         }
     }
     ```

- **Advantages**:
  - No need to hardcode IPs.
  - Works seamlessly across pods and namespaces.
  - Supports scaling and rolling updates.

---

## 🔐 mTLS (Mutual TLS) in AKS
mTLS ensures **both client and server present valid certificates**, preventing unauthorized access.  
- **Key Concepts**:
  - TLS encrypts traffic.
  - mTLS adds **mutual authentication**.
  - Certificates are managed via Kubernetes secrets.

- **Implementation Steps**:
  1. **Generate Certificates**:
     ```bash
     openssl req -newkey rsa:2048 -nodes -keyout client.key -x509 -days 365 -out client.crt
     openssl req -newkey rsa:2048 -nodes -keyout server.key -x509 -days 365 -out server.crt
     ```
  2. **Store Certificates in Kubernetes Secrets**:
     ```yaml
     apiVersion: v1
     kind: Secret
     metadata:
       name: mtls-secrets
     type: Opaque
     data:
       client.crt: <base64-encoded>
       client.key: <base64-encoded>
       server.crt: <base64-encoded>
       server.key: <base64-encoded>
     ```
  3. **Configure Ingress Controller (NGINX/Istio)**:
     ```yaml
     apiVersion: networking.k8s.io/v1
     kind: Ingress
     metadata:
       name: api-ingress
       annotations:
         nginx.ingress.kubernetes.io/auth-tls-secret: default/mtls-secrets
         nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
     spec:
       rules:
         - host: api-a.mydomain.com
           http:
             paths:
               - path: /
                 pathType: Prefix
                 backend:
                   service:
                     name: api-a
                     port:
                       number: 80
     ```
  4. **.NET Client with Certificate**:
     ```csharp
     using System.Net.Http;
     using System.Security.Cryptography.X509Certificates;

     var handler = new HttpClientHandler();
     handler.ClientCertificates.Add(new X509Certificate2("client.pfx", "password"));
     var client = new HttpClient(handler);

     var response = await client.GetAsync("https://api-b.default.svc.cluster.local/api/data");
     ```

- **Advantages**:
  - Strong encryption.
  - Prevents man-in-the-middle attacks.
  - Ensures only trusted services communicate.

---

## 📊 Comparison

| Feature                  | DNS Discovery | mTLS Security |
|---------------------------|---------------|---------------|
| Purpose                  | Routing       | Authentication + Encryption |
| Complexity               | Low           | Medium–High |
| Setup                    | Service + DNS | Certificates + Secrets + Ingress |
| Best Use Case            | Internal calls | Sensitive APIs, regulated environments |

---

✅ **Recommendation**:  
- Use **DNS-based service discovery** for basic interservice communication.  
- Add **mTLS** when handling sensitive data or requiring strict authentication.  
- For production, combine both: DNS for routing + mTLS for secure communication.  

Great, let’s enrich this with deeper detail and cover **DNS-based service discovery**, **mTLS**, **gRPC**, and **API Gateway** in AKS for your two .NET APIs. I’ll break it down into concepts, YAML manifests, and .NET code examples so you can see how each piece fits together.

---

## 🌐 DNS-Based Service Discovery in AKS
- **How it works**: AKS uses **CoreDNS**. Every Kubernetes Service gets a DNS entry like:
  ```
  <service-name>.<namespace>.svc.cluster.local
  ```
- **Example**: If API-B is deployed as a service named `api-b` in the `default` namespace, API-A can call it at:
  ```
  http://api-b.default.svc.cluster.local/api/data
  ```

**YAML for API-B Service**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: api-b
spec:
  selector:
    app: api-b
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: ClusterIP
```

**.NET Code in API-A**
```csharp
using System.Net.Http;
using System.Threading.Tasks;

public class ApiService
{
    private readonly HttpClient _client;
    public ApiService(HttpClient client) => _client = client;

    public async Task<string> CallApiB()
    {
        var response = await _client.GetStringAsync("http://api-b.default.svc.cluster.local/api/data");
        return response;
    }
}
```

✅ Simple, reliable, and scales automatically with pods.

---

## 🔐 mTLS (Mutual TLS) for Secure Communication
- **Why**: Encrypts traffic and ensures **both client and server authenticate each other**.
- **How**: Certificates are stored in Kubernetes secrets and mounted into pods.

**Steps**:
1. Generate certificates (client + server).
2. Store them in Kubernetes secrets.
3. Configure Ingress or Service Mesh (Istio/Linkerd) to enforce mTLS.
4. Update .NET clients to present certificates.

**Secret YAML**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mtls-secrets
type: Opaque
data:
  client.crt: <base64-encoded>
  client.key: <base64-encoded>
  server.crt: <base64-encoded>
  server.key: <base64-encoded>
```

**.NET Client with Certificate**
```csharp
using System.Net.Http;
using System.Security.Cryptography.X509Certificates;

var handler = new HttpClientHandler();
handler.ClientCertificates.Add(new X509Certificate2("client.pfx", "password"));
var client = new HttpClient(handler);

var response = await client.GetAsync("https://api-b.default.svc.cluster.local/api/data");
```

✅ Best for sensitive data, regulated environments, or zero-trust architectures.

---

## ⚡ gRPC Communication
- **Why**: Faster, strongly typed, binary protocol (HTTP/2).
- **How**: Define `.proto` contracts, generate C# stubs, deploy services with gRPC endpoints.

**Proto File**
```proto
syntax = "proto3";

service DataService {
  rpc GetData (DataRequest) returns (DataResponse);
}

message DataRequest {
  string id = 1;
}

message DataResponse {
  string value = 1;
}
```

**Server Setup in .NET**
```csharp
public class DataServiceImpl : DataService.DataServiceBase
{
    public override Task<DataResponse> GetData(DataRequest request, ServerCallContext context)
    {
        return Task.FromResult(new DataResponse { Value = "Hello from API-B" });
    }
}
```

**Client Call in API-A**
```csharp
using Grpc.Net.Client;

var channel = GrpcChannel.ForAddress("https://api-b.default.svc.cluster.local");
var client = new DataService.DataServiceClient(channel);
var reply = await client.GetDataAsync(new DataRequest { Id = "123" });
Console.WriteLine(reply.Value);
```

✅ Ideal for high-performance internal communication.

---

## 🚪 API Gateway (Ingress + Azure API Management)
- **Why**: Provides a single entry point, handles authentication, rate limiting, and routing.
- **Options**:
  - **NGINX Ingress Controller** inside AKS.
  - **Azure API Management (APIM)** outside AKS for enterprise-grade gateway.

**Ingress YAML**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: myapis.mydomain.com
      http:
        paths:
          - path: /api-a
            pathType: Prefix
            backend:
              service:
                name: api-a
                port:
                  number: 80
          - path: /api-b
            pathType: Prefix
            backend:
              service:
                name: api-b
                port:
                  number: 80
```

✅ Best for external clients, centralized policies, and cross-cutting concerns.

---

## 📊 Comparison

| Approach              | Security | Performance | Complexity | Best Use Case |
|-----------------------|----------|-------------|------------|---------------|
| DNS Discovery         | Basic    | Medium      | Low        | Internal sync calls |
| mTLS                  | Strong   | Medium      | Medium     | Sensitive data |
| gRPC                  | Strong   | High        | Medium     | High-performance APIs |
| API Gateway           | Strong   | Medium      | Medium–High| External clients, unified entry |

---

### 🔑 Takeaway
- Start with **DNS-based discovery** for simplicity.
- Add **mTLS** if you need secure, authenticated traffic.
- Use **gRPC** for high-performance internal calls.
- Introduce an **API Gateway** when exposing APIs externally or managing policies.

Perfect — let’s build a **complete end-to-end AKS deployment reference** for two .NET APIs (API-A and API-B), showing how to combine **DNS-based service discovery**, **mTLS**, **gRPC**, and an **API Gateway**.  

---

# 🏗️ End-to-End Blueprint for Two .NET APIs in AKS

## 1. **Deployments and Services**
Each API runs in its own Deployment and is exposed internally via a ClusterIP Service.

**API-A Deployment + Service**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-a
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-a
  template:
    metadata:
      labels:
        app: api-a
    spec:
      containers:
        - name: api-a
          image: myregistry.azurecr.io/api-a:latest
          ports:
            - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: api-a
spec:
  selector:
    app: api-a
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: ClusterIP
```

**API-B Deployment + Service**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-b
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-b
  template:
    metadata:
      labels:
        app: api-b
    spec:
      containers:
        - name: api-b
          image: myregistry.azurecr.io/api-b:latest
          ports:
            - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: api-b
spec:
  selector:
    app: api-b
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: ClusterIP
```

✅ Now API-A can call API-B via DNS:  
`http://api-b.default.svc.cluster.local/api/data`

---

## 2. **mTLS Setup**
Secure traffic between services using mutual TLS.

**Step 1: Create Secrets**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mtls-secrets
type: Opaque
data:
  client.pfx: <base64-encoded>
  server.pfx: <base64-encoded>
```

**Step 2: Mount Secrets in Pods**
```yaml
spec:
  containers:
    - name: api-a
      image: myregistry.azurecr.io/api-a:latest
      volumeMounts:
        - name: certs
          mountPath: /etc/certs
  volumes:
    - name: certs
      secret:
        secretName: mtls-secrets
```

**Step 3: .NET Client with Certificate**
```csharp
var handler = new HttpClientHandler();
handler.ClientCertificates.Add(new X509Certificate2("/etc/certs/client.pfx", "password"));
var client = new HttpClient(handler);

var response = await client.GetAsync("https://api-b.default.svc.cluster.local/api/data");
```

---

## 3. **gRPC Communication**
Switch from REST to gRPC for high-performance internal calls.

**Proto Definition**
```proto
syntax = "proto3";

service DataService {
  rpc GetData (DataRequest) returns (DataResponse);
}

message DataRequest {
  string id = 1;
}

message DataResponse {
  string value = 1;
}
```

**API-B Server**
```csharp
public class DataServiceImpl : DataService.DataServiceBase
{
    public override Task<DataResponse> GetData(DataRequest request, ServerCallContext context)
    {
        return Task.FromResult(new DataResponse { Value = "Hello from API-B" });
    }
}
```

**API-A Client**
```csharp
using Grpc.Net.Client;

var channel = GrpcChannel.ForAddress("https://api-b.default.svc.cluster.local");
var client = new DataService.DataServiceClient(channel);
var reply = await client.GetDataAsync(new DataRequest { Id = "123" });
Console.WriteLine(reply.Value);
```

---

## 4. **API Gateway (Ingress + Azure API Management)**
Expose both APIs externally with a unified entry point.

**Ingress Controller YAML**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: myapis.mydomain.com
      http:
        paths:
          - path: /api-a
            pathType: Prefix
            backend:
              service:
                name: api-a
                port:
                  number: 80
          - path: /api-b
            pathType: Prefix
            backend:
              service:
                name: api-b
                port:
                  number: 80
```

**Optional: Azure API Management**
- Import both APIs into APIM.
- Configure policies: JWT validation, rate limiting, caching.
- External clients call APIM → APIM routes to AKS Ingress → Services.

---

## 📊 Summary
- **DNS Discovery**: Internal routing via `svc.cluster.local`.
- **mTLS**: Secure, authenticated communication with certificates.
- **gRPC**: High-performance, strongly typed interservice calls.
- **API Gateway**: Unified external entry point with policies.

---

✅ With this blueprint, you can deploy two .NET APIs in AKS, secure them with mTLS, optimize communication with gRPC, and expose them externally via an API Gateway.  
