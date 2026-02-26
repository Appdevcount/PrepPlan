# Azure Kubernetes Service (AKS) - Complete End-to-End Guide

> Single-source study guide to become productive and confident with AKS using two simple .NET APIs as your running example.

---

## Table of Contents

1. **Mental Model & Big Picture**  
2. **AKS Core Concepts & Architecture**  
3. **When to Use AKS (vs Other Azure Options)**  
4. **Prerequisites & Tooling Setup**  
5. **Sample .NET APIs Overview (SimpleApi1 & SimpleApi2)**  
6. **Containerization with Docker (for AKS)**  
7. **Creating an AKS Cluster**  
8. **Deploying .NET APIs to AKS (YAML Manifests)**  
9. **Ingress with NGINX & HTTP Routing**  
10. **Configuration & Secrets Management**  
11. **Scaling (HPA), Resources & Limits**  
12. **Health Probes & High Availability**  
13. **Logging, Monitoring & Observability**  
14. **Security, RBAC & Managed Identity**  
15. **Real-World AKS Challenges (10) & Solutions**  
16. **CI/CD Pipelines for AKS (GitHub Actions)**  
17. **Cost Optimization Strategies**  
18. **Troubleshooting Playbook**  
19. **.NET Developer AKS Interview Questions**  
20. **Quick Reference Cheat Sheet**  
21. **Sample Command Outputs & What They Mean**  
22. **Persistent Volumes & Storage on AKS**  
23. **Terraform IaC for AKS & ACR**  
24. **Azure DevOps CI/CD Pipeline for AKS**  
25. **Advanced AKS Architecture & Operations (Architect View)**  
26. **Helm Packaging & Releases**  
27. **GitOps with Argo CD**  
28. **Azure Application Gateway Ingress & DNS Zones**  

---

## 1. Mental Model & Big Picture

### 1.1 Simple Mental Model

Imagine:

- **Azure Container Apps** = Platform that hides Kubernetes from you.  
- **AKS** = You get **Kubernetes itself**, but Azure manages the control plane (master components).  

So AKS is:

> "Azure-hosted Kubernetes where Microsoft manages the control plane, and you manage the worker nodes, workloads, and cluster configuration."

Visual:

```text
┌───────────────────────────────────────────────────────────────┐
│                  AZURE KUBERNETES SERVICE (AKS)              │
├───────────────────────────────────────────────────────────────┤
│  Azure-managed:                                              │
│    - API Server                                              │
│    - etcd (cluster state)                                    │
│    - Controller Manager                                      │
│    - Scheduler                                               │
│                                                               │
│  You manage:                                                 │
│    - Node pools (VMs)                                        │
│    - Pods, Deployments, Services, Ingress                    │
│    - ConfigMaps, Secrets, HPA, Network Policies              │
│    - Add-ons: Ingress, CSI drivers, Dapr, etc.               │
└───────────────────────────────────────────────────────────────┘
```

### 1.2 Mental Model for Workloads

Think in three levels:

1. **Cluster** – Your whole Kubernetes world (API, nodes, networking).  
2. **Namespace** – Logical folder inside cluster (dev, test, prod).  
3. **Workload** – A set of pods controlled by a higher-level object (Deployment, StatefulSet, Job).

And you never deploy containers directly; you deploy **manifests** that Kubernetes continuously reconciles until actual state matches desired state.

---

## 2. AKS Core Concepts & Architecture

### 2.1 Core Concepts

- **Cluster** – The Kubernetes control plane + node pools.  
- **Node** – A VM in Azure running kubelet and hosting pods.  
- **Pod** – Smallest deployable unit; one or more containers sharing network + storage.  
- **Deployment** – Manages replicated pods, rolling updates, and rollback.  
- **Service** – Stable virtual IP/hostname in front of a set of pods.  
- **Ingress** – HTTP/HTTPS routing layer (Layer 7) for external traffic.  

Diagram:

```text
                Internet
                   │
                   ▼
             ┌────────────┐
             │  Ingress   │  (NGINX/AGIC)
             └─────┬──────┘
                   │
           ┌───────▼────────┐
           │ Kubernetes Svc │ (ClusterIP / LoadBalancer)
           └───────┬────────┘
                   │ (kube-proxy)
          ┌─────────┴─────────┐
          │           │        │
       ┌──▼──┐     ┌──▼──┐  ┌──▼──┐
       │Pod1 │     │Pod2 │  │Pod3 │  (replicas of SimpleApi1)
       └─────┘     └─────┘  └─────┘
```

### 2.2 AKS Architecture in Azure

```text
Azure Subscription
  └── Resource Group
        ├── AKS Cluster (Managed resource group hidden by default)
        │     ├── Control Plane (managed by Microsoft)
        │     └── Node Pools (VM Scale Sets)
        └── Other resources (ACR, Key Vault, Log Analytics, etc.)
```

Key idea: **You focus on app manifests + node pools; Microsoft handles control plane reliability.**

---

## 3. When to Use AKS (vs Other Azure Options)

### 3.1 Compare with App Service & Container Apps

| Requirement                                  | AKS                        | Container Apps           | App Service         |
|---------------------------------------------|----------------------------|--------------------------|---------------------|
| Full Kubernetes control                     | ✅ Yes                     | ❌ No                    | ❌ No                |
| Complex microservices, operators, CRDs      | ✅ Excellent               | ⚠️ Limited               | ❌ No                |
| Scale-to-zero                               | ⚠️ With KEDA / custom     | ✅ Native                | ❌ No                |
| Simpler platform experience                 | ❌ Steep learning curve    | ✅ Easier                | ✅ Easiest           |
| Windows + Linux nodes                       | ✅ Yes                     | ❌ Linux only            | ✅ Yes               |
| Stateful workloads (StatefulSets, PVs)      | ✅ First-class             | ⚠️ via external storage  | ⚠️ via external     |
| Bare metal-like control over infra          | ✅ Yes                     | ❌ No                    | ❌ No                |

Use **AKS** when:

- You need **Kubernetes features**: ingress controllers, operators, CRDs, network policies.  
- You are building **complex microservices** and want K8s standardization.  
- You want to be close to "vanilla" Kubernetes to avoid platform lock-in.

---

## 4. Prerequisites & Tooling Setup

### 4.1 Install/Verify Tools

```bash
# Azure CLI
az --version

# Kubectl (Kubernetes CLI)
kubectl version --client

# Helm (Kubernetes package manager)
helm version

# Docker (for building images)
docker --version

# .NET SDK (for SimpleApi1 & SimpleApi2)
dotnet --version
```

If `kubectl` is not installed yet:

- **Windows (winget):**

  ```bash
  winget install -e --id Kubernetes.kubectl
  ```

- **Windows (Chocolatey):**

  ```bash
  choco install kubernetes-cli
  ```

- **Linux/macOS (curl, official binary):**

  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  ```

Re-run `kubectl version --client` to confirm installation.

### 4.2 Azure Login & Subscription

```bash
# Login to Azure
az login

# List subscriptions
az account list -o table

# Set active subscription
az account set --subscription "<YOUR_SUBSCRIPTION_NAME_OR_ID>"
```

### 4.3 kubeconfig, kubectl & kubelet – How They Relate

Mental model:

```text
You (kubectl) ──> kubeconfig (credentials + cluster info)
                 ↓
           Kubernetes API server (control plane)
                 ↓
            kubelet on each node ──> manages pods/containers
```

- **kubectl** – CLI that sends REST calls to the **API server** (never talks directly to nodes).
- **kubeconfig** – Local file (usually `~/.kube/config`) that stores:
  - `clusters` – API server addresses + certificates.
  - `users` – Credentials/identities to talk to clusters.
  - `contexts` – `(cluster, user, namespace)` triplets; **current-context** decides which cluster `kubectl` talks to.
- **kubelet** – Agent running on each **node**:
  - Watches the API server for Pod specs.
  - Starts/stops containers via container runtime.
  - Reports node/pod status back to the API server.

Example commands:

```bash
# See current context (which cluster you're talking to)
kubectl config current-context

# List all contexts (e.g., local kind cluster, AKS clusters)
kubectl config get-contexts

# Switch to AKS context (set by az aks get-credentials)
kubectl config use-context aks-simpleapis
```

> Mental model: `kubectl` is just an **HTTP client**; `kubeconfig` is its **address book**; `kubelet` is the **node-side agent** that actually ensures pods are running.

---

## 5. Sample .NET APIs Overview (SimpleApi1 & SimpleApi2)

We assume two minimal .NET APIs (`SimpleApi1`, `SimpleApi2`) with endpoints like:

```csharp
// ======================================================================================
// Simple minimal API endpoints used throughout this guide for AKS deployment examples
// ======================================================================================

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi(); // Adds minimal OpenAPI support for local testing

var app = builder.Build();

app.MapOpenApi(); // Exposes /openapi endpoint for Swagger/OpenAPI

// Health endpoint for liveness/readiness probes
app.MapGet("/health", () => Results.Ok(new
{
    status = "healthy",
    timestamp = DateTime.UtcNow
}))
.WithName("Health");

// Simple greeting endpoint
app.MapGet("/hello/{name?}", (string? name) =>
    Results.Ok(new
    {
        message = $"Hello, {name ?? "World"}!",
        from = "SimpleApi"
    }))
.WithName("Hello");

// Environment info endpoint to check which pod/node handled the request
app.MapGet("/info", () => Results.Ok(new
{
    machineName   = Environment.MachineName,          // Will differ per pod
    osVersion     = Environment.OSVersion.VersionString,
    dotnetVersion = Environment.Version.ToString(),
    environment   = app.Environment.EnvironmentName   // Typically "Production" in AKS
}))
.WithName("Info");

// Simple demo endpoint returning random weather data
var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild",
    "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

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

app.Run();

// Immutable record to represent each forecast entry
public record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    // Convenience property calculated from TemperatureC
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
```

We will deploy **SimpleApi1** and **SimpleApi2** as separate Kubernetes Deployments and Services into AKS.

---

## 6. Containerization with Docker (for AKS)

### 6.1 Dockerfile (Multi-stage Build) for SimpleApi

```dockerfile
# ======================================================================================
# STAGE 1: BUILD IMAGE
# - Uses full .NET SDK to restore, build, and publish the app
# - This image is large but temporary (not used in production)
# ======================================================================================
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

# Set working directory inside the container
WORKDIR /src

# Copy the project file and restore dependencies
# This layer is cached and only re-run when the csproj changes
COPY SimpleApi.csproj .
RUN dotnet restore

# Copy the rest of the source code
COPY . .

# Publish the application in Release configuration to /app/publish
RUN dotnet publish -c Release -o /app/publish --no-restore

# ======================================================================================
# STAGE 2: RUNTIME IMAGE
# - Uses smaller ASP.NET Core runtime image
# - Only contains published output (no source, no SDK)
# - Final image used in AKS
# ======================================================================================
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

WORKDIR /app

# ASP.NET Core will listen on port 8080 by default in containers,
# but we explicitly set the port to 80 for clarity
ENV ASPNETCORE_URLS=http://+:80

# Copy the published output from the build stage
COPY --from=build /app/publish .

# Document the port the container listens on
EXPOSE 80

# ENTRYPOINT is the command the container will run on startup
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
```

### 6.2 Build and Push to Azure Container Registry (ACR)

```bash
# Variables
RESOURCE_GROUP="rg-aks-demo"
LOCATION="eastus"
ACR_NAME="acrdemoaks123"   # must be globally unique, lowercase

# Create resource group
az group create -n $RESOURCE_GROUP -l $LOCATION

# Create Azure Container Registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Login to ACR
az acr login --name $ACR_NAME

# Build and push SimpleApi1
cd SimpleApi1

# Build image locally
docker build -t simpleapi1:latest .

# Tag image for ACR
docker tag simpleapi1:latest $ACR_NAME.azurecr.io/simpleapi1:v1

