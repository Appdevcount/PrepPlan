# 09 — Docker & Kubernetes (AKS)

> **Mental Model:** Docker is a shipping container — your app + all its dependencies
> in one sealed box that runs identically everywhere. Kubernetes is the cargo ship —
> it orchestrates thousands of containers, restarts failed ones, and scales on demand.

---

## Dockerfile — Multi-Stage Build Pattern

```dockerfile
# ── Stage 1: Build ────────────────────────────────────────────────────────────
# WHY SDK image for build: contains dotnet build/publish tools (large ~600MB)
# WHY NOT SDK in final image: final image only needs runtime (~200MB) — smaller = faster pull
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# WHY copy .csproj first (before source): Docker layer cache.
#   If source changes but .csproj doesn't, the restore layer is cached — faster builds.
COPY ["src/Orders.Api/Orders.Api.csproj", "src/Orders.Api/"]
COPY ["src/Orders.Application/Orders.Application.csproj", "src/Orders.Application/"]
COPY ["src/Orders.Domain/Orders.Domain.csproj", "src/Orders.Domain/"]
COPY ["src/Orders.Infrastructure/Orders.Infrastructure.csproj", "src/Orders.Infrastructure/"]

# Restore before copying full source — layer cached until .csproj changes
RUN dotnet restore "src/Orders.Api/Orders.Api.csproj"

# Now copy all source — cache bust only here if source changes
COPY . .

WORKDIR "/src/src/Orders.Api"
RUN dotnet publish "Orders.Api.csproj" \
    -c Release \
    -o /app/publish \
    --no-restore \                    # WHY --no-restore: already restored above
    /p:UseAppHost=false               # WHY: removes native executable wrapper — not needed in Linux container

# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

# WHY non-root user: container escapes are less impactful if process runs as non-root
RUN adduser --disabled-password --gecos "" appuser
USER appuser

WORKDIR /app
COPY --from=build /app/publish .

# WHY ASPNETCORE_HTTP_PORTS not ASPNETCORE_URLS: newer, cleaner in .NET 8+
ENV ASPNETCORE_HTTP_PORTS=80
EXPOSE 80

# WHY ENTRYPOINT not CMD: ENTRYPOINT can't be overridden by accident.
#   Use CMD only when you want the default to be overridable.
ENTRYPOINT ["dotnet", "Orders.Api.dll"]
```

---

## .dockerignore

```
# WHY .dockerignore: prevents sending unnecessary files to Docker daemon.
#   Without it: node_modules, .git, bin/obj are sent = slow builds + accidental leaks.

.git
.gitignore
**/bin
**/obj
**/.vs
**/node_modules
*.md
.env
.env.*               # WHY: never send env files — may contain secrets
**/TestResults
**/coverage
Dockerfile*
docker-compose*
```

---

## Kubernetes Deployment Manifest

```yaml
# ── deployment.yaml ──────────────────────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orders-api
  namespace: production
  labels:
    app: orders-api
    version: "1.0.0"
spec:
  replicas: 3              # WHY 3: one per availability zone in AKS (3-zone cluster)
  selector:
    matchLabels:
      app: orders-api
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # WHY 1: create 1 new pod before removing old — no downtime
      maxUnavailable: 0    # WHY 0: always keep full replica count during rollout
  template:
    metadata:
      labels:
        app: orders-api
        version: "1.0.0"
    spec:
      # WHY topologySpreadConstraints: spread pods across nodes and zones
      #   Without this: all 3 pods might land on 1 node — node failure = full outage
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app: orders-api

      containers:
        - name: orders-api
          image: myregistry.azurecr.io/orders-api:1.0.0
          ports:
            - containerPort: 80

          # ── Resource limits — ALWAYS set these ───────────────────────────
          # WHY limits: without them one pod can starve others on the same node
          # WHY requests: scheduler uses requests to decide pod placement
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"      # 100 millicores = 0.1 CPU
            limits:
              memory: "256Mi"  # WHY 2x request: handles burst without OOM kill
              cpu: "500m"

          # ── Environment — no secrets here (use secretRef) ────────────────
          env:
            - name: ASPNETCORE_ENVIRONMENT
              value: production
            - name: KeyVault__Name
              value: my-keyvault-prod
            # Managed identity credential is picked up automatically via DefaultAzureCredential
            # No secret needed — pod identity or workload identity handles auth to Key Vault

          # ── Probes — required for AKS to know pod health ─────────────────
          # Liveness: is the process alive? Restart if failing.
          livenessProbe:
            httpGet:
              path: /health/live
              port: 80
            initialDelaySeconds: 10   # WHY 10s: give app time to start before checking
            periodSeconds: 15
            failureThreshold: 3       # restart after 3 consecutive failures

          # Readiness: can this pod serve traffic? Remove from load balancer if failing.
          # WHY separate from liveness: warming up (DB migrations, cache load) takes time.
          #   A pod can be alive but not ready. Readiness controls traffic; liveness controls restart.
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
            failureThreshold: 3

          # ── Graceful shutdown ─────────────────────────────────────────────
          lifecycle:
            preStop:
              exec:
                # WHY sleep 5: gives the load balancer time to stop routing traffic
                #   before the app stops accepting connections (prevents 502 errors)
                command: ["/bin/sh", "-c", "sleep 5"]

      terminationGracePeriodSeconds: 30   # WHY 30: allows in-flight requests to complete
```

