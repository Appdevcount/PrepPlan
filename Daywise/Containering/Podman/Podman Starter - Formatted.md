# Podman Starter Guide for Windows

## Initial Setup Session

```powershell
# Check Podman version
PS E:\repos> podman --version
podman version 5.7.1

# First attempt to list containers fails - machine not running
PS E:\repos> podman ps
Cannot connect to Podman. Please verify your connection to the Linux system using `podman system connection list`, 
or try `podman machine init` and `podman machine start` to manage a new Linux VM
Error: unable to connect to Podman socket: failed to connect: dial tcp 127.0.0.1:54702: connectex: 
No connection could be made because the target machine actively refused it.

# Check existing connections
PS E:\repos> podman system connection list
Name                         URI                                                          Identity                                                      Default     ReadWrite
podman-machine-default       ssh://user@127.0.0.1:54702/run/user/1000/podman/podman.sock  C:\Users\User\.local\share\containers\podman\machine\machine  false       true
podman-machine-default-root  ssh://root@127.0.0.1:54702/run/podman/podman.sock            C:\Users\User\.local\share\containers\podman\machine\machine  true        true

# Start the Podman machine
PS E:\repos> podman machine start
Starting machine "podman-machine-default"
API forwarding listening on: npipe:////./pipe/docker_engine
Docker API clients default to this address. You do not need to set DOCKER_HOST.
time="2026-02-21T20:11:02+05:30" level=error msg="Process exited with status 2"
Machine "podman-machine-default" started successfully

# Verify it's working
PS E:\repos> podman ps
CONTAINER ID  IMAGE       COMMAND     CREATED     STATUS      PORTS       NAMES

# Attempt to init with custom resources fails - VM already exists
PS E:\repos> podman machine init --cpus=1 --memory=1024 --disk-size=10
Error: podman-machine-default: VM already exists
```

---

## Docker Engine vs Podman on Low-Resource Windows Machines

### Key Comparison

| Feature | Docker Engine | Podman |
|---------|---------------|--------|
| **Architecture** | Daemon-based (requires a background service) | Daemonless (runs containers directly via fork/exec) |
| **Memory Usage** | Higher baseline (~150 MB) | Lower baseline (~50 MB) |
| **CPU Overhead** | Slightly higher due to central daemon | Lower, since no daemon |
| **Startup Speed** | Faster startup (150–180 ms) | Slightly slower (180–220 ms) |
| **Rootless Mode** | Requires root/admin for daemon | Rootless by default, more secure |
| **Windows Integration** | Docker Desktop relies on WSL2 backend | Podman Desktop uses WSL2 but lighter footprint |
| **Compatibility** | Full Docker CLI + ecosystem support | Docker CLI compatible, supports `docker-compose.yml` via Podman Compose |
| **Kubernetes Support** | Via Docker + third-party tools | Native with `podman play kube` |

### Why This Matters for Low-Resource Windows Machines

- **Podman** is generally lighter on RAM and CPU, making it better suited for laptops or older PCs with limited resources
- **Docker Desktop** tends to consume more background resources because of its daemon and WSL2 integration, which can slow down other applications
- Podman's **daemonless architecture** means containers only consume resources when running, while Docker keeps its daemon active at all times
- If you're running multiple containers or doing heavy workloads, Docker may feel more stable, but for lightweight development or testing, Podman is more efficient

### Recommendation

- If your Windows machine has **limited RAM/CPU**, **Podman Desktop** is the better choice
- If you need **maximum compatibility with existing Docker workflows**, Docker Desktop is still more widely supported
- A practical approach: install **Podman Desktop**, test your workloads, and fall back to Docker only if you hit compatibility issues

---

## Understanding Connection Errors

That error is expected when running **Podman on Windows** because Podman doesn't run natively—it uses a lightweight Linux VM under the hood (via WSL2 or a virtual machine). Right now, your Podman client is trying to connect to a socket, but no Podman machine (VM) is running, so the connection is refused.

---

## Steps to Get Podman Working on Windows

### 1. Check Available Connections

```powershell
podman system connection list
```

This shows whether Podman knows about any Linux VM connections.

### 2. Initialize a Podman Machine (VM)

```powershell
podman machine init
```

- This sets up a lightweight Linux VM (using WSL2 or QEMU depending on your setup)
- You can pass options like `--cpus`, `--memory`, or `--disk-size` to optimize for low-resource machines

**Example:**

```powershell
podman machine init --cpus=1 --memory=1024 --disk-size=10
```