# Push to ACR
docker push $ACR_NAME.azurecr.io/simpleapi1:v1

# Build and push SimpleApi2
cd ../SimpleApi2
docker build -t simpleapi2:latest .
docker tag simpleapi2:latest $ACR_NAME.azurecr.io/simpleapi2:v1
docker push $ACR_NAME.azurecr.io/simpleapi2:v1

# Go back to root folder
cd ..
```

Expected ACR repositories:

```text
simpleapi1  (tag: v1)
simpleapi2  (tag: v1)
```

---

## 7. Creating an AKS Cluster

### 7.1 Create AKS Cluster Integrated with ACR

```bash
AKS_NAME="aks-simpleapis"
NODE_COUNT=2
NODE_SIZE="Standard_B4ms"   # small but reasonable for tests

# Create AKS cluster and attach ACR permissions
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count $NODE_COUNT \
  --node-vm-size $NODE_SIZE \
  --generate-ssh-keys \
  --attach-acr $ACR_NAME

# Get credentials for kubectl
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing

# Verify cluster connection
kubectl get nodes
```

Sample output:

```text
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-12345678-vmss000000   Ready    agent   5m    v1.29.x
aks-nodepool1-12345678-vmss000001   Ready    agent   5m    v1.29.x
```

---

## 8. Deploying .NET APIs to AKS (YAML Manifests)

We’ll use one **namespace** for both APIs and deploy each as a **Deployment + Service**.

### 8.0 YAML Files Used in This Guide (Mini Index)

To avoid confusion, here is a quick index of the main Kubernetes manifests we use and what each does:

- `k8s-simpleapi1.yaml` – Deployment + Service for **SimpleApi1**.
- `k8s-simpleapi2.yaml` – Deployment + Service for **SimpleApi2**.
- `k8s-ingress.yaml` – Ingress resource that routes `/api1` and `/api2` paths to the two Services.
- `k8s-config.yaml` – ConfigMap with non-secret settings (e.g., `AppSettings__ApiName`).
- `k8s-secrets.yaml` – Secret with sensitive values (e.g., connection strings, API keys).
- `k8s-hpa-simpleapi1.yaml` – Horizontal Pod Autoscaler for SimpleApi1 based on CPU.
- `storageclass-managed-csi.yaml` – StorageClass for Azure Disk via CSI driver.
- `pvc-uploads.yaml` – PersistentVolumeClaim for a 10Gi disk used by SimpleApi1.

When you read later sections, refer back to this list to see **which concern** each YAML addresses:

- **Workload & networking** → Deployments, Services, Ingress.
- **Configuration** → ConfigMap, Secret.
- **Scalability** → HPA.
- **Storage** → StorageClass, PVC.

### 8.1 Create Namespace

```bash
kubectl create namespace simple-apis

# Verify
kubectl get namespaces
```

Expected snippet:

```text
NAME           STATUS   AGE
default        Active   ...
kube-system    Active   ...
simple-apis    Active   ...
```

### 8.2 Deployment & Service for SimpleApi1

Create `k8s-simpleapi1.yaml`:

```yaml
# ======================================================================================
# SimpleApi1 Deployment + Service for AKS
# - Deploys 3 replicas
# - Exposes as a ClusterIP service (internal to cluster)
# ======================================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1
  namespace: simple-apis
  labels:
    app: simpleapi1
spec:
  replicas: 3                        # Desired number of pod replicas
  selector:
    matchLabels:
      app: simpleapi1                # Must match pod template labels
  template:
    metadata:
      labels:
        app: simpleapi1
    spec:
      containers:
        - name: simpleapi1
          image: acrdemoaks123.azurecr.io/simpleapi1:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80      # Must match EXPOSE/ASPNETCORE_URLS
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: "Production"    # Standard ASP.NET Core env
          resources:
            requests:                # Minimum guaranteed resources
              cpu: "100m"           # 0.1 vCPU
              memory: "128Mi"       # 128MB
            limits:                  # Hard upper limit per pod
              cpu: "500m"           # 0.5 vCPU
              memory: "512Mi"       # 512MB
          readinessProbe:
            httpGet:
              path: "/health"       # Uses our /health endpoint
              port: 80
            initialDelaySeconds: 5   # Wait before first check
            periodSeconds: 10        # Check every 10s
            timeoutSeconds: 2
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: "/health"       # Reuse same endpoint for liveness
              port: 80
            initialDelaySeconds: 15
            periodSeconds: 20
            timeoutSeconds: 2
            failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: simpleapi1-svc
  namespace: simple-apis
  labels:
    app: simpleapi1
spec:
  type: ClusterIP                 # Internal-only; exposed via Ingress later
  selector:
    app: simpleapi1
  ports:
    - name: http
      port: 80                    # Service port inside cluster
      targetPort: 80              # Container port
```

**Key fields explained (mental model: "desired state" for app + stable IP):**

- `apiVersion: apps/v1` – Uses the stable API group for Deployments.
- `kind: Deployment` – Higher-level controller that keeps the right number of pods running and performs rolling updates.
- `metadata.name` – Logical name of the Deployment; used by `kubectl` commands and HPA.
- `spec.replicas` – Desired number of pod copies; Kubernetes continually reconciles actual pods to this value.
- `spec.selector.matchLabels` – Label selector that tells the Deployment which pods it owns. **Must match** `template.metadata.labels`.
- `template.spec.containers` – Desired container(s) in each pod: image, ports, env vars, probes.
- `image` – Full image reference from ACR; avoid `:latest` for repeatable deployments.
- `resources.requests` – Minimum CPU/memory the scheduler uses to place pods on nodes.
- `resources.limits` – Hard caps; if exceeded, pods may be throttled or OOMKilled.
- `readinessProbe` – Endpoint that must succeed before traffic is sent to the pod.
- `livenessProbe` – Endpoint used to decide if the container should be restarted.
- `Service.spec.type: ClusterIP` – Creates an internal virtual IP used by other pods.
- `ports.port` – Port exposed by the Service inside the cluster.
- `ports.targetPort` – Container port traffic is forwarded to (must match `containerPort`).

**Sample apply & inspection:**

```bash
kubectl apply -f k8s-simpleapi1.yaml

kubectl get deployment simpleapi1 -n simple-apis

kubectl get pods -n simple-apis -o wide
```

Sample output (shape):

```text
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
simpleapi1   3/3     3            3           2m

NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE
simpleapi1-7d6c8df9f8-abcde   1/1     Running   0          2m    10.244.0.10   aks-nodepool1-...
simpleapi1-7d6c8df9f8-fghij   1/1     Running   0          2m    10.244.0.11   aks-nodepool1-...
simpleapi1-7d6c8df9f8-klmno   1/1     Running   0          2m    10.244.0.12   aks-nodepool1-...
```
Apply the manifest:

```bash
kubectl apply -f k8s-simpleapi1.yaml

# Check deployment and pods
kubectl get deployments -n simple-apis
kubectl get pods -n simple-apis -o wide
kubectl get svc -n simple-apis
```

### 8.3 Deployment & Service for SimpleApi2

Create `k8s-simpleapi2.yaml`:

```yaml
# ======================================================================================
# SimpleApi2 Deployment + Service
# - Same pattern as SimpleApi1
# - Often used as downstream service in examples
# ======================================================================================
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi2
  namespace: simple-apis
  labels:
    app: simpleapi2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: simpleapi2
  template:
    metadata:
      labels:
        app: simpleapi2
    spec:
      containers:
        - name: simpleapi2
          image: acrdemoaks123.azurecr.io/simpleapi2:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: "Production"
          resources:
            requests:
              cpu: "50m"
              memory: "64Mi"
            limits:
              cpu: "250m"
              memory: "256Mi"
          readinessProbe:
            httpGet:
              path: "/health"
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: "/health"
              port: 80
            initialDelaySeconds: 15
            periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: simpleapi2-svc
  namespace: simple-apis
  labels:
    app: simpleapi2
spec:
  type: ClusterIP
  selector:
    app: simpleapi2
  ports:
    - name: http
      port: 80
      targetPort: 80
```

Apply:

```bash
kubectl apply -f k8s-simpleapi2.yaml
kubectl get deployments,pods,svc -n simple-apis
```

---

## 9. Ingress with NGINX & HTTP Routing

### 9.1 Install NGINX Ingress Controller (Helm)

```bash
# Create a namespace for ingress
kubectl create namespace ingress-nginx

# Add Helm repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX ingress controller (basic setup)
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.replicaCount=2 \
  --set controller.nodeSelector."kubernetes\.io/os"=linux \
  --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux

# Wait and get external IP
kubectl get service ingress-nginx-controller -n ingress-nginx
```

Sample output:

```text
NAME                       TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)
ingress-nginx-controller   LoadBalancer   10.0.XXX.XXX  20.50.100.200   80:30080/TCP,443:30443/TCP
```

### 9.2 Ingress Resource for SimpleApi1 & SimpleApi2

Create `k8s-ingress.yaml`:

```yaml
# ======================================================================================
# Ingress resource routing HTTP paths to our APIs
# - /api1 -> SimpleApi1
# - /api2 -> SimpleApi2
# ======================================================================================
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-apis-ingress
  namespace: simple-apis
  annotations:
    kubernetes.io/ingress.class: "nginx"        # Use NGINX ingress controller
    nginx.ingress.kubernetes.io/rewrite-target: "/$2"  # Strip base path (/api1, /api2)
