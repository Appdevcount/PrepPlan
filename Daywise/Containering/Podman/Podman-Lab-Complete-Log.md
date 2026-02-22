# Podman Lab — Complete Execution Log
### .NET SimpleApi · Offline Concepts · Podman 5.7.1

> **Date:** 2026-02-22
> **Tool:** Podman 5.7.1 (replaces Docker — all `docker` commands become `podman`)
> **Project:** `SimpleApi` — ASP.NET Core 10 minimal API with 4 endpoints
> **Source guide:** `tester.txt` — Docker for .NET Developers
> **Azure sections SKIPPED:** Lines 2029–4667 (`Azure Deployment`, `Azure Functions`) — require Azure subscription
> **CI/CD section:** GitHub Actions YAML documented as reference only — no live CI runner

---

## Table of Contents

1. [Project Structure Overview](#1-project-structure-overview)
2. [Section Coverage Map](#2-section-coverage-map)
3. [Podman Fundamentals — Images](#3-podman-fundamentals--images)
4. [Podman Fundamentals — Containers](#4-podman-fundamentals--containers)
5. [Testing the API Endpoints](#5-testing-the-api-endpoints)
6. [Container Inspection & Debugging](#6-container-inspection--debugging)
7. [Environment Variables](#7-environment-variables)
8. [Data Management — Volumes](#8-data-management--volumes)
9. [Networking](#9-networking)
10. [Multi-Stage Build — Fresh Rebuild](#10-multi-stage-build--fresh-rebuild)
11. [Image Lifecycle — Pruning](#11-image-lifecycle--pruning)
12. [Security — Resource Limits & Read-Only Filesystem](#12-security--resource-limits--read-only-filesystem)
13. [Compose — podman-compose](#13-compose--podman-compose)
14. [Volume Backup & Restore](#14-volume-backup--restore)
15. [Final Environment State](#15-final-environment-state)
16. [Skipped — Azure Sections](#16-skipped--azure-sections)
17. [CI/CD Reference — GitHub Actions YAML](#17-cicd-reference--github-actions-yaml)
18. [Key Takeaways — Docker → Podman Translation](#18-key-takeaways--docker--podman-translation)
19. [Common Pitfalls Found During This Lab](#19-common-pitfalls-found-during-this-lab)

---

## 1. Project Structure Overview

```
d:\Containering\Podman\
├── SimpleApi\
│   ├── Dockerfile              ← Multi-stage build (SDK → runtime)
│   ├── docker-compose.yml      ← Single-service compose definition
│   ├── .dockerignore           ← Excludes bin/, obj/, IDE files from context
│   ├── Program.cs              ← ASP.NET Core 10 minimal API
│   ├── SimpleApi.csproj        ← net10.0, OpenAPI package
│   └── appsettings.json
└── tester.txt                  ← Full Docker for .NET developer guide
```

### `Dockerfile` (multi-stage) — already in project

```dockerfile
# Stage 1: Build — uses heavy SDK image (894 MB) to compile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy only .csproj first — key caching trick:
# If only source code changes, this layer is reused (NuGet restore skipped)
COPY SimpleApi.csproj .
RUN dotnet restore

# Now copy everything else, then publish
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# Stage 2: Runtime — lightweight image (234 MB), no SDK/compiler
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Override default port (ASP.NET Core 8+ containers default to 8080)
ENV ASPNETCORE_HTTP_PORTS=80

COPY --from=build /app/publish .

EXPOSE 80
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
```

**Why multi-stage?**
- Build image: ~900 MB (SDK + compiler + all build tools)
- Runtime image: ~235 MB (runtime only — no compiler, no source code)
- Security: build tools never end up in production image
- Speed: NuGet restore layer is cached when only `.cs` files change

### `Program.cs` — API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/health` | GET | Returns `{status, timestamp}` — useful for container health probes |
| `/hello/{name?}` | GET | Returns greeting; name is optional |
| `/info` | GET | Returns machineName, osVersion, dotnetVersion, environment |
| `/weatherforecast` | GET | Returns 5-day mock forecast |

---

## 2. Section Coverage Map

| Section (from tester.txt) | Lines | Status | Notes |
|---|---|---|---|
| Introduction | 26–46 | ✅ Conceptual | Covered in overview |
| Docker Fundamentals | 47–134 | ✅ Executed | All commands run with `podman` |
| Docker for .NET - Getting Started | 135–181 | ✅ Executed | Build + run |
| Dockerfile Best Practices | 182–690 | ✅ Executed | Multi-stage build |
| Multi-Stage Builds | 691–913 | ✅ Executed | `--no-cache` rebuild |
| Docker Compose | 914–1198 | ✅ Executed | `podman-compose` |
| Container Orchestration | 1199–1481 | ⚠️ Reference | Requires Kubernetes cluster |
| Development Workflows | 1482–1693 | ✅ Conceptual | `--env`, volume mounts |
| CI/CD Integration | 1694–2028 | 📄 Reference | GitHub Actions YAML only |
| **Azure Deployment** | **2029–3794** | **⛔ SKIPPED** | **Requires Azure subscription** |
| **Azure Functions** | **3795–4667** | **⛔ SKIPPED** | **Requires Azure subscription** |
| Security Best Practices | 4668–5560 | ✅ Executed | Resource limits, read-only |
| Performance Optimization | 5561–5714 | ✅ Executed | Layer caching, `--no-cache` |
| Networking in Docker | 5715–5835 | ✅ Executed | Custom bridge network |
| Data Management & Volumes | 5836–5956 | ✅ Executed | Named volumes, cp, backup |
| Debugging & Troubleshooting | 5957–6278 | ✅ Executed | logs, exec, inspect, stats |
| Production Deployment | 6279–6536 | ✅ Executed | Resource limits |
| Real-World Scenarios | 6537–6908 | ✅ Executed | Multi-container via compose |
| Common Pitfalls & Solutions | 6909–7090 | ✅ Documented | Port mismatch found + fixed |

---

## 3. Podman Fundamentals — Images

### Why: Images are the immutable blueprints. Every container is a running instance of one.

**Command: List all local images**

```bash
podman images
```

**Output:**
```
REPOSITORY                       TAG         IMAGE ID      CREATED         SIZE
localhost/simpleapi              latest      8a461bbc6654  29 minutes ago  235 MB
<none>                           <none>      383c084ab381  55 minutes ago  900 MB   ← dangling (build stage)
<none>                           <none>      239bde6ec370  13 hours ago    900 MB   ← dangling (old build stage)
mcr.microsoft.com/dotnet/sdk     10.0        2ccbbe6cf279  11 days ago     894 MB
mcr.microsoft.com/dotnet/aspnet  10.0        0b6ec319bfb2  11 days ago     234 MB
quay.io/podman/hello             v1.0        5dd467fce50b  21 months ago   787 kB
quay.io/podman/hello             latest      5dd467fce50b  21 months ago   787 kB
```

**Observations:**
- `simpleapi:latest` (235 MB) = the runtime image we run in production
- `<none>` rows are **dangling images** — leftover intermediate build-stage layers. They waste disk space. Cleaned up in step 11.
- `dotnet/sdk:10.0` (894 MB) vs `dotnet/aspnet:10.0` (234 MB) — multi-stage build saves ~660 MB per image

---

**Command: Tag an image with a version**

```bash
podman tag localhost/simpleapi:latest localhost/simpleapi:v1.0.0
```

**Why:** `latest` is a moving target. Version tags (`v1.0.0`) let you roll back to exact builds. In production, always tag with a version AND `latest`.

**Output after tagging:**
```
REPOSITORY               TAG      IMAGE ID      SIZE
localhost/simpleapi      v1.0.0   8a461bbc6654  235 MB   ← new tag
localhost/simpleapi      latest   8a461bbc6654  235 MB   ← same ID — no extra disk space
```

Both tags point to the same image ID — tagging is just a label, no data is duplicated.

---

**Command: Inspect image metadata**

```bash
podman image inspect localhost/simpleapi:latest \
  --format "ID: {{.Id}}\nCreated: {{.Created}}\nSize: {{.Size}}\nArchitecture: {{.Architecture}}\nOS: {{.Os}}\nLayers: {{len .RootFS.Layers}}"
```

**Output:**
```
ID: 8a461bbc66547b99adf13bc1dbf35c334d796e57ebddc2cb2c62ecfc984c3499
Created: 2026-02-22 04:45:38.323742819 +0000 UTC
Size: 234829492
Architecture: amd64
OS: linux
Layers: 7
```

**Why:** The image runs Linux (`linux/amd64`) even though we built it on Windows. Podman runs a Linux VM (podman machine) under the hood. The 7 layers correspond to the Dockerfile instructions in stage 2.

---

**Command: Show image layer history**

```bash
podman history localhost/simpleapi:latest
```

**Output:**
```
ID            CREATED         CREATED BY                                     SIZE
02a09d9841a7  29 minutes ago  ENTRYPOINT ["dotnet", "SimpleApi.dll"]         0B
<missing>     29 minutes ago  EXPOSE 80                                       0B
<missing>     29 minutes ago  COPY dir:eb34e538... (app files)               824kB    ← our app
0b6ec319bfb2  29 minutes ago  ENV ASPNETCORE_HTTP_PORTS=80                   0B
<missing>     29 minutes ago  WORKDIR /app                                    0B
<missing>     11 days ago     COPY /dotnet /usr/share/dotnet (runtime)       27.2MB   ← from base image
<missing>     11 days ago     RUN apt-get update && ... (Ubuntu packages)    43.3MB   ← from base image
<missing>     11 days ago     ADD file:... (Ubuntu base layer)               80.6MB   ← OS base
```

**Why layers matter:** Each layer is cached. Only the layers that CHANGE need to be rebuilt. Our application layer (824kB) rebuilds on code changes, but the base OS (80.6MB) and runtime (27.2MB + 43.3MB) layers are always reused from cache.

---

## 4. Podman Fundamentals — Containers

### Why: Containers are isolated running processes. Multiple containers can run from the same image.

**Pre-condition: Stop and remove any previous container to start clean**

```bash
podman stop simpleapicontainer
podman rm simpleapicontainer
```

**Output:**
```
simpleapicontainer
simpleapicontainer
```

---

**Command: Run a container in detached mode**

```bash
podman run -d -p 8080:80 --name simpleapi-c1 localhost/simpleapi:latest
```

| Flag | Meaning |
|---|---|
| `-d` | Detached — run in background, return container ID |
| `-p 8080:80` | Port mapping: host port 8080 → container port 80 |
| `--name simpleapi-c1` | Human-readable name for the container |
| `localhost/simpleapi:latest` | Image to run |

**Output:**
```
dc375c7a6462622bbeb3c648183ed70f15894e153075bdbdf3b0873cf1de8e1d
```
(64-character container ID)

---

**Command: List running containers**

```bash
podman ps
```

**Output:**
```
CONTAINER ID  IMAGE                       COMMAND     CREATED                 STATUS                 PORTS                 NAMES
dc375c7a6462  localhost/simpleapi:latest              Less than a second ago  Up Less than a second  0.0.0.0:8080->80/tcp  simpleapi-c1
```

**Reading the output:**
- `CONTAINER ID`: First 12 chars of the full 64-char ID
- `0.0.0.0:8080->80/tcp`: Host all-interfaces port 8080 forwarded to container port 80
- Status `Up`: Container process is running

---

**Command: List ALL containers (including stopped)**

```bash
podman ps -a
```

**Why:** `podman ps` only shows running containers. `-a` shows stopped, exited, created states too. Essential for debugging "why isn't my container running".

---

## 5. Testing the API Endpoints

### Why: Validates the container is working correctly and can receive HTTP traffic.

**Health check endpoint**

```bash
# ── What is "python3 -m json.tool"? ──────────────────────────────────────────
# python3       → the Python interpreter, used here purely as a command-line utility
#                 (nothing to do with your .NET app — Python is a separate tool on the machine)
# -m            → "run a module as a script" flag
#                 Instead of running a .py file, -m tells Python to find a named module
#                 in its standard library and execute it directly from the command line
# json.tool     → a built-in Python module (no install required — ships with Python)
#                 It reads JSON text from stdin (piped in via |) and prints it
#                 indented and human-readable
#
# Without it:   curl returns a compact one-liner → {"status":"healthy","timestamp":"..."}
# With it:      output is formatted as shown below — much easier to read while learning
# ─────────────────────────────────────────────────────────────────────────────
curl.exe -s http://localhost:8080/health | python3 -m json.tool
```

**Output:**
```json
{
    "status": "healthy",
    "timestamp": "2026-02-22T05:16:28.1439588Z"
}
```

**Why this matters:** In production, orchestrators (Kubernetes, Docker Swarm) use health check endpoints to decide if a container is ready to receive traffic. If `/health` returns non-2xx, the container is restarted or removed from load balancer rotation.

---

**Hello endpoint with parameter**

```bash
# python3 -m json.tool → same as above; formats the raw JSON response into readable indented output
curl http://localhost:8080/hello/Podman | python3 -m json.tool
```

**Output:**
```json
{
    "message": "Hello, Podman!",
    "from": "SimpleApi"
}
```

---

**Info endpoint — reveals container environment**

```bash
# python3 -m json.tool → same as above; formats the raw JSON response into readable indented output
curl http://localhost:8080/info | python3 -m json.tool
```

**Output:**
```json
{
    "machineName": "dc375c7a6462",
    "osVersion": "Unix 6.6.87.2",
    "dotnetVersion": "10.0.3",
    "environment": "Production"
}
```

**Key observations:**
- `machineName` is the **container ID** (not the Windows host name). Each container has its own hostname = its container ID
- `osVersion` is `Unix 6.6.87.2` — Linux kernel in the Podman VM, not Windows 10
- `environment` is `Production` because we didn't set `ASPNETCORE_ENVIRONMENT`

---

**Weather forecast endpoint**

```bash
# python3 -m json.tool → same as above; formats the raw JSON array response into readable indented output
curl http://localhost:8080/weatherforecast | python3 -m json.tool
```

**Output:**
```json
[
    {"date": "2026-02-23", "temperatureC": 43, "summary": "Balmy", "temperatureF": 109},
    {"date": "2026-02-24", "temperatureC": 13, "summary": "Hot",   "temperatureF": 55},
    {"date": "2026-02-25", "temperatureC": -10,"summary": "Mild",  "temperatureF": 15},
    {"date": "2026-02-26", "temperatureC": 54, "summary": "Balmy", "temperatureF": 129},
    {"date": "2026-02-27", "temperatureC": 27, "summary": "Hot",   "temperatureF": 80}
]
```

---

## 6. Container Inspection & Debugging

### Why: When things go wrong, these commands are your primary diagnostic toolkit.

**View container logs**

```bash
podman logs simpleapi-c1
```

**Output:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: /app
```

**Why:** The `::` in `http://[::]:80` means the app listens on all network interfaces (IPv4 + IPv6) inside the container. This is correct for a container — it must listen on all interfaces so Podman's port mapping can reach it.

Useful log variants:
```bash
podman logs -f simpleapi-c1          # Follow (stream) logs in real time
podman logs --tail 100 simpleapi-c1  # Only last 100 lines
podman logs --timestamps simpleapi-c1 # Include timestamps
```

---

**Execute commands inside a running container**

```bash
# Check which user is running the process
podman exec simpleapi-c1 whoami
```

**Output:** `root`

> ⚠️ **Security note:** Running as `root` inside the container is a risk. If an attacker escapes the container, they have root on the container filesystem. Best practice: create a non-root user in the Dockerfile and use `USER appuser`. The current `Dockerfile` doesn't do this — it's a known improvement area.

```bash
# Check the OS inside the container
podman exec simpleapi-c1 sh -c "cat /etc/os-release"
```

**Output:**
```
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
...
```

The ASP.NET runtime image is based on Ubuntu 24.04. This is why the image is ~234 MB.

```bash
# List application files published into the container
podman exec simpleapi-c1 sh -c "ls /app"
```

**Output:**
```
Microsoft.AspNetCore.OpenApi.dll
Microsoft.OpenApi.dll
SimpleApi
SimpleApi.deps.json
SimpleApi.dll           ← the entry point DLL
SimpleApi.pdb           ← debug symbols
SimpleApi.runtimeconfig.json
appsettings.Development.json
appsettings.json
web.config
```

**Why:** Only published output is here — no source `.cs` files, no `.csproj`, no NuGet packages. This is the multi-stage build benefit. The container image contains only what's needed to run.

---

**Inspect container details**

```bash
podman inspect simpleapi-c1 \
  --format "Name: {{.Name}}\nImage: {{.ImageName}}\nStatus: {{.State.Status}}\nIP: {{.NetworkSettings.IPAddress}}\nPorts: {{.HostConfig.PortBindings}}\nPID: {{.State.Pid}}"
```

**Output:**
```
Name: simpleapi-c1
Image: localhost/simpleapi:latest
Status: running
IP: 10.88.0.9
Ports: map[80/tcp:[{0.0.0.0 8080}]]
PID: 4445
```

**Why:** `inspect` gives the full JSON of everything about a container. The `--format` uses Go templates to extract specific fields. Useful in scripts for automation.

---

**Container resource usage**

```bash
podman stats simpleapi-c1 --no-stream
```

**Output:**
```
ID            NAME          CPU %   MEM USAGE / LIMIT    MEM %   NET IO              PIDS
dc375c7a6462  simpleapi-c1  0.98%   24.96MB / 4.038GB    0.62%   3.829kB / 3.246kB   19
```

**Reading the output:**
- CPU: 0.98% — nearly idle (no active requests)
- Memory: 24.96MB used of 4.038GB host RAM limit (no container limit set yet)
- 19 threads — ASP.NET Core thread pool at minimum
- `--no-stream`: print once and exit (without this flag, it updates like `top`)

---

**Copy file from container to host**

```bash
podman cp simpleapi-c1:/app/appsettings.json ./appsettings-from-container.json
cat ./appsettings-from-container.json
```

**Output:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Why:** `podman cp` works like `scp` but for containers. Useful for extracting config files, log files, or generated outputs. Reverse direction: `podman cp ./localfile.json containerName:/app/localfile.json`

---

## 7. Environment Variables

### Why: The primary way to configure containers without changing the image. 12-factor app principle.

**Run container with custom environment**

```bash
podman run -d -p 8090:80 \
  --name simpleapi-dev \
  -e ASPNETCORE_ENVIRONMENT=Development \
  -e DOTNET_RUNNING_IN_CONTAINER=true \
  localhost/simpleapi:latest
```

```bash
# python3 -m json.tool → formats the JSON response so we can clearly see the environment field changed
curl http://localhost:8090/info | python3 -m json.tool
```

**Output:**
```json
{
    "machineName": "2c9b898addfb",
    "osVersion": "Unix 6.6.87.2",
    "dotnetVersion": "10.0.3",
    "environment": "Development"
}
```

**Key difference:** `"environment": "Development"` — the same image now behaves as a dev environment just by passing `-e`. This is why we don't build separate images for dev/staging/production. One image, different config via environment variables.

**Common .NET container environment variables:**

| Variable | Purpose |
|---|---|
| `ASPNETCORE_ENVIRONMENT` | `Development`, `Staging`, `Production` |
| `ASPNETCORE_HTTP_PORTS` | Ports to listen on (e.g. `80` or `8080`) |
| `ASPNETCORE_URLS` | Full URLs (e.g. `http://+:80`) — alternative to above |
| `DOTNET_RUNNING_IN_CONTAINER` | Tells .NET to enable container-optimized behavior |
| `ConnectionStrings__DefaultConnection` | Override appsettings connection string |

Note: `__` (double underscore) is the environment variable equivalent of `:` in `appsettings.json` hierarchy.

---

## 8. Data Management — Volumes

### Why: Container filesystems are ephemeral. When a container is removed, all its data is gone. Volumes persist data outside the container lifecycle.

**Create a named volume**

```bash
podman volume create app-logs
podman volume ls
```

**Output:**
```
DRIVER      VOLUME NAME
local       app-logs
```

---

**Inspect volume details**

```bash
podman volume inspect app-logs
```

**Output:**
```json
[
    {
        "Name": "app-logs",
        "Driver": "local",
        "Mountpoint": "/var/lib/containers/storage/volumes/app-logs/_data",
        "CreatedAt": "2026-02-22T10:48:25.49394318+05:30",
        "Labels": {},
        "Scope": "local",
        "Options": {}
    }
]
```

**Why:** The volume lives at `/var/lib/containers/storage/volumes/app-logs/_data` — inside the Podman Linux VM. Even if the container is deleted and recreated, this path and its data persists.

---

**Run container with mounted volume**

```bash
podman run -d -p 8091:80 \
  --name simpleapi-vol \
  -v app-logs:/app/logs \
  localhost/simpleapi:latest
```

**Output:**
```
ae42dc207496...
```

`-v app-logs:/app/logs` mounts the `app-logs` volume at `/app/logs` inside the container. Anything the app writes to `/app/logs` is stored in the volume and survives container deletion.

**Volume types summary:**

| Type | Syntax | Use case |
|---|---|---|
| Named volume | `-v myvolume:/app/data` | Databases, persistent state |
| Bind mount | `-v /host/path:/app/data` | Development (live code reload) |
| tmpfs | `--tmpfs /app/temp:rw` | Temporary in-memory scratch space |

---

**Volume Backup**

```bash
podman run --rm \
  -v app-logs:/data \
  -v "d:/Containering/Podman":/backup \
  mcr.microsoft.com/dotnet/aspnet:10.0 \
  sh -c "cd /data && tar czf /backup/app-logs-backup.tar.gz . && echo Backup done"
```

**Output:**
```
Backup done
```

**How it works:**
1. `--rm` — remove this helper container after it exits
2. `-v app-logs:/data` — mount the volume to read data from
3. `-v "d:/Containering/Podman":/backup` — mount host folder for output
4. `tar czf` — compress and archive the volume contents to the backup folder
5. No long-running container is left — backup is a one-shot operation

**Verify backup created on host:**
```bash
ls -lh d:/Containering/Podman/app-logs-backup.tar.gz
```
```
-rw-r--r--  105 Feb 22 10:52 app-logs-backup.tar.gz
```

**Restore command (for reference):**
```bash
podman run --rm \
  -v app-logs:/data \
  -v "d:/Containering/Podman":/backup \
  mcr.microsoft.com/dotnet/aspnet:10.0 \
  sh -c "tar xzf /backup/app-logs-backup.tar.gz -C /data"
```

---

## 9. Networking

### Why: Containers need to talk to each other (API → Database → Cache). Custom networks provide isolation and DNS-based service discovery.

**List all networks**

```bash
podman network ls
```

**Output:**
```
NETWORK ID    NAME        DRIVER
986067b0de5b  mynetwork   bridge
2f259bab93aa  podman      bridge
```

`podman` is the default network. All containers without `--network` specified join this.

---

**Create a custom bridge network with subnet**

```bash
podman network create \
  --driver bridge \
  --subnet 172.25.0.0/16 \
  --gateway 172.25.0.1 \
  api-backend
```

**Output:** `api-backend`

**Why define a subnet?**
- Predictable IP ranges for firewall rules
- Isolate services: `api-backend` containers can't reach `api-frontend` containers
- `dns_enabled: true` (shown in inspect below) means containers find each other by **name**, not IP

---

**Inspect the new network**

```bash
podman network inspect api-backend
```

**Output:**
```json
{
    "name": "api-backend",
    "driver": "bridge",
    "network_interface": "podman2",
    "subnets": [{"subnet": "172.25.0.0/16", "gateway": "172.25.0.1"}],
    "ipv6_enabled": false,
    "internal": false,
    "dns_enabled": true,
    "containers": {}
}
```

`"dns_enabled": true` — critical for microservices. Containers on the same network can reach each other by container name (e.g., `http://database:5432`) instead of IP addresses.

---

**Connect a running container to the network**

```bash
podman network connect api-backend simpleapi-c1
```

**Verify the container now has a second IP:**
```bash
# podman inspect --format "{{json ...}}"  → outputs the Networks field as raw compact JSON
# | python3 -m json.tool                  → receives that raw JSON via pipe (stdin)
#                                           and prints it indented so the IP addresses are easy to read
podman inspect simpleapi-c1 --format "{{json .NetworkSettings.Networks}}" | python3 -m json.tool
```

**Output (abbreviated):**
```json
{
    "api-backend": {
        "Gateway": "172.25.0.1",
        "IPAddress": "172.25.0.2",
        "MacAddress": "d6:ce:c4:30:57:52"
    },
    "podman": {
        "IPAddress": "10.88.0.9"
    }
}
```

The container now has **two network interfaces**: one on the default `podman` network (10.88.0.9) and one on `api-backend` (172.25.0.2). This is how you give API containers access to both frontend and backend networks.

---

**Network architecture pattern (from tester.txt)**

```
 Internet
     │
 [nginx]  ── frontend network (172.28.0.0/16)
     │
 [api]    ── frontend + backend networks
     │
 [database] ── backend network (172.29.0.0/16, internal=true)
```

`internal: true` on a network means no external access — database is completely isolated from the internet.

---

## 10. Multi-Stage Build — Fresh Rebuild

### Why: Shows each build stage clearly, validates layer caching benefits, and demonstrates `--no-cache` for a completely fresh build.

**Command: Build with `--no-cache` flag**

```bash
cd "d:/Containering/Podman/SimpleApi"
podman build --no-cache -t localhost/simpleapi:fresh .
```

**Full build output:**
```
[1/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
[1/2] STEP 2/6: WORKDIR /src
--> 597ecc8d0c23
[1/2] STEP 3/6: COPY SimpleApi.csproj .
--> d4b47aa6b6ac
[1/2] STEP 4/6: RUN dotnet restore
  Determining projects to restore...
  Restored /src/SimpleApi.csproj (in 3.65 sec).       ← NuGet packages downloaded
--> 01473452c1cb
[1/2] STEP 5/6: COPY . .
--> d467de03e0e4
[1/2] STEP 6/6: RUN dotnet publish -c Release -o /app/publish --no-restore
  SimpleApi -> /src/bin/Release/net10.0/SimpleApi.dll
  SimpleApi -> /app/publish/
--> 8419ec2c092e

[2/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
[2/2] STEP 2/6: WORKDIR /app
--> 2993688c6a9d
[2/2] STEP 3/6: ENV ASPNETCORE_HTTP_PORTS=80
--> 881f0a36ce98
[2/2] STEP 4/6: COPY --from=build /app/publish .
--> 9a356b05513c                                       ← copies only published output
[2/2] STEP 5/6: EXPOSE 80
--> 4ed8d33dc3ca
[2/2] STEP 6/6: ENTRYPOINT ["dotnet", "SimpleApi.dll"]
[2/2] COMMIT localhost/simpleapi:fresh
--> fa769e71c5a4
Successfully tagged localhost/simpleapi:fresh
```

**Reading the build output:**
- `[1/2]` = Stage 1 (build), `[2/2]` = Stage 2 (runtime)
- `STEP N/6` = instruction number out of total instructions in this stage
- `Using cache` (seen in cached builds) = layer reused from previous build — no work done
- Without cache: all 12 steps run. With cache and only code changes: steps 1-3 of stage 1 are cached, steps 4-6 re-run

**Layer caching strategy — the key insight from tester.txt:**
```dockerfile
COPY SimpleApi.csproj .   # Layer A — only changes when .csproj changes
RUN dotnet restore         # Layer B — cached until Layer A changes (~4 sec saved)
COPY . .                   # Layer C — changes with every code edit
RUN dotnet publish ...     # Layer D — always rebuilds after code changes
```

On every code change: only Layers C and D rebuild. Layer B (NuGet restore, the slow one) stays cached.

---

## 11. Image Lifecycle — Pruning

### Why: Every `--no-cache` build or Dockerfile edit leaves behind dangling images (unnamed build stages). They waste disk space.

**Before pruning:**
```bash
podman images
```
```
REPOSITORY               TAG      IMAGE ID      SIZE
localhost/simpleapi      fresh    fa769e71c5a4  235 MB
<none>                   <none>   8419ec2c092e  900 MB   ← dangling (new build stage 1)
localhost/simpleapi      v1.0.0   8a461bbc6654  235 MB
localhost/simpleapi      latest   8a461bbc6654  235 MB
<none>                   <none>   383c084ab381  900 MB   ← dangling (old build stage)
<none>                   <none>   239bde6ec370  900 MB   ← dangling (even older)
mcr.microsoft.com/dotnet/sdk    10.0   2ccbbe6cf279  894 MB
mcr.microsoft.com/dotnet/aspnet 10.0   0b6ec319bfb2  234 MB
```

**Prune dangling images:**
```bash
podman image prune -f
```

**Output:**
```
239bde6ec370207003758dee4e8eff2f508c8f6ae5d5b5fe6856ceadf7b25bc3
383c084ab38161fa85c9ab597d87a7a93417b81320e368f6e7077b6cfdb2e464
8419ec2c092e11ecd0d1ec7441dc45af3b7442517ca7b52b1e6807c7af900594
... (intermediate layer hashes)
```

**After pruning:**
```
REPOSITORY               TAG      IMAGE ID      SIZE
localhost/simpleapi      fresh    fa769e71c5a4  235 MB
localhost/simpleapi      v1.0.0   8a461bbc6654  235 MB
localhost/simpleapi      latest   8a461bbc6654  235 MB
mcr.microsoft.com/dotnet/sdk    10.0   894 MB
mcr.microsoft.com/dotnet/aspnet 10.0   234 MB
quay.io/podman/hello    latest   787 kB
```

The three dangling 900MB images are gone. `-f` = force (no confirmation prompt).

**Remove a specific tag:**
```bash
podman rmi localhost/simpleapi:fresh
```
```
Untagged: localhost/simpleapi:fresh
```
Note: only the tag is removed. If another tag (like `latest`) still points to the same image ID, the image data stays. The image data is only deleted when ALL tags pointing to it are removed.

---

## 12. Security — Resource Limits & Read-Only Filesystem

### Why: Production containers should be isolated from the host, given only the resources they need, and prevented from writing to areas they shouldn't.

**Run with memory cap, CPU limit, and read-only root filesystem**

```bash
podman run -d -p 8092:80 \
  --name simpleapi-secure \
  --memory=256m \
  --cpus=0.5 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid \
  localhost/simpleapi:latest
```

| Flag | Value | Reason |
|---|---|---|
| `--memory=256m` | 256 MB | Hard cap — container OOM-killed if exceeded |
| `--cpus=0.5` | 0.5 vCPU | Throttled to half a CPU core |
| `--read-only` | — | Root filesystem is read-only — container can't write files (except explicitly allowed mounts) |
| `--tmpfs /tmp:rw,noexec,nosuid` | — | Provide a writable /tmp in memory; `noexec` prevents running binaries from /tmp; `nosuid` prevents setuid exploits |

**Test — still works despite restrictions:**
```bash
curl http://localhost:8092/health
```
```json
{"status":"healthy","timestamp":"2026-02-22T05:20:17.9896474Z"}
```

**Resource usage with limits applied:**
```bash
podman stats simpleapi-secure --no-stream
```
```
ID            NAME              CPU %   MEM USAGE / LIMIT    MEM %
71550573deec  simpleapi-secure  5.89%   20.26MB / 268.4MB   7.55%
```

**Note:** `268.4MB` limit shown = our `256m` plus a small overhead. The app uses only `20.26MB` — well within budget.

**Why `--read-only` matters:** If an attacker exploits the API, they cannot write malware to disk, cannot modify application binaries, and cannot create persistent backdoors. Combined with a non-root user, this dramatically limits blast radius.

**Security checklist (from tester.txt Section 12):**

| Practice | Status in our Dockerfile |
|---|---|
| Non-root user | ⚠️ Not yet — runs as root |
| Memory limit | ✅ Applied via `--memory` at runtime |
| CPU limit | ✅ Applied via `--cpus` at runtime |
| Read-only filesystem | ✅ Applied via `--read-only` at runtime |
| Minimal base image | ✅ Uses `aspnet:10.0` not `sdk:10.0` |
| No secrets in image | ✅ No hardcoded secrets |

---

## 13. Compose — podman-compose

### Why: Running multiple related services (API + database + cache) one-by-one with `podman run` is tedious. Compose defines the whole stack in one YAML file.

**Install podman-compose:**
```bash
# ── What is "python3 -m pip install podman-compose"? ─────────────────────────
# python3       → the Python interpreter
# -m pip        → runs pip as a module via -m flag
#                 pip = Python's package manager (like "dotnet add package" for .NET,
#                 or "npm install" for Node.js)
#                 Using "-m pip" instead of just "pip" guarantees we use the pip
#                 that belongs to this exact Python version — avoids version mismatch bugs
# install       → pip sub-command: download and install a package
# podman-compose → the package name on PyPI (Python Package Index — the public registry
#                 for Python packages, like NuGet for .NET)
#                 This installs the podman-compose tool, which is a Python program
#                 that reads docker-compose.yml files and runs them using podman
# ─────────────────────────────────────────────────────────────────────────────
python3 -m pip install podman-compose
```
```
Successfully installed podman-compose-1.5.0 python-dotenv-1.2.1
```

**Verify:**
```bash
# ── What is "python3 -m podman_compose"? ─────────────────────────────────────
# python3           → the Python interpreter
# -m podman_compose → runs the installed podman_compose package as a module
#                     (note underscore: the importable package name is podman_compose,
#                      but the CLI tool name is podman-compose with a dash)
#
# WHY use "-m podman_compose" instead of just "podman-compose"?
#   pip installs the podman-compose.exe binary into a Scripts/ folder.
#   That folder is NOT always on your system PATH (we saw the warning during install).
#   Using "python3 -m podman_compose" bypasses PATH entirely —
#   Python finds the installed package directly by its module name.
#   It ALWAYS works, regardless of PATH configuration.
#
# This is the equivalent of running "docker-compose" commands.
# ─────────────────────────────────────────────────────────────────────────────
python3 -m podman_compose --version
```
```
podman version 5.7.1
podman-compose version 1.5.0
```

---

**The `docker-compose.yml` (after port fix):**

```yaml
services:
  simpleapi:
    build: .
    container_name: simpleapi
    ports:
      - "5080:80"        # host:container
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
    restart: unless-stopped
```

> ⚠️ **Port mismatch fixed:** The original file had `5080:8080` but the Dockerfile sets `ASPNETCORE_HTTP_PORTS=80`, so the container listens on port 80, not 8080. Fixed to `5080:80`. See [Common Pitfalls](#19-common-pitfalls-found-during-this-lab).

---

**Command: Start the compose stack**

```bash
cd d:/Containering/Podman/SimpleApi
# python3 -m podman_compose → runs podman-compose via Python module (see explanation above)
# up                        → start all services defined in docker-compose.yml
#                             also builds images if they don't exist yet
# -d                        → detached mode: run in background, return the terminal prompt
python3 -m podman_compose up -d
```

**Output:**
```
[1/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
...
[2/2] STEP 6/6: ENTRYPOINT ["dotnet", "SimpleApi.dll"]
[2/2] COMMIT simpleapi_simpleapi
Successfully tagged localhost/simpleapi_simpleapi:latest
simpleapi
```

The compose image is tagged `simpleapi_simpleapi:latest` (project_service naming).

---

**Test compose-started container:**
```bash
curl http://localhost:5080/health
```
```json
{"status":"healthy","timestamp":"2026-02-22T05:22:20.7579057Z"}
```

---

**Command: View service status**
```bash
# ps → lists all containers managed by this compose project (same as "podman ps" but filtered to this stack)
python3 -m podman_compose ps
```
```
CONTAINER ID  IMAGE                              PORTS                 NAMES
09a64a0401d9  localhost/simpleapi_simpleapi:latest  0.0.0.0:5080->80/tcp  simpleapi
```

---

**Command: View service logs**
```bash
# logs → streams stdout/stderr from all containers in the compose stack
#         add a service name to filter: python3 -m podman_compose logs simpleapi
#         add -f to follow (live stream): python3 -m podman_compose logs -f
python3 -m podman_compose logs
```
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://[::]:80
info: Microsoft.Hosting.Lifetime[0]
      Application started.
```

---

**Command: Stop and remove compose stack**
```bash
# down → stops all running containers and removes them + the auto-created network
#         unlike "stop" (which only stops), "down" also removes containers
#         add -v to also remove named volumes: python3 -m podman_compose down -v
python3 -m podman_compose down
```
```
simpleapi
simpleapi
simpleapi_default
```

Removes container, removes the auto-created `simpleapi_default` network.

---

**Compose command reference (docker → podman):**

| Docker Compose | Podman Compose |
|---|---|
| `docker-compose up -d` | `python3 -m podman_compose up -d` |
| `docker-compose down` | `python3 -m podman_compose down` |
| `docker-compose logs -f` | `python3 -m podman_compose logs` |
| `docker-compose ps` | `python3 -m podman_compose ps` |
| `docker-compose build --no-cache` | `python3 -m podman_compose build --no-cache` |
| `docker-compose exec api bash` | `python3 -m podman_compose exec api bash` |

---

## 14. Volume Backup & Restore

### Already covered in Section 8. Summary:

```bash
# Backup
podman run --rm -v app-logs:/data -v "d:/Containering/Podman":/backup \
  mcr.microsoft.com/dotnet/aspnet:10.0 \
  sh -c "cd /data && tar czf /backup/app-logs-backup.tar.gz ."

# Restore
podman run --rm -v app-logs:/data -v "d:/Containering/Podman":/backup \
  mcr.microsoft.com/dotnet/aspnet:10.0 \
  sh -c "tar xzf /backup/app-logs-backup.tar.gz -C /data"

# Copy single file from container
podman cp simpleapi-c1:/app/appsettings.json ./appsettings-from-container.json

# Copy single file to container
podman cp ./config.json simpleapi-c1:/app/config.json
```

---

## 15. Final Environment State

After all lab exercises, the environment looks like this:

**Containers running:**
```
CONTAINER ID  IMAGE                     PORTS                 NAMES
dc375c7a6462  localhost/simpleapi:latest  0.0.0.0:8080->80/tcp  simpleapi-c1     ← base run
2c9b898addfb  localhost/simpleapi:latest  0.0.0.0:8090->80/tcp  simpleapi-dev    ← env vars demo
ae42dc207496  localhost/simpleapi:latest  0.0.0.0:8091->80/tcp  simpleapi-vol    ← volume mount
71550573deec  localhost/simpleapi:latest  0.0.0.0:8092->80/tcp  simpleapi-secure ← resource limits
```

**Volumes:**
```
DRIVER   VOLUME NAME
local    app-logs
```

**Networks:**
```
NETWORK ID    NAME         DRIVER
35e872b3c66e  api-backend  bridge    ← custom network with subnet
986067b0de5b  mynetwork    bridge    ← from previous session
2f259bab93aa  podman       bridge    ← default
```

**Images:**
```
REPOSITORY                         TAG       SIZE
localhost/simpleapi_simpleapi       latest    235 MB   ← compose-built
localhost/simpleapi                 v1.0.0    235 MB   ← tagged version
localhost/simpleapi                 latest    235 MB   ← main
mcr.microsoft.com/dotnet/sdk        10.0      894 MB   ← build base
mcr.microsoft.com/dotnet/aspnet     10.0      234 MB   ← runtime base
```

---

## 16. Skipped — Azure Sections

The following sections from `tester.txt` require an active Azure subscription and are **not covered in this offline lab**:

### Azure Deployment — ACR to App Services & Container Apps (Lines 2029–3794)
- Azure Container Registry (ACR) — push/pull images to Azure's private registry
- Azure App Service — deploy containers as managed web apps
- Azure Container Apps — serverless container platform

### Azure Functions with Docker (Lines 3795–4667)
- Packaging Azure Functions in containers
- Durable Functions in Docker
- Local testing with Azure Functions Core Tools

**When ready to practice Azure sections:**
1. You need an Azure subscription (free tier available at portal.azure.com)
2. Azure CLI (`az` command) must be installed
3. Run `az login` to authenticate
4. Create a resource group: `az group create --name rg-podman-lab --location eastus`

---

## 17. CI/CD Reference — GitHub Actions YAML

### Why documented but not executed: GitHub Actions requires a GitHub repository and a runner. No local execution is possible.

The `tester.txt` CI/CD section (lines 1694–2028) covers GitHub Actions workflows. Here is the pattern translated to use Podman:

```yaml
# .github/workflows/podman-build-deploy.yml
name: Podman Build and Push

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Podman
        run: |
          sudo apt-get update
          sudo apt-get install -y podman

      - name: Build image
        run: |
          podman build -t myregistry.io/simpleapi:${{ github.sha }} \
                       -t myregistry.io/simpleapi:latest \
                       ./SimpleApi

      - name: Run tests in container
        run: |
          podman run --rm localhost/simpleapi:latest \
            dotnet test --no-build

      - name: Push to registry
        run: |
          echo "${{ secrets.REGISTRY_PASSWORD }}" | \
            podman login myregistry.io -u ${{ secrets.REGISTRY_USERNAME }} --password-stdin
          podman push myregistry.io/simpleapi:${{ github.sha }}
          podman push myregistry.io/simpleapi:latest
```

**Key principles from tester.txt:**
- Never hardcode credentials in YAML — use `secrets.*`
- Tag with commit SHA for traceability + `latest` for convenience
- Build once, test in the built image, push same image
- Separate jobs for build, test, push using `needs:` for dependency

---

## 18. Key Takeaways — Docker → Podman Translation

Podman is a **drop-in replacement** for Docker. All commands are identical except:

| Docker | Podman | Notes |
|---|---|---|
| `docker build` | `podman build` | Identical |
| `docker run` | `podman run` | Identical |
| `docker images` | `podman images` | Identical |
| `docker ps` | `podman ps` | Identical |
| `docker exec` | `podman exec` | Identical |
| `docker logs` | `podman logs` | Identical |
| `docker inspect` | `podman inspect` | Identical |
| `docker volume` | `podman volume` | Identical |
| `docker network` | `podman network` | Identical |
| `docker stats` | `podman stats` | Identical |
| `docker cp` | `podman cp` | Identical |
| `docker-compose` | `python3 -m podman_compose` | Install via pip |
| `docker tag` | `podman tag` | Identical |
| `docker rmi` | `podman rmi` | Identical |
| `docker image prune` | `podman image prune` | Identical |

**Key architectural difference:**
- Docker: requires a background daemon (`dockerd`) running as root
- Podman: **daemonless** — each `podman` command is a self-contained process. On Windows, it uses a lightweight Linux VM (`podman machine`) but no persistent root daemon on the host OS.

---

## 19. Common Pitfalls Found During This Lab

### Pitfall 1: Port Mismatch in docker-compose.yml

**Problem found:**
```yaml
# WRONG — container doesn't listen on 8080
ports:
  - "5080:8080"
```

**Root cause:** The Dockerfile sets `ENV ASPNETCORE_HTTP_PORTS=80`, so the app listens on port 80. The compose file was mapping to port 8080 — nothing would respond there.

**Fix applied:**
```yaml
# CORRECT
ports:
  - "5080:80"
```

**Lesson:** Always match your compose port mapping to what the container actually listens on. Check with `podman logs` — it shows `Now listening on: http://[::]:80`.

---

### Pitfall 2: Running as Root

**Detected via:**
```bash
podman exec simpleapi-c1 whoami
# Output: root
```

**Problem:** The current Dockerfile has no `USER` directive. The .NET process runs as root inside the container. If exploited, an attacker has root on the container filesystem.

**Fix — add to Dockerfile:**
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Create non-root user
RUN groupadd -r appuser --gid=1000 \
    && useradd -r -g appuser --uid=1000 appuser

COPY --from=build --chown=appuser:appuser /app/publish .

# Switch to non-root before ENTRYPOINT
USER appuser

EXPOSE 80
ENTRYPOINT ["dotnet", "SimpleApi.dll"]
```

---

### Pitfall 3: No Resource Limits

**Problem:** Without `--memory` and `--cpus`, a misbehaving container can consume ALL host resources and crash other containers (or the host).

**Fix:** Always set limits in production:
```bash
podman run --memory=256m --cpus=0.5 ...
```
Or in compose:
```yaml
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
```

---

### Pitfall 4: exec with Windows-style paths

**Problem encountered:**
```bash
podman exec simpleapi-c1 cat /etc/os-release
# Error: cat: 'C:/Program Files/Git/etc/os-release': No such file or directory
```

**Cause:** Git Bash on Windows translates `/etc/os-release` to a Windows path. The container process receives the Windows path instead of the Unix path.

**Fix:** Wrap in `sh -c "..."` to prevent path translation:
```bash
podman exec simpleapi-c1 sh -c "cat /etc/os-release"
```

---

### Pitfall 5: Dangling Images Accumulate

**Problem:** Every `--no-cache` build leaves behind the unnamed build-stage image (`<none>` tag), which is ~900MB for the .NET SDK image.

**Fix:** Run after each build session:
```bash
podman image prune -f
```

Or during CI, use multi-stage builds correctly and always prune after push.

---

### Pitfall 6: `podman-compose` Not on PATH

**Problem:** After `pip install podman-compose`, the binary installed to a path not in `$PATH`.

**Observed warning:**
```
WARNING: The script podman-compose.exe is installed in
'C:\Users\User\AppData\Local\Python\pythoncore-3.14-64\Scripts'
which is not on PATH.
```

**Fix — use the module form instead of the binary:**
```bash
# Instead of: podman-compose up -d
#             ↑ this form requires the binary to be on PATH — may fail with "command not found"

# Use this instead:
python3 -m podman_compose up -d
# python3      → invoke the Python interpreter you already have
# -m           → find and run a module by name (no PATH lookup needed)
# podman_compose → the module name of the installed package
# This works because Python always knows where its own installed packages are,
# even when the Scripts/ bin folder is not on the system PATH.
```

---

*End of Lab Log*

---

> **Generated:** 2026-02-22
> **Environment:** Windows 10 Pro · Podman 5.7.1 · .NET 10.0.3 · ASP.NET Core 10
> **Azure sections:** Will be documented separately when Azure subscription is available