### 3. Start the Podman Machine

```powershell
podman machine start
```

This boots the VM and exposes the Podman socket.

### 4. Verify It's Running

```powershell
podman ps
```

Now it should connect successfully and show running containers (or none if fresh).

---

## Optimizing for Low-Resource Windows Machines

- Use **minimal CPU and memory allocation** when initializing:
  ```powershell
  podman machine init --cpus=1 --memory=1024 --disk-size=10
  ```
- Stop the VM when not in use:
  ```powershell
  podman machine stop
  ```
- Prefer **rootless containers** (default in Podman) to reduce overhead and improve security
- If you only need occasional container runs, Podman is lighter than Docker Desktop since it doesn't keep a heavy daemon running

---

## Understanding Connection List Output

When you run `podman system connection list`, you see two entries:

### 1. `podman-machine-default`

- **URI:** `ssh://user@127.0.0.1:54702/run/user/1000/podman/podman.sock`
- Connection for running Podman as a **non-root (regular user)** inside the Podman-managed Linux VM
- **Default = false** → It's available, but not the active/default connection

### 2. `podman-machine-default-root`

- **URI:** `ssh://root@127.0.0.1:54702/run/podman/podman.sock`
- Connection for running Podman as **root inside the VM**
- **Default = true** → This is currently the active/default connection

### Why You're Getting the Error

- The connections exist, but the **Podman machine (VM)** itself is not running
- That's why the socket at `127.0.0.1:54702` is refusing connections — nothing is listening there until you start the VM

### What You Need to Do

```powershell
# Start the Podman VM
podman machine start

# Verify it's running
podman ps
```

### Switch to Non-Root Connection (Optional)

To switch the default connection to the non-root one (lighter and safer):

```powershell
podman system connection default podman-machine-default
```

---

## Managing Existing Podman Machines

### If VM Already Exists

The error `VM already exists` means you've already initialized the default Podman machine once before. You don't need to run `podman machine init` again unless you want to delete and recreate it.

**Current setup:**
- A **default VM** (`podman-machine-default`) is already created
- Connections are registered (`user` and `root`)
- But the VM isn't running, so the socket is unavailable

### Next Steps

1. **Start the existing VM:**
   ```powershell
   podman machine start
   ```

2. **Check containers:**
   ```powershell
   podman ps
   ```

3. **Stop when not needed:**
   ```powershell
   podman machine stop
   ```

### Reconfiguring Resources

Since the VM already exists, you can't re-init with new CPU/memory/disk settings unless you delete it first:

```powershell
podman machine rm podman-machine-default
podman machine init --cpus=1 --memory=1024 --disk-size=10
podman machine start
```

⚠️ **Warning:** Removing the machine will delete any containers/images stored inside it.

---

## Quick Reference Commands

```powershell
# Machine management
podman machine list                  # List all machines
podman machine start                 # Start default machine
podman machine stop                  # Stop default machine
podman machine rm [name]             # Remove a machine
podman machine ssh                   # SSH into the machine

# Connection management
podman system connection list        # List all connections
podman system connection default [name]  # Set default connection

# Container operations
podman ps                            # List running containers
podman ps -a                         # List all containers
podman images                        # List images
podman run [image]                   # Run a container
podman stop [container]              # Stop a container
podman rm [container]                # Remove a container
```

---

## Session 2: Working with Images (Podman1.txt)

This session covers the core image lifecycle commands: listing, pulling, removing, and tagging.

### List Images

```powershell
PS E:\repos> podman images
REPOSITORY            TAG         IMAGE ID      CREATED        SIZE
quay.io/podman/hello  latest      5dd467fce50b  21 months ago  787 kB
```

Only the `podman/hello` test image exists at this point. No .NET images yet.

---

### Pull an Image

```powershell
PS E:\repos> podman pull mcr.microsoft.com/dotnet/aspnet:8.0
Getting image source signatures
Copying blob sha256:16a4ae3c252c395cc687beda642ff037708c4f6c9cb1bc867a51013d543d1d76
Copying blob sha256:dc989867784ead8b4cca8ae65779cea285c9082efb12bba858be89c6e6da57bc
Copying blob sha256:0d87adf8cbf99c86eb8603fd4f627087392e9e34b9dd7758a65dd7997f06340c
Copying blob sha256:4831516dd0cb86845f5f902cb9b9d25b5c853152c337eb57e4737a9b7e2a2eb9
Writing manifest to image destination
f2d3263032886bb7e11fded4a98d9738c65630f1435fdedc73f7a9db4cab7895
REPOSITORY                       TAG         IMAGE ID      CREATED        SIZE
mcr.microsoft.com/dotnet/aspnet  8.0         f2d326303288  11 days ago    221 MB
quay.io/podman/hello             latest      5dd467fce50b  21 months ago  787 kB
```