spec:
  rules:
    - host: aks-simpleapis.demo.com             # Optional; can use IP directly for tests
      http:
        paths:
          - path: /api1(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: simpleapi1-svc
                port:
                  number: 80
          - path: /api2(/|$)(.*)
            pathType: Prefix
            backend:
              service:
                name: simpleapi2-svc
                port:
                  number: 80
```

**Key ingress attributes explained (mental model: "HTTP router" in front of Services):**

- `kind: Ingress` – Layer 7 router that receives external HTTP/HTTPS traffic.
- `metadata.annotations["kubernetes.io/ingress.class"]` – Binds this Ingress to the NGINX controller we installed.
- `nginx.ingress.kubernetes.io/rewrite-target` – Rewrites `/api1/anything` to `/anything` before hitting the backend.
- `spec.rules[].host` – Optional host header used for virtual hosting; when omitted, Ingress responds on any host.
- `paths[].path` – URL prefix matched by NGINX; `(/|$)(.*)` captures the rest of the URL for rewriting.
- `paths[].backend.service.name` – Name of the Kubernetes Service that receives the traffic.
- `paths[].backend.service.port.number` – Service port (not container port) to route to.

**Sample command & output:**

```bash
kubectl get ingress -n simple-apis
```

```text
NAME                  CLASS   HOSTS                     ADDRESS         PORTS   AGE
simple-apis-ingress   nginx   aks-simpleapis.demo.com   20.50.100.200   80      5m
```

Apply:

```bash
kubectl apply -f k8s-ingress.yaml
kubectl get ingress -n simple-apis
```

Test using the ingress public IP:

```bash
INGRESS_IP="20.50.100.200"   # from ingress-nginx-controller EXTERNAL-IP

# Call SimpleApi1
curl http://$INGRESS_IP/api1/health
curl http://$INGRESS_IP/api1/info

# Call SimpleApi2
curl http://$INGRESS_IP/api2/health
curl http://$INGRESS_IP/api2/info
```

---

## 10. Configuration & Secrets Management

### 10.1 ConfigMaps (Non-sensitive Configuration)

**Use case**: Feature flags, API names, non-secret settings.

Create `k8s-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: simpleapi-config
  namespace: simple-apis

data:
  AppSettings__ApiName: "SimpleApi1"
  AppSettings__ApiVersion: "1.0.0"
  Features__EnableBeta: "true"
```

Apply:

```bash
kubectl apply -f k8s-config.yaml
```

Use in deployment (snippet from SimpleApi1):

```yaml
# ... inside spec.template.spec.containers[0]
        env:
          - name: ASPNETCORE_ENVIRONMENT
            value: "Production"
          - name: AppSettings__ApiName
            valueFrom:
              configMapKeyRef:
                name: simpleapi-config    # Name of ConfigMap
                key: AppSettings__ApiName
          - name: AppSettings__ApiVersion
            valueFrom:
              configMapKeyRef:
                name: simpleapi-config
                key: AppSettings__ApiVersion
```

Read in .NET code:

```csharp
var builder = WebApplication.CreateBuilder(args);

// IConfiguration automatically pulls from environment variables
var apiName    = builder.Configuration["AppSettings:ApiName"];      // from ConfigMap
var apiVersion = builder.Configuration["AppSettings:ApiVersion"];   // from ConfigMap

var app = builder.Build();

app.MapGet("/config", () => Results.Ok(new
{
    apiName,
    apiVersion,
    environment = app.Environment.EnvironmentName
}));

app.Run();
```

### 10.2 Secrets (Sensitive Configuration)

Create `k8s-secrets.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: simpleapi-secrets
  namespace: simple-apis

type: Opaque
stringData:
  ConnectionStrings__Database: "Server=tcp:mydbserver.database.windows.net,1433;Database=MyDb;User ID=appuser;Password=P@ssw0rd!;"
  ApiKey: "super-secret-api-key"
```

Apply:

```bash
kubectl apply -f k8s-secrets.yaml
```

Reference in deployment:

```yaml
        env:
          - name: ConnectionStrings__Database
            valueFrom:
              secretKeyRef:
                name: simpleapi-secrets
                key: ConnectionStrings__Database
          - name: ApiKey
            valueFrom:
              secretKeyRef:
                name: simpleapi-secrets
                key: ApiKey
```

Consume in .NET:

```csharp
var connectionString = builder.Configuration["ConnectionStrings:Database"];
var apiKey           = builder.Configuration["ApiKey"];
```

> Production tip: Use **Azure Key Vault CSI driver** with AKS to avoid putting secrets directly in Kubernetes.

### 10.3 Azure Key Vault CSI Driver & SecretProviderClass

When you use the **Secrets Store CSI driver**, pods can mount secrets **directly from Key Vault** via a custom resource called `SecretProviderClass`.

Mental model:

```text
Key Vault secrets ──> SecretProviderClass (mapping) ──> CSI volume mounted into pod
```

#### 10.3.1 Install Azure Key Vault Provider (high level)

At a high level (one-time per cluster):

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/main/deploy/rbac-secretproviderclass.yaml

helm repo add csi-secrets-store-provider-azure https://azure.github.io/secrets-store-csi-driver-provider-azure/charts
helm repo update

helm install csi-secrets-store-provider-azure csi-secrets-store-provider-azure/csi-secrets-store-provider-azure \
  --namespace kube-system
```

Sample output (shape):

```text
NAME: csi-secrets-store-provider-azure
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
``` 

#### 10.3.2 Define a SecretProviderClass

Create `k8s-kv-secretproviderclass.yaml`:

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: kv-simpleapi-secrets
  namespace: simple-apis
spec:
  provider: azure
  parameters:
    keyvaultName: my-kv-name              # Name of your Key Vault
    tenantId: <tenant-guid>               # Azure AD tenant ID
    objects: |
      array:
        - objectName: DbConnectionString  # Name of secret in Key Vault
          objectType: secret              # secret, key, or certificate
          objectAlias: db-conn
  secretObjects:                           # (optional) also sync into a K8s Secret
    - secretName: simpleapi-kv-secrets
      type: Opaque
      data:
        - objectName: DbConnectionString
          key: ConnectionStrings__Database
```

Key pieces:

- `provider: azure` – Use Azure Key Vault provider.
- `parameters.keyvaultName` – Which Key Vault to read from.
- `objects` – Which secrets/keys/certs to pull and how to alias them.
- `secretObjects` – Optional mapping to create a **native Kubernetes Secret** from Key Vault content.

Apply and verify:

```bash
kubectl apply -f k8s-kv-secretproviderclass.yaml
kubectl get secretproviderclass -n simple-apis
```

Sample output:

```text
NAME                   AGE
kv-simpleapi-secrets   10s
```

#### 10.3.3 Mount Key Vault Secrets into SimpleApi1 Pods

Update the SimpleApi1 Deployment to mount the CSI volume and (optionally) sync to a Secret:

```yaml
spec:
  template:
    spec:
      volumes:
        - name: kv-secrets
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: kv-simpleapi-secrets
      containers:
        - name: simpleapi1
          image: acrdemoaks123.azurecr.io/simpleapi1:v1
          volumeMounts:
            - name: kv-secrets
              mountPath: "/mnt/secrets-store"
              readOnly: true
          env:
            - name: ConnectionStrings__Database
              valueFrom:
                secretKeyRef:
                  name: simpleapi-kv-secrets
                  key: ConnectionStrings__Database
```

Two ways to use the data:

- **File-based** – Read from `/mnt/secrets-store/db-conn` inside the container.
- **Env var-based** – Use `secretObjects` and `secretKeyRef` as shown to keep your .NET config model unchanged.

> Mental model: Key Vault remains the **source of truth**; CSI driver projects secrets into pods on demand, and `SecretProviderClass` is the contract describing *which* secrets to pull and *how*.

---

## 11. Scaling (HPA), Resources & Limits

### 11.1 Horizontal Pod Autoscaler (HPA) for SimpleApi1

Create `k8s-hpa-simpleapi1.yaml`:

```yaml
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
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60  # Scale out when average CPU > 60%
```

Apply:

```bash
kubectl apply -f k8s-hpa-simpleapi1.yaml
kubectl get hpa -n simple-apis
```

**HPA spec explained (mental model: "automatic replica dial" based on load):**

- `scaleTargetRef` – Which Deployment the HPA controls.
- `minReplicas` / `maxReplicas` – Lower/upper bounds for automatic scaling.
- `metrics[].type: Resource` – Use built-in metrics (CPU/Memory) from Metrics Server.
- `resource.name: cpu` – Use CPU utilization as the signal.
- `target.averageUtilization: 60` – Try to keep average CPU at 60%; above → scale out, below → scale in.

Sample `kubectl get hpa` output:

```text
NAME            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
simpleapi1-hpa  Deployment/simpleapi1  45%/60%   2         10        2          3m
```

### 11.2 Load Testing to See Scaling

```bash
# Use watch to observe pods and HPA
watch kubectl get pods,hpa -n simple-apis

# Use a simple load tool like hey (https://github.com/rakyll/hey)
hey -z 2m -q 50 "http://$INGRESS_IP/api1/weatherforecast"
```

As CPU usage increases, you should see **HPA** creating more pod replicas up to `maxReplicas`.

---

## 12. Health Probes & High Availability

### 12.1 Health Endpoints in Code

```csharp
// Liveness: Is the process running?
app.MapGet("/health/live", () => Results.Ok(new { status = "live" }));

// Readiness: Is the app ready to receive traffic? (e.g., DB reachable)
app.MapGet("/health/ready", async () =>
{
    // Example pseudo-check
    var dbHealthy = true; // Replace with real check

    if (!dbHealthy)
    {
        return Results.StatusCode(StatusCodes.Status503ServiceUnavailable);
    }

    return Results.Ok(new { status = "ready" });
});
```

### 12.2 Probes in YAML

```yaml
        readinessProbe:
          httpGet:
            path: "/health/ready"
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: "/health/live"
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

These probes allow Kubernetes to:

- Avoid sending traffic to pods that aren’t ready.  
- Restart pods that are stuck or unhealthy.

---

## 13. Logging, Monitoring & Observability

### 13.1 Enable Azure Monitor for AKS

When creating AKS, enable monitoring or add later:

```bash
az aks enable-addons \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --addons monitoring \
  --workspace-resource-id \
    "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace>"
```

### 13.2 View Pod Logs

```bash
# List pods
kubectl get pods -n simple-apis

# View logs for a specific pod
kubectl logs simpleapi1-7d6c8df9f8-abcde -n simple-apis

# Stream logs continuously
kubectl logs -f deployment/simpleapi1 -n simple-apis
```

Sample output for the last command (shape):

```text
info: SimpleApi[0]
  Handling /hello for World
info: SimpleApi[0]
  Handling /hello for Alice
warn: SimpleApi[0]
  Slow request detected at /weatherforecast (250 ms)
```

> Pod-level command (`kubectl logs simpleapi1-...`) prints the same log lines; `-f` just follows them as they are written.

### 13.3 Structured Logging in .NET

```csharp
var builder = WebApplication.CreateBuilder(args);

// Optional: configure logging levels, providers, etc.
var app = builder.Build();

app.MapGet("/hello/{name?}", (string? name, ILogger<Program> logger) =>
{
    var resolvedName = name ?? "World";

    // Structured logging with property
    logger.LogInformation("Handling /hello for {Name}", resolvedName);

    return Results.Ok(new
    {
        message = $"Hello, {resolvedName}!",
        from = "SimpleApi"
    });
});

app.Run();
```

Logs become queryable in Azure Monitor / Log Analytics.

### 13.4 Application Insights for .NET on AKS

For **end-to-end request traces, dependencies, and metrics**, add Application Insights to your API.

Add the NuGet package:

```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

Configure in `Program.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationInsightsTelemetry();

var app = builder.Build();

app.MapGet("/ai-demo", (ILogger<Program> logger) =>
{
    logger.LogInformation("Handling /ai-demo");
    return Results.Ok("AI demo ok");
});

app.Run();
```

Set the connection string via environment variable (mapped from a Secret or Key Vault):

```yaml
env:
  - name: APPLICATIONINSIGHTS_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: simpleapi-secrets
        key: AppInsights__ConnectionString
```

Once deployed, requests, traces, and dependencies appear in your Application Insights resource.

### 13.5 Querying Logs with Kusto (KQL)

In Log Analytics, you can run KQL queries like:

```kusto
ContainerLog
| where TimeGenerated > ago(1h)
| where KubernetesNamespace == "simple-apis"
| where LogLevel == "Error"
| project TimeGenerated, PodName, LogMessage
| order by TimeGenerated desc
```

For Application Insights telemetry:

```kusto
traces
| where timestamp > ago(1h)
| where cloud_RoleName == "simpleapi1"
| summarize count() by severityLevel
```

> Mental model: **pod logs** help with instance-level issues; **App Insights** and KQL give you **application-level observability** (latency, failures, user flows).

---

## 14. Security, RBAC & Managed Identity

### 14.1 Basic RBAC Mental Model

- **Kubernetes RBAC** – Controls what users/service accounts can do **inside** the cluster.  
- **Azure RBAC** – Controls what identities can do to **Azure resources** (AKS, ACR, Key Vault, etc.).

### 14.2 Accessing Azure Resources from Pods (Managed Identity)

Use **Workload Identity** (recommended) or **AAD Pod Identity (legacy)** to allow pods to call Azure resources without secrets.

Simplified steps (Workload Identity):

1. Create a **User Assigned Managed Identity** in Azure.  
2. Annotate a Kubernetes ServiceAccount with that identity.  
3. Use **DefaultAzureCredential** in .NET to obtain tokens.

#### 14.2.1 How AKS + Managed Identity + Key Vault fit together

Mental model (high level):

```text
Pod (container)
  └── uses Kubernetes ServiceAccount
        └── federated with a User Assigned Managed Identity (UAMI)
              └── gets token from Entra ID
                    └── uses token to call Key Vault (RBAC)
```

- The **User Assigned Managed Identity (UAMI)** is an Azure identity (like a service principal) that lives **outside** the AKS cluster.
- **Workload Identity** creates a **trust** between a Kubernetes ServiceAccount and that UAMI using a **federated credential**.
- When code inside the pod calls `DefaultAzureCredential`, it presents a token based on the ServiceAccount identity; Entra ID exchanges that for a token for the UAMI.
- Key Vault sees the **UAMI** as the caller and applies **Key Vault access policies / RBAC** to decide if the secret can be read.

In short:

> Pod → ServiceAccount → Workload Identity → UAMI → Entra ID token → Key Vault.

#### 14.2.2 Step‑by‑step: AKS pod accessing Key Vault with Workload Identity

At a high level you do three things:

1. **Create the UAMI and give it Key Vault permissions.**  
2. **Enable Workload Identity on AKS and bind a ServiceAccount to the UAMI.**  
3. **Use `DefaultAzureCredential` from your .NET app running in that pod.**

**Step 1 – Create User Assigned Managed Identity and grant Key Vault access**

```bash
# Variables
RESOURCE_GROUP="rg-aks-demo"
LOCATION="eastus"
UAMI_NAME="uami-aks-simpleapis"
KEYVAULT_NAME="kv-simpleapis"

# 1a. Create UAMI
az identity create \
  --name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

# Capture its principalId for RBAC assignments
UAMI_PRINCIPAL_ID=$(az identity show \
  --name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP \
  --query principalId -o tsv)

# 1b. Grant the UAMI access to Key Vault (RBAC example)
az role assignment create \
  --assignee-object-id $UAMI_PRINCIPAL_ID \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/<subId>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME"
```

Now the UAMI **is allowed** to read secrets from that Key Vault.

**Step 2 – Enable Workload Identity on AKS and bind ServiceAccount → UAMI**

1. Enable Workload Identity on the AKS cluster (if not already):

```bash
AKS_NAME="aks-simpleapis"

az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --enable-oidc-issuer \
  --enable-workload-identity

# Get the OIDC issuer URL for the cluster
OIDC_ISSUER=$(az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --query "oidcIssuerProfile.issuerUrl" -o tsv)
```

2. Create a Kubernetes ServiceAccount that your pod will use, for example in the `simple-apis` namespace:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: simpleapi-sa
  namespace: simple-apis
  annotations:
    azure.workload.identity/client-id: "<UAMI_CLIENT_ID>"   # from az identity show
```

Apply it:

```bash
kubectl apply -f sa-simpleapi.yaml
```

3. Create a **federated identity credential** on the UAMI that trusts tokens issued for this ServiceAccount:

```bash
UAMI_CLIENT_ID=$(az identity show \
  --name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP \
  --query clientId -o tsv)

az identity federated-credential create \
  --name simpleapi-fic \
  --identity-name $UAMI_NAME \
  --resource-group $RESOURCE_GROUP \
  --issuer $OIDC_ISSUER \
  --subject "system:serviceaccount:simple-apis:simpleapi-sa" \
  --audiences api://AzureADTokenExchange
```

This says: *"Tokens issued by this AKS OIDC issuer for the ServiceAccount `simpleapi-sa` in namespace `simple-apis` can be exchanged for a token for this UAMI."*

4. Finally, make your Deployment use that ServiceAccount:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: simpleapi1
  namespace: simple-apis
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: simpleapi1
    spec:
      serviceAccountName: simpleapi-sa   # <‑‑ critical link to the identity
      containers:
        - name: simpleapi1
          image: <acr>.azurecr.io/simpleapi1:v1
```

**Step 3 – Use `DefaultAzureCredential` inside .NET**

Once the identity wiring is in place, your .NET code simply uses `DefaultAzureCredential`. At runtime, the library:

1. Detects it is running on AKS with Workload Identity.
2. Obtains a token for the **ServiceAccount** from the cluster’s OIDC issuer.
3. Exchanges that for a token for the **UAMI**.
4. Uses that token to call **Key Vault** (or any other Azure resource the UAMI can access).

You do **not** store any client secrets, certificates, or connection strings for authentication – the identity binding handles it.

Code example:

```csharp
// Example: Access Azure Key Vault from a pod without secrets
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

var builder = WebApplication.CreateBuilder(args);

var keyVaultUrl = builder.Configuration["KeyVaultUrl"]; // e.g., https://mykv.vault.azure.net/

// DefaultAzureCredential automatically uses Workload Identity in AKS
var client = new SecretClient(new Uri(keyVaultUrl), new DefaultAzureCredential());

var app = builder.Build();

app.MapGet("/secret", async () =>
{
    // Fetch secret from Key Vault using pod's identity
    KeyVaultSecret secret = await client.GetSecretAsync("AppSecret");

    return Results.Ok(new
    {
        secretName  = secret.Name,
        secretValue = secret.Value.Substring(0, 4) + "***" // Never log full secret
    });
});

app.Run();
```

### 14.3 App-Level Authentication & Authorization (Entra ID + JWT)

So far we covered **cluster-level RBAC** and **identity to Azure resources**. You also need **API-level auth** so only authorized callers can hit your endpoints.

Mental model:

```text
Client (browser/service) ──(JWT bearer token)──> SimpleApi
                ↓
             ASP.NET Core auth middleware
                ↓
            [Authorize] attributes on endpoints
```

High-level steps:

1. Register an **app in Microsoft Entra ID** (formerly Azure AD).  
2. Configure that app for **access tokens** (scopes/roles).  
3. Configure your .NET API to validate JWT tokens issued by Entra ID.  
4. Protect endpoints with `[Authorize]` and roles/policies.

Package and code (minimal API):

```bash
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
```

```csharp
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

builder.Services
  .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
  .AddJwtBearer(options =>
  {
    options.Authority = "https://login.microsoftonline.com/<tenant-id>/v2.0";
    options.TokenValidationParameters = new TokenValidationParameters
    {
      ValidAudience = "api://<your-api-client-id>"
    };
  });

builder.Services.AddAuthorization();

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/secure", () => "You are authorized!")
   .RequireAuthorization();

app.Run();
```

In Kubernetes, you deploy the same container; tokens are validated **inside the app**, independent of ingress controller. NGINX or Application Gateway simply forward the `Authorization: Bearer <token>` header.

> Mental model: Kubernetes decides **who can talk to the cluster** (RBAC), Entra ID + JWT and ASP.NET Core decide **who can use your API endpoints**.

---

## 15. Real-World AKS Challenges (10) & Solutions

Below are **10 realistic AKS-specific challenges** and how to solve them with code/YAML and explanations.

### Challenge 1: Pod Restarts Due to Out-of-Memory (OOMKilled)

**Symptom:**

```bash
kubectl get pods -n simple-apis
# STATUS shows CrashLoopBackOff or OOMKilled

kubectl describe pod <pod-name> -n simple-apis
# Events show OOMKilled
```

**Root Cause:**

- Containers use more memory than requested/limited.  
- No/incorrect resource limits.

**Solution:** Set realistic **requests/limits** based on measurements.

```yaml
# In SimpleApi1 deployment
resources:
  requests:
    cpu: "100m"
    memory: "256Mi"      # Increase from 128Mi to 256Mi
  limits:
    cpu: "500m"
    memory: "512Mi"      # Ensure limit is comfortably above normal usage
```

Add logging to understand memory usage over time (via metrics or Application Insights). Although .NET doesn’t give direct memory metrics easily, you can measure request patterns and use APM tools.

**Mental Model:**

> In Kubernetes, **no limits** = dangerous; pods can be killed at any time if node memory runs out. Always set **requests** and **limits**.

---

### Challenge 2: High Latency / Timeouts Under Load

**Symptom:**

- Requests to `/weatherforecast` or `/info` become slow.  
- Timeouts in clients.

**Root Cause:**

- Insufficient replicas.  
- No autoscaling.  
- Heavy work done synchronously.

**Solution:**

1. **Enable HPA** (as shown earlier).  
2. Ensure **async** in your .NET code.

```csharp
// BAD: Blocking thread with Task.Delay.Result or .Wait()
app.MapGet("/slow-bad", () =>
{
    Task.Delay(2000).Wait(); // Blocks the thread - not scalable
    return Results.Ok("Done");
});

// GOOD: Async endpoint using await
app.MapGet("/slow-good", async () =>
{
    await Task.Delay(2000); // Non-blocking - better throughput
    return Results.Ok("Done");
});
```

3. Scale out via HPA and verify HPA reacts to CPU.

**Mental Model:**

> AKS gives you **horizontal scale**, but if your code is synchronous/blocking, you won’t benefit fully. Combine **HPA + async code**.

---

### Challenge 3: Ingress 502/504 Errors (Bad Gateway / Timeout)

**Symptom:**

- `curl` to ingress IP returns 502 or 504.  
- Direct `kubectl port-forward` works.

**Possible Causes:**

- Wrong `targetPort` in Service.  
- Pod not ready (failing readiness probe).  
- Ingress paths not matching.

**Checklist:**

1. Verify Pod is Ready:

```bash
kubectl get pods -n simple-apis
kubectl describe pod <pod> -n simple-apis
```

2. Verify Service:

```bash
kubectl get svc simpleapi1-svc -n simple-apis -o yaml
# Ensure spec.ports[*].targetPort == containerPort in Deployment
```

3. Verify Ingress:

- Check correct host/path.  
- Use simpler path without rewrite to test:

```yaml
# Temporary test ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simpleapi1-test-ingress
  namespace: simple-apis
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: simpleapi1-svc
                port:
                  number: 80
```

If this works, the issue is with complex path rewrite rules.

**Mental Model:**

> Always debug **from pod outward**: Pod → Service → Ingress → External.

---

### Challenge 4: Broken Service-to-Service Communication (DNS Issues)

**Scenario:** SimpleApi1 calls SimpleApi2 using HTTP.

**Code in SimpleApi1:**

```csharp
var builder = WebApplication.CreateBuilder(args);

// Register HttpClient with base address pointing to Kubernetes Service
builder.Services.AddHttpClient("SimpleApi2", client =>
{
    // IMPORTANT: Use service name + namespace + cluster domain
    client.BaseAddress = new Uri("http://simpleapi2-svc.simple-apis.svc.cluster.local");
});

var app = builder.Build();

app.MapGet("/call-api2", async (IHttpClientFactory httpClientFactory) =>
{
    var client = httpClientFactory.CreateClient("SimpleApi2");

    // Call SimpleApi2 /info endpoint
    var response = await client.GetAsync("/info");
    response.EnsureSuccessStatusCode();

    var content = await response.Content.ReadAsStringAsync();

    return Results.Ok(new
    {
        message      = "Successfully called SimpleApi2 from SimpleApi1",
        api2Response = content
    });
});

app.Run();
```

**Common Mistake:** Using external IP or ingress host internally, which is slower and can break if ingress changes.

**Fix:** Always use **Kubernetes Service DNS name**: `service.namespace.svc.cluster.local`.

**Mental Model:**

> Inside the cluster, treat Services as your **internal load balancers**; never go out via ingress for service-to-service calls.

---

### Challenge 5: Rolling Updates Impact Live Traffic (Spikes/Errors)

**Symptom:**

- During `kubectl apply -f deployment.yaml`, some requests fail or see mixed versions.

**Solution:** Use proper **rolling update strategy** + `maxUnavailable`.

```yaml
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # One extra pod can be created during update
      maxUnavailable: 0    # Always keep all existing pods available
```

Also, ensure readiness probes are correct so new pods only receive traffic when actually ready.

**Mental Model:**

> Kubernetes rolling update is safe **only if** readiness probes are correct and strategy values are tuned.

---

### Challenge 6: Multiple Environments (dev/test/prod) in One Cluster

**Problem:**

- Hard to isolate dev/test/prod traffic.  
- Risk of mixing configurations.

**Solution:** Use **namespaces** + environment-specific **labels**/**Ingress hostnames**.

```bash
kubectl create namespace simple-apis-dev
kubectl create namespace simple-apis-prod
```

Deploy same manifests with different namespaces and minimal changes (e.g., hostnames):

```yaml
# prod ingress host
spec:
  rules:
    - host: api-prod.mycompany.com

# dev ingress host
spec:
  rules:
    - host: api-dev.mycompany.com
```

**Mental Model:**

> Namespaces are your **folders** inside the cluster; use them as the first-level isolation for environments.

---

### Challenge 7: Log Volume Too High / Expensive

**Symptom:**

- Log Analytics costs are high.  
- Too many noisy logs.

**Solution:**

1. **Reduce log level** in production.

```csharp
builder.Logging.ClearProviders();

builder.Logging.AddConsole();

builder.Logging.SetMinimumLevel(LogLevel.Warning); // Only warnings and above
```

2. Configure logging in `appsettings.Production.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft": "Warning",
      "Microsoft.Hosting.Lifetime": "Information"
    }
  }
}
```

3. Use sampling in Application Insights if enabled.

**Mental Model:**

> In AKS, **you pay for logs**; logging everything at `Information` level can be expensive.

---

### Challenge 8: Over-Privileged Pods (Security Risk)

**Symptom:**

- Security review shows pods running as root.  
- Containers can access host resources.

**Solution:** Set **Pod SecurityContext** and run as non-root.

```yaml
spec:
  template:
    spec:
      securityContext:
        runAsUser: 1000          # Non-root UID
        runAsGroup: 3000         # Non-root GID
        fsGroup: 2000
      containers:
        - name: simpleapi1
          image: acrdemoaks123.azurecr.io/simpleapi1:v1
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
```

**Mental Model:**

> Default container images often run as root; in Kubernetes, always assume **compromise will happen** and minimize blast radius.

---

### Challenge 9: Node Pool Saturation (Cluster Capacity Issues)

**Symptom:**

- New pods pending with reason `Unschedulable`.  
- Error: `0/2 nodes are available: 2 Insufficient cpu`.

**Solution:**

1. Check pending pods:

```bash
kubectl get pods -n simple-apis
kubectl describe pod <pending-pod> -n simple-apis
```

2. Scale node pool or reduce resource requests.

```bash
# Scale node count
az aks scale \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 3
```

Or adjust resource requests in deployment.

**Mental Model:**

> HPA scales **pods**, but if **node pool** is full, pods remain pending. Always monitor **cluster capacity** as well.

---

### Challenge 10: Debugging a Broken Pod (CrashLoopBackOff)

**Symptom:**

- Pod keeps restarting.  
- Logs not enough.

**Solution:** Use `kubectl exec` and `kubectl port-forward` to debug.

```bash
# Describe pod to see events
kubectl describe pod simpleapi1-xxx -n simple-apis