---

## Service and Ingress

```yaml
# ── service.yaml ──────────────────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: orders-api-svc
  namespace: production
spec:
  # WHY ClusterIP not LoadBalancer: traffic comes through Ingress, not directly.
  #   LoadBalancer creates a public Azure Load Balancer — expensive, uncontrolled exposure.
  type: ClusterIP
  selector:
    app: orders-api
  ports:
    - port: 80
      targetPort: 80

---
# ── ingress.yaml ──────────────────────────────────────────────────────────────
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: orders-api-ingress
  namespace: production
  annotations:
    # WHY nginx not azure: NGINX gives per-path routing, rewrite, rate limiting
    kubernetes.io/ingress.class: nginx
    # TLS termination at ingress — internal traffic is HTTP (within cluster)
    cert-manager.io/cluster-issuer: letsencrypt-prod
    # WHY rate limit at ingress: blocks abusive clients before reaching the app
    nginx.ingress.kubernetes.io/limit-rps: "100"
spec:
  tls:
    - hosts: [api.myapp.com]
      secretName: orders-api-tls
  rules:
    - host: api.myapp.com
      http:
        paths:
          - path: /api/v1/orders
            pathType: Prefix
            backend:
              service:
                name: orders-api-svc
                port:
                  number: 80
```

---

## Horizontal Pod Autoscaler

```yaml
# WHY HPA: scale out under load, scale in when idle — pay only for what you use.
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: orders-api-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: orders-api
  minReplicas: 3    # WHY 3: one per zone minimum — never fewer for HA
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          # WHY 70 not 100: scaling takes ~60s. If you wait for 100% CPU you're already
          #   degraded. 70% gives headroom to scale before saturation.
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleDown:
      # WHY 5min stabilizationWindow: prevents flapping (scale up → cool down → scale down → repeat)
      stabilizationWindowSeconds: 300
      policies:
        - type: Pods
          value: 1          # remove max 1 pod per 60s when scaling down
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0   # WHY 0: react immediately when scaling up (traffic spike)
      policies:
        - type: Pods
          value: 4          # add up to 4 pods per 60s when scaling up
          periodSeconds: 60
```

---

## ConfigMap and Secret Pattern

```yaml
# ── configmap.yaml — non-sensitive configuration ──────────────────────────────
apiVersion: v1
kind: ConfigMap
metadata:
  name: orders-api-config
  namespace: production
data:
  # WHY ConfigMap: version-controlled, auditable, non-secret config
  ASPNETCORE_ENVIRONMENT: "production"
  ServiceBus__QueueName: "orders-prod"
  FeatureFlags__NewCheckout: "true"

---
# ── NEVER store real secrets in a Secret manifest committed to git ────────────
# WHY: base64 is NOT encryption. Anyone with kubectl access can decode it.
# Use Azure Key Vault CSI Driver instead:

# secretproviderclass.yaml — pull secrets from Key Vault into pod
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: orders-api-secrets
  namespace: production
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: "<workload-identity-client-id>"   # WHY workload identity: no secrets to manage
    keyvaultName: my-keyvault-prod
    tenantId: "<tenant-id>"
    objects: |
      array:
        - |
          objectName: ConnectionStrings--Database
          objectType: secret
        - |
          objectName: ServiceBus--ConnectionString
          objectType: secret
  secretObjects:
    - secretName: orders-api-secrets
      type: Opaque
      data:
        - objectName: ConnectionStrings--Database
          key: database-connection
```