**What happened:**
- Podman pulled 4 layer blobs from Microsoft Container Registry
- Each `Copying blob sha256:...` line is one image layer being downloaded
- The image is 221 MB — this is the ASP.NET runtime-only image (not the full SDK)
- After pull, `podman images` shows the new image alongside the existing one

---

### Remove an Image

```powershell
PS E:\repos> podman rmi f2d326303288
Untagged: mcr.microsoft.com/dotnet/aspnet:8.0
Deleted: f2d3263032886bb7e11fded4a98d9738c65630f1435fdedc73f7a9db4cab7895

PS E:\repos> podman images
REPOSITORY            TAG         IMAGE ID      CREATED        SIZE
quay.io/podman/hello  latest      5dd467fce50b  21 months ago  787 kB
```

**What happened:**
- `Untagged` — the name/tag `aspnet:8.0` was removed first
- `Deleted` — then the actual image data layers were deleted from disk
- You can `rmi` by Image ID or by name. If multiple tags point to the same image, only the tag is removed until the last tag is gone.

---

### Tag an Image

```powershell
PS E:\repos> podman tag quay.io/podman/hello:latest quay.io/podman/hello:v1.0
PS E:\repos> podman images
REPOSITORY            TAG         IMAGE ID      CREATED        SIZE
quay.io/podman/hello  v1.0        5dd467fce50b  21 months ago  787 kB
quay.io/podman/hello  latest      5dd467fce50b  21 months ago  787 kB
```

**Key insight:** Both `v1.0` and `latest` show the **same IMAGE ID** (`5dd467fce50b`). Tagging doesn't copy data — it just adds a new label pointing to the same image layers. No extra disk space is used.

---

## Session 3: First Build of SimpleApi (Podman2.txt)

This session documents the very first build of the .NET 10 SimpleApi from scratch, followed by several attempts to run it with port mapping — including real mistakes and how they were diagnosed.

### First Build — Pulling All Layers

```powershell
PS D:\Containering\Podman\SimpleApi> podman build -t simpleapi:latest .
[1/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
Trying to pull mcr.microsoft.com/dotnet/sdk:10.0...
Getting image source signatures
Copying blob sha256:40be876054b9...
Copying blob sha256:f5adb485db00...
Copying blob sha256:01d7766a2e4a...
Copying blob sha256:2ec1f654a8d3...
Copying blob sha256:dd2509e04e54...
Copying blob sha256:53857c53a381...
Copying blob sha256:49353ec27a35...
Copying blob sha256:7d830fe8a493...
Copying blob sha256:96d68fe10fd2...
Copying blob sha256:198bb7165c4e...
Writing manifest to image destination
[1/2] STEP 2/6: WORKDIR /src
--> 1403811838c8
[1/2] STEP 3/6: COPY SimpleApi.csproj .
--> b4c7141f21c4
[1/2] STEP 4/6: RUN dotnet restore
  Determining projects to restore...
  Restored /src/SimpleApi.csproj (in 4.51 sec).
--> 002e5e8314fe
[1/2] STEP 5/6: COPY . .
--> 6a7013532c2f
[1/2] STEP 6/6: RUN dotnet publish -c Release -o /app/publish --no-restore
  SimpleApi -> /src/bin/Release/net10.0/SimpleApi.dll
  SimpleApi -> /app/publish/
--> 239bde6ec370
[2/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
Trying to pull mcr.microsoft.com/dotnet/aspnet:10.0...
...
Writing manifest to image destination
[2/2] STEP 4/6: COPY --from=build /app/publish .
--> 1543023697cc
[2/2] STEP 5/6: EXPOSE 8080
[2/2] STEP 6/6: ENTRYPOINT ["dotnet", "SimpleApi.dll"]
[2/2] COMMIT simpleapi:latest
6d8978269bda4ba09e1f9ccdbd98bd951ad9c15ed7567fcd096024307a707b43

PS D:\Containering\Podman\SimpleApi> podman images
REPOSITORY                       TAG         IMAGE ID      CREATED         SIZE
localhost/simpleapi              latest      6d8978269bda  27 seconds ago  235 MB
mcr.microsoft.com/dotnet/sdk     10.0        2ccbbe6cf279  10 days ago     894 MB
quay.io/podman/hello             v1.0        5dd467fce50b  21 months ago   787 kB
quay.io/podman/hello             latest      5dd467fce50b  21 months ago   787 kB
```