# Check logs
kubectl logs simpleapi1-xxx -n simple-apis --previous   # previous container

# Open an interactive shell (if image has /bin/sh)
kubectl exec -it simpleapi1-xxx -n simple-apis -- /bin/sh

# Port forward directly to a pod
kubectl port-forward pod/simpleapi1-xxx 8080:80 -n simple-apis

# Then call it locally
curl http://localhost:8080/health
```

**Mental Model:**

> Treat each pod as a separate Linux container you can "SSH" into with `kubectl exec`. Inspect environment variables, files, and connectivity directly in-cluster.

---

## 16. CI/CD Pipelines for AKS (GitHub Actions)

### 16.1 GitHub Actions: Build, Push & Deploy

Create `.github/workflows/aks-deploy-simpleapi1.yml`:

```yaml
name: AKS - Build and Deploy SimpleApi1

on:
  push:
    branches: [ main ]
    paths:
      - 'SimpleApi1/**'
  workflow_dispatch:

env:
  ACR_NAME: acrdemoaks123
  IMAGE_NAME: simpleapi1
  RESOURCE_GROUP: rg-aks-demo
  AKS_NAME: aks-simpleapis
  K8S_NAMESPACE: simple-apis

jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Login to Azure
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}  # SPN JSON

      - name: Azure Container Registry - Login
        uses: azure/cli@v2
        with:
          inlineScript: |
            az acr login --name $ACR_NAME

      - name: Build and push image
        run: |
          IMAGE_TAG=${{ github.sha }}
          IMAGE_FULL_NAME=$ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG

          # Build
          docker build -t $IMAGE_FULL_NAME ./SimpleApi1

          # Push
          docker push $IMAGE_FULL_NAME

          echo "IMAGE_FULL_NAME=$IMAGE_FULL_NAME" >> $GITHUB_ENV

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Login to Azure
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Get AKS credentials
        uses: azure/cli@v2
        with:
          inlineScript: |
            az aks get-credentials \
              --resource-group $RESOURCE_GROUP \
              --name $AKS_NAME \
              --overwrite-existing

      - name: Set image in k8s manifest and apply
        run: |
          # Substitute image in deployment file using envsubst
          export IMAGE_FULL_NAME=${{ env.IMAGE_FULL_NAME }}

          # Use envsubst or yq/jq in real world; here we assume Helm or Kustomize for better flows
          kubectl set image deployment/simpleapi1 \
            simpleapi1=$IMAGE_FULL_NAME \
            -n $K8S_NAMESPACE

      - name: Verify rollout
        run: |
          kubectl rollout status deployment/simpleapi1 -n $K8S_NAMESPACE