**What happened:**
- Stage 1 (`[1/2]`): Pulled the .NET SDK 10.0 image (10 blobs), restored NuGet packages, compiled and published the app
- Stage 2 (`[2/2]`): Pulled the lighter ASP.NET runtime image, copied only the published output
- Final image `simpleapi:latest` is 235 MB — the runtime image only, no SDK bloat

---

### Mistake 1: `-p` flag placed after the image name

```powershell
PS D:\Containering\Podman\SimpleApi> podman run -d --name simpleapicontainer localhost/simpleapi:latest -p 8080:80
0c4d8665498e3f55b0b470d45a27351a051d11ead26dc11209ff02d254a3cb3e

PS D:\Containering\Podman\SimpleApi> podman ps
CONTAINER ID  IMAGE                       COMMAND     CREATED         STATUS         PORTS       NAMES
0c4d8665498e  localhost/simpleapi:latest  -p 8080:80  11 seconds ago  Up 12 seconds  8080/tcp    simpleapicontainer
```

**What went wrong:** The `-p 8080:80` flag appears after the image name. Podman treats everything after the image name as the **container's startup command**, not as a Podman flag. The `PORTS` column shows `8080/tcp` — that's just the internal port documented in the image, not an actual host binding. Curl failed because no port was mapped on the host.

> ⚠️ **Rule:** All Podman flags (`-d`, `-p`, `--name`, `-e`, `-v`) must come **before** the image name.

```powershell
# WRONG — -p is treated as container argument
podman run -d --name myapp myimage:latest -p 8080:80

# CORRECT — -p is before the image name
podman run -d -p 8080:80 --name myapp myimage:latest
```

---

### Mistake 2: Cannot reuse a container name without removing first

```powershell
PS D:\Containering\Podman\SimpleApi> podman run -d -p 8080:80 --name simpleapicontainer localhost/simpleapi:latest
Error: creating container storage: the container name "simpleapicontainer" is already in use by
0c4d8665498e3f55b0b470d45a27351a051d11ead26dc11209ff02d254a3cb3e.
You have to remove that container to be able to reuse that name: that name is already in use
```

**Fix — stop then remove the old container before reusing the name:**

```powershell
PS D:\Containering\Podman\SimpleApi> podman stop 0c4d8665498e
PS D:\Containering\Podman\SimpleApi> podman rm 0c4d8665498e3f55b0b470d45a27351a051d11ead26dc11209ff02d254a3cb3e
0c4d8665498e...
```

> ⚠️ **Rule:** `podman rm` only works on stopped containers. A running container cannot be removed without `--force`. Also, `podman stop` does not automatically delete the container — you must `podman rm` separately.

---

### Mistake 3: Mapping to host port 80 — hijacked by Windows IIS

```powershell
PS D:\Containering\Podman\SimpleApi> podman run -d -p 80:80 --name simpleapicontainer localhost/simpleapi:latest
3884de58dcfe...

PS D:\Containering\Podman\SimpleApi> curl http://localhost:80/weatherforecast
curl : HTTP Error 404.0 - Not Found
...
Module   IIS Web Core
Physical Path   C:\inetpub\wwwroot\weatherforecast
```

**What went wrong:** Port 80 on Windows is already occupied by IIS (Internet Information Services). When you map host port 80, your `curl` request hits IIS, not Podman. IIS returns its own 404 because `/weatherforecast` doesn't exist on the Windows filesystem.

**The container was running fine — but Windows intercepted the request before it reached Podman's port forwarding.**

> ⚠️ **Rule on Windows:** Avoid host port 80 and 443 — they are typically held by IIS or other Windows services. Use `8080`, `8090`, or any high port instead.

---

### First Successful curl — Port 8080:8080 workaround

```powershell
PS D:\Containering\Podman\SimpleApi> podman run -d -p 8080:8080 --name simpleapicontainer localhost/simpleapi:latest
795b7352bde2...

PS D:\Containering\Podman\SimpleApi> curl http://localhost:8080/weatherforecast

StatusCode        : 200
StatusDescription : OK
Content           : [{"date":"2026-02-22","temperatureC":-14,"summary":"Freezing","temperatureF":7},
                    {"date":"2026-02-23","temperatureC":-5,"summary":"Bracing","temperatureF":24}...]
Server: Kestrel
```

**Why it worked this time:** The original Dockerfile had `ENV ASPNETCORE_HTTP_PORTS=8080` so the app listened on port 8080. Mapping `-p 8080:8080` (host 8080 → container 8080) matched correctly.

**But this is not clean** — `EXPOSE 80` in the Dockerfile was misleading. The next sessions fix this properly.

---

## Session 4: Port Mismatch Deep Dive and HTTPS Error (Podman3.txt)

This session shows the full investigation and fix for the ENV/EXPOSE/port-mapping mismatch, plus an important HTTPS certificate error that appears when HTTPS ports are enabled in containers without certificates.

### Machine Recovery After Restart

```powershell
PS D:\Containering\Podman> podman ps
Error: unable to connect to Podman socket: failed to connect: dial tcp 127.0.0.1:54702:
connectex: No connection could be made because the target machine actively refused it.

PS D:\Containering\Podman> podman machine start
Starting machine "podman-machine-default"
API forwarding listening on: npipe:////./pipe/docker_engine
time="2026-02-22T08:47:54+05:30" level=error msg="Process exited with status 2"
Machine "podman-machine-default" started successfully
```

The `level=error` line during startup is a known non-fatal warning on Windows — the Docker API proxy process exits with status 2 but the Podman machine itself starts fine. `podman ps` works normally after this.

---

### Build with Layer Cache — Much Faster

```powershell
PS D:\Containering\Podman\SimpleApi> podman build -t simpleapi:latest .
[1/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
[1/2] STEP 2/6: WORKDIR /src
--> Using cache 1403811838c8...
[1/2] STEP 3/6: COPY SimpleApi.csproj .
--> Using cache b4c7141f21c4...
[1/2] STEP 4/6: RUN dotnet restore
--> Using cache 002e5e8314fe...    ← NuGet restore skipped — .csproj unchanged
[1/2] STEP 5/6: COPY . .
--> Using cache 6a7013532c2f...
[1/2] STEP 6/6: RUN dotnet publish -c Release -o /app/publish --no-restore
--> Using cache 239bde6ec370...    ← publish skipped — source unchanged
```

**Every step shows `Using cache`** — because neither the `.csproj` nor the source code changed since the last build. The entire build completes in seconds instead of minutes.

---

### The ENV vs EXPOSE vs -p Mismatch Explained

The root cause of all port confusion across sessions:

| Setting | Value | Meaning |
|---|---|---|
| `ENV ASPNETCORE_HTTP_PORTS=8080` | 8080 | App listens on port **8080** inside container |
| `EXPOSE 80` | 80 | Documentation hint — says port 80 is used (wrong!) |
| `-p 8080:80` | host:container | Maps host 8080 → container port **80** (nothing there!) |

**Result:** The app runs on 8080 inside the container but the mapping goes to port 80. Connection closes unexpectedly.

```powershell
PS D:\Containering\Podman\SimpleApi> podman run -d -p 8080:80 --name simpleapicontainer localhost/simpleapi:latest
3aaa9a2f2ce6...

PS D:\Containering\Podman\SimpleApi> curl http://localhost:8080/weatherforecast
curl : The underlying connection was closed: The connection was closed unexpectedly.
```

**Diagnosis from container logs:**

```powershell
#- You set ENV ASPNETCORE_HTTP_PORTS=8080 → ASP.NET Core will listen on port 8080 inside the container
#- You EXPOSE 80 → This tells Podman/Docker that the container exposes port 80, but your app isn't
#  actually listening there.
#  Your app is listening on 8080 inside the container, but you mapped -p 8080:80.
#  That maps host port 8080 → container port 80. Since nothing is listening on port 80
#  inside the container, the connection closes unexpectedly.
```

**Fix: Change `ENV ASPNETCORE_HTTP_PORTS` to `80` in the Dockerfile** (or map `-p 8080:8080`).

---

### HTTPS Certificate Error — When Enabling HTTPS in Containers

During one build attempt with `ASPNETCORE_HTTPS_PORTS=443` and `EXPOSE 443`:

```powershell
PS D:\Containering\Podman\SimpleApi> podman logs simpleapicontainer
fail: Microsoft.Extensions.Hosting.Internal.Host[11]
      Hosting failed to start
      System.InvalidOperationException: Unable to configure HTTPS endpoint.
      No server certificate was specified, and the default developer certificate could not
      be found or is out of date.
      To generate a developer certificate run 'dotnet dev-certs https'.
```