```

> Note: In real setups, you’d usually templatize manifests via Helm or Kustomize.

---

## 17. Cost Optimization Strategies

Key levers:

- Node size (VM SKU).  
- Node count & autoscaling.  
- Spot node pools for non-critical workloads.  
- Right-sizing pod requests/limits.  
- Minimizing log volume.

Example: Enable **Cluster Autoscaler** when creating AKS:

```bash
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 2 \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5 \
  --node-vm-size Standard_B4ms \
  --attach-acr $ACR_NAME
```

**Mental Model:**

> Cost = (Node hours) + (Storage) + (Log ingestion). Focus on **autoscaling nodes**, **right-sizing pods**, and **controlling logs**.

---

## 18. Troubleshooting Playbook

Quick checklist when something breaks:

1. **Is the cluster healthy?**
   ```bash
   az aks show -g $RESOURCE_GROUP -n $AKS_NAME -o table
   ```

2. **Are nodes ready?**
   ```bash
   kubectl get nodes
   ```

3. **Are pods running?**
   ```bash
   kubectl get pods -n simple-apis
   kubectl describe pod <pod> -n simple-apis
   ```

4. **Are Services correct?**
   ```bash
   kubectl get svc -n simple-apis
   kubectl describe svc simpleapi1-svc -n simple-apis
   ```

5. **Is Ingress working?**
   ```bash
   kubectl get ingress -n simple-apis
   kubectl describe ingress simple-apis-ingress -n simple-apis
   ```

6. **Logs:**
   ```bash
   kubectl logs -f deployment/simpleapi1 -n simple-apis
   ```

7. **Port forwarding for local debugging:**
   ```bash
   kubectl port-forward svc/simpleapi1-svc 8080:80 -n simple-apis
   curl http://localhost:8080/health
   ```

---

## 19. .NET Developer AKS Interview Questions

These are practice questions commonly asked when a **.NET developer** is expected to work with AKS.

### 19.1 Conceptual Questions

1. **Explain the difference between a Pod, Deployment, and Service in Kubernetes.**  
  - **Answer (mental model – "cattle vs pets"):** A **Pod** is the smallest runnable unit (1+ containers sharing an IP and volumes) – think of it as an *individual cow*. A **Deployment** manages *a herd of identical pods*: it defines *desired state* (image, replicas, strategy) and Kubernetes keeps actual state in sync, doing rolling updates and rollbacks. A **Service** is the *stable front door* (virtual IP + DNS name) that load-balances traffic across matching pods, so clients don’t care when pods are recreated.  

2. **How would you deploy a .NET 8 Web API to AKS starting from source code?**  
  - **Answer (pipeline mental model – "source → image → cluster")**: (1) Create Dockerfile and build a container image locally, then push it to ACR. (2) Create an AKS cluster attached to that ACR. (3) Write Kubernetes manifests – `Deployment` (image + replicas + probes + env) and `Service` (ClusterIP/LoadBalancer). (4) Use `kubectl apply -f` to deploy manifests to a namespace. (5) Add Ingress for HTTP routing. (6) Optionally wire CI/CD (GitHub Actions or Azure DevOps) so pushes to `main` trigger image build + `kubectl` rollout.

3. **What’s the difference between `ClusterIP`, `NodePort`, and `LoadBalancer` Services? When would you use each?**  
  - **Answer (onion mental model – "layers of exposure")**: `ClusterIP` is the **innermost layer** – IP reachable only *inside* the cluster (default; used for internal microservice communication). `NodePort` opens a fixed port (30000–32767) on each node and forwards to the pods – rarely used directly in AKS, often a building block for external load balancers. `LoadBalancer` provisions an **external cloud load balancer** (public IP) pointing at the Service – used for direct internet exposure when you don’t use Ingress. In most production AKS setups you combine **ClusterIP + Ingress**, not NodePort.

4. **How does Horizontal Pod Autoscaler (HPA) work and what metrics can it use?**  
  - **Answer (thermostat mental model)**: HPA watches metrics (like CPU, memory, custom Prometheus, or external metrics) for a target object (Deployment/ReplicaSet). It compares *current* value with a *desired* target (e.g., 60% CPU) and periodically adjusts the replica count to bring the metric back to target – exactly like a thermostat adjusting heating/cooling. On AKS, common metrics are CPU/Memory utilization, but you can also use KEDA for queue length, HTTP qps, etc.

5. **What are readiness and liveness probes? Give examples from your APIs.**  
  - **Answer (doctor mental model – "can you work vs are you alive")**: A **liveness probe** answers "Should Kubernetes **restart** this container?" – if the probe fails repeatedly, kubelet kills the container. A **readiness probe** answers "Is this pod **ready to receive traffic**?" – if it fails, the pod stays running but is removed from Service endpoints. In our APIs, `/health/live` can be a simple 200 OK endpoint; `/health/ready` might check DB connections or downstream dependencies and return 503 if not ready.

6. **How do you manage configuration and secrets for .NET apps in AKS?**  
  - **Answer (12-factor mental model)**: Treat configuration as **environment**. For non‑secret config (feature flags, names) use **ConfigMaps** mapped to environment variables, then read via `builder.Configuration[...]`. For secrets (DB strings, API keys) use **Secrets** or better **Key Vault + Workload Identity**, exposing only references as env vars. Avoid hardcoding in code or images; keep config external and versioned.

7. **Explain how AKS integrates with Azure Container Registry (ACR).**  
  - **Answer (warehouse mental model)**: ACR is your **private image warehouse**; AKS nodes are "trucks" pulling images. Integration is via **Azure RBAC**: when you run `az aks create --attach-acr`, Azure grants the cluster’s managed identity pull (`AcrPull`) rights on ACR. Then, when kubelet schedules a pod, it authenticates to ACR using that identity and pulls images securely without embedded credentials.

8. **What is the role of an Ingress controller? How would you expose multiple services under a single public IP?**  
  - **Answer (reverse-proxy mental model)**: An Ingress controller (e.g., NGINX) is a **cluster-level reverse proxy**. It watches Ingress resources and configures routing rules (host/path → Service). To expose multiple services, you (1) deploy a single Ingress controller (one LoadBalancer IP), then (2) create an Ingress per app or per domain that routes `api.myapp.com/api1` → `simpleapi1-svc`, `api.myapp.com/api2` → `simpleapi2-svc`. One public IP, many apps behind it.

9. **How would you do blue-green or canary deployments on AKS?**  
  - **Answer (traffic-split mental model)**: In pure Kubernetes you typically use **two Deployments** (blue/green) plus (a) separate Services and switch the Ingress backend, or (b) tools like **service mesh/NGINX canary annotations** to split traffic by header/weight. Simpler approach: new Deployment with the same Service selector, scale old one down as you scale new one up (or use separate labels and update Service selector as cutover). Helm and GitOps tools can orchestrate this.

10. **What’s the difference between scaling pods and scaling nodes? When might pods be pending even though HPA wants more replicas?**
   - **Answer (two-level scaling mental model)**: **Pod scaling** (HPA) changes replica count of workloads; **node scaling** (Cluster Autoscaler) adjusts VM nodes. HPA may request more replicas, but if nodes don’t have enough CPU/memory to place them, pods become `Pending` with `Insufficient cpu/memory`. That’s when **Cluster Autoscaler** must kick in to add nodes, or you must right-size requests.

### 19.2 .NET + AKS Scenario Questions

1. **You have a .NET minimal API running in AKS that randomly returns 500 errors under load. How would you diagnose this?**  
  - **Answer (layered investigation)**: (1) Start with `kubectl get pods` and `kubectl describe pod` to check restarts, OOMKilled, or probe failures. (2) Use `kubectl logs` (and Application Insights if enabled) to see stack traces and correlation IDs. (3) Verify HPA and resource limits: `kubectl get hpa`, check if instances are CPU throttled. (4) Load-test a single pod with `kubectl port-forward` to see if the bug is app-level (e.g., thread starvation, deadlocks) vs cluster-level (e.g., not enough replicas). (5) If it’s external dependencies (DB/service), check their latency and circuit-breaker configuration.

2. **How would you configure your .NET app to call another microservice within the same AKS cluster?**  
  - **Answer (DNS + HttpClient mental model)**: Create a Kubernetes Service for the downstream app (e.g., `simpleapi2-svc`) and call it using its DNS name (e.g., `http://simpleapi2-svc.simple-apis.svc.cluster.local`). In .NET, register a named `HttpClient` using `IHttpClientFactory`, configure base address to that DNS, and optionally add Polly handlers for retries/timeouts. This keeps calls internal, fast, and independent of ingress/public IPs.