**Why this happens:** ASP.NET Core's Kestrel web server requires an SSL certificate to bind to an HTTPS port. Inside a container, there is no developer certificate (`dotnet dev-certs https` generates one on the host, but it doesn't exist inside the container image).

**The right approach for containers:**
- Keep the container HTTP-only — set `ENV ASPNETCORE_HTTP_PORTS=80` only
- HTTPS termination is handled **outside** the container by a reverse proxy (nginx, Traefik, an API gateway, or a cloud load balancer)
- The container just serves plain HTTP internally — the proxy adds TLS externally

> ⚠️ **Never put ASPNETCORE_HTTPS_PORTS or EXPOSE 443 in a production container Dockerfile** unless you mount a real certificate.

---

### Architecture Check

```powershell
PS D:\Containering\Podman\SimpleApi> podman inspect localhost/simpleapi:latest --format "{{.Architecture}}"
amd64

PS D:\Containering\Podman\SimpleApi> podman info --format "{{.Host.Arch}}"
amd64
```

Both the image and the Podman host VM are `amd64` (x86-64). No cross-platform mismatch. If you build on Apple Silicon (arm64) for deployment to amd64 servers, you'd use `--platform linux/amd64` to force the correct architecture.

```powershell
# Build for a specific platform explicitly
podman build --platform linux/amd64 -t simpleapi:latest .
```

---

### Final Working Build and Successful curl

After fixing the Dockerfile to use `ENV ASPNETCORE_HTTP_PORTS=80` and removing the HTTPS lines:

```powershell
PS D:\Containering\Podman\SimpleApi> podman build --platform linux/amd64 -t simpleapi:latest .
[1/2] STEP 1/6: FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
...
[2/2] STEP 3/6: ENV ASPNETCORE_HTTP_PORTS=80     ← app now listens on 80
[2/2] STEP 4/6: COPY --from=build /app/publish .
[2/2] STEP 5/6: EXPOSE 80                        ← EXPOSE matches ENV
[2/2] STEP 6/6: ENTRYPOINT ["dotnet", "SimpleApi.dll"]
[2/2] COMMIT simpleapi:latest
Successfully tagged localhost/simpleapi:latest
8a461bbc66547b99adf13bc1dbf35c334d796e57ebddc2cb2c62ecfc984c3499

PS D:\Containering\Podman\SimpleApi> podman run -d -p 8080:80 --name simpleapicontainer localhost/simpleapi:latest
8cc4ea5052d5...

PS D:\Containering\Podman\SimpleApi> podman ps
CONTAINER ID  IMAGE                       PORTS                 NAMES
8cc4ea5052d5  localhost/simpleapi:latest  0.0.0.0:8080->80/tcp  simpleapicontainer

PS D:\Containering\Podman\SimpleApi> curl http://localhost:8080/weatherforecast

StatusCode        : 200
StatusDescription : OK
Content           : [{"date":"2026-02-23","temperatureC":17,"summary":"Chilly","temperatureF":62},
                    {"date":"2026-02-24","temperatureC":30,"summary":"Scorching","temperatureF":85}...]
Server            : Kestrel
```

**Final port mapping is now consistent:**
- `ENV ASPNETCORE_HTTP_PORTS=80` → app listens on container port 80
- `EXPOSE 80` → documents port 80
- `-p 8080:80` → host 8080 maps to container 80 ✅
- `curl http://localhost:8080/...` → hits Podman, not IIS ✅

---

## Lessons Learned — Common Pitfalls from Sessions 2–4

| # | Pitfall | Symptom | Fix |
|---|---|---|---|
| 1 | `-p` flag after image name | `PORTS` column shows no host binding; curl fails | Put all flags **before** the image name |
| 2 | Reusing a stopped container name | `Error: container name already in use` | `podman stop` + `podman rm` before reusing name |
| 3 | Host port 80 taken by IIS | curl returns IIS 404 page | Use host ports ≥ 8000 on Windows |
| 4 | ENV port ≠ EXPOSE port ≠ -p container port | `connection closed unexpectedly` | All three must agree: `ENV=80`, `EXPOSE 80`, `-p X:80` |
| 5 | HTTPS ports without certificate | `Unable to configure HTTPS endpoint` | Remove HTTPS config from container; use reverse proxy for TLS |
| 6 | Building without context (`.`) | `Error: no context directory and no Containerfile specified` | Always include `.` at end of `podman build` command |
| 7 | `podman rm` on running container | `cannot remove container as it is running` | `podman stop` first, then `podman rm` |