3. **How do you handle database connection strings securely in AKS?**  
  - **Answer (no secret in code/image)**: Store secrets in **Azure Key Vault** and use **Workload Identity** or Managed Identity from pods to retrieve them at runtime (`DefaultAzureCredential` + `SecretClient`). For simpler cases, store connection strings in Kubernetes Secrets referenced as env vars. Do not bake secrets into Docker images, git repos, or ConfigMaps.

4. **What changes (if any) do you make to a .NET app to make it Kubernetes-friendly?**  
  - **Answer (12-factor + K8s hooks)**: Add `/health/live` and `/health/ready` endpoints for probes; use environment variables for configuration; ensure graceful shutdown by respecting SIGTERM (e.g., don’t block the thread, use async, dispose resources). Avoid writing to local disk as persistent storage; rely on external stores (DB, blob, PV). Make the app stateless where possible so pods can be scaled and recreated at will.

5. **Your AKS cluster becomes expensive. As a .NET dev with some DevOps ownership, what would you look at?**  
  - **Answer (three buckets – compute, storage, logs)**: (1) **Compute** – Are node sizes too large? Is Cluster Autoscaler enabled? Are pod requests/limits oversized so nodes underutilize CPU? (2) **Storage** – Are there unused disks/PVs, excessive premium storage? (3) **Observability** – Is Log Analytics ingesting too much (set log levels, sampling). Also check for idle namespaces/workloads and use dev/test node pools or spot nodes where appropriate.

### 19.3 Hands-On Style Questions

1. *“Given this `Deployment` YAML, can you point out any anti-patterns?”*  
  - **Answer guidance:** Look for missing `resources` (requests/limits), lack of `livenessProbe`/`readinessProbe`, `image: myapp:latest`, container running as root, no labels/selectors, or hard-coded hostnames.

2. *“Write a simple Kubernetes manifest to deploy a .NET API with 3 replicas and expose it within the cluster.”*  
  - **Answer guidance:** Use a `Deployment` with `spec.replicas: 3` and a `Service` of type `ClusterIP` (similar to `simpleapi1` in this guide). The key is matching `selector` labels and `template.metadata.labels` so the Service finds the pods.

3. *“How would you roll back a bad deployment in AKS?”*  
   ```bash
   kubectl rollout history deployment/simpleapi1 -n simple-apis
   kubectl rollout undo deployment/simpleapi1 -n simple-apis
   ```
  - **Answer guidance:** Explain that Deployments keep revision history; you can inspect it with `rollout history` and revert using `rollout undo` (optionally `--to-revision=N`). Also mention monitoring metrics/logs after rollback.

4. *“Show how you’d add a `/health` endpoint to your .NET API and wire it into Kubernetes probes.”*  
  - **Answer guidance:** In code, implement `/health/live` and `/health/ready` endpoints; in YAML, configure `livenessProbe` and `readinessProbe` HTTP checks pointing to those paths with sensible delays and periods. Emphasize the difference between the two probes.

5. *“How would you add structured logging and push it to Azure Monitor from your AKS-hosted .NET service?”*  
  - **Answer guidance:** Use ASP.NET Core built-in logging (`ILogger`) with structured messages. Enable Azure Monitor/Container Insights on the cluster so stdout/stderr logs flow to Log Analytics. Optionally add Application Insights SDK to the app for traces/requests/dependencies, and configure the instrumentation key/connection string via environment variables.

---

## 20. Quick Reference Cheat Sheet

```bash
# ===== CLUSTER & CONTEXT =====
az aks get-credentials -g <rg> -n <aks-name> --overwrite-existing
kubectl config get-contexts
kubectl config use-context <context>

# ===== NAMESPACES =====
kubectl get ns
kubectl create namespace simple-apis

# ===== DEPLOYMENTS & PODS =====
kubectl apply -f k8s-simpleapi1.yaml
kubectl get deployments -n simple-apis
kubectl get pods -n simple-apis -o wide
kubectl describe deployment simpleapi1 -n simple-apis

# ===== SERVICES & INGRESS =====
kubectl get svc -n simple-apis
kubectl get ingress -n simple-apis

# ===== LOGS & DEBUGGING =====
kubectl logs -f deployment/simpleapi1 -n simple-apis
kubectl describe pod <pod> -n simple-apis
kubectl exec -it <pod> -n simple-apis -- /bin/sh
kubectl port-forward svc/simpleapi1-svc 8080:80 -n simple-apis

# ===== SCALING =====
kubectl get hpa -n simple-apis
kubectl scale deployment simpleapi1 --replicas=5 -n simple-apis

# ===== ROLLOUTS =====
kubectl rollout status deployment/simpleapi1 -n simple-apis
kubectl rollout history deployment/simpleapi1 -n simple-apis
kubectl rollout undo deployment/simpleapi1 -n simple-apis
```

---

**You can now use this guide as a single source to go from:**

- Writing a **simple .NET minimal API** →  
- Containerizing it with Docker →  
- Pushing it to ACR →  
- Running it in AKS with Deployments, Services, and Ingress →  
- Scaling, securing, monitoring, and troubleshooting it in production.

Use this as a workbook: 
- Type the commands, 
- Deploy the YAMLs, 
- Change values and re-apply, 
- Watch the effects live in AKS.

That hands-on loop is how you build real AKS expertise as a .NET developer.

---

## 21. Sample Command Outputs & What They Mean

This section shows **typical outputs** for the most important commands in the guide so you can quickly recognize whether things look healthy.

### 21.1 Azure CLI & Docker

```bash
az group create -n rg-aks-demo -l eastus
```

Sample output:

```json
{
  "id": "/subscriptions/<sub>/resourceGroups/rg-aks-demo",
  "location": "eastus",
  "managedBy": null,
  "name": "rg-aks-demo",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "type": "Microsoft.Resources/resourceGroups"
}
```

> **Interpretation:** Resource group exists and is ready if `provisioningState` is `Succeeded`.

```bash
az acr create \
  --resource-group rg-aks-demo \
  --name acrdemoaks123 \
  --sku Basic \
  --admin-enabled true
```

Key part of output:

```json
"loginServer": "acrdemoaks123.azurecr.io",
"provisioningState": "Succeeded",
"sku": { "name": "Basic" },
"adminUserEnabled": true
```

> Mental model: This is your **private Docker Hub in Azure**. Note the `loginServer` – you’ll use it in image tags.

```bash
docker build -t simpleapi1:latest .
```

Tail of output:

```text
Successfully built 7c1a4e8bf8f3
Successfully tagged simpleapi1:latest
```

> Means the image is ready in your local Docker daemon.

```bash
docker push acrdemoaks123.azurecr.io/simpleapi1:v1
```

Tail of output:

```text
v1: digest: sha256:9b3a... size: 2413
```

> Image successfully stored in ACR – `digest` is the immutable content ID.

### 21.2 AKS Cluster & Nodes

```bash
az aks create --resource-group rg-aks-demo --name aks-simpleapis ...
```

You’ll see a long JSON; key fields:

```json
"provisioningState": "Succeeded",
"agentPoolProfiles": [
  {
    "count": 2,
    "vmSize": "Standard_B4ms",
    "mode": "System"
  }
]
```

```bash
az aks get-credentials -g rg-aks-demo -n aks-simpleapis --overwrite-existing
```

Output:

```text
Merged "aks-simpleapis" as current context in /home/user/.kube/config
```

```bash
kubectl get nodes
```

```text
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-12345678-vmss000000   Ready    agent   10m   v1.29.x
aks-nodepool1-12345678-vmss000001   Ready    agent   10m   v1.29.x
```

> **Healthy cluster**: all nodes `Ready` with a recent Kubernetes version.

### 21.3 Workloads & Namespaces

```bash
kubectl get ns
```

```text
NAME              STATUS   AGE
default           Active   12m
kube-system       Active   12m
ingress-nginx     Active   5m
simple-apis       Active   3m
```

```bash
kubectl get deployments -n simple-apis
```

```text
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
simpleapi1   3/3     3            3           2m
simpleapi2   2/2     2            2           2m
```

> `READY` should equal `replicas`; if not, check probes and logs.

```bash
kubectl get svc -n simple-apis
```

```text
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
simpleapi1-svc  ClusterIP   10.0.200.101   <none>        80/TCP    2m
simpleapi2-svc  ClusterIP   10.0.74.223    <none>        80/TCP    2m
```

### 21.4 Ingress & HPA

```bash
kubectl get ingress -n simple-apis
```

```text
NAME                  CLASS   HOSTS                     ADDRESS         PORTS   AGE
simple-apis-ingress   nginx   aks-simpleapis.demo.com   20.50.100.200   80      5m
```

```bash
kubectl get hpa -n simple-apis
```

```text
NAME            REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
simpleapi1-hpa  Deployment/simpleapi1  30%/60%   2         10        2          3m
```

> `TARGETS` shows *current/desired* metric. When current > desired, HPA will scale out.

### 21.5 Health & Logs

```bash
curl http://$INGRESS_IP/api1/health
```

```json
{"status":"healthy","timestamp":"2026-02-26T10:30:00Z"}
```

```bash
kubectl logs -f deployment/simpleapi1 -n simple-apis
```

```text
info: SimpleApi[0]
      Handling /hello for World
info: SimpleApi[0]
      Handling /hello for Alice
```

> Mental model: **`kubectl` shows cluster health**, `curl` shows **app health**.

---

## 22. Persistent Volumes & Storage on AKS

AKS supports multiple storage backends (Azure Disks, Azure Files). The **mental model** is:

> Pod ↔ PVC (claim) ↔ PV (actual storage) ↔ Azure Disk/File.

You normally interact with **PersistentVolumeClaim** (PVC); AKS and CSI drivers handle the rest.

### 22.1 Use Case – Upload Folder for SimpleApi1

Say SimpleApi1 needs a shared folder `/app/uploads` across restarts.

#### 22.1.1 Create a StorageClass (for Azure Disk)

Most AKS clusters have a default StorageClass, but here is an explicit one:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-csi
provisioner: disk.csi.azure.com
parameters:
  skuName: StandardSSD_LRS
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

Key attributes:

- `provisioner` – Uses Azure Disk CSI driver.
- `skuName` – Disk performance tier.
- `reclaimPolicy` – `Delete` means PV is deleted when PVC is deleted.
- `volumeBindingMode` – Wait until a pod is scheduled before creating disk.

Apply:

```bash
kubectl apply -f storageclass-managed-csi.yaml
kubectl get storageclass
```

#### 22.1.2 Create a PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: uploads-pvc
  namespace: simple-apis
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: managed-csi
```

Explanation:

- `accessModes: ReadWriteOnce` – Mounted read/write by a single node (fine for most APIs).
- `resources.requests.storage` – Requested size; Azure Disk of ~10Gi will be created.

Apply and check:

```bash
kubectl apply -f pvc-uploads.yaml
kubectl get pvc -n simple-apis
```

```text
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
uploads-pvc   Bound    pvc-1234abcd-...                           10Gi       RWO            managed-csi    1m
```

#### 22.1.3 Mount PVC in SimpleApi1 Deployment

Patch `simpleapi1` Deployment:

```yaml
spec:
  template:
    spec:
      volumes:
        - name: uploads-volume
          persistentVolumeClaim:
            claimName: uploads-pvc
      containers:
        - name: simpleapi1
          image: acrdemoaks123.azurecr.io/simpleapi1:v1
          volumeMounts:
            - name: uploads-volume
              mountPath: /app/uploads
```

**Mental model:** Pods are ephemeral, but the disk backing `/app/uploads` is **not**; when pods restart, data remains.

### 22.2 Using Azure Files for Shared Read/Write

For multiple pods across nodes, use **Azure Files** (SMB-like share). You’d use a different CSI driver and `ReadWriteMany` access mode – conceptually the same PVC → PV → Azure Files mapping.

### 22.3 Volume Types Cheat Sheet

At a glance:

- `emptyDir` – Ephemeral scratch space shared by containers in a pod; deleted when the pod is deleted.
- `configMap` / `secret` volumes – Project configuration/secret keys as files; great for mounting JSON configs.
- `persistentVolumeClaim` (backed by Azure Disk or Azure Files) – Long-lived storage surviving pod restarts.
- `hostPath` – Direct host filesystem mount (avoid in AKS except for very specific daemon scenarios).
- `ephemeral` / `emptyDir` on SSD – For high-speed cache that can be lost without data loss.

**Rule of thumb:**

- Use **managed databases** (Azure SQL, Cosmos DB) for business data.  
- Use **Azure Disk** for per-node durable volumes.  
- Use **Azure Files** for shared read/write scenarios.  
- Use **ConfigMap/Secret volumes** for configuration files and TLS certs.

### 22.4 Azure Files Example (ReadWriteMany)

Create a StorageClass for Azure Files (if one does not already exist):

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi
provisioner: file.csi.azure.com
parameters:
  skuName: Standard_LRS
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

Then create a PVC that uses `ReadWriteMany`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-files-pvc
  namespace: simple-apis
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: azurefile-csi
```

Mount it into both SimpleApi1 and SimpleApi2 for a shared folder:

```yaml
spec:
  template:
    spec:
      volumes:
        - name: shared-files
          persistentVolumeClaim:
            claimName: shared-files-pvc
      containers:
        - name: simpleapi1
          volumeMounts:
            - name: shared-files
              mountPath: /app/shared
```

Now any file written under `/app/shared` from one pod instance is visible to all pods mounting the same Azure Files share.

---

## 23. Terraform IaC for AKS & ACR

Terraform lets you define AKS + ACR as **code** so environments are reproducible.

### 23.1 Minimal Terraform Layout

`providers.tf`:

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}
``;

`main.tf`:

```hcl
locals {
  location = "eastus"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-demo-tf"
  location = local.location
}

resource "azurerm_container_registry" "acr" {
  name                = "acrdemoakstf123"   # must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-simpleapis-tf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-simpleapis-tf"

  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = "Standard_B4ms"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
```

### 23.2 Terraform Commands & Sample Output

```bash
terraform init
```

```text
Initializing the backend...
Initializing provider plugins...

Terraform has been successfully initialized!
```

```bash
terraform plan
```

```text
Plan: 3 to add, 0 to change, 0 to destroy.

  # azurerm_resource_group.rg will be created
  # azurerm_container_registry.acr will be created
  # azurerm_kubernetes_cluster.aks will be created
```

```bash
terraform apply
```

```text
azurerm_resource_group.rg: Creation complete
azurerm_container_registry.acr: Creation complete
azurerm_kubernetes_cluster.aks: Creation complete

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

> Mental model: Terraform keeps a **state file** = "source of truth" for your Azure infrastructure; `plan` shows diff, `apply` reconciles reality to that.

---

## 24. Azure DevOps CI/CD Pipeline for AKS

We already showed GitHub Actions. This section shows a **multi‑stage Azure DevOps pipeline** that builds, pushes, and deploys SimpleApi1.

### 24.1 Service Connection & Variables

Prerequisites:

- Azure DevOps **service connection** to your subscription (e.g., `Azure-ServiceConnection`).
- Variable group or pipeline variables:
  - `resourceGroup = rg-aks-demo`
  - `aksName = aks-simpleapis`
  - `acrName = acrdemoaks123`
  - `imageName = simpleapi1`

### 24.2 azure-pipelines.yml (Build + Deploy)

```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - SimpleApi1/*

stages:
  - stage: Build
    displayName: Build & Push Image
    jobs:
      - job: Build
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - checkout: self

          - task: AzureCLI@2
            displayName: 'Build and push to ACR'
            inputs:
              azureSubscription: 'Azure-ServiceConnection'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                IMAGE_TAG=$(Build.BuildId)
                IMAGE_FULL_NAME=$(acrName).azurecr.io/$(imageName):$IMAGE_TAG

                az acr login --name $(acrName)

                docker build -t $IMAGE_FULL_NAME ./SimpleApi1
                docker push $IMAGE_FULL_NAME

                echo "##vso[task.setvariable variable=IMAGE_FULL_NAME;isOutput=true]$IMAGE_FULL_NAME"
            name: buildStep

  - stage: Deploy
    displayName: Deploy to AKS
    dependsOn: Build
    jobs:
      - deployment: DeployToAks
        environment: 'aks-simpleapis'
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - checkout: self

                - task: AzureCLI@2
                  displayName: 'Get AKS credentials'
                  inputs:
                    azureSubscription: 'Azure-ServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      az aks get-credentials \
                        --resource-group $(resourceGroup) \
                        --name $(aksName) \
                        --overwrite-existing

                - task: AzureCLI@2
                  displayName: 'Update image in Deployment'
                  inputs:
                    azureSubscription: 'Azure-ServiceConnection'
                    scriptType: 'bash'
                    scriptLocation: 'inlineScript'
                    inlineScript: |
                      IMAGE_FULL_NAME=$(acrName).azurecr.io/$(imageName):$(Build.BuildId)
                      kubectl set image deployment/simpleapi1 \
                        simpleapi1=$IMAGE_FULL_NAME \
                        -n simple-apis

                      kubectl rollout status deployment/simpleapi1 -n simple-apis
```

**Mental model:** CI (Build stage) always produces a **new image tag**, CD (Deploy stage) simply **points the Deployment** to that new tag and waits for a healthy rollout.

---

## 25. Advanced AKS Architecture & Operations (Architect View)

This section summarizes architect-level topics that go **beyond first deployments** so you can reason about production‑grade AKS platforms.

### 25.1 Cluster & Networking Architecture

- **Network plugins (Azure CNI vs kubenet)**  
  - *Azure CNI*: Pods get IPs from the VNet; easy pod‑to‑on‑prem access, but you must plan address space carefully.  
  - *kubenet*: Pods get IPs from an overlay; nodes use NAT for egress. Simpler IP use, but more hops to reach pods.
- **VNet design & IP planning**  
  - Plan separate subnets for: AKS node pool(s), Application Gateway / NAT gateway, data tier (databases), jumpbox/bastion.  
  - Leave enough IPs for **pod density** (pods per node × nodes per pool × growth headroom).
- **Private clusters & egress**  
  - Private cluster = API server has only a private IP; use Azure Bastion, VPN, or ExpressRoute to manage.  
  - Use **NAT Gateway** for stable outbound IPs from the cluster (important for IP allowlists in downstream systems).
- **Node pools strategy**  
  - Split **system** vs **user** node pools (system pool minimal and stable; user pools scale up/down).  
  - Add specialized pools: spot nodes for cheap batch work; GPU pools for ML workloads; memory‑optimized pools for heavy APIs.  
  - Use **taints/tolerations** and **nodeSelectors** to steer workloads to appropriate pools.

### 25.2 Security, Compliance & Governance

- **NetworkPolicies**  
  - Think of them as **firewall rules inside the cluster**: restrict which pods can talk to which pods/namespaces.  
  - Typical pattern: deny‑all then allow only required flows (web → API → DB proxy, monitoring agents, etc.).
- **Pod security**  
  - Use **Pod Security Standards** (baseline/restricted) or **OPA Gatekeeper/Azure Policy** to enforce:  
    - No privileged containers, no root filesystem writes, minimal Linux capabilities, no host networking.  
  - Mental model: define a **“safe pod contract”** and make admission controllers enforce it.
- **Identity & secrets**  
  - Standardize on **Workload Identity + Key Vault CSI driver**; avoid long‑lived secrets in YAML.  
  - Architecture: pod’s ServiceAccount ↔ federated credential ↔ Entra app ↔ Key Vault access policy.
- **Supply chain security**  
  - Use **ACR tasks or GitHub Actions** to scan images (e.g., Trivy/Defender for Cloud).  
  - Optionally sign images (Cosign/Notary) and enforce signed‑only policies via Gatekeeper.

### 25.3 Operations, Upgrades & SRE Practices

- **Upgrade strategy**  
  - Separate: **control plane upgrade** (AKS-managed) and **node pool upgrades** (agent nodes).  
  - Use **surge upgrades**: AKS temporarily adds nodes, drains old ones, and rolls workloads; define maintenance windows.  
  - Always test upgrades in **pre‑prod cluster** before production.
- **Backup & restore**  
  - Use tools like **Velero** to back up Kubernetes objects and volumes.  
  - Treat infra as code: Git + Terraform/Bicep as the **source of truth**; rebuilding cluster from code is the primary recovery path.
- **Observability deep‑dive**  
  - Design **SLOs** (e.g., 99.9% success rate, p95 latency < 300 ms) and drive alerts from them.  
  - Use KQL queries in Log Analytics for: error spikes, slow endpoints, noisy neighbors, and capacity trends.  
  - Add distributed tracing (OpenTelemetry → Application Insights) for cross‑service call chains.
- **Advanced debugging**  
  - Use `kubectl exec` and **ephemeral containers** for live debugging of running pods.  
  - When nodes misbehave, inspect `kubelet` and container runtime logs; consider cordoning/draining suspect nodes.

### 25.4 Application Architecture Patterns on AKS

- **Resiliency**  
  - Use **Polly** in .NET for retries with backoff, circuit breakers, and timeouts.  
  - Keep operations **idempotent** and safe to retry; design compensating actions where required.
- **Messaging & background work**  
  - Run consumers for **Service Bus/Event Hubs** as Deployments with HPA based on queue depth or lag.  
  - For long‑running jobs, prefer **Jobs/CronJobs** or dedicated worker services instead of overloading HTTP APIs.
- **API Gateway vs Ingress**  
  - Ingress is primarily **L7 routing + TLS termination**.  
  - When you need advanced features (global routing, rate limits, auth offload, API versioning), front AKS with **APIM** or a dedicated gateway (Envoy/NGINX Plus/Kong).
- **Stateful workloads**  
  - Use **StatefulSets** for components that need stable identities and persistent volumes (e.g., Kafka/ZooKeeper).  
  - Prefer managed services (Azure SQL/Cosmos DB/Redis) for core data; use StatefulSets mainly when no managed option fits.

### 25.5 Data & Storage Strategy

- **Choosing storage**  
  - Azure Disk – high‑performance block storage for a single node (`ReadWriteOnce`).  
  - Azure Files – shared file storage (`ReadWriteMany`) for multiple pods across nodes.  
  - Azure NetApp Files – high‑end NFS for demanding workloads.  
  - External DBs – use managed PaaS (SQL, Cosmos) for business data; keep only cache/temp data on PVs.
- **Multi‑tenant isolation**  
  - Options: segregated namespaces per tenant, separate databases per tenant, or row‑level security in shared DBs.  
  - Choose based on regulatory isolation needs, tenant count, and operational overhead.

### 25.6 Platform Engineering & Delivery

- **GitOps (Flux/Argo CD)**  
  - Cluster watches Git repos for desired state; merge to `main` = deploy.  
  - Mental model: CI builds images; GitOps CD syncs manifests/Helm charts.
- **Helm as packaging unit**  
  - Wrap your Deployments, Services, Ingress, HPA, and ConfigMaps into **Helm charts** with per‑environment `values.yaml`.  
  - Version charts and use `helm rollback` for quick reversions.
- **Platform team model**  
  - Create **golden paths**: pre‑built templates (repos + charts + pipelines) for APIs, workers, and event processors.  
  - App teams stay focused on business code; platform team owns the AKS platform (security, upgrades, shared tooling).

Use this section as a **roadmap of what to learn next** once you are comfortable with the earlier, hands‑on sections of the guide.

---

## 26. Helm Packaging & Releases

Helm is the **package manager for Kubernetes**. Instead of applying many YAML files manually, you bundle them into a **chart** and manage releases with `helm install/upgrade/rollback`.

### 26.1 Mental Model

```text
values.yaml (config per env)
        ↓
Helm templates (Deployment, Service, Ingress, HPA, ConfigMap...)
        ↓
Rendered Kubernetes manifests
        ↓
Applied to cluster as a release (versioned)
```

### 26.2 Create a Chart for SimpleApi1

From repo root:

```bash
mkdir -p charts
cd charts
helm create simpleapi1
```

This generates a structure like:

```text
charts/simpleapi1/
  Chart.yaml
  values.yaml
  templates/
    deployment.yaml
    service.yaml
    ingress.yaml
    hpa.yaml
    _helpers.tpl
```

### 26.3 Customize values.yaml

Edit `charts/simpleapi1/values.yaml` (simplified):

```yaml
replicaCount: 3

image:
  repository: acrdemoaks123.azurecr.io/simpleapi1
  tag: "v1"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: aks-simpleapis.demo.com
      paths:
        - path: /api1(/|$)(.*)
          pathType: Prefix

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

The default `templates/deployment.yaml` uses these values via `{{ .Values.image.repository }}`, `{{ .Values.replicaCount }}`, etc. You can adapt it to match the earlier raw YAML.

### 26.4 Install the Chart

From the `charts` folder:

```bash
helm install simpleapi1-release ./simpleapi1 \
  --namespace simple-apis \
  --create-namespace
```

Sample output:

```text
NAME: simpleapi1-release
LAST DEPLOYED: 2026-02-26 10:30:00
NAMESPACE: simple-apis
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  ...
```

Verify resources:

```bash
kubectl get all -n simple-apis
helm list -n simple-apis
```

### 26.5 Upgrades and Rollbacks

To deploy a new image tag:

```bash
helm upgrade simpleapi1-release ./simpleapi1 \
  --namespace simple-apis \
  --set image.tag=v2
```

Sample output:

```text
Release "simpleapi1-release" has been upgraded. Happy Helming!
NAME: simpleapi1-release
LAST DEPLOYED: 2026-02-26 11:00:00
NAMESPACE: simple-apis
STATUS: deployed
REVISION: 2
```

If something goes wrong:

```bash
helm rollback simpleapi1-release 1 -n simple-apis
```

> Mental model: A **Helm release** is a versioned snapshot of your app’s manifests + values; upgrades create new revisions, and rollbacks move back to older revisions.

---

## 27. GitOps with Argo CD

Argo CD implements **GitOps**: Kubernetes state is driven by **what’s in Git**, not by ad‑hoc `kubectl apply` commands.

### 27.1 Mental Model

```text
Git repo (manifests or Helm charts)
        ↓
Argo CD (watches repo, compares to cluster)
        ↓
Kubernetes cluster (desired state = Git)
```

You **commit** changes to Git; Argo CD detects them and **syncs** the cluster.

### 27.2 Install Argo CD

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f \
  https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get pods -n argocd
```

Sample output:

```text
NAME                                  READY   STATUS    RESTARTS   AGE
argocd-application-controller-0       1/1     Running   0          2m
argocd-repo-server-xxxxxxx-xxxxx     1/1     Running   0          2m
argocd-server-xxxxxxx-xxxxx          1/1     Running   0          2m
...
```

To access the Argo CD UI (for local testing):

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open `https://localhost:8080` in a browser.

### 27.3 Prepare a Git Repository

Assume you have a Git repo with either:

- Plain manifests in `k8s/` (e.g., `k8s-simpleapi1.yaml`, `k8s-simpleapi2.yaml`, `k8s-ingress.yaml`), **or**
- A Helm chart in `charts/simpleapi1` as shown earlier.

Commit and push these files to, say, `main` branch.

### 27.4 Create an Argo CD Application (Manifests Example)

Create `argocd-app-simpleapis.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: simpleapis
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/your-org/aks-simpleapis.git'
    targetRevision: main
    path: k8s          # folder containing k8s-simpleapi*.yaml
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: simple-apis
  syncPolicy:
    automated:
      prune: true      # Delete resources removed from Git
      selfHeal: true   # Re-apply drifted resources
    syncOptions:
      - CreateNamespace=true
```

Apply and inspect:

```bash
kubectl apply -f argocd-app-simpleapis.yaml
kubectl get applications.argoproj.io -n argocd
```

In the Argo CD UI you’ll see the `simpleapis` application; once synced, it will create the namespace and deploy your APIs.

### 27.5 Using Helm with Argo CD

To use a Helm chart instead of plain manifests, change the `source` section:

```yaml
spec:
  source:
    repoURL: 'https://github.com/your-org/aks-simpleapis.git'
    targetRevision: main
    path: charts/simpleapi1
    helm:
      releaseName: simpleapi1-release
      values: |
        image:
          tag: v1
        replicaCount: 3
```

Argo CD will run `helm template` under the hood and apply the rendered manifests.

### 27.6 Day-2 Flow with GitOps

Typical change flow:

1. Developer changes `values.yaml` (e.g., new image tag `v2`, different replicas).  
2. Commit + push to `main`.  
3. Argo CD detects the diff and marks the app as **OutOfSync**.  
4. With `automated` policy enabled, Argo CD automatically syncs; otherwise, you click **Sync** in the UI or run `argocd app sync simpleapis`.  
5. Cluster reflects new desired state; if something fails, you revert in Git (Git history = change history).

> Mental model: Git is the **single source of truth** for manifests/Helm values; Argo CD is the **controller** that keeps the cluster in lockstep with that truth.

---

## 28. Azure Application Gateway Ingress & DNS Zones

So far we used **NGINX Ingress Controller**. Azure also offers an **Application Gateway Ingress Controller (AGIC)** that uses **Azure Application Gateway** (Layer 7 load balancer/WAF) as the ingress layer integrated with Azure networking and DNS.

### 28.1 Mental Model – NGINX vs Application Gateway

```text
Internet
  ↓
DNS (api.mycompany.com → App Gateway public IP)
  ↓
Azure Application Gateway (WAF, HTTPS termination, routing)
  ↓
AKS cluster Services (ClusterIP) → Pods (SimpleApi1/2)
```

- **NGINX Ingress** – Runs inside the AKS cluster as pods; fronted by a LoadBalancer service. Great for flexibility and portability.
- **Application Gateway** – Azure-managed service with built-in WAF, SSL offload, and integration with VNet, DNS, and routing features.
- **AGIC** – A controller running in AKS that **translates Ingress resources into Application Gateway configuration**.

### 28.2 High-Level Setup Steps

1. Create a **VNet** and subnets for AKS and App Gateway.  
2. Provision an **Application Gateway** in its own subnet.  
3. Create an AKS cluster in the VNet.  
4. Enable the **ingress-appgw** addon to connect AKS to Application Gateway.  
5. Create `Ingress` resources (similar to NGINX); AGIC programs Application Gateway accordingly.  
6. Use **Azure DNS** to point `api.mycompany.com` to the App Gateway public IP.

### 28.3 VNet and Application Gateway (Conceptual Commands)

```bash
RESOURCE_GROUP="rg-aks-demo"
LOCATION="eastus"
VNET_NAME="vnet-aks-appgw"
SUBNET_AKS="snet-aks"
SUBNET_APPGW="snet-appgw"

# Create VNet with two subnets
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name $SUBNET_AKS \
  --subnet-prefixes 10.0.0.0/24

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_APPGW \
  --address-prefixes 10.0.1.0/24

# Create public IP for Application Gateway
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name pip-appgw \
  --sku Standard \
  --allocation-method static

# Create Application Gateway (simplified)
az network application-gateway create \
  --resource-group $RESOURCE_GROUP \
  --name appgw-simpleapis \
  --sku WAF_v2 \
  --public-ip-address pip-appgw \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_APPGW

APPGW_ID=$(az network application-gateway show \
  --resource-group $RESOURCE_GROUP \
  --name appgw-simpleapis \
  --query id -o tsv)
```

### 28.4 Attach Application Gateway to AKS (AGIC)

When creating AKS, you can specify the VNet subnet and then enable AGIC:

```bash
AKS_NAME="aks-simpleapis"

az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 2 \
  --network-plugin azure \
  --vnet-subnet-id \
    $(az network vnet subnet show -g $RESOURCE_GROUP -n $SUBNET_AKS --vnet-name $VNET_NAME --query id -o tsv) \
  --enable-managed-identity

az aks enable-addons \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --addons ingress-appgw \
  --appgw-id $APPGW_ID
```

Sample output (snippet):

```text
"addonProfiles": {
  "ingressApplicationGateway": {
    "enabled": true,
    "config": {
      "applicationGatewayId": "/subscriptions/.../resourceGroups/rg-aks-demo/providers/Microsoft.Network/applicationGateways/appgw-simpleapis"
    }
  }
}
```

### 28.5 Ingress Resources with Application Gateway

The **Ingress YAML is almost identical** to the NGINX example; AGIC reads it and configures listeners, rules, and backend pools on Application Gateway.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-apis-agic
  namespace: simple-apis
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
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

Apply and verify:

```bash
kubectl apply -f k8s-ingress-agic.yaml
kubectl get ingress -n simple-apis
```

### 28.6 Azure DNS Zones and Records

Use Azure DNS to map a **friendly host name** to the Application Gateway public IP.

```bash
DNS_ZONE_NAME="mycompany.com"

az network dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name $DNS_ZONE_NAME

APPGW_IP=$(az network public-ip show \
  --resource-group $RESOURCE_GROUP \
  --name pip-appgw \
  --query ipAddress -o tsv)

az network dns record-set a add-record \
  --resource-group $RESOURCE_GROUP \
  --zone-name $DNS_ZONE_NAME \
  --record-set-name api \
  --ipv4-address $APPGW_IP
```

Now `api.mycompany.com` (A record) resolves to the Application Gateway IP. With the Ingress host set to `api.mycompany.com`, the full flow is:

```text
Client → DNS (api.mycompany.com) → App Gateway → AGIC-configured HTTP settings → AKS Services → Pods
```

> Mental model: **NGINX Ingress** is cluster-local and flexible; **Application Gateway Ingress** integrates deeply with Azure networking, WAF, and DNS. Choose based on your organization’s security/networking standards.


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